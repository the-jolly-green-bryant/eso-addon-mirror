-- BuildTracker_PaperdollUI.lua
--
-- The main visual build editor: a build-switcher dropdown plus all 14 equip
-- slots grouped into three labeled cards - APPAREL, ACCESSORIES, WEAPONS -
-- stacked vertically, echoing the layout of the base game's own gamepad-mode
-- Inventory "Equipped" panel (the flat, rounded-card style shown when
-- pressing "I", not the keyboard-mode Character Sheet's 3D model). That
-- panel isn't something an addon can literally instantiate (gamepad-mode
-- screens are tied to a separate template/scene system), and its exact
-- texture assets weren't reachable to verify, so this mimics the *shape* of
-- it - section headers, card grouping, flat borders - using our own
-- hand-built controls rather than any borrowed asset. Exact pixel offsets
-- below are a first pass tuned by eye, not derived from any spec - expect
-- to nudge them after seeing this in game. Deeper color/typography styling
-- is intentionally deferred; this pass is the structural regroup only.
--
-- Built from raw control types, same singleton-window pattern as
-- BuildTracker_ExportImportUI.lua and BuildTracker_SetPickerUI.lua.

BuildTracker = BuildTracker or {}
BuildTracker.UI = BuildTracker.UI or {}

local UI = BuildTracker.UI
local window -- lazily created singleton

local WINDOW_WIDTH = 520 -- widened again (was 460) to fit the new Export/Import arrow buttons on the same row without crowding
local WINDOW_HEIGHT = 860
local SOCKET_SIZE = 60 -- was 52; bumped up so slot-name labels ("Shoulders" etc) fit without an ugly orphaned-letter wrap
local CARD_WIDTH = 300
local CARD_HEADER_OFFSET = 36 -- header label height + inner padding before the first slot row

-- {slotId, x, y} per section - x/y are offsets from the card's TOPLEFT,
-- already accounting for CARD_HEADER_OFFSET (added in CreateSlotControl).
-- Three shared columns (left/center/right = 58/130/202) so apparel,
-- accessories, and weapons all line up visually.
local APPAREL_LAYOUT = {
    { EQUIP_SLOT_HEAD,      130, 0 },
    { EQUIP_SLOT_SHOULDERS, 58,  72 },
    { EQUIP_SLOT_CHEST,     130, 72 },
    { EQUIP_SLOT_HAND,      202, 72 },
    { EQUIP_SLOT_WAIST,     130, 144 },
    { EQUIP_SLOT_LEGS,      130, 216 },
    { EQUIP_SLOT_FEET,      130, 288 },
}
local APPAREL_CARD_HEIGHT = CARD_HEADER_OFFSET + 288 + SOCKET_SIZE + 10

local ACCESSORY_LAYOUT = {
    { EQUIP_SLOT_NECK,  58,  0 },
    { EQUIP_SLOT_RING1, 130, 0 },
    { EQUIP_SLOT_RING2, 202, 0 },
}
local ACCESSORY_CARD_HEIGHT = CARD_HEADER_OFFSET + SOCKET_SIZE + 10

local WEAPON_LAYOUT = {
    { EQUIP_SLOT_MAIN_HAND,   58,  0 },
    { EQUIP_SLOT_OFF_HAND,    202, 0 },
    { EQUIP_SLOT_BACKUP_MAIN, 58,  72 },
    { EQUIP_SLOT_BACKUP_OFF,  202, 72 },
}
local WEAPON_CARD_HEIGHT = CARD_HEADER_OFFSET + 72 + SOCKET_SIZE + 10

-- Slot-name overrides for the in-socket fallback label only (tooltips,
-- /bt info, etc. keep using the full BuildTracker.SLOT_NAMES text) - even
-- at the larger SOCKET_SIZE, "Backup Main Hand"/"Backup Off Hand" are too
-- long to avoid an awkward wrap.
local SLOT_DISPLAY_LABEL_OVERRIDES = {
    [EQUIP_SLOT_BACKUP_MAIN] = "Bkp Main",
    [EQUIP_SLOT_BACKUP_OFF]  = "Bkp Off",
}
local function GetSlotDisplayLabel(slotId)
    return SLOT_DISPLAY_LABEL_OVERRIDES[slotId] or BuildTracker.SLOT_NAMES[slotId] or ""
end

-- 00FF00/FF3333/FFCC00 as 0-1 RGB, matching /bt owned's existing chat color scheme.
local COLOR_COLLECTED     = { 0, 1, 0, 1 }
local COLOR_NOT_COLLECTED = { 1, 0.2, 0.2, 1 }
local COLOR_UNKNOWN       = { 1, 0.8, 0, 1 }
local COLOR_UNASSIGNED    = { 0.4, 0.4, 0.4, 1 }

