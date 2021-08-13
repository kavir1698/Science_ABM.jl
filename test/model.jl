
@testset "Mutation" begin
  param_file = "params.yml"
  @test_nowarn model = Science_ABM.initialize_model(param_file)
  model = Science_ABM.initialize_model(param_file)
  run!(model, dummystep, Science_ABM.model_step!, model.properties["years"])
  run!(model, dummystep, Science_ABM.model_step!, 10)
end