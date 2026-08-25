local ADDON_NAME = "TetsuWritCrafter"
TetsuWritCrafter = TetsuWritCrafter or {}

local defaultAccountVars = {
    characters = {},
    dailyCrafted = {},
    mainCrafterName = nil,
}

local function SanitizeDatabase()
    local vars = TetsuWritCrafter.savedVars
    if not vars or not vars.characters then return end

    local validNames = {}
    local numChars = GetNumCharacters()
    for i = 1, numChars do
        local name = GetCharacterInfo(i)
        validNames[zo_strformat("<<1>>", name)] = true
    end

    for key, _ in pairs(vars.characters) do
        if not validNames[key] then
            vars.characters[key] = nil
        end
    end
end

local function UpdateCharacterData()
    SanitizeDatabase()

    local charName = zo_strformat("<<1>>", GetUnitName("player"))
    local vars = TetsuWritCrafter.savedVars
    local L = TetsuWritCrafter.L

    vars.characters[charName] = vars.characters[charName] or { enabled = true }
    vars.characters[charName].isScanned = true

    vars.characters[charName].blacksmithingTier = GetSkillAbilityUpgradeInfo(SKILL_TYPE_TRADESKILL, 1, 1) or 1
    vars.characters[charName].clothingTier      = GetSkillAbilityUpgradeInfo(SKILL_TYPE_TRADESKILL, 2, 1) or 1
    vars.characters[charName].enchantingTier    = GetSkillAbilityUpgradeInfo(SKILL_TYPE_TRADESKILL, 3, 1) or 1
    vars.characters[charName].alchemyTier       = GetSkillAbilityUpgradeInfo(SKILL_TYPE_TRADESKILL, 4, 1) or 1
    vars.characters[charName].provisioningTier  = GetSkillAbilityUpgradeInfo(SKILL_TYPE_TRADESKILL, 5, 1) or 1
    vars.characters[charName].woodworkingTier   = GetSkillAbilityUpgradeInfo(SKILL_TYPE_TRADESKILL, 6, 1) or 1
    vars.characters[charName].jewelryTier       = GetSkillAbilityUpgradeInfo(SKILL_TYPE_TRADESKILL, 7, 1) or 1

    local bsCur, bsMax = GetSkillAbilityUpgradeInfo(SKILL_TYPE_TRADESKILL, 1, 1)
    if bsCur and bsMax and bsCur == bsMax then
        vars.mainCrafterName = charName
    end

    local totalChars = GetNumCharacters()
    local scannedCount = 0
    local missingChars = {}

    for i = 1, totalChars do
        local name = zo_strformat("<<1>>", GetCharacterInfo(i))
        if vars.characters[name] and vars.characters[name].isScanned then
            scannedCount = scannedCount + 1
        else
            table.insert(missingChars, name)
        end
    end

    if scannedCount < totalChars then
        d(zo_strformat("|cFFD700[Tetsu's Writ Crafter]|r " .. L.SYNC_STATUS, scannedCount, totalChars, table.concat(missingChars, ", ")))
    else
        if vars.mainCrafterName == charName then
            local patternLetters = { [1] = "A", [2] = "B", [3] = "C" }
            local todayPattern = patternLetters[TetsuWritCrafter.Data.GetTodayPatternIndex()] or "A"
            local activeAlts = 0
            for name, data in pairs(vars.characters) do
                if name ~= charName and data.enabled then activeAlts = activeAlts + 1 end
            end
            d(zo_strformat("|c00FF00[Tetsu's Writ Crafter]|r " .. L.READY_BRIEFING, todayPattern, activeAlts))
        end
    end
end

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= ADDON_NAME then return end

    TetsuWritCrafter.savedVars = ZO_SavedVars:NewAccountWide(
        "TetsuWritCrafterSavedVars",
        1,
        nil,
        defaultAccountVars
    )

    SanitizeDatabase()
    TetsuWritCrafter.RegisterSettings()
    TetsuWritCrafter.Banking.Initialize()
    TetsuWritCrafter.Quests.Initialize()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_StationOpen", EVENT_CRAFTING_STATION_INTERACT, function()
        TetsuWritCrafter.Crafting.AddStationKeybind()
    end)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_StationClose", EVENT_END_CRAFTING_INTERACTION, function()
        TetsuWritCrafter.Crafting.RemoveStationKeybind()
    end)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_ModeUpdate", EVENT_CRAFTING_MODE_UPDATED, function()
        TetsuWritCrafter.Crafting.AddStationKeybind()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Activated", EVENT_PLAYER_ACTIVATED, function()
        UpdateCharacterData()
    end)

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)