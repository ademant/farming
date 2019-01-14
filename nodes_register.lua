local S = farming.intllib
	-- fallback default definition, if no defaults given by configuration
local farming_default_env={temperature_min=0,temperature_max=100,humidity_min=0,humidity_max=100,
	elevation_min=0,elevation_max=31000,light_min=10,light_max=default.LIGHT_MAX,rarety=10,
	grow_time_mean=120,spread_rate=1e-5,infect_rate_base=1e-5,infect_rate_monoculture=1e-3,
	harvest_max=2,place_param2 = 3,}

-- function to check definition for a plant
-- and set to defaults values
local register_plant_check_def = function(def) -- time optimised
--	local starttime=os.clock()
	local actmodname=minetest.get_current_modname()
	local base_name=actmodname..":"..def.name
	def.mod_name=actmodname
	def.plant_name=def.name
	def.base_name=base_name
	def.basepng=base_name:gsub(":","_")
	
	for dn,dv in pairs(farming_default_env) do
		if def[dn] == nil then
			def[dn] = dv
		end
	end
	if not def.description then
		def.description = def.name:gsub("^%l", string.upper)
	end
	if not def.fertility then
		def.fertility = {"grassland"}
	end
	if def.groups.seed_grindable ~= nil then
		if not def.grind  then
			def.grind = base_name.."_grinded"
		end
	end
	if def.groups.seed_roastable ~= nil then
		if not def.roast then
			def.roast = base_name.."_roasted"
		end
	end
	if def.groups.for_coffee ~= nil then
		if def.roast ~= nil then
			if string.find(def.roast,"roasted")~=nil then
				def.coffeepowder=def.roast:gsub("roasted","powder")
			end
		end
	end
	-- check if seed_drop is set and check if it is a node name
	if def.seed_drop then
		if not string.match(def.seed_drop,":") then
			def.seed_drop=actmodname..":"..def.seed_drop
		end
		def.groups["has_harvest"] = 1
	end
	if def.groups.wiltable then
		if not def.wilt_time then
			def.wilt_time = farming.wilt_time
		end
	end
	if not def.place_param2 then
		def.place_param2 = 3
	end
	def.grow_time_min=math.floor(def.grow_time_mean*0.75)
	def.grow_time_max=math.floor(def.grow_time_mean*1.2)
--	print("time check definition "..1000*(os.clock()-starttime))
  return def
end

-- Register plants
farming.register_plant = function(def)
	-- Check def table
	if not def.steps then
		return nil
	end
	-- check definition
    def = register_plant_check_def(def)
	-- local definitions
	def.step_name=def.mod_name..":"..def.name
	def.seed_name=def.mod_name..":"..def.name.."_seed"
	def.plant_name = def.name
	local def_groups=def.groups
    -- if plant has harvest then registering
    if def_groups["has_harvest"] ~= nil then
		-- if plant drops seed of wild crop, set the wild seed as harvest
		if def.seed_drop ~= nil then
			def.harvest_name = def.seed_drop
		else
			def.harvest_name = def.step_name
		end
		print(def.harvest_name)
		farming.register_harvest(def)
    else
		def.harvest_name=def.seed_name
    end
    
    if def_groups["wiltable"] == 2 then
		def.wilt_name=def.mod_name..":wilt_"..def.name
		farming.register_wilt(def)
	end

    farming.register_seed(def)

	farming.register_steps(def)
	
	-- crops, which should be cultured, does not randomly appear on the field
	if (not def_groups["to_culture"]) then
		local edef=def
		local spread_def={name=def.step_name.."_1",
				temp_min=edef.temperature_min,temp_max=edef.temperature_max,
				hum_min=edef.humidity_min,hum_max=edef.humidity_max,
				y_min=edef.elevation_min,y_max=edef.elevation_max,base_rate = math.floor(math.log(def.spread_rate*1e10)),
				light_min=edef.light_min,light_max=edef.light_max}
		farming.min_light = math.min(farming.min_light,edef.light_min)
		table.insert(farming.spreading_crops,1,spread_def)
	end
	
    if def_groups["infectable"] then
      farming.register_infect(def)
    end
    
    -- if defined special roast, grind item or seed to drop,
    -- check if the item already exist. when not than register it.
    for _,it in ipairs({"roast","grind","seed_drop"}) do
		if def[it] ~= nil then
			if minetest.registered_craftitems[def[it]] == nil then
				farming.register_craftitem(def[it])
			end
		end
	end

    if def_groups["use_flail"] then
		if def.straw == nil then
			def.straw= "farming:straw"
		end
		farming.craft_seed(def)
    end

    if def_groups["use_trellis"] then
		farming.trellis_seed(def)
