--[[
  * Wykkyd [ Full Immersion ]
  * Sponsored & Supported by: The Prydonian Elders
  * Author: Ravalox Darkshire (support@ecgroup.us)
  * Special Thanks To: Zenimax Online Studios & Bethesda for The Elder Scrolls Online
]]--

local _addon = {}
_addon._v = {}
_addon._v.major		= 2
_addon._v.monthly 	= 3
_addon._v.daily 	= 4
_addon._v.minor 	= 7
_addon.Version 		= _addon._v.major
	..".".._addon._v.monthly
	..".".._addon._v.daily
	..".".._addon._v.minor
_addon.Name			= "wykkydsFullImmersion"
_addon.MAJOR 		= _addon.Name..".".._addon._v.major
_addon.MINOR 		= string.format(".%02d%02d%03d", _addon._v.monthly, _addon._v.daily, _addon._v.minor)
_addon.DisplayName  = "Wykkyd Full Immersion"
_addon.SavedVariableVersion = 3
_addon.Player = "" -- will be set on load by LibWykkkydFactory
_addon.Settings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.GlobalSettings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.wykkydPreferred = {
	["reticle_size"] = 0.500000,
	["subtitles_shiftx"] = 0,
	["compassHideBackground"] = false,
	["compassHideTip"] = false,
	["compassEnabled"] = true,
	["auto_sheath"] = true,
	["compassLocked"] = false,
	["compassHLocked"] = true,
	["compassOpacity"] = 100,
	["compassWidth"] = 600,
	["use_emote_list"] = false,
	["use_reticle_size"] = true,
	["playertoplayer"] = true,
	["subtitles_enabled"] = true,
	["compassHeight"] = 8,
	["subtitles_scale"] = 72,
	["subtitles_lock"] = true,
	["offsetY"] = 49,
	["offsetX"] = 0,
	["compassTextScale"] = 85,
	["compassScale"] = 100,
	["helm_smart_hide"] = true,
	["alerttext"] = true,
	["enabled"] = true,
	["subtitles_shifty"] = -233,
	["make_like_character"] = nil,
}

local windows = {
	["ZO_Compass"] = "compass",
	["ZO_CompassFrame"] = "compass",
	["ZO_FocusedQuestTrackerPanel"] = "quest",
	["ZO_QuestTracker"] = "quest",
	["ZO_ReticleContainer"] = "reticle",
	["ZO_AlertTextNotification"] = "alerttext",
	["ZO_PlayerToPlayerAreaPromptContainerActionArea"] = "playertoplayer",
}

local reloadedOnce = false

