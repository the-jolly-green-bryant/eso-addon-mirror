local P = PBsUltraDetailedStats
P.UI = { column = 1, selected = {1, 1, 1, 1, 1}, offsets = {0, 0, 0, 0, 0}, showAll = false }
local U = P.UI
local W, H = 2000, 1040
local GOLD = {0.88, 0.78, 0.48, 1}
local WHITE = {0.92, 0.92, 0.88, 1}
local MUTED = {0.62, 0.65, 0.69, 1}
local BLUE, RED, GREEN = {0.35, 0.8, 1, 1}, {1, 0.42, 0.43, 1}, {0.48, 0.95, 0.43, 1}
-- Areas 1 and 2 share the first page; the others each take the full width.
local TITLES = {"装備", "ビルド", "詳細ステータス", "星座・CPパッシブ", "スキル"}
local AREAS = #TITLES
-- Fallback only: the game's own quality colours are used when the client provides them,
-- which is what makes a Mythic item orange rather than white.
local QUALITY = {[0] = MUTED, [1] = WHITE, [2] = GREEN, [3] = BLUE, [4] = {0.76, 0.5, 0.96, 1}, [5] = GOLD, [6] = {1, 0.55, 0.12, 1}}
local function qualityColor(quality)
    if quality and GetInterfaceColor and INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS then
        return {GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, quality)}
    end
    return QUALITY[quality] or WHITE
end
local function disciplineColor(kind)
    if kind == CHAMPION_DISCIPLINE_TYPE_COMBAT then return BLUE end
    if kind == CHAMPION_DISCIPLINE_TYPE_CONDITIONING then return RED end
    if kind == CHAMPION_DISCIPLINE_TYPE_WORLD then return GREEN end
end
local BUILD_UPDATE = P.name .. "BuildUI"
-- The whole of a list is on screen at once: a grid of small cells for the three text areas,
-- and rows for equipment, which carries an icon and a trait line of its own.
local GRID_COLUMNS, GRID_ROWS = 7, 32
local GRID_X, GRID_Y, GRID_W, GRID_H = 40, 308, 275, 18
local GEAR_ROWS, GEAR_Y, GEAR_H, GEAR_W = 17, 308, 30, 1094
-- Equipment and the build share the first page: equipment keeps the left of the screen, and
-- the build, which is short, gets two columns of large cells of its own beside it.
local BUILD_X, BUILD_Y, BUILD_W, BUILD_H, BUILD_ROWS, BUILD_COLUMNS = 1140, 308, 412, 30, 17, 2
local MEDIUM, BOLD = "$(GAMEPAD_MEDIUM_FONT)|20|soft-shadow-thin", "$(GAMEPAD_BOLD_FONT)|20|soft-shadow-thin"
local BAR_X, BAR_PITCH = 566, 140
local COMBAT_X, COMBAT_W = {1486, 1582, 1762, 1858}, {92, 176, 92, 100}
-- The description pane: taller on the first page, whose rows are 30 points, than under the
-- 32-row grid. {divider, text top, text space}.
local DETAIL_PAGE1, DETAIL_GRID = {826, 860, 170}, {898, 932, 96}
local DETAIL_SPLIT = 930
local function label(parent, x, y, w, h, size)
    local c = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    c:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    c:SetDimensions(w, h)
    c:SetFont("$(GAMEPAD_MEDIUM_FONT)|" .. size .. "|soft-shadow-thin")
    c:SetColor(unpack(WHITE))
    return c
end
local function line(parent, x, y, w, h, size)
    local c = label(parent, x, y, w, h, size)
    c:SetMaxLineCount(1)
    c:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    return c
end
local function background(parent, x, y, w, h, r, g, b, a)
    local c = WINDOW_MANAGER:CreateControl(nil, parent, CT_BACKDROP)
    c:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    c:SetDimensions(w, h)
    c:SetCenterColor(r, g, b, a)
    c:SetEdgeColor(0, 0, 0, 0)
    return c
end
local function texture(parent, x, y, size)
    local c = WINDOW_MANAGER:CreateControl(nil, parent, CT_TEXTURE)
    c:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    c:SetDimensions(size, size)
    return c
end
local function icon(control, path)
    control:SetHidden(not path or path == "")
    if path and path ~= "" then control:SetTexture(path) end
