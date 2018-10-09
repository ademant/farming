local S = farming.intllib
-- Potato

local po_def={
	description = "Potato",
	paramtype2 = "meshoptions",
	inventory_image = "farming_potato.png",
	steps = 4,
	max_harvest=4,
	minlight = 13,
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland"},
	groups = {food_wheat = 1, flammable = 4,no_harvest=1, on_soil = 1,snappy=1,food=1,infectable=1},
	place_param2 = 3,
	spawnon = { spawnon = farming.change_soil or {"default:dirt_with_grass"},
				spawn_min = 50,
				spawn_max = 300,
				spawnby = nil,
				scale = 0.006, -- 0.006
				spawn_num = -1},
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
	min_temp=25,
	max_temp=60,
	min_humidity=30,
	max_humidity=70,
}
farming.register_plant("farming:potato", po_def)


