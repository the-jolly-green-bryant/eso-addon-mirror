local ADDON_NAME = "ConsoleMetrics"

local ConsoleMetrics = {
    name = ADDON_NAME,
    version = "0.1.0",
    defaults = {
        x = 220,
        y = 180,
        scale = 1,
        locked = false,
        showOutOfCombat = true,
        scrollSize = 8,
        autoClearOnNextFight = true,
        maxFightHistory = 25,
        uiPanelEnabled = false,
        dialogAutoHide = true,
        dialogAutoHideSeconds = 12,
        drSampleAlpha = 0.35,
        customSetRules = {},
        customSetDraftLabel = "",
        customSetDraftScene = "PvP",
        customSetDraftAbilityId = "",
        customSetDraftAbilityName = "",
        saveFightDraftName = "",
        loadFightDraftName = "",
        savedFights = {},
        maxSavedFights = 10,
    },
    ui = {},
    scrollEntries = {},
    inCombat = false,
    hideAtMs = nil,
    dialogAutoHideAtMs = nil,
    dialogRefreshAtMs = nil,
    lastDebugPrintAtMs = nil,
    fight = nil,
    fightHistory = {},
    viewFightIndex = 0,
    dialogPanel = "main",
}

local POST_COMBAT_VISIBLE_MS = 10000
local DIALOG_LIVE_REFRESH_MS = 500
local RESISTANCE_CAP = 33000
local RESISTANCE_SCALE = 66000
local TOP_MOMENTS_LIMIT = 30
local MAJOR_PROTECTION_DR_PCT = 10
local MINOR_PROTECTION_DR_PCT = 5
local EFFECTS_PANEL_LIMIT = 30
local RESOURCE_SAMPLE_INTERVAL_MS = 1000
local PING_DIP_DELTA_MS = 25
local PING_SPIKE_DELTA_MS = 40
local PING_HIGH_DELAY_MS = 140

-- Lazily resolved at first sample so all game constants are guaranteed bound.
-- Console uses COMBAT_MECHANIC_FLAGS_* (health=1, magicka=2, stamina=4).
local RESOURCE_POWER_TYPES_CACHE = nil

local function GetResourcePowerTypes()
    if RESOURCE_POWER_TYPES_CACHE then
        return RESOURCE_POWER_TYPES_CACHE
    end

    local g = type(_G) == "table" and _G or nil

    local function Resolve(consoleKey, consoleDefault)
        local consVal = g and tonumber(g[consoleKey]) or nil
        if consVal then
            return { consVal }
        end
        -- Hardcoded console fallback in case the constant resolves late.
        return { consoleDefault }
    end

    RESOURCE_POWER_TYPES_CACHE = {
        health   = Resolve("COMBAT_MECHANIC_FLAGS_HEALTH",   1),
        magicka  = Resolve("COMBAT_MECHANIC_FLAGS_MAGICKA",  2),
        stamina  = Resolve("COMBAT_MECHANIC_FLAGS_STAMINA",  4),
        ultimate = Resolve("COMBAT_MECHANIC_FLAGS_ULTIMATE", 8),
    }

    return RESOURCE_POWER_TYPES_CACHE
end

local ROLE_COMPARISON_PROFILES = {
    dps = {
        label = "DPS",
        health = { 18000, 36000 },
        primary = { 28000, 42000 },
        secondary = { 12000, 24000 },
        crit = { 55, 70 },
        healthNote = "Above range is usually too defensive for a standard DPS profile.",
        primaryNote = "Above range can indicate overinvestment versus damage/crit/pen.",
        secondaryNote = "Very high secondary pools often have weak marginal return for DPS.",
        critNote = "Above this, crit damage/pen or raw power may be better value.",
    },
    healer = {
        label = "Healer",
        health = { 22000, 40000 },
        primary = { 30000, 50000 },
        secondary = { 12000, 28000 },
        crit = { 35, 60 },
        healthNote = "Too much health can reduce healing throughput or sustain efficiency.",
        primaryNote = "Primary pool is typically Magicka for healer throughput and sustain.",
        secondaryNote = "Secondary pool supports utility, blocking, and break free management.",
        critNote = "Healer crit goals vary by set and content; treat this as a practical band.",
    },
    tank = {
        label = "Tank",
        health = { 32000, 55000 },
        primary = { 22000, 38000 },
        secondary = { 16000, 32000 },
        crit = { 10, 35 },
        healthNote = "High health is expected, but extreme values can overtrade group utility.",
        primaryNote = "Primary pool should support taunt uptime, blocking, and core skill loops.",
        secondaryNote = "Secondary pool helps with swap pressure and emergency sustain windows.",
        critNote = "Tank crit is usually lower priority than resist, sustain, and utility.",
    },
}

local function MapRoleValueToProfileKey(roleValue)
    if type(roleValue) == "string" then
        local lower = string.lower(roleValue)
        if string.find(lower, "tank", 1, true) ~= nil then
            return "tank"
        end
        if string.find(lower, "heal", 1, true) ~= nil then
            return "healer"
        end
        if string.find(lower, "dps", 1, true) ~= nil or string.find(lower, "damage", 1, true) ~= nil then
            return "dps"
        end
        return nil
    end

    if type(roleValue) ~= "number" then
        return nil
    end

    if type(LFG_ROLE_TANK) == "number" and roleValue == LFG_ROLE_TANK then
        return "tank"
    end
    if type(LFG_ROLE_HEAL) == "number" and roleValue == LFG_ROLE_HEAL then
        return "healer"
    end
    if type(LFG_ROLE_DPS) == "number" and roleValue == LFG_ROLE_DPS then
        return "dps"
    end

    if roleValue == 1 then
        return "tank"
    end
    if roleValue == 2 then
        return "healer"
    end
    if roleValue == 3 then
        return "dps"
    end

    return nil
end

local function GetSelectedRoleComparisonProfile()
    local probes = {
        {
            source = "group selected role",
            getValue = function()
                if type(GetGroupMemberSelectedRole) == "function" then
                    return GetGroupMemberSelectedRole("player")
                end
                return nil
            end,
        },
        {
            source = "LFG selected role",
            getValue = function()
                if type(GetSelectedLFGRole) == "function" then
                    return GetSelectedLFGRole()
                end
                return nil
            end,
        },
        {
            source = "unit group role",
            getValue = function()
                if type(GetUnitGroupRole) == "function" then
                    return GetUnitGroupRole("player")
                end
                return nil
            end,
        },
    }

    for i = 1, #probes do
        local roleValue = probes[i].getValue()
        local roleKey = MapRoleValueToProfileKey(roleValue)
        if roleKey and ROLE_COMPARISON_PROFILES[roleKey] then
            return roleKey, ROLE_COMPARISON_PROFILES[roleKey], string.format("Using %s.", probes[i].source)
        end
    end

    return "dps", ROLE_COMPARISON_PROFILES.dps, "Selected role unavailable; using DPS defaults."
end

local function ColorFromHex(hex)
    local clean = (hex or "FFFFFF"):gsub("#", "")
    local r = tonumber(clean:sub(1, 2), 16) or 255
    local g = tonumber(clean:sub(3, 4), 16) or 255
    local b = tonumber(clean:sub(5, 6), 16) or 255
    return { r / 255, g / 255, b / 255 }
end

local function SafeAbilityId(abilityId)
    return math.floor(tonumber(abilityId) or 0)
end

local function FormatAbilityIdentity(abilityName, abilityId)
    return string.format("%s [id:%d]", abilityName or "Unknown", SafeAbilityId(abilityId))
end

local COMBAT_TEXT_COLORS = {
    start = ColorFromHex("#FF7314"),
    summary = ColorFromHex("#FFB04D"),
    damage = ColorFromHex("#FF7D29"),
    damageCrit = ColorFromHex("#FFCC61"),
    heal = ColorFromHex("#3DE378"),
    healCrit = ColorFromHex("#73FF8C"),
    taken = ColorFromHex("#FF4242"),
}

