.PHONY: all configure build install enable-hunter disable-hunter enable-bincache disable-bincache enable-upload disable-upload version format clean

all: install


configure: 
	cmake -DCMAKE_BUILD_TYPE=Release -S . -B build

build: configure
	cmake --build build

install: build
	cp build/kagome-adapter ../../bin/


enable-hunter: 
	cmake -DHUNTER_ENABLED=YES -S . -B build

disable-hunter: 
	cmake -DHUNTER_ENABLED=NO -S . -B build


enable-bincache: 
	cmake -DHUNTER_USE_CACHE_SERVERS=YES -S . -B build

disable-bincache:
	cmake -DHUNTER_USE_CACHE_SERVERS=NO -S . -B build


enable-upload:
	cmake -DHUNTER_RUN_UPLOAD=YES -S . -B build

disable-upload:
	cmake -DHUNTER_RUN_UPLOAD=NO -S . -B build


version:
	@grep "github.com/soramitsu/kagome" cmake/HunterConfig.cmake | grep -o -E "[0-9a-f]{40}"


format:
	find src -iname *.hpp -o -iname *.cpp | xargs clang-format -i


clean:
	rm -rf build
