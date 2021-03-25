# Attempt at solving the first chapter in MBML (https://www.mbmlbook.com/MurderMystery.html)
# using Julia
# referenced https://github.com/biaslab/ForneyLab.jl/blob/master/demo/bayes_rule_discrete.ipynb

using ForneyLab;
using Plots, LaTeXStrings, SpecialFunctions; theme(:default);

# Two suspects, Grey and Auburn
# Two weapons, Revolve or Dagger

g = FactorGraph()

# prior probability for murderer [auburn, grey]
@RV prior ~ Clamp([.7, .3])

# mocking the CPT for p(w|m)
@RV cpt_weapon ~ Clamp([0.2 0.9; 0.8 0.1])
@RV cpt_hair ~ Clamp([0.2 0.9; 0.8 0.1])

# murderer
@RV m ~ Categorical(prior)
# weapon
@RV w ~ Transition(m, cpt_weapon)
# hair
@RV h ~ Transition(m, cpt_hair)

placeholder(h, :h, dims=(2,))
placeholder(w, :w, dims=(2,))

# uncomment below to display graph, requres graphviz
draw(g)

# generate the algorithm to find the marginal of m: murderer
algo = messagePassingAlgorithm(m)
source_code = algorithmSourceCode(algo)
eval(Meta.parse(source_code)) # Parse and load the algorithm in scope

# execute algorithm 
# simulating observation of w=revolver AND h=True
data = Dict(:w => [1, 0],
            :h => [1, 0])

# obtain the marginal distribution for murderer given observations
marginals = step!(data)


