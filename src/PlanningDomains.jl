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

## Download and cache management utilities ##

const CACHE_DIRS = Dict{String,String}()

"Return or create local cache directory for a remote planning repository."
function get_cache!(repo::T) where {T <: PlanningRepository}
    return get!(CACHE_DIRS, string(T)) do
        get_scratch!(@__MODULE__, string(T))
    end
end

"Clear local cache directory associated with a remote planning repository."
function clear_cache!(repo::T) where {T <: PlanningRepository}
    delete_scratch!(@__MODULE__, string(T))
    delete!(CACHE_DIRS, string(T))
    return nothing
end

"Clear all local caches of remote planning repositories."
function clear_all_caches!()
    for repo in keys(CACHE_DIRS)
        delete_scratch!(@__MODULE__, repo)
    end
    empty!(CACHE_DIRS)
    return nothing
end

"Download `src` URL to `dst` path with a fixed timeout."
function timed_download(src, dst, timeout)
    tmp_path, tmp_io = mktemp()
    @info "Downloading $src to local cache..."
    Downloads.download(src, tmp_io, timeout=timeout)
    close(tmp_io)
    mkpath(dirname(dst))
    mv(tmp_path, dst)
end

## Code for JuliaPlanners repository ##

"Repository provided by the JuliaPlanners organization."
struct JuliaPlannersRepo <: PlanningRepository end

const JULIA_PLANNERS_DIR =
    normpath(dirname(pathof(@__MODULE__)), "..", "repositories", "julia-planners")

function load_domain(repo::JuliaPlannersRepo, domain::AbstractString)
    domain_dir = joinpath(JULIA_PLANNERS_DIR, domain)
    return load_domain(joinpath(domain_dir, "domain.pddl"))
end

function load_problem(repo::JuliaPlannersRepo,
                      domain::AbstractString, problem::AbstractString)
    domain_dir = joinpath(JULIA_PLANNERS_DIR, domain)
    return load_problem(joinpath(domain_dir, "$problem.pddl"))
end

function load_problem(repo::JuliaPlannersRepo, domain::AbstractString, idx::Int)
    return load_problem(repo, domain, "problem-$idx")
end

function list_domains(repo::JuliaPlannersRepo)
    return readdir(JULIA_PLANNERS_DIR)
end

function list_problems(repo::JuliaPlannersRepo, domain::AbstractString)
    # Filter out non-problem files
    fns = filter(readdir(joinpath(JULIA_PLANNERS_DIR, domain))) do fn
        match(r".*\.pddl", fn) !== nothing && fn != "domain.pddl"
    end
    # Strip .pddl suffix
    return map(fn -> fn[1:end-5], fns)
end

## Code for IPC Instances repository ##

"Repository of International Planning Competition domains and problems."
struct IPCInstancesRepo <: PlanningRepository end

const IPC_INSTANCES_URL =
    "https://raw.githubusercontent.com/potassco/pddl-instances/master/"

function load_domain(repo::IPCInstancesRepo, domain::AbstractString)
    m = match(r"(ipc-\d\d\d\d)-(.*)", domain)
    if m === nothing
        error("Domain name must be in the format 'ipc-YYYY-domain-name'.")
    end
    ipc, domain = m.captures
    return load_domain(repo, ipc, domain)
end

function load_domain(repo::IPCInstancesRepo,
                     ipc::AbstractString, domain::AbstractString)
    remote_path = IPC_INSTANCES_URL * "$ipc/domains/$domain/domain.pddl"
    local_path = joinpath(get_cache!(repo), ipc, domain, "domain.pddl")
    if !isfile(local_path) # Download file if not already cached
        timed_download(remote_path, local_path, 5.0)
    end
    return load_domain(local_path)
end

function load_problem(repo::IPCInstancesRepo, ipc::AbstractString,
                      domain::AbstractString, problem::AbstractString)
    remote_path = IPC_INSTANCES_URL * "/$ipc/domains/$domain/instances/$problem.pddl"
    local_path = joinpath(get_cache!(repo), ipc, domain, "$problem.pddl")
    if !isfile(local_path) # Download file if not already cached
        timed_download(remote_path, local_path, 5.0)
    end
    return load_problem(local_path)
end

function load_problem(repo::IPCInstancesRepo, ipc::AbstractString,
                      domain::AbstractString, idx::Int)
    return load_problem(repo, ipc, domain, "instance-$idx")
end

function load_problem(repo::IPCInstancesRepo,
                      domain::AbstractString, problem::AbstractString)
    m = match(r"(ipc-\d\d\d\d)-(.*)", domain)
    if m === nothing
        error("Domain name must be in the format 'ipc-YYYY-domain-name'.")
    end
    ipc, domain = m.captures
    return load_problem(repo, ipc, domain, problem)
end

function load_problem(repo::IPCInstancesRepo,
                      domain::AbstractString, idx::Int)
    return load_problem(repo, domain, "instance-$idx")
end

function list_domains(repo::IPCInstancesRepo)
    years = [1998, 2000, 2002, 2004, 2006, 2008, 2011, 2014]
    domains = reduce(vcat, ("ipc-$y-" .* list_domains(repo, "ipc-$y")
                            for y in years))
    return domains
end

function list_domains(repo::IPCInstancesRepo, ipc::AbstractString)
    m = match(r"(ipc-\d\d\d\d)", ipc)
    if m === nothing
        error("Collection name must be in the format 'ipc-YYYY'.")
    end
    remote_path = IPC_INSTANCES_URL * "$ipc/README.md"
    local_path = joinpath(get_cache!(repo), ipc, "README.md")
    if !isfile(local_path) # Download file if not already cached
        timed_download(remote_path, local_path, 5.0)
    end
    domains = String[] # Read domain names from table in README.md
    open(local_path) do io
        for line in eachline(io)
            m = match(r"\|\s*\[\w+\]\(domains/([\w-]+)\).*\|", line)
            m === nothing && continue
            push!(domains, m[1])
        end
    end
    return domains
end

function list_problems(repo::IPCInstancesRepo, domain::AbstractString)
    m = match(r"(ipc-\d\d\d\d)-(.*)", domain)
    if m === nothing
        error("Domain name must be in the format 'ipc-YYYY-domain-name'.")
    end
    ipc, domain = m.captures
    return list_problems(repo, ipc, domain)
end

function list_problems(repo::IPCInstancesRepo,
                       ipc::AbstractString, domain::AbstractString)
    m = match(r"(ipc-\d\d\d\d)", ipc)
    if m === nothing
        error("Collection name must be in the format 'ipc-YYYY'.")
    end
    remote_path = IPC_INSTANCES_URL * "$ipc/domains/$domain/README.md"
    local_path = joinpath(get_cache!(repo), ipc, domain, "README.md")
    if !isfile(local_path) # Download file if not already cached
        timed_download(remote_path, local_path, 5.0)
    end
    problems = String[] # Read problem names from table in README.md
    open(local_path) do io
        for line in eachline(io)
            m = match(r"\|\s*(instance-\d+)\.pddl.*\|", line)
            m === nothing && continue
            push!(problems, m[1])
        end
    end
    return problems
end

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
