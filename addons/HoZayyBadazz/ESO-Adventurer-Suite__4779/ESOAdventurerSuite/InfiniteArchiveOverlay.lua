-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.
--
-- Suite-managed Infinite Archive HUD tracker.
--
-- ESO owns the live Infinite Archive tracker and can hide/re-anchor it as HUD
-- scenes change.  The Suite keeps the live tracker for gameplay (so the real
-- keybind and progression behavior stay intact), but uses a Suite-owned layout
-- preview while HUD Layout Mode is active.  That preview is independent of the
-- HUD scene, so it remains visible and draggable above LibAddonMenu settings.

local EPC = ESOProgressionCoach
EPC.InfiniteArchiveOverlay = EPC.InfiniteArchiveOverlay or {}
local A = EPC.InfiniteArchiveOverlay
local wm = WINDOW_MANAGER

local REASON_DISABLED = "EAS_InfiniteArchiveOverlayDisabled"
local REASON_LAYOUT = "EAS_InfiniteArchiveOverlayLayoutPreview"

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c, d, e = pcall(fn, ...)
    if not ok then return fallback end
    return a, b, c, d, e
end

local function raiseControl(control)
    if not control then return end
    pcall(function()
        if control.SetTopLevel then control:SetTopLevel(true) end
        if control.SetDrawTier and DT_HIGH then control:SetDrawTier(DT_HIGH) end
        if control.SetDrawLayer and DL_OVERLAY then control:SetDrawLayer(DL_OVERLAY) end
        if control.SetDrawLevel then control:SetDrawLevel(1000) end
    end)
end

function A:GetNativeTracker()
    local tracker = rawget(_G, "ENDLESS_DUNGEON_HUD_TRACKER")
    local control = rawget(_G, "ZO_EndDunHUDTracker")
    if tracker and tracker.control then control = tracker.control end
    return tracker, control
end

function A:GetNativeFragment()
    local tracker = self:GetNativeTracker()
    local fragment = rawget(_G, "ENDLESS_DUNGEON_HUD_TRACKER_FRAGMENT")
    if not fragment and tracker and type(tracker.GetFragment) == "function" then
        fragment = safe(tracker.GetFragment, nil, tracker)
    end
    return fragment
end

function A:SetNativeHiddenForReason(reason, hidden)
    local fragment = self:GetNativeFragment()
    if fragment and type(fragment.SetHiddenForReason) == "function" then
        fragment:SetHiddenForReason(reason, hidden == true)
    end
end

function A:IsArchiveStarted()
    local manager = rawget(_G, "ENDLESS_DUNGEON_MANAGER")
    if manager and type(manager.IsEndlessDungeonStarted) == "function" then
        return safe(manager.IsEndlessDungeonStarted, false, manager) == true
    end
    if type(IsEndlessDungeonStarted) == "function" then
        return safe(IsEndlessDungeonStarted, false) == true
    end
    return false
end

function A:GetPosition()
    local left = tonumber(EPC.saved and EPC.saved.infiniteArchiveOverlayLeft) or -1
    local top = tonumber(EPC.saved and EPC.saved.infiniteArchiveOverlayTop) or -1
    return left, top
end

function A:GetScale()
    local scale = tonumber(EPC.saved and EPC.saved.infiniteArchiveOverlayScale) or 1.0
    return math.max(0.65, math.min(1.80, scale))
end

function A:ApplyPosition()
    local _, control = self:GetNativeTracker()
    if not control then return end

    control:SetScale(self:GetScale())
    if control.SetClampedToScreen then control:SetClampedToScreen(true) end

    local left, top = self:GetPosition()
    if left >= 0 and top >= 0 then
        control:ClearAnchors()
        control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end
end

function A:GetPreviewTitle()
    if SI_ENDLESS_DUNGEON_HUD_TRACKER_TITLE and type(GetString) == "function" then
        local text = safe(GetString, "", SI_ENDLESS_DUNGEON_HUD_TRACKER_TITLE)
        if text and text ~= "" then return text end
    end
    return "Infinite Archive"
end

