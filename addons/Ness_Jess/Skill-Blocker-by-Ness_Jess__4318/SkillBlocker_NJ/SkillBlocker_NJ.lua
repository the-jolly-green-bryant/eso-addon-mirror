-------------------------------------------------------------------------------
------------------------[  SkillBlocker By Ness_Jess  ]------------------------
-------------------------------------------------------------------------------

SkillBlocker_NJ = SkillBlocker_NJ or {}
local SB_NJ = SkillBlocker_NJ

SB_NJ.lock = {}
SB_NJ.criminalOverlays = {}
SB_NJ.name = "Skill Blocker by Ness_Jess"

local ADDON_NAME = "SkillBlocker_NJ"
local ADDON_VERSION = "1.5"

local FONT_SETTINGS = "$(BOLD_FONT)|12|soft-shadow-thin" --thick-outline
local FONT_SLIDER = "$(BOLD_FONT)|14|soft-shadow-thin"

local GetSlotBoundId = GetSlotBoundId
local GetSlotType = GetSlotType
local GetUnitBuffInfo = GetUnitBuffInfo
local GetNumBuffs = GetNumBuffs
local GetAbilityIdForCraftedAbilityId = GetAbilityIdForCraftedAbilityId
local GetCraftedAbilityActiveScriptIds = GetCraftedAbilityActiveScriptIds
local GetActiveHotbarCategory = GetActiveHotbarCategory
local GetUnitPower = GetUnitPower
local DoesUnitExist = DoesUnitExist
local GetAbilityName = GetAbilityName
local IsUnitInCombat = IsUnitInCombat
local PlaySound = PlaySound
local GetUnitClassId = GetUnitClassId
local GetActionSlotEffectTimeRemaining = GetActionSlotEffectTimeRemaining 
local wm = WINDOW_MANAGER 
local tostring = tostring
local pairs = pairs
local ipairs = ipairs
local zo_strformat = zo_strformat
local GetString = GetString 
local type = type
local zo_callLater = zo_callLater
local GetSkillAbilityUpgradeInfo = GetSkillAbilityUpgradeInfo
local GetSkillAbilityId = GetSkillAbilityId
local GetNumSkillTypes = GetNumSkillTypes
local GetNumSkillLines = GetNumSkillLines
local GetNumSkillAbilities = GetNumSkillAbilities

local ACTION_TYPE_CRAFTED_ABILITY = ACTION_TYPE_CRAFTED_ABILITY
local HOTBAR_CATEGORY_PRIMARY = HOTBAR_CATEGORY_PRIMARY
local HOTBAR_CATEGORY_BACKUP = HOTBAR_CATEGORY_BACKUP
local HOTBAR_CATEGORY_WEREWOLF = HOTBAR_CATEGORY_WEREWOLF 
local HOTBAR_CATEGORY_DAEDRIC_ARTIFACT = HOTBAR_CATEGORY_DAEDRIC_ARTIFACT
local HOTBAR_CATEGORY_TEMPORARY = HOTBAR_CATEGORY_TEMPORARY
local REGISTER_FILTER_UNIT_TAG = REGISTER_FILTER_UNIT_TAG
local SOUNDS_INVENTORY_ITEM_LOCKED = SOUNDS.INVENTORY_ITEM_LOCKED
local SOUNDS_INVENTORY_ITEM_UNLOCKED = SOUNDS.INVENTORY_ITEM_UNLOCKED
local SOUNDS_WINDOW_OPEN = SOUNDS.WINDOW_OPEN
local SOUNDS_WINDOW_CLOSE = SOUNDS.WINDOW_CLOSE
local SOUNDS_SLIDER_VALUE_CHANGED = SOUNDS.SLIDER_VALUE_CHANGED
local EFFECT_RESULT_FADED = EFFECT_RESULT_FADED
local EFFECT_RESULT_GAINED = EFFECT_RESULT_GAINED
local EFFECT_RESULT_UPDATED = EFFECT_RESULT_UPDATED
local POWERTYPE_ULTIMATE = POWERTYPE_ULTIMATE

local SM = SCENE_MANAGER
local EM = EVENT_MANAGER
local LAM = LibAddonMenu2
local LSB = LibSkillBlocker
local LCM = LibCustomMenu

local ALLOWED_HOTBARS = {
    [HOTBAR_CATEGORY_PRIMARY] = true,
    [HOTBAR_CATEGORY_BACKUP] = true,
    [HOTBAR_CATEGORY_WEREWOLF] = true,
    [HOTBAR_CATEGORY_DAEDRIC_ARTIFACT] = true,
    [HOTBAR_CATEGORY_TEMPORARY] = true,
}

local EventBus = ZO_CallbackObject:New()
local EVENTS = {
    LOGIC_UPDATE = "LogicUpdate", 
    UI_UPDATE = "UiUpdate"        
}

local currentHotbar = HOTBAR_CATEGORY_PRIMARY

-- FancyActionBar+
local function GetFabRemainingTime(abilityId)
    if FancyActionBar and FancyActionBar.effects then
        local effect = FancyActionBar.effects[abilityId]
        if effect and effect.endTime and effect.endTime > 0 then
            local remainingSeconds = effect.endTime - GetGameTimeSeconds()
            if remainingSeconds > 0 then
                return remainingSeconds * 1000
            end
        end
    end
    return 0
end

local isPlayerInCombat = false 
local lastUsedAbilityId = 0 
local ULTIMATE_SLOT_INDEX = 8 

local function zo_round(value) return math.floor(value + 0.5) end
local function round_decimal(num)
    return math.floor(num * 10 + 0.5) / 10
end

-------------------------------------------------------------------------------
----------------------------[    Configuration    ]----------------------------
-------------------------------------------------------------------------------

local Data = SB_NJ.Data or {}

local BANNER_ABILITY_IDS = Data.Banners or {}
local BUFF_COMBAT_ABILITY_IDS = Data.BuffCombat or {}
local COMBAT_ONLY_ABILITY_IDS = Data.CombatOnly or {}
local CRIMINAL_ABILITY_IDS = Data.CriminalAbilities or {}
local WEREWOLF_ULTIMATE_IDS = Data.WerewolfUltimate or {}
local IS_CRUX_ABILITY = Data.IsCrux or {}
local STACK_ABILITY_CONFIG = Data.StackConfig or {}
local TARGET_HP_ABILITY_CONFIG = Data.TargetHpConfig or {}
local TARGET_HP_DEFAULT_VALUES = Data.TargetHpDefaults or {}
local DOT_HOT_CONFIG = Data.DotHot or {}
local SCRIBING_DOT_HOT = Data.ScribingDotHot or {}
local DEBUFF_ABILITY_CONFIG = Data.DebuffAbilityConfig or {}
local TOGGLE_ULTIMATES = Data.ToggleUltimates or {}
local BANNER_BUFF_RANGES = Data.BannerBuffRanges or {}
local SCRIBING_LOGIC = Data.ScribingLogic or {}

local BANNER_STATE_UNLOCKED = 0
local BANNER_STATE_COMBAT_ONLY = 1
local BANNER_STATE_SMART_BLOCK = 2
local BANNER_STATE_FULL_LOCK = 3

local STATE_UNLOCKED = 0
local STATE_COMBAT_ONLY = 1
local STATE_FULL_BLOCK = 2

local TEXTURE_PATHS = {
    unlocked = { normal = "/esoui/art/miscellaneous/unlocked_up.dds", pressed = "/esoui/art/miscellaneous/unlocked_down.dds", over = "/esoui/art/miscellaneous/unlocked_over.dds" },
    locked = { normal = "/esoui/art/miscellaneous/locked_up.dds", pressed = "/esoui/art/miscellaneous/locked_down.dds", over = "/esoui/art/miscellaneous/locked_over.dds" },
    combat = { normal = "/esoui/art/tutorial/tutorial_idexicon_combat_up.dds", pressed = "/esoui/art/treeicons/tutorial_idexicon_combat_down.dds", over = "/esoui/art/tutorial/tutorial_idexicon_combat_over.dds" },
    smart = { normal = "/esoui/art/guild/guildhistory_indexicon_combat_up.dds", pressed = "/esoui/art/guild/guildhistory_indexicon_combat_down.dds", over = "/esoui/art/guild/guildhistory_indexicon_combat_over.dds" },
    settings = { normal = "/esoui/art/housing/keyboard/path_settings_icon_up.dds", pressed = "/esoui/art/housing/keyboard/path_settings_icon_down.dds", over = "/esoui/art/housing/keyboard/path_settings_icon_over.dds" },
    werewolf = { normal = "/esoui/art/treeicons/tutorial_indexicon_greymoor_up.dds", pressed = "/esoui/art/treeicons/tutorial_indexicon_greymoor_down.dds", over = "/esoui/art/treeicons/tutorial_indexicon_greymoor_over.dds" }
}

local variableVersion = 0
local savedVarsName = "SkillBlockerNJ_Data"
local defaults = {
    displayAlert = false,
    rememberLocks = true,
    doubleCastBlockDuration = 0,
    resetDoubleCastOnLA = true,
    mainBarBlockedAbilities = {},
    offBarBlockedAbilities = {},
    doubleCastBlockedAbilities = { mainBar = {}, offBar = {} },
    criminalBlockSettings = { mainBar = {}, offBar = {} },
    advancedBlockMode = { mainBar = {}, offBar = {} },
    bannerBlockState = BANNER_STATE_UNLOCKED,
    buffCombatSettings = { mainBar = {}, offBar = {} },
    combatOnlyBlockState = STATE_UNLOCKED,
    stackAbilitySettings = { mainBar = {}, offBar = {} },
    targetHpAbilitySettings = { mainBar = {}, offBar = {} },
    ultimateAbilitySettings = { mainBar = {}, offBar = {} },
    dotHotSettings = { mainBar = {}, offBar = {} },
    debuffAbilitySettings = { mainBar = {}, offBar = {} },
    werewolfBlockSettings = { mainBar = {}, offBar = {} },
}

local settings

local settingsWindow, hpSettingsWindow, ultSettingsWindow, dotHotSettingsWindow, debuffSettingsWindow
local currentSettingsAbilityId, currentSettingsSlotNum

local playerClassId
local activeBuffs = {}
local relevantBuffIds = {}
local tempRelevantBuffs = {}
local activeDebuffs = {}
local relevantDebuffIds = {}

local targetHealthPercent = 0
local isTrackingTargetHp = false
local isTrackingEffects = false
local isTrackingUltimate = false
local exceptionBannerCache = {} 
local handlerCache = {} 
local uiEventsRegistered = false

local function GetSettings()
    return settings or defaults
end

local shouldBlockAbility, drawLocks, blockBoth, ScanHotbarForRelevantBuffs, HideAllSettingsWindows, ShowSettingsWindow, ShowHpSettingsWindow, ShowUltimateSettingsWindow, ShowDotHotSettingsWindow, CreateSettingsWindow, CreateHpSettingsWindow, CreateUltimateSettingsWindow, CreateDotHotSettingsWindow, CreateDebuffSettingsWindow, ShowDebuffSettingsWindow

-------------------------------------------------------------------------------
----------------------------[       Helpers       ]----------------------------
-------------------------------------------------------------------------------

local function GetOrCreateControl(name, parent, cType, globalNameOverride)
    local finalName
    if globalNameOverride then
        finalName = globalNameOverride
    elseif parent then
        finalName = parent:GetName() .. name
    else
        finalName = name
    end
    
    local control = wm:GetControlByName(finalName)
    if not control then
        if parent then
            control = wm:CreateControl("$(parent)" .. name, parent, cType)
        else
            control = wm:CreateTopLevelWindow(finalName)
        end
    end
    return control
end

local function sliderValueToSetting(sliderValue, config)
    if sliderValue == 0 then return 0
    elseif sliderValue == config.maxStack - config.minThreshold + 2 then return config.maxStack + 1
    else return config.minThreshold + sliderValue - 1 end
end

local function settingToSliderValue(setting, config)
    if setting == 0 then return 0
    elseif setting > config.maxStack then return config.maxStack - config.minThreshold + 2
    else return setting - config.minThreshold + 1 end
end

local function GetSettingsTable(settingsKey)
    if not settings then return {} end
    local currentSettings = GetSettings()
    local settingsTable = currentSettings[settingsKey]
    if type(settingsTable) ~= "table" then return {} end
    local result = (currentHotbar == HOTBAR_CATEGORY_PRIMARY or currentHotbar == HOTBAR_CATEGORY_WEREWOLF or currentHotbar == HOTBAR_CATEGORY_DAEDRIC_ARTIFACT or currentHotbar == HOTBAR_CATEGORY_TEMPORARY) and settingsTable.mainBar or settingsTable.offBar
    return result or {}
end

local function IsAdvancedModeEnabled(abilityId, modeType)
    local tbl = GetSettingsTable("advancedBlockMode")
    local savedMode = tbl[abilityId]
    
    if not savedMode then return false end
    
    if savedMode == true then return true end
    
    if modeType then
        return savedMode == modeType
    end
    
    return true
end

local function GetSlotBoundAbilityIdSafe(slotNum)
    if not slotNum then return 0 end
    local slottedId = GetSlotBoundId(slotNum, currentHotbar)
    if not slottedId or slottedId == 0 then return 0 end
    
    local actionType = GetSlotType(slotNum, currentHotbar)
    if actionType == ACTION_TYPE_CRAFTED_ABILITY then
        slottedId = GetAbilityIdForCraftedAbilityId(slottedId) or 0
    end
    return slottedId
end

local rankCache = {}

local function GetSkillRank(slotNum)
    if not slotNum then return 4 end
    
    local abilityId = GetSlotBoundId(slotNum, currentHotbar)
    if not abilityId or abilityId == 0 then return 4 end

    if rankCache[abilityId] then return rankCache[abilityId] end

    local actionType = GetSlotType(slotNum, currentHotbar)
    if actionType == ACTION_TYPE_CRAFTED_ABILITY then
        rankCache[abilityId] = 4
        return 4
    end

    if GetAbilityProgressionRankFromAbilityId then
        local rank = GetAbilityProgressionRankFromAbilityId(abilityId)
        if rank then 
            rankCache[abilityId] = rank
            return rank 
        end
    end

    for skillType = 1, GetNumSkillTypes() do
        local numLines = GetNumSkillLines(skillType)
        for skillLineIndex = 1, numLines do
            local numAbilities = GetNumSkillAbilities(skillType, skillLineIndex)
            for skillIndex = 1, numAbilities do
                
                local id = GetSkillAbilityId(skillType, skillLineIndex, skillIndex, true)
                
                if id == abilityId then
                    
                    local currentRank = GetSkillAbilityUpgradeInfo(skillType, skillLineIndex, skillIndex)
                    currentRank = currentRank or 4
                    
                    rankCache[abilityId] = currentRank
                    return currentRank
                end
            end
        end
    end

    rankCache[abilityId] = 4
    return 4
end

local function GetScribingMaxDuration(abilityId, slotNum)
    local config = SCRIBING_DOT_HOT[abilityId]
    if not config then return 0 end

    if config.fixed then return config.fixed end

    if not slotNum then return 0 end

    local slotBoundId = GetSlotBoundId(slotNum, currentHotbar)
    local s1, s2, s3 = GetCraftedAbilityActiveScriptIds(slotBoundId)

    local d1 = (config.script1 and config.script1[s1]) or 0
    local d2 = (config.script2 and config.script2[s2]) or 0
    local d3 = (config.script3 and config.script3[s3]) or 0

    return math.max(d1, d2, d3)
end

local function GetDotHotDuration(abilityId, slotNum)

    local config = DOT_HOT_CONFIG[abilityId]
    if config then
        if config.durations then
            if not slotNum then
                for i = 3, 8 do
                    if GetSlotBoundAbilityIdSafe(i) == abilityId then
                        slotNum = i
                        break
                    end
                end
            end
            local rank = GetSkillRank(slotNum)
            if rank < 1 then rank = 1 end
            if rank > 4 then rank = 4 end
            return config.durations[rank] or config.durations[4]
        else
            return config.maxDuration or 0
        end
    end

    return GetScribingMaxDuration(abilityId, slotNum)
end

local function IsExceptionBanner(slotBoundId, actionType)
    if exceptionBannerCache[slotBoundId] ~= nil then return exceptionBannerCache[slotBoundId] end
    
    if actionType == ACTION_TYPE_CRAFTED_ABILITY then
        local script1, script2, script3 = GetCraftedAbilityActiveScriptIds(slotBoundId)
        
        if script1 == SCRIBING_LOGIC.primaryScript then
            local triggerData = SCRIBING_LOGIC.triggers[script2]
            
            if triggerData then
                if triggerData.ignoreClass then
                    local playerClass = playerClassId or GetUnitClassId("player")
                    exceptionBannerCache[slotBoundId] = (playerClass ~= triggerData.ignoreClass)
                    return exceptionBannerCache[slotBoundId]
                end
                
                exceptionBannerCache[slotBoundId] = true
                return true
            end
        end
    end
    
    exceptionBannerCache[slotBoundId] = false
    return false
end

--local function hasActiveBannerBuff()
--    for id, _ in pairs(activeBuffs) do
--        for _, range in ipairs(BANNER_BUFF_RANGES) do
--            if id >= range.min and id <= range.max then
--                return true
--            end
--        end
--    end
--    return false
--end

local function hasActiveBannerBuff()
    for id, _ in pairs(activeBuffs) do
        if BANNER_BUFF_RANGES[id] then
            return true
        end
    end
    return false
end

local function hasSpecificBuff(buffId)
    return activeBuffs[buffId] ~= nil
end

local function getTexture(state, type, category)
    local texSet
    if category == "banner" then
        if state == BANNER_STATE_UNLOCKED then texSet = TEXTURE_PATHS.unlocked
        elseif state == BANNER_STATE_COMBAT_ONLY then texSet = TEXTURE_PATHS.combat
        elseif state == BANNER_STATE_SMART_BLOCK then texSet = TEXTURE_PATHS.smart
        else texSet = TEXTURE_PATHS.locked end
    elseif category == "werewolf" then
        if state == 0 then texSet = TEXTURE_PATHS.unlocked
        elseif state == 1 then texSet = TEXTURE_PATHS.werewolf
        else texSet = TEXTURE_PATHS.locked end
    else 
        if state == STATE_UNLOCKED then texSet = TEXTURE_PATHS.unlocked
        elseif state == STATE_COMBAT_ONLY then texSet = TEXTURE_PATHS.combat
        else texSet = TEXTURE_PATHS.locked end
    end
    
    if type == "normal" then return texSet.normal
    elseif type == "pressed" then return texSet.pressed
    else return texSet.over end
end

local function GetLockTextures(iconType, state)
    if iconType == "settings" then
        return TEXTURE_PATHS.settings.normal, TEXTURE_PATHS.settings.pressed, TEXTURE_PATHS.settings.over
    elseif iconType == "locked" or iconType == "unlocked" then
        local texSet = TEXTURE_PATHS[iconType]
        return texSet.normal, texSet.pressed, texSet.over
    else
        local category = "default"
        if iconType == "banner" then category = "banner"
        elseif iconType == "werewolf" then category = "werewolf" end

        return getTexture(state, "normal", category), 
               getTexture(state, "pressed", category), 
               getTexture(state, "over", category)
    end
