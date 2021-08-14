using Lynx
using Luxor

Lynx.init("Events", 800, 600)

mouse = Point(0, 0)

function update(dt)
    background("black")
    sethue("#1fe")
    circle(mouse, 50, :fill)
end

onkeypress(@window) do event
    key = keyname(event)
    @info "Key $key pressed!" code=event.keyval
end

onevent(:destroy, @window) do win
    @info "Window has been closed!"
end

onmousemove(@canvas) do event
    global mouse = Point(event.x, event.y)
    @info "Mouse moved to $(mouse)"
end

onmousedown(@canvas) do event
    x, y = event.x, event.y
    btn = event.button
    @info "Mouse pressed at ($x, $y) with button $btn"
end

onmouseup(@canvas) do event
    x, y = event.x, event.y
    btn = event.button
    @info "Mouse released at ($x, $y) with button $btn"
end

onmousedrag(@canvas) do event
    x, y = event.x, event.y
    btn = event.button
    @info "Mouse drag at ($x, $y) with button $btn"
end

run!(update)