function A:GetPreviewProgress()
    local manager = rawget(_G, "ENDLESS_DUNGEON_MANAGER")
    if manager and self:IsArchiveStarted() and type(manager.GetCurrentProgressionText) == "function" then
        local text = safe(manager.GetCurrentProgressionText, "", manager, true)
        if text and text ~= "" then return text end
    end

    local managerClass = rawget(_G, "ZO_EndlessDungeonManager")
    if managerClass and type(managerClass.GetProgressionText) == "function" then
        local text = safe(managerClass.GetProgressionText, "", 1, 1, 1, true)
        if text and text ~= "" then return text end
    end
    return "Arc 1   Cycle 1   Stage 1"
end

function A:GetKeybindText()
    if type(GetActionBindingInfo) == "function" then
        local keyCode = safe(GetActionBindingInfo, nil, "TOGGLE_ACTIVITY_HUD_TRACKER", 1)
        if keyCode and keyCode ~= KEY_INVALID and type(GetKeyName) == "function" then
            local keyName = safe(GetKeyName, "", keyCode)
            if keyName and keyName ~= "" then return keyName end
        end
    end
    return "F5"
end

function A:CreateLayoutPreview()
    if self.previewFrame then return self.previewFrame end

    local frame = wm:CreateTopLevelWindow("EAS_InfiniteArchiveOverlayPreview")
    frame:SetDimensions(250, 76)
    frame:SetClampedToScreen(true)
    frame:SetMouseEnabled(false)
    frame:SetMovable(false)
    frame:SetHidden(true)

    local keyBg = wm:CreateControl("EAS_InfiniteArchiveOverlayPreview_KeyBG", frame, CT_BACKDROP)
    keyBg:SetAnchor(TOPLEFT, frame, TOPLEFT, 0, 4)
    keyBg:SetDimensions(46, 32)
    keyBg:SetCenterColor(0.02, 0.025, 0.03, 0.92)
    keyBg:SetEdgeColor(0.94, 0.96, 0.96, 1)
    keyBg:SetEdgeTexture(nil, 2, 2, 2)

    local key = wm:CreateControl("EAS_InfiniteArchiveOverlayPreview_Key", keyBg, CT_LABEL)
    key:SetAnchorFill(keyBg)
    key:SetFont("ZoFontGameBold")
    key:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    key:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    key:SetColor(1, 1, 1, 1)

    local title = wm:CreateControl("EAS_InfiniteArchiveOverlayPreview_Title", frame, CT_LABEL)
    title:SetAnchor(TOPLEFT, keyBg, TOPRIGHT, 10, 0)
    title:SetDimensions(190, 28)
    title:SetFont("ZoFontGameShadow")
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    title:SetColor(0.94, 0.88, 0.70, 1)

    local progress = wm:CreateControl("EAS_InfiniteArchiveOverlayPreview_Progress", frame, CT_LABEL)
    progress:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 8, -1)
    progress:SetDimensions(185, 28)
    progress:SetFont("ZoFontGameShadow")
    progress:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    progress:SetColor(1, 1, 1, 1)

    local hint = wm:CreateControl("EAS_InfiniteArchiveOverlayPreview_Hint", frame, CT_LABEL)
    hint:SetAnchor(TOPLEFT, frame, BOTTOMLEFT, 0, -4)
    hint:SetDimensions(250, 20)
    hint:SetFont("ZoFontGameSmall")
    hint:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    hint:SetColor(0.95, 0.82, 0.42, 1)
    hint:SetText("DRAG TO MOVE - INFINITE ARCHIVE")

    frame:SetHandler("OnMoveStart", function()
        A.previewDragging = true
    end)

    frame:SetHandler("OnMoveStop", function(control)
        if not A.layoutMode then
            A.previewDragging = false
            return
        end
        if EPC.saved then
            EPC.saved.infiniteArchiveOverlayLeft = control:GetLeft()
            EPC.saved.infiniteArchiveOverlayTop = control:GetTop()
        end
        A.previewDragging = false
        A:ApplyPosition()
        -- Do not clear/reapply the preview anchor here. The control is already
        -- exactly where the player dropped it, and re-anchoring can make the
        -- drag feel like it snapped or resisted the mouse.
    end)

    self.previewFrame = frame
    self.previewKey = key
    self.previewTitle = title
    self.previewProgress = progress
    self.previewHint = hint

    self:ApplyPreviewPosition()
    return frame
