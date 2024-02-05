using Distributed
#follows Server side example here: https://github.com/open62541/open62541/blob/2c87f1ed06bf594103d6bf0b1d31267fa3e9d8cf/examples/access_control/server_access_control.c

Distributed.addprocs(1) # Add a single worker process to run the server

Distributed.@everywhere begin
    using open62541
    using Test
    using Pkg

    function allowAddNode(server, ac, sessionId, sessionContext, item)
        return UA_TRUE
    end

    function allowAddReference(server, ac, sessionId, sessionContext, item)
        return UA_TRUE
    end

    function allowDeleteNode(server, ac, sessionId, sessionContext, item)
        return UA_FALSE #Do not allow node deletion from client
    end

    function allowDeleteReference(server, ac, sessionId, sessionContext, item)
        return UA_TRUE
    end
end

Distributed.@spawnat Distributed.workers()[end] begin
    #configure server and add login details of one user.
    server = UA_Server_new()
    config = UA_Server_getConfig(server)
    UA_ServerConfig_setDefault(config)
    login = UA_UsernamePasswordLogin(UA_STRING("user"), UA_STRING("password"))
    retval0 = UA_AccessControl_default(config, false, C_NULL,
        Ref(unsafe_load(unsafe_load(config.securityPolicies)).policyUri), 1, Ref(login))
    @test retval0 == UA_STATUSCODE_GOOD

    #generate callbacks and add them to the config; TODO: define callback generators for these, so that the user doesn't have to deal with @cfunction etc.
    cb_allowAddNode = @cfunction(allowAddNode,
        Bool,
        (Ptr{UA_Server},
            Ptr{UA_AccessControl},
            Ptr{UA_NodeId},
            Ptr{Cvoid},
            Ptr{UA_AddNodesItem}))
    cb_allowAddReference = @cfunction(allowAddReference,
        Bool,
        (Ptr{UA_Server},
            Ptr{UA_AccessControl},
            Ptr{UA_NodeId},
            Ptr{Cvoid},
            Ptr{UA_AddReferencesItem}))
    cb_allowDeleteNode = @cfunction(allowDeleteNode,
        Bool,
        (Ptr{UA_Server},
            Ptr{UA_AccessControl},
            Ptr{UA_NodeId},
            Ptr{Cvoid},
            Ptr{UA_DeleteNodesItem}))
    cb_allowDeleteReference = @cfunction(allowDeleteReference,
        Bool,
        (Ptr{UA_Server},
            Ptr{UA_AccessControl},
            Ptr{UA_NodeId},
            Ptr{Cvoid},
            Ptr{UA_DeleteReferencesItem}))

    config.accessControl.allowAddNode = cb_allowAddNode
    config.accessControl.allowAddReference = cb_allowAddReference
    config.accessControl.allowDeleteNode = cb_allowDeleteNode
    config.accessControl.allowDeleteReference = cb_allowDeleteReference
    UA_Server_run(server, Ref(true))
end

#Client side: https://github.com/open62541/open62541/blob/2c87f1ed06bf594103d6bf0b1d31267fa3e9d8cf/examples/access_control/client_access_control.c
# Specify client and connect to server after server startup
client = UA_Client_new()
UA_ClientConfig_setDefault(UA_Client_getConfig(client))
max_duration = 30.0 # Maximum waiting time for server startup 
sleep_time = 2.0 # Sleep time in seconds between each connection trial
let trial
    trial = 0
    while trial < max_duration / sleep_time
        retval1 = UA_Client_connectUsername(client,
            "opc.tcp://localhost:4840",
            "user",
            "password")
        if retval1 == UA_STATUSCODE_GOOD
            println("Connection established.")
            break
        end
        sleep(sleep_time)
        trial = trial + 1
    end
    @test trial < max_duration / sleep_time # Check if maximum number of trials has been exceeded
end

newVariableIdRequest = UA_NodeId_new()
newVariableId = UA_NodeId_new()
value = UA_UInt32(50)
accesslevel = UA_ACCESSLEVEL(read = true)
description = "NewVariable description"
displayname = "NewVariable"
newVariableAttributes = UA_VariableAttributes_generate(value = value,
    accesslevel = accesslevel,
    description = description,
    displayname = displayname)
retval2 = UA_Client_addVariableNode(client, newVariableIdRequest,
    UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER),
    UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES), UA_QUALIFIEDNAME(1, "newVariable"),
    UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE),
    newVariableAttributes, newVariableId)
@test retval2 == UA_STATUSCODE_GOOD

extNodeId = UA_EXPANDEDNODEID_NUMERIC(0, 0);
extNodeId.nodeId = newVariableId
retval3 = UA_Client_addReference(client, UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER),
    UA_NODEID_NUMERIC(0, UA_NS0ID_HASCOMPONENT), UA_TRUE, UA_STRING_NULL, extNodeId,
    UA_NODECLASS_VARIABLE)
@test retval3 == UA_STATUSCODE_GOOD

retval4 = UA_Client_deleteReference(client, UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER),
    UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES), UA_TRUE, extNodeId, UA_TRUE)
@test retval4 == UA_STATUSCODE_GOOD

retval5 = UA_Client_deleteNode(client, newVariableId, UA_TRUE)
@test retval5 == UA_STATUSCODE_BADUSERACCESSDENIED #disallowed deleting nodes via client above, so should return access denied retcode

#TODO: need to do clean up.

# Disconnect client
UA_Client_disconnect(client)
UA_Client_delete(client)

println("Ungracefully kill server process...")
Distributed.interrupt(Distributed.workers()[end])
Distributed.rmprocs(Distributed.workers()[end]; waitfor = 0)
