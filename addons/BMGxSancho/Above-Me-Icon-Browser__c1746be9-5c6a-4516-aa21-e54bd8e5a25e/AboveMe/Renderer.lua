AboveMe = AboveMe or {}
local AM = AboveMe
local WM = WINDOW_MANAGER

AM.renderControls = AM.renderControls or {}
AM.renderStates = AM.renderStates or {}
AM.remoteSelections = AM.remoteSelections or {}
AM.worldSamples = AM.worldSamples or {}

-- ESO does not expose the native nameplate or head anchor. Above Me therefore
-- uses a safe universal world-space base and adds each player's calibrated
-- per-character adjustment before projecting to the screen.
local BASE_OVERHEAD_HEIGHT_METERS = 3.25
local NAMEPLATE_CLEARANCE_PIXELS = 8

-- Sampling and animation are intentionally separated. Unit world positions are
-- sampled at a lightweight interval while the camera projection and icon motion
-- are updated more frequently for smoother camera response.
local WORLD_SAMPLE_INTERVAL_MS = 75
local ANIMATION_INTERVAL_MS = 33
local POSITION_DEAD_ZONE_PIXELS = 2.25
local TELEPORT_SNAP_PIXELS = 220
local HIDE_GRACE_MS = 225
local SPRING_FREQUENCY_IDLE = 13
local SPRING_FREQUENCY_ACTIVE = 19
local FAST_CATCHUP_TARGET_PIXELS = 18
local MAX_DELTA_SECONDS = 0.05

local function GetRenderKey(unitTag)
    if AreUnitsEqual("player", unitTag) then
        return "player"
    end

    local displayName = GetUnitDisplayName(unitTag)
    if displayName and displayName ~= "" then
        return displayName
    end

    return unitTag
end

local function CreateIconControl(key)
    local safeKey = tostring(key):gsub("[^%w_]", "_")
    local control = WM:CreateControl("AboveMeIcon_" .. safeKey, AM.worldWindow, CT_TEXTURE)
    control:SetHidden(true)
    control:SetDrawLayer(DL_OVERLAY)
    control:SetDrawTier(DT_HIGH)
    control:SetDrawLevel(100)
    control:SetPixelRoundingEnabled(false)
    AM.renderControls[key] = control
    return control
end

function AM:CreateRenderer()
    self.renderSpace = WM:CreateControl("AboveMeRenderSpace", GuiRoot, CT_CONTROL)
    self.renderSpace:SetAnchorFill(GuiRoot)
    self.renderSpace:Create3DRenderSpace()
    self.renderSpace:SetHidden(true)

    self.worldWindow = WM:CreateTopLevelWindow("AboveMeWorldWindow")
    self.worldWindow:SetAnchorFill(GuiRoot)
    self.worldWindow:SetMouseEnabled(false)
    self.worldWindow:SetMovable(false)
    self.worldWindow:SetDrawLayer(DL_OVERLAY)
    self.worldWindow:SetDrawTier(DT_HIGH)
    self.worldWindow:SetDrawLevel(100)

    local fragment = ZO_HUDFadeSceneFragment:New(self.worldWindow)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
end

function AM:HideAllIcons(resetState)
    for key, control in pairs(self.renderControls) do
        control:SetHidden(true)
        if resetState then
            self.renderStates[key] = nil
            self.worldSamples[key] = nil
        end
    end
end

function AM:GetSelectionForUnit(unitTag)
    if AreUnitsEqual("player", unitTag) then
        return self.saved.iconId, self:GetPlacementOffset()
    end

    local displayName = GetUnitDisplayName(unitTag)
    if not displayName or displayName == "" then return nil, 0 end

    local remote = self.remoteSelections[displayName]
    if type(remote) == "table" then
        return remote.iconId, tonumber(remote.placementOffset) or 0
    end

    -- Compatibility with earlier development builds that stored only the icon ID.
    return remote, 0
end

local function UnitCanDisplay(unitTag)
    if not DoesUnitExist(unitTag) or not IsUnitPlayer(unitTag) or not IsUnitOnline(unitTag) then return false end
    if unitTag ~= "player" then
        if not IsGroupMemberInSameWorldAsPlayer(unitTag) then return false end
        if IsGroupMemberInRemoteRegion(unitTag) then return false end
        if not IsGroupMemberInSameInstanceAsPlayer(unitTag) and not IsActiveWorldBattleground() then return false end
    end
    return true
end

