local KD = KyzderpsDerps
local Spud = KD.AntiSpud

---------------------------------------------------------------------
local function CheckLog()
    if (Spud.IsCurrentStateEnabledInSetting(KD.savedOptions.antispud.log)
        and not IsEncounterLogEnabled()) then
        Spud.Display("You are not logging", Spud.LOG)
    else
        Spud.Display(nil, Spud.LOG)
    end
end
Spud.CheckLog = CheckLog

local function OnSpudStateChanged(oldState, newState)
    CheckLog()
end

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Spud.InitializeLog()
    KD:dbg("    Initializing AntiSpud Log...")

    Spud.RegisterStateListener("Log", OnSpudStateChanged)

    CheckLog()

    ZO_PreHook("SetEncounterLogEnabled", function() zo_callLater(CheckLog, 100) end)
end
