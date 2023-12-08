## Code for IPC Instances repository ##

"""
    IPCInstancesRepo

Repository of International Planning Competition (IPC) domains and problems,
hosted at https://github.com/potassco/pddl-instances.

- Collections: Formatted as "ipc-YYYY", where YYYY is a IPC year.
- Domains: Specified as a string (e.g. "blocks-strips-typed"). When the
    collection is not provided as an argument, it should be prepended to the
    domain name with a dash (e.g. "ipc-2000-blocks-strips-typed").
- Problems: Formatted as "instance-i", generally organized by increasing difficulty.
"""
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

function list_collections(repo::IPCInstancesRepo)
    years = [1998, 2000, 2002, 2004, 2006, 2008, 2011, 2014]
    return ["ipc-$y" for y in years]
end

function list_domains(repo::IPCInstancesRepo)
    domains = reduce(vcat, (c * "-" .* list_domains(repo, c)
                            for c in list_collections(repo)))
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
