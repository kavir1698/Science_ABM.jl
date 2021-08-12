# Function for data collection
# TODO: modify the code below

function knowledge_output_all(researchers::Array{Researcher})
	nresearchers = length(researchers)
	produced_knowledge = Array{Array{Float64}}(undef, nresearchers)
	for (index, researcher) in enumerate(researchers)
		produced_knowledge1 = knowledge_output(researcher)
		produced_knowledge[index] = produced_knowledge1
	end
	return produced_knowledge
end

function summary_stats(researchers::Array{Researcher})
	all_knowledge = knowledge_output_all(researchers)  # an array of arrays, each of which show the produced knowledge by each researcher from different projects.
	sum_knowledge_per_person = [sum(i) for i in all_knowledge]
	mean_knowledge_per_person = mean(sum_knowledge_per_person)
	std_knowledge_per_person = std(sum_knowledge_per_person)
	median_knowledge_per_person = median(sum_knowledge_per_person)
	minimum_knowledge_per_person = minimum(sum_knowledge_per_person)
	maximum_knowledge_per_person = maximum(sum_knowledge_per_person)
	
	submissions_per_author = [length(r.publication_success) for r in researchers]
	publications_per_author = [length(findall(a-> !ismissing(a) && a==true, r.publication_success)) for r in researchers]

	n_researchers = length(researchers)
	researcher_exps = getproperty.(researchers, :experience)
	mean_researcher_exp = mean(researcher_exps)
	std_researcher_exp = std(researcher_exps)

	granted_researchers = getproperty.(researchers, :grant)
	n_granted_researchers = length(findall(a-> a>0, granted_researchers))
	mean_granted_researchers = mean(granted_researchers)
	std_granted_researchers = std(granted_researchers)

	latest_citations = [r.publication_citations[end] for r in researchers if length(r.publication_citations) > 0]
	if length(latest_citations) > 0
		mean_latest_citations = mean(latest_citations)
		std_latest_citations = std(latest_citations)
	else
		mean_latest_citations = 0.0
		std_latest_citations = 0.0
	end

	totalcitations = [sum(res.publication_citations) for res in researchers]
	nona = findall(a-> !isnan(a), totalcitations)
	meancitations = mean(totalcitations[nona])
	stdcitations = std(totalcitations[nona])

	mean_risks, std_risks, mean_generality, std_generality = risk_taking_stats(researchers)
	
	return (sum_knowledge_per_person=sum_knowledge_per_person, mean_knowledge_per_person=mean_knowledge_per_person, std_knowledge_per_person=std_knowledge_per_person, median_knowledge_per_person=median_knowledge_per_person, minimum_knowledge_per_person=minimum_knowledge_per_person, maximum_knowledge_per_person=maximum_knowledge_per_person, submissions_per_author=submissions_per_author, publications_per_author=publications_per_author, n_researchers=n_researchers, researcher_exps=researcher_exps, mean_researcher_exp=mean_researcher_exp, std_researcher_exp=std_researcher_exp, n_granted_researchers=n_granted_researchers, mean_granted_researchers=mean_granted_researchers, std_granted_researchers=std_granted_researchers, latest_citations=latest_citations, mean_latest_citations=mean_latest_citations, std_latest_citations=std_latest_citations, totalcitations=totalcitations, meancitations=meancitations, stdcitations=stdcitations, mean_risks=mean_risks, std_risks=std_risks, mean_generality=mean_generality, std_generality=std_generality)
end

function risk_taking_stats(researchers::Array{Researcher})
	risk_taking = getproperty.(researchers, :risk_taking)
	generality = getproperty.(researchers, :generality)

	mean_risks = mean(risk_taking)
	std_risks = std(risk_taking)
	mean_generality = mean(generality)
	std_generality = std(generality)

	return mean_risks, std_risks, mean_generality, std_generality
end

