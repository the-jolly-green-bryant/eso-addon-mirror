-- StickerbookPlus – Overlay (new/missing markers on tiles)

local Addon = StickerbookPlus
local Overlay = {}
Addon.Overlay = Overlay

local SOURCE = Addon.SOURCE

local LEVEL_BACKGROUND = 1
local LEVEL_BORDER      = 2

local g_overlayCounter = 0

-- ── Backdrop controls ─────────────────────────────────────────────────────────

local function CreateBorderLines(parent, id)
    local lines = {}
    local sides = { "Top", "Bottom", "Left", "Right" }
    for _, side in ipairs(sides) do
        local tex = WINDOW_MANAGER:CreateControl("SBPBorder" .. id .. side, parent, CT_TEXTURE)
        tex:SetDrawLevel(LEVEL_BORDER)
        tex:SetHidden(true)
        -- Decorative overlay, must never feed back into a resizeToFitDescendents
        -- parent's own size (see AGENTS.md, Antiquities set-tile height).
        tex:SetExcludeFromResizeToFitExtents(true)
        lines[side] = tex
    end
    return lines
end

local function PositionBorderLines(lines, thickness)
    lines.Top:ClearAnchors()
    lines.Top:SetAnchor(TOPLEFT,  nil, TOPLEFT,  0, 0)
    lines.Top:SetAnchor(TOPRIGHT, nil, TOPRIGHT, 0, 0)
    lines.Top:SetHeight(thickness)

    lines.Bottom:ClearAnchors()
    lines.Bottom:SetAnchor(BOTTOMLEFT,  nil, BOTTOMLEFT,  0, 0)
    lines.Bottom:SetAnchor(BOTTOMRIGHT, nil, BOTTOMRIGHT, 0, 0)
    lines.Bottom:SetHeight(thickness)

    lines.Left:ClearAnchors()
    lines.Left:SetAnchor(TOPLEFT,    nil, TOPLEFT,    0, thickness)
    lines.Left:SetAnchor(BOTTOMLEFT, nil, BOTTOMLEFT, 0, -thickness)
    lines.Left:SetWidth(thickness)

    lines.Right:ClearAnchors()
    lines.Right:SetAnchor(TOPRIGHT,    nil, TOPRIGHT,    0, thickness)
    lines.Right:SetAnchor(BOTTOMRIGHT, nil, BOTTOMRIGHT, 0, -thickness)
    lines.Right:SetWidth(thickness)
end

local function CreateOrGetOverlayControls(control)
    if control._sbpOverlay then
        return control._sbpOverlay
    end

    g_overlayCounter = g_overlayCounter + 1
    local id = g_overlayCounter

    local bg = WINDOW_MANAGER:CreateControl("SBPBg" .. id, control, CT_TEXTURE)
    bg:SetDrawLevel(LEVEL_BACKGROUND)
    bg:SetAnchorFill(control)
    bg:SetHidden(true)
    -- Decorative overlay, must never feed back into a resizeToFitDescendents
    -- parent's own size (see AGENTS.md, Antiquities set-tile height).
    bg:SetExcludeFromResizeToFitExtents(true)

    local lines = CreateBorderLines(control, id)

    control._sbpOverlay = { bg = bg, lines = lines }
    return control._sbpOverlay
end

-- ── Color helpers ─────────────────────────────────────────────────────────────

local function ApplyColor(tex, colorTable)
    tex:SetColor(colorTable.r, colorTable.g, colorTable.b, colorTable.a or 1)
end

-- ── Apply / clear overlay ─────────────────────────────────────────────────────

local function ShowNewOverlay(ov, db)
    local thickness = db.newBorderThickness

    ov.bg:SetHidden(not db.showNewBackground)
    if db.showNewBackground then
        ApplyColor(ov.bg, db.newBackgroundColor)
    end

    local showBorder = db.showNewBorder and thickness > 0
    for _, line in pairs(ov.lines) do
        line:SetHidden(not showBorder)
        if showBorder then
            ApplyColor(line, db.newBorderColor)
        end
    end
    if showBorder then
        PositionBorderLines(ov.lines, thickness)
    end
end

