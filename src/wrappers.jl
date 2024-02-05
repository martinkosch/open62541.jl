#Preliminary definitions
abstract type AbstractOpen62541Wrapper end

Jpointer(x::AbstractOpen62541Wrapper) = getfield(x, :ptr)
function Base.getproperty(x::AbstractOpen62541Wrapper, f::Symbol)
    unsafe_load(getproperty(Jpointer(x), f))
end

function Base.unsafe_convert(::Type{Ptr{T}}, obj::AbstractOpen62541Wrapper) where {T}
    Base.unsafe_convert(Ptr{T}, Jpointer(obj))
end

## Useful basic types
#String
mutable struct JUA_String <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_String}
    function JUA_String(s::AbstractString)
        obj = new(UA_STRING(s))
        finalizer(release_handle, obj)
        return obj
    end
end

function release_handle(obj::JUA_String)
    UA_String_delete(Jpointer(obj))
end

#Guid
mutable struct JUA_Guid <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_Guid}
    function JUA_Guid()
        obj = new(UA_Guid_random())
        finalizer(release_handle, obj)
        return obj
    end
    function JUA_Guid(guidstring::AbstractString)
        obj = new(UA_GUID(guidstring))
        finalizer(release_handle, obj)
        return obj
    end
end

function release_handle(obj::JUA_Guid)
    UA_Guid_delete(Jpointer(obj))
end

## Server and server config
mutable struct JUA_Server <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_Server}
    function JUA_Server()
        obj = new(UA_Server_new())
        finalizer(release_handle, obj)
        return obj
    end
end

function release_handle(obj::JUA_Server)
    UA_Server_delete(Jpointer(obj))
end

mutable struct JUA_ServerConfig <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_ServerConfig}
    function JUA_ServerConfig(server::JUA_Server)
        #no finalizer, because the config object lives and dies with the server itself
        obj = new(UA_Server_getConfig(server))
        return obj
    end
end

function JUA_Server_getConfig(server::JUA_Server)
    return JUA_ServerConfig(server)
end

#aliasing functions that interact with server and serverconfig
const JUA_ServerConfig_setMinimalCustomBuffer = UA_ServerConfig_setMinimalCustomBuffer
const JUA_ServerConfig_setMinimal = UA_ServerConfig_setMinimal
const JUA_ServerConfig_setDefault = UA_ServerConfig_setDefault
const JUA_ServerConfig_setBasics = UA_ServerConfig_setBasics
const JUA_ServerConfig_addNetworkLayerTCP = UA_ServerConfig_addNetworkLayerTCP
const JUA_ServerConfig_addSecurityPolicyNone = UA_ServerConfig_addSecurityPolicyNone
const JUA_ServerConfig_addEndpoint = UA_ServerConfig_addEndpoint
const JUA_ServerConfig_addAllEndpoints = UA_ServerConfig_addAllEndpoints
const JUA_ServerConfig_clean = UA_ServerConfig_clean
const JUA_AccessControl_default = UA_AccessControl_default
const JUA_AccessControl_defaultWithLoginCallback = UA_AccessControl_defaultWithLoginCallback

## NodeIds
mutable struct JUA_NodeId <: AbstractOpen62541Wrapper
    ptr::Ptr{UA_NodeId}

    function JUA_NodeId()
        obj = new(UA_NodeId_new())
        finalizer(release_handle, obj)
        return obj
    end
    function JUA_NodeId(identifier::Union{AbstractString, JUA_String})
        obj = new(UA_NODEID(identifier))
        finalizer(release_handle, obj)
        return obj
    end
    function JUA_NodeId(nsIndex::Integer, identifier::Integer)
        obj = new(UA_NODEID_NUMERIC(nsIndex, identifier))
        finalizer(release_handle, obj)
        return obj
    end
    function JUA_NodeId(nsIndex::Integer, identifier::Union{AbstractString, JUA_String})
        obj = new(UA_NODEID_STRING_ALLOC(nsIndex, identifier))
        finalizer(release_handle, obj)
        return obj
    end
    function JUA_NodeId(nsIndex::Integer, identifier::JUA_Guid)
        obj = new(UA_NODEID_GUID(nsIndex, Jpointer(identifier)))
        finalizer(release_handle, obj)
        return obj
    end
end

function release_handle(obj::JUA_NodeId)
    UA_NodeId_delete(Jpointer(obj))
end

JUA_NodeId_equal(j1, j2) = UA_NodeId_equal(j1, j2)

#TODO: here we can do automatic unsafe_wrap on the content, so that the user doesn't have to do it.
# mutable struct JUA_Variant{T} <: AbstractOpen62541Wrapper
#     ptr::Ptr{UA_Variant}
#     v::T

#     function JUA_Variant()
#         obj = new(UA_Variant_new())
#         finalizer(release_handle, obj)
#         return obj
#     end
# end

# function release_handle(obj::JUA_Variant)
#     UA_Variant_delete(Jpointer(obj))
# end

#function JUA_Client_readValueAttribute(client, nodeId, out =  JUA_Variant())
