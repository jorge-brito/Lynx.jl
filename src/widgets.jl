abstract type Widget{T} end

# --------------------------------------------------------------------------------
# ----------------------------------| Containers |--------------------------------
# --------------------------------------------------------------------------------

abstract type Container{T} <: Widget{T} end

mutable struct Window <: Container{GtkWindow}
    widget::GtkWidget
end

function Window(title::String, width::Int, height::Int, children::Widget...; props...)
    widget = @container GtkWindow(title, width, height)
    return @gcpreserve Window(widget)
end

"""
A container used to pack widgets together.
"""
mutable struct Box <: Container{GtkBox}
    widget::GtkWidget
end
"""
        Box(direction, children...; props...) -> Box

Creates a [`Box`](@ref) widget.

The `direction` parameter determines the direction the widgets 
are packed. `:v` for vertical or `:h` for horizontal.
"""
function Box(direction::Symbol, children::Widget...; props...)
    widget = @container GtkBox(direction)
    return @gcpreserve Box(widget)
end
"""
A widget with two adjustable panes.
"""
mutable struct Paned <: Container{GtkPaned}
    widget::GtkWidget
end
"""
        Paned(direction, children...; props...) -> Paned

Creates a [`Paned`](@ref) widget.

The `direction` parameter determines how the two panes are
arranged, either horizontally `:h`, or vertically `:v`.
"""
function Paned(direction::Symbol, children::Widget...; props...)
    widget = @container GtkPaned(direction)
    return @gcpreserve Paned(widget)
end
"""
Adds scrollbars to its child widget.
"""
mutable struct Scrolled <: Container{GtkScrolledWindow}
    widget::GtkWidget
end
"""
        Scrolled(children::Widget...; props...) -> Scrolled

Creates a [`Scrolled`](@ref) widget.
"""
function Scrolled(children::Widget...; props...)
    widget = @container GtkScrolledWindow()
    return @gcpreserve Scrolled(widget)
end
"""
A bin with a decorative frame and optional label
"""
mutable struct Frame <: Container{GtkFrame}
    widget::GtkWidget
end

function Frame(children::Widget...; props...)
    widget = @container GtkFrame()
    return @gcpreserve Frame(widget)
end

function Frame(label::String, children::Widget...; props...)
    widget = @container GtkFrame(label)
    return @gcpreserve Frame(widget)
end

function Frame(label::Widget, children::Widget...; props...)
    widget = @container GtkFrame()
    this = @gcpreserve Frame(widget)
    this["label-widget"] = gwidget(label)
    return this
end

mutable struct Notebook <: Container{GtkNotebook}
    widget::GtkWidget
end

function Notebook(children::Widget...; props...)
    widget = @container GtkNotebook()
    return @gcpreserve Notebook(widget)
end

mutable struct TreeView <: Container{GtkTreeView}
    widget::GtkWidget
end

function TreeView(children...; props...)
    widget = @container GtkTreeView(types...)
    return @gcpreserve TreeView(widget)
end

mutable struct Expander <: Container{GtkExpander}
    widget::GtkWidget
end

function Expander(label::AbstractString, children::Widget...; props...)
    widget = @container GtkExpander(label)
    return @gcpreserve Expander(widget)
end

# ----------------------------------------------------------------------------
# ----------------------------------| Inputs |--------------------------------
# ----------------------------------------------------------------------------

abstract type Input{T, S} <: Widget{S} end
abstract type RangeWidget{T, S} <: Input{T, S} end

"""
A slider widget for selecting a value from a range
"""
mutable struct Slider{T} <: RangeWidget{T, GtkScale}
    widget::GtkWidget
    value::Observable{T}
    adjustment::GtkAdjustment
end

function Slider(range::AbstractRange{T}, vertical::Bool = false; start::Real = middle(range), props...) where {T}
    widget = @widget GtkScale(vertical, range)
    adj = G.adjustment(widget)
    this = @gcpreserve Slider{T}(widget, Observable{T}(start), adj)
    G.value(adj, start)
    signal_connect(adj, "value-changed") do args...
        this.value[] = G.value(adj)
    end
    return this
end
"""
Retrieve an integer or floating-point number from the user
"""
mutable struct SpinButton{T} <: RangeWidget{T, GtkSpinButton}
    widget::GtkWidget
    value::Observable{T}
    adjustment::GtkAdjustment
end

function SpinButton(range::AbstractRange{T}; start::Real = middle(range), props...) where {T}
    widget = @widget GtkSpinButton(range)
    adj = G.adjustment(widget)
    this = @gcpreserve SpinButton{T}(widget, Observable{T}(start), adj)
    G.value(adj, start)
    signal_connect(adj, "value-changed") do args...
        this.value[] = G.value(adj)
    end
    return this
end
"""
A single line text entry field.
"""
mutable struct TextField <: Input{String, GtkEntry}
    widget::GtkWidget
    value::Observable{String}
end

function TextField(; props...)
    widget = @widget GtkEntry()
    text = get(props, :text, "")
    this = @gcpreserve TextField(widget, Observable(text))
    onevent("changed", this) do args...
        this.value[] = Gtk.bytestring(G.text(widget))
    end
    return this
