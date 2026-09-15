local appName = "LibNotify"
local notifyInProgress = false
local colourStartup
local colourSet

--add option to move notification box
--add option into each add-on for text only with no picture
--add a notify in progress que

LibNotify = {}

LibNotify.savedVariables = {}

LibNotify.defaults = {
playSound = true,
textColor = { 0, 1, 0, 1 },
type = "Scrolling",
sound = "ANTIQUITIES_FANFARE_FAILURE",
yAxisBox = 200,
xAxisBox = 1050,
yAxisStatic = 500,
xAxisStatic = 1050,
}

LibNotify.notificationType = {
"Scrolling",
"Static",
}

LibNotify.addons = {
["advancingYokedaTracker"] = true,
["aeriesCryTracker"] = true,
["archdruidTracker"] = true,
["darkConvergenceTracker"] = true,
["essenceThiefTracker"] = true,
["feedingFrenzyTracker"] = true,
["FrenziedMomentumTracker"] = true,
["gorethiefTracker"] = true,
["mechAcuityTracker"] = true,
["rallyingCryTracker"] = true,
["riposteTracker"] = true,
["rushOfAgonyTracker"] = true,
["turningTideTracker"] = true,
["wardTracker"] = true,
["warHornTracker"] = true,
["warmaskTracker"] = true,
["wretchedVitalityTracker"] = true
}

LibNotify.samples = {
    options = {
        "ACTIVE_SKILL_MORPH_CHOSEN",--
        "SKILL_PURCHASED",--
        "ABILITY_SYNERGY_READY",--
        "ANTIQUITIES_FANFARE_FAILURE",--
        "AVA_GATE_CLOSED",--
        "AVA_GATE_OPENED",--
        "BATTLEGROUND_MATCH_LOST",--
        "BATTLEGROUND_MATCH_WON",--
        "BATTLEGROUND_MEDAL_RECEIVED",--
        "BLACKSMITH_IMPROVE_TOOLTIP_GLOW_SUCCESS",--
        "CHAMPION_POINT_GAINED",--
        "DISPLAY_ANNOUNCEMENT",--
        "DUEL_START",--
        "DUEL_WON",--
        "ELDER_SCROLL_CAPTURED_BY_ALDMERI",--
        "EMPEROR_ABDICATED",--
        "EMPEROR_CORONATED_ALDMERI",--
        "GROUP_ELECTION_REQUESTED",--
        "GROUP_ELECTION_RESULT_WON",--
        "JUSTICE_PICKPOCKET_BONUS",--
        "JUSTICE_STATE_CHANGED",--
        "OBJECTIVE_COMPLETED",--

    },
    names = {
        "Skill Morph Chosen",
        "Skill Purchased",
        "Ability Synergy Ready",
        "Antiquities Failure",
        "AVA Gate Closed",
        "AVA Gate Opened",
        "BG Lost",
        "BG Won",
        "BG Medal Awarded",
        "Blacksmith Success",
        "Champion Point Gained",
        "Display Announcement",
        "Duel Start",
        "Duel Won",
        "Elder Scroll Captured",
        "Emperor Abdicated",
        "Emperor Coronated",
        "Group Vote Request",
        "Group Vote Passed",
        "Pickpocket Bonus",
        "Justice State Changed",
        "Objective Completed",
    },
}

--print message to chat box
local function printMessage(msg)
	local chat = LibChatMessage(appName, "MA")
	chat:Print(msg)
end

--check add-on validity
local function isAddonValid(name)
    return LibNotify.addons[name]
end

--play sound effect
local function doSound(audio)
    PlaySound(SOUNDS[audio])
end

--display static notify
local function displayMessageStatic(message)
    libNotifyNotifyStatic:SetText(message)
    zo_callLater(function () libNotifyNotifyStatic:SetText("") end, 2000)
end

