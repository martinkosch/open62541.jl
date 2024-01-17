const UA_TYPES = Ref{Ptr{UA_DataType}}(0) # Initialize with C_NULL and initialize correct address during __init__
const UA_TYPES_PTRS = OffsetVector{Ptr{UA_DataType}}(undef, 0:(UA_TYPES_COUNT - 1)) # Initialize vector of UA_TYPES pointer undefined and write values during __init__
const UA_TYPES_MAP = Vector{DataType}(undef, UA_TYPES_COUNT) # Initialize vector of mapping between UA_TYPES and Julia types as undefined and write values during __init__

function juliadatatype(p::Ptr{UA_DataType})
    ind = Int(Int((p - UA_TYPES_PTRS[0])) / sizeof(UA_DataType))
    return UA_TYPES_MAP[ind + 1]
end

# Initialize default attribute definitions with C_NULL and initialize correct address during __init__ (extern variables are missed by Clang.jl)
const UA_VariableAttributes_default = Ref{UA_VariableAttributes}()
const UA_VariableTypeAttributes_default = Ref{UA_VariableTypeAttributes}()
const UA_MethodAttributes_default = Ref{UA_MethodAttributes}()
const UA_ObjectAttributes_default = Ref{UA_ObjectAttributes}()
const UA_ObjectTypeAttributes_default = Ref{UA_ObjectTypeAttributes}()
const UA_ReferenceTypeAttributes_default = Ref{UA_ReferenceTypeAttributes}()
const UA_DataTypeAttributes_default = Ref{UA_DataTypeAttributes}()
const UA_ViewAttributes_default = Ref{UA_ViewAttributes}()

function UA_init(p::Ref{T}) where {T}
    @ccall memset(p::Ptr{Cvoid}, 0::Cint, (sizeof(T))::Csize_t)::Ptr{Cvoid}
    return nothing
end

# ## UA_Array
# Julia wrapper for C array types
struct UA_Array{T <: Ptr} <: AbstractArray{T, 1}
    ptr::T
    length::Int64
end

function UA_Array(s::T, field::Symbol) where {T}
    size_fieldname = Symbol(field, :Size)
    ptr = getfield(s, field)
    datasize = getfield(s, size_fieldname)
    return UA_Array(ptr, Int64(datasize))
end

Base.size(a::UA_Array) = (a.length,)
Base.length(a::UA_Array) = a.length
Base.IndexStyle(::Type{<:UA_Array}) = IndexLinear()
function Base.getindex(a::UA_Array{Ptr{T}}, i::Int) where {T}
    1 <= i <= a.length || throw(BoundsError(a, i))
    return a.ptr + (i - 1) * sizeof(T)
end
Base.firstindex(a::UA_Array) = 1
Base.lastindex(a::UA_Array) = a.length
Base.setindex!(a::UA_Array, v, i::Int) = unsafe_store!(a.ptr, v, i)
Base.unsafe_wrap(a::UA_Array) = unsafe_wrap(Array, a[begin], size(a))
Base.pointer(a::UA_Array) = a[begin]
Base.convert(::Type{Ptr{T}}, a::UA_Array{Ptr{T}}) where {T} = a[begin]
Base.convert(::Type{Ptr{Nothing}}, a::UA_Array) = Base.unsafe_convert(Ptr{Nothing}, a)
Base.convert(::Type{Ptr{Nothing}}, a::UA_Array{Ptr{Nothing}}) = a[begin] # Avoid method ambigutiy
function Base.unsafe_convert(::Type{Ptr{Nothing}}, a::UA_Array)
    Base.unsafe_convert(Ptr{Nothing}, a[begin])
end

function UA_Array_init(p::UA_Array)
    for i in p
        UA_init(i)
    end
end

function UA_Array_new(v::AbstractArray{T},
        type_ptr::Ptr{UA_DataType} = ua_data_type_ptr_default(T)) where {T}
    v_typed = convert(Vector{juliadatatype(type_ptr)}, vec(v)) # Implicit check if T can be converted to type_ptr
    arr_ptr = convert(Ptr{T}, UA_Array_new(length(v), type_ptr))
    GC.@preserve v_typed unsafe_copyto!(arr_ptr, pointer(v_typed), length(v))
    return UA_Array(arr_ptr, length(v))
end

