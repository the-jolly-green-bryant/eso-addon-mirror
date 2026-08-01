BSCCompainionInfo = BSCCompainionInfo or {}
local BSCCOIN = BSCCompainionInfo

BSCCOIN.ACTION_BAR_SKILL_LIST = { }

-------------------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------------------
--GetAbilityCooldown(skilldata.abilityId, 'companion')
local function EffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType) 
	--d(zo_strformat("AbilityName[<<1>>] abilityId[<<2>>] unitName[<<3>>] changeType[<<4>>]", GetAbilityName(abilityId), abilityId, unitName, changeType))
	--EFFECT_RESULT_FADED
    --EFFECT_RESULT_FULL_REFRESH
    --EFFECT_RESULT_GAINED
    --EFFECT_RESULT_TRANSFER
    --EFFECT_RESULT_UPDATED 
	if changeType == EFFECT_RESULT_GAINED then		
		for i, v in ipairs(BSCCOIN.ACTION_BAR_SKILL_LIST) do		
			if v.abilityId == abilityId then
				v.startTime = beginTime
				v.endTime = endTime
				v.updateCD = true	
			end			
		end
	end
end
-------------------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------------------
function BSCCOIN:InitSkillBarIcons()
	if not DoesUnitExist("companion") or not HasActiveCompanion() then return end
	
	-- Update Hotbar Stuff
	local hotbar = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(HOTBAR_CATEGORY_COMPANION)
	if hotbar == nil then return end

	-- Unregister
	for i, v in ipairs(BSCCOIN.ACTION_BAR_SKILL_LIST) do
		if v.abilityId ~= -1 then
			EVENT_MANAGER:UnregisterForEvent(BSCCOIN.Name..tostring(v.abilityId), EVENT_EFFECT_CHANGED)
		end
	end			
	-- Empty Table again
	BSCCOIN.ACTION_BAR_SKILL_LIST = { }	
	
	for slotIndex, slotData in hotbar:SlotIterator(COMPANION_SKILLS_FILTER) do
		local skilldata = slotData:GetCompanionSkillData()
		local newslotidx = tonumber(slotIndex) -2
		if skilldata ~= nil then
			BSCCompainionInfoUI:GetNamedChild("SKillInfoIC"..tostring(newslotidx)):SetTexture(GetAbilityIcon(skilldata.abilityId))
			if newslotidx < 6 then
				BSCCOIN.ACTION_BAR_SKILL_LIST[newslotidx] = { }
				BSCCOIN.ACTION_BAR_SKILL_LIST[newslotidx].abilityId = skilldata.abilityId
				BSCCOIN.ACTION_BAR_SKILL_LIST[newslotidx].startTime = 0
				BSCCOIN.ACTION_BAR_SKILL_LIST[newslotidx].endTime = 0
				BSCCOIN.ACTION_BAR_SKILL_LIST[newslotidx].updateCD = false		
				
				EVENT_MANAGER:RegisterForEvent(BSCCOIN.Name..tostring(skilldata.abilityId), EVENT_EFFECT_CHANGED, EffectChanged)
				EVENT_MANAGER:AddFilterForEvent(BSCCOIN.Name..tostring(skilldata.abilityId), EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, 'companion')	
				EVENT_MANAGER:AddFilterForEvent(BSCCOIN.Name..tostring(skilldata.abilityId), EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, tonumber(skilldata.abilityId))
			end
		else
			BSCCompainionInfoUI:GetNamedChild("SKillInfoIC"..tostring(newslotidx)):SetTexture(ZO_NO_TEXTURE_FILE)		
			if newslotidx < 6 then
				-- Empty SkillData
				BSCCOIN.ACTION_BAR_SKILL_LIST[newslotidx] = { }
				BSCCOIN.ACTION_BAR_SKILL_LIST[newslotidx].abilityId = -1	
				BSCCOIN.ACTION_BAR_SKILL_LIST[newslotidx].startTime = 0
				BSCCOIN.ACTION_BAR_SKILL_LIST[newslotidx].endTime = 0		
				BSCCOIN.ACTION_BAR_SKILL_LIST[newslotidx].updateCD = false	
			end
		end
	end
end
-------------------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------------------
local function HotbarUpdate(_, actionSlotIndex, hotbarCategory)
	if not DoesUnitExist("companion") and not HasActiveCompanion() then return end
	if hotbarCategory ~= HOTBAR_CATEGORY_COMPANION then return end
	--d(zo_strformat('actionSlotIndex[<<1>>] hotbarCategory[<<2>>]', actionSlotIndex, hotbarCategory))
	BSCCOIN:InitSkillBarIcons()
