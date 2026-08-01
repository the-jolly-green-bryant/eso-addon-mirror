-- Transmute Set Crafter — Queue list + add/edit flow
--
-- The right panel of the main window. Each row shows one queued
-- reconstruction request: set, type (with armor weight color), trait,
-- enchantment. Hovering a row pops a live preview tooltip with the
-- chosen trait + quality + planned glyph baked into the link.
--
-- Also owns the "Add to Queue" / "Update Entry" / "Cancel Edit" /
-- "Edit Row" interactions, which read the selected pieces + dropdown
-- picks from TSC._UI and route to Queue.lua's AddToQueue/UpdateQueueEntry.

local TSC = TransmuteSetCrafter
local UI  = TSC._UI

local QUEUE_ENTRY      = 3   -- ScrollList data type id (must match TSC convention)
local QUEUE_ROW_HEIGHT = 30

-- ── Column layout ─────────────────────────────────────────
-- Column widths flex with the queue list width. Proportions sum to 1.

local QUEUE_LEFT_PAD   = 4
local QUEUE_RIGHT_PAD  = 4
local QUEUE_BUTTON_PAD = 68   -- Edit (36) + gap (4) + Close (24) + 4px right margin
local QUEUE_COL_GAP    = 4
local QUEUE_HEADER_GAP = 22   -- vertical gap from header baseline to list top
local QUEUE_SCROLLBAR  = 18   -- scrollbar reserved on the right of the list

local QUEUE_COL_PROP = {
    setName = 0.28,
    type    = 0.28,  -- includes weight suffix for armor, e.g. "Chest (H)"
    trait   = 0.20,
    enchant = 0.24,
}

local QUEUE_COL_MIN = {
    setName = 90,
    type    = 110,   -- room for "Greatsword" or "Shoulders (M)"
    trait   = 70,
    enchant = 70,
}

local function ComputeQueueColumnLayout(rowWidth)
    local usable = rowWidth - QUEUE_LEFT_PAD - QUEUE_RIGHT_PAD - QUEUE_BUTTON_PAD - (QUEUE_COL_GAP * 3)
    if usable < 50 then usable = 50 end

    local wSet     = math.max(QUEUE_COL_MIN.setName, math.floor(usable * QUEUE_COL_PROP.setName))
    local wType    = math.max(QUEUE_COL_MIN.type,    math.floor(usable * QUEUE_COL_PROP.type))
    local wTrait   = math.max(QUEUE_COL_MIN.trait,   math.floor(usable * QUEUE_COL_PROP.trait))
    local wEnchant = math.max(QUEUE_COL_MIN.enchant, usable - wSet - wType - wTrait)

    local x = QUEUE_LEFT_PAD
    local layout = {}
    layout.setName = { x = x, w = wSet };  x = x + wSet  + QUEUE_COL_GAP
    layout.type    = { x = x, w = wType }; x = x + wType + QUEUE_COL_GAP
    layout.trait   = { x = x, w = wTrait };x = x + wTrait + QUEUE_COL_GAP
    layout.enchant = { x = x, w = wEnchant }
    return layout
end

local function PlaceQueueCol(child, parent, x, w, offY)
    if not child then return end
    child:ClearAnchors()
    child:SetAnchor(TOPLEFT, parent, TOPLEFT, x, offY or 0)
    child:SetWidth(w)
end

-- Width used by SetDividerX cheap-reflow path.
TSC.QUEUE_SCROLLBAR = QUEUE_SCROLLBAR

function TSC.UpdateQueueColumnHeaders()
    local qList = TransmuteSetCrafterWindowQueueList
    if not qList then return end
    local listW = qList:GetWidth()
    if not listW or listW < 50 then return end
    local rowWidth = listW - QUEUE_SCROLLBAR
    local layout   = ComputeQueueColumnLayout(rowWidth)

    PlaceQueueCol(TransmuteSetCrafterWindowQueueColSet,     qList, layout.setName.x, layout.setName.w, -QUEUE_HEADER_GAP)
    PlaceQueueCol(TransmuteSetCrafterWindowQueueColType,    qList, layout.type.x,    layout.type.w,    -QUEUE_HEADER_GAP)
    PlaceQueueCol(TransmuteSetCrafterWindowQueueColTrait,   qList, layout.trait.x,   layout.trait.w,   -QUEUE_HEADER_GAP)
    PlaceQueueCol(TransmuteSetCrafterWindowQueueColEnchant, qList, layout.enchant.x, layout.enchant.w, -QUEUE_HEADER_GAP)
