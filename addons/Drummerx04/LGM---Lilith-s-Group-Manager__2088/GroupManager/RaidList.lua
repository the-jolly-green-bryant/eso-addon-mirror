----------------------------------
--Group List Keyboard
----------------------------------
local LGM = LGM or {}


-- Creates a Filtered List object
local RaidList = ZO_SortFilterList:Subclass()

local LGM_DATA = 1
local listSize, activeCount = 0, 0
local activeCountLabel
local characterInfoPanel


local function UpdateActiveCountLabel()
   activeCountLabel:SetText(string.format("Selected Raid Members: %3d / %3d", activeCount, listSize))
end

--Initialize a new FilteredList with a control that has $(parent)Headers and $(parent)List children
function RaidList:New(control)
   return  self:Initialize(control)
end

function RaidList:Initialize(control)
   --Control must have $(parent)List that inherits ZO_ScrollList
   self.control = control
   self:InitializeSortFilterList(control)
   self.label = GetControl(control, "HeadersDisplayNameName")
   characterInfoPanel = GetControl(control, "CharacterInfo")
   activeCountLabel = GetControl(control, "ActiveCount")
   activeCountLabel:SetHandler("OnEffectivelyShown", UpdateActiveCountLabel)

   ZO_ScrollList_AddDataType(self.list, LGM_DATA, "LGMRaidGroupRow", 30, function(control, data) self:SetupRaidRow(control, data) end)
   ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")

   self:SetEmptyText("No Raid Members")
   self.emptyRow:ClearAnchors()
   self.emptyRow:SetAnchor(TOPLEFT, GetControl(control, "List"), TOPLEFT, 0,0)
   self.emptyRow:SetWidth(280)

   self.inviteQueue = {}
   self.masterList = {}
   local sortKeys = {
      ["displayname"] = { caseInsensitive = true },
      ["active"] = {tiebreaker = "displayname"},
      --["active"] = {tiebreaker = "displayname"}
   }
   self.currentSortKey = "displayname"
   self.currentSortOrder = ZO_SORT_ORDER_UP
   self.sortFunction = function( listEntry1, listEntry2 )
      return(ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, sortKeys, self.currentSortOrder))
   end


   local function update(_, name1, name2, _, newStatus)
      local name = type(name1) == 'string' and name1 or name2
      local data = self.masterList[name]
      if data and newStatus ~= data.status then
         data.status = newStatus
         self:UpdateRow(data)
      end
      if self.activeInviteList then
         data = self.activeInviteList[name]
         if data and data.active and newStatus == PLAYER_STATUS_ONLINE then
            zo_callLater(
               function()
                  LGM.inviteList:InviteRaidMember(data.displayname, data.characterInfo)
               end, 2000)
         end
      end
   end
   EVENT_MANAGER:RegisterForEvent(LGM.name, EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, update)
   EVENT_MANAGER:RegisterForEvent(LGM.name, EVENT_FRIEND_PLAYER_STATUS_CHANGED, update)

   control:SetHandler("OnEffectivelyShown", function() self:SetOnlineStatuses() self:RefreshFilters() end)
   -- control:SetHandler("OnEffectivelyHidden", function() d("Raid Panel Hidden") end)

   return self
end




function RaidList:UpdateRow(data)
   local control = data.control
   if not control then return end

   -- GetControl(control,"Number"):SetText("("..tostring(data.sortIndex)..")")

   control:SetAlpha(data.active and 1.0 or 0.4)

   -- local statusControl = GetControl(control, "Status")
   local statusControl = GetControl(control, "Icon")
   if statusControl then
      statusControl:SetTexture(GetPlayerStatusIcon(data.status and data.status or PLAYER_STATUS_OFFLINE ))
   end
end

do
   local noNewIndexes = { __newindex = function() end }
   -- Create a secondary table to store elements to be associated with Saved
   -- Variable entries, but not actually stored within it
   local function defaults()
      local default = { sortIndex = -1, control = false, status = false, characterInfo = false}
      default.__index = default
      default.__newindex = default
      return setmetatable(default, noNewIndexes)
   end

   -- Prepares the data table to be compatible with saved variables and ZOS's scroll list.
   function RaidList:NewEntry(name, data)
      setmetatable(data, defaults() )

      self:SetPlayerStatus(data)

      -- Adjust the list tallies
      listSize = listSize + 1
      if data.active then activeCount = activeCount + 1 end

      return data
   end

