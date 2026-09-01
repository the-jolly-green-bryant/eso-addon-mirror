local appName = "archdruidTracker"
local bearProcID = 176813
local timeRemaining = 0
local picPath = GetAbilityIcon(bearProcID)
local iconText = zo_iconTextFormat(picPath, 80, 80, " ")
local isLoaded = false
local procTime = 15
local vulnTime = 7
local isMenuOpen = false

archdruidTracker = {}

archdruidTracker.defaults = {
    trackArch = true,
    trackVuln = false,
    yAxisText = 930,
    xAxisText = 1300
}

archdruidTracker.majorEffects = {
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
local function printMessageTest(msg)
	local chat = LibChatMessage(appName, "MA")
	chat:Print(msg)
end

--clean player names
local function cleanName(str)
    return str:sub(1, -4)
end

--is debuff major
local function isVulnActive(abilityID)
	return archdruidTracker.majorEffects[abilityID]
end

local function processProc()

    local text 
    if procTime > 9 then
        text = string.format(" %d", procTime)
    else
        text = string.format("  %d", procTime)
    end

    if procTime >= 0 then   
        EVENT_MANAGER:RegisterForUpdate("archdruidUpdate", 1000, processProc)
        archAddonTextLabelTime:SetText(text)
    else
        EVENT_MANAGER:UnregisterForUpdate("archdruidUpdate")
        archAddonTextLabelTime:SetText("")
        procTime = 15
    end

    procTime = procTime - 1
end

local function processVuln()

    local text = string.format("%d", vulnTime)
       
    if vulnTime >= 0 then   
        EVENT_MANAGER:RegisterForUpdate("archdruidUpdateVuln", 1000, processVuln)
        archAddonTextLabelVuln:SetText(text)
    else
        EVENT_MANAGER:UnregisterForUpdate("archdruidUpdateVuln")
        archAddonTextLabelVuln:SetText("")
        vulnTime = 7
    end

    vulnTime = vulnTime - 1
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

    --was player who procced archdruid
    if(abilityId == bearProcID and nameTmp == cleanName(sourceName)) then
        processProc()
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
        if hitValue == 1 and archdruidTracker.savedVariables.trackVuln then 
            processVuln() 
        end
    end

end

--register for notifications about archdruid vulnerability proc
local function registerAlertsVuln()
    EVENT_MANAGER:RegisterForEvent("archVulnDebuff", EVENT_COMBAT_EVENT, combatReportVuln)
end

--unregister for notifications about archdruid vulnerability proc
local function unRegisterAlertsVuln()
    EVENT_MANAGER:UnregisterForEvent("archVulnDebuff", EVENT_COMBAT_EVENT)
end

--register for notifications about archdruid proc
local function registerAlerts()
    EVENT_MANAGER:RegisterForEvent("archDebuff", EVENT_COMBAT_EVENT, combatReport)
    EVENT_MANAGER:AddFilterForEvent("archDebuff", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
    EVENT_MANAGER:AddFilterForEvent("archDebuff", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, bearProcID)
end

--unregister for notifications about archdruid proc
local function unRegisterAlerts()
    EVENT_MANAGER:UnregisterForEvent("archDebuff", EVENT_COMBAT_EVENT)
end

--when UI opens
local function onMenuOpened()
	isMenuOpen = true
    archAddonText:SetHidden(true)
end

--when UI closes
local function onMenuClosed()
	isMenuOpen = false
    if archdruidTracker.savedVariables.trackArch then
        archAddonText:SetHidden(false)
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
    archAddonText:ClearAnchors()
    archAddonText:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--change icon anchor to move text around the screen
local function setAnchorIcon(x, y)  
    archAddonText:SetHidden(false)
	zo_callLater(function () if isMenuOpen == true then archAddonText:SetHidden(true) end end, 2000)
    archAddonText:ClearAnchors()
    archAddonText:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--setup options menu
local function createOptions()

    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "Archdruid Tracker",
        displayName = "Archdruid Tracker",
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
            name = "Track Cooldown",
            tooltip = "Displays a timer while the Archdruid cooldown is active.",
            getFunc = function()
                return archdruidTracker.savedVariables.trackArch
            end,
            setFunc = function(value)
                archdruidTracker.savedVariables.trackArch = value
                archdruidTracker.savedVariables.trackVuln = value
                if not value then
                    unRegisterAlerts()
                else
                    registerAlerts()
                end
            end,
            default = archdruidTracker.defaults.trackArch,
        },
        {
            type = "checkbox",
            name = "Track Debuff",
            tooltip = "Displays a smaller timer that tracks the Archdruid Major Vulnerability debuff.",
            getFunc = function()
                return archdruidTracker.savedVariables.trackVuln
            end,
            setFunc = function(value)
                archdruidTracker.savedVariables.trackVuln = value
            end,
            default = archdruidTracker.defaults.trackVuln,
        },
        {
            type = "slider",
            name = "Icon and Text x Position",
            tooltip = "Adjust the left and right position of the on screen icon and timer text.",
            min = 0, max = 1700, step = 10,
            getFunc = function()
                return archdruidTracker.savedVariables.xAxisText
            end,
            setFunc = function(value)
                archdruidTracker.savedVariables.xAxisText = value
                setAnchorIcon(archdruidTracker.savedVariables.xAxisText, archdruidTracker.savedVariables.yAxisText)
            end,
            default = archdruidTracker.defaults.xAxisText,
        },
        {
            type = "slider",
            name = "Icon and Text y Position",
            tooltip = "Adjust the up and down position of the on screen icon and timer text.",
            min = 0, max = 1000, step = 10,
            getFunc = function()
                return archdruidTracker.savedVariables.yAxisText
            end,
            setFunc = function(value)
                archdruidTracker.savedVariables.yAxisText = value
                setAnchorIcon(archdruidTracker.savedVariables.xAxisText, archdruidTracker.savedVariables.yAxisText)
            end,
            default = archdruidTracker.defaults.yAxisText,
        },
        {
            type = "divider",
            height = 0,
            width = "full",
        }
    }

    LAM:RegisterAddonPanel("Archdruid Tracker", panelData)
    LAM:RegisterOptionControls("Archdruid Tracker", optionsData)
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
    archdruidTracker.savedVariables = ZO_SavedVars:NewCharacterIdSettings("adtAddonVars", 1, "Settings", archdruidTracker.defaults, GetUnitName("player"))

	--notify if tracking is disabled
	if not archdruidTracker.savedVariables.trackArch then
		zo_callLater(function() printMessageTest("tracking disabled") end, 600)
	end

    --setup text field areas
    archAddonText:SetMovable(true)
    archAddonTextIcon:SetFont("$(GAMEPAD_MEDIUM_FONT)|$(GP_54)|soft-shadow-thick")
    archAddonTextLabelTime:SetFont("$(GAMEPAD_BOLD_FONT)|$(GP_54)|soft-shadow-thick")
    archAddonTextLabelVuln:SetFont("$(GAMEPAD_BOLD_FONT)|$(GP_34)|soft-shadow-thick")
    archAddonTextIcon:SetText(iconText)
    archAddonTextLabelTime:SetText("")
    archAddonTextLabelTime:SetColor(255, 255, 0, 255)
    archAddonTextLabelVuln:SetText("")
    archAddonTextLabelVuln:SetColor(255, 255, 0, 255)

    setAnchorStartupIcon(archdruidTracker.savedVariables.xAxisText, archdruidTracker.savedVariables.yAxisText)

    --register for combat alerts if tracking is enabled
    if archdruidTracker.savedVariables.trackArch then
        registerAlerts()
        archAddonText:SetHidden(false)
    else
        archAddonText:SetHidden(true)
    end

    --register for combat alerts if tracking is enabled for major vulnerability
    if archdruidTracker.savedVariables.trackVuln then
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

