-- WHEAT
local S = farming.intllib

local w1def={
	paramtype2 = "meshoptions",
	steps = 8, -- steps till full-grown plant
	mean_grow_time=20, -- mean time till next step
	range_grow_time=3, -- plus/minus for random generator
	max_harvest=2, -- max amount of harvesting item for full grown plant
--	eat_hp=1, -- set in config for eatable plants
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
	description = S("Wheat Seed"),
	inventory_image = "farming_wheat_seed.png",
	eat_hp=1,
	next_plant="farming:culturewheat",
	next_plant_rarity=12,
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
	}
--print(dump(w1def))
--if(table.getn(farming.possible_biomes)>0) then
--  def.biomes=farming.possible_biomes
--end
farming.register_plant("farming:wheat", w1def)

local wdef={
	paramtype2 = "meshoptions",
	steps = 4, -- steps till full-grown plant
	mean_grow_time=20, -- mean time till next step
	range_grow_time=3, -- plus/minus for random generator
	max_harvest=4, -- max amount of harvesting item for full grown plant
--	eat_hp=1, -- set in config for eatable plants
	minlight = 11, 
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland"},
	groups = {food_wheat=1,no_spawn=1,grain = 1, flammable = 4, on_soil = 1,infectable=1},
	place_param2 = 3,
	description = S("Culture Wheat Seed"),
	inventory_image = "farming_culturewheat_seed.png",
	eat_hp=1,
	steps=4,
	eat_hp=1,
	mean_grow_time=20,
	range_grow_time=5,
	infect = {
		base_rate = 10,
		mono_rate = 5,
		infect_rate = 2,
		intervall = 50,
		},
	spread = {spreadon = farming.change_soil or {"default:dirt_with_grass"},
		base_rate = 100,
		spread = 50,
		intervall = 360,
		change = 0.00001, --part of soil, which get plants
		},
	}
farming.register_plant("farming:culturewheat", wdef)

