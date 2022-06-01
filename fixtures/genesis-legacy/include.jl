using .HostFixture
using Test


tester = HostFixture.Tester("Legacy Genesis", "tester", "legacy")

HostFixture.execute(tester, 10) do (root, result)
    # Extract all hashes returned from log
    hashes = map(m -> m[1], eachmatch(r"##([^#\n]+)##", result)) 

    # Check state root hash
    @test root == hashes[1]
end
