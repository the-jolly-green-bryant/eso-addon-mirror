MPL = MPL or {}
MPL.name = "702sCraftCompletionistList"

local MPL = MPL

local totalFurnishingPlans = 0
local knownFurnishingPlans = 0

local totalBlueprints = 0
local knownBlueprints = 0

local totalDesigns = 0
local knownDesigns = 0

local totalDiagrams = 0
local knownDiagrams = 0

local totalFormulas = 0
local knownFormulas = 0

local totalPatterns = 0
local knownPatterns = 0

local totalPraxis = 0
local knownPraxis = 0

local totalSketches = 0
local knownSketches = 0

local totalRecipes = 0
local knownRecipes = 0

local totalFoodRecipes = 0
local knownFoodRecipes = 0

local totalDrinkRecipes = 0
local knownDrinkRecipes = 0

local allPlans = true
local knownPlans = false
local unknownPlans = false

local mainFurnishingMenuOpen = false
local subFurnishingMenuOpen = false
local mainRecipeMenuOpen = false
local subRecipeMenuOpen = false
local motifMenuOpen = false

local selectedPlans = selectedPlans or "All Plans"
local selectedRecipes = selectedRecipes or "All Recipes"
local selectedMotifs = selectedMotifs or "All Motifs"

local filteredName = filteredName or ""
local filteredRecipes = filteredRecipes or ""
local filteredMotifs = filteredMotifs or ""

local currentTradeType

local characterChoice = characterChoice or "This Character"
local loadedCharacter = loadedCharacter or GetUnitName("player")

local MasterPlanList = MasterPlanList or {}
local useTrackedCharacter = false
local trackedCharacters


local LCK = LibCharacterKnowledge

--Furnishing Plan Logic

local DISCONTINUED_PLANS = {
    [118064] = true,
    [118053] = true,
    [118065] = true,
    [118054] = true,
    [118055] = true,
    [189498] = true,
    [118119] = true,
    [118120] = true,
    [118125] = true,
    [118127] = true,
    [118126] = true,
    [118137] = true,
    [117894] = true,
    [130326] = true,
    [130327] = true,
    [118290] = true,
    [118354] = true,
    [118096] = true,
    [118118] = true,
    [118286] = true,
    [118281] = true,
    [118061] = true,
    [118062] = true,
    [118098] = true,
    [118056] = true,
    [118288] = true,
    [118291] = true,
    [118293] = true,
    [118000] = true,
    [118295] = true,
    [118289] = true,
    [118321] = true,
    [118296] = true,
    [118297] = true,
    [115395] = true,
    [118107] = true,
    [118278] = true,
    [118277] = true,
    [118057] = true,
    [118060] = true,
    [118059] = true,
    [118058] = true,
    [118111] = true,
    [118066] = true,
    [130332] = true,
    [130325] = true,
    [118298] = true,
    [118284] = true,
    [118283] = true,
    [118121] = true,
    [116475] = true,
    [118112] = true,
    [130322] = true,
    [118299] = true,
    [118300] = true,
    [118489] = true,
    [117835] = true,
    [118304] = true,
    [130339] = true,
    [120997] = true,
    [120996] = true,
    [117765] = true,
    [118068] = true,
    [118069] = true,
    [118070] = true,
    [118071] = true,
    [115698] = true,
    [116433] = true,
    [116474] = true,
    [116473] = true,
    [116445] = true,
    [116472] = true,
    [130329] = true,
    [125530] = true
}

function MPL.SetNewTrackedCharacter()
    
    if MPL.LCKCurrentServer == "NA" then
        MasterPlanList.mainNACrafterName = GetUnitName("player")
        MasterPlanList.mainNACrafterID = GetCurrentCharacterId()
        MPL.chat:Print(string.format("%s now set as your Main Crafter (NA).", MasterPlanList.mainNACrafterName))
    elseif MPL.LCKCurrentServer == "EU" then
        MasterPlanList.mainEUCrafterName = GetUnitName("player")
        MasterPlanList.mainEUCrafterID = GetCurrentCharacterId()
        MPL.chat:Print(string.format("%s now set as your Main Crafter (EU).", MasterPlanList.mainEUCrafterName))
    end
    
    --MasterPlanList.trackedCharacter = GetUnitName("player")
    --MasterPlanList.trackedCharacterID = GetCurrentCharacterId()
    --MPL.chat:Print(string.format("%s now set as your Main Crafter.", MasterPlanList.trackedCharacter))
end

-- Tooltip Handling

local tooltipFontStyle = { fontSize = 34, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1 }

local function AddKnowledgeLine(section, iconPath, color, names)
    if not names or #names == 0 then return end

    local size = 35
    local iconMarkup = string.format("|t%d:%d:%s|t", size, size, iconPath)
    local namesString = table.concat(names, ", ")

    local lineText = string.format("%s |c%s%s|r", iconMarkup, color, namesString)
    section:AddLine(lineText, tooltipFontStyle)
end

function BagToolTip(toolTipControl, functionName)
    ZO_PreHook(toolTipControl, functionName, function(selectedData,...)
		if toolTipControl.selectedEquipSlot then
			GAMEPAD_TOOLTIPS:LayoutBagItem(GAMEPAD_LEFT_TOOLTIP, BAG_WORN, toolTipControl.selectedEquipSlot)
		end

        return false
	end)
end

function CustomItemToolTip(toolTipControl, functionName)
    ZO_PreHook(toolTipControl, functionName, function(control, itemLink, ...)
        
        if not LCK.IsKnowledgeUsable(LCK.GetItemKnowledgeForCharacter(itemLink, nil, nil)) then
        return false end

        local serverList = LCK.GetServerList()

        --d(serverList[1])

        local mainId = MPL.LCKCurrentServer == "NA" and MasterPlanList.mainNACrafterID or MasterPlanList.mainEUCrafterID
        local mainName = MPL.LCKCurrentServer == "NA" and MasterPlanList.mainNACrafterName or MasterPlanList.mainEUCrafterName

        local knownNames = {}
        local unknownNames = {}

        local sectionStyle = toolTipControl:GetStyle("bodySection")
        local section = toolTipControl:AcquireSection(sectionStyle)

        if mainId and mainName then

            local mainKnowledge = LCK.GetItemKnowledgeForCharacter(itemLink, MPL.LCKCurrentServer, mainId)

            if mainKnowledge == LCK.KNOWLEDGE_INVALID then return false end

            local mainIcon = (mainKnowledge == LCK.KNOWLEDGE_UNKNOWN)
                and "esoui/art/hud/gamepad/gp_radialicon_cancel_down.dds"
                or  "esoui/art/hud/gamepad/gp_radialicon_accept_down.dds"

            local mainColor = (mainKnowledge == LCK.KNOWLEDGE_UNKNOWN) and "ff0000" or "00ff00"

            AddKnowledgeLine(section, mainIcon, mainColor, {mainName})
            section:AddLine("")
            toolTipControl:AddSection(section)
        end

        if not MasterPlanList.trackedCharacters then
            return false
        end

        for charId, name in pairs(MasterPlanList.trackedCharacters) do

            if charId ~= mainId then
                local knowledge = LCK.GetItemKnowledgeForCharacter(itemLink, MPL.LCKCurrentServer, charId)

                if knowledge == LCK.KNOWLEDGE_INVALID then return false end

                if knowledge == LCK.KNOWLEDGE_UNKNOWN then
                    table.insert(unknownNames, name)
                elseif knowledge == LCK.KNOWLEDGE_KNOWN then
                    table.insert(knownNames, name)
                end

            end
        end

        section:AddLine("")

        if #unknownNames > 0 then
            AddKnowledgeLine(section,
                "esoui/art/hud/gamepad/gp_radialicon_cancel_down.dds",
                "ff0000",
                unknownNames
            )
        end

        if #knownNames > 0 then
            AddKnowledgeLine(section,
                "esoui/art/hud/gamepad/gp_radialicon_accept_down.dds",
                "00ff00",
                knownNames
            )
        end

        toolTipControl:AddSection(section)

        return false
    end)
end


function InitGamepadTooltips()
	zo_callLater(function() CustomItemToolTip(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP), "LayoutItem") end, 2000)
    CustomItemToolTip(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP), "LayoutItem")
    BagToolTip(GAMEPAD_INVENTORY, "UpdateCategoryLeftTooltip")
end

local function IsKnownByMainCrafter(resultItemID)
   
    local mainId = MPL.LCKCurrentServer == "NA" and MasterPlanList.mainNACrafterID or MasterPlanList.mainEUCrafterID

    return LCK.GetItemKnowledgeForCharacter(
        LCK.GetSourceItemIdFromResultItem(resultItemID),
        nil, 
        mainId) == LCK.KNOWLEDGE_KNOWN
end


function MPL.CountPlansForCraft(tradeSkillType)
    local total = 0
    local known = 0

    local numRecipeLists = GetNumRecipeLists()

    for recipeListIndex = 17, numRecipeLists do
        local _, numRecipes = GetRecipeListInfo(recipeListIndex)

        for recipeIndex = 1, numRecipes do
            local isKnown, recipeName, _, _, _, _, recipeCraftType, resultItemID =
                GetRecipeInfo(recipeListIndex, recipeIndex)

            if useTrackedCharacter then
                isKnown = IsKnownByMainCrafter(resultItemID)
                --isKnown = MasterPlanList.trackedCharacterPlans[resultItemID]
            end

            local includeItem = true

            if filteredName ~= "" and not string.find(string.lower(recipeName), string.lower(filteredName)) then
                includeItem = false
            end

            if includeItem and recipeCraftType == tradeSkillType and not DISCONTINUED_PLANS[resultItemID] then
                total = total + 1
                if isKnown then
                    known = known + 1
                end
            end
        end
    end

    return total, known
end

function MPL.GetBlueprintCount()
    totalBlueprints, knownBlueprints = MPL.CountPlansForCraft(CRAFTING_TYPE_WOODWORKING)
