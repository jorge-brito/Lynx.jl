@testset "Basic" begin

    Lynx.init("Hello, world!", 400, 400)

    @test @window() isa Window
    @test @canvas() isa Canvas

    function setup()
        @test @width() == 400
        @test @height() == 400
        @test size(@canvas) == (400, 400)
        @info "Setup"
    end
    
    # drawing is done here
    function update(dt)
        @info "update"
    end
    
    run!(update, setup, await=false)
end