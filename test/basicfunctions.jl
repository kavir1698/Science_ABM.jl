@testset "Basicfunctions Module Tests" begin

  param_file = "params.yml"
  model = Science_ABM.initialize_model(param_file)
  problem = Science_ABM.choose_problem(model[1], model)

  
  @testset "choose_problem Tests" begin
    @test isdefined(Science_ABM, :choose_problem) == true
    @test isdefined(problem, :complexity)
    @inferred Science_ABM.choose_problem(model[1], model)
    @test length(fieldnames(typeof(problem))) ==  5
    @test problem.time_to_finish <= 3
    @test problem.success_probability < 1
    @test problem.success_probability > 0
  end

  @testset "pushproblem! Tests" begin
    @test isdefined(Science_ABM, :pushproblem!) == true
    @test length(model[1].problem_history) == 3
    @test typeof(model[1].publication_success[1]) == Bool
  end
end
