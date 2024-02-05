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

#TODO: Still to be implemented; the below is a list of all callbacks occurring in open62541.h (some are double); 
# They are not all equally important of course and will be implemented as needed over time.

# typedef void (*UA_Server_AsyncOperationNotifyCallback)(UA_Server *server);
# void (*monitoredItemRegisterCallback)(UA_Server *server,
#                                           const UA_NodeId *sessionId,
#                                           void *sessionContext,
#                                           const UA_NodeId *nodeId,
#                                           void *nodeContext,
#                                           UA_UInt32 attibuteId,
#                                           UA_Boolean removed);

#                                           (*UA_NodeIteratorCallback)(UA_NodeId childId, UA_Boolean isInverse,
#                                           UA_NodeId referenceTypeId, void *handle);
#                                           typedef void (*UA_Server_DataChangeNotificationCallback)
#                                           (UA_Server *server, UA_UInt32 monitoredItemId, void *monitoredItemContext,
#                                            const UA_NodeId *nodeId, void *nodeContext, UA_UInt32 attributeId,
#                                            const UA_DataValue *value);
                                      
#                                       typedef void (*UA_Server_EventNotificationCallback)
#                                           (UA_Server *server, UA_UInt32 monId, void *monContext,
#                                            size_t nEventFields, const UA_Variant *eventFields);      

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

# typedef struct {
#     /* Log a message. The message string and following varargs are formatted
#      * according to the rules of the printf command. Use the convenience macros
#      * below that take the minimum log level defined in ua_config.h into
#      * account. */
#     void (*log)(void *logContext, UA_LogLevel level, UA_LogCategory category,
#                 const char *msg, va_list args);

#     void *context; /* Logger state */

#     void (*clear)(void *context); /* Clean up the logger plugin */
# } UA_Logger;

# struct UA_Connection {
#     UA_ConnectionState state;
#     UA_SecureChannel *channel;     /* The securechannel that is attached to
#                                     * this connection */
#     UA_SOCKET sockfd;              /* Most connectivity solutions run on
#                                     * sockets. Having the socket id here
#                                     * simplifies the design. */
#     UA_DateTime openingDate;       /* The date the connection was created */
#     void *handle;                  /* A pointer to internal data */

#     /* Get a buffer for sending */
#     UA_StatusCode (*getSendBuffer)(UA_Connection *connection, size_t length,
#                                    UA_ByteString *buf);

#     /* Release the send buffer manually */
#     void (*releaseSendBuffer)(UA_Connection *connection, UA_ByteString *buf);

#     /* Sends a message over the connection. The message buffer is always freed,
#      * even if sending fails.
#      *
#      * @param connection The connection
#      * @param buf The message buffer
#      * @return Returns an error code or UA_STATUSCODE_GOOD. */
#     UA_StatusCode (*send)(UA_Connection *connection, UA_ByteString *buf);

#     /* Receive a message from the remote connection
#      *
#      * @param connection The connection

#      * @param response The response string. If this is empty, it will be
#      *        allocated by the connection and needs to be freed with
#      *        connection->releaseBuffer. If the response string is non-empty, it
#      *        will be used as the receive buffer. If bytes are received, the
#      *        length of the buffer is adjusted to match the length of the
#      *        received bytes.
#      * @param timeout Timeout of the recv operation in milliseconds
#      * @return Returns UA_STATUSCODE_BADCOMMUNICATIONERROR if the recv operation
#      *         can be repeated, UA_STATUSCODE_GOOD if it succeeded and
#      *         UA_STATUSCODE_BADCONNECTIONCLOSED if the connection was
#      *         closed. */
#     UA_StatusCode (*recv)(UA_Connection *connection, UA_ByteString *response,
#                           UA_UInt32 timeout);

#     /* Release the buffer of a received message */
#     void (*releaseRecvBuffer)(UA_Connection *connection, UA_ByteString *buf);

#     /* Close the connection. The network layer closes the socket. This is picked
#      * up during the next 'listen' and the connection is freed in the network
#      * layer. */
#     void (*close)(UA_Connection *connection);

#     /* To be called only from within the server (and not the network layer).
#      * Frees up the connection's memory. */
#     void (*free)(UA_Connection *connection);
# };

# struct UA_ServerNetworkLayer {
#     void *handle; /* Internal data */

#     /* Points to external memory, i.e. handled by server or client */
#     UA_NetworkStatistics *statistics;

#     UA_String discoveryUrl;

#     UA_ConnectionConfig localConnectionConfig;

#     /* Start listening on the network layer.
#      *
#      * @param nl The network layer
#      * @return Returns UA_STATUSCODE_GOOD or an error code. */
#     UA_StatusCode (*start)(UA_ServerNetworkLayer *nl, const UA_Logger *logger,
#                            const UA_String *customHostname);

#     /* Listen for new and closed connections and arriving packets. Calls
#      * UA_Server_processBinaryMessage for the arriving packets. Closed
#      * connections are picked up here and forwarded to
#      * UA_Server_removeConnection where they are cleaned up and freed.
#      *
#      * @param nl The network layer
#      * @param server The server for processing the incoming packets and for
#      *               closing connections.
#      * @param timeout The timeout during which an event must arrive in
#      *                milliseconds
#      * @return A statuscode for the status of the network layer. */
#     UA_StatusCode (*listen)(UA_ServerNetworkLayer *nl, UA_Server *server,
#                             UA_UInt16 timeout);

#     /* Close the network socket and all open connections. Afterwards, the
#      * network layer can be safely deleted.
#      *
#      * @param nl The network layer
#      * @param server The server that processes the incoming packets and for
#      *               closing connections before deleting them.
#      * @return A statuscode for the status of the closing operation. */
#     void (*stop)(UA_ServerNetworkLayer *nl, UA_Server *server);

#     /* Deletes the network layer context. Call only after stopping. */
#     void (*clear)(UA_ServerNetworkLayer *nl);
# };


# struct UA_AccessControl {
#     void *context;
#     void (*clear)(UA_AccessControl *ac);

#     /* Supported login mechanisms. The server endpoints are created from here. */
#     size_t userTokenPoliciesSize;
#     UA_UserTokenPolicy *userTokenPolicies;

#     /* Authenticate a session. The session context is attached to the session
#      * and later passed into the node-based access control callbacks. The new
#      * session is rejected if a StatusCode other than UA_STATUSCODE_GOOD is
#      * returned. */
#     UA_StatusCode (*activateSession)(UA_Server *server, UA_AccessControl *ac,
#                                      const UA_EndpointDescription *endpointDescription,
#                                      const UA_ByteString *secureChannelRemoteCertificate,
#                                      const UA_NodeId *sessionId,
#                                      const UA_ExtensionObject *userIdentityToken,
#                                      void **sessionContext);

#     /* Deauthenticate a session and cleanup */
#     void (*closeSession)(UA_Server *server, UA_AccessControl *ac,
#                          const UA_NodeId *sessionId, void *sessionContext);

#     /* Access control for all nodes*/
#     UA_UInt32 (*getUserRightsMask)(UA_Server *server, UA_AccessControl *ac,
#                                    const UA_NodeId *sessionId, void *sessionContext,
#                                    const UA_NodeId *nodeId, void *nodeContext);

#     /* Additional access control for variable nodes */
#     UA_Byte (*getUserAccessLevel)(UA_Server *server, UA_AccessControl *ac,
#                                   const UA_NodeId *sessionId, void *sessionContext,
#                                   const UA_NodeId *nodeId, void *nodeContext);

