Minetest Game mod: farming
==========================
See license.txt for license information.

Mod for extending the farming capabilities of minetest. 
You have wild crops, which you can cultivate to get faster and more harvest.
(TODO) The crops can be infected, where you get nothing. And the infection spreads to nearby crops.
(TODO) A culture of crops can be destroyed by the infection, where the cultured variant of crops 
are easier infected than the wild form.
With special plants you can make a curing mixture. And other plants can protect the culture.

The code is written to enable extension by other mods.
You have only one txt file to configure the crops. It's read in a table. Not defined fields are filled,
if a default row is given. If no default is given, the field is not importet to the crop.
Based on the definition the behauvior is defined:
- Crops with harvest: The crop has to be digged and drops a harvest, which can not be seeded again.
	The seed has to be crafted out of the harvest. If the option "use_flail" is activated, a standard
	craft is used: With a flail you get one seed and one straw (default, can be changed by field "straw").
	The seed can be placed again to grow more.
	If a cultured variant is given, by change you get cultured harvest, which grows faster, has more harvest,
	gets easier infected or what ever is defined for the cultured crop.
	Most kind of wheat, barley and so on are defined this way.
- Crops with seed: The crop drops directly seed. The amount is given in the configuration by "max_harvest".
	Crops like potato or corn are defined in this way.
- Punchable fruits: Full-grown fruits can be punched to give one fruit and back one step. After the growing
	time the fruits are available again. The full-grown can't be digged. It will be punched, directly afterwards
	the second last step will be digged, giving one fruit.
- Crops with trellis: For creating seedable items you have to craft out of the harvest the seed with a trellis.
	Diggin any step will release the trellis for further usage. By using the option "use_trellis" the craft 
	is direct registered.

Authors of source code
----------------------
Originally by PilzAdam (MIT)
webdesigner97 (MIT)
ademant (MIT)
Various Minetest developers and contributors (MIT)

Authors of media (textures)
---------------------------
Created by PilzAdam (CC BY 3.0):
  farming_bread.png
  farming_soil.png
  farming_soil_wet.png
  farming_soil_wet_side.png
  farming_string.png

Created by BlockMen (CC BY 3.0):
  farming_tool_steelhoe.png
  farming_tool_stonehoe.png
  farming_tool_woodhoe.png

Created by MasterGollum (CC BY 3.0):
  farming_straw.png

Created by Gambit (CC BY 3.0):
  farming_wheat.png
  farming_wheat_*.png
  farming_cotton_*.png
  farming_flour.png
  farming_cotton_seed.png
  farming_wheat_seed.png

Created by Napiophelios (CC BY-SA 3.0):
  farming_cotton.png

Created by Ten1Plus (CC BY-SA 3.0):
  farming_hemp.png
  farming_beetroot

Created by ademant (CC BY 3.0):
  farming_tool_flail.png
  farming_tool_coffee_grinder.png (based on art by cactus_cowboy on openclipart.org)
  farming_tool_scythe (based on svg by Rinaldum on wikimedia)
  farming_tool_billhook (based on svg by Henrysalome on wikimedia)
  farming_sugerbeet (based on farming_beetroot)
  farming_blackberry (based on farming_blueberry)
  farming_strawberry (based on farming_raspberry)
  farming_strawberry_seed (based on gif from Nicke L on wikimedia)
  farming_raspberry_seed (based on jpg from AlbertCahalan on wikimedia)
  farming_mustard
  farming_spelt (based on farming_barley)
  farming_hop
  farming_tobaco (based on pictures of wikimedia)
