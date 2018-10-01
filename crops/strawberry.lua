-- Strawberry
local S = farming.intllib

local possible_biomes={}
for name,def in pairs(minetest.registered_biomes) do
  if def.heat_point > 12 and def.heat_point < 40 and def.humidity_point > 10 and def.humidity_point < 50 then
    table.insert(possible_biomes,1,name)
  end
end
local sdef={
	paramtype2 = "meshoptions",
	steps = 4, -- steps till full-grown plant
	mean_grow_time=20, -- mean time till next step
	range_grow_time=3, -- plus/minus for random generator
	max_harvest=2, -- max amount of harvesting item for full grown plant
--	eat_hp=1, -- set in config for eatable plants
	minlight = 13, 
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland"},
	groups = {food=1,grain = 1, flammable = 4,no_seed=1 ,punchable = 1},
	place_param2 = 3,
	min_temp=10,
	max_temp=50,
	min_humidity=10,
	max_humidity=70,
	spawnon = { spawnon = farming.change_soil or {"default:dirt_with_grass"},
				spawn_min = 0,
				spawn_max = 42,
				spawnby = nil,
				spawn_num = -1},
	description = S("Strawberry"),
	inventory_image = "farming_strawberry.png",
	eat_hp=2,
	steps=4,
	max_harvest=2,
	}

--if(table.getn(possible_biomes)>0) then
--  def.biomes=possible_biomes
--end
print("strawberry")
print(dump(sdef))

farming.register_plant("farming:strawberry", sdef)

