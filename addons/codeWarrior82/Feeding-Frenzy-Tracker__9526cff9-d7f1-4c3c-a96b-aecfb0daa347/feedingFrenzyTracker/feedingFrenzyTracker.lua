local appName = "feedingFrenzyTracker"
local frenzyAbilityID = 131353
local ferociousRoarAbilityID = 39113
local picPath = GetAbilityIcon(frenzyAbilityID)
local iconText = zo_iconTextFormat(picPath, 80, 80, " ")
local isLoaded = false
local isMenuOpen = false
local frenzyCooldown = 19
local courageTime = 20

feedingFrenzyTracker = {}

feedingFrenzyTracker.defaults = {
    trackFF = true,
    yAxisText = 930,
    xAxisText = 1400
}

--print message to chat box
local function printMessage(msg)
	local chat = LibChatMessage(appName, "MA")
	chat:Print(msg)
end

--clean player names
local function cleanName(str)
    return str:sub(1, -4)
end

local function processCourage()

    local text

    if courageTime > 9 then
        text = string.format("%d", courageTime)
    else
        text = string.format(" %d", courageTime)
    end

    if courageTime > 0 then
        EVENT_MANAGER:RegisterForUpdate("updateCourage", 1000, processCourage)
        ffAddonLabelCourage:SetText(text)
        courageTime = courageTime - 1
    else
        EVENT_MANAGER:UnregisterForUpdate("updateCourage")
        ffAddonLabelCourage:SetText("")
        courageTime = 19
    end
end

--handle combat alert
local function combatReportCourage(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, 
    sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

    --target type 0 = npc's / innocents / world adds / world bosses / dungeon adds / dungeon bosses / pvp guards
    --target type 3 = players
    --target type 4 = training dummies
    if isError then
        return
    end

    local nameTmp = GetUnitName("player")

    if nameTmp == cleanName(sourceName) then
        courageTime = 19
        processCourage()
    end

end

local function processFrenzy()

    local text

    if frenzyCooldown > 9 then
        text = string.format("%d", frenzyCooldown)
    else
        text = string.format(" %d", frenzyCooldown)
    end

    if frenzyCooldown > 0 then
        EVENT_MANAGER:RegisterForUpdate("updateFrenzy", 1000, processFrenzy)
        ffAddonLabelSynergy:SetText(text)
        frenzyCooldown = frenzyCooldown - 1
    else
        EVENT_MANAGER:UnregisterForUpdate("updateFrenzy")
        ffAddonLabelSynergy:SetText("")
        frenzyCooldown = 19
    end
end

local function combatReport(eventCode, changeType, effectSlot, effectName, unitTag,
    beginTime, endTimeParam, stackCount, iconNameParam, buffType, effectType,
    abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)

    if abilityId ~= frenzyAbilityID then return end

    local nameTmp = GetUnitName("player")

    --d(changeType)	 -- 1 is gained, 2 is gone, 3 is update

    if changeType == 1 then
        --gained frenzy, only first time using if no frenzy is active 
        return
    elseif changeType == 2 then
        --frenzy finished
        return
    elseif changeType == 3 and nameTmp == cleanName(unitName) then
        --here start 20 second timer that refreshes each time you
        frenzyCooldown = 19
        processFrenzy()
    else
        end

end

--when UI opens
local function onMenuOpened()
    if feedingFrenzyTracker.savedVariables.trackFF then
        isMenuOpen = true
        ffAddon:SetHidden(true)
    end
end

--when UI closes
local function onMenuClosed()
    if feedingFrenzyTracker.savedVariables.trackFF then
        isMenuOpen = false
        ffAddon:SetHidden(false)
    end
end

--menu has been opened
local function onSceneStateChange(scene, oldState, newState)
    if isLoaded then
        local sceneName = SCENE_MANAGER:GetCurrentScene():GetName()

        if sceneName == "hud" then
            if  newState == SCENE_HIDING then onMenuOpened()
            elseif  newState == SCENE_HIDDEN then onMenuClosed()
            end
        end
    end
end

--register for notifications 
local function registerAlerts()
    EVENT_MANAGER:RegisterForEvent("feedfrenzy", EVENT_EFFECT_CHANGED, combatReport)
    EVENT_MANAGER:AddFilterForEvent("feedfrenzy", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, frenzyAbilityID)
    EVENT_MANAGER:RegisterForEvent("courageBuff", EVENT_COMBAT_EVENT, combatReportCourage)
    EVENT_MANAGER:AddFilterForEvent("courageBuff", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, ferociousRoarAbilityID)
end

--unregister for notifications
local function unRegisterAlerts()
    EVENT_MANAGER:UnregisterForEvent("feedfrenzy", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent("courageBuff", EVENT_EFFECT_CHANGED)
end

--change icon anchor to move icon around the screen at app start
local function setAnchorStartupIcon(x, y)  
    ffAddon:ClearAnchors()
    ffAddon:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--change icon anchor to move text around the screen
local function setAnchorIcon(x, y)  
    ffAddon:SetHidden(false)
    zo_callLater(function () if isMenuOpen == true then ffAddon:SetHidden(true) end end, 2000)
    ffAddon:ClearAnchors()
    ffAddon:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--setup options menu
local function createOptions()

    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "Feeding Frenzy Tracker",
        displayName = "Feeding Frenzy Tracker",
        author = "codewarrior82",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "description",
            title = "Add-On Settings",
            width = "full",
        },
        {
            type = "divider",
            height = 0,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Track Buff",
            tooltip = "Displays a timer while the Ferocious Roar Major Courage buff is active and a smaller timer while the Feeding Frenzy synergy is on cooldown.",
            getFunc = function()
                return feedingFrenzyTracker.savedVariables.trackFF
            end,
            setFunc = function(value)
                feedingFrenzyTracker.savedVariables.trackFF = value
                if not value then
                    unRegisterAlerts()
                    ffAddon:SetHidden(true)
                else
                    registerAlerts()
                    ffAddon:SetHidden(false)
                end
            end,
            default = feedingFrenzyTracker.defaults.trackFF,
        },
        {
            type = "slider",
            name = "Icon and Text x Position",
            tooltip = "Adjust the left and right position of the on screen icon and timer text.",
            min = 0, max = 1700, step = 10,
            getFunc = function()
                return feedingFrenzyTracker.savedVariables.xAxisText
            end,
            setFunc = function(value)
                feedingFrenzyTracker.savedVariables.xAxisText = value
                setAnchorIcon(feedingFrenzyTracker.savedVariables.xAxisText, feedingFrenzyTracker.savedVariables.yAxisText)
            end,
            default = feedingFrenzyTracker.defaults.xAxisText,
        },
        {
            type = "slider",
            name = "Icon and Text y Position",
            tooltip = "Adjust the up and down position of the on screen icon and timer text.",
            min = 0, max = 1000, step = 10,
            getFunc = function()
                return feedingFrenzyTracker.savedVariables.yAxisText
            end,
            setFunc = function(value)
                feedingFrenzyTracker.savedVariables.yAxisText = value
                setAnchorIcon(feedingFrenzyTracker.savedVariables.xAxisText, feedingFrenzyTracker.savedVariables.yAxisText)
            end,
            default = feedingFrenzyTracker.defaults.yAxisText,
        },
        {
            type = "divider",
            height = 0,
            width = "full",
        }
    }

    LAM:RegisterAddonPanel("feed frenz Tracker", panelData)
    LAM:RegisterOptionControls("feed frenz Tracker", optionsData)
