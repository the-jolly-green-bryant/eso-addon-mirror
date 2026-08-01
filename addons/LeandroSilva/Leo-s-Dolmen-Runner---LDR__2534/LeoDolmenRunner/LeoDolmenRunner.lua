LeoDolmenRunner = {
    name = "LeoDolmenRunner",
    displayName = "Leo's Dolmen Runner",
    version = "1.3.1",
    chatPrefix = "|c39B027LeoDolmenRunner|r: ",
    isDebug = false,
    defaults = {
        hidden = true,
        runner = {
            autoTravel = true,
            autoDismiss = true,
            reapplyBuff = true
        },
        inviter = {
            maxSize = 24,
            autoKick = false,
            enableBlacklist = true,
            kickDelay = 10,
            blacklist = {}
        }
    }
}

local LDR = LeoDolmenRunner

function LDR.log(message)
    d(LDR.chatPrefix .. message)
end

function LDR.debug(message)
    if not LDR.isDebug then return end
    LDR.log("[D] " .. message)
end

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
    local showButton, feedbackWindow = LibFeedback:initializeFeedbackWindow(LeoDolmenRunner,
    LDR.name,LeoDolmenRunnerWindow, "@LeandroSilva",
            {TOPRIGHT, LeoDolmenRunnerWindow, TOPRIGHT,-35,-2},
            {0,1000,10000,"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=Y9KM4PZU2UZ6A"},
            "If you find a bug, have a request, or simply wish to donate, send me a mail.")
    LDR.feedback = feedbackWindow
    LDR.feedback:SetDrawTier(DT_HIGH)

    LeoDolmenRunnerWindowTitle:SetText(LeoDolmenRunner.displayName .. " v" .. LeoDolmenRunner.version)

    SLASH_COMMANDS["/ldr"] = function(cmd)
        local options = {}
        local i = 1
        for v in string.gmatch(cmd,"[^%s]+") do
            if (v ~= nil and v ~= "") then
                options[i] = string.lower(v)
                i = i + 1
            end
        end

        if #options == 0 or options[1] == "help" then
            LDR.log("Available options: ")
            d("    /ldr toggle: Toggles the main window")
            d("    /ldr show: Shows the main window")
            d("    /ldr hide: Hides the main window")
            d("    /ldr start: Starts the runner")
            d("    /ldr stop: Stops the runner")
            d("    /ldr cw: Changes direction to clockwise")
            d("    /ldr ccw: Changes direction to counter clockwise")
            d("    /ldr <letter>: Starts auto invite listening to the letter <letter>")
            d("    /ldr ai stop: Stops auto invite")
            return
        end

        if options[1] == "toggle" then LeoDolmenRunnerWindow:ToggleHidden()
        elseif options[1] == "show" then LeoDolmenRunnerWindow:SetHidden(false)
        elseif options[1] == "hide" then LeoDolmenRunnerWindow:SetHidden(true)
        elseif options[1] == "start" then LDR.runner:Start()
        elseif options[1] == "stop" then LDR.runner:Stop()
        elseif options[1] == "cw" then LDR.runner:CW()
        elseif options[1] == "ccw" then LDR.runner:CCW()
        elseif options[1] == "bl" and #options == 1 then LDR.inviter:DisplayBlacklist()
        elseif options[1] == "bl" and #options == 2 and options[2] == "clear" then LDR.inviter:ClearBlacklist()
        elseif options[1] == "bl" and #options == 3 and options[2] == "add" then LDR.inviter:AddPlayerToBlacklist(options[3])
        elseif options[1] == "bl" and #options == 3 and options[2] == "rem" then LDR.inviter:RemovePlayerFromBlacklist(options[3])
        elseif options[1] == "debug" and #options == 2 then LDR.isDebug = options[2] == "on"
        elseif options[1] == "ai" and #options == 2 and options[2] == "stop" then LDR.inviter:Stop()
        elseif string.len(options[1]) == 1 then LDR.inviter:Start(options[1])
        else LDR.log("Listening message must be only 1 letter (eg: x).")
        end
    end

    if GetDisplayName() == "@LeandroSilva" then
        SLASH_COMMANDS["/rr"] = function(cmd)
            ReloadUI()
        end
    end

    self.runner:Initialize()
    self.inviter:Initialize()
    self.ui:Initialize()

    LDR.settingsPanel = LeoDolmenRunner_Settings:New()
    LDR.settingsPanel:CreatePanel()

    EVENT_MANAGER:RegisterForUpdate(LeoDolmenRunner.name, 1000, function() LDR:Update() end)
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= LDR.name then return end

    EVENT_MANAGER:UnregisterForEvent(LDR.name, EVENT_ADD_ON_LOADED)
    LDR.settings = LibSavedVars:NewAccountWide( LDR.name .. "_Data", "Account", LDR.defaults )

    if not LeoDolmenRunner.settings.inviter.blacklist then LeoDolmenRunner.settings.inviter.blacklist = {} end
    if not LeoDolmenRunner.settings.inviter.enableBlacklist then LeoDolmenRunner.settings.inviter.enableBlacklist = true end

    LDR:Initialize()

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", OnSettingsControlsCreated)
    EVENT_MANAGER:RegisterForEvent(LDR.name, EVENT_START_FAST_TRAVEL_INTERACTION, function(eventId, ...) LDR.runner:OnFastTravelInteraction(...) end)
    EVENT_MANAGER:RegisterForEvent(LDR.name, EVENT_EXPERIENCE_GAIN, function(eventId, ...) LDR.runner:OnExperienceGain(...) end)
    EVENT_MANAGER:RegisterForEvent(LDR.name, EVENT_PLAYER_COMBAT_STATE, function(eventId, ...) LDR.runner:OnCombatState(...) end)

    LDR.log("started.")
end

EVENT_MANAGER:RegisterForEvent(LDR.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

ZO_CreateStringId('SI_BINDING_NAME_LEODOLMENRUNNER_TOGGLE_WINDOW', "Show/Hide Main Window")
ZO_CreateStringId('SI_BINDING_NAME_LEODOLMENRUNNER_RUNNER_TOGGLE', "Start/Stop runner")
ZO_CreateStringId('SI_BINDING_NAME_LEODOLMENRUNNER_INVITER_TOGGLE', "Start/Stop auto inviter")
