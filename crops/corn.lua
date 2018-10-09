local S = farming.intllib
-- Corn

local po_def={
	description = "Corn",
	paramtype2 = "meshoptions",
	inventory_image = "farming_corn.png",
	steps = 8,
	max_harvest=4,
	minlight = 13,
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland"},
	groups = {food_wheat = 1, flammable = 4,no_harvest=1, on_soil = 1,snappy=1,food=1},
	place_param2 = 3,
	spawnon = { spawnon = farming.change_soil or {"default:dirt_with_grass"},
				spawn_min = 10,
				spawn_max = 150,
				spawnby = nil,
				scale = 0.006, -- 0.006
				spawn_num = -1},
	spread = {spreadon = farming.change_soil or {"default:dirt_with_grass"},
		base_rate = 10,
		spread = 5,
		intervall = 12,
		change = 0.0001, --part of soil, which get plants
		},
	min_temp=30,
	max_temp=60,
	min_humidity=40,
	max_humidity=70,
}
farming.register_plant("farming:corn", po_def)

