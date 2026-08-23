ValknarrUIEMovement = ValknarrUIEMovement or {}

local Movement = ValknarrUIEMovement
local Grid = ValknarrUIEGrid
local Log = ValknarrUIELog

-- Stick Y+ matches gamepad lists (tilt toward you = down the screen).
local DEADZONE = 0.40
local INITIAL_REPEAT_MS = 220
local REPEAT_MS = 90
local FRAME_CLAIM_NAME = "ValknarrUIEFrameClaim"
local HUD_UNLOCK_NAME = "ValknarrUIEHudUnlock"
-- Full ForceRelease (UI mode off + drain layers) only for the scene
-- handoff. After that, keep clearing consume-by-UI on HUD until Begin.
-- A timed burst always lost: walk worked for a couple of seconds after
-- A/B (no-op or save), then HUD re-consumed with no camera/HUD event
-- (WASD still worked).
local HUD_UNLOCK_FULL_FRAMES = 30

-- Only used if grid.lua somehow did not load; the grid owns the real values.
local FALLBACK_STEP_X, FALLBACK_STEP_Y = 0.025, 0.045
local FALLBACK_W, FALLBACK_H = 0.16, 0.05

local function Now()
    if type(GetFrameTimeMilliseconds) == "function" then
        local ok, value = pcall(GetFrameTimeMilliseconds)
        if ok and type(value) == "number" then
            return value
        end
    end
    return 0
end

local function ReadAxis(name)
    local fn = _G[name]
    if type(fn) ~= "function" then
        return nil
    end
    local ok, value = pcall(fn)
    if ok and type(value) == "number" then
        return value
    end
    return nil
end

local function ReadDirectional(token)
    if not DIRECTIONAL_INPUT or type(DIRECTIONAL_INPUT.GetXY) ~= "function" or not token then
        return nil, nil
    end
    local ok, x, y = pcall(DIRECTIONAL_INPUT.GetXY, DIRECTIONAL_INPUT, token)
    if ok and type(x) == "number" and type(y) == "number" then
        return x, y
    end
    return nil, nil
end

local function ClaimOwnerName(owner)
    if not owner then
        return "none"
    end
    if owner == ValknarrUIEEditor then
        return "editor"
    end
    if owner == ValknarrUIESettingsMenu then
        return "settings"
    end
    return "other"
end

function Movement:IsGameplayHud()
    if not SCENE_MANAGER then
        return true
    end
    local scene = SCENE_MANAGER.currentScene
    if not scene then
        return true
    end
    local name
    if type(scene.GetName) == "function" then
        local ok, value = pcall(scene.GetName, scene)
        if ok then
            name = value
        end
    end
    if type(name) ~= "string" or name == "" then
        return true
    end
    local lower = string.lower(name)
    return lower == "hud" or lower == "hudui" or lower == "hud_ui"
end

-- After close, HUD fragments can SetGamepadLeftStickConsumedByUI(true)
-- later in the same frame than our unlock tick. Refuse that while the
-- editor's post-close unlock is armed and gameplay HUD is current.
-- Inventory / map are not HUD, so they can still consume.
function Movement:ShouldBlockPostCloseConsume()
    if self.claimed then
        return false
    end
    local editor = ValknarrUIEEditor
    if not editor or not editor.postCloseUnlock then
        return false
    end
    if editor.active or editor.ending or editor.finishingExit then
        return false
    end
    return self:IsGameplayHud()
end

