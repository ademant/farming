-- Rhubarb

farming.register_plant("farming:rhubarb", {
	description = "Rhubarb",
	paramtype2 = "meshoptions",
	inventory_image = "farming_rhubarb.png",
	steps = 3,
	switch_drop_count = 2, -- at which stage more harvest
	minlight = 13,
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland"},
	groups = {food_wheat = 1, flammable = 4,no_seed=1},
	place_param2 = 3,
	spawnon = { spawnon = farming.change_soil or {"default:dirt_with_grass"},
				spawn_min = 0,
				spawn_max = 42,
				spawnby = nil,
				scale = 0.006, -- 0.006
				spawn_num = -1}
})