end

-- ── Queue list refresh ─────────────────────────────────────

function TSC.RefreshQueueList()
    local qList    = TransmuteSetCrafterWindowQueueList
    ZO_ScrollList_Clear(qList)
    local dataList = ZO_ScrollList_GetDataList(qList)

    for i, entry in ipairs(TSC.queue) do
        table.insert(dataList, ZO_ScrollList_CreateDataEntry(QUEUE_ENTRY, {
            queueIndex     = i,
            pieceId        = entry.pieceId,
            setName        = entry.setName,
            pieceType      = entry.pieceType   or "",
            armorType      = entry.armorType,
            traitType      = entry.traitType,
            traitName      = entry.traitName,
            quality        = entry.quality,
            qualityName    = entry.qualityName,
            enchantment    = entry.enchantment or "",
            enchantQuality = entry.enchantQuality or ITEM_FUNCTIONAL_QUALITY_LEGENDARY,
            status         = entry.status or "pending",
        }))
    end

    ZO_ScrollList_Commit(qList)
    TSC.UpdateTransmuteButton()
end

-- ── Row tooltip (queued-state preview) ─────────────────────

-- Replace fields 4 (enchantmentItemId), 5 (subtype), 6 (level) in an item
-- link, leaving every other field intact. Returns the patched link or the
-- original if parsing fails.
local function PatchEnchantmentFields(link, glyphItemId, subtype, lvl)
    local prefix, fields, suffix = link:match("^(|H%d:item:)([^|]+)(|h.*)$")
    if not fields then return link end
    local parts = {}
    for p in (fields .. ":"):gmatch("([^:]*):") do
        parts[#parts + 1] = p
    end
    if #parts < 6 then return link end
    parts[4] = tostring(glyphItemId)
    parts[5] = tostring(subtype)
    parts[6] = tostring(lvl)
    return prefix .. table.concat(parts, ":") .. suffix
end

function TSC.OnQueueRowMouseEnter(ctrl)
    if not ctrl.data then return end
    ctrl:GetNamedChild("Highlight"):SetAlpha(0.2)
    if not ctrl.data.pieceId then return end

    local entry = TSC.queue[ctrl.data.queueIndex]
    if not entry then return end

    -- Build a preview link with the queued trait + quality so the tooltip
    -- reflects exactly what reconstruction would produce. Weight is intrinsic
    -- to the pieceId and shown automatically.
    local traitType = entry.traitType or ITEM_TRAIT_TYPE_NONE
    local link      = GetItemSetCollectionPieceItemLink(
                          ctrl.data.pieceId, LINK_STYLE_DEFAULT,
                          traitType, entry.quality)
    if not link or link == "" then return end

    -- Bake the planned glyph into the link's enchantment fields so the tooltip
    -- shows the user's intended enchant rather than the item's bundled default.
    if entry.enchantment and entry.enchantment ~= "" and TSC.GetItemLinkEnchantedFields then
        local glyphItemId, subtype, lvl =
            TSC.GetItemLinkEnchantedFields(entry.enchantment, entry.enchantQuality)
        if glyphItemId then
            link = PatchEnchantmentFields(link, glyphItemId, subtype, lvl)
        end
    end

    InitializeTooltip(ItemTooltip, ctrl, LEFT, -5, 0)
    ItemTooltip:SetLink(link)
end

function TSC.OnQueueRowMouseExit(ctrl)
    if ctrl.data then
        ctrl:GetNamedChild("Highlight"):SetAlpha(0)
        ClearTooltip(ItemTooltip)
    end
end

-- ── Row setup ──────────────────────────────────────────────

function TSC.SetupQueueRow(ctrl, data)
    ctrl.data = data
    local quality = data.quality or ITEM_FUNCTIONAL_QUALITY_ARTIFACT
    local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, quality)
    if not r then r, g, b = 1, 1, 1 end

    -- Match row width to current list width and reflow columns proportionally
    local qList = TransmuteSetCrafterWindowQueueList
    local listW = (qList and qList:GetWidth()) or 500
    local rowWidth = listW - QUEUE_SCROLLBAR
    if rowWidth < 200 then rowWidth = 488 end
    ctrl:SetWidth(rowWidth)

    local layout     = ComputeQueueColumnLayout(rowWidth)
    local setNameLbl = ctrl:GetNamedChild("SetName")
    local typeLbl    = ctrl:GetNamedChild("Type")
    local traitLbl   = ctrl:GetNamedChild("Trait")
    local enchantLbl = ctrl:GetNamedChild("Enchant")

    PlaceQueueCol(setNameLbl, ctrl, layout.setName.x, layout.setName.w)
    PlaceQueueCol(typeLbl,    ctrl, layout.type.x,    layout.type.w)
    PlaceQueueCol(traitLbl,   ctrl, layout.trait.x,   layout.trait.w)
    PlaceQueueCol(enchantLbl, ctrl, layout.enchant.x, layout.enchant.w)

    setNameLbl:SetText(data.setName or "")
    setNameLbl:SetColor(r, g, b, 1)
    typeLbl:SetText(data.pieceType or "")
    typeLbl:SetColor((TSC.GetArmorColor(data.armorType) or TSC.Color.TEAL):UnpackRGBA())
    traitLbl:SetText(data.traitName or "")

    local enchantText = data.enchantment or ""
    if data.status == "needs_enchant" and enchantText ~= "" then
        enchantText = enchantText .. GetString(SI_TSC_MISSING_SUFFIX)
    end
    enchantLbl:SetText(enchantText)
    if data.enchantment and data.enchantment ~= "" then
        local eq = data.enchantQuality or ITEM_FUNCTIONAL_QUALITY_LEGENDARY
        local er, eg, eb = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, eq)
        if er then
            enchantLbl:SetColor(er, eg, eb, 1)
        else
            enchantLbl:SetColor(TSC.Color.TEAL:UnpackRGBA())
        end
    else
        enchantLbl:SetColor(TSC.Color.TEAL:UnpackRGBA())
    end

    ctrl:GetNamedChild("Highlight"):SetAlpha(0)
    ctrl:GetNamedChild("Edit"):SetText(GetString(SI_TSC_LABEL_EDIT))

    -- Show a red warning if the player can't actually reconstruct this entry:
    -- piece not unlocked, or chosen trait not researched for this piece.
    local warningLbl = ctrl:GetNamedChild("Warning")
    if warningLbl then
        local reason = nil
        local pieceData = data.pieceId and TSC.GetPieceData(data.pieceId)
        if not pieceData then
            reason = GetString(SI_TSC_WARN_PIECE_GONE)
        elseif not pieceData:IsUnlocked() then
            reason = GetString(SI_TSC_WARN_NOT_COLLECTED)
        else
            local traitType = data.traitType
            if traitType and traitType ~= ITEM_TRAIT_TYPE_NONE
               and not IsTraitKnownForItem(data.pieceId, traitType) then
                reason = GetString(SI_TSC_WARN_TRAIT_NOT_RESEARCHED)
            end
        end
        if reason then
            warningLbl:SetText("!")
            warningLbl:SetHidden(false)
            ctrl.warningReason = reason
        else
            warningLbl:SetHidden(true)
            ctrl.warningReason = nil
        end
    end
