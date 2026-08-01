PillagerCooldown = {
    name = 'PillagerCooldown',
    author = '@necco889',
    version  = "1.0.0",
    variableVersion = 1,
    refreshUICrash = false,
    
    pillagerAbilityId = 172055,
    ultgainAbilityId = 172055,
    -- pillagerCooldownAbilityId = 172056,      --this is not reported by the game only visible in the log
    pillagerDuration = 45,
    
    pillagerBuffEndTime = 0,
    pillagerCooldownEndTime = 0,
    ultiGainSelf = 0,
    ultiGainGlobal = 0,
    affectedPlayers = {},
    affectedPlayersNum = 0,
    groupSize = -1,
    lastGroupSize = -1,
    currentUiState = -1,
    
    -- ui_frame = nil,
    ui_labelDuration = nil,
    ui_labelPlayers = nil,
    ui_labelUltiGain = nil,
    ui_unlocked = false,

    -- Settings
    defaults = {
        left = 400,
        top = 300,
        enabled = true,
        showAffectedPlayers = true,
        showUltiGain = true,
        ultiGainMode = 0,
    },


    --debug
    -- pillagerAbilityId = 61711,  --major mending
    -- ultgainAbilityId = 45005,  --Mountain's Blessing (dk earthen heart ability /6s)
    -- dgs = 0,

}

local self=PillagerCooldown

local function debugPrint(message, ...)
    df("[PillagerCd]: %s", message:format(...))
end

function PillagerCooldown.OnMoveStop( )
    self.SV.left = PillagerCooldownFrame:GetLeft();
    self.SV.top = PillagerCooldownFrame:GetTop();
end

local function updateVisibility()
    self.fragment:Refresh()
end

local function setUiState(s)
    if self.currentUiState ~= s then
        if s == 0 then
            --white
            self.ui_labelDuration:SetColor(1,1,1,1)
            self.ui_labelPlayers:SetColor(1,1,1,1)
            self.ui_labelUltiGain:SetColor(1,1,1,1)
            self.ui_labelDuration:SetText("  0.0")
            self.ui_labelPlayers:SetText("   0")
            self.ui_labelUltiGain:SetText("   0")
        elseif s == 1 then
            --green
            self.ui_labelDuration:SetColor(0,1,0,1)
            self.ui_labelPlayers:SetColor(0,1,0,1)
            self.ui_labelUltiGain:SetColor(0,1,0,1)
        elseif s == 2 then
            --red
            self.ui_labelDuration:SetColor(1,0.2,0.2,1)
            self.ui_labelPlayers:SetColor(1,0.2,0.2,1)
            self.ui_labelUltiGain:SetColor(1,0.2,0.2,1)
        end
        self.currentUiState = s
    end
end

local function updateUi(duration, affected, gained)
    self.ui_labelDuration:SetText(string.format("  %2.1f", duration))
    if self.SV.showAffectedPlayers then
        self.ui_labelPlayers:SetText(string.format("%4s", self.affectedPlayersNum))
    end
    if self.SV.showUltiGain then
        self.ui_labelUltiGain:SetText(string.format("%4s", self.SV.ultiGainMode == 0 and self.ultiGainSelf or self.ultiGainGlobal))
    end
end

function PillagerCooldown.refreshUI()
    --crash safeguard
    if self.refreshUICrash then
        EVENT_MANAGER:UnregisterForUpdate(PillagerCooldown.name.."Cycle")
        return
    end
    self.refreshUICrash = true
    
    self.groupSize = GetGroupSize()
    -- self.groupSize = GetGroupSize() + self.dgs
    if self.groupSize ~= self.lastGroupSize then
        self.lastGroupSize = self.groupSize
        updateVisibility()
    end

    if self.pillagerBuffEndTime > 0 then
        setUiState(1)
        local duration = self.pillagerBuffEndTime - GetFrameTimeSeconds()
        if duration > 0 then
            updateUi(duration)
        else
            self.pillagerBuffEndTime = 0
        end
    elseif self.pillagerCooldownEndTime > 0 then
        setUiState(2)
        local duration = self.pillagerCooldownEndTime - GetFrameTimeSeconds()
        if duration > 0 then
            updateUi(duration)
        else
            self.pillagerCooldownEndTime = 0
            self.affectedPlayers = {}
            self.affectedPlayersNum = 0
            self.ultiGainSelf = 0
            self.ultiGainGlobal = 0
        end
    else
        setUiState(0)
    end

    self.refreshUICrash = false
