-- This file is part of AutoInvite
--
-- (C) 2016 Scott Yeskie (Sasky)
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
local function dbg(msg) if AutoInvite.debug then d("|c999999" .. msg) end end
local function echo(msg) CHAT_SYSTEM.primaryContainer.currentBuffer:AddMessage("|CFFFF00" .. msg) end

local AI_SmallGroupListing = ZO_SortFilterList:Subclass()
local AI_GROUP_LIST_ENTRIES = {}

local AI_GROUP_DATA = 1

--local ENTRY_SORT_KEYS =
--{
--    ["displayName"] = { },
--}

local STATUS_ORDERING = setmetatable({
    ONLINE = 1,
    OFFLINE = 2,
    SENT = 3,
    QUEUE = 4,
    GROUPED = 5,
    UNKNOWN = 6,
}, { __index = function() return 6 end })

function AI_SmallGroupListing:New(control)
    local manager = ZO_SortFilterList.New(self, control)

    ZO_ScrollList_AddDataType(manager.list, AI_GROUP_DATA, "AI_SmallGroupListRow", 30, function(control, data) manager:SetupEntry(control, data) end)
    ZO_ScrollList_EnableHighlight(manager.list, "ZO_ThinListHighlight")

    manager:SetEmptyText(GetString(SI_AUTO_INVITE_NO_GROUP_MESSAGE))
    manager.emptyRow:ClearAnchors()
    manager.emptyRow:SetAnchor(TOPLEFT, manager.control, TOPLEFT, 270, 100)
    manager.emptyRow:SetWidth(280)
    manager:SetAlternateRowBackgrounds(true)
    manager:RefreshData()

    manager.sortHeaderGroup:SelectHeaderByKey("displayName")

    local function Update()
        manager:RefreshData()
    end

--    local function UpdateSingle(name)
--        manager:updateSingle(name)
--    end

    ZO_PreHook(GROUP_LIST, "FilterScrollList", function()
        dbg("Hooked FilterScrollList")
        if not hookedMasterList then
            manager:RefreshData()
        end
    end)

--    control:RegisterForEvent(EVENT_GROUP_MEMBER_LEFT, Update)
    control:RegisterForEvent(EVENT_GROUP_MEMBER_JOINED, Update)
--    control:RegisterForEvent(EVENT_GROUP_MEMBER_KICKED, Update)
--    control:RegisterForEvent(EVENT_GROUP_DISBANDED, Update)
--    control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, Update)

    AI_SMALL_GROUP_LIST_FRAGMENT = ZO_FadeSceneFragment:New(AI_SmallGroupList)

    return manager
end

function AI_SmallGroupListing:updateSingle(name)
    dbg("Calling AI_SmallGroupListing:updateSingle()")
    --Used for sent invite, invite declined, add to queue
    --Updates that one entry then
    if AI_GROUP_LIST_ENTRIES[name] then
        AI_GROUP_LIST_ENTRIES[name]:Update()
    elseif name then
        dbg("Name " .. name .. " not found.")
        AI_GROUP_LIST_ENTRIES[name] = AI_SLG_Entry.New(name)
    end

    self:RefreshFilters()
end

function AI_SmallGroupListing:removeSingle(name)
    dbg("Calling AI_SmallGroupListing:updateSingle()")
    AI_GROUP_LIST_ENTRIES[name] = nil
    self:RefreshFilters()
end

function AI_SmallGroupListing:getStatus(data)
    --TODO: Make this a LUT
    local status = data.status
    if status == STATUS_ORDERING.ONLINE then
        return "|c33CC33Online"
    end

    if status == STATUS_ORDERING.OFFLINE then
        return "|c666666Offline"
    end

    if status == STATUS_ORDERING.SENT then
        return "|c999966Sent"
    end

    if status == STATUS_ORDERING.QUEUE then
        return "|c999999Queue"
    end

    if status == STATUS_ORDERING.GROUPED then
        return "|cFB2B2BGrouped"
    end

    return ""
end

function AI_SmallGroupListing:SetupEntry(control, data)
    ZO_SortFilterList.SetupRow(self, control, data)

    control.displayName = data.displayName

    GetControl(control, "DisplayName"):SetText(data.displayName)
    GetControl(control, "Status"):SetText(self:getStatus(data))
    --GetControl(control, "BG"):SetWidth(300)
end

function AI_SmallGroupListing.CompareMembers(listEntry1, listEntry2)
    local d1 = listEntry1.data
    local d2 = listEntry2.data

    if d1.status == d2.status then
        return string.lower(d1.displayName) < string.lower(d2.displayName)
    else
        return d1.status < d2.status
    end
end

