farming.register_hoe(":farming:hoe_wood", {
	description = "Wooden Hoe",
	inventory_image = "farming_tool_woodhoe.png",
	max_uses = 30,
	material = "group:wood",
	groups = {flammable = 2},
})

farming.register_hoe(":farming:hoe_stone", {
	description = "Stone Hoe",
	inventory_image = "farming_tool_stonehoe.png",
	max_uses = 90,
	material = "group:stone"
})

farming.register_hoe(":farming:hoe_steel", {
	description = "Steel Hoe",
	inventory_image = "farming_tool_steelhoe.png",
	max_uses = 500,
	material = "default:steel_ingot"
})

farming.register_scythe(":farming:scythe_wood", {
	description = "Wooden Scythe",
	inventory_image = "farming_tool_scythe_wood.png",
	max_uses = 30,
	farming_change = 10,
	material = "group:wood",
	groups = {flammable = 2},
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			snappy = {times={[1]=4.00, [2]=1.60, [3]=0.80}, uses=10, maxlevel=1},
		},
		damage_groups = {fleshy=4},
	},
})
farming.register_scythe(":farming:scythe_stone", {
	description = "Stone Scythe",
	inventory_image = "farming_tool_scythe_stone.png",
	max_uses = 60,
	farming_change = 5,
	material = "group:stone",
	groups = {flammable = 2},
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			snappy = {times={[1]=3.00, [2]=1.40, [3]=0.70}, uses=20, maxlevel=1},
		},
		damage_groups = {fleshy=4},
	},
})
farming.register_scythe(":farming:scythe_steel", {
	description = "Steel Scythe",
	inventory_image = "farming_tool_scythe_steel.png",
	max_uses = 500,
	farming_change = 3,
	material = "default:steel_ingot",
	groups = {flammable = 2},
})
farming.register_billhook(":farming:billhook_wood", {
	description = "Wooden Billhook",
	inventory_image = "farming_tool_billhook_wood.png",
	max_uses = 30,
	farming_change = 20,
	material = "group:wood",
	groups = {flammable = 2},
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			snappy = {times={[1]=5.00, [2]=2.00, [3]=1.40}, uses=10, maxlevel=1},
		},
		damage_groups = {fleshy=4},
	},
})
farming.register_billhook(":farming:billhook_stone", {
	description = "Stone Billhook",
	inventory_image = "farming_tool_billhook_stone.png",
	max_uses = 60,
	farming_change = 10,
	material = "group:stone",
	groups = {flammable = 2},
})
farming.register_billhook(":farming:billhook_steel", {
	description = "Steel Billhook",
	inventory_image = "farming_tool_billhook_steel.png",
	max_uses = 500,
	farming_change = 6,
	material = "default:steel_ingot",
	groups = {flammable = 2},
})