end

-- Add a new player to the raid list if missing
function RaidList:AddRaidMember(name, groupName)
   if not self.masterList[name] then
      df("Adding %s to group: %s", name, groupName)

      local data = self:NewEntry(name, { displayname = name, active = true })
      self.masterList[name] = data
      table.insert(ZO_ScrollList_GetDataList(self.list), ZO_ScrollList_CreateDataEntry(LGM_DATA, data))
      self:RefreshFilters()
   end
end


--[[
   Sets the masterList to be the ACTUAL saved variables group list,
   so ALL changes to the status of the masterlist will be saved
   automatically.

--]]
function RaidList:LoadRaidInviteGroup(list)
   self.masterList = list

   listSize, activeCount = 0, 0
   for name, data in pairs(list) do
      data.inviteStatus = nil
      self:NewEntry(name, data)
   end

   self:RefreshData()
   --   self:SetOnlineStatuses()
   UpdateActiveCountLabel()

   self.label:SetText(LGM.SV.inviteGroup)
end

local function LgmGetCharacterInfo(GetInfo, index, guildId)
   local hasCharacter, charName, zoneName, classType, alliance, level, championRank, zoneId
   local infoTable = false
   if guildId then
      hasCharacter, charName, zoneName, classType, alliance, level, championRank, zoneId = GetInfo(guildId, index)
   else
      hasCharacter, charName, zoneName, classType, alliance, level, championRank, zoneId = GetInfo(index)
   end
   if hasCharacter then
      infoTable = {
         guildId = guildId,
         index = index,
         characterName = zo_strformat("<<1>>",charName),
         formattedZone = zo_strformat("<<1>>",zoneName),
         zoneId = zoneId,
         class = classType,
         level = level,
         championRank = championRank,
      }
   end
   return infoTable
end
function RaidList:SetPlayerStatus(data)
   -- if player is a guildie
   for guildIndex=1, GetNumGuilds() do
      local guildId = GetGuildId(guildIndex)
      local memberIndex = GetGuildMemberIndexFromDisplayName(guildId, data.displayname)
      if memberIndex then
         local _, _, _, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, memberIndex)
         data.status = playerStatus
         data.characterInfo = LgmGetCharacterInfo(GetGuildMemberCharacterInfo, memberIndex, guildId)
         return --self:UpdateRow(data)
      end
   end

   -- if player is a friend
   for i=1, GetNumFriends() do
      local displayName, _, playerStatus, _ = GetFriendInfo(i)
      if data.displayname == displayName then
         data.status = playerStatus
         data.characterInfo = LgmGetCharacterInfo(GetFriendCharacterInfo, i)
         return --self:UpdateRow(data)
      end
   end


end

function RaidList:SetOnlineStatuses()
   for _, data in pairs(self.masterList) do
      self:SetPlayerStatus(data)
   end
end


------------------------------------------------------------------------------------------------------------------------
-- ZO_List Stuff

function RaidList:SetupRaidRow( control, data )
   control.data = data
   data.control = control
   GetControl(control, "DisplayName"):SetText(data.displayname)
   --GetControl(control, "BG"):SetHidden(false)


   self:SetupRow(control, data)
   self:UpdateRow(data)
end


function RaidList:BuildMasterList()
   local scrollData = ZO_ScrollList_GetDataList(self.list)
   ZO_ClearNumericallyIndexedTable(scrollData)

   --for i, data in ipairs(self.masterList) do
   for name, data in pairs(self.masterList) do
      table.insert(scrollData, ZO_ScrollList_CreateDataEntry(LGM_DATA, data))
   end
end

-- function RaidList:FilterScrollList() end

function RaidList:SortScrollList()
   local scrollData = ZO_ScrollList_GetDataList(self.list)
   table.sort(scrollData, self.sortFunction)

end

