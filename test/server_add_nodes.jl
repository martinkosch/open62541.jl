# Simple checks whether addition of different node types was successful or not
# Closely follows https://www.open62541.org/doc/1.3/tutorial_server_variabletype.html

#TODO: need to clean up in terms of memory management.

using open62541
using Test

#configure server
server = UA_Server_new()
retval0 = UA_ServerConfig_setMinimalCustomBuffer(UA_Server_getConfig(server),
    4842, C_NULL, 0, 0)
@test retval0 == UA_STATUSCODE_GOOD

## Variable nodes with scalar and array floats - other number types are tested 
## in add_change_var_scalar.jl and add_change_var_array.jl

#Variable node: scalar
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

#UA interface
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
accesslevel = UA_ACCESSLEVEL(read = true, write = true)
attr = UA_VariableAttributes_generate(value = input,
    displayname = varnodetext,
    description = "this is an array variable",
    accesslevel = accesslevel)
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
accesslevel = UA_ACCESSLEVEL(read = true)
displayname = "2D point type"
description = "This is a 2D point type."
attr = UA_VariableTypeAttributes_generate(value = input,
    displayname = displayname,
    description = description)
retval3 = UA_Server_addVariableTypeNode(server, UA_NodeId_new(),
    UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE),
    UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE),
    UA_QUALIFIEDNAME(1, "2DPoint Type"), UA_NodeId_new(),
    attr, C_NULL, pointtypeid)

# Test whether adding the variable type node to the server worked
@test retval3 == UA_STATUSCODE_GOOD

#now add a variable node based on the variabletype node that we just defined.
input = rand(2)
pointvariableid1 = UA_NodeId_new()
accesslevel = UA_ACCESSLEVEL(read = true, write = true)
displayname = "a 2D point variable"
description = "This is a 2D point variable."
attr = UA_VariableTypeAttributes_generate(value = input,
    displayname = displayname,
    description = description)
retval4 = UA_Server_addVariableNode(server, UA_NodeId_new(),
    UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER),
    UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
    UA_QUALIFIEDNAME(1, "2DPoint Type"), pointtypeid,
    attr, C_NULL, pointvariableid1)
# Test whether adding the variable type node to the server worked
@test retval4 == UA_STATUSCODE_GOOD

#now attempt to add a node with the wrong dimensions 
input = rand(2, 3)
pointvariableid2 = UA_NodeId_new()
accesslevel = UA_ACCESSLEVEL(read = true, write = true)
displayname = "not a 2d point variable"
description = "This should fail"
attr = UA_VariableTypeAttributes_generate(value = input,
    displayname = displayname,
    description = description)
retval5 = UA_Server_addVariableNode(server, UA_NodeId_new(),
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

#variable type node - scalar
input = 42
scalartypeid = UA_NodeId_new()
accesslevel = UA_ACCESSLEVEL(read = true)
displayname = "scalar integer type"
description = "This is a scalar integer type."
attr = UA_VariableTypeAttributes_generate(value = input,
    displayname = displayname,
    description = description)
retval6 = UA_Server_addVariableTypeNode(server, UA_NodeId_new(),
    UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE),
    UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE),
    UA_QUALIFIEDNAME(1, "scalar integer type"), UA_NodeId_new(),
    attr, C_NULL, scalartypeid)

# Test whether adding the variable type node to the server worked
@test retval6 == UA_STATUSCODE_GOOD

#add object node
#follows this tutorial page: https://www.open62541.org/doc/1.3/tutorial_server_object.html
pumpid = UA_NodeId_new()
displayname = "Pump (Manual)"
description = "This is a manually added pump."
oAttr = UA_ObjectAttributes_generate(displayname = displayname, description = description)
requestednewnodeid = UA_NodeId_new()
parentnodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER)
referencetypeid = UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES)
browsename = UA_QUALIFIEDNAME(1, displayname)
typedefinition = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEOBJECTTYPE)
retval7 = UA_Server_addObjectNode(server, requestednewnodeid, parentnodeid, referencetypeid,
    browsename, typedefinition, oAttr, C_NULL, pumpid)

@test retval6 == UA_STATUSCODE_GOOD

#TODO: follow rest of tutorial, C code below
pumpTypeId = UA_NODEID_NUMERIC(1, 1001)
#Define the object type for "Device"
deviceTypeId = UA_NodeId_new()
dtAttr = UA_ObjectTypeAttributes_generate(displayname = "DeviceType",
    description = "Object type for a device")
