local S = farming.intllib
local modname=minetest.get_current_modname()
local modlist=minetest.get_modnames()

-- defining template for roasting
local function roast_seed(seed_name,roast_name,cooktime)
  minetest.register_craft({
	type = "cooking",
	cooktime = cooktime or 3,
	output = roast_name,
	recipe = seed_name
  })
end

-- craft flour with mortar
-- minetest.clear_craft({output="farming:flour"})
minetest.register_craft({
	type = "shapeless",
	output = "farming:flour",
	recipe = {
		"group:for_flour", "group:for_flour", "group:for_flour",
		"group:for_flour", modname..":mortar_pestle"
	},
	replacements = {{"group:food_mortar_pestle", modname..":mortar_pestle"}},
})

minetest.register_craft({
	type = "shapeless",
	output = "farming:flour",
	recipe = {
		"group:for_flour", "group:for_flour", "group:for_flour",
		modname..":mortar_pestle_highlevel"
	},
	replacements = {{modname..":mortar_pestle_highlevel", modname..":mortar_pestle_highlevel"}},
})
minetest.register_craftitem("farming:flour", {
	description = "Flour",
	inventory_image = "farming_flour.png",
	groups = {food_flour = 1, flammable = 1},
})


if basic_functions.has_value(modlist,"vessels") and basic_functions.has_value(modlist,"bucket") then
	minetest.register_craftitem(modname..":nettle_water",{
		description = "Nettle Water",
		inventory_image = "farming_tool_glass_nettle.png",
		groups = {desinfect = 1}
	})
	minetest.register_craft({
		output=modname..":nettle_water",
		type = "shapeless",
		recipe={"vessels:glass_bottle","bucket:bucket_water",modname..":nettle"},
		replacements = {{"bucket:bucket_water", "bucket:bucket_empty"}}
	})
end


minetest.register_craft({
	type = "fuel",
	recipe = "farming:straw",
	burntime = 10,
})
minetest.register_craft({
	type = "fuel",
	recipe = "farming:nettle_fibre",
	burntime = 8,
})
minetest.register_craft({
	type = "fuel",
	recipe = "farming:hemp_fibre",
	burntime = 8,
})