_addon.UpdateWindowState = function()
	local on = _addon:GetOrDefault( false, _addon.Settings["enabled"] )
	if ZO_ReticleContainer:GetScale() ~= _addon:GetOrDefault( 1, _addon.Settings["reticle_size"] ) and _addon:GetOrDefault( false, _addon.Settings["use_reticle_size"] )
		then ZO_ReticleContainer:SetScale( _addon:GetOrDefault( 1, _addon.Settings["reticle_size"] ) ); end
	if on then
		reloadedOnce = false
		for w,g in pairs(windows) do
			if g == "quest" then
				if _addon:GetOrDefault( false, _addon.Settings["quest"] ) then
					if not ZO_FocusedQuestTrackerPanel:IsHidden() then ZO_FocusedQuestTrackerPanel:SetHidden( true ) end
					if _addon:GetOrDefault( false, _addon.Settings["wmqt"] ) and WYK_QuestTracker_MQT then
						if not WYK_QuestTracker_MQT:IsHidden() then WYK_QuestTracker_MQT:SetHidden( true ) end
					end
				end
			elseif string.sub(g,1,7) == "reticle" then
				if g == "reticle" then
					if _addon.Settings["reticle"] == "Hide Always" or _addon:GetOrDefault( "Smart Hide", _addon.Settings["reticle"] ) == "Smart Hide" then
						if _G[w] ~= nil then
							if not _G[w]:IsHidden() and _addon.Settings["reticle"] == "Hide Always" then
								_G[w]:SetHidden( true )
							elseif _addon:GetOrDefault( "Smart Hide", _addon.Settings["reticle"] ) == "Smart Hide" then
								local ishidden = _G[w]:IsHidden()
								local inmousemode = IsGameCameraUIModeActive()
								local stealthed = GetUnitStealthState( "player" ) ~= STEALTH_STATE_NONE
								local incombat = IsUnitInCombat( "player" )
								local combattarget = (GetUnitNameHighlightedByReticle() ~= "" and IsGameCameraUnitHighlightedAttackable())
								local interactionPossible, questInteraction, questTargetBased, questJournalIndex, questToolIndex, questToolOnCooldown = GetGameCameraInteractableInfo()
								local showit = false

								if not inmousemode then
									if stealthed and _addon:GetOrDefault( "Show", _addon.Settings["reticle_sh_stealth"]) == "Show" then showit = true end
									if incombat and _addon:GetOrDefault( "Show", _addon.Settings["reticle_sh_combat"]) == "Show" then showit = true end
									if combattarget and _addon:GetOrDefault( "Show", _addon.Settings["reticle_sh_target"]) == "Show" then showit = true end
									if interactionPossible and _addon:GetOrDefault( "Show", _addon.Settings["reticle_sh_interact"]) == "Show" then showit = true end
								end
								_G[w]:SetHidden( not showit );
							end
						end
					end
				end
			else
				if _addon.Settings[g] then
					if _G[w] ~= nil then
						if not _G[w]:IsHidden() then _G[w]:SetHidden( true ) end
					end
				end
			end
		end
	else
		if reloadedOnce then return end
		for w,g in pairs(windows) do
			if g == "quest" then
				if _addon:GetOrDefault( false, _addon.Settings["quest"] ) then
					if ZO_FocusedQuestTrackerPanel:IsHidden() then ZO_FocusedQuestTrackerPanel:SetHidden( false ) end
					if _addon:GetOrDefault( false, _addon.Settings["wmqt"] ) and WYK_QuestTracker_MQT then
						if WYK_QuestTracker_MQT:IsHidden() then WYK_QuestTracker_MQT:SetHidden( false ) end
					end
				end
			elseif g == "reticle" then
				if _addon.Settings["reticle"] == "Hide Always" or _addon.Settings["reticle"] == "Smart Hide" then
					if _G[w] ~= nil then
						if _G[w]:GetScale() ~= 1 then _G[w]:SetScale(1); end
						if _G[w]:IsHidden() then _G[w]:SetHidden( false ) end
					end
				end
			else
				if _addon.Settings[g] then
					local leaveOff = false
					if WYKKYD_G ~= nil then
						if WYKKYD_G["FramesToLeaveOff"] ~= nil then
							if WYKKYD_G["FramesToLeaveOff"][w] ~= nil then
								leaveOff = true
							end
						end
					end
					if _G[w] ~= nil and not leaveOff then
						if _G[w]:IsHidden() then _G[w]:SetHidden( false ) end
					end
				end
			end
		end
		reloadedOnce = true
	end
end

local _L = {}
local loadListEmotes = function()
	_addon:LoadEmotes()
	_L = {}
	_L["ALL"] 		= {}
	_L["ENABLED"]  = {}
	_L["DDL"]  	= {}
	_L["DDV"]  	= {}
	_L["DDLKP"]  	= {}
	_L["DDV"]["  "] = -1
	table.insert(_L["ALL"], "  ")
	table.insert(_L["DDL"], "  ")
	for n,tbl in ipairs(_addon.GLOBAL.emotesSorted) do
		table.insert(_L["ALL"], tbl.name)
		table.insert(_L["DDL"], tbl.name)
		_L["ENABLED"][tbl.code] = true
		_L["DDV"][tbl.name] = tbl.code
		_L["DDLKP"][tbl.code] = tbl.name
	end
end

_addon.Subtitles = {}
_addon.AutoSheath = {}
_addon.HandleCompass = function() end
_addon.HandleCombatStateChange = function( params )
	if _addon:GetOrDefault( false, _addon.Settings["helm_smart_hide"] ) then
		if params.inCombat then _addon.showHelm()
		else _addon.hideHelm() end
	end
	if _addon:GetOrDefault( false, _addon.Settings["auto_sheath"] ) then
		if params.inCombat then _addon.AutoSheath.ShouldBeWielding() end
	end
