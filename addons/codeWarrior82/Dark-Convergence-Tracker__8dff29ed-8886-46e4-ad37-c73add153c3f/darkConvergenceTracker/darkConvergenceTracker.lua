local appName = "darkConvergenceTracker"
local darkAbilityID = 159388
local timeRemaining = 0
local picPath = GetAbilityIcon(darkAbilityID)
local iconText = zo_iconTextFormat(picPath, 80, 80, " ")
local isLoaded = false
local isMenuOpen = false

darkConvergenceTracker = {}

darkConvergenceTracker.defaults = {
    trackDark = true,
    yAxisText = 930,
    xAxisText = 1420
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

--when UI opens
local function onMenuOpened()
	isMenuOpen = true
    dctrack:SetHidden(true)
end

--when UI closes
local function onMenuClosed()
	isMenuOpen = false
    if darkConvergenceTracker.savedVariables.trackDark then
        dctrack:SetHidden(false)
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
    dctrack:ClearAnchors()
    dctrack:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--change icon anchor to move text around the screen
local function setAnchorIcon(x, y)  
    dctrack:SetHidden(false)
	zo_callLater(function () if isMenuOpen == true then dctrack:SetHidden(true) end end, 2000)
    dctrack:ClearAnchors()
    dctrack:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--handle cooldown
local function processCooldown()

    local text
    if timeRemaining >= 10 then
        text = string.format(" %d", timeRemaining)
    else
        text = string.format("  %d", timeRemaining)
    end

    if timeRemaining > 0 then
        EVENT_MANAGER:RegisterForUpdate("darkUpdate", 1000, processCooldown)
        dctrackLabelMain:SetText(text)
    else
        EVENT_MANAGER:UnregisterForUpdate("darkUpdate")
        dctrackLabelMain:SetText("")
        timeRemaining = 24
    end

    timeRemaining = timeRemaining - 1
end

local function combatReport(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, 
    sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

    local nameTmp = GetUnitName("player")

    if isError then
        return
    end

    if nameTmp ~= cleanName(sourceName) or abilityId ~= darkAbilityID then
        return
    end

    timeRemaining = 24
    processCooldown()
end

--register for notifications about archdruid proc
local function registerAlerts()
    EVENT_MANAGER:RegisterForEvent("darkProc", EVENT_COMBAT_EVENT, combatReport)
    EVENT_MANAGER:AddFilterForEvent("darkProc", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, darkAbilityID)
end

--unregister for notifications about archdruid proc
local function unRegisterAlerts()
    EVENT_MANAGER:UnregisterForEvent("darkProc", EVENT_COMBAT_EVENT)
end

--setup options menu
local function createOptions()

    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "Dark Convergence Tracker",
        displayName = "Dark Convergence Tracker",
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
            name = "Track cooldown",
            tooltip = "Displays a timer that tracks the Dark Convergence cooldown.",
            getFunc = function()
                return darkConvergenceTracker.savedVariables.trackDark
            end,
            setFunc = function(value)
                darkConvergenceTracker.savedVariables.trackDark = value
                if not value then
                    unRegisterAlerts()
                    dctrack:SetHidden(true)
                else
                    registerAlerts()
                    dctrack:SetHidden(false)
                end
            end,
            default = darkConvergenceTracker.defaults.trackDark,
        },
        {
            type = "slider",
            name = "Icon and Text x Position",
            tooltip = "Adjust the left and right position of the on screen icon and timer text.",
            min = 0, max = 1700, step = 10,
            getFunc = function()
                return darkConvergenceTracker.savedVariables.xAxisText
            end,
            setFunc = function(value)
                darkConvergenceTracker.savedVariables.xAxisText = value
                setAnchorIcon(darkConvergenceTracker.savedVariables.xAxisText, darkConvergenceTracker.savedVariables.yAxisText)
            end,
            default = darkConvergenceTracker.defaults.xAxisText,
        },
        {
            type = "slider",
            name = "Icon and Text y Position",
            tooltip = "Adjust the up and down position of the on screen icon and timer text.",
            min = 0, max = 1000, step = 10,
            getFunc = function()
                return darkConvergenceTracker.savedVariables.yAxisText
            end,
            setFunc = function(value)
                darkConvergenceTracker.savedVariables.yAxisText = value
                setAnchorIcon(darkConvergenceTracker.savedVariables.xAxisText, darkConvergenceTracker.savedVariables.yAxisText)
            end,
            default = darkConvergenceTracker.defaults.yAxisText,
        },
        {
            type = "divider",
            height = 0,
            width = "full",
        }
    }

    LAM:RegisterAddonPanel("Dark Convergence Tracker", panelData)
    LAM:RegisterOptionControls("Dark Convergence Tracker", optionsData)
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
    darkConvergenceTracker.savedVariables = ZO_SavedVars:NewCharacterIdSettings("dctAddonVars", 1, "Settings", darkConvergenceTracker.defaults, GetUnitName("player"))

	--notify if tracking is disabled
	if not darkConvergenceTracker.savedVariables.trackDark then
		zo_callLater(function() printMessage("tracking disabled") end, 600)
	end

    --setup text field areas
    dctrack:SetMovable(true)
    dctrackIcon:SetFont("$(GAMEPAD_MEDIUM_FONT)|$(GP_54)|soft-shadow-thick")
    dctrackLabelMain:SetFont("$(GAMEPAD_BOLD_FONT)|$(GP_61)|soft-shadow-thick")
    dctrackLabelCorner:SetFont("$(GAMEPAD_BOLD_FONT)|$(GP_34)|soft-shadow-thick")
    dctrackIcon:SetText(iconText)
    dctrackLabelMain:SetText("")
    dctrackLabelMain:SetColor(255, 0, 0, 255)
    dctrackLabelCorner:SetText("")
    --dctrackLabelCorner:SetColor(255, 255, 0, 255)

    setAnchorStartupIcon(darkConvergenceTracker.savedVariables.xAxisText, darkConvergenceTracker.savedVariables.yAxisText)

    --register for combat alerts if tracking is enabled
    if darkConvergenceTracker.savedVariables.trackDark then
        registerAlerts()
        dctrack:SetHidden(false)
    else
        dctrack:SetHidden(true)
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
