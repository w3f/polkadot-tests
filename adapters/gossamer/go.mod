module w3f/gossamer-adapter

require (
	github.com/ChainSafe/gossamer v0.2.1-0.20210115002259-7c0a61a29bc6
	github.com/dgraph-io/ristretto v0.0.3 // indirect
	github.com/dgryski/go-farm v0.0.0-20200201041132-a6ae2369ad13 // indirect
	github.com/go-yaml/yaml v2.1.0+incompatible
)

replace github.com/ChainSafe/gossamer => ../../hosts/gossamer

go 1.14
