local CBG_Object = ZO_Object:Subclass()
function CBG_Object:New(...)
	local object = ZO_Object.New(self)
	object:Initialize(...)
	return object
end
function CBG_Object:Initialize()
	self.ADDON_NAME = "ChatBG"
	self.ADDON_VERSION = "1.4"
	self.settings = {}
	self.player_activated = false
end
function CBG_Object:CreateSettingsMenu()
	if not LibAddonMenu2 then return end

	local defaults = self:DefaultSettings()
	local OptionsName = "ChatBGOptions"
	local panelData = {
		type = "panel",
		name = self.ADDON_NAME,
		displayName = zo_strformat("|cff8800<<1>>|r", self.ADDON_NAME),
		author = "Weolo",
		version = self.ADDON_VERSION,
		registerForRefresh = true,
		registerForDefaults = true,
		website = "https://www.esoui.com/downloads/info2296-ChatBG.html",
		feedback = "https://www.esoui.com/downloads/info2296-ChatBG.html#comments"
	}
	self.panel = LibAddonMenu2:RegisterAddonPanel(OptionsName, panelData)

	local optionsData = {
		{
			type = "header",
			name = SI_WINDOW_TITLE_CHAT_COLOR_OPTIONS
		},{
			type = "colorpicker",
			name = SI_CHAT_OPTIONS_BACKGROUND_COLOR,
			getFunc = function() return self.settings.colour.r, self.settings.colour.g, self.settings.colour.b, self.settings.colour.a end,
			setFunc = function(r,g,b,a)
				self.settings.colour = {r=r, g=g, b=b, a=a}
				self:SetBgColour()
			end,
			default = defaults.colour
		}
	}
	LibAddonMenu2:RegisterOptionControls(OptionsName, optionsData)
end
function CBG_Object:OnPlayerActivated()
	if self.player_activated then return end --Only the first time
	self.player_activated = true
	EVENT_MANAGER:UnregisterForEvent(self.ADDON_NAME, EVENT_PLAYER_ACTIVATED)
	self:SetBgColour()
	self:CreateSettingsMenu()
end
function CBG_Object:DefaultSettings()
	return {
		colour = {
			r = 0,
			g = 0,
			b = 0,
			a = 0.5
		}
	}
end
function CBG_Object:SetBgColour()
	if ZO_ChatWindowBg then
		ZO_ChatWindowBg:SetCenterTexture(nil)
		ZO_ChatWindowBg:SetEdgeTexture(nil, 256, 256, 32)
		ZO_ChatWindowBg:SetCenterColor(self.settings.colour.r, self.settings.colour.g, self.settings.colour.b, self.settings.colour.a)
		ZO_ChatWindowBg:SetEdgeColor(self.settings.colour.r, self.settings.colour.g, self.settings.colour.b, self.settings.colour.a)
	end
end
function CBG_Object:OnLoaded(addonName)
	local name = self.ADDON_NAME
	if addonName ~= name then return end
	EVENT_MANAGER:UnregisterForEvent(name, EVENT_ADD_ON_LOADED)
	self.settings = ZO_SavedVars:NewAccountWide("ChatBGSettings", 1, nil, self:DefaultSettings())
	EVENT_MANAGER:RegisterForEvent(name, EVENT_PLAYER_ACTIVATED, function() self:OnPlayerActivated() end)
end

ChatBG = CBG_Object:New()
EVENT_MANAGER:RegisterForEvent(ChatBG.ADDON_NAME, EVENT_ADD_ON_LOADED, function(_, addonName) ChatBG:OnLoaded(addonName) end)