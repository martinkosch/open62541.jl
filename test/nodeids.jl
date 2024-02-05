#Purpose: run through all kinds of different functions defining nodeids and test them

using open62541
using Test

#NodeId String
n1 = UA_NODEID("ns=1;s=test")
n2 = UA_NODEID_STRING(1, "test")
n3 = UA_NODEID_STRING_ALLOC(1, "test")
@test isa(n1, Ptr{UA_NodeId})
@test isa(n2, Ptr{UA_NodeId})
@test isa(n3, Ptr{UA_NodeId})
@test UA_NodeId_equal(n1, n2)
@test UA_NodeId_equal(n1, n3)

#NodeId Numeric
n4 = UA_NODEID("ns=1;i=1234")
n5 = UA_NODEID_NUMERIC(1, 1234)
n6 = UA_NODEID_NUMERIC(1, 1234)
@test isa(n4, Ptr{UA_NodeId})
@test isa(n5, Ptr{UA_NodeId})
@test UA_NodeId_equal(n4, n5)
@test UA_NodeId_equal(n4, n6)

#Nodeid Guid
guid = UA_Guid_random()
guid_string = UA_print(unsafe_load(guid))
n7 = UA_NODEID("ns=1;g=" * guid_string)
n8 = UA_NODEID_GUID(1, guid)
n9 = UA_NODEID_GUID(1, guid_string)
UA_Guid_delete(guid)
@test isa(n7, Ptr{UA_NodeId})
@test isa(n8, Ptr{UA_NodeId})
@test isa(n9, Ptr{UA_NodeId})
@test UA_NodeId_equal(n7, n8)
@test UA_NodeId_equal(n7, n9)

#Nodeid ByteString
n10 = UA_NODEID("ns=1;b=dGVzdA==")
n11 = UA_NODEID_BYTESTRING(1, "test")
n12 = UA_NODEID_BYTESTRING_ALLOC(1, "test")
@test isa(n10, Ptr{UA_NodeId})
@test isa(n11, Ptr{UA_NodeId})
@test isa(n12, Ptr{UA_NodeId})
@test UA_NodeId_equal(n10, n11)
@test UA_NodeId_equal(n10, n12)

#ExpandedNodeid String
n13 = UA_EXPANDEDNODEID("ns=1;s=test")
n14 = UA_EXPANDEDNODEID_STRING(1, "test")
n15 = UA_EXPANDEDNODEID_STRING_ALLOC(1, "test")
@test isa(n13, Ptr{UA_ExpandedNodeId})
@test isa(n14, Ptr{UA_ExpandedNodeId})
@test isa(n15, Ptr{UA_ExpandedNodeId})
@test UA_ExpandedNodeId_equal(n13, n14)
@test UA_ExpandedNodeId_equal(n13, n15)
@test UA_ExpandedNodeId_isLocal(n13)

#ExpandedNodeid Numeric
n16 = UA_EXPANDEDNODEID("ns=1;i=1234")
n17 = UA_EXPANDEDNODEID_NUMERIC(1, 1234)
n18 = UA_EXPANDEDNODEID_NUMERIC(1, 1234)
@test isa(n16, Ptr{UA_ExpandedNodeId})
@test isa(n17, Ptr{UA_ExpandedNodeId})
@test isa(n18, Ptr{UA_ExpandedNodeId})
@test UA_ExpandedNodeId_equal(n16, n17)
@test UA_ExpandedNodeId_equal(n16, n18)
@test UA_ExpandedNodeId_isLocal(n16)

#ExpandedNodeid String Guid
guid = UA_Guid_random()
guid_string = UA_print(unsafe_load(guid))
n19 = UA_EXPANDEDNODEID("ns=1;g=" * guid_string)
n20 = UA_EXPANDEDNODEID_STRING_GUID(1, guid)
n21 = UA_EXPANDEDNODEID_STRING_GUID(1, guid_string)
UA_Guid_delete(guid)
@test isa(n19, Ptr{UA_ExpandedNodeId})
@test isa(n20, Ptr{UA_ExpandedNodeId})
@test isa(n21, Ptr{UA_ExpandedNodeId})
@test UA_ExpandedNodeId_equal(n19, n20)
@test UA_ExpandedNodeId_equal(n19, n21)
@test UA_ExpandedNodeId_isLocal(n19)