end

function TSC.OnQueueRowWarningEnter(ctrl)
    local row = ctrl:GetParent()
    if not row or not row.warningReason then return end
    InitializeTooltip(InformationTooltip, ctrl, BOTTOMRIGHT, 0, -4, BOTTOMLEFT)
    InformationTooltip:AddLine(row.warningReason, "ZoFontGameMedium", 1.0, 0.45, 0.45)
end

function TSC.OnQueueRowWarningExit(ctrl)
    ClearTooltip(InformationTooltip)
end

-- ── Add button state ───────────────────────────────────────

function TSC.UpdateAddButton()
    local label
    if UI.editingQueueIndex then
        label = GetString(SI_TSC_LABEL_UPDATE_ENTRY)
    else
        local count = TSC.SelectedPieceCount()
        if count > 1 then
            label = zo_strformat(SI_TSC_ADD_COUNT_TO_QUEUE, count)
        else
            label = GetString(SI_TSC_ADD_TO_QUEUE)
        end
    end
    TransmuteSetCrafterWindowAddToQueueButton:SetText(label)
    TransmuteSetCrafterWindowCancelEditButton:SetHidden(UI.editingQueueIndex == nil)
end

-- ── "Add Selected to Queue" / "Update Entry" ──────────────

function TSC.AddSelectedToQueue()
    -- Edit mode: update the existing entry instead of adding a new one
    if UI.editingQueueIndex then
        if not UI.selectedTrait then
            TSC.Notify(TSC.NOTIFY_WARN, GetString(SI_TSC_MSG_NO_TRAIT))
            return
        end
        if not UI.selectedQuality then
            TSC.Notify(TSC.NOTIFY_WARN, GetString(SI_TSC_MSG_NO_QUALITY))
            return
        end
        TSC.UpdateQueueEntry(UI.editingQueueIndex, UI.selectedTrait, UI.selectedQuality,
                             UI.selectedEnchant, UI.selectedEnchantQuality)
        TSC.ClearPieceSelection()
        TSC.UpdateAddButton()
        TSC.UpdateTransmuteButton()
        return
    end

    -- Normal mode: add selected pieces to queue
    if not next(UI.selectedPieces) then
        TSC.Notify(TSC.NOTIFY_WARN, GetString(SI_TSC_MSG_NO_PIECES))
        return
    end
    if not UI.selectedTrait then
        TSC.Notify(TSC.NOTIFY_WARN, GetString(SI_TSC_MSG_NO_TRAIT))
        return
    end
    if not UI.selectedQuality then
        TSC.Notify(TSC.NOTIFY_WARN, GetString(SI_TSC_MSG_NO_QUALITY))
        return
    end
    for pieceId in pairs(UI.selectedPieces) do
        TSC.AddToQueue(pieceId, UI.selectedTrait, UI.selectedQuality,
                       UI.selectedEnchant, UI.selectedEnchantQuality)
    end
    TSC.ClearSelectedPiecesKeepDropdowns()
    TSC.RefreshInventoryList()
    TSC.UpdateAddButton()
    TSC.UpdateTransmuteButton()
