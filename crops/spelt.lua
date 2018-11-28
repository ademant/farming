
local S = farming.intllib

-- spelt seeds
minetest.register_node("farming:seed_spelt", {
	description = S("Spelt Seed"),
	tiles = {"farming_spelt_seed.png"},
	inventory_image = "farming_spelt_seed.png",
	wield_image = "farming_spelt_seed.png",
	drawtype = "signlike",
	groups = {seed = 1, snappy = 3, attached_node = 1},
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	sunlight_propagates = true,
	selection_box = farming.select,
	on_place = function(itemstack, placer, pointed_thing)
		return farming.place_seed(itemstack, placer, pointed_thing, "farming:spelt_1")
	end,
})

-- harvested spelt
minetest.register_craftitem("farming:spelt", {
	description = S("Spelt"),
	inventory_image = "farming_spelt.png",
	groups = {food_spelt = 1, flammable = 2},
})

-- flour
minetest.register_craft({
	type = "shapeless",
	output = "farming:flour",
	recipe = {
		"farming:spelt", "farming:spelt", "farming:spelt",
		"farming:spelt", "farming:mortar_pestle"
	},
	replacements = {{"group:food_mortar_pestle", "farming:mortar_pestle"}},
})

-- roasted spelt
minetest.register_craftitem("farming:spelt_roasted", {
	description = S("Roasted Spelt"),
	inventory_image = "farming_spelt_roasted.png",
	groups = {food_spelt_roasted = 1, flammable = 2},
})
minetest.register_craft({
	type = "cooking",
	cooktime = 1,
	output = "farming:spelt_roasted",
	recipe = "farming:spelt"
})

-- spelt coffee
minetest.register_craftitem("farming:spelt_coffee", {
	description = S("Spelt Coffee"),
	inventory_image = "farming_roasted_powder.png",
	groups = {food_spelt_powder = 1, flammable = 2},
})
minetest.register_craft({
	type = "shapeless",
	output = "farming:spelt_coffee",
	recipe = {
		"farming:spelt_roasted", "farming:spelt_roasted", "farming:coffee_grinder"
	},
	replacements = {{"group:food_coffee_grinder", "farming:coffee_grinder"}},
})

-- cold cup of coffee
minetest.register_node("farming:spelt_coffee_cup", {
	description = S("Cup of Spelt Coffee"),
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

minetest.register_alias("farming:spelt_coffee_cup_hot", "farming:spelt_coffee_cup")

minetest.register_craft( {
	output = "farming:spelt_coffee_cup",
	type = "shapeless",
	recipe = {"vessels:drinking_glass", "group:food_spelt_powder",
		"bucket:bucket_water", "group:food_saucepan"},
	replacements = {
		{"bucket:bucket_water", "bucket:bucket_empty"},
		{"group:food_saucepan", "farming:saucepan"},
	}
})

minetest.register_craft({
	type = "cooking",
	cooktime = 15,
	output = "farming:spelt_roasted",
	recipe = "farming:spelt"
})

-- spelt definition
local crop_def = {
	drawtype = "plantlike",
	tiles = {"farming_spelt_1.png"},
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 3,
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
minetest.register_node("farming:spelt_1", table.copy(crop_def))

-- stage 2
crop_def.tiles = {"farming_spelt_2.png"}
minetest.register_node("farming:spelt_2", table.copy(crop_def))

-- stage 3
crop_def.tiles = {"farming_spelt_3.png"}
minetest.register_node("farming:spelt_3", table.copy(crop_def))

-- stage 4
crop_def.tiles = {"farming_spelt_4.png"}
minetest.register_node("farming:spelt_4", table.copy(crop_def))

-- stage 5
crop_def.tiles = {"farming_spelt_5.png"}
crop_def.drop = {
	items = {
		{items = {'farming:spelt'}, rarity = 2},
		{items = {'farming:seed_spelt'}, rarity = 2},
	}
}
minetest.register_node("farming:spelt_5", table.copy(crop_def))

-- stage 6
crop_def.tiles = {"farming_spelt_6.png"}
crop_def.drop = {
	items = {
		{items = {'farming:spelt'}, rarity = 2},
		{items = {'farming:seed_spelt'}, rarity = 1},
	}
}
minetest.register_node("farming:spelt_6", table.copy(crop_def))

-- stage 7 (final)
crop_def.tiles = {"farming_spelt_7.png"}
crop_def.groups.growing = 0
crop_def.drop = {
	items = {
		{items = {'farming:spelt'}, rarity = 1},
		{items = {'farming:spelt'}, rarity = 3},
		{items = {'farming:seed_spelt'}, rarity = 1},
		{items = {'farming:seed_spelt'}, rarity = 3},
	}
}
minetest.register_node("farming:spelt_7", table.copy(crop_def))