--		print(dump(def))
    end

    if def_groups["seed_grindable"] then
		farming.register_grind(def)
    end

    if def_groups["seed_roastable"] then
		farming.register_roast(def)
    end

    if def_groups["for_coffee"] then
		farming.register_coffee(def)
    end

	if def.rarety_grass_drop ~= nil then
		if def.harvest_name ~= nil then
			table.insert(farming.grass_drop.items,1,{items={def.harvest_name},rarity=def.rarety_grass_drop})
		end
	end
	if def.rarety_junglegrass_drop ~= nil then
		if def.harvest_name ~= nil then
			table.insert(farming.junglegrass_drop.items,1,{items={def.harvest_name},rarity=def.rarety_junglegrass_drop})
		end
	end
	
   	farming.registered_plants[def.name] = def
end

farming.register_harvest=function(hdef) --time optimised
	-- base definition of harvest
	local harvest_def={
		description = S(hdef.description),
		inventory_image = hdef.mod_name.."_"..hdef.plant_name..".png",
		groups = {flammable = 2,farming_harvest=1},
		plant_name=hdef.plant_name,
	}
--	print(hdef.step_name)
	minetest.register_craftitem(":" .. hdef.step_name, harvest_def)
end

farming.register_craftitem = function(itemname)
	local desc = itemname:split(":")[2]
	local item_def={
		description = S(desc:gsub("^%l", string.upper)),
		inventory_image = itemname:gsub(":","_")..".png",
		groups = {flammable = 2},
	}
	minetest.register_craftitem(":"..itemname,item_def)
end

farming.register_infect=function(idef)
--	local starttime=os.clock()
	local infectpng=idef.mod_name.."_"..idef.plant_name.."_ill.png"
	local infect_def={
		description = S(idef.description),
		tiles = {infectpng},
		drawtype = "plantlike",
		waving = 1,
		paramtype = "light",
		walkable = false,
		buildable_to = true,
		on_dig = farming.plant_cured , -- why digging fails?
		selection_box = {type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},},
		sounds = default.node_sound_leaves_defaults(),
		on_timer=farming.timer_infect,
		place_param2=idef.place_param2,
		groups = {snappy = 3, attached_node = 1, flammable = 2,farming_infect=2},
	}
	
	for _,coln in ipairs({"step_name","name","seed_name","plant_name",
		"infect_rate_base","infect_rate_monoculture"}) do
	  infect_def[coln] = idef[coln]
	end

	infect_def.groups[idef.plant_name] = 0
	minetest.register_node(":" .. idef.name.."_infected", infect_def)
--	print("time register infect "..1000*(os.clock()-starttime))
end
farming.register_wilt=function(idef)
--	local starttime=os.clock()
	if not idef.wilt_name then
		return
	end
	local wilt_def={
		description = S(idef.description:gsub("^%l", string.upper).." wilted"),
		tiles = {idef.basepng.."_wilt.png"},
		drawtype = "plantlike",
		waving = 1,
		paramtype = "light",
		walkable = false,
		buildable_to = true,
		selection_box = {type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},},
		sounds = default.node_sound_leaves_defaults(),
		on_timer = farming.timer_wilt,
		place_param2=idef.place_param2,
		groups = {snappy = 3, attached_node = 1, flammable = 2,farming_wilt=1},
	}

	if idef.straw then
		wilt_def.drop={items={{items={idef.straw}}}}
	end
	
	for _,coln in ipairs({"name","seed_name","plant_name","fertility"}) do
	  wilt_def[coln] = idef[coln]
	end

	if idef.groups.wiltable then
		wilt_def.groups["wiltable"]=idef.groups.wiltable
	end
	minetest.register_node(":" .. idef.wilt_name, wilt_def)
