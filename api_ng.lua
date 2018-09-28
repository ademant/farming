local S = farming.intllib

-- helping function for getting biomes
farming.get_biomes = function(biom_def)
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
	local mintemp = biom_def.min_temp or -100
	local maxtemp = biom_def.max_temp or 1000
	local minhum = biom_def.min_humidity or -100
	local maxhum = biom_def.max_humidity or 1000
	local minelev = biom_def.spawnon.spawn_min or 0
	local maxelev = biom_def.spawnon.spawn_max or 31000
	for name,def in pairs(minetest.registered_biomes) do
--	  print(name)
	  local bpossible = 0
	  if def.heat_point >= mintemp and def.heat_point <= maxtemp then
	    bpossible = bpossible + 1
--	    print("heat")
	  end
	  if def.humidity_point >= minhum and def.humidity_point <= maxhum then
	    bpossible = bpossible + 1
--	    print("humidity")
	  end
--	  print(def.y_min.."-def-"..def.y_max)
--	  print(minelev.."-search-"..maxelev)
	  if def.y_min <= maxelev and def.y_max >= minelev then
	    bpossible = bpossible + 1
--	    print("elevation")
	  end
--	  print("possible: "..bpossible)
--	  print("max: "..count_def)
	  if bpossible == count_def then
	    table.insert(possible_biomes,1,name)
	  end
	end
	return possible_biomes
end
-- Register plants
farming.register_plant = function(name, def)
	-- Check def table
	if not def.steps then
		return nil
	end
	if not def.description then
		def.description = "Seed"
	end
	if not def.inventory_image then
		def.inventory_image = "unknown_item.png"
	end
	if not def.minlight then
		def.minlight = 1
	end
	if not def.maxlight then
		def.maxlight = 14
	end
	if not def.fertility then
		def.fertility = {}
	end
	if not def.switch_drop_count then
      def.switch_drop_count = math.floor(0.75 * def.steps)
    else
      if (def.switch_drop_count > def.steps) then
        def.switch_drop_count = def.steps
      end
	end
	if not def.max_harvest then
	  def.max_harvest = 2
	end
	if not def.mean_grow_time then
	  def.mean_grow_time=math.random(170,220)
	end
	if not def.range_grow_time then
	  def.range_grow_time=math.random(15,25)
	end
	if def.range_grow_time > def.mean_grow_time then
	  def.range_grow_time = math.floor(def.mean_grow_time / 2)
	end
	def.min_grow_time=math.floor(def.mean_grow_time-def.range_grow_time)
	def.max_grow_time=math.floor(def.mean_grow_time+def.range_grow_time)
	if not def.eat_hp then
	  def.eat_hp = 1
	end
	if not def.spawnon then
	  def.spawnon = { spawnon = {"default:dirt_with_grass"},
				spawn_min = 0,
				spawn_max = 42,
				spawnby = nil,
				scale = 0.006,
				offset = 0.12,
				spawn_num = -1}
	else
		def.spawnon.spawnon=def.spawnon.spawnon or {"default:dirt_with_grass"}
		def.spawnon.spawn_min = def.spawnon.spawn_min or 0
		def.spawnon.spawn_max = def.spawnon.spawn_max or 42
		def.spawnon.spawnby = def.spawnon.spawn_by or nil
		def.spawnon.scale = def.spawnon.scale or farming.rarety
		def.spawnon.offset = def.spawnon.offset or 0.12
		def.spawnon.spawn_num = def.spawnon.spawn_num or -1
	end
    
	-- local definitions
	local mname = name:split(":")[1]
	local pname = name:split(":")[2]
	local harvest_name=mname..":"..pname
	local harvest_name_png=mname.."_"..pname
	local seed_name=mname..":seed_"..pname
	local seed_name_png=mname.."_seed_"..pname
	if (def.groups["no_seed"] ~= nil) then
	  seed_name = harvest_name
	end

	farming.registered_plants[pname] = def

	-- Register harvest
	local harvest_def={
		description = S(pname:gsub("^%l", string.upper)),
		inventory_image = harvest_name_png .. ".png",
		groups = def.groups or {flammable = 2},
	}
	if ( def.eat_hp > 0 ) then
	  harvest_def.on_use=minetest.item_eat(def.eat_hp)
	end
	minetest.register_craftitem(":" .. harvest_name, harvest_def)
	
	-- Register seed
	local lbm_nodes = {seed_name}
	local g = {seed = 1, snappy = 3, attached_node = 1, flammable = 2}
	for k, v in pairs(def.fertility) do
		g[v] = 1
	end
