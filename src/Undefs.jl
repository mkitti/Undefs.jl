"""
    Undefs

    See [`undefs`](@ref)
"""
module Undefs
    export undefs


    const IDims = Tuple{Vararg{<: Integer}}

    """
        undefs([T=Float64], dims::Tuple)
        undefs([T=Float64], dims::Integer...)

    Create an Array, with element type T, of undefined elements with size
    specified by dims. See also fill, ones, zero.

    ```jldoctest
    julia> undefs(3, 2)
    3×2 Matrix{Float64}:
     1.42603e-105  1.42603e-105
     1.42603e-105  1.42603e-105
     1.42603e-105  1.42603e-105

    julia> undefs(Int, 4, 5)
    4×5 Matrix{Int64}:
     0  0  0  0  0
     0  0  0  0  0
     0  0  0  0  0
     0  0  0  0  0

    julia> undefs(Int8, (1,2,3))
    1×2×3 Array{Int8, 3}:
    [:, :, 1] =
     0  0

    [:, :, 2] =
     0  0

    [:, :, 3] =
     0  0

    julia> undefs(Int8, (2,3))
    2×3 Matrix{Int8}:
     -96  119   60
     103  -15  127

    julia> fill!(undefs(Int8, (2,3)), 0)
    2×3 Matrix{Int8}:
     0  0  0
     0  0  0
    ```

    This is a convenience method for `Array{T}(undef, dims)`. It is
    recommended to use the above invocation since it allows array types other
    than `Array` to be constructed via similar syntax.

    See also `fill!`, `zeros`, `ones`
    """
    undefs(::Type{T}, dims::IDims) where T = Array{T}(undef, dims)
    undefs(dims::IDims) = undefs(Float64, dims)
    undefs(::Type{T}, dims::Integer...) where T = undefs(T, dims)
    undefs(dims::Integer...) = undefs(Float64, dims)
end
