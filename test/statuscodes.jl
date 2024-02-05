#tests custom exceptions

using open62541
using Test

codes_good = [UA_STATUSCODE_GOOD
    UA_STATUSCODE_GOODCOMMUNICATIONEVENT
    UA_STATUSCODE_GOODSHUTDOWNEVENT
    UA_STATUSCODE_GOODCALLAGAIN
    UA_STATUSCODE_GOODNONCRITICALTIMEOUT]
codes_uncertain = [UA_STATUSCODE_UNCERTAIN,
    UA_STATUSCODE_UNCERTAINDOMINANTVALUECHANGED,
    UA_STATUSCODE_UNCERTAINSUBSTITUTEVALUE,
    UA_STATUSCODE_UNCERTAININITIALVALUE,
    UA_STATUSCODE_UNCERTAINSENSORNOTACCURATE]
codes_bad = [UA_STATUSCODE_BAD,
    UA_STATUSCODE_BADEVENTFILTERINVALID,
    UA_STATUSCODE_BADCONTENTFILTERINVALID,
    UA_STATUSCODE_BADFILTEROPERATORINVALID,
    UA_STATUSCODE_BADFILTEROPERATORUNSUPPORTED]

bools_good = [true, false, false]
bools_uncertain = [false, true, false]
bools_bad = [false, false, true]

function test_codes(codes, bools)
    for c in codes
        @test open62541.UA_StatusCode_isGood(c) == bools[1]
        @test open62541.UA_StatusCode_isUncertain(c) == bools[2]
        @test open62541.UA_StatusCode_isBad(c) == bools[3]
    end
end

test_codes(codes_good, bools_good)
test_codes(codes_uncertain, bools_uncertain)
test_codes(codes_bad, bools_bad)