end
-------------------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------------------
local function UpdateUIIconsCooldown()
	if not HasActiveCompanion() then return end
	if not BSCCOIN.SV.DISPLAY_SKILLS then return end

	for i, v in ipairs(BSCCOIN.ACTION_BAR_SKILL_LIST) do		
		local DURATION = v.endTime - (GetGameTimeMilliseconds()/1000)		
		if DURATION >= 0 and v.updateCD == true	then 
			BSCCompainionInfoUI:GetNamedChild("SKillInfoIC"..tostring(i)):SetColor(0.2, 0.2, 0.2, 1)
			BSCCompainionInfoUI:GetNamedChild("SKillInfoIC"..tostring(i).."CD"):SetText(string.format("%.1fs", DURATION))
			BSCCompainionInfoUI:GetNamedChild("SKillInfoIC"..tostring(i).."CD"):SetColor(1, 0, 0, 1)
		else
			BSCCompainionInfoUI:GetNamedChild("SKillInfoIC"..tostring(i)):SetColor(1, 1, 1, 1)
			BSCCompainionInfoUI:GetNamedChild("SKillInfoIC"..tostring(i).."CD"):SetText(string.format("%.1fs", 0))
			BSCCompainionInfoUI:GetNamedChild("SKillInfoIC"..tostring(i).."CD"):SetColor( 0, 1, 0, 1)
			v.updateCD = false
		end		
	end
end
-------------------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------------------
local function EffectChangedNeu(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType) 

	d("    		EffectChanged		")
	d(zo_strformat("AbilityName[<<1>>] abilityId[<<2>>] unitName[<<3>>] changeType[<<4>>] effectSlot[<<5>>] unitTag[<<6>>] unitId[<<7>>]", GetAbilityName(abilityId), abilityId, unitName, changeType, effectSlot, unitTag, unitId))
	d("    							")
	
end

--local function OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow) 
local function OnCombatEvent(_, result, _, _, _, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId, _)

	--if sourceName == "" and targetName == "" then return end
	--if targetUnitId == 0 and sourceUnitId == 0 then return end

	--if targetUnitId ~= 0 then
	--	if LibUnitTracker:GetUnitNameByUnitId(targetUnitId) ~= zo_strformat('<<1>>', GetCompanionName(GetActiveCompanionDefId())) then return end
	--end

	--if sourceUnitId ~= 0 then
	--	if LibUnitTracker:GetUnitNameByUnitId(sourceUnitId) ~= zo_strformat('<<1>>', GetCompanionName(GetActiveCompanionDefId())) then return end
	--end
	

	--if result == ACTION_RESULT_BEGIN then
		d("    		OnCombatEvent		")
		d(zo_strformat("abilityId[<<1>>] AbilityName[<<2>>] sourceName[<<3>>] TargetName[<<4>>] result[<<5>>] abilityActionSlotType[<<6>>]", abilityId, GetAbilityName(abilityId), sourceName, targetName, result, abilityActionSlotType))
		d(zo_strformat("sourceType[<<1>>] targetType[<<2>>] sourceUnitId[<<3>>] targetUnitId[<<4>>]", sourceType, targetType, sourceUnitId, targetUnitId))
		--d(zo_strformat("TName[<<1>>] SName[<<2>>]", LibUnitTracker:GetUnitNameByUnitId(targetUnitId), LibUnitTracker:GetUnitNameByUnitId(sourceUnitId)))
		d("    							")
	--end
	 
end

function BSCCOIN:InitSkillCD()	
	EVENT_MANAGER:RegisterForEvent(BSCCOIN.Name, EVENT_HOTBAR_SLOT_STATE_UPDATED, HotbarUpdate)
	EVENT_MANAGER:AddFilterForEvent(BSCCOIN.Name, EVENT_HOTBAR_SLOT_STATE_UPDATED, REGISTER_FILTER_UNIT_TAG, 'companion')
		
	-- Skill Update
	EVENT_MANAGER:RegisterForEvent(BSCCOIN.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, 
		function(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountChange, repairedByCharacterName, repairedByDisplayName, isLastUpdateForMessage) 
			if not HasActiveCompanion() then return end
			BSCCOIN:InitSkillBarIcons()
		end
	)
	EVENT_MANAGER:AddFilterForEvent(BSCCOIN.Name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_COMPANION_WORN)	
	
	-- Skills CD Update
	EVENT_MANAGER:RegisterForUpdate(BSCCOIN.Name.."Skills", 100, UpdateUIIconsCooldown)
	--EVENT_MANAGER:UnregisterForUpdate(BSCCOIN.Name.."Skills")
		
	
	
	-- Test Area		
	--EVENT_MANAGER:RegisterForEvent(BSCCOIN.Name.."TEST", EVENT_EFFECT_CHANGED, EffectChangedNeu)
	--EVENT_MANAGER:AddFilterForEvent(BSCCOIN.Name.."TEST", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, 'companion')	
	--EVENT_MANAGER:AddFilterForEvent(BSCCOIN.Name.."TEST", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 157142)

	--EVENT_MANAGER:RegisterForEvent(BSCCOIN.Name.."TEST", EVENT_COMBAT_EVENT, OnCombatEvent)
	--EVENT_MANAGER:AddFilterForEvent(BSCCOIN.Name.."TEST", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 157142)
	
	--EVENT_RETICLE_TARGET_COMPANION_CHANGED
