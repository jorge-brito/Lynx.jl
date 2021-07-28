using Lynx
using Luxor

function App()
    canvas = Canvas()
    x, y = 0, 0

    onmousemove(canvas) do event
        x = event.x
        y = event.y
    end

    onmousedown(canvas) do event
        pos = event.x, event.y
        btn = event.button
        @info "Clicked at $pos with button $btn"
    end

    onmouseup(canvas) do event
        pos = event.x, event.y
        btn = event.button
        @info "Click released at $pos with button $btn"
    end

    onmousedrag(canvas) do event
        pos = event.x, event.y
        btn = event.button
        @info "Mouse drag at $pos with button $btn"
    end

    onupdate(canvas) do dt
        background("white")
        sethue("#111")
        circle(x, y, 50, :fill)
    end

    Window("Canvas Test", 800, 600, children = (
        canvas
    )) # Window
end

showall(App())