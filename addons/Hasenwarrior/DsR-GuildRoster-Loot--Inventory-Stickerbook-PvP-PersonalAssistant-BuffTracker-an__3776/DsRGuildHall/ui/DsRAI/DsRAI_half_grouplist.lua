local function dbg(msg) if DsRAutoINV.debug then d("|c999999" .. msg) end end
local function echo(msg) CHAT_ROUTER:AddSystemMessage("|CFFFF00" .. msg) end

local DsRAI_SmallGroupListing = ZO_SortFilterList:Subclass()
local DsRAI_GROUP_LIST_ENTRIES = {}

local DsRAI_GROUP_DATA = 1

local STATUS_ORDERING = setmetatable({
    ONLINE  = 1,
    OFFLINE = 2,
    SENT    = 3,
    QUEUE   = 4,
    GROUPED = 5,
    UNKNOWN = 6,
}, { __index = function() return 6 end })

function DsRAI_SmallGroupListing:New(control, acctName, charName)
    local manager = ZO_SortFilterList.New(self, control)

    ZO_ScrollList_AddDataType(manager.list, DsRAI_GROUP_DATA, "DsRAI_SmallGroupListRow", 30, function(control, data) manager:SetupEntry(control, data) end)
    ZO_ScrollList_EnableHighlight(manager.list, "ZO_ThinListHighlight")

    manager:SetEmptyText(GetString(SI_DsRAI_NO_GROUP_MESSAGE))
    manager.emptyRow:ClearAnchors()
    manager.emptyRow:SetAnchor(TOP, ZO_GroupList, TOP, 0, 140)
    -- manager.emptyRow:SetAnchor(TOP, ZO_GroupList, TOP, -180, 30)
    manager.emptyRow:SetWidth(400)
    manager:SetAlternateRowBackgrounds(true)
    manager:RefreshData()

    manager.sortHeaderGroup:SelectHeaderByKey("displayName")

    local function Update()
        manager:RefreshData()
    end

    ZO_PreHook(GROUP_LIST, "FilterScrollList", function()
        dbg("Hooked FilterScrollList")
        if not hookedMasterList then
            manager:RefreshData()
        end
    end)

    control:RegisterForEvent(EVENT_GROUP_MEMBER_JOINED, Update)

    DsRAI_SMALL_GROUP_LIST_FRAGMENT = ZO_FadeSceneFragment:New(DsRAI_SmallGroupList)

    return manager
end

function DsRAI_SmallGroupListing:updateSingle(name, acctName, charName)
    dbg("Calling DsRAI_SmallGroupListing:updateSingle()")
    if DsRAI_GROUP_LIST_ENTRIES[name] then
        DsRAI_GROUP_LIST_ENTRIES[name]:Update()
    elseif name then
        dbg("Name " .. name .. " not found.")
        DsRAI_GROUP_LIST_ENTRIES[name] = AI_SLG_Entry.New(name)
    end

    self:RefreshFilters()
end

function DsRAI_SmallGroupListing:removeSingle(name, acctName, charName)
    dbg("Calling DsRAI_SmallGroupListing:updateSingle()")
    DsRAI_GROUP_LIST_ENTRIES[name] = nil
    self:RefreshFilters()
end

function DsRAI_SmallGroupListing:getStatus(data)
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

function DsRAI_SmallGroupListing:SetupEntry(control, data)
    ZO_SortFilterList.SetupRow(self, control, data)

    control.displayName = data.displayName

    GetControl(control, "DisplayName"):SetText(data.displayName)
    GetControl(control, "Status"):SetText(self:getStatus(data))
end

function DsRAI_SmallGroupListing.CompareMembers(listEntry1, listEntry2)
    local d1 = listEntry1.data
    local d2 = listEntry2.data

    if d1.status == d2.status then
        return string.lower(d1.displayName) < string.lower(d2.displayName)
    else
        return d1.status < d2.status
    end
end

function DsRAI_SmallGroupListing:BuildMasterList()
    dbg("Calling DsRAI_SmallGroupListing:BuildMasterList()")
    DsRAI_GROUP_LIST_ENTRIES = {}

    for name, time in pairs(DsRAutoINV.sentInvite) do
        DsRAI_GROUP_LIST_ENTRIES[name] = AI_SLG_Entry.NewDefined(name, STATUS_ORDERING.SENT, time)
    end

    for _, name in pairs(DsRAutoINV.__getQueue()) do
        DsRAI_GROUP_LIST_ENTRIES[name] = AI_SLG_Entry.NewDefined(name, STATUS_ORDERING.QUEUE)
    end

    for i = 1, GetGroupSize() do
        local tag  = GetGroupUnitTagByIndex(i)
        local name = GetUnitName(tag)
        DsRAI_GROUP_LIST_ENTRIES[name] = AI_SLG_Entry.New(name, tag)
    end
end

function DsRAI_SmallGroupListing:FilterScrollList()
    dbg("Calling DsRAI_SmallGroupListing:FilterScrollList()")
    -- No filtering. Copy over from master list
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    for _, data in pairs(DsRAI_GROUP_LIST_ENTRIES) do
        table.insert(scrollData, ZO_ScrollList_CreateDataEntry(DsRAI_GROUP_DATA, data))
    end
end

function DsRAI_SmallGroupListing:SortScrollList()
    dbg("Calling DsRAI_SmallGroupListing:SortScrollList()")
    if (self.currentSortKey ~= nil and self.currentSortOrder ~= nil) then
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        table.sort(scrollData, self.CompareMembers)
    end
end

AI_SLG_Entry = {}
AI_SLG_Entry.__index = AI_SLG_Entry

--For debugging
function AI_SLG_Entry.NewDefined(name, status, arg, acctName, charName)
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

    local grouped = IsPlayerInGroup(name) and not DsRAutoINV:IsPlayerInSameGroup(name)
    if grouped then
        self.status = STATUS_ORDERING.GROUPED
        return;
    end
    if GetUnitName(tag) == name then
        local offline = DsRAutoINV.kickTable[name]
        if IsUnitOnline(tag) then
            self.status = STATUS_ORDERING.ONLINE
        else
            self.status = STATUS_ORDERING.OFFLINE
            self.time = offline
        end
    else
        local sent = DsRAutoINV:IsInviteSent(name)
        if sent then
            self.status = STATUS_ORDERING.SENT
            self.time = sent
        else
            local queue = DsRAutoINV:IsInQueue(name)
            if queue then
                self.status = STATUS_ORDERING.QUEUE
                --self.position = queue
            else
                dbg("Unknown status for " .. name)
                DsRAI_GROUP_LIST_ENTRIES[name] = nil
            end
        end
    end
end

function AI_SLG_Entry.New(name, tag, acctName, charName)
    local self = setmetatable({}, AI_SLG_Entry)
    self.status = STATUS_ORDERING.UNKNOWN
    self.displayName = name
    self.unitName = tag
    self:Update()
    return self
end

function DsRAI_SmallGroupListing_OnMouseEnter(control)
    MINI_GROUP_LIST:Row_OnMouseEnter(control)
end

function DsRAI_SmallGroupListing_OnMouseExit(control)
    MINI_GROUP_LIST:Row_OnMouseExit(control)
end

function DsRAI_SmallGroupListing_OnInitialized(self)
    MINI_GROUP_LIST = DsRAI_SmallGroupListing:New(self)
end
