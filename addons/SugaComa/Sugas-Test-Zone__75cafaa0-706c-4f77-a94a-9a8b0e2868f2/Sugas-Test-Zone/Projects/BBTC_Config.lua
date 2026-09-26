SugasTestZoneBBTCadence = SugasTestZoneBBTCadence or {}
local Project = SugasTestZoneBBTCadence

Project.Config = {
    addonName = "Sugas-Test-Zone",
    displayName = "BackBarTimer + CadenceCoach",
    version = "0.1.0-test9",
    savedVariablesName = "SugasTestZoneBBTCadence_SV",
    savedVariablesVersion = 1,

    firstSlot = 3,
    lastSlot = 7,
    minimumDurationMs = 4000,
    hudDisplayWindowMs = 10000,
    hudWarningMs = 2000,
    updateIntervalMs = 100,
    cadencePeriodMs = 2000,
    cadencePulseMs = 350,
    pendingEffectWindowMs = 1200,
    clusterWindowMs = 3000,
}

Project.Defaults = {
    mode = "pvp",
    leadSeconds = 2,
    debug = false,
    suppressZeroDuration = true,
    blockCadence = false,
    lightCadence = false,
    hudFullCountdown = false,
    hudCountdownSeconds = 10,
    hudScale = 1.0,
    layoutVersion = 0,
    leftInset = 110,
    leftY = 0,
    rightInset = 110,
    rightY = 0,
    frontSlots = {
        [3] = true, [4] = true, [5] = true, [6] = true, [7] = true,
    },
    backSlots = {
        [3] = true, [4] = true, [5] = true, [6] = true, [7] = true,
    },
}

function Project:Log(message, force)
    if not force and not (self.sv and self.sv.debug) then return end
    if type(CHAT_ROUTER) == "table" and type(CHAT_ROUTER.AddSystemMessage) == "function" then
        CHAT_ROUTER:AddSystemMessage(string.format("[STZ BBT %s] %s", self.Config.version, tostring(message)))
    elseif type(d) == "function" then
        d(string.format("[STZ BBT %s] %s", self.Config.version, tostring(message)))
    end
end