end

local function UpdateLockStatus(abilityId, shouldLock, soundTypeOverride)
    if not settings then return end
    
    if shouldLock then
        LSB.RegisterSkillBlock(ADDON_NAME, abilityId, blockBoth, settings.displayAlert)
        local sound = soundTypeOverride or SOUNDS_INVENTORY_ITEM_LOCKED
        if sound then PlaySound(sound) end
    else
        LSB.UnregisterSkillBlock(ADDON_NAME, abilityId)
        local sound = soundTypeOverride or SOUNDS_INVENTORY_ITEM_UNLOCKED
        if sound then PlaySound(sound) end
    end
end

local function RegisterSilentBlock(abilityId)
    LSB.RegisterSkillBlock(ADDON_NAME, abilityId, blockBoth, settings.displayAlert)
end

local function ToggleNumericSetting(settingsKey, abilityId, onValue, offValue)
    local settingsTable = GetSettingsTable(settingsKey)
    local current = settingsTable[abilityId] or offValue
    
    if current ~= offValue then
        settingsTable[abilityId] = offValue
        UpdateLockStatus(abilityId, false)
    else
        settingsTable[abilityId] = onValue
        UpdateLockStatus(abilityId, true)
    end
    return true
end

-------------------------------------------------------------------------------
--------------------------[    Logic Strategies    ]---------------------------
-------------------------------------------------------------------------------

local function UpdateExternalBlockRegistration(abilityId, playSoundType)
    if not settings then return end
    
    local shouldBlockAnywhere = (settings.mainBarBlockedAbilities[abilityId] or settings.offBarBlockedAbilities[abilityId])
    
    if shouldBlockAnywhere then
        UpdateLockStatus(abilityId, true, (playSoundType == "LOCK") and SOUNDS_INVENTORY_ITEM_LOCKED or nil)
    else
        UpdateLockStatus(abilityId, false, (playSoundType == "UNLOCK") and SOUNDS_INVENTORY_ITEM_UNLOCKED or nil)
    end
end

local function shouldBlockTargetHpAbility(abilityId)
    local settingsTable = GetSettingsTable("targetHpAbilitySettings")
    local hpThreshold = settingsTable[abilityId] or 100

    if hpThreshold == 100 then return false end
    if hpThreshold == 0 then return true end
    
    if not DoesUnitExist("reticleover") then return true end
    
    return targetHealthPercent > hpThreshold
end

local function shouldBlockStackAbility(abilityId, config)
    local settingsTable = GetSettingsTable("stackAbilitySettings")
    local setting = settingsTable[abilityId] or 0
    
    if setting == 0 then return false end
    if setting > config.maxStack then return true end
    
    if config.mode == "stage" then
        
        local buff1Active = activeBuffs[config.buffId] ~= nil
        
        if setting == 1 then
            return buff1Active
        end
        
        if setting == 2 then
            local buff2Active = (config.buffId2 and (activeBuffs[config.buffId2] ~= nil))
            return buff1Active or buff2Active
        end
        
        return false
    end

    local currentStacks = activeBuffs[config.buffId] or 0

    if config.mode == "reverse" then
        return currentStacks >= setting
    end

    return currentStacks < setting
end

local function IsToggleUltimateActive(abilityId)
    if not TOGGLE_ULTIMATES[abilityId] then return false end
    return activeBuffs[abilityId] and activeBuffs[abilityId] >= 0
end

local function IsOpenWorld()
    if GetCurrentZoneHouseId() > 0 then return false end

    local mapContentType = GetMapContentType()
    
    if mapContentType ~= MAP_CONTENT_NONE then 
        return false 
    end

    if GetZoneDungeonDifficulty and GetZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_NONE then
        return false
    end

    local success, inDungeon = pcall(function() return IsUnitInDungeon("player") end)
    if success and inDungeon then
        return false
    end

    if GetZoneType then
        local zoneType = GetZoneType()
        if zoneType ~= 1 then
            return false
        end
    end

    return true
end

local function IsAnyBlockConfigured(abilityId)
    if not settings then return false end

    if settings.doubleCastBlockedAbilities.mainBar[abilityId] or 
       settings.doubleCastBlockedAbilities.offBar[abilityId] then 
       return true 
    end

    if settings.criminalBlockSettings.mainBar[abilityId] or 
       settings.criminalBlockSettings.offBar[abilityId] then 
       return true 
    end

    if settings.mainBarBlockedAbilities[abilityId] or 
       settings.offBarBlockedAbilities[abilityId] then 
       return true 
    end

    local stackMain = settings.stackAbilitySettings.mainBar[abilityId] or 0
    local stackOff = settings.stackAbilitySettings.offBar[abilityId] or 0
    if stackMain > 0 or stackOff > 0 then return true end

    local hpMain = settings.targetHpAbilitySettings.mainBar[abilityId] or 100
    local hpOff = settings.targetHpAbilitySettings.offBar[abilityId] or 100
    if hpMain < 100 or hpOff < 100 then return true end

    local ultMain = settings.ultimateAbilitySettings.mainBar[abilityId] or 0
    local ultOff = settings.ultimateAbilitySettings.offBar[abilityId] or 0
    if ultMain > 0 or ultOff > 0 then return true end

    local dotMain = settings.dotHotSettings.mainBar[abilityId] or 0
    local dotOff = settings.dotHotSettings.offBar[abilityId] or 0
    if dotMain > 0 or dotOff > 0 then return true end

    local debuffMain = settings.debuffAbilitySettings.mainBar[abilityId] or 0
    local debuffOff = settings.debuffAbilitySettings.offBar[abilityId] or 0
    if debuffMain > 0 or debuffOff > 0 then return true end

    if BUFF_COMBAT_ABILITY_IDS[abilityId] then
         local bcMain = settings.buffCombatSettings.mainBar[abilityId] or 0
         local bcOff = settings.buffCombatSettings.offBar[abilityId] or 0
         if bcMain ~= 0 or bcOff ~= 0 then return true end
    end

    if COMBAT_ONLY_ABILITY_IDS[abilityId] then
         if (settings.combatOnlyBlockState or 0) ~= 0 then return true end
    end

    if WEREWOLF_ULTIMATE_IDS[abilityId] then
         local wwMain = settings.werewolfBlockSettings.mainBar[abilityId] or 0
         local wwOff = settings.werewolfBlockSettings.offBar[abilityId] or 0
         if wwMain > 0 or wwOff > 0 then return true end
    end
    
    if BANNER_ABILITY_IDS[abilityId] then
         if (settings.bannerBlockState or 0) ~= 0 then return true end
    end

    return false
end

local Handlers = {}

Handlers.CombatOnly = {
    matches = function(id) return COMBAT_ONLY_ABILITY_IDS[id] end,
    shouldBlock = function(id) 
        local currentSettings = GetSettings()
        local s = currentSettings.combatOnlyBlockState or STATE_UNLOCKED
        if s == STATE_FULL_BLOCK then return true
        elseif s == STATE_COMBAT_ONLY then return isPlayerInCombat
        else return false end
    end,
    toggle = function(id)
        if not settings then return true end
        
        local ns = ((settings.combatOnlyBlockState or 0) + 1) % 3
        settings.combatOnlyBlockState = ns
        local doBlock = (ns ~= STATE_UNLOCKED)
        for cid, _ in pairs(COMBAT_ONLY_ABILITY_IDS) do 
             UpdateLockStatus(cid, doBlock, nil)
        end
        PlaySound(doBlock and SOUNDS_INVENTORY_ITEM_LOCKED or SOUNDS_INVENTORY_ITEM_UNLOCKED)
        return true
    end,
    forceToggle = function(id)
        if not settings then return true end
        
        local s = settings.combatOnlyBlockState or STATE_UNLOCKED
        local newState = (s == STATE_UNLOCKED) and STATE_FULL_BLOCK or STATE_UNLOCKED
        settings.combatOnlyBlockState = newState
        
        local doBlock = (newState == STATE_FULL_BLOCK)
        for cid, _ in pairs(COMBAT_ONLY_ABILITY_IDS) do 
            UpdateLockStatus(cid, doBlock, nil)
        end
        PlaySound(doBlock and SOUNDS_INVENTORY_ITEM_LOCKED or SOUNDS_INVENTORY_ITEM_UNLOCKED)
        return true
    end,
    getIcon = function(id) 
        local currentSettings = GetSettings()
        return "combat", currentSettings.combatOnlyBlockState or STATE_UNLOCKED 
    end,
    getTooltip = function(id) 
        local currentSettings = GetSettings()
        local s = currentSettings.combatOnlyBlockState or 0
        return (s==0 and GetString(SKILLBLOCKER_NJ_UNLOCKED)) or (s==1 and GetString(SKILLBLOCKER_NJ_LOCKED_COMBAT)) or GetString(SKILLBLOCKER_NJ_LOCKED)
    end
}

Handlers.Stack = {
    matches = function(id) return STACK_ABILITY_CONFIG[id] ~= nil and IsAdvancedModeEnabled(id, "Stack") end,
    shouldBlock = function(id) return shouldBlockStackAbility(id, STACK_ABILITY_CONFIG[id]) end,
    toggle = function(id, slotNum)
        if settingsWindow and settingsWindow.window and not settingsWindow.window:IsHidden() and currentSettingsAbilityId == id then 
            HideAllSettingsWindows() 
        else 
            ShowSettingsWindow(id, slotNum) 
        end
        return false 
    end,
    forceToggle = function(id)
        local config = STACK_ABILITY_CONFIG[id]
        return ToggleNumericSetting("stackAbilitySettings", id, config.maxStack + 1, 0)
    end,
    getIcon = function(id) return "settings", 0 end,
    getTooltip = function(id) return GetString(SKILLBLOCKER_NJ_BLOCK_SETTINGS) end
}

Handlers.BuffCombat = {
    matches = function(id) return BUFF_COMBAT_ABILITY_IDS[id] ~= nil end,
    shouldBlock = function(id)
        local tbl = GetSettingsTable("buffCombatSettings")
        local s = tbl[id] or STATE_UNLOCKED
        if s == STATE_FULL_BLOCK then return true
        elseif s == STATE_COMBAT_ONLY then return hasSpecificBuff(BUFF_COMBAT_ABILITY_IDS[id]) and isPlayerInCombat
        else return false end
    end,
    toggle = function(id)
        local tbl = GetSettingsTable("buffCombatSettings")
        local currentState = tbl[id] or 0
        local ns = (currentState + 1) % 3
        tbl[id] = ns
        local mainState = settings.buffCombatSettings.mainBar[id] or STATE_UNLOCKED
        local offState = settings.buffCombatSettings.offBar[id] or STATE_UNLOCKED
        
        local shouldLock = (mainState ~= STATE_UNLOCKED or offState ~= STATE_UNLOCKED)
        UpdateLockStatus(id, shouldLock)
        return true
    end,
    forceToggle = function(id)
        local tbl = GetSettingsTable("buffCombatSettings")
        local currentState = tbl[id] or STATE_UNLOCKED
        
        if currentState ~= STATE_UNLOCKED then
            tbl[id] = STATE_UNLOCKED
            local otherBarTbl = (currentHotbar == HOTBAR_CATEGORY_PRIMARY) and settings.buffCombatSettings.offBar or settings.buffCombatSettings.mainBar
            if (otherBarTbl[id] or STATE_UNLOCKED) == STATE_UNLOCKED then
                 UpdateLockStatus(id, false)
            else
                PlaySound(SOUNDS_INVENTORY_ITEM_UNLOCKED)
            end
        else
            tbl[id] = STATE_FULL_BLOCK
            UpdateLockStatus(id, true)
        end
        return true
    end,
    getIcon = function(id) return "combat", GetSettingsTable("buffCombatSettings")[id] or STATE_UNLOCKED end,
    getTooltip = function(id)
        local s = GetSettingsTable("buffCombatSettings")[id] or 0
        return (s==0 and GetString(SKILLBLOCKER_NJ_UNLOCKED)) or (s==1 and GetString(SKILLBLOCKER_NJ_LOCKED_COMBAT)) or GetString(SKILLBLOCKER_NJ_LOCKED)
    end
}

Handlers.ExceptionBanner = {
    matches = function(id, slotNum)
        if not BANNER_ABILITY_IDS[id] then return false end
        local slotBoundId = GetSlotBoundId(slotNum, currentHotbar)
        local actionType = GetSlotType(slotNum, currentHotbar)
        return IsExceptionBanner(slotBoundId, actionType)
    end,
    shouldBlock = function(id)
        local currentSettings = GetSettings()
        if currentHotbar == HOTBAR_CATEGORY_PRIMARY or currentHotbar == HOTBAR_CATEGORY_WEREWOLF or currentHotbar == HOTBAR_CATEGORY_DAEDRIC_ARTIFACT or currentHotbar == HOTBAR_CATEGORY_TEMPORARY then
            return currentSettings.mainBarBlockedAbilities and currentSettings.mainBarBlockedAbilities[id] == true
        elseif currentHotbar == HOTBAR_CATEGORY_BACKUP then
            return currentSettings.offBarBlockedAbilities and currentSettings.offBarBlockedAbilities[id] == true 
        end
        return false
    end,
    toggle = function(id)
        if not settings then return true end
        
        local isCurrentlyBlocked = settings.mainBarBlockedAbilities[id] or false
        local newState = not isCurrentlyBlocked
        if newState then
            settings.mainBarBlockedAbilities[id] = true
            settings.offBarBlockedAbilities[id] = true
            UpdateLockStatus(id, true)
        else
            settings.mainBarBlockedAbilities[id] = nil
            settings.offBarBlockedAbilities[id] = nil
            UpdateLockStatus(id, false)
        end
        return true
    end,
    getIcon = function(id)
        local currentSettings = GetSettings()
        local mainBar = currentSettings.mainBarBlockedAbilities or {}
        local offBar = currentSettings.offBarBlockedAbilities or {}
        local isBlocked = mainBar[id] or offBar[id]
        return (isBlocked and "locked" or "unlocked"), 0
    end,
    getTooltip = function(id)
        local currentSettings = GetSettings()
        local mainBar = currentSettings.mainBarBlockedAbilities or {}
        local offBar = currentSettings.offBarBlockedAbilities or {}
        local isBlocked = mainBar[id] or offBar[id]
        return isBlocked and GetString(SKILLBLOCKER_NJ_LOCKED) or GetString(SKILLBLOCKER_NJ_UNLOCKED)
    end
}

Handlers.Banner = {
    matches = function(id, slotNum)
        if not BANNER_ABILITY_IDS[id] then return false end
        local slotBoundId = GetSlotBoundId(slotNum, currentHotbar)
        local actionType = GetSlotType(slotNum, currentHotbar)
        return not IsExceptionBanner(slotBoundId, actionType)
    end,
    shouldBlock = function(id)
        local currentSettings = GetSettings()
        local s = currentSettings.bannerBlockState or BANNER_STATE_UNLOCKED
        if s == BANNER_STATE_UNLOCKED then return false 
        elseif s == BANNER_STATE_COMBAT_ONLY then return isPlayerInCombat and hasActiveBannerBuff()
        elseif s == BANNER_STATE_SMART_BLOCK then return hasActiveBannerBuff() 
        elseif s == BANNER_STATE_FULL_LOCK then return true end
        return false
    end,
    toggle = function(id)
        if not settings then return true end
        
        local ns = ((settings.bannerBlockState or 0) + 1) % 4
        settings.bannerBlockState = ns
        if ns ~= BANNER_STATE_UNLOCKED then
            settings.mainBarBlockedAbilities[id] = nil
            settings.offBarBlockedAbilities[id] = nil
        end
        local doBlock = (ns ~= BANNER_STATE_UNLOCKED)
        for bid, _ in pairs(BANNER_ABILITY_IDS) do 
             UpdateLockStatus(bid, doBlock, nil)
        end
        PlaySound((ns == 0) and SOUNDS_INVENTORY_ITEM_UNLOCKED or SOUNDS_INVENTORY_ITEM_LOCKED)
        return true
    end,
    forceToggle = function(id)
        if not settings then return true end
        
        local s = settings.bannerBlockState or BANNER_STATE_UNLOCKED
        if s ~= BANNER_STATE_UNLOCKED then
            settings.bannerBlockState = BANNER_STATE_UNLOCKED
            for bid, _ in pairs(BANNER_ABILITY_IDS) do UpdateLockStatus(bid, false, nil) end
            PlaySound(SOUNDS_INVENTORY_ITEM_UNLOCKED)
        else
            settings.bannerBlockState = BANNER_STATE_FULL_LOCK
            settings.mainBarBlockedAbilities[id] = nil
            settings.offBarBlockedAbilities[id] = nil
            for bid, _ in pairs(BANNER_ABILITY_IDS) do UpdateLockStatus(bid, true, nil) end
            PlaySound(SOUNDS_INVENTORY_ITEM_LOCKED)
        end
        return true
    end,
    getIcon = function(id) 
        local currentSettings = GetSettings()
        return "banner", currentSettings.bannerBlockState or BANNER_STATE_UNLOCKED 
    end,
    getTooltip = function(id)
        local currentSettings = GetSettings()
        local s = currentSettings.bannerBlockState or 0
        if s == BANNER_STATE_UNLOCKED then return GetString(SKILLBLOCKER_NJ_UNLOCKED)
        elseif s == BANNER_STATE_COMBAT_ONLY then return GetString(SKILLBLOCKER_NJ_LOCKED_COMBAT)
        elseif s == BANNER_STATE_SMART_BLOCK then return GetString(SKILLBLOCKER_NJ_LOCKED_ACTIVE)
        else return GetString(SKILLBLOCKER_NJ_LOCKED) end
    end
}

Handlers.TargetHP = {
    matches = function(id) return TARGET_HP_ABILITY_CONFIG[id] ~= nil and IsAdvancedModeEnabled(id, "TargetHP") end,
    shouldBlock = function(id) return shouldBlockTargetHpAbility(id) end,
    toggle = function(id, slotNum)
        if hpSettingsWindow and hpSettingsWindow.window and not hpSettingsWindow.window:IsHidden() and 
           currentSettingsAbilityId == id then HideAllSettingsWindows() else ShowHpSettingsWindow(id, slotNum) end
        return false
    end,
    forceToggle = function(id)
        return ToggleNumericSetting("targetHpAbilitySettings", id, 0, 100)
    end,
    getIcon = function(id) return "settings", 0 end,
    getTooltip = function(id) return GetString(SKILLBLOCKER_NJ_BLOCK_SETTINGS) end
}

