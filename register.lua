local S = farming.intllib

-- helping function for getting biomes
farming.get_biomes = function(biom_def)
--[[
  catch all biomes out of minetest.registered_biomes which fit definition
]]
	local possible_biomes={}
	local count_def=0
	if (biom_def.min_temp ~= nil or biom_def.max_temp ~= nil) then
	  count_def = count_def + 1
	end
	if (biom_def.min_humidity ~= nil or biom_def.max_humidity ~= nil) then
	  count_def = count_def + 1
	end
	if biom_def.spawnon then
		if (biom_def.min_humidity ~= nil or biom_def_max_humidity ~= nil) then
		  count_def = count_def + 1
		end
	end
	
	-- check definition: if not set, choose values, which should fit all biomes
	local mintemp = biom_def.min_temp or -100
	local maxtemp = biom_def.max_temp or 1000
	local minhum = biom_def.min_humidity or -100
	local maxhum = biom_def.max_humidity or 1000
	local minelev = biom_def.spawnon.spawn_min or 0
	local maxelev = biom_def.spawnon.spawn_max or 31000
	for name,def in pairs(minetest.registered_biomes) do
	  local bpossible = 0
	  if def.heat_point >= mintemp and def.heat_point <= maxtemp then
	    bpossible = bpossible + 1
	  end
	  if def.humidity_point >= minhum and def.humidity_point <= maxhum then
	    bpossible = bpossible + 1
	  end
	  if def.y_min <= maxelev and def.y_max >= minelev then
	    bpossible = bpossible + 1
	  end
	  if bpossible == count_def then
	    table.insert(possible_biomes,1,name)
	  end
	end
	return possible_biomes
end

-- function to check definition
-- and set to defaults values
local register_plant_check_def = function(def)
	if not def.description then
		def.description = "Seed"
	end
	if not def.inventory_image then
		def.inventory_image = "unknown_item.png"
	end
	-- minimum of light needed for growing
	if not def.minlight then
		def.minlight = 1
	end
	if not def.maxlight then
		def.maxlight = 14
	end
	if not def.fertility then
		def.fertility = {}
	end
	if not def.max_harvest then
	  def.max_harvest = 2
	end
	if not def.mean_grow_time then
	  def.mean_grow_time=math.random(farming.wait_min,farming.wait_max)
	end
	if not def.range_grow_time then
	  def.range_grow_time=math.random(0,farming.wait_max-farming.wait_min)
	end
	if def.range_grow_time > def.mean_grow_time then
	  def.range_grow_time = math.floor(def.mean_grow_time / 2)
	end
	def.min_grow_time=math.floor(def.mean_grow_time-def.range_grow_time)
	def.max_grow_time=math.floor(def.mean_grow_time+def.range_grow_time)
--	if not def.eat_hp then
--	  def.eat_hp = 1
--	end
	local spawn = true
    if (not def.spawnon) or (def.groups["no_spawn"]) then
      def.spawnon = nil
      def.groups["no_spawn"] = 1
      spawn = false
    end
	if def.spawnon and spawn then
		def.spawnon.spawnon=def.spawnon.spawnon or {"default:dirt_with_grass"}
		def.spawnon.spawn_min = def.spawnon.spawn_min or 0
		def.spawnon.spawn_max = def.spawnon.spawn_max or 42
		def.spawnon.spawnby = def.spawnon.spawn_by or nil
		def.spawnon.scale = def.spawnon.scale or farming.rarety
		def.spawnon.offset = def.spawnon.offset or 0.02
		def.spawnon.spawn_num = def.spawnon.spawn_num or -1
	end
	if def.spread then
	  def.spread.spreadon = def.spread.spreadon or {"default:dirt_with_grass"}
	  def.spread.base_rate = def.spread.base_rate or 10
	  def.spread.spread = def.spread.spread or 5
	  def.spread.intervall = def.spread.intervall or 120
	  def.spread.change = def.spread.change or 0.00001
	  def.spread.inv_change = math.ceil(1/def.spread.change)
	end
	local infect = false
	if (def.infect) or (def.groups["infectable"]) then
		def.infect = {}
		def.groups["infectable"] = 1
	end
	if def.infect then
	  def.infect.base_rate = def.infect.base_rate or 10
	  def.infect.mono_rate = def.infect.mono_rate or 10
	  def.infect.infect_rate = def.infect.infect_rate or 10
	  def.infect.intervall = def.infect.intervall or 120
	end
  return def
