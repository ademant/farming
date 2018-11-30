
-- infect a plant at pos and start timer
farming.plant_infect = function(pos)
	local starttime=os.clock()

	local def = minetest.registered_nodes[minetest.get_node(pos).name]
	local infect_name=def.plant_name.."_infected"

	if not minetest.registered_nodes[infect_name] then
		return 
	end

	if not def.groups.infectable then
		return
	end

	if not def.groups.step then
		return
	end

	local meta = minetest.get_meta(pos)
	local toremove=false
	if meta:get_int("farming:healthiness") then
		local healthiness=meta:get_int("farming:healthiness")
		-- check for nearby plants which can protect against infections
		for i=1,3 do
			local protplant=minetest.find_node_near(pos,i,"group:infection_defense")
			if protplant ~= nil then
				ppdef=minetest.get_node(protplant)
				-- the protection plant has to be within their defined radius
				if ppdef.groups.infection_defense >= i then
					healthiness=healthiness+i*10
				end
			end
		end

		if healthiness>farming.health_threshold then
			meta:set_int("farming:healthiness",healthiness-meta:get_int("farming:weakness"))
		else
			meta:set_int("farming:healthiness",farming.health_threshold)
			meta:set_int("farming:weakness",5)
			toremove=true
		end
	else
		toremove=true
	end

	if toremove then
		local placenode = {name = infect_name}
		if def.place_param2 then
			placenode.param2 = def.place_param2
		end

		minetest.swap_node(pos, placenode)

		local meta = minetest.get_meta(pos)
		meta:set_int("farming:step",def.groups["step"])

		minetest.get_node_timer(pos):start(math.random(farming.wait_min,farming.wait_max))
	end
	--table.insert(farming.time_plantinfect,1000*(os.clock()-starttime))
end

-- cures a plant at pos, restoring at last saved step
farming.plant_cured = function(pos)
	local starttime=os.clock()

	local node = minetest.get_node(pos)
	local name = node.name
	local def = minetest.registered_nodes[name]
	local meta = minetest.get_meta(pos)
	local cured_step=meta:get_int("farming:step")
	if cured_step == nil then cured_stel = 1 end
	local cured_name=def.step_name.."_"..cured_step

	if not minetest.registered_nodes[cured_name] then
		return 
	end

	local placenode = {name = cured_name}
	if def.place_param2 then
		placenode.param2 = def.place_param2
	end

	minetest.swap_node(pos, placenode)
	--table.insert(farming.time_plantcured,1000*(os.clock()-starttime))
end

-- function for handle punching of a crop
-- if at last step than go back one step and give puncher one fruit
-- then start timer again
farming.punch_step = function(pos, node, puncher, pointed_thing)
	local starttime=os.clock()

	local def = minetest.registered_nodes[node.name]

	if def.groups.punchable == nil then
		return
	end

	-- only give fruit and go back if pre step is defined
	if def.pre_step == nil then
		return
	end

	if puncher ~= nil and puncher:get_player_name() ~= "" then
		-- give one item only if no billhook is used
		puncher:get_inventory():add_item('main',def.drop_item)
	end

	minetest.swap_node(pos, {name=def.pre_step,
		param2=def.place_param2 or 3})
	
	-- new timer needed?
	local pre_def=minetest.registered_nodes[def.pre_step]
	local meta = minetest.get_meta(pos)
	meta:set_int("farming:step",pre_def.groups.step)

	if pre_def.next_step then
		local waittime=math.random(pre_def.grow_time_min or 100, pre_def.grow_time_max or 200) * farming.factor_regrow
		minetest.get_node_timer(pos):start(math.random(pre_def.grow_time_min or 100, pre_def.grow_time_max or 200))
	end
	--table.insert(farming.time_plantpunch,1000*(os.clock()-starttime))
	return 
end

-- function for digging crops
-- if dug with scythe by change you harvest more
farming.dig_harvest = function(pos, node, digger)
	local starttime=os.clock()

	local def = minetest.registered_nodes[node.name]
	local tool_def = digger:get_wielded_item():get_definition()

	if tool_def.groups.scythe and def.drop_item then
		if tool_def.farming_change ~= nil then
			if math.random(1,tool_def.farming_change)==1 then
				digger:get_inventory():add_item('main',def.drop_item)
			end
		end
	end

