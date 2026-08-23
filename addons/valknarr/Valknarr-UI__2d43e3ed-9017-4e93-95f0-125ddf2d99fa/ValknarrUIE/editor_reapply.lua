-- Saved-layout reapply and native HUD reset hooks. Session Begin/End and
-- stick claim stay in editor.lua — every guard there is console-learned.
-- Methods hang off the same ValknarrUIEEditor table.

ValknarrUIEEditor = ValknarrUIEEditor or {}

local Editor = ValknarrUIEEditor
local ADDON_NAME = Editor.ADDON_NAME or "ValknarrUIE"
local Log = ValknarrUIELog
local Adapter = ValknarrUIEPlayerAttributes
local Store = ValknarrUIELayoutStore
local Movement = ValknarrUIEMovement
local Grid = ValknarrUIEGrid
local ElementIds = Editor.ElementIds

-- Native HUD fade is 250ms. Death hides PLAYER_ATTRIBUTE_BARS_FRAGMENT;
-- zoning and inventory both hide/show the HUD after that. One delayed
-- apply on PLAYER_ACTIVATED is too early and never runs on resurrect.
-- Retry after the fade so we win the race with XML template re-anchors.
local REAPPLY_DELAYS_MS = { 500, 1200 }

function Editor:ApplyPendingLayout(reason)
    self:Relocate()
    local width, height = Adapter:GetScreenSize()
    if Grid and Grid.LayoutLines then
        Grid:LayoutLines(width, height)
    end
    self:BeginBatch()
    for _, name in ipairs(ElementIds()) do
        self:Apply(name, reason or "reapply-event")
    end
    self:EndBatch()
end

function Editor:ReapplySavedLayout(reason)
    if self.active then
        return 0
    end
    if not Store:HasUserLayout() then
        return 0
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
    return applied
end

function Editor:ReapplyElement(name, reason)
    if self.ending then
        return false
    end
    if self.active then
        return self:Apply(name, reason or "element") and true or false
    end
    if not Store or not Store.HasUserLayout or not Store:HasUserLayout() then
        return false
    end
    if not self.controls or not self.controls[name] then
        self:Relocate()
    end
    local pending = Store:Load()
    local position = pending and pending[name]
    local control = self.controls and self.controls[name]
    if not position or not control then
        return false
    end
    local applied = self:ApplyPosition(name, control, position)
    if Log and applied then
        Log:Debug("Reapplied " .. tostring(name) .. " (" .. tostring(reason or "event") .. ")")
    end
    return applied and true or false
end

-- HUD fragments can SetGamepadLeftStickConsumedByUI(true) after FinishExit
-- (ending is already false, hudUnlockFrames may already be 0). Keep
-- unconsuming from camera / HUD / action-layer handlers until Begin.
-- Not fragment-shown: that would SetInUIMode(false) on inventory, etc.
local POST_CLOSE_UNLOCK_REASONS = {
    ["hud-scene"] = true,
    ["hudui-scene"] = true,
    ["action-layer"] = true,
}

local HUD_SCENE_NAMES = {
    hud = true,
    hudui = true,
}
-- Menu hide, HUD SHOWING, HUD SHOWN, and HUD_UI can all fire on one ESC.
-- One pin, no 500/1200 retries — those were the hitch.
local MENU_EXIT_DEBOUNCE_MS = 750

local function SceneNameOf(scene)
    if not scene then
        return nil
    end
    if type(scene) == "string" then
        return string.lower(scene)
    end
    if type(scene.GetName) == "function" then
        local ok, name = pcall(scene.GetName, scene)
        if ok and type(name) == "string" and name ~= "" then
            return string.lower(name)
        end
    end
    return nil
end

function Editor:PreviousSceneName()
    local manager = SCENE_MANAGER
    if not manager then
        return nil
    end
    local scene
    if type(manager.GetPreviousScene) == "function" then
        local ok, value = pcall(manager.GetPreviousScene, manager)
        if ok then
            scene = value
        end
    end
    if scene == nil then
        scene = manager.previousScene
    end
    return SceneNameOf(scene)
end

-- HUD_SCENE SHOWING also fires while walking. Only re-pin when coming back
-- from a real menu (ESC / gamepad menu / map), not from hud <-> hudui.
function Editor:PinOnceAfterMenu(reason)
    if self.active or self.ending or self.finishingExit then
        return false
    end
    local now = 0
    if type(GetGameTimeMilliseconds) == "function" then
        local ok, value = pcall(GetGameTimeMilliseconds)
        if ok and type(value) == "number" then
            now = value
        end
    end
    local last = self.lastMenuExitReapplyMs
    if last ~= nil and (now - last) < MENU_EXIT_DEBOUNCE_MS then
        return false
    end
    self.lastMenuExitReapplyMs = now
    self:ReapplySavedLayout(reason or "menu-exit")
    return true
