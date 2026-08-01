local L = GetString
local SF = LibSFUtils
local LAM = LibAddonMenu2


TTFAS_Settings = ZO_Object:Subclass()
local curprof
local newprofname
local newprof
local oldprofname
local fromprofname


local function UpdateChoices(controlname, data)
	local dropdownCtrl = WINDOW_MANAGER:GetControlByName(controlname)
    if dropdownCtrl == nil then
        return
    end
	dropdownCtrl:UpdateChoices(data.choices, data.choicesValues, 
		data.choicesTooltips)  
end

local function UpdateValue(controlname, text)
	local descCtrl = WINDOW_MANAGER:GetControlByName(controlname)
	if descCtrl == nil then return end
	if type(text) == "number" then text = GetString(text) end
	descCtrl.desc:SetText(text)
	--after setting this value, let's refresh the others to see if any should be disabled or have their settings changed
	LAM.util.RequestRefreshIfNeeded(descCtrl)
end	

function TTFAS_Settings:New( ... )
    local result = ZO_Object.New( self )
    TTFAS_Settings.InitSettingsUI( ... )
    return result
end

-- defining frequently used dropdown choices
local defaultChoices, defaultChoicesValues = FASFV:choicesNvalues(
		FAS_NEVER, FAS_ALWAYS, FAS_MIN_QUALITY, FAS_MIN_VALUE)

local dTTCChoices, dTTCChoicesValues = FASFV:choicesNvalues(
		FAS_NEVER, FAS_ALWAYS, FAS_MIN_QUALITY, FAS_MIN_VALUE, FAS_TTC_MIN_VALUE)

local valChoices, valChoicesValues = FASFV:choicesNvalues(
		FAS_NEVER, FAS_ALWAYS, FAS_MIN_VALUE)
local booleanChoices, booleanChoicesValues = FASFV:choicesNvalues(
		FAS_NEVER, FAS_ALWAYS)

local qualityChoices = {
	SF.ColorText("mythic", SF.hex.mythic),
	SF.ColorText("legendary", SF.hex.legendary),
	SF.ColorText("epic", SF.hex.epic),
	SF.ColorText("superior", SF.hex.superior),
	SF.ColorText("fine", SF.hex.fine),
	SF.ColorText("normal", SF.hex.normal),
	SF.ColorText("junk", SF.hex.junk),
}
local qualityChoicesValues = {
	ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE,
	ITEM_DISPLAY_QUALITY_LEGENDARY,
	ITEM_DISPLAY_QUALITY_ARTIFACT,
	ITEM_DISPLAY_QUALITY_ARCANE,
	ITEM_DISPLAY_QUALITY_MAGIC,
	ITEM_DISPLAY_QUALITY_NORMAL,
	ITEM_DISPLAY_QUALITY_TRASH,
}

local stolenContainerChoices, stolenContainerChoicesValues = FASFV:choicesNvalues(
		FAS_TAKE_ALL, FAS_JUST_OPEN, FAS_FOLLOW)

local setChoices
local setChoicesValues
if TamrielTradeCentre then
	setChoices, setChoicesValues = FASFV:choicesNvalues(
		FAS_NEVER, FAS_ALWAYS, FAS_UNCOLLECTED, FAS_COLLECTED, FAS_TTC_MIN_VALUE)
else
	setChoices, setChoicesValues = FASFV:choicesNvalues(
		FAS_NEVER, FAS_ALWAYS, FAS_UNCOLLECTED, FAS_COLLECTED)
end
local intricateChoices, intricateChoicesValues = FASFV:choicesNvalues(
		FAS_NEVER, FAS_ALWAYS, FAS_TYPE_BASED)

local treasureMapsChoices, treasureMapsChoicesValues = FASFV:choicesNvalues(
		FAS_NEVER, FAS_ALWAYS, FAS_NON_BASE_ZONE)

local treasuresChoices, treasuresChoicesValues = FASFV:choicesNvalues(
		FAS_NEVER, FAS_ALWAYS, FAS_MIN_QUALITY)

local styleMaterialsChoices, styleMaterialsChoicesValues = FASFV:choicesNvalues(
		FAS_NEVER, FAS_ALWAYS, FAS_NON_RACIAL)

local soulGemsChoices, soulGemsChoicesValues = FASFV:choicesNvalues(
		FAS_NEVER, FAS_ALWAYS, FAS_FILLED, FAS_UNFILLED)

local potionsChoices, potionsChoicesValues = FASFV:choicesNvalues(
		FAS_NEVER, FAS_ALWAYS, FAS_NORMAL_POTIONS, FAS_POTENT_POTIONS)

local function defaultTTC() 
	if TTFAS.TTC_addon then 
		return dTTCChoices 
	end
	return defaultChoices 
end

local function defaultTTCVals() 
	if TTFAS.TTC_addon then 
		return dTTCChoicesValues 
	end
	return defaultChoicesValues 
end

