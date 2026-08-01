----------------------------------
--Group List Keyboard
----------------------------------
local LGM = LGM or {}


-- Creates a Filtered List object
local InviteList = ZO_SortFilterList:Subclass()
local characterInfoPanel
local LGM_DATA = 1

--Initialize a new FilteredList with a control that has $(parent)Headers and $(parent)List children
function InviteList:New(control)
   return  self:Initialize(control)
end

function InviteList:Initialize(control)
   --Control must have $(parent)List that inherits ZO_ScrollList
   self:InitializeSortFilterList(control)

   characterInfoPanel = GetControl(control, "CharacterInfo")

   ZO_ScrollList_AddDataType(self.list, LGM_DATA, "LGMInviteRow", 30, function(control, data) self:SetupInviteRow(control, data) end)
   ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")

   self:SetEmptyText("No Group Members or Invites")
   self.emptyRow:ClearAnchors()
   self.emptyRow:SetAnchor(TOPLEFT, GetControl(control, "List"), TOPLEFT, 0, 0)
   self.emptyRow:SetWidth(280)

   local sortKeys = {
      ["displayName"] = { caseInsensitive = true },
   }
   self.currentSortKey = "displayName"
   self.currentSortOrder = ZO_SORT_ORDER_UP
   self.sortFunction = function( listEntry1, listEntry2 )
      return(ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, sortKeys, self.currentSortOrder))
   end
   self.masterList = {}

   ------------------------------------------------------------------------------------------------------------------------
   -- ~/programs/eso/esoui/esoui/common/globals/shareddialogs.lua
   ------------------------------------------------------------------------------------------------------------------------


   --Generate Grouped Members in list
   control:SetHandler("OnEffectivelyShown", function()
                         self.isShowing = true
                         if self.isDirty then
                            self:RefreshData()
                            self.isDirty = false
                         end
                      end)
   control:SetHandler("OnEffectivelyHidden", function() self.isShowing = false end)

   self:RefreshData()

   return self
end

function InviteList:RegisterHandlers()
   local function refreshGroup()
      self:RefreshGroupList()
   end
   -- Bind LGM group refresh to ZOS's group refresh
   -- local GroupAPIRefresh = GROUP_LIST_MANAGER.BuildMasterList
   -- function GROUP_LIST_MANAGER:BuildMasterList()
   --    GroupAPIRefresh(self)
   --    refreshGroup()
   -- end

   local function roleChanged(_, unitTag, roleId)
      local data = self.masterList[GetUnitDisplayName(unitTag)]
      if data then
            self:UpdateRow(data)
      end
   end

   EVENT_MANAGER:RegisterForEvent(LGM.name, EVENT_LEADER_UPDATE, refreshGroup)
   EVENT_MANAGER:RegisterForEvent(LGM.name, EVENT_GROUP_MEMBER_JOINED, refreshGroup)
   EVENT_MANAGER:RegisterForEvent(LGM.name, EVENT_PLAYER_ACTIVATED, refreshGroup)
   EVENT_MANAGER:RegisterForEvent(LGM.name, EVENT_GROUP_MEMBER_CONNECTED_STATUS, refreshGroup)
   EVENT_MANAGER:RegisterForEvent(LGM.name, EVENT_GROUP_MEMBER_ROLE_CHANGED, roleChanged)
   EVENT_MANAGER:RegisterForEvent(LGM.name, EVENT_GROUP_MEMBER_LEFT, function(...) self:GroupMemberLeft(...) end)
   EVENT_MANAGER:RegisterForEvent(LGM.name, EVENT_GROUP_INVITE_RESPONSE, function(...) self:OnInviteReply(...) end)
