FishingStateMachine =
{
    name            = "FishingStateMachine",
    currentState    = 0,
    angle           = 0,
    swimming        = false,
    state           = {}
}

FishingStateMachine.state     = {
    idle      =  0, --Running around, neither looking at an interactable nor fighting
    lookaway  =  1, --Looking at an interactable which is NOT a fishing hole
    looking   =  2, --Looking at a fishing hole
    depleted  =  3, --fishing hole just depleted

    nobait    =  5, --Looking at a fishing hole, with NO bait equipped
    fishing   =  6, --Fishing
    reelin    =  7, --Reel in!
    loot      =  8, --Lootscreen open, only right after Reel in!
    invfull   =  9, --No free inventory slots

    fight     = 14, --Fighting / Enemys taunted
    dead      = 15  --Dead
}

--local logger = LibDebugLogger(FishingStateMachine.name)

-- [[ forward declared functions ]] ----------------------------------------------------
local _lootSceneCB

--[[ local functions ]] ----------------------------------------------------------------

-- This function changes and publishes the fishing state
-- fight state is very strict, it is only overwritten by "dead" or "idle"+"not fighting" states
local function _changeState(state, overwriteFight)
    local this = FishingStateMachine

    if this.currentState == state then return end

    if this.currentState == this.state.fight and not overwriteFight then return end

    if this.swimming and state == this.state.looking then state = this.state.lookaway end

    EVENT_MANAGER:UnregisterForUpdate(this.name .. "STATE_REELIN_END")
    EVENT_MANAGER:UnregisterForUpdate(this.name .. "STATE_DEPLETED_END")
    EVENT_MANAGER:UnregisterForEvent(this.name .. "OnSlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)

    if state == this.state.depleted then
        EVENT_MANAGER:RegisterForUpdate(this.name .. "STATE_DEPLETED_END", 3000, function()
            if this.currentState == this.state.depleted then _changeState(this.state.idle) end
        end)

    elseif state == this.state.fishing then
        this.angle = (math.deg(GetPlayerCameraHeading())-180) % 360

        if not GetSetting_Bool(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT) then -- false = auto_loot off
            LOOT_SCENE:RegisterCallback("StateChange", _lootSceneCB)
        end
        EVENT_MANAGER:RegisterForEvent(this.name .. "OnSlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function()
            if this.currentState == this.state.fishing then _changeState(this.state.reelin) end
        end)

    elseif state == this.state.reelin then
        EVENT_MANAGER:RegisterForUpdate(this.name .. "STATE_REELIN_END", 3000, function()
            if this.currentState == this.state.reelin then _changeState(this.state.idle) end
        end)
    end

    this.currentState = state
    this.CallbackManager:FireCallbacks(this.name .. "_STATE_CHANGE", this.currentState)
end


local function _lootRelease()
    local this = FishingStateMachine

    local action, _, _, _, additionalInfo = GetGameCameraInteractableActionInfo()
    local angleDiv = ((math.deg(GetPlayerCameraHeading())-180) % 360) - this.angle

    if action and additionalInfo == ADDITIONAL_INTERACT_INFO_FISHING_NODE then
        _changeState(this.state.looking)
    elseif action then
        _changeState(this.state.lookaway)
    elseif -30 < angleDiv and angleDiv < 30 then
        _changeState(this.state.depleted)
    else
        _changeState(this.state.idle)
    end
end


_lootSceneCB = function(oldState, newState)
    local this = FishingStateMachine

    if newState == SCENE_HIDDEN then -- IDLE
        _lootRelease()
        LOOT_SCENE:UnregisterCallback("StateChange", _lootSceneCB)
    elseif this.currentState ~= this.state.reelin and this.currentState ~= this.state.loot then -- fishing interrupted
        LOOT_SCENE:UnregisterCallback("StateChange", _lootSceneCB)
    elseif newState == SCENE_SHOWN then -- LOOT, INVFULL
        if (GetBagUseableSize(BAG_BACKPACK) - GetNumBagUsedSlots(BAG_BACKPACK)) <= 0 then
            _changeState(this.state.invfull)
        else
            _changeState(this.state.loot)
        end
    end
end


local tmpInteractableName = ""
local tmpNotMoving = true
local function _onAction()
    local this = FishingStateMachine

    local action, interactableName, _, _, additionalInfo = GetGameCameraInteractableActionInfo()

    if  action and (this.currentState == this.state.fishing
        or this.currentState == this.state.reeling)
        and INTERACTION_FISH ~= GetInteractionType() then -- fishing interrupted
        _changeState(this.state.idle)

    elseif action and IsPlayerTryingToMove() and this.currentState < this.state.fishing then
        _changeState(this.state.lookaway)
        tmpInteractableName = ""
        tmpNotMoving = false
        EVENT_MANAGER:RegisterForUpdate(this.name .. "MOVING", 400, function()
            if not IsPlayerTryingToMove() then
                EVENT_MANAGER:UnregisterForUpdate(this.name .. "MOVING")
                tmpNotMoving = true
            end
        end)

    elseif action and additionalInfo == ADDITIONAL_INTERACT_INFO_FISHING_NODE then -- NOBAIT, LOOKING
        if not GetFishingLure() then
            _changeState(this.state.nobait)
        elseif this.currentState < this.state.fishing and tmpNotMoving then
            _changeState(this.state.looking)
            tmpInteractableName = interactableName
        end

    elseif action and tmpInteractableName == interactableName and INTERACTION_FISH == GetInteractionType() then -- FISHING, REELIN+
        if this.currentState > this.state.fishing then return end
        _changeState(this.state.fishing)

    elseif action then -- LOOKAWAY
        _changeState(this.state.lookaway)
        tmpInteractableName = ""

    elseif this.currentState == this.state.reelin and GetSetting_Bool(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT) then --DEPLETED
        _lootRelease()

    elseif this.currentState ~= this.state.depleted then -- IDLE
        _changeState(this.state.idle)
        tmpInteractableName = ""
    end
end


local function _onAddOnLoaded(event, addonName)
    local this = FishingStateMachine

    ZO_PreHookHandler(RETICLE.interact, "OnEffectivelyShown", _onAction)
    ZO_PreHookHandler(RETICLE.interact, "OnHide", _onAction)

    EVENT_MANAGER:RegisterForEvent(this.name, EVENT_PLAYER_SWIMMING, function(eventCode) this.swimming = true end)
    EVENT_MANAGER:RegisterForEvent(this.name, EVENT_PLAYER_NOT_SWIMMING, function(eventCode) this.swimming = false end)
    EVENT_MANAGER:RegisterForEvent(this.name, EVENT_PLAYER_DEAD, function(eventCode) _changeState(this.state.dead, true) end)
    EVENT_MANAGER:RegisterForEvent(this.name, EVENT_PLAYER_ALIVE, function(eventCode) _changeState(this.state.idle) end)
    EVENT_MANAGER:RegisterForEvent(this.name, EVENT_PLAYER_COMBAT_STATE, function(eventCode, inCombat)
        if inCombat then
            _changeState(this.state.fight)
        elseif this.currentState == this.state.fight then
            _changeState(this.state.idle, true)
        end
    end)

    _changeState(this.state.idle)
end


FishingStateMachine.CallbackManager = ZO_CallbackObject:New()
EVENT_MANAGER:RegisterForEvent(FishingStateMachine.name, EVENT_ADD_ON_LOADED, _onAddOnLoaded)


--[[ global functions ]] ----------------------------------------------------------------


function FishingStateMachine:getState()
    return self.currentState
end


function FishingStateMachine:registerOnStateChange(callback)
    self.CallbackManager:RegisterCallback(self.name .. "_STATE_CHANGE", callback)
end


function FishingStateMachine:unregisterOnStateChange(callback)
    self.CallbackManager:UnregisterCallback(self.name .. "_STATE_CHANGE", callback)
end


