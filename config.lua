
--[[
	Farming settings can be changed here and kept inside mod folder
	even after the mod has been updated, or you can place inside
	world folder for map specific settings.
--]]

-- true to enable crop/food in-game and on mapgen
farming.carrot = true
farming.potato = true
farming.tomato = true
farming.cucumber = true
farming.corn = true
farming.coffee = true
farming.melon = true
farming.pumpkin = true
farming.cocoa = true
farming.raspberry = true
farming.blueberry = true
farming.rhubarb = true
farming.beans = true
farming.grapes = true
farming.barley = true
farming.chili = true
farming.hemp = true
farming.onion = true
farming.garlic = true
farming.pepper = true
farming.pineapple = true
farming.peas = true
farming.beetroot = true

-- rarety of crops on map, default is 0.001 (higher number = more crops)
farming.rarety = 0.002

-- node type, where grain can be randomly found
farming.change_soil = {}
local test_soil = {"default:dirt","default:dirt_with_grass","default:dirt_with_dry_grass","default:dirt_with_rainforest_litter",
	"default:dirt_with_coniferous_litter","default:permafrost_with_moss"}
for i,s in ipairs(test_soil) do
  if minetest.registered_nodes[s] ~= nil then
    table.insert(farming.change_soil,s)
  end
end
farming.change_soil_desert = {}
local test_soil = {"default:desert_sand"}
for i,s in ipairs(test_soil) do
  if minetest.registered_nodes[s] ~= nil then
    table.insert(farming.change_soil_desert,s)
  end
end

farming.possible_biomes={}
for name,def in pairs(minetest.registered_biomes) do
  if def.heat_point > 10 and def.heat_point < 50 and def.humidity_point > 5 and def.humidity_point < 70 then
    table.insert(farming.possible_biomes,1,name)
  end
end
--print(table.maxn(farming.possible_biomes))

farming.plant_def={
	paramtype2 = "meshoptions",
	steps = 8, -- steps till full-grown plant
	mean_grow_time=20, -- mean time till next step
	range_grow_time=3, -- plus/minus for random generator
	max_harvest=2, -- max amount of harvesting item for full grown plant
--	eat_hp=1, -- set in config for eatable plants
	minlight = 13, 
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland"},
	groups = {grain = 1, flammable = 4},
	place_param2 = 3,
	min_temp=10,
	max_temp=50,
	min_humidity=10,
	max_humidity=70,
	spawnon = { spawnon = farming.change_soil or {"default:dirt_with_grass"},
				spawn_min = 0,
				spawn_max = 42,
				spawnby = nil,
				scale = 0.006, -- 0.006
				spawn_num = -1}
}

