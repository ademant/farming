Minetest Game mod: farming
==========================
See license.txt for license information.

Mod for extending the farming capabilities of minetest. 
You have wild crops, which you can cultivate to get faster and more harvest.
The crops can be infected, where you get nothing. And the infection spreads to nearby crops.
A culture of crops can be destroyed by the infection, where the cultured variant of crops 
are easier infected than the wild form.
With special plants (right now nettles) you can make a curing mixture. And other plants can protect the culture.
You should use special devices to get more fruits:
- With a scythe you dig the node and by change get one more harvest. The change is better for a steel scythe than for stone or wood
- With a billhook you punch for example berries to get by change one berry more.
Booth are weared out by each harvest.

For each crop you can define the count of step. In the last step the crop is full-grown, where the crops can be punchable. 
The defined grow time is modified by the amount of light the crop would see and the place: The less light at 
the position will be (under a tree for example), the longer the crop needs to reach the next step.

The code is written to enable extension by other mods.
You have only one txt file to configure the crops. It's read in a table. Not defined fields are filled,
if a default row is given. If no default is given, the field is not importet to the crop.
Based on the definition the behauvior is defined:
- Crops with harvest (Wheat, Barley, Spelt, Nettle, Hemp): The crop has to be digged and drops a harvest, which can not be seeded again.
	The seed has to be crafted out of the harvest. If the option "use_flail" is activated, a standard
	craft is used: With a flail you get one seed and one straw (default, can be changed by field "straw").
	The seed can be placed again to grow more.
	If a cultured variant is given (Wheat), by change you get cultured harvest, which grows faster, has more harvest,
	gets easier infected or what ever is defined for the cultured crop.
	Most kind of wheat, barley and so on are defined this way.
- Crops with seed: The crop drops directly seed. The amount is given in the configuration by "max_harvest".
	Crops like potato or corn are defined in this way.
- Punchable fruits (Berries, Tea, Tobaco, Coffee): Full-grown fruits can be punched to give one fruit and back one step. After the growing
	time the fruits are available again. The full-grown can't be digged. It will be punched, directly afterwards
	the second last step will be digged, giving one fruit.
- Crops with trellis (Tomatoes, Hop, Grapes): For creating seedable items you have to craft out of the harvest the seed with a trellis.
	Digging any step will release the trellis for further usage. By using the option "use_trellis" the craft 
	is direct registered.
- crops with extractable seed (Tea, Tobaco): The normal harvest are the leaves of the plant, which you can punch out of the box.
	To get a seed of the fruit, you have to use a seed picker. The plant goes back one step and need to regrow booth
	leaves and seed.

Authors of source code
----------------------
Originally by PilzAdam (MIT)
webdesigner97 (MIT)
TenPlus1 (MIT)
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
  farming_strawberry
  
Created by ademant (CC BY 3.0):
  farming_tool_flail.png
  farming_tool_coffee_grinder.png (based on art by cactus_cowboy on openclipart.org)
  farming_tool_scythe (based on svg by Rinaldum on wikimedia)
  farming_tool_billhook (based on svg by Henrysalome on wikimedia)
  farming_sugerbeet (based on farming_beetroot)
  farming_blackberry (based on farming_blueberry)
  farming_blackberry_seed (based on jpg from AlbertCahalan on wikimedia)
  farming_blueberry_seed (based on jpg from Bateau ivre on wikimedia)
  farming_strawberry_seed (based on gif from Nicke L on wikimedia)
  farming_raspberry_seed (based on jpg from AlbertCahalan on wikimedia)
  farming_mustard
  farming_spelt (based on farming_barley)
  farming_hop
  farming_tobaco (based on pictures of wikimedia)
  farming_tool_spinningwheal (based on drawing by firkin on opencliparts)
  farming_yarn (based on picture from ikiwana on wikimedia)
