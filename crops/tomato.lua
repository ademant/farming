local S = farming.intllib
-- Tomato

farming.register_plant("farming:tomato", {
	description = "Tomato",
	paramtype2 = "meshoptions",
	inventory_image = "farming_tomato_seed.png",
	steps = 8,
	minlight = 13,
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland"},
	groups = {food_wheat=1, grain = 1, flammable = 4, on_soil = 1,snappy=1,food=1,punchable=1},
	place_param2 = 3,
	min_temp=30,
	max_temp=60,
	min_humidity=30,
	max_humidity=70,
	spawnon = { spawnon = farming.change_soil or {"default:dirt_with_grass"},
				spawn_min = 25,
				spawn_max = 100,
				spawnby = nil,
				spawn_num = -1},
	eat_hp=1,
	max_harvest=2,
})

