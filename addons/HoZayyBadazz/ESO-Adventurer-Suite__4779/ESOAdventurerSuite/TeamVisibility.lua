-- ESO Adventurer Suite - Team Visibility
-- Proven 3D particle implementation based on ESO's legacy 3D texture render-space API.
-- Uses ESO 3D texture render-space controls adapted specifically
-- for companions and group members inside ESO Adventurer Suite.

ESOProgressionCoach = ESOProgressionCoach or {}
local EPC = ESOProgressionCoach

EPC.TeamVisibility = EPC.TeamVisibility or {}
local T = EPC.TeamVisibility
local wm = WINDOW_MANAGER

local GROUP_MARKER_TEXTURE = "/esoui/art/mappins/ui-worldmapgrouppip.dds"
local BEAM_SOURCE_TEXTURE = "EsoUI/Art/Miscellaneous/lensflare_star_256.dds"
-- Use a current built-in ESO light texture only. The client has repeatedly rejected
-- custom addon DDS files in this 3D render path, while built-in ESO textures load
-- reliably. Sampling a broader vertical portion of the lens flare keeps the
-- soft center glow while also fading at the top and bottom so the beam
-- hugs the character instead of looking like a hard-capped rectangle.
local MAX_GROUP_MEMBERS = 12
local UPDATE_MS = 900
local WORLD_REFRESH_MS = 600
local POSITION_GRACE_MS = 2000
local BEAM_CENTER_Y_CM = 170
local BASE_BEAM_WIDTH_M = 3.55
local BASE_BEAM_HEIGHT_M = 8.20
local BASE_PITCH = math.rad(-0.05)
local DRAW_LEVEL_EFFECTS = 10
local LAYERS_PER_UNIT = 2
local DEFAULT_COMPANION_COLOR = { r = 0.72, g = 0.38, b = 1.00 }
local DEAD_PLAYER_COLOR = { r = 1.00, g = 0.00, b = 0.00 }
local RESERVED_RED_FALLBACK = { r = 1.00, g = 0.62, b = 0.12 }
local DEAD_FLASH_PERIOD_MS = 2000
local DEAD_FLASH_MIN_FACTOR = 0.30
local BEAM_U1, BEAM_U2, BEAM_V1, BEAM_V2 = 0.06, 0.94, 0.06, 0.94

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c, d = pcall(fn, ...)
    if not ok then return fallback end
    return a, b, c, d
end

local function sameUnit(a, b)
    if type(AreUnitsEqual) == "function" then
        return safe(AreUnitsEqual, false, a, b) == true
    end
    return a == b
end

function T:IsEnabled()
    return EPC.saved == nil or EPC.saved.teamVisibilityEnabled ~= false
end

function T:LightsEnabled()
    return self:IsEnabled() and (EPC.saved == nil or EPC.saved.teamVisibilityLightsEnabled ~= false)
end

function T:ApplyNativeGroupMarkers()
    if not self:IsEnabled() then return false end
    if type(SetFloatingMarkerInfo) ~= "function" or MAP_PIN_TYPE_GROUP == nil then return false end
    local ok = pcall(SetFloatingMarkerInfo, MAP_PIN_TYPE_GROUP, 52,
        GROUP_MARKER_TEXTURE, GROUP_MARKER_TEXTURE, false, false)
    self.nativeMarkersApplied = ok == true
    return self.nativeMarkersApplied
end

function T:IsGroupMemberDead(unitTag)
    if not unitTag or unitTag == "companion" then return false end
    return safe(IsUnitDead, false, unitTag) == true
end

function T:IsCompanionDown()
    if safe(DoesUnitExist, false, "companion") ~= true then return false end

    -- ESO normally exposes a downed companion through IsUnitDead. Keep a
    -- health fallback as well so the glow can still react if that flag lags
    -- for a frame while the companion's Health has already reached zero.
    if safe(IsUnitDead, false, "companion") == true then return true end
    if type(GetUnitPower) == "function" and POWERTYPE_HEALTH ~= nil then
        local currentHealth, maxHealth = safe(GetUnitPower, nil, "companion", POWERTYPE_HEALTH)
        currentHealth = tonumber(currentHealth)
        maxHealth = tonumber(maxHealth)
        if currentHealth ~= nil and maxHealth ~= nil and maxHealth > 0 and currentHealth <= 0 then
            return true
        end
    end
    return false
end

function T:GetBaseRoleColor(unitTag)
    if safe(IsUnitGroupLeader, false, unitTag) == true then
        return 1.00, 0.82, 0.20, 1.00
    end
    local role = safe(GetGroupMemberSelectedRole, nil, unitTag)
    if role ~= nil then
        if LFG_ROLE_TANK ~= nil and role == LFG_ROLE_TANK then
            return 0.20, 0.55, 1.00, 1.00
        elseif LFG_ROLE_HEAL ~= nil and role == LFG_ROLE_HEAL then
            return 0.20, 1.00, 0.45, 1.00
        elseif LFG_ROLE_DPS ~= nil and role == LFG_ROLE_DPS then
            -- Keep living DPS clearly orange/amber. Pure red is reserved for death.
            return 1.00, 0.62, 0.12, 1.00
        end
    end
    return 0.15, 0.95, 1.00, 1.00
