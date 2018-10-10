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
dofile(farming.path .. "/register.lua")
dofile(farming.path .. "/nodes.lua")
dofile(farming.path .. "/tools.lua")
dofile(farming.path .. "/utensils.lua")
dofile(farming.path .. "/craft.lua")
dofile(farming.path .. "/crops.lua")

print("dump registered plants")
print(dump(farming.registered_plants))

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

-- replacement LBM for pre-nodetimer plants
minetest.register_lbm({
	name = ":farming:start_nodetimer_",
	nodenames = "groups:farming",
	action = function(pos, node)
			minetest.get_node_timer(pos):start(math.random(farming.wait_min,farming.wait_max))
	end,
})

minetest.register_abm({
	nodenames = farming.change_soil,
	neighbors = {"air"},
	interval = 15+math.random(-1,1), -- little noise
	chance = 2,
	action = function(pos)
		local ptabove={x=pos.x,y=pos.y+1,z=pos.z}
		local above = minetest.get_node(ptabove)
		if above.name ~= "air" then
			return
		end
		local ptlight=minetest.get_node_light(ptabove)
		if ptlight < 5 then
			return
		end
		local pos0 = vector.subtract(pos,4)
		local pos1 = vector.add(pos,4)
		-- only for positions, where not too many plants are nearby
		if #minetest.find_nodes_in_area(pos0,pos1,"group:farming") > 2 then
			return
		end
		if math.random(0,100) < 1 then
			local node_temp=minetest.get_heat(pos)
			local node_hum=minetest.get_humidity(pos)
			local sc={}
			for _,line in ipairs(farming.spreading_crops) do
			  if line.temp_min<=node_temp and line.temp_max>=node_temp then
				if line.hum_min<=node_hum and line.hum_max>=node_hum then
					if line.y_min<=pos.y and line.y_max>=pos.y then
						for k=1,line.base_rate do
							table.insert(sc,1,line.name)
						end
					end
				end
			  end
			end
			if #sc > 0 then
				local rand_plant = math.random(1,#sc)
				minetest.add_node(ptabove, {name=sc[rand_plant],param2=1})
				minetest.get_node_timer(ptabove):start(math.random(10, 15))
			end
		end
	end,
})


minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- loaded ")
