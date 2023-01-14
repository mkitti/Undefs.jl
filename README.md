# Undefs.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mkitti.github.io/Undefs.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mkitti.github.io/Undefs.jl/dev/)
[![Build Status](https://github.com/mkitti/Undefs.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mkitti/Undefs.jl/actions/workflows/CI.yml?query=branch%3Amain)

This is a convenience package for constructing and working with Julia Arrays with undefined elements.

The standard syntax for creating an array with undefined elements, also called an "empty array" in some languages, is the following

```julia
T = Int64
dims = (3, 4)
A = Array{T}(undef, dims)
B = Array{T}(undef, 4, 5)
C = Array{Float64}(undef, 4, 5)
```

This package allow you to do the same as above via the following syntax.

```julia
using Undefs
A = undefs(Int64, (3, 4))
B = undefs(Int64, 4, 5)
C = undefs(4, 5) # uses a Float64 element type
```

This package is for convenience only. I recommend using the standard syntax over using this package.
The standard syntax allows you to construct other types of arrays and or other similar parameterized types.
