
FROM ghcr.io/gleam-lang/gleam:v1.14.0-erlang-alpine AS tailwind-generation
WORKDIR /src
RUN apk add --no-cache curl ca-certificates
COPY . .
RUN mkdir -p priv/css && gleam run -m tailwind/install && gleam run -m tailwind/run

# Pre-fetch and resize news article images at build time so the runtime
# doesn't need Elixir, libvips, or any image-processing dependencies.
FROM python:3.13-slim AS image-fetcher
RUN pip install --no-cache-dir Pillow
WORKDIR /build
COPY src/news.gleam src/
COPY scripts/ scripts/
RUN python3 scripts/fetch_news_images.py

FROM ghcr.io/gleam-lang/gleam:v1.14.0-erlang-alpine
COPY . /build/
RUN cd /build && gleam export erlang-shipment
RUN mv /build/build/erlang-shipment /app && rm -r /build
RUN apk add --no-cache curl ca-certificates
COPY ./priv /app/priv/
COPY --from=image-fetcher /build/priv/static/news_images /app/priv/static/news_images
COPY --from=tailwind-generation /src/priv/css/tailwind.css /app/priv/css/

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl --fail http://localhost:8000/health || exit 1

EXPOSE 8000
ENV ERL_FLAGS="+MBacul 80 +MHacul 80 +MLacul 80 +MSacul 80"
WORKDIR /app
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]

