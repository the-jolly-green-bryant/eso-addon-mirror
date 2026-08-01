-- StickerbookPlus – MarkAll (mark-all-as-seen buttons)

local Addon = StickerbookPlus
local MarkAll = {}
Addon.MarkAll = MarkAll

local SOURCE = Addon.SOURCE

local BUTTON_LABELS = {
    GetString(SBP_MARKALL_LABEL_REMOVE),
    GetString(SBP_MARKALL_LABEL_CLEAR),
    GetString(SBP_MARKALL_LABEL_DONE),
    GetString(SBP_MARKALL_LABEL_SEEN),
}

local g_buttons = {}  -- g_buttons[source] = button control

-- ── Visibility ─────────────────────────────────────────────────────────────────

local function HasAnyNew(source)
    local tracked = Addon.trackedTiles and Addon.trackedTiles[source]
    if not tracked then return false end
    for _, tileObj in pairs(tracked) do
        if Addon.Overlay.ShouldMarkNew(tileObj, source) then
            return true
        end
    end
    return false
end

local function RefreshButtonVisibility(source)
    local button = g_buttons[source]
    if not button then return end
    local db = Addon.db
    if not db or not db.enabled or not db.showMarkAllButton then
        button:SetHidden(true)
        return
    end
    button:SetHidden(not HasAnyNew(source))
end

-- ── Clear logic per source ─────────────────────────────────────────────────────

local function ClearNewForTile(tileObj, source)
    if source == SOURCE.SETS then
        local pieceData = tileObj.itemSetCollectionPieceData
        if not pieceData then return end
        local pieceId = pieceData:GetId()
        if tileObj._sbpIsNew then
            pieceData:ClearNew()
            tileObj._sbpIsNew = false
        end
        if Addon.testNewIds and Addon.testNewIds[pieceId] then
            Addon.testNewIds[pieceId] = nil
        end
    elseif source == SOURCE.OUTFITS then
        local collectibleData = tileObj.collectibleData
        if not collectibleData then return end
        local collectibleId = collectibleData:GetId()
        ClearCollectibleNewStatus(collectibleId)
        tileObj._sbpIsNew = false
        if Addon.testNewOutfitIds and Addon.testNewOutfitIds[collectibleId] then
            Addon.testNewOutfitIds[collectibleId] = nil
        end
    elseif source == SOURCE.COLLECTIONS then
        local collectibleData = tileObj.collectibleData
        if not collectibleData then return end
        local collectibleId = collectibleData:GetId()
        ClearCollectibleNewStatus(collectibleId)
        tileObj._sbpIsNew = false
        if Addon.testNewCollectionIds and Addon.testNewCollectionIds[collectibleId] then
            Addon.testNewCollectionIds[collectibleId] = nil
        end
    end
end

-- ── Click action ──────────────────────────────────────────────────────────────

local function OnMarkAllClicked(source)
    local tracked = Addon.trackedTiles and Addon.trackedTiles[source]
    if not tracked then return end
    for _, tileObj in pairs(tracked) do
        if Addon.Overlay.ShouldMarkNew(tileObj, source) then
            ClearNewForTile(tileObj, source)
        end
        Addon.Overlay.ApplyOverlayToControl(tileObj, source)
    end
    RefreshButtonVisibility(source)
end

-- ── Button width calculation ──────────────────────────────────────────────────

local function GetButtonWidth(text)
    local fontObject = _G["ZoFontGameBold"]
    if fontObject then
        return GetStringWidthScaled(fontObject, text, 1, SPACE_INTERFACE) + 24
    end
    return 160
end

-- ── Create button ─────────────────────────────────────────────────────────────

local function CreateButton(source, anchorControl, anchorPoint, relativePoint, offsetX, offsetY)
    if not anchorControl then return end

    local button = WINDOW_MANAGER:CreateControlFromVirtual("SBPMarkAllButton_" .. source, anchorControl:GetParent(), "ZO_DefaultButton")
    button:SetAnchor(anchorPoint or BOTTOMLEFT, anchorControl, relativePoint or TOPLEFT, offsetX or 9, offsetY or -4)
    button:SetDrawTier(DT_HIGH)
    button:SetHandler("OnClicked", function() OnMarkAllClicked(source) end)
    button:SetHidden(true)

    g_buttons[source] = button
end

-- ── Refresh button text and width ─────────────────────────────────────────────