-- Fallback texture path for the Transmute Crystal currency icon (the same
-- blue seed-crystal icon the base game shows at a Transmutation station) -
-- confirmed against LootDrop's own CURT_CHAOTIC_CREATIA icon reference.
-- ZO_Currency_GetKeyboardCurrencyIcon(CURT_CHAOTIC_CREATIA) is tried first
-- in the tooltip code below since that's the officially sanctioned lookup
-- (won't break if ZOS ever moves the asset); this is only the safety net.
local TRANSMUTE_CRYSTAL_ICON_FALLBACK = "/esoui/art/currency/currency_seedcrystal_mipmap.dds"

local function SetWindowShown(shown)
    window:SetHidden(not shown)
    SetGameCameraUIMode(shown)
end

local function CreateTextButton(parent, text, width)
    local btn = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    btn:SetFont("ZoFontGameBold")
    btn:SetText("[ " .. text .. " ]")
    btn:SetColor(unpack(BuildTracker.UI_GOLD_TEXT))
    btn:SetMouseEnabled(true)
    btn:SetDimensions(width or 90, 24)
    btn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    btn:SetHandler("OnMouseEnter", function(self) self:SetColor(1, 1, 1, 1) end)
    btn:SetHandler("OnMouseExit", function(self) self:SetColor(unpack(BuildTracker.UI_GOLD_TEXT)) end)
    return btn
end

-- Which off-hand slot a two-handed weapon in the given main-hand slot
-- disables. Main and Backup bars stay fully independent - a two-handed
-- weapon in one never affects the other's off-hand slot.
local PAIRED_OFF_HAND_SLOT = {
    [EQUIP_SLOT_MAIN_HAND]   = EQUIP_SLOT_OFF_HAND,
    [EQUIP_SLOT_BACKUP_MAIN] = EQUIP_SLOT_BACKUP_OFF,
}

-- True if the given main-hand slot currently holds a two-handed weapon.
-- Checked fresh off the actual item (not the slot's stored equipType/
-- weaponType fields, which aren't reliably updated to the true resolved
-- hand-type - see Sets.GetItemIdForSlot's own comments) so this stays
-- correct regardless of how the assignment was made.
local function IsTwoHanded(build, slotId)
    local slotData = build.slots[slotId]
    if not slotData then return false end
    local itemLink = BuildTracker.Sets.BuildItemLink(slotData.itemId)
    if not itemLink then return false end
    local ok, equipType = pcall(GetItemLinkEquipType, itemLink)
    return ok and equipType == EQUIP_TYPE_TWO_HAND
end

-- `disabled` slots (an off-hand slot whose paired main-hand holds a
-- two-handed weapon) render as unavailable and ignore clicks/hover, but the
-- underlying build data is left untouched - swapping the main-hand weapon
-- back to one-handed makes whatever was here reappear automatically rather
-- than being silently lost.
local function RefreshSlot(slotId, status, disabled)
    local ctrl = window.slotControls[slotId]
    ctrl.disabled = disabled or false

    if disabled then
        ctrl.icon:SetHidden(true)
        ctrl.label:SetHidden(false)
        ctrl.label:SetText("Two-Handed")
        ctrl.clearBtn:SetHidden(true)
        ctrl.socket:SetEdgeColor(0.25, 0.25, 0.25, 1)
        ctrl.itemLink = nil
        ctrl.setId = nil
        ctrl.traitType = nil
        ctrl.enchantId = nil
        ctrl.tooltipItemLink = nil
        ctrl.traitEmbedded = false
        ctrl.enchantEmbedded = false
        return
    end

    local build = BuildTracker.Data.GetBuild(window.currentBuildId)
    local slotData = build and build.slots[slotId]

    if not slotData then
        ctrl.icon:SetHidden(true)
        ctrl.label:SetHidden(false)
        ctrl.label:SetText(GetSlotDisplayLabel(slotId))
        ctrl.clearBtn:SetHidden(true)
        ctrl.socket:SetEdgeColor(unpack(COLOR_UNASSIGNED))
        ctrl.itemLink = nil
        ctrl.setId = nil
        ctrl.traitType = nil
        ctrl.enchantId = nil
        ctrl.tooltipItemLink = nil
        ctrl.traitEmbedded = false
        ctrl.enchantEmbedded = false
        return
    end

    local itemLink = BuildTracker.Sets.BuildItemLink(slotData.itemId)
    -- Deliberately not "itemLink and pcall(...)" - Lua's `and` truncates a
    -- function call to its first return only, which would silently drop
    -- `icon` here every time.
    local icon
    if itemLink then
        local ok, result = pcall(GetItemLinkInfo, itemLink)
        if ok then icon = result end
    end
    if icon then
        ctrl.icon:SetTexture(icon)
        ctrl.icon:SetHidden(false)
        ctrl.label:SetHidden(true)
        ctrl.itemLink = itemLink
        ctrl.setId = slotData.setId
        ctrl.traitType = slotData.traitType
        ctrl.enchantId = slotData.enchantId

        -- Tooltip-only link, kept separate from ctrl.itemLink (used by
        -- reconstruction-cost/source-text lookups elsewhere) so an
        -- unverified guess here can never affect anything but the visual
        -- preview. Trait and enchant are verified independently (one can
        -- embed successfully while the other doesn't) via the base game's
        -- own GetItemLinkTraitType/GetItemLinkAppliedEnchantId - see
        -- Sets.BuildCustomizedItemLink's own comment for why this isn't
        -- guaranteed for either. Whichever doesn't verify falls back to its
        -- own explicit "Desired ..." tooltip line instead.
        ctrl.tooltipItemLink = itemLink
        ctrl.traitEmbedded = false
        ctrl.enchantEmbedded = false
        if slotData.traitType or slotData.enchantId then
            local candidate = BuildTracker.Sets.BuildCustomizedItemLink(slotData.itemId, slotData.traitType, slotData.enchantId)
            local usedCandidate = false
            if slotData.traitType then
                local ok, actualTrait = pcall(GetItemLinkTraitType, candidate)
                if ok and actualTrait == slotData.traitType then
                    ctrl.traitEmbedded = true
                    usedCandidate = true
                end
            end
            if slotData.enchantId then
                local ok, actualEnchant = pcall(GetItemLinkAppliedEnchantId, candidate)
                if ok and actualEnchant == slotData.enchantId then
                    ctrl.enchantEmbedded = true
                    usedCandidate = true
                end
            end
            if usedCandidate then
                ctrl.tooltipItemLink = candidate
            end
        end
    else
        -- Icon lookup failed for an already-validated itemId (shouldn't
        -- happen in practice) - fall back to the unassigned label rendering
        -- rather than guess at a "missing icon" texture path.
        ctrl.icon:SetHidden(true)
        ctrl.label:SetHidden(false)
        ctrl.label:SetText(GetSlotDisplayLabel(slotId))
        ctrl.itemLink = nil
        ctrl.setId = nil
        ctrl.traitType = nil
        ctrl.enchantId = nil
        ctrl.tooltipItemLink = nil
        ctrl.traitEmbedded = false
        ctrl.enchantEmbedded = false
    end
    ctrl.clearBtn:SetHidden(false)

    local isCollected = status[slotId]
    if isCollected == true then
        ctrl.socket:SetEdgeColor(unpack(COLOR_COLLECTED))
    elseif isCollected == false then
        ctrl.socket:SetEdgeColor(unpack(COLOR_NOT_COLLECTED))
    else
        ctrl.socket:SetEdgeColor(unpack(COLOR_UNKNOWN))
    end
end

local function RefreshAllSlots()
    if not window.currentBuildId then return end
    local build = BuildTracker.Data.GetBuild(window.currentBuildId)
    local status = BuildTracker.Ownership.GetBuildOwnershipStatus(window.currentBuildId)
    local disabledSlots = {}
    if build then
        for mainHandSlot, offHandSlot in pairs(PAIRED_OFF_HAND_SLOT) do
            disabledSlots[offHandSlot] = IsTwoHanded(build, mainHandSlot)
        end
    end
    for _, slotId in ipairs(BuildTracker.SLOT_ORDER) do
        RefreshSlot(slotId, status, disabledSlots[slotId])
    end
end

local function RefreshBuildSwitcher()
    local combo = window.buildSwitcher
    combo:ClearItems()
    for _, b in ipairs(BuildTracker.Data.GetAllBuildsSorted()) do
        local text = string.format("#%s - %s", b.id, BuildTracker.SanitizeDisplayText(b.name))
        local entry = combo:CreateItemEntry(text, function()
            window.currentBuildId = b.id
            BuildTracker.Data.SetLastSelectedBuildId(b.id)
            RefreshAllSlots()
        end)
        entry.buildTrackerBuildId = b.id
        combo:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)
        if b.id == window.currentBuildId then
            combo:SetSelectedItem(text)
        end
    end
    combo:UpdateItems()
end

-- A labeled, flat-bordered grouping panel - the closest stand-in we can
-- build ourselves for the reference screenshot's rounded "APPAREL"/
-- "ACCESSORIES"/"WEAPONS" cards, without any borrowed art asset (see file
-- header). Anchors below `anchorAbove`'s bottom-left, offset by xOffset so
-- every card ends up left-aligned at the same absolute x regardless of
-- anchorAbove's own width (the build switcher is narrower than a card and
-- isn't centered the same way, so a plain TOP-to-BOTTOM anchor would have
-- misaligned the first card - each caller passes the xOffset needed to
-- correct for that).
local function CreateSectionCard(parent, anchorAbove, xOffset, yGap, title, height)
    local card = WINDOW_MANAGER:CreateControl(nil, parent, CT_BACKDROP)
    card:SetDimensions(CARD_WIDTH, height)
    card:SetAnchor(TOPLEFT, anchorAbove, BOTTOMLEFT, xOffset, yGap)
    card:SetCenterColor(0.09, 0.09, 0.12, 0.85)
    BuildTracker.ApplyWindowBorder(card)

    local header = WINDOW_MANAGER:CreateControl(nil, card, CT_LABEL)
    header:SetAnchor(TOPLEFT, card, TOPLEFT, 12, 8)
    header:SetFont("ZoFontGameBold")
    header:SetText(title)
    header:SetColor(unpack(BuildTracker.UI_GOLD_TEXT))

    return card
end

local function CreateSlotControl(card, slotId, x, y)
    local ctrl = {} -- built up as controls are created so handlers below can close over it (e.g. ctrl.itemLink for the hover tooltip)

    local socket = WINDOW_MANAGER:CreateControl(nil, card, CT_BACKDROP)
    socket:SetDimensions(SOCKET_SIZE, SOCKET_SIZE)
    socket:SetAnchor(TOPLEFT, card, TOPLEFT, x, CARD_HEADER_OFFSET + y)
    socket:SetCenterColor(0.14, 0.14, 0.17, 0.9)
    socket:SetEdgeColor(unpack(COLOR_UNASSIGNED))
    ctrl.socket = socket

    -- CT_BACKDROP does not appear to support direct mouse interaction in
    -- this client - SetMouseEnabled(true) on the backdrop itself (and on
    -- its CT_BACKDROP parent `card`) had zero effect on click/hover in
    -- testing. Every control in this addon that's actually confirmed to
    -- receive mouse events (dragHandle, Rename/+/-/Close) is CT_CONTROL or
    -- CT_LABEL, never CT_BACKDROP. This invisible CT_CONTROL overlay - the
    -- same type as the proven-working dragHandle - carries the real
    -- handlers instead; `socket` stays a pure visual backdrop (border color
    -- still drives the ownership-status coding via RefreshSlot).
    local hitArea = WINDOW_MANAGER:CreateControl(nil, socket, CT_CONTROL)
    hitArea:SetAnchorFill(socket)
    hitArea:SetMouseEnabled(true)
    hitArea:SetHandler("OnMouseUp", function(_, button, upInside)
        if ctrl.disabled then return end
        if not upInside then return end
        if button == MOUSE_BUTTON_INDEX_LEFT then
            BuildTracker.UI.ShowSetPicker(window.currentBuildId, slotId)
        elseif button == MOUSE_BUTTON_INDEX_RIGHT and ctrl.itemLink then
            -- Only meaningful once a set is assigned - nothing to tag a
            -- trait/enchantment note onto otherwise.
            BuildTracker.UI.ShowSlotOptions(window.currentBuildId, slotId)
        end
    end)
    -- Item tooltip only makes sense once a set is assigned; ctrl.itemLink/
    -- ctrl.setId/ctrl.traitType/ctrl.enchantId are kept up to date by
    -- RefreshSlot (nil when the slot is empty or disabled). The
    -- trait/enchant/source/reconstruction lines are appended after the base
    -- game's own set-bonus tooltip content, separated by a divider - same
    -- visual pattern LibSets itself uses for its tooltip hook.
    hitArea:SetHandler("OnMouseEnter", function(self)
        if ctrl.disabled then
            ZO_Tooltips_ShowTextTooltip(self, TOP, "Unavailable while a two-handed weapon is equipped in the paired main-hand slot.")
        elseif ctrl.itemLink then
            InitializeTooltip(ItemTooltip, self, TOP, 0, 0, BOTTOM)
            ItemTooltip:SetLink(ctrl.tooltipItemLink or ctrl.itemLink)

            if ctrl.setId then
                -- Only shown as fallbacks: if ctrl.traitEmbedded/
                -- ctrl.enchantEmbedded is true, the native line above (from
                -- ctrl.tooltipItemLink) already reflects that choice, so
                -- repeating it here would just be redundant - each verifies
                -- independently, see Sets.BuildCustomizedItemLink's comment
                -- for why neither is guaranteed.
                local traitName = not ctrl.traitEmbedded and BuildTracker.UI.GetTraitName(ctrl.traitType)
                local enchantName = not ctrl.enchantEmbedded and BuildTracker.UI.GetEnchantName(ctrl.enchantId)
                local sourceText = BuildTracker.Sets.GetSetSourceText(ctrl.setId)
                    or BuildTracker.Sets.GetCraftLocationText(ctrl.setId)
                local reconstructionCost = BuildTracker.Sets.GetSetReconstructionCost(ctrl.setId, ctrl.itemLink)
                if traitName or enchantName or sourceText or reconstructionCost then
                    ZO_Tooltip_AddDivider(ItemTooltip)
                    if traitName then ItemTooltip:AddLine("Desired Trait: " .. traitName) end
                    if enchantName then ItemTooltip:AddLine("Desired Enchantment: " .. enchantName) end
                    if sourceText then ItemTooltip:AddLine(sourceText) end
                    if reconstructionCost then
                        -- ZO_Currency_GetKeyboardCurrencyIcon is the officially
                        -- sanctioned currency-icon lookup (won't break if ZOS
                        -- ever moves the asset); TRANSMUTE_CRYSTAL_ICON_FALLBACK
                        -- is the safety net if that lookup isn't available.
                        local iconPath = TRANSMUTE_CRYSTAL_ICON_FALLBACK
                        if ZO_Currency_GetKeyboardCurrencyIcon and CURT_CHAOTIC_CREATIA then
                            local okIcon, result = pcall(ZO_Currency_GetKeyboardCurrencyIcon, CURT_CHAOTIC_CREATIA)
                            if okIcon and result and result ~= "" then iconPath = result end
                        end
                        ItemTooltip:AddLine(string.format("Reconstruct: %d %s", reconstructionCost, zo_iconFormatInheritColor(iconPath, 16, 16)))
                    end
                end
            end
        end
    end)
    hitArea:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
        ClearTooltip(ItemTooltip)
    end)

    local icon = WINDOW_MANAGER:CreateControl(nil, socket, CT_TEXTURE)
    icon:SetAnchor(TOPLEFT, socket, TOPLEFT, 3, 3)
    icon:SetAnchor(BOTTOMRIGHT, socket, BOTTOMRIGHT, -3, -3)
    icon:SetHidden(true)
    ctrl.icon = icon

    local label = WINDOW_MANAGER:CreateControl(nil, socket, CT_LABEL)
    label:SetAnchorFill(socket)
    label:SetFont("ZoFontGameSmall")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    ctrl.label = label

    -- Real base-game close-button icon (CT_BUTTON handles hover/press states
    -- via texture swap natively) instead of a font-glyph "x" - confirmed
    -- path used by several installed addons (AutoCategory, LibSFUtils,
    -- ActionDurationReminder) for exactly this close/cancel purpose.
    local clearBtn = WINDOW_MANAGER:CreateControl(nil, socket, CT_BUTTON)
    clearBtn:SetAnchor(TOPRIGHT, socket, TOPRIGHT, 4, -4)
    clearBtn:SetDimensions(18, 18)
    clearBtn:SetNormalTexture("/esoui/art/buttons/closebutton_up.dds")
    clearBtn:SetPressedTexture("/esoui/art/buttons/closebutton_down.dds")
    clearBtn:SetMouseOverTexture("/esoui/art/buttons/closebutton_mouseover.dds")
    clearBtn:SetDisabledTexture("/esoui/art/buttons/closebutton_disabled.dds")
    clearBtn:SetMouseEnabled(true)
    clearBtn:SetHidden(true)
    clearBtn:SetClickSound("Click")
    clearBtn:SetHandler("OnClicked", function()
        BuildTracker.Data.ClearBuildSlot(window.currentBuildId, slotId)
    end)
    ctrl.clearBtn = clearBtn

    return ctrl
