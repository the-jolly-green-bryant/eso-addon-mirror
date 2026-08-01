--[[----------------------------------------------
STimer
Author: Static_Recharge
Version: 2.1.1
Description: Allows for the creation of a custom
timer.
----------------------------------------------]]--


--[[----------------------------------------------
Addon Information
----------------------------------------------]]--
local ST = {
  addonName = "STimer",
  version = "2.1.1",
  author = "Static_Recharge",
}


--[[----------------------------------------------
Aliases
----------------------------------------------]]--
local EM = EVENT_MANAGER
local CS = CHAT_SYSTEM
local SM = SCENE_MANAGER


--[[----------------------------------------------
Variable, Table and Constant Declarations
----------------------------------------------]]--
ST.Const = {
  chatPrefix = "|cFF3300[STimer]: |cFFFFFF",
  chatSuffix = "|r",
}

ST.Defaults = {bgHidden = false, duration = nil, paused = false, next = nil, start = nil}

ST.duration = nil
ST.inProgress = false
ST.alerted = false
ST.secondMode = false
ST.next = nil
ST.paused = false


--[[----------------------------------------------
General Functions
----------------------------------------------]]--
function ST.SendToChat(text)
  if text ~= nil then
    CS:AddMessage(ST.Const.chatPrefix .. text .. ST.Const.chatSuffix)
  else
    CS:AddMessage(ST.Const.chatPrefix .. "nil string" .. ST.Const.chatSuffix)
  end
end

function ST.Test()
  ST.SendToChat("Test")
end


--[[----------------------------------------------
Window Control Functions
----------------------------------------------]]--
function ST_ON_MOVE_STOP()
  ST.SavedVars.left = ST_Panel:GetLeft()
  ST.SavedVars.top = ST_Panel:GetTop()
end

function ST.RestorePanel()
	local left = ST.SavedVars.left
	local top = ST.SavedVars.top
  local bgHidden = ST.SavedVars.bgHidden

	if left ~= nil and top ~= nil then
		ST_Panel:ClearAnchors()
		ST_Panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
	end

  ST_PanelBG:SetHidden(bgHidden)
end

function ST.HideBG()
  ST_PanelBG:SetHidden(not ST_PanelBG:IsHidden())
  ST.SavedVars.bgHidden = ST_PanelBG:IsHidden()
end

function ST.HUDSceneChange(oldState, newState)
  if (newState == SCENE_SHOWN) and (ST.inProgress or ST.paused) then
    ST_Panel:SetHidden(false)
  elseif (newState == SCENE_HIDDEN) then
    ST_Panel:SetHidden(true)
  end
end

function ST.HUDUISceneChange(oldState, newState)
  if (newState == SCENE_SHOWN) and (ST.inProgress or ST.paused) then
    ST_Panel:SetHidden(false)
  elseif (newState == SCENE_HIDDEN) then
    ST_Panel:SetHidden(true)
  end
end

function ST.ShowPanel()
  local sceneName = SM:GetCurrentScene():GetName()
  if sceneName == "hud" or sceneName == "hudui" then ST_Panel:SetHidden(false) else ST_Panel:SetHidden(true) end
end


--[[----------------------------------------------
Timer Control Functions
----------------------------------------------]]--
function ST.Start(duration)
  if ST.inProgress or ST.paused then ST.SendToChat("Another timer is already active. Use |cFF3300/st stop|r |cFFFFFFto stop the current timer.") return end
  if (duration == nil) or (duration <= 0) or (type(duration) ~= "number") then ST.SendToChat("Invalid timer duration. Please enter a time in minutes greater than zero.") return end

  ST.start = os.rawclock()
  duration = math.floor(duration * 60)
  if duration <= 60 then ST.secondMode = true end
  if ST.secondMode then
    ST_PanelLabel:SetText(duration .. "s")
  else
    local hours = math.floor(duration / 3600)
    local minutes = math.ceil((duration - (hours * 3600)) / 60)
    ST_PanelLabel:SetText(hours .. "h : " .. minutes .. "m")
  end
  ST.next = ST.start + 1000
  ST_PanelLabel:SetAlpha(1)
  ST.ShowPanel()
  ST.duration = duration
  ST.inProgress = true
end

function ST.TimerIterator()
  if not ST.inProgress then return end
  local now = os.rawclock()
  if now < ST.next then return end
  local timePassed = now - ST.next

  if timePassed > 1000 then
    ST.duration = ST.duration - math.floor(timePassed / 1000)
    ST.next = ST.next + (1000 * math.ceil(timePassed / 1000))
  else
    ST.duration = ST.duration - 1
    ST.next = ST.next + 1000
  end
  if ST.duration <= 60 then ST.secondMode = true end
  if ST.duration > 0 then
    if ST.secondMode then
      ST_PanelLabel:SetText(ST.duration .. "s")
    else
      local hours = math.floor(ST.duration / 3600)
      local minutes = math.ceil((ST.duration - (hours * 3600)) / 60)
      ST_PanelLabel:SetText(hours .. "h : " .. minutes .. "m")
    end
  else
    ST_PanelLabel:SetText("|cFF3300DONE!|r")
    ST_PanelLabel:SetAlpha(1)
    ST_PanelStopButton:SetHidden(false)
    if not ST.alerted then
      PlaySound(SOUNDS.NEW_TIMED_NOTIFICATION)
      zo_callLater(function() ST.BlinkIterator() end, 500)
      ST.alerted = true
    end
  end
end

