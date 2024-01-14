FROM rust:1.75.0-alpine3.19 as builder

WORKDIR /usr/src/demon
RUN apk upgrade
RUN apk add --no-cache musl-dev curl

# Install cargo-leptos
RUN curl --proto '=https' --tlsv1.2 -LsSf https://github.com/leptos-rs/cargo-leptos/releases/download/0.2.5/cargo-leptos-installer.sh | sh

# Add the WASM target
RUN rustup target add wasm32-unknown-unknown

# Make an /app dir, which everything will eventually live in
RUN mkdir -p /app
WORKDIR /app
COPY . .

# Build the app
RUN cargo-leptos build --release -vv

FROM alpine:3.19.0
RUN apk update

# Copy the server binary to the /app directory
COPY --from=builder /app/target/release/server /app/
# /target/site contains our JS/WASM/CSS, etc.
COPY --from=builder /app/target/site /app/site
WORKDIR /app

# Set any required env variables and
ENV RUST_LOG="info"
ENV LEPTOS_SITE_ADDR="0.0.0.0:80"
ENV LEPTOS_SITE_ROOT="site"
EXPOSE 80

# Run the server
CMD ["/app/server"]