end

-- Small rename popup - its own singleton (not reusing the ExportImportUI
-- popup, since that's a different modal surface that could legitimately be
-- open for something else) so it can float above the still-open paperdoll.
local renamePopup

local function EnsureRenamePopup()
    if renamePopup then return renamePopup end

    renamePopup = WINDOW_MANAGER:CreateTopLevelWindow("BuildTracker_RenamePopup")
    renamePopup:SetDimensions(320, 130)
    renamePopup:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    renamePopup:SetMouseEnabled(true)
    renamePopup:SetMovable(true)
    renamePopup:SetClampedToScreen(true)
    renamePopup:SetHidden(true)
    renamePopup:SetDrawTier(DT_HIGH)
    -- Same tier as the main paperdoll window isn't enough to guarantee this
    -- renders in front of it (confirmed: it was opening behind the still-
    -- open paperdoll) - a higher DrawLevel within that tier breaks the tie.
    renamePopup:SetDrawLevel(10)

    local bg = WINDOW_MANAGER:CreateControl(nil, renamePopup, CT_BACKDROP)
    bg:SetCenterColor(0.05, 0.05, 0.08, 0.97)
    BuildTracker.ApplyWindowBorder(bg, renamePopup)

    local title = WINDOW_MANAGER:CreateControl(nil, renamePopup, CT_LABEL)
    title:SetAnchor(TOPLEFT, renamePopup, TOPLEFT, 12, 10)
    title:SetFont("ZoFontWinH4")
    title:SetText("Rename Build")

    local editBoxBG = WINDOW_MANAGER:CreateControl(nil, renamePopup, CT_BACKDROP)
    editBoxBG:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 12)
    editBoxBG:SetDimensions(296, 26)
    editBoxBG:SetCenterColor(0, 0, 0, 0.6)
    editBoxBG:SetEdgeColor(0.3, 0.3, 0.3, 1)

    local editBox = WINDOW_MANAGER:CreateControl(nil, editBoxBG, CT_EDITBOX)
    editBox:SetAnchorFill(editBoxBG)
    editBox:SetFont("ZoFontGame")
    editBox:SetMaxInputChars(64)
    editBox:SetMouseEnabled(true)
    editBox:SetHandler("OnMouseUp", function(self, _, upInside)
        if upInside then
            self:TakeFocus()
            self:SelectAll()
        end
    end)
    renamePopup.editBox = editBox

    local function Confirm()
        local ok, err = BuildTracker.Data.RenameBuild(renamePopup.buildId, editBox:GetText())
        if ok then
            renamePopup:SetHidden(true)
            RefreshBuildSwitcher()
        else
            d("|cFFA500[BT]|r Error: " .. tostring(err))
        end
    end
    editBox:SetHandler("OnEnter", Confirm)
    editBox:SetHandler("OnEscape", function() renamePopup:SetHidden(true) end)

    local saveBtn = CreateTextButton(renamePopup, "Save", 80)
    saveBtn:SetAnchor(BOTTOMRIGHT, renamePopup, BOTTOMRIGHT, -10, -10)
    saveBtn:SetHandler("OnMouseUp", function(_, _, upInside) if upInside then Confirm() end end)

    local cancelBtn = CreateTextButton(renamePopup, "Cancel", 80)
    cancelBtn:SetAnchor(BOTTOMRIGHT, saveBtn, BOTTOMLEFT, -10, 0)
    cancelBtn:SetHandler("OnMouseUp", function(_, _, upInside)
        if upInside then renamePopup:SetHidden(true) end
    end)

    return renamePopup
