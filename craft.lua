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


-- function to drink item on use with fallback to eat if thirsty mod not available
local drink_or_eat = function(hp_change,replace_with_item,itemstack,user,pointed_thing)
	if minetest.get_modpath("thirsty") ~= nil then
		thirsty.drink(user,3*hp_change)
	else
		minetest.do_item_eat(hp_change,replace_with_item,itemstack,user,pointed_thing)
	end
end

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
	minetest.register_craft( {
		output = modname..":grain_coffee_cup 3",
		type = "shapeless",
		recipe = {"vessels:drinking_glass","vessels:drinking_glass","vessels:drinking_glass", "group:food_grain_powder",
			"bucket:bucket_water"},
		replacements = {
			{"bucket:bucket_water", "bucket:bucket_empty"},
		}
	})
	minetest.register_craft( {
		output = modname..":coffee_cup",
		type = "shapeless",
		recipe = {"vessels:drinking_glass", "group:food_powder",
			"bucket:bucket_water"},
		replacements = {
			{"bucket:bucket_water", "bucket:bucket_empty"},
		}
	})
	minetest.register_craftitem("farming:grain_coffee_cup", {
		description = "Grain Coffee",
		inventory_image = "farming_coffee_cup.png",
		on_use = function(itemstack,user,pointed_thing)
			drink_or_eat(2,"vessels:drinking_glass",itemstack,user,pointed_thing)
		end,
		groups = {coffee = 1, flammable = 1, beverage=1},
	})
	minetest.register_craftitem("farming:grain_coffee_cup_hot", {
		description = "Grain Coffee hot",
		inventory_image = "farming_coffee_cup_hot.png",
		on_use = function(itemstack,user,pointed_thing)
			drink_or_eat(4,"vessels:drinking_glass",itemstack,user,pointed_thing)
		end,
		groups = {coffee = 2, flammable = 1, beverage=2},
	})
	minetest.register_craft({
		type = "cooking",
		cooktime = 2,
		output = "farming:grain_coffee_cup_hot",
		recipe = "farming:grain_coffee_cup"
	})
	minetest.register_craftitem("farming:grain_milk", {
		description = "Grain Milk",
		inventory_image = "farming_grain_milk.png",
		on_use = function(itemstack,user,pointed_thing)
			drink_or_eat(5,"vessels:drinking_glass",itemstack,user,pointed_thing)
		end,
		groups = {flammable = 1, beverage=1},
	})
	minetest.register_craft( {
		output = modname..":grain_milk 3",
		type = "shapeless",
		recipe = {"vessels:drinking_glass","vessels:drinking_glass","vessels:drinking_glass", "farming:flour",
			"bucket:bucket_water"},
		replacements = {
			{"bucket:bucket_water", "bucket:bucket_empty"},
		}
	})
else
	print("Mod vessels/bucket not available. Seriously? -> no COFFEE!")
end

if basic_functions.has_value(modlist,"wool") then
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
