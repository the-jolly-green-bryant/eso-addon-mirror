AO = {}
local AO_Menu = LibStub("LibAddonMenu-2.0")
local outfits = {}
local costumes = {}
local costumeMenuList = {}
local combatState = false

local mementos = {}
local mementoMenuList = {}

local curOutfit = 0

local barOutfit = -1
local oocOutfit = -1

local buff1 = 0
local buff2 = 0
local buff3 = 0
local buff4 = 0
local buff5 = 0
local buff6 = 0
local buff7 = 0
local buff8 = 0

local buffMenuList = {
	"Disabled",
	"Empower",
	"Major Brutality",
	"Major Berserk",
	"Major Expedition",
	"Major Force",
	"Major Heroism",
	"Major Mending",
	"Major Prophecy",
	"Major Protection",
	"Major Savagery",
	"Major Sorcery",
	"Major Resolve",
	"Major Ward",
	"Minor Expedition",
	"Minor Force",
	"Minor Mending",
	"Minor Endurance",
	"Minor Vitality",
	"Minor Berserk",
	"Minor Heroism",
	"Minor Protection",
	"Minor Resolve",
	"Minor Ward"
}

local buffIDList = {
	["Disabled"] = 0,
	["Empower"] = BUFF_TYPE_EMPOWER,
	["Major Brutality"] = BUFF_TYPE_MAJOR_BRUTALITY,
	["Major Berserk"] = BUFF_TYPE_MAJOR_BERSERK,
	["Major Expedition"] = BUFF_TYPE_MAJOR_EXPEDITION,
	["Major Force"] = BUFF_TYPE_MAJOR_FORCE,
	["Major Heroism"] = BUFF_TYPE_MAJOR_HEROISM,
	["Major Mending"] = BUFF_TYPE_MAJOR_MENDING,
	["Major Prophecy"] = BUFF_TYPE_MAJOR_PROPHECY,
	["Major Protection"] = BUFF_TYPE_MAJOR_PROTECTION,
	["Major Savagery"] = BUFF_TYPE_MAJOR_SAVAGERY,
	["Major Sorcery"] = BUFF_TYPE_MAJOR_SORCERY,
	["Major Resolve"] = BUFF_TYPE_MAJOR_RESOLVE,
	["Major Ward"] = BUFF_TYPE_MAJOR_WARD,
	["Minor Expedition"] = BUFF_TYPE_MINOR_EXPEDITION,
	["Minor Force"] = BUFF_TYPE_MINOR_FORCE,
	["Minor Mending"] = BUFF_TYPE_MINOR_MENDING,
	["Minor Endurance"] = BUFF_TYPE_MINOR_ENDURANCE,
	["Minor Vitality"] = BUFF_TYPE_MINOR_VITALITY,
	["Minor Berserk"] = BUFF_TYPE_MINOR_BERSERK,
	["Minor Heroism"] = BUFF_TYPE_MINOR_HEROISM,
	["Minor Protection"] = BUFF_TYPE_MINOR_PROTECTION,
	["Minor Resolve"] = BUFF_TYPE_MINOR_RESOLVE,
	["Minor Ward"] = BUFF_TYPE_MINOR_WARD
}

local buffNameList = {
	[0] = "Disabled",
	[BUFF_TYPE_EMPOWER] = "Empower",
	[BUFF_TYPE_MAJOR_BRUTALITY] = "Major Brutality",
	[BUFF_TYPE_MAJOR_BERSERK] = "Major Berserk",
	[BUFF_TYPE_MAJOR_EXPEDITION] = "Major Expedition",
	[BUFF_TYPE_MAJOR_FORCE] = "Major Force",
	[BUFF_TYPE_MAJOR_HEROISM] = "Major Heroism",
	[BUFF_TYPE_MAJOR_MENDING] = "Major Mending",
	[BUFF_TYPE_MAJOR_PROPHECY] = "Major Prophecy",
	[BUFF_TYPE_MAJOR_PROTECTION] = "Major Protection",
	[BUFF_TYPE_MAJOR_SAVAGERY] = "Major Savagery",
	[BUFF_TYPE_MAJOR_SORCERY] = "Major Sorcery",
	[BUFF_TYPE_MAJOR_RESOLVE] = "Major Resolve",
	[BUFF_TYPE_MAJOR_WARD] = "Major Ward",
	[BUFF_TYPE_MINOR_EXPEDITION] = "Minor Expedition",
	[BUFF_TYPE_MINOR_FORCE] = "Minor Force",
	[BUFF_TYPE_MINOR_MENDING] = "Minor Mending",
	[BUFF_TYPE_MINOR_ENDURANCE] = "Minor Endurance",
	[BUFF_TYPE_MINOR_VITALITY] = "Minor Vitality",
	[BUFF_TYPE_MINOR_BERSERK] = "Minor Berserk",
	[BUFF_TYPE_MINOR_HEROISM] = "Minor Heroism",
	[BUFF_TYPE_MINOR_PROTECTION] = "Minor Protection",
	[BUFF_TYPE_MINOR_RESOLVE] = "Minor Resolve",
	[BUFF_TYPE_MINOR_WARD] = "Minor Ward"
}

