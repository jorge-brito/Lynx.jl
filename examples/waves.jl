using Lynx
using Colors
using Luxor

App("Waves", 800, 600)

const settings = (
    # background color
    bgcolor = "black",
    # offset range
    offset = -50:50,
    # particle density
    detail = 3,
    # number of waves
    waves = 5,
    # particle size
    radius = 2,
    # animation speed
    speed = 1.8,
    # wave frequency
    frequency = 1,
    # wave amplitude
    amplitude = 1.5
)

function Waves()
    @unpack bgcolor, detail, waves = settings
    @unpack offset, radius, speed = settings
    @unpack frequency, amplitude = settings

    t = 0.0
    ω, A = frequency, amplitude
    f(x) = A * cos(ω * x + t)

    function update(dt)
        background(bgcolor)
        w, h = size(@canvas)
        dx = w / 4π
        for sx in 0:(dx / detail):w
            x = mapr(sx, 0:w, -2π:2π)
            sy = mapr(f(x), -2π:2π, 0:h)
            for n in 0:waves
                λ = mapr(n, 0:waves, offset)
                hue = mapr(n / waves, 0:360)
                sethue(HSL(hue, .8, .7))
                circle(sx + λ, sy + λ, radius, :fill)
            end
        end

        t += dt * speed
    end
end

run!(Waves(), await = true)