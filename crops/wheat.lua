-- WHEAT
local S = farming.intllib

local def=farming.plant_def
def.description = S("Wheat Seed")
def.inventory_image = "farming_wheat_seed.png"
def.eat_hp=1
def.next_plant="farming:culturewheat"
def.next_plant_rarity=12
def.groups.food_wheat=1
--print(dump(def))
--if(table.getn(farming.possible_biomes)>0) then
--  def.biomes=farming.possible_biomes
--end
farming.register_plant("farming:wheat", def)

local def=farming.plant_def
def.description = S("Culture Wheat Seed")
def.inventory_image = "farming_culturewheat_seed.png"
def.eat_hp=1
def.steps=4
def.eat_hp=1
def.max_harvest=4
def.min_light=11
def.mean_grow_time=20
def.range_grow_time=5
def.groups.food_wheat=1
def.groups.no_spawn=1
if(table.getn(farming.possible_biomes)>0) then
  def.biomes=farming.possible_biomes
end
farming.register_plant("farming:culturewheat", def)

