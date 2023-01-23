using Undefs: JLArray, isptrarray
using Test

@testset "JLArray" begin
    A = rand(5, 3)
    B = Matrix{Vector{Int}}(undef, 7, 4)
    C = Vector{Bool}(undef, 9)
    D = Array{Int32}(undef, 3, 4, 5)

    jla = JLArray(A)
    @test jla.data == pointer(A)
    @test !jla.ptrarray
    @test !isptrarray(A)
    @test jla.how == 0
    @test jla.length == 15
    @test jla.ncols == 3
    @test jla.nrows == 5
    @test jla.ndims == 2
    @test !jla.hasptr
    @test !jla.isshared
    @test jla.isaligned

    jla = JLArray(B)
    @test jla.data == pointer(B)
    @test jla.ptrarray
    @test isptrarray(B)
    @test jla.how == 0
    @test jla.length == 28
    @test jla.ncols == 4
    @test jla.nrows == 7
    @test jla.ndims == 2
    @test !jla.hasptr
    @test !jla.isshared
    @test jla.isaligned

    jla = JLArray(C)
    @test jla.data == pointer(C)
    @test !jla.ptrarray
    @test !isptrarray(C)
    @test jla.how == 0
    @test jla.length == 9
    @test jla.maxsize == 9
    @test jla.nrows == 9 
    @test jla.ndims == 1
    @test !jla.hasptr
    @test !jla.isshared
    @test jla.isaligned

    jla = JLArray(D)
    @test jla.data == pointer(D)
    @test !jla.ptrarray
    @test !isptrarray(D)
    @test jla.how == 0
    @test jla.length == 60
    @test jla.ncols == 4
    @test jla.nrows == 3
    @test jla.ndims == 3
    @test !jla.hasptr
    @test !jla.isshared
    @test jla.isaligned

    ptr = Libc.malloc(1024)
    E = unsafe_wrap(Array, Ptr{Int32}(ptr), (8, 32))
    jla = JLArray(E)
    @test jla.data == pointer(E)
    @test !jla.ptrarray
    @test !isptrarray(E)
    @test jla.how == 0
    @test jla.length == 256
    @test jla.ncols == 32
    @test jla.nrows == 8
    @test jla.ndims == 2
    @test !jla.hasptr
    @test jla.isshared
    @test !jla.isaligned

    F = unsafe_wrap(Array, Ptr{Int32}(ptr), (8, 2, 2, 2, 4); own = true)
    jla = JLArray(F)
    @test jla.data == pointer(F)
    @test !jla.ptrarray
    @test !isptrarray(F)
    @test jla.how == 2
    @test jla.length == 256
    @test jla.ncols == 2
    @test jla.nrows == 8
    @test jla.ndims == 5
    @test !jla.hasptr
    @test jla.isshared
    @test !jla.isaligned


end