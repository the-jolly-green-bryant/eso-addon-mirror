--[[----------------------------------------------------------
	Coral Riptide Tracker - Tracks weapon damage increase bonus
	----------------------------------------------------------
	* 
	* @ZaiZah (PC-EU)
	*
]]--
local ADDON_NAME	 = "RiptideTracker"
local LAM2 			 = LibAddonMenu2
local RiptideTracker = {
	name 			 = ADDON_NAME,
	version 		 = "1.3",
	variableVersion	 = 1,
	author 			 = "|c00c1ffZai|r|cffffffZah|r",
	authorId 		 = "@ZaiZah",
	slashCommandName = "/rtt",
	default	= {
		renderTick 		 = 500,
		locked 			 = false,
		alwaysShow 		 = false,
		onlyShowInCombat = false,
		useAltTheme 	 = false,
		showRiptideIcon  = false,
		offsetX 		 = 645,
		offsetY 		 = 520,
		bgColor		 	 = {0/255, 0/255, 0/255, .6},
		bgBorderColor	 = {0/255, 0/255, 0/255, 1},
		barColor1 		 = {141/255, 74/255, 63/255, .5},
		barColor2 		 = {221/255, 74/255, 63/255, .8},
		barThresh 		 = 33,
		altOffsetX  	 = 645,
		altOffsetY 		 = 520,
		altThemeSize 	 = 1,
		altAlpha 		 = 1,
		altBgBorderColor = {0/255, 0/255, 0/255, 1},
		altfontColor 	 = {0/255, 210/255, 60/255, 1},
	},
}
local savedVariables = {}
local inCombat = false
local isSlotted = false
local isUsingAltTheme = false
local RIPTIDE_MAIN_FRAGMENT = {}
local RIPTIDE_ALT_FRAGMENT = {}
local coralItemLink = "|H1:item:187412:363:50:0:0:0:0:0:0:0:0:0:0:0:2048:130:0:0:0:10000:0|h|h"

local function StripText(text)
    return text:gsub("|c%x%x%x%x%x%x", "")
end
local function GetCoralBonus()
	local _, bonusDescription, _ = GetItemLinkSetBonusInfo(coralItemLink, nil, 5)
	local shrinkStr = string.sub(bonusDescription,156)
	local bonus = SplitString(" ", shrinkStr)
	return StripText(bonus)
end
local function Update()
	local CoralBonus = GetCoralBonus()
	if isUsingAltTheme then
		RiptideControlAltbonus:SetText(CoralBonus)
	else
		local current, _, effectiveMax = GetUnitPower("player", POWERTYPE_STAMINA)
		local percent = (current / effectiveMax) * 100
		if percent <= savedVariables.barThresh then
			RiptideControlpercentBar:SetColor(savedVariables.barColor2[1],savedVariables.barColor2[2],savedVariables.barColor2[3],savedVariables.barColor2[4])
		else
			RiptideControlpercentBar:SetColor(savedVariables.barColor1[1],savedVariables.barColor1[2],savedVariables.barColor1[3],savedVariables.barColor1[4])
		end
		RiptideControlpercentBar:SetMinMax(0, effectiveMax)
		RiptideControlpercentBar:SetValue(current)
		RiptideControlbonus:SetText(CoralBonus)
	end
end
local function SetCheck()
	local numNormalEquipped = 0
	local numPerfectedEquipped = 0
	_, _, _, numNormalEquipped, _, _, numPerfectedEquipped = GetItemLinkSetInfo(coralItemLink, true)
	if (numNormalEquipped + numPerfectedEquipped) >= 3 then
		isSlotted = true
	else
		isSlotted = false
	end
end
local function CombatState()
	if savedVariables.onlyShowInCombat then
		inCombat = IsUnitInCombat("player")
	else
		inCombat = true
	end
	RIPTIDE_MAIN_FRAGMENT:Refresh()
	RIPTIDE_ALT_FRAGMENT:Refresh()