--	print(dump(def.drop))
	minetest.node_dig(pos,node,digger)
	--table.insert(farming.time_digharvest,1000*(os.clock()-starttime))
end

-- timer function for infected plants
-- the step of plant is reduced till zero then the plant dies
-- nearby crops are infected by change given in configuration
-- normally in monoculture the infection rate is higher
farming.timer_infect = function(pos,elapsed)
--	local starttime=os.clock()
	local node = minetest.get_node(pos)

	local def = minetest.registered_nodes[node.name]
	local meta = minetest.get_meta(pos)
	-- if no step is saved in metadata (should not be, but...) , removing plant

	if meta:get_int("farming:step") == nil then
		minetest.swap_node(pos, {name="air"})
		return
	end

	-- if zero step is reached, plant dies
	if meta:get_int("farming:step") == 0 then
		minetest.swap_node(pos, {name="default:grass_"..math.random(1,4)})
		return
	end

	local infected = 0
	-- check for monoculture and infect nearby plants
	if def.infect_rate_monoculture ~= nil then
		local monoculture=minetest.find_nodes_in_area(vector.subtract(pos,2),vector.add(pos,2),"group:"..def.plant_name)
		if monoculture ~= nil then
			for i = 1,#monoculture do
				if math.random(1,math.max(2,def.infect_rate_monoculture))==1 then
					farming.plant_infect(monoculture[i])
					infected=infected+1
				end
			end
		end
	end

	-- if no monoculture plant was infected try other crops
	-- check for nearby other plants and infect them
	if infected == 0 then
		if def.infect_rate_base ~= nil then
			local culture=minetest.find_nodes_in_area(vector.subtract(pos,3),vector.add(pos,3),"group:infectable")
			if culture ~= nil then
				for i = 1,#culture do
					if math.random(1,math.max(2,def.infect_rate_base))==1 then
						farming.plant_infect(culture[i])
						infected=infected+1
					end
				end
			end
		end
	end

	meta:set_int("farming:step",meta:get_int("farming:step")-1)
	minetest.get_node_timer(pos):start(math.random(farming.wait_min,farming.wait_max))
	--table.insert(farming.time_infect,1000*(os.clock()-starttime))
end

-- timer function called for a step to grow
-- if enough light then grow to next step
-- if a following step or wilt is defined then calculate new time and set timer
farming.timer_step = function(pos, elapsed)
	local starttime=os.clock()

	local def = minetest.registered_nodes[minetest.get_node(pos).name]

	-- check for enough light
	if not def.next_step then
		return
	end

	local light = minetest.get_node_light(pos)
	local pdef=farming.registered_plants[def.plant_name]

	if not light or light < pdef.light_min or light > pdef.light_max then
		minetest.get_node_timer(pos):start(math.random(farming.wait_min, farming.wait_max))
		return
	end

	local next_def=minetest.registered_nodes[def.next_step]
	minetest.swap_node(pos, {name=def.next_step,
		param2=def.place_param2 or 3})
	local meta = minetest.get_meta(pos)

	if next_def.groups.farming_wilt ~= nil then
		if meta:get_int("farming:weakness") == nil then
			farming.set_node_metadata(pos)
		end
		meta:set_int("farming:weakness",math.ceil(meta:get_int("farming:weakness")/2))
	else
		meta:set_int("farming:step",next_def.groups.step)
	end
	
	if next_def.groups.farming_fullgrown ~= nil then
		meta:set_int("farming:seeds",1)
	else
		meta:set_int("farming:seeds",0)
	end

	-- new timer needed?
	local wait_factor = 1
	-- check for config values
	local lightamount=meta:get_int("farming:lightamount")

	if lightamount ~= nil then
		local ls = farming.light_stat[tostring(def.light_min)]
		if ls.amount ~= nil and lightamount > 0 then
			-- time till next step is stretched. Less light means longer growing time
			wait_factor = ls.amount / lightamount
		end
	else
		wait_factor = math.max(0.75,def.light_min/minetest.get_node_light(pos,0.5))
	end

	-- using light at midday to increase or decrease growing time
	local wait_min = math.ceil(def.grow_time_min * wait_factor)
	local wait_max = math.ceil(def.grow_time_max * wait_factor)
	if wait_max <= wait_min then wait_max = 2*wait_min end

	local timespeed=minetest.settings:get("time_speed")
	local time_wait=math.random(wait_min,wait_max)
	local local_rwt=time_wait*timespeed/(86400)
	local daystart=meta:get_float("farming:daystart")
	local acttime=minetest.get_timeofday()

	if math.abs(acttime+local_rwt-0.5)>(0.5-daystart) then
		time_wait=86400*(1+daystart-acttime)/timespeed
	end
	minetest.get_node_timer(pos):start(time_wait)
	--table.insert(farming.time_steptimer,1000*(os.clock()-starttime))
	return
