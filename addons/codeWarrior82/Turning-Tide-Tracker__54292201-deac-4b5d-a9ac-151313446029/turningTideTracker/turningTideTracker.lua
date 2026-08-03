local appName = "turningTideTracker"
local turningTideID = 167350
local timeRemaining = 0
--flowing water lasts 10 seconds
--major vuln 10 seconds
--cooldown on major vuln 15 seconds
local picPath = GetAbilityIcon(turningTideID)
local iconText = zo_iconTextFormat(picPath, 80, 80, " ")
local isLoaded = false
local procTime = 15
local vulnTime = 10

turningTideTracker = {}

turningTideTracker.defaults = {
    trackTurn = true,
    trackVuln = false,
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
	return turningTideTracker.majorEffects[abilityID]
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
    if(abilityId == turningTideID and nameTmp == cleanName(sourceName)) then
        printMessageTest("got tt")
    end




end





--register for notifications about turning tide proc
local function registerAlerts()
    EVENT_MANAGER:RegisterForEvent("turnDebuff", EVENT_COMBAT_EVENT, combatReport)
    EVENT_MANAGER:AddFilterForEvent("turnDebuff", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
    EVENT_MANAGER:AddFilterForEvent("turnDebuff", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, turningTideID)
end

--unregister for notifications about turning tide proc
local function unRegisterAlerts()
    EVENT_MANAGER:UnregisterForEvent("turnDebuff", EVENT_COMBAT_EVENT)
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
    turningTideTracker.savedVariables = ZO_SavedVars:NewCharacterIdSettings("adtAddonVars", 1, "Settings", turningTideTracker.defaults, GetUnitName("player"))

    --setup text field areas
    ttAddonText:SetMovable(true)
    ttAddonTextIcon:SetFont("$(GAMEPAD_MEDIUM_FONT)|$(GP_54)|soft-shadow-thick")
    ttAddonTextLabelTime:SetFont("$(GAMEPAD_BOLD_FONT)|$(GP_54)|soft-shadow-thick")
    ttAddonTextLabelVuln:SetFont("$(GAMEPAD_BOLD_FONT)|$(GP_34)|soft-shadow-thick")
    ttAddonTextIcon:SetText(iconText)
    ttAddonTextLabelTime:SetText("14")
    --ttAddonTextLabelTime:SetColor(255, 255, 0, 255)
    ttAddonTextLabelVuln:SetText("9")
    --ttAddonTextLabelVuln:SetColor(255, 255, 0, 255)

    --setAnchorStartupIcon(turningTideTracker.savedVariables.xAxisText, turningTideTracker.savedVariables.yAxisText)

    --register for combat alerts if tracking is enabled
    --if archdruidTracker.savedVariables.trackArch then
        registerAlerts()
    --    archAddonText:SetHidden(false)
    --else
    --    archAddonText:SetHidden(true)
    --end

    --register for combat alerts if tracking is enabled for major vulnerability
    --if archdruidTracker.savedVariables.trackVuln then
    --    registerAlertsVuln()
    --end

    --register for notifications of menu or map opening
    --SCENE_MANAGER:RegisterCallback("SceneStateChanged", onSceneStateChange)

    --setup add on menu options
    --createOptions()

    --set is loaded boolean for use later, to stop scene change hiding tracker icon at first load in
    zo_callLater(function () isLoaded = true end, 2000)
end

--register for notification that an addon has been loaded
EVENT_MANAGER:RegisterForEvent(appName, EVENT_ADD_ON_LOADED, onAddOnLoaded)

