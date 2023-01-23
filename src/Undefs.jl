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

    const IDims = Tuple{Vararg{<: Integer}}

    struct Undef end

    """
        undefs([T=Float64], dims::Tuple)
        undefs([T=Float64], dims::Integer...)

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

    include("JLArray.jl")

    """
        undef!(array::Array, index=1)

    Reset an element of an array to be `#undef`.
    """
    function undef!(array::Array, index::Integer=1)
        checkbounds(array, index)
        _undef!(array, index)
    end

    function undef!(array::Array, I::Integer...)
        checkbounds(array, I...)
        _undef!(array, LinearIndices(array)[I...])
    end

    # undef! without any bounds checking
    function _undef!(array::Array, index::Integer=1)
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

    macro undef!(ex)
        ex.head == :ref || throw(ArgumentError("@undef! can only be applied to array linear indexing expression"))
        args = esc.(ex.args)
        ex_out = Expr(:call, undef!, args...)
        return ex_out
    end
end
