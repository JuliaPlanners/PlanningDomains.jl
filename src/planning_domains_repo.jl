## Code for planning.domains repository ##

"Repository of domains and problems provided by http://planning.domains/."
struct PlanningDomainsRepo <: PlanningRepository end

const PLANNING_DOMAINS_API_URL =
    "https://api.planning.domains/json/classical"

function list_collections(repo::PlanningDomainsRepo)
    endpoint = "$PLANNING_DOMAINS_API_URL/collections"
    cache_path = joinpath(get_cache!(repo), "collections.json")
    resp = cached_json_query(endpoint, cache_path)
    collections = map(resp["result"]) do data
        "$(data["collection_id"])-$(data["collection_name"])"
    end
    return collections
end

function resolve_collection(repo::PlanningDomainsRepo,
                            query::Union{Regex,AbstractString})
    collections = find_collections(repo, query)
    if length(collections) > 1
        error("More than one collection matching $query found.")
    end
    idx = parse(Int, match(r"(\d+)-.*", first(collections))[1])
    return idx
end
resolve_collection(repo::PlanningDomainsRepo, idx::Int) = idx

function list_domains(repo::PlanningDomainsRepo)
    endpoint = "$PLANNING_DOMAINS_API_URL/domains"
    cache_path = joinpath(get_cache!(repo), "all-domains.json")
    resp = cached_json_query(endpoint, cache_path)
    domains = map(resp["result"]) do data
        "$(data["domain_id"])-$(data["domain_name"])"
    end
    return domains
end

function list_domains(repo::PlanningDomainsRepo,
                      collection::Union{Int,Regex,AbstractString})
    idx = resolve_collection(repo, collection)
    endpoint = "$PLANNING_DOMAINS_API_URL/domains/$idx"
    cache_path = joinpath(get_cache!(repo), "collection-$idx-domains.json")
    resp = cached_json_query(endpoint, cache_path)
    domains = map(resp["result"]) do data
        "$(data["domain_id"])-$(data["domain_name"])"
    end
    return domains
end

function resolve_domain(repo::PlanningDomainsRepo,
                        query::Union{Regex,AbstractString})
    domains = find_domains(repo, query)
    if length(domains) > 1
        error("More than one domain matching $query found.")
    elseif isempty(domains)
        error("No domains matching $query found.")
    end
    idx = parse(Int, match(r"(\d+)-.*", first(domains))[1])
    return idx
end
resolve_domain(repo::PlanningDomainsRepo, idx::Int) = idx

function resolve_domain(repo::PlanningDomainsRepo,
                        collection::Union{Int,Regex,AbstractString},
                        query::Union{Regex,AbstractString})
    domains = find_domains(repo, collection, query)
    if length(domains) > 1
        error("More than one domain matching $query found.")
    elseif isempty(domains)
        error("No domains in $collection matching $query found.")
    end
    idx = parse(Int, match(r"(\d+)-.*", first(domains))[1])
    return idx
end
resolve_domain(repo::PlanningDomainsRepo, collection, idx::Int) = idx

function list_problems(repo::PlanningDomainsRepo,
                       domain::Union{Int,Regex,AbstractString})
    idx = resolve_domain(repo, domain)
    endpoint = "$PLANNING_DOMAINS_API_URL/problems/$idx"
    cache_path = joinpath(get_cache!(repo), "domain-$idx-problems.json")
    resp = cached_json_query(endpoint, cache_path)
    problems = map(resp["result"]) do data
        "$(data["problem_id"])-$(data["problem"])"
    end
    return problems
end

function list_problems(repo::PlanningDomainsRepo,
                       collection::Union{Int,Regex,AbstractString},
                       domain::Union{Int,Regex,AbstractString})
    idx = resolve_domain(repo, collection, domain)
    return list_problems(repo, idx)
end

function resolve_problem(repo::PlanningDomainsRepo,
                         domain::Union{Int,Regex,AbstractString},
                         query::Union{Regex,AbstractString})
    problems = find_problems(repo, domain, query)
    if length(problems) > 1
        error("More than one problem matching $query found.")
    elseif isempty(problems)
        error("No problems in $domain matching $query found.")
    end
    idx = parse(Int, match(r"(\d+)-.*", first(problems))[1])
    return idx
end
resolve_problem(repo::PlanningDomainsRepo, domain, idx::Int) = idx

function resolve_problem(repo::PlanningDomainsRepo,
                         collection::Union{Int,Regex,AbstractString},
                         domain::Union{Int,Regex,AbstractString},
                         query::Union{Regex,AbstractString})
    problems = find_problems(repo, collection, domain, query)
    if length(problems) > 1
        error("More than one problem matching $query found.")
    elseif isempty(problems)
        error("No problems in $domain matching $query found.")
    end
    idx = parse(Int, match(r"(\d+)-.*", first(problems))[1])
    return idx
end
resolve_problem(repo::PlanningDomainsRepo, collection, domain, idx::Int) = idx

function load_domain(repo::PlanningDomainsRepo,
                     domain::Union{Int,Regex,AbstractString})
    idx = resolve_domain(repo, domain)
    # Query URL to domain file
    endpoint = "$PLANNING_DOMAINS_API_URL/problems/$idx"
    cache_path = joinpath(get_cache!(repo), "domain-$idx-problems.json")
    resp = cached_json_query(endpoint, cache_path)
    problem_info = first(resp["result"])
    remote_path = problem_info["domain_url"]
    local_path = joinpath(get_cache!(repo), problem_info["domain_path"])
    # Download file if not already cached locally
    if !isfile(local_path)
        timed_download(remote_path, local_path, 5.0)
    end
    return load_domain(local_path)
end

function load_domain(repo::PlanningDomainsRepo,
                     collection::Union{Int,Regex,AbstractString},
                     domain::Union{Int,Regex,AbstractString})
    idx = resolve_domain(repo, collection, domain)
    return load_domain(repo, idx)
end

function load_problem(repo::PlanningDomainsRepo,
                      domain::Union{Int,Regex,AbstractString},
                      problem::Union{Int,Regex,AbstractString})
    idx = resolve_problem(repo, domain, problem)
    endpoint = "$PLANNING_DOMAINS_API_URL/problem/$idx"
    cache_path = joinpath(get_cache!(repo), "problem-$idx.json")
    problem_info = cached_json_query(endpoint, cache_path)["result"]
    remote_path = problem_info["problem_url"]
    local_path = joinpath(get_cache!(repo), problem_info["problem_path"])
    if !isfile(local_path) # Download file if not already cached
        timed_download(remote_path, local_path, 5.0)
    end
    return load_problem(local_path)
end

function load_problem(repo::PlanningDomainsRepo,
                      collection::Union{Int,Regex,AbstractString},
                      domain::Union{Int,Regex,AbstractString},
                      problem::Union{Int,Regex,AbstractString})
    idx = resolve_problem(repo, collection, domain, problem)
    return load_problem(repo, domain, idx)
end
