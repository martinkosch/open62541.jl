# Simple checks whether addition of different node types was successful or not
# Closely follows https://www.open62541.org/doc/1.3/tutorial_server_variabletype.html

using Open62541
using Test
using Pkg.BinaryPlatforms

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
out = UA_Variant_new()
UA_Server_readValue(server, varnodeid, out)
output_server = unsafe_wrap(out)
@test all(isapprox(input, output_server))

#clean up memory for this part of the code
UA_VariableAttributes_delete(attr)
UA_NodeId_delete(varnodeid)
UA_NodeId_delete(parentnodeid)
UA_NodeId_delete(parentreferencenodeid)
UA_NodeId_delete(typedefinition)
UA_QualifiedName_delete(browsename)
UA_Variant_delete(out)

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
# Test whether the correct array is within the server (read from server)
out = UA_Variant_new()
UA_Server_readValue(server, varnodeid, out)
output_server = unsafe_wrap(out)
@test all(isapprox(input, output_server))

#clean up memory for this part of the code
#note: this seems repetitive, but if not cleaning
#      up each time, the memory is never freed
#      properly (until Julia shutdown)
UA_VariableAttributes_delete(attr)
UA_NodeId_delete(varnodeid)
UA_NodeId_delete(parentnodeid)
UA_NodeId_delete(parentreferencenodeid)
UA_NodeId_delete(typedefinition)
UA_QualifiedName_delete(browsename)
UA_Variant_delete(out)

## VariableTypeNode - array
input = zeros(2)
pointtypeid = UA_NodeId_new()
accesslevel = UA_ACCESSLEVEL(read = true)
displayname = "2D point type"
description = "This is a 2D point type."
attr = UA_VariableTypeAttributes_generate(value = input,
    displayname = displayname,
    description = description)
requestednewnodeid = UA_NodeId_new()
parentnodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE)
browsename = UA_QUALIFIEDNAME(1, "2DPoint Type")
typedefinition = UA_NodeId_new()
retval3 = UA_Server_addVariableTypeNode(server, requestednewnodeid,
    parentnodeid, parentreferencenodeid, browsename, typedefinition,
    attr, C_NULL, pointtypeid)

# Test whether adding the variable type node to the server worked
@test retval3 == UA_STATUSCODE_GOOD

#clean up memory for this part of the code
UA_VariableTypeAttributes_delete(attr)
UA_NodeId_delete(requestednewnodeid)
UA_NodeId_delete(parentnodeid)
UA_NodeId_delete(parentreferencenodeid)
UA_NodeId_delete(typedefinition)
UA_QualifiedName_delete(browsename)

#now add a variable node based on the variabletype node that we just defined.
input = rand(2)
pointvariableid1 = UA_NodeId_new()
accesslevel = UA_ACCESSLEVEL(read = true, write = true)
displayname = "a 2D point variable"
description = "This is a 2D point variable."
attr = UA_VariableAttributes_generate(value = input,
    displayname = displayname,
    description = description)
requestednewnodeid = UA_NodeId_new()
parentnodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER)
parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT)
browsename = UA_QUALIFIEDNAME(1, "2DPoint Type")
retval4 = UA_Server_addVariableNode(server, requestednewnodeid,
    parentnodeid, parentreferencenodeid, browsename, pointtypeid,
    attr, C_NULL, pointvariableid1)
# Test whether adding the variable node to the server worked
@test retval4 == UA_STATUSCODE_GOOD

#clean up memory for this part of the code
UA_VariableAttributes_delete(attr)
UA_NodeId_delete(requestednewnodeid)
UA_NodeId_delete(parentnodeid)
UA_NodeId_delete(parentreferencenodeid)
UA_QualifiedName_delete(browsename)

#now attempt to add a node with the wrong dimensions 
input = rand(2, 3)
pointvariableid2 = UA_NodeId_new()
accesslevel = UA_ACCESSLEVEL(read = true, write = true)
displayname = "not a 2d point variable"
description = "This should fail"
attr = UA_VariableAttributes_generate(value = input,
    displayname = displayname,
    description = description)