#     /* Additional access control for method nodes */
#     UA_Boolean (*getUserExecutable)(UA_Server *server, UA_AccessControl *ac,
#                                     const UA_NodeId *sessionId, void *sessionContext,
#                                     const UA_NodeId *methodId, void *methodContext);

#     /* Additional access control for calling a method node in the context of a
#      * specific object */
#     UA_Boolean (*getUserExecutableOnObject)(UA_Server *server, UA_AccessControl *ac,
#                                             const UA_NodeId *sessionId, void *sessionContext,
#                                             const UA_NodeId *methodId, void *methodContext,
#                                             const UA_NodeId *objectId, void *objectContext);

#     /* Allow adding a node */
#     UA_Boolean (*allowAddNode)(UA_Server *server, UA_AccessControl *ac,
#                                const UA_NodeId *sessionId, void *sessionContext,
#                                const UA_AddNodesItem *item);

#     /* Allow adding a reference */
#     UA_Boolean (*allowAddReference)(UA_Server *server, UA_AccessControl *ac,
#                                     const UA_NodeId *sessionId, void *sessionContext,
#                                     const UA_AddReferencesItem *item);

#     /* Allow deleting a node */
#     UA_Boolean (*allowDeleteNode)(UA_Server *server, UA_AccessControl *ac,
#                                   const UA_NodeId *sessionId, void *sessionContext,
#                                   const UA_DeleteNodesItem *item);

#     /* Allow deleting a reference */
#     UA_Boolean (*allowDeleteReference)(UA_Server *server, UA_AccessControl *ac,
#                                        const UA_NodeId *sessionId, void *sessionContext,
#                                        const UA_DeleteReferencesItem *item);

#     /* Allow browsing a node */
#     UA_Boolean (*allowBrowseNode)(UA_Server *server, UA_AccessControl *ac,
#                                   const UA_NodeId *sessionId, void *sessionContext,
#                                   const UA_NodeId *nodeId, void *nodeContext);

# #ifdef UA_ENABLE_SUBSCRIPTIONS
#     /* Allow transfer of a subscription to another session. The Server shall
#      * validate that the Client of that Session is operating on behalf of the
#      * same user */
#     UA_Boolean (*allowTransferSubscription)(UA_Server *server, UA_AccessControl *ac,
#                                             const UA_NodeId *oldSessionId, void *oldSessionContext,
#                                             const UA_NodeId *newSessionId, void *newSessionContext);
# #endif

# #ifdef UA_ENABLE_HISTORIZING
#     /* Allow insert,replace,update of historical data */
#     UA_Boolean (*allowHistoryUpdateUpdateData)(UA_Server *server, UA_AccessControl *ac,
#                                                const UA_NodeId *sessionId, void *sessionContext,
#                                                const UA_NodeId *nodeId,
#                                                UA_PerformUpdateType performInsertReplace,
#                                                const UA_DataValue *value);

#     /* Allow delete of historical data */
#     UA_Boolean (*allowHistoryUpdateDeleteRawModified)(UA_Server *server, UA_AccessControl *ac,
#                                                       const UA_NodeId *sessionId, void *sessionContext,
#                                                       const UA_NodeId *nodeId,
#                                                       UA_DateTime startTimestamp,
#                                                       UA_DateTime endTimestamp,
#                                                       bool isDeleteModified);
# #endif
# };


# struct UA_CertificateVerification {
#     void *context;

#     /* Verify the certificate against the configured policies and trust chain. */
#     UA_StatusCode (*verifyCertificate)(void *verificationContext,
#                                        const UA_ByteString *certificate);

#     /* Verify that the certificate has the applicationURI in the subject name. */
#     UA_StatusCode (*verifyApplicationURI)(void *verificationContext,
#                                           const UA_ByteString *certificate,
#                                           const UA_String *applicationURI);

#     /* Delete the certificate verification context */
#     void (*clear)(UA_CertificateVerification *cv);
# };

# typedef struct {
#     UA_String uri;

#     /* Verifies the signature of the message using the provided keys in the context.
#      *
#      * @param channelContext the channelContext that contains the key to verify
#      *                       the supplied message with.
#      * @param message the message to which the signature is supposed to belong.
#      * @param signature the signature of the message, that should be verified. */
#     UA_StatusCode (*verify)(void *channelContext, const UA_ByteString *message,
#                             const UA_ByteString *signature) UA_FUNC_ATTR_WARN_UNUSED_RESULT;

#     /* Signs the given message using this policys signing algorithm and the
#      * provided keys in the context.
#      *
#      * @param channelContext the channelContext that contains the key to sign
#      *                       the supplied message with.
#      * @param message the message to sign.
#      * @param signature an output buffer to which the signature is written. The
#      *                  buffer needs to be allocated by the caller. The
#      *                  necessary size can be acquired with the signatureSize
#      *                  attribute of this module. */
#     UA_StatusCode (*sign)(void *channelContext, const UA_ByteString *message,
#                           UA_ByteString *signature) UA_FUNC_ATTR_WARN_UNUSED_RESULT;

#     /* Gets the signature size that depends on the local (private) key.
#      *
#      * @param channelContext the channelContext that contains the
#      *                       certificate/key.
#      * @return the size of the local signature. Returns 0 if no local
#      *         certificate was set. */
#     size_t (*getLocalSignatureSize)(const void *channelContext);

#     /* Gets the signature size that depends on the remote (public) key.
#      *
#      * @param channelContext the context to retrieve data from.
#      * @return the size of the remote signature. Returns 0 if no
#      *         remote certificate was set previousely. */
#     size_t (*getRemoteSignatureSize)(const void *channelContext);

#     /* Gets the local signing key length.
#      *
#      * @param channelContext the context to retrieve data from.
#      * @return the length of the signing key in bytes. Returns 0 if no length can be found.
#      */
#     size_t (*getLocalKeyLength)(const void *channelContext);

#     /* Gets the local signing key length.
#      *
#      * @param channelContext the context to retrieve data from.
#      * @return the length of the signing key in bytes. Returns 0 if no length can be found.
#      */
#     size_t (*getRemoteKeyLength)(const void *channelContext);
# } UA_SecurityPolicySignatureAlgorithm;

# typedef struct {
#     UA_String uri;

#     /* Encrypt the given data in place. For asymmetric encryption, the block
#      * size for plaintext and cypher depend on the remote key (certificate).
#      *
#      * @param channelContext the channelContext which contains information about
#      *                       the keys to encrypt data.
#      * @param data the data that is encrypted. The encrypted data will overwrite
#      *             the data that was supplied. */
#     UA_StatusCode (*encrypt)(void *channelContext,
#                              UA_ByteString *data) UA_FUNC_ATTR_WARN_UNUSED_RESULT;

#     /* Decrypts the given ciphertext in place. For asymmetric encryption, the
#      * block size for plaintext and cypher depend on the local private key.
#      *
#      * @param channelContext the channelContext which contains information about
#      *                       the keys needed to decrypt the message.
#      * @param data the data to decrypt. The decryption is done in place. */
#     UA_StatusCode (*decrypt)(void *channelContext,
#                              UA_ByteString *data) UA_FUNC_ATTR_WARN_UNUSED_RESULT;

#     /* Returns the length of the key used to encrypt messages in bits. For
#      * asymmetric encryption the key length is for the local private key.
#      *
#      * @param channelContext the context to retrieve data from.
#      * @return the length of the local key. Returns 0 if no
#      *         key length is known. */
#     size_t (*getLocalKeyLength)(const void *channelContext);

#     /* Returns the length of the key to encrypt messages in bits. Depends on the
#      * key (certificate) from the remote side.
#      *
#      * @param channelContext the context to retrieve data from.
#      * @return the length of the remote key. Returns 0 if no
#      *         key length is known. */
#     size_t (*getRemoteKeyLength)(const void *channelContext);

