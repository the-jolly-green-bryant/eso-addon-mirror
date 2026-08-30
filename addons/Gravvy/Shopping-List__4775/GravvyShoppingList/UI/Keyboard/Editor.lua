ShoppingListEditor = {}

local Editor = ShoppingListEditor
local WINDOW_WIDTH = 460
local WINDOW_HEIGHT = 770

local function makeLabel(parent, text, x, y, width)
    local label = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    ShoppingListAccessibility:SetFont(label, "ZoFontGame")
    label:SetColor(0.86, 0.82, 0.72, 1)
    label:SetText(text)
    label:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    label:SetDimensions(width or 120, 30)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return label
end

local function makeEdit(parent, x, y, width, numeric, maxChars)
    local backdrop = WINDOW_MANAGER:CreateControlFromVirtual(nil, parent, "ZO_EditBackdrop")
    backdrop:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    backdrop:SetDimensions(width, 30)

    local edit = WINDOW_MANAGER:CreateControlFromVirtual(nil, backdrop, "ZO_DefaultEditForBackdrop")
    edit:ClearAnchors()
    edit:SetAnchor(TOPLEFT, backdrop, TOPLEFT, 3, 2)
    edit:SetAnchor(BOTTOMRIGHT, backdrop, BOTTOMRIGHT, -3, -2)
    ShoppingListAccessibility:SetFont(edit, "ZoFontGame")
    edit:SetMaxInputChars(maxChars or (numeric and 4 or 100))
    edit:SetNewLineEnabled(false)
    edit:SetSelectAllOnFocus(true)
    if numeric then
        edit:SetTextType(TEXT_TYPE_NUMERIC)
    end
    return edit
end

local function makeNoteEdit(parent, x, y, width, height)
    local backdrop = WINDOW_MANAGER:CreateControlFromVirtual(nil, parent, "ZO_EditBackdrop")
    backdrop:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    backdrop:SetDimensions(width, height)

    local edit = WINDOW_MANAGER:CreateControlFromVirtual(
        nil,
        backdrop,
        "ZO_DefaultEditMultiLineForBackdrop"
    )
    edit:ClearAnchors()
    edit:SetAnchor(TOPLEFT, backdrop, TOPLEFT, 5, 4)
    edit:SetAnchor(BOTTOMRIGHT, backdrop, BOTTOMRIGHT, -5, -4)
    ShoppingListAccessibility:SetFont(edit, "ZoFontGame")
    edit:SetMaxInputChars(ShoppingListData.MAX_NOTE_LENGTH)
    edit:SetNewLineEnabled(true)
    return edit
end

local function makeButton(parent, text, x, width)
    local button = WINDOW_MANAGER:CreateControl(nil, parent, CT_BUTTON)
    button:SetAnchor(BOTTOMLEFT, parent, BOTTOMLEFT, x, -16)
    button:SetDimensions(width, 30)
    ShoppingListAccessibility:SetFont(button, "ZoFontGame")
    button:SetText(text)
    button:SetNormalFontColor(0.85, 0.78, 0.62, 1)
    button:SetMouseOverFontColor(1, 1, 1, 1)
    return button
end

local function makeInlineButton(parent, text, x, y, width)
    local button = WINDOW_MANAGER:CreateControl(nil, parent, CT_BUTTON)
    button:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    button:SetDimensions(width, 30)
    ShoppingListAccessibility:SetFont(button, "ZoFontGame")
    button:SetText(text)
    button:SetNormalFontColor(0.85, 0.78, 0.62, 1)
    button:SetMouseOverFontColor(1, 1, 1, 1)
    return button
end

local function makeCombo(parent, name, x, y, width)
    local controlName = parent:GetName() .. name .. "Combo"
    local container = WINDOW_MANAGER:CreateControlFromVirtual(
        controlName,
        parent,
        "ZO_ComboBox"
    )
    container:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    container:SetDimensions(width, 30)
    local combo = ZO_ComboBox_ObjectFromContainer(container)
    combo:SetSortsItems(false)
    return combo
end

local function formatGold(value)
    value = math.floor((tonumber(value) or 0) + 0.5)
    if ZO_CommaDelimitNumber then
        return zo_strformat(
            GetString(SI_SHOPPING_LIST_GOLD_SHORT),
            ZO_CommaDelimitNumber(value)
        )
    end
    return zo_strformat(GetString(SI_SHOPPING_LIST_GOLD_SHORT), value)
end

