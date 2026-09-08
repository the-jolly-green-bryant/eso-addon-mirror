local appName = "gorethiefTracker"
local gorethiefAbilityID = 260047
local timeRemaining = 0
local picPath = GetAbilityIcon(gorethiefAbilityID)
local iconText = zo_iconTextFormat(picPath, 80, 80, " ")
local isLoaded = false
local isMenuOpen = false

gorethiefTracker = {}

gorethiefTracker.defaults = {
    trackGore = true,
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
    gttrack:SetHidden(true)
end

--when UI closes
local function onMenuClosed()
	isMenuOpen = false
    if gorethiefTracker.savedVariables.trackGore then
        gttrack:SetHidden(false)
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
    gttrack:ClearAnchors()
    gttrack:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--change icon anchor to move text around the screen
local function setAnchorIcon(x, y)  
    gttrack:SetHidden(false)
	zo_callLater(function () if isMenuOpen == true then gttrack:SetHidden(true) end end, 2000)
    gttrack:ClearAnchors()
    gttrack:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--report when new effect is gained
local function effectReport(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, 
    effectType, abilityType, statusEffectType, unitName, unitID, abilityID)

    local nameTmp = GetUnitName("player")

    if nameTmp ~= cleanName(unitName) or abilityID ~= gorethiefAbilityID then
        return
    end

    if changeType == 2 then
        gttrackLabelMain:SetText("")
        return
    end

    local text = ""

    if stackCount == 10 then
        text = string.format(" %d", stackCount)
    else
        text = string.format("  %d", stackCount)
    end
    gttrackLabelMain:SetText(text)

end

--register for notifications about archdruid proc
local function registerAlerts()
    EVENT_MANAGER:RegisterForEvent("goreProc", EVENT_EFFECT_CHANGED, effectReport)
    EVENT_MANAGER:AddFilterForEvent("goreProc", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, gorethiefAbilityID)
end

--unregister for notifications about archdruid proc
local function unRegisterAlerts()
    EVENT_MANAGER:UnregisterForEvent("goreProc", EVENT_EFFECT_CHANGED)
end

--setup options menu
local function createOptions()

    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "Gorethief Tracker",
        displayName = "Gorethief Tracker",
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
                return gorethiefTracker.savedVariables.trackGore
            end,
            setFunc = function(value)
                gorethiefTracker.savedVariables.trackGore = value
                if not value then
                    unRegisterAlerts()
                    gttrack:SetHidden(true)
                else
                    registerAlerts()
                    gttrack:SetHidden(false)
                end
            end,
            default = gorethiefTracker.defaults.trackGore,
        },
        {
            type = "slider",
            name = "Icon and Text x Position",
            tooltip = "Adjust the left and right position of the on screen icon and timer text.",
            min = 0, max = 1700, step = 10,
            getFunc = function()
                return gorethiefTracker.savedVariables.xAxisText
            end,
            setFunc = function(value)
                gorethiefTracker.savedVariables.xAxisText = value
                setAnchorIcon(gorethiefTracker.savedVariables.xAxisText, gorethiefTracker.savedVariables.yAxisText)
            end,
            default = gorethiefTracker.defaults.xAxisText,
        },
        {
            type = "slider",
            name = "Icon and Text y Position",
            tooltip = "Adjust the up and down position of the on screen icon and timer text.",
            min = 0, max = 1000, step = 10,
            getFunc = function()
                return gorethiefTracker.savedVariables.yAxisText
            end,
            setFunc = function(value)
                gorethiefTracker.savedVariables.yAxisText = value
                setAnchorIcon(gorethiefTracker.savedVariables.xAxisText, gorethiefTracker.savedVariables.yAxisText)
            end,
            default = gorethiefTracker.defaults.yAxisText,
        },
        {
            type = "divider",
            height = 0,
            width = "full",
        }
    }

    LAM:RegisterAddonPanel("Gorethief Tracker", panelData)
    LAM:RegisterOptionControls("Gorethief Tracker", optionsData)
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
    gorethiefTracker.savedVariables = ZO_SavedVars:NewCharacterIdSettings("gttAddonVars", 1, "Settings", gorethiefTracker.defaults, GetUnitName("player"))

	--notify if tracking is disabled
	if not gorethiefTracker.savedVariables.trackGore then
		zo_callLater(function() printMessageTest("tracking disabled") end, 600)
	end

    --setup text field areas
    gttrack:SetMovable(true)
    gttrackIcon:SetFont("$(GAMEPAD_MEDIUM_FONT)|$(GP_54)|soft-shadow-thick")
    gttrackLabelMain:SetFont("$(GAMEPAD_BOLD_FONT)|$(GP_54)|soft-shadow-thick")
    gttrackIcon:SetText(iconText)
    gttrackLabelMain:SetText("")
    --rctrackLabelMain:SetColor(255, 255, 0, 255)

    setAnchorStartupIcon(gorethiefTracker.savedVariables.xAxisText, gorethiefTracker.savedVariables.yAxisText)

    --register for combat alerts if tracking is enabled
    if gorethiefTracker.savedVariables.trackGore then
        registerAlerts()
        gttrack:SetHidden(false)
    else
        gttrack:SetHidden(true)
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
