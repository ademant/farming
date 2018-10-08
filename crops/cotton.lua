-- Cotton
local S = farming.intllib
local cdef={
	paramtype2 = "meshoptions",
	steps = 8, -- steps till full-grown plant
	mean_grow_time=20, -- mean time till next step
	range_grow_time=3, -- plus/minus for random generator
	max_harvest=2, -- max amount of harvesting item for full grown plant
	minlight = 13, 
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland"},
	groups = {cotton = 1, flammable = 4,no_harvest=1,punchable=1},
	place_param2 = 3,
	min_temp=45,
	max_temp=80,
	min_humidity=40,
	max_humidity=70,
	spawnon = { spawnon = farming.change_soil or {"default:dirt_with_grass"},
				spawn_min = 50,
				spawn_max = 500,
				spawnby = nil,
				spawn_num = -1},
	description = S("Cotton Seed"),
	inventory_image = "farming_cotton_seed.png",
	}

farming.register_plant("farming:cotton", cdef)