function ST.BlinkIterator()
  if ST.inProgress then
    ST_PanelLabel:SetHidden(not ST_PanelLabel:IsHidden())
    zo_callLater(function() ST.BlinkIterator() end, 500)
  end
end

function ST.Stop()
  if not ST.inProgress and not ST.paused then ST.SendToChat("There is no timer started. Use |cFF3300/st start #|r to start a new timer.") return end
  ST.inProgress = false
  ST.duration = nil
  ST.alerted = false
  ST.secondMode = false
  ST.next = nil
  ST.start = nil
  ST.paused = false
  ST_PanelLabel:SetHidden(false)
  ST_Panel:SetHidden(true)
  ST_PanelStopButton:SetHidden(true)
end

function ST.Pause()
  if not ST.inProgress and not ST.paused then ST.SendToChat("There is no timer started. Use |cFF3300/st start #|cFFFFFF to start a new timer.") return end
  if ST.inProgress then
    ST.inProgress = false
    ST.start = os.rawclock() - ST.next
    ST.paused = true
    ST_PanelLabel:SetAlpha(0.4)
    ST.SendToChat("Paused.")
  elseif ST.duration and ST.paused then
    ST.next = os.rawclock() + 1000 - ST.start
    ST.inProgress = true
    ST.paused = false
    ST_PanelLabel:SetAlpha(1)
    ST.SendToChat("Resumed.")
  end
end

function ST_STOP()
  ST.Stop()
end

function ST_PAUSE()
  ST.Pause()
end

function ST_ON_UPDATE()
  ST.TimerIterator()
end


--[[----------------------------------------------
Command Parser
----------------------------------------------]]--
function ST.CommandParse(args)
	local Options = {}
	for match in (args .. " "):gmatch("(.-)" .. " ") do
    table.insert(Options, match);
  end

	if Options[1] == "" then
		ST.SendToChat("Command List\n|cFFFFFF/st start # - starts a timer for # minutes.\n|cFFFFFF/st stop - stops the current timer.\n|cFFFFFF/st pause - toggles pausing and resuming the current timer.\n|cFFFFFF/st hidebg - toggles the background visibility of the timer.")
	elseif Options[1] == "start" then
    ST.Start(tonumber(Options[2]))
  elseif Options[1] == "stop" then
    ST.Stop()
  elseif Options[1] == "test" then
    ST.Test()
  elseif Options[1] == "hidebg" then
    ST.HideBG()
  elseif Options[1] == "pause" then
    ST.Pause()
  else
    ST.SendToChat("Invalid command")
  end
end


--[[----------------------------------------------
Initialization
----------------------------------------------]]--
function ST.OnAddonLoaded(eventCode, addonName)
  if addonName == ST.addonName then
    EM:UnregisterForEvent(ST.addonName, EVENT_ADD_ON_LOADED)

    ST.SavedVars = ZO_SavedVars:NewAccountWide("STimer", 1, nil, ST.Defaults, nil)

    ST.RestorePanel()
    local control = ST_PanelPauseButton
    control:SetHandler("onMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, "Pause/Resume") end)
    control:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)

    local scene = SM:GetScene("hud")
    scene:RegisterCallback("StateChange", ST.HUDSceneChange)
    local scene = SM:GetScene("hudui")
    scene:RegisterCallback("StateChange", ST.HUDUISceneChange)

    EM:RegisterForEvent(ST.addonName, EVENT_PLAYER_ACTIVATED, ST.OnPlayerActiviated)
    EM:RegisterForEvent(ST.addonName, EVENT_PLAYER_DEACTIVATED, ST.OnPlayerDeactiviated)
  end
end

function ST.OnPlayerActiviated(eventCode, initial)
  if not initial and ST.SavedVars.duration ~= nil then
    ST.start = ST.SavedVars.start
    ST.next = ST.SavedVars.next
    ST.paused = ST.SavedVars.paused
    ST.duration = ST.SavedVars.duration
    if ST.duration <= 60 then ST.secondMode = true end
    if ST.secondMode then
      ST_PanelLabel:SetText(ST.duration .. "s")
    else
      local hours = math.floor(ST.duration / 3600)
      local minutes = math.ceil((ST.duration - (hours * 3600)) / 60)
      ST_PanelLabel:SetText(hours .. "h : " .. minutes .. "m")
    end
    if ST.paused then
      ST_PanelLabel:SetAlpha(0.4)
      ST.SendToChat("Still paused after reload UI. Use |cFF3300/st pause|cFFFFFF to resume the timer or |cFF3300/st stop|cFFFFFF to cancel it.")
    else
      ST.SendToChat("Resumed after reload UI. Use |cFF3300/st pause|cFFFFFF to pause the timer or |cFF3300/st stop|cFFFFFF to cancel it.")
      ST_PanelLabel:SetAlpha(1)
      ST.inProgress = true
    end
    ST.ShowPanel()
  end
end

function ST.OnPlayerDeactiviated(eventCode)
  if ST.inProgress or ST.paused then 
    ST.SavedVars.next = ST.next
    ST.SavedVars.duration = ST.duration
    ST.SavedVars.start = ST.start
  else
    ST.SavedVars.next = nil
    ST.SavedVars.duration = nil
  end
  ST.SavedVars.paused = ST.paused
end


--[[----------------------------------------------
Main Registration
----------------------------------------------]]--
SLASH_COMMANDS["/st"] = ST.CommandParse
EM:RegisterForEvent(ST.addonName, EVENT_ADD_ON_LOADED, ST.OnAddonLoaded)