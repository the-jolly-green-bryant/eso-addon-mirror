-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////// --- Locals -- /////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////


BSCCompanionInfoExtension = BSCCompanionInfoExtension or {}
local BSCCOIN_EX = BSCCompanionInfoExtension
local BSCCOIN = BSCCompainionInfo
BSCCOIN_EX.UIInitialized = false

local defaultSV = {
	CUSTOM_XP_BARS_NUMBER = 2,
	DPS_BAR_SHOW = true,
	RAPPORT_BAR_SHOW = true,
	RAPPORT_BAR_COLOR = { 0, 0.0470588244, 0.4196078479, 1 },
	CUSTOM_XP_BARS = {
		[1] = {
			["SKILL_LINE"] = "Equipped weapon",
			["COLOR"] = { 0, 0.0470588244, 0.4196078479, 1 }
		},
		[2] = {
			["SKILL_LINE"] = "Equipped armor",
			["COLOR"] = { 0, 0.2980392277, 0.0666666701, 1 },
		},
		[3] = {
			["SKILL_LINE"] = "Equipped weapon",
			["COLOR"] = { 0, 0.0470588244, 0.4196078479, 1 }
		},
		[4] = {
			["SKILL_LINE"] = "Equipped armor",
			["COLOR"] = { 0, 0.2980392277, 0.0666666701, 1 },
		},
		[5] = {
			["SKILL_LINE"] = "Equipped weapon",
			["COLOR"] = { 0, 0.0470588244, 0.4196078479, 1 }
		},
	}
}
local damageReport = {
	totalDamage = 0,
	DPS = 0
}

-- Addon data
BSCCOIN_EX.Name = "BSCs-CompanionInfoExtension"
BSCCOIN_EX.NameSpaced = "BloodStainChild666's Companion Info - Extension"
BSCCOIN_EX.NameMenu = "BSCs-CompanionUI-Extension"
BSCCOIN_EX.Author = "@DoonerSeraph"
BSCCOIN_EX.Version = 1
BSCCOIN_EX.SavedVar = "BSCCompanionInfoExtensionsSavedVariables"
BSCCOIN_EX.VersionDisplay = "2.0.3"

--Controls
BSCCOIN_EX.XPControls = {}
BSCCOIN_EX.DPSControls = {}
BSCCOIN_EX.RapportControls = {}

-- Original Addon functions - Set at load

local originalUpdateUISettings = BSCCOIN.UpdateUISettings;

-- Private functions

local function PackRGBA(r, g, b, a)
	return {
		r = r,
		g = g,
		b = b,
		a = a
	}
end

local function UnpackRGBA(color)
	return color.r, color.g, color.b, color.a
end

local function PackRGBAVar(colorVariable)
	return {
		r = colorVariable[1],
		g = colorVariable[2],
		b = colorVariable[3],
		a = colorVariable[4]
	}
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

local function UpdateXPUI(xpControls)
	if xpControls == nil or xpControls.StatusBarControl == nil then return end
	local skillLineId = xpControls.SkillLineId
	if HasActiveCompanion() then		
		local level, _, _ = GetCompanionSkillLineDynamicInfo(skillLineId)
		local lastRankXP, nextRankXP, currentXP = GetCompanionSkillLineXPInfo(skillLineId)
		local destroXpInLevel = currentXP - lastRankXP
		local destroTotalXpInLevel = nextRankXP - lastRankXP	
		local forceRefresh = true
        local shouldNotWrap = forceRefresh		
        
		--xpControls.StatusBarControl:SetValue(destroLevel, destroXpInLevel, destroTotalXpInLevel, shouldNotWrap, forceRefresh)
		local percentageXp = zo_floor(destroXpInLevel / destroTotalXpInLevel * 100)  		
		xpControls.ExpInfoControl:SetText(zo_strformat("LV <<1>> : ", level)..zo_strformat(SI_EXPERIENCE_CURRENT_MAX_PERCENT, ZO_CommaDelimitNumber(destroXpInLevel), ZO_CommaDelimitNumber(destroTotalXpInLevel), percentageXp))

		xpControls.StatusBarControl:SetDimensions(math.ceil((destroXpInLevel / destroTotalXpInLevel) * (BSCCOIN.SV.UI_WIDTH))+1,BSCCOIN.SV.UI_HIGHT_XPBAR-2)
	end
