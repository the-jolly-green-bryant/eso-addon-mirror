--[[

Lens Flare Toggle
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Addon info
local AddonName = "LensFlareToggle"
-- Local variables
local savedVars = {}
local strTo01 = {
    ["true"]  = 1,
    ["on"]    = 1,
    ["1"]     = 1,
    ["false"] = 0,
    ["off"]   = 0,
    ["0"]     = 0,
}


-- Set/reset/toggle lens flare
local function ToggleLensFlare(value)
    local t = type(value)

    -- Handle number, boolean and string input, ignore others (ignore ==> toggle)
    if t == "number" then
        if value ~= 1 and value ~= 0 then
            value = nil
        end
    elseif t == "boolean" then
        value = value and 1 or 0
    elseif t == "string" then
        value = strTo01[value]
    else
        value = nil
    end
    if value == nil then
        -- Get toggled value
        value = GetCVar("LENS_FLARE")=="1" and 0 or 1
    end
    
    savedVars.lensFlare = value
    SetCVar("LENS_FLARE", value)
    
    local msg = "Lens flare "
    if value==1 then
        msg = msg.."on"
    else
        msg = msg.."off"
    end
    d(msg)
end
 
-- Initialisations
local function OnPlayerActivated(event)
    -- Set up SavedVariables table
    savedVars = ZO_SavedVars:NewAccountWide("LensFlareToggle_SavedVariables", 1, nil, {lensFlare=1})
    
    -- Set value from saved variables
    ToggleLensFlare(savedVars.lensFlare)

    -- Register slash command and link function
    SLASH_COMMANDS["/lensflare"] = ToggleLensFlare
    
    EVENT_MANAGER:UnregisterForEvent(AddonName, EVENT_PLAYER_ACTIVATED)
end
EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)