function Movement:InstallConsumeGuard()
    if self.consumeGuardInstalled then
        return
    end
    local rawLeft = self.rawLeftConsume
    if rawLeft then
        local guarded = function(consumed)
            if consumed and Movement:ShouldBlockPostCloseConsume() then
                Movement.blockedHudConsume = (Movement.blockedHudConsume or 0) + 1
                return rawLeft(false)
            end
            return rawLeft(consumed)
        end
        self.guardedLeft = guarded
        _G.SetGamepadLeftStickConsumedByUI = guarded
        self.apiLeftConsume = rawLeft
    end
    local rawRight = self.rawRightConsume
    if rawRight then
        local guarded = function(consumed)
            if consumed and Movement:ShouldBlockPostCloseConsume() then
                Movement.blockedHudConsume = (Movement.blockedHudConsume or 0) + 1
                return rawRight(false)
            end
            return rawRight(consumed)
        end
        self.guardedRight = guarded
        _G.SetGamepadRightStickConsumedByUI = guarded
        self.apiRightConsume = rawRight
    end
    self.consumeGuardInstalled = true
end

-- Resolve claim/release API presence once. Avoid type()+pcall probes every frame.
function Movement:ResolveClaimApis()
    if not self.apisResolved then
        local left = type(SetGamepadLeftStickConsumedByUI) == "function" and SetGamepadLeftStickConsumedByUI or nil
        if left and left ~= self.guardedLeft then
            self.rawLeftConsume = left
        end
        self.apiLeftConsume = self.rawLeftConsume
        local right = type(SetGamepadRightStickConsumedByUI) == "function" and SetGamepadRightStickConsumedByUI or nil
        if right and right ~= self.guardedRight then
            self.rawRightConsume = right
        end
        self.apiRightConsume = self.rawRightConsume
        self.apiCameraUI = type(SetGameCameraUIMode) == "function" and SetGameCameraUIMode or nil
        self.apiSetInUIMode = (SCENE_MANAGER and type(SCENE_MANAGER.SetInUIMode) == "function") and SCENE_MANAGER.SetInUIMode or nil
        if type(LockCameraRotation) == "function" then
            self.apiLockCamera = LockCameraRotation
        elseif type(LockGameCameraRotation) == "function" then
            self.apiLockCamera = LockGameCameraRotation
        else
            self.apiLockCamera = nil
        end
        self.apiPushLayer = type(PushActionLayerByName) == "function" and PushActionLayerByName or nil
        self.apiRemoveLayer = type(RemoveActionLayerByName) == "function" and RemoveActionLayerByName or nil
        self.apiConsume = (DIRECTIONAL_INPUT and type(DIRECTIONAL_INPUT.Consume) == "function") and DIRECTIONAL_INPUT.Consume or nil
        self.apisResolved = true
        self.consumeGuardInstalled = false
    end
    self:InstallConsumeGuard()
end

function Movement:BumpClaimGeneration()
    self.claimGeneration = (self.claimGeneration or 0) + 1
    return self.claimGeneration
end

function Movement:HasStickApi()
    return type(_G.GetGamepadLeftStickX) == "function"
        or type(_G.GetGamepadRightStickX) == "function"
        or (DIRECTIONAL_INPUT ~= nil)
end

function Movement:ConsumeSticks()
    local consume = self.apiConsume
    if not consume or not DIRECTIONAL_INPUT then
        self:ResolveClaimApis()
        consume = self.apiConsume
    end
    if not consume or not DIRECTIONAL_INPUT then
        return
    end
    consume(DIRECTIONAL_INPUT, ZO_DI_LEFT_STICK, ZO_DI_RIGHT_STICK, ZO_DI_DPAD)
end

-- Fallback per-frame claim when the editor tick is not running (recover path).
-- Prefer Editor:StartStickPolling, which consolidates claim + stick poll.
function Movement:StartFrameClaim()
    if self.frameClaim or not EVENT_MANAGER or type(EVENT_MANAGER.RegisterForUpdate) ~= "function" then
        return
    end
    local ok = pcall(
        EVENT_MANAGER.RegisterForUpdate,
        EVENT_MANAGER,
        FRAME_CLAIM_NAME,
        0,
        function()
            if Movement.claimed then
                Movement:HoldClaim()
            end
        end
    )
    if ok then
        self.frameClaim = true
    end
end

