UA_Client_getContext(client::UA_Client) = UA_Client_getConfig(client).clientContext

function UA_Client_connectUsername(client::Ptr{UA_Client},
        endpointUrl::AbstractString,
        username::AbstractString,
        password::AbstractString)
    identityToken = UA_UserNameIdentityToken_new()
    identityToken == CNULL && return UA_STATUSCODE_BADOUTOFMEMORY
    identityToken.userName = UA_STRING_ALLOC(username)
    identityToken.password = UA_STRING_ALLOC(password)
    cc = UA_Client_getConfig(client)
    UA_ExtensionObject_clear(cc.userIdentityToken)
    cc.userIdentityToken.encoding = UA_EXTENSIONOBJECT_DECODED
    cc.userIdentityToken.content.decoded.type = UA_TYPES_PTRS[UA_TYPES_USERNAMEIDENTITYTOKEN]
    cc.userIdentityToken.content.decoded.data = identityToken
    return UA_Client_connect(client, endpointUrl)
end

## UA_Client_Service functions
for att in attributes_UA_Client_Service
    fun_name = Symbol(att[1])
    req_type = Symbol("UA_", uppercasefirst(att[2]), "Request")
    resp_type = Symbol("UA_", uppercasefirst(att[2]), "Response")
    req_type_ptr = Symbol("UA_TYPES_", uppercase(String(att[2])), "REQUEST")
    resp_type_ptr = Symbol("UA_TYPES_", uppercase(String(att[2])), "RESPONSE")

    @eval begin
        if @isdefined $(req_type) # Skip functions that use undefined types, e.g. deactivated historizing types
            function $(fun_name)(client::Ref{UA_Client}, request::Ptr{$(req_type)})
                response = Ref{$(resp_type)}()
                statuscode = __UA_Client_Service(client,
                    request,
                    UA_TYPES_PTRS[$(req_type_ptr)],
                    response,
                    UA_TYPES_PTRS[$(resp_type_ptr)])
                if isnothing(statuscode) || statuscode == UA_STATUSCODE_GOOD
                    return response[]
                else
                    throw(ClientServiceRequestError("Service request of type ´$(req_type)´ from UA_Client failed with statuscode \"$(UA_StatusCode_name_print(statuscode))\"."))
                end
            end
        end
        #function fallback that wraps any non-ref arguments into refs:
        $(fun_name)(client, request) = $(fun_name)(wrap_ref(client), wrap_ref(request))
    end
end

#TODO: Untested
function UA_Client_MonitoredItems_setMonitoringMode(client, request)
    response = UA_SetMonitoringModeResponse_new()
    __UA_Client_Service(client,
        request, UA_TYPES_PTRS[UA_TYPES_SETMONITORINGMODEREQUEST],
        response, UA_TYPES_PTRS[UA_TYPES_SETMONITORINGMODERESPONSE])
    return response
end

#TODO: Untested
function UA_Client_Subscriptions_setPublishingMode(client, request) 
    response = UA_SetPublishingModeResponse_new()
    __UA_Client_Service(client,
        request, UA_TYPES_PTRS[UA_TYPES_SETPUBLISHINGMODEREQUEST],
        response, UA_TYPES_PTRS[UA_TYPES_SETPUBLISHINGMODERESPONSE])
    return response
end

#TODO: Untested
function UA_Client_MonitoredItems_setTriggering(client, request)
    response = UA_SetTriggeringResponse_new()
    __UA_Client_Service(client,
        request, UA_TYPES_PTRS[UA_TYPES_SETTRIGGERINGREQUEST],
        response, UA_TYPES_PTRS[UA_TYPES_SETTRIGGERINGRESPONSE])
    return response;
end