# Initialize empty array
function UA_Array_new(length::Integer, juliatype::DataType)
    type_ptr = ua_data_type_ptr_default(juliatype)
    ptr_arr = UA_Array_new(length, type_ptr)
    arr_ptr = convert(Ptr{juliatype}, ptr_arr)
    return UA_Array(arr_ptr, length)
end

function UA_print(p::T,
        type_ptr::Ptr{UA_DataType} = ua_data_type_ptr_default(T)) where {T}
    buf = UA_String_new()
    UA_print(wrap_ref(p), type_ptr, buf)
    s = unsafe_string(buf)
    UA_String_clear(buf)
    UA_String_delete(buf)
    return s
end

for (i, type_name) in enumerate(type_names)
    type_ind_name = Symbol("UA_TYPES_", uppercase(String(type_name)[4:end]))
    julia_type = julia_types[i]
    val_type = Val{type_name}

    @eval begin
        # Datatype map functions
        ua_data_type_ptr(::$(val_type)) = UA_TYPES_PTRS[$(i - 1)]
        if !(type_names[$(i)] in types_ambiguous_ignorelist)
            ua_data_type_ptr_default(::Type{$(julia_type)}) = UA_TYPES_PTRS[$(i - 1)]
            Base.show(io::IO, ::MIME"text/plain", v::$(julia_type)) = print(io, UA_print(v))
        end

        # Datatype specific constructors, destructors, initalizers, as well as clear and copy functions
        function $(Symbol(type_name, "_new"))()
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            return convert(Ptr{$(type_name)}, UA_new(data_type_ptr))
        end

        $(Symbol(type_name, "_init"))(p::Ptr{$(type_name)}) = UA_init(p)

        function $(Symbol(type_name, "_copy"))(src::Ref{$(type_name)},
                dst::Ptr{$(type_name)})
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            return UA_copy(src, dst, data_type_ptr)
        end

        function $(Symbol(type_name, "_copy"))(src::$(type_name),
                dst::Ptr{$(type_name)})
            return $(Symbol(type_name, "_copy"))(Ref(src), dst)
        end

        function $(Symbol(type_name, "_clear"))(p::Ptr{$(type_name)})
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            UA_clear(p, data_type_ptr)
        end
        
        function $(Symbol(type_name, "_delete"))(p::Ptr{$(type_name)})
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            UA_delete(p, data_type_ptr)
        end

        function $(Symbol(type_name, "_deleteMembers"))(p::Ptr{$(type_name)})
            oldname = :test
            newname = $(Symbol(type_name, "_clear"))
            Base.depwarn("$oldname is deprecated; use $newname instead",
                oldname,
                force = true)
            $(Symbol(type_name, "_clear"))(p::Ptr{$(type_name)})
        end

        function $(Symbol(type_name, "_Array_new"))(length::Integer)
            # TODO: Allow empty arrays with corresponding UA_EMPTY_ARRAY_SENTINEL indicator
            length <= 0 &&
                throw(DomainError(length, "Length of new array must be larger than zero."))
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            arr_ptr = convert(Ptr{$(type_name)}, UA_Array_new(length, data_type_ptr))
            return UA_Array(arr_ptr, length)
        end

        function $(Symbol(type_name, "_Array_new"))(v::Tuple)
            return $(Symbol(type_name, "_Array_new"))(collect(v))
        end

        function $(Symbol(type_name, "_Array_new"))(v::AbstractVector)
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            v_typed = convert(Vector{$(type_name)}, v)
            arr_ptr = convert(Ptr{$(type_name)}, UA_Array_new(length(v), data_type_ptr))
            GC.@preserve v_typed unsafe_copyto!(arr_ptr, pointer(v_typed), length(v))
            return UA_Array(arr_ptr, length(v))
        end

        function $(Symbol(type_name, "_Array_init"))(p::UA_Array{Ptr{$(type_name)}})
            UA_Array_init(p)
        end

        function $(Symbol(type_name, "_Array_copy"))(src::Ref{$(type_name)},
                dst::Ptr{$(type_name)},
                length::Integer)
            length < 0 && error("Length of copied array cannot be negative.")
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            return UA_Array_copy(src, length, Ref(dst), data_type_ptr)
        end

        function $(Symbol(type_name, "_Array_delete"))(p::Ptr{$(type_name)},
                length::Integer)
            length < 0 && error("Length of deleted array cannot be negative.")
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            UA_Array_delete(p, length, data_type_ptr)
        end

        function $(Symbol(type_name, "_Array_delete"))(p::UA_Array{Ptr{$(type_name)}})
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            UA_Array_delete(p, p.length, data_type_ptr)
        end
    end
