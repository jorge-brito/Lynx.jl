@testset "Containers" begin
    app = Window("Containers tests", 800, 600,
        Scrolled(margin = 10,
            Box(:v,
                Frame("Boxes", margin = 20, label_xalign = 0.05,
                    Box(:v, margin = 20, spacing = 20,
                        Box(:v, spacing = 10,
                            Label("Vertical Box"),
                            Label("Vertical Box"),
                            Label("Vertical Box"),
                        ), # Box
                        Box(:h, spacing = 10,
                            Label("Horizontal Box"),
                            Label("Horizontal Box"),
                            Label("Horizontal Box"),
                        ), # Box
                    ), # Box
                ), # Frame
                Frame("Horizontal Pane", margin = 20, label_xalign = 0.05,
                    Paned(:h, margin = 20,
                        Label("Horizontal Panel", halign = Center, margin = 20),
                        Label("Horizontal Panel", halign = Center, margin = 20),
                    ), # Paned
                ), # Frame
                Frame("Vertical Pane", margin = 20, label_xalign = 0.05,
                    Paned(:v, margin = 20,
                        Label("Vertical Panel", valign = Center, margin = 20),
                        Label("Vertical Panel", valign = Center, margin = 20),
                    ), # Paned
                ), # Frame
            ), # Box
        ), # Scrolled
    ) # Window

    # showall(app)
    # @waitfor app.destroy
end # testset "Widgets"

@testset "Input Widgets" begin

    widgets = (
        Slider = Slider(1:100, start = 75, hexpand = true),
        SpinButton = SpinButton(-10:10, halign = Center),
        ColorButton = ColorButton("#1fa", halign = Center),
        ToggleButton = ToggleButton("Click-me", halign = Center),
        CheckBox = CheckBox(true, halign = Center),
        Switch = Switch(true, halign = Center),
        Dropdown = Dropdown("Item 1", "Item 2", "Item 3", halign = Center),
        TextField = TextField(text = "Hello, world!")
    )

    for (name, widget) in pairs(widgets)
        on(widget.value) do x
            @info "Value of $name has changed to $x"
        end
    end


    app = Window("Input widgets test", 800, 600,
        Box(:v, margin = 20, spacing = 20,
            widgets...
        )
    ) # Window

    # showall(app)

    widgets.Slider[] = 50
    widgets.SpinButton[] = -10
    widgets.ColorButton[] = parse(Colorant, "#111")
    widgets.ToggleButton[] = true
    widgets.CheckBox[] = false
    widgets.Switch[] = false
    widgets.Dropdown[] = 2
    widgets.TextField[] = "Lorem Ipsum"

    @test widgets.Slider[] == 50
    @test widgets.SpinButton[] == -10
    @test widgets.ColorButton[] == parse(Colorant, "#111")
    @test widgets.ToggleButton[] == true
    @test widgets.CheckBox[] == false
    @test widgets.Switch[] == false
    @test widgets.Dropdown[] == "Item 2"
    @test widgets.TextField[] == "Lorem Ipsum"

    # @waitfor app.destroy

end # testset "Input Widgets"


@testset "Common Widgets" begin

    progress = ProgressBar()
    fraction = 0;

    app = Window("Common Widgets test", 800, 600,
        Scrolled(
            Box(:v, margin = 20, spacing = 20,
                Label("""
                    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ac nulla a 
                    nisl suscipit tristique. Praesent facilisis ullamcorper facilisis. Sed consequat 
                    mauris a purus blandit semper. Morbi ullamcorper facilisis enim nec hendrerit. 
                    Interdum et malesuada fames ac ante ipsum primis in faucibus. Donec in suscipit 
                    mauris. Donec eu quam vel nulla vestibulum tempor.
                """),
                progress,
                Button("Make progress") do w
                    fraction += 0.1;
                    fill!(progress, fraction);
                end, # Button
                Button((w) -> pulse!(progress), "Pulse progress bar"),
            ), # Box
        ), # Scrolled
    ) # Window

    # showall(app)
    # @waitfor app.destroy
end