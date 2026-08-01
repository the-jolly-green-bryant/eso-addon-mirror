-- ZMS_UI.lua  –  Settings window for Zone Mount Switcher

ZMS     = ZMS or {}
ZMS.UI  = ZMS.UI or {}

-- Global function called by Bindings.xml
function ZMS_ToggleUI()
    ZMS.UI.Toggle()
end

local UI = ZMS.UI

-- =============================================================
-- i18n wrapper
-- =============================================================
local function L(id)
    local str = GetString(_G[id])
    return (str and str ~= "") and str or id
end

-- =============================================================
-- Internal state
-- =============================================================
UI.currentGroup = nil   -- selected group key, or "UNIVERSAL"
UI.currentTab   = "zones"
UI.initialized  = false

-- =============================================================
-- Shortcuts to child controls
-- =============================================================
local function Win()      return ZMS_UIWindow end
local function Left(s)    return ZMS_UIWindowLeft:GetNamedChild(s) end
local function Right(s)   return ZMS_UIWindowRight:GetNamedChild(s) end
local function LeftList() return ZMS_UIWindowLeftList end
local function ItemList() return ZMS_UIWindowRightItemList end

-- =============================================================
-- Utilities (local copies to avoid touching core)
-- =============================================================
local function AllGroupKeys()
    local all = {}
    for _, k in ipairs(ZMS.GROUP_KEYS or {}) do
        table.insert(all, k)
    end
    if ZMS.saved and ZMS.saved.customGroups then
        for k in pairs(ZMS.saved.customGroups) do
            table.insert(all, k)
        end
    end
    return all
end

local function IsCustomGroup(key)
    for _, k in ipairs(ZMS.GROUP_KEYS or {}) do
        if k == key then return false end
    end
    return true
end

local function GroupDisplayName(key)
    if key == "UNIVERSAL" then return L("ZMS_UI_UNIVERSAL_BTN") end
    if ZMS.saved and ZMS.saved.customGroups and ZMS.saved.customGroups[key] then
        return ZMS.saved.customGroups[key].displayName or key
    end
    return ZMS.GroupDisplayName(key)
end

local function GetCollName(id)
    if GetCollectibleInfo then return (GetCollectibleInfo(id)) end
    return "ID=" .. tostring(id)
end

local function IsUnlocked(id)
    return IsCollectibleUnlocked and IsCollectibleUnlocked(id) == true
end

local function GetActiveMount()
    if GetActiveCollectibleByType then
        return GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_MOUNT)
    end
    if GetActiveCollectibleId then
        return GetActiveCollectibleId(COLLECTIBLE_CATEGORY_TYPE_MOUNT)
    end
end

local function GetActivePet()
    if GetActiveCollectibleByType then
        return GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
    end
    if GetActiveCollectibleId then
        return GetActiveCollectibleId(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
    end
end

local function RemoveFromList(list, id)
    if not list then return end
    for i, v in ipairs(list) do
        if v == id then table.remove(list, i) return end
    end
end

-- =============================================================
-- Tab appearance
-- =============================================================
local function UpdateTabAppearance()
    local defs = {
        { key = "zones",  ctrl = Right("TabZones"),  base = L("ZMS_UI_TAB_ZONES")  },
        { key = "mounts", ctrl = Right("TabMounts"), base = L("ZMS_UI_TAB_MOUNTS") },
        { key = "pets",   ctrl = Right("TabPets"),   base = L("ZMS_UI_TAB_PETS")   },
    }
    for _, t in ipairs(defs) do
        if t.key == UI.currentTab then
            t.ctrl:SetText("|cFFFF00[ " .. t.base .. " ]|r")
        else
            t.ctrl:SetText(t.base)
        end
    end
end

-- =============================================================
-- Group row setup
-- =============================================================
function UI.SetupGroupRow(ctrl, data)
    local nameLabel = ctrl:GetNamedChild("Name")
    local bg        = ctrl:GetNamedChild("Bg")

    if data.key == UI.currentGroup then
        nameLabel:SetText("|cFFFF00" .. data.displayName .. "|r")
        bg:SetHidden(false)
    else
        nameLabel:SetText(data.displayName)
        bg:SetHidden(true)
    end

    ctrl:SetHandler("OnMouseUp", function(self, btn)
        if btn == MOUSE_BUTTON_INDEX_LEFT then
            if data.key == "UNIVERSAL" then
                UI.SelectUniversal()
            else
                UI.SelectGroup(data.key)
            end
        end
    end)
end

-- =============================================================
-- Item row setup
-- =============================================================
function UI.SetupItemRow(ctrl, data)
    ctrl:GetNamedChild("Name"):SetText(data.displayName)
    ctrl.itemData = data
end

-- =============================================================
-- Refresh group list
-- =============================================================
function UI.RefreshGroupList()
    if not UI.initialized then return end

    local list       = LeftList()
    local scrollData = ZO_ScrollList_GetDataList(list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    for _, k in ipairs(ZMS.GROUP_KEYS or {}) do
        table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, {
            key         = k,
            displayName = GroupDisplayName(k),
        }))
    end

    if ZMS.saved and ZMS.saved.customGroups then
        for k in pairs(ZMS.saved.customGroups) do
            table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, {
                key         = k,
                displayName = GroupDisplayName(k) .. L("ZMS_UI_CUSTOM_TAG"),
                isCustom    = true,
            }))
        end
    end

    ZO_ScrollList_Commit(list)
