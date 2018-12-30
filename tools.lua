local S = farming.intllib
farming.path = minetest.get_modpath("farming")

local has_value = basic_functions.has_value 
local crop_cols={
	col_num={"max_uses","farming_change","max_level","damage","times"},
	groups_num={"snappy"}}
local tool_definition = basic_functions.import_csv(farming.path.."/tools.txt",crop_cols)

for i,line in pairs(tool_definition) do
	
	tool_def={description=S(line.name:gsub("_"," ")),
		inventory_image="farming_tool_"..line.name..".png",
		max_uses=line.max_uses,
		farming_change=line.farming_change,
		material = line.material,
		groups={flammable = 2},
		tool_capabilities = {
			full_punch_intervall = 1.0,
			max_drop_level = 4,
			groupcaps={
				snappy = {times={[1]=line.times,[2]=0.4*line.times,[3]=0.25*line.times},
					uses=line.max_uses,
					maxlevel=line.max_level,
					},},
				damage_groups = {fleshy = line.damage}
			}
		}
	local tooltype=line.name:split("_")[1]
	if tooltype=="billhook" then
		farming.register_billhook("farming:"..line.name,tool_def)
	elseif tooltype=="scythe" then
		farming.register_scythe("farming:"..line.name,tool_def)
	elseif tooltype=="hoe" then
		farming.register_hoe("farming:"..line.name,tool_def)
	end
end

-- Picker
-- to extract seeds from crops, which usually give harvest, e.g. tea
farming.register_tool("farming:picker", {
	description = S("Seed Picker"),
	inventory_image = "farming_tool_picker.png",
	groups = {farming_picker = 1, flammable = 2},
	max_uses=30,
	tool_capabilities = {
		full_punch_intervall = 1.0,
		max_drop_level = 2,
		groupcaps = {
			snappy = {times={[1]=5,[2]=2,[3]=1.4},},
			uses=30,
			maxlevel=3,
		},
		damage_groups = {fleshy = 1},
	},
	recipe= {
		{"", "", "group:stick"},
		{"", "group:stick", "group:wool"},
		{"group:stick", "", ""},
	},
	on_use = function(itemstack, user, pointed_thing)
		return farming.use_picker(itemstack, user, pointed_thing, 30)
		end

})
