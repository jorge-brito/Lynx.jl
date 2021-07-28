abstract type AbstractWidget{T} end

mutable struct Widget{T} <: AbstractWidget{T}
    widget::GtkWidget
    function Widget{T}(w::GtkWidget; children::Union{Tuple, AbstractWidget} = (), props...) where {T <: GtkWidget}
        self = new{T}(w)
        setprop!(self; props...)
        if children isa AbstractWidget
            push!(self, children)
        else
            push!(self, children...)
        end
        return self
    end
end
"""
        Button(text; props...) -> Widget{GtkButton}

A widget that emits a signal when clicked on.
"""
Button(text::String; props...) = @widget GtkButton(text)
""" 
        CheckBox(; props...) -> Widget{GtkCheckButton}

A widget with with a check box.
"""
CheckBox(; props...) = @widget GtkCheckButton()
"""
        ColorButton(color; props...) -> Widget{GtkColorButton}

A button to launch a color selection dialog
"""
ColorButton(color::Colorant; props...) = @widget GtkColorButton(convert(GdkRGBA, color))
ColorButton(color::String; props...) = ColorButton(parse(Colorant, color); props...)
"""
        ComboBox(args...; props...) -> Widget{GtkComboBox}

A widget used to choose from a list of items
"""
ComboBox(args...; props...) = @widget GtkComboBox(args...)
"""
    ComboBoxText(args...; props...) -> Widget{GtkComboBoxText}

A simple, text-only combo box
"""
ComboBoxText(args...; props...) = @widget GtkComboBoxText(args...)
"""
        GLArea(args...; props...) -> Widget{GtkGLArea}

A widget for custom drawing with OpenGL
"""
GLArea(args...; props...) = @widget GtkGLArea(args...)
"""
        Image([filepath]; props...) --> Widget{GtkImage}

A widget displaying an image
"""
Image(; props...) = @widget GtkImage()
Image(filepath::String; props...) = @widget GtkImage(filepath)
"""
        Label(text; props...) -> Widget{GtkLabel}

A widget that displays a small to medium amount of text
"""
Label(text::String; props...) = @widget GtkLabel(text)
"""
        LinkButton(text; props...) -> Widget{GtkLinkButton}

Create buttons bound to a URL
"""
LinkButton(args...; props...) = @widget GtkLinkButton(args...)
"""
        ProgressBar(; props...) -> Widget{GtkProgressBar}

A widget which indicates progress visually
"""
ProgressBar(; props...) = @widget GtkProgressBar()
"""
        SpinButton(range; props...) -> Widget{GtkSpinButton}

Retrieve an integer or floating-point number from the user
"""
SpinButton(range::AbstractRange, args...; props...) = @widget GtkSpinButton(range, args...)
"""
        Spinner(; props...) -> Widget{GtkSpinner}

Show a spinner animation
"""
Spinner(; props...) = @widget GtkSpinner()
"""
        Switch(; props...) -> Widget{GtkSwitch}

A “light switch” style toggle
"""
Switch(; props...) = @widget GtkSwitch()
"""
        TextField(; props...) -> Widget{GtkEntry}

A single line text entry field
"""
TextField(args...; props...) = @widget GtkEntry(args...)
"""
        ToggleBtn(; props...) -> Widget{GtkToggleButton}

Create buttons which retain their state
"""
ToggleBtn(args...; props...) = @widget GtkToggleButton(args...)
"""
        VolumeBtn(; props...) -> Widget{GtkVolumeButton}

A button which pops up a volume control
"""
VolumeBtn(args...; props...) = @widget GtkVolumeButton(args...)
"""
        Slider(range, vertical = false; props...) -> Widget{GtkScale}

A slider widget for selecting a value from a range
"""
function Slider(range::AbstractRange, vertical = false; value::Real = first(range), props...)
    self = Widget{GtkScale}(GtkScale(vertical, range); props...)
    value!(self, value)
    return self
end
"""
        Box(layout; props...) -> Widget{GtkBox}

A container for packing widgets in a single row or column
"""
Box(layout::Symbol; props...) = @container GtkBox(layout)
"""
        FileChooserDialog(args...; props...) -> Widget{GtkFileChooserDialog}

A file chooser dialog, suitable for “File/Open” or “File/Save” commands
"""
FileChooserDialog(args...; props...) = @container GtkFileChooserDialog(args...)
"""
        Frame(args...; props...) -> Widget{GtkFrame}

A bin with a decorative frame and optional label
"""
Frame(args...; props...) = @container GtkFrame(args...)
"""
        MessageDialog(args...; props...) -> Widget{GtkMessageDialog}

A convenient message window
"""
MessageDialog(args...; props...) = @container GtkMessageDialog(args...)
"""
        Notebook(args...; props...) -> Widget{GtkNotebook}

    A tabbed notebook container
"""
Notebook(args...; props...) = @container GtkNotebook(args...)
"""
        Paned(layout; props...) -> Widget{GtkPaned}

A widget with two adjustable panes
"""
Paned(layout::Symbol; props...) = @container GtkPaned(layout)
"""
        Scrolled(args...; props...) -> Widget{GtkScrolledWindow}

Adds scrollbars to its child widget
"""
Scrolled(args...; props...) = @container GtkScrolledWindow(args...)
"""
        Window(title, width, height; props...) -> Widget{GtkWindow}

Toplevel which can contain other widgets
"""
Window(title::String, width::Int, height::Int; props...) = @container GtkWindow(title, width, height)