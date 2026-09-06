-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

-- v0.29.205 - Hybrid Desktop Controller Navigation
--
-- Goal: keep the keyboard/desktop presentation selected while allowing the
-- controller to own MENU navigation whenever it is the player's most recent
-- input. Mouse/keyboard input immediately hands menu ownership back to the
-- normal desktop cursor. This module never changes ESO's Gamepad Mode,
-- Keybind Display Mode, or SCENE_MANAGER preferred-mode state.

ESOProgressionCoach = ESOProgressionCoach or {}
local EPC = ESOProgressionCoach

local ACTION_LAYER = "ESOAdventurerSuiteHybridDesktopNavigation"
local UPDATE_NAME = "ESOAdventurerSuite_HybridDesktopNavigation029205"
local INPUT_EVENT_NAME = "ESOAdventurerSuite_HybridDesktopNavigationInput029205"
local MOUSE_EVENT_NAME = "ESOAdventurerSuite_HybridDesktopNavigationMouse029205"

local STICK_DEADZONE = 0.58
local STICK_FIRST_REPEAT_MS = 310
local STICK_REPEAT_MS = 145
local MAX_TREE_DEPTH = 18
local MAX_CANDIDATES = 500

local function SafeCall(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c, d = pcall(fn, ...)
    if not ok then return fallback end
    return a, b, c, d
end

local function NowMS()
    if type(GetFrameTimeMilliseconds) == "function" then
        local ok, value = pcall(GetFrameTimeMilliseconds)
        if ok then return tonumber(value) or 0 end
    end
    return 0
end

local function IsControlHidden(control)
    if not control then return true end
    if type(control.IsControlHidden) == "function" then
        local ok, value = pcall(control.IsControlHidden, control)
        if ok then return value == true end
    end
    if type(control.IsHidden) == "function" then
        local ok, value = pcall(control.IsHidden, control)
        if ok then return value == true end
    end
    return false
end

local function IsMouseEnabled(control)
    if not control or type(control.IsMouseEnabled) ~= "function" then return false end
    local ok, value = pcall(control.IsMouseEnabled, control)
    return ok and value == true
end

local function GetHandler(control, handlerName)
    if not control then return nil end
    if type(control.GetHandler) == "function" then
        local ok, handler = pcall(control.GetHandler, control, handlerName)
        if ok and type(handler) == "function" then return handler end
    end
    return nil
end

local function HasHandler(control, handlerName)
    if not control then return false end
    if type(control.IsHandlerSet) == "function" then
        local ok, value = pcall(control.IsHandlerSet, control, handlerName)
        if ok and value == true then return true end
    end
    return GetHandler(control, handlerName) ~= nil
end

local function GetRect(control)
    if not control or type(control.GetScreenRect) ~= "function" then return nil end
    local ok, left, top, right, bottom = pcall(control.GetScreenRect, control)
    left, top, right, bottom = tonumber(left), tonumber(top), tonumber(right), tonumber(bottom)
    if not ok or not left or not top or not right or not bottom then return nil end
    if right <= left or bottom <= top then return nil end
    return left, top, right, bottom
end

local function GetCenter(control)
    local left, top, right, bottom = GetRect(control)
    if not left then return nil end
    return (left + right) * 0.5, (top + bottom) * 0.5, right - left, bottom - top
end

local function GetGuiDimensions()
    if GuiRoot and type(GuiRoot.GetDimensions) == "function" then
        local ok, w, h = pcall(GuiRoot.GetDimensions, GuiRoot)
        w, h = tonumber(w), tonumber(h)
        if ok and w and h and w > 0 and h > 0 then return w, h end
    end
    return 1920, 1080
end

local function GetControlType(control)
    if not control or type(control.GetType) ~= "function" then return nil end
    local ok, value = pcall(control.GetType, control)
    return ok and value or nil
end

local function IsEditableControl(control)
    local t = GetControlType(control)
    return CT_EDITBOX ~= nil and t == CT_EDITBOX
end

local function GetParent(control)
    if control and type(control.GetParent) == "function" then
        local ok, parent = pcall(control.GetParent, control)
        if ok then return parent end
    end
    return nil
end

local function IsActionableControl(control)
    if not control or control == GuiRoot or IsControlHidden(control) or not IsMouseEnabled(control) then return false end

    local left, top, right, bottom = GetRect(control)
    if not left then return false end

    local screenW, screenH = GetGuiDimensions()
    local width, height = right - left, bottom - top
    if width < 6 or height < 6 then return false end
    -- Reject giant scene/background catchers. They are technically mouse-enabled
    -- in many keyboard screens but are not useful controller focus targets.
    if width > screenW * 0.94 and height > screenH * 0.80 then return false end

    local t = GetControlType(control)
    if CT_BUTTON ~= nil and t == CT_BUTTON then return true end
    if CT_CHECKBOX ~= nil and t == CT_CHECKBOX then return true end
    if CT_SLIDER ~= nil and t == CT_SLIDER then return true end
    if CT_EDITBOX ~= nil and t == CT_EDITBOX then return true end

    return HasHandler(control, "OnClicked")
        or HasHandler(control, "OnMouseUp")
        or HasHandler(control, "OnMouseDown")
        or HasHandler(control, "OnMouseDoubleClick")
end

local function CandidatePriority(control)
    local t = GetControlType(control)
    if CT_BUTTON ~= nil and t == CT_BUTTON then return 5 end
    if CT_CHECKBOX ~= nil and t == CT_CHECKBOX then return 5 end
    if CT_SLIDER ~= nil and t == CT_SLIDER then return 4 end
    if CT_EDITBOX ~= nil and t == CT_EDITBOX then return 3 end
    if HasHandler(control, "OnClicked") then return 4 end
    if HasHandler(control, "OnMouseUp") then return 3 end
    if HasHandler(control, "OnMouseDown") then return 2 end
    return 1
end

function EPC:IsHybridDesktopNavigationEnabled029205()
    if not self:ShouldKeepDesktopUIWithGamepad029197() then return false end
    if type(IsConsoleUI) == "function" and IsConsoleUI() == true then return false end
    if self.saved and self.saved.hybridDesktopGamepadNavigation029205 == false then return false end
    return true
end

function EPC:IsHybridNavigationUIMode029205()
    if SCENE_MANAGER and type(SCENE_MANAGER.IsInUIMode) == "function" then
        local ok, value = pcall(SCENE_MANAGER.IsInUIMode, SCENE_MANAGER)
        if ok then return value == true end
    end
    if type(IsGameCameraUIModeActive) == "function" then
        local ok, value = pcall(IsGameCameraUIModeActive)
        if ok then return value == true end
    end
    return false
end

function EPC:IsHybridNavigationSuppressed029205()
    -- Do not convert controller input into generic menu focus while the player is
    -- actively typing. The native chat/edit control should own input there.
    if type(ZO_GetChatSystem) == "function" then
        local ok, chat = pcall(ZO_GetChatSystem)
        if ok and chat and type(chat.IsTextEntryOpen) == "function" then
            local okOpen, isOpen = pcall(chat.IsTextEntryOpen, chat)
            if okOpen and isOpen == true then return true end
        end
    end

    if WINDOW_MANAGER and type(WINDOW_MANAGER.GetMouseFocusControl) == "function" then
        local ok, focus = pcall(WINDOW_MANAGER.GetMouseFocusControl, WINDOW_MANAGER)
        if ok and IsEditableControl(focus) then return true end
    end

    -- HUD Layout is intentionally a mouse-driven placement workspace. Do not let
    -- the generic menu navigator select/move its overlay controls.
    if self.unitFramesMoveMode == true or self.combatHudMoveMode == true
        or self.interactionMode == true or self.hudLayoutStartPending02959 == true then
        return true
    end

    return false
end

function EPC:IsHybridControllerOwner029205()
    if not self:IsHybridDesktopNavigationEnabled029205() then return false end
    if not self:IsHybridNavigationUIMode029205() then return false end
    if self:IsHybridNavigationSuppressed029205() then return false end

    -- Read the engine's real last-input state. This remains valid even though the
    -- visual IsInGamepadPreferredMode() query is forced to desktop by Core.lua.
    if type(WasLastInputGamepad) == "function" then
        local ok, value = pcall(WasLastInputGamepad)
        if ok then return value == true end
    end
    return self.hybridLastInputGamepad029205 == true
end

function EPC:SetHybridLastInput029205(isGamepad)
    isGamepad = isGamepad == true
    if self.hybridLastInputGamepad029205 == isGamepad then return end
    self.hybridLastInputGamepad029205 = isGamepad
    self.hybridStickDirection029205 = nil
    self.hybridStickNextRepeat029205 = 0
    if not isGamepad then
        self:ClearHybridSelection029205(true)
    end
    self:RefreshHybridDesktopNavigation029205(true)
end

function EPC:CollectHybridNavigationCandidates029205()
    local out, seen = {}, {}

    local function add(control)
        if #out >= MAX_CANDIDATES or not IsActionableControl(control) or seen[control] then return end
        seen[control] = true
        local x, y, width, height = GetCenter(control)
        if not x then return end
        out[#out + 1] = {
            control = control,
            x = x,
            y = y,
            width = width,
            height = height,
            priority = CandidatePriority(control),
        }
    end

    -- Infinite Archive Verse/Vision selector is a high-value keyboard-only
    -- screen for this bridge. Add its choice controls first so focus lands on an
    -- actual offered Verse/Vision rather than an incidental descendant label.
    local iaSelector = rawget(_G, "ENDLESS_DUNGEON_BUFF_SELECTOR_KEYBOARD")
    if iaSelector and iaSelector.buffControls and iaSelector.control and not IsControlHidden(iaSelector.control) then
        for _, control in ipairs(iaSelector.buffControls) do add(control) end
    end

    local function walk(control, depth)
        if #out >= MAX_CANDIDATES or not control or depth > MAX_TREE_DEPTH then return end
        if control ~= GuiRoot and IsControlHidden(control) then return end
        add(control)
        if type(control.GetNumChildren) ~= "function" or type(control.GetChild) ~= "function" then return end
        local okCount, count = pcall(control.GetNumChildren, control)
        count = okCount and tonumber(count) or 0
        for i = 1, count do
            local okChild, child = pcall(control.GetChild, control, i)
            if okChild and child then walk(child, depth + 1) end
            if #out >= MAX_CANDIDATES then break end
        end
    end

    if GuiRoot then walk(GuiRoot, 0) end
    return out
end

function EPC:FindActionableAncestor029205(control)
    local current = control
    for _ = 1, 8 do
        if not current then break end
        if IsActionableControl(current) then return current end
        current = GetParent(current)
    end
    return nil
end

function EPC:CallHybridMouseHandler029205(control, handlerName, ...)
    local handler = GetHandler(control, handlerName)
    if not handler then return false end
    local ok = pcall(handler, control, ...)
    return ok
end

function EPC:SetHybridSelection029205(control)
    if control and not IsActionableControl(control) then control = nil end
    if self.hybridSelectedControl029205 == control then return control ~= nil end

    local previous = self.hybridSelectedControl029205
    self.hybridSelectedControl029205 = nil
    if previous and previous ~= control then
        self:CallHybridMouseHandler029205(previous, "OnMouseExit")
    end

    if control then
        self.hybridSelectedControl029205 = control
        self:CallHybridMouseHandler029205(control, "OnMouseEnter")
        -- A few ZOS keyboard selectors (including Infinite Archive choices) keep
        -- their selected control on the owning manager. Let their native hover
        -- handler do that first; only fill the field when it is still empty.
        local manager = nil
        local okManager, valueManager = pcall(function() return control.manager end)
        if okManager then manager = valueManager end
        if type(manager) == "table" and manager.selectedBuffControl == nil then
            manager.selectedBuffControl = control
        end
        return true
    end
    return false
end

function EPC:ClearHybridSelection029205(restoreMouseHover)
    local previous = self.hybridSelectedControl029205
    self.hybridSelectedControl029205 = nil
    if previous then self:CallHybridMouseHandler029205(previous, "OnMouseExit") end

    -- On a hand-off to the mouse, immediately restore the actual control under
    -- the desktop cursor so keyboard UI hover state never remains stale.
    if restoreMouseHover == true and WINDOW_MANAGER and type(WINDOW_MANAGER.GetMouseOverControl) == "function" then
        local ok, hovered = pcall(WINDOW_MANAGER.GetMouseOverControl, WINDOW_MANAGER)
        if ok and hovered and hovered ~= GuiRoot then
            local actionable = self:FindActionableAncestor029205(hovered)
            if actionable then self:CallHybridMouseHandler029205(actionable, "OnMouseEnter") end
        end
    end
end

function EPC:SeedHybridSelection029205(candidates)
    candidates = candidates or self:CollectHybridNavigationCandidates029205()
    if #candidates == 0 then return false end

    -- Prefer the control currently under the mouse so switching from mouse to
    -- controller continues exactly where the player left off.
    if WINDOW_MANAGER and type(WINDOW_MANAGER.GetMouseOverControl) == "function" then
        local ok, hovered = pcall(WINDOW_MANAGER.GetMouseOverControl, WINDOW_MANAGER)
        if ok then
            local actionable = self:FindActionableAncestor029205(hovered)
            if actionable then return self:SetHybridSelection029205(actionable) end
        end
    end

    local seedX, seedY
    if WINDOW_MANAGER and type(WINDOW_MANAGER.GetUIMousePosition) == "function" then
        local ok, x, y = pcall(WINDOW_MANAGER.GetUIMousePosition, WINDOW_MANAGER)
        if ok then seedX, seedY = tonumber(x), tonumber(y) end
    end
    if not seedX or not seedY then
        local w, h = GetGuiDimensions()
        seedX, seedY = w * 0.5, h * 0.5
    end

    local best, bestScore
    for _, entry in ipairs(candidates) do
        local dx, dy = entry.x - seedX, entry.y - seedY
        local score = dx * dx + dy * dy - (entry.priority or 0) * 1200
        if bestScore == nil or score < bestScore then
            best, bestScore = entry.control, score
        end
    end
    return self:SetHybridSelection029205(best)
end

function EPC:MoveHybridSelection029205(dx, dy)
    if not self:IsHybridControllerOwner029205() then return false end
    dx, dy = tonumber(dx) or 0, tonumber(dy) or 0
    if dx == 0 and dy == 0 then return false end

    local candidates = self:CollectHybridNavigationCandidates029205()
    if #candidates == 0 then return false end

    local current = self.hybridSelectedControl029205
    if not current or not IsActionableControl(current) then
        self:SeedHybridSelection029205(candidates)
        current = self.hybridSelectedControl029205
        if not current then return false end
    end

    local cx, cy = GetCenter(current)
    if not cx then
        self:SeedHybridSelection029205(candidates)
        current = self.hybridSelectedControl029205
        cx, cy = GetCenter(current)
        if not cx then return false end
    end

    -- Sliders are more useful when horizontal controller input changes the
    -- value directly instead of jumping focus away from the setting.
    local currentType = GetControlType(current)
    if CT_SLIDER ~= nil and currentType == CT_SLIDER and dx ~= 0 and math.abs(dx) >= math.abs(dy) then
        if type(current.GetMinMax) == "function" and type(current.GetValue) == "function" and type(current.SetValue) == "function" then
            local okRange, minValue, maxValue = pcall(current.GetMinMax, current)
            local okValue, value = pcall(current.GetValue, current)
            minValue, maxValue, value = tonumber(minValue), tonumber(maxValue), tonumber(value)
            if okRange and okValue and minValue and maxValue and value and maxValue > minValue then
                local step = (maxValue - minValue) / 20
                if type(current.GetValueStep) == "function" then
                    local okStep, nativeStep = pcall(current.GetValueStep, current)
                    nativeStep = okStep and tonumber(nativeStep) or nil
                    if nativeStep and nativeStep > 0 then step = nativeStep end
                end
                value = math.max(minValue, math.min(maxValue, value + (dx > 0 and step or -step)))
                pcall(current.SetValue, current, value)
                return true
            end
        end
    end

    local best, bestScore
    for _, entry in ipairs(candidates) do
        local control = entry.control
        if control ~= current then
            local vx, vy = entry.x - cx, entry.y - cy
            local primary = dx ~= 0 and vx * dx or vy * dy
            if primary > 3 then
                local perpendicular = dx ~= 0 and math.abs(vy) or math.abs(vx)
                local forward = math.abs(primary)
                -- Favor controls in the requested direction and roughly the same
                -- row/column; lightly favor real buttons over generic containers.
                local score = forward + perpendicular * 2.7 + (perpendicular * perpendicular) / math.max(80, forward)
                    - (entry.priority or 0) * 8
                if bestScore == nil or score < bestScore then
                    best, bestScore = control, score
                end
            end
        end
    end

    if best then
        self:SetHybridSelection029205(best)
        if type(PlaySound) == "function" and SOUNDS and SOUNDS.HOR_LIST_ITEM_SELECTED then
            pcall(PlaySound, SOUNDS.HOR_LIST_ITEM_SELECTED)
        end
        return true
    end
    return false
end

function EPC:ActivateHybridSelection029205()
    if not self:IsHybridControllerOwner029205() then return false end
    local control = self.hybridSelectedControl029205
    if not control or not IsActionableControl(control) then
        if not self:SeedHybridSelection029205() then return false end
        control = self.hybridSelectedControl029205
    end
    if not control then return false end

    -- Keep keyboard selector state in sync before invoking its native click.
    self:CallHybridMouseHandler029205(control, "OnMouseEnter")

    if HasHandler(control, "OnClicked") then
        if self:CallHybridMouseHandler029205(control, "OnClicked", MOUSE_BUTTON_INDEX_LEFT or 1) then return true end
    end
    if HasHandler(control, "OnMouseUp") then
        if self:CallHybridMouseHandler029205(control, "OnMouseUp", MOUSE_BUTTON_INDEX_LEFT or 1, true) then return true end
    end
    if HasHandler(control, "OnMouseDown") then
        if self:CallHybridMouseHandler029205(control, "OnMouseDown", MOUSE_BUTTON_INDEX_LEFT or 1) then
            self:CallHybridMouseHandler029205(control, "OnMouseUp", MOUSE_BUTTON_INDEX_LEFT or 1, true)
            return true
        end
    end

    if IsEditableControl(control) and type(control.TakeFocus) == "function" then
        local ok = pcall(control.TakeFocus, control)
        return ok
    end
    return false
end

function EPC:HybridBack029205()
    if not self:IsHybridControllerOwner029205() then return false end
    self:ClearHybridSelection029205(false)
    -- Do not consume B. The action layer allows fallthrough so the current ZOS
    -- scene/keybind strip still performs its own native Back/Close behavior.
    return false
end

function EPC:SetHybridNavigationLayer029205(active)
    active = active == true
    if active == self.hybridNavigationLayerPushed029205 then return end
    if active then
        if type(PushActionLayerByName) == "function" then
            local ok = pcall(PushActionLayerByName, ACTION_LAYER)
            self.hybridNavigationLayerPushed029205 = ok == true
        end
    else
        if self.hybridNavigationLayerPushed029205 and type(RemoveActionLayerByName) == "function" then
            pcall(RemoveActionLayerByName, ACTION_LAYER)
        end
        self.hybridNavigationLayerPushed029205 = false
    end
end

function EPC:SetHybridCursorMode029205(controllerOwnsMenu)
    controllerOwnsMenu = controllerOwnsMenu == true
    if controllerOwnsMenu == self.hybridCursorHidden029205 then return end
    -- HideMouse/ShowMouse with the movement-aware flag is paired exactly once.
    -- Moving the real mouse causes EVENT_INPUT_TYPE_CHANGED, which hands control
    -- back and restores the desktop cursor immediately.
    local ONLY_WHILE_MOVING = true
    if controllerOwnsMenu and type(HideMouse) == "function" then
        local ok = pcall(HideMouse, ONLY_WHILE_MOVING)
        if ok then self.hybridCursorHidden029205 = true end
    elseif not controllerOwnsMenu and self.hybridCursorHidden029205 and type(ShowMouse) == "function" then
        pcall(ShowMouse, ONLY_WHILE_MOVING)
        self.hybridCursorHidden029205 = false
    else
        self.hybridCursorHidden029205 = false
    end
end

function EPC:RefreshHybridDesktopNavigation029205(seedFocus)
    -- Keep the hidden navigation layer available whenever a desktop menu is
    -- open, even while the mouse currently owns it. Its handlers return false
    -- for keyboard/mouse input, so the first controller press can switch modes
    -- immediately instead of being lost while waiting for the next poll.
    local layerActive = self:IsHybridDesktopNavigationEnabled029205()
        and self:IsHybridNavigationUIMode029205()
        and not self:IsHybridNavigationSuppressed029205()
    local active = self:IsHybridControllerOwner029205()
    self:SetHybridNavigationLayer029205(layerActive)
    self:SetHybridCursorMode029205(active)

    if active then
        if seedFocus == true or not self.hybridSelectedControl029205 or not IsActionableControl(self.hybridSelectedControl029205) then
            self:SeedHybridSelection029205()
        end
    else
        self:ClearHybridSelection029205(false)
    end
    return active
end

function EPC:UpdateHybridStickNavigation029205()
    if not self:IsHybridControllerOwner029205() then
        self.hybridStickDirection029205 = nil
        self.hybridStickNextRepeat029205 = 0
        return
    end
    if type(GetGamepadLeftStickX) ~= "function" or type(GetGamepadLeftStickY) ~= "function" then return end

    local okX, x = pcall(GetGamepadLeftStickX, true)
    local okY, y = pcall(GetGamepadLeftStickY, true)
    x, y = okX and tonumber(x) or 0, okY and tonumber(y) or 0

    local dirX, dirY = 0, 0
    if math.abs(x) >= STICK_DEADZONE or math.abs(y) >= STICK_DEADZONE then
        if math.abs(x) > math.abs(y) then dirX = x > 0 and 1 or -1
        else dirY = y > 0 and -1 or 1 end -- ESO stick Y positive is up.
    end

    if dirX == 0 and dirY == 0 then
        self.hybridStickDirection029205 = nil
        self.hybridStickNextRepeat029205 = 0
        return
    end

    local direction = tostring(dirX) .. ":" .. tostring(dirY)
    local now = NowMS()
    if self.hybridStickDirection029205 ~= direction then
        self.hybridStickDirection029205 = direction
        self.hybridStickNextRepeat029205 = now + STICK_FIRST_REPEAT_MS
        self:MoveHybridSelection029205(dirX, dirY)
    elseif now >= (tonumber(self.hybridStickNextRepeat029205) or 0) then
        self.hybridStickNextRepeat029205 = now + STICK_REPEAT_MS
        self:MoveHybridSelection029205(dirX, dirY)
    end
end

function EPC:PollHybridDesktopNavigation029205()
    if not self:IsHybridDesktopNavigationEnabled029205() then
        self:SetHybridNavigationLayer029205(false)
        self:SetHybridCursorMode029205(false)
        self:ClearHybridSelection029205(false)
        return
    end

    -- v0.29.315: controller navigation only owns desktop UI scenes. While the
    -- player is simply running around, do not poll input/stick state or rescan
    -- actionable controls. EVENT_INPUT_TYPE_CHANGED still records the last
    -- input immediately, so opening a menu remains responsive.
    if not self:IsHybridNavigationUIMode029205() then
        if self.hybridNavigationLayerPushed029205 or self.hybridCursorHidden029205 or self.hybridSelectedControl029205 then
            self:SetHybridNavigationLayer029205(false)
            self:SetHybridCursorMode029205(false)
            self:ClearHybridSelection029205(false)
        end
        self.hybridStickDirection029205 = nil
        self.hybridStickNextRepeat029205 = 0
        return
    end

    local lastGamepad = self.hybridLastInputGamepad029205 == true
    if type(WasLastInputGamepad) == "function" then
        local ok, value = pcall(WasLastInputGamepad)
        if ok then lastGamepad = value == true end
    end
    if lastGamepad ~= (self.hybridLastInputGamepad029205 == true) then
        self:SetHybridLastInput029205(lastGamepad)
    else
        self:RefreshHybridDesktopNavigation029205(false)
    end
    self:UpdateHybridStickNavigation029205()
end

function EPC:InstallHybridDesktopNavigation029205()
    if self.hybridDesktopNavigationInstalled029205 then
        self:RefreshHybridDesktopNavigation029205(true)
        return true
    end

    if type(WasLastInputGamepad) == "function" then
        local ok, value = pcall(WasLastInputGamepad)
        self.hybridLastInputGamepad029205 = ok and value == true or false
    else
        self.hybridLastInputGamepad029205 = false
    end

    if EVENT_MANAGER then
        if EVENT_INPUT_TYPE_CHANGED ~= nil then
            EVENT_MANAGER:RegisterForEvent(INPUT_EVENT_NAME, EVENT_INPUT_TYPE_CHANGED, function(_, isGamepad)
                local suite = rawget(_G, "ESOProgressionCoach")
                if suite and suite.SetHybridLastInput029205 then suite:SetHybridLastInput029205(isGamepad == true) end
            end)
        end
        -- Mouse button activity is an explicit keyboard/mouse hand-off even on
        -- builds where mere pointer motion does not emit INPUT_TYPE_CHANGED.
        if EVENT_GLOBAL_MOUSE_DOWN ~= nil then
            EVENT_MANAGER:RegisterForEvent(MOUSE_EVENT_NAME, EVENT_GLOBAL_MOUSE_DOWN, function()
                local suite = rawget(_G, "ESOProgressionCoach")
                if suite and suite.SetHybridLastInput029205 then suite:SetHybridLastInput029205(false) end
            end)
        elseif EVENT_GLOBAL_MOUSE_UP ~= nil then
            EVENT_MANAGER:RegisterForEvent(MOUSE_EVENT_NAME, EVENT_GLOBAL_MOUSE_UP, function()
                local suite = rawget(_G, "ESOProgressionCoach")
                if suite and suite.SetHybridLastInput029205 then suite:SetHybridLastInput029205(false) end
            end)
        end
        EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, 750, function()
            local suite = rawget(_G, "ESOProgressionCoach")
            if suite and suite.PollHybridDesktopNavigation029205 then suite:PollHybridDesktopNavigation029205() end
        end)
    end

    self.hybridDesktopNavigationInstalled029205 = true
    self:RefreshHybridDesktopNavigation029205(true)
    return true