--display scrolling notify
local function displayMessageScrolling(message)
    libNotifyBoxNotify6:SetText(message)
    zo_callLater(function () libNotifyBoxNotify6:SetText("") libNotifyBoxNotify5:SetText(message) end, 300)
    zo_callLater(function () libNotifyBoxNotify5:SetText("") libNotifyBoxNotify4:SetText(message) end, 600)
    zo_callLater(function () libNotifyBoxNotify4:SetText("") libNotifyBoxNotify3:SetText(message) end, 900)
    zo_callLater(function () libNotifyBoxNotify3:SetText("") libNotifyBoxNotify2:SetText(message) end, 1200)
    zo_callLater(function () libNotifyBoxNotify2:SetText("") libNotifyBoxNotify1:SetText(message) end, 1500)
    zo_callLater(function () libNotifyBoxNotify1:SetText("") end, 2000)
end

--run notification process when another add-on calls
function LibNotify.notifyForAddonPlease(addonName, abilityID, message)

    --if not listed add-on tries to access notify service, quit
    if not isAddonValid(addonName) then printMessage("Restricted Access") return end

    local picPath
    local iconText

    --if abilityID is not 0 then display picture, otherwise display just message
    if abilityID ~= 0 then
        picPath = GetAbilityIcon(abilityID)
        iconText = zo_iconTextFormat(picPath, 50, 50, message)
    else
        iconText = message
    end

    --if play sound
    if LibNotify.savedVariables.playSound then doSound(LibNotify.savedVariables.sound) end

    --display the message
    if LibNotify.savedVariables.type == "Scrolling" then
        displayMessageScrolling(iconText)
    elseif LibNotify.savedVariables.type == "Static" then
        displayMessageStatic(iconText)
    end
end







--when finished moving around screen in options
local function setupTextSlotsBlankStatic()
    libNotifyNotifyStatic:SetText("")
end

--when moving around screen in options
local function setupTextSlotsExampleStatic()
    libNotifyNotifyStatic:SetText("example notify")
end

--when finished moving around screen in options
local function setupTextSlotsBlankBox()
    libNotifyBoxNotify1:SetText("")
    libNotifyBoxNotify2:SetText("")
    libNotifyBoxNotify3:SetText("")
    libNotifyBoxNotify4:SetText("")
    libNotifyBoxNotify5:SetText("")
    libNotifyBoxNotify6:SetText("")
end

--when moving around screen in options
local function setupTextSlotsExampleBox()
    libNotifyBoxNotify1:SetText("End here")
    libNotifyBoxNotify2:SetText("example notify")
    libNotifyBoxNotify3:SetText("example notify")
    libNotifyBoxNotify4:SetText("example notify")
    libNotifyBoxNotify5:SetText("example notify")
    libNotifyBoxNotify6:SetText("Start here")
end

--when add-on first starts
local function setupTextSlots()
    libNotifyBox:SetMovable(true)

    libNotifyBoxNotify1:SetColor(0, 255, 0, 255)
    libNotifyBoxNotify1:SetFont("$(GAMEPAD_LIGHT_FONT)|$(GP_54)|soft-shadow-thick")
    libNotifyBoxNotify1:SetText("")

    libNotifyBoxNotify2:SetColor(0, 255, 0, 255)
    libNotifyBoxNotify2:SetFont("$(GAMEPAD_LIGHT_FONT)|$(GP_54)|soft-shadow-thick")
    libNotifyBoxNotify2:SetText("")

    libNotifyBoxNotify3:SetColor(0, 255, 0, 255)
    libNotifyBoxNotify3:SetFont("$(GAMEPAD_LIGHT_FONT)|$(GP_54)|soft-shadow-thick")
    libNotifyBoxNotify3:SetText("")

    libNotifyBoxNotify4:SetColor(0, 255, 0, 255)
    libNotifyBoxNotify4:SetFont("$(GAMEPAD_LIGHT_FONT)|$(GP_54)|soft-shadow-thick")
    libNotifyBoxNotify4:SetText("")

    libNotifyBoxNotify5:SetColor(0, 255, 0, 255)
    libNotifyBoxNotify5:SetFont("$(GAMEPAD_LIGHT_FONT)|$(GP_54)|soft-shadow-thick")
    libNotifyBoxNotify5:SetText("")

    libNotifyBoxNotify6:SetColor(0, 255, 0, 255)
    libNotifyBoxNotify6:SetFont("$(GAMEPAD_LIGHT_FONT)|$(GP_54)|soft-shadow-thick")
    libNotifyBoxNotify6:SetText("")

    --static notify
    libNotify:SetMovable(true)

    libNotifyNotifyStatic:SetColor(colourStartup:UnpackRGBA())
    libNotifyNotifyStatic:SetFont("$(GAMEPAD_LIGHT_FONT)|$(GP_54)|soft-shadow-thick")
    libNotifyNotifyStatic:SetText("")
