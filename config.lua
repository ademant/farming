
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
farming.rarety =  minetest.settings:get("farming.rarety") or 0.002
farming.viscosity =  minetest.settings:get("farming.viscosity") or 1
farming.wait_min =  minetest.settings:get("farming.wait_min") or 60
farming.wait_max =  minetest.settings:get("farming.wait_max") or 70
farming.wilt_removal_time =  minetest.settings:get("farming.wilt_removal_time") or 40
farming.wilt_time =  minetest.settings:get("farming.wilt_time") or 90
farming.min_light =  minetest.settings:get("farming.min_light") or 10
farming.health_threshold =  minetest.settings:get("farming.health_threshold") or 50
farming.factor_regrow =  minetest.settings:get("farming.factor_regrow") or 2
farming.abm_planting =  minetest.settings:get("farming.abm_planting") or 30
farming.abm_planting_change =  minetest.settings:get("farming.abm_planting_change") or 750

-- node type, where grain can be randomly found
farming.change_soil = {}
local test_soil = {"default:dirt","default:dirt_with_grass","default:dirt_with_dry_grass","default:dirt_with_rainforest_litter",
	"default:dirt_with_coniferous_litter","default:permafrost_with_moss"}
for i,s in ipairs(test_soil) do
  if minetest.registered_nodes[s] ~= nil then
	farming.add_soil(s)
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

-- temp list for grass drop
farming.grass_drop={max_items=1,items = {items={items={"default:grass_1"}}}}
farming.junglegrass_drop={max_items=1,items = {items={items={"default:junglegrass"}}}}

-- reading light statistics. needed for calculation of grow time
farming.light_stat = basic_functions.import_csv(farming.path.."/light_stat.txt",{
	col_num={"day_start","amount","name"}})

