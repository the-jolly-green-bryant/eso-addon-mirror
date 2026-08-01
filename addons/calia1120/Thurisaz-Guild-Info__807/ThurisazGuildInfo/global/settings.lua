-- Copyright (c) 2014 User Froali from ESOUI.com
-- All Rights Reserved. If you want to use parts of my AddOns for your own work, please contact me first!

--CONSTANTS
TI.SETTINGS_ALL = 1
TI.SETTINGS_STATUS = 2
TI.SETTINGS_LEVEL = 3
TI.SETTINGS_MEMBER = 4

-------------------------------------------------------------------------
-- Menu
local MENU_SLASH_COMMAND_STRING = "/tgi" ;

function TI.createMenu()
	TI.migrateSavedvars();
	local options = {
		{
			type = "description",
			text =  TI.version..(" by |c4EFFF6Calia1120|r"):format(TI.version),
		},
		{
			type = "submenu",
			name = TI.locale.settings["TGI_SettingsGuildRosterHeader"],
			controls = {
				{
					type = "checkbox",
					name = TI.locale.settings["TGI_SettingsCharNames"],
					tooltip = TI.locale.settings.tooltip["TGI_SettingsCharNames"],
					getFunc = function() return TI.GetCharNameSettings() end,
					setFunc = function(val) TI.SetCharNameSettings(val) end,
					warning = "Reloads UI"
				},
			}
		},
		{
			type = "submenu",
			name = TI.locale.settings["TGI_SettingsAnnouncementsHeader"],
			controls = {
				--ShowAnnouncements
				{
					type = "checkbox",
					name = TI.locale.settings["TGI_SettingsAnnounce"],
					tooltip = TI.locale.settings.tooltip["TGI_SettingsAnnounce"],
					width = "full",
					getFunc = TI.GetGuildSettings,
					setFunc = TI.SetGuildSettings,
					default = TI.defaults.ShowAnnouncements,
				},
				-- Unlock Announcement Window
				{
					type = "checkbox",
					name = TI.locale.settings["TGI_SettingsAnnounceDisplayMoveable"],
					tooltip = TI.locale.settings.tooltip["TGI_SettingsAnnounceDisplayMoveable"],
					width = "half",
					getFunc = TI.GetDisplayMoveable,
					setFunc = TI.SetDisplayMoveable,
				},
				-- How to display Announcements
				{
					type = "dropdown",
					name = TI.locale.settings["TGI_SettingsAnnounceType"],
					tooltip = TI.locale.settings.tooltip["TGI_SettingsAnnounceType"],
					choices = {TI.SETTINGS_DISPLAY_TYPE_CHAT, TI.SETTINGS_DISPLAY_TYPE_LABEL, TI.SETTINGS_DISPLAY_TYPE_BOTH},
					width = "half",
					getFunc = TI.GetDisplayTypeSettings,
					setFunc = TI.SetDisplayTypeSettings,
					default = TI.defaults.DisplayType
				},
				-- Use Colored Display Messages?
				{
					type = "checkbox",
					name = TI.locale.settings["DisplayColorMode"],
					tooltip = TI.locale.settings.tooltip["DisplayColorMode"],
					width = "half",
					getFunc = TI.GetDisplayColorModeSettings,
					setFunc = TI.SetDisplayColorModeSettings,
					default = TI.defaults.AnnounceDisplayColorMode,
				},
				-- AnnounceDisplayAlignment
				{
					
					type = "dropdown",
					name = TI.locale.settings["TGI_SettingsAnnounceDisplayAlign"],
					tooltip = TI.locale.settings.tooltip["TGI_SettingsAnnounceDisplayAlign"],
					width = "half",
					choices = {TI.SETTINGS_DISPLAY_ALIGN_LEFT,TI.SETTINGS_DISPLAY_ALIGN_CENTER, TI.SETTINGS_DISPLAY_ALIGN_RIGHT},
					getFunc = TI.GetDisplayAlignSetting,
					setFunc = TI.SetDisplayAlignSetting,
					default = TI.defaults.AnnounceDisplayAlignment,
				},
				-- Show time on chat announcements
				{
					type = "checkbox",
					name = TI.locale.settings["TGI_SettingsShowTimestamp"],
					tooltip = TI.locale.settings.tooltip["TGI_SettingsShowTimestamp"],
					width = "half",
					getFunc = TI.GetShowTimestamp,
					setFunc = TI.SetShowTimestamp,
					default = TI.defaults.AnnounceShowTimestamp,
				},
				-- Set how long to show Announcement
				{
					type = "slider",
					name = TI.locale.settings["TGI_SettingsAnnounceDisplayTime"],
					tooltip = TI.locale.settings.tooltip["TGI_SettingsAnnounceDisplayTime"],
					width = "half",
					min = 1,
					max = 60,
					step = 0.5,
					getFunc = TI.GetDisplayTime,
					setFunc = TI.SetDisplayTime,
					default = TI.defaults.AnnounceDisplayTime,
				},	
				-- Announcement Font Settings
				{
					type = "dropdown",
					name = TI.locale.settings["TGI_SettingsAnnounceFont"],
					tooltip = TI.locale.settings.tooltip["TGI_SettingsAnnounceFont"],
					--choices = {"ZoFontAnnounce","ZoFontAnnounceLarge","ZoFontAnnounceMedium","ZoFontAnnounceSmall","ZoFontAnnounceMessage"}, --ZoFontAnnounceSmall not selecting properly - won't preview, and displays as AnnounceLarge for some reason. Removed for now. - Calia
					width = "half",
					choices = {"ZoFontAnnounce","ZoFontAnnounceLarge","ZoFontAnnounceMedium","ZoFontAnnounceMessage"},
					getFunc = TI.GetDisplayFont,
					setFunc = TI.SetDisplayFont,
					default = TI.defaults.AnnounceDisplayFont,
				},
				-- Announcement Display Width
				{
					type = "slider",
					name = TI.locale.settings["TGI_SettingsAnnounceDisplayWidth"],
					tooltip = TI.locale.settings.tooltip["TGI_SettingsAnnounceDisplayWidth"],
					width = "half",
					min = 200,
					max = 1680,
					getFunc = TI.GetDisplayWidth,
					setFunc = TI.SetDisplayWidth,
					default = TI.defaults.AnnounceDisplayWidth,
				},
				-- Player Display Name Preferences
				{
					type = "dropdown",
					name = TI.locale.settings["TGI_SettingsNameFormat"],
					tooltip = TI.locale.settings.tooltip["TGI_SettingsNameFormat"],
					width = "half",
					choices = {TI.SETTINGS_SHOW_ACC_AND_CHAR_NAME, TI.SETTINGS_SHOW_CHAR_NAME, TI.SETTINGS_SHOW_ACC_NAME},
					getFunc = TI.GetNameFormatSettings,
					setFunc = TI.SetNameFormatSettings,
					default = TI.defaults.NameFormat,
				},
				-- Set Player Name Color
				{
					type = "colorpicker",
					name = TI.locale.settings["TGI_SettingsPlayerNameColor"],
					tooltip = TI.locale.settings.tooltip["TGI_SettingsPlayerNameColor"],
					width = "half",
					getFunc = TI.GetPlayerNameColor,
					setFunc = TI.SetPlayerNameColor,
					default = { ["r"] = TI.defaults.PlayerNameColor[1], ["g"] = TI.defaults.PlayerNameColor[2], ["b"] = TI.defaults.PlayerNameColor[3], ["a"] = TI.defaults.PlayerNameColor[4] }
				}
			}
		},
		{
			type = "header",
			name = TI.locale.settings["TGI_SettingsGuildsHeader"],
		}
	}

	for i=1,5 do
		local guildName = GetGuildName(GetGuildId(i))
		if(not guildName or  (guildName):len() < 1) then
			guildName = "Guild "..i
		end

		table.insert(options,
			{
				type = "submenu",
				name = guildName,
				controls = {
					-- Show Announcements
					{
						
						type = "checkbox",
						name = TI.locale.settings["TGI_SettingsOverallAnnounceGuild"],
						tooltip = TI.locale.settings.tooltip["TGI_SettingsOverallAnnounceGuild"],
						width = "full",
						getFunc = function() return TI.GetGuildSetting(i) end,
						setFunc = function(newVal) TI.SetGuildSetting(i,newVal) end,
						default = TI.defaults.guildSettings[i].ShowAnnouncements,
					},
					-- Guild Name Abbreviation
					{
						type = "editbox",
						name = TI.locale.settings["TGI_SettingsAbbreviationAnnounceGuild"],
						tooltip = TI.locale.settings.tooltip["TGI_SettingsAbbreviationAnnounceGuild"],
						width = "half",
						isMultiLine = false,
						getFunc = function() return TI.GetGuildAbbreviationSetting(i) end,
						setFunc = function(newVal) TI.SetGuildAbbreviationSetting(i,newVal) end,
						default = TI.defaults.guildSettings[i].Abbreviation,
					},
					-- Guild Name Color
					{
						type = "colorpicker",
						name = TI.locale.settings["TGI_SettingsGuildNameColorGuild"],
						tooltip = TI.locale.settings.tooltip["TGI_SettingsGuildNameColorGuild"],
						width = "half",
						getFunc = function() return TI.GetGuildNameColorSetting(i) end,
						setFunc = function(r,g,b,a) TI.SetGuildNameColorSetting(i,r,g,b,a) end,
						default = { ["r"] = TI.defaults.guildSettings[i].GuildNameColor[1], ["g"] = TI.defaults.guildSettings[i].GuildNameColor[2], ["b"] = TI.defaults.guildSettings[i].GuildNameColor[3], ["a"] = TI.defaults.guildSettings[i].GuildNameColor[4] },
					},
					-- Show roster changes
					{
						type = "checkbox",
						name = TI.locale.settings["TGI_SettingsMemberAnnounceGuild"],
						tooltip = TI.locale.settings.tooltip["TGI_SettingsMemberAnnounceGuild"],
						width = "half",
						getFunc = function() return TI.GetGuildMemberSetting(i) end,
						setFunc = function(newVal) TI.SetGuildMemberSetting(i,newVal) end,
						disabled = function() return not TI.GetGuildSetting(i) end,
						default = TI.defaults.guildSettings[i].ShowMemberChange,
					},
					-- Show online changes
					{
						type = "checkbox",
						name = TI.locale.settings["TGI_SettingsStatusAnnounceGuild"],
						tooltip = TI.locale.settings.tooltip["TGI_SettingsStatusAnnounceGuild"],
						width = "half",
						getFunc = function() return TI.GetGuildStatusSetting(i) end,
						setFunc = function(newVal) TI.SetGuildStatusSetting(i,newVal) end,
						disabled = function() return not TI.GetGuildSetting(i) end,
						default = TI.defaults.guildSettings[i].ShowStatusChange,
					},
					-- Show level changes
					{
						type = "checkbox",
						name = TI.locale.settings["TGI_SettingsLevelAnnounceGuild"],
						tooltip = TI.locale.settings.tooltip["TGI_SettingsLevelAnnounceGuild"],
						width = "half",
						getFunc = function() return TI.GetGuildLevelSetting(i) end,
						setFunc = function(newVal) TI.SetGuildLevelSetting(i,newVal) end,
						disabled = function() return not TI.GetGuildSetting(i) end,
						default = TI.defaults.guildSettings[i].ShowLevelChange,
					},
				}
			});
	end

	local menuPanel = {
		type = "panel",
		name = TI.locale.settings["ThurisazCtrlP"],
		displayName =  TI:ApplyChatColor(TI.locale.settings["ThurisazCtrlP"], {0,1,0,0.5}),
		slashCommand = MENU_SLASH_COMMAND_STRING,	--(optional) will register a keybind to open to this panel
		registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
		registerForDefaults = false,	--boolean (optional) (will set all options controls back to default values)
	}

	local LAM = LibStub:GetLibrary("LibAddonMenu-2.0");
	LAM:RegisterAddonPanel("TGI_ControlPanel", menuPanel);
	LAM:RegisterOptionControls("TGI_ControlPanel", options);
