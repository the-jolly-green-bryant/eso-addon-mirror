local ADDON_NAME = "HeavyAttackAlerter"
local HeavyAttackAlerter = {}

local uiControl = nil
local textureControl = nil
local resetTimerName = ADDON_NAME .. "_ResetTimer"

local SHIELD_TEXTURE = "/esoui/art/icons/servicetooltipicons/servicetooltipicon_heavyarmor.dds"

-- Кэшируем имя игрока
local playerRawName = ""

-- Форматирование строк по стандартам ESO UI
local function GetLoc(stringId, ...)
    if select("#", ...) > 0 then
        return zo_strformat(GetString(stringId), ...)
    end
    return zo_strformat("<<1>>", GetString(stringId))
end

-- Системные звуки
local SOUND_KEYS = { "CHAMPION", "DUEL", "QUEST", "NONE" }

local SOUND_SOUNDS = {
    ["CHAMPION"] = SOUNDS.CHAMPION_POINTS_COMMITTED,
    ["DUEL"]     = SOUNDS.DUEL_START,
    ["QUEST"]    = SOUNDS.QUEST_COMPLETED,
    ["NONE"]     = nil
}

local function GetSoundChoiceString(key)
    if key == "CHAMPION" then return GetLoc(SI_HAA_SOUND_CHAMPION) end
    if key == "DUEL"     then return GetLoc(SI_HAA_SOUND_DUEL) end
    if key == "QUEST"    then return GetLoc(SI_HAA_SOUND_QUEST) end
    return GetLoc(SI_HAA_SOUND_NONE)
end

local defaultSettings = {
    offsetX = 0,
    offsetY = 0,
    size = 40,
    alpha = 30,
    alertAlpha = 100,
    combatOnly = false,
    soundKey = "CHAMPION",
}

local function ResetToSafeState()
    if textureControl then
        local currentAlpha = (HeavyAttackAlerter.savedVars.alpha or 30) / 100
        textureControl:SetColor(0.2, 1.0, 0.2, currentAlpha)
    end
end

local function UpdateUIAppearance()
    if not uiControl or not textureControl then return end

    local size = HeavyAttackAlerter.savedVars.size or 40
    local offX = HeavyAttackAlerter.savedVars.offsetX or 0
    local offY = HeavyAttackAlerter.savedVars.offsetY or 0

    uiControl:ClearAnchors()
    uiControl:SetAnchor(CENTER, GuiRoot, CENTER, offX, offY)
    uiControl:SetDimensions(size, size)

    textureControl:ClearAnchors()
    textureControl:SetAnchor(TOPLEFT, uiControl, TOPLEFT, 0, 0)
    textureControl:SetDimensions(size, size)
    textureControl:SetTexture(SHIELD_TEXTURE)

    ResetToSafeState()

    if HeavyAttackAlerter.savedVars.combatOnly and not IsUnitInCombat("player") then
        uiControl:SetHidden(true)
    else
        uiControl:SetHidden(false)
    end
end

local function TriggerBlockAlert(castDurationMS)
    if not textureControl or not uiControl then return end

    uiControl:SetHidden(false)
    
    local redAlpha = (HeavyAttackAlerter.savedVars.alertAlpha or 100) / 100
    textureControl:SetColor(1.0, 0.0, 0.0, redAlpha)

    local soundKey = HeavyAttackAlerter.savedVars.soundKey or "CHAMPION"
    local soundToPlay = SOUND_SOUNDS[soundKey]
    if soundToPlay then
        PlaySound(soundToPlay)
    end

    EVENT_MANAGER:UnregisterForUpdate(resetTimerName)
    EVENT_MANAGER:RegisterForUpdate(resetTimerName, castDurationMS, function()
        EVENT_MANAGER:UnregisterForUpdate(resetTimerName)
        ResetToSafeState()
        if HeavyAttackAlerter.savedVars.combatOnly and not IsUnitInCombat("player") then
            uiControl:SetHidden(true)
        end
    end)
