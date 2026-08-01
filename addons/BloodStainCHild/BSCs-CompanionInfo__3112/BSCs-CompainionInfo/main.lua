BSCCompainionInfo = BSCCompainionInfo or {}
local BSCCOIN = BSCCompainionInfo

BSCCOIN.Name = "BSCs-CompainionInfo"
BSCCOIN.NameSpaced = "BloodStainChild666's Compainion Info"
BSCCOIN.Author = "@BloodStainChild666"
BSCCOIN.Version = 1
BSCCOIN.SavedVar = "BSCCompainionInfoSaved"
BSCCOIN.NameMenu = "BSCs-CompanionUI"
BSCCOIN.VersionDisplay = "1.0.2"

local defaultSV = {
	UI_LEFT = 250,
	UI_TOP = 500,
	UI_WIDTH = 250,
	UI_HIGHT_HPBAR = 36,
	UI_HIGHT_XPBAR = 20,
	UI_HIGHT_SKILLBAR = 30,
	UI_LOCK = false, 
	PRINT_RAPPORT_CHAT = true,
	DIGIT_DECIMAL_REPLACER = ".",
	-- Name Settings
	DISPLAY_NAME = true,
	DISPLAY_ICON = true,
	ICON_SIZE = 35,
	NAME_FONT = "BOLD_FONT",
	NAME_FONT_SIZE = 23,
	NAME_FONT_STYLE = "soft-shadow-thick",
	NAME_FONT_COLOR = {255, 255, 255, 255},
	-- XPBAr
	DISPLAY_EXPBAR = true,
	XPBAR_FONT = "BOLD_FONT",
	XPBAR_FONT_SIZE = 12,
	XPBAR_FONT_STYLE = "soft-shadow-thick",
	XPBAR_FONT_COLOR = {255, 255, 255, 255},
	XPBAR_BAR_COLORS = ZO_XP_BAR_GRADIENT_COLORS,
	-- HP Bar
	HPBAR_FONT = "BOLD_FONT",
	HPBAR_FONT_SIZE = 23,
	HPBAR_FONT_STYLE = "soft-shadow-thick",
	HPBAR_FONT_COLOR = {255, 255, 255, 255},
	HPBAR_BAR_COLORS = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_HEALTH],
	-- Skills (Alpha)
	DISPLAY_SKILLS = false,
	SKILLS_FONT = "MEDIUM_FONT",
	SKILLS_FONT_SIZE = 14,
	SKILLS_FONT_STYLE = "soft-shadow-thick",
}

--
BSCCOIN.RAPPOER_LEVEL = 0
BSCCOIN.RAPPORT_MIN = GetMinimumRapport()
BSCCOIN.RAPPORT_MAX = GetMaximumRapport()

--local ENGLISH_DIGIT_GROUP_DECIMAL_REPLACER = "."
function BSCCOIN:FormatNumer(amount)	
	if tonumber(amount) < 1000 and tonumber(amount) > -1000 then
		return tostring(amount)
	end
	
	local addMinus = false
	if amount < 0 then
		addMinus = true
		amount = tonumber(amount) * -1
	end
	
	local value = FormatIntegerWithDigitGrouping(amount, BSCCOIN.SV.DIGIT_DECIMAL_REPLACER, GetDigitGroupingSize())
	if addMinus then value = "-"..value end
	
	return value
end
local function FontCheck(size)
	local new_size = size
	
	if size > 54 then new_size = 54 end
	if size > 48 and size < 54 then new_size = 48 end
	if size > 40 and size < 48 then new_size = 40 end
	if size > 36 and size < 40 then new_size = 36 end
	if size > 34 and size < 36 then new_size = 34 end
	if size > 32 and size < 34 then new_size = 32 end
	if size > 30 and size < 32 then new_size = 30 end
	if size > 28 and size < 30 then new_size = 28 end
	if size > 26 and size < 28 then new_size = 26 end
		
	return new_size
end
local function GetFont(Font, Size, Style)
	return zo_strformat("$(<<1>>)|$(KB_<<2>>)|<<3>>", Font, FontCheck(Size), Style)