end

-- Public entry point - the "Rename" button next to the build switcher.
function UI.ShowRenamePrompt(buildId, currentName)
    local p = EnsureRenamePopup()
    p.buildId = buildId
    SetGameCameraUIMode(true) -- the main paperdoll window is already open and owns turning this off again on close
    p:SetHidden(false)
    p.editBox:SetText(currentName)
    p.editBox:TakeFocus()
    p.editBox:SelectAll()
end

-- Delete confirmation - deletion is destructive (wipes the build's slots),
-- so this asks first rather than deleting on a single misclick.
local deleteConfirmPopup

local function EnsureDeleteConfirmPopup()
    if deleteConfirmPopup then return deleteConfirmPopup end

    deleteConfirmPopup = WINDOW_MANAGER:CreateTopLevelWindow("BuildTracker_DeleteConfirmPopup")
    deleteConfirmPopup:SetDimensions(340, 140)
    deleteConfirmPopup:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    deleteConfirmPopup:SetMouseEnabled(true)
    deleteConfirmPopup:SetMovable(true)
    deleteConfirmPopup:SetClampedToScreen(true)
    deleteConfirmPopup:SetHidden(true)
    deleteConfirmPopup:SetDrawTier(DT_HIGH)
    deleteConfirmPopup:SetDrawLevel(10) -- same tie-break as the rename popup, see its comment

    local bg = WINDOW_MANAGER:CreateControl(nil, deleteConfirmPopup, CT_BACKDROP)
    bg:SetCenterColor(0.05, 0.05, 0.08, 0.97)
    BuildTracker.ApplyWindowBorder(bg, deleteConfirmPopup)

    local title = WINDOW_MANAGER:CreateControl(nil, deleteConfirmPopup, CT_LABEL)
    title:SetAnchor(TOPLEFT, deleteConfirmPopup, TOPLEFT, 12, 10)
    title:SetFont("ZoFontWinH4")
    title:SetText("Delete Build")

    local message = WINDOW_MANAGER:CreateControl(nil, deleteConfirmPopup, CT_LABEL)
    message:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 12)
    message:SetDimensions(316, 50)
    message:SetFont("ZoFontGame")
    message:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    deleteConfirmPopup.message = message

    local function Confirm()
        -- Stays "in place" in the list (whatever now occupies the deleted
        -- build's old position) rather than jumping back to the first
        -- build every time - lets repeated clicks mass-delete without
        -- having to re-pick a build from the dropdown each time.
        local nextId = BuildTracker.Data.DeleteBuildAndGetNext(deleteConfirmPopup.buildId)
        deleteConfirmPopup:SetHidden(true)
        if nextId then
            UI.ShowPaperdoll(nextId)
        elseif window then
            SetWindowShown(false)
        end
    end

    local deleteBtn = CreateTextButton(deleteConfirmPopup, "Delete", 90)
    deleteBtn:SetAnchor(BOTTOMRIGHT, deleteConfirmPopup, BOTTOMRIGHT, -10, -10)
    deleteBtn:SetHandler("OnMouseUp", function(_, _, upInside) if upInside then Confirm() end end)

    local cancelBtn = CreateTextButton(deleteConfirmPopup, "Cancel", 90)
    cancelBtn:SetAnchor(BOTTOMRIGHT, deleteBtn, BOTTOMLEFT, -10, 0)
    cancelBtn:SetHandler("OnMouseUp", function(_, _, upInside)
        if upInside then deleteConfirmPopup:SetHidden(true) end
    end)

    return deleteConfirmPopup
end

-- Public entry point - the "-" button next to the build switcher.
function UI.ShowDeleteConfirm(buildId, buildName)
    local p = EnsureDeleteConfirmPopup()
    p.buildId = buildId
    p.message:SetText(string.format('Delete build "%s"? This cannot be undone.', BuildTracker.SanitizeDisplayText(buildName)))
    SetGameCameraUIMode(true)
    p:SetHidden(false)
end

local function EnsureWindow()
    if window then return window end

    window = WINDOW_MANAGER:CreateTopLevelWindow("BuildTracker_PaperdollWindow")
    window:SetDimensions(WINDOW_WIDTH, WINDOW_HEIGHT)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, -60)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)
    -- Without this, this window can sit at a lower effective input/render
    -- priority than whatever else is on screen (e.g. the base game's own
    -- Inventory/Character screen) - the set picker popup already had this,
    -- the main window did not, which is a likely reason clicks/hover on
    -- the slots weren't registering.
    window:SetDrawTier(DT_HIGH)

    local bg = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    bg:SetCenterColor(0.05, 0.05, 0.08, 0.95)
    BuildTracker.ApplyWindowBorder(bg, window)

    local dragHandle = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
    dragHandle:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    dragHandle:SetAnchor(TOPRIGHT, window, TOPRIGHT, 0, 0)
    dragHandle:SetHeight(28)
    dragHandle:SetMouseEnabled(true)
    dragHandle:SetHandler("OnDragStart", function() window:StartMoving() end)
    dragHandle:SetHandler("OnMouseUp", function() window:StopMovingOrResizing() end)

    local title = WINDOW_MANAGER:CreateControl(nil, dragHandle, CT_LABEL)
    title:SetAnchor(TOPLEFT, dragHandle, TOPLEFT, 10, 6)
    title:SetFont("ZoFontWinH4")
    title:SetText("Build Tracker - Build List") -- display text only, see file header - stays "paperdoll" internally

    local buildSwitcherContainer = WINDOW_MANAGER:CreateControlFromVirtual("BuildTracker_PaperdollBuildSwitcher", window, "ZO_ComboBox")
    buildSwitcherContainer:SetAnchor(TOPLEFT, dragHandle, BOTTOMLEFT, 10, 10)
    buildSwitcherContainer:SetDimensions(180, 26)
    local buildSwitcher = ZO_ComboBox_ObjectFromContainer(buildSwitcherContainer)
    buildSwitcher:SetSortsItems(false)
    window.buildSwitcher = buildSwitcher

    -- Renaming the active build directly from the dropdown's own click isn't
    -- safe to hook - that click is already reserved by ZO_ComboBox to open
    -- the list, and overriding it risks breaking build switching entirely.
    -- This adjacent button is the safer equivalent. Width bumped to 110 -
    -- 70 wasn't wide enough for "[ Rename ]" and may have been visually
    -- overlapping/hiding the + button that followed it.
    local renameBtn = CreateTextButton(window, "Rename", 110)
    renameBtn:SetAnchor(LEFT, buildSwitcherContainer, RIGHT, 10, 0)
    renameBtn:SetHandler("OnMouseUp", function(_, button, upInside)
        if upInside and button == MOUSE_BUTTON_INDEX_LEFT and window.currentBuildId then
            local build = BuildTracker.Data.GetBuild(window.currentBuildId)
            if build then
                UI.ShowRenamePrompt(window.currentBuildId, build.name)
            end
        end
    end)

    -- Real base-game plus-button icon (CT_BUTTON handles hover/press states
    -- via texture swap natively) instead of a font-glyph "+" - confirmed
    -- path used by AutoCategory and LibAddonMenuOrderListBox for exactly
    -- this "add a new entry" purpose.
    local addBuildBtn = WINDOW_MANAGER:CreateControl(nil, window, CT_BUTTON)
    addBuildBtn:SetAnchor(LEFT, renameBtn, RIGHT, 14, 0)
    addBuildBtn:SetDimensions(28, 28)
    addBuildBtn:SetNormalTexture("/esoui/art/buttons/plus_up.dds")
    addBuildBtn:SetPressedTexture("/esoui/art/buttons/plus_down.dds")
    addBuildBtn:SetMouseOverTexture("/esoui/art/buttons/plus_over.dds")
    addBuildBtn:SetDisabledTexture("/esoui/art/buttons/plus_disabled.dds")
    addBuildBtn:SetMouseEnabled(true)
    addBuildBtn:SetClickSound("Click")
    addBuildBtn:SetHandler("OnMouseEnter", function(self)
        ZO_Tooltips_ShowTextTooltip(self, TOP, "Create New")
    end)
    addBuildBtn:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)
    addBuildBtn:SetHandler("OnClicked", function()
        local newId = BuildTracker.Data.CreateBuild()
        UI.ShowPaperdoll(newId)
    end)

    -- Real base-game minus-button icon, same reasoning as addBuildBtn above -
    -- confirmed path used by AutoCategory and LibAddonMenuOrderListBox for
    -- exactly this "remove an entry" purpose.
    local deleteBuildBtn = WINDOW_MANAGER:CreateControl(nil, window, CT_BUTTON)
    deleteBuildBtn:SetAnchor(LEFT, addBuildBtn, RIGHT, 10, 0)
    deleteBuildBtn:SetDimensions(28, 28)
    deleteBuildBtn:SetNormalTexture("/esoui/art/buttons/minus_up.dds")
    deleteBuildBtn:SetPressedTexture("/esoui/art/buttons/minus_down.dds")
    deleteBuildBtn:SetMouseOverTexture("/esoui/art/buttons/minus_over.dds")
    deleteBuildBtn:SetDisabledTexture("/esoui/art/buttons/minus_disabled.dds")
    deleteBuildBtn:SetMouseEnabled(true)
    deleteBuildBtn:SetClickSound("Click")
    deleteBuildBtn:SetHandler("OnMouseEnter", function(self)
        ZO_Tooltips_ShowTextTooltip(self, TOP, "Delete Build")
    end)
    deleteBuildBtn:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)
    deleteBuildBtn:SetHandler("OnClicked", function()
        if window.currentBuildId then
            local build = BuildTracker.Data.GetBuild(window.currentBuildId)
            if build then
                UI.ShowDeleteConfirm(window.currentBuildId, build.name)
            end
        end
    end)

    -- Export/Import - up/down arrow placeholders per user request. Real
    -- base-game scrollbox arrow button icons (confirmed path used by
    -- LibAddonMenuOrderListBox for its own move-up/move-down buttons),
    -- same "real icon over font glyph" reasoning as addBuildBtn/deleteBuildBtn
    -- above. Reuses the exact same BuildTracker.ExportImport/UI.ShowExportBox/
    -- ShowImportBox functions the /bt export and /bt import slash commands
    -- already call - no new export/import logic, just a UI shortcut for the
    -- build currently shown in the paperdoll.
    local exportBuildBtn = WINDOW_MANAGER:CreateControl(nil, window, CT_BUTTON)
    exportBuildBtn:SetAnchor(LEFT, deleteBuildBtn, RIGHT, 14, 0)
    exportBuildBtn:SetDimensions(28, 28)
    exportBuildBtn:SetNormalTexture("/esoui/art/buttons/scrollbox_uparrow_up.dds")
    exportBuildBtn:SetPressedTexture("/esoui/art/buttons/scrollbox_uparrow_down.dds")
    exportBuildBtn:SetMouseOverTexture("/esoui/art/buttons/scrollbox_uparrow_over.dds")
    exportBuildBtn:SetDisabledTexture("/esoui/art/buttons/scrollbox_uparrow_up_disabled.dds")
    exportBuildBtn:SetMouseEnabled(true)
    exportBuildBtn:SetClickSound("Click")
    exportBuildBtn:SetHandler("OnMouseEnter", function(self)
        ZO_Tooltips_ShowTextTooltip(self, TOP, "Export Build")
    end)
    exportBuildBtn:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)
    exportBuildBtn:SetHandler("OnClicked", function()
        if not window.currentBuildId then return end
        local build = BuildTracker.Data.GetBuild(window.currentBuildId)
        local str, err = BuildTracker.ExportImport.ExportBuild(window.currentBuildId)
        if str then
            BuildTracker.UI.ShowExportBox("Export: " .. (build and build.name or ("#" .. tostring(window.currentBuildId))), str)
        else
            d("|cFFA500[BT]|r Error: " .. tostring(err))
        end
    end)

    local importBuildBtn = WINDOW_MANAGER:CreateControl(nil, window, CT_BUTTON)
    importBuildBtn:SetAnchor(LEFT, exportBuildBtn, RIGHT, 10, 0)
    importBuildBtn:SetDimensions(28, 28)
    importBuildBtn:SetNormalTexture("/esoui/art/buttons/scrollbox_downarrow_up.dds")
    importBuildBtn:SetPressedTexture("/esoui/art/buttons/scrollbox_downarrow_down.dds")
    importBuildBtn:SetMouseOverTexture("/esoui/art/buttons/scrollbox_downarrow_over.dds")
    importBuildBtn:SetDisabledTexture("/esoui/art/buttons/scrollbox_downarrow_up_disabled.dds")
    importBuildBtn:SetMouseEnabled(true)
    importBuildBtn:SetClickSound("Click")
    importBuildBtn:SetHandler("OnMouseEnter", function(self)
        ZO_Tooltips_ShowTextTooltip(self, TOP, "Import Build")
    end)
    importBuildBtn:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)
    importBuildBtn:SetHandler("OnClicked", function()
        BuildTracker.UI.ShowImportBox(function(text)
            local newId, err = BuildTracker.ExportImport.ImportBuild(text)
            if newId then
                d("|cFFA500[BT]|r Imported as build #" .. newId)
                UI.ShowPaperdoll(newId) -- switch to the newly imported build, same as the + button does for a newly created one
            else
                d("|cFFA500[BT]|r Error: " .. tostring(err))
            end
        end)
    end)

    -- Help - moved here from a standalone top-right icon (CT_TEXTURE +
    -- OnMouseUp), which never registered clicks reliably. This is a plain
    -- CT_BUTTON using OnClicked, the exact same mechanism as every other
    -- button in this row (Rename/+/-/Export/Import), all confirmed
    -- clickable in-game - simpler than chasing why the texture approach
    -- didn't work. Uses the real base-game "info" button art
    -- (`/esoui/art/buttons/info_*.dds`, confirmed via SkillPointAlerts'
    -- own XML) instead of the bare `help_icon.dds` glyph, since it's from
    -- the same button-texture family (bordered square with baked-in icon)
    -- as the plus/minus/scrollbox-arrow buttons beside it - `help_icon.dds`
    -- is just a flat glyph with no border and looked visually inconsistent
    -- next to them.
    local helpBtn = WINDOW_MANAGER:CreateControl(nil, window, CT_BUTTON)
    helpBtn:SetAnchor(LEFT, importBuildBtn, RIGHT, 14, 0)
    helpBtn:SetDimensions(28, 28)
    helpBtn:SetNormalTexture("/esoui/art/buttons/info_up.dds")
    helpBtn:SetPressedTexture("/esoui/art/buttons/info_down.dds")
    helpBtn:SetMouseOverTexture("/esoui/art/buttons/info_over.dds")
    helpBtn:SetDisabledTexture("/esoui/art/buttons/info_disabled.dds")
    helpBtn:SetMouseEnabled(true)
    helpBtn:SetClickSound("Click")
    helpBtn:SetHandler("OnMouseEnter", function(self)
        ZO_Tooltips_ShowTextTooltip(self, TOP, "Help")
    end)
    helpBtn:SetHandler("OnMouseExit", function()
        ZO_Tooltips_HideTextTooltip()
    end)
    helpBtn:SetHandler("OnClicked", function()
        BuildTracker.UI.ShowHelp()
    end)

    window.slotControls = {}

    local function PopulateCard(card, layout)
        for _, entry in ipairs(layout) do
            local slotId, x, y = entry[1], entry[2], entry[3]
            window.slotControls[slotId] = CreateSlotControl(card, slotId, x, y)
        end
    end

    -- buildSwitcherContainer sits at x=10 from the window's left edge (via
    -- dragHandle) and is narrower than a card, so the first card needs a
    -- corrective x offset (computed below via cardLeftMargin - 10) to land
    -- at the same left edge that the later cards inherit for free by
    -- anchoring to the previous card's left edge.
    local cardLeftMargin = (WINDOW_WIDTH - CARD_WIDTH) / 2
    local apparelCard = CreateSectionCard(window, buildSwitcherContainer, cardLeftMargin - 10, 20, "APPAREL", APPAREL_CARD_HEIGHT)
    PopulateCard(apparelCard, APPAREL_LAYOUT)

    local accessoryCard = CreateSectionCard(window, apparelCard, 0, 12, "ACCESSORIES", ACCESSORY_CARD_HEIGHT)
    PopulateCard(accessoryCard, ACCESSORY_LAYOUT)

    local weaponCard = CreateSectionCard(window, accessoryCard, 0, 12, "WEAPONS", WEAPON_CARD_HEIGHT)
    PopulateCard(weaponCard, WEAPON_LAYOUT)

    local closeBtn = CreateTextButton(window, "Close")
    closeBtn:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -10, -10)
    closeBtn:SetHandler("OnMouseUp", function(_, _, upInside)
        if upInside then SetWindowShown(false) end
    end)

    return window