end

function A:ApplyPreviewPosition()
    if not self.previewFrame then return end

    local frame = self.previewFrame
    frame:SetScale(self:GetScale())
    frame:ClearAnchors()

    local left, top = self:GetPosition()
    if left >= 0 and top >= 0 then
        frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    else
        -- Mirror ESO's default keyboard placement closely enough that moving the
        -- preview feels natural before the player has saved a custom position.
        frame:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -18, 90)
    end
end

function A:RefreshPreviewText()
    if not self.previewFrame then return end
    self.previewKey:SetText(self:GetKeybindText())
    self.previewTitle:SetText(self:GetPreviewTitle())
    self.previewProgress:SetText(self:GetPreviewProgress())
end

function A:RaiseForLayout()
    self:CreateLayoutPreview()
    raiseControl(self.previewFrame)
end

function A:InstallAnchorHook()
    local tracker = self:GetNativeTracker()
    if not tracker or self.anchorHookInstalled then return end
    if type(ZO_PostHook) == "function" and type(tracker.RefreshAnchors) == "function" then
        ZO_PostHook(tracker, "RefreshAnchors", function()
            if EPC.InfiniteArchiveOverlay and not EPC.InfiniteArchiveOverlay.layoutMode then
                EPC.InfiniteArchiveOverlay:ApplyPosition()
            end
        end)
        self.anchorHookInstalled = true
    end
end

function A:RestoreNativeProgress()
    local tracker = self:GetNativeTracker()
    if tracker and type(tracker.UpdateProgress) == "function" then
        pcall(tracker.UpdateProgress, tracker)
    end
end

function A:Refresh()
    local tracker, control = self:GetNativeTracker()

    self:CreateLayoutPreview()
    -- ESO and the Suite both refresh this module frequently. While HUD layout
    -- mode is active, never clear/reapply the preview anchor: doing so during
    -- a drag makes the overlay fight the cursor. We only keep its scale/text
    -- current until the player locks it again.
    if self.layoutMode then
        self.previewFrame:SetScale(self:GetScale())
    else
        self:ApplyPreviewPosition()
    end
    self:RefreshPreviewText()

    local enabled = EPC.saved and EPC.saved.showInfiniteArchiveOverlay ~= false

    if tracker and control then
        self:InstallAnchorHook()
        self:ApplyPosition()

        -- Never make the native ZOS tracker movable directly.  ZOS owns its
        -- scene state and can hide/re-parent it while Settings are open.  The
        -- Suite preview is the stable drag target instead.
        control:SetMouseEnabled(false)
        control:SetMovable(false)

        self:SetNativeHiddenForReason(REASON_DISABLED, not enabled)
        self:SetNativeHiddenForReason(REASON_LAYOUT, self.layoutMode == true)

        if not self.layoutMode then
            self:RestoreNativeProgress()
            if tracker.Update then pcall(tracker.Update, tracker) end
            self:ApplyPosition()
        end
    end

    if self.layoutMode then
        self.previewFrame:SetMouseEnabled(true)
        self.previewFrame:SetMovable(true)
        self.previewFrame:SetHidden(false)
        self:RaiseForLayout()
    else
        self.previewFrame:SetMouseEnabled(false)
        self.previewFrame:SetMovable(false)
        self.previewFrame:SetHidden(true)
    end

    return true
end

function A:SetLayoutMode(active)
    active = active == true
    local entering = active and not self.layoutMode
    self.layoutMode = active
    self.previewDragging = false

    -- Apply the saved position once when move mode begins. After this point the
    -- preview is left completely alone so dragging stays smooth.
    if entering then
        self:CreateLayoutPreview()
        self:ApplyPreviewPosition()
    end
    self:Refresh()
end

