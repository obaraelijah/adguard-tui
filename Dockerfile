# syntax=docker/dockerfile:1.2
FROM --platform=$BUILDPLATFORM rust:latest AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    musl-tools

# Update rust and add targets
RUN rustup update && \
    rustup default nightly && \
    rustup target add x86_64-unknown-linux-musl

# Set working directory
WORKDIR /usr/src/adguard-tui

# Copy source code
COPY . .

# Delete the existing Cargo.lock and generate a new one
RUN rm -f Cargo.lock && \
    cargo update && \
    cargo build --release --target x86_64-unknown-linux-musl

# Final stage
FROM scratch
COPY --from=builder /usr/src/adguard-tui/target/x86_64-unknown-linux-musl/release/adguard-tui /
ENTRYPOINT ["/adguard-tui"]