--        print("register "..seed_name)
    local seed_def = {description = S(def.description),
		tiles = {def.inventory_image},
		inventory_image = def.inventory_image,
		wield_image = def.inventory_image,
		drawtype = "signlike",
		groups = g,
		paramtype = "light",
		paramtype2 = "wallmounted",
		place_param2 = def.place_param2 or nil, -- this isn't actually used for placement
		walkable = false,
		sunlight_propagates = true,
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
		},
		fertility = def.fertility,
		sounds = default.node_sound_dirt_defaults({
			dig = {name = "", gain = 0},
			dug = {name = "default_grass_footstep", gain = 0.2},
			place = {name = "default_place_node", gain = 0.25},
		}),
		on_place = function(itemstack, placer, pointed_thing)
			local under = pointed_thing.under
			local node = minetest.get_node(under)
			local udef = minetest.registered_nodes[node.name]
			if udef and udef.on_rightclick and
					not (placer and placer:is_player() and
					placer:get_player_control().sneak) then
				return udef.on_rightclick(under, node, placer, itemstack,pointed_thing) or itemstack
			end
			return farming.place_seed(itemstack, placer, pointed_thing, seed_name)
		end,
		next_plant = harvest_name .. "_1",
		on_timer = function(pos, elapsed)
				local node = minetest.get_node(pos)
				local name = node.name
				local def = minetest.registered_nodes[name]
				-- grow seed
				local soil_node = minetest.get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})
				if not soil_node then
					minetest.get_node_timer(pos):start(math.random(40, 80))
					return
				end
				-- omitted is a check for light, we assume seeds can germinate in the dark.
				for _, v in pairs(def.fertility) do
					if minetest.get_item_group(soil_node.name, v) ~= 0 then
						local placenode = {name = def.next_plant}
						if def.place_param2 then
							placenode.param2 = def.place_param2
						end
						minetest.swap_node(pos, placenode)
						local def_next=minetest.registered_nodes[def.next_plant]
						if def_next.next_plant then
							minetest.get_node_timer(pos):start(math.random(def_next.min_grow_time or 100, def_next.max_grow_time or 200))
							return
						end
					end
				end

			end,
		minlight = def.minlight,
		maxlight = def.maxlight,
	}
	minetest.register_node(":" .. seed_name, seed_def)
	
	-- Register growing steps
	local grad_harvest = def.max_harvest / def.steps
	for i = 1, def.steps do
		local base_rarity = 1
		if def.steps ~= 1 then
			base_rarity =  8 - (i - 1) * 7 / (def.steps - 1)
		end
		local step_harvest = math.floor(i * grad_harvest + 0.05)
		-- create drop table
		local drop = {
			items = {
				{items = {harvest_name}},
				}}
		-- if seeds are not crafted out of harvest, drop additional seeds
		if def.groups.drop_seed ~= nil then
		  table.insert(drop.items,1,{items={seed_name}})
		end
		-- enlarge drop table only, if grain type
		if def.groups.grain then
			-- with higher grow levels you harvest more
			if step_harvest > 1 then
			  for h = 2,step_harvest do
				table.insert(drop.items,1,{items={harvest_name},rarity=base_rarity*h})
				if def.groups.drop_seed ~= nil then
				  table.insert(drop.items,1,{items={seed_name},rarity=base_rarity*h})
				end
			  end
			end
			-- at the end stage you can harvest by change a cultured seed (if defined)
			if (i == def.steps and def.next_plant ~= nil) then
			  def.next_plant_rarity = def.next_plant_rarity or base_rarity*2
			  table.insert(drop.items,1,{items={def.next_plant},rarity=def.next_plant_rarity})
			end
        end		
		local nodegroups = {snappy = 3, flammable = 2, plant = 1, not_in_creative_inventory = 1, attached_node = 1}
		nodegroups[pname] = i

		local next_plant = nil