function A:ResetPosition()
    if EPC.saved then
        EPC.saved.infiniteArchiveOverlayLeft = -1
        EPC.saved.infiniteArchiveOverlayTop = -1
    end

    local tracker = self:GetNativeTracker()
    if tracker and type(tracker.RefreshAnchors) == "function" then
        pcall(tracker.RefreshAnchors, tracker)
    end
    self:ApplyPreviewPosition()
    self:Refresh()
end

function A:Initialize()
    self.layoutMode = false
    self:CreateLayoutPreview()

    local prefix = (EPC.name or "ESOAdventurerSuite") .. "_InfiniteArchiveOverlay"

    if EVENT_PLAYER_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Activated", EVENT_PLAYER_ACTIVATED, function()
            A:Refresh()
        end)
    end

    local manager = rawget(_G, "ENDLESS_DUNGEON_MANAGER")
    if manager and type(manager.RegisterCallback) == "function" then
        manager:RegisterCallback("StateChanged", function() A:Refresh() end)
        manager:RegisterCallback("DungeonInitialized", function() A:Refresh() end)
        manager:RegisterCallback("DungeonStarted", function() A:Refresh() end)
        manager:RegisterCallback("DungeonCompleted", function() A:Refresh() end)
        manager:RegisterCallback("ProgressionChanged", function() A:Refresh() end)
    end

    -- ZO_Ingame can finish deferred initialization after this addon.  Keep the
    -- native position synchronized and keep the Suite preview above settings
    -- while layout mode is active.
    EVENT_MANAGER:RegisterForUpdate(prefix .. "_Guard", 250, function()
        -- Always refresh visibility. This is intentionally safe during HUD
        -- Layout Mode because Refresh() never reapplies the saved anchors while
        -- layoutMode is active; it only updates visibility/text/scale.
        A:Refresh()
    end)

    self:Refresh()
end

-- ============================================================================
-- v0.29.72 - Suite-owned live Infinite Archive overlay.
-- ESO's native Endless Dungeon fragment may be hidden/reparented by its own HUD
-- state. Keep a Suite-owned tracker visible whenever the player is actually in
-- Infinite Archive, while retaining the same frame as the HUD-layout drag target.
-- ============================================================================
local REASON_SUITE_LIVE_02972 = "EAS_InfiniteArchiveSuiteLive02972"

function A:IsPlayerInArchive02972()
    local manager = rawget(_G, "ENDLESS_DUNGEON_MANAGER")
    if manager and type(manager.IsPlayerInEndlessDungeon) == "function" then
        if safe(manager.IsPlayerInEndlessDungeon, false, manager) == true then return true end
    end
    return self:IsArchiveStarted() == true
end

function A:GetKeybindText()
    if type(GetHighestPriorityActionBindingInfoFromName) == "function" then
        local keyCode = safe(GetHighestPriorityActionBindingInfoFromName, nil, "TOGGLE_ACTIVITY_HUD_TRACKER", false)
        if keyCode and keyCode ~= KEY_INVALID and type(GetKeyName) == "function" then
            local keyName = safe(GetKeyName, "", keyCode)
            if keyName and keyName ~= "" then return keyName end
        end
    end
    return "F5"
end

local EAS_InfiniteRefreshBase02972 = A.Refresh
function A:Refresh()
    EAS_InfiniteRefreshBase02972(self)

    self:CreateLayoutPreview()
    self:RefreshPreviewText()
    local enabled = EPC.saved and EPC.saved.showInfiniteArchiveOverlay ~= false
    local inArchive = self:IsPlayerInArchive02972()
    local showLive = enabled and inArchive and self.layoutMode ~= true

    self:SetNativeHiddenForReason(REASON_SUITE_LIVE_02972, showLive)

    if self.previewFrame then
        if self.layoutMode then
            self.previewFrame:SetMouseEnabled(true)
            self.previewFrame:SetMovable(true)
            self.previewFrame:SetHidden(false)
            if self.previewHint then self.previewHint:SetHidden(false) end
            self:RaiseForLayout()
        elseif showLive then
            self.previewFrame:SetMouseEnabled(false)
            self.previewFrame:SetMovable(false)
            if self.previewHint then self.previewHint:SetHidden(true) end
            self.previewFrame:SetHidden(false)
            raiseControl(self.previewFrame)
        else
            self.previewFrame:SetMouseEnabled(false)
            self.previewFrame:SetMovable(false)
            if self.previewHint then self.previewHint:SetHidden(true) end
            self.previewFrame:SetHidden(true)
        end
    end
    return true
