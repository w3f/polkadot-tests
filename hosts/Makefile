.PHONY: all substrate kagome gossamer sync-substrate sync-adapter-substrate sync-runtime-tester sync-gossamer sync-adapter-gossamer version clean


all: substrate kagome gossamer


substrate:
	cd substrate && SKIP_WASM_BUILD=1 cargo build --release
	cp substrate/target/release/polkadot ../bin/

kagome:
	cmake -DCMAKE_BUILD_TYPE=Release -DHUNTER_CONFIGURATION_TYPES=Release \
	      -DHUNTER_PASSWORDS_PATH="$(CURDIR)/../adapters/kagome/cmake/HunterPasswords.cmake" \
	      -DHUNTER_CACHE_SERVERS="https://github.com/w3f/hunter-binary-cache" \
	      -DTESTING=OFF -S kagome -B kagome/build
	cmake --build kagome/build
	cp kagome/build/node/kagome ../bin/

gossamer:
	cd gossamer && go build -v ./cmd/gossamer
	cp gossamer/gossamer ../bin/
	cp ~/go/pkg/mod/github.com/wasmerio/go-ext-wasm@*/wasmer/libwasmer.so ../lib/
	chmod u+w ../lib/libwasmer.so


sync-substrate: sync-adapter-substrate sync-runtime-tester 

sync-adapter-substrate:
	cp substrate/Cargo.lock ../adapters/substrate/
	cargo metadata --manifest-path ../adapters/substrate/Cargo.toml --format-version 1 > /dev/null

sync-runtime-tester:
	cp substrate/Cargo.lock ../runtimes/tester
	cargo metadata --manifest-path ../runtimes/tester/Cargo.toml --format-version 1 > /dev/null


sync-gossamer: sync-adapter-gossamer

sync-adapter-gossamer:
	cd ../adapters/gossamer && go mod tidy


version:
	@echo "substrate-host: $$(cd substrate && git describe)"
	@echo "kagome-host: $$(cd kagome && git describe)"
	@echo "gossamer-host: $$(cd gossamer && git describe --tags)"

clean:
	rm -rf substrate/target
	rm -rf kagome/build
	rm  -f gossamer/gossamer
