OpulentOrdealNavigator = OpulentOrdealNavigator or {}

local OON = OpulentOrdealNavigator

OON.COLORS = {
    RED = "red",
    ORANGE = "orange",
    PURPLE = "purple",
}

OON.ROOMS = {
    red = {
        name = "Cobwebs",
        label = "Red",
        color = { 0.95, 0.12, 0.08 },
        pickups = { "red_pickup_west", "red_pickup_east" },
        join = "red_join",
        drops = { "red_drop_north", "red_drop_south" },
        final = "red_final",
    },
    orange = {
        name = "Drylands",
        label = "Orange",
        color = { 1, 0.48, 0.08 },
        pickups = { "orange_pickup" },
        join = "orange_join",
        drops = { "orange_drop_north", "orange_drop_south" },
        final = "orange_final",
    },
    purple = {
        name = "Eclipse",
        label = "Purple",
        color = { 0.65, 0.25, 1 },
        pickups = { "purple_pickup" },
        join = "purple_join",
        drops = { "purple_drop_north", "purple_drop_south" },
        final = "purple_final",
    },
}

-- Orb routing is always the long way around. Key format is orbColor:spawnRoom.
OON.ORB_ROUTES = {
    ["purple:red"] = { "red", "orange", "purple" },
    ["purple:orange"] = { "orange", "red", "purple" },
    ["orange:red"] = { "red", "purple", "orange" },
    ["orange:purple"] = { "purple", "red", "orange" },
    ["red:orange"] = { "orange", "purple", "red" },
    ["red:purple"] = { "purple", "orange", "red" },
}

-- Named marker anchors. Coordinates are normalized placeholders until captured in-game.
-- x/y are intentionally optional; labels still let the routing engine tell players what to do.
OON.MARKERS = {
    center_middle = { room = "center", kind = "middle", label = "Middle" },

    red_pickup_west = { room = "red", kind = "pickup", label = "Red pickup west" },
    red_pickup_east = { room = "red", kind = "pickup", label = "Red pickup east" },
    red_west_grapple_start = { room = "red", kind = "grapple_start", label = "Red west grapple start" },
    red_west_grapple_target = { room = "red", kind = "grapple_target", label = "Red west grapple target" },
    red_east_grapple_start = { room = "red", kind = "grapple_start", label = "Red east grapple start" },
    red_east_grapple_target = { room = "red", kind = "grapple_target", label = "Red east grapple target" },
    red_to_orange_grapple_start = { room = "red", kind = "grapple_start", label = "Red to Orange grapple start" },
    red_to_orange_grapple_target = { room = "red", kind = "grapple_target", label = "Red to Orange grapple target" },
    red_to_purple_grapple_start = { room = "red", kind = "grapple_start", label = "Red to Purple grapple start" },
    red_to_purple_grapple_target = { room = "red", kind = "grapple_target", label = "Red to Purple grapple target" },
    red_return_grapple_start = { room = "red", kind = "grapple_start", label = "Red return grapple start" },
    red_return_grapple_target = { room = "red", kind = "grapple_target", label = "Red return grapple target" },
    red_join = { room = "red", kind = "join", label = "Red joined area" },
    red_drop_north = { room = "red", kind = "drop", label = "Red drop north" },
    red_drop_south = { room = "red", kind = "drop", label = "Red drop south" },
    red_dual_soak_left = { room = "red", kind = "soak", label = "Red dual soak left", renderLabel = "Red\nLeft soak" },
    red_dual_soak_right = { room = "red", kind = "soak", label = "Red dual soak right", renderLabel = "Red\nRight soak" },
    red_final = { room = "red", kind = "final", label = "Red final holder" },
    red_phase2_tank = { room = "red", kind = "tank", label = "Red phase 2 tank", renderLabel = "P2 Tank", x = 50067, y = 35053, z = 49271 },

    orange_pickup = { room = "orange", kind = "pickup", label = "Orange pickup" },
    orange_join = { room = "orange", kind = "join", label = "Orange joined area" },
    orange_drop_north = { room = "orange", kind = "drop", label = "Orange drop north" },
    orange_drop_south = { room = "orange", kind = "drop", label = "Orange drop south" },
    orange_dual_soak_left = { room = "orange", kind = "soak", label = "Orange dual soak left", renderLabel = "Orange\nLeft soak" },
    orange_dual_soak_right = { room = "orange", kind = "soak", label = "Orange dual soak right", renderLabel = "Orange\nRight soak" },
    orange_final = { room = "orange", kind = "final", label = "Orange final holder" },
    orange_phase2_tank = { room = "orange", kind = "tank", label = "Orange phase 2 tank", renderLabel = "P2 Tank", x = 49470, y = 35057, z = 50376 },

    purple_pickup = { room = "purple", kind = "pickup", label = "Purple pickup" },
    purple_join = { room = "purple", kind = "join", label = "Purple joined area" },
    purple_drop_north = { room = "purple", kind = "drop", label = "Purple drop north" },
    purple_drop_south = { room = "purple", kind = "drop", label = "Purple drop south" },
    purple_dual_soak_left = { room = "purple", kind = "soak", label = "Purple dual soak left", renderLabel = "Purple\nLeft soak" },
    purple_dual_soak_right = { room = "purple", kind = "soak", label = "Purple dual soak right", renderLabel = "Purple\nRight soak" },
    purple_final = { room = "purple", kind = "final", label = "Purple final holder" },
    purple_phase2_tank = { room = "purple", kind = "tank", label = "Purple phase 2 tank", renderLabel = "P2 Tank", x = 50492, y = 35057, z = 50372 },
}