end

	--EVENT_MANAGER:RegisterForEvent(BSCCOIN.Name, EVENT_TUTORIAL_TRIGGER_COMPLETED, 
	--	function(_, tutorialTrigger) 
	--		if tutorialTrigger == TUTORIAL_TRIGGER_COMPANION_RAPPORT_INCREASE 
	--		or tutorialTrigger == TUTORIAL_TRIGGER_COMPANION_RAPPORT_DECREASE then 
	--			d("EVENT_TUTORIAL_TRIGGER_COMPLETED ID: "..GetTutorialId(tutorialTrigger)) 
	--		end
	--	end)
-- Test Area		

	--EVENT_MANAGER:RegisterForEvent(BSCCOIN.Name, EVENT_ACTION_SLOT_ABILITY_USED, 
	--	function(_, hotbarCategory, actionSlotIndex) 
	--		if hotbarCategory ~= HOTBAR_CATEGORY_COMPANION then return end
	--		d("EVENT_ACTION_SLOT_EFFECT_UPDATE IDX: ".. actionSlotIndex) 
	--	end)
	

-- EVENT_TUTORIAL_TRIGGER_COMPLETED (*[TutorialTrigger|#TutorialTrigger]* _tutorialTrigger_)* 
-- EVENT_MARKET_PURCHASE_RESULT (*[MarketPurchasableResult|#MarketPurchasableResult]* _purchaseResult_, *[TutorialTrigger|#TutorialTrigger]* _tutorialTrigger_, *bool* _wasGift_)

-- /script d(GetTutorialId(TUTORIAL_TRIGGER_COMPANION_RAPPORT_DECREASE))
-- TUTORIAL_TRIGGER_COMPANION_RAPPORT_DECREASE
-- TUTORIAL_TRIGGER_COMPANION_RAPPORT_INCREASE

-- First Quest 1500 Rapport
-- Second Quest 2800 Rapporr

-- Heilstab --
-- Verjüngung 					154755
-- reparierende Beschwörung		153684
-- mystische Festung			153685

				--BSCCOIN.ACTION_BAR_SKILL_LIST[newslotidx].cooldown = GetAbilityCooldown(skilldata.abilityId, 'companion')
-- List[subid] = mainid

------ Klasse
	-- Lebendiger Schatten
		-- Geeist. Auswei.	157197
		-- Maske der Qual	153856
		-- Zwielichthülle	157201
	-- Seelendiebin
		-- Lebensabsorption	154790
		-- Bluttransfusion	157287
		-- Lebensentzug		157207
	-- Tödliche Assassine
		-- Schattenschnitt	156182
		-- Krümmungsschlag	153853
		-- Schlächterklinge	153855
	
	-- Drakonische Rüst.	
		-- Drachenblut		155268
		-- Zermalm. Klauen	153812
		-- Lodernder Griff	153839
	-- Inbrünstige Kriegerin
		-- Felsschmettern	155186
		-- Feuriger Flegel	153687
		-- Verschmor. Sch.	154923
	-- Straglendes Hert
		-- Anzünden			154925
		-- Basaltbarriere	153851
		-- Schneid. Waff.	155355
------ Waffen
	-- Zweihänder
		--
		--
		--
	-- Waffe mit Schild
		--
		--
		--
	-- Zwei Waffen
		-- Flinker Angriff	152629
		-- 
		--
	-- Bogen
		-- Durschdringende.	152793
		-- Trickschuss		152701
		-- Otternbiss		
	-- Zerstörungsstab
		-- Zerstörerische	157131	-Feuer-		157142
		--							-Eis-
		--							-Blitz
		-- Elementare Bar.			-Feuer-
		--							-Eis-
		--							-Blitz
		-- Arkane Nova.				-Feuer-
		--							-Eis-
		--							-Blitz
	-- Heilstab
		-- Verjüngung		153066
		-- Reparierende B.	153467
		-- Mystische Fest.	153685
------ Rüstung
	-- Leicht
		-- Hast					156340
	-- Mittel
		-- Verschwinden			156596
	-- Schwer
		-- Bollwerk				156599
------ Gilde
	-- 	Krieger
		-- Silberleine 			153686
		-- Ritual der Erlösung	154926
		-- Beißende Falle		157747
	-- Magiergilde
		-- Sternenregen			155403
		-- Umkerentropie		155408
		-- Parallel				155411
	-- Unerschrockene
		-- Blutroter Brunnen	155515
		-- Wilder Instinkt		157240
		-- Skelettägis			155693



--* GetActionSlotEffectDuration(*luaindex* _actionSlotIndex_, *[HotBarCategory|#HotBarCategory]* _hotbarCategory_)
--** _Returns:_ *integer* _durationMilliseconds_

--* GetActionSlotEffectTimeRemaining(*luaindex* _actionSlotIndex_, *[HotBarCategory|#HotBarCategory]* _hotbarCategory_)
--** _Returns:_ *integer* _timeRemainingMilliseconds_

--EVENT_MANAGER:RegisterForEvent(BSCCOIN.Name, EVENT_HOTBAR_SLOT_UPDATED, function(...) d("EVENT_HOTBAR_SLOT_UPDATED") end)
--UnitReactionType UnitReactionColor
--HOTBAR_CATEGORY_COMPANION RESPEC_RESULT_HOTBAR_NOT_COMPANION_BAR
-- GetNumCompanionsInGroup()
--IsGroupCompanionUnitTag(*string* _unitTag_)
--GetCompanionUnitTagByGroupUnitTag(*string* _groupUnitTag_)
--GetGroupUnitTagByCompanionUnitTag(*string* _companionUnitTag_)

--EVENT_ACTIVE_COMPANION_STATE_CHANGED
--EVENT_COMPANION_SKILLS_FULL_UPDATE 
--EVENT_COMPANION_SKILL_LINE_ADDED 
--EVENT_COMPANION_SKILL_RANK_UPDATE 
--EVENT_COMPANION_SKILL_XP_UPDATE 
--EVENT_COMPANION_SUMMON_RESULT
--EVENT_COMPANION_ULTIMATE_FAILURE 
--EVENT_OPEN_COMPANION_MENU 
--EVENT_RETICLE_TARGET_COMPANION_CHANGED 
--EVENT_COMPANION_WARNING (*[CompanionWarningType|#CompanionWarningType]* _warningType_, *integer* _companionId_)
 
	
--GetActiveCompanionDefId()
--GetActiveCompanionLevelForExperiencePoints() 
--GetActiveCompanionLevelInfo()
--GetActiveCompanionRapport() 
--GetActiveCompanionRapportLevel()
-- GetActiveCompanionRapportLevelDescription(*[CompanionRapportLevel|#CompanionRapportLevel]* _rapportLevel_)
--GetCompanionAbilityId() 
--GetCompanionAbilityRankRequired()  
--GetCompanionCollectibleId()  
--GetCompanionIntroQuestId()  
--GetCompanionName() 
--GetCompanionNumSlotsUnlockedForLevel() 
--GetCompanionPassivePerkAbilityId() 
--GetCompanionSkillLineDynamicInfo() 
--GetCompanionSkillLineId() 
--GetCompanionSkillLineNameById()  
--GetCompanionSkillLineXPInfo() 
--GetGroupUnitTagByCompanionUnitTag()
--GetNumAbilitiesInCompanionSkillLine()
--GetNumCompanionSkillLines()
--GetNumCompanionsInGroup()
--GetNumExperiencePointsInCompanionLevel()
--GetPendingCompanionDefId()
--HasActiveCompanion()
--HasBlockedCompanion()
--HasPendingCompanion()
--IsGroupCompanionUnitTag()
--IsInteractingWithMyCompanion()
--HasPendingCompanion()
--GetActiveCompanionRapportLevel()


--/script d(zo_strformat("RapportInfo: [<<1>>] Level(<<2>>/<<3>>) [<<4>>]", GetCompanionName(GetActiveCompanionDefId()), GetActiveCompanionDefId(), 7, GetActiveCompanionRapportLevelDescription(GetActiveCompanionDefId())))

--/script d(zo_strformat(GetActiveCompanionRapportLevelDescription(0)))