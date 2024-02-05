using Clang.Generators
using open62541_jll
using JuliaFormatter
using OffsetArrays
using Pkg

#update packages by default
Pkg.update()

#change dir
cd(@__DIR__)

include_dir = joinpath(open62541_jll.artifact_dir, "include") |> normpath
open62541_header = joinpath(include_dir, "open62541.h") |> normpath
@assert isfile(open62541_header)

function write_generated_defs(generated_defs_dir::String,
        open62541_header::String,
        type_names,
        julia_types)
    julia_types = replace("$julia_types", Regex("Main\\.open62541\\.") => "")
    type_string = """
    # Vector of all UA types
    const type_names = $type_names

    # Julia types corresponding to the UA types in vector type_names
    const julia_types = $julia_types

    # Vector of types that are ambiguously defined via typedef and are not to be used as default type
    types_ambiguous_ignorelist = [:UA_Duration, :UA_ByteString, :UA_XmlElement, :UA_LocaleId, :UA_DateTime, :UA_UtcTime, :UA_StatusCode]

    """

    inlined_funcs = """
    # Vector of all inlined function names listed in the amalgamated open62541 header file
    const inlined_funcs = $(extract_inlined_funcs(open62541_header))
    """

    data_UA_Client = """
    # UA_Client_ functions data
    const attributes_UA_Client_Service = $(extract_header_data(r"UA_INLINE[\s\S]{0,50}\s(UA_Client_Service_(\w*))\((?:[\s\S]*?)\)(?:[\s\S]*?)UA_\S*", open62541_header))
    const attributes_UA_Client_read = $(extract_header_data(r"UA_INLINE[\s\S]{0,50}\s(UA_Client_read(\w*)Attribute)\((?:[\s\S]*?,\s*){2}(\S*)", open62541_header))
    const attributes_UA_Client_write = $(extract_header_data(r"UA_INLINE[\s\S]{0,50}\s(UA_Client_write(\w*)Attribute)\((?:[\s\S]*?,\s*){2}const\s(\S*)", open62541_header))
    const attributes_UA_Client_read_async = $(extract_header_data(r"UA_INLINE[\s\S]{0,50}\s(UA_Client_read(\w*)Attribute_async)\([\s\S]+?\)[\s\S]+?{[\s\S]+?__UA_Client_readAttribute_async\s*\([\s\S]+?&UA_TYPES\[([\S]+?)\]", open62541_header))
    const attributes_UA_Client_write_async = $(extract_header_data(r"UA_INLINE[\s\S]{0,50}\s(UA_Client_write(\w*)Attribute_async)\s*\(UA_Client\s*\*client,\s*const\s*UA_NodeId\s*nodeId,\s*const\s*(\S*)", open62541_header))
    """
    #Get rid of unnecessary type unions
    data_UA_Client = replace(data_UA_Client,
        "Vector{Union{Nothing, SubString{String}}}" => "Vector{String}")

    data_UA_Server = """
        # UA_Server_ functions data
        const attributes_UA_Server_read = $(extract_header_data(r"UA_INLINE[\s\S]{0,50}\s(UA_Server_read(\w*))\s*\(UA_Server\s*\*server,\s*const\s*UA_NodeId\s*nodeId,\s*(\S*)", open62541_header))
        const attributes_UA_Server_write = $(extract_header_data(r"UA_INLINE[\s\S]{0,50}(UA_Server_write(\w*))\s*\(UA_Server\s*\*server,\s*const\s*UA_NodeId\s*nodeId,\s*const (\S*)", open62541_header))
        """
    #Get rid of unnecessary type unions
    data_UA_Server = replace(data_UA_Server,
        "Vector{Union{Nothing, SubString{String}}}" => "Vector{String}")

    open(generated_defs_dir, "w") do f
        write(f, type_string)
        write(f, inlined_funcs)
        write(f, data_UA_Client)
        write(f, data_UA_Server)
    end
end

function extract_inlined_funcs(open62541_header::String)
    regex_inlined = r"UA_INLINE[\s]+(?:[\w\*]+[\s]*[\s\S]){0,3}((?:__)?UA_[\w]+)\("
    inlined_funcs = String[]
    open(open62541_header, "r") do f
        data = read(f, String)
        append!(inlined_funcs,
            vcat(getfield.(collect(eachmatch(regex_inlined, data)), :captures)...)) # Extract inlined functions from header file
    end
    return inlined_funcs
end

function extract_header_data(regex::Regex, open62541_header::String)
    f = open(open62541_header, "r")
    data = read(f, String)
    close(f)
    all_data = getfield.(collect(eachmatch(regex, data)), :captures) # Extract inlined functions from header file
    return all_data
