#tests custom exceptions

using open62541
using Test

#basic tests to see whether showerror methods throw an error or not.
e1 = open62541.ClientServiceRequestError("test")
e2 = open62541.AttributeReadWriteError("reading",
    "async",
    "server",
    "valuerank",
    UA_STATUSCODE_BADNODEIDINVALID)
e3 = open62541.AttributeCopyError(UA_STATUSCODE_BADOUTOFMEMORY)
f1(x::Float64, y::Float64) = 0.0
f1(x::Float64) = 0.0
input_argtuple = (Int64,)
e4 = open62541.CallbackGeneratorArgumentError(f1, input_argtuple, Float64)
f2(x::Float64) = 0.0
e5 = open62541.CallbackGeneratorArgumentError(f2, input_argtuple, Float64)
(buf = IOBuffer(); showerror(buf, e1); msg = String(take!(buf)); @test !isempty(msg))
(buf = IOBuffer(); showerror(buf, e2); msg = String(take!(buf)); @test !isempty(msg))
(buf = IOBuffer(); showerror(buf, e3); msg = String(take!(buf)); @test !isempty(msg))
(buf = IOBuffer(); showerror(buf, e4); msg = String(take!(buf)); @test !isempty(msg))
(buf = IOBuffer(); showerror(buf, e5); msg = String(take!(buf)); @test !isempty(msg))

#configure server
server = UA_Server_new()
retval = UA_ServerConfig_setDefault(UA_Server_getConfig(server))
@test retval == UA_STATUSCODE_GOOD

#configure client
client = UA_Client_new()
UA_ClientConfig_setDefault(UA_Client_getConfig(client))

#specify a bad nodeid (doesn't exist in server)
bogusid = UA_NODEID_STRING_ALLOC(1, "bogusid")

#AttributeReadWriteError - UA_Server_readX function 
@test_throws open62541.AttributeReadWriteError UA_Server_readValue(server, bogusid)

#AttributeReadWriteError - UA_Server_writeX function 
var1 = UA_Variant_new()
@test_throws open62541.AttributeReadWriteError UA_Server_writeValue(server, bogusid, var1)

#AttributeReadWriteError - UA_Client_readX function 
@test_throws open62541.AttributeReadWriteError UA_Client_readValueAttribute(client, bogusid)

#AttributeReadWriteError - UA_Client_readX function 
var2 = UA_Variant_new()
@test_throws open62541.AttributeReadWriteError UA_Client_writeValueAttribute(client,
    bogusid,
    var2)

#tidy up
UA_Server_delete(server)
UA_Client_delete(client)
UA_Variant_delete(var1)
UA_Variant_delete(var2)
UA_NodeId_delete(bogusid)
