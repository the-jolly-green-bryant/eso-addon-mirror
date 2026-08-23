local U = Ultivite
if not U then return end

local Frames = U.Frames
local Combat = U.Combat
local FAB = U.FancyActionBar
local EnemyAlerts = U.EnemyUltimateAlerts
local Immersive = U.Immersive
local Ownership = U.Ownership

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
Q.previewRestoreGeneration = Q.previewRestoreGeneration or 0
Q.previewRestorePending = false
Q.previewHudInteractionActive = false
Q.previewHudInteractionUntil = 0
Q.manualDismissed = false
Q.closePending = false
Q.chatHooksInstalled = false
Q.chatHookEntry = nil
Q.chatOpenHookEntry = nil
Q.chatCloseHookEntry = nil
Q.chatClosePreHookEntry = nil
Q.chatReopenGeneration = Q.chatReopenGeneration or 0
Q.actionInProgress = false
Q.actionGeneration = Q.actionGeneration or 0
Q.actionButtonKey = nil
Q.lastActionFailure = nil
Q.banditsMiniMapShown = Q.banditsMiniMapShown
Q.banditsMiniMapBridgeInstalled = Q.banditsMiniMapBridgeInstalled or false
Q.banditsMiniMapSettingContainer = nil
Q.banditsMiniMapSettingKey = nil
Q.votanMiniMapAddon = nil
Q.sectionControls = Q.sectionControls or {}
Q.rows = Q.rows or {}
Q.lastAppliedGraphicsProfile = Q.lastAppliedGraphicsProfile
Q.openedFromSettings = Q.openedFromSettings or false
Q.pendingAction = nil
Q.initializing = false
Q.createAttempt = Q.createAttempt or 0
Q.nextCreateRetryMs = Q.nextCreateRetryMs or 0

local function BoolText(value)
    return value and "ON" or "OFF"
end

local function GetProfileFrames()
    -- Setters update the live module table before profile snapshots.
    if Frames and Frames.saved then return Frames.saved end
    local profile = U.GetActiveProfile and U.GetActiveProfile() or nil
    return profile and profile.frames or nil
end

local function GetCombatSettings()
    -- Read the live combat table before profile snapshots.
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

local function IsTextEntryOpen()
    local entry = U.GetChatTextEntry and U.GetChatTextEntry() or nil
    if not entry or type(entry.IsOpen) ~= "function" then return false end
    local ok, isOpen = pcall(entry.IsOpen, entry)
    return ok and isOpen == true
end

function Q.CanShow()
    -- The settings shortcut may open the panel outside the HUD scene.
    if Q.openedFromSettings == true then return true end

    -- TextEntry can open before the HUD scene transition is reported.
    if IsTextEntryOpen() then return true end
    if SCENE_MANAGER and SCENE_MANAGER.IsShowing then
        return SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui")
    end
    return true
end

function Q.IsChatOpen()
    -- TextEntry state is independent of chat-container presentation.
    return IsTextEntryOpen()
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
    if Q.previewEnabled == true then return true end
    if Q.manualDismissed == true then return false end
    if Q.openedFromSettings == true then return true end
    if Q.actionInProgress == true then return true end
    if Q.pointerInside == true then return true end
    if GetNowMs() < (Q.interactionHoldUntil or 0) then return true end
    if Q.chatSessionActive == true then return true end
    return Q.IsChatOpen()
end

local function GetChatDraftText()
    local entry = U.GetChatTextEntry and U.GetChatTextEntry() or nil
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

local function CapturePreviewChatDraft()
    local runtime = Q.previewRuntime
    if not runtime or runtime.chatWasOpen ~= true then return end
    local draft = GetChatDraftText()
    if draft ~= "" or runtime.chatDraftText == "" then runtime.chatDraftText = draft end
end

local function EnsureChatKeyboardFocus()
    local entry = U.GetChatTextEntry and U.GetChatTextEntry() or nil
    if not entry or not IsTextEntryOpen() then return false end

    local edit = entry.editControl or rawget(_G, "ZO_ChatWindowTextEntryEditBox")
    if not edit or type(edit.TakeFocus) ~= "function" then return false end
    if type(edit.HasFocus) == "function" then
        local ok, focused = pcall(edit.HasFocus, edit)
        if ok and focused == true then return true end
    end

    return pcall(edit.TakeFocus, edit)
end

local function IsAnyMouseButtonDown()
    if type(IsMouseButtonDown) ~= "function" then return false end
    for _, button in ipairs({ MOUSE_BUTTON_INDEX_LEFT, MOUSE_BUTTON_INDEX_RIGHT }) do
        local ok, pressed = pcall(IsMouseButtonDown, button)
        if ok and pressed == true then return true end
    end
    return false
end

local function ScheduleChatKeyboardFocusRepair(generation)
    local focusGeneration = generation or (Q.chatReopenGeneration or 0)
    local attempt = 0
    local maxAttempts = 5

    local function tryFocus()
        if focusGeneration ~= (Q.chatReopenGeneration or 0)
            or Q.manualDismissed == true
            or Q.openedFromSettings == true
            or not Q.IsChatOpen() then
            return
        end

        -- Never take keyboard focus while a mouse drag is active. This keeps the
        -- stock chat resize grip fully owned by ESO while still repairing the
        -- missing edit-box focus introduced by 1.0.146.
        if IsAnyMouseButtonDown() then
            attempt = attempt + 1
            if attempt < maxAttempts then zo_callLater(tryFocus, CHAT_WATCH_MS) end
            return
        end

        if EnsureChatKeyboardFocus() then return end

        attempt = attempt + 1
        if attempt < maxAttempts then zo_callLater(tryFocus, CHAT_WATCH_MS) end
    end

    -- Let ESO finish the StartChatInput/Open path and let Ultivite finish its
    -- visibility refresh before performing the one-time focus repair.
    zo_callLater(tryFocus, 10)
end

local function MarkPreviewChatClose()
    CapturePreviewChatDraft()
    local runtime = Q.previewRuntime
    if not runtime then return end
    runtime.chatClosedForHudInteraction = Q.previewHudInteractionActive == true
        or GetNowMs() < (Q.previewHudInteractionUntil or 0)
        or IsAnyMouseButtonDown()
end

function Q.BeginPreviewHudInteraction()
    if Q.previewEnabled ~= true or not Q.previewRuntime then return false end
    Q.previewHudInteractionActive = true
    Q.previewHudInteractionUntil = GetNowMs() + 2000
    Q.HoldForInteraction(2000)
    return true
end

function Q.EndPreviewHudInteraction()
    if Q.previewHudInteractionActive ~= true then return false end
    Q.previewHudInteractionActive = false
    Q.previewHudInteractionUntil = GetNowMs() + 500
    -- Editing is now a persistent explicit session. Do not reopen chat while the
    -- user is dragging or resizing HUD controls. SAVE & LOCK is the only normal
    -- exit path and restores ordinary chat/menu behavior afterward.
    return true
end

function Q.SchedulePreviewChatRestore()
    local runtime = Q.previewRuntime
    if Q.previewEnabled ~= true or not runtime or runtime.chatWasOpen ~= true then return end
    if runtime.chatClosedForHudInteraction ~= true then return end
    if Q.openedFromSettings == true or Q.manualDismissed == true then return end
    if Q.previewRestorePending == true then return end

    Q.previewRestoreGeneration = (Q.previewRestoreGeneration or 0) + 1
    local generation = Q.previewRestoreGeneration
    Q.previewRestorePending = true

    local function restoreWhenReleased()
        if generation ~= (Q.previewRestoreGeneration or 0)
            or Q.previewEnabled ~= true
            or Q.previewRuntime ~= runtime
            or Q.openedFromSettings == true
            or Q.manualDismissed == true then
            Q.previewRestorePending = false
            return
        end

        if IsAnyMouseButtonDown() then
            zo_callLater(restoreWhenReleased, CHAT_WATCH_MS)
            return
        end

        Q.previewRestorePending = false
        if not Q.IsChatOpen() then
            local chatSystem = U.GetChatSystem and U.GetChatSystem() or nil
            local entry = chatSystem and chatSystem.textEntry or nil
            if chatSystem and type(chatSystem.StartTextEntry) == "function" then
                pcall(chatSystem.StartTextEntry, chatSystem, runtime.chatDraftText or "")
            elseif entry and type(entry.Open) == "function" then
                pcall(entry.Open, entry, runtime.chatDraftText or "")
            end
        end
        EnsureChatKeyboardFocus()
        runtime.chatClosedForHudInteraction = false
        if Frames and Frames.ApplyChatVisibilityMode then pcall(Frames.ApplyChatVisibilityMode) end
        Q.RefreshChatVisibility(true)
    end

    zo_callLater(restoreWhenReleased, 0)
end

