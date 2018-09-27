-- Cotton
local S = farming.intllib

local possible_biomes={}
for name,def in pairs(minetest.registered_biomes) do
  if def.heat_point > 20 and def.heat_point < 60 and def.humidity_point > 20 and def.humidity_point < 70 then
    table.insert(possible_biomes,1,name)
  end
end

local def=farming.plant_def
def.description = S("Cotton Seed")
def.inventory_image = "farming_cotton_seed.png"
def.groups.cotton=1
--[[
local def={
	description = S("Cotton Seed"),
	paramtype2 = "meshoptions",
	inventory_image = "farming_cotton_seed.png",
	steps = 8,
	max_harvest=2,
	eat_hp=0,
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
]]
if(table.getn(possible_biomes)>0) then
  def.biomes=possible_biomes
end

farming.register_plant("farming:cotton", def)

