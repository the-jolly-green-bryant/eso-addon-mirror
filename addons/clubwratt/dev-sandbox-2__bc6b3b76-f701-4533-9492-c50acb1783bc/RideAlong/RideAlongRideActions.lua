-- RideAlongRideActions.lua: Wires the ride prompt into the HUD reticle and the
-- ride action into the interact key.
--
-- Prompt: post-hook ZO_Reticle:UpdateInteractText (runs every reticle frame).
-- When the base game left the interact prompt hidden and the reticle target is
-- a ridable group mount, we reuse the reticle's own interact elements so the
-- prompt renders with the platform's real interact key icon (X on PlayStation).
--
-- Action: pre-hook INTERACTIVE_WHEEL_MANAGER:StartInteraction. The
-- GAME_CAMERA_INTERACT binding (see ingame/globals/bindings.xml) calls it on
-- every interact press before GameCameraInteractStart(), so it fires exactly
-- when the user presses the interact button. We return false to let the normal
-- flow continue: with no world interactable under the reticle (guaranteed by
-- the prompt condition) the native interact start is a no-op.

local RideUtils = RideAlong.RideUtils

local RideAlongRideActions = {}

---@param reticle table The ZO_Reticle instance (RETICLE)
---@param rawName string
---@param previousName string|nil Name shown last frame, to skip redundant string formatting
local function ShowRidePrompt(reticle, rawName, previousName)
    -- The base game only writes these text controls when it claims the prompt
    -- itself (in which case previousName was reset to nil), so while the target
    -- is unchanged the texts from the previous frame are still intact and we
    -- can skip the per-frame zo_strformat allocations.
    if rawName ~= previousName then
        reticle.interactKeybindButton:SetText(zo_strformat(SI_GAME_CAMERA_TARGET, GetString(SI_PLAYER_TO_PLAYER_RIDE_MOUNT)))
        reticle.interactContext:SetText(zo_strformat(SI_PLAYER_TO_PLAYER_TARGET, rawName))
        reticle.interactKeybindButton:ShowKeyIcon()
    end
    reticle.interact:SetHidden(false)
end

---Post-hook body for ZO_Reticle:UpdateInteractText.
---@param reticle table The ZO_Reticle instance (RETICLE)
local function OnReticleUpdated(reticle)
    local state = RideAlong.state
    local previousName = state.ridePromptTargetName
    state.ridePromptTargetName = nil

    if not state.savedVars.enabled then
        return
    end
    if not RideUtils.CanShowRidePrompt() then
        return
    end
    -- The base game already claimed the prompt for a real world interaction
    -- (or a quest tool); never fight it.
    if not reticle.interact:IsHidden() then
        return
    end

    local rawName = RideUtils.GetRideTargetName()
    if not rawName then
        return
    end

    state.ridePromptTargetName = rawName
    ShowRidePrompt(reticle, rawName, previousName)
end

---Pre-hook body for INTERACTIVE_WHEEL_MANAGER:StartInteraction.
---@param _manager table
---@param interactiveWheelType number
---@return boolean handled Always false so the native interact flow continues
local function OnInteractPressed(_manager, interactiveWheelType)
    -- GAME_CAMERA_INTERACT starts the fishing-type wheel; other wheel types
    -- (utility, target markers) come from different keys.
    if interactiveWheelType ~= ZO_INTERACTIVE_WHEEL_TYPE_FISHING then
        return false
    end

    local state = RideAlong.state
    if not state.ridePromptTargetName then
        return false
    end
    -- The prompt state is at most one frame old; revalidate before acting.
    local rawName = RideUtils.GetRideTargetName()
    if not rawName or rawName ~= state.ridePromptTargetName then
        return false
    end

    UseMountAsPassenger(rawName)
    return false
end

function RideAlongRideActions.Initialize()
    if not RETICLE or not INTERACTIVE_WHEEL_MANAGER then
        RideAlong.Log("ERROR: RETICLE or INTERACTIVE_WHEEL_MANAGER not available; ride prompt not installed")
        return
    end

    ZO_PostHook(RETICLE, "UpdateInteractText", OnReticleUpdated)
    ZO_PreHook(INTERACTIVE_WHEEL_MANAGER, "StartInteraction", OnInteractPressed)
end

RideAlong.RideActions = RideAlongRideActions
