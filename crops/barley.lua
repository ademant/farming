local S = farming.intllib
-- Barley

farming.register_plant("farming:barley", {
	description = "Barley Seed",
	paramtype2 = "meshoptions",
	inventory_image = "farming_barley_seed.png",
	steps = 7,
	minlight = 13,
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland"},
	groups = {food_wheat=1, grain = 1, flammable = 4, on_soil = 1,snappy=1,food=1,infectable=1},
	place_param2 = 3,
	min_temp=10,
	max_temp=50,
	min_humidity=10,
	max_humidity=70,
	spawnon = { spawnon = farming.change_soil or {"default:dirt_with_grass"},
				spawn_min = 0,
				spawn_max = 42,
				spawnby = nil,
				spawn_num = -1},
	eat_hp=1,
	infect = {
		base_rate = 10,
		mono_rate = 5,
		infect_rate = 5,
		intervall = 50,
		},
	spread = {spreadon = farming.change_soil or {"default:dirt_with_grass"},
		base_rate = 10,
		spread = 5,
		intervall = 12,
		change = 0.0001, --part of soil, which get plants
		},
	max_harvest=2,
})


