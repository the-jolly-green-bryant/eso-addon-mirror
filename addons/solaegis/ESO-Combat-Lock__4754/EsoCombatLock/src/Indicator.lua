-- EsoCombatLock - on-screen lock indicator (companion icon + lock overlay)

local ECL = EsoCombatLock
ECL.Indicator = ECL.Indicator or {}
local Indicator = ECL.Indicator

local FRAME_NAME = "EsoCombatLockIndicator"
local LOCK_TEXTURE = "/esoui/art/miscellaneous/locked_up.dds"
local FALLBACK_TEXTURE = "/esoui/art/icons/ability_undaunted_001.dds"
local EVENT_NAMESPACE = ECL.NAME .. "_Indicator"
local RECONCILE_INTERVAL_MS = 500
local RECONCILE_UPDATE_NAME = EVENT_NAMESPACE .. "_Reconcile"

local frame = nil
local backdrop = nil
local iconTexture = nil
local lockTexture = nil
local previewLabel = nil
local playerInCombat = false

local function db()
    return ECL.db
end

local function isGuardArmed()
    return ECL.Guard and ECL.Guard.IsArmed and ECL.Guard.IsArmed()
end

local function isInCombat()
    return playerInCombat
end

local function shouldShowLockOverlay()
    return isGuardArmed() and isInCombat()
end

local function shouldShow()
    if ECL.IsIndicatorAlwaysVisible() then
        return true
    end
    return shouldShowLockOverlay()
end

local function applySize()
    if not frame or not db() then
        return
    end
    local size = db().indicatorSize or ECL.defaults.indicatorSize or 64
    frame:SetDimensions(size, size)
    if lockTexture then
        local lockSize = zo_max(16, zo_floor(size / 3))
        lockTexture:SetDimensions(lockSize, lockSize)
    end
end

local function savePosition()
    if not frame or not db() then
        return
    end
    local left = frame:GetLeft()
    local top = frame:GetTop()
    local cx, cy = GuiRoot:GetCenter()
    db().indicatorX = left - cx
    db().indicatorY = top - cy
end

local function restorePosition()
    if not frame or not db() then
        return
    end
    local x = db().indicatorX or 0
    local y = db().indicatorY or -200
    frame:ClearAnchors()
    frame:SetAnchor(TOPLEFT, GuiRoot, CENTER, x, y)
end

local function setCompanionIcon(collectibleId)
    if not iconTexture then
        return
    end
    local texture = FALLBACK_TEXTURE
    if collectibleId and collectibleId > 0 and GetCollectibleIcon then
        local icon = GetCollectibleIcon(collectibleId)
        if icon and icon ~= "" then
            texture = icon
        end
    end
    iconTexture:SetTexture(texture)
end

local function refreshCompanionIcon()
    local collectibleId = nil
    if isGuardArmed() and ECL.Guard.GetState then
        collectibleId = ECL.Guard.GetState().companionCollectibleId
    end
    if not collectibleId and ECL.Slots and ECL.Slots.GetActiveCompanionCollectibleId then
        collectibleId = ECL.Slots.GetActiveCompanionCollectibleId()
    end
    setCompanionIcon(collectibleId)
end

local function refreshVisibility()
    if not frame then
        return
    end
    local show = shouldShow()
    local locked = ECL.IsIndicatorLocked()

    frame:SetHidden(not show)
    frame:SetMovable(show and not locked)
    frame:SetMouseEnabled(show and not locked)

    if backdrop then
        backdrop:SetHidden(not show or locked)
    end
    if previewLabel then
        previewLabel:SetHidden(not show or locked)
    end
    if lockTexture then
        lockTexture:SetHidden(not shouldShowLockOverlay())
    end

    ECL.Debug(string.format(
        "Indicator refresh: show=%s armed=%s inCombat=%s always=%s hiddenAfter=%s",
        tostring(show),
        tostring(isGuardArmed()),
        tostring(playerInCombat),
        tostring(ECL.IsIndicatorAlwaysVisible()),
        tostring(frame:IsHidden())
    ))
end

local function reconcileVisibility()
    if not frame then
        return
    end
    playerInCombat = IsUnitInCombat and IsUnitInCombat("player") == true
    local show = shouldShow()
    if frame:IsHidden() ~= (not show) then
        refreshVisibility()
    end
