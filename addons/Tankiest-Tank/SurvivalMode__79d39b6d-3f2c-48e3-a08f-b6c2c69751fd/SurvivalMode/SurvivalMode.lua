local SM = {}

SM.name = "SurvivalMode"

SM.defaults = {
    hungerTime = 3600,
    maxHungerTime = 3600,
    consumeBonus = 1200,
    lowWarningTime = 1200,

    showHud = true,
    showRules = true,
    paused = false,
    allowHungerGainWhilePaused = true,
    failed = false,

    hideHudInMenus = true,
    pauseTimerInMenus = false,

    hudX = 80,
    hudY = 140,
    hudScale = 100,

    hideBackgroundBox = false,
    boxWidthScale = 100,
    boxHeightScale = 100,
    timerXOffset = 138,

    titleScale = 100,
    statusScale = 100,
    hungerLabelScale = 100,
    hungerTimerScale = 100,
    rulesScale = 100,

    backgroundR = 0,
    backgroundG = 0,
    backgroundB = 0,
    backgroundA = 0.95,

    titleR = 1,
    titleG = 1,
    titleB = 1,
    titleA = 1,

    activeR = 0.4,
    activeG = 1,
    activeB = 0.4,
    activeA = 1,

    pausedR = 0.5,
    pausedG = 0.8,
    pausedB = 1,
    pausedA = 1,

    hungerR = 1,
    hungerG = 1,
    hungerB = 1,
    hungerA = 1,

    warningR = 1,
    warningG = 0.65,
    warningB = 0,
    warningA = 1,

    failedR = 1,
    failedG = 0.2,
    failedB = 0.2,
    failedA = 1,

    rulesR = 1,
    rulesG = 1,
    rulesB = 1,
    rulesA = 1,

    ruleGuildTraders = true,
    rulePlayerTrading = true,
    ruleSoulGems = true,
    ruleWayshrines = true,
    ruleBankWithdrawals = true,
    ruleTransmuting = true,
}

SM.lastDetectedAbilityId = nil
SM.lastDetectedAt = 0
SM.inMenu = false

local BASE_TITLE_SCALE = 7.0
local BASE_STATUS_SCALE = 7.5
local BASE_HUNGER_LABEL_SCALE = 7.5
local BASE_HUNGER_TIMER_SCALE = 7.5
local BASE_RULES_SCALE = 4.8

local function ApplyMissingDefaults()
    for key, value in pairs(SM.defaults) do
        if SM.saved[key] == nil then
            SM.saved[key] = value
        end
    end
end

local function FormatTime(seconds)
    seconds = math.max(0, seconds)
    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", minutes, secs)
end

local function IsInMenu()
    if SCENE_MANAGER and SCENE_MANAGER.GetCurrentScene then
        local scene = SCENE_MANAGER:GetCurrentScene()
        if scene and scene.GetName then
            local name = scene:GetName()
            return name ~= "hud" and name ~= "hudui"
        end
    end

    return false
end

local function GetEnabledRules()
    local rules = {}

    table.insert(rules, "- Consume to add " .. tostring(math.floor(SM.saved.consumeBonus / 60)) .. " min")

    if SM.saved.ruleGuildTraders then table.insert(rules, "- No guild traders") end
    if SM.saved.rulePlayerTrading then table.insert(rules, "- No player trading") end
    if SM.saved.ruleSoulGems then table.insert(rules, "- No soul gem usage") end
    if SM.saved.ruleWayshrines then table.insert(rules, "- No wayshrines") end
    if SM.saved.ruleBankWithdrawals then table.insert(rules, "- No bank withdrawals") end
    if SM.saved.ruleTransmuting then table.insert(rules, "- No transmuting") end

    return rules
end

local function GetRulesText()
    return table.concat(GetEnabledRules(), "\n\n")
end

local function ResetChallenge()
    SM.saved.hungerTime = SM.saved.maxHungerTime
    SM.saved.failed = false
    SM.lastDetectedAbilityId = nil
    SM.lastDetectedAt = 0
    SM.UpdateDisplay()
end

