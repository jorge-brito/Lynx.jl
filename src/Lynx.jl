module Lynx

import Gtk
import Gtk.GtkBox
import Gtk.GtkButton
import Gtk.GtkCanvas
import Gtk.GtkCheckButton
import Gtk.GtkColorButton
import Gtk.GtkComboBox
import Gtk.GtkComboBoxText
import Gtk.GtkEntry
import Gtk.GtkFileChooserDialog
import Gtk.GtkFrame
import Gtk.GtkGLArea
import Gtk.GtkImage
import Gtk.GtkLabel
import Gtk.GtkLinkButton
import Gtk.GtkMessageDialog
import Gtk.GtkNotebook
import Gtk.GtkPaned
import Gtk.GtkProgressBar
import Gtk.GtkScale
import Gtk.GtkScrolledWindow
import Gtk.GtkSpinButton
import Gtk.GtkSpinner
import Gtk.GtkSwitch
import Gtk.GtkToggleButton
import Gtk.GtkTreeView
import Gtk.GtkVolumeButton
import Gtk.GtkWidget
import Gtk.GtkGrid
import Gtk.GtkWindow
import Gtk.GtkAdjustment

import Gtk.GAccessor
import Gtk.GdkRGBA
import Gtk.GEnum

import Gtk.signal_connect
import Gtk.set_gtk_property!
import Gtk.get_gtk_property
import Gtk.@guarded
import Gtk.draw
import Gtk.width
import Gtk.height
import Gtk.GObject
import Gtk.signal_handler_disconnect
import Gtk.showall
import Gtk.Cairo

using Gtk: libgtk
using Gtk: libgdk

using Colors
using Luxor
using MacroTools
using Observables

import Observables.ObserverFunction

const G = GAccessor

include("utils.jl")
include("gfunctions.jl")
include("math.jl")
include("widgets.jl")
include("grid.jl")
include("props.jl")
include("canvas.jl")
include("events.jl")
include("layout.jl")
include("app.jl")

# Constants
export Baseline
export Center
export End
export Fill
export Start
# Types
export AbstractLayout
export CanvasEvents
export CanvasOnly
export LynxApp
export MouseEvent
export ScrollEvent
export SideBar
export SymString
# Widgets
export Activable
export Box
export Button
export Canvas
export CheckBox
export ColorButton
export Container
export Dropdown
export Frame
export GLArea
export Grid
export Image
export Input
export Label
export Notebook
export Paned
export ProgressBar
export RangeWidget
export Scrolled
export Slider
export SpinButton
export Spinner
export Switch
export TextField
export ToggleButton
export TreeView
export Widget
export Window
# Functions
export events
export framerate!
export getapp
export getprop
export init
export layout!
export loop!
export mapr
export middle
export onevent
export pulse!
export run!
export setapp
export setprop!
export start!
export stop!
export use!
export value
export value!
export gkey
export onkeypress
export waitfor
export ondraw
export onupdate
export onmousedown
export onmouseup
export onmousemove
export onmousedrag
export onscroll
export span
export cspan
export rspan
export GridElement
# Macros
export @app
export @canvas
export @framerate
export @height
export @map
export @on
export @size
export @unpack
export @use
export @waitfor
export @width
export @window
export @key_str

# Trick to get intellisense on vs-code
if (false) include("../test/runtests.jl") end

end # module Lynx
