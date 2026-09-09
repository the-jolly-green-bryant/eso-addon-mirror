-----------------------------------------------------------
-- If stage is not specified, the star will be maxed out
-- If flex is specified, it uses the index in the flex data
-- If passive is specified, it uses the index in the respective data
-- If deprioritizeSlotting is specified, only slot it if there is still space after allocating all
-----------------------------------------------------------
local BLUE_PVP = {
    nodes = {
        {
            id = 6, -- Tireless Discipline (open nodes)
            stage = 1,
        },
        {
            id = 20, -- Quick Recovery (open nodes)
            stage = 1,
        },
        {
            id = 265, -- Ironclad
        },
        {
            id = 10, -- Piercing (open nodes)
            stage = 1,
        },
        {
            id = 264, -- Master-at-Arms
        },
        {
            id = 11, -- Precision (open nodes)
            stage = 1,
        },
        {
            id = 12, -- Fighting Finesse
        },
        {
            id = 108, -- Blessed (open nodes)
            stage = 1,
        },
        {
            id = 26, -- Focused Mending (open nodes)
            stage = 1,
        },
        {
            id = 29, -- Cleansing Revival
        },
        ------------------
        -- slottables done
        ------------------
        {
            id = 6, -- Tireless Discipline (maxed)
        },
        {
            id = 10, -- Piercing (maxed)
        },
        {
            id = 99, -- Eldritch Insight
        },
        {
            id = 11, -- Precision (maxed)
        },
        {
            id = 108, -- Blessed (maxed)
        },
        {
            id = 20, -- Quick Recovery (maxed)
        },
        {
            id = 15, -- Elemental Aegis
        },
        {
            id = 16, -- Hardy
        },
        {
            id = 17, -- Flawless Ritual
        },
        {
            id = 21, -- War Mage
        },
        {
            id = 18, -- Battle Mastery
        },
        {
            id = 22, -- Mighty
        },
        {
            id = 14, -- Preparation
        },
        ----------------
        -- passives done
        ----------------
        {
            id = 23, -- Biting Aura
        },
    },
}


-----------------------------------------------------------
-- applyFunc
-----------------------------------------------------------
function DynamicCP.SmartPresets.ApplyBlueGeneralPVP()
    return DynamicCP.ApplySmartPreset("Blue", BLUE_PVP)
end