local function ResetVisualSettingsToDefault()
    local keys = {
        "hideBackgroundBox", "boxWidthScale", "boxHeightScale", "timerXOffset",
        "titleScale", "statusScale", "hungerLabelScale", "hungerTimerScale", "rulesScale",
        "backgroundR", "backgroundG", "backgroundB", "backgroundA",
        "titleR", "titleG", "titleB", "titleA",
        "activeR", "activeG", "activeB", "activeA",
        "pausedR", "pausedG", "pausedB", "pausedA",
        "hungerR", "hungerG", "hungerB", "hungerA",
        "warningR", "warningG", "warningB", "warningA",
        "failedR", "failedG", "failedB", "failedA",
        "rulesR", "rulesG", "rulesB", "rulesA",
    }

    for _, key in ipairs(keys) do
        SM.saved[key] = SM.defaults[key]
    end

    SM.UpdateDisplay()
end

local function ResetSettingsToDefault()
    local currentHunger = SM.saved.hungerTime
    local currentFailed = SM.saved.failed

    for key, value in pairs(SM.defaults) do
        SM.saved[key] = value
    end

    SM.saved.hungerTime = math.min(currentHunger, SM.saved.maxHungerTime)
    SM.saved.failed = currentFailed

    SM.UpdateDisplay()
end

local function AddHunger(abilityId)
    local now = GetTimeStamp()

    if abilityId ~= nil and abilityId == SM.lastDetectedAbilityId and now - SM.lastDetectedAt < 5 then
        return
    end

    SM.lastDetectedAbilityId = abilityId
    SM.lastDetectedAt = now

    SM.saved.hungerTime = math.min(
        SM.saved.maxHungerTime,
        SM.saved.hungerTime + SM.saved.consumeBonus
    )

    if SM.saved.failed then
        SM.saved.failed = false
    end

    SM.UpdateDisplay()
end

local function MakeLabel(name, parent, x, y, w, h, text, scale)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    label:SetDimensions(w, h)
    label:SetFont("ZoFontWinH1")
    label:SetScale(scale)
    label:SetText(text)
    return label
end

local function ApplyTextScales()
    SM.title:SetScale(BASE_TITLE_SCALE * (SM.saved.titleScale / 100))
    SM.status:SetScale(BASE_STATUS_SCALE * (SM.saved.statusScale / 100))
    SM.hungerLabel:SetScale(BASE_HUNGER_LABEL_SCALE * (SM.saved.hungerLabelScale / 100))
    SM.hungerTimer:SetScale(BASE_HUNGER_TIMER_SCALE * (SM.saved.hungerTimerScale / 100))
    SM.rules:SetScale(BASE_RULES_SCALE * (SM.saved.rulesScale / 100))
end

local function ApplyColors()
    SM.bg:SetHidden(SM.saved.hideBackgroundBox)
    SM.bg:SetCenterColor(
        SM.saved.backgroundR,
        SM.saved.backgroundG,
        SM.saved.backgroundB,
        SM.saved.backgroundA
    )

    SM.title:SetColor(SM.saved.titleR, SM.saved.titleG, SM.saved.titleB, SM.saved.titleA)
    SM.rulesHeader:SetColor(SM.saved.rulesR, SM.saved.rulesG, SM.saved.rulesB, SM.saved.rulesA)
    SM.rules:SetColor(SM.saved.rulesR, SM.saved.rulesG, SM.saved.rulesB, SM.saved.rulesA)
end

local function ApplyHudLayout()
    local scale = SM.saved.hudScale / 100
    local baseWidth = 228
    local baseHeight = 228
    local ruleHeight = 0

    SM.inMenu = IsInMenu()

    SM.window:SetScale(scale)
    SM.window:ClearAnchors()
    SM.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SM.saved.hudX, SM.saved.hudY)

    SM.hungerTimer:ClearAnchors()
    SM.hungerTimer:SetAnchor(TOPLEFT, SM.window, TOPLEFT, SM.saved.timerXOffset, 140)

    if SM.saved.showRules then
        local ruleCount = #GetEnabledRules()
        ruleHeight = 45 + (ruleCount * 25)

        SM.rulesHeader:SetHidden(false)
        SM.rules:SetHidden(false)
        SM.rules:SetText(GetRulesText())
        SM.rules:SetDimensions(198, ruleHeight)
    else
        SM.rulesHeader:SetHidden(true)
        SM.rules:SetHidden(true)
    end

    local finalWidth = baseWidth * (SM.saved.boxWidthScale / 100)
    local finalHeight = (baseHeight + ruleHeight) * (SM.saved.boxHeightScale / 100)

    SM.window:SetDimensions(finalWidth, finalHeight)

    local shouldHide = not SM.saved.showHud

    if SM.saved.hideHudInMenus and SM.inMenu then
        shouldHide = true
    end

    SM.window:SetHidden(shouldHide)
end

