
"""
Choose a random number from a given distribution as the predictability of a problem.
K: importance of more general information in producing more knowledge. Better be an integer.
max_years: max years a project can take to finish.
"""
function choose_problem(researcher::Researcher, model)
	vurrent_time = model.properties["time"]
	K = model.properties["K"]
	max_years = model.properties["max_years"]
	current_time = model.properties["time"]
	success_probability = researcher.risk_taking
  complexity = 0.0  # not incorporated into the model yet. Can determine time_to_finish. TODO
	time_to_finish = researcher.generality * max_years
	if time_to_finish < 1
		time_to_finish = 1.0
	end
	if K == 0
		generality_importance = 1
	else
		generality_importance = K * time_to_finish
	end
	problem_info = information(success_probability)  * generality_importance # amount of info the project yields
	problem = Problem(success_probability, complexity, time_to_finish, problem_info, current_time)
	return problem
end

"""
    pushproblem!(researcher::Researcher, problem::Problem)

push an already created problem to the history of a researcher
"""
function pushproblem!(researcher::Researcher, problem::Problem)
	push!(researcher.problem_history, problem)
	push!(researcher.publication_citations, 0)
	push!(researcher.publication_success, missing)
end

"
updates researchers profile by one time step (e.g. year)
"
function update_researcher!(researcher::Researcher, model)
	researcher.experience += 1
	if researcher.grant > 0
		researcher.grant -= 1
	end
	finished_problems = Integer[]
	for index in length(researcher.publication_success):-1:1
		if ismissing(researcher.publication_success[index])
			if researcher.problem_history[index].time_to_finish > 1
				researcher.problem_history[index].time_to_finish -= 1
			elseif researcher.problem_history[index].time_to_finish == 1
				researcher.problem_history[index].time_to_finish -= 1
				push!(finished_problems, index)
			end
		end
	end
	for problem_index in finished_problems
		publish!(researcher, problem_index)
	end
	add_citations!(researcher, model)
end


function update_researcher!(model::ABM)
	for researcher in values(model.agents)
		update_researcher!(researcher, model)
	end
end


"""
Adds citations to previous papers
"""
function add_citations!(researcher::Researcher, model::ABM)
	K = model.properties["K"]
	published = findall(a -> !ismissing(a) && a==true, researcher.publication_success)
	for paperind in published
		if K == 0
			generality_importance = 1.0
		else
			generality_importance = K * researcher.received_grants[paperind]
		end
		p = 1 - (researcher.problem_history[paperind].success_probability/generality_importance)
		n = round(Int64, 20 -(researcher.problem_history[paperind].start_time - researcher.problem_history[paperind].time_to_finish))  # this makes the number of citations a decreasing function of time until 20 years after which no citations will occur
		if n <= 0
			researcher.publication_citations[paperind] = 0
		else
			d = Binomial(n, p)
			researcher.publication_citations[paperind] += rand(d)
		end
	end
end


"
information(p)

find Shannon's entropy given a probability
"
function information(probability::AbstractFloat)
	info = -log(2, probability)
	return info
end

# TODO: optimize
"""
		information(res::Researcher)

Returns all information produced by a researcher.
"""
function information(res::Researcher)
	return sum([res.problem_history[i].information for i in 1:length(res.publication_success) if .&(!ismissing(res.publication_success[i], res.publication_success[i] == true))])
end

"""
    information(researchers::Array{Researcher})

Returns sum of all information produced by researchers
"""
function information(researchers::Array{Researcher})
	si = 0.0
	for res in researchers
		si += information(res)
	end
	return si
end


"
    publish!(researcher::Researcher, problem_index::Int64)

Check whether a research project is accepted to for publication given its `success_probability`.
"
function publish!(researcher::Researcher, problem_index::Int64)
	p = researcher.problem_history[problem_index].success_probability  # probability to publish, i.e. the project yielded the expected result
	if rand() <= p
		researcher.publication_success[problem_index] = true
	else
		researcher.publication_success[problem_index] = false
	end
end


"""
Years of research grant that researchers can receive.
"""
function get_grant!(model::ABM)
	nresearchers = nagents(model)
	max_years  = model.properties["max_years"]
	ids = collect(allids(model))
	scores = Array{Float64}(undef, nresearchers)
	counter = 1
	for id in ids
		scores[counter] = get_score(model[id], model)
		counter += 1
	end

	priorities = sortperm(scores, rev=true)

	index = 1
	while model.properties["max_grants"] > 0  && index ≤ nresearchers
		resid = ids[priorities[index]]
		researcher = model[resid]
		problem = choose_problem(researcher, model)
		asked_years = problem.time_to_finish
		if model.properties["max_grants"] >= asked_years && (asked_years+researcher.grant) <= max_years
			researcher.grant += asked_years
			push!(researcher.received_grants, asked_years)
			model.properties["max_grants"] -= asked_years

			# add the problem to the researchers history
			pushproblem!(researcher, problem)
			# researchers[researcher_index] = researcher
		end
		index += 1
	end
	if model.properties["max_grants"] == 0 && index < nresearchers
		for ri in ids[index:nresearchers]
			resid = ids[priorities[index]]
			push!(model[resid].received_grants, 0.0)
		end
	end