end

-------------------------------------------------------------------------
-- Settings 
TI.SETTINGS_DISPLAY_LABEL_COUNT = 5

--CharName in Roster Settings
function TI.GetCharNameSettings()
	return TI.vars.ShowCharNames
end

function TI.SetCharNameSettings(newVal)
	TI.vars.ShowCharNames = newVal
	ReloadUI()
end

--Name Format Settings
function TI.GetNameFormatSettings()
	return TI.vars.NameFormat
end

function TI.SetNameFormatSettings(newVal)
	TI.vars.NameFormat = newVal
end

--Show Announcements Settings
function TI.GetGuildSettings()
	return TI.vars.ShowAnnouncements
end

function TI.SetGuildSettings(newVal)
	TI.vars.ShowAnnouncements = newVal
end

--Display Type Settings
function TI.GetDisplayTypeSettings()
	return TI.vars.DisplayType
end

function TI.SetDisplayTypeSettings(newVal)
	if(newVal == TI.SETTINGS_DISPLAY_TYPE_CHAT) then
		TI.displayControl:SetHidden(true)
        TI.vars.DisplayTypeChat = true
        TI.vars.DisplayTypeHUD = false
	else
		TI.displayControl:SetHidden(false)
    end

    if(newVal == TI.SETTINGS_DISPLAY_TYPE_LABEL) then
        TI.vars.DisplayTypeHUD = true
        TI.vars.DisplayTypeChat = false
    end

    if(newVal == TI.SETTINGS_DISPLAY_TYPE_BOTH) then
        TI.vars.DisplayTypeChat = true
        TI.vars.DisplayTypeHUD = true
    end

	TI.vars.DisplayType = newVal
