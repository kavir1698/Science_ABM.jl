using Pkg
Pkg.activate(@__DIR__)

using Documenter, Agents
using Science_ABM
using Literate

# %% Literate convertion
# indir = joinpath(@__DIR__, "..", "examples")
outdir = joinpath(@__DIR__, "src")
# for file in ("example1.jl", "example2.jl")
# 	Literate.markdown(joinpath(indir, file), outdir)
# end

# %%
makedocs(modules = [Science_ABM,],
sitename= "Science_ABM.jl",
authors = "Ali R. Vahdati and Carlos Melian.",
doctest = false,
format = Documenter.HTML(
    prettyurls = get(ENV, "CI", nothing) == "true",
    ),
pages = [
	"Introduction" => "index.md",
	"Model description" => "model_description.md",
	# "Tutorial" => "tutorial.md",
	# "Examples" => [
	#   "Simple Wright-Fisher" => "example1.md",
	#   "Predator prey" => "example2.md"
	# 	],
    ],
)

if get(ENV, "CI", nothing) == "true"
    deploydocs(repo = "github.com/kavir1698/Science_ABM.jl.git",
               target = "build")
end