local function GetUnitTags()
    local tags = {}
    if AM.saved.showOwnIcon then
        tags[#tags + 1] = "player"
    end
    if AM.saved.showGroupIcons and IsUnitGrouped("player") then
        for i = 1, 12 do
            local unitTag = "group" .. i
            if not AreUnitsEqual("player", unitTag) then
                tags[#tags + 1] = unitTag
            end
        end
    end
    return tags
end

function AM:SampleWorldPositions()
    if not self.saved.enabled or (self.saved.combatOnly and not IsUnitInCombat("player")) then return end

    local now = GetGameTimeMilliseconds()
    local seen = {}

    for _, unitTag in ipairs(GetUnitTags()) do
        if UnitCanDisplay(unitTag) then
            local selectionId, placementOffset = self:GetSelectionForUnit(unitTag)
            if selectionId and self:GetIcon(selectionId) then
                local key = GetRenderKey(unitTag)
                local _, wX, wY, wZ = GetUnitRawWorldPosition(unitTag)
                if wX and wY and wZ then
                    local sample = self.worldSamples[key] or {}
                    sample.unitTag = unitTag
                    sample.iconId = selectionId
                    sample.placementOffset = placementOffset or 0
                    sample.wX = wX
                    sample.wY = wY
                    sample.wZ = wZ
                    sample.sampledAt = now
                    self.worldSamples[key] = sample
                    seen[key] = true
                end
            end
        end
    end

    for key, sample in pairs(self.worldSamples) do
        if not seen[key] and now - (sample.sampledAt or 0) > HIDE_GRACE_MS then
            self.worldSamples[key] = nil
        end
    end
end

local function SpringPosition(state, targetX, targetY, now)
    if not state.x or not state.y then
        state.x, state.y = targetX, targetY
        state.vx, state.vy = 0, 0
        state.lastUpdate = now
        state.targetX, state.targetY = targetX, targetY
        return targetX, targetY
    end

    local targetDx = targetX - (state.targetX or targetX)
    local targetDy = targetY - (state.targetY or targetY)
    local targetChange = zo_sqrt(targetDx * targetDx + targetDy * targetDy)

    -- Hold the prior target when projection noise is smaller than the visual
    -- dead zone. This prevents one- or two-pixel swimming while standing still.
    if targetChange > POSITION_DEAD_ZONE_PIXELS then
        state.targetX, state.targetY = targetX, targetY
    end

    local dx = (state.targetX or targetX) - state.x
    local dy = (state.targetY or targetY) - state.y
    local distance = zo_sqrt(dx * dx + dy * dy)

    if distance >= TELEPORT_SNAP_PIXELS then
        state.x, state.y = state.targetX, state.targetY
        state.vx, state.vy = 0, 0
        state.lastUpdate = now
        return state.x, state.y
    end

    local elapsedMs = math.max(1, now - (state.lastUpdate or now))
    local dt = zo_clamp(elapsedMs / 1000, 0.001, MAX_DELTA_SECONDS)

    -- Use an implicit critically damped spring update. Unlike explicit Euler
    -- integration, this remains stable when frame time changes and cannot build
    -- the small overshoot that appears as icon wobble. Larger target changes
    -- temporarily use a faster spring so camera turns and running do not leave
    -- the icon trailing behind the player.
    local omega = targetChange >= FAST_CATCHUP_TARGET_PIXELS
        and SPRING_FREQUENCY_ACTIVE
        or SPRING_FREQUENCY_IDLE
    local f = 1 + (2 * dt * omega)
    local oo = omega * omega
    local hoo = dt * oo
    local hhoo = dt * hoo
    local detInv = 1 / (f + hhoo)

    local oldX, oldY = state.x, state.y
    local oldVx, oldVy = state.vx or 0, state.vy or 0
    local stableTargetX = state.targetX or targetX
    local stableTargetY = state.targetY or targetY

    state.x = (f * oldX + dt * oldVx + hhoo * stableTargetX) * detInv
    state.y = (f * oldY + dt * oldVy + hhoo * stableTargetY) * detInv
    state.vx = (oldVx + hoo * (stableTargetX - oldX)) * detInv
    state.vy = (oldVy + hoo * (stableTargetY - oldY)) * detInv

    -- Settle completely once both position and velocity are below a tiny visual
    -- threshold. This prevents sub-pixel drift while a player is standing still.
    local settleDx = stableTargetX - state.x
    local settleDy = stableTargetY - state.y
    if math.abs(settleDx) < 0.12 and math.abs(settleDy) < 0.12
        and math.abs(state.vx) < 0.12 and math.abs(state.vy) < 0.12 then
        state.x, state.y = stableTargetX, stableTargetY
        state.vx, state.vy = 0, 0
    end

    state.lastUpdate = now
    return state.x, state.y
end

local function GetCameraTransform(renderSpace)
    Set3DRenderSpaceToCurrentCamera(renderSpace:GetName())

    local cX, cY, cZ = GuiRender3DPositionToWorldPosition(renderSpace:Get3DRenderSpaceOrigin())
    local fX, fY, fZ = renderSpace:Get3DRenderSpaceForward()
    local rX, rY, rZ = renderSpace:Get3DRenderSpaceRight()
    local uX, uY, uZ = renderSpace:Get3DRenderSpaceUp()

    return {
        cX = cX, cY = cY, cZ = cZ,
        i11 = -(uY * fZ - uZ * fY),
        i12 = -(rZ * fY - rY * fZ),
        i13 = -(rY * uZ - rZ * uY),
        i21 = -(uZ * fX - uX * fZ),
        i22 = -(rX * fZ - rZ * fX),
        i23 = -(rZ * uX - rX * uZ),
        i31 = -(uX * fY - uY * fX),
        i32 = -(rY * fX - rX * fY),
        i33 = -(rX * uY - rY * uX),
        i41 = -(uZ * fY * cX + uY * fX * cZ + uX * fZ * cY - uX * fY * cZ - uY * fZ * cX - uZ * fX * cY),
        i42 = -(rX * fY * cZ + rY * fZ * cX + rZ * fX * cY - rZ * fY * cX - rY * fX * cZ - rX * fZ * cY),
        i43 = -(rZ * uY * cX + rY * uX * cZ + rX * uZ * cY - rX * uY * cZ - rY * uZ * cX - rZ * uX * cY),
    }
end

function AM:AnimateRenderer()
    local now = GetGameTimeMilliseconds()

    if not self.saved.enabled or (self.saved.combatOnly and not IsUnitInCombat("player")) then
        self:HideAllIcons(false)
        return
    end

    if not self.saved.showOwnIcon and not self.saved.showGroupIcons then
        self:HideAllIcons(false)
        return
    end

    local transform = GetCameraTransform(self.renderSpace)
    local uiW, uiH = GuiRoot:GetDimensions()
    local seen = {}

    for key, sample in pairs(self.worldSamples) do
        if now - (sample.sampledAt or 0) <= HIDE_GRACE_MS then
            local icon = self:GetIcon(sample.iconId)
            if icon and icon.texture then
                local wX = sample.wX
                local wY = sample.wY + ((BASE_OVERHEAD_HEIGHT_METERS + (sample.placementOffset or 0)) * 100)
                local wZ = sample.wZ

                local pX = wX * transform.i11 + wY * transform.i21 + wZ * transform.i31 + transform.i41
                local pY = wX * transform.i12 + wY * transform.i22 + wZ * transform.i32 + transform.i42
                local pZ = wX * transform.i13 + wY * transform.i23 + wZ * transform.i33 + transform.i43

                if pZ > 0 then
                    local worldW, worldH = GetWorldDimensionsOfViewFrustumAtDepth(pZ)
                    if worldW and worldW ~= 0 and worldH and worldH ~= 0 then
                        local targetX = pX * uiW / worldW
                        local targetY = (-pY * uiH / worldH) - NAMEPLATE_CLEARANCE_PIXELS

                        local dX = wX - transform.cX
                        local dY = wY - transform.cY
                        local dZ = wZ - transform.cZ
                        local distance = 1 + zo_sqrt(dX * dX + dY * dY + dZ * dZ)

                        if distance <= self.saved.maxDistance * 100 then
                            local control = self.renderControls[key] or CreateIconControl(key)
                            local state = self.renderStates[key] or {}
                            self.renderStates[key] = state

                            local x, y = SpringPosition(state, targetX, targetY, now)
                            state.lastSeen = now
                            seen[key] = true

                            control:ClearAnchors()
                            control:SetAnchor(BOTTOM, self.worldWindow, CENTER, x, y)
                            control:SetTexture(icon.texture)
                            control:SetTextureCoords(icon.left or 0, icon.right or 1, icon.top or 0, icon.bottom or 1)
                            control:SetDimensions(self.saved.size, self.saved.size)
                            control:SetScale(1)

                            local fade = 1
                            if self.saved.fadeWithDistance then
                                local maxDistance = self.saved.maxDistance * 100
                                local fadeStart = maxDistance * 0.60
                                local fadeProgress = zo_clampedPercentBetween(fadeStart, maxDistance, distance)
                                fade = 1 - fadeProgress
                            end
                            control:SetAlpha(self.saved.opacity * fade * fade)
                            control:SetHidden(false)
                        end
                    end
                end
            end
        end
    end

    for key, control in pairs(self.renderControls) do
        if not seen[key] then
            local state = self.renderStates[key]
            if not state or not state.lastSeen or now - state.lastSeen >= HIDE_GRACE_MS then
                control:SetHidden(true)
            end
        end
    end
end

-- Kept as a compatibility entry point for older code paths.
function AM:UpdateRenderer()
    self:SampleWorldPositions()
    self:AnimateRenderer()
end

function AM:StartRenderer()
    EVENT_MANAGER:UnregisterForUpdate("AboveMeWorldSampler")
    EVENT_MANAGER:UnregisterForUpdate("AboveMeRenderer")

    self:SampleWorldPositions()
    EVENT_MANAGER:RegisterForUpdate("AboveMeWorldSampler", WORLD_SAMPLE_INTERVAL_MS, function()
        if AM and AM.saved then AM:SampleWorldPositions() end
    end)
    EVENT_MANAGER:RegisterForUpdate("AboveMeRenderer", ANIMATION_INTERVAL_MS, function()
        if AM and AM.saved then AM:AnimateRenderer() end
    end)

    EVENT_MANAGER:RegisterForEvent("AboveMeRendererLifecycle", EVENT_PLAYER_DEACTIVATED, function()
        AM:HideAllIcons(true)
        ZO_ClearTable(AM.worldSamples)
    end)
    EVENT_MANAGER:RegisterForEvent("AboveMeRendererLifecycle", EVENT_PLAYER_ACTIVATED, function()
        ZO_ClearTable(AM.worldSamples)
        AM:HideAllIcons(true)
        AM:SampleWorldPositions()
    end)
end
