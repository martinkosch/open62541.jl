const UA_STRING_NULL = UA_String(0, C_NULL)
const UA_GUID_NULL = UA_Guid(0, 0, 0, Tuple(zeros(UA_Byte, 8)))
const UA_NODEID_NULL = UA_NodeId(tuple(zeros(UA_Byte, 24)))
const UA_EXPANDEDNODEID_NULL = UA_ExpandedNodeId(UA_NODEID_NULL, UA_STRING_NULL, 0)

include("generated_defs.jl")
include("helper_functions.jl")
include("types.jl")
include("attribute_generation.jl")
include("server.jl")
include("client.jl")
include("exceptions.jl")
include("init.jl")

# exports
const PREFIXES = ["UA_", "__UA_"]
for name in names(@__MODULE__; all = true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end
