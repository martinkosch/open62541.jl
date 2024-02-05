#Client service request error
struct ClientServiceRequestError <: Exception
    err::String
end

function Base.showerror(io::IO, e::ClientServiceRequestError)
    print(io, e.err)
end

#Attribute error (server and client)
struct AttributeReadWriteError <: Exception
    action::String
    mode::String
    side::String
    attributename::String
    statuscode::UInt32
end

function Base.showerror(io::IO, e::AttributeReadWriteError)
    print(io,
        "$(e.action) $(e.mode) ´$(e.attributename)´ by UA_$(e.side) failed with statuscode \"$(UA_StatusCode_name_print(e.statuscode))\".")
end

#Attribute copy error
struct AttributeCopyError <: Exception
    statuscode::UInt32
end

function Base.showerror(io::IO, e::AttributeCopyError)
    msg = "Copying attribute object failed with statuscode 
        \"$(UA_StatusCode_name_print(e.statuscode))\"."
    print(io, msg)
end

#Callback generator argument error 
#fields intentionally kept abstract; no specialization needed.
struct CallbackGeneratorArgumentError <: Exception
    f::Any
    argtuple::Any
    returntype::Any
end

function Base.showerror(io::IO, e::CallbackGeneratorArgumentError)
    m = methods(e.f)
    if length(m) > 1
        msg = "The provided function ($(e.f)) has more than one method; it is 
        unclear which one should be used as basis of the callback."
    else
        args_in = fieldtypes(first(methods(e.f)).sig)
        @show args_in[2:end]
        @show e.f, e.argtuple, methods(e.f), args_in
        ret = Base.return_types(e.f, args_in[2:end])[1]
        msg = "Callback generator expected a method with f($(join([e.argtuple...], ", ")))::$(string(e.returntype)), 
            but received a method f($(join(args_in[2:end], ", ")))::$(string(ret))." #TODO: does the job, but it's an ugly error message
    end
    print(io, msg)
end