end


"""
Change a researchers risk taking personality.
"""
function mutate_researcher!(researcher::Researcher, model::ABM)
	μ = model.properties["mutation_rate"]
	risk_range  = model.properties["risk_range"]
	max_years  = model.properties["max_years"]
	risk_mutation = wsample([true, false], [μ, 1-μ]) 
	years_mutation = wsample([true, false], [μ, 1-μ]) 
	if risk_mutation
		lbound = researcher.risk_taking-risk_range
		ubound = researcher.risk_taking+risk_range
		if lbound < 0.01
			lbound = 0.01
		end
		if ubound > 0.99
			ubound = 0.99
		end
		researcher.risk_taking = rand(lbound:0.01:ubound)
	end
	if years_mutation
		current = researcher.generality
		lbound = researcher.generality - 1
		ubound = researcher.generality + 1
		lbound < 0.5 ? lbound = 0.5 : lbound
		ubound > max_years ? ubound = max_years : ubound
		researcher.generality = rand(lbound:0.1:ubound)
	end
end

"""
researchers with a min experience can train students.
"""
function train_students!(researcher::Researcher, model::ABM)
  nstudents = 0
  if researcher.experience > model.properties["min_prof_exp"]
    n_students_dist = Poisson(model.properties["average_students"])
    nstudents = rand(n_students_dist)
  else
    return
	end
  if nstudents == 0
    return
  end
  for nstudent in 1:nstudents
    student = Researcher(nextid(model), researcher.risk_taking, researcher.generality)
    mutate_researcher!(student, model)
    add_agent!(student, model)
  end
end

function train_students!(model::ABM)
  for researcher in values(model.agents)
    train_students!(researcher, model)
  end
end

"""
    get_hindex(researcher::Researcher)

Calculates H-index for a researcher.
"""
function get_hindex(researcher::Researcher)
	cited_papers = findall(researcher.publication_citations)
	sort!(cited_papers, rev=true)
	hindex = 0.000001  # I need a positive number for sampling in get_grant!
	for (index, pos) in enumerate(cited_papers)
		if pos >= index
			hindex = index
		else
			break
		end
	end
	return hindex
end


"""
A general function for scoring researchers
"""
function get_score(researcher::Researcher, model::ABM)
	A = model.properties["A"]
	B = model.properties["B"]
	C = model.properties["C"]
	pubs = findall(a -> !ismissing(a) && a==true, researcher.publication_success)
	n_pubs = length(pubs)
	score = 1e-6
	if n_pubs == 0
		return score
	end
	citations = sum(researcher.publication_citations)
	knowledge = sum([researcher.problem_history[i].information for i in pubs])
	exp = researcher.experience
	score += ((n_pubs*A) + (citations*B) + (knowledge*C)) / exp
	return score
end

function retire!(researcher::Researcher, model::ABM)
	if researcher.experience ≥ model.properties["max_exp"]
		kill_agent!(researcher, model)
	end
end

function retire!(model::ABM)
	for researcher in values(model.agents)
		retire!(researcher, model)
	end
end


function needing_grants(model)
	output = Int[]
	for (id, agent) in model.agents
		if agent.grant == 0 && agent.experience >= model.properties["min_prof_exp"]
			push!(output, id)
		end
	end
	return output
end

function having_grants(model)
	output = Int[]
	for (id, agent) in model.agents
		if agent.grant > 0
			push!(output, id)
		end
	end
	return output
end

function researcher_scores(model, need_grants)
	scores = Float64[]
	for resid in need_grants
		score  = get_score(model[resid], model)
		push!(scores, score)
	end
	return scores
end

"""
Only keep the top n researchers each generation, where n=available grant.
Researchers are ranked by the `get_score` function. Excludes those with lowest scores who do not have any ongoing grant.
"""
function exclude_unproductive!(model::ABM)
	# only exclude those with lowest scores who do not have any ongoing grant.
	need_grants = needing_grants(model)
	need_grants_len = length(need_grants)
	popsize = nagents(model)
	available_grants = round(Int, model.properties["max_grants"])

	if need_grants_len == 0 || popsize < available_grants || available_grants > need_grants_len
		return
	end
	
	# have_grants = having_grants(model)
	scores = researcher_scores(model, need_grants)
	# kill with probability proportional to score
	to_die_count = length(needing_grants) - available_grants
	to_die = wsample(needing_grants, 1 .- scores, to_die_count, replace=false)
	# sorted_researchers = sortperm(scores, rev=true)
	# to_die = need_grants[sorted_researchers][available_grants+1:end]
	for id in to_die
		kill_agent!(id, model)
	end
end