-- -----------------------------------------------------------------------------
-- Seething Fury Counter
-- Author:  g4rr3t
-- Created: May 22, 2019
--
-- Track stacks of Seething Fury.
--
-- Main.lua
-- -----------------------------------------------------------------------------
SFC             = {}
SFC.name        = "SeethingFuryCounter"
SFC.version     = "1.0.0"
SFC.dbVersion   = 1
SFC.slash       = "/sfc"
SFC.prefix      = "[SFC] "

local EM = EVENT_MANAGER
local SC = SLASH_COMMANDS

-- -----------------------------------------------------------------------------
-- Level of debug output
-- 1: Low    - Basic debug info, show core functionality
-- 2: Medium - More information about skills and addon details
-- 3: High   - Everything
SFC.debugMode = 0
-- -----------------------------------------------------------------------------

function SFC:Trace(debugLevel, ...)
    if debugLevel <= SFC.debugMode then
        local message = zo_strformat(...)
        d(SFC.prefix .. message)
    end
end

-- -----------------------------------------------------------------------------
-- Startup
-- -----------------------------------------------------------------------------

function SFC.Initialize(event, addonName)
    if addonName ~= SFC.name then return end

    if GetUnitClassId("player") ~= 1 then
        SFC:Trace(1, "Non-dragonknight class detected, aborting addon initialization.")
        EM:UnregisterForEvent(SFC.name, EVENT_ADD_ON_LOADED)

        -- Hide XML control
        SFC_BuffDurationAnimation:SetHidden(true)

        return
    end

    SFC:Trace(1, "SFC Loaded")
    EM:UnregisterForEvent(SFC.name, EVENT_ADD_ON_LOADED)

    SFC.preferences = ZO_SavedVars:NewAccountWide("SeethingFuryCounterVariables", SFC.dbVersion, nil, SFC.Defaults.Get())

    -- Use saved debugMode value if the above value has not been changed
    if SFC.debugMode == 0 then
        SFC.debugMode = SFC.preferences.debugMode
        SFC:Trace(1, "Setting debug value to saved: <<1>>", SFC.preferences.debugMode)
    end

    SC[SFC.slash] = SFC.UI.SlashCommand

    SFC.Settings.Init()
    SFC.Tracking.RegisterEvents()
    SFC.UI.Setup()

    SFC:Trace(2, "Finished Initialize()")
end

-- -----------------------------------------------------------------------------
-- Event Hooks
-- -----------------------------------------------------------------------------

EM:RegisterForEvent(SFC.name, EVENT_ADD_ON_LOADED, SFC.Initialize)

