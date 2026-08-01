local ADDON_NAME = "MudcrabCounter"
local MCC = {}
MCC.name = ADDON_NAME

-- Ranks: Lore-friendly hierarchy to meta-goofy
local RANKS = {
    { limit = 0,       title = "Coast-Comber",           color = "FFFFFF" },
    { limit = 100,     title = "Pincer-Pincher",         color = "A3FFB4" },
    { limit = 500,     title = "Shell-Shucker",          color = "3A92FF" },
    { limit = 1000,    title = "Mudcrab Menace",         color = "A335EE" },
    { limit = 2500,    title = "Dances with Crabs",      color = "E6CC80" },
    { limit = 5000,    title = "Tidewater Tyrant",       color = "FF8000" },
    { limit = 10000,   title = "Baron of the Brine",     color = "FF4500" },
    { limit = 20000,   title = "Count of the Coastline", color = "FF4500" },
    { limit = 30000,   title = "Duke of the Dunes",      color = "FF4500" },
    { limit = 40000,   title = "Aquatic Archduke",       color = "FF4500" },
    { limit = 50000,   title = "Saltwater Sovereign",    color = "FF4500" },
    { limit = 60000,   title = "High Claw of Tamriel",   color = "FF4500" },
    { limit = 70000,   title = "Potentate of the Pincher", color = "FF4500" },
    { limit = 80000,   title = "Exarch of the Estuary",    color = "FF4500" },
    { limit = 90000,   title = "The Eternal Scuttler",     color = "FF4500" },
    { limit = 100000,  title = "Mythical Mudcrab Master",  color = "EECA2A" },
}

local MUDCRAB_BOSSES = {
    ["titanclaw"] = true, ["mother jagged-claw"] = true, ["shellcracker"] = true,
    ["sharpclaw"] = true, ["spectral mudcrab"] = true, ["clatterclaw"] = true,
}

local defaults = {
    kills = 0,
    bossKills = 0,
    sinceDate = nil,
}

MCC.session = { kills = 0, bossKills = 0 }

local function Msg(text)
    d("|c88CCFF[MCC]|r " .. text)
end

local function GetCurrentRankInfo()
    local kills = MCC.saved.kills or 0
    local currentTier = RANKS[1]
    local nextTier = nil
    for i, rank in ipairs(RANKS) do
        if kills >= rank.limit then
            currentTier = rank
            nextTier = RANKS[i+1]
        else
            break
        end
    end
    return currentTier, nextTier
end

---------------------------------------------------------
-- DASHBOARD (Settings -> Addons)
---------------------------------------------------------
local function CreateSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "Mudcrab Counter",
        displayName = "|c88CCFFMudcrab|r Counter",
        author = "@TwinLamps (PC/NA)",
        version = "1.0",
        slashCommand = "/mccmenu",
        registerForRefresh = true,
    }
    
    local optionsTable = {
        { type = "header", name = "|cFFD700Your Mischief Status|r" },
        {
            type = "description",
            text = function()
                local cur, nxt = GetCurrentRankInfo()
                local status = string.format("Current Rank: |c%s%s|r", cur.color, cur.title)
                if nxt then
                    local diff = nxt.limit - MCC.saved.kills
                    status = status .. string.format("\n|cBBBBBBNext Rank:|r %s\n|cBBBBBBProgress:|r %d more crabs to meet!", nxt.title, diff)
                else
                    status = status .. "\n|cEECA2AYou have achieved Mudcrab Enlightenment.|r"
                end
                return status
            end,
        },
        { type = "header", name = "Session Records" },
        {
            type = "description",
            text = function()
                return string.format("Mudcrab Mischief This Session: %d\nBoss Bounties This Session: %d",
                MCC.session.kills, MCC.session.bossKills)
            end,
        },
        { type = "header", name = "Lifetime Records" },
        {
            type = "description",
            text = function() 
                return string.format("Tracking since: %s\nPesky Pinchers Pinched: %d\nCrabby Bosses Busted: %d", 
                MCC.saved.sinceDate, MCC.saved.kills, MCC.saved.bossKills) 
            end,
        },
        {
            type = "button",
            name = "Reset All Progress",
            func = function() 
                MCC.saved = {kills=0, bossKills=0, sinceDate=os.date("%Y-%m-%d")}
                ReloadUI() 
            end,
            isDangerous = true,
        },
    }
    LAM:RegisterAddonPanel("MudcrabCounterSettings", panelData)
    LAM:RegisterOptionControls("MudcrabCounterSettings", optionsTable)
end

---------------------------------------------------------
-- EVENTS & SLASH COMMANDS
---------------------------------------------------------

local function OnCombatEvent(_, result, _, _, _, _, _, _, targetName)
    if (result == ACTION_RESULT_DIED or result == ACTION_RESULT_DIED_XP) and targetName ~= "" then
        local cleanName = string.lower(zo_strformat("<<1>>", targetName))
        
        if MUDCRAB_BOSSES[cleanName] then
            MCC.saved.bossKills = (MCC.saved.bossKills or 0) + 1
            MCC.session.bossKills = MCC.session.bossKills + 1
            Msg("|cFF5555Boss Bounty Collected:|r " .. zo_strformat("<<C:1>>", cleanName))
        elseif string.find(cleanName, "mudcrab") or string.find(cleanName, "sandcrab") then
            MCC.saved.kills = (MCC.saved.kills or 0) + 1
            MCC.session.kills = MCC.session.kills + 1
        end
    end
end

SLASH_COMMANDS["/mcc"] = function(cmd)
    local arg = string.lower(cmd or "")
    if arg == "help" then
        Msg("Commands: |cFFFF00/mcc|r (All-time), |cFFFF00/mcc session|r (This play), |cFFFF00/mcc sr|r (Reset session), |cFFFF00/mccmenu|r (Dashboard)")
    elseif arg == "session" then
        Msg(string.format("Session: %d Mudcrabs; (%d Bosses).", MCC.session.kills, MCC.session.bossKills))
    elseif arg == "sr" then
        MCC.session = { kills = 0, bossKills = 0 }
        Msg("Session stats have been reset!")
    elseif arg == "reset" then
        Msg("To wipe all data, please use the |cFFFF00/mccmenu|r dashboard.")
    else
        local cur, _ = GetCurrentRankInfo()
        Msg(string.format("Total: %d Kills, %d Bosses (|c%s%s|r).", MCC.saved.kills, MCC.saved.bossKills, cur.color, cur.title))
    end
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    
    -- 1. Unregister load event immediately
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    -- 2. Initialize Variables
    MCC.saved = ZO_SavedVars:NewAccountWide("MudcrabCounterSaved", 1, GetWorldName(), defaults)
    if not MCC.saved.sinceDate then MCC.saved.sinceDate = os.date("%Y-%m-%d") end

    -- 3. Load Menu and Combat Tracker
    CreateSettingsMenu()
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_COMBAT_EVENT, OnCombatEvent)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)