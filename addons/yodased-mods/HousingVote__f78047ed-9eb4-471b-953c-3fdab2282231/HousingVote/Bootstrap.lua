local HV = HousingVote

-- Referenced by bindings.xml: the category label the keybind is grouped
-- under in Controls > Keybindings, and the bind's own display name.
ZO_CreateStringId("SI_HOUSINGVOTE_TITLE", "Housing Vote")
ZO_CreateStringId("SI_BINDING_NAME_HOUSINGVOTE_OPEN", "Open Housing Vote Menu")

function HV.Print(msg)
    d("|c8080FF[HousingVote]|r " .. msg)
end

function HV.CountKeys(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= HV.name then return end
    EVENT_MANAGER:UnregisterForEvent(HV.name, EVENT_ADD_ON_LOADED)

    HV.InitSavedVariables()
    HV.InitMail()
    HV.InitGuildMotd()
    HV.InitGamepadWindow()
    HV.InitConsoleMenu()
    HV.InitCommands()

    HV.Print("loaded. Type /hv for commands.")
end

EVENT_MANAGER:RegisterForEvent(HV.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
