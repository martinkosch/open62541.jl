const UA_STRING_NULL = UA_String(0, C_NULL)
const UA_GUID_NULL = UA_Guid(0, 0, 0, Tuple(zeros(UA_Byte, 8)))
const UA_NODEID_NULL = UA_NodeId(Tuple(zeros(UA_Byte, 24)))
const UA_EXPANDEDNODEID_NULL = UA_ExpandedNodeId(UA_NODEID_NULL, UA_STRING_NULL, 0)

#Julia number types that are rare built directly into open62541
#Does NOT include ComplexF32/64 - these have to be treated differently.
const UA_NUMBER_TYPES = Union{Bool, Int8, Int16, Int32, Int64, UInt8, UInt16, 
    UInt32, UInt64, Float32, Float64} 

include("generated_defs.jl")
include("helper_functions.jl")
include("types.jl")
include("callbacks.jl")
include("server.jl")
include("client.jl")
include("highlevel_types.jl")
include("highlevel_server.jl")
include("highlevel_client.jl")
include("attribute_generation.jl")
include("exceptions.jl")
include("init.jl")
    
# exports
const PREFIXES = ["UA_", "JUA_"]
for name in names(@__MODULE__; all = true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end
