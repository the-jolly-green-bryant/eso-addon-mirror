local appName = "warmaskTracker"
local maskBuffID = 252050
local maskDebuffID = 252048
local markOfHircineID = 252048
local timeRemaining = 0
local picPath = GetAbilityIcon(markOfHircineID)
local iconText = zo_iconTextFormat(picPath, 80, 80, " ")
local isLoaded = false

--[[
todo:



]]

warmaskTracker = {}

warmaskTracker.defaults = {
    trackWarmask = true,
    trackWho = false,
    trackSelf = false,
    yAxisText = 930,
    xAxisText = 1300,
    yAxisTextW = 720,
    xAxisTextW = 830,
    yAxisTextP = 680,
    xAxisTextP = 830
}

--print message to chat box
local function printMessageTest(msg)
	local chat = LibChatMessage(appName, "MA")
	chat:Print(msg)
end

--is warmask buff active
local function buffActive()
    for i = 1, GetNumBuffs("player") do
        local buffName, timeStarted, timeEnding, _, _, _, _, _, iconFilename, _, abilityId, _, _ = GetUnitBuffInfo("player", i)
        
        if abilityId == maskBuffID then
            timeRemaining = timeEnding - GetFrameTimeSeconds()
            return true
        end
    end
    return false
end

--is warmask buff active
local function debuffActive()
    for i = 1, GetNumBuffs("player") do
        local buffName, timeStarted, timeEnding, _, _, _, _, _, iconFilename, _, abilityId, _, _ = GetUnitBuffInfo("player", i)
        
        if abilityId == maskDebuffID then
            timeRemaining = timeEnding - GetFrameTimeSeconds()
            return true
        end
    end
    return false
end

--clean player names
local function cleanName(str)
    return str:sub(1, -4)
end

--handle who has debuff
local function processDebuff(type, name)

    local targetName

    if type == 3 and name ~= "" then
        targetName = cleanName(name)
    elseif type == 4 and name ~= "" then
        targetName = name
    elseif type == 0 and name ~= "" then
        targetName = name--todo clean the names from all type 0 enemies
    elseif name == "" then
        targetName = "unknown"
        return
    end

    if buffActive and timeRemaining >= 0 then
        wmtAddonTextWLabel:SetText(targetName .. "|c00FF00 is targeted|r")
    else
        wmtAddonTextWLabel:SetText("")
    end

end

--handle if player has buff
local function processBuff()
    if buffActive() then
        local text = string.format(" %d", timeRemaining)
        local time = timeRemaining - 50

        --[[if time == 10 then
            wmtAddonTextLabelMini:ClearAnchors()
            wmtAddonTextLabelMini:ClearAnchors():SetAnchor(TOPLEFT, wmtAddonText, TOPLEFT, 58, -5)
        else
            wmtAddonTextLabelMini:ClearAnchors()
            wmtAddonTextLabelMini:ClearAnchors():SetAnchor(TOPLEFT, wmtAddonText, TOPLEFT, 60, -5)
        end--]]

        local textM = string.format(" %d", time)

        wmtAddonTextLabel:SetText(text)

        if time >= 0 then
            wmtAddonTextLabelMini:SetText(textM)
        else
            wmtAddonTextLabelMini:SetText("")
        end

        zo_callLater(function() processBuff() end, 1000)
    else
        wmtAddonTextLabel:SetText("")
        wmtAddonTextLabelMini:SetText("")
        wmtAddonTextWLabel:SetText("")
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

    if(abilityId == maskBuffID) then
        processBuff()
    elseif(abilityId == maskDebuffID) then
        if nameTmp == cleanName(targetName) then 
            --player self has debuff
            if debuffActive() then
                wmtAddonTextPLabel:SetText(cleanName(sourceName) .. "|cFF0000 is targeting you|r")
            else
                wmtAddonTextPLabel:SetText("")
            end
        else
            processDebuff(targetType, targetName)
        end
    end
end

--change who is targeted text anchor to move text around the screen at app start
local function setAnchorStartupP(x, y)  
    wmtAddonTextP:ClearAnchors()
    wmtAddonTextP:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--change who is targeted text anchor to move text around the screen
local function setAnchorP(x, y)  
    wmtAddonTextPLabel:SetText("(InsertName)|cFF0000 is targeting you|r")
    wmtAddonTextP:SetHidden(false)
    zo_callLater(function () wmtAddonTextPLabel:SetText("") end, 2000)
    zo_callLater(function () wmtAddonTextP:SetHidden(true) end, 2000)
    wmtAddonTextP:ClearAnchors()
    wmtAddonTextP:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--change who is targeted text anchor to move text around the screen at app start
local function setAnchorStartupW(x, y)  
    wmtAddonTextW:ClearAnchors()
    wmtAddonTextW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--change who is targeted text anchor to move text around the screen
local function setAnchorW(x, y)  
    wmtAddonTextWLabel:SetText("(InsertName)|c00FF00 is targeted|r")
    wmtAddonTextW:SetHidden(false)
    zo_callLater(function () wmtAddonTextWLabel:SetText("") end, 2000)
    zo_callLater(function () wmtAddonTextW:SetHidden(true) end, 2000)
    wmtAddonTextW:ClearAnchors()
    wmtAddonTextW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--change icon anchor to move text around the screen at app start