end

Base.convert(::Type{UA_String}, x::Ptr{UA_String}) = unsafe_load(x)
Base.convert(::Type{UA_QualifiedName}, x::Ptr{UA_QualifiedName}) = unsafe_load(x)
Base.convert(::Type{UA_NodeId}, x::Ptr{UA_NodeId}) = unsafe_load(x)
Base.convert(::Type{UA_Guid}, x::Ptr{UA_Guid}) = unsafe_load(x)

## StatusCode
function UA_StatusCode_name_print(sc::Integer)
    return unsafe_string(UA_StatusCode_name(UA_StatusCode(sc)))
end

function UA_StatusCode_isBad(sc)
    return (sc >> 30) >= 0x02
end

function UA_StatusCode_isUncertain(sc)
    return (sc >> 30) == 0x01
end

function UA_StatusCode_isGood(sc)
    return (sc >> 30) == 0x00
end

## String
function UA_STRING_ALLOC(s::AbstractString)
    dst = UA_String_new()
    GC.@preserve s begin
        if isempty(s) 
            src = UA_String(0, C_NULL)
        else
            src = UA_String(length(s), pointer(s))
        end
        UA_String_copy(src, dst)    
    end    
    return dst
end

function UA_STRING(s::AbstractString)
    return UA_STRING_ALLOC(s) 
end

#TODO: think whether this can be cleaned up further
Base.unsafe_string(s::UA_String) = unsafe_string(s.data, s.length)
Base.unsafe_string(s::Ref{UA_String}) = unsafe_string(s[])
Base.unsafe_string(s::Ptr{UA_String}) = unsafe_string(unsafe_load(s))

## UA_BYTESTRING
function UA_BYTESTRING_ALLOC(s::AbstractString)
    return UA_STRING_ALLOC(s)
end

function UA_BYTESTRING(s::AbstractString)
    return UA_BYTESTRING_ALLOC(s)
end

function UA_ByteString_equal(s1, s2)
    return UA_String_equal(s1, s2)
end

## DateTime
function UA_DateTime_toUnixTime(date::UA_DateTime)
    return (date - UA_DATETIME_UNIX_EPOCH) / UA_DATETIME_SEC
end

function UA_DateTime_fromUnixTime(unixDate::Integer)
    return UA_DateTime(unixDate * UA_DATETIME_SEC) + UA_DATETIME_UNIX_EPOCH
end

datetime2ua_datetime(dt::DateTime) = UA_DateTime_fromUnixTime(round(Int, datetime2unix(dt)))
ua_datetime2datetime(dt::UA_DateTime) = unix2datetime(UA_DateTime_toUnixTime(dt))

## Guid
function UA_GUID(s::AbstractString)
    ua_s = UA_STRING(s)
    guid = UA_GUID(ua_s)
    UA_String_delete(ua_s)
    return guid
end

function UA_GUID(s::Ptr{UA_String})
    guid = UA_Guid_new()
    retval = UA_Guid_parse(guid, s)
    retval != UA_STATUSCODE_GOOD &&
        error("Parsing of Guid \"$(s)\" failed with statuscode \"$(UA_StatusCode_name_print(retval))\".")
    return guid
end

## NodeId
function UA_NODEID(s::AbstractString)
    ua_s = UA_STRING(s)
    id = UA_NODEID(ua_s)
    UA_String_delete(ua_s)
    return id
end
function UA_NODEID(s::Ptr{UA_String})
    id = UA_NodeId_new()
    retval = UA_NodeId_parse(id, s)
    retval != UA_STATUSCODE_GOOD &&
        error("Parsing of NodeId \"$(s)\" failed with statuscode \"$(UA_StatusCode_name_print(retval))\".")
    return id
end

function UA_NODEID_NUMERIC(nsIndex::Integer, identifier::Integer)
    nodeid = UA_NodeId_new()
    nodeid.namespaceIndex = nsIndex
    nodeid.identifierType = UA_NODEIDTYPE_NUMERIC
    nodeid.identifier.numeric = identifier
    return nodeid
