# syntax=docker/dockerfile:1.2
FROM --platform=$BUILDPLATFORM rust:1.75 AS builder

# Install build dependencies and update rust
RUN rustup update stable && \
    rustup target add aarch64-unknown-linux-musl armv7-unknown-linux-musleabihf x86_64-unknown-linux-musl

# Set working directory
WORKDIR /usr/src/adguard-tui

# Copy source code
COPY . .

# Remove existing Cargo.lock and let cargo generate a new one
RUN rm -f Cargo.lock

# Build for the target platform
ARG TARGETPLATFORM
RUN case "$TARGETPLATFORM" in \
        "linux/amd64")  TARGET="x86_64-unknown-linux-musl" ;; \
        "linux/arm64")  TARGET="aarch64-unknown-linux-musl" ;; \
        "linux/arm/v7") TARGET="armv7-unknown-linux-musleabihf" ;; \
        *) TARGET="x86_64-unknown-linux-musl" ;; \
    esac && \
    cargo update && \
    cargo build --release --target $TARGET

# Final stage
FROM scratch
ARG TARGETPLATFORM
COPY --from=builder /usr/src/adguard-tui/target/*/release/adguard-tui /
ENTRYPOINT ["/adguard-tui"]