--	print("time register wilt "..1000*(os.clock()-starttime))
end


farming.register_seed=function(sdef) --time optimised
--	local starttime=os.clock()
    local seed_def = {
		description=S(sdef.name:gsub("^%l", string.upper).." Seed"),
		next_step = sdef.step_name .. "_1",
		drawtype = "signlike",
		paramtype = "light",
		paramtype2 = "wallmounted",
		walkable = false,
		sunlight_propagates = true,
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
		},
		sounds = default.node_sound_dirt_defaults({
			dig = {name = "", gain = 0},
			dug = {name = "default_grass_footstep", gain = 0.2},
			place = {name = "default_place_node", gain = 0.25},
		}),
		on_place = farming.seed_on_place,
		on_timer = farming.timer_seed,
		place_param2=sdef.place_param2,
		groups = {farming_seed = 1, snappy = 3, attached_node = 1, flammable = 2},
	}
	
	for i,colu in ipairs({"fertility","plant_name","grow_time_min","grow_time_max","light_min"}) do
	  seed_def[colu] = sdef[colu]
	end
	
	local invimage=sdef.seed_name:gsub(":","_")..".png"
	seed_def.inventory_image = invimage
	seed_def.tiles = {invimage}
	seed_def.wield_image = {invimage}
	seed_def.groups[sdef.mod_name] = 1
	
	for k, v in pairs(sdef.fertility) do
		seed_def.groups[v] = 1
	end
	
	for i,colu in ipairs({"on_soil","for_flour"}) do 
		if sdef.groups[colu] then
		  seed_def.groups[colu] = sdef.groups[colu]
		end
	end
	
	if sdef.eat_hp or sdef.drink then
		local eat_hp=0
		if sdef.eat_hp then
			eat_hp=sdef.eat_hp
		end
		seed_def.on_use=minetest.item_eat(eat_hp)
		if sdef.eat_hp then
			seed_def.groups["eatable"]=sdef.eat_hp
		end
		if sdef.drink then
			seed_def.groups["drinkable"]=sdef.drink
		end
	end
	
	minetest.register_node(":" .. sdef.seed_name, seed_def)
--	print("time register seed "..1000*(os.clock()-starttime))
end

