----------------------------------------------------------------------
-- SmartGear — Intelligent Gear Advisor for ESO
----------------------------------------------------------------------
SmartGear = SmartGear or {}
SmartGear.name = "SmartGear"
SmartGear.version = "1.1.0"
SmartGear.savedVarsVersion = 1

-- Default settings
SmartGear.defaults = {
    roleOverride = "auto",    -- "auto", "MagDD", "StamDD", "Tank", "Healer"
    pvpMode = false,
    showTooltips = true,
    showStars = true,
    showDetails = true,
    showStickerbook = true,
    showComparison = true,    -- show vs equipped comparison block
    showAlerts = true,        -- show upgrade alert notifications
    language = "auto",        -- "auto", "en", "ru"
    contentContext = "auto",  -- "auto", "solo", "dungeon", "trial", "pvp"
}

----------------------------------------------------------------------
-- Role Detection (Advanced)
-- Scoring system: each signal adds points to role candidates.
-- Signals: attributes, weapon types, armor weight, slotted skills.
----------------------------------------------------------------------

-- Skill keywords → role signals (partial match on lowercase ability name)
local SKILL_SIGNALS = {
    -- TANK signals
    { pattern = "pierce armor",         role = "Tank",   weight = 4 },
    { pattern = "puncture",             role = "Tank",   weight = 3 },
    { pattern = "heroic slash",         role = "Tank",   weight = 3 },
    { pattern = "inner fire",           role = "Tank",   weight = 3 },
    { pattern = "inner rage",           role = "Tank",   weight = 3 },
    { pattern = "silver leash",         role = "Tank",   weight = 2 },
    { pattern = "absorb missile",       role = "Tank",   weight = 3 },
    { pattern = "defensive posture",    role = "Tank",   weight = 3 },
    { pattern = "shield wall",          role = "Tank",   weight = 3 },
    { pattern = "volatile armor",       role = "Tank",   weight = 2 },
    { pattern = "hardened armor",       role = "Tank",   weight = 2 },
    { pattern = "balance",             role = "Tank",   weight = 1 },
    { pattern = "guard",               role = "Tank",   weight = 2 },
    { pattern = "frost clench",         role = "Tank",   weight = 3 },
    { pattern = "elemental blockade",   role = "Tank",   weight = 1 }, -- tanks use it too
    { pattern = "unrelenting grip",     role = "Tank",   weight = 3 },
    { pattern = "choking talons",       role = "Tank",   weight = 2 },
    { pattern = "gripping shards",      role = "Tank",   weight = 2 },
    { pattern = "beckoning armor",      role = "Tank",   weight = 3 },
    { pattern = "spell wall",           role = "Tank",   weight = 3 },
    { pattern = "turn evil",            role = "Tank",   weight = 2 },
    { pattern = "living dark",          role = "Tank",   weight = 2 },

    -- HEALER signals
    { pattern = "combat prayer",        role = "Healer", weight = 5 },
    { pattern = "illustrious healing",  role = "Healer", weight = 4 },
    { pattern = "radiating regeneration", role = "Healer", weight = 4 },
    { pattern = "healing springs",      role = "Healer", weight = 4 },
    { pattern = "rapid regeneration",   role = "Healer", weight = 3 },
    { pattern = "mutagen",             role = "Healer", weight = 3 },
    { pattern = "energy orb",           role = "Healer", weight = 4 },
    { pattern = "mystic orb",           role = "Healer", weight = 3 },
    { pattern = "overflowing altar",    role = "Healer", weight = 3 },
    { pattern = "breath of life",       role = "Healer", weight = 4 },
    { pattern = "honor the dead",       role = "Healer", weight = 3 },
    { pattern = "restoring focus",      role = "Healer", weight = 2 },
    { pattern = "channeled focus",      role = "Healer", weight = 2 },
    { pattern = "ritual of retribution", role = "Healer", weight = 3 },
    { pattern = "extended ritual",      role = "Healer", weight = 3 },
    { pattern = "blessing of protection", role = "Healer", weight = 3 },
    { pattern = "steadfast ward",       role = "Healer", weight = 3 },
    { pattern = "ward ally",            role = "Healer", weight = 3 },
    { pattern = "life giver",           role = "Healer", weight = 4 },
    { pattern = "panacea",             role = "Healer", weight = 4 },
    { pattern = "force siphon",         role = "Healer", weight = 3 },

    -- MAGICKA DD signals
    { pattern = "crystal weapon",       role = "MagDD",  weight = 2 },
    { pattern = "crystal blast",        role = "MagDD",  weight = 2 },
    { pattern = "force pulse",          role = "MagDD",  weight = 3 },
    { pattern = "crushing shock",       role = "MagDD",  weight = 3 },
    { pattern = "elemental weapon",     role = "MagDD",  weight = 3 },
    { pattern = "scalding rune",        role = "MagDD",  weight = 2 },
    { pattern = "destructive reach",    role = "MagDD",  weight = 2 },
    { pattern = "unstable wall of",     role = "MagDD",  weight = 2 },
    { pattern = "deadroth",            role = "MagDD",  weight = 2 },
    { pattern = "volatile familiar",    role = "MagDD",  weight = 2 },
    { pattern = "daedric prey",         role = "MagDD",  weight = 3 },
    { pattern = "inner light",          role = "MagDD",  weight = 2 },
    { pattern = "degeneration",         role = "MagDD",  weight = 2 },
    { pattern = "entropy",             role = "MagDD",  weight = 1 },
    { pattern = "flame reach",          role = "MagDD",  weight = 2 },

    -- STAMINA DD signals
    { pattern = "rapid strikes",        role = "StamDD", weight = 3 },
    { pattern = "bloodthirst",         role = "StamDD", weight = 3 },
    { pattern = "whirling blade",       role = "StamDD", weight = 2 },
    { pattern = "steel tornado",        role = "StamDD", weight = 2 },
    { pattern = "carve",               role = "StamDD", weight = 2 },
    { pattern = "brawler",             role = "StamDD", weight = 2 },
    { pattern = "stampede",            role = "StamDD", weight = 2 },
    { pattern = "reverse slash",        role = "StamDD", weight = 2 },
    { pattern = "executioner",         role = "StamDD", weight = 2 },
    { pattern = "wrecking blow",        role = "StamDD", weight = 2 },
    { pattern = "molten whip",          role = "StamDD", weight = 2 },
    { pattern = "dizzy swing",          role = "StamDD", weight = 2 },
    { pattern = "rending slash",        role = "StamDD", weight = 2 },
    { pattern = "blood craze",          role = "StamDD", weight = 2 },
    { pattern = "deadly cloak",         role = "StamDD", weight = 2 },
    { pattern = "arrow barrage",        role = "StamDD", weight = 2 },
    { pattern = "poison inject",        role = "StamDD", weight = 2 },
    { pattern = "endless hail",         role = "StamDD", weight = 2 },
    { pattern = "barbed trap",          role = "StamDD", weight = 2 },
    { pattern = "trap beast",           role = "StamDD", weight = 2 },
    { pattern = "camouflaged hunter",   role = "StamDD", weight = 1 },
}

