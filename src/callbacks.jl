#Purpose: File will be used to define callbacks (via @cfunction) used across open62541
#includes generator functions and very simple prototypes as illustrations.

"""
```
UA_NodeTypeLifeCycleCallback_constructor_generate(f::Function)
```

creates a function pointer for the `constructor` field of a `UA_NodeTypeLifeCycle`
object.

`f` must be a Julia function with the following signature:

```f(server::Ptr{UA_Server}, sessionId:: Ptr{UA_NodeId},
       sessionContext::Ptr{Cvoid}, typeNodeId::Ptr{UA_NodeId}, typeNodeContext::Ptr{Cvoid}, 
       nodeId::Ptr{UA_NodeId}, nodeContext::Ptr{Ptr{Cvoid}})::UA_StatusCode```
```
"""
function UA_NodeTypeLifecycleCallback_constructor_generate(f::Function)
    argtuple = (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId},
        Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Ptr{Cvoid}})
    returntype = UA_StatusCode
    ret = Base.return_types(f, argtuple)
    if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret) &&
       ret[1] == returntype
        callback = @cfunction($f,
            UA_StatusCode,
            (Ptr{UA_Server},
                Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId},
                Ptr{Ptr{Cvoid}}))
        return Base.unsafe_convert(Ptr{Cvoid}, callback)
    else
        err = CallbackGeneratorArgumentError(f, argtuple, returntype)
        throw(err)
    end
end

"""
```
UA_NodeTypeLifeCycleCallback_destructor_generate(f::Function)
```

creates a function pointer for the `destructor` field of a `UA_NodeTypeLifeCycle`
object.

`f` must be a Julia function with the following signature:

```f(server::Ptr{UA_Server}, sessionId:: Ptr{UA_NodeId},
       sessionContext::Ptr{Cvoid}, typeNodeId::Ptr{UA_NodeId}, typeNodeContext::Ptr{Cvoid}, 
       nodeId::Ptr{UA_NodeId}, nodeContext::Ptr{Ptr{Cvoid}})::Cvoid```
```
"""
function UA_NodeTypeLifecycleCallback_destructor_generate(f::Function)
    argtuple = (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId},
        Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Ptr{Cvoid}})
    returntype = Nothing
    ret = Base.return_types(f, argtuple)
    if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret) &&
       ret[1] == returntype
        callback = @cfunction($f,
            Cvoid,
            (Ptr{UA_Server}, Ptr{UA_NodeId},
                Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Ptr{Cvoid}}))
        return Base.unsafe_convert(Ptr{Cvoid}, callback)
    else
        err = CallbackGeneratorArgumentError(f, argtuple, returntype)
        throw(err)
    end
end

"""
```
UA_MethodCallback_generate(f::Function)
```

creates a `UA_MethodCallback` that can be attached to a method node using
`UA_Server_addMethodNode`.

`f` must be a Julia function with the following signature:
```f(server::Ptr{UA_Server}, sessionId::Ptr{UA_NodeId}), sessionContext::Ptr{Cvoid}`,   methodId::Ptr{UA_NodeId}, methodContext::Ptr{Cvoid}, objectId::Ptr{UA_NodeId},   objectContext::Ptr{Cvoid}, inputSize::Csize_t, input::Ptr{UA_Variant},   outputSize::Csize_t, output::Ptr{UA_Variant})::UA_StatusCode```
"""
function UA_MethodCallback_generate(f::Function)
    argtuple = (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId},
        Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Cvoid}, Csize_t, Ptr{UA_Variant},
        Csize_t, Ptr{UA_Variant})
    returntype = UA_StatusCode
    ret = Base.return_types(f, argtuple)
    if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret) &&
       ret[1] == returntype
        callback = @cfunction($f, UA_StatusCode,
            (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid},
                Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId}, Ptr{Cvoid},
                Csize_t, Ptr{UA_Variant}, Csize_t, Ptr{UA_Variant}))
        return callback
    else
        err = CallbackGeneratorArgumentError(f, argtuple, returntype)
        throw(err)
    end
end

"""
```
UA_ValueCallback_onRead_generate(f::Function)
```

creates a function pointer for the `onRead` field of a `UA_ValueCallback`
object.

`f` must be a Julia function with the following signature:
```f(server::Ptr{UA_Server}, sessionid::Ptr{UA_NodeId}), sessioncontext::Ptr{Cvoid}, 
        nodeid::Ptr{Cvoid}, nodecontext::Ptr{Cvoid}, range::Ptr{UA_NumericRange}, 
        data::Ptr{UA_DataValue})::Nothing```
"""
function UA_ValueCallback_onRead_generate(f::Function)
    argtuple = (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId},
        Ptr{Cvoid}, Ptr{UA_NumericRange}, Ptr{UA_DataValue})
    returntype = Nothing
    ret = Base.return_types(f, argtuple)
    if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret) &&
       ret[1] == returntype
        callback = @cfunction($f, Nothing,
            (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId},
            Ptr{Cvoid}, Ptr{UA_NumericRange}, Ptr{UA_DataValue}))
        return callback
    else
        err = CallbackGeneratorArgumentError(f, argtuple, returntype)
        throw(err)
    end