end

function T:GetRoleColor(unitTag)
    if self:IsGroupMemberDead(unitTag) then
        return DEAD_PLAYER_COLOR.r, DEAD_PLAYER_COLOR.g, DEAD_PLAYER_COLOR.b, 1.00
    end
    return self:GetBaseRoleColor(unitTag)
end

function T:NormalizeAlivePlayerColor(r, g, b)
    r, g, b = tonumber(r) or 0.15, tonumber(g) or 0.95, tonumber(b) or 1.00
    -- Red is a reserved state color. If an old/saved override is red-dominant,
    -- render it as amber while the player is alive so red means "dead" only.
    local redDominant = r >= 0.72 and g <= 0.48 and b <= 0.48
        and r >= (g + 0.18) and r >= (b + 0.18)
    if redDominant then
        return RESERVED_RED_FALLBACK.r, RESERVED_RED_FALLBACK.g, RESERVED_RED_FALLBACK.b
    end
    return r, g, b
end

function T:GetGroupMemberKey(unitTag)
    if not unitTag or unitTag == "companion" then return nil end
    local displayName = safe(GetUnitDisplayName, nil, unitTag)
    if type(displayName) == "string" and displayName ~= "" then return displayName end
    local unitName = safe(GetUnitName, nil, unitTag)
    if type(unitName) == "string" and unitName ~= "" then return unitName end
    return unitTag
end

function T:GetGroupOverride(unitTag, create)
    if not EPC.saved then return nil, nil end
    local key = self:GetGroupMemberKey(unitTag)
    if not key then return nil, nil end
    EPC.saved.teamVisibilityPlayerOverrides = EPC.saved.teamVisibilityPlayerOverrides or {}
    local profile = EPC.saved.teamVisibilityPlayerOverrides[key]
    if create and not profile then
        local r, g, b = self:GetBaseRoleColor(unitTag)
        profile = {
            enabled = true,
            color = { r = r, g = g, b = b },
            width = tonumber(EPC.saved.teamVisibilityBeamWidth) or BASE_BEAM_WIDTH_M,
            height = tonumber(EPC.saved.teamVisibilityBeamHeight) or BASE_BEAM_HEIGHT_M,
            opacity = tonumber(EPC.saved.teamVisibilityOpacity) or 0.24,
            throughWalls = EPC.saved.teamVisibilityThroughWalls ~= false,
        }
        EPC.saved.teamVisibilityPlayerOverrides[key] = profile
    end
    return profile, key
end

function T:GetCompanionVisualSettings()
    local saved = EPC.saved or {}
    local c = saved.teamVisibilityCompanionColor or DEFAULT_COMPANION_COLOR
    local dead = self:IsCompanionDown()
    local r = tonumber(c.r) or DEFAULT_COMPANION_COLOR.r
    local g = tonumber(c.g) or DEFAULT_COMPANION_COLOR.g
    local b = tonumber(c.b) or DEFAULT_COMPANION_COLOR.b
    if dead then
        r, g, b = DEAD_PLAYER_COLOR.r, DEAD_PLAYER_COLOR.g, DEAD_PLAYER_COLOR.b
    else
        -- Red is a state color for companions too, so an alive companion cannot
        -- be configured with the same red used to signal that it is down.
        r, g, b = self:NormalizeAlivePlayerColor(r, g, b)
    end
    return {
        r = r,
        g = g,
        b = b,
        a = 1.00,
        dead = dead,
        width = tonumber(saved.teamVisibilityCompanionBeamWidth) or BASE_BEAM_WIDTH_M,
        height = tonumber(saved.teamVisibilityCompanionBeamHeight) or BASE_BEAM_HEIGHT_M,
        opacity = tonumber(saved.teamVisibilityCompanionOpacity) or 0.24,
        throughWalls = saved.teamVisibilityCompanionThroughWalls ~= false,
    }
end

