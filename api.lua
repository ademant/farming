
-- Wear out hoes, place soil
-- TODO Ignore group:flower
farming.registered_plants = {}

farming.hoe_on_use = function(itemstack, user, pointed_thing, uses)
	local pt = pointed_thing
	-- check if pointing at a node
	if not pt then
		return
	end
	if pt.type ~= "node" then
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

	-- check if pointing at soil
	if minetest.get_item_group(under.name, "soil") ~= 1 then
		return
	end

	-- check if (wet) soil defined
	local regN = minetest.registered_nodes
	if regN[under.name].soil == nil or regN[under.name].soil.wet == nil or regN[under.name].soil.dry == nil then
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

	-- turn the node into soil and play sound
	minetest.set_node(pt.under, {name = regN[under.name].soil.dry})
	minetest.sound_play("default_dig_crumbly", {
		pos = pt.under,
		gain = 0.5,
	})

	if not (creative and creative.is_enabled_for
			and creative.is_enabled_for(user:get_player_name())) then
		-- wear tool
		local wdef = itemstack:get_definition()
		itemstack:add_wear(65535/(uses-1))
		-- tool break sound
		if itemstack:get_count() == 0 and wdef.sound and wdef.sound.breaks then
			minetest.sound_play(wdef.sound.breaks, {pos = pt.above, gain = 0.5})
		end
	end
	return itemstack
end

-- Register new hoes
farming.register_hoe = function(name, def)
	-- Check for : prefix (register new hoes in your mod's namespace)
	if name:sub(1,1) ~= ":" then
		name = ":" .. name
	end
	-- Check def table
	if def.description == nil then
		def.description = "Hoe"
	end
	if def.inventory_image == nil then
		def.inventory_image = "unknown_item.png"
	end
	if def.max_uses == nil then
		def.max_uses = 30
	end
	-- Register the tool
	minetest.register_tool(name, {
		description = def.description,
		inventory_image = def.inventory_image,
		on_use = function(itemstack, user, pointed_thing)
			return farming.hoe_on_use(itemstack, user, pointed_thing, def.max_uses)
		end,
		groups = def.groups,
		sound = {breaks = "default_tool_breaks"},
	})
	-- Register its recipe
	if def.recipe then
		minetest.register_craft({
			output = name:sub(2),
			recipe = def.recipe
		})
	elseif def.material then
		minetest.register_craft({
			output = name:sub(2),
			recipe = {
				{def.material, def.material, ""},
				{"", "group:stick", ""},
				{"", "group:stick", ""}
			}
		})
	end
end

-- how often node timers for plants will tick, +/- some random value
local function tick(pos)
--	minetest.get_node_timer(pos):start(math.random(166, 286))
	minetest.get_node_timer(pos):start(math.random(16, 26))
end
-- how often a growth failure tick is retried (e.g. too dark)
local function tick_again(pos)
	minetest.get_node_timer(pos):start(math.random(40, 80))
end

farming.grow_plant = function(pos, elapsed)
	local node = minetest.get_node(pos)
	local name = node.name
	local def = minetest.registered_nodes[name]

	if not def.next_plant then
		-- disable timer for fully grown plant
		return
	end

	-- grow seed
	if minetest.get_item_group(node.name, "seed") and def.fertility then
		local soil_node = minetest.get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})
		if not soil_node then
			tick_again(pos)
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
				if minetest.registered_nodes[def.next_plant].next_plant then
					tick(pos)
					return
				end
			end
		end

		return
	end

	-- check if on wet soil
	local below = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
	if minetest.get_item_group(below.name, "soil") < 3 then
		tick_again(pos)
		return
	end

	-- check light
	local light = minetest.get_node_light(pos)
	if not light or light < def.minlight or light > def.maxlight then
		tick_again(pos)
		return
	end

	-- grow
	local placenode = {name = def.next_plant}
	if def.place_param2 then
		placenode.param2 = def.place_param2
	end
	minetest.swap_node(pos, placenode)

	-- new timer needed?
	if minetest.registered_nodes[def.next_plant].next_plant then
		tick(pos)
	end
	return
end