function SM.UpdateDisplay()
    if not SM.window then return end

    ApplyHudLayout()
    ApplyTextScales()
    ApplyColors()

    if SM.saved.hungerTime <= 0 then
        SM.saved.failed = true
    end

    if SM.saved.failed then
        SM.status:SetText("FAILED")
        SM.status:SetColor(SM.saved.failedR, SM.saved.failedG, SM.saved.failedB, SM.saved.failedA)

        SM.hungerLabel:SetText("HUNGER:")
        SM.hungerLabel:SetColor(SM.saved.failedR, SM.saved.failedG, SM.saved.failedB, SM.saved.failedA)

        SM.hungerTimer:SetText(FormatTime(SM.saved.hungerTime))
        SM.hungerTimer:SetColor(SM.saved.failedR, SM.saved.failedG, SM.saved.failedB, SM.saved.failedA)

    elseif SM.saved.paused or (SM.saved.pauseTimerInMenus and SM.inMenu) then
        SM.status:SetText("PAUSED")
        SM.status:SetColor(SM.saved.pausedR, SM.saved.pausedG, SM.saved.pausedB, SM.saved.pausedA)

        SM.hungerLabel:SetText("HUNGER:")
        SM.hungerLabel:SetColor(SM.saved.hungerR, SM.saved.hungerG, SM.saved.hungerB, SM.saved.hungerA)

        SM.hungerTimer:SetText(FormatTime(SM.saved.hungerTime))
        SM.hungerTimer:SetColor(SM.saved.hungerR, SM.saved.hungerG, SM.saved.hungerB, SM.saved.hungerA)

    else
        SM.status:SetText("ACTIVE")
        SM.status:SetColor(SM.saved.activeR, SM.saved.activeG, SM.saved.activeB, SM.saved.activeA)

        SM.hungerLabel:SetText("HUNGER:")
        SM.hungerTimer:SetText(FormatTime(SM.saved.hungerTime))

        if SM.saved.hungerTime < SM.saved.lowWarningTime then
            SM.hungerLabel:SetColor(SM.saved.warningR, SM.saved.warningG, SM.saved.warningB, SM.saved.warningA)
            SM.hungerTimer:SetColor(SM.saved.warningR, SM.saved.warningG, SM.saved.warningB, SM.saved.warningA)
        else
            SM.hungerLabel:SetColor(SM.saved.hungerR, SM.saved.hungerG, SM.saved.hungerB, SM.saved.hungerA)
            SM.hungerTimer:SetColor(SM.saved.hungerR, SM.saved.hungerG, SM.saved.hungerB, SM.saved.hungerA)
        end
    end
end

local function OnTimer()
    local menuPaused = SM.saved.pauseTimerInMenus and IsInMenu()

    if not SM.saved.paused and not SM.saved.failed and not menuPaused then
        SM.saved.hungerTime = SM.saved.hungerTime - 1
    end

    SM.UpdateDisplay()
end

local function OnMenuWatcher()
    local nowInMenu = IsInMenu()

    if nowInMenu ~= SM.inMenu then
        SM.inMenu = nowInMenu
        SM.UpdateDisplay()
    end
end

local function IsLikelyConsumableBuff(beginTime, endTime)
    if not beginTime or not endTime then return false end
    return (endTime - beginTime) >= 1500
end

local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId)
    if unitTag ~= "player" then return end
    if changeType ~= EFFECT_RESULT_GAINED and changeType ~= EFFECT_RESULT_UPDATED then return end

    if SM.saved.paused and not SM.saved.allowHungerGainWhilePaused then return end
    if SM.saved.pauseTimerInMenus and IsInMenu() and not SM.saved.allowHungerGainWhilePaused then return end

    if IsLikelyConsumableBuff(beginTime, endTime) then
        AddHunger(abilityId)
    end
end

local function RegisterSceneCallbacks()
    if not SCENE_MANAGER or not SCENE_MANAGER.GetScene then return end

    local sceneNames = {
        "hud",
        "hudui",
        "gameMenuInGame",
        "inventory",
        "map",
        "skills",
        "character",
        "journal",
        "mail",
        "bank",
        "tradinghouse",
        "gamepad_main_menu",
        "gamepad_inventory_root",
        "gamepad_map_root",
        "gamepad_skills_root",
        "gamepad_character_root",
        "gamepad_journal_root",
    }

    for _, sceneName in ipairs(sceneNames) do
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if scene and scene.RegisterCallback then
            scene:RegisterCallback("StateChange", function()
                SM.UpdateDisplay()
            end)
        end
    end
