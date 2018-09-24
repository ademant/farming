local S = farming.intllib
local modname=minetest.get_current_modname()

-- coffee grinder

minetest.register_craftitem(modname..":coffee_grinder", {
	description = S("Coffee Grinder"),
	inventory_image = "farming_tool_coffee_grinder.png",
	groups = {food_coffee_grinder = 1, flammable = 2},
})

minetest.register_craft({
	output = modname..":coffee_grinder",
	recipe = {
		{"group:wood", "group:stick", "group:wood"},
		{"", "default:stone", ""},
	}
})

-- flail
minetest.register_craftitem(modname..":flail", {
	description = S("Threshing Flail"),
	inventory_image = "farming_tool_flail.png",
	groups = {food_flail = 1, flammable = 2},
})

minetest.register_craft({
	output = modname..":flail",
	recipe = {
		{"", "", "group:stick"},
		{"", "group:stick", "group:stick"},
		{"group:stick", "", ""},
	}
})

-- mortar and pestle -- definition from mod farming by tenplus1
minetest.register_craftitem(modname..":mortar_pestle", {
	description = S("Mortar and Pestle"),
	inventory_image = "farming_tool_mortar_pestle.png",
	groups = {food_mortar_pestle = 1, flammable = 2},
})

minetest.register_craft({
	output = modname..":mortar_pestle",
	recipe = {
		{"default:stone", "group:stick", "default:stone"},
		{"", "default:stone", ""},
	}
})
