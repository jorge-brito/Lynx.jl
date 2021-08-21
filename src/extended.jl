# Extended Gtk functions

function gtk_widget_add_tick_callback(widget::GtkWidget, callback, userdata, notify)
    @ccall libgtk.gtk_widget_add_tick_callback(
        widget::Ptr{GObject},
        callback::Ptr{Nothing},
        userdata::Ptr{Nothing},
        notify::Ptr{Nothing}
    )::Cuint
end

function gtk_widget_remove_tick_callback(widget::GtkWidget, id::Cuint)
    @ccall libgtk.gtk_widget_remove_tick_callback(widget::Ptr{GObject}, id::Cuint)::Nothing
end

function gtk_button_new_from_icon_name(name::String, size::Cuint)
    @ccall libgtk.gtk_button_new_from_icon_name(name::Ptr{Cchar}, size::Cuint)::Ptr{GObject}
end

function icon_button(name::String, size::Cuint = GtkIconSize.BUTTON)
    return Gtk.GtkButtonLeaf(gtk_button_new_from_icon_name(name, size))
end

gdk_keyval_name(keyval::Cuint) = @ccall libgdk.gdk_keyval_name(keyval::Cuint)::Ptr{UInt8}
keyval_name(keyval::Cuint) = Gtk.bytestring(gdk_keyval_name(keyval))

function gtk_grid_attach_next_to(grid::GtkGrid, child::GtkWidget, sibling::GtkWidget, side::Symbol, width::Int, height::Int)
    side = getfield(Gtk.GtkPositionType, side)
    @ccall libgtk.gtk_grid_attach_next_to(
        grid::Ptr{GObject},
        child::Ptr{GObject},
        sibling::Ptr{GObject},
        side::Cint,
        width::Cint,
        height::Cint
    )::Cvoid
end