end

-- ============================================================================
-- v0.29.74 - isolate Suite Archive HUD from ESO's native objective tracker
-- The native Endless Dungeon tracker participates in ZOS' objective-tracker
-- layout. Re-anchoring it from HUD Layout Mode can therefore disturb the native
-- quest tracker. From this version onward the Suite never moves/re-anchors the
-- native tracker; its own preview/live frame is the only movable Archive HUD.
-- ============================================================================
local REASON_NATIVE_ISOLATION_02974 = "EAS_InfiniteArchiveNativeIsolation02974"

function A:ApplyPosition()
    -- Compatibility no-op for the native tracker. Older callers still invoke
    -- ApplyPosition(), but only the Suite-owned frame is allowed to move now.
    if self.previewFrame and not self.previewDragging then
        self:ApplyPreviewPosition()
    end
end

function A:ResetPosition()
    if EPC.saved then
        EPC.saved.infiniteArchiveOverlayLeft = -1
        EPC.saved.infiniteArchiveOverlayTop = -1
    end
    self:CreateLayoutPreview()
    self:ApplyPreviewPosition()
    self:Refresh()
end

function A:Refresh()
    self:CreateLayoutPreview()

    if self.layoutMode then
        if self.previewFrame then self.previewFrame:SetScale(self:GetScale()) end
    elseif not self.previewDragging then
        self:ApplyPreviewPosition()
    end
    self:RefreshPreviewText()

    local enabled = EPC.saved and EPC.saved.showInfiniteArchiveOverlay ~= false
    local inArchive = self:IsPlayerInArchive02972()
    local showLive = enabled and inArchive and self.layoutMode ~= true

    -- The Suite owns the visible Archive HUD. The ZOS tracker remains hidden
    -- while our live tracker is shown, but we never alter its anchors, scale,
    -- mouse state, parent, or update layout.
    self:SetNativeHiddenForReason(REASON_DISABLED, not enabled)
    self:SetNativeHiddenForReason(REASON_LAYOUT, self.layoutMode == true)
    self:SetNativeHiddenForReason(REASON_SUITE_LIVE_02972, showLive)
    self:SetNativeHiddenForReason(REASON_NATIVE_ISOLATION_02974, enabled and (showLive or self.layoutMode == true))

    if not self.previewFrame then return true end

    if self.layoutMode then
        self.previewFrame:SetMouseEnabled(true)
        self.previewFrame:SetMovable(true)
        self.previewFrame:SetHidden(false)
        if self.previewHint then self.previewHint:SetHidden(false) end
        self:RaiseForLayout()
    elseif showLive then
        self.previewFrame:SetMouseEnabled(false)
        self.previewFrame:SetMovable(false)
        self.previewFrame:SetHidden(false)
        if self.previewHint then self.previewHint:SetHidden(true) end
        raiseControl(self.previewFrame)
    else
        self.previewFrame:SetMouseEnabled(false)
        self.previewFrame:SetMovable(false)
        self.previewFrame:SetHidden(true)
        if self.previewHint then self.previewHint:SetHidden(true) end
    end
    return true
end

-- ============================================================================
-- v0.29.75 - gameplay-only Infinite Archive visibility.
-- The Suite Archive tracker is a HUD element, not a menu element. Hide it as
-- soon as ESO enters Pause, Map, Inventory, Settings, or another UI/menu scene.
-- HUD Layout Mode remains a gameplay preview and is allowed only while no real
-- ESO menu scene is suppressing the HUD.
-- ============================================================================
function A:IsArchiveHudVisible02975()
    if EPC and type(EPC.IsGameplayHudSuppressed) == "function" then
        local ok, suppressed = pcall(EPC.IsGameplayHudSuppressed, EPC)
        if ok then return suppressed ~= true end
    end

    -- Conservative fallback for installations where Core's helper has not yet
    -- initialized: ordinary camera UI mode means a menu/UI is owning the screen.
    -- HUD Layout Mode is the one intentional exception.
    if self.layoutMode ~= true and type(IsGameCameraUIModeActive) == "function" then
        local ok, active = pcall(IsGameCameraUIModeActive)
        if ok and active == true then return false end
    end
    return true