## Client Add node functions
for nodeclass in instances(UA_NodeClass)
    if nodeclass != __UA_NODECLASS_FORCE32BIT && nodeclass != UA_NODECLASS_UNSPECIFIED
        nodeclass_sym = Symbol(nodeclass)
        funname_sym = Symbol(replace("UA_Client_add" *
                                     titlecase(string(nodeclass_sym)[14:end]) *
                                     "Node", "type" => "Type"))
        attributeptr_sym = Symbol(uppercase("UA_TYPES_" * string(nodeclass_sym)[14:end] *
                                             "ATTRIBUTES"))
        attributetype_sym = Symbol(replace("UA_"*titlecase(string(nodeclass_sym)[14:end]) *
        "Attributes", "type" => "Type"))
        if funname_sym == :UA_Client_addVariableNode || funname_sym == :UA_Client_addObjectNode
            @eval begin
                # emit specific add node functions
                # UA_Client_addVariableNode     (*client, requestedNewNodeId, parentNodeId, referenceTypeId, browseName, typeDefinition, attr, *outNewNodeId)
                # UA_Client_addObjectNode       (*client, requestedNewNodeId, parentNodeId, referenceTypeId, browseName, typeDefinition, attr, *outNewNodeId) 
                # UA_Client_addVariableTypeNode (*client, requestedNewNodeId, parentNodeId, referenceTypeId, browseName, attr, *outNewNodeId)
                # UA_Client_addReferenceTypeNode(*client, requestedNewNodeId, parentNodeId, referenceTypeId, browseName, attr, *outNewNodeId) 
                # UA_Client_addObjectTypeNode   (*client, requestedNewNodeId, parentNodeId, referenceTypeId, browseName, attr, *outNewNodeId)
                # UA_Client_addViewNode         (*client, requestedNewNodeId, parentNodeId, referenceTypeId, browseName, attr, *outNewNodeId)
                # UA_Client_addReferenceTypeNode(*client, requestedNewNodeId, parentNodeId, referenceTypeId, browseName, attr, *outNewNodeId)
                # UA_Client_addDataTypeNode     (*client, requestedNewNodeId, parentNodeId, referenceTypeId, browseName, attr, *outNewNodeId) 
                # UA_Client_addMethodNode       (*client, requestedNewNodeId, parentNodeId, referenceTypeId, browseName, attr, *outNewNodeId)
                
                #UA_Server_addVariableNode     (*server, requestedNewNodeId, parentNodeId, referenceTypeId, browseName, typeDefinition, attr, *nodeContext, *outNewNodeId)
                function $(funname_sym)(client,
                        requestedNewNodeId,
                        parentNodeId,
                        referenceTypeId,
                        browseName,
                        typeDefinition,
                        attributes,
                        outNewNodeId)
                    return __UA_Client_addNode(client, $(nodeclass_sym),
                        wrap_ref(requestedNewNodeId),
                        wrap_ref(parentNodeId), wrap_ref(referenceTypeId), browseName,
                        wrap_ref(typeDefinition), attributes,
                        UA_TYPES_PTRS[$(attributeptr_sym)],
                        outNewNodeId)
                end
            end
        else
            @eval begin
                function $(funname_sym)(client,
                    requestedNewNodeId,
                    parentNodeId,
                    referenceTypeId,
                    browseName,
                    attributes,
                    outNewNodeId)
                return __UA_Client_addNode(client, $(nodeclass_sym),
                    wrap_ref(requestedNewNodeId),
                    wrap_ref(parentNodeId), wrap_ref(referenceTypeId), browseName,
                    UA_NODEID_NULL, attributes,
                    UA_TYPES_PTRS[$(attributeptr_sym)],
                    outNewNodeId) 
                end
            end
        end

        # #higher level function using dispatch
        # function JUA_Server_addNode(server,
        #         requestedNewNodeId,
        #         parentNodeId,
        #         referenceTypeId,
        #         browseName,
        #         typeDefinition,
        #         attributes::Ptr{$(attributetype_sym)},
        #         nodeContext,
        #         outNewNodeId)
        #     return $(funname_sym)(server,
        #         requestedNewNodeId,
        #         parentNodeId,
        #         referenceTypeId,
        #         browseName,
        #         typeDefinition,
        #         attributes,
        #         nodeContext,
        #         outNewNodeId) 
        # end
    end
end

## Read attribute functions
for att in attributes_UA_Client_read
    fun_name = Symbol(att[1])
    attr_name = Symbol(att[2])
    returnobject = Symbol(att[3]*"_new")
    ret_type_ptr = Symbol("UA_TYPES_", uppercase(String(Symbol(att[3]))[4:end]))
    ua_attr_name = Symbol("UA_ATTRIBUTEID_", uppercase(att[2]))

    @eval begin
        function $(fun_name)(client, nodeId, out =  $returnobject())
            data_type_ptr = UA_TYPES_PTRS[$(ret_type_ptr)]
            statuscode = __UA_Client_readAttribute(client,
                nodeId,
                $(ua_attr_name),
                out,
                data_type_ptr)
            if statuscode == UA_STATUSCODE_GOOD
                return out
            else
                action = "Reading"
                side = "Client"
                mode = ""
                err = AttributeReadWriteError(action,
                    mode,
                    side,
                    $(String(attr_name)),
                    statuscode)
                throw(err)
            end
        end
        #function fallback that wraps any non-ref arguments into refs:
        #$(fun_name)(client, nodeId) = $(fun_name)(wrap_ref(client), wrap_ref(nodeId))
    end
