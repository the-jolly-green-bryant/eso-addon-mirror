-- StickerbookPlus – Hooks (SecurePostHook registrations for all sources)

local Addon = StickerbookPlus
local Hooks = {}
Addon.Hooks = Hooks

local SOURCE = Addon.SOURCE

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function RegisterTile(source, tileObj)
    if not Addon.trackedTiles[source] then
        Addon.trackedTiles[source] = {}
    end
    Addon.trackedTiles[source][tileObj] = tileObj
end

local function UnregisterTile(source, tileObj)
    if Addon.trackedTiles[source] then
        Addon.trackedTiles[source][tileObj] = nil
    end
end

-- ── Sets ──────────────────────────────────────────────────────────────────────

local function InstallSetHooks()
    SecurePostHook(ZO_ItemSetCollectionPieceTile_Keyboard, "LayoutPlatform", function(tileObj)
        tileObj._sbpIsNew = tileObj.itemSetCollectionPieceData ~= nil and tileObj.itemSetCollectionPieceData:IsNew() or false
        RegisterTile(SOURCE.SETS, tileObj)
        Addon.Overlay.ApplyOverlayToControl(tileObj, SOURCE.SETS)
    end)

    SecurePostHook(ZO_ItemSetCollectionPieceTile_Keyboard, "Reset", function(tileObj)
        UnregisterTile(SOURCE.SETS, tileObj)
        Addon.Overlay.ClearControl(tileObj.control)
    end)
end

-- ── Crown Store tag (shared by Collections and Outfits) ───────────────────────

local CROWN_TAG_SIZE  = 22
local CROWN_TAG_TEX   = "EsoUI/Art/Collections/collections_cornerTag_fromStore.dds"
local CROWN_TAG_LEVEL = 5

local function GetOrCreateCrownTag(control)
    if not control then return nil end
    if control._sbpCrownTag then return control._sbpCrownTag end
    local tag = WINDOW_MANAGER:CreateControl(nil, control, CT_TEXTURE)
    tag:SetDrawLevel(CROWN_TAG_LEVEL)
    tag:SetDimensions(CROWN_TAG_SIZE, CROWN_TAG_SIZE)
    tag:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
    tag:SetTexture(CROWN_TAG_TEX)
    tag:SetHidden(true)
    control._sbpCrownTag = tag
    return tag
end

-- state is the object carrying the ._sbpCrownTagShown flag (tileObj for Collections,
-- control for Outfits, since Outfits reuses pooled controls without a stable tileObj).
local function RefreshCrownTag(control, collectibleData, state)
    local db = Addon.db
    local tag = GetOrCreateCrownTag(control)
    if not tag then return end
    if db and db.enabled and db.showCrownTag and collectibleData and collectibleData:IsPurchasable() then
        local c = db.crownTagColor
        tag:SetColor(c.r, c.g, c.b, c.a or 1)
        tag:SetHidden(false)
        state._sbpCrownTagShown = true
    else
        if state._sbpCrownTagShown then
            tag:SetHidden(true)
            tag:SetColor(1.0, 1.0, 1.0, 1.0)
            state._sbpCrownTagShown = false
        end
    end
end

-- ── Collections (ZO_CollectibleTile_Keyboard) ─────────────────────────────────

local function InstallCollectibleHooks()
    SecurePostHook(ZO_CollectibleTile_Keyboard, "LayoutPlatform", function(tileObj)
        if not SCENE_MANAGER:IsShowing("collectionsBook") then return end
        local cd = tileObj.collectibleData
        tileObj._sbpIsNew = cd ~= nil and cd:IsNew() or false
        RegisterTile(SOURCE.COLLECTIONS, tileObj)
        Addon.Overlay.ApplyOverlayToControl(tileObj, SOURCE.COLLECTIONS)
        RefreshCrownTag(tileObj.control, cd, tileObj)
    end)

    -- Hide ESO's native hover corner-tag; our permanent tag already covers it (see AGENTS.md).
    SecurePostHook(ZO_CollectibleTile_Keyboard, "RefreshMouseoverVisuals", function(tileObj)
        if not SCENE_MANAGER:IsShowing("collectionsBook") then return end
        if tileObj._sbpCrownTagShown and tileObj.cornerTagTexture then
            tileObj.cornerTagTexture:SetHidden(true)
        end
    end)

    SecurePostHook(ZO_CollectibleTile_Keyboard, "Reset", function(tileObj)
        local control = tileObj.control
        if control and control._sbpCrownTag then
            control._sbpCrownTag:SetHidden(true)
        end
        tileObj._sbpCrownTagShown = false
        UnregisterTile(SOURCE.COLLECTIONS, tileObj)
        Addon.Overlay.ClearControl(control)
    end)
