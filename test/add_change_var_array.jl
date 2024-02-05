# Purpose: This testset checks whether variable nodes containing arrays (1, 2, 3, 4 dimensions) of
# different types can be created on a server, read, changed and read again (using the server commands and client commands)
# We also check that setting a variable node with one type cannot be set to another type (e.g., integer variable node cannot be
# set to float64.)
using Distributed
Distributed.addprocs(1) # Add a single worker process to run the server

Distributed.@everywhere begin
    using open62541
    using Test

    # What types and sizes we are testing for: 
    types = [Int64, Float64, Bool, Float32, Int32, Int16]
    array_sizes = (11, (2, 5), (3, 4, 5), (3, 4, 5, 6))

    # Generate random default node values and ids
    input_data = Tuple(Tuple(rand(type, array_size) for array_size in array_sizes)
                       for type in types)
    varnode_ids = ["$(string(array_size)) $(Symbol(type)) array variable"
                   for type in types, array_size in array_sizes]
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

    # Add variable node containing an array to the server
    for (type_ind, type) in enumerate(types)
        for (array_size_ind, array_size) in enumerate(array_sizes)
            # Generate a UA_Server with standard config
            input = input_data[type_ind][array_size_ind]
            accesslevel = UA_ACCESSLEVEL(read = true, write = true)
            attr = UA_VariableAttributes_generate(value = input,
                displayname = varnode_ids[type_ind, array_size_ind],
                description = "this is a $(string(array_size)) $(Symbol(type)) array variable",
                accesslevel = accesslevel)
            varnodeid = UA_NODEID_STRING_ALLOC(1, varnode_ids[type_ind, array_size_ind])
            parentnodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER)
            parentreferencenodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES)
            typedefinition = UA_NODEID_NUMERIC(0, UA_NS0ID_BASEDATAVARIABLETYPE)
            browsename = UA_QUALIFIEDNAME_ALLOC(1, varnode_ids[type_ind, array_size_ind])
            nodecontext = C_NULL
            outnewnodeid = C_NULL
            retval = UA_Server_addVariableNode(server, varnodeid, parentnodeid,
                parentreferencenodeid,
                browsename, typedefinition, attr, nodecontext, outnewnodeid)
            # Test whether adding node to the server worked
            @test retval == UA_STATUSCODE_GOOD
            # Test whether the correct array is within the server (read from server)
            output_server = unsafe_wrap(UA_Server_readValue(server, varnodeid))
            @test all(isapprox.(input, output_server))
        end
    end

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
for (type_ind, type) in enumerate(types)
    for (array_size_ind, array_size) in enumerate(array_sizes)
        input = input_data[type_ind][array_size_ind]
        varnodeid = UA_NODEID_STRING_ALLOC(1, varnode_ids[type_ind, array_size_ind])
        output_client = unsafe_wrap(UA_Client_readValueAttribute(client, varnodeid))
        @test all(isapprox.(input, output_client))
    end
end

# Write new data 
for (type_ind, type) in enumerate(types)
    for (array_size_ind, array_size) in enumerate(array_sizes)
        new_input = rand(type, array_size)
        varnodeid = UA_NODEID_STRING_ALLOC(1, varnode_ids[type_ind, array_size_ind])
        retval = UA_Client_writeValueAttribute(client,
            varnodeid,
            UA_Variant_new_copy(new_input))
        @test retval == UA_STATUSCODE_GOOD

        output_client_new = unsafe_wrap(UA_Client_readValueAttribute(client, varnodeid))
        @test all(isapprox.(new_input, output_client_new))
    end
end

# Test wrong data type write errors 
for type_ind in eachindex(types)
    for (array_size_ind, array_size) in enumerate(array_sizes)
        new_input = rand(types[mod(type_ind, length(types)) + 1]) # Select wrong data type
        varnodeid = UA_NODEID_STRING_ALLOC(1, varnode_ids[type_ind, array_size_ind])
        @test_throws open62541.AttributeReadWriteError UA_Client_writeValueAttribute(client,
            varnodeid,
            UA_Variant_new_copy(new_input))
    end
end

# Disconnect client
UA_Client_disconnect(client)
UA_Client_delete(client)

println("Ungracefully kill server process...")
Distributed.interrupt(Distributed.workers()[end])
Distributed.rmprocs(Distributed.workers()[end]; waitfor = 0)
