CEL={}

CEL.name = "CarosEnchantmentLearner"
local GS = GetString

local aspectrunes = {
	45850, -- Ta 1
	45851, -- Jejota 1
	45852, -- Denata 2
	45853, -- Rekuta 3
	45854, -- Kuta 4
}

local essencerunes = {
	45839, -- Dakeipa
	45833, -- Deni
	45836, -- Denima
	45842, -- Deteri
	68342, -- Hakeijo
	45841, --Haoko
	166045, --Indeko
	45849, --Kaderi
	45837, --Kuoko
	45848, --Makderi
	45832, --Makko
	45835, --Makkoma
	45840, --Meip
	45831, --Oko
	45834, --Okoma
	45843, --Okori
	45846, --Oru
	45838, --Rakeipa
	45847, --Taderi
}

local potencyrunes = {
	45856, --Porade 1
	45817, --Jode 1
	45855, --Jora 1
	45818, --Notade 1
	45806, --Jejora 2
	45857, --Jera 2
	45820, --Tade 2
	45819, --Ode 2
	45807, --Odra 3
	45822, --Edode 3
	45821, --Jayde 3
	45808, --Pojora 3
	45809, --Edora 4
	45810, --Jaera 4
	45823, --Pojode 4
	45824, --Rekude 4
	45812, --Denara 5
	45825, --Hade 5
	45826, --Idode 5
	45811, --Pora 5
	45825, --Hade 5
	45826, --Idode 5
	45827, --Pode 6
	45813, --Rera 6
	45814, --Derado 7
	45828, --Kedeko 7
	45815, --Rekura 8
	45829, --Rede 8
	45830, --Kude 9
	45816, --Kura 9
	68340, --Itade 10
	64508, --Jehade 10
	64509, --Rejera 10
	68341, --Repora 10
}

local unknownEssence
local unknownPotency
local unknownAspect
local restartEssence
local restartPotency
local restartAspect
local proficiency
local proficiencyRarity
local potencystop
local proficiencyArray
local amountAspect
local learnkuta = false
local learnhakeijo = false
local learnindeko = false


function CEL:Initialize()
	CEL.savedVariables = ZO_SavedVars:NewAccountWide("CELSavedVariables", 1, nil, {})
	learnkuta = CEL.savedVariables.learnkuta or false
	learnhakeijo = CEL.savedVariables.learnhakeijo or false
	learnindeko = CEL.savedVariables.learnindeko or false
	
	local LAM = LibAddonMenu2
	local panelData = {
         type = "panel",
         name = "Caro's Enchantment Learner",
		 author = "Orejana and Irniben",
		 slashCommand = "/celsettings"
    }
	local optionsData = {
         [1] = {
              type = "checkbox",
              name = "Learn Kuta",
              tooltip = "If activated, Kuta will be learned.",
              getFunc = function() return learnkuta end,
              setFunc = function(value) learnkuta=value CEL.savedVariables.learnkuta=value end,
         },
		[2] = {
              type = "checkbox",
              name = "Learn Hakeijo",
              tooltip = "If activated, Hakeijo will be learned.",
              getFunc = function() return learnhakeijo end,
              setFunc = function(value) learnhakeijo=value CEL.savedVariables.learnhakeijo=value end,
         },
		[3] = {
              type = "checkbox",
              name = "Learn Indeko",
              tooltip = "If activated, Indeko will be learned.",
              getFunc = function() return learnindeko end,
              setFunc = function(value) learnindeko=value CEL.savedVariables.learnindeko=value end,
         },
	}
	
	LAM:RegisterAddonPanel("Caro's Enchantment Learner", panelData)
	LAM:RegisterOptionControls("Caro's Enchantment Learner", optionsData)
	
end

local function getItemLinkFromItemId(itemId)
	return string.format("|H1:item:%d:0:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h", itemId) 
end

