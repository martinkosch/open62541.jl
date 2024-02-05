#Purpose: Tests functionality of basic types used in UA for a lot of things:
#Types currently covered: (J)UA_String, (J)UA_QualifiedName, (J)UA_LocalizedText, (J)UA_ByteString
#Functions currently covered: UA_DateTime_
using open62541
using Test
using Base64
using Dates

#String
s1 = "test1"
bytestring_s1 = base64encode(write, s1)
emptyString = UA_STRING("")
ua_s1 = UA_STRING(s1)
ua_s2 = UA_STRING(s1)
ua_s3 = UA_BYTESTRING(bytestring_s1)
ua_s4 = UA_BYTESTRING(bytestring_s1)
j1 = JUA_String("test1")
@test isa(emptyString, Ptr{UA_String})
@test isa(ua_s1, Ptr{UA_String})
@test isa(ua_s2, Ptr{UA_String})
@test UA_String_equal(ua_s1, ua_s2)
@test UA_String_equal(j1, ua_s1)
@test UA_ByteString_equal(ua_s3, ua_s4)
@test String(base64decode(unsafe_string(ua_s3))) == s1
UA_String_delete(ua_s1)
UA_String_delete(ua_s2)
UA_String_delete(ua_s3)
j1 = 0 #this should trigger the garbage collector 
GC.gc()

#QualifiedName
s1 = "test1"
ns = 1
ua_s1 = UA_STRING(s1)
qn0 = UA_QualifiedName_new()
qn1 = UA_QUALIFIEDNAME(ns, s1)
qn2 = UA_QUALIFIEDNAME(ns, ua_s1)
qn3 = UA_QUALIFIEDNAME_ALLOC(ns, s1)
qn4 = UA_QUALIFIEDNAME_ALLOC(ns, ua_s1)
UA_String_delete(ua_s1)
@test isa(qn1, Ptr{UA_QualifiedName})
@test isa(qn2, Ptr{UA_QualifiedName})
@test isa(qn3, Ptr{UA_QualifiedName})
@test isa(qn4, Ptr{UA_QualifiedName})
@test UA_QualifiedName_equal(qn1, qn2)
@test UA_QualifiedName_equal(qn1, qn3)
@test UA_QualifiedName_equal(qn1, qn4)
@test UA_QualifiedName_isNull(qn0)
UA_QualifiedName_delete(qn1)
UA_QualifiedName_delete(qn2)
UA_QualifiedName_delete(qn3)
UA_QualifiedName_delete(qn4)

## LocalizedText
s1 = "test1"
s2 = "test2"
ua_s1 = UA_STRING(s1)
ua_s2 = UA_STRING(s2)
lt1 = UA_LOCALIZEDTEXT(s1, s2)
lt2 = UA_LOCALIZEDTEXT(s1, ua_s2)
lt3 = UA_LOCALIZEDTEXT(ua_s1, s2)
lt4 = UA_LOCALIZEDTEXT(ua_s1, ua_s2)
UA_String_delete(ua_s1)
UA_String_delete(ua_s2)
@test isa(lt1, Ptr{UA_LocalizedText})
@test isa(lt2, Ptr{UA_LocalizedText})
@test isa(lt3, Ptr{UA_LocalizedText})
@test isa(lt4, Ptr{UA_LocalizedText})
@test UA_LocalizedText_equal(lt1, lt2)
@test UA_LocalizedText_equal(lt1, lt3)
@test UA_LocalizedText_equal(lt1, lt4)
UA_LocalizedText_delete(lt1)
UA_LocalizedText_delete(lt2)
UA_LocalizedText_delete(lt3)
UA_LocalizedText_delete(lt4)

#Testing date functions
timenow = UA_DateTime_now()
unixtime = UA_DateTime_toUnixTime(timenow)
unixtime_precise = UA_DateTime_toUnixTime_precise(timenow)
@test UA_DateTime_fromUnixTime(unixtime) ==
      UA_DateTime_fromUnixTime(trunc(Int, unixtime_precise))
jtime = Dates.now()
jtime_UTC = Dates.now(Dates.UTC)
UTC_offset = ceil(Int,
    ceil(Int, Dates.value(jtime - jtime_UTC) / 3600000 * 4) / 4 * 36_000_000_000) #the 4 is to accommodate all possible timezones; hello Nepali timezone.
@test isa(UA_DateTime_nowMonotonic(), Int)
@test UA_DateTime_fromStruct(UA_DateTime_toStruct(timenow)) == timenow
@test UTC_offset == UA_DateTime_localTimeUtcOffset()

# constant Time equal function test - on a simple example
ua_s1 = UA_STRING("test1")
ua_s2 = UA_STRING("test1")
ua_s3 = UA_STRING("test2")
ptr1 = unsafe_load(ua_s1.data)
ptr2 = unsafe_load(ua_s2.data)
ptr3 = unsafe_load(ua_s3.data)
@test UA_constantTimeEqual(ptr1, ptr2, 5)
@test !UA_constantTimeEqual(ptr1, ptr3, 5)
@test UA_constantTimeEqual(ptr1, ptr3, 4)
UA_String_delete(ua_s1)
UA_String_delete(ua_s2)
UA_String_delete(ua_s3)

#CreateSubscription
sr = UA_CreateSubscriptionRequest_default()
@test isa(sr, Ptr{UA_CreateSubscriptionRequest})
UA_CreateSubscriptionRequest_delete(sr)

#MonitoredItem
n = UA_NODEID_NUMERIC(1, 1234)
mi = UA_MonitoredItemCreateRequest_default(n)
@test isa(mi, Ptr{UA_MonitoredItemCreateRequest})
UA_NodeId_delete(n)
UA_MonitoredItemCreateRequest_delete(mi)

#Client_getContext
client = UA_Client_new()
context = UA_Client_getContext(client)
@test isa(context, Ptr{Ptr{Nothing}})
UA_Client_delete(client)
