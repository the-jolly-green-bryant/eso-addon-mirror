--[[
  * Wykkyd [ Multi-Screen ]
  * Sponsored & Supported by: The Prydonian Elders
  * Author: Ravalox Darkshire (support@ecgroup.us)
  * Special Thanks To: Zenimax Online Studios & Bethesda for The Elder Scrolls Online
]]--

local _addon = {}
_addon._v = {}
_addon._v.major		= 2
_addon._v.monthly 	= 3
_addon._v.daily 	= 3
_addon._v.minor 	= 9
_addon.Version 	= _addon._v.major
	..".".._addon._v.monthly
	..".".._addon._v.daily
	..".".._addon._v.minor
_addon.Name			= "wykkydsMulti-Screen"
_addon.MAJOR 		= _addon.Name..".".._addon._v.major
_addon.MINOR 		= string.format(".%02d%02d%03d", _addon._v.monthly, _addon._v.daily, _addon._v.minor)
_addon.DisplayName  = "Wykkyd Multi-Screen"
_addon.SavedVariableVersion = 1
_addon.Player = "" -- will be set on load by LibWykkkydFactory
_addon.Settings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.GlobalSettings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.wykkydPreferred = nil

local baseX, baseY = nil, nil
local GuiAnchorPoint, GuiAnchorRelativePoint, GuiAnchorOffsetX, GuiAnchorOffsetY = CENTER, CENTER, 0, 0
local OriginalFunctions, OriginalUIWidth, OriginalUIHeight, OriginalUIAnchors = {}, {}, {}, {}
OriginalFunctions.ZO_InteractionManager_PopulateChatterOptions = nil
OriginalFunctions.ZO_Tooltips_SetupDynamicTooltipAnchors = nil
OriginalUIWidth["ZO_SharedThinLeftPanelBackgroundLeft"] = nil
OriginalUIWidth["ZO_SharedStatsBackgroundBG"] = nil
OriginalUIWidth["ZO_WorldMapInfoFootPrintBackgroundBG"] = nil

_addon.LoadSavedVariables = function( self )
	return
end

local validMinMax = function( key, default, min, max )
	local ret = tonumber(_addon:GetOrDefault( default, _addon.GlobalSettings[key] ))
	if ret < min then ret = min end
	if ret > max then ret = max end
	return ret
end

local AspectRatios = { -- Thanks to Tinuviel for this ;)
    1.33,   --4:3
    1.5,    --3:2 (old TV's)
    1.6,    --16:10
    1.78    --16:9
}

local GetMonitorWidth = function() -- Thanks to Tinuviel for the base this was built from
    local uiWidth = _addon:Round(baseX,0)
    local monitorHeight = _addon:Round(baseY,0)
    local monitorWidth = uiWidth / 3
    local aspectRatio = _addon:Round(monitorWidth / monitorHeight, 2)
    local correctedRatio, hasGoodRatio = 0, false

    for i, val in ipairs(AspectRatios) do
        if val == aspectRatio then hasGoodRatio = true; break; end
    end

    if (not hasGoodRatio) then
        for i, val in ipairs(AspectRatios) do
            if aspectRatio > val and val > correctedRatio then correctedRatio = val; end
        end
    else correctedRatio = aspectRatio end

    if (correctedRatio == 1.78) then correctedRatio = 1.7777777777777777777 end
    if (correctedRatio == 1.33) then correctedRatio = 1.3333333333333333333 end

    local correctedMonitorWidth = _addon:Round(correctedRatio * monitorHeight, 0)
    local bezelWidth = _addon:Round(uiWidth - (correctedMonitorWidth * 3))
    local bezelCorrection = 0

    if (bezelWidth > 0) then bezelCorrection = bezelWidth / 2 end

    return correctedMonitorWidth, bezelCorrection, bezelWidth
end

local GetAnchor = function( target, key )
	local _,a,b,c,x,y =  _G[target]:GetAnchor(key)
	return { point=a,relative=b,relativepoint=c,offsetX=x,offsetY=y }
end
local GetAnchors = function( target )
	OriginalUIAnchors[target] = {}
	if _G[target] and OriginalUIAnchors[target] then
		for key = 1, 9, 1 do
			OriginalUIAnchors[target][key] = GetAnchor( target, key )
		end
	end
end
local SetOriginalAnchors = function( target )
	if _G[target] and OriginalUIAnchors[target] then
		_G[target]:ClearAnchors()
		for key = 1, 9, 1 do
			_G[target]:SetAnchor(
				OriginalUIAnchors[target][key].point,
				OriginalUIAnchors[target][key].relative,
				OriginalUIAnchors[target][key].relativepoint,
				OriginalUIAnchors[target][key].offsetX,
				OriginalUIAnchors[target][key].offsetY
			)
		end
	end
