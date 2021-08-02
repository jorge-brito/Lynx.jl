using Lynx
using Colors
using Luxor

App("Layout Test", 800, 600, layout = SideBar(
    size = .30,
    props = (
        margin = 15,
        spacing = 10
    )
))

function Waves()
    t = 0.0
    
    N       = @use Slider(1:100); value!(N, 20)
    input   = @use TextField("Hello, world!")
    spin    = @use SpinButton(-2π:π/8:2π)
    bg      = @use ColorButton("#111")

    function update(dt)
        background(bg[])
        fontsize(14)
        text(input[], 20, 20)
        text(string(spin[]), 20, 40)
    
        center = Point(width(@canvas)/2, height(@canvas)/2)
        for i in 1:N[]
            hue = mapr(i, 1:N[], 0:360)
            sethue(HSL(hue, .8, .7))
            circle(center, 10i * (cos(i * t / 2π) + 1), :stroke)
        end
        t += dt
    end
end

run!(Waves(), await = true)