const SymString = Union{AbstractString, Symbol}

macro map(expr...)
    T, ex =
        if length(expr) == 1
            nothing, first(expr)
        else 
            first(expr), last(expr)
    end

    args = map(ex.args) do arg
        if Meta.isexpr(arg, :(=))
            key, value = arg.args
            return :( $(QuoteNode(key)) => $value )
        elseif Meta.isexpr(arg, :(:=))
            key, value = arg.args
            return :( $key => $value )
        else
            error("Invalid syntax for @map, expected expression of type `foo = bar` or `foo := bar`")
        end
    end
    
    result =
        if isnothing(T)
            Expr(:call, :Dict, args...)
        else
            Expr(:call, Expr(:curly, :Dict, T.args...), args...)
        end
    
    return esc(result)
end

macro widget(expr)
    name = gensym("widget")
    quote
        begin
            $(name) = $(expr)
            for (prop, value) in pairs(props)
                setprop!($(name), prop, value)
            end
            $(name)
        end
    end |> esc
end

macro container(expr)
    name = gensym("widget")
    quote
        begin
            $(name) = $(expr)
            for (prop, value) in pairs(props)
                setprop!($(name), prop, value)
            end
            for (child) in children
                push!($(name), child.widget)
            end
            $(name)
        end
    end |> esc
end

macro secure(expr, msg)
    esc(quote
        try
            $(expr)
        catch e
            @error $(msg) exception = e
        end    
    end)
end

const _ref_dict = IdDict{Any, Any}()

"""
    gcpreserve(widget::GtkWidget, obj)
Preserve `obj` until `widget` has been destroyed.
"""
function gcpreserve(widget::Union{GtkWidget,GtkCanvas}, obj)
    _ref_dict[obj] = obj
    signal_connect(widget, :destroy) do w
        delete!(_ref_dict, obj)
    end
end

macro unpack(expr)
    if @capture(expr, (vars__,) = object_)
        res = Expr[]
        for var in vars
            push!(res, :( $var = $(object).$var ))
        end
        return esc(quote $(res...) end)
    end
end

function Base.convert(::Type{T}, color::GdkRGBA) where {T <: Colorant}
    @unpack r, g, b, a = color
    return convert(T, RGBA(r, g, b, a))
end

function Base.convert(::Type{GdkRGBA}, color::Colorant)
    rgba = convert(RGBA, color)
    @unpack r, g, b, alpha = rgba
    return GdkRGBA(r, g, b, alpha)
end

function middle(r::AbstractRange)
    N = length(r)
    return isodd(N) ? r[N ÷ 2 + 1] : r[N ÷ 2]
end

const Center   = Gtk.GtkAlign.CENTER
const Fill     = Gtk.GtkAlign.FILL
const Start    = Gtk.GtkAlign.START
const End      = Gtk.GtkAlign.END
const Baseline = Gtk.GtkAlign.BASELINE

getprop(w::GtkWidget, prop::SymString, T::DataType) = get_gtk_property(w, prop, T)
setprop!(w::GtkWidget, prop::SymString, value) = set_gtk_property!(w, prop, value)
onevent(callback::Function, event::SymString, w::GtkWidget) = signal_connect(callback, w, event)
disconnect(w::GtkWidget, id::Cuint) = signal_handler_disconnect(w, id)

"""
        @function function_name(args::Types...) = return_type
        @function function_name(@ptr(obj::Type)) = return_type
"""
macro gfunction(expr)
    if @capture(expr, fname_(args__) = body__)
        rtype = first(body)
        fargs = []
        cargs = []
        types = []
        namesym = QuoteNode(fname)
        for ex in args
            if @capture(ex, @ptr(name_::type_) | @ptr(name_::type_, ctype_))
                push!(fargs, :( $name::$type ))
                if !isnothing(ctype)
                    push!(types, :( Ptr{$ctype} ))
                else
                    push!(types, :( Ptr{$type} ))
                end
                push!(cargs, name)
            elseif @capture(ex, name_::type_)
                push!(fargs, ex)
                push!(types, type)
                push!(cargs, name)
            end
        end
        res = quote
            function $(fname)($(fargs...))
                return ccall(($namesym, libgtk), $rtype, ($(types...),), $(cargs...))
            end
        end
        return esc(res)
    end
end

abstract type Iterable end

function Base.iterate(itr::T, state = 1) where T <: Iterable
    if state <= fieldcount(T)
        return getfield(itr, state), state + 1
    else
        return nothing
    end
end