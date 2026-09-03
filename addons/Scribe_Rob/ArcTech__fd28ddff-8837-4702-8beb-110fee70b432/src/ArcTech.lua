-- ArcTech.lua
ArcTech = {}
ArcTech.addon_name = "ArcTech"
ArcTech.initialised = false

local function OnAddOnLoaded(event, addonName)
    if addonName ~= ArcTech.addon_name then return end
    EVENT_MANAGER:UnregisterForEvent(ArcTech.addon_name, EVENT_ADD_ON_LOADED)

    Init()
end

function Init()
    SumBankDepositsThisMonth(ArcTech.guild_id, "@Scribe Rob")

    if ArcTech.initialised then return end
    ArcTech.initialised = true

    InitSavedVars()

    if LibAddonMenu2 then
        InitLAM()
    else
        d("|c3cffbaArcTech loaded (LAM missing)|r")
    end

    if not LibQRCode then
        d("|c3cffbaArcTech loaded (LQR missing)|r")
    end

    d("|c3cffbaArcTech loaded|r")
end

function ArcTechSlash(arg)
    arg = string.lower(tostring(arg or ""))

    if arg == 'house' then
        SLASH_COMMANDS["/guildhouse"] = function()
            HandleGuildhouseSlash(arg)
        end
    end

    if arg == 'discord' then
        d('in the future this will open discord QR Code')
    end
end

SLASH_COMMANDS["/arctech"] = ArcTechSlash
SLASH_COMMANDS["/gh"] = function()
    HandleGuildhouseSlash("main")
end
SLASH_COMMANDS["/rapport"] = function()
        d("Companion Rapport: " .. GetActiveCompanionRapport())
end

EVENT_MANAGER:RegisterForEvent(ArcTech.addon_name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)