local function setChoices(combo, choices, selectedValue)
    combo:ClearItems()
    combo.selectedValue = selectedValue
    local selectedLabel

    for _, choice in ipairs(choices) do
        local value = choice.value
        local label = choice.label
        combo:AddItem(combo:CreateItemEntry(label, function()
            combo.selectedValue = value
        end))
        if value == selectedValue then
            selectedLabel = label
        end
    end

    if not selectedLabel and choices[1] then
        combo.selectedValue = choices[1].value
        selectedLabel = choices[1].label
    end
    combo:SetSelectedItem(selectedLabel or "")
end

local function getTraitChoices()
    local choices = {
        { label = GetString(SI_SHOPPING_LIST_EDITOR_ANY_TRAIT), value = ITEM_TRAIT_TYPE_NONE },
    }
    local traits = {}
    local labelCounts = {}
    local first = ITEM_TRAIT_TYPE_ITERATION_BEGIN or 1
    local last = ITEM_TRAIT_TYPE_ITERATION_END or 64
    for traitType = first, last do
        if traitType ~= ITEM_TRAIT_TYPE_NONE then
            local label = GetString("SI_ITEMTRAITTYPE", traitType)
            if label and label ~= "" then
                traits[#traits + 1] = {
                    label = label,
                    value = traitType,
                    category = GetItemTraitTypeCategory
                        and GetItemTraitTypeCategory(traitType),
                }
                labelCounts[label] = (labelCounts[label] or 0) + 1
            end
        end
    end

    local categoryLabels = {
        [ITEM_TRAIT_TYPE_CATEGORY_WEAPON] = GetString(
            SI_SHOPPING_LIST_EDITOR_TRAIT_WEAPON
        ),
        [ITEM_TRAIT_TYPE_CATEGORY_ARMOR] = GetString(
            SI_SHOPPING_LIST_EDITOR_TRAIT_ARMOR
        ),
        [ITEM_TRAIT_TYPE_CATEGORY_JEWELRY] = GetString(
            SI_SHOPPING_LIST_EDITOR_TRAIT_JEWELRY
        ),
    }
    for _, trait in ipairs(traits) do
        local label = trait.label
        local categoryLabel = categoryLabels[trait.category]
        if labelCounts[label] > 1 and categoryLabel then
            label = zo_strformat(
                GetString(SI_SHOPPING_LIST_EDITOR_TRAIT_WITH_CATEGORY),
                label,
                categoryLabel
            )
        end
        choices[#choices + 1] = { label = label, value = trait.value }
    end
    return choices
end

local qualityChoices = {
    { label = GetString("SI_ITEMQUALITY", ITEM_QUALITY_TRASH), value = ITEM_QUALITY_TRASH },
    { label = GetString("SI_ITEMQUALITY", ITEM_QUALITY_NORMAL), value = ITEM_QUALITY_NORMAL },
    { label = GetString("SI_ITEMQUALITY", ITEM_QUALITY_MAGIC), value = ITEM_QUALITY_MAGIC },
    { label = GetString("SI_ITEMQUALITY", ITEM_QUALITY_ARCANE), value = ITEM_QUALITY_ARCANE },
    { label = GetString("SI_ITEMQUALITY", ITEM_QUALITY_ARTIFACT), value = ITEM_QUALITY_ARTIFACT },
    { label = GetString("SI_ITEMQUALITY", ITEM_QUALITY_LEGENDARY), value = ITEM_QUALITY_LEGENDARY },
}

function Editor.GetTraitChoices()
    return getTraitChoices()
end

function Editor.GetQualityChoices()
    return qualityChoices
end

function Editor:New(owner)
    return setmetatable({ owner = owner }, { __index = self })
end

function Editor:Initialize()
    local window = WINDOW_MANAGER:CreateTopLevelWindow("ShoppingListEditWindow")
    window:SetDimensions(WINDOW_WIDTH, WINDOW_HEIGHT)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetClampedToScreen(true)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetHidden(true)
    window:SetDrawTier(DT_HIGH)
    self.window = window

    local backdrop = ShoppingListControls:CreateBackdrop(window)
    backdrop:SetAnchorFill(window)
    backdrop:SetCenterColor(0.035, 0.035, 0.045, 0.98)
    backdrop:SetEdgeColor(0.5, 0.42, 0.28, 0.95)
    ShoppingListAccessibility:RegisterBackdrop(backdrop)

    local title = makeLabel(
        window,
        GetString(SI_SHOPPING_LIST_EDITOR_TITLE),
        18,
        10,
        WINDOW_WIDTH - 36
    )
    ShoppingListAccessibility:SetFont(title, "ZoFontWinH2")

    self.itemName = makeLabel(window, "", 18, 44, WINDOW_WIDTH - 36)
    self.itemName:SetColor(1, 1, 1, 1)
    self.itemName:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

    makeLabel(window, GetString(SI_SHOPPING_LIST_EDITOR_QUANTITY), 18, 82)
    self.quantity = makeEdit(window, 146, 82, 90, true, #tostring(ShoppingListModel.MAX_QUANTITY))

    makeLabel(window, GetString(SI_SHOPPING_LIST_EDITOR_TARGET_MODE), 18, 122)
    self.targetMode = makeCombo(window, "TargetMode", 146, 122, 280)

    makeLabel(window, GetString(SI_SHOPPING_LIST_EDITOR_SET), 18, 162)
    self.setName = makeEdit(window, 146, 162, 280, false, ShoppingListModel.MAX_NAME_LENGTH)
    self.setName:SetDefaultText(GetString(SI_SHOPPING_LIST_EDITOR_ANY_SET))

    makeLabel(window, GetString(SI_SHOPPING_LIST_EDITOR_TRAIT), 18, 202)
    self.trait = makeCombo(window, "Trait", 146, 202, 280)

    makeLabel(window, GetString(SI_SHOPPING_LIST_EDITOR_QUALITY_RULE), 18, 242)
    self.qualityMode = makeCombo(window, "QualityMode", 146, 242, 135)
    self.quality = makeCombo(window, "Quality", 291, 242, 135)

    makeLabel(window, GetString(SI_SHOPPING_LIST_EDITOR_LEVEL_RULE), 18, 282)
    self.levelMode = makeCombo(window, "LevelMode", 146, 282, 135)

    makeLabel(window, GetString(SI_SHOPPING_LIST_EDITOR_LEVEL), 18, 322)
    self.level = makeEdit(window, 146, 322, 90, true, #tostring(ShoppingListModel.MAX_LEVEL))
    makeLabel(window, GetString(SI_SHOPPING_LIST_EDITOR_CHAMPION_POINTS), 250, 322, 125)
    self.championPoints = makeEdit(window, 376, 322, 50, true, #tostring(ShoppingListModel.MAX_CHAMPION_POINTS))

    makeLabel(window, GetString(SI_SHOPPING_LIST_EDITOR_MAX_UNIT_PRICE), 18, 366, 150)
    self.maxUnitPrice = makeEdit(window, 174, 366, 120, true, #tostring(ShoppingListModel.MAX_PRICE))
    makeLabel(window, GetString(SI_SHOPPING_LIST_EDITOR_GOLD_NONE), 302, 366, 140)

    self.priceSuggestion = makeLabel(window, "", 18, 400, 250)
    ShoppingListAccessibility:SetFont(self.priceSuggestion, "ZoFontGameSmall")
    self.priceSuggestion:SetColor(0.72, 0.82, 0.92, 1)
    self.priceSuggestion:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    self.usePriceSuggestion = makeInlineButton(
        window,
        GetString(SI_SHOPPING_LIST_USE_SUGGESTED_PRICE),
        276,
        400,
        150
    )
    self.usePriceSuggestion:SetHandler("OnClicked", function()
        self:ApplySuggestedPrice()
    end)

    self.purchaseSummary = makeLabel(window, "", 18, 442, WINDOW_WIDTH - 36)
    ShoppingListAccessibility:SetFont(self.purchaseSummary, "ZoFontGameSmall")
    self.purchaseSummary:SetColor(0.75, 0.82, 0.65, 1)
    self.purchaseSummary:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    self.purchaseSummary:SetHeight(44)

    self.ownedSummary = makeLabel(window, "", 18, 484, WINDOW_WIDTH - 36)
    ShoppingListAccessibility:SetFont(self.ownedSummary, "ZoFontGameSmall")
    self.ownedSummary:SetColor(0.75, 0.82, 0.9, 1)

    makeLabel(window, GetString(SI_SHOPPING_LIST_EDITOR_NOTE), 18, 518, 120)
    self.note = makeNoteEdit(window, 18, 548, WINDOW_WIDTH - 36, 100)

    local hint = makeLabel(
        window,
        GetString(SI_SHOPPING_LIST_EDITOR_HINT),
        18,
        652,
        WINDOW_WIDTH - 36
    )
    ShoppingListAccessibility:SetFont(hint, "ZoFontGameSmall")
    hint:SetColor(0.65, 0.65, 0.65, 1)
    hint:SetHeight(60)

    self.historyButton = makeButton(window, GetString(SI_SHOPPING_LIST_BUTTON_HISTORY), 18, 80)
    self.historyButton:SetHandler("OnClicked", function()
        self.owner.history:Open(self.item)
    end)

    self.moveUp = makeButton(window, GetString(SI_SHOPPING_LIST_BUTTON_MOVE_UP), 106, 74)
    self.moveUp:SetHandler("OnClicked", function() self:MoveItem(-1) end)

    self.moveDown = makeButton(window, GetString(SI_SHOPPING_LIST_BUTTON_MOVE_DOWN), 188, 86)
    self.moveDown:SetHandler("OnClicked", function() self:MoveItem(1) end)

    local save = makeButton(window, GetString(SI_SHOPPING_LIST_BUTTON_SAVE), 282, 70)
    save:SetHandler("OnClicked", function() self:Save() end)
    local cancel = makeButton(window, GetString(SI_SHOPPING_LIST_BUTTON_CANCEL), 360, 82)
    cancel:SetHandler("OnClicked", function() self:Hide() end)

    setChoices(self.qualityMode, {
        { label = GetString(SI_SHOPPING_LIST_CHOICE_ANY), value = "any" },
        { label = GetString(SI_SHOPPING_LIST_CHOICE_AT_LEAST), value = "minimum" },
        { label = GetString(SI_SHOPPING_LIST_CHOICE_EXACTLY), value = "exact" },
    }, "any")
    setChoices(self.levelMode, {
        { label = GetString(SI_SHOPPING_LIST_CHOICE_ANY), value = "any" },
        { label = GetString(SI_SHOPPING_LIST_CHOICE_EXACTLY), value = "exact" },
    }, "any")
    setChoices(self.targetMode, {
        { label = GetString(SI_SHOPPING_LIST_TARGET_BUY), value = "buy" },
        { label = GetString(SI_SHOPPING_LIST_TARGET_OWN), value = "own" },
    }, "buy")
    setChoices(self.quality, qualityChoices, ITEM_QUALITY_NORMAL)
    self.traitChoices = getTraitChoices()
end

function Editor:Open(item)
    if not item then
        return
    end

    self.item = item
    local rule = item.match or {}
    self.itemName:SetText(item.itemLink ~= "" and item.itemLink or item.name)
    self.quantity:SetText(tostring(item.desired))
    setChoices(self.targetMode, {
        { label = GetString(SI_SHOPPING_LIST_TARGET_BUY), value = "buy" },
        { label = GetString(SI_SHOPPING_LIST_TARGET_OWN), value = "own" },
    }, ShoppingListModel:NormalizeTargetMode(item.targetMode))
    self.setName:SetText(rule.setName or "")
    self.level:SetText(tostring(rule.level or 1))
    self.championPoints:SetText(tostring(rule.championPoints or 0))
    self.maxUnitPrice:SetText(item.maxUnitPrice and tostring(item.maxUnitPrice) or "")
    self:UpdatePriceSuggestion()
    self.note:SetText(item.note or "")
    self.historyButton:SetEnabled(#(item.purchaseHistory or {}) > 0)
    self:UpdateMoveButtons()

    local owned = self.owner.inventory and self.owner.inventory:GetCounts(item)
    self.ownedSummary:SetText(zo_strformat(
        GetString(SI_SHOPPING_LIST_INVENTORY_BREAKDOWN),
        owned and owned.total or 0,
        owned and owned.backpack or 0,
        owned and owned.bank or 0,
        owned and owned.craftBag or 0
    ))

    local history = item.purchaseHistory or {}
    local totalSpent = tonumber(item.totalSpent) or 0
    local pricedQuantity = tonumber(item.pricedQuantity) or 0
    if #history == 0 then
        self.purchaseSummary:SetColor(0.75, 0.82, 0.65, 1)
        self.purchaseSummary:SetText(GetString(SI_SHOPPING_LIST_NO_PURCHASE_PRICES))
    else
        local average = pricedQuantity > 0 and (totalSpent / pricedQuantity) or 0
        local last = history[#history]
        local lastParts = { zo_strformat(
            GetString(SI_SHOPPING_LIST_LAST_UNIT_PRICE),
            formatGold(last.unitPrice)
        ) }
        if item.maxUnitPrice and (tonumber(last.unitPrice) or 0) > item.maxUnitPrice then
            lastParts[#lastParts + 1] = GetString(SI_SHOPPING_LIST_OVER_TARGET)
            self.purchaseSummary:SetColor(1, 0.45, 0.35, 1)
        else
            self.purchaseSummary:SetColor(0.75, 0.82, 0.65, 1)
        end
        if last.guildName and last.guildName ~= "" then
            lastParts[#lastParts + 1] = last.guildName
        end
        if last.sellerName and last.sellerName ~= "" then
            lastParts[#lastParts + 1] = last.sellerName
        end
        self.purchaseSummary:SetText(zo_strformat(
            GetString(SI_SHOPPING_LIST_PURCHASE_SUMMARY),
            #history,
            GetString(#history == 1
                and SI_SHOPPING_LIST_NOUN_PURCHASE
                or SI_SHOPPING_LIST_NOUN_PURCHASES),
            formatGold(totalSpent),
            formatGold(average),
            table.concat(lastParts, " · ")
        ))
    end

    setChoices(self.trait, self.traitChoices, rule.traitType or ITEM_TRAIT_TYPE_NONE)
    setChoices(self.qualityMode, {
        { label = GetString(SI_SHOPPING_LIST_CHOICE_ANY), value = "any" },
        { label = GetString(SI_SHOPPING_LIST_CHOICE_AT_LEAST), value = "minimum" },
        { label = GetString(SI_SHOPPING_LIST_CHOICE_EXACTLY), value = "exact" },
    }, rule.qualityMode or "any")
    setChoices(self.quality, qualityChoices, rule.quality or ITEM_QUALITY_NORMAL)
    setChoices(self.levelMode, {
        { label = GetString(SI_SHOPPING_LIST_CHOICE_ANY), value = "any" },
        { label = GetString(SI_SHOPPING_LIST_CHOICE_EXACTLY), value = "exact" },
    }, rule.levelMode or "any")

    self.window:SetHidden(false)
end

function Editor:Hide()
    self.note:LoseFocus()
    self.window:SetHidden(true)
end

function Editor:UpdatePriceSuggestion()
    self.suggestedPrice = self.owner.costPlanning:GetSuggestion(self.item)
    if self.suggestedPrice then
        self.priceSuggestion:SetText(zo_strformat(
            GetString(SI_SHOPPING_LIST_LOCAL_PRICE_SUGGESTION),
            formatGold(self.suggestedPrice.price),
            self.suggestedPrice.sourceName
        ))
        self.usePriceSuggestion:SetHidden(false)
        self.usePriceSuggestion:SetEnabled(true)
    else
        self.priceSuggestion:SetText(
            GetString(SI_SHOPPING_LIST_LOCAL_PRICE_UNAVAILABLE)
        )
        self.usePriceSuggestion:SetHidden(true)
    end
end

function Editor:ApplySuggestedPrice()
    if self.suggestedPrice then
        self.maxUnitPrice:SetText(tostring(self.suggestedPrice.price))
    end
end

function Editor:UpdateMoveButtons()
    if not self.item then
        self.moveUp:SetEnabled(false)
        self.moveDown:SetEnabled(false)
        return
    end

    local _, index, list = self.owner.data:FindItem(self.item.id)
    local count = list and #list.items or 0
    self.moveUp:SetEnabled(index ~= nil and index > 1)
    self.moveDown:SetEnabled(index ~= nil and index < count)
end

function Editor:MoveItem(direction)
    if not self.item or not self.owner:MoveItem(self.item.id, direction) then
        return
    end
    self:UpdateMoveButtons()
    self.owner.ui:SetStatus(GetString(SI_SHOPPING_LIST_STATUS_ITEM_ORDER_UPDATED))
end

function Editor:Save()
    if not self.item then
        return
    end

    local ok, message = self.owner.data:UpdateItem(self.item.id, {
        desired = self.quantity:GetText(),
        targetMode = self.targetMode.selectedValue,
        maxUnitPrice = self.maxUnitPrice:GetText(),
        setName = self.setName:GetText(),
        traitType = self.trait.selectedValue,
        qualityMode = self.qualityMode.selectedValue,
        quality = self.quality.selectedValue,
        levelMode = self.levelMode.selectedValue,
        level = self.level:GetText(),
        championPoints = self.championPoints:GetText(),
        note = self.note:GetText(),
    })
    if not ok then
        self.owner.ui:SetStatus(message, true)
        return
    end

    self:Hide()
    self.owner.ui:SetStatus(zo_strformat(
        GetString(SI_SHOPPING_LIST_STATUS_ITEM_UPDATED),
        self.item.name
    ))
    self.owner.ui:Refresh()
    self.owner.gamepad:Refresh()
    self.owner:RefreshInventory()
end