local function RemoveMemberFromRaid(data)
   RaidList.masterList[data.displayname] = nil

   -- adjust list size tracker
   listSize = listSize - 1
   if data.active then activeCount = activeCount - 1 end
   UpdateActiveCountLabel()
   table.remove(ZO_ScrollList_GetDataList(RaidList.list), data.sortIndex)
   RaidList:RefreshFilters()

end

------------------------------------------------------------------------------------------------------------------------
-- Handlers
function RaidList:RowContextMenu(data)
   ClearMenu()
   AddMenuItem(GetString(SI_CHAT_PLAYER_CONTEXT_WHISPER), function() StartChatInput(nil, CHAT_CHANNEL_WHISPER, data.displayname) end)
   AddMenuItem("Invite to Group", function() LGM.inviteList:InviteRaidMember(data.displayname, data.characterInfo) end)
   AddMenuItem(GetString(SI_SOCIAL_MENU_VISIT_HOUSE), function() JumpToHouse(data.displayname) end)
   AddMenuItem("Remove From Raid Group", function() return RemoveMemberFromRaid(data) end)
   if GetUnitDisplayName('player') == '@Drummerx04' then
      AddMenuItem("Grab Table", function() LGMDataTable = data end)
      AddMenuItem("CharacterInfo", function() d("----------",getmetatable(data).status, "----------")end)
   end


   if(ZO_Menu_GetNumMenuItems() > 0) then
      ShowMenu()
   end

end
function RaidList:MouseClickHandler(control, button, shift)
   local data = control.data
   if button == 1 then
      if shift then
         LGM.inviteList:InviteRaidMember(data.displayname, data.characterInfo)
      else
         data.active = not data.active
         activeCount = activeCount + (data.active and 1 or -1)
         UpdateActiveCountLabel()
         self:UpdateRow(data)
      end

   elseif button == 2 then
      if shift then
         RemoveMemberFromRaid(data)
      else
         self:RowContextMenu(data)
      end
   end

end

function RaidList:InviteButtonHandler(control, button)
--   local data = control.data
   if button == 1 then
      control:SetText("Inviting ".. LGM.SV.inviteGroup)
      self.activeInviteList = self.masterList

      for k,v in pairs(self.masterList) do
               if v.active then
                  LGM.inviteList:InviteRaidMember(v.displayname)
               end
      end
   elseif button == 2 then
      control:SetText("Invite Group")
      self.activeInviteList = false
   end
end

function RaidList:AddDeleteButtonHandler(self, button)
   local new = "New Group"
   if button == 1 then
      -- Create "New Group"
      if LGM.SV.Groups[new] == nil then
         LGM.SV.Groups[new] = {}
      end
      LGM.SV.inviteGroup = new
      LGM:UpdateRaidModifiers(new)
   elseif button == 2 then
      -- Delete Current Group
      LGM.SV.Groups[LGM.SV.inviteGroup] = nil
      LGM.SV.inviteGroup = next(LGM.SV.Groups, LGM.SV.InviteGroup) or new
      if LGM.SV.inviteGroup == nil then
         -- Prevent nil groups
         LGM.SV.Groups[new] = {}
         LGM.SV.inviteGroup = new
      end

      LGM:UpdateRaidModifiers(LGM.SV.inviteGroup)
   end
end


function RaidList:ExitRow(row)
   if not self.lockedForUpdates then
      ZO_ScrollList_MouseExit(self.list, row)

      local data = ZO_ScrollList_GetData(row)
      if data then
         self:UpdateRow(data)
      end
      characterInfoPanel:SetHidden(true)

      self.mouseOverRow = nil
   end

end


function RaidList:EnterRow(row)
   if not selflockedForUpdates then
      ZO_ScrollList_MouseEnter(self.list, row)

      local data = ZO_ScrollList_GetData(row)
      if data then
         self:UpdateRow(data)
         LGM.SetupCharacterInfoBox(characterInfoPanel, row, data.characterInfo)
      end

      self.mouseOverRow = row
   end
end




function LGM_RaidList_OnInitialized(self)
   LGM.raidList = RaidList:New(self)
end