function SmartGear.DetectRole()
    local settings = SmartGear.savedVars
    if settings and settings.roleOverride ~= "auto" then
        return settings.roleOverride
    end

    -- Scoring accumulators
    local scores = { MagDD = 0, StamDD = 0, Tank = 0, Healer = 0 }

    -----------------------------------------------------------
    -- Signal 1: Attributes (STRONGEST signal, max 20 points)
    -- Post-hybridization: attributes are the most reliable
    -- indicator of mag vs stam build.
    -----------------------------------------------------------
    local magPoints = GetAttributeSpentPoints(ATTRIBUTE_MAGICKA) or 0
    local stamPoints = GetAttributeSpentPoints(ATTRIBUTE_STAMINA) or 0
    local healthPoints = GetAttributeSpentPoints(ATTRIBUTE_HEALTH) or 0
    local totalAttr = magPoints + stamPoints + healthPoints

    if totalAttr > 0 then
        -- Heavy health -> tank
        if healthPoints > 30 then
            scores.Tank = scores.Tank + 15
        elseif healthPoints > 15 then
            scores.Tank = scores.Tank + 8
        end

        -- Mag vs Stam: strong signal, scales with difference
        local magStamDiff = magPoints - stamPoints
        if magStamDiff > 0 then
            local magScore = math.min(20, math.floor(magStamDiff / 2) + 5)
            scores.MagDD = scores.MagDD + magScore
            scores.Healer = scores.Healer + math.min(5, math.floor(magPoints / 15))
        elseif magStamDiff < 0 then
            local stamScore = math.min(20, math.floor(-magStamDiff / 2) + 5)
            scores.StamDD = scores.StamDD + stamScore
        end
        -- Equal or close: both get small bonus
        if math.abs(magStamDiff) <= 5 and totalAttr > 10 then
            scores.MagDD = scores.MagDD + 3
            scores.StamDD = scores.StamDD + 3
        end
    end

    -----------------------------------------------------------
    -- Signal 2: Equipped weapon types (WEAK signal, max 5)
    -- Post-hybridization: melee weapons used by both mag and
    -- stam builds. Only staves and healing staff are strong.
    -- Daggers/swords are NEUTRAL (used by mag DDs too).
    -----------------------------------------------------------
    local function checkWeapon(slot)
        local weaponType = GetItemWeaponType(BAG_WORN, slot)
        if not weaponType then return end

        if weaponType == WEAPONTYPE_FIRE_STAFF then
            scores.MagDD = scores.MagDD + 2
        elseif weaponType == WEAPONTYPE_LIGHTNING_STAFF then
            scores.MagDD = scores.MagDD + 2
            scores.Healer = scores.Healer + 1
        elseif weaponType == WEAPONTYPE_FROST_STAFF then
            scores.Tank = scores.Tank + 3
            scores.Healer = scores.Healer + 1
        elseif weaponType == WEAPONTYPE_HEALING_STAFF then
            scores.Healer = scores.Healer + 5
        -- Melee: NEUTRAL post-hybrid (mag DDs use daggers/swords)
        elseif weaponType == WEAPONTYPE_TWO_HANDED_SWORD or
               weaponType == WEAPONTYPE_TWO_HANDED_AXE or
               weaponType == WEAPONTYPE_TWO_HANDED_HAMMER then
            scores.StamDD = scores.StamDD + 1
        elseif weaponType == WEAPONTYPE_BOW then
            scores.StamDD = scores.StamDD + 2
        elseif weaponType == WEAPONTYPE_SHIELD then
            scores.Tank = scores.Tank + 5
        end
        -- Daggers, 1H sword/axe/hammer: +0 (neutral, used by all DDs)
    end

    -- Check both bars
    checkWeapon(EQUIP_SLOT_MAIN_HAND)
    checkWeapon(EQUIP_SLOT_OFF_HAND)
    checkWeapon(EQUIP_SLOT_BACKUP_MAIN)
    checkWeapon(EQUIP_SLOT_BACKUP_OFF)

    -----------------------------------------------------------
    -- Signal 3: Equipped armor weight (max 6 points)
    -----------------------------------------------------------
    local lightCount = 0
    local mediumCount = 0
    local heavyCount = 0
    local armorSlots = {
        EQUIP_SLOT_HEAD, EQUIP_SLOT_CHEST, EQUIP_SLOT_SHOULDERS,
        EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS, EQUIP_SLOT_FEET, EQUIP_SLOT_HAND,
    }
    for _, slot in ipairs(armorSlots) do
        local armorType = GetItemArmorType(BAG_WORN, slot)
        if armorType == ARMORTYPE_LIGHT then
            lightCount = lightCount + 1
        elseif armorType == ARMORTYPE_MEDIUM then
            mediumCount = mediumCount + 1
        elseif armorType == ARMORTYPE_HEAVY then
            heavyCount = heavyCount + 1
        end
    end

    if lightCount >= 5 then
        scores.MagDD = scores.MagDD + 4
        scores.Healer = scores.Healer + 3
    elseif mediumCount >= 5 then
        scores.StamDD = scores.StamDD + 5
    elseif heavyCount >= 5 then
        scores.Tank = scores.Tank + 6
    end

    -----------------------------------------------------------
    -- Signal 4: Slotted skills (most powerful signal, max ~30)
    -----------------------------------------------------------
    for hotbar = 0, 1 do
        for slot = 3, 8 do  -- slots 3-7 = skills, 8 = ultimate
            local abilityId = GetSlotBoundId(slot, hotbar)
            if abilityId and abilityId > 0 then
                local name = GetAbilityName(abilityId)
                if name then
                    local lowerName = string.lower(name)
                    for _, signal in ipairs(SKILL_SIGNALS) do
                        if string.find(lowerName, signal.pattern, 1, true) then
                            scores[signal.role] = scores[signal.role] + signal.weight
                        end
                    end
                end
            end
        end
    end

    -----------------------------------------------------------
    -- Signal 5: Class identity (small bonus, max 2)
    -----------------------------------------------------------
    local classId = GetUnitClassId("player")
    -- Nightblades & Arcanists are more often DPS
    -- Templars & Wardens often heal
    -- DKs often tank
    -- These are TINY signals, just tiebreakers
    if classId == 1 then      -- Dragonknight
        scores.Tank = scores.Tank + 1
    elseif classId == 2 then  -- Sorcerer
        scores.MagDD = scores.MagDD + 1
    elseif classId == 3 then  -- Nightblade
        scores.StamDD = scores.StamDD + 1
    elseif classId == 4 then  -- Warden
        scores.Healer = scores.Healer + 1
    elseif classId == 5 then  -- Necromancer
        -- versatile, no bonus
    elseif classId == 6 then  -- Templar
        scores.Healer = scores.Healer + 1
    elseif classId == 117 then -- Arcanist
        scores.MagDD = scores.MagDD + 1
    end

    -----------------------------------------------------------
    -- Pick winner
    -----------------------------------------------------------
    local bestRole = "MagDD"
    local bestScore = 0
    for role, score in pairs(scores) do
        if score > bestScore then
            bestScore = score
            bestRole = role
        end
    end

    -- Store debug info for /smartgear role
    SmartGear.lastDetection = {
        scores = scores,
        winner = bestRole,
        winnerScore = bestScore,
        lightArmor = lightCount,
        mediumArmor = mediumCount,
        heavyArmor = heavyCount,
        magAttr = magPoints,
        stamAttr = stamPoints,
        healthAttr = healthPoints,
    }

    return bestRole