function T:GetMemberVisualSettings(unitTag)
    if unitTag == "companion" then
        return self:GetCompanionVisualSettings()
    end

    local dead = self:IsGroupMemberDead(unitTag)
    local profile = self:GetGroupOverride(unitTag, false)
    if profile and profile.enabled ~= false then
        local color = profile.color or {}
        local rr, rg, rb = self:GetBaseRoleColor(unitTag)
        local r = tonumber(color.r) or rr
        local g = tonumber(color.g) or rg
        local b = tonumber(color.b) or rb
        if dead then
            r, g, b = DEAD_PLAYER_COLOR.r, DEAD_PLAYER_COLOR.g, DEAD_PLAYER_COLOR.b
        else
            r, g, b = self:NormalizeAlivePlayerColor(r, g, b)
        end
        return {
            r = r, g = g, b = b, a = 1.00, dead = dead,
            width = tonumber(profile.width) or tonumber(EPC.saved and EPC.saved.teamVisibilityBeamWidth) or BASE_BEAM_WIDTH_M,
            height = tonumber(profile.height) or tonumber(EPC.saved and EPC.saved.teamVisibilityBeamHeight) or BASE_BEAM_HEIGHT_M,
            opacity = tonumber(profile.opacity) or tonumber(EPC.saved and EPC.saved.teamVisibilityOpacity) or 0.24,
            throughWalls = profile.throughWalls ~= false,
        }
    end

    local r, g, b, a = self:GetBaseRoleColor(unitTag)
    if dead then
        r, g, b = DEAD_PLAYER_COLOR.r, DEAD_PLAYER_COLOR.g, DEAD_PLAYER_COLOR.b
    else
        r, g, b = self:NormalizeAlivePlayerColor(r, g, b)
    end
    return {
        r = r, g = g, b = b, a = a, dead = dead,
        width = tonumber(EPC.saved and EPC.saved.teamVisibilityBeamWidth) or BASE_BEAM_WIDTH_M,
        height = tonumber(EPC.saved and EPC.saved.teamVisibilityBeamHeight) or BASE_BEAM_HEIGHT_M,
        opacity = tonumber(EPC.saved and EPC.saved.teamVisibilityOpacity) or 0.24,
        throughWalls = EPC.saved == nil or EPC.saved.teamVisibilityThroughWalls ~= false,
    }
end

function T:GetMemberColor(unitTag)
    local style = self:GetMemberVisualSettings(unitTag)
    return style.r, style.g, style.b, style.a or 1.00
end

function T:GetRawWorldPosition(unitTag)
    if type(GetUnitRawWorldPosition) ~= "function" then return nil end
    local zoneId, x, y, z = safe(GetUnitRawWorldPosition, nil, unitTag)
    x, y, z = tonumber(x), tonumber(y), tonumber(z)
    if zoneId == nil or x == nil or y == nil or z == nil then return nil end
    if x == 0 and y == 0 and z == 0 then return nil end
    return zoneId, x, y, z
end

function T:IsRenderableMember(unitTag)
    if safe(DoesUnitExist, false, unitTag) ~= true then return false, "unit missing" end
    if sameUnit(unitTag, "player") then return false, "self" end
    if unitTag ~= "companion" and type(IsUnitOnline) == "function" and safe(IsUnitOnline, true, unitTag) == false then
        return false, "offline"
    end

    local memberZone = select(1, self:GetRawWorldPosition(unitTag))
    local playerZone = select(1, self:GetRawWorldPosition("player"))
    if memberZone == nil then return false, "no member position" end
    if playerZone == nil then return false, "no player position" end
    if memberZone ~= playerZone then return false, "different world" end
    return true, "ok"
end

function T:EnsureWindows()
    if not self.particleWindow then
        local win = wm:CreateTopLevelWindow("EAS_TeamVisibilityParticleWindow")
        self.particleWindow = win
        win:SetHidden(false)
        win:SetDimensions(1, 1)
        win:SetMovable(false)
        win:SetMouseEnabled(false)
        win:SetClampedToScreen(false)
        win:ClearAnchors()
        win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, -10, -10)
        if type(win.Create3DRenderSpace) == "function" then win:Create3DRenderSpace() end
        if type(win.SetDrawLayer) == "function" then win:SetDrawLayer(DL_BACKGROUND) end
        if type(win.SetDrawTier) == "function" then win:SetDrawTier(DT_LOW) end
    end

    if not self.cameraWindow then
        local win = wm:CreateTopLevelWindow("EAS_TeamVisibilityCameraWindow")
        self.cameraWindow = win
        win:SetHidden(false)
        win:SetDimensions(1, 1)
        win:SetMouseEnabled(false)

        local control = wm:CreateControl("EAS_TeamVisibilityCameraControl", win, CT_TEXTURE)
        self.cameraControl = control
        control:SetHidden(true)
        if type(win.Create3DRenderSpace) == "function" then win:Create3DRenderSpace() end
        if type(control.Create3DRenderSpace) == "function" then control:Create3DRenderSpace() end
        if type(control.Set3DLocalDimensions) == "function" then control:Set3DLocalDimensions(0.01, 0.01) end
    end
end

function T:UpdateRenderOrigin()
    self:EnsureWindows()
    local win = self.particleWindow
    if not win or type(win.Get3DRenderSpaceOrigin) ~= "function" then return false end
    local ox, oy, oz = safe(win.Get3DRenderSpaceOrigin, nil, win)
    ox, oy, oz = tonumber(ox), tonumber(oy), tonumber(oz)
    if ox == nil or oy == nil or oz == nil then return false end
    -- Important: do NOT override the parent render-space origin here. ESO assigns
    -- the correct camera/world-relative origin when Create3DRenderSpace() runs.
    -- Read ESO's engine-provided origin and subtract it from each converted
    -- particle position; forcing our own origin moves particles
    -- far out of view after /reloadui.
    self.renderOriginX, self.renderOriginY, self.renderOriginZ = ox, oy, oz
    return true