end


farming.register_harvest=function(hdef)
	local harvest_def={
		description = S(hdef.description:gsub("^%l", string.upper)),
		inventory_image = hdef.harvest_png,
		groups = hdef.groups or {flammable = 2},
	}
	for _,coln in ipairs({"plant_name","seed_name","harvest_name"}) do
	  harvest_def[coln] = hdef[coln]
	end

	if not harvest_def.groups["harvest"] then
	  harvest_def.groups["harvest"] = 1
	end
	--print(dump(harvest_def))
	minetest.register_craftitem(":" .. hdef.harvest_name, harvest_def)
end

farming.register_infect=function(idef)
	local infect_def={
		description = S(idef.description:gsub("^%l", string.upper)),
		inventory_image = idef.mod_name.."_"..idef.plant_name.."_ill.png",
		groups = idef.groups or {flammable = 2,ill=2},
		tiles = {idef.mod_name.."_"..idef.plant_name.."_ill.png"},
		wield_image = {idef.mod_name.."_"..idef.plant_name.."_ill.png"},
		drawtype = "plantlike",
		waving = 1,
		paramtype = "light",
		walkable = false,
		buildable_to = true,
		on_dig = farming.plant_cured ,
		selection_box = {type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},},
		sounds = default.node_sound_leaves_defaults(),
	}
	for _,coln in ipairs({"plant_name","seed_name","step_name","harvest_name","place_param2","fertility","description","spawnon"}) do
	  infect_def[coln] = idef[coln]
	end

	infect_def.groups = {seed = 1, snappy = 3, attached_node = 1, flammable = 2,ill=2}
	infect_def.groups[infect_def.plant_name] = -1
	minetest.register_node(":" .. idef.plant_name.."_infected", infect_def)
	print(dump(infect_def))
	local abm_def = {
		nodenames = {"group:"..idef.plant_name},
		intervall = idef.infect.intervall + math.random(-1,1), -- little noise
		change = idef.infect.base_rate,
		action = function(pos)
			local base_rate = minetest.get_node_light(pos,0.5) -- get light at midday
			local infected_neighbours = #minetest.find_nodes_in_area(vector.subtract(pos,4),vector.add(pos,4),"group:ill")
			local mono_rate = #minetest.find_nodes_in_area(vector.subtract(pos,4),vector.add(pos,4),"group:"..idef.plant_name)
			local test_rate = idef.infect.base_rate / infected_neighbours
			if mono_rate > 2 then
				test_rate = test_rate * idef.infect.mono_rate
			else
				test_rate = test_rate * idef.infect.base_rate
			end
			if math.random(0,test_rate)<1 then
				farming.plant_infect(pos)
			end
			end,
		}
	minetest.register_abm(abm_def)
	local abm_def = {
		nodenames = {"group:"..idef.plant_name},
		neighbors = {"group:ill"},
		intervall = idef.infect.intervall + math.random(-1,1),
		change = 1,
		action = function(pos)
			local base_rate = minetest.get_node_light(pos,0.5) -- get light at midday
			local infected_neighbours = #minetest.find_nodes_in_area(vector.subtract(pos,4),vector.add(pos,4),"group:ill")
			local test_rate = idef.infect.infect_rate * #minetest.find_nodes_in_area(vector.subtract(pos,4),vector.add(pos,4),"group:"..idef.plant_name)
			if math.random(0,test_rate)<1 then
				farming.plant_infect(pos)
			end
			end,
		}
	print(dump(abm_def))
	minetest.register_abm(abm_def)
end


