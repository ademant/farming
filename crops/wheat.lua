-- WHEAT
local S = farming.intllib

local def={
	description = S("Wheat Seed"),
	paramtype2 = "meshoptions",
	inventory_image = "farming_wheat_seed.png",
	steps = 8,
	mean_grow_time=20,
	range_grow_time=3,
	max_harvest=2,
	eat_hp=1,
	next_plant="farming:culturewheat",
	next_plant_rarity=12,
	minlight = 13,
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland"},
	groups = {food_wheat = 1, grain = 1, flammable = 4},
	place_param2 = 3,
	spawnon = { spawnon = farming.change_soil or {"default:dirt_with_grass"},
				spawn_min = 0,
				spawn_max = 42,
				spawnby = nil,
				scale = 0.006, -- 0.006
				spawn_num = -1}
}
if(table.getn(farming.possible_biomes)>0) then
  def.biomes=farming.possible_biomes
end
farming.register_plant("farming:wheat", def)

local def={
	description = "Wheat Seed",
	paramtype2 = "meshoptions",
	inventory_image = "farming_culturewheat_seed.png",
	steps = 4,
	mean_grow_time=10,
	range_grow_time=3,
	eat_hp=1,
	max_harvest=4,
	minlight = 11,
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland"},
	groups = {food_wheat = 1, flammable = 4,no_spawn=1},
	place_param2 = 3,
}
if(table.getn(farming.possible_biomes)>0) then
  def.biomes=farming.possible_biomes
end
farming.register_plant("farming:culturewheat", def)

