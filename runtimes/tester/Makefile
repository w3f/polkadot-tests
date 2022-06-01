# Default targets
TARGETS_DEFAULT := hash json raw
TARGETS_LEGACY  := $(patsubst %,%-legacy,$(TARGETS_DEFAULT))

.PHONY: .FORCE all legacy $(TARGETS_DEFAULT) $(TARGETS_LEGACY) version clean
.FORCE: # Always run cargo to check for changes

default: $(TARGETS_DEFAULT)

legacy: $(TARGETS_LEGACY)

# Plain version, no features
OUTPUTS_DEFAULT := $(patsubst %,genesis.default.%,$(TARGETS_DEFAULT))

$(TARGETS_DEFAULT): %: genesis.default.%

$(OUTPUTS_DEFAULT): genesis.default.%: .FORCE
	cargo run --release $* > $@

# Legacy state storage version
OUTPUTS_LEGACY := $(patsubst %,genesis.legacy.%,$(TARGETS_DEFAULT))

$(TARGETS_LEGACY): %-legacy: genesis.legacy.%

$(OUTPUTS_LEGACY): genesis.legacy.%: .FORCE
	cargo run --release --features legacy $* > $@

# Targets for developers
version:
	@cargo metadata --format-version 1 | jq '.packages[] | select(.name=="sp-core").id' | cut -d' ' -f2

clean:
	$(RM) -r target genesis.{default,legacy}.{hash,json,raw}