end

local function UpdateXP()
	for i=1, BSCCOIN_EX.SV.CUSTOM_XP_BARS_NUMBER do
		UpdateXPUI(BSCCOIN_EX.XPControls[i])
	end
end

function BSCCOIN_EX:UpdateXpControlSkillLine(controls, skillLineId)
	controls.SkillLineId = skillLineId
	UpdateXPUI(controls)
end

local function UpdateRapportBar()
	if HasActiveCompanion() then
		local rapport = GetActiveCompanionRapport()
		BSCCOIN_EX.RapportControls.RapportInfoControl:SetText(zo_strformat("Rapport: <<1>>", rapport))

		--d(zo_strformat("Percent rapport: <<1>>", ((rapport + 5000)/(5500+5000))))
		--BSCCOIN_EX.RapportControls.StatusBarControl:SetValue(((rapport + 5000)/(5500+5000)) * 100)
		BSCCOIN_EX.RapportControls.StatusBarControl:SetValue(((rapport + 5000)/(5500+5000)))
	end
end

local function AddExtraXPBarToOriginalUI(xpControls, backdropName, anchorTo, centerColorRGBA, edgeColorRGBA, barColorRGBA1, barColorRGBA2)
	local backDropControl = BSCCompainionInfoUI:CreateControl(backdropName, CT_BACKDROP) -- See http://wiki.esoui.com/Globals#ControlType
	local expInfoControl = backDropControl:CreateControl(backdropName..'ExpInfo', CT_LABEL)
	local statusBarControl = backDropControl:CreateControl(backdropName..'ExpBar', CT_STATUSBAR)
	ApplyTemplateToControl(backDropControl, "BDXP_TEMPLATE")

	backDropControl:ClearAnchors()
	backDropControl:SetAnchor(TOPLEFT, anchorTo, BOTTOMLEFT, 0, 0)
	xpControls.hidden = false
	xpControls.anchor = anchorTo

	local r1, g1, b1, a1 = UnpackRGBA(barColorRGBA1)
	local r2, g2, b2, a2 = UnpackRGBA(barColorRGBA2)
	statusBarControl:SetGradientColors(r1, g1, b1, a1, r2, g2, b2, a2)

	-- Size and font
	backDropControl:SetDimensions(BSCCOIN.SV.UI_WIDTH, BSCCOIN.SV.UI_HIGHT_XPBAR)
	statusBarControl:SetDimensions(BSCCOIN.SV.UI_WIDTH-2, BSCCOIN.SV.UI_HIGHT_XPBAR-2)
	expInfoControl:SetFont(GetFont(BSCCOIN.SV.XPBAR_FONT, BSCCOIN.SV.XPBAR_FONT_SIZE, BSCCOIN.SV.XPBAR_FONT_STYLE))

	return backDropControl, expInfoControl, statusBarControl
end

local function AddExtraXpBars()
	local level, currentXpInLevel, totalXpInLevel, isMaxLevel = ZO_COMPANION_MANAGER:GetLevelInfo()
	if level <= 0 then isMaxLevel = false end

	local anchorTo = BSCCompainionInfoUI:GetNamedChild('HPBackdrop')

	if (isMaxLevel == false and BSCCOIN.SV.DISPLAY_EXPBAR) then
		anchorTo = BSCCompainionInfoUI:GetNamedChild('BDXPB')
	end

	if (BSCCOIN.SV.DISPLAY_SKILLS) then
		anchorTo = BSCCompainionInfoUI:GetNamedChild('SKillInfo')
	end

	for i=1, BSCCOIN_EX.SV.CUSTOM_XP_BARS_NUMBER do
		BSCCOIN_EX.XPControls[i] = {}

		BSCCOIN_EX.XPControls[i].BackDropControl,
		BSCCOIN_EX.XPControls[i].ExpInfoControl, 
		BSCCOIN_EX.XPControls[i].StatusBarControl = AddExtraXPBarToOriginalUI(BSCCOIN_EX.XPControls[i], 
																									'BD_CUSTOM_XP_'..i,
																									anchorTo,
																									PackRGBA(0, 0, 0, 0.6), 
																									PackRGBA(255, 255, 255, 0.6), 
																									PackRGBAVar(BSCCOIN_EX.SV.CUSTOM_XP_BARS[i].COLOR), 
																									PackRGBAVar(BSCCOIN_EX.SV.CUSTOM_XP_BARS[i].COLOR))
		BSCCOIN_EX.XPControls[i].SkillLineId = BSCCOIN_EX:GetCompanionSkillLineIdByName(BSCCOIN_EX.SV.CUSTOM_XP_BARS[i].SKILL_LINE)
		UpdateXPUI(BSCCOIN_EX.XPControls[i])
		anchorTo = BSCCOIN_EX.XPControls[i].BackDropControl

	end
