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

## Installation and basic usage

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

## Documentation

This documentation was built using [Documenter.jl](https://github.com/JuliaDocs).