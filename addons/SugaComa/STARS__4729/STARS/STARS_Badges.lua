-- STARS_Badges.lua
-- Standalone visual-state module for STARS Legacy/Prestige heraldry.
-- RELEASE-CANDIDATE STATUS: LEGACY, BRONZE, SILVER AND GOLD APPROVED
--
-- Design rules:
--   Legacy  : flat two-layer emblems, controlled colour-family progression.
--   Bronze  : procedural shield + flat Legacy charge.
--   Silver  : procedural shield + decorative gold charge.
--   Gold    : richer shield palette/layout + detailed prestige charge.
--
-- This module owns NO SavedVariables. STARS progression remains authoritative.

local STARS = STARS
STARS.BADGES = STARS.BADGES or {}
local B = STARS.BADGES

B.VERSION = "0.6.13"
B.RENDERER_READY = true
B.ASSETS_READY = true
B.LEGACY_ASSETS_READY = true
B.PRESTIGE_ASSETS_READY = true

--[[
DEVELOPER HERALDRY GATES (disabled for the spoiler-free build)

Uncomment together with the preview state/menu in STARS.lua and the preview
override in STARS_Journal.lua if the artwork review rig is needed again.

B.DEVELOPMENT_PREVIEW_READY = true
B.DEVELOPMENT_NATIVE_LEGACY_READY = true
B.DEVELOPMENT_PRESTIGE_PREVIEW_READY = true
]]

B.PRESTIGE_CLASS = {
    LEGACY = "legacy",
    BRONZE = "bronze",
    SILVER = "silver",
    GOLD = "gold",
}


B.ASSET_PATHS = {
    shields = {
        round  = "STARS/Badges/Shields/shield_round.dds",
        oblong = "STARS/Badges/Shields/shield_oblong.dds",
        kite   = "STARS/Badges/Shields/shield_kite.dds",
        silver = "STARS/Badges/Shields/shield_silver.dds",
        gold   = "STARS/Badges/Shields/shield_gold.dds",
    },
    fields = {
        solid            = "STARS/Badges/Fields/field_solid.dds",
        per_pale         = "STARS/Badges/Fields/field_per_pale.dds",
        per_fess         = "STARS/Badges/Fields/field_per_fess.dds",
        quartered        = "STARS/Badges/Fields/field_quartered.dds",
        bend             = "STARS/Badges/Fields/field_bend.dds",
        bend_sinister    = "STARS/Badges/Fields/field_bend_sinister.dds",
        chevron          = "STARS/Badges/Fields/field_chevron.dds",
        inverted_chevron = "STARS/Badges/Fields/field_inverted_chevron.dds",
        pale             = "STARS/Badges/Fields/field_pale.dds",
        fess             = "STARS/Badges/Fields/field_fess.dds",
        chief            = "STARS/Badges/Fields/field_chief.dds",
        base             = "STARS/Badges/Fields/field_base.dds",
        cross            = "STARS/Badges/Fields/field_cross.dds",
        saltire          = "STARS/Badges/Fields/field_saltire.dds",
        pile             = "STARS/Badges/Fields/field_pile.dds",
        silver_per_pale  = "STARS/Badges/Fields/field_silver_per_pale.dds",
        gold_per_pale    = "STARS/Badges/Fields/field_gold_per_pale.dds",
    },
    rims = {
        none   = "STARS/Badges/Rims/rim_none.dds",
        thin   = "STARS/Badges/Rims/rim_thin.dds",
        medium = "STARS/Badges/Rims/rim_medium.dds",
        thick  = "STARS/Badges/Rims/rim_thick.dds",
        double = "STARS/Badges/Rims/rim_double.dds",
        inner  = "STARS/Badges/Rims/rim_inner.dds",
        ornate = "STARS/Badges/Rims/rim_ornate.dds",
        silver_ornate = "STARS/Badges/Rims/rim_silver_ornate.dds",
        gold_ornate   = "STARS/Badges/Rims/rim_gold_ornate.dds",
    },
    bronzeCharges = {
        wayfarer = {
            a = "STARS/Badges/Charges/bronze_wayfarer_ring.dds",
            b = "STARS/Badges/Charges/bronze_wayfarer_star.dds",
        },
        pathfinder = {
            a = "STARS/Badges/Charges/bronze_pathfinder_a.dds",
            b = "STARS/Badges/Charges/bronze_pathfinder_b.dds",
        },
        standard_bearer = {
            a = "STARS/Badges/Charges/bronze_standard_bearer_a.dds",
            b = "STARS/Badges/Charges/bronze_standard_bearer_b.dds",
        },
        vanguard = {
            a = "STARS/Badges/Charges/bronze_vanguard_a.dds",
            b = "STARS/Badges/Charges/bronze_vanguard_b.dds",
        },
        guardian = {
            a = "STARS/Badges/Charges/bronze_guardian_a.dds",
            b = "STARS/Badges/Charges/bronze_guardian_b.dds",
        },
        sentinel = {
            a = "STARS/Badges/Charges/bronze_sentinel_a.dds",
            b = "STARS/Badges/Charges/bronze_sentinel_b.dds",
        },
        champion = {
            a = "STARS/Badges/Charges/bronze_champion_a.dds",
            b = "STARS/Badges/Charges/bronze_champion_b.dds",
        },
        paragon = {
            a = "STARS/Badges/Charges/bronze_paragon_a.dds",
            b = "STARS/Badges/Charges/bronze_paragon_b.dds",
        },
        exemplar = {
            a = "STARS/Badges/Charges/bronze_exemplar_a.dds",
            b = "STARS/Badges/Charges/bronze_exemplar_b.dds",
        },
        luminary = {
            a = "STARS/Badges/Charges/bronze_luminary_a.dds",
            b = "STARS/Badges/Charges/bronze_luminary_b.dds",
        },
        ascendant = {
            a = "STARS/Badges/Charges/bronze_ascendant_a.dds",
            b = "STARS/Badges/Charges/bronze_ascendant_b.dds",
        },
    },
    legacyAtlas   = "STARS/Badges/legacy_atlas.dds",
    heraldryAtlas = "STARS/Badges/heraldry_atlas.dds",
}