end

function MPL.GetDesignCount()
    totalDesigns, knownDesigns = MPL.CountPlansForCraft(CRAFTING_TYPE_PROVISIONING)
end

function MPL.GetDiagramCount()
    totalDiagrams, knownDiagrams = MPL.CountPlansForCraft(CRAFTING_TYPE_BLACKSMITHING)
end

function MPL.GetFormulaCount()
    totalFormulas, knownFormulas = MPL.CountPlansForCraft(CRAFTING_TYPE_ALCHEMY)
end

function MPL.GetPatternCount()
    totalPatterns, knownPatterns = MPL.CountPlansForCraft(CRAFTING_TYPE_CLOTHIER)
end

function MPL.GetPraxisCount()
    totalPraxis, knownPraxis = MPL.CountPlansForCraft(CRAFTING_TYPE_ENCHANTING)
end

function MPL.GetSketchCount()
    totalSketches, knownSketches = MPL.CountPlansForCraft(CRAFTING_TYPE_JEWELRYCRAFTING)
end

function MPL.GetFurnishingPlanCount()
    MPL:GetBlueprintCount()
    MPL:GetDesignCount()
    MPL:GetDiagramCount()
    MPL:GetFormulaCount()
    MPL:GetPatternCount()
    MPL:GetPraxisCount()
    MPL:GetSketchCount()

	totalFurnishingPlans = 0
    knownFurnishingPlans = 0

    local numRecipeLists = GetNumRecipeLists()
    for recipeListIndex = 17, numRecipeLists do
        local recipeListName, numRecipes = GetRecipeListInfo(recipeListIndex)
        for recipeIndex = 1, numRecipes do
            local isKnown, recipeName, _, _, _, _, tradeSkillType, resultItemID = GetRecipeInfo(recipeListIndex, recipeIndex)

            if useTrackedCharacter then
                isKnown = IsKnownByMainCrafter(resultItemID)
                --isKnown = MasterPlanList.trackedCharacterPlans[resultItemID]
            end

            if  tradeSkillType ~= CRAFTING_TYPE_INVALID and not DISCONTINUED_PLANS[resultItemID] then
                totalFurnishingPlans = totalFurnishingPlans + 1

                if isKnown then
                    knownFurnishingPlans = knownFurnishingPlans + 1
                end
            end

        end
    end
end

function MPL.SetTrackedCharacterKnowledge()
    local furnishingPlanStatus = {}

    local numRecipeLists = GetNumRecipeLists()
    for recipeListIndex = 17, numRecipeLists do
        local recipeListName, numRecipes = GetRecipeListInfo(recipeListIndex)
        for recipeIndex = 1, numRecipes do
            local isKnown, recipeName, _, _, _, _, tradeSkillType, resultItemID = GetRecipeInfo(recipeListIndex, recipeIndex)

            if tradeSkillType ~= CRAFTING_TYPE_INVALID and not DISCONTINUED_PLANS[resultItemID] then
                furnishingPlanStatus[resultItemID] = isKnown
            end
        end
    end

    MasterPlanList.trackedCharacterPlans = furnishingPlanStatus
end

 
function MPL.GetPlanLabelText()
    return string.format("Known Plans\n%d / %d", knownFurnishingPlans, totalFurnishingPlans)
end

function MPL.GetBlueprintLabelText()
    return string.format("Blueprints\n%d / %d", knownBlueprints, totalBlueprints)
end

function MPL.GetDesignLabelText()
    return string.format("Designs\n%d / %d", knownDesigns, totalDesigns)
end

function MPL.GetDiagramLabelText()
    return string.format("Diagrams\n%d / %d", knownDiagrams, totalDiagrams)
end

function MPL.GetFormulaLabelText()
    return string.format("Formulas\n%d / %d", knownFormulas, totalFormulas)
end

function MPL.GetPatternLabelText()
    return string.format("Patterns\n%d / %d", knownPatterns, totalPatterns)
end

function MPL.GetPraxisLabelText()
    return string.format("Praxis\n%d / %d", knownPraxis, totalPraxis)
end

function MPL.GetSketchLabelText()
    return string.format("Sketches\n%d / %d", knownSketches, totalSketches)
end

MPL.ActivePlanDialog = nil

MPL.chat = LibChatMessage("702's Craft Completionist List", "CCL")

local function InputChat(text, channel, target)
    local isRestrictedCommunicationPermitted = true
    if target ~= nil and IsCommunicationRestricted() then
        isRestrictedCommunicationPermitted = CanCommunicateWith(target)
    end
    if IsChatSystemAvailableForCurrentPlatform() and isRestrictedCommunicationPermitted then
        ZO_GetChatSystem():StartTextEntry(text, channel, target, true)
    end
end

function MPL.ShareMaterials(itemLink)
    local count = GetItemLinkRecipeNumIngredients(itemLink)

    if count == 0 then
        MPL.chat:SetTagColor("ff0000"):Print("This item has no crafting materials.")
        SafeStartChatInput("This item has no crafting materials.")
        return
    end

    local lines = {}
    table.insert(lines, string.format("%s:", itemLink))

    for i = 1, count do
        local name, _, qty = GetItemLinkRecipeIngredientInfo(itemLink, i)
        name = name:gsub("^%l", string.upper)
        local ingredientLink = GetItemLinkRecipeIngredientItemLink(itemLink, i)
        table.insert(lines, string.format("(%s x%d)", name, qty))
    end

    local message = table.concat(lines, "\n")

    InputChat(message)
end

local currentPlanLink = nil
local currentScrollList = nil

MPL_recipeMenuKeybindGroup = {
    {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        name = "Put Material Requirements in Chat Box",
        order = -2000,
        keybind = "UI_SHORTCUT_LEFT_STICK",
        callback = function()
            MPL.ShareMaterials(currentPlanLink)
        end,
    },
}


local function AddKeybindToCurrentScene()
    local scene = SCENE_MANAGER:GetCurrentScene()
    KEYBIND_STRIP:AddKeybindButtonGroup(MPL_recipeMenuKeybindGroup)
end

local activeList = nil

local function SetUpdateScrollList(shouldUpdate, list)
    if shouldUpdate and list ~= nil then
        activeList = list  -- store the EXACT list you hook

        KEYBIND_STRIP:AddKeybindButtonGroup(MPL_recipeMenuKeybindGroup)

        list:SetOnTargetDataChangedCallback(function(_, targetData)
            if type(targetData.default) == "string" and targetData.default:find("|H") then
                currentPlanLink = targetData.default
                zo_callLater(function()
                    GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_LEFT_TOOLTIP)
                    GAMEPAD_TOOLTIPS:LayoutLink(GAMEPAD_LEFT_TOOLTIP, targetData.default)
                end, 150)
            end
        end)

    else
        KEYBIND_STRIP:RemoveKeybindButtonGroup(MPL_recipeMenuKeybindGroup)

        if activeList then
            activeList:SetOnTargetDataChangedCallback(nil)
            activeList = nil
        end
    end
end

local function HookConsoleDialogBack(onBack)
    for _, group in pairs(KEYBIND_STRIP.keybindGroups) do
        for _, button in ipairs(group) do
            if button.keybind == "UI_SHORTCUT_NEGATIVE" and not button._mplHooked then
                button._mplHooked = true

                local original = button.callback

                button.callback = function(...)
                    onBack()

                    if original then
                        original(...)
                    end
                end

                return true
            end
        end
    end

    return false
end


function MPL.ShowPlanList(labelTextFunc, craftType, extraFilterFunc)
    local settings = LibConsoleDialogs:Create(labelTextFunc)

    MPL.ActivePlanDialog = settings

    local items = {}

    local numRecipeLists = GetNumRecipeLists()

    for recipeListIndex = 17, numRecipeLists do
        local _, numRecipes = GetRecipeListInfo(recipeListIndex)

        for recipeIndex = 1, numRecipes do
            local isKnown, recipeName, _, _, _, _, tradeskill, resultItemID =
                GetRecipeInfo(recipeListIndex, recipeIndex)

            if useTrackedCharacter then
                isKnown = IsKnownByMainCrafter(resultItemID)
                --isKnown = MasterPlanList.trackedCharacterPlans[resultItemID]
            end

            if tradeskill == craftType and not DISCONTINUED_PLANS[resultItemID] then
                local includeItem = true

                if selectedPlans == "Known Plans" and not isKnown then
                    includeItem = false
                elseif selectedPlans == "Unknown Plans" and isKnown then
                    includeItem = false
                end

                if includeItem and filteredName ~= "" and not string.find(string.lower(recipeName), string.lower(filteredName)) then
                    includeItem = false
                end

                if includeItem and extraFilterFunc then
                    includeItem = extraFilterFunc(resultItemID, recipeName)
                end

                if includeItem then
                    local itemLink = string.format("|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", resultItemID)
                    local recipeLink = string.format("|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
                        LCK.GetSourceItemIdFromResultItem(resultItemID))

                    local displayName = isKnown
                        and string.format("|c00ff00(Known)|r %s", recipeLink)
                        or string.format("|cff0000(Unknown) %s|r", recipeLink)

                    table.insert(items, {
                        label = displayName,
                        name = GetItemLinkName(itemLink),
                        link = recipeLink,
                    })
                end
            end
        end
    end

        table.sort(items, function(a, b)
        return zo_strlower(a.name) < zo_strlower(b.name)
    end)

    for _, entry in ipairs(items) do
        local button = {
            type = LibHarvensAddonSettings.ST_BUTTON,
            label = entry.label,
            buttonText = "Put Recipe Link in Chat Box",
            default = entry.link,
            clickHandler = function(control, button)
                InputChat(entry.link)
                zo_callLater(function()
                    GAMEPAD_TOOLTIPS:LayoutLink(GAMEPAD_LEFT_TOOLTIP, entry.link)
                end, 150)
            end
        }
        settings:AddSetting(button)
    end

    settings:Show()
    subFurnishingMenuOpen = true

    currentScrollList = LibHarvensAddonSettings.scrollList:GetMainList()
    local entries = currentScrollList.dataList

    if entries and entries[1] then
        currentPlanLink = entries[1].default
        zo_callLater(function()
            GAMEPAD_TOOLTIPS:LayoutLink(GAMEPAD_LEFT_TOOLTIP,  entries[1].default)
        end, 150)
    end

    SetUpdateScrollList(true, currentScrollList)

    HookConsoleDialogBack(function()
        if subFurnishingMenuOpen or subRecipeMenuOpen then
            LibHarvensAddonSettings:GoBack()
        end
    end)