end

-- ── Outfit styles (own panel, not ZO_CollectibleTile_Keyboard) ────────────────

local function InstallOutfitHooks()
    SecurePostHook(ZO_OutfitStylesPanel_Keyboard, "RefreshGridEntryMultiIcon", function(_, control, data)
        -- Empty cells and headers: clear overlay, don't track
        if data.isEmptyCell or data.clearAction or type(data.GetId) ~= "function" then
            if control._sbpTileObj then
                UnregisterTile(SOURCE.OUTFITS, control._sbpTileObj)
            end
            Addon.Overlay.ClearControl(control)
            if control._sbpCrownTag then
                control._sbpCrownTag:SetHidden(true)
                control._sbpCrownTagShown = false
            end
            return
        end
        local tileObj = control._sbpTileObj
        if not tileObj then
            tileObj = { control = control, collectibleData = data }
            control._sbpTileObj = tileObj
        else
            tileObj.collectibleData = data
        end
        tileObj._sbpIsNew = data:IsNew()
        RegisterTile(SOURCE.OUTFITS, tileObj)
        Addon.Overlay.ApplyOverlayToControl(tileObj, SOURCE.OUTFITS)
        RefreshCrownTag(control, data, control)
    end)
end

function Hooks.RefreshAllOutfitCrownTags()
    local tracked = Addon.trackedTiles and Addon.trackedTiles[SOURCE.OUTFITS]
    if not tracked then return end
    for _, tileObj in pairs(tracked) do
        if tileObj.control then
            RefreshCrownTag(tileObj.control, tileObj.collectibleData, tileObj.control)
        end
    end
end

function Hooks.RefreshAllCrownTags()
    local tracked = Addon.trackedTiles and Addon.trackedTiles[SOURCE.COLLECTIONS]
    if not tracked then return end
    for _, tileObj in pairs(tracked) do
        RefreshCrownTag(tileObj.control, tileObj.collectibleData, tileObj)
    end
    Hooks.RefreshAllOutfitCrownTags()
end

-- ── Lore library (ZO_SortFilterList book entries) ─────────────────────────────

local function InstallLoreHooks()
    SecurePostHook(ZO_SortFilterList, "SetupRow", function(self, entryControl)
        -- Only lore library book entries: owner must be LORE_LIBRARY.list
        if not LORE_LIBRARY or self ~= LORE_LIBRARY.list then return end
        -- Only real book entries; mail entries and headers have no bookIndex
        if not entryControl.bookIndex then return end
        local tileObj = entryControl._sbpLoreTile
        if not tileObj then
            tileObj = { control = entryControl }
            entryControl._sbpLoreTile = tileObj
        end
        tileObj._sbpIsUnlocked = entryControl.known
        RegisterTile(SOURCE.LORE, tileObj)
        Addon.Overlay.ApplyOverlayToControl(tileObj, SOURCE.LORE)
    end)
end

-- ── Achievements (ZO_Achievement instances) ───────────────────────────────────
-- PopupAchievement (ACHIEVEMENTS.popup, used for the chat-link achievement
-- popup) subclasses Achievement and calls Achievement.Show/Reset on itself,
-- so it runs through this same SecurePostHook. That popup is a fixed-size
-- floating window, not a tree/panel tile, so our overlay must never be
-- applied to it (see AGENTS.md).
local function IsAchievementPopup(self)
    return ACHIEVEMENTS ~= nil and self == ACHIEVEMENTS.popup
end