requestednewnodeid = UA_NodeId_new()
parentnodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER)
parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT)
browsename = UA_QUALIFIEDNAME(1, "2DPoint Type")
retval5 = UA_Server_addVariableNode(server, requestednewnodeid,
    parentnodeid, parentreferencenodeid, browsename, pointtypeid,
    attr, C_NULL, pointvariableid2)
# Test whether adding the variable type node to the server worked
@test retval5 == UA_STATUSCODE_BADTYPEMISMATCH

#and now we just want to change value rank (which again shouldn't be allowed)
@test_throws Open62541.AttributeReadWriteError UA_Server_writeValueRank(server,
    pointvariableid1,
    UA_VALUERANK_ONE_OR_MORE_DIMENSIONS)

#clean up this part of the code
UA_VariableAttributes_delete(attr)
UA_NodeId_delete(pointvariableid1)
UA_NodeId_delete(pointvariableid2)
UA_NodeId_delete(pointtypeid)
UA_NodeId_delete(requestednewnodeid)
UA_NodeId_delete(parentnodeid)
UA_NodeId_delete(parentreferencenodeid)
UA_QualifiedName_delete(browsename)

#variable type node - scalar
input = 42
scalartypeid = UA_NodeId_new()
accesslevel = UA_ACCESSLEVEL(read = true)
displayname = "scalar integer type"
description = "This is a scalar integer type."
attr = UA_VariableTypeAttributes_generate(value = input,
    displayname = displayname,
    description = description)
requestednewnodeid = UA_NodeId_new()
parentnodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE)
typedefinition = UA_NodeId_new()
browsename = UA_QUALIFIEDNAME(1, "scalar integer type")
retval6 = UA_Server_addVariableTypeNode(server, requestednewnodeid,
    parentnodeid, parentreferencenodeid, browsename, typedefinition,
    attr, C_NULL, scalartypeid)

# Test whether adding the variable type node to the server worked
@test retval6 == UA_STATUSCODE_GOOD

#clean up this part of the code
UA_VariableTypeAttributes_delete(attr)
UA_NodeId_delete(requestednewnodeid)
UA_NodeId_delete(parentnodeid)
UA_NodeId_delete(typedefinition)
UA_NodeId_delete(parentreferencenodeid)
UA_QualifiedName_delete(browsename)
UA_NodeId_delete(scalartypeid)

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
retval7 = UA_Server_addObjectNode(
    server, requestednewnodeid, parentnodeid, referencetypeid,
    browsename, typedefinition, oAttr, C_NULL, pumpid)

@test retval7 == UA_STATUSCODE_GOOD

# clean up this part of the code
UA_ObjectAttributes_delete(oAttr)
UA_NodeId_delete(requestednewnodeid)
UA_NodeId_delete(parentnodeid)
UA_NodeId_delete(referencetypeid)
UA_NodeId_delete(typedefinition)
UA_QualifiedName_delete(browsename)
UA_NodeId_delete(pumpid)

#Define the object type for "Device"
deviceTypeId = UA_NodeId_new()
dtAttr = UA_ObjectTypeAttributes_generate(displayname = "DeviceType",
    description = "Object type for a device")
requestednewnodeid = UA_NodeId_new()
parentnodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEOBJECTTYPE)
parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE)
browsename = UA_QUALIFIEDNAME(1, "DeviceType")
retval8 = UA_Server_addObjectTypeNode(server, requestednewnodeid,
    parentnodeid, parentreferencenodeid, browsename, dtAttr,
    C_NULL, deviceTypeId)
@test retval8 == UA_STATUSCODE_GOOD
UA_ObjectTypeAttributes_delete(dtAttr)
UA_NodeId_delete(requestednewnodeid)
UA_NodeId_delete(parentnodeid)
UA_NodeId_delete(parentreferencenodeid)
UA_QualifiedName_delete(browsename)

#add manufacturer name to device
mnAttr = UA_VariableAttributes_generate(value = "",
    displayname = "ManufacturerName",
    description = "Name of the manufacturer")