function AO.OnCombatState(_,inCombat)
	if AO.settings.OocCostume == 1 then
		if (inCombat) then
			oocOutfit = -1
		else
			oocOutfit = AO.settings.OocOutfit
			AO.UpdateOutfit()
		end
	else
		combatState = inCombat

		local curCostume = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COSTUME)

		if inCombat then		
			if curCostume ~= 0 then
				UseCollectible(curCostume)
			end
		else
			if curCostume ~= AO.settings.OocCostume then
				UseCollectible(AO.settings.OocCostume)
			end
		end
		
		EVENT_MANAGER:RegisterForUpdate("AO_SwapCostume", 500, AO.CheckCostume)
	end
end

function AO.CheckCostume()
	local curCostume = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COSTUME)

	if combatState then
		if curCostume ~= 0 then
			UseCollectible(curCostume)
		else
			EVENT_MANAGER:UnregisterForUpdate("AO_SwapCostume")
		end
	else		
		if curCostume == AO.settings.OocCostume then
			EVENT_MANAGER:UnregisterForUpdate("AO_SwapCostume")
		else
			UseCollectible(AO.settings.OocCostume)
		end
	end
end

function AO.OnBarSwap(_,isHotbarSwap)
	if isHotbarSwap then
		local pair = GetActiveWeaponPairInfo()
		if pair == 1 then
			barOutfit = AO.settings.bar1Outfit
		elseif pair == 2 then
			barOutfit = AO.settings.bar2Outfit
		end
		AO.UpdateOutfit()
	end	
end

function AO.UpdateOutfit ()
	local targetOutfit = 0

	if barOutfit ~= -1 then targetOutfit = barOutfit end
	if oocOutfit ~= -1 then targetOutfit = oocOutfit end
	if buff1 > 0 and AO.settings.buff1Outfit ~= -1 then targetOutfit = AO.settings.buff1Outfit end
	if buff2 > 0 and AO.settings.buff2Outfit ~= -1 then targetOutfit = AO.settings.buff2Outfit end
	if buff3 > 0 and AO.settings.buff3Outfit ~= -1 then targetOutfit = AO.settings.buff3Outfit end
	if buff4 > 0 and AO.settings.buff4Outfit ~= -1 then targetOutfit = AO.settings.buff4Outfit end
	if buff5 > 0 and AO.settings.buff5Outfit ~= -1 then targetOutfit = AO.settings.buff5Outfit end
	if buff6 > 0 and AO.settings.buff6Outfit ~= -1 then targetOutfit = AO.settings.buff6Outfit end
	if buff7 > 0 and AO.settings.buff7Outfit ~= -1 then targetOutfit = AO.settings.buff7Outfit end
	if buff8 > 0 and AO.settings.buff8Outfit ~= -1 then targetOutfit = AO.settings.buff8Outfit end

	if targetOutfit ~= curOutfit then
		curOutfit = targetOutfit
		AO.WearOutfit(curOutfit)
	end
end

function  AO.WearOutfit ()
	if AO.settings.transformEffect ~= 1 then
		UseCollectible(AO.settings.transformEffect)
	end

	if curOutfit == 0 then
		UnequipOutfit()
	else
		EquipOutfit(curOutfit)
	end
end