function Movement:StopFrameClaim()
    if EVENT_MANAGER and type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
        pcall(EVENT_MANAGER.UnregisterForUpdate, EVENT_MANAGER, FRAME_CLAIM_NAME)
    end
    self.frameClaim = false
end

function Movement:StopHudUnlock()
    if EVENT_MANAGER and type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
        pcall(EVENT_MANAGER.UnregisterForUpdate, EVENT_MANAGER, HUD_UNLOCK_NAME)
    end
    self.hudUnlockActive = false
    self.hudUnlockFrames = 0
end

function Movement:DrainUiShortcuts()
    local remove = self.apiRemoveLayer
    if not remove then
        return
    end
    local isActive = type(IsActionLayerActiveByName) == "function" and IsActionLayerActiveByName or nil
    if isActive then
        for _ = 1, 4 do
            local ok, active = pcall(isActive, "UIShortcuts")
            if not ok or not active then
                break
            end
            pcall(remove, "UIShortcuts")
        end
    else
        pcall(remove, "UIShortcuts")
        pcall(remove, "UIShortcuts")
        pcall(remove, "UIShortcuts")
    end
end

-- Clear consume-by-UI only. Do not drain UIShortcuts or slam camera UI
-- here: that ran every frame after 1.0.0 close and left keys/minimap dead
-- until /reloadui. ForceRelease still drains during the short handoff.
function Movement:UnconsumeHudSticks()
    self:ResolveClaimApis()
    if self.apiLeftConsume then
        self.apiLeftConsume(false)
    end
    if self.apiRightConsume then
        self.apiRightConsume(false)
    end
end

-- After HUD is back: ForceRelease for a short handoff, then stop the
-- tick. The consume guard stays until Begin so HUD consume-true cannot
-- stick the left stick. An endless tick that drained UIShortcuts left
-- keys and the minimap dead until /reloadui.
function Movement:StartHudUnlock(owner)
    self:StopHudUnlock()
    local gen = self.claimGeneration or 0
    self:ForceRelease(owner)
    if not EVENT_MANAGER or type(EVENT_MANAGER.RegisterForUpdate) ~= "function" then
        return
    end
    self.hudUnlockFrames = HUD_UNLOCK_FULL_FRAMES
    self.hudUnlockActive = true
    local ok = pcall(
        EVENT_MANAGER.RegisterForUpdate,
        EVENT_MANAGER,
        HUD_UNLOCK_NAME,
        0,
        function()
            if Movement.claimed or (Movement.claimGeneration or 0) ~= gen then
                Movement:StopHudUnlock()
                return
            end
            local editor = ValknarrUIEEditor
            if editor and (not editor.postCloseUnlock or editor.active or editor.ending) then
                Movement:StopHudUnlock()
                return
            end
            if not Movement:IsGameplayHud() then
                return
            end
            if (Movement.hudUnlockFrames or 0) > 0 then
                Movement:ForceRelease(owner)
                Movement.hudUnlockFrames = (Movement.hudUnlockFrames or 0) - 1
                if (Movement.hudUnlockFrames or 0) <= 0 then
                    Movement:StopHudUnlock()
                end
            else
                Movement:StopHudUnlock()
            end
        end
    )
    if not ok then
        self.hudUnlockActive = false
        self.hudUnlockFrames = 0
    end
end

