DsRGuildBuffSetting = DsRGuildBuffSetting or {}
local DsRBS = DsRGuildBuffSetting

DsRBS.controls = {}   -- zentrale Registry für alle Controls
DsRBS.popups   = {}   -- Registry für dynamische Popups pro Rolle

local DsRIcon = DsRglobals:HolidayIconLoad()

-- ============================================================
-- Hilfsfunktionen für dynamische Popups
-- ============================================================
function DsRBS:GetOrCreatePopup(role, anchorButton)
    if self.popups[role] then
        return self.popups[role]
    end

    local parent = DsRBuffSettingsWindow
    if not parent then return nil end

    local wm = WINDOW_MANAGER

    -- Haupt-Popup-Control
    local popup = wm:CreateControl(nil, parent, CT_CONTROL)
    popup:SetHidden(true)
    popup:SetMouseEnabled(true)
    popup:SetDrawTier(DT_HIGH)
    popup:SetDrawLayer(DL_OVERLAY)
    popup:SetDrawLevel(9997)

    -- Erstmal eine Standardgröße, wird nach Rendern angepasst
    popup:SetDimensions(260, 150)

    -- An den Button andocken (rechts daneben)
    if anchorButton then
        popup:ClearAnchors()
        popup:SetAnchor(LEFT, anchorButton, RIGHT, 10, 0)
    else
        popup:SetAnchor(CENTER, parent, CENTER, 0, 0)
    end

    -- Hintergrund
    local bg = wm:CreateControl(nil, popup, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 1)
    bg:SetEdgeColor(1, 1, 1, 1)
    popup.bg = bg

    -- Content-Container
    local content = wm:CreateControl(nil, popup, CT_CONTROL)
    content:SetAnchor(TOPLEFT, popup, TOPLEFT, 10, 10)
    content:SetDimensions(240, 200)
    popup.content = content

    popup:SetHandler("OnMouseExit", function()
        if not MouseIsOver(popup) then
            popup:SetHidden(true)
        end
    end)
    
    self.popups[role] = popup
    return popup
end

function DsRBS:SetupHover(button, role)
    button:SetHandler("OnMouseEnter", function()
            -- Wenn Popup schon offen ist und die Maus darüber ist → NICHT neu rendern
        local popup = DsRBS.popups[role]
        if popup and not popup:IsHidden() and MouseIsOver(popup) then
            return
        end

        local popup = DsRBS:GetOrCreatePopup(role, button)
        DsRBS:RenderPopupColumns(popup, role)
        popup:SetHidden(false)
    end)

    button:SetHandler("OnMouseExit", function()
        local popup = DsRBS.popups[role]
        if not popup then return end

        if not MouseIsOver(popup) then
            popup:SetHidden(true)
        end
    end)
end

-- ============================================================
-- Text aus Editboxen je Rolle
-- ============================================================
function DsRBS:GetEditBoxTextForRole(role)
    if role == "Tank" then
        return DsRBuffSettingsWindowTankEdit:GetText()
    elseif role == "Heal" then
        return DsRBuffSettingsWindowHealEdit:GetText()
    elseif role == "DPS" then
        return DsRBuffSettingsWindowDDEdit:GetText()
    end
    return ""
end

-- ============================================================
-- Spalten-Daten vorbereiten
-- ============================================================
function DsRBS:BuildPopupColumns(role)
    local text = DsRBS:GetEditBoxTextForRole(role)
    if not text or text == "" then
        return { { "Keine Buffs eingetragen." } }
    end

    local maxPerColumn = DsRGuildLoot.sV.DsRBuff_CurrentRow or 15
    local entries = {}

    for entry in string.gmatch(text, "([^,]+)") do
        local id = tonumber(zo_strtrim(entry))
        if id then
            local buff = DsRBuffData.Buffs[id]
            if buff then
                local icon = zo_iconFormat(buff.icon, 24, 24)
                local name = tostring(buff.name):gsub("%^.+", "") or ("ID: " .. id)
                table.insert(entries, icon .. "  " .. name)
            else
                table.insert(entries, "❓ Unbekannt: " .. id)
            end
        end
    end

    local columns = {}
    local col     = {}

    for _, line in ipairs(entries) do
        table.insert(col, line)
        if #col >= maxPerColumn then
            table.insert(columns, col)
            col = {}
        end
    end

    if #col > 0 then
        table.insert(columns, col)
    end

    return columns
