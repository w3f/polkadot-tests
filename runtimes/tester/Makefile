.PHONY: all build version clean

all: genesis.hash genesis.json genesis.raw.json

build:
	cargo build --release

genesis.hash: build
	cargo run --release hash > $@

genesis.json: build
	cargo run --release json > $@

genesis.raw.json: build
	cargo run --release raw > $@

version:
	@cargo metadata --format-version 1 | jq '.packages[] | select(.name=="sp-core").id' | cut -d' ' -f2

clean:
	rm -rf target genesis.hash genesis.json genesis.raw.json