end
local function index(rows)
    local result = {}
    for _, entry in ipairs(rows) do result[entry.key] = entry end
    return result
end

function U:PageSize(column)
    if column == 1 then return GEAR_ROWS end
    if column == 2 then return BUILD_COLUMNS * BUILD_ROWS end
    return GRID_COLUMNS * GRID_ROWS
end
function U:Resize()
    if not self.root then return end
    local width, height = GuiRoot:GetDimensions()
    -- The extra vertical padding keeps the bottom rows clear of the keybind strip.
    self.root:SetScale(math.min(width / (W + 80), height / (H + 140)))
end

function U:BuildTasks()
    if self.buildTasks then return end
    self.buildTasks, self.buildIndex = {}, 1
    local root
    local function task(fn) self.buildTasks[#self.buildTasks + 1] = fn end
    task(function()
        root = WINDOW_MANAGER:CreateTopLevelWindow("PBsUltraDetailedStatsWindow")
        self.root = root
        root:SetDimensions(W, H)
        root:SetAnchor(CENTER, GuiRoot, CENTER, 0, -34)
        root:SetHidden(true)
        -- A continuous translucent sheet, like SuperStar, instead of four boxed panels.
        background(root, 0, 0, W, H, 0.025, 0.035, 0.07, 0.9)
        background(root, 36, 84, 1928, 1, unpack(GOLD))
        line(root, 40, 26, 720, 46, 36):SetText(P.title)
    end)
    task(function()
        self.nav = {}
        for i, title in ipairs(TITLES) do
            self.nav[i] = line(root, 844 + (i - 1) * 224, 36, 220, 32, 22)
            self.nav[i]:SetText(title)
        end
        self.identity = line(root, 42, 88, 1300, 32, 24)
        self.status = line(root, 1430, 94, 530, 22, 16)
        self.status:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        self.status:SetColor(unpack(MUTED))
        self.points = line(root, 1430, 226, 530, 32, 24)
        self.points:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        self.cpTotal = line(root, 1430, 260, 530, 32, 24)
        self.cpTotal:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    end)
    task(function()
        self.resources = {}
        -- Right-aligned columns; a single spaced string cannot line up in a proportional font.
        local columns = {{"spent", 196, 60, "配分"}, {"max", 262, 118, "最大値"}, {"regen", 386, 120, "戦闘中の再生"}}
        for _, column in ipairs(columns) do
            local head = line(root, column[2], 124, column[3], 20, 16)
            head:SetText(column[4])
            head:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            head:SetColor(unpack(MUTED))
        end
        for i, resource in ipairs({{"magicka", "マジカ", BLUE}, {"health", "体力", RED}, {"stamina", "スタミナ", GREEN}}) do
            local y = 148 + (i - 1) * 36
            local img = texture(root, 44, y + 2, 28)
            img:SetTexture("EsoUI/Art/CharacterWindow/Gamepad/gp_characterSheet_" .. resource[1] .. "Icon.dds")
            local name = line(root, 80, y, 112, 32, 23)
            name:SetText(resource[2]); name:SetColor(unpack(resource[3]))
            local values = {}
            for _, column in ipairs(columns) do
                values[column[1]] = line(root, column[2], y, column[3], 32, 23)
                values[column[1]]:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            end
            self.resources[i] = values
        end
    end)
    task(function()
        self.bars = {}
    end)
    for b = 1, 2 do
        local barIndex = b
        task(function()
            local b = barIndex
            local y = 126 + (b - 1) * 66
            self.bars[b] = {slots = {}, names = {}}
            self.bars[b].title = line(root, 516, y + 6, 48, 28, 20)
            for s = 1, 6 do
                local x = BAR_X + (s - 1) * BAR_PITCH + (s == 6 and 8 or 0)
                background(root, x - 1, y - 1, 38, 38, 0.3, 0.32, 0.35, 0.7)
                self.bars[b].slots[s] = texture(root, x, y, 36)
                -- The icon alone does not say which skill it is; the name goes under it.
                self.bars[b].names[s] = line(root, x - 2, y + 38, 138, 22, 15)
                self.bars[b].names[s]:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            end
        end)
    end
    task(function()
        for i, title in ipairs({"威力", "クリ値（率）", "貫通", "耐性"}) do
            local head = line(root, COMBAT_X[i], 124, COMBAT_W[i], 20, 15)
            head:SetText(title)
            head:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            head:SetColor(unpack(MUTED))
        end
        self.offense = {}
        for i, color in ipairs({BLUE, GREEN}) do
            local y = 148 + (i - 1) * 36
            line(root, 1430, y, 52, 30, 21):SetText(i == 1 and "呪文" or "武器")
            self.offense[i] = {}
            for j = 1, 4 do
                self.offense[i][j] = line(root, COMBAT_X[j], y, COMBAT_W[j], 30, 21)
                self.offense[i][j]:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
                self.offense[i][j]:SetColor(unpack(color))
            end
        end
    end)
    task(function()
        background(root, 36, 302, 1928, 1, 0.65, 0.67, 0.73, 0.3)
        self.listTitle = line(root, 44, 266, 900, 28, 19)
        -- One highlight, moved to the selected entry, instead of one behind every row.
        self.highlight = background(root, GRID_X, GRID_Y, GRID_W, GRID_H, 0.35, 0.37, 0.43, 0.32)
        self.gear = {}
        self.cells = {}
    end)
    for n = 1, GEAR_ROWS do
        local rowIndex = n
        task(function()
            local n = rowIndex
            local y = GEAR_Y + (n - 1) * GEAR_H
            local r = {}
            r.slot = line(root, 44, y + 2, 122, 27, 20)
            r.icon = texture(root, 170, y + 2, 26)
            r.level = line(root, 202, y + 4, 84, 24, 17)
            r.name = line(root, 292, y + 1, 440, 28, 21)
            r.subline = line(root, 742, y + 5, 262, 22, 15)
            r.subline:SetColor(unpack(MUTED))
            r.set = line(root, 1008, y + 4, 96, 24, 17)
            r.set:SetColor(unpack(GREEN))
            r.set:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            self.gear[n] = r
        end)
    end
    task(function() self.buildCells = {} end)
    for first = 1, BUILD_COLUMNS * BUILD_ROWS, 6 do
        local start = first
        task(function()
            for n = start, math.min(start + 5, BUILD_COLUMNS * BUILD_ROWS) do
                local x = BUILD_X + math.floor((n - 1) / BUILD_ROWS) * BUILD_W
                local y = BUILD_Y + ((n - 1) % BUILD_ROWS) * BUILD_H
                local cell = {icon = texture(root, x + 2, y + 3, 24), name = line(root, x + 32, y + 2, 276, 27, 20),
                    value = line(root, x + 312, y + 3, 92, 26, 19)}
                cell.value:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
                self.buildCells[n] = cell
            end
        end)
    end
    for first = 1, GRID_COLUMNS * GRID_ROWS, 9 do
        local start = first
        task(function()
            for n = start, math.min(start + 8, GRID_COLUMNS * GRID_ROWS) do
                local column = math.floor((n - 1) / GRID_ROWS)
                local x = GRID_X + column * GRID_W
                local y = GRID_Y + ((n - 1) % GRID_ROWS) * GRID_H
                local cell = {name = line(root, x + 4, y, 190, GRID_H, 14), value = line(root, x + 196, y, 74, GRID_H, 14)}
                cell.value:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
                self.cells[n] = cell
            end
        end)
    end
    task(function()
        self.detailDivider = background(root, 36, DETAIL_GRID[1], 1928, 1, unpack(GOLD))
        self.detailTitle = line(root, 44, DETAIL_GRID[1] + 6, 1080, 26, 20)
        self.detailTitle:SetColor(unpack(GOLD))
        self.hint = line(root, 1160, DETAIL_GRID[1] + 10, 804, 22, 14)
        self.hint:SetText("十字キー左右：領域   上下：項目   L1/R1：列を移動   L2/R2：説明の続き")
        self.hint:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        self.hint:SetColor(unpack(MUTED))
        -- A window of whole lines over the full text; it only clips. L2/R2 moves the text inside
        -- it by exactly one window, so no line is ever drawn cut in half. The labels keep a height
        -- of 0, which sizes them to their text: fixing the height to a measured value capped every
        -- later measurement at that value, and a first measurement of one line stuck for good.
        self.detailScroll = WINDOW_MANAGER:CreateControl("PBsUltraDetailedStatsDetailScroll", root, CT_SCROLL)
        self.detail = label(self.detailScroll, 0, 0, 1880, 0, 16)
        -- Equipment puts its set in a second column beside the item.
        self.detailSet = label(self.detailScroll, DETAIL_SPLIT - 44, 0, 1880 - (DETAIL_SPLIT - 44), 0, 16)
        self.detailSet:SetHidden(true)
        self.detailLine = math.floor(self.detail.GetFontHeight and self.detail:GetFontHeight() or 20)
        self:PlaceDetail(false)
    end)
end

-- Synchronous construction is used by the standalone test harness only.
function U:Create()
    if self.ready then return end
    self:BuildTasks()
    for _, task in ipairs(self.buildTasks) do task() end
    self.ready = true
    self:Resize()
    self.buildTasks = nil
end

function U:BeginCreate(onReady)
    if self.ready then onReady(); return end
    if self.buildError then error(self.buildError); return end
    self:BuildTasks()
    self.onReady = onReady
    -- One small construction stage per tick; no controls are created on load/show.
    EVENT_MANAGER:UnregisterForUpdate(BUILD_UPDATE)
    EVENT_MANAGER:RegisterForUpdate(BUILD_UPDATE, 32, function()
        local ok, message = pcall(self.buildTasks[self.buildIndex])
        if not ok then
            self:PauseCreate()
            self.buildError = "PBsUltraDetailedStats UI initialization failed: " .. tostring(message)
            error(self.buildError)
        end
        self.buildIndex = self.buildIndex + 1
        if self.buildIndex > #self.buildTasks then
            self.ready = true
            self.buildTasks = nil
            local callback = self.onReady
            self:PauseCreate()
            if callback then callback() end
        end
    end)
end

function U:PauseCreate()
    EVENT_MANAGER:UnregisterForUpdate(BUILD_UPDATE)
    self.onReady = nil
end

function U:Refresh()
    if not self.ready then return end
    local keys = {}
    for i = 1, AREAS do
        local old = self.data and self.data[i][self.selected[i]]
        keys[i] = old and old.key
    end
    self.data = P.Data.Collect(self.showAll)
    self.maps = {}
    for i = 1, AREAS do
        self.maps[i] = index(self.data[i])
        for n, entry in ipairs(self.data[i]) do
            if entry.key == keys[i] then self.selected[i] = n; break end
        end
        self.selected[i] = math.max(1, math.min(self.selected[i], #self.data[i]))
    end
    self.identity:SetText(P.Data.Identity())
    self.status:SetText(self.showAll and "未取得を含む全項目" or "取得済みのCP・スキル")
    self.points:SetText(GetAvailableSkillPoints() .. "  スキルポイント")
    self.cpTotal:SetText(GetUnitChampionPoints("player") .. "  チャンピオンポイント")
    self:Render()
end

function U:RenderOverview()
    local basics, skills = self.data.basics or {}, self.maps[5]
    local function value(key) return P.Data.Number(basics[key]) end
    for i, key in ipairs({"MAGICKA", "HEALTH", "STAMINA"}) do
        local values = self.resources[i]
        values.spent:SetText(value("attr" .. key))
        values.max:SetText(value(key .. "_MAX"))
        values.regen:SetText(value(key .. "_REGEN_COMBAT"))
    end
    for b, category in ipairs({HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP}) do
        local bar = self.bars[b]
        bar.title:SetText((b == 1 and "表" or "裏") .. (GetActiveHotbarCategory() == category and " ●" or ""))
        for s = 1, 6 do
            local entry = skills["bar" .. category .. ":" .. (s + 2)]
            icon(bar.slots[s], entry and entry.icon)
            bar.names[s]:SetText(entry and entry.name or "")
            bar.names[s]:SetColor(unpack(entry and entry.icon and WHITE or MUTED))
        end
    end
    for i, keys in ipairs({{"SPELL_POWER", "SPELL_CRITICAL", "SPELL_PENETRATION", "SPELL_RESIST"}, {"POWER", "CRITICAL_STRIKE", "PHYSICAL_PENETRATION", "PHYSICAL_RESIST"}}) do
        for j, key in ipairs(keys) do
            self.offense[i][j]:SetText(j == 2 and P.Data.Critical(basics[key]) or value(key))
        end
    end
end

function U:RenderGear(entries, offset)
    for n, r in ipairs(self.gear) do
        local entry = entries and entries[offset + n]
        r.slot:SetText(entry and entry.slotLabel or "")
        icon(r.icon, entry and entry.icon)
        r.level:SetText(entry and entry.level or "")
        r.name:SetText(entry and (entry.itemName or entry.name) or "")
        r.name:SetColor(unpack(entry and qualityColor(entry.quality) or WHITE))
        r.set:SetText(entry and entry.setText or "")
        r.subline:SetText(entry and entry.subline or "")
    end
end

-- Places entries column by column into capacity cells of the given column height. An entry
-- marked breakBefore starts a new column; gapBefore leaves one empty row above it, except at
-- the top of a column. Returns the entry for each cell, and the cell for each entry.
local function place(entries, offset, capacity, rows, gaps)
    local placed, cellFor, cursor, complete = {}, {}, 0, true
    for n = offset + 1, entries and #entries or 0 do
        local entry = entries[n]
        local row = cursor % rows
        if entry.breakBefore and row ~= 0 then cursor = cursor + rows - row
        elseif gaps and entry.gapBefore and row ~= 0 and row < rows - 1 then cursor = cursor + 1 end
        cursor = cursor + 1
        if cursor > capacity then complete = false; break end
        placed[cursor], cellFor[n] = entry, cursor
    end
    return placed, cellFor, complete
end
-- The blank rows are dropped rather than lose an entry when they would not all fit.
local function layout(entries, offset, capacity, rows)
    local placed, cellFor, complete = place(entries, offset, capacity, rows, true)
    if complete then return placed, cellFor end
    placed, cellFor = place(entries, offset, capacity, rows, false)
    return placed, cellFor
end
local function colors(entry)
    local color = entry and (disciplineColor(entry.discipline) or (entry.header and GOLD)) or WHITE
    return color, entry and (entry.discipline or entry.header) and color or MUTED
end

function U:RenderGrid(entries, offset)
    local placed, cellFor = layout(entries, offset, #self.cells, GRID_ROWS)
    for n, cell in ipairs(self.cells) do
        local entry = placed[n]
        local nameColor, valueColor = colors(entry)
        cell.name:SetText(entry and entry.name or "")
        cell.name:SetColor(unpack(nameColor))
        cell.value:SetText(entry and entry.value or "")
        cell.value:SetColor(unpack(valueColor))
    end
    return cellFor
end

function U:RenderBuild(entries, offset)
    local placed, cellFor = layout(entries, offset, #self.buildCells, BUILD_ROWS)
    for n, cell in ipairs(self.buildCells) do
        local entry = placed[n]
        local nameColor, valueColor = colors(entry)
        local font = entry and entry.header and BOLD or MEDIUM
        if cell.font ~= font then cell.name:SetFont(font); cell.font = font end
        -- A section title is short and its value long (取得 2 / 保有 2); an entry is the reverse.
        local wide = entry and entry.header or false
        if cell.wide ~= wide then
            cell.wide = wide
            local x, y = BUILD_X + math.floor((n - 1) / BUILD_ROWS) * BUILD_W, BUILD_Y + ((n - 1) % BUILD_ROWS) * BUILD_H
            cell.name:SetWidth(wide and 196 or 276)
            cell.value:ClearAnchors()
            cell.value:SetAnchor(TOPLEFT, self.root, TOPLEFT, x + (wide and 232 or 312), y + 3)
            cell.value:SetWidth(wide and 172 or 92)
        end
        icon(cell.icon, entry and entry.icon)
        cell.name:SetText(entry and entry.name or "")
        cell.name:SetColor(unpack(nameColor))
        cell.value:SetText(entry and entry.value or "")
        cell.value:SetColor(unpack(valueColor))
    end
    return cellFor
end

-- Everything fits on one screen in normal use; paging is the fallback for 全項目.
function U:Offset(column)
    local entries, selected = self.data[column], self.selected[column]
    local page = self:PageSize(column)
    local offset = math.min(self.offsets[column], math.max(0, #entries - page))
    if selected <= offset then offset = selected - 1 end
    if selected > offset + page then offset = selected - page end
    self.offsets[column] = offset
    return offset
end

function U:HighlightCell(position)
    self.highlight:SetDimensions(GRID_W, GRID_H)
    self.highlight:ClearAnchors()
    self.highlight:SetAnchor(TOPLEFT, self.root, TOPLEFT,
        GRID_X + math.floor((position - 1) / GRID_ROWS) * GRID_W, GRID_Y + ((position - 1) % GRID_ROWS) * GRID_H)
end

function U:Render()
    for i = 1, AREAS do
        self.nav[i]:SetColor(unpack(i == self.column and GOLD or MUTED))
    end
    local merged = self.column <= 2
    local entries, selected = self.data[self.column], self.selected[self.column]
    local page = self:PageSize(self.column)
    local offset = self:Offset(self.column)
    self:RenderOverview()
    local cellFor
    if merged then
        self:RenderGear(self.data[1], self:Offset(1))
        cellFor = self:RenderBuild(self.data[2], self:Offset(2))
        self.buildCellFor = cellFor
        self:RenderGrid(nil, 0)
    else
        self:RenderGear(nil, 0)
        self:RenderBuild(nil, 0)
        cellFor = self:RenderGrid(entries, offset)
    end
    local title = string.format("%s   %d / %d", TITLES[self.column], selected, #entries)
    if #entries > page then title = title .. string.format("（%d〜%d を表示）", offset + 1, math.min(offset + page, #entries)) end
    self.listTitle:SetText(title)
    local position = selected - offset
    if self.column == 1 and position >= 1 and position <= page then
        self.highlight:SetDimensions(GEAR_W, GEAR_H)
        self.highlight:ClearAnchors()
        self.highlight:SetAnchor(TOPLEFT, self.root, TOPLEFT, 36, GEAR_Y + (position - 1) * GEAR_H)
        self.highlight:SetHidden(false)
    elseif self.column == 2 and cellFor[selected] then
        local n = cellFor[selected]
        self.highlight:SetDimensions(BUILD_W - 4, BUILD_H)
        self.highlight:ClearAnchors()
        self.highlight:SetAnchor(TOPLEFT, self.root, TOPLEFT,
            BUILD_X + math.floor((n - 1) / BUILD_ROWS) * BUILD_W, BUILD_Y + ((n - 1) % BUILD_ROWS) * BUILD_H)
        self.highlight:SetHidden(false)
    elseif self.column ~= 1 and cellFor[selected] then
        self:HighlightCell(cellFor[selected])
        self.highlight:SetHidden(false)
    else
        self.highlight:SetHidden(true)
    end
    local entry = entries[selected]
    local key = self.column .. ":" .. (entry and entry.key or "")
    self:PlaceDetail(merged)
    local text = entry and entry.detail or "この項目に表示できる情報はありません。"
    local setText = entry and entry.detailSet
    if key ~= self.detailKey or text ~= self.detailText or setText ~= self.detailSetText then
        if key ~= self.detailKey then self.detailOffset = 0 end
        self.detailKey, self.detailText, self.detailSetText = key, text, setText
        self.detail:SetText(text)
        self.detail:SetWidth(setText and (DETAIL_SPLIT - 44 - 40) or 1880)
        self.detailSet:SetText(setText or "")
        self.detailSet:SetHidden(not setText)
    end
    local pages = self:DetailPages()
    self.detailOffset = math.min(self.detailOffset or 0, pages - 1)
    local top = -self.detailOffset * self.detailPage
    self.detail:ClearAnchors()
    self.detail:SetAnchor(TOPLEFT, self.detailScroll, TOPLEFT, 0, top)
    self.detailSet:ClearAnchors()
    self.detailSet:SetAnchor(TOPLEFT, self.detailScroll, TOPLEFT, DETAIL_SPLIT - 44, top)
    local current = self.detailOffset + 1
    self.detailTitle:SetText((entry and (entry.name .. "   " .. entry.value) or "詳細") ..
        (pages > 1 and string.format("   （説明 %d/%d・L2/R2で続き）", current, pages) or ""))
end

function U:MoveColumn(delta)
    if not self.ready then return end
    self.column = (self.column - 1 + delta) % AREAS + 1
    self:Render()
end
function U:MoveRow(delta)
    if not self.ready then return end
    self.selected[self.column] = math.max(1, math.min(#self.data[self.column], self.selected[self.column] + delta))
    self:Render()
end
function U:PlaceDetail(firstPage)
    if self.detailFirstPage == firstPage then return end
    self.detailFirstPage = firstPage
    local spec = firstPage and DETAIL_PAGE1 or DETAIL_GRID
    local function move(control, x, y) control:ClearAnchors(); control:SetAnchor(TOPLEFT, self.root, TOPLEFT, x, y) end
    move(self.detailDivider, 36, spec[1])
    move(self.detailTitle, 44, spec[1] + 6)
    move(self.hint, 1160, spec[1] + 10)
    move(self.detailScroll, 44, spec[2])
    self.detailPage = math.max(1, math.floor(spec[3] / self.detailLine)) * self.detailLine
    self.detailScroll:SetDimensions(1910, self.detailPage)
end

-- The text height is measured when it is needed, not right after SetText: the client lays text
-- out a frame later, and a height read too early made every description one page long.
function U:DetailPages()
    local height = self.detail:GetTextHeight()
    if not self.detailSet:IsHidden() then height = math.max(height, self.detailSet:GetTextHeight()) end
    return math.max(1, math.ceil(height / self.detailPage))
end

-- Turns the description by one whole window of lines. The window (a scroll control) only clips;
-- the text is moved by its anchor, so nothing depends on the scroll control's own extents.
function U:PageDetail(delta)
    if not self.ready then return end
    self.detailOffset = math.max(0, math.min(self:DetailPages() - 1, (self.detailOffset or 0) + delta))
    self:Render()
end
-- On the first page L1/R1 walks the columns on screen — equipment, then the build's two
-- columns — keeping the row, since all three share the same 30-point rows. On the grid pages it
-- jumps one grid column within the area.
function U:MoveGridColumn(delta)
    if not self.ready then return end
    if self.column > 2 then return self:MoveRow(delta * GRID_ROWS) end
    local row, column
    if self.column == 1 then
        row, column = self.selected[1] - self.offsets[1] - 1, -1
    else
        local cell = (self.buildCellFor or {})[self.selected[2]] or 1
        row, column = (cell - 1) % BUILD_ROWS, math.floor((cell - 1) / BUILD_ROWS)
    end
    local target = column + delta
    if target < -1 or target >= BUILD_COLUMNS then return end
    if target == -1 then
        self.column = 1
        self.selected[1] = math.max(1, math.min(#self.data[1], self.offsets[1] + row + 1))
        return self:Render()
    end
    -- The entry on that row of the target column, or the nearest one above it (a blank
    -- separator row has none), or failing that the column's first entry.
    local best, bestRow
    for n, cell in pairs(self.buildCellFor or {}) do
        local r, c = (cell - 1) % BUILD_ROWS, math.floor((cell - 1) / BUILD_ROWS)
        if c == target then
            local better = not best or (r <= row and (bestRow > row or r > bestRow)) or (bestRow > row and r < bestRow)
            if better then best, bestRow = n, r end
        end
    end
    if not best then return end
    self.column, self.selected[2] = 2, best
    self:Render()
end
function U:Keybinds()
    local group = {alignment = KEYBIND_STRIP_ALIGN_LEFT}
    local function bind(key, name, callback, ethereal)
        group[#group + 1] = {keybind = key, name = name, callback = callback, ethereal = ethereal}
    end
    bind("UI_SHORTCUT_NEGATIVE", "戻る", function() SCENE_MANAGER:HideCurrentScene() end)
    bind("UI_SHORTCUT_SECONDARY", "再取得", function() self:Refresh() end)
    bind("UI_SHORTCUT_TERTIARY", "取得済み / 全項目", function() self.showAll = not self.showAll; self:Refresh() end)
    bind("UI_SHORTCUT_INPUT_LEFT", "前の領域", function() self:MoveColumn(-1) end, true)
    bind("UI_SHORTCUT_INPUT_RIGHT", "次の領域", function() self:MoveColumn(1) end, true)
    bind("UI_SHORTCUT_INPUT_UP", "前の項目", function() self:MoveRow(-1) end, true)
    bind("UI_SHORTCUT_INPUT_DOWN", "次の項目", function() self:MoveRow(1) end, true)
    bind("UI_SHORTCUT_LEFT_SHOULDER", "前の列", function() self:MoveGridColumn(-1) end, true)
    bind("UI_SHORTCUT_RIGHT_SHOULDER", "次の列", function() self:MoveGridColumn(1) end, true)
    bind("UI_SHORTCUT_LEFT_TRIGGER", "説明を戻す", function() self:PageDetail(-1) end, true)
    bind("UI_SHORTCUT_RIGHT_TRIGGER", "説明の続き", function() self:PageDetail(1) end, true)
    return group
end
