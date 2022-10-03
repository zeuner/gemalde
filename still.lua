local storage = gemalde.storage

local S = gemalde.S

local supported_scales = {
	1.0,
	2.0,
	3.0,
}

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

local known_scales = {}

known_scales[#known_scales + 1] = 3.0

local known_scales_stored = storage:get(
	"still_known_scales"
)

if known_scales_stored then
	known_scales = minetest.deserialize(
		known_scales_stored
	)
end

local scale_suffix = {}

scale_suffix[3.0] = ""

local scale_suffix_stored = storage:get(
	"still_scale_suffix"
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

storage:set_string("still_known_scales", minetest.serialize(known_scales))

storage:set_string("still_scale_suffix", minetest.serialize(scale_suffix))

local still_path = minetest.get_modpath(
	minetest.get_current_modname()
) .. "/textures/still"

local gemalde_privilege = "teacher"

if not minetest.registered_privileges[gemalde_privilege] then
	gemalde_privilege = "server"
end

local i = 1

while true do
	local filename = "gemalde_" .. i .. ".png"
	local filepath = still_path .. "/" .. filename
	local file = io.open(filepath, "r")
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
	i = i + 1
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

local node_config = {}

local configured_node

local configured_pos

-- register for each picture
for n=1, N do

for o=1, #supported_scales do

local groups = {choppy=2, dig_immediate=3, picture=1, not_in_creative_inventory=1}
if n == 1 and o == 1 then
	groups = {choppy=2, dig_immediate=3, picture=1}
end

-- node
basename = string.sub(
	still_pictures[n],
	1,
	string.find(still_pictures[n], "%.") - 1
)

node_config["gemalde:node_"..n..scale_suffix[supported_scales[o]]] = {
	face = n,
	scale = o,
}

minetest.register_node("gemalde:node_"..n..scale_suffix[supported_scales[o]], {
	description = S("Picture @1", basename),
	drawtype = "signlike",
	tiles = {still_pictures[n]},
	visual_scale = supported_scales[o],
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
		for m = 1, #still_pictures do
			local escaped = minetest.formspec_escape(
				still_pictures[m]
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
		minetest.show_formspec(name, "gemalde:choose", formspec)
	
		--local length = string.len (node.name)
		--local number = string.sub (node.name, 14, length)
		
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

--	TODO.
--	on_place = minetest.rotate_node
})

-- crafts
if n < N and o == 1 then
minetest.register_craft({
	output = 'gemalde:node_'..n..'',
	recipe = {
		{'gemalde:node_'..(n+1)..''},
	}
})
end
end

n = n + 1

end

local on_player_receive_fields = function(player, formname, fields)
	if "gemalde:choose" ~= formname then
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
	local number = still_pictures_reverse[fields.new_face]
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
	configured_node.name = "gemalde:node_"..number..scale_suffix[scale]
	minetest.env:set_node(configured_pos, configured_node)
end

minetest.register_on_player_receive_fields(on_player_receive_fields)

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