end

"""
```
UA_ValueCallback_onWrite_generate(f::Function)
```

creates a function pointer for the `onWrite` field of a `UA_ValueCallback`
object.

`f` must be a Julia function with the following signature:
```f(server::Ptr{UA_Server}, sessionid::Ptr{UA_NodeId}), sessioncontext::Ptr{Cvoid}, 
        nodeid::Ptr{Cvoid}, nodecontext::Ptr{Cvoid}, range::Ptr{UA_NumericRange}, 
        data::Ptr{UA_DataValue})::Nothing```
"""
function UA_ValueCallback_onWrite_generate(f::Function)
    argtuple = (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId},
        Ptr{Cvoid}, Ptr{UA_NumericRange}, Ptr{UA_DataValue})
    returntype = Nothing
    ret = Base.return_types(f, argtuple)
    if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret) &&
       ret[1] == returntype
        callback = @cfunction($f, Nothing,
            (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId},
            Ptr{Cvoid}, Ptr{UA_NumericRange}, Ptr{UA_DataValue}))
        return callback
    else
        err = CallbackGeneratorArgumentError(f, argtuple, returntype)
        throw(err)
    end
end

"""
```
UA_DataSourceCallback_write_generate(f::Function)
```

creates a function pointer for the `write` field of a `UA_DataSource`
object.

`f` must be a Julia function with the following signature:
```f(server::Ptr{UA_Server}, sessionid::Ptr{UA_NodeId}), sessioncontext::Ptr{Cvoid}, 
        nodeid::Ptr{Cvoid}, nodecontext::Ptr{Cvoid}, range::Ptr{UA_NumericRange}, 
        data::Ptr{UA_DataValue})::UA_StatusCode```
"""
function UA_DataSourceCallback_write_generate(f::Function)
    argtuple = (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId},
        Ptr{Cvoid}, Ptr{UA_NumericRange}, Ptr{UA_DataValue})
    returntype = UA_StatusCode
    ret = Base.return_types(f, argtuple)
    if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret) &&
       ret[1] == returntype
        callback = @cfunction($f, UA_StatusCode,
            (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId},
            Ptr{Cvoid}, Ptr{UA_NumericRange}, Ptr{UA_DataValue}))
        return callback
    else
        err = CallbackGeneratorArgumentError(f, argtuple, returntype)
        throw(err)
    end
end

"""
```
UA_DataSourceCallback_read_generate(f::Function)
```

creates a function pointer for the `read` field of a `UA_DataSource`
object.

`f` must be a Julia function with the following signature:
```f(server::Ptr{UA_Server}, sessionid::Ptr{UA_NodeId}), sessioncontext::Ptr{Cvoid}, 
        nodeid::Ptr{Cvoid}, nodecontext::Ptr{Cvoid}, includesourcetimestamp::UA_Boolean, 
        range::Ptr{UA_NumericRange}, data::Ptr{UA_DataValue})::UA_StatusCode```
"""
function UA_DataSourceCallback_read_generate(f::Function)
    argtuple = (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId},
        Ptr{Cvoid}, UA_Boolean, Ptr{UA_NumericRange}, Ptr{UA_DataValue})
    returntype = UA_StatusCode
    ret = Base.return_types(f, argtuple)
    if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret) &&
       ret[1] == returntype
        callback = @cfunction($f, UA_StatusCode,
            (Ptr{UA_Server}, Ptr{UA_NodeId}, Ptr{Cvoid}, Ptr{UA_NodeId},
            Ptr{Cvoid}, UA_Boolean, Ptr{UA_NumericRange}, Ptr{UA_DataValue}))
        return callback
    else
        err = CallbackGeneratorArgumentError(f, argtuple, returntype)
        throw(err)
    end
end

"""
```
UA_ServerCallback_generate(f::Function)
```

creates a `UA_ServerCallback` object that can be used in `UA_Server_addTimedCallback` 
or `UA_Server_addRepeatedCallback`.

`f` must be a Julia function with the following signature:
```f(server::Ptr{UA_Server}, data::Ptr{Cvoid}))::Nothing```
"""
function UA_ServerCallback_generate(f::Function)
    argtuple = (Ptr{UA_Server}, Ptr{Cvoid})
    returntype = Nothing
    ret = Base.return_types(f, argtuple)
    if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret) &&
       ret[1] == returntype
        callback = @cfunction($f, Nothing, (Ptr{UA_Server}, Ptr{Cvoid}))
        return callback
    else
        err = CallbackGeneratorArgumentError(f, argtuple, returntype)
        throw(err)
    end