end


function MPL.GetBlueprints()
    MPL.ShowPlanList(MPL.GetBlueprintLabelText, CRAFTING_TYPE_WOODWORKING)
end

function MPL.GetDesigns()
    MPL.ShowPlanList(MPL.GetDesignLabelText, CRAFTING_TYPE_PROVISIONING)
end

function MPL.GetDiagrams()
    local extraFilter = function(resultItemID, recipeName)
        return resultItemID ~= 125530 -- Exclude Dwarven Cap
    end
    MPL.ShowPlanList(MPL.GetDiagramLabelText, CRAFTING_TYPE_BLACKSMITHING, extraFilter)
end

function MPL.GetFormulas()
    MPL.ShowPlanList(MPL.GetFormulaLabelText, CRAFTING_TYPE_ALCHEMY)
end

function MPL.GetPatterns()
    MPL.ShowPlanList(MPL.GetPatternLabelText, CRAFTING_TYPE_CLOTHIER)
end

function MPL.GetPraxis()
    MPL.ShowPlanList(MPL.GetPraxisLabelText, CRAFTING_TYPE_ENCHANTING)
end

function MPL.GetSketches()
    MPL.ShowPlanList(MPL.GetSketchLabelText, CRAFTING_TYPE_JEWELRYCRAFTING)
end

--Recipe Logic
function MPL.GetFoodRecipeCount()
	totalFoodRecipes = 0
    knownFoodRecipes = 0

    local numRecipeLists = GetNumRecipeLists()
    for recipeListIndex = 1, 17 do
        local recipeListName, numRecipes = GetRecipeListInfo(recipeListIndex)
        for recipeIndex = 1, numRecipes do
            local isKnown, recipeName, _, _, _, specialIngredientType, tradeSkillType, resultItemID = GetRecipeInfo(recipeListIndex, recipeIndex)

            if useTrackedCharacter then
                isKnown = IsKnownByMainCrafter(resultItemID)
                --isKnown = MasterPlanList.trackedCharacterRecipes[resultItemID]
            end

            local includeItem = true

            if filteredRecipes ~= "" and string.find(string.lower(recipeName), string.lower(filteredRecipes)) == nil then
                includeItem = false
            end

            if  includeItem and  specialIngredientType == PROVISIONER_SPECIAL_INGREDIENT_TYPE_SPICES and recipeName ~= "Old Orsinium Blood Soup" then
                totalFoodRecipes = totalFoodRecipes + 1
                if isKnown then
                knownFoodRecipes = knownFoodRecipes + 1
                end
            end

        end
    end
end

function MPL.GetDrinkRecipeCount()
	totalDrinkRecipes = 0
    knownDrinkRecipes = 0

    local numRecipeLists = GetNumRecipeLists()
    for recipeListIndex = 1, 17 do
        local recipeListName, numRecipes = GetRecipeListInfo(recipeListIndex)
        for recipeIndex = 1, numRecipes do
            local isKnown, recipeName, _, _, _, specialIngredientType, tradeSkillType, resultItemID = GetRecipeInfo(recipeListIndex, recipeIndex)

            if useTrackedCharacter then
                isKnown = IsKnownByMainCrafter(resultItemID)
                --isKnown = MasterPlanList.trackedCharacterRecipes[resultItemID]
            end

            local includeItem = true

            if filteredRecipes ~= "" and string.find(string.lower(recipeName), string.lower(filteredRecipes)) == nil then
                includeItem = false
            end

            if  includeItem and specialIngredientType == PROVISIONER_SPECIAL_INGREDIENT_TYPE_FLAVORING then
                totalDrinkRecipes = totalDrinkRecipes + 1
                if isKnown then
                knownDrinkRecipes = knownDrinkRecipes + 1
                end
            end

        end
    end
end

function MPL.GetRecipeCount()
   MPL:GetFoodRecipeCount()
   MPL:GetDrinkRecipeCount()

	totalRecipes = 0
    knownRecipes = 0

   local numRecipeLists = GetNumRecipeLists()
   for recipeListIndex = 1, 17 do
        local recipeListName, numRecipes = GetRecipeListInfo(recipeListIndex)
        for recipeIndex = 1, numRecipes do
            local isKnown, recipeName, _, _, _, specialIngredientType, tradeSkillType, resultItemID = GetRecipeInfo(recipeListIndex, recipeIndex)

            if useTrackedCharacter then
                isKnown = IsKnownByMainCrafter(resultItemID)
                --isKnown = MasterPlanList.trackedCharacterRecipes[resultItemID]
            end

            if  specialIngredientType ~= PROVISIONER_SPECIAL_INGREDIENT_TYPE_FURNISHING and recipeName ~= "Old Orsinium Blood Soup" then
                totalRecipes = totalRecipes + 1
                if isKnown then
                knownRecipes = knownRecipes + 1
                end
            end

        end
   end
end

function MPL:GetDrinkRecipes()
    local settings = LibConsoleDialogs:Create(MPL.GetDrinkRecipeLabelText)
    local items = {}

    local numRecipeLists = GetNumRecipeLists()
    for recipeListIndex = 1, 16 do
        local listName, numRecipes = GetRecipeListInfo(recipeListIndex)
        for recipeIndex = 1, numRecipes do
            local isKnown, recipeName, _, _, _, specialIngredientType, tradeskill, resultItemID = GetRecipeInfo(recipeListIndex, recipeIndex)

            if useTrackedCharacter then
                isKnown = IsKnownByMainCrafter(resultItemID)
                --isKnown = MasterPlanList.trackedCharacterRecipes[resultItemID]
            end

            if specialIngredientType == PROVISIONER_SPECIAL_INGREDIENT_TYPE_FLAVORING then
                local includeItem = true
                if selectedRecipes == "Known Recipes" and not isKnown then
                    includeItem = false
                elseif selectedRecipes == "Unknown Recipes" and isKnown then
                    includeItem = false
                end

                if includeItem and filteredRecipes ~= "" and string.find(string.lower(recipeName), string.lower(filteredRecipes)) == nil then
                    includeItem = false
                end

                if includeItem then
                    local itemLink = string.format("|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", resultItemID)
                    local recipeLink = string.format("|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", LCK.GetSourceItemIdFromResultItem(resultItemID))
                    
                    local displayName = string.format("|c00ff00(Known)|r %s", recipeLink)

                    if not isKnown then
                        displayName = string.format("|cff0000(Unknown) %s|r", recipeLink)
                    end
             
                    table.insert(items, {
                        label = displayName,
                        name = GetItemLinkName(itemLink),
                        link = recipeLink,
                    })
                end
            end
        end
    end

    table.sort(items, function(a, b)
        return zo_strlower(a.name) < zo_strlower(b.name)
    end)

    for _, entry in ipairs(items) do
        local button = {
           type = LibHarvensAddonSettings.ST_BUTTON,
            label = entry.label,
            buttonText = "Put Recipe Link in Chat Box",
            default = entry.link,
            clickHandler = function(control, button)
                InputChat(entry.link)
                zo_callLater(function()
                    GAMEPAD_TOOLTIPS:LayoutLink(GAMEPAD_LEFT_TOOLTIP, entry.link)
                end, 150)
            end
        }
        settings:AddSetting(button)
    end

    settings:Show()
    subRecipeMenuOpen = true

     currentScrollList = LibHarvensAddonSettings.scrollList:GetMainList()
    local entries = currentScrollList.dataList

    if entries and entries[1] then
        currentPlanLink = entries[1].default
        zo_callLater(function()
            GAMEPAD_TOOLTIPS:LayoutLink(GAMEPAD_LEFT_TOOLTIP,  entries[1].default)
        end, 150)
    end

    SetUpdateScrollList(true, currentScrollList)

    HookConsoleDialogBack(function()
        if subFurnishingMenuOpen or subRecipeMenuOpen then
            LibHarvensAddonSettings:GoBack()
        end
    end)
end

