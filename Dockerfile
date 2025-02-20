# syntax=docker/dockerfile:1.2
FROM --platform=$BUILDPLATFORM messense/rust-musl-cross:x86_64-musl AS builder

# Set working directory
WORKDIR /usr/src/adguard-tui

# Copy source code
COPY . .

# Force Cargo to generate a new lock file with the current version
RUN rm -f Cargo.lock && \
    cargo generate-lockfile && \
    cargo build --release

# Final stage
FROM scratch
COPY --from=builder /usr/src/adguard-tui/target/x86_64-unknown-linux-musl/release/adguard-tui /
ENTRYPOINT ["/adguard-tui"]