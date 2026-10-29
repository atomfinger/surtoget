# Base images are pinned by digest; Renovate updates the tag and digest together.
FROM debian:bookworm-slim@sha256:99c0b25c46d0214d5a2091092e7908907dcaecd6a962cde0ac700acee222b6f3 AS tailwind-generation
WORKDIR /src
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && rm -rf /var/lib/apt/lists/*
COPY src/ src/
# The checksums are from the release's sha256sums.txt; update them together
# with the version (also in gleam.toml's [tailwind]).
RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
      x86_64)  TW_ARCH="linux-x64"; TW_SHA256="737becf8d4ad1115ea98df69fa94026d402ca8feb91306a035b5b004167da8dd" ;; \
      aarch64) TW_ARCH="linux-arm64"; TW_SHA256="7a7702db6c93718a9b6655d455304edda18600f5a4f195242342ed3b5b70ebe8" ;; \
      *) echo "Unsupported architecture: $ARCH" >&2 && exit 1 ;; \
    esac && \
    mkdir -p priv/css build/bin && \
    curl -fsSL "https://github.com/tailwindlabs/tailwindcss/releases/download/v4.1.18/tailwindcss-${TW_ARCH}" -o build/bin/tailwindcss && \
    echo "${TW_SHA256}  build/bin/tailwindcss" | sha256sum -c - && \
    chmod +x build/bin/tailwindcss && \
    ./build/bin/tailwindcss --input=./src/styles.css --output=./priv/css/tailwind.css

# Pre-fetch and resize news article images at build time so the runtime
# doesn't need Elixir, libvips, or any image-processing dependencies.
FROM python:3.15.2-slim@sha256:c4158543ecb725b99e57d129dfd43d761d4c43e4577b5e23326aabb223cf7f4e AS image-fetcher
WORKDIR /build
COPY scripts/requirements.txt scripts/
RUN pip install --no-cache-dir --require-hashes --only-binary :all: \
      -r scripts/requirements.txt
COPY src/news.gleam src/
COPY scripts/ scripts/
RUN python3 scripts/fetch_news_images.py

FROM ghcr.io/gleam-lang/gleam:v1.19.2-erlang-alpine@sha256:64b1df35a9611332d51f77c97f16f50ec97863162ba8824400ed4c8dff6378ac AS build
COPY . /build/
RUN cd /build && gleam export erlang-shipment
RUN mv /build/build/erlang-shipment /app && rm -r /build
COPY ./priv /app/priv/
COPY --from=image-fetcher /build/priv/static/news_images /app/priv/static/news_images
COPY --from=tailwind-generation /src/priv/css/tailwind.css /app/priv/css/

# Runtime: plain Erlang without the Gleam/rebar toolchain, running as an
# unprivileged user. Keep the OTP major in step with the gleam image above
# when bumping either (there are no NIFs, so the Alpine branch matters less).
# The tag must be published
# for linux/amd64; older patch tags aren't, and Docker then silently pulls
# linux/386. `apk upgrade` picks up Alpine security fixes between base bumps.
FROM erlang:29.1.2-alpine@sha256:8cd3da3d4d04563479655f7b1d8cf24f075e3ab8f665f21ca18eab1593365256
RUN apk upgrade --no-cache \
    && addgroup -S app \
    && adduser -S -G app app
COPY --from=build /app /app
USER app

# busybox wget instead of installing curl just for this.
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:8000/health || exit 1

EXPOSE 8000
ENV ERL_FLAGS="+MBacul 80 +MHacul 80 +MLacul 80 +MSacul 80"
WORKDIR /app
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]