local function setAnchorStartupIcon(x, y)  
    wmtAddonText:ClearAnchors()
    wmtAddonText:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--change icon anchor to move text around the screen
local function setAnchorIcon(x, y)  
    wmtAddonText:SetHidden(false)
    zo_callLater(function () wmtAddonText:SetHidden(true) end, 2000)
    wmtAddonText:ClearAnchors()
    wmtAddonText:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

--register for notifications about mask buff and debuff
local function registerAlerts()
    EVENT_MANAGER:RegisterForEvent("maskBuff", EVENT_COMBAT_EVENT, combatReport)
    EVENT_MANAGER:AddFilterForEvent("maskBuff", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, maskBuffID)
    EVENT_MANAGER:RegisterForEvent("maskDebuff", EVENT_COMBAT_EVENT, combatReport)
    EVENT_MANAGER:AddFilterForEvent("maskDebuff", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, maskDebuffID)
end

--unregister for notifications about mask buff and debuff
local function unRegisterAlerts()
    EVENT_MANAGER:UnregisterForEvent("maskBuff", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent("maskDebuff", EVENT_COMBAT_EVENT)
end

--setup options menu
local function createOptions()

    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "Warmask Tracker",
        displayName = "Warmask Tracker",
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
            tooltip = "Displays a timer while the Huntsman's Warmask buff is active.",
            getFunc = function()
                return warmaskTracker.savedVariables.trackWarmask
            end,
            setFunc = function(value)
                warmaskTracker.savedVariables.trackWarmask = value
                if not value then
                    unRegisterAlerts()
                    wmtAddonText:SetHidden(true)
                else
                    registerAlerts()
                    wmtAddonText:SetHidden(false)
                end
            end,
            default = warmaskTracker.defaults.trackWarmask,
        },
        {
            type = "slider",
            name = "Icon and Text x Position",
            tooltip = "Adjust the left and right position of the on screen icon and timer text.",
            min = 0, max = 1700, step = 10,
            getFunc = function()
                return warmaskTracker.savedVariables.xAxisText
            end,
            setFunc = function(value)
                warmaskTracker.savedVariables.xAxisText = value
                setAnchorIcon(warmaskTracker.savedVariables.xAxisText, warmaskTracker.savedVariables.yAxisText)
            end,
            default = warmaskTracker.defaults.xAxisText,
        },
        {
            type = "slider",
            name = "Icon and Text y Position",
            tooltip = "Adjust the up and down position of the on screen icon and timer text.",
            min = 0, max = 1000, step = 10,
            getFunc = function()
                return warmaskTracker.savedVariables.yAxisText
            end,
            setFunc = function(value)
                warmaskTracker.savedVariables.yAxisText = value
                setAnchorIcon(warmaskTracker.savedVariables.xAxisText, warmaskTracker.savedVariables.yAxisText)
            end,
            default = warmaskTracker.defaults.yAxisText,
        },
        {
            type = "checkbox",
            name = "Track Debuff",
            tooltip = "Displays on screen text with the name of the person who has your Mark of Hircine debuff on them.",
            getFunc = function()
                return warmaskTracker.savedVariables.trackWho
            end,
            setFunc = function(value)
                warmaskTracker.savedVariables.trackWho = value
                if not value then
                    wmtAddonTextW:SetHidden(true)
                else
                    wmtAddonTextW:SetHidden(false)
                end
            end,
            default = warmaskTracker.defaults.trackWho,
        },
        {
            type = "slider",
            name = "Who has debuff Text x Position",
            tooltip = "Adjust the left and right position of the on screen text that tells you who has the Mark of Hircine debuff.",
            min = 0, max = 1700, step = 10,
            getFunc = function()
                return warmaskTracker.savedVariables.xAxisTextW
            end,
            setFunc = function(value)
                warmaskTracker.savedVariables.xAxisTextW = value
                setAnchorW(warmaskTracker.savedVariables.xAxisTextW, warmaskTracker.savedVariables.yAxisTextW)
            end,
            default = warmaskTracker.defaults.xAxisTextW,
        },
        {
            type = "slider",
            name = "Who has debuff Text y Position",
            tooltip = "Adjust the up and down position of the on screen text that tells you who has the Mark of Hircine debuff.",
            min = 0, max = 1000, step = 10,
            getFunc = function()
                return warmaskTracker.savedVariables.yAxisTextW
            end,
            setFunc = function(value)
                warmaskTracker.savedVariables.yAxisTextW = value
                setAnchorW(warmaskTracker.savedVariables.xAxisTextW, warmaskTracker.savedVariables.yAxisTextW)
            end,
            default = warmaskTracker.defaults.yAxisTextW,
        },
        {
            type = "checkbox",
            name = "Track Debuff on Self",
            tooltip = "Displays on screen text with the name of the person who has placed the Mark of Hircine debuff on you.",
            getFunc = function()
                return warmaskTracker.savedVariables.trackSelf
            end,
            setFunc = function(value)
                warmaskTracker.savedVariables.trackSelf = value
                if not value then
                    wmtAddonTextP:SetHidden(true)
                else
                    wmtAddonTextP:SetHidden(false)
                end
            end,
            default = warmaskTracker.defaults.trackSelf,
        },
        {
            type = "slider",
            name = "Who is targeting Text x Position",
            tooltip = "Adjust the left and right position of the on screen text that tells you who targeted you with the Mark of Hircine debuff.",
            min = 0, max = 1700, step = 10,
            getFunc = function()
                return warmaskTracker.savedVariables.xAxisTextP
            end,
            setFunc = function(value)
                warmaskTracker.savedVariables.xAxisTextP = value
                setAnchorP(warmaskTracker.savedVariables.xAxisTextP, warmaskTracker.savedVariables.yAxisTextP)
            end,
            default = warmaskTracker.defaults.xAxisTextP,
        },
        {
            type = "slider",
            name = "Who is targeting Text y Position",
            tooltip = "Adjust the up and down position of the on screen text that tells you who targeted you with the Mark of Hircine debuff.",
            min = 0, max = 1000, step = 10,
            getFunc = function()
                return warmaskTracker.savedVariables.yAxisTextP
            end,
            setFunc = function(value)
                warmaskTracker.savedVariables.yAxisTextP = value
                setAnchorP(warmaskTracker.savedVariables.xAxisTextP, warmaskTracker.savedVariables.yAxisTextP)
            end,
            default = warmaskTracker.defaults.yAxisTextP,
        },
        {
            type = "divider",
            height = 0,
            width = "full",
        }
    }

    LAM:RegisterAddonPanel("Warmask Tracker", panelData)
    LAM:RegisterOptionControls("Warmask Tracker", optionsData)
