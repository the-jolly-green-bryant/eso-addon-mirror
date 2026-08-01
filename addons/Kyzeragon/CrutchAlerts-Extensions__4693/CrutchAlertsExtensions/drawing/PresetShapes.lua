local CAE = CrutchAlertsExtensions


---------------------------------------------------------------------
-- Presets that can be added with a button
---------------------------------------------------------------------
CAE.PresetShapes = {
---------------------------------------------------------------------
-- Sets
    ["Roar of Alkosh"] = {
        type = CAE.RECTANGLE,
        rgb = false,
        color = {0, 0.8, 1, 0.1},
        fillColor = {1, 1, 1, 0},
        radius = 9,
        height = 15,
        yOffset = 5,
        forwardOffset = 750,
        conditionalSetId = 232,
        activeBarOnly = true,
    },
    ["Perfected Void Bash (vVH)"] = {
        type = CAE.CIRCLE,
        rgb = true,
        color = {1, 1, 1, 0.5},
        radius = 12,
        yOffset = 5,
        forwardOffset = 0,
        conditionalSetId = 564,
        depthBuffers = false,
    },
    ["Turning Tide"] = {
        type = CAE.RECTANGLE,
        rgb = false,
        color = {0, 0.5, 1, 0.3},
        fillColor = {1, 1, 1, 0},
        radius = 10,
        height = 10,
        yOffset = 5,
        forwardOffset = 500,
        conditionalSetId = 622,
        activeBarOnly = true,
    },

---------------------------------------------------------------------
-- Slotted skills
    ["Ferocious Roar"] = {
        type = CAE.CIRCLE,
        rgb = false,
        color = {1, 1, 1, 0.1},
        radius = 10,
        yOffset = 5,
        forwardOffset = 0,
        conditionalAbilityId = 39113,
        depthBuffers = false,
    },
    ["Pragmatic Fatecarver"] = {
        type = CAE.RECTANGLE,
        rgb = false,
        color = {0, 1, 0, 0.2},
        fillColor = {1, 1, 1, 0},
        radius = 3,
        height = 23.5,
        yOffset = 5,
        forwardOffset = 1025,
        conditionalAbilityId = 193398,
        activeBarOnly = true,
    },
    ["Blockade of Fire"] = {
        type = CAE.RECTANGLE,
        rgb = false,
        color = {1, 0, 0, 0.2},
        fillColor = {1, 1, 1, 0},
        radius = 12,
        height = 18,
        yOffset = 5,
        forwardOffset = 900,
        conditionalAbilityId = 39012,
        activeBarOnly = true,
    },
    ["Blockade of Storms"] = {
        type = CAE.RECTANGLE,
        rgb = false,
        color = {0, 1, 1, 0.2},
        fillColor = {1, 1, 1, 0},
        radius = 12,
        height = 18,
        yOffset = 5,
        forwardOffset = 900,
        conditionalAbilityId = 39018,
        activeBarOnly = true,
    },
    ["Blockade of Frost"] = {
        type = CAE.RECTANGLE,
        rgb = false,
        color = {0, 0, 1, 0.2},
        fillColor = {1, 1, 1, 0},
        radius = 12,
        height = 18,
        yOffset = 5,
        forwardOffset = 900,
        conditionalAbilityId = 39028,
        activeBarOnly = true,
    },
    ["Streak (flat ground)"] = {
        type = CAE.CIRCLE,
        rgb = false,
        color = {1, 1, 1, 0.8},
        radius = 0.5,
        yOffset = 5,
        forwardOffset = 1500,
        conditionalAbilityId = 23236,
        depthBuffers = false,
    },

---------------------------------------------------------------------
-- Effects
    ["Deep Fissure (2nd)"] = {
        type = CAE.RECTANGLE,
        rgb = false,
        color = {0.3, 1, 0.8, 0.2},
        fillColor = {0, 1, 1, 0.1},
        radius = 7,
        height = 20,
        yOffset = 5,
        forwardOffset = 1000,
        conditionalEffectId = 178028,
    },
}
