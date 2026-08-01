TrialRecorder = TrialRecorder or {}
local TR = TrialRecorder

TR.NAME = "TrialRecorder"
TR.DISPLAY_NAME = "Trial Recorder"
TR.VERSION = "1.0.007"

local function PrintHelp()
    d("|cD9B66FTrial Recorder|r - Every clear counts.")
    d("Open Settings > Add-ons > Trial Recorder to view your records.")
    d("/trialrecorderdebug - Toggle diagnostic capture")
    d("/trialrecordertest TRIAL VET|HM SCORE TIME_SECONDS - Add a local test record")
end

function TR:OpenTrial(trialKey)
    self.UI:ShowTrial(trialKey)
end

function TR:InitializeCommands()
    SLASH_COMMANDS["/trialrecorderhelp"] = PrintHelp

    SLASH_COMMANDS["/trialrecorderdebug"] = function()
        self.sv.settings.debugEnabled = not self.sv.settings.debugEnabled
        d(string.format("[Trial Recorder] Diagnostic capture %s.", self.sv.settings.debugEnabled and "enabled" or "disabled"))
    end

    SLASH_COMMANDS["/trialrecordertest"] = function(args)
        local key, mode, score, seconds = zo_strsplit(" ", args or "")
        key = zo_strupper(key or "")
        local trial = self.TrialByKey[key]

        if not trial then
            d("[Trial Recorder] Use a registry key such as ROCKGROVE.")
            return
        end

        local run = {
            trialKey = trial.key,
            trialName = trial.name,
            completionType = zo_strupper(mode or "") == "HM" and "HARD_MODE" or "VETERAN",
            completedAt = GetTimeStamp(),
            durationMs = (tonumber(seconds) or 1800) * 1000,
            score = tonumber(score) or 100000,
            characterId = GetCurrentCharacterId(),
            characterName = zo_strformat(SI_UNIT_NAME, GetUnitName("player")),
            addonVersion = self.VERSION,
            classificationSource = "TEST_COMMAND",
        }

        local saved = self:AddRun(run)
        d(saved and "[Trial Recorder] Test record added." or "[Trial Recorder] Test record was not added.")
    end
end

function TR:Initialize()
    self:InitializeStorage()
    self.UI:Initialize()
    self:InitializeTracker()
    self:InitializeCommands()

    if self.Menu and self.Menu.RegisterWhenAvailable then
        self.Menu:RegisterWhenAvailable()
    end

    d("|cD9B66FTrial Recorder|r v" .. self.VERSION .. " loaded.")
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= TR.NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(TR.NAME, EVENT_ADD_ON_LOADED)
    TR:Initialize()
end

EVENT_MANAGER:RegisterForEvent(TR.NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
