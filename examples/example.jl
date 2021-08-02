using Lynx
using Luxor

function App()
    offset = [0., 1000.]
    points = Point[]

    function update(dt, canvas)
        background("black")
        sethue("yellowgreen")

        x = noise(offset[1]) * canvas.width
        y = noise(offset[2]) * canvas.height
        
        circle(x, y, 4, :fill)
        push!(points, Point(x, y))
        poly(points, :stroke)

        offset .+= 2dt

        if length(points) > 50
            # remove the first point
            splice!(points, 1)
        end
    end

    Window("Basic example", 800, 600,
        Paned(:v, position = 520,
            Canvas(update)
        ) # Paned
    ) # Window
end

Lynx.showall(App())