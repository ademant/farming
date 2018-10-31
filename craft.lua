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

minetest.register_craftitem("farming:grain_coffee_cup", {
	description = "Grain Coffee",
	inventory_image = "farming_coffee_cup.png",
	groups = {coffee = 1, flammable = 1},
})
minetest.register_craftitem("farming:coffee_cup", {
	description = "Coffee",
	inventory_image = "farming_coffee_cup.png",
	groups = {coffee = 1, flammable = 1},
})

if farming.has_value(modlist,"vessels") and farming.has_value(modlist,"bucket") then
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
	minetest.register_craft( {
		output = modname..":grain_coffee_cup",
		type = "shapeless",
		recipe = {"vessels:drinking_glass", "group:food_grain_powder",
			"bucket:bucket_water"},
		replacements = {
			{"bucket:bucket_water", "bucket:bucket_empty"},
		}
	})
else
	print("Mod vessels/bucket not available. Seriously? -> no COFFEE!")
end

if farming.has_value(modlist,"wool") then
	minetest.register_craft({
		output="wool:white",
		type="shapeless",
		recipe={"farming:cotton","farming:cotton","farming:cotton","farming:cotton"},
		})
	minetest.register_craft({
		output="wool:dark_green",
		type="shapeless",
		recipe={"farming:nettle_fibre","farming:nettle_fibre","farming:nettle_fibre","farming:nettle_fibre"},
		})
	minetest.register_craft({
		output="wool:dark_green",
		type="shapeless",
		recipe={"farming:hemp_fibre","farming:hemp_fibre","farming:hemp_fibre","farming:hemp_fibre"},
		})
	
end
