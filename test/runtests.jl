using PlanningDomains, Test
using PlanningDomains: clear_cache!, clear_all_caches!

@testset "JuliaPlanners repository" begin
    collection_names = list_collections(JuliaPlannersRepo)
    @test isempty(collection_names)
    domain_names = list_domains(JuliaPlannersRepo)
    @test !isempty(domain_names)
    for dname in domain_names
        problem_names = list_problems(JuliaPlannersRepo, dname)
        @test !isempty(problem_names)
        domain = load_domain(JuliaPlannersRepo, dname)
        problem = load_problem(JuliaPlannersRepo, dname, problem_names[1])
    end
    @test find_domains(JuliaPlannersRepo, "blocks") == ["blocksworld", "blocksworld-axioms"]
    @test find_problems(JuliaPlannersRepo, "blocksworld", "1") == ["problem-1"]
end

@testset "IPC Instances repository" begin
    collection_names = list_collections(IPCInstancesRepo)
    @test !isempty(collection_names)
    domain_names = list_domains(IPCInstancesRepo)
    @test !isempty(domain_names)
    domain_names = list_domains(IPCInstancesRepo, "ipc-2000")
    @test !isempty(domain_names)
    for dname in domain_names
        dname = "ipc-2000-$dname"
        problem_names = list_problems(IPCInstancesRepo, dname)
        @test !isempty(problem_names)
        domain = load_domain(IPCInstancesRepo, dname)
        problem = load_problem(IPCInstancesRepo, dname, problem_names[1])
    end
    @test find_domains(IPCInstancesRepo, "ipc-2000", "blocks") ==
        ["blocks-strips-typed", "blocks-strips-untyped"]
    @test find_problems(IPCInstancesRepo, "ipc-2000-blocks-strips-typed", "100") ==
        ["instance-100"]
    clear_cache!(IPCInstancesRepo())
end

@testset "Planning Domains repository" begin
    collection_names = list_collections(PlanningDomainsRepo)
    @test !isempty(collection_names)
    domain_names = list_domains(PlanningDomainsRepo)
    @test !isempty(domain_names)
    domain_names = list_domains(PlanningDomainsRepo, "IPC-2000")
    @test !isempty(domain_names)
    for dname in domain_names
        problem_names = list_problems(PlanningDomainsRepo, dname)
        @test !isempty(problem_names)
        domain = load_domain(PlanningDomainsRepo, dname)
        problem = load_problem(PlanningDomainsRepo, dname, problem_names[1])
    end
    @test find_domains(PlanningDomainsRepo, "IPC-2000", "blocks") ==
        ["112-blocks"]
    @test find_problems(PlanningDomainsRepo, "112-blocks", "probBLOCKS-4-0") ==
        ["3966-probBLOCKS-4-0.pddl"]
    clear_cache!(PlanningDomainsRepo())
end

@testset "Default repository" begin
    collection_names = list_collections()
    @test isempty(collection_names)
    domain_names = list_domains()
    @test !isempty(domain_names)
    for dname in domain_names
        dname = Symbol(dname)
        problem_names = list_problems(dname)
        @test !isempty(problem_names)
        domain = load_domain(dname)
        problem = load_problem(dname, problem_names[1])
    end
    @test find_domains("blocks") == ["blocksworld", "blocksworld-axioms"]
    @test find_problems("blocksworld", "1") == ["problem-1"]
end

clear_all_caches!()
