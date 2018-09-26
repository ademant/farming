-- Strawberry
local S = farming.intllib

local possible_biomes={}
for name,def in pairs(minetest.registered_biomes) do
  if def.heat_point > 12 and def.heat_point < 40 and def.humidity_point > 10 and def.humidity_point < 50 then
    table.insert(possible_biomes,1,name)
  end
end

local def={
	description = S("Strawberry"),
	paramtype2 = "meshoptions",
	inventory_image = "farming_strawberry.png",
	steps = 4,
	max_harvest=2,
	eat_hp=2,
	minlight = 13,
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland"},
	groups = {food_wheat = 1, punchable = 1, flammable = 4, no_seed=1},
	place_param2 = 3,
	spawnon = { spawnon = farming.change_soil or {"default:dirt_with_grass"},
				spawn_min = 0,
				spawn_max = 42,
				spawnby = nil,
				scale = 0.006, -- 0.006
				spawn_num = -1}
}
if(table.getn(possible_biomes)>0) then
  def.biomes=possible_biomes
end

farming.register_plant("farming:strawberry", def)