#     /* Returns the size of encrypted blocks for sending. For asymmetric
#      * encryption this depends on the remote key (certificate). For symmetric
#      * encryption the local and remote encrypted block size are identical.
#      *
#      * @param channelContext the context to retrieve data from.
#      * @return the size of encrypted blocks in bytes. Returns 0 if no key length is known.
#      */
#     size_t (*getRemoteBlockSize)(const void *channelContext);

#     /* Returns the size of plaintext blocks for sending. For asymmetric
#      * encryption this depends on the remote key (certificate). For symmetric
#      * encryption the local and remote plaintext block size are identical.
#      *
#      * @param channelContext the context to retrieve data from.
#      * @return the size of plaintext blocks in bytes. Returns 0 if no key length is known.
#      */
#     size_t (*getRemotePlainTextBlockSize)(const void *channelContext);
# } UA_SecurityPolicyEncryptionAlgorithm;


# typedef struct {
#     /* Generates a thumbprint for the specified certificate.
#      *
#      * @param certificate the certificate to make a thumbprint of.
#      * @param thumbprint an output buffer for the resulting thumbprint. Always
#      *                   has the length specified in the thumbprintLength in the
#      *                   asymmetricModule. */
#     UA_StatusCode (*makeCertificateThumbprint)(const UA_SecurityPolicy *securityPolicy,
#                                                const UA_ByteString *certificate,
#                                                UA_ByteString *thumbprint)
#     UA_FUNC_ATTR_WARN_UNUSED_RESULT;

#     /* Compares the supplied certificate with the certificate in the endpoint context.
#      *
#      * @param securityPolicy the policy data that contains the certificate
#      *                       to compare to.
#      * @param certificateThumbprint the certificate thumbprint to compare to the
#      *                              one stored in the context.
#      * @return if the thumbprints match UA_STATUSCODE_GOOD is returned. If they
#      *         don't match or an error occurred an error code is returned. */
#     UA_StatusCode (*compareCertificateThumbprint)(const UA_SecurityPolicy *securityPolicy,
#                                                   const UA_ByteString *certificateThumbprint)
#     UA_FUNC_ATTR_WARN_UNUSED_RESULT;

#     UA_SecurityPolicyCryptoModule cryptoModule;
# } UA_SecurityPolicyAsymmetricModule;


# typedef struct {
#     /* Pseudo random function that is used to generate the symmetric keys.
#      *
#      * For information on what parameters this function receives in what situation,
#      * refer to the OPC UA specification 1.03 Part6 Table 33
#      *
#      * @param policyContext The context of the policy instance
#      * @param secret
#      * @param seed
#      * @param out an output to write the data to. The length defines the maximum
#      *            number of output bytes that are produced. */
#     UA_StatusCode (*generateKey)(void *policyContext, const UA_ByteString *secret,
#                                  const UA_ByteString *seed, UA_ByteString *out)
#     UA_FUNC_ATTR_WARN_UNUSED_RESULT;

#     /* Random generator for generating nonces.
#      *
#      * @param policyContext The context of the policy instance
#      * @param out pointer to a buffer to store the nonce in. Needs to be
#      *            allocated by the caller. The buffer is filled with random
#      *            data. */
#     UA_StatusCode (*generateNonce)(void *policyContext, UA_ByteString *out)
#     UA_FUNC_ATTR_WARN_UNUSED_RESULT;

#     /*
#      * The length of the nonce used in the SecureChannel as specified in the standard.
#      */
#     size_t secureChannelNonceLength;

#     UA_SecurityPolicyCryptoModule cryptoModule;
# } UA_SecurityPolicySymmetricModule;

# typedef struct {
#     /* This method creates a new context data object.
#      *
#      * The caller needs to call delete on the received object to free allocated
#      * memory. Memory is only allocated if the function succeeds so there is no
#      * need to manually free the memory pointed to by *channelContext or to
#      * call delete in case of failure.
#      *
#      * @param securityPolicy the policy context of the endpoint that is connected
#      *                       to. It will be stored in the channelContext for
#      *                       further access by the policy.
#      * @param remoteCertificate the remote certificate contains the remote
#      *                          asymmetric key. The certificate will be verified
#      *                          and then stored in the context so that its
#      *                          details may be accessed.
#      * @param channelContext the initialized channelContext that is passed to
#      *                       functions that work on a context. */
#     UA_StatusCode (*newContext)(const UA_SecurityPolicy *securityPolicy,
#                                 const UA_ByteString *remoteCertificate,
#                                 void **channelContext)
#     UA_FUNC_ATTR_WARN_UNUSED_RESULT;

#     /* Deletes the the security context. */
#     void (*deleteContext)(void *channelContext);

#     /* Sets the local encrypting key in the supplied context.
#      *
#      * @param channelContext the context to work on.
#      * @param key the local encrypting key to store in the context. */
#     UA_StatusCode (*setLocalSymEncryptingKey)(void *channelContext,
#                                               const UA_ByteString *key)
#     UA_FUNC_ATTR_WARN_UNUSED_RESULT;

#     /* Sets the local signing key in the supplied context.
#      *
#      * @param channelContext the context to work on.
#      * @param key the local signing key to store in the context. */
#     UA_StatusCode (*setLocalSymSigningKey)(void *channelContext,
#                                            const UA_ByteString *key)
#     UA_FUNC_ATTR_WARN_UNUSED_RESULT;

#     /* Sets the local initialization vector in the supplied context.
#      *
#      * @param channelContext the context to work on.
#      * @param iv the local initialization vector to store in the context. */
#     UA_StatusCode (*setLocalSymIv)(void *channelContext,
#                                    const UA_ByteString *iv)
#     UA_FUNC_ATTR_WARN_UNUSED_RESULT;

#     /* Sets the remote encrypting key in the supplied context.
#      *
#      * @param channelContext the context to work on.
#      * @param key the remote encrypting key to store in the context. */
#     UA_StatusCode (*setRemoteSymEncryptingKey)(void *channelContext,
#                                                const UA_ByteString *key)
#     UA_FUNC_ATTR_WARN_UNUSED_RESULT;

#     /* Sets the remote signing key in the supplied context.
#      *
#      * @param channelContext the context to work on.
#      * @param key the remote signing key to store in the context. */
#     UA_StatusCode (*setRemoteSymSigningKey)(void *channelContext,
#                                             const UA_ByteString *key)
#     UA_FUNC_ATTR_WARN_UNUSED_RESULT;

#     /* Sets the remote initialization vector in the supplied context.
#      *
#      * @param channelContext the context to work on.
#      * @param iv the remote initialization vector to store in the context. */
#     UA_StatusCode (*setRemoteSymIv)(void *channelContext,
#                                     const UA_ByteString *iv)
#     UA_FUNC_ATTR_WARN_UNUSED_RESULT;

#     /* Compares the supplied certificate with the certificate in the channel
#      * context.
#      *
#      * @param channelContext the channel context data that contains the
#      *                       certificate to compare to.
#      * @param certificate the certificate to compare to the one stored in the context.
#      * @return if the certificates match UA_STATUSCODE_GOOD is returned. If they
#      *         don't match or an errror occurred an error code is returned. */
#     UA_StatusCode (*compareCertificate)(const void *channelContext,
#                                         const UA_ByteString *certificate)
#     UA_FUNC_ATTR_WARN_UNUSED_RESULT;
# } UA_SecurityPolicyChannelModule;

# struct UA_SecurityPolicy {
#     /* Additional data */
#     void *policyContext;

