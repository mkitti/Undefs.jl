# Undefs.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mkitti.github.io/Undefs.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mkitti.github.io/Undefs.jl/dev/)
[![Build Status](https://github.com/mkitti/Undefs.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mkitti/Undefs.jl/actions/workflows/CI.yml?query=branch%3Amain)

This is a convenience package for constructing and working with Julia Arrays with undefined elements. I strongly urge you to seek alternatives which may be as performant as the methods provided in this package while still being as performant. In particular, consider [`ArrayAllocators.zeros`](https://github.com/mkitti/ArrayAllocators.jl) or `ArrayAllocators.calloc`.

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

# Alternatives

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