function MPL:GetFoodRecipes()
    local settings = LibConsoleDialogs:Create(MPL.GetFoodRecipeLabelText)
    local items = {}

    local numRecipeLists = GetNumRecipeLists()
    for recipeListIndex = 1, 16 do
        local listName, numRecipes = GetRecipeListInfo(recipeListIndex)
        for recipeIndex = 1, numRecipes do
            local isKnown, recipeName, _, _, _, specialIngredientType, tradeskill, resultItemID = GetRecipeInfo(recipeListIndex, recipeIndex)

            if useTrackedCharacter then
                isKnown = IsKnownByMainCrafter(resultItemID)
                --isKnown = MasterPlanList.trackedCharacterRecipes[resultItemID]
            end

            if specialIngredientType == PROVISIONER_SPECIAL_INGREDIENT_TYPE_SPICES then
                local includeItem = true
                if selectedRecipes == "Known Recipes" and not isKnown then
                    includeItem = false
                elseif selectedRecipes == "Unknown Recipes" and isKnown then
                    includeItem = false
                end

                if includeItem and filteredRecipes ~= "" and string.find(string.lower(recipeName), string.lower(filteredRecipes)) == nil then
                    includeItem = false
                end

                if includeItem and recipeName ~= "Old Orsinium Blood Soup" then
                    local itemLink = string.format("|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", resultItemID)
                    local recipeLink = string.format("|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", LCK.GetSourceItemIdFromResultItem(resultItemID))
                    
                    local displayName = string.format("|c00ff00(Known)|r %s", recipeLink)

                    if not isKnown then
                        displayName = string.format("|cff0000(Unknown) %s|r", recipeLink)
                    end
             
                    table.insert(items, {
                        label = displayName,
                        name = GetItemLinkName(itemLink),
                        link = recipeLink,
                    })
                end
            end
        end
    end

    table.sort(items, function(a, b)
        return zo_strlower(a.name) < zo_strlower(b.name)
    end)

    for _, entry in ipairs(items) do
        local button = {
            type = LibHarvensAddonSettings.ST_BUTTON,
            label = entry.label,
            buttonText = "Put Recipe Link in Chat Box",
            default = entry.link,
            clickHandler = function(control, button)
                InputChat(entry.link)
                zo_callLater(function()
                    GAMEPAD_TOOLTIPS:LayoutLink(GAMEPAD_LEFT_TOOLTIP, entry.link)
                end, 150)
            end
        }
        settings:AddSetting(button)
    end

    settings:Show()
    subRecipeMenuOpen = true

     currentScrollList = LibHarvensAddonSettings.scrollList:GetMainList()
    local entries = currentScrollList.dataList

    if entries and entries[1] then
        currentPlanLink = entries[1].default
        zo_callLater(function()
            GAMEPAD_TOOLTIPS:LayoutLink(GAMEPAD_LEFT_TOOLTIP,  entries[1].default)
        end, 150)
    end

    SetUpdateScrollList(true, currentScrollList)

    HookConsoleDialogBack(function()
        if subFurnishingMenuOpen or subRecipeMenuOpen then
            LibHarvensAddonSettings:GoBack()
        end
    end)

end

function MPL.SetTrackedCharacterRecipeKnowledge()
    local recipeStatus = {}

    local numRecipeLists = GetNumRecipeLists()
    for recipeListIndex = 1, 17 do
        local recipeListName, numRecipes = GetRecipeListInfo(recipeListIndex)
        for recipeIndex = 1, numRecipes do
            local isKnown, recipeName, _, _, _, specialIngredientType, tradeSkillType, resultItemID = GetRecipeInfo(recipeListIndex, recipeIndex)

            if  specialIngredientType ~= PROVISIONER_SPECIAL_INGREDIENT_TYPE_FURNISHING and recipeName ~= "Old Orsinium Blood Soup" then
                recipeStatus[resultItemID] = isKnown
            end
        end
    end

    MasterPlanList.trackedCharacterRecipes = recipeStatus
end
 
function MPL.GetRecipeLabelText()
    return string.format("Known Recipes\n%d / %d", knownRecipes, totalRecipes)
end

function MPL.GetDrinkRecipeLabelText()
    return string.format("Drink Recipes\n%d / %d", knownDrinkRecipes, totalDrinkRecipes)
end

function MPL.GetFoodRecipeLabelText()
    return string.format("Food Recipes\n%d / %d", knownFoodRecipes, totalFoodRecipes)
end

local MOTIF_MENU = {}

function MPL.GetMotifList()
    LibHarvensAddonSettings:GoBack()

    local settings = LibConsoleDialogs:Create("Motif List")

    local label = {
        type = LibHarvensAddonSettings.ST_LABEL,
        label = MPL.GetRecipeLabelText,
    }
    settings:AddSetting(label)

    local edit = {
    type = LibHarvensAddonSettings.ST_EDIT,
    label = "Filter by name",
    setFunction = function(value)
        if filteredMotifs ~= value then
            filteredMotifs = value
            MPL:GetMotifList()
        end
    end,
    getFunction = function()
        return filteredMotifs
    end,
    disable = function()
        return areSettingsDisabled
    end
    }
    settings:AddSetting(edit)

    local dropdown = {
        type = LibHarvensAddonSettings.ST_DROPDOWN,
        label = "Show",
        setFunction = function(combobox, name, item)
            selectedMotifs = name
            MPL:GetMotifList()
        end,
        getFunction = function()
            return selectedMotifs
        end,
        default = "All Motifs",
        items = {
            {
                name = "All Motifs",
                data = 0
            },
            {
                name = "Known Full Books",
                data = 1
            },
            {
                name = "Partial/Unknown Books",
                data = 2
            }
        },
        disable = function()
            return areSettingsDisabled
        end
    }
    settings:AddSetting(dropdown)

    local characterID = GetCurrentCharacterId();

    if useTrackedCharacter then       
        local mainId = MPL.LCKCurrentServer == "NA" and MasterPlanList.mainNACrafterID or MasterPlanList.mainEUCrafterID

        if mainId then
            characterID = mainId
        end
    end

    local motifs = {}
    for _, styleId in ipairs(LCK.GetMotifStyles()) do
        local items = LCK.GetMotifItemsFromStyle(styleId)
        if items then
            table.insert(motifs, {
                styleId = styleId,
                items = items
            })
        end
    end

    table.sort(motifs, function(a, b)
        return a.items.number < b.items.number
    end)

    local fullKnownBooks = 0
    local totalBooks = #motifs

    for _, motifData in ipairs(motifs) do
        local styleId = motifData.styleId
        local items = motifData.items

        local motifLabel = GetItemStyleName(styleId)
        local known = 0
        local totalChapters = 14

        local motifTooltip = ""
        for chapterNum, chapterLink in ipairs(items.chapters) do
            local motifLink = LCK.GetItemLinkFromItemId(chapterLink)

            if LCK.GetItemKnowledgeForCharacter(chapterLink, nil, characterID) == LCK.KNOWLEDGE_KNOWN then
                known = known + 1
                motifLink = "|c00ff00(KNOWN)|r " .. motifLink
            else
                motifLink = "|cff0000(UNKNOWN)|r " .. motifLink
            end

            motifTooltip = motifTooltip .. motifLink .. "\n"
        end

        if #items.chapters == 0 then
            local motifLink = LCK.GetItemLinkFromItemId(items.books[1])

            totalChapters = 1
            if LCK.GetItemKnowledgeForCharacter(items.books[1], nil, characterID) == LCK.KNOWLEDGE_KNOWN then
                known = 1
                motifLink = "|c00ff00(KNOWN)|r " .. motifLink
                else
                motifLink = "|cff0000(UNKNOWN)|r " .. motifLink
            end

            motifTooltip = motifTooltip .. motifLink
        end

        if known == totalChapters then
            fullKnownBooks = fullKnownBooks + 1
        end

        local buttonName = string.format("Crafting Motif %d: %s (%d/%d)", items.number, motifLabel, known, totalChapters)

        if items.crown then
            buttonName = string.format("Crown Crafting Motif %d: %s (%d/%d)", items.number, motifLabel, known, totalChapters)
        end

        local includeButton = true

        if selectedMotifs == "Known Full Books" and not known == totalChapters then
           includeButton = false
        elseif selectedMotifs == "Partial/Unknown Books" and known == totalChapters then
           includeButton = false
        end

        if includeButton and filteredMotifs ~= "" and string.find(string.lower(buttonName), string.lower(filteredMotifs)) == nil then
            includeButton = false
        end

        if includeButton then
            local button = {
                type = LibHarvensAddonSettings.ST_BUTTON,
                label = buttonName,
                tooltip = motifTooltip
            }
            settings:AddSetting(button)
        end
    end

    MOTIF_MENU = settings 
    MOTIF_MENU.settings[1].labelText = string.format("Full Sets Known \n %d/%d", fullKnownBooks, totalBooks)
    MOTIF_MENU:Show()
end

function PlanListStateChange(oldState, newState)
    if newState == SCENE_HIDING then
        SetUpdateScrollList(false, currentScrollList)
        if subFurnishingMenuOpen then
            subFurnishingMenuOpen = false
            MPL:OpenFurnishingPlanMenu()
        elseif subRecipeMenuOpen then
            subRecipeMenuOpen = false
            MPL:OpenRecipeMenu()
        elseif mainFurnishingMenuOpen or mainRecipeMenuOpen then
            mainFurnishingMenuOpen = false
            mainRecipeMenuOpen = false
            MPL:OpenMainMenu()
        elseif motifMenuOpen then
            motifMenuOpen = false
            MPL:OpenMainMenu()
        end
    end

end

local qrDrawn = false

local function ShowDonationWindow()

    if LibQRCode then

    if qrDrawn == false then
        LibQRCode.DrawQRCode(DonationWindowQRCode, "https://www.paypal.com/donate/?business=K56NCFXNGRW7E&no_recurring=0&item_name=The+Craft+Completionist+List+made+my+life+easier%21&currency_code=USD")
        qrDrawn = true;
    end

    SCENE_MANAGER:Show("DonationScene")

    else
        MPL.chat:Print("LibQRCode is not installed. Donation QR code not available. You can donate directly via PayPal to @The702Guy.")
    end
end

-- == MENU COMMANDS ==

local showHiddenCharacters = false
local currentCategory = 1

local function NextCategory()
    currentCategory = currentCategory + 1
    if currentCategory > 4 then
        currentCategory = 1
    end

    MPL.UpdateResearchCategory(currentCategory)
end

local function PreviousCategory()
    currentCategory = currentCategory - 1
    if currentCategory < 1 then
        currentCategory = 4
    end

    MPL.UpdateResearchCategory(currentCategory)
end

local allCharactersHidden = false;

local function NextCharacter()
    local count = #MPL.characterIds
    if count == 0 then return end

    local startIndex = MPL.currentCharacterIndex

    repeat
        MPL.currentCharacterIndex = MPL.currentCharacterIndex + 1
        if MPL.currentCharacterIndex > count then
            MPL.currentCharacterIndex = 1
        end

        local charId = MPL.characterIds[MPL.currentCharacterIndex]
        local data = MasterPlanList.researchCharacters[charId]

        if not data.hidden or showHiddenCharacters then
            allCharactersHidden = false
            MPL.LoadSavedResearch(MPL.currentCharacterIndex)
            return
        end

    until MPL.currentCharacterIndex == startIndex

    allCharactersHidden = true
    MPL.UpdateResearchCategory(currentCategory)