end

function TI.GetDisplayType(setting)
    if(setting == TI.SETTINGS_DISPLAY_TYPE_CHAT) then
        return TI.vars.DisplayTypeChat
    elseif(setting == TI.SETTINGS_DISPLAY_TYPE_LABEL) then
        return TI.vars.DisplayTypeHUD
    end

end


function TI.GetDisplayMoveable()
	return TI.displayControl:IsMouseEnabled()
end

function TI.SetDisplayMoveable(newVal)
	TI.displayControl:SetMouseEnabled(newVal)
	TI.displayControl:SetMovable(newVal)
	TI.displayControlbackDrop:SetHidden(not newVal)
end

--Display Width Setting
function TI.GetDisplayWidth()
	return TI.vars.AnnounceDisplayWidth
end

function TI.SetDisplayWidth(newVal)
	TI.vars.AnnounceDisplayWidth = newVal
	TI.displayControl:SetWidth(TI.vars.AnnounceDisplayWidth)
	TI.displayControlbackDrop:SetWidth(TI.vars.AnnounceDisplayWidth)
--	for i = 1, #TI.SCT.labels do
--		TI.SCT.labels[i]:SetWidth(TI.vars.AnnounceDisplayWidth)
--	end
end

--Display Time Setting
function TI.GetDisplayTime()
	return TI.vars.AnnounceDisplayTime
