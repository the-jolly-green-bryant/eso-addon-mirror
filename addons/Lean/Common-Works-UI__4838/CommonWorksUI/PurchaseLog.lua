-- Common Works -- guild store purchase log
--
-- Show guild-store purchase prices on later item tooltips; requires AGS's
-- ITEM_PURCHASED event for the price.
-- Key by item id and trait: quality upgrades replace the link, itemInstanceId and
-- uniqueId; mail attachments expose no instance id. Item id and trait survive both.

CommonWorksUI = CommonWorksUI or {}
local CW = CommonWorksUI

local WM = WINDOW_MANAGER

-- Same column as the ignore list, one slot higher.
local PANEL_W  = 400
local TOGGLE_W = 200
local ROW_H    = 24
local ROWS     = 20
local PAD      = 10
local BTN_H    = 28
local SCROLL_W = ZO_SCROLL_BAR_WIDTH
local ARROW_H  = 16    -- ZO_ScrollUpButton's height, which the bar anchors outside itself
local PANEL_H  = PAD + ROW_H + ROWS * ROW_H + PAD + BTN_H + PAD

-- Cap purchases per key, dropping the oldest to bound saved-variable growth.
local KEEP = 10

-- Forward declarations for mutually calling record and panel helpers.
local panel, toggle, header, rows, bar, DrawRows
local scroll = 0
-- SortedEntries' memo; nil means rebuild. Cleared by every write to the log.
local sorted, sortedSpent

-- What is worth a price memory: bought to use or to resell, not bought by the hundred.
-- Scribing scripts are one item type covering all three script slots.
local TRACKED = {
    [ITEMTYPE_ARMOR]                  = true,   -- jewelry too
    [ITEMTYPE_WEAPON]                 = true,
    [ITEMTYPE_RACIAL_STYLE_MOTIF]     = true,   -- books and chapters
    [ITEMTYPE_RECIPE]                 = true,   -- recipes, plans, diagrams, blueprints
    [ITEMTYPE_CRAFTED_ABILITY_SCRIPT] = true,
    [ITEMTYPE_CRAFTED_ABILITY]        = true,   -- grimoires
    [ITEMTYPE_MASTER_WRIT]            = true,
    -- Outfit style pages are collectibles, not motifs, and so are runeboxes.
    [ITEMTYPE_COLLECTIBLE]            = true,
}

local function PurchaseKey(itemLink)
    return string.format("%d:%d", GetItemLinkItemId(itemLink), GetItemLinkTraitInfo(itemLink))
end

local function Gold(amount)
    return ZO_Currency_FormatKeyboard(CURT_MONEY, amount, ZO_CURRENCY_FORMAT_AMOUNT_ICON)
end

-- Use guild history's localized relative age ("3 days ago").
local function Ago(stamp)
    return ZO_FormatDurationAgo(GetTimeStamp32() - stamp)
end

local function ItemName(itemLink)
    return zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink))
end

-- Record ---------------------------------------------------------------------

local function Record(itemData)
    local itemLink = itemData.itemLink
    if not TRACKED[GetItemLinkItemType(itemLink)] then return end

    local key = PurchaseKey(itemLink)
    local list = CW.SavedVars.purchases[key]
    if not list then
        list = {}
        CW.SavedVars.purchases[key] = list
    end
    table.insert(list, 1, {
        price  = itemData.purchasePrice,
        count  = itemData.stackCount,
        time   = GetTimeStamp32(),
        guild  = itemData.guildName,
        seller = itemData.sellerName,
        link   = itemLink,
    })
    for i = #list, KEEP + 1, -1 do list[i] = nil end

    sorted = nil
    -- The toggle carries the count, so it redraws even with the panel collapsed.
    if panel then DrawRows() end
end

-- Tooltip --------------------------------------------------------------------

local function PaidText(entry)
    if entry.count > 1 then
        return string.format(CW.L.PAID_STACK, Gold(entry.price), entry.count,
            Gold(zo_round(entry.price / entry.count)), Ago(entry.time))
    end
    return string.format(CW.L.PAID, Gold(entry.price), Ago(entry.time))
end

