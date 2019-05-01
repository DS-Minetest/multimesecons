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
	meta:set_string("channel", "")
	meta:set_string("formspec", "field[channel;Channel;${channel}]")
end

local function def_on_receive_fields_receiver_off(pos, formname, fields, sender)
	if not fields.channel then
		return
	end
	local meta = minetest.get_meta(pos)
	meta:set_string("channel", fields.channel)
	digilines.receptor_send(pos, get_rotate_rules({{x = -1, y = 0, z = 0}})(minetest.get_node(pos)),
			fields.channel , "multimesecons_q")
end

local function def_after_dig_node_receiver_on(pos, oldnode)
	mesecon.receptor_off(pos, get_rotate_rules({{x = 1, y = 0, z = 0}})(oldnode))
	mesecon.do_cooldown(pos)
end

local function def_after_dig_node_emitter_on(pos, oldnode, oldmetadata)
	--~ digilines.receptor_send(pos, get_rotate_rules({{x = 1, y = 0, z = 0}})(oldnode),
			--~ oldmetadata.fields.channel, "multimesecons_off")
	mesecon.do_cooldown(pos)
end

local function def_on_receive_fields_receiver_on(pos, formname, fields, sender)
	if not fields.channel then
		return
	end
	local meta = minetest.get_meta(pos)
	meta:set_string("channel", fields.channel)
	local node = minetest.get_node(pos)
	node.name = "multimesecons:receiver_off"
	minetest.swap_node(pos, node)
	mesecon.receptor_off(pos, get_rotate_rules({{x = 1, y = 0, z = 0}})(node))
	digilines.receptor_send(pos, get_rotate_rules({{x = -1, y = 0, z = 0}})(node),
			fields.channel , "multimesecons_q")
end

local function def_on_receive_fields_emitter_off(pos, formname, fields, sender)
	if not fields.channel then
		return
	end
	local meta = minetest.get_meta(pos)
	meta:set_string("channel", fields.channel)
	digilines.receptor_send(pos, get_rotate_rules({{x = 1, y = 0, z = 0}})(minetest.get_node(pos)),
			fields.channel , "multimesecons_off")
end

local function def_on_receive_fields_emitter_on(pos, formname, fields, sender)
	if not fields.channel then
		return
	end
	local meta = minetest.get_meta(pos)
	local node = minetest.get_node(pos)
	digilines.receptor_send(pos, get_rotate_rules({{x = 1, y = 0, z = 0}})(node),
			meta:get_string("channel") , "multimesecons_off")
	meta:set_string("channel", fields.channel)
	digilines.receptor_send(pos, get_rotate_rules({{x = 1, y = 0, z = 0}})(node),
			fields.channel , "multimesecons_on")
end

