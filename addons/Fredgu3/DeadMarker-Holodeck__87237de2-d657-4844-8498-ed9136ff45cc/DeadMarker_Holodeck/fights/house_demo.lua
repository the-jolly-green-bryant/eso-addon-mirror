-- House demo (smoke pack). Short walk: boss, LT, roles, stack/soak spots.
-- Facing is pack radians (0 = +Z). CompactFight encodes on register.

local fight = {
    id = "house_demo",
    name = "Demo · walkthrough",
    trial = "Demo",
    boss = "Demo",
    variant = "Basic",
    outcome = "kill",
    durationSec = 22,
    phases = {
        { id = 1, name = "Opener",     t = 0 },
        { id = 2, name = "Lieutenant", t = 5 },
        { id = 3, name = "Stack call", t = 10 },
        { id = 4, name = "Burn",       t = 15 },
    },
    entities = {
        {
            id = "boss",
            kind = "boss",
            label = "Boss",
            track = {
                { t = 0,  x = 0, z = 0, visible = true, facing = 1.57 },
                { t = 5,  x = 4, z = 0, facing = 0 },
                { t = 10, x = 4, z = 4, facing = -1.57 },
                { t = 15, x = 0, z = 4, facing = 3.14 },
                { t = 22, x = 0, z = 0, facing = 3.14 },
            },
        },
        {
            id = "lieutenant",
            kind = "mini",
            label = "Lieutenant",
            track = {
                { t = 0,  visible = false },
                { t = 5,  x = 8, z = 2, visible = true, facing = -1.89 },
                { t = 9,  x = 6, z = -2, facing = -0.79 },
                { t = 12, x = 3, z = 1, visible = true, facing = -2.09 },
                { t = 14, visible = false },
                { t = 17, x = -3, z = 3, visible = true, facing = 1.57 },
                { t = 22, x = -3, z = 5, visible = true, facing = 0 },
            },
        },
        {
            id = "tank_mt",
            kind = "tank",
            label = "Main tank",
            track = {
                { t = 0,  x = -1.5, z = 2.5, visible = true, facing = 1.94 },
                { t = 5,  x = 2.5,  z = 1.0, facing = 2.68 },
                { t = 10, x = 2.0,  z = 3.5, facing = -1.77 },
                { t = 15, x = -0.5, z = 3.0, facing = -2.03 },
                { t = 22, x = -1.0, z = 2.0, facing = -2.03 },
            },
        },
        {
            id = "healer_1",
            kind = "healer",
            label = "Healer",
            track = {
                { t = 0,  x = -4, z = 1, visible = true, facing = 2.36 },
                { t = 6,  x = -3, z = 0, facing = 0.46 },
                { t = 10, x = -2, z = 2, facing = 1.57 },
                { t = 14, x = -2, z = 2, facing = -2.03 },
                { t = 18, x = -3.5, z = 1.5, facing = -2.36 },
                { t = 22, x = -4, z = 1, facing = -2.36 },
            },
        },
        {
            id = "dps_ranged",
            kind = "dps",
            label = "Ranged DPS",
            track = {
                { t = 0,  x = -5, z = -1, visible = true, facing = 0.79 },
                { t = 8,  x = -4, z = 0, facing = 0.73 },
                { t = 10, x = -2.2, z = 1.8, facing = 1.57 },
                { t = 14, x = -2.2, z = 1.8, facing = -2.53 },
                { t = 22, x = -5, z = -1, facing = -2.53 },
            },
        },
        {
            id = "stack_main",
            kind = "stack",
            label = "Main stack",
            track = {
                { t = 0,  x = -3, z = 3, visible = true },
                { t = 10, x = -2, z = 2 },
                { t = 22, x = -2, z = 2 },
            },
        },
        {
            id = "soak_A",
            kind = "soak",
            label = "Soak A",
            track = {
                { t = 0,  visible = false },
                { t = 12, x = 1, z = -3, visible = true },
                { t = 16, visible = false },
            },
        },
    },
}

if Holodeck and Holodeck.RegisterFight then
    Holodeck.RegisterFight(fight)
end
