local S = farming.intllib
local modname=minetest.get_current_modname()

-- define seed crafting
local function seed_craft(grain_name)
  local mname = grain_name:split(":")[1]
  local pname = grain_name:split(":")[2]

  minetest.register_craft({
	type = "shapeless",
	output = mname..":seed_"..pname.." 8",
	recipe = {
		grain_name,grain_name,grain_name,grain_name, modname..":flail",grain_name,grain_name,grain_name,grain_name
	},
	replacements = {{"group:food_flail", modname..":flail"},
				{"group:food_wheat","farming:straw"}},
  })
  minetest.register_craft({
	type = "shapeless",
	output = mname..":seed_"..pname.." 1",
	recipe = {
		grain_name, modname..":flail"
	},
	replacements = {{"group:food_flail", modname..":flail"},
				{"group:food_wheat","farming:straw"}},
  })
  minetest.register_craft({
	type = "shapeless",
	output = mname..":seed_"..pname.." 1",
	recipe = {
		modname..":flail",grain_name
	},
	replacements = {{"group:food_flail", modname..":flail"},
				{"group:food_wheat","farming:straw"}},
  })
end

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
		"group:seed", "group:seed", "group:seed",
		"group:seed", modname..":mortar_pestle"
	},
	replacements = {{"group:food_mortar_pestle", modname..":mortar_pestle"}},
})

seed_craft("farming:wheat")
seed_craft("farming:culturewheat")
seed_craft("farming:barley")

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