end

local function AddDPSBarToExtraXPBar(backdropName, anchorTo)
	local backDropControl = BSCCompainionInfoUI:CreateControl(backdropName, CT_BACKDROP) -- See http://wiki.esoui.com/Globals#ControlType
	local dpsInfoControl = backDropControl:CreateControl(backdropName..'DPSInfo', CT_LABEL)
	ApplyTemplateToControl(backDropControl, "DPS_TEMPLATE")
	backDropControl:ClearAnchors()
	backDropControl:SetAnchor(TOPLEFT, anchorTo, BOTTOMLEFT, 0, 0)

	-- Size and font
	backDropControl:SetDimensions(BSCCOIN.SV.UI_WIDTH, BSCCOIN.SV.UI_HIGHT_XPBAR)
	dpsInfoControl:SetDimensions(BSCCOIN.SV.UI_WIDTH-2, BSCCOIN.SV.UI_HIGHT_XPBAR-2)
	dpsInfoControl:SetFont(GetFont(BSCCOIN.SV.XPBAR_FONT, BSCCOIN.SV.XPBAR_FONT_SIZE, BSCCOIN.SV.XPBAR_FONT_STYLE))

	return backDropControl, dpsInfoControl
end

local function AddRapportBar(backdropName, anchorTo)
	local backDropControl = BSCCompainionInfoUI:CreateControl(backdropName, CT_BACKDROP) -- See http://wiki.esoui.com/Globals#ControlType
	local rapportInfoControl = backDropControl:CreateControl(backdropName..'RapportInfo', CT_LABEL)
	local statusBarControl = backDropControl:CreateControl(backdropName..'RapportBar', CT_STATUSBAR)
	ApplyTemplateToControl(backDropControl, "RAPPORT_TEMPLATE")

	backDropControl:ClearAnchors()
	backDropControl:SetAnchor(TOPLEFT, anchorTo, BOTTOMLEFT, 0, 0)
	statusBarControl:SetColor(UnpackRGBA(PackRGBAVar(BSCCOIN_EX.SV.RAPPORT_BAR_COLOR)))

	--Size and font
	backDropControl:SetDimensions(BSCCOIN.SV.UI_WIDTH, BSCCOIN.SV.UI_HIGHT_XPBAR)
	rapportInfoControl:SetDimensions(BSCCOIN.SV.UI_WIDTH-2, BSCCOIN.SV.UI_HIGHT_XPBAR-2)
	statusBarControl:SetDimensions(BSCCOIN.SV.UI_WIDTH-2, BSCCOIN.SV.UI_HIGHT_XPBAR-2)
	rapportInfoControl:SetFont(GetFont(BSCCOIN.SV.XPBAR_FONT, BSCCOIN.SV.XPBAR_FONT_SIZE, BSCCOIN.SV.XPBAR_FONT_STYLE))

	return backDropControl, rapportInfoControl, statusBarControl
end