end


local function PreviousCharacter()
    local count = #MPL.characterIds
    if count == 0 then return end

    local startIndex = MPL.currentCharacterIndex

    repeat
        MPL.currentCharacterIndex = MPL.currentCharacterIndex - 1
        if MPL.currentCharacterIndex < 1 then
            MPL.currentCharacterIndex = count
        end

        local charId = MPL.characterIds[MPL.currentCharacterIndex]
        local data = MasterPlanList.researchCharacters[charId]

       if not data.hidden or showHiddenCharacters then
            allCharactersHidden = false
            MPL.LoadSavedResearch(MPL.currentCharacterIndex)
            return
       end

    until MPL.currentCharacterIndex == startIndex

    allCharactersHidden = true
    MPL.UpdateResearchCategory(currentCategory)
end

local function GetNotificationSetting()

    if MPL.DoResearchNotification then
        return "Turn Alerts Off"
    end
    return "Turn Alerts On"
end

local function ToggleNotificationSetting()
    MasterPlanList.researchNotification = not MasterPlanList.researchNotification
    MPL.DoResearchNotification = MasterPlanList.researchNotification
end

local function ToggleCharacterHidden(charId)
    if charId == nil then charId = MPL.loadedResearchID end

    local data = MasterPlanList.researchCharacters[charId]
    if not data then return end

    data.hidden = not data.hidden

    if data.hidden and not showHiddenCharacters or not data.hidden and allCharactersHidden then NextCharacter() end

    return data.hidden
end

local function GetCharacterHidden(charId)
    local data = MasterPlanList.researchCharacters[charId]
    if not data then return false end

    return data.hidden
end

-- == MAIN MENU ==

local lastSelectedMainSection = 4

local settings = LibConsoleDialogs:Create("702\'s Craft Completionist List")

local section = {
    type = LibHarvensAddonSettings.ST_SECTION,
    label = "Donations"
}
settings:AddSetting(section)

local button = {
    type = LibHarvensAddonSettings.ST_BUTTON,
    label = "|cFFFF00Donate|r",
    buttonText = "Open QR Code",
    tooltip = "If this addon helped you out and you'd like to donate, you can either do PayPal direct to @The702Guy or click this button to generate a QR Code. \n\nNOTE: You may get a UI error clicking the first time, just dismiss the UI error then click again and it will work. Thank you for your support!",
    clickHandler = function(control, button)
        ShowDonationWindow()
    end,
}
settings:AddSetting(button)

local section = {
    type = LibHarvensAddonSettings.ST_SECTION,
    label = loadedCharacter
}
settings:AddSetting(section)

local button = {
    type = LibHarvensAddonSettings.ST_BUTTON,
    label = "Furnishing Plan List",
    buttonText = "Open Furnishing Plan List",
    clickHandler = function(control, button)
        MPL:OpenFurnishingPlanMenu()
        lastSelectedMainSection = 4
    end,
    disable = function()
        return areSettingsDisabled
    end
}
settings:AddSetting(button)

local button = {
    type = LibHarvensAddonSettings.ST_BUTTON,
    label = "Recipe List",
    buttonText = "Open Recipe List",
    clickHandler = function(control, button)
        MPL:OpenRecipeMenu()
        lastSelectedMainSection = 5
    end,
    disable = function()
        return areSettingsDisabled
    end
}
settings:AddSetting(button)

local button = {
    type = LibHarvensAddonSettings.ST_BUTTON,
    label = "Motif List",
    buttonText = "Open Motif List",
    clickHandler = function(control, button)
        MPL:OpenMotifMenu()
        lastSelectedMainSection = 6
    end,
    disable = function()
        return areSettingsDisabled
    end
}
settings:AddSetting(button)

local button = {
    type = LibHarvensAddonSettings.ST_BUTTON,
    label = "Open Research Menu",
    buttonText = "Open Research Menu",
    clickHandler = function(control, button)
        MPL:ShowResearchPanel()
    end,
    disable = function()
        return areSettingsDisabled
    end
}
settings:AddSetting(button)

local dropdown = {
    type = LibHarvensAddonSettings.ST_DROPDOWN,
    label = "Show Research For This Character",
    setFunction = function(combobox, name, item)
        ToggleCharacterHidden(GetCurrentCharacterId())
    end,
    getFunction = function()
        return GetCharacterHidden(GetCurrentCharacterId()) and "Hide" or "Show"
    end,
    default = "Show",
    items = {
        {
            name = "Show",
            data = 0
        },
        {
            name = "Hide",
            data = 1
        },
    },
    disable = function()
        return areSettingsDisabled
    end
}
settings:AddSetting(dropdown)


local section = {
    type = LibHarvensAddonSettings.ST_SECTION,
    label = "Character Selection"
}
settings:AddSetting(section)

local dropdown = {
    type = LibHarvensAddonSettings.ST_DROPDOWN,
    label = "Knowledge to Show",
    setFunction = function(combobox, name, item)
        characterChoice = name
        MPL:ChangeLoadedCharacter()
    end,
    getFunction = function()
        return characterChoice
    end,
    default = "This Character",
    items = {
        {
            name = "This Character",
            data = 0
        },
        {
            name = "Main Crafter",
            data = 1
        },
    },
    disable = function()
        return areSettingsDisabled
    end
}
settings:AddSetting(dropdown)

local button = {
    type = LibHarvensAddonSettings.ST_BUTTON,
    label = "Set current character as Main Crafter",
    buttonText = "Confirm",
    clickHandler = function(control, button)
        MPL:SetNewTrackedCharacter()
        --MPL:SetTrackedCharacterKnowledge()
        --MPL:SetTrackedCharacterRecipeKnowledge()
    end,
    disable = function()
        return areSettingsDisabled
    end
}
settings:AddSetting(button)

local button = {
    type = LibHarvensAddonSettings.ST_BUTTON,

    label = function()
        if MPL:IsCharacterTracked() then
            return "Remove character from account wide tracking"
        else
            return "Add character to account wide tracking"
        end
    end,

    buttonText = function()
        return MPL:IsCharacterTracked() and "Remove" or "Add"
    end,

    clickHandler = function(control, button)
        if MPL:IsCharacterTracked() then
            MPL:RemoveFromAccountWideTracking()
        else
            MPL:AddToAccountWideTracking()
        end
    end,

    disable = function()
        return areSettingsDisabled
    end
}

settings:AddSetting(button)

local MAIN_MENU = settings

-- == FURNISHING PLAN MENU ==

local lastSelectedFurnishingSection = 2

local settings = LibConsoleDialogs:Create("Furnishing Plan List")
 
local label = {
    type = LibHarvensAddonSettings.ST_LABEL,
    label = MPL.GetPlanLabelText,
}
settings:AddSetting(label)


local edit = {
    type = LibHarvensAddonSettings.ST_EDIT,
    label = "Filter by name",
    setFunction = function(value)
        filteredName = value
        MPL:UpdateFurnishingButtonLabels()
    end,
    getFunction = function()
        return filteredName
    end,
    disable = function()
        return areSettingsDisabled
    end
}
settings:AddSetting(edit)

local dropdown = {
    type = LibHarvensAddonSettings.ST_DROPDOWN,
    label = "Show",
    setFunction = function(combobox, name, item)
        selectedPlans = name
    end,
    getFunction = function()
        return selectedPlans
    end,
    default = "All Plans",
    items = {
        {
            name = "All Plans",
            data = 0
        },
        {
            name = "Known Plans",
            data = 1
        },
        {
            name = "Unknown Plans",
            data = 2
        }
    },
    disable = function()
        return areSettingsDisabled
    end
}
settings:AddSetting(dropdown)
 
local blueprintsButton = {
    type = LibHarvensAddonSettings.ST_BUTTON,
    label = MPL.GetBlueprintLabelText,
    buttonText = "Open Blueprint Library",
    clickHandler = function(control, blueprintsButton)
        MPL:GetBlueprints()
        lastSelectedFurnishingSection = 4
    end,
    disable = function()
        return areSettingsDisabled
    end
}
settings:AddSetting(blueprintsButton)

local button = {
    type = LibHarvensAddonSettings.ST_BUTTON,
    label = MPL.GetDesignLabelText,
    buttonText = "Open Design Library",
    clickHandler = function(control, button)
        MPL:GetDesigns()
        lastSelectedFurnishingSection = 5
    end,
    disable = function()
        return areSettingsDisabled
    end
}
settings:AddSetting(button)

local button = {
    type = LibHarvensAddonSettings.ST_BUTTON,
    label = MPL.GetDiagramLabelText,
    buttonText = "Open Diagram Library",
    clickHandler = function(control, button)
        MPL:GetDiagrams()
        lastSelectedFurnishingSection = 6
    end,
    disable = function()
        return areSettingsDisabled
    end
}
settings:AddSetting(button)

local button = {
    type = LibHarvensAddonSettings.ST_BUTTON,
    label = MPL.GetFormulaLabelText,
    buttonText = "Open Formula Library",
    clickHandler = function(control, button)
        MPL:GetFormulas()
        lastSelectedFurnishingSection = 7
    end,
    disable = function()
        return areSettingsDisabled
    end
}
settings:AddSetting(button)

local button = {
    type = LibHarvensAddonSettings.ST_BUTTON,
    label = MPL.GetPatternLabelText,
    buttonText = "Open Pattern Library",
    clickHandler = function(control, button)
        MPL:GetPatterns()
        lastSelectedFurnishingSection = 8
    end,
    disable = function()
        return areSettingsDisabled
    end
}
settings:AddSetting(button)

