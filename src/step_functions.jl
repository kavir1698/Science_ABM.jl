
"
    choose_problem(researcher::Researcher, current_time::Int, K=0, max_years=10)

Choose a random number from a given distribution as the predictability of a problem.
K: importance of more general information in producing more knowledge. Better be an integer.
max_years: max years a project can take to finish.
"
function choose_problem(researcher::Researcher, current_time::Int, K=0, max_years=10)
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
    update_researcher!(researcher::Researcher, K)

updates researchers profile by one time step (e.g. year)

K: importance of longer projects. from starts from zero. use integers.
"
function update_researcher!(researcher::Researcher, K)
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
	add_citations!(researcher, K)
end


"""
		add_citations!(researcher::Researcher, K)
		
Adds citations to previous papers
K: importance of longer projects. from starts from zero. use integers.
"""
function add_citations!(researcher::Researcher, K)
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
    get_grant!(researchers::Array{Researcher}, available_grants::Int64, K::Real, max_years::Real, A, B, C, current_time)

Years of research grant that researchers can receive.
"""
function get_grant!(researchers::Array{Researcher}, available_grants::Int64, K::Real, max_years::Real, A, B, C, current_time)
	nresearchers = length(researchers)
	problems = Array{Problem}(undef, nresearchers)  # let the researchers choose a problem first. Then, give them grants given their problems. If any one gets a grant, then the problem will be included into its history. 
	for r in 1:nresearchers
		problems[r] = choose_problem(researchers[r], current_time, K, max_years)
	end

	scores = Array{Float64}(undef, nresearchers)
	for r in 1:nresearchers
		scores[r] = get_score(researchers[r], A, B, C)
	end

	# priorities = sample(1:nresearchers, Weights(scores), nresearchers, replace=false, ordered=false)  # commenting this out because I think this function introduces too much noise, as the score differences can be very small.
	priorities = sortperm(scores, rev=true)

	index = 1
	while available_grants > 0  && index <= nresearchers
		researcher_index = priorities[index]
		researcher = researchers[researcher_index]
		problem = problems[researcher_index]
		asked_years = problem.time_to_finish
		if available_grants >= asked_years && (asked_years+researcher.grant) <= max_years
			researcher.grant += asked_years
			push!(researcher.received_grants, asked_years)
			available_grants -= asked_years

			# add the problem to the researchers history
			pushproblem!(researcher, problem)
			# researchers[researcher_index] = researcher
		end
		index += 1
	end
	if available_grants == 0 && index < nresearchers
		for ri in index:nresearchers
			researcher_index = priorities[ri]
			researcher = researchers[researcher_index]
			push!(researcher.received_grants, 0.0)
		end
	end
end


"""
     mutate_researcher!(researcher::Researcher; mutation_rate::Float64=0.01, risk_range::Float64=0.1, max_years::Int64=5)

Change a researchers risk taking personality.
"""
function mutate_researcher!(researcher::Researcher; mutation_rate::Float64=0.01, risk_range::Float64=0.1, max_years::Int64=5)
	risk_mutation = wsample([true, false], [mutation_rate, 1-mutation_rate]) 
	years_mutation = wsample([true, false], [mutation_rate, 1-mutation_rate]) 
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
    train_students(researchers::Researcher, min_experience, mutation_rate, average_students, risk_range, max_years)

researchers with a min experience can train students.

# Parameters

* min_experience: minimum experience after which a researcher can have students
* mutation_rate: probability of the student being mutated from the professor. Mutation happens both risk aversion and generality of the student.
* average_students: number of students per professor taken from a Poisson distribution
* risk_range: the range about the professors risk averation from which the student will receive a value.
* max_years: max years a project can take. the years of research is chosen randomly from 1 to this max number.  
"""
function train_students(researcher::Researcher, min_experience, mutation_rate, average_students, risk_range, max_years)
  nstudents = 0
  if researcher.experience > min_experience
    n_students_dist = Poisson(average_students)
    nstudents = rand(n_students_dist)
  else
    return
	end
  if nstudents == 0
    return
  end
  for nstudent in 1:nstudents
    student = Researcher(researcher.risk_taking, researcher.generality)
    mutate_researcher!(student, mutation_rate=mutation_rate, risk_range=risk_range, max_years=max_years)
    add_agent!(model, student) # TODO: check
  end
end

function train_students(researchers::Array{Researcher}, min_experience, mutation_rate, average_students, risk_range, max_years)
  for researcher in researchers
    train_students(researcher, min_experience, mutation_rate, average_students, risk_range, max_years)
  end
end


"""
    exclude_unproductive(researchers::Array{Researcher}, available_grants::Real, A, B, C, min_prof_exp)

Only keep the top n researchers each generation, where n=available grant.
Researchers are ranked by the `get_score` function. Excludes those with lowest scores who do not have any ongoing grant.
"""
function exclude_unproductive(researchers::Array{Researcher}, available_grants::Real, A, B, C, min_prof_exp)
	# only exclude those with lowest scores who do not have any ongoing grant.
	need_grants = findall(a -> a.grant == 0 && a.experience >= min_prof_exp, researchers)
	need_grants_len = length(need_grants)
	popsize = length(researchers)
	
	if need_grants_len == 0 || popsize < available_grants || available_grants > need_grants_len
		return researchers
	end
	
	have_grants = findall(a -> a.grant > 0, researchers)
	scores = Array{Float64}(undef, 0)
	# for researcher in researchers
	for resid in need_grants
		researcher = researchers[resid]
		score  = get_score(researcher, A, B, C)
		push!(scores, score)
	end
	sorted_researchers = sortperm(scores, rev=true)
	chosen_researchers = (1:popsize)[need_grants][sorted_researchers][1:available_grants]
	allres = researchers[vcat(have_grants, chosen_researchers)]

	return allres
end

"""
    knowledge_output(researcher::Researcher)

knowledge output of the researcher given the problems it has worked on and their publication success.
"""
function knowledge_output(researcher::Researcher)
	produced_knowledge = zeros(Float64, length(researcher.problem_history))
	published_indices = findall(a-> !ismissing(a) && a == true, researcher.publication_success)
	for index in published_indices
		problem = researcher.problem_history[index]
		produced_knowledge[index] = problem.information
	end
	return produced_knowledge    
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
    get_score(researcher::Researcher, A, B, C)

A general function for scoring researchers
"""
function get_score(researcher::Researcher, A, B, C)
	pubs = findall(a -> !ismissing(a) && a==true, researcher.publication_success)
	n_pubs = length(pubs)
	score = 1e-6
	if n_pubs == 0
		return score
	end
	citations = sum(researcher.publication_citations)
	knowledge = sum([researcher.problem_history[i].information for i in pubs])
	exp = researcher.experience
	score += (n_pubs*A/(exp)) + ((citations*B/(exp))) + ((knowledge*C)/ (exp))
	return score
end

"""
    retire_researchers!(researchers, max_exp)

retire researchers who have max_exp experience.
"""
function retire_researchers!(researchers, max_exp)
	for index in length(researchers):-1:1  # reverse because splice shifts everything to the left after removing an element.
		if researchers[index].experience == max_exp
			splice!(researchers, index)
		end
	end
end