const UA_TYPES = Ref{Ptr{UA_DataType}}(0) # Initilize with C_NULL and initialize correct address during __init__
const UA_TYPES_PTRS = OffsetVector{Ptr{UA_DataType}}(undef, 0:UA_TYPES_COUNT-1) # Initilize vector of UA_TYPES pointer undefined and write values during __init__
const UA_TYPES_MAP = Vector{DataType}(undef, UA_TYPES_COUNT) # Initilize vector of mapping between UA_TYPES and Julia types as undefined and write values during __init__

function juliadatatype(p::Ptr{UA_DataType})
    global UA_TYPES_PTRS
    global UA_TYPES_MAP
    ind = Int(Int((p - UA_TYPES_PTRS[0])) / sizeof(UA_DataType))
    return UA_TYPES_MAP[ind + 1]
end

function UA_init(p::Ref{T}) where T
    @ccall memset(p::Ptr{Cvoid}, 0::Cint, (sizeof(T))::Csize_t)::Ptr{Cvoid}
    return nothing
end

function UA_Array_new(v::AbstractVector{T}, type_ptr::Ptr{UA_DataType}) where T
    v_typed = convert(Vector{juliadatatype(type_ptr)}, v) # Implicit check if T can be converted to type_ptr
    arr_ptr = convert(Ptr{T}, UA_Array_new(length(v), type_ptr))
    GC.@preserve v_typed unsafe_copyto!(arr_ptr, pointer(v_typed), length(v))
    return arr_ptr
end

function UA_print(p::Ref, type_ptr::Ptr{UA_DataType} = ua_data_type_ptr_default(T))
    buf = UA_String_new()
    UA_print(p, type_ptr, buf)
    s = unsafe_string(buf)
    UA_String_clear(buf)
    UA_String_delete(buf)
    return s
end

UA_print(v::T, type_ptr = ua_data_type_ptr_default(T)) where T = UA_print(Ref(v), type_ptr)

for (i, type_name) in enumerate(type_names)
    type_ind_name = Symbol("UA_TYPES_", uppercase(String(type_name)[4:end]))
    julia_type = julia_types[i]
    val_type = Val{type_name}

    @eval begin
        ua_data_type_ptr(::$(val_type)) = UA_TYPES_PTRS[$(i-1)]
        
        if !(type_names[$(i)] in types_ambiguous_blacklist)
            ua_data_type_ptr_default(::Type{$(julia_type)}) = UA_TYPES_PTRS[$(i-1)]

            Base.show(io::IO, ::MIME"text/plain", v::$(julia_type)) = print(io, UA_print(v))
        end


        function $(Symbol(type_name, "_new"))()
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            return convert(Ptr{$(type_name)}, UA_new(data_type_ptr))
        end

        $(Symbol(type_name, "_init"))(p::Ptr{$(type_name)}) = UA_init(p)

        function $(Symbol(type_name, "_copy"))(src::Ptr{$(type_name)}, dst::Ptr{$(type_name)})
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            return UA_copy(src, dst, data_type_ptr)
        end

        function $(Symbol(type_name, "_clear"))(p::Ptr{$(type_name)})
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            UA_clear(p, data_type_ptr)
        end

        function $(Symbol(type_name, "_delete"))(p::Ptr{$(type_name)})
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            UA_delete(p, data_type_ptr)
        end

        function $(Symbol(type_name, "_Array_new"))(length::Integer)
            length <= 0 && error("Length of new array must be larger than zero.")
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            return convert(Ptr{$(type_name)}, UA_Array_new(length, data_type_ptr))
        end

        function $(Symbol(type_name, "_Array_new"))(v::AbstractVector)
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            v_typed = convert(Vector{$(type_name)}, v)
            arr_ptr = convert(Ptr{$(type_name)}, UA_Array_new(length(v), data_type_ptr))
            GC.@preserve v_typed unsafe_copyto!(arr_ptr, pointer(v_typed), length(v))
            return arr_ptr
        end
        
        function $(Symbol(type_name, "_Array_copy"))(
            src::Ptr{$(type_name)}, 
            dst::Ptr{$(type_name)}, 
            length::Integer, 
        )
            length < 0 && error("Length of copied array must be larger than zero.")
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            return UA_Array_copy(src, length, Ref(dst), data_type_ptr)
        end
        
        function $(Symbol(type_name, "_Array_delete"))(p::Ptr{$(type_name)}, length::Integer)
            length < 0 && error("Length of deleted array must be larger than zero.")
            data_type_ptr = UA_TYPES_PTRS[$(type_ind_name)]
            UA_Array_delete(p, length, data_type_ptr)
        end
    end
