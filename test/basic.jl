@testset "Basic" begin

    Lynx.init("Hello, world!", 400, 400)

    @test @window() isa Window
    @test @canvas() isa Canvas
    
    # drawing is done here
    function update(dt)
        @info "update"
    end
    
    # run!(update, setup, await=false)
end