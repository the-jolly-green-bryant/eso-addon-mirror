------------------
--LOAD LIBRARIES--
------------------

--load LibAddonsMenu-2.0
local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0");

----------------------
--INITIATE VARIABLES--
----------------------

--create Addon UI table
PetDeadAlertData = {};
--define name of addon
PetDeadAlertData.name = "PetDeadAlert";
--define addon version number
PetDeadAlertData.version = 1.00; 
 
PetDeadAlert = {} 

local checkAbilityIdMap = {
--Summon Winged Twilight:
[24613] = "esoui/art/icons/ability_sorcerer_lightning_prey.dds", 
[24739] = "esoui/art/icons/ability_sorcerer_lightning_prey.dds", 
[30581] = "esoui/art/icons/ability_sorcerer_lightning_prey.dds", 
[30584] = "esoui/art/icons/ability_sorcerer_lightning_prey.dds", 
[30587] = "esoui/art/icons/ability_sorcerer_lightning_prey.dds",
--Summon Twilight Tormentor: 
[24636] = "esoui/art/icons/ability_sorcerer_lightning_matriarch.dds", 
[30592] = "esoui/art/icons/ability_sorcerer_lightning_matriarch.dds", 
[30595] = "esoui/art/icons/ability_sorcerer_lightning_matriarch.dds", 
[30598] = "esoui/art/icons/ability_sorcerer_lightning_matriarch.dds",
--Summon Twilight Matriarch: 
[24639] = "esoui/art/icons/ability_sorcerer_storm_prey.dds", 
[30618] = "esoui/art/icons/ability_sorcerer_storm_prey.dds", 
[30622] = "esoui/art/icons/ability_sorcerer_storm_prey.dds", 
[30626] = "esoui/art/icons/ability_sorcerer_storm_prey.dds",
--Summon Unstable Familiar:
[23304] = "esoui/art/icons/ability_sorcerer_unstable_fimiliar.dds", 
[30631] = "esoui/art/icons/ability_sorcerer_unstable_fimiliar.dds", 
[30636] = "esoui/art/icons/ability_sorcerer_unstable_fimiliar.dds", 
[30641] = "esoui/art/icons/ability_sorcerer_unstable_fimiliar.dds",
--Summon Unstable Clannfear: 
[23319] = "esoui/art/icons/ability_sorcerer_unstable_clannfear.dds", 
[30647] = "esoui/art/icons/ability_sorcerer_unstable_clannfear.dds", 
[30652] = "esoui/art/icons/ability_sorcerer_unstable_clannfear.dds", 
[30657] = "esoui/art/icons/ability_sorcerer_unstable_clannfear.dds",
--Summon Volatile Familiar：
[30664] = "esoui/art/icons/ability_sorcerer_speedy_familiar.dds",
[30669] = "esoui/art/icons/ability_sorcerer_speedy_familiar.dds", 
[30674] = "esoui/art/icons/ability_sorcerer_speedy_familiar.dds", 
[23316] = "esoui/art/icons/ability_sorcerer_speedy_familiar.dds",
--Feral Guardian:
[85982] = "esoui/art/icons/ability_warden_018.dds", 
[85983] = "esoui/art/icons/ability_warden_018.dds", 
[85984] = "esoui/art/icons/ability_warden_018.dds", 
[85985] = "esoui/art/icons/ability_warden_018.dds", 
--Eternal Guardian: 
[85986] = "esoui/art/icons/ability_warden_018_b.dds",
[85987] = "esoui/art/icons/ability_warden_018_b.dds", 
[85988] = "esoui/art/icons/ability_warden_018_b.dds", 
[85989] = "esoui/art/icons/ability_warden_018_b.dds",
--Wild Guardian: 
[85990] = "esoui/art/icons/ability_warden_018_c.dds", 
[85991] = "esoui/art/icons/ability_warden_018_c.dds",
[85992] = "esoui/art/icons/ability_warden_018_c.dds",
[85993] = "esoui/art/icons/ability_warden_018_c.dds",
} 


local function triggerAddonLoaded(eventCode, addonName)
	if  (addonName == PetDeadAlertData.name) then
		EVENT_MANAGER:UnregisterForEvent(PetDeadAlertData.name, EVENT_ADD_ON_LOADED);
		
	end
end
 

local function onEffectChanged(eventCode,  changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType,  abilityType,  statusEffectType,  unitName,  unitId,  abilityId,   sourceType)
	--d("EVENT_EFFECT_CHANGED: " .." eventCode:"..eventCode.." changeType:"..changeType.." effectSlot:"..effectSlot.." effectName:"..effectName.." unitTag:"..unitTag.." beginTime:"..beginTime.." endTime:"..endTime.." stackCount:"..stackCount.." iconName:"..iconName.." buffType:"..buffType.." effectType:"..effectType.." abilityType:"..abilityType.." statusEffectType:"..statusEffectType.." unitName:"..unitName.." unitId:"..unitId.." abilityId"..abilityId.." sourceType:"..sourceType)
	if unitTag == "player" and checkAbilityIdMap[abilityId] then
		--player's pet
		if changeType == 1 then
			--d("Summoned Pet")
		elseif changeType == 2 then
			--d("Unsummoned Pet")
			--only alert when in combat
			if IsUnitInCombat("player") then
				local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.AVA_GATE_OPENED)
				messageParams:SetText(zo_strformat("|t64:64:<<1>>|t |cFF0000PET IS DEAD!!|r", checkAbilityIdMap[abilityId]))
				messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN)
				CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
			end
		end
	end
end



EVENT_MANAGER:RegisterForEvent(PetDeadAlertData.name, EVENT_ADD_ON_LOADED, triggerAddonLoaded) 
EVENT_MANAGER:RegisterForEvent(PetDeadAlertData.name, EVENT_EFFECT_CHANGED, onEffectChanged) 