end

-- ── Cancel Edit ────────────────────────────────────────────

function TSC.CancelEdit()
    if not UI.editingQueueIndex then return end
    TSC.ClearPieceSelection()  -- resets editingQueueIndex and all dropdowns
    TSC.UpdateAddButton()      -- restores "Add to Queue" label, hides Cancel button
    TSC.RefreshInventoryList() -- restore normal row appearance
end

-- ── Edit Queue Row ─────────────────────────────────────────

function TSC.EditQueueRow(ctrl)
    if not ctrl or not ctrl.data or not ctrl.data.queueIndex then return end
    local queueIndex = ctrl.data.queueIndex
    local entry      = TSC.queue[queueIndex]
    if not entry then return end

    local pieceData = TSC.GetPieceData(entry.pieceId)
    if not pieceData then
        TSC.Notify(TSC.NOTIFY_WARN, GetString(SI_TSC_MSG_PIECE_GONE_EDIT))
        return
    end

    -- Reset any current piece selection before entering edit mode
    TSC.ClearPieceSelection()
    UI.editingQueueIndex = queueIndex

    -- Repopulate dropdowns with the row's current values preselected
    local itemData = {
        pieceId       = entry.pieceId,
        traitCategory = pieceData:GetTraitCategory(),
    }
    TSC.PopulateTraitDropdown(itemData, entry.traitType)
    TSC.PopulateEnchantDropdown(itemData, entry.enchantment)
    TSC.PopulateQualityDropdown(entry.quality)
    TSC.PopulateEnchantQualityDropdown(entry.enchantQuality)

    TSC.UpdateAddButton()
    TSC.RefreshInventoryList()  -- inventory rows reflect lack of selection
end

-- ── Queue from equipped gear ──────────────────────────────
-- Walk every slot in BAG_WORN (iterating by bag size rather than relying on
-- EQUIP_SLOT_* constants) and queue each set-piece item with its current
-- trait/quality + any detectable glyph.
--
-- Resolution: use GetItemLinkSetInfo(link) for the setId and
-- GetItemLinkItemSetCollectionSlot(link) for the slot id64, then
-- setData:GetPieceDataBySlot(slot) to recover the pieceData. This is more
-- reliable than itemId reverse-mapping because collection links and
-- equipped instances of the same item don't always share an itemId
-- (notably for weapons, jewelry, and waist).

