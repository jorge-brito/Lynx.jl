using Lynx
using Documenter

DocMeta.setdocmeta!(Lynx, :DocTestSetup, :(using Lynx); recursive=true)

makedocs(;
    modules=[Lynx],
    authors="Jorge Brito <jorge.brito.json@gmail.com> and contributors",
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
