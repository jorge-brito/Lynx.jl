```@meta
DocTestSetup = quote
    using Lynx, Colors
end
```

# Introduction to Lynx

Lynx is a julia package for creating interactive applications using
the drawing tools provided by the **Luxor.jl** package and the 
widgets from the **Gtk.jl** package. 

Lynx is suitable for creating quick aplications for real time data
visualization and simulations, but it can also be used for building
GUI apps.

## Installation

Install the package using the package manager:

```
] add Lynx
```

Then load the package with:

```
using Lynx
```

To test with an example, type:

```
julia> include(joinpath(pathof(Lynx), "../../examples/basic.jl"))
```

Which should open an window with a black background and a green 
circle moving randomly.

## Basic usage

There are two ways for using Lynx.

The first uses a `LynxApp` that manages the window, the canvas and other widgets.

```julia
using Lynx
using Luxor

Lynx.init("Hello, world!", 800, 600)

t = 0

# drawing is done here
function update(dt)
    background("#111")
    origin()
    sethue("yellowgreen")
    circle(O, 50(cos(t) + 1), :fill)
    global t += dt
end

# await=true will make sure the program only
# stops when the window is closed
run!(update, await=true)
```

The second way, you create the [`Widget`](@ref)s yourself:

```julia
using Lynx
using Luxor

window = Window("Hello, world!", 400, 400)
canvas = Canvas()

push!(window, canvas)

t = 0

onupdate(canvas) do dt
    background("#111")
    origin()
    sethue("yellowgreen")
    circle(O, 50(cos(t) + 1), :fill)
    global t += dt
end

Lynx.showall(window)
@waitfor window.destroy
```

Both examples above are equivalent.

## Documentation

This documentation was built using [Documenter.jl](https://github.com/JuliaDocs).