end

local function OnPlayerCombatState(eventCode, inCombat)
    if HeavyAttackAlerter.savedVars.combatOnly then
        if inCombat then
            uiControl:SetHidden(false)
            ResetToSafeState()
        else
            uiControl:SetHidden(true)
        end
    end
end

local function OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, 
                             abilityActionSlotType, sourceName, sourceType, targetName, 
                             targetType, hitValue, powerType, damageType, log, 
                             sourceUnitId, targetUnitId, abilityId, overflow)
    
    -- 1. Сброс алерта при прерывании
    if result == ACTION_RESULT_INTERRUPT then
        EVENT_MANAGER:UnregisterForUpdate(resetTimerName)
        ResetToSafeState()
        return
    end

    -- 2. Реагируем ТОЛЬКО на начало силового замаха
    -- Исключаем обычные ченнелы (каналы с красными искрами), концентрируясь на BEGIN замахах
    if result ~= ACTION_RESULT_BEGIN and result ~= ACTION_RESULT_BEGIN_CHANNEL then
        return
    end

    -- 3. Тяжелые силовые атаки (желтые искры) всегда длятся от 750мс
    if not hitValue or hitValue < 750 then
        return
    end

    -- 4. Исключаем прерываемые атаки (красные искры / баши), если они помечены в слоте
    if abilityActionSlotType == ACTION_SLOT_TYPE_INTERRUPTABLE or result == ACTION_RESULT_CANNOT_INTERRUPT then
        -- ACTION_RESULT_CANNOT_INTERRUPT как раз подтверждает, что это НЕ прерываемая желтая атака
    end

    -- 5. Источник — только враг / монстр
    if sourceType ~= COMBAT_UNIT_TYPE_MONSTER and sourceType ~= COMBAT_UNIT_TYPE_OTHER then
        return
    end
    if sourceName == "" or sourceName == playerRawName then
        return
    end

    -- 6. Проверка цели: строго мы (как танк или как сорвавшийся агро-таргет)
    local isTargetingPlayer = (targetType == COMBAT_UNIT_TYPE_PLAYER) 
                           or (targetName ~= "" and targetName == playerRawName)

    if not isTargetingPlayer then
        -- Если босс замахивается кливом/конусом без жесткого таргета, но мы держим его в прицеле/в бою
        if targetType == COMBAT_UNIT_TYPE_NONE and IsUnitInCombat("player") then
            local reticleName = GetUnitName("reticleover")
            local isBoss = (sourceName == GetUnitName("boss1")) or (sourceName == GetUnitName("boss2"))
            if isBoss or (reticleName ~= "" and sourceName == reticleName) then
                isTargetingPlayer = true
            end
        end
    end

    if not isTargetingPlayer then
        return
    end

    -- 7. Запуск тревоги на блок / додж
    TriggerBlockAlert(hitValue)
end