manufacturerNameId = UA_NodeId_new()
requestednewnodeid = UA_NodeId_new()
parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT)
browsename = UA_QUALIFIEDNAME(1, "ManufacturerName")
typedefinition = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
retval9 = UA_Server_addVariableNode(server, requestednewnodeid, 
    deviceTypeId, parentreferencenodeid, browsename, typedefinition, 
    mnAttr, C_NULL, manufacturerNameId)
@test retval9 == UA_STATUSCODE_GOOD

#clean up 
UA_NodeId_delete(requestednewnodeid)
UA_NodeId_delete(parentreferencenodeid)
UA_NodeId_delete(typedefinition)
UA_QualifiedName_delete(browsename)
UA_VariableAttributes_delete(mnAttr)

#Make the manufacturer name mandatory
reftypeid = UA_NODEID_NUMERIC(0, UA_NS0ID_HASMODELLINGRULE)
targetid = UA_EXPANDEDNODEID_NUMERIC(0, UA_NS0ID_MODELLINGRULE_MANDATORY) #TODO: find the proper names for these arguments.
isforward = true
retval10 = UA_Server_addReference(server, manufacturerNameId,
    reftypeid, targetid, isforward)
@test retval10 == UA_STATUSCODE_GOOD

#clean up
UA_NodeId_delete(manufacturerNameId)
UA_NodeId_delete(reftypeid)
UA_ExpandedNodeId_delete(targetid)

#Add model name
modelAttr = UA_VariableAttributes_generate(value = "",
    displayname = "ModelName",
    description = "Name of the model")
requestednewnodeid = UA_NodeId_new()
parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT)
browsename = UA_QUALIFIEDNAME(1, "ModelName")
typedefinition = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
retval11 = UA_Server_addVariableNode(server, requestednewnodeid, 
    deviceTypeId, parentreferencenodeid, browsename,
    typedefinition, modelAttr, C_NULL, C_NULL)
@test retval11 == UA_STATUSCODE_GOOD

#clean up 
UA_NodeId_delete(requestednewnodeid)
UA_NodeId_delete(parentreferencenodeid)
UA_NodeId_delete(typedefinition)
UA_QualifiedName_delete(browsename)
UA_VariableAttributes_delete(modelAttr)

#Define the object type for "Pump"
pumpTypeId = UA_NODEID_NUMERIC(1, 1001)
ptAttr = UA_ObjectTypeAttributes_generate(displayname = "PumpType",
    description = "Object type for a pump")
parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_HASSUBTYPE)
browsename = UA_QUALIFIEDNAME(1, "PumpType")
retval12 = UA_Server_addObjectTypeNode(server, pumpTypeId,
    deviceTypeId, parentreferencenodeid,
    browsename, ptAttr,
    C_NULL, C_NULL)
@test retval12 == UA_STATUSCODE_GOOD

#clean up
UA_NodeId_delete(deviceTypeId)
UA_ObjectTypeAttributes_delete(ptAttr)
UA_NodeId_delete(parentreferencenodeid)
UA_QualifiedName_delete(browsename)

#add status variable to pumptype
statusAttr = UA_VariableAttributes_generate(value = false,
    displayname = "Status",
    description = "Status")
statusId = UA_NodeId_new()
requestednewnodeid = UA_NodeId_new()
parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT)
browsename = UA_QUALIFIEDNAME(1, "Status")
typedefinition = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
retval13 = UA_Server_addVariableNode(server, requestednewnodeid, 
    pumpTypeId, parentreferencenodeid, browsename, typedefinition, 
    statusAttr, C_NULL, statusId)
@test retval13 == UA_STATUSCODE_GOOD

#clean up
UA_NodeId_delete(requestednewnodeid)
UA_NodeId_delete(parentreferencenodeid)
UA_NodeId_delete(typedefinition)
UA_VariableAttributes_delete(statusAttr)
UA_QualifiedName_delete(browsename)

