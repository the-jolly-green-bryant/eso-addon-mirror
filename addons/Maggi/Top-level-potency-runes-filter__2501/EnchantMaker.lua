EnchMaker = {
	name = "EnchantMaker",
	version = "1.1.7",
    ResultControls = {},
    ResultEnchants = {},
    EssenceFilterControls = {},
    PotencyFilterControls = {},
    AspectFilterControls = {},
    usedSolvent = nil,
    doableEnchants = {},
    atEnchantingStation = false,
    menuID = nil,
    dataDefaults = {
        resultsWindowX = 0,
        resultsWindowY = 0,
        mainWindowX = 0,
        mainWindowY = 0,
        useUnknownTraits = false,
        useMissing = false,
        useUnknownSkill = false,
        training = 0,
        sameWindowCoords = false,
    },
    resultsMaxIndex = 0,
	language = GetCVar("language.2") or "en",
}

EnchantMakerSavedVariables = {}

EnchMaker.Euro = {
	Recura  = {translation = "Rekura"},
	Cura    = {translation = "Kura"},
}

EnchMaker.allRunestones = {}

function EnchMaker.TranslateRunes(runeName)
	-- Do any translation for english that's different on Euro server
	if CONSOLE_SERVER_EUROPE == 1 and EnchMaker.language == "en" then
		for k,v in pairs(EnchMaker.Euro) do
			if k == runeName then
				runeName = v.translation
				break
			end
		end
	end
	return runeName	
end

function EnchMaker.LoadRunes()
	
	for runeType, runes in pairs(EnchMaker.runes.potency) do
		for runeName, runeData in pairs(runes) do
			runeName = EnchMaker.TranslateRunes(runeName)
			EnchMaker.allRunestones[runeName] = {name = runeName, runestoneType = runeType .. "Potency", translation = runeData["translation"], prefix = runeData["prefix"], skillRequirement = runeData["skillRequirement"], minLevel = runeData["minLevel"]}
		end
	end

	for runeName, runeData in pairs(EnchMaker.runes.essence) do
		runeName = EnchMaker.TranslateRunes(runeName)
		EnchMaker.allRunestones[runeName] = {name = runeName, runestoneType = "essence", translation = runeData["translation"]}
	end
	
	for runeName, runeData in pairs(EnchMaker.runes.aspect) do
		runeName = EnchMaker.TranslateRunes(runeName)
		EnchMaker.allRunestones[runeName] = {name = runeName, runestoneType = "aspect", translation = runeData["translation"], quality = runeData["quality"], skillRequirement = runeData["skillRequirement"]}
	end
end

function EnchMaker.DEC_HEX(IN)
    local B,K,OUT,I,D=16,"0123456789abcdef","",0
    while IN>0 do
        I=I+1
        IN,D=math.floor(IN/B),math.mod(IN,B)+1
        OUT=string.sub(K,D,D)..OUT
    end
    if OUT:len() == 0 then
        OUT = "=="
    elseif OUT:len() == 1 then
        OUT = "0" .. OUT
    end
    return OUT
end

EnchMaker.Runestone = {
    name = "",
    translation = "",
    quality = nil,
    skillRequirement = nil,
    prefix = nil,
    minLevel = nil,
    qualityColor = "ffffff",
    bag = 0,
    slot = 0,
}

function EnchMaker.Runestone:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

EnchMaker.Enchant = {
    name = "",
    ingredients = {},
    qualityColor = "ffffff",
    prefix = "",
    minLevel = 0,
    quality = 0,
    numUnknown = 0,
}

function EnchMaker.Enchant:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    
    local potencyRune = o.ingredients[1]
    local essenceRune = o.ingredients[2]
    local aspectRune = o.ingredients[3]
    o.prefix = potencyRune.prefix
    o.name = EnchMaker.enchants[EnchMaker.allRunestones[potencyRune.name].runestoneType][essenceRune.name]
    o.minLevel = potencyRune.minLevel
    o.quality = aspectRune.quality
    local qualityColor = GetItemQualityColor(o.quality)
    o.qualityColor = EnchMaker.DEC_HEX(math.floor(((qualityColor["r"]) * 256) - 0.5)) .. EnchMaker.DEC_HEX(math.floor(((qualityColor["g"]) * 256) - 0.5)) .. EnchMaker.DEC_HEX(math.floor(((qualityColor["b"]) * 256) - 0.5))
    return o
end

function EnchMaker.Enchant:conformsToSearch(searchTerms)
    searchTerms = searchTerms or {}
	local _, _, runeType, rankRequirement, rarityRequirement = GetItemCraftingInfo(self.ingredients[1].bag, self.ingredients[1].slot)
	local isUsable = EnchantMakerSavedVariables.useUnknownSkill or DoesRunePassRequirements(runeType, rankRequirement, rarityRequirement)
    local potencyFiltersHit = isUsable
    for k, v in pairs(searchTerms.potency) do
        potencyFiltersHit = false
        break
    end
    for k, v in pairs(searchTerms.potency) do
        if k == self.ingredients[1].name and isUsable then
			potencyFiltersHit = true
			break
        end
    end
    if not potencyFiltersHit then
        return false
    end

	_, _, runeType, rankRequirement, rarityRequirement = GetItemCraftingInfo(self.ingredients[2].bag, self.ingredients[2].slot)
	isUsable = EnchantMakerSavedVariables.useUnknownSkill or DoesRunePassRequirements(runeType, rankRequirement, rarityRequirement)
    local essenceFiltersHit = isUsable
    for k, v in pairs(searchTerms.essence) do
        essenceFiltersHit = false
        break
    end
    for k, v in pairs(searchTerms.essence) do
        if k == self.ingredients[2].name and isUsable then
			essenceFiltersHit = true
			break
		end
    end
    if not essenceFiltersHit then
        return false
    end

	_, _, runeType, rankRequirement, rarityRequirement = GetItemCraftingInfo(self.ingredients[3].bag, self.ingredients[3].slot)
	isUsable = EnchantMakerSavedVariables.useUnknownSkill or DoesRunePassRequirements(runeType, rankRequirement, rarityRequirement)
    local aspectFiltersHit = isUsable
    for k, v in pairs(searchTerms.aspect) do
        aspectFiltersHit = false
        break
    end
    for k, v in pairs(searchTerms.aspect) do
        if k == self.ingredients[3].name and isUsable then
			aspectFiltersHit = true
			break
        end
    end
    if not aspectFiltersHit then
        return false
    end

    if tonumber(EnchantMakerSavedVariables.training) > 0 then
        local numUnknown = 0
        for _, runestone in pairs(self.ingredients) do
            if GetRunestoneTranslatedName(runestone.bag, runestone.slot) == nil then
                numUnknown = numUnknown + 1
            end
        end
        if numUnknown < tonumber(EnchantMakerSavedVariables.training) then
            return false
        else
            self.numUnknown = numUnknown
        end
    end
    return true