farming.register_steps = function(sdef)
--	local starttime=os.clock()
    -- base configuration of all steps
	-- copy some plant definition into definition of this steps
	-- define drop item: normal drop the seed
	local dropitem=sdef.seed_name
	-- if plant has to be harvested, drop harvest instead
	if sdef.groups.has_harvest then
		if sdef.seed_drop then
			dropitem = sdef.seed_drop
		else
			dropitem = sdef.step_name
		end
	end
	
	local is_hurting=(sdef.groups.damage_per_second~=nil)
	local damage=0
	
	if is_hurting then
		damage=sdef.groups.damage_per_second
	end
	
	local is_viscos=(sdef.groups.liquid_viscosity and farming.config:get_int("viscosity") > 0)
	local viscosity=0
	if is_viscos then
		viscosity=sdef.groups.liquid_viscosity
	end
	
	local max_step=sdef.steps
	local stepname=sdef.step_name.."_"
	for i=1,max_step do
		local reli=i/max_step
	    local ndef={description=stepname..i,
			drawtype = "plantlike",
			waving = 1,
			paramtype = "light",
			walkable = false,
			buildable_to = true,
			selection_box = {type = "fixed",
				fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},},
			sounds = default.node_sound_leaves_defaults(),
			drop_item=dropitem,
			drop={items={{items={dropitem}}}},
			tiles={sdef.basepng.."_"..i..".png"},
			place_param2=sdef.place_param2,
			groups = {snappy = 3, flammable = 2,flora=1, plant = 1, 
				not_in_creative_inventory = 1, attached_node = 1,
				step=i,
				},
		}
		
	    for _,colu in ipairs({"grow_time_min","grow_time_max","light_min","plant_name"}) do
			ndef[colu]=sdef[colu]
		end
		
		for _,colu in ipairs({"infectable","snappy","damage_per_second","liquid_viscosity","wiltable"}) do
			if sdef.groups[colu] then
			  ndef.groups[colu] = sdef.groups[colu]
			end
		end
		
		ndef.groups[sdef.mod_name]=1
		ndef.groups[sdef.plant_name]=1
		if sdef.groups.use_trellis then
			table.insert(ndef.drop.items,1,{items={"farming:trellis"}})
		end

		if i < max_step then
			ndef.groups["farming_grows"]=1 -- plant is growing
			ndef.next_step=stepname.. (i + 1)
			ndef.on_timer = farming.timer_step
			ndef.grow_time_min=sdef.grow_time_min
			ndef.grow_time_max=sdef.grow_time_max
		end

		-- hurting and viscosity not for first step, which is used for random generation
		if i > 1 then
			-- check if plant hurts while going through
			if is_hurting then
				-- calculate damage as part of growing: Full damage only for full grown plant
				local step_damage=math.ceil(damage*reli)
				if step_damage > 0 then
					ndef.damage_per_second = step_damage
				end
			end

			-- for some crops you should walk slowly through like a wheat field
			if is_viscos then
				local step_viscosity=math.ceil(viscosity*reli)
				if step_viscosity > 0 then 
					ndef.liquid_viscosity= step_viscosity
					ndef.liquidtype="source"
					ndef.liquid_alternative_source=ndef.description
					ndef.liquid_alternative_flowing=ndef.description
					ndef.liquid_renewable=false
					ndef.liquid_range=0
				end
			end
		end

		-- with higher grow levels you harvest more
		local step_harvest = math.floor(reli*sdef.harvest_max + 0.05)
		if step_harvest > 1 then
		  for h = 2,step_harvest do
			table.insert(ndef.drop.items,1,{items={dropitem},rarity=(max_step - i + 1)*h})
		  end
		end

		if i == max_step then
			ndef.groups["farming_fullgrown"]=1
			for _,colu in ipairs({"punchable","seed_extractable"}) do
				if sdef.groups[colu] then
				  ndef.groups[colu] = sdef.groups[colu]
				end
			end
			ndef.on_dig = farming.dig_harvest
			if sdef.groups.wiltable  then

				local nowilt=sdef.groups.wiltable
				if nowilt == 2 then
					ndef.next_step=sdef.wilt_name
				elseif nowilt == 1 then
					ndef.next_step = stepname .. (i - 1)
				elseif nowilt == 3 then
					ndef.pre_step = stepname .. (i - 1)
					ndef.seed_name=sdef.seed_name
				end

				ndef.on_timer = farming.timer_step
				ndef.grow_time_min=sdef.wilt_time or 10
				ndef.grow_time_max=math.ceil(ndef.grow_time_min*1.1)
			end

			-- at the end stage you can harvest by change a cultured seed (if defined)
			if sdef.next_plant then
			  local next_plant_rarity = (max_step - i + 1)*2
			  --table.insert(ndef.drop.items,1,{items={sdef.next_plant},rarity=next_plant_rarity})
			end

			if sdef.groups.punchable and i > 1 then
				ndef.pre_step = stepname.. (i - 1)
				ndef.on_punch = farming.punch_step
			end
			
			if sdef.groups.seed_extractable then
				ndef.seed_name = sdef.seed_name
			end
		end
--		print(dump(ndef))
		minetest.register_node(":" .. ndef.description, ndef)
	end
--	print("time register step "..1000*(os.clock()-starttime))
end



-- define seed crafting out of harvest, releasing kind of straw
function farming.craft_seed(gdef)
	if gdef.seed_name == nil then
		return
	end
	if gdef.harvest_name == nil then
		return
	end
	
	local straw_name = "farming:straw"
	if gdef.straw ~= nil then
		straw_name = gdef.straw
	end
	
	minetest.register_craft({
		type = "shapeless",
		output = gdef.seed_name.." 1",
		recipe = {
			farming.modname..":flail",gdef.harvest_name
		},
		replacements = {{"group:farming_flail", farming.modname..":flail"},
				{gdef.harvest_name,straw_name}},
	})
end