#Make the status variable mandatory
reftypeid = UA_NODEID_NUMERIC(0, UA_NS0ID_HASMODELLINGRULE)
targetid = UA_EXPANDEDNODEID_NUMERIC(0, UA_NS0ID_MODELLINGRULE_MANDATORY)
isfoward = true
retval14 = UA_Server_addReference(server, statusId,
    reftypeid, targetid, isforward)
@test retval14 == UA_STATUSCODE_GOOD

#clean up
UA_NodeId_delete(statusId)
UA_NodeId_delete(reftypeid)
UA_ExpandedNodeId_delete(targetid)

#add motorrpm variable to pumptype
rpmAttr = UA_VariableAttributes_generate(displayname = "MotorRPM",
    description = "Pump speed in rpm",
    value = 0)
requestednewnodeid = UA_NodeId_new()
parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT)
browsename = UA_QUALIFIEDNAME(1, "MotorRPMs")
typedefinition = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
retval15 = UA_Server_addVariableNode(server, requestednewnodeid, 
    pumpTypeId, parentreferencenodeid, browsename, 
    typedefinition, rpmAttr, C_NULL, C_NULL)
@test retval15 == UA_STATUSCODE_GOOD

#clean up
UA_NodeId_delete(requestednewnodeid)
UA_NodeId_delete(parentreferencenodeid)
UA_NodeId_delete(typedefinition)
UA_VariableAttributes_delete(rpmAttr)
UA_QualifiedName_delete(browsename)

function addPumpObjectInstance(server, name, id)
    oAttr = UA_ObjectAttributes_generate(displayname = name, description = name)
    requestednewnodeid = UA_NodeId_new()
    parentnodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER)
    parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES)
    browsename = UA_QUALIFIEDNAME(1, name)
    retval = UA_Server_addObjectNode(server, requestednewnodeid,
        parentnodeid, parentreferencenodeid, browsename,
        id, oAttr, C_NULL, C_NULL)
    #clean up
    UA_NodeId_delete(requestednewnodeid)
    UA_NodeId_delete(parentnodeid)
    UA_NodeId_delete(parentreferencenodeid)
    UA_QualifiedName_delete(browsename)
    UA_ObjectAttributes_delete(oAttr)
    return retval
end

function pumpTypeConstructor(server, sessionId, sessionContext,
        typeId, typeContext, nodeId, nodeContext)
    #UA_LOG_INFO(UA_Log_Stdout, UA_LOGCATEGORY_USERLAND, "New pump created")

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

    #clean up
    UA_Variant_delete(value)
    UA_BrowsePath_delete(bp)
    #Don't free up rpe as well, because freeing up bp already does that. 

    return UA_STATUSCODE_GOOD
end

@static if !Sys.isapple() || platform_key_abi().tags["arch"] != "aarch64"
    function addPumpTypeConstructor(server, id)
        c_pumpTypeConstructor = UA_NodeTypeLifecycleCallback_constructor_generate(pumpTypeConstructor)
        lifecycle = UA_NodeTypeLifecycle(c_pumpTypeConstructor, C_NULL)
        UA_Server_setNodeTypeLifecycle(server, id, lifecycle)
    end
else
    function addPumpTypeConstructor(server, id)
        c_pumpTypeConstructor = @cfunction(pumpTypeConstructor, UA_StatusCode,
            (Ptr{UA_Server},
                Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId},
                Ptr{Ptr{Cvoid}}))
        lifecycle = UA_NodeTypeLifecycle(c_pumpTypeConstructor, C_NULL)
        UA_Server_setNodeTypeLifecycle(server, id, lifecycle)
    end
end

r1 = addPumpObjectInstance(server, "pump2", pumpTypeId) #should have status = false (constructor not in place yet)
r2 = addPumpObjectInstance(server, "pump3", pumpTypeId) #should have status = false (constructor not in place yet)
addPumpTypeConstructor(server, pumpTypeId)
r3 = addPumpObjectInstance(server, "pump4", pumpTypeId) #should have status = true
r4 = addPumpObjectInstance(server, "pump5", pumpTypeId) #should have status = true
@test  r1 == UA_STATUSCODE_GOOD
@test  r2 == UA_STATUSCODE_GOOD
@test  r3 == UA_STATUSCODE_GOOD
@test  r4 == UA_STATUSCODE_GOOD
#TODO: should actually check the status value and not just whether adding things went ok.

