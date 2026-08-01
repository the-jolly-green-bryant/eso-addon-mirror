-- Create namespace
DsRGuildLeader = {}

-------------------------------------------------------------------------------------------------------------------------------------------------
----- Check first guild and frame
function DsRGuildLeader.Check()
    local guildId   = GUILD_ROSTER_MANAGER:GetGuildId()
    local guildName = GetGuildName(guildId)
    
    if guildName ~= "Die sieben Raben" then
        DsRGuildLeaders:SetHidden(true)
    else
        DsRGuildLeaders:SetHidden(false) 
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Change guild
function DsRGuildLeader.OnGuildIdChanged(guild_roster_manager)
    local guildId   = GUILD_ROSTER_MANAGER:GetGuildId()
    local guildName = GetGuildName(guildId)

    if not guild_roster_manager then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, zo_strformat(gettext.gettext("Can’t identify the guild hall yet")))
        return
    end
    if not guildId then
        return
    end
    
    DsRGuildLeader.Check()
end
