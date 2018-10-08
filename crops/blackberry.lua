local S = farming.intllib
-- Blacberry

local sdef={
	paramtype2 = "meshoptions",
	steps = 4, -- steps till full-grown plant
	mean_grow_time=20, -- mean time till next step
	range_grow_time=3, -- plus/minus for random generator
	max_harvest=2, -- max amount of harvesting item for full grown plant
--	eat_hp=1, -- set in config for eatable plants
	minlight = 13, 
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland"},
	groups = {food=1,grain = 1, flammable = 4,no_harvest=1 ,punchable = 1,snappy=1},
	place_param2 = 3,
	min_temp=25,
	max_temp=55,
	min_humidity=30,
	max_humidity=70,
	spawnon = { spawnon = farming.change_soil or {"default:dirt_with_grass"},
				spawn_min = 0,
				spawn_max = 200,
				spawnby = nil,
				spawn_num = -1},
	description = S("Blackberry"),
	inventory_image = "farming_blackberry.png",
	eat_hp=2,
	spread = {spreadon = farming.change_soil or {"default:dirt_with_grass"},
		base_rate = 1,
		spread = 50,
		intervall = 12,
		change = 0.00001, --part of soil, which get plants
		},
	}


farming.register_plant("farming:blackberry", sdef)

