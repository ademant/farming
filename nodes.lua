local S = farming.intllib

local add_soil = function(item,soil)
  minetest.override_item(item,{
	soil = {
		base = item,
		dry = soil,
		wet = soil.."_wet"
		}
	})
end

for i,v in ipairs(farming.change_soil) do
	add_soil(v,"farming:soil")
end

-- override desert items
if (farming.change_soil_desert == nil) then
  farming.change_soil_desert = {"default:desert_sand"}
end
for i,v in ipairs(farming.change_soil_desert) do
	add_soil(v,"farming:desert_sand_soil")
end

-- register nodes
minetest.register_node("farming:soil", {
	description = "Soil",
	tiles = {"default_dirt.png^farming_soil.png", "default_dirt.png"},
	drop = "default:dirt",
	groups = {crumbly=3, not_in_creative_inventory=1, soil=2, grassland = 1, field = 1},
	sounds = default.node_sound_dirt_defaults(),
	soil = {
		base = "default:dirt",
		dry = "farming:soil",
		wet = "farming:soil_wet"
	}
})

minetest.register_node("farming:soil_wet", {
	description = "Wet Soil",
	tiles = {"default_dirt.png^farming_soil_wet.png", "default_dirt.png^farming_soil_wet_side.png"},
	drop = "default:dirt",
	groups = {crumbly=3, not_in_creative_inventory=1, soil=3, wet = 1, grassland = 1, field = 1},
	sounds = default.node_sound_dirt_defaults(),
	soil = {
		base = "default:dirt",
		dry = "farming:soil",
		wet = "farming:soil_wet"
	}
})

minetest.register_node("farming:desert_sand_soil", {
	description = "Desert Sand Soil",
	drop = "default:desert_sand",
	tiles = {"farming_desert_sand_soil.png", "default_desert_sand.png"},
	groups = {crumbly=3, not_in_creative_inventory = 1, falling_node=1, sand=1, soil = 2, desert = 1, field = 1},
	sounds = default.node_sound_sand_defaults(),
	soil = {
		base = "default:desert_sand",
		dry = "farming:desert_sand_soil",
		wet = "farming:desert_sand_soil_wet"
	}
})

minetest.register_node("farming:desert_sand_soil_wet", {
	description = "Wet Desert Sand Soil",
	drop = "default:desert_sand",
	tiles = {"farming_desert_sand_soil_wet.png", "farming_desert_sand_soil_wet_side.png"},
	groups = {crumbly=3, falling_node=1, sand=1, not_in_creative_inventory=1, soil=3, wet = 1, desert = 1, field = 1},
	sounds = default.node_sound_sand_defaults(),
	soil = {
		base = "default:desert_sand",
		dry = "farming:desert_sand_soil",
		wet = "farming:desert_sand_soil_wet"
	}
})

minetest.register_node("farming:straw", {
	description = S("Straw"),
	tiles = {"farming_straw.png"},
	inventory_image = {"farming_straw.png"},
	is_ground_content = false,
	groups = {snappy=3, flammable=2, fall_damage_add_percent=-30},
	sounds = default.node_sound_leaves_defaults(),
})
minetest.register_node("farming:hemp_fibre", {
	description = S("Hemp Fibre"),
	tiles = {"farming_hemp_fibre.png"},
	inventory_image = "farming_hemp_fibre.png",
	is_ground_content = false,
	groups = {snappy=3, flammable=2, fall_damage_add_percent=-30},
	sounds = default.node_sound_leaves_defaults(),
})
minetest.register_node("farming:nettle_fibre", {
	description = ("Nettle Fibre"),
	tiles = {"farming_nettle_fibre.png"},
	inventory_image = "farming_nettle_fibre.png",
	is_ground_content = false,
	groups = {snappy=3, flammable=2, fall_damage_add_percent=-30},
	sounds = default.node_sound_leaves_defaults(),
})