function MarkAll.RefreshButtonLabel()
    local db = Addon.db
    local idx = db and db.markAllButtonLabel or Addon.MARK_ALL_LABEL_CLEAR
    local text = BUTTON_LABELS[idx] or BUTTON_LABELS[1]
    local width = GetButtonWidth(text)
    for _, button in pairs(g_buttons) do
        button:SetText(text)
        button:SetWidth(width)
    end
end

-- ── Public interface ──────────────────────────────────────────────────────────

function MarkAll.RefreshVisibility(source)
    if source then
        RefreshButtonVisibility(source)
    else
        for src in pairs(g_buttons) do
            RefreshButtonVisibility(src)
        end
    end
end

function MarkAll.Hide(source)
    if source then
        local button = g_buttons[source]
        if button then button:SetHidden(true) end
    else
        for _, button in pairs(g_buttons) do
            button:SetHidden(true)
        end
    end
end

-- All three buttons are created defensively wherever their anchor control is
-- first seen to exist, rather than only once at MarkAll.Initialize() time or
-- only inside a one-time OnDeferredInitialize PostHook — either approach can
-- silently skip button creation for the rest of the session (Sets/Outfits: the
-- panel isn't guaranteed to exist yet at EVENT_ADD_ON_LOADED time; Collections:
-- another addon can deferred-initialize the scene first, confirmed with
-- PerfectPixel — see the equivalent guard in TreeProgress/Achievements.lua).
-- Each Ensure* function is idempotent via the g_buttons guard.

local function EnsureSetsMarkAllButton()
    if g_buttons[SOURCE.SETS] then return end
    local filtersControl = ZO_ItemSetsBook_Keyboard_TopLevelFilters
    if not filtersControl then return end

    CreateButton(SOURCE.SETS, filtersControl:GetNamedChild("ShowLocked"))
    MarkAll.RefreshButtonLabel()
    MarkAll.RefreshVisibility(SOURCE.SETS)
end

local function EnsureOutfitsMarkAllButton()
    if g_buttons[SOURCE.OUTFITS] then return end
    local outfitPanel = ZO_OUTFIT_STYLES_PANEL_KEYBOARD
    if not outfitPanel or not outfitPanel.typeFilterControl then return end

    -- Right-aligned, 20px left of the type-filter dropdown
    CreateButton(SOURCE.OUTFITS, outfitPanel.typeFilterControl, TOPRIGHT, TOPLEFT, -20, 0)
    MarkAll.RefreshButtonLabel()
    MarkAll.RefreshVisibility(SOURCE.OUTFITS)
end

local function EnsureCollectionsMarkAllButton()
    if g_buttons[SOURCE.COLLECTIONS] then return end
    if not COLLECTIONS_BOOK or not COLLECTIONS_BOOK.categoryFilterComboBox then return end

    CreateButton(SOURCE.COLLECTIONS, COLLECTIONS_BOOK.categoryFilterComboBox, TOPRIGHT, TOPLEFT, -8, 0)
    MarkAll.RefreshButtonLabel()
    MarkAll.RefreshVisibility(SOURCE.COLLECTIONS)
end

function MarkAll.Initialize()
    EnsureSetsMarkAllButton()
    if ITEM_SETS_BOOK_SCENE then
        ITEM_SETS_BOOK_SCENE:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_SHOWN then
                EnsureSetsMarkAllButton()
            end
        end)
    end

    EnsureOutfitsMarkAllButton()
    if ZO_OUTFIT_STYLES_BOOK_SCENE then
        ZO_OUTFIT_STYLES_BOOK_SCENE:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_SHOWN then
                EnsureOutfitsMarkAllButton()
            end
        end)
    end

    SecurePostHook(ZO_CollectionsBook, "OnDeferredInitialize", function(self)
        if self == COLLECTIONS_BOOK then
            EnsureCollectionsMarkAllButton()
        end
    end)

    SecurePostHook(ZO_CollectionsBook, "BuildCategories", function(self)
        if self == COLLECTIONS_BOOK then
            EnsureCollectionsMarkAllButton()
        end
    end)

    if COLLECTIONS_BOOK_SCENE then
        COLLECTIONS_BOOK_SCENE:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_SHOWN then
                EnsureCollectionsMarkAllButton()
            end
        end)
    end

    EnsureCollectionsMarkAllButton()

    MarkAll.RefreshButtonLabel()
    MarkAll.RefreshVisibility()
end