#ExpandedNodeid Bytestring
n22 = UA_EXPANDEDNODEID("ns=1;b=dGVzdA==")
n23 = UA_EXPANDEDNODEID_BYTESTRING(1, "test")
n24 = UA_EXPANDEDNODEID_BYTESTRING_ALLOC(1, "test")
@test isa(n22, Ptr{UA_ExpandedNodeId})
@test isa(n23, Ptr{UA_ExpandedNodeId})
@test isa(n24, Ptr{UA_ExpandedNodeId})
@test UA_ExpandedNodeId_equal(n22, n23)
@test UA_ExpandedNodeId_equal(n22, n24)
@test UA_ExpandedNodeId_isLocal(n22)

#hash tests
@test UA_NodeId_hash(n4) == UA_ExpandedNodeId_hash(n16)

#Now tests for non-local ExpandedNodeIds
ns_uri = "http://example.com"
server_ind = 1
nodeid = UA_NODEID_NUMERIC(0, 1234)
guid = UA_Guid_random()
guid_string = UA_print(unsafe_load(guid))
ua_s = UA_STRING("test")
n25 = UA_EXPANDEDNODEID("svr=1;nsu=http://example.com;s=test")
n26 = UA_EXPANDEDNODEID_NUMERIC(1234, ns_uri, server_ind)
n27 = UA_EXPANDEDNODEID_STRING_ALLOC("test", ns_uri, server_ind)
n28 = UA_EXPANDEDNODEID_STRING_ALLOC(ua_s, ns_uri, server_ind)
n29 = UA_EXPANDEDNODEID_STRING_GUID(guid, ns_uri, server_ind)
n30 = UA_EXPANDEDNODEID_STRING_GUID(guid_string, ns_uri, server_ind)
n31 = UA_EXPANDEDNODEID_NODEID(nodeid, ns_uri, server_ind)
n32 = UA_EXPANDEDNODEID_BYTESTRING_ALLOC(ua_s, ns_uri, server_ind)
n33 = UA_EXPANDEDNODEID_BYTESTRING_ALLOC("test", ns_uri, server_ind)
UA_Guid_delete(guid)
UA_String_delete(ua_s)
UA_NodeId_delete(nodeid)
@test isa(n25, Ptr{UA_ExpandedNodeId})
@test isa(n26, Ptr{UA_ExpandedNodeId})
@test isa(n27, Ptr{UA_ExpandedNodeId})
@test isa(n28, Ptr{UA_ExpandedNodeId})
@test isa(n29, Ptr{UA_ExpandedNodeId})
@test isa(n30, Ptr{UA_ExpandedNodeId})
@test isa(n31, Ptr{UA_ExpandedNodeId})
@test isa(n32, Ptr{UA_ExpandedNodeId})
@test isa(n33, Ptr{UA_ExpandedNodeId})
@test !UA_ExpandedNodeId_isLocal(n25)
@test !UA_ExpandedNodeId_isLocal(n26)
@test !UA_ExpandedNodeId_isLocal(n27)
@test !UA_ExpandedNodeId_isLocal(n28)
@test !UA_ExpandedNodeId_isLocal(n29)
@test !UA_ExpandedNodeId_isLocal(n30)
@test !UA_ExpandedNodeId_isLocal(n31)
@test !UA_ExpandedNodeId_isLocal(n32)
@test !UA_ExpandedNodeId_isLocal(n33)
@test UA_ExpandedNodeId_equal(n25, n27)
@test UA_ExpandedNodeId_equal(n27, n28)
@test UA_ExpandedNodeId_equal(n29, n30)
@test UA_ExpandedNodeId_equal(n32, n33)

#tidy up
for i in 1:12
    @eval UA_NodeId_delete($(Symbol("n" * string(i))))
end
for i in 13:33
    @eval UA_ExpandedNodeId_delete($(Symbol("n" * string(i))))
end

## Now testing JUA Interface
j1 = JUA_NodeId()
j2 = JUA_NodeId("ns=1;i=1234")
j3 = JUA_NodeId(1, 1234)
j4 = JUA_NodeId(1, "test")
guid1 = JUA_Guid()
guid2 = JUA_Guid("b20e80d9-e073-9042-4284-c8dcd3addabd")
j5 = JUA_NodeId(1, guid1)
j6 = JUA_NodeId(1, guid2)

@test isa(j1, JUA_NodeId)
@test isa(j2, JUA_NodeId)
@test isa(j3, JUA_NodeId)
@test isa(j4, JUA_NodeId)
@test isa(j5, JUA_NodeId)
@test isa(j6, JUA_NodeId)
guid1 = 0 #this should trigger that the GC collects the object
guid2 = 0 #this should trigger that the GC collects the object
j6 = 0 #this should trigger that the GC collects the object
GC.gc()
@test JUA_NodeId_equal(j2, j3)
