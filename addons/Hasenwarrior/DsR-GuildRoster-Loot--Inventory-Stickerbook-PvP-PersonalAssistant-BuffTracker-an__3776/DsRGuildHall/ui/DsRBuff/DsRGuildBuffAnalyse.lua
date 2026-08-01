-- ============================================================
--  DsR Guild Buff Tracker – Analyse Tabelle
-- ============================================================

DsRGuildBuffAnalyse = DsRGuildBuffAnalyse or {}
local DsRBTA = DsRGuildBuffAnalyse

DsRBuffData = DsRBuffData or {}

local DsRIcon = DsRglobals:HolidayIconLoad()

-- ============================================================
--  SortFilterList Klasse
-- ============================================================

DsRBuffAnalyseList = ZO_SortFilterList:Subclass()

function DsRBuffAnalyseList:New(control)
    local obj = ZO_SortFilterList.New(self, control)
    obj:Initialize(control)
    return obj
end

function DsRBuffAnalyseList:Initialize(control)
    self.control = control
    self.list = control.list
    self.headers = control.headers
    self.sortHeaderGroup = control.sortHeaderGroup
    self.searchText = ""

    self.filters = {
        effectType       = nil,
        statusEffectType = nil,
        abilityType      = nil,
        sourceType       = nil,
        TargetDesc       = nil,
        isPassiv         = nil,
        isUltimate       = nil,
        isPermanent      = nil,
        Cost             = nil,
    }

    ZO_ScrollList_AddDataType(
        self.list,
        1,
        "DsRBuffAnalyseRow",
        44,
        function(rowControl, data)
            self:SetupRow(rowControl, data)
        end
    )

    ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")

    self.currentSortKey = "abilityId"
    self.currentSortOrder = ZO_SORT_ORDER_UP

    self.sortHeaderGroup:RegisterCallback(
        ZO_SortHeaderGroup.OnSortHeaderClicked,
        function(_, key, order)
            self.currentSortKey = key
            self.currentSortOrder = order
            self:RefreshFilters()
        end
    )
end

