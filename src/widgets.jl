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
    return Window(widget)
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
    return Box(widget)
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
    return Paned(widget)
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
    return Scrolled(widget)
end
"""
A bin with a decorative frame and optional label
"""
mutable struct Frame <: Container{GtkFrame}
    widget::GtkWidget
end

function Frame(children::Widget...; props...)
    widget = @container GtkFrame()
    return Frame(widget)
end

function Frame(label::String, children::Widget...; props...)
    widget = @container GtkFrame(label)
    return Frame(widget)
end

function Frame(label::Widget, children::Widget...; props...)
    widget = @container GtkFrame(label.widget)
    return Frame(widget)
end

mutable struct Notebook <: Container{GtkNotebook}
    widget::GtkWidget
end

function Notebook(children::Widget...; props...)
    widget = @container GtkNotebook()
    return Notebook(widget)
end

mutable struct TreeView <: Container{GtkTreeView}
    widget::GtkWidget
end

function TreeView(children...; props...)
    widget = @container GtkTreeView(types...)
    return TreeView(widget)
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
    this = Slider{T}(widget, Observable{T}(start), adj)
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
    this = SpinButton{T}(widget, Observable{T}(start), adj)
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
    this = TextField(widget, Observable(text))
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
    this = ColorButton{T}(widget, Observable(color))
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
    this = ToggleButton(widget, Observable(false))
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
    this = CheckBox(widget, Observable(checked))
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
    this = Switch(widget, Observable(checked))
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
    this = Dropdown(widget, choices, index, Observable(choices[active]))
    this["active"] = active
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
    Button(text::String; props...) = new(@widget GtkButton(text))
end

function Button(clicked::Function, text::String; props...)
    button = Button(text; props...)
    onevent(clicked, "clicked", button)
    return button
end

"""
A widget that displays a small to medium amount of text
"""
mutable struct Label <: Widget{GtkLabel}
    widget::GtkWidget
    Label(text::String; props...) = new(@widget GtkLabel(text))
end

"""
A widget which indicates progress visually

Use the [`fill!`](@ref) and the [`pulse!`](@ref) functions
to control the progress bar.
"""
mutable struct ProgressBar <: Widget{GtkProgressBar}
    widget::GtkWidget
    ProgressBar(; props...) = new(@widget GtkProgressBar())
end

"""
A widget for displaying an image.
"""
mutable struct Image <: Widget{GtkImage}
    widget::GtkWidget
    Image(; props...) = new(@widget GtkImage())
    Image(file::AbstractString; props...) = new(@widget GtkImage(file))
end

"""
Custom drawing with OpenGL.
"""
mutable struct GLArea <: Widget{GtkGLArea}
    widget::GtkWidget
    GLArea(; props...) = new(@widget GtkGLArea())
end