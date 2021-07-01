{ mkShell, julia, jq, yq
, substrate-host,    kagome-host,    gossamer-host
, substrate-adapter, kagome-adapter, gossamer-adapter
, hostapi-runtime, tester-runtime
}:

mkShell {
  name = "spectest-env";

  buildInputs = [
    # Julia and tools
    julia
    jq
    yq

    # Implementations
    substrate-host
    kagome-host
    gossamer-host

    # API adapters
    substrate-adapter
    kagome-adapter
    gossamer-adapter

    # Runtimes
    hostapi-runtime
    tester-runtime
  ];
}