Handlers.Ultimate = {
    matches = function(id, slotNum) 
        return slotNum == ULTIMATE_SLOT_INDEX and IsAdvancedModeEnabled(id, "Ultimate") 
    end,
    shouldBlock = function(id) 
        if TOGGLE_ULTIMATES[id] and IsToggleUltimateActive(id) then 
            return false 
        end

        local settingsTable = GetSettingsTable("ultimateAbilitySettings")
        local threshold = settingsTable[id] or 0
        
        if threshold == 0 then return false end
        
        if threshold > 500 then return true end 
        
        local currentPower = GetUnitPower("player", POWERTYPE_ULTIMATE)
        
        if currentPower < threshold then
            return true
        end

        return false 
    end,
    toggle = function(id, slotNum)
        if ultSettingsWindow and ultSettingsWindow.window and not ultSettingsWindow.window:IsHidden() and 
           currentSettingsAbilityId == id then HideAllSettingsWindows() else ShowUltimateSettingsWindow(id, slotNum) end
        return false
    end,
    forceToggle = function(id)
        return ToggleNumericSetting("ultimateAbilitySettings", id, 501, 0)
    end,
    getIcon = function(id) return "settings", 0 end,
    getTooltip = function(id) return GetString(SKILLBLOCKER_NJ_BLOCK_SETTINGS) end
}

Handlers.DotHot = {
    matches = function(id) 
        return (DOT_HOT_CONFIG[id] ~= nil or SCRIBING_DOT_HOT[id] ~= nil) and IsAdvancedModeEnabled(id, "DotHot") 
    end,
    shouldBlock = function(id, slotNum)
        local settingsTable = GetSettingsTable("dotHotSettings")
        local threshold = settingsTable[id] or 0 
        
        local maxDuration = GetDotHotDuration(id, slotNum)
        
        if threshold == 0 then return false end
        if threshold > maxDuration then return true end
        
        -- 1. Game
        local timeRemainingMS = GetActionSlotEffectTimeRemaining(slotNum)
        
        -- 2. FAB+
        if timeRemainingMS == 0 then
            local fabTime = GetFabRemainingTime(id)
            if fabTime > 0 then
                timeRemainingMS = fabTime
            end
        end
        
        local unblockPointMS = (maxDuration - threshold) * 1000
        
        return timeRemainingMS > unblockPointMS
    end,
    toggle = function(id, slotNum)
        if dotHotSettingsWindow and dotHotSettingsWindow.window and not dotHotSettingsWindow.window:IsHidden() and 
           currentSettingsAbilityId == id then HideAllSettingsWindows() else ShowDotHotSettingsWindow(id, slotNum) end
        return false
    end,
    forceToggle = function(id)
        local maxDuration = GetDotHotDuration(id, nil)
        return ToggleNumericSetting("dotHotSettings", id, maxDuration + 0.1, 0)
    end,
    getIcon = function(id) return "settings", 0 end,
    getTooltip = function(id) return GetString(SKILLBLOCKER_NJ_BLOCK_SETTINGS) end
}

Handlers.Debuff = {
    matches = function(id) return DEBUFF_ABILITY_CONFIG[id] ~= nil and IsAdvancedModeEnabled(id, "Debuff") end,
    shouldBlock = function(id, slotNum)
        local settingsTable = GetSettingsTable("debuffAbilitySettings")
        local setting = settingsTable[id] or 0
        local config = DEBUFF_ABILITY_CONFIG[id]
        
        if setting == 0 then 
            for debuffId, _ in pairs(config.debuffIds) do
                activeDebuffs[debuffId] = 0
            end
            return false 
        end
        
        if setting > config.maxStages then 
            return true 
        end
        
        local hasRelevantDebuff = false
        for debuffId, stage in pairs(config.debuffIds) do
            if (activeDebuffs[debuffId] or 0) > 0 then
                if stage <= setting then
                    hasRelevantDebuff = true
                    break
                end
            end
        end
        
        if hasRelevantDebuff then
            return true
        end
        
        if slotNum and (config.maxStages == 1 and setting >= 1) or (config.maxStages == 2 and setting == 2) then
            local timeRemainingMS = GetActionSlotEffectTimeRemaining(slotNum)
            
            -- FancyActionBar+
            if timeRemainingMS == 0 then
                local fabTime = GetFabRemainingTime(id)
                if fabTime > 0 then
                    timeRemainingMS = fabTime
                end
            end

            if timeRemainingMS > 0 then
                return true
            else
                for debuffId, _ in pairs(config.debuffIds) do
                    activeDebuffs[debuffId] = 0
                end
            end
        end
        
        return false
    end,
    toggle = function(id, slotNum)
        if debuffSettingsWindow and debuffSettingsWindow.window and not debuffSettingsWindow.window:IsHidden() and 
           currentSettingsAbilityId == id then 
            HideAllSettingsWindows() 
        else 
            ShowDebuffSettingsWindow(id, slotNum) 
        end
        return false 
    end,
    forceToggle = function(id)
        local config = DEBUFF_ABILITY_CONFIG[id]
        local newSetting = ToggleNumericSetting("debuffAbilitySettings", id, config.maxStages + 1, 0)
        
        if newSetting == 0 then
            for debuffId, _ in pairs(config.debuffIds) do
                activeDebuffs[debuffId] = 0
            end
        end
        
        return true
    end,
    getIcon = function(id) return "settings", 0 end,
    getTooltip = function(id) return GetString(SKILLBLOCKER_NJ_BLOCK_SETTINGS) end
}

Handlers.Criminal = {
    matches = function(id) return CRIMINAL_ABILITY_IDS[id] end,
    shouldBlock = function(id)
        if isPlayerInCombat then return false end
        if not IsOpenWorld() then return false end
        local settingsTable = GetSettingsTable("criminalBlockSettings")
        return settingsTable[id] == true
    end,
    
    toggle = function(id)
        local settingsTable = GetSettingsTable("criminalBlockSettings")
        
        if settingsTable[id] then 
            settingsTable[id] = nil 
        else 
            settingsTable[id] = true 
        end
        
        local shouldRegister = IsAnyBlockConfigured(id)
        
        UpdateLockStatus(id, shouldRegister, nil)
        
        return true
    end,
    
    forceToggle = function(id) return Handlers.Criminal.toggle(id) end,
    getIcon = function(id) return "unlocked", 0 end, 
    getTooltip = function(id) return "" end 
}

Handlers.DoubleCast = {
    matches = function(id) 
        local tbl = GetSettingsTable("doubleCastBlockedAbilities")
        return tbl[id] == true 
    end,
    shouldBlock = function(id)
        return id == lastUsedAbilityId
    end,
    toggle = function(id) return false end,
    forceToggle = function(id) return false end,
    getIcon = function(id) return "unlocked", 0 end,
    getTooltip = function(id) return GetString(SKILLBLOCKER_NJ_UNLOCKED) end
}

Handlers.Werewolf = {
    matches = function(id) return WEREWOLF_ULTIMATE_IDS[id] end,
    
    shouldBlock = function(id)
        local tbl = GetSettingsTable("werewolfBlockSettings")
        local state = tbl[id] or 0
        
        if state == 0 then return false end 
        if state == 2 then return true end
        
        if state == 1 then
            return currentHotbar == HOTBAR_CATEGORY_WEREWOLF
        end
        
        return false
    end,
    
    toggle = function(id)
        local tbl = GetSettingsTable("werewolfBlockSettings")
        local currentState = tbl[id] or 0
        local ns = (currentState + 1) % 3 
        tbl[id] = ns
        
        local shouldLock = IsAnyBlockConfigured(id)
        UpdateLockStatus(id, shouldLock) 
        return true
    end,
    
    forceToggle = function(id)
        local tbl = GetSettingsTable("werewolfBlockSettings")
        local currentState = tbl[id] or 0
        
        if currentState ~= 0 then
            tbl[id] = 0
        else
            tbl[id] = 2
        end
        
        local shouldLock = IsAnyBlockConfigured(id)
        UpdateLockStatus(id, shouldLock)
        return true
    end,
    
    getIcon = function(id) 
        local state = GetSettingsTable("werewolfBlockSettings")[id] or 0
        return "werewolf", state 
    end,
    
    getTooltip = function(id)
        local s = GetSettingsTable("werewolfBlockSettings")[id] or 0
        if s == 0 then return GetString(SKILLBLOCKER_NJ_UNLOCKED)
        elseif s == 1 then return GetString(SKILLBLOCKER_NJ_LOCKED_WEREWOLF)
        else return GetString(SKILLBLOCKER_NJ_LOCKED) end
    end
}

Handlers.Standard = {
    matches = function(id) return true end,
    shouldBlock = function(id)
        local currentSettings = GetSettings()
        
        if currentHotbar == HOTBAR_CATEGORY_PRIMARY or currentHotbar == HOTBAR_CATEGORY_WEREWOLF or currentHotbar == HOTBAR_CATEGORY_DAEDRIC_ARTIFACT or currentHotbar == HOTBAR_CATEGORY_TEMPORARY then
            return currentSettings.mainBarBlockedAbilities and currentSettings.mainBarBlockedAbilities[id] == true
        elseif currentHotbar == HOTBAR_CATEGORY_BACKUP then
            return currentSettings.offBarBlockedAbilities and currentSettings.offBarBlockedAbilities[id] == true
        end
        return false
    end,
    toggle = function(id)
        if not settings then return true end 
        
        local targetTable = (currentHotbar == HOTBAR_CATEGORY_PRIMARY or currentHotbar == HOTBAR_CATEGORY_WEREWOLF or currentHotbar == HOTBAR_CATEGORY_DAEDRIC_ARTIFACT or currentHotbar == HOTBAR_CATEGORY_TEMPORARY) and settings.mainBarBlockedAbilities or settings.offBarBlockedAbilities
        
        if targetTable[id] then
            targetTable[id] = nil
            
            if IsAnyBlockConfigured(id) then
                PlaySound(SOUNDS_INVENTORY_ITEM_UNLOCKED)
            else
                UpdateExternalBlockRegistration(id, "UNLOCK")
            end
        else
            targetTable[id] = true
            UpdateExternalBlockRegistration(id, "LOCK")
        end
        return true
    end,
    getIcon = function(id) 
        local currentSettings = GetSettings()
        local isBlocked = ((currentHotbar == HOTBAR_CATEGORY_PRIMARY or currentHotbar == HOTBAR_CATEGORY_WEREWOLF or currentHotbar == HOTBAR_CATEGORY_DAEDRIC_ARTIFACT or currentHotbar == HOTBAR_CATEGORY_TEMPORARY) and 
                        currentSettings.mainBarBlockedAbilities and currentSettings.mainBarBlockedAbilities[id]) or 
                        (currentHotbar == HOTBAR_CATEGORY_BACKUP and
                        currentSettings.offBarBlockedAbilities and currentSettings.offBarBlockedAbilities[id])
        return (isBlocked and "locked" or "unlocked"), 0 
    end,
    getTooltip = function(id)
        local currentSettings = GetSettings()
        local isBlocked = ((currentHotbar == HOTBAR_CATEGORY_PRIMARY or currentHotbar == HOTBAR_CATEGORY_WEREWOLF or currentHotbar == HOTBAR_CATEGORY_DAEDRIC_ARTIFACT or currentHotbar == HOTBAR_CATEGORY_TEMPORARY) and 
                        currentSettings.mainBarBlockedAbilities and currentSettings.mainBarBlockedAbilities[id]) or 
                        (currentHotbar == HOTBAR_CATEGORY_BACKUP and 
                        currentSettings.offBarBlockedAbilities and currentSettings.offBarBlockedAbilities[id])
        return isBlocked and GetString(SKILLBLOCKER_NJ_LOCKED) or GetString(SKILLBLOCKER_NJ_UNLOCKED)
    end
}

local OrderedHandlers = { 
    Handlers.CombatOnly, Handlers.Stack, Handlers.BuffCombat, 
    Handlers.ExceptionBanner, Handlers.Banner, Handlers.TargetHP,
    Handlers.Werewolf,
    Handlers.Ultimate, Handlers.DotHot,
    Handlers.Debuff,
    Handlers.Standard 
}

local function GetHandler(abilityId, slotNum)
    if not abilityId or abilityId == 0 then return nil end
    
    local cacheKey = slotNum 
    if handlerCache[cacheKey] and handlerCache[cacheKey].id == abilityId then
        return handlerCache[cacheKey].handler
    end

    for _, handler in ipairs(OrderedHandlers) do
        if handler.matches(abilityId, slotNum) then
            handlerCache[cacheKey] = { id = abilityId, handler = handler }
            return handler
        end
    end
    return nil
end

-------------------------------------------------------------------------------
----------------------------[      Block Logic      ]--------------------------
-------------------------------------------------------------------------------

shouldBlockAbility = function(slotNum, abilityId)

    local doubleCastSettings = GetSettingsTable("doubleCastBlockedAbilities")
    if doubleCastSettings[abilityId] and abilityId == lastUsedAbilityId then
        return true
    end

    local shouldBlock = false
    
    local handler = GetHandler(abilityId, slotNum)
    if handler then
        if handler.shouldBlock(abilityId, slotNum) then
            shouldBlock = true
        end
    end

    if Handlers.Criminal.matches(abilityId) and Handlers.Criminal.shouldBlock(abilityId) then
                local buffId = SB_NJ.Data.BuffCombat[abilityId]
                if buffId and activeBuffs[buffId] then
                    shouldBlock = false
                else
                    shouldBlock = true
                end
            end
        
        return shouldBlock
    end

blockBoth = function(slotNum, abilityId)
    return shouldBlockAbility(slotNum, abilityId)
end

-------------------------------------------------------------------------------
----------------------------[    Buff Tracking    ]----------------------------
-------------------------------------------------------------------------------

local function RefreshBuffCache()
    local unitTag = "player"
    local numBuffs = GetNumBuffs(unitTag)
    
    ZO_ClearTable(activeBuffs)
    
    for i = 1, numBuffs do
        local _, _, _, _, stackCount, _, _, _, _, _, abilityId = GetUnitBuffInfo(unitTag, i)
        if relevantBuffIds[abilityId] then
            activeBuffs[abilityId] = stackCount or 0
        end
    end
end

local function OnEffectChanged(_, changeType, _, _, unitTag, _, _, stackCount, _, _, _, _, _, _, _, abilityId, sourceType)
    if relevantBuffIds[abilityId] and (unitTag == "player") then
        if changeType == EFFECT_RESULT_FADED then
            activeBuffs[abilityId] = nil
        else
            activeBuffs[abilityId] = stackCount or 0
        end
        if SM:IsShowing("skills") then EventBus:FireCallbacks(EVENTS.UI_UPDATE) end
    end

    if relevantDebuffIds[abilityId] then
        if sourceType == COMBAT_UNIT_TYPE_PLAYER then 
            if changeType == EFFECT_RESULT_GAINED then
                activeDebuffs[abilityId] = (activeDebuffs[abilityId] or 0) + 1
            elseif changeType == EFFECT_RESULT_FADED then
                local count = (activeDebuffs[abilityId] or 0) - 1
                if count < 0 then count = 0 end
                activeDebuffs[abilityId] = count
            end
            
            EventBus:FireCallbacks(EVENTS.LOGIC_UPDATE)
            if SM:IsShowing("skills") then EventBus:FireCallbacks(EVENTS.UI_UPDATE) end
        end
    end
end

local lastUltCheckState = {} 

-------------------------------------------------------------------------------
-----------------------------[  Event Handlers   ]-----------------------------
-------------------------------------------------------------------------------

local function UpdateTargetHealth()
    if not DoesUnitExist("reticleover") then
        targetHealthPercent = 0 
        return
    end
    local current, max = GetUnitPower("reticleover", COMBAT_MECHANIC_FLAGS_HEALTH)
    if max > 0 then
        targetHealthPercent = math.floor((current / max) * 100 + 0.5)
    else
        targetHealthPercent = 0
    end
end

local function OnTargetChanged()
    UpdateTargetHealth()
    EventBus:FireCallbacks(EVENTS.LOGIC_UPDATE)
    if SM:IsShowing("skills") then EventBus:FireCallbacks(EVENTS.UI_UPDATE) end
end

local function OnReticleHealthUpdate(_, unitTag, _, powerType, powerValue, _, _)
    if unitTag ~= "reticleover" or powerType ~= COMBAT_MECHANIC_FLAGS_HEALTH then return end
    UpdateTargetHealth()
end

local function OnUltimateUpdate(_, unitTag, _, powerType, powerValue, _, _)
    if unitTag ~= "player" or powerType ~= POWERTYPE_ULTIMATE then return end

    local needsUpdate = false
    local settingsTable = GetSettingsTable("ultimateAbilitySettings")

    for abilityId, threshold in pairs(settingsTable) do
        if threshold > 0 then
            local shouldBlock
            if threshold > 500 then
                shouldBlock = true
            else
                shouldBlock = powerValue < threshold
            end
            
            if lastUltCheckState[abilityId] ~= shouldBlock then
                lastUltCheckState[abilityId] = shouldBlock
                needsUpdate = true
            end
        end
    end

    if needsUpdate then
        EventBus:FireCallbacks(EVENTS.LOGIC_UPDATE)
        if SM:IsShowing("skills") then EventBus:FireCallbacks(EVENTS.UI_UPDATE) end
    end
end