end

-------------------------------------------------------------------------------------------------
-- UI
-------------------------------------------------------------------------------------------------
local function InitUI()		
	-- XP Bar		
	BSCCOIN.xpBarControl = BSCCompainionInfoUI:GetNamedChild("BDXPBExpBar")
    BSCCOIN.xpBar = ZO_WrappingStatusBar:New(BSCCOIN.xpBarControl)	
	
	-- HP Bar
	BSCCOIN.HPBarControl = BSCCompainionInfoUI:GetNamedChild("HPBackdropHPBar")
    BSCCOIN.HPBar = ZO_WrappingStatusBar:New(BSCCOIN.HPBarControl)
	
	--BSCCOIN:UpdateUISettings()
end
-------------------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------------------
local function UpdateHealtBar(value, maxvalue)
	if BSCCOIN.HPBar == nil then return end
	BSCCompainionInfoUI:GetNamedChild("HPBackdropHPValue"):SetText(zo_strformat("<<1>> / <<2>>", BSCCOIN:FormatNumer(value), BSCCOIN:FormatNumer(maxvalue)))	
	BSCCOIN.HPBar:SetValue(0, value, maxvalue, true, true)
end

local function HideCompanionFrame()	
	if not IsUnitGrouped("player") and UNIT_FRAMES:GetFrame("companion") ~= nil then
		UNIT_FRAMES:GetFrame("companion"):SetHiddenForReason("disabled", true)
	end
end
-------------------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------------------
local function UnpackRGBA(color)
	return color.r, color.g, color.b, color.a
end

