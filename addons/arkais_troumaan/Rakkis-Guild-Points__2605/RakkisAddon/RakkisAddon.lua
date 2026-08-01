Rakkis = {
  name = "RakkisAddon",
  version = "1.15",
  hidden = true
}

--Initialize
function Rakkis.OnAddOnLoaded(event, addonName)
  if addonName == Rakkis.name then d("[Rakkis Guild Points] You must not fear. Fear is the mind-killer.") end
  Rakkis.savedVariables = ZO_SavedVars:New("RakkisSavedVariables", 1, nil, {})
  Rakkis.savedVariables.previousNotes = {}
  Rakkis:RestorePosition()
  Rakkis.hidden = true
  RakkisControl:SetHidden(true)
  if not Rakkis.savedVariables.guild_id then
    Rakkis.SetGuild()
  end
  if not Rakkis.savedVariables.groupLimit then
    Rakkis.savedVariables.groupLimit = 10
  end
end

--UI Element Position
function Rakkis.OnIndicatorMoveStop()
  Rakkis.savedVariables.left = RakkisControl:GetLeft()
  Rakkis.savedVariables.top = RakkisControl:GetTop()
end

--UI Element Position
function Rakkis:RestorePosition()
  local left = Rakkis.savedVariables.left
  local top = Rakkis.savedVariables.top

  RakkisControl:ClearAnchors()
  RakkisControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

--UI Call
function Rakkis.Button()
	local event = RakkisControl_EventText:GetText()
	local points = RakkisControl_PointText:GetText()
	local initials = RakkisControl_InitialText:GetText()
	local player = RakkisControl_PlayerText:GetText()
	if player:match("@[^ ]+") then
	  Rakkis.AddGuildPoints(event .. " " .. points .. " " .. initials .. " " .. player)
	else
	  Rakkis.AddGroupPoints(event .. " " .. points .. " " .. initials)
	end
end

--Change active guild
function Rakkis.SetGuild(arg)
  if not arg then
    Rakkis.savedVariables.guild_id = GetGuildId(1)
	d("[Rakkis Guild Points] Active Guild set to: " .. GetGuildName(GetGuildId(1)))
	return
  else
    for guildSz=1,GetNumGuilds() do
      local guild_it = GetGuildId(guildSz)
      local guild_name = GetGuildName(guild_it)
      if guild_name == arg then
        Rakkis.savedVariables.guild_id = guild_it
		d("[Rakkis Guild Points] Active guild has been set to: " .. GetGuildName(guild_it))
		return
      end
    end
  end
end

--Show currently active guild
function Rakkis.ShowGuild()
  if Rakkis.savedVariables.guild_id then
	d("[Rakkis Guild Points] Active Guild is set to: " .. GetGuildName(Rakkis.savedVariables.guild_id))
  else
    d("[Rakkis Guild Points] Active Guild has not been set.")
  end
end

--Hide/Show UI
function Rakkis.ToggleUI()
  if Rakkis.hidden then
    RakkisControl:SetHidden(false)
	Rakkis.hidden = false
  else
    RakkisControl:SetHidden(true)
	Rakkis.hidden = true
  end
end

--Help Menu
function Rakkis.ShowHelp()
  d("/rakkishelp -- Display this help message.")
  d("/rakkisui -- Toggle the UI on/off.")
  d("/rakkisshow -- Shows the currently configured guild.")
  d("/rakkisguild <Guild Name> -- Replace the configured with the given guild name.")
  d("/rakkisgroup <Event> <Points> <Initials> -- Applys points to everyone in your current group.")
  d("/rakkispoints <Event> <Points> <Initials> <@player> -- Applys points to the @player.")
  d("/rakkisnew <@player> <Initials> -- Create a new blank entry for @player.")
  d("/rakkislimit <1-10> -- Set the group limit size for updates")
end

function Rakkis.SetGroupLimit(newlimit)
  if not newlimit then
    d("[Rakkis Guild Points] No value found for new group update limit.")
    return
  end
  if newlimit < 1 then
    d("[Rakkis Guild Points] Value cannot be set to less than 1 for group update limit.")
    return
  end
  if newlimit > 10 then
    d("[Rakkis Guild Points] Value cannot be set to more than 10 for group update limit.")
    return
  end
  Rakkis.savedVariables.groupLimit = newlimit
end

--Add Points for Entire Group
function Rakkis.AddGroupPoints(args)
  local groupSize = GetGroupSize()
  if groupSize < 2 then
    d("[Rakkis Guild Points] You are not in a group")
	return
  end
  local done = 0
  for groupIt = 1,groupSize do
    local group_member = GetUnitDisplayName(GetGroupUnitTagByIndex(groupIt))
	local update = Rakkis.AddGuildPoints(args .. " " .. group_member)
	if update then
	  done = done + 1
	end
	if done > Rakkis.savedVariables.groupLimit then
	  d("[Rakkis Guild Points] Maximum group update limit reached - (" .. Rakkis.savedVariables.groupLimit .. ")")
	  return
	end
  end
  d("[Rakkis Guild Points] Group update complete.")