end
local function SetupUI()
	local offsetX, offsetY = savedVariables.offsetX, savedVariables.offsetY
	local altOffsetX, altOffsetY = savedVariables.altOffsetX, savedVariables.altOffsetY
	local islocked = savedVariables.Locked
	RiptideControl:ClearAnchors()
	RiptideControlAlt:ClearAnchors()
	RiptideControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, offsetX, offsetY)
	RiptideControlAlt:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, altOffsetX, altOffsetY)
	RiptideControlAlt:SetMovable(islocked)
	RiptideControl:SetMovable(islocked)
	RiptideControlicon:SetHidden(not savedVariables.showRiptideIcon)
	RiptideControlbackground:SetCenterColor(unpack(savedVariables.bgColor))
	RiptideControlbackground:SetEdgeColor(unpack(savedVariables.bgBorderColor))
	RiptideControlpercentBar:SetColor(unpack(savedVariables.barColor1))
	RiptideControlAltbackground:SetEdgeColor(unpack(savedVariables.altBgBorderColor))
	RiptideControlAltbonus:SetColor(unpack(savedVariables.altfontColor))
	RiptideControlAltbackground:SetAlpha(savedVariables.altAlpha)
	RiptideControlAlt:SetScale(savedVariables.altThemeSize)
end
local function Initialize()
	isUsingAltTheme = savedVariables.useAltTheme
	RIPTIDE_MAIN_FRAGMENT = ZO_FadeSceneFragment:New(RiptideControl, nil, 0)
	RIPTIDE_MAIN_FRAGMENT:SetConditional(function()
        return (not isUsingAltTheme) and (isSlotted and inCombat)
    end)
	HUD_SCENE:AddFragment(RIPTIDE_MAIN_FRAGMENT)
	HUD_UI_SCENE:AddFragment(RIPTIDE_MAIN_FRAGMENT)
	RIPTIDE_ALT_FRAGMENT = ZO_FadeSceneFragment:New(RiptideControlAlt, nil, 0)
	RIPTIDE_ALT_FRAGMENT:SetConditional(function()
        return (isUsingAltTheme) and (isSlotted and inCombat)
    end)
	HUD_SCENE:AddFragment(RIPTIDE_ALT_FRAGMENT)
	HUD_UI_SCENE:AddFragment(RIPTIDE_ALT_FRAGMENT)
	RiptideControl:SetHandler("OnMoveStop", function()
		savedVariables.offsetX = math.floor(RiptideControl:GetLeft())
    	savedVariables.offsetY = math.floor(RiptideControl:GetTop())
    end)
	RiptideControlAlt:SetHandler("OnMoveStop", function()
		savedVariables.altOffsetX = math.floor(RiptideControlAlt:GetLeft())
    	savedVariables.altOffsetY = math.floor(RiptideControlAlt:GetTop())
    end)
	SetupUI()
	SetCheck()
	CombatState()
	RiptideTracker.CreateSettingsWindow()