B.LEGACY_RANK_KEYS = {
    "wayfarer",
    "pathfinder",
    "standard_bearer",
    "vanguard",
    "guardian",
    "sentinel",
    "champion",
    "paragon",
    "exemplar",
    "luminary",
    "ascendant",
    "venerated",
}

--[[
DEVELOPER PREVIEW LABELS (disabled; retained for future artwork review)

B.BRONZE_PREVIEW_STATES = {
    { key = "bronze_wayfarer",        rankKey = "wayfarer",        name = "Bronze Wayfarer" },
    { key = "bronze_pathfinder",      rankKey = "pathfinder",      name = "Bronze Pathfinder" },
    { key = "bronze_standard_bearer", rankKey = "standard_bearer", name = "Bronze Standard Bearer" },
    { key = "bronze_vanguard",        rankKey = "vanguard",        name = "Bronze Vanguard" },
    { key = "bronze_guardian",        rankKey = "guardian",        name = "Bronze Guardian" },
    { key = "bronze_sentinel",        rankKey = "sentinel",        name = "Bronze Sentinel" },
    { key = "bronze_champion",        rankKey = "champion",        name = "Bronze Champion" },
    { key = "bronze_paragon",         rankKey = "paragon",         name = "Bronze Paragon" },
    { key = "bronze_exemplar",        rankKey = "exemplar",        name = "Bronze Exemplar" },
    { key = "bronze_luminary",        rankKey = "luminary",        name = "Bronze Luminary" },
    { key = "bronze_ascendant",       rankKey = "ascendant",       name = "Bronze Ascendant" },
}

B.BRONZE_PREVIEW_BY_KEY = {}
for stage, state in ipairs(B.BRONZE_PREVIEW_STATES) do
    state.stage = stage
    B.BRONZE_PREVIEW_BY_KEY[state.key] = state
end
]]

