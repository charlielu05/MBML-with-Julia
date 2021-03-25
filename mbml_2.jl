# Chapter 2 of MBML [https://www.mbmlbook.com/LearningSkills_A_model_is_a_set_of_assumptions.html]

using ForneyLab

# 3 questions to test SQL and Csharp skills
# 1st question is to test Csharp
# 2nd question is to test SQL
# 3rd question is to test Cshapr and SQL

g = FactorGraph()

# Can't just use a Bernoulli to model the prior, see (https://github.com/biaslab/ForneyLab.jl/issues/152)
# we need to use a categorical since we have a transition matrix node

@RV prior_csharp ~ Clamp([0.5, 0.5])
@RV prior_sql ~ Clamp([0.5, 0.5]) 

# Csharp

@RV c ~ Categorical(prior_csharp)

# SQL
@RV s ~ Categorical(prior_sql)

# even if candidate has the skill, there is a chance he would get it wrong
# build a CPT with the result from question as input
@RV cpt_csharp ~ Clamp([0.9 0.2;0.1 0.8 ])
@RV correct_csharp ~ Transition(c, cpt_csharp)

# CPT for SQL skills
# p(correct|skill)
@RV cpt_sql ~ Clamp([0.9 0.2; 0.1 0.8])
@RV sql_skills ~ Transition(s, cpt_sql) 

placeholder(correct_csharp, :correct_csharp, dims=(2,))
placeholder(sql_skills, :sql_skills, dims=(2,))

#draw(g)

# generate algorithm using ForneyLab for csharp skills
algo = messagePassingAlgorithm(c)
source_code = algorithmSourceCode(algo)
eval(Meta.parse(source_code))

# execute algorithm
# simulating observation of answering csharp correct and sql incorrect
data = Dict(:correct_csharp => [1, 0],
            :sql_skills => [1, 0])

# obtain the marginal for csharp skills
marginals = step!(data)