end

function T:ResetRenderSpaces()
    self:EnsureWindows()
    self.renderOriginX, self.renderOriginY, self.renderOriginZ = nil, nil, nil

    local win = self.particleWindow
    if win and type(win.Destroy3DRenderSpace) == "function" and type(win.Create3DRenderSpace) == "function" then
        pcall(function()
            win:Destroy3DRenderSpace()
            win:Create3DRenderSpace()
        end)
    end

    local camWin = self.cameraWindow
    local cam = self.cameraControl
    if camWin and type(camWin.Destroy3DRenderSpace) == "function" and type(camWin.Create3DRenderSpace) == "function" then
        pcall(function()
            camWin:Destroy3DRenderSpace()
            camWin:Create3DRenderSpace()
        end)
    end
    if cam and type(cam.Destroy3DRenderSpace) == "function" and type(cam.Create3DRenderSpace) == "function" then
        pcall(function()
            cam:Destroy3DRenderSpace()
            cam:Create3DRenderSpace()
            cam:Set3DLocalDimensions(0.01, 0.01)
        end)
    end

    self:UpdateRenderOrigin()

    if self.particles then
        for _, p in ipairs(self.particles) do
            if p.texture then
                local tex = p.texture
                local pitch, yaw, roll = 0, 0, 0
                if type(tex.Get3DRenderSpaceOrientation) == "function" then
                    pitch, yaw, roll = tex:Get3DRenderSpaceOrientation()
                end
                local sx, sy = 1, 1
                if type(tex.Get3DLocalDimensions) == "function" then sx, sy = tex:Get3DLocalDimensions() end
                local useDepth = true
                if type(tex.Does3DRenderSpaceUseDepthBuffer) == "function" then useDepth = tex:Does3DRenderSpaceUseDepthBuffer() end
                if type(tex.Destroy3DRenderSpace) == "function" then pcall(function() tex:Destroy3DRenderSpace() end) end
                if type(tex.Create3DRenderSpace) == "function" then tex:Create3DRenderSpace() end
                if type(tex.Set3DRenderSpaceOrientation) == "function" then tex:Set3DRenderSpaceOrientation(pitch or 0, yaw or 0, roll or 0) end
                if type(tex.Set3DLocalDimensions) == "function" then tex:Set3DLocalDimensions(sx or 1, sy or 1) end
                if type(tex.Set3DRenderSpaceUsesDepthBuffer) == "function" then tex:Set3DRenderSpaceUsesDepthBuffer(useDepth ~= false) end
            end
        end
    end
end

function T:ApplyBeamTextureState(tex, flipHorizontal)
    if not tex then return false end
    local loaded = true
    if type(tex.IsTextureLoaded) == "function" then
        local ok, value = pcall(function() return tex:IsTextureLoaded() end)
        loaded = ok and value == true
    end
    if not loaded then return false end

    if type(tex.SetAddressMode) == "function" and TEX_MODE_CLAMP ~= nil then
        tex:SetAddressMode(TEX_MODE_CLAMP)
    end
    if type(tex.SetTextureCoords) == "function" then
        -- Sample the horizontal center of ESO's built-in lens flare. The alpha
        -- profile is strongest in the middle and fades toward the sides, so when
        -- stretched vertically it reads as a soft glowing pillar instead of a strip.
        if flipHorizontal then
            tex:SetTextureCoords(BEAM_U2, BEAM_U1, BEAM_V1, BEAM_V2)
        else
            tex:SetTextureCoords(BEAM_U1, BEAM_U2, BEAM_V1, BEAM_V2)
        end
    end
    if type(tex.SetTextureSampleProcessingWeight) == "function" then
        pcall(function()
            tex:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, 1.00)
            tex:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_ALPHA_AS_RGB, 0)
        end)
    end
    return true
end

function T:ApplyNativeSliceState(tex, flipHorizontal)
    if not tex then return false end
    if tex.easTextureSource ~= BEAM_SOURCE_TEXTURE then
        tex:SetTexture(BEAM_SOURCE_TEXTURE)
        tex.easTextureSource = BEAM_SOURCE_TEXTURE
    end
    if not self:ApplyBeamTextureState(tex, flipHorizontal) then return false end
    tex.easLoadedStyle = "eso_lensflare"
    return true
end

function T:EnsureLayerVisual(tex, layerIndex)
    local flipHorizontal = (tonumber(layerIndex) or 1) % 2 == 0
    self:ApplyNativeSliceState(tex, flipHorizontal)
    return flipHorizontal and "eso_lensflare_mirror" or "eso_lensflare"
end

