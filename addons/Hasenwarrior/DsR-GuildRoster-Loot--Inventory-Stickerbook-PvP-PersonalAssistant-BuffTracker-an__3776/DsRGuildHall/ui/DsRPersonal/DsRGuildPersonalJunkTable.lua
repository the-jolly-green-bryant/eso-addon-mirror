-- ============================================================
--  DsR Guild Personal – Junk Table
-- ============================================================

DsRGuildPersonalJunkTable = DsRGuildPersonalJunkTable or {}
local DsRJP = DsRGuildPersonalJunkTable

DsRGuildPersonalJunkTable.defaults = {
    MainMenueWindowX      = 480,
    MainMenueWindowY      = 110,
    MainMenueWindowWidth  = 870,
    MainMenueWindowHeight = 700,
}

-- SaveVariables
function DsRJP:InitSavedVars()
    self.config = ZO_SavedVars:NewAccountWide(
        "DsRGuildPersonalSettings",
        1,
        nil,
        self.defaults
    )
end

-- ============================================================
--  SortFilterList Klasse
-- ============================================================

DsRGuildPersonalJunkTableList = ZO_SortFilterList:Subclass()

function DsRGuildPersonalJunkTableList:New(control)
    local obj = ZO_SortFilterList.New(self, control)
    obj:Initialize(control)
    return obj
end

function DsRGuildPersonalJunkTableList:Initialize(control)
    self.control = control
    self.list = control.list
    self.headers = control.headers
    self.sortHeaderGroup = control.sortHeaderGroup

    self.searchText = ""

    self.filters = {
        itemType = nil,
        itemMark = nil,
    }

    ZO_ScrollList_AddDataType(
        self.list,
        1,
        "DsRGuildPersonalJunkRow",
        40,
        function(rowControl, data)
            self:SetupRow(rowControl, data)
        end
    )

    ZO_CreateStringId("SI_BINDING_NAME_DSRGUILD_MAINBUTTON_WINDOW", GetString(DsRGuildcmd_MainButtonWindow))

    ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")

    self.currentSortKey = "itemText"
    self.currentSortOrder = ZO_SORT_ORDER_UP

    self.sortHeaderGroup:RegisterCallback(
        ZO_SortHeaderGroup.OnSortHeaderClicked,
        function(_, key, order)
            self.currentSortKey = key
            self.currentSortOrder = order
            self:RefreshData()
        end
    )
end

-- ============================================================
--  SetupRow
-- ============================================================

function DsRGuildPersonalJunkTableList:SetupRow(control, data)
    control.ID   = control:GetNamedChild("ID")
    control.Icon = control:GetNamedChild("Icon")
    control.Name = control:GetNamedChild("Name")
    control.Mark = control:GetNamedChild("Mark")
    control.Typ  = control:GetNamedChild("Typ")

    control.Icon:SetText(zo_iconTextFormat(GetItemLinkIcon(data.Link), 32, 32, " "))
    control.Name:SetText(data.Link)
    control.Typ:SetText("|c9fb6cd" .. GetString("SI_ITEMTYPE", data.itemType):gsub("%^.+", "") .. "|r")

    local MarkColored = data.itemMark
        and "|c35fc38" .. GetString(DsRGuildcmd_MainListTRUE) .. "|r"
        or  "|cFF0000" .. GetString(DsRGuildcmd_MainListFALSE) .. "|r"

    control.Mark:SetText(MarkColored)
    control.Mark:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local MarkID = ""
    if data.itemMark and data.itemCheck then
        MarkID = "|cFFFF00*|r|c808080" .. data.itemID .. "|r"
    else
        MarkID = "|c808080" .. data.itemID .. "|r"
    end

    control.ID:SetText(MarkID)

    ZO_SortFilterList.SetupRow(self, control, data)

    control:SetHandler("OnMouseEnter", function(ctrl)
        self:Row_OnMouseEnter(ctrl)
    end)

    control:SetHandler("OnMouseExit", function(ctrl)
        self:Row_OnMouseExit(ctrl)
    end)
