-- Guild Colors

GuildColors = {}
GuildColors.name = "GuildColors"
GuildColors.version = "1.0.12"
GuildColors.lastUpdate = "04.06.2024"
GuildColors.controls = {}
GuildColors.settings = nil
GuildColors.Vars = {}
local em = GetEventManager()
local LSC = LibSlashCommander

function GuildColors.OnAddOnLoaded(event, addonName) 
	if addonName == GuildColors.name then
		em:UnregisterForEvent(GuildColors.name, EVENT_ADD_ON_LOADED);
		GuildColors:Initialize();
	end
end

function GuildColors:saveColors()
	self.settings.colors[1] = ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_GUILD_1))
	self.settings.colors[2] = ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_OFFICER_1))
	self.settings.colors[3] = ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_GUILD_2))
	self.settings.colors[4] = ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_OFFICER_2))
	self.settings.colors[5] = ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_GUILD_3))
	self.settings.colors[6] = ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_OFFICER_3))
	self.settings.colors[7] = ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_GUILD_4))
	self.settings.colors[8] = ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_OFFICER_4))
	self.settings.colors[9] = ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_GUILD_5))
	self.settings.colors[10] = ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_OFFICER_5))
	d("Colors Saved")
end

function GuildColors:setColor(category, color) 
	local r,g,b = ZO_ColorDef:New(color):UnpackRGB();
	SetChatCategoryColor(category, r, g, b);
end

function GuildColors:applyColors()
	GuildColors:setColor(CHAT_CATEGORY_GUILD_1, self.settings.colors[1])
	GuildColors:setColor(CHAT_CATEGORY_OFFICER_1, self.settings.colors[2])
	GuildColors:setColor(CHAT_CATEGORY_GUILD_2, self.settings.colors[3])
	GuildColors:setColor(CHAT_CATEGORY_OFFICER_2, self.settings.colors[4])
	GuildColors:setColor(CHAT_CATEGORY_GUILD_3, self.settings.colors[5])
	GuildColors:setColor(CHAT_CATEGORY_OFFICER_3, self.settings.colors[6])
	GuildColors:setColor(CHAT_CATEGORY_GUILD_4, self.settings.colors[7])
	GuildColors:setColor(CHAT_CATEGORY_OFFICER_4, self.settings.colors[8])
	GuildColors:setColor(CHAT_CATEGORY_GUILD_5, self.settings.colors[9])
	GuildColors:setColor(CHAT_CATEGORY_OFFICER_5, self.settings.colors[10])
	d("All colors applied")
end

function GuildColors:Initialize()
	self.Vars.savedVariablesName = 'GuildColors_SavedVariables'
	self.Vars.profile=nil
	self.Vars.configVersion = 1
	self.Vars.configDefaults = {
		["configVersion"] = self.Vars.configVersion,
		["colors"] = { 
			ZO_ColorDef:New(1,0,0),
			ZO_ColorDef:New(0,1,0),
			ZO_ColorDef:New(0,0,1),
			ZO_ColorDef:New(1,1,0),
			ZO_ColorDef:New(1,0,1),
			ZO_ColorDef:New(0,1,1),
			ZO_ColorDef:New(1,1,1),
			ZO_ColorDef:New(.5,0,0),
			ZO_ColorDef:New(0,.5,0),
			ZO_ColorDef:New(0,0,.5),
		}
	}
	self.settings = ZO_SavedVars:NewAccountWide(
		self.Vars.savedVariablesName, 
		self.Vars.configVersion, 
		self.Vars.profile,
		self.Vars.configDefaults
	)
	LSC:Register("/saveguildcolors", function() GuildColors:saveColors() end , "Saves the current guild colors as your defaults");
	LSC:Register("/applyguildcolors", function() GuildColors:applyColors() end, "Applies defaults as your guild colors");
end

em:RegisterForEvent(GuildColors.name, EVENT_ADD_ON_LOADED, GuildColors.OnAddOnLoaded)

-- 