end
------------------------------------------------------------------------------------------------------------------------
-- Suggestion Handlers
do
   local eventHandle = "LGMSuggestions"
   local function ScanChat(_, channel, fromName, text, isCustomerService, fromDisplayName)
      if channel == CHAT_CHANNEL_PARTY or channel == CHAT_CHANNEL_WHISPER then
         local _,_,name = text:find("(@%w+)")
         if name and not InviteList.masterList[name] then
            local data = InviteList:NewEntry(name)
            data.inviteStatus = "Suggest"
            data.characterName = fromDisplayName
            InviteList:UpdateRow(data)
         end
      end
   end
   function InviteList:SuggestionRegistrationHandler(register)
      if register then
         EVENT_MANAGER:RegisterForEvent(eventHandle, EVENT_CHAT_MESSAGE_CHANNEL, ScanChat)
      else
         EVENT_MANAGER:UnregisterForEvent(eventHandle, EVENT_CHAT_MESSAGE_CHANNEL)
      end

   end
end

------------------------------------------------------------------------------------------------------------------------
-- Offline Handlers
do
   local autoKickRegister = "LGMKickOfflines"
   local registered = false
   function InviteList:KickRegistrationSetter(offlineCount)
      if not registered and LGM.SV.kickTime > 0 and offlineCount > 0 and IsGroupModificationAvailable() and IsUnitGroupLeader('player') then
         EVENT_MANAGER:RegisterForUpdate(autoKickRegister, 5000, function() self:UpdateOfflines() end)
         registered = true
      elseif registered and (LGM.SV.kickTime == 0 or offlineCount == 0 or not IsGroupModificationAvailable() or not IsUnitGroupLeader('player')) then
         EVENT_MANAGER:UnregisterForUpdate(autoKickRegister)
         registered = false
      end
   end
end

function InviteList:KickTimeGetFunc()
   return function()
      self:KickRegistrationSetter(0)
      return LGM.SV.kickTime
   end
end


function InviteList:KickTimeSetFunc()
   return function(time)
      LGM.SV.kickTime = time
      self:KickRegistrationSetter(0)
   end
end

function InviteList:UpdateOfflines()
   local time = os.time()

   for _, data in pairs(self.masterList) do
      if data.unitTag and not IsUnitOnline(data.unitTag) then
         if not data.kickTime then
            data.kickTime = os.time()
         end

         if os.difftime(time, data.kickTime) >= LGM.SV.kickTime and GetGroupSize() > 2 then
            df("Auto Kicking: %s", tostring(GetUnitDisplayName(data.unitTag)))
            GroupKick(data.unitTag)
         end
      else
         data.kickTime = false
      end
   end
end
------------------------------------------------------------------------------------------------------------------------
-- ZO_List Specific Stuff

function InviteList:BuildMasterList()
   local scrollData = ZO_ScrollList_GetDataList(self.list)
   ZO_ClearNumericallyIndexedTable(scrollData)

   for name, data in pairs(self.masterList) do
      table.insert(scrollData, ZO_ScrollList_CreateDataEntry(LGM_DATA, data))
   end
end


function InviteList:SortScrollList()
   local scrollData = ZO_ScrollList_GetDataList(self.list)
   table.sort(scrollData, self.sortFunction)

end

--Callback called by "ZO_ScrollList_CreateDataEntry" to setup a row
function InviteList:SetupInviteRow( control, data )
   control.data = data
   data.control = control

   GetControl(control, "DisplayName"):SetText(data.displayName)
   GetControl(control, "BG"):SetHidden(false)

   self:SetupRow(control, data)
   self:UpdateRow(data)
end


------------------------------------------------------------------------------------------------------------------------
-- Misc


