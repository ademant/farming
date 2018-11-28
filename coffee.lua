local S = farming.intllib

-- cold cup of coffee
minetest.register_node("farming:grain_coffee_cup", {
	description = S("Cup of Grain Coffee"),
	drawtype = "torchlike", --"plantlike",
	tiles = {"farming_coffee_cup.png"},
	inventory_image = "farming_coffee_cup.png",
	wield_image = "farming_coffee_cup.png",
	paramtype = "light",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0.25, 0.25}
	},
	groups = {vessel = 1, dig_immediate = 3, attached_node = 1},
	on_use = minetest.item_eat(2, "vessels:drinking_glass"),
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_alias("farming:grain_coffee_cup_hot", "farming:grain_coffee_cup")

minetest.register_craft( {
	output = "farming:grain_coffee_cup",
	type = "shapeless",
	recipe = {"vessels:drinking_glass", "group:food_grain_powder",
		"bucket:bucket_water", "group:food_saucepan"},
	replacements = {
		{"bucket:bucket_water", "bucket:bucket_empty"},
		{"group:food_saucepan", "farming:saucepan"},
	}
})

minetest.register_craftitem("farming:grain_coffee", {
	description = S("Grain Coffee"),
	inventory_image = "farming_roasted_powder.png",
	groups = {food_grain_powder = 1, flammable = 2},
})
minetest.register_craft({
	type = "shapeless",
	output = "farming:grain_coffee",
	recipe = {
		"group:food_grain_roasted", "group:food_grain_roasted", "farming:coffee_grinder"
	},
	replacements = {{"group:food_coffee_grinder", "farming:coffee_grinder"}},
})