-- functions to conditionally create/populate controls based
-- on if UT or TTC are available
local function recipeCtl(saved)
	local function getval()
		if not TTFAS.UT_addon 
		and curprof.papers.recipes == FASFV:val(FAS_UNKNOWN_BY_ANY) then
			return FASFV:val(FAS_UNKNOWN)
		end
		return curprof.papers.recipes 
	end
	
	local ctl = {
					type = "dropdown",
					name = TTFAS_RECIPES,
					getFunc = getval,
					setFunc = function(value) curprof.papers.recipes = value end,
					default = FASFV:val(FAS_UNKNOWN),
				}
	if TTFAS.UT_addon then
		ctl.choices, ctl.choicesValues = FASFV:choicesNvalues(FAS_NEVER, FAS_ALWAYS, FAS_UNKNOWN, FAS_UNKNOWN_BY_ANY)
		
	else
		ctl.choices, ctl.choicesValues = FASFV:choicesNvalues(FAS_NEVER, FAS_ALWAYS, FAS_UNKNOWN)
	end
	return ctl
end

local function motifsCtl(saved)
	local function getval()
		if not TTFAS.UT_addon and curprof.papers.motifs == FASFV:val(FAS_UNKNOWN_BY_ANY) then
			return FASFV:val(FAS_UNKNOWN)
		end
		return curprof.papers.motifs 
	end
	local ctl = {
					type = "dropdown",
					name = TTFAS_MOTIFS,
					getFunc = getval,
					setFunc = function(value) curprof.papers.motifs = value end,
					default = FASFV:val(FAS_UNKNOWN),
				}
	if TTFAS.UT_addon then
		ctl.choices = FASFV:choices(FAS_NEVER, FAS_ALWAYS, FAS_UNKNOWN, FAS_UNKNOWN_BY_ANY)
		ctl.choicesValues = FASFV:choiceValues(FAS_NEVER, FAS_ALWAYS, FAS_UNKNOWN, FAS_UNKNOWN_BY_ANY)
		
	else
		ctl.choices = FASFV:choices(FAS_NEVER, FAS_ALWAYS, FAS_UNKNOWN)
		ctl.choicesValues = FASFV:choiceValues(FAS_NEVER, FAS_ALWAYS, FAS_UNKNOWN)
	end
	return ctl
end

local function stylesCtl(saved)
	local function getval()
		if not TTFAS.UT_addon and curprof.papers.stylepages == FASFV:val(FAS_UNKNOWN_BY_ANY) then
			return FASFV:val(FAS_UNKNOWN)
		end
		return curprof.papers.stylepages 
	end
	local ctl = {
					type = "dropdown",
					name = TTFAS_STYLE_PAGES,
					getFunc = getval,
					setFunc = function(value) curprof.papers.stylepages = value end,
					default = "only unknown",
				}
	if TTFAS.UT_addon then
		ctl.choices = FASFV:choices(FAS_NEVER, FAS_ALWAYS, FAS_UNKNOWN, FAS_UNKNOWN_BY_ANY)
		ctl.choicesValues = FASFV:choiceValues(FAS_NEVER, FAS_ALWAYS, FAS_UNKNOWN, FAS_UNKNOWN_BY_ANY)
		
	else
		ctl.choices = FASFV:choices(FAS_NEVER, FAS_ALWAYS, FAS_UNKNOWN)
		ctl.choicesValues = FASFV:choiceValues(FAS_NEVER, FAS_ALWAYS, FAS_UNKNOWN)
	end
	return ctl
end

local function TTCpriceCtl(saved)
	if not TTFAS.TTC_addon then return nil end
	return {
				type = "slider",
				name = TTFAS_TTCVALUE_THRESHOLD,
				tooltip = TTFAS_TTCVALUE_THRESHOLD_TT,
				min = 0,
				max = 10000,
				getFunc = function() return curprof.gear.minTTCValue end,
				setFunc = function(value) curprof.gear.minTTCValue = value end,
				default = 0,
			}
end

local function paperTTCpriceCtl(saved)
	if not TamrielTradeCentre then return nil end
	return {
				type = "slider",
				name = TTFAS_TTCVALUE_THRESHOLD,
				tooltip = TTFAS_TTCVALUE_THRESHOLD_TT,
				min = 0,
				max = 10000,
				getFunc = function() return curprof.papers.minTTCValue end,
				setFunc = function(value) curprof.papers.minTTCValue = value end,
				default = 0,
			}
end

local function divider()
	return {
		type = "divider",
		width = "full", --or "half" (optional)
		height = 10,
		alpha = 0.5,
	}
end

-- other useful functions
local function updateProfileDDs()
	UpdateChoices("TTFAS_CTL_CURRPROF", { choices=TTFAS.getProfileNames(),})
	UpdateChoices("TTFAS_CTL_FROMPROF", { choices=TTFAS.getCopyableProfileNames(),})
	UpdateChoices("TTFAS_CTL_DELPROF", { choices=TTFAS.getUserProfileNames(),})
end

local function saveProfile(name, from)
	if name then
		TTFASLogger():Info("Creating profile for "..name)
		TTFAS.createProfile(name, from)
		updateProfileDDs()
	end
end