local button = {
    type = LibHarvensAddonSettings.ST_BUTTON,
    label = MPL.GetPraxisLabelText,
    buttonText = "Open Praxis Library",
    clickHandler = function(control, button)
        MPL:GetPraxis()
        lastSelectedFurnishingSection = 9
    end,
    disable = function()
        return areSettingsDisabled
    end
}
settings:AddSetting(button)

local button = {
    type = LibHarvensAddonSettings.ST_BUTTON,
    label = MPL.GetSketchLabelText,
    buttonText = "Open Sketch Library",
    clickHandler = function(control, button)
        MPL:GetSketches()
        lastSelectedFurnishingSection = 10
    end,
    disable = function()
        return areSettingsDisabled
    end
}
settings:AddSetting(button)
 
local FURNISHING_PLAN_MENU = settings

function MPL.UpdateFurnishingButtonLabels()
    MPL:GetBlueprintCount()
    MPL:GetDesignCount()
    MPL:GetDiagramCount()
    MPL:GetFormulaCount()
    MPL:GetPatternCount()
    MPL:GetPraxisCount()
    MPL:GetSketchCount()
    FURNISHING_PLAN_MENU.settings[4].labelText = MPL.GetBlueprintLabelText
    FURNISHING_PLAN_MENU.settings[5].labelText = MPL.GetDesignLabelText
    FURNISHING_PLAN_MENU.settings[6].labelText = MPL.GetDiagramLabelText
    FURNISHING_PLAN_MENU.settings[7].labelText = MPL.GetFormulaLabelText
    FURNISHING_PLAN_MENU.settings[8].labelText = MPL.GetPatternLabelText
    FURNISHING_PLAN_MENU.settings[9].labelText = MPL.GetPraxisLabelText
    FURNISHING_PLAN_MENU.settings[10].labelText = MPL.GetSketchLabelText
    FURNISHING_PLAN_MENU:UpdateControls()
end


-- Food/Drink Recipe Menu
local lastSelectedRecipeSection = 2

local settings = LibConsoleDialogs:Create("Recipe List")
 
local label = {
    type = LibHarvensAddonSettings.ST_LABEL,
    label = MPL.GetRecipeLabelText,
}
settings:AddSetting(label)

local edit = {
    type = LibHarvensAddonSettings.ST_EDIT,
    label = "Filter by name",
    setFunction = function(value)
        filteredRecipes = value
        MPL:UpdateRecipeButtonLabels()
    end,
    getFunction = function()
        return filteredRecipes
    end,
    disable = function()
        return areSettingsDisabled
    end
}
settings:AddSetting(edit)

local dropdown = {
    type = LibHarvensAddonSettings.ST_DROPDOWN,
    label = "Show",
    setFunction = function(combobox, name, item)
        selectedRecipes = name
    end,
    getFunction = function()
        return selectedRecipes
    end,
    default = "All Recipes",
    items = {
        {
            name = "All Recipes",
            data = 0
        },
        {
            name = "Known Recipes",
            data = 1
        },
        {
            name = "Unknown Recipes",
            data = 2
        }
    },
    disable = function()
        return areSettingsDisabled
    end
}
settings:AddSetting(dropdown)
 
local button = {
    type = LibHarvensAddonSettings.ST_BUTTON,
    label = MPL.GetFoodRecipeLabelText,
    buttonText = "Open Food Recipe Library",
    clickHandler = function(control, button)
        MPL:GetFoodRecipes()
        lastSelectedRecipeSection = 4
    end,
    disable = function()
        return areSettingsDisabled
    end
}
settings:AddSetting(button)

local button = {
    type = LibHarvensAddonSettings.ST_BUTTON,
    label = MPL.GetDrinkRecipeLabelText,
    buttonText = "Open Drink Recipe Library",
    clickHandler = function(control, button)
        MPL:GetDrinkRecipes()
        lastSelectedRecipeSection = 5
    end,
    disable = function()
        return areSettingsDisabled
    end
}
settings:AddSetting(button)

local RECIPE_MENU = settings

function MPL.UpdateRecipeButtonLabels()
    MPL:GetFoodRecipeCount()
    MPL:GetDrinkRecipeCount()
    RECIPE_MENU.settings[4].labelText = MPL.GetFoodRecipeLabelText
    RECIPE_MENU.settings[5].labelText = MPL.GetDrinkRecipeLabelText
    RECIPE_MENU:UpdateControls()
end

function MPL.ChangeLoadedCharacter()
    if characterChoice == "This Character" then
        loadedCharacter = GetUnitName("player")
        useTrackedCharacter = false
    elseif characterChoice == "Main Crafter" then
        loadedCharacter = MPL.LCKCurrentServer == "NA" and MasterPlanList.mainNACrafterName or MasterPlanList.mainEUCrafterName
        useTrackedCharacter = true
    end
    MAIN_MENU.settings[3].labelText = loadedCharacter
    MAIN_MENU:UpdateControls()
end

function MPL.SelectFurnishingListButton()
    local list = LibHarvensAddonSettings.scrollList and LibHarvensAddonSettings.scrollList:GetMainList()
    if not list then return end
    for i, entry in ipairs(list.dataList) do
        if entry and entry.labelText == "Furnishing Plan List" then
            list:SetSelectedIndex(i)
            list:RefreshVisible()
            break
        end
    end
end 

LibConsoleDialogs:RegisterKeybind(
    LORE_LIBRARY_SCENE_GAMEPAD,
    {
        name = "Craft Completionist List",
        callback = function(buttonInfo)
            MPL:OpenMainMenu()
            zo_callLater(function()
                MPL.SelectFurnishingListButton()
            end, 100)
        end,
        visible = true,
        order = 101
    }
)

function MPL.AddToAccountWideTracking()
    local name = GetUnitName("player")
    local id = GetCurrentCharacterId()

    MasterPlanList.trackedCharacters = MasterPlanList.trackedCharacters or {}

    if MasterPlanList.trackedCharacters[id] then
        MPL.chat:Print(string.format("%s is already being tracked.", name))
        return
    end

    MasterPlanList.trackedCharacters[id] = name

    MPL.chat:Print(string.format("CCL will now track plans, recipes, and motif needs for %s.", name))

    MAIN_MENU:UpdateControls()
end

function MPL.RemoveFromAccountWideTracking()
    local id = GetCurrentCharacterId()

    MasterPlanList.trackedCharacters = MasterPlanList.trackedCharacters or {}

    if MasterPlanList.trackedCharacters[id] then
        local name = MasterPlanList.trackedCharacters[id]
        MasterPlanList.trackedCharacters[id] = nil
        MPL.chat:Print(string.format("CCL will no longer track plans, recipes, and motif needs for %s.", name))
        MAIN_MENU:UpdateControls()
    else
        MPL.chat:Print("Character not found in tracked list.")
    end
end

function MPL.IsCharacterTracked()
    local id = GetCurrentCharacterId()
    return MasterPlanList.trackedCharacters and MasterPlanList.trackedCharacters[id] ~= nil
end

MPL_CompletionFragment = ZO_SimpleSceneFragment:New(MPL_CompletionPanel)

local function SetSpecificMenuItem(indexToSet)
    local list = LibHarvensAddonSettings.scrollList and LibHarvensAddonSettings.scrollList:GetMainList()
    if not list then return end

    list:SetSelectedIndex(indexToSet)
    list:RefreshVisible()
end

MPL.NACharacterList = nil
MPL.EUCharacterList = nil

function MPL.BuildServerCharacterList(server)
    local set = {}
    local chars = LCK.GetCharacterList(server)

    for _, entry in ipairs(chars) do
        set[entry.id] = true
    end

    return set
end


function MPL.OpenMainMenu()
    LibHarvensAddonSettings:GoBack()
    MAIN_MENU:Show()
    --local scene = SCENE_MANAGER:GetCurrentScene()
    --scene:AddFragment(MPL_CompletionFragment)
    ---LibHarvensAddonSettings.scene:UnRegisterCallback("StateChange", OnHarvensSceneStateChange)

    SetSpecificMenuItem(lastSelectedMainSection)
    
    lastSelectedMainSection = 4


    LibHarvensAddonSettings.scene:RegisterCallback("StateChange", PlanListStateChange)
end

function MPL.OpenFurnishingPlanMenu()
    LibHarvensAddonSettings:GoBack()
    MPL:GetFurnishingPlanCount()
    if MasterPlanList.trackedCharacter == GetUnitName("player") then
    --MPL:SetTrackedCharacterKnowledge()
    end
    FURNISHING_PLAN_MENU:Show()

    SetSpecificMenuItem(lastSelectedFurnishingSection)

    lastSelectedFurnishingSection = 2

    LibHarvensAddonSettings.scene:UnregisterCallback("StateChange", PlanListStateChange)
    LibHarvensAddonSettings.scene:RegisterCallback("StateChange", PlanListStateChange)  
    mainFurnishingMenuOpen = true
    SetUpdateScrollList(false, currentScrollList)
end

function MPL.OpenRecipeMenu()
    LibHarvensAddonSettings:GoBack()
    MPL:GetRecipeCount()
    if MasterPlanList.trackedCharacter == GetUnitName("player") then
    --MPL:SetTrackedCharacterRecipeKnowledge()
    end
    RECIPE_MENU:Show()

    SetSpecificMenuItem(lastSelectedRecipeSection)

    lastSelectedRecipeSection = 2

    LibHarvensAddonSettings.scene:UnregisterCallback("StateChange", PlanListStateChange)
    LibHarvensAddonSettings.scene:RegisterCallback("StateChange", PlanListStateChange)
    mainRecipeMenuOpen = true
end

function MPL.OpenMotifMenu()
    MPL:GetMotifList()
    LibHarvensAddonSettings.scene:UnregisterCallback("StateChange", PlanListStateChange)
    LibHarvensAddonSettings.scene:RegisterCallback("StateChange", PlanListStateChange)
    motifMenuOpen = true