ScanHotbarForRelevantBuffs = function()

    handlerCache = {}
    exceptionBannerCache = {}

    if not settings then return end
    
    ZO_ClearTable(tempRelevantBuffs)
    local hasRelevantBuffSkills = false
    local hasUltimateBlock = false
    local hasHpBlock = false
    
    ZO_ClearTable(exceptionBannerCache)
    ZO_ClearTable(lastUltCheckState)
    
    local bannerState = settings.bannerBlockState or BANNER_STATE_UNLOCKED
    local buffCombatSettingsTable = GetSettingsTable("buffCombatSettings")
    local stackSettingsTable = GetSettingsTable("stackAbilitySettings")
    local doubleCastSettingsTable = GetSettingsTable("doubleCastBlockedAbilities")
    local ultimateSettingsTable = GetSettingsTable("ultimateAbilitySettings")
    local hpSettingsTable = GetSettingsTable("targetHpAbilitySettings")
    local dotHotSettingsTable = GetSettingsTable("dotHotSettings")
    local debuffSettingsTable = GetSettingsTable("debuffAbilitySettings")

    for i = 3, 8 do
        local slotBoundId = GetSlotBoundId(i, currentHotbar)
        local actionType = GetSlotType(i, currentHotbar)
        local abilityId
        local isExceptionBanner = false
        
        if actionType == ACTION_TYPE_CRAFTED_ABILITY then
            abilityId = GetAbilityIdForCraftedAbilityId(slotBoundId)
            isExceptionBanner = IsExceptionBanner(slotBoundId, actionType)
        else
            abilityId = slotBoundId
        end

        if abilityId and abilityId > 0 then
            local isAdvanced = IsAdvancedModeEnabled(abilityId)

            if doubleCastSettingsTable[abilityId] then
                RegisterSilentBlock(abilityId)
            end

            if i == ULTIMATE_SLOT_INDEX and isAdvanced then
                local ultThreshold = ultimateSettingsTable[abilityId] or 0
                if ultThreshold > 0 and ultThreshold < 500 then
                    hasUltimateBlock = true
                end
            end

            if TOGGLE_ULTIMATES[abilityId] then
                tempRelevantBuffs[abilityId] = true
                hasRelevantBuffSkills = true
            end

            if TARGET_HP_ABILITY_CONFIG[abilityId] and isAdvanced then
                local hpThreshold = hpSettingsTable[abilityId] or 100
                if hpThreshold > 0 and hpThreshold < 100 then
                    hasHpBlock = true
                end
            end
            
            local stackConfig = STACK_ABILITY_CONFIG[abilityId]
            if stackConfig and isAdvanced then
                local setting = stackSettingsTable[abilityId] or 0
                if setting > 0 and setting <= stackConfig.maxStack then
                    tempRelevantBuffs[stackConfig.buffId] = true
                    if stackConfig.buffId2 then
                        tempRelevantBuffs[stackConfig.buffId2] = true
                    end
                    hasRelevantBuffSkills = true
                end
            end

            local debuffConfig = DEBUFF_ABILITY_CONFIG[abilityId]
            if debuffConfig and isAdvanced then
                local setting = debuffSettingsTable[abilityId] or 0
                if setting > 0 then
                    for dId, _ in pairs(debuffConfig.debuffIds) do
                        tempRelevantBuffs[dId] = true 
                    end
                    hasRelevantBuffSkills = true
                end
            end
            
            if BUFF_COMBAT_ABILITY_IDS[abilityId] then
                local state = buffCombatSettingsTable[abilityId] or STATE_UNLOCKED
                if state == STATE_COMBAT_ONLY then
                    tempRelevantBuffs[BUFF_COMBAT_ABILITY_IDS[abilityId]] = true
                    hasRelevantBuffSkills = true
                end
            end

            if not isExceptionBanner and BANNER_ABILITY_IDS[abilityId] then
                if bannerState == BANNER_STATE_COMBAT_ONLY or bannerState == BANNER_STATE_SMART_BLOCK then
                    hasRelevantBuffSkills = true
                    --for _, range in ipairs(BANNER_BUFF_RANGES) do
                    --    for id = range.min, range.max do
                    --        tempRelevantBuffs[id] = true
                    --    end
                    --end
                    for buffId, _ in pairs(BANNER_BUFF_RANGES) do
                        tempRelevantBuffs[buffId] = true
                    end
                end
            end
        end
    end
    
    ZO_ClearTable(relevantBuffIds)
    ZO_ClearTable(relevantDebuffIds)
    for k, v in pairs(tempRelevantBuffs) do 
        local isDebuff = false
        for _, cfg in pairs(DEBUFF_ABILITY_CONFIG) do
            if cfg.debuffIds[k] then isDebuff = true break end
        end

        if isDebuff then
            relevantDebuffIds[k] = true
        else
            relevantBuffIds[k] = v
        end
    end

    if hasRelevantBuffSkills then
        if not isTrackingEffects then
            EM:RegisterForEvent(ADDON_NAME .. "_Effects", EVENT_EFFECT_CHANGED, OnEffectChanged)
            isTrackingEffects = true
        end
        RefreshBuffCache()
    else
        if isTrackingEffects then
            EM:UnregisterForEvent(ADDON_NAME .. "_Effects", EVENT_EFFECT_CHANGED)
            isTrackingEffects = false
            ZO_ClearTable(activeBuffs)
        end
    end

    if hasUltimateBlock then
        if not isTrackingUltimate then
            EM:RegisterForEvent(ADDON_NAME .. "_Ultimate", EVENT_POWER_UPDATE, OnUltimateUpdate)
            EM:AddFilterForEvent(ADDON_NAME .. "_Ultimate", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player", REGISTER_FILTER_POWER_TYPE, POWERTYPE_ULTIMATE)
            isTrackingUltimate = true
            local currentUlt = GetUnitPower("player", POWERTYPE_ULTIMATE)
            OnUltimateUpdate(nil, "player", nil, POWERTYPE_ULTIMATE, currentUlt, nil, nil)
        end
    else
        if isTrackingUltimate then
            EM:UnregisterForEvent(ADDON_NAME .. "_Ultimate", EVENT_POWER_UPDATE)
            isTrackingUltimate = false
        end
    end

    if hasHpBlock then
        if not isTrackingTargetHp then
            EM:RegisterForEvent(ADDON_NAME .. "_HpChange", EVENT_POWER_UPDATE, OnReticleHealthUpdate)
            EM:AddFilterForEvent(ADDON_NAME .. "_HpChange", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "reticleover", REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)
            
            EM:RegisterForEvent(ADDON_NAME .. "_TargetChange", EVENT_TARGET_CHANGED, OnTargetChanged)
            EM:AddFilterForEvent(ADDON_NAME .. "_TargetChange", EVENT_TARGET_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleover")
            
            isTrackingTargetHp = true
            UpdateTargetHealth() 
        end
    else
        if isTrackingTargetHp then
            EM:UnregisterForEvent(ADDON_NAME .. "_HpChange", EVENT_POWER_UPDATE)
            EM:UnregisterForEvent(ADDON_NAME .. "_TargetChange", EVENT_TARGET_CHANGED)
            isTrackingTargetHp = false
            targetHealthPercent = 0
        end
    end
end

-------------------------------------------------------------------------------
----------------------------[    UI Windows       ]----------------------------
-------------------------------------------------------------------------------

local function ForceLogicUpdate()
    ZO_ClearTable(handlerCache)
    ZO_ClearTable(exceptionBannerCache)
    
    UpdateTargetHealth() 
    RefreshBuffCache()   
    
    ZO_ClearTable(lastUltCheckState)
    local currentUlt = GetUnitPower("player", POWERTYPE_ULTIMATE)
    OnUltimateUpdate(nil, "player", nil, POWERTYPE_ULTIMATE, currentUlt, nil, nil)
    
    EventBus:FireCallbacks(EVENTS.LOGIC_UPDATE)
    EventBus:FireCallbacks(EVENTS.UI_UPDATE)
end

SB_NJ.ForceLogicUpdate = ForceLogicUpdate

HideAllSettingsWindows = function()
    if settingsWindow and settingsWindow.window and not settingsWindow.window:IsHidden() then
        settingsWindow.window:SetHidden(true)
        PlaySound(SOUNDS_WINDOW_CLOSE)
    end
    if hpSettingsWindow and hpSettingsWindow.window and not hpSettingsWindow.window:IsHidden() then
        hpSettingsWindow.window:SetHidden(true)
        PlaySound(SOUNDS_WINDOW_CLOSE)
    end
    if ultSettingsWindow and ultSettingsWindow.window and not ultSettingsWindow.window:IsHidden() then
        ultSettingsWindow.window:SetHidden(true)
        PlaySound(SOUNDS_WINDOW_CLOSE)
    end
    if dotHotSettingsWindow and dotHotSettingsWindow.window and not dotHotSettingsWindow.window:IsHidden() then
        dotHotSettingsWindow.window:SetHidden(true)
        PlaySound(SOUNDS_WINDOW_CLOSE)
    end
    if debuffSettingsWindow and debuffSettingsWindow.window and not debuffSettingsWindow.window:IsHidden() then
        debuffSettingsWindow.window:SetHidden(true)
        PlaySound(SOUNDS_WINDOW_CLOSE)
    end
end

local function CreateBaseSettingsWindow(uniqueName, titleWidth, containerHeight)
    local window = GetOrCreateControl(uniqueName, nil, nil, uniqueName)
    window:SetDimensions(titleWidth, 120)
    window:SetDrawLayer(DL_OVERLAY)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetHidden(true)
    
    local background = GetOrCreateControl("Background", window, CT_BACKDROP)
    background:SetAnchorFill()
    background:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 16) 
    background:SetCenterColor(0, 0, 0, 0.95) 
    background:SetEdgeColor(1, 1, 1, 1) 
    
    local abilityName = GetOrCreateControl("AbilityName", window, CT_LABEL)
    abilityName:SetAnchor(TOPLEFT, window, TOPLEFT, 10, 10)
    abilityName:SetDimensions(titleWidth - 20, 20)
    abilityName:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    abilityName:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    abilityName:SetFont("ZoFontWinH4")
    abilityName:SetColor(1, 0.8, 0, 1) 
    
    local closeButton = GetOrCreateControl("CloseButton", window, CT_BUTTON)
    closeButton:SetAnchor(TOPRIGHT, window, TOPRIGHT, -1, 5)
    closeButton:SetDimensions(25, 25)
    closeButton:SetNormalTexture("/esoui/art/buttons/closebutton_up.dds")
    closeButton:SetPressedTexture("/esoui/art/buttons/closebutton_down.dds")
    closeButton:SetMouseOverTexture("/esoui/art/buttons/closebutton_over.dds")
    closeButton:SetHandler("OnClicked", HideAllSettingsWindows)

    local settingsContainer = GetOrCreateControl("SettingsContainer", window, CT_CONTROL)
    settingsContainer:SetDimensions(titleWidth - 10, containerHeight)
    settingsContainer:SetAnchor(CENTER, window, CENTER, 0, 10)

    local valueLabel = GetOrCreateControl("ValueLabel", settingsContainer, CT_LABEL)
    valueLabel:SetAnchor(TOP, settingsContainer, TOP, 0, 5)
    valueLabel:SetDimensions(titleWidth - 10, 20)
    valueLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    valueLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    valueLabel:SetFont(FONT_SLIDER)
    valueLabel:SetColor(1, 1, 1, 1)

    return {
        window = window,
        abilityName = abilityName,
        container = settingsContainer,
        valueLabel = valueLabel
    }
end

local function CreateSliderComponent(parentContainer, prefix)
    local sliderContainer = GetOrCreateControl(prefix.."SliderContainer", parentContainer, CT_CONTROL)
    sliderContainer:SetDimensions(220, 25)
    sliderContainer:SetAnchor(CENTER, parentContainer, CENTER, 0, 5)
    
    local sliderBg = GetOrCreateControl(prefix.."SliderBg", sliderContainer, CT_BACKDROP)
    sliderBg:SetDimensions(150, 20) 
    sliderBg:SetAnchor(CENTER, sliderContainer, CENTER, 0, 0)
    sliderBg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 2)
    sliderBg:SetCenterColor(0.2, 0.2, 0.2, 0.8) 
    sliderBg:SetEdgeColor(0.8, 0.8, 0.8, 0.6) 
    
    local openLockButton = GetOrCreateControl(prefix.."OpenLock", sliderContainer, CT_BUTTON)
    openLockButton:SetAnchor(LEFT, sliderContainer, LEFT, 5, 0)
    openLockButton:SetDimensions(16, 16)
    openLockButton:SetNormalTexture(TEXTURE_PATHS.unlocked.normal)
    openLockButton:SetPressedTexture(TEXTURE_PATHS.unlocked.pressed)
    openLockButton:SetMouseOverTexture(TEXTURE_PATHS.unlocked.over)
    
    local slider = GetOrCreateControl(prefix.."Slider", sliderContainer, CT_SLIDER)
    slider:SetDimensions(150, 20)
    slider:SetAnchor(CENTER, sliderContainer, CENTER, 0, 0)
    slider:SetOrientation(ORIENTATION_HORIZONTAL)
    slider:SetThumbTexture("EsoUI/Art/Miscellaneous/scrollbox_elevator.dds", "EsoUI/Art/Miscellaneous/scrollbox_elevator_disabled.dds", nil, 16, 16)
    slider:SetEnabled(true)
    slider:SetMouseEnabled(true)
    
    local closeLockButton = GetOrCreateControl(prefix.."CloseLock", sliderContainer, CT_BUTTON)
    closeLockButton:SetAnchor(RIGHT, sliderContainer, RIGHT, -5, 0)
    closeLockButton:SetDimensions(16, 16)
    closeLockButton:SetNormalTexture(TEXTURE_PATHS.locked.normal)
    closeLockButton:SetPressedTexture(TEXTURE_PATHS.locked.pressed)
    closeLockButton:SetMouseOverTexture(TEXTURE_PATHS.locked.over)

    return sliderContainer, slider, openLockButton, closeLockButton
end

local function CreateStyledEditBox(parent, namePrefix, width)
    local editBackdrop = wm:CreateControlFromVirtual(namePrefix.."Backdrop", parent, "ZO_EditBackdrop")
    editBackdrop:SetDimensions(width, 16)

    local displayLabel = wm:CreateControl(nil, editBackdrop, CT_LABEL)
    displayLabel:SetAnchor(TOPLEFT, editBackdrop, TOPLEFT, 3, 0)
    displayLabel:SetAnchor(BOTTOMRIGHT, editBackdrop, BOTTOMRIGHT, -3, -3)
    displayLabel:SetFont(FONT_SETTINGS)
    displayLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER) 
    displayLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    displayLabel:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
    displayLabel:SetMouseEnabled(true) 

    local editBox = wm:CreateControlFromVirtual(nil, editBackdrop, "ZO_DefaultEditForBackdrop")
    editBox:ClearAnchors()
    editBox:SetAnchor(TOPLEFT, editBackdrop, TOPLEFT, 3, 0)
    editBox:SetAnchor(BOTTOMRIGHT, editBackdrop, BOTTOMRIGHT, -3, -3)
    editBox:SetFont(FONT_SETTINGS)
    editBox:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
    editBox:SetHidden(true) 

    editBox.displayLabel = displayLabel
    editBox.backdrop = editBackdrop 

    displayLabel:SetHandler("OnMouseUp", function()
        displayLabel:SetHidden(true)
        editBox:SetHidden(false)
        editBox:TakeFocus()
    end)

    local originalSetText = editBox.SetText
    function editBox:SetText(text)
        originalSetText(self, text) 
        if displayLabel then displayLabel:SetText(text) end
    end

    local originalSetColor = editBox.SetColor
    function editBox:SetColor(r, g, b, a)
        originalSetColor(self, r, g, b, a)
        if displayLabel then displayLabel:SetColor(r, g, b, a) end
    end
    
    return editBox
end

CreateSettingsWindow = function() 
    if settingsWindow then return settingsWindow end
    
    local base = CreateBaseSettingsWindow("SkillBlocker_NJ_SettingsWindow", 250, 70)
    local sliderContainer, slider, openBtn, closeBtn = CreateSliderComponent(base.container, "Stack")
    
    local tickButtons = {}
    for i = 1, 15 do 
        local btn = GetOrCreateControl("StackTick" .. i, sliderContainer, CT_LABEL)
        btn:SetDimensions(20, 20)
        btn:SetFont(FONT_SLIDER)
        btn:SetColor(0.7, 0.7, 0.7, 1)    
        btn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        btn:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        btn:SetMouseEnabled(true) 
        btn:SetHidden(true) 
        tickButtons[i] = btn
    end
    
    settingsWindow = {
        window = base.window, abilityName = base.abilityName, valueLabel = base.valueLabel,
        sliderContainer = sliderContainer, slider = slider,
        openLockButton = openBtn, closeLockButton = closeBtn,
        tickButtons = tickButtons
    }
    return settingsWindow
end

CreateHpSettingsWindow = function()
    if hpSettingsWindow then return hpSettingsWindow end

    local base = CreateBaseSettingsWindow("SkillBlocker_NJ_HpSettingsWindow", 250, 70)
    
    local controlsContainer = GetOrCreateControl("HpControlsContainer", base.container, CT_CONTROL)
    controlsContainer:SetDimensions(130, 25)
    controlsContainer:SetAnchor(CENTER, base.container, CENTER, 14, 15)
    
    local minusButton = GetOrCreateControl("HpMinusButton", controlsContainer, CT_BUTTON)
    minusButton:SetAnchor(LEFT, controlsContainer, LEFT, 0, 0)
    minusButton:SetDimensions(25, 25)
    minusButton:SetNormalTexture("/esoui/art/buttons/minus_up.dds")
    minusButton:SetPressedTexture("/esoui/art/buttons/minus_down.dds")
    minusButton:SetMouseOverTexture("/esoui/art/buttons/minus_over.dds")
    
    local editBox = CreateStyledEditBox(controlsContainer, "HpEdit", 44)
    editBox.backdrop:SetAnchor(LEFT, minusButton, RIGHT, 5, 0)

    local plusButton = GetOrCreateControl("HpPlusButton", controlsContainer, CT_BUTTON)
    plusButton:SetAnchor(LEFT, editBox.backdrop, RIGHT, 5, 0)
    plusButton:SetDimensions(25, 25)
    plusButton:SetNormalTexture("/esoui/art/buttons/plus_up.dds")
    plusButton:SetPressedTexture("/esoui/art/buttons/plus_down.dds")
    plusButton:SetMouseOverTexture("/esoui/art/buttons/plus_over.dds")
    
    local lockButton = GetOrCreateControl("HpLockButton", controlsContainer, CT_BUTTON)
    lockButton:SetAnchor(LEFT, plusButton, RIGHT, 10, 0)
    lockButton:SetDimensions(16, 16)
    lockButton:SetNormalTexture(TEXTURE_PATHS.unlocked.normal)
    lockButton:SetPressedTexture(TEXTURE_PATHS.unlocked.pressed)
    lockButton:SetMouseOverTexture(TEXTURE_PATHS.unlocked.over)
    
    hpSettingsWindow = {
        window = base.window, abilityName = base.abilityName, valueLabel = base.valueLabel,
        editBox = editBox,
        minusButton = minusButton, plusButton = plusButton, lockButton = lockButton
    }
    return hpSettingsWindow
end

CreateUltimateSettingsWindow = function()
    if ultSettingsWindow then return ultSettingsWindow end

    local base = CreateBaseSettingsWindow("SkillBlocker_NJ_UltSettingsWindow", 250, 70)
    local sliderContainer, slider, openBtn, closeBtn = CreateSliderComponent(base.container, "Ult")

    local editBox = CreateStyledEditBox(sliderContainer, "UltEdit", 44)
    editBox.backdrop:SetAnchor(TOP, slider, BOTTOM, 2, 5)

    ultSettingsWindow = {
        window = base.window, abilityName = base.abilityName, valueLabel = base.valueLabel,
        sliderContainer = sliderContainer, slider = slider,
        openLockButton = openBtn, closeLockButton = closeBtn,
        editBox = editBox 
    }
    return ultSettingsWindow
end

CreateDotHotSettingsWindow = function()
    if dotHotSettingsWindow then return dotHotSettingsWindow end

    local base = CreateBaseSettingsWindow("SkillBlocker_NJ_DotHotSettingsWindow", 250, 70)
    local sliderContainer, slider, openBtn, closeBtn = CreateSliderComponent(base.container, "DotHot")

    local editBox = CreateStyledEditBox(sliderContainer, "DotHotEdit", 44)
    editBox.backdrop:SetAnchor(TOP, slider, BOTTOM, 2, 5)

    dotHotSettingsWindow = {
        window = base.window, abilityName = base.abilityName, valueLabel = base.valueLabel,
        sliderContainer = sliderContainer, slider = slider,
        openLockButton = openBtn, closeLockButton = closeBtn,
        editBox = editBox 
    }
    return dotHotSettingsWindow
end