-- ------------------------------------------------------------
--  Zeile befüllen
-- ------------------------------------------------------------
function DsRBuffAnalyseList:SetupRow(row, data)
    row.keepHover = false
    row.isHovering = false

    local iconControl = row:GetNamedChild("Icon")
    local c1          = row:GetNamedChild("AbilityId")
    local c2          = row:GetNamedChild("Name")
    local c3          = row:GetNamedChild("EffectType")
    local c4          = row:GetNamedChild("StatusEffectType")
    local c5          = row:GetNamedChild("AbilityType")
    local c6          = row:GetNamedChild("SourceType")
    local c7          = row:GetNamedChild("TargetDesc")
    local c8          = row:GetNamedChild("isPassiv")
    local c9          = row:GetNamedChild("isUltimate")
    local c10         = row:GetNamedChild("isPermanent")
    local c11         = row:GetNamedChild("Cost")

    local icon = DsRBuffData.Buffs[data.abilityId] and DsRBuffData.Buffs[data.abilityId].icon
    iconControl:SetTexture(icon or nil)

    c1:SetText("|cFFFFFF" .. tostring(data.abilityId)        .. "|r")
    c2:SetText("|cFFFF00" .. tostring(data.name):gsub("%^.+", "") .. "|r")

    local EffectListName = DsRglobals.EffectTyp[tonumber(data.effectType)]
    if EffectListName then
        c3:SetText("|c00FF00" .. data.effectType .. " - " .. EffectListName.listname .. "|r")
    else
        c3:SetText("|c00FF00" .. data.effectType .. " - Unknown|r")
    end 

    c4:SetText("|cFFA500" .. tostring(data.statusEffectType) .. "|r")

    local TypeListName = DsRglobals.abilityTypes[tonumber(data.abilityType)]
    if TypeListName then
        c5:SetText("|cADD8E6" .. data.abilityType .. " - " .. TypeListName.listname .. "|r")
    else
        c5:SetText("|cADD8E6" .. data.abilityType .. " - Unknown|r")
    end

    local SourceListName = DsRglobals.sourceType[tonumber(data.sourceType)]
    if SourceListName then
        c6:SetText("|cFFC0CB" .. data.sourceType .. " - " .. SourceListName.listname .. "|r")
    else
        c6:SetText("|cFFC0CB" .. data.sourceType .. " - Unknown|r")
    end

    c7:SetText("|cE1FAC0" .. tostring(data.TargetDesc) .. "|r")
    if tostring(data.TargetDesc) == "Kumulativ" or tostring(data.TargetDesc) == "Cumulative" then
        c2:SetText("|c089cc9" .. tostring(data.name):gsub("%^.+", "") .. "|r")
    end

    if tostring(data.isPassiv) == "true" then
        c8:SetText("|c00FF00" .. tostring(data.isPassiv) .. "|r")
    else
        c8:SetText("|cFF0000" .. tostring(data.isPassiv) .. "|r")
    end    
    if tostring(data.isUltimate) == "true" then
        c9:SetText("|c00FF00" .. tostring(data.isUltimate) .. "|r")
    else
        c9:SetText("|cFF0000" .. tostring(data.isUltimate) .. "|r")
    end
    if tostring(data.isPermanent) == "true" then
        c10:SetText("|c00FF00" .. tostring(data.isPermanent) .. "|r")
    else
        c10:SetText("|cFF0000" .. tostring(data.isPermanent) .. "|r")
    end

    c11:SetText("|cf55f27" .. tostring(data.Cost) .. "|r")

    ----------------------------------------------------------------
    -- RECHTSKLICK-KONTEXTMENÜ
    ----------------------------------------------------------------
    row:SetHandler("OnMouseUp", function(control, button, upInside)
        
        if button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
            row.keepHover = true
            ClearMenu()
          
            AddMenuItem(GetString(DsRGuildMenue_BuffsAnalyseCopyID1) .. "|c00FF00" .. data.abilityId .. "|r" .. GetString(DsRGuildMenue_BuffsAnalyseCopyID2) .. "|cFFA500" .. DsRGuildLoot.sV.DsRBuff_CurrentChar .. "->" .. DsRGuildLoot.sV.DsRBuff_CurrentKey .. "->" .. "|cFF0000Tank" .. "|r" .. GetString(DsRGuildMenue_BuffsAnalyseCopyID3), function()
                local useID = data.abilityId
                local key   = DsRGuildLoot.sV.DsRBuff_CurrentKey
                local char  = DsRGuildLoot.sV.DsRBuff_CurrentChar

                -- Aktuellen Text holen
                local current = DsRGuildBuffsCharSettings["Default"][GetDisplayName()][char][key]["Tank"] or ""

                -- Wenn schon Text drin ist → Komma + Leerzeichen anhängen
                if current ~= "" then
                    current = current .. ", " .. useID
                else
                    current = useID
                end
                DsRGuildBuffsCharSettings["Default"][GetDisplayName()][char][key]["Tank"] = current

                DsRBuffSettingsWindowTankEdit:SetText(DsRGuildBuffsCharSettings["Default"][GetDisplayName()][char][key]["Tank"])

                DsRGuildBuffs.RefreshUI()
            end)
            AddMenuItem(GetString(DsRGuildMenue_BuffsAnalyseCopyID1) .. "|c00FF00" .. data.abilityId .. "|r" .. GetString(DsRGuildMenue_BuffsAnalyseCopyID2) .. "|cFFA500" .. DsRGuildLoot.sV.DsRBuff_CurrentChar .. "->" .. DsRGuildLoot.sV.DsRBuff_CurrentKey .. "->" .. "|c00FF00Heal" .. "|r" .. GetString(DsRGuildMenue_BuffsAnalyseCopyID3), function()
                local useID = data.abilityId
                local key   = DsRGuildLoot.sV.DsRBuff_CurrentKey
                local char  = DsRGuildLoot.sV.DsRBuff_CurrentChar

                -- Aktuellen Text holen
                local current = DsRGuildBuffsCharSettings["Default"][GetDisplayName()][char][key]["Heal"] or ""

                -- Wenn schon Text drin ist → Komma + Leerzeichen anhängen
                if current ~= "" then
                    current = current .. ", " .. useID
                else
                    current = useID
                end
                DsRGuildBuffsCharSettings["Default"][GetDisplayName()][char][key]["Heal"] = current

                DsRBuffSettingsWindowHealEdit:SetText(DsRGuildBuffsCharSettings["Default"][GetDisplayName()][char][key]["Heal"])

                DsRGuildBuffs.RefreshUI()
            end)
            AddMenuItem(GetString(DsRGuildMenue_BuffsAnalyseCopyID1) .. "|c00FF00" .. data.abilityId .. "|r" .. GetString(DsRGuildMenue_BuffsAnalyseCopyID2) .. "|cFFA500" .. DsRGuildLoot.sV.DsRBuff_CurrentChar .. "->" .. DsRGuildLoot.sV.DsRBuff_CurrentKey .. "->" .. "|cADD8E6DPS" .. "|r" .. GetString(DsRGuildMenue_BuffsAnalyseCopyID3), function()
                local useID = data.abilityId
                local key   = DsRGuildLoot.sV.DsRBuff_CurrentKey
                local char  = DsRGuildLoot.sV.DsRBuff_CurrentChar

                -- Aktuellen Text holen
                local current = DsRGuildBuffsCharSettings["Default"][GetDisplayName()][char][key]["DPS"] or ""

                -- Wenn schon Text drin ist → Komma + Leerzeichen anhängen
                if current ~= "" then
                    current = current .. ", " .. useID
                else
                    current = useID
                end
                DsRGuildBuffsCharSettings["Default"][GetDisplayName()][char][key]["DPS"] = current

                DsRBuffSettingsWindowDDEdit:SetText(DsRGuildBuffsCharSettings["Default"][GetDisplayName()][char][key]["DPS"])

                DsRGuildBuffs.RefreshUI()
            end)
            
            AddMenuItem("----------------------------", function() end)

            AddMenuItem(GetString(DsRGuildMenue_BuffsAnalyseFilterName), function()
                local cleanName = tostring(data.name):gsub("%^.+", "")
            
                zo_callLater(function()
                    DsRBTA.searchBox:SetText(cleanName)
                    DsRBTA.analyseList.searchText = cleanName
                    DsRBTA.analyseList:RefreshFilters()
                end, 10)
            end)            
            AddMenuItem(GetString(DsRGuildMenue_BuffsAnalyseDebug), function()
                DsRBuffAnalyseList:DebugAbilityID(data.abilityId, data.name)
            end)  
            ShowMenu(control)

            ZO_PreHook("ZO_Menu_OnHide", function()
                row.keepHover = false
                if not row.isHovering then
                    self:Row_OnMouseExit(row)
                end
            end)
        end
    end)

    ZO_SortFilterList.SetupRow(self, row, data)

    row:SetHandler("OnMouseEnter", function(ctrl)
        ctrl.isHovering = true
        self:Row_OnMouseEnter(ctrl)
    end)

    row:SetHandler("OnMouseExit", function(ctrl)
        ctrl.isHovering = false
        if not ctrl.keepHover then
            self:Row_OnMouseExit(ctrl)
        end
    end)