end

function UA_NODEID_STRING_ALLOC(nsIndex::Integer, identifier::Ptr{UA_String})
    nodeid = UA_NodeId_new()
    nodeid.namespaceIndex = nsIndex
    nodeid.identifierType = UA_NODEIDTYPE_STRING
    UA_String_copy(identifier, nodeid.identifier.string)
    return nodeid
end

function UA_NODEID_STRING_ALLOC(nsIndex::Integer, identifier::AbstractString)
    ua_s = UA_STRING(identifier)
    nodeid = UA_NODEID_STRING_ALLOC(nsIndex, ua_s)
    UA_String_delete(ua_s)
    return nodeid
end

function UA_NODEID_STRING(nsIndex::Integer, identifier::Union{AbstractString,Ptr{UA_String}})
    return UA_NODEID_STRING_ALLOC(nsIndex, identifier)    
end

function UA_NODEID_BYTESTRING_ALLOC(nsIndex::Integer, identifier::Ptr{UA_String})
    nodeid = UA_NodeId_new()
    nodeid.namespaceIndex = nsIndex
    nodeid.identifierType = UA_NODEIDTYPE_BYTESTRING
    UA_String_copy(identifier, nodeid.identifier.byteString)
    return nodeid
end

function UA_NODEID_BYTESTRING_ALLOC(nsIndex::Integer, identifier::AbstractString)
    ua_s = UA_STRING(identifier)
    nodeid = UA_NODEID_BYTESTRING_ALLOC(nsIndex, ua_s)
    UA_String_delete(ua_s)
    return nodeid
end

function UA_NODEID_BYTESTRING(nsIndex::Integer, identifier::Union{AbstractString,Ptr{UA_String}})
    return UA_NODEID_BYTESTRING_ALLOC(nsIndex, identifier)
end

function UA_NODEID_GUID(nsIndex, guid::Ptr{UA_Guid})
    nodeid = UA_NodeId_new()
    nodeid.namespaceIndex = nsIndex
    nodeid.identifierType = UA_NODEIDTYPE_GUID
    nodeid.identifier.guid = guid
    return nodeid    
end

function UA_NODEID_GUID(nsIndex, guid::AbstractString)
    guid = UA_GUID(guid)
    nodeid = UA_NODEID_GUID(nsIndex, guid)
    UA_Guid_delete(guid)
    return nodeid
end

function UA_NodeId_equal(n1, n2)
    UA_NodeId_order(n1, n2) == UA_ORDER_EQ
end

## ExpandedNodeId
function UA_EXPANDEDNODEID(s::AbstractString)
    ua_s = UA_STRING(s)
    nodeid = UA_EXPANDEDNODEID(ua_s)
    UA_String_delete(ua_s)
    return nodeid
end

function UA_EXPANDEDNODEID(s::Ptr{UA_String})
    id = UA_ExpandedNodeId_new()
    retval = UA_ExpandedNodeId_parse(id, s)    
    retval != UA_STATUSCODE_GOOD &&
        error("Parsing of ExpandedNodeId \"$(s)\" failed with statuscode \"$(UA_StatusCode_name_print(retval))\".")
    return id
end

function UA_EXPANDEDNODEID_NUMERIC(nsIndex::Integer, identifier::Integer)
    id = UA_ExpandedNodeId_new() 
    nodeid = UA_NODEID_NUMERIC(nsIndex, identifier)
    id.nodeId = nodeid
    UA_NodeId_delete(nodeid)
    return id
end

function UA_EXPANDEDNODEID_STRING_ALLOC(nsIndex::Integer, identifier::Union{AbstractString, Ptr{UA_String}})
    id = UA_ExpandedNodeId_new()
    nodeid_src = UA_NODEID_STRING_ALLOC(nsIndex, identifier)
    nodeid_dst = id.nodeId
    UA_NodeId_copy(nodeid_src, nodeid_dst)
    UA_NodeId_delete(nodeid_src)
    return id
end

function UA_EXPANDEDNODEID_STRING(nsIndex::Integer, identifier::Union{AbstractString, Ptr{UA_String}})
    return UA_EXPANDEDNODEID_STRING_ALLOC(nsIndex, identifier) 