end

function Editor:TryReapplyAfterMenu()
    if self.active or self.ending or self.finishingExit then
        return false
    end
    local previous = self:PreviousSceneName()
    if not previous or HUD_SCENE_NAMES[previous] then
        return false
    end
    return self:PinOnceAfterMenu("menu-exit")
end

function Editor:TryPostCloseUnlock()
    if not self.postCloseUnlock then
        return false
    end
    if self.active or self.ending or self.finishingExit then
        return false
    end
    if Movement and Movement.claimed and Movement.claimed ~= self then
        return false
    end
    if Movement and Movement.UnconsumeHudSticks then
        Movement:UnconsumeHudSticks()
        return true
    end
    return false
end

function Editor:OnCameraUiEvent()
    if self.finishingExit then
        return
    end
    if self.ending then
        if Log then
            Log:Debug("CameraUI during close — try finish exit")
            Editor:DebugSnapshot("camera-ui")
        end
        self:TryFinishExit(self.session, true)
        return
    end
    if self.active and Movement and Movement.HoldClaim then
        Movement:HoldClaim()
        return
    end
    self:TryPostCloseUnlock()
end

-- HUD / action-layer events fire in a real event handler, which is the
-- context SetGamepadLeftStickConsumedByUI needs. A no-op A/B never gets
-- HUD_SCENE SHOWN (HUD fragments stayed visible in the editor scene), so
-- EVENT_ACTION_LAYER_POPPED / camera UI is the unlock. Only reapply layout
-- once teardown is done.
function Editor:OnGameplayRestored(reason)
    if self.finishingExit then
        return
    end
    if self.ending then
        if Log then
            Log:Debug("GameplayRestored during close (" .. tostring(reason or "event") .. ") — try finish exit")
            Editor:DebugSnapshot("gameplay-restored")
        end
        self:TryFinishExit(self.session, true)
        return
    end
    if POST_CLOSE_UNLOCK_REASONS[tostring(reason or "")] then
        self:TryPostCloseUnlock()
    end
    -- Noisy while moving or fighting: fragment show, HUD scenes, subzone
    -- ZONE_CHANGED. Death / editor-close / leaving a menu still reapply.
    local label = tostring(reason or "")
    if label == "action-layer" or label == "fragment-shown" or label == "hudui-scene" or label == "hud-scene" or label == "zone-changed" then
        return
    end
    self:ScheduleReapply(reason or "hud-shown")
end

function Editor:ScheduleReapply(reason)
    -- Teardown still owns the sticks. Re-anchoring HUD in the middle of
    -- HideCurrentScene is how a no-op A/B leaves the left stick consumed.
    if self.ending then
        if Log then
            Log:Debug("ScheduleReapply skipped while ending (" .. tostring(reason or "event") .. ")")
        end
        return
    end
    self.reapplyGeneration = (self.reapplyGeneration or 0) + 1
    local generation = self.reapplyGeneration
    local label = reason or "event"

    local function run()
        if Editor.reapplyGeneration ~= generation then
            return
        end
        if Editor.active then
            if Log then
                Log:Debug("Reapply after " .. label)
            end
            Editor:ApplyPendingLayout("reapply-event")
            return
        end
        Editor:ReapplySavedLayout(label)
    end

    -- Run now, in the event / native-hook stack. zo_callLater is not a
    -- protected-attribute context, so a delay-only path can silently skip
    -- SetAnchor and leave the HUD on XML defaults until /uiedit.
    run()

    if type(zo_callLater) ~= "function" then
        return
    end
    for index = 1, #REAPPLY_DELAYS_MS do
        local delay = REAPPLY_DELAYS_MS[index]
        zo_callLater(function()
            if Editor.reapplyGeneration ~= generation then
                return
            end
            run()
        end, delay)
    end
end

local function HookAfter(object, methodName, flag, callback)
    if not object or type(object[methodName]) ~= "function" or object[flag] then
        return false
    end
    local original = object[methodName]
    object[methodName] = function(this, ...)
        local a, b, c, d, e = original(this, ...)
        callback(this, ...)
        return a, b, c, d, e
    end
    object[flag] = true
    return true
end

