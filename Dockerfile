# syntax=docker/dockerfile:1.2
FROM --platform=$BUILDPLATFORM rust:1.75 AS builder
RUN rustup update stable
WORKDIR /usr/src/adguard-tui
COPY . .
RUN rm Cargo.lock && cargo build --release

FROM scratch
COPY --from=builder /usr/src/adguard-tui/target/release/adguard-tui /
ENTRYPOINT ["/adguard-tui"]