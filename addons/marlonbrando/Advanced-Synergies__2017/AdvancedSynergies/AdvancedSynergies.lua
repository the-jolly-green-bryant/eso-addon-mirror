-------------------------------------------------------------------------------
-- Advanced Synergies
-------------------------------------------------------------------------------
local addon = {
	name = "AdvancedSynergies",
	displayName = "Advanced Synergies",
	displayNameShort = "Advanced Synergies",
	author = "generic, Valandil",
	version = "1.0.7",
	savedVarVersion = "2",
}

local AdvSyn = _G['AdvSynAddon']
local L = AdvSyn:GetLanguage()

GenericAdvancedSynergies = ZO_Object:Subclass()
function GenericAdvancedSynergies:New(...)
	local container = ZO_Object.New(self)
	container:Initialize(...)
	return container
end

function GenericAdvancedSynergies:Initialize()
	self:InitializeSettingsMenu()
	self:ApplyStyle()
	self:RestorePosition()
	self:HookSynergy()
end

do
    local lastSynergyName = ''
    local isShown = false
    function GenericAdvancedSynergies:ApplyStyle()
	isShown = false
	local color = ZO_ColorDef:New(unpack(self.savedVars.colour))
	AdvancedSynergiesUINotification:SetColor(unpack(self.savedVars.colour))
	AdvancedSynergiesUINotification:SetText(L.SynergyNotification)
	lastSynergyName = L.SynergyNotification
	AdvancedSynergiesUI:SetHidden(not self.savedVars.setupmode)
	AdvancedSynergiesUINotification:SetAlpha(self.savedVars.alpha)
	AdvancedSynergiesUINotification:SetHidden(false)
	AdvancedSynergiesUITooltip:SetText(L.SynergyNotificationTooltip)
	AdvancedSynergiesUITooltip:SetHidden(not self.savedVars.setupmode)
	local fontname = 'EsoUi/Common/Fonts/Univers67.otf|'..self.savedVars.fontsize..'|soft-shadow-thick';
	AdvancedSynergiesUIFont:SetFont(fontname)

    end

    function GenericAdvancedSynergies:SetText(synergyName)
    end

    function GenericAdvancedSynergies:RestorePosition()
	local left = self.savedVars.left
	local top = self.savedVars.top
	AdvancedSynergiesUI:ClearAnchors()
	if left == -1 and top == -1 then
	    AdvancedSynergiesUI:SetAnchor(CENTER, GuiRoot, CENTER, 0, -50)
	else
	    AdvancedSynergiesUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
	end
	AdvancedSynergiesUI:SetMovable(self.savedVars.setupmode)
    end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Synergy Notification onscreen
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local debugdata = {synergies = {}}
local languageId = GetCVar('language.2')
    function GenericAdvancedSynergies:HookSynergy()
	if self.savedVars.debugdata ~= nil then
	    debugdata = self.savedVars.debugdata
	end
	ZO_PreHook(SYNERGY, 'OnSynergyAbilityChanged',
	    function ()
		local active = self.savedVarsChar.active
		local setupmode = self.savedVars.setupmode
		local shownames = self.savedVars.shownames
		local debugmode = self.savedVars.debugmode
		local synergyName, iconFilename = GetSynergyInfo()
		local displayName = L.SynergyNotification
		if shownames then
		  displayName = synergyName
		end
		if active then
		    if synergyName then --hoffentlich heißt das "Synergie verwendbar"
			if lastSynergyName ~= displayName then
			  AdvancedSynergiesUINotification:SetText(ZO_CachedStrFormat('<<1>>', displayName))
			  lastSynergyName = displayName
			end
			if not isShown then
			    AdvancedSynergiesUI:SetHidden(false)
			    isShown = true
			end
			--local wassupressed = SHARED_INFORMATION_AREA:IsSupressed()
			if iconFilename:find('ability_sorcerer_lightning_splash') then
			      --SHARED_INFORMATION_AREA:SetSupressed(true)
			elseif	iconFilename:find('achievement_darkbrotherhood_003') then
			      --SHARED_INFORMATION_AREA:SetSupressed(true)
			else
			      --SHARED_INFORMATION_AREA:SetSupressed(false)
			end

		    else
			if isShown then
			    if (lastSynergyName ~= L.SynergyNotification) and setupmode then
			      AdvancedSynergiesUINotification:SetText(L.SynergyNotification)
			      lastSynergyName = L.SynergyNotification
			    end
			    AdvancedSynergiesUI:SetHidden(not setupmode)
			    isShown = false
			end
		    end
		end
		if debugmode then
		    if synergyName then
			if debugdata.synergies[iconFilename] == nil then
			    debugdata.synergies[iconFilename] = {  }
			end
			if debugdata.synergies[iconFilename][languageId] == nil or debugdata.synergies[iconFilename][languageId] ~= synergyName then
			    debugdata.synergies[iconFilename][languageId] = synergyName
			    self.savedVars.debugdata.synergies[iconFilename] = debugdata.synergies[iconFilename]
			end
		    end
		end
	    end
	)
    end
