mutable struct Problem{F<:AbstractFloat}
	success_probability::F
	complexity::F
	time_to_finish::F
	information::F  # amount of information that will result from solving this problem, if there is a positive result.
	start_time::Int  # the time step in which this project started
end

mutable struct Researcher{F<:AbstractFloat, P<:Problem} <: AbstractAgent
	id::Int
	# risk_taking::Array{Float64} # A list with two values, defining the min and max risk he takes.
	risk_taking::F # The projects are chosen with this confidence that they will succeed.
	generality::F  # how general questions the researcher asks. Questions that are more general, possibly linking different branches of science, take longer, but are also more informative. between 0-1, where 1 is most general
	## resume
	experience::Int  # number of months of experience as a researcher
	problem_history::Vector{P}  # chronological order of problems tackled by the researcher
	publication_success::Vector{Union{Missing, Bool}}  # which of the projects in problem_history are published and which are not 
	publication_citations::Vector{Int}  # number of citations for each published paper
	grant::F  # number of years that the researcher has money for research.
	received_grants::Vector{F}  # years of grant received or not received for each try (not receiving grants are not recorded in problem history or publication success)
end

Researcher(x) = Researcher(x, 0.5, 0.5, 0, Problem{typeof(0.5)}[], Union{Missing, Bool}[], Int[], 0.0, typeof(0.5)[])
Researcher(id::Int, x::AbstractFloat, y::AbstractFloat) = Researcher(id, x, y, 0, Problem{typeof(x)}[], Union{Missing, Bool}[], Int[], 0.0, typeof(x)[])