end

-- =============================================================
-- Refresh item list
-- =============================================================
function UI.RefreshItemList()
    if not UI.initialized then return end
    if not UI.currentGroup  then return end

    local list       = ItemList()
    local scrollData = ZO_ScrollList_GetDataList(list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    local function Add(id, name, idType)
        local label = name
        if idType ~= "zone" then
            label = label .. (IsUnlocked(id) and " |c00FF00[OK]|r" or " |cFF4444[locked]|r")
        end
        table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, {
            id = id, displayName = label, idType = idType,
        }))
    end

    if UI.currentGroup == "UNIVERSAL" then
        if UI.currentTab == "mounts" then
            for _, id in ipairs(ZMS.saved.universalMountIds or {}) do
                Add(id, GetCollName(id) or "?", "mount")
            end
        elseif UI.currentTab == "pets" then
            for _, id in ipairs(ZMS.saved.universalPetIds or {}) do
                Add(id, GetCollName(id) or "?", "pet")
            end
        end
    else
        local key = UI.currentGroup
        if UI.currentTab == "zones" then
            for _, zid in ipairs((ZMS.saved.zoneIdsByGroup or {})[key] or {}) do
                Add(zid, GetZoneNameById(zid) or ("Zone #" .. tostring(zid)), "zone")
            end
        elseif UI.currentTab == "mounts" then
            for _, id in ipairs((ZMS.saved.groupToMountIds or {})[key] or {}) do
                Add(id, GetCollName(id) or "?", "mount")
            end
        elseif UI.currentTab == "pets" then
            for _, id in ipairs((ZMS.saved.groupToPetIds or {})[key] or {}) do
                Add(id, GetCollName(id) or "?", "pet")
            end
        end
    end

    ZO_ScrollList_Commit(list)
end

-- =============================================================
-- Select group
-- =============================================================
function UI.SelectGroup(key)
    UI.currentGroup = key
    UI.RefreshGroupList()

    Right("GroupName"):SetText("|cFFFF00" .. GroupDisplayName(key) .. "|r")

    local isCustom = IsCustomGroup(key)
    Right("DeleteBtn"):SetHidden(not isCustom)
    Right("RenameBtn"):SetHidden(not isCustom)
    Right("TabZones"):SetHidden(false)
    Right("TabMounts"):SetHidden(false)
    Right("TabPets"):SetHidden(false)
    Right("AddBtn"):SetHidden(false)
    Right("ClearAllBtn"):SetHidden(false)

    if UI.currentTab == nil then UI.currentTab = "zones" end
    UI.SelectTab(UI.currentTab)
end

-- =============================================================
-- Select Universal
-- =============================================================
function UI.SelectUniversal()
    UI.currentGroup = "UNIVERSAL"
    UI.RefreshGroupList()

    Right("GroupName"):SetText(L("ZMS_UI_UNIVERSAL_TITLE"))
    Right("DeleteBtn"):SetHidden(true)
    Right("RenameBtn"):SetHidden(true)
    Right("TabZones"):SetHidden(true)
    Right("TabMounts"):SetHidden(false)
    Right("TabPets"):SetHidden(false)
    Right("AddBtn"):SetHidden(false)
    Right("ClearAllBtn"):SetHidden(false)

    if UI.currentTab == "zones" then UI.currentTab = "mounts" end
    UI.SelectTab(UI.currentTab)
end

