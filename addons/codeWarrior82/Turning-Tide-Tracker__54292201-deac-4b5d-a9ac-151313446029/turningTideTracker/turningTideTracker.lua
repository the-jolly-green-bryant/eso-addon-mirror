local appName = "turningTideTracker"
local flowingWaterID = 167350
--167061 id for major vuln from turning tide
local picPath = GetAbilityIcon(flowingWaterID)
local iconText = zo_iconTextFormat(picPath, 80, 80, " ")
local isLoaded = false
local procTime = 15
local vulnTime = 10
local isMenuOpen = false

turningTideTracker = {}

turningTideTracker.defaults = {
    trackTurn = true,
    trackVuln = true,--change to false for release
    yAxisText = 930,
    xAxisText = 1300
}

turningTideTracker.majorEffects = {
-- Major Vulnerability
	[106754] = true,
	[106755] = true,
	[106758] = true,
	[106760] = true,
	[106762] = true,
	[122177] = true,
	[122397] = true,
	[122389] = true,
    [132831] = true,
    [148976] = true,
	[163060] = true,
	[167061] = true,
	[176815] = true,
	[195242] = true,
	[192836] = true,
	[226400] = true,
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

--is debuff major
local function isVulnActive(abilityID)
	return turningTideTracker.majorEffects[abilityID]
end

local function processFlowingWater()

    local text 
    if procTime > 9 then
        text = string.format("%d", procTime)
    else
        text = string.format("  %d", procTime)
    end

    if procTime > 5 then
        ttAddonTextLabelTime:SetColor(0, 255, 0, 255)
    else
        ttAddonTextLabelTime:SetColor(255, 0, 0, 255)
    end

    if procTime > 0 then   
        EVENT_MANAGER:RegisterForUpdate("turningFlowUpdate", 1000, processFlowingWater)
        ttAddonTextLabelTime:SetText(text)
        procTime = procTime - 1
    else
        EVENT_MANAGER:UnregisterForUpdate("turningFlowUpdate")
        ttAddonTextLabelTime:SetText("")
        procTime = 15
    end

end

local function processVuln()
   
    local text 
    local textTime 
    if vulnTime > 9 then
        text = string.format("%d", vulnTime)
    else
        text = string.format(" %d", vulnTime)
    end

    if vulnTime > 0 then   
        EVENT_MANAGER:RegisterForUpdate("turnUpdateVuln", 1000, processVuln)
        ttAddonTextLabelVuln:SetText(text)
        vulnTime = vulnTime - 1
    else
        EVENT_MANAGER:UnregisterForUpdate("turnUpdateVuln")
        ttAddonTextLabelVuln:SetText("")
        vulnTime = 10
    end

end

--handle combat alert major vulnerability
local function combatReportVuln(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, 
    sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

    if isError then
        return
    end

    local nameTmp = GetUnitName("player")

    if(isVulnActive(abilityId) and nameTmp == cleanName(sourceName)) then
        if hitValue == 1 and turningTideTracker.savedVariables.trackVuln then
            vulnTime = 10
            processVuln()
        end
    end

end

--handle combat alert
local function combatReport(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, 
    sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    
    --target type 0 = npc's / innocents / world adds / world bosses / dungeon adds / dungeon bosses / pvp guards
    --target type 3 = players
    --target type 4 = training dummies
    if isError then
        return
    end

    local nameTmp = GetUnitName("player")

    if(abilityId == flowingWaterID) then
        processFlowingWater()
    end
end

--register for notifications about turning tide vulnerability proc
local function registerAlertsVuln()
    EVENT_MANAGER:RegisterForEvent("turnVulnDebuff", EVENT_COMBAT_EVENT, combatReportVuln)
    EVENT_MANAGER:AddFilterForEvent("turnVulnDebuff", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 167061)--major vulnerability abilityId
end

--unregister for notifications about archdruid vulnerability proc
local function unRegisterAlertsVuln()
    EVENT_MANAGER:UnregisterForEvent("turnVulnDebuff", EVENT_COMBAT_EVENT)
end

--register for notifications about turning tide proc
local function registerAlerts()
    EVENT_MANAGER:RegisterForEvent("turnDebuff", EVENT_COMBAT_EVENT, combatReport)
    EVENT_MANAGER:AddFilterForEvent("turnDebuff", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
    EVENT_MANAGER:AddFilterForEvent("turnDebuff", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, flowingWaterID)
end

--unregister for notifications about turning tide proc
local function unRegisterAlerts()
    EVENT_MANAGER:UnregisterForEvent("turnDebuff", EVENT_COMBAT_EVENT)
end

--when UI opens
local function onMenuOpened()
	isMenuOpen = true
    ttAddonText:SetHidden(true)
end

--when UI closes
local function onMenuClosed()
	isMenuOpen = false
    if turningTideTracker.savedVariables.trackTurn then
        ttAddonText:SetHidden(false)
    end
end

--change archdruid anchor to move around the screen at app start
local function setAnchorStartupIcon(x, y)  
    ttAddonText:ClearAnchors()
    ttAddonText:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--change icon anchor to move text around the screen
local function setAnchorIcon(x, y)  
    ttAddonText:SetHidden(false)
	zo_callLater(function () if isMenuOpen == true then ttAddonText:SetHidden(true) end end, 2000)
    ttAddonText:ClearAnchors()
    ttAddonText:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--setup options menu
local function createOptions()

    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "Turning Tide Tracker",
        displayName = "Turning Tide Tracker",
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
            name = "Track Buff and Cooldown",
            tooltip = "Displays a timer while the Flowing Water buff is active.",
            getFunc = function()
                return turningTideTracker.savedVariables.trackTurn
            end,
            setFunc = function(value)
                turningTideTracker.savedVariables.trackTurn = value
                turningTideTracker.savedVariables.trackVuln = value
                if not value then
                    unRegisterAlerts()
                else
                    registerAlerts()
                end
            end,
            default = turningTideTracker.defaults.trackTurn,
        },
        {
            type = "checkbox",
            name = "Track Debuff",
            tooltip = "Displays a timer that tracks the Turning Tide Major Vulnerability debuff.",
            getFunc = function()
                return turningTideTracker.savedVariables.trackVuln
            end,
            setFunc = function(value)
                turningTideTracker.savedVariables.trackVuln = value
            end,
            default = turningTideTracker.defaults.trackVuln,
        },
        {
            type = "slider",
            name = "Icon and Text x Position",
            tooltip = "Adjust the left and right position of the on screen icon and timer text.",
            min = 0, max = 1700, step = 10,
            getFunc = function()
                return turningTideTracker.savedVariables.xAxisText
            end,
            setFunc = function(value)
                turningTideTracker.savedVariables.xAxisText = value
                setAnchorIcon(turningTideTracker.savedVariables.xAxisText, turningTideTracker.savedVariables.yAxisText)
            end,
            default = turningTideTracker.defaults.xAxisText,
        },
        {
            type = "slider",
            name = "Icon and Text y Position",
            tooltip = "Adjust the up and down position of the on screen icon and timer text.",
            min = 0, max = 1000, step = 10,
            getFunc = function()
                return turningTideTracker.savedVariables.yAxisText
            end,
            setFunc = function(value)
                turningTideTracker.savedVariables.yAxisText = value
                setAnchorIcon(turningTideTracker.savedVariables.xAxisText, turningTideTracker.savedVariables.yAxisText)
            end,
            default = turningTideTracker.defaults.yAxisText,
        },
        {
            type = "divider",
            height = 0,
            width = "full",
        }
    }

    LAM:RegisterAddonPanel("Turning Tide Tracker", panelData)
    LAM:RegisterOptionControls("Turning Tide Tracker", optionsData)
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

	--notify if tracking is disabled
	if not turningTideTracker.savedVariables.trackTurn then
		zo_callLater(function() printMessageTest("tracking disabled") end, 600)
	end

    --load saved variables
    turningTideTracker.savedVariables = ZO_SavedVars:NewCharacterIdSettings("turnAddonVars", 1, "Settings", turningTideTracker.defaults, GetUnitName("player"))

    --setup text field areas
    ttAddonText:SetMovable(true)
    ttAddonTextIcon:SetFont("$(GAMEPAD_MEDIUM_FONT)|$(GP_54)|soft-shadow-thick")
    ttAddonTextLabelTime:SetFont("$(GAMEPAD_BOLD_FONT)|$(GP_54)|soft-shadow-thick")
    ttAddonTextLabelVuln:SetFont("$(GAMEPAD_BOLD_FONT)|$(GP_34)|soft-shadow-thick")
    ttAddonTextIcon:SetText(iconText)
    ttAddonTextLabelTime:SetText("")
    ttAddonTextLabelVuln:SetText("")
    --ttAddonTextLabelVuln:SetColor(0, 255, 0, 255)

    setAnchorStartupIcon(turningTideTracker.savedVariables.xAxisText, turningTideTracker.savedVariables.yAxisText)

    --register for combat alerts if tracking is enabled
    if turningTideTracker.savedVariables.trackTurn then
        registerAlerts()
        ttAddonText:SetHidden(false)
    else
        ttAddonText:SetHidden(true)
    end

    --register for combat alerts if tracking is enabled for major vulnerability
    if turningTideTracker.savedVariables.trackVuln then
        registerAlertsVuln()
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

