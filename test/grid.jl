using Lynx

@testset "grid" begin

    layout = """
        header  .       . .       
        sidebar section . items_a
        .       .       . .
        .       .       . items_b
        footer  .       . .
    """

    app = Window("Grid test", 800, 600,
        Scrolled(
            Box(:v,
                Grid(margin = 20, spacing = 20, homogeneous = true, layout, (
                    header  = Button("Header")  |> cspan(4),
                    sidebar = Button("Sidebar") |> rspan(3),
                    section = Button("Section") |> span(2, 3),
                    items_a = Button("Items A") |> rspan(2),
                    items_b = Button("Items B"),
                    footer  = Button("Footer") |> cspan(4)
                )), # Grid
                Grid(margin = 20, spacing = 20, homogeneous = true,
                    "Foo" => Button("Foo"),
                    "Bar" => Button("Bar"),
                    "Qux" => Button("Qux"),
                    "#hide" => Button("Without label"),
                ) # Grid
            ) # Box
        ) # Scrolled
    ) # Window

    # Lynx.showall(app); nothing
end