function AO.GetOutfitName ( num )
	local n = GetOutfitName(num)
	if n == "" then
		return "Outfit " .. num;
	else
		return n
	end
end

function AO.OnEffectChanged (e, change, slot, auraName, unitTag, start, finish, stack, icon, buffType, effectType, abilityType, statusType, unitName, unitId, abilityId, sourceType)
	if change == EFFECT_RESULT_FADED then 
		if auraName == buffNameList[AO.settings.buffEffect1] then
			buff1 = buff1 - 1
			zo_callLater (AO.UpdateOutfit, 100)
		end
		if auraName == buffNameList[AO.settings.buffEffect2] then
			buff2 = buff2 - 1
			zo_callLater (AO.UpdateOutfit, 100)
		end
		if auraName == buffNameList[AO.settings.buffEffect3] then
			buff3 = buff3 - 1
			zo_callLater (AO.UpdateOutfit, 100)
		end
		if auraName == buffNameList[AO.settings.buffEffect4] then
			buff4 = buff4 - 1
			zo_callLater (AO.UpdateOutfit, 100)
		end
		if auraName == buffNameList[AO.settings.buffEffect5] then
			buff5 = buff5 - 1
			zo_callLater (AO.UpdateOutfit, 100)
		end
		if auraName == buffNameList[AO.settings.buffEffect6] then
			buff6 = buff6 - 1
			zo_callLater (AO.UpdateOutfit, 100)
		end
		if auraName == buffNameList[AO.settings.buffEffect7] then
			buff7 = buff7 - 1
			zo_callLater (AO.UpdateOutfit, 100)
		end
		if auraName == buffNameList[AO.settings.buffEffect8] then
			buff8 = buff8 - 1
			zo_callLater (AO.UpdateOutfit, 100)
		end
	else
		if auraName == buffNameList[AO.settings.buffEffect1] then
			buff1 = buff1 + 1
			AO.UpdateOutfit()
		end
		if auraName == buffNameList[AO.settings.buffEffect2] then
			buff2 = buff2 + 1
			AO.UpdateOutfit()
		end
		if auraName == buffNameList[AO.settings.buffEffect3] then
			buff3 = buff3 + 1
			AO.UpdateOutfit()
		end
		if auraName == buffNameList[AO.settings.buffEffect4] then
			buff4 = buff4 + 1
			AO.UpdateOutfit()
		end
		if auraName == buffNameList[AO.settings.buffEffect5] then
			buff5 = buff5 + 1
			AO.UpdateOutfit()
		end
		if auraName == buffNameList[AO.settings.buffEffect6] then
			buff6 = buff6 + 1
			AO.UpdateOutfit()
		end
		if auraName == buffNameList[AO.settings.buffEffect7] then
			buff7 = buff7 + 1
			AO.UpdateOutfit()
		end
		if auraName == buffNameList[AO.settings.buffEffect8] then
			buff8 = buff8 + 1
			AO.UpdateOutfit()
		end
	end
end

