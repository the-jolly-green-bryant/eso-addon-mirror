-----------------------------------------------------------
-- Pragmatic Fatecarver for Bastion
-----------------------------------------------------------
local red_dps_flex_pragmatic = {
    46, -- Bastion
}

local red_dps_flex_nonpragmatic = {
    35, -- Rejuvenation
}


-----------------------------------------------------------
-- Role presets
-----------------------------------------------------------
-- If stage is not specified, the star will be maxed out
-- If flex is specified, it uses the index in the flex data
-- If passive is specified, it uses the index in the respective data
-- If deprioritizeSlotting is specified, only slot it if there is still space after allocating all
-----------------------------------------------------------
local RED_DPS = {
    GetFlex = function(_, isHABuild, isPragmatic, _, index, totalPoints)
        if (isPragmatic) then
            return red_dps_flex_pragmatic[index]
        end
        return red_dps_flex_nonpragmatic[index]
    end,
    nodes = {
        {
            id = 2, -- Boundless Vitality
        },
        {
            id = 34, -- Fortified
        },
        {
            id = 39, -- Tireless Guardian (open nodes)
            stage = 1,
        },
        {
            id = 42, -- Hasty (open nodes)
            stage = 1,
        },
        {
            id = 113, -- Hero's Vigor
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
            id = 42, -- Hasty (maxed)
        },
        {
            id = 38, -- Sprinter
        },
        {
            id = 44, -- Nimble Protector
        },
        {
            id = 45, -- Piercing Gaze (open nodes)
            stage = 1,
        },
        {
            id = 58, -- Tempered Soul (open nodes)
            stage = 1,
        },
        {
            flex = 1, -- Bastion or Rejuvenation
        },
        {
            id = 56, -- Spirit Mastery
        },
        {
            id = 58, -- Tempered Soul (maxed)
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
        ---------------------
        -- most passives done
        ---------------------
        {
            id = 270, -- Celerity
        },
        {
            id = 35, -- Rejuvenation
        },
        {
            id = 52, -- Slippery
        },
        {
            id = 46, -- Bastion
        },
        {
            id = 45, -- Piercing Gaze (maxed)
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
    },
}

local RED_HEAL = {
    nodes = {
        {
            id = 2, -- Boundless Vitality
        },
        {
            id = 34, -- Fortified
        },
        {
            id = 39, -- Tireless Guardian (open nodes)
            stage = 1,
        },
        {
            id = 42, -- Hasty (open nodes)
            stage = 1,
        },
        {
            id = 113, -- Hero's Vigor
        },
        {
            id = 270, -- Celerity
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
            id = 51, -- Expert Evasion
        },
        {
            id = 39, -- Tireless Guardian (maxed)
        },
        {
            id = 42, -- Hasty (maxed)
        },
        {
            id = 44, -- Nimble Protector
        },
        {
            id = 53, -- Mystic Tenacity
        },
        {
            id = 38, -- Sprinter
        },
        {
            id = 45, -- Piercing Gaze (open nodes)
            stage = 1,
        },
        {
            id = 58, -- Tempered Soul
        },
        {
            id = 40, -- Savage Defense
        },
        --------------------
        -- useful stuff done
        --------------------
        {
            id = 52, -- Slippery
        },
        {
            id = 46, -- Bastion
        },
        {
            id = 63, -- Shield Master
        },
        {
            id = 35, -- Rejuvenation
        },
        {
            id = 273, -- Sustained by Suffering
        },
        {
            id = 50, -- Bashing Brutality
        },
        {
            id = 45, -- Piercing Gaze
        },
    },
}

local RED_TANK = {
    nodes = {
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
            id = 34, -- Fortified
        },
        {
            id = 2, -- Boundless Vitality
        },
        {
            id = 42, -- Hasty (open nodes)
            stage = 1,
        },
        {
            id = 113, -- Hero's Vigor
        },
        {
            id = 35, -- Rejuvenation
        },
        {
            id = 37, -- Tumbling
        },
        {
            id = 128, -- Defiance
        },
        {
            id = 270, -- Celerity
        },
        {
            id = 42, -- Hasty (maxed)
        },
        {
            id = 44, -- Nimble Protector
        },
        {
            id = 38, -- Sprinter
        },
        --------------------------------------
        -- important stuff done
        -- bonus passives and slottables below
        --------------------------------------
        {
            id = 40, -- Savage Defense
        },
        {
            id = 267, -- Bracing Anchor
        },
        {
            id = 45, -- Piercing Gaze (open nodes)
            stage = 1,
        },
        {
            id = 58, -- Tempered Soul
        },
        {
            id = 50, -- Bashing Brutality
        },
        {
            id = 53, -- Mystic Tenacity
        },
        {
            id = 45, -- Piercing Gaze
        },
        {
            id = 46, -- Bastion
        },
        {
            id = 51, -- Expert Evasion
        },
        {
            id = 63, -- Shield Master
        },
    },
}


-----------------------------------------------------------
-- applyFunc
-----------------------------------------------------------
function DynamicCP.SmartPresets.ApplyRedPVE()
    local role = GetSelectedLFGRole()
    if (role == LFG_ROLE_TANK) then
        return DynamicCP.ApplySmartPreset("Red", RED_TANK)
    elseif (role == LFG_ROLE_HEAL) then
        return DynamicCP.ApplySmartPreset("Red", RED_HEAL)
    else
        return DynamicCP.ApplySmartPreset("Red", RED_DPS)
    end
end