function InviteList:UpdateRow(data)
   local control = data.control
   if not control then return end
   local statusControl = GetControl(control, "Status")
   local classControl = GetControl(control, "ClassIcon")
   local roleControl = GetControl(control, "RoleIcon")
   -- GetControl(control,"Number"):SetText("("..tostring(data.sortIndex)..")")

   control:SetAlpha(data.active and 1.0 or 0.4)


   if data.isGroup then
      local class = GetClassIcon(data.class)
      local role = GetRoleIcon(data.role)
      if class then
         classControl:SetTexture(class)
      end
      classControl:SetHidden(not class)
      if role then
         roleControl:SetTexture(role)
      end
      roleControl:SetHidden(not role)
   else
      classControl:SetHidden(true)
      roleControl:SetHidden(true)
   end



   --d(data.displayName, data.inviteStatus)
   statusControl:SetText(data.inviteStatus)
   GetControl(control, "DisplayName"):SetColor(0.4627, 0.7373, 0.7647)
   if data.inviteStatus == "Grouped" then
      if data.leader then -- and IsUnitGroupLeader(data.unitTag) then
         GetControl(control, "DisplayName"):SetColor(0.9,0.86,0.12) --gold
      end
      if data.online then--data.unitTag and IsUnitOnline(data.unitTag) then
         statusControl:SetColor(0,1,0.14) -- Green
      else
         statusControl:SetColor(0.8,0.2,0.23) -- Red
      end
   elseif data.inviteStatus == "Sent" then
      statusControl:SetColor(1,0.7,0) -- Orange
   elseif data.inviteStatus == "Pending" then
      statusControl:SetColor(1,1,0) -- Yellow
   elseif data.inviteStatus == "Suggest" then
      statusControl:SetColor(0.4,0.1,0.8) -- Purple/blue
   else
      statusControl:SetColor(1,0.2,0) -- Red
   end
end

local NoDataEntryField = function(t, k, v) if k ~= "dataEntry" then rawset(t,k,v) end end
do
   local  defaults = {
      --__index = { inviteStatus = "", active = true, },
      -- __newindex = function(t, k, v) if t[k] ~= nil then rawset(t,k,v) end end,
      __newindex = NoDataEntryField,

   }
   function InviteList:NewEntry(name, skipRefresh)
      local data = setmetatable({displayName = name, inviteStatus = "", active = true}, defaults)

      self.masterList[name] = data

      table.insert(ZO_ScrollList_GetDataList(self.list), ZO_ScrollList_CreateDataEntry(LGM_DATA, data))
      if not skipRefresh then
         self:RefreshFilters()
      end

      return data
   end
end
function InviteList:ClearAll()
   self.masterList = {}
   self:RefreshData()
end





------------------------------------------------------------------------------------------------------------------------
-- Group Members Changed
function InviteList:RefreshGroupList()
   local offlineCount = 0
   local AltCharacterName
   --d("Refresh Group", "-------")
   for i = 1, GetGroupSize() do
      --local info = GROUP_LIST_MANAGER.masterList[i]

      local tag = GetGroupUnitTagByIndex(i)
      local displayName = GetUnitDisplayName(tag)
      if displayName and not AreUnitsEqual('player', tag) then

         local charName = GetUnitName(tag)
         local online = IsUnitOnline(tag)

         self.masterList[charName] = nil

         local data = self.masterList[displayName]
         if not data then -- Create new entry
            data = self:NewEntry(displayName)
            data.unitTag = tag
         elseif data.characterName ~= charName then
            --An Alternate character detected
            if not data.characterName then
               data.characterName = charName
               data.unitTag = tag
            elseif online then
               -- charName is the character to keep
               AltCharacterName = data.characterName
               data.characterName = charName
               data.unitTag = tag
            else
               -- charName is the character to kick
               AltCharacterName = charName
            end
         else -- Otherwise just update the tag
            data.unitTag = tag
         end


         data.formattedZone = ZO_CachedStrFormat(SI_ZONE_NAME, GetUnitZone(tag))
         data.class = GetUnitClassId(tag)
         data.leader = IsUnitGroupLeader(tag)
         data.characterName = charName
         data.online = online
         data.role = GetGroupMemberAssignedRole(tag)
         if not online then
            offlineCount = offlineCount + 1
         end

         data.inviteStatus = "Grouped"

      end


   end -- for

   if IsUnitGroupLeader('player') and AltCharacterName and LGM.SV.autoAltKick and GetGroupSize() > 2 then
      df("Auto Alt Kick (debug): %s", AltCharacterName)
      GroupKickByName(AltCharacterName)
   end

   if self.isShowing then
      self:RefreshData()
      self.isDirty = false
   else
      self.isDirty = true
   end

   if IsUnitGrouped('player') then
      KEYBIND_STRIP:UpdateKeybindButtonGroup(LGM.keybindStripDescriptor)
   end

   self:KickRegistrationSetter(offlineCount)
end