end

-- ============================================================
--  Build Master List
-- ============================================================

function DsRGuildPersonalJunkTableList:BuildMasterList()
    self.masterList = {}

    local JunkList = DsRGuildPersonal.ACCconfig.JunkMarkManu or {}

    for id, Junk in pairs(JunkList) do
        local Link          = Junk.itemLink
        local Mark          = Junk.MarkJunk
        local itemID        = id
        local itemName      = GetItemLinkName(Link)
        local itemNameText  = LocalizeString("<<1>>", itemName)
        local itemCheck     = false

        local itemType, specializedItemType = GetItemLinkItemType(Link)

        if (itemType == ITEMTYPE_TREASURE and specializedItemType == SPECIALIZED_ITEMTYPE_TREASURE)
        or (itemType == ITEMTYPE_TRASH or specializedItemType == SPECIALIZED_ITEMTYPE_TRASH)
        then
            itemCheck = true
        end

        table.insert(self.masterList, {
            Link      = Link,
            itemID    = itemID,
            itemMark  = Mark,
            itemText  = itemNameText,
            itemCheck = itemCheck,
            itemType  = itemType,
        })
    end
end

-- ============================================================
--  Sort
-- ============================================================

function DsRGuildPersonalJunkTableList:SortScrollList()
    local key = self.currentSortKey
    local order = self.currentSortOrder

    table.sort(self.masterList, function(a, b)
        if order == ZO_SORT_ORDER_UP then
            return a[key] < b[key]
        else
            return a[key] > b[key]
        end
    end)
end

function DsRGuildPersonalJunkTableList:FilterScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    local search = self.searchText
    if search then
        search = search:lower()
        if search == "" then search = nil end
    end

    local total = #self.masterList
    local shown = 0

    for _, entry in ipairs(self.masterList) do
        local include = true

        -- Textsuche
        if search then
            include =
                tostring(entry.itemID):lower():find(search, 1, true) or
                entry.itemText:lower():find(search, 1, true)
        end

        -- Filter: itemType
        if include and self.filters.itemType then
            include = entry.itemType == self.filters.itemType
        end

        -- Filter: Mark (true/false)
        if include and self.filters.itemMark ~= nil then
            include = entry.itemMark == self.filters.itemMark
        end

        if include then
            shown = shown + 1
            table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, entry))
        end
    end

    -- Treffer‑Label aktualisieren
    if DsRJP.resultLabel then
        local color

        if shown == 0 then
            color = "|cFF4444"
        elseif shown == total then
            color = "|cFFA500"
        else
            color = "|c44FF44"
        end

        DsRJP.resultLabel:SetText(string.format(GetString(DsRGuildMenue_BuffsAnalyseFound), color, shown, total))
    end
end

-- ============================================================
--  Refresh
-- ============================================================

function DsRGuildPersonalJunkTableList:RefreshData()
    self:BuildMasterList()
    self:SortScrollList()
    self:FilterScrollList()
    ZO_ScrollList_Commit(self.list)
end

-- ============================================================
--  Mouse Events
-- ============================================================

function DsRGuildPersonalJunkTableList_OnMouseUp(self, button)
    if button == MOUSE_BUTTON_INDEX_RIGHT then
        ClearMenu()
        ShowMenu(self)
    elseif button ~= MOUSE_BUTTON_INDEX_RIGHT then
        return
    end

    ClearMenu()

    local data = ZO_ScrollList_GetData(self)
    if not data then return end

    local Mark = data.itemMark
    local Link = data.Link
    local ID   = data.itemID

    if Mark then
        AddCustomMenuItem(GetString(DsRGuildPersonal_JunkManuRemPermJunk), function()
            DsRGuildPersonal.ACCconfig.JunkMarkManu[ID] = { itemLink = Link, MarkJunk = false }
            DsRJP:LoadJunkList()
        end)
    else
        AddCustomMenuItem(GetString(DsRGuildPersonal_JunkManuSetPermJunk), function()
            DsRGuildPersonal.ACCconfig.JunkMarkManu[ID] = { itemLink = Link, MarkJunk = true }
            DsRJP:LoadJunkList()
        end)
    end

    AddCustomMenuItem(GetString(DsRGuildPersonal_JunkManuClearPermJunk), function()
        DsRGuildPersonal.ACCconfig.JunkMarkManu[ID] = nil
        DsRJP:LoadJunkList()
    end)

    AddCustomMenuItem("-")

    AddCustomMenuItem("Link in Chat", function()
        if IsChatSystemAvailableForCurrentPlatform() then
            ZO_LinkHandler_InsertLink(zo_strformat(SI_TOOLTIP_ITEM_NAME, Link))
        end
    end)

    ShowMenu(self)