end

-- Public entry point.
function UI.ShowPaperdoll(buildId)
    local w = EnsureWindow()
    w.currentBuildId = buildId
    BuildTracker.Data.SetLastSelectedBuildId(buildId)
    RefreshBuildSwitcher()
    RefreshAllSlots()
    SetWindowShown(true)
end

-- Entry point for the optional, unbound-by-default keybind - see
-- BuildTracker_Bindings.xml. Closes the window if it's already open,
-- otherwise opens it to the remembered last-selected build (or the first
-- build if none is remembered yet).
function UI.TogglePaperdollFromKeybind()
    if window and not window:IsHidden() then
        SetWindowShown(false)
        return
    end
    local buildId = BuildTracker.Data.GetDefaultBuildId()
    if not buildId then
        d("|cFFA500[BT]|r No builds yet. Try /bt new <name> first.")
        return
    end
    UI.ShowPaperdoll(buildId)
end

-- Keep the open window in sync whether the change came from this UI or from
-- a /bt slash command. No-ops entirely while the window doesn't exist yet
-- or is closed, so there's no cost when the paperdoll isn't in use.
--
-- A change to a weapon slot can affect its PAIRED off-hand slot's disabled
-- state (see PAIRED_OFF_HAND_SLOT/IsTwoHanded above), so those four slots
-- trigger a full RefreshAllSlots() rather than just refreshing the one that
-- literally changed - simpler and safer than tracking the pairing here too.
local function RefreshChangedSlot(buildId, slotId)
    if not (window and not window:IsHidden() and buildId == window.currentBuildId) then return end
    if BuildTracker.WEAPON_SLOTS[slotId] then
        RefreshAllSlots()
    else
        RefreshSlot(slotId, BuildTracker.Ownership.GetBuildOwnershipStatus(buildId))
    end
