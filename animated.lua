-- Settings
local default_speed	= 2.0

-- Extra
--	x is the paintings number. s is the animation speed.
local frames = {
--	{x, s},
--	{2, 1.0}, -- Example. Speed of 1.0 for the second animated painting.
}

local storage = minetest.get_mod_storage()

local animated_pictures = {}

local animated_pictures_stored = storage:get(
	"animated_pictures"
)

if animated_pictures_stored then
	animated_pictures = minetest.deserialize(animated_pictures_stored)
end

local animated_pictures_reverse = {}

local animated_pictures_reverse_stored = storage:get(
	"animated_pictures_reverse"
)

if animated_pictures_reverse_stored then
	animated_pictures_reverse = minetest.deserialize(
		animated_pictures_reverse_stored
	)
end

local animated_path = minetest.get_modpath(
	minetest.get_current_modname()
) .. "/textures/animated"

local i = 1

while true do
	local filename = animated_path .. "/gemalde_animated_" .. i .. ".png"
	local file = io.open(filename, "r")
	if file then
		io.close(file)
		if not animated_pictures_reverse[filename] then
			local new_index = #animated_pictures + 1
			animated_pictures[new_index] = filename
			animated_pictures_reverse[filename] = new_index
		end
	else
		break
	end
	i = i + 1
end

local found = minetest.get_dir_list(animated_path)

for i = 1, #found do
	if not animated_pictures_reverse[found[i]] then
		local new_index = #animated_pictures + 1
		animated_pictures[new_index] = found[i]
		animated_pictures_reverse[found[i]] = new_index
	end
end

storage:set_string("animated_pictures", minetest.serialize(animated_pictures))

storage:set_string(
	"animated_pictures_reverse",
	minetest.serialize(animated_pictures_reverse)
)

N = #animated_pictures

-- register for each picture
for n=1, N do

local groups = {choppy=2, dig_immediate=3, animated_picture=1, not_in_creative_inventory=1}
if n == 1 then
	groups = {choppy=2, dig_immediate=3, animated_picture=1}
end

-- Look in the frames table for settings.
local frames_speed = default_speed
for _,frames in ipairs(frames) do
	if frames[1] == n then
		frames_speed = frames[2]
	end
end

-- node
basename = string.sub(
	animated_pictures[n],
	1,
	string.find(animated_pictures[n], "%.") - 1
)

minetest.register_node("gemalde:node_animated_"..n.."", {
	description = "Animation " .. basename,
	drawtype = "signlike",
	tiles = {
		{
			image = animated_pictures[n],
			animation ={
				type="vertical_frames",
				length=frames_speed
			}
		},
	},
	visual_scale = 3.0,
	inventory_image = "gemalde_animated_node.png",
	wield_image = "gemalde_animated_node.png",
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
		local number = string.sub (node.name, 23, length)
		
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

--		print("[gemalde] number is "..number.."")
		node.name = "gemalde:node_animated_"..number..""
		minetest.env:set_node(pos, node)
	end,
	
--	TODO.
--	on_place = minetest.rotate_node
})

-- crafts
if n < N then
minetest.register_craft({
	output = 'gemalde:node_animated_'..n..'',
	recipe = {
		{'gemalde:node_animated_'..(n+1)..''},
	}
})
end

n = n + 1

end

-- close the craft loop
minetest.register_craft({
	output = 'gemalde:node_animated_'..N..'',
	recipe = {
		{'gemalde:node_animated_1'},
	}
})

-- initial craft
minetest.register_craft({
	output = 'gemalde:node_animated_1',
	recipe = {
		{'default:book', 'default:book'},
		{'default:book', 'default:book'},
		{'default:book', 'default:book'},
	}
})

-- reset several pictures to #1
minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_animated_1 2',
	recipe = {'group:animated_picture', 'group:animated_picture'},
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_animated_1 3',
	recipe = {'group:animated_picture', 'group:animated_picture', 'group:animated_picture'},
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_animated_1 4',
	recipe = {
		'group:animated_picture', 'group:animated_picture', 'group:animated_picture', 
		'group:animated_picture'
	}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_animated_1 5',
	recipe = {
		'group:animated_picture', 'group:animated_picture', 'group:animated_picture', 
		'group:animated_picture', 'group:animated_picture'
	}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_animated_1 6',
	recipe = {
		'group:animated_picture', 'group:animated_picture', 'group:animated_picture', 
		'group:animated_picture', 'group:animated_picture', 'group:animated_picture'
	}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_animated_1 7',
	recipe = {
		'group:animated_picture', 'group:animated_picture', 'group:animated_picture', 
		'group:animated_picture', 'group:animated_picture', 'group:animated_picture', 
		'group:animated_picture'
	}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_animated_1 8',
	recipe = {
		'group:animated_picture', 'group:animated_picture', 'group:animated_picture', 
		'group:animated_picture', 'group:animated_picture', 'group:animated_picture', 
		'group:animated_picture', 'group:animated_picture'
	}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'gemalde:node_animated_1 9',
	recipe = {
			'group:animated_picture', 'group:animated_picture', 'group:animated_picture', 
			'group:animated_picture', 'group:animated_picture', 'group:animated_picture', 
			'group:animated_picture', 'group:animated_picture', 'group:animated_picture'
		}
})
