local storage = minetest.get_mod_storage()

local still_pictures = {}

local still_pictures_stored = storage:get(
	"still_pictures"
)

if still_pictures_stored then
	still_pictures = minetest.deserialize(still_pictures_stored)
end

local still_pictures_reverse = {}

local still_pictures_reverse_stored = storage:get(
	"still_pictures_reverse"
)

if still_pictures_reverse_stored then
	still_pictures_reverse = minetest.deserialize(
		still_pictures_reverse_stored
	)
end

local still_path = minetest.get_modpath(
	minetest.get_current_modname()
) .. "/textures/still"

local i = 1

while true do
	local filename = still_path .. "/gemalde_" .. i .. ".png"
	local file = io.open(filename, "r")
	if file then
		io.close(file)
		if not still_pictures_reverse[filename] then
			local new_index = #still_pictures + 1
			still_pictures[new_index] = filename
			still_pictures_reverse[filename] = new_index
		end
	else
		break
	end
end

local found = minetest.get_dir_list(still_path)

for i = 1, #found do
	if not still_pictures_reverse[found[i]] then
		local new_index = #still_pictures + 1
		still_pictures[new_index] = found[i]
		still_pictures_reverse[found[i]] = new_index
	end
end

storage:set_string("still_pictures", minetest.serialize(still_pictures))

storage:set_string(
	"still_pictures_reverse",
	minetest.serialize(still_pictures_reverse)
)

N = #still_pictures

-- register for each picture
for n=1, N do

local groups = {choppy=2, dig_immediate=3, picture=1, not_in_creative_inventory=1}
if n == 1 then
	groups = {choppy=2, dig_immediate=3, picture=1}
end

-- node
basename = string.sub(
	still_pictures[n],
	1,
	string.find(still_pictures[n], "%.") - 1
)

minetest.register_node("gemalde:node_"..n.."", {
	description = "Picture " .. basename,
	drawtype = "signlike",
	tiles = {still_pictures[n]},
	visual_scale = 3.0,
	inventory_image = "gemalde_node.png",
	wield_image = "gemalde_node.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "wallmounted",
	},
	groups = groups,

	on_rightclick = function(pos, node, clicker)
	
		local length = string.len (node.name)
		local number = string.sub (node.name, 14, length)
		
		-- TODO. Reducing currently not working, because sneaking prevents right click.
		local keys=clicker:get_player_control()
		if keys["sneak"]==false then
			if number == tostring(N) then
				number = 1
			else
				number = number + 1
			end
		else
			if number == 1 then
				number = N - 1
			else
				number = number - 1
			end
		end

		print("[gemalde] number is "..number.."")
		node.name = "gemalde:node_"..number..""
		minetest.env:set_node(pos, node)
	end,

--	TODO.
--	on_place = minetest.rotate_node
})

-- crafts
if n < N then
minetest.register_craft({
	output = 'gemalde:node_'..n..'',
	recipe = {
		{'gemalde:node_'..(n+1)..''},
	}
})
end

n = n + 1

end

-- close the craft loop
minetest.register_craft({
	output = 'gemalde:node_'..N..'',
	recipe = {
		{'gemalde:node_1'},
	}
})

-- initial craft
minetest.register_craft({
	output = 'gemalde:node_1',
	recipe = {
		{'default:paper', 'default:paper'},
		{'default:paper', 'default:paper'},
		{'default:paper', 'default:paper'},
	}
})

-- reset several pictures to #1
minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_1 2',
	recipe = {'group:picture', 'group:picture'},
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_1 3',
	recipe = {'group:picture', 'group:picture', 'group:picture'},
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_1 4',
	recipe = {
		'group:picture', 'group:picture', 'group:picture', 
		'group:picture'
	}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_1 5',
	recipe = {
		'group:picture', 'group:picture', 'group:picture', 
		'group:picture', 'group:picture'
	}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_1 6',
	recipe = {
		'group:picture', 'group:picture', 'group:picture', 
		'group:picture', 'group:picture', 'group:picture'
	}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_1 7',
	recipe = {
		'group:picture', 'group:picture', 'group:picture', 
		'group:picture', 'group:picture', 'group:picture', 
		'group:picture'
	}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_1 8',
	recipe = {
		'group:picture', 'group:picture', 'group:picture', 
		'group:picture', 'group:picture', 'group:picture', 
		'group:picture', 'group:picture'
	}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_1 9',
	recipe = {
			'group:picture', 'group:picture', 'group:picture', 
			'group:picture', 'group:picture', 'group:picture', 
			'group:picture', 'group:picture', 'group:picture'
		}
})
