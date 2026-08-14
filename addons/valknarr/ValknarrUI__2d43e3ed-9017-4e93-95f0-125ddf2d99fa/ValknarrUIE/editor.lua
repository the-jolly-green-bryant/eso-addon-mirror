ValknarrUIEEditor = ValknarrUIEEditor or {}

local Editor = ValknarrUIEEditor
local ADDON_NAME = "ValknarrUIE"
local ADDON_VERSION = ValknarrUIEVersion or "0.0.0"
local Log = ValknarrUIELog
local Budget = ValknarrUIEBudget
local Platform = ValknarrUIEPlatform
local Adapter = ValknarrUIEPlayerAttributes
local Chat = ValknarrUIEGamepadChat
local Hud = ValknarrUIEHudControls
local Store = ValknarrUIELayoutStore
local Movement = ValknarrUIEMovement
local Grid = ValknarrUIEGrid
local Scene = ValknarrUIEEditorScene
local Radial = ValknarrUIERadial
local SettingsMenu = ValknarrUIESettingsMenu
local Safe = ValknarrUIESafe

local elements = { "health", "magicka", "stamina", "chat" }
local labels = {
    health = "Health",
    magicka = "Magicka",
    stamina = "Stamina",
    chat = "Chat",
}
local PROXY_COLORS = {
    health = { 0.85, 0.15, 0.15, 0.45 },
    magicka = { 0.20, 0.35, 0.95, 0.45 },
    stamina = { 0.20, 0.75, 0.30, 0.45 },
    chat = { 0.12, 0.16, 0.22, 0.72 },
}

-- Cached; LibValknarrUIE:Ids() returns the stable order table (do not mutate).
local function ElementIds()
    local lib = LibValknarrUIE
    if lib and type(lib.Ids) == "function" then
        local ids = lib:Ids()
        if type(ids) == "table" and #ids > 0 then
            return ids
        end
    end
    return elements
end

local function LabelOf(id)
    local lib = LibValknarrUIE
    if lib and type(lib.Label) == "function" then
        local name = lib:Label(id)
        if type(name) == "string" and name ~= "" then
            return name
        end
    end
    return labels[id] or id
end

local AXIS_CYCLE = { "both", "x", "y" }