end


## StatusCode

UA_StatusCode_name_print(sc::Integer) = return unsafe_string(UA_StatusCode_name(UA_StatusCode(sc)))


## String

# String `s` must be kept valid using GC.@preserve as long as the return value is used
function UA_STRING_unsafe(s::AbstractString)
    GC.@preserve s begin
        isempty(s) && return UA_String(0, C_NULL)
        return UA_String(length(s), pointer(s))
    end
end

# String `s` is copied to newly allocated memory that needs to be freed
UA_STRING_ALLOC(s::AbstractString) = UA_String_fromChars(s)

Base.unsafe_string(s::UA_String) = unsafe_string(s.data, s.length)
Base.unsafe_string(s::Ref{UA_String}) = unsafe_string(s[])
Base.unsafe_string(s::Ptr{UA_String}) = unsafe_string(unsafe_load(s))

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
    guid = Ref{UA_Guid}()
    ua_s = UA_STRING_unsafe(s)
    retval = GC.@preserve s UA_Guid_parse(guid, ua_s)
    retval != UA_STATUSCODE_GOOD && error("Parsing of Guid \"$(s)\" failed with statuscode \"$(UA_StatusCode_name_print(retval))\".")
    return guid[]
end


## NodeId 

function UA_NODEID_unsafe(s::AbstractString)
    id = Ref{UA_NodeId}()
    GC.@preserve s UA_NodeId_parse(id, UA_STRING_unsafe(s))
    return id[]
end

function UA_NODEID_NUMERIC(nsIndex::Integer, identifier::Integer)
    identifier_tuple = anonymous_struct_tuple(UInt32(identifier), fieldtype(UA_NodeId, :identifier))
    return UA_NodeId(nsIndex, UA_NODEIDTYPE_NUMERIC, identifier_tuple)
end

# String `s` must be kept valid using GC.@preserve as long as the return value is used
function UA_NODEID_STRING_unsafe(nsIndex::Integer, s::AbstractString)
    GC.@preserve s identifier_tuple = anonymous_struct_tuple(UA_STRING_unsafe(s), fieldtype(UA_NodeId, :identifier))
    return UA_NodeId(nsIndex, UA_NODEIDTYPE_STRING, identifier_tuple)
end

# String `s` is copied to newly allocated memory that needs to be freed
function UA_NODEID_STRING_ALLOC(nsIndex::Integer, s::AbstractString)
    identifier_tuple = anonymous_struct_tuple(UA_String_fromChars(s), fieldtype(UA_NodeId, :identifier))
    return UA_NodeId(nsIndex, UA_NODEIDTYPE_STRING, identifier_tuple)
end

function UA_NODEID_GUID(nsIndex::Integer, guid::UA_Guid)
    identifier_tuple = anonymous_struct_tuple(guid, fieldtype(UA_NodeId, :identifier))
    return UA_NodeId(nsIndex, UA_NODEIDTYPE_GUID, identifier_tuple)
end

UA_NodeId_equal(n1::Ref{UA_NodeId}, n2::Ref{UA_NodeId}) = UA_NodeId_order(n1, n2) == UA_ORDER_EQ


## ExpandedNodeId

function UA_EXPANDEDNODEID(s::AbstractString)
    id = Ref{UA_ExpandedNodeId}()
    GC.@preserve s UA_ExpandedNodeId_parse(id, UA_STRING_unsafe(s))
    return id[]
end

function UA_EXPANDEDNODEID_NUMERIC(nsIndex::Integer, identifier::Integer)
    nodeid = UA_NODEID_NUMERIC(nsIndex, identifier)
    return UA_ExpandedNodeId(nodeid, UA_STRING_NULL, 0)
end

# String `s` must be kept valid using GC.@preserve as long as the return value is used
function UA_EXPANDEDNODEID_STRING_unsafe(nsIndex::Integer, s::AbstractString)
    GC.@preserve s nodeid = UA_NODEID_STRING_unsafe(nsIndex, s)
    return UA_ExpandedNodeId(nodeid, UA_STRING_NULL, 0)
end

# String `s` is copied to newly allocated memory that needs to be freed
function UA_EXPANDEDNODEID_STRING_ALLOC(nsIndex::Integer, s::AbstractString)
    nodeid = UA_NODEID_STRING_ALLOC(nsIndex, s)
    return UA_ExpandedNodeId(nodeid, UA_STRING_NULL, 0)
