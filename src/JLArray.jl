struct JLArray{O}
    data::Ptr{Nothing}
    length::Csize_t
    flags::UInt16
    elsize::UInt16
    offset::UInt32
    nrows::Csize_t
    ncols::Csize_t
    other::O
end
@static if VERSION ≥ v"1.4.0"
    function Base.getproperty(jl_array::JLArray, s::Symbol)
        s == :maxsize && return getfield(jl_array, :ncols)
        flags = getfield(jl_array, :flags)
        s == :how       ?  flags & 0b0000000000000011       : # 2
        s == :ndims     ? (flags & 0b0000011111111100) >> 2 : # 9
        s == :pooled    ?  flags & 0b0000100000000000  != 0 : # 1
        s == :ptrarray  ?  flags & 0b0001000000000000  != 0 : # 1
        s == :hasptr    ?  flags & 0b0010000000000000  != 0 : # 1
        s == :isshared  ?  flags & 0b0100000000000000  != 0 : # 1
        s == :isaligned ?  flags & 0b1000000000000000  != 0 : # 1
        getfield(jl_array, s)
    end
    Base.propertynames(x::JLArray) = (
        fieldnames(JLArray)...,
        :maxsize, :how, :ndims, :pooled, :ptrarray, :hasptr, :isshared, :isaligned
    )
else
    # The hasptr flag was introduced in Julia 1.4
    # https://github.com/JuliaLang/julia/pull/33886
    function Base.getproperty(jl_array::JLArray, s::Symbol)
        s == :maxsize && return getfield(jl_array, :ncols)
        flags = getfield(jl_array, :flags)
        s == :how       ?  flags & 0b0000000000000011       : # 2
        s == :ndims     ? (flags & 0b0000111111111100) >> 2 : # 10
        s == :pooled    ?  flags & 0b0001000000000000  != 0 : # 1
        s == :ptrarray  ?  flags & 0b0010000000000000  != 0 : # 1
        s == :isshared  ?  flags & 0b0100000000000000  != 0 : # 1
        s == :isaligned ?  flags & 0b1000000000000000  != 0 : # 1
        getfield(jl_array, s)
    end
    Base.propertynames(x::JLArray) = (
        fieldnames(JLArray)...,
        :maxsize, :how, :ndims, :pooled, :ptrarray, :isshared, :isaligned
    )
end

function JLArray{O}(array::Array) where O
    GC.@preserve array begin
        ptr = pointer(array)
        jla = unsafe_load(Ptr{JLArray{O}}(pointer_from_objref(array)))
        @assert jla.data == ptr
        jla
    end
end
JLArray(array::Array) = JLArray{Nothing}(array)

function isptrarray(array::Array)
    jla = JLArray(array)
    return jla.ptrarray
end