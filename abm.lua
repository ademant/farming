minetest.register_abm({
	label = "Farming soil",
	nodenames = {"group:field"},
	interval = 15,
	chance = 4,
	action = function(pos, node)
		local n_def = minetest.registered_nodes[node.name] or nil
		local wet = n_def.soil.wet or nil
		local base = n_def.soil.base or nil
		local dry = n_def.soil.dry or nil
		if not n_def or not n_def.soil or not wet or not base or not dry then
			return
		end

		pos.y = pos.y + 1
		local nn = minetest.get_node_or_nil(pos)
		if not nn or not nn.name then
			return
		end
		local nn_def = minetest.registered_nodes[nn.name] or nil
		pos.y = pos.y - 1

		if nn_def and nn_def.walkable and minetest.get_item_group(nn.name, "plant") == 0 then
			minetest.set_node(pos, {name = base})
			return
		end
		-- check if there is water nearby
		local wet_lvl = minetest.get_item_group(node.name, "wet")
		if minetest.find_node_near(pos, 3, {"group:water"}) then
			-- if it is dry soil and not base node, turn it into wet soil
			if wet_lvl == 0 then
				minetest.set_node(pos, {name = wet})
			end
		else
			-- only turn back if there are no unloaded blocks (and therefore
			-- possible water sources) nearby
			if not minetest.find_node_near(pos, 3, {"ignore"}) then
				-- turn it back into base if it is already dry
				if wet_lvl == 0 then
					-- only turn it back if there is no plant/seed on top of it
					if minetest.get_item_group(nn.name, "plant") == 0 and minetest.get_item_group(nn.name, "seed") == 0 then
						minetest.set_node(pos, {name = base})
					end

				-- if its wet turn it back into dry soil
				elseif wet_lvl == 1 then
					minetest.set_node(pos, {name = dry})
				end
			end
		end
	end,
})


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
--				print("place time: "..(1000*(os.clock()-starttime)))
			end
--		end
	end,
})