end

function UA_EXPANDEDNODEID_GUID(nsIndex::Integer, guid::UA_Guid)
    nodeid = UA_NODEID_GUID(nsIndex, guid)
    return UA_ExpandedNodeId(nodeid, UA_STRING_NULL, 0)
end

function UA_ExpandedNodeId_equal(n1::Ref{UA_ExpandedNodeId}, n2::Ref{UA_ExpandedNodeId}) 
    return UA_ExpandedNodeId_order(n1, n2) == UA_ORDER_EQ
end


## QualifiedName

UA_QualifiedName_isNull(q::UA_QualifiedName) = (q.namespaceIndex == 0 && q.name.length == 0)
UA_QualifiedName_isNull(q::Ref{UA_QualifiedName}) = UA_QualifiedName_isNull(q[])

# String `s` must be kept valid using GC.@preserve as long as the return value is used
function UA_QUALIFIEDNAME(nsIndex::Integer, s::AbstractString)
    GC.@preserve s return UA_QualifiedName(nsIndex,  UA_STRING_unsafe(s))
end

# String `s` is copied to newly allocated memory that needs to be freed
function UA_QUALIFIEDNAME_ALLOC(nsIndex::Integer, s::AbstractString)
    return UA_QualifiedName(nsIndex, UA_String_fromChars(s))
end


## LocalizedText

# Strings `locale` and `text` must be kept valid using GC.@preserve as long as the return value is used
function UA_LOCALIZEDTEXT_unsafe(locale::AbstractString, text::AbstractString)
    GC.@preserve locale text begin
        return UA_LocalizedText(UA_STRING_unsafe(locale), UA_STRING_unsafe(text))
    end
end

# Strings `locale` and `text` are copied to newly allocated memory that needs to be freed
function UA_LOCALIZEDTEXT_ALLOC(locale::AbstractString, text::AbstractString)
    return UA_LocalizedText(UA_STRING_ALLOC(locale), UA_STRING_ALLOC(text))
end

## NumericRange

function UA_NUMERICRANGE(s::AbstractArray)
    nr = Ref{UA_NumericRange}()
    retval = GC.@preserve s UA_NumericRange_parse(nr, UA_STRING_unsafe(s))
    retval != UA_STATUSCODE_GOOD && error("Parsing of NumericRange \"$(s)\" failed with statuscode \"$(UA_StatusCode_name_print(retval))\".")
    return nr[]
end

## Variant

function Base.size(v::UA_Variant)
    UA_Variant_isScalar(v) && return ()
    return Tuple([Int(unsafe_load(v.arrayDimensions, d+1)) for d = 0:v.arrayDimensionsSize])
end

Base.size(p::Ref{UA_Variant}) = size(unsafe_load(p))

Base.length(v::UA_Variant) = Int(v.arrayLength)
Base.length(p::Ref{UA_Variant}) = length(unsafe_load(p))

function UA_Variant_new_copy(value::T, type_ptr::Ptr{UA_DataType}) where T
    var = UA_Variant_new()
    var.type = type_ptr
    var.storageType = UA_VARIANT_DATA
    var.arrayLength = length(value)
    var.arrayDimensionsSize = length(size(value))
    if isempty(size(value)) # Scalar value
        var.arrayDimensions = C_NULL
        value_ptr = convert(Ptr{T}, UA_new(type_ptr))
        unsafe_store!(value_ptr, value)
    else # Array value
        value_row_major = permutedims(value, reverse(1:length(size(value))))
        var.data = UA_Array_new(value, type_ptr)
        var.arrayDimensions = UA_UInt32_Array_new([size(value_row_major)...])
    end
    return var
end

UA_Variant_new_copy(value::T) where T = UA_Variant_new_copy(value, ua_data_type_ptr_default(eltype(T)))
UA_Variant_new_copy(value, type_sym::Symbol) = UA_Variant_new_copy(value, ua_data_type_ptr(Val(type_sym)))

function Base.unsafe_wrap(v::UA_Variant)
    type = juliadatatype(v.type)
    UA_Variant_isScalar(v) && return unsafe_load(reinterpret(Ptr{type}, v.data))

    values = unsafe_wrap(Vector, reinterpret(Ptr{type}, v.data), 1)
    values_row_major = reshape(values, size(v))
    return permutedims(values_row_major, reverse(1:length(size(v)))) # To column major format
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