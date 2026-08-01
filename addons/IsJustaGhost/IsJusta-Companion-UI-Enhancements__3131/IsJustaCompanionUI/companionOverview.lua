
local rapportMaxPerLevel = { -- not in use
	[0] = -2500, -- ?
	[1] = -1500, -- ?
	[2] = 749,
	[3] = 1499,
	[4] = 2749,
	[5] = 3999,
	[6] = 4999,
	[7] = 5500,
}

local function getRapportPercent(CUR, MAX)
	return zo_floor(CUR / MAX * 100)
end

local function getRapportValueString(CUR)
	local MAX = GetMaximumRapport()
	return zo_strformat(GetString(SI_IJA_MCF_RAPPORTPERCENT), ZO_CommaDelimitNumber(CUR), ZO_CommaDelimitNumber(MAX), getRapportPercent(CUR, MAX))
end

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
local Companion_Overview = ZO_InitializingObject:Subclass()

function Companion_Overview:Initialize(parent)
	zo_mixin(self, parent)
end

---------------------------------------------------------------------------------------------------------------
-- Keyboad
---------------------------------------------------------------------------------------------------------------
local function ApplyVisualStyle()
	ApplyTemplateToControl(ZO_CompanionOverview_Panel_Keyboard, "IJA_CompanionOverview_Panel_KeyboardTemplate")
end

function Companion_Overview:InitKeyboard()
	local panel = ZO_CompanionOverview_Panel_Keyboard
	local container = panel:GetNamedChild("RapportContainer")
	
	local scene = COMPANION_OVERVIEW_KEYBOARD_FRAGMENT
    scene:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_FRAGMENT_SHOWING then
			ApplyVisualStyle()
			container:GetNamedChild("Rapport"):SetText( GetString(SI_IJA_MCF_RAPPORTPROGRESS))
			container:GetNamedChild("Value"):SetText(getRapportValueString(GetActiveCompanionRapport()))
			panel:GetNamedChild("PassivePerkDescription"):SetText(GetAbilityDescription(ZO_COMPANION_MANAGER:GetActiveCompanionPassivePerkAbilityId()))
			
			local level, currentXpInLevel, totalXpInLevel, isMaxLevel = ZO_COMPANION_MANAGER:GetLevelInfo()
			
			local xpString
			if isMaxLevel then
				xpString = GetString(SI_EXPERIENCE_LIMIT_REACHED)
			else
				xpString = zo_strformat(SI_EXPERIENCE_CURRENT_MAX_PERCENT, ZO_CommaDelimitNumber(currentXpInLevel), ZO_CommaDelimitNumber(totalXpInLevel), getRapportPercent(currentXpInLevel, totalXpInLevel))
			end
			
			panel:GetNamedChild("LevelProgressLabel"):SetText(xpString)
		end
	end)
	self.kbRapportInitialized = true
end