end

function A:Refresh()
    self:CreateLayoutPreview()

    if self.layoutMode then
        if self.previewFrame then self.previewFrame:SetScale(self:GetScale()) end
    elseif not self.previewDragging then
        self:ApplyPreviewPosition()
    end
    self:RefreshPreviewText()

    local enabled = EPC.saved and EPC.saved.showInfiniteArchiveOverlay ~= false
    local inArchive = self:IsPlayerInArchive02972()
    local hudVisible = self:IsArchiveHudVisible02975()
    local showLive = enabled and inArchive and self.layoutMode ~= true and hudVisible
    local showLayout = self.layoutMode == true and hudVisible

    -- Keep the ZOS activity/objective tracker isolated while the Suite owns the
    -- Archive display. Never alter the native tracker's anchors or position.
    self:SetNativeHiddenForReason(REASON_DISABLED, not enabled)
    self:SetNativeHiddenForReason(REASON_LAYOUT, self.layoutMode == true)
    self:SetNativeHiddenForReason(REASON_SUITE_LIVE_02972, showLive)
    self:SetNativeHiddenForReason(REASON_NATIVE_ISOLATION_02974, enabled and (showLive or showLayout))

    if not self.previewFrame then return true end

    if showLayout then
        self.previewFrame:SetMouseEnabled(true)
        self.previewFrame:SetMovable(true)
        self.previewFrame:SetHidden(false)
        if self.previewHint then self.previewHint:SetHidden(false) end
        self:RaiseForLayout()
    elseif showLive then
        self.previewFrame:SetMouseEnabled(false)
        self.previewFrame:SetMovable(false)
        self.previewFrame:SetHidden(false)
        if self.previewHint then self.previewHint:SetHidden(true) end
        raiseControl(self.previewFrame)
    else
        self.previewFrame:SetMouseEnabled(false)
        self.previewFrame:SetMovable(false)
        self.previewFrame:SetHidden(true)
        if self.previewHint then self.previewHint:SetHidden(true) end
    end
    return true
end



-- ============================================================================
-- v0.29.78 - permanently suppress ESO's native Infinite Archive tracker.
-- The Suite now owns the Archive HUD completely.  The ZOS Endless Dungeon HUD
-- fragment must never become visible again during focus loss, menus, scene
-- transitions, or while the Suite-owned Archive frame is intentionally hidden.
-- ============================================================================
local REASON_NATIVE_ALWAYS_02978 = "EAS_InfiniteArchiveNativeAlwaysHidden02978"

function A:SuppressNativeTracker02978()
    -- Prefer the fragment hidden-for-reason API because it survives normal
    -- scene transitions without touching the native tracker's anchors.
    self:SetNativeHiddenForReason(REASON_NATIVE_ALWAYS_02978, true)

    -- Defensive fallback for clients/builds where the fragment has not been
    -- initialized yet or is temporarily unavailable. The 250 ms guard calls
    -- Refresh repeatedly, so this will be reasserted as soon as the control
    -- exists. Do not change its anchors/scale/parent.
    local _, control = self:GetNativeTracker()
    local fragment = self:GetNativeFragment()
    if control and not fragment and type(control.SetHidden) == "function" then
        pcall(control.SetHidden, control, true)
    end
end

local EAS_InfiniteRefreshBase02978 = A.Refresh
function A:Refresh()
    -- Suppress the native tracker before doing any Suite visibility work. This
    -- remains true even if the Suite frame hides because the game loses focus,
    -- a menu opens, or the user disables the Suite Archive overlay.
    self:SuppressNativeTracker02978()
    local result = EAS_InfiniteRefreshBase02978(self)
    -- Reassert after the base refresh as older compatibility reasons may be
    -- toggled there. The dedicated 0.29.78 reason is never released.
    self:SuppressNativeTracker02978()
    return result
end