-- =============================================================
-- Select tab
-- =============================================================
function UI.SelectTab(tab)
    UI.currentTab = tab
    UpdateTabAppearance()

    local addBtn = Right("AddBtn")
    if tab == "zones" then
        addBtn:SetText(L("ZMS_UI_ADD_ZONE"))
    elseif tab == "mounts" then
        addBtn:SetText(L("ZMS_UI_ADD_MOUNT"))
    else
        addBtn:SetText(L("ZMS_UI_ADD_PET"))
    end

    UI.RefreshItemList()
end

-- =============================================================
-- Add current item
-- =============================================================
function UI.AddCurrent()
    if not UI.currentGroup then return end

    local function AlreadyIn(list, id)
        for _, v in ipairs(list) do if v == id then return true end end
        return false
    end

    if UI.currentGroup == "UNIVERSAL" then
        if UI.currentTab == "mounts" then
            local id = GetActiveMount()
            if not id then d("|cFF4444[ZMS]|r " .. L("ZMS_UI_ERR_NO_MOUNT")) return end
            ZMS.saved.universalMountIds = ZMS.saved.universalMountIds or {}
            if AlreadyIn(ZMS.saved.universalMountIds, id) then
                d("|cFFFF00[ZMS]|r " .. L("ZMS_UI_ERR_UNIV_EXISTS")) return
            end
            table.insert(ZMS.saved.universalMountIds, id)
            d("|c87CEEB[ZMS]|r " .. string.format(L("ZMS_UI_OK_UNIV_MOUNT"), GetCollName(id) or "?"))
        elseif UI.currentTab == "pets" then
            local id = GetActivePet()
            if not id then d("|cFF4444[ZMS]|r " .. L("ZMS_UI_ERR_NO_PET")) return end
            ZMS.saved.universalPetIds = ZMS.saved.universalPetIds or {}
            if AlreadyIn(ZMS.saved.universalPetIds, id) then
                d("|cFFFF00[ZMS]|r " .. L("ZMS_UI_ERR_UNIV_EXISTS")) return
            end
            table.insert(ZMS.saved.universalPetIds, id)
            d("|c87CEEB[ZMS]|r " .. string.format(L("ZMS_UI_OK_UNIV_PET"), GetCollName(id) or "?"))
        end
    else
        local key = UI.currentGroup
        if UI.currentTab == "zones" then
            local zid = GetZoneId(GetUnitZoneIndex("player"))
            if not zid or zid <= 0 then d("|cFF4444[ZMS]|r " .. L("ZMS_UI_ERR_INVALID_ZONE")) return end
            ZMS.saved.zoneIdsByGroup[key] = ZMS.saved.zoneIdsByGroup[key] or {}
            if AlreadyIn(ZMS.saved.zoneIdsByGroup[key], zid) then
                d("|cFFFF00[ZMS]|r " .. L("ZMS_UI_ERR_ZONE_EXISTS")) return
            end
            table.insert(ZMS.saved.zoneIdsByGroup[key], zid)
            d("|c87CEEB[ZMS]|r " .. string.format(L("ZMS_UI_OK_ZONE_ADDED"),
                GetZoneNameById(zid) or ("Zone #" .. tostring(zid)), GroupDisplayName(key)))
        elseif UI.currentTab == "mounts" then
            local id = GetActiveMount()
            if not id then d("|cFF4444[ZMS]|r " .. L("ZMS_UI_ERR_NO_MOUNT")) return end
            ZMS.saved.groupToMountIds[key] = ZMS.saved.groupToMountIds[key] or {}
            if AlreadyIn(ZMS.saved.groupToMountIds[key], id) then
                d("|cFFFF00[ZMS]|r " .. L("ZMS_UI_ERR_MOUNT_EXISTS")) return
            end
            table.insert(ZMS.saved.groupToMountIds[key], id)
            d("|c87CEEB[ZMS]|r " .. string.format(L("ZMS_UI_OK_MOUNT_ADDED"),
                GroupDisplayName(key), GetCollName(id) or "?"))
        elseif UI.currentTab == "pets" then
            local id = GetActivePet()
            if not id then d("|cFF4444[ZMS]|r " .. L("ZMS_UI_ERR_NO_PET")) return end
            ZMS.saved.groupToPetIds[key] = ZMS.saved.groupToPetIds[key] or {}
            if AlreadyIn(ZMS.saved.groupToPetIds[key], id) then
                d("|cFFFF00[ZMS]|r " .. L("ZMS_UI_ERR_PET_EXISTS")) return
            end
            table.insert(ZMS.saved.groupToPetIds[key], id)
            d("|c87CEEB[ZMS]|r " .. string.format(L("ZMS_UI_OK_PET_ADDED"),
                GroupDisplayName(key), GetCollName(id) or "?"))
        end
    end

    UI.RefreshItemList()
