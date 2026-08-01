if not GildedUI then return end

local Addon = GildedUI

Addon.STAY_MOUNTED_ACTION_USE = "use"
Addon.STAY_MOUNTED_ACTION_OPEN = "open"
Addon.STAY_MOUNTED_ACTION_TALK = "talk"
Addon.STAY_MOUNTED_ACTION_FISH = "fish"

Addon.STAY_MOUNTED_SLOT_ACTION1 = "action1"
Addon.STAY_MOUNTED_SLOT_ACTION2 = "action2"
Addon.STAY_MOUNTED_SLOT_ACTION3 = "action3"
Addon.STAY_MOUNTED_SLOT_ACTION4 = "action4"
Addon.STAY_MOUNTED_SLOT_ACTION5 = "action5"
Addon.STAY_MOUNTED_SLOT_ULTIMATE = "ultimate"
Addon.STAY_MOUNTED_SLOT_QUICKSLOT = "quickslot"

Addon.STAY_MOUNTED_SPECIAL_BLOCK = "block"
Addon.STAY_MOUNTED_SPECIAL_ATTACK = "attack"
Addon.STAY_MOUNTED_SPECIAL_BASH = "bash"
Addon.STAY_MOUNTED_SPECIAL_CROUCH = "crouch"

Addon.STAY_MOUNTED_ALERT_COOLDOWN_MS = 1500
Addon.STAY_MOUNTED_BLOCK_MESSAGE = "Dismount to interact"

Addon:RegisterDefaults({
    stayMounted = false,
    stayMountedAllowedInteractions = {},
    stayMountedBlockActions = false,
    stayMountedAllowedActions = {},
    stayMountedBlockSpecialMoves = false,
    stayMountedAllowedSpecialMoves = {},
})

local VALID_INTERACTIONS = {
    [Addon.STAY_MOUNTED_ACTION_USE] = true,
    [Addon.STAY_MOUNTED_ACTION_OPEN] = true,
    [Addon.STAY_MOUNTED_ACTION_TALK] = true,
    [Addon.STAY_MOUNTED_ACTION_FISH] = true,
}

local VALID_ACTIONS = {
    [Addon.STAY_MOUNTED_SLOT_ACTION1] = true,
    [Addon.STAY_MOUNTED_SLOT_ACTION2] = true,
    [Addon.STAY_MOUNTED_SLOT_ACTION3] = true,
    [Addon.STAY_MOUNTED_SLOT_ACTION4] = true,
    [Addon.STAY_MOUNTED_SLOT_ACTION5] = true,
    [Addon.STAY_MOUNTED_SLOT_ULTIMATE] = true,
    [Addon.STAY_MOUNTED_SLOT_QUICKSLOT] = true,
}

local VALID_SPECIAL_MOVES = {
    [Addon.STAY_MOUNTED_SPECIAL_BLOCK] = true,
    [Addon.STAY_MOUNTED_SPECIAL_ATTACK] = true,
    [Addon.STAY_MOUNTED_SPECIAL_BASH] = true,
    [Addon.STAY_MOUNTED_SPECIAL_CROUCH] = true,
}

local ACTION_LAYERS = {
    { value = Addon.STAY_MOUNTED_SLOT_ACTION1, layer = "GildedUI_StayMounted_Action1" },
    { value = Addon.STAY_MOUNTED_SLOT_ACTION2, layer = "GildedUI_StayMounted_Action2" },
    { value = Addon.STAY_MOUNTED_SLOT_ACTION3, layer = "GildedUI_StayMounted_Action3" },
    { value = Addon.STAY_MOUNTED_SLOT_ACTION4, layer = "GildedUI_StayMounted_Action4" },
    { value = Addon.STAY_MOUNTED_SLOT_ACTION5, layer = "GildedUI_StayMounted_Action5" },
    { value = Addon.STAY_MOUNTED_SLOT_ULTIMATE, layer = "GildedUI_StayMounted_Ultimate" },
    { value = Addon.STAY_MOUNTED_SLOT_QUICKSLOT, layer = "GildedUI_StayMounted_QuickSlot" },
}

local SPECIAL_MOVE_LAYERS = {
    { value = Addon.STAY_MOUNTED_SPECIAL_ATTACK, layer = "GildedUI_StayMounted_Attack" },
    { value = Addon.STAY_MOUNTED_SPECIAL_BLOCK, layer = "GildedUI_StayMounted_Block" },
    { value = Addon.STAY_MOUNTED_SPECIAL_BASH, layer = "GildedUI_StayMounted_Bash" },
    { value = Addon.STAY_MOUNTED_SPECIAL_CROUCH, layer = "GildedUI_StayMounted_Crouch" },
}

