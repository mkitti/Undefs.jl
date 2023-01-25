module JLArrays

export JLArray, isptrarray

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

function Base.show(io::IO, ::MIME"text/plain", jla::JLArray)
    println(io, typeof(jla), ":")
    println(io, "   data: $(jla.data)")
    println(io, " length: $(jla.length)")
    println(io, "  flags: $(bitstring(jla.flags))")
    println(io, "        how: $(jla.how) ($(how(jla.how)))")
    println(io, "      ndims: $(jla.ndims)")
    println(io, "     pooled: $(jla.pooled)")
    println(io, "   ptrarray: $(jla.ptrarray)")
    println(io, "   isshared: $(jla.isshared)")
    println(io, "  isaligned: $(jla.isaligned)")
    println(io, " elsize: $(jla.elsize)")
    println(io, " offset: $(jla.offset)")
    println(io, "  nrows: $(jla.nrows)")
    if jla.ndims == 1
        println(io, "maxsize: $(jla.ncols)")
    else
        println(io, "  ncols: $(jla.ncols)")
    end
    println(io, "  other: $(jla.other)")
end

function how(i)
    i == 0 ? "data is inlined, or a foreign pointer we don't manage" :
    i == 1 ? "julia-allocated buffer that needs to be marked" :
    i == 2 ? "malloc-allocated pointer this array object manages" :
    i == 3 ? "has a pointer to the object that owns the data" :
    error("Unknown how: $how")
end

end
