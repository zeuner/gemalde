gemalde = {
	storage = minetest.get_mod_storage(),
	S = minetest.get_translator("gemalde")
}

-- still pictures
dofile(minetest.get_modpath("gemalde").."/still.lua")

-- animated picures
dofile(minetest.get_modpath("gemalde").."/animated.lua")