end

-- Seed placement
-- adopted from minetest-game
farming.place_seed = function(itemstack, placer, pointed_thing, plantname)
	local starttime=os.clock()

	-- check if pointing at a node
	if not pointed_thing then
		return itemstack
	end

	if pointed_thing.type ~= "node" then
		return itemstack
	end

	-- check if pointing at the top of the node
	if pointed_thing.above.y ~= pointed_thing.under.y+1 then
		return itemstack
	end
	
	local player_name = placer and placer:get_player_name() or ""

	if minetest.is_protected(pointed_thing.under, player_name) then
		minetest.record_protection_violation(pointed_thing.under, player_name)
		return
	end
	if minetest.is_protected(pointed_thing.above, player_name) then
		minetest.record_protection_violation(pointed_thing.above, player_name)
		return
	end

	local under = minetest.get_node(pointed_thing.under)
	-- return if any of the nodes is not registered
	if not minetest.registered_nodes[under.name] then
		return itemstack
	end

	local above = minetest.get_node(pointed_thing.above)
	if not minetest.registered_nodes[above.name] then
		return itemstack
	end

	-- check if you can replace the node above the pointed node
	if not minetest.registered_nodes[above.name].buildable_to then
		return itemstack
	end

	local udef = minetest.registered_nodes[under.name]
	local pdef = minetest.registered_nodes[plantname]
	
	-- check if pointing at soil and seed needs soil
	if minetest.get_item_group(under.name,"soil") < 2 then
		if minetest.get_item_group(plantname,"on_soil") >= 1 then
			return
		else

			-- check if node is correct one
			local plant_def=farming.registered_plants[pdef.plant_name]
			-- check for correct temperature
			if pointed_thing.under.y < plant_def.elevation_min or pointed_thing.under.y > plant_def.elevation_max then
				minetest.chat_send_player(player_name,"Elevation must be between "..plant_def.elevation_min.." and "..plant_def.elevation_max)
				return
			end

			if minetest.get_heat(pointed_thing.under) < plant_def.temperature_min or minetest.get_heat(pointed_thing.under) > plant_def.temperature_max then
				minetest.chat_send_player(player_name,"Temperature "..minetest.get_heat(pt.under).." is out of range for planting.")
				return
			end

			if minetest.get_humidity(pointed_thing.under) < plant_def.humidity_min or minetest.get_humidity(pointed_thing.under) > plant_def.humidity_max then
				minetest.chat_send_player(player_name,"Humidity "..minetest.get_humidity(pt.under).." is out of range for planting.")
				return
			end
		end
	end

	-- add the node and remove 1 item from the itemstack
	minetest.add_node(pointed_thing.above, {name = plantname, param2 = 1})
	local wait_min=farming.wait_min or 120
	local wait_max=farming.wait_max or 240

	if pdef.grow_time_min then
		wait_min=pdef.grow_time_min
	end
	if pdef.grow_time_max then
		wait_max=pdef.grow_time_max
	end

	minetest.get_node_timer(pointed_thing.above):start(math.random(wait_min, wait_max))

	local meta = minetest.get_meta(pointed_thing.above)
	meta:set_int("farming:step",0)

	farming.set_node_metadata(pointed_thing.above,placer)

	if not (creative and creative.is_enabled_for
			and creative.is_enabled_for(player_name)) then
		itemstack:take_item()
	end
	--table.insert(farming.time_placeseed,1000*(os.clock()-starttime))
	return itemstack
end

