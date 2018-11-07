local S = farming.intllib

farming.register_billhook = function(name,def)
  if not def.groups["billhook"] then
	def.groups["billhook"]=1
  end
  if not def.material then
    return
  end
  if def.max_uses == nil then
	def.max_uses = 30
  end
  if def.on_use == nil then
	def.on_use = function(itemstack, user, pointed_thing)
			return farming.use_billhook(itemstack, user, pointed_thing, def.max_uses)
		end
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
	if def.inventory_image == nil then
		def.inventory_image = "unknown_item.png"
	end
	if def.max_uses == nil then
		def.max_uses = 30
	end
	if def.description == nil then
		def.description = "Farming tool"
	end
	def.description=def.description.."\nmax uses: "..def.max_uses
	if def.farming_change then
		def.description=def.description.."\nfarming change: "..def.farming_change
	end
	def.sound={breaks = "default_tool_breaks"}

	-- Register the tool
	minetest.register_tool(name, def)
	-- Register its recipe
	minetest.register_craft({
		output = name:sub(2),
		recipe = def.recipe
	})
end

-- copied from farming_redo
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
-- copied from farming_redo
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