end

--Add Points for One Guild Member
function Rakkis.AddGuildPoints(args)
  local eventtype, point_var, initials, player = args:match("(%w+) (%d+) (%w+) (@[^ ]+)")
  if (eventtype == nil or point_var == nil or initials == nil or player == nil) then
    d("[Rakkis Guild Points] Missing update argument.")
    return false
  end
  local today = os.date("%m/%d/%Y")
  local points = tonumber(point_var)
  local member_idx = GetGuildMemberIndexFromDisplayName(Rakkis.savedVariables.guild_id, player)
  if member_idx then
    local _,note,rankIdx,_,_ = GetGuildMemberInfo(Rakkis.savedVariables.guild_id, member_idx)
    if rankIdx > 5 and note then
      local points_str = note:match("[pP]oints (%d+)")
	  if points_str then
		local point_num = tonumber(points_str)
		local empty_date = note:match(eventtype .. " (xx[/-]xx[/-]%d+)")
		local event_date = note:match(eventtype .. " (%d+[/-]%d+[/-]%d+) %w+")
		if empty_date then
		  note = note:gsub(eventtype .. " xx[/-]xx[/-]%d+", eventtype .. " " .. today .. " " .. initials)
		  note = note:gsub("Points %d+", "Points " .. point_num + points)
		  SetGuildMemberNote(Rakkis.savedVariables.guild_id, member_idx, note)
		  --d("[Rakkis Guild Points] Event information has been updated for " .. player)
		  return true
		elseif event_date then
		  if event_date ~= today then
			note = note:gsub(eventtype .. " (%d+[/-]%d+[/-]%d+) %w+", eventtype .. " " .. today .. " " .. initials)
			note = note:gsub("Points %d+", "Points " .. point_num + points)
			SetGuildMemberNote(Rakkis.savedVariables.guild_id, member_idx, note)
			--d("[Rakkis Guild Points] Event information has been updated for " .. player)
			return true
		  else
			--d("[Rakkis Guild Points] Event information was already updated today for " .. player)
			return false
		  end
		else
		  note = note .. "\n" .. eventtype .. " " .. today .. " " .. initials
		  note = note:gsub("Points %d+", "Points " .. point_num + points)
		  SetGuildMemberNote(Rakkis.savedVariables.guild_id, member_idx, note)
		  --d("[Rakkis Guild Points] Added event information for " .. player)
		  return true
		end
	  else
	    --d("[Rakkis Guild Points] Could not find points data for: " .. player)
		return false
	  end
    elseif rankIdx > 5 then
      --d("[Rakkis Guild Points] Could not update guild note for: " .. player)
	  return false
    else
      --d("[Rakkis Guild Points] Rank is officer or higher for " .. player)
	  return false
    end
  else
    --d("[Rakkis Guild Points] " .. player .. " was not found in configured guild")
	return false
  end
end

--Create Entry for New Guild Member
function Rakkis.NewMember(args)
  local player,initials = args:match("(@[^ ]+) (%w+)")
  if player == nil or initials == nil then
    d("[Rakkis Guild Points] Could not provision new guild member: missing arguments")
    return
  end
  local member_idx = GetGuildMemberIndexFromDisplayName(Rakkis.savedVariables.guild_id, player)
  if member_idx then
	local _,old_note,_,_,_ = GetGuildMemberInfo(Rakkis.savedVariables.guild_id, member_idx)
	Rakkis.savedVariables.previousNotes.member_idx = old_note
    local today = os.date("%m/%d/%Y")
    local note = "Joined " .. today .. " " .. initials .. "\n\nPoints 0\n\nJ xx/xx/" .. os.date("%Y") .. "\nD xx/xx/" .. os.date("%Y") .. "\nT xx/xx/" .. os.date("%Y")
    SetGuildMemberNote(Rakkis.savedVariables.guild_id, member_idx, note)
    d("[Rakkis Guild Points] " .. player .. " configured as new member")
  else
    d("[Rakkis Guild Points] " .. player .. " was not found in configured guild")
  end
end

SLASH_COMMANDS["/rakkisui"] = Rakkis.ToggleUI
SLASH_COMMANDS["/rakkishelp"] = Rakkis.ShowHelp
SLASH_COMMANDS["/rakkisgroup"] = Rakkis.AddGroupPoints
SLASH_COMMANDS["/rakkispoints"] = Rakkis.AddGuildPoints
SLASH_COMMANDS["/rakkisnew"] = Rakkis.NewMember
SLASH_COMMANDS["/rakkisguild"] = Rakkis.SetGuild
SLASH_COMMANDS["/rakkisshow"] = Rakkis.ShowGuild
SLASH_COMMANDS["/rakkislimit"] = Rakkis.SetGroupLimit

EVENT_MANAGER:RegisterForEvent(Rakkis.name, EVENT_ADD_ON_LOADED, Rakkis.OnAddOnLoaded)