end
CALLBACK_MANAGER:RegisterCallback(BuildTracker.EVENTS.SLOT_SET, RefreshChangedSlot)
CALLBACK_MANAGER:RegisterCallback(BuildTracker.EVENTS.SLOT_CLEARED, RefreshChangedSlot)
CALLBACK_MANAGER:RegisterCallback(BuildTracker.EVENTS.BUILD_CHANGED, function(buildId)
    if window and not window:IsHidden() and buildId == window.currentBuildId then
        RefreshAllSlots()
    end
end)
-- Deletion also renumbers every higher-numbered build (see Data.DeleteBuild)
-- - if that happened via /bt delete rather than this window's own "-"
-- button, the open switcher's labels could go stale, or (if the deleted
-- build was the one on screen) window.currentBuildId could point at
-- nothing. Re-sync in both cases. KNOWN GAP: if a *different*, unrelated
-- build's id shifted under the one currently on screen, this doesn't
-- detect that (there's no stable identity to notice the shift by, only the
-- id itself) - narrow edge case, only reachable via /bt delete + paperdoll
-- open on a higher-numbered build at the same time.
CALLBACK_MANAGER:RegisterCallback(BuildTracker.EVENTS.BUILD_DELETED, function()
    if not (window and not window:IsHidden()) then return end
    if BuildTracker.Data.GetBuild(window.currentBuildId) then
        RefreshBuildSwitcher()
    else
        local nextId = BuildTracker.Data.GetDefaultBuildId()
        if nextId then
            UI.ShowPaperdoll(nextId)
        else
            SetWindowShown(false)
        end
    end
end)