end

function EnchMaker.Enchant:hasSameRunestones(enchant)
    if #self.ingredients ~= #enchant.ingredients then
        return false
    end
    for _, ingredient1 in pairs(self.ingredients) do
        local ingredient1InEnchant = false
        for _, ingredient2 in pairs(enchant.ingredients) do
            if ingredient1.name == ingredient2.name then
                ingredient1InEnchant = true
                break
            end
        end
        if not ingredient1InEnchant then
            return false
        end
    end
    return true
end

function EnchMaker.Enchant.show(resultButton)
    local enchant = EnchMaker.ResultEnchants[resultButton:GetParent()]
    
	local haveAll = true
    if not (EnchMaker.atEnchantingStation and not EnchantMakerSavedVariables.useMissing) then
        d("___________________________________")
        local minLevel = enchant.minLevel
        if minLevel > 50 then
            minLevel = "Champion " .. minLevel - 50
        end

        d("|c" .. enchant.qualityColor .. enchant.prefix .. " " .. EnchMaker.stripTrailingJunk(enchant.name) .. "|r" .. " - for level " .. minLevel )

        d(GetString(ENCHANTMAKER_MADE_WITH))
		for i = 1, #enchant.ingredients do
			local amount = EnchMaker.Inventory.runestones[EnchMaker.allRunestones[enchant.ingredients[i].name].runestoneType][enchant.ingredients[i]]
            d("|c" .. enchant.ingredients[i].qualityColor .. enchant.ingredients[i].name .. " (" .. amount .. ")|r")
			if amount == 0 or amount == "0" then
				haveAll = false
			end
		end
    end
	if haveAll then
		ENCHANTING:ClearSelections()
		for i = 1, #enchant.ingredients do
			ENCHANTING:AddItemToCraft(enchant.ingredients[i].bag, enchant.ingredients[i].slot)
		end
	end
end

EnchMaker.Inventory = {
    runestones = {
        additivePotency = {},
        subtractivePotency = {},
        essence = {},
        aspect = {},
    },
    solvents = {}
}

function EnchMaker.work()
    -- d(EnchMaker.Inventory.runestones["stinkhorn"])
    -- for k, v in pairs (EnchMaker.Inventory.runestones) do
        -- d(k .. " : " .. v)
    -- end
    -- for k, v in pairs (EnchMaker.Inventory.solvents) do
        -- d(k .. " : " .. v)
    -- end
    -- for k, v in pairs(traits) do
        -- d(k)
    -- end
    -- EnchMaker.addStuffToInventoryForBag(BAG_BANK)
    -- EnchMaker.addStuffToInventoryForBag(BAG_BACKPACK)
	-- EnchMaker.addStuffToInventoryForBag(BAG_VIRTUAL)
    -- for k, v in pairs(EnchMaker.Inventory.runestones) do
        -- for k2, v2 in pairs(k) do
            
        -- end
    -- end
end

function EnchMaker.addAllStuffToInventory()
    for runestone, runeData in pairs(EnchMaker.allRunestones) do
        local item = EnchMaker.Runestone:new{name = runeData.name, translation = runeData.translation, quality = runeData.quality, skillRequirement = runeData.skillRequirement, prefix = runeData.prefix, minLevel = runeData.minLevel}
        local skillLevel = 0
        if not EnchantMakerSavedVariables.useUnknownTraits then
            if runeData.runestoneType == "aspect" then
                local _, _, earnedRank, _, _, _, _ = GetSkillAbilityInfo(8, 4, 1)
                skillLevel = earnedRank
            elseif runeData.runestoneType == "additivePotency" or runeData.runestoneType == "subtractivePotency" then
                local _, _, earnedRank, _, _, _, _ = GetSkillAbilityInfo(8, 4, 2)
                skillLevel = earnedRank
            end
        end
        if EnchantMakerSavedVariables.useUnknownSkill or runeData.skillRequirement == nil or skillLevel >= runeData.skillRequirement then
            EnchMaker.Inventory.runestones[runeData.runestoneType][item] = 0
        end
    end
end

function EnchMaker.getInventoryCount(runestoneType,name)
    local itemAlreadyInInventory = nil
    local count = 0
    for k, v in pairs(EnchMaker.Inventory.runestones[runestoneType]) do
        if k.name == name then
    		itemAlreadyInInventory = k
            count = v or 0
            break
        end
    end
    return itemAlreadyInInventory, count
end