local function InitUI()
	AddExtraXpBars()
	
	local anchorTo = BSCCompainionInfoUI:GetNamedChild('HPBackdrop')

	if (BSCCOIN.SV.DISPLAY_SKILLS) then
		anchorTo = BSCCompainionInfoUI:GetNamedChild('SKillInfo')
	end

	if (BSCCOIN_EX.SV.CUSTOM_XP_BARS_NUMBER > 0) then
		anchorTo = BSCCOIN_EX.XPControls[BSCCOIN_EX.SV.CUSTOM_XP_BARS_NUMBER].BackDropControl
	end

	BSCCOIN_EX.DPSControls.BackDropControl,
	BSCCOIN_EX.DPSControls.DpsInfoControl = AddDPSBarToExtraXPBar("DPS_INFO",
																						anchorTo)
	BSCCOIN_EX.RapportControls.BackDropControl,
	BSCCOIN_EX.RapportControls.RapportInfoControl,
	BSCCOIN_EX.RapportControls.StatusBarControl = AddRapportBar("RAPPORT_INFO",
																					BSCCOIN_EX.DPSControls.BackDropControl)

	if (BSCCOIN_EX.SV.DPS_BAR_SHOW == false) then
		BSCCOIN_EX.DPSControls.BackDropControl:SetHidden(true)
		BSCCOIN_EX.RapportControls.BackDropControl:ClearAnchors()
		BSCCOIN_EX.RapportControls.BackDropControl:SetAnchor(TOPLEFT, anchorTo, BOTTOMLEFT, 0, 00)
	end

	if (BSCCOIN_EX.SV.RAPPORT_BAR_SHOW == false) then
		BSCCOIN_EX.RapportControls.BackDropControl:SetHidden(true)
	end

	UpdateXP()
	UpdateRapportBar()
	BSCCOIN:UpdateUISettings()
	BSCCOIN_EX.UIInitialized = true
end

function BSCCOIN:UpdateUISettings()
	-- Execute original functions
	originalUpdateUISettings()

	local level, currentXpInLevel, totalXpInLevel, isMaxLevel = ZO_COMPANION_MANAGER:GetLevelInfo()
	if level <= 0 then isMaxLevel = false end

	-- Simple check to prevent the function from running if the new UI is not initialized yet
	if (BSCCOIN_EX.UIInitialized == false) then return end

	local anchorTo = BSCCompainionInfoUI:GetNamedChild('HPBackdrop')

	if (isMaxLevel == false and BSCCOIN.SV.DISPLAY_EXPBAR) then
		anchorTo = BSCCompainionInfoUI:GetNamedChild('BDXPB')
	end

	if (BSCCOIN.SV.DISPLAY_SKILLS) then
		anchorTo = BSCCompainionInfoUI:GetNamedChild('SKillInfo')
	end

	if (BSCCOIN_EX.SV.CUSTOM_XP_BARS_NUMBER > 0) then
		-- Re-anchors XP bars
		BSCCOIN_EX.XPControls[1].BackDropControl:ClearAnchors()
		BSCCOIN_EX.XPControls[1].BackDropControl:SetAnchor(TOPLEFT, anchorTo, BOTTOMLEFT, 0, 0)
		anchorTo = BSCCOIN_EX.XPControls[BSCCOIN_EX.SV.CUSTOM_XP_BARS_NUMBER].BackDropControl
	end

	for i=1, BSCCOIN_EX.SV.CUSTOM_XP_BARS_NUMBER do
		if (BSCCOIN_EX.XPControls[i] == nil) then break end
		BSCCOIN_EX.XPControls[i].BackDropControl:SetDimensions(BSCCOIN.SV.UI_WIDTH, BSCCOIN.SV.UI_HIGHT_XPBAR)
		BSCCOIN_EX.XPControls[i].StatusBarControl:SetDimensions(BSCCOIN.SV.UI_WIDTH-2, BSCCOIN.SV.UI_HIGHT_XPBAR-2)
		BSCCOIN_EX.XPControls[i].ExpInfoControl:SetFont(GetFont(BSCCOIN.SV.XPBAR_FONT, BSCCOIN.SV.XPBAR_FONT_SIZE, BSCCOIN.SV.XPBAR_FONT_STYLE))
	end

	BSCCOIN_EX.DPSControls.BackDropControl:SetDimensions(BSCCOIN.SV.UI_WIDTH, BSCCOIN.SV.UI_HIGHT_XPBAR)
	BSCCOIN_EX.DPSControls.DpsInfoControl:SetDimensions(BSCCOIN.SV.UI_WIDTH-2, BSCCOIN.SV.UI_HIGHT_XPBAR-2)
	BSCCOIN_EX.DPSControls.DpsInfoControl:SetFont(GetFont(BSCCOIN.SV.XPBAR_FONT, BSCCOIN.SV.XPBAR_FONT_SIZE, BSCCOIN.SV.XPBAR_FONT_STYLE))

	BSCCOIN_EX.RapportControls.BackDropControl:SetDimensions(BSCCOIN.SV.UI_WIDTH, BSCCOIN.SV.UI_HIGHT_XPBAR)
	BSCCOIN_EX.RapportControls.StatusBarControl:SetDimensions(BSCCOIN.SV.UI_WIDTH-2, BSCCOIN.SV.UI_HIGHT_XPBAR-2)
	BSCCOIN_EX.RapportControls.RapportInfoControl:SetDimensions(BSCCOIN.SV.UI_WIDTH-2, BSCCOIN.SV.UI_HIGHT_XPBAR-2)
	BSCCOIN_EX.RapportControls.RapportInfoControl:SetFont(GetFont(BSCCOIN.SV.XPBAR_FONT, BSCCOIN.SV.XPBAR_FONT_SIZE, BSCCOIN.SV.XPBAR_FONT_STYLE))

	if (BSCCOIN_EX.SV.DPS_BAR_SHOW == false) then
		BSCCOIN_EX.DPSControls.BackDropControl:SetHidden(true)
		BSCCOIN_EX.RapportControls.BackDropControl:ClearAnchors()
		BSCCOIN_EX.RapportControls.BackDropControl:SetAnchor(TOPLEFT, anchorTo, BOTTOMLEFT, 0, 0)
	else
		BSCCOIN_EX.DPSControls.BackDropControl:SetHidden(false)
		BSCCOIN_EX.RapportControls.BackDropControl:ClearAnchors()
		BSCCOIN_EX.RapportControls.BackDropControl:SetAnchor(TOPLEFT, BSCCOIN_EX.DPSControls.BackDropControl, BOTTOMLEFT, 0, 0)
	end

	if (BSCCOIN_EX.SV.RAPPORT_BAR_SHOW == false) then
		BSCCOIN_EX.RapportControls.BackDropControl:SetHidden(true)
	else
		BSCCOIN_EX.RapportControls.BackDropControl:SetHidden(false)
	end

	UpdateXP()