end

-- ------------------------------------------------------------
--  MasterList aufbauen
-- ------------------------------------------------------------
function DsRBuffAnalyseList:BuildMasterList()
    self.masterList = {}

    local buffs = DsRBuffData.Buffs or {}

    for abilityId, data in pairs(buffs) do

        local TargetDescription = GetAbilityTargetDescription(abilityId)
        local desc = tostring(TargetDescription):lower()

        if DsRglobals.StackableSets[abilityId] then
                local lang = GetCVar("language.2")
                if lang == "de" then
                    TargetDescription = "Kumulativ"
                else
                    TargetDescription = "Cumulative"
                end
        elseif desc:find("charakter") or desc:find("character") then
            TargetDescription = "Charakter"
        elseif tostring(TargetDescription) == "nil" or tostring(TargetDescription) == "" then
            TargetDescription = "-"
        end

        local abilityTypeInfo = DsRglobals.abilityTypes[data.abilityType]
        local sourceTypeInfo  = DsRglobals.sourceType[data.sourceType]
        local effectTypeInfo  = DsRglobals.EffectTyp[data.effectType]

        table.insert(self.masterList, {
            abilityId        = abilityId,
            name             = GetAbilityName(abilityId) or "",
            effectType       = tostring(data.effectType or "nil"),
            effectTypeText   = effectTypeInfo and (data.effectType .. " - " .. effectTypeInfo.listname) or tostring(data.effectType) or "nil",
            statusEffectType = tostring(data.statusEffectType or "nil"),
            abilityType      = tostring(data.abilityType or "nil"),
            abilityTypeText  = abilityTypeInfo and (data.abilityType .. " - " .. abilityTypeInfo.listname) or tostring(data.abilityType) or "nil",
            sourceType       = tostring(data.sourceType or "nil"),
            sourceTypeText   = sourceTypeInfo and (data.sourceType .. " - " .. sourceTypeInfo.listname) or tostring(data.sourceType) or "nil",
            TargetDesc       = tostring(TargetDescription or "nil"),
            isPassiv         = tostring(IsAbilityPassive(abilityId) or "false"),
            isUltimate       = tostring(IsAbilityUltimate(abilityId) or "false"),
            isPermanent      = tostring(IsAbilityPermanent(abilityId) or "false"),
            Cost             = tostring(GetAbilityCost(abilityId) or "false"),
        })
    end
