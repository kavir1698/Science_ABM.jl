
@testset "Model run" begin
  param_file = "params.yml"
  @test_nowarn model = Science_ABM.initialize_model(param_file)
  model = Science_ABM.initialize_model(param_file)
  if model.properties["replicates"] <= 1
    adata, mdata = run!(model, dummystep, Science_ABM.model_step!, model.properties["years"], adata=Science_ABM.adata, when =  model.properties["save_gens"])
  else
    adata, mdata, models = ensemblerun!([Science_ABM.initialize_model(param_file) for in model.properties["replicates"]], dummystep, Science_ABM.model_step!, model.properties["years"], adata=Science_ABM.adata, when =  model.properties["save_gens"])
  end
end