function T:CreateParticle(index)
    self:EnsureWindows()
    self.particles = self.particles or {}
    if self.particles[index] then return self.particles[index] end

    local tex = wm:CreateControl(nil, self.particleWindow, CT_TEXTURE)
    tex:SetHidden(true)
    tex:ClearAnchors()
    tex:SetAnchor(CENTER, self.particleWindow, CENTER, 0, 0)
    if type(tex.SetTextureReleaseOption) == "function" and RELEASE_TEXTURE_AT_ZERO_REFERENCES ~= nil then
        tex:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
    end
    if type(tex.SetAddressMode) == "function" and TEX_MODE_CLAMP ~= nil then tex:SetAddressMode(TEX_MODE_CLAMP) end
    if type(tex.SetBlendMode) == "function" then
        if TEX_BLEND_MODE_ADD ~= nil then tex:SetBlendMode(TEX_BLEND_MODE_ADD)
        elseif TEX_BLEND_MODE_ALPHA ~= nil then tex:SetBlendMode(TEX_BLEND_MODE_ALPHA) end
    end
    tex:SetColor(1, 1, 1, 1)
    tex:SetAlpha(1)
    if type(tex.SetDesaturation) == "function" then tex:SetDesaturation(0) end
    if type(tex.SetDrawLevel) == "function" then tex:SetDrawLevel(DRAW_LEVEL_EFFECTS + (index % 4)) end
    if type(tex.Set3DRenderSpaceOrientation) == "function" then tex:Set3DRenderSpaceOrientation(0, 0, 0) end
    if type(tex.Create3DRenderSpace) == "function" and (type(tex.Has3DRenderSpace) ~= "function" or not tex:Has3DRenderSpace()) then
        tex:Create3DRenderSpace()
    end
    if type(tex.Set3DLocalDimensions) == "function" then tex:Set3DLocalDimensions(BASE_BEAM_WIDTH_M, BASE_BEAM_HEIGHT_M) end

    -- Built-in ESO texture only: no addon DDS preload/fallback state required.
    tex:SetTexture(BEAM_SOURCE_TEXTURE)
    tex.easTextureSource = BEAM_SOURCE_TEXTURE
    local initialFlip = (index % 2) == 0
    self:ApplyNativeSliceState(tex, initialFlip)
    zo_callLater(function() self:ApplyNativeSliceState(tex, initialFlip) end, 100)

    local particle = { texture = tex, index = index }
    self.particles[index] = particle
    return particle
end

function T:HideParticle(particle)
    if particle and particle.texture then particle.texture:SetHidden(true) end
end

function T:HideAllParticles()
    if self.particles then
        for _, p in ipairs(self.particles) do self:HideParticle(p) end
    end
end

function T:GetCameraHeading()
    if type(GetPlayerCameraHeading) == "function" then return safe(GetPlayerCameraHeading, 0) or 0 end
    return 0
end

function T:GetCameraForwardY()
    if not self.cameraControl or type(Set3DRenderSpaceToCurrentCamera) ~= "function" then return 0 end
    pcall(Set3DRenderSpaceToCurrentCamera, "EAS_TeamVisibilityCameraControl")
    if type(self.cameraControl.Get3DRenderSpaceForward) == "function" then
        local _, y = self.cameraControl:Get3DRenderSpaceForward()
        return tonumber(y) or 0
    end
    return 0
end

function T:GetDeadFlashFactor(nowMs)
    local now = tonumber(nowMs) or 0
    local period = DEAD_FLASH_PERIOD_MS
    if period <= 0 then return 1.00 end
    local phase = (now % period) / period
    local pulse = 0.5 - (0.5 * math.cos(phase * math.pi * 2))
    return DEAD_FLASH_MIN_FACTOR + ((1.00 - DEAD_FLASH_MIN_FACTOR) * pulse)
end

