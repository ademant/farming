local S = farming.intllib
-- Mustard

farming.register_plant("farming:mustard", {
	description = "Mustard Seed",
	paramtype2 = "meshoptions",
	inventory_image = "farming_mustard_seed.png",
	steps = 5,
	minlight = 13,
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland"},
	groups = {food_mustard=1, grain = 1, flammable = 4, snappy=1,food=1,no_harvest=1},
	place_param2 = 3,
	min_temp=40,
	max_temp=70,
	min_humidity=10,
	max_humidity=40,
	spawnon = { spawnon = farming.change_soil or {"default:dirt_with_grass"},
				spawn_min = 20,
				spawn_max = 150,
				spawnby = nil,
				spawn_num = -1},
	spread = {spreadon = farming.change_soil or {"default:dirt_with_grass"},
		base_rate = 10,
		spread = 5,
		intervall = 12,
		change = 0.0001, --part of soil, which get plants
		},
	max_harvest=2,
})