farming.register_seed=function(sdef)
    local seed_def = {
		drawtype = "signlike",
		paramtype = "light",
		paramtype2 = "wallmounted",
		walkable = false,
		sunlight_propagates = true,
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
		},
		sounds = default.node_sound_dirt_defaults({
			dig = {name = "", gain = 0},
			dug = {name = "default_grass_footstep", gain = 0.2},
			place = {name = "default_place_node", gain = 0.25},
		}),
		next_step = sdef.harvest_name .. "_1",
		on_place = farming.seed_on_place,
		on_timer = farming.seed_on_timer,
	}
	for i,colu in ipairs({"inventory_image","minlight","maxlight","place_param2","fertility","description","spawnon","plant_name","seed_name","harvest_name"}) do
	  seed_def[colu] = sdef[colu]
	end
	seed_def.tiles = {sdef.inventory_image}
	seed_def.wield_image = {sdef.inventory_image}
	seed_def.groups = {seed = 1, snappy = 3, attached_node = 1, flammable = 2}
	seed_def.groups[sdef.plant_name] = 0
	for k, v in pairs(sdef.fertility) do
		seed_def.groups[v] = 1
	end
	if sdef.groups["on_soil"] then
	  seed_def.groups["on_soil"] = sdef.groups["on_soil"]
	end
	if sdef.eat_hp then
	  seed_def.on_use=minetest.item_eat(sdef.eat_hp)
	end
	minetest.register_node(":" .. sdef.seed_name, seed_def)
end