#     /* The policy uri that identifies the implemented algorithms */
#     UA_String policyUri;

#     /* The local certificate is specific for each SecurityPolicy since it
#      * depends on the used key length. */
#     UA_ByteString localCertificate;

#     /* Function pointers grouped into modules */
#     UA_SecurityPolicyAsymmetricModule asymmetricModule;
#     UA_SecurityPolicySymmetricModule symmetricModule;
#     UA_SecurityPolicySignatureAlgorithm certificateSigningAlgorithm;
#     UA_SecurityPolicyChannelModule channelModule;

#     const UA_Logger *logger;

#     /* Updates the ApplicationInstanceCertificate and the corresponding private
#      * key at runtime. */
#     UA_StatusCode (*updateCertificateAndPrivateKey)(UA_SecurityPolicy *policy,
#                                                     const UA_ByteString newCertificate,
#                                                     const UA_ByteString newPrivateKey);

#     /* Deletes the dynamic content of the policy */
#     void (*clear)(UA_SecurityPolicy *policy);
# };

# typedef struct {
#     /* Can be NULL. May replace the nodeContext */
#     UA_StatusCode (*constructor)(UA_Server *server,
#                                  const UA_NodeId *sessionId, void *sessionContext,
#                                  const UA_NodeId *nodeId, void **nodeContext);

#     /* Can be NULL. The context cannot be replaced since the node is destroyed
#      * immediately afterwards anyway. */
#     void (*destructor)(UA_Server *server,
#                        const UA_NodeId *sessionId, void *sessionContext,
#                        const UA_NodeId *nodeId, void *nodeContext);

#     /* Can be NULL. Called during recursive node instantiation. While mandatory
#      * child nodes are automatically created if not already present, optional child
#      * nodes are not. This callback can be used to define whether an optional child
#      * node should be created.
#      *
#      * @param server The server executing the callback
#      * @param sessionId The identifier of the session
#      * @param sessionContext Additional data attached to the session in the
#      *        access control layer
#      * @param sourceNodeId Source node from the type definition. If the new node
#      *        shall be created, it will be a copy of this node.
#      * @param targetParentNodeId Parent of the potential new child node
#      * @param referenceTypeId Identifies the reference type which that the parent
#      *        node has to the new node.
#      * @return Return UA_TRUE if the child node shall be instantiated,
#      *         UA_FALSE otherwise. */
#     UA_Boolean (*createOptionalChild)(UA_Server *server,
#                                       const UA_NodeId *sessionId,
#                                       void *sessionContext,
#                                       const UA_NodeId *sourceNodeId,
#                                       const UA_NodeId *targetParentNodeId,
#                                       const UA_NodeId *referenceTypeId);

#     /* Can be NULL. Called when a node is to be copied during recursive
#      * node instantiation. Allows definition of the NodeId for the new node.
#      * If the callback is set to NULL or the resulting NodeId is UA_NODEID_NUMERIC(X,0)
#      * an unused nodeid in namespace X will be used. E.g. passing UA_NODEID_NULL will
#      * result in a NodeId in namespace 0.
#      *
#      * @param server The server executing the callback
#      * @param sessionId The identifier of the session
#      * @param sessionContext Additional data attached to the session in the
#      *        access control layer
#      * @param sourceNodeId Source node of the copy operation
#      * @param targetParentNodeId Parent node of the new node
#      * @param referenceTypeId Identifies the reference type which that the parent
#      *        node has to the new node. */
#     UA_StatusCode (*generateChildNodeId)(UA_Server *server,
#                                          const UA_NodeId *sessionId, void *sessionContext,
#                                          const UA_NodeId *sourceNodeId,
#                                          const UA_NodeId *targetParentNodeId,
#                                          const UA_NodeId *referenceTypeId,
#                                          UA_NodeId *targetNodeId);
# } UA_GlobalNodeLifecycle;

# /**
#  * Node Type Lifecycle
#  * ~~~~~~~~~~~~~~~~~~~
#  * Constructor and destructors for specific object and variable types. */
# typedef struct {
#     /* Can be NULL. May replace the nodeContext */
#     UA_StatusCode (*constructor)(UA_Server *server,
#                                  const UA_NodeId *sessionId, void *sessionContext,
#                                  const UA_NodeId *typeNodeId, void *typeNodeContext,
#                                  const UA_NodeId *nodeId, void **nodeContext);

#     /* Can be NULL. May replace the nodeContext. */
#     void (*destructor)(UA_Server *server,
#                        const UA_NodeId *sessionId, void *sessionContext,
#                        const UA_NodeId *typeNodeId, void *typeNodeContext,
#                        const UA_NodeId *nodeId, void **nodeContext);
# } UA_NodeTypeLifecycle;

# /**
#  * .. _value-callback:
#  *
#  * Value Callback
#  * ~~~~~~~~~~~~~~
#  * Value Callbacks can be attached to variable and variable type nodes. If
#  * not ``NULL``, they are called before reading and after writing respectively. */
# typedef struct {
#     /* Called before the value attribute is read. The external value source can be
#      * be updated and/or locked during this notification call. After this function returns
#      * to the core, the external value source is readed immediately.
#     */
#     UA_StatusCode (*notificationRead)(UA_Server *server, const UA_NodeId *sessionId,
#                                       void *sessionContext, const UA_NodeId *nodeid,
#                                       void *nodeContext, const UA_NumericRange *range);

#     /* Called after writing the value attribute. The node is re-opened after
#      * writing so that the new value is visible in the callback.
#      *
#      * @param server The server executing the callback
#      * @sessionId The identifier of the session
#      * @sessionContext Additional data attached to the session
#      *                 in the access control layer
#      * @param nodeid The identifier of the node.
#      * @param nodeUserContext Additional data attached to the node by
#      *        the user.
#      * @param nodeConstructorContext Additional data attached to the node
#      *        by the type constructor(s).
#      * @param range Points to the numeric range the client wants to write to (or
#      *        NULL). */
#     UA_StatusCode (*userWrite)(UA_Server *server, const UA_NodeId *sessionId,
#                                void *sessionContext, const UA_NodeId *nodeId,
#                                void *nodeContext, const UA_NumericRange *range,
#                                const UA_DataValue *data);
# } UA_ExternalValueCallback;

# typedef struct {
#     /* Nodestore context and lifecycle */
#     void *context;
#     void (*clear)(void *nsCtx);

#     /* The following definitions are used to create empty nodes of the different
#      * node types. The memory is managed by the nodestore. Therefore, the node
#      * has to be removed via a special deleteNode function. (If the new node is
#      * not added to the nodestore.) */
#     UA_Node * (*newNode)(void *nsCtx, UA_NodeClass nodeClass);

#     void (*deleteNode)(void *nsCtx, UA_Node *node);

#     /* ``Get`` returns a pointer to an immutable node. ``Release`` indicates
#      * that the pointer is no longer accessed afterwards. */
#     const UA_Node * (*getNode)(void *nsCtx, const UA_NodeId *nodeId);

#     void (*releaseNode)(void *nsCtx, const UA_Node *node);

#     /* Returns an editable copy of a node (needs to be deleted with the
#      * deleteNode function or inserted / replaced into the nodestore). */
#     UA_StatusCode (*getNodeCopy)(void *nsCtx, const UA_NodeId *nodeId,
#                                  UA_Node **outNode);

#     /* Inserts a new node into the nodestore. If the NodeId is zero, then a
#      * fresh numeric NodeId is assigned. If insertion fails, the node is
#      * deleted. */
#     UA_StatusCode (*insertNode)(void *nsCtx, UA_Node *node,
#                                 UA_NodeId *addedNodeId);

