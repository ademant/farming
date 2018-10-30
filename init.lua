-- Global farming namespace

farming = {}
farming.path = minetest.get_modpath("farming")
farming.config = minetest.get_mod_storage()
farming.modname=minetest.get_current_modname()

local S = dofile(farming.path .. "/intllib.lua")
farming.intllib = S


minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- start loading from "..minetest.get_modpath(minetest.get_current_modname()))
-- Load files


dofile(farming.path .. "/functions.lua") --few helping functions
dofile(farming.path .. "/config.lua") -- configuration of mod

dofile(farming.path .. "/api.lua") -- api of former mod
dofile(farming.path .. "/actions_register.lua") -- several actions defined
dofile(farming.path .. "/nodes_register.lua") -- registering of nodes and items
dofile(farming.path .. "/nodes.lua") --registering nodes
dofile(farming.path .. "/tools_register.lua") --register functions for tools
dofile(farming.path .. "/tools.lua") --define tools
dofile(farming.path .. "/utensils.lua") -- utensils like grinder
dofile(farming.path .. "/craft.lua") -- some craft definitions
dofile(farming.path .. "/crops.lua") -- loading definition of crop and register
dofile(farming.path .. "/abm.lua") -- abm functions

--print("dump registered plants")
--print(dump(farming.registered_plants))

--[[
minetest.register_abm({
	nodenames = {"default:aspen_tree"},
	interval = 30,
	chance = 1,
	action = function(pos)
		minetest.add_node(pos, {name="default:wood"})
	end,
})
]]

-- 1h in minetest == 72s reale Zeit

-- replacement LBM for pre-nodetimer plants
minetest.register_lbm({
	name = ":farming:start_nodetimer_",
	nodenames = "groups:farming",
	action = function(pos, node)
			minetest.get_node_timer(pos):start(math.random(farming.wait_min,farming.wait_max))
	end,
})
--[[
minetest.register_abm({
	nodenames="air",
	intervall=1,
	change=100000,
	action = function(pos)
--		print(dump(farming.calc_light(pos,{light_min=15})))
		print(os.clock(),minetest.get_timeofday())
		end
		})
]]
--[[
light_min	day_start	amount
4			51			988
5			53			978
6			54			972
7			55			965
8			56			957
9			57			948
10			57			948
11			58			937
12			59			925
13			60			912
14			63			870
]]
--print(dump(farming.change_soil))
--print(dump(farming.spreading_crops))
minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- loaded ")
