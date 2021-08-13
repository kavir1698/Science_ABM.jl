# Create a model using Agents.jl

function initialize_model(param_file::AbstractString)
	# Load params
	d = YAML.load_file(param_file)
	
	r = Researcher(1, d["risk_taking_average"], d["generality_average"])
	d["time"] = 1

	model = ABM(typeof(r), properties=d, scheduler=Schedulers.randomly)
	
	
	researchers = start_population(d["population_size"], d["risk_taking_average"], d["generality_average"])
	for res in researchers
		add_agent!(res, model)
	end
	
	start_experienced_population(model, true)
	model.properties["max_grants"] = d["max_grants"] # restore this param

	return model
end

function model_step!(model::ABM)
	retire!(model)
	exclude_unproductive(model)
	get_grant!(model)
	# gain experience, do one year of research, publish finished work, receive citations
	update_researcher!(model)
	train_students!(model)
	# update time
	model.properties["time"] += 1
end

"""
Create a homogeneous population of researchers.

parameters:
population_size: number of researchers.
number_of_grants: how many years of grants exists.
max_years: maximum number of years a researcher can receive a grant.
"""
function start_population(population_size, risk_taking::Float64=0.5, generality::Float64=0.5)
	researchers = [Researcher(i, risk_taking, generality) for i in 1:population_size]
	return researchers
end

"""
Create a heterogenous population of experienced researchers.
""" 
function start_experienced_population(model, randomage=true)
	experience = model.properties["min_prof_exp"]
	population_size = model.properties["population_size"]

	if !randomage
		for year in 1:experience
			get_grant!(model)
			for resid in allids(model)
				update_researcher!(model[resid], K)  # gain experience, do one year of research, publish finished work, receive citations
			end
		end
	else
		age_groups = Int(round(population_size/experience))
		allind = collect(allids(model))
		ress = sample(allind, age_groups, replace=false, ordered=true)
		for ind in reverse(ress)
			splice!(allind, findfirst(a-> a==ind, allind)[1])
		end

		for year in 1:experience
			get_grant!(model)
			for resid in ress
				update_researcher!(model[resid], model)  # gain experience, do one year of research, publish finished work, receive citations
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
end
