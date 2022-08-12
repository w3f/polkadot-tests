module SpecificationTestsuite

    # Include general helpers
    include("StringHelpers.jl")


    export ALL_IMPLEMENTATIONS, ALL_FIXTURES, Config, execute

    "List of all known implementations"
    const ALL_IMPLEMENTATIONS = [
      "substrate"
      "smoldot"
      "kagome"
      "gossamer"
    ]

    module Config
        import ..SpecificationTestsuite: ALL_IMPLEMENTATIONS
        import ..StringHelpers: StringList, CmdString, CmdStringList, cmdjoin

        "By default we log on a warning level."
        verbose = false

        "By default command are run on host."
        docker = false

        "Default containers to use in docker mode"
        containers = Dict{String,String}(
            "substrate" => "parity/polkadot:v0.8.5",
            #"kagome"    => "docker.pkg.github.com/w3f/polkadot-spec/kagome:xxxxxxx",
            #"gossamer"  => "docker.pkg.github.com/w3f/polkadot-spec/gossamer:xxxxxxx",
        )

        "By default all implementations are enabled."
        implementations = ALL_IMPLEMENTATIONS

        "By default no additional arguments are passed."
        extra_args = ``

        "Path of folder containing all fixtures."
        function fixdir()::String
            return "$(@__DIR__)/../fixtures"
        end

        "All subfolders of the fixture folder (i.e. all available fixtures)."
        function fixsubdirs()::StringList
            return first(walkdir(fixdir()))[2]
        end

        "By default all fixtures are enabled."
        fixtures = fixsubdirs()

        "Update verbose setting in config"
        function set_verbose(enabled::Bool)
            global verbose = enabled
        end

        "Update selected implementations in config"
        function set_implementations(selected::StringList)
            global implementations = selected
        end

        "Update selected fixtures in config"
        function set_fixtures(selected::StringList)
            global fixtures = selected
        end

        "Update additional arguments to pass to executable"
        function set_extra_args(selected::CmdString)
            global extra_args = selected
        end

        "Update additional arguments to pass to executable"
        function set_extra_args(selected::CmdStringList)
            set_extra_args(cmdjoin(selected))
        end

        "Update docker settings in config"
        function set_docker(enabled::Bool)
            global docker = enabled
        end

        "Retrieve docker image name to use in docker mode"
        function get_container(implementation::String)::String
            if !(implementation in ALL_IMPLEMENTATIONS)
                @error "Unknown implementation '$implementation'"
            end
            return get(containers, implementation, "")
        end
    end

    "List of all available fixtures"
    const ALL_FIXTURES = Config.fixsubdirs()

    # Include fixture helpers
    include("AdapterFixture.jl")
    include("HostFixture.jl")

    "Run specific fixture for configure implementations"
    function run_fixture(fixture::String)
        if !(fixture in ALL_FIXTURES)
            error("Unknown fixture: " * fixture)
        end

        @time include(Config.fixdir() * "/$fixture/include.jl")
    end

    "Run all configured fixtures"
    function execute()
        for fixture in Config.fixtures
            run_fixture(fixture)
        end
    end
end

