--[[
Loading of crop definition stored in a csv file.
The import is extendable, so new columns in the config file are imported to new field in the table.
First line: Header
Second line should be default crop, where several default values are stored.
Actual columns:
	Name					Name of the crop. Is used for registering all nodes and craftitems
	Enabled		void		crop is not registered in the game
				an value	crop is registered with configured features
	hijack		text		Which crop of other mod should be hijacked (not to use in mod:farming)
	next_plant	text		For wild crop the name of the cultured crop. By change you get the seed or harvest of the cultured one
							Should be a name of another crop in this list
	Rarety					How often the crop spawn in the wild
	Rarety_grass_drop		Change to get crop as drop item when digging grass
	Rarety_junglegrass_drop	Change to get crop as drop item when digging jungle grass
	Steps					Amount of steps the growing needs till full grown plant. Must be set
	harvest_max				Max. amount of harvest or seed you can dig out of full grown plant
	eat_hp					eat health point: How many HP you get by eating the seed.
	to_culture	void		crop can be generated during mapgen and spawn randomly on grassland
				any value	crop can not be find randomly on the map. The seed has to be found in the wild form or crafted.
	to_dig		void
				any value
	has_harvest	void		drops seed which can be used for planting new crops
				any value	drops harvest, where the seed has to be crafted out of the harvest
	on_soil		void		can be planted everywhere where the conditions are met (temperature etc.)
				any value	crap can be found in the wild, but planted only on wet soil, 
							without checking for temperature etc.
	punchable	void		the plant has to be dug to get harvest or seed
				any value	by punching the last step of the crop, you get one seed and the plant change 
							to second last stage
	infectable	void		
				any value	the plant can be infected, where the crop does not give any seed or harvest 
							and may infect other crops nearby
							Higher values means more infectable
	wiltable	void		
				1			Wilt is going one step back, like Berries: They loose the fruits, but grow again
				2			Plant wilt and remove itself after time. During wilt you can harvest straw if defined.
							For grain
				3			crop is spreading seed around and go one step back or dies like nettles
	is_bush		void
				any value	define a bush with a mesh instead of tiles
	infection_defense
				any value	can protect nearby crop against infection. value give range of protection
	seed_extractable
				any value	crop gives normally only harvest, out of which no seeds can be crafted, like tea.
	no_seed		void
				any value
	use_flail	void
				any value	extension to define crafting recipe: With flail you get the seeds out of harvest 
							and kind of fibres/straw
	use_trellis	void
				any value	the crop needs kind of trellis for growing. the trellis is recyclable:
							You get the trellis back by digging the plant at any stage.
	for_coffee	void
				any value	extension to define crafting recipes to brew coffee out of seed
	for_flour	void
				any value	extension to define crafting recipes to craft normal flour out of seed
	seed_roastable
				any value	seed can be roasted in a oven, needs "crop_roasted.png"
							value is used as roast time
	seed_grindable
				any value	seed can be grinded, e.g. in a coffee grinder, needs "crop_grind.png" or value in grind
	damage_per_second
				any value	damage a player get while in a node with this crop, e.g. thorns of raspberries
	liquid_viscosity
				any value	resistance a player sees while walking through a field
	temperature_min/_max	Range of temperature inside the crop can grow.
	humidity_min/_max		Range of humidity
	elevation_min/_max		Height range the crop can be found
	light_min				Minimun amount of light needed for growing. Crop can be planted only on placed
							where light_min is reached at midday. It is also needed for calculating the grow_time.
							With more light at midday the crop grows faster.
	light_max				If node light exceed this value after grow time, the timer starts again without growing.
	infect_rate_base		Normal infect rate for crops
	infect_rate_monoculture	Infect rate if many crops are standing nearby.
	spread_rate				Full grown crops can spread to neighbor block
	grow_time_mean			mean grow time to next step
	wilt_time				Time for wilt of a crop
	straw		text		extension for using flail: item name of fibre to craft out of harvest beside seeds
	culture_rate			rate to get cultured variant out of wild form.
	seed_drop				name of seed you get from plant: grapes drops seed which normally lead to wild wine.
							Only with a trellis you get cultured whine with higher harvest.
							With normal grapes and a trellis you get the "seed" for cultured wine.
	grind					name of item for grinded seed
]]

local S = farming.intllib
farming.path = minetest.get_modpath("farming")

local has_value = basic_functions.has_value 
local crop_cols={
	col_num={"rarety","steps","harvest_max","eat_hp",
	"temperature_min","temperature_max","humidity_min","humidity_max",
	"elevation_min","elevation_max","light_min","light_max",
	"infect_rate_base","infect_rate_monoculture","spread_rate","grow_time_mean","roast_time","wilt_time","rarety_grass_drop"},
	groups_num={"to_culture","to_dig","has_harvest","on_soil","punchable","infectable","is_bush",
	"seed_extractable","use_flail","use_trellis","snappy","infection_defence","seed_roastable",
	"seed_grindable","for_flour","for_coffee","damage_per_second","liquid_viscosity","wiltable"}}
local crop_definition = basic_functions.import_csv(farming.path.."/crops.txt",crop_cols)
-- for the default entry is checked, which numeric values are filled
-- this values are copied into void fields of the crops
if crop_definition["default"] ~= nil then
	default_crop = crop_definition["default"]
	local test_values = {}
	-- check, which numeric columns exist in default entry
	for i,d in pairs(crop_cols.col_num) do
		if default_crop[d] ~= nil then
			table.insert(test_values,1,d)
		end
	end

	-- check for each crop, if value can be copied from default entry
	for i,tdef in pairs(crop_definition) do
		if tdef.name ~= default_crop.name then
			for j,colu in pairs(test_values) do
				if tdef[colu] == nil then
					crop_definition[tdef.name][colu] = default_crop[colu]
				end
			end
		end
	end
end

-- register crops
for i,tdef in pairs(crop_definition) do
	if i ~= "default" then
	
		-- only register when crop is enabled
		if tdef.enabled then
			local starttime=os.clock()
			farming.register_plant(tdef)
			print("farming registering "..tdef.name.." in "..(math.floor(1000000*(os.clock()-starttime))/1000).." milliseconds")
		else
			print("farming "..tdef.name.." disabled")
		end
	end
end

local no_items=tonumber(#farming.grass_drop.items)
local tgd={items={}}
for i,gdrop in pairs(farming.grass_drop.items) do
	if gdrop.rarity ~= nil then
	  gdrop.rarity=gdrop.rarity * (1 + no_items - tonumber(i))
	end
	table.insert(tgd.items,gdrop)
end
minetest.override_item("default:grass_5",{drop=tgd})
minetest.override_item("default:grass_4",{drop=tgd})
local no_items=tonumber(#farming.junglegrass_drop.items)
local tgd={items={}}
for i,gdrop in pairs(farming.junglegrass_drop.items) do
	if gdrop.rarity ~= nil then
	  gdrop.rarity=gdrop.rarity * (1 + no_items - tonumber(i))
	end
	table.insert(tgd.items,gdrop)
end
minetest.override_item("default:junglegrass",{drop=tgd})
