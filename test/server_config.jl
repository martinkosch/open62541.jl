#this shall test access control configurations and basic server configurations

using open62541
using Test

# UA interface
server1 = UA_Server_new()
config1 = UA_Server_getConfig(server1)
retval1 = UA_ServerConfig_setMinimalCustomBuffer(config1, 4842, C_NULL, 0, 0)
retval2 = UA_ServerConfig_setMinimal(config1, 4842, C_NULL)
retval3 = UA_ServerConfig_setDefault(config1)
UA_Server_delete(server1)

@test retval1 == UA_STATUSCODE_GOOD
@test retval2 == UA_STATUSCODE_GOOD
@test retval3 == UA_STATUSCODE_GOOD

# JUA Interface
server2 = JUA_Server()
config2 = JUA_ServerConfig(server2)
config3 = JUA_Server_getConfig(server2)
retval4 = JUA_ServerConfig_setMinimalCustomBuffer(config2, 4842, C_NULL, 0, 0)
retval5 = JUA_ServerConfig_setMinimal(config2, 4842, C_NULL)
retval6 = JUA_ServerConfig_setDefault(config2)
server2 = 0 #trigger the GC
GC.gc()

@test retval4 == UA_STATUSCODE_GOOD
@test retval5 == UA_STATUSCODE_GOOD
@test retval6 == UA_STATUSCODE_GOOD
