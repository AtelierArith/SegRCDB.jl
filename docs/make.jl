using SegRCDB
using Documenter

DocMeta.setdocmeta!(SegRCDB, :DocTestSetup, :(using SegRCDB); recursive=true)

makedocs(;
    modules=[SegRCDB],
    authors="Satoshi Terasaki <terasakisatoshi.math@gmail.com> and contributors",
    repo="https://github.com/AtelierArith/SegRCDB.jl/blob/{commit}{path}#{line}",
    sitename="SegRCDB.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://AtelierArith.github.io/SegRCDB.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/AtelierArith/SegRCDB.jl",
    devbranch="main",
)