function Q.ReopenChatAfterInteraction(draftText, actionGeneration)
    local reopenGeneration = Q.chatReopenGeneration or 0
    local actionGen = actionGeneration or Q.actionGeneration or 0

    local function restoreChat()
        if Q.manualDismissed == true
            or Q.openedFromSettings == true
            or reopenGeneration ~= (Q.chatReopenGeneration or 0)
            or actionGen ~= (Q.actionGeneration or 0) then
            return
        end

        local chatSystem = U.GetChatSystem and U.GetChatSystem() or nil
        local entry = chatSystem and chatSystem.textEntry or nil
        if not IsTextEntryOpen() then
            if chatSystem and type(chatSystem.StartTextEntry) == "function" then
                pcall(chatSystem.StartTextEntry, chatSystem, draftText or "")
            elseif entry and type(entry.Open) == "function" then
                pcall(entry.Open, entry, draftText or "")
            end
        end
        EnsureChatKeyboardFocus()

        if Frames and Frames.ApplyChatVisibilityMode then pcall(Frames.ApplyChatVisibilityMode) end

        Q.actionInProgress = false
        Q.actionButtonKey = nil
        Q.pendingAction = nil
        Q.RefreshChatVisibility(true)
    end

    zo_callLater(function()
        restoreChat()
        if actionGen == (Q.actionGeneration or 0)
            and Q.manualDismissed ~= true
            and not Q.IsChatOpen() then
            zo_callLater(restoreChat, CHAT_WATCH_MS)
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
        Q.BeginPreviewHudInteraction()
        if self.StartMoving then self:StartMoving() end
    end)
    control:SetHandler("OnMouseUp", function(self, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        if self.StopMovingOrResizing then self:StopMovingOrResizing() end
        if Q.previewEnabled == true and savePosition then savePosition(self) end
        Q.EndPreviewHudInteraction()
    end)
    control:SetHandler("OnMoveStop", function(self)
        if Q.previewEnabled == true and savePosition then savePosition(self) end
    end)
    control:SetHandler("OnMouseWheel", function(self, delta)
        if Q.previewEnabled ~= true or Q.resizeEnabled ~= true or delta == 0 then return end
        Q.BeginPreviewHudInteraction()
        if resizeStep then resizeStep(delta > 0 and 1 or -1) end
        Q.EndPreviewHudInteraction()
    end)
end

local function PersistFabPreviewChange()
    if U.PersistLiveSettingsToCurrentScope then
        pcall(U.PersistLiveSettingsToCurrentScope)
    end
    if FAB and FAB.RequestSave then FAB.RequestSave() end
    RequestSave()
end

local function FinishFabPreviewDrag(mover)
    if not mover or mover.ultivitePreviewDragActive ~= true then return end
    mover.ultivitePreviewDragActive = false

    if FAB and FAB.CommitMoverPosition then
        FAB.CommitMoverPosition()
    else
        local fab = rawget(_G, "FancyActionBar")
        if fab and type(fab.SaveMoverPosition) == "function" then
            pcall(fab.SaveMoverPosition)
        end
    end

    PersistFabPreviewChange()
    Q.EndPreviewHudInteraction()
end

function Q.InstallFabPreviewHandlers()
    local fab = rawget(_G, "FancyActionBar")
    local mover = rawget(_G, "FAB_Mover")
    if not fab or not mover or mover.ultivitePreviewHooksInstalled == true then return false end
    if type(ZO_PreHookHandler) ~= "function" or type(ZO_PostHookHandler) ~= "function" then return false end

    mover.ultivitePreviewHooksInstalled = true

    ZO_PreHookHandler(mover, "OnMouseDown", function(_, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT or Q.previewEnabled ~= true then return end
        mover.ultivitePreviewDragActive = Q.BeginPreviewHudInteraction() == true
    end)

    ZO_PostHookHandler(mover, "OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then FinishFabPreviewDrag(mover) end
    end)

    -- FAB saves its mover in OnMoveStop. This post-hook runs after that native
    -- handler and keeps Ultivite's active profile snapshot in step with FAB.
    ZO_PostHookHandler(mover, "OnMoveStop", function()
        FinishFabPreviewDrag(mover)
    end)

    ZO_PreHookHandler(mover, "OnMouseWheel", function(_, delta)
        if Q.previewEnabled ~= true or Q.resizeEnabled ~= true or delta == 0 then return end
        local sv = FAB and FAB.GetSettings and FAB.GetSettings() or nil
        if not sv or not Q.BeginPreviewHudInteraction() then return end

        local key = fab.style == 2 and "gp" or "kb"
        sv.abScaling = sv.abScaling or {}
        sv.abScaling[key] = sv.abScaling[key] or {}
        local scale = zo_clamp((tonumber(sv.abScaling[key].scale) or 100) + (delta > 0 and 2 or -2), 30, 250)
        sv.abScaling[key].enable = true
        sv.abScaling[key].scale = scale
        if type(fab.SetScale) == "function" then pcall(fab.SetScale) end
        if type(fab.ReanchorMover) == "function" then pcall(fab.ReanchorMover) end
        PersistFabPreviewChange()
        Q.EndPreviewHudInteraction()
    end)

    return true
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
                    Q.BeginPreviewHudInteraction()
                    Combat.sv.liveStatFontSize = zo_clamp((tonumber(Combat.sv.liveStatFontSize) or 28) + (delta > 0 and 1 or -1), 16, 42)
                    if Combat.ApplyLiveStatWidgetAppearance then Combat.ApplyLiveStatWidgetAppearance() end
                    SafeRequestSave()
                    Q.EndPreviewHudInteraction()
                end
                widget.root:SetHandler("OnMouseWheel", resizeLiveStat)
                -- The transparent drag surface sits above the root while this
                -- item is being previewed. Give it the same resize handler so
                -- PREVIEW + RESIZE works reliably without leaving a live hitbox.
                if widget.dragger then widget.dragger:SetHandler("OnMouseWheel", resizeLiveStat) end
            end
        end
    end

    -- K/D movement and mouse-wheel resizing are only interactive in preview.
    -- Outside preview the transparent grab surface is disabled.
    if Combat and Combat.pvpHudRoot and not Combat.pvpHudRoot.ultiviteQuickResizeHandler then
        Combat.pvpHudRoot.ultiviteQuickResizeHandler = true
        local function resizePvpKd(_, delta)
            if Q.previewEnabled ~= true or Q.resizeEnabled ~= true or delta == 0 or not Combat.sv then return end
            Q.BeginPreviewHudInteraction()
            Combat.sv.pvpHudFontSize = zo_clamp((tonumber(Combat.sv.pvpHudFontSize) or 20) + (delta > 0 and 1 or -1), 14, 36)
            if Combat.ApplyPvpHudAppearance then Combat.ApplyPvpHudAppearance() end
            SafeRequestSave()
            Q.EndPreviewHudInteraction()
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
            Q.BeginPreviewHudInteraction()
            local size = zo_clamp((tonumber(Combat.sv.majorBreachFontSize) or 16) + (delta > 0 and 1 or -1), 10, 34)
            Combat.sv.majorBreachFontSize = size
            if Combat.majorBreachLabel then Combat.majorBreachLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", size)) end
            SafeRequestSave()
            Q.EndPreviewHudInteraction()
        end)
    end

    Q.InstallFabPreviewHandlers()
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
        if bar and bar.SetHidden and not (Ownership and Ownership.IsControlOwned and Ownership.IsControlOwned(bar)) then
            bar:SetHidden(false)
        end
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
    runtime.chatWasOpen = Q.openedFromSettings ~= true and Q.IsChatOpen()
    runtime.chatDraftText = runtime.chatWasOpen and GetChatDraftText() or ""
    runtime.chatClosedForHudInteraction = false
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
    Q.previewRestoreGeneration = (Q.previewRestoreGeneration or 0) + 1
    Q.previewRestorePending = false
    Q.previewHudInteractionActive = false
    Q.previewHudInteractionUntil = 0

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
    local chatSystem = U.GetChatSystem and U.GetChatSystem() or nil
    local entry = chatSystem and chatSystem.textEntry or nil
    if not entry then return end
    local isOpen = false
    if type(entry.IsOpen) == "function" then
        local ok, value = pcall(entry.IsOpen, entry)
        isOpen = ok and value == true
    end
    if isOpen then
        -- Use ESO's system close path before the TextEntry fallback.
        if chatSystem and type(chatSystem.CloseTextEntry) == "function" then
            pcall(chatSystem.CloseTextEntry, chatSystem)
        end
        if IsTextEntryOpen() and type(entry.Close) == "function" then
            pcall(entry.Close, entry)
        end
        if IsTextEntryOpen() and d then
            d("[Ultivite] ESO chat remained open after the Quick Menu close request; press Escape to close stock chat.")
        end
    end
end

local function ReleaseQuickMenuMouseInput(enabled)
    local allowMouse = enabled == true
    if Q.panel and Q.panel.SetMouseEnabled then Q.panel:SetMouseEnabled(allowMouse) end
    if Q.closeButton and Q.closeButton.SetMouseEnabled then Q.closeButton:SetMouseEnabled(allowMouse) end
    for _, button in pairs(Q.buttons or {}) do
        if button and button.SetMouseEnabled then button:SetMouseEnabled(allowMouse) end
    end
    for _, entry in pairs(Q.sectionControls or {}) do
        local control = entry and entry.control or nil
        if control and control.SetMouseEnabled then control:SetMouseEnabled(allowMouse) end
    end
end


function Q.BeginManualClose()
    Q.chatReopenGeneration = (Q.chatReopenGeneration or 0) + 1
    Q.actionGeneration = (Q.actionGeneration or 0) + 1
    Q.actionInProgress = false
    Q.actionButtonKey = nil
    Q.pendingAction = nil
    Q.pendingSectionAction = nil
    Q.closePending = true
end

function Q.ManualClose()
    if Q.previewEnabled == true then
        Q.closePending = false
        Q.manualDismissed = false
        Q.SafeRefresh()
        return false
    end
    if Q.closePending ~= true then return false end
    Q.closePending = false

    if Q.openedFromSettings == true then
        Q.openedFromSettings = false
        Q.manualDismissed = false
        Q.HideNow()
        return true
    end

    Q.manualDismissed = true
    Q.chatSessionActive = false
    Q.HideNow()
    CloseChatEntryNow()
    return true
end

function Q.OpenFromSettings()
    if not Q.initialized then Q.Create() end
    Q.chatReopenGeneration = (Q.chatReopenGeneration or 0) + 1
    Q.actionGeneration = (Q.actionGeneration or 0) + 1
    Q.actionInProgress = false
    Q.actionButtonKey = nil
    Q.pendingAction = nil
    Q.pendingSectionAction = nil
    Q.closePending = false
    Q.manualDismissed = false
    Q.openedFromSettings = true
    Q.Show()
end

function Q.CloseSettingsSession()
    if Q.openedFromSettings ~= true then return end
    if Q.previewEnabled == true then
        -- Do not tear down a move/resize session just because the LAM panel was
        -- closed. The editor remains active until SAVE & LOCK is pressed.
        Q.openedFromSettings = false
        Q.manualDismissed = false
        Q.Show()
        return false
    end
    Q.openedFromSettings = false
    Q.manualDismissed = false
    Q.HideNow()
    return true
end

function Q.HideNow(force)
    if Q.previewEnabled == true and force ~= true then
        Q.manualDismissed = false
        ReleaseQuickMenuMouseInput(true)
        if Q.panel then Q.panel:SetHidden(false) end
        return false
    end
    Q.pointerInside = false
    if Q.panel then Q.panel:SetHidden(true) end
    ReleaseQuickMenuMouseInput(false)
    if force == true and (Q.previewEnabled == true or Q.previewRuntime) then
        Q.previewEnabled = false
        Q.DeactivatePreviewRuntime()
    end
    return true
end

function Q.SyncPreviewVisibility()
    -- Preview edits only the real HUD controls in their real positions.
end

function Q.Show()
    if not Q.CanShow() then
        -- Scene transitions may temporarily hide the editor, but they must never
        -- end the edit session. Returning to gameplay restores the same session.
        if Q.panel then Q.panel:SetHidden(true) end
        ReleaseQuickMenuMouseInput(false)
        return
    end
    Q.SafeRefresh()
    ReleaseQuickMenuMouseInput(true)
    if Q.panel then Q.panel:SetHidden(false) end
end

function Q.RefreshChatVisibility(force)
    if Q.closePending == true and Q.previewEnabled ~= true then return end

    if Q.previewEnabled == true then
        Q.manualDismissed = false
        Q.closePending = false
        if Q.CanShow() then
            Q.SafeRefresh()
            ReleaseQuickMenuMouseInput(true)
            if Q.panel then Q.panel:SetHidden(false) end
            Q.ApplyActualPreviewVisibility()
        else
            if Q.panel then Q.panel:SetHidden(true) end
            ReleaseQuickMenuMouseInput(false)
        end
        return
    end

    if Q.openedFromSettings == true then
        if Q.panel and Q.panel:IsHidden() then Q.Show() end
        return
    end

    local liveEntryOpen = Q.IsChatOpen()
    Q.chatSessionActive = liveEntryOpen
    local isOpen = liveEntryOpen
    local stateChanged = Q.lastChatOpen ~= isOpen
    Q.lastChatOpen = isOpen

    if isOpen and Q.previewRuntime then
        Q.previewRuntime.chatWasOpen = true
        Q.previewRuntime.chatDraftText = GetChatDraftText()
        Q.previewRuntime.chatClosedForHudInteraction = false
    end

    if not isOpen
        and Q.previewEnabled == true
        and Q.previewRuntime
        and Q.previewRuntime.chatClosedForHudInteraction == true
        and Q.manualDismissed ~= true then
        ReleaseQuickMenuMouseInput(true)
        if Q.panel then Q.panel:SetHidden(false) end
        Q.ApplyActualPreviewVisibility()
        Q.SchedulePreviewChatRestore()
        return
    end

    local heldForAction = Q.actionInProgress == true or Q.pointerInside == true or GetNowMs() < (Q.interactionHoldUntil or 0)
    if not isOpen and heldForAction and Q.manualDismissed ~= true then
        if Q.CanShow() and Q.panel and Q.panel:IsHidden() then ReleaseQuickMenuMouseInput(true); Q.panel:SetHidden(false) end
        return
    end

    if not isOpen then
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
            Q.SafeRefresh()
            ReleaseQuickMenuMouseInput(true)
            if Q.panel then Q.panel:SetHidden(false) end
        end
        -- Fallback for late-created or replaced chat entries. Repair only on the
        -- closed -> open edge, never from the 50 ms watcher while chat remains open.
        if stateChanged and isOpen and Q.actionInProgress ~= true then
            ScheduleChatKeyboardFocusRepair(Q.chatReopenGeneration or 0)
        end
        if Q.previewEnabled and (force or stateChanged) then Q.ApplyActualPreviewVisibility() end
    else
        Q.HideNow()
    end
end

function Q.InstallChatHooks()
    if not ZO_PostHook then return false end

    local entry = U.GetChatTextEntry and U.GetChatTextEntry() or nil
    if not entry then
        -- The chat watcher retries after late TextEntry creation.
        Q.chatHooksInstalled = false
        return false
    end
    if Q.chatHookEntry == entry then return true end

    local function refreshSoon()
        zo_callLater(function()
            if Immersive and Immersive.RefreshChatVisibility then pcall(Immersive.RefreshChatVisibility) end
            Q.RefreshChatVisibility(true)
        end, 0)
    end

    if type(entry.Open) == "function" and Q.chatOpenHookEntry ~= entry then
        local ok = pcall(ZO_PostHook, entry, "Open", function()
            Q.chatReopenGeneration = (Q.chatReopenGeneration or 0) + 1
            Q.openedFromSettings = false
            Q.manualDismissed = false
            Q.closePending = false
            Q.chatSessionActive = true
            if Immersive and Immersive.RefreshChatVisibility then pcall(Immersive.RefreshChatVisibility) end
            if Frames and Frames.ApplyChatVisibilityMode then pcall(Frames.ApplyChatVisibilityMode) end
            -- ESO normally takes focus inside TextEntry:Open. Ultivite's Quick
            -- Menu visibility transition can steal it immediately afterward, so
            -- repair once after Open. The repair never runs during mouse dragging
            -- or resizing and is not part of the 50 ms chat watcher.
            ScheduleChatKeyboardFocusRepair(Q.chatReopenGeneration)
            refreshSoon()
        end)
        if ok then Q.chatOpenHookEntry = entry end
    end
    if type(entry.Close) == "function" and type(ZO_PreHook) == "function" and Q.chatClosePreHookEntry ~= entry then
        local ok = pcall(ZO_PreHook, entry, "Close", function()
            MarkPreviewChatClose()
        end)
        if ok then Q.chatClosePreHookEntry = entry end
    end
    if type(entry.Close) == "function" and Q.chatCloseHookEntry ~= entry then
        local ok = pcall(ZO_PostHook, entry, "Close", function()
            MarkPreviewChatClose()
            Q.chatSessionActive = false
            refreshSoon()
        end)
        if ok then Q.chatCloseHookEntry = entry end
    end

    local fullyInstalled = Q.chatOpenHookEntry == entry and Q.chatCloseHookEntry == entry
    Q.chatHooksInstalled = fullyInstalled
    Q.chatHookEntry = fullyInstalled and entry or nil
    return fullyInstalled
end

function Q.StartChatWatch()
    Q.InstallChatHooks()
    if Q.chatWatchRegistered then return end
    Q.chatWatchRegistered = true
    EVENT_MANAGER:RegisterForUpdate("UltiviteQuickMenuChatWatch", CHAT_WATCH_MS, function()
        -- Bind late-created or replaced chat entries once per object.
        Q.InstallChatHooks()
        if not Q.initialized and not Q.initializing and GetNowMs() >= (Q.nextCreateRetryMs or 0) then
            Q.Create()
        end
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
        Q.SafeRefresh()
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
        Q.SafeRefresh()
    end)
    CALLBACK_MANAGER:RegisterCallback("BUI_Ready", function()
        Q.banditsMiniMapSettingContainer = nil
        Q.banditsMiniMapSettingKey = nil
        ProbeBanditsMiniMapState()
        Q.SafeRefresh()
    end)

    ProbeBanditsMiniMapState()
end

-- Votan's Minimap bridge. Current Votan builds expose the addon as
-- VOTANS_MINIMAP and keep the per-character master show state in
-- addon.player.showMap. The addon's own keybind calls addon:ToggleShowMap(),
-- so Ultivite uses that native path rather than hiding WORLD_MAP controls itself.
-- This keeps Circular Votan's Mini Map and all normal Votan map state in sync.
local function FindVotanMiniMapAddon()
    if type(Q.votanMiniMapAddon) == "table" and type(Q.votanMiniMapAddon.ToggleShowMap) == "function" then
        return Q.votanMiniMapAddon
    end

    -- API 101050 can expose private secure functions through the global table.
    -- Iterating _G from insecure addon code can therefore taint the call stack
    -- merely by reading one of those entries. Only use Votan's documented global.
    local direct = rawget(_G, "VOTANS_MINIMAP")
    if type(direct) == "table" and type(direct.ToggleShowMap) == "function" then
        Q.votanMiniMapAddon = direct
        return direct
    end
    return nil
end

local function ProbeVotanMiniMapState()
    local addon = FindVotanMiniMapAddon()
    if not addon then return nil end
    if type(addon.player) == "table" and type(addon.player.showMap) == "boolean" then
        return addon.player.showMap
    end
    return nil
end

local function VotanMiniMapStateText()
    local addon = FindVotanMiniMapAddon()
    if not addon then return "UNAVAILABLE" end
    local state = ProbeVotanMiniMapState()
    if state == nil then return "UNKNOWN" end
    return state and "ON" or "OFF"
end

local function SetVotanMiniMapEnabled(enabled)
    enabled = enabled == true
    local addon = FindVotanMiniMapAddon()
    if not addon then
        if d then d("[Ultivite] Votan's Minimap unavailable: VotansMiniMap is not loaded.") end
        return false
    end

    local current = ProbeVotanMiniMapState()
    if current == enabled then return true end
    if type(addon.ToggleShowMap) ~= "function" then return false end

    local ok, err = pcall(addon.ToggleShowMap, addon)
    if not ok then
        if d then d("[Ultivite] Votan's Minimap toggle failed: " .. tostring(err)) end
        return false
    end

    -- Votan updates the world-map mode asynchronously around scene changes.
    -- Verify the SavedVariable-backed state on the next frame without touching
    -- the map control directly.
    if zo_callLater then
        zo_callLater(function() Q.SafeRefresh() end, 0)
        zo_callLater(function() Q.SafeRefresh() end, 120)
    end
    return true
end

local function ToggleVotanMiniMap()
    local current = ProbeVotanMiniMapState()
    if current == nil then
        -- If Votan is loaded but its character state has not published yet, do
        -- not guess which direction a blind toggle would move.
        if d then d("[Ultivite] Votan's Minimap state is not ready yet.") end
        return false
    end
    return SetVotanMiniMapEnabled(not current)
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

    local saveOption = SETTINGS_SET_OPTION_SAVE_TO_PERSISTED_DATA
    if saveOption ~= nil then
        return pcall(SetSetting, SETTING_TYPE_GRAPHICS, settingId, value, saveOption) == true
    end
    return pcall(SetSetting, SETTING_TYPE_GRAPHICS, settingId, value) == true
end

-- Graphics profile manager ---------------------------------------------------
-- Profiles are account-wide because they describe client video settings, not
-- character combat layouts. Built-in profiles remain editable and can always
-- be restored to their factory values. Custom profiles use stable IDs so a
-- rename never breaks PvE/PvP automatic assignments.
local GRAPHICS_BUILTIN_PVE = "builtin_pve"
local GRAPHICS_BUILTIN_PVP = "builtin_pvp"
local GRAPHICS_BUILTIN_LOW = "builtin_low"

local function GraphicsValue(value)
    if value == nil then return nil end
    return tostring(value)
end

local function GetGraphicsAccountState()
    if not U.accountSV then return nil end
    U.accountSV.graphics = U.accountSV.graphics or {}
    return U.accountSV.graphics
end

local function GetGodRaysSettingId()
    return _G and _G["GRAPHICS_SETTING_GOD_RAYS"] or nil
end

local function GetAmbientOcclusionSettingId()
    return _G and _G["GRAPHICS_SETTING_AMBIENT_OCCLUSION_TYPE"] or nil
end

local function ReadCVarSafe(name)
    if type(GetCVar) ~= "function" then return nil end
    local ok, value = pcall(GetCVar, name)
    if not ok or value == nil then return nil end
    return tostring(value)
end

-- ESO does not always round-trip boolean graphics values with the same textual
-- representation that was passed to SetSetting/SetCVar. Depending on the
-- setting and client path, false/true can come back as 0/1. Treat those forms
-- as equivalent so a successfully-applied profile is not reported as failed.
local function GraphicsValuesEquivalent(actual, expected)
    if actual == nil or expected == nil then return false end
    actual = tostring(actual):lower()
    expected = tostring(expected):lower()
    if actual == expected then return true end

    local booleanValue = {
        ["true"] = true, ["1"] = true, ["on"] = true,
        ["false"] = false, ["0"] = false, ["off"] = false,
    }
    local actualBool = booleanValue[actual]
    local expectedBool = booleanValue[expected]
    if actualBool ~= nil and expectedBool ~= nil then
        return actualBool == expectedBool
    end

    local actualNumber = tonumber(actual)
    local expectedNumber = tonumber(expected)
    if actualNumber ~= nil and expectedNumber ~= nil then
        return actualNumber == expectedNumber
    end
    return false
end

local function SetCVarSafe(name, value)
    if type(SetCVar) ~= "function" or value == nil then return false end
    value = tostring(value)
    if GraphicsValuesEquivalent(ReadCVarSafe(name), value) then return true end
    local ok = pcall(SetCVar, name, value)
    return ok == true
end

local function BuildFactoryGraphicsSettings(isPve)
    return {
        shadows = GraphicsValue(isPve and SHADOWS_CHOICE_ULTRA or SHADOWS_CHOICE_OFF),
        waterReflections = GraphicsValue(isPve and SCREENSPACE_WATER_REFLECTION_QUALITY_ULTRA or SCREENSPACE_WATER_REFLECTION_QUALITY_OFF),
        distortion = isPve and "true" or "false",
        bloom = isPve and "true" or "false",
        godRays = isPve and "true" or "false",
        clutter = GraphicsValue(isPve and CLUTTER_QUALITY_ULTRA or CLUTTER_QUALITY_OFF),
        ambientOcclusion = GraphicsValue(isPve and AMBIENT_OCCLUSION_TYPE_SSGI or AMBIENT_OCCLUSION_TYPE_NONE),
    }
end

-- All Low uses ESO's own public Low graphics preset. Never enumerate _G here:
-- API 101050 includes private secure functions in the global table and touching
-- them from insecure addon code can taint the stack. The names below come from
-- the stock API 101050 video options panel and are looked up individually with
-- rawget. The preset selector itself is intentionally excluded from the restore
-- snapshot because restoring it would re-run another preset over the exact values
-- we are restoring.
local ALL_LOW_GRAPHICS_SETTING_NAMES = {
    "GRAPHICS_SETTING_FULLSCREEN",
    "GRAPHICS_SETTING_ACTIVE_DISPLAY",
    "GRAPHICS_SETTING_RESOLUTION",
    "GRAPHICS_SETTING_VSYNC",
    "GRAPHICS_SETTING_RENDERTHREAD",
    "GRAPHICS_SETTING_ANTIALIASING_TYPE",
    "GRAPHICS_SETTING_USE_BACKGROUND_FPS_LIMIT",
    "GRAPHICS_SETTING_BACKGROUND_FPS_LIMIT",
    "GRAPHICS_SETTING_GAMMA_ADJUSTMENT",
    "GRAPHICS_SETTING_MIP_LOAD_SKIP_LEVELS",
    "GRAPHICS_SETTING_DLSS_MODE",
    "GRAPHICS_SETTING_FSR_MODE",
    "GRAPHICS_SETTING_SUB_SAMPLING",
    "GRAPHICS_SETTING_SHADOWS",
    "GRAPHICS_SETTING_SCREENSPACE_WATER_REFLECTION_QUALITY",
    "GRAPHICS_SETTING_PLANAR_WATER_REFLECTION_QUALITY",
    "GRAPHICS_SETTING_PFX_GLOBAL_MAXIMUM",
    "GRAPHICS_SETTING_PFX_SUPPRESS_DISTANCE",
    "GRAPHICS_SETTING_VIEW_DISTANCE",
    "GRAPHICS_SETTING_AMBIENT_OCCLUSION_TYPE",
    "GRAPHICS_SETTING_OCCLUSION_CULLING_ENABLED",
    "GRAPHICS_SETTING_CLUTTER_2D_QUALITY",
    "GRAPHICS_SETTING_DEPTH_OF_FIELD_MODE",
    "GRAPHICS_SETTING_CHARACTER_RESOLUTION",
    "GRAPHICS_SETTING_BLOOM",
    "GRAPHICS_SETTING_DISTORTION",
    "GRAPHICS_SETTING_GOD_RAYS",
    "GRAPHICS_SETTING_CONSOLE_ENHANCED_RENDER_QUALITY",
    "GRAPHICS_SETTING_GRAPHICS_MODE_PS5",
    "GRAPHICS_SETTING_GRAPHICS_MODE_XBSS",
    "GRAPHICS_SETTING_GRAPHICS_MODE_XBSX",
    "GRAPHICS_SETTING_CAP_CONSOLE_FRAMERATE_IN_MENUS",
    "GRAPHICS_SETTING_ENERGY_SUSTAINABILITY_SCREEN_DIM_AND_RESOLUTION",
    "GRAPHICS_SETTING_HDR_ENABLED",
    "GRAPHICS_SETTING_HDR_PEAK_BRIGHTNESS",
    "GRAPHICS_SETTING_HDR_SCENE_BRIGHTNESS",
    "GRAPHICS_SETTING_HDR_SCENE_CONTRAST",
    "GRAPHICS_SETTING_HDR_UI_BRIGHTNESS",
    "GRAPHICS_SETTING_HDR_UI_CONTRAST",
    "GRAPHICS_SETTING_HDR_MODE",
    "GRAPHICS_SETTING_SHOW_ADDITIONAL_ALLY_EFFECTS",
}

local function GetNamedGraphicsSettingId(name)
    if type(name) ~= "string" or type(_G) ~= "table" then return nil end
    local settingId = rawget(_G, name)
    return type(settingId) == "number" and settingId or nil
end

-- ESO's Low preset remains the authoritative baseline, but Ultivite also
-- enforces every quality setting for which the public API exposes an explicit
-- Low, Off or performance value. This prevents a partially-applied preset from
-- leaving expensive settings behind while still avoiding any global scanning.
local function BuildAllLowEnforcedTargets()
    local targets = {}
    local function add(settingId, value)
        if type(settingId) == "number" and value ~= nil then
            targets[#targets + 1] = { settingId = settingId, value = tostring(value) }
        end
    end

    add(GRAPHICS_SETTING_MIP_LOAD_SKIP_LEVELS, TEX_RES_CHOICE_LOW)
    add(GRAPHICS_SETTING_SUB_SAMPLING, SUB_SAMPLING_MODE_LOW)
    add(GRAPHICS_SETTING_ANTIALIASING_TYPE, ANTIALIASING_TYPE_NONE)
    add(GRAPHICS_SETTING_SHADOWS, SHADOWS_CHOICE_LOW)
    add(GRAPHICS_SETTING_SCREENSPACE_WATER_REFLECTION_QUALITY, SCREENSPACE_WATER_REFLECTION_QUALITY_LOW)
    add(GRAPHICS_SETTING_PLANAR_WATER_REFLECTION_QUALITY, PLANAR_WATER_REFLECTION_QUALITY_OFF)
    add(GRAPHICS_SETTING_PFX_GLOBAL_MAXIMUM, PARTICLE_DENSITY_LOW)
    add(GRAPHICS_SETTING_AMBIENT_OCCLUSION_TYPE, AMBIENT_OCCLUSION_TYPE_NONE)
    add(GRAPHICS_SETTING_CLUTTER_2D_QUALITY, CLUTTER_QUALITY_LOW)
    add(GRAPHICS_SETTING_DEPTH_OF_FIELD_MODE, DEPTH_OF_FIELD_MODE_OFF)
    add(GRAPHICS_SETTING_CHARACTER_RESOLUTION, CHARACTER_RESOLUTION_LOW)
    add(GRAPHICS_SETTING_BLOOM, "false")
    add(GRAPHICS_SETTING_DISTORTION, "false")
    add(GRAPHICS_SETTING_GOD_RAYS, "false")
    add(GRAPHICS_SETTING_OCCLUSION_CULLING_ENABLED, "true")
    add(GRAPHICS_SETTING_SHOW_ADDITIONAL_ALLY_EFFECTS, "false")

    return targets
end

local function ApplyAllLowEnforcedTargets()
    local ok = true
    local applied = {}
    for _, target in ipairs(BuildAllLowEnforcedTargets()) do
        local supported = true
        if type(DoesPlatformSupportGraphicSetting) == "function" then
            local supportOk, result = pcall(DoesPlatformSupportGraphicSetting, target.settingId)
            if supportOk and result == false then supported = false end
        end
        if supported then
            local targetOk = SetGraphicsSettingSafe(target.settingId, target.value)
            ok = targetOk and ok
            if targetOk then applied[#applied + 1] = target end
        end
    end
    return ok, applied
end

local function VerifyAllLowEnforcedTargets(appliedTargets)
    local ok = true
    for _, target in ipairs(appliedTargets or {}) do
        if not GraphicsValuesEquivalent(GetGraphicsSettingSafe(target.settingId), target.value) then
            ok = false
        end
    end
    return ok
end

local function CaptureAllGraphicsSettingValues()
    local snapshot = {}
    local seenIds = {}
    for _, name in ipairs(ALL_LOW_GRAPHICS_SETTING_NAMES) do
        local settingId = GetNamedGraphicsSettingId(name)
        if settingId ~= nil and not seenIds[settingId] then
            local value = GetGraphicsSettingSafe(settingId)
            if value ~= nil then
                snapshot[name] = value
                seenIds[settingId] = true
            end
        end
    end
    return snapshot
end

local function BuildChangedGraphicsRestoreSnapshot(before)
    local restore = {}
    for name, oldValue in pairs(before or {}) do
        local settingId = GetNamedGraphicsSettingId(name)
        if type(settingId) == "number" then
            local currentValue = GetGraphicsSettingSafe(settingId)
            if currentValue ~= nil and not GraphicsValuesEquivalent(currentValue, oldValue) then
                restore[name] = tostring(oldValue)
            end
        end
    end
    return restore
end

local function ApplyNamedGraphicsSnapshot(snapshot)
    local ok = true
    for name, value in pairs(snapshot or {}) do
        local settingId = GetNamedGraphicsSettingId(name)
        if type(settingId) == "number" then
            ok = SetGraphicsSettingSafe(settingId, value) and ok
        end
    end
    if type(ApplySettings) == "function" then pcall(ApplySettings) end
    return ok
end

local function RestoreAllLowGraphicsSnapshot(silent)
    local state = GetGraphicsAccountState()
    if not state or state.allLowActive ~= true then return true end

    local ok = ApplyNamedGraphicsSnapshot(state.allLowRestoreSnapshot)
    if ok then
        state.allLowActive = false
        state.allLowRestoreSnapshot = nil
        if U.RequestSettingsSave then U.RequestSettingsSave(true) end
    end

    if not silent and d then
        d(ok and "[Ultivite] Restored graphics settings from before All Low." or "[Ultivite] Pre-All-Low graphics restoration was incomplete. The saved restore snapshot was retained for another attempt.")
    end
    return ok
end

local function ApplyAllLowGraphicsPreset(silent)
    local state = GetGraphicsAccountState()
    local presetSetting = rawget(_G, "GRAPHICS_SETTING_PRESETS")
    local lowPreset = rawget(_G, "GRAPHICS_PRESETS_LOW")
    if not state or presetSetting == nil or lowPreset == nil then
        if not silent and d then d("[Ultivite] ESO Low graphics preset is not available on this client.") end
        return false
    end

    local before
    if state.allLowActive ~= true then
        before = CaptureAllGraphicsSettingValues()
    end

    -- First apply ESO's complete Low preset with persisted-data semantics.
    local ok = SetGraphicsSettingSafe(presetSetting, lowPreset)
    if ok and type(ApplySettings) == "function" then
        ok = pcall(ApplySettings) == true and ok
    end
    if ok and type(RefreshSettings) == "function" then
        ok = pcall(RefreshSettings) == true and ok
    end
    if ok and not GraphicsValuesEquivalent(GetGraphicsSettingSafe(presetSetting), lowPreset) then
        ok = false
    end

    -- Then explicitly force the public quality controls to their Low, Off or
    -- performance values. This is intentional redundancy: it makes All Low
    -- deterministic even if ESO leaves one or more controls unchanged when the
    -- preset selector is changed by addon code.
    local enforcedTargets = {}
    if ok then
        local enforcedOk
        enforcedOk, enforcedTargets = ApplyAllLowEnforcedTargets()
        ok = enforcedOk and ok
    end

    if ok and type(ApplySettings) == "function" then
        ok = pcall(ApplySettings) == true and ok
    end
    if ok and type(RefreshSettings) == "function" then
        ok = pcall(RefreshSettings) == true and ok
    end

    if ok then
        ok = VerifyAllLowEnforcedTargets(enforcedTargets) and ok
    end

    if ok and state.allLowActive ~= true then
        state.allLowRestoreSnapshot = BuildChangedGraphicsRestoreSnapshot(before)
        state.allLowActive = true
    elseif ok then
        state.allLowActive = true
    end

    if ok then
        state.lastAppliedProfileId = GRAPHICS_BUILTIN_LOW
        Q.lastAppliedGraphicsProfile = GRAPHICS_BUILTIN_LOW
        if U.RequestSettingsSave then U.RequestSettingsSave(true) end
        if not silent and d then d("[Ultivite] Applied and verified All Low graphics. Previous graphics values are retained for restoration.") end
    elseif not silent and d then
        d("[Ultivite] All Low graphics could not be fully applied or verified.")
    end
    return ok
end

local function CaptureCurrentGraphicsSettings()
    local godRaysSetting = GetGodRaysSettingId()
    local aoSetting = GetAmbientOcclusionSettingId()
    return {
        shadows = GetGraphicsSettingSafe(GRAPHICS_SETTING_SHADOWS),
        waterReflections = GetGraphicsSettingSafe(GRAPHICS_SETTING_SCREENSPACE_WATER_REFLECTION_QUALITY),
        distortion = GetGraphicsSettingSafe(GRAPHICS_SETTING_DISTORTION),
        bloom = GetGraphicsSettingSafe(GRAPHICS_SETTING_BLOOM),
        godRays = godRaysSetting and GetGraphicsSettingSafe(godRaysSetting) or ReadCVarSafe("GOD_RAYS"),
        clutter = GetGraphicsSettingSafe(GRAPHICS_SETTING_CLUTTER_2D_QUALITY),
        ambientOcclusion = aoSetting and GetGraphicsSettingSafe(aoSetting) or ReadCVarSafe("AMBIENT_OCCLUSION_TYPE"),
    }
end

local function CopyGraphicsSettings(source)
    source = source or {}
    return {
        shadows = GraphicsValue(source.shadows),
        waterReflections = GraphicsValue(source.waterReflections),
        distortion = GraphicsValue(source.distortion),
        bloom = GraphicsValue(source.bloom),
        godRays = GraphicsValue(source.godRays),
        clutter = GraphicsValue(source.clutter),
        ambientOcclusion = GraphicsValue(source.ambientOcclusion),
    }
end

function Q.GetCurrentGraphicsSettings()
    return CopyGraphicsSettings(CaptureCurrentGraphicsSettings())
end

function Q.EnsureGraphicsProfiles()
    local state = GetGraphicsAccountState()
    if not state then return nil end
    state.profiles = type(state.profiles) == "table" and state.profiles or {}
    state.order = type(state.order) == "table" and state.order or {}
    state.autoEnabled = state.autoEnabled == true
    state.nextCustomId = math.max(1, tonumber(state.nextCustomId) or 1)
    state.pendingName = tostring(state.pendingName or "Custom Graphics")

    local function ensureBuiltin(id, name, factoryType)
        local profile = state.profiles[id]
        if type(profile) ~= "table" then
            profile = { name = name, builtin = factoryType, settings = BuildFactoryGraphicsSettings(factoryType == "pve") }
            state.profiles[id] = profile
        end
        profile.name = tostring(profile.name or name)
        profile.builtin = factoryType
        profile.special = factoryType == "low" and "allLow" or nil
        if type(profile.settings) ~= "table" then
            profile.settings = BuildFactoryGraphicsSettings(factoryType == "pve")
        end
    end

    ensureBuiltin(GRAPHICS_BUILTIN_PVE, "PvE Quality", "pve")
    ensureBuiltin(GRAPHICS_BUILTIN_PVP, "PvP Performance", "pvp")
    ensureBuiltin(GRAPHICS_BUILTIN_LOW, "All Low", "low")

    local seen = {}
    local cleaned = {}
    local function add(id)
        if state.profiles[id] and not seen[id] then
            cleaned[#cleaned + 1] = id
            seen[id] = true
        end
    end
    add(GRAPHICS_BUILTIN_PVE)
    add(GRAPHICS_BUILTIN_PVP)
    add(GRAPHICS_BUILTIN_LOW)
    for _, id in ipairs(state.order) do add(tostring(id)) end
    for id in pairs(state.profiles) do add(tostring(id)) end
    state.order = cleaned

    if not state.profiles[state.pveProfileId or ""] then state.pveProfileId = GRAPHICS_BUILTIN_PVE end
    if not state.profiles[state.pvpProfileId or ""] then state.pvpProfileId = GRAPHICS_BUILTIN_PVP end
    if not state.profiles[state.selectedProfileId or ""] then state.selectedProfileId = GRAPHICS_BUILTIN_PVE end
    return state
end

function Q.GetGraphicsProfile(profileId)
    local state = Q.EnsureGraphicsProfiles()
    return state and state.profiles and state.profiles[profileId or ""] or nil
end

function Q.GetGraphicsProfileName(profileId)
    local profile = Q.GetGraphicsProfile(profileId)
    return profile and tostring(profile.name or profileId) or "Unknown"
end

function Q.GetAssignedGraphicsProfileId(context)
    local state = Q.EnsureGraphicsProfiles()
    if not state then return nil end
    return tostring(context):upper() == "PVP" and state.pvpProfileId or state.pveProfileId
end

local function ApplyGraphicsSettings(settings)
    settings = settings or {}
    local ok = true
    local expectedGraphics = {}
    local expectedCVars = {}

    local function applyGraphics(settingId, value)
        if settingId == nil or value == nil then ok = false; return false end
        value = tostring(value)
        expectedGraphics[settingId] = value
        local applied = SetGraphicsSettingSafe(settingId, value)
        ok = applied and ok
        return applied
    end

    local function applyCVar(name, value)
        if value == nil then ok = false; return false end
        value = tostring(value)
        local applied = SetCVarSafe(name, value)
        if applied then expectedCVars[name] = value end
        ok = applied and ok
        return applied
    end

    applyGraphics(GRAPHICS_SETTING_SHADOWS, settings.shadows)
    applyGraphics(GRAPHICS_SETTING_SCREENSPACE_WATER_REFLECTION_QUALITY, settings.waterReflections)
    applyGraphics(GRAPHICS_SETTING_DISTORTION, settings.distortion)
    applyGraphics(GRAPHICS_SETTING_BLOOM, settings.bloom)

    local godRaysSetting = GetGodRaysSettingId()
    if godRaysSetting ~= nil then applyGraphics(godRaysSetting, settings.godRays)
    else applyCVar("GOD_RAYS", settings.godRays == "true" and "1" or settings.godRays == "false" and "0" or settings.godRays) end

    applyGraphics(GRAPHICS_SETTING_CLUTTER_2D_QUALITY, settings.clutter)

    local aoSetting = GetAmbientOcclusionSettingId()
    if aoSetting ~= nil then applyGraphics(aoSetting, settings.ambientOcclusion)
    else applyCVar("AMBIENT_OCCLUSION_TYPE", settings.ambientOcclusion) end

    if type(ApplySettings) == "function" then pcall(ApplySettings) end

    for settingId, expected in pairs(expectedGraphics) do
        if not GraphicsValuesEquivalent(GetGraphicsSettingSafe(settingId), expected) then ok = false end
    end
    for name, expected in pairs(expectedCVars) do
        if not GraphicsValuesEquivalent(ReadCVarSafe(name), expected) then ok = false end
    end
    return ok
end

function Q.ApplyGraphicsSettingsSnapshot(settings, silent)
    local ok = ApplyGraphicsSettings(CopyGraphicsSettings(settings))
    if not silent and d then d(ok and "[Ultivite] Unified profile graphics applied." or "[Ultivite] Unified profile graphics verification failed.") end
    return ok
end

function Q.ApplyGraphicsProfileById(profileId, silent, allowRetry)
    local state = Q.EnsureGraphicsProfiles()
    local profile = state and state.profiles and state.profiles[profileId or ""] or nil
    if not profile or type(profile.settings) ~= "table" then return false end

    if profileId == GRAPHICS_BUILTIN_LOW or profile.special == "allLow" then
        return ApplyAllLowGraphicsPreset(silent)
    end

    -- Leaving All Low is transactional: restore every graphics value that ESO's
    -- Low preset changed before applying the narrower PvE/PvP/custom profile.
    -- If restoration fails, keep the snapshot and do not layer another profile
    -- over a partially restored client state.
    if not RestoreAllLowGraphicsSnapshot(true) then
        if not silent and d then
            d("[Ultivite] Graphics profile change stopped because the pre-All-Low settings could not be fully restored.")
        end
        return false
    end

    local ok = ApplyGraphicsSettings(profile.settings)
    if ok then
        state.lastAppliedProfileId = profileId
        Q.lastAppliedGraphicsProfile = profileId
        if not silent and d then d("[Ultivite] Applied graphics profile: " .. tostring(profile.name or profileId) .. ".") end
        if U.RequestSettingsSave then U.RequestSettingsSave(true) end
        return true
    end

    if allowRetry ~= false and zo_callLater then
        local retryId = profileId
        zo_callLater(function()
            local retryState = Q.EnsureGraphicsProfiles()
            if not retryState or not retryState.profiles[retryId] then return end
            if ApplyGraphicsSettings(retryState.profiles[retryId].settings) then
                retryState.lastAppliedProfileId = retryId
                Q.lastAppliedGraphicsProfile = retryId
                if U.RequestSettingsSave then U.RequestSettingsSave(true) end
            elseif d and not silent then
                d("[Ultivite] Graphics profile verification failed after retry: " .. Q.GetGraphicsProfileName(retryId) .. ".")
            end
            Q.SafeRefresh()
        end, 400)
    elseif d and not silent then
        d("[Ultivite] Graphics profile verification failed: " .. Q.GetGraphicsProfileName(profileId) .. ".")
    end
    return false
end

function Q.ApplyAssignedGraphics(context, silent)
    local id = Q.GetAssignedGraphicsProfileId(context)
    if not id then return false end
    return Q.ApplyGraphicsProfileById(id, silent, true)
end

local function ApplyPveGraphicsProfile()
    return Q.ApplyAssignedGraphics("PVE", false)
end

local function ApplyPvpGraphicsProfile()
    return Q.ApplyAssignedGraphics("PVP", false)
end

local function ApplyAllLowGraphicsProfile()
    return Q.ApplyGraphicsProfileById(GRAPHICS_BUILTIN_LOW, false, false)
end

function Q.GetGraphicsContext()
    local function safeBool(fn)
        if type(fn) ~= "function" then return false end
        local ok, value = pcall(fn)
        return ok and value == true
    end
    if safeBool(IsActiveWorldBattleground) then return "PVP", "Battleground" end
    if safeBool(IsInCyrodiil) then return "PVP", "Cyrodiil" end
    if safeBool(IsInImperialCity) then return "PVP", "Imperial City" end
    return "PVE", "PvE"
end

function Q.ApplyAutomaticGraphicsForCurrentContext(force)
    local state = Q.EnsureGraphicsProfiles()
    if not state or state.autoEnabled ~= true then return false end
    local context, reason = Q.GetGraphicsContext()
    local profileId = Q.GetAssignedGraphicsProfileId(context)
    if not profileId then return false end

    -- EVENT_PLAYER_ACTIVATED is the transition boundary. Within one activation
    -- generation, do not reapply an unchanged profile unless explicitly asked.
    local zoneId = 0
    if type(GetZoneId) == "function" and type(GetUnitZoneIndex) == "function" then
        local okIndex, zoneIndex = pcall(GetUnitZoneIndex, "player")
        if okIndex and zoneIndex then
            local okZone, value = pcall(GetZoneId, zoneIndex)
            if okZone then zoneId = tonumber(value) or 0 end
        end
    end
    local signature = tostring(context) .. ":" .. tostring(profileId) .. ":" .. tostring(zoneId)
    if force ~= true and Q.lastAutoGraphicsSignature == signature and Q.lastAppliedGraphicsProfile == profileId then
        return true
    end

    local ok = Q.ApplyGraphicsProfileById(profileId, true, true)
    state.lastAutoContext = context
    state.lastAutoReason = reason
    Q.lastAutoGraphicsSignature = signature
    if U.RequestSettingsSave then U.RequestSettingsSave(true) end
    if ok and d then d("[Ultivite] Auto graphics: " .. tostring(reason) .. " -> " .. Q.GetGraphicsProfileName(profileId) .. ".") end
    return ok
end

function Q.ToggleAutomaticGraphics()
    local state = Q.EnsureGraphicsProfiles()
    if not state then return false end
    state.autoEnabled = state.autoEnabled ~= true
    Q.lastAutoGraphicsSignature = nil
    if U.RequestSettingsSave then U.RequestSettingsSave(true) end
    if state.autoEnabled then Q.ApplyAutomaticGraphicsForCurrentContext(true) end
    return true
end

local function RefreshGraphicsLam()
    if CALLBACK_MANAGER and U.panel then CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", U.panel) end
    Q.SafeRefresh()
end

local function SelectedGraphicsProfile()
    local state = Q.EnsureGraphicsProfiles()
    return state and state.profiles and state.profiles[state.selectedProfileId] or nil, state
end

local function CycleSelectedGraphicsProfile(delta)
    local state = Q.EnsureGraphicsProfiles()
    if not state or #state.order == 0 then return false end
    local current = 1
    for i, id in ipairs(state.order) do
        if id == state.selectedProfileId then current = i break end
    end
    current = ((current - 1 + delta) % #state.order) + 1
    state.selectedProfileId = state.order[current]
    if U.RequestSettingsSave then U.RequestSettingsSave(true) end
    RefreshGraphicsLam()
    return true
end

local function CreateCustomGraphicsProfile(captureCurrent, duplicateSelected)
    local state = Q.EnsureGraphicsProfiles()
    if not state then return false end
    local name = tostring(state.pendingName or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then name = "Custom Graphics" end
    local id = "custom_" .. tostring(state.nextCustomId)
    while state.profiles[id] do state.nextCustomId = state.nextCustomId + 1; id = "custom_" .. tostring(state.nextCustomId) end
    state.nextCustomId = state.nextCustomId + 1

    local settings
    if captureCurrent then
        settings = CaptureCurrentGraphicsSettings()
    elseif duplicateSelected then
        local selected = state.profiles[state.selectedProfileId]
        settings = CopyGraphicsSettings(selected and selected.settings or BuildFactoryGraphicsSettings(true))
    else
        settings = BuildFactoryGraphicsSettings(true)
    end
    state.profiles[id] = { name = name, settings = settings }
    state.order[#state.order + 1] = id
    state.selectedProfileId = id
    if U.RequestSettingsSave then U.RequestSettingsSave(true) end
    RefreshGraphicsLam()
    return true
end

local function RenameSelectedGraphicsProfile()
    local profile, state = SelectedGraphicsProfile()
    if not profile or not state or profile.builtin then return false end
    local name = tostring(state.pendingName or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then return false end
    profile.name = name
    if U.RequestSettingsSave then U.RequestSettingsSave(true) end
    RefreshGraphicsLam()
    return true
end

local function DeleteSelectedGraphicsProfile()
    local profile, state = SelectedGraphicsProfile()
    if not profile or not state or profile.builtin then return false end
    local id = state.selectedProfileId
    state.profiles[id] = nil
    local cleaned = {}
    for _, value in ipairs(state.order) do if value ~= id then cleaned[#cleaned + 1] = value end end
    state.order = cleaned
    if state.pveProfileId == id then state.pveProfileId = GRAPHICS_BUILTIN_PVE end
    if state.pvpProfileId == id then state.pvpProfileId = GRAPHICS_BUILTIN_PVP end
    state.selectedProfileId = GRAPHICS_BUILTIN_PVE
    if U.RequestSettingsSave then U.RequestSettingsSave(true) end
    RefreshGraphicsLam()
    return true
end

local function RestoreSelectedGraphicsProfile()
    local profile, state = SelectedGraphicsProfile()
    if not profile or not state or not profile.builtin then return false end
    profile.settings = BuildFactoryGraphicsSettings(profile.builtin == "pve")
    if U.RequestSettingsSave then U.RequestSettingsSave(true) end
    RefreshGraphicsLam()
    return true
end

local function SetSelectedProfileAs(context)
    local state = Q.EnsureGraphicsProfiles()
    if not state or not state.profiles[state.selectedProfileId] then return false end
    if tostring(context):upper() == "PVP" then state.pvpProfileId = state.selectedProfileId else state.pveProfileId = state.selectedProfileId end
    Q.lastAutoGraphicsSignature = nil
    if U.RequestSettingsSave then U.RequestSettingsSave(true) end
    if state.autoEnabled then Q.ApplyAutomaticGraphicsForCurrentContext(true) end
    RefreshGraphicsLam()
    return true
end

local function EnumChoices(items)
    local labels, values, seen = {}, {}, {}
    for _, item in ipairs(items) do
        local value = _G and _G[item[2]] or nil
        if value ~= nil then
            local text = tostring(value)
            if not seen[text] then labels[#labels + 1] = item[1]; values[#values + 1] = text; seen[text] = true end
        end
    end
    return labels, values
end

function Q.BuildGraphicsMenuControls()
    Q.EnsureGraphicsProfiles()
    local shadowLabels, shadowValues = EnumChoices({ {"Off", "SHADOWS_CHOICE_OFF"}, {"Low", "SHADOWS_CHOICE_LOW"}, {"Medium", "SHADOWS_CHOICE_MEDIUM"}, {"High", "SHADOWS_CHOICE_HIGH"}, {"Ultra", "SHADOWS_CHOICE_ULTRA"} })
    local waterLabels, waterValues = EnumChoices({ {"Off", "SCREENSPACE_WATER_REFLECTION_QUALITY_OFF"}, {"Low", "SCREENSPACE_WATER_REFLECTION_QUALITY_LOW"}, {"Medium", "SCREENSPACE_WATER_REFLECTION_QUALITY_MEDIUM"}, {"High", "SCREENSPACE_WATER_REFLECTION_QUALITY_HIGH"}, {"Ultra", "SCREENSPACE_WATER_REFLECTION_QUALITY_ULTRA"} })
    local clutterLabels, clutterValues = EnumChoices({ {"Off", "CLUTTER_QUALITY_OFF"}, {"Low", "CLUTTER_QUALITY_LOW"}, {"Medium", "CLUTTER_QUALITY_MEDIUM"}, {"High", "CLUTTER_QUALITY_HIGH"}, {"Ultra", "CLUTTER_QUALITY_ULTRA"} })
    local aoLabels, aoValues = EnumChoices({ {"Off", "AMBIENT_OCCLUSION_TYPE_NONE"}, {"SSAO", "AMBIENT_OCCLUSION_TYPE_SSAO"}, {"HBAO", "AMBIENT_OCCLUSION_TYPE_HBAO"}, {"LSAO", "AMBIENT_OCCLUSION_TYPE_LSAO"}, {"Screen Space GI", "AMBIENT_OCCLUSION_TYPE_SSGI"} })
    local boolLabels, boolValues = { "Off", "On" }, { "false", "true" }

    local function getSetting(key)
        local profile = SelectedGraphicsProfile()
        return profile and profile.settings and tostring(profile.settings[key] or "") or ""
    end
    local function setSetting(key, value)
        local profile = SelectedGraphicsProfile()
        if not profile then return end
        profile.settings = profile.settings or {}
        profile.settings[key] = tostring(value)
        if U.RequestSettingsSave then U.RequestSettingsSave(true) end
    end
    local function dropdown(name, key, labels, values, tooltip)
        return { type = "dropdown", name = name, tooltip = tooltip, choices = labels, choicesValues = values,
            getFunc = function() return getSetting(key) end,
            setFunc = function(value) setSetting(key, value) end,
            disabled = function() local p = SelectedGraphicsProfile(); return p and p.special == "allLow" end,
            width = "full" }
    end

    return {
        { type = "description", title = "Automatic Graphics Profiles", text = function()
            local state = Q.EnsureGraphicsProfiles()
            local context, reason = Q.GetGraphicsContext()
            return string.format("Current context: %s. PvE assignment: %s. PvP assignment: %s.", reason, Q.GetGraphicsProfileName(state.pveProfileId), Q.GetGraphicsProfileName(state.pvpProfileId))
        end },
        { type = "checkbox", name = "Automatic graphics switching",
            tooltip = "When enabled, Battlegrounds, Cyrodiil and Imperial City use the assigned PvP profile. Every other zone uses the assigned PvE profile. Switching occurs after loading/zone activation, not during combat.",
            getFunc = function() local state = Q.EnsureGraphicsProfiles(); return state and state.autoEnabled == true end,
            setFunc = function(value) local state = Q.EnsureGraphicsProfiles(); if state then state.autoEnabled = value == true; Q.lastAutoGraphicsSignature = nil; if U.RequestSettingsSave then U.RequestSettingsSave(true) end; if state.autoEnabled then Q.ApplyAutomaticGraphicsForCurrentContext(true) end; Q.SafeRefresh() end end,
            default = false, width = "full" },
        { type = "button", name = function() return "Apply PvE: " .. Q.GetGraphicsProfileName(Q.GetAssignedGraphicsProfileId("PVE")) end, func = ApplyPveGraphicsProfile, width = "half" },
        { type = "button", name = function() return "Apply PvP: " .. Q.GetGraphicsProfileName(Q.GetAssignedGraphicsProfileId("PVP")) end, func = ApplyPvpGraphicsProfile, width = "half" },
        { type = "button", name = "Apply All Low",
            tooltip = "Applies ESO's complete Low graphics preset, then explicitly enforces every supported Low/Off quality control Ultivite can set through the public graphics API. Previous values are retained and restored before PvE, PvP or another profile is applied.",
            func = ApplyAllLowGraphicsProfile, width = "full" },
        { type = "submenu", name = "Profile Editor", controls = {
            { type = "description", title = function() return "Editing: " .. Q.GetGraphicsProfileName((Q.EnsureGraphicsProfiles() or {}).selectedProfileId) end,
                text = function()
                    local p = SelectedGraphicsProfile()
                    if p and p.special == "allLow" then
                        return "All Low applies ESO's complete Low preset and explicitly enforces supported Low/Off quality controls. Ultivite snapshots changed graphics values and restores them before PvE, PvP or another profile is applied."
                    end
                    return "Use Previous/Next to choose a profile. Editing changes the saved profile but does not immediately change live graphics until you apply it or automatic switching selects it."
                end },
            { type = "button", name = "Previous Profile", func = function() CycleSelectedGraphicsProfile(-1) end, width = "half" },
            { type = "button", name = "Next Profile", func = function() CycleSelectedGraphicsProfile(1) end, width = "half" },
            { type = "button", name = "Use Selected as PvE", func = function() SetSelectedProfileAs("PVE") end, width = "half" },
            { type = "button", name = "Use Selected as PvP", func = function() SetSelectedProfileAs("PVP") end, width = "half" },
            dropdown("Shadows", "shadows", shadowLabels, shadowValues, "Shadow quality saved in this graphics profile."),
            dropdown("Water Reflections", "waterReflections", waterLabels, waterValues, "Screen-space water reflection quality."),
            dropdown("Distortion", "distortion", boolLabels, boolValues, "Distortion effect."),
            dropdown("Bloom", "bloom", boolLabels, boolValues, "Bloom effect."),
            dropdown("Sunlight Rays", "godRays", boolLabels, boolValues, "Sunlight/God Rays effect."),
            dropdown("Grass / Clutter", "clutter", clutterLabels, clutterValues, "2D clutter and grass quality."),
            dropdown("Ambient Occlusion", "ambientOcclusion", aoLabels, aoValues, "Ambient occlusion mode, including Screen Space GI when supported by ESO."),
            { type = "editbox", name = "New / Rename Profile Name", isMultiline = false,
                getFunc = function() local state = Q.EnsureGraphicsProfiles(); return state and tostring(state.pendingName or "") or "" end,
                setFunc = function(value) local state = Q.EnsureGraphicsProfiles(); if state then state.pendingName = tostring(value or ""); if U.RequestSettingsSave then U.RequestSettingsSave(true) end end end,
                width = "full" },
            { type = "button", name = "Create From Current Graphics", tooltip = "Creates a new custom profile using ESO's seven graphics settings as they are configured right now.", func = function() CreateCustomGraphicsProfile(true, false) end, width = "full" },
            { type = "button", name = "Duplicate Selected Profile", func = function() CreateCustomGraphicsProfile(false, true) end, width = "half" },
            { type = "button", name = "Rename Selected Custom", func = RenameSelectedGraphicsProfile, width = "half",
                disabled = function() local p = SelectedGraphicsProfile(); return not p or p.builtin ~= nil end },
            { type = "button", name = "Delete Selected Custom", func = DeleteSelectedGraphicsProfile, width = "half", isDangerous = true,
                disabled = function() local p = SelectedGraphicsProfile(); return not p or p.builtin ~= nil end },
            { type = "button", name = "Restore Built-in Defaults", func = RestoreSelectedGraphicsProfile, width = "half",
                disabled = function() local p = SelectedGraphicsProfile(); return not p or p.builtin == nil end },
            { type = "button", name = "Apply Selected Profile Now", func = function() local state = Q.EnsureGraphicsProfiles(); return state and Q.ApplyGraphicsProfileById(state.selectedProfileId, false, true) end, width = "full" },
        } },
    }
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
            Q.SafeRefresh()
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
    -- Combat Only controls timing only. It must not silently change the separate
    -- Action Bar ON/OFF preference.
    Frames.SetCombatOnly(enableCombatOnly, true)
    RequestSave()
    RefreshLAM()
end

local function ToggleActionBar()
    if not Frames or not Frames.saved or not Frames.SetHideActionBar then return end
    Frames.SetHideActionBar(Frames.saved.hideActionBar ~= true, true)
end

local function TogglePyramidPlayerFrames()
    if not Frames or not Frames.SetPyramidLayoutEnabled then return false end
    local f = GetProfileFrames()
    if not f then return false end
    Frames.saved = f
    local enabled = f.pyramidLayoutEnabled ~= true
    local result = Frames.SetPyramidLayoutEnabled(enabled, true)
    RequestSave()
    RefreshLAM()
    return result ~= false
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
    if Combat and Combat.GetEnemyOverheadHealthMode then
        return Combat.GetEnemyOverheadHealthMode()
    end
    return "vanilla"
end

local function SetEnemyHealthMode(mode)
    local sv = GetCombatSettings()
    if not sv or not Combat then return end
    Combat.sv = sv
    if Combat.SetEnemyOverheadHealthMode then
        Combat.SetEnemyOverheadHealthMode(mode, true)
    end
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
    local hidden = Combat and Combat.IsNpcNamesHidden and Combat.IsNpcNamesHidden() or (f.vanillaNpcNamesHidden == true)
    SetNpcNamesHidden(not hidden)
end

local function TogglePlayerNames()
    if not Combat or not Combat.SetPlayerNamesHidden then return end
    local hidden = Combat.IsPlayerNamesHidden and Combat.IsPlayerNamesHidden() or false
    Combat.SetPlayerNamesHidden(not hidden, true)
    RequestSave()
    RefreshLAM()
end

local function ToggleGoldenPursuits()
    if not Frames or not Frames.SetGoldenPursuitsHidden then return end
    local hidden = Frames.IsGoldenPursuitsHidden and Frames.IsGoldenPursuitsHidden() or false
    Frames.SetGoldenPursuitsHidden(not hidden, true)
    RequestSave()
    RefreshLAM()
end

local function ToggleOverheadPlayerInfo()
    if not Combat or not Combat.IsOverheadPlayerInfoEnabled or not Combat.SetOverheadPlayerInfoEnabled then return end
    Combat.SetOverheadPlayerInfoEnabled(not Combat.IsOverheadPlayerInfoEnabled(), true)
    RequestSave()
    RefreshLAM()
end

local function IsVanillaTargetFramesActive()
    return U and U.IsVanillaTargetFramesActive and U.IsVanillaTargetFramesActive() or false
end

local function ToggleTargetFrameMode()
    if not U or not U.ToggleTargetFrameMode then return false end
    local applied = U.ToggleTargetFrameMode(false)
    RefreshLAM()
    Q.SafeRefresh()
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

function Q.SetPreviewEnabled(enabled, explicitExit)
    local newValue = enabled and true or false
    if newValue == Q.previewEnabled then return true end
    if newValue == false and Q.previewEnabled == true and explicitExit ~= true then
        Q.SafeRefresh()
        return false
    end
    Q.previewEnabled = newValue
    if newValue then
        Q.manualDismissed = false
        Q.closePending = false
        Q.ActivatePreviewRuntime()
    else
        Q.DeactivatePreviewRuntime()
    end
    Q.SyncPreviewVisibility()
    Q.SafeRefresh()
    return true
end

function Q.TogglePreview()
    if Q.previewEnabled == true then
        Q.SafeRefresh()
        return false
    end
    return Q.SetPreviewEnabled(true)
end

function Q.SaveAndLockEditing()
    local wasPreview = Q.previewEnabled == true or Q.previewRuntime ~= nil
    if Q.previewEnabled == true then
        Q.SetPreviewEnabled(false, true)
    elseif Q.previewRuntime then
        Q.DeactivatePreviewRuntime()
    end

    if Frames and Frames.SetLocked then Frames.SetLocked(true, true) end
    if Combat and Combat.SetLocked then Combat.SetLocked(true, true) end
    if Combat and Combat.SetPositionPreview then Combat.SetPositionPreview(false) end
    if EnemyAlerts and EnemyAlerts.SetPreviewKind then EnemyAlerts.SetPreviewKind(nil) end

    local fab = rawget(_G, "FancyActionBar")
    if fab and fab.IsUnlocked and fab.ToggleMover and fab.IsUnlocked() then
        pcall(fab.ToggleMover, false)
    end

    Q.previewHudInteractionActive = false
    Q.previewHudInteractionUntil = 0
    Q.previewRestorePending = false
    Q.closePending = false
    Q.manualDismissed = true
    Q.openedFromSettings = false
    RequestSave()
    SafeRequestSave()
    Q.HideNow(false)

    if d and wasPreview then d("[Ultivite] HUD positions and sizes saved and locked.") end
    return true
end

function Q.ToggleResize()
    if Q.previewEnabled ~= true then Q.SetPreviewEnabled(true) end
    Q.resizeEnabled = Q.resizeEnabled ~= true
    Q.ApplyActualPreviewVisibility()
    Q.SafeRefresh()
end

function Q.SelectPreview(key)
    if not key or PREVIEWABLE_KEYS[key] ~= true then return end
    Q.previewKey = key
    if Q.previewEnabled then Q.ApplyActualPreviewVisibility() end
end

function Q.Refresh()
    local f = GetProfileFrames()
    local c = GetCombatSettings()
    SetButtonText("preview", Q.previewEnabled == true and "MOVE / RESIZE MODE: ACTIVE" or "MOVE / RESIZE MODE: OFF")
    SetButtonText("resize", "MOUSE WHEEL RESIZE: " .. BoolText(Q.resizeEnabled == true))
    SetButtonText("saveLock", Q.previewEnabled == true and "SAVE & LOCK EDITING" or "SAVE & LOCK")
    SetButtonText("immersive", "IMMERSIVE MODE: " .. BoolText(Immersive and Immersive.IsActive and Immersive.IsActive()))
    SetButtonText("camera", "CAMERA / SCREENSHOT MODE: " .. BoolText(Immersive and Immersive.IsCameraMode and Immersive.IsCameraMode()))
    SetButtonText("darkSouls", "DARK SOULS PROFILE: " .. DarkSoulsText())
    SetButtonText("pyramid", "PYRAMID PLAYER FRAMES: " .. BoolText(f and f.pyramidLayoutEnabled == true))
    local hudPreset = GetHudVisibilityPreset()
    local hudText = hudPreset == "combat" and "COMBAT CLEAN" or hudPreset == "pvp" and "PVP CLEAN" or SimpleModeLabel(hudPreset)
    SetButtonText("hudVisibility", "ESO HUD PRESET: " .. hudText)
    SetButtonText("enemyHealth", "ESO ENEMY OVERHEAD BARS: " .. SimpleModeLabel(GetEnemyHealthMode()))
    SetButtonText("combatOnly", "COMBAT HUD: " .. ((f and f.combatOnly == true) and "COMBAT ONLY" or "ALWAYS"))
    SetButtonText("actionBar", "ACTION BAR: " .. BoolText(not (f and f.hideActionBar == true)))
    SetButtonText("vanillaTargetFrames", IsVanillaTargetFramesActive() and "TARGET FRAMES: VANILLA  >  ULTIVITE" or "TARGET FRAMES: ULTIVITE  >  VANILLA")
    SetButtonText("groupFrame", "GROUP FRAME: " .. SimpleModeLabel(Frames and Frames.GetGroupFrameVisibilityMode and Frames.GetGroupFrameVisibilityMode() or "show"))
    SetButtonText("cpProgress", "CHAMPION PROGRESS BAR: " .. SimpleModeLabel(Frames and Frames.GetChampionProgressVisibilityMode and Frames.GetChampionProgressVisibilityMode() or "show"))
    SetButtonText("npcNames", "ESO NPC NAMES: " .. ((Combat and Combat.IsNpcNamesHidden and Combat.IsNpcNamesHidden()) and "OFF" or "ON"))
    SetButtonText("playerNames", "ESO PLAYER NAMES: " .. ((Combat and Combat.IsPlayerNamesHidden and Combat.IsPlayerNamesHidden()) and "OFF" or "ON"))
    SetButtonText("goldenPursuits", "GOLDEN PURSUITS: " .. ((Frames and Frames.IsGoldenPursuitsHidden and Frames.IsGoldenPursuitsHidden()) and "OFF" or "ON"))
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
    SetButtonText("votanMiniMap", "VOTAN MINIMAP: " .. VotanMiniMapStateText())
    SetButtonText("banditsMiniMap", "BANDITS MINIMAP: " .. BanditsMiniMapStateText())
    local graphicsState = Q.EnsureGraphicsProfiles()
    local graphicsContext = Q.GetGraphicsContext()
    SetButtonText("graphicsAuto", "AUTO GRAPHICS: " .. BoolText(graphicsState and graphicsState.autoEnabled == true) .. "  |  " .. tostring(graphicsContext))
    SetButtonText("graphicsPveApply", "APPLY PVE: " .. Q.GetGraphicsProfileName(Q.GetAssignedGraphicsProfileId("PVE")))
    SetButtonText("graphicsPvpApply", "APPLY PVP: " .. Q.GetGraphicsProfileName(Q.GetAssignedGraphicsProfileId("PVP")))
    SetButtonText("graphicsLowApply", "APPLY ALL LOW: " .. ((graphicsState and graphicsState.allLowActive == true) and "ACTIVE" or "READY"))
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

function Q.SafeRefresh()
    local ok, failure = pcall(Q.Refresh)
    if ok then
        Q.lastRefreshFailure = nil
        return true
    end
    failure = tostring(failure or "unknown refresh error")
    if Q.lastRefreshFailure ~= failure and d then
        d("[Ultivite] Quick Menu refresh isolated from ESO chat input: " .. failure)
    end
    Q.lastRefreshFailure = failure
    return false
end

local function QuickControlName(base)
    local attempt = tonumber(Q.createAttempt) or 1
    return attempt > 1 and (base .. "Retry" .. tostring(attempt)) or base
end

local function NewButton(parent, key, text, yOffset, callback)
    local button = WINDOW_MANAGER:CreateControlFromVirtual(QuickControlName("UltiviteQuickMenu" .. key), parent, "ZO_DefaultButton")
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
        Q.SafeRefresh()

        if ok and resultOrError ~= false and key ~= "settings" and key ~= "graphicsPveApply" and key ~= "graphicsPvpApply" then
            zo_callLater(function()
                if actionGen ~= (Q.actionGeneration or 0) then return end
                Q.SafeRefresh()
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

local function GetQuickMenuSectionStore()
    if U.accountSV then
        U.accountSV.quickMenuSections = U.accountSV.quickMenuSections or {}
        return U.accountSV.quickMenuSections
    end
    Q.sectionExpandedFallback = Q.sectionExpandedFallback or {}
    return Q.sectionExpandedFallback
end

local function IsSectionExpanded(key)
    local store = GetQuickMenuSectionStore()
    return store[key] == true
end

local function SetSectionExpanded(key, expanded)
    local store = GetQuickMenuSectionStore()
    expanded = expanded == true

    if expanded then
        for sectionKey in pairs(Q.sectionControls or {}) do
            store[sectionKey] = sectionKey == key
        end
    else
        store[key] = false
    end
    pcall(RequestSave)
end

local function UpdateSectionLabel(key)
    local entry = Q.sectionControls[key]
    if not entry or not entry.label then return end
    local prefix = IsSectionExpanded(key) and "[-] " or "[+] "
    entry.label:SetText(prefix .. string.upper(entry.text or key))
end

function Q.LayoutRows()
    if not Q.panel or type(Q.rows) ~= "table" then return end
    local y = HEADER_HEIGHT
    local activeSection = nil

    for _, row in ipairs(Q.rows) do
        if row.type == "section" then
            activeSection = row.key
            local entry = Q.sectionControls[row.key]
            local control = entry and entry.control or nil
            if control then
                control:SetHidden(false)
                control:ClearAnchors()
                control:SetAnchor(TOP, Q.panel, TOP, 0, y)
                y = y + SECTION_HEIGHT + SECTION_GAP
                UpdateSectionLabel(row.key)
            end
        else
            local control = Q.buttons[row.key]
            local visible = activeSection == nil or IsSectionExpanded(activeSection)
            if control then
                control:SetHidden(not visible)
                if visible then
                    control:ClearAnchors()
                    control:SetAnchor(TOP, Q.panel, TOP, 0, y)
                    y = y + ROW_HEIGHT + ROW_GAP
                end
            end
        end
    end

    Q.panel:SetHeight(y + 10)
end

local function ToggleQuickMenuSection(key)
    SetSectionExpanded(key, not IsSectionExpanded(key))
    Q.LayoutRows()
    Q.SafeRefresh()
end

local function NewSection(parent, key, text, index)
    local button = WINDOW_MANAGER:CreateControlFromVirtual(
        QuickControlName("UltiviteQuickMenuSection" .. tostring(index)),
        parent,
        "ZO_DefaultButton"
    )
    button:SetDimensions(PANEL_WIDTH - 24, SECTION_HEIGHT)
    button:SetAnchor(TOP, parent, TOP, 0, HEADER_HEIGHT)
    button:SetFont("ZoFontGameSmall")
    if button.SetNormalFontColor then button:SetNormalFontColor(0.60, 0.84, 0.95, 1.00) end
    if button.SetMouseOverFontColor then button:SetMouseOverFontColor(0.90, 0.97, 1.00, 1.00) end
    button:SetMouseEnabled(true)

    Q.sectionControls[key] = { control = button, label = button, text = text }
    UpdateSectionLabel(key)

    button:SetHandler("OnMouseEnter", function()
        Q.pointerInside = true
        Q.HoldForInteraction(1200)
    end)
    button:SetHandler("OnMouseExit", function()
        Q.pointerInside = false
        Q.HoldForInteraction(500)
    end)

    local function FinishSectionAction(pending)
        if Q.pendingSectionAction ~= pending then return end
        Q.pendingSectionAction = nil
        if pending.generation ~= (Q.actionGeneration or 0) then return end

        if Q.openedFromSettings == true then
            Q.actionInProgress = false
            Q.actionButtonKey = nil
            Q.RefreshChatVisibility(true)
        elseif pending.wasChatOpen and Q.manualDismissed ~= true then
            Q.ReopenChatAfterInteraction(pending.draftText, pending.generation)
        else
            Q.actionInProgress = false
            Q.actionButtonKey = nil
            Q.RefreshChatVisibility(true)
        end
    end

    button:SetHandler("OnMouseDown", function(_, mouseButton)
        if mouseButton ~= MOUSE_BUTTON_INDEX_LEFT then return end
        local wasChatOpen = Q.openedFromSettings ~= true and Q.IsChatOpen()
        Q.actionGeneration = (Q.actionGeneration or 0) + 1
        Q.actionInProgress = true
        Q.actionButtonKey = "section:" .. key
        Q.HoldForInteraction(700)
        local pending = {
            key = key,
            generation = Q.actionGeneration,
            wasChatOpen = wasChatOpen,
            draftText = wasChatOpen and GetChatDraftText() or "",
        }
        Q.pendingSectionAction = pending

        local ok, failure = pcall(ToggleQuickMenuSection, key)
        if not ok and d then d("[Ultivite] Quick Menu section error [" .. tostring(key) .. "]: " .. tostring(failure)) end
        zo_callLater(function() FinishSectionAction(pending) end, 0)
    end)
    button:SetHandler("OnMouseUp", function(_, mouseButton)
        if mouseButton ~= MOUSE_BUTTON_INDEX_LEFT then return end
        local pending = Q.pendingSectionAction
        if not pending or pending.key ~= key then return end
        FinishSectionAction(pending)
    end)
    button:SetHandler("OnClicked", function() end)

    return button
end

local function CreateControls()
    Q.createAttempt = (tonumber(Q.createAttempt) or 0) + 1
    Q.buttons = {}
    Q.sectionControls = {}

    -- Sections default to collapsed to keep the panel compact.
    local rows = {
        { type = "button", key = "settings", text = "FULL ULTIVITE SETTINGS", callback = function()
            if Q.previewEnabled == true then
                Q.SafeRefresh()
                return false
            end
            if Q.openedFromSettings == true then
                Q.CloseSettingsSession()
                return true
            end
            Q.BeginManualClose()
            Q.ManualClose()
            zo_callLater(function()
                if LibAddonMenu2 and U.panel and LibAddonMenu2.OpenToPanel then LibAddonMenu2:OpenToPanel(U.panel) end
            end, 0)
            return true
        end },
        { type = "button", key = "preview", text = "MOVE / RESIZE MODE", callback = Q.TogglePreview },
        { type = "button", key = "resize", text = "MOUSE WHEEL RESIZE", callback = Q.ToggleResize },
        { type = "button", key = "saveLock", text = "SAVE & LOCK", callback = Q.SaveAndLockEditing },
        { type = "button", key = "immersive", text = "IMMERSIVE MODE", callback = function()
            if not Immersive or not Immersive.Toggle then return false end
            local result = Immersive.Toggle(true)
            RefreshLAM()
            return result
        end },
        { type = "button", key = "camera", text = "CAMERA / SCREENSHOT MODE", callback = function()
            if not Immersive or not Immersive.ToggleCameraMode then return false end
            local result = Immersive.ToggleCameraMode(true)
            RefreshLAM()
            if result and Immersive.IsCameraMode and Immersive.IsCameraMode() and zo_callLater then
                zo_callLater(function()
                    Q.BeginManualClose()
                    Q.ManualClose()
                end, 80)
            end
            return result
        end },

        { type = "section", key = "combatInfo", text = "Combat Information" },
        { type = "button", key = "pvpKD", text = "PVP K/D COUNTER", callback = function() ToggleCombatBoolean("showPvpKillCounter", true, "UpdatePvpHud") end },
        { type = "button", key = "stats", text = "DAMAGE + RESISTANCE", callback = CycleStats },
        { type = "button", key = "shield", text = "SHIELD", callback = CycleShield },
        { type = "button", key = "debuffs", text = "DEBUFFS", callback = CycleDebuffs },
        { type = "button", key = "cc", text = "CC IMMUNITY", callback = function() ToggleCombatBoolean("showCcImmunityTracker", true, "ScanPlayerAuraHud") end },

        { type = "section", key = "warnings", text = "Combat Warnings" },
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

        { type = "section", key = "navigation", text = "Navigation & Minimap" },
        { type = "button", key = "feetCompass", text = "FEET COMPASS", callback = CycleFeetCompass },
        { type = "button", key = "crownArrow", text = "CROWN ARROW", callback = CycleCrownArrow },
        { type = "button", key = "votanMiniMap", text = "VOTAN MINIMAP", callback = ToggleVotanMiniMap },
        { type = "button", key = "banditsMiniMap", text = "BANDITS MINIMAP", callback = ToggleBanditsMiniMap },

        { type = "section", key = "worldUi", text = "World UI Visibility" },
        { type = "button", key = "hudVisibility", text = "ESO HUD PRESET", callback = CycleHudVisibilityPreset },
        { type = "button", key = "goldenPursuits", text = "GOLDEN PURSUITS", callback = ToggleGoldenPursuits },
        { type = "button", key = "cpProgress", text = "CHAMPION PROGRESS BAR", callback = CycleCpProgress },
        { type = "button", key = "npcNames", text = "ESO NPC NAMES", callback = ToggleNpcNames },
        { type = "button", key = "playerNames", text = "ESO PLAYER NAMES", callback = TogglePlayerNames },
        { type = "button", key = "overheadPlayerInfo", text = "OVERHEAD PLAYER INFO", callback = ToggleOverheadPlayerInfo },
        { type = "button", key = "esoCompass", text = "ESO COMPASS", callback = function() CycleVisibility("compass", STANDARD_VISIBILITY_CYCLE) end },
        { type = "button", key = "questTracker", text = "QUEST TRACKER", callback = function() CycleVisibility("quests", STANDARD_VISIBILITY_CYCLE) end },
        { type = "button", key = "queueStatus", text = "QUEUE STATUS", callback = function() CycleVisibility("queue", STANDARD_VISIBILITY_CYCLE) end },
        { type = "button", key = "crosshair", text = "CROSSHAIR", callback = function() CycleVisibility("crosshair", CROSSHAIR_VISIBILITY_CYCLE) end },
        { type = "button", key = "chatVisibility", text = "CHAT", callback = CycleChatVisibility },
        { type = "button", key = "mountMeter", text = "MOUNT STAMINA", callback = ToggleMountMeter },
        { type = "button", key = "werewolfMeter", text = "WEREWOLF METER", callback = ToggleWerewolfMeter },

        { type = "section", key = "hudFrames", text = "HUD & Frames" },
        { type = "button", key = "pyramid", text = "PYRAMID PLAYER FRAMES", callback = TogglePyramidPlayerFrames },
        { type = "button", key = "darkSouls", text = "DARK SOULS PROFILE", callback = Q.CycleDarkSoulsMode },
        { type = "button", key = "vanillaTargetFrames", text = "TARGET FRAME MODE", callback = ToggleTargetFrameMode },
        { type = "button", key = "groupFrame", text = "GROUP FRAME", callback = CycleGroupFrame },
        { type = "button", key = "enemyHealth", text = "ESO ENEMY OVERHEAD BARS", callback = CycleEnemyHealth },
        { type = "button", key = "combatOnly", text = "COMBAT HUD", callback = ToggleCombatOnly },
        { type = "button", key = "actionBar", text = "ACTION BAR", callback = ToggleActionBar },

        { type = "section", key = "graphics", text = "Graphics Profiles" },
        { type = "button", key = "graphicsAuto", text = "AUTO GRAPHICS", callback = Q.ToggleAutomaticGraphics },
        { type = "button", key = "graphicsPveApply", text = "APPLY PVE GRAPHICS", callback = ApplyPveGraphicsProfile },
        { type = "button", key = "graphicsPvpApply", text = "APPLY PVP GRAPHICS", callback = ApplyPvpGraphicsProfile },
        { type = "button", key = "graphicsLowApply", text = "APPLY ALL LOW", callback = ApplyAllLowGraphicsProfile },
    }
    Q.rows = rows

    -- LayoutRows calculates the exact live height from expanded sections after
    -- controls are created. Start compact to avoid a one-frame full-height flash.
    local panelHeight = HEADER_HEIGHT + (5 * (ROW_HEIGHT + ROW_GAP)) + (6 * (SECTION_HEIGHT + SECTION_GAP)) + 10

    local panel = WINDOW_MANAGER:CreateTopLevelWindow(QuickControlName("UltiviteQuickMenuPanel"))
    Q.panel = panel
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

    local backdrop = WINDOW_MANAGER:CreateControl(QuickControlName("UltiviteQuickMenuBackdrop"), panel, CT_BACKDROP)
    backdrop:SetAnchorFill(panel)
    backdrop:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
    backdrop:SetCenterColor(0.015, 0.02, 0.025, 0.94)
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 3, 0)
    backdrop:SetEdgeColor(0.20, 0.62, 0.82, 0.92)
    backdrop:SetMouseEnabled(false)

    local title = WINDOW_MANAGER:CreateControl(QuickControlName("UltiviteQuickMenuTitle"), panel, CT_LABEL)
    title:SetDimensions(PANEL_WIDTH - 64, 24)
    title:SetAnchor(TOP, panel, TOP, 0, 8)
    title:SetFont("ZoFontWinH3")
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    title:SetColor(0.85, 0.95, 1.00, 1.00)
    title:SetText("ULTIVITE QUICK MENU")
    title:SetMouseEnabled(false)

    local closeButton = WINDOW_MANAGER:CreateControl(QuickControlName("UltiviteQuickMenuCloseButton"), panel, CT_BUTTON)
    closeButton:SetDimensions(28, 28)
    closeButton:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -7, 5)
    closeButton:SetFont("ZoFontGameBold")
    closeButton:SetText("X")
    if closeButton.SetNormalFontColor then closeButton:SetNormalFontColor(0.90, 0.94, 0.96, 1.00) end
    if closeButton.SetMouseOverFontColor then closeButton:SetMouseOverFontColor(1.00, 0.35, 0.30, 1.00) end
    closeButton:SetHandler("OnMouseDown", function(_, mouseButton)
        if mouseButton ~= MOUSE_BUTTON_INDEX_LEFT then return end
        if Q.previewEnabled == true then Q.SafeRefresh(); return end
        Q.BeginManualClose()
        zo_callLater(function()
            if Q.closePending == true then Q.ManualClose() end
        end, 0)
    end)
    closeButton:SetHandler("OnMouseUp", function(_, mouseButton)
        if mouseButton == MOUSE_BUTTON_INDEX_LEFT and Q.previewEnabled ~= true and Q.closePending == true then Q.ManualClose() end
    end)
    closeButton:SetHandler("OnClicked", function() end)
    Q.closeButton = closeButton

    local hint = WINDOW_MANAGER:CreateControl(QuickControlName("UltiviteQuickMenuHint"), panel, CT_LABEL)
    hint:SetDimensions(PANEL_WIDTH - 54, 18)
    hint:SetAnchor(TOP, panel, TOP, 0, 31)
    hint:SetFont("ZoFontGameSmall")
    hint:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    hint:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    hint:SetColor(0.68, 0.76, 0.82, 0.95)
    hint:SetText("Move/resize stays active until SAVE & LOCK")
    hint:SetMouseEnabled(false)

    local sectionIndex = 0
    for _, row in ipairs(rows) do
        if row.type == "section" then
            sectionIndex = sectionIndex + 1
            NewSection(panel, row.key, row.text, sectionIndex)
        else
            NewButton(panel, row.key, row.text, HEADER_HEIGHT, row.callback)
        end
    end

    Q.InstallBanditsMiniMapBridge()
    Q.LayoutRows()
    -- A label refresh failure must not disable the existing controls.
    Q.SafeRefresh()
end

function Q.Create()
    if Q.initialized then return true end
    if Q.initializing or not WINDOW_MANAGER or not GuiRoot then return false end
    Q.initializing = true
    local ok, failure = pcall(CreateControls)
    Q.initializing = false

    if ok and Q.panel then
        Q.initialized = true
        Q.nextCreateRetryMs = 0
        Q.StartChatWatch()
        Q.RefreshChatVisibility(true)
        return true
    end

    Q.initialized = false
    Q.nextCreateRetryMs = GetNowMs() + 1000
    if Q.panel and Q.panel.SetHidden then pcall(Q.panel.SetHidden, Q.panel, true) end
    if d then d("[Ultivite] Quick Menu creation failed and will retry: " .. tostring(failure or "panel unavailable")) end
    return false
end

local EVENT_NAMESPACE = "UltiviteQuickMenu"
EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, function()
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED)
    zo_callLater(function()
        -- The watch is independent of panel creation. If a control/template is
        -- temporarily unavailable it keeps tracking the real chat entry and
        -- retries construction without ever touching ESO's input mode.
        Q.StartChatWatch()
        Q.Create()
    end, 250)
end)

local GRAPHICS_EVENT_NAMESPACE = "UltiviteGraphicsAuto"
EVENT_MANAGER:RegisterForEvent(GRAPHICS_EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, function()
    -- ESO can still be finalizing video state on the first frame after a load.
    -- Apply once after activation, then the profile writer performs one verified
    -- retry if a setting was not accepted yet.
    if zo_callLater then
        zo_callLater(function() Q.ApplyAutomaticGraphicsForCurrentContext(false) end, 500)
    else
        Q.ApplyAutomaticGraphicsForCurrentContext(false)
    end
end)