end

# Load options from generator.toml
options = load_options(joinpath(@__DIR__, "generator.toml"))

# Extract all inlined functions and move them to codegen ignorelist; leads to out of memory
# error on low memory machines. Implemented Post-Clang.jl removal using Regexp, which is lower
# memory requirement (commented lines after build! command)
append!(options["general"]["output_ignorelist"], extract_inlined_funcs(open62541_header))

# Add compiler flags
args = get_default_args()
push!(args, "-I$include_dir")
push!(args, "-std=c99")

# Create context
ctx = create_context(open62541_header, args, options)

# # Run generator
build!(ctx)

# fn = joinpath(@__DIR__, "../src/open62541.jl")
# f = open(fn, "r")
# data = read(f, String)
# close(f)

# #remove inlined functions
# inlined_funcs = extract_inlined_funcs(open62541_header)
# for i in eachindex(inlined_funcs)
#     r = Regex("function $(inlined_funcs[i])\(.*\)\n(.*)\nend\n") #TODO: this doesn't really match the required pattern.
#     data = replace(data, r => "")
# end

# fn = joinpath(@__DIR__, "../src/open62541.jl")
# f = open(fn, "w")
# write(f, data)
# close(f)

@show "loading module"
include("../src/open62541.jl")

# Get UA type names
UA_TYPES = Ref{Ptr{open62541.UA_DataType}}(0)
UA_TYPES[] = cglobal((:UA_TYPES, libopen62541), open62541.UA_DataType)
UA_TYPES_PTRS = OffsetVector{Ptr{open62541.UA_DataType}}(undef,
    0:(open62541.UA_TYPES_COUNT - 1))
UA_TYPES_MAP = Vector{DataType}(undef, open62541.UA_TYPES_COUNT) # Initialize vector of mapping between UA_TYPES and Julia types as undefined and write values during __init__

for i in eachindex(UA_TYPES_PTRS)
    UA_TYPES_PTRS[i] = UA_TYPES[] + sizeof(open62541.UA_DataType) * i
    typename = "UA_" * unsafe_string(unsafe_load(UA_TYPES_PTRS[i]).typeName)
    UA_TYPES_MAP[i + 1] = getglobal(open62541, Symbol(typename))
end

type_names = [Symbol("UA_", unsafe_string(unsafe_load(type_ptr).typeName))
              for type_ptr in UA_TYPES_PTRS]

# Get corresponding Julia Types
function juliadatatype(p, start, UA_TYPES_MAP)
    ind = Int(Int((p - start)) / sizeof(open62541.UA_DataType))
    return UA_TYPES_MAP[ind + 1]
end
julia_types = [juliadatatype(type_ptr, UA_TYPES_PTRS[0], UA_TYPES_MAP)
               for type_ptr in UA_TYPES_PTRS]

# Write static definitions to file generated_defs.jl
write_generated_defs(joinpath(@__DIR__, "../src/generated_defs.jl"),
    open62541_header,
    type_names,
    julia_types)

# Now let's get the epilogue into the open62541.jl filter
# 1. Read original file content
fn = joinpath(@__DIR__, "../src/open62541.jl")
f = open(fn, "r")
orig_content = read(f, String)
orig_content = replace(orig_content, "end # module" => "")
close(f)

# 2. Read epilogue file content
fn = joinpath(@__DIR__, "./epilogue.jl")
f = open(fn, "r")
epilogue_content = read(f, String)
close(f)

# 3. Write overall content to the file
fn = joinpath(@__DIR__, "../src/open62541.jl")
f = open(fn, "w")
write(f, orig_content * "\n" * epilogue_content * "\nend # module")
close(f)

#remove double new lines on each "const xxx = ..." line
fn = joinpath(@__DIR__, "../src/open62541.jl")
f = open(fn, "r")
orig_content = read(f, String)
close(f)
new_content = replace(orig_content, "\n\nconst" => "\nconst")
f = open(fn, "w")
write(f, new_content)

#set compat bound in Projet.toml automatically to version that the generator ran on.
fn = joinpath(@__DIR__, "Project.toml")
vn2string(vn::VersionNumber) = "$(vn.major).$(vn.minor).$(vn.patch)"
f = open(fn, "r")
orig_content = read(f, String)
close(f)
reg = r"open62541_jll = \"=[0-9]+\.[0-9]+\.[0-9]+\""
open62541_version = vn2string(pkgversion(open62541_jll))
new_content = replace(orig_content, reg => "open62541_jll = \"=$open62541_version\"")
f = open(fn, "w")
write(f, new_content)
close(f)

# automated formatting
format(joinpath(@__DIR__, ".."))
