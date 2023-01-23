using Undefs
using Test

const gclog2 = falses(5)


mutable struct Bar
    function Bar(i)
        self = new()
        finalizer(self) do x
            gclog2[i] = true
            # @async @show i
        end
    end
end

bar = [Bar(5)]
bar[1] = Bar(1)

@undef! bar[1]
GC.gc()

sleep(1)

@testset "Garbage collection test" begin
    @test gclog2[5]
    @test gclog2[1]
end
