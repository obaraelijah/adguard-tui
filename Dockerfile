# syntax=docker/dockerfile:1.2

# Use Rust Alpine as the base builder
FROM --platform=$BUILDPLATFORM rust:1.69.0-alpine AS builder

# Install dependencies in one layer
RUN apk update && apk add --no-cache pkgconfig openssl openssl-dev musl-dev

# Set working directory
WORKDIR /usr/src/adguard-tui

COPY Cargo.toml Cargo.lock ./

# Create a dummy build to cache dependencies
RUN mkdir src && echo "fn main() {}" > src/main.rs && cargo build --release && rm -r src

COPY src ./src

# Build the release binary
RUN cargo build --release && strip target/release/adguard-tui

# Use scratch as the final image to keep it lightweight
FROM scratch
COPY --from=builder /usr/src/adguard-tui/target/release/adguard-tui /
ENTRYPOINT ["/adguard-tui"]