retval7 = UA_Server_addObjectTypeNode(server, UA_NodeId_new(),
    UA_NODEID_NUMERIC(0, UA_NS0ID_BASEOBJECTTYPE),
    UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE),
    UA_QUALIFIEDNAME(1, "DeviceType"), dtAttr,
    C_NULL, deviceTypeId)
@test retval7 == UA_STATUSCODE_GOOD

#add manufacturer name to device
mnAttr = UA_VariableAttributes_generate(value = "",
    displayname = "ManufacturerName",
    description = "Name of the manufacturer")
manufacturerNameId = UA_NodeId_new()
retval8 = UA_Server_addVariableNode(server, UA_NodeId_new(), deviceTypeId,
    UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
    UA_QUALIFIEDNAME(1, "ManufacturerName"),
    UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE), mnAttr, C_NULL, manufacturerNameId);
@test retval8 == UA_STATUSCODE_GOOD

#Make the manufacturer name mandatory
retval9 = UA_Server_addReference(server, manufacturerNameId,
    UA_NODEID_NUMERIC(0, UA_NS0ID_HASMODELLINGRULE),
    UA_EXPANDEDNODEID_NUMERIC(0, UA_NS0ID_MODELLINGRULE_MANDATORY), true)
@test retval9 == UA_STATUSCODE_GOOD

#Add model name
modelAttr = UA_VariableAttributes_generate(value = "",
    displayname = "ModelName",
    description = "Name of the model")
retval10 = UA_Server_addVariableNode(server, UA_NodeId_new(), deviceTypeId,
    UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
    UA_QUALIFIEDNAME(1, "ModelName"),
    UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE), modelAttr, C_NULL, C_NULL);
@test retval10 == UA_STATUSCODE_GOOD

#Define the object type for "Pump"
ptAttr = UA_ObjectTypeAttributes_generate(displayname = "PumpType",
    description = "Object type for a pump")
retval11 = UA_Server_addObjectTypeNode(server, pumpTypeId,
    deviceTypeId, UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE),
    UA_QUALIFIEDNAME(1, "PumpType"), ptAttr,
    C_NULL, C_NULL)
@test retval11 == UA_STATUSCODE_GOOD

statusAttr = UA_VariableAttributes_generate(value = false,
    displayname = "Status",
    description = "Status")
statusId = UA_NodeId_new()
retval12 = UA_Server_addVariableNode(server, UA_NodeId_new(), pumpTypeId,
    UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
    UA_QUALIFIEDNAME(1, "Status"),
    UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE), statusAttr, C_NULL, statusId)
@test retval12 == UA_STATUSCODE_GOOD

#/* Make the status variable mandatory */
retval13 = UA_Server_addReference(server, statusId,
    UA_NODEID_NUMERIC(0, UA_NS0ID_HASMODELLINGRULE),
    UA_EXPANDEDNODEID_NUMERIC(0, UA_NS0ID_MODELLINGRULE_MANDATORY), true)
@test retval13 == UA_STATUSCODE_GOOD

rpmAttr = UA_VariableAttributes_generate(displayname = "MotorRPM",
    description = "Pump speed in rpm",
    value = 0)
retval14 = UA_Server_addVariableNode(server, UA_NodeId_new(), pumpTypeId,
    UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
    UA_QUALIFIEDNAME(1, "MotorRPMs"),
    UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE), rpmAttr, C_NULL, C_NULL)
@test retval14 == UA_STATUSCODE_GOOD

function addPumpObjectInstance(server, name)
    oAttr = UA_ObjectAttributes_generate(displayname = name, description = name)
    UA_Server_addObjectNode(server, UA_NodeId_new(),
        UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER),
        UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES),
        UA_QUALIFIEDNAME(1, name),
        pumpTypeId, #/* this refers to the object type
        #   identifier */
        oAttr, C_NULL, C_NULL)
end

