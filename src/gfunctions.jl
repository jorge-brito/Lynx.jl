@gfunction gtk_widget_add_tick_callback(
    @ptr(widget::GObject),
    @ptr(callback::Any, Nothing),
    @ptr(user_data::Any, Nothing),
    @ptr(notify::Any, Nothing)
) = Cuint

@gfunction gtk_widget_remove_tick_callback(@ptr(widget::GObject), id::Cuint) = Nothing

