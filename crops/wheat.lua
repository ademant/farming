-- WHEAT

farming.register_plant("farming:wheat", {
	description = "Wheat Seed",
	paramtype2 = "meshoptions",
	inventory_image = "farming_wheat_seed.png",
	steps = 8,
	max_harvest=2,
	next_plant="farming:culturewheat",
	next_plant_rarity=12,
	minlight = 13,
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland"},
	groups = {food_wheat = 1, flammable = 4},
	place_param2 = 3,
	spawnon = { spawnon = farming.change_soil or {"default:dirt_with_grass"},
				spawn_min = 0,
				spawn_max = 42,
				spawnby = nil,
				scale = 0.006, -- 0.006
				spawn_num = -1}
})

farming.register_plant("farming:culturewheat", {
	description = "Wheat Seed",
	paramtype2 = "meshoptions",
	inventory_image = "farming_culturewheat_seed.png",
	steps = 4,
	max_harvest=4,
	minlight = 11,
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland"},
	groups = {food_wheat = 1, flammable = 4,no_spawn=1},
	place_param2 = 3,
})

