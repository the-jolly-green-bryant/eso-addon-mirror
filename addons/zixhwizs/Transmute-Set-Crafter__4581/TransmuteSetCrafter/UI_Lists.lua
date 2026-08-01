-- Transmute Set Crafter — Set + Piece inventory list
--
-- The inventory list (left panel) has two browsing modes:
--   • "sets"   — one row per set the player has collected at least one piece
--     of; shows cost-per-piece on the left and an armor/weapon/jewelry
--     composition tag (e.g. "(HML)" or "(JW)") on the right.
--   • "pieces" — drill-down after clicking a set; one row per piece in the
--     set, colored by armor weight, with "(not collected)" + greying for
--     pieces the player hasn't yet collected.
--
-- Clicking pieces in "pieces" mode multi-selects them and pushes the chosen
-- trait/enchant category through to the dropdowns in UI_Dropdowns.lua.

local TSC = TransmuteSetCrafter
local UI  = TSC._UI

local SET_ENTRY      = 1   -- ScrollList data type ids (must match UI.lua refs)
local PIECE_ENTRY    = 2
local INV_ROW_HEIGHT = 30

-- File-local: search box text and the saved scroll position when the player
-- drills into pieces (restored when they hit "Back to sets").
local searchText         = ""
local lastSetScrollValue = 0

-- Sort dropdown handle (populated by SetupSortDropdown). Sort mode itself
-- is persisted in TSC.savedVars.sortMode (default "name").
local sortComboBox
local SORT_MODES   = { "name", "cost", "weight" }
local SORT_LABELS  = {
    name   = SI_TSC_SORT_BY_NAME,
    cost   = SI_TSC_SORT_BY_COST,
    weight = SI_TSC_SORT_BY_WEIGHT,
}

local function PlainWeightKey(entry)
    local s = ""
    if entry.hasHeavy  then s = s .. "H" end
    if entry.hasMedium then s = s .. "M" end
    if entry.hasLight  then s = s .. "L" end
    if s == "" then
        if entry.hasJewelry then s = s .. "J" end
        if entry.hasWeapon  then s = s .. "W" end
    end
    return s
end

-- Search-box cost filter: if the user types "<N", ">N", "=N", "==N",
-- "<=N", or ">=N" (whitespace tolerant) the set list filters by
-- per-piece transmute cost instead of by name.
local function ParseCostFilter(text)
    local op, numStr = text:match("^%s*([<>=]+)%s*(%-?%d+)%s*$")
    if not op or not numStr then return nil end
    if op == "<" or op == ">" or op == "=" or op == "==" or op == "<=" or op == ">=" then
        return op, tonumber(numStr)
    end
    return nil
end

local function MatchesCost(cost, op, value)
    cost = cost or 0
    if op == "<"  then return cost <  value end
    if op == ">"  then return cost >  value end
    if op == "<=" then return cost <= value end
    if op == ">=" then return cost >= value end
    if op == "=" or op == "==" then return cost == value end
    return false
end

-- Search-box weight filter: if the user types "(HML)", "(JW)", "(H)" etc.
-- (case-insensitive), the set list filters to entries whose weight
-- indicators contain ALL of the specified letters.
local function ParseWeightFilter(text)
    local letters = text:match("^%s*%(([HMLJWhmljw]+)%)%s*$")
    if not letters then return nil end
    return letters:upper()
end

local function MatchesWeight(entry, requiredLetters)
    for letter in requiredLetters:gmatch(".") do
        if     letter == "H" and not entry.hasHeavy   then return false
        elseif letter == "M" and not entry.hasMedium  then return false
        elseif letter == "L" and not entry.hasLight   then return false
        elseif letter == "J" and not entry.hasJewelry then return false
        elseif letter == "W" and not entry.hasWeapon  then return false
        end
    end
    return true
end

-- ── Set list builder ───────────────────────────────────────

local function ComputeWeightLabel(entry)
    local s = ""
    if entry.hasHeavy  then s = s .. TSC.Color.ARMOR_HEAVY:Colorize("H")  end
    if entry.hasMedium then s = s .. TSC.Color.ARMOR_MEDIUM:Colorize("M") end
    if entry.hasLight  then s = s .. TSC.Color.ARMOR_LIGHT:Colorize("L")  end
    if s == "" then
        if entry.hasJewelry then s = s .. "J" end
        if entry.hasWeapon  then s = s .. "W" end
    end
    if s == "" then return "" end
    return "(" .. s .. ")"