farming.register_steps = function(pname,sdef)
	-- check if plant gives harvest, where seed can be extractet or gives directly seed
    local has_harvest = true
    if sdef.groups["no_harvest"] then 
      has_harvest = false
    end
    -- check if plant give seeds if punched. then drop table is quite simple
    local is_punchable = false
    if sdef.groups["punchable"] then
      is_punchable = true
    end
    -- check if cultured plant exist
    local has_next_plant = false
    if sdef.next_plant then
      has_next_plant = true
    end

    -- base configuration of each step
	local node_def = {
		drawtype = "plantlike",
		waving = 1,
		paramtype = "light",
		walkable = false,
		buildable_to = true,
		selection_box = {type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},},
		sounds = default.node_sound_leaves_defaults(),
	}
	-- copy some plant definition into definition of this steps
	for _,colu in ipairs({"paramtype2","place_param2","minlight","maxlight","seed_name","plant_name","harvest_name"}) do
	  if sdef[colu] then
	    node_def[colu] = sdef[colu]
	  end
	end
	-- define drop item: normal drop the seed
	local drop_item = sdef.seed_name
	-- if plant has to be harvested, drop harvest instead
	if has_harvest then
	  drop_item = sdef.harvest_name
	end
	local lbm_nodes = {sdef.seed_name}
	for i=1,sdef.steps do
	    local ndef={}
	    for _,colu in ipairs({"minlight","maxlight","sounds","selection_box","drawtype","waving","paramtype","paramtype2","place_param2",
				"walkable","buildable_to","seed_name","plant_name","harvest_name"}) do
			ndef[colu]=node_def[colu]
		end
		ndef.groups = {snappy = 3, flammable = 2,flora=1, plant = 1, not_in_creative_inventory = 1, attached_node = 1, farming = 1}
		if sdef["snappy"] then
		  ndef.groups["snappy"] = sdef["snappy"]
		end
		ndef.groups[pname] = i
		ndef.tiles={sdef.mod_name.."_"..sdef.plant_name.."_"..i..".png"}
		if i < sdef.steps then
			ndef.next_step=sdef.step_name .. "_" .. (i + 1)
			lbm_nodes[#lbm_nodes + 1] = sdef.step_name .. "_" .. i
			ndef.on_timer = farming.step_on_timer
			if sdef.infect then
				ndef.on_punch = farming.plant_infect 
			end
		end
		local base_rarity = 1
		if sdef.steps ~= 1 then
			base_rarity =  8 - (i - 1) * 7 / (sdef.steps - 1)
		end
		ndef.drop={items={{items={drop_item}}}}

		local base_rarity = 1
		if sdef.steps ~= 1 then
			base_rarity =  sdef.steps - i + 1
		end

		-- with higher grow levels you harvest more
		local step_harvest = math.floor(i*sdef.max_harvest/sdef.steps + 0.05)
		if step_harvest > 1 then
		  for h = 2,step_harvest do
			table.insert(ndef.drop.items,1,{items={drop_item},rarity=base_rarity*h})
		  end
		end
		if i == sdef.steps then
		  ndef.on_dig = farming.harvest_on_dig
		end
		-- at the end stage you can harvest by change a cultured seed (if defined)
		if (i == sdef.steps and sdef.next_plant ~= nil) then
		  sdef.next_plant_rarity = sdef.next_plant_rarity or base_rarity*2
		  table.insert(ndef.drop.items,1,{items={sdef.next_plant},rarity=sdef.next_plant_rarity})
		end
		if i == sdef.steps and is_punchable then
		    ndef.pre_step = sdef.step_name .. "_" .. (i - 1)
			ndef.on_punch = farming.step_on_punch
		end
--		print(dump(ndef))
		minetest.register_node(":" .. sdef.step_name .. "_" .. i, ndef)
	end
	farming.register_lbm(lbm_nodes,sdef)
end

farming.register_lbm = function(lbm_nodes,def)
	-- replacement LBM for pre-nodetimer plants
	minetest.register_lbm({
		name = ":" .. def.mod_name .. ":start_nodetimer_" .. def.plant_name,
		nodenames = lbm_nodes,
		action = function(pos, node)
				minetest.get_node_timer(pos):start(math.random(farming.wait_min,farming.wait_max))
		end,
	})
end

farming.register_abm = function(mdef)
	local rand_change = 50
	if mdef.spread then
	  if mdef.spread.base_rate then
	    rand_change = mdef.spread.base_rate
	  end
	end
	if mdef.spread then
		-- random spread of plant on surface.
		minetest.register_abm({
			nodenames = mdef.spread.spreadon,
			neighbors = {"air"},
			interval = mdef.spread.intervall+math.random(-1,1), -- little noise
			chance = rand_change,
			action = function(pos)
				local ptabove={x=pos.x,y=pos.y+1,z=pos.z}
				local above = minetest.get_node(ptabove)
				if above.name ~= "air" then
					return
				end
				if minetest.get_node_light(ptabove) < mdef.minlight then
					return
				end
				local ymin=0
				local ymax=31000
				if mdef.spawnon then
					ymin=mdef.spawnon.spawn_min or 0
					ymax=mdef.spawnon.spawn_max or 31000
				end
				if (ptabove.y < ymin or ptabove.y > ymax ) then
					return
				end
				local pos0 = vector.subtract(pos,4)
				local pos1 = vector.add(pos,4)
				-- only for positions, where not too many plants are nearby
				if #minetest.find_nodes_in_area(pos0,pos1,"group:"..mdef.plant_name) > 2 then
					return
				end
				if math.random(0,mdef.spread.inv_change) < 1 then
					minetest.add_node(ptabove, {name=mdef.harvest_name.."_1"})
					minetest.get_node_timer(pos):start(math.random(mdef.min_grow_time or 100, mdef.max_grow_time or 200))
				end
			end,
		})
		-- spread for full-grown plant
		minetest.register_abm({
			nodenames =mdef.spread.spreadon ,
			neighbours=mdef.harvest_name.."_"..mdef.steps,
			interval = mdef.spread.intervall + math.random(-1,1), --little noise
			chance = mdef.spread.spread,
			action = function(pos)
				local ptabove={x=pos.x,y=pos.y+1,z=pos.z}
				local above = minetest.get_node(ptabove)
				if above.name ~= "air" then
					return
				end
				if minetest.get_node_light(ptabove) < mdef.minlight then
					return
				end
				local ymin=0
				local ymax=31000
				if mdef.spawnon then
					ymin=mdef.spawnon.spawn_min or 0
					ymax=mdef.spawnon.spawn_max or 31000
				end
				if (ptabove.y < ymin or ptabove.y > ymax ) then
					return
				end
				if math.random(0,mdef.spread.inv_change) < 1 then
					minetest.add_node(ptabove, {name=mdef.harvest_name.."_1"})
					minetest.get_node_timer(pos):start(math.random(mdef.min_grow_time or 100, mdef.max_grow_time or 200))
				end
			end,
		})
	end
end
farming.register_mapgen = function(mdef)
    -- register mapgen
    if mdef.groups.no_spawn == nil then
		local deco_def={
			deco_type = "simple",
			place_on = mdef.spawnon.spawnon,
			sidelen = 16,
			noise_params = {
				offset = mdef.spawnon.offset,
				scale = mdef.spawnon.scale, -- 0.006,
				spread = {x = 200, y = 200, z = 200},
				seed = 329,
				octaves = 3,
				persist = 0.6
			},
			y_min = mdef.spawnon.spawn_min,
			y_max = mdef.spawnon.spawn_max,
			decoration = mdef.wildname or mdef.step_name.."_"..mdef.steps,
			spawn_by = mdef.spawnon.spawnby,
			num_spawn_by = mdef.spawnon.spawn_num,
--			biomes = farming.get_biomes(def)
		}
		minetest.register_decoration(deco_def)
--	  end
	end
end

-- Register plants
farming.register_plant = function(name, def)
	-- Check def table
	if not def.steps then
		return nil
	end
	-- check definition
    def = register_plant_check_def(def)
    
	-- local definitions
	def.mod_name = name:split(":")[1]
	def.plant_name = name:split(":")[2]
	def.harvest_name=def.mod_name..":"..def.plant_name
	def.step_name=def.mod_name..":"..def.plant_name
	def.seed_name=def.mod_name..":seed_"..def.plant_name

	-- check if plant gives harvest, where seed can be extractet or gives directly seed
    local has_harvest = true
    if def.groups["no_harvest"] then 
      has_harvest = false
    end
    -- check if plant give seeds if punched. then drop table is quite simple
    local is_punchable = false
    if def.groups["punchable"] then
      is_punchable = true
    end
    -- check if plant can get ill
    local is_infectable = false
    if def.groups["infectable"] then
      is_infectable = true
    end
    -- check if cultured plant exist
    local has_next_plant = false
    if def.next_plant then
      has_next_plant = true
    end
    local spawns = true
    
    -- if plant has harvest then registering
    if has_harvest then
      def.harvest_png=def.mod_name.."_"..def.plant_name..".png"
      farming.register_harvest(def)
    else
      def.harvest_name=def.seed_name
    end
    
   	farming.registered_plants[def.plant_name] = def
    
    farming.register_seed(def)

	farming.register_steps(def.plant_name,def)
	
--	if (def.spawnon) then
--		farming.register_mapgen(def)
--	end
	if (def.spread) and (not def.groups["no_spawn"]) then
		local spread_def={name=def.step_name.."_1",
				temp_min=def.min_temp,temp_max=def.max_temp,
				hum_min=def.min_humidity,hum_max=def.max_humidity,
				y_min=0,y_max=31000,base_rate = def.spread.base_rate}
		if (def.spawnon) then
			spread_def.y_min=def.spawnon.spawn_min
			spread_def.y_max=def.spawnon.spawn_max
		end
		table.insert(farming.spreading_crops,1,spread_def)
	end
	
    if is_infectable then
      farming.register_infect(def)
    end
end

farming.register_billhook = function(name,def)
  if not def.groups["billhook"] then
	def.groups["billhook"]=1
  end
  if not def.material then
    return
  end
  if not def.recipe then
	def.recipe = {
		{"", def.material, def.material},
		{"", "group:stick", ""},
		{"group:stick", "", ""} }
  end
  farming.register_tool(name,def)
end

farming.register_scythe = function(name,def)
  if not def.groups["scythe"] then
	def.groups["scythe"]=1
  end
  if not def.material then
    return
  end
  if not def.recipe then
	def.recipe = {
		{def.material, def.material, "group:stick"},
		{def.material, "group:stick", ""},
		{"group:stick", "", ""} }
  end
  farming.register_tool(name,def)
end

-- Register new Scythes
farming.register_tool = function(name, def)
	-- recipe has to be provided
	if not def.recipe then
		return
	end
	-- Check for : prefix (register new hoes in your mod's namespace)
	if name:sub(1,1) ~= ":" then
		name = ":" .. name
	end
	-- Check def table
	if def.description == nil then
		def.description = "Farming tool"
	end
	if def.inventory_image == nil then
		def.inventory_image = "unknown_item.png"
	end
	if def.max_uses == nil then
		def.max_uses = 30
	end
	def.sound={breaks = "default_tool_breaks"}
--	def.on_dig = function(itemstack, user, pointed_thing)
--		return farming.tool_on_dig(itemstack, user, pointed_thing, def.max_uses)
--	end

	-- Register the tool
	minetest.register_tool(name, def)
	-- Register its recipe
	minetest.register_craft({
		output = name:sub(2),
		recipe = def.recipe
	})
end

farming.plant_infect = function(pos)
	local node = minetest.get_node(pos)
	local name = node.name
	local def = minetest.registered_nodes[name]
	local meta = minetest.get_meta(pos)
	local infect_name=def.plant_name.."_infected"
	if not minetest.registered_nodes[infect_name] then
		return 
	end
	local meta = minetest.get_meta(pos)
	meta:set_int("farming:step",def.groups[def.plant_name])
	local placenode = {name = infect_name}
	if def.place_param2 then
		placenode.param2 = def.place_param2
	end
	minetest.swap_node(pos, placenode)
	meta:set_int("farming:step",def.groups[def.plant_name])
	local placenode = {name = infect_name}
end
farming.plant_cured = function(pos)
	local node = minetest.get_node(pos)
	local name = node.name
	local def = minetest.registered_nodes[name]
	local meta = minetest.get_meta(pos)
	local cured_step=meta:get_int("farming:step")
	print(cured_step)
	local cured_name=def.step_name.."_"..cured_step
	print(cured_name)
	if not minetest.registered_nodes[cured_name] then
		return 
	end
	local placenode = {name = cured_name}
	if def.place_param2 then
		placenode.param2 = def.place_param2
	end
	minetest.swap_node(pos, placenode)
end

farming.step_on_punch = function(pos, node, puncher, pointed_thing)
	local node = minetest.get_node(pos)
	local name = node.name
	local def = minetest.registered_nodes[name]
	local meta = minetest.get_meta(pos)
	-- grow
	local pre_node = def.pre_step
	local placenode = {name = pre_node}
	if def.place_param2 then
		placenode.param2 = def.place_param2
	end
	minetest.swap_node(pos, placenode)
	puncher:get_inventory():add_item('main',def.seed_name)
	-- getting one more when using billhook
	local tool_def = puncher:get_wielded_item():get_definition()
--	print(tool_def.max_uses)
	if tool_def.groups["billhook"] then
  	  puncher:get_inventory():add_item('main',def.seed_name)
	end
	-- new timer needed?
	local pre_def=minetest.registered_nodes[pre_node]
	local meta = minetest.get_meta(pos)
	meta:set_int("farming:step",pre_def.groups[pre_def.plant_name])
	if pre_def.next_step then
		minetest.get_node_timer(pos):start(math.random(pre_def.min_grow_time or 100, pre_def.max_grow_time or 200))
	end
	return 
end

farming.harvest_on_dig = function(pos, node, digger)
	local node = minetest.get_node(pos)
	local name = node.name
	local def = minetest.registered_nodes[name]
	local tool_def = digger:get_wielded_item():get_definition()
	if (def.next_plant == nil) and (tool_def.groups["scythe"]) then
	  local plant_def=farming.registered_plants[def.plant_name]
   	  digger:get_inventory():add_item('main',plant_def.harvest_name)
	end
  minetest.node_dig(pos,node,digger)
end

farming.step_on_timer = function(pos, elapsed)
	local node = minetest.get_node(pos)
	local name = node.name
	local def = minetest.registered_nodes[name]
	-- check for enough light
	local below = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
	local light = minetest.get_node_light(pos)
	if not def.next_step then
		return
	end
	if not light or light < def.minlight or light > def.maxlight then
		minetest.get_node_timer(pos):start(math.random(farming.wait_min, farming.wait_max))
		return
	end
	-- grow
	local placenode = {name = def.next_step}
	if def.place_param2 then
		placenode.param2 = def.place_param2
	end
	minetest.swap_node(pos, placenode)
	local meta = minetest.get_meta(pos)
	meta:set_int("farming:step",def.groups[def.plant_name])
	-- new timer needed?
	if def.next_step then
		local def_next=minetest.registered_nodes[def.next_step]
		minetest.get_node_timer(pos):start(math.random(def_next.min_grow_time or 100, def_next.max_grow_time or 200))
	end
	return
end

-- Seed placement
-- adopted from minetest-game
farming.place_seed = function(itemstack, placer, pointed_thing, plantname)
	local pt = pointed_thing
	-- check if pointing at a node
	if not pt then
		return itemstack
	end
	if pt.type ~= "node" then
		return itemstack
	end

	local under = minetest.get_node(pt.under)
	local above = minetest.get_node(pt.above)
	local udef = minetest.registered_nodes[under.name]
	local pdef = minetest.registered_nodes[plantname]
	local player_name = placer and placer:get_player_name() or ""

	if minetest.is_protected(pt.under, player_name) then
		minetest.record_protection_violation(pt.under, player_name)
		return
	end
	if minetest.is_protected(pt.above, player_name) then
		minetest.record_protection_violation(pt.above, player_name)
		return
	end

	-- return if any of the nodes is not registered
	if not minetest.registered_nodes[under.name] then
		return itemstack
	end
	if not minetest.registered_nodes[above.name] then
		return itemstack
	end

	-- check if pointing at the top of the node
	if pt.above.y ~= pt.under.y+1 then
		return itemstack
	end

	-- check if you can replace the node above the pointed node
	if not minetest.registered_nodes[above.name].buildable_to then
		return itemstack
	end

	-- check if pointing at soil and seed needs soil
	if (minetest.get_item_group(under.name, "soil") < 2) and (minetest.get_item_group(plantname,"on_soil") >= 1) then
		return itemstack
	end
	-- if not neet soil, check for other restrictions
	if (minetest.get_item_group(plantname,"on_soil")<1) then
	  --check for correct height as given in mapgen options
	  if (pt.under.y < pdef.spawnon.spawn_min or pt.under.y > pdef.spawnon.spawn_max) then
  	    return itemstack
	  end
	  -- check if node is in spawning list
	  local is_correct_node = false
	  for _,spawnon in ipairs(pdef.spawnon.spawnon) do
	    if under.name == spawnon then
	      is_correct_node = true
	    end
	  end
	  if not is_correct_node then
	    return itemstack
	  end
	end

	-- add the node and remove 1 item from the itemstack
	minetest.add_node(pt.above, {name = plantname, param2 = 1})
	minetest.get_node_timer(pt.above):start(math.random(farming.wait_min, farming.wait_max))
	local meta = minetest.get_meta(pt.above)
	meta:set_int("farming:step",0)
	if not (creative and creative.is_enabled_for
			and creative.is_enabled_for(player_name)) then
		itemstack:take_item()
	end
	return itemstack
end

farming.seed_on_timer = function(pos, elapsed)
	local node = minetest.get_node(pos)
	local name = node.name
	local def = minetest.registered_nodes[name]
	-- grow seed
	local soil_node = minetest.get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})
	if not soil_node then
		minetest.get_node_timer(pos):start(math.random(farming.wait_min, farming.wait_max))
		return
	end
	local spawnon={}
	for _,v in pairs(def.fertility) do
	  table.insert(spawnon,1,v)
	end
	if def.spawnon then
		for _,v in pairs(def.spawnon.spawnon) do
		  table.insert(spawnon,1,v)
		end
	end
	-- omitted is a check for light, we assume seeds can germinate in the dark.
	for _, v in pairs(spawnon) do
		if (minetest.get_item_group(soil_node.name, v) ~= 0) or (soil_node.name == v) then
			local placenode = {name = def.next_step}
			if def.place_param2 then
				placenode.param2 = def.place_param2
			end
			minetest.swap_node(pos, placenode)
			local meta = minetest.get_meta(pos)
			meta:set_int("farming:step",def.groups[def.plant_name])
			if def.next_step then
				local node_timer=math.random(def.min_grow_time or 100, def.max_grow_time or 200)
				minetest.get_node_timer(pos):start(node_timer)
				return
			end
		end
	end
