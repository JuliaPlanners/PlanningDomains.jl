module PlanningDomains

export load_domain, load_problem
export list_domains, list_problems
export find_domains, find_problems
export JuliaPlannersRepo, IPCInstancesRepo, PlanningDomainsRepo

import PDDL.Parser: load_domain, load_problem, parse_domain, parse_problem
import Scratch: get_scratch!, delete_scratch!
import Downloads, HTTP, JSON

## Generic types and methods ##

"Abstract type for planning domain and problem repositories."
abstract type PlanningRepository end

const REPOS_DOCSTRING = """
The following repositores are currently supported:

- [`JuliaPlannersRepo`](@ref): Repository maintained by the JuliaPlanners organization
- [`IPCInstancesRepo`](@ref): International Planning Competition domains and problems
- [`PlanningDomainsRepo`](@ref): Repository provided by http://planning.domains/

View the documentation of each repository for more information.
"""

"""
    load_domain(repository, domain)
    load_domain(repository, collection, domain)

Load a domain from a planning `repository`. In some repositories, domains
are also organized into `collection`s.

$REPOS_DOCSTRING
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
into `collection`s.

$REPOS_DOCSTRING
"""
load_problem(::Type{T}, args...) where {T <: PlanningRepository} =
    load_problem(T(), args...)
load_problem(repo::PlanningRepository, domain::Symbol, problem) =
    load_problem(repo, replace(string(domain), '_' => '-'), problem)

"""
    list_domains(repository)
    list_domains(repository, collection)

List domains in a planning `repository`. In some repositories, domains
are also organized into `collection`s.

$REPOS_DOCSTRING
"""
list_domains(::Type{T}, args...) where {T <: PlanningRepository} =
    list_domains(T(), args...)

"""
    list_problems(repository, domain)
    list_problems(repository, collection, domain)

List problems from a planning `repository` for a given `domain`. In some
repositories, domains are also organized into `collection`s.

$REPOS_DOCSTRING
"""
list_problems(::Type{T}, arg, args...) where {T <: PlanningRepository} =
    list_problems(T(), arg, args...)
list_problems(::Type{T}, arg::Symbol, args...) where {T <: PlanningRepository} =
    list_problems(T(), replace(string(arg), '_' => '-'), args...)

"""
    find_collections(repository, query)

Find collections from a planning `repository` that match a `query`, which can
be provided as a regular expression or (sub)string.
"""
function find_collections(repo::PlanningRepository, args...)
    @assert !isempty(args) "Query needs to be specified."
    args, query = args[1:end-1], args[end]
    return filter!(s -> occursin(query, s), list_collections(repo, args...))
end
find_collections(::Type{T}, args...) where {T <: PlanningRepository} =
    find_collections(T(), args...)

"""
    find_domains(repository, query)
    find_domains(repository, collection, query)

Find domains from a planning `repository` that match a `query`, which can be
provided as a regular expression or (sub)string.
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

Find problems from a planning `repository` in a given `domain` that match
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
include("planning_domains_repo.jl")

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