CreateDebuffSettingsWindow = function()
    if debuffSettingsWindow then return debuffSettingsWindow end

    local base = CreateBaseSettingsWindow("SkillBlocker_NJ_DebuffSettingsWindow", 250, 70)
    local sliderContainer, slider, openBtn, closeBtn = CreateSliderComponent(base.container, "Debuff")
    
    local tickButtons = {}
    for i = 1, 5 do
        local btn = GetOrCreateControl("DebuffTick" .. i, sliderContainer, CT_LABEL)
        btn:SetDimensions(20, 20)
        btn:SetFont(FONT_SLIDER)
        btn:SetColor(0.7, 0.7, 0.7, 1)    
        btn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        btn:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        btn:SetMouseEnabled(true) 
        btn:SetHidden(true) 
        tickButtons[i] = btn
    end
    
    debuffSettingsWindow = {
        window = base.window, abilityName = base.abilityName, valueLabel = base.valueLabel,
        sliderContainer = sliderContainer, slider = slider,
        openLockButton = openBtn, closeLockButton = closeBtn,
        tickButtons = tickButtons
    }
    return debuffSettingsWindow
end

ShowSettingsWindow = function(abilityId, slotNum)
    local config = STACK_ABILITY_CONFIG[abilityId]
    if not config then return end
    HideAllSettingsWindows()
    local window = CreateSettingsWindow()
    if not window then return end
    
    currentSettingsAbilityId = abilityId
    currentSettingsSlotNum = slotNum
    local settingsTable = GetSettingsTable("stackAbilitySettings")
    local currentSetting = settingsTable[abilityId] or 0
    local sliderSteps = config.maxStack - config.minThreshold + 3
    window.slider:SetMinMax(0, sliderSteps - 1)
    window.slider:SetValueStep(1)
    
    window.slider:SetHandler("OnValueChanged", nil)
    window.slider:SetValue(settingToSliderValue(currentSetting, config))
    
    local function updateDisplay()
        local sliderValue = zo_round(window.slider:GetValue())
        local settingValue = sliderValueToSetting(sliderValue, config)
        local displayValue
        
        if settingValue == 0 then 
            displayValue = "|c00FF00" .. GetString(SKILLBLOCKER_NJ_UNLOCKED) .. "|r"  
            window.valueLabel:SetColor(0, 1, 0, 1)  
        elseif settingValue > config.maxStack then 
            displayValue = "|cFF0000" .. GetString(SKILLBLOCKER_NJ_LOCKED) .. "|r"   
            window.valueLabel:SetColor(1, 0, 0, 1)  
        else
            if config.mode == "stage" then
                displayValue = zo_strformat(GetString(SKILLBLOCKER_NJ_BLOCK_PROC), settingValue)
            elseif config.mode == "reverse" then
                displayValue = GetString(SKILLBLOCKER_NJ_BLOCK_REVERSE) .. " " .. tostring(settingValue)
            else
                local prefix = IS_CRUX_ABILITY[abilityId] and GetString(SKILLBLOCKER_NJ_BLOCK_CRUX) or GetString(SKILLBLOCKER_NJ_BLOCK_STACKS)
                displayValue = prefix .. " " .. tostring(settingValue)
            end
            
            window.valueLabel:SetColor(1, 1, 1, 1)  
        end
        window.valueLabel:SetText(displayValue)
        
        if settingsTable[abilityId] ~= settingValue then
            currentSetting = settingValue
            settingsTable[abilityId] = currentSetting
            
            local mainTable = settings.stackAbilitySettings.mainBar
            local offTable = settings.stackAbilitySettings.offBar
            local mainVal = mainTable[abilityId] or 0
            local offVal = offTable[abilityId] or 0
            
            local shouldBlock = (mainVal > 0 or offVal > 0)
            UpdateLockStatus(abilityId, shouldBlock, nil)
            
            ForceLogicUpdate()
        end
    end

    if window.tickButtons then
        for _, btn in pairs(window.tickButtons) do btn:SetHidden(true) end
        local sliderWidth = 150
        local thumbWidth = 16 
        local maxStepIndex = sliderSteps - 1
        local usableWidth = sliderWidth - thumbWidth
        local startOffset = thumbWidth / 2
        
        for i = 1, maxStepIndex - 1 do
            local btn = window.tickButtons[i]
            if btn then 
                btn:SetHidden(false)
                btn:ClearAnchors()
                local percent = i / maxStepIndex
                local xOffset = startOffset + (percent * usableWidth)
                btn:SetAnchor(TOP, window.slider, BOTTOMLEFT, xOffset, 3)
                
                local stackVal = sliderValueToSetting(i, config)
                btn:SetText(tostring(stackVal))
                
                btn:SetHandler("OnMouseEnter", function(self) self:SetColor(1, 1, 1, 1) end)
                btn:SetHandler("OnMouseExit", function(self) self:SetColor(0.7, 0.7, 0.7, 1) end)
                
                btn:SetHandler("OnMouseUp", function(_, _, upInside)
                    if upInside then
                        window.slider:SetValue(i)
                        PlaySound(SOUNDS_SLIDER_VALUE_CHANGED)
                    end
                end)
            end
        end
    end
    
    window.slider:SetHandler("OnValueChanged", function(c, v) 
        updateDisplay()
    end)
    
    window.slider:SetHandler("OnSliderReleased", function(control)
        local value = control:GetValue()
        local discreteValue = zo_round(value)
        control:SetValue(discreteValue)
        updateDisplay()
        PlaySound(SOUNDS_SLIDER_VALUE_CHANGED)
    end)
    
    window.openLockButton:SetHandler("OnClicked", function() window.slider:SetValue(0) end)
    window.closeLockButton:SetHandler("OnClicked", function() window.slider:SetValue(sliderSteps - 1) end)
    
    window.abilityName:SetText(zo_strformat("<<C:1>>", GetAbilityName(abilityId)))
    updateDisplay()
    
    local lockIndex = currentSettingsSlotNum - 2
    if lockIndex >= 1 and lockIndex <= 6 and SB_NJ.lock[lockIndex] then
        window.window:ClearAnchors()
        window.window:SetAnchor(BOTTOM, SB_NJ.lock[lockIndex], TOP, 0, 0)
    else
        window.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
    window.window:SetHidden(false)
    PlaySound(SOUNDS_WINDOW_OPEN)
end

ShowHpSettingsWindow = function(abilityId, slotNum)
    local config = TARGET_HP_ABILITY_CONFIG[abilityId]
    if not config then return end
    HideAllSettingsWindows()
    
    UpdateTargetHealth()
    
    local window = CreateHpSettingsWindow()
    currentSettingsAbilityId = abilityId
    currentSettingsSlotNum = slotNum
    
    local settingsTable = GetSettingsTable("targetHpAbilitySettings")
    local currentHpValue = settingsTable[abilityId] or 100
    
    local function updateDisplay()
        settingsTable[abilityId] = currentHpValue
    
        local mainTable = settings.targetHpAbilitySettings.mainBar
        local offTable = settings.targetHpAbilitySettings.offBar
        local mainVal = mainTable[abilityId] or 100
        local offVal = offTable[abilityId] or 100

        local shouldBlock = (mainVal < 100 or offVal < 100)
        UpdateLockStatus(abilityId, shouldBlock, nil)
        
        ForceLogicUpdate()

        if not window.editBox:HasFocus() then
            if currentHpValue == 0 then
                window.editBox:SetText("Lock")
                window.editBox.displayLabel:SetText("|cFF0000Lock|r")
                window.editBox:SetColor(1, 0, 0, 1)
                
                window.valueLabel:SetText("|cFF0000" .. GetString(SKILLBLOCKER_NJ_LOCKED) .. "|r")
                window.lockButton:SetNormalTexture(TEXTURE_PATHS.locked.normal)
                window.lockButton:SetPressedTexture(TEXTURE_PATHS.locked.pressed)
                window.lockButton:SetMouseOverTexture(TEXTURE_PATHS.locked.over)
            elseif currentHpValue == 100 then
                window.editBox:SetText("Unlock")
                window.editBox.displayLabel:SetText("|c00FF00Unlock|r")
                window.editBox:SetColor(0, 1, 0, 1)

                window.valueLabel:SetText("|c00FF00" .. GetString(SKILLBLOCKER_NJ_UNLOCKED) .. "|r")
                window.lockButton:SetNormalTexture(TEXTURE_PATHS.unlocked.normal)
                window.lockButton:SetPressedTexture(TEXTURE_PATHS.unlocked.pressed)
                window.lockButton:SetMouseOverTexture(TEXTURE_PATHS.unlocked.over)
            else
                window.editBox:SetText(tostring(currentHpValue))
                window.editBox.displayLabel:SetText(tostring(currentHpValue) .. "%")
                window.editBox:SetColor(1, 1, 1, 1)

                window.valueLabel:SetText(zo_strformat(GetString(SKILLBLOCKER_NJ_BLOCK_HP) .. " <<1>>%", currentHpValue))
                window.lockButton:SetNormalTexture(TEXTURE_PATHS.settings.normal)
                window.lockButton:SetPressedTexture(TEXTURE_PATHS.settings.pressed)
                window.lockButton:SetMouseOverTexture(TEXTURE_PATHS.settings.over)
            end
        end
    end
    
    window.editBox:SetHandler("OnTextChanged", function(self)
        local input = self:GetText()
        if input == "Lock" or input == "Unlock" then return end
        if input ~= "" and not input:match("^[0-9]+$") then return end

        local val = tonumber(input)
        if val then
            val = math.max(math.min(val, 100), 0)
            if currentHpValue ~= val then
                currentHpValue = val
                updateDisplay()
            end
        end
    end)
    
    window.editBox:SetHandler("OnFocusGained", function(self)
        local input = self:GetText()
        if input == "Unlock" then self:SetText("100")
        elseif input == "Lock" then self:SetText("0") end
        
        self:SetColor(1, 1, 1, 1)
        self:SelectAll()

        if self.displayLabel then self.displayLabel:SetHidden(true) end
        self:SetHidden(false)
    end)
    
    window.editBox:SetHandler("OnFocusLost", function(self)
        local text = self:GetText()
        if text == "" then currentHpValue = 100 end
        self:LoseFocus()
        updateDisplay() 
        if self.displayLabel then self.displayLabel:SetHidden(false) end
        self:SetHidden(true)
    end)
    
    window.editBox:SetHandler("OnEnter", function(self) self:LoseFocus() end)
    window.editBox:SetHandler("OnEscape", function(self)
        self:SetText(tostring(currentHpValue))
        self:LoseFocus()
    end)

    window.minusButton:SetHandler("OnClicked", function()
        if currentHpValue > 1 then currentHpValue = currentHpValue - 1 elseif currentHpValue == 100 then currentHpValue = 99 elseif currentHpValue == 1 then currentHpValue = 0 end
        if window.editBox:HasFocus() then window.editBox:LoseFocus() end
        updateDisplay()
    end)
    window.plusButton:SetHandler("OnClicked", function()
        if currentHpValue < 99 and currentHpValue > 0 then currentHpValue = currentHpValue + 1 elseif currentHpValue == 0 then currentHpValue = 1 elseif currentHpValue == 99 then currentHpValue = 100 end
        if window.editBox:HasFocus() then window.editBox:LoseFocus() end
        updateDisplay()
    end)
    window.lockButton:SetHandler("OnClicked", function()
        if currentHpValue == 100 then currentHpValue = TARGET_HP_DEFAULT_VALUES[abilityId] or 50
        elseif currentHpValue == 0 then currentHpValue = 100
        else currentHpValue = 0 end
        if window.editBox:HasFocus() then window.editBox:LoseFocus() end
        updateDisplay()
    end)
    
    window.abilityName:SetText(zo_strformat("<<C:1>>", GetAbilityName(abilityId)))
    updateDisplay()
    
    local lockIndex = currentSettingsSlotNum - 2
    if lockIndex >= 1 and lockIndex <= 6 and SB_NJ.lock[lockIndex] then
        window.window:ClearAnchors()
        window.window:SetAnchor(BOTTOM, SB_NJ.lock[lockIndex], TOP, 0, 0)
    else
        window.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
    window.window:SetHidden(false)
    PlaySound(SOUNDS_WINDOW_OPEN)
end

ShowUltimateSettingsWindow = function(abilityId, slotNum)
    HideAllSettingsWindows()
    local window = CreateUltimateSettingsWindow()
    if not window then return end
    
    currentSettingsAbilityId = abilityId
    currentSettingsSlotNum = slotNum
    
    local settingsTable = GetSettingsTable("ultimateAbilitySettings")
    local currentSetting = settingsTable[abilityId] or 0
    local minVal, maxVal = 0, 501
    
    window.slider:SetMinMax(minVal, maxVal)
    window.slider:SetValueStep(1)
    window.slider:SetHandler("OnValueChanged", nil) 
    window.slider:SetValue(currentSetting)
    
    local function updateDisplay()
        local sliderValue = zo_round(window.slider:GetValue())
        
        if not window.editBox:HasFocus() then
            if sliderValue == 0 then
                window.editBox:SetText("Unlock")
                window.editBox:SetColor(0, 1, 0, 1) 
            elseif sliderValue >= 501 then
                window.editBox:SetText("Lock") 
                window.editBox:SetColor(1, 0, 0, 1) 
            else
                window.editBox:SetText(tostring(sliderValue))
                window.editBox:SetColor(1, 1, 1, 1) 
            end
        end
        
        local displayValue
        if sliderValue == 0 then 
            displayValue = "|c00FF00" .. GetString(SKILLBLOCKER_NJ_UNLOCKED) .. "|r"  
            window.valueLabel:SetColor(0, 1, 0, 1)  
        elseif sliderValue >= 501 then 
            displayValue = "|cFF0000" .. GetString(SKILLBLOCKER_NJ_LOCKED) .. "|r"   
            window.valueLabel:SetColor(1, 0, 0, 1)  
        else
            displayValue = zo_strformat(GetString(SKILLBLOCKER_NJ_BLOCK_ULTIMATE), sliderValue)
            window.valueLabel:SetColor(1, 1, 1, 1)  
        end
        window.valueLabel:SetText(displayValue)
        
        if settingsTable[abilityId] ~= sliderValue then
            settingsTable[abilityId] = sliderValue
            local mainTable = settings.ultimateAbilitySettings.mainBar
            local offTable = settings.ultimateAbilitySettings.offBar
            local shouldBlock = ((mainTable[abilityId] or 0) > 0 or (offTable[abilityId] or 0) > 0)
            UpdateLockStatus(abilityId, shouldBlock, nil)
            
            ForceLogicUpdate()
        end
    end
    
    window.slider:SetHandler("OnValueChanged", function() updateDisplay() end)
    window.slider:SetHandler("OnSliderReleased", function(control)
        control:SetValue(zo_round(control:GetValue()))
        updateDisplay()
        PlaySound(SOUNDS_SLIDER_VALUE_CHANGED)
    end)
    
    window.editBox:SetHandler("OnTextChanged", function(self)
        local input = self:GetText()
        if input == "Lock" or input == "Unlock" then return end
        if input ~= "" and not input:match("^[0-9]+$") then return end

        local val = tonumber(input)
        if val then
            val = math.max(math.min(val, 500), minVal)
            window.slider:SetValue(val) 
            updateDisplay()
        end
    end)
    
    window.editBox:SetHandler("OnFocusGained", function(self)
        local input = self:GetText()
        if input == "Unlock" then self:SetText("0")
        elseif input == "Lock" then self:SetText("500") end
        
        self:SetColor(1, 1, 1, 1)
        self:SelectAll()
        if self.displayLabel then self.displayLabel:SetHidden(true) end
        self:SetHidden(false)
    end)
    
    window.editBox:SetHandler("OnFocusLost", function(self)
        local text = self:GetText()
        if text == "" then window.slider:SetValue(0) end
        updateDisplay() 
        if self.displayLabel then self.displayLabel:SetHidden(false) end
        self:SetHidden(true)
    end)
    
    window.editBox:SetHandler("OnEnter", function(self) self:LoseFocus() end)
    window.editBox:SetHandler("OnEscape", function(self)
        local val = zo_round(window.slider:GetValue())
        if val > 500 then val = 500 end
        self:SetText(tostring(val))
        self:LoseFocus()
    end)
    
    window.openLockButton:SetHandler("OnClicked", function() window.slider:SetValue(0); updateDisplay() end)
    window.closeLockButton:SetHandler("OnClicked", function() window.slider:SetValue(501); updateDisplay() end)
    
    window.abilityName:SetText(zo_strformat("<<C:1>>", GetAbilityName(abilityId)))
    updateDisplay()
    
    local lockIndex = currentSettingsSlotNum - 2
    if lockIndex >= 1 and lockIndex <= 6 and SB_NJ.lock[lockIndex] then
        window.window:ClearAnchors()
        window.window:SetAnchor(BOTTOM, SB_NJ.lock[lockIndex], TOP, 0, 0)
    else
        window.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
    window.window:SetHidden(false)
    PlaySound(SOUNDS_WINDOW_OPEN)
end

ShowDotHotSettingsWindow = function(abilityId, slotNum)
    local config = DOT_HOT_CONFIG[abilityId]
    local scribingConfig = SCRIBING_DOT_HOT[abilityId]
    
    if not config and not scribingConfig then return end
    
    HideAllSettingsWindows()
    
    local window = CreateDotHotSettingsWindow()
    if not window then return end
    
    currentSettingsAbilityId = abilityId
    currentSettingsSlotNum = slotNum
    
    local settingsTable = GetSettingsTable("dotHotSettings")
    local currentSetting = settingsTable[abilityId] or 0
    
    local maxDuration = GetDotHotDuration(abilityId, slotNum)
    
    if maxDuration <= 0 then maxDuration = 1 end

    local lockValue = maxDuration + 0.1
    local minVal = 0
    
    window.slider:SetMinMax(minVal, lockValue)
    window.slider:SetValueStep(0.1)
    window.slider:SetHandler("OnValueChanged", nil) 
    window.slider:SetValue(currentSetting)
    
    local function updateDisplay()
        local sliderValue = round_decimal(window.slider:GetValue())
        
        if not window.editBox:HasFocus() then
            if sliderValue == 0 then
                window.editBox:SetText("Unlock")
                window.editBox:SetColor(0, 1, 0, 1) 
            elseif sliderValue >= lockValue then
                window.editBox:SetText("Lock")
                window.editBox:SetColor(1, 0, 0, 1) 
            else
                window.editBox:SetText(string.format("%.1f", sliderValue))
                window.editBox:SetColor(1, 1, 1, 1) 
            end
        end
        
        local displayValue
        if sliderValue == 0 then 
            displayValue = "|c00FF00" .. GetString(SKILLBLOCKER_NJ_UNLOCKED) .. "|r"  
            window.valueLabel:SetColor(0, 1, 0, 1)  
        elseif sliderValue >= lockValue then 
            displayValue = "|cFF0000" .. GetString(SKILLBLOCKER_NJ_LOCKED) .. "|r"   
            window.valueLabel:SetColor(1, 0, 0, 1)  
        else
            displayValue = zo_strformat(GetString(SKILLBLOCKER_NJ_BLOCK_DURATION), string.format("%.1f", sliderValue))
            window.valueLabel:SetColor(1, 1, 1, 1)  
        end
        window.valueLabel:SetText(displayValue)
        if math.abs((settingsTable[abilityId] or 0) - sliderValue) > 0.01 then
            settingsTable[abilityId] = sliderValue
            local mainTable = settings.dotHotSettings.mainBar
            local offTable = settings.dotHotSettings.offBar
            local shouldBlock = ((mainTable[abilityId] or 0) > 0 or (offTable[abilityId] or 0) > 0)
            UpdateLockStatus(abilityId, shouldBlock, nil)
            
            ForceLogicUpdate()
        end
    end
    
    window.slider:SetHandler("OnValueChanged", function() updateDisplay() end)
    window.slider:SetHandler("OnSliderReleased", function(control)
        control:SetValue(round_decimal(control:GetValue()))
        updateDisplay()
        PlaySound(SOUNDS_SLIDER_VALUE_CHANGED)
    end)
    
    window.editBox:SetHandler("OnTextChanged", function(self)
        local input = self:GetText()
        if input == "Lock" or input == "Unlock" then return end
        
        if input ~= "" and not input:match("^[0-9]*%.?[0-9]*$") then return end

        local val = tonumber(input)
        if val then
            val = math.max(math.min(val, maxDuration), minVal)
            window.slider:SetValue(val) 
            updateDisplay()
        end
    end)
    
    window.editBox:SetHandler("OnFocusGained", function(self)
        local input = self:GetText()
        if input == "Unlock" then self:SetText("0")
        elseif input == "Lock" then self:SetText(tostring(maxDuration)) end
        
        self:SetColor(1, 1, 1, 1)
        self:SelectAll()
        if self.displayLabel then self.displayLabel:SetHidden(true) end
        self:SetHidden(false)
    end)
    
    window.editBox:SetHandler("OnFocusLost", function(self)
        local text = self:GetText()
        if text == "" then window.slider:SetValue(0) end
        updateDisplay() 
        if self.displayLabel then self.displayLabel:SetHidden(false) end
        self:SetHidden(true)
    end)
    
    window.editBox:SetHandler("OnEnter", function(self) self:LoseFocus() end)
    window.editBox:SetHandler("OnEscape", function(self)
        local val = round_decimal(window.slider:GetValue())
        if val > maxDuration then val = maxDuration end
        self:SetText(tostring(val))
        self:LoseFocus()
    end)
    
    window.openLockButton:SetHandler("OnClicked", function() window.slider:SetValue(0); updateDisplay() end)
    window.closeLockButton:SetHandler("OnClicked", function() window.slider:SetValue(lockValue); updateDisplay() end)
    
    window.abilityName:SetText(zo_strformat("<<C:1>>", GetAbilityName(abilityId)))
    updateDisplay()
    
    local lockIndex = currentSettingsSlotNum - 2
    if lockIndex >= 1 and lockIndex <= 6 and SB_NJ.lock[lockIndex] then
        window.window:ClearAnchors()
        window.window:SetAnchor(BOTTOM, SB_NJ.lock[lockIndex], TOP, 0, 0)
    else
        window.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
    window.window:SetHidden(false)
    PlaySound(SOUNDS_WINDOW_OPEN)
