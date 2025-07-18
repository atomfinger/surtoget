
FROM node:22-alpine AS tailwind-generation
WORKDIR /src
COPY package.json package-lock.json ./
RUN npm install
COPY . .
RUN ./node_modules/.bin/tailwindcss -i ./src/styles.css -o ./priv/css/tailwind.css --minify

FROM ghcr.io/gleam-lang/gleam:v1.11.1-elixir-alpine
RUN mix local.hex --force
COPY . /build/
RUN cd /build && gleam export erlang-shipment
RUN mv /build/build/erlang-shipment /app && rm -r /build
RUN apk add --no-cache 
COPY ./priv /app/priv/
COPY --from=tailwind-generation /src/priv/css/tailwind.css /app/priv/css/

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl --fail http://localhost:8000/health || exit 1

EXPOSE 8000
WORKDIR /app
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]

