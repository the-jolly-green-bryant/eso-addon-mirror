BSCAHPotions = BSCAHPotions or {}
local BSCAHP = BSCAHPotions

ZO_CreateStringId("SI_BINDING_NAME_BSCAHP_OPEN_MENU", "Open Addon Menu")
ZO_CreateStringId("SI_BINDING_NAME_BSCAHP_TOGGLE_ONOFF", "Toggle ON/OFF Addon")
for i = 1, 8 do
	ZO_CreateStringId("SI_BINDING_NAME_BSCAHP_SLOT_"..i, "Slot "..i)
end

BSCAHP.Name = "BSCs-AdvancedPotions"
BSCAHP.Version = 1
BSCAHP.SavedVar = "BSCAHPSaved"
BSCAHP.VersionDisplay = "1.0.1"
BSCAHP.NameMenu = "BSCs-AdvancedPotions"
BSCAHP.Author = "@BloodStainChild666"

--61708
BSCAHP.HEROISM_IDS = {
	[61708] = true,		-- 
}

-- Block Potion ?

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
BSCAHP.SLOTTED_POTS = {
	[1] = "",
	[2] = "",
	[3] = "",
	[4] = "",
	[5] = "",
	[6] = "",
	[7] = "",
	[8] = "",
	[9] = "Not In Use",
} 
BSCAHP.SLOTTED_POTS_TOOLTIP = {
	[1] = "",
	[2] = "",
	[3] = "",
	[4] = "",
	[5] = "",
	[6] = "",
	[7] = "",
	[8] = "",
	[9] = "Not In Use",
}
local function GetSlotFromPotion(ItemLink)
	for i = 1, 8 do		
		if BSCAHP.SLOTTED_POTS[i] == ItemLink then return i end
	end
	return -1
