#!/usr/bin/env julia

include("helpers/SpecificationTestsuite.jl")

using .SpecificationTestsuite


function print_usage()
    println("usage: $PROGRAM_FILE [OPTIONS] [FILTERS ...] --args [ARGS ...]")
    println()
    println("OPTIONS:")
    println("  --help       Display this message")
    println("  --verbose    Print debug information")
    println("  --docker     Use docker containers instead of local builds.")
    println()
    println("FILTERS:")
    println("A filter can be used to run specific implementations or fixtures.")
    println("If none are provided all are run. Multiple selecetions are possible.")
    println()
    println("IMPLEMENTATIONS:")
    println(join(ALL_IMPLEMENTATIONS, ", "))
    println()
    println("FIXTURES:")
    println(join(ALL_FIXTURES, ", "))
    println()
    println("EXTRA ARGUMENTS:")
    println("To run the underlying adapter or host with additional arguments, any extra")
    println("arguments passed after --args will be forwarded to the binary.")
end


# Collect filters
implementations = Vector{String}()
fixtures = Vector{String}()

# Collect additional arguments
forward_args = false
extra_args = Vector{String}()

# Process all command line arguments
for arg in ARGS

    if forward_args
        push!(extra_args, arg)
        continue
    end

    if arg == "--help"
        print_usage()
        exit()
    end

    if arg == "--verbose"
        Config.set_verbose(true)
        continue
    end

    if arg == "--docker"
        Config.set_docker(true)
        continue
    end

    if arg == "--args"
        global forward_args = true
        continue
    end

    if arg in ALL_IMPLEMENTATIONS
        push!(implementations, arg)
        continue
    end

    if arg in ALL_FIXTURES
        push!(fixtures, arg)
        continue
    end

    println("Unknown argument: ", arg)
    println()
    print_usage()
    exit()
end

# Apply any specified filters
if !isempty(implementations)
    Config.set_implementations(implementations)
end

if !isempty(fixtures)
    Config.set_fixtures(fixtures)
end

# Forward any extra flags
if !isempty(extra_args)
    Config.set_extra_args(extra_args)
end

# Display config
println("CONFIGURATION:")
println("Loglevel:        " * (Config.verbose ? "verbose"   : "info"))
println("Binaries:        " * (Config.docker  ? "container" : "local"))
println("Implementations: " * join(Config.implementations, ", "))
println("Fixtures:        " * join(Config.fixtures, ", "))
println("Extra Arguments: " * string(Config.extra_args))
println()

# Add locally build or downloaded adapters, testers and hosts to PATH
ENV["PATH"] *= ":$(@__DIR__)/bin"

# Add locally build libaries, because gossamer wasmer go extension does not
# support static linking yet and depends on libwasmer.so.
# https://github.com/wasmerio/go-ext-wasm/pull/40
if haskey(ENV, "LD_LIBRARY_PATH")
    ENV["LD_LIBRARY_PATH"] *= ":$(@__DIR__)/lib"
else
    ENV["LD_LIBRARY_PATH"] = "$(@__DIR__)/lib"
end

# Run from this subfolder (to allow relative paths in suite)
previous_path = pwd()
cd("$(@__DIR__)")

# Execute config
println("EXECUTION:")
execute()

# Reset path
cd(previous_path)

exit()