-- Approved/current working palette.
-- Extra blue/green shades can be inserted later without changing renderer logic.
B.COLOURS = {
    frozen_blood        = { hex = "300502", r = 48/255,  g = 5/255,   b = 3/255 },
    craglorn_crimson    = { hex = "4C111C", r = 76/255,  g = 17/255,  b = 28/255 },
    jode_red            = { hex = "721C28", r = 114/255, g = 28/255,  b = 40/255 },
    dragonstar_red      = { hex = "7F2635", r = 127/255, g = 38/255,  b = 53/255 },
    bloodroot_wine      = { hex = "BA2D11", r = 186/255, g = 45/255,  b = 17/255 },

    covenant_blue       = { hex = "232D59", r = 35/255,  g = 45/255,  b = 89/255 },
    vehks_mystic_blue   = { hex = "116DA8", r = 17/255,  g = 109/255, b = 168/255 },
    abyssal_beryl       = { hex = "3899C4", r = 56/255,  g = 153/255, b = 196/255 },

    hunter_green        = { hex = "354C3D", r = 53/255,  g = 76/255,  b = 61/255 },
    vinebeard_green     = { hex = "16772D", r = 22/255,  g = 119/255, b = 45/255 },
    aurora_green        = { hex = "269968", r = 38/255,  g = 153/255, b = 104/255 },

    epic_violet         = { hex = "3A1C30", r = 58/255,  g = 28/255,  b = 48/255 },
    indomitable_violet  = { hex = "594759", r = 89/255,  g = 71/255,  b = 89/255 },
    transliminal_violet = { hex = "42387C", r = 66/255,  g = 56/255,  b = 124/255 },

    coldharbour_black   = { hex = "26211E", r = 38/255,  g = 33/255,  b = 30/255 },
    legates_black       = { hex = "161919", r = 22/255,  g = 25/255,  b = 25/255 },
    void_pitch          = { hex = "000000", r = 0,       g = 0,       b = 0 },

    -- Reserved for Prestige shields. Do not use for Legacy badge progression.
    ayleid_gold         = { hex = "59421E", r = 89/255,  g = 66/255,  b = 30/255 },
    divine_gold         = { hex = "D6AF49", r = 214/255, g = 175/255, b = 73/255 },
    tower_white_gold    = { hex = "96999B", r = 150/255, g = 153/255, b = 155/255 },
    julianos_white      = { hex = "D8D8D8", r = 216/255, g = 216/255, b = 216/255 },
}

-- Legacy colour hand-off table.
-- Index 1..5 corresponds to the five visual emblem stages within a 300 CP rank.
-- These are deliberately separate from STARS' CP math: this module only translates
-- the progression state into presentation.
--
-- All twelve palettes completed their consolidated PS5 review and are now the
-- production colour hand-off for native Legacy progression.
B.LEGACY_COLOUR_STEPS = {
    wayfarer = {
        { "frozen_blood",     "craglorn_crimson" },
        { "craglorn_crimson", "jode_red" },
        { "jode_red",         "dragonstar_red" },
        { "dragonstar_red",   "bloodroot_wine" },
        { "bloodroot_wine",   "covenant_blue" }, -- crossover
    },

    pathfinder = {
        { "coldharbour_black",  "covenant_blue" },
        { "covenant_blue",      "vehks_mystic_blue" },
        { "vehks_mystic_blue",  "abyssal_beryl" },
        { "abyssal_beryl",      "covenant_blue" },
        { "abyssal_beryl",      "hunter_green" }, -- crossover
    },

    standard_bearer = {
        { "coldharbour_black", "hunter_green" },
        { "hunter_green",      "vinebeard_green" },
        { "vinebeard_green",   "aurora_green" },
        { "aurora_green",      "hunter_green" },
        { "aurora_green",      "epic_violet" }, -- crossover
    },

    vanguard = {
        { "coldharbour_black",   "epic_violet" },
        { "epic_violet",         "indomitable_violet" },
        { "indomitable_violet",  "transliminal_violet" },
        { "transliminal_violet", "epic_violet" },
        { "transliminal_violet", "legates_black" },
    },

    guardian = {
        { "legates_black",    "coldharbour_black" },
        { "coldharbour_black", "craglorn_crimson" },
        { "legates_black",    "jode_red" },
        { "coldharbour_black", "dragonstar_red" },
        { "void_pitch",       "bloodroot_wine" },
    },

    sentinel = {
        { "legates_black",      "covenant_blue" },
        { "coldharbour_black",  "vehks_mystic_blue" },
        { "covenant_blue",      "abyssal_beryl" },
        { "void_pitch",         "vehks_mystic_blue" },
        { "abyssal_beryl",      "jode_red" },
    },

    champion = {
        { "craglorn_crimson", "epic_violet" },
        { "jode_red",         "indomitable_violet" },
        { "dragonstar_red",   "transliminal_violet" },
        { "bloodroot_wine",   "epic_violet" },
        { "bloodroot_wine",   "abyssal_beryl" },
    },

    paragon = {
        { "frozen_blood",     "covenant_blue" },
        { "craglorn_crimson", "vehks_mystic_blue" },
        { "jode_red",         "abyssal_beryl" },
        { "dragonstar_red",   "covenant_blue" },
        { "bloodroot_wine",   "covenant_blue" },
    },

    exemplar = {
        { "covenant_blue",    "hunter_green" },
        { "vehks_mystic_blue", "vinebeard_green" },
        { "abyssal_beryl",    "aurora_green" },
        { "covenant_blue",    "aurora_green" },
        { "abyssal_beryl",    "transliminal_violet" },
    },

    luminary = {
        { "covenant_blue",      "epic_violet" },
        { "vehks_mystic_blue",  "indomitable_violet" },
        { "abyssal_beryl",      "transliminal_violet" },
        { "aurora_green",       "abyssal_beryl" },
        { "bloodroot_wine",     "abyssal_beryl" },
    },

    ascendant = {
        { "epic_violet",         "craglorn_crimson" },
        { "indomitable_violet",  "jode_red" },
        { "transliminal_violet", "dragonstar_red" },
        { "abyssal_beryl",       "transliminal_violet" },
        { "bloodroot_wine",      "transliminal_violet" },
    },

    venerated = {
        { "coldharbour_black", "craglorn_crimson" },
        { "legates_black",     "jode_red" },
        { "void_pitch",        "dragonstar_red" },
        { "bloodroot_wine",    "transliminal_violet" },
        { "bloodroot_wine",    "abyssal_beryl" },
    },
}

