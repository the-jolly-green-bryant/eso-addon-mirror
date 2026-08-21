local U = Ultivite
if not U then return end

local Frames = U.Frames
local Combat = U.Combat
local FAB = U.FancyActionBar
local EnemyAlerts = U.EnemyUltimateAlerts

U.QuickMenu = U.QuickMenu or {}
local Q = U.QuickMenu

local PANEL_WIDTH = 330
local ROW_HEIGHT = 25
local ROW_GAP = 1
local HEADER_HEIGHT = 54
local SECTION_HEIGHT = 21
local SECTION_GAP = 3
local CHAT_WATCH_MS = 50
local PANEL_RIGHT_OFFSET = -20
local PANEL_Y_OFFSET = 70

local DARK_SOULS_MODES = {
    { id = "off", label = "OFF" },
    { id = "full", label = "FULL" },
    { id = "self", label = "SELF BARS" },
    { id = "topLeft", label = "TOP LEFT" },
    { id = "both", label = "TOP LEFT + SELF" },
    { id = "actionEnemy", label = "ACTION + ENEMY" },
    { id = "actionSelf", label = "ACTION + SELF" },
}

local VISIBILITY_LABELS = {
    show = "ON",
    hide = "OFF",
    combat = "HIDE IN COMBAT",
    pvp = "HIDE IN PVP",
    combatOnly = "COMBAT ONLY",
    pvpOnly = "PVP ONLY",
}

-- Quick-menu cycles mirror the actual visibility modes already supported by
-- Ultivite's main settings. Standard HUD elements use the four useful hide
-- states. Crosshair also exposes the two inverse "only" modes.
local STANDARD_VISIBILITY_CYCLE = { "show", "combat", "pvp", "hide" }
local CROSSHAIR_VISIBILITY_CYCLE = { "show", "combatOnly", "pvpOnly", "combat", "pvp", "hide" }

Q.panel = nil
Q.buttons = Q.buttons or {}
Q.lastChatOpen = nil
Q.chatWatchRegistered = false
Q.initialized = false
Q.interactionHoldUntil = 0
Q.chatSessionActive = false
Q.pointerInside = false
Q.previewEnabled = false
Q.resizeEnabled = false
Q.previewKey = "darkSouls"
Q.previewRuntime = nil
Q.previewHandlersInstalled = false
Q.manualDismissed = false
Q.closePending = false
Q.chatHooksInstalled = false
Q.chatReopenGeneration = Q.chatReopenGeneration or 0
Q.actionInProgress = false
Q.actionGeneration = Q.actionGeneration or 0
Q.actionButtonKey = nil
Q.lastActionFailure = nil
Q.banditsMiniMapShown = Q.banditsMiniMapShown
Q.banditsMiniMapBridgeInstalled = Q.banditsMiniMapBridgeInstalled or false
Q.banditsMiniMapSettingContainer = nil
Q.banditsMiniMapSettingKey = nil
Q.lastAppliedGraphicsProfile = Q.lastAppliedGraphicsProfile
Q.openedFromSettings = Q.openedFromSettings or false
Q.pendingAction = nil

local function BoolText(value)
    return value and "ON" or "OFF"
end

local function GetProfileFrames()
    -- The live module table is authoritative while the addon is running. Using
    -- the profile copy first could make quick-menu verification read stale state
    -- immediately after a setter changed Frames.saved.
    if Frames and Frames.saved then return Frames.saved end
    local profile = U.GetActiveProfile and U.GetActiveProfile() or nil
    return profile and profile.frames or nil
end

local function GetCombatSettings()
    -- Same rule as Frames: read the live combat table first so a click and its
    -- displayed state are always talking about the same SavedVariables object.
    if Combat and Combat.sv then return Combat.sv end
    local profile = U.GetActiveProfile and U.GetActiveProfile() or nil
    return profile and profile.combat or nil
end

function Q.IsPreviewing(key)
    return Q.previewEnabled == true and Q.previewKey == key
end

local function RequestSave()
    if U.RequestSettingsSave then U.RequestSettingsSave(true) end
end

local function RefreshLAM()
    if CALLBACK_MANAGER and U.panel then
        CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", U.panel)
    end
end

function Q.CanShow()
    -- When launched from Ultivite's normal settings panel, keep the quick menu
    -- available inside that UI scene. Normal Enter/chat sessions still require
    -- the gameplay HUD scene.
    if Q.openedFromSettings == true then return true end
    if SCENE_MANAGER and SCENE_MANAGER.IsShowing then
        return SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui")
    end
    return true
end

local function SafeBoolMethod(object, methodName)
    if not object or type(object[methodName]) ~= "function" then return nil end
    local ok, value = pcall(object[methodName], object)
    if not ok then return nil end
    return value == true
end

local function ControlOrParentHidden(control)
    local current = control
    local depth = 0
    while current and depth < 6 do
        if type(current.IsHidden) == "function" then
            local ok, hidden = pcall(current.IsHidden, current)
            if ok and hidden == true then return true end
        end
        if type(current.GetAlpha) == "function" then
            local ok, alpha = pcall(current.GetAlpha, current)
            if ok and tonumber(alpha) and tonumber(alpha) <= 0.001 then return true end
        end
        if type(current.GetParent) ~= "function" then break end
        local ok, parent = pcall(current.GetParent, current)
        if not ok or parent == current then break end
        current = parent
        depth = depth + 1
    end
    return false
end

