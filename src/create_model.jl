# Create a model using Agents.jl
# TODO: modify the functions below


"""
		readparams(paramfile::String)

Read all parameters from *param_file*.

The input file is delimited by equal sing. Its first column has variable names (one variable per line)
and the second column is their values. Write the values as you
would write them inside julia: if a value is a string, enclose
it with double quotation; and write variable names without spaces.

# Example input file and explanation of its fields:

population_size=10 # starting population size
max_grants=800 # equivalent to carryin capacity
years=400 # number of years to run the simulation
risk_taking_average=0.5 # the average risk taking of the starting population
generality_average=0.5 # the average of generality of the starting populations
min_prof_exp=6 # min academic age before one can train students (have offsprings)
average_students=2 # average number of students from a poisson distribution per professor per year
max_exp=30 # maximum age of after which the agent retires (dies)
mutation_rate=0.5 # probability that a student is different from the profesor
K=1.0 # a coefficient adding value to longer projects
max_years=6 # maximum number of years an agent can have fundings per time
risk_range=0.1 # a range around the risk taking of professors from which students who are mutated will randomly receive a value
A=10
B=0
C=0
save_gens=[10,200,400]  # save the population at the given generations
plotting=false  # show the program plot figures and save summary stats?
"""
function readparams(paramfile::String)
  if ~isfile(paramfile)
    throw("File path not correct!")
  end
  paramstrings = []
  for line in eachline(open(paramfile))
    if length(line) > 2
      strippedline = strip(line)
      if ~startswith(strippedline, "#")
        param_string = replace(strippedline, "\n" => ";")
        # param_string = replace(param_string, ",", "=")
        push!(paramstrings, param_string)
      end
    end
  end
  return paramstrings
end


"
Create a homogeneous population of researchers.

parameters:
population_size: number of researchers.
number_of_grants: how many years of grants exists.
max_years: maximum number of years a researcher can receive a grant.

"
function start_population(population_size; risk_taking::Float64=0.5, generality::Float64=0.5)
	researchers = [Researcher(risk_taking, generality) for i in 1:population_size]
	return researchers
end

"
Create a heterogenous population of experienced researchers.

parameters:
population_size: number of researchers.
number_of_grants: how many years of grants exists.
max_years: maximum number of years a researcher can receive a grant.
experience: start with a min experience
K: importance of generality, i.e. problems taking longer (more general) add more to knowledge. use integers.
"
function start_experienced_population(population_size; experience::Int64=10, risk_taking_average::Float64=0.5, generality_average::Float64=0.5, max_years=10, K=1.0, A=1, B=1, C=1, randomage=true)
	researchers = start_population(population_size, risk_taking=risk_taking_average, generality=generality_average)
	if ~randomage
		for year in 1:experience
			get_grant!(researchers, population_size*10, K, max_years, A, B, C, year)
			for researcher in researchers
				update_researcher!(researcher, K)  # gain experience, do one year of research, publish finished work, receive citations
			end
		end
	else
		age_groups = Int(round(population_size/experience))
		allind = collect(1:population_size)
		ress = sample(allind, age_groups, replace=false, ordered=true)
		for ind in reverse(ress)
			splice!(allind, findfirst(a-> a==ind, allind)[1])
		end

		for year in 1:experience
			get_grant!(researchers[ress], population_size*10, K, max_years, A, B, C, year)
			for researcher in researchers[ress]
				update_researcher!(researcher, K)  # gain experience, do one year of research, publish finished work, receive citations
			end
			# remove the ress indices from allind and create new ress indices
			if age_groups >= length(allind)
				ress2 = allind
				ress = vcat(ress, allind)
				continue
			else
				ress2 = sample(allind, age_groups, replace=false, ordered=true)
				ress = vcat(ress, ress2)
			end
			for ind in reverse(ress2)
				splice!(allind, findfirst(a-> a==ind, allind))
			end
		end
	end
	return researchers
end


"
Everything that happens in a time step (e.g. a year) happens in this function.
max_years: the max number of years a researcher can receive a grant.
mutation_rate: prob that a student will be different from their supervisor.
"
function time_step!(researchers, available_grants, min_prof_exp, max_exp, mutation_rate, average_students, K, max_years, risk_range, A, B, C, current_time)
	retire_researchers!(researchers, max_exp)
	researchers = exclude_unproductive(researchers, available_grants, A, B, C, min_prof_exp)
	get_grant!(researchers, available_grants, K, max_years, A, B, C, current_time)  # researchers get their grants
	for researcher in researchers
		update_researcher!(researcher, K)  # gain experience, do one year of research, publish finished work, receive citations
	end
	new_researchers = train_students(researchers, min_prof_exp, mutation_rate, average_students, risk_range, max_years)
	for ss in new_researchers
		push!(researchers, ss)
	end
	return researchers
end


"""
at each generation, only top available_grants researchers can survive, and researchers are sorted by the total knowledge they have produced that far.
max_years: maximum number of years a researcher can ask for grants
K: importance of long problems in producing knowledge. use integers.
risk_range: the range around a professors risk taking characteristic from which a student will choose its characteristic. a float.
years: number of years the simulation will run
max_grants: max absolute number of possible grants per year
min_prof_exp: min years of experience after one can receive a professorship (have students)
average_students: average number of student per year per prof. taken from a Poisson distribution
max_exp: maximum years a researcher can work
mutation_rate: prob that a student will be different from their supervisor.
"""
function sim(population_size, max_grants, years, risk_taking_average, generality_average, min_prof_exp, average_students, max_exp, mutation_rate, max_years, K, risk_range, A, B, C, save_gens; savesuffix="", save_time_stats=false)
	
	researchers = start_experienced_population(population_size, experience=min_prof_exp*2, risk_taking_average=risk_taking_average, generality_average=generality_average, max_years=max_years, K=K, A=A, B=B, C=C)

	time_stats = Array{NamedTuple}(undef, years)
	if save_time_stats
		time_stats[1] = summary_stats_small(researchers)
	end
	available_grants = max_grants
	prog = Progress(years-1)
	savegenindex = 1
	for year in 2:years
		# println(year)
		researchers = time_step!(researchers, available_grants, min_prof_exp, max_exp, mutation_rate, average_students, K, max_years, risk_range, A, B, C, year)
		population_size = length(researchers)
		if population_size == 0
			throw("Population went extinct!")
		end
		if year == save_gens[savegenindex]
			# save("researchers_generation_$(save_gens[savegenindex])$savesuffix.jld2", "researchers", researchers)
			ff = open("researchers_generation_$(save_gens[savegenindex])$savesuffix.srz", "w")
			serialize(ff, researchers)
			close(ff)
			if savegenindex < length(save_gens)
				savegenindex += 1
			end
		end
		if save_time_stats
			time_stats[year] = summary_stats_small(researchers);
		end
		next!(prog)
	end
	return researchers, time_stats
end