local function ShowMissingOverlay(ov, db)
    ov.bg:SetHidden(false)
    ApplyColor(ov.bg, db.missingBackgroundColor)
    for _, line in pairs(ov.lines) do
        line:SetHidden(true)
    end
end

local function ClearOverlay(ov)
    ov.bg:SetHidden(true)
    for _, line in pairs(ov.lines) do
        line:SetHidden(true)
    end
end

function Overlay.ClearControl(control)
    if control and control._sbpOverlay then
        ClearOverlay(control._sbpOverlay)
    end
end

-- ── Status icon (ESO new-item icon) ───────────────────────────────────────────

-- Antiquities (main tile and fragment icons) name this field "status" instead
-- of "statusMultiIcon" (see AGENTS.md); both are checked so hideNewIcon works
-- for every tracked area.
local function RefreshStatusIcon(tileObj, isMarkedNew, db)
    local statusIcon = tileObj.statusMultiIcon
        or (tileObj.control and tileObj.control.statusMultiIcon)
        or tileObj.status
        or (tileObj.control and tileObj.control.status)
    if not statusIcon then return end
    local hasIcons = statusIcon.iconData and #statusIcon.iconData > 0
    if isMarkedNew and db and db.hideNewIcon then
        statusIcon:SetHidden(true)
    elseif not hasIcons then
        statusIcon:SetHidden(true) -- ESO reuses pooled icons; hide when empty
    else
        statusIcon:SetHidden(false)
    end
end

-- ── Decision logic ────────────────────────────────────────────────────────────

function Overlay.ShouldMarkNew(tileObj, source)
    local db = Addon.db
    if not db or not db.enabled then return false end
    if source == SOURCE.SETS         and not db.enableSets         then return false end
    if source == SOURCE.OUTFITS      and not db.enableOutfits      then return false end
    if source == SOURCE.COLLECTIONS  and not db.enableCollections  then return false end
    if source == SOURCE.LORE         and not db.enableLore         then return false end
    if source == SOURCE.ACHIEVEMENTS and not db.enableAchievements then return false end
    if source == SOURCE.ANTIQUITIES  and not db.enableAntiquities  then return false end
    if source == SOURCE.ANTIQUITY_FRAGMENTS and not db.enableAntiquities then return false end

    if tileObj._sbpIsNew then return true end

    -- Test simulation via /sbp test item [id]
    if source == SOURCE.SETS and tileObj.itemSetCollectionPieceData then
        local pieceId = tileObj.itemSetCollectionPieceData:GetId()
        if Addon.testNewIds and Addon.testNewIds[pieceId] then
            return true
        end
    end

    -- Test simulation via /sbp test collection [id]
    if source == SOURCE.COLLECTIONS and tileObj.collectibleData then
        local cd = tileObj.collectibleData
        if type(cd.GetId) == "function" then
            local collectibleId = cd:GetId()
            if Addon.testNewCollectionIds and Addon.testNewCollectionIds[collectibleId] then
                return true
            end
        end
    end

    -- Test simulation via /sbp test style [id]
    if source == SOURCE.OUTFITS and tileObj.collectibleData then
        local cd = tileObj.collectibleData
        if type(cd.GetId) == "function" then
            local collectibleId = cd:GetId()
            if Addon.testNewOutfitIds and Addon.testNewOutfitIds[collectibleId] then
                return true
            end
        end
    end

    return false
end

-- Shared between the missing overlay (tileObj.collectibleData) and the outfit
-- sort comparator (raw collectibleData from the sorted-collectibles list, no
-- tileObj) — same criterion, different callers pass different data shapes.
function Overlay.IsOutfitCollectibleMissing(collectibleData, db)
    if collectibleData == nil or not collectibleData:IsLocked() then return false end
    if not db.countHiddenCollectibles and not collectibleData:IsShownInCollection() then return false end
    return true
end