end

-- =============================================================
-- Remove item via row X button
-- =============================================================
function UI.RemoveItemByRow(rowCtrl)
    local data = rowCtrl.itemData
    if not data then return end

    if UI.currentGroup == "UNIVERSAL" then
        if data.idType == "mount" then
            RemoveFromList(ZMS.saved.universalMountIds, data.id)
        elseif data.idType == "pet" then
            RemoveFromList(ZMS.saved.universalPetIds, data.id)
        end
    else
        local key = UI.currentGroup
        if data.idType == "zone" then
            RemoveFromList((ZMS.saved.zoneIdsByGroup or {})[key], data.id)
        elseif data.idType == "mount" then
            RemoveFromList((ZMS.saved.groupToMountIds or {})[key], data.id)
        elseif data.idType == "pet" then
            RemoveFromList((ZMS.saved.groupToPetIds or {})[key], data.id)
        end
    end

    UI.RefreshItemList()
end

-- =============================================================
-- Clear all (current tab)
-- =============================================================
function UI.ClearAll()
    if not UI.currentGroup then return end

    if UI.currentGroup == "UNIVERSAL" then
        if UI.currentTab == "mounts" then ZMS.saved.universalMountIds = {}
        elseif UI.currentTab == "pets" then ZMS.saved.universalPetIds = {} end
    else
        local key = UI.currentGroup
        if UI.currentTab == "zones" then ZMS.saved.zoneIdsByGroup[key] = {}
        elseif UI.currentTab == "mounts" then ZMS.saved.groupToMountIds[key] = {}
        elseif UI.currentTab == "pets" then ZMS.saved.groupToPetIds[key] = {} end
    end

    UI.RefreshItemList()
end

-- =============================================================
-- Delete current group
-- =============================================================
function UI.DeleteCurrentGroup()
    local key = UI.currentGroup
    if not key or key == "UNIVERSAL" then return end
    if not IsCustomGroup(key) then
        d("|cFF4444[ZMS]|r " .. L("ZMS_UI_ERR_DEFAULT_GROUP"))
        return
    end

    local displayName = GroupDisplayName(key)
    ZMS.saved.customGroups[key]    = nil
    ZMS.saved.zoneIdsByGroup[key]  = nil
    ZMS.saved.groupToMountIds[key] = nil
    ZMS.saved.groupToPetIds[key]   = nil

    UI.currentGroup = nil
    Right("GroupName"):SetText(L("ZMS_UI_SELECT_GROUP"))
    Right("DeleteBtn"):SetHidden(true)
    Right("RenameBtn"):SetHidden(true)
    Right("AddBtn"):SetHidden(true)
    Right("ClearAllBtn"):SetHidden(true)
    Right("TabZones"):SetHidden(true)
    Right("TabMounts"):SetHidden(true)
    Right("TabPets"):SetHidden(true)

    local ilist = ItemList()
    ZO_ClearNumericallyIndexedTable(ZO_ScrollList_GetDataList(ilist))
    ZO_ScrollList_Commit(ilist)

    UI.RefreshGroupList()
    d("|c87CEEB[ZMS]|r " .. string.format(L("ZMS_UI_OK_GROUP_DELETED"), displayName))
end

-- =============================================================
-- Create group dialog
-- =============================================================
function UI.OpenCreateGroupDialog()
    ZMS_UICreateDialog:GetNamedChild("KeyInput"):SetText("")
    ZMS_UICreateDialog:GetNamedChild("NameInput"):SetText("")
    ZMS_UICreateDialog:SetHidden(false)
    ZMS_UICreateDialog:BringWindowToTop()
end