end

function UA_EXPANDEDNODEID_BYTESTRING_ALLOC(nsIndex::Integer, identifier::Union{AbstractString, Ptr{UA_String}})
    id = UA_ExpandedNodeId_new() 
    nodeid_src = UA_NODEID_BYTESTRING_ALLOC(nsIndex, identifier)
    nodeid_dst = id.nodeId
    UA_NodeId_copy(nodeid_src, nodeid_dst)
    UA_NodeId_delete(nodeid_src)
    return id
end

function UA_EXPANDEDNODEID_BYTESTRING(nsIndex::Integer, identifier::Union{AbstractString, Ptr{UA_String}})
    return UA_EXPANDEDNODEID_BYTESTRING_ALLOC(nsIndex, identifier)
end

function UA_EXPANDEDNODEID_NODEID(nodeId::Ptr{UA_NodeId})
    id = UA_ExpandedNodeId_new()
    nodeid_dst = id.nodeId
    UA_NodeId_copy(nodeId, nodeid_dst)
    return id
end

function UA_EXPANDEDNODEID_STRING_GUID(nsIndex::Integer, guid::Union{Ptr{UA_Guid},AbstractString})
    id = UA_ExpandedNodeId_new() 
    nodeid_src = UA_NODEID_GUID(nsIndex, guid)
    nodeid_dst = id.nodeId
    UA_NodeId_copy(nodeid_src, nodeid_dst)
    UA_NodeId_delete(nodeid_src)
    return id
end

#NOTE: not part of official open62541 interface, but convenient to define
function UA_EXPANDEDNODEID_NUMERIC(identifier::Integer, ns_uri::AbstractString, server_ind::Integer)
    id = UA_EXPANDEDNODEID_NUMERIC(0, identifier)
    ua_ns_uri = UA_STRING_ALLOC(ns_uri)
    id.serverIndex = server_ind
    uri_dst = id.namespaceUri
    UA_String_copy(ua_ns_uri, uri_dst)
    UA_String_delete(ua_ns_uri)
    return id
end

#NOTE: not part of official open62541 interface, but convenient to define
function UA_EXPANDEDNODEID_STRING_ALLOC(identifier::Union{Ptr{UA_String},AbstractString}, ns_uri::AbstractString, server_ind::Integer)
    id = UA_EXPANDEDNODEID_STRING_ALLOC(0, identifier)
    ua_ns_uri = UA_STRING_ALLOC(ns_uri)
    id.serverIndex = server_ind
    uri_dst = id.namespaceUri
    UA_String_copy(ua_ns_uri, uri_dst)
    UA_String_delete(ua_ns_uri)
    return id
end

#NOTE: not part of official open62541 interface, but convenient to define
function UA_EXPANDEDNODEID_STRING_GUID(guid::Union{Ptr{UA_Guid},AbstractString}, ns_uri::AbstractString, server_ind::Integer)
    id = UA_EXPANDEDNODEID_STRING_GUID(0, guid)
    ua_ns_uri = UA_STRING_ALLOC(ns_uri)
    id.serverIndex = server_ind
    uri_dst = id.namespaceUri
    UA_String_copy(ua_ns_uri, uri_dst)
    UA_String_delete(ua_ns_uri)
    return id
end

#NOTE: not part of official open62541 interface, but convenient to define
function UA_EXPANDEDNODEID_BYTESTRING_ALLOC(identifier::Union{Ptr{UA_String},AbstractString}, ns_uri::AbstractString, server_ind::Integer)
    id = UA_EXPANDEDNODEID_BYTESTRING_ALLOC(0, identifier)
    ua_ns_uri = UA_STRING_ALLOC(ns_uri)
    id.serverIndex = server_ind
    uri_dst = id.namespaceUri
    UA_String_copy(ua_ns_uri, uri_dst)
    UA_String_delete(ua_ns_uri)
    return id
end

#NOTE: not part of official open62541 interface, but convenient to define
function UA_EXPANDEDNODEID_NODEID(nodeid::Ptr{UA_NodeId}, ns_uri::AbstractString, server_ind::Integer)
    id = UA_EXPANDEDNODEID_NODEID(nodeid)
    ua_ns_uri = UA_STRING_ALLOC(ns_uri)
    id.serverIndex = server_ind
    uri_dst = id.namespaceUri
    UA_String_copy(ua_ns_uri, uri_dst)
    UA_String_delete(ua_ns_uri)
    return id
