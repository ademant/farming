-- Tomato

farming.register_plant("farming:tomato", {
	description = "Tomato",
	paramtype2 = "meshoptions",
	inventory_image = "farming_tomato.png",
	steps = 8,
	switch_drop_count = 6, -- at which stage more harvest
	minlight = 13,
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland"},
	groups = {food_wheat = 1, flammable = 4,no_seed=1},
	place_param2 = 3,
	spawnon = { spawnon = {"default:dirt","default:dirt_with_grass"},
				spawn_min = 0,
				spawn_max = 42,
				spawnby = nil,
				scale = 0.006, -- 0.006
				spawn_num = -1}
})