end

ShowDebuffSettingsWindow = function(abilityId, slotNum)
    local config = DEBUFF_ABILITY_CONFIG[abilityId]
    if not config then return end
    HideAllSettingsWindows()
    
    local window = CreateDebuffSettingsWindow()
    if not window then return end
    
    currentSettingsAbilityId = abilityId
    currentSettingsSlotNum = slotNum
    
    local settingsTable = GetSettingsTable("debuffAbilitySettings")
    local currentSetting = settingsTable[abilityId] or 0
    local sliderSteps = config.maxStages + 2
    
    window.slider:SetMinMax(0, sliderSteps - 1)
    window.slider:SetValueStep(1)
    window.slider:SetHandler("OnValueChanged", nil)
    window.slider:SetValue(currentSetting)
    
    local function updateDisplay()
        local sliderValue = zo_round(window.slider:GetValue())
    
        if sliderValue == 0 then
            for debuffId, _ in pairs(config.debuffIds) do
                activeDebuffs[debuffId] = 0
            end
        end
        
        local displayValue
        if sliderValue == 0 then 
            displayValue = "|c00FF00" .. GetString(SKILLBLOCKER_NJ_UNLOCKED) .. "|r"  
            window.valueLabel:SetColor(0, 1, 0, 1)  
        elseif sliderValue > config.maxStages then 
            displayValue = "|cFF0000" .. GetString(SKILLBLOCKER_NJ_LOCKED) .. "|r"   
            window.valueLabel:SetColor(1, 0, 0, 1)  
        else
            displayValue = zo_strformat(GetString(SKILLBLOCKER_NJ_BLOCK_DEBUFF), sliderValue)
            window.valueLabel:SetColor(1, 1, 1, 1)  
        end
        window.valueLabel:SetText(displayValue)
        
        if settingsTable[abilityId] ~= sliderValue then
            settingsTable[abilityId] = sliderValue
            local mainTable = settings.debuffAbilitySettings.mainBar
            local offTable = settings.debuffAbilitySettings.offBar
            local shouldBlock = ((mainTable[abilityId] or 0) > 0 or (offTable[abilityId] or 0) > 0)
            UpdateLockStatus(abilityId, shouldBlock, nil)
            ForceLogicUpdate()
        end
    end

    if window.tickButtons then
        for _, btn in pairs(window.tickButtons) do btn:SetHidden(true) end
        local sliderWidth = 150
        local thumbWidth = 16 
        local maxStepIndex = sliderSteps - 1
        local usableWidth = sliderWidth - thumbWidth
        local startOffset = thumbWidth / 2
        
        for i = 1, maxStepIndex - 1 do
            local btn = window.tickButtons[i]
            if btn then 
                btn:SetHidden(false)
                btn:ClearAnchors()
                local percent = i / maxStepIndex
                local xOffset = startOffset + (percent * usableWidth)
                btn:SetAnchor(TOP, window.slider, BOTTOMLEFT, xOffset, 3)
                
                btn:SetText(tostring(i))
                btn:SetHandler("OnMouseEnter", function(self) self:SetColor(1, 1, 1, 1) end)
                btn:SetHandler("OnMouseExit", function(self) self:SetColor(0.7, 0.7, 0.7, 1) end)
                btn:SetHandler("OnMouseUp", function(_, _, upInside)
                    if upInside then
                        window.slider:SetValue(i)
                        PlaySound(SOUNDS_SLIDER_VALUE_CHANGED)
                    end
                end)
            end
        end
    end
    
    window.slider:SetHandler("OnValueChanged", function() updateDisplay() end)
    window.slider:SetHandler("OnSliderReleased", function(control)
        control:SetValue(zo_round(control:GetValue()))
        updateDisplay()
        PlaySound(SOUNDS_SLIDER_VALUE_CHANGED)
    end)
    
    window.openLockButton:SetHandler("OnClicked", function() window.slider:SetValue(0) end)
    window.closeLockButton:SetHandler("OnClicked", function() window.slider:SetValue(sliderSteps - 1) end)
    
    window.abilityName:SetText(zo_strformat("<<C:1>>", GetAbilityName(abilityId)))
    updateDisplay()
    
    local lockIndex = currentSettingsSlotNum - 2
    if lockIndex >= 1 and lockIndex <= 6 and SB_NJ.lock[lockIndex] then
        window.window:ClearAnchors()
        window.window:SetAnchor(BOTTOM, SB_NJ.lock[lockIndex], TOP, 0, 0)
    else
        window.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
    window.window:SetHidden(false)
    PlaySound(SOUNDS_WINDOW_OPEN)
end

-------------------------------------------------------------------------------
----------------------------[      UI Update      ]----------------------------
-------------------------------------------------------------------------------

local function OnLockMouseEnter(self)
    if self.tooltipText then
        InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 0)
        SetTooltipText(InformationTooltip, self.tooltipText)
    end
end

local function OnLockMouseExit()
    ClearTooltip(InformationTooltip)
end

drawLocks = function()
    local hotbar = currentHotbar
    local locks = SB_NJ.lock

    if not SM:IsShowing("skills") or not ALLOWED_HOTBARS[hotbar] then
        for i = 1, 6 do
            locks[i]:SetHidden(true)
            local button = _G["ZO_SkillsAssignableActionBarButton"..i]
            if button and button.criminalOverlay then 
                button.criminalOverlay:SetHidden(true) 
            end
        end
        SB_NJ.unlockAllButton:SetHidden(true)
        return
    end
    
    for i = 1, 6 do
        local slotNum = i + 2
        local abilityId = GetSlotBoundAbilityIdSafe(slotNum)
        local lock = locks[i]
        
        local button = _G["ZO_SkillsAssignableActionBarButton"..i]
        local crimOverlay = button and button.criminalOverlay
        
        if not abilityId or abilityId == 0 then
            lock:SetHidden(true)
            if crimOverlay then crimOverlay:SetHidden(true) end
        else
            lock:SetHidden(false)

            local handler = GetHandler(abilityId, slotNum)
            
            if handler then
                local iconType, state = handler.getIcon(abilityId)
                local normalTex, pressedTex, overTex = GetLockTextures(iconType, state)
                lock:SetNormalTexture(normalTex)
                lock:SetPressedTexture(pressedTex)
                lock:SetMouseOverTexture(overTex)
                
                lock.tooltipText = handler.getTooltip(abilityId)
            else
                lock:SetNormalTexture(TEXTURE_PATHS.unlocked.normal)
                lock:SetPressedTexture(TEXTURE_PATHS.unlocked.pressed)
                lock:SetMouseOverTexture(TEXTURE_PATHS.unlocked.over)
                
                lock.tooltipText = GetString(SKILLBLOCKER_NJ_UNLOCKED)
            end
            
            lock:SetHandler("OnMouseEnter", OnLockMouseEnter)
            lock:SetHandler("OnMouseExit", OnLockMouseExit)

            if crimOverlay then
                local isCriminal = false
                
                if Handlers.Criminal.matches(abilityId) then
                    if Handlers.Criminal.shouldBlock(abilityId) then
                        isCriminal = true
                    end
                end
                
                crimOverlay:SetHidden(not isCriminal)
            end
        end
    end
    SB_NJ.unlockAllButton:SetHidden(false)
end

local function toggleLock(lock)
    local slotNum = lock.index + 2
    local abilityId = GetSlotBoundAbilityIdSafe(slotNum)
    if not abilityId or abilityId == 0 then return end
    
    local handler = GetHandler(abilityId, slotNum)
    if handler then
        local needRedraw = handler.toggle(abilityId, slotNum)
        EventBus:FireCallbacks(EVENTS.LOGIC_UPDATE) 
        EventBus:FireCallbacks(EVENTS.UI_UPDATE)
    end
end

-------------------------------------------------------------------------------
----------------------------[    Events / Init    ]----------------------------
-------------------------------------------------------------------------------

local function ImmediateUpdate()
    EventBus:FireCallbacks(EVENTS.LOGIC_UPDATE)
    EventBus:FireCallbacks(EVENTS.UI_UPDATE)
end

local function OnSlotUpdated(eventCode, slotNum)
    if slotNum < 3 or slotNum > 8 then return end
    ImmediateUpdate()
end

local function OnActiveWeaponPairChanged()
    currentHotbar = GetActiveHotbarCategory()
    ClearMenu()
    zo_callLater(ImmediateUpdate, 150)
end

local function OnAbilityUsed(eventCode, slotNum)
    if slotNum == 1 then
        if settings.resetDoubleCastOnLA then
            lastUsedAbilityId = 0
            EventBus:FireCallbacks(EVENTS.LOGIC_UPDATE)
            EventBus:FireCallbacks(EVENTS.UI_UPDATE)
        end    
        return
    end

    if slotNum < 3 or slotNum > 8 then return end
    
    local abilityId = GetSlotBoundAbilityIdSafe(slotNum)
    if abilityId and abilityId > 0 then
        lastUsedAbilityId = abilityId
        EventBus:FireCallbacks(EVENTS.LOGIC_UPDATE)
        EventBus:FireCallbacks(EVENTS.UI_UPDATE)

        local duration = settings.doubleCastBlockDuration or 0
        if duration > 0 then
            zo_callLater(function()
                if lastUsedAbilityId == abilityId then
                    lastUsedAbilityId = 0
                    EventBus:FireCallbacks(EVENTS.LOGIC_UPDATE)
                    EventBus:FireCallbacks(EVENTS.UI_UPDATE)
                end
            end, duration * 1000) 
        end
    end
end

local function UI_OnSkillsUpdated() EventBus:FireCallbacks(EVENTS.UI_UPDATE) end
local function UI_OnAbilityUpdated() EventBus:FireCallbacks(EVENTS.UI_UPDATE) end
local function UI_OnActionSlotStateUpdated(_, slotNum, hotbarCategory) 
    if hotbarCategory and hotbarCategory ~= currentHotbar then return end
    if slotNum >= 3 and slotNum <= 8 then EventBus:FireCallbacks(EVENTS.UI_UPDATE) end 
end
local function UI_OnCraftingStationInteract() EventBus:FireCallbacks(EVENTS.UI_UPDATE) end

local function OnSkillsSceneStateChange(oldState, newState)
    if newState == SCENE_SHOWING then
        currentHotbar = GetActiveHotbarCategory()
        isPlayerInCombat = IsUnitInCombat("player")
        
        ImmediateUpdate()
        
        if not uiEventsRegistered then
            EM:RegisterForEvent(ADDON_NAME .. "_UI", EVENT_SKILLS_FULL_UPDATE, UI_OnSkillsUpdated)
            EM:RegisterForEvent(ADDON_NAME .. "_UI", EVENT_ABILITY_LIST_CHANGED, UI_OnAbilityUpdated)
            EM:RegisterForEvent(ADDON_NAME .. "_UI", EVENT_HOTBAR_SLOT_STATE_UPDATED, UI_OnActionSlotStateUpdated)
            EM:RegisterForEvent(ADDON_NAME .. "_UI", EVENT_CRAFTING_STATION_INTERACT, UI_OnCraftingStationInteract)
            uiEventsRegistered = true
        end
        
        drawLocks()
        
    elseif newState == SCENE_HIDING then
        HideAllSettingsWindows()
        
        if uiEventsRegistered then
            EM:UnregisterForEvent(ADDON_NAME .. "_UI", EVENT_SKILLS_FULL_UPDATE)
            EM:UnregisterForEvent(ADDON_NAME .. "_UI", EVENT_ABILITY_LIST_CHANGED)
            EM:UnregisterForEvent(ADDON_NAME .. "_UI", EVENT_HOTBAR_SLOT_STATE_UPDATED)
            EM:UnregisterForEvent(ADDON_NAME .. "_UI", EVENT_CRAFTING_STATION_INTERACT)
            uiEventsRegistered = false
        end
    end
end

local function loadLocks()
    for i = 1, 6 do
        local lockName = string.format("SkillBlocker_NJ_lock%d", i)
        local lock = wm:GetControlByName(lockName)
        if not lock then
             lock = wm:CreateControl(lockName, ZO_SkillsAssignableActionBar, CT_BUTTON)
        end
        lock.index = i
        lock:SetDimensions(16, 16)
        lock:SetNormalTexture(TEXTURE_PATHS.unlocked.normal)
        lock:SetHandler("OnClicked", toggleLock)
        lock:SetAnchor(BOTTOM, _G["ZO_SkillsAssignableActionBarButton"..i], TOP, 0, -7)
        SB_NJ.lock[i] = lock

        local button = _G["ZO_SkillsAssignableActionBarButton"..i]
        
        local overlayName = "SB_NJ_CriminalOverlay_" .. i
        local overlay = wm:GetControlByName(overlayName)
        
        if not overlay then
            overlay = wm:CreateControl(overlayName, ZO_SkillsAssignableActionBar, CT_CONTROL)
        end

        if button then
            overlay:ClearAnchors()
            overlay:SetAnchorFill(button)
            overlay:SetDrawLayer(DL_OVERLAY) 
            overlay:SetDrawLevel(10)
            overlay:SetHidden(true) 

            local bg = overlay:GetNamedChild("BG")
            if not bg then
                bg = wm:CreateControl(overlayName .. "BG", overlay, CT_TEXTURE)
            end
            bg:SetAnchorFill()
            bg:SetTexture("/esoui/art/actionbar/abilityinset.dds")
            bg:SetColor(0, 0, 0, 0.9)
            bg:SetDrawLevel(1)

            local icon = overlay:GetNamedChild("Icon")
            if not icon then
                icon = wm:CreateControl(overlayName .. "Icon", overlay, CT_TEXTURE)
            end
            icon:SetDimensions(32, 32)
            icon:SetAnchor(CENTER, overlay, CENTER, 0, 0)
            icon:SetTexture("/esoui/art/progression/lock.dds")
            icon:SetDrawLevel(2)

            button.criminalOverlay = overlay
        end
    end
    
    local unlockAllButton = wm:GetControlByName("SkillBlocker_NJ_unlockAllButton")
    if not unlockAllButton then
        unlockAllButton = wm:CreateControl("SkillBlocker_NJ_unlockAllButton", ZO_SkillsAssignableActionBar, CT_BUTTON)
    end
    unlockAllButton:SetDimensions(24, 24)
    unlockAllButton:SetNormalTexture(TEXTURE_PATHS.unlocked.normal)
    unlockAllButton:SetPressedTexture(TEXTURE_PATHS.unlocked.pressed)
    unlockAllButton:SetMouseOverTexture(TEXTURE_PATHS.unlocked.over)
    unlockAllButton:SetHandler("OnClicked", function() SB_NJ.unlockAll() end)
    unlockAllButton:SetAnchor(LEFT, ZO_SkillsAssignableActionBarButton6, RIGHT, 20, 0)
    SB_NJ.unlockAllButton = unlockAllButton
    
    unlockAllButton:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 0)
        SetTooltipText(InformationTooltip, GetString(SKILLBLOCKER_NJ_UNLOCK_ALL))
    end)
    unlockAllButton:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
end

