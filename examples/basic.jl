using Lynx
using Luxor

Lynx.init("Hello, world!", 400, 400)

t = 0

function setup()
    # this function is called
    # when the window is created
    @info "Starting"
end

# drawing is done here
function update(dt)
    @info "Updating..."
    background("#111")
    origin()
    sethue("yellowgreen")
    circle(O, 50(cos(t) + 1), :fill)
    global t += dt
end

# await=true will make sure the program only
# stops when the window is closed
run!(update, setup, await=true)