end

local function StartNewReport()
	damageReport.totalDamage = 0
	damageReport.startTime = GetGameTimeSeconds()
	damageReport.endtime = 0
	damageReport.DPS = 0
end

local function UpdateDPSControl()
	BSCCOIN_EX.DPSControls.DpsInfoControl:SetText(zo_strformat("DPS: <<1>>", damageReport.DPS));
end

local function UpdateDPS()
	if (damageReport.startTime == nil) then
		StartNewReport()
	end
	damageReport.DPS = damageReport.totalDamage/(GetGameTimeSeconds() - damageReport.startTime)
	UpdateDPSControl()
end

local function EndReport()
	damageReport.endtime = GetGameTimeSeconds()
	UpdateDPS()
	--d(damageReport)
end

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////// --- Event Handlers -- /////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local function OnSlotUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange)
	if not HasActiveCompanion() then return end
   if bagId == BAG_COMPANION_WORN and updateReason == INVENTORY_UPDATE_REASON_DEFAULT then
   	if (slotIndex == EQUIP_SLOT_MAIN_HAND or slotIndex == EQUIP_SLOT_OFF_HAND) then

    		for i=1, BSCCOIN_EX.SV.CUSTOM_XP_BARS_NUMBER do
				if (BSCCOIN_EX.SV.CUSTOM_XP_BARS[i].SKILL_LINE == "Equipped weapon") then
					BSCCOIN_EX.XPControls[i].SkillLineId = BSCCOIN_EX:GetSkillLineIdFromWeaponType()
					--d(BSCCOIN_EX.XPControls[i].SkillLineId)
					UpdateXPUI(BSCCOIN_EX.XPControls[i])
				end
			end

    	else

 			for i=1, BSCCOIN_EX.SV.CUSTOM_XP_BARS_NUMBER do
				if (BSCCOIN_EX.SV.CUSTOM_XP_BARS[i].SKILL_LINE == "Equipped armor") then
					BSCCOIN_EX.XPControls[i].SkillLineId = BSCCOIN_EX:GetSkillLineFromCompanionArmorPieces()
					UpdateXPUI(BSCCOIN_EX.XPControls[i])
				end
			end

    	end
   end
