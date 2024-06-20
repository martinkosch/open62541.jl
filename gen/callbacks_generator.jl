#Takes what's written in file callbacks_base.jl and adds callback generators for 
#the below AsyncRead functions (cannot use @eval and interpolate value into the 
#@cfunction macro at the same time - or at least I couldn't figure it out)

#change dir
cd(@__DIR__)
fn = "callbacks_base.jl"
f = open(fn, "r")
orig_content = read(f, String)
close(f)

const client_async_read_callbacks = [
    ["UA_ClientAsyncReadAttributeCallback", "UA_DataValue", "attribute"],
    ["UA_ClientAsyncReadValueAttributeCallback", "UA_DataValue", "value"],
    ["UA_ClientAsyncReadDataTypeAttributeCallback", "UA_NodeId", "datatype"],
    ["UA_ClientReadArrayDimensionsAttributeCallback", "UA_Variant", "arraydimensions"],
    ["UA_ClientAsyncReadNodeClassAttributeCallback", "UA_NodeClass", "nodeclass"],
    ["UA_ClientAsyncReadBrowseNameAttributeCallback", "UA_QualifiedName", "browsename"],
    ["UA_ClientAsyncReadDisplayNameAttributeCallback", "UA_LocalizedText", "displayname"],
    ["UA_ClientAsyncReadDescriptionAttributeCallback", "UA_LocalizedText", "description"],
    ["UA_ClientAsyncReadWriteMaskAttributeCallback", "UA_UInt32", "writeMask"],
    ["UA_ClientAsyncReadUserWriteMaskAttributeCallback", "UA_UInt32", "userwritemask"],
    ["UA_ClientAsyncReadIsAbstractAttributeCallback", "UA_Boolean", "isabstract"],
    ["UA_ClientAsyncReadSymmetricAttributeCallback", "UA_Boolean", "symmetric"],
    ["UA_ClientAsyncReadInverseNameAttributeCallback", "UA_LocalizedText", "inversename"],
    ["UA_ClientAsyncReadContainsNoLoopsAttributeCallback", "UA_Boolean", "containsNoLoops"],
    ["UA_ClientAsyncReadEventNotifierAttributeCallback", "UA_Byte", "eventnotifier"],
    ["UA_ClientAsyncReadValueRankAttributeCallback", "UA_UInt32", "valuerank"],
    ["UA_ClientAsyncReadAccessLevelAttributeCallback", "UA_Byte", "accesslevel"],
    ["UA_ClientAsyncReadUserAccessLevelAttributeCallback", "UA_Byte", "useraccesslevel"],
    [
        "UA_ClientAsyncReadMinimumSamplingIntervalAttributeCallback",
        "UA_Double",
        "minimumsamplinginterval"
    ],
    ["UA_ClientAsyncReadHistorizingAttributeCallback", "UA_Boolean", "historizing"],
    ["UA_ClientAsyncReadExecutableAttributeCallback", "UA_Boolean", "executable"],
    ["UA_ClientAsyncReadUserExecutableAttributeCallback", "UA_Boolean", "userexecutable"]
]

fn = joinpath(@__DIR__, "../src/callbacks.jl")
f = open(fn, "w")
addedString = ""
for cb in client_async_read_callbacks
    fun_name = Symbol(cb[1] * "_generate")
    fun_name2 = replace(cb[1], "UA_ClientAsyncRead" => "")
    fun_name2 = replace(fun_name2, "Callback" => "")
    fun_name2 = "UA_Client_read" * fun_name2 * "_async"

    attr_type = Symbol(cb[2])
    attr_name = cb[3]
    docstring = "\"\"\"
```
$(fun_name)(f::Function)
```
creates a `$(cb[1])` that can be supplied as callback argument to `$(fun_name2)`.
The callback will be triggered once the read operation has been carried out.

`f` must be a Julia function with the following signature:
```
f(client::Ptr{UA_Client}, userdata::Ptr{Cvoid}, requestid::UA_UInt32, 
    status::UA_StatusCode, $(attr_name))::$(String(attr_type)))::Nothing
```
\"\"\"\n"
    global addedString = addedString * docstring *
                  "function $(fun_name)(f)
                      argtuple = (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode,
                          $attr_type)
                      returntype = Nothing
                      ret = Base.return_types(f, argtuple)
                      if length(methods(f)) == 1 && hasmethod(f, argtuple) && !isempty(ret)  && ret[1] == returntype
                          callback = @cfunction(\$f, Cvoid, 
                              (Ptr{UA_Client}, Ptr{Cvoid}, UA_UInt32, UA_StatusCode, $attr_type)) 
                          return callback
                      else
                          err = CallbackGeneratorArgumentError(f, argtuple, returntype)
                          throw(err)
                      end
                  end

                  "
end
write(f, orig_content * addedString)
close(f)
