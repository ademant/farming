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
	material = "group:wood",
	groups = {flammable = 2},
})
farming.register_scythe(":farming:scythe_stone", {
	description = "Stone Scythe",
	inventory_image = "farming_tool_scythe_steel.png",
	max_uses = 60,
	material = "group:stone",
	groups = {flammable = 2},
})
farming.register_scythe(":farming:scythe_steel", {
	description = "Steel Scythe",
	inventory_image = "farming_tool_scythe_steel.png",
	max_uses = 500,
	material = "default:steel_ingot",
	groups = {flammable = 2},
})
