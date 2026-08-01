LeoDolmenRunnerRedux = {
    name = "LeoDolmenRunnerRedux",
    displayName = "LDR REDUX",
    version = "2.1.4",
    chatPrefix = "|c39B027LDR-Redux|r: ",
    username = "@Kiasmalyn",
    defaults = {
        hidden = true,
        runner = {
            autoTravel = true,
            autoDismiss = true,
            reapplyBuff = true
        },
        inviter = {
            maxSize = 12,
            autoKick = false,
            enableBlacklist = true,
            kickDelay = 60,
            blacklist = {},
            terms = {
                "dolmen +",
                "dolmen+",
                "lfg dolmen",
                "+ dolmen",
                "+dolmen",
                "++dolmen",
                "dolmen",
                "+domlen",
                "x",
                "+",
                "+d",
                "+dolmen pls",
                "+dol"
            }
        }
    }
}

local LDR = LeoDolmenRunnerRedux

local LastUpdateTimestamp = GetTimeStamp()

function LDR:Update()
    local currentTimestamp = GetTimeStamp()
    local tick = 1
    if GetDiffBetweenTimeStamps(currentTimestamp, LastUpdateTimestamp) >= 5 then
        tick = 5
        LastUpdateTimestamp = currentTimestamp
    end

    self.runner:Update(tick)
    self.inviter:Update(tick)
    self.ui:Update(tick)
end

function LDR:Initialize()
    local showButton, feedbackWindow = LibFeedback:initializeFeedbackWindow(LeoDolmenRunnerRedux,
            LDR.name, LeoDolmenRunnerReduxWindow, LDR.username,
            { TOPRIGHT, LeoDolmenRunnerReduxWindow, TOPRIGHT, -35, -2 },
            { 0, 1000, 10000 },
            GetString(LRR_WINDOW_WELCOME_MESSAGE))
    LDR.feedback = feedbackWindow
    LDR.feedback:SetDrawTier(DT_HIGH)

    LeoDolmenRunnerReduxWindowTitle:SetText(LeoDolmenRunnerRedux.displayName .. " v" .. LeoDolmenRunnerRedux.version)

    self.runner:Initialize()
    self.inviter:Initialize()
    self.ui:Initialize()

    LDR.settingsPanel = LeoDolmenRunnerRedux_Settings:New()
    LDR.settingsPanel:CreatePanel()

    EVENT_MANAGER:RegisterForUpdate(LeoDolmenRunnerRedux.name, 1000, function()
        LDR:Update()
    end)
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= LDR.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(LDR.name, EVENT_ADD_ON_LOADED)
    LDR.settings = LibSavedVars:NewAccountWide(LDR.name .. "_Data", "Account", LDR.defaults)

    if not LeoDolmenRunnerRedux.settings.inviter.blacklist then
        LeoDolmenRunnerRedux.settings.inviter.blacklist = {}
    end
    if not LeoDolmenRunnerRedux.settings.inviter.enableBlacklist then
        LeoDolmenRunnerRedux.settings.inviter.enableBlacklist = true
    end
    if not LeoDolmenRunnerRedux.settings.inviter.terms then
        LeoDolmenRunnerRedux.settings.inviter.terms = LeoDolmenRunnerRedux.defaults.inviter.terms
    end

    LDR:Initialize()

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", OnSettingsControlsCreated)

    EVENT_MANAGER:RegisterForEvent(LDR.name, EVENT_START_FAST_TRAVEL_INTERACTION, function(eventId, ...)
        LDR.runner:OnFastTravelInteraction(...)
    end)
    EVENT_MANAGER:RegisterForEvent(LDR.name, EVENT_EXPERIENCE_GAIN, function(eventId, ...)
        LDR.runner:OnExperienceGain(...)
    end)
    EVENT_MANAGER:RegisterForEvent(LDR.name, EVENT_PLAYER_COMBAT_STATE, function(eventId, ...)
        LDR.runner:OnCombatState(...)
    end)

    LDR.utils:Log(GetString(LRR_WINDOW_INIT))
end

EVENT_MANAGER:RegisterForEvent(LDR.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

ZO_CreateStringId('SI_BINDING_NAME_LEODOLMENRUNNERREDUX_TOGGLE_WINDOW', GetString(LRR_SETTINGS_LABEL_TOGGLE_WINDOW))
ZO_CreateStringId('SI_BINDING_NAME_LEODOLMENRUNNERREDUX_RUNNER_TOGGLE', GetString(LRR_SETTINGS_LABEL_TOGGLE_RUNNER))
ZO_CreateStringId('SI_BINDING_NAME_LEODOLMENRUNNERREDUX_INVITER_TOGGLE', GetString(LRR_SETTINGS_LABEL_TOGGLE_INVITER))
