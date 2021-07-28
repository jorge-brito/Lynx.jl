"""
Layouts are used to organize the `canvas` and other widgets
within the `window`.

They are simple function or callable structures.

Example of layout implementation:

```julia
struct MyLayout <: AbstractLayout
    fields...
    function MyLayout(args...)
        ...
    end
end

function (layout::MyLayout)(window, canvas, widgets...)
    ...
end
```

The `call` implementation of a layout should return a widget 
that contains (or not) the canvas and the widgets.
The returned widget will then be added to the window.
"""
abstract type AbstractLayout <: Function end

"""
The `canvas` is the only widget and fills the entire window.
"""
function CanvasOnly(::Widget, canvas::Canvas, widgets)
    for widget in widgets
        if widget isa AbstractWidget{T} where {T}
            @warn "Attempt to add widget of type $T, but the current layout is CanvasOnly."
        end
    end
    return canvas
end

"""
The `SideBar` layout divides the window between the `canvas`
and a `sidebar` containing the other widgets.
"""
struct SideBar <: AbstractLayout
    position::Symbol
    size::Real
    props::NamedTuple
end
"""
        SideBar(position = :left, size = .25, props = NamedTuple()) -> SideBar

Creates a [`SideBar`](@ref) layout. The `position` determines where the sidebar is placed relative 
to the canvas (can be either `:left` or `:right`). The `size` controls the width of the 
sidebar relative to the width of the window (must be a value between 0 and 1). You can 
also pass aditional properties for the sidebar widget using the `props` parameter.
"""
function SideBar(position = :left; size = .25, props = NamedTuple())
    @assert position in (:left, :right) "Invalid position '$position'. Valid positions are :left or :right"
    @assert size > 0 "Size cannot be negative"
    return SideBar(position, size, props)
end

function (this::SideBar)(window::Widget, canvas::Canvas, widgets)
    props = this.props
    if this.position == :left
        pos = floor(Int, width(window) * this.size)
        return Paned(:v, position = pos, children = (
            Box(:v, widgets...; props...), 
            canvas,
        )) # Paned
    else
        pos = floor(Int, width(window) - width(window) * this.size)
        return Paned(:v, position = pos, children = (
            Box(:v, widgets...; props...), 
            canvas,
        )) # Paned
    end
end