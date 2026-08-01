local u = HodorReflexes.users

CannaReflexes = {
    Name = "CannaReflexes",
    Version = "0.0.3",
    Debug = false,
    Guilds = {"Cannabers"}
}

u["@monster_wolf"] = {"Monster_Wolf", "|cFF0000M. Wolf|r", "HodorReflexes/users/icons/mc/tchewyt.dds"}
u["@zurrias"] = {"Zurrias", "|cFFC0CBZurrias|r", "HodorReflexes/users/icons/equinoxe/dov118.dds"}
u["@najiva"] = {"Najiva", "|cE1F5FEN|r|cB3E5FCa|r|c81D4F4j|r|c4FC3F7i|r|c29B6F6v|r|c03A9F4a|r", "HodorReflexes/users/icons/mc/sock.dds"}




-- MISC FUNCTIONS
local function tblContains(set, key)
    return set[key] ~= nil
end
local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function printIfDebug(fmt)
    if (CannaReflexes.Debug) then
        CHAT_SYSTEM:AddMessage(fmt)
    end
end

--- INIT 
function  CannaReflexes.Initialize()
    CannaReflexes.AddGuildsToHodor()
end

function CannaReflexes.AddGuildsToHodor()
    printIfDebug("AddGuildsToHodor")
    for guild = 1, GetNumGuilds() do
        local guildid = GetGuildId(guild)
        local guildName =  GetGuildName(guildid)
        printIfDebug(guildName)        
        if(has_value(CannaReflexes.Guilds, guildName) ) then
            CannaReflexes.AddGuildMembersToHodor(guildid)
        end
    end
end

function  CannaReflexes.AddGuildMembersToHodor(guildId)
    printIfDebug("printMemberNames" .. guildId)
    for member = 1, GetNumGuildMembers(guildId) do
        local memberName =  GetGuildMemberInfo(guildId, member)
        printIfDebug("member name:" .. memberName)
        if ( not tblContains(u, memberName)) then
            local visible_name = string.sub(memberName, 2)  -- Delete @
            printIfDebug("Adding member" .. memberName .. ":" .. visible_name .. "-->" .. "|c00FF00" .. visible_name  .. "|r" )
            u[memberName] = {visible_name, "|c00FF00" .. visible_name  .. "|r", "HodorReflexes/users/icons/luck/gale.dds"}
        end 
    end
end


-- Events
function CannaReflexes.OnAddOnLoaded  (event, addonName)
    if addonName == CannaReflexes.Name then
        CannaReflexes:Initialize()
    end
    SLASH_COMMANDS["/crelfex"] = CannaReflexes.AddGuildsToHodor
end 

EVENT_MANAGER:RegisterForEvent(CannaReflexes.Name, EVENT_ADD_ON_LOADED, CannaReflexes.OnAddOnLoaded)
