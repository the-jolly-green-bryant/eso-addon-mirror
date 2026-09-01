-- ESO Adventurer Suite
-- Antiquity Lead Finder: live ESO lead state + integrated source-location reference data.

ESOProgressionCoach = ESOProgressionCoach or {}
local EPC = ESOProgressionCoach
EPC.AntiquityLeadFinder = EPC.AntiquityLeadFinder or {}
local F = EPC.AntiquityLeadFinder
local D = EPC.AntiquityLeadData or { locations = {}, findZoneOverrides = {}, specialFindZones = {} }
local wm = WINDOW_MANAGER

local GOLD = { 0.96, 0.72, 0.22, 1.00 }
local TEXT = { 0.94, 0.95, 0.97, 1.00 }
local MUTED = { 0.62, 0.67, 0.74, 1.00 }
local GREEN = { 0.34, 0.88, 0.34, 1.00 }
local CYAN = { 0.24, 0.78, 0.96, 1.00 }
local PURPLE = { 0.74, 0.38, 0.94, 1.00 }
local RED = { 0.96, 0.30, 0.24, 1.00 }
local PANEL = { 0.022, 0.027, 0.039, 0.97 }
local PANEL_ALT = { 0.042, 0.050, 0.070, 0.92 }
local EDGE = { 0.30, 0.35, 0.44, 0.94 }
local PAGE_SIZE = 13
local ACTION_LAYER = "ESOAdventurerSuiteAntiquityLeadFinderLayer"

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local values = { pcall(fn, ...) }
    if not values[1] then return fallback end
    table.remove(values, 1)
    return unpack(values)
end

local function number(value) return tonumber(value) or 0 end

local function clean(value)
    value = tostring(value or "")
    if value ~= "" and type(zo_strformat) == "function" then
        local ok, formatted = pcall(zo_strformat, "<<C:1>>", value)
        if ok and formatted and formatted ~= "" then value = formatted end
    end
    return value:gsub("%^%a+", "")
end

local function zoneNameById(zoneId)
    zoneId = number(zoneId)
    if zoneId <= 0 or type(GetZoneNameById) ~= "function" then return "Unknown" end
    local name = clean(safe(GetZoneNameById, "", zoneId))
    return name ~= "" and name or ("Zone " .. tostring(zoneId))
end

local function formatDuration(seconds)
    seconds = math.max(0, math.floor(number(seconds)))
    if seconds <= 0 then return "-" end
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    if days > 0 then return string.format("%dd %dh", days, hours) end
    if hours > 0 then return string.format("%dh %dm", hours, minutes) end
    return string.format("%dm", math.max(1, minutes))
end

local function createBackdrop(parent, center, edge)
    local control = wm:CreateControl(nil, parent, CT_BACKDROP)
    control:SetCenterColor(unpack(center or PANEL))
    control:SetEdgeColor(unpack(edge or EDGE))
    control:SetEdgeTexture("EsoUI/Art/Tooltips/UI-SliderBackdrop.dds", 1, 1, 1)
    return control
end

local function createLabel(parent, text, font, color, alignment)
    local control = wm:CreateControl(nil, parent, CT_LABEL)
    control:SetFont(font or "ZoFontGame")
    control:SetColor(unpack(color or TEXT))
    control:SetText(tostring(text or ""))
    control:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    control:SetHorizontalAlignment(alignment or TEXT_ALIGN_LEFT)
    return control
end

local function createButton(parent, text, callback)
    local bg = createBackdrop(parent, { 0.09, 0.105, 0.14, 0.98 }, { 0.38, 0.45, 0.56, 0.95 })
    local button = wm:CreateControl(nil, bg, CT_BUTTON)
    button:SetAnchorFill(bg)
    button:SetFont("ZoFontGameBold")
    button:SetNormalFontColor(unpack(TEXT))
    button:SetMouseOverFontColor(unpack(GOLD))
    button:SetPressedFontColor(1, 1, 1, 1)
    button:SetText(text)
    button:SetHandler("OnClicked", callback)
    return button, bg
end

