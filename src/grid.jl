"""
A container for displaying widgets in a grid.
"""
mutable struct Grid <: Container{GtkGrid}
    widget::GtkWidget
    function Grid(; homogeneous=false, spacing=0, props...) 
        self = new(@widget GtkGrid())
        self["column-homogeneous"] = homogeneous
        self["row-homogeneous"] = homogeneous
        self["row-spacing"] = spacing
        self["column-spacing"] = spacing
        return self
    end
end
"""
Represents a grid element that may span multiple rows and/or columns.

You can use the [`span`](@ref) function to create a empty `GridElement`.

Calling a empty `GridElement` as a function and passing a `Widget` as
argument will transform that widget into a `GridElement`, making it
span multiple cells in a [`Grid`](@ref) container.

## Usage:

```julia
grid = Grid([
    # The Button will span 3 columns
    [Button("Example 1") |> span(cols=3)],
    # The Button will span 2 rows
    [Button("Example 2") |> span(rows=2)],
    # The Button will span an 2 rows and 3 columns
    [Button("Example 3") |> span(2, 3)],
])
```
"""
struct GridElement <: Iterable
    width::Int
    height::Int
    widget::Widget
    GridElement() = new(1, 1)
    GridElement(w::Int, h::Int) = new(w, h)
    GridElement(widget::Widget, w::Int, h::Int) = new(w, h, widget)
end

(cell::GridElement)(widget::Widget) = GridElement(widget, cell.width, cell.height)
"""
        span(; rows = 1, cols = 1) -> GridElement
    
Creates a empty [`GridElement`](@ref) that spans multiple `rows` and `cols`.
"""
span(; rows::Int = 1, cols::Int = 1) = GridElement(cols, rows)
"""
        span(rows, cols) -> GridElement
    
Creates a empty [`GridElement`](@ref) that spans multiple `rows` and `cols`.
"""
span(cols::Int, rows::Int) = GridElement(cols, rows)
"""
        rspan(rows) -> GridElement

Creates a empty [`GridElement`](@ref) that spans multiple `rows`
"""
rspan(rows::Int) = span(1, rows)
"""
        cspan(columns) -> GridElement

Creates a empty [`GridElement`](@ref) that spans multiple `columns`
"""
cspan(columns::Int) = span(columns, 1)

Base.isempty(element::GridElement) = !isdefined(element, :widget)
"""
        Grid(rows::Vector; props...) -> Grid

Creates a Grid and adds to it each element in `rows`.

The `rows` argument must be a list of `Vector{<:Widget}`.
The position of each element in `rows` determines its
position within the grid.

You can also use [`GridElement`](@ref) to make widgets span
multiple cells within the grid.

## Example:

```julia
grid = Grid(
    [Label("A"), Label("B")],
    [Label("C"), Label("D")],
    # span 2 columns
    [Label("E") |> span(cols=2)]
)
```
"""
function Grid(rows::Vector; props...)
    self = Grid(; props...)
    for (j, row) in enumerate(rows)
        for (i, element) in enumerate(row)
            if element isa Widget
                self[i, j] = element
            elseif element isa GridElement && !isempty(element)
                w, h, widget = element
                x, y = i:i + w - 1, j: j + h - 1
                self[x, y] = widget
            else
                # ignore
            end
        end
    end
    return self
end
"""
        Grid(layout::String, elements::NamedTuple; props...) -> Grid

Create a `Grid` based on a layout.

The `layout` argument is a `String` representation of the Grid.
Each cell can be empty `.` or can have a name. Then, the `layout`
will be transformed in an Array and every named cell will be 
replaced by the widget in `elements` based on its name.

Layout example:

```julia
layout = \"\"\"
    header  .       . .       
    sidebar section . items_a
    .       .       . .
    .       .       . items_b
    footer  .       . .
\"\"\"
```
The `.` (dot) character represents a empty cell that
create space for element that span multiple cells.

Each row is separated by the `\\n` (new-line) character
and each cell by `space`. You can name each cell, as long
as the name don't have spaces.

Now we can use this `layout` and pass our widgets:

```julia
Grid(layout, (
    header  = Button("Header")  |> cspan(4),
    sidebar = Button("Sidebar") |> rspan(3),
    section = Button("Section") |> span(2, 3),
    items_a = Button("Items A") |> rspan(2),
    items_b = Button("Items B"),
    footer  = Button("Footer") |> cspan(4)
)),
```

"""
function Grid(layout::String, elements::NamedTuple; props...)
    rows = map(split(layout, "\n")) do row
        row = filter(!isempty, split(row, r"\s+"))
        map(row) do name
            if name == "."
                return GridElement()
            elseif hasproperty(elements, Symbol(name))
                return getproperty(elements, Symbol(name))
            else
                return GridElement()
            end
        end
    end
    return Grid(rows; props...)
end

function Grid(rows::Pair{String, <:Widget}...; label = (str) -> Label(str, halign=Start, valign=Center), props...)
    _rows = []
    for (key, widget) in rows
        row = []
        if startswith(key, "#") # hide
            append!(row, [widget |> cspan(2), span()])
        else
            append!(row, [label(key), widget])
        end
        push!(_rows, row)
    end
    return Grid(_rows; props...)
end