function BSCCOIN:UpdateUISettings()
	local level, currentXpInLevel, totalXpInLevel, isMaxLevel = ZO_COMPANION_MANAGER:GetLevelInfo()
	if level <= 0 then isMaxLevel = false end
	
	BSCCompainionInfoUI:SetMovable(not BSCCOIN.SV.UI_LOCK)	
	-- Name
	if not BSCCOIN.SV.DISPLAY_NAME then
		BSCCompainionInfoUI:GetNamedChild("BDName"):SetHidden(true)
	else
		BSCCompainionInfoUI:GetNamedChild("BDName"):SetHidden(false)
		BSCCompainionInfoUI:GetNamedChild("BDName"):SetDimensions(BSCCOIN.SV.UI_WIDTH, BSCCOIN.SV.UI_HIGHT_HPBAR +10)
		BSCCompainionInfoUI:GetNamedChild("BDNameName"):SetColor(unpack(BSCCOIN.SV.NAME_FONT_COLOR))
		BSCCompainionInfoUI:GetNamedChild("BDNameName"):SetFont(GetFont(BSCCOIN.SV.NAME_FONT, BSCCOIN.SV.NAME_FONT_SIZE, BSCCOIN.SV.NAME_FONT_STYLE))
	end
	-- Icon
	if not BSCCOIN.SV.DISPLAY_ICON then
		BSCCompainionInfoUI:GetNamedChild("BDNameIcon"):SetHidden(true)
	else
		BSCCompainionInfoUI:GetNamedChild("BDNameIcon"):SetHidden(false)
		BSCCompainionInfoUI:GetNamedChild("BDNameIcon"):SetDimensions(BSCCOIN.SV.ICON_SIZE, BSCCOIN.SV.ICON_SIZE)		
	end
		
	-- HP Bar
	BSCCompainionInfoUI:GetNamedChild("HPBackdrop"):SetDimensions(BSCCOIN.SV.UI_WIDTH, BSCCOIN.SV.UI_HIGHT_HPBAR)
	BSCCompainionInfoUI:GetNamedChild("HPBackdropHPBar"):SetDimensions(BSCCOIN.SV.UI_WIDTH-2, BSCCOIN.SV.UI_HIGHT_HPBAR-4)
	BSCCompainionInfoUI:GetNamedChild("HPBackdropHPBar"):ClearAnchors()
	BSCCompainionInfoUI:GetNamedChild("HPBackdropHPBar"):SetAnchor(TOPLEFT, BSCCompainionInfoUI:GetNamedChild("HPBackdrop"), TOPLEFT, 2, 2)
	-- Set Font Stuff HP Bar
	BSCCompainionInfoUI:GetNamedChild("HPBackdropHPValue"):SetColor(unpack(BSCCOIN.SV.HPBAR_FONT_COLOR))
	BSCCompainionInfoUI:GetNamedChild("HPBackdropHPValue"):SetFont(GetFont(BSCCOIN.SV.HPBAR_FONT, BSCCOIN.SV.HPBAR_FONT_SIZE, BSCCOIN.SV.HPBAR_FONT_STYLE))
	-- HP Color		
	--ZO_StatusBar_SetGradientColor(BSCCOIN.HPBarControl, ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_HEALTH])
	local r, g, b, a = UnpackRGBA(BSCCOIN.SV.HPBAR_BAR_COLORS[1])
	local r1, g1, b1, a1 = UnpackRGBA(BSCCOIN.SV.HPBAR_BAR_COLORS[2])
	BSCCOIN.HPBarControl:SetGradientColors(r, g, b, a, r1, g1, b1, a1)
		
	-- XP Bar
	BSCCompainionInfoUI:GetNamedChild("BDXPB"):SetDimensions(BSCCOIN.SV.UI_WIDTH, BSCCOIN.SV.UI_HIGHT_XPBAR)
	BSCCompainionInfoUI:GetNamedChild("BDXPBExpBar"):SetDimensions(BSCCOIN.SV.UI_WIDTH-2, BSCCOIN.SV.UI_HIGHT_XPBAR-2)
	BSCCompainionInfoUI:GetNamedChild("BDXPBExpBar"):ClearAnchors()
	BSCCompainionInfoUI:GetNamedChild("BDXPBExpBar"):SetAnchor(TOPLEFT, BSCCompainionInfoUI:GetNamedChild("BDXPB"), TOPLEFT, 1, 1)
	-- Set Font Stuff
	BSCCompainionInfoUI:GetNamedChild("BDXPBExpInfo"):SetColor(unpack(BSCCOIN.SV.XPBAR_FONT_COLOR))
	BSCCompainionInfoUI:GetNamedChild("BDXPBExpInfo"):SetFont(GetFont(BSCCOIN.SV.XPBAR_FONT, BSCCOIN.SV.XPBAR_FONT_SIZE, BSCCOIN.SV.XPBAR_FONT_STYLE))
	-- Color 
    --ZO_StatusBar_SetGradientColor(BSCCOIN.xpBarControl, ZO_XP_BAR_GRADIENT_COLORS)	
	r, g, b, a = UnpackRGBA(BSCCOIN.SV.XPBAR_BAR_COLORS[1])
	r1, g1, b1, a1 = UnpackRGBA(BSCCOIN.SV.XPBAR_BAR_COLORS[2])
	BSCCOIN.xpBarControl:SetGradientColors(r, g, b, a, r1, g1, b1, a1)
	
	 	
	if isMaxLevel or not BSCCOIN.SV.DISPLAY_EXPBAR then
		BSCCompainionInfoUI:GetNamedChild("BDXPB"):SetHidden(true)
	else
		BSCCompainionInfoUI:GetNamedChild("BDXPB"):SetHidden(false)
	end	
	
	-- Skill Infos	
	if not BSCCOIN.SV.DISPLAY_SKILLS then	
		-- hide Skills infos
		BSCCompainionInfoUI:GetNamedChild("SKillInfo"):SetHidden(true)
	else		
		BSCCompainionInfoUI:GetNamedChild("SKillInfo"):SetHidden(false)
		BSCCompainionInfoUI:GetNamedChild("SKillInfo"):ClearAnchors()
		if isMaxLevel or not BSCCOIN.SV.DISPLAY_EXPBAR then
			BSCCompainionInfoUI:GetNamedChild("SKillInfo"):SetAnchor(TOPLEFT, BSCCompainionInfoUI:GetNamedChild("HPBackdrop"), BOTTOMLEFT, 0, 0)
		else
			BSCCompainionInfoUI:GetNamedChild("SKillInfo"):SetAnchor(TOPLEFT, BSCCompainionInfoUI:GetNamedChild("BDXPB"), BOTTOMLEFT, 0, 0)
		end
		
		BSCCompainionInfoUI:GetNamedChild("SKillInfo"):SetDimensions(BSCCOIN.SV.UI_WIDTH, BSCCOIN.SV.UI_HIGHT_SKILLBAR)
		for i = 1, 6 do
			BSCCompainionInfoUI:GetNamedChild("SKillInfoIC"..tostring(i)):SetDimensions(BSCCOIN.SV.UI_HIGHT_SKILLBAR, BSCCOIN.SV.UI_HIGHT_SKILLBAR)
			if i <= 5 then
				BSCCompainionInfoUI:GetNamedChild("SKillInfoIC"..tostring(i).."CD"):SetFont(GetFont(BSCCOIN.SV.SKILLS_FONT, BSCCOIN.SV.SKILLS_FONT_SIZE, BSCCOIN.SV.SKILLS_FONT_STYLE))
			end
		end
	end			