local function addTestCase(name, status, arg)
    AI_GROUP_LIST_ENTRIES[name] = AI_SLG_Entry.NewDefined(name, status, arg)
end

function AI_SmallGroupListing:BuildMasterList()
    dbg("Calling AI_SmallGroupListing:BuildMasterList()")
    AI_GROUP_LIST_ENTRIES = {}

    for name, time in pairs(AutoInvite.sentInvite) do
        AI_GROUP_LIST_ENTRIES[name] = AI_SLG_Entry.NewDefined(name, STATUS_ORDERING.SENT, time)
    end

    for _, name in pairs(AutoInvite.__getQueue()) do
        AI_GROUP_LIST_ENTRIES[name] = AI_SLG_Entry.NewDefined(name, STATUS_ORDERING.QUEUE)
    end

    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        local name = GetUnitName(tag)
        AI_GROUP_LIST_ENTRIES[name] = AI_SLG_Entry.New(name, tag)
    end

   --addTestCase("Zaniira", 1)
   --addTestCase("Ravlor", 2)
   --addTestCase("Sasky", 1)
   --addTestCase("Jinsa", 3)
   --addTestCase("Sascii", 4)
end

function AI_SmallGroupListing:FilterScrollList()
    dbg("Calling AI_SmallGroupListing:FilterScrollList()")
    -- No filtering. Copy over from master list
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    for _, data in pairs(AI_GROUP_LIST_ENTRIES) do
        table.insert(scrollData, ZO_ScrollList_CreateDataEntry(AI_GROUP_DATA, data))
    end
end

function AI_SmallGroupListing:SortScrollList()
    dbg("Calling AI_SmallGroupListing:SortScrollList()")
    if (self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        table.sort(scrollData, self.CompareMembers)
    end
end

AI_SLG_Entry = {}
AI_SLG_Entry.__index = AI_SLG_Entry

--For debugging
function AI_SLG_Entry.NewDefined(name, status, arg)
    local self = setmetatable({}, AI_SLG_Entry)
    self.status = status
    self.displayName = name

    if status == STATUS_ORDERING.queue then
        self.position = arg
    else
        self.time = arg
    end

    return self
end

function AI_SLG_Entry:Update()
    local name = self.displayName or ""
    local tag = self.unitName

    local grouped = IsPlayerInGroup(name) and not AutoInvite:IsPlayerInSameGroup(name)
    if grouped then
        self.status = STATUS_ORDERING.GROUPED
        return;
    end
    if GetUnitName(tag) == name then
        local offline = AutoInvite.kickTable[name]
        if IsUnitOnline(tag) then
            self.status = STATUS_ORDERING.ONLINE
        else
            self.status = STATUS_ORDERING.OFFLINE
            self.time = offline
        end
    else
        local sent = AutoInvite:IsInviteSent(name)
        if sent then
            self.status = STATUS_ORDERING.SENT
            self.time = sent
        else
            local queue = AutoInvite:IsInQueue(name)
            if queue then
                self.status = STATUS_ORDERING.QUEUE
                --self.position = queue
            else
                dbg("Unknown status for " .. name)
                AI_GROUP_LIST_ENTRIES[name] = nil
            end
        end
    end
end

function AI_SLG_Entry.New(name, tag)
    local self = setmetatable({}, AI_SLG_Entry)
    self.status = STATUS_ORDERING.UNKNOWN
    self.displayName = name
    self.unitName = tag
    self:Update()
    return self
end

--Global XML Handlers


--function ZO_IgnoreListManager:IgnoreListPanelRow_OnMouseUp(control, button, upInside)
--    if(button == 2 and upInside) then
--        ClearMenu()
--
--        local data = ZO_ScrollList_GetData(control)
--        if data then
--            AddMenuItem(GetString(SI_SOCIAL_MENU_EDIT_NOTE), GetNoteEditFunction(self.control, data.displayName))
--            AddMenuItem(GetString(SI_IGNORE_MENU_REMOVE_IGNORE), function() RemoveIgnore(data.displayName) end)
--
--            self:ShowMenu(control)
--        end
--    end
--end

function AI_SmallGroupListing_OnMouseEnter(control)
    MINI_GROUP_LIST:Row_OnMouseEnter(control)
end

function AI_SmallGroupListing_OnMouseExit(control)
    MINI_GROUP_LIST:Row_OnMouseExit(control)
end

--function AI_SmallGroupListing_OnMouseUp(control, button, upInside)
--    MINI_GROUP_LIST:IgnoreListPanelRow_OnMouseUp(control, button, upInside)
--end

function AI_SmallGroupListing_OnInitialized(self)
    MINI_GROUP_LIST = AI_SmallGroupListing:New(self)
end
