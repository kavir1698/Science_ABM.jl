# Model description

## Model outline

![](docs/figures/simulation.png?raw=true)

There are $n$ agents / scientists. Each agent chooses a problem with a success probability $s$. The more probable the success of a project, the less information it will yield. Negative results may / may not be rewarded. If an agent is not rewarded in $y$ consecutive years, he loses his career. Find the total information of the system with different parameter sets.

Parameters to think about including in the model: probability of finding a significantly positive result, probability that the finding is real, probability of acceptance of papers, false discovery rate, h-index of scientists.	

The total fitness of the researcher is assumed to depend on total number of publications with diminishing returns, with an additional bonus for big impact discoveries.

Agents can learn from the lab they start their project to incline towards playing safe or taking risks in choosing a research project. This is equivalent of inheritance in biological systems. They can also learn from past experience and change their strategy (equivalent of mutation). The reward system is the equivalent of selection.

It may be more efficient to define a genetic algorithm to find the best set of parameters to maximize the advancement of science and minimize costs.

### Parameters of the model

* population\_size: number of researchers to start the simulation with. These researchers may be just starting their career or experienced.
* max\_grants: maximum number of grants that can be distributed every year.
* max\_years: maximum number of years a researcher can be granted.
* years: number of years that the simulation will run.
* risk\_taking\_average: the risk taking characteristic of the initial population.
* generality\_average: tendency of the initial population to choose general problems (those that take longer to finish)
* K: importance of longer projects. If K=0, projects that take longer have no advantage to projects that finish in one year. If K > 1, longer projects mean they are more general (possibly interdisciplinary) and increase knowledge more than shorter projects.
* min\_prof\_exp: minimum years of experience before a researcher can train students (become professor). 
* average\_students: average number of students that professors will have every year, taken from a Poisson distribution. 
* max\_exp: Number of years a researcher can be in academia, after which it will retire.
* mutation_rate (Default=1): the probability that a student will be different his/her professor in being bold. 
* risk\_range: the range around the boldness of a professor from which a student will randomly choose a boldness value.
* A, B, and C: parameters that control the reward and punishment system. Every time step, grants are distributed according to researchers' scores. Also, when there are more researchers than there are grants, those with lowest scores are removed. A score is calculated as follows:  
  score = (number of publications * A / experience) + (all received citations * B / experience) + (total produced knowledge * C / experience)


### Structure of the model

#### Researcher

  Each researcher has a risk-taking (boldness) characteristic with a minimum and a maximum risk (in range 0-1) they take to choose their research projects. Every year, they gain one year of research experience. Researchers also have a tendency to choose general or specific problem by choosing problems that take longer or shorter to finish. The time to finish is an integer between 1 and max_years.

#### Research projects

  A research project has the following properties: 'success probability': the probability that the project will return positive results. Lower probability projects are more informative if successful. 'complexity': how difficult is the project. This will determine how long it takes to perform it. Currently, this is not implemented and all the projects take one year to finish. 'time to finish': how long it takes to finish a project. This is a characteristic of researchers. 'information': the amount of knowledge that a successful project will provide.

#### Evolutionary algorithm

##### Mutation

  Mutation occurs when students enter academia. Each student will receive a boldness value randomly chosen from his professors boldness +- risk\_range. Moreover, a new student will receive a random number for time to finish his projects.

##### fitness

  Grants are bestowed based on a sampling of researchers, without replacement, and weighted by their scores.

##### Selection

  When there are researchers more than the number of grants, those with lowest scores are removed.

##### Reproduction

  Professors train new researchers every year.

## Future features

1. Researchers will be allowed to publish negative results and get credit for it.
1. Allow collaboration
1. Compare with empirical data
1. Random scores - Null model