end

--an addon has loaded
local function onAddOnLoaded(event, name)

    --if add-on loaded was not this add-on quit
    if name ~= appName then
        return
    end

    --unregister for notifications of add-on loaded
    EVENT_MANAGER:UnregisterForEvent(appName, EVENT_ADD_ON_LOADED)

	--notify that add-on has been loaded
	zo_callLater(function() printMessage("add-on successfully loaded") end, 500)
	
	--load saved variables
    feedingFrenzyTracker.savedVariables = ZO_SavedVars:NewCharacterIdSettings("feedAddonVars", 1, "Settings", feedingFrenzyTracker.defaults, GetUnitName("player"))
	
	--notify if tracking is disabled
	if not feedingFrenzyTracker.savedVariables.trackFF then
		zo_callLater(function() printMessageTest("tracking disabled") end, 600)
	end

    --setup text field areas
    ffAddon:SetMovable(true)
    ffAddonIcon:SetFont("$(GAMEPAD_MEDIUM_FONT)|$(GP_54)|soft-shadow-thick")
    ffAddonLabelCourage:SetFont("$(GAMEPAD_BOLD_FONT)|$(GP_54)|soft-shadow-thick")
    ffAddonLabelSynergy:SetFont("$(GAMEPAD_BOLD_FONT)|$(GP_34)|soft-shadow-thick")
    ffAddonIcon:SetText(iconText)
    ffAddonLabelCourage:SetText("")
    ffAddonLabelSynergy:SetText("")

    setAnchorStartupIcon(feedingFrenzyTracker.savedVariables.xAxisText, feedingFrenzyTracker.savedVariables.yAxisText)

    --register for combat alerts if tracking is enabled
    if feedingFrenzyTracker.savedVariables.trackFF then
        registerAlerts()
        ffAddon:SetHidden(false)
    else
        ffAddon:SetHidden(true)
    end

    --register for notifications of menu or map opening
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", onSceneStateChange)

    --setup add on menu options
    createOptions()

    --set is loaded boolean for use later, to stop scene change hiding tracker icon at first load in
    zo_callLater(function () isLoaded = true end, 2000)
end

--register for notification that an addon has been loaded
EVENT_MANAGER:RegisterForEvent(appName, EVENT_ADD_ON_LOADED, onAddOnLoaded)