end

local function applyLockState()
    refreshVisibility()
end

function Indicator.Initialize()
    if frame then
        applySize()
        restorePosition()
        applyLockState()
        return
    end

    frame = WINDOW_MANAGER:CreateTopLevelWindow(FRAME_NAME)
    frame:SetClampedToScreen(true)
    frame:SetDrawLayer(DL_OVERLAY)
    frame:SetHidden(true)

    backdrop = WINDOW_MANAGER:CreateControl(nil, frame, CT_BACKDROP)
    backdrop:SetAnchorFill()
    backdrop:SetCenterColor(0.1, 0.15, 0.2, 0.55)
    backdrop:SetEdgeTexture("/esoui/art/chatwindow/chat_bg_edge.dds", 256, 256, 32)
    backdrop:SetDrawLayer(DL_OVERLAY)

    iconTexture = WINDOW_MANAGER:CreateControl(nil, frame, CT_TEXTURE)
    iconTexture:SetAnchor(CENTER)
    iconTexture:SetDimensions(1, 1)
    iconTexture:SetAnchorFill()
    iconTexture:SetDrawLayer(DL_OVERLAY)

    lockTexture = WINDOW_MANAGER:CreateControl(nil, frame, CT_TEXTURE)
    lockTexture:SetTexture(LOCK_TEXTURE)
    lockTexture:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -2, -2)
    lockTexture:SetDrawLayer(DL_OVERLAY)

    previewLabel = WINDOW_MANAGER:CreateControl(nil, frame, CT_LABEL)
    previewLabel:SetFont("$(MEDIUM_FONT)|$(KB_14)|soft-shadow-thin")
    previewLabel:SetColor(0.9, 0.9, 0.7, 1)
    previewLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    previewLabel:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    previewLabel:SetAnchor(BOTTOM, frame, TOP, 0, -4)
    previewLabel:SetText("Drag to position")
    previewLabel:SetDrawLayer(DL_OVERLAY)

    frame:SetHandler("OnMoveStop", function()
        savePosition()
        ECL.Debug("Indicator position saved")
    end)

    applySize()
    restorePosition()
    refreshCompanionIcon()
    applyLockState()
end

local function onCompanionStateChanged()
    refreshCompanionIcon()
    refreshVisibility()
end

local function onCombatState(_, inCombat)
    playerInCombat = inCombat == true
    refreshVisibility()
end

function Indicator.Register()
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ACTIVE_COMPANION_STATE_CHANGED, onCompanionStateChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_COMBAT_STATE, onCombatState)
    EVENT_MANAGER:UnregisterForUpdate(RECONCILE_UPDATE_NAME)
    EVENT_MANAGER:RegisterForUpdate(RECONCILE_UPDATE_NAME, RECONCILE_INTERVAL_MS, reconcileVisibility)
    playerInCombat = IsUnitInCombat and IsUnitInCombat("player") == true
    refreshCompanionIcon()
    refreshVisibility()
end

function Indicator.OnArmed(collectibleId)
    setCompanionIcon(collectibleId)
    refreshVisibility()
end

function Indicator.OnDisarmed()
    refreshVisibility()
    refreshCompanionIcon()
end

function Indicator.GetDebugState()
    return {
        hidden = frame and frame:IsHidden(),
        show = shouldShow(),
        playerInCombat = playerInCombat,
        apiInCombat = IsUnitInCombat and IsUnitInCombat("player"),
        armed = isGuardArmed(),
    }
end

function Indicator.ApplyLockState()
    applyLockState()
end

function Indicator.Refresh()
    applyLockState()
end

function Indicator.ResetPosition()
    if not db() then
        return
    end
    db().indicatorX = ECL.defaults.indicatorX
    db().indicatorY = ECL.defaults.indicatorY
    restorePosition()
    ECL.Chat("Indicator location reset to default")
    refreshVisibility()
end

function Indicator.TogglePositionLock()
    if not db() then
        return
    end
    db().indicatorLocked = not ECL.IsIndicatorLocked()
    Indicator.Refresh()
    if db().indicatorLocked then
        ECL.Chat("Indicator position locked")
    else
        ECL.Chat("Indicator position unlocked — drag to reposition")
    end
end
