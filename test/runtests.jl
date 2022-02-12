using PlanningDomains, Test
using PlanningDomains: clear_cache!, clear_all_caches!

@testset "JuliaPlanners repository" begin
    domain_names = list_domains(JuliaPlannersRepo)
    @test !isempty(domain_names)
    for dname in domain_names
        problem_names = list_problems(JuliaPlannersRepo, dname)
        @test !isempty(problem_names)
        domain = load_domain(JuliaPlannersRepo, dname)
        problem = load_problem(JuliaPlannersRepo, dname, problem_names[1])
    end
end

@testset "IPC Instances repository" begin
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
    clear_cache!(IPCInstancesRepo())
end

clear_all_caches!()
