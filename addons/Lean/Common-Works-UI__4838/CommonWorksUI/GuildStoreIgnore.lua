-- Common Works -- guild store ignore list
--
-- Right-click listings to ignore variations or items across guild stores.
-- AGS's FilterLocalResult keeps counts and Show More accurate; requires AGS.

CommonWorksUI = CommonWorksUI or {}
local CW = CommonWorksUI

local WM = WINDOW_MANAGER

-- AwesomeGuildStore reserves 1..99 for itself and lists filters owned by other add-ons
-- from 100 up in data/FilterIds.lua; 110 is the first free slot after that list.
local FILTER_ID = 110

-- Anchor below results, in Master Merchant's button column.
local PANEL_W  = 320
local TOGGLE_W = 200   -- Master Merchant's button width, so the column lines up
local ROW_H   = 24
local ROWS    = 24
local PAD     = 10
local BTN_H   = 28
local SCROLL_W = ZO_SCROLL_BAR_WIDTH
local ARROW_H  = 16    -- ZO_ScrollUpButton's height, which the bar anchors outside itself
local PANEL_H = PAD + ROW_H + ROWS * ROW_H + PAD + BTN_H + PAD

-- Declare before IsIgnored so its lookup fields resolve as locals.
local filter, panel, toggle, header, rows, scroll, bar, tally
-- Rebuilt from the saved list on every refresh, so nothing needs migrating by hand.
-- matchCache is per rule-set and dies with it.
local hasSetKeys, hasTraitKeys, hasNoSetKey, matchRules, matchCache = false, false, false, {}, {}

-- Item id spans all qualities, traits and levels; a variation adds quality and trait.
local function ItemKey(itemLink)
    return "i:" .. GetItemLinkItemId(itemLink)
end

local function VariationKey(itemLink)
    return string.format("v:%d:%d:%d", GetItemLinkItemId(itemLink),
        GetItemLinkFunctionalQuality(itemLink), GetItemLinkTraitInfo(itemLink))
end

-- Set ids cover every piece and variation; perfected sets have separate ids.
local function SetKey(itemLink)
    local hasSet, _, _, _, _, setId = GetItemLinkSetInfo(itemLink)
    return hasSet and ("s:" .. setId) or nil
end

-- One rule for all non-set gear; exclude non-gear such as mats, motifs and furnishings.
local NOSET_KEY = "n:"

local function IsSetlessGear(itemLink)
    if GetItemLinkSetInfo(itemLink) then return false end
    local itemType = GetItemLinkItemType(itemLink)
    -- Jewelry is ITEMTYPE_ARMOR too, so this is every equippable piece.
    return itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_ARMOR
end

-- GetItemLinkName gives editable text (armory_gamepad.lua:468).
-- zo_strformat on a link preserves markup, producing an uneditable colored chip.
local function ItemName(itemLink)
    return zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink))
end

-- Normalize Intricate/Ornate to armor ids so one rule covers weapons, armor and jewelry.
-- Trait information is a character's research badge, so it cannot key the item's trait.
local TRAIT_GROUP = {
    [ITEM_TRAIT_TYPE_ARMOR_INTRICATE]   = ITEM_TRAIT_TYPE_ARMOR_INTRICATE,
    [ITEM_TRAIT_TYPE_WEAPON_INTRICATE]  = ITEM_TRAIT_TYPE_ARMOR_INTRICATE,
    [ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] = ITEM_TRAIT_TYPE_ARMOR_INTRICATE,
    [ITEM_TRAIT_TYPE_ARMOR_ORNATE]      = ITEM_TRAIT_TYPE_ARMOR_ORNATE,
    [ITEM_TRAIT_TYPE_WEAPON_ORNATE]     = ITEM_TRAIT_TYPE_ARMOR_ORNATE,
    [ITEM_TRAIT_TYPE_JEWELRY_ORNATE]    = ITEM_TRAIT_TYPE_ARMOR_ORNATE,
}

local function TraitKey(itemLink)
    local group = TRAIT_GROUP[GetItemLinkTraitInfo(itemLink)]
    return group ~= nil and ("t:" .. group) or nil