OON.PERSISTENT_MARKER_GROUPS = OON.PERSISTENT_MARKER_GROUPS or {}
OON.PERSISTENT_MARKER_GROUPS.phase2_tanks = {
    "red_phase2_tank",
    "orange_phase2_tank",
    "purple_phase2_tank",
}

OON.SOAK_SIDES = {
    left = {
        label = "Left",
        suffix = "_drop_north",
    },
    right = {
        label = "Right",
        suffix = "_drop_south",
    },
}

OON.SOAK_MARKERS = {
    red = {
        single = "red_drop_north",
        left = "red_dual_soak_left",
        right = "red_dual_soak_right",
    },
    orange = {
        single = "orange_drop_north",
        left = "orange_dual_soak_left",
        right = "orange_dual_soak_right",
    },
    purple = {
        single = "purple_drop_north",
        left = "purple_dual_soak_left",
        right = "purple_dual_soak_right",
    },
}

OON.PATH_CHUNKS = {
    red_pickup_west_to_join = {
        owner = "red",
        from = "red_pickup_west",
        to = "red_join",
        purpose = "pickup_to_join",
        movement = "grapple",
        instruction = "Move to the grapple start, grapple across, then continue to the joined area.",
        markers = { "red_pickup_west", "red_west_grapple_start", "red_west_grapple_target", "red_join" },
    },
    red_pickup_east_to_join = {
        owner = "red",
        from = "red_pickup_east",
        to = "red_join",
        purpose = "pickup_to_join",
        movement = "grapple",
        instruction = "Move to the grapple start, grapple across, then continue to the joined area.",
        markers = { "red_pickup_east", "red_east_grapple_start", "red_east_grapple_target", "red_join" },
    },
    orange_pickup_to_join = {
        owner = "orange",
        from = "orange_pickup",
        to = "orange_join",
        purpose = "pickup_to_join",
        markers = { "orange_pickup", "orange_join" },
    },
    purple_pickup_to_join = {
        owner = "purple",
        from = "purple_pickup",
        to = "purple_join",
        purpose = "pickup_to_join",
        markers = { "purple_pickup", "purple_join" },
    },

    red_join_to_orange_join = {
        owner = "red",
        from = "red_join",
        to = "orange_join",
        purpose = "handoff",
        movement = "grapple",
        instruction = "Use the red grapple exit before crossing to Orange.",
        markers = { "red_join", "red_to_orange_grapple_start", "red_to_orange_grapple_target", "orange_join" },
    },
    red_join_to_purple_join = {
        owner = "red",
        from = "red_join",
        to = "purple_join",
        purpose = "handoff",
        movement = "grapple",
        instruction = "Use the red grapple exit before crossing to Purple.",
        markers = { "red_join", "red_to_purple_grapple_start", "red_to_purple_grapple_target", "purple_join" },
    },
    orange_join_to_red_join = {
        owner = "orange",
        from = "orange_join",
        to = "red_join",
        purpose = "handoff",
        movement = "grapple",
        instruction = "Cross toward Red, then use the grapple point into the joined area.",
        markers = { "orange_join", "red_return_grapple_start", "red_return_grapple_target", "red_join" },
    },
    orange_join_to_purple_join = {
        owner = "orange",
        from = "orange_join",
        to = "purple_join",
        purpose = "handoff",
        markers = { "orange_join", "purple_join" },
    },
    purple_join_to_red_join = {
        owner = "purple",
        from = "purple_join",
        to = "red_join",
        purpose = "handoff",
        movement = "grapple",
        instruction = "Cross toward Red, then use the grapple point into the joined area.",
        markers = { "purple_join", "red_return_grapple_start", "red_return_grapple_target", "red_join" },
    },
    purple_join_to_orange_join = {
        owner = "purple",
        from = "purple_join",
        to = "orange_join",
        purpose = "handoff",
        markers = { "purple_join", "orange_join" },
    },

    red_join_to_final = {
        owner = "red",
        from = "red_join",
        to = "red_final",
        purpose = "final_setup",
        markers = { "red_join", "red_drop_north", "red_final" },
    },
    orange_join_to_final = {
        owner = "orange",
        from = "orange_join",
        to = "orange_final",
        purpose = "final_setup",
        markers = { "orange_join", "orange_drop_north", "orange_final" },
    },
    purple_join_to_final = {
        owner = "purple",
        from = "purple_join",
        to = "purple_final",
        purpose = "final_setup",
        markers = { "purple_join", "purple_drop_north", "purple_final" },
    },

    red_join_to_middle = {
        owner = "red",
        from = "red_join",
        to = "center_middle",
        purpose = "return_middle",
        markers = { "red_join", "center_middle" },
    },
    orange_join_to_middle = {
        owner = "orange",
        from = "orange_join",
        to = "center_middle",
        purpose = "return_middle",
        markers = { "orange_join", "center_middle" },
    },
    purple_join_to_middle = {
        owner = "purple",
        from = "purple_join",
        to = "center_middle",
        purpose = "return_middle",
        markers = { "purple_join", "center_middle" },
    },
    red_final_to_middle = {
        owner = "red",
        from = "red_final",
        to = "center_middle",
        purpose = "return_middle",
        markers = { "red_final", "center_middle" },
    },
    orange_final_to_middle = {
        owner = "orange",
        from = "orange_final",
        to = "center_middle",
        purpose = "return_middle",
        markers = { "orange_final", "center_middle" },
    },
    purple_final_to_middle = {
        owner = "purple",
        from = "purple_final",
        to = "center_middle",
        purpose = "return_middle",
        markers = { "purple_final", "center_middle" },
    },
}