end

----------------------------------------------------------------------
-- Initialization
----------------------------------------------------------------------
local function OnAddonLoaded(event, addonName)
    if addonName ~= SmartGear.name then return end

    -- Load saved variables
    SmartGear.savedVars = ZO_SavedVars:NewAccountWide(
        "SmartGearSavedVars",
        SmartGear.savedVarsVersion,
        nil,
        SmartGear.defaults
    )

    -- Detect language
    local lang = SmartGear.savedVars.language
    if lang == "auto" then
        local clientLang = GetCVar("language.2")
        if clientLang == "ru" then
            SmartGear.currentLang = "ru"
        else
            SmartGear.currentLang = "en"
        end
    else
        SmartGear.currentLang = lang
    end

    -- Detect role on load
    SmartGear.currentRole = SmartGear.DetectRole()

    -- Initialize subsystems
    SmartGear.InitPlayerProfile()
    if SmartGear.PatchSetStatMap then SmartGear.PatchSetStatMap() end
    SmartGear.InitTooltipHooks()
    SmartGear.InitUpgradeAlerts()
    SmartGear.InitSettings()

    -- Re-detect role when skills change
    EVENT_MANAGER:RegisterForEvent(SmartGear.name, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, function()
        SmartGear.currentRole = SmartGear.DetectRole()
    end)

    -- Re-detect role when attributes change
    EVENT_MANAGER:RegisterForEvent(SmartGear.name, EVENT_ATTRIBUTE_FORCE_RESPEC, function()
        SmartGear.currentRole = SmartGear.DetectRole()
    end)

    -- Re-detect when gear changes (weapon swap, equip new item)
    EVENT_MANAGER:RegisterForEvent(SmartGear.name .. "Gear", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId)
        if bagId == BAG_WORN then
            SmartGear.currentRole = SmartGear.DetectRole()
        end
    end)

    EVENT_MANAGER:UnregisterForEvent(SmartGear.name, EVENT_ADD_ON_LOADED)

    d("|c00FF00[SmartGear]|r v" .. SmartGear.version .. " loaded. Role: |cFFFF00" .. SmartGear.GetRoleDisplayName(SmartGear.currentRole) .. "|r")