end

local function BuildSetList()
    local setMap       = {}
    local lowerSrc     = string.lower(searchText)
    local currencyType = TSC.GetReconCurrencyType()

    -- Walk every piece. Build (or reuse) the set entry, track composition
    -- regardless of unlock, but only bump the unlocked-piece count for unlocked
    -- pieces. Sets with zero unlocked pieces are dropped in the filter below.
    for _, pieceData in ITEM_SET_COLLECTIONS_DATA_MANAGER:ItemSetCollectionPieceIterator() do
        local setData = pieceData:GetItemSetCollectionData()
        local setId   = setData:GetId()
        local entry   = setMap[setId]
        if not entry then
            entry = {
                setData    = setData,
                count      = 0,
                pieceCost  = setData:GetReconstructionCurrencyOptionCost(currencyType),
                hasHeavy   = false,
                hasMedium  = false,
                hasLight   = false,
                hasWeapon  = false,
                hasJewelry = false,
            }
            setMap[setId] = entry
        end
        if pieceData:IsUnlocked() then
            entry.count = entry.count + 1
        end
        local cat = pieceData:GetTraitCategory()
        if cat == ITEM_TRAIT_TYPE_CATEGORY_ARMOR then
            local armorType = GetItemLinkArmorType(pieceData:GetItemLink())
            if     armorType == ARMORTYPE_HEAVY  then entry.hasHeavy  = true
            elseif armorType == ARMORTYPE_MEDIUM then entry.hasMedium = true
            elseif armorType == ARMORTYPE_LIGHT  then entry.hasLight  = true
            end
        elseif cat == ITEM_TRAIT_TYPE_CATEGORY_WEAPON then
            entry.hasWeapon = true
        elseif cat == ITEM_TRAIT_TYPE_CATEGORY_JEWELRY then
            entry.hasJewelry = true
        end
    end

    local sets = {}
    local costOp, costVal = ParseCostFilter(searchText)
    local weightFilter    = ParseWeightFilter(searchText)
    for _, entry in pairs(setMap) do
        local passesSearch
        if costOp then
            passesSearch = MatchesCost(entry.pieceCost, costOp, costVal)
        elseif weightFilter then
            passesSearch = MatchesWeight(entry, weightFilter)
        else
            passesSearch = searchText == "" or
                string.find(string.lower(entry.setData:GetRawName()), lowerSrc, 1, true)
        end
        if passesSearch and entry.count > 0 then
            table.insert(sets, entry)
        end
    end

    local mode = TSC.savedVars.sortMode or "name"
    table.sort(sets, function(a, b)
        local ak, bk
        if mode == "cost" then
            ak, bk = a.pieceCost or 0, b.pieceCost or 0
        elseif mode == "weight" then
            ak, bk = PlainWeightKey(a), PlainWeightKey(b)
        else
            ak, bk = a.setData:GetRawName(), b.setData:GetRawName()
        end
        if ak == bk then
            return a.setData:GetRawName() < b.setData:GetRawName()
        end
        return ak < bk
    end)
    return sets
end

-- ── Piece list builder ────────────────────────────────────

local function BuildPieceList()
    local targetSetId = UI.selectedSet:GetId()
    local pieces = {}
    for _, pieceData in ITEM_SET_COLLECTIONS_DATA_MANAGER:ItemSetCollectionPieceIterator() do
        if pieceData:GetItemSetCollectionData():GetId() == targetSetId then
            table.insert(pieces, pieceData)
        end
    end
    table.sort(pieces, function(a, b)
        return (a:GetRawName() or "") < (b:GetRawName() or "")
    end)
    return pieces
end

-- ── Piece-selection helpers (TSC public — shared with UI.lua add/edit) ──

function TSC.ClearPieceSelection()
    UI.selectedPieces         = {}
    UI.lastSelectedPiece      = nil
    UI.selectedTrait          = nil
    UI.selectedQuality        = nil
    UI.selectedEnchant        = ""
    UI.selectedEnchantQuality = ITEM_FUNCTIONAL_QUALITY_LEGENDARY
    UI.editingQueueIndex      = nil
    UI.lastUsedCategory       = nil
    if TSC.ClearAllDropdowns then TSC.ClearAllDropdowns() end
end

