using Lynx

function App()
    Window("Test", 800, 600, children = (
        Scrolled(children = (
            Box(:v, margin = 50, spacing = 20, children = (
                Label("Hello world"),
                Button("Click-me", halign = Center),
                Image(joinpath(@__DIR__, "../assets/image.png")),
                ProgressBar(),
                Slider(1:100, value = 50),
                SpinButton(1:100),
                CheckBox(active = true),
                ToggleBtn("Toggle Me"),
                LinkButton("Hello"),
                Switch(active = false, halign = Center),
                ColorButton("#f1a", halign = Center),
                VolumeBtn(),
                TextField(text = "Hello, world!"),
            )), # Box
        )) # Scrolled
    )) # Window
end

app = App()
showall(app)

!isinteractive() && @waitfor app.destroy
nothing