end

-- ============================================================
--  Load Junk List
-- ============================================================

function DsRJP:LoadJunkList()
    self.list:RefreshData()
end

-- ============================================================
--  Fenster erstellen
-- ============================================================

function DsRJP:CreateWindow()
    if self.window then return end

    local wm = WINDOW_MANAGER

    local win = wm:CreateTopLevelWindow("DsRGuildPersonalJunkWindow")
    win:SetDimensions(self.config.MainMenueWindowWidth, self.config.MainMenueWindowHeight)
    win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.config.MainMenueWindowX, self.config.MainMenueWindowY)
    win:SetMovable(true)
    win:SetResizeHandleSize(20)
    win:SetClampedToScreen(true)
    win:SetMouseEnabled(true)
    win:SetHidden(true)
    self.window = win

    -- Save Position
    win:SetHandler("OnMoveStop", function()
        self.config.MainMenueWindowX = win:GetLeft()
        self.config.MainMenueWindowY = win:GetTop()
    end)

    -- Save Size
    win:SetHandler("OnResizeStop", function()
        self.config.MainMenueWindowWidth  = win:GetWidth()
        self.config.MainMenueWindowHeight = win:GetHeight()
    end)

    local function CreateDropdown(name, parent, labelText, offsetX, offsetY)
        -- Label links
        local label = wm:CreateControl(nil, parent, CT_LABEL)
        label:SetFont("ZoFontGame")
        label:SetText(labelText)
        label:SetAnchor(TOPLEFT, parent, TOPLEFT, offsetX, offsetY)

        -- ComboBox rechts daneben
        local comboControl = wm:CreateControlFromVirtual(name, parent, "ZO_ComboBox")
        comboControl:SetDimensions(150, 28)
        comboControl:SetAnchor(LEFT, label, RIGHT, 10, 0)   -- <<< WICHTIG: gleiche Höhe!

        local combo = ZO_ComboBox_ObjectFromContainer(comboControl)
        combo:SetSortsItems(false)

        return combo
    end
    
    -- Background
    local bg = wm:CreateControl(nil, win, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.75)
    bg:SetEdgeColor(1, 1, 1, 0.4)

    -- Title
    local title = wm:CreateControl(nil, win, CT_LABEL)
    title:SetFont("ZoFontWinH1")
    title:SetText(GetString(DsRGuildMainWindow_Header))
    title:SetAnchor(TOP, win, TOP, 0, 12)

    -- Label "Filter"
    local filterLabel = wm:CreateControl(nil, win, CT_LABEL)
    filterLabel:SetFont("ZoFontGame")
    filterLabel:SetText(GetString(DsRGuildMenue_BuffsAnalyseFilter))
    filterLabel:SetAnchor(TOPLEFT, win, TOPLEFT, 20, 60)


    local searchBG = wm:CreateControl(nil, win, CT_BACKDROP)
    searchBG:SetDimensions(400, 28)
    searchBG:SetAnchor(LEFT, filterLabel, RIGHT, 10, 0)
    searchBG:SetCenterColor(0.2, 0.2, 0.2, 1)
    searchBG:SetEdgeColor(1, 1, 1, 0.4)

    local searchBox = wm:CreateControlFromVirtual("DsRJunkSearchBox", searchBG, "ZO_DefaultEdit")
    searchBox:SetAnchorFill()
    searchBox:SetText("")

    searchBox:SetHandler("OnTextChanged", function(self)
        DsRJP.list.searchText = self:GetText()
        DsRJP.list:RefreshData()
    end)

    local resetButton = wm:CreateControlFromVirtual("DsRJunkResetButton", win, "ZO_DefaultButton")
    resetButton:SetDimensions(120, 28)
    resetButton:SetAnchor(LEFT, searchBG, RIGHT, 10, 0)
    resetButton:SetText(GetString(DsRGuildMenue_BuffsAnalyseFilterRefresh))

    resetButton:SetHandler("OnClicked", function()
        searchBox:SetText("")
        DsRJP.list.searchText = ""

        DsRJP.list.filters.itemType = nil
        DsRJP.list.filters.itemMark = nil

        -- DROPDOWNS ZURÜCKSETZEN
        DsRJP.ddItemType:SetSelectedItem(GetString(DsRGuildcmd_MainListALL))
        DsRJP.ddItemMark:SetSelectedItem(GetString(DsRGuildcmd_MainListALL))

        DsRJP.list:RefreshData()
    end)

    local resultLabel = wm:CreateControl(nil, win, CT_LABEL)
    resultLabel:SetFont("ZoFontGame")
    resultLabel:SetText("Found: 0 / 0")
    resultLabel:SetAnchor(LEFT, resetButton, RIGHT, 20, 0)

    DsRJP.resultLabel = resultLabel

    DsRJP.ddItemType = CreateDropdown("DsRJunkFilterItemType", win, "Typ", 20, 95)
    DsRJP.ddItemMark = CreateDropdown("DsRJunkFilterItemMark", win, "Mark", 220, 95)

    -- Header Container
    local headers = wm:CreateControl(nil, win, CT_CONTROL)
    headers:SetDimensions(820, 40)
    headers:SetAnchor(TOPLEFT, win, TOPLEFT, 20, 120)

    local headerGroup = ZO_SortHeaderGroup:New(headers)

    local function AddHeader(name, text, key, width, anchorTo)
        local h = wm:CreateControlFromVirtual(name, headers, "ZO_SortHeader")
        h:SetDimensions(width, 40)

        if anchorTo then
            h:SetAnchor(LEFT, anchorTo, RIGHT, 0, 0)
        else
            h:SetAnchor(LEFT, headers, LEFT, 40, 0)
        end

        ZO_SortHeader_Initialize(h, text, key, ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT)
        headerGroup:AddHeader(h)
        return h
    end

    local h1 = AddHeader("DsRJunkHeaderID",   "|c27F2F5ID|r",    "itemID",   90)
    local h2 = AddHeader("DsRJunkHeaderName", "|c27F2F5Name|r",  "itemText", 420, h1)
    local h3 = AddHeader("DsRJunkHeaderTyp",  "|c27F2F5Typ|r",   "itemType", 190, h2)
    local h4 = AddHeader("DsRJunkHeaderMark", "|c27F2F5Mark|r",  "itemMark", 100, h3)

    -- ScrollList Container
    local listControl = wm:CreateControl("DsRJunkListControl", win, CT_CONTROL)
    listControl:SetAnchor(TOPLEFT, win, TOPLEFT, 20, 150)
    listControl:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -20, -40)

    local scrollList = wm:CreateControlFromVirtual("DsRJunkListControlList", listControl, "ZO_ScrollList")
    scrollList:SetAnchorFill()

    listControl.list = scrollList
    listControl.headers = headers
    listControl.sortHeaderGroup = headerGroup

    self.list = DsRGuildPersonalJunkTableList:New(listControl)

    -- Close Button
    local close = wm:CreateControlFromVirtual(nil, win, "ZO_DefaultButton")
    close:SetAnchor(BOTTOM, win, BOTTOM, 0, -20)
    close:SetDimensions(160, 28)
    close:SetText(GetString(DsRGuildcmd_MainListCLOSE))
    close:SetHandler("OnClicked", function()
        win:SetHidden(true)
    end)

    -- Fenster schließen, wenn andere UI-Elemente geöffnet werden
    ZO_PreHookHandler(ZO_InteractWindow, "OnShow", function()
        if self.window then self.window:SetHidden(true) end
    end)

    ZO_PreHookHandler(ZO_GameMenu_InGame, "OnShow", function()
        if self.window then self.window:SetHidden(true) end
    end)

    ZO_PreHookHandler(ZO_KeybindStripControl, "OnShow", function()
        if self.window then self.window:SetHidden(true) end
    end)

    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnShow", function()
        if self.window then self.window:SetHidden(true) end
    end)

    ZO_PreHookHandler(ZO_PlayerInventoryMenu, "OnHide", function()
        if self.window then self.window:SetHidden(true) end
    end)
