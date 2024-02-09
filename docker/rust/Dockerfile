FROM rust:1.76.0-alpine3.19 as builder

WORKDIR /usr/src/financrr
COPY . .
RUN apk add --no-cache musl-dev

RUN cargo build --release

FROM alpine:3.19.1
RUN apk update

RUN addgroup -g 1000 -S financrr; \
        adduser -u 1000 -S -D -G financrr -H -h /home/financrr -s /bin/sh financrr;

#COPY --from=builder --chown=1000:1000 /usr/local/cargo/bin/financrr /home/financrr/financrr
COPY --from=builder --chown=1000:1000 /usr/src/financrr/target/release/backend /home/financrr/financrr

RUN chmod +x /home/financrr/financrr
USER financrr
WORKDIR /home/financrr
ENV ADDRESS=0.0.0.0:80
ENTRYPOINT ["/home/financrr/financrr"]