function UI.ConfirmCreateGroup()
    local keyInput  = ZMS_UICreateDialog:GetNamedChild("KeyInput")
    local nameInput = ZMS_UICreateDialog:GetNamedChild("NameInput")
    if not keyInput or not nameInput then return end

    local keyRaw  = keyInput:GetText()
    local nameRaw = nameInput:GetText()

    if not keyRaw or keyRaw:match("^%s*$") then
        d("|cFF4444[ZMS]|r " .. L("ZMS_UI_ERR_KEY_REQUIRED"))
        return
    end

    local key         = keyRaw:upper():gsub("[%s%-]+", "_")
    local displayName = (nameRaw and not nameRaw:match("^%s*$")) and nameRaw or key

    for _, k in ipairs(AllGroupKeys()) do
        if k == key then
            d("|cFFFF00[ZMS]|r " .. string.format(L("ZMS_UI_ERR_KEY_EXISTS"), key))
            return
        end
    end

    ZMS.saved.customGroups             = ZMS.saved.customGroups or {}
    ZMS.saved.customGroups[key]        = { displayName = displayName }
    ZMS.saved.zoneIdsByGroup[key]      = {}
    ZMS.saved.groupToMountIds[key]     = {}
    ZMS.saved.groupToPetIds[key]       = {}

    ZMS_UICreateDialog:SetHidden(true)
    UI.RefreshGroupList()
    UI.SelectGroup(key)
    d("|c87CEEB[ZMS]|r " .. string.format(L("ZMS_UI_OK_GROUP_CREATED"), displayName, key))
end

-- =============================================================
-- Rename dialog
-- =============================================================
function UI.OpenRenameDialog()
    if not UI.currentGroup or UI.currentGroup == "UNIVERSAL" then return end
    local nameInput = ZMS_UIRenameDialog:GetNamedChild("NameInput")
    if nameInput then nameInput:SetText(GroupDisplayName(UI.currentGroup)) end
    ZMS_UIRenameDialog:SetHidden(false)
    ZMS_UIRenameDialog:BringWindowToTop()
end

function UI.ConfirmRename()
    local nameInput = ZMS_UIRenameDialog:GetNamedChild("NameInput")
    if not nameInput then return end
    local newName = nameInput:GetText()

    if not newName or newName:match("^%s*$") then
        d("|cFF4444[ZMS]|r " .. L("ZMS_UI_ERR_NAME_EMPTY"))
        return
    end

    local key = UI.currentGroup
    if not key or key == "UNIVERSAL" then return end

    ZMS.saved.customGroups[key].displayName = newName
    ZMS_UIRenameDialog:SetHidden(true)
    Right("GroupName"):SetText("|cFFFF00" .. newName .. "|r")
    UI.RefreshGroupList()
    d("|c87CEEB[ZMS]|r " .. string.format(L("ZMS_UI_OK_GROUP_RENAMED"), newName))
end

-- =============================================================
-- Toggle account-wide / per-character scope
-- =============================================================
function UI.ToggleAccountWide()
    if not ZMS.svAccount then return end

    local newValue = not (ZMS.svAccount.accountWide ~= false)
    ZMS.svAccount.accountWide = newValue
    ZMS.ApplySavedVarsScope()

    UI.UpdateScopeButton()
    d(newValue and L("ZMS_UI_SCOPE_ACCOUNT") or L("ZMS_UI_SCOPE_CHARACTER"))

    -- Reset right panel and refresh with new scope data
    UI.currentGroup = nil
    Right("GroupName"):SetText(L("ZMS_UI_SELECT_GROUP"))
    Right("DeleteBtn"):SetHidden(true)
    Right("RenameBtn"):SetHidden(true)
    Right("AddBtn"):SetHidden(true)
    Right("ClearAllBtn"):SetHidden(true)
    Right("TabZones"):SetHidden(true)
    Right("TabMounts"):SetHidden(true)
    Right("TabPets"):SetHidden(true)
    local ilist = ItemList()
    ZO_ClearNumericallyIndexedTable(ZO_ScrollList_GetDataList(ilist))
    ZO_ScrollList_Commit(ilist)
    UI.RefreshGroupList()
end

function UI.UpdateScopeButton()
    local btn = ZMS_UIWindow:GetNamedChild("ScopeBtn")
    if not btn then return end
    local isAccount = (not ZMS.svAccount) or (ZMS.svAccount.accountWide ~= false)
    btn:SetText(isAccount and L("ZMS_UI_MODE_ACCOUNT") or L("ZMS_UI_MODE_CHARACTER"))
end

-- =============================================================
-- Save / restore window position
-- =============================================================
function UI.OnMoveStop()
    if not ZMS.saved then return end
    local valid, _, _, _, x, y = ZMS_UIWindow:GetAnchor(0)
    if valid then
        ZMS.saved.uiX = x
        ZMS.saved.uiY = y
    end
end

local function RestorePosition()
    if ZMS.saved and ZMS.saved.uiX and ZMS.saved.uiY then
        ZMS_UIWindow:ClearAnchors()
        ZMS_UIWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
            ZMS.saved.uiX, ZMS.saved.uiY)
    end
