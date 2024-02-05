
using open62541

n1 = JUA_NodeId(1, 1234)
n2 = UA_NODEID_NUMERIC(1, 1234)
n3 = JUA_NodeId(1, "my_new_id")
n4 = UA_NODEID_STRING_ALLOC(1, "my_new_id")

UA_NodeId_equal(n1, n2)
UA_NodeId_equal(n3, n4)

n3 = 10 #this causes reference to the pointer in n3 to be lost (which is connected to allocated memory). 
#since finalizer is defined in the wrapper, the memory gets automatically freed.
GC.gc() #garbage collector frees the memory (normally runs automatically) 

for i in 1:50_000_000 #"forgetting" to free memory creates memory leak - should eat up about 3GB of memory.
    n5 = UA_NODEID_STRING_ALLOC(1, "my new id")
    n5 = 10
end

GC.gc() #memory not recovered by GC. :(

for i in 1:50_000_000 #no memory leak; usage constant, because the GC is at work.
    n6 = open62541.JUA_NodeId(1, "my new id")
    n6 = 10
end

using Distributed
Distributed.addprocs(1) # Add a single worker process to run the server

Distributed.@everywhere begin
    using open62541
    using Test
end

# Create nodes with random default values on new server running at a worker process
Distributed.@spawnat Distributed.workers()[end] begin
    server = UA_Server_new()
    retval = UA_ServerConfig_setMinimalCustomBuffer(UA_Server_getConfig(server),
        4842,
        C_NULL,
        0,
        0)
    @test retval == UA_STATUSCODE_GOOD

    # Add variable node containing a scalar to the server
    input = rand(100, 100)
    accesslevel = UA_ACCESSLEVELMASK_READ | UA_ACCESSLEVELMASK_WRITE
    attr = UA_generate_variable_attributes(input,
        "test",
        "test",
        accesslevel)
    varnodeid = UA_NODEID_STRING_ALLOC(1, "test")
    parentnodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER)
    parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES)
    typedefinition = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
    browsename = UA_QUALIFIEDNAME_ALLOC(1, "test")
    nodecontext = C_NULL
    outnewnodeid = C_NULL
    retval = UA_Server_addVariableNode(server, varnodeid, parentnodeid,
        parentreferencenodeid,
        browsename, typedefinition, attr, nodecontext, outnewnodeid)

    # Start up the server
    Distributed.@spawnat Distributed.workers()[end] redirect_stderr() # Turn off all error messages
    println("Starting up the server...")
    UA_Server_run(server, Ref(true))
end

# Specify client and connect to server after server startup
client = UA_Client_new()
UA_ClientConfig_setDefault(UA_Client_getConfig(client))
max_duration = 40.0 # Maximum waiting time for server startup 
sleep_time = 2.0 # Sleep time in seconds between each connection trial
let trial
    trial = 0
    while trial < max_duration / sleep_time
        retval = UA_Client_connect(client, "opc.tcp://localhost:4842")
        if retval == UA_STATUSCODE_GOOD
            println("Connection established.")
            break
        end
        sleep(sleep_time)
        trial = trial + 1
    end
    @test trial < max_duration / sleep_time # Check if maximum number of trials has been exceeded
end

# Read with client from server
for i in 1:3000
    varnodeid = UA_NODEID_STRING_ALLOC(1, "test")
    output_client = UA_Client_readValueAttribute(client, varnodeid)
    output_client = 10
end

# Disconnect client
UA_Client_disconnect(client)
UA_Client_delete(client)

println("Ungracefully kill server process...")
Distributed.interrupt(Distributed.workers()[end])
Distributed.rmprocs(Distributed.workers()[end]; waitfor = 0)