end

-- Hidden binding-layer entry points. Each returns false when the hybrid navigator
-- does not own the current menu so ESO's native action can fall through normally.
function ESOAdventurerSuite_HybridNavUp029205()
    local suite = rawget(_G, "ESOProgressionCoach")
    return suite and suite.MoveHybridSelection029205 and suite:MoveHybridSelection029205(0, -1) or false
end
function ESOAdventurerSuite_HybridNavDown029205()
    local suite = rawget(_G, "ESOProgressionCoach")
    return suite and suite.MoveHybridSelection029205 and suite:MoveHybridSelection029205(0, 1) or false
end
function ESOAdventurerSuite_HybridNavLeft029205()
    local suite = rawget(_G, "ESOProgressionCoach")
    return suite and suite.MoveHybridSelection029205 and suite:MoveHybridSelection029205(-1, 0) or false
end
function ESOAdventurerSuite_HybridNavRight029205()
    local suite = rawget(_G, "ESOProgressionCoach")
    return suite and suite.MoveHybridSelection029205 and suite:MoveHybridSelection029205(1, 0) or false
end
function ESOAdventurerSuite_HybridNavPrimary029205()
    local suite = rawget(_G, "ESOProgressionCoach")
    return suite and suite.ActivateHybridSelection029205 and suite:ActivateHybridSelection029205() or false
end
function ESOAdventurerSuite_HybridNavBack029205()
    local suite = rawget(_G, "ESOProgressionCoach")
    return suite and suite.HybridBack029205 and suite:HybridBack029205() or false
end
