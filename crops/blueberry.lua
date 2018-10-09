-- Blueberry

farming.register_plant("farming:blueberry", {
	description = "Blueberry",
	paramtype2 = "meshoptions",
	inventory_image = "farming_blueberry.png",
	steps = 4,
	switch_drop_count = 3, -- at which stage more harvest
	minlight = 13,
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland"},
	groups = {food_wheat = 1, flammable = 4,no_seed=1},
	place_param2 = 3,
	min_temp=20,
	max_temp=55,
	min_humidity=50,
	max_humidity=70,
	spawnon = { spawnon = farming.change_soil or {"default:dirt_with_grass"},
				spawn_min = 10,
				spawn_max = 100,
				spawnby = nil,
				scale = 0.006, -- 0.006
				spawn_num = -1},
	spread = {spreadon = farming.change_soil or {"default:dirt_with_grass"},
		base_rate = 1,
		spread = 50,
		intervall = 12,
		change = 0.00001, --part of soil, which get plants
		},
})


