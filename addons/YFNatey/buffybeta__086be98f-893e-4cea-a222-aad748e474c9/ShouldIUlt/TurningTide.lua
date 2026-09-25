---=============================================================================
-- Turning Tide Tracker
--
-- Turning Tide (Set): Can only proc every 10 seconds
-- - NORMAL ICON: Buff is active on player
-- - RED-TINTED ICON with countdown: 10-second cooldown after buff disappears
--   (whether consumed by bash or expired naturally)
-- - HIDDEN: After cooldown completes, waiting for next proc
---=============================================================================

local TURNING_TIDE_ID        = 167350
local TURNING_TIDE_NAME      = "Turning Tide"
local COOLDOWN_DURATION_MS   = 15000 -- 10 seconds (matches set's internal cooldown)
local TIMER_UPDATE_NAME      = "ShouldIUltTurningTideTimer"

-- State
ShouldIUlt.ttIsActive        = false -- buff currently on player
ShouldIUlt.ttCooldown        = false -- in the 10-second cooldown phase
ShouldIUlt.ttCooldownEndTime = 0     -- when the cooldown expires
ShouldIUlt.ttDragging        = false

---=============================================================================
-- Position helpers
---=============================================================================

function ShouldIUlt:UpdateTurningTidePosition()
    local container = TurningTideContainer
    if not container then return end

    local maxX = math.floor(GuiRoot:GetWidth() / 2)
    local maxY = math.floor(GuiRoot:GetHeight() / 2)

    local x = math.max(-maxX, math.min(maxX, ShouldIUlt.savedVars.turningTidePositionX))
    local y = math.max(-maxY, math.min(maxY, ShouldIUlt.savedVars.turningTidePositionY))

    ShouldIUlt.savedVars.turningTidePositionX = x
    ShouldIUlt.savedVars.turningTidePositionY = y

    container:ClearAnchors()
    container:SetAnchor(CENTER, GuiRoot, CENTER, x, y)
end

function ShouldIUlt:GetTurningTideCooldownRemaining()
    if not self:IsTurningTideCooldownActive() then
        return 0
    end

    return self.turningTideCooldownEndTime - GetGameTimeMilliseconds()
end

---=============================================================================
-- Visual update
---=============================================================================

function ShouldIUlt:UpdateTurningTideUI()
    local container = TurningTideContainer
    if not container then return end

    -- Respect the enable toggle
    if not ShouldIUlt.savedVars.trackTurningTide then
        container:SetHidden(true)
        return
    end

    local iconControl = container:GetNamedChild("Icon")
    local timerLabel = container:GetNamedChild("Timer")
    local iconSize = ShouldIUlt.savedVars.turningTideIconSize or 50

    container:SetDimensions(iconSize, iconSize)
    if iconControl then
        iconControl:SetDimensions(iconSize, iconSize)

        -- Get the Turning Tide icon from the database
        local iconPath = self:GetBuffIcon(TURNING_TIDE_NAME)
        iconControl:SetTexture(iconPath)
    end

    local opacity = ShouldIUlt.savedVars.turningTideOpacity or 1.0

    if self.ttIsActive then
        -- NORMAL: Buff is active (ready to bash or will expire naturally)
        container:SetHidden(false)
        container:SetAlpha(opacity)
        if iconControl then
            iconControl:SetColor(1, 1, 1, 1) -- Normal white/full color
        end
        if timerLabel then
            timerLabel:SetText("")
            timerLabel:SetHidden(true)
        end
    elseif self:IsTurningTideCooldownActive() then
        -- RED: 10-second cooldown after buff disappears (bash or natural expiry)
        -- Shows remaining time until next proc is possible
        container:SetHidden(false)
        container:SetAlpha(opacity)
        if iconControl then
            iconControl:SetColor(1, 0.02, 0, 1) -- Red tint (matches off-balance immunity)
        end
        if timerLabel then
            local remaining = self:GetTurningTideCooldownRemaining()
            if remaining > 0 then
                timerLabel:SetText(string.format("%.1f", remaining / 1000))
                timerLabel:SetHidden(false)
            else
                timerLabel:SetText("")
                timerLabel:SetHidden(true)
            end
        end
    else
        -- HIDDEN: Cooldown complete, waiting for next proc
        container:SetHidden(true)
    end
end

---=============================================================================
-- Event hook — monitors when Turning Tide appears/disappears
---=============================================================================

function ShouldIUlt:OnTurningTideEffectChanged(changeType, abilityId)
    if abilityId ~= TURNING_TIDE_ID then return end
    if not ShouldIUlt.savedVars.trackTurningTide then return end

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        -- Buff appeared/refreshed: show normal icon, cancel any cooldown
        self:ClearTurningTideCooldown()
        self.ttIsActive = true
        self:UpdateTurningTideUI()
    elseif changeType == EFFECT_RESULT_FADED then
        -- Buff disappeared (consumed by bash OR expired naturally)
        -- Start the 10-second cooldown immediately, turn red
        self.ttIsActive = false
        self:StartTurningTideCooldown()
    end
end

---=============================================================================
-- Drag support
---=============================================================================

function ShouldIUlt:SetupTurningTideDrag()
    local container = TurningTideContainer
    if not container then return end

    container:SetHandler("OnMoveStop", function(ctrl)
        local left, top = ctrl:GetScreenRect()
        local screenW = GuiRoot:GetWidth()
        local screenH = GuiRoot:GetHeight()
        local size = ShouldIUlt.savedVars.turningTideIconSize or 50
        ShouldIUlt.savedVars.turningTidePositionX = math.floor((left + size / 2) - screenW / 2)
        ShouldIUlt.savedVars.turningTidePositionY = math.floor((top + size / 2) - screenH / 2)
    end)
end

---=============================================================================
-- Initialize
---=============================================================================

function ShouldIUlt:InitializeTurningTideTracker()
    self:UpdateTurningTidePosition()
    self:SetupTurningTideDrag()

    local iconControl = TurningTideContainer and TurningTideContainer:GetNamedChild("Icon")
    local iconSize = ShouldIUlt.savedVars.turningTideIconSize or 50
    if iconControl then
        iconControl:SetDimensions(iconSize, iconSize)
        -- Set the icon texture
        local iconPath = self:GetBuffIcon(TURNING_TIDE_NAME)
        iconControl:SetTexture(iconPath)
    end

    -- Scan for the buff at login/reload (in case it's already active)
    local numBuffs = GetNumBuffs("player")
    for i = 0, numBuffs do
        local buffName, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        if abilityId == TURNING_TIDE_ID then
            self.ttIsActive = true
            break
        end
    end

    self:UpdateTurningTideUI()
end
