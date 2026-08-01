GuildToolsByFenInternals = {
    name = "GuildToolsByFen",
    title = "Guild Tools by Fen",
    author = "Fenweldryn",
    version = "0.9.1"
}

if(GuildToolsByFen == nil) then 
    GuildToolsByFen = {} 
    GuildToolsByFen.history = {} 
    GuildToolsByFen.settings = {} 
end    

if(GuildToolsByFenSettings == nil) then 
    GuildToolsByFenSettings = {}
end

GuildToolsByFenInternals.rosterOnMouseEnter = ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter
GuildToolsByFenInternals.rosterOnMouseExit = ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit

function GuildToolsByFenInternals.createUser(user, guildId)
    if (user == nil) then return end  
    if (guildId == nil) then return end 
    if (GuildToolsByFen.history[guildId][user] ~= nil) then return end  
    
    GuildToolsByFen.history[guildId][user] = {
        lastEvent = nil,
        timeJoined = nil,
        withdrawals = {
            last30Days = 0,
            lastWeek = 0,
            thisWeek = 0,
            today = 0
        },
        deposits = {
            last30Days = 0,
            lastWeek = 0,
            thisWeek = 0,
            today = 0
        }        
    }
end

function GuildToolsByFenInternals.createGuild(guildId)
    if (GuildToolsByFen.history[guildId] ~= nil) then return end
    
    GuildToolsByFen.history[guildId] = {}
end