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
    elseif @capture(expr, widget_.event_)
        eventname = QuoteNode(event)
        return esc(
            quote
                begin
                    obs = Observable{Widget}($(widget))
                    onevent($(eventname), $(widget)) do args...
                        obs[] = $(widget)
                    end
                    obs
                end
            end
        )
    end
end

function gkey(key::SymString)
    _key = Symbol("GDK_KEY_$key")
    if isdefined(Gtk.GConstants, _key)
        return getfield(Gtk.GConstants, _key)
    else
        @error "Unknown key '$key'"
        return nothing
    end
end

macro key_str(str) 
    Expr(:call, :gkey, esc(str))
end

keyname(event::Gtk.GdkEventKey) = keyval_name(event.keyval)

function setprop!(self::Widget, prop::SymString, callback::Function)
    prop = string(prop)
    if startswith(prop, "on")
        eventname = string(prop[3:end])
        onevent(callback, eventname, self)
    else
        set_gtk_property!(gwidget(self), prop, callback)
    end
end

function onkeypress(callback::Function, widget::Widget)
    if hasmethod(callback, Tuple{<:Widget, Gtk.GdkEventKey})
        onevent(callback, "key-press-event", widget)
    else
        onevent("key-press-event", widget) do widget, event
            callback(event)
        end
    end
end

function onkeypress(callback::Function, key::Integer, widget::Widget)
    onkeypress(widget) do widget, event
        if key == event.keyval
            callback(widget, event)
        end
    end
end

function ondraw(callback::Function, canvas::GtkCanvas)
    @guarded draw(canvas) do c
        w, h = size(c)
        drawing = Drawing(w, h, :image)
        drawing.cr = Gtk.getgc(c)
        callback(canvas)
        finish()
    end
end

ondraw(callback::Function, canvas::Canvas) = ondraw(callback, gwidget(canvas))

function GtkTickCallback(::Ptr{GObject}, ::Ptr{GObject}, ptr::Ptr{Nothing})
    canvas = unsafe_load(convert(Ptr{GtkCanvas}, ptr))
    Gtk.draw(canvas, false)
    return true
end

function onupdate(callback::Function, canvas::GtkCanvas)
    ondraw(callback, canvas)
    ptr = @cfunction(GtkTickCallback, Bool, (Ptr{GObject}, Ptr{GObject}, Ptr{Cvoid}))
    ref = Ref(canvas)
    return GC.@preserve ptr begin
        gtk_widget_add_tick_callback(canvas, ptr, ref, C_NULL)
    end
end

function onupdate(callback::Function, canvas::Canvas; fps::Ref{Float64} = Ref(60.0))
    then = Ref{Float64}(time_ns())
    canvas.tickcb = onupdate(gwidget(canvas)) do canvas
        now = time_ns()
        dt = (now - then[]) / 10e8
        interval = inv(fps[])
        if dt > interval
            callback(dt, canvas)
        end
        then[] = now - (dt % interval)
    end
end

"""
        onmousedown(callback, canvas)

The `mouse-down` event is fired when the user `press` with the mouse on the canvas.
"""
function onmousedown(callback::Function, canvas::Canvas)
    on(canvas.mouse.mousedown) do event
        @secure callback(event) "'onmousedown' event callback triggered a exception"
    end
end
"""
        onmouseup(callback, canvas)

The `mouse-up` event is fired when the user `release` the mouse on the canvas.
"""
function onmouseup(callback::Function, canvas::Canvas)
    on(canvas.mouse.mouseup) do event
        @secure callback(event) "'onmouseup' event callback triggered a exception"
    end
end
"""
        onmousemove(callback, canvas)

The `mouse-move` event is fired when the user `moves` the cursor on the canvas.
"""
function onmousemove(callback::Function, canvas::Canvas)
    on(canvas.mouse.mousemove) do event
        @secure callback(event) "'onmousemove' event callback triggered a exception"
    end
end
"""
        onmousedrag(callback, canvas)

The `mouse-drag` event is fired when the user holds `down` and `move` the cursor on the canvas.
"""
function onmousedrag(callback::Function, canvas::Canvas)
    on(canvas.mouse.mousedrag) do event
        @secure callback(event) "'onmousedrag' event callback triggered a exception"
    end
end
"""
        onscroll(callback, canvas)

The `scroll` event is fired when the user `scrolls` with the mouse-wheel on the canvas.
"""
function onscroll(callback::Function, canvas::Canvas)
    on(canvas.mouse.scroll) do event
        @secure callback(event) "'onscroll' event callback triggered a exception"
    end
end

function onresize(callback::Function, widget::GtkWidget)
    return onevent(callback, "size-allocate", widget)
end

onresize(callback::Function, widget::Widget) = onresize(callback, gwidget(widget))