do
   local reasonMap = {

      [GROUP_LEAVE_REASON_DESTROYED] = "Destroyed",
      [GROUP_LEAVE_REASON_DISBAND] = "Disband",
      [GROUP_LEAVE_REASON_KICKED] = "Kicked",
      [GROUP_LEAVE_REASON_LEFT_BATTLEGROUND] = "BGs",
      [GROUP_LEAVE_REASON_VOLUNTARY] = "Left",
   }

   local deferId = nil

   function InviteList:GroupMemberLeft(_, _, reason, isLocalPlayer, isLeader, displayName, actionRequiredVote)
      local data = self.masterList[displayName]
      if data then
         data.inviteStatus = reasonMap[reason] or "Left"
         data.unitTag = false
         data.kickTime = false
      end

      self:RefreshGroupList()

      if isLocalPlayer then
         if deferId then
            zo_removeCallLater(deferId)
            deferId = nil
         end
         deferId = zo_callLater(function()
            if not IsUnitGrouped('player') then
               LGM:DisableInvites()
            end
            deferId = nil
         end, 120000)
      end

      if not IsUnitGrouped('player') then
         KEYBIND_STRIP:UpdateKeybindButtonGroup(LGM.keybindStripDescriptor)
      end
   end
end
------------------------------------------------------------------------------------------------------------------------
-- Invite Stuff
do
   local responseMap = {
      [GROUP_INVITE_RESPONSE_ACCEPTED] = "ACCEPTED",
      [GROUP_INVITE_RESPONSE_ALREADY_GROUPED] = "Another",
      [GROUP_INVITE_RESPONSE_CANNOT_CREATE_GROUPS] = "Cannot",
      [GROUP_INVITE_RESPONSE_REQUEST_FAIL_ALREADY_GROUPED] = "OtherGroup",
      [GROUP_INVITE_RESPONSE_REQUEST_FAIL_GROUP_FULL] = "Full",
      [GROUP_INVITE_RESPONSE_CONSIDERING_OTHER] = "Pending",
      [GROUP_INVITE_RESPONSE_DECLINED] = "Declined",
      [GROUP_INVITE_RESPONSE_GENERIC_JOIN_FAILURE] = "Failure",
      [GROUP_INVITE_RESPONSE_GROUP_FULL] = "Full",
      [GROUP_INVITE_RESPONSE_IGNORED] = "Ignored",
      [GROUP_INVITE_RESPONSE_INVITED] = "Invited",
      [GROUP_INVITE_RESPONSE_IN_BATTLEGROUND] = "Battleground",
      [GROUP_INVITE_RESPONSE_ONLY_LEADER_CAN_INVITE] = "NotLeader",
      [GROUP_INVITE_RESPONSE_OTHER_ALLIANCE] = "Alliance",
      [GROUP_INVITE_RESPONSE_PLAYER_NOT_FOUND] = "Offline",
      [GROUP_INVITE_RESPONSE_SELF_INVITE] = "Dumbass",
   }
   function InviteList:OnInviteReply(_, characterName, response, displayName)
      local name = displayName ~= "" and displayName or characterName

      --Ideally this will always be true
      if name ~= "" then
         local data = self.masterList[name] or self:NewEntry(name)
         data.inviteStatus = responseMap[response] or "Failed"
         self:UpdateRow(data)
      end
   end
end

function InviteList:AddToInviteQueue(data, characterInfo)
   LGM.GroupInviteByName(data.displayName)
   data.inviteStatus = "Sent"
   self:UpdateRow(data)
end

function InviteList:InviteRaidMember(name, characterInfo)
   local data = self.masterList[name] or self:NewEntry(name)
   local isOffline = data.unitTag and not IsUnitOnline(data.unitTag)

   if characterInfo then
      data.class = characterInfo.class
      data.formattedZone = characterInfo.formattedZone
      data.characterName = characterInfo.characterName
   end

   if GetGroupSize() < LGM.SV.maxSize then
      -- invite if the group member isn't grouped or is grouped but is offline
      if data and (data.inviteStatus ~= "Grouped" or isOffline) then
         self:AddToInviteQueue(data, characterInfo)
      end
   else
      data.inviteStatus = "LGM Max"
      self:UpdateRow(data)
   end
