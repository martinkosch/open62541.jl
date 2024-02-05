#function that wraps a non-ref/non-ptr argument into a ref of appropriate type.
wrap_ref(x::Union{Ref, Ptr}) = x #no-op fall back
wrap_ref(x) = Ref(x)