--                print("register "..harvest_name.."_"..i)
        local node_def = {
			drawtype = "plantlike",
			waving = 1,
			tiles = {harvest_name_png .. "_" .. i .. ".png"},
			paramtype = "light",
			paramtype2 = def.paramtype2 or nil,
			place_param2 = def.place_param2 or nil,
			walkable = false,
			buildable_to = true,
			drop = drop,
			selection_box = {
				type = "fixed",
				fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
			},
			groups = nodegroups,
			sounds = default.node_sound_leaves_defaults(),
			minlight = def.minlight,
			maxlight = def.maxlight,
		}
		if i < def.steps then
			next_plant = harvest_name .. "_" .. (i + 1)
			node_def.next_plant=next_plant
			lbm_nodes[#lbm_nodes + 1] = harvest_name .. "_" .. i
			node_def.on_timer = function(pos, elapsed)
					local node = minetest.get_node(pos)
					local name = node.name
					local def = minetest.registered_nodes[name]
					-- check if on wet soil
					local below = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
					if minetest.get_item_group(below.name, "soil") < 3 then
						minetest.get_node_timer(pos):start(math.random(40, 80))
						return
					end
					-- check light
					local light = minetest.get_node_light(pos)
					if not light or light < def.minlight or light > def.maxlight then
						minetest.get_node_timer(pos):start(math.random(40, 80))
						return
					end
					-- grow
					local placenode = {name = def.next_plant}
					if def.place_param2 then
						placenode.param2 = def.place_param2
					end
					minetest.swap_node(pos, placenode)
					-- new timer needed?
					local def_next=minetest.registered_nodes[def.next_plant]
					minetest.get_node_timer(pos):start(math.random(def_next.min_grow_time or 100, def_next.max_grow_time or 200))
					return
				end
		end
		if i == def.steps and def.groups.punchable then
			node_def.on_punch = function(pos, node, puncher, pointed_thing)
				-- grow
				local pre_node = harvest_name .. "_"..(i-1)
--				print(pre_node .. " pre node")
				local placenode = {name = pre_node}
				if def.place_param2 then
					placenode.param2 = def.place_param2
				end
				minetest.swap_node(pos, placenode)
				puncher:get_inventory():add_item('main',seed_name)
				-- new timer needed?
				local pre_def=minetest.registered_nodes[pre_node]
				if pre_def.next_plant then
					minetest.get_node_timer(pos):start(math.random(pre_def.min_grow_time or 100, pre_def.max_grow_time or 200))
				end
			end

		end
		minetest.register_node(":" .. harvest_name .. "_" .. i, node_def)
	end

	-- replacement LBM for pre-nodetimer plants
	minetest.register_lbm({
		name = ":" .. mname .. ":start_nodetimer_" .. pname,
		nodenames = lbm_nodes,
		action = function(pos, node)
			tick_again(pos)
		end,
	})

    -- register mapgen
--      print("spawn "..dump(def.spawnon))
--      print("scale "..def.spawnon.scale)
    if def.groups.no_spawn == nil then
--      print("spawn "..dump(def.spawnon))
      for j,onpl in ipairs(def.spawnon.spawnon) do
		local deco_def={
			deco_type = "simple",
			place_on = onpl,
			sidelen = 16,
			noise_params = {
				offset = def.spawnon.offset,
				scale = def.spawnon.scale, -- 0.006,
				spread = {x = 200, y = 200, z = 200},
				seed = 329,
				octaves = 3,
				persist = 0.6
			},
			y_min = def.spawnon.spawn_min,
			y_max = def.spawnon.spawn_max,
			decoration = def.wildname or harvest_name.."_1",
			spawn_by = def.spawnon.spawnby,
			num_spawn_by = def.spawnon.spawn_num,
			biomes = farming.get_biomes(def)
		}
		minetest.register_decoration(deco_def)
	  end
	end
	-- Return
	local r = {
		seed = mname .. ":seed_" .. pname,
		harvest = mname .. ":" .. pname
	}
	return r
end