end

-- ============================================================
-- Popup-Inhalt rendern (dynamisch)
-- ============================================================
function DsRBS:RenderPopupColumns(popup, role)
    if not popup then return end

    -- alten Content-Container komplett entsorgen
    if popup.content then
        popup.content:SetHidden(true)
        popup.content:SetParent(nil)
        popup.content = nil
    end

    local wm = WINDOW_MANAGER

    -- neuen Content-Container anlegen
    local content = wm:CreateControl(nil, popup, CT_CONTROL)
    content:SetAnchor(TOPLEFT, popup, TOPLEFT, 10, 10)
    content:SetDimensions(240, 200)
    popup.content = content

    local columns = DsRBS:BuildPopupColumns(role)

    local colWidth  = 260
    local maxHeight = 0

    content:SetDimensions(#columns * colWidth, 2000)

    for colIndex, colData in ipairs(columns) do
        local colControl = wm:CreateControl(nil, content, CT_CONTROL)
        colControl:SetAnchor(TOPLEFT, content, TOPLEFT, (colIndex - 1) * colWidth, 0)
        colControl:SetDimensions(colWidth, 10)

        local y = 0
        for _, line in ipairs(colData) do
            local label = wm:CreateControl(nil, colControl, CT_LABEL)
            label:SetFont("ZoFontGame")
            label:SetText(line)
            label:SetAnchor(TOPLEFT, colControl, TOPLEFT, 0, y)
            label:SetWidth(colWidth - 10)
            label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

            y = y + label:GetTextHeight() + 4
        end

        colControl:SetHeight(y)
        if y > maxHeight then maxHeight = y end
    end

    local totalWidth  = #columns * colWidth + 20
    local totalHeight = maxHeight + 20

    popup:SetDimensions(totalWidth, totalHeight)
    content:SetDimensions(totalWidth - 20, totalHeight - 20)

    if popup.bg then
        popup.bg:SetDimensions(totalWidth, totalHeight)
    end
end

-- ============================================================
-- Fenster initialisieren
-- ============================================================
function DsRBS:Init()
    local win = DsRBuffSettingsWindow
    if not win then return end

    DsRGuildLoot = DsRGuildLoot or {}
    DsRGuildLoot.sV = DsRGuildLoot.sV or {}
    DsRGuildLoot.sV.DsRBuffSettingXoff = DsRGuildLoot.sV.DsRBuffSettingXoff or 300
    DsRGuildLoot.sV.DsRBuffSettingYoff = DsRGuildLoot.sV.DsRBuffSettingYoff or 200

    win:ClearAnchors()
    win:SetAnchor(
        TOPLEFT,
        GuiRoot,
        TOPLEFT,
        DsRGuildLoot.sV.DsRBuffSettingXoff,
        DsRGuildLoot.sV.DsRBuffSettingYoff
    )

    win:SetHandler("OnMoveStop", function()
        DsRGuildLoot.sV.DsRBuffSettingXoff = win:GetLeft()
        DsRGuildLoot.sV.DsRBuffSettingYoff = win:GetTop()
    end)

    DsRBuffSettingsWindowTitle:SetText(
        zo_iconFormat(DsRIcon, 36, 36) ..
        "|c9fb6cdDsR - Buff-Management|r" ..
        zo_iconFormat(DsRIcon, 36, 36)
    )
    DsRBuffSettingsWindowSubTitle:SetText("Eingeloggter Char: |cadff2f" .. GetUnitName("player") .. "|r")
    DsRBuffSettingsWindowInfoTitleA:SetText(GetString(DsRGuildMenue_BuffsWhiteDesc))
    DsRBuffSettingsWindowInfoTitleB:SetText(GetString(DsRGuildMenue_BuffsWhiteDesc1))

    DsRBuffSettingsWindowTankLabel:SetText("|cFF0000Tank|r")
    DsRBuffSettingsWindowHealLabel:SetText("|c00FF00Heal|r")
    DsRBuffSettingsWindowDDLabel:SetText("|cADD8E6DPS|r")

    self:SetupButtons()

    self:ApplyEditBoxStyle(DsRBuffSettingsWindowTankEdit, DsRBuffSettingsWindowTankLabel)
    self:ApplyEditBoxStyle(DsRBuffSettingsWindowHealEdit, DsRBuffSettingsWindowHealLabel)
    self:ApplyEditBoxStyle(DsRBuffSettingsWindowDDEdit,  DsRBuffSettingsWindowDDLabel)

    DsRBS.controls.TankEdit = DsRBuffSettingsWindowTankEdit
    DsRBS.controls.HealEdit = DsRBuffSettingsWindowHealEdit
    DsRBS.controls.DDEdit   = DsRBuffSettingsWindowDDEdit

    self:CenterDropdowns()
    self:InitDropdowns()

    -- Hover für Buttons einrichten (dynamische Popups)
    DsRBS:SetupHover(DsRBuffSettingsWindowTankShowListButton, "Tank")
    DsRBS:SetupHover(DsRBuffSettingsWindowHealShowListButton, "Heal")
    DsRBS:SetupHover(DsRBuffSettingsWindowDDShowListButton,   "DPS")

    DsRBuffSettingsWindowTankEdit:SetHandler("OnTextChanged", function(selfEdit)
        local text  = selfEdit:GetText()
        local clean = text:gsub("[^0-9,%s]", "")

        if clean ~= text then
            selfEdit:SetText(clean)
            selfEdit:SetCursorPosition(#clean)
        end

        DsRBS:SaveCurrentEdit("Tank", clean)
        DsRGuildBuffs.RefreshUI()
    end)

    DsRBuffSettingsWindowHealEdit:SetHandler("OnTextChanged", function(selfEdit)
        local text  = selfEdit:GetText()
        local clean = text:gsub("[^0-9,%s]", "")
        if clean ~= text then
            selfEdit:SetText(clean)
            selfEdit:SetCursorPosition(#clean)
        end
        DsRBS:SaveCurrentEdit("Heal", clean)
        DsRGuildBuffs.RefreshUI()
    end)

    DsRBuffSettingsWindowDDEdit:SetHandler("OnTextChanged", function(selfEdit)
        local text  = selfEdit:GetText()
        local clean = text:gsub("[^0-9,%s]", "")
        if clean ~= text then
            selfEdit:SetText(clean)
            selfEdit:SetCursorPosition(#clean)
        end
        DsRBS:SaveCurrentEdit("DPS", clean)
        DsRGuildBuffs.RefreshUI()
    end)

    self:LoadCurrentEdits()
end

-- ============================================================
-- Buttons erstellen & zentrieren
-- ============================================================
function DsRBS:SetupButtons()
    local win = DsRBuffSettingsWindow

    local analyseBtn  = DsRBuffSettingsWindowAnalyseButton
    local closeBtn    = DsRBuffSettingsWindowCloseButton
    local doubleBtn   = DsRBuffSettingsWindowDoubleCheckButton
    local TankSetBtn  = DsRBuffSettingsWindowTankSetRoleButton
    local HealSetBtn  = DsRBuffSettingsWindowHealSetRoleButton
    local DPSSetBtn   = DsRBuffSettingsWindowDDSetRoleButton
    local TankShowBtn = DsRBuffSettingsWindowTankShowListButton
    local HealShowBtn = DsRBuffSettingsWindowHealShowListButton
    local DPSShowBtn  = DsRBuffSettingsWindowDDShowListButton

    analyseBtn:SetText(GetString(DsRGuildMenue_BuffsIDAnalySearch))
    closeBtn:SetText(GetString(DsRGuildMenue_BuffsAnalyseFilterClose))
    doubleBtn:SetText(GetString(DsRGuildMenue_BuffsCheckClean))
    TankSetBtn:SetText(string.format(GetString(DsRGuildMenue_BuffsSetRole), "|cFF0000Tank|r"))
    HealSetBtn:SetText(string.format(GetString(DsRGuildMenue_BuffsSetRole), "|c00FF00Heal|r"))
    DPSSetBtn:SetText(string.format(GetString(DsRGuildMenue_BuffsSetRole), "|cADD8E6DD|r"))
    TankShowBtn:SetText(GetString(DsRGuildMenue_BuffsShowList))
    HealShowBtn:SetText(GetString(DsRGuildMenue_BuffsShowList))
    DPSShowBtn:SetText(GetString(DsRGuildMenue_BuffsShowList))

    analyseBtn:SetHandler("OnClicked", function()
        DsRGuildBuffAnalyse:ShowAnalyseWindow()
    end)

    closeBtn:SetHandler("OnClicked", function()
        win:SetHidden(true)
    end)

    doubleBtn:SetHandler("OnClicked", function()
        DsRBS:CleanAllEdits()
    end)

    TankSetBtn:SetHandler("OnClicked", function()
        DsRGuildBuffs:SetRoleTank()
    end)

    HealSetBtn:SetHandler("OnClicked", function()
        DsRGuildBuffs:SetRoleHeal()
    end)

    DPSSetBtn:SetHandler("OnClicked", function()
        DsRGuildBuffs:SetRoleDD()
    end)

    DsRBS.controls.AnalyseButton     = analyseBtn
    DsRBS.controls.CloseButton       = closeBtn
    DsRBS.controls.DoubleCheckButton = doubleBtn
end

-- ============================================================
-- Dropdowns zentrieren
-- ============================================================
function DsRBS:CenterDropdowns()
    local container = DsRBuffSettingsWindowDropdownContainer
    local ort       = DsRBuffSettingsWindowDropdownContainerOrt
    local char      = DsRBuffSettingsWindowDropdownContainerChar

    if not (container and ort and char) then return end

    local cw = container:GetWidth()
    local dw = 180
    local spacing = 40
    local total = (dw * 2) + spacing
    local startX = (cw - total) / 2

    ort:ClearAnchors()
    ort:SetAnchor(LEFT, container, LEFT, startX, 0)

    char:ClearAnchors()
    char:SetAnchor(LEFT, container, LEFT, startX + dw + spacing, 0)

    DsRBS.controls.DropdownOrt = ort
    DsRBS.controls.DropdownChar = char
end

-- ============================================================
-- Dynamischer Hintergrund + feste Größe für Editboxen
-- ============================================================
function DsRBS:ApplyEditBoxStyle(editBox, anchorLabel)
    local win = DsRBuffSettingsWindow
    if not editBox or not anchorLabel then return end

    local wm = WINDOW_MANAGER

    local margin = 20
    local bgHeight = 180
    local editHeight = 160

    local bgWidth = win:GetWidth() - (margin * 2)
    local editWidth = bgWidth - 20

    local bgName = editBox:GetName() .. "BG"
    local bg = _G[bgName]

    if not bg then
        bg = wm:CreateControl(bgName, win, CT_BACKDROP)
        bg:SetCenterColor(0.2, 0.2, 0.2, 1)
        bg:SetEdgeColor(1, 1, 1, 0.4)
    end

    bg:ClearAnchors()
    bg:SetDimensions(bgWidth, bgHeight)
    bg:SetAnchor(TOP, anchorLabel, BOTTOM, 0, 10)

    editBox:ClearAnchors()
    editBox:SetDimensions(editWidth, editHeight)
    editBox:SetAnchor(CENTER, bg, CENTER, 0, 0)

    editBox:SetMaxInputChars(1000)
end

-- ============================================================
-- Dropdowns füllen
-- ============================================================
local function BuildOrtDropdownChoices()
    local list = {}
    local lang = GetCVar("language.2")

    table.insert(list, "PvP")

    if lang == "de" then
        table.insert(list, "Allgemein")
    else
        table.insert(list, "General")
    end

    for _, raid in ipairs(DsRglobals.Raids) do
        local name = (lang == "de") and raid.de or raid.en
        if name and name ~= "" then
            table.insert(list, name)
        end
    end

    table.sort(list)
    return list
end

local function BuildCharDropdownChoices()
    local Charlist = {}

    for _, CharName in ipairs(DsRGuildLoot.sV.characters) do
        table.insert(Charlist, CharName)
    end
    table.sort(Charlist)
    return Charlist
end

function DsRBS:InitDropdowns()
    DsRBS.controls.DropdownOrt  = DsRBuffSettingsWindowDropdownContainerOrt
    DsRBS.controls.DropdownChar = DsRBuffSettingsWindowDropdownContainerChar

    local ortDD  = ZO_ComboBox_ObjectFromContainer(DsRBS.controls.DropdownOrt)
    local charDD = ZO_ComboBox_ObjectFromContainer(DsRBS.controls.DropdownChar)

    if not ortDD or not charDD then
        d("[DsR] Fehler: Dropdown-Objekte nicht gefunden!")
        return
    end

    local ortChoices  = BuildOrtDropdownChoices()
    local charChoices = BuildCharDropdownChoices()

    ortDD:ClearItems()
    charDD:ClearItems()

    for _, name in ipairs(ortChoices) do
        local entry = ortDD:CreateItemEntry(name, function()
            DsRBS:OnOrtSelected(name)
        end)
        ortDD:AddItem(entry)
    end

    local savedOrt = DsRGuildLoot.sV.DsRBuff_CurrentKey
    if savedOrt and savedOrt ~= "" then
        for _, name in ipairs(ortChoices) do
            if name == savedOrt then
                ortDD:SetSelectedItem(savedOrt)
                break
            end
        end
    end

    for _, name in ipairs(charChoices) do
        local entry = charDD:CreateItemEntry(name, function()
            DsRBS:OnCharSelected(name)
        end)
        charDD:AddItem(entry)
    end

    local currentChar = GetUnitName("player")
    for _, name in ipairs(charChoices) do
        if name == currentChar then
            charDD:SetSelectedItem(currentChar)
            DsRGuildLoot.sV.DsRBuff_CurrentChar = currentChar
            return
        end
    end

    if #charChoices > 0 then
        charDD:SetSelectedItem(charChoices[1])
        DsRGuildLoot.sV.DsRBuff_CurrentChar = charChoices[1]
    end
end

function DsRBS:LoadCurrentEdits()
    local ort = DsRGuildLoot.sV.DsRBuff_CurrentKey
    local char = DsRGuildLoot.sV.DsRBuff_CurrentChar

    if not ort or not char then return end

    local data = DsRGuildBuffsCharSettings["Default"][GetDisplayName()][char][ort]

    DsRBuffSettingsWindowTankEdit:SetText(data and data.Tank or "")
    DsRBuffSettingsWindowHealEdit:SetText(data and data.Heal or "")
    DsRBuffSettingsWindowDDEdit:SetText(data and data.DPS or "")
end

-- ============================================================
-- SPEICHERUNG
-- ============================================================
function DsRBS:OnOrtSelected(choice)
    DsRGuildLoot.sV.DsRBuff_CurrentKey = choice
    
    local ort  = DsRGuildLoot.sV.DsRBuff_CurrentKey
    local char = DsRGuildLoot.sV.DsRBuff_CurrentChar
    local data = DsRGuildBuffsCharSettings["Default"][GetDisplayName()][char][ort]

    DsRBuffSettingsWindowTankEdit:SetText(data and data.Tank or "")
    DsRBuffSettingsWindowHealEdit:SetText(data and data.Heal or "")
    DsRBuffSettingsWindowDDEdit:SetText(data and data.DPS or "")
end

function DsRBS:OnCharSelected(choice)
    DsRGuildLoot.sV.DsRBuff_CurrentChar = choice

    local ort  = DsRGuildLoot.sV.DsRBuff_CurrentKey
    local char = DsRGuildLoot.sV.DsRBuff_CurrentChar
    local data = DsRGuildBuffsCharSettings["Default"][GetDisplayName()][char][ort]

    DsRBuffSettingsWindowTankEdit:SetText(data and data.Tank or "")
    DsRBuffSettingsWindowHealEdit:SetText(data and data.Heal or "")
    DsRBuffSettingsWindowDDEdit:SetText(data and data.DPS or "")
end

function DsRBS:SaveCurrentEdit(role, text)
    local ort = DsRGuildLoot.sV.DsRBuff_CurrentKey
    local char = DsRGuildLoot.sV.DsRBuff_CurrentChar

    if not ort or not char then
        d("[DsR] Fehler: Ort oder Charakter nicht gesetzt!")
        return
    end

    DsRGuildBuffsCharSettings["Default"][GetDisplayName()][char][ort][role] = text
end

-- ============================================================
-- BEREINIGEN
-- ============================================================
function DsRBS:CleanAllEdits()
    local ort  = DsRGuildLoot.sV.DsRBuff_CurrentKey
    local char = DsRGuildLoot.sV.DsRBuff_CurrentChar

    if not ort or not char then
        d("[DsR] Fehler: Ort oder Charakter nicht gesetzt!")
        return
    end

    DsRGuildBuffsCharSettings["Default"]                                = DsRGuildBuffsCharSettings["Default"] or {}
    DsRGuildBuffsCharSettings["Default"][GetDisplayName()]              = DsRGuildBuffsCharSettings["Default"][GetDisplayName()] or {}
    DsRGuildBuffsCharSettings["Default"][GetDisplayName()][char]        = DsRGuildBuffsCharSettings["Default"][GetDisplayName()][char] or {}
    DsRGuildBuffsCharSettings["Default"][GetDisplayName()][char][ort]   = DsRGuildBuffsCharSettings["Default"][GetDisplayName()][char][ort] or {}

    local saveRef = DsRGuildBuffsCharSettings["Default"][GetDisplayName()][char][ort]

    local function clean(text)
        if not text or text == "" then return "" end

        text = text:gsub("[^0-9,%s]", "")

        local seen = {}
        local result = {}

        for entry in string.gmatch(text, "([^,]+)") do
            entry = zo_strtrim(entry)
            if entry ~= "" and not seen[entry] then
                seen[entry] = true
                table.insert(result, entry)
            end
        end

        return table.concat(result, ", ")
    end

    local tankText = DsRBuffSettingsWindowTankEdit:GetText()
    local cleanedTank = clean(tankText)
    DsRBuffSettingsWindowTankEdit:SetText(cleanedTank)
    saveRef["Tank"] = cleanedTank

    local healText = DsRBuffSettingsWindowHealEdit:GetText()
    local cleanedHeal = clean(healText)
    DsRBuffSettingsWindowHealEdit:SetText(cleanedHeal)
    saveRef["Heal"] = cleanedHeal

    local ddText = DsRBuffSettingsWindowDDEdit:GetText()
    local cleanedDD = clean(ddText)
    DsRBuffSettingsWindowDDEdit:SetText(cleanedDD)
    saveRef["DPS"] = cleanedDD

    DsRGuildBuffs.RefreshUI()
end

-- ============================================================
-- Fenster anzeigen
-- ============================================================
function DsRBS:Show()
    if not self.initialized then
        self:Init()
        self.initialized = true
    end

    DsRBuffSettingsWindow:SetHidden(false)
    DsRGuildBuffs.RefreshUI()
    SCENE_MANAGER:ShowBaseScene()
    SCENE_MANAGER:SetInUIMode(true)
end
