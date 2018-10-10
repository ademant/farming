local S = farming.intllib

farming.path = minetest.get_modpath("farming")

local crop_definition = {}

-- import configurations from crops.csv
local file = io.open(farming.path .. "/crops.csv", "r")
for line in file:lines() do
	local attribs = line:split(",", true)
	local name,enabled,next_plant,rarety,steps,harvest_max,eat_hp,to_culture,to_dig,has_harvest,on_soil,
		punchable,infectable,seed_extractable,use_flail,use_trellis,snappy,temperature_min,temperature_max,
		humidity_min,humidity_max,elevation_min,elevation_max,light_min,light_max,
		infect_rate_base,infect_rate_monoculture,spread_rate,grow_time_mean = unpack(attribs)
	if #name > 0 and name:sub(1,1) ~= "#" and #enabled > 0 and #steps > 0 then
		crop_definition[name]={
			paramtype2 = "meshoptions",
			fertility = {"grassland"},
			place_param2 = 3,
			groups = {farming=1},
			mod_name=minetest.get_current_modname(),
			steps = tonumber(steps),
			environment={
				grow_time_mean=tonumber(grow_time_mean),
				harvest_max=tonumber(harvest_max),
				light_min=tonumber(light_min),
				light_max=tonumber(light_max) or default.LIGHT_MAX,
				temperature_min=tonumber(temperature_min),
				temperature_max=tonumber(temperature_max),
				humidity_min=tonumber(humidity_min),
				humidity_max=tonumber(humidity_max),
				elevation_min=tonumber(elevation_min),
				elevation_max=tonumber(elevation_max),
				rarety=tonumber(rarety),
				},
			name=name,
			description=S(name),
			eat_hp=tonumber(eat_hp),
			next_plant=next_plant,
			spawnon = farming.change_soil or {"default:dirt_with_grass"},
			infect = {
				base_rate = tonumber(infect_rate_base),
				mono_rate = tonumber(infect_rate_monoculture),
				},
			spread = {spreadon = farming.change_soil or {"default:dirt_with_grass"},
				base_rate = tonumber(spread_rate),
				},
			}
			if #on_soil > 0 then
				crop_definition[name].groups["on_soil"]=tonumber(on_soil)
			end
			if #to_culture > 0 then
				crop_definition[name].groups["to_culture"]=tonumber(to_culture)
			end
			if #punchable > 0 then
				crop_definition[name].groups["punchable"]=tonumber(punchable)
			end
			if #has_harvest > 0 then
				crop_definition[name].groups["has_harvest"]=tonumber(has_harvest)
			end
			if #infectable > 0 then
				crop_definition[name].groups["infectable"]=tonumber(infectable)
			end
			if #seed_extractable > 0 then
				crop_definition[name].groups["seed_extractable"]=tonumber(seed_extractable)
			end
			if #use_flail > 0 then
				crop_definition[name].groups["use_flail"]=tonumber(use_flail)
			end
			if #use_trellis > 0 then
				crop_definition[name].groups["use_trellis"]=tonumber(use_trellis)
			end
			if #snappy > 0 then
				crop_definition[name].groups["snappy"]=tonumber(snappy)
			else
				crop_definition[name].groups["snappy"]=3
			end
	end
end
file:close()

-- voids are filled from default
if crop_definition["default"]~=nil then
  local default_def = crop_definition["default"]
  for i,tdef in pairs(crop_definition) do
	if tdef.name ~= "default" then
		local tdef_name = tdef.name
		for _,colu in ipairs({"rarety","harvest_max","temperature_min","temperature_max",
			"humidity_min","humidity_max","elevation_min","elevation_max"}) do
			if crop_definition[tdef_name].environment[colu] == nil then
				crop_definition[tdef_name].environment[colu] = default_def.environment[colu]
			end
		end
		if crop_definition[tdef_name].infect.base_rate == nil then
			crop_definition[tdef_name].infect.base_rate = default_def.infect.base_rate or 0.001
		end
		if crop_definition[tdef_name].infect.mono_rate == nil then
			crop_definition[tdef_name].infect.mono_rate = default_def.infect.mono_rate or 0.01
		end
		if crop_definition[tdef_name].spread.base_rate == nil then
			crop_definition[tdef_name].spread.base_rate = default_def.spread.base_rate or 0.001
		end
		biom_def={
			min_temp=crop_definition[tdef_name].environment.temperature_min,
			max_temp=crop_definition[tdef_name].environment.temperature_max,
			min_humidity=crop_definition[tdef_name].environment.humidity_min,
			max_humidity=crop_definition[tdef_name].environment.humidity_max,
			spawnon={spawn_min=crop_definition[tdef_name].environment.elevation_min,
				spawn_max=crop_definition[tdef_name].environment.elevation_max,
				},}
		local crop_spawnon={}
		local crop_biom = farming.get_biomes(biom_def)
		for _,bio in pairs(crop_biom) do
			local tbio=minetest.registered_biomes[bio]
			if tbio.node_top then
				crop_spawnon[tbio.node_top] = 1
			end
		end
		local csp = {}
		for nod,val in pairs(crop_spawnon) do
			table.insert(csp,nod)
		end
		crop_definition[tdef_name].biomes=crop_biom
		crop_definition[tdef_name].spawnon=csp
		crop_definition[tdef_name].spread.spreadon=csp
	end
  end
end

-- register crops
for i,tdef in pairs(crop_definition) do
	if i ~= "default" then
		print("farming registering "..tdef.name)
		farming.register_plant(tdef)
	end
end
