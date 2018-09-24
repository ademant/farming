
local table_insert = function(tab,tin)
  local out=tab
  for i=#out,1,-1 do
    out[i+1]=out[i]
  end
  out[1]=tin
  return out
end

farming.enlarge_drop_table = function(item_name,def)
--[[
insert new seed at beginning of drop table. calculate new rarity.

example:
farming_grain.enlarge_drop("default:grass_4",{items={"farming:seed_wheat"},rarity=8})
]]

  local tdrop=minetest.registered_nodes[item_name].drop.items -- get drop.items table of stored item
  local new_drop={def}

  -- new drop table
  if tdrop ~= nil then
    for i=1,#tdrop do
      new_drop[i+1]=tdrop[i]
    end
  end
  -- calculate new rarity for each element. if all seeds have same rarity then the first element will drop more often than following elements
  for i=1,#new_drop do
    new_rarity=2^(#new_drop-i)
    new_drop[i].rarity=new_rarity
  end
  -- grab old drop table
  local old_def=minetest.registered_nodes[item_name].drop
  old_def.items=new_drop
  -- override drop table
  minetest.override_item(item_name,{drop=old_def})
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
	if not def.spawnon then
	  def.spawnon = { spawnon = {"default:dirt_with_grass"},
				spawn_min = 0,
				spawn_max = 42,
				spawnby = nil,
				scale = 0.006,
				spawn_num = -1}
	else
		def.spawnon.spawnon=def.spawnon.spawnon or {"default:dirt_with_grass"}
		def.spawnon.spawn_min = def.spawnon.spawn_min or 0
		def.spawnon.spawn_max = def.spawnon.spawn_max or 42
		def.spawnon.spawnby = def.spawnon.spawn_by or nil
		def.spawnon.scale = def.spawnon.scale or farming.rarety
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
	  seed_name = mname..":"..pname
	end

	farming.registered_plants[pname] = def

	-- Register harvest
	minetest.register_craftitem(":" .. harvest_name, {
		description = pname:gsub("^%l", string.upper),
		inventory_image = mname .. "_" .. pname .. ".png",
		groups = def.groups or {flammable = 2},
	})
	
	-- Register seed
	local lbm_nodes = {seed_name}
	local g = {seed = 1, snappy = 3, attached_node = 1, flammable = 2}
	for k, v in pairs(def.fertility) do
		g[v] = 1
	end
        print("register "..seed_name)
	minetest.register_node(":" .. seed_name, {
		description = def.description,
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
				return udef.on_rightclick(under, node, placer, itemstack,
					pointed_thing) or itemstack
			end

			return farming.place_seed(itemstack, placer, pointed_thing, mname .. ":seed_" .. pname)
		end,
		next_plant = mname .. ":" .. pname .. "_1",
		on_timer = farming.grow_plant,
		minlight = def.minlight,
		maxlight = def.maxlight,
	})
	
	-- Register growing steps
	for i = 1, def.steps do
		local base_rarity = 1
		if def.steps ~= 1 then
			base_rarity =  8 - (i - 1) * 7 / (def.steps - 1)
		end
		-- create drop table
		local drop = {
			items = {
				{items = {harvest_name}},
				}
			}
		-- if seeds are not crafted out of harvest, drop additional seeds
		if def.groups.drop_seed ~= nil then
		  table.insert(drop.items,1,{items={seed_name}})
		end
		-- with higher grow levels you harvest more
		if (i >= def.switch_drop_count ) then
		  table.insert(drop.items,1,{items={harvest_name},rarity=base_rarity})
			if def.groups.drop_seed ~= nil then
			  table.insert(drop.items,1,{items={seed_name},rarity=base_rarity})
			end
		end
		-- at the end stage you can harvest by change a cultured seed (if defined)
		if (i == def.steps and def.next_plant ~= nil) then
		  def.next_plant_rarity = def.next_plant_rarity or base_rarity*2
		  table.insert(drop.items,1,{items={def.next_plant},rarity=def.next_plant_rarity})
		end
		
		local nodegroups = {snappy = 3, flammable = 2, plant = 1, not_in_creative_inventory = 1, attached_node = 1}
		nodegroups[pname] = i

		local next_plant = nil

		if i < def.steps then
			next_plant = harvest_name .. "_" .. (i + 1)
			lbm_nodes[#lbm_nodes + 1] = harvest_name .. "_" .. i
		end
                print("register "..harvest_name.."_"..i)
		minetest.register_node(":" .. harvest_name .. "_" .. i, {
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
			next_plant = next_plant,
			on_timer = farming.grow_plant,
			minlight = def.minlight,
			maxlight = def.maxlight,
		})
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
        print("spawn "..dump(def.spawnon))
        print("scale "..def.spawnon.scale)
    local mapgen_level = def.switch_drop_count - 1
    print(mapgen_level)
    for i = 1,math.max(mapgen_level,1) do
      for j,onpl in ipairs(def.spawnon.spawnon) do
		minetest.register_decoration({
			deco_type = "simple",
			place_on = onpl,
			sidelen = 16,
			noise_params = {
				offset = 0.12 - 0.08*i,
				scale = def.spawnon.scale, -- 0.006,
				spread = {x = 200, y = 200, z = 200},
				seed = 329,
				octaves = 3,
				persist = 0.6
			},
			y_min = def.spawnon.spawn_min,
			y_max = def.spawnon.spawn_max,
			decoration = harvest_name.."_"..i,
			spawn_by = def.spawnon.spawnby,
			num_spawn_by = def.spawnon.spawn_num,
		})
	  end
	end
	-- Return
	local r = {
		seed = mname .. ":seed_" .. pname,
		harvest = mname .. ":" .. pname
	}
	return r
end