end

--setup options menu
local function createOptions()

    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "LibNotify",
        displayName = "LibNotify",
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
            type = "dropdown",
            name = "Notification Type",
            tooltip = "Choose between a static notification and a scrolling notification.",
            choices = LibNotify.notificationType,
            getFunc = function() return LibNotify.savedVariables.type end,
            setFunc = function(var) LibNotify.savedVariables.type = var end,
        },
        {
            type = "colorpicker",
            name = "Text colour",
            tooltip = "Change the colour of the notification text.",
            default = ZO_ColorDef:New(unpack(LibNotify.defaults.textColor)),
            getFunc = function ()
                return unpack(LibNotify.savedVariables.textColor)
            end,
            setFunc = function (r, g, b, a)
                LibNotify.savedVariables.textColor = { r, g, b, a }
                colourSet = ZO_ColorDef:New(unpack(LibNotify.savedVariables.textColor))
                libNotifyNotifyStatic:SetColor(colourSet:UnpackRGBA())
            end,
        },
        {
            type = "button",
            name = "Test Colour",
            tooltip = "Show a short notification with the new colour you have set.",
            func = function()
                libNotifyNotifyStatic:SetText("Notification")
                zo_callLater(function () libNotifyNotifyStatic:SetText("") end, 2000)
             end,
        },
        {
            type = "checkbox",
            name = "Play Sound",
            tooltip = "Plays audio when the notification starts.",
            getFunc = function()
                return LibNotify.savedVariables.playSound
            end,
            setFunc = function(value)
                LibNotify.savedVariables.playSound = value
            end,
            default = LibNotify.defaults.playSound,
        },
        {
            type = "dropdown",
            name = "Sound Type",
            tooltip = "Choose the audio sample to play at the start of each notification.",
            choices = LibNotify.samples.names,
            choicesValues = LibNotify.samples.options,
            getFunc = function() return LibNotify.savedVariables.sound end,
            setFunc = function(value) LibNotify.savedVariables.sound = value end,
            sort = "name-up",
            width = "full",
            scrollable = true,
        },
        {
            type = "button",
            name = "Test Sound",
            tooltip = "Play audio with the sound you have set.",
            func = function()
                doSound(LibNotify.savedVariables.sound)
             end,
        },
        {
            type = "divider",
            height = 0,
            width = "full",
        }
    }

    LAM:RegisterAddonPanel("LibNotify", panelData)
    LAM:RegisterOptionControls("LibNotify", optionsData)
end

--add-on loaded
local function libLoaded(event, name)
    --if add-on loaded was not this add-on quit
    if name ~= appName then return end
    --unregister for notifications of add-on loaded
    EVENT_MANAGER:UnregisterForEvent(appName, EVENT_ADD_ON_LOADED)
    --load saved variables
    LibNotify.savedVariables = ZO_SavedVars:NewCharacterIdSettings("libNotifyAddonVars", 1, "Settings", LibNotify.defaults, GetUnitName("player"))

    colourStartup = ZO_ColorDef:New(unpack(LibNotify.savedVariables.textColor))

    --setup each text slot
    setupTextSlots()
    --setup options menu
    createOptions()
end

--register for notification that an addon has been loaded
EVENT_MANAGER:RegisterForEvent(appName, EVENT_ADD_ON_LOADED, libLoaded)


--example of message from other addon, 
--notifyForAddonPlease(appName, abilityID, "Aerie's Call ended")