end

--when UI opens
local function onMenuOpened()
    if warmaskTracker.savedVariables.trackWarmask then
        wmtAddonText:SetHidden(true)
    end
    if warmaskTracker.savedVariables.trackWho then
        wmtAddonTextW:SetHidden(true)    
    end
    if warmaskTracker.savedVariables.trackSelf then
        wmtAddonTextP:SetHidden(true)
    end
end

--when UI closes
local function onMenuClosed()
    if warmaskTracker.savedVariables.trackWarmask then
        wmtAddonText:SetHidden(false)
    end
    if warmaskTracker.savedVariables.trackWho then
        wmtAddonTextW:SetHidden(false)
    end
    if warmaskTracker.savedVariables.trackSelf then
        wmtAddonTextP:SetHidden(false)
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
    warmaskTracker.savedVariables = ZO_SavedVars:NewCharacterIdSettings("wmtAddonVars", 1, "Settings", warmaskTracker.defaults, GetUnitName("player"))

    --organise on screen text
    wmtAddonText:SetMovable(true)
    wmtAddonTextW:SetMovable(true)
    wmtAddonTextP:SetMovable(true)
    wmtAddonTextLabelMini:SetMovable(true)
    wmtAddonTextIcon:SetFont("$(GAMEPAD_MEDIUM_FONT)|$(GP_54)|soft-shadow-thick")
    wmtAddonTextLabel:SetFont("$(GAMEPAD_BOLD_FONT)|$(GP_42)|soft-shadow-thick")
    wmtAddonTextLabelMini:SetFont("$(GAMEPAD_BOLD_FONT)|$(GP_22)|soft-shadow-thick")
    wmtAddonTextWLabel:SetFont("$(GAMEPAD_MEDIUM_FONT)|$(GP_42)|soft-shadow-thick")
    wmtAddonTextPLabel:SetFont("$(GAMEPAD_MEDIUM_FONT)|$(GP_42)|soft-shadow-thick")
    wmtAddonTextIcon:SetText(iconText)
    wmtAddonTextLabel:SetText("")
    wmtAddonTextLabelMini:SetText("")
    wmtAddonTextWLabel:SetText("")
    wmtAddonTextPLabel:SetText("")
    setAnchorStartupIcon(warmaskTracker.savedVariables.xAxisText, warmaskTracker.savedVariables.yAxisText)
    setAnchorStartupW(warmaskTracker.savedVariables.xAxisTextW, warmaskTracker.savedVariables.yAxisTextW)
    setAnchorStartupP(warmaskTracker.savedVariables.xAxisTextP, warmaskTracker.savedVariables.yAxisTextP)

    --just good practice
    if warmaskTracker.savedVariables.trackWho then
        wmtAddonTextW:SetHidden(false)
    else
        wmtAddonTextW:SetHidden(true)
    end
    if warmaskTracker.savedVariables.trackSelf then
        wmtAddonTextP:SetHidden(false)
    else
        wmtAddonTextP:SetHidden(true)
    end

    --register for combat alerts if tracking is enabled
    if warmaskTracker.savedVariables.trackWarmask then
        registerAlerts()
        wmtAddonText:SetHidden(false)
    else
        wmtAddonText:SetHidden(true)
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