#     /* To replace a node, get an editable copy of the node, edit and replace
#      * with this function. If the node was already replaced since the copy was
#      * made, UA_STATUSCODE_BADINTERNALERROR is returned. If the NodeId is not
#      * found, UA_STATUSCODE_BADNODEIDUNKNOWN is returned. In both error cases,
#      * the editable node is deleted. */
#     UA_StatusCode (*replaceNode)(void *nsCtx, UA_Node *node);

#     /* Removes a node from the nodestore. */
#     UA_StatusCode (*removeNode)(void *nsCtx, const UA_NodeId *nodeId);

#     /* Maps the ReferenceTypeIndex used for the references to the NodeId of the
#      * ReferenceType. The returned pointer is stable until the Nodestore is
#      * deleted. */
#     const UA_NodeId * (*getReferenceTypeId)(void *nsCtx, UA_Byte refTypeIndex);

#     /* Execute a callback for every node in the nodestore. */
#     void (*iterate)(void *nsCtx, UA_NodestoreVisitor visitor,
#                     void *visitorCtx);
# } UA_Nodestore;

# struct UA_HistoryDatabase {
#     void *context;

#     void (*clear)(UA_HistoryDatabase *hdb);

#     /* This function will be called when a nodes value is set.
#      * Use this to insert data into your database(s) if polling is not suitable
#      * and you need to get all data changes.
#      * Set it to NULL if you do not need it.
#      *
#      * server is the server this node lives in.
#      * hdbContext is the context of the UA_HistoryDatabase.
#      * sessionId and sessionContext identify the session which set this value.
#      * nodeId is the node id for which data was set.
#      * historizing is the nodes boolean flag for historizing
#      * value is the new value. */
#     void
#     (*setValue)(UA_Server *server,
#                 void *hdbContext,
#                 const UA_NodeId *sessionId,
#                 void *sessionContext,
#                 const UA_NodeId *nodeId,
#                 UA_Boolean historizing,
#                 const UA_DataValue *value);

#     /* This function will be called when an event is triggered.
#      * Use it to insert data into your event database.
#      * No default implementation is provided by UA_HistoryDatabase_default.
#      *
#      * server is the server this node lives in.
#      * hdbContext is the context of the UA_HistoryDatabase.
#      * originId is the node id of the event's origin.
#      * emitterId is the node id of the event emitter.
#      * historicalEventFilter is the value of the HistoricalEventFilter property of
#      *                       the emitter (OPC UA Part 11, 5.3.2), it is NULL if
#      *                       the property does not exist or is not set.
#      * fieldList is the event field list returned after application of
#      *           historicalEventFilter to the event node. */
#     void
#     (*setEvent)(UA_Server *server,
#                 void *hdbContext,
#                 const UA_NodeId *originId,
#                 const UA_NodeId *emitterId,
#                 const UA_EventFilter *historicalEventFilter,
#                 UA_EventFieldList *fieldList);

#     /* This function is called if a history read is requested with
#      * isRawReadModified set to false. Setting it to NULL will result in a
#      * response with statuscode UA_STATUSCODE_BADHISTORYOPERATIONUNSUPPORTED.
#      *
#      * server is the server this node lives in.
#      * hdbContext is the context of the UA_HistoryDatabase.
#      * sessionId and sessionContext identify the session which set this value.
#      * requestHeader, historyReadDetails, timestampsToReturn, releaseContinuationPoints
#      * nodesToReadSize and nodesToRead is the requested data from the client. It
#      *                 is from the request object.
#      * response the response to fill for the client. If the request is ok, there
#      *          is no need to use it. Use this to set status codes other than
#      *          "Good" or other data. You find an already allocated
#      *          UA_HistoryReadResult array with an UA_HistoryData object in the
#      *          extension object in the size of nodesToReadSize. If you are not
#      *          willing to return data, you have to delete the results array,
#      *          set it to NULL and set the resultsSize to 0. Do not access
#      *          historyData after that.
#      * historyData is a proper typed pointer array pointing in the
#      *             UA_HistoryReadResult extension object. use this to provide
#      *             result data to the client. Index in the array is the same as
#      *             in nodesToRead and the UA_HistoryReadResult array. */
#     void
#     (*readRaw)(UA_Server *server,
#                void *hdbContext,
#                const UA_NodeId *sessionId,
#                void *sessionContext,
#                const UA_RequestHeader *requestHeader,
#                const UA_ReadRawModifiedDetails *historyReadDetails,
#                UA_TimestampsToReturn timestampsToReturn,
#                UA_Boolean releaseContinuationPoints,
#                size_t nodesToReadSize,
#                const UA_HistoryReadValueId *nodesToRead,
#                UA_HistoryReadResponse *response,
#                UA_HistoryData * const * const historyData);

#     /* No default implementation is provided by UA_HistoryDatabase_default
#      * for the following function */
#     void
#     (*readModified)(UA_Server *server,
#                void *hdbContext,
#                const UA_NodeId *sessionId,
#                void *sessionContext,
#                const UA_RequestHeader *requestHeader,
#                const UA_ReadRawModifiedDetails *historyReadDetails,
#                UA_TimestampsToReturn timestampsToReturn,
#                UA_Boolean releaseContinuationPoints,
#                size_t nodesToReadSize,
#                const UA_HistoryReadValueId *nodesToRead,
#                UA_HistoryReadResponse *response,
#                UA_HistoryModifiedData * const * const historyData);

#     /* No default implementation is provided by UA_HistoryDatabase_default
#      * for the following function */
#     void
#     (*readEvent)(UA_Server *server,
#                void *hdbContext,
#                const UA_NodeId *sessionId,
#                void *sessionContext,
#                const UA_RequestHeader *requestHeader,
#                const UA_ReadEventDetails *historyReadDetails,
#                UA_TimestampsToReturn timestampsToReturn,
#                UA_Boolean releaseContinuationPoints,
#                size_t nodesToReadSize,
#                const UA_HistoryReadValueId *nodesToRead,
#                UA_HistoryReadResponse *response,
#                UA_HistoryEvent * const * const historyData);

#     /* No default implementation is provided by UA_HistoryDatabase_default
#      * for the following function */
#     void
#     (*readProcessed)(UA_Server *server,
#                void *hdbContext,
#                const UA_NodeId *sessionId,
#                void *sessionContext,
#                const UA_RequestHeader *requestHeader,
#                const UA_ReadProcessedDetails *historyReadDetails,
#                UA_TimestampsToReturn timestampsToReturn,
#                UA_Boolean releaseContinuationPoints,
#                size_t nodesToReadSize,
#                const UA_HistoryReadValueId *nodesToRead,
#                UA_HistoryReadResponse *response,
#                UA_HistoryData * const * const historyData);

#     /* No default implementation is provided by UA_HistoryDatabase_default
#      * for the following function */
#     void
#     (*readAtTime)(UA_Server *server,
#                void *hdbContext,
#                const UA_NodeId *sessionId,
#                void *sessionContext,
#                const UA_RequestHeader *requestHeader,
#                const UA_ReadAtTimeDetails *historyReadDetails,
#                UA_TimestampsToReturn timestampsToReturn,
#                UA_Boolean releaseContinuationPoints,
#                size_t nodesToReadSize,
#                const UA_HistoryReadValueId *nodesToRead,
#                UA_HistoryReadResponse *response,
#                UA_HistoryData * const * const historyData);

#     void
#     (*updateData)(UA_Server *server,
#                   void *hdbContext,
#                   const UA_NodeId *sessionId,
#                   void *sessionContext,
#                   const UA_RequestHeader *requestHeader,
#                   const UA_UpdateDataDetails *details,
#                   UA_HistoryUpdateResult *result);