local function currentRootZoneId()
    local zoneIndex = number(safe(GetUnitZoneIndex, 0, "player"))
    local zoneId = zoneIndex > 0 and number(safe(GetZoneId, 0, zoneIndex)) or 0
    if zoneId <= 0 then
        local mapZoneIndex = number(safe(GetCurrentMapZoneIndex, 0))
        zoneId = mapZoneIndex > 0 and number(safe(GetZoneId, 0, mapZoneIndex)) or 0
    end
    local seen = {}
    while zoneId > 0 and not seen[zoneId] and type(GetParentZoneId) == "function" do
        seen[zoneId] = true
        local parent = number(safe(GetParentZoneId, zoneId, zoneId))
        if parent <= 0 or parent == zoneId then break end
        zoneId = parent
    end
    return zoneId
end

function F:GetFindZoneInfo(antiquityId, scryZoneId, haveLead)
    local override = D.findZoneOverrides and D.findZoneOverrides[antiquityId] or nil
    local zoneId = number(override or scryZoneId)
    local special = D.specialFindZones and D.specialFindZones[zoneId]
    if special then return special.label or "Multiple zones", zoneId, special.zones or {} end
    return zoneNameById(zoneId), zoneId, { zoneId }
end

function F:MatchesCurrentZone(entry, rootZoneId)
    if not entry or rootZoneId <= 0 then return true end
    if entry.findZoneId == 101010 then return true end -- all zones
    for _, zoneId in ipairs(entry.findZones or {}) do
        if number(zoneId) == rootZoneId then return true end
        local candidate = number(zoneId)
        local seen = {}
        while candidate > 0 and not seen[candidate] and type(GetParentZoneId) == "function" do
            if candidate == rootZoneId then return true end
            seen[candidate] = true
            local parent = number(safe(GetParentZoneId, candidate, candidate))
            if parent <= 0 or parent == candidate then break end
            candidate = parent
        end
    end
    return false
end

function F:BuildEntries()
    local entries = {}
    if type(GetNextAntiquityId) ~= "function" then return entries end
    local antiquityId = safe(GetNextAntiquityId, nil)
    local guard = 0
    while antiquityId and guard < 2000 do
        guard = guard + 1
        antiquityId = number(antiquityId)
        if antiquityId > 0 then
            local haveLead = safe(DoesAntiquityHaveLead, false, antiquityId) == true
            local scryZoneId = number(safe(GetAntiquityZoneId, 0, antiquityId))
            local name = clean(safe(GetAntiquityName, "Antiquity", antiquityId))
            local quality = number(safe(GetAntiquityQuality, 0, antiquityId))
            local difficulty = number(safe(GetAntiquityDifficulty, quality, antiquityId))
            local recovered = number(safe(GetNumAntiquitiesRecovered, 0, antiquityId))
            local repeatable = safe(IsAntiquityRepeatable, true, antiquityId) ~= false
            local loreTotal = number(safe(GetNumAntiquityLoreEntries, 0, antiquityId))
            local loreAcquired = number(safe(GetNumAntiquityLoreEntriesAcquired, 0, antiquityId))
            local loreMissing = math.max(0, loreTotal - loreAcquired)
            local expiration = haveLead and number(safe(GetAntiquityLeadTimeRemainingSeconds, 0, antiquityId)) or 0
            local setId = number(safe(GetAntiquitySetId, 0, antiquityId))
            local setName = setId > 0 and clean(safe(GetAntiquitySetName, "", setId)) or ""
            local source = D.locations and D.locations[antiquityId] or nil
            local findZone, findZoneId, findZones = self:GetFindZoneInfo(antiquityId, scryZoneId, haveLead)
            local complete = (not repeatable and recovered > 0)
            local status
            if haveLead then status = "HAVE LEAD"
            elseif complete then status = "COMPLETE"
            elseif loreMissing > 0 and recovered > 0 then status = "CODEX"
            else status = "FIND LEAD" end
            entries[#entries + 1] = {
                antiquityId = antiquityId,
                name = name,
                haveLead = haveLead,
                scryZoneId = scryZoneId,
                scryZone = zoneNameById(scryZoneId),
                findZone = findZone,
                findZoneId = findZoneId,
                findZones = findZones,
                source = source,
                sourceShort = source and tostring(source.short or source.sourceType or "Unknown") or "Unknown",
                sourceType = source and tostring(source.sourceType or "Unknown") or "Unknown",
                sourceLong = source and tostring(source.long or source.short or "Source location not documented.") or "Source location not documented.",
                sourceComplete = source and source.complete == true or false,
                difficulty = difficulty,
                quality = quality,
                recovered = recovered,
                repeatable = repeatable,
                loreMissing = loreMissing,
                loreTotal = loreTotal,
                expiration = expiration,
                setName = setName,
                status = status,
                complete = complete,
            }
        end
        antiquityId = safe(GetNextAntiquityId, nil, antiquityId)
    end
    return entries