-- "Soft" clear after Add to Queue: drop the piece selection (and any edit-mode
-- lock), but KEEP the trait / quality / enchant / enchant-quality choices and
-- their populated dropdowns so the user can queue another same-category piece
-- without re-picking everything.
function TSC.ClearSelectedPiecesKeepDropdowns()
    if UI.lastSelectedPiece then
        UI.lastUsedCategory = UI.lastSelectedPiece.traitCategory
    end
    UI.selectedPieces    = {}
    UI.lastSelectedPiece = nil
    UI.editingQueueIndex = nil
end

function TSC.SelectedPieceCount()
    local n = 0
    for _ in pairs(UI.selectedPieces) do n = n + 1 end
    return n
end

-- ── Navigation header (Sets ↔ Pieces) ────────────────────

function TSC.UpdateNavigationState()
    local inPieceMode = UI.browsingMode == "pieces"

    TransmuteSetCrafterWindowSearchBG:SetHidden(inPieceMode)
    TransmuteSetCrafterWindowSearchBox:SetHidden(inPieceMode)
    local sortDD = TransmuteSetCrafterWindowSortDropdown
    if sortDD then sortDD:SetHidden(inPieceMode) end

    if inPieceMode and UI.selectedSet then
        TransmuteSetCrafterWindowInventoryHeader:SetText(
            GetString(SI_TSC_BACK_PREFIX) .. UI.selectedSet:GetFormattedName())
        TransmuteSetCrafterWindowInventoryHeader:SetColor(TSC.Color.TEAL:UnpackRGBA())
    else
        TransmuteSetCrafterWindowInventoryHeader:SetText(GetString(SI_TSC_INVENTORY_HEADER))
        TransmuteSetCrafterWindowInventoryHeader:SetColor(1, 1, 1, 1)
    end
end

-- ── Inventory list refresh ─────────────────────────────────

function TSC.RefreshInventoryList()
    local invList  = TransmuteSetCrafterWindowInventoryList
    ZO_ScrollList_Clear(invList)
    local dataList = ZO_ScrollList_GetDataList(invList)

    if UI.browsingMode == "sets" then
        for _, entry in ipairs(BuildSetList()) do
            table.insert(dataList, ZO_ScrollList_CreateDataEntry(SET_ENTRY, {
                setData     = entry.setData,
                setName     = entry.setData:GetFormattedName(),
                numPieces   = entry.count,
                pieceCost   = entry.pieceCost,
                weightLabel = ComputeWeightLabel(entry),
            }))
        end
    else
        for _, pieceData in ipairs(BuildPieceList()) do
            table.insert(dataList, ZO_ScrollList_CreateDataEntry(PIECE_ENTRY, {
                pieceId        = pieceData:GetId(),
                pieceName      = pieceData:GetFormattedName(),
                pieceIcon      = pieceData:GetIcon(),
                displayQuality = pieceData:GetDisplayQuality(),
                traitCategory  = pieceData:GetTraitCategory(),
                isUnlocked     = pieceData:IsUnlocked(),
                armorType      = GetItemLinkArmorType(pieceData:GetItemLink()),
            }))
        end
    end

    ZO_ScrollList_Commit(invList)
    TSC.UpdateNavigationState()
end

-- ── Set row ────────────────────────────────────────────────

function TSC.SetupSetRow(ctrl, data)
    ctrl.data = data
    local label = data.setName
    if data.pieceCost and data.pieceCost > 0 then
        label = string.format("(%d) %s", data.pieceCost, data.setName)
    end
    ctrl:GetNamedChild("Name"):SetText(label)
    ctrl:GetNamedChild("Weight"):SetText(data.weightLabel or "")
    ctrl:GetNamedChild("Chevron"):SetText("›")
    ctrl:GetNamedChild("Highlight"):SetAlpha(0)
end

function TSC.OnSetRowMouseEnter(ctrl)
    if ctrl.data then ctrl:GetNamedChild("Highlight"):SetAlpha(0.15) end
end

function TSC.OnSetRowMouseExit(ctrl)
    if ctrl.data then ctrl:GetNamedChild("Highlight"):SetAlpha(0) end
end

function TSC.OnSetRowClick(ctrl, button, upInside)
    if not upInside or not ctrl.data then return end
    if button ~= MOUSE_BUTTON_INDEX_LEFT then return end

    local list = TransmuteSetCrafterWindowInventoryList
    if list and list.scrollbar then
        lastSetScrollValue = list.scrollbar:GetValue()
    end

    UI.browsingMode = "pieces"
    UI.selectedSet  = ctrl.data.setData
    TSC.ClearPieceSelection()
    TSC.RefreshInventoryList()
    TSC.UpdateAddButton()
    TSC.UpdateTransmuteButton()
