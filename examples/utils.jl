var"@asset_str"(::LineNumberNode, ::Module, path) = joinpath(@__DIR__, "..", "assets", path)

mutable struct Mouse
    x::Real
    y::Real
    dx::Real
    dy::Real
    zoom::Real
    Mouse() = new()
end

function Mouse(canvas::Canvas)
    this = Mouse()
    this.zoom = 1
    onmousemove(canvas) do event
        if isdefined(this, :x)
            this.dx = event.x - this.x
            this.dy = event.y - this.y
        end
        this.x = event.x
        this.y = event.y
    end
    onscroll(canvas) do event
        dir = event.direction
        this.zoom += 0.1 * dir
    end
    return this
end

Luxor.Point(this::Mouse) = Point(this.x, this.y)