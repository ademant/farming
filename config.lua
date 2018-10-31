
--[[
	Farming settings can be changed here and kept inside mod folder
	even after the mod has been updated, or you can place inside
	world folder for map specific settings.
--]]

local viscosity=1

if minetest.settings:get("farming.rarety") then
  farming.config:set_float("rarety",minetest.settings:get("farming.rarety"))
end
if minetest.settings:get("farming.viscosity") then
	farming.config:set_int("viscosity",minetest.settings:get("farming.viscosity"))
else
	farming.config:set_int("viscosity",viscosity)
end

-- rarety of crops on map, default is 0.001 (higher number = more crops)
farming.rarety =  0.002
-- random waiting time for growing
farming.wait_min = 10
farming.wait_max = 20
farming.wilt_removal_time = 60
farming.wilt_time = 5
farming.min_light = 10
farming.health_threshold=50 -- plant with healthiness smaller this threshold can get ill
farming.factor_regrow = 2 -- after punching fruits the plant needs more time to regrow
farming.abm_planting=15 -- time intervall for abm planting
farming.abm_planting_change=200 -- change for abm planting for execution

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

-- register for crops, which are spreading by abm
farming.spreading_crops = {}

-- register for crops
farming.registered_plants = {}

-- reading light statistics. needed for calculation of grow time
farming.light_stat = farming.import_csv(farming.path.."/light_stat.txt",{
	col_num={"day_start","amount","name"}})