#     void
#     (*deleteRawModified)(UA_Server *server,
#                          void *hdbContext,
#                          const UA_NodeId *sessionId,
#                          void *sessionContext,
#                          const UA_RequestHeader *requestHeader,
#                          const UA_DeleteRawModifiedDetails *details,
#                          UA_HistoryUpdateResult *result);

#     /* Add more function pointer here.
#      * For example for read_event, read_annotation, update_details */
# };

# typedef struct {
#     void *clientContext; /* User-defined pointer attached to the client */
#     UA_Logger logger;    /* Logger used by the client */
#     UA_UInt32 timeout;   /* Response timeout in ms */

#     /* The description must be internally consistent.
#      * - The ApplicationUri set in the ApplicationDescription must match the
#      *   URI set in the certificate */
#     UA_ApplicationDescription clientDescription;

#     /**
#      * Connection configuration
#      * ~~~~~~~~~~~~~~~~~~~~~~~~
#      *
#      * The following configuration elements reduce the "degrees of freedom" the
#      * client has when connecting to a server. If no connection can be made
#      * under these restrictions, then the connection will abort with an error
#      * message. */
#     UA_ExtensionObject userIdentityToken; /* Configured User-Identity Token */
#     UA_MessageSecurityMode securityMode;  /* None, Sign, SignAndEncrypt. The
#                                            * default is invalid. This indicates
#                                            * the client to select any matching
#                                            * endpoint. */
#     UA_String securityPolicyUri; /* SecurityPolicy for the SecureChannel. An
#                                   * empty string indicates the client to select
#                                   * any matching SecurityPolicy. */

#     /**
#      * If either endpoint or userTokenPolicy has been set (at least one non-zero
#      * byte in either structure), then the selected Endpoint and UserTokenPolicy
#      * overwrite the settings in the basic connection configuration. The
#      * userTokenPolicy array in the EndpointDescription is ignored. The selected
#      * userTokenPolicy is set in the dedicated configuration field.
#      *
#      * If the advanced configuration is not set, the client will write to it the
#      * selected Endpoint and UserTokenPolicy during GetEndpoints.
#      *
#      * The information in the advanced configuration is used during reconnect
#      * when the SecureChannel was broken. */
#     UA_EndpointDescription endpoint;
#     UA_UserTokenPolicy userTokenPolicy;

#     /**
#      * If the EndpointDescription has not been defined, the ApplicationURI
#      * constrains the servers considered in the FindServers service and the
#      * Endpoints considered in the GetEndpoints service.
#      *
#      * If empty the applicationURI is not used to filter.
#      */
#     UA_String applicationUri;

#     /**
#      * Custom Data Types
#      * ~~~~~~~~~~~~~~~~~
#      * The following is a linked list of arrays with custom data types. All data
#      * types that are accessible from here are automatically considered for the
#      * decoding of received messages. Custom data types are not cleaned up
#      * together with the configuration. So it is possible to allocate them on
#      * ROM.
#      *
#      * See the section on :ref:`generic-types`. Examples for working with custom
#      * data types are provided in ``/examples/custom_datatype/``. */
#     const UA_DataTypeArray *customDataTypes;

#     /**
#      * Advanced Client Configuration
#      * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

#     UA_UInt32 secureChannelLifeTime; /* Lifetime in ms (then the channel needs
#                                         to be renewed) */
#     UA_UInt32 requestedSessionTimeout; /* Session timeout in ms */
#     UA_ConnectionConfig localConnectionConfig;
#     UA_UInt32 connectivityCheckInterval;     /* Connectivity check interval in ms.
#                                               * 0 = background task disabled */
#     /* Available SecurityPolicies */
#     size_t securityPoliciesSize;
#     UA_SecurityPolicy *securityPolicies;

#     /* Certificate Verification Plugin */
#     UA_CertificateVerification certificateVerification;

#     /* Callbacks for async connection handshakes */
#     UA_ConnectClientConnection initConnectionFunc;
#     UA_StatusCode (*pollConnectionFunc)(UA_Connection *connection,
#                                         UA_UInt32 timeout,
#                                         const UA_Logger *logger);

#     /* Callback for state changes. The client state is differentated into the
#      * SecureChannel state and the Session state. The connectStatus is set if
#      * the client connection (including reconnects) has failed and the client
#      * has to "give up". If the connectStatus is not set, the client still has
#      * hope to connect or recover. */
#     void (*stateCallback)(UA_Client *client,
#                           UA_SecureChannelState channelState,
#                           UA_SessionState sessionState,
#                           UA_StatusCode connectStatus);

#     /* When connectivityCheckInterval is greater than 0, every
#      * connectivityCheckInterval (in ms), an async read request is performed on
#      * the server. inactivityCallback is called when the client receive no
#      * response for this read request The connection can be closed, this in an
#      * attempt to recreate a healthy connection. */
#     void (*inactivityCallback)(UA_Client *client);

# #ifdef UA_ENABLE_SUBSCRIPTIONS
#     /* Number of PublishResponse queued up in the server */
#     UA_UInt16 outStandingPublishRequests;

#     /* If the client does not receive a PublishResponse after the defined delay
#      * of ``(sub->publishingInterval * sub->maxKeepAliveCount) +
#      * client->config.timeout)``, then subscriptionInactivityCallback is called
#      * for the subscription.. */
#     void (*subscriptionInactivityCallback)(UA_Client *client,
#                                            UA_UInt32 subscriptionId,
#                                            void *subContext);
# #endif

#     UA_LocaleId *sessionLocaleIds;
#     size_t sessionLocaleIdsSize;
# } UA_ClientConfig;

# typedef void (*UA_ClientAsyncServiceCallback)(UA_Client *client, void *userdata,
#                                               UA_UInt32 requestId, void *response);

# typedef UA_Boolean
# (*UA_HistoricalIteratorCallback)(UA_Client *client,
#     const UA_NodeId *nodeId,
#     UA_Boolean moreDataAvailable,
#     const UA_ExtensionObject *data, void *callbackContext);

#     typedef void (*UA_Client_DeleteSubscriptionCallback)
#     (UA_Client *client, UA_UInt32 subId, void *subContext);

# typedef void (*UA_Client_StatusChangeNotificationCallback)
#     (UA_Client *client, UA_UInt32 subId, void *subContext,
#      UA_StatusChangeNotification *notification);

#      /**
#  * The clientHandle parameter cannot be set by the user, any value will be replaced
#  * by the client before sending the request to the server. */

# /* Callback for the deletion of a MonitoredItem */
# typedef void (*UA_Client_DeleteMonitoredItemCallback)
#     (UA_Client *client, UA_UInt32 subId, void *subContext,
#      UA_UInt32 monId, void *monContext);

# /* Callback for DataChange notifications */
# typedef void (*UA_Client_DataChangeNotificationCallback)
#     (UA_Client *client, UA_UInt32 subId, void *subContext,
#      UA_UInt32 monId, void *monContext,
#      UA_DataValue *value);

# /* Callback for Event notifications */
# typedef void (*UA_Client_EventNotificationCallback)
#     (UA_Client *client, UA_UInt32 subId, void *subContext,
#      UA_UInt32 monId, void *monContext,
#      size_t nEventFields, UA_Variant *eventFields);

#      typedef void (*UA_ClientAsyncReadCallback)(UA_Client *client, void *userdata,
#      UA_UInt32 requestId, UA_ReadResponse *rr);

#      typedef void (*UA_ClientAsyncWriteCallback)(UA_Client *client, void *userdata,
#      UA_UInt32 requestId, UA_WriteResponse *wr);