B.ASSETS = {
    legacyAtlas   = B.ASSET_PATHS.legacyAtlas,
    heraldryAtlas = B.ASSET_PATHS.heraldryAtlas,

    -- Placeholder UV contract. Real atlas coordinates will replace these.
    -- Each Legacy emblem ultimately exposes two atlas regions: A + B.
    legacy = {},

    bronzeCharges = B.ASSET_PATHS.bronzeCharges,
    silverCharges = {},
    goldCharges = {},
}

for _, key in ipairs(B.LEGACY_RANK_KEYS) do
    B.ASSETS.legacy[key] = {
        a = nil, -- { left, right, top, bottom }
        b = nil,
    }
    B.ASSETS.silverCharges[key] = "STARS/Badges/Charges/silver_" .. key .. ".dds"
    B.ASSETS.goldCharges[key]   = "STARS/Badges/Charges/gold_" .. key .. ".dds"
end

-- Production presentation contract for the three complete Prestige tiers.
-- Each tier reuses the first eleven approved Legacy identities; Venerated
-- remains the final flat Legacy emblem before Bronze begins.
B.PRESTIGE_TIER_STYLES = {
    bronze = {
        visualClass = B.PRESTIGE_CLASS.BRONZE,
        tierName = "Bronze",
        tierNumber = 1,
        shieldShape = "oblong",
        shieldField = "solid",
        shieldRim = "thick",
    },
    silver = {
        visualClass = B.PRESTIGE_CLASS.SILVER,
        tierName = "Silver",
        tierNumber = 2,
        shieldShape = "silver",
        shieldField = "silver_per_pale",
        shieldRim = "silver_ornate",
    },
    gold = {
        visualClass = B.PRESTIGE_CLASS.GOLD,
        tierName = "Gold",
        tierNumber = 3,
        shieldShape = "gold",
        shieldField = "gold_per_pale",
        shieldRim = "gold_ornate",
    },
}

