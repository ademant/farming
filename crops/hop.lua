local S = farming.intllib
-- Hops

farming.register_plant("farming:hops", {
	description = "Hops",
	paramtype2 = "meshoptions",
	inventory_image = "farming_hops_seed.png",
	steps = 8,
	minlight = 13,
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland"},
	groups = {food_wheat=1, grain = 1, flammable = 4, on_soil = 1,snappy=1,food=1,punchable=1},
	place_param2 = 3,
	min_temp=20,
	max_temp=50,
	min_humidity=20,
	max_humidity=70,
	spawnon = { spawnon = farming.change_soil or {"default:dirt_with_grass"},
				spawn_min = 0,
				spawn_max = 42,
				spawnby = nil,
				spawn_num = -1},
	eat_hp=1,
	max_harvest=2,
})