function Overlay.ShouldMarkMissing(tileObj, source)
    local db = Addon.db
    if not db or not db.enabled then return false end
    if source == SOURCE.SETS then
        if not db.enableSets or not db.showMissingForSets then return false end
        local pieceData = tileObj.itemSetCollectionPieceData
        return pieceData ~= nil and not pieceData:IsUnlocked()
    elseif source == SOURCE.OUTFITS then
        if not db.enableOutfits or not db.showMissingForOutfits then return false end
        return Overlay.IsOutfitCollectibleMissing(tileObj.collectibleData, db)
    elseif source == SOURCE.COLLECTIONS then
        if not db.enableCollections or not db.showMissingForCollections then return false end
        local collectibleData = tileObj.collectibleData
        if collectibleData == nil then return false end
        if not collectibleData:IsLocked() then return false end
        if not db.countHiddenCollectibles and not collectibleData:IsShownInCollection() then return false end
        -- Combination fragments already completed elsewhere: locked but no longer obtainable, not "missing".
        if collectibleData:IsCategoryType(COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT) then
            if not CanCombinationFragmentBeUnlocked(collectibleData:GetId()) then
                return false
            end
        end
        return true
    elseif source == SOURCE.LORE then
        if not db.enableLore or not db.showMissingForLore then return false end
        return tileObj._sbpIsUnlocked == false
    elseif source == SOURCE.ACHIEVEMENTS then
        if not db.enableAchievements or not db.showMissingForAchievements then return false end
        return tileObj._sbpIsUnlocked == false
    elseif source == SOURCE.ANTIQUITIES then
        if not db.enableAntiquities or not db.showMissingForAntiquities then return false end
        return tileObj._sbpIsMissing == true
    elseif source == SOURCE.ANTIQUITY_FRAGMENTS then
        if not db.enableAntiquities or not db.showMissingForAntiquityFragments then return false end
        return tileObj._sbpIsMissing == true
    end
    return false
end

-- ── Main apply function ───────────────────────────────────────────────────────

function Overlay.ApplyOverlayToControl(tileObj, source)
    local control = tileObj.control
    if not control then return end

    local db = Addon.db
    if not db or not db.enabled then
        if control._sbpOverlay then
            ClearOverlay(control._sbpOverlay)
        end
        RefreshStatusIcon(tileObj, false, db)
        return
    end

    local ov = CreateOrGetOverlayControls(control)

    if Overlay.ShouldMarkNew(tileObj, source) then
        ShowNewOverlay(ov, db)
        RefreshStatusIcon(tileObj, true, db)
    elseif Overlay.ShouldMarkMissing(tileObj, source) then
        ShowMissingOverlay(ov, db)
        RefreshStatusIcon(tileObj, false, db)
    else
        ClearOverlay(ov)
        RefreshStatusIcon(tileObj, false, db)
    end

    if Addon.MarkAll then
        Addon.MarkAll.RefreshVisibility(source)
    end
end

-- ── Refresh all tiles of a source ─────────────────────────────────────────────

function Overlay.RefreshTrackedTiles(source)
    local tracked = Addon.trackedTiles and Addon.trackedTiles[source]
    if not tracked then return end
    for _, tileObj in pairs(tracked) do
        Overlay.ApplyOverlayToControl(tileObj, source)
    end
end

function Overlay.RefreshAll()
    if not Addon.trackedTiles then return end
    for source, _ in pairs(Addon.trackedTiles) do
        Overlay.RefreshTrackedTiles(source)
    end
end

-- ── Tooltip ID display ────────────────────────────────────────────────────────

