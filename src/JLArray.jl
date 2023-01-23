struct JLArray
    data::Ptr{Nothing}
    length::Csize_t
    flags::UInt16
    elsize::UInt16
    offset::UInt32
    nrows::Csize_t
    ncols::Csize_t
end
function Base.getproperty(jl_array::JLArray, s::Symbol)
    s == :maxsize && return getfield(jl_array, :ncols)
    flags = getfield(jl_array, :flags)
    s == :how       ?  flags & 0b0000000000000011       :
    s == :ndims     ? (flags & 0b0000011111111100) >> 2 :
    s == :pooled    ?  flags & 0b0000100000000000  != 0 :
    s == :ptrarray  ?  flags & 0b0001000000000000  != 0 :
    s == :hasptr    ?  flags & 0b0010000000000000  != 0 :
    s == :isshared  ?  flags & 0b0100000000000000  != 0 :
    s == :isaligned ?  flags & 0b1000000000000000  != 0 :
    getfield(jl_array, s)
end
Base.propertynames(x::JLArray) = (
    fieldnames(JLArray)...,
    :maxsize, :how, :ndims, :pooled, :ptrarray, :hasptr, :isshared, :isaligned
)

JLArray(array::Array) =
    unsafe_load(Ptr{JLArray}(pointer(array) - sizeof(JLArray)))

function isptrarray(array::Array)
    jla = JLArray(array)
    return jla.ptrarray
end