end

_addon.LoadSavedVariables = function( self )
	return
end

_addon.LoadSettingsMenu = function( self )
	local panelData = {
		type = "panel",
		name = "Wykkyd Full Immersion",
		displayName = "|cFF2222Wykkyd Full Immersion|r",
		author = "Exodus Code Group",
		version = self.Version,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local optionsTable = {
		[1] = { type = "description", text = "Adds many nice features for showing/hiding or enhancing the default user interface elements.", },
		[2] = self:MakeStandardOption( self.Settings, "Don my helm in times of war", "helm_smart_hide", false, "checkbox", { tooltip = "Shows helm during combat, hides it out of combat", default=false, } ),
		[3] = self:MakeStandardOption( self.Settings, "Sheath my weapon in times of peace", "auto_sheath", false, "checkbox", { tooltip = "Attempts to sheath your weapon out of combat", default=false, } ),
		[4] = self:MakeStandardOption( self.Settings, "Enable Reticle Scale", "use_reticle_size", false, "checkbox", { tooltip = "Enables the resizing of your targetting reticle", width="half", default=false, } ),
		[5] = self:MakeStandardOption( self.Settings, "Scale %", "reticle_size", 100, "slider", { tooltip = "Sets the new size of the targetting reticle, when enabled", min=50, max=120, step=1, default=100, width="half", } ),
		[6] = self:MakeStandardOption( self.Settings, "Enable all 'Hideables' |c656565(keybindable)|r", "enabled", false, "checkbox", { tooltip = "Master on/off switch for all Hideables options in the list below", default=false, } ),
		[7] = {
			type = "submenu",
			name = "|cCAB222Full Immersion 'Hideables'|r",
			tooltip = "Special configurations to hide or alter the display of existing in-game windows",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Hide Compass", "compass", false, "checkbox", { default=false, } ),
				[2] = self:MakeStandardOption( self.Settings, "Hide Quest Tracker", "quest", false, "checkbox", { default=false, } ),
				[3] = self:MakeStandardOption( self.Settings, " ... include Wykkyd's MQT", "wmqt", false, "checkbox", { default=false, } ),
				[4] = self:MakeStandardOption( self.Settings, "Hide Alert Window", "alerttext", false, "checkbox", { default=false, } ),
				[5] = self:MakeStandardOption( self.Settings, "Hide 'Hold to Interact' Window", "playertoplayer", false, "checkbox", { default=false, } ),
				[6] = self:MakeStandardOption( self.Settings, "Reticle Control State", "reticle", "Smart Hide", "dropdown", { choices={ "Show", "Hide Always", "Smart Hide" }, default="Smart Hide", } ),
				[7] = self:MakeStandardOption( self.Settings, " ... In Combat", "reticle_sh_combat", "Show", "dropdown", { choices={ "Show", "Hide" }, default="Show", } ),
				[8] = self:MakeStandardOption( self.Settings, " ... Stealthed", "reticle_sh_stealth", "Show", "dropdown", { choices={ "Show", "Hide" }, default="Show", } ),
				[9] = self:MakeStandardOption( self.Settings, " ... Targetting", "reticle_sh_target", "Show", "dropdown", { choices={ "Show", "Hide" }, default="Show", } ),
				[10] = self:MakeStandardOption( self.Settings, " ... Interactable", "reticle_sh_interact", "Show", "dropdown", { choices={ "Show", "Hide" }, default="Show", } ),
			},
		},
		[8] = self:MakeStandardOption( self.Settings, "Enable Subtitles", "subtitles_enabled", false, "checkbox", { tooltip = "Master on/off switch for all Subtitles options in the list below", default=false, } ),
		[9] = {
			type = "submenu",
			name = "|cCAB222Subtitle Options|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Lock Subtitles In Place (hide's bg)", "subtitles_lock", false, "checkbox", { tooltip = "Hides the background and locks the frame in place when enabled.", default=false, } ),
				[2] = self:MakeStandardOption( self.Settings, "Lock Horizontally Center", "subtitles_lockhc", true, "checkbox", { tooltip = "Keeps the frame centered horizontally on screen.", default=true, } ),
				[3] = self:MakeStandardOption( self.Settings, "Text Scale %", "subtitles_scale", 100, "slider", { tooltip = "Scales the text of the Subtitle screen by %", min=50, max=150, step=1, default=100, } ),
				[4] = self:MakeStandardOption( self.Settings, "Fade Time", "subtitles_fade", 8, "slider", { tooltip = "Sets how many seconds it will take for the Subtitle content to fade off screen", min=5, max=20, step=1, default=8, } ),
				[5] = self:MakeStandardOption( self.Settings, "Align in Which Direction?", "subtitles_align", "CENTER", "dropdown", { choices={ "LEFT", "CENTER", "RIGHT" }, default="CENTER", } ),
			},
		},
		[10] = {
			type = "submenu",
			name = "|cCAB222Compass Options|r",
			controls = {
				[1] = self:MakeStandardOption( self.Settings, "Enable compass tweaks", "compassEnabled", false, "checkbox", { default=false, } ),
				[2] = self:MakeStandardOption( self.Settings, "Compass locked in place", "compassLocked", true, "checkbox", { default=true, } ),
				[3] = self:MakeStandardOption( self.Settings, "Compass locked horizontal", "compassHLocked", true, "checkbox", { default=true, } ),
				[4] = self:MakeStandardOption( self.Settings, "Hide Tip/Legend text above compass", "compassHideTip", false, "checkbox", { default=false, } ),
				[5] = self:MakeStandardOption( self.Settings, "Hide compass background", "compassHideBackground", false, "checkbox", { default=false, } ),
				[6] = self:MakeStandardOption( self.Settings, "Compass Tip/icon Scale", "compassScale", 100, "slider", { min=25, max=125, step=1, default=100, } ),
				[7] = self:MakeStandardOption( self.Settings, "Compass Height", "compassHeight", 12, "slider", { min=1, max=60, step=1, default=12, } ),
				[8] = self:MakeStandardOption( self.Settings, "Compass Width", "compassWidth", 500, "slider", { min=100, max=1000, step=5, default=500, } ),
				[9] = self:MakeStandardOption( self.Settings, "Tip/Legend text scale", "compassTextScale", 100, "slider", { min=50, max=150, step=1, default=100, } ),
				[10] = self:MakeStandardOption( self.Settings, "Compass icon/text opacity", "compassOpacity", 100, "slider", { min=0, max=100, step=1, default=100, } ),
			},
		},
		[11] = self:MakeStandardOption( self.Settings, "Place EMOTE list onto Chat Window", "use_emote_list", true, "checkbox", { warning="Reloads your UI when changed.", default=true, } ),
	}
	optionsTable[5].getFunc = function() return self:GetOrDefault( 1, self.Settings["reticle_size"] ) * 100 end
	optionsTable[5].setFunc = function( val ) self.Settings["reticle_size"] = (val / 100) end
	optionsTable[8].setFunc = function( val )
		self.Settings["subtitles_enabled"] = val
		if val then
			if wykkydsSubtitles:IsHidden() then
				wykkydsSubtitles:SetHidden(false);
				wykkydsSubtitles:SetMouseEnabled( self:GetOrDefault( true, self.Settings[ "subtitles_moveable" ] ) )
				wykkydsSubtitles:SetMovable( self:GetOrDefault( true, self.Settings[ "subtitles_moveable" ] ) )
				wykkydsSubtitles.bg:SetHidden( not self:GetOrDefault( true, self.Settings[ "subtitles_moveable" ] ) )
			end
		else
			if not wykkydsSubtitles:IsHidden() then
				wykkydsSubtitles:SetHidden( true );
			end
		end
	end
	optionsTable[9].controls[1].setFunc = function( val )
		self.Settings[ "subtitles_lock" ] = val
		local o = _G[ "wykkydsSubtitles" ]
		if o ~= nil then
			o:SetMouseEnabled( not val )
			o:SetMovable( not val )
			o.bg:SetHidden( val )
		end
	end
	optionsTable[9].controls[2].setFunc = function( val )
		self.Settings[ "subtitles_lockhc" ] = val
		wykkydsSubtitles:SetFrameCoords()
	end
	optionsTable[9].controls[3].setFunc = function( val )
		self.Settings[ "subtitles_scale" ] = val
		local o = _G["wykkydsSubtitles"]
		if o ~= nil then
			o.Label:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 18 * (self:GetOrDefault( 100, self.Settings["subtitles_scale"] ) / 100), "soft-shadow-thick"))
			o:SetDimensions(1000, ((18 * (_addon:GetOrDefault( 100, _addon.Settings["subtitles_scale"] ) / 100)) + 2) * 3 )
			o.Label:SetDimensions(1000, ((18 * (_addon:GetOrDefault( 100, _addon.Settings["subtitles_scale"] ) / 100)) + 2) * 3 )
		end
	end
	optionsTable[9].controls[5].setFunc = function( val )
		self.Settings[ "subtitles_align" ] = val
		local o = _G[ "wykkydsSubtitles" ]
		if o ~= nil then
			o.Label:SetHorizontalAlignment(
				self.GLOBAL.TextAlign[ "h" ][ string.lower( self.Settings[ "subtitles_align" ] or "CENTER" ) ]
			)
		end
	end
	for ii = 1, 10, 1 do
		local sFunc = optionsTable[10].controls[ii].setFunc
		optionsTable[10].controls[ii].setFunc = function( val )
			sFunc( val )
			_addon.HandleCompass()
		end
	end
	optionsTable[11].setFunc = function( val )
		self.Settings["use_emote_list"] = val
		self:ReloadUI()
	end

	optionsTable = self:InjectAdvancedSettings( optionsTable, 1 )
	self.LAM:RegisterAddonPanel( _addon.Name.."_LAM", panelData )
	self.LAM:RegisterOptionControls( _addon.Name.."_LAM", optionsTable )
