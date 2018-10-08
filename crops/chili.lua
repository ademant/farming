-- Chili

farming.register_plant("farming:chili", {
	description = "Chili Seed",
	paramtype2 = "meshoptions",
	inventory_image = "farming_chili_seed.png",
	steps = 8,
	switch_drop_count = 6, -- at which stage more harvest
	minlight = 13,
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland"},
	groups = {food_wheat = 1, flammable = 4},
	place_param2 = 3,
	spawnon = { spawnon = farming.change_soil or {"default:dirt_with_grass"},
				spawn_min = 40,
				spawn_max = 400,
				spawnby = nil,
				scale = 0.006, -- 0.006
				spawn_num = -1},
	spread = {spreadon = farming.change_soil or {"default:dirt_with_grass"},
		base_rate = 10,
		spread = 5,
		intervall = 12,
		change = 0.0001, --part of soil, which get plants
		},
	min_temp=40,
	max_temp=70,
	min_humidity=15,
	max_humidity=50,
})


