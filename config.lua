
--[[
	Farming settings can be changed here and kept inside mod folder
	even after the mod has been updated, or you can place inside
	world folder for map specific settings.
--]]

farming.crops = {"wheat","strawberry","potato"}

for i,crop in ipairs(farming.crops) do
  print(crop.." - "..farming.config:get_string(crop))
  if farming.config:get_string(crop) == "" then
    farming.config:set_int(crop,1)
  end
  if minetest.settings:get("farming."..crop) ~= nil then
    if minetest.settings:get_bool("farming."..crop) then
      farming.config:set_int(crop,1)
    else
      farming.config:set_int(crop,0)
    end
  end
end
if minetest.settings:get("farming.rarety") then
  farming.config:set_float("rarety",minetest.settings:get("farming.rarety"))
end

-- rarety of crops on map, default is 0.001 (higher number = more crops)
farming.rarety = farming.config:get_float("rarety") or 0.002
-- random waiting time for growing
farming.wait_min = farming.config:get_int("wati_min") or 40
farming.wait_max = farming.config:get_int("wati_max") or 80

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


