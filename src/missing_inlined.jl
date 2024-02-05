using open62541

missing_inlined_funcs = String[]
for func in open62541.inlined_funcs
    if !isdefined(open62541, Symbol(func))
        push!(missing_inlined_funcs, func)
    end
end
