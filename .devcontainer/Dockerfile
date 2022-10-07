# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.245.2/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version (use ubuntu-22.04 or ubuntu-18.04 on local arm64/Apple Silicon): ubuntu-22.04, ubuntu-20.04, ubuntu-18.04
ARG VARIANT="focal"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

# Install dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        curl \
        build-essential \
        make \
        cmake \
        pkg-config \
        libssl-dev \
        clang \
        libclang-dev \
        wget \
        gcc-8 \
        g++-8 \
        golang \
        julia 

# Setup environment for user
USER vscode

## Install Rust
ENV PATH="/home/vscode/.cargo/bin:${PATH}"
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y \
    --default-toolchain nightly
RUN rustup target add wasm32-unknown-unknown

## For C++/Kagome
ENV CC=gcc-8
ENV CXX=g++-8
