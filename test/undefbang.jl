using Test
using Undefs

const gclog = falses(5)

@testset "undef!" begin
    mutable struct Foo
        function Foo(i)
            self = new()
            finalizer(self) do x
                gclog[i] = true
                # @async @show i
            end
        end
    end

    A = Array{Foo}(undef, 5)
    @test !isassigned(A, 3)
    A .= [Foo(i) for i in eachindex(A)]
    @test isassigned(A, 3)
    @undef! A[3]
    @test !isassigned(A, 3)
    @test isassigned(A, 1)
    @test isassigned(A, 2)
    @test isassigned(A, 4)
    @test isassigned(A, 5)
    @undef! A[1]
    @undef! A[2]
    @undef! A[4]
    @undef! A[5]
    @test !isassigned(A, 1)
    @test !isassigned(A, 2)
    @test !isassigned(A, 4)
    @test !isassigned(A, 5)

    B = Array{Foo}(undef, 5, 5)
    @test !isassigned(B, 3, 2)
    B[3,2] = Foo(1)
    @test isassigned(B, 3, 2)
    @undef! B[3,2]
    @test !isassigned(B, 3, 2)
end

GC.gc()

sleep(1)

@test gclog[3]
