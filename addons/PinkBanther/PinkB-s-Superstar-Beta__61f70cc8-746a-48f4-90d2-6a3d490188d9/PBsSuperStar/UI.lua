local P = PBsSuperStar
P.UI = { column = 1, selected = {1, 1, 1, 1}, offsets = {0, 0, 0, 0}, showAll = false }
local U = P.UI
local W, H = 2000, 1040
local GOLD = {0.88, 0.78, 0.48, 1}
local WHITE = {0.92, 0.92, 0.88, 1}
local MUTED = {0.62, 0.65, 0.69, 1}
local BLUE, RED, GREEN = {0.35, 0.8, 1, 1}, {1, 0.42, 0.43, 1}, {0.48, 0.95, 0.43, 1}
local TITLES = {"装備", "詳細ステータス", "星座・CPパッシブ", "スキル"}
local QUALITY = {[0] = MUTED, [1] = WHITE, [2] = GREEN, [3] = BLUE, [4] = {0.76, 0.5, 0.96, 1}, [5] = GOLD}
local BUILD_UPDATE = P.name .. "BuildUI"
-- The whole of a list is on screen at once: a grid of small cells for the three text areas,
-- and full-width rows for equipment, which carries an icon and two lines of its own.
local GRID_COLUMNS, GRID_ROWS = 7, 32
local GRID_X, GRID_Y, GRID_W, GRID_H = 40, 308, 275, 18
local GEAR_ROWS, GEAR_Y, GEAR_H, GEAR_W = 17, 308, 34, 1094
-- Equipment and the detailed statistics share one page: equipment keeps the left of the
-- screen, and the statistics fill the grid's last three columns beside it.
local STATS_BASE, STATS_COLUMNS = 4, 3
local BAR_X, BAR_PITCH = 534, 141
local DETAIL_Y, DETAIL_SPACE = 932, 100
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
    if column == 2 then return STATS_COLUMNS * GRID_ROWS end
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
        root = WINDOW_MANAGER:CreateTopLevelWindow("PBsSuperStarWindow")
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
            self.nav[i] = line(root, 964 + (i - 1) * 250, 38, 246, 30, 21)
            self.nav[i]:SetText(title)
        end
        self.identity = line(root, 42, 90, 1300, 28, 21)
        self.status = line(root, 1400, 96, 560, 20, 14)
        self.status:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        self.status:SetColor(unpack(MUTED))
        self.points = line(root, 1400, 240, 560, 28, 21)
        self.points:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        self.cpTotal = line(root, 1400, 268, 560, 28, 21)
        self.cpTotal:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        self.masteryLine = line(root, 44, 244, 900, 22, 15)
    end)
    task(function()
        self.resources = {}
        -- Right-aligned columns; a single spaced string cannot line up in a proportional font.
        local columns = {{"spent", 186, 58, "配分"}, {"max", 250, 100, "最大値"}, {"regen", 356, 104, "戦闘中の再生"}}
        for _, column in ipairs(columns) do
            local head = line(root, column[2], 124, column[3], 18, 14)
            head:SetText(column[4])
            head:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            head:SetColor(unpack(MUTED))
        end
        for i, resource in ipairs({{"magicka", "マジカ", BLUE}, {"health", "体力", RED}, {"stamina", "スタミナ", GREEN}}) do
            local y = 142 + (i - 1) * 30
            local img = texture(root, 44, y + 1, 24)
            img:SetTexture("EsoUI/Art/CharacterWindow/Gamepad/gp_characterSheet_" .. resource[1] .. "Icon.dds")
            local name = line(root, 76, y, 104, 26, 19)
            name:SetText(resource[2]); name:SetColor(unpack(resource[3]))
            local values = {}
            for _, column in ipairs(columns) do
                values[column[1]] = line(root, column[2], y, column[3], 26, 19)
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
            local y = 128 + (b - 1) * 58
            self.bars[b] = {slots = {}, names = {}}
            self.bars[b].title = line(root, 480, y + 6, 50, 24, 17)
            for s = 1, 6 do
                local x = BAR_X + (s - 1) * BAR_PITCH + (s == 6 and 8 or 0)
                background(root, x - 1, y - 1, 34, 34, 0.3, 0.32, 0.35, 0.7)
                self.bars[b].slots[s] = texture(root, x, y, 32)
                -- The icon alone does not say which skill it is; the name goes under it.
                self.bars[b].names[s] = line(root, x - 4, y + 34, 138, 18, 13)
                self.bars[b].names[s]:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            end
        end)
    end
    task(function()
        for i, title in ipairs({"威力", "クリ値", "貫通", "耐性"}) do
            local head = line(root, 1470 + (i - 1) * 124, 124, 116, 18, 13)
            head:SetText(title)
            head:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            head:SetColor(unpack(MUTED))
        end
        self.offense = {}
        for i, color in ipairs({BLUE, GREEN}) do
            local y = 146 + (i - 1) * 30
            line(root, 1406, y, 58, 26, 18):SetText(i == 1 and "呪文" or "武器")
            self.offense[i] = {}
            for j = 1, 4 do
                self.offense[i][j] = line(root, 1470 + (j - 1) * 124, y, 116, 26, 19)
                self.offense[i][j]:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
                self.offense[i][j]:SetColor(unpack(color))
            end
        end
    end)
    task(function()
        background(root, 36, 302, 1928, 1, 0.65, 0.67, 0.73, 0.3)
        self.listTitle = line(root, 44, 270, 900, 26, 17)
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
            r.slot = line(root, 44, y + 5, 118, 24, 17)
            r.icon = texture(root, 168, y + 5, 24)
            r.level = line(root, 198, y + 7, 78, 22, 15)
            r.name = line(root, 284, y + 4, 420, 24, 18)
            r.subline = line(root, 712, y + 8, 268, 20, 12)
            r.subline:SetColor(unpack(MUTED))
            r.set = line(root, 986, y + 7, 118, 22, 15)
            r.set:SetColor(unpack(GREEN))
            r.set:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            self.gear[n] = r
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
        background(root, 36, 898, 1928, 1, unpack(GOLD))
        self.detailTitle = line(root, 44, 904, 1080, 26, 20)
        self.detailTitle:SetColor(unpack(GOLD))
        local hint = line(root, 1160, 908, 804, 22, 14)
        hint:SetText("十字キー左右：領域   上下：項目   L1/R1・LB/RB：列を移動")
        hint:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        hint:SetColor(unpack(MUTED))
        -- As many whole lines as the space below holds: nothing scrolls, nothing is
        -- half-drawn, and the text cannot run past the bottom of the window.
        self.detail = label(root, 44, DETAIL_Y, 1910, 0, 16)
        local lineHeight = math.floor(self.detail.GetFontHeight and self.detail:GetFontHeight() or 20)
        local lines = math.max(1, math.floor(DETAIL_SPACE / lineHeight))
        self.detail:SetMaxLineCount(lines)
        self.detail:SetHeight(lines * lineHeight)
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
            self.buildError = "PBsSuperStar UI initialization failed: " .. tostring(message)
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
    for i = 1, 4 do
        local old = self.data and self.data[i][self.selected[i]]
        keys[i] = old and old.key
    end
    self.data = P.Data.Collect(self.showAll)
    self.maps = {}
    for i = 1, 4 do
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
    local stats, skills = self.maps[2], self.maps[4]
    local function value(key) return stats[key] and stats[key].value or "—" end
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
        for j, key in ipairs(keys) do self.offense[i][j]:SetText(value(key)) end
    end
    -- Class Mastery passives: bought with their own points, so they are counted separately.
    local mastery = self.data[4].mastery or {}
    self.masteryLine:SetText(mastery.subclassed and "クラスマスタリー：サブクラス使用中は選択不可"
        or string.format("クラスマスタリー　取得 %d / 保有ポイント %d", #mastery, mastery.points or 0))
    self.masteryLine:SetColor(unpack(mastery.subclassed and MUTED or GOLD))
end

function U:RenderGear(entries, offset)
    for n, r in ipairs(self.gear) do
        local entry = entries and entries[offset + n]
        r.slot:SetText(entry and entry.slotLabel or "")
        icon(r.icon, entry and entry.icon)
        r.level:SetText(entry and entry.level or "")
        r.name:SetText(entry and (entry.itemName or entry.name) or "")
        r.name:SetColor(unpack(entry and QUALITY[entry.quality] or WHITE))
        r.set:SetText(entry and entry.setText or "")
        r.subline:SetText(entry and entry.subline or "")
    end
end

-- base is the first grid column the list may use; the cells outside it are cleared.
function U:RenderGrid(entries, offset, base, columns)
    local first, last = base * GRID_ROWS, (base + columns) * GRID_ROWS
    for n, cell in ipairs(self.cells) do
        local entry = entries and n > first and n <= last and entries[offset + n - first]
        cell.name:SetText(entry and entry.name or "")
        cell.name:SetColor(unpack(entry and entry.header and GOLD or WHITE))
        cell.value:SetText(entry and entry.value or "")
        cell.value:SetColor(unpack(entry and entry.header and GOLD or MUTED))
    end
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
    self.highlight:SetAnchor(TOPLEFT, self.root, TOPLEFT,
        GRID_X + math.floor((position - 1) / GRID_ROWS) * GRID_W, GRID_Y + ((position - 1) % GRID_ROWS) * GRID_H)
end

function U:Render()
    for i = 1, 4 do
        self.nav[i]:SetColor(unpack(i == self.column and GOLD or MUTED))
    end
    local merged = self.column <= 2
    local entries, selected = self.data[self.column], self.selected[self.column]
    local page = self:PageSize(self.column)
    local offset = self:Offset(self.column)
    self:RenderOverview()
    if merged then
        self:RenderGear(self.data[1], self:Offset(1))
        self:RenderGrid(self.data[2], self:Offset(2), STATS_BASE, STATS_COLUMNS)
    else
        self:RenderGear(nil, 0)
        self:RenderGrid(entries, offset, 0, GRID_COLUMNS)
    end
    local title = string.format("%s   %d / %d", TITLES[self.column], selected, #entries)
    if #entries > page then title = title .. string.format("（%d〜%d を表示）", offset + 1, math.min(offset + page, #entries)) end
    self.listTitle:SetText(title)
    local position = selected - offset
    if position >= 1 and position <= page and #entries > 0 then
        if self.column == 1 then
            self.highlight:SetDimensions(GEAR_W, GEAR_H)
            self.highlight:SetAnchor(TOPLEFT, self.root, TOPLEFT, 36, GEAR_Y + (position - 1) * GEAR_H)
        elseif self.column == 2 then
            self:HighlightCell(STATS_BASE * GRID_ROWS + position)
        else
            self:HighlightCell(position)
        end
        self.highlight:SetHidden(false)
    else
        self.highlight:SetHidden(true)
    end
    local entry = entries[selected]
    self.detailTitle:SetText(entry and (entry.name .. "   " .. entry.value) or "詳細")
    local text = entry and entry.detail or "この項目に表示できる情報はありません。"
    if text ~= self.detailText then
        self.detailText = text
        self.detail:SetText(text)
    end
end

function U:MoveColumn(delta)
    if not self.ready then return end
    self.column = (self.column - 1 + delta) % 4 + 1
    self:Render()
end
function U:MoveRow(delta)
    if not self.ready then return end
    self.selected[self.column] = math.max(1, math.min(#self.data[self.column], self.selected[self.column] + delta))
    self:Render()
end
function U:MoveGridColumn(delta)
    if not self.ready then return end
    self:MoveRow(delta * (self.column == 1 and GEAR_ROWS or GRID_ROWS))
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
    return group
end
