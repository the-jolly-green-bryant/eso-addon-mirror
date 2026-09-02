ShoppingListOverview = {}

local Overview = ShoppingListOverview
local WINDOW_WIDTH = 820
local WINDOW_HEIGHT = 540
local ROW_COUNT = 11
local ROW_HEIGHT = 34

local function makeLabel(parent, font)
    local label = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    ShoppingListAccessibility:SetFont(label, font or "ZoFontGame")
    label:SetColor(0.9, 0.9, 0.9, 1)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return label
end

local function makeButton(parent, text, width)
    local button = WINDOW_MANAGER:CreateControl(nil, parent, CT_BUTTON)
    button:SetDimensions(width, 28)
    ShoppingListAccessibility:SetFont(button, "ZoFontGame")
    button:SetText(text)
    button:SetNormalFontColor(0.85, 0.78, 0.62, 1)
    button:SetMouseOverFontColor(1, 1, 1, 1)
    return button
end

local function formatGold(value)
    value = math.floor((tonumber(value) or 0) + 0.5)
    if ZO_CommaDelimitNumber then
        value = ZO_CommaDelimitNumber(value)
    end
    return zo_strformat(GetString(SI_SHOPPING_LIST_GOLD_SHORT), value)
end

function Overview:New(owner)
    return setmetatable({ owner = owner, rows = {}, offset = 0 }, {
        __index = self,
    })
end

function Overview:Initialize()
    local window = WINDOW_MANAGER:CreateTopLevelWindow("ShoppingListOverviewWindow")
    window:SetDimensions(WINDOW_WIDTH, WINDOW_HEIGHT)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetHidden(true)
    window:SetDrawTier(DT_HIGH)
    window:SetHandler("OnMouseWheel", function(_, delta) self:Scroll(-delta) end)
    self.window = window

    local backdrop = ShoppingListControls:CreateBackdrop(window)
    backdrop:SetAnchorFill(window)
    backdrop:SetCenterColor(0.035, 0.035, 0.045, 0.98)
    backdrop:SetEdgeColor(0.5, 0.42, 0.28, 0.95)
    ShoppingListAccessibility:RegisterBackdrop(backdrop)

    local title = makeLabel(window, "ZoFontWinH2")
    title:SetText(GetString(SI_SHOPPING_LIST_OVERVIEW_TITLE))
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 10)
    title:SetDimensions(WINDOW_WIDTH - 36, 30)
    ShoppingListControls:MakeWindowMovable(
        window,
        title,
        self.owner.data,
        "listOverview"
    )

    local help = makeLabel(window, "ZoFontGameSmall")
    help:SetText(GetString(SI_SHOPPING_LIST_OVERVIEW_HELP))
    help:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 42)
    help:SetDimensions(WINDOW_WIDTH - 36, 28)

    self:CreateHeaders()
    for index = 1, ROW_COUNT do
        self.rows[index] = self:CreateRow(index)
    end

    self.page = makeLabel(window, "ZoFontGameSmall")
    self.page:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.page:SetAnchor(BOTTOM, window, BOTTOM, 0, -52)
    self.page:SetDimensions(300, 22)

    local newer = makeButton(window, GetString(SI_SHOPPING_LIST_BUTTON_NEWER), 80)
    newer:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 18, -14)
    newer:SetHandler("OnClicked", function() self:Scroll(-ROW_COUNT) end)

    local older = makeButton(window, GetString(SI_SHOPPING_LIST_BUTTON_OLDER), 80)
    older:SetAnchor(LEFT, newer, RIGHT, 8, 0)
    older:SetHandler("OnClicked", function() self:Scroll(ROW_COUNT) end)

    local close = makeButton(window, GetString(SI_SHOPPING_LIST_BUTTON_CLOSE), 80)
    close:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -18, -14)
    close:SetHandler("OnClicked", function() self:Hide() end)
end

function Overview:CreateHeaders()
    local headers = {
        { id = SI_SHOPPING_LIST_OVERVIEW_LIST, x = 18, width = 180 },
        { id = SI_SHOPPING_LIST_OVERVIEW_PROGRESS, x = 202, width = 100 },
        { id = SI_SHOPPING_LIST_OVERVIEW_REMAINING, x = 306, width = 125 },
        { id = SI_SHOPPING_LIST_OVERVIEW_SPENDING, x = 435, width = 130 },
        { id = SI_SHOPPING_LIST_OVERVIEW_ORGANIZATION, x = 569, width = 177 },
    }
    for _, header in ipairs(headers) do
        local label = makeLabel(self.window, "ZoFontGameSmall")
        label:SetText(GetString(header.id))
        label:SetColor(0.72, 0.65, 0.5, 1)
        label:SetAnchor(TOPLEFT, self.window, TOPLEFT, header.x, 70)
        label:SetDimensions(header.width, 24)
    end
end

