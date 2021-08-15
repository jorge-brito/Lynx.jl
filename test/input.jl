@testset "Input Widgets" begin

function Item(name::String, child::Widget)
    value = map(x -> "Value: $x", child.value)
    child["margin-top"] = 10
    return Expander(name, expanded = true,
        Box(:v, spacing = 10, 
            child,
            Label("", label = value, halign = Center)
        ) # Box
    ) # Expander
end

inputs = @map {
    Slider       = Slider(0:100, hexpand = true),
    SpinButton   = SpinButton(-50:50),
    TextField    = TextField(text = "Lorem ipsum dolor"),
    ColorButton  = ColorButton("#f1a"),
    ToggleButton = ToggleButton("Click-me"),
    CheckBox     = CheckBox(true),
    Switch       = Switch(false, halign = Center)
}

widgets = map(collect(inputs)) do (name, widget)
    on(widget) do x
        @info "Value of $name widget changed to $x"
    end
    Item(string(name), widget)
end

app = Window("Input widgets test", 300, 800,
    Scrolled(
        Box(:v, margin = 20, spacing = 10,
            widgets...
        )
    ) #Scrolled
) # Window

@test value(inputs[:Slider])        == 50
@test value(inputs[:SpinButton])    == 0
@test value(inputs[:TextField])     == "Lorem ipsum dolor"
@test value(inputs[:ColorButton])   == parse(Colorant, "#f1a") 
@test value(inputs[:ToggleButton])  == false
@test value(inputs[:CheckBox])      == true
@test value(inputs[:Switch])        == false

@showall app
# @waitfor app.destroy
Lynx.destroy(app)

end # testset