end

local function IsIgnored(itemLink)
    local ignored = CW.SavedVars.storeIgnored
    if ignored[ItemKey(itemLink)] ~= nil or ignored[VariationKey(itemLink)] ~= nil then return true end

    -- Check cheap item/variation keys before set, trait and name lookups on every search row.
    if hasSetKeys then
        local key = SetKey(itemLink)
        if key ~= nil and ignored[key] ~= nil then return true end
    end

    if hasTraitKeys then
        local key = TraitKey(itemLink)
        if key ~= nil and ignored[key] ~= nil then return true end
    end

    if hasNoSetKey and IsSetlessGear(itemLink) then return true end

    if #matchRules == 0 then return false end
    -- Cache name matches per item; listings repeat across pages and guilds.
    local matched = matchCache[itemLink]
    if matched == nil then
        local name = zo_strlower(ItemName(itemLink))
        matched = false
        for i = 1, #matchRules do
            -- Plain find, not a pattern: item names are full of - and ' and (.
            if string.find(name, matchRules[i], 1, true) then matched = true break end
        end
        matchCache[itemLink] = matched
    end
    return matched
end

-- AGS caches filtered views and saved searches by serialized state.
-- Use a stable digest that changes with the list, without storing the whole list twice.
local function Digest()
    local count, sum = 0, 0
    for key in pairs(CW.SavedVars.storeIgnored) do
        count = count + 1
        -- Weight every byte by position so letter-only match rules also change the digest.
        for i = 1, #key do sum = sum + string.byte(key, i) * i end
    end
    return string.format("%d.%d", count, sum)
end

-- The panel normally builds the label before the first search; keep filtering if absent.
local hidden = 0
local function ShowTally()
    if tally then tally:SetText(string.format(CW.L.STORE_IGNORE_HIDDEN, hidden)) end
end

local function RegisterFilter(AGS)
    local FilterBase = AGS.class.FilterBase
    local IgnoreFilter = FilterBase:Subclass()

    function IgnoreFilter:New(...)
        local object = ZO_Object.New(self)
        object:Initialize(...)
        return object
    end

    function IgnoreFilter:Initialize()
        FilterBase.Initialize(self, FILTER_ID, FilterBase.GROUP_LOCAL, CW.L.STORE_IGNORE_FILTER)
        -- CanFilter uses this to attach the filter to every item category.
        local subcategories = {}
        for _, id in pairs(AGS.data.SUB_CATEGORY_ID) do subcategories[id] = true end
        self:SetEnabledSubcategories(subcategories)
    end

    -- AGS brackets each view pass with SetUp/TearDown (ItemDatabaseFilterView:UpdateItems).
    -- Filters stop at the first match, so rows hidden earlier are not ours to count.
    function IgnoreFilter:SetUpLocalFilter(...)
        hidden = 0
        return not self:IsDefault(...)
    end

    function IgnoreFilter:FilterLocalResult(itemData)
        if not IsIgnored(itemData.itemLink) then return true end
        hidden = hidden + 1
        return false
    end

    function IgnoreFilter:TearDownLocalFilter()
        ShowTally()
    end

    -- AGS drops default filters before processing rows.
    function IgnoreFilter:IsDefault()
        return not CW.SavedVars.storeIgnoreEnabled or next(CW.SavedVars.storeIgnored) == nil
    end

    function IgnoreFilter:Serialize()
        return Digest()
    end

    filter = IgnoreFilter:New()
    AGS:RegisterFilter(filter)
end

-- Store the source item link, or the original text for partial matches.
-- Trait rows use the key's trait rather than the source item's name.
local function TraitName(key)
    return GetString("SI_ITEMTRAITTYPE", tonumber(string.sub(key, 3)))
end

