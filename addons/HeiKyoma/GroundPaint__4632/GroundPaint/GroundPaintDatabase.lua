GroundPaint = GroundPaint or {}

GroundPaint.Database = {
    order = {
        "alkosh",
        "arcan_beam",
        "jabs",
        "bugs_W",
        "auf",
        "deatrowall_DD",
        "manabomb",
        "combat_prayer",
        "heal_orb",
        "deatrowall_Sup",
        "barrier",
        "horn",
        "undaunted",
    },

    zones = {
        arcan_beam = {
            displayName = "Arcanist beam",
            shape = "square",
            alignment = "forward",
            width = 3,
            length = 22,
            fillStep = 0.35,
            lineColor = { r = 0, g = 1, b = 0.4, a = 0.9 },
            fillColor = { r = 0, g = 1, b = 0.4, a = 0.15 },
        },

        alkosh = {
            displayName = "Alkosh",
            shape = "square",
            alignment = "forward",
            width = 10,
            length = 15,
            fillStep = 0.35,
            lineColor = { r = 1, g = 0.7, b = 0, a = 0.9 },
            fillColor = { r = 1, g = 0.7, b = 0, a = 0.15 },
        },

        auf = {
            displayName = "Claw fury (WW)",
            shape = "cone2",
            alignment = "forward",
            width = 10,
            length = 7,
            fillStep = 0.35,
            lineColor = { r = 1, g = 0, b = 0, a = 0.9 },
            fillColor = { r = 1, g = 0, b = 0, a = 0.15 },
        },

        jabs = {
            displayName = "Jabs (templar)",
            shape = "square",
            alignment = "forward",
            width = 6,
            length = 8,
            fillStep = 0.35,
            lineColor = { r = 1.00, g = 0.92, b = 0.45, a = 0.9 },
            fillColor = { r = 1.00, g = 0.92, b = 0.45, a = 0.15 },
        },

        bugs_W = {
            displayName = "Scorch (Warden)",
            shape = "square",
            alignment = "forward",
            width = 7,
            length = 20,
            fillStep = 0.35,
            lineColor = { r = 0.25, g = 0.75, b = 1.00, a = 0.9 },
            fillColor = { r = 0.25, g = 0.75, b = 1.00, a = 0.15 },
        },

        manabomb = {
            displayName = "Magicka detonation",
            shape = "ellipse",
            alignment = "center",
            width = 8*2,
            length = 8*2,
            fillStep = 0.35,
            lineColor = { r = 0.72, g = 0.35, b = 1.00, a = 0.9 },
            fillColor = { r = 0.72, g = 0.35, b = 1.00, a = 0.15 },
        },

        combat_prayer = {
            displayName = "Combat Prayer",
            shape = "square",
            alignment = "forward",
            width = 8,
            length = 20,
            fillStep = 0.35,
            lineColor = { r = 0.5, g = 0.8, b = 1.0, a = 0.9 },
            fillColor = { r = 0.5, g = 0.8, b = 1.0, a = 0.15 },
        },

        heal_orb = {
            displayName = "Healing orb",
            shape = "square",
            alignment = "forward",
            width = 8,
            length = 16,
            fillStep = 0.35,
            lineColor = { r = 0.5, g = 1, b = 0.7, a = 0.9 },
            fillColor = { r = 0.5, g = 1, b = 0.7, a = 0.15 },
        },

        deatrowall_DD = {
            displayName = "Unstable wall (destro)",
            shape = "square",
            alignment = "forward",
            width = 8,
            length = 18,
            fillStep = 0.35,
            lineColor = { r = 0.7, g = 0.3, b = 1, a = 0.9 },
            fillColor = { r = 0.7, g = 0.3, b = 1, a = 0.15 },
        },

        deatrowall_Sup = {
            displayName = "Elemental Blockade (destro)",
            shape = "square",
            alignment = "forward",
            width = 12,
            length = 18,
            fillStep = 0.35,
            lineColor = { r = 0.7, g = 0.3, b = 1, a = 0.9 },
            fillColor = { r = 0.7, g = 0.3, b = 1, a = 0.15 },
        },

        undaunted = {
            displayName = "28m: Altar, agro etc",
            shape = "ellipse",
            alignment = "center",
            width = 28*2,
            length = 28*2,
            fillStep = 0.35,
            lineColor = { r = 0.7, g = 0, b = 0, a = 0.9 },
            fillColor = { r = 0.7, g = 0, b = 0, a = 0 },
        },

        barrier = {
            displayName = "Barrier",
            shape = "ellipse",
            alignment = "center",
            width = 12*2,
            length = 12*2,
            fillStep = 0.35,
            lineColor = { r = 1.0, g = 0.92, b = 0.55, a = 0.9 },
            fillColor = { r = 1.0, g = 0.92, b = 0.55, a = 0.15 },
        },

        horn = {
            displayName = "Horn",
            shape = "ellipse",
            alignment = "center",
            width = 20*2,
            length = 20*2,
            fillStep = 0.35,
            lineColor = { r = 1.0, g = 0.72, b = 0.28, a = 0.9 },
            fillColor = { r = 1.0, g = 0.72, b = 0.28, a = 0.15 },
        },


    },
}