end

function DsRJP:FillDropdowns()
    local itemTypes = {}

    local function AddUnique(tbl, id, name)
        if id ~= nil and name ~= nil then
            tbl[id] = name
        end
    end

    for _, entry in ipairs(self.list.masterList or {}) do
        local id = entry.itemType
        local name = GetString("SI_ITEMTYPE", id):gsub("%^.+", "")
        AddUnique(itemTypes, id, name)
    end

    local function ToList(dict)
        local list = {}
        for k in pairs(dict) do table.insert(list, k) end
        table.sort(list)
        return list
    end

    -- === ItemType Dropdown füllen ===
    local combo = self.ddItemType
    combo:ClearItems()

    local entryAll = combo:CreateItemEntry(GetString(DsRGuildcmd_MainListALL), function()
        self.list.filters.itemType = nil
        self.list:RefreshData()
    end)
    combo:AddItem(entryAll)

    -- Sortierte Liste erzeugen
    local sorted = {}
    for id, name in pairs(itemTypes) do
        table.insert(sorted, { id = id, name = name })
    end
    table.sort(sorted, function(a, b)
        return a.name < b.name
    end)

    -- Dropdown füllen
    for _, v in ipairs(sorted) do
        local e = combo:CreateItemEntry(v.name, function()
            self.list.filters.itemType = v.id
            self.list:RefreshData()
        end)
        combo:AddItem(e)
    end

    combo:SetSelectedItem(GetString(DsRGuildcmd_MainListALL))

    -- === itemMark Dropdown füllen ===
    local combo2 = self.ddItemMark
    combo2:ClearItems()

    local entryAll2 = combo2:CreateItemEntry(GetString(DsRGuildcmd_MainListALL), function()
        self.list.filters.itemMark = nil
        self.list:RefreshData()
    end)
    combo2:AddItem(entryAll2)

    local entryTrue = combo2:CreateItemEntry(GetString(DsRGuildcmd_MainListTRUE), function()
        self.list.filters.itemMark = true
        self.list:RefreshData()
    end)
    combo2:AddItem(entryTrue)

    local entryFalse = combo2:CreateItemEntry(GetString(DsRGuildcmd_MainListFALSE), function()
        self.list.filters.itemMark = false
        self.list:RefreshData()
    end)
    combo2:AddItem(entryFalse)

    combo2:SetSelectedItem(GetString(DsRGuildcmd_MainListALL))
end



function DsRJP:ShowWindow()
    if not self.config then
        self:InitSavedVars()
    end

    self:CreateWindow()
    self:LoadJunkList()
    self:FillDropdowns()
    self.window:SetHidden(false)
end

function DsRGuildPersonalJunkTable:ToggleWindow(forceOpen)
    if not self.config then
        self:InitSavedVars()
    end

    self:CreateWindow()

    if forceOpen == true then
        self.window:SetHidden(false)
        self:LoadJunkList()
        self:FillDropdowns()
        SetGameCameraUIMode ( true )
        return
    end

    if self.window:IsHidden() then
        self.window:SetHidden(false)
        self:LoadJunkList()
        self:FillDropdowns()
    else
        self.window:SetHidden(true)
    end
end
