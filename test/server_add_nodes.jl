# Simple checks whether addition of different node types was successful or not
# Closely follows https://www.open62541.org/doc/1.3/tutorial_server_variabletype.html

using open62541
using Test

#configure server
server = UA_Server_new()
retval0 = UA_ServerConfig_setDefault(UA_Server_getConfig(server))
@test retval0 == UA_STATUSCODE_GOOD

## Variable nodes with scalar and array floats - other number types are tested 
## in add_change_var_scalar.jl and add_change_var_array.jl
#Variable node: scalar
accesslevel = UA_ACCESSLEVELMASK_READ | UA_ACCESSLEVELMASK_WRITE
input = rand(Float64)
attr = UA_generate_variable_attributes(input,
    "scalar variable",
    "this is a scalar variable",
    accesslevel)
varnodeid = UA_NODEID_STRING_ALLOC(1, "scalar variable")
parentnodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER)
parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES)
typedefinition = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
browsename = UA_QUALIFIEDNAME_ALLOC(1, "scalar variable")
nodecontext = C_NULL
outnewnodeid = C_NULL
retval1 = UA_Server_addVariableNode(server, varnodeid, parentnodeid,
    parentreferencenodeid,
    browsename, typedefinition, attr, nodecontext, outnewnodeid)
#test whether adding node to the server worked    
@test retval1 == UA_STATUSCODE_GOOD
# Test whether the correct array is within the server (read from server)
output_server = unsafe_wrap(UA_Server_readValue(server, varnodeid))
@test all(isapprox(input, output_server))

#Variable node: array
input = rand(Float64, 2, 3, 4)
varnodetext = "array variable"
accesslevel = UA_ACCESSLEVELMASK_READ | UA_ACCESSLEVELMASK_WRITE
attr = UA_generate_variable_attributes(input,
    varnodetext,
    "this is an array variable",
    accesslevel)
varnodeid = UA_NODEID_STRING_ALLOC(1, varnodetext)
parentnodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER)
parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES)
typedefinition = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
browsename = UA_QUALIFIEDNAME_ALLOC(1, varnodetext)
nodecontext = C_NULL
outnewnodeid = C_NULL
retval2 = UA_Server_addVariableNode(server, varnodeid, parentnodeid,
    parentreferencenodeid,
    browsename, typedefinition, attr, nodecontext, outnewnodeid)
# Test whether adding node to the server worked
@test retval2 == UA_STATUSCODE_GOOD

## VariableTypeNode - array
input = zeros(2)
pointtypeid = UA_NodeId_new()
accesslevel = UA_ACCESSLEVELMASK_READ
displayname = "2D point type"
description = "This is a 2D point type."
attr = UA_generate_variabletype_attributes(input,
    displayname,
    description)
retval3 = UA_Server_addVariableTypeNode(server, UA_NODEID_NULL,
    UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE),
    UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE),
    UA_QUALIFIEDNAME(1, "2DPoint Type"), UA_NODEID_NULL,
    attr, C_NULL, pointtypeid)

# Test whether adding the variable type node to the server worked
@test retval3 == UA_STATUSCODE_GOOD

#now add a variable node based on the variabletype node that we just defined.
input = rand(2)
pointvariableid1 = UA_NodeId_new()
accesslevel = UA_ACCESSLEVELMASK_READ | UA_ACCESSLEVELMASK_WRITE
displayname = "a 2D point variable"
description = "This is a 2D point variable."
attr = UA_generate_variabletype_attributes(input,
    displayname,
    description)
retval4 = UA_Server_addVariableNode(server, UA_NODEID_NULL,
    UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER),
    UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
    UA_QUALIFIEDNAME(1, "2DPoint Type"), pointtypeid,
    attr, C_NULL, pointvariableid1)
# Test whether adding the variable type node to the server worked
@test retval4 == UA_STATUSCODE_GOOD

#now attempt to add a node with the wrong dimensions 
input = rand(2, 3)
pointvariableid2 = UA_NodeId_new()
accesslevel = UA_ACCESSLEVELMASK_READ | UA_ACCESSLEVELMASK_WRITE
displayname = "not a 2d point variable"
description = "This should fail"
attr = UA_generate_variabletype_attributes(input,
    displayname,
    description)
retval5 = UA_Server_addVariableNode(server, UA_NODEID_NULL,
    UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER),
    UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
    UA_QUALIFIEDNAME(1, "2DPoint Type"), pointtypeid,
    attr, C_NULL, pointvariableid2)
# Test whether adding the variable type node to the server worked
@test retval5 == UA_STATUSCODE_BADTYPEMISMATCH

#and now we just want to change value rank (which again shouldn't be allowed)
@test_throws open62541.AttributeReadWriteError UA_Server_writeValueRank(server,
    pointvariableid1,
    UA_VALUERANK_ONE_OR_MORE_DIMENSIONS)

#variable type node - scalar (to increase test coverage)
input = 42
scalartypeid = UA_NodeId_new()
accesslevel = UA_ACCESSLEVELMASK_READ
displayname = "scalar integer type"
description = "This is a scalar integer type."
attr = UA_generate_variabletype_attributes(input,
    displayname,
    description)
retval6 = UA_Server_addVariableTypeNode(server, UA_NODEID_NULL,
    UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE),
    UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE),
    UA_QUALIFIEDNAME(1, "scalar integer type"), UA_NODEID_NULL,
    attr, C_NULL, scalartypeid)

# Test whether adding the variable type node to the server worked
@test retval6 == UA_STATUSCODE_GOOD
