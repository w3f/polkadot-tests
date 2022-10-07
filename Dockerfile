FROM mcr.microsoft.com/vscode/devcontainers/base:0-focal

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

# Setup environment
#RUN git submodule update --init

## Install Rust
ENV PATH="/root/.cargo/bin:${PATH}"
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y \
    --default-toolchain nightly \
    --target wasm32-unknown-unknown

## For C++/Kagome
ENV CC=gcc-8
ENV CXX=g++-8

COPY . .

RUN make runtimes
RUN make adapters
