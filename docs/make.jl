using GLIBCVectorMath
using Documenter

makedocs(;
    modules=[GLIBCVectorMath],
    authors="Chris Elrod <elrodc@gmail.com> and contributors",
    repo="https://github.com/chriselrod/GLIBCVectorMath.jl/blob/{commit}{path}#L{line}",
    sitename="GLIBCVectorMath.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://chriselrod.github.io/GLIBCVectorMath.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/chriselrod/GLIBCVectorMath.jl",
)
