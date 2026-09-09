-----------------------------------------------------------
-- If stage is not specified, the star will be maxed out
-- If flex is specified, it uses the index in the flex data
-- If passive is specified, it uses the index in the respective data
-- If deprioritizeSlotting is specified, only slot it if there is still space after allocating all
-----------------------------------------------------------
local RED_PVP = {
    nodes = {
        {
            id = 37, -- Tumbling (open nodes)
            stage = 1,
        },
        {
            id = 53, -- Mystic Tenacity (open nodes)
            stage = 1,
        },
        {
            id = 275, -- Pain's Refuge
        },
        {
            id = 273, -- Sustained by Suffering
        },
        {
            id = 57, -- Survival Instincts
        },
        {
            id = 128, -- Defiance (open nodes)
            stage = 1,
        },
        {
            id = 59, -- Juggernaut
        },
        ------------------
        -- slottables done
        ------------------
        {
            id = 128, -- Defiance (maxed)
        },
        {
            id = 113, -- Hero's Vigor
        },
        {
            id = 42, -- Hasty
        },
        {
            id = 37, -- Tumbling (maxed)
        },
        {
            id = 53, -- Mystic Tenacity (maxed)
        },
        {
            id = 39, -- Tireless Guardian (open nodes)
            stage = 1,
        },
        {
            id = 43, -- Fortification
        },
        {
            id = 39, -- Tireless Guardian (maxed)
        },
        {
            id = 44, -- Nimble Protector
        },
        {
            id = 38, -- Sprinter
        },
        {
            id = 45, -- Piercing Gaze
        },
        {
            id = 58, -- Tempered Soul
        },
        {
            id = 40, -- Savage Defense
        },
        {
            id = 50, -- Bashing Brutality
        },
        ----------------
        -- passives done
        ----------------
        {
            id = 270, -- Celerity
        },
        {
            id = 52, -- Slippery
        },
        {
            id = 46, -- Bastion
        },
        {
            id = 2, -- Boundless Vitality
        },
    },
}


-----------------------------------------------------------
-- applyFunc
-----------------------------------------------------------
function DynamicCP.SmartPresets.ApplyRedGeneralPvP()
    return DynamicCP.ApplySmartPreset("Red", RED_PVP)
end