-- Gear Filters
-- This works better than the old just return nil for controls I don't want
-- because this function does not return nil, thereby avoided the erroneous
-- LAM2 warning about not creating options (caused by the nil controls)
local function gearSetting()
	local secopts = {
			type = "submenu",
			name = SF.ColorText(TTFAS_GEAR_FILTERS, SF.hex.goldenrod),
			controls = {}
		}
	local ctls = secopts.controls
	table.insert(ctls, {
					type = "dropdown",
					name = TTFAS_QUALITY_THRESHOLD,
					choices = qualityChoices,
					choicesValues = qualityChoicesValues,
					getFunc = function() return curprof.gear.minQuality end,
					setFunc = function(value) curprof.gear.minQuality = value end,
					default = ITEM_DISPLAY_QUALITY_NORMAL,
				})
	table.insert(ctls, {
					type = "slider",
					name = TTFAS_VALUE_THRESHOLD,
					tooltip = TTFAS_VALUE_THRESHOLD_TT,
					min = 0,
					max = 1000,
					getFunc = function() return curprof.gear.minValue end,
					setFunc = function(value) curprof.gear.minValue = value end,
					default = 0,
				})
	local ttcsec = TTCpriceCtl(saved)
	if ttcsec then
		table.insert(ctls, ttcsec)
	end
	table.insert(ctls, divider())
	table.insert(ctls, {
					type = "dropdown",
					name = TTFAS_SET_ITEMS,
					choices = setChoices,
					choicesValues = setChoicesValues,
					getFunc = function() return curprof.gear.set end,
					setFunc = function(value) curprof.gear.set = value end,
					default = FASFV:val(FAS_ALWAYS), --"always loot",
				})
	table.insert(ctls, divider())
	table.insert(ctls, {
					type = "dropdown",
					name = TTFAS_COMP_QUALITY_THRESHOLD,
					tooltip = TTFAS_COMP_QUALITY_THRESHOLD_TT,
					choices = qualityChoices,
					choicesValues = qualityChoicesValues,
					getFunc = function() return curprof.gear.minCompQuality end,
					setFunc = function(value) curprof.gear.minCompQuality = value end,
					default = ITEM_DISPLAY_QUALITY_NORMAL,
				})
	table.insert(ctls, {
					type = "dropdown",
					name = TTFAS_COMPANION_GEARS,
					choices = FASFV:choices(FAS_NEVER, FAS_ALWAYS, FAS_MIN_QUALITY),
					choicesValues = FASFV:choiceValues(FAS_NEVER, FAS_ALWAYS, FAS_MIN_QUALITY),
					getFunc = function() return curprof.gear.companionGears end,
					setFunc = function(value) curprof.gear.companionGears = value end,
					default = FASFV:val(FAS_ALWAYS),
				})
	table.insert(ctls, divider())
	table.insert(ctls, {
					type = "dropdown",
					name = TTFAS_UNRESEARCHED_ITEMS,
					choices = booleanChoices,
					choicesValues = booleanChoicesValues,
					getFunc = function() return curprof.gear.unresearched end,
					setFunc = function(value) curprof.gear.unresearched = value end,
					default = FASFV:val(FAS_NEVER),
				})
	table.insert(ctls, {
					type = "dropdown",
					name = TTFAS_ORNATE_ITEMS,
					choices = valChoices,
					choicesValues = valChoicesValues,
					getFunc = function() return curprof.gear.ornate end,
					setFunc = function(value) curprof.gear.ornate = value end,
					default = FASFV:val(FAS_ALWAYS),
				})
	table.insert(ctls, {
					type = "dropdown",
					name = TTFAS_INTRICATE_ITEMS,
					choices = intricateChoices,
					choicesValues = intricateChoicesValues,
					getFunc = function() return curprof.gear.intricate end,
					setFunc = function(value) curprof.gear.intricate = value end,
					default = FASFV:val(FAS_NEVER),
				})
	table.insert(ctls, {
					type = "dropdown",
					name = TTFAS_CLOTHING_INTRICATE_ITEMS,
					choices = booleanChoices,
					choicesValues = booleanChoicesValues,
					getFunc = function() return curprof.gear.clothIntricate end,
					setFunc = function(value) curprof.gear.clothIntricate = value end,
					default = FASFV:val(FAS_NEVER),
					disabled = function() return curprof.gear.intricate ~= FASFV:val(FAS_TYPE_BASED) end,
				})
	table.insert(ctls, {
					type = "dropdown",
					name = TTFAS_BLACKSMITHING_INTRICATE_ITEMS,
					choices = booleanChoices,
					choicesValues = booleanChoicesValues,
					getFunc = function() return curprof.gear.metalIntricate end,
					setFunc = function(value) curprof.gear.metalIntricate = value end,
					default = FASFV:val(FAS_NEVER),
					disabled = function() return curprof.gear.intricate ~= FASFV:val(FAS_TYPE_BASED) end,
				})
	table.insert(ctls, {
					type = "dropdown",
					name = TTFAS_WOODWORKING_INTRICATE_ITEMS,
					choices = booleanChoices,
					choicesValues = booleanChoicesValues,
					getFunc = function() return curprof.gear.woodIntricate end,
					setFunc = function(value) curprof.gear.woodIntricate = value end,
					default = FASFV:val(FAS_NEVER),
					disabled = function() return curprof.gear.intricate ~= FASFV:val(FAS_TYPE_BASED) end,
				})
	table.insert(ctls, {
					type = "dropdown",
					name = TTFAS_JEWELRY_INTRICATE_ITEMS,
					choices = booleanChoices,
					choicesValues = booleanChoicesValues,
					getFunc = function() return curprof.gear.jewelIntricate end,
					setFunc = function(value) curprof.gear.jewelIntricate = value end,
					default = FASFV:val(FAS_NEVER),
					disabled = function() return curprof.gear.intricate ~= FASFV:val(FAS_TYPE_BASED) end,
				})
	table.insert(ctls, divider())
	table.insert(ctls, {
					type = "dropdown",
					name = TTFAS_WEAPONS,
					choices = defaultTTC(),
					choicesValues = defaultTTCVals(),
					getFunc = function() 
						if not TamrielTradeCentre and curprof.gear.weapons == FASFV:val(FAS_TTC_MIN_VALUE) then
							return FASFV:val(FAS_MIN_VALUE)
						end
						return curprof.gear.weapons 
					end,
					setFunc = function(value)
						curprof.gear.weapons = value 
					end,
					default = FASFV:val(FAS_NEVER),
				})
	table.insert(ctls, {
					type = "dropdown",
					name = TTFAS_ARMORS,
					choices = defaultTTC(),
					choicesValues = defaultTTCVals(),
					getFunc = function() 
						if not TTFAS.TTC_addon and curprof.gear.armors == FASFV:val(FAS_TTC_MIN_VALUE) then
							return FASFV:val(FAS_MIN_VALUE)
						end
						return curprof.gear.armors 
					end,
					setFunc = function(value) 
						--d("new armors - "..value)
						curprof.gear.armors = value 
					end,
					default = FASFV:val(FAS_NEVER),
				})
	table.insert(ctls, {
					type = "dropdown",
					name = TTFAS_JEWELRY,
					choices = defaultTTC(),
					choicesValues = defaultTTCVals(),
					getFunc = function() return curprof.gear.jewelry end,
					setFunc = function(value) 
						curprof.gear.jewelry = value 
					end,
					default = FASFV:val(FAS_ALWAYS),
				})
	return secopts
