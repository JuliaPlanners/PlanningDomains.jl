using PlanningDomains, Test

@testset "JuliaPlanners repository" begin
    domains = list_domains(JuliaPlannersRepo)
    @test !isempty(domains)
    problems = list_problems(JuliaPlannersRepo, domains[1])
    @test !isempty(problems)
    load_domain(JuliaPlannersRepo, domains[1])
    load_problem(JuliaPlannersRepo, domains[1], problems[1])
end