local isTopLevelPotencyRune = { [64508] = true, [64509] = true, [68341] = true, [68340] = true }
function EnchMaker.addStuffToInventoryForBag(bagId)
	local useTopLevelPotency = EnchantMakerSavedVariables.useTopLevelPotency
	local TypeStr = ""
	local slotIndex = ZO_GetNextBagSlotIndex(bagId, nil)
	while slotIndex do
        local itemType = GetItemType(bagId, slotIndex)
        -- or GetCostToCraftEnchantingItem(bagId, slotIndex) ~= 0 
        if itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT or itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE or itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY or itemType == ITEMTYPE_ENCHANTMENT_BOOSTER then

			local _, stack, _, meetsUsageRequirement, _, _, _, quality = GetItemInfo(bagId, slotIndex)
            if (meetsUsageRequirement or EnchantMakerSavedVariables.useUnknownSkill) then
				if (itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT or itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE or itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY) then
				if not useTopLevelPotency or itemType ~= ITEMTYPE_ENCHANTING_RUNE_POTENCY or isTopLevelPotencyRune[GetItemId(bagId, slotIndex)] then
					local runeData = EnchMaker.allRunestones[EnchMaker.stripTrailingJunk(GetItemName(bagId, slotIndex))]
					local itemAlreadyInInventory = nil
					local count = nil
					
					itemAlreadyInInventory, count = EnchMaker.getInventoryCount(runeData.runestoneType,runeData.name)
					if stack == nil then
						stack = 0
					end
					if count == nil then
						count = 0
					end

                    --local l = GetRunestoneTranslatedName(bagId, slotIndex) or "Unknown"

					if itemAlreadyInInventory ~= nil then
						EnchMaker.Inventory.runestones[runeData.runestoneType][itemAlreadyInInventory] = count + stack
					else
						local item = EnchMaker.Runestone:new{name = runeData.name, translation = runeData.translation, quality = runeData.quality, skillRequirement = runeData.skillRequirement, prefix = runeData.prefix, minLevel = runeData.minLevel, bag = bagId, slot = slotIndex}
						local qualityColor = GetItemQualityColor(quality)
						item.qualityColor = EnchMaker.DEC_HEX(math.floor(((qualityColor["r"]) * 256) - 0.5)) .. EnchMaker.DEC_HEX(math.floor(((qualityColor["g"]) * 256) - 0.5)) .. EnchMaker.DEC_HEX(math.floor(((qualityColor["b"]) * 256) - 0.5))
						EnchMaker.Inventory.runestones[runeData.runestoneType][item] = stack
					end

				elseif itemType == ITEMTYPE_ENCHANTMENT_BOOSTER then
					d("TODO: Handle ITEMTYPE_ENCHANTMENT_BOOSTER")
					d(GetItemName(bagId, slotIndex))
					-- local item = EnchMaker.Runestone:new{EnchMaker.allRunestones[EnchMaker.stripTrailingJunk(GetItemName(bagId, slotIndex))]}
					-- item.bag = bagId
					-- item.slot = slotIndex
					-- local qualityColor = GetItemQualityColor(quality)
					-- item.qualityColor = EnchMaker.DEC_HEX(math.floor(((qualityColor["r"]) * 256) - 0.5)) .. EnchMaker.DEC_HEX(math.floor(((qualityColor["g"]) * 256) - 0.5)) .. EnchMaker.DEC_HEX(math.floor(((qualityColor["b"]) * 256) - 0.5))
					-- local itemAlreadyInInventory = nil
					-- for k, v in pairs(EnchMaker.Inventory.solvents) do
						-- if k.name == item.name then
							-- itemAlreadyInInventory = k
							-- break
						-- end
					-- end
					-- if itemAlreadyInInventory ~= nil then
						-- EnchMaker.Inventory.solvents[itemAlreadyInInventory] = EnchMaker.Inventory.solvents[itemAlreadyInInventory] + stack
					-- else
						-- EnchMaker.Inventory.solvents[item] = stack
					-- end
				end -- top runes if
				end
			end
        end
		slotIndex = ZO_GetNextBagSlotIndex(bagId, slotIndex)
    end
end

function EnchMaker.addStuffToInventory()
    --addStuffToBag(0) -- equipped
    if EnchantMakerSavedVariables.useMissing then
        EnchMaker.addAllStuffToInventory()
    end
    EnchMaker.addStuffToInventoryForBag(BAG_BANK)
    EnchMaker.addStuffToInventoryForBag(BAG_BACKPACK)
	EnchMaker.addStuffToInventoryForBag(BAG_VIRTUAL)			-- Crafting Bag (Req ESO Subscription)

    -- if EnchMaker.useGuildBank
    -- addStuffToBag(3) -- guild bank
end

function EnchMaker.findDoableEnchants(searchTerms)
    searchTerms = searchTerms or {}
    for _, potencyList in pairs({[1] = EnchMaker.Inventory.runestones.additivePotency, [2] = EnchMaker.Inventory.runestones.subtractivePotency}) do
        for potencyRune, numPotencyRunes in pairs(potencyList) do
            for essenceRune, numEssenceRunes in pairs(EnchMaker.Inventory.runestones.essence) do
                for aspectRune, numAspectRunes in pairs(EnchMaker.Inventory.runestones.aspect) do
                    local enchant = EnchMaker.Enchant:new{ingredients = {[1] = potencyRune, [2] = essenceRune, [3] = aspectRune}}
                    if enchant ~= nil and enchant:conformsToSearch(searchTerms) then
                        table.insert(EnchMaker.doableEnchants, enchant)
                    end
                end
            end
        end
    end
end

function EnchMaker.interactWithEnchantingStation(eventCode, craftSkill, sameStation)
    if craftSkill == CRAFTING_TYPE_ENCHANTING then
        EnchMaker.atEnchantingStation = true
        EnchMaker.doEnchanting()
    end
end

function EnchMaker.doEnchanting()
    -- load the names if not done already
    if next(EnchMaker.allRunestones) == null then
        EnchMaker.LoadRunes()
    end

    EnchantMaker:SetHidden(false)
    EnchMaker.addStuffToInventory()
    EnchMaker.updateControls()
end

function EnchMaker.endEnchanting()
    if not EnchantMaker:IsHidden() or not EnchantMakerOutput:IsHidden() or EnchMaker.atEnchantingStation then
        EnchMaker.doableEnchants = {}
        for k, v in pairs(EnchMaker.AspectFilterControls) do
            v:SetHidden(true)
        end
        for k, v in pairs(EnchMaker.PotencyFilterControls) do
            v:SetHidden(true)
        end
        for k, v in pairs(EnchMaker.EssenceFilterControls) do
            v:SetHidden(true)
        end
        EnchMaker.Inventory.runestones = {
            additivePotency = {},
            subtractivePotency = {},
            essence = {},
            aspect = {},
        }
        EnchMaker.AspectFilterControls = {}
        EnchMaker.PotencyFilterControls = {}
        EnchMaker.EssenceFilterControls = {}
        for k, v in pairs(EnchMaker.ResultControls) do
            v:SetHidden(true)
        end
        EnchMaker.ResultControls = {}
        EnchantMaker:SetHidden(true)
        EnchantMakerOutput:SetHidden(true)
        EnchMaker.atEnchantingStation = false
    end