end

function UA_ExpandedNodeId_equal(n1, n2)
    return UA_ExpandedNodeId_order(n1, n2) == UA_ORDER_EQ
end

## QualifiedName

function UA_QUALIFIEDNAME_ALLOC(nsIndex::Integer, s::AbstractString)
    ua_s = UA_STRING(s)
    qn = UA_QUALIFIEDNAME_ALLOC(nsIndex, ua_s)
    UA_String_delete(ua_s)
    return qn
end

function UA_QUALIFIEDNAME_ALLOC(nsIndex::Integer, s::Ptr{UA_String})
    qn = UA_QualifiedName_new()
    qn.namespaceIndex = nsIndex
    UA_String_copy(s, qn.name)
    return qn
end

function UA_QUALIFIEDNAME(nsIndex::Integer, s::Union{AbstractString,Ptr{UA_String}})
    UA_QUALIFIEDNAME_ALLOC(nsIndex, s)
end

UA_QualifiedName_isNull(q::Ptr{UA_QualifiedName}) = (unsafe_load(q.namespaceIndex) == 0 && unsafe_load(q.name.length) == 0)

## LocalizedText
function UA_LOCALIZEDTEXT_ALLOC(locale::AbstractString, text::AbstractString)
    text_uas = UA_STRING(text)
    lt = UA_LOCALIZEDTEXT_ALLOC(locale, text_uas)
    UA_String_delete(text_uas)
    return lt
end

function UA_LOCALIZEDTEXT_ALLOC(locale::Ptr{UA_String}, text::AbstractString)
    text_uas = UA_STRING(text)
    lt = UA_LOCALIZEDTEXT_ALLOC(locale, text_uas)
    UA_String_delete(text_uas)
    return lt
end

function UA_LOCALIZEDTEXT_ALLOC(locale::AbstractString, text::Ptr{UA_String})
    locale_uas = UA_STRING(locale)
    lt = UA_LOCALIZEDTEXT_ALLOC(locale_uas, text)
    UA_String_delete(locale_uas)
    return lt
end

function UA_LOCALIZEDTEXT_ALLOC(locale::Ptr{UA_String}, text::Ptr{UA_String})
    lt = UA_LocalizedText_new()
    UA_String_copy(locale, lt.locale)
    UA_String_copy(text, lt.text)
    return lt
end

function UA_LOCALIZEDTEXT(locale::Union{AbstractString, Ptr{UA_String}}, text::Union{AbstractString, Ptr{UA_String}}) 
    return UA_LOCALIZEDTEXT_ALLOC(locale, text)
end

function UA_LocalizedText_equal(lt1, lt2)
    return UA_String_equal(lt1.locale, lt2.locale) && UA_String_equal(lt1.text, lt2.text)
end

## NumericRange
function UA_NUMERICRANGE(s::AbstractArray)
    nr = Ref{UA_NumericRange}()
    retval = GC.@preserve s UA_NumericRange_parse(nr, UA_STRING(s))
    retval != UA_STATUSCODE_GOOD &&
        error("Parsing of NumericRange \"$(s)\" failed with statuscode \"$(UA_StatusCode_name_print(retval))\".")
    return nr[]
end

## Variant
function unsafe_size(v::UA_Variant)
    UA_Variant_isScalar(v) && return ()
    v.arrayDimensionsSize == 0 && return (Int(v.arrayLength),)
    return Tuple([Int(unsafe_load(v.arrayDimensions, d + 1))
                  for d in 0:(v.arrayDimensionsSize - 1)])
end

unsafe_size(p::Ref{UA_Variant}) = unsafe_size(unsafe_load(p))
Base.length(v::UA_Variant) = Int(v.arrayLength)
Base.length(p::Ref{UA_Variant}) = length(unsafe_load(p))

function UA_Variant_new_copy(value::AbstractArray{T, N},
        type_ptr::Ptr{UA_DataType} = ua_data_type_ptr_default(T)) where {T, N}
    var = UA_Variant_new()
    var.type = type_ptr
    var.storageType = UA_VARIANT_DATA
    var.arrayLength = length(value)
    var.arrayDimensionsSize = length(size(value))
    var.data = UA_Array_new(vec(permutedims(value, reverse(1:N))), type_ptr)
    var.arrayDimensions = UA_UInt32_Array_new(reverse(size(value)))
    return var
