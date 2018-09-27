-- Strawberry
local S = farming.intllib

local possible_biomes={}
for name,def in pairs(minetest.registered_biomes) do
  if def.heat_point > 12 and def.heat_point < 40 and def.humidity_point > 10 and def.humidity_point < 50 then
    table.insert(possible_biomes,1,name)
  end
end
local def=farming.plant_def
def.description = S("Strawberry")
def.inventory_image = "farming_strawberry.png"
def.eat_hp=2
def.groups.food=1
def.steps=4
def.max_harvest=2
def.groups.food_wheat=1

--if(table.getn(possible_biomes)>0) then
--  def.biomes=possible_biomes
--end

farming.register_plant("farming:strawberry", def)

