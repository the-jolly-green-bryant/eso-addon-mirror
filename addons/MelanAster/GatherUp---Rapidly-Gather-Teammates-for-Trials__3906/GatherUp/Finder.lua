local GU = MAGatherUp

--Tool Function
local function IsOnline()
  local Online = {}
  local Offline = {}
  --Group List
  for i = 1, GetGroupSize() do
    local Tag = "group"..i
    local Name = GetUnitDisplayName(Tag)
    if Name then
      if IsUnitOnline(Tag) then
        Online[Name] = true
      else
        Offline[Name] = true
      end
    end
  end
  --Friends List
  for i = 1,  GetNumFriends() do
    local Name, _, Status = GetFriendInfo(i)
    if Name ~= "" then
      if Status == PLAYER_STATUS_ONLINE then
        Online[Name] = true
      elseif Status == PLAYER_STATUS_OFFLINE then
        Offline[Name] = true
      end
    end
  end
  --Guild List
  for a = 1, 5 do
    local GuildId =  GetGuildId(a)
    if GuildId ~= 0 then
      for b = 1, GetNumGuildMembers(GuildId) do
        local Name, _, _, Status = GetGuildMemberInfo(GuildId, b)
        if Name ~= "" then
          if Status == PLAYER_STATUS_ONLINE then
            Online[Name] = true
          elseif Status == PLAYER_STATUS_OFFLINE then
            Offline[Name] = true
          end
        end
      end
    end
  end
  --Result
  return Online, Offline
end

local function HaveRole(DisplayName)
  for i = 1, GetGroupSize() do
    local Tag = "group"..i
    if DisplayName == GetUnitDisplayName(Tag) then
      local Role = GetGroupMemberSelectedRole(Tag)
      if Role ~= 0 then
        return true, Tag
      else
        return false, Tag
      end
    end
  end
end

local function IsCharChanged(DisplayName, CharName)
  --Friends List
  for i = 1,  GetNumFriends() do
    local Name, _, Status = GetFriendInfo(i)
    if Status == PLAYER_STATUS_ONLINE and Name == DisplayName then
      local Character = select(2, GetFriendCharacterInfo(i))
      if Character:gsub("%^.+", "") ~= CharName then
        return true
      else
        return false
      end
    end
  end
  --Guild List
  for a = 1, 5 do
    local GuildId =  GetGuildId(a)
    if GuildId ~= 0 then
      for b = 1, GetNumGuildMembers(GuildId) do
        local Name, _, _, Status = GetGuildMemberInfo(GuildId, b)
        if Status == PLAYER_STATUS_ONLINE and Name == DisplayName then
          local Character = select(2,  GetGuildMemberCharacterInfo(GuildId, b))
          if Character:gsub("%^.+", "") ~= CharName then
            return true
          else
            return false
          end
        end
      end
    end
  end
  --Not Found
  return false
end

--Replace Non-English words with Space
local function OnlyEnglish(String)
  local CharTab = {utf8.codepoint(String, 1, -1)}
  for i = 1, #CharTab do
    if CharTab[i] > 127 then
      CharTab[i] = 32 
    end
  end
  return string.char(unpack(CharTab))
end

--Show Window
function GU.ShowWindow()
  if MAGU_TopLevel:IsHidden() then
    EVENT_MANAGER:RegisterForUpdate("GatherUP_Update", 1000, GU.UpdateWindow)
  else
    EVENT_MANAGER:UnregisterForUpdate("GatherUP_Update")
  end
  --Update dungeon and windows info
  GU.UpdateWindow()
  --Show window
  SCENE_MANAGER:ToggleTopLevel(MAGU_TopLevel)
end