end
--local function UpdateChoices(choices, choicesValues, choicesTooltips)
function BSCAHP:checkslot()	
	for i = 1, 8 do
		local ItemLink = GetSlotItemLink(i, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
		BSCAHP.SLOTTED_POTS[i] = ItemLink
		BSCAHP.SLOTTED_POTS_TOOLTIP[i] = BSCAHP:GetItemLinkInfo(ItemLink)
	end	
	
	if BSCAHP_DD_G_1 ~= nil then
		BSCAHP_DD_G_1:UpdateChoices(BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS_TOOLTIP)
		BSCAHP_DD_G_2:UpdateChoices(BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS_TOOLTIP)
		BSCAHP_DD_G_3:UpdateChoices(BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS_TOOLTIP)
		BSCAHP_DD_G_4:UpdateChoices(BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS_TOOLTIP)
		BSCAHP_DD_G_5:UpdateChoices(BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS_TOOLTIP)
		BSCAHP_DD_G_6:UpdateChoices(BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS_TOOLTIP)
		BSCAHP_DD_G_7:UpdateChoices(BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS_TOOLTIP)
		BSCAHP_DD_G_8:UpdateChoices(BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS_TOOLTIP)	
		BSCAHP_DD_F_1:UpdateChoices(BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS_TOOLTIP)
		BSCAHP_DD_F_2:UpdateChoices(BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS_TOOLTIP)
		BSCAHP_DD_F_3:UpdateChoices(BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS_TOOLTIP)
		BSCAHP_DD_F_4:UpdateChoices(BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS_TOOLTIP)
		BSCAHP_DD_F_5:UpdateChoices(BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS_TOOLTIP)
		BSCAHP_DD_F_6:UpdateChoices(BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS_TOOLTIP)
		BSCAHP_DD_F_7:UpdateChoices(BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS_TOOLTIP)
		BSCAHP_DD_F_8:UpdateChoices(BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS_TOOLTIP)
		BSCAHP_COMBAT_IN:UpdateChoices(BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS_TOOLTIP)
		BSCAHP_COMBAT_OUT:UpdateChoices(BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS, BSCAHP.SLOTTED_POTS_TOOLTIP)
	end
	-- find if pot exist
	if tonumber(GetSlotFromPotion(BSCAHP.SV.POTION_IN_COMBAT)) == -1 then BSCAHP.SV.POTION_IN_COMBAT = "Not In Use" end
	if tonumber(GetSlotFromPotion(BSCAHP.SV.POTION_OUT_COMBAT)) == -1 then BSCAHP.SV.POTION_OUT_COMBAT = "Not In Use" end	
	for i = 1, 8 do		
		if tonumber(GetSlotFromPotion(BSCAHP.SV.POTION_GAIN_LIST[i])) == -1 then BSCAHP.SV.POTION_GAIN_LIST[i] = "Not In Use" end
		if tonumber(GetSlotFromPotion(BSCAHP.SV.POTION_FADE_LIST[i])) == -1 then BSCAHP.SV.POTION_FADE_LIST[i] = "Not In Use" end		
	end
	BSCAHP:UpdateSkillSlotIDS()
end
local function SetSelectedQS(slot)
	if not BSCAHP.SV.ENABLE_ADDON then return end
	if GetCurrentQuickslot() == slot then return end
	if slot == -1 then return end
	SetCurrentQuickslot(slot)
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
BSCAHP.SKILLSLOT_GAIN = { }
BSCAHP.SKILLSLOT_FADE = { }
function BSCAHP:UpdateSkillSlotIDS()
	BSCAHP.SKILLSLOT_GAIN = { }
	BSCAHP.SKILLSLOT_FADE = { }
	for i = 1, 8 do
		if tonumber(BSCAHP.SV.BUFF_GAIN_LIST[i]) > 0 then
			local sid = tonumber(BSCAHP.SV.BUFF_GAIN_LIST[i])
			local potslot = tonumber(GetSlotFromPotion(BSCAHP.SV.POTION_GAIN_LIST[i]))
			if potslot > 0 and potslot < 9 then			
				BSCAHP.SKILLSLOT_GAIN[sid] = potslot	
			end
		end		
		if tonumber(BSCAHP.SV.BUFF_FADE_LIST[i]) > 0 then
			local sid = tonumber(BSCAHP.SV.BUFF_FADE_LIST[i])
			local potslot = tonumber(GetSlotFromPotion(BSCAHP.SV.POTION_FADE_LIST[i]))
			if potslot > 0 and potslot < 9 then			
				BSCAHP.SKILLSLOT_FADE[sid] = potslot
			end
		end		
	end
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- EVENT_EFFECT_CHANGED (eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
local function OnEffectChanged( _, changeType, _, _, unitTag, beginTime, endTime, _, _, _, _, _, _, unitName, unitId, abilityId, _)
	if changeType == EFFECT_RESULT_FADED then
		if BSCAHP.SKILLSLOT_FADE[abilityId] ~= nil then
			SetSelectedQS(BSCAHP.SKILLSLOT_FADE[abilityId])
		end
	elseif changeType == EFFECT_RESULT_UPDATED then	
		if BSCAHP.SKILLSLOT_GAIN[abilityId] ~= nil then
			SetSelectedQS(BSCAHP.SKILLSLOT_GAIN[abilityId])
		end
	end	
	--d(zo_strformat("ID[<<1>>] Name[<<2>>] changeType[<<3>>]", abilityId, GetAbilityName(abilityId), changeType))	
end
local function OnCombatState(_, inCombat)	
	if inCombat then
		SetSelectedQS(GetSlotFromPotion(BSCAHP.SV.POTION_IN_COMBAT))
	else
		SetSelectedQS(GetSlotFromPotion(BSCAHP.SV.POTION_OUT_COMBAT))
	end
end
local function OnPlayerActivated()	
    EVENT_MANAGER:UnregisterForEvent(BSCAHP.Name, EVENT_PLAYER_ACTIVATED)	
	BSCAHP:checkslot()
end

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local function CreateLable()
	-- font
	local fontSize = 23
	local font = string.format("$(BOLD_FONT)|$(KB_%s)|soft-shadow-thick", fontSize)		
	local parent = QuickslotButton		
	BSCAHP.CDLabel = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
	BSCAHP.CDLabel:SetAnchor(BOTTOM, parent, TOP, 0, 0) 
	BSCAHP.CDLabel:SetFont(font)
	BSCAHP.CDLabel:SetHidden(false)
end
local function UpdateUI()
	BSCAHP.CDLabel:SetText(string.format("%.1f", (GetSlotCooldownInfo(GetCurrentQuickslot(), HOTBAR_CATEGORY_QUICKSLOT_WHEEL) / 1000)))
end
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function BSCAHP:ToggleONOFF()
	BSCAHP.SV.ENABLE_ADDON = not BSCAHP.SV.ENABLE_ADDON	
	if BSCAHP.SV.ENABLE_ADDON then 
		CHAT_ROUTER:AddSystemMessage(BSCAHP.Name.." Now Enabled!")
	else
		CHAT_ROUTER:AddSystemMessage(BSCAHP.Name.." Now Disabled!")
	end
end


-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////// --- Init -- //////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
local defaultSV = {	
	ENABLE_ADDON = false,
	POTION_IN_COMBAT = "Not In Use",
	POTION_OUT_COMBAT = "Not In Use",
	BUFF_GAIN_LIST = { 0, 0, 0, 0, 0, 0, 0, 0, },
	POTION_GAIN_LIST = { "Not In Use", "Not In Use", "Not In Use", "Not In Use", "Not In Use", "Not In Use", "Not In Use", "Not In Use", },
	BUFF_FADE_LIST = { 0, 0, 0, 0, 0, 0, 0, 0, },
	POTION_FADE_LIST = { "Not In Use", "Not In Use", "Not In Use", "Not In Use", "Not In Use", "Not In Use", "Not In Use", "Not In Use", },	
}

function BSCAHP.init(event, addonName)
	if addonName ~= BSCAHP.Name then
		return 
	end		
	EVENT_MANAGER:UnregisterForEvent(BSCAHP.Name, 	EVENT_ADD_ON_LOADED)	
	-- Get Saved Data
	BSCAHP.SV = ZO_SavedVars:NewCharacterNameSettings(BSCAHP.SavedVar, BSCAHP.Version, nil, defaultSV)			
	BSCAHP.InitMenu()
	--
	CreateLable()
	--
	EVENT_MANAGER:RegisterForEvent(BSCAHP.Name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(BSCAHP.Name, EVENT_PLAYER_COMBAT_STATE, OnCombatState)	

	EVENT_MANAGER:RegisterForEvent(BSCAHP.Name, EVENT_HOTBAR_SLOT_UPDATED, function(_, _, hotbarCategory) if hotbarCategory == HOTBAR_CATEGORY_QUICKSLOT_WHEEL then BSCAHP:checkslot() end end )
	
	EVENT_MANAGER:RegisterForUpdate(BSCAHP.Name, 200, UpdateUI)
	EVENT_MANAGER:RegisterForEvent(BSCAHP.Name, EVENT_EFFECT_CHANGED, OnEffectChanged)
	EVENT_MANAGER:AddFilterForEvent(BSCAHP.Name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, 'player')
end
EVENT_MANAGER:RegisterForEvent(BSCAHP.Name, EVENT_ADD_ON_LOADED, BSCAHP.init)