end

## Write attribute functions
for att in attributes_UA_Client_write
    fun_name = Symbol(att[1])
    attr_name = Symbol(att[2])
    attr_type = Symbol(att[3])
    attr_type_ptr = Symbol("UA_TYPES_", uppercase(String(attr_type)[4:end]))
    ua_attr_name = Symbol("UA_ATTRIBUTEID_", uppercase(att[2]))

    @eval begin
        function $(fun_name)(client::Ref{UA_Client},
                nodeId::Ref{UA_NodeId},
                new_attr::Ref{$attr_type})
            data_type_ptr = UA_TYPES_PTRS[$(attr_type_ptr)]
            statuscode = __UA_Client_writeAttribute(client,
                nodeId,
                $(ua_attr_name),
                new_attr,
                data_type_ptr)
            if statuscode == UA_STATUSCODE_GOOD
                return statuscode
            else
                action = "Writing"
                side = "Client"
                mode = ""
                err = AttributeReadWriteError(action,
                    mode,
                    side,
                    $(String(attr_name)),
                    statuscode)
                throw(err)
            end
        end
        #function fallback that wraps any non-ref arguments into refs:
        function $(fun_name)(client, nodeId, new_attr)
            return ($fun_name)(wrap_ref(client),
                wrap_ref(nodeId),
                wrap_ref(new_attr))
        end
    end
end

## Read attribute async functions
for att in attributes_UA_Client_read_async
    fun_name = Symbol(att[1])
    attr_name = Symbol(att[2])
    ret_type = Symbol(att[3])
    ret_type_ptr = Symbol("UA_TYPES_", uppercase(String(ret_type)[4:end]))
    ua_attr_name = Symbol("UA_ATTRIBUTEID_", uppercase(att[2]))

    @eval begin
        function $(fun_name)(client::Ref{UA_Client},
                nodeId::Ref{UA_NodeId},
                callback::Ref{Nothing},
                userdata::Ref{Nothing},
                reqId::Integer)
            data_type_ptr = UA_TYPES_PTRS[$(ret_type_ptr)]
            statuscode = __UA_Client_readAttribute_async(client,
                nodeId,
                $(ua_attr_name),
                data_type_ptr,
                reinterpret(UA_ClientAsyncServiceCallback, callback),
                userdata,
                reqId)
            if statuscode == UA_STATUSCODE_GOOD
                return statuscode
            else
                action = "Reading"
                side = "Client"
                mode = "asynchronously"
                err = AttributeReadWriteError(action,
                    mode,
                    side,
                    $(String(attr_name)),
                    statuscode)
                throw(err)
            end
        end
        #function fallback that wraps any non-ref arguments into refs:
        function $(fun_name)(client, nodeId, callback, userdata, reqId)
            return $(fun_name)(wrap_ref(client),
                wrap_ref(nodeId),
                wrap_ref(callback),
                wrap_ref(userdata),
                reqId::Integer)
        end
    end
end

## Write attribute async functions
for att in attributes_UA_Client_write_async
    fun_name = Symbol(att[1])
    attr_name = Symbol(att[2])
    attr_type = Symbol(att[3])
    attr_type_ptr = Symbol("UA_TYPES_", uppercase(String(attr_type)[4:end]))
    ua_attr_name = Symbol("UA_ATTRIBUTEID_", uppercase(att[2]))

    @eval begin
        function $(fun_name)(client::Ref{UA_Client},
                nodeId::Ref{UA_NodeId},
                out::Ref{$(attr_type)},
                callback::Ref{Nothing},
                userdata::Ref{Nothing},
                reqId::Integer)
            data_type_ptr = UA_TYPES_PTRS[$(attr_type_ptr)]
            statuscode = __UA_Client_writeAttribute_async(client,
                nodeId,
                $(ua_attr_name),
                out,
                data_type_ptr,
                callback,
                userdata,
                reqId)
            if statuscode == UA_STATUSCODE_GOOD
                return statuscode
            else
                action = "Writing"
                side = "Client"
                mode = "asynchronously"
                err = AttributeReadWriteError(action,
                    mode,
                    side,
                    $(String(attr_name)),
                    statuscode)
                throw(err)
            end
        end
        #function fallback that wraps any non-ref arguments into refs:
        function $(fun_name)(client, nodeId, out, callback, userdata, reqId)
            return $(fun_name)(wrap_ref(client),
                wrap_ref(nodeId),
                wrap_ref(out),
                wrap_ref(callback),
                wrap_ref(userdata),
                reqId::Integer)
        end
    end
end