end

local setGuiAnchors = function( assume, screensPerRow, targetScreen, targetWidth )
	if targetScreen == 1 then -- leftmost
		if assume == "top" then
			GuiAnchorPoint = TOPLEFT
			GuiAnchorRelativePoint = TOPLEFT
		elseif assume == "bottom" then
			GuiAnchorPoint = BOTTOMLEFT
			GuiAnchorRelativePoint = BOTTOMLEFT
		else -- "mid"
			GuiAnchorPoint = LEFT
			GuiAnchorRelativePoint = LEFT
		end
		return
	end
	if targetScreen == screensPerRow then -- rightmost
		if assume == "top" then
			GuiAnchorPoint = TOPRIGHT
			GuiAnchorRelativePoint = TOPRIGHT
		elseif assume == "bottom" then
			GuiAnchorPoint = BOTTOMRIGHT
			GuiAnchorRelativePoint = BOTTOMRIGHT
		else -- "mid"
			GuiAnchorPoint = RIGHT
			GuiAnchorRelativePoint = RIGHT
		end
		return
	end
	if (targetScreen == 2 and screensPerRow == 3) or (targetScreen == 3 and screensPerRow == 5) then -- center
		if assume == "top" then
			GuiAnchorPoint = TOP
			GuiAnchorRelativePoint = TOP
		elseif assume == "bottom" then
			GuiAnchorPoint = BOTTOM
			GuiAnchorRelativePoint = BOTTOM
		else -- "mid"
			GuiAnchorPoint = CENTER
			GuiAnchorRelativePoint = CENTER
		end
		return
	end
	if screensPerRow == 4 then
		if targetScreen == 2 then
			GuiAnchorOffsetX = targetWidth
			if assume == "top" then
				GuiAnchorPoint = TOPLEFT
				GuiAnchorRelativePoint = TOPLEFT
			elseif assume == "bottom" then
				GuiAnchorPoint = BOTTOMLEFT
				GuiAnchorRelativePoint = BOTTOMLEFT
			else -- "mid"
				GuiAnchorPoint = LEFT
				GuiAnchorRelativePoint = LEFT
			end
			return
		end
		if targetScreen == 3 then
			GuiAnchorOffsetX = (targetWidth*-1)
			if assume == "top" then
				GuiAnchorPoint = TOPRIGHT
				GuiAnchorRelativePoint = TOPRIGHT
			elseif assume == "bottom" then
				GuiAnchorPoint = BOTTOMRIGHT
				GuiAnchorRelativePoint = BOTTOMRIGHT
			else -- "mid"
				GuiAnchorPoint = RIGHT
				GuiAnchorRelativePoint = RIGHT
			end
			return
		end
	end
	if screensPerRow == 5 then
		if targetScreen == 2 then
			GuiAnchorOffsetX = targetWidth
			if assume == "top" then
				GuiAnchorPoint = TOPLEFT
				GuiAnchorRelativePoint = TOPLEFT
			elseif assume == "bottom" then
				GuiAnchorPoint = BOTTOMLEFT
				GuiAnchorRelativePoint = BOTTOMLEFT
			else -- "mid"
				GuiAnchorPoint = LEFT
				GuiAnchorRelativePoint = LEFT
			end
			return
		end
		if targetScreen == 4 then
			GuiAnchorOffsetX = (targetWidth*-1)
			if assume == "top" then
				GuiAnchorPoint = TOPRIGHT
				GuiAnchorRelativePoint = TOPRIGHT
			elseif assume == "bottom" then
				GuiAnchorPoint = BOTTOMRIGHT
				GuiAnchorRelativePoint = BOTTOMRIGHT
			else -- "mid"
				GuiAnchorPoint = RIGHT
				GuiAnchorRelativePoint = RIGHT
			end
			return
		end
	end
end

local hadAttemptedFix = false
local chatFixed = false

