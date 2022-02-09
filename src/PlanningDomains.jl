module PlanningDomains

export load_domain, load_problem
export JuliaPlannersRepo, IPCInstancesRepo

import PDDL.Parser: load_domain, load_problem, parse_domain, parse_problem
import Downloads

## Generic types and methods ##

"Abstract type for planning domain and problem repositories."
abstract type PlanningRepository end

load_domain(::Type{T}, args...) where {T <: PlanningRepository} =
    load_domain(T(), args...)
load_problem(::Type{T}, args...) where {T <: PlanningRepository} =
    load_problem(T(), args...)

load_domain(repo::PlanningRepository, name::Symbol) =
    load_domain(repo, replace(string(name), '_' => '-'))
load_problem(repo::PlanningRepository, domain::Symbol, problem) =
    load_problem(repo, replace(string(domain), '_' => '-'), problem)

## Code for JuliaPlanners repository ##

"Repository provided by the JuliaPlanners organization."
struct JuliaPlannersRepo <: PlanningRepository end

const JULIA_PLANNERS_DIR =
    joinpath(pkgdir(@__MODULE__), "repositories", "julia-planners")

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

## Code for IPC Instances repository ##

"Repository of International Planning Competition domains and problems."
struct IPCInstancesRepo <: PlanningRepository end

const IPC_INSTANCES_DIR =
    joinpath(pkgdir(@__MODULE__), "repositories", "ipc-instances")

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
    local_path = joinpath(IPC_INSTANCES_DIR, ipc, domain, "domain.pddl")
    if !isfile(local_path) # Download file if not already cached
        tmp_path, tmp_io = mktemp()
        @info "Downloading $remote_path to local cache..."
        Downloads.download(remote_path, tmp_io, timeout=5.0)
        close(tmp_io)
        mkpath(dirname(local_path))
        mv(tmp_path, local_path, force=true)
    end
    return load_domain(local_path)
end

function load_problem(repo::IPCInstancesRepo, ipc::AbstractString,
                      domain::AbstractString, problem::AbstractString)
    remote_path = IPC_INSTANCES_URL * "/$ipc/domains/$domain/instances/$problem.pddl"
    local_path = joinpath(IPC_INSTANCES_DIR, ipc, domain, "$problem.pddl")
    if !isfile(local_path) # Download file if not already cached
        tmp_path, tmp_io = mktemp()
        @info "Downloading $remote_path to local cache..."
        Downloads.download(remote_path, tmp_io, timeout=5.0)
        close(tmp_io)
        mkpath(dirname(local_path))
        mv(tmp_path, local_path, force=true)
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

## Default implementations ##

load_domain(domain::Symbol) =
    load_domain(JuliaPlannersRepo(), domain)
load_problem(domain::Symbol, problem) =
    load_problem(JuliaPlannersRepo(), domain, problem)

end