local function RegisterAddonSettings()
    local LibHarven = LibHarvensAddonSettings
    if not LibHarven then return end

    local settings = LibHarven:AddAddon("Heavy Attack Alerter")
    if not settings then return end

    settings.version = "1.0.6"
    settings.author = "YourName"

    -- 1. Только в бою
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = GetLoc(SI_HAA_COMBAT_ONLY_NAME),
        tooltip = GetLoc(SI_HAA_COMBAT_ONLY_TIP),
        default = false,
        getFunction = function() return HeavyAttackAlerter.savedVars.combatOnly end,
        setFunction = function(value)
            HeavyAttackAlerter.savedVars.combatOnly = value
            UpdateUIAppearance()
        end,
    })

    -- 2. Выбор звука
    local soundItems = {}
    for _, key in ipairs(SOUND_KEYS) do
        table.insert(soundItems, { name = GetSoundChoiceString(key), data = key })
    end

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_DROPDOWN,
        label = GetLoc(SI_HAA_SOUND_NAME),
        tooltip = GetLoc(SI_HAA_SOUND_TIP),
        items = soundItems,
        default = soundItems[1],
        getFunction = function()
            local currentKey = HeavyAttackAlerter.savedVars.soundKey or "CHAMPION"
            for _, item in ipairs(soundItems) do
                if item.data == currentKey then
                    return item
                end
            end
            return soundItems[1]
        end,
        setFunction = function(combobox, name, item)
            local selectedItem = item or combobox
            local selectedKey = selectedItem and selectedItem.data

            if not selectedKey and type(selectedItem) == "string" then
                for _, elem in ipairs(soundItems) do
                    if elem.name == selectedItem or elem.data == selectedItem then
                        selectedKey = elem.data
                        break
                    end
                end
            end

            if selectedKey then
                HeavyAttackAlerter.savedVars.soundKey = selectedKey
                if SOUND_SOUNDS[selectedKey] then
                    PlaySound(SOUND_SOUNDS[selectedKey])
                end
            end
        end,
    })

    -- 3. Прозрачность зеленого щита
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = GetLoc(SI_HAA_ALPHA_NAME),
        tooltip = GetLoc(SI_HAA_ALPHA_TIP),
        min = 10,
        max = 100,
        step = 5,
        unit = "%",
        default = 30,
        getFunction = function() return HeavyAttackAlerter.savedVars.alpha end,
        setFunction = function(value)
            HeavyAttackAlerter.savedVars.alpha = value
            UpdateUIAppearance()
        end,
    })

    -- 4. Прозрачность красного щита
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = GetLoc(SI_HAA_ALERT_ALPHA_NAME),
        tooltip = GetLoc(SI_HAA_ALERT_ALPHA_TIP),
        min = 10,
        max = 100,
        step = 5,
        unit = "%",
        default = 100,
        getFunction = function() return HeavyAttackAlerter.savedVars.alertAlpha end,
        setFunction = function(value)
            HeavyAttackAlerter.savedVars.alertAlpha = value
        end,
    })

    -- 5. Размер иконки
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = GetLoc(SI_HAA_SIZE_NAME),
        min = 24,
        max = 128,
        step = 2,
        unit = "px",
        default = 40,
        getFunction = function() return HeavyAttackAlerter.savedVars.size end,
        setFunction = function(value)
            HeavyAttackAlerter.savedVars.size = value
            UpdateUIAppearance()
        end,
    })

    -- 6. Смещение X
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = GetLoc(SI_HAA_OFFSET_X_NAME),
        min = -500,
        max = 500,
        step = 5,
        default = 0,
        getFunction = function() return HeavyAttackAlerter.savedVars.offsetX end,
        setFunction = function(value)
            HeavyAttackAlerter.savedVars.offsetX = value
            UpdateUIAppearance()
        end,
    })

    -- 7. Смещение Y
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = GetLoc(SI_HAA_OFFSET_Y_NAME),
        min = -500,
        max = 500,
        step = 5,
        default = 0,
        getFunction = function() return HeavyAttackAlerter.savedVars.offsetY end,
        setFunction = function(value)
            HeavyAttackAlerter.savedVars.offsetY = value
            UpdateUIAppearance()
        end,
    })

    -- 8. Кнопка теста
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = GetLoc(SI_HAA_TEST_BUTTON_NAME),
        tooltip = GetLoc(SI_HAA_TEST_BUTTON_TIP),
        buttonText = GetLoc(SI_HAA_TEST_BUTTON_NAME),
        clickHandler = function()
            TriggerBlockAlert(1500)
        end,
    })
end

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= ADDON_NAME then return end

    HeavyAttackAlerter.savedVars = ZO_SavedVars:NewAccountWide(
        "HeavyAttackAlerterSavedVars", 
        3, 
        nil, 
        defaultSettings
    )

    playerRawName = GetUnitName("player")
    uiControl = HeavyAttackAlerter_UI
    textureControl = HeavyAttackAlerter_UI_Texture

    UpdateUIAppearance()
    RegisterAddonSettings()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)