end
local function UpdateOnSpawn()
	if DoesUnitExist("companion") and HasActiveCompanion() then
		BSCCompainionInfoUI:SetHidden(false)
		BSCCOIN:UpdateUISettings()
		HideCompanionFrame()
		
		BSCCompainionInfoUI:GetNamedChild("BDNameIcon"):SetTexture(ZO_COMPANION_MANAGER:GetActiveCompanionIcon())
		BSCCompainionInfoUI:GetNamedChild("BDNameName"):SetText(zo_strformat("<<1>> (<<2>>)", GetCompanionName(GetActiveCompanionDefId()), GetUnitLevel('companion')))
		
		local current, max, effectiveMax = GetUnitPower('companion', POWERTYPE_HEALTH)
		UpdateHealtBar(current, effectiveMax)
	else
		BSCCompainionInfoUI:SetHidden(true)
	end
end
-------------------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------------------
local function UpdateXPUI()
	if BSCCOIN.xpBar == nil then return end
	if HasActiveCompanion() then		
		if not BSCCOIN.SV.DISPLAY_EXPBAR then return end	
        local level, currentXpInLevel, totalXpInLevel, isMaxLevel = ZO_COMPANION_MANAGER:GetLevelInfo()		
		local forceRefresh = true
        local shouldNotWrap = forceRefresh
        if isMaxLevel then			
			BSCCompainionInfoUI:GetNamedChild("BDXPB"):SetHidden(true)			
			if BSCCOIN.SV.DISPLAY_SKILLS then
				BSCCompainionInfoUI:GetNamedChild("SKillInfo"):ClearAnchors()
				BSCCompainionInfoUI:GetNamedChild("SKillInfo"):SetAnchor(TOPLEFT, BSCCompainionInfoUI:GetNamedChild("HPBackdrop"), BOTTOMLEFT, 0, 0)
			end
        else			
			BSCCompainionInfoUI:GetNamedChild("BDXPB"):SetHidden(false)
			if BSCCOIN.SV.DISPLAY_SKILLS then
				BSCCompainionInfoUI:GetNamedChild("SKillInfo"):ClearAnchors()
				BSCCompainionInfoUI:GetNamedChild("SKillInfo"):SetAnchor(TOPLEFT, BSCCompainionInfoUI:GetNamedChild("BDXPB"), BOTTOMLEFT, 0, 0)		
			end
						
            BSCCOIN.xpBar:SetValue(level, currentXpInLevel, totalXpInLevel, shouldNotWrap, forceRefresh)
			local percentageXp = zo_floor(currentXpInLevel / totalXpInLevel * 100)  		
			BSCCompainionInfoUI:GetNamedChild("BDXPBExpInfo"):SetText(zo_strformat(SI_EXPERIENCE_CURRENT_MAX_PERCENT, ZO_CommaDelimitNumber(currentXpInLevel), ZO_CommaDelimitNumber(totalXpInLevel), percentageXp))
		end
		BSCCompainionInfoUI:GetNamedChild("BDNameName"):SetText(zo_strformat("<<1>> (<<2>>)", GetCompanionName(GetActiveCompanionDefId()), level))
	end
