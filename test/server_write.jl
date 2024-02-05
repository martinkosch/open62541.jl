# Purpose: This testset checks whether the UA_Server_writeXXXAttribute(...) functions 
#are usable. This is currently only implemented for nodes of "variable" type. For the attributes
#contained in such nodes we check whether the respective write function is able to write a correct
#variable type to the node (TODO: also check that the correct value is actually readable from the 
#node after writing). For functions not defined for a variable node, we check that they throw the 
#appropriate exception. 

#TODO: implement other node types, so that we can check the remaining functions.

using open62541
using Test
using Base.Threads

#configure server
server = UA_Server_new()
retval0 = UA_ServerConfig_setDefault(UA_Server_getConfig(server))
@test retval0 == UA_STATUSCODE_GOOD

#add variable node
accesslevel = UA_ACCESSLEVEL(read = true, write = true)
input = rand(Float64)
attr = UA_VariableAttributes_generate(value = input,
    displayname = "scalar variable",
    description = "this is a scalar variable",
    accesslevel = accesslevel)
varnodeid = UA_NODEID_STRING_ALLOC(1, "scalar variable")
parentnodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER)
parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES)
typedefinition = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
browsename = UA_QUALIFIEDNAME_ALLOC(1, "scalar variable")
nodecontext = C_NULL
outnewnodeid = C_NULL
retval = UA_Server_addVariableNode(server, varnodeid, parentnodeid,
    parentreferencenodeid,
    browsename, typedefinition, attr, nodecontext, outnewnodeid)
#test whether adding node to the server worked    
@test retval == UA_STATUSCODE_GOOD

#add a variabletype node
input = zeros(2)
variabletypenodeid = UA_NodeId_new()
accesslevel = UA_ACCESSLEVEL(read = true)
displayname = "2D point type"
description = "This is a 2D point type."
attr = UA_VariableAttributes_generate(value = input,
    displayname = displayname,
    description = description,
    accesslevel = accesslevel) #TODO: BUG?!?!!?!? shouldn't this be variableTYPE_attributes
retval = UA_Server_addVariableTypeNode(server, UA_NodeId_new(),
    UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE),
    UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE),
    UA_QUALIFIEDNAME(1, "2DPoint Type"), UA_NodeId_new(),
    attr, C_NULL, variabletypenodeid)
#test whether adding node to the server worked    
@test retval == UA_STATUSCODE_GOOD

nodes = (varnodeid, variabletypenodeid)
for node in nodes
    nodeclass = unsafe_load(UA_Server_readNodeClass(server, node))
    if nodeclass == UA_NODECLASS_VARIABLE
        attributeset = UA_VariableAttributes
    elseif nodeclass == UA_NODECLASS_VARIABLETYPE
        attributeset = UA_VariableTypeAttributes
    end #TODO: add more node types once implemented
    for att in open62541.attributes_UA_Server_write
        fun_write = Symbol(att[1])
        fun_read = Symbol(replace(att[1], "write" => "read"))
        attr_name = Symbol(att[2])
        if attr_name != :BrowseName #can't write browsename, see here: https://github.com/open62541/open62541/issues/3545
            if in(Symbol(lowercasefirst(att[2])), fieldnames(attributeset)) ||
               in(Symbol(lowercasefirst(att[2])), fieldnames(UA_NodeHead))
                read_value = eval(fun_read)(server, node) #read
                statuscode = eval(fun_write)(server, node, read_value) #write read value back...
                @test statuscode == UA_STATUSCODE_GOOD
            end
        end
    end
end