-- Hex strings (no# prefix) for |cHHHHHH...|r ESO color markup in panel labels.
local COMBAT_COLOR_HEX = {
    start      = "FF7314",  -- amber: combat start
    summary    = "FFB04D",  -- gold: summaries
    damage     = "FF7D29",  -- orange: direct damage
    damageCrit = "FFCC61",  -- yellow: critical damage
    dot        = "FF982A",  -- deep orange: damage-over-time ticks
    heal       = "3DE378",  -- green: direct healing
    healCrit   = "73FF8C",  -- bright green: critical healing
    hot        = "52EAA8",  -- teal: heal-over-time ticks
    taken      = "FF4242",  -- red: incoming damage
    shield     = "7BB2FF",  -- blue: absorb/shield
    overflow   = "FF6060",  -- light red: overflow damage/heal
    mitigation = "A0C8FF",  -- sky blue: blocked/shielded mitigation
}

local METRIC_ROW_COLORS = {
    dps = COMBAT_TEXT_COLORS.damage,
    hps = COMBAT_TEXT_COLORS.heal,
    damage = COMBAT_TEXT_COLORS.damage,
    heal = COMBAT_TEXT_COLORS.heal,
    taken = COMBAT_TEXT_COLORS.taken,
    crit = COMBAT_TEXT_COLORS.damageCrit,
}

-- Curated set aliases used to classify common PvE/PvP proc names in combat events.
local POPULAR_SET_CATALOG = {
    { label = "Pillar of Nirn", scene = "PvE", aliases = { "pillar of nirn", "nirn" } },
    { label = "Whorl of the Depths", scene = "PvE", aliases = { "whorl of the depths", "whorl" } },
    { label = "Arms of Relequen", scene = "PvE", aliases = { "arms of relequen", "relequen" } },
    { label = "Aegis Caller", scene = "PvE", aliases = { "aegis caller", "aegis" } },
    { label = "Mantle of Siroria", scene = "PvE", aliases = { "mantle of siroria", "siroria" } },
    { label = "Zaan", scene = "PvE", aliases = { "zaan" } },
    { label = "Coral Riptide", scene = "PvE", aliases = { "coral riptide", "riptide" } },
    { label = "Kinras's Wrath", scene = "PvE", aliases = { "kinras", "kinras's wrath" } },
    { label = "Bahsei's Mania", scene = "PvE", aliases = { "bahsei", "bahsei's mania" } },
    { label = "Azureblight Reaper", scene = "PvE", aliases = { "azureblight", "azureblight reaper" } },
    { label = "Rallying Cry", scene = "PvP", aliases = { "rallying cry", "rallying" } },
    { label = "Mara's Balm", scene = "PvP", aliases = { "mara's balm", "maras balm" } },
    { label = "Daedric Trickery", scene = "PvP", aliases = { "daedric trickery", "trickery" } },
    { label = "Plaguebreak", scene = "PvP", aliases = { "plaguebreak" } },
    { label = "Vicious Death", scene = "PvP", aliases = { "vicious death" } },
    { label = "Dark Convergence", scene = "PvP", aliases = { "dark convergence", "convergence" } },
    { label = "Wretched Vitality", scene = "PvP", aliases = { "wretched vitality", "wretched" } },
    { label = "Mark of the Pariah", scene = "PvP", aliases = { "pariah", "mark of the pariah" } },
    { label = "Hrothgar's Chill", scene = "PvP", aliases = { "hrothgar", "hrothgar's chill" } },
    { label = "Balorgh", scene = "PvP", aliases = { "balorgh" } },
}

-- Heuristic keywords to surface likely set procs beyond the curated catalog.
local LIKELY_SET_PROC_KEYWORDS = {
    "set",
    "proc",
    "nirn",
    "relequen",
    "siroria",
    "balorgh",
    "pariah",
    "hrothgar",
    "trickery",
    "vitality",
    "convergence",
    "plague",
    "semblance",
    "opportunist",
    "slayer",
    "whisper",
    "ward",
}

local function NumberText(value)
    return ZO_CommaDelimitNumber(math.floor(value + 0.5))
end

local function ShortNumber(value)
    if value >= 1000000 then
        return string.format("%.2fm", value / 1000000)
    end
    if value >= 1000 then
        return string.format("%.1fk", value / 1000)
    end
    return tostring(math.floor(value + 0.5))
end

-- Wrap a formatted number in ESO color markup: |cHHHHHH<number>|r
local function ColorNum(value, colorHex)
    return string.format("|c%s%s|r", colorHex or "FFFFFF", NumberText(value))
end

local function ColorShort(value, colorHex)
    return string.format("|c%s%s|r", colorHex or "FFFFFF", ShortNumber(value))
end

local function ColorText(text, colorHex)
    return string.format("|c%s%s|r", colorHex or "FFFFFF", tostring(text or ""))
end

local function TrimText(text)
    local value = tostring(text or "")
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    return value
end

local function BuildDefaultFightSaveName(snapshot, slotIndex)
    local topTarget = snapshot and snapshot.targetList and snapshot.targetList[1] or nil
    local targetTag = topTarget and topTarget.name and topTarget.name ~= "" and (" vs " .. topTarget.name) or ""
    return string.format("Slot %d: %.1fs / %s DPS%s", slotIndex or 1, snapshot and snapshot.duration or 0, ShortNumber((snapshot and snapshot.dps) or 0), targetTag)
end

local function GetActionBarSlotBounds()
    -- Console client confirmed layout: skills occupy slots 3-7 and ultimate is slot 8.
    return 3, 8
end

local function SafeGetActionBarSlotName(slotIndex, hotbarCategory)
    local slotName = nil
    if type(GetSlotName) == "function" then
        local ok = pcall(function()
            if hotbarCategory ~= nil then
                slotName = GetSlotName(slotIndex, hotbarCategory)
            else
                slotName = GetSlotName(slotIndex)
            end
        end)
        if ok and type(slotName) == "string" and slotName ~= "" then
            -- Filter out non-skill action slots using pattern matching
            local lowerName = string.lower(slotName)
            if string.match(lowerName, "heavy%s*attack")
            or string.match(lowerName, "light%s*attack")
            or string.match(lowerName, "^dodge")
            or lowerName == "block"
            or lowerName == "bash" then
                return nil, nil
            end
            return slotName
        end
    end

    if type(GetSlotBoundId) == "function" and type(GetAbilityName) == "function" then
        local abilityId = nil
        local ok = pcall(function()
            if hotbarCategory ~= nil then
                abilityId = GetSlotBoundId(slotIndex, hotbarCategory)
            else
                abilityId = GetSlotBoundId(slotIndex)
            end
        end)
        if ok and type(abilityId) == "number" and abilityId > 0 then
            local okName, abilityName = pcall(GetAbilityName, abilityId)
            if okName and type(abilityName) == "string" and abilityName ~= "" then
                return abilityName, abilityId
            end
            return string.format("Ability %d", abilityId), abilityId
        end
    end

    return nil, nil
end

local function BuildActionBarSnapshot(hotbarCategory)
    local entries = {}
    local firstSlot, ultimateSlot = GetActionBarSlotBounds()
    local skillCount = 0
    for slotIndex = firstSlot, ultimateSlot do
        local abilityName, abilityId = SafeGetActionBarSlotName(slotIndex, hotbarCategory)
        if abilityName then  -- Skip filtered slots (Heavy Attack, Dodge)
            local slotLabel = slotIndex == ultimateSlot and "Ultimate" or string.format("Skill %d", skillCount + 1)
            entries[#entries + 1] = {
                slotLabel = slotLabel,
                abilityName = abilityName or "Empty",
                abilityId = abilityId or 0,
            }
            if slotIndex ~= ultimateSlot then
                skillCount = skillCount + 1
            end
        end
    end
    return entries
end

local function BuildEquipmentSlotDefinitions()
    local slots = {}
    local function Add(label, slotValue)
        if type(slotValue) == "number" then
            slots[#slots + 1] = { label = label, slot = slotValue }
        end
    end

    Add("Head", EQUIP_SLOT_HEAD)
    Add("Shoulders", EQUIP_SLOT_SHOULDERS)
    Add("Chest", EQUIP_SLOT_CHEST)
    Add("Hands", EQUIP_SLOT_HAND)
    Add("Waist", EQUIP_SLOT_WAIST)
    Add("Legs", EQUIP_SLOT_LEGS)
    Add("Feet", EQUIP_SLOT_FEET)
    Add("Neck", EQUIP_SLOT_NECK)
    Add("Ring 1", EQUIP_SLOT_RING1)
    Add("Ring 2", EQUIP_SLOT_RING2)
    Add("Main Hand", EQUIP_SLOT_MAIN_HAND)
    Add("Off Hand", EQUIP_SLOT_OFF_HAND)
    Add("Backup Main", EQUIP_SLOT_BACKUP_MAIN)
    Add("Backup Off", EQUIP_SLOT_BACKUP_OFF)

    return slots
end

local function SafeGetEquippedItemText(slotIndex)
    if type(BAG_WORN) ~= "number" then
        return "Unavailable"
    end

    local itemLink = nil
    local itemName = nil
    if type(GetItemLink) == "function" then
        local ok = pcall(function()
            local linkStyle = type(LINK_STYLE_BRACKETS) == "number" and LINK_STYLE_BRACKETS or LINK_STYLE_DEFAULT
            itemLink = GetItemLink(BAG_WORN, slotIndex, linkStyle)
        end)
        if not ok then
            itemLink = nil
        end
    end
    if type(GetItemName) == "function" then
        local ok = pcall(function()
            itemName = GetItemName(BAG_WORN, slotIndex)
        end)
        if not ok then
            itemName = nil
        end
    end

    if type(itemLink) == "string" and itemLink ~= "" and itemLink ~= "|H0:item:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h" then
        return itemLink
    end
    if type(itemName) == "string" and itemName ~= "" then
        return itemName
    end
    return "Empty"
end

local function BuildEquipmentSnapshot()
    local entries = {}
    local slots = BuildEquipmentSlotDefinitions()
    for i = 1, #slots do
        entries[#entries + 1] = {
            label = slots[i].label,
            text = SafeGetEquippedItemText(slots[i].slot),
        }
    end
    return entries
end

local function BuildActiveBoonSnapshot()
    local boons = {}
    if type(GetNumBuffs) ~= "function" or type(GetUnitBuffInfo) ~= "function" then
        return boons
    end

    local ok, buffCount = pcall(GetNumBuffs, "player")
    if not ok or type(buffCount) ~= "number" then
        return boons
    end

    for buffIndex = 1, buffCount do
        local buffName = nil
        local okBuff = pcall(function()
            buffName = GetUnitBuffInfo("player", buffIndex)
        end)
        if okBuff and type(buffName) == "string" and buffName ~= "" then
            local lowerName = string.lower(buffName)
            if string.find(lowerName, "boon", 1, true) ~= nil or string.find(lowerName, "mundus", 1, true) ~= nil then
                boons[#boons + 1] = buffName
            end
        end
    end

    return boons
end

local function SafeCallResults(func, ...)
    if type(func) ~= "function" then
        return nil
    end

    local results = nil
    local ok = pcall(function(...)
        results = { func(...) }
    end, ...)

    if not ok then
        return nil
    end

    return results
end

local function FindFirstNonEmptyString(results, skipValues)
    if type(results) ~= "table" then
        return nil
    end

    for i = 1, #results do
        local value = results[i]
        if type(value) == "string" and value ~= "" then
            if not skipValues or not skipValues[value] then
                return value
            end
        end
    end

    return nil
end

local function BuildEquippedSetSummary()
    local results = {}
    local seen = {}
    local slots = BuildEquipmentSlotDefinitions()

    if type(GetItemLink) ~= "function" or type(GetItemLinkSetInfo) ~= "function" or type(BAG_WORN) ~= "number" then
        return results
    end

    for i = 1, #slots do
        local slotInfo = slots[i]
        local itemLink = nil
        local okLink = pcall(function()
            local linkStyle = type(LINK_STYLE_BRACKETS) == "number" and LINK_STYLE_BRACKETS or LINK_STYLE_DEFAULT
            itemLink = GetItemLink(BAG_WORN, slotInfo.slot, linkStyle)
        end)

        if okLink and type(itemLink) == "string" and itemLink ~= "" then
            local setResults = SafeCallResults(GetItemLinkSetInfo, itemLink)
            local hasSet = setResults and setResults[1]
            local setName = setResults and setResults[2]
            local numEquipped = tonumber(setResults and setResults[4]) or 0
            local maxEquipped = tonumber(setResults and setResults[5]) or 0

            if hasSet and type(setName) == "string" and setName ~= "" then
                local lowerName = string.lower(setName)
                local entry = seen[lowerName]
                if not entry then
                    entry = {
                        setName = setName,
                        numEquipped = numEquipped,
                        maxEquipped = maxEquipped,
                        slots = {},
                    }
                    seen[lowerName] = entry
                    results[#results + 1] = entry
                end

                entry.slots[#entry.slots + 1] = slotInfo.label
                entry.numEquipped = math.max(entry.numEquipped or 0, numEquipped)
                entry.maxEquipped = math.max(entry.maxEquipped or 0, maxEquipped)
            end
        end
    end

    table.sort(results, function(a, b)
        if (a.numEquipped or 0) == (b.numEquipped or 0) then
            return tostring(a.setName) < tostring(b.setName)
        end
        return (a.numEquipped or 0) > (b.numEquipped or 0)
    end)

    return results
end

local function BuildWeaponEffectSnapshot()
    local weaponSlots = {
        { label = "Main Hand", slot = type(EQUIP_SLOT_MAIN_HAND) == "number" and EQUIP_SLOT_MAIN_HAND or nil },
        { label = "Off Hand", slot = type(EQUIP_SLOT_OFF_HAND) == "number" and EQUIP_SLOT_OFF_HAND or nil },
        { label = "Backup Main", slot = type(EQUIP_SLOT_BACKUP_MAIN) == "number" and EQUIP_SLOT_BACKUP_MAIN or nil },
        { label = "Backup Off", slot = type(EQUIP_SLOT_BACKUP_OFF) == "number" and EQUIP_SLOT_BACKUP_OFF or nil },
    }

    local entries = {}
    for i = 1, #weaponSlots do
        local slotInfo = weaponSlots[i]
        if type(slotInfo.slot) == "number" then
            local itemText = SafeGetEquippedItemText(slotInfo.slot)
            local enchantText = nil
            local poisonText = nil
            local itemLink = nil

            if type(GetItemLink) == "function" and type(BAG_WORN) == "number" then
                local okLink = pcall(function()
                    local linkStyle = type(LINK_STYLE_BRACKETS) == "number" and LINK_STYLE_BRACKETS or LINK_STYLE_DEFAULT
                    itemLink = GetItemLink(BAG_WORN, slotInfo.slot, linkStyle)
                end)
                if not okLink then
                    itemLink = nil
                end
            end

            if type(itemLink) == "string" and itemLink ~= "" then
                local skipValues = {}
                skipValues[itemText] = true
                local enchantResults = SafeCallResults(GetItemLinkWeaponEnchantInfo, itemLink)
                enchantText = FindFirstNonEmptyString(enchantResults, skipValues)
                if not enchantText then
                    enchantResults = SafeCallResults(GetItemLinkEnchantInfo, itemLink)
                    enchantText = FindFirstNonEmptyString(enchantResults, skipValues)
                end

                local poisonResults = SafeCallResults(GetItemPoisonInfo, BAG_WORN, slotInfo.slot)
                poisonText = FindFirstNonEmptyString(poisonResults, skipValues)
                if not poisonText then
                    poisonResults = SafeCallResults(GetItemLinkOnUseAbilityInfo, itemLink)
                    poisonText = FindFirstNonEmptyString(poisonResults, skipValues)
                end
            end

            entries[#entries + 1] = {
                label = slotInfo.label,
                itemText = itemText,
                enchantText = enchantText or "Unavailable",
                poisonText = poisonText or "None",
            }
        end
    end

    return entries
end

local function ClassifyChampionDisciplineBucket(disciplineName, disciplineType)
    local lowerName = string.lower(tostring(disciplineName or ""))
    if string.find(lowerName, "war", 1, true) ~= nil then
        return "warfare"
    end
    if string.find(lowerName, "fit", 1, true) ~= nil then
        return "fitness"
    end
    if string.find(lowerName, "craft", 1, true) ~= nil then
        return "craft"
    end

    local combatType = type(CHAMPION_DISCIPLINE_TYPE_COMBAT) == "number" and CHAMPION_DISCIPLINE_TYPE_COMBAT or nil
    local conditioningType = type(CHAMPION_DISCIPLINE_TYPE_CONDITIONING) == "number" and CHAMPION_DISCIPLINE_TYPE_CONDITIONING or nil
    local worldType = type(CHAMPION_DISCIPLINE_TYPE_WORLD) == "number" and CHAMPION_DISCIPLINE_TYPE_WORLD or nil

    if type(disciplineType) == "number" then
        if combatType and disciplineType == combatType then
            return "warfare"
        end
        if conditioningType and disciplineType == conditioningType then
            return "fitness"
        end
        if worldType and disciplineType == worldType then
            return "craft"
        end

        -- Console PTS mapping seen on this client can be rotated compared to legacy assumptions.
        if disciplineType == 1 then
            return "fitness"
        end
        if disciplineType == 2 then
            return "craft"
        end
        if disciplineType == 3 then
            return "warfare"
        end
    end
    return nil
end

local function RemapChampionBucket(bucketKey)
    -- Use current game discipline mapping directly.
    return bucketKey
end

local championUnpack = table.unpack or unpack

local function ChampionFirstNumber(results)
    if type(results) ~= "table" then
        return nil
    end

    for i = 1, #results do
        local value = tonumber(results[i])
        if value ~= nil then
            return value
        end
    end

    return nil
end

local function ChampionFirstPositiveNumber(results)
    if type(results) ~= "table" then
        return nil
    end

    for i = 1, #results do
        local value = tonumber(results[i])
        if value and value > 0 then
            return value
        end
    end

    return nil
end

local function ChampionReadNumberFromFunctionNames(fnNames, ...)
    local g = type(_G) == "table" and _G or nil
    for i = 1, #fnNames do
        local fn = g and g[fnNames[i]]
        if type(fn) == "function" then
            local value = ChampionFirstNumber(SafeCallResults(fn, ...))
            if value ~= nil then
                return value
            end
        end
    end
    return nil
end

local function GetChampionSkillIdSafe(disciplineId, disciplineIndex, disciplineType, skillIndex)
    if skillIndex == nil then
        return nil
    end

    local g = type(_G) == "table" and _G or nil
    local fnNames = {
        "GetChampionSkillId",
        "GetChampionDisciplineSkillId",
        "GetChampionSkillIdByIndex",
        "GetChampionDisciplineSkillIdByIndex",
    }
    local argLists = {
        { disciplineId, skillIndex },
        { disciplineIndex, skillIndex },
    }
    if disciplineType ~= nil then
        argLists[#argLists + 1] = { disciplineType, skillIndex }
    end

    for i = 1, #fnNames do
        local fn = g and g[fnNames[i]]
        if type(fn) == "function" then
            for j = 1, #argLists do
                local skillId = ChampionFirstPositiveNumber(SafeCallResults(fn, championUnpack(argLists[j])))
                if skillId then
                    return skillId
                end
            end
        end
    end

    return nil
end

local function GetChampionAbilityIdSafe(skillId, disciplineId, disciplineIndex, disciplineType, skillIndex)
    if not skillId then
        return nil
    end

    local fnNames = {
        "GetChampionSkillAbilityId",
        "GetAbilityIdForChampionSkill",
        "GetChampionSkillProgressionAbilityId",
    }

    local abilityId = ChampionReadNumberFromFunctionNames(fnNames, skillId)
    if abilityId and abilityId > 0 then
        return abilityId
    end

    local argLists = {
        { disciplineId, skillIndex },
        { disciplineIndex, skillIndex },
    }
    if disciplineType ~= nil then
        argLists[#argLists + 1] = { disciplineType, skillIndex }
    end

    for i = 1, #argLists do
        abilityId = ChampionReadNumberFromFunctionNames(fnNames, championUnpack(argLists[i]))
        if abilityId and abilityId > 0 then
            return abilityId
        end
    end

    return nil
end

local function CollectObservedChampionSlotIds()
    local g = type(_G) == "table" and _G or nil
    local observedIds = {}
    local slotContentFns = {
        "GetChampionSkillSlotSkillId",
        "GetChampionSkillSlotAbilityId",
        "GetChampionSkillSlotId",
        "GetChampionSlottedSkillId",
        "GetChampionSkillInSlot",
        "GetChampionSkillIdInSlot",
        "GetSlottedChampionSkillId",
    }
    local numSlots = ChampionFirstNumber(SafeCallResults(GetNumChampionSkillSlots)) or 12
    if numSlots <= 0 then
        numSlots = 12
    end
    local slotProbeMax = math.max(numSlots, 64)

    for i = 1, #slotContentFns do
        local fn = g and g[slotContentFns[i]]
        if type(fn) == "function" then
            for slotIndex = 1, slotProbeMax do
                local slotId = ChampionFirstPositiveNumber(SafeCallResults(fn, slotIndex))
                if slotId then
                    observedIds[slotId] = true
                end
            end
            for slotIndex = 0, slotProbeMax do
                local slotId = ChampionFirstPositiveNumber(SafeCallResults(fn, slotIndex))
                if slotId then
                    observedIds[slotId] = true
                end
            end
        end
    end

    return observedIds
end

local function IsChampionSkillSlottableSafe(skillId, disciplineId, disciplineIndex, disciplineType, skillIndex, abilityId, observedSlotIds)
    if not skillId then
        return nil
    end

    local g = type(_G) == "table" and _G or nil
    if type(observedSlotIds) == "table" then
        if observedSlotIds[skillId] or (abilityId and observedSlotIds[abilityId]) then
            return true
        end
    end

    local argLists = {
        { skillId },
        { disciplineId, skillIndex },
        { disciplineIndex, skillIndex },
    }
    if disciplineType ~= nil then
        argLists[#argLists + 1] = { disciplineType, skillIndex }
    end
    if abilityId and abilityId > 0 then
        argLists[#argLists + 1] = { abilityId }
    end

    local booleanFns = {
        "IsChampionSkillSlottable",
    }
    local sawBoolean = false
    for i = 1, #booleanFns do
        local fn = g and g[booleanFns[i]]
        if type(fn) == "function" then
            for j = 1, #argLists do
                local results = SafeCallResults(fn, championUnpack(argLists[j]))
                if type(results) == "table" and type(results[1]) == "boolean" then
                    sawBoolean = true
                    if results[1] == true then
                        return true
                    end
                end
            end
        end
    end

    local slottableTypeValues = {}
    local slottableTypeNames = {
        "CHAMPION_SKILL_TYPE_SLOTTABLE",
        "CHAMPION_CONSTELLATION_SKILL_TYPE_SLOTTABLE",
    }
    for i = 1, #slottableTypeNames do
        local typeValue = g and tonumber(g[slottableTypeNames[i]]) or nil
        if typeValue ~= nil then
            slottableTypeValues[typeValue] = true
        end
    end

    if next(slottableTypeValues) ~= nil then
        local sawSkillType = false
        local skillTypeFns = {
            "GetChampionSkillType",
        }
        for i = 1, #skillTypeFns do
            local fn = g and g[skillTypeFns[i]]
            if type(fn) == "function" then
                for j = 1, #argLists do
                    local skillType = ChampionFirstNumber(SafeCallResults(fn, championUnpack(argLists[j])))
                    if skillType ~= nil then
                        sawSkillType = true
                        if slottableTypeValues[skillType] then
                            return true
                        end
                    end
                end
            end
        end
        if sawSkillType then
            return false
        end
    end

    if sawBoolean then
        return false
    end

    return nil
end

function ConsoleMetrics:BuildChampionSlottablesById()
    local cache = {}
    local meta = {
        disciplineCount = 0,
        skillCount = 0,
        slottableCount = 0,
        unknownCount = 0,
    }

    local allSkillStates = {}
    local slotsById = {}

    local g = type(_G) == "table" and _G or nil
    local cdm = g and g.CHAMPION_DATA_MANAGER or nil
    local hotbarCat = g and g.HOTBAR_CATEGORY_CHAMPION or nil

    if cdm == nil or type(cdm.disciplineDatas) ~= "table" then
        self.championSlottablesById = cache
        self.championSlottablesMeta = meta
        self.championAllSkillStates = allSkillStates
        self.championObservedSlotIds = slotsById
        return cache, meta
    end

    if type(GetSlotBoundId) == "function" and hotbarCat ~= nil then
        for slotIndex = 1, 12 do
            local ok, starId = pcall(GetSlotBoundId, slotIndex, hotbarCat)
            if ok and type(starId) == "number" and starId > 0 then
                slotsById[starId] = true
            end
        end
    end

    for _, discipline in pairs(cdm.disciplineDatas) do
        meta.disciplineCount = meta.disciplineCount + 1
        local disciplineId = discipline.disciplineId
        local disciplineNameResults = SafeCallResults(GetChampionDisciplineName, disciplineId)
        local disciplineName = (disciplineNameResults and disciplineNameResults[1])
            or string.format("Discipline %d", disciplineId)
        local disciplineType = ChampionFirstNumber(SafeCallResults(GetChampionDisciplineType, disciplineId))
        local bucketKey = RemapChampionBucket(ClassifyChampionDisciplineBucket(disciplineName, disciplineType))

        for _, star in pairs(discipline.championSkillDatas or {}) do
            local starId = star.championSkillId
            if starId then
                meta.skillCount = meta.skillCount + 1

                local starName = string.format("Star %d", starId)
                if type(GetChampionSkillName) == "function" then
                    local ok, name = pcall(GetChampionSkillName, starId)
                    if ok and type(name) == "string" and name ~= "" then
                        starName = name
                    end
                end

                local isSlottable = false
                if type(star.IsTypeSlottable) == "function" then
                    local ok, result = pcall(star.IsTypeSlottable, star)
                    isSlottable = ok and result == true
                end

                local skillState = {
                    skillId = starId,
                    name = starName,
                    disciplineId = disciplineId,
                    disciplineName = disciplineName,
                    bucketKey = bucketKey,
                    disciplineType = disciplineType,
                    abilityId = nil,
                    isSlottable = isSlottable,
                }
                allSkillStates[starId] = skillState

                if isSlottable then
                    cache[starId] = skillState
                    meta.slottableCount = meta.slottableCount + 1
                else
                    meta.unknownCount = meta.unknownCount + 1
                end
            end
        end
    end

    self.championSlottablesById = cache
    self.championSlottablesMeta = meta
    self.championAllSkillStates = allSkillStates
    self.championObservedSlotIds = slotsById
    return cache, meta
end

function ConsoleMetrics:RefreshChampionSlottableCache()
    return self:BuildChampionSlottablesById()
end

function ConsoleMetrics:DumpChampionSlottables()
    local cache, meta = self:RefreshChampionSlottableCache()
    local entries = {}
    for _, entry in pairs(cache or {}) do
        entries[#entries + 1] = entry
    end

    local bucketOrder = {
        warfare = 1,
        fitness = 2,
        craft = 3,
    }

    table.sort(entries, function(a, b)
        local bucketA = bucketOrder[a.bucketKey or ""] or 99
        local bucketB = bucketOrder[b.bucketKey or ""] or 99
        if bucketA ~= bucketB then
            return bucketA < bucketB
        end
        if tostring(a.disciplineName or "") ~= tostring(b.disciplineName or "") then
            return tostring(a.disciplineName or "") < tostring(b.disciplineName or "")
        end
        if tostring(a.name or "") ~= tostring(b.name or "") then
            return tostring(a.name or "") < tostring(b.name or "")
        end
        return (a.skillId or 0) < (b.skillId or 0)
    end)

    self:Print(string.format(
        "Champion slottables: %d of %d skills scanned across %d disciplines (unknown=%d).",
        meta.slottableCount or 0,
        meta.skillCount or 0,
        meta.disciplineCount or 0,
        meta.unknownCount or 0
    ))

    local printer = type(d) == "function" and d or function(message)
        self:Print(message)
    end

    local function PrintEntry(entry, tag)
        printer(string.format(
            "|cFF6A00[CM-CP]|r [%s] id=%d abilityId=%s bucket=%s discipline=%s name=%s ability=%s",
            tag,
            entry.skillId or 0,
            tostring(entry.abilityId or 0),
            tostring(entry.bucketKey or "unknown"),
            tostring(entry.disciplineName or "Unknown"),
            tostring(entry.name or string.format("Skill %d", entry.skillId or 0)),
            tostring(entry.abilityName or "n/a")
        ))
    end

    if #entries > 0 then
        for i = 1, #entries do
            PrintEntry(entries[i], "slottable")
        end
        return
    end

    -- No confirmed slottables: emit raw observed slot IDs then all unknown skill states.
    local observedList = {}
    for slotId, _ in pairs(self.championObservedSlotIds or {}) do
        observedList[#observedList + 1] = tostring(slotId)
    end
    table.sort(observedList)
    if #observedList > 0 then
        self:Print("Observed (currently slotted) IDs: " .. table.concat(observedList, ", "))
    else
        self:Print("Slot probing found no IDs. Run /cm debugbuild to check slot API availability.")
    end

    local unknownEntries = {}
    for _, skillState in pairs(self.championAllSkillStates or {}) do
        unknownEntries[#unknownEntries + 1] = skillState
    end

    if #unknownEntries == 0 then
        self:Print("No skill states collected; Champion API may be unavailable.")
        return
    end

    table.sort(unknownEntries, function(a, b)
        local bucketA = bucketOrder[a.bucketKey or ""] or 99
        local bucketB = bucketOrder[b.bucketKey or ""] or 99
        if bucketA ~= bucketB then
            return bucketA < bucketB
        end
        if tostring(a.disciplineName or "") ~= tostring(b.disciplineName or "") then
            return tostring(a.disciplineName or "") < tostring(b.disciplineName or "")
        end
        if tostring(a.name or "") ~= tostring(b.name or "") then
            return tostring(a.name or "") < tostring(b.name or "")
        end
        return (a.skillId or 0) < (b.skillId or 0)
    end)

    self:Print(string.format("Dumping all %d unknown skills (slottable API unavailable):", #unknownEntries))
    for i = 1, #unknownEntries do
        PrintEntry(unknownEntries[i], "?")
    end
end

local function BuildChampionSnapshot()
    local snapshot = {
        totalPoints = nil,
        warfare = {},
        fitness = {},
        craft = {},
        available = false,
    }

    local totalResults = SafeCallResults(GetPlayerChampionPointsEarned)
    snapshot.totalPoints = tonumber(totalResults and totalResults[1]) or nil

    local g = type(_G) == "table" and _G or nil
    local cdm = g and g.CHAMPION_DATA_MANAGER or nil
    local hotbarCat = g and g.HOTBAR_CATEGORY_CHAMPION or nil

    -- Fast path: CHAMPION_DATA_MANAGER is the accurate console PTS source (same as LibCombat).
    if cdm ~= nil and type(cdm.disciplineDatas) == "table" then
        local slotsById = {}
        if type(GetSlotBoundId) == "function" and hotbarCat ~= nil then
            for slotIndex = 1, 12 do
                local ok, starId = pcall(GetSlotBoundId, slotIndex, hotbarCat)
                if ok and type(starId) == "number" and starId > 0 then
                    slotsById[starId] = true
                end
            end
        end

        local slotDebugInfo = {
            method = "CHAMPION_DATA_MANAGER",
            foundIds = slotsById,
            probes = {},
        }

        local disciplineCount = 0
        for _, discipline in pairs(cdm.disciplineDatas) do
            disciplineCount = disciplineCount + 1
            local disciplineId = discipline.disciplineId

            local disciplineNameResults = SafeCallResults(GetChampionDisciplineName, disciplineId)
            local disciplineName = (disciplineNameResults and disciplineNameResults[1])
                or string.format("Discipline %d", disciplineId)
            local disciplineType = ChampionFirstNumber(SafeCallResults(GetChampionDisciplineType, disciplineId))
            local bucketKey = RemapChampionBucket(ClassifyChampionDisciplineBucket(disciplineName, disciplineType))

            local totalPoints = 0
            if type(discipline.GetNumSavedSpentPoints) == "function" then
                local ok, pts = pcall(discipline.GetNumSavedSpentPoints, discipline)
                totalPoints = (ok and tonumber(pts)) or 0
            end

            local entry = {
                name = disciplineName,
                points = totalPoints,
                stars = {},
                debug = {
                    disciplineId = disciplineId,
                    disciplineType = disciplineType,
                    method = "CHAMPION_DATA_MANAGER",
                    skillPointProbes = {},
                },
            }

            local summedPoints = 0
            for _, star in pairs(discipline.championSkillDatas or {}) do
                local starId = star.championSkillId
                if starId then
                    local savedPoints = 0
                    if type(star.GetNumSavedPoints) == "function" then
                        local ok, pts = pcall(star.GetNumSavedPoints, star)
                        savedPoints = (ok and tonumber(pts)) or 0
                    end
                    if savedPoints > 0 then
                        summedPoints = summedPoints + savedPoints
                    end

                    if slotsById[starId] then
                        local starName = string.format("Star %d", starId)
                        if type(GetChampionSkillName) == "function" then
                            local ok, name = pcall(GetChampionSkillName, starId)
                            if ok and type(name) == "string" and name ~= "" then
                                starName = name
                            end
                        end
                        entry.stars[#entry.stars + 1] = starName
                    end
                end
            end

            if summedPoints > 0 then
                entry.points = summedPoints
            end

            if bucketKey then
                snapshot[bucketKey][#snapshot[bucketKey] + 1] = entry
            end
        end

        snapshot.available = disciplineCount > 0
        snapshot._slotDebugInfo = slotDebugInfo
        return snapshot
    end

    -- Fallback: probe-based approach when CHAMPION_DATA_MANAGER is unavailable.
    local slottedIds = {}
    local slottedNames = {}

    local function NormalizeName(name)
        if type(name) ~= "string" then
            return nil
        end
        local normalized = string.lower(name)
        normalized = string.gsub(normalized, "|c%x%x%x%x%x%x", "")
        normalized = string.gsub(normalized, "|r", "")
        normalized = string.gsub(normalized, "[^%w%s]", " ")
        normalized = string.gsub(normalized, "%s+", " ")
        normalized = string.gsub(normalized, "^%s+", "")
        normalized = string.gsub(normalized, "%s+$", "")
        return normalized ~= "" and normalized or nil
    end

    local function AddSlottedName(name)
        local normalized = NormalizeName(name)
        if normalized then
            slottedNames[normalized] = true
        end
    end

    local function AddSlottedId(skillId)
        local sid = tonumber(skillId)
        if not sid or sid <= 0 then
            return
        end
        slottedIds[sid] = true
        if type(GetChampionSkillName) == "function" then
            local ok, name = pcall(GetChampionSkillName, sid)
            if ok then
                AddSlottedName(name)
            end
        end
        if type(GetAbilityName) == "function" then
            local ok, name = pcall(GetAbilityName, sid)
            if ok then
                AddSlottedName(name)
            end
        end
    end

    local function FirstNumber(results)
        if type(results) ~= "table" then
            return nil
        end
        for i = 1, #results do
            local value = tonumber(results[i])
            if value ~= nil then
                return value
            end
        end
        return nil
    end

    local function FirstPositiveNumber(results)
        if type(results) ~= "table" then
            return nil
        end
        for i = 1, #results do
            local value = tonumber(results[i])
            if value and value > 0 then
                return value
            end
        end
        return nil
    end

    local function ReadNumberFromFunctionNames(fnNames, ...)
        for i = 1, #fnNames do
            local fn = g and g[fnNames[i]]
            if type(fn) == "function" then
                local results = SafeCallResults(fn, ...)
                local value = FirstNumber(results)
                if value ~= nil then
                    return value
                end
            end
        end
        return nil
    end

    local unpackFn = table.unpack or unpack

    local function ReadMaxNumberFromFunctionNamesWithArgLists(fnNames, argLists)
        local best = nil
        for i = 1, #argLists do
            local value = ReadNumberFromFunctionNames(fnNames, unpackFn(argLists[i]))
            if value ~= nil and (best == nil or value > best) then
                best = value
            end
        end
        return best
    end

    local function CollectNumberProbeValues(fnNames, argLists)
        local values = {}
        for i = 1, #fnNames do
            local fn = g and g[fnNames[i]]
            if type(fn) == "function" then
                for j = 1, #argLists do
                    local value = FirstNumber(SafeCallResults(fn, unpackFn(argLists[j])))
                    if value ~= nil then
                        values[#values + 1] = string.format("%s(%s)=%s", fnNames[i], table.concat(argLists[j], ""), tostring(value))
                    end
                end
            end
        end
        return values
    end

    local function ReadBooleanFromFunctionNames(fnNames, ...)
        for i = 1, #fnNames do
            local fn = g and g[fnNames[i]]
            if type(fn) == "function" then
                local results = SafeCallResults(fn, ...)
                if type(results) == "table" and type(results[1]) == "boolean" then
                    return results[1]
                end
            end
        end
        return nil
    end

    local slotContentFns = {
        "GetChampionSkillSlotSkillId",
        "GetChampionSkillSlotAbilityId",
        "GetChampionSkillSlotId",
        "GetChampionSlottedSkillId",
        "GetChampionSkillInSlot",
        "GetChampionSkillIdInSlot",
        "GetSlottedChampionSkillId",
    }

    local numSlotsResults = SafeCallResults(GetNumChampionSkillSlots)
    local numSlots = tonumber(numSlotsResults and numSlotsResults[1]) or 12
    if numSlots <= 0 then
        numSlots = 12
    end
    local slotProbeMax = math.max(numSlots, 64)

    local slotDebugInfo = {
        numSlotsFunction = "GetNumChampionSkillSlots",
        numSlotsResult = FirstNumber(numSlotsResults),
        resolvedNumSlots = numSlots,
        probeMax = slotProbeMax,
        probes = {},
        foundIds = {},
    }

    for _, fnName in ipairs(slotContentFns) do
        local fn = g and g[fnName]
        if type(fn) == "function" then
            for slotIdx = 1, slotProbeMax do
                local result = FirstPositiveNumber(SafeCallResults(fn, slotIdx))
                if result then
                    slotDebugInfo.probes[#slotDebugInfo.probes + 1] = string.format("%s(%d)=%d", fnName, slotIdx, result)
                    slotDebugInfo.foundIds[result] = true
                    AddSlottedId(result)
                end
            end
            for slotIdx = 0, slotProbeMax do
                local result = FirstPositiveNumber(SafeCallResults(fn, slotIdx))
                if result then
                    slotDebugInfo.probes[#slotDebugInfo.probes + 1] = string.format("%s(%d)=%d", fnName, slotIdx, result)
                    slotDebugInfo.foundIds[result] = true
                    AddSlottedId(result)
                end
            end
        end
    end

    local abilityIdFns = {
        "GetChampionSkillAbilityId",
        "GetAbilityIdForChampionSkill",
        "GetChampionSkillProgressionAbilityId",
    }

    local function ResolveAbilityIdForSkill(skillId, disciplineArg, skillIndexArg)
        if not skillId then
            return nil
        end
        local abilityId = ReadNumberFromFunctionNames(abilityIdFns, skillId)
        if abilityId and abilityId > 0 then
            return abilityId
        end
        if disciplineArg ~= nil and skillIndexArg ~= nil then
            abilityId = ReadNumberFromFunctionNames(abilityIdFns, disciplineArg, skillIndexArg)
            if abilityId and abilityId > 0 then
                return abilityId
            end
        end
        return nil
    end

    local function IsSkillSlottedById(skillId, disciplineArg, skillIndexArg)
        if slottedIds[skillId] then
            return true
        end

        local mappedAbilityId = ResolveAbilityIdForSkill(skillId, disciplineArg, skillIndexArg)
        if mappedAbilityId and slottedIds[mappedAbilityId] then
            return true
        end

        local slottedCheckFns = {
            "IsChampionSkillSlotted",
            "IsSlottedChampionSkill",
            "IsChampionAbilitySlotted",
        }
        local isSlotted = ReadBooleanFromFunctionNames(slottedCheckFns, skillId)
        if isSlotted == true then
            return true
        end
        if disciplineArg ~= nil and skillIndexArg ~= nil then
            isSlotted = ReadBooleanFromFunctionNames(slottedCheckFns, disciplineArg, skillIndexArg)
            if isSlotted == true then
                return true
            end
        end
        if skillIndexArg ~= nil then
            isSlotted = ReadBooleanFromFunctionNames(slottedCheckFns, skillIndexArg)
            if isSlotted == true then
                return true
            end
        end
        if mappedAbilityId then
            isSlotted = ReadBooleanFromFunctionNames(slottedCheckFns, mappedAbilityId)
            if isSlotted == true then
                return true
            end
        end

        local normalized = nil
        if type(GetChampionSkillName) == "function" then
            local ok, skillName = pcall(GetChampionSkillName, skillId)
            normalized = ok and NormalizeName(skillName) or nil
            if normalized and slottedNames[normalized] then
                return true
            end
        end

        if mappedAbilityId and type(GetAbilityName) == "function" then
            local ok, abilityName = pcall(GetAbilityName, mappedAbilityId)
            normalized = ok and NormalizeName(abilityName) or nil
            if normalized and slottedNames[normalized] then
                return true
            end
        end

        if type(GetAbilityName) == "function" then
            local ok, abilityName = pcall(GetAbilityName, skillId)
            normalized = ok and NormalizeName(abilityName) or nil
            if normalized and slottedNames[normalized] then
                return true
            end
        end

        return false
    end

    local disciplineCountResults = SafeCallResults(GetNumChampionDisciplines)
    local disciplineCount = FirstNumber(disciplineCountResults) or 0
    if disciplineCount <= 0 then
        return snapshot
    end
    snapshot.available = true

    local disciplineIndices = {}
    for index = 1, disciplineCount do
        disciplineIndices[#disciplineIndices + 1] = index
    end
    for index = 0, math.max(0, disciplineCount - 1) do
        disciplineIndices[#disciplineIndices + 1] = index
    end

    local seenDisciplineIds = {}
    for _, index in ipairs(disciplineIndices) do
        local disciplineIdResults = SafeCallResults(GetChampionDisciplineId, index)
        local disciplineId = FirstPositiveNumber(disciplineIdResults)
        if not disciplineId and type(index) == "number" and index > 0 then
            disciplineId = index
        end
        if disciplineId and not seenDisciplineIds[disciplineId] then
            seenDisciplineIds[disciplineId] = true
            local disciplineNameResults = SafeCallResults(GetChampionDisciplineName, disciplineId)
            local disciplineName = disciplineNameResults and disciplineNameResults[1] or string.format("Discipline %d", disciplineId)
            local disciplineType = FirstNumber(SafeCallResults(GetChampionDisciplineType, disciplineId))
                or FirstNumber(SafeCallResults(GetChampionDisciplineType, index))
            local bucketKey = RemapChampionBucket(ClassifyChampionDisciplineBucket(disciplineName, disciplineType))

            local pointsFnNames = {
                "GetNumPointsSpentOnChampionDiscipline",
                "GetNumPointsSpentInChampionDiscipline",
                "GetNumSpentPointsOnChampionDiscipline",
                "GetNumSpentChampionPointsOnDiscipline",
            }
            local pointsArgs = {
                { disciplineId },
                { index },
            }
            if disciplineType ~= nil then
                pointsArgs[#pointsArgs + 1] = { disciplineType }
            end
            local entry = {
                name = disciplineName,
                points = ReadMaxNumberFromFunctionNamesWithArgLists(pointsFnNames, pointsArgs) or 0,
                stars = {},
                debug = {
                    disciplineId = disciplineId,
                    disciplineIndex = index,
                    disciplineType = disciplineType,
                    pointsProbes = CollectNumberProbeValues(pointsFnNames, pointsArgs),
                    skillPointProbes = {},
                },
            }

            local skillCount = 0
            local skillCountArgs = {
                { disciplineId },
                { index },
            }
            if disciplineType ~= nil then
                skillCountArgs[#skillCountArgs + 1] = { disciplineType }
            end
            for i = 1, #skillCountArgs do
                local count = FirstNumber(SafeCallResults(GetNumChampionDisciplineSkills, unpackFn(skillCountArgs[i])))
                if count and count > skillCount then
                    skillCount = count
                end
            end

            local skillIdFnNames = {
                "GetChampionSkillId",
                "GetChampionDisciplineSkillId",
                "GetChampionSkillIdByIndex",
                "GetChampionDisciplineSkillIdByIndex",
            }

            local function ResolveSkillId(skillIndex)
                local argLists = {
                    { disciplineId, skillIndex },
                    { index, skillIndex },
                }
                if disciplineType ~= nil then
                    argLists[#argLists + 1] = { disciplineType, skillIndex }
                end

                for i = 1, #skillIdFnNames do
                    local fn = g and g[skillIdFnNames[i]]
                    if type(fn) == "function" then
                        for j = 1, #argLists do
                            local skillId = FirstPositiveNumber(SafeCallResults(fn, unpackFn(argLists[j])))
                            if skillId then
                                return skillId
                            end
                        end
                    end
                end

                return nil
            end

            local seenSkillIds = {}
            local summedSkillPoints = 0
            local skillPointsFnNames = {
                "GetNumPointsSpentOnChampionSkill",
                "GetNumPointsSpentInChampionSkill",
                "GetNumSpentPointsOnChampionSkill",
                "GetNumSpentChampionPointsOnSkill",
                "GetChampionSkillCurrentPoints",
                "GetChampionSkillNumPoints",
            }
            local seenSkillProbeLogs = {}
            local function CollectSkill(skillId, skillIndex)
                if not skillId then
                    return
                end

                local skillState = seenSkillIds[skillId]
                if not skillState then
                    local skillNameResults = SafeCallResults(GetChampionSkillName, skillId)
                    skillState = {
                        name = skillNameResults and skillNameResults[1] or string.format("Skill %d", skillId),
                        points = 0,
                        slotted = false,
                    }
                    seenSkillIds[skillId] = skillState
                end

                local skillName = skillState.name

                local skillPointArgs = {
                    { skillId },
                    { disciplineId, skillId },
                    { index, skillId },
                }
                if skillIndex ~= nil then
                    skillPointArgs[#skillPointArgs + 1] = { disciplineId, skillIndex }
                    skillPointArgs[#skillPointArgs + 1] = { index, skillIndex }
                end
                if disciplineType ~= nil then
                    skillPointArgs[#skillPointArgs + 1] = { disciplineType, skillId }
                    if skillIndex ~= nil then
                        skillPointArgs[#skillPointArgs + 1] = { disciplineType, skillIndex }
                    end
                end

                local skillPoints = ReadMaxNumberFromFunctionNamesWithArgLists(skillPointsFnNames, skillPointArgs) or 0
                if skillPoints > skillState.points then
                    summedSkillPoints = summedSkillPoints - skillState.points + skillPoints
                    skillState.points = skillPoints
                end

                if entry.points <= 0 then
                    for i = 1, #skillPointsFnNames do
                        local fn = g and g[skillPointsFnNames[i]]
                        if type(fn) == "function" then
                            for j = 1, #skillPointArgs do
                                local value = FirstNumber(SafeCallResults(fn, unpackFn(skillPointArgs[j])))
                                if value ~= nil then
                                    local probeText = string.format(
                                        "%s(skill=%s:%s,args=%s)=%s",
                                        skillPointsFnNames[i],
                                        tostring(skillId),
                                        tostring(skillName),
                                        table.concat(skillPointArgs[j], ""),
                                        tostring(value)
                                    )
                                    if not seenSkillProbeLogs[probeText] then
                                        seenSkillProbeLogs[probeText] = true
                                        entry.debug.skillPointProbes[#entry.debug.skillPointProbes + 1] = probeText
                                    end
                                end
                            end
                        end
                    end
                end

                if not skillState.slotted and (IsSkillSlottedById(skillId, disciplineId, skillIndex) or IsSkillSlottedById(skillId, disciplineType, skillIndex)) then
                    skillState.slotted = true
                    entry.stars[#entry.stars + 1] = skillName
                end
            end

            local skillProbeMax = math.max(skillCount + 8, 96)

            for skillIndex = 1, skillProbeMax do
                local skillId = ResolveSkillId(skillIndex)
                CollectSkill(skillId, skillIndex)
            end

            for skillIndex = 0, skillProbeMax do
                local skillId = ResolveSkillId(skillIndex)
                CollectSkill(skillId, skillIndex)
            end

            if summedSkillPoints > 0 then
                entry.points = summedSkillPoints
            end

            if bucketKey then
                snapshot[bucketKey][#snapshot[bucketKey] + 1] = entry
            end
        end
    end

    snapshot._slotDebugInfo = slotDebugInfo

    return snapshot
end

local function UnitName(rawName)
    if not rawName or rawName == "" then
        return "Unknown"
    end
    return zo_strformat(SI_UNIT_NAME, rawName)
end

local function IsDamageResult(result)
    return result == ACTION_RESULT_DAMAGE
        or result == ACTION_RESULT_DOT_TICK
        or result == ACTION_RESULT_DOT_TICK_CRITICAL
        or result == ACTION_RESULT_CRITICAL_DAMAGE
        or result == ACTION_RESULT_DAMAGE_SHIELDED
        or result == ACTION_RESULT_BLOCKED_DAMAGE
end

local function IsHealResult(result)
    return result == ACTION_RESULT_HEAL
        or result == ACTION_RESULT_HOT_TICK
        or result == ACTION_RESULT_HOT_TICK_CRITICAL
        or result == ACTION_RESULT_CRITICAL_HEAL
end

local function IsCriticalResult(result)
    return result == ACTION_RESULT_CRITICAL_DAMAGE
        or result == ACTION_RESULT_CRITICAL_HEAL
end

local function IsEffectGainedResult(result)
    return result == ACTION_RESULT_EFFECT_GAINED
        or result == ACTION_RESULT_EFFECT_GAINED_DURATION
        or result == ACTION_RESULT_EFFECT_REFRESH
        or result == ACTION_RESULT_EFFECT_REAPPLIED
end

local function IsEffectFadedResult(result)
    return result == ACTION_RESULT_EFFECT_FADED
        or result == ACTION_RESULT_EFFECT_FADED_DURATION
end

local function Clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    end
    if value > maxValue then
        return maxValue
    end
    return value
end

local function SortSkillEntries(skillMap)
    local list = {}
    for _, info in pairs(skillMap) do
        list[#list + 1] = info
    end

    table.sort(list, function(a, b)
        return a.damage > b.damage
    end)

    return list
end

local function SortSkillEntriesByHeal(skillMap)
    local list = {}
    for _, info in pairs(skillMap) do
        if (info.heal or 0) > 0 then
            list[#list + 1] = info
        end
    end

    table.sort(list, function(a, b)
        return (a.heal or 0) > (b.heal or 0)
    end)

    return list
end

local function AddTopMoment(momentList, moment)
    momentList[#momentList + 1] = moment

    table.sort(momentList, function(a, b)
        return (a.value or 0) > (b.value or 0)
    end)

    while #momentList > TOP_MOMENTS_LIMIT do
        table.remove(momentList, #momentList)
    end
end

local function CloneMoments(momentList)
    local clone = {}
    for i = 1, #momentList do
        local moment = momentList[i]
        clone[i] = {
            value = moment.value,
            label = moment.label,
            tooltip = moment.tooltip,
            abilityId = moment.abilityId,
            abilityName = moment.abilityName,
            effectName = moment.effectName,
        }
    end
    return clone
end

local function NewFight(nowMs)
    return {
        startMs = nowMs,
        endMs = nil,
        totalDamage = 0,
        totalOverflowDamage = 0,
        totalBlockedDamage = 0,
        totalShieldedDamage = 0,
        totalHeal = 0,
        totalOverflowHeal = 0,
        totalTaken = 0,
        totalIncomingOverflowDamage = 0,
        totalIncomingBlockedDamage = 0,
        totalIncomingShieldedDamage = 0,
        hits = 0,
        crits = 0,
        peakDps = 0,
        peakHps = 0,
        skillMap = {},
        incomingSkillMap = {},
        incomingSetDamageMap = {},
        incomingLikelySetProcMap = {},
        dotMap = {},
        hotMap = {},
        targetMap = {},
        topHealingMoments = {},
        topMitigationMoments = {},
        -- Tracks every effect seen via ACTION_RESULT_EFFECT_GAINED/FADED style events.
        allEffects = {},
        -- Tracks major/minor subsets for fast console-friendly filtering.
        majorMinorEffects = {},
        -- Tracks popular PvE/PvP set procs by alias.
        setEffects = {},
        -- Resource snapshots sampled during combat for avg/median display.
        resourceSamples = {
            lastSampleMs = nil,
            healthPct = {},
            magickaPct = {},
            staminaPct = {},
            pingMs = {},
            -- Absolute value tracking for per-fight regen/drain/ultimate gen.
            lastAbsHealth = nil,
            lastAbsMagicka = nil,
            lastAbsStamina = nil,
            lastAbsUltimate = nil,
            lastPingMs = nil,
            minPingMs = nil,
            maxPingMs = nil,
            pingDipCount = 0,
            pingSpikeCount = 0,
            highDelaySamples = 0,
            totalHealthRegen = 0,
            totalHealthDrain = 0,
            totalMagickaRegen = 0,
            totalMagickaDrain = 0,
            totalStaminaRegen = 0,
            totalStaminaDrain = 0,
            totalUltimateGen = 0,
            totalUltimateDrain = 0,
        },
        protectionInfo = {
            currentState = "unknown",
            currentLabel = "No mitigation data",
            currentResistance = 0,
            currentDrPct = 0,
            confidence = 0,
            samples = 0,
            lastSampleMs = nowMs,
            drEma = 0,
            stateMs = {
                majorMinor = 0,
                major = 0,
                minor = 0,
                none = 0,
                unknown = 0,
            },
        },
    }
end

function ConsoleMetrics:IsFightViewDialogShowing()
    return self.ui.fightViewDialog ~= nil
        and self.ui.fightViewDialog.selected == true
        and LibHarvensAddonSettings ~= nil
        and LibHarvensAddonSettings.scene ~= nil
        and LibHarvensAddonSettings.scene:IsShowing()
end

function ConsoleMetrics:ArmDialogAutoHide()
    if not self.saved.dialogAutoHide then
        self.dialogAutoHideAtMs = nil
        return
    end

    local seconds = tonumber(self.saved.dialogAutoHideSeconds) or self.defaults.dialogAutoHideSeconds
    seconds = Clamp(seconds, 3, 120)
    self.dialogAutoHideAtMs = GetFrameTimeMilliseconds() + (seconds * 1000)
end

function ConsoleMetrics:CloseFightViewDialog(silent, reason)
    self.dialogAutoHideAtMs = nil
    self.dialogRefreshAtMs = nil

    if self.ui.fightViewDialog then
        -- Clear selection state first so OnUpdate won't treat this as an active panel.
        self.ui.fightViewDialog.selected = false
        if self.ui.fightViewDialog.Hide then
            self.ui.fightViewDialog:Hide()
        end
    end

    if LibHarvensAddonSettings and LibHarvensAddonSettings.scene and LibHarvensAddonSettings.scene.Hide then
        LibHarvensAddonSettings.scene:Hide()
    end

    if LibConsoleDialogs then
        LibConsoleDialogs:Close()
    end

    if not silent then
        local source = reason or "manual"
        self:Print(string.format("Fight data dialog closed (%s)", source))
    end
end

local function GetFightDurationSeconds(fight, nowMs)
    if not fight or not fight.startMs then
        return 0
    end

    local endMs = fight.endMs or nowMs
    return math.max((endMs - fight.startMs) / 1000, 0)
end

local function EstimateTargetResistance(target)
    if not target then
        return 0, 0
    end

    local mitigatedLike = (target.blocked or 0) + (target.shielded or 0)
    local totalObserved = (target.effective or 0) + (target.overflow or 0) + mitigatedLike
    if totalObserved <= 0 then
        return 0, 0
    end

    local mitigationRatio = Clamp(mitigatedLike / totalObserved, 0, 0.5)
    local resistance = Clamp(mitigationRatio * RESISTANCE_SCALE, 0, RESISTANCE_CAP)
    return resistance, mitigationRatio * 100
end

local function InferProtectionFromDr(drPct, hasData)
    if not hasData then
        return "No mitigation data", "unknown", 0
    end

    if drPct >= (MAJOR_PROTECTION_DR_PCT + MINOR_PROTECTION_DR_PCT - 1.0) then
        local confidence = Clamp(0.65 + ((drPct - (MAJOR_PROTECTION_DR_PCT + MINOR_PROTECTION_DR_PCT)) / 20), 0.45, 0.98)
        return "Major + Minor Protection (inferred)", "majorMinor", confidence
    end

    if drPct >= (MAJOR_PROTECTION_DR_PCT - 1.0) then
        local confidence = Clamp(0.60 + ((drPct - MAJOR_PROTECTION_DR_PCT) / 18), 0.40, 0.95)
        return "Major Protection (inferred)", "major", confidence
    end

    if drPct >= (MINOR_PROTECTION_DR_PCT - 1.0) then
        local confidence = Clamp(0.55 + ((drPct - MINOR_PROTECTION_DR_PCT) / 15), 0.35, 0.90)
        return "Minor Protection (inferred)", "minor", confidence
    end

    local confidence = Clamp(0.50 + ((MINOR_PROTECTION_DR_PCT - drPct) / 15), 0.30, 0.90)
    return "No Protection inferred", "none", confidence
end

local function IsMajorMinorEffectName(effectName)
    if not effectName or effectName == "" then
        return false
    end

    local lower = string.lower(effectName)
    return string.find(lower, "major ", 1, true) == 1
        or string.find(lower, "minor ", 1, true) == 1
end

local function MatchPopularSet(abilityName)
    if not abilityName or abilityName == "" then
        return nil
    end

    local lower = string.lower(abilityName)
    for i = 1, #POPULAR_SET_CATALOG do
        local entry = POPULAR_SET_CATALOG[i]
        for j = 1, #entry.aliases do
            local alias = entry.aliases[j]
            if string.find(lower, alias, 1, true) ~= nil then
                return entry
            end
        end
    end

    return nil
end

local function NormalizeCustomSetScene(scene)
    local lower = string.lower(TrimText(scene))
    if lower == "" then
        return "PvP"
    end
    if lower == "pve" then
        return "PvE"
    end
    if lower == "pvp" then
        return "PvP"
    end
    return "Custom"
end

local function BuildCustomAliasList(abilityName)
    local aliases = {}
    local base = string.lower(TrimText(abilityName))
    if base == "" then
        return aliases
    end

    aliases[#aliases + 1] = base
    for token in string.gmatch(base, "[^,%|;]+") do
        local clean = TrimText(token)
        if clean ~= "" then
            local exists = false
            for i = 1, #aliases do
                if aliases[i] == clean then
                    exists = true
                    break
                end
            end
            if not exists then
                aliases[#aliases + 1] = clean
            end
        end
    end

    return aliases
end

local function ClassifyLikelySetProc(abilityName)
    if not abilityName or abilityName == "" then
        return false, nil, 0
    end

    -- Keep curated matching authoritative and separate from heuristic rows.
    if MatchPopularSet(abilityName) then
        return false, nil, 0
    end

    local lower = string.lower(abilityName)
    local score = 0
    local reasons = {}

    for i = 1, #LIKELY_SET_PROC_KEYWORDS do
        local keyword = LIKELY_SET_PROC_KEYWORDS[i]
        if string.find(lower, keyword, 1, true) ~= nil then
            score = score + 1
            reasons[#reasons + 1] = keyword
        end
    end

    if string.find(lower, "'s ", 1, true) ~= nil then
        score = score + 1
        reasons[#reasons + 1] = "possessive"
    end

    if string.find(lower, " of ", 1, true) ~= nil then
        score = score + 0.5
        reasons[#reasons + 1] = "name pattern"
    end

    if score < 1.5 then
        return false, nil, score
    end

    return true, table.concat(reasons, ", "), score
end

local function BuildProtectionSummary(protectionInfo, nowMs)
    local stateMs = {
        majorMinor = 0,
        major = 0,
        minor = 0,
        none = 0,
        unknown = 0,
    }

    if protectionInfo and protectionInfo.stateMs then
        stateMs.majorMinor = protectionInfo.stateMs.majorMinor or 0
        stateMs.major = protectionInfo.stateMs.major or 0
        stateMs.minor = protectionInfo.stateMs.minor or 0
        stateMs.none = protectionInfo.stateMs.none or 0
        stateMs.unknown = protectionInfo.stateMs.unknown or 0

        if protectionInfo.lastSampleMs and protectionInfo.currentState and nowMs > protectionInfo.lastSampleMs then
            local elapsed = nowMs - protectionInfo.lastSampleMs
            local key = protectionInfo.currentState
            stateMs[key] = (stateMs[key] or 0) + elapsed
        end
    end

    local totalMs = stateMs.majorMinor + stateMs.major + stateMs.minor + stateMs.none + stateMs.unknown
    local trackedKnownMs = stateMs.majorMinor + stateMs.major + stateMs.minor + stateMs.none
    local anyProtectionMs = stateMs.majorMinor + stateMs.major + stateMs.minor

    local function Ratio(ms)
        if totalMs <= 0 then
            return 0
        end
        return (ms / totalMs) * 100
    end

    return {
        totalMs = totalMs,
        trackedKnownMs = trackedKnownMs,
        majorMinorMs = stateMs.majorMinor,
        majorMs = stateMs.major,
        minorMs = stateMs.minor,
        noneMs = stateMs.none,
        unknownMs = stateMs.unknown,
        anyProtectionMs = anyProtectionMs,
        majorMinorPct = Ratio(stateMs.majorMinor),
        majorPct = Ratio(stateMs.major),
        minorPct = Ratio(stateMs.minor),
        nonePct = Ratio(stateMs.none),
        unknownPct = Ratio(stateMs.unknown),
        anyProtectionPct = Ratio(anyProtectionMs),
    }
end

local function AcquireTrackedEffect(effectMap, key, name, category, abilityId, effectName)
    local track = effectMap[key]
    if not track then
        track = {
            key = key,
            name = name,
            category = category,
            abilityId = SafeAbilityId(abilityId),
            effectName = effectName or name,
            uptimeMs = 0,
            activeSinceMs = nil,
            activations = 0,
            fades = 0,
            procs = 0,
            totalValue = 0,
        }
        effectMap[key] = track
    else
        if (track.name == nil or track.name == "") and name and name ~= "" then
            track.name = name
        end
        if (track.effectName == nil or track.effectName == "") and effectName and effectName ~= "" then
            track.effectName = effectName
        end
        if (track.abilityId == nil or track.abilityId == 0) and SafeAbilityId(abilityId) > 0 then
            track.abilityId = SafeAbilityId(abilityId)
        end
    end

    return track
end

local function StartTrackedEffect(track, nowMs)
    if track.activeSinceMs == nil then
        track.activeSinceMs = nowMs
        track.activations = (track.activations or 0) + 1
    end
end

local function StopTrackedEffect(track, nowMs)
    if track.activeSinceMs ~= nil and nowMs >= track.activeSinceMs then
        track.uptimeMs = (track.uptimeMs or 0) + (nowMs - track.activeSinceMs)
        track.activeSinceMs = nil
        track.fades = (track.fades or 0) + 1
    end
end

-- Convert internal per-effect runtime state into sorted, render-ready summary rows.
local function BuildTrackedEffectList(effectMap, durationSeconds, nowMs)
    local list = {}
    local durationMs = math.max((durationSeconds or 0) * 1000, 0)

    for _, track in pairs(effectMap or {}) do
        local uptimeMs = track.uptimeMs or 0
        if track.activeSinceMs and nowMs > track.activeSinceMs then
            uptimeMs = uptimeMs + (nowMs - track.activeSinceMs)
        end

        local uptimePct = 0
        if durationMs > 0 then
            uptimePct = Clamp((uptimeMs / durationMs) * 100, 0, 100)
        end

        list[#list + 1] = {
            name = track.name,
            category = track.category,
            abilityId = SafeAbilityId(track.abilityId),
            effectName = track.effectName or track.name,
            uptimeMs = uptimeMs,
            uptimePct = uptimePct,
            activations = track.activations or 0,
            fades = track.fades or 0,
            procs = track.procs or 0,
            totalValue = track.totalValue or 0,
        }
    end

    table.sort(list, function(a, b)
        if a.uptimePct == b.uptimePct then
            return (a.procs or 0) > (b.procs or 0)
        end
        return a.uptimePct > b.uptimePct
    end)

    return list
end

local function Mean(values)
    if #values == 0 then
        return 0
    end

    local sum = 0
    for i = 1, #values do
        sum = sum + values[i]
    end

    return sum / #values
end

local function Median(values)
    local count = #values
    if count == 0 then
        return 0
    end

    local sorted = {}
    for i = 1, count do
        sorted[i] = values[i]
    end
    table.sort(sorted)

    local midpoint = math.floor(count / 2)
    if (count % 2) == 1 then
        return sorted[midpoint + 1]
    end

    return (sorted[midpoint] + sorted[midpoint + 1]) / 2
end

local function SafeGetCurrentPowerFromList(powerTypeList)
    if type(GetUnitPower) ~= "function" or type(powerTypeList) ~= "table" then
        return nil
    end

    for i = 1, #powerTypeList do
        local powerType = powerTypeList[i]
        if type(powerType) == "number" then
            local current = GetUnitPower("player", powerType)
            if current and current >= 0 then
                return current
            end
        end
    end

    return nil
end

local function SafeGetMaxPowerFromList(powerTypeList)
    if type(GetUnitPower) ~= "function" or type(powerTypeList) ~= "table" then
        return nil
    end

    for i = 1, #powerTypeList do
        local powerType = powerTypeList[i]
        if type(powerType) == "number" then
            local _, maximum = GetUnitPower("player", powerType)
            if maximum and maximum > 0 then
                return maximum
            end
        end
    end

    return nil
end

local function SafeGetPowerPctFromList(powerTypeList)
    local current = SafeGetCurrentPowerFromList(powerTypeList)
    local maximum = SafeGetMaxPowerFromList(powerTypeList)
    if not current or not maximum or maximum <= 0 then
        return nil
    end

    return Clamp((current / maximum) * 100, 0, 100)
end

local function BuildResourceSampleSummary(values)
    if #values == 0 then
        return {
            samples = 0,
            averagePct = 0,
            medianPct = 0,
            hasData = false,
        }
    end

    return {
        samples = #values,
        averagePct = Mean(values),
        medianPct = Median(values),
        hasData = true,
    }
end

local function BuildNumericSampleSummary(values)
    if #values == 0 then
        return {
            samples = 0,
            average = 0,
            median = 0,
            min = 0,
            max = 0,
            hasData = false,
        }
    end

    local normalized = {}
    local sum = 0
    local minValue = nil
    local maxValue = nil

    for i = 1, #values do
        local value = tonumber(values[i]) or 0
        normalized[#normalized + 1] = value
        sum = sum + value
        if minValue == nil or value < minValue then
            minValue = value
        end
        if maxValue == nil or value > maxValue then
            maxValue = value
        end
    end

    return {
        samples = #normalized,
        average = sum / #normalized,
        median = Median(normalized),
        min = minValue or 0,
        max = maxValue or 0,
        hasData = true,
    }
end

local function SafeGetLatencyMs()
    if type(GetLatency) ~= "function" then
        return nil
    end

    local latency = nil
    local ok = pcall(function()
        latency = GetLatency()
    end)
    if not ok then
        return nil
    end

    latency = tonumber(latency)
    if latency == nil or latency < 0 then
        return nil
    end

    -- Some API layers may expose latency in seconds; normalize to milliseconds.
    if latency > 0 and latency < 5 then
        latency = latency * 1000
    end

    return math.floor(latency + 0.5)
end

local function BuildSustainPerformanceSummary(magickaStats, staminaStats)
    local avgInputs = {}
    local medianInputs = {}

    if magickaStats and magickaStats.hasData then
        avgInputs[#avgInputs + 1] = magickaStats.averagePct or 0
        medianInputs[#medianInputs + 1] = magickaStats.medianPct or 0
    end
    if staminaStats and staminaStats.hasData then
        avgInputs[#avgInputs + 1] = staminaStats.averagePct or 0
        medianInputs[#medianInputs + 1] = staminaStats.medianPct or 0
    end

    if #avgInputs == 0 then
        return {
            hasData = false,
            averagePct = 0,
            medianPct = 0,
            label = "No sustain data",
            sourceCount = 0,
        }
    end

    local averagePct = Mean(avgInputs)
    local medianPct = Mean(medianInputs)
    local label = "Stable"
    if averagePct >= 75 then
        label = "Strong"
    elseif averagePct >= 50 then
        label = "Stable"
    elseif averagePct >= 30 then
        label = "Pressured"
    else
        label = "Critical"
    end

    return {
        hasData = true,
        averagePct = averagePct,
        medianPct = medianPct,
        label = label,
        sourceCount = #avgInputs,
    }
end

local function StdDev(values, mean)
    if #values <= 1 then
        return 0
    end

    local variance = 0
    for i = 1, #values do
        local diff = values[i] - mean
        variance = variance + (diff * diff)
    end

    variance = variance / (#values - 1)
    return math.sqrt(variance)
end

local function LinearSlope(values)
    local n = #values
    if n <= 1 then
        return 0
    end

    local sumX = 0
    local sumY = 0
    local sumXY = 0
    local sumXX = 0

    for i = 1, n do
        local x = i
        local y = values[i]
        sumX = sumX + x
        sumY = sumY + y
        sumXY = sumXY + (x * y)
        sumXX = sumXX + (x * x)
    end

    local denom = (n * sumXX) - (sumX * sumX)
    if denom == 0 then
        return 0
    end

    return ((n * sumXY) - (sumX * sumY)) / denom
end

local function ExponentialAverage(values, alpha)
    if #values == 0 then
        return 0
    end

    local ema = values[1]
    for i = 2, #values do
        ema = alpha * values[i] + (1 - alpha) * ema
    end
    return ema
end

function ConsoleMetrics:AcquireTargetInfo(targetName)
    local key = targetName
    if not key or key == "" then
        key = "Unknown"
    end

    local info = self.fight.targetMap[key]
    if not info then
        info = {
            name = key,
            damage = 0,
            effective = 0,
            overflow = 0,
            blocked = 0,
            shielded = 0,
            hits = 0,
        }
        self.fight.targetMap[key] = info
    end

    return info
end

function ConsoleMetrics:SampleFightResources(nowMs, forceSample)
    if not self.fight or not self.fight.resourceSamples then
        return
    end

    local resourceSamples = self.fight.resourceSamples
    if not forceSample and resourceSamples.lastSampleMs and nowMs < (resourceSamples.lastSampleMs + RESOURCE_SAMPLE_INTERVAL_MS) then
        return
    end

    local resourceTypes = GetResourcePowerTypes()
    local healthPct = SafeGetPowerPctFromList(resourceTypes.health)
    local magickaPct = SafeGetPowerPctFromList(resourceTypes.magicka)
    local staminaPct = SafeGetPowerPctFromList(resourceTypes.stamina)
    local sampledAny = false

    if healthPct then
        resourceSamples.healthPct[#resourceSamples.healthPct + 1] = healthPct
        sampledAny = true
    end
    if magickaPct then
        resourceSamples.magickaPct[#resourceSamples.magickaPct + 1] = magickaPct
        sampledAny = true
    end
    if staminaPct then
        resourceSamples.staminaPct[#resourceSamples.staminaPct + 1] = staminaPct
        sampledAny = true
    end

    local pingMs = SafeGetLatencyMs()
    if pingMs ~= nil then
        local pingSamples = resourceSamples.pingMs or {}
        resourceSamples.pingMs = pingSamples
        pingSamples[#pingSamples + 1] = pingMs
        if resourceSamples.minPingMs == nil or pingMs < resourceSamples.minPingMs then
            resourceSamples.minPingMs = pingMs
        end
        if resourceSamples.maxPingMs == nil or pingMs > resourceSamples.maxPingMs then
            resourceSamples.maxPingMs = pingMs
        end

        local lastPing = resourceSamples.lastPingMs
        if lastPing ~= nil then
            local delta = pingMs - lastPing
            if delta <= -PING_DIP_DELTA_MS then
                resourceSamples.pingDipCount = (resourceSamples.pingDipCount or 0) + 1
            elseif delta >= PING_SPIKE_DELTA_MS then
                resourceSamples.pingSpikeCount = (resourceSamples.pingSpikeCount or 0) + 1
            end
        end

        if pingMs >= PING_HIGH_DELAY_MS then
            resourceSamples.highDelaySamples = (resourceSamples.highDelaySamples or 0) + 1
        end

        resourceSamples.lastPingMs = pingMs
        sampledAny = true
    end

    if sampledAny then
        resourceSamples.lastSampleMs = nowMs
    end

    -- Track absolute resource deltas: positive = regen, negative = drain.
    local hpCurr   = SafeGetCurrentPowerFromList(resourceTypes.health)
    local magCurr  = SafeGetCurrentPowerFromList(resourceTypes.magicka)
    local stamCurr = SafeGetCurrentPowerFromList(resourceTypes.stamina)
    local ultCurr  = SafeGetCurrentPowerFromList(resourceTypes.ultimate)

    local function AccumulateDelta(lastKey, regenKey, drainKey, current)
        if current == nil then return end
        local last = resourceSamples[lastKey]
        if last ~= nil then
            local delta = current - last
            if delta > 0 then
                resourceSamples[regenKey] = (resourceSamples[regenKey] or 0) + delta
            elseif delta < 0 then
                resourceSamples[drainKey] = (resourceSamples[drainKey] or 0) - delta
            end
        end
        resourceSamples[lastKey] = current
    end

    AccumulateDelta("lastAbsHealth",   "totalHealthRegen",   "totalHealthDrain",   hpCurr)
    AccumulateDelta("lastAbsMagicka",  "totalMagickaRegen",  "totalMagickaDrain",  magCurr)
    AccumulateDelta("lastAbsStamina",  "totalStaminaRegen",  "totalStaminaDrain",  stamCurr)
    AccumulateDelta("lastAbsUltimate", "totalUltimateGen",   "totalUltimateDrain", ultCurr)
end

function ConsoleMetrics:BuildFightSummaryFromFight(fight, nowMs)
    local duration = GetFightDurationSeconds(fight, nowMs)
    local totalDamage = fight.totalDamage or 0
    local totalHeal = fight.totalHeal or 0
    local totalTaken = fight.totalTaken or 0
    local hits = fight.hits or 0
    local crits = fight.crits or 0
    local dps = duration > 0 and (totalDamage / duration) or 0
    local hps = duration > 0 and (totalHeal / duration) or 0
    local critPct = hits > 0 and ((crits / hits) * 100) or 0

    local targetList = {}
    for _, target in pairs(fight.targetMap or {}) do
        local estimatedResistance, mitigationPct = EstimateTargetResistance(target)
        targetList[#targetList + 1] = {
            name = target.name,
            damage = target.damage,
            effective = target.effective,
            overflow = target.overflow,
            blocked = target.blocked,
            shielded = target.shielded,
            hits = target.hits,
            estimatedResistance = estimatedResistance,
            mitigationPct = mitigationPct,
        }
    end

    table.sort(targetList, function(a, b)
        return a.damage > b.damage
    end)

    -- Build pre-sorted lists once so live and historical views share identical ordering.
    local protectionSummary = BuildProtectionSummary(fight.protectionInfo, nowMs)
    local allEffectList = BuildTrackedEffectList(fight.allEffects, duration, nowMs)
    local majorMinorList = BuildTrackedEffectList(fight.majorMinorEffects, duration, nowMs)
    local setProcList = BuildTrackedEffectList(fight.setEffects, duration, nowMs)
    local resourceSamples = fight.resourceSamples or {}
    local healthResourceSummary = BuildResourceSampleSummary(resourceSamples.healthPct or {})
    local magickaResourceSummary = BuildResourceSampleSummary(resourceSamples.magickaPct or {})
    local staminaResourceSummary = BuildResourceSampleSummary(resourceSamples.staminaPct or {})
    local pingSampleSummary = BuildNumericSampleSummary(resourceSamples.pingMs or {})
    local sustainSummary = BuildSustainPerformanceSummary(magickaResourceSummary, staminaResourceSummary)
    local resourceSampleCount = math.max(healthResourceSummary.samples, magickaResourceSummary.samples, staminaResourceSummary.samples, pingSampleSummary.samples)
    local incomingSkillList = SortSkillEntries(fight.incomingSkillMap or {})
    local incomingSetDamageList = SortSkillEntries(fight.incomingSetDamageMap or {})
    local incomingLikelySetProcList = SortSkillEntries(fight.incomingLikelySetProcMap or {})

    return {
        startMs = fight.startMs,
        endMs = fight.endMs,
        duration = duration,
        dps = dps,
        hps = hps,
        totalDamage = totalDamage,
        totalOverflowDamage = fight.totalOverflowDamage or 0,
        totalBlockedDamage = fight.totalBlockedDamage or 0,
        totalShieldedDamage = fight.totalShieldedDamage or 0,
        totalHeal = totalHeal,
        totalOverflowHeal = fight.totalOverflowHeal or 0,
        totalTaken = totalTaken,
        totalIncomingOverflowDamage = fight.totalIncomingOverflowDamage or 0,
        totalIncomingBlockedDamage = fight.totalIncomingBlockedDamage or 0,
        totalIncomingShieldedDamage = fight.totalIncomingShieldedDamage or 0,
        critPct = critPct,
        skillList = SortSkillEntries(fight.skillMap or {}),
        healSkillList = SortSkillEntriesByHeal(fight.skillMap or {}),
        incomingSkillList = incomingSkillList,
        incomingSetDamageList = incomingSetDamageList,
        incomingLikelySetProcList = incomingLikelySetProcList,
        dotList = SortSkillEntries(fight.dotMap or {}),
        hotList = SortSkillEntriesByHeal(fight.hotMap or {}),
        targetList = targetList,
        peakDps = fight.peakDps or 0,
        peakHps = fight.peakHps or 0,
        topHealingMoments = CloneMoments(fight.topHealingMoments or {}),
        topMitigationMoments = CloneMoments(fight.topMitigationMoments or {}),
        allEffectList = allEffectList,
        majorMinorList = majorMinorList,
        setProcList = setProcList,
        protectionSummary = protectionSummary,
        inferredProtectionLabel = (fight.protectionInfo and fight.protectionInfo.currentLabel) or "No mitigation data",
        inferredProtectionConfidence = (fight.protectionInfo and fight.protectionInfo.confidence) or 0,
        inferredDrPct = (fight.protectionInfo and fight.protectionInfo.currentDrPct) or 0,
        resourceSummary = {
            sampleCount = resourceSampleCount,
            health = healthResourceSummary,
            magicka = magickaResourceSummary,
            stamina = staminaResourceSummary,
            sustain = sustainSummary,
            totalHealthRegen  = resourceSamples.totalHealthRegen  or 0,
            totalHealthDrain  = resourceSamples.totalHealthDrain  or 0,
            totalMagickaRegen = resourceSamples.totalMagickaRegen or 0,
            totalMagickaDrain = resourceSamples.totalMagickaDrain or 0,
            totalStaminaRegen = resourceSamples.totalStaminaRegen or 0,
            totalStaminaDrain = resourceSamples.totalStaminaDrain or 0,
            totalUltimateGen  = resourceSamples.totalUltimateGen  or 0,
            totalUltimateDrain = resourceSamples.totalUltimateDrain or 0,
            ping = {
                hasData = pingSampleSummary.hasData,
                samples = pingSampleSummary.samples,
                averageMs = pingSampleSummary.average,
                medianMs = pingSampleSummary.median,
                minMs = pingSampleSummary.min,
                maxMs = pingSampleSummary.max,
                dips = resourceSamples.pingDipCount or 0,
                spikes = resourceSamples.pingSpikeCount or 0,
                highDelaySamples = resourceSamples.highDelaySamples or 0,
                highDelayThresholdMs = PING_HIGH_DELAY_MS,
            },
        },
    }
end

function ConsoleMetrics:RecordTopHealingMoment(abilityId, abilityName, targetName, effectiveHeal, overflowHeal, isCrit)
    if not self.fight then
        return
    end

    local totalHeal = (effectiveHeal or 0) + (overflowHeal or 0)
    if totalHeal <= 0 then
        return
    end

    local critTag = isCrit and " [CRIT]" or ""
    local healHex = isCrit and COMBAT_COLOR_HEX.healCrit or COMBAT_COLOR_HEX.heal
    local overflowTag = (overflowHeal or 0) > 0 and string.format(" (+%s ovh)", ColorShort(overflowHeal, COMBAT_COLOR_HEX.overflow)) or ""
    AddTopMoment(self.fight.topHealingMoments, {
        value = totalHeal,
        abilityId = SafeAbilityId(abilityId),
        abilityName = abilityName,
        effectName = abilityName,
        label = string.format("+%s  %s%s", ColorShort(totalHeal, healHex), FormatAbilityIdentity(abilityName, abilityId), critTag),
        tooltip = string.format("Healed %s for %s%s | Ability: %s", targetName, NumberText(effectiveHeal or 0), overflowTag, FormatAbilityIdentity(abilityName, abilityId)),
    })
end

function ConsoleMetrics:RecordTopMitigationMoment(labelPrefix, actorName, reason, amount, abilityId, abilityName)
    if not self.fight or amount <= 0 then
        return
    end

    AddTopMoment(self.fight.topMitigationMoments, {
        value = amount,
        abilityId = SafeAbilityId(abilityId),
        abilityName = abilityName,
        effectName = abilityName,
        label = string.format("%s%s  %s (%s)", labelPrefix, ColorShort(amount, COMBAT_COLOR_HEX.mitigation), actorName, reason),
        tooltip = string.format("%s via %s", reason, FormatAbilityIdentity(abilityName, abilityId)),
    })
end

-- Central effect tracker used by the Buff Uptime panel.
-- It records all effects first, then derives focused subsets (Major/Minor and popular sets).
function ConsoleMetrics:TrackMajorMinorAndSets(nowMs, result, abilityId, abilityName, sourceIsPlayer, targetIsPlayer, didDamage, didHeal, totalValue)
    if not self.fight or not abilityName or abilityName == "" then
        return
    end

    local touchesPlayer = sourceIsPlayer or targetIsPlayer
    if not touchesPlayer then
        return
    end

    local gained = IsEffectGainedResult(result)
    local faded = IsEffectFadedResult(result)
    local lowerName = string.lower(abilityName)

    if gained or faded then
        local allEffectTrack = AcquireTrackedEffect(self.fight.allEffects, lowerName, abilityName, "Effect", abilityId, abilityName)
        if gained then
            StartTrackedEffect(allEffectTrack, nowMs)
        else
            StopTrackedEffect(allEffectTrack, nowMs)
        end
    end

    if IsMajorMinorEffectName(abilityName) then
        local category = string.find(lowerName, "major ", 1, true) == 1 and "Major" or "Minor"
        local majorMinorTrack = AcquireTrackedEffect(self.fight.majorMinorEffects, lowerName, abilityName, category, abilityId, abilityName)

        if gained then
            StartTrackedEffect(majorMinorTrack, nowMs)
        elseif faded then
            StopTrackedEffect(majorMinorTrack, nowMs)
        end

        if didDamage or didHeal then
            majorMinorTrack.procs = (majorMinorTrack.procs or 0) + 1
            majorMinorTrack.totalValue = (majorMinorTrack.totalValue or 0) + (totalValue or 0)
        end
    end

    local setMatch = self:MatchTrackedSet(abilityId, abilityName)
    if setMatch then
        local setKey = string.lower(setMatch.label)
        local setTrack = AcquireTrackedEffect(self.fight.setEffects, setKey, setMatch.label, setMatch.scene, abilityId, abilityName)

        if gained then
            StartTrackedEffect(setTrack, nowMs)
        elseif faded then
            StopTrackedEffect(setTrack, nowMs)
        end

        if didDamage or didHeal then
            setTrack.procs = (setTrack.procs or 0) + 1
            setTrack.totalValue = (setTrack.totalValue or 0) + (totalValue or 0)
        end
    end
end

function ConsoleMetrics:UpdateProtectionInference(nowMs)
    if not self.fight or not self.fight.protectionInfo then
        return
    end

    local snapshot = self:GetFightSnapshot()
    local topTarget = snapshot.targetList and snapshot.targetList[1] or nil
    local estimatedResistance = (topTarget and topTarget.estimatedResistance) or nil
    local hasData = estimatedResistance ~= nil
    local resistance = estimatedResistance or 0
    local drPct = hasData and Clamp((resistance / RESISTANCE_SCALE) * 100, 0, 50) or 0

    local info = self.fight.protectionInfo
    local alpha = Clamp(tonumber(self.saved.drSampleAlpha) or self.defaults.drSampleAlpha, 0.05, 0.85)
    if info.samples <= 0 then
        info.drEma = drPct
    else
        info.drEma = (alpha * drPct) + ((1 - alpha) * (info.drEma or drPct))
    end

    local inferredLabel, inferredKey, confidence = InferProtectionFromDr(info.drEma or drPct, hasData)

    local previousState = info.currentState or "unknown"
    local elapsed = 0
    if info.lastSampleMs and nowMs > info.lastSampleMs then
        elapsed = nowMs - info.lastSampleMs
    end
    if elapsed > 0 then
        info.stateMs[previousState] = (info.stateMs[previousState] or 0) + elapsed
    end

    info.currentState = inferredKey
    info.currentLabel = inferredLabel
    info.currentResistance = resistance
    info.currentDrPct = drPct
    info.confidence = confidence
    info.lastSampleMs = nowMs
    info.samples = (info.samples or 0) + 1
end

local function RuleToMatchResult(rule, safeId)
    return {
        label            = rule.label or string.format("Custom Set %d", safeId),
        scene            = NormalizeCustomSetScene(rule.scene),
        fromCustom       = not rule.fromPCT,
        fromPCT          = rule.fromPCT or false,
        cooldownDurationMs = rule.cooldownDurationMs,
        procType         = rule.procType,
        result           = rule.result,
        texture          = rule.texture,
        showFrame        = rule.showFrame,
        description      = rule.description,
        settingsColor    = rule.settingsColor,
    }
end

function ConsoleMetrics:MatchCustomSetRule(abilityId, abilityName)
    if not self.saved or type(self.saved.customSetRules) ~= "table" then
        return nil
    end

    local safeId = SafeAbilityId(abilityId)
    local lowerName = string.lower(abilityName or "")

    -- Prefer exact abilityId match first; check primary abilityId and all entries in abilityIds.
    if safeId > 0 then
        for i = 1, #self.saved.customSetRules do
            local rule = self.saved.customSetRules[i]
            -- Check primary stored ID.
            if SafeAbilityId(rule.abilityId) == safeId then
                return RuleToMatchResult(rule, safeId)
            end
            -- Check multi-ID list (PCT sets like Pirate Skeleton).
            if type(rule.abilityIds) == "table" then
                for k = 1, #rule.abilityIds do
                    if SafeAbilityId(rule.abilityIds[k]) == safeId then
                        return RuleToMatchResult(rule, safeId)
                    end
                end
            end
        end
    end

    if lowerName == "" then
        return nil
    end

    for i = 1, #self.saved.customSetRules do
        local rule = self.saved.customSetRules[i]
        local aliases = rule.aliases or BuildCustomAliasList(rule.abilityName)
        for j = 1, #aliases do
            local alias = aliases[j]
            if alias ~= "" and string.find(lowerName, alias, 1, true) ~= nil then
                return RuleToMatchResult(rule, SafeAbilityId(rule.abilityId))
            end
        end
    end

    return nil
end

function ConsoleMetrics:MatchTrackedSet(abilityId, abilityName)
    local custom = self:MatchCustomSetRule(abilityId, abilityName)
    if custom then
        return custom
    end
    return MatchPopularSet(abilityName)
end

function ConsoleMetrics:AddCustomSetRule(label, scene, abilityId, abilityName)
    if not self.saved then
        return false, "Settings are not initialized yet."
    end

    self.saved.customSetRules = self.saved.customSetRules or {}

    local cleanName = TrimText(abilityName)
    local cleanLabel = TrimText(label)
    local safeId = SafeAbilityId(abilityId)
    local normalizedScene = NormalizeCustomSetScene(scene)

    if cleanLabel == "" then
        if cleanName ~= "" then
            cleanLabel = cleanName
        elseif safeId > 0 then
            cleanLabel = string.format("Custom Set %d", safeId)
        else
            return false, "Add Custom Set: provide ability ID and/or ability name."
        end
    end

    if safeId <= 0 and cleanName == "" then
        return false, "Add Custom Set: provide ability ID and/or ability name."
    end

    local aliases = BuildCustomAliasList(cleanName)
    for i = 1, #self.saved.customSetRules do
        local existing = self.saved.customSetRules[i]
        local existingId = SafeAbilityId(existing.abilityId)
        local existingName = string.lower(TrimText(existing.abilityName))
        if safeId > 0 and existingId == safeId then
            return false, string.format("Custom set already exists for ability ID %d.", safeId)
        end
        if cleanName ~= "" and existingName ~= "" and existingName == string.lower(cleanName) then
            return false, string.format("Custom set already exists for ability name '%s'.", cleanName)
        end
    end

    self.saved.customSetRules[#self.saved.customSetRules + 1] = {
        label    = cleanLabel,
        scene    = normalizedScene,
        abilityId = safeId,
        abilityIds = { safeId },
        abilityName = cleanName,
        aliases  = aliases,
        fromCustom = true,
    }

    return true, string.format("Added custom set rule: %s (scene=%s, id=%d, name=%s)", cleanLabel, normalizedScene, safeId, cleanName ~= "" and cleanName or "n/a")
end

-- Import one full PvPCooldownTracker Data.Sets entry by set name key.
-- Handles id as number or array, carries all PCT fields verbatim.
function ConsoleMetrics:AddPCTSetEntry(setName, entry)
    if not self.saved then
        return false, "Settings not initialized."
    end

    self.saved.customSetRules = self.saved.customSetRules or {}

    local cleanLabel = TrimText(setName)
    if cleanLabel == "" then
        return false, "PCT entry has no set name."
    end

    -- Deduplicate by normalized label.
    local lowerLabel = string.lower(cleanLabel)
    for i = 1, #self.saved.customSetRules do
        if string.lower(TrimText(self.saved.customSetRules[i].label)) == lowerLabel then
            return false, string.format("Already have rule for '%s'.", cleanLabel)
        end
    end

    -- Normalise id: may be number or array of numbers.
    local primaryId = 0
    local allIds = {}
    if type(entry.id) == "table" then
        for _, v in ipairs(entry.id) do
            local sid = SafeAbilityId(v)
            if sid > 0 then
                allIds[#allIds + 1] = sid
            end
        end
        primaryId = allIds[1] or 0
    else
        primaryId = SafeAbilityId(entry.id)
        if primaryId > 0 then
            allIds[1] = primaryId
        end
    end

    -- Derive scene from procType (synergies/passives → PvE leaning; sets → PvP default).
    local scene = "PvP"
    if type(entry.procType) == "string" then
        local pt = string.lower(entry.procType)
        if pt == "synergy" or pt == "passive" then
            scene = "PvE"
        end
    end

    self.saved.customSetRules[#self.saved.customSetRules + 1] = {
        label              = cleanLabel,
        scene              = scene,
        abilityId          = primaryId,
        abilityIds         = allIds,
        abilityName        = "",
        aliases            = {},
        fromPCT            = true,
        -- Full PCT fields preserved:
        cooldownDurationMs = tonumber(entry.cooldownDurationMs),
        procType           = type(entry.procType) == "string" and entry.procType or nil,
        result             = tonumber(entry.result),
        texture            = type(entry.texture) == "string" and entry.texture or nil,
        showFrame          = entry.showFrame ~= false,
        description        = type(entry.description) == "string" and entry.description or nil,
        settingsColor      = type(entry.settingsColor) == "string" and entry.settingsColor or nil,
    }

    return true, string.format("Imported: %s (id=%d, cooldown=%sms)",
        cleanLabel, primaryId, tostring(tonumber(entry.cooldownDurationMs) or "?"))
end

function ConsoleMetrics:ImportSetsFromPvPCooldownTracker()
    if not self.saved then
        return 0, "Settings are not initialized yet."
    end

    -- Primary path: PvPCooldownTracker.Data.Sets is the canonical structured source.
    -- Each key is the set display name; value contains id, cooldownDurationMs, procType, result, etc.
    local g = type(_G) == "table" and _G or nil
    local pct = g and g.PvPCooldownTracker or nil
    local dataTable = pct and type(pct.Data) == "table" and pct.Data.Sets or nil

    if type(dataTable) ~= "table" then
        return 0, "PvPCooldownTracker.Data.Sets not found. Ensure PvPCooldownTracker is loaded before importing."
    end

    local addedCount = 0
    local skippedCount = 0
    local messages = {}

    for setName, entry in pairs(dataTable) do
        if type(setName) == "string" and type(entry) == "table" then
            local ok, msg = self:AddPCTSetEntry(setName, entry)
            if ok then
                addedCount = addedCount + 1
            else
                skippedCount = skippedCount + 1
                -- Only collect non-duplicate skip messages for debugging.
                if not string.find(msg, "Already have rule", 1, true) then
                    messages[#messages + 1] = msg
                end
            end
        end
    end

    if addedCount == 0 and skippedCount == 0 then
        return 0, "PvPCooldownTracker.Data.Sets is empty."
    end

    if addedCount == 0 then
        return 0, string.format("No new entries imported (%d already present).", skippedCount)
    end

    local summary = string.format("Imported %d set rules from PvPCooldownTracker", addedCount)
    if skippedCount > 0 then
        summary = summary .. string.format(" (%d already present, skipped)", skippedCount)
    end
    summary = summary .. "."

    if #messages > 0 then
        for i = 1, math.min(5, #messages) do
            self:Print("PCT import: " .. messages[i])
        end
    end

    return addedCount, summary
end

function ConsoleMetrics:PrintHelp()
    local helpLines = {
        "Commands:",
        "/cm view - Open the Console Metrics dialog.",
        "/cm close - Close the dialog immediately.",
        "/cm prev - View the previous saved fight.",
        "/cm next - View the next saved fight.",
        "/cm clear - Clear live fight data and all history.",
        "/cm savefight [name] - Save the currently viewed fight to a persistent slot.",
        "/cm loadfight <name> - Load one saved fight by name into history.",
        "/cm loadfightexact <name> - Load one saved fight by exact name only.",
        "/cm loadsaves - Load all saved fight slots into session fight history.",
        "/cm debugbuild - Print build snapshot debug details.",
        "/cm linkbuild - Pre-fill chat with a compact build summary to share.",
        "/cm dumpcpslottables - Dump confirmed Champion slottable skill IDs.",
        "/cm autoclear on|off - Toggle auto clear when a new fight starts.",
        "/cm autohide on|off - Toggle dialog auto close after combat.",
        "/cm inject - Retry Journal menu/keybind integration.",
        "/cm reset - Reset addon options to defaults.",
        "/cm dumpsets - Dump all game item sets (API) and session-observed ability IDs.",
        "/cm importpct - Import custom set rules from PvPCooldownTracker.",
        "/cm addset <label>|<scene>|<abilityId>|<abilityName> - Add custom set matcher.",
    }

    for i = 1, #helpLines do
        self:Print(helpLines[i])
    end
end

function ConsoleMetrics:RegisterLAMSettings()
    if not LibAddonMenu2 then
        return
    end

    local panelData = {
        type = "panel",
        name = "Console Metrics",
        displayName = "Console Metrics",
        author = "Vixen Hunny",
        version = self.version,
        registerForRefresh = true,
    }
    local sceneChoices = { "PvP", "PvE", "Custom" }
    local function NormalizeDraftAbilityId()
        local id = SafeAbilityId(self.saved.customSetDraftAbilityId)
        if id > 0 then
            return tostring(id)
        end
        return ""
    end
        local optionsTable = {
                {
                    type = "button",
                    name = "Open Console Metrics",
                    tooltip = "Opens the combat metrics dialog window",
                    func = function()
                        self:OpenFightViewDialog(true)
                    end,
                    width = "full",
                },
                {
                    type = "header",
                    name = "Dialog Options",
                },
                {
                    type = "checkbox",
                    name = "Auto Hide Dialog",
                    tooltip = "Automatically close the dialog after leaving combat",
                    getFunc = function()
                        return self.saved.dialogAutoHide
                    end,
                    setFunc = function(value)
                        self.saved.dialogAutoHide = value
                        self:ArmDialogAutoHide()
                    end,
                    default = self.defaults.dialogAutoHide,
                },
                {
                    type = "slider",
                    name = "Auto Hide Delay (seconds)",
                    tooltip = "How long to wait after combat ends before closing the dialog",
                    getFunc = function()
                        return self.saved.dialogAutoHideSeconds
                    end,
                    setFunc = function(value)
                        self.saved.dialogAutoHideSeconds = value
                        self:ArmDialogAutoHide()
                    end,
                    min = 3,
                    max = 120,
                    step = 1,
                    default = self.defaults.dialogAutoHideSeconds,
                },
                {
                    type = "checkbox",
                    name = "Auto Clear on Next Fight",
                    tooltip = "Clear displayed metrics when a new fight starts",
                    getFunc = function()
                        return self.saved.autoClearOnNextFight
                    end,
                    setFunc = function(value)
                        self.saved.autoClearOnNextFight = value
                    end,
                    default = self.defaults.autoClearOnNextFight,
                },
                {
                    type = "slider",
                    name = "Max Fight History",
                    tooltip = "Maximum number of previous fights to keep in history",
                    getFunc = function()
                        return self.saved.maxFightHistory
                    end,
                    setFunc = function(value)
                        self.saved.maxFightHistory = value
                    end,
                    min = 5,
                    max = 100,
                    step = 1,
                    default = self.defaults.maxFightHistory,
                },
                {
                    type = "slider",
                    name = "ML DR Learning Weight",
                    tooltip = "Higher values adapt faster to changes in inferred DR",
                    getFunc = function()
                        return math.floor((self.saved.drSampleAlpha or self.defaults.drSampleAlpha) * 100 + 0.5)
                    end,
                    setFunc = function(value)
                        self.saved.drSampleAlpha = Clamp(value / 100, 0.05, 0.85)
                    end,
                    min = 5,
                    max = 85,
                    step = 1,
                    default = math.floor(self.defaults.drSampleAlpha * 100 + 0.5),
                },
                {
                    type = "header",
                    name = "Custom Set Matching",
                },
                {
                    type = "description",
                    text = "Add custom set rules by ability ID/name and optionally import from PvPCooldownTracker.",
                    width = "full",
                },
                {
                    type = "editbox",
                    name = "Set Label",
                    tooltip = "Friendly label for this set entry in panel output.",
                    getFunc = function()
                        return self.saved.customSetDraftLabel or ""
                    end,
                    setFunc = function(value)
                        self.saved.customSetDraftLabel = TrimText(value)
                    end,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Set Scene",
                    tooltip = "Classification tag shown in set-proc rows.",
                    choices = sceneChoices,
                    getFunc = function()
                        return NormalizeCustomSetScene(self.saved.customSetDraftScene)
                    end,
                    setFunc = function(value)
                        self.saved.customSetDraftScene = NormalizeCustomSetScene(value)
                    end,
                    width = "half",
                },
                {
                    type = "editbox",
                    name = "Ability ID",
                    tooltip = "Exact match ability ID (optional, but recommended).",
                    getFunc = function()
                        return NormalizeDraftAbilityId()
                    end,
                    setFunc = function(value)
                        self.saved.customSetDraftAbilityId = TrimText(value)
                    end,
                    width = "half",
                },
                {
                    type = "editbox",
                    name = "Ability Name / Alias",
                    tooltip = "Name matcher. Comma-separated tokens are accepted as aliases.",
                    getFunc = function()
                        return self.saved.customSetDraftAbilityName or ""
                    end,
                    setFunc = function(value)
                        self.saved.customSetDraftAbilityName = TrimText(value)
                    end,
                    width = "full",
                },
                {
                    type = "button",
                    name = "Add Custom Set Rule",
                    tooltip = "Adds the current draft as a custom set matcher.",
                    func = function()
                        local abilityId = tonumber(self.saved.customSetDraftAbilityId)
                        local ok, message = self:AddCustomSetRule(
                            self.saved.customSetDraftLabel,
                            self.saved.customSetDraftScene,
                            abilityId,
                            self.saved.customSetDraftAbilityName
                        )
                        self:Print(message)
                        if ok then
                            self.saved.customSetDraftAbilityId = ""
                            self.saved.customSetDraftAbilityName = ""
                        end
                    end,
                    width = "half",
                },
                {
                    type = "button",
                    name = "Import PvPCooldownTracker Rules",
                    tooltip = "Scans PvPCooldownTracker tables and imports ability-based set rules.",
                    func = function()
                        local added, message = self:ImportSetsFromPvPCooldownTracker()
                        self:Print(message)
                        if added > 0 then
                            self:Print(string.format("Custom set rule count: %d", #(self.saved.customSetRules or {})))
                        end
                    end,
                    width = "half",
                },
                {
                    type = "button",
                    name = "Clear Custom Set Rules",
                    tooltip = "Removes all custom set rules added through settings/import.",
                    func = function()
                        self.saved.customSetRules = {}
                        self:Print("Cleared all custom set rules.")
                    end,
                    width = "half",
                },
            }

    LibAddonMenu2:RegisterAddonPanel("ConsoleMetricsPanel", panelData)
    LibAddonMenu2:RegisterOptionControls("ConsoleMetricsPanel", optionsTable)
end

function ConsoleMetrics:GetFightSnapshot()
    local nowMs = GetFrameTimeMilliseconds()
    if not self.fight then
        return self:BuildFightSummaryFromFight(NewFight(nowMs), nowMs)
    end

    return self:BuildFightSummaryFromFight(self.fight, nowMs)
end

function ConsoleMetrics:GetViewedFightSnapshot()
    if self.viewFightIndex >= 1 and self.viewFightIndex <= #self.fightHistory then
        return self.fightHistory[self.viewFightIndex], false
    end

    return self:GetFightSnapshot(), true
end

function ConsoleMetrics:GetBehaviorModel()
    local dpsValues = {}
    local hpsValues = {}
    local takenValues = {}
    local resistanceValues = {}

    local function AddSummary(summary)
        dpsValues[#dpsValues + 1] = summary.dps or 0
        hpsValues[#hpsValues + 1] = summary.hps or 0
        takenValues[#takenValues + 1] = summary.totalTaken or 0
        if summary.targetList then
            for j = 1, #summary.targetList do
                local resistance = summary.targetList[j].estimatedResistance
                if resistance ~= nil then
                    resistanceValues[#resistanceValues + 1] = math.max(0, resistance)
                end
            end
        end
    end

    for i = 1, #self.fightHistory do
        AddSummary(self.fightHistory[i])
    end

    local liveSummary = self:GetFightSnapshot()
    if liveSummary and (liveSummary.totalDamage > 0 or liveSummary.totalHeal > 0 or liveSummary.totalTaken > 0) then
        AddSummary(liveSummary)
    end

    if #dpsValues == 0 then
        return {
            samples = 0,
            predictedDps = 0,
            predictedHps = 0,
            predictedTaken = 0,
            predictedResistance = 0,
            predictedDrPct = 0,
            predictedProtectionLabel = "No mitigation data",
            predictedProtectionConfidence = 0,
            resistanceSamples = 0,
            volatilityPct = 0,
            pressureProfile = "Need completed fights for pressure profile",
            rhythmProfile = "Need completed fights for rhythm profile",
            hasHistory = false,
        }
    end

    local dpsMean = Mean(dpsValues)
    local dpsStd = StdDev(dpsValues, dpsMean)
    local volatility = dpsMean > 0 and (dpsStd / dpsMean) or 0

    local predictedDps = math.max(0, ExponentialAverage(dpsValues, 0.35) + LinearSlope(dpsValues))
    local predictedHps = math.max(0, ExponentialAverage(hpsValues, 0.35) + LinearSlope(hpsValues))
    local predictedTaken = math.max(0, ExponentialAverage(takenValues, 0.35) + LinearSlope(takenValues))
    local predictedResistance = Mean(resistanceValues)
    if #resistanceValues > 0 then
        predictedResistance = math.max(0, ExponentialAverage(resistanceValues, 0.35) + LinearSlope(resistanceValues))
        predictedResistance = Clamp(predictedResistance, 0, RESISTANCE_CAP)
    end

    local predictedDrPct = Clamp((predictedResistance / RESISTANCE_SCALE) * 100, 0, 50)
    local predictedProtectionLabel, _, predictedProtectionConfidence = InferProtectionFromDr(predictedDrPct, #resistanceValues > 0)

    local pressureProfile = "Balanced pressure"
    if predictedTaken > (predictedDps * 0.8) then
        pressureProfile = "High incoming pressure"
    elseif predictedTaken < (predictedDps * 0.25) then
        pressureProfile = "Low incoming pressure"
    end

    local rhythmProfile = volatility > 0.35 and "Bursty fight rhythm" or "Stable fight rhythm"

    return {
        samples = #dpsValues,
        predictedDps = predictedDps,
        predictedHps = predictedHps,
        predictedTaken = predictedTaken,
        predictedResistance = predictedResistance,
        predictedDrPct = predictedDrPct,
        predictedProtectionLabel = predictedProtectionLabel,
        predictedProtectionConfidence = predictedProtectionConfidence,
        resistanceSamples = #resistanceValues,
        volatilityPct = volatility * 100,
        pressureProfile = pressureProfile,
        rhythmProfile = rhythmProfile,
        hasHistory = true,
    }
end

function ConsoleMetrics:AddCurrentFightToHistory()
    if not self.fight then
        return
    end

    local nowMs = GetFrameTimeMilliseconds()
    local summary = self:BuildFightSummaryFromFight(self.fight, nowMs)
    if summary.totalDamage <= 0 and summary.totalHeal <= 0 and summary.totalTaken <= 0 then
        return
    end

    self.fightHistory[#self.fightHistory + 1] = summary

    local maxHistory = tonumber(self.saved.maxFightHistory) or self.defaults.maxFightHistory
    while #self.fightHistory > maxHistory do
        table.remove(self.fightHistory, 1)
    end

    self.viewFightIndex = #self.fightHistory
end

function ConsoleMetrics:StepFightView(step)
    if #self.fightHistory == 0 then
        self.viewFightIndex = 0
        return false
    end

    if self.viewFightIndex == 0 then
        if step < 0 then
            self.viewFightIndex = #self.fightHistory
        else
            self.viewFightIndex = 1
        end
    else
        self.viewFightIndex = self.viewFightIndex + step
        if self.viewFightIndex < 1 then
            self.viewFightIndex = #self.fightHistory
        elseif self.viewFightIndex > #self.fightHistory then
            self.viewFightIndex = 1
        end
    end

    return true
end

function ConsoleMetrics:ResetFightData(keepHistory)
    local nowMs = GetFrameTimeMilliseconds()
    self.fight = NewFight(nowMs)
    self.hideAtMs = nil
    self.viewFightIndex = 0
    self.scrollEntries = {}

    if not keepHistory then
        self.fightHistory = {}
    end

    if self.ui.root then
        self.ui.root:SetHidden(true)
    end

    self:RefreshScroll()
    self:UpdateMetrics()
end

function ConsoleMetrics:SaveViewedFight()
    local snapshot = self:GetViewedFightSnapshot()
    if not snapshot then
        return false, "No fight data to save."
    end
    if (snapshot.totalDamage or 0) <= 0 and (snapshot.totalHeal or 0) <= 0 and (snapshot.totalTaken or 0) <= 0 then
        return false, "Fight has no data worth saving."
    end
    local maxSaves = tonumber(self.saved.maxSavedFights) or self.defaults.maxSavedFights
    if #self.saved.savedFights >= maxSaves then
        return false, string.format("Saves full (%d/%d). Delete a save slot first.", #self.saved.savedFights, maxSaves)
    end

    local requestedLabel = TrimText((self.saved and self.saved.saveFightDraftName) or "")
    local autoLabel = requestedLabel == ""
    local label = autoLabel and BuildDefaultFightSaveName(snapshot, #self.saved.savedFights + 1) or requestedLabel
    snapshot.savedLabel = label
    self.saved.savedFights[#self.saved.savedFights + 1] = {
        label = label,
        autoLabel = autoLabel,
        snapshot = snapshot,
    }
    return true, string.format("Fight saved: %s", label)
end

function ConsoleMetrics:DeleteSavedFight(index)
    if type(index) ~= "number" or index < 1 or index > #self.saved.savedFights then
        return false, "Invalid save slot."
    end
    local removedLabel = self.saved.savedFights[index].label or string.format("Slot %d", index)
    table.remove(self.saved.savedFights, index)
    -- Re-label only auto-generated entries so custom names remain unchanged.
    for i = 1, #self.saved.savedFights do
        local entry = self.saved.savedFights[i]
        if entry and entry.autoLabel and type(entry.snapshot) == "table" then
            entry.label = BuildDefaultFightSaveName(entry.snapshot, i)
            entry.snapshot.savedLabel = entry.label
        end
    end
    return true, string.format("Deleted: %s", removedLabel)
end

function ConsoleMetrics:LoadSavedFightIntoHistory(index)
    local entry = self.saved.savedFights and self.saved.savedFights[index]
    if not entry or type(entry.snapshot) ~= "table" then
        return false, "Invalid or empty save slot."
    end
    self.fightHistory[#self.fightHistory + 1] = entry.snapshot
    local maxHistory = tonumber(self.saved.maxFightHistory) or self.defaults.maxFightHistory
    while #self.fightHistory > maxHistory do
        table.remove(self.fightHistory, 1)
    end
    self.viewFightIndex = #self.fightHistory
    return true, string.format("Loaded: %s (history slot %d/%d)", entry.label, self.viewFightIndex, #self.fightHistory)
end

function ConsoleMetrics:LoadSavedFightIntoHistoryByName(rawName)
    local query = TrimText(rawName)
    if query == "" then
        return false, "Provide a saved fight name."
    end

    local saves = self.saved and self.saved.savedFights or nil
    if type(saves) ~= "table" or #saves == 0 then
        return false, "No saved fights available."
    end

    local lowerQuery = string.lower(query)
    local exactIndex = nil
    local partialMatches = {}

    for i = 1, #saves do
        local entry = saves[i]
        local label = TrimText(entry and entry.label or "")
        local lowerLabel = string.lower(label)

        if label ~= "" then
            if lowerLabel == lowerQuery then
                exactIndex = i
                break
            end
            if string.find(lowerLabel, lowerQuery, 1, true) ~= nil then
                partialMatches[#partialMatches + 1] = i
            end
        end
    end

    if exactIndex then
        return self:LoadSavedFightIntoHistory(exactIndex)
    end

    if #partialMatches == 1 then
        return self:LoadSavedFightIntoHistory(partialMatches[1])
    end

    if #partialMatches > 1 then
        local names = {}
        for i = 1, math.min(5, #partialMatches) do
            names[#names + 1] = saves[partialMatches[i]].label
        end
        local suffix = #partialMatches > 5 and "..." or ""
        return false, string.format("Multiple saved fights match '%s': %s%s", query, table.concat(names, " | "), suffix)
    end

    return false, string.format("Saved fight '%s' not found.", query)
end

function ConsoleMetrics:LoadSavedFightIntoHistoryByExactName(rawName)
    local query = TrimText(rawName)
    if query == "" then
        return false, "Provide a saved fight name."
    end

    local saves = self.saved and self.saved.savedFights or nil
    if type(saves) ~= "table" or #saves == 0 then
        return false, "No saved fights available."
    end

    local lowerQuery = string.lower(query)
    for i = 1, #saves do
        local entry = saves[i]
        local label = TrimText(entry and entry.label or "")
        if label ~= "" and string.lower(label) == lowerQuery then
            return self:LoadSavedFightIntoHistory(i)
        end
    end

    return false, string.format("Exact saved fight '%s' not found.", query)
end

function ConsoleMetrics:FindCustomSetRuleByLabel(label)
    if type(label) ~= "string" or label == "" then
        return nil
    end
    if not self.saved or type(self.saved.customSetRules) ~= "table" then
        return nil
    end

    local lowerLabel = string.lower(TrimText(label))
    for i = 1, #self.saved.customSetRules do
        local rule = self.saved.customSetRules[i]
        if type(rule) == "table" and string.lower(TrimText(rule.label or "")) == lowerLabel then
            return rule
        end
    end

    return nil
end

function ConsoleMetrics:BuildProcTimerSnapshot(nowMs)
    local entries = {}
    local seen = {}
    local currentMs = nowMs
    if type(currentMs) ~= "number" then
        if type(GetGameTimeMilliseconds) == "function" then
            currentMs = GetGameTimeMilliseconds()
        else
            currentMs = GetFrameTimeMilliseconds()
        end
    end

    local g = type(_G) == "table" and _G or nil
    local pctData = g and g.PvPCooldownTracker and g.PvPCooldownTracker.Data and g.PvPCooldownTracker.Data.Sets or nil
    local equippedSets = BuildEquippedSetSummary()

    local function AddEntry(label, equippedInfo)
        if type(label) ~= "string" or label == "" then
            return
        end

        local lowerLabel = string.lower(label)
        if seen[lowerLabel] then
            return
        end

        local rule = self:FindCustomSetRuleByLabel(label)
        local pctEntry = pctData and pctData[label] or nil
        local track = self.fight and self.fight.setEffects and self.fight.setEffects[lowerLabel] or nil
        if not rule and not pctEntry and not track then
            return
        end

        seen[lowerLabel] = true
        local cooldownMs = tonumber((pctEntry and pctEntry.cooldownDurationMs) or (rule and rule.cooldownDurationMs)) or 0
        local onCooldown = pctEntry and pctEntry.onCooldown or false
        local procTimeMs = tonumber(pctEntry and pctEntry.timeOfProc) or 0
        local remainingMs = 0
        if onCooldown and cooldownMs > 0 and procTimeMs > 0 then
            remainingMs = math.max(0, (procTimeMs + cooldownMs) - currentMs)
        end

        local stateText = "Ready"
        if track and track.activeSinceMs then
            if remainingMs > 0 then
                stateText = string.format("Active | Ready %.1fs", remainingMs / 1000)
            else
                stateText = "Active"
            end
        elseif remainingMs > 0 then
            stateText = string.format("Ready %.1fs", remainingMs / 1000)
        end

        entries[#entries + 1] = {
            label = label,
            stateText = stateText,
            cooldownMs = cooldownMs,
            remainingMs = remainingMs,
            numEquipped = equippedInfo and equippedInfo.numEquipped or 0,
            maxEquipped = equippedInfo and equippedInfo.maxEquipped or 0,
            slots = equippedInfo and equippedInfo.slots or {},
            fromPCT = pctEntry ~= nil,
            fromCustomRule = rule ~= nil,
        }
    end

    for i = 1, #equippedSets do
        AddEntry(equippedSets[i].setName, equippedSets[i])
    end

    for i = 1, #(self.saved and self.saved.customSetRules or {}) do
        local rule = self.saved.customSetRules[i]
        if type(rule) == "table" and type(rule.label) == "string" and rule.label ~= "" then
            AddEntry(rule.label, nil)
        end
    end

    table.sort(entries, function(a, b)
        local function Rank(entry)
            if string.find(entry.stateText or "", "Active", 1, true) ~= nil then
                return 1
            end
            if (entry.remainingMs or 0) > 0 then
                return 2
            end
            return 3
        end

        local rankA = Rank(a)
        local rankB = Rank(b)
        if rankA == rankB then
            return tostring(a.label) < tostring(b.label)
        end
        return rankA < rankB
    end)

    return entries
end

function ConsoleMetrics:PopulateFightViewDialog(dialog)
    local snapshot, isLive = self:GetViewedFightSnapshot()
    local behavior = self:GetBehaviorModel()
    local panel = self.dialogPanel or "main"
    dialog:Clear()

    local function AddScrollableStatLine(text, tooltip)
        dialog:AddSetting({
            type = LibHarvensAddonSettings.ST_BUTTON,
            label = text,
            tooltip = tooltip or text,
            clickHandler = function()
            end,
        })
    end

    local function RefreshDialog()
        self:PopulateFightViewDialog(dialog)
        dialog:Show()
        self:ArmDialogAutoHide()
    end

    local function AddActionButton(label, tooltip, action, disable)
        dialog:AddSetting({
            type = LibHarvensAddonSettings.ST_BUTTON,
            label = label,
            tooltip = tooltip,
            clickHandler = function()
                action()
                RefreshDialog()
            end,
            disable = disable,
        })
    end

    local function AddBackButton()
        AddActionButton(
            "Back",
            "Return to the main panel",
            function()
                self.dialogPanel = "main"
            end
        )
    end

    local function AddCloseButton()
        dialog:AddSetting({
            type = LibHarvensAddonSettings.ST_BUTTON,
            label = "Close",
            tooltip = "Close fight data dialog",
            clickHandler = function()
                self:CloseFightViewDialog(false, "button")
            end,
        })
    end

    local function FormatMs(ms)
        return string.format("%.1fs", (ms or 0) / 1000)
    end

    local viewingText = isLive and "Live" or string.format("Fight %d/%d", self.viewFightIndex, #self.fightHistory)
    if not isLive and type(snapshot.savedLabel) == "string" and snapshot.savedLabel ~= "" then
        viewingText = snapshot.savedLabel
    end

    if panel == "main" then
        dialog:AddSetting({
            type = LibHarvensAddonSettings.ST_SECTION,
            label = string.format("Console Metrics Main (%s)", viewingText),
            tooltip = "Choose a panel for detailed breakdowns",
        })

        AddScrollableStatLine(string.format("Duration: %.1fs", snapshot.duration), "Current viewed fight duration")
        AddScrollableStatLine(string.format("DPS: %s", ShortNumber(snapshot.dps)), "Current viewed fight DPS")
        AddScrollableStatLine(string.format("HPS: %s", ShortNumber(snapshot.hps)), "Current viewed fight HPS")
        AddScrollableStatLine(string.format("Predicted Resistance: %s", NumberText(behavior.predictedResistance or 0)), "ML-lite resistance estimate")
        AddScrollableStatLine(string.format("All Effects Tracked: %d", #(snapshot.allEffectList or {})), "Unique effects seen in combat state changes")
        AddScrollableStatLine(string.format("Major/Minor Effects Tracked: %d", #(snapshot.majorMinorList or {})), "Unique Major and Minor effects seen this fight")
        AddScrollableStatLine(string.format("Popular Sets Tracked: %d", #(snapshot.setProcList or {})), "Unique popular PvE/PvP sets seen this fight")

        AddActionButton("Previous Fight", "Cycle to previous fight in history", function()
            self:StepFightView(-1)
        end, function()
            return #self.fightHistory == 0
        end)
        AddActionButton("Next Fight", "Cycle to next fight in history", function()
            self:StepFightView(1)
        end, function()
            return #self.fightHistory == 0
        end)
        AddActionButton("View Live Fight", "Return to current live fight view", function()
            self.viewFightIndex = 0
        end)

        AddActionButton("Open Overview Panel", "General fight totals and timeline controls", function()
            self.dialogPanel = "overview"
        end)
        AddActionButton("Open Resource Panel", "Fight resource averages, medians, and sustain profile", function()
            self.dialogPanel = "resources"
        end)
        AddActionButton("Open Mitigation/Healing Panel", "Mitigation totals and top moments", function()
            self.dialogPanel = "mitigation"
        end)
        AddActionButton("Open Resistance/DR Panel", "Resistance, DR, and inferred protections", function()
            self.dialogPanel = "resistance"
        end)
        AddActionButton("Open Buff Uptime Panel", "All Major/Minor uptimes plus popular PvE/PvP set procs", function()
            self.dialogPanel = "buffs"
        end)
        AddActionButton("Open Skills Panel", "Top damage and healing moments", function()
            self.dialogPanel = "skills"
        end)
        AddActionButton("Open Build Snapshot Panel", "Current front/back bars, equipped loadout, and boon snapshot", function()
            self.dialogPanel = "build"
        end)
        AddActionButton("Open ML Model Panel", "Prediction model outputs and confidence", function()
            self.dialogPanel = "behavior"
        end)
        AddActionButton("Open Formula Panel", "ESO stat math reference and addon equations", function()
            self.dialogPanel = "formulas"
        end)
        AddActionButton("Open Save Fight Panel", "Name the current fight and save it into a persistent slot", function()
            if TrimText(self.saved.saveFightDraftName or "") == "" then
                self.saved.saveFightDraftName = BuildDefaultFightSaveName(snapshot, #self.saved.savedFights + 1)
            end
            self.dialogPanel = "save"
        end)
        AddActionButton("Open Saved Fights Panel", string.format("Save and load fights across sessions (%d saved)", #self.saved.savedFights), function()
            self.dialogPanel = "saves"
        end)
        AddActionButton("Open Options Panel", "Toggles, clear, and help explanations", function()
            self.dialogPanel = "options"
        end)

        AddCloseButton()
        return
    end

    if panel == "overview" then
        dialog:AddSetting({
            type = LibHarvensAddonSettings.ST_SECTION,
            label = string.format("Overview Panel (%s)", viewingText),
            tooltip = "Overall fight statistics and timeline",
        })

        local overviewLines = {
            string.format("Duration: %.1fs", snapshot.duration),
            string.format("DPS: %s", ShortNumber(snapshot.dps)),
            string.format("HPS: %s", ShortNumber(snapshot.hps)),
            string.format("Damage Done: %s", NumberText(snapshot.totalDamage)),
            string.format("Healing Done: %s", NumberText(snapshot.totalHeal)),
            string.format("Damage Taken: %s", NumberText(snapshot.totalTaken)),
            string.format("Crit Rate: %.1f%%", snapshot.critPct),
            string.format("Peak DPS: %s", ShortNumber(snapshot.peakDps or 0)),
            string.format("Peak HPS: %s", ShortNumber(snapshot.peakHps or 0)),
        }
        for i = 1, #overviewLines do
            AddScrollableStatLine(overviewLines[i], "Overview statistic")
        end

        AddActionButton("Previous Fight", "Cycle to previous fight in history", function()
            self:StepFightView(-1)
        end, function()
            return #self.fightHistory == 0
        end)
        AddActionButton("Next Fight", "Cycle to next fight in history", function()
            self:StepFightView(1)
        end, function()
            return #self.fightHistory == 0
        end)
        AddActionButton("View Live Fight", "Return to current live fight view", function()
            self.viewFightIndex = 0
        end)

        AddBackButton()
        AddCloseButton()
        return
    end

    if panel == "save" then
        dialog:AddSetting({
            type = LibHarvensAddonSettings.ST_SECTION,
            label = string.format("Save Fight Panel (%s)", viewingText),
            tooltip = "Give the current viewed fight a custom name, then persist it across sessions.",
        })

        dialog:AddSetting({
            type = LibHarvensAddonSettings.ST_EDIT,
            label = "Fight Save Name",
            tooltip = "Enter any name you want for this saved fight.",
            getFunction = function()
                return self.saved.saveFightDraftName or ""
            end,
            setFunction = function(value)
                self.saved.saveFightDraftName = TrimText(value)
            end,
            maxChars = 80,
        })

        AddScrollableStatLine(string.format("Preview Duration: %.1fs", snapshot.duration or 0), "Current viewed fight duration.")
        AddScrollableStatLine(string.format("Preview DPS/HPS: %s / %s", ShortNumber(snapshot.dps or 0), ShortNumber(snapshot.hps or 0)), "Current viewed fight throughput preview.")
        AddScrollableStatLine(string.format("Preview Totals: %s dmg / %s heal / %s taken", ShortNumber(snapshot.totalDamage or 0), ShortNumber(snapshot.totalHeal or 0), ShortNumber(snapshot.totalTaken or 0)), "What will be stored into the saved slot.")

        AddActionButton("Use Auto Name", "Generate the default slot label from this fight's summary.", function()
            self.saved.saveFightDraftName = BuildDefaultFightSaveName(snapshot, #self.saved.savedFights + 1)
        end)
        AddActionButton("Clear Draft Name", "Clear the custom fight name and fall back to auto-name on save.", function()
            self.saved.saveFightDraftName = ""
        end)
        AddActionButton("Save Viewed Fight", "Persist this fight using the current draft name or auto-name if blank.", function()
            local ok, msg = self:SaveViewedFight()
            self:Print(msg)
            if ok then
                self.dialogPanel = "saves"
            end
        end)

        AddBackButton()
        AddCloseButton()
        return
    end

    if panel == "resources" then
        dialog:AddSetting({
            type = LibHarvensAddonSettings.ST_SECTION,
            label = string.format("Resource Panel (%s)", viewingText),
            tooltip = "Fight-duration average and median resource values with sustain profile",
        })

        local resourceSummary = snapshot.resourceSummary or {}
        local hpStats = resourceSummary.health or {}
        local magStats = resourceSummary.magicka or {}
        local stamStats = resourceSummary.stamina or {}
        local sustainStats = resourceSummary.sustain or {}
        local sampleCount = resourceSummary.sampleCount or 0

        AddScrollableStatLine(
            string.format("Samples: %d", sampleCount),
            string.format("Resource samples are recorded every %.1fs during combat.", RESOURCE_SAMPLE_INTERVAL_MS / 1000)
        )

        local rpt = GetResourcePowerTypes()
        local hpMax = SafeGetMaxPowerFromList(rpt.health) or 0
        local magMax = SafeGetMaxPowerFromList(rpt.magicka) or 0
        local stamMax = SafeGetMaxPowerFromList(rpt.stamina) or 0

        local function AddResourceSustainLine(label, stats, maxValue, colorHex)
            if not stats.hasData then
                AddScrollableStatLine(
                    string.format("%s Avg/Median: n/a", label),
                    "No fight-duration samples available for this resource yet."
                )
                return
            end

            local avgPctText = ColorText(string.format("%.1f%%", stats.averagePct or 0), colorHex)
            local medPctText = ColorText(string.format("%.1f%%", stats.medianPct or 0), colorHex)
            if maxValue and maxValue > 0 then
                local avgValue = (stats.averagePct or 0) * maxValue / 100
                local medValue = (stats.medianPct or 0) * maxValue / 100
                AddScrollableStatLine(
                    string.format("%s Avg/Median: %s/%s (%s/%s)", label, NumberText(avgValue), NumberText(medValue), avgPctText, medPctText),
                    string.format("Fight sustain trend for %s based on %d total samples.", label, sampleCount)
                )
                return
            end

            AddScrollableStatLine(
                string.format("%s Avg/Median: %s/%s", label, avgPctText, medPctText),
                string.format("Fight sustain trend for %s based on %d total samples.", label, sampleCount)
            )
        end

        AddResourceSustainLine("Health", hpStats, hpMax, COMBAT_COLOR_HEX.heal)
        AddResourceSustainLine("Magicka", magStats, magMax, COMBAT_COLOR_HEX.summary)
        AddResourceSustainLine("Stamina", stamStats, stamMax, COMBAT_COLOR_HEX.damage)

        if sustainStats.hasData then
            local sustainHex = COMBAT_COLOR_HEX.heal
            if sustainStats.label == "Pressured" then
                sustainHex = COMBAT_COLOR_HEX.summary
            elseif sustainStats.label == "Critical" then
                sustainHex = COMBAT_COLOR_HEX.taken
            elseif sustainStats.label == "Strong" then
                sustainHex = COMBAT_COLOR_HEX.healCrit
            end

            AddScrollableStatLine(
                string.format(
                    "Sustain Avg/Median: %s/%s (%s)",
                    ColorText(string.format("%.1f%%", sustainStats.averagePct or 0), sustainHex),
                    ColorText(string.format("%.1f%%", sustainStats.medianPct or 0), sustainHex),
                    ColorText(sustainStats.label or "Stable", sustainHex)
                ),
                "Sustain score uses average Magicka/Stamina fight percentages across sampled combat time."
            )
        else
            AddScrollableStatLine(
                "Sustain Avg/Median: n/a",
                "No Magicka/Stamina sampling data yet. Enter combat to build sustain history."
            )
        end

        -- Regen / Drain / Ultimate Gen section
        dialog:AddSetting({
            type = LibHarvensAddonSettings.ST_SECTION,
            label = "Regen / Drain / Ultimate Gen",
            tooltip = "Cumulative resource gains (regen) and spends (drain) sampled each second during combat.",
        })

        local fightDuration = snapshot.duration or 0
        local rsm = resourceSummary

        local function AddRegenDrainLine(label, totalRegen, totalDrain, colorRegen, colorDrain)
            local regenPs = fightDuration > 0 and (totalRegen / fightDuration) or 0
            local drainPs = fightDuration > 0 and (totalDrain / fightDuration) or 0
            AddScrollableStatLine(
                string.format("%s Regen/Drain: %s/%s (%s/%s)",
                    label,
                    ColorText(NumberText(math.floor(totalRegen)), colorRegen),
                    ColorText(NumberText(math.floor(totalDrain)), colorDrain),
                    ColorText(string.format("%.1f/s", regenPs), colorRegen),
                    ColorText(string.format("%.1f/s", drainPs), colorDrain)
                ),
                string.format("%s: +%s total regen | -%s total drain over %.1fs (%.1f/s regen, %.1f/s drain).",
                    label, NumberText(math.floor(totalRegen)), NumberText(math.floor(totalDrain)), fightDuration, regenPs, drainPs)
            )
        end

        local hpR,  hpD  = rsm.totalHealthRegen  or 0, rsm.totalHealthDrain  or 0
        local magR, magD = rsm.totalMagickaRegen or 0, rsm.totalMagickaDrain or 0
        local stR,  stD  = rsm.totalStaminaRegen or 0, rsm.totalStaminaDrain or 0
        local ultG, ultD = rsm.totalUltimateGen  or 0, rsm.totalUltimateDrain or 0

        if hpR > 0 or hpD > 0 then
            AddRegenDrainLine("Health",   hpR,  hpD,  COMBAT_COLOR_HEX.heal,    COMBAT_COLOR_HEX.taken)
        else
            AddScrollableStatLine("Health Regen/Drain: n/a", "No health regen/drain data yet.")
        end
        if magR > 0 or magD > 0 then
            AddRegenDrainLine("Magicka", magR, magD, COMBAT_COLOR_HEX.summary, COMBAT_COLOR_HEX.taken)
        else
            AddScrollableStatLine("Magicka Regen/Drain: n/a", "No magicka regen/drain data yet.")
        end
        if stR > 0 or stD > 0 then
            AddRegenDrainLine("Stamina", stR,  stD,  COMBAT_COLOR_HEX.damage,  COMBAT_COLOR_HEX.taken)
        else
            AddScrollableStatLine("Stamina Regen/Drain: n/a", "No stamina regen/drain data yet.")
        end

        local ultGenPs = fightDuration > 0 and (ultG / fightDuration) or 0
        if ultG > 0 or ultD > 0 then
            AddScrollableStatLine(
                string.format("Ultimate Gen/Spend: %s/%s (%s)",
                    ColorText(NumberText(math.floor(ultG)), COMBAT_COLOR_HEX.summary),
                    ColorText(NumberText(math.floor(ultD)), COMBAT_COLOR_HEX.taken),
                    ColorText(string.format("%.2f/s", ultGenPs), COMBAT_COLOR_HEX.summary)
                ),
                string.format("Ultimate: +%s generated | -%s spent over %.1fs (%.2f gen/s).",
                    NumberText(math.floor(ultG)), NumberText(math.floor(ultD)), fightDuration, ultGenPs)
            )
        else
            AddScrollableStatLine("Ultimate Gen/Spend: n/a", "No ultimate generation data yet.")
        end

        dialog:AddSetting({
            type = LibHarvensAddonSettings.ST_SECTION,
            label = "Delay / Ping",
            tooltip = "Latency sampled each second during combat. Tracks dips, spikes, and high-delay windows.",
        })

        local pingStats = resourceSummary.ping or {}
        if pingStats.hasData then
            local function PingMsText(value)
                return NumberText(math.floor((value or 0) + 0.5))
            end

            local sampleTotal = pingStats.samples or 0
            local highDelay = pingStats.highDelaySamples or 0
            local highDelayPct = sampleTotal > 0 and ((highDelay / sampleTotal) * 100) or 0

            AddScrollableStatLine(
                string.format("Ping Avg/Median: %s/%s ms",
                    ColorText(PingMsText(pingStats.averageMs), COMBAT_COLOR_HEX.summary),
                    ColorText(PingMsText(pingStats.medianMs), COMBAT_COLOR_HEX.summary)
                ),
                "Average and median ping sampled during this fight."
            )

            AddScrollableStatLine(
                string.format("Ping Min/Max: %s/%s ms",
                    ColorText(PingMsText(pingStats.minMs), COMBAT_COLOR_HEX.heal),
                    ColorText(PingMsText(pingStats.maxMs), COMBAT_COLOR_HEX.taken)
                ),
                "Lowest and highest ping observed in combat samples."
            )

            AddScrollableStatLine(
                string.format("Ping Dips/Spikes: %s/%s",
                    ColorText(NumberText(pingStats.dips or 0), COMBAT_COLOR_HEX.heal),
                    ColorText(NumberText(pingStats.spikes or 0), COMBAT_COLOR_HEX.taken)
                ),
                string.format("Dip: ping dropped by >= %dms between samples. Spike: ping rose by >= %dms.", PING_DIP_DELTA_MS, PING_SPIKE_DELTA_MS)
            )

            AddScrollableStatLine(
                string.format("High Delay Samples: %s/%s (%.1f%% >= %dms)",
                    ColorText(NumberText(highDelay), COMBAT_COLOR_HEX.taken),
                    NumberText(sampleTotal),
                    highDelayPct,
                    pingStats.highDelayThresholdMs or PING_HIGH_DELAY_MS
                ),
                "How often ping exceeded the configured high-delay threshold in this fight."
            )
        else
            AddScrollableStatLine("Ping Avg/Median: n/a", "Latency API unavailable in this context or no ping samples yet.")
        end

        AddBackButton()
        AddCloseButton()
        return
    end

    if panel == "mitigation" then
        dialog:AddSetting({
            type = LibHarvensAddonSettings.ST_SECTION,
            label = "Mitigation / Healing Panel",
            tooltip = "Incoming/outgoing mitigation with top moments",
        })

        local outgoingMitigated = (snapshot.totalBlockedDamage or 0) + (snapshot.totalShieldedDamage or 0)
        local incomingMitigated = (snapshot.totalIncomingBlockedDamage or 0) + (snapshot.totalIncomingShieldedDamage or 0)
        local mitigationLines = {
            string.format("Outgoing Mitigated: %s", NumberText(outgoingMitigated)),
            string.format("Incoming Mitigated: %s", NumberText(incomingMitigated)),
            string.format("Outgoing Blocked: %s", NumberText(snapshot.totalBlockedDamage or 0)),
            string.format("Outgoing Shielded: %s", NumberText(snapshot.totalShieldedDamage or 0)),
            string.format("Incoming Blocked: %s", NumberText(snapshot.totalIncomingBlockedDamage or 0)),
            string.format("Incoming Shielded: %s", NumberText(snapshot.totalIncomingShieldedDamage or 0)),
            string.format("Overflow Damage: %s", NumberText(snapshot.totalOverflowDamage or 0)),
            string.format("Overflow Healing: %s", NumberText(snapshot.totalOverflowHeal or 0)),
        }
        for i = 1, #mitigationLines do
            AddScrollableStatLine(mitigationLines[i], "Mitigation/healing statistic")
        end

        dialog:AddSetting({ type = LibHarvensAddonSettings.ST_SECTION, label = "Skills That Damaged You" })
        if not snapshot.incomingSkillList or #snapshot.incomingSkillList == 0 then
            AddScrollableStatLine("No incoming skill damage yet.", "No enemy damage events recorded against you in this fight")
        else
            for i = 1, math.min(20, #snapshot.incomingSkillList) do
                local skill = snapshot.incomingSkillList[i]
                local skillCritPct = skill.hits > 0 and ((skill.crits / skill.hits) * 100) or 0
                AddScrollableStatLine(
                    string.format("%d) %s [id:%d] - %s (%.0f%% crit)", i, skill.name, skill.abilityId or 0, ColorShort(skill.damage, COMBAT_COLOR_HEX.taken), skillCritPct),
                    string.format("Source: %s | Hits: %d | Crits: %d", skill.source or "Unknown", skill.hits or 0, skill.crits or 0)
                )
            end
        end

        dialog:AddSetting({ type = LibHarvensAddonSettings.ST_SECTION, label = "Set Procs That Damaged You" })
        if not snapshot.incomingSetDamageList or #snapshot.incomingSetDamageList == 0 then
            AddScrollableStatLine("No incoming set proc damage yet.", "No incoming skills matched your tracked popular set catalog")
        else
            for i = 1, math.min(20, #snapshot.incomingSetDamageList) do
                local setProc = snapshot.incomingSetDamageList[i]
                local setCritPct = setProc.hits > 0 and ((setProc.crits / setProc.hits) * 100) or 0
                AddScrollableStatLine(
                    string.format("%d) [%s] %s - %s (%.0f%% crit)", i, setProc.scene or "Set", setProc.name, ColorShort(setProc.damage, COMBAT_COLOR_HEX.taken), setCritPct),
                    string.format("Proc ability: %s | Source: %s | Hits: %d", FormatAbilityIdentity(setProc.effectName or setProc.name, setProc.abilityId), setProc.source or "Unknown", setProc.hits or 0)
                )
            end
        end

        dialog:AddSetting({ type = LibHarvensAddonSettings.ST_SECTION, label = "Likely Set Procs (Heuristic)" })
        if not snapshot.incomingLikelySetProcList or #snapshot.incomingLikelySetProcList == 0 then
            AddScrollableStatLine("No likely set procs detected.", "Heuristic mode found no additional likely set-proc ability names")
        else
            for i = 1, math.min(20, #snapshot.incomingLikelySetProcList) do
                local proc = snapshot.incomingLikelySetProcList[i]
                local procCritPct = proc.hits > 0 and ((proc.crits / proc.hits) * 100) or 0
                AddScrollableStatLine(
                    string.format("%d) %s [id:%d] - %s (%.0f%% crit)", i, proc.name, proc.abilityId or 0, ColorShort(proc.damage, COMBAT_COLOR_HEX.summary), procCritPct),
                    string.format("Heuristic score: %.1f | Signals: %s | Source: %s", proc.heuristicScore or 0, proc.heuristicReason or "n/a", proc.source or "Unknown")
                )
            end
        end

        dialog:AddSetting({ type = LibHarvensAddonSettings.ST_SECTION, label = "Top Healing Moments (30)" })
        if not snapshot.topHealingMoments or #snapshot.topHealingMoments == 0 then
            AddScrollableStatLine("No healing moments yet.", "No healing events in this fight")
        else
            for i = 1, math.min(30, #snapshot.topHealingMoments) do
                local moment = snapshot.topHealingMoments[i]
                AddScrollableStatLine(string.format("%d) %s", i, moment.label), moment.tooltip)
            end
        end

        dialog:AddSetting({ type = LibHarvensAddonSettings.ST_SECTION, label = "Top Mitigation Moments (30)" })
        if not snapshot.topMitigationMoments or #snapshot.topMitigationMoments == 0 then
            AddScrollableStatLine("No mitigation moments yet.", "No blocked or shielded moments in this fight")
        else
            for i = 1, math.min(30, #snapshot.topMitigationMoments) do
                local moment = snapshot.topMitigationMoments[i]
                AddScrollableStatLine(string.format("%d) %s", i, moment.label), moment.tooltip)
            end
        end

        AddBackButton()
        AddCloseButton()
        return
    end

    if panel == "build" then
        local frontBarCategory = type(HOTBAR_CATEGORY_PRIMARY) == "number" and HOTBAR_CATEGORY_PRIMARY or nil
        local backBarCategory = type(HOTBAR_CATEGORY_BACKUP) == "number" and HOTBAR_CATEGORY_BACKUP or nil
        local frontBar = BuildActionBarSnapshot(frontBarCategory)
        local backBar = BuildActionBarSnapshot(backBarCategory)
        local championSnapshot = BuildChampionSnapshot()
        local equipment = BuildEquipmentSnapshot()
        local equippedSets = BuildEquippedSetSummary()
        local weaponEffects = BuildWeaponEffectSnapshot()
        local procTimers = self:BuildProcTimerSnapshot()
        local boons = BuildActiveBoonSnapshot()

        dialog:AddSetting({
            type = LibHarvensAddonSettings.ST_SECTION,
            label = "Build Snapshot Panel",
            tooltip = "Console-style build snapshot: player stats, equipped gear, bars, and active boon-style buffs.",
        })

        -- Player Stats Section
        local function SafeGetPlayerStat(statType)
            if type(GetPlayerStat) ~= "function" or type(statType) ~= "number" then
                return nil
            end
            local applyBonus = type(STAT_BONUS_OPTION_APPLY_BONUS) == "number" and STAT_BONUS_OPTION_APPLY_BONUS or nil
            local applySoftCap = type(STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP) == "number" and STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP or nil
            local a, b, c, d = GetPlayerStat(statType, applyBonus, applySoftCap)
            for i = 1, 4 do
                local val = tonumber(select(i, a, b, c, d))
                if val and val > 0 then return val end
            end
            a, b, c, d = GetPlayerStat(statType)
            for i = 1, 4 do
                local val = tonumber(select(i, a, b, c, d))
                if val and val > 0 then return val end
            end
            return nil
        end

        dialog:AddSetting({
            type = LibHarvensAddonSettings.ST_SECTION,
            label = "Player Stats",
            tooltip = "Current character stats.",
        })

        local hpMax = SafeGetPlayerStat(type(STAT_HEALTH_MAX) == "number" and STAT_HEALTH_MAX or nil)
        local stamMax = SafeGetPlayerStat(type(STAT_STAMINA_MAX) == "number" and STAT_STAMINA_MAX or nil)
        local magMax = SafeGetPlayerStat(type(STAT_MAGICKA_MAX) == "number" and STAT_MAGICKA_MAX or nil)
        local physRes = SafeGetPlayerStat(type(STAT_PHYSICAL_RESISTANCE) == "number" and STAT_PHYSICAL_RESISTANCE or nil)
        local spellRes = SafeGetPlayerStat(type(STAT_SPELL_RESISTANCE) == "number" and STAT_SPELL_RESISTANCE or nil)
        local critRes = SafeGetPlayerStat(type(STAT_CRITICAL_RESISTANCE) == "number" and STAT_CRITICAL_RESISTANCE or nil)
        local weaponDmg = SafeGetPlayerStat(type(STAT_WEAPON_DAMAGE) == "number" and STAT_WEAPON_DAMAGE or nil)
        local spellDmg = SafeGetPlayerStat(type(STAT_SPELL_DAMAGE) == "number" and STAT_SPELL_DAMAGE or nil)
        local armorPen = SafeGetPlayerStat(type(STAT_ARMOR_PENETRATION) == "number" and STAT_ARMOR_PENETRATION or nil)
        local spellPen = SafeGetPlayerStat(type(STAT_SPELL_PENETRATION) == "number" and STAT_SPELL_PENETRATION or nil)
        local critChance = SafeGetPlayerStat(type(STAT_CRITICAL_STRIKE) == "number" and STAT_CRITICAL_STRIKE or nil)
        local critDamage = SafeGetPlayerStat(type(STAT_CRITICAL_DAMAGE) == "number" and STAT_CRITICAL_DAMAGE or nil)

        local function SafeFormatCritChance(value)
            if not value then
                return nil
            end
            if type(GetCriticalStrikeChance) == "function" then
                local ok, pct = pcall(GetCriticalStrikeChance, value)
                if ok and type(pct) == "number" then
                    return pct
                end
            end
            return tonumber(value)
        end

        if hpMax then
            AddScrollableStatLine(string.format("Max HP: %s", NumberText(math.floor(hpMax))), "Maximum Health")
        end
        if stamMax then
            AddScrollableStatLine(string.format("Max Stamina: %s", NumberText(math.floor(stamMax))), "Maximum Stamina")
        end
        if magMax then
            AddScrollableStatLine(string.format("Max Magicka: %s", NumberText(math.floor(magMax))), "Maximum Magicka")
        end
        if physRes then
            AddScrollableStatLine(string.format("Phys Resist: %s", NumberText(math.floor(physRes))), "Physical Resistance")
        end
        if spellRes then
            AddScrollableStatLine(string.format("Spell Resist: %s", NumberText(math.floor(spellRes))), "Spell Resistance")
        end
        if critRes then
            AddScrollableStatLine(string.format("Crit Resist: %s", NumberText(math.floor(critRes))), "Critical Resistance")
        end
        if weaponDmg then
            AddScrollableStatLine(string.format("Weapon Dmg: %s", NumberText(math.floor(weaponDmg))), "Weapon Damage")
        end
        if spellDmg then
            AddScrollableStatLine(string.format("Spell Dmg: %s", NumberText(math.floor(spellDmg))), "Spell Damage")
        end
        if armorPen then
            AddScrollableStatLine(string.format("Armor Pen: %s", NumberText(math.floor(armorPen))), "Armor Penetration")
        end
        if spellPen then
            AddScrollableStatLine(string.format("Spell Pen: %s", NumberText(math.floor(spellPen))), "Spell Penetration")
        end
        if critChance then
            local critChancePct = SafeFormatCritChance(critChance)
            if critChancePct then
                AddScrollableStatLine(
                    string.format("Crit Chance: %.1f%%", critChancePct),
                    "Critical Strike Chance"
                )
            end
        end
        if critDamage then
            AddScrollableStatLine(string.format("Crit Dmg: %.1f%%", critDamage), "Critical Damage Bonus")
        end

        dialog:AddSetting({ type = LibHarvensAddonSettings.ST_SECTION, label = "Equipped Armor" })
        if #equipment == 0 then
            AddScrollableStatLine("No equipment data available.", "Equipment API unavailable in this context.")
        else
            for i = 1, #equipment do
                local item = equipment[i]
                AddScrollableStatLine(
                    string.format("%s: %s", item.label, item.text),
                    string.format("Equipped in %s slot.", item.label)
                )
            end
        end

        if championSnapshot.totalPoints then
            AddScrollableStatLine(
                string.format("Champion Points: %s", NumberText(championSnapshot.totalPoints)),
                "Current earned Champion Point total."
            )
        end

        dialog:AddSetting({ type = LibHarvensAddonSettings.ST_SECTION, label = "Front Bar" })
        for i = 1, #frontBar do
            local entry = frontBar[i]
            AddScrollableStatLine(
                string.format("%s: %s", entry.slotLabel, entry.abilityName),
                string.format("Ability ID: %d", entry.abilityId or 0)
            )
        end

        dialog:AddSetting({ type = LibHarvensAddonSettings.ST_SECTION, label = "Back Bar" })
        for i = 1, #backBar do
            local entry = backBar[i]
            AddScrollableStatLine(
                string.format("%s: %s", entry.slotLabel, entry.abilityName),
                string.format("Ability ID: %d", entry.abilityId or 0)
            )
        end

        dialog:AddSetting({ type = LibHarvensAddonSettings.ST_SECTION, label = "Champion Snapshot" })
        local function AddChampionBucket(label, entries)
            if #entries == 0 then
                AddScrollableStatLine(string.format("%s: unavailable", label), string.format("No %s champion data exposed in this context.", string.lower(label)))
                return
            end

            for i = 1, #entries do
                local entry = entries[i]
                local starText = #entry.stars > 0 and table.concat(entry.stars, ", ") or "No slotted stars detected"
                AddScrollableStatLine(
                    string.format("%s: %s pts", entry.name, NumberText(entry.points or 0)),
                    string.format("%s stars: %s", label, starText)
                )
            end
        end

        if championSnapshot.available then
            AddChampionBucket("Warfare", championSnapshot.warfare)
            AddChampionBucket("Fitness", championSnapshot.fitness)
            AddChampionBucket("Craft", championSnapshot.craft)
        else
            AddScrollableStatLine("Champion data unavailable.", "Champion discipline APIs did not expose data in this build/context.")
        end

        dialog:AddSetting({ type = LibHarvensAddonSettings.ST_SECTION, label = "Equipped Sets" })
        if #equippedSets == 0 then
            AddScrollableStatLine("No equipped set data available.", "Set API unavailable or no set items are equipped.")
        else
            for i = 1, #equippedSets do
                local setInfo = equippedSets[i]
                AddScrollableStatLine(
                    string.format("%s (%d/%d)", setInfo.setName, setInfo.numEquipped or 0, setInfo.maxEquipped or 0),
                    string.format("Equipped on: %s", table.concat(setInfo.slots or {}, ", "))
                )
            end
        end

        dialog:AddSetting({ type = LibHarvensAddonSettings.ST_SECTION, label = "Weapon Enchants / Poisons" })
        if #weaponEffects == 0 then
            AddScrollableStatLine("No weapon detail data available.", "Weapon detail API unavailable in this context.")
        else
            for i = 1, #weaponEffects do
                local entry = weaponEffects[i]
                AddScrollableStatLine(
                    string.format("%s: %s", entry.label, entry.itemText),
                    string.format("Enchant: %s | Poison: %s", entry.enchantText, entry.poisonText)
                )
            end
        end

        dialog:AddSetting({ type = LibHarvensAddonSettings.ST_SECTION, label = "Proc Timers / Ready" })
        if #procTimers == 0 then
            AddScrollableStatLine("No tracked proc timers available.", "Import PvPCooldownTracker rules or equip tracked sets to populate this section.")
        else
            for i = 1, #procTimers do
                local entry = procTimers[i]
                local sourceBits = {}
                if entry.fromPCT then
                    sourceBits[#sourceBits + 1] = "PCT"
                end
                if entry.fromCustomRule then
                    sourceBits[#sourceBits + 1] = "CM"
                end
                local sourceText = #sourceBits > 0 and table.concat(sourceBits, "/") or "tracked"
                AddScrollableStatLine(
                    string.format("%s: %s", entry.label, entry.stateText),
                    string.format("Cooldown: %.1fs | Equipped: %d/%d | Source: %s", (entry.cooldownMs or 0) / 1000, entry.numEquipped or 0, entry.maxEquipped or 0, sourceText)
                )
            end
        end

        dialog:AddSetting({ type = LibHarvensAddonSettings.ST_SECTION, label = "Boon / Mundus" })
        if #boons == 0 then
            AddScrollableStatLine("No boon-style buff detected.", "If ESO exposes the current boon through buffs here, it will show up in this list.")
        else
            for i = 1, #boons do
                AddScrollableStatLine(boons[i], "Active boon or mundus-style buff detected on the player.")
            end
        end

        AddActionButton("Print Build Debug", "Print the current Build Snapshot panel data to chat.", function()
            self:PrintBuildSnapshotDebug("build-panel")
        end)

        AddActionButton("Link Build in Chat", "Pre-fill chat input with a compact build summary you can send to group/zone.", function()
            self:LinkBuildToChat()
        end)

        AddBackButton()
        AddCloseButton()
        return
    end

    if panel == "resistance" then
        dialog:AddSetting({
            type = LibHarvensAddonSettings.ST_SECTION,
            label = "Resistance / DR Panel",
            tooltip = "Machine learning inference for target resistance and protections",
        })

        if not snapshot.targetList or #snapshot.targetList == 0 then
            AddScrollableStatLine("No target data yet.", "No resistance samples available")
        else
            for i = 1, math.min(5, #snapshot.targetList) do
                local target = snapshot.targetList[i]
                local drPct = Clamp((target.estimatedResistance / RESISTANCE_SCALE) * 100, 0, 50)
                local label, _, confidence = InferProtectionFromDr(drPct, true)
                AddScrollableStatLine(
                    string.format("%d) %s - %s res (DR %.1f%%)", i, target.name, NumberText(target.estimatedResistance), drPct),
                    "Estimated resistance and inferred DR"
                )
                AddScrollableStatLine(
                    string.format("   %s (confidence %.0f%%)", label, confidence * 100),
                    "Inferred protection state"
                )
            end
        end

        AddScrollableStatLine(string.format("Predicted Resistance: %s", NumberText(behavior.predictedResistance or 0)), "ML-lite predicted resistance")
        AddScrollableStatLine(string.format("Predicted DR: %.1f%%", behavior.predictedDrPct or 0), "Predicted DR from resistance model")
        AddScrollableStatLine(string.format("Predicted Protections: %s", behavior.predictedProtectionLabel or "No mitigation data"), "Protection state inferred from predicted DR")

        AddBackButton()
        AddCloseButton()
        return
    end

    if panel == "buffs" then
        local ps = snapshot.protectionSummary or BuildProtectionSummary(nil, 0)
        local allEffectList = snapshot.allEffectList or {}
        local majorMinorList = snapshot.majorMinorList or {}
        local setProcList = snapshot.setProcList or {}

        dialog:AddSetting({
            type = LibHarvensAddonSettings.ST_SECTION,
            label = "Buff Uptime Panel (Inferred)",
            tooltip = "Protection uptime, every Major/Minor effect, and popular set coverage",
        })

        -- First section keeps the inferred protection model summary visible at the top.
        AddScrollableStatLine(string.format("Tracked Time: %s", FormatMs(ps.totalMs)), "Total time with inference samples")
        AddScrollableStatLine(string.format("Any Protection Uptime: %.1f%% (%s)", ps.anyProtectionPct or 0, FormatMs(ps.anyProtectionMs)), "Major/Minor/Combined inferred uptime")
        AddScrollableStatLine(string.format("Any Protection Downtime: %.1f%% (%s)", 100 - (ps.anyProtectionPct or 0), FormatMs((ps.noneMs or 0) + (ps.unknownMs or 0))), "No protection or unknown time")

        AddScrollableStatLine(string.format("Major Uptime: %.1f%% (%s)", ps.majorPct or 0, FormatMs(ps.majorMs)), "Inferred major protection uptime")
        AddScrollableStatLine(string.format("Major Downtime: %.1f%%", 100 - (ps.majorPct or 0)), "Time without inferred major protection")

        AddScrollableStatLine(string.format("Minor Uptime: %.1f%% (%s)", ps.minorPct or 0, FormatMs(ps.minorMs)), "Inferred minor protection uptime")
        AddScrollableStatLine(string.format("Minor Downtime: %.1f%%", 100 - (ps.minorPct or 0)), "Time without inferred minor protection")

        AddScrollableStatLine(string.format("Major+Minor Uptime: %.1f%% (%s)", ps.majorMinorPct or 0, FormatMs(ps.majorMinorMs)), "Inferred simultaneous major+minor protection")
        AddScrollableStatLine(string.format("Unknown Inference Time: %.1f%% (%s)", ps.unknownPct or 0, FormatMs(ps.unknownMs)), "No mitigation signal available")

        -- Full effect list gives a direct answer to "what was active and for how long".
        dialog:AddSetting({ type = LibHarvensAddonSettings.ST_SECTION, label = "All Effects and Uptime" })
        if #allEffectList == 0 then
            AddScrollableStatLine("No effects tracked yet.", "Effect rows appear when effect gained/faded events are seen")
        else
            for i = 1, math.min(EFFECTS_PANEL_LIMIT, #allEffectList) do
                local effect = allEffectList[i]
                AddScrollableStatLine(
                    string.format(
                        "%d) %s [id:%d] - %.1f%% (%s)",
                        i,
                        effect.name,
                        effect.abilityId or 0,
                        effect.uptimePct or 0,
                        FormatMs(effect.uptimeMs)
                    ),
                    string.format("Effect: %s | Activations: %d | Fades: %d", effect.effectName or effect.name or "Unknown", effect.activations or 0, effect.fades or 0)
                )
            end
            if #allEffectList > EFFECTS_PANEL_LIMIT then
                AddScrollableStatLine(
                    string.format("Showing top %d of %d effects", EFFECTS_PANEL_LIMIT, #allEffectList),
                    "Panel limits rows for gamepad readability"
                )
            end
        end

        -- Major/Minor subset is preserved separately for quick combat readability.
        dialog:AddSetting({ type = LibHarvensAddonSettings.ST_SECTION, label = "All Major/Minor Effects" })
        if #majorMinorList == 0 then
            AddScrollableStatLine("No Major/Minor effects tracked yet.", "Major/Minor uptime appears after matching combat events")
        else
            for i = 1, #majorMinorList do
                local effect = majorMinorList[i]
                AddScrollableStatLine(
                    string.format(
                        "%d) [%s] %s [id:%d] - %.1f%% (%s) procs:%d",
                        i,
                        effect.category or "Effect",
                        effect.name,
                        effect.abilityId or 0,
                        effect.uptimePct or 0,
                        FormatMs(effect.uptimeMs),
                        effect.procs or 0
                    ),
                    string.format("Effect: %s | Activations: %d | Fades: %d | Total value: %s", effect.effectName or effect.name or "Unknown", effect.activations or 0, effect.fades or 0, NumberText(effect.totalValue or 0))
                )
            end
        end

        -- Popular sets section highlights common meta sets without losing full-effect visibility above.
        dialog:AddSetting({ type = LibHarvensAddonSettings.ST_SECTION, label = "Popular PvE/PvP Set Procs" })
        if #setProcList == 0 then
            AddScrollableStatLine("No popular set procs tracked yet.", "Set coverage appears when abilities match the tracked catalog")
        else
            for i = 1, #setProcList do
                local setInfo = setProcList[i]
                AddScrollableStatLine(
                    string.format(
                        "%d) [%s] %s [id:%d] - %.1f%% (%s) procs:%d",
                        i,
                        setInfo.category or "Set",
                        setInfo.name,
                        setInfo.abilityId or 0,
                        setInfo.uptimePct or 0,
                        FormatMs(setInfo.uptimeMs),
                        setInfo.procs or 0
                    ),
                    string.format("Effect: %s | Activations: %d | Fades: %d | Total value: %s", setInfo.effectName or setInfo.name or "Unknown", setInfo.activations or 0, setInfo.fades or 0, NumberText(setInfo.totalValue or 0))
                )
            end
        end

        AddBackButton()
        AddCloseButton()
        return
    end

    if panel == "skills" then
        dialog:AddSetting({
            type = LibHarvensAddonSettings.ST_SECTION,
            label = "Skills Panel (Damage)",
            tooltip = "Top 20 skills by total damage output this fight",
        })

        if #snapshot.skillList == 0 then
            AddScrollableStatLine("No skill data yet.", "No damage skills recorded in this fight")
        else
            for i = 1, math.min(20, #snapshot.skillList) do
                local skill = snapshot.skillList[i]
                local skillCritPct = skill.hits > 0 and ((skill.crits / skill.hits) * 100) or 0
                AddScrollableStatLine(
                    string.format("%d) %s [id:%d] - %s (%.0f%% crit)", i, skill.name, skill.abilityId or 0, ColorShort(skill.damage, COMBAT_COLOR_HEX.damage), skillCritPct),
                    string.format("Ability: %s | Hits: %d | Crits: %d", FormatAbilityIdentity(skill.name, skill.abilityId), skill.hits or 0, skill.crits or 0)
                )
            end
        end

        dialog:AddSetting({ type = LibHarvensAddonSettings.ST_SECTION, label = "Skills (Overall Healing)" })
        if not snapshot.healSkillList or #snapshot.healSkillList == 0 then
            AddScrollableStatLine("No healing skill data yet.", "No healing skills recorded in this fight")
        else
            for i = 1, math.min(20, #snapshot.healSkillList) do
                local skill = snapshot.healSkillList[i]
                local skillCritPct = skill.hits > 0 and ((skill.crits / skill.hits) * 100) or 0
                AddScrollableStatLine(
                    string.format("%d) %s [id:%d] - %s (%.0f%% crit)", i, skill.name, skill.abilityId or 0, ColorShort(skill.heal, COMBAT_COLOR_HEX.heal), skillCritPct),
                    string.format("Ability: %s | Hits: %d | Crits: %d | Damage dealt: %s", FormatAbilityIdentity(skill.name, skill.abilityId), skill.hits or 0, skill.crits or 0, NumberText(skill.damage or 0))
                )
            end
        end

        dialog:AddSetting({ type = LibHarvensAddonSettings.ST_SECTION, label = "Top DoT Ticks (Damage over Time)" })
        if not snapshot.dotList or #snapshot.dotList == 0 then
            AddScrollableStatLine("No DoT data yet.", "No damage-over-time ticks recorded in this fight")
        else
            for i = 1, math.min(20, #snapshot.dotList) do
                local dot = snapshot.dotList[i]
                local dotCritPct = dot.hits > 0 and ((dot.crits / dot.hits) * 100) or 0
                AddScrollableStatLine(
                    string.format("%d) %s [id:%d] - %s (%.0f%% crit)", i, dot.name, dot.abilityId or 0, ColorShort(dot.damage, COMBAT_COLOR_HEX.dot), dotCritPct),
                    string.format("DoT: %s | Total ticks: %d | Crit ticks: %d", FormatAbilityIdentity(dot.name, dot.abilityId), dot.hits or 0, dot.crits or 0)
                )
            end
        end

        dialog:AddSetting({ type = LibHarvensAddonSettings.ST_SECTION, label = "Top HoT Ticks (Heal over Time)" })
        if not snapshot.hotList or #snapshot.hotList == 0 then
            AddScrollableStatLine("No HoT data yet.", "No heal-over-time ticks recorded in this fight")
        else
            for i = 1, math.min(20, #snapshot.hotList) do
                local hot = snapshot.hotList[i]
                local hotCritPct = hot.hits > 0 and ((hot.crits / hot.hits) * 100) or 0
                AddScrollableStatLine(
                    string.format("%d) %s [id:%d] - %s (%.0f%% crit)", i, hot.name, hot.abilityId or 0, ColorShort(hot.heal, COMBAT_COLOR_HEX.hot), hotCritPct),
                    string.format("HoT: %s | Total ticks: %d | Crit ticks: %d", FormatAbilityIdentity(hot.name, hot.abilityId), hot.hits or 0, hot.crits or 0)
                )
            end
        end

        dialog:AddSetting({ type = LibHarvensAddonSettings.ST_SECTION, label = "Top Healing Moments (30)" })
        if not snapshot.topHealingMoments or #snapshot.topHealingMoments == 0 then
            AddScrollableStatLine("No healing moments yet.", "No healing events in this fight")
        else
            for i = 1, math.min(30, #snapshot.topHealingMoments) do
                local moment = snapshot.topHealingMoments[i]
                AddScrollableStatLine(string.format("%d) %s", i, moment.label), moment.tooltip)
            end
        end

        dialog:AddSetting({ type = LibHarvensAddonSettings.ST_SECTION, label = "Top Mitigation Moments (30)" })
        if not snapshot.topMitigationMoments or #snapshot.topMitigationMoments == 0 then
            AddScrollableStatLine("No mitigation moments yet.", "No mitigation events in this fight")
        else
            for i = 1, math.min(30, #snapshot.topMitigationMoments) do
                local moment = snapshot.topMitigationMoments[i]
                AddScrollableStatLine(string.format("%d) %s", i, moment.label), moment.tooltip)
            end
        end

        AddBackButton()
        AddCloseButton()
        return
    end

    if panel == "behavior" then
        dialog:AddSetting({
            type = LibHarvensAddonSettings.ST_SECTION,
            label = "Behavior Model Panel (ML-lite)",
            tooltip = "Model predictions built from fight history using EMA + trend extrapolation",
        })

        local behaviorRows = {
            {
                label = string.format("Samples: %d", behavior.samples or 0),
                tooltip = "Total fight summaries used by the model (history plus live fight when non-empty)",
            },
            {
                label = string.format("Predicted Next DPS: %s", ShortNumber(behavior.predictedDps or 0)),
                tooltip = "Forecasted DPS using exponential moving average (alpha 0.35) plus linear slope",
            },
            {
                label = string.format("Predicted Next HPS: %s", ShortNumber(behavior.predictedHps or 0)),
                tooltip = "Forecasted HPS using exponential moving average (alpha 0.35) plus linear slope",
            },
            {
                label = string.format("Predicted Next Taken: %s", ShortNumber(behavior.predictedTaken or 0)),
                tooltip = "Forecasted incoming damage trend from previous fights and current combat",
            },
            {
                label = string.format("Predicted Resistance: %s", NumberText(behavior.predictedResistance or 0)),
                tooltip = "Estimated target resistance from observed mitigation samples, clamped to 0-33,000",
            },
            {
                label = string.format("Predicted DR: %.1f%%", behavior.predictedDrPct or 0),
                tooltip = "Damage reduction estimate from resistance using DR = resistance / 66,000 (max 50%)",
            },
            {
                label = string.format("Predicted Protections: %s", behavior.predictedProtectionLabel or "No mitigation data"),
                tooltip = "Inferred state (Major/Minor/None) from predicted DR threshold matching",
            },
            {
                label = string.format("Prediction Confidence: %.0f%%", (behavior.predictedProtectionConfidence or 0) * 100),
                tooltip = "Confidence score based on proximity to DR bands and number of resistance samples",
            },
            {
                label = string.format("Resistance Samples: %d", behavior.resistanceSamples or 0),
                tooltip = "Number of target resistance observations that fed the resistance model",
            },
            {
                label = string.format("Volatility: %.1f%%", behavior.volatilityPct or 0),
                tooltip = "Fight variance measured as DPS stddev / mean DPS",
            },
            {
                label = behavior.pressureProfile or "No pressure profile yet",
                tooltip = "Pressure profile compares predicted incoming damage versus predicted DPS",
            },
            {
                label = behavior.rhythmProfile or "No rhythm profile yet",
                tooltip = "Rhythm profile uses volatility threshold (over 35% = bursty, otherwise stable)",
            },
        }

        for i = 1, #behaviorRows do
            AddScrollableStatLine(behaviorRows[i].label, behaviorRows[i].tooltip)
        end

        AddBackButton()
        AddCloseButton()
        return
    end

    if panel == "formulas" then
        dialog:AddSetting({
            type = LibHarvensAddonSettings.ST_SECTION,
            label = "Formula Panel (ESO + ConsoleMetrics)",
            tooltip = "Core ESO stat equations plus exact formulas used by this addon",
        })

        AddScrollableStatLine(
            "Coverage Notes",
            "This panel includes core published ESO equations and all formulas used by ConsoleMetrics. Some internal server formulas are undisclosed and can change by patch."
        )

        local function AddFormulaRow(title, equation, note)
            AddScrollableStatLine(title, string.format("%s | %s", equation, note))
        end

        local function AddFormulaSection(label)
            dialog:AddSetting({
                type = LibHarvensAddonSettings.ST_SECTION,
                label = label,
                tooltip = "Formula reference",
            })
        end

        AddFormulaSection("Core Throughput")
        AddFormulaRow("DPS", "DPS = TotalDamage / max(DurationSeconds, 0.001)", "Primary outgoing damage rate.")
        AddFormulaRow("HPS", "HPS = TotalHeal / max(DurationSeconds, 0.001)", "Primary outgoing healing rate.")
        AddFormulaRow("Crit Rate", "CritRatePct = (CritHits / max(Hits, 1)) * 100", "Critical hit percentage.")
        AddFormulaRow("Peak DPS", "PeakDps = max(PeakDps, CurrentDps)", "Highest observed DPS in fight.")
        AddFormulaRow("Peak HPS", "PeakHps = max(PeakHps, CurrentHps)", "Highest observed HPS in fight.")
        AddFormulaRow("Effect Uptime", "UptimePct = Clamp((UptimeMs / max(DurationMs, 1)) * 100, 0, 100)", "Used for all effect uptime rows.")
        AddFormulaRow("Any Protection Uptime", "AnyProtectionPct = (AnyProtectionMs / max(TotalMs, 1)) * 100", "Major + Minor + MajorMinor inferred states.")
        AddFormulaRow("Downtime", "DowntimePct = 100 - AnyProtectionPct", "No/unknown protection time.")

        AddFormulaSection("Resistance and DR")
        AddFormulaRow("Observed Mitigation", "MitigationRatio = Clamp((Blocked + Shielded) / (Effective + Overflow + Blocked + Shielded), 0, 0.5)", "Observed mitigation proxy from combat events.")
        AddFormulaRow("Estimated Resistance", "Resistance = Clamp(MitigationRatio * 66000, 0, 33000)", "Addon target resistance estimate.")
        AddFormulaRow("DR from Resistance", "DRPct = Clamp((Resistance / 66000) * 100, 0, 50)", "ESO linear DR approximation used by addon.")
        AddFormulaRow("After Penetration", "PostPenRes = max(TargetResistance - Penetration, 0)", "Effective resistance after pen.")
        AddFormulaRow("Post-Pen DR", "PostPenDRPct = Clamp((PostPenRes / 66000) * 100, 0, 50)", "Damage reduction after penetration.")
        AddFormulaRow("Outgoing Mitigated", "OutgoingMitigated = OutgoingBlocked + OutgoingShielded", "Displayed in mitigation panel.")
        AddFormulaRow("Incoming Mitigated", "IncomingMitigated = IncomingBlocked + IncomingShielded", "Displayed in mitigation panel.")
        AddFormulaRow("Approx Damage Taken", "DamageTakenApprox = RawDamage * (1 - PostPenDR)", "Useful sanity estimate when pen is known.")
        AddFormulaRow("Resistance Cap", "EffectiveResistCap = 33000", "Current cap used in addon constants.")

        AddFormulaSection("Crit, Scaling, Sustain")
        AddFormulaRow("Crit Chance (rating)", "CritChancePct approx = (CritRating / 21912) * 100", "Level-50 CP160 style conversion; patch dependent.")
        AddFormulaRow("Critical Hit", "CritHit = BaseHit * (1 + CritDamageBonus)", "Final crit before target-side mitigation.")
        AddFormulaRow("Crit Damage Cap", "CritDamageBonus <= 1.25 (125%)", "Common ESO cap reference.")
        AddFormulaRow("Power Approximation", "EffectivePower approx = WeaponOrSpellDamage + (MaxResource / 10.5)", "Common ESO coefficient approximation.")
        AddFormulaRow("Overheal", "Overheal = max(HealAmount - MissingHealth, 0)", "Non-effective healing.")
        AddFormulaRow("Effective Healing", "EffectiveHeal = HealAmount - Overheal", "Healing that actually restored HP.")
        AddFormulaRow("Shield Absorb", "ShieldAbsorbed = min(IncomingDamage, ActiveShield)", "Shielded portion of incoming hit.")
        AddFormulaRow("Recovery Tick", "RecoveryPerSecond = RecoveryStat / 2", "ESO recovery shown per 2s tick.")

        AddFormulaSection("Protection Inference (Exact Addon Logic)")
        AddFormulaRow("Major+Minor Threshold", "If DRPct >= (MajorPct + MinorPct - 1.0), state = majorMinor", "With current constants: DR >= 14%.")
        AddFormulaRow("Major Threshold", "Else if DRPct >= (MajorPct - 1.0), state = major", "With current constants: DR >= 9%.")
        AddFormulaRow("Minor Threshold", "Else if DRPct >= (MinorPct - 1.0), state = minor", "With current constants: DR >= 4%.")
        AddFormulaRow("No Protection", "Else state = none", "Below minor threshold.")
        AddFormulaRow("Major+Minor Confidence", "Clamp(0.65 + ((DRPct - (MajorPct + MinorPct)) / 20), 0.45, 0.98)", "Exact formula in InferProtectionFromDr.")
        AddFormulaRow("Major Confidence", "Clamp(0.60 + ((DRPct - MajorPct) / 18), 0.40, 0.95)", "Exact formula in InferProtectionFromDr.")
        AddFormulaRow("Minor Confidence", "Clamp(0.55 + ((DRPct - MinorPct) / 15), 0.35, 0.90)", "Exact formula in InferProtectionFromDr.")
        AddFormulaRow("None Confidence", "Clamp(0.50 + ((MinorPct - DRPct) / 15), 0.30, 0.90)", "Exact formula in InferProtectionFromDr.")

        AddFormulaSection("Behavior Model (Exact Addon Logic)")
        AddFormulaRow("Prediction Core", "Predicted = max(0, EMA(values, 0.35) + LinearSlope(values))", "Applied to DPS, HPS, and Taken.")
        AddFormulaRow("EMA", "EMA_t = alpha * x_t + (1 - alpha) * EMA_{t-1}", "alpha = 0.35 in this addon.")
        AddFormulaRow("Linear Slope", "Slope = ((n*sum(xy)) - (sumx*sumy)) / ((n*sum(xx)) - (sumx^2))", "Least-squares slope on ordered samples.")
        AddFormulaRow("Mean", "Mean = sum(values) / n", "Arithmetic mean for model aggregates.")
        AddFormulaRow("StdDev", "StdDev = sqrt(sum((x - mean)^2) / (n - 1))", "Sample standard deviation.")
        AddFormulaRow("Volatility", "VolatilityPct = (StdDev(DPS) / max(Mean(DPS), epsilon)) * 100", "High volatility indicates bursty output.")
        AddFormulaRow("Pressure Profile", "High if PredTaken > 0.8*PredDps; Low if PredTaken < 0.25*PredDps; else Balanced", "Exact branch logic used in model panel.")
        AddFormulaRow("Rhythm Profile", "Bursty if Volatility > 35; else Stable", "Exact branch logic used in model panel.")

        AddFormulaSection("UESP Build Editor Formulas (Special:EsoBuildEditor)")
        AddFormulaRow("Source Modules", "ext.EsoBuildData.editor.scripts + ext.EsoBuildData.viewer.scripts", "Formulas below are extracted from UESP Build Editor runtime code.")

        AddFormulaSection("UESP Core Conversions")
        AddFormulaRow("Flat Crit -> Percent", "CritPct = round1(FlatCrit / (2 * EffectiveLevel * (100 + EffectiveLevel)) * 100)", "From ConvertEsoFlatCritToPercent().")
        AddFormulaRow("Percent Crit -> Flat", "FlatCrit = round(CritPct * 2 * EffectiveLevel * (100 + EffectiveLevel))", "From ConvertEsoPercentCritToFlat().")
        AddFormulaRow("Flat Resist -> Percent", "ResistPct = round(max(0, (clamp(FlatResist, 0, 33000) - 100) / (EffectiveLevel * 10)))", "From ConvertEsoFlatResistToPercent().")
        AddFormulaRow("Element Resist -> Percent", "ElementResistPct = round(max(0, clamp(FlatResist, 0, 33000) / (EffectiveLevel * 10)))", "From ConvertEsoElementResistToPercent().")
        AddFormulaRow("Crit Resist -> Percent", "CritResistPct = round(FlatCritResist / EffectiveLevel)", "From ConvertEsoCritResistToPercent().")

        AddFormulaSection("UESP Damage, Crit, and Mitigation Pipeline")
        AddFormulaRow("Base Damage Pipeline", "Damage = floor((floor(Base * SkillDamageMod * AllDamageMod) + ExtraDamage) * CritFactor * Mitigation)", "Order used by EsoBuildCombatApplyDamage().")
        AddFormulaRow("Critical Factor", "CritFactor = (1 + CritDamageBonus) when random <= CritRate, else 1", "Crit roll and multiplier in EsoBuildCombatApplyDamage().")
        AddFormulaRow("Crit Resist Reduction", "CritDamageBonus = max(0, CritDamageBonus - round2(CritResist * (0.035 / 250)))", "From EsoBuildCombatGetCritDataForSkill().")
        AddFormulaRow("Target Mitigation", "Mitigation = ResistDamageTaken * (1 + TargetDamageTaken)", "From EsoBuildCombatGetTargetMitigation().")
        AddFormulaRow("Resist Damage Taken", "ResistDamageTaken = 1 - clamp(Resist, 0, ESO_RESIST_CAP) / 66000", "From resistDamageTaken calculation.")
        AddFormulaRow("Oblivion Exception", "If DamageType == Oblivion then ResistDamageTaken = 1", "Oblivion bypasses resistance in UESP combat simulation.")

        AddFormulaSection("UESP Skill/Set Runtime Equations")
        AddFormulaRow("Venomous Claw Tick", "TickDamage = floor(BaseTick * (1 + floor(TickCount / 2) * StepPct / 100))", "From Venomous Claw getDotTickDamage().")
        AddFormulaRow("Hurricane Tick", "TickDamage = floor(BaseTick * (1 + TickCount * MaxPct / 100 / TickInterval * Duration))", "From Hurricane getDotTickDamage().")
        AddFormulaRow("Eviscerate Execute", "DamageMod = 1 + ((100 - CurrentHealthPct) / 100) * ExecutePct / 100", "From Eviscerate getDamageMod().")
        AddFormulaRow("Onslaught Ignored Resist", "IgnoredResist = floor(CurrentResist * IgnorePct / 100)", "Stored for follow-up penetration effect.")
        AddFormulaRow("Onslaught Follow-up Pen", "FlatResistMod = -IgnoredResist (direct, non-DOT only while active)", "From Onslaught getFlatResistMod().")
        AddFormulaRow("Knight Slayer", "BonusDamage = min(floor(TargetMaxHealth * HealthPct / 100), MaxOblivionDamage)", "From Knight Slayer onHeavyAttack().")
        AddFormulaRow("Sload's Semblance", "ProcDamage = min(floor(TargetMaxHealth * HealthPct / 100), MaxOblivionDamage)", "From Sload's Semblance onAnyDamage().")
        AddFormulaRow("Roaring Opportunist Duration", "Duration = clamp(HeavyAttackDamage / DamagePerSecond, MinDuration, MaxDuration)", "From Roaring Opportunist onHeavyAttack().")
        AddFormulaRow("Balorgh (2x variant)", "WeaponSpellDamageBonus = 2 * UltimateConsumed", "From Balorgh set rule variant 1.")
        AddFormulaRow("Balorgh (hybrid variant)", "WeaponSpellDamageBonus = UltimateConsumed; PenBonus = PenMultiplier * UltimateConsumed", "From Balorgh set rule variant 2.")

        AddFormulaSection("UESP Dynamic Set Tooltip Formulas")
        AddFormulaRow("Three-Piece Scaling", "CurrentWeaponSpellDamage = BaseDamage * ThreeSetCount; CurrentArmor = BaseArmor * ThreeSetCount", "From UpdateEsoBuildSetOther().")
        AddFormulaRow("Bahsei Current Value", "CurrentPct = Set.BahseiMania * 100", "From UESP tooltip recompute for Bahsei.")
        AddFormulaRow("Coral Riptide Current Value", "CurrentWeaponSpellDamage = Set.CoralRiptide", "From UESP tooltip recompute for Coral Riptide.")
        AddFormulaRow("Mora's Whispers Crit", "CurrentCrit = round(Set.MorasWhispers)", "From UESP tooltip recompute for Mora's Whispers.")
        AddFormulaRow("Mora's Whispers XP/Skill", "CurrentInspirationPct = round(Set.MorasWhispers / MaxCrit * MaxInspirationPct)", "From UESP tooltip recompute for Mora's Whispers.")
        AddFormulaRow("Mora's Whispers Kill XP", "CurrentMonsterKillPct = round(Set.MorasWhispers / MaxCrit * MaxMonsterKillPct)", "From UESP tooltip recompute for Mora's Whispers.")
        AddFormulaRow("Pearlescent Ward Damage", "CurrentWeaponSpellDamage = round(Set.PearlescentWard / 12 * MaxDamage)", "From UESP tooltip recompute for Pearlescent Ward.")
        AddFormulaRow("Pearlescent Ward Reduction", "CurrentReductionPct = round(Set.PearlescentWard / 12 * MaxReductionPct)", "From UESP tooltip recompute for Pearlescent Ward.")
        AddFormulaRow("Mark of the Pariah", "CurrentResistValue = round(Set.MarkPariah)", "From UESP tooltip recompute for Mark of the Pariah.")

        AddFormulaSection("UESP Proc Template Equations")
        AddFormulaRow("Proc Chance Gate", "Trigger if random <= ChancePct/100 and cooldown is ready", "Core condition used by many UESP set/skill procs.")
        AddFormulaRow("DOT From Total", "PerTick = TotalDamage / DurationSeconds", "Used repeatedly when constructing periodic effects.")
        AddFormulaRow("Generic Bonus Window", "Apply bonus for DurationSeconds, then expire when CurrentTime >= EndTime", "Shared toggle/buff timing behavior in UESP combat engine.")

        AddFormulaSection("Live Player Stat Comparison")
        local roleKey, roleProfile, roleSource = GetSelectedRoleComparisonProfile()

        AddScrollableStatLine(
            string.format("Comparison Profile: %s", roleProfile.label),
            string.format(
                "%s Using GetPlayerStat-derived max stats. Health %s-%s | Primary %s-%s | Secondary %s-%s | Crit %.0f%%-%.0f%%.",
                roleSource,
                NumberText(roleProfile.health[1]),
                NumberText(roleProfile.health[2]),
                NumberText(roleProfile.primary[1]),
                NumberText(roleProfile.primary[2]),
                NumberText(roleProfile.secondary[1]),
                NumberText(roleProfile.secondary[2]),
                roleProfile.crit[1],
                roleProfile.crit[2]
            )
        )
        AddScrollableStatLine(
            "Role Detection",
            string.format("Detected profile key: %s", roleKey)
        )

        local function FirstPositiveNumber(...)
            local count = select("#", ...)
            for i = count, 1, -1 do
                local value = tonumber(select(i, ...))
                if value and value > 0 then
                    return value
                end
            end
            return nil
        end

        local function SafeGetDerivedPlayerStat(statType)
            if type(GetPlayerStat) ~= "function" or type(statType) ~= "number" then
                return nil
            end

            local applyBonus = type(STAT_BONUS_OPTION_APPLY_BONUS) == "number" and STAT_BONUS_OPTION_APPLY_BONUS or nil
            local applySoftCap = type(STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP) == "number" and STAT_SOFT_CAP_OPTION_APPLY_SOFT_CAP or nil

            local a, b, c, d = GetPlayerStat(statType, applyBonus, applySoftCap)
            local derivedValue = FirstPositiveNumber(a, b, c, d)
            if derivedValue then
                return derivedValue
            end

            a, b, c, d = GetPlayerStat(statType)
            return FirstPositiveNumber(a, b, c, d)
        end

        local function SafeGetCurrentPower(powerType)
            if type(powerType) ~= "table" then
                return nil
            end

            return SafeGetCurrentPowerFromList(powerType)
        end

        local function CompareRange(value, low, high)
            if value > high then
                return "TOO HIGH"
            end
            if value < low then
                return "LOW"
            end
            return "OK"
        end

        local function AddComparisonRow(label, value, low, high, note)
            local status = CompareRange(value, low, high)
            AddScrollableStatLine(
                string.format("%s: %s [%s]", label, NumberText(value), status),
                string.format("Target range: %s-%s | %s", NumberText(low), NumberText(high), note)
            )
        end
        
        local hpMax = SafeGetDerivedPlayerStat(STAT_HEALTH_MAX)
        local magMax = SafeGetDerivedPlayerStat(STAT_MAGICKA_MAX)
        local stamMax = SafeGetDerivedPlayerStat(STAT_STAMINA_MAX)
        
        local rpt = GetResourcePowerTypes()
        local hpCurrent = SafeGetCurrentPower(rpt.health)
        local magCurrent = SafeGetCurrentPower(rpt.magicka)
        local stamCurrent = SafeGetCurrentPower(rpt.stamina)

        local roleKey, roleProfile, roleSource = GetSelectedRoleComparisonProfile()

        if hpMax and magMax and stamMax then
            local primaryType = magMax >= stamMax and "Magicka" or "Stamina"
            local primaryMax = math.max(magMax, stamMax)
            local secondaryMax = math.min(magMax, stamMax)

            AddComparisonRow(
                "Max Health",
                hpMax,
                roleProfile.health[1],
                roleProfile.health[2],
                roleProfile.healthNote
            )
            AddComparisonRow(
                string.format("Primary Resource (%s)", primaryType),
                primaryMax,
                roleProfile.primary[1],
                roleProfile.primary[2],
                roleProfile.primaryNote
            )
            AddComparisonRow(
                "Secondary Resource",
                secondaryMax,
                roleProfile.secondary[1],
                roleProfile.secondary[2],
                roleProfile.secondaryNote
            )

            local resourceSummary = snapshot.resourceSummary or {}
            local hpStats = resourceSummary.health
            local magStats = resourceSummary.magicka
            local stamStats = resourceSummary.stamina
            local hasFightResourceSamples = (hpStats and hpStats.hasData)
                or (magStats and magStats.hasData)
                or (stamStats and stamStats.hasData)

            if hasFightResourceSamples then
                local sampleCount = resourceSummary.sampleCount or 0

                local function AddResourceAvgMedianRow(label, stats, maxValue)
                    if not stats or not stats.hasData or not maxValue or maxValue <= 0 then
                        AddScrollableStatLine(
                            string.format("%s Fight Avg/Median: n/a", label),
                            "No fight-duration resource samples available for this stat."
                        )
                        return
                    end

                    local avgValue = maxValue * (stats.averagePct / 100)
                    local medianValue = maxValue * (stats.medianPct / 100)
                    AddScrollableStatLine(
                        string.format(
                            "%s Fight Avg/Median: %s/%s (%.0f%%/%.0f%%)",
                            label,
                            NumberText(avgValue),
                            NumberText(medianValue),
                            stats.averagePct,
                            stats.medianPct
                        ),
                        string.format(
                            "Sampled every %.1fs while in combat (%d samples across this fight).",
                            RESOURCE_SAMPLE_INTERVAL_MS / 1000,
                            sampleCount
                        )
                    )
                end

                AddResourceAvgMedianRow("HP", hpStats, hpMax)
                AddResourceAvgMedianRow("MAG", magStats, magMax)
                AddResourceAvgMedianRow("STAM", stamStats, stamMax)
            else
                hpCurrent = hpCurrent or hpMax
                magCurrent = magCurrent or magMax
                stamCurrent = stamCurrent or stamMax

                local hpPct = (hpCurrent / hpMax) * 100
                local magPct = (magCurrent / magMax) * 100
                local stamPct = (stamCurrent / stamMax) * 100
                AddScrollableStatLine(
                    string.format("Current Resource State: HP %.0f%% | MAG %.0f%% | STAM %.0f%%", hpPct, magPct, stamPct),
                    "Fallback snapshot when fight-duration resource samples are not available yet."
                )
            end
        else
            AddScrollableStatLine(
                "Player Power Stats Unavailable",
                "Could not read GetPlayerStat-derived max pools in this context; comparison rows skipped."
            )
        end

        local critStatus = CompareRange(snapshot.critPct or 0, roleProfile.crit[1], roleProfile.crit[2])
        AddScrollableStatLine(
            string.format("Combat Crit Rate: %.1f%% [%s]", snapshot.critPct or 0, critStatus),
            string.format(
                "%s target range: %.0f%%-%.0f%%. %s",
                roleProfile.label,
                roleProfile.crit[1],
                roleProfile.crit[2],
                roleProfile.critNote
            )
        )

        local incomingDps = 0
        if snapshot.duration and snapshot.duration > 0 then
            incomingDps = (snapshot.totalTaken or 0) / snapshot.duration
        end
        AddScrollableStatLine(
            string.format("Incoming DPS Pressure: %s", ShortNumber(incomingDps)),
            "Use with health/resist checks: if pressure is low and survivability stats are high, those stats may be overbuilt."
        )

        AddFormulaSection("Diminishing Returns + Stop Points")

        local liveRes = Clamp(behavior.predictedResistance or 0, 0, RESISTANCE_CAP)
        local liveDr = Clamp((liveRes / RESISTANCE_SCALE) * 100, 0, 50)

        local statStep = 1000
        local nextRes = Clamp(liveRes + statStep, 0, RESISTANCE_CAP)
        local nextDr = Clamp((nextRes / RESISTANCE_SCALE) * 100, 0, 50)
        local drGainPct = math.max(0, nextDr - liveDr)

        local ehpNow = 1
        local ehpNext = 1
        if liveDr < 99.9 then
            ehpNow = 1 / (1 - (liveDr / 100))
        end
        if nextDr < 99.9 then
            ehpNext = 1 / (1 - (nextDr / 100))
        end
        local ehpGainPct = ((ehpNext / math.max(ehpNow, 0.0001)) - 1) * 100

        local penDrDropPct = (math.min(statStep, liveRes) / RESISTANCE_SCALE) * 100
        local afterPenRes = math.max(0, liveRes - statStep)
        local dmgMultNow = 1 - (liveRes / RESISTANCE_SCALE)
        local dmgMultAfterPen = 1 - (afterPenRes / RESISTANCE_SCALE)
        local penRelativeGainPct = 0
        if dmgMultNow > 0 then
            penRelativeGainPct = ((dmgMultAfterPen / dmgMultNow) - 1) * 100
        end

        AddFormulaRow(
            "Resistance DR Value (+1,000 Resist)",
            string.format("Live @%s res: +1000 -> +%.2f%% DR, +%.2f%% EHP", NumberText(liveRes), drGainPct, ehpGainPct),
            "DR gain is linear, but effective health gain accelerates as DR rises; practical stop near 30k-33k resist."
        )
        AddFormulaRow(
            "Penetration Value (+1,000 Pen)",
            string.format("Live @%s target res: -%.2f%% DR, +%.2f%% dmg mult", NumberText(liveRes), penDrDropPct, penRelativeGainPct),
            "Best stop: when total effective pen reaches target resist (about 18,200 PvE boss baseline; up to 33,000 PvP targets)."
        )
        AddFormulaRow(
            "Crit Chance DR Value",
            "DeltaDamagePer1PctCrit = CritDamageBonusPct / 100",
            "No hard DR curve; practical stop is when buffed crit chance is already high and another stat gives better DPS gain."
        )
        AddFormulaRow(
            "Crit Chance Practical Stop",
            string.format("TargetRange: %.0f%%-%.0f%% buffed for %s setups", roleProfile.crit[1], roleProfile.crit[2], roleProfile.label),
            roleProfile.critNote
        )
        AddFormulaRow(
            "Crit Damage DR Value",
            "DeltaDamagePer1PctCritDamage = CritChancePct / 100",
            "Hard stop at total crit damage cap (125%)."
        )
        AddFormulaRow(
            "Crit Damage Practical Stop",
            "Stop when TotalCritDamageBonus >= 125%",
            "After cap, invest in crit chance, penetration, raw damage, or sustain."
        )
        AddFormulaRow(
            "Weapon/Spell Damage DR Value",
            "PowerScaleApprox: 1 WSD approx 10.5 MaxResource",
            "No true DR; stop adding WSD when sustain or survivability costs outweigh equivalent DPS gain."
        )
        AddFormulaRow(
            "Max Resource DR Value",
            "PowerScaleApprox: +10.5 MaxResource approx +1 WSD",
            "No hard DR; stop when resource stacking gives less damage per slot than WSD or crit stats."
        )
        AddFormulaRow(
            "Recovery DR Value",
            "EffectiveSurplus = RecoveryIncome - RotationCost",
            "Stop when sustained surplus is consistently positive and deaths/rotational pressure come from damage, not sustain."
        )
        AddFormulaRow(
            "Healing Done DR Value",
            "HealedOutput = EffectiveHeal / CastTime",
            "No hard cap, but practical stop is when overheal is consistently high and mitigation/damage provides better team value."
        )
        AddFormulaRow(
            "Health DR Value",
            "EHP = Health / (1 - DR)",
            "Stop adding health when one-shot survivability is met and extra points reduce pressure output too much."
        )
        AddFormulaRow(
            "Summary Rule",
            "Stop adding a stat when marginal gain from +1 unit is lower than the best alternative stat",
            "Use marginal gain comparison per slot/trait/set bonus, not just raw character sheet values."
        )

        AddBackButton()
        AddCloseButton()
        return
    end

    if panel == "options" then
        dialog:AddSetting({
            type = LibHarvensAddonSettings.ST_SECTION,
            label = "Options Panel",
            tooltip = "Settings, control buttons, and command reference",
        })

        AddActionButton(self.saved.dialogAutoHide and "Dialog Auto Hide: ON" or "Dialog Auto Hide: OFF", "Toggle automatic dialog close when out of combat", function()
            self.saved.dialogAutoHide = not self.saved.dialogAutoHide
        end)

        AddActionButton(self.saved.autoClearOnNextFight and "Auto Clear: ON" or "Auto Clear: OFF", "Toggle auto clear when next combat starts", function()
            self.saved.autoClearOnNextFight = not self.saved.autoClearOnNextFight
        end)

        AddActionButton("Clear Fight Data", "Clear current and historical fight data", function()
            self:ResetFightData(false)
        end)

        dialog:AddSetting({
            type = LibHarvensAddonSettings.ST_SECTION,
            label = "Options Explained",
            tooltip = "Descriptions of all available commands and toggles",
        })

        local optionHelpLines = {
            "Previous/Next Fight: Navigate stored fight history.",
            "View Live Fight: Return to current active combat data.",
            "Formula Panel: ESO stat equations and addon formulas.",
            "Build Snapshot Panel: Current bars, gear, and boon-style snapshot.",
            "Resource Panel Delay/Ping: Tracks latency averages, dips, spikes, and high-delay samples.",
            "Print Build Debug: Dumps build-panel data to chat for API verification.",
            "Save Fight Panel: Type a custom save name before persisting.",
            "Saved Fights Panel: Persist fights across sessions.",
            "Load Saved Fight By Name: Type a saved label and load that one fight.",
            "Dialog Auto Hide: Auto closes the dialog after combat.",
            "Auto Clear: Clears scroll/live panel data on next fight.",
            "Clear Fight Data: Wipes current fight and full history.",
            "Print Debug Snapshot: Dumps only current-fight data to chat.",
            "Slash /cm savefight [name]: Save viewed fight to saved slots.",
            "Slash /cm loadfight <name>: Load one saved fight by name.",
            "Slash /cm loadfightexact <name>: Load one saved fight by exact name only.",
            "Slash /cm loadsaves: Load all saved fights into history.",
            "Slash /cm dumpcpslottables: Dump confirmed Champion slottable IDs.",
            "Slash /cm linkbuild: Pre-fill chat input with a compact build summary.",
        }
        for i = 1, #optionHelpLines do
            AddScrollableStatLine(optionHelpLines[i], "Option explanation")
        end

        AddBackButton()
        AddCloseButton()
        return
    end

    if panel == "saves" then
        local saves = self.saved.savedFights or {}
        local maxSaves = tonumber(self.saved.maxSavedFights) or self.defaults.maxSavedFights
        dialog:AddSetting({
            type = LibHarvensAddonSettings.ST_SECTION,
            label = string.format("Saved Fights (%d/%d)", #saves, maxSaves),
            tooltip = "Fights saved here persist across sessions. Load a slot to browse it in history.",
        })

        AddActionButton(
            string.format("Open Save Fight Panel (%s)", isLive and "Live" or string.format("Fight %d", self.viewFightIndex)),
            "Open the separate naming panel before persisting this fight.",
            function()
                if TrimText(self.saved.saveFightDraftName or "") == "" then
                    self.saved.saveFightDraftName = BuildDefaultFightSaveName(snapshot, #saves + 1)
                end
                self.dialogPanel = "save"
            end
        )

        dialog:AddSetting({
            type = LibHarvensAddonSettings.ST_EDIT,
            label = "Load Saved Fight Name",
            tooltip = "Type the saved fight label to load that fight directly into history.",
            getFunction = function()
                return self.saved.loadFightDraftName or ""
            end,
            setFunction = function(value)
                self.saved.loadFightDraftName = TrimText(value)
            end,
            maxChars = 120,
        })

        AddActionButton(
            "Load Saved Fight By Name",
            "Load one saved fight by typed name (exact match, then partial match fallback).",
            function()
                local ok, msg = self:LoadSavedFightIntoHistoryByName(self.saved.loadFightDraftName or "")
                self:Print(msg)
                if ok then
                    self.dialogPanel = "main"
                end
            end
        )

        if #saves == 0 then
            AddScrollableStatLine("No saved fights yet. View a fight and press Save above.", "Save fights to access them across sessions and reloads.")
        else
            for i = 1, #saves do
                local entry = saves[i]
                if entry and entry.snapshot then
                    local snap = entry.snapshot
                    local topTarget = snap.targetList and snap.targetList[1]
                    local targetDesc = topTarget and (" vs " .. (topTarget.name or "?")) or ""
                    AddScrollableStatLine(
                        string.format("%s%s  |  %s dmg / %s heal / %s taken",
                            entry.label or string.format("Slot %d", i),
                            targetDesc,
                            ShortNumber(snap.totalDamage or 0),
                            ShortNumber(snap.totalHeal or 0),
                            ShortNumber(snap.totalTaken or 0)
                        ),
                        string.format("Duration: %.1fs | Crit: %.1f%% | Peak DPS: %s",
                            snap.duration or 0, snap.critPct or 0, ShortNumber(snap.peakDps or 0))
                    )
                    local slotIndex = i
                    AddActionButton(
                        string.format("Load Slot %d Into History", slotIndex),
                        string.format("Add saved slot %d to fight history so you can browse it with Prev/Next.", slotIndex),
                        function()
                            local ok, msg = self:LoadSavedFightIntoHistory(slotIndex)
                            self:Print(msg)
                            self.dialogPanel = "main"
                        end
                    )
                    AddActionButton(
                        string.format("Delete Slot %d", slotIndex),
                        string.format("Permanently delete saved slot %d.", slotIndex),
                        function()
                            local ok, msg = self:DeleteSavedFight(slotIndex)
                            self:Print(msg)
                        end
                    )
                end
            end
        end

        if #saves > 0 then
            AddActionButton("Clear All Saves", "Delete all saved fight slots permanently.", function()
                self.saved.savedFights = {}
                self:Print("All saved fights cleared.")
            end)
        end

        AddBackButton()
        AddCloseButton()
        return
    end

    self.dialogPanel = "main"
    RefreshDialog()
end

function ConsoleMetrics:OpenFightViewDialog(forceLive)
    if not LibConsoleDialogs or not LibHarvensAddonSettings then
        self:Print("LibConsoleDialogs not found. Install/enable it in this game folder to use /cm view.")
        return
    end

    if forceLive then
        self.viewFightIndex = 0
        self.dialogPanel = "main"
    elseif not self.dialogPanel then
        self.dialogPanel = "main"
    end

    if self.ui.root then
        self.ui.root:SetHidden(true)
    end

    if not self.ui.fightViewDialog then
        self.ui.fightViewDialog = LibConsoleDialogs:Create("Console Metrics")
    end

    self:PopulateFightViewDialog(self.ui.fightViewDialog)
    self.ui.fightViewDialog:Show()
    self:ArmDialogAutoHide()
    self.dialogRefreshAtMs = 0
end

function ConsoleMetrics:RegisterJournalSceneKeybinds()
    if not LibConsoleDialogs or not SCENE_MANAGER then
        return 0
    end

    self.registeredJournalScenes = self.registeredJournalScenes or {}
    local candidateScenes = {
        "gamepad_journal_root",
        "gamepad_journal",
        "journal",
        "gamepad_quest_journal",
        "gamepad_activities",
    }

    local function TryRegisterScene(sceneName, scene)
        if not sceneName or not scene or self.registeredJournalScenes[sceneName] then
            return false
        end

        LibConsoleDialogs:RegisterKeybind(scene, {
            name = function()
                return "Console Metrics"
            end,
            tooltip = function()
                return "Open Console Metrics"
            end,
            callback = function()
                self:OpenFightViewDialog(true)
            end,
            visible = function()
                return true
            end,
            enabled = function()
                return true
            end,
            order = 2200,
        })

        self.registeredJournalScenes[sceneName] = true
        return true
    end

    local added = 0
    for i = 1, #candidateScenes do
        local sceneName = candidateScenes[i]
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if TryRegisterScene(sceneName, scene) then
            added = added + 1
        end
    end

    if SCENE_MANAGER.scenes then
        for sceneName, scene in pairs(SCENE_MANAGER.scenes) do
            local nameLower = string.lower(tostring(sceneName))
            if string.find(nameLower, "journal", 1, true) ~= nil then
                if TryRegisterScene(sceneName, scene) then
                    added = added + 1
                end
            end
        end
    end

    return added
end

function ConsoleMetrics:InsertIntoJournalMenu()
    local openDialog = function()
        self:OpenFightViewDialog(true)
    end

    local function ToText(value)
        if type(value) == "number" then
            return tostring(GetString(value))
        end
        if value == nil then
            return ""
        end
        return tostring(value)
    end

    local function AddSubmenuEntry(subMenu)
        for _, subItem in ipairs(subMenu) do
            if subItem and (subItem.consoleMetricsEntry or subItem.name == "Console Metrics") then
                return false
            end
        end

        subMenu[#subMenu + 1] = {
            name = "Console Metrics",
            icon = "EsoUI/Art/Journal/journal_tabicon_log_up.dds",
            activatedCallback = openDialog,
            callback = openDialog,
            enabled = function()
                return true
            end,
            consoleMetricsEntry = true,
        }
        return true
    end

    local injected = false
    local journalLabel = SI_MAIN_MENU_JOURNAL and GetString(SI_MAIN_MENU_JOURNAL) or "Journal"

    -- Preferred path: patch live gamepad menu data and add an item into Journal's submenu.
    if MAIN_MENU_GAMEPAD and MAIN_MENU_GAMEPAD.categoryList and MAIN_MENU_GAMEPAD.categoryList.dataList then
        local list = MAIN_MENU_GAMEPAD.categoryList
        local dataList = list.dataList

        for _, entry in ipairs(dataList) do
            local data = entry and entry.data
            local idText = string.lower(ToText(entry and entry.id))
            local textLower = string.lower(ToText(data and data.text))
            local nameLower = string.lower(ToText(data and data.name))

            local isJournal = idText:find("journal", 1, true) ~= nil
                or textLower == string.lower(journalLabel)
                or nameLower == string.lower(journalLabel)
                or textLower == "journal"
                or nameLower == "journal"

            if isJournal and data and type(data.subMenu) == "table" then
                AddSubmenuEntry(data.subMenu)
                if list.Commit then
                    list:Commit()
                end
                injected = true
                break
            end
        end
    end

    if not injected and type(ZO_MENU_ENTRIES) == "table" then
        for _, entry in ipairs(ZO_MENU_ENTRIES) do
            local data = entry and entry.data
            local idText = entry and entry.id and string.lower(tostring(entry.id)) or ""

            local nameText = ToText(data and data.name)
            local nameLower = string.lower(nameText)

            local isJournal = idText:find("journal", 1, true) ~= nil
                or nameText == journalLabel
                or nameLower == "journal"

            if isJournal and data then
                data.subMenu = data.subMenu or {}
                AddSubmenuEntry(data.subMenu)

                injected = true
                break
            end
        end
    end

    -- Last-resort fallback for builds with no Journal submenu structure.
    if not injected and MAIN_MENU_GAMEPAD and MAIN_MENU_GAMEPAD.categoryList then
        local list = MAIN_MENU_GAMEPAD.categoryList
        local dataList = list.dataList
        if dataList then
            local insertIndex = #dataList + 1

            for i, entry in ipairs(dataList) do
                local data = entry and entry.data
                local text = ToText(data and data.text)

                if text == journalLabel or text == "Journal" then
                    insertIndex = i + 1
                    break
                end
            end

            local entryData = ZO_GamepadEntryData:New("Console Metrics", "EsoUI/Art/Journal/journal_tabicon_log_up.dds")
            entryData.consoleMetricsEntry = true
            entryData.callback = openDialog

            if entryData.SetIconTintOnSelection then
                entryData:SetIconTintOnSelection(true)
            end

            table.insert(dataList, insertIndex, { template = "ZO_GamepadMenuEntryTemplate", data = entryData })
            if list.Commit then
                list:Commit()
            end
            injected = true
        end
    end

    if injected and MAIN_MENU_GAMEPAD and MAIN_MENU_GAMEPAD.RefreshMainList then
        MAIN_MENU_GAMEPAD:RefreshMainList()
    end

    self.journalMenuInserted = injected
    return injected
end

function ConsoleMetrics:RefreshJournalIntegration(showStatus)
    local menuReady = self:InsertIntoJournalMenu()
    local sceneHooks = self:RegisterJournalSceneKeybinds()

    if showStatus then
        if menuReady then
            self:Print(string.format("Journal menu item ready (scene hooks: %d)", sceneHooks))
        else
            self:Print("Journal menu item still unavailable in current menu state")
        end
    end

    return menuReady, sceneHooks
end

function ConsoleMetrics:Print(message)
    d(string.format("|cFF6A00[%s]|r %s", self.name, tostring(message)))
end

function ConsoleMetrics:LinkBuildToChat()
    local frontBarCategory = type(HOTBAR_CATEGORY_PRIMARY) == "number" and HOTBAR_CATEGORY_PRIMARY or nil
    local backBarCategory = type(HOTBAR_CATEGORY_BACKUP) == "number" and HOTBAR_CATEGORY_BACKUP or nil
    local frontBar = BuildActionBarSnapshot(frontBarCategory)
    local backBar = BuildActionBarSnapshot(backBarCategory)
    local championSnapshot = BuildChampionSnapshot()
    local equippedSets = BuildEquippedSetSummary()
    local boons = BuildActiveBoonSnapshot()

    local function ShortName(name, maxLen)
        if type(name) ~= "string" or name == "" then return "?" end
        maxLen = maxLen or 14
        if #name <= maxLen then return name end
        local first = string.match(name, "^(%S+)")
        if first and #first <= maxLen then return first end
        return string.sub(name, 1, maxLen)
    end

    local function BarNames(bar)
        local names = {}
        for i = 1, #bar do
            local name = bar[i].abilityName
            if name and name ~= "Empty" and name ~= "" then
                names[#names + 1] = ShortName(name, 13)
            end
        end
        if #names == 0 then return "-" end
        return table.concat(names, ", ")
    end

    local function BucketText(entries)
        if not entries or #entries == 0 then return nil end
        local parts = {}
        for i = 1, #entries do
            local e = entries[i]
            local pts = (e.points and e.points > 0) and tostring(e.points) or "0"
            local stars = #(e.stars or {}) > 0 and ("[" .. table.concat(e.stars, ",") .. "]") or ""
            parts[#parts + 1] = ShortName(e.name, 10) .. ":" .. pts .. stars
        end
        return table.concat(parts, " ")
    end

    local cp = championSnapshot.totalPoints and NumberText(championSnapshot.totalPoints) or "?"
    local wf = BucketText(championSnapshot.warfare)
    local fn = BucketText(championSnapshot.fitness)
    local cr = BucketText(championSnapshot.craft)

    local cpText = "CP:" .. cp
    if wf then cpText = cpText .. " WF(" .. wf .. ")" end
    if fn then cpText = cpText .. " FN(" .. fn .. ")" end
    if cr then cpText = cpText .. " CR(" .. cr .. ")" end

    local setNames = {}
    for i = 1, #equippedSets do
        local s = equippedSets[i]
        if s.setName and s.setName ~= "" then
            setNames[#setNames + 1] = ShortName(s.setName, 18) .. "(" .. (s.numEquipped or 0) .. ")"
        end
    end
    local setsText = #setNames > 0 and table.concat(setNames, ", ") or "-"

    local boonText = #boons > 0 and ShortName(boons[1], 18) or "-"

    local parts = {
        "[CM Build]",
        cpText,
        "Sets: " .. setsText,
        "F[" .. BarNames(frontBar) .. "]",
        "B[" .. BarNames(backBar) .. "]",
        "Boon: " .. boonText,
    }
    local chatLine = table.concat(parts, " | ")

    if #chatLine > 350 then
        chatLine = string.sub(chatLine, 1, 347) .. "..."
    end

    if type(CHAT_SYSTEM) == "table" and type(CHAT_SYSTEM.StartTextEntry) == "function" then
        CHAT_SYSTEM:StartTextEntry(chatLine)
        self:Print("Build ready to link — choose a channel and press Enter.")
    else
        self:Print(chatLine)
        self:Print("(Copy the line above and paste it into chat.)")
    end
end

function ConsoleMetrics:PrintBuildSnapshotDebug(reason)
    local source = reason or "manual"
    local frontBarCategory = type(HOTBAR_CATEGORY_PRIMARY) == "number" and HOTBAR_CATEGORY_PRIMARY or nil
    local backBarCategory = type(HOTBAR_CATEGORY_BACKUP) == "number" and HOTBAR_CATEGORY_BACKUP or nil
    local frontBar = BuildActionBarSnapshot(frontBarCategory)
    local backBar = BuildActionBarSnapshot(backBarCategory)
    local championSnapshot = BuildChampionSnapshot()
    local equippedSets = BuildEquippedSetSummary()
    local weaponEffects = BuildWeaponEffectSnapshot()
    local procTimers = self:BuildProcTimerSnapshot()
    local boons = BuildActiveBoonSnapshot()

    local function JoinOrFallback(values, fallback)
        if type(values) ~= "table" or #values == 0 then
            return fallback
        end
        return table.concat(values, ", ")
    end

    local function PrintBar(label, entries)
        self:Print(string.format("DEBUGBUILD [%s]", label))
        for i = 1, #entries do
            local entry = entries[i]
            self:Print(string.format(
                "  %s -> %s (id=%d)",
                entry.slotLabel or string.format("Slot %d", i),
                entry.abilityName or "Empty",
                entry.abilityId or 0
            ))
        end
    end

    local function PrintChampionBucket(label, entries)
        self:Print(string.format("DEBUGBUILD [%s]", label))
        if #entries == 0 then
            self:Print("  unavailable")
            return
        end
        for i = 1, #entries do
            local entry = entries[i]
            self:Print(string.format(
                "  %s pts=%s stars=%s",
                entry.name or "Unknown",
                NumberText(entry.points or 0),
                JoinOrFallback(entry.stars, "none")
            ))
            -- Print debug info when stars are missing (even if points show)
            if #(entry.stars or {}) == 0 and type(entry.debug) == "table" then
                self:Print(string.format(
                    "    probe disciplineId=%s index=%s type=%s",
                    tostring(entry.debug.disciplineId),
                    tostring(entry.debug.disciplineIndex),
                    tostring(entry.debug.disciplineType)
                ))
                local pointsProbes = entry.debug.pointsProbes or {}
                if #pointsProbes > 0 then
                    for j = 1, #pointsProbes do
                        self:Print("    " .. tostring(pointsProbes[j]))
                    end
                else
                    self:Print("    no discipline point probe results")
                end

                local skillPointProbes = entry.debug.skillPointProbes or {}
                if #skillPointProbes > 0 then
                    for j = 1, math.min(12, #skillPointProbes) do
                        self:Print("    " .. tostring(skillPointProbes[j]))
                    end
                else
                    self:Print("    no skill point probe results")
                end
            end
        end
        -- Print slot debug info at end of each bucket if any stars are missing
        if type(championSnapshot._slotDebugInfo) == "table" then
            local hasEmptyStars = false
            for i = 1, #entries do
                if #(entries[i].stars or {}) == 0 then
                    hasEmptyStars = true
                    break
                end
            end
            if hasEmptyStars then
                local foundIdsList = {}
                if type(championSnapshot._slotDebugInfo.foundIds) == "table" then
                    for id, _ in pairs(championSnapshot._slotDebugInfo.foundIds) do
                        foundIdsList[#foundIdsList + 1] = tostring(id)
                    end
                end
                self:Print(string.format(
                    "    SLOT DEBUG: numSlots=%s probeMax=%s foundIds=%s",
                    tostring(championSnapshot._slotDebugInfo.resolvedNumSlots),
                    tostring(championSnapshot._slotDebugInfo.probeMax),
                    #foundIdsList > 0 and table.concat(foundIdsList, ",") or "none"
                ))
                local probes = championSnapshot._slotDebugInfo.probes or {}
                if #probes > 0 then
                    for j = 1, math.min(12, #probes) do
                        self:Print("    " .. tostring(probes[j]))
                    end
                else
                    self:Print("    SLOT DEBUG: no probes found any slotted skills")
                end
            end
        end
    end

    self:Print(string.format(
        "DEBUGBUILD[%s] cp=%s sets=%d weapons=%d procs=%d boons=%d",
        source,
        championSnapshot.totalPoints and NumberText(championSnapshot.totalPoints) or "n/a",
        #equippedSets,
        #weaponEffects,
        #procTimers,
        #boons
    ))

    PrintBar("Front Bar", frontBar)
    PrintBar("Back Bar", backBar)
    PrintChampionBucket("Warfare", championSnapshot.warfare)
    PrintChampionBucket("Fitness", championSnapshot.fitness)
    PrintChampionBucket("Craft", championSnapshot.craft)

    self:Print("DEBUGBUILD [Equipped Sets]")
    if #equippedSets == 0 then
        self:Print("  unavailable")
    else
        for i = 1, #equippedSets do
            local entry = equippedSets[i]
            self:Print(string.format(
                "  %s (%d/%d) slots=%s",
                entry.setName or "Unknown Set",
                entry.numEquipped or 0,
                entry.maxEquipped or 0,
                JoinOrFallback(entry.slots, "none")
            ))
        end
    end

    self:Print("DEBUGBUILD [Weapon Effects]")
    if #weaponEffects == 0 then
        self:Print("  unavailable")
    else
        for i = 1, #weaponEffects do
            local entry = weaponEffects[i]
            self:Print(string.format(
                "  %s item=%s enchant=%s poison=%s",
                entry.label or string.format("Weapon %d", i),
                entry.itemText or "Unknown",
                entry.enchantText or "Unavailable",
                entry.poisonText or "None"
            ))
        end
    end

    self:Print("DEBUGBUILD [Proc Timers]")
    if #procTimers == 0 then
        self:Print("  unavailable")
    else
        for i = 1, #procTimers do
            local entry = procTimers[i]
            self:Print(string.format(
                "  %s state=%s cd=%.1fs equipped=%d/%d slots=%s pct=%s cm=%s",
                entry.label or "Unknown Proc",
                entry.stateText or "Ready",
                (entry.cooldownMs or 0) / 1000,
                entry.numEquipped or 0,
                entry.maxEquipped or 0,
                JoinOrFallback(entry.slots, "none"),
                tostring(entry.fromPCT == true),
                tostring(entry.fromCustomRule == true)
            ))
        end
    end

    self:Print("DEBUGBUILD [Boon / Mundus]")
    if #boons == 0 then
        self:Print("  unavailable")
    else
        for i = 1, #boons do
            self:Print(string.format("  %s", boons[i]))
        end
    end
end

function ConsoleMetrics:GetFightDuration(nowMs)
    if not self.fight or not self.fight.startMs then
        return 0
    end

    local endMs = nowMs
    if self.fight.endMs then
        endMs = self.fight.endMs
    end

    return math.max((endMs - self.fight.startMs) / 1000, 0)
end

function ConsoleMetrics:PushScrollLine(text, color)
    self.scrollEntries[#self.scrollEntries + 1] = {
        text = text,
        color = color,
        timeMs = GetFrameTimeMilliseconds(),
    }

    while #self.scrollEntries > self.saved.scrollSize do
        table.remove(self.scrollEntries, 1)
    end

    self:RefreshScroll()
end

function ConsoleMetrics:TrackSkill(abilityId, abilityName, damageValue, healValue, isCrit)
    local skillId = abilityId or 0
    local info = self.fight.skillMap[skillId]
    if not info then
        info = {
            abilityId = skillId,
            name = abilityName ~= "" and abilityName or "Unknown Skill",
            damage = 0,
            heal = 0,
            hits = 0,
            crits = 0,
        }
        self.fight.skillMap[skillId] = info
    end

    info.damage = info.damage + damageValue
    info.heal = info.heal + healValue
    info.hits = info.hits + 1
    if isCrit then
        info.crits = info.crits + 1
    end
end

function ConsoleMetrics:TrackDotTick(abilityId, abilityName, damageValue, isCrit)
    local skillId = abilityId or 0
    local info = self.fight.dotMap[skillId]
    if not info then
        info = {
            abilityId = skillId,
            name = (abilityName and abilityName ~= "") and abilityName or "Unknown DoT",
            damage = 0,
            heal = 0,
            hits = 0,
            crits = 0,
        }
        self.fight.dotMap[skillId] = info
    end
    info.damage = info.damage + damageValue
    info.hits = info.hits + 1
    if isCrit then
        info.crits = info.crits + 1
    end
end

function ConsoleMetrics:TrackHotTick(abilityId, abilityName, healValue, isCrit)
    local skillId = abilityId or 0
    local info = self.fight.hotMap[skillId]
    if not info then
        info = {
            abilityId = skillId,
            name = (abilityName and abilityName ~= "") and abilityName or "Unknown HoT",
            damage = 0,
            heal = 0,
            hits = 0,
            crits = 0,
        }
        self.fight.hotMap[skillId] = info
    end
    info.heal = info.heal + healValue
    info.hits = info.hits + 1
    if isCrit then
        info.crits = info.crits + 1
    end
end

function ConsoleMetrics:TrackIncomingSkill(abilityId, abilityName, damageValue, isCrit, sourceName)
    if not self.fight or damageValue <= 0 then
        return
    end

    local skillId = abilityId or 0
    local info = self.fight.incomingSkillMap[skillId]
    if not info then
        info = {
            abilityId = skillId,
            name = (abilityName and abilityName ~= "") and abilityName or "Unknown Enemy Skill",
            damage = 0,
            heal = 0,
            hits = 0,
            crits = 0,
            source = UnitName(sourceName),
        }
        self.fight.incomingSkillMap[skillId] = info
    end

    info.damage = info.damage + damageValue
    info.hits = info.hits + 1
    if isCrit then
        info.crits = info.crits + 1
    end
    if not info.source or info.source == "Unknown" then
        info.source = UnitName(sourceName)
    end
end

function ConsoleMetrics:TrackIncomingSetDamage(abilityId, abilityName, damageValue, isCrit, sourceName)
    if not self.fight or damageValue <= 0 then
        return
    end

    local setMatch = self:MatchTrackedSet(abilityId, abilityName)
    if not setMatch then
        return
    end

    local key = string.lower(setMatch.label)
    local info = self.fight.incomingSetDamageMap[key]
    if not info then
        info = {
            abilityId = SafeAbilityId(abilityId),
            name = setMatch.label,
            damage = 0,
            heal = 0,
            hits = 0,
            crits = 0,
            scene = setMatch.scene,
            effectName = abilityName,
            source = UnitName(sourceName),
        }
        self.fight.incomingSetDamageMap[key] = info
    end

    info.damage = info.damage + damageValue
    info.hits = info.hits + 1
    if isCrit then
        info.crits = info.crits + 1
    end
    if (not info.abilityId or info.abilityId == 0) and SafeAbilityId(abilityId) > 0 then
        info.abilityId = SafeAbilityId(abilityId)
    end
    if (not info.effectName or info.effectName == "") and abilityName and abilityName ~= "" then
        info.effectName = abilityName
    end
    if not info.source or info.source == "Unknown" then
        info.source = UnitName(sourceName)
    end
end

function ConsoleMetrics:TrackIncomingLikelySetProc(abilityId, abilityName, damageValue, isCrit, sourceName)
    if not self.fight or damageValue <= 0 then
        return
    end

    if self:MatchTrackedSet(abilityId, abilityName) then
        return
    end

    local matched, reason, score = ClassifyLikelySetProc(abilityName)
    if not matched then
        return
    end

    local key = string.lower(abilityName or "unknown")
    local info = self.fight.incomingLikelySetProcMap[key]
    if not info then
        info = {
            abilityId = SafeAbilityId(abilityId),
            name = (abilityName and abilityName ~= "") and abilityName or "Unknown Likely Set Proc",
            damage = 0,
            heal = 0,
            hits = 0,
            crits = 0,
            source = UnitName(sourceName),
            heuristicReason = reason,
            heuristicScore = score,
        }
        self.fight.incomingLikelySetProcMap[key] = info
    end

    info.damage = info.damage + damageValue
    info.hits = info.hits + 1
    if isCrit then
        info.crits = info.crits + 1
    end
    if (not info.abilityId or info.abilityId == 0) and SafeAbilityId(abilityId) > 0 then
        info.abilityId = SafeAbilityId(abilityId)
    end
    if not info.source or info.source == "Unknown" then
        info.source = UnitName(sourceName)
    end
    if (not info.heuristicReason or info.heuristicReason == "") and reason and reason ~= "" then
        info.heuristicReason = reason
    end
    if score and score > (info.heuristicScore or 0) then
        info.heuristicScore = score
    end
end

function ConsoleMetrics:StartFight()
    if self.inCombat then
        return
    end

    local nowMs = GetFrameTimeMilliseconds()
    self.inCombat = true
    self.hideAtMs = nil
    self.viewFightIndex = 0

    if self.saved.autoClearOnNextFight then
        self.scrollEntries = {}
    end

    self.fight = NewFight(nowMs)
    self:SampleFightResources(nowMs, true)
    self.lastDebugPrintAtMs = nil

    if self.ui.root then
        self.ui.root:SetHidden(true)
    end

    self:PushScrollLine("Combat started", COMBAT_TEXT_COLORS.start)
    self:UpdateMetrics()
end

function ConsoleMetrics:StopFight()
    if not self.inCombat or not self.fight then
        return
    end

    local nowMs = GetFrameTimeMilliseconds()
    self:SampleFightResources(nowMs, true)
    self:UpdateProtectionInference(nowMs)
    self.inCombat = false
    self.fight.endMs = nowMs
    self.hideAtMs = nowMs + POST_COMBAT_VISIBLE_MS

    local duration = self:GetFightDuration(nowMs)
    local dps = 0
    if duration > 0 then
        dps = self.fight.totalDamage / duration
    end

    self:PushScrollLine(
        string.format(
            "Fight: %ss, %s DPS, %s HPS",
            string.format("%.1f", duration),
            ShortNumber(dps),
            ShortNumber(duration > 0 and (self.fight.totalHeal / duration) or 0)
        ),
        COMBAT_TEXT_COLORS.summary
    )

    self:AddCurrentFightToHistory()
    if self:IsFightViewDialogShowing() then
        self:ArmDialogAutoHide()
    end
    self:UpdateMetrics()
end

function ConsoleMetrics:OnCombatState(_, inCombat)
    if inCombat then
        self:StartFight()
    else
        self:StopFight()
    end
end

function ConsoleMetrics:OnCombatEvent(
    _,
    result,
    _,
    abilityName,
    _,
    _,
    sourceName,
    sourceType,
    targetName,
    targetType,
    hitValue,
    _,
    _,
    _,
    _,
    _,
    abilityId,
    overflow
)
    local nowMs = GetFrameTimeMilliseconds()
    local effectiveValue = hitValue or 0
    local overflowValue = overflow or 0
    -- Effect state transitions frequently carry zero hit values, so we must keep them for uptime tracking.
    local isEffectStateChange = IsEffectGainedResult(result) or IsEffectFadedResult(result)

    if not self.inCombat or not self.fight or ((effectiveValue <= 0 and overflowValue <= 0) and not isEffectStateChange) then
        return
    end

    local sourceIsPlayer = sourceType == COMBAT_UNIT_TYPE_PLAYER
        or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET
        or UnitName(sourceName) == self.playerName
    local targetIsPlayer = targetType == COMBAT_UNIT_TYPE_PLAYER or UnitName(targetName) == self.playerName

    local didDamage = IsDamageResult(result)
    local didHeal = IsHealResult(result)
    local isCrit = IsCriticalResult(result)
    local safeAbilityName = (abilityName and abilityName ~= "") and abilityName or "Unknown Skill"
    local totalCombatValue = effectiveValue + overflowValue

    -- Accumulate every unique ability name→ID pair seen this session for /cm dumpsets discovery.
    local safeIdForLog = SafeAbilityId(abilityId)
    if safeIdForLog > 0 and safeAbilityName ~= "Unknown Skill" and not self.observedAbilityLog[safeIdForLog] then
        self.observedAbilityLog[safeIdForLog] = safeAbilityName
    end

    -- Update effect trackers before damage/heal aggregation so live dialog refresh sees current uptime state.
    self:TrackMajorMinorAndSets(
        nowMs,
        result,
        abilityId,
        safeAbilityName,
        sourceIsPlayer,
        targetIsPlayer,
        didDamage,
        didHeal,
        totalCombatValue
    )

    if sourceIsPlayer and (didDamage or didHeal) then
        local damageValue = didDamage and (effectiveValue + overflowValue) or 0
        local healValue = didHeal and effectiveValue or 0
        local overflowHealValue = didHeal and overflowValue or 0

        self.fight.totalDamage = self.fight.totalDamage + damageValue
        self.fight.totalOverflowDamage = self.fight.totalOverflowDamage + (didDamage and overflowValue or 0)
        self.fight.totalHeal = self.fight.totalHeal + healValue
        self.fight.totalOverflowHeal = self.fight.totalOverflowHeal + overflowHealValue
        self.fight.hits = self.fight.hits + 1
        if isCrit then
            self.fight.crits = self.fight.crits + 1
        end

        if didDamage and result == ACTION_RESULT_BLOCKED_DAMAGE then
            self.fight.totalBlockedDamage = self.fight.totalBlockedDamage + damageValue
        end

        if didDamage then
            if result == ACTION_RESULT_DAMAGE_SHIELDED then
                self.fight.totalShieldedDamage = self.fight.totalShieldedDamage + damageValue
            elseif overflowValue > 0 then
                self.fight.totalShieldedDamage = self.fight.totalShieldedDamage + overflowValue
            end
        end

        self:TrackSkill(abilityId, safeAbilityName, damageValue, healValue, isCrit)
        -- Track periodic ticks separately for per-ability DoT/HoT breakdown lists.
        if didDamage and (result == ACTION_RESULT_DOT_TICK or result == ACTION_RESULT_DOT_TICK_CRITICAL) then
            self:TrackDotTick(abilityId, safeAbilityName, damageValue, isCrit)
        end
        if didHeal and (result == ACTION_RESULT_HOT_TICK or result == ACTION_RESULT_HOT_TICK_CRITICAL) then
            self:TrackHotTick(abilityId, safeAbilityName, healValue, isCrit)
        end
        if didHeal then
            self:RecordTopHealingMoment(
                abilityId,
                safeAbilityName,
                UnitName(targetName),
                healValue,
                overflowHealValue,
                isCrit
            )
        end

        if didDamage then
            local targetInfo = self:AcquireTargetInfo(UnitName(targetName))
            targetInfo.damage = targetInfo.damage + damageValue
            targetInfo.effective = targetInfo.effective + effectiveValue
            targetInfo.overflow = targetInfo.overflow + overflowValue
            targetInfo.hits = targetInfo.hits + 1

            if result == ACTION_RESULT_BLOCKED_DAMAGE then
                targetInfo.blocked = targetInfo.blocked + damageValue
                self:RecordTopMitigationMoment(
                    "-",
                    UnitName(targetName),
                    "Outgoing blocked",
                    damageValue,
                    abilityId,
                    safeAbilityName
                )
            end

            if result == ACTION_RESULT_DAMAGE_SHIELDED then
                targetInfo.shielded = targetInfo.shielded + damageValue
                self:RecordTopMitigationMoment(
                    "-",
                    UnitName(targetName),
                    "Outgoing shielded",
                    damageValue,
                    abilityId,
                    safeAbilityName
                )
            elseif overflowValue > 0 then
                targetInfo.shielded = targetInfo.shielded + overflowValue
                self:RecordTopMitigationMoment(
                    "-",
                    UnitName(targetName),
                    "Outgoing overflow",
                    overflowValue,
                    abilityId,
                    safeAbilityName
                )
            end
        end

        if didDamage then
            local overflowText = overflowValue > 0 and string.format(" (+%s ovf)", ShortNumber(overflowValue)) or ""
            self:PushScrollLine(
                string.format("%s%s  %s", ShortNumber(damageValue), overflowText, FormatAbilityIdentity(safeAbilityName, abilityId)),
                isCrit and COMBAT_TEXT_COLORS.damageCrit or COMBAT_TEXT_COLORS.damage
            )
        elseif didHeal then
            local overflowText = overflowHealValue > 0 and string.format(" (+%s ovh)", ShortNumber(overflowHealValue)) or ""
            self:PushScrollLine(
                string.format("+%s%s  %s", ShortNumber(healValue), overflowText, FormatAbilityIdentity(safeAbilityName, abilityId)),
                isCrit and COMBAT_TEXT_COLORS.healCrit or COMBAT_TEXT_COLORS.heal
            )
        end
    end

    if targetIsPlayer and didDamage and not sourceIsPlayer then
        self.fight.totalTaken = self.fight.totalTaken + effectiveValue
        self.fight.totalIncomingOverflowDamage = self.fight.totalIncomingOverflowDamage + overflowValue

        local incomingDamageValue = effectiveValue + overflowValue
        self:TrackIncomingSkill(abilityId, safeAbilityName, incomingDamageValue, isCrit, sourceName)
        self:TrackIncomingSetDamage(abilityId, safeAbilityName, incomingDamageValue, isCrit, sourceName)
        self:TrackIncomingLikelySetProc(abilityId, safeAbilityName, incomingDamageValue, isCrit, sourceName)
        if result == ACTION_RESULT_BLOCKED_DAMAGE then
            self.fight.totalIncomingBlockedDamage = self.fight.totalIncomingBlockedDamage + incomingDamageValue
            self:RecordTopMitigationMoment(
                "+",
                UnitName(sourceName),
                "Incoming blocked",
                incomingDamageValue,
                abilityId,
                safeAbilityName
            )
        end
        if result == ACTION_RESULT_DAMAGE_SHIELDED then
            self.fight.totalIncomingShieldedDamage = self.fight.totalIncomingShieldedDamage + incomingDamageValue
            self:RecordTopMitigationMoment(
                "+",
                UnitName(sourceName),
                "Incoming shielded",
                incomingDamageValue,
                abilityId,
                safeAbilityName
            )
        elseif overflowValue > 0 then
            self.fight.totalIncomingShieldedDamage = self.fight.totalIncomingShieldedDamage + overflowValue
            self:RecordTopMitigationMoment(
                "+",
                UnitName(sourceName),
                "Incoming overflow",
                overflowValue,
                abilityId,
                safeAbilityName
            )
        end

        local overflowText = overflowValue > 0 and string.format(" (+%s ovf)", ShortNumber(overflowValue)) or ""
        self:PushScrollLine(
            string.format("-%s%s  from %s via %s", ShortNumber(effectiveValue), overflowText, UnitName(sourceName), FormatAbilityIdentity(safeAbilityName, abilityId)),
            COMBAT_TEXT_COLORS.taken
        )
    end
end

function ConsoleMetrics:RefreshScroll()
    if not self.ui.scrollLabels then
        return
    end

    local nowMs = GetFrameTimeMilliseconds()

    for index, label in ipairs(self.ui.scrollLabels) do
        local sourceIndex = #self.scrollEntries - index + 1
        local entry = self.scrollEntries[sourceIndex]

        if entry then
            local age = (nowMs - entry.timeMs) / 1000
            local alpha = Clamp(1 - (age / 6), 0.25, 1)
            label:SetText(entry.text)
            label:SetColor(entry.color[1], entry.color[2], entry.color[3], alpha)
            label:SetHidden(false)
        else
            label:SetHidden(true)
        end
    end
end

function ConsoleMetrics:UpdateTopSkills()
    if not self.ui.skillLabels then
        return
    end

    local skillList = SortSkillEntries(self.fight.skillMap)

    for i, label in ipairs(self.ui.skillLabels) do
        local info = skillList[i]
        if info then
            local critPct = 0
            if info.hits > 0 then
                critPct = (info.crits / info.hits) * 100
            end

            label:SetText(
                string.format(
                    "%d. %s [id:%d]  %s  (%.0f%%)",
                    i,
                    info.name,
                    info.abilityId or 0,
                    ShortNumber(info.damage),
                    critPct
                )
            )
            label:SetHidden(false)
        else
            label:SetText(string.format("%d. -", i))
            label:SetHidden(false)
        end
    end
end

function ConsoleMetrics:UpdateMetrics()
    if not self.fight then
        return
    end

    local nowMs = GetFrameTimeMilliseconds()
    local duration = self:GetFightDuration(nowMs)
    local dps = duration > 0 and (self.fight.totalDamage / duration) or 0
    local hps = duration > 0 and (self.fight.totalHeal / duration) or 0
    local critPct = self.fight.hits > 0 and (self.fight.crits / self.fight.hits) * 100 or 0

    self.fight.peakDps = math.max(self.fight.peakDps, dps)
    self.fight.peakHps = math.max(self.fight.peakHps, hps)

    if not self.ui.rows then
        return
    end

    local totalMax = math.max(self.fight.totalDamage, self.fight.totalHeal, self.fight.totalTaken, 1)
    local rateMax = math.max(dps, hps, 1)

    local durationText = string.format("Encounter  %ss", string.format("%.1f", duration))
    self.ui.durationLabel:SetText(durationText)

    self.ui.rows.dps.value:SetText(ShortNumber(dps))
    self.ui.rows.hps.value:SetText(ShortNumber(hps))
    self.ui.rows.damage.value:SetText(NumberText(self.fight.totalDamage))
    self.ui.rows.heal.value:SetText(NumberText(self.fight.totalHeal))
    self.ui.rows.taken.value:SetText(NumberText(self.fight.totalTaken))
    self.ui.rows.crit.value:SetText(string.format("%.1f%%", critPct))

    self.ui.rows.dps.bar:SetMinMax(0, rateMax)
    self.ui.rows.hps.bar:SetMinMax(0, rateMax)
    self.ui.rows.damage.bar:SetMinMax(0, totalMax)
    self.ui.rows.heal.bar:SetMinMax(0, totalMax)
    self.ui.rows.taken.bar:SetMinMax(0, totalMax)
    self.ui.rows.crit.bar:SetMinMax(0, 100)

    self.ui.rows.dps.bar:SetValue(dps)
    self.ui.rows.hps.bar:SetValue(hps)
    self.ui.rows.damage.bar:SetValue(self.fight.totalDamage)
    self.ui.rows.heal.bar:SetValue(self.fight.totalHeal)
    self.ui.rows.taken.bar:SetValue(self.fight.totalTaken)
    self.ui.rows.crit.bar:SetValue(critPct)

    self:UpdateTopSkills()
    self:UpdateTopHealing()
end

function ConsoleMetrics:UpdateTopHealing()
    if not self.ui.healLabels or not self.fight then
        return
    end

    local healList = {}
    for _, moment in ipairs(self.fight.topHealingMoments or {}) do
        healList[#healList + 1] = moment
    end

    for i, label in ipairs(self.ui.healLabels) do
        local moment = healList[i]
        if moment then
            label:SetText(string.format("%d. %s", i, moment.label))
            label:SetHidden(false)
        else
            label:SetText(string.format("%d. -", i))
            label:SetHidden(false)
        end
    end
end

local function CreateLabeledRow(parent, labelText, yOffset, color)
    local wm = WINDOW_MANAGER

    local row = wm:CreateControl(nil, parent, CT_CONTROL)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, yOffset)
    row:SetDimensions(400, 40)

    local label = wm:CreateControl(nil, row, CT_LABEL)
    label:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
    label:SetFont("ZoFontGamepad20")
    label:SetColor(color[1], color[2], color[3], 1)
    label:SetText(labelText)

    local value = wm:CreateControl(nil, row, CT_LABEL)
    value:SetAnchor(TOPRIGHT, row, TOPRIGHT, 0, 0)
    value:SetFont("ZoFontGamepad20")
    value:SetColor(color[1], color[2], color[3], 1)
    value:SetText("0")

    local track = wm:CreateControl(nil, row, CT_BACKDROP)
    track:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 24)
    track:SetDimensions(400, 12)
    track:SetCenterColor(0.12, 0.06, 0.03, 0.95)
    track:SetEdgeColor(0.36, 0.20, 0.10, 1)
    track:SetEdgeTexture(nil, 1, 1, 0, 0)

    local bar = wm:CreateControl(nil, track, CT_STATUSBAR)
    bar:SetAnchor(TOPLEFT, track, TOPLEFT, 1, 1)
    bar:SetDimensions(398, 10)
    bar:SetTexture("EsoUI/Art/Miscellaneous/progressbar_genericfill.dds")
    bar:SetColor(color[1], color[2], color[3], 1)
    bar:SetMinMax(0, 1)
    bar:SetValue(0)

    return {
        value = value,
        bar = bar,
    }
end

function ConsoleMetrics:CreateUI()
    local wm = WINDOW_MANAGER

    local root = wm:CreateTopLevelWindow("ConsoleMetricsRoot")
    root:SetDimensions(760, 430)
    root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.saved.x, self.saved.y)
    root:SetMovable(not self.saved.locked)
    root:SetMouseEnabled(true)
    root:SetClampedToScreen(true)
    root:SetScale(self.saved.scale)

    root:SetHandler("OnMoveStop", function(control)
        self.saved.x = control:GetLeft()
        self.saved.y = control:GetTop()
    end)

    local frame = wm:CreateControl(nil, root, CT_BACKDROP)
    frame:SetAnchorFill(root)
    frame:SetCenterColor(0.08, 0.04, 0.02, 0.84)
    frame:SetEdgeColor(1, 0.42, 0.15, 0.92)
    frame:SetEdgeTexture(nil, 2, 2, 0, 0)

    local titleBg = wm:CreateControl(nil, root, CT_BACKDROP)
    titleBg:SetAnchor(TOPLEFT, root, TOPLEFT, 0, 0)
    titleBg:SetDimensions(760, 62)
    titleBg:SetCenterColor(0.25, 0.08, 0.02, 0.95)
    titleBg:SetEdgeColor(1, 0.54, 0.20, 0.95)
    titleBg:SetEdgeTexture(nil, 1, 1, 0, 0)

    local title = wm:CreateControl(nil, root, CT_LABEL)
    title:SetAnchor(LEFT, titleBg, LEFT, 20, 0)
    title:SetFont("ZoFontGamepad34")
    title:SetColor(1, 0.74, 0.42, 1)
    title:SetText("CONSOLE METRICS")

    local subtitle = wm:CreateControl(nil, root, CT_LABEL)
    subtitle:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, -6)
    subtitle:SetFont("ZoFontGamepad16")
    subtitle:SetColor(0.96, 0.84, 0.71, 1)
    subtitle:SetText("Combat snapshot tuned for gamepad UI")

    local durationLabel = wm:CreateControl(nil, root, CT_LABEL)
    durationLabel:SetAnchor(RIGHT, titleBg, RIGHT, -22, 0)
    durationLabel:SetFont("ZoFontGamepad20")
    durationLabel:SetColor(1, 0.83, 0.67, 1)
    durationLabel:SetText("Encounter 0.0s")

    local statsPane = wm:CreateControl(nil, root, CT_BACKDROP)
    statsPane:SetAnchor(TOPLEFT, root, TOPLEFT, 16, 74)
    statsPane:SetDimensions(420, 340)
    statsPane:SetCenterColor(0.10, 0.05, 0.03, 0.65)
    statsPane:SetEdgeColor(0.45, 0.24, 0.12, 0.85)
    statsPane:SetEdgeTexture(nil, 1, 1, 0, 0)

    local feedPane = wm:CreateControl(nil, root, CT_BACKDROP)
    feedPane:SetAnchor(TOPRIGHT, root, TOPRIGHT, -16, 74)
    feedPane:SetDimensions(300, 340)
    feedPane:SetCenterColor(0.09, 0.04, 0.03, 0.67)
    feedPane:SetEdgeColor(0.45, 0.24, 0.12, 0.85)
    feedPane:SetEdgeTexture(nil, 1, 1, 0, 0)

    local feedTitle = wm:CreateControl(nil, feedPane, CT_LABEL)
    feedTitle:SetAnchor(TOPLEFT, feedPane, TOPLEFT, 12, 10)
    feedTitle:SetFont("ZoFontGamepad20")
    feedTitle:SetColor(1, 0.70, 0.47, 1)
    feedTitle:SetText("BATTLE FEED")

    local rows = {
        dps = CreateLabeledRow(statsPane, "DPS", 12, METRIC_ROW_COLORS.dps),
        hps = CreateLabeledRow(statsPane, "HPS", 58, METRIC_ROW_COLORS.hps),
        damage = CreateLabeledRow(statsPane, "Damage Done", 104, METRIC_ROW_COLORS.damage),
        heal = CreateLabeledRow(statsPane, "Healing Done", 150, METRIC_ROW_COLORS.heal),
        taken = CreateLabeledRow(statsPane, "Damage Taken", 196, METRIC_ROW_COLORS.taken),
        crit = CreateLabeledRow(statsPane, "Crit Rate", 242, METRIC_ROW_COLORS.crit),
    }

    local skillTitle = wm:CreateControl(nil, statsPane, CT_LABEL)
    skillTitle:SetAnchor(TOPLEFT, statsPane, TOPLEFT, 0, 292)
    skillTitle:SetFont("ZoFontGamepad20")
    skillTitle:SetColor(1, 0.70, 0.47, 1)
    skillTitle:SetText("Top Damage Skills")

    local skillLabels = {}
    for i = 1, 3 do
        local skillLabel = wm:CreateControl(nil, statsPane, CT_LABEL)
        skillLabel:SetAnchor(TOPLEFT, statsPane, TOPLEFT, 0, 292 + (i * 24))
        skillLabel:SetFont("ZoFontGamepad20")
        skillLabel:SetColor(0.95, 0.86, 0.76, 1)
        skillLabel:SetText(string.format("%d. -", i))
        skillLabels[i] = skillLabel
    end

    local healTitle = wm:CreateControl(nil, feedPane, CT_LABEL)
    healTitle:SetAnchor(TOPLEFT, feedPane, TOPLEFT, 12, 280)
    healTitle:SetFont("ZoFontGamepad20")
    healTitle:SetColor(1, 0.70, 0.47, 1)
    healTitle:SetText("TOP HEALING")

    local healLabels = {}
    for i = 1, 3 do
        local healLabel = wm:CreateControl(nil, feedPane, CT_LABEL)
        healLabel:SetAnchor(TOPLEFT, feedPane, TOPLEFT, 12, 280 + (i * 24))
        healLabel:SetFont("ZoFontGamepad16")
        healLabel:SetColor(0.45, 1, 0.55, 1)
        healLabel:SetText(string.format("%d. -", i))
        healLabels[i] = healLabel
    end

    local scrollLabels = {}
    for i = 1, self.saved.scrollSize do
        local line = wm:CreateControl(nil, feedPane, CT_LABEL)
        line:SetAnchor(TOPLEFT, feedPane, TOPLEFT, 12, 28 + ((i - 1) * 36))
        line:SetDimensions(280, 34)
        line:SetFont("ZoFontGamepad20")
        line:SetColor(1, 0.68, 0.46, 1)
        line:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        line:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        line:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        line:SetHidden(true)
        scrollLabels[i] = line
    end

    self.ui.root = root
    self.ui.rows = rows
    self.ui.durationLabel = durationLabel
    self.ui.scrollLabels = scrollLabels
    self.ui.skillLabels = skillLabels
    self.ui.healLabels = healLabels

    if not self.saved.showOutOfCombat then
        root:SetHidden(true)
    end
end

function ConsoleMetrics:DumpGameSets()
    -- Part 1: Enumerate all item sets via ESO item set API.
    local gameSetCount = 0
    if type(GetNumItemSets) == "function" then
        local numSets = 0
        local ok = pcall(function()
            numSets = GetNumItemSets()
        end)
        if ok and type(numSets) == "number" and numSets > 0 then
            gameSetCount = numSets
            self:Print(string.format("Enumerating %d item sets via GetNumItemSets...", numSets))
            for i = 1, numSets do
                local setName, numBonuses, numEquipped, maxEquipped, setId, isCrafted
                local ok2 = pcall(function()
                    setName, numBonuses, numEquipped, maxEquipped, setId, isCrafted = GetItemSetInfo(i)
                end)
                if ok2 and setName and setName ~= "" then
                    d(string.format(
                        "|cFF6A00[CM-Set]|r [%d] setId=%s name=%s bonuses=%d crafted=%s",
                        i,
                        tostring(setId or "?"),
                        setName,
                        tonumber(numBonuses) or 0,
                        tostring(isCrafted or false)
                    ))
                end
            end
        else
            self:Print("GetNumItemSets returned 0 or is unavailable in this context.")
        end
    else
        self:Print("GetNumItemSets not found in this ESO build.")
    end

    -- Part 2: Session-observed ability IDs accumulated from all combat events this session.
    local abilityCount = 0
    for _ in pairs(self.observedAbilityLog or {}) do
        abilityCount = abilityCount + 1
    end

    if abilityCount > 0 then
        self:Print(string.format("Session-observed unique abilities: %d", abilityCount))
        for abilityId, name in pairs(self.observedAbilityLog) do
            d(string.format("|cFF6A00[CM-Ability]|r id=%d name=%s", abilityId, name))
        end
    else
        self:Print("No abilities observed this session. Enter combat to populate ability ID log.")
    end

    if gameSetCount == 0 and abilityCount == 0 then
        self:Print("dumpsets: no data yet. Check ESO API availability or enter combat first.")
    end
end

function ConsoleMetrics:HandleSlash(rawInput)
    local input = string.lower(zo_strtrim(rawInput or ""))
    local rawText = rawInput or ""

    if input == "" or input == "help" or input == "options" then
        self:PrintHelp()
        return
    end

    if input == "inject" or input == "journal" then
        self:RefreshJournalIntegration(true)
        return
    end

    if input == "view" or input == "menu" then
        self.dialogPanel = "main"
        self:OpenFightViewDialog()
        return
    end

    if input == "close" then
        self:CloseFightViewDialog(false, "slash")
        return
    end

    if input == "next" then
        if self:StepFightView(1) then
            self:OpenFightViewDialog(false)
        else
            self:Print("No fight history available yet.")
        end
        return
    end

    if input == "prev" then
        if self:StepFightView(-1) then
            self:OpenFightViewDialog(false)
        else
            self:Print("No fight history available yet.")
        end
        return
    end

    if input == "clear" then
        self:ResetFightData(false)
        self:Print("Fight history and live fight data cleared")
        return
    end

    local autoClearMode = string.match(input, "^autoclear%s+(%S+)$")
    if autoClearMode == "on" then
        self.saved.autoClearOnNextFight = true
        self:Print("Auto clear on next fight enabled")
        return
    end

    if autoClearMode == "off" then
        self.saved.autoClearOnNextFight = false
        self:Print("Auto clear on next fight disabled")
        return
    end

    local autoHideMode = string.match(input, "^autohide%s+(%S+)$")
    if autoHideMode == "on" then
        self.saved.dialogAutoHide = true
        self:ArmDialogAutoHide()
        self:Print("Dialog auto hide enabled")
        return
    end

    if autoHideMode == "off" then
        self.saved.dialogAutoHide = false
        self.dialogAutoHideAtMs = nil
        self:Print("Dialog auto hide disabled")
        return
    end

    if input == "dumpsets" or input == "logsets" then
        self:DumpGameSets()
        return
    end

    if input == "debugbuild" or input == "builddebug" then
        self:PrintBuildSnapshotDebug("slash")
        return
    end

    if input == "linkbuild" or input == "buildlink" or input == "chatbuild" then
        self:LinkBuildToChat()
        return
    end

    if input == "dumpcpslottables" or input == "dumpcpstars" or input == "logcpslottables" then
        self:DumpChampionSlottables()
        return
    end

    if input == "importpct" or input == "syncpct" then
        local _, message = self:ImportSetsFromPvPCooldownTracker()
        self:Print(message)
        return
    end

    local savefightName = string.match(rawText, "^%s*[Ss][Aa][Vv][Ee][Ff][Ii][Gg][Hh][Tt]%s+(.+)$")
    if savefightName then
        self.saved.saveFightDraftName = TrimText(savefightName)
        local ok, message = self:SaveViewedFight()
        self:Print(message)
        return
    end

    if input == "savefight" then
        local ok, message = self:SaveViewedFight()
        self:Print(message)
        return
    end

    local loadfightExactName = string.match(rawText, "^%s*[Ll][Oo][Aa][Dd][Ff][Ii][Gg][Hh][Tt][Ee][Xx][Aa][Cc][Tt]%s+(.+)$")
    if loadfightExactName then
        self.saved.loadFightDraftName = TrimText(loadfightExactName)
        local ok, message = self:LoadSavedFightIntoHistoryByExactName(self.saved.loadFightDraftName)
        self:Print(message)
        if ok then
            self.dialogPanel = "main"
            self:OpenFightViewDialog(false)
        end
        return
    end

    local loadfightStrictName = string.match(rawText, "^%s*[Ll][Oo][Aa][Dd][Ff][Ii][Gg][Hh][Tt][Ss][Tt][Rr][Ii][Cc][Tt]%s+(.+)$")
    if loadfightStrictName then
        self.saved.loadFightDraftName = TrimText(loadfightStrictName)
        local ok, message = self:LoadSavedFightIntoHistoryByExactName(self.saved.loadFightDraftName)
        self:Print(message)
        if ok then
            self.dialogPanel = "main"
            self:OpenFightViewDialog(false)
        end
        return
    end

    local loadfightName = string.match(rawText, "^%s*[Ll][Oo][Aa][Dd][Ff][Ii][Gg][Hh][Tt]%s+(.+)$")
    if loadfightName then
        self.saved.loadFightDraftName = TrimText(loadfightName)
        local ok, message = self:LoadSavedFightIntoHistoryByName(self.saved.loadFightDraftName)
        self:Print(message)
        if ok then
            self.dialogPanel = "main"
            self:OpenFightViewDialog(false)
        end
        return
    end

    if input == "loadfight" then
        local ok, message = self:LoadSavedFightIntoHistoryByName(self.saved.loadFightDraftName or "")
        self:Print(message)
        if ok then
            self.dialogPanel = "main"
            self:OpenFightViewDialog(false)
        end
        return
    end

    if input == "loadfightexact" or input == "loadfightstrict" then
        local ok, message = self:LoadSavedFightIntoHistoryByExactName(self.saved.loadFightDraftName or "")
        self:Print(message)
        if ok then
            self.dialogPanel = "main"
            self:OpenFightViewDialog(false)
        end
        return
    end

    if input == "loadsaves" then
        local before = #self.fightHistory
        for i = 1, #(self.saved.savedFights or {}) do
            self:LoadSavedFightIntoHistory(i)
        end
        local added = #self.fightHistory - before
        if added > 0 then
            self:Print(string.format("Loaded %d saved fight(s) into history. Use /cm view to browse.", added))
            self.dialogPanel = "main"
            self:OpenFightViewDialog(false)
        else
            self:Print("No saved fights to load, or all are already in history.")
        end
        return
    end

    local addsetPayload = string.match(rawText, "^%s*[Aa][Dd][Dd][Ss][Ee][Tt]%s+(.+)$")
    if addsetPayload then
        local label, scene, abilityIdText, abilityName = string.match(addsetPayload, "([^|]*)|([^|]*)|([^|]*)|?(.*)")
        local abilityId = tonumber(TrimText(abilityIdText))
        local _, message = self:AddCustomSetRule(label, scene, abilityId, abilityName)
        self:Print(message)
        return
    end

    if input == "toggle" or input == "lock" or input == "unlock" then
        self:Print("On-screen panel is disabled. Use /cm view for the console dialog.")
        return
    end

    if input == "reset" then
        self.saved.x = self.defaults.x
        self.saved.y = self.defaults.y
        self.saved.scale = self.defaults.scale
        self.saved.autoClearOnNextFight = self.defaults.autoClearOnNextFight
        self.saved.maxFightHistory = self.defaults.maxFightHistory
        self.saved.dialogAutoHide = self.defaults.dialogAutoHide
        self.saved.dialogAutoHideSeconds = self.defaults.dialogAutoHideSeconds
        self.saved.drSampleAlpha = self.defaults.drSampleAlpha
        self.saved.customSetRules = {}
        self.saved.customSetDraftLabel = self.defaults.customSetDraftLabel
        self.saved.customSetDraftScene = self.defaults.customSetDraftScene
        self.saved.customSetDraftAbilityId = self.defaults.customSetDraftAbilityId
        self.saved.customSetDraftAbilityName = self.defaults.customSetDraftAbilityName
        self.saved.saveFightDraftName = self.defaults.saveFightDraftName
        self.saved.loadFightDraftName = self.defaults.loadFightDraftName
        self.saved.uiPanelEnabled = self.defaults.uiPanelEnabled
        self.dialogPanel = "main"
        self.dialogAutoHideAtMs = nil
        self.lastDebugPrintAtMs = nil
        if self.ui.root then
            self.ui.root:SetHidden(true)
        end
        self:Print("Dialog options reset")
        return
    end

    self:Print("Unknown command. Use /cm help")
end

function ConsoleMetrics:OnUpdate()
    local nowMs = GetFrameTimeMilliseconds()

    if self.dialogAutoHideAtMs and self.saved.dialogAutoHide and not self.inCombat and nowMs >= self.dialogAutoHideAtMs then
        self:CloseFightViewDialog(true, "autohide")
    end

    if self.inCombat then
        self:SampleFightResources(nowMs, false)
        self:UpdateProtectionInference(nowMs)
        self:UpdateMetrics()
    elseif self.hideAtMs and self.ui.root and not self.saved.showOutOfCombat then
        if nowMs >= self.hideAtMs then
            self.hideAtMs = nil
            self.ui.root:SetHidden(true)
        end
    end

    if self:IsFightViewDialogShowing() and self.viewFightIndex == 0 then
        if not self.dialogRefreshAtMs or nowMs >= self.dialogRefreshAtMs then
            if self.ui.fightViewDialog then
                self:PopulateFightViewDialog(self.ui.fightViewDialog)
            end
            self.dialogRefreshAtMs = nowMs + DIALOG_LIVE_REFRESH_MS
        end
    else
        self.dialogRefreshAtMs = nil
    end

    self:RefreshScroll()
end

function ConsoleMetrics:Initialize()
    self.saved = ZO_SavedVars:NewAccountWide("ConsoleMetricsSavedVars", 1, nil, self.defaults)
    self.saved.maxFightHistory = tonumber(self.saved.maxFightHistory) or self.defaults.maxFightHistory
    self.saved.maxFightHistory = math.max(5, math.min(100, self.saved.maxFightHistory))
    if self.saved.autoClearOnNextFight == nil then
        self.saved.autoClearOnNextFight = self.defaults.autoClearOnNextFight
    end
    if self.saved.dialogAutoHide == nil then
        self.saved.dialogAutoHide = self.defaults.dialogAutoHide
    end
    self.saved.dialogAutoHideSeconds = tonumber(self.saved.dialogAutoHideSeconds) or self.defaults.dialogAutoHideSeconds
    self.saved.dialogAutoHideSeconds = Clamp(self.saved.dialogAutoHideSeconds, 3, 120)
    if self.saved.uiPanelEnabled == nil then
        self.saved.uiPanelEnabled = self.defaults.uiPanelEnabled
    end
    self.saved.uiPanelEnabled = false
    if self.saved.debugEnabled == nil then
        self.saved.debugEnabled = self.defaults.debugEnabled
    end
    self.saved.debugIntervalSeconds = tonumber(self.saved.debugIntervalSeconds) or self.defaults.debugIntervalSeconds
    self.saved.debugIntervalSeconds = Clamp(self.saved.debugIntervalSeconds, 1, 30)
    self.saved.drSampleAlpha = tonumber(self.saved.drSampleAlpha) or self.defaults.drSampleAlpha
    self.saved.drSampleAlpha = Clamp(self.saved.drSampleAlpha, 0.05, 0.85)
    if type(self.saved.customSetRules) ~= "table" then
        self.saved.customSetRules = {}
    end
    if type(self.saved.customSetDraftLabel) ~= "string" then
        self.saved.customSetDraftLabel = self.defaults.customSetDraftLabel
    end
    self.saved.customSetDraftScene = NormalizeCustomSetScene(self.saved.customSetDraftScene or self.defaults.customSetDraftScene)
    if type(self.saved.customSetDraftAbilityId) ~= "string" then
        self.saved.customSetDraftAbilityId = self.defaults.customSetDraftAbilityId
    end
    if type(self.saved.customSetDraftAbilityName) ~= "string" then
        self.saved.customSetDraftAbilityName = self.defaults.customSetDraftAbilityName
    end
    if type(self.saved.saveFightDraftName) ~= "string" then
        self.saved.saveFightDraftName = self.defaults.saveFightDraftName
    end
    if type(self.saved.loadFightDraftName) ~= "string" then
        self.saved.loadFightDraftName = self.defaults.loadFightDraftName
    end
    if type(self.saved.savedFights) ~= "table" then
        self.saved.savedFights = {}
    end
    self.saved.maxSavedFights = tonumber(self.saved.maxSavedFights) or self.defaults.maxSavedFights
    self.saved.maxSavedFights = math.max(1, math.min(50, self.saved.maxSavedFights))

    self.playerName = UnitName(GetUnitName("player"))
    self.fightHistory = {}
    -- Restore persisted saved fights into session history so they're browsable immediately.
    for i = 1, #self.saved.savedFights do
        local entry = self.saved.savedFights[i]
        if entry and type(entry.snapshot) == "table" then
            self.fightHistory[#self.fightHistory + 1] = entry.snapshot
        end
    end
    self.viewFightIndex = #self.fightHistory > 0 and #self.fightHistory or 0
    self.dialogPanel = "main"
    self.dialogAutoHideAtMs = nil
    self.lastDebugPrintAtMs = nil
    self.observedAbilityLog = {}

    if self.saved.uiPanelEnabled then
        self:CreateUI()
    end
    self.fight = NewFight(GetFrameTimeMilliseconds())

    self:RegisterLAMSettings()

    EVENT_MANAGER:RegisterForEvent(self.name .. "JournalMenuInject", EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(self.name .. "JournalMenuInject", EVENT_PLAYER_ACTIVATED)

        local initialMenuReady, initialSceneCount = self:RefreshJournalIntegration(false)
        if initialMenuReady then
            self:Print(string.format("Journal menu item ready (scene hooks: %d)", initialSceneCount))
            return
        end

        local retryName = self.name .. "JournalMenuRetry"
        local attempts = 0
        EVENT_MANAGER:RegisterForUpdate(retryName, 1500, function()
            attempts = attempts + 1
            local menuReady, hookedScenes = self:RefreshJournalIntegration(false)
            if menuReady then
                self:Print(string.format("Journal menu item ready (scene hooks: %d)", hookedScenes))
                EVENT_MANAGER:UnregisterForUpdate(retryName)
            elseif attempts >= 20 then
                self:Print("Journal menu item not ready yet. Open Main Menu, highlight Journal, then /reloadui.")
                EVENT_MANAGER:UnregisterForUpdate(retryName)
            end
        end)
    end)

    if MAIN_MENU_GAMEPAD_SCENE and MAIN_MENU_GAMEPAD_SCENE.RegisterCallback then
        MAIN_MENU_GAMEPAD_SCENE:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_SHOWING or newState == SCENE_SHOWN then
                self:RefreshJournalIntegration(false)
            end
        end)
    end

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, function(...)
        self:OnCombatState(...)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT, function(...)
        self:OnCombatEvent(...)
    end)

    EVENT_MANAGER:RegisterForUpdate(self.name .. "Update", 200, function()
        self:OnUpdate()
    end)

    SLASH_COMMANDS["/cm"] = function(args)
        self:HandleSlash(args)
    end
    SLASH_COMMANDS["/consolemetrics"] = function(args)
        self:HandleSlash(args)
    end

    self:Print("Loaded. Console dialog mode active. Use /cm view")
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    ConsoleMetrics:Initialize()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
