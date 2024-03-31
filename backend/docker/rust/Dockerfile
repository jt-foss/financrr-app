FROM rust:1.77.0-alpine3.19 AS builder

RUN apk add --no-cache musl-dev

WORKDIR /usr/src/financrr
COPY . .

RUN cargo build --release

# Final stage: create a minimal runtime image
FROM alpine:3.19.1

# Update package repositories
RUN apk update

# Create a non-root user
RUN addgroup -g 1000 -S financrr && \
    adduser -u 1000 -S -D -G financrr -H -h /home/financrr -s /bin/sh financrr

# Set the working directory
WORKDIR /home/financrr

# Copy the binaries from the builder stage
COPY --from=builder --chown=1000:1000 //usr/src/financrr/target/release/backend /home/financrr/financrr
COPY --from=builder --chown=1000:1000 /usr/src/financrr/target/release/migration /home/financrr/migrator

# Set permissions for the binary
RUN chmod +x /home/financrr/financrr
RUN chmod +x /home/financrr/migrator

# Switch to non-root user
USER financrr

# Entrypoint command
ENTRYPOINT ["/home/financrr/financrr"]
