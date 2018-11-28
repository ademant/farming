
local S = farming.intllib

-- fuels
minetest.register_craft({
	type = "fuel",
	recipe = "farming:straw",
	burntime = 3,
})
-- flour
minetest.register_craftitem("farming:flour", {
	description = S("Flour"),
	inventory_image = "farming_flour.png",
	groups = {food_flour = 1, flammable = 1},
})
minetest.register_craft({
	type = "shapeless",
	output = "farming:flour",
	recipe = {
		"group:seed", "group:seed", "group:seed",
		"group:seed", "farming:mortar_pestle"
	},
	replacements = {{"group:food_mortar_pestle", "farming:mortar_pestle"}},
})

-- bread
minetest.register_craftitem("farming:bread", {
	description = S("Bread"),
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

-- sliced bread
minetest.register_craftitem("farming:bread_slice", {
	description = S("Sliced Bread"),
	inventory_image = "farming_bread_slice.png",
	on_use = minetest.item_eat(1),
	groups = {food_bread_slice = 1, flammable = 2},
})

minetest.register_craft({
	type = "shapeless",
	output = "farming:bread_slice 5",
	recipe = {"farming:bread", "group:food_cutting_board"},
	replacements = {{"group:food_cutting_board", "farming:cutting_board"}},
})

-- toast
minetest.register_craftitem("farming:toast", {
	description = S("Toast"),
	inventory_image = "farming_toast.png",
	on_use = minetest.item_eat(1),
	groups = {food_toast = 1, flammable = 2},
})

minetest.register_craft({
	type = "cooking",
	cooktime = 3,
	output = "farming:toast",
	recipe = "farming:bread_slice"
})

-- toast sandwich
minetest.register_craftitem("farming:toast_sandwich", {
	description = S("Toast Sandwich"),
	inventory_image = "farming_toast_sandwich.png",
	on_use = minetest.item_eat(4),
	groups = {flammable = 2},
})

minetest.register_craft({
	output = "farming:toast_sandwich",
	recipe = {
		{"farming:bread_slice"},
		{"farming:toast"},
		{"farming:bread_slice"},
	}
})

local function register_grain(grain_name_in,bwild,max_level,harvest_threshold,seed_threshold,seed_rarity)
local grain_name=string.lower(grain_name_in)
local print_name=string.upper(string.sub(grain_name,1,1))..string.sub(grain_name,2,99)
local modname=minetest.get_current_modname()
local farming_name=modname..":"..grain_name
local seed_name=modname..":seed_"..grain_name
print("registering "..seed_name)
local seed_png="farming_"..grain_name.."_seed.png"

-- seeds
minetest.register_node(seed_name, {
	description = S(print_name.." Seed"),
	tiles = {seed_png},
	inventory_image = seed_png,
	wield_image = seed_png,
	drawtype = "signlike",
	groups = {seed = 1, snappy = 3, attached_node = 1, flammable = 4},
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	sunlight_propagates = true,
	selection_box = farming.select,
	on_place = function(itemstack, placer, pointed_thing)
		return farming.place_seed(itemstack, placer, pointed_thing, "farming:"..grain_name.."_1")
	end,
})
-- harvested 
minetest.register_craftitem(farming_name, {
	description = S(print_name),
	inventory_image = "farming_"..grain_name..".png",
	groups = {food_harvested = 1, flammable = 4},
})
-- roasted 
minetest.register_craftitem(seed_name.."_roasted", {
	description = S(print_name.." roasted"),
	inventory_image = "farming_"..grain_name.."_seed_roasted.png",
	groups = {food_grain_roasted = 1, flammable = 4},
})
minetest.register_craft({
	type = "cooking",
	cooktime = 15,
	output = seed_name.."_roasted",
	recipe = seed_name
})

minetest.register_craft({
	type = "shapeless",
	output = seed_name,
	recipe = {
		farming_name, farming_name, farming_name,
		farming_name, modname..":flail"
	},
	replacements = {{"group:flail", "farming:flail"},
					{"group:harvested",modname..":straw"}},
})
-- grain definition
local crop_def = {
	drawtype = "plantlike",
	tiles = {"farming_"..grain_name.."_1.png"},
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 3,
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	drop = "",
	selection_box = farming.select,
	groups = {
		snappy = 3, flammable = 4, plant = 1, attached_node = 1,
		not_in_creative_inventory = 1, growing = 1
	},
	sounds = default.node_sound_leaves_defaults()
}

-- stages
for level=1,max_level,1 do
  crop_def.tiles = {"farming_"..grain_name.."_"..level..".png"}
  if (level >= harvest_threshold) and (level < seed_threshold) then
    crop_def.drop={items={items = {items = {farming_name},rarity=1}}}
  end
  if (level >= seed_threshold) then
    crop_def.drop={	items = {
			{items = {farming_name},rarity=1},
			{items = {farming_name},rarity=3},
			{items = {seed_name},rarity=seed_rarity}
			}
		}
  end
  if (level == max_level) then
    crop_def.groups.growing = 0
  end
  minetest.register_node(farming_name.."_"..level, table.copy(crop_def))
end



-- fuels
minetest.register_craft({
	type = "fuel",
	recipe = farming_name,
	burntime = 1,
})

end

register_grain("wheat",true,8,5,7,2)
print("register grain spelt")
register_grain("spelt",true,7,5,6,2)


