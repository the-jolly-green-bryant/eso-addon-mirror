local appName = "LibNotify"
local notifyInProgress = false

--add option to move notification box
--add option to change sound
--add option to change text colour
--add option for scrolling or basic notifications

--add option into each add-on for text only with no picture, and option for sound or not

LibNotify = {}

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



--print message to chat box
local function printMessage(msg)
	local chat = LibChatMessage(appName, "MA")
	chat:Print(msg)
end

--clean player names
local function cleanName(str)
    return str:sub(1, -4)
end

--check add-on validity
local function isAddonValid(name)
    return LibNotify.addons[name]
end

--play sound effect
local function doSound()
    PlaySound(SOUNDS.ANTIQUITIES_FANFARE_FAILURE)
end

--display scrolling notify
local function displayMessage(message)
    libNotifyBoxNotify10:SetText(message)
    zo_callLater(function () libNotifyBoxNotify10:SetText("") libNotifyBoxNotify9:SetText(message) end, 300)
    zo_callLater(function () libNotifyBoxNotify9:SetText("") libNotifyBoxNotify8:SetText(message) end, 600)
    zo_callLater(function () libNotifyBoxNotify8:SetText("") libNotifyBoxNotify7:SetText(message) end, 900)
    zo_callLater(function () libNotifyBoxNotify7:SetText("") libNotifyBoxNotify6:SetText(message) end, 1200)
    zo_callLater(function () libNotifyBoxNotify6:SetText("") libNotifyBoxNotify5:SetText(message) end, 1500)
    zo_callLater(function () libNotifyBoxNotify5:SetText("") libNotifyBoxNotify4:SetText(message) end, 1800)
    zo_callLater(function () libNotifyBoxNotify4:SetText("") libNotifyBoxNotify3:SetText(message) end, 2100)
    zo_callLater(function () libNotifyBoxNotify3:SetText("") libNotifyBoxNotify2:SetText(message) end, 2400)
    zo_callLater(function () libNotifyBoxNotify2:SetText("") libNotifyBoxNotify1:SetText(message) end, 2700)
    zo_callLater(function () libNotifyBoxNotify1:SetText("") end, 3200)
end

--run notification process when another add-on calls
function LibNotify.notifyForAddonPlease(addonName, abilityID, message,  playSound)

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
    if playSound then doSound() end

    --display the message
    displayMessage(iconText)

end

--when finished moving around screen in options
local function setupTextSlotsBlank()
    libNotifyBoxNotify1:SetText("")
    libNotifyBoxNotify2:SetText("")
    libNotifyBoxNotify3:SetText("")
    libNotifyBoxNotify4:SetText("")
    libNotifyBoxNotify5:SetText("")
    libNotifyBoxNotify6:SetText("")
    libNotifyBoxNotify7:SetText("")
    libNotifyBoxNotify8:SetText("")
    libNotifyBoxNotify9:SetText("")
    libNotifyBoxNotify10:SetText("")
end

--when moving around screen in options
local function setupTextSlotsExample()
    libNotifyBoxNotify1:SetText("End here")
    libNotifyBoxNotify2:SetText("example notify")
    libNotifyBoxNotify3:SetText("example notify")
    libNotifyBoxNotify4:SetText("example notify")
    libNotifyBoxNotify5:SetText("example notify")
    libNotifyBoxNotify6:SetText("example notify")
    libNotifyBoxNotify7:SetText("example notify")
    libNotifyBoxNotify8:SetText("example notify")
    libNotifyBoxNotify9:SetText("example notify")
    libNotifyBoxNotify10:SetText("Start here")
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

    libNotifyBoxNotify7:SetColor(0, 255, 0, 255)
    libNotifyBoxNotify7:SetFont("$(GAMEPAD_LIGHT_FONT)|$(GP_54)|soft-shadow-thick")
    libNotifyBoxNotify7:SetText("")

    libNotifyBoxNotify8:SetColor(0, 255, 0, 255)
    libNotifyBoxNotify8:SetFont("$(GAMEPAD_LIGHT_FONT)|$(GP_54)|soft-shadow-thick")
    libNotifyBoxNotify8:SetText("")

    libNotifyBoxNotify9:SetColor(0, 255, 0, 255)
    libNotifyBoxNotify9:SetFont("$(GAMEPAD_LIGHT_FONT)|$(GP_54)|soft-shadow-thick")
    libNotifyBoxNotify9:SetText("")

    libNotifyBoxNotify10:SetColor(0, 255, 0, 255)
    libNotifyBoxNotify10:SetFont("$(GAMEPAD_LIGHT_FONT)|$(GP_54)|soft-shadow-thick")
    libNotifyBoxNotify10:SetText("")
end

--add-on loaded
local function libLoaded(event, name)
    --if add-on loaded was not this add-on quit
    if name ~= appName then return end
    --unregister for notifications of add-on loaded
    EVENT_MANAGER:UnregisterForEvent(appName, EVENT_ADD_ON_LOADED)
    --setup each text slot
    setupTextSlots()
end

--register for notification that an addon has been loaded
EVENT_MANAGER:RegisterForEvent(appName, EVENT_ADD_ON_LOADED, libLoaded)


--example of message from other addon, 
--notifyForAddonPlease("aeriesCryTracker", abilityID, "Aerie's Call ended" , true)