end

_addon.CreateEmoteFrame = function()
	loadListEmotes()
	local ddl = _addon.Frames.StandardDDL:Create( "WFIEmoteDDL", ZO_ChatWindow, _L["DDL"], "Emotes", true, function( val )
		if val ~= "  " and val ~= nil then
			local emoteCode = _L["DDV"][ val ]
			if emoteCode ~= nil then PlayEmoteByIndex( emoteCode ) end
		end
	end, true )
	ddl:ClearAnchors()
	ddl:SetAnchor( RIGHT, ZO_ChatWindowOptions, LEFT, -6, 1 )
end

_addon.Initialize = function( self )
	self:OnUpdateCallback( "_addonWindowTic", self.UpdateWindowState )

	if self:GetOrDefault( true, self.Settings["use_emote_list"] ) then _addon.CreateEmoteFrame() end

	self:RegisterEvent( EVENT_PLAYER_COMBAT_STATE, self.HandleCombatStateChange, true )

	if self:GetOrDefault( false, self.Settings["auto_sheath"] ) then
		self.AutoSheath.Enable()
	end

	self.Subtitles.Draw()
	self:OnUpdateCallback( "_addonSubtitleTic", _addon.Subtitles.Update )

	self.HandleCompass()
	self:OnUpdateCallback( "compass_hook", self.HandleCompass )
end

if wykkydsFullImmersionGlobal == nil then wykkydsFullImmersionGlobal = {} end
LWF4.REGISTER_FACTORY(
	_addon, false, true,
	function( self ) self:LoadSavedVariables() end,
	function( self ) self:LoadSettingsMenu() end,
	function( self ) self:Initialize() end,
	"wykkydsFullImmersionGlobal", true
)

_addon.KeyboundControl = function()
	if IsGameCameraUIModeActive() then return end
	if _addon.Settings["enabled"] then
		_addon.Settings["enabled"] = false
		--self:ReloadUI()
	else _addon.Settings["enabled"] = true end
end

WYK_FullImmersion = _addon