# typedef void (*UA_ClientAsyncBrowseCallback)(UA_Client *client, void *userdata,
# UA_UInt32 requestId, UA_BrowseResponse *wr);

# typedef void
# (*UA_ClientAsyncOperationCallback)(UA_Client *client, void *userdata,
# UA_UInt32 requestId, UA_StatusCode status,
# void *result);
# typedef void (*UA_ClientAsyncCallCallback)(UA_Client *client, void *userdata,
# UA_UInt32 requestId, UA_CallResponse *cr);

# typedef void (*UA_ClientAsyncAddNodesCallback)(UA_Client *client, void *userdata,
#                                                UA_UInt32 requestId,
#                                                UA_AddNodesResponse *ar);


# typedef UA_StatusCode (*UA_UsernamePasswordLoginCallback)
# (const UA_String *userName, const UA_ByteString *password,
# size_t usernamePasswordLoginSize, const UA_UsernamePasswordLogin
# *usernamePasswordLogin, void **sessionContext, void *loginContext);

# typedef struct UA_HistoryDataBackend UA_HistoryDataBackend;

#     struct UA_HistoryDataBackend {
#         void *context;
    
#         void
#         (*deleteMembers)(UA_HistoryDataBackend *backend);
    
#         /* This function sets a DataValue for a node in the historical data storage.
#          *
#          * server is the server the node lives in.
#          * hdbContext is the context of the UA_HistoryDataBackend.
#          * sessionId and sessionContext identify the session that wants to read historical data.
#          * nodeId is the node for which the value shall be stored.
#          * value is the value which shall be stored.
#          * historizing is the historizing flag of the node identified by nodeId.
#          * If sessionId is NULL, the historizing flag is invalid and must not be used. */
#         UA_StatusCode
#         (*serverSetHistoryData)(UA_Server *server,
#                                 void *hdbContext,
#                                 const UA_NodeId *sessionId,
#                                 void *sessionContext,
#                                 const UA_NodeId *nodeId,
#                                 UA_Boolean historizing,
#                                 const UA_DataValue *value);
    
#         /* This function is the high level interface for the ReadRaw operation. Set
#          * it to NULL if you use the low level API for your plugin. It should be
#          * used if the low level interface does not suite your database. It is more
#          * complex to implement the high level interface but it also provide more
#          * freedom. If you implement this, then set all low level api function
#          * pointer to NULL.
#          *
#          * server is the server the node lives in.
#          * hdbContext is the context of the UA_HistoryDataBackend.
#          * sessionId and sessionContext identify the session that wants to read historical data.
#          * backend is the HistoryDataBackend whose storage is to be queried.
#          * start is the start time of the HistoryRead request.
#          * end is the end time of the HistoryRead request.
#          * nodeId is the node id of the node for which historical data is requested.
#          * maxSizePerResponse is the maximum number of items per response the server can provide.
#          * numValuesPerNode is the maximum number of items per response the client wants to receive.
#          * returnBounds determines if the client wants to receive bounding values.
#          * timestampsToReturn contains the time stamps the client is interested in.
#          * range is the numeric range the client wants to read.
#          * releaseContinuationPoints determines if the continuation points shall be released.
#          * continuationPoint is the continuation point the client wants to release or start from.
#          * outContinuationPoint is the continuation point that gets passed to the
#          *                      client by the HistoryRead service.
#          * result contains the result histoy data that gets passed to the client. */
#         UA_StatusCode
#         (*getHistoryData)(UA_Server *server,
#                           const UA_NodeId *sessionId,
#                           void *sessionContext,
#                           const UA_HistoryDataBackend *backend,
#                           const UA_DateTime start,
#                           const UA_DateTime end,
#                           const UA_NodeId *nodeId,
#                           size_t maxSizePerResponse,
#                           UA_UInt32 numValuesPerNode,
#                           UA_Boolean returnBounds,
#                           UA_TimestampsToReturn timestampsToReturn,
#                           UA_NumericRange range,
#                           UA_Boolean releaseContinuationPoints,
#                           const UA_ByteString *continuationPoint,
#                           UA_ByteString *outContinuationPoint,
#                           UA_HistoryData *result);
    
#         /* This function is part of the low level HistoryRead API. It returns the
#          * index of a value in the database which matches certain criteria.
#          *
#          * server is the server the node lives in.
#          * hdbContext is the context of the UA_HistoryDataBackend.
#          * sessionId and sessionContext identify the session that wants to read historical data.
#          * nodeId is the node id of the node for which the matching value shall be found.
#          * timestamp is the timestamp of the requested index.
#          * strategy is the matching strategy which shall be applied in finding the index. */
#         size_t
#         (*getDateTimeMatch)(UA_Server *server,
#                             void *hdbContext,
#                             const UA_NodeId *sessionId,
#                             void *sessionContext,
#                             const UA_NodeId *nodeId,
#                             const UA_DateTime timestamp,
#                             const MatchStrategy strategy);
    
#         /* This function is part of the low level HistoryRead API. It returns the
#          * index of the element after the last valid entry in the database for a
#          * node.
#          *
#          * server is the server the node lives in.
#          * hdbContext is the context of the UA_HistoryDataBackend.
#          * sessionId and sessionContext identify the session that wants to read historical data.
#          * nodeId is the node id of the node for which the end of storage shall be returned. */
#         size_t
#         (*getEnd)(UA_Server *server,
#                   void *hdbContext,
#                   const UA_NodeId *sessionId,
#                   void *sessionContext,
#                   const UA_NodeId *nodeId);
    
#         /* This function is part of the low level HistoryRead API. It returns the
#          * index of the last element in the database for a node.
#          *
#          * server is the server the node lives in.
#          * hdbContext is the context of the UA_HistoryDataBackend.
#          * sessionId and sessionContext identify the session that wants to read historical data.
#          * nodeId is the node id of the node for which the index of the last element
#          *        shall be returned. */
#         size_t
#         (*lastIndex)(UA_Server *server,
#                      void *hdbContext,
#                      const UA_NodeId *sessionId,
#                      void *sessionContext,
#                      const UA_NodeId *nodeId);
    
#         /* This function is part of the low level HistoryRead API. It returns the
#          * index of the first element in the database for a node.
#          *
#          * server is the server the node lives in.
#          * hdbContext is the context of the UA_HistoryDataBackend.
#          * sessionId and sessionContext identify the session that wants to read historical data.
#          * nodeId is the node id of the node for which the index of the first
#          *        element shall be returned. */
#         size_t
#         (*firstIndex)(UA_Server *server,
#                       void *hdbContext,
#                       const UA_NodeId *sessionId,
#                       void *sessionContext,
#                       const UA_NodeId *nodeId);
    
#         /* This function is part of the low level HistoryRead API. It returns the
#          * number of elements between startIndex and endIndex including both.
#          *
#          * server is the server the node lives in.
#          * hdbContext is the context of the UA_HistoryDataBackend.
#          * sessionId and sessionContext identify the session that wants to read historical data.
#          * nodeId is the node id of the node for which the number of elements shall be returned.
#          * startIndex is the index of the first element in the range.
#          * endIndex is the index of the last element in the range. */
#         size_t
#         (*resultSize)(UA_Server *server,
#                       void *hdbContext,
#                       const UA_NodeId *sessionId,
#                       void *sessionContext,
#                       const UA_NodeId *nodeId,
#                       size_t startIndex,
#                       size_t endIndex);
    
