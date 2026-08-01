local DP = _G["DynamicPotions"]

function DP:GetEffectMaskFromLink(itemLink)
    if not itemLink then
        return nil
    end

    local data = itemLink:match("|H.:item:(.-)|h.-|h")
    local mask = select(21, zo_strsplit(':', data))
    return tonumber(mask) or 0
end

-- Seeded effect tables (work in progress)
DP.EFFECT_TABLE = {
    HEROISM = {
        [197919] = true, -- Mag + Stam + Heroism
        [2031616] = true, -- minor heroism example
    },
    UNSTOPPABLE = {
        [1245184] = true,
        [1245443] = true,
    },
    TRI_STAT = {
        [8454917] = true,
        [66309] = true,
    },
    ENDURANCE = {
        [66825] = true,
    },
    BI_STAT = {
        [197888] = true, -- Mag + Stam
    },
    RESISTS = {
        PHYSICAL_ONLY = {
            [589824] = true,
            [596224] = true,
        },
        SPELL_ONLY = {
            [458752] = true,
            [198425] = true,
            [788224] = true,
        },
        BOTH_RESISTS = {
            [67337] = true,
            [461056] = true,
        },
    }
}

-- Classification according to priority
function DP:Classify(effectMask)
    local E = self.EFFECT_TABLE

    if E.HEROISM[effectMask] then
        return "HEROISM"
    end
    if E.UNSTOPPABLE[effectMask] then
        return "IMMOVABLE"
    end
    if E.RESISTS.BOTH_RESISTS[effectMask] then
        return "UNBROKEN"
    end
    if E.RESISTS.SPELL_ONLY[effectMask] then
        return "SRESIST"
    end
    if E.RESISTS.PHYSICAL_ONLY[effectMask] then
        return "PRESIST"
    end
    if E.TRI_STAT[effectMask] then
        return "TRISTAT"
    end
    if E.BI_STAT[effectMask] then
        return "BISTAT"
    end
    if E.ENDURANCE[effectMask] then
        return "ENDURANCE"
    end
    return nil
end

-- Tier detection: combined level (level + cp)
DP.TIERS_BREAKPOINTS = {
    { level = 3, id = "DP_TIER_3" },
    { level = 10, id = "DP_TIER_10" },
    { level = 20, id = "DP_TIER_20" },
    { level = 30, id = "DP_TIER_30" },
    { level = 40, id = "DP_TIER_40" },
    { level = 60, id = "DP_TIER_60" }, -- L50+CP10
    { level = 100, id = "DP_TIER_100" }, -- L50+CP50
    { level = 150, id = "DP_TIER_150" }, -- L50+CP100
    { level = 200, id = "DP_TIER_200" }, -- L50+CP150
}

function DP:GetTierName(combinedLevel)
    local highestTierId = "DP_TIER_30" -- default

    for _, tierData in ipairs(self.TIERS_BREAKPOINTS) do
        if combinedLevel >= tierData.level then
            highestTierId = tierData.id
        else
            break
        end
    end

    -- Convert a stored name like into the numeric/global string ID, if available.
    local stringIdOrName = _G[highestTierId] or highestTierId
    return GetString(stringIdOrName)
end



function DP:FormatPotionName(classification, combinedLevel)
    local tier = self:GetTierName(combinedLevel) or "Potion"

    if classification == "HEROISM" then
        return string.format("%s of Heroism", tier)
    elseif classification == "IMMOVABLE" then
        return string.format("%s of Immovability", tier)
    elseif classification == "UNBROKEN" then
        return string.format("%s of the Unbroken", tier)
    elseif classification == "PRESIST" then
        return string.format("%s of Armor", tier)
    elseif classification == "SRESIST" then
        return string.format("%s of Spell Resistance", tier)
    elseif classification == "TRISTAT" then
        return string.format("Tri-stat %s", tier)
    elseif classification == "BISTAT" then
        return string.format("Bi-stat %s", tier)
    elseif classification == "ENDURANCE" then
        return string.format("%s of Endurance", tier)
    end
    return nil
end

-- Main icon resolver:
function DP:GetIconFor(classification, combinedLevel)
    local tierIndex
    if combinedLevel >= 60 then
        tierIndex = 5
    elseif combinedLevel >= 40 then
        tierIndex = 4
    elseif combinedLevel >= 30 then
        tierIndex = 3
    elseif combinedLevel >= 20 then
        tierIndex = 2
    else
        tierIndex = 1
    end

    local COLOR_MAP = {
        HEROISM     = "crown_golden",
        IMMOVABLE   = "especial_red",
        UNBROKEN    = "crown_red",
        SRESIST      = "regular_purple",
        PRESIST      = "regular_golden",
        TRISTAT     = "especial_purple",
        BISTAT      = "especial_cyan",
        ENDURANCE      = "especial_yellow",
    }

    local color = COLOR_MAP[classification] or "regular_red"

    ---------------------------------------------------------------------
    --    Final path example:
    --    /DynamicPotions/art/icon_especial_orange_03.dds
    ---------------------------------------------------------------------
    return string.format(
        "/DynamicPotions/art/icon_%s_%02d.dds",
        color,        -- orange / purple / green / etc
        tierIndex     -- 01 - 05
    )
end