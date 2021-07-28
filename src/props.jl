gwidget(widget::AbstractWidget) = getfield(widget, 1)
"""
        getprop(widget, name, T) -> T

Gets a `widget` property indentified by `name` with type `T`.
"""
function getprop(widget::AbstractWidget, name::SymString, T::DataType)
    return get_gtk_property(widget[], name, T)
end
"""
        setprop!(widget, name, value)

Sets the `value` of a `widget` property indentified by `name`.
"""
function setprop!(widget::AbstractWidget, name::SymString, value)
    set_gtk_property!(widget[], name, value)
end

function setprop!(widget::AbstractWidget; props...)
    for (prop, value) in pairs(props)
        setprop!(widget, prop, value)
    end
end

Base.getindex(widget::AbstractWidget) = gwidget(widget)

function Base.getindex(widget::AbstractWidget, name::SymString, type::DataType)
    return getprop(widget, name, type)
end

function Base.setindex!(widget::AbstractWidget, value, name::SymString)
    setprop!(widget, value, name)
end

function Base.setproperty!(widget::AbstractWidget, name::Symbol, value)
    setprop!(widget, name, value)
end

function Base.getproperty(widget::AbstractWidget, name::Symbol)
    return T::DataType -> getprop(widget, name, T)
end

function Base.push!(widget::AbstractWidget, child::AbstractWidget...)
    for child in child
        push!(widget[], child[])
    end
end

Gtk.width(self::AbstractWidget) = Gtk.width(gwidget(self))
Gtk.height(self::AbstractWidget) = Gtk.height(gwidget(self))
Gtk.showall(self::AbstractWidget) = Gtk.showall(gwidget(self))
Base.size(self::AbstractWidget) = (width(self), height(self))