end

local function CreateUI()
    SM.window = WINDOW_MANAGER:CreateTopLevelWindow("SurvivalModeWindow")
    SM.window:SetDimensions(228, 418)
    SM.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SM.saved.hudX, SM.saved.hudY)
    SM.window:SetHidden(not SM.saved.showHud)
    SM.window:SetDrawLayer(DL_OVERLAY)
    SM.window:SetDrawLevel(999)

    SM.bg = WINDOW_MANAGER:CreateControl("SurvivalModeBG", SM.window, CT_BACKDROP)
    SM.bg:SetAnchorFill(SM.window)
    SM.bg:SetEdgeColor(1, 1, 1, 1)

    SM.title = MakeLabel("SurvivalModeTitle", SM.window, 20, 20, 198, 51, "SURVIVALMODE", BASE_TITLE_SCALE)
    SM.status = MakeLabel("SurvivalModeStatus", SM.window, 20, 77, 198, 51, "ACTIVE", BASE_STATUS_SCALE)

    SM.hungerLabel = MakeLabel("SurvivalModeHungerLabel", SM.window, 20, 140, 95, 51, "HUNGER:", BASE_HUNGER_LABEL_SCALE)
    SM.hungerTimer = MakeLabel("SurvivalModeHungerTimer", SM.window, SM.saved.timerXOffset, 140, 100, 51, "60:00", BASE_HUNGER_TIMER_SCALE)

    SM.rulesHeader = MakeLabel("SurvivalModeRulesHeader", SM.window, 20, 210, 198, 43, "RULES:", 6.0)

    SM.rules = MakeLabel(
        "SurvivalModeRules",
        SM.window,
        20,
        248,
        198,
        170,
        GetRulesText(),
        BASE_RULES_SCALE
    )

    SM.UpdateDisplay()
end

local function AddRuleCheckbox(panel, label, tooltip, fieldName, defaultValue)
    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = label,
        tooltip = tooltip,
        getFunction = function()
            return SM.saved[fieldName]
        end,
        setFunction = function(value)
            SM.saved[fieldName] = value
            SM.UpdateDisplay()
        end,
        default = defaultValue,
    })
end

local function AddColorSetting(panel, label, tooltip, rKey, gKey, bKey, aKey)
    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_COLOR,
        label = label,
        tooltip = tooltip,
        getFunction = function()
            return SM.saved[rKey], SM.saved[gKey], SM.saved[bKey], SM.saved[aKey]
        end,
        setFunction = function(r, g, b, a)
            SM.saved[rKey] = r
            SM.saved[gKey] = g
            SM.saved[bKey] = b

            if a ~= nil then
                SM.saved[aKey] = a
            end

            SM.UpdateDisplay()
        end,
        default = {
            r = SM.defaults[rKey],
            g = SM.defaults[gKey],
            b = SM.defaults[bKey],
            a = SM.defaults[aKey],
        },
    })
end

local function AddScaleSlider(panel, label, tooltip, key)
    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = label,
        tooltip = tooltip,
        min = 50,
        max = 200,
        step = 5,
        unit = "%",
        getFunction = function()
            return SM.saved[key]
        end,
        setFunction = function(value)
            SM.saved[key] = value
            SM.UpdateDisplay()
        end,
        default = 100,
    })
end

