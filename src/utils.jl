const SymString = Union{AbstractString, Symbol}
# I'm lazy
const Signal{T} = Observable{T}

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
    if @capture(expr, GType_(params__))
        return esc(:( Widget{$GType}($(expr); props...) ))
    end
end

macro container(expr)
    if @capture(expr, GType_(params__))
        return esc(:( Widget{$GType}($(expr); children = get(props, :children, ()), props...) ))
    end
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
Preserve `obj` until `widget` has been [`destroy`](@ref)ed.
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