function AO.CreateSettingsMenu()
	local panelData = {
		type = "panel",
		name = "AutoOutfit",
		displayName = ZO_HIGHLIGHT_TEXT:Colorize("Auto Outfit"),
		author = "raj72616a",
		version = "0.7",
		slashCommand = "/ao",
		registerForRefresh = true,
		registerForDefaults = true
	}

	AO_Menu:RegisterAddonPanel("AutoOutfitMenu", panelData)

	local outfitNum = GetNumUnlockedOutfits()
	outfits[1] = "Disabled"
	outfits[2] = "No Outfit"

	for o = 1, outfitNum do
		local idx = o + 2
		outfits[idx] = AO.GetOutfitName(o)
	end


	costumeMenuList = {}
	costumeMenuList[1] = "Disabled"

	newItm = {}
	newItm.name = "Disabled"
	newItm.id = 0;
	costumes = {}
	costumes[1] = newItm;

	mementoMenuList = {}
	mementoMenuList[1] = "Disabled"

	mementos = {}
	mementos[1] = newItm;

	for categoryIndex=1, GetNumCollectibleCategories() do
	
		local name, numSubCatgories, numCollectibles, unlockedCollectibles = GetCollectibleCategoryInfo(categoryIndex)
		
		for subCategoryIndex=1, numSubCatgories do
		
			local subCategoryName, subCategoryNumCollectibles, subCategoryUnlockedCollectibles = GetCollectibleSubCategoryInfo(categoryIndex, subCategoryIndex)
			
			for collectibleIndex=1, subCategoryNumCollectibles do
			
				local collectibleId = GetCollectibleId(categoryIndex, subCategoryIndex, collectibleIndex)
				local collectibleName, _, _, _, unlocked, _, _, categoryType = GetCollectibleInfo(collectibleId)
				if unlocked then
					if categoryType == COLLECTIBLE_CATEGORY_TYPE_COSTUME then						
						newItm = {}
						newItm.name = collectibleName
						newItm.id = collectibleId;
						table.insert(costumes, newItm)
						table.insert(costumeMenuList,collectibleName)
					elseif categoryType == COLLECTIBLE_CATEGORY_TYPE_MEMENTO then
						newItm = {}
						newItm.name = collectibleName
						newItm.id = collectibleId;
						table.insert(mementos, newItm)
						table.insert(mementoMenuList,collectibleName)
					end
				end
			end
		end

		for collectibleIndex=1, numCollectibles do
		
			local collectibleId = GetCollectibleId(categoryIndex, nil, collectibleIndex)
			local collectibleName, _, _, _, unlocked, _, _, categoryType = GetCollectibleInfo(collectibleId)
			
			if unlocked then
				if categoryType == COLLECTIBLE_CATEGORY_TYPE_COSTUME then						
					newItm = {}
					newItm.name = collectibleName
					newItm.id = collectibleId;
					table.insert(costumes, newItm)
					table.insert(costumeMenuList,collectibleName)
				elseif categoryType == COLLECTIBLE_CATEGORY_TYPE_MEMENTO then
					newItm = {}
					newItm.name = collectibleName
					newItm.id = collectibleId;
					table.insert(mementos, newItm)
					table.insert(mementoMenuList,collectibleName)
				end
			end
		end
	end

	local optionsTable = {
		{
			type = "dropdown",
			name = "Out-of-Combat Costume",
			choices = costumeMenuList,
			getFunc = function() 
				if AO.settings.OocCostume == 1 then
					return "Disabled"
				end

				local collectibleName, _, _, _, unlocked, _, _, categoryType = GetCollectibleInfo(AO.settings.OocCostume)
				return collectibleName
			end,
			setFunc = function(selected)
				if selected == "Disabled" then
					AO.settings.OocCostume = 1
				else
		          for index, itm in ipairs(costumes) do
		            if itm.name == selected then
		              AO.settings.OocCostume = itm.id
		              break
		            end
		          end   
		        end

			end,
			default = 1
		},
		{
			type = "dropdown",
			name = "Transform Effect (Memento)",
			choices = mementoMenuList,
			getFunc = function() 
				if AO.settings.transformEffect == 1 then
					return "Disabled"
				end

				local collectibleName, _, _, _, unlocked, _, _, categoryType = GetCollectibleInfo(AO.settings.transformEffect)
				return collectibleName
			end,
			setFunc = function(selected)
				if selected == "Disabled" then
					AO.settings.transformEffect = 1
				else
		          for index, itm in ipairs(mementos) do
		            if itm.name == selected then
		              AO.settings.transformEffect = itm.id
		              break
		            end
		          end   
		        end

			end,
			default = 1
		},
		{
			type = "dropdown",
			name = "Bar 1 Outfit",
			choices = outfits,
			getFunc = function() return outfits[AO.settings.bar1Outfit + 2] end,
			setFunc = function(selected)
		          for index, name in ipairs(outfits) do
		            if name == selected then
		              AO.settings.bar1Outfit = index - 2
		            break
		            end
		          end   
				end,
			default = -1
		},
		{
			type = "dropdown",
			name = "Bar 2 Outfit",
			choices = outfits,
			getFunc = function() return outfits[AO.settings.bar2Outfit + 2] end,
			setFunc = function(selected)
		          for index, name in ipairs(outfits) do
		            if name == selected then
		              AO.settings.bar2Outfit = index - 2
		            break
		            end
		          end   
				end,
			default = -1
		},
		{
			type = "dropdown",
			name = "Out-of-Combat Outfit",
			choices = outfits,
			getFunc = function() return outfits[AO.settings.OocOutfit + 2] end,
			setFunc = function(selected)
		          for index, name in ipairs(outfits) do
		            if name == selected then
		              AO.settings.OocOutfit = index - 2
		            break
		            end
		          end   
				end,
			default = -1
		},
		{
			type = "dropdown",
			name = "Change On Effect 1",
			choices = buffMenuList,
			getFunc = function() return buffNameList[AO.settings.buffEffect1] end,
			setFunc = function(selected)
		          AO.settings.buffEffect1 = buffIDList[selected]
				end,
			default = -1
		},
		{
			type = "dropdown",
			name = "to Outfit 1",
			choices = outfits,
			getFunc = function() return outfits[AO.settings.buff1Outfit + 2] end,
			setFunc = function(selected)
		          for index, name in ipairs(outfits) do
		            if name == selected then
		              AO.settings.buff1Outfit = index - 2
		            break
		            end
		          end   
				end,
			default = -1
		},
		{
			type = "dropdown",
			name = "Change On Effect 2",
			choices = buffMenuList,
			getFunc = function() return buffNameList[AO.settings.buffEffect2] end,
			setFunc = function(selected)
		          AO.settings.buffEffect2 = buffIDList[selected]
				end,
			default = -1
		},
		{
			type = "dropdown",
			name = "to Outfit 2",
			choices = outfits,
			getFunc = function() return outfits[AO.settings.buff2Outfit + 2] end,
			setFunc = function(selected)
		          for index, name in ipairs(outfits) do
		            if name == selected then
		              AO.settings.buff2Outfit = index - 2
		            break
		            end
		          end   
				end,
			default = -1
		},
		{
			type = "dropdown",
			name = "Change On Effect 3",
			choices = buffMenuList,
			getFunc = function() return buffNameList[AO.settings.buffEffect3] end,
			setFunc = function(selected)
		          AO.settings.buffEffect3 = buffIDList[selected]
				end,
			default = -1
		},
		{
			type = "dropdown",
			name = "to Outfit 3",
			choices = outfits,
			getFunc = function() return outfits[AO.settings.buff3Outfit + 2] end,
			setFunc = function(selected)
		          for index, name in ipairs(outfits) do
		            if name == selected then
		              AO.settings.buff3Outfit = index - 2
		            break
		            end
		          end   
				end,
			default = -1
		},
		{
			type = "dropdown",
			name = "Change On Effect 4",
			choices = buffMenuList,
			getFunc = function() return buffNameList[AO.settings.buffEffect4] end,
			setFunc = function(selected)
		          AO.settings.buffEffect4 = buffIDList[selected]
				end,
			default = -1
		},
		{
			type = "dropdown",
			name = "to Outfit 4",
			choices = outfits,
			getFunc = function() return outfits[AO.settings.buff4Outfit + 2] end,
			setFunc = function(selected)
		          for index, name in ipairs(outfits) do
		            if name == selected then
		              AO.settings.buff4Outfit = index - 2
		            break
		            end
		          end   
				end,
			default = -1
		} --,
		-- {
		-- 	type = "dropdown",
		-- 	name = "Change On Effect 5",
		-- 	choices = buffMenuList,
		-- 	getFunc = function() return buffNameList[AO.settings.buffEffect5] end,
		-- 	setFunc = function(selected)
		--           AO.settings.buffEffect5 = buffIDList[selected]
		-- 		end,
		-- 	default = -1
		-- },
		-- {
		-- 	type = "dropdown",
		-- 	name = "to Outfit 5",
		-- 	choices = outfits,
		-- 	getFunc = function() return outfits[AO.settings.buff5Outfit + 2] end,
		-- 	setFunc = function(selected)
		--           for index, name in ipairs(outfits) do
		--             if name == selected then
		--               AO.settings.buff5Outfit = index - 2
		--             break
		--             end
		--           end   
		-- 		end,
		-- 	default = -1
		-- },
		-- {
		-- 	type = "dropdown",
		-- 	name = "Change On Effect 6",
		-- 	choices = buffMenuList,
		-- 	getFunc = function() return buffNameList[AO.settings.buffEffect6] end,
		-- 	setFunc = function(selected)
		--           AO.settings.buffEffect6 = buffIDList[selected]
		-- 		end,
		-- 	default = -1
		-- },
		-- {
		-- 	type = "dropdown",
		-- 	name = "to Outfit 6",
		-- 	choices = outfits,
		-- 	getFunc = function() return outfits[AO.settings.buff6Outfit + 2] end,
		-- 	setFunc = function(selected)
		--           for index, name in ipairs(outfits) do
		--             if name == selected then
		--               AO.settings.buff6Outfit = index - 2
		--             break
		--             end
		--           end   
		-- 		end,
		-- 	default = -1
		-- },
		-- {
		-- 	type = "dropdown",
		-- 	name = "Change On Effect 7",
		-- 	choices = buffMenuList,
		-- 	getFunc = function() return buffNameList[AO.settings.buffEffect7] end,
		-- 	setFunc = function(selected)
		--           AO.settings.buffEffect7 = buffIDList[selected]
		-- 		end,
		-- 	default = -1
		-- },
		-- {
		-- 	type = "dropdown",
		-- 	name = "to Outfit 7",
		-- 	choices = outfits,
		-- 	getFunc = function() return outfits[AO.settings.buff7Outfit + 2] end,
		-- 	setFunc = function(selected)
		--           for index, name in ipairs(outfits) do
		--             if name == selected then
		--               AO.settings.buff7Outfit = index - 2
		--             break
		--             end
		--           end   
		-- 		end,
		-- 	default = -1
		-- },
		-- {
		-- 	type = "dropdown",
		-- 	name = "Change On Effect 8",
		-- 	choices = buffMenuList,
		-- 	getFunc = function() return buffNameList[AO.settings.buffEffect8] end,
		-- 	setFunc = function(selected)
		--           AO.settings.buffEffect8 = buffIDList[selected]
		-- 		end,
		-- 	default = -1
		-- },
		-- {
		-- 	type = "dropdown",
		-- 	name = "to Outfit 8",
		-- 	choices = outfits,
		-- 	getFunc = function() return outfits[AO.settings.buff8Outfit + 2] end,
		-- 	setFunc = function(selected)
		--           for index, name in ipairs(outfits) do
		--             if name == selected then
		--               AO.settings.buff8Outfit = index - 2
		--             break
		--             end
		--           end   
		-- 		end,
		-- 	default = -1
		-- }
	}

	AO_Menu:RegisterOptionControls("AutoOutfitMenu", optionsTable)