end

local function OnPlayerFirstActivated()
	EVENT_MANAGER:UnregisterForEvent(BSCCOIN_EX.Name,EVENT_PLAYER_ACTIVATED);
	InitUI()
	EVENT_MANAGER:RegisterForEvent(BSCCOIN_EX.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnSlotUpdate)
	EVENT_MANAGER:AddFilterForEvent(BSCCOIN_EX.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_COMPANION_WORN)
	EVENT_MANAGER:RegisterForEvent(BSCCOIN_EX.Name, EVENT_COMPANION_SKILL_XP_UPDATE, UpdateXP)
end

local function OnPlayerActivated()
	if not DoesUnitExist("companion") or not HasActiveCompanion() then
		BSCCompainionInfoUI:SetHidden(true)
	else
		BSCCompainionInfoUI:SetHidden(false)
	end
	UpdateXP()
	BSCCOIN:InitSkillBarIcons()
end

local function WaitForCompanion()

	for i=1, BSCCOIN_EX.SV.CUSTOM_XP_BARS_NUMBER do
		if (BSCCOIN_EX.XPControls ~= nil and BSCCOIN_EX.XPControls[i] ~= nil) then
			if (BSCCOIN_EX.SV.CUSTOM_XP_BARS[i].SKILL_LINE == "Equipped weapon") then
				BSCCOIN_EX.XPControls[i].SkillLineId = BSCCOIN_EX:GetSkillLineIdFromWeaponType()
			elseif (BSCCOIN_EX.SV.CUSTOM_XP_BARS[i].SKILL_LINE == "Equipped armor") then
				BSCCOIN_EX.XPControls[i].SkillLineId = BSCCOIN_EX:GetSkillLineFromCompanionArmorPieces()
			end
		end
	end

	UpdateXP()
	EVENT_MANAGER:UnregisterForUpdate("WaitForCompanion"..BSCCOIN_EX.Name)
end

local function OnCompanionActivated()
	--BSCCOIN_EX.ArmorXPControls.SkillLineId = BSCCOIN_EX:GetCompanionSkillLineIdByName(BSCCOIN_EX.SV.CUSTOM_XP_BAR_1_SKILL_LINE)
	--BSCCOIN_EX.WeaooponXPControls.SkillLineId = BSCCOIN_EX:GetCompanionSkillLineIdByName(BSCCOIN_EX.SV.CUSTOM_XP_BAR_2_SKILL_LINE)

	UpdateXP()
	UpdateRapportBar()
	BSCCOIN:InitSkillBarIcons()
	EVENT_MANAGER:RegisterForUpdate("WaitForCompanion"..BSCCOIN_EX.Name, 500, WaitForCompanion)
end

local function UpdateUI()
	--BSCCOIN_EX.ArmorXPControls.SkillLineId = BSCCOIN_EX:GetCompanionSkillLineIdByName(BSCCOIN_EX.SV.CUSTOM_XP_BAR_1_SKILL_LINE)
	--BSCCOIN_EX.WeaponXPControls.SkillLineId = BSCCOIN_EX:GetCompanionSkillLineIdByName(BSCCOIN_EX.SV.CUSTOM_XP_BAR_2_SKILL_LINE)

	for i=1, BSCCOIN_EX.SV.CUSTOM_XP_BARS_NUMBER do
		if (BSCCOIN_EX.XPControls ~= nil and BSCCOIN_EX.XPControls[i] ~= nil) then
			if (BSCCOIN_EX.SV.CUSTOM_XP_BARS[i].SKILL_LINE == "Equipped weapon") then
				BSCCOIN_EX.XPControls[i].SkillLineId = BSCCOIN_EX:GetSkillLineIdFromWeaponType()
			elseif (BSCCOIN_EX.SV.CUSTOM_XP_BARS[i].SKILL_LINE == "Equipped armor") then
				BSCCOIN_EX.XPControls[i].SkillLineId = BSCCOIN_EX:GetSkillLineFromCompanionArmorPieces()
			end
		end
	end

	UpdateXP()
	UpdateRapportBar()
	BSCCOIN:InitSkillBarIcons()