local function CreateSettings()
    if not LibHarvensAddonSettings then return end

    local panel = LibHarvensAddonSettings:AddAddon("SurvivalMode", { allowDefaults = true })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Reset Challenge",
        buttonText = "Reset Challenge",
        tooltip = "Reset Hunger to full and clear the failed state.",
        clickHandler = ResetChallenge,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Pause Timer",
        tooltip = "Pause or resume the Hunger countdown.",
        getFunction = function() return SM.saved.paused end,
        setFunction = function(value)
            SM.saved.paused = value
            SM.UpdateDisplay()
        end,
        default = false,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Allow Hunger Gain While Paused",
        tooltip = "Allow food and drink consumables to add Hunger time even while the timer is paused.",
        getFunction = function() return SM.saved.allowHungerGainWhilePaused end,
        setFunction = function(value)
            SM.saved.allowHungerGainWhilePaused = value
            SM.UpdateDisplay()
        end,
        default = true,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Hide HUD While In Menus",
        tooltip = "Hide the SurvivalMode HUD while viewing game menus.",
        getFunction = function() return SM.saved.hideHudInMenus end,
        setFunction = function(value)
            SM.saved.hideHudInMenus = value
            SM.UpdateDisplay()
        end,
        default = true,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Pause Timer While In Menus",
        tooltip = "Pause the Hunger countdown while viewing game menus.",
        getFunction = function() return SM.saved.pauseTimerInMenus end,
        setFunction = function(value)
            SM.saved.pauseTimerInMenus = value
            SM.UpdateDisplay()
        end,
        default = false,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show HUD",
        tooltip = "Show or hide the SurvivalMode HUD.",
        getFunction = function() return SM.saved.showHud end,
        setFunction = function(value)
            SM.saved.showHud = value
            SM.UpdateDisplay()
        end,
        default = true,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Show Rules on HUD",
        tooltip = "Show or hide the listed challenge rules on the HUD.",
        getFunction = function() return SM.saved.showRules end,
        setFunction = function(value)
            SM.saved.showRules = value
            SM.UpdateDisplay()
        end,
        default = true,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "HUD Scale",
        tooltip = "Scale the entire SurvivalMode HUD.",
        min = 50,
        max = 150,
        step = 5,
        unit = "%",
        getFunction = function() return SM.saved.hudScale end,
        setFunction = function(value)
            SM.saved.hudScale = value
            SM.UpdateDisplay()
        end,
        default = 100,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "HUD X Position",
        tooltip = "Move the SurvivalMode HUD left or right.",
        min = 0,
        max = 1700,
        step = 10,
        getFunction = function() return SM.saved.hudX end,
        setFunction = function(value)
            SM.saved.hudX = value
            SM.UpdateDisplay()
        end,
        default = 80,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "HUD Y Position",
        tooltip = "Move the SurvivalMode HUD up or down.",
        min = 0,
        max = 900,
        step = 10,
        getFunction = function() return SM.saved.hudY end,
        setFunction = function(value)
            SM.saved.hudY = value
            SM.UpdateDisplay()
        end,
        default = 140,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Max Hunger Minutes",
        tooltip = "Maximum Hunger timer value.",
        min = 5,
        max = 120,
        step = 5,
        unit = " min",
        getFunction = function() return math.floor(SM.saved.maxHungerTime / 60) end,
        setFunction = function(value)
            SM.saved.maxHungerTime = value * 60
            SM.saved.hungerTime = math.min(SM.saved.hungerTime, SM.saved.maxHungerTime)
            SM.UpdateDisplay()
        end,
        default = 60,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Hunger Added Per Consumable",
        tooltip = "How many minutes are added when a long-duration consumable buff is detected.",
        min = 5,
        max = 60,
        step = 5,
        unit = " min",
        getFunction = function() return math.floor(SM.saved.consumeBonus / 60) end,
        setFunction = function(value)
            SM.saved.consumeBonus = value * 60
            SM.UpdateDisplay()
        end,
        default = 20,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Warning Threshold",
        tooltip = "Hunger turns the warning color below this many minutes.",
        min = 5,
        max = 45,
        step = 5,
        unit = " min",
        getFunction = function() return math.floor(SM.saved.lowWarningTime / 60) end,
        setFunction = function(value)
            SM.saved.lowWarningTime = value * 60
            SM.UpdateDisplay()
        end,
        default = 20,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Text, Scaling, and Color Settings",
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Reset Text, Scaling, and Color Settings",
        buttonText = "Reset Appearance",
        tooltip = "Restore HUD text colors, background options, box size, and text scale settings to their default values.",
        clickHandler = ResetVisualSettingsToDefault,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Hide Background Box",
        tooltip = "Hide the HUD background box so only text is shown.",
        getFunction = function() return SM.saved.hideBackgroundBox end,
        setFunction = function(value)
            SM.saved.hideBackgroundBox = value
            SM.UpdateDisplay()
        end,
        default = false,
    })

    AddScaleSlider(panel, "HUD Box Width", "Adjust only the HUD background box width without scaling the text.", "boxWidthScale")
    AddScaleSlider(panel, "HUD Box Height", "Adjust only the HUD background box height without scaling the text.", "boxHeightScale")

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Timer X Position",
        tooltip = "Move the timer left or right so it does not overlap the HUNGER label.",
        min = 90,
        max = 190,
        step = 5,
        getFunction = function() return SM.saved.timerXOffset end,
        setFunction = function(value)
            SM.saved.timerXOffset = value
            SM.UpdateDisplay()
        end,
        default = 138,
    })

    AddScaleSlider(panel, "Title Text Scale", "Scale the SurvivalMode title text without resizing the HUD box.", "titleScale")
    AddScaleSlider(panel, "Status Text Scale", "Scale the ACTIVE / FAILED / PAUSED status text without resizing the HUD box.", "statusScale")
    AddScaleSlider(panel, "Hunger Label Scale", "Scale only the HUNGER label text.", "hungerLabelScale")
    AddScaleSlider(panel, "Hunger Timer Scale", "Scale only the Hunger timer numbers.", "hungerTimerScale")
    AddScaleSlider(panel, "Rules Text Scale", "Scale the displayed challenge rules text without resizing the HUD box.", "rulesScale")

    AddColorSetting(panel, "HUD Background Color", "Change the HUD background color. Use the opacity slider below for transparency.", "backgroundR", "backgroundG", "backgroundB", "backgroundA")

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "HUD Background Opacity",
        tooltip = "Adjust HUD background opacity separately from the color picker.",
        min = 0,
        max = 100,
        step = 5,
        unit = "%",
        getFunction = function() return math.floor(SM.saved.backgroundA * 100) end,
        setFunction = function(value)
            SM.saved.backgroundA = value / 100
            SM.UpdateDisplay()
        end,
        default = 95,
    })

    AddColorSetting(panel, "Title Text Color", "Change the SurvivalMode title text color.", "titleR", "titleG", "titleB", "titleA")
    AddColorSetting(panel, "Active Status Color", "Change the ACTIVE status text color.", "activeR", "activeG", "activeB", "activeA")
    AddColorSetting(panel, "Paused Status Color", "Change the PAUSED status text color.", "pausedR", "pausedG", "pausedB", "pausedA")
    AddColorSetting(panel, "Normal Hunger Color", "Change the normal Hunger label and timer color.", "hungerR", "hungerG", "hungerB", "hungerA")
    AddColorSetting(panel, "Warning Hunger Color", "Change the Hunger text color below the warning threshold.", "warningR", "warningG", "warningB", "warningA")
    AddColorSetting(panel, "Failed Status Color", "Change the FAILED status and Hunger text color.", "failedR", "failedG", "failedB", "failedA")
    AddColorSetting(panel, "Rules Text Color", "Change the displayed challenge rules text color.", "rulesR", "rulesG", "rulesB", "rulesA")

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Challenge Rules",
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_DESCRIPTION,
        text = "These are personal challenge rules only. SurvivalMode displays them on the HUD but does not enforce them.",
    })

    AddRuleCheckbox(panel, "No Guild Traders", "Display the personal challenge rule: No guild traders.", "ruleGuildTraders", true)
    AddRuleCheckbox(panel, "No Player Trading", "Display the personal challenge rule: No player trading.", "rulePlayerTrading", true)
    AddRuleCheckbox(panel, "No Soul Gem Usage", "Display the personal challenge rule: No soul gem usage.", "ruleSoulGems", true)
    AddRuleCheckbox(panel, "No Wayshrines", "Display the personal challenge rule: No wayshrines.", "ruleWayshrines", true)
    AddRuleCheckbox(panel, "No Bank Withdrawals", "Display the personal challenge rule: No bank withdrawals.", "ruleBankWithdrawals", true)
    AddRuleCheckbox(panel, "No Transmuting", "Display the personal challenge rule: No transmuting.", "ruleTransmuting", true)

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Reset All Settings",
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Reset All Settings to Default",
        buttonText = "Reset All Settings",
        tooltip = "Restore all SurvivalMode settings to their default values.",
        clickHandler = ResetSettingsToDefault,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_DESCRIPTION,
        text = "Made by Tankiest Tank",
    })
end

local function Start()
    SM.saved = ZO_SavedVars:NewAccountWide("SurvivalModeSavedVars", 1, nil, SM.defaults)
    ApplyMissingDefaults()

    if not SM.window then
        CreateUI()
    end

    CreateSettings()
    RegisterSceneCallbacks()
    SM.UpdateDisplay()

    EVENT_MANAGER:RegisterForUpdate("SurvivalModeTimer", 1000, OnTimer)
    EVENT_MANAGER:RegisterForUpdate("SurvivalModeMenuWatcher", 100, OnMenuWatcher)
    EVENT_MANAGER:RegisterForEvent("SurvivalModeEffectChanged", EVENT_EFFECT_CHANGED, OnEffectChanged)
end

EVENT_MANAGER:RegisterForEvent("SurvivalModeStart", EVENT_PLAYER_ACTIVATED, Start)