OON.TEAM_ROUTE_CHUNKS = {
    ["red>orange"] = { "red_pickup_west_to_join", "red_join_to_orange_join" },
    ["red>purple"] = { "red_pickup_east_to_join", "red_join_to_purple_join" },
    ["orange>red"] = { "orange_pickup_to_join", "orange_join_to_red_join" },
    ["orange>purple"] = { "orange_pickup_to_join", "orange_join_to_purple_join" },
    ["purple>red"] = { "purple_pickup_to_join", "purple_join_to_red_join" },
    ["purple>orange"] = { "purple_pickup_to_join", "purple_join_to_orange_join" },
}

OON.FINAL_SETUP_CHUNKS = {
    red = { "red_join_to_final" },
    orange = { "orange_join_to_final" },
    purple = { "purple_join_to_final" },
}

OON.RETURN_CHUNKS = {
    red = {
        join = { "red_join_to_middle" },
        final = { "red_final_to_middle" },
    },
    orange = {
        join = { "orange_join_to_middle" },
        final = { "orange_final_to_middle" },
    },
    purple = {
        join = { "purple_join_to_middle" },
        final = { "purple_final_to_middle" },
    },
}

OON.ROLE_PRIORITY = {
    [LFG_ROLE_DPS] = 1,
    [LFG_ROLE_HEAL] = 2,
    [LFG_ROLE_TANK] = 3,
    [LFG_ROLE_INVALID] = 4,
}