end

-- =============================================================
-- Apply localized text to all static controls
-- =============================================================
local function ApplyLocalizedLabels()
    Left("Header"):SetText(L("ZMS_UI_GROUPS_HEADER"))
    Left("UniversalBtn"):SetText(L("ZMS_UI_UNIVERSAL_BTN"))
    Left("NewGroupBtn"):SetText(L("ZMS_UI_NEW_GROUP_BTN"))
    Right("GroupName"):SetText(L("ZMS_UI_SELECT_GROUP"))
    Right("RenameBtn"):SetText(L("ZMS_UI_RENAME_BTN"))
    Right("DeleteBtn"):SetText(L("ZMS_UI_DELETE_BTN"))
    Right("TabZones"):SetText(L("ZMS_UI_TAB_ZONES"))
    Right("TabMounts"):SetText(L("ZMS_UI_TAB_MOUNTS"))
    Right("TabPets"):SetText(L("ZMS_UI_TAB_PETS"))
    Right("AddBtn"):SetText(L("ZMS_UI_ADD_ZONE"))
    Right("ClearAllBtn"):SetText(L("ZMS_UI_CLEAR_ALL"))

    -- Dialogs
    local cd = ZMS_UICreateDialog
    cd:GetNamedChild("Title"):SetText(L("ZMS_UI_DLG_CREATE_TITLE"))
    cd:GetNamedChild("KeyLabel"):SetText(L("ZMS_UI_DLG_KEY_LABEL"))
    cd:GetNamedChild("NameLabel"):SetText(L("ZMS_UI_DLG_NAME_LABEL"))
    cd:GetNamedChild("OkBtn"):SetText(L("ZMS_UI_DLG_CREATE_BTN"))
    cd:GetNamedChild("CancelBtn"):SetText(L("ZMS_UI_DLG_CANCEL_BTN"))

    local rd = ZMS_UIRenameDialog
    rd:GetNamedChild("Title"):SetText(L("ZMS_UI_DLG_RENAME_TITLE"))
    rd:GetNamedChild("NameLabel"):SetText(L("ZMS_UI_DLG_NEWNAME_LABEL"))
    rd:GetNamedChild("OkBtn"):SetText(L("ZMS_UI_DLG_RENAME_BTN"))
    rd:GetNamedChild("CancelBtn"):SetText(L("ZMS_UI_DLG_CANCEL_BTN"))
end

-- =============================================================
-- Initialize (lazy, called on first Open)
-- =============================================================
function UI.Initialize()
    if UI.initialized then return end
    UI.initialized = true

    RestorePosition()
    ApplyLocalizedLabels()

    local leftList = LeftList()
    ZO_ScrollList_AddDataType(leftList, 1, "ZMS_UIGroupRow", 28,
        function(ctrl, data) UI.SetupGroupRow(ctrl, data) end)
    ZO_ScrollList_EnableHighlight(leftList, "ZO_ThinListHighlight")

    local itemList = ItemList()
    ZO_ScrollList_AddDataType(itemList, 1, "ZMS_UIItemRow", 28,
        function(ctrl, data) UI.SetupItemRow(ctrl, data) end)
    ZO_ScrollList_EnableHighlight(itemList, "ZO_ThinListHighlight")
end

-- =============================================================
-- Open / Close / Toggle
-- =============================================================
function UI.Open()
    -- The window is keyboard/mouse only – not usable on console
    if IsConsoleUI() then
        d("|c87CEEB[ZMS]|r " .. L("ZMS_UI_CONSOLE_ONLY_CMD"))
        return
    end

    UI.Initialize()
    Win():SetHidden(false)
    Win():BringWindowToTop()
    UI.UpdateScopeButton()
    UI.RefreshGroupList()

    if not UI.currentGroup then
        Right("AddBtn"):SetHidden(true)
        Right("ClearAllBtn"):SetHidden(true)
        Right("TabZones"):SetHidden(true)
        Right("TabMounts"):SetHidden(true)
        Right("TabPets"):SetHidden(true)
        Right("DeleteBtn"):SetHidden(true)
        Right("RenameBtn"):SetHidden(true)
    end
end

function UI.Close()
    Win():SetHidden(true)
end

function UI.Toggle()
    if IsConsoleUI() then
        d("|c87CEEB[ZMS]|r " .. L("ZMS_UI_CONSOLE_ONLY_CMD"))
        return
    end
    if Win():IsHidden() then
        UI.Open()
    else
        UI.Close()
    end
end
