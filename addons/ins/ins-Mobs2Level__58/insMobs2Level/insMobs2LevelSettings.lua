-- our global variable
local insM2L = insM2L

-- here we will keep our settings and will make a menu to change them
insM2L.insM2LSettings = ZO_Object:Subclass()

local LAM = LibAddonMenu2

--------------------------------------------------------------------
--  insM2L.insM2LSettings:New function
--  input: none
--  Purpose: Create a settings object
--------------------------------------------------------------------
function insM2L.insM2LSettings:New()
	local obj = ZO_Object.New(self)
	obj:Initialize()
	return obj
end

function insM2L.insM2LSettings:GetLang()
	local lang = GetCVar("language.2")
	if ( lang == "de" or lang == "en" or lang == "fr" ) then
		return lang
	end
	return "en"
end

--------------------------------------------------------------------
--  SetOutputTab function
--  input: Chat Tab ID (an integer)
--  Purpose: Move the output to indicated Chat Tab
--------------------------------------------------------------------
function insM2L.insM2LSettings:SetOutputTab(tabn)
	local tab = string.format("ZO_ChatWindowTemplate%d",tabn)
	local name = string.format("ZO_ChatWindowTabTemplate%dText",tabn)
	local tabExist = _G[tab] ~= nil

	if ( tabExist ) then
--		insM2L.tab = _G[tab]["buffer"]
		insM2L.tabName = _G[name]:GetText()
	end

	return tabExist
end

--------------------------------------------------------------------
--  insM2L.insM2LSettings:Initialize function
--  input: none
--  Purpose: Initialize settings, use default value if a setting doesn't exist
--------------------------------------------------------------------
function insM2L.insM2LSettings:Initialize()
	insM2L.defaults = {
		debg = false,
		craft = true,
		kill = true,
		quest = true,
		event = true,
		output = false,
		tab = 1,
		timestamp = false,
		custXPmsg    = "<cW>You gained <cG><1><cY> XP <cW>: <cG><2><cW> to go (<cG><3> <cY><999><cW>)",
		custSkillmsg = "<cW>You gained <cG><1><cY> XP <cW>: <cG><2><cW> to go (<cG><3> <cY><4> repeats<cW>)",
		custQuestmsg = "<cW>You gained <cG><1><cY> XP <cW>: <cG><2><cW> to go (<cG><3> <cY><999><cW>)",
		custEventmsg = "<cW>You gained <cG><1><cY> XP <cW>: <cG><2><cW> to go (<cG><3> <cY><999><cW>)",
	}
	insM2L.SV = ZO_SavedVars:NewAccountWide("insM2L_SV",102,"Default Namespace",insM2L.defaults,"Default Profile")
	
    self:CreateOptionsMenu()
end

--------------------------------------------------------------------
--  insM2L.insM2LSettings:CreateOptionsMenu
--  input: none
--  Purpose: Create settings menu using LibAddonMenu v2
--------------------------------------------------------------------
function insM2L.insM2LSettings:CreateOptionsMenu()
--	load phrases based on client locale
	local phrases = insM2L.strings[self:GetLang()].phrases