end
-------------------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------------------
local function ToggleUI(oldState, newState)
	if not DoesUnitExist("companion") and not HasActiveCompanion() then return end

	if newState == SCENE_SHOWN then
		BSCCompainionInfoUI:SetHidden(false)
	elseif newState == SCENE_HIDDEN then
		BSCCompainionInfoUI:SetHidden(true)
	end
end
function BSCCOIN.OnMoveStop()
	BSCCOIN.SV.UI_LEFT = BSCCompainionInfoUI:GetLeft()
	BSCCOIN.SV.UI_TOP = BSCCompainionInfoUI:GetTop()
end
local function RestorePosition()
	-- Position
	BSCCompainionInfoUI:ClearAnchors()
	BSCCompainionInfoUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BSCCOIN.SV.UI_LEFT, BSCCOIN.SV.UI_TOP)
	BSCCompainionInfoUI:SetMovable(not BSCCOIN.SV.UI_LOCK)
end
-------------------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------------------
local function OnCompanionActivate()
	BSCCOIN:UpdateUISettings()
	UpdateXPUI()
	UpdateOnSpawn()
	BSCCOIN.RAPPOER_LEVEL = GetActiveCompanionRapportLevel()
	zo_callLater(function() BSCCOIN:InitSkillBarIcons() end, 1500)
	HideCompanionFrame()
end
-------------------------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------------------------
local function OnCompanionDeactivate()
	UpdateXPUI()
	UpdateOnSpawn()
end
-------------------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------------------
local function OnCompainStatChange( _, newState, oldState)
	--d(zo_strformat('NewState[<<1>>] OldState[<<2>>]', newState, oldState))
	if newState ~= COMPANION_STATE_ACTIVE then
		BSCCompainionInfoUI:SetHidden(true)
	else
		BSCCompainionInfoUI:SetHidden(false)
		HideCompanionFrame()	
	end	
end
-------------------------------------------------------------------------------------------------
-- OnCompanionPowerUpdate
-------------------------------------------------------------------------------------------------
local function OnCompanionPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	if not HasActiveCompanion() then return end
	UpdateHealtBar(powerValue, powerEffectiveMax)	
	--d(zo_strformat("unitTag[<<1>>] powerValue[<<2>>] powerMax[<<3>>] powerEffectiveMax[<<4>>]", unitTag, powerValue, powerMax, powerEffectiveMax))
end
-------------------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------------------
local function OnPlayerActivated()	
    EVENT_MANAGER:UnregisterForEvent(BSCCOIN.Name, EVENT_PLAYER_ACTIVATED)
	
	BSCCOIN:UpdateUISettings()
	UpdateXPUI()
	UpdateOnSpawn()
	BSCCOIN:InitSkillBarIcons()
	BSCCompainionInfoUI:SetHidden(true)
