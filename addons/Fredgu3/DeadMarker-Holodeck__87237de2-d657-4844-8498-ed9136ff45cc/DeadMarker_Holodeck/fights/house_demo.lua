-- House demo fight pack (library entry).
-- Meters relative to origin. World-aligned XZ (no facing yet).
-- Shows: boss + LT + role ghosts (tank/healer) + stack spot.
-- Registered at load via Holodeck.RegisterFight.

local fight = {
    id = "house_demo",
    name = "House Demo (boss + LT + roles)",
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
                { t = 0,  x = 0, z = 0, visible = true },
                { t = 5,  x = 4, z = 0 },
                { t = 10, x = 4, z = 4 },
                { t = 15, x = 0, z = 4 },
                { t = 22, x = 0, z = 0 },
            },
        },
        {
            id = "lieutenant",
            kind = "mini",
            label = "Lieutenant",
            track = {
                { t = 0,  visible = false },
                { t = 5,  x = 8, z = 2, visible = true },
                { t = 9,  x = 6, z = -2 },
                { t = 12, x = 3, z = 1 },
                { t = 14, visible = false },
                { t = 17, x = -3, z = 3, visible = true },
                { t = 22, x = -3, z = 5, visible = true },
            },
        },
        -- Role ghosts: raid-lead demo / automated path when team can't record live
        {
            id = "tank_mt",
            kind = "tank",
            label = "Main tank",
            track = {
                { t = 0,  x = -1.5, z = 2.5, visible = true },
                { t = 5,  x = 2.5,  z = 1.0 },
                { t = 10, x = 2.0,  z = 3.5 },
                { t = 15, x = -0.5, z = 3.0 },
                { t = 22, x = -1.0, z = 2.0 },
            },
        },
        {
            id = "healer_1",
            kind = "healer",
            label = "Healer",
            track = {
                { t = 0,  x = -4, z = 1, visible = true },
                { t = 6,  x = -3, z = 0 },
                { t = 10, x = -2, z = 2 },  -- toward stack
                { t = 14, x = -2, z = 2 },
                { t = 18, x = -3.5, z = 1.5 },
                { t = 22, x = -4, z = 1 },
            },
        },
        {
            id = "dps_ranged",
            kind = "dps",
            label = "Ranged DPS",
            track = {
                { t = 0,  x = -5, z = -1, visible = true },
                { t = 8,  x = -4, z = 0 },
                { t = 10, x = -2.2, z = 1.8 }, -- stack with team
                { t = 14, x = -2.2, z = 1.8 },
                { t = 22, x = -5, z = -1 },
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