-- Resolve an equipped item's link to its set-collection pieceData.
-- Two non-obvious fallbacks are required:
--   • Perfected trial sets carry the perfected setId on the equipped item,
--     but the collection book stores the unperfected set. Fall back via
--     GetItemSetUnperfectedSetId(setId).
--   • GetItemLinkItemSetCollectionSlot() returns 0 on some items
--     (notably perfected weapons + jewelry + waist), so the direct slot
--     lookup misses. Fall back to matching by equip/armor/weapon type
--     within the set's pieces.
local function ResolveEquippedPieceData(link)
    local hasSet, _, _, _, _, setId = GetItemLinkSetInfo(link)
    if not hasSet or not setId or setId == 0 then return nil end

    local mgr = ITEM_SET_COLLECTIONS_DATA_MANAGER
    local setData = mgr:GetItemSetCollectionData(setId)
    if not setData then
        local unperfId = GetItemSetUnperfectedSetId(setId)
        if unperfId and unperfId ~= 0 then
            setData = mgr:GetItemSetCollectionData(unperfId)
        end
    end
    if not setData then return nil end

    local collectionSlot = GetItemLinkItemSetCollectionSlot(link)
    if collectionSlot and collectionSlot ~= 0 then
        local piece = setData:GetPieceDataBySlot(collectionSlot)
        if piece then return piece end
    end

    -- Fallback: match by equip type + armor type + weapon type.
    local equipType  = GetItemLinkEquipType(link)
    local armorType  = GetItemLinkArmorType(link)
    local weaponType = GetItemLinkWeaponType(link)
    for _, pieceData in setData:PieceIterator() do
        local pdLink = pieceData:GetItemLink()
        if GetItemLinkEquipType(pdLink)  == equipType
           and GetItemLinkArmorType(pdLink)  == armorType
           and GetItemLinkWeaponType(pdLink) == weaponType then
            return pieceData
        end
    end
    return nil
end

function TSC.QueueEquipped()
    local added, skipped = 0, 0
    local bagSize = GetBagSize(BAG_WORN)
    for slot = 0, bagSize - 1 do
        local link = GetItemLink(BAG_WORN, slot)
        if link and link ~= "" then
            local pieceData = ResolveEquippedPieceData(link)
            if pieceData then
                local trait   = GetItemLinkTraitInfo(link)
                local quality = GetItemLinkFunctionalQuality(link)
                local enchant, enchantQuality
                if TSC.GetEnchantInfoFromItemLink then
                    enchant, enchantQuality = TSC.GetEnchantInfoFromItemLink(link)
                end
                TSC.AddToQueue(pieceData:GetId(),
                               trait,
                               quality,
                               enchant or "",
                               enchantQuality or ITEM_FUNCTIONAL_QUALITY_LEGENDARY)
                added = added + 1
            else
                local hasSet = GetItemLinkSetInfo(link)
                if hasSet then skipped = skipped + 1 end
            end
        end
    end
    TSC.NotifyF(TSC.NOTIFY_INFO, SI_TSC_MSG_EQUIPPED_QUEUED, added, skipped)
end

-- ── Lifecycle ─────────────────────────────────────────────

-- Called from UI.lua SetupUI: register the queue row template + seed headers.
function TSC.SetupQueueList()
    local qList = TransmuteSetCrafterWindowQueueList
    ZO_ScrollList_AddDataType(qList, QUEUE_ENTRY, "TSC_QueueRow",
                              QUEUE_ROW_HEIGHT,
                              function(ctrl, data) TSC.SetupQueueRow(ctrl, data) end)

    TransmuteSetCrafterWindowQueueColSet:SetText(GetString(SI_TSC_COL_SET))
    TransmuteSetCrafterWindowQueueColType:SetText(GetString(SI_TSC_COL_TYPE))
    TransmuteSetCrafterWindowQueueColTrait:SetText(GetString(SI_TSC_COL_TRAIT))
    TransmuteSetCrafterWindowQueueColEnchant:SetText(GetString(SI_TSC_COL_ENCHANT))
end
