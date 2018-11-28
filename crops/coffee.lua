
local S = farming.intllib

-- coffee
minetest.register_craftitem("farming:coffee_beans_raw", {
	description = S("Raw Coffee Beans"),
	inventory_image = "farming_coffee_beans_raw.png",
	groups = {food_coffee_raw = 1, flammable = 2},
	on_place = function(itemstack, placer, pointed_thing)
		return farming.place_seed(itemstack, placer, pointed_thing, "farming:coffee_1")
	end,
})
minetest.register_craftitem("farming:coffee_beans", {
	description = S("Coffee Beans"),
	inventory_image = "farming_coffee_beans.png",
	groups = {food_coffee = 1, flammable = 2},
})

-- roasted coffee
minetest.register_craftitem("farming:coffee_beans", {
	description = S("Caffee Beans"),
	inventory_image = "farming_coffee_beans_raw.png",
	groups = {food_coffee = 1, flammable = 2},
})
minetest.register_craft({
	type = "cooking",
	cooktime = 5,
	output = "farming:coffee_beans",
	recipe = "farming:coffee_beans_raw"
})

-- spelt coffee
minetest.register_craftitem("farming:coffee_powder", {
	description = S("Coffee Powder"),
	inventory_image = "farming_roasted_powder.png",
	groups = {food_coffee_powder = 1, flammable = 2},
})
minetest.register_craft({
	type = "shapeless",
	output = "farming:coffee_powder",
	recipe = {
		"farming:coffee_beans", "farming:coffee_beans", "farming:coffee_beans",
		"farming:coffee_beans", "farming:coffee_grinder"
	},
	replacements = {{"group:food_coffee_grinder", "farming:coffee_grinder"}},
})


-- cold cup of coffee
minetest.register_node("farming:coffee_cup", {
	description = S("Cup of Coffee"),
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

minetest.register_alias("farming:coffee_cup_hot", "farming:coffee_cup")
minetest.register_alias("farming:drinking_cup", "vessels:drinking_glass")

minetest.register_craft( {
	output = "farming:coffee_cup",
	type = "shapeless",
	recipe = {"vessels:drinking_glass", "group:food_coffee_powder",
		"bucket:bucket_water", "group:food_saucepan"},
	replacements = {
		{"bucket:bucket_water", "bucket:bucket_empty"},
		{"group:food_saucepan", "farming:saucepan"},
	}
})

-- coffee definition
local crop_def = {
	drawtype = "plantlike",
	tiles = {"farming_coffee_1.png"},
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	drop = "",
	selection_box = farming.select,
	groups = {
		snappy = 3, flammable = 2, plant = 1, attached_node = 1,
		not_in_creative_inventory = 1, growing = 1
	},
	sounds = default.node_sound_leaves_defaults()
}

-- stage 1
minetest.register_node("farming:coffee_1", table.copy(crop_def))

-- stage 2
crop_def.tiles = {"farming_coffee_2.png"}
minetest.register_node("farming:coffee_2", table.copy(crop_def))

-- stage 3
crop_def.tiles = {"farming_coffee_3.png"}
minetest.register_node("farming:coffee_3", table.copy(crop_def))

-- stage 4
crop_def.tiles = {"farming_coffee_4.png"}
minetest.register_node("farming:coffee_4", table.copy(crop_def))

-- stage 5 (final)
crop_def.tiles = {"farming_coffee_5.png"}
crop_def.groups.growing = 0
crop_def.drop = {
	items = {
		{items = {'farming:coffee_beans 2'}, rarity = 1},
		{items = {'farming:coffee_beans 2'}, rarity = 2},
		{items = {'farming:coffee_beans 2'}, rarity = 3},
	}
}
minetest.register_node("farming:coffee_5", table.copy(crop_def))