function Editor:HookNativeResets()
    local bars = _G.PLAYER_ATTRIBUTE_BARS
    HookAfter(bars, "ApplyStyle", "ValknarrUIEReapplyHooked", function()
        Editor:OnGameplayRestored("attribute-style")
    end)

    local fragmentNames = {
        "PLAYER_ATTRIBUTE_BARS_FRAGMENT",
        "ACTION_BAR_FRAGMENT",
        "COMPASS_FRAME_FRAGMENT",
        "FOCUSED_QUEST_TRACKER_FRAGMENT",
        "BUFF_DEBUFF_FRAGMENT",
        "PLAYER_PROGRESS_BAR_FRAGMENT",
        "HUD_EQUIPMENT_STATUS_FRAGMENT",
    }
    for index = 1, #fragmentNames do
        local fragment = _G[fragmentNames[index]]
        HookAfter(fragment, "SetHiddenForReason", "ValknarrUIEReapplyHooked", function(_, _reason, hidden)
            if not hidden then
                Editor:OnGameplayRestored("fragment-shown")
            end
        end)
    end

    local function HookScene(scene, label)
        if not scene or type(scene.RegisterCallback) ~= "function" or scene.ValknarrUIEReapplyHooked then
            return
        end
        local ok = pcall(scene.RegisterCallback, scene, "StateChange", function(_, newState)
            if newState == SCENE_SHOWN or newState == SCENE_SHOWING then
                Editor:OnGameplayRestored(label)
            end
            -- SHOWN only: SHOWING + SHOWN + HUD_UI was four full reapplies.
            if (label == "hud-scene" or label == "hudui-scene") and newState == SCENE_SHOWN then
                Editor:TryReapplyAfterMenu()
            end
        end)
        if ok then
            scene.ValknarrUIEReapplyHooked = true
        end
    end
    HookScene(_G.HUD_SCENE, "hud-scene")
    HookScene(_G.HUD_UI_SCENE, "hudui-scene")

    -- ESC / gamepad menu / map: hide is the leave-menu signal if previous-scene
    -- is missing on console. HUD SHOWING still skips walking bounces.
    local function HookMenuExit(scene)
        if not scene or type(scene.RegisterCallback) ~= "function" or scene.ValknarrUIEMenuExitHooked then
            return
        end
        local ok = pcall(scene.RegisterCallback, scene, "StateChange", function(_, newState)
            if newState == SCENE_HIDDEN then
                Editor:PinOnceAfterMenu("menu-exit")
            end
        end)
        if ok then
            scene.ValknarrUIEMenuExitHooked = true
        end
    end
    HookMenuExit(_G.MAIN_MENU_KEYBOARD)
    HookMenuExit(_G.MAIN_MENU_GAMEPAD)
    HookMenuExit(_G.WORLD_MAP_SCENE)
end

function Editor:RegisterEvents()
    if not EVENT_MANAGER then
        if Log then
            Log:Warn("EVENT_MANAGER missing; reapply hooks not registered")
        end
        return
    end

    local function Register(suffix, eventId, reason)
        if not eventId or type(EVENT_MANAGER.RegisterForEvent) ~= "function" then
            return
        end
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. suffix, eventId, function()
            Editor:OnGameplayRestored(reason)
        end)
    end

    -- PLAYER_ACTIVATED does not fire on in-zone death. EVENT_PLAYER_ALIVE does.
    -- ZONE_CHANGED also fires for named subzones while walking; do not reapply.
    -- ApplyStyle rewrites platform templates (XML anchors).
    Register("Activated", EVENT_PLAYER_ACTIVATED, "player-activated")
    Register("Alive", EVENT_PLAYER_ALIVE, "player-alive")
    Register("Resized", EVENT_SCREEN_RESIZED, "screen-resized")
    Register("GamepadMode", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, "gamepad-mode")
    Register("LayerPop", EVENT_ACTION_LAYER_POPPED, "action-layer")
    if EVENT_ACTION_LAYER_PUSHED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "LayerPush", EVENT_ACTION_LAYER_PUSHED, function()
            if Editor.postCloseUnlock and not Editor.active and not Editor.ending then
                if Movement and Movement.UnconsumeHudSticks and Movement.IsGameplayHud and Movement:IsGameplayHud() then
                    Movement:UnconsumeHudSticks()
                end
            end
        end)
    end

    local function OnCameraUi()
        Editor:OnCameraUiEvent()
    end
    if EVENT_GAME_CAMERA_UI_MODE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "CameraUI", EVENT_GAME_CAMERA_UI_MODE_CHANGED, OnCameraUi)
    end
    if EVENT_GAME_CAMERA_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "CameraOn", EVENT_GAME_CAMERA_ACTIVATED, OnCameraUi)
    end
    self:HookNativeResets()
    if Log then
        Log:Debug("Event hooks registered")
    end
end

return Editor
