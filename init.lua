-- Global farming namespace

farming = {}
farming.path = minetest.get_modpath("farming")
farming.config = minetest.get_mod_storage()
farming.modname=minetest.get_current_modname()

local S = dofile(farming.path .. "/intllib.lua")
farming.intllib = S


minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- start loading from "..minetest.get_modpath(minetest.get_current_modname()))
-- Load files


dofile(farming.path .. "/functions.lua")
dofile(farming.path .. "/config.lua")

dofile(farming.path .. "/api.lua")
dofile(farming.path .. "/register.lua")
dofile(farming.path .. "/nodes.lua")
dofile(farming.path .. "/tools.lua")
dofile(farming.path .. "/utensils.lua")
dofile(farming.path .. "/craft.lua")
dofile(farming.path .. "/crops.lua")

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
		
minetest.register_abm({
	label="crops getting ill",
	nodenames="group:infectable",
	intervall = 5,
	change=5,
	action = function(pos)
		local starttime=os.time()
		local node=minetest.get_node(pos)
		if node.name == "air" or node.name == "ignore" then
			return
		end
		local ndef = minetest.registered_nodes[node.name]
		if ndef.groups.infectable == nil then
			return
		end
		local meta = minetest.get_meta(pos)
		local ill_rate=meta:get_int("farming:weakness")
		if ill_rate == nil then
			return
		end
		if math.random(1,ill_rate)==1 then
			farming.plant_infect(pos)
		end
--		print("infect time: "..os.time()-starttime)
	end
})

minetest.register_abm({
	label="Planting crops",
	nodenames = farming.change_soil,
	neighbors = {"air"},
	interval = 15+math.random(-1,1), -- little noise
	chance = 200,
	action = function(pos)
		local starttime=os.clock()
		local ptabove={x=pos.x,y=pos.y+1,z=pos.z}
		local above = minetest.get_node(ptabove)
		if above.name ~= "air" then
			return
		end
		local ptlight=minetest.get_node_light(ptabove)
		if ptlight < farming.min_light then
			return
		end
		local ptlight=minetest.get_node_light(ptabove,.5)
		if ptlight < farming.min_light then
			return
		end
		-- only for positions, where not too many plants are nearby
		-- first check if any crops are nearby, because the counting
		-- of nearby crops is time consuming
		if minetest.find_node_near(pos,4,"group:farming") ~= nil then
			if #minetest.find_nodes_in_area(vector.subtract(pos,4),vector.add(pos,4),"group:farming") > 2 then
				return
			end
		end
--		if math.random(0,100) < 1 then
			local node_temp=minetest.get_heat(pos)
			local node_hum=minetest.get_humidity(pos)
			local sc={}
			for _,line in ipairs(farming.spreading_crops) do
			  if line.temp_min<=node_temp and line.temp_max>=node_temp then
				if line.hum_min<=node_hum and line.hum_max>=node_hum then
					if line.y_min<=pos.y and line.y_max>=pos.y then
						if line.light_min<=ptlight and line.light_max >= ptlight then
							for k=1,math.floor(math.log(line.base_rate*1e10)) do
								table.insert(sc,1,line.name)
							end
						end
					end
				end
			  end
			end
			if #sc > 0 then
				local rand_plant = math.random(1,#sc)
				minetest.add_node(ptabove, {name=sc[rand_plant],param2=1})
				minetest.get_node_timer(ptabove):start(math.random(10, 15))
				local starttime=os.clock()
				farming.set_node_metadata(ptabove)
				print("place time: "..(1000*(os.clock()-starttime)))
			end
--		end
	end,
})
--print(dump(farming.spreading_crops))
minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- loaded ")
