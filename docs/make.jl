using Lynx
using Documenter

DocMeta.setdocmeta!(Lynx, :DocTestSetup, :(using Lynx); recursive=true)

makedocs(;
    modules=[Lynx],
    authors="Jorge Brito <jorge.brito.json@gmail.com>",
    repo="https://github.com/jorge-brito/Lynx.jl/blob/{commit}{path}#{line}",
    sitename="Lynx.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(
    repo = "github.com/jorge-brito/Lynx.jl.git",
    target = "build"
)