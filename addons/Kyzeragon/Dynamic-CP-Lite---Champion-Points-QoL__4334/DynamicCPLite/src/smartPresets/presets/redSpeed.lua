-----------------------------------------------------------
-- If stage is not specified, the star will be maxed out
-- If flex is specified, it uses the index in the flex data
-- If passive is specified, it uses the index in the respective data
-- If deprioritizeSlotting is specified, only slot it if there is still space after allocating all
-----------------------------------------------------------
local RED_SPEED = {
    nodes = {
        {
            id = 38, -- Sprinter (open nodes)
            stage = 1,
        },
        {
            id = 42, -- Hasty (open nodes)
            stage = 1,
        },
        {
            id = 270, -- Celerity
        },
        {
            id = 42, -- Hasty (maxed)
        },
        ---------------------
        -- speed done
        ---------------------
        {
            id = 2, -- Boundless Vitality
        },
        {
            id = 34, -- Fortified
        },
        {
            id = 113, -- Hero's Vigor
        },
        {
            id = 39, -- Tireless Guardian (open nodes)
            stage = 1,
        },
        {
            id = 43, -- Fortification
        },
        {
            id = 37, -- Tumbling
        },
        {
            id = 128, -- Defiance
        },
        {
            id = 39, -- Tireless Guardian (maxed)
        },
        {
            id = 44, -- Nimble Protector
        },
        {
            id = 35, -- Rejuvenation
        },
        {
            id = 38, -- Sprinter (maxed)
        },
        {
            id = 40, -- Savage Defense
        },
        {
            id = 50, -- Bashing Brutality
        },
        {
            id = 53, -- Mystic Tenacity
        },
        {
            id = 45, -- Piercing Gaze (open nodes)
            stage = 1,
        },
        {
            id = 58, -- Tempered Soul
        },
        {
            id = 45, -- Piercing Gaze (maxed)
        },
        ----------------
        -- passives done
        ----------------
        {
            id = 52, -- Slippery
        },
        {
            id = 46, -- Bastion
        },
        {
            id = 47, -- Siphoning Spells
        },
        {
            id = 51, -- Expert Evasion
        },
        {
            id = 48, -- Bloody Renewal
        },
        {
            id = 56, -- Spirit Mastery
        },
    },
}


-----------------------------------------------------------
-- applyFunc
-----------------------------------------------------------
function DynamicCP.SmartPresets.ApplyRedSpeed()
    return DynamicCP.ApplySmartPreset("Red", RED_SPEED)
end
