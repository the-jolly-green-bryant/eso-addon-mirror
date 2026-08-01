RaidToolsGroupBuffs = {
	spc = 0,
	powass = 0,
	cp = 0
}

local ABILITY_POWERFUL_ASSAULT = 61771
local ABILITY_SPELLPOWERCURE = 66902
local ABILITY_COMBAT_PRAYER = 40094 -- Berserk: 62645, Ward: 62644, Resolve: 62643
local ABILITY_MINOR_BERSERK = 62636

SPC_INFO = {}
POWASS_INFO = {}
CP_INFO = {}

local cp_up = {} -- Combat Prayer
local is_valid_cp = {} -- Combat Prayer

function RaidToolsGroupBuffs.OnEffectChanged(_, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
	if not string.match(unitTag, 'group') then return end
	if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_FADED then
		--d(string.format('[%s] unit: %s (%s), ability: %s (%s)', changeType, unitName, unitTag, effectName, abilityId))
	end
	local is_dd, is_heal, is_tank = GetGroupMemberRoles(unitTag)
	if not RaidTools.storage.config.groupbuffs.only_dds or (RaidTools.storage.config.groupbuffs.only_dds and is_dd) then
		if abilityId == ABILITY_POWERFUL_ASSAULT then
			if changeType == EFFECT_RESULT_GAINED then
				RaidToolsGroupBuffs.powass = RaidToolsGroupBuffs.powass + 1
			elseif changeType == EFFECT_RESULT_FADED then
				RaidToolsGroupBuffs.powass = RaidToolsGroupBuffs.powass - 1
			end
			if RaidToolsGroupBuffs.powass < 0 or RaidToolsGroupBuffs.powass > 12 then RaidToolsGroupBuffs.powass = 0 end
		elseif abilityId == ABILITY_SPELLPOWERCURE then
			if changeType == EFFECT_RESULT_GAINED then
				RaidToolsGroupBuffs.spc = RaidToolsGroupBuffs.spc + 1
			elseif changeType == EFFECT_RESULT_FADED then
				RaidToolsGroupBuffs.spc = RaidToolsGroupBuffs.spc - 1
			end
			if RaidToolsGroupBuffs.spc < 0 or RaidToolsGroupBuffs.spc > 12 then RaidToolsGroupBuffs.spc = 0 end
		elseif abilityId == ABILITY_COMBAT_PRAYER then
			if changeType == EFFECT_RESULT_GAINED then
				is_valid_cp[unitName] = true
			elseif changeType == EFFECT_RESULT_FADED then
				is_valid_cp[unitName] = false
			end
		elseif abilityId == ABILITY_MINOR_BERSERK then
			if changeType == EFFECT_RESULT_GAINED and is_valid_cp[unitName] then
				RaidToolsGroupBuffs.cp = RaidToolsGroupBuffs.cp + 1
				cp_up[unitName] = true
			elseif changeType == EFFECT_RESULT_FADED and cp_up[unitName] then
				RaidToolsGroupBuffs.cp = RaidToolsGroupBuffs.cp - 1
				cp_up[unitName] = nil
			end
			if RaidToolsGroupBuffs.cp < 0 or RaidToolsGroupBuffs.cp > 12 then RaidToolsGroupBuffs.cp = 0 end
		end
	end
	RaidToolsGroupBuffs.Update()
end

-- RaidTools.storage.config.groupbuffs.only_dds
-- RaidTools.storage.config.groupbuffs.only_as_key_role

function RaidToolsGroupBuffs.Update()
	SPC_INFO.label:SetText('SPC: '..RaidToolsGroupBuffs.spc)
	POWASS_INFO.label:SetText('PFA: '..RaidToolsGroupBuffs.powass)
	CP_INFO.label:SetText(' CP: '..RaidToolsGroupBuffs.cp)
end

function RaidToolsGroupBuffs.Show()
	SPC_INFO.fragment:SetHiddenForReason("HideSPC_INFO", false)
	POWASS_INFO.fragment:SetHiddenForReason("HidePOWASS_INFO", false)
	CP_INFO.fragment:SetHiddenForReason("HideCP_INFO", false)
end


function RaidToolsGroupBuffs.Hide()
	SPC_INFO.fragment:SetHiddenForReason("HideSPC_INFO", true)
	POWASS_INFO.fragment:SetHiddenForReason("HidePOWASS_INFO", true)
	CP_INFO.fragment:SetHiddenForReason("HideCP_INFO", true)
end


function RaidToolsGroupBuffs.Init()
	CALLBACK_MANAGER:RegisterCallback("OnBossFightStart", function(boss, hardmode)
		cp_up = {}
		is_valid_cp = {}
		RaidToolsGroupBuffs.cp = 0
		RaidToolsGroupBuffs.spc = 0
		RaidToolsGroupBuffs.powass = 0
		local is_dd, is_heal, is_tank = GetPlayerRoles()
		if RaidTools.storage.config.groupbuffs.only_as_key_role then
			if not is_heal and not is_tank then return end
		end
		if RaidTools.storage.config.spc.active then
			SPC_INFO.fragment:SetHiddenForReason("HideSPC_INFO", false)
		end
		if RaidTools.storage.config.cp.active then
			CP_INFO.fragment:SetHiddenForReason("HideCP_INFO", false)
		end
		if RaidTools.storage.config.powass.active then
			POWASS_INFO.fragment:SetHiddenForReason("HidePOWASS_INFO", false)
		end
	end)

	CALLBACK_MANAGER:RegisterCallback("OnBossFightOver", function(boss)
		if RaidTools.storage.config.spc.active then
			SPC_INFO.fragment:SetHiddenForReason("HideSPC_INFO", true)
		end
		if RaidTools.storage.config.cp.active then
			CP_INFO.fragment:SetHiddenForReason("HideCP_INFO", true)
		end
		if RaidTools.storage.config.powass.active then
			POWASS_INFO.fragment:SetHiddenForReason("HidePOWASS_INFO", true)
		end
	end)
	RaidToolsGroupBuffs.BuildUI()
end

function RaidToolsGroupBuffs.BuildUI()
	local function OnSPCMoved()
		RaidTools.storage.config.spc.x = SPC_INFO:GetLeft()
		RaidTools.storage.config.spc.y = SPC_INFO:GetTop()
	end
	local function OnPFAMoved()
		RaidTools.storage.config.powass.x = POWASS_INFO:GetLeft()
		RaidTools.storage.config.powass.y = POWASS_INFO:GetTop()
	end
	local function OnCPMoved()
		RaidTools.storage.config.cp.x = CP_INFO:GetLeft()
		RaidTools.storage.config.cp.y = CP_INFO:GetTop()
	end
	SPC_INFO = RaidTools.WM:CreateTopLevelWindow("RaidToolsGroupBuffsSPC")
	SPC_INFO:SetDimensions(80, 80)
	SPC_INFO:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RaidTools.storage.config.spc.x, RaidTools.storage.config.spc.y)
	SPC_INFO:SetClampedToScreen(true)
	SPC_INFO:SetMouseEnabled(true)
	SPC_INFO:SetMovable(true)
	SPC_INFO:SetHidden(true)
	SPC_INFO:SetAlpha(1)
	SPC_INFO:SetHandler("OnMoveStop", OnSPCMoved)

	SPC_INFO.icon = RaidTools.WM:CreateControl(nil, SPC_INFO, CT_TEXTURE)
	SPC_INFO.icon:SetDimensions(40, 40)
	SPC_INFO.icon:SetAnchor(TOPLEFT, SPC_INFO, TOPLEFT, 20, 0)
	SPC_INFO.icon:SetTexture(GetAbilityIcon(ABILITY_SPELLPOWERCURE))

	SPC_INFO.label = RaidTools.WM:CreateControl(nil, SPC_INFO, CT_LABEL)
	SPC_INFO.label:SetDimensions(100, 10)
	SPC_INFO.label:SetAnchor(TOPLEFT, SPC_INFO, TOPLEFT, 5, 40)
	SPC_INFO.label:SetFont('ZoFontConversationOption')
	SPC_INFO.label:SetText('SPC: 0')

	SPC_INFO.fragment = ZO_HUDFadeSceneFragment:New(SPC_INFO)
	HUD_SCENE:AddFragment(SPC_INFO.fragment)
    HUD_UI_SCENE:AddFragment(SPC_INFO.fragment)

    POWASS_INFO = RaidTools.WM:CreateTopLevelWindow("RaidToolsGroupBuffsPOWASS")
	POWASS_INFO:SetDimensions(80, 80)
	POWASS_INFO:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RaidTools.storage.config.powass.x, RaidTools.storage.config.powass.y)
	POWASS_INFO:SetClampedToScreen(true)
	POWASS_INFO:SetMouseEnabled(true)
	POWASS_INFO:SetMovable(true)
	POWASS_INFO:SetHidden(true)
	POWASS_INFO:SetAlpha(1)
	POWASS_INFO:SetHandler("OnMoveStop", OnPFAMoved)
	POWASS_INFO.icon = RaidTools.WM:CreateControl(nil, POWASS_INFO, CT_TEXTURE)
	POWASS_INFO.icon:SetDimensions(40, 40)
	POWASS_INFO.icon:SetAnchor(TOPLEFT, POWASS_INFO, TOPLEFT, 20, 0)
	POWASS_INFO.icon:SetTexture(GetAbilityIcon(ABILITY_POWERFUL_ASSAULT))

	POWASS_INFO.label = RaidTools.WM:CreateControl(nil, POWASS_INFO, CT_LABEL)
	POWASS_INFO.label:SetDimensions(100, 10)
	POWASS_INFO.label:SetAnchor(TOPLEFT, POWASS_INFO, TOPLEFT, 5, 40)
	POWASS_INFO.label:SetFont('ZoFontConversationOption')
	POWASS_INFO.label:SetText('PFA: 0')

	POWASS_INFO.fragment = ZO_HUDFadeSceneFragment:New(POWASS_INFO)
	HUD_SCENE:AddFragment(POWASS_INFO.fragment)
    HUD_UI_SCENE:AddFragment(POWASS_INFO.fragment)

    CP_INFO = RaidTools.WM:CreateTopLevelWindow("RaidToolsGroupBuffsCP")
	CP_INFO:SetDimensions(80, 80)
	CP_INFO:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RaidTools.storage.config.cp.x, RaidTools.storage.config.cp.y)
	CP_INFO:SetClampedToScreen(true)
	CP_INFO:SetMouseEnabled(true)
	CP_INFO:SetMovable(true)
	CP_INFO:SetHidden(true)
	CP_INFO:SetAlpha(1)
	CP_INFO:SetHandler("OnMoveStop", OnCPMoved)
	CP_INFO.icon = RaidTools.WM:CreateControl(nil, CP_INFO, CT_TEXTURE)
	CP_INFO.icon:SetDimensions(40, 40)
	CP_INFO.icon:SetAnchor(TOPLEFT, CP_INFO, TOPLEFT, 20, 0)
	CP_INFO.icon:SetTexture(GetAbilityIcon(ABILITY_COMBAT_PRAYER))

	CP_INFO.label = RaidTools.WM:CreateControl(nil, CP_INFO, CT_LABEL)
	CP_INFO.label:SetDimensions(100, 10)
	CP_INFO.label:SetAnchor(TOPLEFT, CP_INFO, TOPLEFT, 5, 40)
	CP_INFO.label:SetFont('ZoFontConversationOption')
	CP_INFO.label:SetText('CP: 0')

	CP_INFO.fragment = ZO_HUDFadeSceneFragment:New(CP_INFO)
	HUD_SCENE:AddFragment(CP_INFO.fragment)
    HUD_UI_SCENE:AddFragment(CP_INFO.fragment)

    RaidToolsGroupBuffs.Hide()
end