local function AppendPaid(tooltip, itemLink)
    if not itemLink or itemLink == "" then return end
    local list = CW.SavedVars.purchases[PurchaseKey(itemLink)]
    if not list then return end

    tooltip:AddVerticalPadding(4)
    ZO_Tooltip_AddDivider(tooltip)
    tooltip:AddLine(PaidText(list[1]), "ZoFontGame", ZO_HIGHLIGHT_TEXT:UnpackRGB())
    -- Weight the average by item count, including stacks.
    if #list > 1 then
        local total, items = 0, 0
        for i = 1, #list do
            total = total + list[i].price
            items = items + list[i].count
        end
        tooltip:AddLine(string.format(CW.L.PAID_AVERAGE, #list, Gold(zo_round(total / items))),
            "ZoFontGameSmall", ZO_NORMAL_TEXT:UnpackRGB())
    end
end

-- Use ZO_PostHook: tooltips are controls, while SecurePostHook requires a table.
-- Hook each surface; AGS routes store rows through SetLink (ItemDatabase.lua:21),
-- so also hooking SetTradingHouseItem would duplicate the tooltip line.
local function HookTooltips()
    ZO_PostHook(ItemTooltip, "SetBagItem", function(self, bagId, slotIndex)
        AppendPaid(self, GetItemLink(bagId, slotIndex))
    end)
    ZO_PostHook(ItemTooltip, "SetAttachedMailItem", function(self, mailId, attachIndex)
        AppendPaid(self, GetAttachedItemLink(mailId, attachIndex))
    end)
    -- Chat links, and every store result row through AGS.
    ZO_PostHook(ItemTooltip, "SetLink", AppendPaid)
    ZO_PostHook(PopupTooltip, "SetLink", AppendPaid)
end

-- Panel ----------------------------------------------------------------------

-- Rows change only with the log, so scrolling reuses the pass.
local function SortedEntries()
    if sorted then return sorted, sortedSpent end
    sorted, sortedSpent = {}, 0
    for key, entries in pairs(CW.SavedVars.purchases) do
        for i = 1, #entries do
            local entry = entries[i]
            sortedSpent = sortedSpent + entry.price
            sorted[#sorted + 1] = { key = key, index = i, entry = entry }
        end
    end
    table.sort(sorted, function(a, b) return a.entry.time > b.entry.time end)
    return sorted, sortedSpent
end

local function RowText(entry)
    local name = GetItemQualityColor(GetItemLinkDisplayQuality(entry.link)):Colorize(ItemName(entry.link))
    return string.format(CW.L.PAID_ROW, name, Gold(entry.price), Ago(entry.time))
end

function DrawRows()
    local list, spent = SortedEntries()
    local overflow = zo_max(0, #list - ROWS)
    scroll = zo_clamp(scroll, 0, overflow)
    -- The handler below ignores a value it already has, so this cannot loop.
    bar:SetMinMax(0, overflow)
    bar:SetValue(scroll)

    header:SetText(string.format(CW.L.PAID_TITLE, #list, Gold(spent)))
    toggle:SetText(string.format(CW.L.PAID_TOGGLE, #list))

    for i = 1, ROWS do
        local item = list[scroll + i]
        local row = rows[i]
        row:SetHidden(item == nil)
        row.remove:SetHidden(item == nil)
        if item then
            row.link = item.entry.link
            row.key, row.index = item.key, item.index
            row:SetText(RowText(item.entry))
        end
    end
end

local function Forget(key, index)
    local entries = CW.SavedVars.purchases[key]
    if not entries then return end
    table.remove(entries, index)
    if #entries == 0 then CW.SavedVars.purchases[key] = nil end
    sorted = nil
    DrawRows()
end

local CLEAR_DIALOG = "CW_PURCHASE_LOG_CLEAR"

ESO_Dialogs[CLEAR_DIALOG] = {
    title    = { text = CW.L.PAID_CLEAR_TITLE },
    mainText = { text = CW.L.PAID_CLEAR_PROMPT },
    buttons  = {
        {
            text = SI_DIALOG_CONFIRM,
            callback = function()
                ZO_ClearTable(CW.SavedVars.purchases)
                sorted = nil
                scroll = 0
                DrawRows()
            end,
        },
        { text = SI_DIALOG_CANCEL },
    },
}

local function BuildRow(i)
    local row = WM:CreateControl("CW_PurchaseLogRow" .. i, panel, CT_LABEL)
    row:SetDimensions(PANEL_W - PAD * 2 - ROW_H - SCROLL_W, ROW_H)
    row:SetFont("ZoFontGame")
    row:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row:SetMaxLineCount(1)
    row:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    row:SetMouseEnabled(true)
    row:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 0, (i - 1) * ROW_H)
    row:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(ItemTooltip, self, RIGHT, -10, 0)
        ItemTooltip:SetLink(self.link)
    end)
    row:SetHandler("OnMouseExit", function() ClearTooltip(ItemTooltip) end)

    -- The decline button the base game puts on its own ignore list rows
    -- (esoui/ingame/contacts/keyboard/ignorelist_keyboard.xml).
    local remove = WM:CreateControl("CW_PurchaseLogRemove" .. i, panel, CT_BUTTON)
    remove:SetDimensions(20, 20)
    remove:SetNormalTexture("EsoUI/Art/Buttons/decline_up.dds")
    remove:SetPressedTexture("EsoUI/Art/Buttons/decline_down.dds")
    remove:SetMouseOverTexture("EsoUI/Art/Buttons/decline_over.dds")
    remove:SetAnchor(LEFT, row, RIGHT, 4, 0)
    remove:SetHandler("OnClicked", function()
        Forget(row.key, row.index)
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
    toggle = WM:CreateControlFromVirtual("CW_PurchaseLogToggle", pane, "ZO_DefaultButton")
    toggle:SetDimensions(TOGGLE_W, BTN_H)
    -- Stack above the ignore tally; the shared AGS callback installs it first.
    toggle:SetAnchor(BOTTOM, CW_StoreIgnoreTally, TOP, 0, -6)

    panel = WM:CreateControl("CW_PurchaseLogPanel", pane, CT_CONTROL)
    panel:SetDimensions(PANEL_W, PANEL_H)
    panel:SetMouseEnabled(true)
    panel:SetMovable(true)
    panel:SetDrawTier(DT_HIGH)
    -- Anchor to the screen to avoid opening below the bottom-of-pane toggle.
    local pos = CW.SavedVars.purchaseLogPos
    panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, pos.x, pos.y)
    panel:SetHandler("OnMoveStart", function(self) self:SetClampedToScreen(true) end)
    panel:SetHandler("OnMoveStop", function(self)
        pos.x, pos.y = self:GetLeft(), self:GetTop()
        self:SetClampedToScreen(false)
    end)

    local bg = WM:CreateControlFromVirtual("CW_PurchaseLogBg", panel, "ZO_DefaultBackdrop")
    bg:ClearAnchors()
    bg:SetCenterColor(0, 0, 0, 1)
    bg:SetEdgeColor(0, 0, 0, 1)
    bg:SetAlpha(0.85)
    bg:SetAnchor(TOPLEFT, panel, TOPLEFT, 0, 0)
    bg:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, 0, 0)
    bg:SetDrawLevel(0)

    header = WM:CreateControl("CW_PurchaseLogHeader", panel, CT_LABEL)
    header:SetDimensions(PANEL_W - PAD * 2, ROW_H)
    header:SetFont("ZoFontHeader")
    header:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    header:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
    header:SetAnchor(TOPLEFT, panel, TOPLEFT, PAD, PAD)

    rows = {}
    for i = 1, ROWS do rows[i] = BuildRow(i) end

    local clear = WM:CreateControlFromVirtual("CW_PurchaseLogClear", panel, "ZO_DefaultButton")
    clear:SetDimensions(PANEL_W - PAD * 2, BTN_H)
    clear:SetText(CW.L.PAID_CLEAR)
    clear:SetAnchor(BOTTOM, panel, BOTTOM, 0, -PAD)
    clear:SetHandler("OnClicked", function()
        -- Nothing to lose, nothing to ask about.
        local count = #SortedEntries()
        if count == 0 then return end
        ZO_Dialogs_ShowDialog(CLEAR_DIALOG, nil, { mainTextParams = { count } })
    end)

    -- The wheel scrolls anywhere over the panel, quicker than the bar.
    panel:SetHandler("OnMouseWheel", function(_, delta)
        scroll = scroll - delta
        DrawRows()
    end)

    -- Inset by one arrow height to keep the externally anchored buttons inside the list.
    bar = WM:CreateControlFromVirtual("CW_PurchaseLogBar", panel, "ZO_VerticalScrollbarBase")
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
        CW.SavedVars.purchaseLogShown = not CW.SavedVars.purchaseLogShown
        panel:SetHidden(not CW.SavedVars.purchaseLogShown)
    end)
    panel:SetHidden(not CW.SavedVars.purchaseLogShown)
end

-- Hook tooltips before any trader visit so saved prices appear wherever items are viewed.
function CW.InstallPurchaseLog()
    if not CW.SavedVars.purchaseLog then return end
    local AGS = CW.GetAGS()
    if not AGS then return end

    HookTooltips()
    AGS:RegisterCallback(AGS.callback.ITEM_PURCHASED, Record)
    AGS:RegisterCallback(AGS.callback.AFTER_INITIAL_SETUP, function()
        BuildPanel(ZO_TradingHouseBrowseItemsLeftPane)
        DrawRows()
    end)
end
