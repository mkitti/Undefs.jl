var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = Undefs","category":"page"},{"location":"#Undefs","page":"Home","title":"Undefs","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for Undefs.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [Undefs]","category":"page"},{"location":"#Undefs.Undefs","page":"Home","title":"Undefs.Undefs","text":"Undefs\n\nSee [`undefs`](@ref)\n\n\n\n\n\n","category":"module"},{"location":"#Undefs.undefs-Union{Tuple{T}, Tuple{Type{T}, Tuple{Vararg{Integer}}}} where T","page":"Home","title":"Undefs.undefs","text":"undefs([T=Float64], dims::Tuple)\nundefs([T=Float64], dims::Integer...)\n\nCreate an Array, with element type T, of undefined elements with size specified by dims. See also fill, ones, zero.\n\njulia> undefs(3, 2)\n3×2 Matrix{Float64}:\n 1.42603e-105  1.42603e-105\n 1.42603e-105  1.42603e-105\n 1.42603e-105  1.42603e-105\n\njulia> undefs(Int, 4, 5)\n4×5 Matrix{Int64}:\n 0  0  0  0  0\n 0  0  0  0  0\n 0  0  0  0  0\n 0  0  0  0  0\n\njulia> undefs(Int8, (1,2,3))\n1×2×3 Array{Int8, 3}:\n[:, :, 1] =\n 0  0\n\n[:, :, 2] =\n 0  0\n\n[:, :, 3] =\n 0  0\n\njulia> undefs(Int8, (2,3))\n2×3 Matrix{Int8}:\n -96  119   60\n 103  -15  127\n\njulia> fill!(undefs(Int8, (2,3)), 0)\n2×3 Matrix{Int8}:\n 0  0  0\n 0  0  0\n\nThis is a convenience method for Array{T}(undef, dims). It is recommended to use the above invocation since it allows array types other than Array to be constructed via similar syntax.\n\nSee also fill!, zeros, ones\n\n\n\n\n\n","category":"method"}]
}