#clean up pumpTypeId
UA_NodeId_delete(pumpTypeId)

    #add method node
    #follows this: https://www.open62541.org/doc/1.3/tutorial_server_method.html

function helloWorld(server, sessionId, sessionHandle, methodId,
        methodContext, objectId, objectContext, inputSize, input, outputSize, output)
    inputstr = unsafe_string(unsafe_wrap(input))
    tmp = UA_STRING("Hello " * inputstr)
    UA_Variant_setScalarCopy(output, tmp, UA_TYPES_PTRS[UA_TYPES_STRING])
    UA_String_delete(tmp)
    return UA_STATUSCODE_GOOD
end

inputArgument = UA_Argument_new()
lt = UA_LOCALIZEDTEXT("en-US", "A String")
ua_s = UA_STRING("MyInput")
UA_LocalizedText_copy(lt, inputArgument.description)
UA_String_copy(ua_s, inputArgument.name)
inputArgument.dataType = UA_TYPES_PTRS[UA_TYPES_STRING].typeId
inputArgument.valueRank = UA_VALUERANK_SCALAR
UA_LocalizedText_delete(lt)
UA_String_delete(ua_s)

outputArgument = UA_Argument_new()
lt = UA_LOCALIZEDTEXT("en-US", "A String")
ua_s = UA_STRING("MyOutput")
UA_LocalizedText_copy(lt, outputArgument.description)
UA_String_copy(ua_s, outputArgument.name)
outputArgument.dataType = UA_TYPES_PTRS[UA_TYPES_STRING].typeId
outputArgument.valueRank = UA_VALUERANK_SCALAR
helloAttr = UA_MethodAttributes_generate(description = "Say Hello World",
    displayname = "Hello World",
    executable = true,
    userexecutable = true)

methodid = UA_NODEID_NUMERIC(1, 62541)
parentnodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER)
parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT)
@static if !Sys.isapple() || platform_key_abi().tags["arch"] != "aarch64"
    helloWorldMethodCallback = UA_MethodCallback_generate(helloWorld)
else #we are on Apple Silicon and can't use a closure in @cfunction, have to do more work.
    helloWorldMethodCallback = @cfunction(helloWorld, UA_StatusCode,
        (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid},
            Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Cvoid},
            Csize_t, Ptr{UA_Variant}, Csize_t, Ptr{UA_Variant}))
end
browsename = UA_QUALIFIEDNAME(1, "hello world")
retval = UA_Server_addMethodNode(server, methodid,
    parentnodeid, parentreferencenodeid, browsename,
    helloAttr, helloWorldMethodCallback,
    1, inputArgument, 1, outputArgument, C_NULL, C_NULL)

    @test retval == UA_STATUSCODE_GOOD

inputArguments = UA_Variant_new()
ua_s = UA_STRING("Peter")
UA_Variant_setScalar(inputArguments, ua_s, UA_TYPES_PTRS[UA_TYPES_STRING])
req = UA_CallMethodRequest_new()
req.objectId = parentnodeid
req.methodId = methodid
req.inputArgumentsSize = 1
req.inputArguments = inputArguments

    answer = UA_CallMethodResult_new()
    UA_Server_call(server, req, answer)
    @test unsafe_load(answer.statusCode) == UA_STATUSCODE_GOOD
    @test unsafe_string(unsafe_wrap(unsafe_load(answer.outputArguments))) == "Hello Peter"

#clean up
UA_MethodAttributes_delete(helloAttr)
UA_Argument_delete(inputArgument)
UA_Argument_delete(outputArgument)
UA_NodeId_delete(parentnodeid)
UA_NodeId_delete(parentreferencenodeid)
UA_QualifiedName_delete(browsename)
UA_CallMethodRequest_delete(req)
UA_CallMethodResult_delete(answer)
