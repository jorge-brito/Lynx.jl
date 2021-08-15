using Lynx
using Test
using Observables
using Colors

var"@asset_str"(::LineNumberNode, ::Module, path) = joinpath(@__DIR__, "..", "assets", path)

include("input.jl")
include("widgets.jl")

@testset "Examples" begin
    include("../examples/basic.jl")
    include("../examples/events.jl")
    include("../examples/images.jl")
    include("../examples/random.jl")
end