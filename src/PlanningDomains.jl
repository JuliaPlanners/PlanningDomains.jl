module PlanningDomains

export load_domain, load_problem

import PDDL.Parser: load_domain, load_problem, parse_domain, parse_problem

"Abstract type for planning domain and problem repositories."
abstract type PlanningRepository end

load_domain(repo::PlanningRepository, name::Symbol) =
    load_domain(repo, replace(string(name), '_' => '-'))
load_problem(repo::PlanningRepository, domain::Symbol, problem) =
    load_problem(repo, replace(string(domain), '_' => '-'), problem)

## Code for JuliaPlanners repository ##

"Repository provided by the JuliaPlanners organization."
struct JuliaPlannersRepo <: PlanningRepository end

function load_domain(repo::JuliaPlannersRepo, name::AbstractString)
    domain_dir = joinpath(dirname(pathof(@__MODULE__)), "../domains", name)
    return load_domain(joinpath(domain_dir, "domain.pddl"))
end

function load_problem(repo::JuliaPlannersRepo,
                      domain::AbstractString, problem::AbstractString)
    domain_dir = joinpath(dirname(pathof(@__MODULE__)), "../domains", domain)
    return load_problem(joinpath(domain_dir, "$problem.pddl"))
end

function load_problem(repo::JuliaPlannersRepo, domain::AbstractString, idx::Int)
    return load_problem(repo, domain, "problem-$idx")
end

## Generic and default implementations ##

load_domain(name::Symbol) =
    load_domain(JuliaPlannersRepo(), name)
load_problem(domain::Symbol, problem) =
    load_problem(JuliaPlannersRepo(), domain, problem)

end
