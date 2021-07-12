.PHONY: all build install build-expmem install-expmem version clean

RELEASE_WASM_PATH := target/release/wbuild/hostapi-runtime/hostapi_runtime.compact.wasm


all: install

build:
	cargo build --release

install: build
	cp $(RELEASE_WASM_PATH) ../../bin/hostapi-runtime.default.wasm


build-expmem:
	cargo build --features export-memory --release

install-expmem: build-expmem
	cp $(RELEASE_WASM_PATH) ../../bin/hostapi-runtime.expmem.wasm


version:
	@echo "Unknown"

clean:
	rm -rf target