end

function F:PassesFilter(entry)
    local filter = self.filter or (EPC.saved and EPC.saved.antiquityLeadFinderFilter) or "CAN_FIND"
    if filter == "CAN_FIND" then
        if entry.haveLead or entry.complete then return false end
    elseif filter == "HAVE_LEAD" then
        if not entry.haveLead then return false end
    elseif filter == "MISSING_CODEX" then
        if entry.loreMissing <= 0 then return false end
    elseif filter == "NEVER_DUG" then
        if entry.recovered > 0 then return false end
    end
    if self.currentZoneOnly == true then
        if not self:MatchesCurrentZone(entry, currentRootZoneId()) then return false end
    end
    return true
end

function F:RefreshData()
    local all = self:BuildEntries()
    local filtered = {}
    for _, entry in ipairs(all) do if self:PassesFilter(entry) then filtered[#filtered + 1] = entry end end
    table.sort(filtered, function(a, b)
        if a.haveLead ~= b.haveLead then return a.haveLead == true end
        if a.haveLead and b.haveLead and a.expiration ~= b.expiration then return a.expiration < b.expiration end
        if a.difficulty ~= b.difficulty then return a.difficulty > b.difficulty end
        return string.lower(a.name) < string.lower(b.name)
    end)
    self.entries = filtered
    self.page = math.max(1, math.min(self.page or 1, math.max(1, math.ceil(#filtered / PAGE_SIZE))))
end

function F:SetFilter(filter)
    self.filter = tostring(filter or "CAN_FIND")
    if EPC.saved then EPC.saved.antiquityLeadFinderFilter = self.filter end
    self.page = 1
    self:Refresh()
end

function F:ToggleCurrentZone()
    self.currentZoneOnly = not (self.currentZoneOnly == true)
    if EPC.saved then EPC.saved.antiquityLeadFinderCurrentZone = self.currentZoneOnly == true end
    self.page = 1
    self:Refresh()
end

function F:CreateRow(parent, index)
    local row = wm:CreateControl(nil, parent, CT_CONTROL)
    row.bg = createBackdrop(row, index % 2 == 0 and PANEL_ALT or PANEL, { 0.18, 0.22, 0.29, 0.65 })
    row.bg:SetAnchorFill(row)
    row.status = createLabel(row, "", "ZoFontGameSmall", TEXT, TEXT_ALIGN_CENTER)
    row.name = createLabel(row, "", "ZoFontGameSmall", TEXT)
    row.zone = createLabel(row, "", "ZoFontGameSmall", MUTED)
    row.source = createLabel(row, "", "ZoFontGameSmall", TEXT)
    row.dug = createLabel(row, "", "ZoFontGameSmall", MUTED, TEXT_ALIGN_CENTER)
    row.expires = createLabel(row, "", "ZoFontGameSmall", MUTED, TEXT_ALIGN_RIGHT)
    for _, label in ipairs({ row.name, row.zone, row.source }) do
        if type(label.SetWrapMode) == "function" and TEXT_WRAP_MODE_ELLIPSIS ~= nil then label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end
    end
    row.button = wm:CreateControl(nil, row, CT_BUTTON)
    row.button:SetAnchorFill(row)
    row.button:SetHandler("OnClicked", function() if row.entry then F:SelectEntry(row.entry) end end)
    row:SetHidden(true)
    return row
end

function F:LayoutRow(row, header)
    if not row then return end
    local width = number(row:GetWidth())
    local h = number(row:GetHeight())
    local margin, gap = 4, 6
    local statusW, zoneW, dugW, expiresW = 92, 170, 54, 82
    local nameW = math.max(210, math.floor(width * 0.26))
    local fixed = margin * 2 + statusW + nameW + zoneW + dugW + expiresW + (gap * 5)
    local sourceW = math.max(190, width - fixed)
    local x = margin
    local function place(control, w, align)
        control:ClearAnchors()
        control:SetAnchor(TOPLEFT, row, TOPLEFT, x, 0)
        control:SetDimensions(w, h)
        control:SetHorizontalAlignment(align or TEXT_ALIGN_LEFT)
        x = x + w + gap
    end
    place(row.status, statusW, TEXT_ALIGN_CENTER)
    place(row.name, nameW, header and TEXT_ALIGN_CENTER or TEXT_ALIGN_LEFT)
    place(row.zone, zoneW, header and TEXT_ALIGN_CENTER or TEXT_ALIGN_LEFT)
    place(row.source, sourceW, header and TEXT_ALIGN_CENTER or TEXT_ALIGN_LEFT)
    place(row.dug, dugW, TEXT_ALIGN_CENTER)
    place(row.expires, math.max(60, width - x - margin), header and TEXT_ALIGN_CENTER or TEXT_ALIGN_RIGHT)
end

function F:CreateHeaderRow(parent)
    local row = wm:CreateControl(nil, parent, CT_CONTROL)
    row.status = createLabel(row, "STATUS", "ZoFontGameSmall", MUTED, TEXT_ALIGN_CENTER)
    row.name = createLabel(row, "LEAD", "ZoFontGameSmall", MUTED, TEXT_ALIGN_CENTER)
    row.zone = createLabel(row, "FIND ZONE", "ZoFontGameSmall", MUTED, TEXT_ALIGN_CENTER)
    row.source = createLabel(row, "SOURCE", "ZoFontGameSmall", MUTED, TEXT_ALIGN_CENTER)
    row.dug = createLabel(row, "DUG", "ZoFontGameSmall", MUTED, TEXT_ALIGN_CENTER)
    row.expires = createLabel(row, "EXPIRES", "ZoFontGameSmall", MUTED, TEXT_ALIGN_CENTER)
    return row
end

function F:CreateWindow()
    if self.window then return true end
    if not wm then return false end
    local base = "EAS_AntiquityLeadFinder"
    local rootName = base
    local serial = 1
    while _G[rootName] ~= nil and serial < 100 do
        serial = serial + 1
        rootName = base .. "_" .. tostring(serial)
    end
    local ok, window = pcall(function() return wm:CreateTopLevelWindow(rootName) end)
    if not ok or not window then return false end
    self.window = window
    window:SetDrawTier(DT_HIGH)
    window:SetDrawLayer(DL_CONTROLS)
    window:SetDrawLevel(230)
    window:SetMouseEnabled(true)
    if type(window.SetMovable) == "function" then window:SetMovable(true) end
    if type(window.SetResizable) == "function" then window:SetResizable(true) end
    if window.SetDimensionConstraints then window:SetDimensionConstraints(1000, 720, 1500, 950) end
    if window.SetClampedToScreen then window:SetClampedToScreen(true) end
    window:SetDimensions(1180, 760)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetHidden(true)

    self.background = createBackdrop(window, { 0.010, 0.013, 0.020, 0.985 }, { 0.78, 0.58, 0.18, 1.00 })
    self.background:SetAnchorFill(window)

    self.header = createBackdrop(window, { 0.028, 0.032, 0.045, 0.99 }, EDGE)
    self.header:SetAnchor(TOPLEFT, window, TOPLEFT, 4, 4)
    self.header:SetAnchor(TOPRIGHT, window, TOPRIGHT, -4, 4)
    self.header:SetHeight(50)
    self.header:SetMouseEnabled(true)
    self.header:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and type(window.StartMoving) == "function" then window:StartMoving() end
    end)
    self.header:SetHandler("OnMouseUp", function()
        if type(window.StopMovingOrResizing) == "function" then window:StopMovingOrResizing() end
        F:SavePlacement()
    end)
    self.title = createLabel(self.header, "ANTIQUITY LEAD FINDER", "ZoFontWinH2", TEXT, TEXT_ALIGN_CENTER)
    self.title:SetAnchor(CENTER, self.header, CENTER, 0, 0)
    self.title:SetDimensions(420, 30)
    self.subtitle = createLabel(self.header, "Live ESO lead state + source-location reference", "ZoFontGameSmall", MUTED)
    self.subtitle:SetAnchor(LEFT, self.header, LEFT, 14, 13)
    self.subtitle:SetDimensions(330, 20)
    self.closeButton, self.closeBg = createButton(self.header, "X", function() F:Hide() end)
    self.closeBg:SetAnchor(RIGHT, self.header, RIGHT, -10, 0)
    self.closeBg:SetDimensions(40, 30)

    self.filters = wm:CreateControl(nil, window, CT_CONTROL)
    self.filters:SetAnchor(TOPLEFT, window, TOPLEFT, 8, 60)
    self.filters:SetAnchor(TOPRIGHT, window, TOPRIGHT, -8, 60)
    self.filters:SetHeight(40)
    self.filterButtons = {}
    local defs = {
        { "CAN FIND", "CAN_FIND" }, { "HAVE LEAD", "HAVE_LEAD" }, { "MISSING CODEX", "MISSING_CODEX" },
        { "NEVER DUG", "NEVER_DUG" }, { "ALL", "ALL" },
    }
    local x = 0
    for _, def in ipairs(defs) do
        local button, bg = createButton(self.filters, def[1], function() F:SetFilter(def[2]) end)
        bg:SetAnchor(LEFT, self.filters, LEFT, x, 0)
        bg:SetDimensions(def[2] == "MISSING_CODEX" and 128 or 106, 30)
        x = x + (def[2] == "MISSING_CODEX" and 136 or 114)
        self.filterButtons[def[2]] = { button = button, bg = bg }
    end
    self.zoneButton, self.zoneBg = createButton(self.filters, "CURRENT ZONE", function() F:ToggleCurrentZone() end)
    self.zoneBg:SetAnchor(RIGHT, self.filters, RIGHT, -166, 0)
    self.zoneBg:SetDimensions(140, 30)
    self.refreshButton, self.refreshBg = createButton(self.filters, "REFRESH", function() F:Refresh() end)
    self.refreshBg:SetAnchor(RIGHT, self.filters, RIGHT, 0, 0)
    self.refreshBg:SetDimensions(112, 30)

    self.listPanel = createBackdrop(window, PANEL, EDGE)
    self.listPanel:SetAnchor(TOPLEFT, window, TOPLEFT, 8, 104)
    self.listPanel:SetAnchor(TOPRIGHT, window, TOPRIGHT, -8, 104)
    self.listPanel:SetHeight(448)
    self.listHeader = self:CreateHeaderRow(self.listPanel)
    self.listHeader:SetAnchor(TOPLEFT, self.listPanel, TOPLEFT, 8, 8)
    self.listHeader:SetAnchor(TOPRIGHT, self.listPanel, TOPRIGHT, -8, 8)
    self.listHeader:SetHeight(24)
    self.rows = {}
    for i = 1, PAGE_SIZE do
        local row = self:CreateRow(self.listPanel, i)
        row:SetAnchor(TOPLEFT, self.listPanel, TOPLEFT, 8, 34 + ((i - 1) * 30))
        row:SetAnchor(TOPRIGHT, self.listPanel, TOPRIGHT, -8, 34 + ((i - 1) * 30))
        row:SetHeight(29)
        self.rows[i] = row
    end

    self.detailPanel = createBackdrop(window, PANEL, EDGE)
    self.detailPanel:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 8, -42)
    self.detailPanel:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -8, -42)
    self.detailPanel:SetHeight(154)
    self.detailTitle = createLabel(self.detailPanel, "Select a lead", "ZoFontGameBold", GOLD)
    self.detailTitle:SetAnchor(TOPLEFT, self.detailPanel, TOPLEFT, 12, 8)
    self.detailTitle:SetAnchor(TOPRIGHT, self.detailPanel, TOPRIGHT, -12, 8)
    self.detailTitle:SetHeight(24)
    self.detailMeta = createLabel(self.detailPanel, "", "ZoFontGameSmall", MUTED)
    self.detailMeta:SetAnchor(TOPLEFT, self.detailPanel, TOPLEFT, 12, 34)
    self.detailMeta:SetAnchor(TOPRIGHT, self.detailPanel, TOPRIGHT, -12, 34)
    self.detailMeta:SetHeight(24)
    self.detailSource = createLabel(self.detailPanel, "", "ZoFontGameSmall", TEXT)
    self.detailSource:SetAnchor(TOPLEFT, self.detailPanel, TOPLEFT, 12, 60)
    self.detailSource:SetAnchor(TOPRIGHT, self.detailPanel, TOPRIGHT, -12, 60)
    self.detailSource:SetHeight(80)
    self.detailSource:SetVerticalAlignment(TEXT_ALIGN_TOP)
    if type(self.detailSource.SetWrapMode) == "function" and TEXT_WRAP_MODE_ELLIPSIS ~= nil then self.detailSource:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end

    self.previousButton, self.previousBg = createButton(window, "<", function() F:PreviousPage() end)
    self.previousBg:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -150, -8)
    self.previousBg:SetDimensions(38, 28)
    self.pageLabel = createLabel(window, "PAGE 1 / 1", "ZoFontGameSmall", MUTED, TEXT_ALIGN_CENTER)
    self.pageLabel:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -58, -8)
    self.pageLabel:SetDimensions(86, 28)
    self.nextButton, self.nextBg = createButton(window, ">", function() F:NextPage() end)
    self.nextBg:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -8, -8)
    self.nextBg:SetDimensions(38, 28)
    self.countLabel = createLabel(window, "", "ZoFontGameSmall", MUTED)
    self.countLabel:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 12, -8)
    self.countLabel:SetDimensions(420, 28)

    window:SetHandler("OnResizeStop", function() F:SavePlacement() F:ApplyLayout() end)
    self:RestorePlacement()
    self:ApplyLayout()
    return true