end

-- ------------------------------------------------------------
--  Sortierung
-- ------------------------------------------------------------
function DsRBuffAnalyseList:SortScrollList()
    local key = self.currentSortKey
    local order = self.currentSortSortOrder

    table.sort(self.masterList, function(a, b)
        if order == ZO_SORT_ORDER_UP then
            return a[key] < b[key]
        else
            return a[key] > b[key]
        end
    end)
end

-- ------------------------------------------------------------
--  Filter
-- ------------------------------------------------------------
function DsRBuffAnalyseList:FilterScrollList()
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
                tostring(entry.abilityId):lower():find(search, 1, true) or
                entry.name:lower():find(search, 1, true) or
                entry.effectType:lower():find(search, 1, true) or
                tostring(entry.effectTypeText):lower():find(search, 1, true) or
                entry.statusEffectType:lower():find(search, 1, true) or
                entry.abilityType:lower():find(search, 1, true) or
                tostring(entry.abilityTypeText):lower():find(search, 1, true) or
                entry.sourceType:lower():find(search, 1, true) or
                tostring(entry.sourceTypeText):lower():find(search, 1, true) or
                entry.TargetDesc:lower():find(search, 1, true) or
                entry.isPassiv:lower():find(search, 1, true) or
                entry.isUltimate:lower():find(search, 1, true) or
                entry.isPermanent:lower():find(search, 1, true) or
                entry.Cost:lower():find(search, 1, true)
        end

        -- Dropdown-Filter
        if include and self.filters.effectType then
            include = entry.effectType == self.filters.effectType:match("^(%d+)")
        end
        if include and self.filters.statusEffectType then
            include = entry.statusEffectType == self.filters.statusEffectType
        end
        if include and self.filters.abilityType then
            include = entry.abilityType == self.filters.abilityType:match("^(%d+)")
        end
        if include and self.filters.sourceType then
            include = entry.sourceType == self.filters.sourceType:match("^(%d+)")
        end
        if include and self.filters.TargetDesc then
            include = entry.TargetDesc == self.filters.TargetDesc
        end
        if include and self.filters.isPassiv then
            include = entry.isPassiv == self.filters.isPassiv
        end
        if include and self.filters.isUltimate then
            include = entry.isUltimate == self.filters.isUltimate
        end
        if include and self.filters.isPermanent then
            include = entry.isPermanent == self.filters.isPermanent
        end

        if include then
            shown = shown + 1
            table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, entry))
        end
    end

    -- Treffer-Counter aktualisieren
    if DsRBTA.resultLabel then
        local color

        if shown == 0 then
            color = "|cFF4444"   -- Rot
        elseif shown == total then
            color = "|cFFA500"   -- Orange (keine Filter aktiv)
        else
            color = "|c44FF44"   -- Grün
        end

        DsRBTA.resultLabel:SetText(string.format("Buffs: %s%d|r / |cFFA500%d|r", color, shown, total))
    end
end

-- ------------------------------------------------------------
--  Refresh
-- ------------------------------------------------------------
function DsRBuffAnalyseList:RefreshData()
    self:BuildMasterList()
    self:SortScrollList()
    self:FilterScrollList()
    ZO_ScrollList_Commit(self.list)
end

function DsRBuffAnalyseList:RefreshFilters()
    self:SortScrollList()
    self:FilterScrollList()
    ZO_ScrollList_Commit(self.list)
end

-- ============================================================
--  Analyse Fenster
-- ============================================================