end

function EnchMaker.craftCompleted(craftSkill)
    if(EnchMaker.atEnchantingStation) then
        EnchMaker.Inventory.runestones = {}
        EnchMaker.Inventory.runestones.additivePotency = {}
        EnchMaker.Inventory.runestones.subtractivePotency = {}
        EnchMaker.Inventory.runestones.essence = {}
        EnchMaker.Inventory.runestones.aspect = {}
        EnchMaker.addStuffToInventory()
        EnchMaker.updateControls()
        EnchantMaker:SetHidden(true)
    end
end

-- function EnchMaker.checkAll(checkButton, isChecked)
    -- local labelControl = WINDOW_MANAGER:GetControlByName("EnchantMakerAllEssenceCheckBoxText")
    -- if isChecked then
        -- labelControl:SetText(GetString(ENCHANTMAKER_UNCHECK_ALL))
    -- else
        -- labelControl:SetText(GetString(ENCHANTMAKER_CHECK_ALL))
    -- end
    -- for _, checkBox in pairs(EnchMaker.PotencyFilterControls) do
        -- if isChecked then
            -- ZO_CheckButton_SetChecked(checkBox)
            -- EnchMaker.checkButtonClicked(checkBox, true)
        -- else
            -- ZO_CheckButton_SetUnchecked(checkBox)
            -- EnchMaker.checkButtonClicked(checkBox, false)
        -- end
    -- end
-- end

function EnchMaker.searchAgain()
    EnchMaker.resultsMaxIndex = 0
    local atEnchantingStation = false
    if EnchMaker.atEnchantingStation then
        atEnchantingStation = true
    end
    EnchMaker.endEnchanting()
    EnchMaker.atEnchantingStation = atEnchantingStation
    if atEnchantingStation then
        EnchMaker.interactWithEnchantingStation(nil, CRAFTING_TYPE_ENCHANTING, true)
    else
        EnchMaker.doEnchanting()
    end
    EnchantMaker:SetHidden(false)
    EnchantMaker:SetMovable(true)
    EnchantMakerOutput:SetHidden(true)
    EnchMaker.updateControls()
end

function EnchMaker.previous()
    EnchMaker.resultsMaxIndex = EnchMaker.resultsMaxIndex - 15
    for k, v in pairs(EnchMaker.ResultControls) do
        v:SetHidden(true)
    end
    -- if EnchMaker.resultsMaxIndex < 0 then
        -- EnchMaker.resultsMaxIndex = 0
    -- end
    EnchMaker.search()
end

function EnchMaker.next()
    EnchMaker.resultsMaxIndex = EnchMaker.resultsMaxIndex + 15
    for k, v in pairs(EnchMaker.ResultControls) do
        v:SetHidden(true)
    end
    EnchMaker.search()
end