end

function F:ApplyLayout()
    if not self.window then return end
    local width, height = self.window:GetDimensions()
    local detailHeight = 154
    local listTop = 104
    local footerReserve = detailHeight + 54
    self.listPanel:ClearAnchors()
    self.listPanel:SetAnchor(TOPLEFT, self.window, TOPLEFT, 8, listTop)
    self.listPanel:SetAnchor(TOPRIGHT, self.window, TOPRIGHT, -8, listTop)
    self.listPanel:SetHeight(math.max(425, height - listTop - footerReserve))
    local availableRows = math.max(1, math.floor((self.listPanel:GetHeight() - 36) / PAGE_SIZE))
    local rowHeight = math.max(25, math.min(31, availableRows))
    self.listHeader:SetDimensions(self.listPanel:GetWidth() - 16, 24)
    self:LayoutRow(self.listHeader, true)
    for i, row in ipairs(self.rows or {}) do
        row:ClearAnchors()
        row:SetAnchor(TOPLEFT, self.listPanel, TOPLEFT, 8, 34 + ((i - 1) * rowHeight))
        row:SetDimensions(self.listPanel:GetWidth() - 16, rowHeight - 1)
        self:LayoutRow(row, false)
    end
end

function F:SavePlacement()
    if not self.window or not EPC.saved then return end
    EPC.saved.antiquityLeadFinderLeft = self.window:GetLeft()
    EPC.saved.antiquityLeadFinderTop = self.window:GetTop()
    EPC.saved.antiquityLeadFinderWidth = self.window:GetWidth()
    EPC.saved.antiquityLeadFinderHeight = self.window:GetHeight()
