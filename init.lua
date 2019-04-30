local function get_rotate_rules(orules)
	return function(node)
		local rules = table.copy(orules)
		for i = 1, node.param2 do
			rules = mesecon.rotate_rules_left(rules)
		end
		return rules
	end
end

local function def_on_construct(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("name", "")
	meta:set_string("formspec", "field[name;Name;${name}]")
end

local function def_on_receive_fields(pos, formname, fields, sender)
	if not fields.name then
		return
	end
	local meta = minetest.get_meta(pos)
	meta:set_string("name", fields.name)
end

local digiline_def_receiver_off = {
	receptor = {
		rules = get_rotate_rules({{x = -1, y = 0, z = 0}}),
	},
	effector = {
		rules = get_rotate_rules({{x = -1, y = 0, z = 0}}),
		action = function(pos, node, channel, msg)
			if channel ~= "multimesecons_on" then
				return
			end
			if msg ~= minetest.get_meta(pos):get_string("name") then
				return
			end
			node.name = "multimesecons:receiver_on"
			minetest.swap_node(pos, node)
			mesecon.receptor_on(pos, get_rotate_rules({{x = 1, y = 0, z = 0}})(node))
		end,
	},
}

local digiline_def_receiver_on = {
	receptor = {
		rules = get_rotate_rules({{x = -1, y = 0, z = 0}}),
	},
	effector = {
		rules = get_rotate_rules({{x = -1, y = 0, z = 0}}),
		action = function(pos, node, channel, msg)
			if channel ~= "multimesecons_off" then
				return
			end
			if msg ~= minetest.get_meta(pos):get_string("name") then
				return
			end
			node.name = "multimesecons:receiver_off"
			minetest.swap_node(pos, node)
			mesecon.receptor_off(pos, get_rotate_rules({{x = 1, y = 0, z = 0}})(node))
		end,
	},
}

local digiline_def_emitter_off = {
	receptor = {
		rules = get_rotate_rules({{x = 1, y = 0, z = 0}}),
	},
	effector = {
		rules = get_rotate_rules({{x = 1, y = 0, z = 0}}),
		action = function(pos, node, channel, msg)
			if channel ~= "multimesecons_q" then
				return
			end
			if msg ~= minetest.get_meta(pos):get_string("name") then
				return
			end
			digilines.receptor_send(pos, get_rotate_rules({{x = 1, y = 0, z = 0}})(node), "multimesecons_off", msg)
		end,
	},
}

local digiline_def_emitter_on = {
	receptor = {
		rules = get_rotate_rules({{x = 1, y = 0, z = 0}}),
	},
	effector = {
		rules = get_rotate_rules({{x = 1, y = 0, z = 0}}),
		action = function(pos, node, channel, msg)
			if channel ~= "multimesecons_q" then
				return
			end
			if msg ~= minetest.get_meta(pos):get_string("name") then
				return
			end
			digilines.receptor_send(pos, get_rotate_rules({{x = 1, y = 0, z = 0}})(node), "multimesecons_on", msg)
		end,
	},
}


mesecon.register_node("multimesecons:receiver", {
	description = "Multimesecons Receiver",
	drawtype = "nodebox",
	drop = "multimesecons:receiver_off",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -1/16, 0.5, -7/16, 1/16},
			{-3/8, -0.5, -5/16, 0, -5/16, 5/16},
			{-1/8, -0.5, -3/16, 3/8, -3/8, 3/16}
		}
	},
	sounds = default.node_sound_stone_defaults(),
	onstate = "multimesecons:receiver_on",
	offstate = "multimesecons:receiver_off",
	after_dig_node = mesecon.do_cooldown,
	on_construct = def_on_construct,
	on_receive_fields = def_on_receive_fields,
}, {
	tiles = {"multimesecons_receiver_top_off.png", "multimesecons_receiver_bottom_off.png",
			"multimesecons_receiver_front_off.png", "multimesecons_receiver_back_off.png",
			"multimesecons_receiver_side_off.png^[transformFX", "multimesecons_receiver_side_off.png"},
	groups = {dig_immediate = 2, overheat = 1},
	mesecons = {receptor = {
		state = mesecon.state.off,
		rules = get_rotate_rules({{x = 1, y = 0, z = 0}}),
	}},
	digilines = digiline_def_receiver_off,
	digiline = digiline_def_receiver_off,
}, {
	tiles = {"multimesecons_receiver_top_on.png", "multimesecons_receiver_bottom_on.png",
			"multimesecons_receiver_front_on.png", "multimesecons_receiver_back_on.png",
			"multimesecons_receiver_side_on.png^[transformFX", "multimesecons_receiver_side_on.png"},
	groups = {dig_immediate = 2, not_in_creative_inventory = 1, overheat = 1},
	mesecons = {receptor = {
		state = mesecon.state.on,
		rules = get_rotate_rules({{x = 1, y = 0, z = 0}}),
	}},
	digilines = digiline_def_receiver_on,
	digiline = digiline_def_receiver_on,
})

mesecon.register_node("multimesecons:emitter", {
	description = "Multimesecons Emitter",
	drawtype = "nodebox",
	drop = "multimesecons:emitter_off",
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -1/16, 0.5, -7/16, 1/16},
			{-3/8, -0.5, -5/16, 0, -3/8, 5/16},
			{-1/8, -0.5, -3/16, 3/8, -5/16, 3/16}
		}
	},
	sounds = default.node_sound_stone_defaults(),
	onstate = "multimesecons:emitter_on",
	offstate = "multimesecons:emitter_off",
	after_dig_node = mesecon.do_cooldown,
	on_construct = def_on_construct,
	on_receive_fields = def_on_receive_fields,
}, {
	tiles = {"multimesecons_emitter_top_off.png", "multimesecons_emitter_bottom_off.png",
			"multimesecons_emitter_front_off.png", "multimesecons_emitter_back_off.png",
			"multimesecons_emitter_side_off.png^[transformFX", "multimesecons_emitter_side_off.png"},
	groups = {dig_immediate = 2, overheat = 1},
	mesecons = {effector = {
		rules = get_rotate_rules({{x = -1, y = 0, z = 0}}),
		action_on = function(pos, node)
			node.name = "multimesecons:emitter_on"
			minetest.swap_node(pos, node)
			digilines.receptor_send(pos, get_rotate_rules({{x = 1, y = 0, z = 0}})(node),
					"multimesecons_on", minetest.get_meta(pos):get_string("name"))
		end,
	}},
	digilines = digiline_def_emitter_off,
	digiline = digiline_def_emitter_off,
}, {
	tiles = {"multimesecons_emitter_top_on.png", "multimesecons_emitter_bottom_on.png",
			"multimesecons_emitter_front_on.png", "multimesecons_emitter_back_on.png",
			"multimesecons_emitter_side_on.png^[transformFX", "multimesecons_emitter_side_on.png"},
	groups = {dig_immediate = 2, not_in_creative_inventory = 1, overheat = 1},
	mesecons = {effector = {
		rules = get_rotate_rules({{x = -1, y = 0, z = 0}}),
		action_off = function(pos, node)
			node.name = "multimesecons:emitter_off"
			minetest.swap_node(pos, node)
			digilines.receptor_send(pos, get_rotate_rules({{x = 1, y = 0, z = 0}})(node),
					"multimesecons_off", minetest.get_meta(pos):get_string("name"))
		end,
	}},
	digilines = digiline_def_emitter_on,
	digiline = digiline_def_emitter_on,
})



--~ minetest.register_node("multimesecons:many_ports", {
--~ })
