using Gtk: libgtk
using Gtk: libgdk

struct MouseEvent
    x::Real
    y::Real
    button::Cuint
    state::Cuint
end

struct ScrollEvent
    x::Real
    y::Real
    direction::GEnum
    state::Cuint
    dx::Float64
    dy::Float64
end

struct CanvasEvents
    mouseup::Signal{MouseEvent}
    mousedown::Signal{MouseEvent}
    mousemove::Signal{MouseEvent}
    mousedrag::Signal{MouseEvent}
    scroll::Signal{ScrollEvent}
    ids::Vector{Culong}
    widget::GtkWidget
    function CanvasEvents(canvas::GtkCanvas)
        event = MouseEvent(-1, -1, 0, 0)
        scroll = ScrollEvent(-1, -1, 0, 0, 0, 0)
        ids = Culong[]
        this = new(event, event, event, event, scroll, ids, canvas)
        push!(ids, Gtk.on_signal_button_press(mousedown_cb, canvas, false, this))
        push!(ids, Gtk.on_signal_button_release(mouseup_cb, canvas, false, this))
        push!(ids, Gtk.on_signal_motion(mousemove_cb, canvas, 0, 0, false, this))
        push!(ids, Gtk.on_signal_scroll(mousescroll_cb, canvas, false, this))
        return this
    end
end

mutable struct Canvas <: AbstractWidget{GtkCanvas}
    widget::GtkCanvas
    mouse::CanvasEvents
    function Canvas(width::Integer = -1, height::Integer = -1; props...)
        gcanvas = GtkCanvas(width, height)
        for id in gcanvas.mouse.ids
            signal_handler_disconnect(gcanvas, id)
        end
        empty!(gcanvas.mouse.ids)
        mouse = CanvasEvents(gcanvas)
        canvas = new(gcanvas, mouse)
        !isempty(props) && setprop!(canvas; props...)
        canvas.is_focus = true
        gcpreserve(gcanvas, canvas)
        return canvas
     end
end

events(canvas::Canvas) = getfield(canvas, :mouse)

function Canvas(update::Function; loop::Bool = true)
    canvas = Canvas()
    if loop
        onupdate(dt -> update(dt, canvas), canvas)
    else
        ondraw(dt -> update(dt, canvas), canvas)
    end
    return canvas
end

function mousedown_cb(ptr::Ptr, eventp::Ptr, this::CanvasEvents)
    evt = unsafe_load(eventp)
    this.mousedown[] = MouseEvent(evt.x, evt.y, evt.button, evt.state)
    return Cint(false)
end

function mouseup_cb(ptr::Ptr, eventp::Ptr, this::CanvasEvents)
    evt = unsafe_load(eventp)
    this.mouseup[] = MouseEvent(evt.x, evt.y, evt.button, evt.state)
    return Cint(false)
end

function mousemove_cb(ptr::Ptr, eventp::Ptr, this::CanvasEvents)
    evt = unsafe_load(eventp)
    button = 0
    this.mousemove[] = MouseEvent(evt.x, evt.y, 0, evt.state)
    if evt.state & Gtk.GdkModifierType.BUTTON1 != 0
        button = 1
    elseif evt.state & Gtk.GdkModifierType.BUTTON2 != 0
        button = 2
    elseif evt.state & Gtk.GdkModifierType.BUTTON3 != 0
        button = 3
    end
    if button != 0
        this.mousedrag[] = MouseEvent(evt.x, evt.y, button, evt.state)
    end
    Cint(false)
end

function mousescroll_cb(ptr::Ptr, eventp::Ptr, this::CanvasEvents)
    evt = unsafe_load(eventp)
    this.scroll[] = ScrollEvent(
        evt.x, 
        evt.y, 
        evt.direction, 
        evt.state,
        evt.delta_x,
        evt.delta_y
    )
    Cint(false)
end