local function SanitizeStringList(raw, valid)
    if type(raw) ~= "table" then
        return {}
    end
    local cleaned = {}
    for i = 1, #raw do
        local value = raw[i]
        if valid[value] then
            cleaned[#cleaned + 1] = value
        end
    end
    return cleaned
end

local function ListContains(list, value)
    if type(list) ~= "table" then
        return false
    end
    for i = 1, #list do
        if list[i] == value then
            return true
        end
    end
    return false
end

local function SetLayerActive(layerName, active)
    RemoveActionLayerByName(layerName)
    if active then
        PushActionLayerByName(layerName)
    end
end

function Addon:SanitizeStayMounted()
    self:SanitizeSavedBoolean("stayMounted")
    self:SanitizeSavedBoolean("stayMountedBlockActions")
    self:SanitizeSavedBoolean("stayMountedBlockSpecialMoves")

    local sv = self.state.sv
    sv.stayMountedAllowedInteractions = SanitizeStringList(sv.stayMountedAllowedInteractions, VALID_INTERACTIONS)
    sv.stayMountedAllowedActions = SanitizeStringList(sv.stayMountedAllowedActions, VALID_ACTIONS)
    sv.stayMountedAllowedSpecialMoves = SanitizeStringList(sv.stayMountedAllowedSpecialMoves, VALID_SPECIAL_MOVES)
end

function Addon:IsStayMountedAllowedInteraction(actionKey)
    return ListContains(self.state.sv and self.state.sv.stayMountedAllowedInteractions, actionKey)
end

function Addon:GetMountedInteractActionKey()
    if not GetGameCameraInteractableActionInfo then
        return nil
    end

    local action = GetGameCameraInteractableActionInfo()
    if action == GetString(SI_GAMECAMERAACTIONTYPE5) then
        return self.STAY_MOUNTED_ACTION_USE
    end
    if action == GetString(SI_GAMECAMERAACTIONTYPE13) then
        return self.STAY_MOUNTED_ACTION_OPEN
    end
    if action == GetString(SI_GAMECAMERAACTIONTYPE2) then
        return self.STAY_MOUNTED_ACTION_TALK
    end
    if action == GetString(SI_GAMECAMERAACTIONTYPE16) then
        return self.STAY_MOUNTED_ACTION_FISH
    end
    return nil
end

function Addon:IsAllowedMountedInteraction()
    local actionKey = self:GetMountedInteractActionKey()
    if not actionKey then
        return false
    end
    return self:IsStayMountedAllowedInteraction(actionKey)
end

function Addon:ShouldBlockMountedInteraction()
    local sv = self.state.sv
    return sv and sv.stayMounted and IsMounted() and not self:IsAllowedMountedInteraction()
end

function Addon:ShowStayMountedBlockedAlert()
    local now = GetFrameTimeMilliseconds()
    local last = self.state.stayMountedAlertAtMs or 0
    if now - last <= self.STAY_MOUNTED_ALERT_COOLDOWN_MS then
        return
    end
    self.state.stayMountedAlertAtMs = now
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, self.STAY_MOUNTED_BLOCK_MESSAGE)
end

function Addon:SetReticleStayMountedBlocked()
    if RETICLE.additionalInfo then
        RETICLE.additionalInfo:SetHidden(false)
        RETICLE.additionalInfo:SetText(self.STAY_MOUNTED_BLOCK_MESSAGE)
    end
    if RETICLE.interactKeybindButton then
        RETICLE.interactKeybindButton:SetEnabled(false)
    end
end

function Addon:SyncStayMountedActionLayers()
    local sv = self.state.sv
    -- Pushing BlockAction layers while settings/combo keybind state is active
    -- breaks gamepad popups (can't B-out on reopen). Only block while in world.
    local inUi = IsGameCameraUIModeActive and IsGameCameraUIModeActive()
    local mounted = IsMounted() and not inUi

    local blockActions = sv and sv.stayMountedBlockActions and mounted
    local allowedActions = sv and sv.stayMountedAllowedActions
    for i = 1, #ACTION_LAYERS do
        local entry = ACTION_LAYERS[i]
        SetLayerActive(entry.layer, blockActions and not ListContains(allowedActions, entry.value))
    end

    local blockSpecial = sv and sv.stayMountedBlockSpecialMoves and mounted
    local allowedSpecial = sv and sv.stayMountedAllowedSpecialMoves
    for i = 1, #SPECIAL_MOVE_LAYERS do
        local entry = SPECIAL_MOVE_LAYERS[i]
        SetLayerActive(entry.layer, blockSpecial and not ListContains(allowedSpecial, entry.value))
    end
end

function Addon:InitStayMountedInteractHooks()
    if self.state.stayMountedHooksInstalled then
        return
    end
    if not RETICLE or not RETICLE.GetInteractPromptVisible or not RETICLE.UpdateInteractText then
        return
    end

    self.state.stayMountedHooksInstalled = true

    local originalGetInteractPromptVisible = RETICLE.GetInteractPromptVisible
    RETICLE.GetInteractPromptVisible = function(reticle, ...)
        -- GAMEPAD_JUMP_OR_INTERACT calls this on every jump; only block when a prompt is up.
        local visible = originalGetInteractPromptVisible(reticle, ...)
        if visible and Addon:ShouldBlockMountedInteraction() then
            Addon:ShowStayMountedBlockedAlert()
            return false
        end
        return visible
    end

    local originalUpdateInteractText = RETICLE.UpdateInteractText
    RETICLE.UpdateInteractText = function(reticle, ...)
        local result = originalUpdateInteractText(reticle, ...)
        local interactShowing = RETICLE.interact and not RETICLE.interact:IsHidden()
        if interactShowing and Addon:ShouldBlockMountedInteraction() then
            Addon:SetReticleStayMountedBlocked()
        end
        return result
    end
end

function Addon:InitStayMounted()
    self:InitStayMountedInteractHooks()

    if not self.state.stayMountedLayersInstalled then
        self.state.stayMountedLayersInstalled = true
        local namespace = self.name .. "StayMountedLayers"
        EVENT_MANAGER:RegisterForEvent(namespace, EVENT_MOUNTED_STATE_CHANGED, function()
            Addon:SyncStayMountedActionLayers()
        end)
        EVENT_MANAGER:RegisterForEvent(namespace .. "UiMode", EVENT_GAME_CAMERA_UI_MODE_CHANGED, function()
            Addon:SyncStayMountedActionLayers()
        end)
    end

    self:SyncStayMountedActionLayers()
end
