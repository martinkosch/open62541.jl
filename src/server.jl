# serverconfig functions
"""
```
UA_ServerConfig_setMinimal(config, portNumber, certificate)
```

creates a new server config with one endpoint. The config will set the tcp
network layer to the given port and adds a single endpoint with the security
policy ``SecurityPolicy#None`` to the server. A server certificate may be
supplied but is optional.
"""
function UA_ServerConfig_setMinimal(config, portNumber, certificate)
    UA_ServerConfig_setMinimalCustomBuffer(config, portNumber, certificate, 0, 0)
end

"""
```
UA_ServerConfig_setDefault(config)
```

Creates a server config on the default port 4840 with no server certificate.
"""
function UA_ServerConfig_setDefault(config)
    UA_ServerConfig_setMinimal(config, 4840, C_NULL)
end

## Add node Functions
function UA_Server_addMethodNode(server, requestedNewNodeId, parentNodeId,
        referenceTypeId, browseName, attr, method::Function,
        inputArgumentsSize, inputArguments, outputArgumentsSize,
        outputArguments, nodeContext, outNewNodeId)

    #Generate the appropriate Cfunction pointer for the callback method
    callback = UA_MethodCallback_generate(method)

    return UA_Server_addMethodNodeEx(server, requestedNewNodeId,
        parentNodeId, referenceTypeId, browseName, unsafe_load(attr),
        callback, inputArgumentsSize, inputArguments,
        UA_NODEID_NULL, C_NULL, outputArgumentsSize, outputArguments,
        UA_NODEID_NULL, C_NULL, nodeContext, outNewNodeId)
end

#TODO: would need a JUA_Server_addNode version of this as well.

for nodeclass in instances(UA_NodeClass)
    if nodeclass != __UA_NODECLASS_FORCE32BIT && nodeclass != UA_NODECLASS_UNSPECIFIED
        nodeclass_sym = Symbol(nodeclass)
        funname_sym = Symbol(replace("UA_Server_add" *
                                     titlecase(string(nodeclass_sym)[14:end]) *
                                     "Node", "type" => "Type"))
        attributeptr_sym = Symbol(uppercase("UA_TYPES_" * string(nodeclass_sym)[14:end] *
                                            "ATTRIBUTES"))
        attributetype_sym = Symbol(replace("UA_" *
                                           titlecase(string(nodeclass_sym)[14:end]) *
                                           "Attributes", "type" => "Type"))
        if funname_sym == :UA_Server_addVariableNode ||
           funname_sym == :UA_Server_addVariableTypeNode ||
           funname_sym == :UA_Server_addObjectNode
            @eval begin
                # emit specific add node functions                 
                function $(funname_sym)(server, requestedNewNodeId, parentNodeId,
                        referenceTypeId, browseName, typeDefinition, attributes,
                        nodeContext, outNewNodeId)
                    return __UA_Server_addNode(server, $(nodeclass_sym),
                        requestedNewNodeId, parentNodeId, referenceTypeId,
                        browseName, typeDefinition, attributes,
                        UA_TYPES_PTRS[$(attributeptr_sym)], nodeContext, outNewNodeId)
                end

                #higher level function using dispatch
                function JUA_Server_addNode(server, requestedNewNodeId,
                        parentNodeId, referenceTypeId, browseName,
                        attributes::Ptr{$(attributetype_sym)},
                        outNewNodeId, nodeContext, typeDefinition)
                    return $(funname_sym)(server, requestedNewNodeId,
                        parentNodeId, referenceTypeId, browseName,
                        typeDefinition, attributes, nodeContext, outNewNodeId)
                end
            end
        elseif funname_sym != :UA_Server_addMethodNode
            @eval begin
                # emit specific add node functions
                function $(funname_sym)(server, requestedNewNodeId, parentNodeId,
                        referenceTypeId, browseName, attributes, nodeContext,
                        outNewNodeId)
                    return __UA_Server_addNode(server, $(nodeclass_sym),
                        requestedNewNodeId,
                        parentNodeId, referenceTypeId, browseName,
                        wrap_ref(UA_NODEID_NULL), attributes,
                        UA_TYPES_PTRS[$(attributeptr_sym)],
                        nodeContext, outNewNodeId)
                end

                #higher level function using dispatch
                function JUA_Server_addNode(server, requestedNewNodeId,
                        parentNodeId, referenceTypeId, browseName,
                        attributes::Ptr{$(attributetype_sym)},
                        outNewNodeId, nodeContext)
                    return $(funname_sym)(server, requestedNewNodeId,
                        parentNodeId, referenceTypeId, browseName, attributes,
                        nodeContext, outNewNodeId)
                end
            end
        end
    end
end

## Read functions
for att in attributes_UA_Server_read
    fun_name = Symbol(att[1])
    attr_name = Symbol(att[2])
    ret_type = Symbol(att[3] * "_new")
    ret_type_ptr = Symbol("UA_TYPES_", uppercase(String(ret_type)[4:end]))
    ua_attr_name = Symbol("UA_ATTRIBUTEID_", uppercase(att[2]))

    @eval begin
        """
        ```
        $($(fun_name))(server, nodeId, out = $($(String(ret_type)))())
        ```

        Uses the Server API to read the value of the attribute $($(String(attr_name))) from the NodeId `nodeId` located on server `server`.
        The result is saved into the buffer `out`.

        """
        function $(fun_name)(server, nodeId, out = $(ret_type)())
            statuscode = __UA_Server_read(server, nodeId, $(ua_attr_name), out)
            if statuscode == UA_STATUSCODE_GOOD
                return out
            else
                action = "Reading"
                side = "Server"
                mode = ""
                err = AttributeReadWriteError(action, mode, side,
                    $(String(attr_name)), statuscode)
                throw(err)
            end
        end
    end
end

## Write functions
for att in attributes_UA_Server_write
    fun_name = Symbol(att[1])
    attr_name = Symbol(att[2])
    attr_type = Symbol(att[3])
    attr_type_ptr = Symbol("UA_TYPES_", uppercase(String(attr_type)[4:end]))
    ua_attr_name = Symbol("UA_ATTRIBUTEID_", uppercase(att[2]))

    @eval begin
        """
        ```
        $($(fun_name))(server, nodeId, new_val)
        ```

        Uses the Server API to write the value `new_val` to the attribute $($(String(attr_name))) of the NodeId `nodeId` located on server `server`. 

        """
        function $(fun_name)(server, nodeId, new_val)
            data_type_ptr = UA_TYPES_PTRS[$(attr_type_ptr)]
            statuscode = __UA_Server_write(server, nodeId, $(ua_attr_name),
                data_type_ptr, wrap_ref(new_val))
            if statuscode == UA_STATUSCODE_GOOD
                return statuscode
            else
                action = "Writing"
                side = "Server"
                mode = ""
                err = AttributeReadWriteError(action, mode, side,
                    $(String(attr_name)), statuscode)
                throw(err)
            end
        end
    end
end

function UA_Server_call(server, request, result)
    r = UA_Server_call(server, request)
    UA_CallMethodResult_copy(r, result)
    return result
end