local AdjustScreen = function(eventCode, x, y)
	if not _addon:GetOrDefault( false, _addon.GlobalSettings[ "enabled" ] ) then return end
	local screensPerRow	= validMinMax("screens_per_row", 3, 1, 5)
	local rows 			= validMinMax("screen_rows", 1, 1, 3)
	local targetRow		= validMinMax("screen_target_row", 1, 1, 3)
	local targetScreen	= validMinMax("screen_target_screen", 2, 1, 5)
	local adjustBezel	= _addon:GetOrDefault( true, _addon.GlobalSettings[ "correct_bezel" ] )
	local manualBezel	= _addon:GetOrDefault( false, _addon.GlobalSettings[ "manual_bezel" ] )
	local configBezel	= validMinMax("config_bezel", 5, .1, 30)
	local attemptFix 	= _addon:GetOrDefault( true, _addon.GlobalSettings[ "attempt_fix" ] )
	local screens		= screensPerRow*rows
	if screens <= 1 then _addon:Print( "|cFF2222[MultiScreen]"..LWF4_DEFAULT_CHAT_COLOR.." Cannot support Multi-Screen on a single screen. Check your settings." ); return; end
	local offsetX, offsetY = 0, 0
	if eventCode then
		_addon:ReloadUI()
	else
		if baseX == nil then baseX = GuiRoot:GetWidth() end
		if baseY == nil then baseY = GuiRoot:GetHeight() end
	end
	local targetWidth 	= baseX / screensPerRow
	local targetHeight	= baseY / rows
	local resultWidth 	= targetWidth
	local gui = _G[ "wykkydMulti-ScreenGuiRoot" ]
	if not gui then gui = _addon.Frames.NewTopLevel( "wykkydMulti-ScreenGuiRoot" ) end
	gui:SetDimensions( baseX, baseY )
	if rows == 1 then
		setGuiAnchors( "mid", screensPerRow, targetScreen, targetWidth )
	elseif rows == 2 then
		if targetRow == 1 then setGuiAnchors( "top", screensPerRow, targetScreen, targetWidth )
		else setGuiAnchors( "bottom", screensPerRow, targetScreen, targetWidth ) end
	else -- 3
		if targetRow == 1 then setGuiAnchors( "top", screensPerRow, targetScreen, targetWidth )
		elseif targetRow == 2 then setGuiAnchors( "mid", screensPerRow, targetScreen, targetWidth )
		else setGuiAnchors( "bottom", screensPerRow, targetScreen, targetWidth ) end
	end
	GuiRoot:SetParent( gui )
	GuiRoot:ClearAnchors()
	GuiRoot:SetWidth( targetWidth )
	GuiRoot:SetAnchor( GuiAnchorPoint, gui, GuiAnchorRelativePoint, GuiAnchorOffsetX, GuiAnchorOffsetY )
	if adjustBezel then
		local correctedMonitorWidth, bezelCorrection, bezelWidth = GetMonitorWidth()
		resultWidth = correctedMonitorWidth
		if manualBezel then bezelCorrection = (configBezel/2); bezelWidth = configBezel; end
		GuiRoot:SetWidth( correctedMonitorWidth )
		local offX, offY = GuiAnchorOffsetX, GuiAnchorOffsetY
		if offX < 0 then offX = offX + ( bezelCorrection * -1 )
		elseif offX > 0 then offX = offX + bezelCorrection end
		if GuiAnchorRelativePoint == TOP or GuiAnchorRelativePoint == TOPLEFT or GuiAnchorRelativePoint == TOPRIGHT then offY = bezelCorrection end
		if GuiAnchorRelativePoint == BOTTOM or GuiAnchorRelativePoint == BOTTOMLEFT or GuiAnchorRelativePoint == BOTTOMRIGHT then offY = ( bezelCorrection * -1 ) end
		GuiRoot:ClearAnchors()
		GuiRoot:SetAnchor( GuiAnchorPoint, gui, GuiAnchorRelativePoint, offX, offY)
	end
	if attemptFix then
		if not hadAttemptedFix then
			OriginalUIWidth["ZO_SharedRightPanelBackgroundLeft"] = ZO_SharedRightPanelBackgroundLeft:GetWidth()
			OriginalUIWidth["ZO_SharedStatsBackgroundBG"] = ZO_SharedStatsBackgroundBG:GetWidth()
			OriginalUIWidth["ZO_WorldMapInfoFootPrintBackgroundBG"] = ZO_WorldMapInfoFootPrintBackgroundBG:GetWidth()
			OriginalFunctions.ZO_InteractionManager_PopulateChatterOptions = ZO_InteractionManager.PopulateChatterOptions
			OriginalFunctions.ZO_Tooltips_SetupDynamicTooltipAnchors = ZO_Tooltips_SetupDynamicTooltipAnchors
			_addon:RegisterEvent( EVENT_QUEST_OFFERED, function() ZO_InteractWindowBottomBG:SetAnchor(TOPRIGHT, GuiRoot, RIGHT, 0, 0); end, false )
			_addon:RegisterEvent( EVENT_QUEST_COMPLETE_DIALOG, function() ZO_InteractWindowBottomBG:SetAnchor(TOPRIGHT, GuiRoot, RIGHT, 0, 0); end, false )
		end
		hadAttemptedFix = true
		ZO_SharedRightPanelBackgroundLeft:SetWidth(OriginalUIWidth["ZO_SharedRightPanelBackgroundLeft"] - 385)
		ZO_SharedStatsBackgroundBG:SetWidth(OriginalUIWidth["ZO_SharedStatsBackgroundBG"] - 305)
		ZO_WorldMapInfoFootPrintBackgroundBG:SetWidth(OriginalUIWidth["ZO_WorldMapInfoFootPrintBackgroundBG"] - 600)
		ZO_SharedThinLeftPanelBackgroundRight:ClearAnchors()
		ZO_SharedThinLeftPanelBackgroundRight:SetAnchor(TOPRIGHT, ZO_SharedThinLeftPanelBackground, TOPRIGHT,165,0)
		ZO_SharedThinLeftPanelBackgroundRight:SetHeight(ZO_SharedThinLeftPanelBackground:GetHeight() - 125)
		ZO_SharedThinLeftPanelBackgroundRight:SetWidth(ZO_Character:GetWidth() + 20)
		ZO_SharedThinLeftPanelBackgroundLeft:SetHeight(ZO_SharedThinLeftPanelBackground:GetHeight() - 125)
		ZO_SharedThinLeftPanelBackgroundLeft:SetWidth(ZO_Character:GetWidth() + 20)
		ZO_InteractWindowDivider:ClearAnchors()
		ZO_InteractWindowDivider:SetAnchor(RIGHT, GuiRoot, TOPRIGHT,  0, targetHeight * .5)
		ZO_InteractWindowDivider:SetWidth(resultWidth/2)
		ZO_InteractWindowTopBG:SetAnchor(BOTTOMRIGHT, GuiRoot, RIGHT, 0, 0)
		ZO_InteractionManager.PopulateChatterOptions = function(...) OriginalFunctions.ZO_InteractionManager_PopulateChatterOptions(...); ZO_InteractWindowBottomBG:SetAnchor(TOPRIGHT, GuiRoot, RIGHT, 0, 0); end
		ZO_Tooltips_SetupDynamicTooltipAnchors = function(a, b, c, d) OriginalFunctions.ZO_Tooltips_SetupDynamicTooltipAnchors(a, b, c, d); if (b:GetType() == 7) then a:ClearAnchors(); a:SetAnchor(LEFT, b, RIGHT, 10, 0); end end
		if not chatFixed then
			chatFixed = true
			ZO_ChatWindowMinimize:SetHandler( "OnClicked", function(self, button)
				if button == 1 then CHAT_SYSTEM:ShowMinBar() end
				for xx = 1, 10, 1 do
					if _G["ZO_ChatWindowTabTemplate"..xx] then
						_G["ZO_ChatWindowTabTemplate"..xx]:SetClampedToScreen( false )
					end
				end
				ZO_ChatWindow:SetClampedToScreen( false )
				ZO_ChatWindow:ClearAnchors();
				ZO_ChatWindow:SetAnchor( RIGHT, _G["wykkydMulti-ScreenGuiRoot"], LEFT, -200, 0 );
			end )
			ZO_ChatWindowMinBarMaximize:SetHandler( "OnClicked", function(self, button)
				if button == 1 then CHAT_SYSTEM:HideMinBar() end
				for xx = 1, 10, 1 do
					if _G["ZO_ChatWindowTabTemplate"..xx] then
						_G["ZO_ChatWindowTabTemplate"..xx]:SetClampedToScreen( true )
					end
				end
				ZO_ChatWindow:SetClampedToScreen( true )
				ZO_ChatWindow:ClearAnchors();
				ZO_ChatWindow:SetAnchor( BOTTOMLEFT, GuiRoot, BOTTOMLEFT, 0, 0 );
			end )
		end
		ZO_ChatWindow:ClearAnchors();
		ZO_ChatWindow:SetAnchor( BOTTOMLEFT, GuiRoot, BOTTOMLEFT, 0, 0 );
	else
		if hadAttemptedFix then _addon:ReloadUI() end
	end
