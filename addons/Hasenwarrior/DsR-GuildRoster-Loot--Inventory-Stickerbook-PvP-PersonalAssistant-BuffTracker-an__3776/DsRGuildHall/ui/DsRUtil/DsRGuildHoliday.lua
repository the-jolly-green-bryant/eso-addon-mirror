-- Create namespace
DsRGuildHoliday = {}

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Footer
function DsRGuildHoliday.LoadIconHoliFooter()
    local IconFooter = DsRGuildHolidayIconFooter
    local ld = os.date("*t")
    local guildId   = GUILD_ROSTER_MANAGER:GetGuildId()
    local guildName = GetGuildName(guildId)
    
-- New year
    if (ld.month == 1 and ld.day >= 1) and (ld.month == 1 and ld.day <= 3) then
        IconFooter:SetTexture("DsRGuildHall/misc/DsR_newyearfooter.dds")
-- Valentine's Day
    elseif ld.month == 2 and ld.day == 14 then
        IconFooter:SetTexture("DsRGuildHall/misc/DsR_valentinheader.dds")
-- Ester
     elseif (ld.month == 3 and ld.day >= 25) and (ld.month == 3 and ld.day <= 29) then
        IconFooter:SetTexture("DsRGuildHall/misc/DsR_esterfooter.dds")
-- Halloween
    elseif (ld.month == 10 and ld.day >= 30) and (ld.month == 11 and ld.day <=3) then
        IconFooter:SetTexture("DsRGuildHall/misc/DsR_halloweenfooter.dds")
-- Christmas
    elseif ld.month == 12 and ld.day >= 0 and ld.day <= 26 then
        IconFooter:SetTexture("DsRGuildHall/misc/DsR_xmasfooter.dds")
    else
        IconFooter:SetTexture("")
        IconFooter:SetHidden(true)
    end
    
    if not PerfectPixel then
        IconFooter:SetAnchor(TOP, ZO_GuildHome, BOTTOM, 120 , 200)
    elseif PerfectPixel then
        IconFooter:SetAnchor(TOP, ZO_GuildHome, BOTTOM, 120 , -40)
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Header
function DsRGuildHoliday.LoadIconHoliHeader()
    local IconHeader = DsRGuildHolidayIconHeader
    local ld = os.date("*t")
   
-- New year
    if (ld.month == 1 and ld.day >= 1) and (ld.month == 1 and ld.day <= 3) then
        IconHeader:SetTexture("DsRGuildHall/misc/DsR_newyearheader.dds")
-- Valentine's Day
    elseif ld.month == 2 and ld.day == 14 then
        IconHeader:SetTexture("DsRGuildHall/misc/DsR_valentinheader.dds")
-- Ester
     elseif (ld.month == 3 and ld.day >= 25) and (ld.month == 3 and ld.day <= 29) then
        IconHeader:SetTexture("DsRGuildHall/misc/DsR_esterheader.dds")
-- Halloween
    elseif (ld.month == 10 and ld.day >= 30) and (ld.month == 11 and ld.day <=3) then
        IconHeader:SetTexture("DsRGuildHall/misc/DsR_halloweenheader.dds")
-- Christmas
    elseif ld.month == 12 and ld.day >= 0 and ld.day <= 26 then
        IconHeader:SetTexture("DsRGuildHall/misc/DsR_xmasheader.dds")
    else
        IconHeader:SetTexture("")
        IconHeader:SetHidden(true)
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
----- change guild
function DsRGuildHoliday.OnGuildIdChanged(guild_roster_manager)
    local guildId   = GUILD_ROSTER_MANAGER:GetGuildId()
    local guildName = GetGuildName(guildId)
    local IconFooter = DsRGuildHolidayIconFooter

    if not PerfectPixel then
        IconFooter:SetAnchor(TOP, ZO_GuildHome, BOTTOM, 120 , 200)
    elseif PerfectPixel then
        IconFooter:SetAnchor(TOP, ZO_GuildHome, BOTTOM, 120 , -40)
    end
end