end

function F:RestorePlacement(forceCenter)
    if not self.window or not EPC.saved then return end
    local rootW, rootH = number(GuiRoot:GetWidth()), number(GuiRoot:GetHeight())
    local width = math.max(1000, math.min(number(EPC.saved.antiquityLeadFinderWidth or 1180), math.max(1000, rootW - 30)))
    local height = math.max(720, math.min(number(EPC.saved.antiquityLeadFinderHeight or 760), math.max(720, rootH - 30)))
    self.window:SetDimensions(width, height)
    self.window:ClearAnchors()
    local left = number(EPC.saved.antiquityLeadFinderLeft or -1)
    local top = number(EPC.saved.antiquityLeadFinderTop or -1)
    if forceCenter or left < 0 or top < 0 then self.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    else self.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top) end
end

function F:ResetPosition()
    if not EPC.saved then return end
    EPC.saved.antiquityLeadFinderLeft = -1
    EPC.saved.antiquityLeadFinderTop = -1
    EPC.saved.antiquityLeadFinderWidth = 1180
    EPC.saved.antiquityLeadFinderHeight = 760
    self:RestorePlacement(true)
    self:ApplyLayout()
end

function F:SelectEntry(entry)
    self.selected = entry
    if not entry or not self.detailTitle then return end
    local statusColor = entry.haveLead and "|c55E86E" or (entry.complete and "|cA9B2C0" or "|cFFD36A")
    self.detailTitle:SetText(string.format("%s%s|r", statusColor, entry.name))
    local setText = entry.setName ~= "" and (" • Set: " .. entry.setName) or ""
    self.detailMeta:SetText(string.format("%s • Difficulty %d • Dug %d • Missing Codex %d • Scry: %s%s",
        entry.status, entry.difficulty, entry.recovered, entry.loreMissing, entry.scryZone, setText))
    local completeness = entry.sourceComplete and "documented" or "community / best-known"
    self.detailSource:SetText(string.format("FIND ZONE: %s\nSOURCE TYPE: %s\nSOURCE: %s\nLocation data: %s.",
        entry.findZone, entry.sourceType, entry.sourceLong, completeness))