end

"""
A button to launch a color selection dialog
"""
mutable struct ColorButton{T <: Colorant} <: Input{T, GtkColorButton}
    widget::GtkWidget
    value::Observable{T}
end

function ColorButton(color::T; props...) where {T <: Colorant}
    widget = @widget GtkColorButton(convert(GdkRGBA, color))
    this = @gcpreserve ColorButton{T}(widget, Observable(color))
    onevent("notify::color", widget) do args...
        this.value[] = this["rgba", GdkRGBA]
    end
    return this
end

ColorButton(color::String; props...) = ColorButton(parse(Colorant, color); props...)

abstract type Activable{W} <: Input{Bool, W} end

"""
Create buttons which retain their state
"""
mutable struct ToggleButton <: Activable{GtkToggleButton}
    widget::GtkWidget
    value::Observable{Bool}
end

function ToggleButton(text::String; props...)
    widget = @widget GtkToggleButton(text)
    this = @gcpreserve ToggleButton(widget, Observable(false))
    onevent("toggled", widget) do args...
        this.value[] = G.active(widget)
    end
    return this
end

"""
Create widgets with a discrete toggle button
"""
mutable struct CheckBox <: Activable{GtkCheckButton}
    widget::GtkWidget
    value::Observable{Bool}
end

function CheckBox(checked::Bool; props...)
    widget = @widget GtkCheckButton()
    this = @gcpreserve CheckBox(widget, Observable(checked))
    G.active(widget, checked)
    onevent("toggled", widget) do args...
        this.value[] = G.active(widget)
    end
    return this
end

"""
A “light switch” style toggle
"""
mutable struct Switch <: Activable{GtkSwitch}
    widget::GtkWidget
    value::Observable{Bool}
end

function Switch(checked::Bool; props...)
    widget = @widget GtkSwitch()
    this = @gcpreserve Switch(widget, Observable(checked))
    this["active"] = true
    onevent("notify::active", this) do args...
        setindex!(this.value, this["active", Bool])
    end
    return this
end

mutable struct Dropdown <: Input{String, GtkComboBoxText}
    widget::GtkWidget
    choices::Tuple{Vararg{String}}
    index::Observable{Int}
    value::Observable{String}
end

"""
A widget used to choose from a list of items
"""
function Dropdown(choices::String...; active::Int = 1, props...)
    widget = @widget GtkComboBoxText()
    index = Observable(active)
    for choice in choices
        push!(widget, choice)
    end
    this = @gcpreserve Dropdown(widget, choices, index, Observable(choices[active]))
    this["active"] = active - 1
    onevent("changed", this) do args...
        this.index[] = getprop(widget, :active, Int)
        this.value[] = Gtk.bytestring( G.active_text(widget) )
    end
    return this
end

# ------------------------------------------------------------------------------------
# ----------------------------------| Common Widgets |--------------------------------
# ------------------------------------------------------------------------------------
"""
A widget that emits a signal when clicked on
"""
mutable struct Button <: Widget{GtkButton}
    widget::GtkWidget
end

Button(text::String; props...) = Button(@widget GtkButton(text))

function Button(icon::AbstractString, size::Symbol; props...)
    gsize::Cuint = getfield(Gtk.GtkIconSize, Symbol(uppercase(string(size))))
    widget = @widget icon_button(icon, gsize)
    return @gcpreserve Button(widget)
end

function Button(clicked::Function, text::String; props...)
    button = Button(text; props...)
    onevent(clicked, "clicked", button)
    return button
end

function Button(clicked::Function, icon::AbstractString, size::Symbol; props...)
    button = Button(icon, size; props...)
    onevent(clicked, "clicked", button)
    return button
end

"""
A widget that displays a small to medium amount of text
"""
mutable struct Label <: Widget{GtkLabel}
    widget::GtkWidget
    function Label(text::String; props...)
        widget = @widget GtkLabel(text)
        return @gcpreserve new(widget)
    end
end

"""
A widget which indicates progress visually

Use the [`fill!`](@ref) and the [`pulse!`](@ref) functions
to control the progress bar.
"""
mutable struct ProgressBar <: Widget{GtkProgressBar}
    widget::GtkWidget
end

function ProgressBar(; props...)
    widget = @widget GtkProgressBar()
    return @gcpreserve ProgressBar(widget)
end

function ProgressBar(fill::Float64; props...)
    this = ProgressBar(; props...)
    fill!(this, fill)
    return this
end

"""
A widget for displaying an image.
"""
mutable struct ImageView <: Widget{GtkImage}
    widget::GtkWidget
    function ImageView(; props...)
        widget = @widget GtkImage()
        return @gcpreserve new(widget)
    end
    function ImageView(file::AbstractString; props...) 
        widget = @widget GtkImage(file)
        return @gcpreserve new(widget)
    end
end

"""
Custom drawing with OpenGL.
"""
mutable struct GLArea <: Widget{GtkGLArea}
    widget::GtkWidget
    function GLArea(; props...)
        widget = @widget GtkGLArea()
        return @gcpreserve new(widget)
    end
end