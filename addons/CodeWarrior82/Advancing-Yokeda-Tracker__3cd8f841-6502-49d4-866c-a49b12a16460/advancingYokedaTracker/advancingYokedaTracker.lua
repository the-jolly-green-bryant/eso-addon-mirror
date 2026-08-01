local appName = "advancingYokedaTracker"

local isLoaded = false
local advBuffID = 50978
local timeRemaining = 0
local timeLeft = ""
local stacks = 0
local picPath = "/esoui/art/icons/ability_warrior_005.dds"
local iconText = zo_iconTextFormat(picPath, 80, 80, " ")

advancingYokedaTracker = {}

advancingYokedaTracker.defaults = {
    trackAdv = true,
    yAxisText = 930,
    xAxisText = 1400,
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

--is adv yokeda buff active
local function buffActive()
    for i = 1, GetNumBuffs("player") do
        local buffName, timeStarted, timeEnding, _, _, _, _, _, iconFilename, _, abilityId, _, _ = GetUnitBuffInfo("player", i)
        
        if abilityId == advBuffID then
            timeRemaining = timeEnding - GetFrameTimeSeconds()
            return true
        end
    end
    return false
end

--handle if player has buff
local function processAdvBuff()
    if buffActive() then
        local text = string.format(" %d", timeRemaining)

        --printMessageTest(text)
        advAddonTextLabelTime:SetText(text)
        
        zo_callLater(function() processAdvBuff() end, 1000)
    else
        advAddonTextLabelTime:SetText("")
    end
end

--handle combat alert
local function combatReport(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, 
    sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

    if isError then
        return
    end

    local nameTmp = GetUnitName("player")

    if(abilityId == advBuffID) then
        if nameTmp == cleanName(targetName) then 

            if buffActive() then
                processAdvBuff()
            end
        end
    end
end

--handle effect change alert
local function effectReport( _,  changeType,  _,  _,  unitTag, beginTime, endTime, stackCount,  _,  _,  effectType, _,  _,  unitName, unitId, abilityId, sourceType)
	--changeType
	-- 1 = EFFECT_RESULT_GAINED
	-- 2 = EFFECT_RESULT_FADED
	-- 3 = EFFECT_RESULT_UPDATED
	if changeType == EFFECT_RESULT_FADED then stackCount = 0 end

	if abilityId == nil then return end

	local msg = (zo_strformat("<<1>>", stackCount))

    if stackCount > 0 then
        advAddonTextLabelStacks:SetText(msg)
    else
        advAddonTextLabelStacks:SetText("")
    end
end

--register for notifications about mask buff and debuff
local function registerAlerts()
    EVENT_MANAGER:RegisterForEvent("advBuff", EVENT_COMBAT_EVENT, combatReport)
    EVENT_MANAGER:AddFilterForEvent("advBuff", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, advBuffID)

    EVENT_MANAGER:RegisterForEvent("advBuffTrack", EVENT_EFFECT_CHANGED, effectReport)
    EVENT_MANAGER:AddFilterForEvent("advBuffTrack", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, advBuffID)
  	EVENT_MANAGER:AddFilterForEvent("advBuffTrack", EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
end

--unregister for notifications about mask buff and debuff
local function unRegisterAlerts()
    EVENT_MANAGER:UnregisterForEvent("advBuff", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent("advBuffTrack", EVENT_COMBAT_EVENT)
end

--change icon anchor to move icon around the screen at app start
local function setAnchorStartupIcon(x, y)  
    advAddonText:ClearAnchors()
    advAddonText:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--change icon anchor to move text around the screen
local function setAnchorIcon(x, y)  
    advAddonText:SetHidden(false)
    zo_callLater(function () advAddonText:SetHidden(true) end, 2000)
    advAddonText:ClearAnchors()
    advAddonText:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--when UI opens
local function onMenuOpened()
    if advancingYokedaTracker.savedVariables.trackAdv then
        advAddonText:SetHidden(true)
    end
end

--when UI closes
local function onMenuClosed()
    if advancingYokedaTracker.savedVariables.trackAdv then
        advAddonText:SetHidden(false)
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

--setup options menu
local function createOptions()

    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "Advancing Yokeda Tracker",
        displayName = "Advancing Yokeda Tracker",
        author = "codewarrior82",
        registerForRefresh = true,
        registerForDefaults = true,
    }

--advancingYokedaTracker
--advAddonText
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
            tooltip = "Displays a timer while the Advancing Yokeda buff is active.",
            getFunc = function()
                return advancingYokedaTracker.savedVariables.trackAdv
            end,
            setFunc = function(value)
                advancingYokedaTracker.savedVariables.trackAdv = value
                if not value then
                    unRegisterAlerts()
                    advAddonText:SetHidden(true)
                else
                    registerAlerts()
                    advAddonText:SetHidden(false)
                end
            end,
            default = advancingYokedaTracker.defaults.trackAdv,
        },
        {
            type = "slider",
            name = "Icon and Text x Position",
            tooltip = "Adjust the left and right position of the on screen icon and timer text.",
            min = 0, max = 1700, step = 10,
            getFunc = function()
                return advancingYokedaTracker.savedVariables.xAxisText
            end,
            setFunc = function(value)
                advancingYokedaTracker.savedVariables.xAxisText = value
                setAnchorIcon(advancingYokedaTracker.savedVariables.xAxisText, advancingYokedaTracker.savedVariables.yAxisText)
            end,
            default = advancingYokedaTracker.defaults.xAxisText,
        },
        {
            type = "slider",
            name = "Icon and Text y Position",
            tooltip = "Adjust the up and down position of the on screen icon and timer text.",
            min = 0, max = 1000, step = 10,
            getFunc = function()
                return advancingYokedaTracker.savedVariables.yAxisText
            end,
            setFunc = function(value)
                advancingYokedaTracker.savedVariables.yAxisText = value
                setAnchorIcon(advancingYokedaTracker.savedVariables.xAxisText, advancingYokedaTracker.savedVariables.yAxisText)
            end,
            default = advancingYokedaTracker.defaults.yAxisText,
        },
        {
            type = "divider",
            height = 0,
            width = "full",
        }
    }

    LAM:RegisterAddonPanel("Adv Yok Tracker", panelData)
    LAM:RegisterOptionControls("Adv Yok Tracker", optionsData)
end

local function onAddOnLoadedAdv(event, name)
    --if add-on loaded was not this add-on quit
    if name ~= appName then
        return
    end

    --unregister for notifications of add-on loaded
    EVENT_MANAGER:UnregisterForEvent(appName, EVENT_ADD_ON_LOADED)

	--notify that add-on has been loaded
	zo_callLater(function() printMessageTest("add-on successfully loaded") end, 500)

    --load saved variables
    advancingYokedaTracker.savedVariables = ZO_SavedVars:NewCharacterIdSettings("aytAddonVars", 1, "Settings", advancingYokedaTracker.defaults, GetUnitName("player"))

    --setup text field areas
    advAddonText:SetMovable(true)
    advAddonTextIcon:SetFont("$(GAMEPAD_MEDIUM_FONT)|$(GP_54)|soft-shadow-thick")
    advAddonTextIcon:SetText(iconText)
    advAddonTextLabelTime:SetFont("$(GAMEPAD_BOLD_FONT)|$(GP_54)|soft-shadow-thick")
    advAddonTextLabelTime:SetText("")
    advAddonTextLabelStacks:SetFont("$(GAMEPAD_BOLD_FONT)|$(GP_25)|soft-shadow-thick")
    advAddonTextLabelStacks:SetText("")
    setAnchorStartupIcon(advancingYokedaTracker.savedVariables.xAxisText, advancingYokedaTracker.savedVariables.yAxisText)

    --register for combat alerts
    registerAlerts()

    --register for notifications of menu or map opening
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", onSceneStateChange)

    --setup add on menu options
    createOptions()

    --set is loaded boolean for use later, to stop scene change hiding tracker icon at first load in
    zo_callLater(function () isLoaded = true end, 2000)

end

--register for notification that an addon has been loaded
EVENT_MANAGER:RegisterForEvent(appName, EVENT_ADD_ON_LOADED, onAddOnLoadedAdv)