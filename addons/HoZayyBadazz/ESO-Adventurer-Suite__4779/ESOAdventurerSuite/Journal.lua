-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

local EPC = ESOProgressionCoach
EPC.Journal = EPC.Journal or {}
local J = EPC.Journal
local wm = WINDOW_MANAGER

local TABS = {"NOTES", "PINS", "BUILD", "GEAR", "SKILLS", "COMBAT", "ACTIVITY", "QUESTS", "TRAVEL", "TOOLS", "ACHIEVEMENTS", "STATS", "CODEX", "DICE"}
local TAB_LABELS = {
    NOTES="Notes", PINS="Checkpoints", BUILD="Build Guide", GEAR="Gear & Sets", SKILLS="Skills & CP",
    COMBAT="Combat", ACTIVITY="Activities", QUESTS="Quest Finder", TRAVEL="Map / Travel", TOOLS="Utilities",
    ACHIEVEMENTS="Achievements", STATS="Character Stats", CODEX="Crafting Codex", DICE="Dice & Coin",
}
local TAB_TITLES = {
    NOTES="TAMRIEL CODEX", PINS="CHECKPOINTS", BUILD="BUILD GUIDE", GEAR="GEAR & SETS", SKILLS="SKILLS & CHAMPION",
    COMBAT="COMBAT", ACTIVITY="ACTIVITIES", QUESTS="QUEST FINDER", TRAVEL="MAP & TRAVEL", TOOLS="UTILITIES",
    ACHIEVEMENTS="ACHIEVEMENTS", STATS="CHARACTER STATS", CODEX="CRAFTING CODEX", DICE="DICE & COIN",
}
local TAB_PAGE_NUMBERS = { NOTES="01", PINS="02", BUILD="03", GEAR="04", SKILLS="05", COMBAT="06", ACTIVITY="07", QUESTS="08", TRAVEL="09", TOOLS="10", ACHIEVEMENTS="11", STATS="12", CODEX="13", DICE="14" }
local SUITE_TABS = { BUILD=true, GEAR=true, SKILLS=true, COMBAT=true, ACTIVITY=true, QUESTS=true, TRAVEL=true, TOOLS=true }
local CATEGORIES = {"ALL", "Adventure", "Quests", "Builds", "Crafting", "Roleplay", "Personal"}
local THEMES = {
    PARCHMENT = { bg={0.0,0.0,0.0,0.0}, panel={0.93,0.88,0.76,0.08}, page={0.955,0.915,0.81,0.992}, page2={0.965,0.925,0.825,0.992}, cover={0.10,0.07,0.035,0.96}, edge={0.50,0.38,0.18,0.92}, text={0.15,0.09,0.04,1}, accent={0.32,0.18,0.08,1} },
    MIDNIGHT  = { bg={0.010,0.014,0.024,0.99}, panel={0.035,0.045,0.062,0.96}, page={0.050,0.060,0.082,0.98}, page2={0.040,0.050,0.072,0.98}, cover={0.010,0.014,0.024,1}, edge={0.24,0.36,0.54,1}, text={0.88,0.92,0.98,1}, accent={0.43,0.68,0.96,1} },
    DAEDRIC   = { bg={0.050,0.008,0.008,0.99}, panel={0.12,0.025,0.025,0.96}, page={0.145,0.035,0.030,0.98}, page2={0.115,0.022,0.024,0.98}, cover={0.045,0.005,0.006,1}, edge={0.62,0.10,0.10,1}, text={0.96,0.84,0.78,1}, accent={0.98,0.31,0.22,1} },
    FROST     = { bg={0.018,0.042,0.056,0.99}, panel={0.045,0.085,0.105,0.96}, page={0.060,0.110,0.130,0.98}, page2={0.045,0.090,0.112,0.98}, cover={0.012,0.035,0.050,1}, edge={0.30,0.66,0.76,1}, text={0.87,0.96,0.99,1}, accent={0.43,0.86,0.94,1} },
}
local THEME_ORDER = {"PARCHMENT", "MIDNIGHT", "DAEDRIC", "FROST"}
local PIN_TYPE = "EAS_CUSTOM_JOURNAL_PIN"

local function getNativeLoreBookMedium()
    local medium = BOOK_MEDIUM_YELLOWED_PAPER or BOOK_MEDIUM_NOTE or BOOK_MEDIUM_SCROLL
    if not medium or type(GetBookMediumInfo) ~= "function" then return nil end
    local ok, bg, numPages, pageWidth, pageHeight, pageYOffset, leftPageXOffset, rightPageXOffset, openSound, closeSound, turnPageSound = pcall(GetBookMediumInfo, medium)
    if not ok or not bg or bg == "" then return nil end
    return {
        medium = medium, bg = bg, numPages = numPages, pageWidth = pageWidth, pageHeight = pageHeight,
        pageYOffset = pageYOffset, leftPageXOffset = leftPageXOffset, rightPageXOffset = rightPageXOffset,
        openSound = openSound, closeSound = closeSound, turnPageSound = turnPageSound,
    }
end

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a,b,c,d,e,f,g,h = pcall(fn, ...)
    if not ok then return fallback end
    return a,b,c,d,e,f,g,h
end
local function trim(s)
    s = tostring(s or "")
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end
local function nowStamp()
    return tonumber(safe(GetTimeStamp, 0)) or 0
end
local function setButtonStyle(button, selected, theme)
    if not button then return end
    local t = theme or THEMES.PARCHMENT
    if button.SetNormalFontColor then
        if selected then button:SetNormalFontColor(t.accent[1],t.accent[2],t.accent[3],1)
        else button:SetNormalFontColor(t.text[1],t.text[2],t.text[3],0.92) end
        button:SetMouseOverFontColor(t.accent[1],t.accent[2],t.accent[3],1)
        button:SetPressedFontColor(t.accent[1],t.accent[2],t.accent[3],1)
    end
end
local function makeButton(name, parent, text, x, y, w, h, handler)
    local b = wm:CreateControl(name, parent, CT_BUTTON)
    b:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    b:SetDimensions(w, h)
    b:SetFont("ZoFontGameBold")
    b:SetText(text)
    if SOUNDS and SOUNDS.DEFAULT_CLICK and b.SetClickSound then b:SetClickSound(SOUNDS.DEFAULT_CLICK) end
    if handler then b:SetHandler("OnClicked", handler) end
    return b
end
local function makeLabel(name, parent, text, x, y, w, h, font)
    local l = wm:CreateControl(name, parent, CT_LABEL)
    l:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    l:SetDimensions(w, h)
    l:SetFont(font or "ZoFontGame")
    if l.SetMaxLineCount then l:SetMaxLineCount(0) end
    l:SetText(text or "")
    l:SetVerticalAlignment(TEXT_ALIGN_TOP)
    return l
end

local function getStringWidth(label, text)
    if label and type(label.GetStringWidth) == "function" then
        local ok, width = pcall(label.GetStringWidth, label, tostring(text or ""))
        if ok and type(width) == "number" then return width end
    end
    return string.len(tostring(text or "")) * 8
end

local function makeEsoSafeBookText(text)
    text = tostring(text or "")
    -- ESO fonts do not contain every Unicode symbol. Replace common UI punctuation
    -- that can render as square/missing-glyph boxes while preserving names/text.
    local replacements = {
        {string.char(226, 134, 148), " / "},   -- bidirectional arrow
        {string.char(226, 134, 146), " -> "},  -- right arrow
        {string.char(226, 128, 148), " - "},   -- em dash
        {string.char(226, 128, 147), "-"},     -- en dash
        {string.char(226, 128, 162), "-"},     -- bullet
        {string.char(194, 187), ">"},          -- double angle quote
        {string.char(226, 156, 147), "[DONE]"},-- check mark
        {string.char(194, 183), "-"},          -- middle dot
    }
    for i = 1, #replacements do
        text = text:gsub(replacements[i][1], replacements[i][2])
    end
    return text
end