local function IsChatContainerMinimized()
    if not CHAT_SYSTEM then return true end
    local containers = { CHAT_SYSTEM }
    if CHAT_SYSTEM.primaryContainer then containers[#containers + 1] = CHAT_SYSTEM.primaryContainer end
    if type(CHAT_SYSTEM.GetPrimaryContainer) == "function" then
        local ok, container = pcall(CHAT_SYSTEM.GetPrimaryContainer, CHAT_SYSTEM)
        if ok and container then containers[#containers + 1] = container end
    end
    local chatWindow = rawget(_G, "ZO_ChatWindow")
    if chatWindow then containers[#containers + 1] = chatWindow end

    for _, container in ipairs(containers) do
        local minimized = SafeBoolMethod(container, "IsMinimized")
        if minimized == true then return true end
        if container.isMinimized == true or container.minimized == true then return true end
        if container ~= CHAT_SYSTEM and ControlOrParentHidden(container) then return true end
    end
    return false
end

local function MaximizeChatContainerNow()
    if not CHAT_SYSTEM then return end
    local containers = { CHAT_SYSTEM }
    if CHAT_SYSTEM.primaryContainer then containers[#containers + 1] = CHAT_SYSTEM.primaryContainer end
    if type(CHAT_SYSTEM.GetPrimaryContainer) == "function" then
        local ok, container = pcall(CHAT_SYSTEM.GetPrimaryContainer, CHAT_SYSTEM)
        if ok and container then containers[#containers + 1] = container end
    end
    for _, container in ipairs(containers) do
        if container and type(container.Maximize) == "function" then
            pcall(container.Maximize, container)
        elseif container and type(container.Restore) == "function" then
            pcall(container.Restore, container)
        end
    end
end

function Q.IsChatOpen()
    local entry = CHAT_SYSTEM and CHAT_SYSTEM.textEntry or nil
    if not entry or type(entry.IsOpen) ~= "function" then return false end
    local ok, isOpen = pcall(entry.IsOpen, entry)
    if not ok or isOpen ~= true then return false end

    -- TextEntry:IsOpen() is the authoritative typing-session state. Do not use
    -- edit-control/parent visibility here: ESO can transiently fade, hide or
    -- reparent chat controls while another mouse-enabled UI element is under
    -- the cursor. Treating that visual transition as a close made the Quick
    -- Menu disappear simply by hovering Preview targets. A genuine minimize is
    -- still an intentional chat close for Quick Menu purposes.
    if IsChatContainerMinimized() then return false end
    return true
end

local function GetNowMs()
    if GetFrameTimeMilliseconds then
        return GetFrameTimeMilliseconds()
    end
    return 0
end

function Q.HoldForInteraction(milliseconds)
    local duration = tonumber(milliseconds) or 350
    local untilMs = GetNowMs() + duration
    if untilMs > (Q.interactionHoldUntil or 0) then
        Q.interactionHoldUntil = untilMs
    end
end

function Q.ShouldRemainVisible()
    if not Q.CanShow() then return false end
    if Q.manualDismissed == true then return false end
    if Q.openedFromSettings == true then return true end
    if Q.actionInProgress == true then return true end
    if Q.pointerInside == true then return true end
    if GetNowMs() < (Q.interactionHoldUntil or 0) then return true end
    if Q.chatSessionActive == true then return true end
    return Q.IsChatOpen()
end

local function GetChatDraftText()
    local entry = CHAT_SYSTEM and CHAT_SYSTEM.textEntry or nil
    if not entry then return "" end
    local candidates = { entry.editControl, entry.control, entry }
    for _, control in ipairs(candidates) do
        if control and type(control.GetText) == "function" then
            local ok, value = pcall(control.GetText, control)
            if ok and value ~= nil then return tostring(value) end
        end
    end
    return ""
end

-- ESO's TextEntry can remain logically open after the player clicks another UI
-- control even though its edit box has lost keyboard focus. Calling TextEntry:Open()
-- again does not fix that because the stock implementation only TakeFocus()es when
-- transitioning from closed to open. The Quick Menu therefore restores focus on
-- the real ESO edit box explicitly after one of its buttons has been used.
local function EnsureChatKeyboardFocus()
    local entry = CHAT_SYSTEM and CHAT_SYSTEM.textEntry or nil
    if not entry then return false end

    local isOpen = false
    if type(entry.IsOpen) == "function" then
        local ok, value = pcall(entry.IsOpen, entry)
        isOpen = ok and value == true
    end
    if not isOpen then return false end

    local edit = entry.editControl
    if not edit or type(edit.TakeFocus) ~= "function" then return false end

    if type(edit.HasFocus) == "function" then
        local ok, hasFocus = pcall(edit.HasFocus, edit)
        if ok and hasFocus == true then return true end
    end

    local ok = pcall(edit.TakeFocus, edit)
    return ok == true
end

function Q.ReopenChatAfterInteraction(draftText, actionGeneration)
    local reopenGeneration = Q.chatReopenGeneration or 0
    local actionGen = actionGeneration or Q.actionGeneration or 0

    local function restoreOnce()
        if Q.manualDismissed == true
            or Q.openedFromSettings == true
            or reopenGeneration ~= (Q.chatReopenGeneration or 0)
            or actionGen ~= (Q.actionGeneration or 0) then
            return
        end

        local entry = CHAT_SYSTEM and CHAT_SYSTEM.textEntry or nil
        if entry then
            local isOpen = false
            if type(entry.IsOpen) == "function" then
                local ok, value = pcall(entry.IsOpen, entry)
                isOpen = ok and value == true
            end
            if not isOpen and type(entry.Open) == "function" then
                -- Stock TextEntry:Open() restores keyboard focus when reopening.
                pcall(entry.Open, entry, draftText or "")
            else
                -- When the entry stayed logically open, explicitly restore the
                -- edit-control focus that the Quick Menu click temporarily took.
                EnsureChatKeyboardFocus()
            end
        end

        -- Ultivite visibility rules must never hide chat while text entry is open.
        if Frames and Frames.ApplyChatVisibilityMode then pcall(Frames.ApplyChatVisibilityMode) end
        EnsureChatKeyboardFocus()

        Q.actionInProgress = false
        Q.actionButtonKey = nil
        Q.pendingAction = nil
        Q.RefreshChatVisibility(true)
    end

    -- One next-tick restore is enough after the mouse button has been released.
    -- A second bounded pass handles clients that publish chat focus one frame late,
    -- without leaving long delayed callbacks that can interfere with later typing.
    zo_callLater(function()
        restoreOnce()
        if actionGen == (Q.actionGeneration or 0) and not Q.IsChatOpen() and Q.manualDismissed ~= true then
            zo_callLater(restoreOnce, 45)
        end
    end, 0)
end

local function SafeRequestSave()
    if RequestAddOnSavedVariablesPrioritySave then
        RequestAddOnSavedVariablesPrioritySave("Ultivite")
    end
end

local function SaveCenteredPosition(root, xKey, yKey, minX, maxX, minY, maxY)
    if not root or not Combat or not Combat.sv or not GuiRoot then return end
    local cx, cy = root:GetCenter()
    local gx, gy = GuiRoot:GetCenter()
    if not cx or not cy or not gx or not gy then return end
    local x = zo_round(cx - gx)
    local y = zo_round(cy - gy)
    if minX then x = zo_clamp(x, minX, maxX) end
    if minY then y = zo_clamp(y, minY, maxY) end
    Combat.sv[xKey] = x
    Combat.sv[yKey] = y
    SafeRequestSave()
end

local function InstallMovableResizeHandlers(control, savePosition, resizeStep)
    if not control or control.ultiviteQuickPreviewHandlers then return end
    control.ultiviteQuickPreviewHandlers = true
    control:SetHandler("OnMouseDown", function(self, button)
        if Q.previewEnabled ~= true or button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        if self.StartMoving then self:StartMoving() end
    end)
    control:SetHandler("OnMouseUp", function(self, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        if self.StopMovingOrResizing then self:StopMovingOrResizing() end
        if Q.previewEnabled == true and savePosition then savePosition(self) end
    end)
    control:SetHandler("OnMoveStop", function(self)
        if Q.previewEnabled == true and savePosition then savePosition(self) end
    end)
    control:SetHandler("OnMouseWheel", function(self, delta)
        if Q.previewEnabled ~= true or Q.resizeEnabled ~= true or delta == 0 then return end
        if resizeStep then resizeStep(delta > 0 and 1 or -1) end
    end)
end

function Q.InstallPreviewHandlers()
    Q.previewHandlersInstalled = true

    -- Navigation helpers are real Ultivite controls. In preview they become
    -- direct drag targets and the wheel changes their real saved size.
    if Frames and Frames.CreateFeetCompass then
        local feet = Frames.CreateFeetCompass()
        InstallMovableResizeHandlers(feet, function(root)
            local cx, cy = root:GetCenter(); local gx, gy = GuiRoot:GetCenter()
            if cx and cy and gx and gy then
                Frames.SetFeetCompassX(zo_round(cx - gx))
                Frames.SetFeetCompassY(zo_round(cy - gy))
            end
        end, function(direction)
            local f = GetProfileFrames()
            Frames.SetFeetCompassSize((tonumber(f and f.feetCompassSize) or 320) + (direction * 10))
        end)
    end
    if Frames and Frames.CreateCrownDirectionArrow then
        local crown = Frames.CreateCrownDirectionArrow()
        InstallMovableResizeHandlers(crown, function(root)
            local cx, cy = root:GetCenter(); local gx, gy = GuiRoot:GetCenter()
            if cx and cy and gx and gy then
                Frames.SetCrownDirectionArrowX(zo_round(cx - gx))
                Frames.SetCrownDirectionArrowY(zo_round(cy - gy))
            end
        end, function(direction)
            local f = GetProfileFrames()
            Frames.SetCrownDirectionArrowSize((tonumber(f and f.crownDirectionArrowSize) or 38) + (direction * 2))
        end)
    end

    if Frames and Frames.CreateDSEnemyHealthBar then
        local enemy = Frames.CreateDSEnemyHealthBar()
        local frame = enemy and enemy.frame
        if frame then
            frame:SetMovable(true)
            InstallMovableResizeHandlers(frame, function(root)
                local cx, _ = root:GetCenter(); local gx, _ = GuiRoot:GetCenter()
                local bottom = root:GetBottom(); local rootHeight = GuiRoot:GetHeight()
                if cx and gx then Frames.SetDSEnemyGeometryValue("dsEnemyX", zo_round(cx - gx)) end
                if bottom and rootHeight then Frames.SetDSEnemyGeometryValue("dsEnemyBottomOffset", zo_round(bottom - rootHeight)) end
            end, function(direction)
                local f = GetProfileFrames()
                local width = tonumber(f and f.dsEnemyWidth) or 988
                local height = tonumber(f and f.dsEnemyHeight) or 18
                Frames.SetDSEnemyGeometryValue("dsEnemyWidth", width + (direction * 40))
                Frames.SetDSEnemyGeometryValue("dsEnemyHeight", height + (direction * 2))
            end)
        end
    end
    if Frames and Frames.CreateDSSelfHealthBar then
        local selfBar = Frames.CreateDSSelfHealthBar()
        local frame = selfBar and selfBar.frame
        if frame then
            frame:SetMovable(true)
            InstallMovableResizeHandlers(frame, function(root)
                local cx, _ = root:GetCenter(); local gx, _ = GuiRoot:GetCenter()
                local bottom = root:GetBottom(); local rootHeight = GuiRoot:GetHeight()
                if cx and gx then Frames.SetDarkSoulsBottomX(zo_round(cx - gx)) end
                if bottom and rootHeight then Frames.SetDarkSoulsBottomDistance(math.abs(zo_round(bottom - rootHeight))) end
            end, function(direction)
                local f = GetProfileFrames()
                if Frames.SetDSSelfScale then Frames.SetDSSelfScale((tonumber(f and f.dsSelfScale) or 1.0) + (direction * 0.05)) end
            end)
        end
    end

    if Combat and Combat.CreateLiveStatWidgets then
        Combat.CreateLiveStatWidgets()
        for _, widget in pairs(Combat.liveStatWidgets or {}) do
            if widget and widget.root and not widget.root.ultiviteQuickResizeHandler then
                widget.root.ultiviteQuickResizeHandler = true
                local function resizeLiveStat(_, delta)
                    if Q.previewEnabled ~= true or Q.resizeEnabled ~= true or delta == 0 or not Combat.sv then return end
                    Combat.sv.liveStatFontSize = zo_clamp((tonumber(Combat.sv.liveStatFontSize) or 28) + (delta > 0 and 1 or -1), 16, 42)
                    if Combat.ApplyLiveStatWidgetAppearance then Combat.ApplyLiveStatWidgetAppearance() end
                    SafeRequestSave()
                end
                widget.root:SetHandler("OnMouseWheel", resizeLiveStat)
                -- The transparent drag surface sits above the root and normally
                -- receives mouse input first. Give it the same resize handler so
                -- RESIZE works reliably without changing the always-draggable rule.
                if widget.dragger then widget.dragger:SetHandler("OnMouseWheel", resizeLiveStat) end
            end
        end
    end

    -- K/D is always draggable on its own. Mouse-wheel resizing is deliberately
    -- separate and only becomes active while PREVIEW + RESIZE are enabled.
    if Combat and Combat.pvpHudRoot and not Combat.pvpHudRoot.ultiviteQuickResizeHandler then
        Combat.pvpHudRoot.ultiviteQuickResizeHandler = true
        local function resizePvpKd(_, delta)
            if Q.previewEnabled ~= true or Q.resizeEnabled ~= true or delta == 0 or not Combat.sv then return end
            Combat.sv.pvpHudFontSize = zo_clamp((tonumber(Combat.sv.pvpHudFontSize) or 20) + (delta > 0 and 1 or -1), 14, 36)
            if Combat.ApplyPvpHudAppearance then Combat.ApplyPvpHudAppearance() end
            SafeRequestSave()
        end
        Combat.pvpHudRoot:SetHandler("OnMouseWheel", resizePvpKd)
        if Combat.pvpHudDragger then Combat.pvpHudDragger:SetHandler("OnMouseWheel", resizePvpKd) end
    end

    local auraRoots = {
        { root = Combat and Combat.ccImmunityRoot, x = "ccImmunityX", y = "ccImmunityY", size = "playerAuraIconSize", min = 24, max = 90, apply = "ApplyPlayerAuraHudLayout" },
        { root = Combat and Combat.playerDebuffRoot, x = "playerDebuffX", y = "playerDebuffY", size = "playerAuraIconSize", min = 24, max = 90, apply = "ApplyPlayerAuraHudLayout" },
        { root = Combat and Combat.targetDebuffRoot, x = "targetDebuffX", y = "targetDebuffY", size = "targetDebuffIconSize", min = 24, max = 90, apply = "ApplyTargetDebuffLayout" },
    }
    for _, info in ipairs(auraRoots) do
        if info.root then
            InstallMovableResizeHandlers(info.root, function(root)
                SaveCenteredPosition(root, info.x, info.y, -900, 900, -520, 520)
                if Combat[info.apply] then Combat[info.apply]() end
            end, function(direction)
                if not Combat.sv then return end
                Combat.sv[info.size] = zo_clamp((tonumber(Combat.sv[info.size]) or 48) + (direction * 2), info.min, info.max)
                if Combat[info.apply] then Combat[info.apply]() end
                SafeRequestSave()
            end)
        end
    end

    local warningRoots = {
        { root = Combat and Combat.combatDangerRoot, x = "combatDangerX", y = "combatDangerY", size = "combatDangerFontSize", min = 22, max = 42, apply = "ApplyCombatDangerLayout", labels = function() return Combat.combatDangerLabels end },
        { root = Combat and Combat.foodWarningRoot, x = "foodWarningX", y = "foodWarningY", size = "foodWarningFontSize", min = 16, max = 50, label = function() return Combat.foodWarningLabel end },
        { root = Combat and Combat.majorResolveWarningRoot, x = "majorResolveWarningX", y = "majorResolveWarningY", size = "majorResolveWarningFontSize", min = 16, max = 46, label = function() return Combat.majorResolveWarningLabel end },
    }
    for _, info in ipairs(warningRoots) do
        if info.root then
            InstallMovableResizeHandlers(info.root, function(root)
                SaveCenteredPosition(root, info.x, info.y, -900, 900, -520, 520)
                if info.apply and Combat[info.apply] then Combat[info.apply]() end
            end, function(direction)
                if not Combat.sv then return end
                local size = zo_clamp((tonumber(Combat.sv[info.size]) or 24) + direction, info.min, info.max)
                Combat.sv[info.size] = size
                if info.apply and Combat[info.apply] then Combat[info.apply]() end
                if info.label then
                    local label = info.label()
                    if label then label:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", size)) end
                end
                if info.labels then
                    for _, label in ipairs(info.labels() or {}) do label:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", size)) end
                end
                SafeRequestSave()
            end)
        end
    end

    if Combat and Combat.majorBreachRoot and not Combat.majorBreachRoot.ultiviteQuickResizeOnly then
        Combat.majorBreachRoot.ultiviteQuickResizeOnly = true
        Combat.majorBreachRoot:SetHandler("OnMouseWheel", function(_, delta)
            if Q.previewEnabled ~= true or Q.resizeEnabled ~= true or delta == 0 or not Combat.sv then return end
            local size = zo_clamp((tonumber(Combat.sv.majorBreachFontSize) or 16) + (delta > 0 and 1 or -1), 10, 34)
            Combat.sv.majorBreachFontSize = size
            if Combat.majorBreachLabel then Combat.majorBreachLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", size)) end
            SafeRequestSave()
        end)
    end

    local fab = rawget(_G, "FancyActionBar")
    local mover = rawget(_G, "FAB_Mover")
    if fab and mover and not mover.ultiviteQuickResizeHandler then
        mover.ultiviteQuickResizeHandler = true
        mover:SetHandler("OnMouseWheel", function(_, delta)
            if Q.previewEnabled ~= true or Q.resizeEnabled ~= true or delta == 0 then return end
            local sv = FAB and FAB.GetSettings and FAB.GetSettings() or nil
            if not sv then return end
            local key = fab.style == 2 and "gp" or "kb"
            sv.abScaling = sv.abScaling or {}
            sv.abScaling[key] = sv.abScaling[key] or {}
            local scale = zo_clamp((tonumber(sv.abScaling[key].scale) or 100) + (delta > 0 and 2 or -2), 30, 250)
            sv.abScaling[key].enable = true
            sv.abScaling[key].scale = scale
            if fab.SetScale then pcall(fab.SetScale) end
            if fab.ReanchorMover then pcall(fab.ReanchorMover) end
            if FAB and FAB.RequestSave then FAB.RequestSave() end
        end)
    end
end

function Q.ApplyActualPreviewVisibility()
    if Q.previewEnabled ~= true then return end
    Q.InstallPreviewHandlers()

    -- Preset changes can relock their normal editors. Preview owns the edit
    -- session while it is active, so immediately put the real HUD back into
    -- movable mode without changing the selected visual preset.
    if Frames and Frames.saved and Frames.saved.locked == true and Frames.SetLocked then Frames.SetLocked(false, true) end
    if Combat and Combat.sv and Combat.sv.locked == true and Combat.SetPositionPreview then Combat.SetPositionPreview(true) end
    local liveFab = rawget(_G, "FancyActionBar")
    if liveFab and liveFab.ToggleMover and liveFab.IsUnlocked and not liveFab.IsUnlocked() then pcall(liveFab.ToggleMover, true) end

    -- First release anything that was force-shown for the previous menu row.
    -- The normal Ultivite update routines decide whether those controls should
    -- be visible when they are not the active preview target.
    if Frames and Frames.RefreshNavigationHelpers then Frames.RefreshNavigationHelpers(true) end
    if EnemyAlerts and EnemyAlerts.SetPreviewKind then EnemyAlerts.SetPreviewKind(nil) end
    if Combat then
        if Combat.UpdateLiveStatWidgets then Combat.UpdateLiveStatWidgets(true) end
        if Combat.ScanPlayerAuraHud then Combat.ScanPlayerAuraHud() end
        if Combat.ScanTargetAuras then Combat.ScanTargetAuras() end
        if Combat.UpdateCombatDangerWarnings then Combat.UpdateCombatDangerWarnings(true) end
        if Combat.UpdateFoodWarning then Combat.UpdateFoodWarning() end
        if Combat.UpdateMajorResolveWarning then Combat.UpdateMajorResolveWarning() end
        if Combat.UpdateMajorBreachDisplay then Combat.UpdateMajorBreachDisplay() end
        if Combat.SetPvpHudEditMode then Combat.SetPvpHudEditMode(false) elseif Combat.UpdatePvpHud then Combat.UpdatePvpHud() end
    end

    local key = Q.previewKey or "darkSouls"
    if key == "actionBar" then
        -- Show the actual FAB/ESO action-bar root while it is the selected preview.
        -- The FAB mover remains responsible for drag/resize and DeactivatePreviewRuntime
        -- restores the user's real Action Bar / Combat HUD visibility afterwards.
        local bar = rawget(_G, "ZO_ActionBar1")
        if bar and bar.SetHidden then bar:SetHidden(false) end
    end
    if (key == "darkSouls" or key == "enemyHealth") and Frames then
        if Frames.dsEnemyHealthControl and Frames.dsEnemyHealthControl.frame then
            Frames.dsEnemyHealthControl.frame:SetMovable(true)
            Frames.dsEnemyHealthControl.frame:SetMouseEnabled(true)
        end
        if Frames.dsSelfHealthControl and Frames.dsSelfHealthControl.frame then
            Frames.dsSelfHealthControl.frame:SetMovable(true)
            Frames.dsSelfHealthControl.frame:SetMouseEnabled(true)
        end
    end
    if key == "feetCompass" and Frames and Frames.ApplyFeetCompassLayout and Frames.CreateFeetCompass then
        Frames.ApplyFeetCompassLayout()
        local control = Frames.CreateFeetCompass()
        control:SetMovable(true); control:SetMouseEnabled(true); control:SetHidden(false)
    elseif key == "crownArrow" and Frames and Frames.ApplyCrownDirectionArrowLayout and Frames.CreateCrownDirectionArrow then
        Frames.ApplyCrownDirectionArrowLayout()
        local control = Frames.CreateCrownDirectionArrow()
        control:SetMovable(true); control:SetMouseEnabled(true); control:SetHidden(false)
    elseif key == "pvpKD" and Combat then
        if Combat.SetPvpHudEditMode then Combat.SetPvpHudEditMode(true) end
        if Combat.pvpHudRoot then
            Combat.pvpHudRoot:SetMovable(true)
            Combat.pvpHudRoot:SetMouseEnabled(true)
            Combat.pvpHudRoot:SetHidden(false)
        end
        if Combat.pvpHudDragger then Combat.pvpHudDragger:SetMouseEnabled(true) end
    elseif key == "stats" and Combat and Combat.CreateLiveStatWidgets then
        Combat.CreateLiveStatWidgets()
        for _, widget in pairs(Combat.liveStatWidgets or {}) do
            if widget and widget.root then widget.root:SetHidden(false); widget.root:SetMouseEnabled(true); widget.root:SetMovable(true) end
        end
    elseif key == "shield" and Combat and Combat.CreateLiveStatWidgets then
        Combat.CreateLiveStatWidgets()
        local widget = Combat.liveStatWidgets and Combat.liveStatWidgets.shield
        if widget and widget.root then
            widget.root:SetHidden(false); widget.root:SetMouseEnabled(true); widget.root:SetMovable(true)
            if widget.label then widget.label:SetText("12500") end
        end
    elseif key == "cc" and Combat and Combat.ccImmunityRoot then
        Combat.ccImmunityRoot:SetMovable(true); Combat.ccImmunityRoot:SetMouseEnabled(true); Combat.ccImmunityRoot:SetHidden(false)
        if Combat.ccImmunityCountdown then Combat.ccImmunityCountdown:SetText("6.0") end
    elseif key == "debuffs" and Combat then
        if Combat.playerDebuffRoot then Combat.playerDebuffRoot:SetMovable(true); Combat.playerDebuffRoot:SetMouseEnabled(true); Combat.playerDebuffRoot:SetHidden(false) end
        if Combat.targetDebuffRoot then Combat.targetDebuffRoot:SetMovable(true); Combat.targetDebuffRoot:SetMouseEnabled(true); Combat.targetDebuffRoot:SetHidden(false) end
    elseif key == "corrosiveAlert" and EnemyAlerts and EnemyAlerts.SetPreviewKind then
        EnemyAlerts.SetPreviewKind("corrosive")
    elseif key == "onslaughtAlert" and EnemyAlerts and EnemyAlerts.SetPreviewKind then
        EnemyAlerts.SetPreviewKind("onslaught")
    elseif (key == "burst" or key == "execute") and Combat and Combat.combatDangerRoot then
        local root = Combat.combatDangerRoot
        root:SetMovable(true); root:SetMouseEnabled(true); root:SetHidden(false)
        local label = Combat.combatDangerLabels and Combat.combatDangerLabels[1]
        if label then
            label:ClearAnchors(); label:SetAnchor(CENTER, root, CENTER, 0, 0)
            label:SetText(key == "burst" and "BURST DAMAGE" or "EXECUTE DANGER")
            if key == "burst" then label:SetColor(1.0, 0.12, 0.08, 1) else label:SetColor(1.0, 0.18, 0.16, 1) end
            label:SetHidden(false)
        end
    elseif key == "food" and Combat and Combat.foodWarningRoot then
        Combat.foodWarningRoot:SetMovable(true); Combat.foodWarningRoot:SetMouseEnabled(true); Combat.foodWarningRoot:SetHidden(false)
    elseif key == "resolve" and Combat and Combat.majorResolveWarningRoot then
        Combat.majorResolveWarningRoot:SetMovable(true); Combat.majorResolveWarningRoot:SetMouseEnabled(true); Combat.majorResolveWarningRoot:SetHidden(false)
    elseif key == "breach" and Combat and Combat.majorBreachRoot then
        Combat.majorBreachEditMode = true
        Combat.majorBreachRoot:SetMovable(true); Combat.majorBreachRoot:SetMouseEnabled(true); Combat.majorBreachRoot:SetHidden(false)
        if Combat.majorBreachLabel then Combat.majorBreachLabel:SetColor(1, 0.12, 0.08, 1); Combat.majorBreachLabel:SetText("●") end
    end
end

function Q.ActivatePreviewRuntime()
    if Q.previewRuntime then return end
    local runtime = {}
    local f = GetProfileFrames()
    local c = GetCombatSettings()
    runtime.framesLocked = f and f.locked ~= false
    runtime.combatLocked = c and c.locked ~= false
    local fab = rawget(_G, "FancyActionBar")
    runtime.fabUnlocked = fab and fab.IsUnlocked and fab.IsUnlocked() or false
    Q.previewRuntime = runtime

    if Frames and Frames.SetLocked then Frames.SetLocked(false, true) end
    if Combat and Combat.SetPositionPreview then Combat.SetPositionPreview(true) end
    if fab and fab.ToggleMover then pcall(fab.ToggleMover, true) end
    Q.ApplyActualPreviewVisibility()
end

function Q.DeactivatePreviewRuntime()
    local runtime = Q.previewRuntime
    Q.previewRuntime = nil
    Q.resizeEnabled = false

    if EnemyAlerts and EnemyAlerts.SetPreviewKind then EnemyAlerts.SetPreviewKind(nil) end
    if Frames then
        local feet = Frames.CreateFeetCompass and Frames.CreateFeetCompass() or nil
        local crown = Frames.CreateCrownDirectionArrow and Frames.CreateCrownDirectionArrow() or nil
        if feet then feet:SetMovable(false); feet:SetMouseEnabled(false) end
        if crown then crown:SetMovable(false); crown:SetMouseEnabled(false) end
        if runtime and Frames.SetLocked then Frames.SetLocked(runtime.framesLocked ~= false, true) end
        if Frames.RefreshNavigationHelpers then Frames.RefreshNavigationHelpers(true) end
    end
    if Combat then
        Combat.majorBreachEditMode = false
        if Combat.SetPvpHudEditMode then Combat.SetPvpHudEditMode(false) end
        for _, root in pairs({ Combat.ccImmunityRoot, Combat.playerDebuffRoot, Combat.targetDebuffRoot, Combat.combatDangerRoot, Combat.foodWarningRoot, Combat.majorResolveWarningRoot, Combat.majorBreachRoot }) do
            if root then root:SetMovable(false); root:SetMouseEnabled(false) end
        end
        if runtime and Combat.SetPositionPreview then Combat.SetPositionPreview(runtime.combatLocked == false) end
        if Combat.UpdateLiveStatWidgets then Combat.UpdateLiveStatWidgets(true) end
        if Combat.ScanPlayerAuraHud then Combat.ScanPlayerAuraHud() end
        if Combat.ScanTargetAuras then Combat.ScanTargetAuras() end
        if Combat.UpdateCombatDangerWarnings then Combat.UpdateCombatDangerWarnings(true) end
        if Combat.UpdateFoodWarning then Combat.UpdateFoodWarning() end
        if Combat.UpdateMajorResolveWarning then Combat.UpdateMajorResolveWarning() end
        if Combat.UpdateMajorBreachDisplay then Combat.UpdateMajorBreachDisplay() end
    end
    if Frames then
        if Frames.dsEnemyHealthControl and Frames.dsEnemyHealthControl.frame then Frames.dsEnemyHealthControl.frame:SetMovable(false); Frames.dsEnemyHealthControl.frame:SetMouseEnabled(false) end
        if Frames.dsSelfHealthControl and Frames.dsSelfHealthControl.frame then Frames.dsSelfHealthControl.frame:SetMovable(false); Frames.dsSelfHealthControl.frame:SetMouseEnabled(false) end
    end
    local fab = rawget(_G, "FancyActionBar")
    if fab and fab.ToggleMover and runtime then pcall(fab.ToggleMover, runtime.fabUnlocked == true) end
    if FAB and FAB.ApplyCombatOnlyVisibility then FAB.ApplyCombatOnlyVisibility(false) end
end

local function CloseChatEntryNow()
    local entry = CHAT_SYSTEM and CHAT_SYSTEM.textEntry or nil
    if not entry then return end
    local isOpen = false
    if type(entry.IsOpen) == "function" then
        local ok, value = pcall(entry.IsOpen, entry)
        isOpen = ok and value == true
    end
    if isOpen and type(entry.Close) == "function" then
        pcall(entry.Close, entry)
    end
end

local function ReleaseQuickMenuMouseInput(enabled)
    local allowMouse = enabled == true
    if Q.panel and Q.panel.SetMouseEnabled then Q.panel:SetMouseEnabled(allowMouse) end
    if Q.closeButton and Q.closeButton.SetMouseEnabled then Q.closeButton:SetMouseEnabled(allowMouse) end
    for _, button in pairs(Q.buttons or {}) do
        if button and button.SetMouseEnabled then button:SetMouseEnabled(allowMouse) end
    end
end


function Q.BeginManualClose()
    -- Only arm the close here. The actual close happens after mouse-up so the
    -- left button has completed its UI click before control returns to gameplay.
    Q.chatReopenGeneration = (Q.chatReopenGeneration or 0) + 1
    Q.actionGeneration = (Q.actionGeneration or 0) + 1
    Q.actionInProgress = false
    Q.actionButtonKey = nil
    Q.pendingAction = nil
    Q.closePending = true
end

function Q.ManualClose()
    Q.closePending = false

    -- If the quick menu was launched from the normal Ultivite settings panel,
    -- closing it must not touch chat or gameplay input at all. The settings panel
    -- remains underneath and continues to own UI mode normally.
    if Q.openedFromSettings == true then
        Q.openedFromSettings = false
        Q.manualDismissed = false
        Q.HideNow()
        return
    end

    Q.manualDismissed = true
    Q.chatSessionActive = false
    Q.HideNow()
    -- This runs from mouse-up, so it is safe to close ESO chat synchronously and
    -- let ESO's own TextEntry:Close() path release UI/camera input.
    CloseChatEntryNow()
end

function Q.OpenFromSettings()
    if not Q.initialized then Q.Create() end
    Q.chatReopenGeneration = (Q.chatReopenGeneration or 0) + 1
    Q.actionGeneration = (Q.actionGeneration or 0) + 1
    Q.actionInProgress = false
    Q.actionButtonKey = nil
    Q.pendingAction = nil
    Q.closePending = false
    Q.manualDismissed = false
    Q.openedFromSettings = true
    Q.Show()
end

function Q.CloseSettingsSession()
    if Q.openedFromSettings ~= true then return end
    Q.openedFromSettings = false
    Q.manualDismissed = false
    Q.HideNow()
end

function Q.HideNow()
    Q.pointerInside = false
    if Q.panel then Q.panel:SetHidden(true) end
    ReleaseQuickMenuMouseInput(false)
    if Q.previewEnabled == true or Q.previewRuntime then
        Q.previewEnabled = false
        Q.DeactivatePreviewRuntime()
    end
end

function Q.SyncPreviewVisibility()
    -- Preview edits only the real HUD controls in their real positions.
end

function Q.Show()
    if not Q.CanShow() then Q.HideNow(); return end
    Q.Refresh()
    ReleaseQuickMenuMouseInput(true)
    if Q.panel then Q.panel:SetHidden(false) end
end

function Q.RefreshChatVisibility(force)
    -- The X is a two-phase close. Keep the control alive between mouse-down and
    -- mouse-up even if clicking it makes chat lose focus in that same frame.
    if Q.closePending == true then return end

    -- A Quick Menu launched from Ultivite's addon settings is intentionally
    -- independent of chat. It stays open until X is pressed or the settings
    -- panel closes.
    if Q.openedFromSettings == true then
        if Q.panel and Q.panel:IsHidden() then Q.Show() end
        return
    end

    local liveEntryOpen = Q.IsChatOpen()
    -- Open/Close hooks own the session state. The live query is only a recovery
    -- path for reload/order edge cases, never a reason to close a still-active
    -- session because some child control changed visual state.
    if liveEntryOpen then Q.chatSessionActive = true end
    local isOpen = Q.chatSessionActive == true or liveEntryOpen
    local stateChanged = Q.lastChatOpen ~= isOpen
    Q.lastChatOpen = isOpen

    -- A quick-menu click temporarily transfers mouse focus away from the chat
    -- edit box. That is not a user-requested chat close. Keep the panel alive
    -- until the action has restored chat and verified its resulting state.
    local heldForAction = Q.actionInProgress == true or Q.pointerInside == true or GetNowMs() < (Q.interactionHoldUntil or 0)
    if not isOpen and heldForAction and Q.manualDismissed ~= true then
        if Q.CanShow() and Q.panel and Q.panel:IsHidden() then ReleaseQuickMenuMouseInput(true); Q.panel:SetHidden(false) end
        return
    end

    if not isOpen then
        -- A genuine chat close/minimize ends the quick-menu session. This also
        -- clears a manual X dismissal so the next Enter can open it normally.
        Q.manualDismissed = false
        if force or stateChanged or (Q.panel and not Q.panel:IsHidden()) then Q.HideNow() end
        return
    end

    if Q.manualDismissed == true then
        if Q.panel and not Q.panel:IsHidden() then Q.HideNow() end
        return
    end

    if Q.CanShow() then
        if force or stateChanged or (Q.panel and Q.panel:IsHidden()) then
            Q.Refresh()
            ReleaseQuickMenuMouseInput(true)
            if Q.panel then Q.panel:SetHidden(false) end
        end
        if Q.previewEnabled and (force or stateChanged) then Q.ApplyActualPreviewVisibility() end
    else
        Q.HideNow()
    end
end

function Q.InstallChatHooks()
    if Q.chatHooksInstalled or not ZO_PostHook then return end
    Q.chatHooksInstalled = true

    local function refreshSoon()
        zo_callLater(function() Q.RefreshChatVisibility(true) end, 0)
    end

    local entry = CHAT_SYSTEM and CHAT_SYSTEM.textEntry or nil
    if entry then
        if type(entry.Open) == "function" then
            pcall(ZO_PostHook, entry, "Open", function()
                -- A fresh Enter/chat-open is a new session. Cancel any deferred
                -- close from the previous quick-menu session before it can touch it.
                Q.chatReopenGeneration = (Q.chatReopenGeneration or 0) + 1
                local focusGeneration = Q.chatReopenGeneration
                Q.openedFromSettings = false
                Q.manualDismissed = false
                Q.closePending = false
                Q.chatSessionActive = true
                if Frames and Frames.ApplyChatVisibilityMode then Frames.ApplyChatVisibilityMode() end
                refreshSoon()

                -- Showing Ultivite's mouse-enabled overlay must never leave the
                -- newly opened ESO chat box without keyboard focus. Reassert the
                -- stock edit-control focus on the next frame only if this is still
                -- the same chat session.
                zo_callLater(function()
                    if focusGeneration ~= (Q.chatReopenGeneration or 0) then return end
                    if Q.manualDismissed == true or Q.openedFromSettings == true then return end
                    EnsureChatKeyboardFocus()
                end, 0)
            end)
        end
        if type(entry.Close) == "function" then
            pcall(ZO_PostHook, entry, "Close", function()
                Q.chatSessionActive = false
                refreshSoon()
            end)
        end
    end

    local containers = {}
    if CHAT_SYSTEM and CHAT_SYSTEM.primaryContainer then containers[#containers + 1] = CHAT_SYSTEM.primaryContainer end
    if CHAT_SYSTEM and type(CHAT_SYSTEM.GetPrimaryContainer) == "function" then
        local ok, container = pcall(CHAT_SYSTEM.GetPrimaryContainer, CHAT_SYSTEM)
        if ok and container then containers[#containers + 1] = container end
    end
    for _, container in ipairs(containers) do
        if type(container.Minimize) == "function" then
            pcall(ZO_PostHook, container, "Minimize", function()
                Q.chatSessionActive = false
                refreshSoon()
            end)
        end
        for _, methodName in ipairs({ "Maximize", "Restore" }) do
            if type(container[methodName]) == "function" then
                pcall(ZO_PostHook, container, methodName, refreshSoon)
            end
        end
    end
end

function Q.StartChatWatch()
    Q.InstallChatHooks()
    if Q.chatWatchRegistered then return end
    Q.chatWatchRegistered = true
    EVENT_MANAGER:RegisterForUpdate("UltiviteQuickMenuChatWatch", CHAT_WATCH_MS, function()
        -- Preview visibility is applied on selection/state changes. Reapplying it
        -- every 50ms caused real HUD update routines to hide a control and the
        -- quick menu to show it again on alternating frames, producing strobing.
        Q.RefreshChatVisibility(false)
    end)
    Q.RefreshChatVisibility(true)
end

-- Bandits UI minimap bridge. Bandits publishes BUI_Ready and
-- BUI_MiniMap_Shown callbacks. Bandits 4.427+ extracted minimap settings from
-- the older module layout, so the live BUI.MiniMap table may not exist while
-- the minimap is disabled. Ultivite therefore treats the saved setting and the
-- live module as separate compatibility paths. It never creates its own map.
local BANDITS_MINIMAP_SETTING_KEYS = {
    "MiniMap", "Minimap", "miniMap", "minimap",
    "ShowMiniMap", "ShowMinimap", "showMiniMap", "showMinimap",
    "MiniMapEnabled", "MinimapEnabled", "miniMapEnabled", "minimapEnabled",
    "EnableMiniMap", "EnableMinimap", "enableMiniMap", "enableMinimap",
}

local function NormalizeBanditsSettingKey(value)
    return string.lower(tostring(value or "")):gsub("[^a-z]", "")
end

local BANDITS_MINIMAP_NORMALIZED_KEYS = {
    minimap = true,
    showminimap = true,
    minimapenabled = true,
    enableminimap = true,
}

local function BanditsSettingToBool(value)
    if type(value) == "boolean" then return value end
    if type(value) == "number" then return value ~= 0 end
    if type(value) == "string" then
        local normalized = string.lower(value):gsub("^%s+", ""):gsub("%s+$", "")
        if normalized == "1" or normalized == "true" or normalized == "on"
            or normalized == "enabled" or normalized == "show" or normalized == "shown" then
            return true
        end
        if normalized == "0" or normalized == "false" or normalized == "off"
            or normalized == "disabled" or normalized == "hide" or normalized == "hidden" then
            return false
        end
    end
    return nil
end

local function SetBanditsSettingValue(container, key, enabled)
    if type(container) ~= "table" or key == nil then return false end
    local current = container[key]
    if type(current) == "boolean" then
        container[key] = enabled == true
    elseif type(current) == "number" then
        container[key] = enabled and 1 or 0
    elseif type(current) == "string" then
        local normalized = string.lower(current):gsub("^%s+", ""):gsub("%s+$", "")
        if normalized == "on" or normalized == "off" then
            container[key] = enabled and "On" or "Off"
        elseif normalized == "enabled" or normalized == "disabled" then
            container[key] = enabled and "Enabled" or "Disabled"
        elseif normalized == "show" or normalized == "hide" then
            container[key] = enabled and "Show" or "Hide"
        elseif normalized == "1" or normalized == "0" then
            container[key] = enabled and "1" or "0"
        else
            container[key] = enabled and "true" or "false"
        end
    else
        container[key] = enabled == true
    end
    return true
end

local function FindBanditsMiniMapSetting()
    if Q.banditsMiniMapSettingContainer and Q.banditsMiniMapSettingKey then
        local value = Q.banditsMiniMapSettingContainer[Q.banditsMiniMapSettingKey]
        if BanditsSettingToBool(value) ~= nil then
            return Q.banditsMiniMapSettingContainer, Q.banditsMiniMapSettingKey
        end
    end

    local bui = rawget(_G, "BUI")
    if type(bui) ~= "table" then return nil, nil end
    local roots = {
        bui.Vars, bui.SavedVars, bui.Settings, bui.vars, bui.settings,
        bui.MiniMapSettings, bui.MinimapSettings, bui.MiniMapVars, bui.MinimapVars,
    }

    local function inspect(tbl)
        if type(tbl) ~= "table" then return nil, nil end
        for _, key in ipairs(BANDITS_MINIMAP_SETTING_KEYS) do
            if BanditsSettingToBool(tbl[key]) ~= nil then return tbl, key end
        end
        for key, value in pairs(tbl) do
            if BANDITS_MINIMAP_NORMALIZED_KEYS[NormalizeBanditsSettingKey(key)]
                and BanditsSettingToBool(value) ~= nil then
                return tbl, key
            end
        end
        return nil, nil
    end

    for _, tbl in pairs(roots) do
        local container, key = inspect(tbl)
        if container then
            Q.banditsMiniMapSettingContainer = container
            Q.banditsMiniMapSettingKey = key
            return container, key
        end
    end

    -- Current Bandits has moved minimap settings between files over time. Search
    -- two settings levels, but only inside roots and branches whose names clearly
    -- identify minimap/map/navigation data so unrelated Bandits booleans are safe.
    local function inspectNested(tbl, depth)
        if type(tbl) ~= "table" or depth > 2 then return nil, nil end
        for parentKey, nested in pairs(tbl) do
            if type(nested) == "table" then
                local normalized = NormalizeBanditsSettingKey(parentKey)
                if normalized == "minimap" or normalized == "map" or normalized == "navigation"
                    or normalized == "minimapsettings" or normalized == "minimapvars" then
                    local container, key = inspect(nested)
                    if container then return container, key end
                    container, key = inspectNested(nested, depth + 1)
                    if container then return container, key end
                end
            end
        end
        return nil, nil
    end

    for _, tbl in pairs(roots) do
        local container, key = inspectNested(tbl, 1)
        if container then
            Q.banditsMiniMapSettingContainer = container
            Q.banditsMiniMapSettingKey = key
            return container, key
        end
    end
    return nil, nil
end

local function TryBanditsMiniMapCall(object, methodName, ...)
    if type(object) ~= "table" or type(object[methodName]) ~= "function" then return false end
    local fn = object[methodName]
    local args = { ... }

    -- Bandits historically defines functions with dot syntax. Try that form
    -- first, then colon/self style for newer or wrapped implementations.
    local ok = pcall(fn, unpack(args))
    if ok then return true end
    ok = pcall(fn, object, unpack(args))
    return ok == true
end

local function TryBanditsGlobalCall(name, ...)
    local fn = rawget(_G, name)
    if type(fn) ~= "function" then return false end
    return pcall(fn, ...)
end

local function GetBanditsMiniMapModule()
    local bui = rawget(_G, "BUI")
    if type(bui) ~= "table" then return nil end
    local candidates = {
        bui.MiniMap, bui.Minimap, bui.MiniMapModule, bui.MinimapModule,
        rawget(_G, "BUI_MiniMap"), rawget(_G, "BUI_Minimap"),
    }
    for _, candidate in pairs(candidates) do
        if type(candidate) == "table" then return candidate end
    end
    return nil
end

local function ProbeBanditsMiniMapState()
    local module = GetBanditsMiniMapModule()
    if module then
        for _, methodName in ipairs({ "IsShown", "IsVisible", "IsEnabled", "GetEnabled" }) do
            if type(module[methodName]) == "function" then
                local ok, value = pcall(module[methodName], module)
                if not ok then ok, value = pcall(module[methodName]) end
                if ok and type(value) == "boolean" then
                    Q.banditsMiniMapShown = value
                    return value
                end
            end
        end
    end

    local container, key = FindBanditsMiniMapSetting()
    if container and key then
        local state = BanditsSettingToBool(container[key])
        if state ~= nil then
            Q.banditsMiniMapShown = state
            return state
        end
    end
    return Q.banditsMiniMapShown
end

local function BanditsMiniMapStateText()
    if not rawget(_G, "BUI") then return "NOT INSTALLED" end
    local state = ProbeBanditsMiniMapState()
    if state == nil then return "READY" end
    return state and "ON" or "OFF"
end

local function SetBanditsMiniMapEnabled(enabled)
    local bui = rawget(_G, "BUI")
    if type(bui) ~= "table" then
        if d then d("[Ultivite] Bandits minimap unavailable: Bandits User Interface is not loaded.") end
        return false
    end

    enabled = enabled == true
    local current = ProbeBanditsMiniMapState()
    if current ~= nil and current == enabled then return true end

    local container, settingKey = FindBanditsMiniMapSetting()
    local settingChanged = false
    if container and settingKey then
        settingChanged = SetBanditsSettingValue(container, settingKey, enabled)
    end

    local module = GetBanditsMiniMapModule()
    local invoked = false

    if module then
        if enabled then
            invoked = TryBanditsMiniMapCall(module, "SetEnabled", true)
                or TryBanditsMiniMapCall(module, "SetVisible", true)
                or TryBanditsMiniMapCall(module, "SetShown", true)
                or TryBanditsMiniMapCall(module, "Enable")
                or TryBanditsMiniMapCall(module, "Show")
        else
            -- Bandits 4.437's own Minimap checkbox writes BUI.Vars.MiniMap
            -- and then calls BUI.MiniMap.ReInit(). Merely changing the saved
            -- setting leaves an already-running minimap alive until ReInit
            -- tears down the minimap and restores the normal world map.
            if settingChanged then
                invoked = TryBanditsMiniMapCall(module, "ReInit")
            end
            if not invoked then
                invoked = TryBanditsMiniMapCall(module, "SetEnabled", false)
                    or TryBanditsMiniMapCall(module, "SetVisible", false)
                    or TryBanditsMiniMapCall(module, "SetShown", false)
                    or TryBanditsMiniMapCall(module, "Disable")
                    or TryBanditsMiniMapCall(module, "Hide")
            end
        end

        if not invoked and not settingChanged and type(module.Toggle) == "function" and current ~= nil then
            invoked = TryBanditsMiniMapCall(module, "Toggle")
        end
    end

    -- Compatibility with extracted/current builds that expose the binding/helper
    -- as a global instead of keeping the full module table alive while disabled.
    if not invoked then
        if enabled then
            invoked = TryBanditsGlobalCall("BUI_MiniMap_Show")
                or TryBanditsGlobalCall("BUI_Minimap_Show")
                or TryBanditsGlobalCall("BUI_ShowMiniMap")
        else
            invoked = TryBanditsGlobalCall("BUI_MiniMap_Hide")
                or TryBanditsGlobalCall("BUI_Minimap_Hide")
                or TryBanditsGlobalCall("BUI_HideMiniMap")
        end
    end

    if not invoked and not settingChanged and current ~= nil then
        invoked = TryBanditsGlobalCall("BUI_MiniMap_Toggle")
            or TryBanditsGlobalCall("BUI_Minimap_Toggle")
            or TryBanditsGlobalCall("BUI_ToggleMiniMap")
    end

    if not invoked and not settingChanged then
        if d then d("[Ultivite] Bandits minimap toggle unavailable: no compatible Bandits minimap setting or live method was found.") end
        return false
    end

    Q.banditsMiniMapShown = enabled

    -- When Bandits was loaded with its minimap disabled, recent builds may not
    -- instantiate the minimap module at all. The SavedVariable has now been
    -- restored, so a single ReloadUI is the reliable way to let Bandits create
    -- the module. Do this only on OFF -> ON when no live method was available.
    if enabled and settingChanged and not invoked and module == nil and type(ReloadUI) == "function" then
        if d then d("[Ultivite] Bandits minimap enabled. Reloading UI so Bandits can initialize its minimap module.") end
        zo_callLater(function() ReloadUI() end, 120)
        return true
    end

    zo_callLater(function()
        ProbeBanditsMiniMapState()
        Q.Refresh()
    end, 100)
    return true
end

local function ToggleBanditsMiniMap()
    local current = ProbeBanditsMiniMapState()
    if current == nil then
        local container, key = FindBanditsMiniMapSetting()
        if container and key then current = BanditsSettingToBool(container[key]) end
    end
    if current == nil then
        -- If Bandits is loaded but its extracted minimap module/setting has not
        -- published state yet, "turn on" is the least destructive first action.
        return SetBanditsMiniMapEnabled(true)
    end
    return SetBanditsMiniMapEnabled(not current)
end

function Q.InstallBanditsMiniMapBridge()
    if Q.banditsMiniMapBridgeInstalled then return end
    Q.banditsMiniMapBridgeInstalled = true
    if not CALLBACK_MANAGER or type(CALLBACK_MANAGER.RegisterCallback) ~= "function" then return end

    CALLBACK_MANAGER:RegisterCallback("BUI_MiniMap_Shown", function(shown)
        if type(shown) == "boolean" then Q.banditsMiniMapShown = shown end
        Q.Refresh()
    end)
    CALLBACK_MANAGER:RegisterCallback("BUI_Ready", function()
        Q.banditsMiniMapSettingContainer = nil
        Q.banditsMiniMapSettingKey = nil
        ProbeBanditsMiniMapState()
        Q.Refresh()
    end)

    ProbeBanditsMiniMapState()
end

local function GetGraphicsSettingSafe(settingId)
    if SETTING_TYPE_GRAPHICS == nil or settingId == nil or type(GetSetting) ~= "function" then return nil end
    local ok, value = pcall(GetSetting, SETTING_TYPE_GRAPHICS, settingId)
    if not ok or value == nil then return nil end
    return tostring(value)
end

local function SetGraphicsSettingSafe(settingId, value)
    if SETTING_TYPE_GRAPHICS == nil or settingId == nil or type(SetSetting) ~= "function" then return false end
    value = tostring(value)
    if GetGraphicsSettingSafe(settingId) == value then return true end
    return pcall(SetSetting, SETTING_TYPE_GRAPHICS, settingId, value) == true
end

local function ApplyGraphicsProfile(profile)
    local pve = tostring(profile):upper() ~= "PVP"
    local profileName = pve and "PVE" or "PVP"
    local ok = true
    local expectedGraphics = {}
    local expectedCVars = {}

    local function applyGraphics(settingId, value)
        if settingId == nil or value == nil then ok = false; return false end
        expectedGraphics[settingId] = tostring(value)
        local applied = SetGraphicsSettingSafe(settingId, value)
        ok = applied and ok
        return applied
    end

    local function applyCVar(name, value)
        if type(SetCVar) ~= "function" then ok = false; return false end
        local applied = pcall(SetCVar, name, tostring(value))
        if applied then expectedCVars[name] = tostring(value) end
        ok = applied and ok
        return applied
    end

    -- Only these seven settings are touched.
    if GRAPHICS_SETTING_SHADOWS ~= nil and SHADOWS_CHOICE_ULTRA ~= nil and SHADOWS_CHOICE_OFF ~= nil then
        applyGraphics(GRAPHICS_SETTING_SHADOWS, pve and SHADOWS_CHOICE_ULTRA or SHADOWS_CHOICE_OFF)
    else
        ok = false
    end

    if GRAPHICS_SETTING_SCREENSPACE_WATER_REFLECTION_QUALITY ~= nil
        and SCREENSPACE_WATER_REFLECTION_QUALITY_ULTRA ~= nil
        and SCREENSPACE_WATER_REFLECTION_QUALITY_OFF ~= nil then
        applyGraphics(GRAPHICS_SETTING_SCREENSPACE_WATER_REFLECTION_QUALITY, pve and SCREENSPACE_WATER_REFLECTION_QUALITY_ULTRA or SCREENSPACE_WATER_REFLECTION_QUALITY_OFF)
    else
        ok = false
    end

    applyGraphics(GRAPHICS_SETTING_DISTORTION, pve and "true" or "false")
    applyGraphics(GRAPHICS_SETTING_BLOOM, pve and "true" or "false")

    local godRaysSetting = _G and _G["GRAPHICS_SETTING_GOD_RAYS"] or nil
    if godRaysSetting ~= nil then
        applyGraphics(godRaysSetting, pve and "true" or "false")
    else
        applyCVar("GOD_RAYS", pve and "1" or "0")
    end

    if GRAPHICS_SETTING_CLUTTER_2D_QUALITY ~= nil and CLUTTER_QUALITY_ULTRA ~= nil and CLUTTER_QUALITY_OFF ~= nil then
        applyGraphics(GRAPHICS_SETTING_CLUTTER_2D_QUALITY, pve and CLUTTER_QUALITY_ULTRA or CLUTTER_QUALITY_OFF)
    else
        ok = false
    end

    local aoValue = pve and AMBIENT_OCCLUSION_TYPE_SSGI or AMBIENT_OCCLUSION_TYPE_NONE
    if aoValue ~= nil then
        local aoSettingId = _G and _G["GRAPHICS_SETTING_AMBIENT_OCCLUSION_TYPE"] or nil
        if aoSettingId ~= nil then
            applyGraphics(aoSettingId, aoValue)
        else
            applyCVar("AMBIENT_OCCLUSION_TYPE", aoValue)
        end
    else
        ok = false
    end

    if type(ApplySettings) == "function" then pcall(ApplySettings) end

    -- Verify the cached values after ESO applies the profile. A successful pcall
    -- alone is not proof that the setting changed.
    for settingId, expected in pairs(expectedGraphics) do
        if GetGraphicsSettingSafe(settingId) ~= expected then ok = false end
    end
    if type(GetCVar) == "function" then
        for name, expected in pairs(expectedCVars) do
            local readOk, actual = pcall(GetCVar, name)
            if not readOk or tostring(actual) ~= expected then ok = false end
        end
    end

    if ok then
        Q.lastAppliedGraphicsProfile = profileName
        if d then d("[Ultivite] Applied " .. profileName .. " graphics profile and verified the changed settings.") end
        return true
    end

    if d then d("[Ultivite] Graphics profile verification failed for one or more video settings on this client.") end
    return false
end

local function ApplyPveGraphicsProfile()
    return ApplyGraphicsProfile("PVE")
end

local function ApplyPvpGraphicsProfile()
    return ApplyGraphicsProfile("PVP")
end

local function GetQuickPlayerLayout()
    if Frames and Frames.GetQuickPlayerLayout then
        return Frames.GetQuickPlayerLayout()
    end
    return "normal"
end

function Q.GetDarkSoulsMode()
    local f = GetProfileFrames()
    if not f then return "off" end

    if f.fullDarkSoulsMode == true then
        return "full"
    end

    if f.darkSoulsMode == true and f.hideActionBar ~= true then
        if f.dsSelfHealthBar == true and f.dsSelfResourceBars ~= true and f.dsEnemyHealthMode == "off" then
            return "actionSelf"
        end
        if f.dsEnemyHealthMode == "only" and FAB and FAB.IsAvailable and FAB.IsAvailable() then
            return "actionEnemy"
        end
    end

    local quick = GetQuickPlayerLayout()
    if quick == "bottomOnly" then return "self" end
    if quick == "topLeft" then return "topLeft" end
    if quick == "both" then return "both" end
    return "off"
end

local function FindDarkSoulsModeIndex(mode)
    for index, item in ipairs(DARK_SOULS_MODES) do
        if item.id == mode then return index end
    end
    return 1
end

local function ApplyTopLeftPreset(layout)
    if Frames and Frames.SetQuickPlayerLayout then
        Frames.SetQuickPlayerLayout(layout, true)
        if Frames.SetDSEnemyHealthMode then Frames.SetDSEnemyHealthMode("off", true) end
        if Frames.SetHideActionBar then Frames.SetHideActionBar(false, true) end
    end
    if U.ApplyFullDarkSoulsAuxVisibility then U.ApplyFullDarkSoulsAuxVisibility(false) end
    if U.FinalizePresetEditingState then U.FinalizePresetEditingState() end
    RequestSave()
    RefreshLAM()
end

local PROFILE_FRAME_PRESERVE_KEYS = {
    "combatOnly",
    "groupFrameVisibilityMode", "hideGroupFrame",
    "championProgressVisibilityMode", "hideChampionProgress", "hideChampionProgressInPvp",
    "vanillaNpcNamesHidden", "vanillaNpcNameRestoreEnemy", "vanillaNpcNameRestoreFriendly", "vanillaNpcNameRestoreNeutral",
    "compassVisibilityMode", "questTrackerVisibilityMode", "queueStatusVisibilityMode", "crosshairVisibilityMode",
    "chatVisibilityMode", "autoHideChat",
    "hideMountStaminaBar", "hideWerewolfResourceBar",
    "feetCompass", "feetCompassVisibilityMode",
    "crownDirectionArrow", "crownDirectionArrowVisibilityMode",
}

local PROFILE_COMBAT_PRESERVE_KEYS = {
    "showLiveDamageStat", "showFrontResistanceStat", "showBackResistanceStat",
    "showDamageShieldStat", "showShieldBrokenWarning",
    "showPlayerDebuffTracker", "showImportantTargetDebuffs", "showCcImmunityTracker",
    "showBurstDamageWarning", "burstDamageWarningMode",
    "showExecuteDangerWarning", "executeDangerWarningMode",
    "showNoFoodWarning", "showNoMajorResolveWarning", "majorBreachTracker",
    "showEnemyCorrosiveAlert", "showEnemyOnslaughtAlert", "enemyUltimateAlertIconSize",
    "nativeHideNpcNames", "npcNamesGlobalHidden", "npcNamesOverrideActive",
}

local function CaptureIndependentQuickMenuState()
    local snapshot = { frames = {}, combat = {} }
    local f = GetProfileFrames()
    local c = GetCombatSettings()
    if f then
        for _, key in ipairs(PROFILE_FRAME_PRESERVE_KEYS) do snapshot.frames[key] = f[key] end
    end
    if c then
        for _, key in ipairs(PROFILE_COMBAT_PRESERVE_KEYS) do snapshot.combat[key] = c[key] end
    end
    return snapshot
end

local function RestoreIndependentQuickMenuState(snapshot)
    if not snapshot then return end
    local f = GetProfileFrames()
    local c = GetCombatSettings()
    if f and snapshot.frames then
        for _, key in ipairs(PROFILE_FRAME_PRESERVE_KEYS) do
            f[key] = snapshot.frames[key]
        end
    end
    if c and snapshot.combat then
        for _, key in ipairs(PROFILE_COMBAT_PRESERVE_KEYS) do
            c[key] = snapshot.combat[key]
        end
    end

    if Frames and f then
        Frames.saved = f
        if Frames.ApplyGroupFrameState then Frames.ApplyGroupFrameState() end
        if Frames.InstallGroupFrameChampionPointHook then Frames.InstallGroupFrameChampionPointHook() end
        if Frames.ApplyGroupFrameChampionPoints then Frames.ApplyGroupFrameChampionPoints() end
        if Frames.InstallChampionProgressHook then Frames.InstallChampionProgressHook() end
        if Frames.ApplyChampionProgressVisibility then Frames.ApplyChampionProgressVisibility(true) end
        if Frames.ApplyMountStaminaBarVisibility then Frames.ApplyMountStaminaBarVisibility() end
        if Frames.ApplyWerewolfResourceBarVisibility then Frames.ApplyWerewolfResourceBarVisibility() end
        if Frames.RefreshNavigationHelpers then Frames.RefreshNavigationHelpers(true) end
        if Frames.ApplyChatVisibilityMode then Frames.ApplyChatVisibilityMode() end
        if Frames.RefreshUiVisibilityRules then Frames.RefreshUiVisibilityRules(true) end
        if Frames.SetCombatOnly then Frames.SetCombatOnly(f.combatOnly == true, true) end
    end

    -- CP display is not a profile preference. It is permanently enabled.
    if f then f.showGroupFrameChampionPoints = true end
    if c then c.showNativePlayerCpFrame = true end

    if Combat and c then
        Combat.sv = c
        if Combat.UpdateLiveStatWidgets then Combat.UpdateLiveStatWidgets(true) end
        if Combat.ScanPlayerAuraHud then Combat.ScanPlayerAuraHud() end
        if Combat.ScanTargetAuras then Combat.ScanTargetAuras() end
        if Combat.UpdateImportantTargetDebuffs then Combat.UpdateImportantTargetDebuffs(true) end
        if Combat.UpdateCombatDangerWarnings then Combat.UpdateCombatDangerWarnings(true) end
        if Combat.UpdateFoodWarning then Combat.UpdateFoodWarning() end
        if Combat.UpdateMajorResolveWarning then Combat.UpdateMajorResolveWarning() end
        if Combat.UpdateMajorBreachDisplay then Combat.UpdateMajorBreachDisplay() end
        if Combat.ApplyNativeOverheadTargetBar then Combat.ApplyNativeOverheadTargetBar() end
        if Combat.ApplyDefaultTargetFrameVisibility then Combat.ApplyDefaultTargetFrameVisibility() end
    end
end

function Q.ApplyDarkSoulsMode(mode)
    local independentSnapshot = CaptureIndependentQuickMenuState()

    local applied = true
    if mode == "full" then
        applied = not U.ApplyFullDarkSoulsPreset or U.ApplyFullDarkSoulsPreset(true) ~= false
    elseif mode == "self" then
        applied = not U.ApplyDarkSoulsSelfPreset or U.ApplyDarkSoulsSelfPreset(true) ~= false
    elseif mode == "topLeft" then
        ApplyTopLeftPreset("topLeft")
    elseif mode == "both" then
        ApplyTopLeftPreset("both")
    elseif mode == "actionEnemy" then
        applied = not U.ApplyDarkSoulsActionBarPreset or U.ApplyDarkSoulsActionBarPreset(true) ~= false
        if applied and U.SetDarkSoulsActionBarHealthSource then
            applied = U.SetDarkSoulsActionBarHealthSource("enemy", true) ~= false
        end
    elseif mode == "actionSelf" then
        applied = not U.ApplyDarkSoulsActionBarPreset or U.ApplyDarkSoulsActionBarPreset(true) ~= false
        if applied and U.SetDarkSoulsActionBarHealthSource then
            applied = U.SetDarkSoulsActionBarHealthSource("self", true) ~= false
        end
    else
        -- OFF means leave the Dark Souls layout only. Do not run the broad
        -- recommended-HUD preset because that resets unrelated quick-menu choices.
        if Frames and Frames.SetQuickPlayerLayout then
            Frames.SetQuickPlayerLayout("normal", true)
            if Frames.SetDSEnemyHealthMode then Frames.SetDSEnemyHealthMode("off", true) end
            if Frames.SetHideActionBar then Frames.SetHideActionBar(false, true) end
            if Frames.SetShowDSUltimate then Frames.SetShowDSUltimate(false, true) end
        elseif U.ApplyDefaultCombatHUDLayout then
            U.ApplyDefaultCombatHUDLayout(true)
        end
        if U.ApplyFullDarkSoulsAuxVisibility then U.ApplyFullDarkSoulsAuxVisibility(false) end
    end

    -- Profiles own layout, not the other quick-menu categories. Restore the
    -- player's independent Combat Information, Navigation, Warnings and World UI
    -- choices after a preset has finished changing its visual layout.
    RestoreIndependentQuickMenuState(independentSnapshot)

    if U.FinalizePresetEditingState then U.FinalizePresetEditingState() end
    RequestSave()
    RefreshLAM()

    if applied ~= false then
        local actual = Q.GetDarkSoulsMode()
        if actual ~= mode then
            if d then d("[Ultivite] Dark Souls profile verification failed: requested=" .. tostring(mode) .. " actual=" .. tostring(actual)) end
            return false
        end
    end
    return applied
end

function Q.CycleDarkSoulsMode()
    local current = Q.GetDarkSoulsMode()
    local index = FindDarkSoulsModeIndex(current)

    -- Skip an unavailable FAB-specific profile instead of leaving the button on
    -- the same state and making the click look broken.
    for _ = 1, #DARK_SOULS_MODES do
        index = index + 1
        if index > #DARK_SOULS_MODES then index = 1 end
        local nextMode = DARK_SOULS_MODES[index]
        local applied = Q.ApplyDarkSoulsMode(nextMode.id)
        if applied ~= false then
            Q.Refresh()
            return true
        end
        if d then d("[Ultivite] Skipping unavailable Dark Souls profile: " .. tostring(nextMode.label)) end
    end

    return false
end

local function CycleIndex(current, cycle)
    local index = 1
    for i, value in ipairs(cycle) do
        if value == current then index = i break end
    end
    index = index + 1
    if index > #cycle then index = 1 end
    return cycle[index]
end

local function ToggleCombatOnly()
    if not Frames or not Frames.saved or not Frames.SetCombatOnly then return end
    local enableCombatOnly = Frames.saved.combatOnly ~= true
    if Frames.SetHideActionBar and Frames.saved.hideActionBar == true then
        Frames.SetHideActionBar(false, true)
    end
    Frames.SetCombatOnly(enableCombatOnly, true)
    RequestSave()
    RefreshLAM()
end

local function ToggleActionBar()
    if not Frames or not Frames.saved or not Frames.SetHideActionBar then return end
    Frames.SetHideActionBar(Frames.saved.hideActionBar ~= true, true)
end

local function CycleVisibility(kind, cycle)
    if not Frames or not Frames.GetUiVisibilityMode or not Frames.SetUiVisibilityMode then return end
    cycle = cycle or STANDARD_VISIBILITY_CYCLE
    Frames.SetUiVisibilityMode(kind, CycleIndex(Frames.GetUiVisibilityMode(kind), cycle), true)
end

local function ToggleCombatBoolean(key, defaultOn, refreshFunction)
    local sv = GetCombatSettings()
    if not sv then return end
    local current = defaultOn and sv[key] ~= false or sv[key] == true
    sv[key] = not current
    if Combat then
        Combat.sv = sv
        if refreshFunction and Combat[refreshFunction] then Combat[refreshFunction]() end
    end
    RequestSave()
    RefreshLAM()
end

local function ToggleMajorBreach()
    local sv = GetCombatSettings()
    if not sv then return end
    sv.majorBreachTracker = not (sv.majorBreachTracker ~= false)
    if Combat then
        Combat.sv = sv
        if not sv.majorBreachTracker and Combat.SetMajorBreachState then Combat.SetMajorBreachState(false, 0, 0, "") end
        if Combat.UpdateMajorBreachDisplay then Combat.UpdateMajorBreachDisplay() end
    end
    RequestSave(); RefreshLAM()
end

local SetNpcNamesHidden
local ENEMY_HEALTH_CYCLE = { "vanilla", "target", "all", "off" }
local function GetEnemyHealthMode()
    local sv = GetCombatSettings()
    if not sv then return "vanilla" end
    if sv.hideNativeOverheadHealthBars == true then return "off" end
    if sv.nativeOverheadTargetBar == true then
        return sv.nativeAllEnemyHealthbars == true and "all" or "target"
    end
    return "vanilla"
end

local function SetEnemyHealthMode(mode)
    local sv = GetCombatSettings()
    if not sv or not Combat then return end
    Combat.sv = sv
    if mode == "off" then
        if sv.quickMenuEnemyHealthSavedTargetFrame ~= nil then
            sv.targetFrame = sv.quickMenuEnemyHealthSavedTargetFrame == true
            sv.quickMenuEnemyHealthSavedTargetFrame = nil
        end
        sv.hideDefaultTargetFrame = true
        if Combat.SetHideNativeOverheadHealthBars then Combat.SetHideNativeOverheadHealthBars(true, true) end
    elseif mode == "target" or mode == "all" then
        if sv.quickMenuEnemyHealthSavedTargetFrame ~= nil then
            sv.targetFrame = sv.quickMenuEnemyHealthSavedTargetFrame == true
            sv.quickMenuEnemyHealthSavedTargetFrame = nil
        end
        sv.hideDefaultTargetFrame = true
        sv.hideNativeOverheadHealthBars = false
        sv.nativeOverheadTargetBar = true
        sv.nativeAllEnemyHealthbars = mode == "all"
        if Combat.ApplyNativeOverheadTargetBar then Combat.ApplyNativeOverheadTargetBar() end
        if Combat.ApplyDefaultTargetFrameVisibility then Combat.ApplyDefaultTargetFrameVisibility() end
    else
        -- VANILLA must mean one clean base-game presentation, not ESO's stock
        -- target frame plus Ultivite's persistent custom target frame together.
        if sv.quickMenuEnemyHealthSavedTargetFrame == nil then
            sv.quickMenuEnemyHealthSavedTargetFrame = sv.targetFrame ~= false
        end
        sv.targetFrame = false
        sv.hideNativeOverheadHealthBars = false
        sv.nativeOverheadTargetBar = false
        sv.hideDefaultTargetFrame = false
        if Combat.ApplyNativeOverheadTargetBar then Combat.ApplyNativeOverheadTargetBar() end
        if Combat.ApplyDefaultTargetFrameVisibility then Combat.ApplyDefaultTargetFrameVisibility() end
    end
    if Combat.RefreshDisplay then Combat.RefreshDisplay() end
    local f = GetProfileFrames()
    if f and f.vanillaNpcNamesHidden == true and SetNpcNamesHidden then SetNpcNamesHidden(true) end
    RequestSave(); RefreshLAM()
end

local function CycleEnemyHealth()
    SetEnemyHealthMode(CycleIndex(GetEnemyHealthMode(), ENEMY_HEALTH_CYCLE))
end

local GROUP_CYCLE = { "show", "pvp", "hide" }
local function CycleGroupFrame()
    if not Frames or not Frames.GetGroupFrameVisibilityMode or not Frames.SetGroupFrameVisibilityMode then return end
    Frames.SetGroupFrameVisibilityMode(CycleIndex(Frames.GetGroupFrameVisibilityMode(), GROUP_CYCLE), true)
end

local CP_CYCLE = { "show", "combat", "pvp", "hide" }
local function CycleCpProgress()
    if not Frames or not Frames.GetChampionProgressVisibilityMode or not Frames.SetChampionProgressVisibilityMode then return end
    Frames.SetChampionProgressVisibilityMode(CycleIndex(Frames.GetChampionProgressVisibilityMode(), CP_CYCLE), true)
end

local function GetEsoNameplateSetting(settingId)
    if not GetSetting or SETTING_TYPE_NAMEPLATES == nil or settingId == nil then return "" end
    local ok, value = pcall(GetSetting, SETTING_TYPE_NAMEPLATES, settingId)
    return ok and tostring(value or "") or ""
end

local function SetEsoNameplateSetting(settingId, value)
    if not SetSetting or SETTING_TYPE_NAMEPLATES == nil or settingId == nil or value == nil then return false end
    value = tostring(value)
    if GetEsoNameplateSetting(settingId) == value then return true end
    local option = SETTINGS_SET_OPTION_SAVE_TO_PERSISTED_DATA
    local ok
    if option ~= nil then
        ok = pcall(SetSetting, SETTING_TYPE_NAMEPLATES, settingId, value, option)
    else
        ok = pcall(SetSetting, SETTING_TYPE_NAMEPLATES, settingId, value)
    end
    if not ok then return false end
    return GetEsoNameplateSetting(settingId) == value
end

SetNpcNamesHidden = function(hidden)
    local f = GetProfileFrames()
    local c = GetCombatSettings()
    if not f then return false end
    hidden = hidden and true or false

    f.vanillaNpcNamesHidden = hidden
    if c then
        c.npcNamesGlobalHidden = hidden
        c.npcNamesOverrideActive = true
    end

    if Combat then
        if c then Combat.sv = c end
        if Combat.SetNpcNamesHidden then
            Combat.SetNpcNamesHidden(hidden)
        else
            local choice = hidden and (NAMEPLATE_CHOICE_NEVER or NAMEPLATE_CHOICE_NONE or 0) or (NAMEPLATE_CHOICE_ALWAYS or NAMEPLATE_CHOICE_TARGETED or 1)
            if not hidden and NAMEPLATE_TYPE_ALL_NAMEPLATES ~= nil then SetEsoNameplateSetting(NAMEPLATE_TYPE_ALL_NAMEPLATES, 1) end
            SetEsoNameplateSetting(NAMEPLATE_TYPE_ENEMY_NPC_NAMEPLATES, choice)
            SetEsoNameplateSetting(NAMEPLATE_TYPE_FRIENDLY_NPC_NAMEPLATES, choice)
            SetEsoNameplateSetting(NAMEPLATE_TYPE_NEUTRAL_NPC_NAMEPLATES, choice)
        end
    end

    RequestSave(); RefreshLAM()
    return true
end

local function ToggleNpcNames()
    local f = GetProfileFrames(); if not f then return end
    SetNpcNamesHidden(f.vanillaNpcNamesHidden ~= true)
end

local function ToggleOverheadPlayerInfo()
    if not Combat or not Combat.IsOverheadPlayerInfoEnabled or not Combat.SetOverheadPlayerInfoEnabled then return end
    Combat.SetOverheadPlayerInfoEnabled(not Combat.IsOverheadPlayerInfoEnabled(), true)
    RequestSave()
    RefreshLAM()
end

local function IsVanillaTargetFramesActive()
    local sv = GetCombatSettings()
    if not sv then return false end
    return sv.targetFrame == false
        and sv.nativeOverheadTargetBar ~= true
        and sv.hideDefaultTargetFrame ~= true
        and sv.hideNativeOverheadHealthBars ~= true
        and sv.autoHideOtherTargetFrames ~= true
end

local function ApplyVanillaTargetFrames()
    if not U or not U.ApplyVanillaTargetFrames then return false end
    local applied = U.ApplyVanillaTargetFrames(false)
    RefreshLAM()
    Q.Refresh()
    return applied
end

local CHAT_CYCLE = { "show", "combat", "pvp", "hide" }
local function CycleChatVisibility()
    if not Frames or not Frames.GetChatVisibilityMode or not Frames.SetChatVisibilityMode then return end
    Frames.SetChatVisibilityMode(CycleIndex(Frames.GetChatVisibilityMode(), CHAT_CYCLE), true)
end

local function ToggleMountMeter()
    local f = GetProfileFrames(); if not f or not Frames or not Frames.SetHideMountStaminaBar then return end
    Frames.SetHideMountStaminaBar(f.hideMountStaminaBar ~= true, true)
end

local function ToggleWerewolfMeter()
    local f = GetProfileFrames(); if not f or not Frames or not Frames.SetHideWerewolfResourceBar then return end
    Frames.SetHideWerewolfResourceBar(f.hideWerewolfResourceBar ~= true, true)
end

local STAT_CYCLE = { "off", "damage", "resistance", "both" }
local function GetStatMode()
    local c = GetCombatSettings(); if not c then return "off" end
    local damage = c.showLiveDamageStat == true
    local resistance = c.showFrontResistanceStat == true or c.showBackResistanceStat == true
    if damage and resistance then return "both" end
    if damage then return "damage" end
    if resistance then return "resistance" end
    return "off"
end
local function SetStatMode(mode)
    local c = GetCombatSettings(); if not c then return end
    c.showLiveDamageStat = mode == "damage" or mode == "both"
    c.showFrontResistanceStat = mode == "resistance" or mode == "both"
    c.showBackResistanceStat = mode == "resistance" or mode == "both"
    if Combat then Combat.sv = c; if Combat.UpdateLiveStatWidgets then Combat.UpdateLiveStatWidgets(true) end end
    RequestSave(); RefreshLAM()
end
local function CycleStats() SetStatMode(CycleIndex(GetStatMode(), STAT_CYCLE)) end

local SHIELD_CYCLE = { "off", "strength", "warning", "both" }
local function GetShieldMode()
    local c = GetCombatSettings(); if not c then return "off" end
    local strength = c.showDamageShieldStat == true
    local warning = c.showShieldBrokenWarning ~= false
    if strength and warning then return "both" end
    if strength then return "strength" end
    if warning then return "warning" end
    return "off"
end
local function SetShieldMode(mode)
    local c = GetCombatSettings(); if not c then return end
    c.showDamageShieldStat = mode == "strength" or mode == "both"
    c.showShieldBrokenWarning = mode == "warning" or mode == "both"
    if not c.showShieldBrokenWarning and Combat then Combat.shieldBreakExpiresAtMs = 0 end
    if Combat then
        Combat.sv = c
        if Combat.UpdateLiveStatWidgets then Combat.UpdateLiveStatWidgets(true) end
        if Combat.UpdateCombatDangerWarnings then Combat.UpdateCombatDangerWarnings(true) end
    end
    RequestSave(); RefreshLAM()
end
local function CycleShield() SetShieldMode(CycleIndex(GetShieldMode(), SHIELD_CYCLE)) end

local DEBUFF_CYCLE = { "off", "self", "target", "both" }
local function GetDebuffMode()
    local c = GetCombatSettings(); if not c then return "off" end
    local selfOn = c.showPlayerDebuffTracker == true
    local targetOn = c.showImportantTargetDebuffs == true
    if selfOn and targetOn then return "both" end
    if selfOn then return "self" end
    if targetOn then return "target" end
    return "off"
end
local function SetDebuffMode(mode)
    local c = GetCombatSettings(); if not c then return end
    c.showPlayerDebuffTracker = mode == "self" or mode == "both"
    c.showImportantTargetDebuffs = mode == "target" or mode == "both"
    if Combat then
        Combat.sv = c
        if Combat.ScanPlayerAuraHud then Combat.ScanPlayerAuraHud() elseif Combat.UpdatePlayerAuraHud then Combat.UpdatePlayerAuraHud() end
        if Combat.ScanTargetAuras then Combat.ScanTargetAuras() end
        if Combat.UpdateImportantTargetDebuffs then Combat.UpdateImportantTargetDebuffs(true) end
    end
    RequestSave(); RefreshLAM()
end
local function CycleDebuffs() SetDebuffMode(CycleIndex(GetDebuffMode(), DEBUFF_CYCLE)) end

local HELPER_CYCLE = { "off", "show", "combatOnly", "pvpOnly" }
local function GetHelperMode(kind)
    local f = GetProfileFrames(); if not f then return "off" end
    local enabled = kind == "feet" and (f.feetCompass == true) or (kind == "crown" and f.crownDirectionArrow == true)
    if not enabled then return "off" end
    if Frames and Frames.GetNavigationHelperVisibilityMode then return Frames.GetNavigationHelperVisibilityMode(kind) end
    return "show"
end
local function SetHelperMode(kind, mode)
    if not Frames then return false end
    if kind == "feet" and Frames.SetFeetCompass then Frames.SetFeetCompass(mode ~= "off", true) end
    if kind == "crown" and Frames.SetCrownDirectionArrow then Frames.SetCrownDirectionArrow(mode ~= "off", true) end
    if mode ~= "off" and Frames.SetNavigationHelperVisibilityMode then Frames.SetNavigationHelperVisibilityMode(kind, mode, true) end
    if Frames.RefreshNavigationHelpers then Frames.RefreshNavigationHelpers(true) end
    RequestSave(); RefreshLAM()
    return true
end
local function CycleFeetCompass() SetHelperMode("feet", CycleIndex(GetHelperMode("feet"), HELPER_CYCLE)) end
local function CycleCrownArrow() SetHelperMode("crown", CycleIndex(GetHelperMode("crown"), HELPER_CYCLE)) end

local WARNING_CYCLE = { "off", "pvp", "always" }
local function GetWarningMode(kind)
    local c = GetCombatSettings(); if not c then return "off" end
    if Combat then Combat.sv = c end
    if Combat and Combat.GetDangerWarningMode then return Combat.GetDangerWarningMode(kind) end
    local key = kind == "burst" and "showBurstDamageWarning" or "showExecuteDangerWarning"
    return c[key] == false and "off" or "always"
end
local function CycleWarning(kind)
    local c = GetCombatSettings(); if not c then return end
    if Combat then Combat.sv = c end
    local mode = CycleIndex(GetWarningMode(kind), WARNING_CYCLE)
    if Combat and Combat.SetDangerWarningMode then Combat.SetDangerWarningMode(kind, mode, true) end
end

local HUD_PRESETS = { "normal", "combat", "pvp", "minimal" }
local function GetHudVisibilityPreset()
    if not Frames then return "normal" end
    local compass = Frames.GetUiVisibilityMode and Frames.GetUiVisibilityMode("compass") or "show"
    local quests = Frames.GetUiVisibilityMode and Frames.GetUiVisibilityMode("quests") or "show"
    local queue = Frames.GetUiVisibilityMode and Frames.GetUiVisibilityMode("queue") or "show"
    local crosshair = Frames.GetUiVisibilityMode and Frames.GetUiVisibilityMode("crosshair") or "show"
    local cp = Frames.GetChampionProgressVisibilityMode and Frames.GetChampionProgressVisibilityMode() or "show"
    if compass == "show" and quests == "show" and queue == "show" and crosshair == "show" and cp == "show" then return "normal" end
    if compass == "combat" and quests == "combat" and queue == "combat" and crosshair == "show" and cp == "combat" then return "combat" end
    if compass == "pvp" and quests == "pvp" and queue == "pvp" and crosshair == "show" and cp == "pvp" then return "pvp" end
    if compass == "hide" and quests == "hide" and queue == "hide" and crosshair == "combatOnly" and cp == "hide" then return "minimal" end
    return "custom"
end
local function ApplyHudVisibilityPreset(mode)
    if not Frames then return end
    local values
    if mode == "combat" then values = { "combat", "combat", "combat", "show", "combat" }
    elseif mode == "pvp" then values = { "pvp", "pvp", "pvp", "show", "pvp" }
    elseif mode == "minimal" then values = { "hide", "hide", "hide", "combatOnly", "hide" }
    else values = { "show", "show", "show", "show", "show" } end
    if Frames.SetUiVisibilityMode then
        Frames.SetUiVisibilityMode("compass", values[1], true)
        Frames.SetUiVisibilityMode("quests", values[2], true)
        Frames.SetUiVisibilityMode("queue", values[3], true)
        Frames.SetUiVisibilityMode("crosshair", values[4], true)
    end
    if Frames.SetChampionProgressVisibilityMode then Frames.SetChampionProgressVisibilityMode(values[5], true) end
    RequestSave(); RefreshLAM()
end
local function CycleHudVisibilityPreset()
    local current = GetHudVisibilityPreset()
    local nextMode = current == "custom" and "normal" or CycleIndex(current, HUD_PRESETS)
    ApplyHudVisibilityPreset(nextMode)
end

local function VisibilityText(kind)
    if not Frames or not Frames.GetUiVisibilityMode then return "?" end
    return VISIBILITY_LABELS[Frames.GetUiVisibilityMode(kind)] or "?"
end
local function SimpleModeLabel(mode)
    local labels = {
        show = "ON", hide = "OFF", pvp = "HIDE IN PVP", combat = "HIDE IN COMBAT",
        combatOnly = "COMBAT ONLY", pvpOnly = "PVP ONLY", vanilla = "VANILLA",
        target = "TARGET ONLY", all = "ALL ENEMIES", normal = "NORMAL", minimal = "MINIMAL",
        custom = "CUSTOM", damage = "DAMAGE", resistance = "RESISTANCE", both = "BOTH",
        strength = "STRENGTH", warning = "BROKEN WARNING ONLY", self = "ON ME", targetDebuff = "TARGET",
        off = "OFF", always = "ALWAYS",
    }
    return labels[mode] or string.upper(tostring(mode or "?"))
end

local function DarkSoulsText()
    local mode = Q.GetDarkSoulsMode()
    for _, item in ipairs(DARK_SOULS_MODES) do if item.id == mode then return item.label end end
    return "CUSTOM"
end

local function SetButtonText(key, text)
    local button = Q.buttons[key]
    if button and button.SetText then button:SetText(text) end
end


-- Preview uses the real HUD controls in their real screen positions. The old
-- detached demo window was removed completely so there is only one preview path.

local PREVIEWABLE_KEYS = {
    darkSouls = true,
    enemyHealth = true,
    actionBar = true,
    pvpKD = true,
    stats = true,
    shield = true,
    debuffs = true,
    cc = true,
    feetCompass = true,
    crownArrow = true,
    corrosiveAlert = true,
    onslaughtAlert = true,
    burst = true,
    execute = true,
    food = true,
    resolve = true,
    breach = true,
}

function Q.SetPreviewEnabled(enabled)
    local newValue = enabled and true or false
    if newValue == Q.previewEnabled then return end
    Q.previewEnabled = newValue
    if newValue then
        Q.ActivatePreviewRuntime()
    else
        Q.DeactivatePreviewRuntime()
    end
    Q.SyncPreviewVisibility()
    Q.Refresh()
end

function Q.TogglePreview()
    Q.SetPreviewEnabled(Q.previewEnabled ~= true)
end

function Q.ToggleResize()
    if Q.previewEnabled ~= true then Q.SetPreviewEnabled(true) end
    Q.resizeEnabled = Q.resizeEnabled ~= true
    Q.ApplyActualPreviewVisibility()
    Q.Refresh()
end

function Q.SelectPreview(key)
    if not key or PREVIEWABLE_KEYS[key] ~= true then return end
    Q.previewKey = key
    if Q.previewEnabled then Q.ApplyActualPreviewVisibility() end
end

function Q.Refresh()
    local f = GetProfileFrames()
    local c = GetCombatSettings()
    SetButtonText("preview", "PREVIEW: " .. BoolText(Q.previewEnabled == true))
    SetButtonText("resize", "RESIZE: " .. BoolText(Q.resizeEnabled == true))
    SetButtonText("darkSouls", "DARK SOULS PROFILE: " .. DarkSoulsText())
    local hudPreset = GetHudVisibilityPreset()
    local hudText = hudPreset == "combat" and "COMBAT CLEAN" or hudPreset == "pvp" and "PVP CLEAN" or SimpleModeLabel(hudPreset)
    SetButtonText("hudVisibility", "HUD VISIBILITY: " .. hudText)
    SetButtonText("enemyHealth", "ENEMY HEALTH BARS: " .. SimpleModeLabel(GetEnemyHealthMode()))
    SetButtonText("combatOnly", "COMBAT HUD: " .. ((f and f.combatOnly == true) and "COMBAT ONLY" or "ALWAYS"))
    SetButtonText("actionBar", "ACTION BAR: " .. BoolText(not (f and f.hideActionBar == true)))
    SetButtonText("vanillaTargetFrames", IsVanillaTargetFramesActive() and "TARGET FRAMES: VANILLA / DEFAULT" or "RESTORE VANILLA TARGET FRAMES")
    SetButtonText("groupFrame", "GROUP FRAME: " .. SimpleModeLabel(Frames and Frames.GetGroupFrameVisibilityMode and Frames.GetGroupFrameVisibilityMode() or "show"))
    SetButtonText("cpProgress", "CP PROGRESS BAR: " .. SimpleModeLabel(Frames and Frames.GetChampionProgressVisibilityMode and Frames.GetChampionProgressVisibilityMode() or "show"))
    SetButtonText("npcNames", "NPC NAMES: " .. ((f and f.vanillaNpcNamesHidden == true) and "OFF" or "ON"))
    SetButtonText("overheadPlayerInfo", "OVERHEAD PLAYER INFO: " .. BoolText(Combat and Combat.IsOverheadPlayerInfoEnabled and Combat.IsOverheadPlayerInfoEnabled()))
    SetButtonText("esoCompass", "ESO COMPASS: " .. VisibilityText("compass"))
    SetButtonText("questTracker", "QUEST TRACKER: " .. VisibilityText("quests"))
    SetButtonText("queueStatus", "QUEUE STATUS: " .. VisibilityText("queue"))
    SetButtonText("crosshair", "CROSSHAIR: " .. VisibilityText("crosshair"))
    local chatMode = Frames and Frames.GetChatVisibilityMode and Frames.GetChatVisibilityMode() or "show"
    SetButtonText("chatVisibility", "CHAT: " .. (chatMode == "show" and "NORMAL" or (chatMode == "hide" and "AUTO HIDE" or SimpleModeLabel(chatMode))))
    SetButtonText("mountMeter", "MOUNT STAMINA: " .. BoolText(not (f and f.hideMountStaminaBar == true)))
    SetButtonText("werewolfMeter", "WEREWOLF METER: " .. BoolText(not (f and f.hideWerewolfResourceBar == true)))
    SetButtonText("pvpKD", "PVP K/D COUNTER: " .. BoolText(c and c.showPvpKillCounter ~= false))
    SetButtonText("stats", "DAMAGE + RESISTANCE: " .. SimpleModeLabel(GetStatMode()))
    SetButtonText("shield", "SHIELD: " .. SimpleModeLabel(GetShieldMode()))
    local debuffMode = GetDebuffMode()
    local debuffText = debuffMode == "self" and "ON ME" or debuffMode == "target" and "TARGET" or SimpleModeLabel(debuffMode)
    SetButtonText("debuffs", "DEBUFFS: " .. debuffText)
    SetButtonText("cc", "CC IMMUNITY: " .. BoolText(c and c.showCcImmunityTracker ~= false))
    SetButtonText("feetCompass", "FEET COMPASS: " .. SimpleModeLabel(GetHelperMode("feet")))
    SetButtonText("crownArrow", "CROWN ARROW: " .. SimpleModeLabel(GetHelperMode("crown")))
    SetButtonText("banditsMiniMap", "BANDITS MINIMAP: " .. BanditsMiniMapStateText())
    SetButtonText("graphicsPveApply", "APPLY PVE GRAPHICS")
    SetButtonText("graphicsPvpApply", "APPLY PVP GRAPHICS")
    local burstMode = GetWarningMode("burst")
    local executeMode = GetWarningMode("execute")
    SetButtonText("burst", "BURST WARNING: " .. (burstMode == "pvp" and "PVP ONLY" or SimpleModeLabel(burstMode)))
    SetButtonText("execute", "EXECUTE WARNING: " .. (executeMode == "pvp" and "PVP ONLY" or SimpleModeLabel(executeMode)))
    SetButtonText("corrosiveAlert", "CORROSIVE ARMOR ALERT: " .. BoolText(c and c.showEnemyCorrosiveAlert ~= false))
    SetButtonText("onslaughtAlert", "ONSLAUGHT ALERT: " .. BoolText(c and c.showEnemyOnslaughtAlert ~= false))
    SetButtonText("food", "NO FOOD WARNING: " .. BoolText(c and c.showNoFoodWarning ~= false))
    SetButtonText("resolve", "MAJOR RESOLVE WARNING: " .. BoolText(c and c.showNoMajorResolveWarning ~= false))
    SetButtonText("breach", "MAJOR BREACH DOT: " .. BoolText(c and c.majorBreachTracker ~= false))
    if Q.previewEnabled then Q.ApplyActualPreviewVisibility() end
end

local function NewButton(parent, key, text, yOffset, callback)
    local button = WINDOW_MANAGER:CreateControlFromVirtual("UltiviteQuickMenu" .. key, parent, "ZO_DefaultButton")
    button:SetDimensions(PANEL_WIDTH - 24, ROW_HEIGHT)
    button:SetAnchor(TOP, parent, TOP, 0, yOffset)
    button:SetText(text)
    if button.SetFont then button:SetFont("ZoFontGameBold") end

    button:SetHandler("OnMouseEnter", function()
        Q.pointerInside = true
        Q.HoldForInteraction(1200)
        if Q.previewEnabled == true and PREVIEWABLE_KEYS[key] == true then Q.SelectPreview(key) end
    end)
    button:SetHandler("OnMouseExit", function()
        Q.pointerInside = false
        -- Give ESO a short grace period while moving directly between adjacent
        -- Quick Menu rows so a one-frame gap cannot close the whole panel.
        Q.HoldForInteraction(500)
    end)

    -- Mouse-down only protects the menu from the temporary chat-focus loss that
    -- happens when a UI control receives the click. The setting itself is not
    -- changed until mouse-up, after ESO has received a complete UI click.
    button:SetHandler("OnMouseDown", function(self, mouseButton)
        if mouseButton ~= MOUSE_BUTTON_INDEX_LEFT then return end
        local wasChatOpen = Q.openedFromSettings ~= true and Q.IsChatOpen()
        Q.actionGeneration = (Q.actionGeneration or 0) + 1
        Q.actionInProgress = true
        Q.actionButtonKey = key
        Q.lastActionFailure = nil
        Q.HoldForInteraction(700)
        Q.pendingAction = {
            key = key,
            generation = Q.actionGeneration,
            wasChatOpen = wasChatOpen,
            draftText = wasChatOpen and GetChatDraftText() or "",
            beforeText = self.GetText and tostring(self:GetText() or "") or "",
        }
    end)

    button:SetHandler("OnMouseUp", function(self, mouseButton)
        if mouseButton ~= MOUSE_BUTTON_INDEX_LEFT then return end
        local pending = Q.pendingAction
        if not pending or pending.key ~= key then return end
        Q.pendingAction = nil
        local actionGen = pending.generation
        if actionGen ~= (Q.actionGeneration or 0) then return end

        local ok, resultOrError = pcall(callback)
        if not ok then
            Q.lastActionFailure = tostring(resultOrError)
            if d then d("[Ultivite] Quick Menu callback error [" .. tostring(key) .. "]: " .. tostring(resultOrError)) end
        elseif resultOrError == false then
            Q.lastActionFailure = "backend rejected requested state"
            if Combat and Combat.IsDiagnosticLoggingEnabled and Combat.IsDiagnosticLoggingEnabled() and d then
                d("[Ultivite] Quick Menu action unavailable [" .. tostring(key) .. "]")
            end
        end

        if PREVIEWABLE_KEYS[key] == true then Q.SelectPreview(key) end
        Q.Refresh()

        if ok and resultOrError ~= false and key ~= "settings" and key ~= "graphicsPveApply" and key ~= "graphicsPvpApply" then
            zo_callLater(function()
                if actionGen ~= (Q.actionGeneration or 0) then return end
                Q.Refresh()
                local afterText = self.GetText and tostring(self:GetText() or "") or ""
                if pending.beforeText == afterText then
                    Q.lastActionFailure = "state did not change"
                    if Combat and Combat.IsDiagnosticLoggingEnabled and Combat.IsDiagnosticLoggingEnabled() and d then
                        d("[Ultivite] Quick Menu no-op [" .. tostring(key) .. "]: " .. tostring(pending.beforeText))
                    end
                end
            end, 100)
        end

        if key == "settings" then
            Q.actionInProgress = false
            Q.actionButtonKey = nil
            return
        end

        if Q.openedFromSettings == true then
            Q.actionInProgress = false
            Q.actionButtonKey = nil
            Q.RefreshChatVisibility(true)
        elseif pending.wasChatOpen and Q.manualDismissed ~= true then
            Q.ReopenChatAfterInteraction(pending.draftText, actionGen)
        else
            Q.actionInProgress = false
            Q.actionButtonKey = nil
            Q.RefreshChatVisibility(true)
        end
    end)

    -- All behavior is owned by the explicit down/up pair above. Keeping
    -- OnClicked empty avoids a second callback from the virtual button template.
    button:SetHandler("OnClicked", function() end)
    Q.buttons[key] = button
    return button
end

local function NewSection(parent, text, yOffset, index)
    local backdrop = WINDOW_MANAGER:CreateControl("UltiviteQuickMenuSectionBackdrop" .. tostring(index), parent, CT_BACKDROP)
    backdrop:SetDimensions(PANEL_WIDTH - 24, SECTION_HEIGHT)
    backdrop:SetAnchor(TOP, parent, TOP, 0, yOffset)
    backdrop:SetCenterColor(0.035, 0.055, 0.070, 0.92)
    backdrop:SetEdgeColor(0.15, 0.35, 0.46, 0.65)
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 1, 0)
    backdrop:SetMouseEnabled(false)

    local label = WINDOW_MANAGER:CreateControl("UltiviteQuickMenuSectionLabel" .. tostring(index), backdrop, CT_LABEL)
    label:SetAnchorFill(backdrop)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetFont("ZoFontGameSmall")
    label:SetColor(0.60, 0.84, 0.95, 1.00)
    label:SetText(string.upper(text))
    label:SetMouseEnabled(false)
    return backdrop
end


function Q.Create()
    if Q.initialized or not WINDOW_MANAGER or not GuiRoot then return end
    Q.initialized = true

    -- Rows are intentionally grouped by what the player is trying to change,
    -- not by the internal module that owns the setting.
    local rows = {
        { type = "button", key = "preview", text = "PREVIEW", callback = Q.TogglePreview },
        { type = "button", key = "resize", text = "RESIZE", callback = Q.ToggleResize },
        { type = "button", key = "settings", text = "FULL ULTIVITE SETTINGS", callback = function()
            if Q.openedFromSettings == true then
                Q.CloseSettingsSession()
                return true
            end
            Q.ManualClose()
            zo_callLater(function()
                if LibAddonMenu2 and U.panel and LibAddonMenu2.OpenToPanel then LibAddonMenu2:OpenToPanel(U.panel) end
            end, 0)
            return true
        end },

        { type = "section", text = "Combat Information" },
        { type = "button", key = "pvpKD", text = "PVP K/D COUNTER", callback = function() ToggleCombatBoolean("showPvpKillCounter", true, "UpdatePvpHud") end },
        { type = "button", key = "stats", text = "DAMAGE + RESISTANCE", callback = CycleStats },
        { type = "button", key = "shield", text = "SHIELD", callback = CycleShield },
        { type = "button", key = "debuffs", text = "DEBUFFS", callback = CycleDebuffs },
        { type = "button", key = "cc", text = "CC IMMUNITY", callback = function() ToggleCombatBoolean("showCcImmunityTracker", true, "ScanPlayerAuraHud") end },

        { type = "section", text = "Navigation" },
        { type = "button", key = "feetCompass", text = "FEET COMPASS", callback = CycleFeetCompass },
        { type = "button", key = "crownArrow", text = "CROWN ARROW", callback = CycleCrownArrow },
        { type = "button", key = "banditsMiniMap", text = "BANDITS MINIMAP", callback = ToggleBanditsMiniMap },

        { type = "section", text = "Warnings" },
        { type = "button", key = "corrosiveAlert", text = "CORROSIVE ARMOR ALERT", callback = function()
            if EnemyAlerts and EnemyAlerts.SetCorrosiveEnabled then return EnemyAlerts.SetCorrosiveEnabled(not EnemyAlerts.GetCorrosiveEnabled()) end
            return false
        end },
        { type = "button", key = "onslaughtAlert", text = "ONSLAUGHT ALERT", callback = function()
            if EnemyAlerts and EnemyAlerts.SetOnslaughtEnabled then return EnemyAlerts.SetOnslaughtEnabled(not EnemyAlerts.GetOnslaughtEnabled()) end
            return false
        end },
        { type = "button", key = "burst", text = "BURST WARNING", callback = function() CycleWarning("burst") end },
        { type = "button", key = "execute", text = "EXECUTE WARNING", callback = function() CycleWarning("execute") end },
        { type = "button", key = "food", text = "NO FOOD WARNING", callback = function() ToggleCombatBoolean("showNoFoodWarning", true, "UpdateFoodWarning") end },
        { type = "button", key = "resolve", text = "MAJOR RESOLVE WARNING", callback = function() ToggleCombatBoolean("showNoMajorResolveWarning", true, "UpdateMajorResolveWarning") end },
        { type = "button", key = "breach", text = "MAJOR BREACH DOT", callback = ToggleMajorBreach },

        { type = "section", text = "World UI" },
        { type = "button", key = "groupFrame", text = "GROUP FRAME", callback = CycleGroupFrame },
        { type = "button", key = "cpProgress", text = "CP PROGRESS BAR", callback = CycleCpProgress },
        { type = "button", key = "npcNames", text = "NPC NAMES", callback = ToggleNpcNames },
        { type = "button", key = "overheadPlayerInfo", text = "OVERHEAD PLAYER INFO", callback = ToggleOverheadPlayerInfo },
        { type = "button", key = "esoCompass", text = "ESO COMPASS", callback = function() CycleVisibility("compass", STANDARD_VISIBILITY_CYCLE) end },
        { type = "button", key = "questTracker", text = "QUEST TRACKER", callback = function() CycleVisibility("quests", STANDARD_VISIBILITY_CYCLE) end },
        { type = "button", key = "queueStatus", text = "QUEUE STATUS", callback = function() CycleVisibility("queue", STANDARD_VISIBILITY_CYCLE) end },
        { type = "button", key = "crosshair", text = "CROSSHAIR", callback = function() CycleVisibility("crosshair", CROSSHAIR_VISIBILITY_CYCLE) end },
        { type = "button", key = "chatVisibility", text = "CHAT", callback = CycleChatVisibility },
        { type = "button", key = "mountMeter", text = "MOUNT STAMINA", callback = ToggleMountMeter },
        { type = "button", key = "werewolfMeter", text = "WEREWOLF METER", callback = ToggleWerewolfMeter },

        { type = "section", text = "Graphics Profiles" },
        { type = "button", key = "graphicsPveApply", text = "APPLY PVE GRAPHICS", callback = ApplyPveGraphicsProfile },
        { type = "button", key = "graphicsPvpApply", text = "APPLY PVP GRAPHICS", callback = ApplyPvpGraphicsProfile },

        { type = "section", text = "Profiles & Core HUD" },
        { type = "button", key = "darkSouls", text = "DARK SOULS PROFILE", callback = Q.CycleDarkSoulsMode },
        { type = "button", key = "hudVisibility", text = "HUD VISIBILITY", callback = CycleHudVisibilityPreset },
        { type = "button", key = "enemyHealth", text = "ENEMY HEALTH BARS", callback = CycleEnemyHealth },
        { type = "button", key = "combatOnly", text = "COMBAT HUD", callback = ToggleCombatOnly },
        { type = "button", key = "actionBar", text = "ACTION BAR", callback = ToggleActionBar },
        { type = "button", key = "vanillaTargetFrames", text = "RESTORE VANILLA TARGET FRAMES", callback = ApplyVanillaTargetFrames },
    }

    local contentHeight = 0
    for _, row in ipairs(rows) do
        if row.type == "section" then
            contentHeight = contentHeight + SECTION_HEIGHT + SECTION_GAP
        else
            contentHeight = contentHeight + ROW_HEIGHT + ROW_GAP
        end
    end
    local panelHeight = HEADER_HEIGHT + contentHeight + 10

    local panel = WINDOW_MANAGER:CreateTopLevelWindow("UltiviteQuickMenuPanel")
    panel:SetDimensions(PANEL_WIDTH, panelHeight)
    panel:SetAnchor(RIGHT, GuiRoot, RIGHT, PANEL_RIGHT_OFFSET, PANEL_Y_OFFSET)
    panel:SetMouseEnabled(true)
    panel:SetMovable(false)
    panel:SetClampedToScreen(true)
    panel:SetHandler("OnMouseEnter", function()
        Q.pointerInside = true
        Q.HoldForInteraction(1200)
    end)
    panel:SetHandler("OnMouseExit", function()
        Q.pointerInside = false
        Q.HoldForInteraction(500)
    end)
    if panel.SetDrawTier then panel:SetDrawTier(DT_HIGH) end
    if panel.SetDrawLayer then panel:SetDrawLayer(DL_OVERLAY) end
    if panel.SetDrawLevel then panel:SetDrawLevel(5001) end
    panel:SetHidden(true)
    panel:SetMouseEnabled(false)

    local backdrop = WINDOW_MANAGER:CreateControl("UltiviteQuickMenuBackdrop", panel, CT_BACKDROP)
    backdrop:SetAnchorFill(panel)
    backdrop:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
    backdrop:SetCenterColor(0.015, 0.02, 0.025, 0.94)
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 3, 0)
    backdrop:SetEdgeColor(0.20, 0.62, 0.82, 0.92)
    backdrop:SetMouseEnabled(false)

    local title = WINDOW_MANAGER:CreateControl("UltiviteQuickMenuTitle", panel, CT_LABEL)
    title:SetDimensions(PANEL_WIDTH - 64, 24)
    title:SetAnchor(TOP, panel, TOP, 0, 8)
    title:SetFont("ZoFontWinH3")
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    title:SetColor(0.85, 0.95, 1.00, 1.00)
    title:SetText("ULTIVITE QUICK MENU")
    title:SetMouseEnabled(false)

    local closeButton = WINDOW_MANAGER:CreateControl("UltiviteQuickMenuCloseButton", panel, CT_BUTTON)
    closeButton:SetDimensions(28, 28)
    closeButton:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -7, 5)
    closeButton:SetFont("ZoFontGameBold")
    closeButton:SetText("X")
    if closeButton.SetNormalFontColor then closeButton:SetNormalFontColor(0.90, 0.94, 0.96, 1.00) end
    if closeButton.SetMouseOverFontColor then closeButton:SetMouseOverFontColor(1.00, 0.35, 0.30, 1.00) end
    closeButton:SetHandler("OnMouseDown", function(_, mouseButton)
        if mouseButton == MOUSE_BUTTON_INDEX_LEFT then Q.BeginManualClose() end
    end)
    closeButton:SetHandler("OnMouseUp", function(_, mouseButton)
        if mouseButton == MOUSE_BUTTON_INDEX_LEFT and Q.closePending == true then Q.ManualClose() end
    end)
    closeButton:SetHandler("OnClicked", function() end)
    Q.closeButton = closeButton

    local hint = WINDOW_MANAGER:CreateControl("UltiviteQuickMenuHint", panel, CT_LABEL)
    hint:SetDimensions(PANEL_WIDTH - 54, 18)
    hint:SetAnchor(TOP, panel, TOP, 0, 31)
    hint:SetFont("ZoFontGameSmall")
    hint:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    hint:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    hint:SetColor(0.68, 0.76, 0.82, 0.95)
    hint:SetText("Enter opens  |  X closes")
    hint:SetMouseEnabled(false)

    Q.panel = panel
    local y = HEADER_HEIGHT
    local sectionIndex = 0
    for _, row in ipairs(rows) do
        if row.type == "section" then
            sectionIndex = sectionIndex + 1
            NewSection(panel, row.text, y, sectionIndex)
            y = y + SECTION_HEIGHT + SECTION_GAP
        else
            NewButton(panel, row.key, row.text, y, row.callback)
            y = y + ROW_HEIGHT + ROW_GAP
        end
    end

    Q.InstallBanditsMiniMapBridge()
    Q.Refresh()
    Q.StartChatWatch()
end

local EVENT_NAMESPACE = "UltiviteQuickMenu"
EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, function()
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED)
    zo_callLater(function()
        Q.Create()
    end, 250)
end)