--Update Info Display
function GU.UpdateWindow()
  --Leader Display
  GU.Controls[1]:GetNamedChild("_Name"):SetEditEnabled(false)
  GU.Controls[1]:GetNamedChild("_Name"):SetText(GetUnitDisplayName("player"))
  GU.Controls[1]:GetNamedChild("_Name"):SetColor(0, 1, 0)
  GU.Controls[1]:GetNamedChild("_Info"):SetText(
    GU.ICON_CLASS[GetUnitClassId("player")]..GetUnitChampionPoints("player")
  )
  --Member Display
  local Online, Offline = IsOnline()
  for i = 2, 12 do
    local Name = GU.Controls[i]:GetNamedChild("_Name")
    local Display = Name:GetText()
    local Info = GU.Controls[i]:GetNamedChild("_Info")
    if Display ~= "" then
      if IsPlayerInGroup(Display) then
        --In Group
        Name:SetColor(0, 1, 0)
        if Online[Display] then
          local Role, Tag = HaveRole(Display)
          if Role then
            --Online
            Info:SetText(GU.ICON_CLASS[GetUnitClassId(Tag)]..GetUnitChampionPoints(Tag))
          else
            --Change Character
            Info:SetText(GU.ICON_CHANGING)
          end
        else
          --Offline
          Info:SetText(GU.ICON_OFFLINE)
        end
      else
        --Not in Group
        Name:SetColor(1, 1, 1)
        if Online[Display] then
          --Online
          Info:SetText(GU.ICON_ONLINE)
        elseif Offline[Display] then
          --Offline
          Info:SetText(GU.ICON_OFFLINE)
        else
          --Unknown
          Info:SetText(GU.ICON_UNKNOWN)
        end
          --Full members
        if GetGroupSize() == 12 then
          Name:SetColor(1, 0, 0)
        end
      end
    else
      --None
      Name:SetColor(1, 1, 1)
      Info:SetText(GU.ICON_UNKNOWN)
    end
  end
  --SL Display
  for i = 1, 3 do
    if GU.SV.Slot[i]["Title"] then
      WINDOW_MANAGER:GetControlByName("MAGU_TopLevel_Slot_"..i):SetText(GU.SV.Slot[i]["Title"])
    else
      WINDOW_MANAGER:GetControlByName("MAGU_TopLevel_Slot_"..i):SetText(GU.Lang.BUTTON_FREESLOT)
    end
  end
  if MAGU_TopLevel_DeleteMode:GetState() == 1 then
    MAGU_TopLevel_DeleteMode:SetText(GU.Lang.BUTTON_DELETE)
  else
    MAGU_TopLevel_DeleteMode:SetText(GU.Lang.BUTTON_SAVELOAD)
  end
end

--Button Empty
function GU.Empty()
  GU.Start(MAGU_TopLevel_Queue, false)
  for i = 2, 12 do
    GU.Controls[i]:GetNamedChild("_Name"):SetText("")
  end
  GU.UpdateWindow()
end

--Button Save/Load
function GU.SaveLoad(Index)
  local Mode = MAGU_TopLevel_DeleteMode:GetState()
  if Mode == 1 then
    GU.SV.Slot[Index] = {}
  else
    if GU.SV.Slot[Index]["Title"] then
      GU.Empty()
      for i = 2, 12 do
        GU.Controls[i]:GetNamedChild("_Name"):SetText(GU.SV.Slot[Index][i-1])
      end
    else
      for i = 2, 12 do
        GU.SV.Slot[Index][i-1] = GU.Controls[i]:GetNamedChild("_Name"):GetText()
      end
      local Y, M, D = GetDateElementsFromTimestamp(GetTimeStamp())
      GU.SV.Slot[Index]["Title"] = Y.."."..M.."."..D
    end
  end
  GU.UpdateWindow()
end

--Button Analyze
function GU.Analyze()
  GU.Empty()
  local String = OnlyEnglish(MAGU_TopLevel_Paste:GetText())
  local NameTab = {}
  local Tep = {}
  MAGU_TopLevel_Paste:SetText("")
  for Fragment in string.gmatch(String, "@[%a%d%-%.'_]+") do
    NameTab[Fragment] = true
  end
  NameTab[GetUnitDisplayName("player")] = false
  for Name, Value in pairs(NameTab) do
    if Value == true then
      table.insert(Tep, Name)
    end
  end
  for i = 2, 12 do
    local Target = Tep[i-1] or ""
    GU.Controls[i]:GetNamedChild("_Name"):SetText(Target)
  end
end

