using Lynx
using Luxor

Lynx.init("Hello, world!", 400, 400)

t = 0

# drawing is done here
function update(dt)
    background("#111")
    origin()
    sethue("yellowgreen")
    circle(O, 50(cos(t) + 1), :fill)
    global t += dt
end

# await=true will make sure the program only
# stops when the window is closed
run!(update, await=true)