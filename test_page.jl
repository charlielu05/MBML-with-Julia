using ForneyLab;
using Plots, LaTeXStrings, SpecialFunctions; theme(:default);

N = 25          # number of coin tosses
p = 0.75        # p parameter of the Bernoulli distribution
sbernoulli(n, p) = [(rand() < p) ? 1 : 0 for _ = 1:n] # define Bernoulli sampler
dataset = sbernoulli(N, p); # run N Bernoulli trials
print("dataset = ") ; show(dataset)

g = FactorGraph()
a = placeholder(:a)
b = placeholder(:b)
@RV θ ~ Beta(a,b)
@RV y ~ Bernoulli(θ)
placeholder(y, :y)
draw(g)

# Generate a message passging sum-product algorithm that infers theta
algo = messagePassingAlgorithm(θ) # derive a sum-product algorithm to infer θ
algo_code = algorithmSourceCode(algo) # convert the algorithm to Julia code
algo_expr = Meta.parse(algo_code) # parse the algorithm into a Julia expression
eval(algo_expr) # evaluate the functions contained in the Julia expression

# Create a marginals dictionary, and initialize hyperparameters
a = 2.0
b = 7.0
marginals = Dict(:θ => ProbabilityDistribution(Beta, a=a, b=b))

for i in 1:N
    # Feed in datapoints 1 at a time
    data = Dict(:y => dataset[i],
                :a => marginals[:θ].params[:a],
                :b => marginals[:θ].params[:b])

    step!(data, marginals)
end

plot(fillalpha=0.3, fillrange = 0, leg=false, xlabel=L"\theta", yticks=nothing)
BetaPDF(α, β) = x ->  x^(α-1)*(1-x)^(β-1)/beta(α, β) # beta distribution definition
BernoulliPDF(z, N) = θ -> θ^z*(1-θ)^(N-z) # Bernoulli distribution definition

rθ = range(0, 1, length=100)
p1 = plot(rθ, BetaPDF(a, b), title="Prior", fillalpha=0.3, fillrange = 0, ylabel=L"P(\theta)", c=1,)
p2 = plot(rθ, BernoulliPDF(sum(dataset), N), title="Likelihood", fillalpha=0.3, fillrange = 0, ylabel=L"P(D|\theta)", c=2)
p3 = plot(rθ, BetaPDF(marginals[:θ].params[:a], marginals[:θ].params[:b]), title="Posterior", fillalpha=0.3, fillrange = 0, ylabel=L"P(\theta|D)", c=3)
plot(p1, p2, p3, layout=@layout([a; b; c]))