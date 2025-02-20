# syntax=docker/dockerfile:1.2
FROM --platform=$BUILDPLATFORM rustlang/rust:nightly AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    musl-tools

# Add musl target
RUN rustup target add x86_64-unknown-linux-musl

# Set working directory
WORKDIR /usr/src/adguard-tui

# Copy source code
COPY . .

# Force Cargo to use the latest format
RUN rm -f Cargo.lock && \
    CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse \
    cargo update && \
    CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse \
    cargo build --release --target x86_64-unknown-linux-musl

# Final stage
FROM scratch
COPY --from=builder /usr/src/adguard-tui/target/x86_64-unknown-linux-musl/release/adguard-tui /
ENTRYPOINT ["/adguard-tui"]