end
-------------------------------------------------------------------------------------------------
-- Menu Labels
-------------------------------------------------------------------------------------------------
local function CreateLable()
	-- font
	local fontSize = 22
	local fontStyle = ZoFontGame:GetFontInfo()
	local fontWeight = "soft-shadow-thin"
	local font = string.format("%s|$(KB_%s)|%s", fontStyle, fontSize, fontWeight)
	
	local parentR = ZO_CompanionOverview_Panel_KeyboardRapportContainerProgressIconRight	
	BSCCOIN.RaportMaxLabel = WINDOW_MANAGER:CreateControl(nil, parentR, CT_LABEL)
	BSCCOIN.RaportMaxLabel:SetAnchor(TOP, parentR, BOTTOM, 0, 0) 
	BSCCOIN.RaportMaxLabel:SetFont(font)
		
	local parentL = ZO_CompanionOverview_Panel_KeyboardRapportContainerProgressIconLeft	
	BSCCOIN.RaportMinLabel = WINDOW_MANAGER:CreateControl(nil, parentL, CT_LABEL)
	BSCCOIN.RaportMinLabel:SetAnchor(TOP, parentL, BOTTOM, 0, 0) 
	BSCCOIN.RaportMinLabel:SetFont(font)
	
	local parentB = ZO_CompanionOverview_Panel_KeyboardRapportContainerProgressBar	
	BSCCOIN.RaportValueLabel = WINDOW_MANAGER:CreateControl(nil, parentB, CT_LABEL)
	BSCCOIN.RaportValueLabel:SetAnchor(BOTTOM, parentB, TOP, 0, 0) 
	BSCCOIN.RaportValueLabel:SetFont(font)	
	
	--local parentDesc = ZO_CompanionOverview_Panel_KeyboardRapportContainerDescription	
	--/script d(GetAbilityDescription(ZO_COMPANION_MANAGER:GetActiveCompanionPassivePerkAbilityId()))
end
-------------------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------------------
local function SetRapportMenuValues()
	BSCCOIN.RaportMaxLabel:SetText(BSCCOIN:FormatNumer(GetMaximumRapport()))
	BSCCOIN.RaportMinLabel:SetText(BSCCOIN:FormatNumer(GetMinimumRapport()))
	BSCCOIN.RaportValueLabel:SetText("Current Value: "..BSCCOIN:FormatNumer(GetActiveCompanionRapport()))
end

--SI_DIGIT_DECIMAL_SEPARATOR
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////// --- Init -- //////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function BSCCOIN.init(event, addonName)	
	if addonName ~= BSCCOIN.Name then
		return 
	end
	EVENT_MANAGER:UnregisterForEvent(BSCCOIN.Name, 	EVENT_ADD_ON_LOADED)

	BSCCOIN.SV = ZO_SavedVars:NewAccountWide(BSCCOIN.SavedVar, BSCCOIN.Version, nil, defaultSV)
	-- Command
	--SLASH_COMMANDS['/bsccoin'] = SlashCommand
	
	-- Menu Stuff
	CreateLable()	
	-- UI
	RestorePosition()
	BSCCOIN:InitMenu()	
	BSCCOIN:InitSkillCD()
	BSCCOIN:InitRapport()
	InitUI()
	
	EVENT_MANAGER:RegisterForEvent(BSCCOIN.Name, EVENT_OPEN_COMPANION_MENU, SetRapportMenuValues)	
	
	EVENT_MANAGER:RegisterForEvent(BSCCOIN.Name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)	
	
	-- Compainion Stuff
	EVENT_MANAGER:RegisterForEvent(BSCCOIN.Name, EVENT_COMPANION_ACTIVATED, OnCompanionActivate)
	EVENT_MANAGER:RegisterForEvent(BSCCOIN.Name, EVENT_COMPANION_DEACTIVATED, OnCompanionDeactivate)
	EVENT_MANAGER:RegisterForEvent(BSCCOIN.Name, EVENT_ACTIVE_COMPANION_STATE_CHANGED, OnCompainStatChange)
	EVENT_MANAGER:RegisterForEvent(BSCCOIN.Name, EVENT_COMPANION_EXPERIENCE_GAIN, UpdateXPUI)
	
	-- HP Update
	EVENT_MANAGER:RegisterForEvent(BSCCOIN.Name, EVENT_POWER_UPDATE, OnCompanionPowerUpdate)
	EVENT_MANAGER:AddFilterForEvent(BSCCOIN.Name, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
	EVENT_MANAGER:AddFilterForEvent(BSCCOIN.Name, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, 'companion')
		  
	-- Scene Stuff
	SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", ToggleUI)
	SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", ToggleUI)
	
end

EVENT_MANAGER:RegisterForEvent(BSCCOIN.Name, EVENT_ADD_ON_LOADED, BSCCOIN.init)