end

-- ── Piece row ──────────────────────────────────────────────

-- A row is "disabled" when (a) the player hasn't collected this piece, or
-- (b) something is already selected and this piece's trait category doesn't
-- match it — mixing categories would invalidate the trait dropdown.
local function PieceIsDisabled(data)
    if not data.isUnlocked then return true end
    if not UI.lastSelectedPiece then return false end
    if UI.selectedPieces[data.pieceId] then return false end
    return data.traitCategory ~= UI.lastSelectedPiece.traitCategory
end

function TSC.SetupInventoryRow(ctrl, data)
    ctrl.data = data

    local iconCtrl = ctrl:GetNamedChild("Icon")
    local nameLbl  = ctrl:GetNamedChild("Name")
    iconCtrl:SetTexture(data.pieceIcon)

    local label = data.pieceName
    local letter = TSC.ArmorLetter[data.armorType]
    if letter then label = label .. " (" .. letter .. ")" end
    if not data.isUnlocked then
        label = label .. GetString(SI_TSC_PIECE_NOT_COLLECTED)
    end
    nameLbl:SetText(label)

    if PieceIsDisabled(data) then
        nameLbl:SetColor(TSC.Color.DISABLED:UnpackRGBA())
        iconCtrl:SetColor(1, 1, 1, 0.35)
    else
        local color = TSC.GetArmorColor(data.armorType) or TSC.Color.TEAL
        nameLbl:SetColor(color:UnpackRGBA())
        iconCtrl:SetColor(1, 1, 1, 1)
    end

    ctrl:GetNamedChild("Highlight"):SetAlpha(0)
    ctrl:GetNamedChild("SelectionBG"):SetAlpha(UI.selectedPieces[data.pieceId] and 0.55 or 0)
end

function TSC.OnInventoryRowMouseEnter(ctrl)
    if not ctrl.data then return end
    if not PieceIsDisabled(ctrl.data) then
        ctrl:GetNamedChild("Highlight"):SetAlpha(0.2)
    end
end

function TSC.OnInventoryRowMouseExit(ctrl)
    if ctrl.data then
        ctrl:GetNamedChild("Highlight"):SetAlpha(0)
    end
end

function TSC.OnInventoryRowClick(ctrl, button, upInside)
    if not upInside or not ctrl.data then return end
    if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
    if PieceIsDisabled(ctrl.data) then return end

    -- Auto-cancel any ongoing edit when starting a new selection
    if UI.editingQueueIndex then
        TSC.CancelEdit()
    end

    local pieceId = ctrl.data.pieceId

    if UI.selectedPieces[pieceId] then
        -- Deselect this piece
        UI.selectedPieces[pieceId] = nil

        if UI.lastSelectedPiece and UI.lastSelectedPiece.pieceId == pieceId then
            UI.lastSelectedPiece = nil
            for _, data in pairs(UI.selectedPieces) do
                UI.lastSelectedPiece = data
                break
            end
            if UI.lastSelectedPiece then
                -- Re-populate for the new lead piece, preserving the user's choices
                TSC.PopulateTraitDropdown(UI.lastSelectedPiece, UI.selectedTrait)
                TSC.PopulateEnchantDropdown(UI.lastSelectedPiece,
                    (UI.selectedEnchant ~= "" and UI.selectedEnchant) or nil)
            end
            -- If everything is now deselected, leave dropdowns + selections intact
            -- so the next pick can reuse them (within the same category).
        end
    else
        -- Select this piece
        local newCategory      = ctrl.data.traitCategory
        local categoryChanged  = (UI.lastUsedCategory ~= nil and UI.lastUsedCategory ~= newCategory)
        local firstEverSession = (UI.lastUsedCategory == nil)

        UI.selectedPieces[pieceId] = ctrl.data
        UI.lastSelectedPiece       = ctrl.data

        if categoryChanged then
            -- Category changed — previous trait + enchant choices are no longer valid
            UI.selectedTrait   = nil
            UI.selectedEnchant = ""
        end

        -- Repopulate trait + enchant for this piece (preserves selection where possible
        -- and refreshes "(not researched)" labels which can differ between pieces).
        TSC.PopulateTraitDropdown(ctrl.data, UI.selectedTrait)
        TSC.PopulateEnchantDropdown(ctrl.data,
            (UI.selectedEnchant ~= "" and UI.selectedEnchant) or nil)

        -- Quality dropdowns aren't category-dependent — populate once per session
        if firstEverSession then
            TSC.PopulateQualityDropdown(UI.selectedQuality)
            TSC.PopulateEnchantQualityDropdown(UI.selectedEnchantQuality)
        end

        UI.lastUsedCategory = newCategory
    end

    TSC.RefreshInventoryList()
    TSC.UpdateAddButton()
    TSC.UpdateTransmuteButton()
