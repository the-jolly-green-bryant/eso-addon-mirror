--[[
Copyright (c) 2017-2019 Dolores Scott
All rights reserved.
See LICENSE file for terms.
]]

local WMGH = WheresMyGuildHall
local LAM = LibAddonMenu2
local SF = LibSFUtils
local GRM = GUILD_ROSTER_MANAGER

local color = SF.hex
local saved = WMGH.saved

-- saved.guildsettings      [ndx] {guildName=, GuildMasterOwner=, GHL_Compatible=, GuildHallScan=}
--
local function createGuildMenu(ndx)
    local menu = {
        type = "submenu",
        name = SF.GetIconized("", color.gold),
        controls = {
            {
                type = "checkbox",
                name = WMGH_ASSUME_GM,
                width = "full",
                getFunc = function()
                    local settings = WMGH.GetSettingsByIndex(ndx)
                    if settings.GuildMasterOwner ~= nil then
                        return settings.GuildMasterOwner
                    end
                    if WMGH.saved.guildsettings and WMGH.saved.guildsettings[ndx] then
						return WMGH.saved.guildsettings[ndx].GuildMasterOwner
					end
                    -- default value
					return true
				end,
                setFunc = function(value)
                    local settings = WMGH.GetSettingsByIndex(ndx)
                    settings.GuildMasterOwner = value
                    if GetGuildId(ndx) == GRM:GetGuildId() then
                     WMGH.DoDisplay(GetGuildId(ndx))
                    end
                end,
            },
            {
                type = "checkbox",
                name = WMGH_GHL_COMPATIBLE,
                tooltip = WMGH_GHL_COMPATIBLE_TT,
                width = "full",
                getFunc = function()
					if WMGH.saved.guildsettings and WMGH.saved.guildsettings[ndx] then
						return WMGH.saved.guildsettings[ndx].GHL_Compatible
					end
                    return  false
                end,
                setFunc = function(value)
                    local settings = WMGH.GetSettingsByIndex(ndx)
                    settings.GHL_Compatible = value
                    if GetGuildId(ndx) == GRM:GetGuildId() then
                        WMGH.DoDisplay(GetGuildId(ndx))
                    end
                end,
            },
            {
                type = "checkbox",
                name = WMGH_SCAN_GUILDHALL,
                tooltip = WMGH_SCAN_GUILDHALL_TT,
                width = "full",
                getFunc = function()
                    if WMGH.saved.guildsettings and WMGH.saved.guildsettings[ndx] then
                        return WMGH.saved.guildsettings[ndx].GuildHallScan
                    end
                    return false
                end,
                setFunc = function(value)
                    local settings = WMGH.GetSettingsByIndex(ndx)
                    settings.GuildHallScan = value
                    if GetGuildId(ndx) == GRM:GetGuildId() then
                        WMGH.DoDisplay(GetGuildId(ndx))
                    end
                end,
            },
        }
    }
    return menu
end


local panelData = {
   type = "panel",
   name = "Where's My Guild Hall", --GetString(WMGH_NAME),
   displayName = SF.GetIconized(WMGH_NAME, color.gold),
   author = SF.GetIconized("Shadowfen", color.purple),
   version = SF.GetIconized(WMGH.version, color.gold),
   slashCommand = "/wmgh.settings",
   registerForRefresh = true,
}

local optionsTable = {
    {
        type = "header",
        name = SF.GetIconized(WMGH_GUILDS_SECTION_NM, color.bronze),
        width = "full", --or "half" (optional)
    },
    -- menu sections get added later in RegisterSettings
}   -- end optionsTable

-- guilds       -- [name] GuildEntry
function WMGH.RegisterSettings(numguilds, guilds)
    LAM:RegisterAddonPanel("WheresMyGuildHallOptions", panelData)
    if( numguilds == 0 ) then
        d("You do not belong to any guilds")
    else
        for ndx = 1, WMGH.numGuilds do
            local gmenu = createGuildMenu(ndx)
            local v = WMGH.GetGuildByIndex(ndx)
            if not v then
                break
            end
            gmenu.name = SF.GetIconized(v.name, color.superior)
            table.insert(optionsTable, gmenu)
        end
    end
    LAM:RegisterOptionControls("WheresMyGuildHallOptions", optionsTable)
end
