local S = farming.intllib
local modname=minetest.get_current_modname()


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


roast_seed("farming:seed_barley","farming:seed_barley_roasted")
roast_seed("farming:seed_wheat","farming_grain:seed_wheat_roasted")

minetest.register_craft({
type = "shapeless",
output = modname..":grain_powder",
recipe = {
	"group:food_grain_roasted", modname..":coffee_grinder"
},
replacements = {{"group:food_coffee_grinder", modname..":coffee_grinder"}},
})

minetest.register_craft( {
	output = modname..":grain_coffee_cup",
	type = "shapeless",
	recipe = {"vessels:drinking_glass", "group:food_grain_powder",
		"bucket:bucket_water"},
	replacements = {
		{"bucket:bucket_water", "bucket:bucket_empty"},
	}
})

minetest.register_craftitem("farming:bread", {
	description = "Bread",
	inventory_image = "farming_bread.png",
	on_use = minetest.item_eat(5),
	groups = {food_bread = 1, flammable = 2},
})

minetest.register_craft({
	type = "cooking",
	cooktime = 15,
	output = "farming:bread",
	recipe = "farming:flour"
})

minetest.register_craftitem("farming:flour", {
	description = "Flour",
	inventory_image = "farming_flour.png",
	groups = {food_flour = 1, flammable = 1},
})

minetest.register_craftitem("farming:grain_roasted", {
	description = "Grain Roaste",
	inventory_image = "farming_grain_roasted.png",
	groups = {food_roasted = 1, flammable = 1},
})

minetest.register_craftitem(modname..":nettle_water",{
	description = "Nettle Water",
	inventory_image = "farming_tool_glass_nettle.png",
	groups = {desinfect = 1}
})
minetest.register_craft({
	output=modname..":nettle_water 10",
	type = "shapeless",
	recipe={"vessels:glass_bottle 10","bucket_water",farming.modname..":nettle"},
	replacements = {{"bucket_water", "bucket_empty"}}
})