end

-- ── Inventory header (back to sets) ───────────────────────

function TSC.OnInventoryHeaderClick()
    if UI.browsingMode == "pieces" then TSC.BackToSets() end
end

function TSC.OnInventoryHeaderMouseEnter(ctrl)
    if UI.browsingMode == "pieces" then ctrl:SetColor(TSC.Color.HEADER_HOVER:UnpackRGBA()) end
end

function TSC.OnInventoryHeaderMouseExit(ctrl)
    if UI.browsingMode == "pieces" then
        ctrl:SetColor(TSC.Color.TEAL:UnpackRGBA())
    else
        ctrl:SetColor(1, 1, 1, 1)
    end
end

function TSC.BackToSets()
    UI.browsingMode = "sets"
    UI.selectedSet  = nil
    TSC.ClearPieceSelection()
    TSC.RefreshInventoryList()
    TSC.UpdateAddButton()
    TSC.UpdateTransmuteButton()

    -- Restore scroll position on the next frame. ZO_ScrollList_Commit may
    -- defer its scrollbar SetMinMax call (it falls back to an OnUpdate
    -- handler when the contents have transient zero-height during a mode
    -- switch). Setting the slider value immediately would clamp against
    -- the stale piece-mode max, which silently truncates high values to
    -- whatever the piece list's max was — visible as "scroll snaps to top"
    -- when the user was near the bottom of the set list.
    local list = TransmuteSetCrafterWindowInventoryList
    local target = lastSetScrollValue
    if list and list.scrollbar then
        zo_callLater(function()
            if list.scrollbar then list.scrollbar:SetValue(target) end
        end, 0)
    end
end

-- ── Search ─────────────────────────────────────────────────

function TSC.OnSearchTextChanged(editBox)
    searchText = editBox:GetText() or ""
    local clearBtn = TransmuteSetCrafterWindowSearchClear
    if clearBtn then clearBtn:SetHidden(searchText == "") end
    if UI.browsingMode == "sets" then
        TSC.RefreshInventoryList()
    end
end

function TSC.OnSearchClear()
    local searchBox = TransmuteSetCrafterWindowSearchBox
    if searchBox then searchBox:SetText("") end
end

-- ── Lifecycle ─────────────────────────────────────────────

local function SetupSortDropdown()
    sortComboBox = ZO_ComboBox_ObjectFromContainer(TransmuteSetCrafterWindowSortDropdown)
    if not sortComboBox then return end
    sortComboBox:SetSortsItems(false)
    sortComboBox:ClearItems()

    local current = TSC.savedVars.sortMode or "name"
    local selectedEntry
    for _, mode in ipairs(SORT_MODES) do
        local captured = mode
        local entry = sortComboBox:CreateItemEntry(GetString(SORT_LABELS[mode]), function()
            TSC.savedVars.sortMode = captured
            TSC.RefreshInventoryList()
        end)
        sortComboBox:AddItem(entry)
        if mode == current then selectedEntry = entry end
    end
    if selectedEntry then sortComboBox:SelectItem(selectedEntry) end
end

-- Called once from UI.lua SetupUI: register the two ScrollList row templates
-- and populate the sort selector.
function TSC.SetupInventoryList()
    local invList = TransmuteSetCrafterWindowInventoryList
    ZO_ScrollList_AddDataType(invList, SET_ENTRY,   "TSC_SetRow",
                              INV_ROW_HEIGHT,
                              function(ctrl, data) TSC.SetupSetRow(ctrl, data) end)
    ZO_ScrollList_AddDataType(invList, PIECE_ENTRY, "TSC_InventoryRow",
                              INV_ROW_HEIGHT,
                              function(ctrl, data) TSC.SetupInventoryRow(ctrl, data) end)
    ZO_ScrollList_EnableHighlight(invList, "ZO_TallListHighlight")

    SetupSortDropdown()
end
