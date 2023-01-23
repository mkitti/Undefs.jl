using Undefs
using Test

@testset "Undefs.jl" begin
    include("undefs.jl")
    include("undefbang.jl")
    include("gctest.jl")
end
