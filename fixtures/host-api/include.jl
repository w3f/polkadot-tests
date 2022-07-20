include("./HostApiFunctions.jl")
include("./HostApiInputs.jl")
include("./HostApiOutputs.jl")

using .StringHelpers
using .AdapterFixture

tests = AdapterFixture.Builder("Host API", `host-api`)

HOSTAPI_FIXTURE_DATASETS = [
    [
        HostApiFunctions.none,
        nothing,
        HostApiOutputs.none,
    ],[
        HostApiFunctions.value,
        [
            HostApiInputs.value_1,
        ],
        HostApiOutputs.value .* "\n",
    ],[
        HostApiFunctions.child_key_value,
        [
            HostApiInputs.child_child,
            HostApiInputs.key_value_1,
        ],
        HostApiOutputs.child_key_value,
    ],[
        HostApiFunctions.child_key_value_offset_buffer_size,
        [
            HostApiInputs.child_child,
            HostApiInputs.key_value_1,
            HostApiInputs.offset,
            HostApiInputs.buffer_size,
        ],
        HostApiOutputs.key_value_offset_buffer_size .* "\n",
    ],[
        HostApiFunctions.child_prefix_key_value_key_value,
        [
            HostApiInputs.child_child,
            HostApiInputs.prefix_key_value_key_value,
        ],
        HostApiOutputs.child_prefix_key_value_key_value,
    ],[
        HostApiFunctions.child_key_value_key_value,
        [
            HostApiInputs.child_child,
            HostApiInputs.key_value_1,
            HostApiInputs.key_value_2,
        ],
        HostApiOutputs.child_key_value_key_value,
    ],[
        HostApiFunctions.key_value,
        [
            HostApiInputs.key_value_1,
        ],
        HostApiOutputs.key_value,
    ],[
        HostApiFunctions.key_value_offset_buffer_size,
        [
            HostApiInputs.key_value_1,
            HostApiInputs.offset,
            HostApiInputs.buffer_size,
        ],
        HostApiOutputs.key_value_offset_buffer_size .* "\n",
    ],[
        HostApiFunctions.prefix_key_value_key_value,
        [
            HostApiInputs.prefix_key_value_key_value,
        ],
        nothing,
    ],[
        HostApiFunctions.key_value_key_value,
        [
            HostApiInputs.key_value_1,
            HostApiInputs.key_value_2,
        ],
        HostApiOutputs.key_value_key_value .* "\n",
    ],[
        HostApiFunctions.seed,
        [
            HostApiInputs.seed_1,
        ],
        HostApiOutputs.seed .* "\n",
    ],[
        HostApiFunctions.seed_seed,
        [
            HostApiInputs.seed_1,
            HostApiInputs.seed_2,
        ],
        nothing,
    ],[
        HostApiFunctions.seed_msg,
        [
            HostApiInputs.seed_1,
            HostApiInputs.value_1[1:6],
        ],
        nothing,
    ],[
        HostApiFunctions.key_value_key_value_key_value,
        [
            HostApiInputs.key_value_1,
            HostApiInputs.key_value_2,
            HostApiInputs.key_value_3,
        ],
        HostApiOutputs.key_value_key_value_key_value .* "\n",
    ],[
        HostApiFunctions.value_value_value,
        [
            HostApiInputs.value_1,
            HostApiInputs.value_2,
            HostApiInputs.value_3,
        ],
        HostApiOutputs.value_value_value .* "\n",
#    ],[
#        HostApiFunctions.kind_key_value,
#        [
#            HostApiInputs.kind,
#            HostApiInputs.key_value_1,
#        ],
#        HostApiOutputs.kind_key_value,
#    ],[
#        HostApiFunctions.kind_key_value_value,
#        [
#            HostApiInputs.kind,
#            HostApiInputs.key_value_1,
#            HostApiInputs.value_1,
#        ],
#        HostApiOutputs.kind_key_value_value .* "\n",
    ]
]

for (func, input, output) in HOSTAPI_FIXTURE_DATASETS
    sub!(tests) do t
        arg!(t, `--function`)
        foreach!(t, func)

        if input != nothing
            arg!(t, `--input`)
            foreach!(t, commajoin(flatzip(input...)))
        end

        commit!(t, output)
    end
end

AdapterFixture.execute(tests)
