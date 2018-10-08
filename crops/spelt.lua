local S = farming.intllib
-- Spelt

farming.register_plant("farming:spelt", {
	description = "Spelt Seed",
	paramtype2 = "meshoptions",
	inventory_image = "farming_spelt_seed.png",
	steps = 7,
	minlight = 13,
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland"},
	groups = {food_wheat=1, grain = 1, flammable = 4, on_soil = 1,snappy=1,food=1},
	place_param2 = 3,
	min_temp=00,
	max_temp=60,
	min_humidity=10,
	max_humidity=50,
	spawnon = { spawnon = farming.change_soil or {"default:dirt_with_grass"},
				spawn_min = 0,
				spawn_max = 100,
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