end

local eventRegistered = false
local droppedStartingEvent = false

local prepAdjustScreen = function()
	if not droppedStartingEvent then
		droppedStartingEvent = true
		EVENT_MANAGER:UnregisterForEvent( "wykkydsMulti-Screen_ActivationPrep", EVENT_PLAYER_ACTIVATED )
	end
	if _addon:GetOrDefault( false, _addon.GlobalSettings[ "enabled" ] ) then
		AdjustScreen()
		if not eventRegistered then
			_addon:RegisterEvent( EVENT_SCREEN_RESIZED, AdjustScreen )
			eventRegistered = true
		end
	else
		if eventRegistered then
			_addon:RegisterEvent( EVENT_SCREEN_RESIZED )
			_addon:ReloadUI()
		end
	end
end

_addon.LoadSettingsMenu = function( self )
	local panelData = {
		type = "panel",
		name = _addon.DisplayName,
		displayName = "|cFF2222".._addon.DisplayName.."|r",
		author = "Exodus Code Group",
		version = self.Version,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local optionsTable = {
		[1] = {
			type = "description",
			text = "Multi-Screen support requires the use of 3rd party software and/or hardware, sometimes requiring specific operating system versions or even specific video cards depending on your brand. The most common being ATI's Catalyst, should your version allow you to do so, and nVidia's Spanning configurations.",
		},
		[2] = {
			type = "description",
			text = "Once you have the game drawing across multiple screens at once this addon becomes useful to you. If you are on a single screen, or a duplicated screen across multiple monitors, then this addon will have little to no benefit to you.",
		},
		[3] = self:MakeStandardOption( self.GlobalSettings, "Enable Multi-Screen Support", "enabled", false, "checkbox", { warning="Reloads your UI when setting is turned off", default=false, } ),
		[4] = self:MakeStandardOption( self.GlobalSettings, "How many rows of monitors?", "screen_rows", 1, "slider", { min=1, max=3, step=1, default=1, } ),
		[5] = self:MakeStandardOption( self.GlobalSettings, "How many monitors per row?", "screens_per_row", 3, "slider", { min=1, max=5, step=1, default=3, } ),
		[6] = self:MakeStandardOption( self.GlobalSettings, "Which row should have your UI?", "screen_target_row", 1, "slider", { min=1, max=3, step=1, default=1, } ),
		[7] = self:MakeStandardOption( self.GlobalSettings, "Which screen on that row should?", "screen_target_screen", 2, "slider", { min=1, max=5, step=1, default=2, } ),
		[8] = self:MakeStandardOption( self.GlobalSettings, "Enable Bezel Correction", "correct_bezel", true, "checkbox", { default=true, } ),
		[9] = self:MakeStandardOption( self.GlobalSettings, "Use Manual Bezel Correction", "manual_bezel", false, "checkbox", { tooltip="This setting will only engage when Bezel Correction is also enabled",default=false, } ),
		[10] = self:MakeStandardOption( self.GlobalSettings, "Manual Bezel Size", "config_bezel", 2, "slider", { min=.1, max=30, step=.1, default=2, } ),
		[11] = self:MakeStandardOption( self.GlobalSettings, "Attempt to correct screen elements", "enabled", true, "checkbox", {
			tooltip="This should be on. However, in the off chance it doesn't work you can disable it.",
			warning="Reloads your UI when setting is turned off",
			default=true, }
		),
	}
	for xx = 3, 11, 1 do
		local func = optionsTable[xx].setFunc
		optionsTable[xx].setFunc = function( val )
			func( val )
			prepAdjustScreen()
		end
	end
	self.LAM:RegisterAddonPanel(_addon.Name.."_LAM", panelData)
	self.LAM:RegisterOptionControls(_addon.Name.."_LAM", optionsTable)
end

local addonInitialized = false
local playerActivated = false

local activatePlayerScreen = function()
	playerActivated = true
	if addonInitialized then prepAdjustScreen() end
end
local activateAddon = function()
	addonInitialized = true
	if playerActivated then prepAdjustScreen() end
end

_addon.Initialize = function( self )
	activateAddon()
end

if wykkydsMultiScreenGlobal == nil then wykkydsMultiScreenGlobal = {} end
LWF4.REGISTER_FACTORY(
	_addon, false, true,
	function( self ) _addon:LoadSavedVariables( self ) end,
	function( self ) _addon:LoadSettingsMenu( self ) end,
	function( self ) _addon:Initialize( self ) end,
	"wykkydsMultiScreenGlobal", true
)

EVENT_MANAGER:RegisterForEvent( "wykkydsMulti-Screen_ActivationPrep", EVENT_PLAYER_ACTIVATED, activatePlayerScreen )