function EnchMaker.search()
    if EnchMaker.resultsMaxIndex == 0 then
        local filters = {
            potency = {},
            essence = {},
            aspect = {},
        }
        for _, checkBox in pairs(EnchMaker.PotencyFilterControls) do
            if ZO_CheckButton_IsChecked(checkBox) then
                filters.potency[checkBox.text] = true
            end
        end
        for _, checkBox in pairs(EnchMaker.EssenceFilterControls) do
            if ZO_CheckButton_IsChecked(checkBox) then
                filters.essence[checkBox.text] = true
            end
        end
        for _, checkBox in pairs(EnchMaker.AspectFilterControls) do
            if ZO_CheckButton_IsChecked(checkBox) then
                filters.aspect[checkBox.text] = true
            end
        end
        EnchMaker.doableEnchants = {}
        EnchMaker.findDoableEnchants(filters)
    end
    -- local i = 1
    if #EnchMaker.doableEnchants > EnchMaker.resultsMaxIndex + 15 then
        WINDOW_MANAGER:GetControlByName("EnchantMakerOutputNextButton"):SetHidden(false)
    else
        WINDOW_MANAGER:GetControlByName("EnchantMakerOutputNextButton"):SetHidden(true)
    end
    if EnchMaker.resultsMaxIndex > 0 then
        WINDOW_MANAGER:GetControlByName("EnchantMakerOutputPreviousButton"):SetHidden(false)
    else
        WINDOW_MANAGER:GetControlByName("EnchantMakerOutputPreviousButton"):SetHidden(true)
    end
    local resultLineOffsetX = 0
    local resultLineOffsetY = 0
    for i, v in pairs(EnchMaker.doableEnchants) do
        if i > EnchMaker.resultsMaxIndex then
            local index = i - EnchMaker.resultsMaxIndex
            local uniqueName = "EnchantMakerResult"
            local ingredients = v.ingredients
            table.sort(ingredients, function (a, b) return string.lower(a.name) < string.lower(b.name) end)
            for _, ingredient in pairs(ingredients) do
                uniqueName = uniqueName .. ingredient.name
            end
            uniqueName = "EnchantMakerResult" .. uniqueName
            local control = WINDOW_MANAGER:GetControlByName(uniqueName)

            if control == nil then
                control = CreateControlFromVirtual(uniqueName, EnchantMakerOutputResultsBG, "EnchantMakerResult")
            else
                control:SetHidden(false)
            end
            WINDOW_MANAGER:GetControlByName(uniqueName .. "ShowButton"):SetText(GetString(ENCHANTMAKER_SHOW))
            control:SetSimpleAnchorParent(resultLineOffsetX, resultLineOffsetY + ((control:GetHeight()+2)*(index-1)))
            local runestoneType = ""
            local potencyRune
            local essenceRune
            local aspectRune
			
            for j = 1, #ingredients do
                if EnchMaker.allRunestones[ingredients[j].name].runestoneType == "additivePotency" then
                    runestoneType = "additivePotency"
                    potencyRune = ingredients[j]
                elseif EnchMaker.allRunestones[ingredients[j].name].runestoneType == "subtractivePotency" then
                    runestoneType = "subtractivePotency"
                    potencyRune = ingredients[j]
                elseif EnchMaker.allRunestones[ingredients[j].name].runestoneType == "essence" then
                    essenceRune = ingredients[j]
                elseif EnchMaker.allRunestones[ingredients[j].name].runestoneType == "aspect" then
                    aspectRune = ingredients[j]
                end
            end
			
            if v.numUnknown > 0 then
                control:SetText(potencyRune.prefix .. " " .. EnchMaker.enchants[runestoneType][essenceRune.name].. "   (" .. v.numUnknown .. " unknown translations.)")
            else
                control:SetText(EnchMaker.LangGlyphName(potencyRune.prefix,EnchMaker.enchants[runestoneType][essenceRune.name]))
                --control:SetText(potencyRune.prefix .. " " .. EnchMaker.enchants[runestoneType][essenceRune.name])
            end

            local qualityColor = GetItemQualityColor(aspectRune.quality)
            control:SetColor(qualityColor['r'], qualityColor['g'], qualityColor['b'], qualityColor['a'])
            EnchMaker.ResultEnchants[control] = v
            EnchMaker.ResultControls[index] = control
            -- i = i + 1
        end
        if i >= EnchMaker.resultsMaxIndex + 15 then
            break
        end
    end
    --d("________________________________")
    --d(#EnchMaker.doableEnchants .. " possible combinations found.")
    EnchantMakerOutput:SetHidden(false)
    EnchantMakerOutput:SetMovable(true)
    EnchantMaker:SetHidden(true)
end

function EnchMaker.stripTrailingJunk(words)
    local junkIndex = string.find(words, "^", 1, true)
    if junkIndex ~= nil then
        return string.sub(words, 1, junkIndex-1)
    end
    return words
end

function EnchMaker.EnchantMakerOutputSetFrameCoords(self)
    local x, y = 0, 0
    local addOnX, addOnY = EnchantMakerOutput:GetCenter()
    local guiRootX, guiRootY = GuiRoot:GetCenter()
    x = addOnX - guiRootX
    y = addOnY - guiRootY
    
    EnchantMakerSavedVariables.resultsWindowX = x
    EnchantMakerSavedVariables.resultsWindowY = y

    if EnchantMakerSavedVariables.sameWindowCoords then
        EnchantMakerSavedVariables.mainWindowX = x
        EnchantMakerSavedVariables.mainWindowY = y
        EnchantMaker:ClearAnchors()
        EnchantMaker:SetAnchor(CENTER, GuiRoot, CENTER, EnchantMakerSavedVariables.mainWindowX, EnchantMakerSavedVariables.mainWindowY)
    end
end

function EnchMaker.EnchantMakerSetFrameCoords(self)
    local x, y = 0, 0
    local addOnX, addOnY = EnchantMaker:GetCenter()
    local guiRootX, guiRootY = GuiRoot:GetCenter()
    x = addOnX - guiRootX
    y = addOnY - guiRootY
    
    EnchantMakerSavedVariables.mainWindowX = x
    EnchantMakerSavedVariables.mainWindowY = y

    if EnchantMakerSavedVariables.sameWindowCoords then
        EnchantMakerSavedVariables.resultsWindowX = x
        EnchantMakerSavedVariables.resultsWindowY = y
        EnchantMakerOutput:ClearAnchors()
        EnchantMakerOutput:SetAnchor(CENTER, GuiRoot, CENTER, EnchantMakerSavedVariables.mainWindowX, EnchantMakerSavedVariables.mainWindowY)
    end
end

function EnchMaker.initWindows()
    WINDOW_MANAGER:GetControlByName("EnchantMakerOutputNextButton"):SetText(GetString(ENCHANTMAKER_NEXXT))
    WINDOW_MANAGER:GetControlByName("EnchantMakerOutputPreviousButton"):SetText(GetString(ENCHANTMAKER_PREVIOUS))
    if EnchantMakerSavedVariables.sameWindowCoords then
        EnchantMaker:SetHandler("OnMoveStop", EnchMaker.EnchantMakerSetFrameCoords)
        EnchantMaker:SetAnchor(CENTER, GuiRoot, CENTER, EnchantMakerSavedVariables.mainWindowX, EnchantMakerSavedVariables.mainWindowY)
        EnchantMaker:SetMovable(true)

        EnchantMakerOutput:SetHandler("OnMoveStop", EnchMaker.EnchantMakerOutputSetFrameCoords)
        EnchantMakerOutput:SetAnchor(CENTER, GuiRoot, CENTER, EnchantMakerSavedVariables.mainWindowX, EnchantMakerSavedVariables.mainWindowY)
        EnchantMakerOutput:SetMovable(true)
    else
        EnchantMaker:SetHandler("OnMoveStop", EnchMaker.EnchantMakerSetFrameCoords)
        EnchantMaker:SetAnchor(CENTER, GuiRoot, CENTER, EnchantMakerSavedVariables.mainWindowX, EnchantMakerSavedVariables.mainWindowY)
        EnchantMaker:SetMovable(true)

        EnchantMakerOutput:SetHandler("OnMoveStop", EnchMaker.EnchantMakerOutputSetFrameCoords)
        EnchantMakerOutput:SetAnchor(CENTER, GuiRoot, CENTER, EnchantMakerSavedVariables.resultsWindowX, EnchantMakerSavedVariables.resultsWindowY)
        EnchantMakerOutput:SetMovable(true)
    end
    
    WINDOW_MANAGER:GetControlByName("EnchantMakerSearchButton"):SetText(GetString(ENCHANTMAKER_SEARCH))
    WINDOW_MANAGER:GetControlByName("EnchantMakerOutputSearchButton"):SetText(GetString(ENCHANTMAKER_SEARCH_AGAIN))
    WINDOW_MANAGER:GetControlByName("EnchantMakerPotencyLabel"):SetText(GetString(ENCHANTMAKER_POTENCY_HAVE))
    WINDOW_MANAGER:GetControlByName("EnchantMakerEssenceLabel"):SetText(GetString(ENCHANTMAKER_ESSENCE_HAVE))
    WINDOW_MANAGER:GetControlByName("EnchantMakerAspectLabel"):SetText(GetString(ENCHANTMAKER_ASPECT_HAVE))
    WINDOW_MANAGER:GetControlByName("EnchantMakerOutputLabel"):SetText(GetString(ENCHANTMAKER_SEARCH_RESULTS))

    EnchMaker.updateControls()
end

function EnchMaker.sortAndFlattenIngredients(tab, func)
    local newTable = {}
    for k, v in pairs(tab) do
        table.insert(newTable, k)
    end
    table.sort(newTable, func)
    return newTable
end

function EnchMaker.checkboxInfo(self, button, ctrl, alt, shift, command)
    if button == 2 then
        local ingredient = self.item
        local ingredientType = EnchMaker.allRunestones[ingredient.name].runestoneType
        if ingredientType == "additivePotency" or ingredientType == "subtractivePotency" then
            d("------------------------------------------", '"' .. ingredient.name .. '" translates to "' .. ingredient.translation .. '".')
            local minLevel = ingredient.minLevel
            if minLevel > 50 then
                minLevel = "Champion " .. minLevel - 50
            end
            if ingredientType == "additivePotency" then
                d("Level " .. minLevel.. " Additive potency runestone.")
            else
                d("Level " .. minLevel.. " Subtractive potency runestone .")
            end
        elseif ingredientType == "essence" then
            d("------------------------------------------", '"' .. ingredient.name .. '" translates to "' .. ingredient.translation .. '".')
        elseif ingredientType == "aspect" then
            local qualityString = ""
            local qualityColor = GetItemQualityColor(ingredient.quality)
            qualityColor = EnchMaker.DEC_HEX(math.floor(((qualityColor["r"]) * 256) - 0.5)) .. EnchMaker.DEC_HEX(math.floor(((qualityColor["g"]) * 256) - 0.5)) .. EnchMaker.DEC_HEX(math.floor(((qualityColor["b"]) * 256) - 0.5))
            if ingredient.quality == ITEM_QUALITY_NORMAL then
                qualityString = "|c" .. qualityColor .. "Normal" .. "|r"
            elseif ingredient.quality == ITEM_QUALITY_MAGIC then
                qualityString = "|c" .. qualityColor .. "Magic" .. "|r"
            elseif ingredient.quality == ITEM_QUALITY_ARCANE then
                qualityString = "|c" .. qualityColor .. "Arcane" .. "|r"
            elseif ingredient.quality == ITEM_QUALITY_ARTIFACT then
                qualityString = "|c" .. qualityColor .. "Artifact" .. "|r"
            elseif ingredient.quality == ITEM_QUALITY_LEGENDARY then
                qualityString = "|c" .. qualityColor .. "Legendary" .. "|r"
            end
            d("------------------------------------------", '"' .. ingredient.name .. '" translates to "' .. ingredient.translation .. '".')
            d("Used to create a " .. qualityString .. " item.")
        end
    end
end

function EnchMaker.tooltip(ctrl,text)
    ctrl:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, text) end)
    ctrl:SetHandler("OnMouseExit", function(self)  ZO_Tooltips_HideTextTooltip() end)