local function InstallAchievementHooks()
    SecurePostHook(Achievement, "Show", function(self, achievementId)
        if IsAchievementPopup(self) then return end
        local control = self:GetControl()
        if not control then return end
        local tileObj = control._sbpAchievementTile
        if not tileObj then
            tileObj = { control = control }
            control._sbpAchievementTile = tileObj
        end
        local _, _, _, _, completed = GetAchievementInfo(achievementId)
        tileObj._sbpIsUnlocked = completed
        RegisterTile(SOURCE.ACHIEVEMENTS, tileObj)
        Addon.Overlay.ApplyOverlayToControl(tileObj, SOURCE.ACHIEVEMENTS)
    end)

    SecurePostHook(Achievement, "Reset", function(self)
        if IsAchievementPopup(self) then return end
        local control = self:GetControl()
        local tileObj = control and control._sbpAchievementTile
        if not tileObj then return end
        UnregisterTile(SOURCE.ACHIEVEMENTS, tileObj)
        Addon.Overlay.ClearControl(control)
    end)
end

-- ── Antiquities (ZO_AntiquityTile_Keyboard / ZO_AntiquitySetTile_Keyboard) ────
-- Scryable tiles intentionally not hooked; fragment detection rationale
-- documented in AGENTS.md. The tile's own overlay used to need a manual
-- fixed-size anchor workaround (FixAntiquityOverlaySize) to avoid an anchor
-- cycle with the tile's resizeToFitDescendents layout; superseded by
-- SetExcludeFromResizeToFitExtents on the overlay controls themselves
-- (Overlay.lua), which lets plain SetAnchorFill be used safely everywhere.

-- Set tile: HasDiscovered() has OR semantics across fragments (see AGENTS.md); missing
-- means at least one fragment is not yet discovered. Kept separate from
-- Overlay.ShouldMarkMissing and TreeProgress/Antiquities.lua's sort status: this
-- is the tooltip/tile-icon overlay path, called with the raw set data at hook
-- time rather than a tileObj or the 3-way sort status.
local function IsAntiquitySetMissing(setData)
    for _, antiquityData in setData:AntiquityIterator() do
        if not antiquityData:HasDiscovered() then
            return true
        end
    end
    return false
end

-- Fragment icons: only ZO_AntiquityFragmentIcon instances have control.status; used to
-- distinguish them from the main icon. See AGENTS.md for full rationale.
local function InstallAntiquityFragmentIconHook()
    SecurePostHook("ZO_AntiquityIcon_SetData", function(control, tileData)
        if not control.status then return end
        local wrapper = control._sbpFragmentWrapper
        if not wrapper then
            wrapper = { control = control }
            control._sbpFragmentWrapper = wrapper
        end
        wrapper._sbpIsMissing = not tileData:IsComplete()
        wrapper._sbpIsNew = tileData:GetAntiquitySetData() ~= nil and tileData:HasNewLead()
        RegisterTile(SOURCE.ANTIQUITY_FRAGMENTS, wrapper)
        Addon.Overlay.ApplyOverlayToControl(wrapper, SOURCE.ANTIQUITY_FRAGMENTS)
    end)
end

local function InstallAntiquityHooks()
    local function RefreshAntiquityTile(tileObj)
        local tileData = tileObj.tileData
        local control = tileObj.control
        if not tileData or not control then return end
        if tileData:GetType() == ZO_ANTIQUITY_TYPE_SET then
            tileObj._sbpIsMissing = IsAntiquitySetMissing(tileData)
        else
            tileObj._sbpIsMissing = not tileData:HasDiscovered()
        end
        tileObj._sbpIsNew = tileData:HasNewLead()
        RegisterTile(SOURCE.ANTIQUITIES, tileObj)
        Addon.Overlay.ApplyOverlayToControl(tileObj, SOURCE.ANTIQUITIES)
    end

    SecurePostHook(ZO_AntiquityTile_Keyboard, "Refresh", RefreshAntiquityTile)
    SecurePostHook(ZO_AntiquitySetTile_Keyboard, "Refresh", RefreshAntiquityTile)

    SecurePostHook(ZO_AntiquityTileBase_Keyboard, "Reset", function(self)
        local control = self.control
        UnregisterTile(SOURCE.ANTIQUITIES, self)
        if control then
            Addon.Overlay.ClearControl(control)
        end
    end)

    InstallAntiquityFragmentIconHook()
end

-- ── Public init function ──────────────────────────────────────────────────────

function Hooks.Initialize()
    Addon.trackedTiles = {}

    InstallSetHooks()
    InstallCollectibleHooks()
    InstallOutfitHooks()
    InstallLoreHooks()
    InstallAchievementHooks()
    InstallAntiquityHooks()
    Addon.Overlay.InstallTooltipHook()
    Addon.Overlay.InstallMouseoverClearHook()
end