--	initialize main panel for our settings
	local lampanel = {
		type = "panel",
		name = "ins:Mobs2Level",
		displayName  = "|cFFFFFFins|r|cFFFF00:|r|c00FF00Mobs2Level|r",
		author = insM2L.author,
		version = insM2L.version,
		slashCommand = "/m2l",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
--	populate our settings menu
	local lamoptions = {
		{
			type = "header",
			name = phrases.GENERAL,
		},
--	toggle time stamp
		{
			type = "checkbox",
			name = phrases.TIMESTAMP,
			tooltip = nil,
			getFunc = function() return insM2L.SV.timestamp end,
			setFunc = function(value) insM2L.SV.timestamp = not insM2L.SV.timestamp end,
			default = insM2L.defaults.timestamp,
		},
-- set the output to indicated Chat Tab
		{
			type = "editbox",
			name = phrases.TAB,
			tooltip = insM2L.tabName,
			isMultiline = false,
			getFunc = function() return insM2L.SV.tab end,
			setFunc = function(value)
						if ( ( value ~= nil ) and ( value ~= "" ) and ( self:SetOutputTab(value) ) ) then
							insM2L.SV.tab = value
						end
			end,
			warning = phrases.TAB_WARNING,
			default = insM2L.defaults.tab,
		},
--	toggle craft skills XP gain output
		{
			type = "checkbox",
			name = phrases.CRAFT,
			tooltip = nil,
			getFunc = function() return insM2L.SV.craft end,
			setFunc = function(value) insM2L.SV.craft = not insM2L.SV.craft end,
			default = insM2L.defaults.craft,
		},
--	toggle kill XP gain output
		{
			type = "checkbox",
			name = phrases.KILL,
			tooltip = nil,
			getFunc = function() return insM2L.SV.kill end,
			setFunc = function(value) insM2L.SV.kill = not insM2L.SV.kill end,
			default = insM2L.defaults.kill,
		},
--	toggle quest XP gain output
		{
			type = "checkbox",
			name = phrases.QUEST,
			tooltip = nil,
			getFunc = function() return insM2L.SV.quest end,
			setFunc = function(value) insM2L.SV.quest = not insM2L.SV.quest end,
			default = insM2L.defaults.quest,
		},
--	toggle event XP gain output
		{
			type = "checkbox",
			name = phrases.EVENT,
			tooltip = nil,
			getFunc = function() return insM2L.SV.event end,
			setFunc = function(value) insM2L.SV.event = not insM2L.SV.event end,
			default = insM2L.defaults.event,
		},
--	toggle debug mode
		{
			type = "checkbox",
			name = phrases.DEBUG,
			tooltip = nil,
			getFunc = function() return insM2L.SV.debg end,
			setFunc = function(value) insM2L.SV.debg = not insM2L.SV.debg end,
			default = insM2L.defaults.debg,
		},
		{
			type = "header",
			name = phrases.CUSTOMHEAD,
		},
		{
			type = "description",
			text = phrases.CUSTOM_DESCRIPTION1,
		},
		{
			type = "description",
			text = phrases.CUSTOM_DESCRIPTION2,
		},
		{
			type = "description",
			text = phrases.CUSTOM_DESCRIPTION3,
		},
		{
			type = "checkbox",
			name = phrases.CUSTOM,
			tooltip = nil,
			getFunc = function() return insM2L.SV.output end,
			setFunc = function(value) insM2L.SV.output = not insM2L.SV.output end,
			default = insM2L.defaults.output,
		},
-- custom output for skills
		{
			type = "editbox",
			name = phrases.CUSTOMSKILL,
			tooltip = nil,
			isMultiline = false,
			getFunc = function() return insM2L.SV.custSkillmsg end,
			setFunc = function(value)
						if ( ( value ~= nil ) and ( value ~= "" ) ) then
							insM2L.SV.custSkillmsg = value
						end
			end,
			default = insM2L.defaults.custSkillmsg,
		},
-- custom output for kills
		{
			type = "editbox",
			name = phrases.CUSTOMKILL,
			tooltip = nil,
			isMultiline = false,
			getFunc = function() return insM2L.SV.custXPmsg end,
			setFunc = function(value)
						if ( ( value ~= nil ) and ( value ~= "" ) ) then
							insM2L.SV.custXPmsg = value
						end
			end,
			default = insM2L.defaults.custXPmsg,
		},
-- custom output for quests
		{
			type = "editbox",
			name = phrases.CUSTOMQUEST,
			tooltip = nil,
			isMultiline = false,
			getFunc = function() return insM2L.SV.custQuestmsg end,
			setFunc = function(value)
						if ( ( value ~= nil ) and ( value ~= "" ) ) then
							insM2L.SV.custQuestmsg = value
						end
			end,
			default = insM2L.defaults.custQuestmsg,
		},
-- custom output for events
		{
			type = "editbox",
			name = phrases.CUSTOMEVENT,
			tooltip = nil,
			isMultiline = false,
			getFunc = function() return insM2L.SV.custEventmsg end,
			setFunc = function(value)
						if ( ( value ~= nil ) and ( value ~= "" ) ) then
							insM2L.SV.custEventmsg = value
						end
			end,
			default = insM2L.defaults.custEventmsg,
		},
	}
	
--	register our settings menu and its options
	LAM:RegisterAddonPanel("insM2LSettingsPanel", lampanel)
	LAM:RegisterOptionControls("insM2LSettingsPanel", lamoptions)
end