local function EntryText(key, value)
    local kind = string.sub(key, 1, 1)
    if kind == "t" then
        return string.format(CW.L.STORE_IGNORE_TRAIT_ROW, TraitName(key))
    end
    if kind == "m" then
        return string.format(CW.L.STORE_IGNORE_MATCH_ROW, value)
    end
    if kind == "n" then
        return CW.L.STORE_IGNORE_SETLESS_ROW
    end
    -- A set entry names the set, not the piece it was added from.
    if kind == "s" then
        local _, setName = GetItemLinkSetInfo(value)
        return string.format(CW.L.STORE_IGNORE_SET_ROW, zo_strformat(SI_TOOLTIP_ITEM_NAME, setName))
    end
    local name = ItemName(value)
    -- Color variations by quality; item-wide entries cover every quality.
    if kind == "v" then
        return GetItemQualityColor(GetItemLinkDisplayQuality(value)):Colorize(name)
    end
    return string.format(CW.L.STORE_IGNORE_ALL_ROW, name)
end

-- Rebuild rules separately from SortedEntries so scrolling preserves IsIgnored's name cache.
local function RebuildRules()
    hasSetKeys, hasTraitKeys, hasNoSetKey = false, false, false
    matchRules = {}
    ZO_ClearTable(matchCache)
    for key in pairs(CW.SavedVars.storeIgnored) do
        local kind = string.sub(key, 1, 1)
        if kind == "s" then hasSetKeys = true end
        if kind == "t" then hasTraitKeys = true end
        if kind == "n" then hasNoSetKey = true end
        -- Past the "m:" prefix the key is already lowered, the form find wants.
        if kind == "m" then matchRules[#matchRules + 1] = string.sub(key, 3) end
    end
end

-- Name matches first, then the broad "All ..." rules, then sets, then single variations.
local RANK = { m = 1, n = 2, t = 2, i = 2, s = 3, v = 4 }

-- Rows change only with the list, so scrolling reuses the pass.
local sorted
local function SortedEntries()
    if sorted then return sorted end
    sorted = {}
    for key, value in pairs(CW.SavedVars.storeIgnored) do
        sorted[#sorted + 1] = { key = key, link = value, text = EntryText(key, value),
                                rank = RANK[string.sub(key, 1, 1)] }
    end
    -- Within a rank, by text then key for a stable order.
    table.sort(sorted, function(a, b)
        if a.rank ~= b.rank then return a.rank < b.rank end
        if a.text == b.text then return a.key < b.key end
        return a.text < b.text
    end)
    return sorted
end

-- Every write to the list goes through SetIgnored or the clear dialog.
local function ListChanged()
    sorted = nil
    RebuildRules()
end

local function DrawRows()
    local list = SortedEntries()
    local overflow = zo_max(0, #list - ROWS)
    scroll = zo_clamp(scroll, 0, overflow)
    -- The handler below ignores a value it already has, so this cannot loop.
    bar:SetMinMax(0, overflow)
    bar:SetValue(scroll)

    -- An inactive filter never runs again to clear its tally.
    if not CW.SavedVars.storeIgnoreEnabled or #list == 0 then hidden = 0 end
    ShowTally()

    header:SetText(string.format(CW.L.STORE_IGNORE_TITLE, #list))
    toggle:SetText(string.format(CW.L.STORE_IGNORE_TOGGLE, #list))

    for i = 1, ROWS do
        local entry = list[scroll + i]
        local row = rows[i]
        row:SetHidden(entry == nil)
        row.remove:SetHidden(entry == nil)
        if entry then
            -- Tooltips only for single-item rules; set rules represent more than their source item.
            local kind = string.sub(entry.key, 1, 1)
            row.link = (kind == "i" or kind == "v") and entry.link or nil
            row.key = entry.key
            row:SetText(entry.text)
        end
    end
end

local function SetIgnored(key, itemLink)
    CW.SavedVars.storeIgnored[key] = itemLink
    ListChanged()
    DrawRows()
    -- FILTER_VALUE_CHANGED re-serializes the digest and refreshes results immediately.
    filter:HandleChange()
end

-- The base game's text-entry dialog shape (ingamedialogs.lua:1263): requiresTextInput
-- greys OK out on an empty box, and both buttons are already localised.
local DIALOG = "CW_STORE_IGNORE_MATCH"

ESO_Dialogs[DIALOG] = {
    title    = { text = CW.L.STORE_IGNORE_MATCH_TITLE },
    mainText = { text = CW.L.STORE_IGNORE_MATCH_PROMPT },
    editBox  = {},
    buttons  = {
        {
            requiresTextInput = true,
            text = SI_DIALOG_ACCEPT,
            callback = function(dialog)
                local text = zo_strtrim(ZO_Dialogs_GetEditBoxText(dialog))
                -- Spaces alone get past requiresTextInput and would match everything.
                if text == "" then return end
                SetIgnored("m:" .. zo_strlower(text), text)
            end,
        },
        { text = SI_DIALOG_CANCEL },
    },
}

local CLEAR_DIALOG = "CW_STORE_IGNORE_CLEAR"

ESO_Dialogs[CLEAR_DIALOG] = {
    title    = { text = CW.L.STORE_IGNORE_CLEAR_TITLE },
    mainText = { text = CW.L.STORE_IGNORE_CLEAR_PROMPT },
    buttons  = {
        {
            text = SI_DIALOG_CONFIRM,
            callback = function()
                ZO_ClearTable(CW.SavedVars.storeIgnored)
                ListChanged()
                scroll = 0
                DrawRows()
                filter:HandleChange()
            end,
        },
        { text = SI_DIALOG_CANCEL },
    },
}

local function ResultItemLink(inventorySlot)
    if ZO_InventorySlot_GetType(inventorySlot) ~= SLOT_TYPE_TRADING_HOUSE_ITEM_RESULT then return nil end
    -- AGS hangs its result object off the row with the link on it; the vanilla slot
    -- index is the fallback for a row it did not build.
    local data = ZO_ScrollList_GetData(inventorySlot)
    if data and data.itemLink then return data.itemLink end
    return GetTradingHouseSearchResultItemLink(ZO_Inventory_GetSlotIndex(inventorySlot))
end

local function AddMenuEntries(inventorySlot)
    local itemLink = ResultItemLink(inventorySlot)
    if not itemLink then return end

    AddCustomMenuItem(CW.L.STORE_IGNORE_VARIATION, function()
        SetIgnored(VariationKey(itemLink), itemLink)
    end)
    AddCustomMenuItem(CW.L.STORE_IGNORE_ALL, function()
        SetIgnored(ItemKey(itemLink), itemLink)
    end)

    -- Name the set; omit this entry on items without one.
    local hasSet, setName = GetItemLinkSetInfo(itemLink)
    if hasSet then
        AddCustomMenuItem(string.format(CW.L.STORE_IGNORE_SET, zo_strformat(SI_TOOLTIP_ITEM_NAME, setName)), function()
            SetIgnored(SetKey(itemLink), itemLink)
        end)
    elseif IsSetlessGear(itemLink) then
        AddCustomMenuItem(CW.L.STORE_IGNORE_SETLESS, function()
            SetIgnored(NOSET_KEY, itemLink)
        end)
    end

    -- Named by whichever this one carries, absent on an item carrying neither.
    local traitKey = TraitKey(itemLink)
    if traitKey then
        AddCustomMenuItem(string.format(CW.L.STORE_IGNORE_TRAIT, TraitName(traitKey)), function()
            SetIgnored(traitKey, itemLink)
        end)
    end

    -- Prefilled with the whole name so the box explains itself.
    AddCustomMenuItem(CW.L.STORE_IGNORE_MATCH, function()
        ZO_Dialogs_ShowDialog(DIALOG, nil, { initialEditText = ItemName(itemLink) })
    end)
end

local function BuildRow(i)
    local row = WM:CreateControl("CW_StoreIgnoreRow" .. i, panel, CT_LABEL)
    row:SetDimensions(PANEL_W - PAD * 2 - ROW_H - SCROLL_W, ROW_H)
    row:SetFont("ZoFontGame")
    row:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row:SetMaxLineCount(1)
    row:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    row:SetMouseEnabled(true)
    row:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 0, (i - 1) * ROW_H)
    row:SetHandler("OnMouseEnter", function(self)
        if not self.link then return end
        InitializeTooltip(ItemTooltip, self, RIGHT, -10, 0)
        ItemTooltip:SetLink(self.link)
    end)
    row:SetHandler("OnMouseExit", function() ClearTooltip(ItemTooltip) end)

    -- The decline button the base game puts on its own ignore list rows
    -- (esoui/ingame/contacts/keyboard/ignorelist_keyboard.xml).
    local remove = WM:CreateControl("CW_StoreIgnoreRemove" .. i, panel, CT_BUTTON)
    remove:SetDimensions(20, 20)
    remove:SetNormalTexture("EsoUI/Art/Buttons/decline_up.dds")
    remove:SetPressedTexture("EsoUI/Art/Buttons/decline_down.dds")
    remove:SetMouseOverTexture("EsoUI/Art/Buttons/decline_over.dds")
    remove:SetAnchor(LEFT, row, RIGHT, 4, 0)
    remove:SetHandler("OnClicked", function()
        SetIgnored(row.key, nil)
        PlaySound(SOUNDS.DEFAULT_CLICK)
    end)
    remove:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(InformationTooltip, self, LEFT, 4, 0)
        SetTooltipText(InformationTooltip, GetString(SI_DIALOG_REMOVE))
    end)
    remove:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

    row.remove = remove
    return row
end

local function BuildPanel(pane)
    toggle = WM:CreateControlFromVirtual("CW_StoreIgnoreToggle", pane, "ZO_DefaultButton")
    toggle:SetDimensions(TOGGLE_W, BTN_H)
    -- Anchor to the browse pane's bottom. PerfectPixel shortens it by 50px with MM
    -- (compatibility.lua:962), placing us above MM's button; otherwise use the window bottom.
    toggle:SetAnchor(BOTTOM, pane, BOTTOM, 0, -6)

    local enabled = WM:CreateControlFromVirtual("CW_StoreIgnoreEnabled", pane, "ZO_CheckButton")
    enabled:SetAnchor(RIGHT, toggle, LEFT, -4, 0)
    ZO_CheckButton_SetCheckState(enabled, CW.SavedVars.storeIgnoreEnabled)
    ZO_CheckButton_SetToggleFunction(enabled, function(_, checked)
        CW.SavedVars.storeIgnoreEnabled = checked
        DrawRows()
        filter:HandleChange()
    end)

    tally = WM:CreateControl("CW_StoreIgnoreTally", pane, CT_LABEL)
    tally:SetFont("ZoFontGameSmall")
    tally:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
    tally:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    tally:SetDimensions(TOGGLE_W, ROW_H)
    tally:SetAnchor(BOTTOM, toggle, TOP, 0, -2)

    panel = WM:CreateControl("CW_StoreIgnorePanel", pane, CT_CONTROL)
    panel:SetDimensions(PANEL_W, PANEL_H)
    panel:SetMouseEnabled(true)
    panel:SetMovable(true)
    panel:SetDrawTier(DT_HIGH)
    -- Anchor to the screen: the bottom-of-pane toggle would put the panel off short screens.
    local pos = CW.SavedVars.storeIgnorePos
    panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, pos.x, pos.y)
    -- Clamp while dragging to keep the panel on screen without snapping on release.
    panel:SetHandler("OnMoveStart", function(self) self:SetClampedToScreen(true) end)
    panel:SetHandler("OnMoveStop", function(self)
        pos.x, pos.y = self:GetLeft(), self:GetTop()
        self:SetClampedToScreen(false)
    end)

    -- Built-in black ZO_DefaultBackdrop; clear its preset anchor.
    local bg = WM:CreateControlFromVirtual("CW_StoreIgnoreBg", panel, "ZO_DefaultBackdrop")
    bg:ClearAnchors()
    bg:SetCenterColor(0, 0, 0, 1)
    bg:SetEdgeColor(0, 0, 0, 1)
    bg:SetAlpha(0.85)
    bg:SetAnchor(TOPLEFT, panel, TOPLEFT, 0, 0)
    bg:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, 0, 0)
    bg:SetDrawLevel(0)

    header = WM:CreateControl("CW_StoreIgnoreHeader", panel, CT_LABEL)
    header:SetDimensions(PANEL_W - PAD * 2, ROW_H)
    header:SetFont("ZoFontHeader")
    header:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    header:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
    header:SetAnchor(TOPLEFT, panel, TOPLEFT, PAD, PAD)

    rows = {}
    for i = 1, ROWS do rows[i] = BuildRow(i) end

    local clear = WM:CreateControlFromVirtual("CW_StoreIgnoreClear", panel, "ZO_DefaultButton")
    clear:SetDimensions(PANEL_W - PAD * 2, BTN_H)
    clear:SetText(CW.L.STORE_IGNORE_CLEAR)
    clear:SetAnchor(BOTTOM, panel, BOTTOM, 0, -PAD)
    clear:SetHandler("OnClicked", function()
        -- Nothing to lose, nothing to ask about.
        local count = NonContiguousCount(CW.SavedVars.storeIgnored)
        if count == 0 then return end
        ZO_Dialogs_ShowDialog(CLEAR_DIALOG, nil, { mainTextParams = { count } })
    end)

    -- The wheel scrolls anywhere over the panel, quicker than the bar.
    panel:SetHandler("OnMouseWheel", function(_, delta)
        scroll = scroll - delta
        DrawRows()
    end)

    -- Inset by one arrow height to keep the externally anchored buttons inside the list.
    bar = WM:CreateControlFromVirtual("CW_StoreIgnoreBar", panel, "ZO_VerticalScrollbarBase")
    bar:SetAnchor(TOPRIGHT, header, BOTTOMRIGHT, 0, ARROW_H)
    bar:SetDimensions(SCROLL_W, ROWS * ROW_H - ARROW_H * 2)
    bar:SetValueStep(1)
    bar:SetHandler("OnValueChanged", function(_, value)
        value = zo_round(value)
        if value == scroll then return end
        scroll = value
        DrawRows()
    end)
    for name, dir in pairs({ Up = -1, Down = 1 }) do
        bar:GetNamedChild(name):SetHandler("OnClicked", function()
            scroll = scroll + dir
            DrawRows()
        end)
    end

    toggle:SetHandler("OnClicked", function()
        CW.SavedVars.storeIgnoreListShown = not CW.SavedVars.storeIgnoreListShown
        panel:SetHidden(not CW.SavedVars.storeIgnoreListShown)
    end)
    panel:SetHidden(not CW.SavedVars.storeIgnoreListShown)
end

-- First trader visit: register the filter during AGS setup, then build the panel and menus.
function CW.InstallStoreIgnore()
    if not CW.SavedVars.storeIgnoreList then return end
    local AGS = CW.GetAGS()
    if not AGS then return end

    scroll = 0
    -- AFTER_FILTER_SETUP precedes the panel, so the rules cannot wait on its first DrawRows.
    RebuildRules()

    -- Append hidden-row counts to AGS's label on every search/cooldown/ready update.
    -- Hook the class: instance hooks shadow the method and drop later add-ons' hooks.
    SecurePostHook(AGS.class.SearchResultListWrapper, "UpdateShowMoreRowState", function(self)
        if not self.showMoreEntry or hidden == 0 then return end
        local label = self.showMoreEntry.label
        label:SetText(string.format(CW.L.STORE_IGNORE_SHOW_MORE, label:GetText(), hidden))
    end)

    AGS:RegisterCallback(AGS.callback.AFTER_FILTER_SETUP, function() RegisterFilter(AGS) end)
    AGS:RegisterCallback(AGS.callback.AFTER_INITIAL_SETUP, function()
        BuildPanel(ZO_TradingHouseBrowseItemsLeftPane)
        DrawRows()
        LibCustomMenu:RegisterContextMenu(AddMenuEntries, LibCustomMenu.CATEGORY_SECONDARY)
    end)
end
