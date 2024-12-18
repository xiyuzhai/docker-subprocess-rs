FROM nvidia/cuda:12.3.1-devel-ubuntu22.04 AS builder

# Set NVIDIA specific environment variables
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# Install Rust and required dependencies
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Pre-create a directory for the app
WORKDIR /usr/src/container_app
COPY container_app .

# Build with release profile
RUN cargo build --release

# Runtime stage
FROM nvidia/cuda:12.3.1-runtime-ubuntu22.04

# Set NVIDIA specific environment variables in runtime image
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# Copy only the built binary
COPY --from=builder /usr/src/container_app/target/release/container-app /usr/local/bin/container-app

CMD ["container-app"] 