end
function RiptideTracker.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = GetString(SI_RTT_SETTING_NAME_SHORT),
		displayName = GetString(SI_RTT_SETTING_NAME),
		author = RiptideTracker.author,
		version = RiptideTracker.version,
		slashCommand = RiptideTracker.slashCommandName,
		registerForRefresh = true,
		registerForDefaults = true,
		website = "https://www.esoui.com/downloads/info3663-RiptideTracker.html#info",
	}
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("Riptide_Tracker", panelData)
	local optionsData={
		[1] = {
			type = "header",
			name = ZO_HIGHLIGHT_TEXT:Colorize(GetString(SI_RTT_GENERAL_SETTINGS)),
		},
		[2] = {
			type = "description",
			text = ZO_HINT_TEXT:Colorize(GetString(SI_RTT_GENERAL_THEME_DESC)),
		},
		[3] = {
			type = "checkbox",
			name = GetString(SI_RTT_GENERAL_THEME),
			tooltip = GetString(SI_RTT_GENERAL_THEME_TOOLTIP),
			default = RiptideTracker.default.useAltTheme,
			getFunc = function() return savedVariables.useAltTheme end,
			setFunc = function(v)
				isUsingAltTheme = v
				savedVariables.useAltTheme = v
			end
		},
		[4] = {
			type = "description",
			text = ZO_HINT_TEXT:Colorize(GetString(SI_RTT_GENERAL_LOCK_DESC)),
		},
		[5] = {
			type = "checkbox",
			name = GetString(SI_RTT_GENERAL_LOCK),
			tooltip = GetString(SI_RTT_GENERAL_LOCK_TOOLTIP),
			default = RiptideTracker.default.Locked,
			getFunc = function() return savedVariables.Locked end,
			setFunc = function(v) 
				RiptideControlAlt:SetMovable(v)
				RiptideControl:SetMovable(v)
				savedVariables.Locked = v
			end,
		},
		[6] = {
			type = "button",
			name = GetString(SI_RTT_GENERAL_LOCB),
			tooltip = GetString(SI_RTT_GENERAL_LOCB_TOOLTIP),
			func = function()
				if isUsingAltTheme then
					local OffsetX, OffsetY = savedVariables.default.altOffsetX, savedVariables.default.altOffsetY
					--
					savedVariables.altOffsetX, savedVariables.altOffsetY = OffsetX, OffsetY
					RiptideControlAlt:ClearAnchors()
					RiptideControlAlt:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, OffsetX, OffsetY)
				else
					local OffsetX, OffsetY = savedVariables.default.offsetX, savedVariables.default.offsetY
					--
					savedVariables.offsetX, savedVariables.offsetY = OffsetX, OffsetY
					RiptideControl:ClearAnchors()
					RiptideControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, OffsetX, OffsetY)
				end
			end,
			width = "half",
		},
		[7] = {
			type = "description",
			text = ZO_HINT_TEXT:Colorize(GetString(SI_RTT_GENERAL_COMBAT_DESC)),
		},
		[8] = {
			type = "checkbox",
			name = GetString(SI_RTT_GENERAL_COMBAT),
			tooltip = GetString(SI_RTT_GENERAL_COMBAT_DESC),
			default = RiptideTracker.default.onlyShowInCombat,
			getFunc = function() return savedVariables.onlyShowInCombat end,
			setFunc = function(v) 
				savedVariables.onlyShowInCombat = v
				CombatState()
			end,
		},
		[9] = {
			type = "divider",
		},
		[10] = {
			type = "description",
			text = ZO_HINT_TEXT:Colorize(GetString(SI_RTT_GENERAL_TICK_DESC)),
		},
		[11] = {
			type = "slider",
			name = GetString(SI_RTT_GENERAL_TICK),
			tooltip = GetString(SI_RTT_GENERAL_TICK_TOOLTIP),
			default = RiptideTracker.default.renderTick,
			min = 200,
			max = 3000,
			step = 100,
			getFunc = function() return savedVariables.renderTick end,
			setFunc = function(v)
				savedVariables.renderTick = v
				EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. 'Update')
				EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. 'Update', v, Update)
			end,
		},
		[12] = {
			type = "divider",
		},
		[13] = {
			type = "submenu",
			name = GetString(SI_RTT_GENERAL_THEME_DEF),
			disabled = function() return savedVariables.useAltTheme end,
			controls = {
				[1] = {
					type = "checkbox",
					name = GetString(SI_RTT_GENERAL_BARC_ICON),
					tooltip = GetString(SI_RTT_GENERAL_BARC_ICONTOOLTIP),
					default = not RiptideTracker.default.showRiptideIcon,
					getFunc = function() return savedVariables.showRiptideIcon end,
					setFunc = function(v) 
						savedVariables.showRiptideIcon = v
						RiptideControlicon:SetHidden(not v)
					end,
				},
				[2] = {
					type = "description",
					text = ZO_HINT_TEXT:Colorize(GetString(SI_RTT_GENERAL_BARC_CDESC)),
				},
				[3] = {
					type = "colorpicker",
					name = GetString(SI_RTT_GENERAL_BARC_CENT),
					tooltip = GetString(SI_RTT_GENERAL_BARC_CTOOLTIP),
					default = {r = RiptideTracker.default.bgColor[1], g = RiptideTracker.default.bgColor[2], b = RiptideTracker.default.bgColor[3], a = RiptideTracker.default.bgColor[4]},
					getFunc = function() return unpack(savedVariables.bgColor) end,
					setFunc = function(r,g,b,a) 
						savedVariables.bgColor = {r, g, b, a}--.8
						RiptideControlbackground:SetCenterColor(r,  g,  b, a)
					end,
				},
				[4] = {
					type = "colorpicker",
					name = GetString(SI_RTT_GENERAL_BARC_EDGE),
					tooltip = GetString(SI_RTT_GENERAL_BARC_CTOOLTIP),
					default = {r = RiptideTracker.default.bgBorderColor[1], g = RiptideTracker.default.bgBorderColor[2], b = RiptideTracker.default.bgBorderColor[3], a = RiptideTracker.default.bgBorderColor[4]},
					getFunc = function() return unpack(savedVariables.bgBorderColor) end,
					setFunc = function(r,g,b,a) 
						savedVariables.bgBorderColor = {r, g, b, a}--.8
						RiptideControlbackground:SetEdgeColor(r,  g,  b, a)
					end,
				},
				[5] = {
					type = "description",
					text = ZO_HINT_TEXT:Colorize(GetString(SI_RTT_GENERAL_BARC_DESC)),
				},
				[6] = {
					type = "colorpicker",
					name = GetString(SI_RTT_GENERAL_BARC),
					tooltip = GetString(SI_RTT_GENERAL_BARC_TOOLTIP),
					default = {r = RiptideTracker.default.barColor1[1], g = RiptideTracker.default.barColor1[2], b = RiptideTracker.default.barColor1[3], a = RiptideTracker.default.barColor1[4]},
					getFunc = function() return unpack(savedVariables.barColor1) end,
					setFunc = function(r,g,b,a) 
						savedVariables.barColor1 = {r, g, b, a} --.5
						RiptideControlpercentBar:SetColor(r,  g,  b, a)
					end,
				},
				[7] = {
					type = "colorpicker",
					name = GetString(SI_RTT_GENERAL_BARC_HIGH),
					tooltip = GetString(SI_RTT_GENERAL_BARC_TOOLTIP),
					default = {r = RiptideTracker.default.barColor2[1], g = RiptideTracker.default.barColor2[2], b = RiptideTracker.default.barColor2[3], a = RiptideTracker.default.barColor2[4]},
					getFunc = function() return unpack(savedVariables.barColor2) end,
					setFunc = function(r,g,b,a) 
						savedVariables.barColor2 = {r, g, b, a}--.8
					end,
				},
				[8] = {
					type = "description",
					text = ZO_HINT_TEXT:Colorize(GetString(SI_RTT_GENERAL_BARC_THRESHDESC)),
				},
				[9] = {
					type = "slider",
					name = GetString(SI_RTT_GENERAL_BARC_THRESH),
					tooltip = GetString(SI_RTT_GENERAL_BARC_THRESHTOOLTIP),
					default = RiptideTracker.default.barThresh,
					min = 10,
					max = 100,
					step = 1,
					decimals = 2,
					getFunc = function() return savedVariables.barThresh end,
					setFunc = function(v) 
						savedVariables.barThresh = v
					end,
				},
			},
		},
		[14] = {
			type = "submenu",
			name = GetString(SI_RTT_GENERAL_THEME_ALT),
			disabled = function() return not savedVariables.useAltTheme end,
			controls = {
				[1] = {
					type = "slider",
					name = GetString(SI_RTT_GENERAL_ICON_SIZE),
					tooltip = GetString(SI_RTT_GENERAL_ICON_SIZETOOLTIP),
					default = RiptideTracker.default.altThemeSize,
					min = 0.2,
					max = 2.5,
					step = 0.1,
					decimals = 1,
					getFunc = function() return savedVariables.altThemeSize end,
					setFunc = function(v) 
						savedVariables.altThemeSize = v
						RiptideControlAlt:SetScale(v)
					end,
				},
				[2] = {
					type = "colorpicker",
					name = GetString(SI_RTT_GENERAL_ICON_FONTC),
					tooltip = GetString(SI_RTT_GENERAL_ICON_FONTCTOOLTIP),
					default = {r = RiptideTracker.default.altfontColor[1], g = RiptideTracker.default.altfontColor[2], b = RiptideTracker.default.altfontColor[3], a = RiptideTracker.default.altfontColor[4]},
					getFunc = function() return unpack(savedVariables.altfontColor) end,
					setFunc = function(r,g,b,a) 
						savedVariables.altfontColor = {r, g, b, a}--.8
						RiptideControlAltbonus:SetColor(r,  g,  b, a)
					end,
				},
				[3] = {
					type = "colorpicker",
					name = GetString(SI_RTT_GENERAL_ICON_EDGE),
					tooltip = GetString(SI_RTT_GENERAL_ICON_EDGETOOLTIP),
					default = {r = RiptideTracker.default.altBgBorderColor[1], g = RiptideTracker.default.altBgBorderColor[2], b = RiptideTracker.default.altBgBorderColor[3], a = RiptideTracker.default.altBgBorderColor[4]},
					getFunc = function() return unpack(savedVariables.altBgBorderColor) end,
					setFunc = function(r,g,b,a) 
						savedVariables.altBgBorderColor = {r, g, b, a}--.8
						RiptideControlAltbackground:SetEdgeColor(r,  g,  b, a)
					end,
				},
				[4] = {
					type = "slider",
					name = GetString(SI_RTT_GENERAL_ICON_ALPHA),
					tooltip = GetString(SI_RTT_GENERAL_ICON_ALPHATOOLTIP),
					default = RiptideTracker.default.altAlpha,
					min = 0.1,
					max = 1,
					step = 0.1,
					decimals = 1,
					getFunc = function() return savedVariables.altAlpha end,
					setFunc = function(v) 
						savedVariables.altAlpha = v
						RiptideControlAltbackground:SetAlpha(v)
					end,
				},
			},
		},
	}
	LAM2:RegisterOptionControls("Riptide_Tracker", optionsData)
end
local function OnAddOnLoaded(event, addonName)
    if addonName == ADDON_NAME then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. 'Initialize', EVENT_ADD_ON_LOADED)
		savedVariables = ZO_SavedVars:NewAccountWide("RiptideTrackerSV", RiptideTracker.variableVersion, nil, RiptideTracker.default)
		if (not savedVariables) then
			savedVariables = RiptideTracker.default
		end
        Initialize()
		EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. 'Update', savedVariables.renderTick, Update)
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. 'Combat', EVENT_PLAYER_COMBAT_STATE, CombatState)
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. 'Activated', EVENT_PLAYER_ACTIVATED, SetCheck)
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. 'Armory', EVENT_ARMORY_BUILD_RESTORE_RESPONSE, SetCheck)
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. 'InvUPD', EVENT_INVENTORY_SINGLE_SLOT_UPDATE, SetCheck)
		EVENT_MANAGER:AddFilterForEvent(ADDON_NAME .. 'InvUPD', EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
    end
end
EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. 'Initialize', EVENT_ADD_ON_LOADED, OnAddOnLoaded)