end

function EnchMaker.updateControls()
    local newHeight = 390
	local PopText = ""

    if #EnchMaker.PotencyFilterControls == 0 then
        local index = 1
        local count = 0

		--table.sort(EnchMaker.Inventory.runestones.additivePotency, function (a, b) return a.minLevel < b.minLevel end)
        for _, k in pairs(EnchMaker.sortAndFlattenIngredients(EnchMaker.Inventory.runestones.additivePotency, function (a, b) return a.minLevel < b.minLevel end)) do
            local controlName = "EnchantMaker" .. k.name:gsub(" ", "") .. "CheckBox"
            local cboxControl = WINDOW_MANAGER:GetControlByName(controlName)
            local labelControl = WINDOW_MANAGER:GetControlByName(controlName .. "Text")
            if cboxControl == nil then
                cboxControl = CreateControlFromVirtual(controlName, EnchantMakerSearchBG, "EnchantMakerCheckBox")
                cboxControl.text = k.name
                cboxControl:SetHandler("OnMouseUp", EnchMaker.checkboxInfo)
                cboxControl.item = k
                labelControl = CreateControlFromVirtual(controlName .. "Text", cboxControl, "EnchantMakerCheckBoxText")
            else
                cboxControl:SetHidden(false)
            end
            cboxControl:SetSimpleAnchorParent(EnchMaker.Dialog.Potency - 10, (cboxControl:GetHeight()+2)*(index-1))
            _, count = EnchMaker.getInventoryCount("additivePotency",k.name) 
			--labelControl:SetText(string.format("|c00ff00+|r %d %s (%s)  %d",k.skillRequirement,k.name,k.prefix,count))
			labelControl:SetText(string.format("|c00ff00+|r %s  %d",k.prefix,count))

            PopText = string.format("%s (%s %d)",k.name,GetString(ENCHANTMAKER_REQUIRES_POTENCY),k.skillRequirement)
            EnchMaker.tooltip(cboxControl,PopText)
            EnchMaker.tooltip(labelControl,PopText)
            labelControl:SetMouseEnabled(true)

            EnchMaker.PotencyFilterControls[index] = cboxControl
            index = index + 1
        end

        for _, k in pairs(EnchMaker.sortAndFlattenIngredients(EnchMaker.Inventory.runestones.subtractivePotency, function (a, b) return a.minLevel < b.minLevel end)) do
            local controlName = "EnchantMaker" .. k.name:gsub(" ", "") .. "CheckBox"
            local cboxControl = WINDOW_MANAGER:GetControlByName(controlName)
            local labelControl = WINDOW_MANAGER:GetControlByName(controlName .. "Text")
            if cboxControl == nil then
                cboxControl = CreateControlFromVirtual(controlName, EnchantMakerSearchBG, "EnchantMakerCheckBox")
                cboxControl.text = k.name
                cboxControl:SetHandler("OnMouseUp", EnchMaker.checkboxInfo)
                cboxControl.item = k
                labelControl = CreateControlFromVirtual(controlName .. "Text", cboxControl, "EnchantMakerCheckBoxText")
            else
                cboxControl:SetHidden(false)
            end
            cboxControl:SetSimpleAnchorParent(EnchMaker.Dialog.Potency - 10, (cboxControl:GetHeight()+2)*(index-1))
            _, count = EnchMaker.getInventoryCount("subtractivePotency",k.name) 
		    --labelControl:SetText(string.format("|cff0000-|r %d %s (%s)  %d",k.skillRequirement,k.name,k.prefix,count))
			labelControl:SetText(string.format("|cff0000+|r %s  %d",k.prefix,count))

            PopText = string.format("%s (%s %d)",k.name,GetString(ENCHANTMAKER_REQUIRES_POTENCY),k.skillRequirement)
            EnchMaker.tooltip(cboxControl,PopText)
            EnchMaker.tooltip(labelControl,PopText)
            labelControl:SetMouseEnabled(true)

            EnchMaker.PotencyFilterControls[index] = cboxControl
            index = index + 1
        end
        newHeight = #EnchMaker.PotencyFilterControls * 22.5
    else
        newHeight = #EnchMaker.PotencyFilterControls * 22.5
    end

    if #EnchMaker.EssenceFilterControls == 0 then
        local index = 1
        for _, k in pairs(EnchMaker.sortAndFlattenIngredients(EnchMaker.Inventory.runestones.essence, function(a, b) return a.name < b.name end)) do
            local controlName = "EnchantMaker" .. k.name:gsub(" ", "") .. "CheckBox"
            local cboxControl = WINDOW_MANAGER:GetControlByName(controlName)
            local labelControl = WINDOW_MANAGER:GetControlByName(controlName .. "Text")
            if cboxControl == nil then
                cboxControl = CreateControlFromVirtual(controlName, EnchantMakerSearchBG, "EnchantMakerCheckBox")
                cboxControl.text = k.name
		        cboxControl:SetHandler("OnMouseUp", EnchMaker.checkboxInfo)
                cboxControl.item = k
                labelControl = CreateControlFromVirtual(controlName .. "Text", cboxControl, "EnchantMakerCheckBoxText")
            else
                cboxControl:SetHidden(false)
            end
            cboxControl:SetSimpleAnchorParent(EnchMaker.Dialog.Essence - 10, (cboxControl:GetHeight()+2)*(index-1))
            _, count = EnchMaker.getInventoryCount("essence",k.name) 
        	--labelControl:SetText(string.format("%s (%s)  %d",k.name,k.translation,count))
			labelControl:SetText(string.format("%s  %d",k.translation,count))

            PopText = string.format("%s",k.name)
            EnchMaker.tooltip(cboxControl,PopText)
            EnchMaker.tooltip(labelControl,PopText)
            labelControl:SetMouseEnabled(true)

            EnchMaker.EssenceFilterControls[index] = cboxControl
            index = index + 1
        end
        if #EnchMaker.EssenceFilterControls * 22.5 > newHeight then
            newHeight = #EnchMaker.EssenceFilterControls * 22.5
        end
    else
        if #EnchMaker.EssenceFilterControls * 22.5 > newHeight then
            newHeight = #EnchMaker.EssenceFilterControls * 22.5
        end
    end

    if #EnchMaker.AspectFilterControls == 0 then
        local index = 1
        for _, k in pairs(EnchMaker.sortAndFlattenIngredients(EnchMaker.Inventory.runestones.aspect, function (a, b) if a.quality == b.quality then return a.name < b.name else return a.quality < b.quality end end)) do
            local controlName = "EnchantMaker" .. k.name:gsub(" ", "") .. "CheckBox"
            local cboxControl = WINDOW_MANAGER:GetControlByName(controlName)
            local labelControl = WINDOW_MANAGER:GetControlByName(controlName .. "Text")
            if cboxControl == nil then
                cboxControl = CreateControlFromVirtual(controlName, EnchantMakerSearchBG, "EnchantMakerCheckBox")
                cboxControl.text = k.name
                cboxControl:SetHandler("OnMouseUp", EnchMaker.checkboxInfo)
                cboxControl.item = k
                labelControl = CreateControlFromVirtual(controlName .. "Text", cboxControl, "EnchantMakerCheckBoxText")
            else
                cboxControl:SetHidden(false)
            end
            cboxControl:SetSimpleAnchorParent(EnchMaker.Dialog.Aspect - 10, (cboxControl:GetHeight()+2)*(index-1))
            _, count = EnchMaker.getInventoryCount("aspect",k.name)
			--labelControl:SetText(GetItemQualityColor(k.quality):Colorize(string.format("%s (%s)  %d",k.name, k.translation, count)))
			labelControl:SetText(GetItemQualityColor(k.quality):Colorize(string.format("%s  %d",k.translation, count)))

            PopText = string.format("%s (%s %d)",k.name,GetString(ENCHANTMAKER_REQUIRES_ASPECT),k.skillRequirement)
            EnchMaker.tooltip(cboxControl,PopText)
            EnchMaker.tooltip(labelControl,PopText)
            labelControl:SetMouseEnabled(true)

            EnchMaker.AspectFilterControls[index] = cboxControl
            index = index + 1
        end
        if #EnchMaker.AspectFilterControls * 22.5 > newHeight then
            newHeight = #EnchMaker.AspectFilterControls * 22.5
        end
    else
        if #EnchMaker.AspectFilterControls * 22.5 > newHeight then
            newHeight = #EnchMaker.AspectFilterControls * 22.5
        end
    end
    EnchantMaker:SetHeight(newHeight + 140)
    EnchantMakerSearchBG:SetHeight(newHeight)
    EnchantMakerSearchButton:ClearAnchors()
    EnchantMakerSearchButton:SetAnchor(CENTER, EnchantMakerSearchBG, BOTTOM, 0, 30)

    -- Make the width and X positions per language (some language much wider)
    EnchantMaker:SetWidth(EnchMaker.Dialog.Width)
    EnchantMakerSearchBG:SetWidth(EnchMaker.Dialog.Width - 20)
    EnchantMakerPotencyLabel:SetAnchor(TOPLEFT, EnchantMaker, TOPLEFT, EnchMaker.Dialog.Potency, 50)
    EnchantMakerEssenceLabel:SetAnchor(TOPLEFT, EnchantMaker, TOPLEFT, EnchMaker.Dialog.Essence, 50)
    EnchantMakerAspectLabel:SetAnchor(TOPLEFT, EnchantMaker, TOPLEFT, EnchMaker.Dialog.Aspect, 50)
