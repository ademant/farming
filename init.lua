-- Global farming namespace

farming = {}
farming.path = minetest.get_modpath("farming")
farming.config = minetest.get_mod_storage()

local S = dofile(farming.path .. "/intllib.lua")
farming.intllib = S


minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- start loading from "..minetest.get_modpath(minetest.get_current_modname()))
-- Load files


dofile(farming.path .. "/config.lua")

dofile(farming.path .. "/api.lua")
dofile(farming.path .. "/api_ng.lua")
dofile(farming.path .. "/nodes.lua")
dofile(farming.path .. "/tools.lua")
dofile(farming.path .. "/utensils.lua")
dofile(farming.path .. "/craft.lua")


for i,crop in ipairs(farming.crops) do
  if farming.config:get_int(crop) == 1 then
    dofile(farming.path.."/crops/"..crop..".lua")
  end
end
print("dump registered plants")
print(dump(farming.registered_plants))



minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- loaded ")
