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

function onevent(callback::Function, event::SymString, self::AbstractWidget)
    return signal_connect(callback, gwidget(self), event)
end

function setprop!(self::AbstractWidget, prop::SymString, callback::Function)
    prop = string(prop)
    if startswith(prop, "on")
        eventname = string(prop[3:end])
        onevent(callback, eventname, self)
    else
        set_gtk_property!(gwidget(self), prop, callback)
    end
end

function onkeypress(callback::Function, widget::AbstractWidget)
    onevent(callback, "key-press-event", widget)
end

function onkeypress(callback::Function, key::Integer, widget::AbstractWidget)
    onevent("key-press-event", widget) do widget, event
        if event.keyval == key
            callback(event)
        end
    end
end

function ondraw(callback::Function, canvas::GtkCanvas; framerate = 60.0, hotreload = false)
    lastframe = time_ns()
    interval = inv(framerate + 12)
    @guarded draw(canvas) do c
        now = time_ns()
        dt = (now - lastframe) / 10e8
        if dt > interval
            lastframe = now - (dt % interval)
            w, h = width(c), height(c)
            drawing = Drawing(w, h, :image)
            drawing.cr = Gtk.getgc(c)
            hotreload ? Base.invokelatest(callback, dt) : (callback)(dt)
            finish()
        end
    end
end

ondraw(callback::Function, canvas::Canvas; kwargs...) = ondraw(callback, canvas[]; kwargs...)

function GtkTickCallback(::Ptr{GObject}, ::Ptr{GObject}, ptr::Ptr{Nothing})
    canvas = unsafe_load(convert(Ptr{GtkCanvas}, ptr))
    Gtk.draw(canvas, false)
    return true
end

function onupdate(callback::Function, canvas::GtkCanvas; kwargs...)
    ondraw(callback, canvas; kwargs...)
    ptr = @cfunction(GtkTickCallback, Bool, (Ptr{GObject}, Ptr{GObject}, Ptr{Cvoid}))
    ref = Ref(canvas)
    GC.@preserve ptr begin
        @ccall libgtk.gtk_widget_add_tick_callback(
            canvas::Ptr{GObject},
            ptr::Ptr{Cvoid},
            ref::Ref{GtkCanvas},
            C_NULL::Ptr{Cvoid},
        )::Cuint
    end
end

onupdate(callback::Function, canvas::Canvas; kwargs...) = onupdate(callback, canvas[]; kwargs...)

"""
        onmousedown(callback, canvas)

The `mouse-down` event is fired when the user `press` with the mouse on the canvas.
"""
function onmousedown(callback::Function, canvas::Canvas)
    on(events(canvas).mousedown) do event
        @secure callback(event) "'onmousedown' event callback triggered a exception"
    end
end
"""
        onmouseup(callback, canvas)

The `mouse-up` event is fired when the user `release` the mouse on the canvas.
"""
function onmouseup(callback::Function, canvas::Canvas)
    on(events(canvas).mouseup) do event
        @secure callback(event) "'onmouseup' event callback triggered a exception"
    end
end
"""
        onmousemove(callback, canvas)

The `mouse-move` event is fired when the user `moves` the cursor on the canvas.
"""
function onmousemove(callback::Function, canvas::Canvas)
    on(events(canvas).mousemove) do event
        @secure callback(event) "'onmousemove' event callback triggered a exception"
    end
end
"""
        onmousedrag(callback, canvas)

The `mouse-drag` event is fired when the user holds `down` and `move` the cursor on the canvas.
"""
function onmousedrag(callback::Function, canvas::Canvas)
    on(events(canvas).mousedrag) do event
        @secure callback(event) "'onmousedrag' event callback triggered a exception"
    end
end
"""
        onscroll(callback, canvas)

The `scroll` event is fired when the user `scrolls` with the mouse-wheel on the canvas.
"""
function onscroll(callback::Function, canvas::Canvas)
    on(events(canvas).scroll) do event
        @secure callback(event) "'onscroll' event callback triggered a exception"
    end
end