"""
A container for displaying widgets in a grid.
"""
mutable struct Grid <: Container{GtkGrid}
    widget::GtkWidget
    function Grid(; homogeneous=false, spacing=0, props...) 
        self = new(@widget GtkGrid())
        self["column-homogeneous"] = homogeneous
        self["row-homogeneous"] = homogeneous
        if spacing isa Real
            self["row-spacing"] = spacing
            self["column-spacing"] = spacing
        elseif spacing isa Tuple{Real, Real}
            self["row-spacing"] = spacing[1]
            self["column-spacing"] = spacing[2]
        end
        return self
    end
end

function attach!(grid::Grid, child::Widget, x::Int, y::Int, w::Int, h::Int)
    grid[x: x + (w - 1), y:y + (h - 1)] = child
end

function attach!(grid::Grid, sibling::Widget, child::Widget, side::Symbol, w::Int, h::Int)
    gtk_grid_attach_next_to(
        gwidget(grid),
        gwidget(sibling),
        gwidget(child),
        side,
        w, h
    )
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
struct GridElement <: Widget{GtkWidget}
    widget::Widget
    w::Int
    h::Int
    GridElement() = new(NullContainer(), 1, 1)
    GridElement(w::Int, h::Int) = new(NullContainer(), w, h)
    GridElement(widget::Widget, w::Int, h::Int) = new(widget, w, h)
    GridElement(e::GridElement) = new(e.widget, e.w, e.h)
    GridElement(widget::Widget) = new(widget, 1, 1)
end

GridElement(::typeof(-)) = GridElement()

gwidget(this::GridElement) = gwidget(this.widget)

(cell::GridElement)(widget::Widget) = GridElement(widget, cell.w, cell.h)
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

Base.isempty(e::GridElement) = e.widget isa NullContainer

const GridCell = Union{<:Widget, Tuple{}}

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
    Label("A"), Label("B"),     |,
    Label("C"), Label("D"),     |,
    Label("E") |> span(cols=2), |,
)
```
"""
function Grid(cells::Union{<:Widget, typeof(-), typeof(|)}...; props...)
    self = Grid(; props...)
    rows = splitv(x -> x == |, collect(cells)) 
    for (j, row) in enumerate(rows)
        for (i, cell) in enumerate(row)
            if cell isa GridElement && !isempty(cell)
                w, h = cell.w, cell.h
                x, y = i:i + w - 1, j: j + h - 1
                self[x, y] = cell.widget
            elseif cell isa Widget
                self[i, j] = cell
            else
                # ignore
            end
        end
    end
    return self
end