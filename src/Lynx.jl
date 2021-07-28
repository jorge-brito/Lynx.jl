module Lynx

using Gtk
using Gtk: GtkWidget
using Gtk: GdkRGBA
using Gtk: GtkSwitch
using Gtk: GEnum

import Gtk.GAccessor

using Colors
using Luxor
using MacroTools
using Observables

import Observables.ObserverFunction

include("utils.jl")
include("math.jl")
include("widgets.jl")
include("props.jl")
include("canvas.jl")
include("helpers.jl")
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
export App
export CanvasOnly
export SideBar
# Widgets
export Box
export Button
export Canvas
export CheckBox
export ColorButton
export ComboBox
export ComboBoxText
export FileChooserDialog
export Frame
export GLArea
export Image
export Label
export LinkButton
export MessageDialog
export Notebook
export Paned
export ProgressBar
export Scrolled
export Slider
export SpinButton
export Spinner
export Switch
export TextField
export ToggleBtn
export VolumeBtn
export Widget
export Window
# Functions
export framerate!
export getapp
export getprop
export gwidget
export gkey
export height
export layout!
export loop!
export ondraw
export onevent
export onkeypress
export onmousedown
export onmousedrag
export onmousemove
export onmousescroll
export onmouseup
export onupdate
export run!
export setapp
export setprop!
export showall
export SymString
export use!
export value
export value!
export width
export mapr
# Macros
export @app
export @canvas
export @framerate
export @key_str
export @map
export @on
export @unpack
export @use
export @waitfor
export @window

end # module Lynx
