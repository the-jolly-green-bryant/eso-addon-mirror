-- ArcTech.lua

ArcTech = ArcTech or {}

ArcTech.addon_name = "ArcTech"
ArcTech.initialised = false

-----------------------------------------------------------
-- Addon initialization
-----------------------------------------------------------

local function Init()
    if ArcTech.initialised then
        return
    end

    ArcTech.initialised = true

    d("ArcTech Reloaded - currently under development")

    if ArcTech.Discord then
        ArcTech.Discord.Initialize()
    end
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ArcTech.addon_name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(
        ArcTech.addon_name,
        EVENT_ADD_ON_LOADED
    )

    Init()
end

-----------------------------------------------------------
-- ArcTech slash commands
-----------------------------------------------------------

function ArcTechSlash(arg)
    arg = string.lower(tostring(arg or ""))

    if arg == "house" then
        HandleGuildhouseSlash("main")

    else
        d("ArcTech commands:")
        d("/arctech house")
        d("/discord")
    end
end

SLASH_COMMANDS["/arctech"] = ArcTechSlash

SLASH_COMMANDS["/gh"] = function()
    HandleGuildhouseSlash("main")
end

SLASH_COMMANDS["/rapport"] = function()
    d(
        "Companion Rapport: " ..
        tostring(GetActiveCompanionRapport())
    )
end

-----------------------------------------------------------
-- Register addon
-----------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(
    ArcTech.addon_name,
    EVENT_ADD_ON_LOADED,
    OnAddOnLoaded
)