--Button Start
local OnWork = false
function GU.Start(Control, Key)
  if Key == 0 then
    OnWork = false
  else --Left/Right
    OnWork = not OnWork
  end
  if OnWork then
    GU.BanAlert(true)
    if Key == 1 then --Left Click
      GU.Invite(true)
    end
    if Key == 2 then --Right Click
      Control:SetText(GU.Lang.BUTTON_QUEUE_STOP)
      EVENT_MANAGER:RegisterForUpdate("GatherUP_Cycle", 4000, GU.Invite)
    end
    d("[GU] "..GU.Lang.CHAT_START)
  else
    --Reset
    Control:SetText(GU.Lang.BUTTON_QUEUE_RUN)
    GU.BanAlert(false)
    EVENT_MANAGER:UnregisterForUpdate("GatherUP_Cycle")
    GU.InviteQueue = {}
    GU.UpdateWindow()
  end
end

-----------------
----Auto Part----
-----------------
GU.InviteQueue = {}

--Invite Cycle
function GU.Invite(Single)
  --Not Leader
  if IsUnitGrouped("player") and not IsUnitGroupLeader("player") then
    d("[GU] "..GU.Lang.BUTTON_QUEUE_NL)
    return
  end
  --Check Status
  for Name, Value in pairs(GU.InviteQueue) do
    if Value and IsPlayerInGroup(Name) then
      GU.InviteQueue[Name] = nil
    end
  end
  --Add Invite Queue from GatherUp
  local Online, Offline = IsOnline()
  for i = 2, 12 do
    local Name = GU.Controls[i]:GetNamedChild("_Name"):GetText()
    if Name ~= "" and not IsPlayerInGroup(Name) and not Offline[Name] then
      GU.InviteQueue[Name] = true
    end
  end
  --Invite
  for Name, Value in pairs(GU.InviteQueue) do
    if Value then
      GroupInviteByName(Name)
    end
  end
  --Check Character Change for Friends and Guild Members
  local AnyChange = false
  for i = 1, GetGroupSize() do
    local Tag = "group"..i
    local Name = GetUnitDisplayName(Tag)
    local Char = GetUnitName(Tag)
    if IsCharChanged(Name, Char) then
      GroupKickByName(Name)
      GU.InviteQueue[Name] = true
      AnyChange = true
      d("[GU] "..CHAT_CHANGED.." -> "..Name)
    end
  end
  --Single Mode
  if Single == true then
    if AnyChange then --Character Change, Need One More Cycle
      zo_callLater(function() GU.Invite(true) end, 3000)
    else --Single Done
      GU.Start(MAGU_TopLevel_Queue, 0)
    end
  end
end

--Ban Alert when Inviting
local AlertHander = ZO_AlertText_GetHandlers()[EVENT_GROUP_INVITE_RESPONSE]
function GU.BanAlert(Ban)
  local Chat = select(2, ZO_ChatSystem_GetEventCategoryMappings())
  if Ban then
    ZO_AlertText_GetHandlers()[EVENT_GROUP_INVITE_RESPONSE] = nil
    Chat[EVENT_GROUP_INVITE_RESPONSE] = nil
  else
    ZO_AlertText_GetHandlers()[EVENT_GROUP_INVITE_RESPONSE] = AlertHander
    Chat[EVENT_GROUP_INVITE_RESPONSE] = CHAT_CATEGORY_SYSTEM
  end
end

--When Error with Invitation
function GU.InviteError(_, _, Response, Display)
  if Response == GROUP_INVITE_RESPONSE_GROUP_FULL then
    GU.Start(MAGU_TopLevel_Queue, false)
    d("[GU] "..GetString(SI_GROUPINVITERESPONSE6))
  end
  if Response == GROUP_INVITE_RESPONSE_CANNOT_CREATE_GROUPS then
    GU.Start(MAGU_TopLevel_Queue, false)
    d("[GU] "..GetString(SI_GROUPINVITERESPONSE11))
  end
end

--Trial Start
function GU.TrialStart()
  if OnWork then
    GU.Start(MAGU_TopLevel_Queue, 0)
    d("[GU] "..GU.Lang.CHAT_DONE)
  end
end