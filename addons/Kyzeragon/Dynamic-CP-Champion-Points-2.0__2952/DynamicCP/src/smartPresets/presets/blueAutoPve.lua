-----------------------------------------------------------
-- AOE vs ST (more later?)
-----------------------------------------------------------
local blue_dps_flex_aoe = {
    264, -- Master-at-Arms
    23, -- Biting Aura
    8, -- Wrathful Strikes
    277, -- Exploiter
}

local blue_dps_flex_st = {
    264, -- Master-at-Arms
    25, -- Deadly Aim
    8, -- Wrathful Strikes
    277, -- Exploiter
}

local blue_dps_flex_ha = {
    259, -- Weapons Expert
    12, -- Fighting Finesse
    25, -- Deadly Aim
    277, -- Exploiter
}


-----------------------------------------------------------
-- Passive stats
-----------------------------------------------------------
local blue_dps_stam = { -- TODO: fatecarver "mag" instead?
    18, -- Battle Mastery
    22, -- Mighty
    17, -- Flawless Ritual
    21, -- War Mage
    6, -- Tireless Discipline
    99, -- Eldritch Insight
}

local blue_dps_mag = {
    17, -- Flawless Ritual
    21, -- War Mage
    18, -- Battle Mastery
    22, -- Mighty
    99, -- Eldritch Insight
    6, -- Tireless Discipline
}


-----------------------------------------------------------
-- Role presets
-----------------------------------------------------------
-- If stage is not specified, the star will be maxed out
-- If flex is specified, it uses the index in the flex data
-- If passive is specified, it uses the index in the respective data
-- If deprioritizeSlotting is specified, only slot it if there is still space after allocating all
-----------------------------------------------------------
local BLUE_DPS = {
    GetFlex = function(hasAoeSpammable, isHABuild, _, _, index, totalPoints)
        if (isHABuild) then
            return blue_dps_flex_ha[index]
        elseif (hasAoeSpammable) then
            return blue_dps_flex_aoe[index]
        end
        return blue_dps_flex_st[index]
    end,
    GetPassive = function(isStamHigher, index)
        if (isStamHigher) then
            return blue_dps_stam[index]
        end
        return blue_dps_mag[index]
    end,
    nodes = {
        {
            id = 10, -- Piercing (open nodes)
            stage = 1,
        },
        {
            id = 11, -- Precision (open nodes)
            stage = 1,
        },
        {
            flex = 1,
        },
        {
            flex = 2,
        },
        {
            flex = 3,
        },
        {
            flex = 4,
        },
        {
            id = 10, -- Piercing (maxed)
        },
        {
            id = 11, -- Precision (maxed)
        },
        {
            passive = 1, -- Flawless Ritual / Battle Mastery
        },
        {
            passive = 2, -- War Mage / Mighty
        },
        {
            passive = 3, -- Flawless Ritual / Battle Mastery
        },
        {
            passive = 4, -- War Mage / Mighty
        },
        {
            passive = 5, -- Eldritch Insight / Tireless Discipline
        },
        {
            id = 20, -- Quick Recovery (open nodes)
            stage = 1,
        },
        {
            id = 14, -- Preparation
        },
        {
            id = 15, -- Elemental Aegis
        },
        {
            id = 16, -- Hardy
        },
        {
            passive = 6, -- Tireless Discipline / Eldritch Insight
        },
        {
            id = 20, -- Quick Recovery (maxed)
        },
        {
            id = 108, -- Blessed
        },
        -------------------------------------
        -- 4 slottables and all passives done
        -- below is bonus
        -------------------------------------
        {
            id = 23, -- Biting Aura
        },
        {
            id = 12, -- Fighting Finesse
        },
        {
            id = 27, -- Thaumaturge
        },
        {
            id = 25, -- Deadly Aim
        },
        {
            id = 30, -- Reaving Blows
        },
        {
            id = 31, -- Backstabber
        },
    },
}

local BLUE_HEAL = {
    nodes = {
        {
            id = 99, -- Eldritch Insight
        },
        {
            id = 108, -- Blessed
        },
        {
            id = 20, -- Quick Recovery (open nodes)
            stage = 1,
        },
        {
            id = 14, -- Preparation
        },
        {
            id = 24, -- Soothing Tide
        },
        {
            id = 28, -- Swift Renewal
        },
        {
            id = 263, -- Enlivening Overflow
        },
        {
            id = 262, -- From the Brink
        },
        {
            id = 11, -- Precision
        },
        {
            id = 6, -- Tireless Discipline
        },
        {
            id = 16, -- Hardy
        },
        {
            id = 15, -- Elemental Aegis
        },
        {
            id = 20, -- Quick Recovery (maxed)
        },
        {
            id = 10, -- Piercing (open nodes)
            stage = 1,
        },
        {
            id = 17, -- Flawless Ritual
        },
        {
            id = 21, -- War Mage
        },
        {
            id = 10, -- Piercing (maxed)
        },
        {
            id = 18, -- Battle Mastery
        },
        {
            id = 22, -- Mighty
        },
        -------------------------------------
        -- 4 slottables and all passives done
        -- below is bonus
        -------------------------------------
        {
            id = 9, -- Rejuvenator
        },
        {
            id = 26, -- Focused Mending
        },
        {
            id = 12, -- Fighting Finesse
        },
        {
            id = 4, -- Untamed Aggression
        },
    },
}

local BLUE_TANK = {
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
            id = 14, -- Preparation
        },
        {
            id = 16, -- Hardy
        },
        {
            id = 15, -- Elemental Aegis
        },
        {
            id = 20, -- Quick Recovery (maxed)
        },
        {
            id = 6, -- Tireless Discipline (maxed)
        },
        {
            id = 99, -- Eldritch Insight
        },
        {
            id = 108, -- Blessed
        },
        {
            id = 133, -- Unassailable (open nodes)
            stage = 1,
        },
        {
            id = 159, -- Bulwark
        },
        {
            id = 265, -- Ironclad
        },
        {
            id = 134, -- Duelist's Rebuff
        },
        {
            id = 136, -- Enduring Resolve
        },
        -------------------------------------
        -- 4 slottables done
        -- below is not as important
        -------------------------------------
        {
            id = 11, -- Precision
        },
        {
            id = 133, -- Unassailable (maxed)
        },
        {
            id = 10, -- Piercing (open nodes)
            stage = 1,
        },
        {
            id = 17, -- Flawless Ritual
        },
        {
            id = 18, -- Battle Mastery
        },
        {
            id = 10, -- Piercing (maxed)
        },
        {
            id = 22, -- Mighty
        },
        {
            id = 21, -- War Mage
        },
    },
}

-- TODO: do jabs? do... oakensoul? :prettypuke:
-----------------------------------------------------------
-- applyFunc
-----------------------------------------------------------
function DynamicCP.SmartPresets.ApplyBluePVE()
    local role = GetSelectedLFGRole()
    if (role == LFG_ROLE_TANK) then
        return DynamicCP.ApplySmartPreset("Blue", BLUE_TANK)
    elseif (role == LFG_ROLE_HEAL) then
        return DynamicCP.ApplySmartPreset("Blue", BLUE_HEAL)
    else
        return DynamicCP.ApplySmartPreset("Blue", BLUE_DPS)
    end
end