end


------------------------------------------------------------------------------------------------------------------------
-- Handlers

function InviteList:RowContextMenu(data)
   ClearMenu()
   AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_WHISPER), function() StartChatInput(nil, CHAT_CHANNEL_WHISPER, data.displayName) end)
   if data.inviteStatus ~= "Grouped" then
      AddMenuItem("Invite Override", function() self:AddToInviteQueue(data) end)
   end
   AddMenuItem(GetString(SI_SOCIAL_MENU_VISIT_HOUSE), function() JumpToHouse(data.displayName) end)
   if data.unitTag then
      AddMenuItem(GetString(SI_SOCIAL_MENU_JUMP_TO_PLAYER), function() if CanJumpToGroupMember(data.unitTag) then JumpToGroupMember(data.displayName) end end)
                  if IsUnitGroupLeader('player') then
                     AddMenuItem(GetString(SI_GROUP_LIST_MENU_PROMOTE_TO_LEADER), function() GroupPromote(data.unitTag) end)
                     AddMenuItem(GetString(SI_GROUP_LIST_MENU_KICK_FROM_GROUP), function() GroupKick(data.unitTag) end)
                  end

   end
   AddMenuItem("Remove From List", function()
                  self.masterList[data.displayName] = nil
                  self:RefreshData()
   end)

   if GetUnitDisplayName('player') == '@Drummerx04' then
      AddMenuItem("Dump Data Table", function() d("-------",data) end)
   end
   if(ZO_Menu_GetNumMenuItems() > 0) then
      ShowMenu()
   end

end
function InviteList:MouseClickHandler(control, button, shift, alt)
   local data = control.data
   if button == 1 then
      if shift then
         self:AddToInviteQueue(data) -- Instant invite
      else
         data.active = not data.active
         self:UpdateRow(data)
      end
   elseif button == 2 then
      if shift and not alt then  -- Add to Raid List

         LGM.raidList:AddRaidMember(data.displayName, LGM.SV.inviteGroup)

      elseif not shift and alt then -- Instant Kick
         self.masterList[data.displayName] = nil
         self:RefreshData()
      else
         self:RowContextMenu(data)
      end
   end
end

-- Celestial Scarecrow
function InviteList:InviteButtonHandler(control, button, shift)
   --   local data = control.data
   if button == 1 then
      if shift then
         for name, data in pairs(self.masterList) do
            if data.active then
               LGM.raidList:AddRaidMember(name, LGM.SV.inviteGroup)
            end
         end
      else
         for k,data in pairs(self.masterList) do
            if data.active and data.inviteStatus ~= "Grouped" then
               self:InviteRaidMember(k)
            end
         end
      end
   else
      if shift then
         ZO_ClearTable(self.masterList)
      end
      self:RefreshGroupList()


   end
end


function InviteList:ExitRow(row)
   if not self.lockedForUpdates then
      ZO_ScrollList_MouseExit(self.list, row)

      local data = ZO_ScrollList_GetData(row)
      if data then
         ZO_Options_OnMouseExit(row)
      end
      characterInfoPanel:SetHidden(true)

      self.mouseOverRow = nil
   end
end


function InviteList:EnterRow(row)
   if not selflockedForUpdates then
      ZO_ScrollList_MouseEnter(self.list, row)

      local data = ZO_ScrollList_GetData(row)
      if data and data.characterName then
         if data.unitTag then
            data.class = GetUnitClassId(data.unitTag)
            data.formattedZone = zo_strformat("<<1>>",GetUnitZone(data.unitTag))
         end
         -- InitializeTooltip(InformationTooltip, row, BOTTOM, 100, 0, TOP)
         -- SetTooltipText(InformationTooltip, data.characterName or "")
         LGM.SetupCharacterInfoBox(characterInfoPanel, row, data)
      end

      self.mouseOverRow = row
   end
end

function LGM_InviteList_OnInitialized(self)
   LGM.inviteList = InviteList:New(self)
end

