NowhereVaultSecretSeeker = NowhereVaultSecretSeeker or {}
local NVC = NowhereVaultSecretSeeker

NVC.VAULT_ZONE_ID = 1533

-- Pin styles:
-- blue / blue1 / blue2 = navigation, route, possible spawn
-- green / green1 / green3 = important secret interaction / reward
NVC.rooms = {
    [2937] = {
        name = "Nowhere Vault Nexus",
        wing = "Hub",
        secret = "Main Hub",
        instructions = {
            "Choose a wing. Room order inside each wing is randomized.",
        },
        pins = {},
    },

    [2876] = {
        name = "Sage's Vault",
        wing = "Final Reward",
        secret = "Ancient Direnni Quasigriff",
        instructions = {
            "Place all 3 Wing Seals in visible slots.",
            "Barrier drops; interact with Quasigriff for mount.",
        },
        pins = {},
    },

    [2861] = {
        name = "Meditative Garden",
        wing = "Special Room",
        secret = "None",
        instructions = {
            "Resource room. Gather what you want and continue when ready.",
        },
        pins = {},
    },

    [2881] = {
        name = "Magicka Flow Junction",
        wing = "Stash Room",
        secret = "None",
        instructions = {
            "Loot chests. Beginner's Reward: 5 / 10 / 15.",
        },
        pins = {},
    },

    [2845] = {
        name = "Hunt of the Watchers",
        wing = "Arcanum Wing",
        secret = "Watcher Filtration Gills",
        instructions = {
            "GREEN: get Whistle + find Sigil.",
            "Lure Watcher with SAME symbol to Sigil.",
            "Activate/use Whistle; kill Watcher.",
            "BLUE dots = possible Seeker Glyph spots.",
        },
        pins = {
            {x=.357743, y=.445278, label="Shrill Whistle", style="green", note="Important secret pickup"},
            {x=.550989, y=.655898, label="Watcher Sigil", style="green", note="Match this symbol to the correct Watcher"},

            {x=.408087, y=.641140, label="Possible Seeker Glyph", style="blue", note="Possible / variable spawn"},
            {x=.278477, y=.473119, label="Possible Seeker Glyph", style="blue", note="Possible / variable spawn"},
            {x=.307609, y=.295503, label="Possible Seeker Glyph", style="blue", note="Possible / variable spawn"},
            {x=.443533, y=.074451, label="Possible Seeker Glyph", style="blue", note="Possible / variable spawn"},
            {x=.537208, y=.162544, label="Possible Seeker Glyph", style="blue", note="Possible / variable spawn"},
            {x=.453756, y=.263231, label="Possible Seeker Glyph", style="blue", note="Possible / variable spawn"},
            {x=.642431, y=.586854, label="Possible Seeker Glyph", style="blue", note="Possible / variable spawn"},
            {x=.758120, y=.526463, label="Possible Seeker Glyph", style="blue", note="Possible / variable spawn"},
            {x=.691379, y=.293968, label="Possible Seeker Glyph", style="blue", note="Possible / variable spawn"},
            {x=.590517, y=.465932, label="Possible Seeker Glyph", style="blue", note="Verified spawn"},
            {x=.536685, y=.307749, label="Possible Seeker Glyph", style="blue", note="Verified spawn"},
        },
    },

    [2846] = {
        name = "Murky Grotto",
        wing = "Arcanum Wing",
        secret = "Fungal Sight",
        prerequisite = "Watcher Filtration Gills",
        prerequisiteSource = "Hunt of the Watchers",
        instructions = {
            "Stay near the BLUE dot; no need to stand on it.",
            "DO NOT kill Toxic Plants.",
            "Wait for Toxic Matron; kill her.",
        },
        hint = "* HINT: Don't let combat pets kill the plants.",
        pins = {
            {x=.507002, y=.632830, label="Central Secret Area", style="blue", note="Wait here for the Toxic Matron mechanic"},
            {x=.586994, y=.150420, label="Skyshard", style="skyshard", note="Tucked away under a series of massive roots."},
        },
    },

    [2848] = {
        name = "Fungal Chasm",
        wing = "Arcanum Wing",
        secret = "Subjugating Mindspore",
        prerequisite = "Fungal Sight",
        prerequisiteSource = "Murky Grotto",
        instructions = {
            "Go to BLUE pin.",
            "Jump onto green mist bridge.",
            "Follow path to GREEN pin; interact with tree.",
        },
        pins = {
            {x=.324392, y=.451959, label="Secret Path / Long Jump Start", style="blue", note="Navigation point"},
            {x=.249816, y=.302701, label="Subjugating Mindspore Tree", style="green", note="Interact here"},
            {x=.580104, y=.289144, label="Skyshard", style="skyshard", note="Perched precariously above flowing fire."},
        },
    },

    [2840] = {
        name = "Custodian's Repository",
        wing = "Arcanum Wing",
        secret = "Arcanum Wing Seal",
        prerequisite = "Astralight Lumen",
        prerequisiteSource = "Eclipsed Hall",
        instructions = {
            "Go to GREEN Astral Tear.",
            "INTERACT. Confirm Wing Seal before leaving.",
        },
        pins = {
            {x=.647873, y=.419872, label="Astral Tear - Arcanum Wing Seal", style="green", note="Confirmed secret interaction"},
        },
    },

    [2854] = {
        name = "Moonlit Isles",
        wing = "Lunar Path Wing",
        secret = "Resonating Core",
        instructions = {
            "CHAINS - activate ALL 3 secret bridge sections.",
            "Take portal back to entrance.",
            "Run path again; at halfway point, use SECRET BRIDGE.",
            "Follow secret bridge; take Resonating Core.",
        },
        hint = "* EXTRA: Go to RED pin for shortcut.\nHold BLOCK and slowly walk off edge. Might live... might die.",
        pins = {
            {x=.468423, y=.498133, label="1 - Chains / Pillar Puzzle", style="blue1", note="Route step 1"},
            {x=.263346, y=.330419, label="2 - Secret Bridge Entrance", style="blue2", note="Secret bridge route"},
            {x=.571584, y=.220290, label="3 - Resonating Core", style="green3", note="Interact here"},
            {x=.370240, y=.505600, label="EXTRA - Shortcut", style="red", note="Hold BLOCK and slowly walk off edge. Might live... might die."},
            {x=.460304, y=.675896, label="Skyshard", style="skyshard", note="Stashed on a low cliff that only magic can reach."},
        },
    },

    [2872] = {
        name = "Twilight Maze",
        wing = "Lunar Path Wing",
        secret = "Cantor's Starsong",
        prerequisite = "Resonating Core",
        prerequisiteSource = "Moonlit Isles",
        instructions = {
            "Stay STEALTHED. Do not attack.",
            "BLUE: find Little Soft Boots; FOLLOW HIM.",
            "At rubble, enter Secret Room.",
            "Lost him? Leave room and re-enter.",
            "TIP: Light a brazier; its flame travels toward a singing add.",
        },
        pins = {
        },
    },

    [2856] = {
        name = "Twilight Maze",
        wing = "Lunar Path Wing",
        secret = "Cantor's Starsong",
        prerequisite = "Resonating Core",
        prerequisiteSource = "Moonlit Isles",
        instructions = {
            "Stay STEALTHED. Do not attack.",
            "BLUE: find Little Soft Boots; FOLLOW HIM.",
            "At rubble, enter Secret Room.",
            "Lost him? Leave room and re-enter.",
            "TIP: Light a brazier; its flame travels toward a singing add.",
        },
        pins = {
            {x=.300309, y=.648336, label="Little Soft Boots - Search Area", style="bluearea", note="Look for Little Soft Boots around this area. He moves - stay stealthed and follow him."},
        },
    },

    [2871] = {
        name = "Twilight Maze",
        wing = "Lunar Path Wing",
        secret = "Cantor's Starsong",
        prerequisite = "Resonating Core",
        prerequisiteSource = "Moonlit Isles",
        instructions = {
            "Upper ruins / Skyshard area.",
            "TIP: Light a brazier; its flame travels toward a singing add.",
        },
        pins = {
            {x=.142017, y=.550070, label="Skyshard", style="skyshard", note="Among the ruins above the darkened maze."},
        },
    },

    [2870] = {
        name = "Night Maze",
        wing = "Lunar Path Wing",
        secret = "Cantor's Starsong",
        prerequisite = "Resonating Core",
        prerequisiteSource = "Moonlit Isles",
        instructions = {
            "GREEN Lion: place Resonating Core.",
            "WAIT, then INTERACT AGAIN for Starsong.",
        },
        pins = {
            {x=.865954, y=.252186, label="Lion Statue", style="green", note="Place Core, wait, then interact AGAIN"},
        },
    },

    [2837] = {
        name = "Eclipsed Hall",
        wing = "Lunar Path Wing",
        secret = "Astralight Lumen",
        prerequisite = "Cantor's Starsong",
        prerequisiteSource = "Twilight Maze / Night Maze",
        instructions = {
            "GREEN: grab Mallet near portal.",
            "Ring main bell again.",
            "Ring every BLUE-GLOWING outer bell.",
            "Lumen awards automatically.",
        },
        pins = {
            {x=.121435, y=.507556, label="Mallet - Near Portal", style="green", note="Pick this up first"},
        },
    },

    [2838] = {
        name = "The Lakehouse",
        wing = "Lunar Path Wing",
        secret = "Lunar Path Wing Seal",
        prerequisite = "Connoisseur's Vision",
        prerequisiteSource = "Haunted Undercroft",
        instructions = {
            "GREEN: interact with Creative Transcendence on the wall for Wing Seal.",
        },
        pins = {
            {x=.476055, y=.457294, label="Creative Transcendence - Lunar Path Wing Seal", style="green", note="Interact here for the Wing Seal"},
        },
    },

    [2849] = {
        name = "Gallery of Curios",
        wing = "Cursed Castle Wing",
        secret = "Artist's Touch",
        instructions = {
            "1: Painting - grab Lens from rubble.",
            "2: Go to BLUE viewing spot.",
            "Face sword statue between columns; use Lens.",
            "Wrong objects spawn adds.",
        },
        hint = "* HINT: After enough kills, the Curios take mercy: a blue swirling aura appears on you when near a correct hidden Curio.",
        pins = {
            {x=.923220, y=.240152, label="1 - Destroyed Painting + Artist's Lens", style="green1", note="Lens is in the rubble beside the painting"},
            {x=.819593, y=.677064, label="2 - Correct Viewing Spot", style="blue2", note="Face the sword-bearing statue and use the Lens"},
            {x=.448870, y=.404500, label="Skyshard", style="skyshard", note="In an alcove overlooking a room with three curios on display."},
        },
    },

    [2851] = {
        name = "Sinking Courtyard",
        wing = "Cursed Castle Wing",
        secret = "Carafe of Salt Water",
        prerequisite = "Artist's Touch",
        prerequisiteSource = "Gallery of Curios",
        instructions = {
            "Activate 3 Rain Totems.",
            "BLUE = possible spots; more are intentionally unmapped.",
            "Then GREEN fountain for Salt Water.",
        },
        pins = {
            {x=.313287, y=.255236, label="Possible Rain Totem", style="blue", note="Possible / variable spawn"},
            {x=.407034, y=.366428, label="Possible Rain Totem", style="blue", note="Possible / variable spawn"},
            {x=.488974, y=.419897, label="Possible Rain Totem", style="blue", note="Confirmed active here on one run"},
            {x=.300675, y=.400010, label="Possible Rain Totem", style="blue", note="Confirmed active here on one run"},
            {x=.558302, y=.746048, label="Possible Rain Totem", style="blue", note="Possible / variable spawn"},
            {x=.617511, y=.456752, label="Salt Water Fountain", style="green", note="Fixed final interaction"},

            {x=.518377, y=.292241, label="Gold Crystal", style="crystal_gold", note="Recorded crystal location"},
            {x=.617989, y=.517571, label="Blue Crystal", style="crystal_blue", note="Recorded crystal location"},
            {x=.372974, y=.435480, label="Red Crystal", style="crystal_red", note="Recorded crystal location"},

            {x=.418865, y=.433534, label="Skyshard", style="skyshard", note="Under the watchful eye of a great protector."},
        },
    },

    [2853] = {
        name = "Haunted Undercroft",
        wing = "Cursed Castle Wing",
        secret = "Connoisseur's Vision",
        prerequisite = "Carafe of Salt Water",
        prerequisiteSource = "Sinking Courtyard",
        warning = "DO THIS SECRET BEFORE COMPLETING THE NORMAL ROOM MECHANIC.",
        instructions = {
            "BEFORE normal mechanic: use Salt Water in center pot.",
            "Kill secret boss for Connoisseur's Vision.",
        },
        pins = {},
    },

    [2852] = {
        name = "Prison of the Unrepentant",
        wing = "Cursed Castle Wing",
        secret = "Cursed Castle Wing Seal",
        prerequisite = "Subjugating Mindspore",
        prerequisiteSource = "Fungal Chasm",
        instructions = {
            "Search side rooms for Psychical Escape.",
            "Interact for Cursed Castle Wing Seal.",
        },
        pins = {},
    },
}