function Movement:ClaimSticks(owner, control)
    if not owner then
        return
    end
    self:ResolveClaimApis()
    -- Invalidate any deferred ForceRelease from a previous End/Cancel.
    self:BumpClaimGeneration()
    self:StopHudUnlock()
    local already = self.claimed == owner
    -- Teardown ledger: record what this claim session owns so release only
    -- undoes our mutations (and stale deferred callbacks can no-op).
    self.ledger = {
        generation = self.claimGeneration,
        owner = owner,
        pushedLayer = false,
        active = true,
    }
    owner.UpdateDirectionalInput = function()
        -- Deactivate can lag a frame after a quick A/B. Never re-consume
        -- sticks once the editor has started teardown.
        if not Movement.claimed then
            return
        end
        if owner.ending or owner.active == false then
            return
        end
        Movement:HoldClaim()
    end
    if DIRECTIONAL_INPUT and type(DIRECTIONAL_INPUT.Activate) == "function" then
        pcall(DIRECTIONAL_INPUT.Activate, DIRECTIONAL_INPUT, owner, control or GuiRoot)
    end
    self.claimed = owner
    self:HoldClaim()
    -- Prefer the editor's consolidated tick; fall back if it is not running yet.
    if not owner.stickPolling then
        self:StartFrameClaim()
    else
        self:StopFrameClaim()
    end
    if Log and not already then
        Log:Debug("Sticks claimed owner=" .. ClaimOwnerName(owner) .. " gen=" .. tostring(self.claimGeneration) .. " (per-frame consume so character does not walk)")
    end
end

function Movement:Describe()
    self:ResolveClaimApis()
    local ledger = self.ledger
    local owner = self.claimed or (ledger and ledger.owner)
    return {
        owner = ClaimOwnerName(self.claimed),
        claimed = self.claimed ~= nil,
        ownerActive = owner and owner.active and true or false,
        ownerEnding = owner and owner.ending and true or false,
        claimGeneration = self.claimGeneration or 0,
        actionLayerPushed = self.actionLayerPushed and true or false,
        frameClaim = self.frameClaim and true or false,
        hudUnlockFrames = self.hudUnlockFrames or 0,
        hudUnlockActive = self.hudUnlockActive and true or false,
        blockedHudConsume = self.blockedHudConsume or 0,
        consumeGuard = self.consumeGuardInstalled and true or false,
        ledgerActive = ledger and ledger.active and true or false,
        ledgerOwner = ClaimOwnerName(ledger and ledger.owner),
        ledgerGeneration = ledger and ledger.generation or 0,
        leftConsumeApi = self.apiLeftConsume ~= nil,
        rightConsumeApi = self.apiRightConsume ~= nil,
        cameraUiApi = self.apiCameraUI ~= nil,
        setInUIModeApi = self.apiSetInUIMode ~= nil,
        directionalApi = DIRECTIONAL_INPUT ~= nil,
    }
end

-- Stop per-frame consume without unconsuming engine flags. A/B must not
-- SetGamepadLeftStickConsumedByUI(false) while the editor scene is still
-- tearing down — HUD fragments put consume back. ForceRelease later, once
-- HUD is current.
function Movement:StopClaim(owner)
    self:StopFrameClaim()
    local target = owner or self.claimed
    self.claimed = nil
    if target and type(target) == "table" then
        target.UpdateDirectionalInput = function() end
    end
    if DIRECTIONAL_INPUT and type(DIRECTIONAL_INPUT.Deactivate) == "function" and target then
        pcall(DIRECTIONAL_INPUT.Deactivate, DIRECTIONAL_INPUT, target)
    end
end

function Movement:HoldClaim()
    -- After A/B close, never re-claim once StopClaim/ForceRelease cleared claimed.
    if not self.claimed then
        return
    end
    self:ResolveClaimApis()
    if self.apiLeftConsume then
        self.apiLeftConsume(true)
    end
    if self.apiRightConsume then
        self.apiRightConsume(true)
    end
    if self.apiCameraUI then
        self.apiCameraUI(true)
    end
    if self.apiSetInUIMode and SCENE_MANAGER then
        self.apiSetInUIMode(SCENE_MANAGER, true)
    end
    if self.apiLockCamera then
        self.apiLockCamera(true)
    end
    -- Do not PushActionLayerByName("UIShortcuts"): the editor scene already
    -- has UI_SHORTCUTS_ACTION_LAYER_FRAGMENT. An extra Push left a leftover
    -- layer after hide, which eats the left stick while WASD still moves.
    self:ConsumeSticks()
end

