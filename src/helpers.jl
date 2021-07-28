const RangeLike = Union{GtkScale, GtkSpinButton}
const Activable = Union{GtkSwitch, GtkToggleButton, GtkCheckButton}

function value(widget::Widget{<:RangeLike})
    adjustment = GAccessor.adjustment(widget[])
    return GAccessor.value(adjustment)
end

function value!(widget::Widget{<:RangeLike}, value::Real) 
    adjustment = GAccessor.adjustment(widget[])
    return GAccessor.value(adjustment, value)
end

function Base.convert(::Type{T}, color::GdkRGBA) where T <: Colorant
    return convert(T, RGBA(color.r, color.g, color.b, color.a))
end

function Base.convert(::Type{GdkRGBA}, color::Colorant)
    c = convert(RGBA, color)
    return GdkRGBA(c.r, c.g, c.b, c.alpha)
end

function value(widget::Widget{GtkColorButton})
    return convert(RGBA, widget.rgba(GdkRGBA))
end

function value!(widget::Widget{GtkColorButton}, color::Colorant)
    return setprop!(widget; rgba = convert(GdkRGBA, color))
end

function value(widget::Widget{<:Activable})
    return widget.active(Bool)
end

function value!(widget::Widget{<:Activable}, value::Bool)
    return setprop!(widget; active = value)
end

Gtk.waitforsignal(self::Widget, signal) = Gtk.waitforsignal(gwidget(self), signal)
"""
        @waitfor widget.event

Block the current task until the `event` is triggered for `widget`.

## Examples:

```julia
window = Window("Hello, world", 800, 600)

... # Some UI stuff

if !isinteractive()
    # If the code is not running on a interactive julia session
    # (e.g. the REPL), then the line below will block the current
    # task until the window is destroyed
    @waitfor window.destroy
end
```
"""
macro waitfor(expr)
    if @capture(expr, widget_.event_)
        eventname = QuoteNode(event)
        return :( Gtk.waitforsignal($( esc(widget) ), $(eventname)) )
    end
end

"""
        @on widget.event() do args... body... end

Adds a `event` callback to the corresponding `widget`

## Usage

```julia
@on window.destroy() do args...
    # do something when the window is destroyed
end

@on button.clicked() do args...
    # do something when the button is clicked
end

```
"""
macro on(expr)
    if @capture(expr, widget_.event_() do args__ body__ end)
        eventname = QuoteNode(event)
        return esc(
            quote
                onevent($(eventname), $(widget)) do $(args...)
                    $(body...)
                end
            end
        )
    end
end

const Center   = Gtk.GtkAlign.CENTER
const Fill     = Gtk.GtkAlign.FILL
const Start    = Gtk.GtkAlign.START
const End      = Gtk.GtkAlign.END
const Baseline = Gtk.GtkAlign.BASELINE