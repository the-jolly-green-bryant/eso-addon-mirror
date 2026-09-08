local appName = "rallyingCryTracker"
local rallyingAbilityID = 166731
local timeRemaining = 0
local picPath = GetAbilityIcon(rallyingAbilityID)
local iconText = zo_iconTextFormat(picPath, 80, 80, " ")
local isLoaded = false
local isMenuOpen = false

rallyingCryTracker = {}

rallyingCryTracker.defaults = {
    trackRally = true,
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
    rctrack:SetHidden(true)
end

--when UI closes
local function onMenuClosed()
	isMenuOpen = false
    if rallyingCryTracker.savedVariables.trackRally then
        rctrack:SetHidden(false)
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
    rctrack:ClearAnchors()
    rctrack:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--change icon anchor to move text around the screen
local function setAnchorIcon(x, y)  
    rctrack:SetHidden(false)
	zo_callLater(function () if isMenuOpen == true then rctrack:SetHidden(true) end end, 2000)
    rctrack:ClearAnchors()
    rctrack:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--is buff active
local function buffActive()
    for i = 1, GetNumBuffs("player") do
        local buffName, timeStarted, timeEnding, _, _, _, _, _, iconFilename, _, abilityId, _, _ = GetUnitBuffInfo("player", i)
        
        if abilityId == rallyingAbilityID then
            timeRemaining = timeEnding - GetFrameTimeSeconds()
            return true
        end
    end
    return false
end

--handle if player has buff
local function processBuff()
    if buffActive() then

        local text = ""

        if timeRemaining >= 10 then
            text = string.format("%d", timeRemaining)
        else
            text = string.format(" %d", timeRemaining)
        end

        local time = timeRemaining - 5

        local textM = ""

        if time >= 10 then
            textM = string.format("%d", time)
        else
            textM = string.format(" %d", time)
        end

        if timeRemaining >= 0 then
            rctrackLabelMain:SetText(text)
        else
            rctrackLabelMain:SetText("")
        end

        if time >= 0 then
            rctrackLabelCorner:SetText(textM)
        else
            rctrackLabelCorner:SetText("")
        end

        zo_callLater(function() processBuff() end, 1000)
    else
        rctrackLabelMain:SetText("")
        rctrackLabelCorner:SetText("")
    end
end

--report when new effect is gained
local function effectReport(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, 
    effectType, abilityType, statusEffectType, unitName, unitID, abilityID)

    local nameTmp = GetUnitName("player")

    if nameTmp ~= cleanName(unitName) or changeType ~= 1 or abilityID ~= rallyingAbilityID then
        return
    end

    processBuff()

end

--register for notifications about archdruid proc
local function registerAlerts()
    EVENT_MANAGER:RegisterForEvent("rallyProc", EVENT_EFFECT_CHANGED, effectReport)
    EVENT_MANAGER:AddFilterForEvent("rallyProc", EVENT_EFFECT_CHANGED, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)--may need changing
    EVENT_MANAGER:AddFilterForEvent("rallyProc", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, rallyingAbilityID)
end

--unregister for notifications about archdruid proc
local function unRegisterAlerts()
    EVENT_MANAGER:UnregisterForEvent("rallyProc", EVENT_EFFECT_CHANGED)
end

--setup options menu
local function createOptions()

    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "Rallying Cry Tracker",
        displayName = "Rallying Cry Tracker",
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
            tooltip = "Displays a timer while the Rallying Cry buff is active.",
            getFunc = function()
                return rallyingCryTracker.savedVariables.trackRally
            end,
            setFunc = function(value)
                rallyingCryTracker.savedVariables.trackRally = value
                if not value then
                    unRegisterAlerts()
                    rctrack:SetHidden(true)
                else
                    registerAlerts()
                    rctrack:SetHidden(false)
                end
            end,
            default = rallyingCryTracker.defaults.trackRally,
        },
        {
            type = "slider",
            name = "Icon and Text x Position",
            tooltip = "Adjust the left and right position of the on screen icon and timer text.",
            min = 0, max = 1700, step = 10,
            getFunc = function()
                return rallyingCryTracker.savedVariables.xAxisText
            end,
            setFunc = function(value)
                rallyingCryTracker.savedVariables.xAxisText = value
                setAnchorIcon(rallyingCryTracker.savedVariables.xAxisText, rallyingCryTracker.savedVariables.yAxisText)
            end,
            default = rallyingCryTracker.defaults.xAxisText,
        },
        {
            type = "slider",
            name = "Icon and Text y Position",
            tooltip = "Adjust the up and down position of the on screen icon and timer text.",
            min = 0, max = 1000, step = 10,
            getFunc = function()
                return rallyingCryTracker.savedVariables.yAxisText
            end,
            setFunc = function(value)
                rallyingCryTracker.savedVariables.yAxisText = value
                setAnchorIcon(rallyingCryTracker.savedVariables.xAxisText, rallyingCryTracker.savedVariables.yAxisText)
            end,
            default = rallyingCryTracker.defaults.yAxisText,
        },
        {
            type = "divider",
            height = 0,
            width = "full",
        }
    }

    LAM:RegisterAddonPanel("Rallying Cry Tracker", panelData)
    LAM:RegisterOptionControls("Rallying Cry Tracker", optionsData)
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
	zo_callLater(function() printMessageTest("add-on successfully loaded") end, 500)

	--load saved variables
    rallyingCryTracker.savedVariables = ZO_SavedVars:NewCharacterIdSettings("rctAddonVars", 1, "Settings", rallyingCryTracker.defaults, GetUnitName("player"))

	--notify if tracking is disabled
	if not rallyingCryTracker.savedVariables.trackRally then
		zo_callLater(function() printMessageTest("tracking disabled") end, 600)
	end

    --setup text field areas
    rctrack:SetMovable(true)
    rctrackIcon:SetFont("$(GAMEPAD_MEDIUM_FONT)|$(GP_54)|soft-shadow-thick")
    rctrackLabelMain:SetFont("$(GAMEPAD_BOLD_FONT)|$(GP_54)|soft-shadow-thick")
    rctrackLabelCorner:SetFont("$(GAMEPAD_BOLD_FONT)|$(GP_34)|soft-shadow-thick")
    rctrackIcon:SetText(iconText)
    rctrackLabelMain:SetText("")
    --rctrackLabelMain:SetColor(255, 255, 0, 255)
    rctrackLabelCorner:SetText("")
    --rctrackLabelCorner:SetColor(255, 255, 0, 255)

    setAnchorStartupIcon(rallyingCryTracker.savedVariables.xAxisText, rallyingCryTracker.savedVariables.yAxisText)

    --register for combat alerts if tracking is enabled
    if rallyingCryTracker.savedVariables.trackRally then
        registerAlerts()
        rctrack:SetHidden(false)
    else
        rctrack:SetHidden(true)
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