end

local function OnDamageDealt(eventCode,result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

	if (sourceUnitId == 0) then
		return
	end

	if sourceUnitId ~= 0 then
		if (LibUnitTracker:GetUnitNameByUnitId(sourceUnitId) == nil or LibUnitTracker:GetUnitNameByUnitId(sourceUnitId) ~= zo_strformat('<<1>>', GetCompanionName(GetActiveCompanionDefId()))) then return end
	end

	if (abilityName == nil or abilityName == "" or hitValue == nil or damageReport.totalDamage == nil) then
		return
	end

	--d(zo_strformat("[<<1>>] hits [<<2>>] for [<<3>>] damage with [<<4>>].", LibUnitTracker:GetUnitNameByUnitId(sourceUnitId), LibUnitTracker:GetUnitNameByUnitId(targetUnitId), hitValue, abilityName))
	damageReport.totalDamage = damageReport.totalDamage + hitValue
	UpdateDPS()
end

local function OnCombatState(eventCode, inCombat)
	if inCombat then
      --d("Combat started")
      StartNewReport()
   else
      --d("Combat ended")
      EndReport()
   end
end

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////// --- Init -- //////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function BSCCOIN_EX.init(event, addonName)	
	if addonName ~= BSCCOIN_EX.Name then
		return 
	end

	-- Saved Variables
	BSCCOIN_EX.SV = ZO_SavedVars:NewAccountWide(BSCCOIN_EX.SavedVar, BSCCOIN_EX.Version, nil, defaultSV)

	-- Menu
	BSCCOIN_EX:InitMenu()

	--Events for UI
	EVENT_MANAGER:UnregisterForEvent(BSCCOIN_EX.Name,EVENT_ADD_ON_LOADED);
	EVENT_MANAGER:RegisterForEvent(BSCCOIN_EX.Name, EVENT_PLAYER_ACTIVATED, OnPlayerFirstActivated)	
	EVENT_MANAGER:RegisterForEvent(BSCCOIN_EX.Name.."Secondary", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)	
	EVENT_MANAGER:RegisterForEvent(BSCCOIN_EX.Name, EVENT_COMPANION_ACTIVATED, OnCompanionActivated)

	-- Events for DPS counter
	EVENT_MANAGER:RegisterForEvent("OnCombatState"..BSCCOIN_EX.Name, EVENT_PLAYER_COMBAT_STATE, OnCombatState)

	EVENT_MANAGER:RegisterForEvent("OnDamageDealt"..BSCCOIN_EX.Name, EVENT_COMBAT_EVENT, OnDamageDealt)
	EVENT_MANAGER:AddFilterForEvent("OnDamageDealt"..BSCCOIN_EX.Name, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DAMAGE)
	EVENT_MANAGER:AddFilterForEvent("OnDamageDealt"..BSCCOIN_EX.Name, EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG, 'companion')

	EVENT_MANAGER:RegisterForEvent("OnDotDamageDealt"..BSCCOIN_EX.Name, EVENT_COMBAT_EVENT, OnDamageDealt)
	EVENT_MANAGER:AddFilterForEvent("OnDotDamageDealt"..BSCCOIN_EX.Name, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DOT_TICK)
	EVENT_MANAGER:AddFilterForEvent("OnDotDamageDealt"..BSCCOIN_EX.Name, EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG, 'companion')	

	-- Evests for rapport
	EVENT_MANAGER:RegisterForEvent("OnRapportUpdate"..BSCCOIN_EX.Name, EVENT_COMPANION_RAPPORT_UPDATE, UpdateRapportBar)

	--Wait for companion
	EVENT_MANAGER:RegisterForUpdate("WaitForCompanion"..BSCCOIN_EX.Name, 500, WaitForCompanion)
end

EVENT_MANAGER:RegisterForEvent(BSCCOIN_EX.Name, EVENT_ADD_ON_LOADED, BSCCOIN_EX.init)