end

function F:RefreshRows()
    local entries = self.entries or {}
    local pageCount = math.max(1, math.ceil(#entries / PAGE_SIZE))
    self.page = math.max(1, math.min(self.page or 1, pageCount))
    local first = ((self.page - 1) * PAGE_SIZE) + 1
    for i, row in ipairs(self.rows or {}) do
        local entry = entries[first + i - 1]
        row.entry = entry
        if entry then
            row.status:SetText(entry.status)
            row.name:SetText(entry.name)
            row.zone:SetText(entry.findZone)
            row.source:SetText(entry.sourceShort)
            row.dug:SetText(tostring(entry.recovered))
            row.expires:SetText(entry.haveLead and formatDuration(entry.expiration) or "-")
            local c = entry.haveLead and GREEN or (entry.complete and MUTED or (entry.status == "CODEX" and PURPLE or GOLD))
            row.status:SetColor(unpack(c))
            row.bg:SetCenterColor(unpack(i % 2 == 0 and PANEL_ALT or PANEL))
            row:SetHidden(false)
        else
            row:SetHidden(true)
        end
    end
    self.pageLabel:SetText(string.format("PAGE %d / %d", self.page, pageCount))
    self.countLabel:SetText(string.format("%d leads shown • %d source records integrated", #entries, number(D.recordCount)))
    self.previousButton:SetEnabled(self.page > 1)
    self.previousButton:SetAlpha(self.page > 1 and 1 or 0.35)
    self.nextButton:SetEnabled(self.page < pageCount)
    self.nextButton:SetAlpha(self.page < pageCount and 1 or 0.35)
    local filter = self.filter or "CAN_FIND"
    for key, item in pairs(self.filterButtons or {}) do
        item.bg:SetEdgeColor(unpack(key == filter and GOLD or EDGE))
    end
    self.zoneBg:SetEdgeColor(unpack(self.currentZoneOnly and CYAN or EDGE))
    self.zoneButton:SetText(self.currentZoneOnly and "CURRENT ZONE: ON" or "CURRENT ZONE")
    if self.selected then
        local found = nil
        for _, e in ipairs(entries) do if e.antiquityId == self.selected.antiquityId then found = e break end end
        if found then self:SelectEntry(found) else self.selected = nil end
    end
end

function F:Refresh()
    if not self.window or self.window:IsHidden() then return end
    self:RefreshData()
    self:RefreshRows()
end

function F:PreviousPage()
    self.page = math.max(1, (self.page or 1) - 1)
    self:RefreshRows()
end

function F:NextPage()
    local pageCount = math.max(1, math.ceil(#(self.entries or {}) / PAGE_SIZE))
    self.page = math.min(pageCount, (self.page or 1) + 1)
    self:RefreshRows()
end

function F:SetUIMode(active)
    if type(SetGameCameraUIMode) == "function" then pcall(SetGameCameraUIMode, active == true) end
    if SCENE_MANAGER and type(SCENE_MANAGER.SetInUIMode) == "function" then pcall(SCENE_MANAGER.SetInUIMode, SCENE_MANAGER, active == true) end
end

function F:Show()
    if not EPC.saved or EPC.saved.antiquityLeadFinderEnabled == false then
        if EPC.Print then EPC:Print("Antiquity Lead Finder is disabled in Suite settings.") end
        return
    end
    if not self.window and not self:CreateWindow() then return end
    self.filter = EPC.saved.antiquityLeadFinderFilter or "CAN_FIND"
    self.currentZoneOnly = EPC.saved.antiquityLeadFinderCurrentZone == true
    self.window:SetHidden(false)
    self:SetUIMode(true)
    self.ownsUIMode = true
    if type(PushActionLayerByName) == "function" and not self.actionLayerPushed then
        local ok = pcall(PushActionLayerByName, ACTION_LAYER)
        self.actionLayerPushed = ok
    end
    self:ApplyLayout()
    self:RefreshData()
    self:RefreshRows()
end

function F:Hide()
    if self.window then self.window:SetHidden(true) end
    if self.actionLayerPushed and type(RemoveActionLayerByName) == "function" then pcall(RemoveActionLayerByName, ACTION_LAYER) end
    self.actionLayerPushed = false
    if self.ownsUIMode then self:SetUIMode(false) end
    self.ownsUIMode = false
end

function F:Toggle()
    if not self.window or self.window:IsHidden() then self:Show() else self:Hide() end
end

function F:RefreshSettings()
    if EPC.saved and EPC.saved.antiquityLeadFinderEnabled == false then self:Hide() end
end

function F:RegisterEvents()
    local prefix = (EPC.name or "EAS") .. "_AntiquityLeadFinder"
    local function reg(suffix, eventId)
        if eventId ~= nil then
            EVENT_MANAGER:RegisterForEvent(prefix .. suffix, eventId, function() if F.window and not F.window:IsHidden() then F:Refresh() end end)
        end
    end
    reg("_LeadAcquired", EVENT_ANTIQUITY_LEAD_ACQUIRED)
    reg("_LeadExpired", EVENT_ANTIQUITY_LEAD_EXPIRED)
    reg("_Tracking", EVENT_ANTIQUITY_TRACKING_UPDATE)
    reg("_Scrying", EVENT_ANTIQUITY_SCRYING_RESULT)
    reg("_Player", EVENT_PLAYER_ACTIVATED)
end

function F:Initialize()
    self.page = 1
    self.filter = EPC.saved and EPC.saved.antiquityLeadFinderFilter or "CAN_FIND"
    self.currentZoneOnly = EPC.saved and EPC.saved.antiquityLeadFinderCurrentZone == true
    self:RegisterEvents()
    if type(ZO_CreateStringId) == "function" then
        ZO_CreateStringId("SI_BINDING_NAME_ESO_ADVENTURER_SUITE_ANTIQUITIES_CATEGORY", "ESO Adventurer Suite - Antiquities")
        ZO_CreateStringId("SI_BINDING_NAME_ESO_ADVENTURER_SUITE_ANTIQUITY_LEAD_FINDER", "Open / Close Antiquity Lead Finder")
    end
    if type(SLASH_COMMANDS) == "table" then
        SLASH_COMMANDS["/easleads"] = function() F:Show() end
    end
end

function ESOAdventurerSuite_ToggleAntiquityLeadFinder()
    if EPC.AntiquityLeadFinder then EPC.AntiquityLeadFinder:Toggle() end
end