end

function TI.SetDisplayTime(newVal)
	TI.vars.AnnounceDisplayTime = newVal
	TI.SCT:SetTime(TI.vars.AnnounceDisplayTime)
end

--Display Font
function TI.GetDisplayFont()
	return TI.vars.AnnounceDisplayFont
end

function TI.SetDisplayFont(newVal)
	TI.vars.AnnounceDisplayFont = newVal
	TI.AnnouncementTest()
end

--Display ColorMode
function TI.GetDisplayColorModeSettings()
    return TI.vars.AnnounceDisplayColorMode;
end
function TI.SetDisplayColorModeSettings(newVal)
    TI.vars.AnnounceDisplayColorMode = newVal
end

--Display Align
function TI.GetDisplayAlignSetting()
    return TI.vars.AnnounceDisplayAlignment;
end

function TI.SetDisplayAlignSetting(newVal)
    TI.vars.AnnounceDisplayAlignment = newVal
end

function TI.GetDisplayAlign()
    if( TI.vars.AnnounceDisplayAlignment == TI.SETTINGS_DISPLAY_ALIGN_LEFT) then
        return TEXT_ALIGN_LEFT
    elseif( TI.vars.AnnounceDisplayAlignment == TI.SETTINGS_DISPLAY_ALIGN_CENTER) then
        return TEXT_ALIGN_CENTER
    elseif( TI.vars.AnnounceDisplayAlignment == TI.SETTINGS_DISPLAY_ALIGN_RIGHT) then
        return TEXT_ALIGN_RIGHT
    end
    return TEXT_ALIGN_CENTER
end

--Player Name Color Settings
function TI.GetPlayerNameColor()
	return TI.vars.PlayerNameColor[1],TI.vars.PlayerNameColor[2],TI.vars.PlayerNameColor[3],TI.vars.PlayerNameColor[4]
end
function TI.GetPlayerNameColorTable()
	return TI.vars.PlayerNameColor
end

function TI.SetPlayerNameColor(r,g,b,a)
	TI.vars.PlayerNameColor = {r,g,b,a}
end

--[[
--Show Timestamp
 ]]
function TI.GetShowTimestamp()
    return TI.vars.AnnounceShowTimestamp
end

function TI.SetShowTimestamp(newVal)
    TI.vars.AnnounceShowTimestamp = newVal
end


-----------------------------------------------------------------------------------
--General Show Announcements Settings
function TI.GetGuildSetting(guildId)
	return TI.vars.guildSettings[guildId].ShowAnnouncements
end