-- timer function for growing seed
-- after the time out the first step of plant in placed
farming.timer_seed = function(pos, elapsed)
	local starttime=os.clock()

	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]

	local soil_node = minetest.get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})
	if not soil_node then
		minetest.get_node_timer(pos):start(math.random(farming.wait_min, farming.wait_max))
		return
	end

	-- omitted is a check for light, we assume seeds can germinate in the dark.
	local placenode = {name = def.next_step}
	if def.place_param2 then
		placenode.param2 = def.place_param2 or 3
	end

	minetest.swap_node(pos, placenode)
	local meta = minetest.get_meta(pos)

	if def.next_step then
		meta:set_int("farming:step",minetest.registered_nodes[def.next_step].groups.step)

		-- using light at midday to increase or decrease growing time
		local local_light_max = minetest.get_node_light(pos,0.5)
		local wait_factor = math.max(0.75,def.light_min/local_light_max)
		local wait_min = math.ceil(def.grow_time_min * wait_factor)
		local wait_max = math.ceil(def.grow_time_max * wait_factor)
		if wait_max <= wait_min then wait_max = 2*wait_min end

		local node_timer=math.random(wait_min, wait_max)
		minetest.get_node_timer(pos):start(node_timer)
		return
	end
	--table.insert(farming.time_seedtimer,1000*(os.clock()-starttime))
end

