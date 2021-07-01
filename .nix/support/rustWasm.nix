{ rustChannelOf, makeRustPlatform }:

let
  channel = rustChannelOf {
    date = "2021-04-15";
    channel = "nightly";
    sha256 = "09rn65aj7v4fxv5l7wh7m68f372c0qxdxiayr0kg5bslbx9payfy";
  };
in 
  channel.rust.override { targets = [ "wasm32-unknown-unknown" ]; }