end

-- == CUSTOM KEYBINDINGS ==


function MPL.UpdateResearchCategory(currentCategory)

     if allCharactersHidden then
        MPL_ResearchPanelCharacterHeader:SetText("")
        MPL_ResearchPanelSkillHeader:SetText("All characters hidden, unhide a character to view research info.")

        for col = 1, 14 do
            _G["MPL_ResearchPanelCol" .. col .. "Header"]:SetHidden(true)
            _G["MPL_ResearchPanelCol" .. col .. "Text"]:SetHidden(true)
            _G["MPL_ResearchPanelCol" .. col .. "BG"]:SetHidden(true)
        end

        MPL.UpdateResearchPanel()
        return
    end


    local craftingSkill = CRAFTING_SKILLS[currentCategory]

    local server = MPL.NACharacterList[MPL.loadedResearchID] and "NA" or "EU"


    MPL_ResearchPanelCharacterHeader:SetText(string.format("%s (%s)", MPL.loadedResearchCharacter, server))
    MPL_ResearchPanelSkillHeader:SetText(CRAFTING_SKILL_NAMES[craftingSkill])

    local columns = MPL.GetResearchColumns(craftingSkill, MPL.loadedResearch)

    for col = 1, 14 do
        local header = _G["MPL_ResearchPanelCol" .. col .. "Header"]
        local text   = _G["MPL_ResearchPanelCol" .. col .. "Text"]
        local bg     = _G["MPL_ResearchPanelCol" .. col .. "BG"]

        if columns[col] then
            header:SetText(columns[col].header or "")
            text:SetText(columns[col].body or "")
            header:SetHidden(false)
            text:SetHidden(false)
            bg:SetHidden(false)
        else
            header:SetHidden(true)
            text:SetHidden(true)
            bg:SetHidden(true)
        end
    end
end

local function UpdateCraftingStationMenu(craftingSkill)

    if allCharactersHidden then
        MPL_CraftStationPanelCharacterHeader:SetText("")
        MPL_CraftStationPanelSkillHeader:SetText("All characters hidden, unhide a character to view research info.")

        for col = 1, 14 do
            _G["MPL_CraftStationPanelCol" .. col .. "Header"]:SetHidden(true)
            _G["MPL_CraftStationPanelCol" .. col .. "Text"]:SetHidden(true)
            _G["MPL_CraftStationPanelCol" .. col .. "BG"]:SetHidden(true)
        end

        return
    end

    local server = MPL.NACharacterList[MPL.loadedResearchID] and "NA" or "EU"


    MPL_CraftStationPanelCharacterHeader:SetText(string.format("%s (%s)", MPL.loadedResearchCharacter, server))
    MPL_CraftStationPanelSkillHeader:SetText(CRAFTING_SKILL_NAMES[craftingSkill])

    local columns = MPL.GetResearchColumns(craftingSkill, MPL.loadedResearch)

    for col = 1, 14 do
        local header = _G["MPL_CraftStationPanelCol" .. col .. "Header"]
        local text   = _G["MPL_CraftStationPanelCol" .. col .. "Text"]
        local bg     = _G["MPL_CraftStationPanelCol" .. col .. "BG"]

        if columns[col] then
            header:SetText(columns[col].header or "")
            text:SetText(columns[col].body or "")
            header:SetHidden(false)
            text:SetHidden(false)
            bg:SetHidden(false)
        else
            header:SetHidden(true)
            text:SetHidden(true)
            bg:SetHidden(true)
        end
    end
end

local function GetHiddenSetting()

    if showHiddenCharacters then
        return "Exclude Hidden Characters"
    end
    return "Include Hidden Characters"
end

local MPL_researchPanelKeybindGroup = {
    {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        name = function()
            return GetNotificationSetting()
        end,
        order = -2000,
        keybind = "UI_SHORTCUT_SECONDARY",
        callback = function()
            ToggleNotificationSetting()
            KEYBIND_STRIP:UpdateCurrentKeybindButtonGroups()
        end,
    },
    {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        name = "Close",
        order = -2000,
        keybind = "UI_SHORTCUT_NEGATIVE",
        callback = function()
            SCENE_MANAGER:Hide("ResearchScene")
        end,
    },
    {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        name = function()
            return GetCharacterHidden(MPL.loadedResearchID) and "Show Character" or "Hide Character"
        end,
        order = -2000,
        keybind = "UI_SHORTCUT_LEFT_STICK",
        callback = function()
            ToggleCharacterHidden(nil)
            KEYBIND_STRIP:UpdateCurrentKeybindButtonGroups()
        end,
    },
    {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        name = function()
            return GetHiddenSetting()
        end,
        order = -2000,
        keybind = "UI_SHORTCUT_RIGHT_STICK",
        callback = function()
            showHiddenCharacters = not showHiddenCharacters
            if MPL.loadedHiddenSetting or not MPL.loadedHiddenSetting and allCharactersHidden then NextCharacter() end
            KEYBIND_STRIP:UpdateCurrentKeybindButtonGroups()
        end,
    },
    {
        name = "← Character",
        order = -2000,
        keybind ="UI_SHORTCUT_INPUT_UP",
        callback = function()
            PreviousCharacter()
            KEYBIND_STRIP:UpdateCurrentKeybindButtonGroups()
        end,
    },
    {
        name = "→ Character",
        order = -2000,
        keybind = "UI_SHORTCUT_INPUT_DOWN",
        callback = function()
            NextCharacter()
            KEYBIND_STRIP:UpdateCurrentKeybindButtonGroups()
        end,
    },
    {
        name = "← Craft",
        order = -2000,
        keybind = "UI_SHORTCUT_LEFT_SHOULDER",
        callback = function()
            PreviousCategory()
        end,
    },
    {
        name = "→ Craft",
        order = -2000,
        keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
        callback = function()
            NextCategory()
        end,
    },
}

-- == CRAFTING STATION RESEARCH PANEL ==

local smithingScene = SCENE_MANAGER:GetScene("gamepad_smithing_creation")

MPL_CraftingFragment = ZO_SimpleSceneFragment:New(MPL_CraftStationPanel)

local MPL_craftingStationResearchKeybindGroup
local MPL_craftingStationKeybindGroups

local function OpenCraftingStationPanel()
    MPL.LoadSavedResearch(MPL.currentCharacterIndex)
    smithingScene:AddFragment(MPL_CraftingFragment)
    MPL_CraftStationPanel:SetDrawLayer(DL_OVERLAY)
    MPL_CraftStationPanel:SetDrawTier(0)
    MPL_CraftStationPanel:SetDrawLevel(9999)
    MPL_CraftStationPanel:SetScale(.9)
    KEYBIND_STRIP:AddKeybindButtonGroup(MPL_craftingStationResearchKeybindGroup)
    KEYBIND_STRIP:RemoveKeybindButtonGroup(MPL_craftingStationKeybindGroup)
    UpdateCraftingStationMenu(MPL.openStation)
end

local function CloseCraftingStationPanel()
    smithingScene:RemoveFragment(MPL_CraftingFragment)
    KEYBIND_STRIP:RemoveKeybindButtonGroup(MPL_craftingStationResearchKeybindGroup)
    if smithingScene:IsShowing() then
        KEYBIND_STRIP:AddKeybindButtonGroup(MPL_craftingStationKeybindGroup)
    end
end


MPL_craftingStationKeybindGroup = {
    {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        name = "Open CCRM",
        order = -2000,
        keybind = "UI_SHORTCUT_LEFT_STICK",
        callback = function()
            OpenCraftingStationPanel()
        end,
    },
}

MPL_craftingStationResearchKeybindGroup = {
    {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        name = "Close CCRM",
        order = 9999,
        keybind = "UI_SHORTCUT_LEFT_STICK",
        callback = function()
            CloseCraftingStationPanel()
        end,
    },
    {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        name = "← Char",
        order = 9999,
        keybind = "UI_SHORTCUT_LEFT_TRIGGER",
        callback = function()
            PreviousCharacter()
        end,
    },
    {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        name = "→ Char",
        order = 9999,
        keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
        callback = function()
            NextCharacter()
        end,
    },
}

-- == RESEARCH MENU SAVING/LOADING] ==

function MPL.ShowResearchPanel()
    showHiddenCharacters = false
    MPL.SaveResearchForCharacter()
    MPL.LoadSavedResearch(MPL.currentCharacterIndex)
    MPL.UpdateResearchCategory(currentCategory)

    SCENE_MANAGER:Show("ResearchScene")
    KEYBIND_STRIP:AddKeybindButtonGroup(MPL_researchPanelKeybindGroup)

    MPL_ResearchPanel:SetScale(.9)

end

local function IsCreationMode()
    return GetCraftingInteractionMode() == ZO_SmithingCreation
end

local function InitScenes()   
    ResearchScene = ZO_Scene:New("ResearchScene", SCENE_MANAGER)

    local panelFragment = ZO_FadeSceneFragment:New(MPL_ResearchPanel)
    ResearchScene:AddFragment(panelFragment)
    ResearchScene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)

    DonationScene = ZO_Scene:New("DonationScene", SCENE_MANAGER)
    DonationScene:AddFragment(ZO_FadeSceneFragment:New(DonationWindow))

    ResearchScene:RegisterCallback("StateChange", function(oldState, newState)
    if newState == SCENE_SHOWING then
        EVENT_MANAGER:RegisterForUpdate("MPL_ResearchUpdate", 1000, MPL.UpdateResearchPanel)
        MPL.UpdateResearchPanel()
        KEYBIND_STRIP:AddKeybindButtonGroup(MPL_researchPanelKeybindGroup)

    elseif newState == SCENE_HIDDEN then
        EVENT_MANAGER:UnregisterForUpdate("MPL_ResearchUpdate")
        KEYBIND_STRIP:RemoveKeybindButtonGroup(MPL_researchPanelKeybindGroup)
    end
    end)

    smithingScene:RegisterCallback("StateChange", function(oldState, newState)
    if newState == SCENE_SHOWING then
        KEYBIND_STRIP:AddKeybindButtonGroup(MPL_craftingStationKeybindGroup)

    elseif newState == SCENE_HIDDEN then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(MPL_craftingStationKeybindGroup)
        if smithingScene:HasFragment(MPL_CraftingFragment) then
            CloseCraftingStationPanel()
        end
    end
    end)