function TI.SetGuildSetting(guildId, newVal)
	TI.vars.guildSettings[guildId].ShowAnnouncements = newVal
end

-- Guild Abbreviation Settings
function TI.GetGuildAbbreviationSetting(guildId)
	return TI.vars.guildSettings[guildId].Abbreviation;
end

function TI.SetGuildAbbreviationSetting(guildId, newVal)
	TI.vars.guildSettings[guildId].Abbreviation = newVal
end


--Status Change Settings
function TI.GetGuildStatusSetting(guildId)
	return TI.vars.guildSettings[guildId].ShowStatusChange
end

function TI.SetGuildStatusSetting(guildId, newVal)
	TI.vars.guildSettings[guildId].ShowStatusChange = newVal
end


--Level Change Settings
function TI.GetGuildLevelSetting(guildId)
	return TI.vars.guildSettings[guildId].ShowLevelChange
end

function TI.SetGuildLevelSetting(guildId, newVal)
	TI.vars.guildSettings[guildId].ShowLevelChange = newVal
end

--Member Change Settings
function TI.GetGuildMemberSetting(guildId)
	return TI.vars.guildSettings[guildId].ShowMemberChange
end

function TI.SetGuildMemberSetting(guildId, newVal)
	TI.vars.guildSettings[guildId].ShowMemberChange = newVal
end


--Raid Score Notifications Settings  (removed until confirmed working - Calia)
function TI.GetRaidScoreNotifySetting(guildId)
	return TI.vars.guildSettings[guildId].ShowRaidScoreNotifications;
	end

function TI.SetRaidScoreNotifySetting(guildId, newVal)
	TI.vars.guildSettings[guildId].ShowRaidScoreNotifications = newVal;
end


--Guild Name Color Settings
---Returns Color Table {r,g,b,a} of guildId
function TI.GetGuildNameColorTable(guildId)
	guildId = TI:getNormalizedGuildId(guildId)
	if(TI.vars.guildSettings[guildId].GuildNameColor) then
		return TI.vars.guildSettings[guildId].GuildNameColor
	end
	return {1,0,0,1};
end

function TI.GetGuildNameColorSetting(guildId)
	return unpack(TI.vars.guildSettings[guildId].GuildNameColor);
end

function TI.SetGuildNameColorSetting(guildId, r,g,b,a)
	TI.vars.guildSettings[guildId].GuildNameColor = {r,g,b,a};
end

---Migrates savedVars to new format since 0.43
function TI.migrateSavedvars()
	if(TI.vars.migrationDone) then return end

	for i=1, 5 do

		if(TI.vars["ShowAnnouncementsGuild"..i] ~= nil) then
			TI.vars.guildSettings[i].ShowAnnouncements = TI.vars["ShowAnnouncementsGuild"..i];
			TI.vars["ShowAnnouncementsGuild"..i] = nil;
		end

		if(TI.vars["AbbreviationAnnouncementsGuild"..i] ~= nil) then
			TI.vars.guildSettings[i].Abbreviation = TI.vars["AbbreviationAnnouncementsGuild"..i];
			TI.vars["AbbreviationAnnouncementsGuild"..i] = nil;
		end

		if(TI.vars["ShowStatusAnnouncementsGuild"..i] ~= nil) then
			TI.vars.guildSettings[i].ShowStatusChange = TI.vars["ShowStatusAnnouncementsGuild"..i];
			TI.vars["ShowStatusAnnouncementsGuild"..i] = nil;
		end

		if(TI.vars["ShowLevelAnnouncementsGuild"..i] ~= nil) then
			TI.vars.guildSettings[i].ShowLevelChange = TI.vars["ShowLevelAnnouncementsGuild"..i];
			TI.vars["ShowLevelAnnouncementsGuild"..i] = nil;
		end

		if(TI.vars["ShowMemberAnnouncementsGuild"..i] ~= nil) then
			TI.vars.guildSettings[i].ShowMemberChange = TI.vars["ShowMemberAnnouncementsGuild"..i];
			TI.vars["ShowMemberAnnouncementsGuild"..i] = nil;
		end

		if(TI.vars["GuildNameColorAnnouncementsGuild"..i] ~= nil) then
			TI.vars.guildSettings[i].GuildNameColor = TI.vars["GuildNameColorAnnouncementsGuild"..i];
			TI.vars["GuildNameColorAnnouncementsGuild"..i] = nil;
		end

	end
	TI.vars.migrationDone = true;
	d("migrated saved vars!");

end