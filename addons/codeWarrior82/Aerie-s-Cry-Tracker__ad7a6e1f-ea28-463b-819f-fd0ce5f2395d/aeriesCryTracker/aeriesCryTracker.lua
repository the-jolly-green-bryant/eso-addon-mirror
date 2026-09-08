local appName = "aeriesCryTracker"
local aeriesAbilityID = 227605
local eaglesAbilityID = 226887
local timeRemaining = 0
local procTime = 12
local picPath = GetAbilityIcon(aeriesAbilityID)
local iconText = zo_iconTextFormat(picPath, 80, 80, " ")
local isLoaded = false
local isMenuOpen = false

aeriesCryTracker = {}

aeriesCryTracker.defaults = {
    trackAeries = true,
    trackEagles = true,
    yAxisTextAeries = 930,
    xAxisTextAeries = 1300,
    yAxisTextEagles = 500,
    xAxisTextEagles = 1100
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

--change aeries anchor to move around the screen at app start
local function setAnchorStartupIconAeries(x, y)  
    actrack:ClearAnchors()
    actrack:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--change aeries anchor to move around the screen at app start
local function setAnchorStartupIconEagles(x, y)  
    emtrack:ClearAnchors()
    emtrack:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--is buff active
local function buffActive()
    for i = 1, GetNumBuffs("player") do
        local buffName, timeStarted, timeEnding, _, _, _, _, _, iconFilename, _, abilityId, _, _ = GetUnitBuffInfo("player", i)
        
        if abilityId == aeriesAbilityID then
            timeRemaining = timeEnding - GetFrameTimeSeconds()
            return true
        end
    end
    return false
end

--handle if player has buff
local function processBuff()
    if buffActive() then

        local time = timeRemaining

        local text = ""

        if time >= 10 then
            text = string.format(" %d", time)
        else
            text = string.format("  %d", time)
        end

        if time > 0 then
            actrackLabelMain:SetText(text)
        else
            actrackLabelMain:SetText("")
        end

        zo_callLater(function() processBuff() end, 1000)
    else
        actrackLabelMain:SetText("")
    end
end

--report when new effect is gained
local function effectReport(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, 
    effectType, abilityType, statusEffectType, unitName, unitID, abilityID)

    local nameTmp = GetUnitName("player")

    --player lost buff so naturally there is no target
    if changeType == 2 then
        emtrackIcon:SetText("")
        return
    end

    if nameTmp ~= cleanName(unitName) or changeType ~= 1 or abilityID ~= aeriesAbilityID then
        return
    end

    processBuff()

end

local function combatReport(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, 
    sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

    --target type 0 = npc's / innocents / world adds / world bosses / dungeon adds / dungeon bosses / pvp guards
    --target type 3 = players
    --target type 4 = training dummies

    if isError then
        return
    end

    if result ~= 2240 then
        return
    end

    --display name
    if aeriesCryTracker.savedVariables.trackEagles then
        if targetType == 3 then
            emtrackIcon:SetText(zo_strformat("<<1>>", cleanName(targetName)))
        else
            emtrackIcon:SetText(zo_strformat("<<1>>", targetName))
        end
    end

end

--change aeries anchor to move text around the screen
local function setAnchorIconAeries(x, y)  
    actrack:SetHidden(false)
	zo_callLater(function () if isMenuOpen == true then actrack:SetHidden(true) end end, 2000)
    actrack:ClearAnchors()
    actrack:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--change eagles anchor to move text around the screen
local function setAnchorIconEagles(x, y)
    if not buffActive() then
        emtrackIcon:SetText("Target Name")
    end
    emtrack:SetHidden(false)
    zo_callLater(function () if isMenuOpen == true then emtrack:SetHidden(true) end end, 2000)
    emtrack:ClearAnchors()
    emtrack:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--when UI opens
local function onMenuOpened()
	isMenuOpen = true
    actrack:SetHidden(true)
    emtrack:SetHidden(true)
end

--when UI closes
local function onMenuClosed()
	isMenuOpen = false
    if aeriesCryTracker.savedVariables.trackAeries then
        actrack:SetHidden(false)
    end
    if aeriesCryTracker.savedVariables.trackEagles then
        emtrack:SetHidden(false)
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

--register for notifications about archdruid proc
local function registerAlerts()
    EVENT_MANAGER:RegisterForEvent("aeriesProc", EVENT_EFFECT_CHANGED, effectReport)
    EVENT_MANAGER:AddFilterForEvent("aeriesProc", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, aeriesAbilityID)

    EVENT_MANAGER:RegisterForEvent("eaglesProc", EVENT_COMBAT_EVENT, combatReport)
    EVENT_MANAGER:AddFilterForEvent("eaglesProc", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, eaglesAbilityID)
end

--unregister for notifications about archdruid proc
local function unRegisterAlerts()
    EVENT_MANAGER:UnregisterForEvent("aeriesProc", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent("eaglesProc", EVENT_COMBAT_EVENT)
end

--setup options menu
local function createOptions()

    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "Aeries Cry Tracker",
        displayName = "Aeries Cry Tracker",
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
            tooltip = "Displays a timer while the Aerie's Call buff is active.",
            getFunc = function()
                return aeriesCryTracker.savedVariables.trackAeries
            end,
            setFunc = function(value)
                aeriesCryTracker.savedVariables.trackAeries = value
                aeriesCryTracker.savedVariables.trackEagles = value
                if not value then
                    unRegisterAlerts()
                    actrack:SetHidden(true)
                    emtrack:SetHidden(true)
                else
                    registerAlerts()
                    actrack:SetHidden(false)
                    emtrack:SetHidden(false)
                end
            end,
            default = aeriesCryTracker.defaults.trackAeries,
        },
        {
            type = "slider",
            name = "Icon and Text x Position",
            tooltip = "Adjust the left and right position of the on screen icon and timer text.",
            min = 0, max = 1700, step = 10,
            getFunc = function()
                return aeriesCryTracker.savedVariables.xAxisTextAeries
            end,
            setFunc = function(value)
                aeriesCryTracker.savedVariables.xAxisTextAeries = value
                setAnchorIconAeries(aeriesCryTracker.savedVariables.xAxisTextAeries, aeriesCryTracker.savedVariables.yAxisTextAeries)
            end,
            default = aeriesCryTracker.defaults.xAxisTextAeries,
        },
        {
            type = "slider",
            name = "Icon and Text y Position",
            tooltip = "Adjust the up and down position of the on screen icon and timer text.",
            min = 0, max = 1000, step = 10,
            getFunc = function()
                return aeriesCryTracker.savedVariables.yAxisTextAeries
            end,
            setFunc = function(value)
                aeriesCryTracker.savedVariables.yAxisTextAeries = value
                setAnchorIconAeries(aeriesCryTracker.savedVariables.xAxisTextAeries, aeriesCryTracker.savedVariables.yAxisTextAeries)
            end,
            default = aeriesCryTracker.defaults.yAxisTextAeries,
        },
        {
            type = "checkbox",
            name = "Track Eagle's Mark",
            tooltip = "Displays text with the name of the target that has Eagle's Mark applied to them.",
            getFunc = function()
                return aeriesCryTracker.savedVariables.trackEagles
            end,
            setFunc = function(value)
                aeriesCryTracker.savedVariables.trackEagles = value
                if not value then
                    --unRegisterAlertsEagles()
                    emtrack:SetHidden(true)
                else
                    --registerAlertsEagles()
                    emtrack:SetText("")
                    emtrack:SetHidden(true)
                end
            end,
            default = aeriesCryTracker.defaults.trackEagles,
        },
        {
            type = "slider",
            name = "Icon and Text x Position",
            tooltip = "Adjust the left and right position of the on screen text.",
            min = 0, max = 1700, step = 10,
            getFunc = function()
                return aeriesCryTracker.savedVariables.xAxisTextEagles
            end,
            setFunc = function(value)
                aeriesCryTracker.savedVariables.xAxisTextEagles = value
                setAnchorIconEagles(aeriesCryTracker.savedVariables.xAxisTextEagles, aeriesCryTracker.savedVariables.yAxisTextEagles)
            end,
            default = aeriesCryTracker.defaults.xAxisTextEagles,
        },
        {
            type = "slider",
            name = "Icon and Text y Position",
            tooltip = "Adjust the up and down position of the on screen text.",
            min = 0, max = 1000, step = 10,
            getFunc = function()
                return aeriesCryTracker.savedVariables.yAxisTextEagles
            end,
            setFunc = function(value)
                aeriesCryTracker.savedVariables.yAxisTextEagles = value
                setAnchorIconEagles(aeriesCryTracker.savedVariables.xAxisTextEagles, aeriesCryTracker.savedVariables.yAxisTextEagles)
            end,
            default = aeriesCryTracker.defaults.yAxisTextEagles,
        },
        {
            type = "divider",
            height = 0,
            width = "full",
        }
    }

    LAM:RegisterAddonPanel("Aeries Cry Tracker", panelData)
    LAM:RegisterOptionControls("Aeries Cry Tracker", optionsData)
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
    aeriesCryTracker.savedVariables = ZO_SavedVars:NewCharacterIdSettings("aeriesAddonVars", 1, "Settings", aeriesCryTracker.defaults, GetUnitName("player"))

	--notify if tracking is disabled
	if not aeriesCryTracker.savedVariables.trackAeries then
		zo_callLater(function() printMessage("tracking disabled") end, 600)
	end

    --setup text field areas
    actrack:SetMovable(true)
    actrackIcon:SetFont("$(GAMEPAD_MEDIUM_FONT)|$(GP_54)|soft-shadow-thick")
    actrackLabelMain:SetFont("$(GAMEPAD_BOLD_FONT)|$(GP_54)|soft-shadow-thick")
    actrackIcon:SetText(iconText)
    actrackLabelMain:SetText("")
    actrackLabelMain:SetColor(255, 255, 0, 255)

    setAnchorStartupIconAeries(aeriesCryTracker.savedVariables.xAxisTextAeries, aeriesCryTracker.savedVariables.yAxisTextAeries)

    emtrack:SetMovable(true)
    emtrackIcon:SetFont("$(GAMEPAD_MEDIUM_FONT)|$(GP_54)|soft-shadow-thick")
    emtrackIcon:SetText("")
    emtrackIcon:SetColor(0, 255, 0, 255)

    setAnchorStartupIconEagles(aeriesCryTracker.savedVariables.xAxisTextEagles, aeriesCryTracker.savedVariables.yAxisTextEagles)

    --register for combat alerts if tracking is enabled for aeries call
    if aeriesCryTracker.savedVariables.trackAeries then
        registerAlerts()
        actrack:SetHidden(false)
    else
        actrack:SetHidden(true)
    end

    --register for combat alerts if tracking is enabled for eagles mark
    if aeriesCryTracker.savedVariables.trackEagles then
        emtrack:SetHidden(false)
    else
        emtrack:SetHidden(true)
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