end

function TTFAS_Settings.InitSettingsUI( saved, curprof1 )
	TTFASLogger():Debug("running InitSettingsUI")
	curprof = curprof1
	local panelData = 
	{
		type = "panel",
		name = L(TTFAS_PANEL_NAME),
		displayName = L(TTFAS_PANEL_DISPLAYNAME),
		author = TTFAS.author,
		version = TTFAS.version,
		slashCommand = "/ttfas",
		registerForRefresh = true,
	}

	local function checkTTCPriceCtl(saved)
		if not TTFAS.TTC_addon then return end

		TTFASLogger():Debug("have TTC, creating TTCPriceCtl")
		return  {
					type = "dropdown",
					name = TTFAS_TTC_MIN,
					tooltip = TTFAS_PAPER_TTC_MIN_DESC,
					choices = booleanChoices,
					choicesValues = booleanChoicesValues,
					getFunc = function() return curprof.papers.paperTTC end,
					setFunc = function(value) curprof.papers.paperTTC = value end,
					default = FASFV:val(FAS_NEVER),
				}
	end
	
	local function integTT(ctltbl)
		if not ThiefTools then return end
		local TT_options = {
			{
				type = "header",
				name = SF.ColorText(TTFAS_TT_ADDON, SF.hex.superior),
			},
			{
				type = "description",
				text = SF.ColorText(TTFAS_TT_DESC, SF.hex.frangipani),
			},
			{
				type = "description",
				text = SF.ColorText(TTFAS_TT_DESC2, SF.hex.frangipani),
			},
			{
				type = "description",
				text = SF.ColorText(TTFAS_TT_DESC3, SF.hex.frangipani),
			},
		}
		TTFASLogger():Debug("Have TT, adding TT Section")
		
		for _, v in ipairs(TT_options) do
			table.insert(ctltbl, v)
		end
	end

	local function integUT(ctltbl)
		if not UnknownTracker then return end
		local UT_options = {
			{
				type = "header",
				name = SF.ColorText("Unknown Tracker", SF.hex.superior),
			},
			{
				type = "description",
				text = SF.ColorText(TTFAS_UT_ADDON_DESC, SF.hex.frangipani),
			},
			{
				type = "description",
				text = SF.ColorText(TTFAS_UT_ADDON_SETTINGS, SF.hex.frangipani),
			},
		}
		TTFASLogger():Debug("Have UT, adding UT Section")
		
		for _, v in ipairs(UT_options) do
			table.insert(ctltbl, v)
		end
	end
	
	local function integTTC(ctltbl)
		local TTC_options = {
			{
				type = "header",
				name = SF.ColorText("Tamriel Trade Centre", SF.hex.superior),
			},
			{
				type = "description",
				text = SF.ColorText(TTFAS_TTC_ADDON_DESC, SF.hex.mocassin),
			},
			{
				type = "dropdown",
				name = TTFAS_TTCPRICE_BASE,
				choices = {L(TTFAS_PP_SUGGESTED),L(TTFAS_PP_AVERAGE)},
				getFunc = function() return curprof.TTC_baseprice end,
				setFunc = function(value) curprof.TTC_baseprice = value end,
				default = L(TTFAS_PP_SUGGESTED),
				disabled = not TTFAS.TTC_addon,
			},
			{
				type = "dropdown",
				name = TTFAS_PROFIT,
				tooltip = TTFAS_PROFIT_TT,
				choices = { L(TTFAS_PP_BASEPRICE), L(TTFAS_PP_PROFIT) },
				getFunc = function() return curprof.TTC_profit end,
				setFunc = function(value) curprof.TTC_profit = value end,
				default = L(TTFAS_PP_BASEPRICE),
				disabled = not TTFAS.TTC_addon,
			},
		}
		if not TamrielTradeCentre then return end
		TTFASLogger():Debug("Have TTC, adding TTC Section")
		
		for _, v in ipairs(TTC_options) do
			table.insert(ctltbl, v)
		end
	end
	
	local function integMSAL(ctltbl)
		if not MuchSmarterAutoLoot then return end
		local MSAL_options = {
			{
				type = "header",
				name = SF.ColorText(TTFAS_MSAL_ADDON, SF.hex.superior),
			},
			{
				type = "description",
				text = SF.ColorText(TTFAS_MSAL_DESC, SF.hex.frangipani),
			},
		}
		TTFASLogger():Debug("Have MSAL, adding MSAL Section")
		
		for _, v in ipairs(MSAL_options) do
			table.insert(ctltbl, v)
		end
	end

	local function integrationsSection(saved)
		if UnknownTracker or TamrielTradeCentre or ThiefTools then
			local ctltbl = {}
			integTT(ctltbl)
			integUT(ctltbl)
			integTTC(ctltbl)
			--integMSAL(ctltbl)		-- TBD
			
			return {
				type = "submenu",
				name = SF.ColorText(TTFAS_INTEGRATIONS, SF.hex.goldenrod),
				controls = ctltbl,
			}
		end

	end
	
	local optionsData = 
	{
		-- Addon-wide options
		-- Enable/disable TTFAS addon
		{
			type = "checkbox",
			name = TTFAS_ENABLE,
			tooltip = TTFAS_ENABLE_TT,
			keybind =  "UI_SHORTCUT_PRIMARY" , 
			getFunc = function() return TTFAS.saved.enabled end,
			setFunc = function(value)
				if value then
					TTFAS_Enable()
				else
					TTFAS_Disable()
				end
				TTFAS.saved.enabled = value 
			end,
			default = true,
		},
		-- announce banner on startup
		{
			type = "checkbox",
			name = TTFAS_BANNER,
			tooltip = TTFAS_BANNER_TT,
			getFunc = function() return saved.banner end,
			setFunc = function(value) saved.banner = value end,
			default = true
		},
		divider(),
		-- Game Settings
		{
			type = "submenu",
			name = SF.ColorText(TTFAS_GAME_SETTINGS, SF.hex.ltskyblue),
			controls = {
				{
					type = "description",
					text = SF.ColorText(TTFAS_GAME_SETTINGS_DESC, SF.hex.mocassin),
				},
				{
					type = "checkbox",
					name = TTFAS_LOOT_HISTORY,
					tooltip = TTFAS_LOOT_HISTORY_TT,
					getFunc = function() 
					local val = GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_LOOT_HISTORY)
						--TTFASLogger():Debug("Retrieved setting for Loot History: ", val, " type is ",type((val)))
						local v = (val=="true" or val=="1") and true or false
						--TTFASLogger():Debug("type of v: ", type(v), "value of v: ",v)
						return v 
					end,
					setFunc = function(value) 
						--TTFASLogger():Debug("Setting new val for Loot History: ", value, " type is ",type((value)))
						SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_LOOT_HISTORY, tostring(value)) 
					end,
					default = true,
				},
			}
		},
		-- Active Profile
		{
			type = "header",
			name = SF.ColorText(TTFAS_PROFILE_SETTINGS, SF.hex.bronze),
		},
		{
			type = "description",
			text = SF.ColorText(TTFAS_PROFILE_DESC, SF.hex.frangipani),
		},
		{
			type = "dropdown",
			name = TTFAS_CURRENT_PROFILE,
			tooltip = TTFAS_CURRENT_PROFILE_TT,
			choices = TTFAS.getProfileNames(),
			getFunc = function() 
				if not curprof.profileName then
					TTFASLogger():Debug("CURRENT_PROFILE - name was nil, setting to Account-Wide")
					curprof.profileName = "Account-Wide"
					TTFAS.ChangeCurProf(curprof.profileName)
					curprof = TTFAS.currentProfile
				end
				return curprof.profileName 
			end,
			setFunc = function(value) 
				TTFAS.ChangeCurProf(value)
				curprof = TTFAS.currentProfile
				local toonId = GetCurrentCharacterId()
				TTFAS.profTbl.uses[toonId] = value
			end,
			reference="TTFAS_CTL_CURRPROF",
		},
		{
			type = "description",
			text = SF.ColorText(TTFAS_PROFILE_DESC2, SF.hex.frangipani),
		},
		-- General Settings
		{
			type = "submenu",
			name = SF.ColorText(TTFAS_GENERAL_SETTINGS, SF.hex.goldenrod),
			controls = {
				 {
					type = "checkbox",
					name = TTFAS_CLOSE_LOOT_WINDOW,
					tooltip = TTFAS_CLOSE_LOOT_WINDOW_TT,
					getFunc = function() 
						return curprof.general.closeLootWindow 
					end,
					setFunc = function(value) 
						curprof.general.closeLootWindow = value 
					end,
					default = false,
				},
				{
					type = "checkbox",
					name = TTFAS_TURN_OFF_AUTOSTEAL,
					tooltip = TTFAS_TURN_OFF_AUTOSTEAL_TT,
					getFunc = function() return curprof.general.turnOffGmAS end,
					setFunc = function(value) curprof.general.turnOffGmAS = value end,
					default = true,
				},
				{
					type = "checkbox",
					name = TTFAS_TURN_OFF_AUTOLOOT,
					tooltip = TTFAS_TURN_OFF_AUTOLOOT_TT,
					getFunc = function() return curprof.general.turnOffGmAL end,
					setFunc = function(value) curprof.general.turnOffGmAL = value end,
					default = false,
				},
			}
		},
		-- Gear Filters
		gearSetting(),
		-- Materials Filters
		{
			type = "submenu",
			name = SF.ColorText(TTFAS_MATERIAL_FILTERS, SF.hex.goldenrod),
			controls = {
				{
					type = "dropdown",
					name = TTFAS_CRAFTING_MATERIALS,
					tooltip = TTFAS_CRAFTING_MATERIALS_TT,
					choices = booleanChoices,
					choicesValues = booleanChoicesValues,
					getFunc = function() return curprof.materials.crafting end,
					setFunc = function(value) curprof.materials.crafting = value end,
					default = FASFV:val(FAS_NEVER),
				},
				{
					type = "dropdown",
					name = TTFAS_STYLE_MATERIALS,
					choices = styleMaterialsChoices,
					choicesValues = styleMaterialsChoicesValues,
					getFunc = function() return curprof.materials.style end,
					setFunc = function(value) curprof.materials.style = value end,
					default = FASFV:val(FAS_NEVER),
				},
				{
					type = "dropdown",
					name = TTFAS_TRAIT_MATERIALS,
					choices = booleanChoices,
					choicesValues = booleanChoicesValues,
					getFunc = function() return curprof.materials.trait end,
					setFunc = function(value) curprof.materials.trait = value end,
					default = FASFV:val(FAS_NEVER),
				},
				{
					type = "dropdown",
					name = TTFAS_ALCHEMY_INGREDIENTS,
					choices = booleanChoices,
					choicesValues = booleanChoicesValues,
					getFunc = function() return curprof.materials.alchemy end,
					setFunc = function(value) curprof.materials.alchemy = value end,
					default = FASFV:val(FAS_NEVER),
				},
				{
					type = "dropdown",
					name = TTFAS_COOKING_INGREDIENTS,
					choices = booleanChoices,
					choicesValues = booleanChoicesValues,
					getFunc = function() return curprof.materials.ingredients end,
					setFunc = function(value) curprof.materials.ingredients = value end,
					default = FASFV:val(FAS_NEVER),
				},
				{
					type = "dropdown",
					name = TTFAS_ENCHANTING_RUNES,
					choices = booleanChoices,
					choicesValues = booleanChoicesValues,
					getFunc = function() return curprof.materials.runes end,
					setFunc = function(value) curprof.materials.runes = value end,
					default = FASFV:val(FAS_NEVER),
				},
				{
					type = "dropdown",
					name = TTFAS_FURNISHING_MATERIALS,
					choices = booleanChoices,
					choicesValues = booleanChoicesValues,
					getFunc = function() return curprof.materials.furnishing end,
					setFunc = function(value) curprof.materials.furnishing = value end,
					default = FASFV:val(FAS_NEVER),
				},
			}
		},
		-- Treasures Filters
		{
			type = "submenu",
			name = SF.ColorText(TTFAS_TREASURES_FILTERS, SF.hex.goldenrod),
			controls = {
				{
					type = "dropdown",
					name = TTFAS_TREASURES,
					choices = treasuresChoices,
					choicesValues = treasuresChoicesValues,
					getFunc = function() return curprof.treasures.treasures end,
					setFunc = function(value) curprof.treasures.treasures = value end,
					default = FASFV:val(FAS_ALWAYS),
				},
				{
					type = "dropdown",
					name = TTFAS_TREASURES_QUALITY_THRESHOLD,
					choices = qualityChoices,
					choicesValues = qualityChoicesValues,
					getFunc = function() return curprof.treasures.minQuality end,
					setFunc = function(value) curprof.treasures.minQuality = value end,
					default = ITEM_DISPLAY_QUALITY_NORMAL,
					disabled = function() return curprof.treasures.treasures ~= FASFV:val(FAS_MIN_QUALITY) end,
				},
				{
					type = "checkbox",
					name = TTFAS_TURN_ON_AZANDAR,
					tooltip = TTFAS_TURN_ON_AZANDAR_TT,
					getFunc = function() return curprof.treasures.azandar end,
					setFunc = function(value) curprof.treasures.azandar = value end,
					default = true,
				},
			},
		},
		-- Containers Filters
		{
			type = "submenu",
			name = SF.ColorText(TTFAS_CONTAINERS_FILTERS, SF.hex.goldenrod),
			controls = {
				{
					type = "dropdown",
					name = TTFAS_CONTAINERS,
					choices = booleanChoices,
					choicesValues = booleanChoicesValues,
					getFunc = function() return curprof.containers.containers end,
					setFunc = function(value) curprof.containers.containers = value end,
					default = FASFV:val(FAS_ALWAYS),
				},
				{
					type = "dropdown",
					name = TTFAS_INV_CONTAINERS,
					choices = stolenContainerChoices,
					choicesValues = stolenContainerChoicesValues,
					getFunc = function() return curprof.containers.invcontainers end,
					setFunc = function(value) curprof.containers.invcontainers = value end,
					default = FASFV:val(FAS_TAKE_ALL),
				},
			},
		},
		-- Papers Filters
		{
			type = "submenu",
			name = SF.ColorText(TTFAS_PAPERS_FILTERS, SF.hex.goldenrod),
			controls = {
				recipeCtl(saved),
				motifsCtl(saved),
				stylesCtl(saved),
				divider(),
				{
					type = "dropdown",
					name = TTFAS_TREASURE_MAPS,
					choices = treasureMapsChoices,
					choicesValues = treasureMapsChoicesValues,
					getFunc = function() return curprof.papers.treasureMaps end,
					setFunc = function(value) curprof.papers.treasureMaps = value end,
					default = FASFV:val(FAS_NON_BASE_ZONE),
				},
				{
					type = "dropdown",
					name = TTFAS_WRITS,
					choices = booleanChoices,
					choicesValues = booleanChoicesValues,
					getFunc = function() return curprof.papers.writs end,
					setFunc = function(value) curprof.papers.writs = value end,
					default = FASFV:val(FAS_NEVER),
				},
				divider(),
				paperTTCpriceCtl(saved),
				checkTTCPriceCtl(saved),
			},
		},
		-- Miscellaneous Filters
		{
			type = "submenu",
			name = SF.ColorText(TTFAS_MISC_FILTERS, SF.hex.goldenrod),
			controls = {
				{
					type = "dropdown",
					name = TTFAS_GLYPHS,
					choices = booleanChoices,
					choicesValues = booleanChoicesValues,
					getFunc = function() return curprof.misc.glyphs end,
					setFunc = function(value) curprof.misc.glyphs = value end,
					default = FASFV:val(FAS_NEVER),
				},
				{
					type = "dropdown",
					name = TTFAS_FOOD_DRINK,
					choices = booleanChoices,
					choicesValues = booleanChoicesValues,
					getFunc = function() return curprof.misc.foodAndDrink end,
					setFunc = function(value) curprof.misc.foodAndDrink = value end,
					default = FASFV:val(FAS_NEVER),
				},
				{
					type = "dropdown",
					name = TTFAS_POISONS,
					choices = booleanChoices,
					choicesValues = booleanChoicesValues,
					getFunc = function() return curprof.misc.poisons end,
					setFunc = function(value) curprof.misc.poisons = value end,
					default = FASFV:val(FAS_NEVER),
				},
				{
					type = "dropdown",
					name = TTFAS_POTIONS,
					choices = potionsChoices,
					choicesValues = potionsChoicesValues,
					getFunc = function() return curprof.misc.potions end,
					setFunc = function(value) curprof.misc.potions = value end,
					default = FASFV:val(FAS_NEVER),
				},
				divider(),
				{
					type = "dropdown",
					name = TTFAS_FURNITURE,
					choices = booleanChoices,
					choicesValues = booleanChoicesValues,
					getFunc = function() return curprof.misc.furniture end,
					setFunc = function(value) curprof.misc.furniture = value end,
					default = FASFV:val(FAS_NEVER),
				},
				divider(),
				{
					type = "dropdown",
					name = TTFAS_LOCKPICKS_TOOLS,
					choices = booleanChoices,
					choicesValues = booleanChoicesValues,
					getFunc = function() return curprof.misc.lockpicks end,
					setFunc = function(value) curprof.misc.lockpicks = value end,
					default = FASFV:val(FAS_NEVER),
				},
				{
					type = "dropdown",
					name = TTFAS_SOUL_GEMS,
					choices = soulGemsChoices,
					choicesValues = soulGemsChoicesValues,
					getFunc = function() return curprof.misc.soulGems end,
					setFunc = function(value) curprof.misc.soulGems = value end,
					default = FASFV:val(FAS_FILLED),
				},
				divider(),
				{
					type = "dropdown",
					name = TTFAS_BAIT,
					choices = booleanChoices,
					choicesValues = booleanChoicesValues,
					getFunc = function() return curprof.misc.bait end,
					setFunc = function(value) curprof.misc.bait = value end,
					default = FASFV:val(FAS_NEVER),
				},
			}
		},
		--Integratons
		integrationsSection(saved),
		-- Profile Management
		{
			type = "submenu",
			name = SF.ColorText(TTFAS_PROFILE_MGMT, SF.hex.bronze),
			controls = {
				{
					type = "header",
					name = SF.ColorText(TTFAS_CREATE_PROF, SF.hex.superior),
				},
				{
					type = "description",
					text = SF.ColorText(TTFAS_CREATE_PROF_DESC, SF.hex.mocassin),
				},
				{
					type = "description",
					text = SF.ColorText(TTFAS_NEW_PROF_NAME_DESC, SF.hex.mocassin),
				},
				{
					type = "editbox",
					name = TTFAS_NEW_PROF_NAME, -- or string id or function returning a string
					getFunc = function() return newprofname end,
					setFunc = function(value) 
						TTFASLogger():Debug(SF.str("Entered name: >",value,"<"))
						if value == "" then
							TTFASLogger():Debug("Tried to choose empty string as a profile name.")
							newprofname = nil
							
						elseif value == "Default" or value == "Account-Wide" then
							TTFASLogger()r:Debug("Tried to choose invalid name "..value.." as a profile name.")
							newprofname = nil
							
						elseif TTFAS.isNewProfileName(value) then
							TTFASLogger():Debug("New profile name submitted: ".. value)
							newprofname = value 
							
						else
							TTFASLogger():Debug("Profile name already exists: ".. value)
							newprofname = nil
						end
					end,
					reference="TTFAS_CTL_NEWPROFNM",

				},
				{
					type = "dropdown",
					name = TTFAS_COPYFROM_PROFILE,
					tooltip = TTFAS_COPYFROM_PROFILE_TT,
					choices = TTFAS.getCopyableProfileNames(),
					getFunc = function() return fromprofname end,
					setFunc = function(value) 
						if value == "" then
							TTFASLogger():Debug("No copy profile selected: >"..value.."<")
							fromprofname = nil
							return 
						end
						local fromprof = TTFAS.profTbl.profiles[value]
						if fromprof then
							TTFASLogger():Debug("Want to copy prof: "..value)
							fromprofname = value
						end
					end,
					reference="TTFAS_CTL_FROMPROF",
				},
				{
					type = "button",
					name = TTFAS_SAVE_PROF_BTN, -- string id or function returning a string
					disabled = function () 
						if newprofname and fromprofname then
							return false
						end
						return true
					end,
					func = function() 
						TTFASLogger():Debug("Saving profile for "..newprofname)
						if newprofname and newprofname ~= "" and newprofname ~= "Account-Wide" and newprofname ~= "Default" then
							saveProfile(newprofname, fromprofname)
							newprofname = nil
							fromprofname = nil
						end
					end,
					reference = "TTFAS_CTL_SVPROF",
                    width = "half", --or "half" (optional)
				},
				{
					type = "header",
					name = SF.ColorText(TTFAS_DELETE_HDR, SF.hex.superior),
				},
				{
					type = "description",
					text = SF.ColorText(TTFAS_DEL_PROF_DESC, SF.hex.mocassin),
				},
				{
					type = "dropdown",
					name = TTFAS_DEL_PROFILE,
					choices = TTFAS.getUserProfileNames(),
					getFunc = function() return oldprofname end,
					setFunc = function(value) 
						if value == "Account-Wide" then
							TTFASLogger():Debug("Not allowed to delete: "..value)
							oldprofname = nil
							UpdateValue("TTFAS_CTL_USEDBY","  ")
							return 
						end
						local oldprof = TTFAS.profTbl.profiles[value]
						if oldprof then
							TTFASLogger():Debug("Want to delete prof: "..value)
							oldprofname = value
							UpdateValue("TTFAS_CTL_USEDBY",value)
						end
					end,
					reference="TTFAS_CTL_DELPROF",
				},
				{
					type = "description",
					text = function()
						local numusers = 0
						for k, v in pairs(TTFAS.profTbl.uses) do
							if v == oldprofname then
								numusers = numusers + 1
							end
						end
						return SF.ColorText(SF.str(L(TTFAS_USED_BY), numusers), SF.hex.mocassin)
					end,
					reference="TTFAS_CTL_USEDBY",
				},
				{
					type = "button",
					name = TTFAS_DELETE_PROF_BTN,
					disabled = function () 
						if oldprofname and oldprofname~="" then
							return false
						end
						return true
					end,
                    isDangerous = true,
					warning = TTFAS_CONFIRM_DELETE,
					func = function() 
						TTFASLogger():Debug("Check deleting profile for "..oldprofname)
						if oldprofname then
							if oldprofname == curprof.profileName then
								TTFASLogger():Debug("Changing current profile from ".. curprof.profileName.." to Account-Wide")
								curprof.profileName = "Account-Wide"
							end
							TTFASLogger():Debug("Deleting profile for "..oldprofname)
							TTFAS.deleteProfile(oldprofname)
							oldprofname = nil
							updateProfileDDs()
						end
					end,
				},
			},
		},
		-- Debug options
		{
			type = "checkbox",
			name = TTFAS_DEBUG,
			tooltip = TTFAS_DEBUG_TT,
			getFunc = function() return saved.debugMode end,
			setFunc = function(value) 
				saved.debugMode = value
				TTFAS.toggleDebug(value)
			end,
			width = "half",
			default = false,
		},
	}
	
	LAM:RegisterAddonPanel("TTFASOptions", panelData)
	LAM:RegisterOptionControls("TTFASOptions", optionsData)
end
