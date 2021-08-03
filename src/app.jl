"""
An `LynxApp` is a basic structure that holds a `window`, a `canvas`
and other `widgets` to make a interactive application with a
few lines of code.
"""
mutable struct LynxApp
    window::Widget
    canvas::Canvas
    framerate::Float64
    targetfps::Float64
    widgets::Vector{<:Widget}
    layout::Function
    loop::Bool
    LynxApp() = new()
end

const CURRENT_APP = Ref{LynxApp}()

function getapp()
    if isassigned(CURRENT_APP)
	    return CURRENT_APP[]
    else
	    error("No LynxApp has been created. Create one before using this function.")
    end
end

function setapp(app::LynxApp)
    CURRENT_APP[] = app
end

"""
	@app() -> LynxApp

Returns the current `LynxApp` or throws an exception
if no LynxApp has been created.
"""
var"@app"(args...) = :( getapp() )

"""
	@canvas() -> Canvas

Returns the current `Canvas`.
"""
var"@canvas"(args...) = :( getapp().canvas )

"""
	@window() -> Window

Returns the current `Window`.
"""
var"@window"(args...) = :( getapp().window )
"""
        @width -> Int

The width of the current canvas.
"""
var"@width"(args...) = :( width(getapp().canvas) )
"""
        @height -> Int

The height of the current canvas.
"""
var"@height"(args...) = :( height(getapp().canvas) )
"""
        @size -> Tuple{Int, Int}

The width and height of the current canvas.
"""
var"@size"(args...) = :( size(getapp().canvas) )

"""
	@framerate() -> Float64

Returns the current `framerate`.
"""
var"@framerate"(args...) = :( getapp().window )

"""
        @use widget

Adds the `widget` to the current application and returns it.
"""
var"@use"(::LineNumberNode, ::Module, expr) = esc(Expr(:call, :use!, expr))

"""
	loop!(x::Bool)

Whether or not the `update` function should be called every frame.
"""
loop!(x::Bool) = setproperty!(@app, :loop, x)

"""
	framerate!(x::Real)

Sets the current framerate.
"""
framerate!(x::Real) = x > 0 ? setproperty!(@app, :targetfps, x) : @warn "Framerate must be positive" received=x

"""
	layout!(layout::Function)

Sets the current layout.
"""
layout!(layout::Function) = setproperty!(@app, :layout, layout)

"""
        use!(widget) -> Widget

Adds the `widget` to the current application and returns it.
"""
use!(widget::Widget) = (push!(getapp().widgets, widget); widget)

"""
        init(title, width, height; layout = CanvasOnly) -> LynxApp

Creates a new [`LynxApp`](@ref).
"""
function init(title::String, width::Int, height::Int; layout::Function = CanvasOnly)
    app = LynxApp()
    app.window = Window(title, width, height)
    app.canvas = Canvas()
    app.targetfps = 60.0
    app.framerate = 0.0
    app.layout = layout
    app.loop = true
    app.widgets = Widget[]
    setapp(app)
    return app
end

function dontloop!(canvas::Canvas)
    gtk_widget_remove_tick_callback(gwidget(canvas), canvas.tickcb)
end

"""
        run!(update::Function [, setup::Function]; await = false, hotreload = false)

Run the current `LynxApp` with the given `update` function. 
If `await` is true, the main task will be blocked until 
the user closes the window. If `hotreload` is true, only 
the newest version of `update` will be called.

You can also specify a `setup` function that will be called when
the window is created.
"""
function run!(update::Function, setup::Function = () -> nothing; await::Bool = false, hotreload::Bool = false)
    app = @app
    body = app.layout(app.window, app.canvas, app.widgets...)
    @assert body isa Widget "The return of a layout must be a Widget. Received $(typeof(body))"
    push!(app.window, body)

    setup_called = false

    onupdate(app.canvas; framerate = app.targetfps, hotreload) do dt
        if !setup_called
            setup()
            setup_called = true
        else
            update(dt)
            if app.loop
                app.framerate = inv(dt)
            else
                dontloop!(app.canvas)
            end
        end
    end
    
    showall(app.window)
    await && @waitfor app.window.destroy
    return nothing
end