#         /* This function is part of the low level HistoryRead API. It copies data
#          * values inside a certain range into a buffer.
#          *
#          * server is the server the node lives in.
#          * hdbContext is the context of the UA_HistoryDataBackend.
#          * sessionId and sessionContext identify the session that wants to read historical data.
#          * nodeId is the node id of the node for which the data values shall be copied.
#          * startIndex is the index of the first value in the range.
#          * endIndex is the index of the last value in the range.
#          * reverse determines if the values shall be copied in reverse order.
#          * valueSize is the maximal number of data values to copy.
#          * range is the numeric range which shall be copied for every data value.
#          * releaseContinuationPoints determines if the continuation points shall be released.
#          * continuationPoint is a continuation point the client wants to release or start from.
#          * outContinuationPoint is a continuation point which will be passed to the client.
#          * providedValues contains the number of values that were copied.
#          * values contains the values that have been copied from the database. */
#         UA_StatusCode
#         (*copyDataValues)(UA_Server *server,
#                           void *hdbContext,
#                           const UA_NodeId *sessionId,
#                           void *sessionContext,
#                           const UA_NodeId *nodeId,
#                           size_t startIndex,
#                           size_t endIndex,
#                           UA_Boolean reverse,
#                           size_t valueSize,
#                           UA_NumericRange range,
#                           UA_Boolean releaseContinuationPoints,
#                           const UA_ByteString *continuationPoint,
#                           UA_ByteString *outContinuationPoint,
#                           size_t *providedValues,
#                           UA_DataValue *values);
    
#         /* This function is part of the low level HistoryRead API. It returns the
#          * data value stored at a certain index in the database.
#          *
#          * server is the server the node lives in.
#          * hdbContext is the context of the UA_HistoryDataBackend.
#          * sessionId and sessionContext identify the session that wants to read historical data.
#          * nodeId is the node id of the node for which the data value shall be returned.
#          * index is the index in the database for which the data value is requested. */
#         const UA_DataValue*
#         (*getDataValue)(UA_Server *server,
#                         void *hdbContext,
#                         const UA_NodeId *sessionId,
#                         void *sessionContext,
#                         const UA_NodeId *nodeId,
#                         size_t index);
    
#         /* This function returns UA_TRUE if the backend supports returning bounding
#          * values for a node. This function is mandatory.
#          *
#          * server is the server the node lives in.
#          * hdbContext is the context of the UA_HistoryDataBackend.
#          * sessionId and sessionContext identify the session that wants to read
#          *           historical data.
#          * nodeId is the node id of the node for which the capability to return
#          *        bounds shall be queried. */
#         UA_Boolean
#         (*boundSupported)(UA_Server *server,
#                           void *hdbContext,
#                           const UA_NodeId *sessionId,
#                           void *sessionContext,
#                           const UA_NodeId *nodeId);
    
#         /* This function returns UA_TRUE if the backend supports returning the
#          * requested timestamps for a node. This function is mandatory.
#          *
#          * server is the server the node lives in.
#          * hdbContext is the context of the UA_HistoryDataBackend.
#          * sessionId and sessionContext identify the session that wants to read historical data.
#          * nodeId is the node id of the node for which the capability to return
#          *        certain timestamps shall be queried. */
#         UA_Boolean
#         (*timestampsToReturnSupported)(UA_Server *server,
#                                        void *hdbContext,
#                                        const UA_NodeId *sessionId,
#                                        void *sessionContext,
#                                        const UA_NodeId *nodeId,
#                                        const UA_TimestampsToReturn timestampsToReturn);
    
#         UA_StatusCode
#         (*insertDataValue)(UA_Server *server,
#                            void *hdbContext,
#                            const UA_NodeId *sessionId,
#                            void *sessionContext,
#                            const UA_NodeId *nodeId,
#                            const UA_DataValue *value);
#         UA_StatusCode
#         (*replaceDataValue)(UA_Server *server,
#                             void *hdbContext,
#                             const UA_NodeId *sessionId,
#                             void *sessionContext,
#                             const UA_NodeId *nodeId,
#                             const UA_DataValue *value);
#         UA_StatusCode
#         (*updateDataValue)(UA_Server *server,
#                            void *hdbContext,
#                            const UA_NodeId *sessionId,
#                            void *sessionContext,
#                            const UA_NodeId *nodeId,
#                            const UA_DataValue *value);
#         UA_StatusCode
#         (*removeDataValue)(UA_Server *server,
#                            void *hdbContext,
#                            const UA_NodeId *sessionId,
#                            void *sessionContext,
#                            const UA_NodeId *nodeId,
#                            UA_DateTime startTimestamp,
#                            UA_DateTime endTimestamp);
#     };

#     typedef struct UA_HistoryDataGathering UA_HistoryDataGathering;
#         struct UA_HistoryDataGathering {
#             void *context;
        
#             void
#             (*deleteMembers)(UA_HistoryDataGathering *gathering);
        
#             /* This function registers a node for the gathering of historical data.
#              *
#              * server is the server the node lives in.
#              * hdgContext is the context of the UA_HistoryDataGathering.
#              * nodeId is the node id of the node to register.
#              * setting contains the gatering settings for the node to register. */
#             UA_StatusCode
#             (*registerNodeId)(UA_Server *server,
#                               void *hdgContext,
#                               const UA_NodeId *nodeId,
#                               const UA_HistorizingNodeIdSettings setting);
        
#             /* This function stops polling a node for value changes.
#              *
#              * server is the server the node lives in.
#              * hdgContext is the context of the UA_HistoryDataGathering.
#              * nodeId is id of the node for which polling shall be stopped.
#              * setting contains the gatering settings for the node. */
#             UA_StatusCode
#             (*stopPoll)(UA_Server *server,
#                         void *hdgContext,
#                         const UA_NodeId *nodeId);
        
#             /* This function starts polling a node for value changes.
#              *
#              * server is the server the node lives in.
#              * hdgContext is the context of the UA_HistoryDataGathering.
#              * nodeId is the id of the node for which polling shall be started. */
#             UA_StatusCode
#             (*startPoll)(UA_Server *server,
#                          void *hdgContext,
#                          const UA_NodeId *nodeId);
        
#             /* This function modifies the gathering settings for a node.
#              *
#              * server is the server the node lives in.
#              * hdgContext is the context of the UA_HistoryDataGathering.
#              * nodeId is the node id of the node for which gathering shall be modified.
#              * setting contains the new gatering settings for the node. */
#             UA_Boolean
#             (*updateNodeIdSetting)(UA_Server *server,
#                                    void *hdgContext,
#                                    const UA_NodeId *nodeId,
#                                    const UA_HistorizingNodeIdSettings setting);
        
#             /* Returns the gathering settings for a node.
#              *
#              * server is the server the node lives in.
#              * hdgContext is the context of the UA_HistoryDataGathering.
#              * nodeId is the node id of the node for which the gathering settings shall
#              *        be retrieved. */
#             const UA_HistorizingNodeIdSettings*
#             (*getHistorizingSetting)(UA_Server *server,
#                                      void *hdgContext,
#                                      const UA_NodeId *nodeId);
        
#             /* Sets a DataValue for a node in the historical data storage.
#              *
#              * server is the server the node lives in.
#              * hdgContext is the context of the UA_HistoryDataGathering.
#              * sessionId and sessionContext identify the session which wants to set this value.
#              * nodeId is the node id of the node for which a value shall be set.
#              * historizing is the historizing flag of the node identified by nodeId.
#              * value is the value to set in the history data storage. */
#             void
#             (*setValue)(UA_Server *server,
#                         void *hdgContext,
#                         const UA_NodeId *sessionId,
#                         void *sessionContext,
#                         const UA_NodeId *nodeId,
#                         UA_Boolean historizing,
#                         const UA_DataValue *value);
#         };