end

"""
```
UA_ClientCallback_generate(f::Function)
```
creates a `UA_ClientCallback` object that can be used in `UA_Client_addTimedCallback` 
or `UA_Client_addRepeatedCallback`.

`f` must be a Julia function with the following signature:
```f(client::Ptr{UA_Client}, data::Ptr{Cvoid}))::Nothing```
"""
function UA_ClientCallback_generate(f::Function)
    argtuple = (Ptr{UA_Client}, Ptr{Cvoid})
    returntype = Nothing
    ret = Base.return_types(f, argtuple)
    if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret) &&
       ret[1] == returntype
        callback = @cfunction($f, Nothing, (Ptr{UA_Client}, Ptr{Cvoid}))
        return callback
    else
        err = CallbackGeneratorArgumentError(f, argtuple, returntype)
        throw(err)
    end
end

#1 # typedef void ( * UA_Server_AsyncOperationNotifyCallback ) ( UA_Server * server )
#2 # typedef UA_Connection ( * UA_ConnectClientConnection ) ( UA_ConnectionConfig config , UA_String endpointUrl , UA_UInt32 timeout , const UA_Logger * logger )
#3 # typedef void ( * UA_NodestoreVisitor ) ( void * visitorCtx , const UA_Node * node )
#4 # typedef UA_StatusCode ( * UA_NodeIteratorCallback ) ( UA_NodeId childId , UA_Boolean isInverse , UA_NodeId referenceTypeId , void * handle )
#5 # typedef void ( * UA_Server_DataChangeNotificationCallback ) ( UA_Server * server , UA_UInt32 monitoredItemId , void * monitoredItemContext , const UA_NodeId * nodeId , void * nodeContext , UA_UInt32 attributeId , const UA_DataValue * value )
#6 # typedef void ( * UA_Server_EventNotificationCallback ) ( UA_Server * server , UA_UInt32 monId , void * monContext , size_t nEventFields , const UA_Variant * eventFields )
#7 # typedef void ( * UA_ClientAsyncServiceCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , void * response )
#8 # typedef UA_Boolean ( * UA_HistoricalIteratorCallback ) ( UA_Client * client , const UA_NodeId * nodeId , UA_Boolean moreDataAvailable , const UA_ExtensionObject * data , void * callbackContext )
#9 # typedef void ( * UA_Client_DeleteSubscriptionCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext )
#10 # typedef void ( * UA_Client_StatusChangeNotificationCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext , UA_StatusChangeNotification * notification )
#11 # typedef void ( * UA_Client_DeleteMonitoredItemCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext , UA_UInt32 monId , void * monContext )
#12 # typedef void ( * UA_Client_DataChangeNotificationCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext , UA_UInt32 monId , void * monContext , UA_DataValue * value )
#13 # typedef void ( * UA_Client_EventNotificationCallback ) ( UA_Client * client , UA_UInt32 subId , void * subContext , UA_UInt32 monId , void * monContext , size_t nEventFields , UA_Variant * eventFields )
#14 # typedef void ( * UA_ClientAsyncReadCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_ReadResponse * rr )
#15 # typedef void ( * UA_ClientAsyncWriteCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_WriteResponse * wr )
#16 # typedef void ( * UA_ClientAsyncBrowseCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_BrowseResponse * wr )
#17 # typedef void ( * UA_ClientAsyncOperationCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_StatusCode status , void * result )
#18 # typedef void ( * UA_ClientAsyncCallCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_CallResponse * cr )
#19 # typedef void ( * UA_ClientAsyncAddNodesCallback ) ( UA_Client * client , void * userdata , UA_UInt32 requestId , UA_AddNodesResponse * ar )
#20 # typedef UA_StatusCode ( * UA_UsernamePasswordLoginCallback ) ( const UA_String * userName , const UA_ByteString * password , size_t usernamePasswordLoginSize , const UA_UsernamePasswordLogin * usernamePasswordLogin , void * * sessionContext , void * loginContext )
"""
```
UA_ClientAsyncReadAttributeCallback_generate(f::Function)
```
creates a `UA_ClientAsyncReadAttributeCallback` that can be supplied as callback argument to `UA_Client_readAttribute_async`.
The callback will be triggered once the read operation has been carried out.

`f` must be a Julia function with the following signature:
```f(client::Ptr{UA_Client}, userdata::Ptr{Cvoid}, requestid::UA_UInt32, 
    status::UA_StatusCode, attribute)::UA_DataValue)::Nothing```
"""
function UA_ClientAsyncReadAttributeCallback_generate(f)
                      argtuple = (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode,
                          UA_DataValue)
                      returntype = Nothing
                      ret = Base.return_types(f, argtuple)
                      if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret)  && ret[1] == returntype
                          callback = @cfunction($f, Cvoid, 
                              (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode, UA_DataValue)) 
                          return callback
                      else
                          err = CallbackGeneratorArgumentError(f, argtuple, returntype)
                                                    throw(err)
                      end
                  end

                  """
```
UA_ClientAsyncReadValueAttributeCallback_generate(f::Function)
```
creates a `UA_ClientAsyncReadValueAttributeCallback` that can be supplied as callback argument to `UA_Client_readValueAttribute_async`.
The callback will be triggered once the read operation has been carried out.

`f` must be a Julia function with the following signature:
```f(client::Ptr{UA_Client}, userdata::Ptr{Cvoid}, requestid::UA_UInt32, 
    status::UA_StatusCode, value)::UA_DataValue)::Nothing```
"""
function UA_ClientAsyncReadValueAttributeCallback_generate(f)
                      argtuple = (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode,
                          UA_DataValue)
                      returntype = Nothing
                      ret = Base.return_types(f, argtuple)
                      if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret)  && ret[1] == returntype
                          callback = @cfunction($f, Cvoid, 
                              (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode, UA_DataValue)) 
                          return callback
                      else
                          err = CallbackGeneratorArgumentError(f, argtuple, returntype)
                                                    throw(err)
                      end
                  end

                  """
```
UA_ClientAsyncReadDataTypeAttributeCallback_generate(f::Function)
```
creates a `UA_ClientAsyncReadDataTypeAttributeCallback` that can be supplied as callback argument to `UA_Client_readDataTypeAttribute_async`.
The callback will be triggered once the read operation has been carried out.

`f` must be a Julia function with the following signature:
```f(client::Ptr{UA_Client}, userdata::Ptr{Cvoid}, requestid::UA_UInt32, 
    status::UA_StatusCode, datatype)::UA_NodeId)::Nothing```
"""
function UA_ClientAsyncReadDataTypeAttributeCallback_generate(f)
                      argtuple = (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode,
                          UA_NodeId)
                      returntype = Nothing
                      ret = Base.return_types(f, argtuple)
                      if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret)  && ret[1] == returntype
                          callback = @cfunction($f, Cvoid, 
                              (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode, UA_NodeId)) 
                          return callback
                      else
                          err = CallbackGeneratorArgumentError(f, argtuple, returntype)
                                                    throw(err)
                      end
                  end

                  """
```
UA_ClientReadArrayDimensionsAttributeCallback_generate(f::Function)
```
creates a `UA_ClientReadArrayDimensionsAttributeCallback` that can be supplied as callback argument to `UA_Client_readUA_ClientReadArrayDimensionsAttribute_async`.
The callback will be triggered once the read operation has been carried out.

`f` must be a Julia function with the following signature:
```f(client::Ptr{UA_Client}, userdata::Ptr{Cvoid}, requestid::UA_UInt32, 
    status::UA_StatusCode, arraydimensions)::UA_Variant)::Nothing```
"""
function UA_ClientReadArrayDimensionsAttributeCallback_generate(f)
                      argtuple = (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode,
                          UA_Variant)
                      returntype = Nothing
                      ret = Base.return_types(f, argtuple)
                      if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret)  && ret[1] == returntype
                          callback = @cfunction($f, Cvoid, 
                              (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode, UA_Variant)) 
                          return callback
                      else
                          err = CallbackGeneratorArgumentError(f, argtuple, returntype)
                                                    throw(err)
                      end
                  end

                  """
```
UA_ClientAsyncReadNodeClassAttributeCallback_generate(f::Function)
```
creates a `UA_ClientAsyncReadNodeClassAttributeCallback` that can be supplied as callback argument to `UA_Client_readNodeClassAttribute_async`.
The callback will be triggered once the read operation has been carried out.

`f` must be a Julia function with the following signature:
```f(client::Ptr{UA_Client}, userdata::Ptr{Cvoid}, requestid::UA_UInt32, 
    status::UA_StatusCode, nodeclass)::UA_NodeClass)::Nothing```
"""
function UA_ClientAsyncReadNodeClassAttributeCallback_generate(f)
                      argtuple = (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode,
                          UA_NodeClass)
                      returntype = Nothing
                      ret = Base.return_types(f, argtuple)
                      if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret)  && ret[1] == returntype
                          callback = @cfunction($f, Cvoid, 
                              (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode, UA_NodeClass)) 
                          return callback
                      else
                          err = CallbackGeneratorArgumentError(f, argtuple, returntype)
                                                    throw(err)
                      end
                  end

                  """
```
UA_ClientAsyncReadBrowseNameAttributeCallback_generate(f::Function)
```
creates a `UA_ClientAsyncReadBrowseNameAttributeCallback` that can be supplied as callback argument to `UA_Client_readBrowseNameAttribute_async`.
The callback will be triggered once the read operation has been carried out.

`f` must be a Julia function with the following signature:
```f(client::Ptr{UA_Client}, userdata::Ptr{Cvoid}, requestid::UA_UInt32, 
    status::UA_StatusCode, browsename)::UA_QualifiedName)::Nothing```
"""
function UA_ClientAsyncReadBrowseNameAttributeCallback_generate(f)
                      argtuple = (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode,
                          UA_QualifiedName)
                      returntype = Nothing
                      ret = Base.return_types(f, argtuple)
                      if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret)  && ret[1] == returntype
                          callback = @cfunction($f, Cvoid, 
                              (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode, UA_QualifiedName)) 
                          return callback
                      else
                          err = CallbackGeneratorArgumentError(f, argtuple, returntype)
                                                    throw(err)
                      end
                  end

                  """
```
UA_ClientAsyncReadDisplayNameAttributeCallback_generate(f::Function)
```
creates a `UA_ClientAsyncReadDisplayNameAttributeCallback` that can be supplied as callback argument to `UA_Client_readDisplayNameAttribute_async`.
The callback will be triggered once the read operation has been carried out.

`f` must be a Julia function with the following signature:
```f(client::Ptr{UA_Client}, userdata::Ptr{Cvoid}, requestid::UA_UInt32, 
    status::UA_StatusCode, displayname)::UA_LocalizedText)::Nothing```
"""
function UA_ClientAsyncReadDisplayNameAttributeCallback_generate(f)
                      argtuple = (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode,
                          UA_LocalizedText)
                      returntype = Nothing
                      ret = Base.return_types(f, argtuple)
                      if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret)  && ret[1] == returntype
                          callback = @cfunction($f, Cvoid, 
                              (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode, UA_LocalizedText)) 
                          return callback
                      else
                          err = CallbackGeneratorArgumentError(f, argtuple, returntype)
                                                    throw(err)
                      end
                  end

                  """
```
UA_ClientAsyncReadDescriptionAttributeCallback_generate(f::Function)
```
creates a `UA_ClientAsyncReadDescriptionAttributeCallback` that can be supplied as callback argument to `UA_Client_readDescriptionAttribute_async`.
The callback will be triggered once the read operation has been carried out.

`f` must be a Julia function with the following signature:
```f(client::Ptr{UA_Client}, userdata::Ptr{Cvoid}, requestid::UA_UInt32, 
    status::UA_StatusCode, description)::UA_LocalizedText)::Nothing```
"""
function UA_ClientAsyncReadDescriptionAttributeCallback_generate(f)
                      argtuple = (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode,
                          UA_LocalizedText)
                      returntype = Nothing
                      ret = Base.return_types(f, argtuple)
                      if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret)  && ret[1] == returntype
                          callback = @cfunction($f, Cvoid, 
                              (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode, UA_LocalizedText)) 
                          return callback
                      else
                          err = CallbackGeneratorArgumentError(f, argtuple, returntype)
                                                    throw(err)
                      end
                  end

                  """
```
UA_ClientAsyncReadWriteMaskAttributeCallback_generate(f::Function)
```
creates a `UA_ClientAsyncReadWriteMaskAttributeCallback` that can be supplied as callback argument to `UA_Client_readWriteMaskAttribute_async`.
The callback will be triggered once the read operation has been carried out.

`f` must be a Julia function with the following signature:
```f(client::Ptr{UA_Client}, userdata::Ptr{Cvoid}, requestid::UA_UInt32, 
    status::UA_StatusCode, writeMask)::UA_UInt32)::Nothing```
"""
function UA_ClientAsyncReadWriteMaskAttributeCallback_generate(f)
                      argtuple = (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode,
                          UA_UInt32)
                      returntype = Nothing
                      ret = Base.return_types(f, argtuple)
                      if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret)  && ret[1] == returntype
                          callback = @cfunction($f, Cvoid, 
                              (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode, UA_UInt32)) 
                          return callback
                      else
                          err = CallbackGeneratorArgumentError(f, argtuple, returntype)
                                                    throw(err)
                      end
                  end

                  """
```
UA_ClientAsyncReadUserWriteMaskAttributeCallback_generate(f::Function)
```
creates a `UA_ClientAsyncReadUserWriteMaskAttributeCallback` that can be supplied as callback argument to `UA_Client_readUserWriteMaskAttribute_async`.
The callback will be triggered once the read operation has been carried out.

`f` must be a Julia function with the following signature:
```f(client::Ptr{UA_Client}, userdata::Ptr{Cvoid}, requestid::UA_UInt32, 
    status::UA_StatusCode, userwritemask)::UA_UInt32)::Nothing```
"""
function UA_ClientAsyncReadUserWriteMaskAttributeCallback_generate(f)
                      argtuple = (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode,
                          UA_UInt32)
                      returntype = Nothing
                      ret = Base.return_types(f, argtuple)
                      if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret)  && ret[1] == returntype
                          callback = @cfunction($f, Cvoid, 
                              (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode, UA_UInt32)) 
                          return callback
                      else
                          err = CallbackGeneratorArgumentError(f, argtuple, returntype)
                                                    throw(err)
                      end
                  end

                  """
```
UA_ClientAsyncReadIsAbstractAttributeCallback_generate(f::Function)
```
creates a `UA_ClientAsyncReadIsAbstractAttributeCallback` that can be supplied as callback argument to `UA_Client_readIsAbstractAttribute_async`.
The callback will be triggered once the read operation has been carried out.

`f` must be a Julia function with the following signature:
```f(client::Ptr{UA_Client}, userdata::Ptr{Cvoid}, requestid::UA_UInt32, 
    status::UA_StatusCode, isabstract)::UA_Boolean)::Nothing```
"""
function UA_ClientAsyncReadIsAbstractAttributeCallback_generate(f)
                      argtuple = (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode,
                          UA_Boolean)
                      returntype = Nothing
                      ret = Base.return_types(f, argtuple)
                      if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret)  && ret[1] == returntype
                          callback = @cfunction($f, Cvoid, 
                              (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode, UA_Boolean)) 
                          return callback
                      else
                          err = CallbackGeneratorArgumentError(f, argtuple, returntype)
                                                    throw(err)
                      end
                  end

                  """
```
UA_ClientAsyncReadSymmetricAttributeCallback_generate(f::Function)
```
creates a `UA_ClientAsyncReadSymmetricAttributeCallback` that can be supplied as callback argument to `UA_Client_readSymmetricAttribute_async`.
The callback will be triggered once the read operation has been carried out.

`f` must be a Julia function with the following signature:
```f(client::Ptr{UA_Client}, userdata::Ptr{Cvoid}, requestid::UA_UInt32, 
    status::UA_StatusCode, symmetric)::UA_Boolean)::Nothing```
"""
function UA_ClientAsyncReadSymmetricAttributeCallback_generate(f)
                      argtuple = (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode,
                          UA_Boolean)
                      returntype = Nothing
                      ret = Base.return_types(f, argtuple)
                      if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret)  && ret[1] == returntype
                          callback = @cfunction($f, Cvoid, 
                              (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode, UA_Boolean)) 
                          return callback
                      else
                          err = CallbackGeneratorArgumentError(f, argtuple, returntype)
                                                    throw(err)
                      end
                  end

                  """
```
UA_ClientAsyncReadInverseNameAttributeCallback_generate(f::Function)
```
creates a `UA_ClientAsyncReadInverseNameAttributeCallback` that can be supplied as callback argument to `UA_Client_readInverseNameAttribute_async`.
The callback will be triggered once the read operation has been carried out.

`f` must be a Julia function with the following signature:
```f(client::Ptr{UA_Client}, userdata::Ptr{Cvoid}, requestid::UA_UInt32, 
    status::UA_StatusCode, inversename)::UA_LocalizedText)::Nothing```
"""
function UA_ClientAsyncReadInverseNameAttributeCallback_generate(f)
                      argtuple = (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode,
                          UA_LocalizedText)
                      returntype = Nothing
                      ret = Base.return_types(f, argtuple)
                      if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret)  && ret[1] == returntype
                          callback = @cfunction($f, Cvoid, 
                              (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode, UA_LocalizedText)) 
                          return callback
                      else
                          err = CallbackGeneratorArgumentError(f, argtuple, returntype)
                                                    throw(err)
                      end
                  end

                  """
```
UA_ClientAsyncReadContainsNoLoopsAttributeCallback_generate(f::Function)
```
creates a `UA_ClientAsyncReadContainsNoLoopsAttributeCallback` that can be supplied as callback argument to `UA_Client_readContainsNoLoopsAttribute_async`.
The callback will be triggered once the read operation has been carried out.

`f` must be a Julia function with the following signature:
```f(client::Ptr{UA_Client}, userdata::Ptr{Cvoid}, requestid::UA_UInt32, 
    status::UA_StatusCode, containsNoLoops)::UA_Boolean)::Nothing```
"""
function UA_ClientAsyncReadContainsNoLoopsAttributeCallback_generate(f)
                      argtuple = (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode,
                          UA_Boolean)
                      returntype = Nothing
                      ret = Base.return_types(f, argtuple)
                      if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret)  && ret[1] == returntype
                          callback = @cfunction($f, Cvoid, 
                              (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode, UA_Boolean)) 
                          return callback
                      else
                          err = CallbackGeneratorArgumentError(f, argtuple, returntype)
                                                    throw(err)
                      end
                  end

                  """
```
UA_ClientAsyncReadEventNotifierAttributeCallback_generate(f::Function)
```
creates a `UA_ClientAsyncReadEventNotifierAttributeCallback` that can be supplied as callback argument to `UA_Client_readEventNotifierAttribute_async`.
The callback will be triggered once the read operation has been carried out.

`f` must be a Julia function with the following signature:
```f(client::Ptr{UA_Client}, userdata::Ptr{Cvoid}, requestid::UA_UInt32, 
    status::UA_StatusCode, eventnotifier)::UA_Byte)::Nothing```
"""
function UA_ClientAsyncReadEventNotifierAttributeCallback_generate(f)
                      argtuple = (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode,
                          UA_Byte)
                      returntype = Nothing
                      ret = Base.return_types(f, argtuple)
                      if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret)  && ret[1] == returntype
                          callback = @cfunction($f, Cvoid, 
                              (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode, UA_Byte)) 
                          return callback
                      else
                          err = CallbackGeneratorArgumentError(f, argtuple, returntype)
                                                    throw(err)
                      end
                  end

                  """
```
UA_ClientAsyncReadValueRankAttributeCallback_generate(f::Function)
```
creates a `UA_ClientAsyncReadValueRankAttributeCallback` that can be supplied as callback argument to `UA_Client_readValueRankAttribute_async`.
The callback will be triggered once the read operation has been carried out.

`f` must be a Julia function with the following signature:
```f(client::Ptr{UA_Client}, userdata::Ptr{Cvoid}, requestid::UA_UInt32, 
    status::UA_StatusCode, valuerank)::UA_UInt32)::Nothing```
"""
function UA_ClientAsyncReadValueRankAttributeCallback_generate(f)
                      argtuple = (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode,
                          UA_UInt32)
                      returntype = Nothing
                      ret = Base.return_types(f, argtuple)
                      if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret)  && ret[1] == returntype
                          callback = @cfunction($f, Cvoid, 
                              (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode, UA_UInt32)) 
                          return callback
                      else
                          err = CallbackGeneratorArgumentError(f, argtuple, returntype)
                                                    throw(err)
                      end
                  end

                  """
```
UA_ClientAsyncReadAccessLevelAttributeCallback_generate(f::Function)
```
creates a `UA_ClientAsyncReadAccessLevelAttributeCallback` that can be supplied as callback argument to `UA_Client_readAccessLevelAttribute_async`.
The callback will be triggered once the read operation has been carried out.

`f` must be a Julia function with the following signature:
```f(client::Ptr{UA_Client}, userdata::Ptr{Cvoid}, requestid::UA_UInt32, 
    status::UA_StatusCode, accesslevel)::UA_Byte)::Nothing```
"""
function UA_ClientAsyncReadAccessLevelAttributeCallback_generate(f)
                      argtuple = (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode,
                          UA_Byte)
                      returntype = Nothing
                      ret = Base.return_types(f, argtuple)
                      if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret)  && ret[1] == returntype
                          callback = @cfunction($f, Cvoid, 
                              (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode, UA_Byte)) 
                          return callback
                      else
                          err = CallbackGeneratorArgumentError(f, argtuple, returntype)
                                                    throw(err)
                      end
                  end

                  """
```
UA_ClientAsyncReadUserAccessLevelAttributeCallback_generate(f::Function)
```
creates a `UA_ClientAsyncReadUserAccessLevelAttributeCallback` that can be supplied as callback argument to `UA_Client_readUserAccessLevelAttribute_async`.
The callback will be triggered once the read operation has been carried out.

`f` must be a Julia function with the following signature:
```f(client::Ptr{UA_Client}, userdata::Ptr{Cvoid}, requestid::UA_UInt32, 
    status::UA_StatusCode, useraccesslevel)::UA_Byte)::Nothing```
"""
function UA_ClientAsyncReadUserAccessLevelAttributeCallback_generate(f)
                      argtuple = (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode,
                          UA_Byte)
                      returntype = Nothing
                      ret = Base.return_types(f, argtuple)
                      if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret)  && ret[1] == returntype
                          callback = @cfunction($f, Cvoid, 
                              (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode, UA_Byte)) 
                          return callback
                      else
                          err = CallbackGeneratorArgumentError(f, argtuple, returntype)
                                                    throw(err)
                      end
                  end

                  """
```
UA_ClientAsyncReadMinimumSamplingIntervalAttributeCallback_generate(f::Function)
```
creates a `UA_ClientAsyncReadMinimumSamplingIntervalAttributeCallback` that can be supplied as callback argument to `UA_Client_readMinimumSamplingIntervalAttribute_async`.
The callback will be triggered once the read operation has been carried out.

`f` must be a Julia function with the following signature:
```f(client::Ptr{UA_Client}, userdata::Ptr{Cvoid}, requestid::UA_UInt32, 
    status::UA_StatusCode, minimumsamplinginterval)::UA_Double)::Nothing```
"""
function UA_ClientAsyncReadMinimumSamplingIntervalAttributeCallback_generate(f)
                      argtuple = (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode,
                          UA_Double)
                      returntype = Nothing
                      ret = Base.return_types(f, argtuple)
                      if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret)  && ret[1] == returntype
                          callback = @cfunction($f, Cvoid, 
                              (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode, UA_Double)) 
                          return callback
                      else
                          err = CallbackGeneratorArgumentError(f, argtuple, returntype)
                                                    throw(err)
                      end
                  end

                  """
```
UA_ClientAsyncReadHistorizingAttributeCallback_generate(f::Function)
```
creates a `UA_ClientAsyncReadHistorizingAttributeCallback` that can be supplied as callback argument to `UA_Client_readHistorizingAttribute_async`.
The callback will be triggered once the read operation has been carried out.

`f` must be a Julia function with the following signature:
```f(client::Ptr{UA_Client}, userdata::Ptr{Cvoid}, requestid::UA_UInt32, 
    status::UA_StatusCode, historizing)::UA_Boolean)::Nothing```
"""
function UA_ClientAsyncReadHistorizingAttributeCallback_generate(f)
                      argtuple = (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode,
                          UA_Boolean)
                      returntype = Nothing
                      ret = Base.return_types(f, argtuple)
                      if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret)  && ret[1] == returntype
                          callback = @cfunction($f, Cvoid, 
                              (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode, UA_Boolean)) 
                          return callback
                      else
                          err = CallbackGeneratorArgumentError(f, argtuple, returntype)
                                                    throw(err)
                      end
                  end

                  """
```
UA_ClientAsyncReadExecutableAttributeCallback_generate(f::Function)
```
creates a `UA_ClientAsyncReadExecutableAttributeCallback` that can be supplied as callback argument to `UA_Client_readExecutableAttribute_async`.
The callback will be triggered once the read operation has been carried out.

`f` must be a Julia function with the following signature:
```f(client::Ptr{UA_Client}, userdata::Ptr{Cvoid}, requestid::UA_UInt32, 
    status::UA_StatusCode, executable)::UA_Boolean)::Nothing```
"""
function UA_ClientAsyncReadExecutableAttributeCallback_generate(f)
                      argtuple = (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode,
                          UA_Boolean)
                      returntype = Nothing
                      ret = Base.return_types(f, argtuple)
                      if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret)  && ret[1] == returntype
                          callback = @cfunction($f, Cvoid, 
                              (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode, UA_Boolean)) 
                          return callback
                      else
                          err = CallbackGeneratorArgumentError(f, argtuple, returntype)
                                                    throw(err)
                      end
                  end

                  """
```
UA_ClientAsyncReadUserExecutableAttributeCallback_generate(f::Function)
```
creates a `UA_ClientAsyncReadUserExecutableAttributeCallback` that can be supplied as callback argument to `UA_Client_readUserExecutableAttribute_async`.
The callback will be triggered once the read operation has been carried out.

`f` must be a Julia function with the following signature:
```f(client::Ptr{UA_Client}, userdata::Ptr{Cvoid}, requestid::UA_UInt32, 
    status::UA_StatusCode, userexecutable)::UA_Boolean)::Nothing```
"""
function UA_ClientAsyncReadUserExecutableAttributeCallback_generate(f)
                      argtuple = (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode,
                          UA_Boolean)
                      returntype = Nothing
                      ret = Base.return_types(f, argtuple)
                      if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret)  && ret[1] == returntype
                          callback = @cfunction($f, Cvoid, 
                              (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode, UA_Boolean)) 
                          return callback
                      else
                          err = CallbackGeneratorArgumentError(f, argtuple, returntype)
                                                    throw(err)
                      end
                  end

                  