function CEL.learnenchantments()
	restartEssence = 1
	restartAspect = 1
	restartPotency = 1
	proficiency = GetNonCombatBonus(NON_COMBAT_BONUS_ENCHANTING_LEVEL)
	proficiencyRarity = GetNonCombatBonus(NON_COMBAT_BONUS_ENCHANTING_RARITY_LEVEL)
	
	local LLC = LibLazyCrafting:AddRequestingAddon(CEL.name,true, function()end)
	local tabellennamedafuer = {}
	
	proficiencyArray = {4, 8, 12, 16, 22, 24, 26, 28, 30, 34}
	potencystop = proficiencyArray[proficiency]
	local tableAmountRunes = {}
	for i,v in pairs (potencyrunes) do
		local inventory, bank, virtual = GetItemLinkStacks(getItemLinkFromItemId(v))
		tableAmountRunes[v] = inventory + bank + virtual
	end
	for i,v in pairs (aspectrunes) do
		local inventory, bank, virtual = GetItemLinkStacks(getItemLinkFromItemId(v))
		tableAmountRunes[v] = inventory + bank + virtual
	end
	for i,v in pairs (essencerunes) do
		local inventory, bank, virtual = GetItemLinkStacks(getItemLinkFromItemId(v))
		tableAmountRunes[v] = inventory + bank + virtual
	end
	if not learnkuta then
		tableAmountRunes[45854]=0
	end
	if not learnhakeijo then
		tableAmountRunes[68342]=0
	end
	if not learnindeko then
		tableAmountRunes[166045]=0
	end
	
	for i=0, #potencyrunes do
		unknownEssence = nil
		unknownPotency = nil
		unknownAspect = nil
		for j=restartEssence, #essencerunes do
			local bagId, slotIndex = findItemLocationById(essencerunes[j])
			if bagId ~= nil and slotIndex ~= nil and GetRunestoneTranslatedName(bagId, slotIndex) == nil and tableAmountRunes[essencerunes[j]] > 0 then
				unknownEssence = essencerunes[j]
				restartEssence = j+1
				break
			end
		end
		for k=restartPotency, potencystop do
			local bagId, slotIndex = findItemLocationById(potencyrunes[k])
			if bagId ~= nil and slotIndex ~= nil and GetRunestoneTranslatedName(bagId, slotIndex) == nil and tableAmountRunes[potencyrunes[k]] > 0 then
				unknownPotency = potencyrunes[k]
				restartPotency = k+1
				break
			end
		end
		
		for m=restartAspect, proficiencyRarity+1 do
			local bagId, slotIndex = findItemLocationById(aspectrunes[m])
			if bagId ~= nil and slotIndex ~= nil and GetRunestoneTranslatedName(bagId, slotIndex) == nil and tableAmountRunes[aspectrunes[m]] > 0 then
				unknownAspect = aspectrunes[m]
				restartAspect = m+1
				break
			end
		end
		if unknownPotency or unknownAspect or unknownEssence then
			local index = 1
			while not unknownAspect do
				if tableAmountRunes[aspectrunes[index]] > 0 then
					unknownAspect = aspectrunes[index]
				end
				index = index+1
				if (index > #aspectrunes or index > proficiencyRarity+1) and not unknownAspect then
					d("Not enough aspect runes left!")
					break
				end
			end
			local index = 1
			while not unknownPotency do
				if tableAmountRunes[potencyrunes[index]] > 0 then
					unknownPotency = potencyrunes[index]
				end
				index = index+1
				if (index > #potencyrunes or index > potencystop) and not unknownPotency then
					d("Not enough potency runes left!")
					break
				end
			end
			local index = 1
			while not unknownEssence do
				if tableAmountRunes[essencerunes[index]] > 0 then
					unknownEssence = essencerunes[index]
				end
				index = index+1
				if (index > #essencerunes) and not unknownPotency then
					d("Not enough essence runes left!")
					break
				end
			end
			if not unknownEssence or not unknownAspect or not unknownPotency then 
				break 
			end
			LLC:CraftEnchantingItemId(unknownPotency, unknownEssence, unknownAspect, true, "", {}, 1)
			table.insert(tabellennamedafuer, {getItemLinkFromItemId(unknownPotency), getItemLinkFromItemId(unknownEssence), getItemLinkFromItemId(unknownAspect)})
			tableAmountRunes[unknownPotency] = tableAmountRunes[unknownPotency] -1
			tableAmountRunes[unknownAspect] = tableAmountRunes[unknownAspect] -1
			tableAmountRunes[unknownEssence] = tableAmountRunes[unknownEssence] -1
		end
	end
	if #tabellennamedafuer == 0 then
		d("You have nothing left to learn (at your current proficiency level) or you are completely out of runes.")
	end
end

function CEL.OnAddOnLoaded(event, addonName)
  if addonName == CEL.name then
    CEL:Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(CEL.name, EVENT_ADD_ON_LOADED, CEL.OnAddOnLoaded)

SLASH_COMMANDS["/cel"] = CEL.learnenchantments