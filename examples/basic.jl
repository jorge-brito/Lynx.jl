using Lynx
using Luxor

Lynx.init("Basic Example", 800, 600)

function setup()
    @info "Canvas width is $(@width) and height is $(@height)"
end

time = 0.

function update(dt)
    background("#111")
    sethue("yellowgreen")
    origin()

    radius = 50 * (cos(time) + 2)
    circle(O, radius, :fill)

    global time += dt
end

run!(update, setup)