function SB_NJ.unlockAll()
    if not settings then return end

    HideAllSettingsWindows() 

    local tables = {settings.mainBarBlockedAbilities, settings.offBarBlockedAbilities}
    for _, tbl in pairs(tables) do
        if tbl then
            for id, _ in pairs(tbl) do 
                LSB.UnregisterSkillBlock(ADDON_NAME, id) 
            end
            ZO_ClearTable(tbl)
        end
    end
    
    local specialLists = {BANNER_ABILITY_IDS, BUFF_COMBAT_ABILITY_IDS, COMBAT_ONLY_ABILITY_IDS, STACK_ABILITY_CONFIG, TARGET_HP_ABILITY_CONFIG, DOT_HOT_CONFIG}
    for _, list in pairs(specialLists) do
        for id, _ in pairs(list) do 
            LSB.UnregisterSkillBlock(ADDON_NAME, id) 
        end
    end

    local criminalTables = {settings.criminalBlockSettings.mainBar, settings.criminalBlockSettings.offBar}
    for _, tbl in pairs(criminalTables) do
        if tbl then
            for id, _ in pairs(tbl) do
                 LSB.UnregisterSkillBlock(ADDON_NAME, id)
            end
            ZO_ClearTable(tbl)
        end
    end

    local doubleCastTables = {settings.doubleCastBlockedAbilities.mainBar, settings.doubleCastBlockedAbilities.offBar}
    for _, tbl in pairs(doubleCastTables) do
        if tbl then
            for id, _ in pairs(tbl) do
                 LSB.UnregisterSkillBlock(ADDON_NAME, id)
            end
            ZO_ClearTable(tbl)
        end
    end

    local werewolfTables = {settings.werewolfBlockSettings.mainBar, settings.werewolfBlockSettings.offBar}
    for _, tbl in pairs(werewolfTables) do
        if tbl then
            for id, _ in pairs(tbl) do LSB.UnregisterSkillBlock(ADDON_NAME, id) end
            ZO_ClearTable(tbl)
        end
    end

    local ultimateTables = {settings.ultimateAbilitySettings.mainBar, settings.ultimateAbilitySettings.offBar}
    for _, tbl in pairs(ultimateTables) do
        if tbl then
            for id, _ in pairs(tbl) do
                LSB.UnregisterSkillBlock(ADDON_NAME, id)
            end
            ZO_ClearTable(tbl)
        end
    end

    local dotHotTables = {settings.dotHotSettings.mainBar, settings.dotHotSettings.offBar}
    for _, tbl in pairs(dotHotTables) do
        if tbl then
            for id, _ in pairs(tbl) do LSB.UnregisterSkillBlock(ADDON_NAME, id) end
            ZO_ClearTable(tbl)
        end
    end

    local debuffTables = {settings.debuffAbilitySettings.mainBar, settings.debuffAbilitySettings.offBar}
    for _, tbl in pairs(debuffTables) do
        if tbl then
            for id, _ in pairs(tbl) do LSB.UnregisterSkillBlock(ADDON_NAME, id) end
            ZO_ClearTable(tbl)
        end
    end
    ZO_ClearTable(activeDebuffs)
    
    settings.bannerBlockState = BANNER_STATE_UNLOCKED
    ZO_ClearTable(settings.buffCombatSettings.mainBar)
    ZO_ClearTable(settings.buffCombatSettings.offBar)
    settings.combatOnlyBlockState = STATE_UNLOCKED
    ZO_ClearTable(settings.stackAbilitySettings.mainBar)
    ZO_ClearTable(settings.stackAbilitySettings.offBar)
    
    ZO_ClearTable(settings.advancedBlockMode.mainBar)
    ZO_ClearTable(settings.advancedBlockMode.offBar)

    for id, _ in pairs(TARGET_HP_ABILITY_CONFIG) do
        settings.targetHpAbilitySettings.mainBar[id] = 100
        settings.targetHpAbilitySettings.offBar[id] = 100
    end
    
    EventBus:FireCallbacks(EVENTS.LOGIC_UPDATE)
    EventBus:FireCallbacks(EVENTS.UI_UPDATE)
    PlaySound(SOUNDS_INVENTORY_ITEM_UNLOCKED)
end

function SB_NJ.Cleanup()
    playerClassId = nil 
    
    ZO_ClearTable(handlerCache)
    ZO_ClearTable(exceptionBannerCache)
    ZO_ClearTable(rankCache)
    ZO_ClearTable(tempRelevantBuffs)
    ZO_ClearTable(activeBuffs)
    ZO_ClearTable(relevantBuffIds)
    ZO_ClearTable(activeDebuffs)
    ZO_ClearTable(relevantDebuffIds)
    
    if isTrackingEffects then
        EM:UnregisterForEvent(ADDON_NAME .. "_Effects", EVENT_EFFECT_CHANGED)
        isTrackingEffects = false
    end
    if isTrackingUltimate then
        EM:UnregisterForEvent(ADDON_NAME .. "_Ultimate", EVENT_POWER_UPDATE)
        isTrackingUltimate = false
    end
    
    if isTrackingTargetHp then
        EM:UnregisterForEvent(ADDON_NAME .. "_HpChange", EVENT_POWER_UPDATE)
        EM:UnregisterForEvent(ADDON_NAME .. "_TargetChange", EVENT_TARGET_CHANGED)
        isTrackingTargetHp = false
    end

    HideAllSettingsWindows() 
end

function SB_NJ.ToggleSlot(bindIndex)
    local slotNum = (bindIndex == 6) and 8 or (bindIndex + 2)
    local abilityId = GetSlotBoundAbilityIdSafe(slotNum)
    if not abilityId or abilityId == 0 then return end
    
    HideAllSettingsWindows()

    local handler = GetHandler(abilityId, slotNum)
    if handler then
        local toggleFunc = handler.forceToggle or handler.toggle
        local needRedraw = toggleFunc(abilityId, slotNum)
        
        EventBus:FireCallbacks(EVENTS.LOGIC_UPDATE)
        EventBus:FireCallbacks(EVENTS.UI_UPDATE)
    end
end

function SB_NJ.ToggleDoubleCastBlock(abilityId)
    local isBanner = SB_NJ.Data.Banners[abilityId]
    
    if isBanner then
        local currentSettings = GetSettingsTable("doubleCastBlockedAbilities")
        local willBlock = not currentSettings[abilityId]
        
        for bannerId, _ in pairs(SB_NJ.Data.Banners) do
            if willBlock then
                settings.doubleCastBlockedAbilities.mainBar[bannerId] = true
                settings.doubleCastBlockedAbilities.offBar[bannerId] = true
            else
                settings.doubleCastBlockedAbilities.mainBar[bannerId] = nil
                settings.doubleCastBlockedAbilities.offBar[bannerId] = nil
            end
            local shouldRegister = IsAnyBlockConfigured(bannerId)
            UpdateLockStatus(bannerId, shouldRegister, nil)
        end
        
    else
        local tbl = GetSettingsTable("doubleCastBlockedAbilities")
        if tbl[abilityId] then
            tbl[abilityId] = nil
        else
            tbl[abilityId] = true
        end
        local shouldRegister = IsAnyBlockConfigured(abilityId)
        UpdateLockStatus(abilityId, shouldRegister, nil)
    end

    EventBus:FireCallbacks(EVENTS.LOGIC_UPDATE)
    EventBus:FireCallbacks(EVENTS.UI_UPDATE)
end

function SB_NJ.SetAdvancedMode(abilityId, modeType, enable)
    HideAllSettingsWindows()

    local tbl = GetSettingsTable("advancedBlockMode")
    
    if enable then
        tbl[abilityId] = modeType
        PlaySound(SOUNDS_INVENTORY_ITEM_LOCKED)
    else
        if tbl[abilityId] == modeType or tbl[abilityId] == true then
            tbl[abilityId] = nil
            PlaySound(SOUNDS_INVENTORY_ITEM_UNLOCKED)
        end
    end
    
    ZO_ClearTable(handlerCache)
    EventBus:FireCallbacks(EVENTS.LOGIC_UPDATE)
    EventBus:FireCallbacks(EVENTS.UI_UPDATE)
end

-------------------------------------------------------------------------------
----------------------------[     Custom Menu      ]---------------------------
-------------------------------------------------------------------------------

local function RemoveAbilityFromSlot(slotNum, hotbarCategory)
    local hotbar = ACTION_BAR_ASSIGNMENT_MANAGER:GetCurrentHotbar()
    if hotbar then
        hotbar:ClearSlot(slotNum)
    end
end

local lastMenuX, lastMenuY = nil, nil

local function ShowSkillBlockerMenu(abilityId, slotNum, control)
    ClearMenu()
    
    local abilityName = zo_strformat("<<C:1>>", GetAbilityName(abilityId))
    
    AddCustomMenuItem("|cFFD700" .. abilityName .. "|r", function() end, MENU_ADD_OPTION_HEADER)
    
    -- 1. Double Cast
    local dcSettings = GetSettingsTable("doubleCastBlockedAbilities")
    local isDcBlocked = dcSettings[abilityId]
    
    local dcActionText = isDcBlocked and GetString(SKILLBLOCKER_NJ_ACTION_DISABLE) or GetString(SKILLBLOCKER_NJ_ACTION_ENABLE)
    local dcLabel = string.format("|cFFD700[|r|c00FFFFSkill Blocker|r|cFFD700]|r |cFFD700%s:|r %s", 
        GetString(SKILLBLOCKER_NJ_MENU_DOUBLE_CAST_TITLE), 
        isDcBlocked and "|cFF0000" .. dcActionText .. "|r" or "|c00FF00" .. dcActionText .. "|r")
    
    AddCustomMenuItem(dcLabel, function() 
        SB_NJ.ToggleDoubleCastBlock(abilityId)
        ClearMenu()
    end)

    local function AddAdvancedToggle(title, modeType)
        local isEnabled = IsAdvancedModeEnabled(abilityId, modeType)
        local actionText = isEnabled and GetString(SKILLBLOCKER_NJ_ACTION_DISABLE) or GetString(SKILLBLOCKER_NJ_ACTION_ENABLE)
        
        local label = string.format("|cFFD700[|r|c00FFFFSkill Blocker|r|cFFD700]|r |cFFD700%s:|r %s", 
            title, 
            isEnabled and "|cFF0000" .. actionText .. "|r" or "|c00FF00" .. actionText .. "|r")
        
        AddCustomMenuItem(label, function()
            SB_NJ.SetAdvancedMode(abilityId, modeType, not isEnabled)
            ClearMenu()
        end)
    end

    -- 2. Stacks / Crux / Proc
    if STACK_ABILITY_CONFIG[abilityId] then
        local config = STACK_ABILITY_CONFIG[abilityId]
        local title = GetString(SKILLBLOCKER_NJ_MENU_STACK_TITLE)
        
        if IS_CRUX_ABILITY[abilityId] then
            title = GetString(SKILLBLOCKER_NJ_MENU_CRUX_TITLE)
        elseif config.mode == "stage" then
            title = GetString(SKILLBLOCKER_NJ_MENU_PROC_TITLE)
        end
        
        AddAdvancedToggle(title, "Stack")
    end

    -- 3. Debuff (Explosions)
    if DEBUFF_ABILITY_CONFIG[abilityId] then
        AddAdvancedToggle(GetString(SKILLBLOCKER_NJ_MENU_DEBUFF_TITLE), "Debuff")
    end

    -- 4. Ultimate Points
    local isUltimateSlot = (GetSlotBoundAbilityIdSafe(ULTIMATE_SLOT_INDEX) == abilityId)
    if isUltimateSlot or TOGGLE_ULTIMATES[abilityId] or GetSettingsTable("ultimateAbilitySettings")[abilityId] then
        AddAdvancedToggle(GetString(SKILLBLOCKER_NJ_MENU_ULTIMATE_TITLE), "Ultimate")
    end

    -- 5. Duration (Dot/Hot)
    if DOT_HOT_CONFIG[abilityId] or SCRIBING_DOT_HOT[abilityId] then
        AddAdvancedToggle(GetString(SKILLBLOCKER_NJ_MENU_DURATION_TITLE), "DotHot")
    end

    -- 6. Target HP
    if TARGET_HP_ABILITY_CONFIG[abilityId] then
        AddAdvancedToggle(GetString(SKILLBLOCKER_NJ_MENU_HP_TITLE), "TargetHP")
    end

    -- 7. Criminal
    if CRIMINAL_ABILITY_IDS[abilityId] then
        local crimSettings = GetSettingsTable("criminalBlockSettings")
        local isCrimBlocked = crimSettings[abilityId]
        
        local crimAction = isCrimBlocked and GetString(SKILLBLOCKER_NJ_ACTION_DISABLE) or GetString(SKILLBLOCKER_NJ_ACTION_ENABLE)
        local crimTitle = GetString(SKILLBLOCKER_NJ_MENU_CRIMINAL_TITLE)
        
        local prefix, crimeWord = crimTitle:match("^(.-)(«.*»)$")
        if not crimeWord then
            prefix = crimTitle
            crimeWord = ""
        end
        
        local labelCrim = string.format("|cFFD700[|r|c00FFFFSkill Blocker|r|cFFD700]|r |cFFD700%s%s:|r %s", 
            prefix, 
            "|cFF0000" .. crimeWord .. "|cFFD700",
            isCrimBlocked and "|cFF0000" .. crimAction .. "|r" or "|c00FF00" .. crimAction .. "|r")

        AddCustomMenuItem(labelCrim, function() 
            Handlers.Criminal.toggle(abilityId)
            ClearMenu()
            EventBus:FireCallbacks(EVENTS.LOGIC_UPDATE)
            EventBus:FireCallbacks(EVENTS.UI_UPDATE)
        end)
    end

    AddCustomMenuItem(LibCustomMenu.DIVIDER, function() end)
    
    AddCustomMenuItem("|cFFD700[|r|c00FFFFSkill Blocker|r|cFFD700]|r |cFF0000" .. GetString(SKILLBLOCKER_NJ_DELETE_FROM_SLOT) .. "|r", function()
        RemoveAbilityFromSlot(slotNum, currentHotbar)
        ClearMenu()
    end)

    if control then
        ShowMenu(control)
    end
end

local function HookAbilitySlotRightClick()
    ZO_PreHook("ZO_AbilitySlot_OnSlotClicked", function(abilitySlot, buttonId)
        if buttonId == MOUSE_BUTTON_INDEX_RIGHT then
            local button = ZO_ActionBar_GetButton(abilitySlot.slotNum)
            if button then
                local slotNum = button:GetSlot()
                local slotType = GetSlotType(slotNum) 
                
                if (slotType == ACTION_TYPE_ABILITY or slotType == ACTION_TYPE_CRAFTED_ABILITY) and 
                   IsSlotUsed(slotNum) and not IsSlotLocked(slotNum) then
                    
                    local abilityId = GetSlotBoundAbilityIdSafe(slotNum)
                    
                    if abilityId and abilityId > 0 then
                        ShowSkillBlockerMenu(abilityId, slotNum, abilitySlot)
                        return true
                    end
                end
            end
        end
    end)
end

local function HookAssignableSkillsMenu()
    ZO_PreHook(ZO_KeyboardAssignableActionBarButton, "ShowActionMenu", function(self)
        local hotbar = ACTION_BAR_ASSIGNMENT_MANAGER:GetCurrentHotbar()
        local slotData = hotbar:GetSlotData(self.slotId)
        
        if slotData and not slotData:IsEmpty() then
            local abilityId = GetSlotBoundAbilityIdSafe(self.slotId)
            
            if abilityId and abilityId > 0 then
                ShowSkillBlockerMenu(abilityId, self.slotId, self.button)
                return true
            end
        end
        return false
    end)
end

local function InitializeCustomMenu()
    HookAbilitySlotRightClick()
    HookAssignableSkillsMenu()
end

local blockListContainer = nil

local guiPool = {
    rows = {},
    headers = {}
}