--[[
DEVELOPER PRESTIGE PREVIEW INDEX (disabled; retained for future artwork review)

B.PRESTIGE_PREVIEW_STATES = {}
B.PRESTIGE_PREVIEW_BY_KEY = {}
for _, tierKey in ipairs({ "bronze", "silver", "gold" }) do
    local tier = B.PRESTIGE_TIER_STYLES[tierKey]
    for stage = 1, 11 do
        local rankKey = B.LEGACY_RANK_KEYS[stage]
        local key = tierKey .. "_" .. rankKey
        local state = {
            key = key,
            tierKey = tierKey,
            rankKey = rankKey,
            stage = stage,
            name = tier.tierName .. " " .. (B.BRONZE_PREVIEW_STATES[stage].name:gsub("^Bronze ", "")),
        }
        B.PRESTIGE_PREVIEW_STATES[#B.PRESTIGE_PREVIEW_STATES + 1] = state
        B.PRESTIGE_PREVIEW_BY_KEY[key] = state
    end
end
]]

-- Legacy atlas contract: 1024x512, arranged as 128x128 cells.
-- Each Legacy rank owns two consecutive cells: tintable layer A then layer B.
-- All twelve approved rank families are available to native progression.
local function LegacyAtlasCell(cellIndex)
    local column = cellIndex % 8
    local row = math.floor(cellIndex / 8)
    return {
        column / 8,
        (column + 1) / 8,
        row / 4,
        (row + 1) / 4,
    }
end

for rankIndex, key in ipairs(B.LEGACY_RANK_KEYS) do
    local firstCell = (rankIndex - 1) * 2
    B.ASSETS.legacy[key] = {
        a = LegacyAtlasCell(firstCell),
        b = LegacyAtlasCell(firstCell + 1),
    }
end

local function Clamp(value, low, high)
    value = tonumber(value) or low
    if value < low then return low end
    if value > high then return high end
    return value
end

local function HasValidUV(uv)
    if type(uv) ~= "table" or #uv < 4 then return false end

    local left = tonumber(uv[1])
    local right = tonumber(uv[2])
    local top = tonumber(uv[3])
    local bottom = tonumber(uv[4])
    if not left or not right or not top or not bottom then return false end

    return left >= 0 and right <= 1 and top >= 0 and bottom <= 1
        and left < right and top < bottom
end

-- Reports whether every Legacy rank has two usable atlas regions and all five
-- colour stages. This is intentionally read-only: it never enables artwork or
-- changes progression/SavedVariables. It remains a read-only integrity report
-- for the production Legacy asset contract.
function B:GetLegacyReadiness()
    local report = {
        ready = true,
        rankCount = #self.LEGACY_RANK_KEYS,
        completeRanks = 0,
        ranks = {},
        missingUVs = {},
        incompletePalettes = {},
    }

    for _, key in ipairs(self.LEGACY_RANK_KEYS) do
        local asset = self.ASSETS.legacy[key]
        local hasA = type(asset) == "table" and HasValidUV(asset.a)
        local hasB = type(asset) == "table" and HasValidUV(asset.b)
        local steps = self.LEGACY_COLOUR_STEPS[key]
        local stageCount = type(steps) == "table" and #steps or 0
        local paletteComplete = stageCount == 5

        if paletteComplete then
            for stage = 1, 5 do
                local pair = steps[stage]
                if type(pair) ~= "table" or not self.COLOURS[pair[1]] or not self.COLOURS[pair[2]] then
                    paletteComplete = false
                    break
                end
            end
        end

        local rankReady = hasA and hasB and paletteComplete
        report.ranks[key] = {
            uvA = hasA,
            uvB = hasB,
            colourStages = stageCount,
            paletteComplete = paletteComplete,
            ready = rankReady,
        }

        if not hasA or not hasB then
            report.missingUVs[#report.missingUVs + 1] = key
        end
        if not paletteComplete then
            report.incompletePalettes[#report.incompletePalettes + 1] = key
        end
        if rankReady then
            report.completeRanks = report.completeRanks + 1
        else
            report.ready = false
        end
    end

    return report
end

function B:GetPrestigeClass(progression)
    if type(progression) ~= "table" then return nil end
    if progression.phase == "legacy" then
        return self.PRESTIGE_CLASS.LEGACY
    end

    local tier = math.max(1, math.floor(tonumber(progression.tierNumber) or 1))
    if tier == 1 then return self.PRESTIGE_CLASS.BRONZE end
    if tier == 2 then return self.PRESTIGE_CLASS.SILVER end
    return self.PRESTIGE_CLASS.GOLD
end

function B:GetLegacyColours(rankKey, emblemCount)
    local steps = self.LEGACY_COLOUR_STEPS[rankKey]
    if not steps or #steps == 0 then return nil, nil, "palette_pending" end

    -- STARS currently earns visual emblems at 50/100/150/200/250.
    -- Zero therefore has no coloured badge yet. We do not silently change
    -- STARS' progression math here.
    emblemCount = math.floor(tonumber(emblemCount) or 0)
    if emblemCount <= 0 then return nil, nil, "no_emblem_yet" end

    local stage = Clamp(emblemCount, 1, #steps)
    local pair = steps[stage]
    return self.COLOURS[pair[1]], self.COLOURS[pair[2]], nil
end

function B:BuildLegacyModel(progression)
    local count = math.max(0, math.min(5, math.floor(tonumber(progression.emblemCount) or 0)))
    local a, b, reason = self:GetLegacyColours(progression.rankKey, count)

    return {
        visualClass = self.PRESTIGE_CLASS.LEGACY,
        rankKey = progression.rankKey,
        rankName = progression.rankName,
        rankLevel = tonumber(progression.level) or 0,
        emblemCount = count,
        layerAColour = a,
        layerBColour = b,
        asset = self.ASSETS.legacy[progression.rankKey],
        renderable = count > 0 and a ~= nil and b ~= nil,
        pendingReason = reason,
    }
end

--[=[
DEVELOPER MODEL BUILDERS (disabled; retained for future artwork review)

Builds display-only Legacy and Prestige models without touching live
progression or SavedVariables.

function B:BuildLegacyPreviewModel(rankKey, emblemStage)
    rankKey = tostring(rankKey or "wayfarer")
    if not self.ASSETS.legacy[rankKey] then
        return nil, "unknown_preview_rank"
    end

    local stage = math.floor(Clamp(emblemStage, 1, 5))
    local steps = self.LEGACY_COLOUR_STEPS[rankKey]
    local pair = type(steps) == "table" and steps[stage] or nil
    local a = type(pair) == "table" and self.COLOURS[pair[1]] or nil
    local b = type(pair) == "table" and self.COLOURS[pair[2]] or nil
    local asset = self.ASSETS.legacy[rankKey]

    local model = {
        visualClass = self.PRESTIGE_CLASS.LEGACY,
        rankKey = rankKey,
        rankName = rankKey,
        rankLevel = stage * 50,
        emblemCount = stage,
        layerAColour = a,
        layerBColour = b,
        asset = asset,
        renderable = asset ~= nil and a ~= nil and b ~= nil,
        pendingReason = nil,
        developmentPreview = true,
    }
    return model, nil
end

-- Builds one of the 33 Bronze/Silver/Gold review states without touching live
-- Prestige progression. The optional two-argument form accepts tier + rank;
-- the one-argument combined key remains supported by the existing test path.
function B:BuildPrestigePreviewModel(previewKey, previewRankKey)
    if previewRankKey ~= nil then
        previewKey = tostring(previewKey or "bronze") .. "_" .. tostring(previewRankKey or "wayfarer")
    else
        previewKey = tostring(previewKey or "bronze_wayfarer")
    end
    local preview = self.PRESTIGE_PREVIEW_BY_KEY[previewKey]
    if not preview then
        return nil, "unknown_prestige_preview"
    end

    local tier = self.PRESTIGE_TIER_STYLES[preview.tierKey]
    local bronzeCharge = preview.tierKey == "bronze" and self.ASSETS.bronzeCharges[preview.rankKey] or nil
    local chargeTable = preview.tierKey == "silver" and self.ASSETS.silverCharges
        or preview.tierKey == "gold" and self.ASSETS.goldCharges or nil
    local chargePath = chargeTable and chargeTable[preview.rankKey] or nil
    local model = {
        visualClass = tier.visualClass,
        tierName = tier.tierName,
        tierNumber = tier.tierNumber,
        tierLevel = (preview.stage - 1) * 10,
        totalPrestigeRanks = ((tier.tierNumber - 1) * 110) + ((preview.stage - 1) * 10),
        badgeStage = preview.stage,

        shieldShape = tier.shieldShape,
        shieldField = tier.shieldField,
        shieldRim = tier.shieldRim,
        shieldPalette = {},
        chargeKey = preview.rankKey,
        chargeAPath = bronzeCharge and bronzeCharge.a,
        chargeBPath = bronzeCharge and bronzeCharge.b,
        chargePath = chargePath,

        renderable = (bronzeCharge ~= nil and bronzeCharge.a ~= nil and bronzeCharge.b ~= nil)
            or chargePath ~= nil,
        pendingReason = nil,
        developmentPreview = true,
        prestigePreview = true,
    }
    return model, nil
end

]=]

function B:BuildPrestigeModel(progression)
    local class = self:GetPrestigeClass(progression)
    local stage = Clamp(math.floor(tonumber(progression.badgeStage) or 1), 1, 11)
    local rankKey = self.LEGACY_RANK_KEYS[stage]
    local tier = self.PRESTIGE_TIER_STYLES[class]
    local bronzeCharge = class == self.PRESTIGE_CLASS.BRONZE
        and self.ASSETS.bronzeCharges[rankKey] or nil
    local chargeTable = class == self.PRESTIGE_CLASS.SILVER and self.ASSETS.silverCharges
        or class == self.PRESTIGE_CLASS.GOLD and self.ASSETS.goldCharges or nil
    local chargePath = chargeTable and chargeTable[rankKey] or nil

    local model = {
        visualClass = class,
        tierName = progression.tierName,
        tierNumber = tonumber(progression.tierNumber) or 1,
        tierLevel = tonumber(progression.level) or 0,
        totalPrestigeRanks = tonumber(progression.totalPrestigeRanks) or 0,
        badgeStage = stage,

        shieldShape = tier and tier.shieldShape,
        shieldField = tier and tier.shieldField,
        shieldRim = tier and tier.shieldRim,
        shieldPalette = {},
        chargeKey = rankKey,
        chargeAPath = bronzeCharge and bronzeCharge.a,
        chargeBPath = bronzeCharge and bronzeCharge.b,
        chargePath = chargePath,

        renderable = tier ~= nil and (
            bronzeCharge ~= nil and bronzeCharge.a ~= nil and bronzeCharge.b ~= nil
            or chargePath ~= nil),
        pendingReason = nil,
    }

    if class == self.PRESTIGE_CLASS.BRONZE then
        model.chargeStyle = "flat"
    elseif class == self.PRESTIGE_CLASS.SILVER then
        model.chargeStyle = "decorative_gold"
    else
        model.chargeStyle = "detailed"
    end

    if not model.renderable then
        model.pendingReason = "prestige_assets_incomplete"
    end

    return model
end

function B:BuildModel(progression)
    if type(progression) ~= "table" then return nil, "missing_progression" end
    if progression.phase == "legacy" then
        return self:BuildLegacyModel(progression), nil
    end
    return self:BuildPrestigeModel(progression), nil
end

function B:GetCurrentModel()
    if type(STARS) ~= "table" or type(STARS.GetPrestigeProgression) ~= "function" then
        return nil, "stars_progression_unavailable"
    end

    local progression = STARS:GetPrestigeProgression()
    return self:BuildModel(progression)
end

function B:CanRender(model)
    if self.RENDERER_READY ~= true or type(model) ~= "table" or model.renderable ~= true then
        return false
    end

    local function IsCompleteLegacyModel(candidate)
        local asset = candidate and candidate.asset
        return type(asset) == "table"
            and HasValidUV(asset.a)
            and HasValidUV(asset.b)
            and candidate.layerAColour ~= nil
            and candidate.layerBColour ~= nil
    end

    local function IsCompletePrestigeModel(candidate)
        local knownClass = candidate.visualClass == self.PRESTIGE_CLASS.BRONZE
            or candidate.visualClass == self.PRESTIGE_CLASS.SILVER
            or candidate.visualClass == self.PRESTIGE_CLASS.GOLD
        if not knownClass then return false end
        local hasCharge
        if candidate.visualClass == self.PRESTIGE_CLASS.BRONZE then
            hasCharge = candidate.chargeAPath ~= nil and candidate.chargeBPath ~= nil
        else
            hasCharge = candidate.chargePath ~= nil
        end
        return self.ASSET_PATHS.shields[candidate.shieldShape] ~= nil
            and self.ASSET_PATHS.fields[candidate.shieldField] ~= nil
            and self.ASSET_PATHS.rims[candidate.shieldRim] ~= nil
            and hasCharge
    end

    --[[
    DEVELOPER RENDER BYPASSES (disabled; retained for future artwork review)

    -- A development preview may render one individually complete Legacy emblem
    -- while the production gate remains closed. Normal gameplay never receives
    -- a model carrying this marker.
    if self.DEVELOPMENT_PREVIEW_READY == true
        and model.developmentPreview == true
        and model.visualClass == self.PRESTIGE_CLASS.LEGACY then
        return IsCompleteLegacyModel(model)
    end

    if self.DEVELOPMENT_PRESTIGE_PREVIEW_READY == true
        and model.developmentPreview == true
        and model.prestigePreview == true then
        return IsCompletePrestigeModel(model)
    end

    -- Test-only native path: with preview disabled, let the player's genuine
    -- Legacy model reach the renderer. This proves Paragon (and any other live
    -- Legacy rank) without changing CP, progression, SavedVariables, or the
    -- production LEGACY_ASSETS_READY gate.
    if self.DEVELOPMENT_NATIVE_LEGACY_READY == true
        and model.visualClass == self.PRESTIGE_CLASS.LEGACY then
        return IsCompleteLegacyModel(model)
    end
    ]]

    if self.ASSETS_READY ~= true then return false end
    if model.visualClass == self.PRESTIGE_CLASS.LEGACY then
        return self.LEGACY_ASSETS_READY == true and IsCompleteLegacyModel(model)
    end
    return self.PRESTIGE_ASSETS_READY == true and IsCompletePrestigeModel(model)
end

local LAYERS = { "Shield", "Field", "Rim", "ChargeA", "ChargeB", "LegacyA", "LegacyB" }

local function ResolveColour(colours, value)
    if type(value) == "string" then return colours[value] end
    if type(value) == "table" then return value end
    return nil
end

local function SetLayer(view, childName, texturePath, colour, uv)
    local layer = view and view:GetNamedChild(childName)
    if not layer then return false end
    if not texturePath or texturePath == "" then
        layer:SetHidden(true)
        return false
    end

    layer:SetTexture(texturePath)
    if uv and #uv >= 4 and layer.SetTextureCoords then
        layer:SetTextureCoords(uv[1], uv[2], uv[3], uv[4])
    elseif layer.SetTextureCoords then
        layer:SetTextureCoords(0, 1, 0, 1)
    end

    colour = colour or { r = 1, g = 1, b = 1 }
    layer:SetColor(tonumber(colour.r) or 1, tonumber(colour.g) or 1, tonumber(colour.b) or 1, tonumber(colour.a) or 1)
    layer:SetHidden(false)
    return true
end

function B:Release(view)
    if not view or type(view.GetNamedChild) ~= "function" then return false end
    for _, childName in ipairs(LAYERS) do
        local layer = view:GetNamedChild(childName)
        if layer then layer:SetHidden(true) end
    end
    view:SetHidden(true)
    return true
end

function B:RenderLegacy(view, model)
    local asset = model.asset
    if not asset or not asset.a or not asset.b then return nil, "legacy_uv_pending" end

    local a = SetLayer(view, "LegacyA", self.ASSETS.legacyAtlas, model.layerAColour, asset.a)
    local b = SetLayer(view, "LegacyB", self.ASSETS.legacyAtlas, model.layerBColour, asset.b)
    if not a or not b then return nil, "legacy_layers_unavailable" end

    view:SetHidden(false)
    return view, nil
end

function B:RenderPrestige(view, model)
    local shieldPath = self.ASSET_PATHS.shields[model.shieldShape]
    local fieldPath = self.ASSET_PATHS.fields[model.shieldField]
    local rimPath = self.ASSET_PATHS.rims[model.shieldRim]
    local palette = type(model.shieldPalette) == "table" and model.shieldPalette or {}

    if not shieldPath or not fieldPath or not rimPath then return nil, "shield_rules_pending" end

    local shield = SetLayer(view, "Shield", shieldPath, ResolveColour(self.COLOURS, palette.shield))
    local field = SetLayer(view, "Field", fieldPath, ResolveColour(self.COLOURS, palette.field))
    local rim = SetLayer(view, "Rim", rimPath, ResolveColour(self.COLOURS, palette.rim))
    if not shield or not field or not rim then return nil, "shield_layers_unavailable" end

    if model.visualClass == self.PRESTIGE_CLASS.BRONZE then
        if model.chargeAPath and model.chargeBPath then
            local a = SetLayer(view, "ChargeA", model.chargeAPath, ResolveColour(self.COLOURS, palette.chargeA))
            local b = SetLayer(view, "ChargeB", model.chargeBPath, ResolveColour(self.COLOURS, palette.chargeB))
            if not a or not b then return nil, "bronze_charge_layers_unavailable" end
        else
            local charge = model.chargeKey and self.ASSETS.legacy[model.chargeKey]
            if not charge or not charge.a or not charge.b then return nil, "bronze_charge_pending" end
            local a = SetLayer(view, "ChargeA", self.ASSETS.legacyAtlas, ResolveColour(self.COLOURS, palette.chargeA), charge.a)
            local b = SetLayer(view, "ChargeB", self.ASSETS.legacyAtlas, ResolveColour(self.COLOURS, palette.chargeB), charge.b)
            if not a or not b then return nil, "bronze_charge_layers_unavailable" end
        end
    else
        local chargeTable = model.visualClass == self.PRESTIGE_CLASS.SILVER
            and self.ASSETS.silverCharges or self.ASSETS.goldCharges
        local chargePath = model.chargePath or (model.chargeKey and chargeTable[model.chargeKey])
        if not chargePath then return nil, "prestige_charge_pending" end
        local charge = SetLayer(view, "ChargeA", chargePath, ResolveColour(self.COLOURS, palette.charge))
        if not charge then return nil, "prestige_charge_layer_unavailable" end
    end

    view:SetHidden(false)
    return view, nil
end

function B:Render(view, model)
    self:Release(view)
    if not self:CanRender(model) then
        return nil, model and model.pendingReason or "assets_not_ready"
    end
    if not view or type(view.GetNamedChild) ~= "function" then return nil, "missing_view" end
    if model.visualClass == self.PRESTIGE_CLASS.LEGACY then
        return self:RenderLegacy(view, model)
    end
    return self:RenderPrestige(view, model)
end