local function wrapForBook(label, text, maxWidth)
    text = makeEsoSafeBookText(text)
    maxWidth = tonumber(maxWidth) or (label and label.GetWidth and label:GetWidth()) or 320
    if maxWidth <= 0 then maxWidth = 320 end
    local out = {}
    for paragraph in string.gmatch(text .. "\n", "(.-)\n") do
        if paragraph == "" then
            out[#out+1] = ""
        else
            local line = ""
            for word in string.gmatch(paragraph, "%S+") do
                local candidate = line == "" and word or (line .. " " .. word)
                if line == "" or getStringWidth(label, candidate) <= maxWidth then
                    line = candidate
                else
                    out[#out+1] = line
                    line = word
                end
            end
            if line ~= "" then out[#out+1] = line end
        end
    end
    return table.concat(out, "\n")
end

local function setBookText(label, text, width)
    if not label then return end
    label:SetText(wrapForBook(label, text, width))
end
local function makePanel(name, parent, x, y, w, h)
    local p = wm:CreateControl(name, parent, CT_BACKDROP)
    p:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    p:SetDimensions(w, h)
    p:SetEdgeTexture(nil, 1, 1, 1)
    return p
end

local function getChanceTexture(kind, sides)
    if tostring(kind) == "COIN" then return "ESOAdventurerSuite/Art/coin.dds" end
    local die = tonumber(sides) or 20
    die = math.max(2, math.floor(die))
    return string.format("ESOAdventurerSuite/Art/dice_d%d.dds", die)
end

local function styleIconButton(button, theme)
    if not button then return end
    theme = theme or THEMES.PARCHMENT
    button._theme = theme
    if button.bg then
        button.bg:SetCenterColor(theme.page[1], theme.page[2], theme.page[3], 0.34)
        button.bg:SetEdgeColor(theme.edge[1], theme.edge[2], theme.edge[3], 0.48)
    end
    if button.label then button.label:SetColor(theme.text[1], theme.text[2], theme.text[3], 1) end
end

local function makeIconButton(name, parent, texturePath, labelText, x, y, w, h, handler)
    local b = wm:CreateControl(name, parent, CT_BUTTON)
    b:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    b:SetDimensions(w, h)
    if SOUNDS and SOUNDS.DEFAULT_CLICK and b.SetClickSound then b:SetClickSound(SOUNDS.DEFAULT_CLICK) end
    if handler then b:SetHandler("OnClicked", handler) end

    local bg = wm:CreateControl(name.."_BG", b, CT_BACKDROP)
    bg:SetAnchorFill(b)
    bg:SetEdgeTexture(nil, 1, 1, 1)
    b.bg = bg

    local icon = wm:CreateControl(name.."_Icon", b, CT_TEXTURE)
    local iconSize = math.min(w - 18, h - 38)
    if iconSize < 24 then iconSize = math.min(w - 8, h - 8) end
    icon:SetDimensions(iconSize, iconSize)
    icon:SetAnchor(TOP, b, TOP, 0, 8)
    icon:SetTexture(texturePath)
    b.icon = icon

    local label = wm:CreateControl(name.."_Label", b, CT_LABEL)
    label:SetAnchor(BOTTOM, b, BOTTOM, 0, -6)
    label:SetDimensions(w - 10, 20)
    label:SetFont("ZoFontGameBold")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetText(labelText or "")
    b.label = label

    local function applyHover(alpha, edge)
        local t = b._theme or THEMES.PARCHMENT
        if b.bg then
            b.bg:SetCenterColor(t.page[1], t.page[2], t.page[3], alpha)
            b.bg:SetEdgeColor(t.edge[1], t.edge[2], t.edge[3], edge)
        end
    end
    b:SetHandler("OnMouseEnter", function() applyHover(0.48, 0.72) end)
    b:SetHandler("OnMouseExit", function() applyHover(0.34, 0.48) end)
    styleIconButton(b, THEMES.PARCHMENT)
    return b
end

function J:EnsureSaved()
    EPC.saved.journal = EPC.saved.journal or {}
    local s = EPC.saved.journal
    s.entries = s.entries or {}
    s.pins = s.pins or {}
    s.theme = s.theme or "PARCHMENT"
    if s.loreBookJournalUpgrade ~= true then s.theme = "PARCHMENT" s.loreBookJournalUpgrade = true end
    if s.nativeLoreBookJournalUpgrade ~= true then s.theme = "PARCHMENT" s.nativeLoreBookJournalUpgrade = true end
    s.activeTab = s.activeTab or "NOTES"
    s.category = s.category or "ALL"
    if s.readMode == nil then s.readMode = false end
    s.nextEntryId = tonumber(s.nextEntryId) or 1
    s.nextPinId = tonumber(s.nextPinId) or 1
    return s
end

function J:GetTheme()
    local s = self:EnsureSaved()
    return THEMES[s.theme] or THEMES.PARCHMENT
end

function J:ApplyTheme()
    if not self.window then return end
    local t = self:GetTheme()
    local themeName = self:EnsureSaved().theme or "PARCHMENT"

    -- The journal uses ESO's native Lore Reader book art. Themes tint the stock book
    -- instead of drawing opaque addon panels over the parchment.
    if self.bookTexture then
        if themeName == "MIDNIGHT" then self.bookTexture:SetColor(0.40, 0.46, 0.62, 1)
        elseif themeName == "DAEDRIC" then self.bookTexture:SetColor(0.66, 0.37, 0.31, 1)
        elseif themeName == "FROST" then self.bookTexture:SetColor(0.68, 0.82, 0.88, 1)
        else self.bookTexture:SetColor(1, 1, 1, 1) end
    end
    if self.bg then
        if self.nativeBook then self.bg:SetCenterColor(0,0,0,0) self.bg:SetEdgeColor(0,0,0,0)
        else self.bg:SetCenterColor(t.page[1],t.page[2],t.page[3],0.98) self.bg:SetEdgeColor(t.edge[1],t.edge[2],t.edge[3],0.9) end
    end
    if self.bookCover then self.bookCover:SetCenterColor(0,0,0,0) self.bookCover:SetEdgeColor(0,0,0,0) end
    if self.leftPage then self.leftPage:SetCenterColor(0,0,0,0) self.leftPage:SetEdgeColor(0,0,0,0) end
    if self.rightPage then self.rightPage:SetCenterColor(0,0,0,0) self.rightPage:SetEdgeColor(0,0,0,0) end
    if self.spine then self.spine:SetCenterColor(0,0,0,0) self.spine:SetEdgeColor(0,0,0,0) end
    if self.flipPage then
        self.flipPage:SetCenterColor(t.page2[1],t.page2[2],t.page2[3],0.92)
        self.flipPage:SetEdgeColor(t.edge[1],t.edge[2],t.edge[3],0.35)
    end
    for _, p in pairs(self.panels or {}) do
        p:SetCenterColor(0,0,0,0)
        p:SetEdgeColor(t.edge[1],t.edge[2],t.edge[3],0.18)
    end
    for _, l in pairs(self.themeLabels or {}) do l:SetColor(t.text[1],t.text[2],t.text[3],1) end
    if self.title then self.title:SetColor(t.accent[1],t.accent[2],t.accent[3],1) end
    if self.subtitle then self.subtitle:SetColor(t.text[1],t.text[2],t.text[3],0.72) end
    if self.noteTitleEdit then self.noteTitleEdit:SetColor(t.text[1],t.text[2],t.text[3],1) end
    if self.noteBodyEdit then self.noteBodyEdit:SetColor(t.text[1],t.text[2],t.text[3],1) end
    if self.checkpointNameEdit then self.checkpointNameEdit:SetColor(t.text[1],t.text[2],t.text[3],1) end
    for name, b in pairs(self.tabButtons or {}) do setButtonStyle(b, name == self.activeTab, t) end
    for name, b in pairs(self.categoryButtons or {}) do setButtonStyle(b, name == self.category, t) end
    for mode, b in pairs(self.codexButtons or {}) do setButtonStyle(b, mode == (self.codexMode or "ALCHEMY"), t) end
    for _, b in ipairs(self.topButtons or {}) do setButtonStyle(b, false, t) end
    for _, b in ipairs(self.iconButtons or {}) do styleIconButton(b, t) end
    if self.modeButton then setButtonStyle(self.modeButton, self.readMode ~= true, t) end
    if self.themeButton then setButtonStyle(self.themeButton, false, t) end
    if self.closeButton then setButtonStyle(self.closeButton, false, t) end
    if self.prevPageButton then setButtonStyle(self.prevPageButton, false, t) end
    if self.nextPageButton then setButtonStyle(self.nextPageButton, false, t) end
    if self.diceResultPanel then
        self.diceResultPanel:SetCenterColor(t.page2[1], t.page2[2], t.page2[3], 0.42)
        self.diceResultPanel:SetEdgeColor(t.edge[1], t.edge[2], t.edge[3], 0.52)
    end
    if self.diceResultValue then self.diceResultValue:SetColor(t.accent[1], t.accent[2], t.accent[3], 1) end
end

function J:CycleTheme()
    local s = self:EnsureSaved()
    local current = 1
    for i=1,#THEME_ORDER do if THEME_ORDER[i] == s.theme then current = i break end end
    current = current + 1
    if current > #THEME_ORDER then current = 1 end
    s.theme = THEME_ORDER[current]
    self:ApplyTheme()
    if self.themeButton then self.themeButton:SetText("THEME") end
end

function J:CreateEditBox(name, parent, x, y, w, h, multiLine)
    local e = wm:CreateControl(name, parent, CT_EDITBOX)
    e:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    e:SetDimensions(w, h)
    e:SetFont("ZoFontGame")
    if e.SetMaxInputChars then e:SetMaxInputChars(multiLine and 12000 or 120) end
    if multiLine and e.SetMultiLine then e:SetMultiLine(true) end
    if multiLine and e.SetNewLineEnabled then e:SetNewLineEnabled(true) end
    e:SetColor(0.18,0.11,0.05,1)
    e:SetHandler("OnTextChanged", function() self.dirty = true end)
    e:SetHandler("OnFocusLost", function() self:SaveCurrentEntry() end)
    return e
end

function J:SetEditorEnabled(enabled)
    enabled = enabled == true
    if self.noteTitleEdit then
        if self.noteTitleEdit.SetEditEnabled then self.noteTitleEdit:SetEditEnabled(enabled) end
        self.noteTitleEdit:SetMouseEnabled(enabled)
    end
    if self.noteBodyEdit then
        if self.noteBodyEdit.SetEditEnabled then self.noteBodyEdit:SetEditEnabled(enabled) end
        self.noteBodyEdit:SetMouseEnabled(enabled)
    end
    if self.modeButton then self.modeButton:SetText(enabled and "EDIT MODE" or "READ MODE") end
end

function J:FindEntry(id)
    if not id then return nil end
    local entries = self:EnsureSaved().entries
    for i=1,#entries do if entries[i].id == id then return entries[i], i end end
    return nil
end

function J:GetFilteredEntries()
    local result = {}
    local category = self.category or "ALL"
    for _, e in ipairs(self:EnsureSaved().entries) do
        if category == "ALL" or e.category == category then result[#result+1] = e end
    end
    table.sort(result, function(a,b) return (tonumber(a.modified) or 0) > (tonumber(b.modified) or 0) end)
    return result
end

function J:SaveCurrentEntry()
    if not self.currentEntryId or not self.noteTitleEdit or not self.noteBodyEdit then return end
    local e = self:FindEntry(self.currentEntryId)
    if not e then return end
    e.title = trim(self.noteTitleEdit:GetText())
    if e.title == "" then e.title = "Untitled Note" end
    e.body = tostring(self.noteBodyEdit:GetText() or "")
    e.category = e.category or (self.category ~= "ALL" and self.category or "Personal")
    e.modified = nowStamp()
    self.dirty = false
end

function J:SelectEntry(id)
    self:SaveCurrentEntry()
    local e = self:FindEntry(id)
    self.currentEntryId = e and e.id or nil
    if e then
        self.noteTitleEdit:SetText(e.title or "")
        self.noteBodyEdit:SetText(e.body or "")
    else
        self.noteTitleEdit:SetText("")
        self.noteBodyEdit:SetText("Select a note or create a new one.")
    end
    self.dirty = false
    self:RefreshNotes()
end

function J:NewEntry()
    self:SaveCurrentEntry()
    local s = self:EnsureSaved()
    local category = self.category ~= "ALL" and self.category or "Personal"
    local e = { id=s.nextEntryId, title="New Note", body="", category=category, created=nowStamp(), modified=nowStamp() }
    s.nextEntryId = s.nextEntryId + 1
    s.entries[#s.entries+1] = e
    self.currentEntryId = e.id
    self.noteTitleEdit:SetText(e.title)
    self.noteBodyEdit:SetText("")
    self.dirty = false
    self:RefreshNotes()
    if self.noteTitleEdit.TakeFocus then self.noteTitleEdit:TakeFocus() end
end

function J:DeleteEntry()
    local _, idx = self:FindEntry(self.currentEntryId)
    if not idx then return end
    table.remove(self:EnsureSaved().entries, idx)
    self.currentEntryId = nil
    self:RefreshNotes()
    local list = self:GetFilteredEntries()
    if list[1] then self:SelectEntry(list[1].id) else self:SelectEntry(nil) end
end

function J:SetCategory(category)
    self:SaveCurrentEntry()
    self.category = category
    self:EnsureSaved().category = category
    self.currentEntryId = nil
    self:RefreshNotes()
    local list = self:GetFilteredEntries()
    if list[1] then self:SelectEntry(list[1].id) else self:SelectEntry(nil) end
    self:ApplyTheme()
end

function J:RefreshNotes()
    if not self.notePage then return end
    local list = self:GetFilteredEntries()
    for i=1,#self.noteRows do
        local b = self.noteRows[i]
        local e = list[i]
        if e then
            local mark = e.id == self.currentEntryId and "> " or ""
            b:SetText(mark .. (e.title or "Untitled"))
            b:SetHidden(false)
            b.entryId = e.id
        else
            b:SetHidden(true)
            b.entryId = nil
        end
        setButtonStyle(b, e and e.id == self.currentEntryId, self:GetTheme())
    end
    if self.noteCount then self.noteCount:SetText(string.format("%d note%s", #list, #list == 1 and "" or "s")) end
    if self.deleteButton and self.deleteButton.SetEnabled then self.deleteButton:SetEnabled(self.activeTab == "NOTES" and self.currentEntryId ~= nil) end
end

function J:GetPinById(id)
    if not id then return nil end
    local pins = self:EnsureSaved().pins
    for i=1,#pins do if pins[i].id == id then return pins[i], i end end
    return nil
end

function J:RegisterMapPins()
    if self.mapPinsRegistered then return end
    if type(ZO_WorldMap_AddCustomPin) ~= "function" then return end
    local layout = { level=55, texture="EsoUI/Art/MapPins/MapPing.dds", size=30 }
    local function addPins(pinManager)
        local currentMapId = tonumber(safe(GetCurrentMapId, 0)) or 0
        local currentMapIndex = tonumber(safe(GetCurrentMapIndex, 0)) or 0
        for _, pin in ipairs(J:EnsureSaved().pins) do
            local same = (pin.mapId and pin.mapId ~= 0 and pin.mapId == currentMapId)
                or (pin.mapIndex and pin.mapIndex ~= 0 and pin.mapIndex == currentMapIndex)
            if same and tonumber(pin.x) and tonumber(pin.y) then
                pinManager:CreatePin(_G[PIN_TYPE], pin, pin.x, pin.y)
            end
        end
    end
    local ok = pcall(ZO_WorldMap_AddCustomPin, PIN_TYPE, addPins, nil, layout, nil)
    if ok and _G[PIN_TYPE] then
        self.mapPinsRegistered = true
        if type(ZO_WorldMap_SetCustomPinEnabled) == "function" then pcall(ZO_WorldMap_SetCustomPinEnabled, _G[PIN_TYPE], true) end
        if type(ZO_WorldMap_RefreshCustomPinsOfType) == "function" then pcall(ZO_WorldMap_RefreshCustomPinsOfType, _G[PIN_TYPE]) end
    end
end

function J:RefreshMapPins()
    self:RegisterMapPins()
    if self.mapPinsRegistered and type(ZO_WorldMap_RefreshCustomPinsOfType) == "function" and _G[PIN_TYPE] then
        pcall(ZO_WorldMap_RefreshCustomPinsOfType, _G[PIN_TYPE])
    end
end

function J:GetSortedCheckpoints()
    local result = {}
    for _, pin in ipairs(self:EnsureSaved().pins) do result[#result+1] = pin end
    table.sort(result, function(a,b)
        local am = tonumber(a.modified or a.created) or 0
        local bm = tonumber(b.modified or b.created) or 0
        if am == bm then return tostring(a.name or "") < tostring(b.name or "") end
        return am > bm
    end)
    return result
end

function J:FindCheckpoint(query)
    query = zo_strlower(trim(query))
    if query == "" then return nil, {} end
    local exact, matches = nil, {}
    for _, pin in ipairs(self:EnsureSaved().pins) do
        local name = zo_strlower(trim(pin.name or ""))
        if name == query then exact = pin break end
        if string.find(name, query, 1, true) then matches[#matches+1] = pin end
    end
    if exact then return exact, {exact} end
    if #matches == 1 then return matches[1], matches end
    return nil, matches
end

function J:SaveCurrentLocation(customName)
    if type(SetMapToPlayerLocation) == "function" then pcall(SetMapToPlayerLocation) end
    local x,y,_,inCurrentMap = safe(GetMapPlayerPosition, 0, "player")
    x, y = tonumber(x) or 0, tonumber(y) or 0
    if inCurrentMap == false or x <= 0 or y <= 0 then
        EPC:Print("Checkpoint could not read your current map position.")
        return false
    end

    local s = self:EnsureSaved()
    local mapName = trim(safe(GetMapName, "Current Map"))
    local zone = trim(safe(GetUnitZone, "", "player"))
    local name = trim(customName)
    if name == "" and self.checkpointNameEdit then name = trim(self.checkpointNameEdit:GetText()) end
    if name == "" then name = string.format("Checkpoint %d - %s", s.nextPinId, zone ~= "" and zone or mapName) end

    -- If a checkpoint is selected, SAVE / UPDATE HERE edits that checkpoint in place,
    -- including its custom name. With no selection, an exact-name match is updated;
    -- otherwise a new named checkpoint is created.
    local existing = self.selectedPinId and self:GetPinById(self.selectedPinId) or nil
    if not existing then
        for _, pin in ipairs(s.pins) do
            if zo_strlower(trim(pin.name or "")) == zo_strlower(name) then existing = pin break end
        end
    end

    local zoneId, worldX, worldY, worldZ = safe(GetUnitWorldPosition, 0, "player")
    local stamp = nowStamp()
    local pin = existing or { id=s.nextPinId, created=stamp }
    if not existing then
        s.nextPinId = s.nextPinId + 1
        s.pins[#s.pins+1] = pin
    end
    pin.name = name
    pin.x, pin.y = x, y
    pin.mapId = tonumber(safe(GetCurrentMapId, 0)) or 0
    pin.mapIndex = tonumber(safe(GetCurrentMapIndex, 0)) or 0
    pin.mapName, pin.zone = mapName, zone
    pin.zoneId = tonumber(zoneId) or 0
    pin.worldX, pin.worldY, pin.worldZ = tonumber(worldX) or 0, tonumber(worldY) or 0, tonumber(worldZ) or 0
    pin.modified = stamp
    pin.kind = "checkpoint"

    -- Capture the nearest discovered wayshrine while the map is already set to the
    -- player's current location. This makes newly saved checkpoints immediately travel-ready.
    self:GetNearestWayshrineForCheckpoint(pin, true)

    self.selectedPinId = pin.id
    self.checkpointPage = 1
    if self.checkpointNameEdit then self.checkpointNameEdit:SetText(name) end
    self:RefreshPinsPage()
    self:RefreshMapPins()
    EPC:Print((existing and "Checkpoint updated: " or "Checkpoint saved: ") .. name)
    return true
end

function J:DeletePin()
    local _, idx = self:GetPinById(self.selectedPinId)
    if not idx then return false end
    local removed = table.remove(self:EnsureSaved().pins, idx)
    self.selectedPinId = nil
    if self.checkpointNameEdit then self.checkpointNameEdit:SetText("") end
    self:RefreshPinsPage()
    self:RefreshMapPins()
    if removed then EPC:Print("Checkpoint deleted: " .. tostring(removed.name or "Checkpoint")) end
    return removed ~= nil
end

function J:DeleteCheckpointByName(query)
    local pin, matches = self:FindCheckpoint(query)
    if not pin then
        if #matches > 1 then
            EPC:Print("More than one checkpoint matches '" .. tostring(query) .. "'. Use a more specific name.")
        else
            EPC:Print("No checkpoint found for: " .. tostring(query))
        end
        return false
    end
    self.selectedPinId = pin.id
    return self:DeletePin()
end

function J:SetPinWaypoint(pinOverride)
    local pin = pinOverride or self:GetPinById(self.selectedPinId)
    if not pin then return false end

    -- Current ESO clients expose a world-location waypoint call. New checkpoints save
    -- world coordinates so the waypoint can be restored without depending on which
    -- map the player currently has open. Older saved pins fall back to map+PingMap.
    if type(SetPlayerWaypointByWorldLocation) == "function" and tonumber(pin.worldX) and tonumber(pin.worldZ) and (pin.worldX ~= 0 or pin.worldZ ~= 0) then
        local ok, success = pcall(SetPlayerWaypointByWorldLocation, pin.worldX, pin.worldY or 0, pin.worldZ)
        if ok and success == true then
            self.selectedPinId = pin.id
            EPC:Print("Checkpoint waypoint set: " .. tostring(pin.name or "Checkpoint"))
            return true
        end
    end

    local mapSet = false
    if type(SetMapToMapId) == "function" and tonumber(pin.mapId) and pin.mapId > 0 then
        local ok = pcall(SetMapToMapId, pin.mapId)
        mapSet = ok
    end
    if (not mapSet) and type(SetMapToMapListIndex) == "function" and tonumber(pin.mapIndex) and pin.mapIndex > 0 then
        mapSet = pcall(SetMapToMapListIndex, pin.mapIndex)
    end

    if type(PingMap) == "function" and MAP_PIN_TYPE_PLAYER_WAYPOINT and MAP_TYPE_LOCATION_CENTERED then
        local ok = pcall(PingMap, MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, pin.x, pin.y)
        if not ok then
            EPC:Print("Could not place the checkpoint waypoint on this map.")
            return false
        end
    else
        EPC:Print("Waypoint API unavailable; open the World Map to view the saved checkpoint.")
        return false
    end

    if mapSet and type(CALLBACK_MANAGER) == "table" and CALLBACK_MANAGER.FireCallbacks then
        pcall(CALLBACK_MANAGER.FireCallbacks, CALLBACK_MANAGER, "OnWorldMapChanged")
    end
    self.selectedPinId = pin.id
    EPC:Print("Checkpoint waypoint set: " .. tostring(pin.name or "Checkpoint"))
    return true
end

function J:GoToCheckpoint(query)
    local pin, matches = self:FindCheckpoint(query)
    if not pin then
        if #matches > 1 then
            EPC:Print("Multiple checkpoints match '" .. tostring(query) .. "':")
            for i=1,math.min(8,#matches) do EPC:Print("- " .. tostring(matches[i].name or "Checkpoint")) end
            EPC:Print("Use a more specific checkpoint name.")
        else
            EPC:Print("No checkpoint found for: " .. tostring(query))
        end
        return false
    end
    return self:SetPinWaypoint(pin)
end

function J:ListCheckpoints()
    local pins = self:GetSortedCheckpoints()
    if #pins == 0 then
        EPC:Print("No checkpoints saved yet. Use /esosuite checkpoint save <name>.")
        return
    end
    EPC:Print(string.format("Saved checkpoints (%d):", #pins))
    for i=1,math.min(20,#pins) do
        local p = pins[i]
        EPC:Print(string.format("%d. %s  -  %s", i, tostring(p.name or "Checkpoint"), tostring(p.zone or p.mapName or "Unknown")))
    end
    if #pins > 20 then EPC:Print(string.format("...and %d more. Open Tamriel Codex > Checkpoints to browse them.", #pins-20)) end
end

function J:ChangeCheckpointPage(delta)
    local pins = self:GetSortedCheckpoints()
    local pageSize = #self.pinRows > 0 and #self.pinRows or 7
    local pages = math.max(1, math.ceil(#pins / pageSize))
    self.checkpointPage = math.max(1, math.min(pages, (tonumber(self.checkpointPage) or 1) + (tonumber(delta) or 0)))
    self:RefreshPinsPage()
end

function J:GetNearestWayshrineForCheckpoint(pin, forceRefresh)
    if type(pin) ~= "table" then return nil end

    if not forceRefresh and tonumber(pin.nearestWayshrineNodeIndex) and pin.nearestWayshrineNodeIndex > 0
        and EPC.Travel and EPC.Travel.GetWayshrineNodeEntry then
        local cached = EPC.Travel:GetWayshrineNodeEntry(pin.nearestWayshrineNodeIndex)
        if cached then
            cached.exactCheckpointMapMatch = pin.nearestWayshrineExact == true
            return cached
        end
    end

    if EPC.Travel and EPC.Travel.GetNearestWayshrineToCheckpoint then
        local entry, exact = EPC.Travel:GetNearestWayshrineToCheckpoint(pin)
        if entry then
            pin.nearestWayshrineNodeIndex = entry.nodeIndex
            pin.nearestWayshrineName = entry.name
            pin.nearestWayshrineZone = entry.zoneName
            pin.nearestWayshrineExact = exact == true
            return entry
        end
    end

    pin.nearestWayshrineNodeIndex = nil
    pin.nearestWayshrineName = nil
    pin.nearestWayshrineZone = nil
    pin.nearestWayshrineExact = nil
    return nil
end

function J:TravelToNearestCheckpointWayshrine()
    local pin = self:GetPinById(self.selectedPinId)
    if not pin then
        EPC:Print("Select a checkpoint first.")
        return false
    end
    local entry = self:GetNearestWayshrineForCheckpoint(pin, false)
    if not entry then
        EPC:Print("No discovered wayshrine could be matched to this checkpoint.")
        return false
    end
    if EPC.Travel and EPC.Travel.TravelToWayshrineNode then
        return EPC.Travel:TravelToWayshrineNode(entry.nodeIndex, entry.name)
    end
    EPC:Print("Travel helper is unavailable.")
    return false
end

function J:RefreshPinsPage()
    if not self.pinRows then return end
    local pins = self:GetSortedCheckpoints()
    local pageSize = #self.pinRows
    local pages = math.max(1, math.ceil(#pins / math.max(1,pageSize)))
    self.checkpointPage = math.max(1, math.min(pages, tonumber(self.checkpointPage) or 1))
    local first = (self.checkpointPage - 1) * pageSize + 1

    for i=1,#self.pinRows do
        local b = self.pinRows[i]
        local pin = pins[first + i - 1]
        if pin then
            local mark = pin.id == self.selectedPinId and "> " or ""
            b:SetText(string.format("%s%s   -   %s", mark, pin.name or "Checkpoint", pin.zone or pin.mapName or "Map"))
            b:SetHidden(false)
            b.pinId = pin.id
        else
            b:SetHidden(true)
            b.pinId = nil
        end
        setButtonStyle(b, pin and pin.id == self.selectedPinId, self:GetTheme())
    end

    if self.checkpointPageLabel then
        self.checkpointPageLabel:SetText(string.format("%d checkpoint%s   -   page %d/%d", #pins, #pins == 1 and "" or "s", self.checkpointPage, pages))
    end
    if self.checkpointPrev and self.checkpointPrev.SetEnabled then self.checkpointPrev:SetEnabled(self.checkpointPage > 1) end
    if self.checkpointNext and self.checkpointNext.SetEnabled then self.checkpointNext:SetEnabled(self.checkpointPage < pages) end

    if self.pinInfo then
        local p = self:GetPinById(self.selectedPinId)
        if p then
            local shrine = self:GetNearestWayshrineForCheckpoint(p, false)
            self.selectedCheckpointWayshrine = shrine
            local shrineText = "Nearest discovered wayshrine: None matched"
            if shrine then
                local shrineLabel = shrine.exactCheckpointMapMatch == false and "Available discovered wayshrine in zone" or "Nearest discovered wayshrine"
                shrineText = string.format("%s: %s\nTravel: %s - %s", shrineLabel, shrine.name or "Wayshrine", shrine.costText or "Cost unknown", shrine.statusText or "Ready")
            end
            setBookText(self.pinInfo, string.format("%s\n%s\nCoordinates: %.2f, %.2f\n\n%s\n\nSET WAYPOINT marks the exact checkpoint. TRAVEL TO WAYSHRINE takes you to the nearest discovered wayshrine ESO exposes for that saved area.", p.name or "Checkpoint", p.zone or p.mapName or "", (p.x or 0)*100, (p.y or 0)*100, shrineText), self.pinInfo:GetWidth())
            if self.pinWayshrine then
                if self.pinWayshrine.SetEnabled then self.pinWayshrine:SetEnabled(shrine ~= nil) end
                setButtonStyle(self.pinWayshrine, false, self:GetTheme())
            end
        else
            self.selectedCheckpointWayshrine = nil
            setBookText(self.pinInfo, "Save named places you want to revisit  -  XP farms, material routes, fishing spots, bosses, treasure areas, or anything else. Select a checkpoint to see its nearest discovered wayshrine and travel there, or place a waypoint on the exact saved location.", self.pinInfo:GetWidth())
            if self.pinWayshrine and self.pinWayshrine.SetEnabled then self.pinWayshrine:SetEnabled(false) end
        end
    end
end

function J:Roll(sides)
    sides = math.max(2, tonumber(sides) or 20)
    local result = math.random(1, sides)
    self.diceHistory = self.diceHistory or {}
    self.lastChanceKind = "DICE"
    self.lastChanceSides = sides
    self.lastChanceResult = tostring(result)
    table.insert(self.diceHistory, 1, string.format("d%d  ->  %d", sides, result))
    while #self.diceHistory > 12 do table.remove(self.diceHistory) end
    self:RefreshDice()
end

function J:TossCoin()
    self.diceHistory = self.diceHistory or {}
    local result = math.random(1,2) == 1 and "HEADS" or "TAILS"
    self.lastChanceKind = "COIN"
    self.lastChanceSides = nil
    self.lastChanceResult = result
    table.insert(self.diceHistory, 1, "Coin  ->  " .. result)
    while #self.diceHistory > 12 do table.remove(self.diceHistory) end
    self:RefreshDice()
end

function J:RefreshDice()
    local history = self.diceHistory or {}
    local historyText = #history > 0 and table.concat(history, "\n") or "Choose a die or toss a coin."
    if self.diceHistoryOutput then
        setBookText(self.diceHistoryOutput, historyText, self.diceHistoryOutput:GetWidth())
    elseif self.diceOutput then
        setBookText(self.diceOutput, historyText, self.diceOutput:GetWidth())
    end

    if self.diceResultTitle and self.diceResultValue and self.diceResultSub then
        if self.lastChanceKind == "COIN" then
            self.diceResultTitle:SetText("COIN TOSS")
            self.diceResultValue:SetText(self.lastChanceResult or "-")
            setBookText(self.diceResultSub, "A Septim-inspired flip for quick decisions and roleplay moments.", self.diceResultSub:GetWidth())
            if self.diceResultIcon then self.diceResultIcon:SetTexture(getChanceTexture("COIN")) end
        elseif self.lastChanceKind == "DICE" then
            local sides = tonumber(self.lastChanceSides) or 20
            self.diceResultTitle:SetText(string.format("D%d RESULT", sides))
            self.diceResultValue:SetText(tostring(self.lastChanceResult or "-"))
            setBookText(self.diceResultSub, string.format("Rolled on a D%d. Use it for checks, encounters, loot calls, or any roll your party needs.", sides), self.diceResultSub:GetWidth())
            if self.diceResultIcon then self.diceResultIcon:SetTexture(getChanceTexture("DICE", sides)) end
        else
            self.diceResultTitle:SetText("LUCK OF THE DRAW")
            self.diceResultValue:SetText("READY")
            setBookText(self.diceResultSub, "Choose a die or toss a coin to see the latest result here.", self.diceResultSub:GetWidth())
            if self.diceResultIcon then self.diceResultIcon:SetTexture(getChanceTexture("DICE", 20)) end
        end
    end
end

function J:BuildQuestText()
    local lines = {"ACTIVE QUEST DOCUMENTS", ""}
    local max = MAX_JOURNAL_QUESTS or 25
    local count = 0
    if type(GetJournalQuestName) == "function" then
        for i=1,max do
            local name = trim(safe(GetJournalQuestName, "", i))
            if name ~= "" then
                count = count + 1
                local level = tonumber(safe(GetJournalQuestLevel, 0, i)) or 0
                local zone = trim(safe(GetJournalQuestLocationInfo, "", i))
                lines[#lines+1] = string.format("%02d. %s%s", count, name, level > 0 and string.format("  [Lv %d]", level) or "")
                if zone ~= "" then lines[#lines+1] = "     " .. zone end
            end
        end
    end
    if count == 0 then lines[#lines+1] = "No active quests were found in the character journal." end
    lines[#lines+1] = ""
    lines[#lines+1] = "For quests you have not started, use the Suite's QUESTS tab."
    return table.concat(lines, "\n")
end

function J:BuildAchievementText()
    local lines = {"ACHIEVEMENT DOCUMENTS", ""}
    local earned = tonumber(safe(GetEarnedAchievementPoints, 0)) or 0
    local total = tonumber(safe(GetTotalAchievementPoints, 0)) or 0
    if total > 0 then lines[#lines+1] = string.format("Achievement Points: %d / %d", earned, total) end
    local ids = { safe(GetRecentlyCompletedAchievements, nil, 12) }
    local found = 0
    for i=1,#ids do
        local id = tonumber(ids[i]) or 0
        if id > 0 and type(GetAchievementInfo) == "function" then
            local name, description, points, _, completed = safe(GetAchievementInfo, "", id)
            name = trim(name)
            if name ~= "" then
                found = found + 1
                lines[#lines+1] = string.format("%s %s%s", completed and "[DONE]" or "-", name, tonumber(points) and points > 0 and string.format("  (%d pts)", points) or "")
                if description and description ~= "" then lines[#lines+1] = "   " .. trim(description) end
            end
        end
    end
    if found == 0 then lines[#lines+1] = "Recent achievement details are not currently exposed by the client." end
    return table.concat(lines, "\n")
end

function J:BuildStatsText()
    local name = trim(safe(GetUnitName, "Player", "player"))
    local display = trim(safe(GetDisplayName, ""))
    local level = tonumber(safe(GetUnitLevel, 0, "player")) or 0
    local cp = tonumber(safe(GetUnitChampionPoints, 0, "player")) or 0
    local zone = trim(safe(GetUnitZone, "", "player"))
    local bagUsed, bagSize = safe(GetNumBagUsedSlots, 0, BAG_BACKPACK), safe(GetBagSize, 0, BAG_BACKPACK)
    local money = tonumber(safe(GetCurrentMoney, 0)) or 0
    local inv,maxInv,stam,maxStam,speed,maxSpeed = safe(GetRidingStats, 0)
    local lines = {
        "GAME STATISTICS", "",
        "Character: " .. name,
        display ~= "" and ("Account: " .. display) or nil,
        string.format("Level: %d   Champion Points: %d", level, cp),
        zone ~= "" and ("Zone: " .. zone) or nil,
        string.format("Backpack: %d / %d", tonumber(bagUsed) or 0, tonumber(bagSize) or 0),
        string.format("Gold: %d", money),
        "",
        "RIDING",
        string.format("Speed: %d / %d", tonumber(speed) or 0, tonumber(maxSpeed) or 0),
        string.format("Stamina: %d / %d", tonumber(stam) or 0, tonumber(maxStam) or 0),
        string.format("Carry Capacity: %d / %d", tonumber(inv) or 0, tonumber(maxInv) or 0),
    }
    local out = {}
    for _,v in ipairs(lines) do if v then out[#out+1] = v end end
    return table.concat(out, "\n")
end

local CODEX = {
    ALCHEMY = [[ALCHEMY QUICK CODEX

Core effect pairs commonly used when experimenting:
- Restore Health  /  Ravage Health
- Restore Magicka  /  Ravage Magicka
- Restore Stamina  /  Ravage Stamina
- Increase Weapon/Spell Power  /  Lower Weapon/Spell Power
- Weapon/Spell Critical  /  Reduce Critical
- Armor  /  Fracture/Breach style resistance reduction
- Speed  /  Hindrance
- Invisibility  /  Detection
- Unstoppable  /  Entrapment

The game only reveals reagent traits your character has learned. Use this page as a planning reference, then verify the exact trait set on the in-game Alchemy station before crafting.]],
    RUNES = [[ENCHANTING RUNE CODEX

ESSENCE RUNES  -  what the glyph affects
- Oko  -  Health
- Makko  -  Magicka
- Deni  -  Stamina
- Dekeipa  -  Frost
- Meip  -  Shock
- Rakeipa  -  Flame
- Okori  -  Power
- Taderi  -  Physical Harm
- Makderi  -  Spell Harm
- Haoko  -  Disease
- Kuoko  -  Poison
- Oru  -  Alchemical Resistance
- Indeko  -  Prismatic / tri-stat family

ASPECT RUNES  -  quality
- Ta  -  Normal
- Jejota  -  Fine
- Denata  -  Superior
- Rekuta  -  Epic
- Kuta  -  Legendary

POTENCY RUNES determine level and whether the essence is additive or subtractive. Always verify the resulting glyph preview before creation.]],
    MATERIALS = [[CRAFTING MATERIAL CODEX

BLACKSMITHING
Iron  ->  Steel  ->  Orichalcum  ->  Dwarven  ->  Ebony  ->  Calcinium  ->  Galatite  ->  Quicksilver  ->  Voidstone  ->  Rubedite

CLOTHING
Rawhide/Jute  ->  Hide/Flax  ->  Leather/Cotton  ->  Thick Leather/Spidersilk  ->  Fell Hide/Ebonthread  ->  Topgrain/Kresh Fiber  ->  Iron Hide/Ironthread  ->  Superb Hide/Silverweave  ->  Shadowhide/Void Cloth  ->  Rubedo Leather/Ancestor Silk

WOODWORKING
Maple  ->  Oak  ->  Beech  ->  Hickory  ->  Yew  ->  Birch  ->  Ash  ->  Mahogany  ->  Nightwood  ->  Ruby Ash

JEWELRY
Pewter  ->  Copper  ->  Silver  ->  Electrum  ->  Platinum

Research traits and improvement materials are character/account progression systems; the Codex is intended as a quick reference rather than a replacement for the crafting station's authoritative preview.]],
}

function J:SetCodexMode(mode)
    if CODEX[mode] then self.codexMode = mode self:RefreshCodex() end
end
function J:RefreshCodex()
    if self.codexBody then setBookText(self.codexBody, CODEX[self.codexMode or "ALCHEMY"] or "", self.codexBody:GetWidth()) end
    for mode,b in pairs(self.codexButtons or {}) do setButtonStyle(b, mode == (self.codexMode or "ALCHEMY"), self:GetTheme()) end
end

function J:RefreshDocumentPage()
    local page = self.pages and self.pages[self.activeTab]
    local body = page and page.body
    if not body then return end
    if self.activeTab == "ACHIEVEMENTS" then setBookText(body, self:BuildAchievementText(), body:GetWidth())
    elseif self.activeTab == "STATS" then setBookText(body, self:BuildStatsText(), body:GetWidth()) end
end

local function addViewStats(lines, stats)
    if type(stats) ~= "table" then return end
    for i=1,#stats do
        local row = stats[i]
        if row then lines[#lines+1] = string.format("%s: %s", tostring(row.label or ""), tostring(row.value or "")) end
    end
end

local function addViewItems(lines, header, items, limit)
    if type(items) ~= "table" or #items == 0 then return end
    lines[#lines+1] = ""
    if header and header ~= "" then lines[#lines+1] = tostring(header) end
    limit = math.min(#items, tonumber(limit) or 6)
    for i=1,limit do lines[#lines+1] = "- " .. tostring(items[i]) end
end

function J:CreateSuitePage(parent, name)
    local page = wm:CreateControl("EAS_Journal_Suite_"..name, parent, CT_CONTROL)
    page:SetAnchorFill(parent)
    local w, h = math.max(320, parent:GetWidth()), math.max(420, parent:GetHeight())
    local body = makeLabel("EAS_Journal_SuiteBody_"..name, page, "", 0, 0, w, h-72, "ZoFontGame")
    self.themeLabels[#self.themeLabels+1] = body
    page.body = body
    page.buttons = {}
    local gap = 5
    local bw = math.floor((w - gap*2) / 3)
    for i=1,6 do
        local row = i > 3 and 1 or 0
        local col = (i-1) % 3
        local b = makeButton("EAS_Journal_SuiteAction_"..name.."_"..i, page, "", col*(bw+gap), h-64 + row*31, bw, 27, function() self:RunSuiteAction(name, i) end)
        b:SetHidden(true)
        page.buttons[i] = b
    end
    return page
end

function J:SetSuiteButtons(tab, labels)
    local page = self.pages and self.pages[tab]
    if not page or not page.buttons then return end
    local theme = self:GetTheme()
    for i=1,#page.buttons do
        local b = page.buttons[i]
        local label = labels and labels[i] or nil
        if label and label ~= "" then
            b:SetText(label)
            b:SetHidden(false)
            setButtonStyle(b, false, theme)
        else
            b:SetHidden(true)
        end
    end
end

function J:CycleOrder(current, order)
    local idx = 1
    for i=1,#order do if order[i] == current then idx = i break end end
    idx = idx + 1
    if idx > #order then idx = 1 end
    return order[idx]
end

function J:RunSuiteAction(tab, action)
    if tab == "GEAR" and EPC.SetJournal then
        if action == 1 then EPC.SetJournal:SetFilter(self:CycleOrder(EPC.SetJournal.filter or "ALL", {"ALL","OVERLAND","DUNGEON","TRIAL"}))
        elseif action == 2 then EPC.SetJournal:PromptSearch()
        elseif action == 3 then EPC.SetJournal:ChangePage(-1)
        elseif action == 4 then EPC.SetJournal:ChangePage(1)
        elseif action == 5 then local v=EPC.SetJournal:BuildView(); local n=#(v.rows or {}); if n>0 then self.suiteRowIndex.GEAR=(self.suiteRowIndex.GEAR % n)+1 EPC.SetJournal:SelectRow(self.suiteRowIndex.GEAR) end
        elseif action == 6 then EPC.SetJournal:RouteSelected() end
    elseif tab == "QUESTS" and EPC.QuestFinder then
        if action == 1 then EPC.QuestFinder:SetFilter(self:CycleOrder(EPC.QuestFinder.filter or "NOT_STARTED", {"NOT_STARTED","ACTIVE","ALL"})) EPC:RefreshNow("codex-quest-filter")
        elseif action == 2 then EPC.QuestFinder:Scroll(-(EPC.QuestFinder.PAGE_SIZE or 8))
        elseif action == 3 then EPC.QuestFinder:Scroll(EPC.QuestFinder.PAGE_SIZE or 8)
        elseif action == 4 then local v=EPC.QuestFinder:BuildView(); local n=#(v.rows or {}); if n>0 then self.suiteRowIndex.QUESTS=(self.suiteRowIndex.QUESTS % n)+1 EPC.QuestFinder:SelectRow(self.suiteRowIndex.QUESTS) end
        elseif action == 5 then EPC.QuestFinder:RouteSelected() end
    elseif tab == "TRAVEL" and EPC.Travel then
        if action == 1 then EPC.Travel:SetMode(self:CycleOrder(EPC.Travel:GetMode(), EPC.Travel.modeOrder or {"SHRINES","FRIENDS","GUILD","GROUP"}))
        elseif action == 2 then EPC.Travel:ChangePage(-1, EPC.Travel.BOOK_PAGE_SIZE or 8)
        elseif action == 3 then EPC.Travel:ChangePage(1, EPC.Travel.BOOK_PAGE_SIZE or 8)
        elseif action == 4 then local ps=EPC.Travel.BOOK_PAGE_SIZE or 8; local v=EPC.Travel:BuildView(EPC.lastSnapshot or {}, ps); local n=#(v.rows or {}); if n>0 then self.suiteRowIndex.TRAVEL=(self.suiteRowIndex.TRAVEL % n)+1 EPC.Travel:SelectVisibleRow(self.suiteRowIndex.TRAVEL, ps) end
        elseif action == 5 then EPC.Travel:TravelSelected() end
    elseif tab == "ACTIVITY" and EPC.Activities then
        if action == 1 then EPC.Activities:SetGoal(self:CycleOrder(EPC.Activities:GetGoal(), {"BALANCED","XP","GOLD"}))
        elseif action == 2 then local v=EPC.Activities:BuildView(EPC.lastSnapshot or {}); local n=#(v.rows or {}); if n>0 then self.suiteRowIndex.ACTIVITY=(self.suiteRowIndex.ACTIVITY % n)+1 EPC.Activities:SelectVisibleRow(self.suiteRowIndex.ACTIVITY) end
        elseif action == 3 then EPC.Activities:ActivateSelected() end
    elseif tab == "TOOLS" and EPC.UtilitySuite then
        if action == 1 then EPC.UtilitySuite:SetMode(self:CycleOrder(EPC.UtilitySuite:GetMode(), {"OVERVIEW","INVENTORY","RESEARCH","COLLECTIONS","DAILIES"})) end
    elseif tab == "BUILD" or tab == "SKILLS" or tab == "COMBAT" then
        EPC:RefreshNow("codex-refresh")
    end
    if self.window and not self.window:IsHidden() then self:RefreshSuitePage(tab) end
end

function J:BuildSuiteText(tab)
    local model = EPC.lastModel
    if not model and EPC.RefreshNow then EPC:RefreshNow("codex-open") model = EPC.lastModel end
    local lines = {}
    local base = model and model.tabs and model.tabs[tab] or nil
    if base then
        if base.title and base.title ~= "" then lines[#lines+1] = tostring(base.title) end
        if base.description and base.description ~= "" then lines[#lines+1] = "" lines[#lines+1] = tostring(base.description) end
        if base.stats then lines[#lines+1] = "" addViewStats(lines, base.stats) end
        addViewItems(lines, base.listHeader, base.items, 6)
    end

    if tab == "GEAR" and EPC.SetJournal then
        local v = EPC.SetJournal:BuildView()
        lines[#lines+1] = ""
        lines[#lines+1] = string.format("SET JOURNAL  -  %s  -  page %d/%d", tostring(v.filter or "ALL"), tonumber(v.page) or 1, tonumber(v.pageCount) or 1)
        for i,row in ipairs(v.rows or {}) do
            local mark = v.selected and v.selected.setId == row.setId and ">" or "-"
            lines[#lines+1] = string.format("%s %s  [%d/%d]", mark, tostring(row.name or "Set"), tonumber(row.unlocked) or 0, tonumber(row.total) or 0)
            lines[#lines+1] = "   " .. tostring(row.sourceText or row.kindText or "")
        end
        if v.hint then lines[#lines+1] = "" lines[#lines+1] = tostring(v.hint) end
    elseif tab == "QUESTS" and EPC.QuestFinder then
        local v = EPC.QuestFinder:BuildView()
        lines[#lines+1] = string.format("%s  -  %d matches  -  %s", tostring(v.filter or "NOT_STARTED"), tonumber(v.total) or 0, tostring(v.scanProgress or ""))
        lines[#lines+1] = ""
        for _,row in ipairs(v.rows or {}) do
            local mark = v.selected and v.selected.key == row.key and ">" or "-"
            lines[#lines+1] = string.format("%s %s", mark, tostring(row.name or "Quest"))
            lines[#lines+1] = string.format("   %s  -  %s", tostring(row.zone or "Unknown zone"), tostring(row.status or row.type or "Quest"))
        end
        if v.selected then lines[#lines+1] = "" lines[#lines+1] = tostring(v.selected.starter or v.selected.access or "") end
    elseif tab == "TRAVEL" and EPC.Travel then
        local v = EPC.Travel:BuildView(EPC.lastSnapshot or {}, EPC.Travel.BOOK_PAGE_SIZE or 8)
        lines[#lines+1] = tostring(v.title or "Travel")
        lines[#lines+1] = tostring(v.description or "")
        lines[#lines+1] = ""
        lines[#lines+1] = string.format("%s  -  page %d/%d", tostring(v.modeLabel or v.mode or "Travel"), tonumber(v.page) or 1, tonumber(v.pageCount) or 1)
        for _,row in ipairs(v.rows or {}) do
            local mark = v.selected and v.selected.key == row.key and ">" or "-"
            lines[#lines+1] = string.format("%s %s", mark, tostring(row.name or "Destination"))
            lines[#lines+1] = string.format("   %s  -  %s", tostring(row.zoneName or "Unknown zone"), tostring(row.statusText or row.costText or ""))
        end
        if v.hint then lines[#lines+1] = "" lines[#lines+1] = tostring(v.hint) end
    elseif tab == "ACTIVITY" and EPC.Activities then
        local v = EPC.Activities:BuildView(EPC.lastSnapshot or {})
        lines[#lines+1] = tostring(v.title or "Activities")
        lines[#lines+1] = tostring(v.description or "")
        lines[#lines+1] = ""
        addViewStats(lines, v.stats)
        lines[#lines+1] = ""
        for _,row in ipairs(v.rows or {}) do
            local mark = v.selected and v.selected.key == row.key and ">" or "-"
            lines[#lines+1] = mark .. " " .. tostring(row.name or row.displayText or "Activity")
            if row.detailText then lines[#lines+1] = "   " .. tostring(row.detailText) end
        end
        if v.hint then lines[#lines+1] = "" lines[#lines+1] = tostring(v.hint) end
    elseif tab == "TOOLS" and EPC.UtilitySuite then
        local v = EPC.UtilitySuite:BuildView(EPC.lastSnapshot or {})
        lines[#lines+1] = tostring(v.title or "Utilities")
        lines[#lines+1] = tostring(v.description or "")
        lines[#lines+1] = ""
        addViewStats(lines, v.stats)
        addViewItems(lines, v.listHeader or ("MODE: " .. tostring(v.modeLabel or v.mode or "OVERVIEW")), v.rows or v.items, 7)
        if v.hint then lines[#lines+1] = "" lines[#lines+1] = tostring(v.hint) end
    end

    if #lines == 0 then lines = {"This Codex section is waiting for character data.", "", "Use REFRESH or reopen the Codex after the character has loaded."} end
    return table.concat(lines, "\n")
end

function J:RefreshSuitePage(tab)
    tab = tab or self.activeTab
    if not SUITE_TABS[tab] then return end
    local page = self.pages and self.pages[tab]
    if not page or not page.body then return end
    setBookText(page.body, self:BuildSuiteText(tab), page.body:GetWidth())
    if tab == "GEAR" then self:SetSuiteButtons(tab, {"FILTER","SEARCH","< PAGE","PAGE >","SELECT","ROUTE"})
    elseif tab == "QUESTS" then self:SetSuiteButtons(tab, {"FILTER","< PAGE","PAGE >","SELECT","ROUTE"})
    elseif tab == "TRAVEL" then self:SetSuiteButtons(tab, {"MODE","< PAGE","PAGE >","SELECT","TRAVEL"})
    elseif tab == "ACTIVITY" then self:SetSuiteButtons(tab, {"GOAL","SELECT","ROUTE"})
    elseif tab == "TOOLS" then self:SetSuiteButtons(tab, {"MODE"})
    else self:SetSuiteButtons(tab, {"REFRESH"}) end
end

function J:PlayPageTurn()
    if not self.flipPage then return end
    local t = self:GetTheme()
    self.flipPage:SetCenterColor(unpack(t.page2 or t.page or t.panel))
    self.flipPage:SetEdgeColor(unpack(t.edge))
    self.flipPage:SetHidden(false)
    self.flipPage:SetAlpha(1)
    self.flipPage:SetScale(1)
    self.flipPage:ClearAnchors()
    self.flipPage:SetAnchor(TOPLEFT, self.rightContent or self.window, TOPLEFT, 0, self.rightContent and 88 or 238)

    if not ANIMATION_MANAGER or not ANIMATION_MANAGER.CreateTimeline or not ANIMATION_SCALE or not ANIMATION_ALPHA then
        self.flipPage:SetHidden(true)
        return
    end
    if self.pageTurnTimeline and self.pageTurnTimeline.IsPlaying and self.pageTurnTimeline:IsPlaying() then self.pageTurnTimeline:Stop() end
    local tl = ANIMATION_MANAGER:CreateTimeline()
    local shrink = tl:InsertAnimation(ANIMATION_SCALE, self.flipPage, 0)
    shrink:SetScaleValues(1.0, 0.08)
    shrink:SetDuration(150)
    local fade1 = tl:InsertAnimation(ANIMATION_ALPHA, self.flipPage, 0)
    fade1:SetAlphaValues(1.0, 0.72)
    fade1:SetDuration(150)
    tl:InsertCallback(function()
        self.flipPage:ClearAnchors()
        self.flipPage:SetAnchor(TOPLEFT, self.leftNavigation or self.window, TOPLEFT, 0, self.leftNavigation and 88 or 238)
    end, 155)
    local expand = tl:InsertAnimation(ANIMATION_SCALE, self.flipPage, 160)
    expand:SetScaleValues(0.08, 1.0)
    expand:SetDuration(150)
    local fade2 = tl:InsertAnimation(ANIMATION_ALPHA, self.flipPage, 160)
    fade2:SetAlphaValues(0.72, 0.0)
    fade2:SetDuration(150)
    tl:InsertCallback(function()
        self.flipPage:SetHidden(true)
        self.flipPage:SetAlpha(1)
        self.flipPage:SetScale(1)
    end, 315)
    self.pageTurnTimeline = tl
    if self.turnSound and type(PlaySound) == "function" then pcall(PlaySound, self.turnSound) end
    tl:PlayFromStart()
end

function J:TurnPage(delta)
    local current = 1
    for i=1,#TABS do if TABS[i] == self.activeTab then current = i break end end
    local nextIndex = current + (tonumber(delta) or 1)
    if nextIndex < 1 then nextIndex = #TABS end
    if nextIndex > #TABS then nextIndex = 1 end
    self:SetTab(TABS[nextIndex])
end

function J:SetTab(tab)
    self:SaveCurrentEntry()
    local changed = self.activeTab ~= nil and self.activeTab ~= tab
    self.activeTab = tab
    self:EnsureSaved().activeTab = tab
    if self.pageNumber then
        local idx = 1
        for i=1,#TABS do if TABS[i] == tab then idx = i break end end
        self.pageNumber:SetText(string.format("Page %s", TAB_PAGE_NUMBERS[tab] or tostring(idx)))
    end
    if self.currentSummary or self.sectionSubtitle then
        local sub = ({
            NOTES = "Personal field reports, notes, and records",
            PINS = "Named places to revisit for farming, XP, routes, and exploration",
            BUILD = "Character build guidance and next priorities",
            GEAR = "Gear audit, Item Set Collection, and source routing",
            SKILLS = "Skill points, weapon bars, and Champion priorities",
            COMBAT = "Role-aware combat analysis and recent fight data",
            ACTIVITY = "XP, gold, quest, and activity planning",
            QUESTS = "Find active or not-yet-started quests and route toward them",
            TRAVEL = "Wayshrines, friends, guild, and group travel",
            TOOLS = "Inventory, research, collections, and daily utilities",
            ACHIEVEMENTS = "Achievement notes and completed milestones",
            STATS = "Character records, riding, inventory, and wealth",
            CODEX = "Crafting codex and reference material",
            DICE = "Roleplay dice and coin tosses",
        })[tab] or ""
        if self.currentSummary then setBookText(self.currentSummary, sub, self.currentSummary:GetWidth()) end
        if self.sectionSubtitle then setBookText(self.sectionSubtitle, sub, self.sectionSubtitle:GetWidth()) end
    end
    if self.modeButton then self.modeButton:SetText(self.readMode and "EDIT" or "READ") end
    if self.sectionTitle then self.sectionTitle:SetText(TAB_TITLES[tab] or tab) end
    if self.currentHeader then self.currentHeader:SetText(string.format("CURRENT CHAPTER  -  %s", TAB_LABELS[tab] or tab)) end
    local notesTab = tab == "NOTES"
    if self.newButton then self.newButton:SetHidden(not notesTab) end
    if self.saveButton then self.saveButton:SetHidden(not notesTab) end
    if self.deleteButton then self.deleteButton:SetHidden(not notesTab) end
    if self.modeButton then self.modeButton:SetHidden(not notesTab) end
    if self.themeButton then self.themeButton:SetHidden(false) end
    if self.closeButton then self.closeButton:SetHidden(false) end
    local showCategories = notesTab
    if self.categoryHeader then self.categoryHeader:SetHidden(not showCategories) end
    for _, b in pairs(self.categoryButtons or {}) do b:SetHidden(not showCategories) end
    if self.deleteButton and self.deleteButton.SetEnabled then self.deleteButton:SetEnabled(showCategories and self.currentEntryId ~= nil) end
    for name,page in pairs(self.pages or {}) do page:SetHidden(name ~= tab) end
    if SUITE_TABS[tab] then
        if EPC.saved then EPC.saved.activeTab = (tab == "TRAVEL" and "MAP" or tab) end
        if EPC.RefreshNow then EPC:RefreshNow("codex-" .. string.lower(tab)) end
        self:RefreshSuitePage(tab)
    elseif tab == "NOTES" then self:RefreshNotes()
    elseif tab == "PINS" then self:RefreshPinsPage()
    elseif tab == "DICE" then self:RefreshDice()
    elseif tab == "CODEX" then self:RefreshCodex()
    else self:RefreshDocumentPage() end
    self:ApplyTheme()
    if changed and self.window and not self.window:IsHidden() then self:PlayPageTurn() end
end

function J:CreateNotesPage(parent)
    local page = wm:CreateControl("EAS_Journal_NotesPage", parent, CT_CONTROL)
    page:SetAnchorFill(parent)
    self.notePage = page
    local w, h = math.max(320, parent:GetWidth()), math.max(420, parent:GetHeight())
    local listW = math.floor(w * 0.34)
    local editorX = listW + 16
    local editorW = w - editorX

    self.noteCount = makeLabel("EAS_Journal_NoteCount", page, "", 0, 0, listW, 22, "ZoFontGameSmall")
    self.themeLabels[#self.themeLabels+1] = self.noteCount
    self.noteRows = {}
    for i=1,10 do
        local b = makeButton("EAS_Journal_NoteRow"..i, page, "", 0, 28+(i-1)*32, listW, 28, function(control)
            if control.entryId then self:SelectEntry(control.entryId) end
        end)
        b:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        self.noteRows[i] = b
    end

    local divider = wm:CreateControl("EAS_Journal_NotesDivider", page, CT_BACKDROP)
    divider:SetAnchor(TOPLEFT, page, TOPLEFT, listW + 7, 8)
    divider:SetDimensions(1, h - 24)
    divider:SetCenterColor(0.26,0.17,0.08,0.25)
    divider:SetEdgeColor(0,0,0,0)

    self.noteTitleEdit = self:CreateEditBox("EAS_Journal_TitleEdit", page, editorX, 6, editorW, 34, false)
    self.noteTitleEdit:SetFont("ZoFontGameBold")
    local bodyH = math.max(280, h - 98)
    self.noteBodyEdit = self:CreateEditBox("EAS_Journal_BodyEdit", page, editorX, 52, editorW, bodyH, true)
    self.noteBodyEdit:SetFont("ZoFontGame")
    local autosave = makeLabel("EAS_Journal_Autosave", page, "Auto-saved when changing pages or closing the Tamriel Codex.", editorX, 58 + bodyH, editorW, 34, "ZoFontGameSmall")
    self.themeLabels[#self.themeLabels+1] = autosave
    return page
end

function J:CreatePinsPage(parent)
    local page = wm:CreateControl("EAS_Journal_PinsPage", parent, CT_CONTROL)
    page:SetAnchorFill(parent)
    local w, h = math.max(320, parent:GetWidth()), math.max(420, parent:GetHeight())

    local nameLabel = makeLabel("EAS_Journal_CheckpointNameLabel", page, "CHECKPOINT NAME", 0, 0, w, 20, "ZoFontGameSmall")
    self.themeLabels[#self.themeLabels+1] = nameLabel
    self.checkpointNameEdit = wm:CreateControl("EAS_Journal_CheckpointNameEdit", page, CT_EDITBOX)
    self.checkpointNameEdit:SetAnchor(TOPLEFT, page, TOPLEFT, 0, 22)
    self.checkpointNameEdit:SetDimensions(w, 32)
    self.checkpointNameEdit:SetFont("ZoFontGame")
    if self.checkpointNameEdit.SetMaxInputChars then self.checkpointNameEdit:SetMaxInputChars(80) end
    self.checkpointNameEdit:SetColor(0.15,0.09,0.04,1)

    self.pinRows = {}
    for i=1,7 do
        local b = makeButton("EAS_Journal_PinRow"..i, page, "", 0, 64+(i-1)*34, w, 30, function(control)
            self.selectedPinId = control.pinId
            local selected = self:GetPinById(control.pinId)
            if selected and self.checkpointNameEdit then self.checkpointNameEdit:SetText(selected.name or "") end
            self:RefreshPinsPage()
        end)
        b:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        self.pinRows[i] = b
    end

    self.checkpointPrev = makeButton("EAS_Journal_CheckpointPrev", page, "< PREV", 0, 306, 86, 26, function() self:ChangeCheckpointPage(-1) end)
    self.checkpointPageLabel = makeLabel("EAS_Journal_CheckpointPageLabel", page, "", 94, 308, w-188, 22, "ZoFontGameSmall")
    self.checkpointPageLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.themeLabels[#self.themeLabels+1] = self.checkpointPageLabel
    self.checkpointNext = makeButton("EAS_Journal_CheckpointNext", page, "NEXT >", w-86, 306, 86, 26, function() self:ChangeCheckpointPage(1) end)

    self.pinInfo = makeLabel("EAS_Journal_PinInfo", page, "", 0, 340, w, math.max(82, h-438), "ZoFontGame")
    self.themeLabels[#self.themeLabels+1] = self.pinInfo

    local half = math.floor((w - 12) / 2)
    self.pinSave = makeButton("EAS_Journal_PinSave", page, "SAVE / UPDATE HERE", 0, h-78, half, 32, function()
        self:SaveCurrentLocation(self.checkpointNameEdit and self.checkpointNameEdit:GetText() or "")
    end)
    self.pinWaypoint = makeButton("EAS_Journal_PinWaypoint", page, "WAYPOINT", half+12, h-78, half, 32, function() self:SetPinWaypoint() end)
    self.pinDelete = makeButton("EAS_Journal_PinDelete", page, "DELETE CHECKPOINT", math.floor((w-190)/2), h-40, 190, 28, function() self:DeletePin() end)
    return page
end

function J:CreateDicePage(parent)
    local page = wm:CreateControl("EAS_Journal_DicePage", parent, CT_CONTROL)
    page:SetAnchorFill(parent)
    local w, h = math.max(320, parent:GetWidth()), math.max(420, parent:GetHeight())
    local title = makeLabel("EAS_Journal_DiceTitle", page, "ROLEPLAY TOOLS", 0, 0, w, 34, "ZoFontWinH2")
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.themeLabels[#self.themeLabels+1] = title
    local dice = {4,6,8,10,12,20,100}
    local cell = math.floor(w / 4)
    for i,sides in ipairs(dice) do
        local col = (i-1) % 4
        local row = zo_floor((i-1) / 4)
        makeButton("EAS_Journal_D"..sides, page, "D"..sides, col*cell+4, 56+row*46, cell-8, 34, function() self:Roll(sides) end)
    end
    makeButton("EAS_Journal_Coin", page, "TOSS COIN", math.floor(w*0.25), 154, math.floor(w*0.5), 36, function() self:TossCoin() end)
    self.diceOutput = makeLabel("EAS_Journal_DiceOutput", page, "Choose a die or toss a coin.", 12, 216, w-24, h-228, "ZoFontGame")
    self.diceOutput:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.themeLabels[#self.themeLabels+1] = self.diceOutput
    return page
end

function J:CreateDocumentPage(parent, name)
    local page = wm:CreateControl("EAS_Journal_"..name.."Page", parent, CT_CONTROL)
    page:SetAnchorFill(parent)
    local w, h = math.max(320, parent:GetWidth()), math.max(420, parent:GetHeight())
    local body = makeLabel("EAS_Journal_"..name.."Body", page, "", 0, 0, w, h, "ZoFontGame")
    self.themeLabels[#self.themeLabels+1] = body
    page.body = body
    return page
end

function J:CreateCodexPage(parent)
    local page = wm:CreateControl("EAS_Journal_CodexPage", parent, CT_CONTROL)
    page:SetAnchorFill(parent)
    local w, h = math.max(320, parent:GetWidth()), math.max(420, parent:GetHeight())
    self.codexButtons = {}
    local modes = {"ALCHEMY","RUNES","MATERIALS"}
    local bw = math.floor((w - 12) / 3)
    for i,mode in ipairs(modes) do
        self.codexButtons[mode] = makeButton("EAS_Journal_Codex"..mode, page, mode, (i-1)*(bw+6), 0, bw, 32, function() self:SetCodexMode(mode) end)
    end
    self.codexBody = makeLabel("EAS_Journal_CodexBody", page, "", 0, 48, w, h-48, "ZoFontGame")
    self.themeLabels[#self.themeLabels+1] = self.codexBody
    return page
end

-- Locate an action by name and compare a raw OnKeyDown event with any of
-- that action's keyboard binding slots. This deliberately bypasses active
-- action-layer routing while the Codex is open.
function J:RawKeyMatchesAction(actionName, key, ctrl, alt, shift, command)
    if type(GetNumActionLayers) ~= "function" or type(GetActionLayerInfo) ~= "function"
        or type(GetActionLayerCategoryInfo) ~= "function" or type(GetActionInfo) ~= "function"
        or type(GetActionBindingInfo) ~= "function" then
        return false
    end

    local function modifierPresent(modifierKey, m1, m2, m3, m4)
        if type(ZO_Keybindings_DoesKeyMatchAnyModifiers) == "function" then
            return ZO_Keybindings_DoesKeyMatchAnyModifiers(modifierKey, m1, m2, m3, m4) == true
        end
        return m1 == modifierKey or m2 == modifierKey or m3 == modifierKey or m4 == modifierKey
    end

    local numLayers = GetNumActionLayers() or 0
    for layerIndex = 1, numLayers do
        local _, numCategories = GetActionLayerInfo(layerIndex)
        for categoryIndex = 1, (numCategories or 0) do
            local _, numActions = GetActionLayerCategoryInfo(layerIndex, categoryIndex)
            for actionIndex = 1, (numActions or 0) do
                local name = GetActionInfo(layerIndex, categoryIndex, actionIndex)
                if name == actionName then
                    -- Keyboard actions normally expose two binding slots. Check a few
                    -- slots defensively; invalid/unbound slots simply do not match.
                    for bindingIndex = 1, 4 do
                        local boundKey, m1, m2, m3, m4 = GetActionBindingInfo(layerIndex, categoryIndex, actionIndex, bindingIndex)
                        if boundKey and boundKey ~= KEY_INVALID and boundKey == key then
                            local wantCtrl = modifierPresent(KEY_CTRL, m1, m2, m3, m4)
                            local wantAlt = modifierPresent(KEY_ALT, m1, m2, m3, m4)
                            local wantShift = modifierPresent(KEY_SHIFT, m1, m2, m3, m4)
                            local wantCommand = KEY_COMMAND and modifierPresent(KEY_COMMAND, m1, m2, m3, m4) or false
                            if (ctrl == true) == wantCtrl and (alt == true) == wantAlt
                                and (shift == true) == wantShift and (command == true) == wantCommand then
                                return true
                            end
                        end
                    end
                    return false
                end
            end
        end
    end
    return false
end

function J:Create()
    local window = wm:CreateTopLevelWindow("EAS_CustomJournal")
    self.window = window
    window:SetDimensions(1024, 1024)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, -8)
    window:SetClampedToScreen(true)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetHidden(true)
    window:SetDrawLayer(DL_OVERLAY)
    window:SetDrawTier(DT_HIGH)

    -- v5: Capture the Codex toggle key directly while this top-level window
    -- has UI focus. Action-layer dispatch can be suppressed while camera UI mode
    -- is active, so compare the raw key event against the user's saved binding.
    if window.SetKeyboardEnabled then
        window:SetKeyboardEnabled(true)
    end
    window:SetHandler("OnKeyDown", function(_, key, ctrl, alt, shift, command)
        if self.window:IsHidden() then return end
        if self:RawKeyMatchesAction("ESO_PROGRESSION_COACH_TOGGLE", key, ctrl, alt, shift, command) then
            self:Hide()
        end
    end)

    local rootHeight = tonumber(GuiRoot and GuiRoot.GetHeight and GuiRoot:GetHeight()) or 1080
    if rootHeight < 1060 and window.SetScale then
        window:SetScale(math.max(0.72, (rootHeight - 28) / 1024))
    end

    local nativeBook = getNativeLoreBookMedium()
    self.nativeBook = nativeBook

    local bookTexture = wm:CreateControl("EAS_CustomJournal_NativeLoreBook", window, CT_TEXTURE)
    bookTexture:SetAnchorFill(window)
    if nativeBook then bookTexture:SetTexture(nativeBook.bg) end
    bookTexture:SetTextureCoords(0,1,0,1)
    bookTexture:SetMouseEnabled(false)
    self.bookTexture = bookTexture
    self.openSound = nativeBook and nativeBook.openSound or nil
    self.closeSound = nativeBook and nativeBook.closeSound or nil
    self.turnSound = nativeBook and nativeBook.turnPageSound or nil

    -- Fallback paper only appears if the client cannot provide the native Lore Reader medium.
    local bg = wm:CreateControl("EAS_CustomJournal_BG", window, CT_BACKDROP)
    bg:SetAnchor(TOPLEFT, window, TOPLEFT, 68, 108)
    bg:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -68, -108)
    bg:SetEdgeTexture(nil, 2, 2, 2)
    bg:SetCenterColor(0.95,0.89,0.76, nativeBook and 0 or 1)
    bg:SetEdgeColor(0.34,0.22,0.10, nativeBook and 0 or 0.85)
    self.bg = bg

    local pageW = tonumber(nativeBook and nativeBook.pageWidth) or 374
    local pageH = tonumber(nativeBook and nativeBook.pageHeight) or 620
    pageW = math.max(340, math.min(410, pageW))
    pageH = math.max(560, math.min(690, pageH))

    -- Left page: persistent chapter navigation, aligned to the native Lore Reader page geometry.
    local leftNav = wm:CreateControl("EAS_CustomJournal_LeftNavigation", window, CT_CONTROL)
    if nativeBook then leftNav:SetAnchor(LEFT, window, LEFT, tonumber(nativeBook.leftPageXOffset) or 0, tonumber(nativeBook.pageYOffset) or 0)
    else leftNav:SetAnchor(TOPLEFT, window, TOPLEFT, 126, 172) end
    leftNav:SetDimensions(pageW, pageH)
    self.leftNavigation = leftNav

    local title = makeLabel("EAS_CustomJournal_Title", leftNav, "TAMRIEL CODEX", 0, 0, pageW, 38, "ZoFontWinH2")
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    local subtitle = makeLabel("EAS_CustomJournal_Subtitle", leftNav, "INDEX OF CHAPTERS", 12, 36, pageW-24, 22, "ZoFontGameBold")
    subtitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    local indexIntro = makeLabel("EAS_CustomJournal_IndexIntro", leftNav, "Choose a chapter on the left page. The right page displays its contents.", 18, 60, pageW-36, 34, "ZoFontGameSmall")
    indexIntro:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    local rule = wm:CreateControl("EAS_CustomJournal_LeftRule", leftNav, CT_BACKDROP)
    rule:SetAnchor(TOPLEFT, leftNav, TOPLEFT, 28, 98)
    rule:SetDimensions(pageW-56, 1)
    rule:SetCenterColor(0.26,0.17,0.08,0.32)
    rule:SetEdgeColor(0,0,0,0)

    self.title, self.subtitle, self.indexIntro = title, subtitle, indexIntro
    self.panels, self.themeLabels, self.tabButtons, self.pages = {}, {title, subtitle, indexIntro}, {}, {}

    self.tabPageLabels = {}
    for i,tab in ipairs(TABS) do
        local label = TAB_LABELS[tab] or TAB_TITLES[tab] or tab
        local rowY = 114 + (i-1)*24
        local b = makeButton("EAS_CustomJournal_Tab"..tab, leftNav, label, 20, rowY, pageW-78, 20, function() self:SetTab(tab) end)
        b:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        self.tabButtons[tab] = b
        local num = makeLabel("EAS_CustomJournal_TabPage"..tab, leftNav, TAB_PAGE_NUMBERS[tab] or tostring(i), pageW-58, rowY, 34, 20, "ZoFontGameSmall")
        num:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        self.tabPageLabels[tab] = num
        self.themeLabels[#self.themeLabels+1] = num
    end

    local currentHeader = makeLabel("EAS_CustomJournal_CurrentHeader", leftNav, "CURRENT CHAPTER", 20, pageH-212, pageW-40, 20, "ZoFontGameBold")
    local currentSummary = makeLabel("EAS_CustomJournal_CurrentSummary", leftNav, "Select an entry from the index to begin reading.", 20, pageH-188, pageW-40, 74, "ZoFontGame")
    currentSummary:SetVerticalAlignment(TEXT_ALIGN_TOP)
    self.currentHeader, self.currentSummary = currentHeader, currentSummary
    self.themeLabels[#self.themeLabels+1] = currentHeader
    self.themeLabels[#self.themeLabels+1] = currentSummary

    local categoryHeader = makeLabel("EAS_CustomJournal_CategoryHeader", leftNav, "NOTE CATEGORIES", 20, pageH-106, pageW-40, 20, "ZoFontGameSmall")
    self.themeLabels[#self.themeLabels+1] = categoryHeader
    self.categoryHeader = categoryHeader
    self.categoryButtons = {}
    for i,cat in ipairs(CATEGORIES) do
        local col = (i-1) % 2
        local row = zo_floor((i-1) / 2)
        local catW = math.floor((pageW - 48) / 2)
        local b = makeButton("EAS_Journal_Cat"..i, leftNav, cat, 18 + col*(catW+12), pageH-82 + row*22, catW, 20, function() self:SetCategory(cat) end)
        b:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        self.categoryButtons[cat] = b
    end
    local leftPageNumber = makeLabel("EAS_CustomJournal_LeftPageNumber", leftNav, "INDEX", 0, pageH-24, pageW, 20, "ZoFontGameSmall")
    leftPageNumber:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.leftPageNumber = leftPageNumber
    self.themeLabels[#self.themeLabels+1] = leftPageNumber

    -- Right page: book actions at the top, section content below.
    local rightPage = wm:CreateControl("EAS_CustomJournal_RightContent", window, CT_CONTROL)
    if nativeBook then rightPage:SetAnchor(RIGHT, window, RIGHT, tonumber(nativeBook.rightPageXOffset) or 0, tonumber(nativeBook.pageYOffset) or 0)
    else rightPage:SetAnchor(TOPLEFT, window, TOPLEFT, 550, 158) end
    rightPage:SetDimensions(pageW, pageH)
    self.rightContent = rightPage

    local gap = 4
    local actionW = math.floor((pageW - gap*5) / 6)
    local newB = makeButton("EAS_CustomJournal_New", rightPage, "NEW", 0, 0, actionW, 28, function()
        if self.activeTab ~= "NOTES" then self:SetTab("NOTES") end
        self:NewEntry()
    end)
    local saveB = makeButton("EAS_CustomJournal_Save", rightPage, "SAVE", actionW+gap, 0, actionW, 28, function() self:SaveCurrentEntry() end)
    local deleteB = makeButton("EAS_CustomJournal_Delete", rightPage, "DEL", (actionW+gap)*2, 0, actionW, 28, function()
        if self.activeTab == "NOTES" then self:DeleteEntry() end
    end)
    local mode = makeButton("EAS_CustomJournal_Mode", rightPage, "READ", (actionW+gap)*3, 0, actionW, 28, function()
        self.readMode = not self.readMode
        self:EnsureSaved().readMode = self.readMode
        self:SetEditorEnabled(not self.readMode)
        self:ApplyTheme()
    end)
    local theme = makeButton("EAS_CustomJournal_Theme", rightPage, "THEME", (actionW+gap)*4, 0, actionW, 28, function() self:CycleTheme() end)
    local close = makeButton("EAS_CustomJournal_Close", rightPage, "CLOSE", (actionW+gap)*5, 0, actionW, 28, function() self:Hide() end)
    self.newButton, self.saveButton, self.deleteButton = newB, saveB, deleteB
    self.modeButton, self.themeButton, self.closeButton = mode, theme, close
    self.topButtons = {newB, saveB, deleteB, mode, theme, close}

    local sectionTitle = makeLabel("EAS_CustomJournal_RightTitle", rightPage, "TAMRIEL CODEX", 0, 40, pageW, 30, "ZoFontWinH2")
    sectionTitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    local sectionSubtitle = makeLabel("EAS_CustomJournal_RightSubtitle", rightPage, "", 12, 68, pageW-24, 32, "ZoFontGame")
    sectionSubtitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    local rightRule = wm:CreateControl("EAS_CustomJournal_RightRule", rightPage, CT_BACKDROP)
    rightRule:SetAnchor(TOPLEFT, rightPage, TOPLEFT, 0, 104)
    rightRule:SetDimensions(pageW, 1)
    rightRule:SetCenterColor(0.26,0.17,0.08,0.34)
    rightRule:SetEdgeColor(0,0,0,0)
    self.sectionTitle = sectionTitle
    self.sectionSubtitle = sectionSubtitle
    self.themeLabels[#self.themeLabels+1] = sectionTitle
    self.themeLabels[#self.themeLabels+1] = sectionSubtitle

    local content = wm:CreateControl("EAS_CustomJournal_Content", rightPage, CT_CONTROL)
    content:SetAnchor(TOPLEFT, rightPage, TOPLEFT, 0, 118)
    content:SetDimensions(pageW, pageH-152)
    self.content = content

    self.pages.NOTES = self:CreateNotesPage(content)
    self.pages.PINS = self:CreatePinsPage(content)
    self.pages.BUILD = self:CreateSuitePage(content, "BUILD")
    self.pages.GEAR = self:CreateSuitePage(content, "GEAR")
    self.pages.SKILLS = self:CreateSuitePage(content, "SKILLS")
    self.pages.COMBAT = self:CreateSuitePage(content, "COMBAT")
    self.pages.ACTIVITY = self:CreateSuitePage(content, "ACTIVITY")
    self.pages.QUESTS = self:CreateSuitePage(content, "QUESTS")
    self.pages.TRAVEL = self:CreateSuitePage(content, "TRAVEL")
    self.pages.TOOLS = self:CreateSuitePage(content, "TOOLS")
    self.pages.ACHIEVEMENTS = self:CreateDocumentPage(content, "ACHIEVEMENTS")
    self.pages.STATS = self:CreateDocumentPage(content, "STATS")
    self.pages.CODEX = self:CreateCodexPage(content)
    self.pages.DICE = self:CreateDicePage(content)
    self.suiteRowIndex = { GEAR=0, QUESTS=0, TRAVEL=0, ACTIVITY=0 }

    local prevPage = makeButton("EAS_CustomJournal_PrevPage", rightPage, "< PREV", 6, pageH-28, 88, 26, function() self:TurnPage(-1) end)
    local pageNumber = makeLabel("EAS_CustomJournal_PageNumber", rightPage, "Page 1 / 7", math.floor((pageW-150)/2), pageH-26, 150, 22, "ZoFontGameSmall")
    pageNumber:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    local nextPage = makeButton("EAS_CustomJournal_NextPage", rightPage, "NEXT >", pageW-94, pageH-28, 88, 26, function() self:TurnPage(1) end)
    self.prevPageButton, self.nextPageButton, self.pageNumber = prevPage, nextPage, pageNumber
    self.themeLabels[#self.themeLabels+1] = pageNumber

    -- A translucent parchment sheet provides the page-turn illusion without replacing the native book art.
    local flip = wm:CreateControl("EAS_CustomJournal_FlipPage", window, CT_BACKDROP)
    flip:SetDimensions(pageW, pageH-96)
    flip:SetAnchor(TOPLEFT, rightPage, TOPLEFT, 0, 88)
    flip:SetEdgeTexture(nil, 1, 1, 1)
    flip:SetDrawLayer(DL_OVERLAY)
    flip:SetHidden(true)
    self.flipPage = flip
    local flipMark = makeLabel("EAS_CustomJournal_FlipMark", flip, "TAMRIEL CODEX", 20, math.floor((pageH-130)/2), pageW-40, 30, "ZoFontWinH2")
    flipMark:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.themeLabels[#self.themeLabels+1] = flipMark

    window:SetHandler("OnMoveStop", function(control)
        local s = self:EnsureSaved()
        s.left, s.top = control:GetLeft(), control:GetTop()
    end)
    local s = self:EnsureSaved()
    if tonumber(s.left) and tonumber(s.top) and s.left >= 0 and s.top >= 0 then
        window:ClearAnchors()
        window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, s.left, s.top)
    end

    self.category = s.category or "ALL"
    self.activeTab = s.activeTab or "NOTES"
    self.readMode = s.readMode == true
    self.codexMode = "ALCHEMY"
    self:SetEditorEnabled(not self.readMode)
    self:SetTab(self.activeTab)
    self:RegisterMapPins()
end

function J:ActivateCodexActionLayer()
    if not self.window or self.window:IsHidden() then return end
    if type(PushActionLayerByName) ~= "function" then return end

    -- UI mode can rebuild the active action-layer stack. Push only after the
    -- Codex is actually visible, and refresh once on the next UI tick.
    if self.codexActionLayerPushed and type(RemoveActionLayerByName) == "function" then
        pcall(RemoveActionLayerByName, "ESOAdventurerSuiteCodexLayer")
        self.codexActionLayerPushed = false
    end

    local ok = pcall(PushActionLayerByName, "ESOAdventurerSuiteCodexLayer")
    self.codexActionLayerPushed = ok == true

    if type(zo_callLater) == "function" then
        zo_callLater(function()
            if not self.window or self.window:IsHidden() then return end
            if type(RemoveActionLayerByName) == "function" then
                pcall(RemoveActionLayerByName, "ESOAdventurerSuiteCodexLayer")
            end
            local pushed = pcall(PushActionLayerByName, "ESOAdventurerSuiteCodexLayer")
            self.codexActionLayerPushed = pushed == true
        end, 100)
    end
end

function J:Show()
    if not self.window then return end

    local already = safe(IsGameCameraUIModeActive, false) == true
    self.ownsUIMode = not already
    if not already then
        if type(SetGameCameraUIMode) == "function" then pcall(SetGameCameraUIMode, true)
        elseif SCENE_MANAGER and SCENE_MANAGER.SetInUIMode then pcall(SCENE_MANAGER.SetInUIMode, SCENE_MANAGER, true) end
    end
    self.window:SetHidden(false)
    self:ActivateCodexActionLayer()
    if self.openSound and type(PlaySound) == "function" then pcall(PlaySound, self.openSound) end
    if SUITE_TABS[self.activeTab] then self:RefreshSuitePage(self.activeTab) end
    self:RefreshDocumentPage()
    self:RefreshPinsPage()
    if EPC.RepairCostOverlay and EPC.RepairCostOverlay.Refresh then
        EPC.RepairCostOverlay:Refresh()
    end
end

function J:Hide()
    if not self.window then return end
    self:SaveCurrentEntry()
    self.window:SetHidden(true)

    if self.codexActionLayerPushed and type(RemoveActionLayerByName) == "function" then
        pcall(RemoveActionLayerByName, "ESOAdventurerSuiteCodexLayer")
        self.codexActionLayerPushed = false
    end
    if self.closeSound and type(PlaySound) == "function" then pcall(PlaySound, self.closeSound) end
    if self.ownsUIMode then
        if type(SetGameCameraUIMode) == "function" then pcall(SetGameCameraUIMode, false)
        elseif SCENE_MANAGER and SCENE_MANAGER.SetInUIMode then pcall(SCENE_MANAGER.SetInUIMode, SCENE_MANAGER, false) end
    end
    self.ownsUIMode = false
    if EPC.RepairCostOverlay and EPC.RepairCostOverlay.Refresh then
        EPC.RepairCostOverlay:Refresh()
    end
end

function J:Toggle()
    if not self.window then return end
    if self.window:IsHidden() then self:Show() else self:Hide() end
end

function J:Initialize()
    self:EnsureSaved()
    self:Create()
    EVENT_MANAGER:RegisterForEvent(EPC.name .. "_JournalMap", EVENT_PLAYER_ACTIVATED, function() self:RefreshMapPins() end)
end

--[[
    v0.19.0 two-page Codex override
    Keeps the existing data/model layer intact, but replaces the single-content-page
    book layout with a true two-page spread plus an index and edge chapter tabs.
]]

TABS = {"INDEX", "NOTES", "PINS", "BUILD", "GEAR", "SKILLS", "COMBAT", "ACTIVITY", "QUESTS", "TRAVEL", "TOOLS", "ACHIEVEMENTS", "STATS", "CODEX", "DICE"}
TAB_LABELS.INDEX = "Index"
TAB_TITLES.INDEX = "TAMRIEL CODEX"

local EAS_TAB_SHORT = {
    INDEX="INDEX", NOTES="NOTES", PINS="PINS", BUILD="BUILD", GEAR="GEAR", SKILLS="SKILLS", COMBAT="COMBAT",
    ACTIVITY="ACTIVITY", QUESTS="QUESTS", TRAVEL="TRAVEL", TOOLS="TOOLS", ACHIEVEMENTS="ACHV", STATS="STATS",
    CODEX="CRAFT", DICE="DICE",
}

local EAS_TAB_DESCRIPTIONS = {
    INDEX="A two-page index of your records, routes, guides, and discoveries.",
    NOTES="Personal notes and field reports. Browse on the left page and write on the right.",
    PINS="Named checkpoints for XP farms, material routes, bosses, fishing spots, and places worth revisiting.",
    BUILD="Character build guidance, priorities, and progression notes.",
    GEAR="Item-set collection progress, set sources, and route guidance.",
    SKILLS="Skill points, bars, progression, and Champion Point guidance.",
    COMBAT="Role-aware combat information and recent fight analysis.",
    ACTIVITY="Activities for XP, gold, quests, and progression goals.",
    QUESTS="Quest discovery and routing for active and not-yet-started quests.",
    TRAVEL="Wayshrines, group, guild, and social travel destinations.",
    TOOLS="Inventory, research, collections, daily tasks, and utility information.",
    ACHIEVEMENTS="Achievement records and recent milestones.",
    STATS="Character statistics, riding progress, inventory, and wealth.",
    CODEX="Crafting reference pages for alchemy, enchanting runes, and materials.",
    DICE="Roleplay dice and coin tosses.",
}

local function easSplitSpreadText(text)
    text = tostring(text or "")
    local lines = {}
    for line in string.gmatch(text .. "\n", "(.-)\n") do lines[#lines+1] = line end
    if #lines <= 1 then return text, "" end

    local weights, total = {}, 0
    for i,line in ipairs(lines) do
        local len = string.len(line)
        local w = math.max(1, math.ceil(math.max(1, len) / 44))
        if line == "" then w = 1 end
        weights[i] = w
        total = total + w
    end
    local target = math.max(1, math.floor((total + 1) / 2))
    local used, splitAt = 0, math.max(1, math.floor(#lines / 2))
    for i,w in ipairs(weights) do
        used = used + w
        if used >= target then splitAt = i break end
    end
    if splitAt >= #lines then splitAt = math.max(1, #lines - 1) end

    local left, right = {}, {}
    for i,line in ipairs(lines) do
        if i <= splitAt then left[#left+1] = line else right[#right+1] = line end
    end
    return table.concat(left, "\n"), table.concat(right, "\n")
end

local function easMakeRule(name, parent, y, width)
    local rule = wm:CreateControl(name, parent, CT_BACKDROP)
    rule:SetAnchor(TOPLEFT, parent, TOPLEFT, 14, y)
    rule:SetDimensions(math.max(1, width - 28), 1)
    rule:SetCenterColor(0.26,0.17,0.08,0.28)
    rule:SetEdgeColor(0,0,0,0)
    return rule
end

function J:CreateSpreadShell(name)
    local spread = wm:CreateControl("EAS_CodexSpread_"..name, self.window, CT_CONTROL)
    spread:SetAnchorFill(self.window)

    local left = wm:CreateControl("EAS_CodexSpread_"..name.."_Left", spread, CT_CONTROL)
    left:SetAnchor(TOPLEFT, self.leftPageHost, TOPLEFT, 0, 0)
    left:SetDimensions(self.pageW, self.pageH)

    local right = wm:CreateControl("EAS_CodexSpread_"..name.."_Right", spread, CT_CONTROL)
    right:SetAnchor(TOPLEFT, self.rightPageHost, TOPLEFT, 0, 0)
    right:SetDimensions(self.pageW, self.pageH)

    spread.left, spread.right = left, right
    spread.key = name
    return spread
end

function J:AddSpreadHeader(spread, leftTitle, rightTitle)
    local key = tostring(spread.key or leftTitle or "Spread"):gsub("%W", "")
    local lt = makeLabel("EAS_Codex_"..key.."_LeftTitle", spread.left, leftTitle or "", 8, 4, self.pageW-16, 34, "ZoFontWinH2")
    lt:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    local rt = makeLabel("EAS_Codex_"..key.."_RightTitle", spread.right, rightTitle or leftTitle or "", 8, 4, self.pageW-16, 34, "ZoFontWinH2")
    rt:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    easMakeRule("EAS_CodexRuleL_"..key, spread.left, 42, self.pageW)
    easMakeRule("EAS_CodexRuleR_"..key, spread.right, 42, self.pageW)
    self.themeLabels[#self.themeLabels+1] = lt
    self.themeLabels[#self.themeLabels+1] = rt
    spread.leftTitle, spread.rightTitle = lt, rt
end

function J:CreateIndexSpread()
    local spread = self:CreateSpreadShell("INDEX")
    self:AddSpreadHeader(spread, "TAMRIEL CODEX", "INDEX")

    local intro = makeLabel("EAS_CodexIndexIntro", spread.left,
        "A field codex for your adventures across Tamriel. Choose a chapter from this opening index, then use PREV / NEXT to move through the book.",
        20, 58, self.pageW-40, 74, "ZoFontGame")
    self.themeLabels[#self.themeLabels+1] = intro
    setBookText(intro, intro:GetText(), intro:GetWidth())

    local indexTabs = {}
    for _,tab in ipairs(TABS) do if tab ~= "INDEX" then indexTabs[#indexTabs+1] = tab end end
    local leftCount = math.ceil(#indexTabs / 2)
    for i,tab in ipairs(indexTabs) do
        local parent = i <= leftCount and spread.left or spread.right
        local localIndex = i <= leftCount and i or (i-leftCount)
        local y = (i <= leftCount and 150 or 70) + (localIndex-1)*48
        local pageIndex = 1
        for idx,name in ipairs(TABS) do if name == tab then pageIndex = idx break end end
        local firstPage = (pageIndex-1)*2 + 1
        local label = string.format("%-18s  %d", TAB_LABELS[tab] or tab, firstPage)
        local b = makeButton("EAS_CodexIndex_"..tab, parent, label, 24, y, self.pageW-48, 34, function() self:SetTab(tab) end)
        b:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        setButtonStyle(b, false, self:GetTheme())
    end

    local foot = makeLabel("EAS_CodexIndexFoot", spread.right,
        "This opening spread is the table of contents. Each chapter uses both pages. Use PREV / NEXT to turn spreads, or INDEX to return here.",
        24, self.pageH-126, self.pageW-48, 78, "ZoFontGameSmall")
    self.themeLabels[#self.themeLabels+1] = foot
    setBookText(foot, foot:GetText(), foot:GetWidth())
    return spread
end

function J:CreateNotesSpread()
    local spread = self:CreateSpreadShell("NOTES")
    self:AddSpreadHeader(spread, "NOTES & RECORDS", "CURRENT ENTRY")
    self.notePage = spread

    local catHeader = makeLabel("EAS_CodexNotesCategoryHeader", spread.left, "CATEGORIES", 12, 54, self.pageW-24, 20, "ZoFontGameSmall")
    self.themeLabels[#self.themeLabels+1] = catHeader
    self.categoryHeader = catHeader
    self.categoryButtons = {}
    local catW = math.floor((self.pageW - 38) / 2)
    for i,cat in ipairs(CATEGORIES) do
        local col = (i-1) % 2
        local row = math.floor((i-1) / 2)
        local b = makeButton("EAS_CodexNoteCat_"..i, spread.left, cat, 12 + col*(catW+10), 78 + row*24, catW, 21, function() self:SetCategory(cat) end)
        b:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        self.categoryButtons[cat] = b
    end

    self.noteCount = makeLabel("EAS_CodexNoteCount", spread.left, "", 12, 180, self.pageW-24, 20, "ZoFontGameSmall")
    self.themeLabels[#self.themeLabels+1] = self.noteCount
    self.noteRows = {}
    local rows = 11
    for i=1,rows do
        local b = makeButton("EAS_CodexNoteRow_"..i, spread.left, "", 12, 208+(i-1)*31, self.pageW-24, 27, function(control)
            if control.entryId then self:SelectEntry(control.entryId) end
        end)
        b:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        self.noteRows[i] = b
    end

    local gap = 6
    local bw = math.floor((self.pageW - 24 - gap*3) / 4)
    self.newButton = makeButton("EAS_CodexNoteNew", spread.right, "NEW", 12, 56, bw, 27, function() self:NewEntry() end)
    self.saveButton = makeButton("EAS_CodexNoteSave", spread.right, "SAVE", 12+bw+gap, 56, bw, 27, function() self:SaveCurrentEntry() end)
    self.deleteButton = makeButton("EAS_CodexNoteDelete", spread.right, "DEL", 12+(bw+gap)*2, 56, bw, 27, function() self:DeleteEntry() end)
    self.modeButton = makeButton("EAS_CodexNoteMode", spread.right, "EDIT", 12+(bw+gap)*3, 56, bw, 27, function()
        self.readMode = not self.readMode
        self:EnsureSaved().readMode = self.readMode
        self:SetEditorEnabled(not self.readMode)
        self:ApplyTheme()
    end)
    self.topButtons[#self.topButtons+1] = self.newButton
    self.topButtons[#self.topButtons+1] = self.saveButton
    self.topButtons[#self.topButtons+1] = self.deleteButton
    self.topButtons[#self.topButtons+1] = self.modeButton

    self.noteTitleEdit = self:CreateEditBox("EAS_CodexNoteTitle", spread.right, 12, 98, self.pageW-24, 36, false)
    self.noteTitleEdit:SetFont("ZoFontGameBold")
    self.noteBodyEdit = self:CreateEditBox("EAS_CodexNoteBody", spread.right, 12, 148, self.pageW-24, self.pageH-236, true)
    self.noteBodyEdit:SetFont("ZoFontGame")
    local autosave = makeLabel("EAS_CodexNoteAutosave", spread.right, "Auto-saves when changing entries, chapters, or closing the Codex.", 12, self.pageH-72, self.pageW-24, 42, "ZoFontGameSmall")
    self.themeLabels[#self.themeLabels+1] = autosave
    setBookText(autosave, autosave:GetText(), autosave:GetWidth())
    return spread
end

function J:CreatePinsSpread()
    local spread = self:CreateSpreadShell("PINS")
    self:AddSpreadHeader(spread, "CHECKPOINTS", "CHECKPOINT DETAILS")

    local nameLabel = makeLabel("EAS_CodexCheckpointNameLabel", spread.left, "CHECKPOINT NAME", 12, 56, self.pageW-24, 18, "ZoFontGameSmall")
    self.themeLabels[#self.themeLabels+1] = nameLabel
    self.checkpointNameEdit = wm:CreateControl("EAS_CodexCheckpointName", spread.left, CT_EDITBOX)
    self.checkpointNameEdit:SetAnchor(TOPLEFT, spread.left, TOPLEFT, 12, 78)
    self.checkpointNameEdit:SetDimensions(self.pageW-24, 32)
    self.checkpointNameEdit:SetFont("ZoFontGame")
    if self.checkpointNameEdit.SetMaxInputChars then self.checkpointNameEdit:SetMaxInputChars(80) end

    self.pinRows = {}
    for i=1,9 do
        local b = makeButton("EAS_CodexCheckpointRow_"..i, spread.left, "", 12, 122+(i-1)*36, self.pageW-24, 31, function(control)
            self.selectedPinId = control.pinId
            local selected = self:GetPinById(control.pinId)
            if selected and self.checkpointNameEdit then self.checkpointNameEdit:SetText(selected.name or "") end
            self:RefreshPinsPage()
        end)
        b:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        self.pinRows[i] = b
    end

    self.checkpointPrev = makeButton("EAS_CodexCheckpointPrev", spread.left, "< PREV", 12, self.pageH-62, 78, 26, function() self:ChangeCheckpointPage(-1) end)
    self.checkpointPageLabel = makeLabel("EAS_CodexCheckpointPage", spread.left, "", 96, self.pageH-60, self.pageW-192, 22, "ZoFontGameSmall")
    self.checkpointPageLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.themeLabels[#self.themeLabels+1] = self.checkpointPageLabel
    self.checkpointNext = makeButton("EAS_CodexCheckpointNext", spread.left, "NEXT >", self.pageW-90, self.pageH-62, 78, 26, function() self:ChangeCheckpointPage(1) end)

    self.pinInfo = makeLabel("EAS_CodexCheckpointInfo", spread.right, "", 18, 70, self.pageW-36, self.pageH-246, "ZoFontGame")
    self.themeLabels[#self.themeLabels+1] = self.pinInfo
    self.pinSave = makeButton("EAS_CodexCheckpointSave", spread.right, "SAVE / UPDATE HERE", 18, self.pageH-154, self.pageW-36, 32, function()
        self:SaveCurrentLocation(self.checkpointNameEdit and self.checkpointNameEdit:GetText() or "")
    end)
    self.pinWaypoint = makeButton("EAS_CodexCheckpointWaypoint", spread.right, "SET WAYPOINT", 18, self.pageH-112, self.pageW-36, 32, function() self:SetPinWaypoint() end)
    self.pinDelete = makeButton("EAS_CodexCheckpointDelete", spread.right, "DELETE CHECKPOINT", 18, self.pageH-70, self.pageW-36, 30, function() self:DeletePin() end)
    return spread
end

function J:CreateSuiteSpread(name)
    local spread = self:CreateSpreadShell(name)
    self:AddSpreadHeader(spread, TAB_TITLES[name] or name, "CONTINUED")
    local bodyH = self.pageH - 122
    local leftBody = makeLabel("EAS_CodexSuiteLeft_"..name, spread.left, "", 14, 58, self.pageW-28, bodyH, "ZoFontGame")
    local rightBody = makeLabel("EAS_CodexSuiteRight_"..name, spread.right, "", 14, 58, self.pageW-28, bodyH, "ZoFontGame")
    self.themeLabels[#self.themeLabels+1] = leftBody
    self.themeLabels[#self.themeLabels+1] = rightBody
    spread.leftBody, spread.rightBody = leftBody, rightBody
    spread.buttons = {}

    local gap = 5
    local bw = math.floor((self.pageW - 28 - gap*2) / 3)
    for i=1,6 do
        local parent = i <= 3 and spread.left or spread.right
        local col = (i-1) % 3
        local b = makeButton("EAS_CodexSuiteAction_"..name.."_"..i, parent, "", 14+col*(bw+gap), self.pageH-50, bw, 28, function() self:RunSuiteAction(name, i) end)
        b:SetHidden(true)
        spread.buttons[i] = b
    end
    return spread
end

function J:CreateDocumentSpread(name)
    local spread = self:CreateSpreadShell(name)
    self:AddSpreadHeader(spread, TAB_TITLES[name] or name, "CONTINUED")
    spread.leftBody = makeLabel("EAS_CodexDocLeft_"..name, spread.left, "", 14, 58, self.pageW-28, self.pageH-92, "ZoFontGame")
    spread.rightBody = makeLabel("EAS_CodexDocRight_"..name, spread.right, "", 14, 58, self.pageW-28, self.pageH-92, "ZoFontGame")
    self.themeLabels[#self.themeLabels+1] = spread.leftBody
    self.themeLabels[#self.themeLabels+1] = spread.rightBody
    return spread
end

function J:CreateCodexSpread()
    local spread = self:CreateSpreadShell("CODEX")
    self:AddSpreadHeader(spread, "CRAFTING CODEX", "REFERENCE")
    self.codexButtons = {}
    local modes = {"ALCHEMY","RUNES","MATERIALS"}
    local bw = math.floor((self.pageW - 36) / 3)
    for i,mode in ipairs(modes) do
        local b = makeButton("EAS_CodexCraftMode_"..mode, spread.left, mode, 12+(i-1)*(bw+6), 58, bw, 28, function() self:SetCodexMode(mode) end)
        self.codexButtons[mode] = b
    end
    self.codexLeftBody = makeLabel("EAS_CodexCraftLeftBody", spread.left, "", 14, 104, self.pageW-28, self.pageH-132, "ZoFontGame")
    self.codexRightBody = makeLabel("EAS_CodexCraftRightBody", spread.right, "", 14, 58, self.pageW-28, self.pageH-88, "ZoFontGame")
    self.themeLabels[#self.themeLabels+1] = self.codexLeftBody
    self.themeLabels[#self.themeLabels+1] = self.codexRightBody
    return spread
end

function J:CreateDiceSpread()
    local spread = self:CreateSpreadShell("DICE")
    self:AddSpreadHeader(spread, "ROLEPLAY DICE", "FORTUNE & HISTORY")

    local intro = makeLabel("EAS_CodexDiceIntro", spread.left,
        "Choose an ESO-themed die or flip a Septim-style coin for fast roleplay calls, random encounters, loot decisions, or tavern games.",
        18, 54, self.pageW-36, 54, "ZoFontGame")
    self.themeLabels[#self.themeLabels+1] = intro
    setBookText(intro, intro:GetText(), intro:GetWidth())

    self.iconButtons = self.iconButtons or {}
    local tileGap = 8
    local tileW = math.floor((self.pageW - 24 - tileGap * 2) / 3)
    local tileH = 90
    local dice = {4,6,8,10,12,20}
    for i, sides in ipairs(dice) do
        local col = (i - 1) % 3
        local row = math.floor((i - 1) / 3)
        local btn = makeIconButton(
            "EAS_CodexDice_"..sides,
            spread.left,
            getChanceTexture("DICE", sides),
            "D"..sides,
            12 + col * (tileW + tileGap),
            118 + row * (tileH + 10),
            tileW,
            tileH,
            function() self:Roll(sides) end
        )
        self.iconButtons[#self.iconButtons+1] = btn
    end

    local wideW = tileW * 2 + tileGap
    local d100 = makeIconButton("EAS_CodexDice_100", spread.left, getChanceTexture("DICE", 100), "D100", 12, 318, tileW, tileH, function() self:Roll(100) end)
    self.iconButtons[#self.iconButtons+1] = d100
    local coin = makeIconButton("EAS_CodexCoin", spread.left, getChanceTexture("COIN"), "COIN", 12 + tileW + tileGap, 318, wideW, tileH, function() self:TossCoin() end)
    self.iconButtons[#self.iconButtons+1] = coin

    local hint = makeLabel("EAS_CodexDiceHint", spread.left,
        "The latest result appears on the facing page, with your recent roll history preserved below it.",
        18, 420, self.pageW - 36, 48, "ZoFontGameSmall")
    self.themeLabels[#self.themeLabels+1] = hint
    setBookText(hint, hint:GetText(), hint:GetWidth())

    self.diceResultPanel = makePanel("EAS_CodexDiceResultPanel", spread.right, 22, 58, self.pageW - 44, 246)
    self.diceResultTitle = makeLabel("EAS_CodexDiceResultTitle", self.diceResultPanel, "LUCK OF THE DRAW", 12, 12, self.diceResultPanel:GetWidth() - 24, 28, "ZoFontWinH2")
    self.diceResultTitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.themeLabels[#self.themeLabels+1] = self.diceResultTitle

    self.diceResultIcon = wm:CreateControl("EAS_CodexDiceResultIcon", self.diceResultPanel, CT_TEXTURE)
    self.diceResultIcon:SetDimensions(78, 78)
    self.diceResultIcon:SetAnchor(TOP, self.diceResultPanel, TOP, 0, 44)
    self.diceResultIcon:SetTexture(getChanceTexture("DICE", 20))

    self.diceResultValue = makeLabel("EAS_CodexDiceResultValue", self.diceResultPanel, "READY", 12, 124, self.diceResultPanel:GetWidth() - 24, 38, "ZoFontWinH1")
    self.diceResultValue:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.diceResultValue:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.diceResultSub = makeLabel("EAS_CodexDiceResultSub", self.diceResultPanel, "Choose a die or toss a coin to see the latest result here.", 18, 164, self.diceResultPanel:GetWidth() - 36, 72, "ZoFontGame")
    self.diceResultSub:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.diceResultSub:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.themeLabels[#self.themeLabels+1] = self.diceResultSub
    setBookText(self.diceResultSub, self.diceResultSub:GetText(), self.diceResultSub:GetWidth())

    local historyTitle = makeLabel("EAS_CodexDiceHistoryTitle", spread.right, "ROLL HISTORY", 24, 320, self.pageW-48, 24, "ZoFontGameSmall")
    historyTitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.themeLabels[#self.themeLabels+1] = historyTitle

    self.diceHistoryOutput = makeLabel("EAS_CodexDiceHistoryOutput", spread.right, "Choose a die or toss a coin.", 24, 348, self.pageW-48, self.pageH-372, "ZoFontGame")
    self.themeLabels[#self.themeLabels+1] = self.diceHistoryOutput
    self.diceOutput = self.diceHistoryOutput
    self:RefreshDice()
    return spread
end

function J:RefreshCodex()
    local text = CODEX[self.codexMode or "ALCHEMY"] or ""
    local left, right = easSplitSpreadText(text)
    if self.codexLeftBody then setBookText(self.codexLeftBody, left, self.codexLeftBody:GetWidth()) end
    if self.codexRightBody then setBookText(self.codexRightBody, right, self.codexRightBody:GetWidth()) end
    for mode,b in pairs(self.codexButtons or {}) do setButtonStyle(b, mode == (self.codexMode or "ALCHEMY"), self:GetTheme()) end
end

function J:RefreshDocumentPage()
    local page = self.pages and self.pages[self.activeTab]
    if not page or not page.leftBody then return end
    local text = ""
    if self.activeTab == "ACHIEVEMENTS" then text = self:BuildAchievementText()
    elseif self.activeTab == "STATS" then text = self:BuildStatsText()
    else return end
    local left, right = easSplitSpreadText(text)
    setBookText(page.leftBody, left, page.leftBody:GetWidth())
    setBookText(page.rightBody, right, page.rightBody:GetWidth())
end

function J:RefreshSuitePage(tab)
    tab = tab or self.activeTab
    if not SUITE_TABS[tab] then return end
    local page = self.pages and self.pages[tab]
    if not page or not page.leftBody then return end
    local left, right = easSplitSpreadText(self:BuildSuiteText(tab))
    setBookText(page.leftBody, left, page.leftBody:GetWidth())
    setBookText(page.rightBody, right, page.rightBody:GetWidth())
    if tab == "GEAR" then self:SetSuiteButtons(tab, {"FILTER","SEARCH","< PAGE","PAGE >","SELECT","ROUTE"})
    elseif tab == "QUESTS" then self:SetSuiteButtons(tab, {"FILTER","< PAGE","PAGE >","SELECT","ROUTE"})
    elseif tab == "TRAVEL" then self:SetSuiteButtons(tab, {"MODE","< PAGE","PAGE >","SELECT","TRAVEL"})
    elseif tab == "ACTIVITY" then self:SetSuiteButtons(tab, {"GOAL","SELECT","ROUTE"})
    elseif tab == "TOOLS" then self:SetSuiteButtons(tab, {"MODE"})
    else self:SetSuiteButtons(tab, {"REFRESH"}) end
end

function J:SetTab(tab)
    if not tab or not TAB_TITLES[tab] then tab = "INDEX" end
    self:SaveCurrentEntry()
    local changed = self.activeTab ~= nil and self.activeTab ~= tab
    self.activeTab = tab
    self:EnsureSaved().activeTab = tab

    local idx = 1
    for i,name in ipairs(TABS) do if name == tab then idx = i break end end
    if self.leftPageNumber then self.leftPageNumber:SetText(tostring((idx-1)*2 + 1)) end
    if self.rightPageNumber then self.rightPageNumber:SetText(tostring((idx-1)*2 + 2)) end
    if self.pageNumber then self.pageNumber:SetText(string.format("%d-%d", (idx-1)*2 + 1, (idx-1)*2 + 2)) end

    local notesTab = tab == "NOTES"
    if self.modeButton then self.modeButton:SetText(self.readMode and "EDIT" or "READ") end
    if self.deleteButton and self.deleteButton.SetEnabled then self.deleteButton:SetEnabled(notesTab and self.currentEntryId ~= nil) end

    for name,page in pairs(self.pages or {}) do page:SetHidden(name ~= tab) end

    if SUITE_TABS[tab] then
        if EPC.saved then EPC.saved.activeTab = (tab == "TRAVEL" and "MAP" or tab) end
        if EPC.RefreshNow then EPC:RefreshNow("codex-" .. string.lower(tab)) end
        self:RefreshSuitePage(tab)
    elseif tab == "NOTES" then self:RefreshNotes()
    elseif tab == "PINS" then self:RefreshPinsPage()
    elseif tab == "DICE" then self:RefreshDice()
    elseif tab == "CODEX" then self:RefreshCodex()
    elseif tab == "ACHIEVEMENTS" or tab == "STATS" then self:RefreshDocumentPage() end

    self:ApplyTheme()
    if changed and self.window and not self.window:IsHidden() then self:PlayPageTurn() end
end

function J:Create()
    local window = wm:CreateTopLevelWindow("EAS_CustomJournal")
    self.window = window
    window:SetDimensions(1024, 1024)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, -8)
    window:SetClampedToScreen(true)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetHidden(true)
    window:SetDrawLayer(DL_OVERLAY)
    window:SetDrawTier(DT_HIGH)

    local rootHeight = tonumber(GuiRoot and GuiRoot.GetHeight and GuiRoot:GetHeight()) or 1080
    if rootHeight < 1060 and window.SetScale then window:SetScale(math.max(0.72, (rootHeight - 28) / 1024)) end

    local nativeBook = getNativeLoreBookMedium()
    self.nativeBook = nativeBook
    local bookTexture = wm:CreateControl("EAS_CustomJournal_NativeLoreBook", window, CT_TEXTURE)
    bookTexture:SetAnchorFill(window)
    if nativeBook then bookTexture:SetTexture(nativeBook.bg) end
    bookTexture:SetTextureCoords(0,1,0,1)
    bookTexture:SetMouseEnabled(false)
    self.bookTexture = bookTexture
    self.openSound = nativeBook and nativeBook.openSound or nil
    self.closeSound = nativeBook and nativeBook.closeSound or nil
    self.turnSound = nativeBook and nativeBook.turnPageSound or nil

    local bg = wm:CreateControl("EAS_CustomJournal_BG", window, CT_BACKDROP)
    bg:SetAnchor(TOPLEFT, window, TOPLEFT, 68, 108)
    bg:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -68, -108)
    bg:SetEdgeTexture(nil, 2, 2, 2)
    bg:SetCenterColor(0.95,0.89,0.76, nativeBook and 0 or 1)
    bg:SetEdgeColor(0.34,0.22,0.10, nativeBook and 0 or 0.85)
    self.bg = bg

    local pageW = tonumber(nativeBook and nativeBook.pageWidth) or 374
    local pageH = tonumber(nativeBook and nativeBook.pageHeight) or 620
    pageW = math.max(340, math.min(410, pageW))
    pageH = math.max(560, math.min(690, pageH))
    self.pageW, self.pageH = pageW, pageH

    local leftHost = wm:CreateControl("EAS_CodexLeftPageHost", window, CT_CONTROL)
    if nativeBook then leftHost:SetAnchor(LEFT, window, LEFT, tonumber(nativeBook.leftPageXOffset) or 0, tonumber(nativeBook.pageYOffset) or 0)
    else leftHost:SetAnchor(TOPLEFT, window, TOPLEFT, 126, 172) end
    leftHost:SetDimensions(pageW, pageH)
    self.leftPageHost = leftHost
    self.leftNavigation = leftHost

    local rightHost = wm:CreateControl("EAS_CodexRightPageHost", window, CT_CONTROL)
    if nativeBook then rightHost:SetAnchor(RIGHT, window, RIGHT, tonumber(nativeBook.rightPageXOffset) or 0, tonumber(nativeBook.pageYOffset) or 0)
    else rightHost:SetAnchor(TOPLEFT, window, TOPLEFT, 550, 158) end
    rightHost:SetDimensions(pageW, pageH)
    self.rightPageHost = rightHost
    self.rightContent = rightHost

    self.panels, self.themeLabels, self.tabButtons, self.pages, self.topButtons = {}, {}, {}, {}, {}
    self.categoryButtons = {}

    -- Keep chapter navigation on the opening INDEX spread instead of cluttering both outer book edges.
    -- A single INDEX control remains available while reading so users can return to the table of contents.
    local indexButton = makeButton("EAS_CodexIndexButton", window, "INDEX", 698, 68, 86, 26, function() self:SetTab("INDEX") end)
    indexButton:SetDrawLayer(DL_OVERLAY)
    indexButton:SetDrawLevel(1000)
    local theme = makeButton("EAS_CodexTheme", window, "THEME", 792, 68, 86, 26, function() self:CycleTheme() end)
    local close = makeButton("EAS_CodexClose", window, "CLOSE", 886, 68, 86, 26, function() self:Hide() end)
    self.indexButton, self.themeButton, self.closeButton = indexButton, theme, close
    self.topButtons[#self.topButtons+1] = indexButton
    self.topButtons[#self.topButtons+1] = theme
    self.topButtons[#self.topButtons+1] = close

    self.pages.INDEX = self:CreateIndexSpread()
    self.pages.NOTES = self:CreateNotesSpread()
    self.pages.PINS = self:CreatePinsSpread()
    self.pages.BUILD = self:CreateSuiteSpread("BUILD")
    self.pages.GEAR = self:CreateSuiteSpread("GEAR")
    self.pages.SKILLS = self:CreateSuiteSpread("SKILLS")
    self.pages.COMBAT = self:CreateSuiteSpread("COMBAT")
    self.pages.ACTIVITY = self:CreateSuiteSpread("ACTIVITY")
    self.pages.QUESTS = self:CreateSuiteSpread("QUESTS")
    self.pages.TRAVEL = self:CreateSuiteSpread("TRAVEL")
    self.pages.TOOLS = self:CreateSuiteSpread("TOOLS")
    self.pages.ACHIEVEMENTS = self:CreateDocumentSpread("ACHIEVEMENTS")
    self.pages.STATS = self:CreateDocumentSpread("STATS")
    self.pages.CODEX = self:CreateCodexSpread()
    self.pages.DICE = self:CreateDiceSpread()
    self.suiteRowIndex = { GEAR=0, QUESTS=0, TRAVEL=0, ACTIVITY=0 }

    local prev = makeButton("EAS_CodexPrevSpread", window, "< PREV", 336, 894, 86, 26, function() self:TurnPage(-1) end)
    local spreadNo = makeLabel("EAS_CodexSpreadNumber", window, "1-2", 452, 896, 120, 22, "ZoFontGameSmall")
    spreadNo:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    local nextB = makeButton("EAS_CodexNextSpread", window, "NEXT >", 602, 894, 86, 26, function() self:TurnPage(1) end)
    self.prevPageButton, self.nextPageButton, self.pageNumber = prev, nextB, spreadNo
    self.themeLabels[#self.themeLabels+1] = spreadNo

    local leftNum = makeLabel("EAS_CodexLeftPageNumber", leftHost, "1", math.floor((pageW-40)/2), pageH-28, 40, 20, "ZoFontGameSmall")
    leftNum:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    local rightNum = makeLabel("EAS_CodexRightPageNumber", rightHost, "2", math.floor((pageW-40)/2), pageH-28, 40, 20, "ZoFontGameSmall")
    rightNum:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.leftPageNumber, self.rightPageNumber = leftNum, rightNum
    self.themeLabels[#self.themeLabels+1] = leftNum
    self.themeLabels[#self.themeLabels+1] = rightNum

    local flip = wm:CreateControl("EAS_CustomJournal_FlipPage", window, CT_BACKDROP)
    flip:SetDimensions(pageW, pageH-72)
    flip:SetAnchor(TOPLEFT, rightHost, TOPLEFT, 0, 44)
    flip:SetEdgeTexture(nil, 1, 1, 1)
    flip:SetDrawLayer(DL_OVERLAY)
    flip:SetHidden(true)
    self.flipPage = flip
    local flipMark = makeLabel("EAS_CodexFlipMark", flip, "TAMRIEL CODEX", 18, math.floor((pageH-110)/2), pageW-36, 30, "ZoFontWinH2")
    flipMark:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.themeLabels[#self.themeLabels+1] = flipMark

    window:SetHandler("OnMoveStop", function(control)
        local s = self:EnsureSaved()
        s.left, s.top = control:GetLeft(), control:GetTop()
    end)

    local s = self:EnsureSaved()
    if s.twoPageIndexUpgrade ~= true then
        s.activeTab = "INDEX"
        s.twoPageIndexUpgrade = true
    end
    if s.cleanOpeningIndexUpgrade ~= true then
        s.activeTab = "INDEX"
        s.cleanOpeningIndexUpgrade = true
    end
    if tonumber(s.left) and tonumber(s.top) and s.left >= 0 and s.top >= 0 then
        window:ClearAnchors()
        window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, s.left, s.top)
    end

    self.category = s.category or "ALL"
    self.activeTab = s.activeTab or "INDEX"
    self.readMode = s.readMode == true
    self.codexMode = "ALCHEMY"
    self:SetEditorEnabled(not self.readMode)
    self:SetTab(self.activeTab)
    self:RegisterMapPins()
end

--[[
    v0.19.1 interactive Codex fix
    Restores the old menu's direct row selection inside the two-page book.
    Left page = filters + clickable rows. Right page = selected details + actions.
]]

local EAS_INTERACTIVE_TABS = { GEAR=true, QUESTS=true, TRAVEL=true, ACTIVITY=true }

local function easSetEnabled(control, enabled)
    if not control then return end
    if control.SetEnabled then control:SetEnabled(enabled == true) end
    if control.SetAlpha then control:SetAlpha(enabled == true and 1 or 0.45) end
end

local function easSetInk(label, selected, muted)
    if not label or not label.SetColor then return end
    local t = J:GetTheme()
    if selected then
        label:SetColor(t.accent[1], t.accent[2], t.accent[3], 1)
    elseif muted then
        label:SetColor(t.text[1], t.text[2], t.text[3], 0.66)
    else
        label:SetColor(t.text[1], t.text[2], t.text[3], 1)
    end
end

function J:CreateBookRow(parent, name, index, y, onClick)
    local row = wm:CreateControl("EAS_CodexInteractive_"..name.."_"..index, parent, CT_BUTTON)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, 14, y)
    row:SetDimensions(self.pageW-28, 44)
    row:SetMouseEnabled(true)
    row:SetHandler("OnClicked", function() onClick(index) end)

    local title = makeLabel("EAS_CodexInteractiveTitle_"..name.."_"..index, row, "", 4, 1, self.pageW-52, 19, "ZoFontGameBold")
    local detail = makeLabel("EAS_CodexInteractiveDetail_"..name.."_"..index, row, "", 4, 21, self.pageW-52, 18, "ZoFontGameSmall")
    detail:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

    local rule = wm:CreateControl("EAS_CodexInteractiveRule_"..name.."_"..index, row, CT_BACKDROP)
    rule:SetAnchor(BOTTOMLEFT, row, BOTTOMLEFT, 4, 0)
    rule:SetDimensions(self.pageW-54, 1)
    rule:SetCenterColor(0.26,0.17,0.08,0.18)
    rule:SetEdgeColor(0,0,0,0)

    row.titleLabel = title
    row.detailLabel = detail
    row.rule = rule
    row.rowIndex = index
    return row
end

function J:CreateInteractiveSuiteSpread(name)
    local spread = self:CreateSpreadShell(name)
    self:AddSpreadHeader(spread, TAB_TITLES[name] or name, "SELECTED")
    spread.interactive = true
    spread.controls = {}
    spread.rows = {}

    -- Top filter/mode row. Exact labels are populated per section.
    local ctlGap = 4
    local ctlW = math.floor((self.pageW - 28 - ctlGap*3) / 4)
    for i=1,4 do
        local b = makeButton("EAS_CodexInteractiveCtl_"..name.."_"..i, spread.left, "", 14+(i-1)*(ctlW+ctlGap), 54, ctlW, 25, function() self:RunInteractiveControl(name, i) end)
        spread.controls[i] = b
    end

    -- Secondary controls: search/clear or page navigation depending on section.
    spread.secondary = {}
    local secW = math.floor((self.pageW - 28 - ctlGap*3) / 4)
    for i=1,4 do
        local b = makeButton("EAS_CodexInteractiveSecondary_"..name.."_"..i, spread.left, "", 14+(i-1)*(secW+ctlGap), 84, secW, 25, function() self:RunInteractiveSecondary(name, i) end)
        spread.secondary[i] = b
    end

    local rowStart = 116
    local rowCount = 8
    for i=1,rowCount do
        spread.rows[i] = self:CreateBookRow(spread.left, name, i, rowStart + (i-1)*47, function(rowIndex)
            self:SelectInteractiveRow(name, rowIndex)
        end)
    end

    spread.pageLabel = makeLabel("EAS_CodexInteractivePage_"..name, spread.left, "", 14, self.pageH-86, self.pageW-28, 20, "ZoFontGameSmall")
    spread.pageLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.themeLabels[#self.themeLabels+1] = spread.pageLabel

    spread.detailTitle = makeLabel("EAS_CodexInteractiveSelectedTitle_"..name, spread.right, "Select an entry", 18, 62, self.pageW-36, 52, "ZoFontWinH2")
    spread.detailTitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    spread.detailBody = makeLabel("EAS_CodexInteractiveSelectedBody_"..name, spread.right, "", 18, 124, self.pageW-36, self.pageH-308, "ZoFontGame")
    spread.detailBody:SetVerticalAlignment(TEXT_ALIGN_TOP)
    self.themeLabels[#self.themeLabels+1] = spread.detailTitle
    self.themeLabels[#self.themeLabels+1] = spread.detailBody

    spread.optimizerModes = {}
    if name == "GEAR" then
        local modeW = math.floor((self.pageW - 42) / 4)
        for i=1,4 do
            spread.optimizerModes[i] = makeButton("EAS_CodexOptimizerMode_"..i, spread.right, "", 10 + (i-1)*(modeW+2), self.pageH-244, modeW, 26, function()
                if EPC.GearOptimizer and EPC.GearOptimizer.PRESET_ORDER then
                    EPC.GearOptimizer:SetPreset(EPC.GearOptimizer.PRESET_ORDER[i])
                    self:RefreshSuitePage("GEAR")
                end
            end)
        end
    end
    spread.action0 = makeButton("EAS_CodexInteractiveAction0_"..name, spread.right, "", 18, self.pageH-208, self.pageW-36, 32, function() self:RunInteractiveGearOptimizer(name) end)
    spread.action1 = makeButton("EAS_CodexInteractiveAction1_"..name, spread.right, "ACTION", 18, self.pageH-168, self.pageW-36, 32, function() self:RunInteractivePrimary(name) end)
    spread.action2 = makeButton("EAS_CodexInteractiveAction2_"..name, spread.right, "", 18, self.pageH-128, self.pageW-36, 30, function() self:RunInteractiveSecondaryAction(name) end)
    spread.action3 = makeButton("EAS_CodexInteractiveAction3_"..name, spread.right, "", 18, self.pageH-88, self.pageW-36, 30, function() self:RunInteractiveTertiaryAction(name) end)
    spread.action0:SetHidden(true)
    spread.action2:SetHidden(true)
    spread.action3:SetHidden(true)

    if name == "QUESTS" then
        spread.left:SetMouseEnabled(true)
        spread.left:SetHandler("OnMouseWheel", function(_, delta)
            if EPC.QuestFinder then
                EPC.QuestFinder:Scroll(delta > 0 and -(EPC.QuestFinder.PAGE_SIZE or 8) or (EPC.QuestFinder.PAGE_SIZE or 8))
                self:RefreshSuitePage("QUESTS")
            end
        end)
    end

    return spread
end

-- Override the generic spread creator for sections that need row-by-row interaction.
local easOldCreateSuiteSpread_v191 = J.CreateSuiteSpread
function J:CreateSuiteSpread(name)
    if EAS_INTERACTIVE_TABS[name] then return self:CreateInteractiveSuiteSpread(name) end
    return easOldCreateSuiteSpread_v191(self, name)
end

function J:RunInteractiveControl(tab, index)
    if tab == "GEAR" and EPC.SetJournal then
        local filters = {"ALL","OVERLAND","DUNGEON","TRIAL"}
        EPC.SetJournal:SetFilter(filters[index] or "ALL")
    elseif tab == "QUESTS" and EPC.QuestFinder then
        local filters = {"NOT_STARTED","ACTIVE","ALL"}
        if index <= 3 then EPC.QuestFinder:SetFilter(filters[index]) end
        if EPC.RefreshNow then EPC:RefreshNow("codex-quest-filter") end
    elseif tab == "TRAVEL" and EPC.Travel then
        local modes = {"SHRINES","FRIENDS","GUILD","GROUP"}
        EPC.Travel:SetMode(modes[index] or "SHRINES")
    elseif tab == "ACTIVITY" and EPC.Activities then
        local goals = {"BALANCED","XP","GOLD"}
        if index <= 3 then EPC.Activities:SetGoal(goals[index]) end
    end
    self:RefreshSuitePage(tab)
end

function J:RunInteractiveSecondary(tab, index)
    if tab == "GEAR" and EPC.SetJournal then
        if index == 1 then EPC.SetJournal:PromptSearch()
        elseif index == 2 then EPC.SetJournal:ClearSearch()
        elseif index == 3 then EPC.SetJournal:ChangePage(-1)
        elseif index == 4 then EPC.SetJournal:ChangePage(1) end
    elseif tab == "QUESTS" and EPC.QuestFinder then
        if index == 1 then
            if type(StartChatInput) == "function" then StartChatInput("/esosuite quest ") end
        elseif index == 2 then EPC.QuestFinder:Scroll(-(EPC.QuestFinder.PAGE_SIZE or 8))
        elseif index == 3 then EPC.QuestFinder:Scroll(EPC.QuestFinder.PAGE_SIZE or 8)
        elseif index == 4 and EPC.RefreshNow then EPC:RefreshNow("codex-quest-refresh") end
    elseif tab == "TRAVEL" and EPC.Travel then
        if index == 1 then EPC.Travel:ChangePage(-1, EPC.Travel.BOOK_PAGE_SIZE or 8)
        elseif index == 2 then EPC.Travel:ChangePage(1, EPC.Travel.BOOK_PAGE_SIZE or 8)
        elseif index == 3 and EPC.RefreshNow then EPC:RefreshNow("codex-travel-refresh") end
    elseif tab == "ACTIVITY" and EPC.RefreshNow then
        EPC:RefreshNow("codex-activity-refresh")
    end
    self:RefreshSuitePage(tab)
end

function J:SelectInteractiveRow(tab, index)
    if tab == "GEAR" and EPC.SetJournal then EPC.SetJournal:SelectRow(index)
    elseif tab == "QUESTS" and EPC.QuestFinder then EPC.QuestFinder:SelectRow(index)
    elseif tab == "TRAVEL" and EPC.Travel then EPC.Travel:SelectVisibleRow(index, EPC.Travel.BOOK_PAGE_SIZE or 8)
    elseif tab == "ACTIVITY" and EPC.Activities then EPC.Activities:SelectVisibleRow(index) end
    self:RefreshSuitePage(tab)
end

function J:RunInteractiveGearOptimizer(tab)
    if tab == "GEAR" and EPC.GearOptimizer and EPC.GearOptimizer.EquipBestRecommended then
        EPC.GearOptimizer:EquipBestRecommended()
    end
    self:RefreshSuitePage(tab)
end

function J:RunInteractivePrimary(tab)
    if tab == "GEAR" and EPC.SetJournal then EPC.SetJournal:FastTravelSelected()
    elseif tab == "QUESTS" and EPC.QuestFinder then EPC.QuestFinder:RouteSelected()
    elseif tab == "TRAVEL" and EPC.Travel then EPC.Travel:TravelSelected()
    elseif tab == "ACTIVITY" and EPC.Activities then EPC.Activities:ActivateSelected() end
    self:RefreshSuitePage(tab)
end

function J:RunInteractiveSecondaryAction(tab)
    if tab == "GEAR" and EPC.SetJournal and EPC.SetJournal.RouteSelected then
        EPC.SetJournal:RouteSelected()
    end
    self:RefreshSuitePage(tab)
end

function J:RunInteractiveTertiaryAction(tab)
    if tab == "GEAR" and EPC.SetJournal and EPC.SetJournal.OpenSourceQuests then
        EPC.SetJournal:OpenSourceQuests()
    end
    self:RefreshSuitePage(tab)
end

function J:RefreshInteractiveGear(page)
    local v = EPC.SetJournal and EPC.SetJournal:BuildView() or {rows={}}
    if page.optimizerModes and EPC.GearOptimizer then
        local active = select(1, EPC.GearOptimizer:GetPreset())
        for i,b in ipairs(page.optimizerModes) do
            local key = EPC.GearOptimizer.PRESET_ORDER[i]
            local preset = EPC.GearOptimizer.PRESETS[key]
            b:SetHidden(false)
            b:SetText(preset and preset.label or key)
            setButtonStyle(b, key == active, self:GetTheme())
        end
    end
    if page.action0 then
        page.action0:SetHidden(false)
        local _,preset = EPC.GearOptimizer and EPC.GearOptimizer:GetPreset() or nil,nil
        page.action0:SetText(preset and ("OPTIMIZE: " .. preset.label) or "ENDGAME OPTIMIZE")
        easSetEnabled(page.action0, EPC.GearOptimizer ~= nil and EPC.GearOptimizer.EquipBestRecommended ~= nil)
    end
    local filters = {"ALL","OVERLAND","DUNGEON","TRIAL"}
    for i,b in ipairs(page.controls) do
        b:SetText(filters[i])
        setButtonStyle(b, filters[i] == v.filter, self:GetTheme())
    end
    page.secondary[1]:SetText("SEARCH")
    page.secondary[2]:SetText("CLEAR")
    page.secondary[3]:SetText("< PREV")
    page.secondary[4]:SetText("NEXT >")
    for i,b in ipairs(page.secondary) do b:SetHidden(false) setButtonStyle(b, false, self:GetTheme()) end
    easSetEnabled(page.secondary[3], (tonumber(v.page) or 1) > 1)
    easSetEnabled(page.secondary[4], (tonumber(v.page) or 1) < (tonumber(v.pageCount) or 1))

    local selectedId = v.selected and v.selected.setId or nil
    for i,rowControl in ipairs(page.rows) do
        local row = v.rows and v.rows[i]
        if row then
            local selected = selectedId ~= nil and selectedId == row.setId
            rowControl:SetHidden(false)
            rowControl.titleLabel:SetText(tostring(row.name or "Item Set"))
            rowControl.detailLabel:SetText(string.format("%d/%d collected  -  %s", tonumber(row.unlocked) or 0, tonumber(row.total) or 0, tostring(row.kindText or "Set pieces")))
            easSetInk(rowControl.titleLabel, selected, false)
            easSetInk(rowControl.detailLabel, selected, true)
        else rowControl:SetHidden(true) end
    end
    page.pageLabel:SetText(string.format("PAGE %d / %d  -  %d SETS", tonumber(v.page) or 1, tonumber(v.pageCount) or 1, tonumber(v.total) or 0))
    if v.selected then
        page.detailTitle:SetText(v.selected.name or "Selected Set")
        setBookText(page.detailBody, string.format("COLLECTION\n%d / %d pieces\n\nTYPE\n%s\n\nSOURCE\n%s\n\n%s", tonumber(v.selected.unlocked) or 0, tonumber(v.selected.total) or 0, tostring(v.selected.kindText or "Set pieces"), tostring(v.selected.sourceText or "Unknown source"), tostring(v.hint or "")), page.detailBody:GetWidth())
        page.action1:SetText("FAST TRAVEL")
        page.action2:SetText("ROUTE SOURCE")
        page.action3:SetText("ZONE QUESTS")
        page.action2:SetHidden(false)
        page.action3:SetHidden(false)
        easSetEnabled(page.action1, true); easSetEnabled(page.action2, true); easSetEnabled(page.action3, true)
    else
        page.detailTitle:SetText("SELECT A SET")
        setBookText(page.detailBody, "Click any set on the left page. Its collection progress, source, and routing actions will appear here.", page.detailBody:GetWidth())
        page.action1:SetText("FAST TRAVEL")
        page.action2:SetText("ROUTE SOURCE")
        page.action3:SetText("ZONE QUESTS")
        page.action2:SetHidden(false)
        page.action3:SetHidden(false)
        easSetEnabled(page.action1, false); easSetEnabled(page.action2, false); easSetEnabled(page.action3, false)
    end
end

function J:RefreshInteractiveQuests(page)
    if page.action0 then page.action0:SetHidden(true) end
    local v = EPC.QuestFinder and EPC.QuestFinder:BuildView() or {rows={}}
    local filters = {{"NOT_STARTED","NOT STARTED"},{"ACTIVE","ACTIVE"},{"ALL","ALL"}}
    for i,b in ipairs(page.controls) do
        if i <= 3 then
            b:SetHidden(false); b:SetText(filters[i][2]); setButtonStyle(b, v.filter == filters[i][1], self:GetTheme())
        else b:SetHidden(true) end
    end
    page.secondary[1]:SetText("SEARCH")
    page.secondary[2]:SetText("< PREV")
    page.secondary[3]:SetText("NEXT >")
    page.secondary[4]:SetText("REFRESH")
    for _,b in ipairs(page.secondary) do b:SetHidden(false) setButtonStyle(b, false, self:GetTheme()) end
    easSetEnabled(page.secondary[2], (tonumber(v.offset) or 0) > 0)
    easSetEnabled(page.secondary[3], ((tonumber(v.offset) or 0) + #(v.rows or {})) < (tonumber(v.total) or 0))

    local selectedKey = v.selected and v.selected.key or nil
    for i,rowControl in ipairs(page.rows) do
        local row = v.rows and v.rows[i]
        if row then
            local selected = selectedKey ~= nil and selectedKey == row.key
            rowControl:SetHidden(false)
            rowControl.titleLabel:SetText(tostring(row.name or "Quest"))
            local meta = string.format("%s  -  %s", tostring(row.zone or "Unknown zone"), tostring(row.status or row.type or "Quest"))
            rowControl.detailLabel:SetText(meta)
            easSetInk(rowControl.titleLabel, selected, false)
            easSetInk(rowControl.detailLabel, selected, true)
        else rowControl:SetHidden(true) end
    end
    local first = (tonumber(v.offset) or 0) + 1
    local last = math.min(tonumber(v.total) or 0, first + #(v.rows or {}) - 1)
    page.pageLabel:SetText(string.format("%d-%d OF %d  -  %s", (v.total or 0) > 0 and first or 0, last, tonumber(v.total) or 0, tostring(v.scanProgress or "INDEX")))
    if v.selected then
        page.detailTitle:SetText(v.selected.name or "Selected Quest")
        local details = {
            "STATUS\n" .. tostring(v.selected.status or v.selected.type or "Quest"),
            "ZONE\n" .. tostring(v.selected.zone or "Unknown zone"),
            "STARTER / ACCESS\n" .. tostring(v.selected.starter or "Starter location unknown"),
            tostring(v.selected.access or ""),
        }
        if v.selected.requires then details[#details+1] = "REQUIRES\n" .. tostring(v.selected.requires) end
        setBookText(page.detailBody, table.concat(details, "\n\n"), page.detailBody:GetWidth())
        page.action1:SetText("ROUTE TO STARTER")
        page.action2:SetHidden(true)
        easSetEnabled(page.action1, true)
    else
        page.detailTitle:SetText("SELECT A QUEST")
        setBookText(page.detailBody, "Click a quest on the left page to select it. The starter/access information and route button will appear here.", page.detailBody:GetWidth())
        page.action1:SetText("ROUTE TO STARTER")
        page.action2:SetHidden(true)
        easSetEnabled(page.action1, false)
    end
end

function J:RefreshInteractiveTravel(page)
    if page.action0 then page.action0:SetHidden(true) end
    local bookPageSize = EPC.Travel and (EPC.Travel.BOOK_PAGE_SIZE or 8) or 8
    local v = EPC.Travel and EPC.Travel:BuildView(EPC.lastSnapshot or {}, bookPageSize) or {rows={}}
    local modes = {{"SHRINES","SHRINES"},{"FRIENDS","FRIENDS"},{"GUILD","GUILD"},{"GROUP","GROUP"}}
    for i,b in ipairs(page.controls) do
        b:SetHidden(false); b:SetText(modes[i][2]); setButtonStyle(b, v.mode == modes[i][1], self:GetTheme())
    end
    page.secondary[1]:SetText("< PREV")
    page.secondary[2]:SetText("NEXT >")
    page.secondary[3]:SetText("REFRESH")
    page.secondary[4]:SetHidden(true)
    for i,b in ipairs(page.secondary) do if i <= 3 then b:SetHidden(false) setButtonStyle(b, false, self:GetTheme()) end end
    easSetEnabled(page.secondary[1], v.canPageBack == true)
    easSetEnabled(page.secondary[2], v.canPageForward == true)

    local selectedKey = v.selected and v.selected.key or nil
    for i,rowControl in ipairs(page.rows) do
        local row = v.rows and v.rows[i]
        if row then
            local selected = selectedKey ~= nil and selectedKey == row.key
            rowControl:SetHidden(false)
            rowControl.titleLabel:SetText(tostring(row.name or "Destination"))
            local detail = string.format("%s  -  %s  -  %s", tostring(row.zoneName or "Unknown zone"), tostring(row.costText or ""), tostring(row.statusText or ""))
            if row.isQuestBest then detail = "QUEST BEST  -  " .. detail end
            rowControl.detailLabel:SetText(detail)
            easSetInk(rowControl.titleLabel, selected, row.canTravel ~= true)
            easSetInk(rowControl.detailLabel, selected, true)
        else rowControl:SetHidden(true) end
    end
    page.pageLabel:SetText(string.format("PAGE %d / %d  -  %s", tonumber(v.page) or 1, tonumber(v.pageCount) or 1, tostring(v.modeLabel or v.mode or "TRAVEL")))
    if v.selected then
        page.detailTitle:SetText(v.selected.name or "Selected Destination")
        local details = string.format("ZONE\n%s\n\nCOST\n%s\n\nSTATUS\n%s\n\n%s", tostring(v.selected.zoneName or "Unknown zone"), tostring(v.selected.costText or ""), tostring(v.selected.statusText or ""), tostring(v.hint or ""))
        setBookText(page.detailBody, details, page.detailBody:GetWidth())
        page.action1:SetText(v.actionText or "TRAVEL")
        page.action2:SetHidden(true)
        easSetEnabled(page.action1, v.actionEnabled == true)
    else
        page.detailTitle:SetText("SELECT A DESTINATION")
        setBookText(page.detailBody, tostring(v.emptyText or "Click a destination on the left page, then use TRAVEL here."), page.detailBody:GetWidth())
        page.action1:SetText(v.actionText or "TRAVEL")
        page.action2:SetHidden(true)
        easSetEnabled(page.action1, false)
    end
end

function J:RefreshInteractiveActivity(page)
    if page.action0 then page.action0:SetHidden(true) end
    local v = EPC.Activities and EPC.Activities:BuildView(EPC.lastSnapshot or {}) or {rows={}}
    local goals = {{"BALANCED","BALANCED"},{"XP","XP"},{"GOLD","GOLD"}}
    for i,b in ipairs(page.controls) do
        if i <= 3 then b:SetHidden(false); b:SetText(goals[i][2]); setButtonStyle(b, v.goal == goals[i][1], self:GetTheme()) else b:SetHidden(true) end
    end
    page.secondary[1]:SetText("REFRESH")
    page.secondary[2]:SetHidden(true)
    page.secondary[3]:SetHidden(true)
    page.secondary[4]:SetHidden(true)
    page.secondary[1]:SetHidden(false)
    setButtonStyle(page.secondary[1], false, self:GetTheme())

    local selectedKey = v.selected and v.selected.key or nil
    for i,rowControl in ipairs(page.rows) do
        local row = v.rows and v.rows[i]
        if row then
            local selected = selectedKey ~= nil and selectedKey == row.key
            rowControl:SetHidden(false)
            rowControl.titleLabel:SetText(tostring(row.name or row.displayText or "Activity"))
            rowControl.detailLabel:SetText(tostring(row.detailText or row.location or ""))
            easSetInk(rowControl.titleLabel, selected, false)
            easSetInk(rowControl.detailLabel, selected, true)
        else rowControl:SetHidden(true) end
    end
    page.pageLabel:SetText(string.format("GOAL: %s", tostring(v.goalLabel or v.goal or "BALANCED")))
    if v.selected then
        page.detailTitle:SetText(v.selected.name or "Selected Activity")
        local details = string.format("%s\n\n%s", tostring(v.selected.detailText or v.selected.location or ""), tostring(v.hint or v.selected.note or ""))
        setBookText(page.detailBody, details, page.detailBody:GetWidth())
        page.action1:SetText(v.actionText or "ROUTE QUEST")
        page.action2:SetHidden(true)
        easSetEnabled(page.action1, v.actionEnabled == true)
    else
        page.detailTitle:SetText("SELECT AN ACTIVITY")
        setBookText(page.detailBody, tostring(v.hint or "Click an activity on the left page to see its details and route/action."), page.detailBody:GetWidth())
        page.action1:SetText(v.actionText or "ROUTE QUEST")
        page.action2:SetHidden(true)
        easSetEnabled(page.action1, false)
    end
end

-- Override the v0.19 plain-text renderer for interactive sections.
local easOldRefreshSuitePage_v191 = J.RefreshSuitePage
function J:RefreshSuitePage(tab)
    tab = tab or self.activeTab
    local page = self.pages and self.pages[tab]
    if page and page.interactive then
        if tab == "GEAR" then self:RefreshInteractiveGear(page)
        elseif tab == "QUESTS" then self:RefreshInteractiveQuests(page)
        elseif tab == "TRAVEL" then self:RefreshInteractiveTravel(page)
        elseif tab == "ACTIVITY" then self:RefreshInteractiveActivity(page) end
        return
    end
    return easOldRefreshSuitePage_v191(self, tab)
end

--[[
    v0.19.3 readability/layout override
    - Keeps global book controls inside the native lore-book pages.
    - Notes use an explicit TITLE field with a large NOTES body beneath it.
    - Checkpoints expose a clear NAME THIS CHECKPOINT field for labels such as XP Farm.
    - Book text uses explicit word wrapping and a smaller readable font for dense pages.
]]

-- Rebind the shared book text helper so every later refresh uses readable wrapping.
setBookText = function(label, text, width)
    if not label then return end
    text = tostring(text or "")
    width = tonumber(width) or (label.GetWidth and label:GetWidth()) or 320
    if label.SetVerticalAlignment then label:SetVerticalAlignment(TEXT_ALIGN_TOP) end

    -- Start with the normal readable game font. Dense pages automatically step down
    -- to the standard small font rather than clipping horizontally.
    if label.SetFont then label:SetFont("ZoFontGame") end
    local wrapped = wrapForBook(label, text, width)
    local lineCount = 0
    for _ in string.gmatch(wrapped .. "\n", "(.-)\n") do lineCount = lineCount + 1 end
    if lineCount > 30 and label.SetFont then
        label:SetFont("ZoFontGameSmall")
        wrapped = wrapForBook(label, text, width)
    end
    label:SetText(wrapped)
end

function J:CreateNotesSpread()
    local spread = self:CreateSpreadShell("NOTES")
    self:AddSpreadHeader(spread, "NOTES", "WRITE / READ NOTE")
    self.notePage = spread

    -- Left page: browse notes. Keep categories compact so the note list gets most of the page.
    local catHeader = makeLabel("EAS_CodexNotesCategoryHeader", spread.left, "CATEGORIES", 12, 54, self.pageW-24, 20, "ZoFontGameSmall")
    self.themeLabels[#self.themeLabels+1] = catHeader
    self.categoryHeader = catHeader
    self.categoryButtons = {}
    local catW = math.floor((self.pageW - 38) / 2)
    for i,cat in ipairs(CATEGORIES) do
        local col = (i-1) % 2
        local row = math.floor((i-1) / 2)
        local b = makeButton("EAS_CodexNoteCat_v193_"..i, spread.left, cat, 12 + col*(catW+10), 78 + row*24, catW, 21, function() self:SetCategory(cat) end)
        b:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        self.categoryButtons[cat] = b
    end

    self.noteCount = makeLabel("EAS_CodexNoteCount_v193", spread.left, "", 12, 180, self.pageW-24, 20, "ZoFontGameSmall")
    self.themeLabels[#self.themeLabels+1] = self.noteCount
    self.noteRows = {}
    for i=1,11 do
        local b = makeButton("EAS_CodexNoteRow_v193_"..i, spread.left, "", 12, 208+(i-1)*31, self.pageW-24, 27, function(control)
            if control.entryId then self:SelectEntry(control.entryId) end
        end)
        b:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        self.noteRows[i] = b
    end

    -- Right page: TITLE first, then the note body directly below it.
    local titleLabel = makeLabel("EAS_CodexNoteTitleLabel_v193", spread.right, "TITLE", 12, 56, self.pageW-24, 20, "ZoFontGameBold")
    self.themeLabels[#self.themeLabels+1] = titleLabel
    self.noteTitleEdit = self:CreateEditBox("EAS_CodexNoteTitle_v193", spread.right, 12, 80, self.pageW-24, 36, false)
    self.noteTitleEdit:SetFont("ZoFontGameBold")

    local notesLabel = makeLabel("EAS_CodexNoteBodyLabel_v193", spread.right, "NOTES", 12, 128, self.pageW-24, 20, "ZoFontGameBold")
    self.themeLabels[#self.themeLabels+1] = notesLabel
    local actionY = self.pageH - 102
    self.noteBodyEdit = self:CreateEditBox("EAS_CodexNoteBody_v193", spread.right, 12, 152, self.pageW-24, math.max(250, actionY-164), true)
    self.noteBodyEdit:SetFont("ZoFontGame")

    local gap = 6
    local bw = math.floor((self.pageW - 24 - gap*3) / 4)
    self.newButton = makeButton("EAS_CodexNoteNew_v193", spread.right, "NEW", 12, actionY, bw, 27, function() self:NewEntry() end)
    self.saveButton = makeButton("EAS_CodexNoteSave_v193", spread.right, "SAVE", 12+bw+gap, actionY, bw, 27, function() self:SaveCurrentEntry() end)
    self.deleteButton = makeButton("EAS_CodexNoteDelete_v193", spread.right, "DELETE", 12+(bw+gap)*2, actionY, bw, 27, function() self:DeleteEntry() end)
    self.modeButton = makeButton("EAS_CodexNoteMode_v193", spread.right, "EDIT", 12+(bw+gap)*3, actionY, bw, 27, function()
        self.readMode = not self.readMode
        self:EnsureSaved().readMode = self.readMode
        self:SetEditorEnabled(not self.readMode)
        self:ApplyTheme()
    end)
    self.topButtons[#self.topButtons+1] = self.newButton
    self.topButtons[#self.topButtons+1] = self.saveButton
    self.topButtons[#self.topButtons+1] = self.deleteButton
    self.topButtons[#self.topButtons+1] = self.modeButton

    local autosave = makeLabel("EAS_CodexNoteAutosave_v193", spread.right,
        "Auto-save is on when you change notes, change chapters, or close the Codex.",
        12, actionY+31, self.pageW-24, 34, "ZoFontGameSmall")
    self.themeLabels[#self.themeLabels+1] = autosave
    setBookText(autosave, autosave:GetText(), autosave:GetWidth())
    return spread
end

function J:CreatePinsSpread()
    local spread = self:CreateSpreadShell("PINS")
    self:AddSpreadHeader(spread, "CHECKPOINTS", "CHECKPOINT DETAILS")

    local nameLabel = makeLabel("EAS_CodexCheckpointNameLabel_v193", spread.left, "NAME THIS CHECKPOINT", 12, 54, self.pageW-24, 20, "ZoFontGameBold")
    self.themeLabels[#self.themeLabels+1] = nameLabel
    local hint = makeLabel("EAS_CodexCheckpointNameHint_v193", spread.left,
        "Example: XP Farm, Material Route, World Boss, Fishing Spot",
        12, 76, self.pageW-24, 38, "ZoFontGameSmall")
    self.themeLabels[#self.themeLabels+1] = hint
    setBookText(hint, hint:GetText(), hint:GetWidth())

    self.checkpointNameEdit = wm:CreateControl("EAS_CodexCheckpointName_v193", spread.left, CT_EDITBOX)
    self.checkpointNameEdit:SetAnchor(TOPLEFT, spread.left, TOPLEFT, 12, 116)
    self.checkpointNameEdit:SetDimensions(self.pageW-24, 34)
    self.checkpointNameEdit:SetFont("ZoFontGameBold")
    if self.checkpointNameEdit.SetMaxInputChars then self.checkpointNameEdit:SetMaxInputChars(80) end

    local savedLabel = makeLabel("EAS_CodexCheckpointSavedLabel_v193", spread.left, "SAVED CHECKPOINTS", 12, 160, self.pageW-24, 20, "ZoFontGameSmall")
    self.themeLabels[#self.themeLabels+1] = savedLabel
    self.pinRows = {}
    for i=1,8 do
        local b = makeButton("EAS_CodexCheckpointRow_v193_"..i, spread.left, "", 12, 184+(i-1)*39, self.pageW-24, 34, function(control)
            self.selectedPinId = control.pinId
            local selected = self:GetPinById(control.pinId)
            if selected and self.checkpointNameEdit then self.checkpointNameEdit:SetText(selected.name or "") end
            self:RefreshPinsPage()
        end)
        b:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        self.pinRows[i] = b
    end

    self.checkpointPrev = makeButton("EAS_CodexCheckpointPrev_v193", spread.left, "< PREV", 12, self.pageH-66, 78, 26, function() self:ChangeCheckpointPage(-1) end)
    self.checkpointPageLabel = makeLabel("EAS_CodexCheckpointPage_v193", spread.left, "", 96, self.pageH-64, self.pageW-192, 22, "ZoFontGameSmall")
    self.checkpointPageLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.themeLabels[#self.themeLabels+1] = self.checkpointPageLabel
    self.checkpointNext = makeButton("EAS_CodexCheckpointNext_v193", spread.left, "NEXT >", self.pageW-90, self.pageH-66, 78, 26, function() self:ChangeCheckpointPage(1) end)

    local detailsIntro = makeLabel("EAS_CodexCheckpointDetailIntro_v193", spread.right,
        "Select a saved checkpoint on the left. You can update it to your current location, place a waypoint, or delete it.",
        18, 56, self.pageW-36, 78, "ZoFontGameSmall")
    self.themeLabels[#self.themeLabels+1] = detailsIntro
    setBookText(detailsIntro, detailsIntro:GetText(), detailsIntro:GetWidth())

    self.pinInfo = makeLabel("EAS_CodexCheckpointInfo_v193", spread.right, "", 18, 140, self.pageW-36, self.pageH-390, "ZoFontGame")
    self.themeLabels[#self.themeLabels+1] = self.pinInfo
    self.pinSave = makeButton("EAS_CodexCheckpointSave_v193", spread.right, "SAVE / UPDATE HERE", 18, self.pageH-200, self.pageW-36, 30, function()
        self:SaveCurrentLocation(self.checkpointNameEdit and self.checkpointNameEdit:GetText() or "")
    end)
    self.pinWaypoint = makeButton("EAS_CodexCheckpointWaypoint_v193", spread.right, "SET EXACT CHECKPOINT WAYPOINT", 18, self.pageH-162, self.pageW-36, 30, function() self:SetPinWaypoint() end)
    self.pinWayshrine = makeButton("EAS_CodexCheckpointWayshrine_v213", spread.right, "TRAVEL TO WAYSHRINE", 18, self.pageH-124, self.pageW-36, 30, function() self:TravelToNearestCheckpointWayshrine() end)
    if self.pinWayshrine.SetEnabled then self.pinWayshrine:SetEnabled(false) end
    self.pinDelete = makeButton("EAS_CodexCheckpointDelete_v193", spread.right, "DELETE CHECKPOINT", 18, self.pageH-86, self.pageW-36, 30, function() self:DeletePin() end)
    return spread
end

-- Interactive rows should never use ellipsis. Use a compact second line and explicit wrapping.
function J:CreateBookRow(parent, name, index, y, onClick)
    local row = wm:CreateControl("EAS_CodexInteractive_v193_"..name.."_"..index, parent, CT_BUTTON)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, 14, y)
    row:SetDimensions(self.pageW-28, 44)
    row:SetMouseEnabled(true)
    row:SetHandler("OnClicked", function() onClick(index) end)

    local title = makeLabel("EAS_CodexInteractiveTitle_v193_"..name.."_"..index, row, "", 4, 0, self.pageW-36, 20, "ZoFontGameBold")
    local detail = makeLabel("EAS_CodexInteractiveDetail_v193_"..name.."_"..index, row, "", 4, 20, self.pageW-36, 22, "ZoFontGameSmall")
    local rule = wm:CreateControl("EAS_CodexInteractiveRule_v193_"..name.."_"..index, row, CT_BACKDROP)
    rule:SetAnchor(BOTTOMLEFT, row, BOTTOMLEFT, 4, 0)
    rule:SetDimensions(self.pageW-38, 1)
    rule:SetCenterColor(0.26,0.17,0.08,0.18)
    rule:SetEdgeColor(0,0,0,0)

    row.titleLabel = title
    row.detailLabel = detail
    row.rule = rule
    row.rowIndex = index
    return row
end

-- Let the latest book creation build all pages, then move every global control onto parchment.
local easCreate_v193_base = J.Create
function J:Create()
    easCreate_v193_base(self)

    -- The native book controls must be anchored to page hosts, not absolute window pixels.
    local footerY = -4
    if self.indexButton then
        self.indexButton:ClearAnchors()
        self.indexButton:SetAnchor(BOTTOMLEFT, self.leftPageHost, BOTTOMLEFT, 8, footerY)
        self.indexButton:SetDimensions(68, 24)
        self.indexButton:SetMouseEnabled(true)
        self.indexButton:SetDrawLayer(DL_OVERLAY)
        self.indexButton:SetDrawLevel(1000)
    end
    if self.prevPageButton then
        self.prevPageButton:ClearAnchors()
        self.prevPageButton:SetAnchor(BOTTOMRIGHT, self.leftPageHost, BOTTOMRIGHT, -8, footerY)
        self.prevPageButton:SetDimensions(76, 24)
        self.prevPageButton:SetText("< PREV")
    end
    if self.nextPageButton then
        self.nextPageButton:ClearAnchors()
        self.nextPageButton:SetAnchor(BOTTOMLEFT, self.rightPageHost, BOTTOMLEFT, 8, footerY)
        self.nextPageButton:SetDimensions(76, 24)
        self.nextPageButton:SetText("NEXT >")
    end
    if self.themeButton then
        self.themeButton:ClearAnchors()
        self.themeButton:SetAnchor(BOTTOMRIGHT, self.rightPageHost, BOTTOMRIGHT, -82, footerY)
        self.themeButton:SetDimensions(72, 24)
        self.themeButton:SetText("THEME")
    end
    if self.closeButton then
        self.closeButton:ClearAnchors()
        self.closeButton:SetAnchor(BOTTOMRIGHT, self.rightPageHost, BOTTOMRIGHT, -8, footerY)
        self.closeButton:SetDimensions(68, 24)
        self.closeButton:SetText("CLOSE")
    end

    -- The window-wide spread number was outside some native book media. Use the printed page numbers instead.
    if self.pageNumber then self.pageNumber:SetHidden(true) end
    if self.leftPageNumber then
        self.leftPageNumber:ClearAnchors()
        self.leftPageNumber:SetAnchor(BOTTOM, self.leftPageHost, BOTTOM, 0, -6)
    end
    if self.rightPageNumber then
        self.rightPageNumber:ClearAnchors()
        self.rightPageNumber:SetAnchor(BOTTOM, self.rightPageHost, BOTTOM, 0, -6)
    end

    -- One-time migration opens the clean index so users immediately see the corrected layout.
    local s = self:EnsureSaved()
    if s.readableBookControlsUpgrade ~= true then
        s.activeTab = "INDEX"
        s.readableBookControlsUpgrade = true
        self:SetTab("INDEX")
    end
end


--[[
    v0.19.4 editing / book-only / text-fit override
    - Makes both note fields and checkpoint names explicit focusable edit controls.
    - Keeps the legacy standalone window permanently hidden; Tamriel Codex is the main UI.
    - Gives Utilities a true two-page information layout so priorities/hints are not clipped.
    - Fits wrapped book text vertically using ESO label text measurements when available.
]]

local function easConfigureEditable(control, multiLine)
    if not control then return end
    control:SetMouseEnabled(true)
    if control.SetKeyboardEnabled then control:SetKeyboardEnabled(true) end
    if control.SetEditEnabled then control:SetEditEnabled(true) end
    if control.SetCopyEnabled then control:SetCopyEnabled(true) end
    if control.SetPasteEnabled then control:SetPasteEnabled(true) end
    if control.SetTextType and TEXT_TYPE_ALL then control:SetTextType(TEXT_TYPE_ALL) end
    if multiLine then
        if control.SetMultiLine then control:SetMultiLine(true) end
        if control.SetNewLineEnabled then control:SetNewLineEnabled(true) end
    end
    -- Explicit focus handling avoids cases where a bare CT_EDITBOX renders but does
    -- not begin receiving keyboard input when clicked inside the native book window.
    control:SetHandler("OnMouseUp", function(edit, button, upInside)
        if upInside ~= false and edit.TakeFocus then edit:TakeFocus() end
    end)
end

local easCreateEditBox_v194_base = J.CreateEditBox
function J:CreateEditBox(name, parent, x, y, w, h, multiLine)
    local edit = easCreateEditBox_v194_base(self, name, parent, x, y, w, h, multiLine)
    easConfigureEditable(edit, multiLine == true)
    return edit
end

local function easSetBookTextFit(label, text, width)
    if not label then return end
    text = tostring(text or "")
    width = tonumber(width) or (label.GetWidth and label:GetWidth()) or 320
    local height = tonumber(label.GetHeight and label:GetHeight()) or 0
    if label.SetVerticalAlignment then label:SetVerticalAlignment(TEXT_ALIGN_TOP) end

    local fonts = {"ZoFontGame", "ZoFontGameSmall"}
    local chosen = fonts[1]
    local wrapped = ""
    for _,font in ipairs(fonts) do
        if label.SetFont then label:SetFont(font) end
        wrapped = wrapForBook(label, text, width)
        label:SetText(wrapped)
        chosen = font
        local textHeight = tonumber(label.GetTextHeight and label:GetTextHeight()) or 0
        if height <= 0 or textHeight <= height then break end
    end
    if chosen == "ZoFontGameSmall" and label.SetLineSpacing then label:SetLineSpacing(-1) end
    label:SetText(wrapped)
end

-- Make the shared book renderer use vertical fit as well as word wrapping.
setBookText = easSetBookTextFit

-- Utilities gets a deliberate two-page layout instead of a blind midpoint split.
local easRefreshSuitePage_v194_base = J.RefreshSuitePage
function J:RefreshSuitePage(tab)
    tab = tab or self.activeTab
    if tab == "TOOLS" and EPC.UtilitySuite then
        local page = self.pages and self.pages.TOOLS
        if page and page.leftBody and page.rightBody then
            local v = EPC.UtilitySuite:BuildView(EPC.lastSnapshot or {}) or {}
            local left = {}
            left[#left+1] = tostring(v.title or "Utilities")
            if v.description and v.description ~= "" then
                left[#left+1] = ""
                left[#left+1] = tostring(v.description)
            end
            if v.stats then
                left[#left+1] = ""
                addViewStats(left, v.stats)
            end

            local right = {}
            right[#right+1] = tostring(v.listHeader or ("MODE: " .. tostring(v.modeLabel or v.mode or "OVERVIEW")))
            right[#right+1] = ""
            local rows = v.rows or v.items or {}
            if #rows == 0 then
                right[#right+1] = "No utility priorities are available yet."
            else
                for i,row in ipairs(rows) do
                    local text = type(row) == "table" and (row.text or row.label or row.name or row.value) or row
                    right[#right+1] = string.format("%d. %s", i, tostring(text or ""))
                    if type(row) == "table" and row.detailText then right[#right+1] = "   " .. tostring(row.detailText) end
                end
            end
            if v.hint and v.hint ~= "" then
                right[#right+1] = ""
                right[#right+1] = "NOTE"
                right[#right+1] = tostring(v.hint)
            end

            easSetBookTextFit(page.leftBody, table.concat(left, "\n"), page.leftBody:GetWidth())
            easSetBookTextFit(page.rightBody, table.concat(right, "\n"), page.rightBody:GetWidth())
            self:SetSuiteButtons("TOOLS", {"MODE"})
            return
        end
    end
    return easRefreshSuitePage_v194_base(self, tab)
end

local easCreate_v194_base = J.Create
function J:Create()
    easCreate_v194_base(self)

    -- v6: Install raw keyboard capture for the single toggle key on the FINAL active Codex window.
    -- Earlier J:Create implementations are superseded later in this file, so the
    -- handler must be attached here after the complete book has been constructed.
    if self.window then
        if self.window.SetKeyboardEnabled then
            self.window:SetKeyboardEnabled(true)
        end
        self.window:SetHandler("OnKeyDown", function(_, key, ctrl, alt, shift, command)
            if not self.window or self.window:IsHidden() then return end
            if self:RawKeyMatchesAction("ESO_PROGRESSION_COACH_TOGGLE", key, ctrl, alt, shift, command) then
                self:Hide()
            end
        end)
    end

    -- One-time migration: open Notes in edit mode so both title and body are ready to type.
    local s = self:EnsureSaved()
    if s.fullNoteEditingUpgrade ~= true then
        s.readMode = false
        s.fullNoteEditingUpgrade = true
    end
    self.readMode = s.readMode == true

    easConfigureEditable(self.noteTitleEdit, false)
    easConfigureEditable(self.noteBodyEdit, true)
    easConfigureEditable(self.checkpointNameEdit, false)
    self:SetEditorEnabled(not self.readMode)

    -- Keep the obsolete menu window inaccessible even if an older saved variable says enabled.
    if EPC.UI and EPC.UI.root then EPC.UI.root:SetHidden(true) end
end
