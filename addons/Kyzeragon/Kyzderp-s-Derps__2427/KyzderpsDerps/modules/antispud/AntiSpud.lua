local KD = KyzderpsDerps

KD.AntiSpud = {}
local Spud = KD.AntiSpud


---------------------------------------------------------------------
--[[
summon pets after dying
resummon pets on zhajhassa
addons not enabled
wrong cp
missing gear
incomplete sets
]]

local currentState = "NONE"

function Spud.DisplayWarning(message)
    -- TODO: other methods of warnings like popup dialogs
    local chatWarning = "|cFF0000W" ..
                        "|cFF7F00A" ..
                        "|cFFFF00R" ..
                        "|c00FF00N" ..
                        "|c0000FFI" ..
                        "|c2E2B5FN" ..
                        "|c8B00FFG" ..
                        "|r: " .. message
    KD:dbg(chatWarning)
end

---------------------------------------------------------------------
-- Entry
function Spud.Initialize()
    KD:dbg("    Initializing AntiSpud module...")

    Spud.InitializeSpaulder()
    Spud.InitializeMundus()
    Spud.InitializeSkills()
    Spud.InitializeFood()
    Spud.InitializeTorte()
    Spud.InitializeLog()
    Spud.InitializeGearSetup()

    if (KD.savedOptions.antispud.equipped.enable) then
        Spud.InitializeEquipped()
    end

    -- Needs to go last in case others register listeners
    Spud.InitializeState()
end
