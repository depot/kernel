# Stage 1: Build environment
FROM ubuntu:24.04 AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libncurses-dev \
    bison \
    flex \
    libssl-dev \
    libelf-dev \
    git \
    bc \
    kmod \
    cpio \
    rsync \
    wget \
    python3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a working directory
WORKDIR /kernel-build

# Copy the Linux kernel source code
# Assuming the kernel source is in the current directory
COPY . .

# Build the kernel (set -j to the number of cores you want to use)
RUN make olddefconfig && \
    make headers && \
    make prepare && \
    make modules_prepare && \
    make scripts

RUN make -j$(nproc) && \
    make modules -j$(nproc)

# Stage 2: Final minimal image
FROM scratch

# Copy only the compiled kernel from the builder stage
COPY --from=builder /kernel-build/arch/x86/boot/bzImage /vmlinuz

# This results in a Docker image with just the kernel
