local S = farming.intllib

farming.path = minetest.get_modpath("farming")

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

local crop_definition = {}
local crop_numeric_values = {"rarety","steps","harvest_max","eat_hp","temperature_min","temperature_max","humidity_min","humidity_max","elevation_min","elevation_max","light_min","light_max","infect_rate_base","infect_rate_monoculture","spread_rate","grow_time_mean"}
local crop_groups = {"to_culture","to_dig","has_harvest","on_soil","punchable","infectable","seed_extractable","use_flail","use_trellis","snappy","infection_defence"}

-- import configurations from crops.csv
local file = io.open(farming.path .. "/crops.csv", "r")
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
					nrow[header[i]]=d
				end
			end
		end
	end
	if nrow.enabled then
		crop_definition[nrow.name]=nrow
	end
end
file:close()

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
		if tdef.enabled then
			print("farming registering "..tdef.name)
			farming.register_plant(tdef)
		else
			print("farming "..tdef.name.." disabled")
		end
	end
end
