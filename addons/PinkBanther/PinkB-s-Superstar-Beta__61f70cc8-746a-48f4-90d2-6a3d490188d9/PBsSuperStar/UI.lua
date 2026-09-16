local P = PBsSuperStar
P.UI = { column = 1, selected = {1, 1, 1, 1}, offsets = {0, 0, 0, 0}, showAll = false }
local U = P.UI
local W, H = 1800, 1000
local GOLD = {0.88, 0.78, 0.48, 1}
local WHITE = {0.92, 0.92, 0.88, 1}
local MUTED = {0.62, 0.65, 0.69, 1}
local BLUE, RED, GREEN = {0.35, 0.8, 1, 1}, {1, 0.42, 0.43, 1}, {0.48, 0.95, 0.43, 1}
local TITLES = {"装備", "詳細ステータス", "星座・CPパッシブ", "スキル"}
local QUALITY = {[0] = MUTED, [1] = WHITE, [2] = GREEN, [3] = BLUE, [4] = {0.76, 0.5, 0.96, 1}, [5] = GOLD}
local BUILD_UPDATE = P.name .. "BuildUI"
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

function U:PageSize(column) return column == 1 and 14 or 5 end
function U:Resize()
    if not self.root then return end
    local width, height = GuiRoot:GetDimensions()
    self.root:SetScale(math.min(width / (W + 100), height / (H + 100)))
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
        root:SetAnchor(CENTER, GuiRoot, CENTER, 0, -12)
        root:SetHidden(true)
        -- A continuous translucent sheet, like SuperStar, instead of four boxed panels.
        background(root, 0, 0, W, H, 0.025, 0.035, 0.07, 0.9)
        background(root, 36, 82, 1728, 1, unpack(GOLD))
        line(root, 40, 27, 720, 48, 38):SetText(P.title)
    end)
    task(function()
        self.nav = {}
        for i, title in ipairs(TITLES) do
            self.nav[i] = line(root, 850 + (i - 1) * 228, 40, 225, 32, 23)
            self.nav[i]:SetText(title)
        end
        self.identity = label(root, 42, 102, 620, 62, 23)
        self.identity:SetMaxLineCount(2)
        self.status = line(root, 1250, 185, 510, 23, 17)
        self.status:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        self.points = line(root, 1250, 103, 510, 38, 27)
        self.points:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        self.cpTotal = line(root, 1250, 143, 510, 38, 27)
        self.cpTotal:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    end)
    task(function()
        self.resources = {}
        for i, resource in ipairs({{"magicka", "マジカ", BLUE}, {"health", "体力", RED}, {"stamina", "スタミナ", GREEN}}) do
            local y = 188 + (i - 1) * 39
            local img = texture(root, 44, y, 31)
            img:SetTexture("EsoUI/Art/CharacterWindow/Gamepad/gp_characterSheet_" .. resource[1] .. "Icon.dds")
            local name = line(root, 83, y, 98, 32, 23)
            name:SetText(resource[2]); name:SetColor(unpack(resource[3]))
            self.resources[i] = line(root, 178, y, 450, 32, 24)
        end
        line(root, 180, 169, 450, 20, 16):SetText("配分      最大値          戦闘中の再生")

    end)
    task(function()
        self.bars = {}
    end)
    for b = 1, 2 do
        local barIndex = b
        task(function()
            local b = barIndex
            local y = 104 + (b - 1) * 59
            self.bars[b] = {slots = {}}
            self.bars[b].title = line(root, 672, y + 12, 76, 28, 20)
            for s = 1, 6 do
                local x = 754 + (s - 1) * 57 + (s == 6 and 14 or 0)
                background(root, x - 1, y - 1, 50, 50, 0.3, 0.32, 0.35, 0.7)
                self.bars[b].slots[s] = texture(root, x, y, 48)
            end
        end)
    end

    task(function()
        for i, title in ipairs({"威力", "クリ値", "貫通", "耐性"}) do
            line(root, 735 + (i - 1) * 91, 229, 89, 25, 18):SetText(title)
        end
    end)
    task(function()
        self.offense = {}
        for i, color in ipairs({BLUE, GREEN}) do
            local y = 255 + (i - 1) * 29
            line(root, 675, y, 58, 28, 21):SetText(i == 1 and "呪文" or "武器")
            self.offense[i] = {}
            for j = 1, 4 do
                self.offense[i][j] = line(root, 735 + (j - 1) * 91, y, 89, 28, 22)
                self.offense[i][j]:SetColor(unpack(color))
            end
        end

    end)
    task(function()
        self.gearTitle = line(root, 42, 310, 1000, 28, 22)
        self.gear = {}
    end)
    for n = 1, 14 do
        local rowIndex = n
        task(function()
            local n = rowIndex
            local y = 341 + (n - 1) * 38
            local r = {}
            r.highlight = background(root, 36, y, 1050, 38, 0.35, 0.37, 0.43, 0.32)
            r.slot = line(root, 44, y + 4, 164, 30, 23)
            r.icon = texture(root, 213, y + 3, 30)
            r.level = line(root, 251, y + 2, 88, 27, 21)
            r.name = line(root, 345, y - 1, 589, 27, 23)
            r.set = line(root, 939, y + 1, 139, 28, 20)
            r.set:SetColor(unpack(GREEN))
            r.subline = line(root, 345, y + 23, 730, 18, 16)
            r.subline:SetColor(unpack(MUTED))
            self.gear[n] = r
        end)
    end

    task(function()
        self.champion = {}
    end)
    for n = 1, 3 do
        local groupIndex = n
        task(function()
            local n = groupIndex
            local y = 215 + (n - 1) * 109
            local group = {slots = {}}
            group.title = line(root, 1142, y, 616, 32, 26)
            background(root, 1142, y + 33, 615, 1, 0.65, 0.67, 0.73, 0.3)
            for s = 1, 4 do
                local x = 1142 + ((s - 1) % 2) * 316
                local sy = y + 41 + math.floor((s - 1) / 2) * 28
                group.slots[s] = line(root, x, sy, 302, 26, 20)
            end
            self.champion[n] = group
        end)
    end

    task(function()
        self.effectsTitle = line(root, 1142, 552, 615, 29, 23)
        self.effectsTitle:SetText("ムンダス・食事・有効な効果")
        self.effects = {}
        for n = 1, 3 do
            local y = 588 + (n - 1) * 27
            self.effects[n] = {icon = texture(root, 1142, y, 24), name = line(root, 1176, y, 581, 26, 21)}
        end

    end)
    task(function()
        self.inspectTitle = line(root, 1142, 678, 615, 30, 23)
        background(root, 1142, 711, 615, 1, 0.65, 0.67, 0.73, 0.3)
        self.inspect = {}
        for n = 1, 5 do
            local y = 719 + (n - 1) * 31
            self.inspect[n] = {
                highlight = background(root, 1136, y, 628, 30, 0.35, 0.37, 0.43, 0.32),
                name = line(root, 1142, y, 457, 29, 21), value = line(root, 1604, y, 151, 29, 21),
            }
            self.inspect[n].value:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        end
    end)
    task(function()
        background(root, 36, 890, 1728, 1, unpack(GOLD))
        self.detailTitle = line(root, 44, 899, 1710, 29, 23)
        self.detailTitle:SetColor(unpack(GOLD))
        self.detailScroll = WINDOW_MANAGER:CreateControl("PBsSuperStarDetailScroll", root, CT_SCROLL)
        self.detailScroll:SetAnchor(TOPLEFT, root, TOPLEFT, 44, 935)
        self.detailScroll:SetDimensions(1710, 40)
        self.detail = label(self.detailScroll, 0, 0, 1680, 0, 21)
        line(root, 44, 978, 1710, 22, 16):SetText("十字キー左右：装備 / 詳細ステータス / CP / スキル    上下：項目    L1/R1・LB/RB：ページ    L2/R2・LT/RT：説明スクロール")
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
        self.resources[i]:SetText(value("attr" .. key) .. "       " .. value(key .. "_MAX") .. "       ▲" .. value(key .. "_REGEN_COMBAT"))
    end
    for b, category in ipairs({HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP}) do
        local bar = self.bars[b]
        bar.title:SetText((b == 1 and "表" or "裏") .. (GetActiveHotbarCategory() == category and " ●" or ""))
        for s = 1, 6 do
            local entry = skills["bar" .. category .. ":" .. (s + 2)]
            icon(bar.slots[s], entry and entry.icon)
        end
    end
    for i, keys in ipairs({{"SPELL_POWER", "SPELL_CRITICAL", "SPELL_PENETRATION", "SPELL_RESIST"}, {"POWER", "CRITICAL_STRIKE", "PHYSICAL_PENETRATION", "PHYSICAL_RESIST"}}) do
        for j, key in ipairs(keys) do self.offense[i][j]:SetText(value(key)) end
    end
    local groups = self.data[3].disciplines or {}
    for n, controls in ipairs(self.champion) do
        local group = groups[n]
        local color = GOLD
        if group then
            if group.kind == CHAMPION_DISCIPLINE_TYPE_COMBAT then color = BLUE
            elseif group.kind == CHAMPION_DISCIPLINE_TYPE_CONDITIONING then color = RED
            elseif group.kind == CHAMPION_DISCIPLINE_TYPE_WORLD then color = GREEN end
        end
        controls.title:SetColor(unpack(color))
        controls.title:SetText(group and (group.name .. "  " .. group.points) or (n == 1 and "星座情報なし" or ""))
        local slots = {}
        for _, entry in ipairs(self.data[3]) do
            if group and entry.disciplineId == group.id then slots[#slots + 1] = entry end
        end
        for s, c in ipairs(controls.slots) do
            local entry = slots[s]
            c:SetColor(unpack(color))
            c:SetText(entry and ("○ " .. entry.name .. "  " .. entry.value) or "")
        end
    end
    local effects = {}
    for _, entry in ipairs(self.data[2]) do
        if entry.key:sub(1, 4) == "buff" then
            -- Mundus first; every effect remains reachable through detailed stats.
            if entry.name:find("ムンダス：", 1, true) then table.insert(effects, 1, entry)
            else effects[#effects + 1] = entry end
        end
    end
    self.effectsTitle:SetText("ムンダス・食事・有効な効果  " .. #effects)
    for n, c in ipairs(self.effects) do
        local entry = effects[n]
        icon(c.icon, entry and entry.icon)
        c.name:SetText(entry and entry.name or (n == 1 and "有効な効果なし" or ""))
    end
end

function U:Render()
    for i = 1, 4 do
        local count, selected, page = #self.data[i], self.selected[i], self:PageSize(i)
        local offset = math.min(self.offsets[i], math.max(0, count - page))
        if selected <= offset then offset = selected - 1 end
        if selected > offset + page then offset = selected - page end
        self.offsets[i] = offset
        self.nav[i]:SetColor(unpack(i == self.column and GOLD or MUTED))
    end
    self:RenderOverview()
    self.gearTitle:SetText(string.format("装備   %d / %d", self.selected[1], #self.data[1]))
    self.gearTitle:SetColor(unpack(self.column == 1 and GOLD or WHITE))
    for n, r in ipairs(self.gear) do
        local entry = self.data[1][self.offsets[1] + n]
        r.highlight:SetHidden(not entry or self.column ~= 1 or self.offsets[1] + n ~= self.selected[1])
        r.slot:SetText(entry and entry.slotLabel or "")
        icon(r.icon, entry and entry.icon)
        r.level:SetText(entry and entry.level or "")
        r.name:SetText(entry and (entry.itemName or entry.name) or "")
        r.name:SetColor(unpack(entry and QUALITY[entry.quality] or WHITE))
        r.set:SetText(entry and entry.setText or "")
        r.subline:SetText(entry and entry.subline or "")
    end
    -- Additional lists share the lower-right space, without replacing the overview.
    local section = self.column == 1 and 4 or self.column
    local entries = self.data[section]
    local inspectOffset = self.offsets[section]
    if self.column == 1 then
        entries = {}
        for _, entry in ipairs(self.data[4]) do
            if entry.key:sub(1, 4) == "line" or entry.key:sub(1, 5) == "skill" or entry.key == "error" then entries[#entries + 1] = entry end
        end
        inspectOffset = 0
    end
    self.inspectTitle:SetText(string.format("%s   %d / %d", TITLES[section], self.selected[section], #entries))
    if self.column == 1 then self.inspectTitle:SetText("取得スキル・パッシブ") end
    self.inspectTitle:SetColor(unpack(self.column == section and GOLD or WHITE))
    for n, r in ipairs(self.inspect) do
        local entry = entries[inspectOffset + n]
        r.highlight:SetHidden(not entry or self.column ~= section or self.offsets[section] + n ~= self.selected[section])
        r.name:SetText(entry and entry.name or "")
        r.name:SetWidth(entry and entry.value ~= "" and 457 or 615)
        r.name:SetColor(unpack(entry and entry.header and GOLD or WHITE))
        r.value:SetText(entry and entry.value or "")
    end
    local entry = self.data[self.column][self.selected[self.column]]
    local key = self.column .. ":" .. (entry and entry.key or "")
    if key ~= self.detailKey then self.detailScroll:SetVerticalScroll(0); self.detailKey = key end
    self.detailTitle:SetText(entry and (entry.name .. "   " .. entry.value) or "詳細")
    local text = entry and entry.detail or "この項目に表示できる情報はありません。"
    if text ~= self.detailText then
        self.detailText = text
        self.detail:SetText(text)
        self.detail:SetHeight(self.detail:GetTextHeight())
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
function U:ScrollDetail(delta)
    if not self.ready then return end
    local maxScroll = math.max(0, self.detail:GetHeight() - self.detailScroll:GetHeight())
    self.detailScroll:SetVerticalScroll(math.max(0, math.min(maxScroll, self.detailScroll:GetVerticalScroll() + delta)))
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
    bind("UI_SHORTCUT_LEFT_SHOULDER", "前のページ", function() self:MoveRow(-self:PageSize(self.column)) end, true)
    bind("UI_SHORTCUT_RIGHT_SHOULDER", "次のページ", function() self:MoveRow(self:PageSize(self.column)) end, true)
    bind("UI_SHORTCUT_LEFT_TRIGGER", "説明を上へ", function() self:ScrollDetail(-32) end, true)
    bind("UI_SHORTCUT_RIGHT_TRIGGER", "説明を下へ", function() self:ScrollDetail(32) end, true)
    return group
end