end

EVENT_MANAGER:RegisterForEvent(SmartGear.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

----------------------------------------------------------------------
-- Slash commands
----------------------------------------------------------------------
SLASH_COMMANDS["/smartgear"] = function(args)
    if args == "role" then
        SmartGear.currentRole = SmartGear.DetectRole()
        local det = SmartGear.lastDetection
        d("|c00FF00[SmartGear]|r Role detection results:")
        d("  Winner: |cFFFF00" .. SmartGear.GetRoleDisplayName(SmartGear.currentRole) .. "|r")
        if det then
            d("  Scores: " ..
                "|c00DDFFMagDD|r=" .. det.scores.MagDD ..
                "  |c00DDFFStamDD|r=" .. det.scores.StamDD ..
                "  |c00DDFFTank|r=" .. det.scores.Tank ..
                "  |c00DDFFHealer|r=" .. det.scores.Healer)
            d("  Attributes: Mag=" .. det.magAttr .. " Stam=" .. det.stamAttr .. " HP=" .. det.healthAttr)
            d("  Armor: Light=" .. det.lightArmor .. " Medium=" .. det.mediumArmor .. " Heavy=" .. det.heavyArmor)
        end
    elseif args == "refresh" then
        SmartGear.currentRole = SmartGear.DetectRole()
        d("|c00FF00[SmartGear]|r Data refreshed. Role: |cFFFF00" .. SmartGear.GetRoleDisplayName(SmartGear.currentRole) .. "|r")
    elseif args == "scan" then
        SmartGear.ScanUpgrades()
    elseif args == "swap" then
        local swaps = SmartGear.CheckAllBarsWeaponSwap()
        if swaps and #swaps > 0 then
            for _, s in ipairs(swaps) do
                local barName = s.bar == 2 and "Bar 2" or "Bar 1"
                local mainName = zo_strformat("<<1>>", GetItemLinkName(s.mainLink))
                local offName  = zo_strformat("<<1>>", GetItemLinkName(s.offLink))
                d("|c00FF00[SmartGear]|r " .. barName .. ": " .. mainName .. " <-> " .. offName .. " (+" .. s.scoreBenefit .. ")")
            end
            SmartGear.ShowSwapAlert(swaps[1])
        else
            local lang = SmartGear.currentLang or "en"
            d("|c00FF00[SmartGear]|r " .. (lang == "ru"
                and "Оружие размещено оптимально."
                or  "Weapons are optimally placed."))
        end
    elseif args == "debug" then
        -- Debug: show loaded data summary
        local totalSets = 0
        local tierCount = { S = 0, A = 0, B = 0, C = 0 }
        local withStats = 0
        if SmartGear.MetaSets then
            for name, data in pairs(SmartGear.MetaSets) do
                totalSets = totalSets + 1
                local t = data.tier or "?"
                if tierCount[t] then tierCount[t] = tierCount[t] + 1 end
                if data.statContributions then withStats = withStats + 1 end
            end
        end
        d("|c00FF00[SmartGear]|r Debug info:")
        d("  MetaSets loaded: |cFFFFFF" .. totalSets .. "|r")
        d("  Tiers: S=" .. tierCount.S .. " A=" .. tierCount.A .. " B=" .. tierCount.B .. " C=" .. tierCount.C)
        d("  With statContributions: |cFFFFFF" .. withStats .. "|r")
        d("  StatTargets: |cFFFFFF" .. (SmartGear.StatTargets and "OK" or "MISSING") .. "|r")
        d("  TraitStatMap: |cFFFFFF" .. (SmartGear.TraitStatMap and "OK" or "MISSING") .. "|r")
        d("  PlayerProfile: |cFFFFFF" .. (SmartGear.PlayerProfile and "OK" or "MISSING") .. "|r")
        d("  ContentContexts: |cFFFFFF" .. (SmartGear.ContentContexts and "OK" or "MISSING") .. "|r")
        local ctx = SmartGear.GetContentContext and SmartGear.GetContentContext() or "?"
        d("  Active context: |c00DDFF" .. ctx .. "|r")
        d("  Role: |cFFFF00" .. (SmartGear.currentRole or "?") .. "|r")
        -- Show a few sample sets
        if SmartGear.MetaSets then
            d("  Sample S-tier sets:")
            local shown = 0
            for name, data in pairs(SmartGear.MetaSets) do
                if data.tier == "S" and shown < 5 then
                    local roles = table.concat(data.roles or {}, ",")
                    local sc = data.statContributions and "YES" or "no"
                    d("    |cFFFF00" .. name .. "|r [" .. roles .. "] stats=" .. sc)
                    shown = shown + 1
                end
            end
        end
    elseif args == "buffs" then
        -- Debug: dump all active buffs to chat
        local numBuffs = GetNumBuffs("player") or 0
        d("|c00FF00[SmartGear]|r Active buffs (" .. numBuffs .. "):")
        for i = 1, numBuffs do
            local buffName, timeStarted, timeEnding, buffSlot, stackCount,
                  iconFilename, buffType, effectType, abilityType,
                  statusEffectType, abilityId, canClickOff = GetUnitBuffInfo("player", i)
            if buffName and buffName ~= "" then
                d(string.format("  [%d] id=%s name=|cFFFF00%s|r icon=%s",
                    i, tostring(abilityId), buffName, tostring(iconFilename)))
            end
        end
    elseif args == "stats" then
        SmartGear.RefreshPlayerProfile()
        local p = SmartGear.PlayerProfile
        local role = SmartGear.currentRole or "MagDD"
        local lang = SmartGear.currentLang or "en"
        local gaps = SmartGear.ComputeStatGaps(role)
        local context = SmartGear.GetContentContext()
        local ctxInfo = SmartGear.ContentContexts and SmartGear.ContentContexts[context]
        local ctxName = ctxInfo and (lang == "ru" and ctxInfo.nameRu or ctxInfo.name) or context

        d("|c00FF00[SmartGear]|r " .. SmartGear.GetRoleDisplayName(role) .. " / |c00DDFF" .. ctxName .. "|r:")

        local effectiveWSD = math.max(p.weaponSpellDmg, math.max(p.weaponDamage, p.spellDamage))
        local targets = SmartGear.StatTargets and SmartGear.StatTargets[role] or {}

        local function fmtStat(label, current, target, gapKey)
            local gapVal = gaps[gapKey] or 0
            local gapText = ""
            if gapVal <= 0 then
                gapText = "|c00FF00CAPPED|r"
            else
                gapText = string.format("gap: |cFFFF00%.2f|r", gapVal)
            end
            d(string.format("  %s: |cFFFFFF%d|r / %d (%s)", label, current, target or 0, gapText))
        end

        fmtStat("WSD", effectiveWSD, targets.weaponDamage, "weaponDamage")
        fmtStat("Crit", math.floor(p.effectiveCrit), targets.critPercent, "critPercent")
        fmtStat("Pen", p.effectivePen, targets.penetration, "penetration")

        if role == "MagDD" or role == "Healer" then
            fmtStat("Max Magicka", p.maxMagicka, targets.maxResource, "maxResource")
        elseif role == "StamDD" then
            fmtStat("Max Stamina", p.maxStamina, targets.maxResource, "maxResource")
        else
            fmtStat("Max Health", p.maxHealth, targets.maxHealth, "maxHealth")
            fmtStat("Resist", p.effectiveResist, targets.resistance, "resistance")
        end

        -- Mundus
        local mName = lang == "ru" and (p.mundusNameRu or p.mundusName) or p.mundusName
        if mName and mName ~= "" then
            d("  Mundus: |c00DDFF" .. mName .. "|r (" .. (p.mundusStat or "?") .. ")")
        else
            d("  Mundus: |cFF0000" .. (lang == "ru" and "Не обнаружен" or "Not detected") .. "|r")
        end

        -- Race
        local rName = lang == "ru" and (p.raceNameRu or p.raceName) or p.raceName
        d("  Race: |cFFFF00" .. (rName or "?") .. "|r")

    else
        -- Open settings panel
        if SmartGear.OpenSettings then
            SmartGear.OpenSettings()
        else
            d("|c00FF00[SmartGear]|r Commands: /smartgear role | refresh | scan | swap | stats")
        end
    end
end

----------------------------------------------------------------------
-- Utility
----------------------------------------------------------------------
function SmartGear.GetString(key)
    local strings = SmartGear.Strings[SmartGear.currentLang] or SmartGear.Strings["en"]
    return strings[key] or key
end

function SmartGear.GetRoleDisplayName(role)
    local names = {
        MagDD = "Magicka DD",
        StamDD = "Stamina DD",
        Tank = "Tank",
        Healer = "Healer",
    }
    return names[role] or role
end