local digiline_def_receiver_off = {
	receptor = {
		rules = get_rotate_rules({{x = -1, y = 0, z = 0}}),
	},
	effector = {
		rules = get_rotate_rules({{x = -1, y = 0, z = 0}}),
		action = function(pos, node, channel, msg)
			if msg ~= "multimesecons_on" then
				return
			end
			if channel ~= minetest.get_meta(pos):get_string("channel") then
				return
			end
			if mesecon.do_overheat(pos) then
				minetest.remove_node(pos)
				minetest.add_item(pos, "multimesecons:receiver_off")
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
			if msg ~= "multimesecons_off" then
				return
			end
			if channel ~= minetest.get_meta(pos):get_string("channel") then
				return
			end
			if mesecon.do_overheat(pos) then
				minetest.remove_node(pos)
				mesecon.receptor_off(pos, get_rotate_rules({{x = 1, y = 0, z = 0}})(node))
				minetest.add_item(pos, "multimesecons:receiver_off")
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
			if msg ~= "multimesecons_q" then
				return
			end
			if channel ~= minetest.get_meta(pos):get_string("channel") then
				return
			end
			if mesecon.do_overheat(pos) then
				--~ digilines.receptor_send(pos, get_rotate_rules({{x = 1, y = 0, z = 0}})(node),
						--~ channel, "multimesecons_off")
				minetest.remove_node(pos)
				minetest.add_item(pos, "multimesecons:emitter_off")
				return
			end
			digilines.receptor_send(pos, get_rotate_rules({{x = 1, y = 0, z = 0}})(node), channel, "multimesecons_off")
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
			if msg ~= "multimesecons_q" then
				return
			end
			if channel ~= minetest.get_meta(pos):get_string("channel") then
				return
			end
			if mesecon.do_overheat(pos) then
				minetest.remove_node(pos)
				digilines.receptor_send(pos, get_rotate_rules({{x = 1, y = 0, z = 0}})(node),
						channel, "multimesecons_off")
				minetest.add_item(pos, "multimesecons:emitter_off")
				return
			end
			digilines.receptor_send(pos, get_rotate_rules({{x = 1, y = 0, z = 0}})(node), channel, "multimesecons_on")
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
	on_construct = def_on_construct,
}, {
	tiles = {"multimesecons_receiver_top_off.png", "multimesecons_receiver_bottom_off.png",
			"multimesecons_receiver_front_off.png", "multimesecons_receiver_back_off.png",
			"multimesecons_receiver_side_off.png^[transformFX", "multimesecons_receiver_side_off.png"},
	groups = {dig_immediate = 2, overheat = 1},
	after_dig_node = mesecon.do_cooldown,
	on_receive_fields = def_on_receive_fields_receiver_off,
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
	after_dig_node = def_after_dig_node_receiver_on,
	on_receive_fields = def_on_receive_fields_receiver_on,
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
	on_construct = def_on_construct,
}, {
	tiles = {"multimesecons_emitter_top_off.png", "multimesecons_emitter_bottom_off.png",
			"multimesecons_emitter_front_off.png", "multimesecons_emitter_back_off.png",
			"multimesecons_emitter_side_off.png^[transformFX", "multimesecons_emitter_side_off.png"},
	groups = {dig_immediate = 2, overheat = 1},
	after_dig_node = mesecon.do_cooldown,
	on_receive_fields = def_on_receive_fields_emitter_off,
	mesecons = {effector = {
		rules = get_rotate_rules({{x = -1, y = 0, z = 0}}),
		action_on = function(pos, node)
			if mesecon.do_overheat(pos) then
				minetest.remove_node(pos)
				minetest.add_item(pos, "multimesecons:emitter_off")
				return
			end
			node.name = "multimesecons:emitter_on"
			minetest.swap_node(pos, node)
			digilines.receptor_send(pos, get_rotate_rules({{x = 1, y = 0, z = 0}})(node),
					minetest.get_meta(pos):get_string("channel"), "multimesecons_on")
		end,
	}},
	digilines = digiline_def_emitter_off,
	digiline = digiline_def_emitter_off,
}, {
	tiles = {"multimesecons_emitter_top_on.png", "multimesecons_emitter_bottom_on.png",
			"multimesecons_emitter_front_on.png", "multimesecons_emitter_back_on.png",
			"multimesecons_emitter_side_on.png^[transformFX", "multimesecons_emitter_side_on.png"},
	groups = {dig_immediate = 2, not_in_creative_inventory = 1, overheat = 1},
	after_dig_node = def_after_dig_node_emitter_on,
	on_receive_fields = def_on_receive_fields_emitter_on,
	mesecons = {effector = {
		rules = get_rotate_rules({{x = -1, y = 0, z = 0}}),
		action_off = function(pos, node)
			if mesecon.do_overheat(pos) then
				minetest.remove_node(pos)
				digilines.receptor_send(pos, get_rotate_rules({{x = 1, y = 0, z = 0}})(node),
						minetest.get_meta(pos):get_string("channel"), "multimesecons_off")
				minetest.add_item(pos, "multimesecons:emitter_off")
				return
			end
			node.name = "multimesecons:emitter_off"
			minetest.swap_node(pos, node)
			digilines.receptor_send(pos, get_rotate_rules({{x = 1, y = 0, z = 0}})(node),
					minetest.get_meta(pos):get_string("channel"), "multimesecons_off")
		end,
	}},
	digilines = digiline_def_emitter_on,
	digiline = digiline_def_emitter_on,
})



--~ minetest.register_node("multimesecons:many_ports", {
--~ })