local function RefreshBlockList(container)
    if not container then return end
    
    local wm = WINDOW_MANAGER
    local settings = SB_NJ.settings
    
    for _, row in pairs(guiPool.rows) do row:SetHidden(true) row:ClearAnchors() end
    for _, header in pairs(guiPool.headers) do header:SetHidden(true) header:ClearAnchors() end
    
    local lastControl = nil
    local rowIndex = 0
    local headerIndex = 0
    local contentHeight = 0

    local function OnRemoveButtonClick(control)
        if control.removeAction then 
            control.removeAction()
            SB_NJ.ForceLogicUpdate() 
            RefreshBlockList(container) 
        end
    end

    local function AcquireRow()
        rowIndex = rowIndex + 1
        if not guiPool.rows[rowIndex] then
            local row = wm:CreateControl(nil, container, CT_CONTROL)
            row:SetHeight(24)
            row:SetWidth(container:GetWidth())
            
            local btn = wm:CreateControl(nil, row, CT_BUTTON)
            btn:SetDimensions(20, 20)
            btn:SetAnchor(LEFT, row, LEFT, 0, 0)
            btn:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
            btn:SetPressedTexture("/esoui/art/buttons/decline_down.dds")
            btn:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
            btn:SetHandler("OnClicked", OnRemoveButtonClick)
            row.btn = btn
            
            local label = wm:CreateControl(nil, row, CT_LABEL)
            label:SetFont("ZoFontGame")
            label:SetAnchor(LEFT, btn, RIGHT, 5, 0)
            label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
            row.label = label
            
            guiPool.rows[rowIndex] = row
        end
        return guiPool.rows[rowIndex]
    end

    local function AcquireHeader()
        headerIndex = headerIndex + 1
        if not guiPool.headers[headerIndex] then
            local header = wm:CreateControl(nil, container, CT_LABEL)
            header:SetFont("ZoFontWinH4")
            header:SetColor(1, 0.8, 0, 1)
            header:SetHeight(30)
            header:SetWidth(container:GetWidth())
            guiPool.headers[headerIndex] = header
        end
        return guiPool.headers[headerIndex]
    end

    local function AddListRow(text, action)
        local row = AcquireRow()
        row:SetHidden(false)
        row.label:SetText(text)
        row.btn.removeAction = action
        
        if lastControl then
            row:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, 0, 2)
        else
            row:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
        end
        lastControl = row
        contentHeight = contentHeight + 26
    end

    local function AddListHeader(text)
        local header = AcquireHeader()
        header:SetHidden(false)
        header:SetText(text)
        if lastControl then
            header:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, 0, 10)
            contentHeight = contentHeight + 40
        else
            header:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
            contentHeight = contentHeight + 30
        end
        lastControl = header
    end
    
    local function RemoveBlockLogic(abilityId, removeAction)
        removeAction()
        local shouldLock = IsAnyBlockConfigured(abilityId)
        UpdateLockStatus(abilityId, shouldLock)
    end

    local function CollectBlocks(isMainBar)
        local barName = isMainBar and "mainBar" or "offBar"
        local blocks = {} 
        
        local function AddBlock(id, reasonString, callback, groupedIds)
            table.insert(blocks, {id = id, text = reasonString, callback = callback, groupedIds = groupedIds})
        end

        -- 1. Full Lock
        local fullLockTable = isMainBar and settings.mainBarBlockedAbilities or settings.offBarBlockedAbilities
        for id, _ in pairs(fullLockTable) do
            AddBlock(id, GetString(SKILLBLOCKER_NJ_LOCKED), function() 
                RemoveBlockLogic(id, function()
                    fullLockTable[id] = nil
                    UpdateExternalBlockRegistration(id, "UNLOCK")
                end)
            end)
        end

        -- 2. Buff/Combat
        local bcTable = settings.buffCombatSettings[barName]
        for id, state in pairs(bcTable) do
            if state ~= 0 then
                local reason = (state == 1) and GetString(SKILLBLOCKER_NJ_LOCKED_COMBAT) or GetString(SKILLBLOCKER_NJ_LOCKED)
                AddBlock(id, reason, function() RemoveBlockLogic(id, function() bcTable[id] = 0 end) end)
            end
        end

        -- 3. Banner
        if settings.bannerBlockState and settings.bannerBlockState ~= 0 then
            local bannerReason = GetString(SKILLBLOCKER_NJ_LOCKED)
            if settings.bannerBlockState == 1 then bannerReason = GetString(SKILLBLOCKER_NJ_LOCKED_COMBAT)
            elseif settings.bannerBlockState == 2 then bannerReason = GetString(SKILLBLOCKER_NJ_LOCKED_ACTIVE) end

            local allBannerIds = {}
            local repId = nil
            for id, _ in pairs(SB_NJ.Data.Banners or {}) do
                table.insert(allBannerIds, id)
                if not repId then repId = id end
            end
            if repId then
                table.sort(allBannerIds)
                AddBlock(repId, bannerReason, function()
                    settings.bannerBlockState = 0
                    for bid, _ in pairs(SB_NJ.Data.Banners or {}) do UpdateLockStatus(bid, false) end
                end, allBannerIds)
            end
        end

        -- 4. Combat Only
        if settings.combatOnlyBlockState and settings.combatOnlyBlockState ~= 0 then
            local combatReason = (settings.combatOnlyBlockState == 1) and GetString(SKILLBLOCKER_NJ_LOCKED_COMBAT) or GetString(SKILLBLOCKER_NJ_LOCKED)
            for id, _ in pairs(SB_NJ.Data.CombatOnly or {}) do
                AddBlock(id, combatReason, function()
                    settings.combatOnlyBlockState = 0
                    for cid, _ in pairs(SB_NJ.Data.CombatOnly or {}) do UpdateLockStatus(cid, false) end
                end)
            end
        end

        -- 5. Double Cast
        local dcTable = settings.doubleCastBlockedAbilities[barName]
        local dcBannerIds = {}
        for id, _ in pairs(dcTable) do
            if SB_NJ.Data.Banners[id] then table.insert(dcBannerIds, id)
            else
                AddBlock(id, GetString(SKILLBLOCKER_NJ_MENU_DOUBLE_CAST_TITLE), function()
                    RemoveBlockLogic(id, function() dcTable[id] = nil end)
                end)
            end
        end
        if #dcBannerIds > 0 then
            table.sort(dcBannerIds)
            AddBlock(dcBannerIds[1], GetString(SKILLBLOCKER_NJ_MENU_DOUBLE_CAST_TITLE), function()
                for _, bid in ipairs(dcBannerIds) do
                    RemoveBlockLogic(bid, function() 
                        if settings.doubleCastBlockedAbilities.mainBar then settings.doubleCastBlockedAbilities.mainBar[bid] = nil end
                        if settings.doubleCastBlockedAbilities.offBar then settings.doubleCastBlockedAbilities.offBar[bid] = nil end
                    end)
                end
            end, dcBannerIds)
        end

        -- 6. Criminal
        local crimTable = settings.criminalBlockSettings[barName]
        for id, _ in pairs(crimTable) do
            AddBlock(id, GetString(SKILLBLOCKER_NJ_MENU_CRIMINAL_TITLE), function()
                RemoveBlockLogic(id, function() crimTable[id] = nil end)
            end)
        end
        
        -- 7. Werewolf
        local wwTable = settings.werewolfBlockSettings[barName]
        for id, state in pairs(wwTable) do
            if state ~= 0 then
                local reason = (state == 1) and GetString(SKILLBLOCKER_NJ_LOCKED_WEREWOLF) or GetString(SKILLBLOCKER_NJ_LOCKED)
                AddBlock(id, reason, function()
                    RemoveBlockLogic(id, function() wwTable[id] = 0 end)
                end)
            end
        end
        
        -- 8. Advanced (Stacks, HP, Ultimate, Duration, Debuff)
        local advancedConfigs = {
            {key = "stackAbilitySettings", str = SKILLBLOCKER_NJ_BLOCK_STACKS, def = 0, mode = "Stack"},
            {key = "targetHpAbilitySettings", str = SKILLBLOCKER_NJ_BLOCK_HP, def = 100, mode = "TargetHP"},
            {key = "ultimateAbilitySettings", str = SKILLBLOCKER_NJ_BLOCK_ULTIMATE, def = 0, mode = "Ultimate"},
            {key = "dotHotSettings", str = SKILLBLOCKER_NJ_BLOCK_DURATION, def = 0, mode = "DotHot"},
            {key = "debuffAbilitySettings", str = SKILLBLOCKER_NJ_BLOCK_DEBUFF, def = 0, mode = "Debuff"},
        }

        for _, cfg in ipairs(advancedConfigs) do
            local subTable = settings[cfg.key][barName]
            for id, val in pairs(subTable) do
                local isActive = (cfg.def == 100 and val < 100) or (cfg.def == 501 and val < 501) or (cfg.def == 0 and val > 0)
                if isActive then
                    local rawStr = GetString(cfg.str)
                    if cfg.mode == "Stack" and SB_NJ.Data.StackConfig[id] then
                        local sCfg = SB_NJ.Data.StackConfig[id]
                        if SB_NJ.Data.IsCrux[id] then
                            rawStr = (sCfg.mode == "reverse") and GetString(SKILLBLOCKER_NJ_BLOCK_REVERSE) or GetString(SKILLBLOCKER_NJ_BLOCK_CRUX)
                        elseif sCfg.mode == "stage" then
                            rawStr = GetString(SKILLBLOCKER_NJ_BLOCK_PROC)
                        end
                    end
                    local reason = rawStr:find("<<1>>") and zo_strformat(rawStr, val) or (rawStr .. " " .. val)
                    AddBlock(id, reason, function()
                        RemoveBlockLogic(id, function()
                            subTable[id] = cfg.def
                            SB_NJ.SetAdvancedMode(id, cfg.mode, false)
                        end)
                    end)
                end
            end
        end

        table.sort(blocks, function(a, b) 
            return zo_strformat("<<C:1>>", GetAbilityName(a.id)) < zo_strformat("<<C:1>>", GetAbilityName(b.id))
        end)
        return blocks
    end

    local function DrawBar(isMain)
        AddListHeader(isMain and GetString(SKILLBLOCKER_NJ_MAIN_BAR) or GetString(SKILLBLOCKER_NJ_BACK_BAR))
        local list = CollectBlocks(isMain)
        for _, b in ipairs(list) do
            local ids = b.groupedIds and table.concat(b.groupedIds, ", ") or tostring(b.id)
            local line = string.format("|c00FFFF\"%s\"|r |cAAAAAA[ID: %s]|r: %s", zo_strformat("<<C:1>>", GetAbilityName(b.id)), ids, b.text)
            AddListRow(line, b.callback)
        end
    end

    DrawBar(true)
    DrawBar(false)
    container:SetHeight(contentHeight + 20)
end

local function Initialize()

    SB_NJ.settings = ZO_SavedVars:NewCharacterIdSettings(savedVarsName, variableVersion, "settings", defaults, GetWorldName())
    settings = SB_NJ.settings

    playerClassId = GetUnitClassId("player") 

    LAM:RegisterAddonPanel("Skill Blocker by Ness_Jess", { 
        type = "panel", 
        name = "|c00FFFFSkill Blocker by Ness_Jess|r", 
        author = "|c00FFFF@Ness_Jess|r", 
        version = ADDON_VERSION 
    })
    
    LAM:RegisterOptionControls("Skill Blocker by Ness_Jess", {
        {
            type = "header",
            name = "|cFFD700" .. GetString(SKILLBLOCKER_NJ_GENERAL_SETTINGS) .. "|r",
        },
        { 
            type = "checkbox", 
            name = GetString(SKILLBLOCKER_NJ_REMEMBER), 
            getFunc = function() return GetSettings().rememberLocks end, 
            setFunc = function(v) if settings then settings.rememberLocks = v end end 
        },
        { 
            type = "checkbox", 
            name = GetString(SKILLBLOCKER_NJ_SHOW_ALERT), 
            tooltip = GetString(SKILLBLOCKER_NJ_ALERT_TOOLTIP), 
            getFunc = function() return GetSettings().displayAlert end, 
            setFunc = function(v) if settings then settings.displayAlert = v end end 
        },
        {
            type = "header",
            name = "|cFFD700" .. GetString(SKILLBLOCKER_NJ_DOUBLE_CAST_BLOCK_SETTINGS) .. "|r",
        },
        { 
            type = "checkbox", 
            name = GetString(SKILLBLOCKER_NJ_RESET_DOUBLE_CAST_LA), 
            tooltip = GetString(SKILLBLOCKER_NJ_RESET_DOUBLE_CAST_LA_TOOLTIP), 
            getFunc = function() return GetSettings().resetDoubleCastOnLA end, 
            setFunc = function(v) if settings then settings.resetDoubleCastOnLA = v end end 
        },
        {
            type = "slider",
            name = GetString(SKILLBLOCKER_NJ_DOUBLE_CAST_BLOCK_DURATION),
            tooltip = GetString(SKILLBLOCKER_NJ_DOUBLE_CAST_BLOCK_DURATION_TOOLTIP),
            min = 0,
            max = 3,
            step = 0.1,
            decimals = 1,
            getFunc = function() return GetSettings().doubleCastBlockDuration end, 
            setFunc = function(v) 
                if settings then 
                    settings.doubleCastBlockDuration = v 
                    
                    lastUsedAbilityId = 0 
                    
                    EventBus:FireCallbacks(EVENTS.LOGIC_UPDATE)
                    EventBus:FireCallbacks(EVENTS.UI_UPDATE)
                end 
            end 
        },
        {
            type = "header",
            name = "|cFFD700" .. (GetString(SKILLBLOCKER_NJ_MENU_ACTIVE_BLOCKS_TITLE) or "Active Blocks") .. "|r",
        },
        {
            type = "custom",
            reference = "SkillBlocker_NJ_BlockList",
            width = "full",
            createFunc = function(customControl)
                RefreshBlockList(customControl)
                local function OnPanelOpened(panel)
                    if panel == SkillBlocker_NJ_BlockList.panel then
                        RefreshBlockList(customControl)
                    end
                end
                CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", OnPanelOpened)
            end,
            refreshFunc = function(customControl)
                RefreshBlockList(customControl)
            end,
        }
    })

    currentHotbar = GetActiveHotbarCategory()
    isPlayerInCombat = IsUnitInCombat("player")
    loadLocks()
    
    EventBus:RegisterCallback(EVENTS.LOGIC_UPDATE, function()
        ZO_ClearTable(handlerCache) 
        ScanHotbarForRelevantBuffs() 
    end)
    
    EventBus:RegisterCallback(EVENTS.UI_UPDATE, function()
        drawLocks() 
    end)

    if settings and settings.rememberLocks then
        local registeredStandardLocks = {}
        local function registerStandardLock(abilityTable)
            if not abilityTable then return end
            for id, _ in pairs(abilityTable) do
                if not registeredStandardLocks[id] then
                    UpdateLockStatus(id, true, nil)
                    registeredStandardLocks[id] = true
                end
            end
        end
        registerStandardLock(settings.mainBarBlockedAbilities)
        registerStandardLock(settings.offBarBlockedAbilities)
        
        if settings.bannerBlockState ~= BANNER_STATE_UNLOCKED then
            for id, _ in pairs(BANNER_ABILITY_IDS) do 
                UpdateLockStatus(id, true, nil)
            end
        end
        
        if settings.buffCombatSettings then
            for id, _ in pairs(BUFF_COMBAT_ABILITY_IDS) do
                local valMain = (settings.buffCombatSettings.mainBar and settings.buffCombatSettings.mainBar[id]) or STATE_UNLOCKED
                local valOff = (settings.buffCombatSettings.offBar and settings.buffCombatSettings.offBar[id]) or STATE_UNLOCKED
                if valMain ~= STATE_UNLOCKED or valOff ~= STATE_UNLOCKED then
                     UpdateLockStatus(id, true, nil)
                end
            end
        end

        if settings.combatOnlyBlockState ~= STATE_UNLOCKED then
            for id, _ in pairs(COMBAT_ONLY_ABILITY_IDS) do UpdateLockStatus(id, true, nil) end
        end

        if settings.criminalBlockSettings then
            local criminalTables = {settings.criminalBlockSettings.mainBar, settings.criminalBlockSettings.offBar}
            for _, tbl in pairs(criminalTables) do
                if tbl then
                    for id, _ in pairs(tbl) do
                        if not isPlayerInCombat and IsOpenWorld() then
                             UpdateLockStatus(id, true, nil)
                        end
                    end
                end
            end
        end
        
        if settings.stackAbilitySettings then
            for id, config in pairs(STACK_ABILITY_CONFIG) do 
                local advMain = settings.advancedBlockMode and settings.advancedBlockMode.mainBar and settings.advancedBlockMode.mainBar[id]
                local advOff = settings.advancedBlockMode and settings.advancedBlockMode.offBar and settings.advancedBlockMode.offBar[id]
                
                if advMain or advOff then
                    local valMain = (settings.stackAbilitySettings.mainBar and settings.stackAbilitySettings.mainBar[id]) or 0
                    local valOff = (settings.stackAbilitySettings.offBar and settings.stackAbilitySettings.offBar[id]) or 0
                    if valMain > 0 or valOff > 0 then UpdateLockStatus(id, true, nil) end
                end
            end
        end
        
        if settings.targetHpAbilitySettings then
            for id, _ in pairs(TARGET_HP_ABILITY_CONFIG) do 
                local advMain = settings.advancedBlockMode and settings.advancedBlockMode.mainBar and settings.advancedBlockMode.mainBar[id]
                local advOff = settings.advancedBlockMode and settings.advancedBlockMode.offBar and settings.advancedBlockMode.offBar[id]

                if advMain or advOff then
                    local valMain = (settings.targetHpAbilitySettings.mainBar and settings.targetHpAbilitySettings.mainBar[id]) or 100
                    local valOff = (settings.targetHpAbilitySettings.offBar and settings.targetHpAbilitySettings.offBar[id]) or 100
                    if valMain < 100 or valOff < 100 then UpdateLockStatus(id, true, nil) end
                end
            end
        end

        if settings.werewolfBlockSettings then
            local wwTables = {settings.werewolfBlockSettings.mainBar, settings.werewolfBlockSettings.offBar}
            for _, tbl in pairs(wwTables) do
                if tbl then
                    for id, val in pairs(tbl) do
                        if val > 0 then UpdateLockStatus(id, true, nil) end
                    end
                end
            end
        end

        if settings.ultimateAbilitySettings then
            if settings.ultimateAbilitySettings.mainBar then
                for id, _ in pairs(settings.ultimateAbilitySettings.mainBar) do
                    if settings.advancedBlockMode and settings.advancedBlockMode.mainBar and settings.advancedBlockMode.mainBar[id] then
                        local val = settings.ultimateAbilitySettings.mainBar[id] or 0
                        if val > 0 then UpdateLockStatus(id, true, nil) end
                    end
                end
            end
            if settings.ultimateAbilitySettings.offBar then
                for id, _ in pairs(settings.ultimateAbilitySettings.offBar) do
                    if settings.advancedBlockMode and settings.advancedBlockMode.offBar and settings.advancedBlockMode.offBar[id] then
                        local val = settings.ultimateAbilitySettings.offBar[id] or 0
                        if val > 0 then UpdateLockStatus(id, true, nil) end
                    end
                end
            end
        end

        if settings.dotHotSettings then
            if settings.dotHotSettings.mainBar then
                for id, _ in pairs(settings.dotHotSettings.mainBar) do
                    if settings.advancedBlockMode and settings.advancedBlockMode.mainBar and settings.advancedBlockMode.mainBar[id] then
                        local val = settings.dotHotSettings.mainBar[id] or 0
                        if val > 0 then UpdateLockStatus(id, true, nil) end
                    end
                end
            end
            if settings.dotHotSettings.offBar then
                for id, _ in pairs(settings.dotHotSettings.offBar) do
                    if settings.advancedBlockMode and settings.advancedBlockMode.offBar and settings.advancedBlockMode.offBar[id] then
                        local val = settings.dotHotSettings.offBar[id] or 0
                        if val > 0 then UpdateLockStatus(id, true, nil) end
                    end
                end
            end
        end

        if settings.debuffAbilitySettings then
            if settings.debuffAbilitySettings.mainBar then
                for id, _ in pairs(settings.debuffAbilitySettings.mainBar) do
                    if settings.advancedBlockMode and settings.advancedBlockMode.mainBar and settings.advancedBlockMode.mainBar[id] then
                        local val = settings.debuffAbilitySettings.mainBar[id] or 0
                        if val > 0 then UpdateLockStatus(id, true, nil) end
                    end
                end
            end
            if settings.debuffAbilitySettings.offBar then
                for id, _ in pairs(settings.debuffAbilitySettings.offBar) do
                    if settings.advancedBlockMode and settings.advancedBlockMode.offBar and settings.advancedBlockMode.offBar[id] then
                        local val = settings.debuffAbilitySettings.offBar[id] or 0
                        if val > 0 then UpdateLockStatus(id, true, nil) end
                    end
                end
            end
        end
        
        if settings.doubleCastBlockedAbilities then
            local doubleCastTables = {settings.doubleCastBlockedAbilities.mainBar, settings.doubleCastBlockedAbilities.offBar}
            for _, tbl in pairs(doubleCastTables) do
                if tbl then
                    for id, _ in pairs(tbl) do
                        RegisterSilentBlock(id)
                    end
                end
            end
        end
    end

    EventBus:FireCallbacks(EVENTS.LOGIC_UPDATE)
    EventBus:FireCallbacks(EVENTS.UI_UPDATE)

    ACTION_BAR_ASSIGNMENT_MANAGER:RegisterCallback("CurrentHotbarUpdated", function(hotbarCategory)
        currentHotbar = hotbarCategory
        HideAllSettingsWindows()
        ClearMenu() 
        ImmediateUpdate()
    end)
    
    EM:RegisterForEvent(ADDON_NAME, EVENT_HOTBAR_SLOT_UPDATED, function(_, slotIndex) OnSlotUpdated(nil, slotIndex + 1) end)
    EM:RegisterForEvent(ADDON_NAME, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, OnActiveWeaponPairChanged)
    EM:RegisterForEvent(ADDON_NAME, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, function() OnSlotUpdated(nil, 3) end) 
    EM:RegisterForEvent(ADDON_NAME .. "_Cleanup", EVENT_PLAYER_DEACTIVATED, SB_NJ.Cleanup)
    EM:RegisterForEvent(ADDON_NAME .. "_Death", EVENT_PLAYER_DEAD, function()
        ZO_ClearTable(activeDebuffs)
        EventBus:FireCallbacks(EVENTS.LOGIC_UPDATE)
        EventBus:FireCallbacks(EVENTS.UI_UPDATE)
    end)
    EM:RegisterForEvent(ADDON_NAME .. "_DoubleCastMonitor", EVENT_ACTION_SLOT_ABILITY_USED, OnAbilityUsed)
    EM:RegisterForEvent(ADDON_NAME .. "_GlobalCombat", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat) 
        isPlayerInCombat = inCombat
        if SM:IsShowing("skills") then
            EventBus:FireCallbacks(EVENTS.UI_UPDATE)
        end
    end)

    SM:GetScene("skills"):RegisterCallback("StateChange", OnSkillsSceneStateChange)

        EM:RegisterForEvent(ADDON_NAME .. "_LoadedMsg", EVENT_PLAYER_ACTIVATED, function()
        EM:UnregisterForEvent(ADDON_NAME .. "_LoadedMsg", EVENT_PLAYER_ACTIVATED)
        zo_callLater(function()
            d("[|c00FFFFSkill Blocker by Ness_Jess|r] " .. GetString(SKILLBLOCKER_NJ_LOADED))
            InitializeCustomMenu()
        end, 0)
    end)
end

EM:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(_, name) 
    if name == ADDON_NAME then 
        EM:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
        Initialize() 
    end 
end)