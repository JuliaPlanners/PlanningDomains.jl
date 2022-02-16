# PlanningDomains.jl

A (meta)-repository of PDDL domains and problems. The following repositories are supported:
- `JuliaPlannersRepo`: A built-in repository maintained by the [JuliaPlanners](https://github.com/JuliaPlanners) GitHub organization. Domains and problem files can be found in [`repositories/julia-planners`](repositories/julia-planners).
- `IPCInstancesRepo`: A repository of International Planning Competition (IPC) domains and problems, hosted at https://github.com/potassco/pddl-instances.
- `PlanningDomainsRepo`: A repository of domains and problems accessible via https://api.planning.domains.

## Usage

#### Listing

To list the domains provided by a repository, run `list_domains`:

```julia
list_domains(JuliaPlannersRepo)
4-element Vector{String}:
 "blocksworld"
 "doors-keys-gems"
 "gridworld"
 "zeno-travel"
```

To list the problems in a domain, run `list_problems`:
```julia
julia> list_problems(JuliaPlannersRepo, "blocksworld")
9-element Vector{String}:
 "problem-1"
 ⋮
 "problem-9"
```

Some repositories also organize domains into collections. We can list collections via `list_collections`, and list domains in a particular collection via `list_domains`:
```julia
julia> list_collections(IPCInstancesRepo)
8-element Vector{String}:
 "ipc-1998"
 ⋮
 "ipc-2014"

julia> list_domains(IPCInstancesRepo, "ipc-2000")
12-element Vector{String}:
 "blocks-strips-typed"
 ⋮
 "schedule-adl-untyped"
```

#### Loading

To load a domain, specify the repository and domain name as arguments to `load_domain`. To load a problem, specify either the problem name or its index:
```julia
domain = load_domain(JuliaPlannersRepo, "blocksworld")
problem_1 = load_problem(JuliaPlannersRepo, "blocksworld", "problem-1")
problem_2 = load_problem(JuliaPlannersRepo, "blocksworld", 2)
```

#### Searching

Collections, domains and problems can also be searched for using
`find_collections`, `find_domains`, and `find_problems`, by providing a (sub)string or regular expression as a query:
```julia
julia> find_collections(PlanningDomainsRepo, "Fast")
2-element Vector{String}:
 "9-Fast Downward All Problem Suite"
 "10-Fast Downward LM-Cut Problem Suite"

julia> find_domains(PlanningDomainsRepo, "blocks")
3-element Vector{String}:
 "112-blocks"
 "127-blocks-3op"
 "128-blocks-reduced"

julia> find_problems(PlanningDomainsRepo, "112-blocks", r"BLOCKS-4-\d.pddl")
3-element Vector{String}:
 "3967-probBLOCKS-4-1.pddl"
 "3968-probBLOCKS-4-2.pddl"
 "3966-probBLOCKS-4-0.pddl"
```

#### Cache Management

For repositories hosted online, PlanningDomains.jl maintains a local cache to reduce load times. However, this cache is not automatically updated if the remote repositories change. To manually clear the cache for a particular repository use `PlanningDomains.clear_cache!`. To clear all caches, use `PlanningDomains.clear_all_caches!`.
