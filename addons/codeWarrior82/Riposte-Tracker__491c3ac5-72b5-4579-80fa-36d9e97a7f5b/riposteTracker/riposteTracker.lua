local appName = "riposteTracker"
local riposteAbilityID = 60230
local timeRemaining = 0
local picPath = GetAbilityIcon(riposteAbilityID)
local iconText = zo_iconTextFormat(picPath, 80, 80, " ")
local isLoaded = false
local isMenuOpen = false
local trackingRiposte = false

riposteTracker = {}

riposteTracker.defaults = {
    trackRip = true,
    yAxisText = 930,
    xAxisText = 1400
}

--print message to chat box
local function printMessageTest(msg)
	local chat = LibChatMessage(appName, "MA")
	chat:Print(msg)
end

--clean player names
local function cleanName(str)
    return str:sub(1, -4)
end

--when UI opens
local function onMenuOpened()
	isMenuOpen = true
    riptrack:SetHidden(true)
end

--when UI closes
local function onMenuClosed()
	isMenuOpen = false
    if riposteTracker.savedVariables.trackRip then
        riptrack:SetHidden(false)
    end
end

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

--change archdruid anchor to move around the screen at app start
local function setAnchorStartupIcon(x, y)  
    riptrack:ClearAnchors()
    riptrack:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--change icon anchor to move text around the screen
local function setAnchorIcon(x, y)  
    riptrack:SetHidden(false)
	zo_callLater(function () if isMenuOpen == true then riptrack:SetHidden(true) end end, 2000)
    riptrack:ClearAnchors()
    riptrack:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--is buff active
local function buffActive()

    for i = 1, GetNumBuffs("player") do
        local buffName, timeStarted, timeEnding, _, stackCount, _, _, _, iconFilename, _, abilityId, _, _ = GetUnitBuffInfo("player", i)
        --local buffName, startTime, endTime, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, 
        --statusEffectType, abilityId, canClickOff, castByPlayer = GetBuffInfo("player", i)

        if abilityId == riposteAbilityID then
            timeRemaining = timeEnding - GetFrameTimeSeconds()
            return true
        end
    end
    return false
end

--handle if player has buff
local function processBuff()
    
    if buffActive() then

        trackingRiposte = true

        local text = ""

        text = string.format("  %d", timeRemaining)

        riptrackLabelMain:SetText(text)

        zo_callLater(function() processBuff() end, 1000)
    else
        trackingRiposte = false
        riptrackLabelMain:SetText("")
    end
end

--report when new effect is gained
local function effectReport(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, 
    effectType, abilityType, statusEffectType, unitName, unitID, abilityID)

    local nameTmp = GetUnitName("player")

    if nameTmp ~= cleanName(unitName) or abilityID ~= riposteAbilityID then
        return
    end

    if changeType == 2 then
        riptrackLabelMain:SetText("")
        trackingRiposte = false
        return
    end

    if not trackingRiposte then
        --timeRemaining = 5
        processBuff()
    end

end

--register for notifications about archdruid proc
local function registerAlerts()
    EVENT_MANAGER:RegisterForEvent("ripProc", EVENT_EFFECT_CHANGED, effectReport)
    EVENT_MANAGER:AddFilterForEvent("ripProc", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, riposteAbilityID)
end

--unregister for notifications about proc
local function unRegisterAlerts()
    EVENT_MANAGER:UnregisterForEvent("ripProc", EVENT_EFFECT_CHANGED)
end

--setup options menu
local function createOptions()

    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "Riposte Tracker",
        displayName = "Riposte Tracker",
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
            name = "Track buff and cooldown",
            tooltip = "Displays the current stack amount of Gorethief while Gorethief is active.",
            getFunc = function()
                return riposteTracker.savedVariables.trackRip
            end,
            setFunc = function(value)
                riposteTracker.savedVariables.trackRip = value
                if not value then
                    unRegisterAlerts()
                    riptrack:SetHidden(true)
                else
                    registerAlerts()
                    riptrack:SetHidden(false)
                end
            end,
            default = riposteTracker.defaults.trackRip,
        },
        {
            type = "slider",
            name = "Icon and Text x Position",
            tooltip = "Adjust the left and right position of the on screen icon and timer text.",
            min = 0, max = 1700, step = 10,
            getFunc = function()
                return riposteTracker.savedVariables.xAxisText
            end,
            setFunc = function(value)
                riposteTracker.savedVariables.xAxisText = value
                setAnchorIcon(riposteTracker.savedVariables.xAxisText, riposteTracker.savedVariables.yAxisText)
            end,
            default = riposteTracker.defaults.xAxisText,
        },
        {
            type = "slider",
            name = "Icon and Text y Position",
            tooltip = "Adjust the up and down position of the on screen icon and timer text.",
            min = 0, max = 1000, step = 10,
            getFunc = function()
                return riposteTracker.savedVariables.yAxisText
            end,
            setFunc = function(value)
                riposteTracker.savedVariables.yAxisText = value
                setAnchorIcon(riposteTracker.savedVariables.xAxisText, riposteTracker.savedVariables.yAxisText)
            end,
            default = riposteTracker.defaults.yAxisText,
        },
        {
            type = "divider",
            height = 0,
            width = "full",
        }
    }

    LAM:RegisterAddonPanel("Riposte Tracker", panelData)
    LAM:RegisterOptionControls("Riposte Tracker", optionsData)
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
	zo_callLater(function() printMessageTest("add-on loaded") end, 500)

	--load saved variables
    riposteTracker.savedVariables = ZO_SavedVars:NewCharacterIdSettings("ripAddonVars", 1, "Settings", riposteTracker.defaults, GetUnitName("player"))

	--notify if tracking is disabled
	if not riposteTracker.savedVariables.trackRip then
		zo_callLater(function() printMessageTest("tracking disabled") end, 600)
	end

    --setup text field areas
    riptrack:SetMovable(true)
    riptrackIcon:SetFont("$(GAMEPAD_MEDIUM_FONT)|$(GP_54)|soft-shadow-thick")
    riptrackLabelMain:SetFont("$(GAMEPAD_BOLD_FONT)|$(GP_61)|soft-shadow-thick")
    riptrackIcon:SetText(iconText)
    riptrackLabelMain:SetText("")
    --riptrackLabelMain:SetColor(255, 255, 0, 255)

    setAnchorStartupIcon(riposteTracker.savedVariables.xAxisText, riposteTracker.savedVariables.yAxisText)

    --register for combat alerts if tracking is enabled
    if riposteTracker.savedVariables.trackRip then
        registerAlerts()
        riptrack:SetHidden(false)
    else
        riptrack:SetHidden(true)
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
