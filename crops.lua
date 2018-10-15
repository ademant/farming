--[[
Loading of crop definition stored in a csv file.
The import is extendable, so new columns in the config file are imported to new field in the table.
First line: Header
Second line should be default crop, where several default values are stored.
Actual columns:
	Name					Name of the crop. Is used for registering all nodes and craftitems
	Enabled		void		crop is not registered in the game
				an value	crop is registered with configured features
	next_plant	text		For wild crop the name of the cultured crop. By change you get the seed or harvest of the cultured one
							Should be a name of another crop in this list
	Rarety					How often the crop spawn in the wild
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
	straw		text		extension for using flail: item name of fibre to craft out of harvest beside seeds
	culture_rate			rate to get cultured variant out of wild form.
	seed_drop				name of seed you get from plant: grapes drops seed which normally lead to wild wine.
							Only with a trellis you get cultured whine with higher harvest.
							With normal grapes and a trellis you get the "seed" for cultured wine.
]]

local S = farming.intllib
farming.path = minetest.get_modpath("farming")

local has_value = farming.has_value 

local crop_definition = {}
local crop_numeric_values = {"rarety","steps","harvest_max","eat_hp",
	"temperature_min","temperature_max","humidity_min","humidity_max",
	"elevation_min","elevation_max","light_min","light_max",
	"infect_rate_base","infect_rate_monoculture","spread_rate","grow_time_mean"}
local crop_groups = 
	{"to_culture","to_dig","has_harvest","on_soil","punchable","infectable",
	"seed_extractable","use_flail","use_trellis","snappy","infection_defence"}

local crop_definition = farming.import_csv(farming.path.."/crops.txt",{
	col_num=crop_numeric_values,
	groups_num=crop_groups})

print(dump(crop_definition))

--[[
-- import configurations from crops.csv
local file = io.open(farming.path .. "/crops.txt", "r")
-- reading header with column names
local header = file:read():split(",",true)
-- read each line, split in separat fields and stores in array
-- by header the value is stored as numeric, in the group environment or as text
for line in file:lines() do
	local attribs = line:split(",",true)
	local nrow={groups={}}
	for i,d in ipairs(attribs) do
		if d ~= "" then
			local th=header[i]
			if has_value(crop_numeric_values,th) then
				nrow[th] = tonumber(d)
			else
				if has_value(crop_groups,th) then
					nrow.groups[th]=tonumber(d)
				else
					nrow[header[i] ]=d
				end
			end
		end
	end
	if nrow.enabled then
		crop_definition[nrow.name]=nrow
	end
end
file:close()
]]
-- for the default entry is checked, which numeric values are filled
-- this values are copied into void fields of the crops
if crop_definition["default"] ~= nil then
	default_crop = crop_definition["default"]
	local test_values = {}
	for i,d in pairs(crop_numeric_values) do
		if default_crop[d] ~= nil then
			table.insert(test_values,1,d)
		end
	end
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
			print("farming registering "..tdef.name)
			farming.register_plant(tdef)
		else
			print("farming "..tdef.name.." disabled")
		end
	end
end