end

function EnchMaker.close()
    EnchMaker.endEnchanting()
end

function EnchMaker.init(eventCode, addOnName)
    if addOnName ~= "EnchantMaker" then
        return
    end
	
	if not (EnchMaker.language == "en" or EnchMaker.language == "de" or EnchMaker.language == "fr") then
		EnchMaker.language = "en"
	end

    EnchantMakerSavedVariables = ZO_SavedVars:New("EnchantMaker_Data", 1, nil, EnchMaker.dataDefaults, nil)
    EnchMaker.initMenu()
    EnchMaker.initWindows()

	if EnchantMakerSavedVariables.useTopLevelPotency == nil then
		EnchantMakerSavedVariables.useTopLevelPotency = true
	end

    --SLASH_COMMANDS["/enchantmaker"] = EnchMaker.work
    SLASH_COMMANDS["/enchantmaker"] = EnchMaker.doEnchanting
end

function EnchMaker.initMenu()
	-- // Settings panel LAM
	local LAM = LibStub("LibAddonMenu-2.0")
	if (not LAM) then return end

	local ADDON_NAME = "Enchant Maker"
	local ADDON_VERSION = "v" .. EnchMaker.version
	local panelData = {
		type = "panel",
		name = ADDON_NAME,
		displayName = ADDON_NAME,
		author = "|cFFFFFFfacit|r",
		version = ADDON_VERSION,
		-- slashCommand = "/enchantmaker",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	LAM:RegisterAddonPanel(ADDON_NAME, panelData)

	local optionsTable = {
		{
			type = "checkbox",
			name = GetString(ENCHANTMAKER_SAME_WINDOW_COORDS_SHORT),
			tooltip = GetString(ENCHANTMAKER_SAME_WINDOW_COORDS_LONG),
			getFunc = function() return EnchantMakerSavedVariables.sameWindowCoords end,
			setFunc = function(value) EnchantMakerSavedVariables.sameWindowCoords = value end,
			width = nil, --full,	-- full or "half" (optional)
			warning = nil,	--(optional)

			default = EnchMaker.dataDefaults.sameWindowCoords,
		},
		{
			type = "checkbox",
			name = GetString(ENCHANTMAKER_USE_UNKNOWN_TRAITS_SHORT),
			tooltip = GetString(ENCHANTMAKER_USE_UNKNOWN_TRAITS_LONG),
			getFunc = function() return EnchantMakerSavedVariables.useUnknownTraits end,
			setFunc = function(value) EnchantMakerSavedVariables.useUnknownTraits = value end,
			width = nil,  --full,	-- full or "half" (optional)
			warning = nil,	--(optional)
			
			default = EnchMaker.dataDefaults.useUnknownTraits,
		},
		{
			type = "dropdown",
			name = GetString(ENCHANTMAKER_TRAINING_SHORT),
			tooltip = GetString(ENCHANTMAKER_TRAINING_LONG),
			choices = {"0", "1", "2", "3"},
			getFunc = function()
				return tostring(EnchantMakerSavedVariables.training)
			end,
			setFunc = function(value)
				if tonumber(value) > 0 then
					EnchantMakerSavedVariables.useUnknownTraits = true
				end
				EnchantMakerSavedVariables.training = tonumber(value)
			end,
			width = nil, --full,	-- full or "half" (optional)

			default = tostring(EnchMaker.dataDefaults.training),
		},
		{
			type = "checkbox",
			name = GetString(ENCHANTMAKER_USE_MISSING_RUNESTONES_SHORT),
			tooltip = GetString(ENCHANTMAKER_USE_MISSING_RUNESTONES_LONG),
			getFunc = function() return EnchantMakerSavedVariables.useMissing end,
			setFunc = function(value) EnchantMakerSavedVariables.useMissing = value end,
			width = nil,   --full,	-- full or "half" (optional) -- or true?
			warning = GetString(ENCHANTMAKER_USE_MISSING_RUNESTONES_WARNING),	--(optional)

			default = EnchMaker.dataDefaults.useMissing,
		},
		{
			type = "checkbox",
			name = GetString(ENCHANTMAKER_USE_UNKNOWN_SKILL_SHORT),
			tooltip = GetString(ENCHANTMAKER_USE_UNKNOWN_SKILL_LONG),
			getFunc = function() return EnchantMakerSavedVariables.useUnknownSkill end,
			setFunc = function(value) EnchantMakerSavedVariables.useUnknownSkill = value end,
			width = nil,   --full,	-- full or "half" (optional) -- or true?

			default = EnchMaker.dataDefaults.useUnknownSkill,
		},
		{
			type = "checkbox",
			name = GetString(ENCHANTMAKER_USE_TOP_POTENCY_RUNES),
			tooltip = GetString(ENCHANTMAKER_USE_TOP_POTENCY_RUNES),
			getFunc = function() return EnchantMakerSavedVariables.useTopLevelPotency end,
			setFunc = function(value) EnchantMakerSavedVariables.useTopLevelPotency = value end,
			width = nil,   --full,	-- full or "half" (optional) -- or true?

			default = true,
		},
	}

	LAM:RegisterOptionControls(ADDON_NAME, optionsTable)
end

function EnchMaker.Initialized()
    EVENT_MANAGER:RegisterForEvent("EnchantMaker", EVENT_ADD_ON_LOADED, EnchMaker.init)
    EVENT_MANAGER:RegisterForEvent("EnchantMaker", EVENT_CRAFTING_STATION_INTERACT, EnchMaker.interactWithEnchantingStation)
    EVENT_MANAGER:RegisterForEvent("EnchantMaker", EVENT_END_CRAFTING_STATION_INTERACT, EnchMaker.endEnchanting)
    EVENT_MANAGER:RegisterForEvent("EnchantMaker", EVENT_CRAFT_COMPLETED, EnchMaker.craftCompleted)
end

EnchMaker.Initialized()