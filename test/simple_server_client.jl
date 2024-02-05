using Distributed
Distributed.addprocs(1) # Add a single worker process to run the server

Distributed.@everywhere begin
    using open62541
    using Test
    using Pkg
end

# Create a new server running at a worker process
Distributed.@spawnat Distributed.workers()[end] begin
    server = UA_Server_new()
    retval1 = UA_ServerConfig_setMinimalCustomBuffer(UA_Server_getConfig(server),
        4842, C_NULL, 0, 0)
    @test retval1 == UA_STATUSCODE_GOOD
    @test isa(server, Ptr{UA_Server})
    UA_Server_run(server, Ref(true))
end

# Specify client and connect to server after server startup
client = UA_Client_new()
UA_ClientConfig_setDefault(UA_Client_getConfig(client))
max_duration = 30.0 # Maximum waiting time for server startup 
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

# nodeid containing software version running on server
nodeid = UA_NODEID_NUMERIC(0, UA_NS0ID_SERVER_SERVERSTATUS_BUILDINFO_SOFTWAREVERSION)

# Read nodeid from server
raw_version = UA_Client_readValueAttribute(client, nodeid)
open62541_version_server = unsafe_string(unsafe_wrap(raw_version))

# Do version numbers agree?
vn2string(vn::VersionNumber) = "$(vn.major).$(vn.minor).$(vn.patch)"
if VERSION < v"1.9"
    pkgdir_old(m::Core.Module) = abspath(Base.pathof(Base.moduleroot(m)), "..", "..")
    function pkgproject_old(m::Core.Module)
        Pkg.Operations.read_project(Pkg.Types.projectfile_path(pkgdir_old(m)))
    end
    pkgversion_old(m::Core.Module) = pkgproject_old(m).version
    open62541_version_julia = pkgversion_old(open62541_jll)
else
    open62541_version_julia = pkgversion(open62541_jll)
end
open62541_version_julia = vn2string(open62541_version_julia)
@test open62541_version_server == open62541_version_julia

# Disconnect client
UA_Client_disconnect(client)
UA_Client_delete(client)

println("Ungracefully kill server process...")
Distributed.interrupt(Distributed.workers()[end])
Distributed.rmprocs(Distributed.workers()[end]; waitfor = 0)
