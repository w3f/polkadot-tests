# Polkadot Conformance Testsuite

[![License](https://img.shields.io/github/license/w3f/polkadot-tests.svg)](https://github.com/w3f/polkadot-tests/blob/main/LICENSE)
[![Conformance Testsuite](https://github.com/w3f/polkadot-tests/workflows/conformance.yml/badge.svg)](https://github.com/w3f/polkadot-tests/actions/workflows/conformance.yml)
[![Integration Testsuite](https://github.com/w3f/polkadot-tests/workflows/integration.yml/badge.svg)](https://github.com/w3f/polkadot-tests/actions/workflows/integration.yml)
[![Cachix Cache](https://img.shields.io/badge/cachix-polkadot--tests-blue.svg)](https://polkadot-tests.cachix.org)
[![Nix Integration](https://github.com/w3f/polkadot-tests/actions/workflows/nix-flake.yml/badge.svg)](https://github.com/w3f/polkadot-tests/actions/workflows/nix-flake.yml)

This repository contains specification tests of the different components of Polkadot, which are run against the different implementations (i.e in Rust, C++ and Golang) of Polkadot

Currently the testsuite contains the following tests:

- SCALE Codec Encoding ([scale-codec](fixtures/state-trie))
- State Trie Hashing ([state-trie](fixtures/state-trie))
- Polkadot Host API ([host-api](fixtures/host-api))
- Genesis Import ([genesis](fixtures/genesis))

The goal is to ensure that the different implementations behave in the same way and produce the identical output, which is the necessary basis for the interoperability of all Polkadot clients.

The implementation under test is made available via git submodules, so it is recommended to clone this repository with `--recurse-submodules` or to intialize them after the fact with `git submodule init`.

# Dependencies

To run the test against various implementation, the suite utilizes mutliple binaries that have to be compiled or downloaded before the test suite can be run.

To build and run the test suite from source, it depends on the following components:

- _julia_ to run the testsuite
- _rust-nightly_ (with wasm target) to build substrate host and adpater (as well as testers and wasm-adapter)
- _cmake_ and _gcc_ or _clang_ (version 8 or 9 of either) to build kagome host and adapter
- _go_ to build gossamer host and adapter

While the official target of our testsuite are currently only debian-based systems, there is in general no reason for it to not be able to run on any recent GNU/Linux or even UNIX-based OS, like OS X.

## General Build

There is a simple Makefile in the [root directory](./), that will build all the required API adapters, testers and hosts when you run `make`. Any successful build will lead to the resulting binary being copied into the `bin`  subfolder. This should allow you to run any of the fixtures in the test suite afterwards. The Makefile additionally allows you only build specific binaries or groups by providing a separate target for each (e.g. `make kagome-adapter gossamer-host` or `make adapters`).

If you only want to run a certain fixture or only test a specific implementation, you might therefore not need to build all adapters, testers and hosts. The only binary needed for most tests is the `substrate-adapter` (as it is used as the reference implementation). Furthermore you only need to build any of the hosts if you want to run any `host-tester` based fixture (i.e. only `genesis` at the moment).
It should also be noted that the testsuite will pick up any hosts (or adapters) in your `PATH` first, so if you already have any of those installed you can run the test suite against the binaries in your `PATH` instead.

To build any of the hosts, please make sure you initialized the corresponding submodules in the [hosts subfolder](./hosts), e.g. with `git submodule update --init`.

### Substrate API Adapter

Needs Rust Nightly with WASM toolchain (and potentially libclang?)

```sh
make substrate-adapter
```

### Kagome API Adapter

Needs CMake, GCC or Clang >= 8 (GCC 10 currently broken), Rust, Perl, Python

```sh
make kagome-adapter
```

Set `HUNTER_USE_CACHE_SERVERS` to `YES` to use Soramitsu's binary cache. The adapter specific Makefile has the `enable-bincache` target to do exactly that.

### Gossamer API Adapter

Needs recent version of Go.

```sh
make gossamer-adapter
```

## On Debian-based systems

If you are on a debian-based system, here are some more concrete pointers to help you to set up your environment.

### Install dependencies

Install the required software in order to run build all adapters and to be able to run all tests.

**Note:** The test suite requires CMake version 3.12 or higher and gcc/g++ or clang version 8. However it is not recommended to change your default gcc/g++ versions for your whole installation, as that can lead to issues down the road. Please use the environment variables `CC` and `CXX` to temporally change the used compiler instead.

For example on 18.04, something like this should get you started:

```sh
apt update && apt install -y --no-install-recommends \
  build-essential \
  make \
  pkg-config \
  libssl-dev \
  clang \
  libclang-dev \
  wget \
  gcc-8 \
  g++-8 \
  golang \
  julia 
```

### Install recent CMake

This can be skipped on Ubunut 20.04, as a recent version of CMake can be installed through aptitude. Also see the official [cmake homepage](https://cmake.org/download) for the most recent version:

```sh
wget https://github.com/Kitware/CMake/releases/download/v3.17.2/cmake-3.17.2-Linux-x86_64.sh
chmod +x cmake-3.17.2-Linux-x86_64.sh
./cmake-3.17.2-Linux-x86_64.sh --skip-license --prefix=/usr/local
```

### Install Rust

While kagome only needs a recent version of rust, substrate depends on nightly and the wasm32 toolchain to build its nostd wasm targets.

```sh
curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly --target wasm32-unknown-unknown
```

### Force a recent C/C++ compiler

This is only needed before you build kagome (adapter). GCC 9, Clang 8 or Clang 9 work as well. Change example accordingly:

```sh
export CC=gcc-8
export CXX=g++-8
```

## Using Nix

We provide nix flake integration, however due to the use of submodules, integration is a bit unreliable. To intialize the repo, after cloning it and its submodules, just run the following command:

```sh
nix flake lock --update-input substrate-submodule --update-input kagome-submodule --update-input gossamer-submodule
```

# Running tests

By running `./runtests.jl` the automated tests get executed. With `./runtests.jl --verbose` the CLI parameters including the outputs can be displayed. Do note that this script must be run from this repos root directory, since it uses relative paths. Use `./runtests.jl --help` to learn how to run individual tests.

# Structure

All fixtures are written in julia and can be found in the fixtures folder. Each subfolder contains a seperate fixtures. To add a new fixture it is enough to add a new subfolder containing a `include.jl` file. 


Each of those tests defines how the final executable tests are called and pass data to it. The function names, testing data and results can be found in each fixtures subfolder.

## Structure of Polkadot Host API tests

Those adapters call functions that call the Polkadot Host API.

```text
+---------------------+
| host-api/include.jl |
|                     |
+----------|----------+
           |                      +------------------+
           +--------------------->+  Wasm Executor   |    *call runtime function*
           | substrate-adapter    |                  +---------------------------+
           |                      |                  |                           |
           |                      |                  |                           v
           |                      |  +---------------+                 +---------|-------+
           |                      |  | Polkadot Host |    *call API*   | hostapi-runtime |
           |                      |  |               +<----------------+                 |
           |                      |  |               |                 |                 |
           |                      +--|---------------+                 +-----------------+
           |
           |
           +---------------------> ...
           | gossamer-adapter
           |
           |
           +---------------------> ...
             kagome-adapter

```

Each adapter will use the custom Polkadot Runtime to call functions on the Wasm blob, which in return call the Polkadot Host API. The return values are then returned to the tester which will optionally print those values and compare them against the expected results.

Each adapter will use the custom Polkadot Runtime to call functions on the Wasm blob, which in return call the PDRE API. The return values are then returned to the tester which will optionally print those values and compare them against the expected results.

Relevant files:

|Directory/File                          |Description                        |
|----------------------------------------|-----------------------------------|
|*fixtures/host-api/include.jl*          | Passes data to different adapters |
|*fixtures/host-api/HostApiFunctions.jl* | Contains functions names          |
|*fixtures/host-api/HostApiInputs.jl*    | Contains input data               |
|*fixtures/host-api/HostApiOutputs.jl*   | Contains the outputs/results      |

The tests are executed in the following way:

`<adapter> host-api --function <function> --input <data>`

Example:

`substrate-adapter host-api --function test_blake2_128 --input "Horizontal"`

Each function gets tested with multiple inputs and then goes on to the next function.

In the Julia scripts, the functions (module *PdreApiTestFixtures*) are grouped together depending on the format of the inputs (module *PdreApiTestData*). Their outputs are compared with the corresponding list (module *PdreApiExpectedResults*). The sequence of those entries must be paid attention to.

This table shows the relationship between the lists.

|PdreApiTestFixtures     |PdreApiTestData             |PdreApiExpectedResults  |
|------------------------|----------------------------|------------------------|
|fn_crypto_hashes        |value_data                  |res_crypto_hashes       |
|fn_crypto_keys          |value_data                  |                        |
|fn_general_kv           |key_value_data              |res_storage_kv          |
|fn_storage_kv_offset    |key_value_data              |res_storage_kv_offset   |
|fn_storage_2x_kv        |prefix_key_value_data       |res_storage_2x_kv       |
|fn_storage_compare_set  |prefix_key_value_data       |res_storage_compare_set |
|fn_storage_prefix       |prefix_key_value_data       |                        |
|fn_storage_child_kv     |child_key_value_data        |res_storage_child       |
|fn_storage_child_2x_kv  |prefix_child_key_value_data |res_child_storage_root  |
|fn_storage_prefix_child |prefix_child_key_value_data |                        |
|fn_network              |                            |                        |

## Internals

Most of the internal logic of the testsuite can be found in the [helpers](./helpers) subfolder. 

The main module to configure and run the testsuite is called [`SpecificationTestsuite`](./helpers/SpecificationTestsuite.jl), which is also what [`runtests.jl`](./runtests.jl) uses to execute the suite after parsing any supplied command line arguments and extending PATH to include any local builds of adapters.

All the fixtures are located in their respective folder in the [`fixtures`](./fixtures) subfolder, while the fixture specific logic is contained in a file called `include.jl` for each of them.

# Update tested implementation

## Substrate and Parity Polkadot

The submodule in [hosts/substrate](./hosts/substrate) should always point to a recent commit or release of [Parity Polkadot](https://github.com/paritytech/polkadot).

After every update, `substrate-adapter` and `tester-runtime` should be update to the same substrate commit used by node in the submodule. This can be done by overwriting their `Cargo.lock` file with the one that comes with the submodule. You can use `make sync` in the the `hosts` subfolder which automates that process.

## Kagome

The `kagome-adapter` are build against the submodule under [hosts/kagome](./hosts/kagome) which should always point to a recent commit or release of [Kagome](https://github.com/soramitsu/kagome).

There are no special updates steps needed apart from fixing build and test failures or updating the `soramitsu-hunter` repository used.

## Gossamer

The `gossamer-adapter` are build against the submodule under [hosts/gossamer](./hosts/gossamer) which should always point to a recent commit or release of [Gossamer](https://github.com/ChainSafe/gossamer).

There are no special updates steps needed apart from fixing build and test failures.
