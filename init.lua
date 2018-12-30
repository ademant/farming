-- Global farming namespace

farming = {}
farming.path = minetest.get_modpath("farming")
farming.config = minetest.get_mod_storage()
farming.modname=minetest.get_current_modname()
farming.mod = "redesign"
local S = dofile(farming.path .. "/intllib.lua")
farming.intllib = S


minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- start loading from "..minetest.get_modpath(minetest.get_current_modname()))
-- Load files

-- import settingtypes.txt
basic_functions.import_settingtype(farming.path .. "/settingtypes.txt")

dofile(farming.path .. "/api.lua") -- several helping functions
dofile(farming.path .. "/config.lua") -- configuration of mod

dofile(farming.path .. "/actions_register.lua") -- several actions defined
dofile(farming.path .. "/nodes_register.lua") -- registering of nodes and items
dofile(farming.path .. "/nodes.lua") --registering nodes
dofile(farming.path .. "/tools_register.lua") --register functions for tools
dofile(farming.path .. "/tools.lua") --define tools
dofile(farming.path .. "/utensils.lua") -- utensils like grinder
dofile(farming.path .. "/craft.lua") -- some craft definitions
dofile(farming.path .. "/crops.lua") -- loading definition of crop and register
dofile(farming.path .. "/abm.lua") -- abm functions
dofile(farming.path .. "/compatibility.lua") -- Compatibility with other mods

-- replacement LBM for pre-nodetimer plants
minetest.register_lbm({
	name = ":farming:start_nodetimer_",
	nodenames = "groups:farming",
	action = function(pos, node)
			minetest.get_node_timer(pos):start(math.random(farming.wait_min,farming.wait_max))
	end,
})
minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- loaded ")