---------------------------------------------------------------------------------------------------------------
-- Gamepad
---------------------------------------------------------------------------------------------------------------
function Companion_Overview:InitGamepad()
	local RAPPORT_GRADIENT_START = ZO_ColorDef:New("722323") --Red
	local RAPPORT_GRADIENT_END = ZO_ColorDef:New("009966") --Green
	local RAPPORT_GRADIENT_MIDDLE = ZO_ColorDef:New("9D840D") --Yellow
	
	ZO_TOOLTIP_STYLES.companionStatValuePair = {
		height = 40,
		statValuePairSpacing = 8,
		childSecondarySpacing = 3,
		childSpacing = 80,
		widthPercent = 100,
		layoutPrimaryDirection = "right",
		layoutSecondaryDirection = "down",
		layoutPrimaryDirectionCentered = true,
		horizontalAlignment = 0,
	}

	function ZO_Tooltip:LayoutCompanionOverview(companionData)
		--Section containing the numerical XP Progress
		local xpProgressSection = self:AcquireSection(self:GetStyle("companionXpProgressSection"))
		local xpProgressStatValuePair = xpProgressSection:AcquireStatValuePair(self:GetStyle("statValuePair"))
		xpProgressStatValuePair:SetStat(GetString(SI_STAT_GAMEPAD_EXPERIENCE_LABEL), self:GetStyle("statValuePairStat"))

		--Status bar representing the xp progress values
		local xpBar = self:AcquireStatusBar(self:GetStyle("companionXpBar"))

		--This is not used for companions so just hide it
		xpBar:GetNamedChild("EnlightenedBar"):SetHidden(true)

		--First, grab the level information for this companion
		local level, currentXpInLevel, totalXpInLevel, isMaxLevel = ZO_COMPANION_MANAGER:GetLevelInfo()

		if isMaxLevel then
			--If the companion is at max level, we show something different
			xpProgressStatValuePair:SetValue(GetString(SI_EXPERIENCE_LIMIT_REACHED), self:GetStyle("statValuePairValue"))

			--Since the companion is at max level, we want the bar to be totally filled, so just set something arbitrary to reflect that
			xpBar:SetMinMax(0, 1)
			xpBar:SetValue(1)
		else
			--Calculate the percentage value for the companion's current experience, and then populate both the bar and xp progress values
			local percentageXp = zo_floor(currentXpInLevel / totalXpInLevel * 100) 
			xpProgressStatValuePair:SetValue(zo_strformat(SI_EXPERIENCE_CURRENT_MAX_PERCENT, ZO_CommaDelimitNumber(currentXpInLevel), ZO_CommaDelimitNumber(totalXpInLevel), percentageXp), self:GetStyle("statValuePairValue"))
			xpBar:SetMinMax(0, totalXpInLevel)
			xpBar:SetValue(currentXpInLevel)
		end

		xpProgressSection:AddStatValuePair(xpProgressStatValuePair)

		self:AddSection(xpProgressSection)
		self:AddStatusBar(xpBar)

		local passivePerkId = ZO_COMPANION_MANAGER:GetActiveCompanionPassivePerkAbilityId()

		--Section containing the name of the companion's passive perk ability
		local passivePerkTitleSection = self:AcquireSection(self:GetStyle("companionOverviewStatValueSection"))
		local passivePerkPair = passivePerkTitleSection:AcquireStatValuePair(self:GetStyle("statValuePair"))
		passivePerkPair:SetStat(GetString(SI_COMPANION_OVERVIEW_PERK), self:GetStyle("statValuePairStat"))

		local formattedPerkName = ZO_CachedStrFormat(SI_ABILITY_NAME, GetAbilityName(passivePerkId))
		passivePerkPair:SetValue(formattedPerkName, self:GetStyle("statValuePairValue"))
		passivePerkTitleSection:AddStatValuePair(passivePerkPair)
		self:AddSection(passivePerkTitleSection)

		--Section containing the description of the companion's passive perk ability
		local formattedPerkDescription = GetAbilityDescription(passivePerkId)
		local passivePerkBodySection = self:AcquireSection(self:GetStyle("companionOverviewBodySection"))
		passivePerkBodySection:AddLine(formattedPerkDescription, self:GetStyle("companionOverviewDescription"))
		self:AddSection(passivePerkBodySection)

		-- Grab the rapport information for the active companion
		local rapportValue = GetActiveCompanionRapport()
		local rapportLevel = GetActiveCompanionRapportLevel()
		local rapportDescription = GetActiveCompanionRapportLevelDescription(rapportLevel)

		--Section containing the player's current rapport level with the companion
		local rapportStatusSection = self:AcquireSection(self:GetStyle("companionOverviewStatValueSection"))
		local rapportStatusPair = rapportStatusSection:AcquireStatValuePair(self:GetStyle("statValuePair"))
		rapportStatusPair:SetStat(GetString(SI_Companion_Overview_STATUS), self:GetStyle("statValuePairStat"))
		rapportStatusPair:SetValue(GetString("SI_COMPANIONRAPPORTLEVEL", rapportLevel), self:GetStyle("statValuePairValue"))
		rapportStatusSection:AddStatValuePair(rapportStatusPair)
		self:AddSection(rapportStatusSection)

		--Section containing the rapport bar
		local rapportBarSection = self:AcquireSection(self:GetStyle("companionRapportBarSection"))

		--The rapport bar is a special type of status bar, so we have to create as a custom control and set it up manually
		local rapportBarControl = self:AcquireCustomControl(self:GetStyle("companionRapportBar"))
		local rapportBar = ZO_SlidingStatusBar:New(rapportBarControl)
		rapportBar:SetGradientColors(RAPPORT_GRADIENT_START, RAPPORT_GRADIENT_END, RAPPORT_GRADIENT_MIDDLE)
		rapportBar:SetMinMax(GetMinimumRapport(), GetMaximumRapport())
		rapportBar:SetValue(rapportValue)

		local rapportValuePair = rapportBarSection:AcquireStatValuePair(self:GetStyle("companionStatValuePair"))
		rapportValuePair:SetStat(GetString(SI_IJA_MCF_RAPPORTPROGRESS), self:GetStyle("statValuePairStat"))
		rapportValuePair:SetValue(getRapportValueString(rapportValue), self:GetStyle("statValuePairValue"))
		rapportBarSection:AddStatValuePair(rapportValuePair)
		
		--Add the rapport bar in between the two rapport icons
		rapportBarSection:AddTexture("EsoUI/Art/HUD/lootHistory_icon_rapportDecrease.dds", self:GetStyle("companionRapportTexture"))
		rapportBarSection:AddCustomControl(rapportBarControl)
		rapportBarSection:AddTexture("EsoUI/Art/HUD/lootHistory_icon_rapportIncrease.dds", self:GetStyle("companionRapportTexture"))
		self:AddSection(rapportBarSection)

		--Section containing the description for the companion's current rapport level
		local rapportBodySection = self:AcquireSection(self:GetStyle("companionOverviewBodySection"))
		rapportBodySection:AddLine(rapportDescription, self:GetStyle("companionOverviewDescription"))
		self:AddSection(rapportBodySection)
	end

	self.gpRapportInitialized = true
end

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
function Companion_Overview:PerformDeferredInitialization()
	self.kbRapportInitialized = false
	self.gpRapportInitialized = false
	
	local function OnGamepadPreferredModeChanged()
		local gamepadMode = IsInGamepadPreferredMode()
		
		if gamepadMode then
			if not self.gpRapportInitialized then self:InitGamepad() end
		else
			if not self.kbRapportInitialized then self:InitKeyboard() end
		end
	end
	ZO_PlatformStyle:New(OnGamepadPreferredModeChanged)
end

---------------------------------------------------------------------------------------------------------------
function IJA_CompanionOverview_Initialize(parent)
	return Companion_Overview:New(parent)
end
