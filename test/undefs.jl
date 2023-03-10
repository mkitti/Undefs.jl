using Test
using Undefs

@testset "undefs function" begin
    A = undefs(10, 10)
    @test size(A) == (10, 10)
    @test eltype(A) == Float64

    A = undefs((10, 10))
    @test size(A) == (10, 10)
    @test eltype(A) == Float64

    A = undefs(Int, 5, 15)
    @test size(A) == (5, 15)
    @test eltype(A) == Int

    A = undefs(Int, (5, 15))
    @test size(A) == (5, 15)
    @test eltype(A) == Int

    A = undefs(Int32, Int32(4), Int32(20)) 
    @test size(A) == (4, 20)
    @test eltype(A) == Int32

    A = undefs(Int32, Int32.((4,20))) 
    @test size(A) == (4, 20)
    @test eltype(A) == Int32

    A = undefs(Array, Int, 5, 6)
    @test size(A) == (5,6)
    @test eltype(A) == Int

    A = undefs(Array, Float64, (6,9))
    @test size(A) == (6,9)
    @test eltype(A) == Float64

    @test_throws ArgumentError undefs(Array{Float64}, Int, 3, 2)
end
