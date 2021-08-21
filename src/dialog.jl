module Dialog

using Lynx
using Lynx: Container
using Lynx: Widget

import Gtk
import Gtk.GConstants
import Gtk.GAccessor

export ask!
export error!
export file!
export input!
export save!
export warn!

"""
        file!(title::String; filters = String[], parent = NullContainer()) -> String

Opens a `file` dialog. Suitable for `open/read` file operations.

`filters` are used to filter the types of files the user can choose.
Example: `*.png`
"""
function file!(title::String; parent::Widget = NullContainer(), filters::Vector{String} = String[])
    return Gtk.open_dialog(title, parent.widget, filters)
end
"""
        save!(title::String, default = "Untitled", path = pwd(), parent = NullContainer()) -> String

Opens a dialog for saving a `file`.

- `default` - the default file name. 
- `path` - the path of the directory which the dialog opens with.
- `parent` - the window the dialog belongs.

Returns a string containing the full path the user choose 
to save or a empty string if the dialog was cancelled.
"""
function save!(title::String, default::String = "Untitled", path::String = pwd(), parent::Widget = NullContainer())
    return save_file_dialog(title, default, path, parent.widget)
end
"""
        info!(message::String; parent = NullContainer())

Display a informative `message`.
"""
function info!(message::String; parent::Widget = NullContainer())
    return Gtk.info_dialog(message, parent.widget)
end
"""
        warn!(message::String; parent = NullContainer())

Warn the user with a `message`.
"""
function warn!(message::String; parent::Widget = NullContainer())
    return Gtk.warn_dialog(message, parent.widget)
end
"""
        error!(message::String; parent = NullContainer())

Display a error `message`.
"""
function error!(message::String; parent::Widget = NullContainer())
    return Gtk.error_dialog(message, parent.widget)
end
"""
        ask!(message, yes::String, no::String; parent = NullContainer())

Opens a dialog asking the user for confirmation. 
The dialog contains `yes` and `no` buttons which both can be customized.
"""
function ask!(message::String, no::String = "No", yes::String = "Yes"; parent::Widget = NullContainer())
    return Gtk.ask_dialog(message, no, yes, parent.widget)
end
"""
        input!(message, default, buttons = ("Cancel", "Accept", 1); parent = NullContainer()) -> String

Prompts for text input and returns what the user typed.
"""
function input!(message::AbstractString, buttons = ("Cancel", "Accept"); default::AbstractString = "", 
    parent::Widget = NullContainer())
    btns = ((buttons[1], 0), (buttons[2], 1))
    return Gtk.input_dialog(message, default, btns, parent.widget)
end

# Extended Gtk Functions

function save_file_dialog(title::AbstractString, default::AbstractString, 
    path::AbstractString, parent = Gtk.GtkNullContainer(); kwargs...)
    dlg = Gtk.GtkFileChooserDialog(title, parent, GConstants.GtkFileChooserAction.SAVE,
                                (("_Cancel", GConstants.GtkResponseType.CANCEL),
                                 ("_Save",   GConstants.GtkResponseType.ACCEPT)); kwargs...)
    dlgp = Gtk.GtkFileChooser(dlg)
    GAccessor.current_name(dlgp, default)
    GAccessor.current_folder(dlgp, path)
    response = Gtk.run(dlg)
    filename = ""
    if response == Gtk.GtkResponseType.ACCEPT
        filename = Gtk.bytestring(GAccessor.filename(dlgp))
    end
    Gtk.destroy(dlg)
    return filename
end

end # Dialog