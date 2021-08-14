@testset "Widgets" begin

function Centered(layout, children...; props...)
    Box(layout, children...; valign = Center, halign = Center, props...)
end

function Item(name::String, children; centered::Bool = true, desc=name)
    Frame("", margin = 10, tooltip_text = desc,
        Box(:v, spacing = 10, margin = 10,
            (centered ? Centered(:v, margin=10, children) : children),
            Label(name, halign=Center),
        )
    )
end

function App(title; width, height)
    Window(title, width, height,
        Scrolled(
            Box(:v, spacing=5, margin = 20, valign=Center,
                Item("Label", desc = "Displays a small to medium amount of text",
                    Label("Lorem ipsum dolor...")
                ), # Item
                Item("ProgressBar", desc = "Displays progress visually" ,
                    ProgressBar(.50, hexpand=true)
                ), # Item
                Grid(spacing = 10, [
                    Item("ImageView", desc = "Displays an image",
                        ImageView(asset"image.png")
                    ) Item("Picture", desc = "Displays an image with custom width and height",
                        Picture(asset"image.png", 300, 300, filter=:Best)
                    )
                ]),
                Item("Slider", desc = "Horizontal slider",
                    centered=false,
                    Box(:h,
                        Slider(1:100, hexpand = true)
                    )
                ), # Item
                Grid(spacing = 10, halign = Center, [
                    [
                        Item("Button", desc = "A button that emits a signal when clicked on",
                            Button("Button")
                        ), # Item
                        Item("ToggleButton", desc = "A button that maintain its state",
                            ToggleButton("ToggleButton")
                        ), # Item
                        Item("Dropdown", desc = "A widget that allows the user to choose an item from a list of options.",
                            Dropdown("Foo", "Bar", "Qux")
                        ), # Item
                        Item("ColorButton", desc = "Opens a color chooser dialog",
                            ColorButton("#f1a")
                        ), # Item
                        Item("Switch", desc = "A “light switch” style toggle",
                            Switch(false)
                        ) # Item
                    ]
                ]),
                Grid(spacing = 10, halign = Center, [
                    [
                        Item("TextField", desc = "A single line text entry widget.",
                            TextField(text = "Hello, world!")
                        ), # Item
                        Item("SpinButton", desc = "Retrieves a number from the user",
                            SpinButton(-50:50)
                        ), # Item
                    ]
                ]),
                Frame("",
                    Expander("Expander", halign = Center, margin = 20,
                        Box(:v, spacing = 10, margin = 20,
                            Button("Foo"),
                            Button("Bar"),
                            Button("Qux"),
                        )
                    )
                ),
                Item("Grid", 
                    Grid(spacing = 20, [
                        Button("□") Button("□") Button("□")
                        Button("□") Button("□") Button("□")
                        Button("□") Button("□") Button("□")
                    ])
                )
            ) # Box
        ) # Scrolled
    ) # Window
end

app = App("Widgets test", width=900, height=720)
@showall app
# @waitfor app.destroy
Lynx.destroy(app)

end # testset