end

function GenericAdvancedSynergies:InitializeSettingsMenu()

	local menu = LibAddonMenu2

	local panel = {
		type = "panel",
		name = addon.displayName,
		displayName = addon.displayName,
		author = addon.author,
	version = addon.version,
		--website = "http://www.esoui.com/downloads/info1851-GroupLeader.html",
		--slashCommand = "/sgl",
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local options = {
		{
			type = "checkbox",
			name = L.SettingMoveNotification,
			tooltip = L.SettingMoveNotificationTooltip,
			getFunc = function() return self.savedVars.setupmode end,
			setFunc = function(value)
				self.savedVars.setupmode = value
				AdvancedSynergiesUI:SetMovable(self.savedVars.setupmode)
				self:ApplyStyle()
				self:RestorePosition()
			end,
			default = true,
		},
    {
      type = "checkbox",
      name = L.SettingShowNames,
      tooltip = L.SettingShowNamesTooltip,
      getFunc = function() return self.savedVars.shownames end,
      setFunc = function(value)
	self.savedVars.shownames = value
      end,
      default = true,
    },
		{
			type = "slider",
			name = L.SettingFontsize,
			min = 15,
			max = 70,
			step = 1,
			decimals = 0,
			clampInput = true,
			getFunc = function() return self.savedVars.fontsize end,
			setFunc = function(value)
				self.savedVars.fontsize = value
				self:ApplyStyle()
				self:RestorePosition()
			end,
			default = self.default.fontsize
		},
		{
			type = "colorpicker",
			name = SI_WINDOW_TITLE_COLOR_PICKER,
			default = ZO_ColorDef:New(unpack(self.default.colour)),
			getFunc = function() return unpack(self.savedVars.colour) end,
			setFunc = function(r, g, b)
				self.savedVars.colour = {r, g, b}
				self:ApplyStyle()
				self:RestorePosition()
			end,
			width = "half",
		},
		{
			type = "slider",
			name = L.SettingTransparency,
			tooltip = L.SettingTransparencyTooltip,
			min = 0,
			max = 100,
			step = 5,
			decimals = 0,
			clampInput = true,
			getFunc = function() return self.savedVars.alpha * 100 end,
			setFunc = function(value)
				self.savedVars.alpha = value / 100
				self:ApplyStyle()
				self:RestorePosition()
			end,
			default = self.default.alpha * 100,
			width = "half",
		},
    {
      type = "checkbox",
      name = L.SettingActiveOnChar,
      tooltip = L.SettingActiveOnCharTooltip,
      getFunc = function() return self.savedVarsChar.active end,
      setFunc = function(value)
	self.savedVarsChar.active = value
	self:ApplyStyle()
	self:RestorePosition()
      end,
      default = true,
    },
		{
			type = "checkbox",
			name = L.SettingDebug,
      tooltip = L.SettingDebugTooltip,
			getFunc = function() return self.savedVars.debugmode end,
			setFunc = function(value)
				self.savedVars.debugmode = value
				AdvancedSynergiesUI:SetMovable(self.savedVars.debugmode)
				self:ApplyStyle()
				self:RestorePosition()
			end,
			default = false,
		},
	}

	menu:RegisterAddonPanel(addon.name.."OptionsMenu", panel)
	menu:RegisterOptionControls(addon.name.."OptionsMenu", options)

end

function GenericAdvancedSynergies:OnMoveStop()
    self.savedVars.left = AdvancedSynergiesUI:GetLeft()
    self.savedVars.top = AdvancedSynergiesUI:GetTop()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Init
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function OnAddonLoaded(event, addonName)
	if addonName ~= 'AdvancedSynergies' then return end

end
function GenericAdvancedSynergiesInitialized(control)
    EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, function(_, addonName)
	if addonName ~= addon.name then return end
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
	GenericAdvancedSynergies.default = {
		colour = { 1.0, 0.0, 0.0 },
		alpha = 1,
		lifespan = 1000,
		left = -1,
		top = -1,
		setupmode = true,
		fontsize = 40,
		shownames = false,
		debugmode = false,
		debugdata = { synergies = {} }
	}
	GenericAdvancedSynergies.defaultChar = {
		active = true,
	}
	GenericAdvancedSynergies.savedVars = ZO_SavedVars:NewAccountWide("AdvancedSynergies", addon.savedVarVersion, nil, GenericAdvancedSynergies.default)
	GenericAdvancedSynergies.savedVarsChar = ZO_SavedVars:NewCharacterIdSettings("AdvancedSynergies", addon.savedVarVersion, nil, GenericAdvancedSynergies.defaultChar)

	GENERIC_ADVANCED_SYNERGIES = GenericAdvancedSynergies:New()
    end)
end
