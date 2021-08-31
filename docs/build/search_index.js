var documenterSearchIndex = {"docs":
[{"location":"api.html#API","page":"API","title":"API","text":"","category":"section"},{"location":"api.html#Parameters","page":"API","title":"Parameters","text":"","category":"section"},{"location":"api.html","page":"API","title":"API","text":"The parameters below are required for any simulation. They should be in a dictionary object. The dictionary keys should be the parameters names as Symbol (with a colon \":\" before the name). See the Tutorial page for an example of the parameters dictionary.","category":"page"},{"location":"api.html","page":"API","title":"API","text":"ploidy: A tuple specifying the ploidy of each species. Currently only support ploidy=1 (haploid) and ploidy=2 (diploid).\nphenotypes: A tuple specifying the number of phenotypes p for each species.\nngenes: A tuple specifying the number of genes l for each species.\ngrowthrates: A tuple specifying growth rate for each species. Growth rates are for a logistic growth model, where N_t+1 = N_t + rtimes N_t times (1 - ((N_t  K)), where N is population size, t is time, r is growth rate and K is carrying capacity. If r=0, population size remains constant.\ninteractionCoeffs: A matrix containing competition coefficients between each pair of species. A competition coefficient c_ij denotes the strength of competition exerted by an individual of species j on an individual of species i.\ninteraction_equation: either textrmlotkaVoltera_generalized (if you want host-parasite or predator prey dynamics) or textrmlotkaVoltera_competition. Default is textrmlotkaVoltera_competition. The LV competition equation is as follows. It uses the Lotka-Voltera equation Ni_t+1 = Ni_t + rtimes Ni_t times (1 - ((Ni_t + sum_j=1^Nspecies c_ijNj_t)Ki) where c is competition coefficient. When competition coefficient is positive, population j competes with population i. If negative, population j helps population i to grow. And if 0, population j does not affect population i. If c_ij  0 and c_ji  0, both populations are in competition, if c_ij  0 and c_ji  0, species i is a parasite of species j. If c_ij  0 and c_ji  0, the two species have a mutualistic relationship. If c_ij  0 and c_ji = 0, they have a commensal relationship. It can also be nothing. The generalized Lotka-Voltera equation is x_t+1 = x_t + D(x_t)(r + Cx_t), where x is an array population densities of all species (NK), r is an array of growth rates when growing alone, C is interaction coefficient matrix.\npleiotropyMat: A tuple of pleiotropy matrices, one for each species. A pleitropy matrix is a binary matrix with size p times l that specifies the phenotypes that each locus affects.\nepistasisMat: A tuple of epistasis matrices, one for each species. An epistasis matrix is of size l times l and specifies the direction (positive or negative) and size of effect of one loci on the other loci. For example, if at row 1 and column 2 is a value 0.2, it means that locus 1 affects locus 2 by increasing the effect of locus 2 (because its positive) with 20% of the effect of locus 1. The effect of loci are themselves specified in the q vector.\nexpressionArrays: A tuple of expression arrays, one for each species. An expression array q shows the effect size of a locus. It can be thought of expression level of a gene.\nselectionCoeffs: A tuple  of selection coefficients for each species.\noptPhenotypes: A tuple of arrays, where each inner array specifies optimal phenotypes θ for each species. Each inner array should be of length p (number of phenotypes) of its corresponding species.\ncovMat: A tuple of matrices, each of which ω represents a covariance matrix of the selection surface. Each matrix is of size ptimes p.\nmutProbs: A tuple of arrays, one per species. Each inner array specifies the probabilities for different type of mutations. An inner array has three values with the following order: first, the probability that an individual's gene expressions (array q) mutate per generation. Second, the probability that an individual's pleiotropy matrix mutates per generation. Third, the probability that an individual's epistasis matrix mutates per generation. If an individual is going to receive a mutation at any of the mentioned levels, the amount of change that it receives is determined by mutMagnitudes.\nmutMagnitudes: A tuple of arrays, one for each species. Each inner array has three numbers specifying the amount of change per mutation in gene expression (q), pleiotropy matrix (b), and epistasis matrix a, respectively. The first number is the variance of a normal distribution with mean zero. If an individual's gene expression is going to mutate, random numbers from that distribution are added to the expression of each locus. The second number is a probability that any one element in the pleiotropy matrix will switch - if on, becomes off, and vice versa. The third number is again the variance of another normal distribution with mean zero. Random numbers taken from such distribution are added to each element of the epistasis matrix.\nN: A dictionary where each key is a node number and its value is a tuple for population size of each species at that node. This dictionary does not have to have a key for all the nodes, but it should have a value for all the species.\nK: A dictionary where each key is a node number and its value is tuple of carrying capacities K of the node for each species. The dictionary should have a key for all the nodes and carrying capacity for each species per node.\nmigration_rates: An array of matrices, each matrix shows migration rates between each pair of nodes for a species. The rows and columns of the matrix are node numbers in order. Values are read column-wise: each column shows out-migration to all other nodes from a node. If instead of a matrix, there is nothing, no migration occurs for that species.\nE: A tuple  of the variance of a normal distribution ε representing environmental noise for each species.\ngenerations: number of generations to run the simulation.\nspace: (default=nothing) Either a tuple of size 2 or 3 for a grid size or a SimpleGraph object for an arbitrary graph. If it is a tuple, a grid is built internally\nmoore: (default=false) Whether nodes in the grid have 8 neighbors (Moore neighborhood). Default is false, i.e. cells only have 4 neighbors.\nperiodic: (default=false) If space is 2D, should the edges connect to the opposite side?\nseed: (default=0). Seed for random number generator. Only set if >0.","category":"page"},{"location":"api.html#Simulation-outline","page":"API","title":"Simulation outline","text":"","category":"section"},{"location":"api.html","page":"API","title":"API","text":"Within each time-step, the following occurs:","category":"page"},{"location":"api.html","page":"API","title":"API","text":"Mutation\nFitness update\nMigration\nReproduction (only for diploids)\nselection","category":"page"},{"location":"api.html#Mutation","page":"API","title":"Mutation","text":"","category":"section"},{"location":"api.html","page":"API","title":"API","text":"Mutation can happen at three levels: changing the expression of each gene expressionArrays, changing the pleiotropy matrix pleiotropyMat, and changing the epistatic interactions between genes. The probability that a mutation occurs at each of these levels is controlled by parameter mutProbs. And size of mutations when they occur are controlled by parameter mutMagnitudes. The genotype vector y and pleiotropy matrix B of each individual mutates.","category":"page"},{"location":"api.html","page":"API","title":"API","text":"Epistatic matrix A and expression vectors Q mutate by adding their values to random numbers from a normal distribution with mean 0 and standard deviation given in parameter mutMagnitudes.","category":"page"},{"location":"api.html","page":"API","title":"API","text":"B mutates by randomly switching 0s and 1s with probability given in parameter mutMagnitudes.","category":"page"},{"location":"api.html#Fitness-update","page":"API","title":"Fitness update","text":"","category":"section"},{"location":"api.html","page":"API","title":"API","text":"Fitness of each individual updates after mutation. Fitness is W = exp(γ times transpose(z - θ)times inv(ω)times (z - θ)), where is the phenotype vector (z = pleiotropyMat(Aq) + μ), γ is selection coefficient, θ is optimum phenotypes vector, and ω is covariance matrix of selection surface. ","category":"page"},{"location":"api.html#Migration","page":"API","title":"Migration","text":"","category":"section"},{"location":"api.html","page":"API","title":"API","text":"Each agent moves with probabilities given in migration_rates to other nodes.","category":"page"},{"location":"api.html#Reproduction","page":"API","title":"Reproduction","text":"","category":"section"},{"location":"api.html","page":"API","title":"API","text":"When a species is diploid, they sexually reproduce. To that end, individuals of the same species in the same location are randomly paired. Each pair produces one offspring. Then the parents die.","category":"page"},{"location":"api.html","page":"API","title":"API","text":"To produce an offspring, each parent contributes to half of the offspring's genotype y and pleiotropy matrix B. The genes coming from each parent are randomly assigned.","category":"page"},{"location":"api.html#Selection","page":"API","title":"Selection","text":"","category":"section"},{"location":"api.html","page":"API","title":"API","text":"A number of individuals n are selected for the next generation via sampling with replacement weighted by individuals' fitness values. n is calculated using the Lotka-Voltera model for population competition Ni_t+1 = Ni_t + rtimes Ntimes (1 - ((Ni + cNj)K) where N is population size, t is time, r is growth rate and K is carrying capacity, and c is competition coefficient. Briefly, each population growth with a logistic model when it is not affected by other species. Otherwise, its growth increases or decreases depending on its interactions with other species.","category":"page"},{"location":"api.html#Data-collection","page":"API","title":"Data collection","text":"","category":"section"},{"location":"api.html","page":"API","title":"API","text":"The interface to the model is from the runmodel function (see Tutorial).","category":"page"},{"location":"api.html","page":"API","title":"API","text":"EvoDynamics.jl uses Agents.jl underneath. See Agents.jl's documentation for details about writing functions to collect any data during simulations. Here, we explain the specific implementation of the model.","category":"page"},{"location":"api.html","page":"API","title":"API","text":"There are two main objects from which you can collect data: and agent object of type AbstractAgent and a model object of type ABM. Both of these types are defined the Agents.jl package.","category":"page"},{"location":"api.html","page":"API","title":"API","text":"Agent object has the following fields: id, positions, species, epistasisMat (epistasis matrix), pleiotropyMat (pleiotropy matrix), and q (gene expression array).","category":"page"},{"location":"api.html","page":"API","title":"API","text":"The model object has the following fields: space which is a GraphSpace or GridSpace object from Agents.jl, agents that is an array holding all agents, and properties which is a dictionary holding all the parameters passed to the model.","category":"page"},{"location":"api.html","page":"API","title":"API","text":"To collect data, provide a dictionary where the keys are either agent fields, or :model. The value of a key is an array of any number of functions.","category":"page"},{"location":"api.html","page":"API","title":"API","text":"If a key is an agent field, all the value of the field from all agents are collected and then aggregated with the functions in the value. For example, to collect mean and median fitness of individuals which is in field W, your dictionary will be Dict(:W => [mean, median]).","category":"page"},{"location":"api.html","page":"API","title":"API","text":"If a key is :model, functions in its value array should be functions that accept a single argument, the model object, and return a single number or a tuple of numbers. For example, this is the default dictionary and its function:","category":"page"},{"location":"api.html","page":"API","title":"API","text":"collect = Dict(:model => [mean_fitness_per_species])\n\n\"Returns a tuple whose entries are the mean fitness of each species.\"\nfunction mean_fitness_per_species(model::ABM)\n  nspecies = length(model.properties[:nphenotypes])\n  mean_fitness = Array{Float32}(undef, nspecies)\n  for species in 1:nspecies\n    fitness = mean([i.W for i in values(model.agents) if i.species == species])\n    mean_fitness[species] = fitness\n  end\n\n  return Tuple(mean_fitness)\nend","category":"page"},{"location":"example2.html","page":"Weak modular structure","title":"Weak modular structure","text":"EditURL = \"<unknown>/examples/example2.jl\"","category":"page"},{"location":"example2.html#Weak-modular-structure","page":"Weak modular structure","title":"Weak modular structure","text":"","category":"section"},{"location":"example2.html","page":"Weak modular structure","title":"Weak modular structure","text":"using EvoDynamics\nusing Agents\nusing Distributions\nusing Random\nusing LinearAlgebra\n\nnspecies = 10\nnphenotypes = fill(3, nspecies)\nngenes = fill(3, nspecies)\nploidy = fill(1, nspecies)\nepistasisMat = Tuple([rand(Normal(0, 0.01), i, i) for i in (ngenes .* ploidy)])","category":"page"},{"location":"example2.html","page":"Weak modular structure","title":"Weak modular structure","text":"choose random values for epistasis matrix epistasisMat, but make sure the diagonal is 1.0, meaning that each locus affects itself 100%.","category":"page"},{"location":"example2.html","page":"Weak modular structure","title":"Weak modular structure","text":"for index in 1:length(epistasisMat)\n  for diag in 1:size(epistasisMat[index], 1)\n    epistasisMat[index][diag, diag] = 1.0\n  end\nend\n\nmig = rand(10, 10)\nmig[LinearAlgebra.diagind(mig)] .= 1.0\n\nparameters = Dict(\n  :ngenes => ngenes .* ploidy,\n  :nphenotypes => nphenotypes,\n  :growthrates => fill(0.1, nspecies),\n  :interactionCoeffs => rand(Normal(0, 0.001), nspecies, nspecies),\n  :pleiotropyMat => Tuple([LinearAlgebra.diagm(fill(true, max(nphenotypes[i], ngenes[i] * ploidy[i]))) for i in 1:nspecies]),\n  :epistasisMat =>  epistasisMat,\n  :expressionArrays => Tuple([rand() for el in 1:l] for l in ngenes .* ploidy),\n  :selectionCoeffs => fill(0.0, nspecies),\n  :ploidy => ploidy,\n  :optPhenotypes => Tuple([randn(n) for n in nphenotypes]),\n  :covMat => Tuple([LinearAlgebra.diagm(fill(1.0, max(i[1], i[2]))) for i in zip(nphenotypes, nphenotypes)]),\n  :mutProbs => Tuple([(0.02, 0.0, 0.0) for i in 1:nspecies]),\n  :mutMagnitudes => Tuple([(0.01, 0.0, 0.01) for i in 1:nspecies]),\n  :N => Dict(i => fill(100, nspecies) for i in 1:nspecies),\n  :K => Dict(i => fill(1000, nspecies) for i in 1:nspecies),\n  :migration_rates => [mig for i in 1:nspecies],\n  :E => Tuple(0.001 for i in 1:nspecies),\n  :generations => 5,\n  :space => (5,2),\n);\n\nfunction nspecies_per_node(model)\n  output = zeros(model.properties[:nspecies], nv(model))\n  for species in model.properties[:nspecies]\n    for node in 1:nv(model)\n      for ag in get_node_contents(node, model)\n        output[model.agents[ag].species, node] += 1\n      end\n    end\n  end\n  return Tuple(output)\nend\n\nagentdata, modeldata, model = runmodel(parameters, mdata=[nspecies_per_node]);\nmodeldata","category":"page"},{"location":"example2.html","page":"Weak modular structure","title":"Weak modular structure","text":"","category":"page"},{"location":"example2.html","page":"Weak modular structure","title":"Weak modular structure","text":"This page was generated using Literate.jl.","category":"page"},{"location":"example1.html","page":"Simplest model","title":"Simplest model","text":"EditURL = \"<unknown>/examples/example1.jl\"","category":"page"},{"location":"example1.html#Simplest-model","page":"Simplest model","title":"Simplest model","text":"","category":"section"},{"location":"example1.html","page":"Simplest model","title":"Simplest model","text":"We can create and run simple Wright-Fisher simulations with EvoDynamics.jl. To that end, we define a single haploid species, in single region, with a single gene affecting a single phenotype. The values of parameters below are set arbitrarily.","category":"page"},{"location":"example1.html","page":"Simplest model","title":"Simplest model","text":"using EvoDynamics\n\nparameters = Dict(\n  :ngenes => (1),\n  :nphenotypes => (1),\n  :growthrates => (0.7),\n  :interactionCoeffs => nothing,\n  :pleiotropyMat => [[true]],\n  :epistasisMat =>  [[1.0]],\n  :expressionArrays => [[1.0]],\n  :selectionCoeffs => (0.5),\n  :ploidy => (1),\n  :optPhenotypes => [[2.4]],\n  :covMat => [[0.8]],\n  :mutProbs => [(0.1, 0.0, 0.0)],\n  :mutMagnitudes => [(0.05, 0.0, 0.01)],\n  :N => Dict(1 => (100)),\n  :K => Dict(1 => [1000]),\n  :migration_rates => (nothing,),\n  :E => (0.01),\n  :generations => 10,\n  :space => nothing\n)\n\n_, modeldata, model = runmodel(parameters)","category":"page"},{"location":"example1.html","page":"Simplest model","title":"Simplest model","text":"","category":"page"},{"location":"example1.html","page":"Simplest model","title":"Simplest model","text":"This page was generated using Literate.jl.","category":"page"},{"location":"host-parasite.html","page":"Host-parasite dynamics","title":"Host-parasite dynamics","text":"EditURL = \"<unknown>/examples/host-parasite.jl\"","category":"page"},{"location":"host-parasite.html#Host-parasite-and-predator-prey-models","page":"Host-parasite dynamics","title":"Host-parasite and predator-prey models","text":"","category":"section"},{"location":"host-parasite.html","page":"Host-parasite dynamics","title":"Host-parasite dynamics","text":"There are two species interaction equations we can use the Lotka-Voltera competition equation and the generalized Lotka-Voltera equation. The competition equation can model any kind of species interactions except when one species depends on other species to grow, that is, without the other species it has a negative growth rate (e.g. in predator-prey and host-parasite). The generalized equation can model predator-prey and host-parasite dynamics, but it is not suitable for mutualistic dynamics where two species help each other (they may grow indefinitely).","category":"page"},{"location":"host-parasite.html","page":"Host-parasite dynamics","title":"Host-parasite dynamics","text":"Here we model a host-parasite dynamic. The important parameters are interactionCoeffs, interaction_equation, and growthrates. The first species is the parasite that has an intrinsite negative growth rate (-0.1) and completely depends on its host for growth ($ \\textrm{interactionCoeffs}_{12} = 0.5 $). The host has a positive intrinsic growth rate (0.1) and it reduces in the presence of parasite.","category":"page"},{"location":"host-parasite.html","page":"Host-parasite dynamics","title":"Host-parasite dynamics","text":"using EvoDynamics\nusing Agents\nusing Plots\n\nparameters = Dict(\n  :ngenes => (2, 2),\n  :nphenotypes => (2, 2),\n  :growthrates => (-0.1, 0.1),\n  :interactionCoeffs => [0 0.5; -0.2 0],\n  :interaction_equation => \"lotkaVoltera_generalized\",\n  :pleiotropyMat => ([true false; false true], [true false; false true]),\n  :epistasisMat =>  ([1 0; 0 1], [1 0; 0 1]),\n  :expressionArrays => ([1, 1], [1, 1]),\n  :selectionCoeffs => (0.5, 0.5),\n  :ploidy => (1, 2),\n  :optPhenotypes => ([2.5, 3], [3.1 2]),\n  :covMat => (rand(2, 2), rand(2, 2)),\n  :mutProbs => ((0.001, 0.0, 0.0), (0.001, 0.0, 0.0)),\n  :mutMagnitudes =>((0.005, 0.0, 0.01), (0.005, 0.0, 0.01)),\n  :N => Dict(1 => (100, 100)),\n  :K => Dict(1 => (1000, 1000)),\n  :migration_rates => [nothing, nothing],\n  :E => (0.01, 0.01),\n  :generations => 20,\n  :space => nothing\n)\n\nfunction nspecies_per_node(model)\n  output = zeros(model.properties[:nspecies], nv(model))\n  for species in model.properties[:nspecies]\n    for node in 1:nv(model)\n      for ag in EvoDynamics.get_node_contents(node, model)\n        output[model.agents[ag].species, node] += 1\n      end\n    end\n  end\n  return Tuple(output)\nend\n\n_, modeldata, model = runmodel(parameters, mdata=[nspecies_per_node]);\n\nplot(1:101, modeldata[!, 2], label=\"Parasite\")\nplot!(1:101, modeldata[!, 3], label=\"Host\")","category":"page"},{"location":"host-parasite.html","page":"Host-parasite dynamics","title":"Host-parasite dynamics","text":"","category":"page"},{"location":"host-parasite.html","page":"Host-parasite dynamics","title":"Host-parasite dynamics","text":"This page was generated using Literate.jl.","category":"page"},{"location":"index.html#EvoDynamics.jl-Documentation","page":"Introduction","title":"EvoDynamics.jl Documentation","text":"","category":"section"},{"location":"index.html","page":"Introduction","title":"Introduction","text":"EvoDynamics.jl tries to bridge the gap in studying biological systems at small and large scales. Some studies only focus on single genes affecting single phenotypes, some studies only analyze gene interactions, some focus on populations, and some on species interactions. EvoDynamics.jl is a framework to study the effect of interactions between all these levels. It includes explicit pleiotropy, epistasis, selection acting on multiple phenotypes, different phenotypes affecting fitness at different amounts, arbitrary spatial structure, migration, and interacting species.","category":"page"},{"location":"index.html","page":"Introduction","title":"Introduction","text":"Figure below shows different biological levels controlled by the model.","category":"page"},{"location":"index.html","page":"Introduction","title":"Introduction","text":"(Image: Fig. 1. __Model structure.__)","category":"page"},{"location":"index.html","page":"Introduction","title":"Introduction","text":"We used the paper below as a starting point for this project. But EvoDynamics.jl goes way beyond that system by including multi-species interactions, spatial structure, and explicitly implementing epistasis and gene expression.","category":"page"},{"location":"index.html","page":"Introduction","title":"Introduction","text":"Melo, D., & Marroig, G. (2015). Directional selection can drive the evolution of modularity in complex traits. Proceedings of the National Academy of Sciences, 112(2), 470–475. https://doi.org/10.1073/pnas.1322632112","category":"page"},{"location":"index.html","page":"Introduction","title":"Introduction","text":"See Tutorial for running the model, and API for a description of model parameters and simulation outline.","category":"page"},{"location":"tutorial.html#Tutorial","page":"Tutorial","title":"Tutorial","text":"","category":"section"},{"location":"tutorial.html#EvoDynamics.jl's-basic-usage","page":"Tutorial","title":"EvoDynamics.jl's basic usage","text":"","category":"section"},{"location":"tutorial.html","page":"Tutorial","title":"Tutorial","text":"First, define your model parameters. Below is a set of random parameters. See API for a description of each parameter.","category":"page"},{"location":"tutorial.html","page":"Tutorial","title":"Tutorial","text":"using Random\nimport LinearAlgebra: Symmetric\n\nnphenotypes = (4, 5)\nngenes = (7, 8)\nploidy = (2, 1)\n# choose random values for epistasis matrix epistasisMat, but make sure the diagonal is \n# 1.0, meaning that each locus affects itself 100%.\nepistasisMat = Tuple([Random.rand(-0.5:0.01:0.5, i, i) for i in (ngenes .* ploidy)])\nfor index in 1:length(epistasisMat)\n  for diag in 1:size(epistasisMat[index], 1)\n    epistasisMat[index][diag, diag] = 1\n  end\nend\n\nparameters = Dict(\n  :ngenes => ngenes .* ploidy,\n  :nphenotypes => nphenotypes,\n  :growthrates => (0.8, 0.12),\n  :interactionCoeffs => rand(-0.1:0.01:0.1, 2, 2),\n  :pleiotropyMat => (rand([true, false], nphenotypes[1], ngenes[1] * ploidy[1]), rand([true, false], nphenotypes[2], ngenes[2] * ploidy[2])),\n  :epistasisMat =>  epistasisMat,\n  :expressionArrays => Tuple([rand() for el in 1:l] for l in ngenes .* ploidy),\n  :selectionCoeffs => (0.5, 0.5),\n  :ploidy => ploidy,\n  :optPhenotypes => Tuple([randn(Float16, n) for n in nphenotypes]),\n  :covMat => Tuple([Symmetric(rand(Float16, i[1], i[2])) for i in zip(nphenotypes, nphenotypes)]),\n  :mutProbs => Tuple([(0.02, 0.0, 0.0), (0.02, 0.0, 0.0)]),\n  :mutMagnitudes => Tuple([(0.05, 0.0, 0.01), (0.05, 0.0, 0.01)]),\n  :N => Dict(1 => (1000, 1000)),\n  :K => Dict(1 => [1000, 1000], 2 => [1000, 1000], 3 => [1000, 1000], 4 => [1000, 1000]),\n  :migration_rates => [[1.0 0.02 0.02 0.02; 0.03 1.0 0.03 0.03; 0.01 0.01 1.0 0.01; 0.01 0.01 0.01 1.0] for i in 1:2],\n  :E => (0.01, 0.01),\n  :generations => 5,\n  :space => (2,2),\n  :moore => false\n)","category":"page"},{"location":"tutorial.html","page":"Tutorial","title":"Tutorial","text":"We can the use the runmodel function to create a model from these parameters and run the simulation.","category":"page"},{"location":"tutorial.html","page":"Tutorial","title":"Tutorial","text":"runmodel","category":"page"},{"location":"tutorial.html#EvoDynamics.runmodel","page":"Tutorial","title":"EvoDynamics.runmodel","text":"runmodel(parameters::Dict; kwargs)\n\nCreates and runs a model given parameters. Returns a DataFrame of collected data, which are specified by kwargs.\n\nKeywords\n\nadata=[] agent data to be collected. Either agent fields or functions that accept an agent as input can be put in the array. To aggregate collected data, provide tuples inside the array. For example, to collect mean and median fitness of individuals which is in field W, your array will be [(:W,mean), (:W,median)].\nmdata=[meanfitnessper_species] model data to be collected. By default, collects mean population fitness per species. Each row of the output DataFrame corresponds to all agents and each column is the value function applied to a field. The functions in the array are applied to the model object.\nwhen::AbstractArray{Int}=1:parameters[:generations] The generations from which data are collected\nreplicates::Int = 0 Number of replicates per simulation.\nparallel::Bool = false Whether to run replicates in parallel. If true, you should add processors to your julia session (e.g. by addprocs(n)) and define your parameters and EvoDynamics on all workers. To do that, add @everywhere before them. For example, @everywhere EvoDynamics.\n\n\n\n\n\n","category":"function"},{"location":"tutorial.html","page":"Tutorial","title":"Tutorial","text":"using EvoDynamics\ndata, model = runmodel(parameters)\ndata[1:5, :]","category":"page"}]
}
