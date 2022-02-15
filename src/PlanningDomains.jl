module PlanningDomains

export load_domain, load_problem
export list_domains, list_problems
export find_domains, find_problems
export JuliaPlannersRepo, IPCInstancesRepo

import PDDL.Parser: load_domain, load_problem, parse_domain, parse_problem
import Scratch: get_scratch!, delete_scratch!
import Downloads

## Generic types and methods ##

"Abstract type for planning domain and problem repositories."
abstract type PlanningRepository end

"""
    load_domain(repository, domain)
    load_domain(repository, collection, domain)

Load a domain from a planning `repository`. In some repositories, domains
are also organized into `collection`s. The following repositores are
currently supported:

- `JuliaPlannersRepo`: no collections
- `IPCInstancesRepo`: collection format: "ipc-YYYY"
"""
load_domain(::Type{T}, args...) where {T <: PlanningRepository} =
    load_domain(T(), args...)
load_domain(repo::PlanningRepository, domain::Symbol) =
    load_domain(repo, replace(string(domain), '_' => '-'))

"""
    load_problem(repository, domain, problem)
    load_problem(repository, collection, domain, problem)

Load a problem (specified as a name or index) from a planning `repository`
for a given `domain`. In some repositories, domains are also organized
into `collection`s. The following repositores are currently supported:

- `JuliaPlannersRepo`: no collections, problem format "problem-N"
- `IPCInstancesRepo`: collection format "ipc-YYYY", problem format "instance-N"
"""
load_problem(::Type{T}, args...) where {T <: PlanningRepository} =
    load_problem(T(), args...)
load_problem(repo::PlanningRepository, domain::Symbol, problem) =
    load_problem(repo, replace(string(domain), '_' => '-'), problem)

"""
    list_domains(repository)
    list_domains(repository, collection)

List domains in a planning `repository`. In some repositories, domains
are also organized into `collection`s. The following repositores are
currently supported:

- `JuliaPlannersRepo`: no collections
- `IPCInstancesRepo`: collection format: "ipc-YYYY"
"""
list_domains(::Type{T}, args...) where {T <: PlanningRepository} =
    list_domains(T(), args...)

"""
    list_problems(repository, domain)
    list_problems(repository, collection, domain)

List problems from a planning `repository` for a given `domain`. In some
repositories, domains are also organized into `collection`s. The following
repositores are currently supported:

- `JuliaPlannersRepo`: no collections
- `IPCInstancesRepo`: collection format "ipc-YYYY"
"""
list_problems(::Type{T}, arg, args...) where {T <: PlanningRepository} =
    list_problems(T(), arg, args...)
list_problems(::Type{T}, arg::Symbol, args...) where {T <: PlanningRepository} =
    list_problems(T(), replace(string(arg), '_' => '-'), args...)

"""
    find_domains(repository, query)
    find_domains(repository, collection, query)

Find domains from a planning `repository` for a given `domain` that matches
a `query`, which can be provided as a regular expression or (sub)string.
"""
function find_domains(repo::PlanningRepository, args...)
    @assert !isempty(args) "Query needs to be specified."
    args, query = args[1:end-1], args[end]
    return filter!(s -> occursin(query, s), list_domains(repo, args...))
end
find_domains(::Type{T}, args...) where {T <: PlanningRepository} =
    find_domains(T(), args...)

"""
    find_problems(repository, domain, query)
    find_problems(repository, collection, domain, query)

Find problems from a planning `repository` for a given `domain` that matches
a `query`, which can be provided as a regular expression or (sub)string.
"""
function find_problems(repo::PlanningRepository, args...)
    @assert !isempty(args) "Query needs to be specified."
    args, query = args[1:end-1], args[end]
    return filter!(s -> occursin(query, s), list_problems(repo, args...))
end
find_problems(::Type{T}, args...) where {T <: PlanningRepository} =
    find_problems(T(), args...)

## Repository-specific implementations ##

include("cache_management.jl")
include("julia_planners_repo.jl")
include("ipc_instances_repo.jl")

## Default implementations ##

"""
    load_domain(domain::Symbol)

Load a domain from the default repository (`JuliaPlannersRepo`). Underscores '_'
in `domain` are automatically converted to dashes '-'.
"""
load_domain(domain::Symbol) =
    load_domain(JuliaPlannersRepo(), domain)

"""
    load_problem(domain::Symbol, problem)

Load a problem from the default repository (`JuliaPlannersRepo`). Underscores '_'
in `domain` are automatically converted to dashes '-'. Problems can be
specified as either a name or an index.
"""
load_problem(domain::Symbol, problem) =
    load_problem(JuliaPlannersRepo(), domain, problem)

"""
    list_domains()

List domains from the default repository (`JuliaPlannersRepo`). Underscores '_'
in `domain` are automatically converted to dashes '-'.
"""
list_domains() =
    list_domains(JuliaPlannersRepo)

"""
    list_problems(domain)

List problems from the default repository (`JuliaPlannersRepo`). Underscores '_'
in `domain` are automatically converted to dashes '-'.
"""
list_problems(domain) =
    list_problems(JuliaPlannersRepo, domain)

"""
    find_domains(query::Union{AbstractString,Regex})

Find domains from the default repository (`JuliaPlannersRepo`).
"""
find_domains(query::Union{AbstractString,Regex}) =
    find_domains(JuliaPlannersRepo, query)

"""
    find_problems(domain, query::Union{AbstractString,Regex})

Find problems from the default repository (`JuliaPlannersRepo`).
"""
find_problems(domain, query::Union{AbstractString,Regex}) =
    find_problems(JuliaPlannersRepo, domain, query)

end