function pumpTypeConstructor(server, sessionId, sessionContext,
        typeId, typeContext, nodeId, nodeContext)
    #UA_LOG_INFO(UA_Log_Stdout, UA_LOGCATEGORY_USERLAND, "New pump created");

    #/* Find the NodeId of the status child variable */
    rpe = UA_RelativePathElement_new()
    UA_RelativePathElement_init(rpe)
    rpe.referenceTypeId = UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT)
    rpe.isInverse = false
    rpe.includeSubtypes = false
    rpe.targetName = UA_QUALIFIEDNAME(1, "Status")

    bp = UA_BrowsePath_new()
    UA_BrowsePath_init(bp)
    bp.startingNode = nodeId
    bp.relativePath.elementsSize = 1
    bp.relativePath.elements = rpe

    bpr = UA_Server_translateBrowsePathToNodeIds(server, bp)
    if bpr.statusCode != UA_STATUSCODE_GOOD || bpr.targetsSize < 1
        return bpr.statusCode
    end

    #Set the status value
    status = true
    value = UA_Variant_new()
    UA_Variant_setScalarCopy(value, Ref(status), UA_TYPES_PTRS[UA_TYPES_BOOLEAN])
    UA_Server_writeValue(server, bpr.targets.targetId.nodeId, value)

    #TODO: clean up to avoid memory leaks
    return UA_STATUSCODE_GOOD
end

function addPumpTypeConstructor(server)
    c_pumpTypeConstructor = UA_NodeTypeLifecycleCallback_constructor_generate(pumpTypeConstructor)
    lifecycle = UA_NodeTypeLifecycle(c_pumpTypeConstructor, C_NULL)
    UA_Server_setNodeTypeLifecycle(server, pumpTypeId, lifecycle)
end

addPumpObjectInstance(server, "pump2") #should have status = false (constructor not in place yet)
addPumpObjectInstance(server, "pump3") #should have status = false (constructor not in place yet)
addPumpTypeConstructor(server)
addPumpObjectInstance(server, "pump4") #should have status = true
addPumpObjectInstance(server, "pump5") #should have status = true

#add method node
#follows this: https://www.open62541.org/doc/1.3/tutorial_server_method.html

function helloWorldMethodCallback(server, sessionId, sessionHandle, methodId,
        methodContext, objectId, objectContext, inputSize, input, outputSize, output)
    inputstr = unsafe_string(unsafe_wrap(input))
    tmp = UA_STRING("Hello " * inputstr)
    UA_Variant_setScalarCopy(output, tmp, UA_TYPES_PTRS[UA_TYPES_STRING])
    UA_String_delete(tmp)
    return UA_STATUSCODE_GOOD
end

inputArgument = UA_Argument_new()
inputArgument.description = UA_LOCALIZEDTEXT("en-US", "A String")
inputArgument.name = UA_STRING("MyInput");
inputArgument.dataType = UA_TYPES_PTRS[UA_TYPES_STRING].typeId;
inputArgument.valueRank = UA_VALUERANK_SCALAR
outputArgument = UA_Argument_new()
outputArgument.description = UA_LOCALIZEDTEXT("en-US", "A String");
outputArgument.name = UA_STRING("MyOutput");
outputArgument.dataType = UA_TYPES_PTRS[UA_TYPES_STRING].typeId
outputArgument.valueRank = UA_VALUERANK_SCALAR
helloAttr = UA_MethodAttributes_generate(description = "Say Hello World",
    displayname = "Hello World",
    executable = true,
    userexecutable = true)

methodid = UA_NODEID_NUMERIC(1, 62541)
obj = UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER)
retval = UA_Server_addMethodNode(server, methodid,
    obj,
    UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT),
    UA_QUALIFIEDNAME(1, "hello world"),
    helloAttr, helloWorldMethodCallback,
    1, inputArgument, 1, outputArgument, C_NULL, C_NULL)

@test retval == UA_STATUSCODE_GOOD

#UA_Server_run(server, Ref(true)) - checking server in uaexpert shows that the 
#hello world method is there and that it produces the correct results when called
inputArguments = UA_Variant_new()
ua_s = UA_STRING("Peter")
UA_Variant_setScalar(inputArguments, ua_s, UA_TYPES_PTRS[UA_TYPES_STRING])
req = UA_CallMethodRequest_new()
req.objectId = obj
req.methodId = methodid
req.inputArgumentsSize = 1
req.inputArguments = inputArguments

answer = UA_CallMethodResult_new()
UA_Server_call(server, req, answer)
@test unsafe_load(answer.statusCode) == UA_STATUSCODE_GOOD
@test unsafe_string(unsafe_wrap(unsafe_load(answer.outputArguments))) == "Hello Peter"

UA_CallMethodRequest_delete(req)
UA_CallMethodResult_delete(answer)

#TODO: this will need a test to see whether any memory is leaking.

#TODO: should be testing the higher level interface as well. template code below
#JUA interface
# retval1 = JUA_Server_addNode(server, varnodeid, parentnodeid,
#     parentreferencenodeid,
#     browsename, typedefinition, attr, nodecontext, outnewnodeid)