function Overview:CreateRow(index)
    local row = WINDOW_MANAGER:CreateControl(nil, self.window, CT_CONTROL)
    row:SetAnchor(TOPLEFT, self.window, TOPLEFT, 18, 94 + ((index - 1) * ROW_HEIGHT))
    row:SetDimensions(WINDOW_WIDTH - 36, ROW_HEIGHT)

    row.name = makeLabel(row, "ZoFontGame")
    row.name:SetAnchor(LEFT, row, LEFT, 0, 0)
    row.name:SetDimensions(180, ROW_HEIGHT)
    row.name:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

    row.progress = makeLabel(row, "ZoFontGameSmall")
    row.progress:SetAnchor(LEFT, row, LEFT, 184, 0)
    row.progress:SetDimensions(100, ROW_HEIGHT)

    row.remaining = makeLabel(row, "ZoFontGameSmall")
    row.remaining:SetAnchor(LEFT, row, LEFT, 288, 0)
    row.remaining:SetDimensions(125, ROW_HEIGHT)

    row.spending = makeLabel(row, "ZoFontGameSmall")
    row.spending:SetAnchor(LEFT, row, LEFT, 417, 0)
    row.spending:SetDimensions(130, ROW_HEIGHT)

    row.organization = makeLabel(row, "ZoFontGameSmall")
    row.organization:SetAnchor(LEFT, row, LEFT, 551, 0)
    row.organization:SetDimensions(177, ROW_HEIGHT)
    row.organization:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

    row.open = makeButton(row, GetString(SI_SHOPPING_LIST_OVERVIEW_OPEN), 52)
    row.open:SetAnchor(RIGHT, row, RIGHT, 0, 0)
    return row
end

function Overview:GetOrganizationText(entry)
    local list = entry.list
    local values = {}
    if entry.archived then
        values[#values + 1] = GetString(SI_SHOPPING_LIST_OVERVIEW_ARCHIVED)
    end
    if list.pinned then
        values[#values + 1] = GetString(SI_SHOPPING_LIST_OVERVIEW_PINNED)
    end
    if list.favorite then
        values[#values + 1] = GetString(SI_SHOPPING_LIST_OVERVIEW_FAVORITE)
    end
    if list.locked then
        values[#values + 1] = GetString(SI_SHOPPING_LIST_OVERVIEW_LOCKED)
    end
    if list.recurring then
        values[#values + 1] = GetString(SI_SHOPPING_LIST_OVERVIEW_RECURRING)
    end
    if not entry.archived
        and self.owner.data:IsMultiListTripEnabled()
        and list.tripActive
    then
        values[#values + 1] = GetString(SI_SHOPPING_LIST_OVERVIEW_TRIP)
    end
    if list.category and list.category ~= "" then
        values[#values + 1] = zo_strformat(
            GetString(SI_SHOPPING_LIST_OVERVIEW_CATEGORY),
            list.category
        )
    end
    if #entry.assignments > 0 then
        local names = {}
        for _, assignment in ipairs(entry.assignments) do
            names[#names + 1] = assignment.name
        end
        values[#values + 1] = zo_strformat(
            GetString(SI_SHOPPING_LIST_OVERVIEW_ASSIGNED),
            table.concat(names, ", ")
        )
    end
    if #values == 0 then
        return GetString(SI_SHOPPING_LIST_OVERVIEW_NONE)
    end
    return table.concat(values, " · ")
end

function Overview:OpenList(listId)
    self.owner.ui.listSignature = nil
    self.owner.ui:SelectList(listId)
    self:Hide()
end

function Overview:Refresh()
    self.entries = self.owner.data:GetListOverview()
    local maximum = math.max(0, #self.entries - ROW_COUNT)
    self.offset = zo_clamp(self.offset, 0, maximum)
    for index, row in ipairs(self.rows) do
        local entry = self.entries[self.offset + index]
        row:SetHidden(entry == nil)
        if entry then
            row.name:SetText(entry.list.name)
            row.progress:SetText(zo_strformat(
                GetString(SI_SHOPPING_LIST_OVERVIEW_PROGRESS_VALUE),
                entry.completedEntries,
                entry.entryCount
            ))
            row.remaining:SetText(zo_strformat(
                GetString(SI_SHOPPING_LIST_OVERVIEW_REMAINING_VALUE),
                entry.remainingEntries,
                entry.remainingQuantity
            ))
            row.spending:SetText(entry.budget and zo_strformat(
                GetString(SI_SHOPPING_LIST_OVERVIEW_BUDGET_VALUE),
                formatGold(entry.spent),
                formatGold(entry.budget)
            ) or zo_strformat(
                GetString(SI_SHOPPING_LIST_OVERVIEW_SPENDING_VALUE),
                formatGold(entry.spent)
            ))
            row.organization:SetText(self:GetOrganizationText(entry))
            row.open:SetHidden(entry.archived)
            local listId = entry.list.id
            row.open:SetHandler("OnClicked", function() self:OpenList(listId) end)
        end
    end
    local first = #self.entries == 0 and 0 or self.offset + 1
    local last = math.min(#self.entries, self.offset + ROW_COUNT)
    self.page:SetText(zo_strformat(
        GetString(SI_SHOPPING_LIST_PAGE_RANGE),
        first,
        last,
        #self.entries
    ))
end

function Overview:Scroll(delta)
    local maximum = math.max(0, #(self.entries or {}) - ROW_COUNT)
    self.offset = zo_clamp(self.offset + delta, 0, maximum)
    self:Refresh()
end

function Overview:Open()
    self.offset = 0
    self:Refresh()
    self.window:SetHidden(false)
end

function Overview:Hide()
    self.window:SetHidden(true)
end
