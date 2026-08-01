BSCCompanionInfoExtension = BSCCompanionInfoExtension or {}
local BSCCOIN_EX = BSCCompanionInfoExtension
local BSCCOIN = BSCCompainionInfo

local optionsTable = {}

local skillLineTable = {}
BSCCOIN_EX.SkillLineTable = skillLineTable
local skillLineChoices = { "Equipped weapon", "Equipped armor" }

local function AddDivider(control)
	table.insert(control, {
		type = "divider",
	})
end

local function AddBasicSetting()
	table.insert(optionsTable, {
        type = "header",
		name = "UI Settings",
    })	
    table.insert(optionsTable, {
		type = "checkbox",
		name = "Display Companion DPS",
		tooltip = "Companion DPS is updated when the companion deals damage or combat ends. Very bare-bones :)",
		getFunc = function() return BSCCOIN_EX.SV.DPS_BAR_SHOW end,
		setFunc = function(v) 
			BSCCOIN_EX.SV.DPS_BAR_SHOW = v
			BSCCOIN:UpdateUISettings()
		end,
	})
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Display Rapport Bar/Number",
		getFunc = function() return BSCCOIN_EX.SV.RAPPORT_BAR_SHOW end,
		setFunc = function(v) 
			BSCCOIN_EX.SV.RAPPORT_BAR_SHOW = v
			BSCCOIN:UpdateUISettings()
		end,
	})
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Custom XP bars to show", 
		requiresReload = true,
        choices = { 0, 1, 2, 3, 4, 5 },
		getFunc = function()
			return BSCCOIN_EX.SV.CUSTOM_XP_BARS_NUMBER
		end,
		setFunc = function(v) 
			BSCCOIN_EX.SV.CUSTOM_XP_BARS_NUMBER = v
			--BSCCOIN:UpdateUISettings()
		end,
        width = "full",
	})
end

local function AddRapportSetting()
	table.insert(optionsTable, {
        type = "header",
		name = "Rapport Settings",
    })	
    table.insert(optionsTable, {
		type = "colorpicker",
		name = "Color Rapport bar",
		tooltip = "",
		getFunc = function() return unpack(BSCCOIN_EX.SV.RAPPORT_BAR_COLOR) end,	--(alpha is optional)
		setFunc = function(r,g,b,a) 
			BSCCOIN_EX.SV.RAPPORT_BAR_COLOR = {r, g, b, a}
			BSCCOIN_EX.RapportControls.StatusBarControl:SetColor(r, g, b, a)
			--BSCCOIN:UpdateUISettings()
		end,	--(alpha is optional)
        width = "full",
	})
end

local function AddXpBarSubMenus()
	for i = 1, BSCCOIN_EX.SV.CUSTOM_XP_BARS_NUMBER do
		local controls = {}

		table.insert(controls, {
			type = "dropdown",
			name = "Companion skill line", 
			tooltip = "",
	        choices = skillLineChoices,
			getFunc = function()
				return BSCCOIN_EX.SV.CUSTOM_XP_BARS[i].SKILL_LINE
			end,
			setFunc = function(v) 
				local skillLineId = BSCCOIN_EX:GetCompanionSkillLineIdByName(v)

				BSCCOIN_EX.SV.CUSTOM_XP_BARS[i].SKILL_LINE = v
				BSCCOIN_EX:UpdateXpControlSkillLine(BSCCOIN_EX.XPControls[i], skillLineId)
				--BSCCOIN:UpdateUISettings()
			end,
	        width = "full",
		})

		table.insert(controls, {
			type = "colorpicker",
			name = "Color",
			tooltip = "",
			getFunc = function() return unpack(BSCCOIN_EX.SV.CUSTOM_XP_BARS[i].COLOR) end,	--(alpha is optional)
			setFunc = function(r,g,b,a) 
				BSCCOIN_EX.SV.CUSTOM_XP_BARS[i].COLOR = {r, g, b, a}
				BSCCOIN_EX.XPControls[i].StatusBarControl:SetGradientColors(r, g, b, a, r, g, b, a)
				--BSCCOIN:UpdateUISettings()
			end,	--(alpha is optional)
	        width = "full",
		})

		table.insert(optionsTable, {
			type = "submenu",
			name = "Custom XP Bar "..i,
			controls = controls
		})
	end
end

local function LoadCompanionSkillLines()
	for i=174,191,1 
		do 
			local skillLineName = GetSkillLineNameById(i)
			table.insert(skillLineChoices, skillLineName)
			skillLineTable[skillLineName] = i
		end
	for i=196,198,1 
		do 
			local skillLineName = GetSkillLineNameById(i)
			table.insert(skillLineChoices, skillLineName)
			skillLineTable[skillLineName] = i
		end
	for i=200,202,1 
		do 
			local skillLineName = GetSkillLineNameById(i)
			table.insert(skillLineChoices, skillLineName)
			skillLineTable[skillLineName] = i
		end
	for i=241,243,1 
		do 
			local skillLineName = GetSkillLineNameById(i)
			table.insert(skillLineChoices, skillLineName)
			skillLineTable[skillLineName] = i
		end
end

function BSCCOIN_EX:GetCompanionSkillLineIdByName(skillLineName)
	local skillLineId = nil

	if (skillLineName == "Equipped weapon") then
		skillLineId = BSCCOIN_EX:GetSkillLineIdFromWeaponType()
	elseif (skillLineName == "Equipped armor") then 
		skillLineId = BSCCOIN_EX:GetSkillLineFromCompanionArmorPieces() 
	else
		skillLineId = skillLineTable[skillLineName]
	end

	return skillLineId
end

function BSCCOIN_EX:InitMenu()
	-- the panel for the addons menu
	local panelData = {
		type = "panel",
		name = BSCCOIN_EX.NameMenu,
		displayName = BSCCOIN_EX.NameSpaced,
		author = BSCCOIN_EX.Author,
		version = BSCCOIN_EX.VersionDisplay,
		registerForRefresh = true,
		slashCommand = "/cuiesettings"
	}

	LoadCompanionSkillLines()

	AddBasicSetting()
	AddRapportSetting()
	AddXpBarSubMenus()

    local addonpanel = LibAddonMenu2:RegisterAddonPanel(BSCCOIN_EX.NameSpaced, panelData)
    LibAddonMenu2:RegisterOptionControls(BSCCOIN_EX.NameSpaced, optionsTable)
		
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", 
		function(currentpanel) 
			if addonpanel == currentpanel then 				
				BSCCompainionInfoUI:SetHidden(false) 
			end 
		end )
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", 
		function(currentpanel) 
			if addonpanel == currentpanel then 								
				BSCCompainionInfoUI:SetHidden(true) 
			end 
		end )
end