function T:PositionParticle(particle, unitTag, layerIndex)
    if not particle or not particle.texture then return false, "particle missing" end
    local zoneId, rawX, rawY, rawZ = self:GetRawWorldPosition(unitTag)
    if rawX == nil then return false, "no raw world position" end
    if type(WorldPositionToGuiRender3DPosition) ~= "function" then return false, "world conversion API unavailable" end

    -- Place the center around torso height so the beam mainly covers the character
    -- instead of extending like a long-distance sky column.
    local worldY = rawY + BEAM_CENTER_Y_CM
    local gx, gy, gz = safe(WorldPositionToGuiRender3DPosition, nil, rawX, worldY, rawZ)
    gx, gy, gz = tonumber(gx), tonumber(gy), tonumber(gz)
    if gx == nil or gy == nil or gz == nil then return false, "world-to-3D conversion failed" end

    -- Keep the proven live-origin placement path that visibly renders and stays
    -- attached to the companion.
    local baseX, baseY, baseZ = 0, 0, 0
    if self.particleWindow and type(self.particleWindow.Get3DRenderSpaceOrigin) == "function" then
        local ox, oy, oz = safe(self.particleWindow.Get3DRenderSpaceOrigin, nil, self.particleWindow)
        baseX, baseY, baseZ = tonumber(ox) or 0, tonumber(oy) or 0, tonumber(oz) or 0
        self.renderOriginX, self.renderOriginY, self.renderOriginZ = baseX, baseY, baseZ
    end
    gx, gy, gz = gx - baseX, gy - baseY, gz - baseZ

    local memberStyle = self:GetMemberVisualSettings(unitTag)
    local beamWidthM = tonumber(memberStyle.width) or BASE_BEAM_WIDTH_M
    local beamHeightM = tonumber(memberStyle.height) or BASE_BEAM_HEIGHT_M
    beamWidthM = zo_clamp(beamWidthM, 0.25, 5.00)
    beamHeightM = zo_clamp(beamHeightM, 1.50, 12.00)

    local tex = particle.texture
    local visualStyle = self:EnsureLayerVisual(tex, layerIndex)
    if type(tex.SetBlendMode) == "function" then
        if TEX_BLEND_MODE_ADD ~= nil then tex:SetBlendMode(TEX_BLEND_MODE_ADD)
        elseif TEX_BLEND_MODE_ALPHA ~= nil then tex:SetBlendMode(TEX_BLEND_MODE_ALPHA) end
    end
    if type(tex.Set3DRenderSpaceOrigin) == "function" then tex:Set3DRenderSpaceOrigin(gx, gy, gz) end
    local heading = self:GetCameraHeading()
    local pitch = BASE_PITCH + math.abs(self:GetCameraForwardY()) * BASE_PITCH
    if type(tex.Set3DRenderSpaceOrientation) == "function" then tex:Set3DRenderSpaceOrientation(pitch, heading, 0) end

    local throughWalls = memberStyle.throughWalls ~= false
    if type(tex.Set3DRenderSpaceUsesDepthBuffer) == "function" then tex:Set3DRenderSpaceUsesDepthBuffer(not throughWalls) end

    local r, g, b, roleAlpha = memberStyle.r, memberStyle.g, memberStyle.b, memberStyle.a or 1.00
    local opacity = tonumber(memberStyle.opacity) or 0.24
    local alpha = zo_clamp(math.min(roleAlpha or 1, opacity), 0.03, 1.00)

    -- Keep the normal two-layer glow soft at lower settings, but allow the
    -- intensity sliders to reach a genuinely bright additive glow at the top.
    if LAYERS_PER_UNIT > 1 then
        alpha = zo_clamp(alpha * 0.78, 0.02, 0.90)
    end

    if memberStyle.dead then
        -- Dead/downed red has its own brightness control so it can stand out
        -- even when the member's normal glow is intentionally dim. At 100%,
        -- the additive red layers are allowed to reach full alpha at the pulse peak.
        local deadOpacity = tonumber(EPC.saved and EPC.saved.teamVisibilityDeadOpacity) or 1.00
        local nowMs = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
        alpha = zo_clamp(deadOpacity * self:GetDeadFlashFactor(nowMs), 0.01, 1.00)
    end
    if type(tex.Set3DLocalDimensions) == "function" then
        tex:Set3DLocalDimensions(beamWidthM, beamHeightM)
    end
    tex:SetColor(r, g, b, alpha)
    tex:SetAlpha(alpha)
    if type(tex.SetVertexColors) == "function" then
        tex:SetVertexColors(1 + 2, r, g, b, alpha)
        tex:SetVertexColors(4 + 8, r, g, b, alpha)
    end
    tex:SetHidden(false)

    self.lastRenderInfo = {
        unitTag = unitTag,
        zoneId = zoneId,
        rawX = rawX,
        rawY = rawY,
        rawZ = rawZ,
        guiX = gx,
        guiY = gy,
        guiZ = gz,
        widthMeters = beamWidthM,
        heightMeters = beamHeightM,
        depth = not throughWalls,
    }
    return true, "ok"
end

