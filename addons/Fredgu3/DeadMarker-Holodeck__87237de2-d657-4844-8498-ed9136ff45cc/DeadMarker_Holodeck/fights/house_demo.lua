-- House demo fight pack (library entry).
-- Meters relative to origin. World-aligned XZ (no facing yet).
-- Registered at load via Holodeck.RegisterFight.

local fight = {
    id = "house_demo",
    name = "House Demo (boss + lieutenant)",
    durationSec = 20,
    phases = {
        { id = 1, name = "Opener",     t = 0 },
        { id = 2, name = "Lieutenant", t = 5 },
        { id = 3, name = "Burn",       t = 14 },
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
                { t = 20, x = 0, z = 0 },
            },
        },
        {
            id = "lieutenant",
            kind = "miniboss",
            label = "Lieutenant",
            track = {
                { t = 0,  visible = false },
                { t = 5,  x = 8, z = 2, visible = true },
                { t = 9,  x = 6, z = -2 },
                { t = 12, x = 3, z = 1 },
                { t = 14, visible = false },
                { t = 17, x = -3, z = 3, visible = true },
                { t = 20, x = -3, z = 5, visible = true },
            },
        },
        {
            id = "stack_main",
            kind = "stack",
            label = "Main stack",
            track = {
                { t = 0,  x = -3, z = 3, visible = true },
                { t = 10, x = -2, z = 2 },
                { t = 20, x = -2, z = 2 },
            },
        },
    },
}

if Holodeck and Holodeck.RegisterFight then
    Holodeck.RegisterFight(fight)
end