-- timer function for wilt plants
-- normal plants will die after the time
-- weed like nettles can spread to neighbour places
farming.timer_wilt = function(pos, elapsed)
	local starttime=os.clock()

	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]

	if def.groups.wiltable == 3 then -- nettle or weed
		-- determine all nearby nodes with soil
		local farming_nearby=minetest.find_nodes_in_area(vector.subtract(pos,2),vector.add(pos,2),"group:farming")
		-- within radius 2 not more than 4 nettles should be for further spreading
		if #farming_nearby <= 4 then
			local neighb=minetest.find_nodes_in_area(vector.subtract(pos,2),vector.add(pos,2),"group:soil")
			if neighb ~= nil then
				local freen={}
				-- get soil nodes with air above
				for j=1,#neighb do
					local jpos=neighb[j]
					if basic_functions.has_value({"air","default:grass_1","default:grass_2","default:grass_3","default:grass_4","default:grass_5"},minetest.get_node({x=jpos.x,y=jpos.y+1,z=jpos.z}).name) then
						table.insert(freen,1,jpos)
					end
				end

				-- randomly pick one and spread
				if #freen >= 1 then
					local npos={x=jpos.x,y=jpos.y+1,z=jpos.z}
					local jpos=freen[math.random(1,#freen)]
					minetest.add_node(npos, {name = def.seed_name, param2 = 1})
					farming.set_node_metadata(npos)
					minetest.get_node_timer(npos):start(def.grow_time_min or 10)
				end
			end
		end

		-- after spreading the source can be removed, go back one step or stay
		-- with higher change to be removed if already several similar plants are nearby
		local wran=math.random(1,math.max(3,#farming_nearby))
		if wran >= 3 then
			minetest.swap_node(pos, {name="air"})
		end
		if wran == 2 then
			if def.pre_step ~= nil then
				minetest.swap_node(pos, {name=def.pre_step, param2=1})
				minetest.get_node_timer(pos):start(math.random(def.grow_time_min or 10,def.grow_time_max or 20))
			end
		end
		if wran == 1 then
			minetest.get_node_timer(pos):start(math.random(def.grow_time_min or 10,def.grow_time_max or 20))
		end
	else --normal crop
		minetest.set_node(pos, {name="air"})
		minetest.add_node(pos, {name="default:grass_"..math.random(1,5),param2=1})
	end
	--table.insert(farming.time_wilttimer,1000*(os.clock()-starttime))
end


farming.seed_on_place = function(itemstack, placer, pointed_thing)
	local node = minetest.get_node(pointed_thing.under)
	local udef = minetest.registered_nodes[node.name]
	local plantname = itemstack:get_name()
	if udef and udef.on_rightclick and
			not (placer and placer:is_player() and
			placer:get_player_control().sneak) then
		return udef.on_rightclick(pointed_thing.under, node, placer, itemstack,
			pointed_thing) or itemstack
	end
	return farming.place_seed(itemstack, placer, pointed_thing, plantname)
end

-- using tools
-- adopted from minetest-games
farming.dig_by_tool = function(itemstack, user, pointed_thing, uses)
	local starttime=os.clock()
	-- check if pointing at a node
	if not pointed_thing then
		return
	end

	local under = minetest.get_node(pointed_thing.under)
	local p = {x=pointed_thing.under.x, y=pointed_thing.under.y+1, z=pointed_thing.under.z}
	local above = minetest.get_node(p)

	-- return if any of the nodes is not registered
	if not minetest.registered_nodes[under.name] then
		return
	end
	if not minetest.registered_nodes[above.name] then
		return
	end

	-- check if the node above the pointed thing is air
	if above.name ~= "air" then
		return
	end

	if minetest.is_protected(pointed_thing.under, user:get_player_name()) then
		minetest.record_protection_violation(pointed_thing.under, user:get_player_name())
		return
	end
	if minetest.is_protected(pointed_thing.above, user:get_player_name()) then
		minetest.record_protection_violation(pointed_thing.above, user:get_player_name())
		return
	end
	if not (creative and creative.is_enabled_for
			and creative.is_enabled_for(user:get_player_name())) then
		-- wear tool
		local wdef = itemstack:get_definition()
		itemstack:add_wear(65535/(wdef.max_uses-1))
		minetest.node_dig(pt.under,under,user)
		-- tool break sound
		if itemstack:get_count() == 0 and wdef.sound and wdef.sound.breaks then
			minetest.sound_play(wdef.sound.breaks, {pos = pointed_thing.above, gain = 0.5})
		end
	end
	--table.insert(farming.time_tooldig,1000*(os.clock()-starttime))
	return itemstack
end

farming.use_picker = function(itemstack, user, pointed_thing,uses)
	local starttime=os.clock()
	-- check if pointing at a node
	if not pointed_thing then
		return
	end
	if pointed_thing.type ~= "node" then
		return
	end
	local pos = pointed_thing.under
	local under = minetest.get_node(pos)
	-- return if any of the nodes is not registered
	if not minetest.registered_nodes[under.name] then
		return
	end

	if minetest.is_protected(pos, user:get_player_name()) then
		minetest.record_protection_violation(pos, user:get_player_name())
		return
	end

	local pdef=minetest.registered_nodes[under.name]
	-- check if pointing at punchable crop
	if pdef.groups.punchable == nil then
		return
	end
	-- check if plant is full grown
	if pdef.groups.farming_fullgrown == nil then
		return
	end
	-- check if seeds can be extracted
	if pdef.groups.seed_extractable == nil then
		return
	end
	-- check if seeds are available
	local meta = minetest.get_meta(pos)
	if meta:get_int("farming:seeds") == nil then
		meta:set_int("farming:seeds",0)
		return
	else
		if meta:get_int("farming:seeds")==0 then
			return
		end
	end
	
	local tdef=itemstack:get_definition()
	if not (creative and creative.is_enabled_for
			and creative.is_enabled_for(user:get_player_name())) then
		-- wear tool
		itemstack:add_wear(65535/(uses-1))
		-- tool break sound
		if itemstack:get_count() == 0 and tdef.sound and tdef.sound.breaks then
			minetest.sound_play(tdef.sound.breaks, {pos = pointed_thing.above, gain = 0.5})
		end
	end
	user:get_inventory():add_item('main',pdef.seed_name)
	if math.random(1,3)==1 then
		user:get_inventory():add_item('main',pdef.seed_name)
	end
	-- call punching function of crop: normally go back one step and start timer
	minetest.punch_node(pointed_thing.under)
	local meta = minetest.get_meta(pos)
	meta:set_int("farming:seeds",0)

	--table.insert(farming.time_usehook,1000*(os.clock()-starttime))
	return itemstack
end
-- function for using billhook on punchable fruits
-- add wear to billhook and give player by change one more fruit
farming.use_billhook = function(itemstack, user, pointed_thing, uses)
	local starttime=os.clock()
	-- check if pointing at a node
	if not pointed_thing then
		return
	end
	if pointed_thing.type ~= "node" then
		return
	end
	local under = minetest.get_node(pointed_thing.under)
	-- return if any of the nodes is not registered
	if not minetest.registered_nodes[under.name] then
		return
	end

	local pdef=minetest.registered_nodes[under.name]
	-- check if pointing at punchable crop
	if pdef.groups.punchable == nil then
		return
	end
	-- check if plant is full grown
	if pdef.groups.farming_fullgrown == nil then
		return
	end
	if minetest.is_protected(pointed_thing.under, user:get_player_name()) then
		minetest.record_protection_violation(pointed_thing.under, user:get_player_name())
		return
	end

	local tdef=itemstack:get_definition()
	if not (creative and creative.is_enabled_for
			and creative.is_enabled_for(user:get_player_name())) then
		-- wear tool
		itemstack:add_wear(65535/(uses-1))
		-- tool break sound
		if itemstack:get_count() == 0 and tdef.sound and tdef.sound.breaks then
			minetest.sound_play(tdef.sound.breaks, {pos = pointed_thing.above, gain = 0.5})
		end
	end
	user:get_inventory():add_item('main',pdef.drop_item)
	if tdef.farming_change ~= nil then
		if math.random(1,tdef.farming_change)==1 then
			user:get_inventory():add_item('main',pdef.drop_item)
		end
	end
	-- call punching function of crop: normally go back one step and start timer
	minetest.punch_node(pointed_thing.under)
	--table.insert(farming.time_usehook,1000*(os.clock()-starttime))
	return itemstack
end

-- calculate light amount on a position for a given light_min
farming.calc_light=function(pos,pdef)
	local starttime=os.clock()
	-- calculating 
	local day_start=99999
	local light_amount=0
	local light_min=pdef.light_min
	
	-- run from 5:00 till 12:00 in 6min steps
	for i=50,120 do
		local reli=i/240
		local nl=minetest.get_node_light(pos,reli)
		if nl>light_min then
			light_amount=light_amount+nl
			if day_start > 1000 then day_start = i end
		end
	end
	
	if day_start > 240 then
		day_start=120
	end
	
	--table.insert(farming.time_calclight,1000*(os.clock()-starttime))
	local outdata={day_start=day_start,
			light_amount=light_amount,
			}
			
	return outdata
end

-- calculate several meta data for a node and save in node storage
farming.set_node_metadata=function(pos,player)
	local starttime=os.clock()
	local base_rate = 5
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	local pdef = farming.registered_plants[def.plant_name]
	local ill_rate=base_rate * (pdef.light_max-minetest.get_node_light(pos,0.5))/(pdef.light_max-pdef.light_min)
	local player_meta=99
	if player ~= nil then
		player_meta=player:get_meta()
	end
	-- calc coeff for temperature
	local ill_temp=(base_rate * math.sqrt(math.min(minetest.get_heat(pos)-pdef.temperature_min,pdef.temperature_max-minetest.get_heat(pos))/(pdef.temperature_max-pdef.temperature_min)))
	-- negative coeff means, it is out of range
	if ill_temp < 0 then
		ill_temp = (ill_temp * (-0.75))
	end

	-- calc coeff for humidity
	local ill_hum=(base_rate * math.sqrt(math.min(minetest.get_humidity(pos)-pdef.humidity_min,pdef.humidity_max-minetest.get_humidity(pos))/(pdef.humidity_max-pdef.humidity_min)))
	-- negative coeff means, it is out of range
	if ill_hum < 0 then
		ill_hum = (ill_hum * (-0.75))
	end

	local infect_rate = 1
	if pdef.groups.infectable then
		infect_rate = pdef.groups.infectable
	end

	ill_rate = math.ceil((ill_rate + ill_temp + ill_hum)/infect_rate)
	if player_meta <> 99 then
		if player_meta:get_int("xp:farming") ~= nil then
			ill_rate = math.ceil(ill_rate * player_meta:get_int("xp:farming"))
		end
	end
	local meta = minetest.get_meta(pos)

	-- weakness as rate, how easily a crop can be infected
	meta:set_int("farming:weakness",ill_rate)
	-- healthiness as mechanism to controll if a crop will be infected
	meta:set_int("farming:healthiness",50+ill_rate)
	
	local lightcalc=farming.calc_light(pos,pdef)
	-- daytime, when light reach light_min
	meta:set_float("farming:daystart",lightcalc.day_start/240)
	-- amount of light the crop gets till midday
	meta:set_int("farming:lightamount",lightcalc.light_amount)
	-- init the amount of seed available at the crop
	meta:set_int("farming:seeds",0)
	--table.insert(farming.time_setmeta,1000*(os.clock()-starttime))
end
