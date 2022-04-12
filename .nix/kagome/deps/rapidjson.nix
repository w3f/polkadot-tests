{ fetchFromGitHub, rapidjson }:

rapidjson.overrideAttrs (super: rec {
  name = "${super.pname}-${version}";
  version = "1.1.0-66eb606-p0";

  src = fetchFromGitHub {
    owner = "hunter-packages";
    repo = "rapidjson";
    rev = "v${version}";
    sha256 = "19117mlw5z4wwf8ix5hkwjk00hgvngjdiwaj8kqfb069l5m04j32";
  }; 
})
