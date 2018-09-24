-- Global farming namespace

farming = {}
farming.path = minetest.get_modpath("farming")

local S = dofile(farming.path .. "/intllib.lua")
farming.intllib = S


minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- start loading from "..minetest.get_modpath(minetest.get_current_modname()))
-- Load files

farming.rarety = 0.002 -- 0.006
farming.potato = minetest.settings:get("farming.potato") or true
farming.carrot = minetest.settings:get("farming.carrot") or true
farming.tomato = minetest.settings:get("farming.tomato") or true
farming.wheat = minetest.settings:get("farming.wheat") or true
farming.cotton = minetest.settings:get("farming.cotton") or true

dofile(farming.path .. "/config.lua")
--[[
for i,inp in ipairs({farming.path,minetest.get_worldpath}) do
    print(inp.."/farming.conf")
	local inconf = io.open(inp.."/farming.conf", "r")
	if inconf then
		dofile(inp .. "/farming.conf")
		inp:close()
		inp = nil
	end
end
]]
dofile(farming.path .. "/api.lua")
dofile(farming.path .. "/api_ng.lua")
dofile(farming.path .. "/nodes.lua")
dofile(farming.path .. "/hoes.lua")
dofile(farming.path .. "/utensils.lua")
dofile(farming.path .. "/craft.lua")


dofile(farming.path .. "/crops/wheat.lua")
dofile(farming.path .. "/crops/potato.lua")
dofile(farming.path .. "/crops/carrot.lua")
dofile(farming.path .. "/crops/tomato.lua")
dofile(farming.path .. "/crops/barley.lua")
dofile(farming.path .. "/crops/cotton.lua")



-- Straw

minetest.register_craft({
	output = "farming:straw 3",
	recipe = {
		{"farming:wheat", "farming:wheat", "farming:wheat"},
		{"farming:wheat", "farming:wheat", "farming:wheat"},
		{"farming:wheat", "farming:wheat", "farming:wheat"},
	}
})

minetest.register_craft({
	output = "farming:wheat 3",
	recipe = {
		{"farming:straw"},
	}
})


-- Fuels

minetest.register_craft({
	type = "fuel",
	recipe = "farming:straw",
	burntime = 3,
})

minetest.register_craft({
	type = "fuel",
	recipe = "farming:wheat",
	burntime = 1,
})

minetest.register_craft({
	type = "fuel",
	recipe = "farming:cotton",
	burntime = 1,
})

minetest.register_craft({
	type = "fuel",
	recipe = "farming:string",
	burntime = 1,
})

minetest.register_craft({
	type = "fuel",
	recipe = "farming:hoe_wood",
	burntime = 5,
})


minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- loaded ")
