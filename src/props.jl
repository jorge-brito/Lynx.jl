gwidget(w::T) where T <: Widget = getfield(w, :widget)
getprop(w::Widget, name::SymString, T::DataType) = getprop(gwidget(w), name, T)
setprop!(w::Widget, name::SymString, value::T) where {T} = setprop!(gwidget(w), name, value)
disconnect(w::Widget, id) = disconnect(gwidget(w), id)

Base.get(w::Widget, name::SymString, T::DataType) = getprop(w, name, T)
Base.getindex(w::Widget, name::SymString, T::DataType) = getprop(w, name, T)
Base.setindex!(w::Widget, value, name::SymString) = setprop!(w, name, value)

function onevent(callback::Function, event::SymString, self::Widget)
    return signal_connect(callback, gwidget(self), event)
end

function Base.push!(w::Container, children::Widget...)
    for child in children
        push!(gwidget(w), gwidget(child))
    end
end

function Base.setindex!(grid::Grid, child::Widget, indices::Vararg{Union{Int, UnitRange}})
    setindex!(gwidget(grid), gwidget(child), indices...)
end

Observables.on(f, input::Input; kwargs...) = on(f, input.value; kwargs...)

Gtk.showall(w::Widget) = Gtk.showall(gwidget(w))
Gtk.width(w::Widget) = Gtk.width(gwidget(w))
Gtk.height(w::Widget) = Gtk.height(gwidget(w))
Gtk.destroy(w::Widget) = Gtk.destroy(gwidget(w))

Base.size(w::Widget) = (Gtk.width(w), Gtk.height(w))
Base.show(w::Widget) = Gtk.show(gwidget(w))

Base.show(io::IO, ::T) where {T <: Widget} = write(io, "$T")

"""
        value(widget::Input{T}) -> T

Returns the `value` of a `Input` widget.
"""
function value(input::Input)
    return input.value[]
end
"""
        value!(widget::Input, value) -> Nothing

Sets the `value` of a `Input` widget.
"""
function value!(input::Input, value)
    input.value[] = value
end

Base.getindex(input::Input) = value(input)
Base.setindex!(input::Input, value) = value!(input, value)

value!(input::RangeWidget, value::Real) = G.value(input.adjustment, value)

function value!(w::ColorButton{T}, value::Colorant) where {T}
    w["rgba"] = convert(GdkRGBA, value)
end

value!(input::Activable, value::Bool) = G.active(gwidget(input), value)

value!(input::Switch, value::Bool) = setprop!(input, :active, value)

function value!(dropdown::Dropdown, value::Int)
    dropdown["active"] = value - 1
    dropdown.value[] = dropdown.choices[value]
end

Base.getindex(widget::Dropdown, index::Int) = widget.choices[index]

progress_bar_pulse(w::GtkProgressBar) = @ccall libgtk.gtk_progress_bar_pulse(w::Ptr{GObject})::Cvoid

"""
        pulse!(widget::ProgressBar) -> Nothing

Make the progress bar pulse, indicating that a unknown
amount of progress has been made.
"""
pulse!(bar::ProgressBar) = progress_bar_pulse(bar.widget)

"""
        fill!(bar::ProgressBar, fraction::Real) -> Nothing

Causes the progress bar to “fill in” the given `fraction` of the bar. 
The fraction should be between 0.0 and 1.0, inclusive.
"""
Base.fill!(bar::ProgressBar, fraction::Real) = G.fraction(bar.widget, fraction)

function value!(input::TextField, value::String)
    GAccessor.text(input.widget, value)
    input.value[] = value
end

function Base.push!(button::Button, image::ImageView)
    GAccessor.always_show_image(button.widget, true)
    GAccessor.image(button.widget, image.widget)
end

macro showall(widget)
    return quote
        showall($( esc(widget) ))
    end
end