local function CycleAxis(current)
    for index = 1, #AXIS_CYCLE do
        if AXIS_CYCLE[index] == current then
            return AXIS_CYCLE[(index % #AXIS_CYCLE) + 1]
        end
    end
    return "both"
end

local function AxisLabel(mode)
    if mode == "x" then
        return "X"
    end
    if mode == "y" then
        return "Y"
    end
    return "XY"
end

local function RegistryEntry(id)
    local lib = LibValknarrUIE
    if lib and type(lib.Get) == "function" then
        return lib:Get(id)
    end
    return nil
end

local function CountFound(controls)
    local ids = ElementIds()
    local found = 0
    for _, name in ipairs(ids) do
        if controls and controls[name] then
            found = found + 1
        end
    end
    return found, #ids
end

local function StatusLabel(status)
    if status == "live" then
        return "LIVE"
    end
    if status == "fallback" then
        return "FALLBACK"
    end
    return "MISSING"
end

local function StatusColor(status)
    if status == "live" then
        return 0.45, 0.92, 0.45, 1
    end
    if status == "fallback" then
        return 1, 0.78, 0.28, 1
    end
    return 0.95, 0.38, 0.38, 1
end

local function SafeControlName(id)
    return tostring(id or ""):gsub("[^%w]", "")
end

local function SetLabelFont(control, preferred)
    if Platform and Platform.SetPreferredFont then
        Platform:SetPreferredFont(control, preferred)
        return
    end
    if control and type(control.SetFont) == "function" then
        pcall(control.SetFont, control, preferred or "ZoFontGamepad34")
    end
end

-- Overlay drawing lives in editor_overlay.lua (loaded next). These helpers
-- are assigned onto the editor table so that file can use the same copies.
Editor.ElementIds = ElementIds
Editor.LabelOf = LabelOf
Editor.StatusLabel = StatusLabel
Editor.StatusColor = StatusColor
Editor.CountFound = CountFound
Editor.AxisLabel = AxisLabel
Editor.SafeControlName = SafeControlName
Editor.SetLabelFont = SetLabelFont
Editor.PROXY_COLORS = PROXY_COLORS


function Editor:ApplyPosition(name, control, position)
    local entry = RegistryEntry(name)
    if entry and type(entry.apply) == "function" then
        local ok, applied = pcall(entry.apply, control, position)
        if ok then
            return applied and true or false
        end
        if Log then
            Log:Warn("Custom apply failed for " .. tostring(name) .. ": " .. tostring(applied))
        end
        return false
    end
    return Adapter:Apply(control, position.x, position.y, position.w, position.h)
end

function Editor:Apply(name, reason)
    local position = self.pending and self.pending[name]
    local control = self.controls and self.controls[name]
    if not position then
        return
    end

    self.status = self.status or {}
    local applied = false
    if control then
        applied = self:ApplyPosition(name, control, position)
        self.status[name] = applied and "live" or "fallback"
        if Log and not applied then
            Log:Warn("Native apply failed for " .. name .. " (" .. tostring(reason or "update") .. "); fallback silhouette")
        end
    else
        self.status[name] = "unavailable"
        if Log then
            Log:Warn("No native control for " .. name .. "; fallback silhouette")
        end
    end

    self:InvalidateOverlay()
    if reason and string.sub(tostring(reason), 1, 5) == "move-" and not self.announcedFirstMove then
        self.announcedFirstMove = true
        if Log then
            local status = StatusLabel(self.status and self.status[name])
            Log:Always("Moved " .. LabelOf(name) .. " — catalog should read " .. status .. " if the real bar followed.")
        end
    end
    return applied
end

function Editor:SelectByDelta(delta)
    local current = 1
    for index, name in ipairs(ElementIds()) do
        if name == self.selected then
            current = index
            break
        end
    end
    local ids = ElementIds()
    local count = #ids
    local index = ((current - 1 + delta) % count) + 1
    self.selected = ids[index]
    if Log then
        local status = StatusLabel(self.status and self.status[self.selected])
        Log:Info("Selected " .. LabelOf(self.selected) .. " [" .. status .. "]")
    end
    self:RefreshOverlay()
end

function Editor:SelectNext()
    self:SelectByDelta(1)
end

function Editor:SelectPrevious()
    self:SelectByDelta(-1)
end

function Editor:Nudge(direction, precision)
    if not self.active or not self.pending or not self.selected then
        return
    end
    local usePrecision = precision
    if usePrecision == nil then
        usePrecision = self.precision
    end
    Movement:Move(self.pending[self.selected], direction, usePrecision)
    self.dirty = true
    self:Apply(self.selected, "move-" .. direction)
end

function Editor:Resize(direction, precision)
    if not self.active or not self.pending or not self.selected then
        return
    end
    local usePrecision = precision
    if usePrecision == nil then
        usePrecision = self.precision
    end
    Movement:Resize(self.pending[self.selected], direction, usePrecision)
    self.dirty = true
    self:Apply(self.selected, "resize-" .. direction)
end

function Editor:ToggleCleanPreview()
    self.cleanPreview = not self.cleanPreview
    if Log then
        Log:Info("Clean preview " .. (self.cleanPreview and "ON" or "OFF") .. " (Y or B to leave)")
    end
    self:RefreshOverlay()
    self:ApplyPreviewToKeybinds()
end

function Editor:StartStickPolling()
    if self.stickPolling then
        return
    end
    if not EVENT_MANAGER or type(EVENT_MANAGER.RegisterForUpdate) ~= "function" then
        if Log then
            Log:Warn("Stick polling unavailable; use D-pad to move")
        end
        return
    end
    if Movement and Movement.HasStickApi and not Movement:HasStickApi() then
        if Log then
            Log:Warn("Gamepad stick APIs missing; D-pad still moves")
        end
        return
    end
    self.stickPolling = true
    self.lastStickPollMs = 0
    if Movement and Movement.ResetRepeat then
        Movement:ResetRepeat()
    end
    if Movement and Movement.ResolveClaimApis then
        Movement:ResolveClaimApis()
    end
    -- One per-frame handler: claim sticks every frame, poll move/resize ~50ms.
    -- Avoids a second RegisterForUpdate(0) from Movement:StartFrameClaim.
    if Movement and Movement.StopFrameClaim then
        Movement:StopFrameClaim()
    end
    local ok, err = pcall(
        EVENT_MANAGER.RegisterForUpdate,
        EVENT_MANAGER,
        ADDON_NAME .. "Stick",
        0,
        function()
            if not Editor.active or Editor.ending then
                return
            end
            -- Plain field increment: this runs every frame, so it must not
            -- allocate or call into the engine.
            if Budget then
                Budget.frames = (Budget.frames or 0) + 1
            end
            if Movement and Movement.claimed then
                Movement:HoldClaim()
            end
            local now = 0
            if type(GetFrameTimeMilliseconds) == "function" then
                local tok, value = pcall(GetFrameTimeMilliseconds)
                if tok and type(value) == "number" then
                    now = value
                end
            end
            if now - (Editor.lastStickPollMs or 0) >= 50 then
                Editor.lastStickPollMs = now
                local pollStart = Budget and Budget.Now and Budget:Now()
                Editor:OnStickUpdate()
                if Budget and Budget.RecordPoll then
                    Budget:RecordPoll(pollStart)
                end
            end
        end
    )
    if not ok then
        self.stickPolling = false
        if Log then
            Log:Warn("Stick poll register failed: " .. Log:FormatValue(err))
        end
    elseif Log then
        Log:Debug("Editor tick started (per-frame claim + 50ms stick poll)")
    end
end

function Editor:StopStickPolling()
    if EVENT_MANAGER and type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
        pcall(EVENT_MANAGER.UnregisterForUpdate, EVENT_MANAGER, ADDON_NAME .. "Stick")
    end
    self.stickPolling = false
    if Movement and Movement.ResetRepeat then
        Movement:ResetRepeat()
    end
end

function Editor:EnsureSize(name)
    local pending = self.pending and self.pending[name]
    if not pending then
        return
    end
    if type(pending.w) == "number" and type(pending.h) == "number" and pending.w > 0 and pending.h > 0 then
        return
    end

    local control = self.controls and self.controls[name]
    local live
    if Adapter.GetNormalizedRect then
        live = Adapter:GetNormalizedRect(control)
    end
    if live and live.w and live.h then
        pending.w = live.w
        pending.h = live.h
    else
        local pixelW, pixelH = Adapter:GetControlSize(control)
        local screenW, screenH = Adapter:GetScreenSize()
        if pixelW and pixelH and screenW and screenH and pixelW > 1 and pixelH > 1 then
            pending.w = pixelW / screenW
            pending.h = pixelH / screenH
        else
            local defaults = Store:DefaultFor(name)
            pending.w = (defaults and defaults.w) or 0.16
            pending.h = (defaults and defaults.h) or 0.05
        end
    end
    -- Not snapped here on purpose. Opening the editor must not change
    -- anything; Movement:Resize snaps when the player actually resizes.
end

function Editor:CycleMoveAxis()
    self.moveAxis = CycleAxis(self.moveAxis)
    if Log then
        Log:Always("Move axis = " .. AxisLabel(self.moveAxis) .. " (L3)")
    end
    self:UpdateBanner()
end

function Editor:CycleResizeAxis()
    self.resizeAxis = CycleAxis(self.resizeAxis)
    if Log then
        Log:Always("Resize axis = " .. AxisLabel(self.resizeAxis) .. " (R3)")
    end
    self:UpdateBanner()
end

function Editor:RecoverAfterSceneHide()
    if not self.active or self.ending or self.recovering then
        return
    end
    if Scene and Scene.IsShowing and Scene:IsShowing() then
        return
    end
    self.recovering = true
    if self.root then
        self.root:SetHidden(false)
    end
    if Scene and Scene.DetachEditorRoot then
        Scene:DetachEditorRoot(self.root)
    end
    if Scene and Scene.Show then
        Scene:Show(self.root, true)
    end
    if not self.keybinds then
        self:InstallKeybinds()
    elseif KEYBIND_STRIP and type(KEYBIND_STRIP.UpdateKeybindButtonGroup) == "function" then
        pcall(KEYBIND_STRIP.UpdateKeybindButtonGroup, KEYBIND_STRIP, self.keybinds)
    end
    self:ApplyPreviewToKeybinds()
    if Movement and Movement.ClaimSticks then
        Movement:ClaimSticks(self, self.root or GuiRoot)
    elseif Movement and Movement.HoldClaim then
        Movement:HoldClaim()
    end
    if Chat and Chat.KeepAlive then
        Chat:KeepAlive()
    end
    self:RefreshOverlay()
    self.recovering = false
    if Log then
        Log:Debug("Editor scene restored after unexpected hide")
    end
end

function Editor:OnStickUpdate()
    if not self.active or self.ending then
        return
    end
    -- Overlay visibility only. Stick consume is per-frame on the editor tick.
    -- Do NOT reopen the scene from this poll — that caused the
    -- hide→KEYBIND_STRIP→claim thrash while moving HUD pieces.
    if self.root and type(self.root.IsHidden) == "function" then
        local ok, hidden = pcall(self.root.IsHidden, self.root)
        if ok and hidden then
            self.root:SetHidden(false)
            self:RefreshOverlay()
        end
    end
    if not Movement.PollSticks then
        return
    end
    local moveDir, resizeDir = Movement:PollSticks()
    moveDir = Movement:FilterAxis(moveDir, self.moveAxis)
    resizeDir = Movement:FilterAxis(resizeDir, self.resizeAxis)
    if not moveDir and not resizeDir then
        return
    end
    -- Both sticks can fire on the same poll; one redraw covers both.
    self:BeginBatch()
    if moveDir then
        self:Nudge(moveDir, self.precision)
    end
    if resizeDir then
        self:EnsureSize(self.selected)
        self:Resize(resizeDir, self.precision)
    end
    self:EndBatch()
end

-- Native controls plus any registered by guest add-ons. Four call sites used to
-- repeat this pairing, and one of them passed an empty sources table and threw
-- the result away.
function Editor:LocateAll()
    local controls, sources = Adapter:Locate()
    if LibValknarrUIE and LibValknarrUIE.LocateGuests then
        controls, sources = LibValknarrUIE:LocateGuests(controls, sources)
    end
    return controls, sources
end

function Editor:Relocate()
    local controls, sources = self:LocateAll()
    self.controls = controls
    return controls, sources
end

local function IsEditorActive()
    return Editor.active
end

local function Bind(name, keybind, callback, order, ethereal)
    return {
        name = name,
        keybind = keybind,
        callback = callback,
        enabled = IsEditorActive,
        ethereal = ethereal and true or nil,
        keepEthereal = ethereal and true or nil,
        order = order,
    }
end

function Editor:ApplyPreviewToKeybinds()
    if not self.keybinds then
        return
    end
    local hide = self.cleanPreview and true or false
    for index = 1, #self.keybinds do
        local bind = self.keybinds[index]
        if type(bind) == "table" and bind.keybind then
            if bind.keepEthereal then
                bind.ethereal = true
            else
                bind.ethereal = hide or nil
            end
        end
    end
    if KEYBIND_STRIP and type(KEYBIND_STRIP.UpdateKeybindButtonGroup) == "function" then
        pcall(KEYBIND_STRIP.UpdateKeybindButtonGroup, KEYBIND_STRIP, self.keybinds)
    end
    if KEYBIND_STRIP and type(KEYBIND_STRIP.SetHiddenForReason) == "function" then
        pcall(KEYBIND_STRIP.SetHiddenForReason, KEYBIND_STRIP, ADDON_NAME .. "Preview", hide)
    end
    if Scene and Scene.SetKeybindChromeVisible then
        Scene:SetKeybindChromeVisible(not hide)
    end
end

-- Visible strip: tab between HUD pieces, save, exit. Shoulders match ESO
-- inventory tabs; triggers are the same action (hidden) in case one pair is
-- eaten by the scene. Some scenes reject the trigger binds outright, so
-- InstallKeybinds retries with includeTriggers false.
local function BuildKeybinds(includeTriggers)
    local function dpad(direction)
        return function()
            Editor:Nudge(direction, Editor.precision)
        end
    end

    local binds = {
        alignment = KEYBIND_STRIP_ALIGN_CENTER or KEYBIND_STRIP_ALIGN_LEFT or 1,
        Bind("Previous", "UI_SHORTCUT_LEFT_SHOULDER", function()
            Editor:SelectPrevious()
        end, 100),
        Bind("Next", "UI_SHORTCUT_RIGHT_SHOULDER", function()
            Editor:SelectNext()
        end, 101),
        Bind("Save", "UI_SHORTCUT_PRIMARY", function()
            Editor:Save()
        end, 200),
        Bind("Exit", "UI_SHORTCUT_NEGATIVE", function()
            Editor:Cancel()
        end, 201),
        Bind("Precision", "UI_SHORTCUT_SECONDARY", function()
            Editor.precision = not Editor.precision
            if Log then
                Log:Info("Precision " .. (Editor.precision and "ON" or "OFF"))
            end
            Editor:UpdateBanner()
        end, 202),
        Bind("Preview", "UI_SHORTCUT_TERTIARY", function()
            Editor:ToggleCleanPreview()
        end, 203),
        Bind("Move left", "UI_SHORTCUT_LEFT", dpad("left"), 300, true),
        Bind("Move right", "UI_SHORTCUT_RIGHT", dpad("right"), 301, true),
        Bind("Move up", "UI_SHORTCUT_UP", dpad("up"), 302, true),
        Bind("Move down", "UI_SHORTCUT_DOWN", dpad("down"), 303, true),
        Bind("Move axis", "UI_SHORTCUT_LEFT_STICK", function()
            Editor:CycleMoveAxis()
        end, 310, true),
        Bind("Size axis", "UI_SHORTCUT_RIGHT_STICK", function()
            Editor:CycleResizeAxis()
        end, 311, true),
    }

    if includeTriggers then
        binds[#binds + 1] = Bind("Previous", "UI_SHORTCUT_LEFT_TRIGGER", function()
            Editor:SelectPrevious()
        end, 110, true)
        binds[#binds + 1] = Bind("Next", "UI_SHORTCUT_RIGHT_TRIGGER", function()
            Editor:SelectNext()
        end, 111, true)
    end

    return binds
end

function Editor:InstallKeybinds()
    if self.keybinds then
        return
    end
    if not KEYBIND_STRIP or type(KEYBIND_STRIP.AddKeybindButtonGroup) ~= "function" then
        if Log then
            Log:Warn("KEYBIND_STRIP unavailable; use slash commands only")
        end
        return
    end

    self.keybinds = BuildKeybinds(true)
    local ok, err = pcall(KEYBIND_STRIP.AddKeybindButtonGroup, KEYBIND_STRIP, self.keybinds)
    if not ok then
        if Log then
            Log:Warn("Keybind strip with triggers failed: " .. Log:FormatValue(err) .. " — retrying without triggers")
        end
        self.keybinds = BuildKeybinds(false)
        ok, err = pcall(KEYBIND_STRIP.AddKeybindButtonGroup, KEYBIND_STRIP, self.keybinds)
    end
    if ok and type(KEYBIND_STRIP.UpdateKeybindButtonGroup) == "function" then
        pcall(KEYBIND_STRIP.UpdateKeybindButtonGroup, KEYBIND_STRIP, self.keybinds)
    end
    if ok then
        self:ApplyPreviewToKeybinds()
    end
    if Log then
        if ok then
            Log:Info("Keybind strip installed (A save, B exit, bumpers/triggers cycle)")
        else
            Log:Warn("Keybind strip install failed: " .. Log:FormatValue(err))
            self.keybinds = nil
        end
    elseif not ok then
        self.keybinds = nil
    end
end

function Editor:RemoveKeybinds()
    if KEYBIND_STRIP and type(KEYBIND_STRIP.SetHiddenForReason) == "function" then
        pcall(KEYBIND_STRIP.SetHiddenForReason, KEYBIND_STRIP, ADDON_NAME .. "Preview", false)
    end
    if self.keybinds and KEYBIND_STRIP and type(KEYBIND_STRIP.RemoveKeybindButtonGroup) == "function" then
        local ok, err = pcall(KEYBIND_STRIP.RemoveKeybindButtonGroup, KEYBIND_STRIP, self.keybinds)
        if Log then
            if ok then
                Log:Debug("Keybind strip removed")
            else
                Log:Warn("Keybind strip remove failed: " .. Log:FormatValue(err))
            end
        end
    end
    self.keybinds = nil
end

function Editor:SuspendInput()
    self:StopStickPolling()
    self:RemoveKeybinds()
end

function Editor:ResumeInput()
    if not self.active then
        return
    end
    self:InstallKeybinds()
    self:StartStickPolling()
end

function Editor:BuildPendingFromLive(snapToGrid)
    local pending = {}
    for _, name in ipairs(ElementIds()) do
        local live
        if Adapter.GetNormalizedRect then
            live = Adapter:GetNormalizedRect(self.controls[name])
        else
            live = Adapter:GetNormalizedCenter(self.controls[name])
        end
        if live then
            if not live.w or not live.h then
                local defaults = Store:DefaultFor(name)
                live.w = live.w or (defaults and defaults.w)
                live.h = live.h or (defaults and defaults.h)
            end
            -- Do not snap on open — that would rewrite native anchors before Save.
            -- Movement/Resize snap when the player actually nudges. When a
            -- caller does ask for a snap, normalize size too: a measured pixel
            -- size is never a grid multiple.
            if snapToGrid and Grid and Grid.SnapRect then
                Grid:SnapRect(live, false)
            elseif snapToGrid and Grid and Grid.Snap then
                Grid:Snap(live, false)
            end
            pending[name] = live
            if Log then
                Log:Debug(string.format(
                    "Live %s = %.3f, %.3f w=%.3f h=%.3f",
                    name,
                    live.x,
                    live.y,
                    live.w or 0,
                    live.h or 0
                ))
            end
        else
            pending[name] = Store:DefaultFor(name)
            if Log then
                Log:Warn("No live position for " .. name .. "; using default")
            end
        end
    end
    return pending
end

function Editor:RunPreviewHooks(phase)
    for _, name in ipairs(ElementIds()) do
        local entry = RegistryEntry(name)
        local fn = entry and entry[phase]
        if type(fn) == "function" then
            local ok, err = pcall(fn)
            if not ok and Log then
                Log:Warn(phase .. " failed for " .. name .. ": " .. tostring(err))
            end
        end
    end
end

function Editor:Begin()
    if SettingsMenu and SettingsMenu.active then
        SettingsMenu:Hide()
    end
    if self.active then
        if Log then
            Log:Info("/uiedit while active — cancelling")
        end
        self:Cancel()
        return
    end

    -- Clear leftover End() state so a reopen within ~750ms is a clean session.
    self.ending = false
    if Movement and Movement.BumpClaimGeneration then
        Movement:BumpClaimGeneration()
    end
    -- Per-session counters, so /uiedit budget describes this edit rather than
    -- everything since login.
    if Budget and Budget.Reset then
        Budget:Reset()
    end

    if Log then
        Log:SetHudVisible(Store and Store.GetSetting and Store:GetSetting("showDebugLog"))
        Log:Info("Entering edit mode (v" .. ADDON_VERSION .. ")")
        Log:Dump("Environment", Adapter:DescribeEnvironment())
    end

    local sources
    self.controls, sources = self:Relocate()
    local found, total = CountFound(self.controls)
    if Log then
        Log:Info("Native controls located: " .. found .. "/" .. total)
        if sources then
            Log:Dump("Control sources", sources)
        end
        for _, name in ipairs(ElementIds()) do
            if self.controls[name] then
                Log:Debug(name .. " anchors: " .. Adapter:DescribeAnchors(self.controls[name]))
            end
        end
    end

    self.nativeAnchors = {}
    self.status = {}
    for _, name in ipairs(ElementIds()) do
        self.nativeAnchors[name] = Adapter:Capture(self.controls[name])
        self.status[name] = self.controls[name] and "fallback" or "unavailable"
    end

    local hadSaved = Store:HasUserLayout()
    if hadSaved then
        self.pending = Store:Load()
        if Log then
            Log:Info("Loaded saved layout")
            Log:Dump("Pending", self.pending)
        end
    else
        self.pending = self:BuildPendingFromLive()
        if Log then
            Log:Info("No saved layout — starting from live HUD positions")
        end
    end

    self.previousForceVisibility = Adapter:GetForceVisibility()
    self.selected = ElementIds()[1] or "health"
    self.precision = false
    self.moveAxis = "both"
    self.resizeAxis = "both"
    self.cleanPreview = false
    self.announcedFirstMove = false
    self.dirty = false
    self.recoverScheduled = false
    self.recovering = false
    self.session = (self.session or 0) + 1
    local session = self.session
    self.active = true

    Adapter:ForceVisible(true)
    self:CreateOverlay()
    if self.root then
        self.root:SetHidden(false)
    end

    Scene.onHidden = function()
        if not Editor.active or Editor.ending or Editor.session ~= session then
            return
        end
        -- Long debounce. Stick leak used to dismiss the scene every few
        -- hundred ms; reopening immediately created the claim thrash.
        if Editor.recoverScheduled then
            return
        end
        Editor.recoverScheduled = true
        local function restore()
            Editor.recoverScheduled = false
            if not Editor.active or Editor.ending or Editor.session ~= session then
                return
            end
            Editor:RecoverAfterSceneHide()
        end
        if type(zo_callLater) == "function" then
            zo_callLater(restore, 1000)
        else
            restore()
        end
    end
    local sceneShown = Scene:Show(self.root)
    self.sceneActive = sceneShown
    if self.root then
        self.root:SetHidden(false)
    end
    if Log and not sceneShown then
        Log:Warn("Scene push unavailable; HUD-adjacent overlay mode")
    end

    -- Pin chat after the editor scene (HUD_FRAGMENT) is showing so Maximize
    -- is not immediately hidden by IsHidden(). Capture already happened.
    self:RunPreviewHooks("preparePreview")
    if LibValknarrUIE and LibValknarrUIE.LocateGuests then
        self.controls, sources = LibValknarrUIE:LocateGuests(self.controls, sources)
    end
    for _, name in ipairs(ElementIds()) do
        if self.controls[name] and not self.nativeAnchors[name] then
            self.nativeAnchors[name] = Adapter:Capture(self.controls[name])
            self.status[name] = "fallback"
        end
    end
    if not hadSaved then
        self.pending = self:BuildPendingFromLive()
    else
        -- New HUD ids (action bar, compass, …) must start from live, not
        -- invented defaults, or a 0.5.0 save would teleport them on first open.
        local live = self:BuildPendingFromLive()
        self.pending = self.pending or {}
        for _, name in ipairs(ElementIds()) do
            if self.pending[name] == nil then
                self.pending[name] = live[name]
            end
        end
    end
    found, total = CountFound(self.controls)

    self:InstallKeybinds()
    self:StartStickPolling()
    if Movement and Movement.ClaimSticks then
        Movement:ClaimSticks(self, self.root or GuiRoot)
    end

    if hadSaved then
        self:BeginBatch()
        for _, name in ipairs(ElementIds()) do
            self:Apply(name, "load-saved")
        end
        self:EndBatch()
    else
        -- Nothing changes until the player moves or presses A.
        -- Pending mirrors live centers for the overlay; natives stay put.
        for _, name in ipairs(ElementIds()) do
            if self.controls[name] then
                self.status[name] = "live"
            end
        end
        self:RefreshOverlay()
    end

    if Log then
        Log:Always("Editor open. Left stick moves. Right stick resizes (width / height).")
        Log:Always("Click L3 / R3 to lock move or resize to X, Y, or both. Y hides buttons. A saves. B exits.")
        if found == 0 then
            Log:Warn("No native controls found — silhouettes still move for UX validation.")
        elseif found < total then
            Log:Warn("Only " .. found .. "/" .. total .. " native controls found — check /uiedit diag")
        end
    end
end

function Editor:End()
    if self.ending then
        return
    end
    self.ending = true
    self.session = (self.session or 0) + 1
    local endSession = self.session
    self.recoverScheduled = false
    self.recovering = false
    -- Drop active before Scene:Hide. Hide fires camera-UI events that used
    -- to HoldClaim again while active was still true (left stick stuck).
    self.active = false
    if Scene then
        Scene.onHidden = nil
    end
    self:StopStickPolling()
    if Movement and Movement.ForceRelease then
        Movement:ForceRelease(self)
    elseif Movement and Movement.ReleaseSticks then
        Movement:ReleaseSticks(self)
    end
    self:RemoveKeybinds()
    -- Do not SetKeybindChromeVisible(true) here: adding KEYBIND_STRIP
    -- backdrop while closing re-enters UI mode and can leave sticks dead.
    if self.root then
        self.root:SetHidden(true)
    end
    self:SetChromeVisible(false)
    for _, proxy in pairs(self.proxies or {}) do
        proxy:SetHidden(true)
    end
    Grid:SetVisible(false)
    self:RunPreviewHooks("endPreview")
    Adapter:ForceVisible(self.previousForceVisibility == true)
    if self.sceneActive then
        Scene:Hide()
    end
    self.sceneActive = false

    local function finishGameplay()
        -- Skip if a newer Begin()/Cancel()/End() invalidated this close.
        if Editor.session ~= endSession or Editor.active then
            return
        end
        if Scene and Scene.ReturnToGame then
            Scene:ReturnToGame()
        end
        if Movement and Movement.ForceRelease then
            -- Only if claimGeneration still matches the deferred release epoch.
            Movement:ForceRelease(self)
        end
    end

    if Movement and Movement.ReleaseSticksDeferred then
        Movement:ReleaseSticksDeferred(self)
    elseif Movement and Movement.ForceRelease then
        Movement:ForceRelease(self)
    end

    -- Hide finishes over several frames; Show(hud) + stick release after that.
    if type(zo_callLater) == "function" then
        zo_callLater(finishGameplay, 30)
        zo_callLater(function()
            finishGameplay()
        end, 200)
        zo_callLater(function()
            if Editor.session ~= endSession then
                return
            end
            if not Editor.active and Movement and Movement.ForceRelease then
                Movement:ForceRelease(self)
            end
            if Editor.session == endSession then
                self.ending = false
            end
        end, 750)
    else
        finishGameplay()
        self.ending = false
    end
    if Log then
        Log:Info("Edit mode closed")
    end
end

function Editor:Save()
    if not self.active then
        if Log then
            Log:Warn("Save ignored — editor not active")
        end
        return
    end
    local ok = Store:Save(self.pending)
    if not ok then
        -- Closing here would drop the layout the player just built with no way
        -- to retry. Stay open and let them press A again or B to back out.
        if Log then
            Log:Always("Save failed — layout kept in the editor. A retries, B exits without saving.")
        end
        return false
    end
    if Log then
        Log:Always("Layout saved. It will reapply after reload or zoning.")
    end
    self:End()
    return true
end

function Editor:Cancel()
    if self.ending then
        return
    end
    if not self.active then
        if Movement and Movement.ReleaseSticksDeferred then
            Movement:ReleaseSticksDeferred(self)
        elseif Movement and Movement.ForceRelease then
            Movement:ForceRelease(self)
        end
        return
    end
    -- B is Exit and scene Back. Kill input before restoring anchors so a
    -- mid-cancel scene hide cannot ClaimSticks again.
    self.session = (self.session or 0) + 1
    self.active = false
    if Scene then
        Scene.onHidden = nil
    end
    self:StopStickPolling()
    if Movement and Movement.ForceRelease then
        Movement:ForceRelease(self)
    elseif Movement and Movement.ReleaseSticks then
        Movement:ReleaseSticks(self)
    end
    -- Only restore native anchors if the player moved/resized something.
    -- Restoring after a no-op open makes the action bar jump for no reason.
    if self.dirty then
        for _, name in ipairs(ElementIds()) do
            Adapter:Restore(self.controls[name], self.nativeAnchors[name])
        end
        if Log then
            Log:Always("Cancelled — native anchors restored, nothing saved.")
        end
    elseif Log then
        Log:Always("Cancelled — nothing moved, nothing saved.")
    end
    self:End()
end

function Editor:ResetToDefaults()
    if not self.active then
        return
    end
    -- Session-only until Save: do not Clear SavedVars here. B restores natives
    -- and keeps the previous save; A writes the defaults.
    self.pending = Store:Reset()
    self.dirty = true
    self:BeginBatch()
    for _, name in ipairs(ElementIds()) do
        self:Apply(name, "reset-defaults")
    end
    self:EndBatch()
    if Log then
        Log:Always("Previewing default layout (not saved yet). A saves, B restores.")
    end
    self:RefreshOverlay()
end

function Editor:Reset()
    self:ResetToDefaults()
end

function Editor:Diagnose()
    if Log then
        Log:SetHudVisible(true)
        Log:ClearHud()
        Log:Always("Running /uiedit diag")
        Log:Dump("Environment", Adapter:DescribeEnvironment())
    end
    local controls, sources = self:LocateAll()
    if Log then
        local found, total = CountFound(controls)
        Log:Info("Controls found: " .. found .. "/" .. total)
        Log:Dump("Sources", sources)
        Log:Dump("Settings", Store:DescribeSettings())
        if Chat and Chat.Describe then
            Log:Dump("Gamepad chat", Chat:Describe())
        end
        if LibValknarrUIE and LibValknarrUIE.Count then
            Log:Info("LibValknarrUIE registered elements: " .. tostring(LibValknarrUIE:Count()))
        end
        Log:Dump("SavedVars", {
            initialized = Store.saved ~= nil,
            hasUserLayout = Store:HasUserLayout(),
        })
        if Store:HasUserLayout() then
            Log:Dump("Saved elements", Store:Load())
        end
        for _, name in ipairs(ElementIds()) do
            local live
            if Adapter.GetNormalizedRect then
                live = Adapter:GetNormalizedRect(controls[name])
            else
                live = Adapter:GetNormalizedCenter(controls[name])
            end
            if live then
                Log:Debug(string.format(
                    "Live %s center = %.3f, %.3f w=%.3f h=%.3f",
                    name,
                    live.x,
                    live.y,
                    live.w or 0,
                    live.h or 0
                ))
            else
                Log:Warn("Live center unavailable for " .. name)
            end
            if controls[name] then
                Log:Info(name .. " anchors: " .. Adapter:DescribeAnchors(controls[name]))
            end
        end
        if _G.ACTION_BAR then
            Log:Info("ACTION_BAR present")
            Log:Debug("ACTION_BAR anchors: " .. Adapter:DescribeAnchors(_G.ACTION_BAR))
        else
            Log:Debug("ACTION_BAR global not present")
        end
        Log:Dump("Budget", Budget and Budget.Describe and Budget:Describe())
        Log:Always("Diag complete — debug HUD is on. /uiedit log hud off to hide it.")
    end
    self:ShowBudget()
end

function Editor:ShowBudget()
    if not Log then
        return
    end
    if not Budget or not Budget.Report then
        Log:Always("Budget instrumentation unavailable")
        return
    end
    Budget:Report(Log)
end

function Editor:ShowHelp()
    if not Log then
        return
    end
    Log:Always("Valknarr UI v" .. ADDON_VERSION)
    Log:Always("/uiedit              toggle editor")
    Log:Always("/uiedit diag         dump diagnostics (shows log HUD)")
    Log:Always("/uiedit budget       memory, control count, and editor timing")
    Log:Always("/uiedit log on|off   verbose chat logging")
    Log:Always("/uiedit log hud      show on-canvas log HUD")
    Log:Always("/uiedit log hud off  hide on-canvas log HUD")
    Log:Always("/uiedit settings     open the config panel (invert stick, etc.)")
    Log:Always("/uiedit invert       toggle invert stick up/down")
    Log:Always("/uiedit preview      toggle clean preview (if editor is open)")
    Log:Always("/uiedit reset        default layout (editor must be open)")
    Log:Always("/uiedit help         this help")
    Log:Always("In editor: LS moves, RS resizes, L3/R3 lock axis, Y hides buttons, A saves, B exits")
end

local function TrimArgs(args)
    local text = tostring(args or "")
    if type(zo_strtrim) == "function" then
        return zo_strtrim(text)
    end
    return text:match("^%s*(.-)%s*$") or text
end

function Editor:HandleSlash(args)
    local text = TrimArgs(args)
    local command = string.lower(text)
    if command == "" then
        self:Begin()
        return
    end
    if command == "help" or command == "?" then
        self:ShowHelp()
        return
    end
    if command == "diag" or command == "debug" or command == "status" then
        self:Diagnose()
        return
    end
    if command == "budget" or command == "memory" or command == "perf" then
        self:ShowBudget()
        return
    end
    if command == "log on" or command == "logon" then
        Store:SetSetting("showDebugLog", true)
        if Log.ApplyFromStore then
            Log:ApplyFromStore(false)
        else
            Log:SetEnabled(true)
        end
        return
    end
    if command == "log off" or command == "logoff" then
        Store:SetSetting("showDebugLog", false)
        if Log.ApplyFromStore then
            Log:ApplyFromStore(false)
        else
            Log:SetEnabled(false)
        end
        return
    end
    if command == "log hud" or command == "loghud" then
        Store:SetSetting("showDebugLog", true)
        if Log.ApplyFromStore then
            Log:ApplyFromStore(false)
        else
            Log:SetEnabled(true)
            Log:SetHudVisible(true)
        end
        Log:Always("On-canvas log HUD shown")
        return
    end
    if command == "log hud off" or command == "loghudoff" then
        Log:SetHudVisible(false)
        Log:Always("On-canvas log HUD hidden")
        return
    end
    if command == "preview" or command == "clean" then
        if self.active then
            self:ToggleCleanPreview()
        elseif Log then
            Log:Warn("Open /uiedit first, then toggle clean preview")
        end
        return
    end
    if command == "reset" or command == "defaults" then
        if self.active then
            self:ResetToDefaults()
        elseif Log then
            Log:Warn("Open /uiedit first, then /uiedit reset")
        end
        return
    end
    if command == "settings" or command == "config" or command == "options" then
        if SettingsMenu and SettingsMenu.Show then
            SettingsMenu:Show()
        end
        return
    end
    if command == "invert" or command == "invert y" or command == "inverty" then
        local on = Store:ToggleSetting("invertStickY")
        if Log then
            Log:Always("Invert stick up/down = " .. (on and "ON" or "OFF") .. " (saved)")
        end
        if SettingsMenu and SettingsMenu.active and SettingsMenu.Refresh then
            SettingsMenu:Refresh()
        end
        return
    end
    if command == "invert x" or command == "invertx" then
        local on = Store:ToggleSetting("invertStickX")
        if Log then
            Log:Always("Invert stick left/right = " .. (on and "ON" or "OFF") .. " (saved)")
        end
        if SettingsMenu and SettingsMenu.active and SettingsMenu.Refresh then
            SettingsMenu:Refresh()
        end
        return
    end
    if Log then
        Log:Warn("Unknown /uiedit args: " .. text)
    end
    self:ShowHelp()
end

function Editor:RegisterBuiltins()
    local lib = LibValknarrUIE
    if not lib or type(lib.RegisterElement) ~= "function" then
        return
    end
    lib:RegisterAddon(ADDON_NAME, "Valknarr UI")
    local builtins = {
        { id = "health", name = "Health", x = 0.50, y = 0.86 },
        { id = "magicka", name = "Magicka", x = 0.38, y = 0.82 },
        { id = "stamina", name = "Stamina", x = 0.62, y = 0.82 },
    }
    for index = 1, #builtins do
        local item = builtins[index]
        lib:RegisterElement(ADDON_NAME, item.id, {
            name = item.name,
            locate = function()
                return Adapter:Find(item.id)
            end,
            resizable = true,
            default = { x = item.x, y = item.y },
        })
    end
    lib:RegisterElement(ADDON_NAME, "chat", {
        name = "Chat",
        resizable = true,
        locate = function()
            if Chat and Chat.Find then
                return Chat:Find()
            end
            return nil, "missing"
        end,
        apply = function(control, position)
            if Chat and Chat.Apply then
                return Chat:Apply(control, position)
            end
            return Adapter:Apply(control, position.x, position.y, position.w, position.h)
        end,
        preparePreview = function()
            if Chat and Chat.PinOpen then
                Chat:PinOpen()
            end
        end,
        endPreview = function()
            if Chat and Chat.Unpin then
                Chat:Unpin()
            end
        end,
        default = { x = 0.872, y = 0.671, w = 490 / 1920, h = 280 / 1080 },
    })
    if Hud and Hud.Register then
        Hud:Register(lib, ADDON_NAME)
    end
end

function Editor:Initialize()
    if Log then
        local mode = (Platform and Platform.ModeLabel and Platform:ModeLabel()) or "?"
        Log:Always("Valknarr UI v" .. ADDON_VERSION .. " loaded (" .. mode .. ")")
        Log:Always("Smoke test: /uiedit diag   then   /uiedit")
        Log:Always("LIVE in the catalog means the real HUD piece moved. LB/RB cycles bars, chat, action bar, compass, …")
        Log:Always("Install LibAddonMenu-2.0. Config: /uiedit settings or Add-On Settings.")
    end
    Store:Initialize()
    if Log and Log.ApplyFromStore then
        Log:ApplyFromStore(true)
    end
    self:RegisterBuiltins()
    if Chat and Chat.Initialize then
        Chat:Initialize()
    end
    if Chat then
        Chat.onReset = function(reason)
            if Editor.active then
                Editor:Apply("chat", reason or "chat-reset")
            else
                Editor:ReapplySavedLayout(reason or "chat-reset")
            end
        end
    end
    if SettingsMenu and SettingsMenu.RegisterLibraries then
        SettingsMenu:RegisterLibraries()
    end
    SLASH_COMMANDS = SLASH_COMMANDS or {}
    SLASH_COMMANDS["/uiedit"] = function(args)
        Editor:HandleSlash(args)
    end
    if Radial and Radial.TryRegister then
        local registered = Radial:TryRegister(function()
            Editor:Begin()
        end)
        if registered and Log then
            Log:Always("LibRadialMenu: assign Open editor on the utility wheel if you use it.")
        end
    end
    self:RegisterEvents()
end

function Editor:ReapplySavedLayout(reason)
    if self.active then
        return
    end
    if not Store:HasUserLayout() then
        return
    end
    self:Relocate()
    local pending = Store:Load()
    local applied = 0
    local ids = ElementIds()
    for _, name in ipairs(ids) do
        local position = pending and pending[name]
        local control = self.controls and self.controls[name]
        if position and control and Editor:ApplyPosition(name, control, position) then
            applied = applied + 1
        end
    end
    if Log then
        Log:Info("Reapplied saved layout (" .. tostring(reason or "event") .. ") " .. applied .. "/" .. #ids)
    end
end

function Editor:RegisterEvents()
    if not EVENT_MANAGER then
        if Log then
            Log:Warn("EVENT_MANAGER missing; reapply hooks not registered")
        end
        return
    end

    local function AfterDelay(callback)
        if type(zo_callLater) == "function" then
            zo_callLater(callback, 250)
        else
            callback()
        end
    end

    -- Activation and resize need the same treatment: controls may have been
    -- recreated, so relocate them and put the layout back.
    local function OnRelocateEvent(reason)
        AfterDelay(function()
            if not Editor.active then
                Editor:ReapplySavedLayout(reason)
                return
            end
            if Log then
                Log:Debug("Reapply after " .. reason)
            end
            Editor:Relocate()
            local width, height = Adapter:GetScreenSize()
            Grid:LayoutLines(width, height)
            Editor:BeginBatch()
            for _, name in ipairs(ElementIds()) do
                Editor:Apply(name, "reapply-event")
            end
            Editor:EndBatch()
        end)
    end

    if EVENT_PLAYER_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Activated", EVENT_PLAYER_ACTIVATED, function()
            OnRelocateEvent("player-activated")
        end)
    end
    if EVENT_SCREEN_RESIZED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Resized", EVENT_SCREEN_RESIZED, function()
            OnRelocateEvent("screen-resized")
        end)
    end
    local function OnCameraUi()
        if Editor.active and not Editor.ending and Movement and Movement.HoldClaim then
            Movement:HoldClaim()
        end
    end
    if EVENT_GAME_CAMERA_UI_MODE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "CameraUI", EVENT_GAME_CAMERA_UI_MODE_CHANGED, OnCameraUi)
    end
    if EVENT_GAME_CAMERA_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "CameraOn", EVENT_GAME_CAMERA_ACTIVATED, OnCameraUi)
    end
    if Log then
        Log:Debug("Event hooks registered")
    end
end

local function OnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    Editor:Initialize()
end

if EVENT_MANAGER and EVENT_ADD_ON_LOADED then
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnLoaded)
end