function DsRBTA:CreateAnalyseWindow()
    if self.analyseWindow then return end

    local wm = WINDOW_MANAGER

    -- Hauptfenster
    local win = wm:CreateTopLevelWindow("DsRBuffAnalyseWindow")
    win:SetDimensions(1400, 900)
    win:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    win:SetMovable(true)
    win:SetResizeHandleSize(20)
    win:SetClampedToScreen(true)
    win:SetMouseEnabled(true)
    win:SetHidden(true)
    win:SetDrawLevel(9998)

    self.analyseWindow = win

    -- Hintergrund
    local bg = wm:CreateControl(nil, win, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.9)
    bg:SetEdgeColor(1, 1, 1, 0.9)

    -- Titel
    local title = wm:CreateControl(nil, win, CT_LABEL)
    title:SetFont("ZoFontWinH1")
    title:SetText(zo_iconFormat(DsRIcon, 36, 36) .. "|c9fb6cdDsR - Buff Analyse|r" .. zo_iconFormat(DsRIcon, 36, 36))
    title:SetAnchor(TOP, win, TOP, 0, 12)

    -- Label "Filtern"
    local filterLabel = wm:CreateControl(nil, win, CT_LABEL)
    filterLabel:SetFont("ZoFontGame")
    filterLabel:SetText(GetString(DsRGuildMenue_BuffsAnalyseFilter))
    filterLabel:SetAnchor(TOPLEFT, win, TOPLEFT, 20, 60)

    -- Hintergrund für das Suchfeld
    local searchBG = wm:CreateControl(nil, win, CT_BACKDROP)
    searchBG:SetDimensions(400, 28)
    searchBG:SetAnchor(LEFT, filterLabel, RIGHT, 10, 0)
    searchBG:SetCenterColor(0.2, 0.2, 0.2, 1)
    searchBG:SetEdgeColor(1, 1, 1, 0.4)

    -- EditBox
    local searchBox = wm:CreateControlFromVirtual("DsRBuffAnalyseSearchBox", searchBG, "ZO_DefaultEdit")
    searchBox:SetAnchorFill()
    searchBox:SetText("")
    self.searchBox = searchBox

    searchBox:SetHandler("OnTextChanged", function(self)
        if DsRBTA.analyseList then
            DsRBTA.analyseList.searchText = self:GetText()
            DsRBTA.analyseList:RefreshFilters()
        end
    end)

    -- Reset-Button
    local resetButton = wm:CreateControlFromVirtual("DsRBuffAnalyseResetButton", win, "ZO_DefaultButton")
    resetButton:SetDimensions(120, 28)
    resetButton:SetAnchor(LEFT, searchBG, RIGHT, 10, 0)
    resetButton:SetText(GetString(DsRGuildMenue_BuffsAnalyseFilterRefresh))

    -- Dropdown-Factory
    local function CreateDropdown(name, parent, labelText, offsetX)
        local label = wm:CreateControl(nil, parent, CT_LABEL)
        label:SetFont("ZoFontGame")
        label:SetText(labelText)
        label:SetAnchor(TOPLEFT, parent, TOPLEFT, offsetX, 95)

        local comboControl = wm:CreateControlFromVirtual(name, parent, "ZO_ComboBox")
        comboControl:SetDimensions(100, 28)
        comboControl:SetAnchor(TOPLEFT, label, BOTTOMLEFT, 0, 2)

        local combo = ZO_ComboBox_ObjectFromContainer(comboControl)
        combo:SetSortsItems(false) -- WICHTIG!

        return combo
    end

    -- Dropdowns erstellen und in DsRBTA speichern
    self.ddEffect  = CreateDropdown("DsRFilterEffect",  win, "|c00FF00Effect|r",  20)
    self.ddStatus  = CreateDropdown("DsRFilterStatus",  win, "|cFFA500Status|r",  140)
    self.ddAbility = CreateDropdown("DsRFilterAbility", win, "|cADD8E6Ability|r", 260)
    self.ddSource  = CreateDropdown("DsRFilterSource",  win, "|cFFC0CBSource|r",  380)
    self.ddTarget  = CreateDropdown("DsRFilterTarget",  win, "|cE1FAC0Target|r",  500)
    self.ddPassiv  = CreateDropdown("DsRFilterPassiv",  win, "Passiv",  620)
    self.ddUlti    = CreateDropdown("DsRFilterUlti",    win, "Ulti",    740)
    self.ddPerma   = CreateDropdown("DsRFilterPerma",   win, "Permanent", 860)

    -- Treffer-Counter
    local resultLabel = wm:CreateControl(nil, win, CT_LABEL)
    resultLabel:SetFont("ZoFontGame")
    resultLabel:SetText("Buffs: 0 / 0")
    resultLabel:SetAnchor(LEFT, resetButton, RIGHT, 50, 0)

    -- Speichern, damit die SortFilterList darauf zugreifen kann
    self.resultLabel = resultLabel

    -- Header Container
    local headers = wm:CreateControl(nil, win, CT_CONTROL)
    headers:SetDimensions(760, 44)
    headers:SetAnchor(TOPLEFT, win, TOPLEFT, 20, 150)

    -- Header-Gruppe
    local headerGroup = ZO_SortHeaderGroup:New(headers)

    local function AddHeader(name, text, key, width, anchorTo)
        local h = wm:CreateControlFromVirtual(name, headers, "ZO_SortHeader")
        h:SetDimensions(width, 44)

        if anchorTo then
            h:SetAnchor(LEFT, anchorTo, RIGHT, 0, 0)
        else
            h:SetAnchor(LEFT, headers, LEFT, 32, 0)
        end

        ZO_SortHeader_Initialize(h, text, key, ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT)
        headerGroup:AddHeader(h)
        return h
    end

    local h1  = AddHeader("DsRBuffAnalyseHeaderAbilityId",          "|c27F2F5ID|r",       "abilityId",        60)
    local h2  = AddHeader("DsRBuffAnalyseHeaderName",               "|c27F2F5Name|r",     "name",             300, h1)
    local h3  = AddHeader("DsRBuffAnalyseHeaderEffectType",         "|c27F2F5Effect|r",   "effectType",       120, h2)
    local h4  = AddHeader("DsRBuffAnalyseHeaderStatusEffectType",   "|c27F2F5Status|r",   "statusEffectType", 70, h3)
    local h5  = AddHeader("DsRBuffAnalyseHeaderAbilityType",        "|c27F2F5Ability|r",  "abilityType",      180, h4)
    local h6  = AddHeader("DsRBuffAnalyseHeaderSourceType",         "|c27F2F5Source|r",   "sourceType",       120, h5)
    local h7  = AddHeader("DsRBuffAnalyseHeaderTargetDesc",         "|c27F2F5Target|r",   "TargetDesc",       120, h6)
    local h8  = AddHeader("DsRBuffAnalyseHeaderisPassiv",           "|c27F2F5Passiv|r",   "isPassiv",         90, h7)
    local h9  = AddHeader("DsRBuffAnalyseHeaderisUltimate",         "|c27F2F5Ulti|r",     "isUltimate",       90, h8)
    local h10 = AddHeader("DsRBuffAnalyseHeaderisPermanent",        "|c27F2F5Perma|r",    "isPermanent",      80, h9)
    local h11 = AddHeader("DsRBuffAnalyseHeaderCost",               "|c27F2F5Cost|r",     "Cost",             80, h10)

    -- ScrollList Container
    local listControl = wm:CreateControl("DsRBuffAnalyseListControl", win, CT_CONTROL)
    listControl:SetAnchor(TOPLEFT, win, TOPLEFT, 20, 190)
    listControl:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -20, -40)

    -- ScrollList
    local scrollList = wm:CreateControlFromVirtual("DsRBuffAnalyseListControlList", listControl, "ZO_ScrollList")
    scrollList:SetAnchorFill()

    listControl.list = scrollList
    listControl.headers = headers
    listControl.sortHeaderGroup = headerGroup

    -- SortFilterList instanziieren
    self.analyseList = DsRBuffAnalyseList:New(listControl)

    -- Dropdown-Helfer zum Füllen
    local function FillDropdown(combo, values, filterKey)
        combo.m_selectedItemData = nil
        combo:ClearItems()

        -- "Alle" immer oben
        local entryAll = combo:CreateItemEntry(GetString(DsRGuildMenue_BuffsAnalyseFilterAll), function()
            DsRBTA.analyseList.filters[filterKey] = nil
            DsRBTA.analyseList:RefreshFilters()
        end)
        combo:AddItem(entryAll)

        table.sort(values)

        for _, v in ipairs(values) do
            local e = combo:CreateItemEntry(v, function()
                DsRBTA.analyseList.filters[filterKey] = v
                DsRBTA.analyseList:RefreshFilters()
            end)
            combo:AddItem(e)
        end

        combo:SetSelectedItem(GetString(DsRGuildMenue_BuffsAnalyseFilterAll))
    end

    -- Werte für Dropdowns aus SavedVariables sammeln
    local buffs = DsRBuffData.Buffs or {}

    local effectTypes = {}
    local statusTypes = {}
    local abilityTypes = {}
    local sourceTypes = {}

    local function AddUnique(tbl, value)
        if value and value ~= "" and value ~= "nil" then
            if not tbl[value] then tbl[value] = true end
        end
    end

    for _, data in pairs(buffs) do
        AddUnique(effectTypes, tostring(data.effectType))
        AddUnique(statusTypes, tostring(data.statusEffectType))
        AddUnique(abilityTypes, tostring(data.abilityType))
        AddUnique(sourceTypes, tostring(data.sourceType))
    end

    local function ToStatusList(dict)
        local list = {}
        for k in pairs(dict) do table.insert(list, k) end
        return list
    end

    local function ToAbilityList(dict)
        local list = {}
        for k in pairs(dict) do
            local TypeListName = DsRglobals.abilityTypes[tonumber(k)]
            if TypeListName then
                table.insert(list, string.format("%d - %s", k, TypeListName.listname))
            else
                table.insert(list, "0 - Unknown")
            end
        end
        return list
    end

    local function ToSourceList(dict)
        local list = {}
        for k in pairs(dict) do
            local TypeListName = DsRglobals.sourceType[tonumber(k)]
            if TypeListName then
                table.insert(list, string.format("%d - %s", k, TypeListName.listname))
            elseif k == "6" then
                table.insert(list, "6 - Unknown")
            end
        end
        return list
    end

    local function ToEffectList(dict)
        local list = {}
        for k in pairs(dict) do
            local TypeListName = DsRglobals.EffectTyp[tonumber(k)]
            if TypeListName then
                table.insert(list, string.format("%d - %s", k, TypeListName.listname))
            else
                table.insert(list, "0 - Unknown")
            end
        end
        return list
    end

    FillDropdown(self.ddEffect,  ToEffectList(effectTypes),  "effectType")
    FillDropdown(self.ddStatus,  ToStatusList(statusTypes),  "statusEffectType")
    FillDropdown(self.ddAbility, ToAbilityList(abilityTypes), "abilityType")
    FillDropdown(self.ddSource,  ToSourceList(sourceTypes),  "sourceType")

    local lang = GetCVar("language.2")
    if lang == "de" then
        FillDropdown(self.ddTarget, { "Charakter", "Feind", "Fläche", "Kegel", "Verbündete", "Bodenziel", "Kumulativ", "-" } ,   "TargetDesc")
    else
        FillDropdown(self.ddTarget, { "Self", "Enemy", "Area", "Cone", "Ally", "Ground", "Cumulative", "-" } ,   "TargetDesc")
    end
       
    FillDropdown(self.ddPassiv, { "false", "true" } , "isPassiv")
    FillDropdown(self.ddUlti,   { "false", "true" } , "isUltimate")
    FillDropdown(self.ddPerma,  { "false", "true" } , "isPermanent")

    -- Reset-Button Logik
    resetButton:SetHandler("OnClicked", function()
        -- Suchfeld leeren
        searchBox:SetText("")
        DsRBTA.analyseList.searchText = ""

        -- Dropdowns zurücksetzen
        DsRBTA.ddEffect:SetSelectedItem(GetString(DsRGuildMenue_BuffsAnalyseFilterAll))
        DsRBTA.ddStatus:SetSelectedItem(GetString(DsRGuildMenue_BuffsAnalyseFilterAll))
        DsRBTA.ddAbility:SetSelectedItem(GetString(DsRGuildMenue_BuffsAnalyseFilterAll))
        DsRBTA.ddSource:SetSelectedItem(GetString(DsRGuildMenue_BuffsAnalyseFilterAll))
        DsRBTA.ddTarget:SetSelectedItem(GetString(DsRGuildMenue_BuffsAnalyseFilterAll))
        DsRBTA.ddPassiv:SetSelectedItem(GetString(DsRGuildMenue_BuffsAnalyseFilterAll))
        DsRBTA.ddUlti:SetSelectedItem(GetString(DsRGuildMenue_BuffsAnalyseFilterAll))
        DsRBTA.ddPerma:SetSelectedItem(GetString(DsRGuildMenue_BuffsAnalyseFilterAll))

        -- interne Filter löschen
        DsRBTA.analyseList.filters.effectType = nil
        DsRBTA.analyseList.filters.statusEffectType = nil
        DsRBTA.analyseList.filters.abilityType = nil
        DsRBTA.analyseList.filters.sourceType = nil
        DsRBTA.analyseList.filters.TargetDesc = nil
        DsRBTA.analyseList.filters.isPassiv = nil
        DsRBTA.analyseList.filters.isUltimate = nil
        DsRBTA.analyseList.filters.isPermanent = nil

        -- Tabelle neu laden
        DsRBTA.analyseList:RefreshFilters()
    end)

    -- Schließen-Button
    local close = wm:CreateControlFromVirtual(nil, win, "ZO_DefaultButton")
    close:SetAnchor(BOTTOM, win, BOTTOM, 0, -20)
    close:SetDimensions(160, 28)
    close:SetText(GetString(DsRGuildMenue_BuffsAnalyseFilterClose))
    close:SetHandler("OnClicked", function()
        win:SetHidden(true)
    end)

    -- Resize-Grip
    local resize = wm:CreateControl("DsRBuffAnalyseResizeGrip", win, CT_CONTROL)
    resize:SetDimensions(20, 20)
    resize:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, 0, 0)
    resize:SetMouseEnabled(true)

    resize:SetHandler("OnMouseDown", function(_, button)
        if button == 1 then
            win:StartSizing(SIZING_BOTTOMRIGHT)
        end
    end)

    resize:SetHandler("OnMouseUp", function()
        win:StopSizing()
        if self.analyseList and self.analyseList.list then
            ZO_ScrollList_Commit(self.analyseList.list)
        end
    end)

    EVENT_MANAGER:RegisterForUpdate("DsRBTA_CheckMovement", 100, function()
        if IsPlayerMoving() then
            if self.analyseWindow then
                self.analyseWindow:SetHidden(true)
            end
        end
    end)
