using Undefs
using Documenter

DocMeta.setdocmeta!(Undefs, :DocTestSetup, :(using Undefs); recursive=true)

makedocs(;
    modules=[Undefs],
    authors="Mark Kittisopikul <markkitt@gmail.com> and contributors",
    repo="https://github.com/mkitti/Undefs.jl/blob/{commit}{path}#{line}",
    sitename="Undefs.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://mkitti.github.io/Undefs.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/mkitti/Undefs.jl",
    devbranch="main",
)
