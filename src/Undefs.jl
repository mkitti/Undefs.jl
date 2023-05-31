"""
    Undefs

    See [`undefs`](@ref) which is a convenience method for
    `Array{T}(undef, dims...)` which is recommended over using this package.

    Also consider alternatives such as
    [ArrayAllocators.jl](https://github.com/mkitti/ArrayAllocators.jl] which
    provides as `ArrayAllocators.zeros` method offering similar performance.
"""
module Undefs
    export undefs, undef!, @undef!
    
    include("JLArrays.jl")

    using .JLArrays: JLArray, isptrarray

    const IDims = Tuple{Vararg{Integer}}

    struct Undef end

    """
        undefs([A=Array], [T=Float64], dims::Tuple)
        undefs([A=Array], [T=Float64], dims::Integer...)

    Create an Array, with element type T, of undefined elements with size
    specified by dims. See also fill, ones, zero.

    ```julia
    julia> undefs(3, 2)
    3×2 Matrix{Float64}:
    ...

    julia> undefs(Int, 4, 5)
    4×5 Matrix{Int64}:
    ...

    julia> undefs(Int8, (1,2,3))
    1×2×3 Array{Int8, 3}:
    ...

    julia> undefs(Int8, (2,3))
    2×3 Matrix{Int8}:
    ...

    julia> fill!(undefs(Int8, (2,3)), 0)
    2×3 Matrix{Int8}:
     0  0  0
     0  0  0
    ```

    This is a convenience method for `Array{T}(undef, dims)`. It is
    recommended to use the above invocation since it allows array types other
    than `Array` to be constructed via similar syntax.

    See also `fill!`, `zeros`, `ones`, `ArrayAllocators.zeros`
    """
    undefs(::Type{T}, dims::IDims) where T = Array{T}(undef, dims)
    undefs(dims::IDims) = undefs(Float64, dims)
    undefs(::Type{T}, dims::Integer...) where T = undefs(T, dims)
    undefs(dims::Integer...) = undefs(Float64, dims)

    undefs(::Type{A}, ::Type{T}, dims::IDims) where {T, A <: AbstractArray{T}} = A(undef, dims)
    undefs(::Type{A}, ::Type{T}, dims::Integer...) where {T, A <: AbstractArray{T}} = A(undef, dims)

    undefs(::Type{A}, ::Type{T2}, dims::IDims) where {T, T2, A <: AbstractArray{T}} =
        throw(ArgumentError("Cannot create an array of type $A with elements of type $T2"))
    undefs(::Type{A}, ::Type{T2}, dims::Integer...) where {T, T2, A <: AbstractArray{T}} =
        throw(ArgumentError("Cannot create an array of type $A with elements of type $T2"))
    
    undefs(::Type{A}, ::Type{T}, dims::IDims) where {T, A <: AbstractArray} = A{T}(undef, dims)
    undefs(::Type{A}, ::Type{T}, dims::Integer...) where {T, A <: AbstractArray} = A{T}(undef, dims)


    """
        undef!(array::Array, index=1)

    Reset an element of an array to be `#undef`.

    The method is highly experimental and uses undocumented internal details
    which may change.
    """
    function undef!(array::Array, index::Integer=1)
        _undef!(array, index)
    end

    function undef!(array::Array, I::Integer...)
        checkbounds(array, I...)
        _undef!(array, LinearIndices(array)[I...])
    end

    # undef! without any bounds checking
    @inline function _undef!(array::Array, index::Integer=1)
        Base._unsetindex!(array, index)
    end

    # old definition, without any bounds checking
    function _old_undef!(array::Array, index::Integer=1)
        if isptrarray(array)
            GC.@preserve array begin
                ptr = Ptr{Ptr{Nothing}}(pointer(array))
                unsafe_store!(ptr, C_NULL, index)
            end
        else
            throw(ArgumentError("Cannot apply `undef!` to an array that is not a pointer array"))
        end
        return nothing
    end

    @static if !isdefined(Base, :allocatedinline)
        allocatedinline(::Type{T}) where T = T.isinlinealloc
        allocatedinline(U::Union) = Base.isbitsunion(U)
    else
        using Base: allocatedinline
    end

    """
        undef!(ref::Base.RefValue{T}) where T

    Reset the target of a `Ref` to be `#undef`.

    The method is highly experimental and uses undocumented internal details
    which may change.
    """
    function undef!(ref::Base.RefValue{T}) where T
        if !allocatedinline(T)
            ptr = Ptr{Ptr{Nothing}}(pointer_from_objref(ref))
            unsafe_store!(ptr, C_NULL)
        else
            error("Cannot undef! a Ref of a type, $T, that is allocated inline.")
        end
    end

    """
        @undef! array[i]
        @undef! ref[]

    Reset the indexed element to be `#undef`.

    The underlying method is highly experimental and uses undocumented internal
    details which may change.
    """
    macro undef!(ex)
        ex.head == :ref || throw(ArgumentError("@undef! can only be applied to an array or reference indexing expression"))
        args = esc.(ex.args)
        ex_out = Expr(:call, undef!, args...)
        return ex_out
    end
end
