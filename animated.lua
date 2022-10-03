-- Settings
local default_speed	= 2.0

-- Extra
--	x is the paintings number. s is the animation speed.
local frames = {
--	{x, s},
--	{2, 1.0}, -- Example. Speed of 1.0 for the second animated painting.
}

local storage = gemalde.storage

local S = gemalde.S

local supported_scales = {
	1.0,
	2.0,
	3.0,
}

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

local known_scales = {}

known_scales[#known_scales + 1] = 3.0

local known_scales_stored = storage:get(
	"animated_known_scales"
)

if known_scales_stored then
	known_scales = minetest.deserialize(
		known_scales_stored
	)
end

local scale_suffix = {}

scale_suffix[3.0] = ""

local scale_suffix_stored = storage:get(
	"animated_scale_suffix"
)

if scale_suffix_stored then
	scale_suffix = minetest.deserialize(
		scale_suffix_stored
	)
end

for _, scale in pairs(supported_scales) do
	if not scale_suffix[scale] then
		local new_index = #known_scales + 1
		scale_suffix[scale] = "_" .. new_index
		known_scales[new_index] = scale
	end
end

storage:set_string("animated_known_scales", minetest.serialize(known_scales))

storage:set_string("animated_scale_suffix", minetest.serialize(scale_suffix))

local animated_path = minetest.get_modpath(
	minetest.get_current_modname()
) .. "/textures/animated"

local gemalde_privilege = "teacher"

if not minetest.registered_privileges[gemalde_privilege] then
	gemalde_privilege = "server"
end

local i = 1

while true do
	local filename = "gemalde_animated_" .. i .. ".png"
	local filepath = animated_path .. "/" .. filename
	local file = io.open(filepath, "r")
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

local node_config = {}

local configured_node

local configured_pos

-- register for each picture
for n=1, N do

for o=1, #supported_scales do

local groups = {choppy=2, dig_immediate=3, animated_picture=1, not_in_creative_inventory=1}
if n == 1 and o == 1 then
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

node_config["gemalde:node_animated_"..n..scale_suffix[supported_scales[o]]] = {
	face = n,
	scale = o,
}

minetest.register_node(
	"gemalde:node_animated_"..n..scale_suffix[supported_scales[o]], {
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
	visual_scale = supported_scales[o],
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
		local name = clicker:get_player_name()
		local privileges = minetest.get_player_privs(name)
		if not privileges[gemalde_privilege] then
			minetest.chat_send_player(
				name,
				S("missing privilege @1", gemalde_privilege)
			)
			return false
		end

		local formspec = "size[9.0,9.0;]"
		local label = minetest.formspec_escape(S("Picture"))
		formspec = formspec .. "label[1.0,1.0;" .. label .. "]"
		formspec = formspec .. "dropdown[1.0,2.0;7.0;new_face;"
		local delimiter = ""
		for m = 1, #animated_pictures do
			local escaped = minetest.formspec_escape(
				animated_pictures[m]
			)
			formspec = formspec .. delimiter .. escaped
			delimiter = ","
		end
		formspec = formspec .. ";" .. node_config[node.name].face .. ";]"
		label = minetest.formspec_escape(S("Scale"))
		formspec = formspec .. "label[1.0,3.0;" .. label .. "]"
		formspec = formspec .. "dropdown[1.0,4.0;7.0;new_scale;"
		local delimiter = ""
		for m = 1, #supported_scales do
			local escaped = minetest.formspec_escape(
				supported_scales[m]
			)
			formspec = formspec .. delimiter .. escaped
			delimiter = ","
		end
		formspec = formspec .. ";" .. node_config[node.name].scale .. ";]"
		formspec = formspec .. "button_exit[1.0,5.0;7.0,1.0;close;"
		label = minetest.formspec_escape(S("Close"))
		formspec = formspec .. label .. "]"
		configured_node = node
		configured_pos = pos
		minetest.show_formspec(
			name,
			"gemalde:choose_animated",
			formspec
		)

		--local length = string.len (node.name)
		--local number = string.sub (node.name, 23, length)

		---- TODO. Reducing currently not working, because sneaking prevents right click.
		--local keys=clicker:get_player_control()
		--if keys["sneak"]==false then
			--if number == tostring(N) then
				--number = 1
			--else
				--number = number + 1
			--end
		--else
			--if number == 1 then
				--number = N - 1
			--else
				--number = number - 1
			--end
		--end

		--print("[gemalde] number is "..number.."")
		--node.name = "gemalde:node_"..number..""
		--minetest.env:set_node(pos, node)
	end,

--      TODO.
--      on_place = minetest.rotate_node
})

-- crafts
if n < N and o == 1 then
minetest.register_craft({
	output = 'gemalde:node_animated_'..n..'',
	recipe = {
		{'gemalde:node_animated_'..(n+1)..''},
	}
})
end
end

n = n + 1

end

local on_player_receive_fields = function(player, formname, fields)
	if "gemalde:choose_animated" ~= formname then
		return false
	end
	local name = player:get_player_name()
	local privileges = minetest.get_player_privs(name)
	local current_node = minetest.env:get_node(configured_pos)
	local config = node_config[current_node.name]
	configured_face = config.face
	configured_scale = config.scale
	if not privileges[gemalde_privilege] then
		minetest.chat_send_player(
			name,
			S("missing privilege @1", gemalde_privilege)
		)
		return false
	end
	local number = animated_pictures_reverse[fields.new_face]
	if not number then
		number = configured_face
	end
	print("[gemalde] number is " .. number)
	local scale = fields.new_scale
	if scale then
		scale = tonumber(scale)
	else
		scale = supported_scales[configured_scale]
	end
	print("[gemalde] scale is " .. scale)
	local suffix = scale_suffix[scale]
	configured_node.name = "gemalde:node_animated_"..number..suffix
	minetest.env:set_node(configured_pos, configured_node)
end

minetest.register_on_player_receive_fields(on_player_receive_fields)


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