end

function DsRBTA:ShowAnalyseWindow()
    self:CreateAnalyseWindow()
    self.analyseList:RefreshData()
    self.analyseWindow:SetHidden(false)
end

-- ============================================================
--  Debug-Ausgabe
-- ============================================================
function DsRBuffAnalyseList:DebugAbilityID(abilityId, name)
    CHAT_SYSTEM:Maximize()

    -- NIL-SAFE STRING
    local function Safe(v)
        if v == nil then return "|cFF0000nil|r" end
        return "|c00FF00" .. tostring(v) .. "|r"
    end

    -- SAFE CALL (prüft ob Funktion existiert UND ob sie fehlerfrei läuft)
    local function Call(func, ...)
        if type(func) ~= "function" then
            return "|cFF0000nil|r"
        end
        local ok, result = pcall(func, ...)
        if not ok then
            return "|cFF0000error|r"
        end
        if result == nil then
            return "|cFF0000nil|r"
        end
        return "|c00FF00" .. tostring(result) .. "|r"
    end

    local function Label(text)
        return "|cFFFF00" .. text .. "|r"
    end

    local IconPfad = GetAbilityIcon(abilityId)
    local Icon     = zo_iconFormat(IconPfad, 32, 32)

    d("|c00FFFF--------------------------------------------------|r")
    d("|c00FFFF--------------------------------------------------|r")
    d("|c00FFFF--------------------------------------------------|r")
    d("|c00FFFFABILITY DEBUG → ID:|r " .. Icon .. name:gsub("%^.+", "") .. " (" .. Safe(abilityId) .. ")")
    d("|c00FFFF--------------------------------------------------|r")

    d("|c00CDCD-- Cost|r")
    local cost = Call(function(id) return select(1, GetAbilityCost(id)) end, abilityId)
    d(Label("Cost: ") .. cost)

    d("|c00CDCD-- Time|r")
    d(Label("Cast Time: ") .. Call(GetAbilityCastInfo, abilityId))
    d(Label("Duration: ") .. Call(GetAbilityDuration, abilityId))
    d(Label("Cooldown: ") .. Call(GetAbilityCooldown, abilityId))

    d("|c00CDCD-- Reichweite / AoE|r")
    d(Label("Range: ") .. Call(GetAbilityRange, abilityId))
    d(Label("Radius: ") .. Call(GetAbilityRadius, abilityId))
    d(Label("Angle Distance: ") .. Call(GetAbilityAngleDistance, abilityId))
    d(Label("Target Description: ") .. Call(GetAbilityTargetDescription, abilityId))

    d("|c00CDCD-- Typen|r")
    d(Label("Buff Type: ") .. Call(GetAbilityBuffType, abilityId))

    d("|c00CDCD-- Flags|r")
    d(Label("Is Passive: ") .. Call(IsAbilityPassive, abilityId))
    d(Label("Is Ultimate: ") .. Call(IsAbilityUltimate, abilityId))
    d(Label("Is Permant: ") .. Call(IsAbilityPermanent, abilityId))

    d("|c00CDCD-- Rolle|r")
    local isTankRole, isHealerRole, isDamageRole = GetAbilityRoles(abilityId)
    d(Label("Tank: ") .. "|c00FF00" .. tostring(isTankRole) .. "|r")
    d(Label("Healer: ") .. "|c00FF00" .. tostring(isHealerRole) .. "|r")
    d(Label("DD: ") .. "|c00FF00" .. tostring(isDamageRole) .. "|r")

    d("|c00CDCD-- Diverse|r")
    d(Label("Mundus Typ: ") .. Call(GetAbilityMundusStoneType, abilityId))
    d(Label("Num Derived Stats: ") .. Call(GetAbilityNumDerivedStats, abilityId))
    d(Label("Num Advanced Stat: ") .. Call(GetAbilityNumAdvancedStats, abilityId))
    d(Label("Crafted: ") .. Call(GetAbilityCraftedAbilityId, abilityId))

    d("|c00FFFF--------------------------------------------------|r")
    d("|c00FFFFABILITY DEBUG END|r")
    d("|c00FFFF--------------------------------------------------|r")
end