end

MPL.loadedResearchCharacter = ""
MPL.loadedResearch = {}
MPL.loadedTimeStamp = 0
MPL.loadedHiddenSetting = false
MPL.loadedResearchID = nil

MPL.characterIds = {}
MPL.currentCharacterIndex = 1

function MPL.GetAllHidden()
    return allCharactersHidden
end

function MPL.LoadSavedResearch(index) 
    local charId = MPL.characterIds[index]
    if not charId then return end

    local data = MasterPlanList.researchCharacters[charId]

    if data.hidden and not showHiddenCharacters then
        NextCharacter()
        return
    end

    if not data then return nil end
    MPL.loadedResearch = data.research
    MPL.loadedTimeStamp = data.timestamp
    MPL.loadedResearchCharacter = data.characterName
    MPL.loadedHiddenSetting = data.hidden
    MPL.loadedResearchID = charId

    if SCENE_MANAGER:IsShowing("ResearchScene") then
        MPL.UpdateResearchCategory(currentCategory)
        MPL.UpdateResearchPanel()
    else if not MPL_CraftStationPanel:IsHidden() then
        UpdateCraftingStationMenu(MPL.openStation)
    end
    end
end

function MPL.BuildCharacterIndex()
    MPL.characterIds = {}

    local temp = {}

    for charId, data in pairs(MasterPlanList.researchCharacters) do
        local name = data.characterName
        if name and name ~= "" then
            table.insert(temp, {
                id = charId,
                name = zo_strlower(name),
            })
        end
    end

    table.sort(temp, function(a, b)
        return a.name < b.name
    end)

    for _, entry in ipairs(temp) do
        table.insert(MPL.characterIds, entry.id)
    end

    MPL.currentCharacterIndex = 1
    local currentId = tostring(GetCurrentCharacterId())

    for i, id in ipairs(MPL.characterIds) do
        if tostring(id) == currentId then
            MPL.currentCharacterIndex = i
            break
        end
    end
end

function MPL.SaveResearchForCharacter()
    local charId = GetCurrentCharacterId()
    if not charId then return end

    MasterPlanList.researchCharacters[charId] = {
        characterName = GetUnitName("player"),
        timestamp = GetTimeStamp(),
        research = {},
        hidden = MasterPlanList.researchCharacters[charId]
             and MasterPlanList.researchCharacters[charId].hidden
             or false,
    }

    local entry = MasterPlanList.researchCharacters[charId].research

    for _, craftingSkill in ipairs(CRAFTING_SKILLS) do
        local craftTable = {
            lines = {},
            max = GetMaxSimultaneousSmithingResearch(craftingSkill),
        }
        entry[craftingSkill] = craftTable

        local numLines = GetNumSmithingResearchLines(craftingSkill)

        for lineIndex = 1, numLines do
            local lineName, _, numTraits =
                GetSmithingResearchLineInfo(craftingSkill, lineIndex)

            if craftingSkill == CRAFTING_TYPE_WOODWORKING then
                lineName = lineName:gsub("[Ss]taff", ""):gsub("%s+$", "")
            elseif craftingSkill == CRAFTING_TYPE_CLOTHIER and lineName == "Robe & Jerkin" then
                lineName = "Robe"
            end

            local lineData = { lineName = lineName, traits = {} }
            craftTable.lines[lineIndex] = lineData

            for traitIndex = 1, numTraits do
                local traitType, _, known, apiResearching =
                    GetSmithingResearchLineTraitInfo(craftingSkill, lineIndex, traitIndex)

                local duration, timeRemainingSecs =
                    GetSmithingResearchLineTraitTimes(craftingSkill, lineIndex, traitIndex)

                local researching = (timeRemainingSecs and timeRemainingSecs > 0)

                lineData.traits[traitIndex] = {
                    traitType = traitType,
                    known = known,
                    researching = researching,
                    timeRemainingSecs = timeRemainingSecs,
                }
            end
        end
    end
end

function MPL.CheckOfflineResearch()
    for charId, data in pairs(MasterPlanList.researchCharacters) do
        local savedResearch = data.research
        local savedTimestamp = data.timestamp
        local name = data.characterName

        if savedResearch and savedTimestamp then
            MPL.UpdateExpiredResearch(charId, name, savedResearch, savedTimestamp)
        end
    end
end

MPL.DoResearchNotification = false

MPL.LCKCurrentServer = nil;

function MPL.InitResearch()
    if MasterPlanList.researchNotification == nil then
        MasterPlanList.researchNotification = true
    end

    MPL.DoResearchNotification = MasterPlanList.researchNotification

    MPL.SaveResearchForCharacter()    
    MPL.BuildCharacterIndex()
    MPL.CheckOfflineResearch()

    local serverList = LCK.GetServerList()

    MPL.LCKCurrentServer = serverList[1]

    MPL.NACharacterList = MPL.BuildServerCharacterList("NA")
    MPL.EUCharacterList = MPL.BuildServerCharacterList("EU")

    if MasterPlanList.trackedCharacterID ~= nil then
        if MasterPlanList.mainNACrafterID == nil and MPL.LCKCurrentServer == "NA" and MPL.NACharacterList[MasterPlanList.trackedCharacterID] then
            MasterPlanList.mainNACrafterName = MasterPlanList.trackedCharacter
            MasterPlanList.mainNACrafterID = MasterPlanList.trackedCharacterID
        elseif MasterPlanList.mainEUCrafterID == nil and MPL.LCKCurrentServer == "EU" and MPL.EUCharacterList[MasterPlanList.trackedCharacterID] then
            MasterPlanList.mainEUCrafterName = MasterPlanList.trackedCharacter
            MasterPlanList.mainEUCrafterID = MasterPlanList.trackedCharacterID
        end
    end
end


-- == ADDON LOADING ==

function MPL.OnAddOnLoaded(event, addonName)
  if addonName == MPL.name then
    EVENT_MANAGER:UnregisterForEvent(MPL.name, EVENT_ADD_ON_LOADED) 

    MasterPlanList = ZO_SavedVars:NewAccountWide("MasterPlanList", 1, nil, {
       trackedCharacter = nil,
       trackedCharacterID = nil,
       trackedCharacterPlans = {},
       trackedCharacterRecipes = {},
       researchCharacters = {},
       researchNotification = true,
       mainNACrafterName = nil,
       mainNACrafterID = nil,
       mainEUCrafterName = nil,
       mainEUCrafterID = nil,
    })

    SLASH_COMMANDS["/craftcompletionist"] = MPL.OpenMainMenu
    SLASH_COMMANDS["/showresearch"] = MPL.ShowResearchPanel
    InitGamepadTooltips()
    InitScenes()

    EVENT_MANAGER:RegisterForEvent("MPL_PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(function()
            MPL.InitResearch()
        end, 1000)
    end)

    EVENT_MANAGER:RegisterForUpdate("MPL_OfflineResearchCheck", 60000, MPL.CheckOfflineResearch)


   end
end

EVENT_MANAGER:RegisterForEvent(MPL.name, EVENT_ADD_ON_LOADED, MPL.OnAddOnLoaded)


-- =================================
-- == OLD FUNCTIONS FOR REFERENCE ==
-- =================================


--[[
 -- 17 = Conservatory, 18 = Courtyard, 19 = Dining, 20 = Gallery, 21 = Hearth, 22 = Library, 23 = Parlor
 -- 24 = Lighting, 25 = Structures, 26 = Suite, 27 = Undercroft, 28 = Workshop, 29 = Miscellaneous, 30 = Services
function MPL.TestPlan()

    local recipeInfo = { GetRecipeInfo(12, 1) }
    for i, v in ipairs(recipeInfo) do
        d(string.format("Index %d = %s", i, tostring(v)))
    end
    local recipeInfo = { GetRecipeInfo(13, 2) }
    for i, v in ipairs(recipeInfo) do
        d(string.format("Index %d = %s", i, tostring(v)))
    end
    local recipeInfo = { GetRecipeInfo(14, 3) }
    for i, v in ipairs(recipeInfo) do
        d(string.format("Index %d = %s", i, tostring(v)))
    end
    local recipeInfo = { GetRecipeInfo(15, 4) }
    for i, v in ipairs(recipeInfo) do
        d(string.format("Index %d = %s", i, tostring(v)))
    end
    local recipeInfo = { GetRecipeInfo(16, 5) }
    for i, v in ipairs(recipeInfo) do
        d(string.format("Index %d = %s", i, tostring(v)))
    end
    local recipeInfo = { GetRecipeInfo(11, 6) }
    for i, v in ipairs(recipeInfo) do
        d(string.format("Index %d = %s", i, tostring(v)))
    end
    local recipeInfo = { GetRecipeInfo(17, 7) }
    for i, v in ipairs(recipeInfo) do
        d(string.format("Index %d = %s", i, tostring(v)))
    end
   
end

function InitCharacterList()
    d(string.format("%s", GetWorldName()))

    local server = (GetWorldName() == "NA Megaserver") and "NA" or "EU"

    local characterList = LCK.GetCharacterList(server)

    for _, entry in ipairs(characterList) do
        local id = entry.id
        local name = entry.name
        local account = entry.account

        d(string.format("Character: %s (ID: %s) Account: %s", name, tostring(id), account))
    end
end

local function OnLCKReady()
    d("LCK is ready, initializing character list")
    InitCharacterList()
end

]]--