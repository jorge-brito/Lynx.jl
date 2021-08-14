using Lynx
using Luxor
using Colors

init("Random particles", 800, 600)

N = 100
xoff = 0.
yoff = 1000.

function update(dt)
    global xoff, yoff;
    background("#111")

    for n in 1:N
        x = noise(xoff + n) * @width
        y = noise(yoff + n) * @height
        hue = mapr(n, 1:N, 0:360)
        color = HSL(hue, .85, .65)
        sethue(color)
        circle(x, y, 5, :fill)
    end

    sethue("white")
    fontsize(14)
    fps = floor(Int, @framerate)
    text("Framerate: $(fps)fps", @width()/2, 20, halign = :center)

    xoff += 0.5 * dt
    yoff += 0.5 * dt
end

run!(update)