end

local function abilityEvtListenerPillager(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if changeType==EFFECT_RESULT_GAINED or changeType==EFFECT_RESULT_UPDATED  then
        --reports multiple times
        self.pillagerBuffEndTime = endTime
        self.pillagerCooldownEndTime = beginTime + self.pillagerDuration
        if self.affectedPlayers[unitName] == nil then
            self.affectedPlayersNum = self.affectedPlayersNum + 1
            self.affectedPlayers[unitName] = true
        end
    end
end

local function onUltiGain(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, _, _)
    
    if result == ACTION_RESULT_POWER_ENERGIZE then
        if targetType == COMBAT_UNIT_TYPE_GROUP then
            self.ultiGainGlobal = self.ultiGainGlobal + hitValue
        elseif targetType == COMBAT_UNIT_TYPE_PLAYER then
            self.ultiGainGlobal = self.ultiGainGlobal + hitValue
            self.ultiGainSelf = self.ultiGainSelf + hitValue
        end
    end
    
    
end

function PillagerCooldown.Initialize()
    EVENT_MANAGER:RegisterForEvent(PillagerCooldown.name .. "On", EVENT_EFFECT_CHANGED, abilityEvtListenerPillager)
    EVENT_MANAGER:AddFilterForEvent(PillagerCooldown.name .. "On", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, self.pillagerAbilityId, REGISTER_FILTER_IS_ERROR, false)
    EVENT_MANAGER:UnregisterForEvent(PillagerCooldown.name .. "UltiGain", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:RegisterForEvent(PillagerCooldown.name .. "UltiGain", EVENT_COMBAT_EVENT, onUltiGain)
    EVENT_MANAGER:AddFilterForEvent(PillagerCooldown.name .. "UltiGain", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, self.ultgainAbilityId)
    EVENT_MANAGER:RegisterForUpdate(PillagerCooldown.name.."Cycle", 100, PillagerCooldown.refreshUI)
end

function PillagerCooldown.Cleanup()
    EVENT_MANAGER:UnregisterForEvent(PillagerCooldown.name .. "On", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(PillagerCooldown.name .. "UltiGain", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForUpdate(PillagerCooldown.name.."Cycle")
end

local function uiShowCondition()
    return PillagerCooldown.SV.enabled and (self.ui_unlocked or self.groupSize > 1)
end


local function OnPlayerActivated(eventCode)
    EVENT_MANAGER:UnregisterForEvent(PillagerCooldown.name, eventCode)
    -- PillagerCooldown.Initialize()
    PillagerCooldown.Enable(PillagerCooldown.SV.enabled)

    SCENE_MANAGER:GetScene("hud"):AddFragment(self.fragment);
    SCENE_MANAGER:GetScene("hudui"):AddFragment(self.fragment);
    self.fragment:SetConditional(uiShowCondition)
    self.ui_labelDuration = PillagerCooldownFrame:GetNamedChild("_Duration")
    self.ui_labelPlayers = PillagerCooldownFrame:GetNamedChild("_NumOfPlayers")
    self.ui_labelPlayers:SetHidden(not self.SV.showAffectedPlayers)
    self.ui_labelUltiGain = PillagerCooldownFrame:GetNamedChild("_UltiGain")
    self.ui_labelUltiGain:SetHidden(not self.SV.showUltiGain)
    setUiState(0)
end

function PillagerCooldown.OnAddOnLoaded(event, addOnName)
    if addOnName ~= PillagerCooldown.name then return end
    EVENT_MANAGER:UnregisterForEvent(PillagerCooldown.name, EVENT_ADD_ON_LOADED);

    PillagerCooldown.SV = ZO_SavedVars:New("PillagerCooldownSavedVariables", PillagerCooldown.variableVersion, nil, PillagerCooldown.defaults)
    PillagerCooldownFrame:ClearAnchors();
    PillagerCooldownFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PillagerCooldown.SV.left, PillagerCooldown.SV.top);
    PillagerCooldown.AddonMenu()

    self.fragment = ZO_HUDFadeSceneFragment:New(PillagerCooldownFrame);

    EVENT_MANAGER:RegisterForEvent(PillagerCooldown.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

function PillagerCooldown.DefaultPosition()
  self.SV.left = nil
  self.SV.top = nil
end

function PillagerCooldown.UnlockUI(unlock)
  self.ui_unlocked = unlock
  PillagerCooldownFrame:SetMovable(unlock)
  PillagerCooldownFrame:SetMouseEnabled(unlock)
  updateVisibility()
end

function PillagerCooldown.ShowAffectedPlayers(show)
  self.SV.showAffectedPlayers = show
  self.ui_labelPlayers:SetHidden(not show)
end

function PillagerCooldown.ShowUltiGain(show)
  self.SV.showUltiGain = show
  self.ui_labelUltiGain:SetHidden(not show)
end

function PillagerCooldown.Enable(val)
    PillagerCooldown.SV.enabled = val
    if val then
        PillagerCooldown.Initialize()
    else
        PillagerCooldown.Cleanup()
    end
end

function PillagerCooldown.AddonMenu()
    local menuOptions = {
        type                = "panel",
        name                = "PillagerCooldown",
        displayName         = "Pillager's Profit Cooldown Tracker",
        author              = PillagerCooldown.author,
        version             = PillagerCooldown.version,
        registerForRefresh  = true,
        registerForDefaults = true,
    }

    local dataTable = {
        {
            type = "description",
            text = "Hodor style Pillager's Profit tracker",
        },
        {
            type    = "button",
            name    = "Reset to default position",
            func = function() PillagerCooldown.DefaultPosition()  end,
            warning = "Requires /reloadui for the position to reset",
        },
        {
            type    = "checkbox",
            name    = "Enabled",
            default = PillagerCooldown.defaults.enabled,
            getFunc = function() return PillagerCooldown.SV.enabled end,
            setFunc = function(newValue) PillagerCooldown.Enable(newValue) end,
        },
        {
            type    = "checkbox",
            name    = "Unlock UI",
            default = false,
            getFunc = function() return PillagerCooldown.ui_unlocked end,
            setFunc = function(newValue) PillagerCooldown.UnlockUI(newValue) end,
        },
        {
            type    = "checkbox",
            name    = "Show number of affected players",
            default = PillagerCooldown.defaults.showAffectedPlayers,
            getFunc = function() return PillagerCooldown.SV.showAffectedPlayers end,
            setFunc = function(newValue) PillagerCooldown.ShowAffectedPlayers(newValue) end,
        },
        {
            type    = "checkbox",
            name    = "Show gained ultimate",
            default = PillagerCooldown.defaults.showUltiGain,
            getFunc = function() return PillagerCooldown.SV.showUltiGain end,
            setFunc = function(newValue) PillagerCooldown.ShowUltiGain(newValue) end,
        },
        {
            type = "dropdown",
            name = "Ultimate gain mode",
            default = PillagerCooldown.defaults.ultiGainMode == 0 and "self" or "global",
            choices = {"self", "global"},
            getFunc = function() return PillagerCooldown.SV.ultiGainMode == 0 and "self" or "global" end,
            setFunc = function(newValue) PillagerCooldown.SV.ultiGainMode = (newValue == "self" and 0 or 1) end
        },
    }

    LAM = LibAddonMenu2
    LAM:RegisterAddonPanel(PillagerCooldown.name .. "Options", menuOptions )
    LAM:RegisterOptionControls(PillagerCooldown.name .. "Options", dataTable )
end

EVENT_MANAGER:RegisterForEvent(PillagerCooldown.name, EVENT_ADD_ON_LOADED, PillagerCooldown.OnAddOnLoaded)