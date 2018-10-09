local S = farming.intllib

farming.path = minetest.get_modpath("farming")

local crop_definition = {}

local file = io.open(farming.path .. "/crops.csv", "r")
for line in file:lines() do
	local attribs = line:split(",", true)
	local name,enabled,next_plant,rarety,steps,harvest_max,eat_hp,to_culture,has_harvest,on_soil,punchable,infectable,
		seed_extractable,snappy,temperature_min,temperature_max,humidity_min,humidity_max,elevation_min,elevation_max,
		infect_rate_base,infect_rate_monoculture,spread_rate = unpack(attribs)
	if #name > 0 and name:sub(1,1) ~= "#" and #enabled > 0 and #steps > 0 then
		biom_def={min_temp=tonumber(temperature_min) or 0,
			max_temp=tonumber(temperature_max) or 100,
			min_humidity=tonumber(humidity_min) or 0,
			max_humidity=tonumber(humidity_max) or 100,
			spawnon={spawn_min=tonumber(elevation_min) or 0,
				spawn_max=tonumber(elevation_max)} or 31000,
				}
		crop_definition[name]={
			paramtype2 = "meshoptions",
			fertility = {"grassland"},
			place_param2 = 3,
			groups = {farming=1},
			steps = tonumber(steps),
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
			description=S(name),
			eat_hp=tonumber(eat_hp),
			next_plant=next_plant,
			spawnon = farming.change_soil or {"default:dirt_with_grass"},
			next_plant="farming:culturewheat",
			next_plant_rarity=12,
			infect = {
				base_rate = tonumber(infect_rate_base),
				mono_rate = tonumber(infect_rate_monoculture),
				},
			spread = {spreadon = farming.change_soil or {"default:dirt_with_grass"},
				base_rate = tonumber(spread_rate),
				},
			biomes=farming.get_biomes(biom_def),
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
			if #snappy > 0 then
				crop_definition[name].groups["snappy"]=tonumber(snappy)
			else
				crop_definition[name].groups["snappy"]=3
			end
	end
end

if crop_definition["default"]~=nil then
  local default_def = crop_definition["default"]
  print(#crop_definition)
  print(dump(default_def))
  for i,tdef in ipairs(crop_definition) do
	print(dump(tdef))
	if tdef.name ~= "default" then
		local tdef_name = tdef.name
		for _,colu in ipairs({"rarety","harvest_max","temperature_min","temperature_max",
			"humidity_min","humidity_max","elevation_min","elevation_max",
			"infect_rate_base","infect_rate_monoculture","spread_rate"}) do
			print(colu)
			if crop_definition[tdef_name][colu] == nil then
				print(colu)
				print(default_def[colu])
				crop_definition[tdef_name][colu] = default_def[colu]
			end
		end
	end
  end
end
--	print(dump(crop_definition))