function farming.register_coffee(cdef)
	local starttime=os.clock()
	if not cdef.coffeepowder then
		return
	end
	if not cdef.roast then
		return
	end
	
	local powder_png = cdef.coffeepowder:gsub(":","_")..".png"
	
	local powder_def={
		description = S(cdef.description:gsub("^%l", string.upper).." powder"),
		inventory_image = powder_png,
		groups = {flammable = 2,food_grain_powder=1},
		plant_name=cdef.plant_name,
	}
	
	if cdef.eat_hp then
	  powder_def.on_use=minetest.item_eat(cdef.eat_hp)
	  powder_def.groups["eatable"]=cdef.eat_hp
	end
	minetest.register_craftitem(":" .. cdef.coffeepowder, powder_def)
	
	minetest.register_craft({
		type = "shapeless",
		output = cdef.coffeepowder,
		recipe = {cdef.roast,
				farming.modname..":coffee_grinder"},
	replacements = {{"group:food_coffee_grinder", farming.modname..":coffee_grinder"}},

	})
--	print("time register coffee "..1000*(os.clock()-starttime))
end

-- registering roast items if needed for plant
function farming.register_roast(rdef)
	local starttime=os.clock()
	if not rdef.seed_name then
		return
	end
	if not rdef.roast then
		return
	end
	
	local roastitem=rdef.roast
	-- if no roast defined in config, register an own roast item
	if minetest.registered_craftitems[roastitem] == nil then
		local roast_png = roastitem:gsub(":","_")..".png"
		local rn = roastitem:split(":")[2]
		rn=rn:gsub("_"," ")
		
		local roast_def={
			description = S(rdef.description:gsub("^%l", string.upper)),
			inventory_image = roast_png,
			groups = {flammable = 2},
			plant_name=rdef.plant_name,
		}
		
		if rdef.groups.seed_roastable then
			roast_def.groups["seed_roastable"] = rdef.groups.seed_roastable
		end
		if rdef.eat_hp then
		  roast_def.on_use=minetest.item_eat(rdef.eat_hp*2)
		  roast_def.groups["eatable"]=rdef.eat_hp*2
		end
		
		minetest.register_craftitem(":" .. roastitem, roast_def)
	end
	
	local cooktime = 3
	if rdef.groups.seed_roastable then
		cooktime = rdef.groups.seed_roastable
	end
	
	local seedname=rdef.seed_name
	if rdef.seed_drop ~= nil then
		seedname=rdef.seed_drop
	end
	
	minetest.register_craft({
		type = "cooking",
		cooktime = cooktime or 3,
		output = roastitem,
		recipe = seedname
	})
--	print("time register roast "..1000*(os.clock()-starttime))
end

-- registering grind items
function farming.register_grind(rdef)
	local starttime=os.clock()
	if rdef.seed_name == nil then
		return
	end
	if rdef.step_name == nil then
		return
	end
	
	local grinditem = rdef.step_name.."_flour"
	if rdef.grind then
		grinditem = rdef.grind
	end
	
	local desc = grinditem:split(":")[2]
	desc = desc:gsub("_"," ")
	local grind_png = grinditem:gsub(":","_")..".png"
	
	local grind_def={
		description = S(desc:gsub("^%l", string.upper).." roasted"),
		inventory_image = grind_png,
		groups = {flammable = 2},
		plant_name=rdef.plant_name,
	}
	
	if rdef.eat_hp then
	  grind_def.on_use=minetest.item_eat(rdef.eat_hp)
	  grind_def.groups["eatable"]=rdef.eat_hp
	end
	
	minetest.register_craftitem(":" .. grinditem, grind_def)
	
	minetest.register_craft({
		type = "shapeless",
		output = grinditem,
		recipe = {rdef.seed_name.." "..rdef.groups["seed_grindable"],
				farming.modname..":mortar_pestle"},
		replacements = {{"group:food_mortar_pestle", farming.modname..":mortar_pestle"}},

	})
--	print("time register grind "..1000*(os.clock()-starttime))
end

farming.trellis_seed = function(gdef)
	if gdef.seed_name == nil then
		return
	end
	if gdef.harvest_name == nil then
		return
	end
	
	minetest.register_craft({
	type = "shapeless",
	output = gdef.seed_name.." 1",
	recipe = {
		farming.modname..":trellis",gdef.harvest_name
	},
  })
end

--	local starttime=os.clock()
--	print("time define infect "..1000*(os.clock()-starttime))