end

function UA_Variant_new_copy(value::Ref{T},
        type_ptr::Ptr{UA_DataType} = ua_data_type_ptr_default(T)) where {T <: Union{AbstractFloat, Integer}}
    var = UA_Variant_new()
    var.type = type_ptr
    var.storageType = UA_VARIANT_DATA
    var.arrayLength = 0
    var.arrayDimensionsSize = length(size(value))
    UA_Variant_setScalarCopy(var, value, type_ptr)
    var.arrayDimensions = C_NULL
    return var
end

function UA_Variant_new_copy(value::T,
        type_ptr::Ptr{UA_DataType} = ua_data_type_ptr_default(T)) where {T <: Union{AbstractFloat, Integer}}
    return UA_Variant_new_copy(Ref(value), type_ptr)
end

function UA_Variant_new_copy(value, type_sym::Symbol)
    UA_Variant_new_copy(value, ua_data_type_ptr(Val(type_sym)))
end

function Base.unsafe_wrap(v::UA_Variant)
    type = juliadatatype(v.type)
    data = reinterpret(Ptr{type}, v.data)
    UA_Variant_isScalar(v) && return GC.@preserve data unsafe_load(data)
    values = GC.@preserve data unsafe_wrap(Array, data, unsafe_size(v))
    values_row_major = reshape(values, unsafe_size(v))
    return permutedims(values_row_major, reverse(1:(Int64(v.arrayDimensionsSize)))) # To column major format; TODO: Which permutation is right? TODO: can make allocation free using PermutedDimsArray?
end

Base.unsafe_wrap(p::Ref{UA_Variant}) = unsafe_wrap(unsafe_load(p))
UA_Variant_isEmpty(v::UA_Variant) = v.type == C_NULL
UA_Variant_isEmpty(p::Ref{UA_Variant}) = UA_Variant_isEmpty(unsafe_load(p))
UA_Variant_isScalar(v::UA_Variant) = v.arrayLength == 0 && v.data > UA_EMPTY_ARRAY_SENTINEL
UA_Variant_isScalar(p::Ref{UA_Variant}) = UA_Variant_isScalar(unsafe_load(p))

function UA_Variant_hasScalarType(v::UA_Variant, type::Ref{UA_DataType})
    return UA_Variant_isScalar(v) && type == v.type
end

function UA_Variant_hasScalarType(p::Ref{UA_Variant}, type::Ref{UA_DataType})
    return UA_Variant_hasScalarType(unsafe_load(p), type)
end

function UA_Variant_hasArrayType(v::UA_Variant, type::Ref{UA_DataType})
    return !UA_Variant_isScalar(v) && type == v.type
end

function UA_Variant_hasArrayType(p::Ref{UA_Variant}, type::Ref{UA_DataType})
    return UA_Variant_hasArrayType(unsafe_load(p), type)
end

## Subscriptions
function UA_CreateSubscriptionRequest_default()
    request = UA_CreateSubscriptionRequest_new()
    UA_CreateSubscriptionRequest_init(request)
    request.requestedPublishingInterval = 500.0
    request.requestedLifetimeCount = 10000
    request.requestedMaxKeepAliveCount = 10
    request.maxNotificationsPerPublish = 0
    request.publishingEnabled = true
    request.priority = 0
    return request
end

function UA_MonitoredItemCreateRequest_default(nodeId::UA_NodeId) 
    request = UA_MonitoredItemCreateRequest_new()
    UA_MonitoredItemCreateRequest_init(request)
    request.itemToMonitor.nodeId = nodeId
    request.itemToMonitor.attributeId = UA_ATTRIBUTEID_VALUE
    request.monitoringMode = UA_MONITORINGMODE_REPORTING
    request.requestedParameters.samplingInterval = 250
    request.requestedParameters.discardOldest = true
    request.requestedParameters.queueSize = 1
    return request
end

function UA_MonitoredItemCreateRequest_default(nodeId::Ptr{UA_NodeId}) 
    UA_MonitoredItemCreateRequest_default(unsafe_load(nodeId))
end