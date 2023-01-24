# Undefs.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mkitti.github.io/Undefs.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mkitti.github.io/Undefs.jl/dev/)
[![Build Status](https://github.com/mkitti/Undefs.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mkitti/Undefs.jl/actions/workflows/CI.yml?query=branch%3Amain)

Undefs.jl is a convenience and educational package for constructing and working with Julia Arrays with undefined elements. This package is not intended for production code.

I strongly urge you to seek alternatives which may be as performant as the methods provided in this package while being as effective and supported. In particular, consider [`ArrayAllocators.zeros`](https://github.com/mkitti/ArrayAllocators.jl) or `ArrayAllocators.calloc` if you need fast and safe array initialization. If you are interested in resetting an element to `#undef`, consider using a `Union{T,Nothing}` instead as an element type and using `nothing` to "unset" elements. The alternatives are discussed in more detail below.

# `undefs` array construction

The standard syntax in Julia for creating an array with undefined elements, also called an "empty array" in some languages, is the following.

```julia
T = Int64
dims = (3, 4)
A = Array{T}(undef, dims)
B = Array{T}(undef, 4, 5)
C = Array{Float64}(undef, 4, 5)
```

This package implements the method `undefs` that allows you to do the same as above via the following syntax.

```julia
using Undefs
A = undefs(Int64, (3, 4))
B = undefs(Int64, 4, 5)
C = undefs(4, 5) # uses a Float64 element type
```

This package is for convenience only. I recommend using the standard syntax over using this package or seeking alternatives (see below). The standard syntax allows you to construct other types of arrays and or other similar parameterized types in a similar fashion. Alternatives may be as performant and safer to use than this package.

## Alternatives to `undefs` array construction

`undefs`, while convenient, can be treacherous. Novices may easily confuse the method with producing a similar result to `zeros`, which eagerly and explicitly fills the array with zeros. `undefs` makes no guarantee what the resulting array will contain. Used incorrectly, `undefs` can lead to incorrect code that may not be easily detectable since `undefs` often returns arrays with all zero values.

Often, the motivation for reaching for `undefs` or `Array{T}(undef, ...)` is performance. However, there are methods to achieve this while avoiding the pitfalls of using `undefs`. For example, [`ArrayAllocators.jl`](https://github.com/mkitti/ArrayAllocators.jl) provides several alternative mechanisms to obtaining zeroed arrays that may provide similar performance to use `Undefs.undefs`.

```julia
julia> using Undefs, ArrayAllocators

# Some warmup may be required here

julia> @time ArrayAllocators.zeros(Int, 2048, 2048);
  0.000025 seconds (3 allocations: 32.000 MiB)

julia> @time Array{Int}(calloc, 2048, 2048);
  0.000028 seconds (3 allocations: 32.000 MiB)

julia> @time undefs(Int, 2048, 2048);
  0.000046 seconds (2 allocations: 32.000 MiB)
```

## Discussion of `undefs`

The desire for a method called `undefs` originates from the existence of similar methods such as `zeros`, `ones`, `trues`, and `falses`. These are convenience methods that eagerly allocate and initialize the arrays they construct. Array construction via `Array{T}(undef, dims)` outperforms these methods because it does *not* do any array initialization. The resulting array may be full of arbitrary values. At times this can deceiving because the returned element values may be all zeros early in a Julia session. This behavior cannot be consistently relied upon as subsequent invocations will yield arrays filled with values other than zero. Arrays allocated in this manner can be eagerly initialized via the `fill!` method. `fill!` is used to implement the convenience methods.

The syntax `Array{T}(undef, dims)` allows for the selection of an array type, an element type, and the dimensions of the array. It also clearly indicates that the values will be undefined. Critics of this syntax may find it verbose. In particular, the introduction of curly braces for the array element type parameter may be unfamiliar to new users of Julia and contrasts with the simplicity of the convenience methods mentioned earlier that use a procedural syntax common among many programming languages. Those convenience methods assume a default array type, `Array`, and a default element type, `Float64`, reducing the verbosity. An `undefs` method could make similar assumptions as it does here.

The arguments for not including an `undefs` method in `Base` include introducing the type parameter syntax, discouraging use of uninitialized arrays by new users of Julia, and encouarging the consideration of other array types. The arguments contrast with the continued existence of the convenience methods, which may be less performant.

This package exports the convenience method `undefs` to advance the conversation on this topic while also leading users to the supported alternatives. By providing a package that provides this functionality the debate is no longer about the existence of `undefs` but whether such as method should be in `Base` or if its existence in a package such as this is useful.

# Experimental: Resetting elements of arrays and references to `#undef` via `undef!` and `@undef!`

This package also includes experimental support for resetting elements of arrays and referenes to `#undef`.

This can be done via the `undef!` function or the `@undef!` macro.

```julia
julia> mutable struct Foo end

julia> A = Array{Foo}(undef, 2)
2-element Vector{Foo}:
 #undef
 #undef

julia> A[1] = Foo()
Foo()

julia> isassigned(A, 1)
true

julia> @undef! A[1]

julia> A
2-element Vector{Foo}:
 #undef
 #undef

julia> isassigned(A, 1)
false
```

This is highly experimental and depends on Julia private internals which may change between minor versions of Julia.
Currently, this package is tested from Julia 1.0.5 through Julia 1.9.0-beta3 in limited circumstances. Use at your own risk.

## Alternatives to `undefs!`

Rather than using `undefs!` which is experimental and relies on Julia private internals, considering using a union type with `Nothing`.

```julia
julia> A = Array{Union{Foo,Nothing}}(nothing, 2)
2-element Vector{Union{Nothing, Foo}}:
 nothing
 nothing

julia> A[1] = Foo()
Foo()

julia> A
2-element Vector{Union{Nothing, Foo}}:
 Foo()
 nothing

julia> A[1] = nothing

julia> A
2-element Vector{Union{Nothing, Foo}}:
 nothing
 nothing
```

## Discussion of `undefs!`

`undefs!` depends on array layout details that are not intended to be exposed as part of the public interface of Julia. `#undef` occurs when Julia uses an array of pointers layout for arrays of elements of mutable or non-concrete types. An `#undef` indicates that those pointers are `NULL` pointers that point to nothing. Arrays of primitives or immutable bitstypes are in contrast laid out using an inline layout without indirection.

This package reads the internal array layout details to determine when an array of pointers layout is used. To return an element to an `#undef` state, `undef!` sets the corresponding pointer to be a `NULL` pointer, `C_NULL` or `Ptr{Nothing} @0x0000000000000000`. Problems can arise if this package incorrectly determines the layout type of the array.

Due to the use of internal array layout details, `undefs!` should be considered highly experimental. It's implementation here is mainly to elucidate the internal Julia array structure for educational purposes.