-- Always clear gameplay stick locks. Safe after B even if claimed was wiped.
-- Restores only what the current ledger recorded when possible.
function Movement:ForceRelease(owner)
    self:ResolveClaimApis()
    if Log then
        local held = self.claimed ~= nil or self.actionLayerPushed or self.frameClaim
        Log:Debug(string.format(
            "ForceRelease %s owner=%s claimed=%s gen=%s layer=%s frameClaim=%s",
            held and "held" or "idle",
            ClaimOwnerName(self.claimed or owner),
            tostring(self.claimed ~= nil),
            tostring(self.claimGeneration or 0),
            tostring(self.actionLayerPushed and true or false),
            tostring(self.frameClaim and true or false)
        ))
    end
    local ledger = self.ledger
    local target = owner or self.claimed or (ledger and ledger.owner)
    self.claimed = nil
    self:StopFrameClaim()
    if target and type(target) == "table" then
        target.UpdateDirectionalInput = function() end
    end
    if DIRECTIONAL_INPUT and type(DIRECTIONAL_INPUT.Deactivate) == "function" and target then
        pcall(DIRECTIONAL_INPUT.Deactivate, DIRECTIONAL_INPUT, target)
    end
    if self.apiLeftConsume then
        self.apiLeftConsume(false)
    end
    if self.apiRightConsume then
        self.apiRightConsume(false)
    end
    if self.apiCameraUI then
        self.apiCameraUI(false)
    end
    if self.apiSetInUIMode and SCENE_MANAGER then
        self.apiSetInUIMode(SCENE_MANAGER, false)
    end
    if self.apiLockCamera then
        self.apiLockCamera(false)
    end
    -- Drain leftover UIShortcuts pushes (ours plus any hide leftover). Extra
    -- Remove is a no-op if the layer is already gone.
    self:DrainUiShortcuts()
    self.actionLayerPushed = false
    if ledger then
        ledger.active = false
    end
    -- Keep ledger.generation for deferred callbacks to compare against.
end

function Movement:ReleaseSticks(owner)
    self:ForceRelease(owner)
end

-- Deferred releases are session-guarded via claimGeneration. A new ClaimSticks
-- (reopen /uiedit) bumps the generation so pending ForceRelease calls no-op.
function Movement:ReleaseSticksDeferred(owner)
    local gen = self.claimGeneration or 0
    self:ForceRelease(owner)
    if type(zo_callLater) ~= "function" then
        return
    end
    local delays = { 1, 25, 50, 100, 200, 400, 700, 1000, 1500 }
    for index = 1, #delays do
        local delay = delays[index]
        zo_callLater(function()
            if (Movement.claimGeneration or 0) ~= gen then
                return
            end
            if Movement.claimed then
                return
            end
            Movement:ForceRelease(owner)
        end, delay)
    end
end

local function DirectionFromAxes(x, y)
    if math.abs(x) < DEADZONE and math.abs(y) < DEADZONE then
        return nil
    end
    if math.abs(x) >= math.abs(y) then
        if x > 0 then
            return "right"
        end
        return "left"
    end
    if y > 0 then
        return "down"
    end
    return "up"
end

function Movement:FilterAxis(direction, mode)
    if not direction then
        return nil
    end
    if mode == "x" and (direction == "up" or direction == "down") then
        return nil
    end
    if mode == "y" and (direction == "left" or direction == "right") then
        return nil
    end
    return direction
end

function Movement:ReadPair(stick)
    local xName, yName, token
    if stick == "right" then
        xName, yName, token = "GetGamepadRightStickX", "GetGamepadRightStickY", _G.ZO_DI_RIGHT_STICK
    else
        xName, yName, token = "GetGamepadLeftStickX", "GetGamepadLeftStickY", _G.ZO_DI_LEFT_STICK
    end
    local x = ReadAxis(xName)
    local y = ReadAxis(yName)
    if not x or not y then
        local dx, dy = ReadDirectional(token)
        x = x or dx
        y = y or dy
    end
    x = x or 0
    y = y or 0
    local Store = ValknarrUIELayoutStore
    if Store and Store.GetSetting then
        if Store:GetSetting("invertStickX") then
            x = -x
        end
        if Store:GetSetting("invertStickY") then
            y = -y
        end
    end
    return DirectionFromAxes(x, y)
