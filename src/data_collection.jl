# Functions for data collection

# mymean(a) = isempty(a) ? missing : mean(a)
mymean(a) = isempty(a) ? 0.0 : mean(a)
mystd(a) = isempty(a) ? 0.0 : std(a)
mymedian(a) = isempty(a) ? 0.0 : median(a)
mysum(a) = isempty(a) ? 0.0 : sum(a)

"""
knowledge output of the researcher given the problems it has worked on and their publication success.
"""
function mean_knowledge_output(researcher::Researcher)
	produced_knowledge = zeros(Float64, length(researcher.problem_history))
	published_indices = findall(a-> !ismissing(a) && a == true, researcher.publication_success)
	for index in published_indices
		problem = researcher.problem_history[index]
		produced_knowledge[index] = problem.information
	end
	return mymean(produced_knowledge)    
end

submissions_per_author(r::Researcher) = length(r.publication_success)

publications_per_author(r::Researcher) = length(findall(a-> !ismissing(a) && a==true, r.publication_success))

isgranted(r::Researcher) = r.grant > 0 ? true : false

function totalcitations(r::Researcher)
	j = sum(r.publication_citations)
	if !isnan(j)
		return 0
	else
		return j
	end
end

npapers(r::Researcher) = length(findall(a-> !ismissing(a) && a==true, r.publication_success))

nprojects(r::Researcher) = length(r.publication_success)

pop(r::Researcher) = 1

adata = [
	(mean_knowledge_output, mysum),
	(mean_knowledge_output, mymean),
	# (mean_knowledge_output, mystd),
	(mean_knowledge_output, mymedian),
	(submissions_per_author, mymean),
	# (submissions_per_author, mystd),
	(submissions_per_author, mymedian),
	(publications_per_author, mymean),
	# (publications_per_author, mystd),
	(publications_per_author, mymedian),
	(:experience, mymean),
	(:experience, mymedian),
	# (:experience, mystd),
	(isgranted, count),
	(:grant, mymean),
	(totalcitations, mymean),
	# (totalcitations, mystd),
	(totalcitations, mymedian),
	(:risk_taking, mymean),
	# (:risk_taking, mystd),
	(:risk_taking, mymedian),
	(:generality, mymean),
	# (:generality, mystd),
	(:generality, mymedian),
	(npapers, mymean),
	# (npapers, mystd),
	(npapers, mymedian),
	(nprojects, mymean),
	(nprojects, mymedian),
	# (nprojects, mystd),
	(pop, mysum)
]
