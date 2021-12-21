using .HostFixture
using Test


tester = HostFixture.Tester("Raw Genesis", true, "tester")

HostFixture.execute(tester, 10) do (root, result)
    # Extract all hashes returned from log
    hashes = map(m -> m[1], eachmatch(r"##([^#\n]+)##", result)) 

    # Check state root hash
    @test root == hashes[1]


    # Extract all calls made from log
    calls = map(m -> m[1], eachmatch(r"@@([^@\n]+)@@", result))

    # Check that grandpa config is requested
    @test "grandpa_authorities()" in calls

    # Check that babe configuration is requested
    @test "configuration()" in calls
end