end

function Movement:ResetRepeat()
    self.heldLeft = nil
    self.heldRight = nil
    self.nextLeft = 0
    self.nextRight = 0
end

local function PollOne(heldKey, nextKey, direction, now)
    if not direction then
        Movement[heldKey] = nil
        Movement[nextKey] = 0
        return nil
    end
    if Movement[heldKey] ~= direction then
        Movement[heldKey] = direction
        Movement[nextKey] = now + INITIAL_REPEAT_MS
        return direction
    end
    if now >= (Movement[nextKey] or 0) then
        Movement[nextKey] = now + REPEAT_MS
        return direction
    end
    return nil
end

-- Left stick = move. Right stick = resize. Independent so both can fire.
-- Does not own stick-consume; StartFrameClaim does that every frame.
function Movement:PollSticks()
    local now = Now()
    local left = PollOne("heldLeft", "nextLeft", self:ReadPair("left"), now)
    local right = PollOne("heldRight", "nextRight", self:ReadPair("right"), now)
    return left, right
end

function Movement:Move(position, direction, precision)
    if type(position) ~= "table" then
        if Log then
            Log:Warn("Move skipped: missing position table")
        end
        return
    end

    local stepX, stepY = FALLBACK_STEP_X, FALLBACK_STEP_Y
    if Grid and Grid.Step then
        stepX, stepY = Grid:Step(precision)
    end
    local beforeX, beforeY = position.x, position.y
    if direction == "left" then
        position.x = position.x - stepX
    elseif direction == "right" then
        position.x = position.x + stepX
    elseif direction == "up" then
        position.y = position.y - stepY
    elseif direction == "down" then
        position.y = position.y + stepY
    else
        if Log then
            Log:Warn("Unknown move direction: " .. tostring(direction))
        end
        return
    end

    if Grid and Grid.Snap then
        Grid:Snap(position, precision)
    else
        position.x = math.max(0, math.min(1, position.x))
        position.y = math.max(0, math.min(1, position.y))
    end

    if Log then
        Log:Debug(string.format(
            "Move %s (%.3f,%.3f)->(%.3f,%.3f) precision=%s",
            tostring(direction),
            beforeX or -1,
            beforeY or -1,
            position.x,
            position.y,
            tostring(precision and true or false)
        ))
    end
end

function Movement:Resize(position, direction, precision)
    if type(position) ~= "table" then
        if Log then
            Log:Warn("Resize skipped: missing position table")
        end
        return
    end

    local stepX, stepY = FALLBACK_STEP_X, FALLBACK_STEP_Y
    if Grid and Grid.Step then
        stepX, stepY = Grid:Step(precision)
    end
    if type(position.w) ~= "number" then
        position.w = FALLBACK_W
    end
    if type(position.h) ~= "number" then
        position.h = FALLBACK_H
    end
    local beforeW, beforeH = position.w, position.h
    if direction == "right" then
        position.w = position.w + stepX
    elseif direction == "left" then
        position.w = position.w - stepX
    elseif direction == "down" then
        position.h = position.h + stepY
    elseif direction == "up" then
        position.h = position.h - stepY
    else
        if Log then
            Log:Warn("Unknown resize direction: " .. tostring(direction))
        end
        return
    end

    -- Grid owns the lattice and the bounds so one step in and one step back
    -- returns the exact starting size.
    if Grid and Grid.SnapSize then
        Grid:SnapSize(position, precision)
    end

    if Log then
        Log:Debug(string.format(
            "Resize %s (%.3f,%.3f)->(%.3f,%.3f) precision=%s",
            tostring(direction),
            beforeW or -1,
            beforeH or -1,
            position.w,
            position.h,
            tostring(precision and true or false)
        ))
    end
end

return Movement