function T:RefreshParticles()
    if not self:LightsEnabled() then
        self.lastStatus = "Team beam disabled in settings."
        self:HideAllParticles()
        return
    end

    local hasCompanion = safe(DoesUnitExist, false, "companion") == true
    local groupSize = tonumber(safe(GetGroupSize, 0)) or 0
    if not hasCompanion and groupSize <= 1 then
        if (tonumber(self.lastVisibleParticleCount029315) or 0) > 0 then self:HideAllParticles() end
        self.lastVisibleParticleCount029315 = 0
        self.lastStatus = "No active companion or grouped teammate available."
        return
    end

    self:EnsureWindows()
    -- Do not cache/lock the parent origin here. PositionParticle reads ESO's live
    -- parent 3D origin on every placement, matching the proven reference addon.
    local used, visible = 0, 0
    local reasons = {}
    local companionVisible = false

    local now = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
    self.lastValidUnitRender = self.lastValidUnitRender or {}

    local function renderUnit(unitTag)
        local renderable, why = self:IsRenderableMember(unitTag)
        local lastValid = self.lastValidUnitRender[unitTag]

        -- ESO can briefly return an invalid/zero companion or group position on
        -- a frame even though the unit is still present.  Do not immediately
        -- hide a beam that was just positioned successfully; keep the last valid
        -- 3D placement for a short grace period and update it on the next good tick.
        if not renderable then
            if lastValid and (now - lastValid) <= POSITION_GRACE_MS then
                local unitHadVisible = false
                for layer = 1, LAYERS_PER_UNIT do
                    used = used + 1
                    local p = self:CreateParticle(used)
                    if p and p.texture and not p.texture:IsHidden() then
                        visible = visible + 1
                        unitHadVisible = true
                    end
                end
                if unitTag == "companion" and unitHadVisible then companionVisible = true end
                reasons[#reasons + 1] = unitTag .. ": transient " .. tostring(why)
                return
            end
            reasons[#reasons + 1] = unitTag .. ": " .. tostring(why)
            return
        end

        local unitHadVisible = false
        local anyPositioned = false
        for layer = 1, LAYERS_PER_UNIT do
            used = used + 1
            local p = self:CreateParticle(used)
            local ok, reason = self:PositionParticle(p, unitTag, layer)
            if ok then
                visible = visible + 1
                unitHadVisible = true
                anyPositioned = true
            else
                -- Preserve the last valid particle briefly rather than flickering off.
                if lastValid and (now - lastValid) <= POSITION_GRACE_MS and p and p.texture and not p.texture:IsHidden() then
                    visible = visible + 1
                    unitHadVisible = true
                else
                    self:HideParticle(p)
                end
                reasons[#reasons + 1] = unitTag .. ": " .. tostring(reason)
            end
        end
        if anyPositioned then self.lastValidUnitRender[unitTag] = now end
        if unitTag == "companion" and unitHadVisible then companionVisible = true end
    end

    if hasCompanion then renderUnit("companion") end

    if groupSize > 1 then
        for i = 1, math.min(groupSize, MAX_GROUP_MEMBERS) do
            local unitTag = "group" .. tostring(i)
            if not sameUnit(unitTag, "player") then renderUnit(unitTag) end
        end
    end

    if self.particles then
        for i = used + 1, #self.particles do self:HideParticle(self.particles[i]) end
    end

    self.lastVisibleParticleCount029315 = visible
    if visible > 0 then
        if companionVisible and groupSize <= 1 then
            self.lastStatus = string.format("Companion glow active (%d particles).", visible)
        elseif companionVisible then
            self.lastStatus = string.format("Team glow active for companion/group (%d particles).", visible)
        else
            self.lastStatus = string.format("Team glow active (%d particles).", visible)
        end
    elseif safe(DoesUnitExist, false, "companion") == true then
        self.lastStatus = "Companion detected, but glow could not render: " .. tostring(reasons[1] or "unknown")
    elseif groupSize > 1 then
        self.lastStatus = "Group detected, but glow could not render: " .. tostring(reasons[1] or "unknown")
    else
        self.lastStatus = "No active companion or grouped teammate available."
    end
end

function T:GetStatusText()
    return self.lastStatus or "Team Visibility initialized."
end

function T:RefreshSettings()
    if self:IsEnabled() then self:ApplyNativeGroupMarkers() end
    self:RefreshParticles()
end

function T:Initialize()
    self.particles = {}
    self.lastStatus = "Team Visibility initialized."
    self.lastRenderInfo = nil
    self.lastValidUnitRender = {}

    if EPC.saved then
        local styleVersion = tonumber(EPC.saved.teamVisibilityStyleVersion) or 0
        if styleVersion < 22 then
            EPC.saved.teamVisibilityBeamWidth = tonumber(EPC.saved.teamVisibilityBeamWidth) or BASE_BEAM_WIDTH_M
            EPC.saved.teamVisibilityBeamHeight = tonumber(EPC.saved.teamVisibilityBeamHeight) or BASE_BEAM_HEIGHT_M
            EPC.saved.teamVisibilityOpacity = tonumber(EPC.saved.teamVisibilityOpacity) or 0.24
            EPC.saved.teamVisibilityPlayerOverrides = EPC.saved.teamVisibilityPlayerOverrides or {}
            EPC.saved.teamVisibilitySelectedGroupSlot = tonumber(EPC.saved.teamVisibilitySelectedGroupSlot) or 1
            EPC.saved.teamVisibilityCompanionColor = EPC.saved.teamVisibilityCompanionColor or { r = DEFAULT_COMPANION_COLOR.r, g = DEFAULT_COMPANION_COLOR.g, b = DEFAULT_COMPANION_COLOR.b }
            EPC.saved.teamVisibilityCompanionBeamWidth = tonumber(EPC.saved.teamVisibilityCompanionBeamWidth) or EPC.saved.teamVisibilityBeamWidth or BASE_BEAM_WIDTH_M
            EPC.saved.teamVisibilityCompanionBeamHeight = tonumber(EPC.saved.teamVisibilityCompanionBeamHeight) or EPC.saved.teamVisibilityBeamHeight or BASE_BEAM_HEIGHT_M
            EPC.saved.teamVisibilityCompanionOpacity = tonumber(EPC.saved.teamVisibilityCompanionOpacity) or EPC.saved.teamVisibilityOpacity or 0.24
            if EPC.saved.teamVisibilityCompanionThroughWalls == nil then EPC.saved.teamVisibilityCompanionThroughWalls = EPC.saved.teamVisibilityThroughWalls ~= false end
            EPC.saved.teamVisibilityEnabled = true
            EPC.saved.teamVisibilityLightsEnabled = true
            styleVersion = 22
        end
        if styleVersion < 24 then
            EPC.saved.teamVisibilityPlayerOverrides = EPC.saved.teamVisibilityPlayerOverrides or {}
            for _, profile in pairs(EPC.saved.teamVisibilityPlayerOverrides) do
                if type(profile) == "table" and type(profile.color) == "table" then
                    local r, g, b = self:NormalizeAlivePlayerColor(profile.color.r, profile.color.g, profile.color.b)
                    profile.color = { r = r, g = g, b = b }
                end
            end
            styleVersion = 24
        end
        if styleVersion < 25 then
            EPC.saved.teamVisibilityDeadOpacity = tonumber(EPC.saved.teamVisibilityDeadOpacity) or 1.00
            styleVersion = 25
        end
        if styleVersion < 26 then
            local companionColor = EPC.saved.teamVisibilityCompanionColor or DEFAULT_COMPANION_COLOR
            local r, g, b = self:NormalizeAlivePlayerColor(companionColor.r, companionColor.g, companionColor.b)
            EPC.saved.teamVisibilityCompanionColor = { r = r, g = g, b = b }
            styleVersion = 26
        end
        EPC.saved.teamVisibilityStyleVersion = styleVersion
    end

    self:EnsureWindows()
    self:UpdateRenderOrigin()
    self:ApplyNativeGroupMarkers()

    local prefix = (EPC.name or "EAS") .. "_TeamVisibility"
    EVENT_MANAGER:RegisterForUpdate(prefix .. "_Particles", UPDATE_MS, function()
        self:RefreshParticles()
    end)

    if EVENT_PLAYER_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Activated", EVENT_PLAYER_ACTIVATED, function()
            self:HideAllParticles()
            self:ApplyNativeGroupMarkers()
            zo_callLater(function()
                self:ResetRenderSpaces()
                self:RefreshParticles()
            end, WORLD_REFRESH_MS)
        end)
    end

    if EVENT_GROUP_UPDATE then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Group", EVENT_GROUP_UPDATE, function()
            self:RefreshParticles()
        end)
    end

    if EVENT_ZONE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Zone", EVENT_ZONE_CHANGED, function(_, unitTag)
            if not unitTag or unitTag == "player" then
                self:HideAllParticles()
                zo_callLater(function()
                    self:ResetRenderSpaces()
                    self:RefreshParticles()
                end, WORLD_REFRESH_MS)
            end
        end)
    end

    SLASH_COMMANDS["/easteam"] = function()
        self:RefreshParticles()
        local extra = ""
        local p = self.particles and self.particles[1]
        if p and p.texture then
            local tex = p.texture
            local loaded = "n/a"
            local okLoaded, valueLoaded = pcall(function() return tex:IsTextureLoaded() end)
            if okLoaded then loaded = valueLoaded end
            local has3D = type(tex.Has3DRenderSpace) == "function" and tex:Has3DRenderSpace() or "n/a"
            local hidden = tex:IsHidden()
            local sx, sy = "n/a", "n/a"
            if type(tex.Get3DLocalDimensions) == "function" then sx, sy = tex:Get3DLocalDimensions() end
            local depth = type(tex.Does3DRenderSpaceUseDepthBuffer) == "function" and tex:Does3DRenderSpaceUseDepthBuffer() or "n/a"
            extra = string.format(" | textureLoaded=%s source=%s has3D=%s hidden=%s size=%s,%s depth=%s",
                tostring(loaded), tostring(tex.easTextureSource or "unknown"), tostring(has3D), tostring(hidden), tostring(sx), tostring(sy), tostring(depth))
        end
        if self.renderOriginX ~= nil then
            extra = extra .. string.format(" | root=%s,%s,%s", tostring(self.renderOriginX), tostring(self.renderOriginY), tostring(self.renderOriginZ))
        end
        if self.lastRenderInfo then
            local i = self.lastRenderInfo
            extra = extra .. string.format(" | %s zone=%s raw=%s,%s,%s gui=%s,%s,%s",
                tostring(i.unitTag), tostring(i.zoneId), tostring(i.rawX), tostring(i.rawY), tostring(i.rawZ),
                tostring(i.guiX), tostring(i.guiY), tostring(i.guiZ))
        end
        extra = extra .. " | style=eso-soft-body-lensflare-beam mirrored=true anchor=full-character-tall roundedCaps=true originMode=live graceMs=" .. tostring(POSITION_GRACE_MS)
        extra = extra .. " | texture=builtin-lensflare blend=additive oneBeam=true"
        d("ESO Adventurer Suite - Team Visibility: " .. self:GetStatusText() .. extra)
    end

    zo_callLater(function()
        self:ResetRenderSpaces()
        self:RefreshParticles()
    end, 500)
end