function Overlay.InstallTooltipHook()
    SecurePostHook(ZO_ItemSetCollectionPieceTile_Keyboard, "RefreshMouseoverVisuals", function(tileObj)
        local db = Addon.db
        if not db or not db.enabled or not db.showSetIds then return end

        local pieceData = tileObj.itemSetCollectionPieceData
        if not pieceData or not tileObj:IsMousedOver() then return end

        ItemTooltip:AddLine(" ", "", 0.6, 0.6, 0.6)
        ItemTooltip:AddLine("SBP SetId: " .. tostring(pieceData:GetSetId()), "", 0.6, 0.6, 0.6)
        ItemTooltip:AddLine("SBP ItemId: " .. tostring(pieceData:GetId()),   "", 0.6, 0.6, 0.6)
    end)

    SecurePostHook(ZO_CollectibleTile_Keyboard, "RefreshMouseoverVisuals", function(tileObj)
        if not SCENE_MANAGER:IsShowing("collectionsBook") then return end
        local db = Addon.db
        if not db or not db.enabled or not db.showCollectionId then return end

        local cd = tileObj.collectibleData
        if not cd or not tileObj:IsMousedOver() then return end

        ItemTooltip:AddLine(" ", "", 0.6, 0.6, 0.6)
        ItemTooltip:AddLine("SBP CollectibleId: " .. tostring(cd:GetId()), "", 0.6, 0.6, 0.6)
    end)

    SecurePostHook(ZO_OutfitStylesPanel_Keyboard, "OnOutfitStyleEntryMouseEnter", function(_, control)
        local db = Addon.db
        if not db or not db.enabled or not db.showOutfitId then return end

        local dataEntry = control.dataEntry
        if not dataEntry or not dataEntry.data then return end
        local collectibleData = dataEntry.data
        if collectibleData.isEmptyCell or collectibleData.clearAction then return end
        if type(collectibleData.GetId) ~= "function" then return end

        ItemTooltip:AddLine(" ", "", 0.6, 0.6, 0.6)
        local styleId = collectibleData:GetReferenceId()
        if styleId and styleId > 0 then
            ItemTooltip:AddLine("SBP StyleId: " .. tostring(styleId), "", 0.6, 0.6, 0.6)
        end
        ItemTooltip:AddLine("SBP CollectibleId: " .. tostring(collectibleData:GetId()), "", 0.6, 0.6, 0.6)
    end)
end

-- ── Mouseover clear for test-new markers ──────────────────────────────────────

function Overlay.InstallMouseoverClearHook()
    -- Sets: reset test item on mouse exit
    SecurePostHook(ZO_ItemSetCollectionPieceTile_Keyboard, "OnFocusChanged", function(tileObj, isFocused)
        if isFocused then return end
        local pieceData = tileObj.itemSetCollectionPieceData
        if not pieceData then return end
        local pieceId = pieceData:GetId()
        if Addon.testNewIds and Addon.testNewIds[pieceId] then
            Addon.testNewIds[pieceId] = nil
            Addon.Overlay.ApplyOverlayToControl(tileObj, SOURCE.SETS)
        end
    end)

    -- Collections: reset test flag and refresh overlay on mouse exit
    SecurePostHook(ZO_CollectibleTile_Keyboard, "OnMouseExit", function(tileObj)
        if not SCENE_MANAGER:IsShowing("collectionsBook") then return end
        local cd = tileObj.collectibleData
        if not cd or type(cd.GetId) ~= "function" then return end
        local collectibleId = cd:GetId()
        if not (Addon.testNewCollectionIds and Addon.testNewCollectionIds[collectibleId]) then return end
        Addon.testNewCollectionIds[collectibleId] = nil
        tileObj._sbpIsNew = false
        Addon.Overlay.ApplyOverlayToControl(tileObj, SOURCE.COLLECTIONS)
    end)

    -- Outfits: ESO clears new-status on mouse exit; reset test flag + overlay too
    SecurePostHook(ZO_OutfitStylesPanel_Keyboard, "OnOutfitStyleEntryMouseExit", function(_, control)
        local dataEntry = control.dataEntry
        if not dataEntry or not dataEntry.data then return end
        local collectibleData = dataEntry.data
        if collectibleData.isEmptyCell or collectibleData.clearAction then return end
        if type(collectibleData.GetId) ~= "function" then return end
        local collectibleId = collectibleData:GetId()

        if not (Addon.testNewOutfitIds and Addon.testNewOutfitIds[collectibleId]) then return end
        Addon.testNewOutfitIds[collectibleId] = nil

        local tracked = Addon.trackedTiles and Addon.trackedTiles[SOURCE.OUTFITS]
        if tracked then
            for _, tileObj in pairs(tracked) do
                if tileObj.collectibleData and tileObj.collectibleData:GetId() == collectibleId then
                    tileObj._sbpIsNew = false
                    Addon.Overlay.ApplyOverlayToControl(tileObj, SOURCE.OUTFITS)
                    break
                end
            end
        end
    end)
end