end
			
farming.seed_on_place = function(itemstack, placer, pointed_thing)
	local under = pointed_thing.under
	local node = minetest.get_node(under)
	local udef = minetest.registered_nodes[node.name]
	local plantname = itemstack:get_name()
	if udef and udef.on_rightclick and
			not (placer and placer:is_player() and
			placer:get_player_control().sneak) then
		return udef.on_rightclick(under, node, placer, itemstack,
			pointed_thing) or itemstack
	end
	return farming.place_seed(itemstack, placer, pointed_thing, plantname)
end

-- using tools
-- adopted from minetest-games
farming.tool_on_dig = function(itemstack, user, pointed_thing, uses)
	local pt = pointed_thing
	-- check if pointing at a node
	if not pt then
		return
	end

	local under = minetest.get_node(pt.under)
	local p = {x=pt.under.x, y=pt.under.y+1, z=pt.under.z}
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

	if minetest.is_protected(pt.under, user:get_player_name()) then
		minetest.record_protection_violation(pt.under, user:get_player_name())
		return
	end
	if minetest.is_protected(pt.above, user:get_player_name()) then
		minetest.record_protection_violation(pt.above, user:get_player_name())
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
			minetest.sound_play(wdef.sound.breaks, {pos = pt.above, gain = 0.5})
		end
	end
	return itemstack
end