function summary_stats_small(researchers::Array{Researcher})
	all_knowledge = knowledge_output_all(researchers)  # an array of arrays, each of which show the produced knowledge by each researcher from different projects.
	sum_knowledge_per_person = [sum(i) for i in all_knowledge]
	sum_knowledge = sum(sum_knowledge_per_person)
	mean_knowledge_per_person = mean(sum_knowledge_per_person)
	std_knowledge_per_person = std(sum_knowledge_per_person)

	submissions_per_author = [length(findall(a-> !ismissing(a), r.publication_success)) for r in researchers]
	mean_submission_per_author = mean(submissions_per_author)
	std_submission_per_author = std(submissions_per_author)

	publications_per_author = [length(findall(a-> !ismissing(a) && a==true, r.publication_success)) for r in researchers]
	mean_publication_per_author = mean(publications_per_author)
	std_publication_per_author = std(publications_per_author)

	n_researchers = length(researchers)
	researcher_exps = getproperty.(researchers, :experience)
	mean_researcher_exp = mean(researcher_exps)
	std_researcher_exp = std(researcher_exps)

	granted_researchers = getproperty.(researchers, :grant)
	mean_granted_researchers = mean(granted_researchers)
	std_granted_researchers = std(granted_researchers)

	latest_citations = [researcher.publication_citations[end] for researcher in researchers if length(researcher.publication_citations) > 0]
	if length(latest_citations) > 0
		mean_latest_citations = mean(latest_citations)
		std_latest_citations = std(latest_citations)
	else
		mean_latest_citations = 0
		std_latest_citations = 0
	end

	mean_risks, std_risks, mean_generality, std_generality = risk_taking_stats(researchers)
	
	return (sum_knowledge=sum_knowledge, mean_knowledge_per_person=mean_knowledge_per_person, std_knowledge_per_person=std_knowledge_per_person, mean_submission_per_author=mean_submission_per_author, std_submission_per_author=std_submission_per_author, mean_publication_per_author=mean_publication_per_author, std_publication_per_author=std_publication_per_author, n_researchers=n_researchers, mean_researcher_exp=mean_researcher_exp, std_researcher_exp=std_researcher_exp, mean_granted_researchers=mean_granted_researchers, std_granted_researchers=std_granted_researchers, mean_latest_citations=mean_latest_citations, std_latest_citations=std_latest_citations, mean_risks=mean_risks, std_risks=std_risks, mean_generality=mean_generality, std_generality=std_generality)
end

"""
detailed_researcher_stats(researcher::Researcher)
"""
function detailed_researcher_stats(res)
	npapers = length(findall(a-> !ismissing(a) && a==true, res.publication_success))
	nprojects = length(res.publication_success)
	sumknowledge = sum(knowledge_output(res))
	age = res.experience
	risk = res.risk_taking
	sumcitations = sum(res.publication_citations)

	return npapers, nprojects, sumknowledge, age, risk, sumcitations
end

struct Detailed_stats
	scores::Array{AbstractFloat}
	npapers::Array{Integer}
	nprojects::Array{Integer}
	sumknowledges::Array{AbstractFloat}
	ages::Array{Integer}
	risks::Array{AbstractFloat}
	sumcitations::Array{Integer}
end

function detailed_researchers_stats(researchers::Array, A, B, C)
	nresearchers = length(researchers)

	scores = Array{AbstractFloat}(undef, nresearchers)
	npapers = Array{Integer}(undef, nresearchers)
	nprojects = Array{Integer}(undef, nresearchers)
	sumknowledges = Array{AbstractFloat}(undef, nresearchers)
	ages = Array{Integer}(undef, nresearchers)
	risks = Array{AbstractFloat}(undef, nresearchers)
	sumcitations = Array{Integer}(undef, nresearchers)

	for (index, res) in enumerate(researchers)
		npaper, nproject, sumknowledge, age, risk, sumcitation = detailed_researcher_stats(res)
		score = get_score(res, A, B, C)

		scores[index] = score
		npapers[index] = npaper
		nprojects[index] = nproject
		sumknowledges[index] = sumknowledge
		ages[index] = age
		risks[index] = risk
		sumcitations[index] = sumcitation
	end

	dd = Detailed_stats(scores, npapers, nprojects, sumknowledges, ages, risks, sumcitations)
	return dd
end

"""
same as detailed_researchers_stats, but collects data from multiple files
"""
function detailed_stats_multi(filepaths::Array{String}, A, B, C)
	dds = Array{Detailed_stats}(undef, length(filepaths))
	for (ind, fp) in enumerate(filepaths)
		# dd = detailed_researchers_stats(load(fp, "researchers"), A, B, C)
		dd = detailed_researchers_stats(deserialize(open(fp)), A, B, C)
		dds[ind] = dd
	end
	return dds
end