end

function AO.OnAddOnLoaded(event, addonName)
	--closeWindow()
	if addonName == "AutoOutfit" then
		AO.settings = ZO_SavedVars:New("AO_SavedVariables", 1, "settings", {
				bar1Outfit = -1, 
				bar2Outfit = -1, 
				OocOutfit = -1, 
				OocCostume = 1, 
				transformEffect = 1, 
				buffEffect1 = 0, 
				buff1Outfit = -1, 
				buffEffect2 = 0, 
				buff2Outfit = -1, 
				buffEffect3 = 0, 
				buff3Outfit = -1, 
				buffEffect4 = 0, 
				buff4Outfit = -1, 
				buffEffect5 = 0, 
				buff5Outfit = -1, 
				buffEffect6 = 0, 
				buff6Outfit = -1, 
				buffEffect7 = 0, 
				buff7Outfit = -1, 
				buffEffect8 = 0, 
				buff8Outfit = -1 
			})
		
		EVENT_MANAGER:RegisterForEvent("AutoOutfit", EVENT_PLAYER_COMBAT_STATE, AO.OnCombatState)
		EVENT_MANAGER:RegisterForEvent("AutoOutfit", EVENT_ACTION_SLOTS_FULL_UPDATE, AO.OnBarSwap)
		EVENT_MANAGER:RegisterForEvent("AutoOutfit", EVENT_EFFECT_CHANGED, AO.OnEffectChanged)
		EVENT_MANAGER:AddFilterForEvent("AutoOutfit", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

		AO.CreateSettingsMenu();

		curOutfit = GetEquippedOutfitIndex()
		AO.OnBarSwap (0,true)
	end
end 

EVENT_MANAGER:RegisterForEvent("AutoOutfit", EVENT_ADD_ON_LOADED, AO.OnAddOnLoaded)