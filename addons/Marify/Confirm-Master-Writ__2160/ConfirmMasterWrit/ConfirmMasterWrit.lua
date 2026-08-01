ConfirmMasterWrit = {
    displayName = "|c3CB371" .. "Confirm MasterWrit" .. "|r",
    shortName = "CMW",
    name = "ConfirmMasterWrit",
    version = "1.4.0",

    icon             = zo_iconFormat("esoui/art/buttons/accept_up.dds", 18, 18),
    failedIcon       = zo_iconFormat("esoui/art/buttons/decline_up.dds", 20, 20),
    questionIcon     = zo_iconFormat("esoui/art/notifications/notification_help_up.dds", 32, 32),
    researchIcon     = zo_iconFormat("esoui/art/crafting/smithing_tabIcon_research_up.dds", 30, 30),
    txtColor         = "|c"..ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_TOOLTIP, ITEM_TOOLTIP_COLOR_GENERAL)):ToHex(),
    failedColor      = "|c"..ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_FAILED)):ToHex(),
    questionColor    = "|cF39800",

    pinTag = {
        x        = 0,
        y        = 0,
        texture  = "",
        color    = {GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, ITEM_QUALITY_LEGENDARY)},
        isHidden = true,
    },

    compassPinLayout = {
        maxDistance = 0.05,
        texture = "",
        sizeCallback = function(pin, angle, normalizedAngle, normalizedDistance)
                           pin:SetDimensions(64, 64)
                       end,
        additionalLayout = {
            function(pin, angle, normalizedAngle, normalizedDistance)
                local pinTag = pin.pinTag
                pin:SetHidden(pinTag.isHidden)
                if pinTag.isHidden then
                    return
                end

                local color = pinTag.color
                local icon = pin:GetNamedChild("Background")
                icon:SetTexture(pinTag.texture)
                icon:SetColor(color[1], color[2], color[3], color[4])
            end,
            function(pin)
                -- Not Used
            end,
        },
    },

    setNameList = {},
    setIdList = {},
    confirmList = {},
    target = nil,
    lastInteractName = nil,
    masterWritItemList = {},
    provisioningItemList = nil,
    allMarked = false,
    markers = {},
    isBindButtonVisible = nil,
    bindButton = {
        name = function()
            return ConfirmMasterWrit:GetBindButtonName()
        end,
        keybind = "CMW_ALL_MARK",
        visible = function()
            return ConfirmMasterWrit:GetBindButtonVisible()
        end,
        callback = function()
            ConfirmMasterWrit:ShowMarker()
        end,
        enabled = true,
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
    },

    alchemyResultList = {
        ["1:3:15:199"]  = "|H0:item:30141:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:983299|h|h",
        ["1:3:19:199"]  = "|H0:item:27039:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:1245443|h|h",
        ["1:3:19:239"]  = "|H0:item:76844:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:1245443|h|h",
        ["1:3:5:199"]   = "|H0:item:54339:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:66309|h|h",
        ["1:3:7:199"]   = "|H0:item:54339:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:66311|h|h",
        ["1:4:12:199"]  = "|H0:item:44815:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:265217|h|h",
        ["1:4:27:199"]  = "|H0:item:44815:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:262427|h|h",
        ["1:4:27:239"]  = "|H0:item:76829:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:262427|h|h",
        ["1:5:15:199"]  = "|H0:item:30146:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:1114373|h|h",
        ["1:5:19:199"]  = "|H0:item:27039:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:1245445|h|h",
        ["1:5:9:199"]   = "|H0:item:54339:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:66825|h|h",
        ["1:7:12:199"]  = "|H0:item:44813:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:786695|h|h",
        ["1:7:12:239"]  = "|H0:item:76837:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:786695|h|h",
        ["1:7:9:199"]   = "|H0:item:54339:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:67337|h|h",
        ["1:9:29:199"]  = "|H0:item:54339:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:67869|h|h",
        ["2:10:18:199"] = "|H0:item:44812:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:133650|h|h",
        ["2:10:18:239"] = "|H0:item:76827:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:133650|h|h",
        ["2:11:21:199"] = "|H0:item:44812:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:136459|h|h",
        ["2:11:21:239"] = "|H0:item:76827:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:136459|h|h",
        ["2:13:23:199"] = "|H0:item:44812:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:136973|h|h",
        ["2:13:23:239"] = "|H0:item:76827:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:136973|h|h",
        ["2:22:30:239"] = "|H0:item:76827:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:136734|h|h",
        ["2:25:30:199"] = "|H0:item:44812:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:137502|h|h",
        ["2:25:30:239"] = "|H0:item:76827:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:137502|h|h",
        ["2:4:23:199"]  = "|H0:item:44812:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:132119|h|h",
        ["2:4:23:239"]  = "|H0:item:76827:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:132119|h|h",
        ["2:4:6:199"]   = "|H0:item:44812:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:132102|h|h",
        ["2:4:6:239"]   = "|H0:item:76827:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:132102|h|h",
        ["2:6:28:199"]  = "|H0:item:44812:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:132636|h|h",
        ["2:6:28:239"]  = "|H0:item:76827:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:132636|h|h",
        ["2:8:11:199"]  = "|H0:item:44812:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:133896|h|h",
        ["2:8:11:239"]  = "|H0:item:76827:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:133896|h|h",
        ["3:11:21:199"] = "|H0:item:30142:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:1379075|h|h",
        ["3:11:21:239"] = "|H0:item:76846:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:1379075|h|h",
        ["3:15:19:199"] = "|H0:item:27039:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:1249027|h|h",
        ["3:15:19:239"] = "|H0:item:76844:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:1249027|h|h",
        ["4:6:26:199"]  = "|H0:item:44815:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:263706|h|h",
        ["4:6:26:239"]  = "|H0:item:76829:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:263706|h|h",
        ["5:13:23:199"] = "|H0:item:27041:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:1510661|h|h",
        ["5:13:23:239"] = "|H0:item:76848:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:1510661|h|h",
        ["6:9:29:199"]  = "|H0:item:44809:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:395549|h|h",
        ["6:9:29:239"]  = "|H0:item:76831:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:395549|h|h",
        ["7:12:21:199"] = "|H0:item:30142:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:1379335|h|h",
        ["7:12:21:239"] = "|H0:item:76846:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:1379335|h|h",
        ["7:25:30:199"] = "|H0:item:44814:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:465182|h|h",
        ["7:25:30:239"] = "|H0:item:76832:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:465182|h|h",
        ["8:11:15:199"] = "|H0:item:30145:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:724744|h|h",
        ["8:11:15:239"] = "|H0:item:76836:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:724744|h|h",
        ["9:25:30:199"] = "|H0:item:27042:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:596254|h|h",
        ["9:25:30:239"] = "|H0:item:76834:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:596254|h|h",
    },

}




local function ColorTxt(color, ...)
    return color .. zo_strjoin("", ...) .. "|r"
end




local function FailedTxt(...)
    return ConfirmMasterWrit.failedColor .. zo_strjoin("", ...) .. "|r"
end




local function QuestionTxt(...)
    return ConfirmMasterWrit.questionColor .. zo_strjoin("", ...) .. "|r"
end




local function Txt(...)
    return ConfirmMasterWrit.txtColor .. zo_strjoin("", ...) .. "|r"
end




function ConfirmMasterWrit:CheckStyleData()

    if GetDisplayName() ~= "@Marify" then
        return
    end

    local name
    local styleData
    for itemStyleId = ITEMSTYLE_MIN_VALUE, ITEMSTYLE_MAX_VALUE do

        name = GetItemStyleName(itemStyleId)
        if name and name ~= "" then
            if GetCVar("language.2") == "en" then
                if self.savedVariables.styleData == nil then
                    self.savedVariables.styleData = {}
                end
                self.savedVariables.styleData[itemStyleId] = name
            end
        end
    end
end




function ConfirmMasterWrit:Confirm(itemLink, isCheck)


    if itemLink == nil or itemLink == "" then
        return false
    end

    local itemType, specializedItemType = GetItemLinkItemType(itemLink)
    if itemType ~= ITEMTYPE_MASTER_WRIT and self.savedVariables.isBoosterStack then
        self:ConfirmBooster(itemType, itemLink)
        return false
    end


    local result
    if isCheck then
        self:Debug("[Confirm(isCheck)]")
        result = self.confirmList[itemLink]
        if result ~= nil then
            self:Debug("　　>" .. tostring(result) .. "(Cashed)")
            return result
        end
        self:Debug("　　No Cashed".. itemLink)
    else
        self:Debug("[Confirm]")
    end
    result = true


    local craftingType, max = self:GetCraftingTypeByLink(itemLink)
    if (not craftingType) then
        return false
    end
    self:Debug("　　craftingType=<<1>>:<<2>> max=<<3>>", craftingType,
                                                         tostring(GetCraftingSkillName(craftingType)),
                                                         tostring(max))
    local splitItemLinks = {}
    local splitItemLink = string.match(itemLink, "|H%d:item:%d+(.*)")
    for i = 1, 11 do
        splitItemLinks[#splitItemLinks + 1] = string.match(splitItemLink, ":(%d+):")
        --d("　　" .. tostring(i) .. "=" .. tostring(splitItemLinks[#splitItemLinks]))
        splitItemLink = string.match(splitItemLink, ":%d+(.*)")
    end


    ItemTooltip:AddLine(zo_iconFormat("esoui/art/tradinghouse/tradinghouse_divider_short.dds", 300, 2))
    if craftingType == CRAFTING_TYPE_ALCHEMY then
        if (not self:ConfirmAlchemyResult(itemLink,
                                          splitItemLinks[6],
                                          splitItemLinks[7],
                                          splitItemLinks[8],
                                          splitItemLinks[9], max)) then
            -- [SolventAndReagent]
            self:ConfirmSolventAndReagent(itemLink, max)
        end

    elseif craftingType == CRAFTING_TYPE_PROVISIONING then
        local itemId = tonumber(splitItemLinks[6])
        if (not self:ConfirmProvisioningResult(itemId, max)) then

            -- [Recipe]
            local quality, itemType, listIndex, recipeIndex, numIngredients = self:ConfirmRecipe(itemId)

            -- [RecipeQuality]
            self:ConfirmRecipeQuality(quality)

            -- [RecipeIngredient]
            self:ConfirmRecipeIngredient(itemType, listIndex, recipeIndex, numIngredients, max)
        end

    elseif craftingType == CRAFTING_TYPE_ENCHANTING then
        local essence = tonumber(splitItemLinks[6])
        local potency = tonumber(splitItemLinks[7])
        local quality = tonumber(splitItemLinks[8])
        if (not self:ConfirmEnchantResult(essence, potency, quality, max)) then

            -- [AspectQuality]
            self:ConfirmAspectQuality(quality)

            -- [Runestone]
            self:ConfirmRunestone(essence, potency, quality)
        end

    elseif craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
        local key           = tonumber(splitItemLinks[6])
        local quality       = tonumber(splitItemLinks[8])
        local setId         = tonumber(splitItemLinks[9])
        local itemTraitType = tonumber(splitItemLinks[10])
        local itemStyleId   = tonumber(splitItemLinks[11])
        if self:ConfirmSmithingResult(key, quality, setId, itemTraitType, 0, max) then
            result = false
        else
            -- [Trait]
            local _, researchLineIndex, itemAmount, itemMaterialLink = self:GetMasterWritInfo(key)
            result = result and self:ConfirmTrait(craftingType, researchLineIndex, itemTraitType, ItemTooltip)

            -- [Set]
            result = result and self:ConfirmSet(craftingType, researchLineIndex, setId, itemLink, ItemTooltip)

            -- [Stack]
            result = result and self:ConfirmStack(nil, itemTraitType, itemMaterialLink, itemAmount, craftingType, quality, ItemTooltip)
        end
    else
        local key           = tonumber(splitItemLinks[6])
        local quality       = tonumber(splitItemLinks[8])
        local setId         = tonumber(splitItemLinks[9])
        local itemTraitType = tonumber(splitItemLinks[10])
        local itemStyleId   = tonumber(splitItemLinks[11])
        if self:ConfirmSmithingResult(key, quality, setId, itemTraitType, itemStyleId, max) then
            result = false
        else
            -- [Trait]
            local itemStyleChapter, researchLineIndex, itemAmount, itemMaterialLink = self:GetMasterWritInfo(key)
            result = result and self:ConfirmTrait(craftingType, researchLineIndex, itemTraitType, ItemTooltip)

            -- [Set]
            result = result and self:ConfirmSet(craftingType, researchLineIndex, setId, itemLink, ItemTooltip)

            -- [Style]
            result = result and self:ConfirmStyle(itemStyleId, itemStyleChapter, ItemTooltip)

            -- [Stack]
            result = result and self:ConfirmStack(itemStyleId, itemTraitType, itemMaterialLink, itemAmount, craftingType, quality, ItemTooltip)
        end
    end

    self.confirmList[itemLink] = result
    return result
end




function ConfirmMasterWrit:ConfirmAlchemyResult(itemLink, key1, key2, key3, key4, max)

    local item = self:GetAlchemyResult(itemLink, key1, key2, key3, key4)
    if item and item.stack >= max then
        local itemName = GetItemLinkName(item.itemLink)
        local quality = GetItemLinkQuality(item.itemLink)
        local color = "|c" .. ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, quality)):ToHex()
        local icon = zo_iconFormat(GetItemLinkIcon(item.itemLink), 32, 32)

        if self.savedVariables.moreInfo then
            local itemName = GetItemLinkName(item.itemLink)
            local txt = Txt(self.icon, icon, self:Convert(itemName)) .. ColorTxt(color, " ", max, "/", item.stack)
            ItemTooltip:AddLine(txt)
        else
            local txt = Txt(self.icon, icon) .. ColorTxt(color, " ", max, "/", item.stack)
            ItemTooltip:AddLine(txt)
        end
        return true
    end
    return false
end




function ConfirmMasterWrit:ConfirmAspectQuality(quality)

    if quality == nil or quality == 0 then
        return
    end


    self:Debug("　　[AspectQuality]")
    local skillType, skillIndex = GetCraftingSkillLineIndices(CRAFTING_TYPE_ENCHANTING)
    local abilityIndex = 1
    local abilityName, _, _, _, _, _, _, rankIndex = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
    abilityName = self:Convert(abilityName)

    local result
    if (quality - 1) <= rankIndex then
        if self.savedVariables.moreInfo then
            result = Txt(self.icon, GetString(SI_WINDOW_TITLE_SKILLS), ": ", abilityName, (quality - 1))
            ItemTooltip:AddLine(result)
        end
    else
        result = FailedTxt(self.failedIcon, GetString(SI_WINDOW_TITLE_SKILLS), ": ", abilityName, (quality - 1))
        ItemTooltip:AddLine(result)
    end
end




function ConfirmMasterWrit:ConfirmBooster(itemType, itemLink)

    local quality = GetItemLinkQuality(itemLink)
    if quality < ITEM_QUALITY_MAGIC then
        return
    end
    self:Debug("[ConfirmBooster]")


    local craftingType = self:GetCraftingType(itemType, itemLink)
    if (not craftingType) then
        return
    end


    local boosterList = self:GetBoosterList(craftingType, quality)
    for _, booster in ipairs(boosterList) do
        if booster.quality == quality then
            local result = ColorTxt(booster.color, zo_iconFormat(booster.icon), booster.stack)
            ItemTooltip:AddLine(result)
            return
        end
    end
end




function ConfirmMasterWrit:ConfirmEnchantResult(essence, potency, quality, max)

    local item = self:GetEnchantResult(essence, potency, quality)
    if item and item.stack >= 1 then
        local itemName = GetItemLinkName(item.itemLink)
        local quality = GetItemLinkQuality(item.itemLink)
        local color = "|c" .. ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, quality)):ToHex()
        local icon = zo_iconFormat(GetItemLinkIcon(item.itemLink), 32, 32)

        if self.savedVariables.moreInfo then
            local itemName = GetItemLinkName(item.itemLink)
            local txt = Txt(self.icon, icon, self:Convert(itemName)) .. ColorTxt(color, " ", max, "/", item.stack)
            ItemTooltip:AddLine(txt)
        else
            local txt = Txt(self.icon, icon) .. ColorTxt(color, " ", max, "/", item.stack)
            ItemTooltip:AddLine(txt)
        end
        return true
    end
    return false
end




function ConfirmMasterWrit:ConfirmProvisioningResult(itemId, max)

    local item = self:GetProvisioningResult(itemId)
    if item and item.stack >= max then
        local itemName = GetItemLinkName(item.itemLink)
        local quality = GetItemLinkQuality(item.itemLink)
        local color = "|c" .. ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, quality)):ToHex()
        local icon = zo_iconFormat(GetItemLinkIcon(item.itemLink), 32, 32)

        if self.savedVariables.moreInfo then
            local itemName = GetItemLinkName(item.itemLink)
            local txt = Txt(self.icon, icon, self:Convert(itemName)) .. ColorTxt(color, " ", max, "/", item.stack)
            ItemTooltip:AddLine(txt)
        else
            local txt = Txt(self.icon, icon) .. ColorTxt(color, " ", max, "/", item.stack)
            ItemTooltip:AddLine(txt)
        end
        return true
    end
    return false
end




function ConfirmMasterWrit:ConfirmRecipe(itemId)

    self:Debug("　　[Recipe]")
    local qualityMax = 4
    local qualityMin = 1
    local listName, numRecipes
    local isKnown, recipeName, numIngredients, quality, ingredientType, stationType
    local itemLink
    local itemType
    local result
    for listIndex = 1, GetNumRecipeLists() do
        listName, numRecipes = GetRecipeListInfo(listIndex)
        for recipeIndex = 1, numRecipes do
            isKnown, recipeName, numIngredients, _, quality, ingredientType, stationType = GetRecipeInfo(listIndex, recipeIndex)

            if isKnown
                and recipeName
                and recipeName ~= ""
                and stationType == CRAFTING_TYPE_PROVISIONING
                and ingredientType ~= PROVISIONER_SPECIAL_INGREDIENT_TYPE_FURNISHING
                and quality <= qualityMax
                and quality >= qualityMin then

                itemLink = GetRecipeResultItemLink(listIndex, recipeIndex)
                if itemId == GetItemLinkItemId(itemLink) then
                    itemType = GetItemLinkItemType(itemLink) 
                    if self.savedVariables.moreInfo then
                        result = Txt(self.icon, self:Convert(recipeName))
                        ItemTooltip:AddLine(result)
                    end
                    return quality, itemType, listIndex, recipeIndex, numIngredients
                end
            end
        end
    end

    result = FailedTxt(self.failedIcon, GetString(SI_PROVISIONER_NO_RECIPES))
    ItemTooltip:AddLine(result)
    return quality, itemType, listIndex, recipeIndex, numIngredients
end




function ConfirmMasterWrit:ConfirmRecipeIngredient(itemType, listIndex, recipeIndex, numIngredients, max)

    if listIndex == nil or recipeIndex == nil or numIngredients == nil then
        return
    end


    self:Debug("　　[RecipeIngredient]")
    -- [AmountToMake]
    -- Rank0:1
    -- Rank1:2 (+1)
    -- Rank2:3 (+2)
    -- Rank3:4 (+3)
    local skillType, skillIndex = GetCraftingSkillLineIndices(CRAFTING_TYPE_PROVISIONING)
    local abilityIndex = 5
    if itemType == ITEMTYPE_DRINK then
        abilityIndex = 6
    end
    local abilityName, _, _, _, _, purchased, _, rankIndex = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
    if (not purchased) then
        rankIndex = 0
    end
    local amountToMake = 1 + rankIndex


    local itemName, quantity
    local itemLink
    local icon
    local quality
    local color
    local ingredientCount
    local ingredientMax
    local ingredientList = {}
    for ingredientIndex = 1, numIngredients do
        itemName, _, quantity = GetRecipeIngredientItemInfo(listIndex, recipeIndex, ingredientIndex)
        itemLink = GetRecipeIngredientItemLink(listIndex, recipeIndex, ingredientIndex)
        icon = zo_iconFormat(GetItemLinkIcon(itemLink), 25, 25)
        quality = GetItemLinkQuality(itemLink)
        color = "|c" .. ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, quality)):ToHex()
        ingredientCount = GetCurrentRecipeIngredientCount(listIndex, recipeIndex, ingredientIndex)
        quantity = quantity * max
        ingredientMax = math.ceil(quantity / amountToMake)

        local ingredient = {}
        ingredient.quality = quality

        if ingredientCount < ingredientMax then
            ingredient.result = FailedTxt(self.failedIcon, self:Convert(itemName), " ", icon, ingredientCount)
                                .. ColorTxt(color, "/", ingredientMax)
            ItemTooltip:AddLine(ingredient.result)

        elseif self.savedVariables.moreInfo then
            ingredient.result = Txt(self.icon, self:Convert(itemName))
                                .. ColorTxt(color, " ", icon, ingredientCount)
            ingredientList[#ingredientList + 1] = ingredient

        else
            ingredient.result = ColorTxt(color, icon, ingredientCount)
            ingredientList[#ingredientList + 1] = ingredient
        end
    end
    if #ingredientList == 0 then
        return
    end


    table.sort(ingredientList, function(a, b)
        if a.quality < b.quality then
            return true
        end
    end)
    if self.savedVariables.moreInfo then
        for _, ingredient in ipairs(ingredientList) do
            ItemTooltip:AddLine(ingredient.result)
        end
    else
        local result = {}
        for _, ingredient in ipairs(ingredientList) do
            result[#result + 1] = ingredient.result
        end
        ItemTooltip:AddLine(table.concat(result, " "))
    end
end




function ConfirmMasterWrit:ConfirmRecipeQuality(quality)

    if quality == nil or quality == 0 then
        return
    end


    self:Debug("　　[RecipeQuality]")
    local skillType, skillIndex = GetCraftingSkillLineIndices(CRAFTING_TYPE_PROVISIONING)
    local abilityIndex = 1
    local abilityName, _, _, _, _, _, _, rankIndex = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
    abilityName = self:Convert(abilityName)

    local result
    if quality <= rankIndex then
        if self.savedVariables.moreInfo then
            result = Txt(self.icon, GetString(SI_WINDOW_TITLE_SKILLS), ": ", abilityName, quality)
            ItemTooltip:AddLine(result)
        end
    else
        result = FailedTxt(self.failedIcon, GetString(SI_WINDOW_TITLE_SKILLS), ": ", abilityName, quality)
        ItemTooltip:AddLine(result)
    end
end




function ConfirmMasterWrit:ConfirmRunestone(essence, potency, quality)

    if essence == nil or potency == nil or quality == nil then
        return
    end

    self:Debug("　　[Runestone]")
    self:Debug("　　[Potency]" .. tostring(potency))
    self:Debug("　　[Essence]" .. tostring(essence))
    self:Debug("　　[Quality]" .. tostring(quality))
    local potencyRune, essenceRune, qualityRune = self:GetRunestoneData(essence, potency, quality)
    local resultList = {}
    local result
    local errorResult
    local itemLink
    local itemName
    local icon
    local stack


    -- [Potency]
    itemLink = potencyRune
    itemName = self:Convert(GetItemLinkName(itemLink))
    icon     = zo_iconFormat(GetItemLinkInfo(itemLink), 25, 25)
    stack    = self:GetTotalStack(itemLink)
    if stack < 1 then
        errorResult = FailedTxt(zo_strformat("<<1>><<2>> <<3>><<4>>", self.failedIcon, itemName, icon, stack))
        ItemTooltip:AddLine(errorResult)

    elseif self.savedVariables.moreInfo then
        result = Txt(self.icon, itemName, " ", icon, stack)
        ItemTooltip:AddLine(result)

    else
        resultList[#resultList + 1] = Txt(icon, stack)
    end


    -- [Essence]
    itemLink = essenceRune
    itemName = self:Convert(GetItemLinkName(itemLink))
    icon     = zo_iconFormat(GetItemLinkInfo(itemLink), 25, 25)
    stack    = self:GetTotalStack(itemLink)
    if stack < 1 then
        errorResult = FailedTxt(zo_strformat("<<1>><<2>> <<3>><<4>>", self.failedIcon, itemName, icon, stack))
        ItemTooltip:AddLine(errorResult)

    elseif self.savedVariables.moreInfo then
        result = Txt(self.icon, itemName, " ", icon, stack)
        ItemTooltip:AddLine(result)

    else
        resultList[#resultList + 1] = Txt(icon, stack)
    end


    -- [Quality]
    itemLink = qualityRune
    itemName = self:Convert(GetItemLinkName(itemLink))
    icon     = zo_iconFormat(GetItemLinkInfo(itemLink), 25, 25)
    stack    = self:GetTotalStack(itemLink)
    local color = "|c" .. ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, quality)):ToHex()
    if stack < 1 then
        errorResult = FailedTxt(zo_strformat("<<1>><<2>> <<3>><<4>>", self.failedIcon, itemName, icon, stack))
        ItemTooltip:AddLine(errorResult)

    elseif self.savedVariables.moreInfo then
        result = Txt(self.icon, itemName) .. ColorTxt(color, " ", icon, stack)
        ItemTooltip:AddLine(result)

    else
        resultList[#resultList + 1] = ColorTxt(color, " ", icon, stack)
    end


    if #resultList > 0 then
        ItemTooltip:AddLine(table.concat(resultList, " "))
    end
end




function ConfirmMasterWrit:ConfirmSet(craftingType, researchLineIndex, setId, itemLink, tooltip)

    if setId == 0 then
        return true
    end

    self:Debug("　　[Set(<<1>>, <<2>>, <<3>>)]", craftingType, researchLineIndex, setId)
    local researchCount = 0
    local name, _, numTraits = GetSmithingResearchLineInfo(craftingType, researchLineIndex)
    self:Debug("　　　　researchLineIndex=<<1>>:<<2>>", tostring(researchLineIndex), tostring(name))
    local traitType, isKnown
    for traitIndex = 1, numTraits do
        traitType, _, isKnown = GetSmithingResearchLineTraitInfo(craftingType, researchLineIndex, traitIndex)
        if isKnown then
            researchCount = researchCount + 1
            --self:Debug("　　　　　　O:<<1>>", GetString("SI_ITEMTRAITTYPE", traitType))
        --else
            --self:Debug("　　　　　　X:<<1>>", GetString("SI_ITEMTRAITTYPE", traitType), self.disabledColor)
        end
    end

    local txt
    local setName = self:GetItemSetName(itemLink)
    local needResearchCount = LibSets.GetSetInfo(setId).traitsNeeded
    if needResearchCount == nil then
        txt = zo_strformat("Unknown craftSets(itemStyleId:<<1>>:<<2>>", tostring(itemStyleId),
                                                                        self:Convert(GetItemStyleName(itemStyleId)))
        if GetDisplayName() == "@Marify" then
            self:Message(txt, ZO_ERROR_COLOR:ToHex())
        else
            self:Message(txt)
        end
    end
    self:Debug("　　　　needResearch=<<1>>/<<2>>", researchCount, needResearchCount)

    local result = true
    if researchCount < needResearchCount then
        txt = FailedTxt(zo_strformat("<<1>><<2>>: <<3>>  <<4>><<5>>/<<6>>", self.failedIcon,
                                                                            GetString(SI_MASTER_WRIT_DESCRIPTION_SET),
                                                                            setName,
                                                                            self.researchIcon,
                                                                            researchCount,
                                                                            needResearchCount))
        result = false
    elseif self.savedVariables.moreInfo then
        txt = Txt(self.icon, GetString(SI_MASTER_WRIT_DESCRIPTION_SET), ": ", setName)
    else
        return true
    end
    if tooltip then
        tooltip:AddLine(txt)
    end
    return result
end




function ConfirmMasterWrit:ConfirmSmithingResult(key, quality, setId, traitType, styleId, max)

    local item = self:GetSmithingResult(key, quality, setId, traitType, styleId)
    if item and item.stack >= 1 then
        local itemName = GetItemLinkName(item.itemLink)
        local quality = GetItemLinkQuality(item.itemLink)
        local color = "|c" .. ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, quality)):ToHex()
        local icon = zo_iconFormat(GetItemLinkIcon(item.itemLink), 32, 32)

        if self.savedVariables.moreInfo then
            local itemName = GetItemLinkName(item.itemLink)
            local txt = Txt(self.icon, icon, self:Convert(itemName)) .. ColorTxt(color, " ", max, "/", item.stack)
            ItemTooltip:AddLine(txt)
        else
            local txt = Txt(self.icon, icon) .. ColorTxt(color, " ", max, "/", item.stack)
            ItemTooltip:AddLine(txt)
        end
        return true
    end
    return false
end




function ConfirmMasterWrit:ConfirmSolventAndReagent(itemLink, max)

    if (not DailyAlchemy) then
        return
    end
    self:Debug("　　[ConfirmSolventAndReagent]")


    local txt = GenerateMasterWritBaseText(itemLink)
    txt = DailyAlchemy:ConvertedJournalCondition(txt)
    self:Debug("　　　　txt=" .. tostring(txt))
    self:Debug("　　　　max=" .. tostring(max))
    local parameterList = DailyAlchemy:Advice(txt, 0, max, true)


    local solventAndReagentList
    for _, parameter in ipairs(parameterList) do
        if parameter.resultLink then
            solventAndReagentList = {
                parameter.solvent,
                parameter.reagent1,
                parameter.reagent2,
                parameter.reagent3,
            }
            break
        end
    end
    if solventAndReagentList == nil then
        return
    end


    local itemName
    local quality
    local color
    local icon
    local result
    local resultList = {}
    for _, value in ipairs(solventAndReagentList) do
        itemName = value.itemName
        quality = GetItemLinkQuality(value.itemLink)
        color = "|c" .. ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, quality)):ToHex()
        icon = zo_iconFormat(GetItemLinkIcon(value.itemLink), 25, 25)

        if value.stack < value.quantity then
            result = FailedTxt(self.failedIcon, self:Convert(itemName), " ", icon, value.stack)
                                .. ColorTxt(color, "/", value.quantity)
            ItemTooltip:AddLine(result)

        elseif self.savedVariables.moreInfo then
            result = Txt(self.icon, self:Convert(itemName)) .. ColorTxt(color, " ", icon, value.stack)
            resultList[#resultList + 1] = result

        else
            result = ColorTxt(color, icon, value.stack)
            resultList[#resultList + 1] = result
        end
    end
    if #resultList == 0 then
        return
    end


    if self.savedVariables.moreInfo then
        for _, result in ipairs(resultList) do
            ItemTooltip:AddLine(result)
        end
    else
        ItemTooltip:AddLine(table.concat(resultList, " "))
    end
end




function ConfirmMasterWrit:ConfirmStack(itemStyleId, traitType, itemMaterialLink, amount, craftingType, quality, tooltip)

    self:Debug("　　[Stack]")
    local txts = {}
    local errorTxt
    local itemLink
    local itemName
    local icon
    local stack
    local mimicIcon
    local mimicStack = 0
    local result = true


    -- [StyleItem]
    if itemStyleId then
        itemLink = GetItemStyleMaterialLink(itemStyleId)
        itemName = self:Convert(GetItemLinkName(itemLink))
        icon     = zo_iconFormat(GetItemLinkInfo(itemLink), 25, 25)
        stack    = self:GetTotalStack(itemLink)
        if self.savedVariables.useMimicStone then
            local mimicStone = "|H1:item:71668:6:1:0:0:0:0:0:0:0:0:0:0:0:1:36:0:1:0:0:0|h|h"
            mimicIcon  = zo_iconFormat(GetItemLinkIcon(mimicStone), 25, 25)
            mimicStack = self:GetTotalStack(mimicStone)
        end


        if stack > 0 then
            txts[#txts + 1] = Txt(icon, stack)
        elseif tooltip == nil then
            return false

        elseif mimicStack > 0 then
            errorTxt = FailedTxt(zo_strformat("<<1>><<2>>", icon, stack))
            local mimicInfo = Txt("  (", mimicIcon, mimicStack, ")")
            local txt = Txt(zo_strformat("<<1>><<2>>: <<3>>  <<4>><<5>>", self.icon,
                                                                          GetString(SI_SPECIALIZEDITEMTYPE1950),
                                                                          itemName,
                                                                          errorTxt,
                                                                          mimicInfo))
            tooltip:AddLine(txt)
            result = true

        else
            self:Debug("　　　　　　not useMimicStone")
            errorTxt = FailedTxt(zo_strformat("<<1>><<2>>: <<3>>  <<4>><<5>>", self.failedIcon,
                                                                               GetString(SI_SPECIALIZEDITEMTYPE1950),
                                                                               itemName,
                                                                               icon,
                                                                               stack))
            tooltip:AddLine(errorTxt)
            result = false
        end
    end


    -- [TraitItem]
    for traitItemIndex = 1, GetNumSmithingTraitItems() do
        itemTraitType, itemName, icon = GetSmithingTraitItemInfo(traitItemIndex)
        icon = zo_iconFormat(icon, 25, 25)
        itemName = self:Convert(itemName)
        if itemTraitType == traitType then
            local itemLink = GetSmithingTraitItemLink(traitItemIndex)
            stack = self:GetTotalStack(itemLink)
            if stack == 0 then
                errorTxt = FailedTxt(self.failedIcon, itemName, " ", icon, stack)
                if tooltip == nil then
                    return false
                else
                    tooltip:AddLine(errorTxt)
                    result = false
                end
            else
                txts[#txts + 1] = Txt(icon, stack)
            end
            break
        end
    end


    -- [Material]
    stack = self:GetTotalStack(itemMaterialLink)
    icon = zo_iconFormat(GetItemLinkInfo(itemMaterialLink), 25, 25)
    if stack >= amount then
        txts[#txts + 1] = Txt(icon, stack)
    elseif tooltip == nil then
        return false
    else
        itemName = self:Convert(GetItemLinkName(itemMaterialLink))
        errorTxt = FailedTxt(self.failedIcon, itemName, " ", icon, stack, "/", amount)
        tooltip:AddLine(errorTxt)
        result = false
    end


    -- [Booster]
    local boosterList = self:GetBoosterList(craftingType, quality)
    local max = boosterList[#boosterList]
    local amountToMake = self:GetAmountToMake(craftingType)
    local boosterAmount
    for _, booster in ipairs(boosterList) do
        boosterAmount = amountToMake[booster.quality]
        icon = zo_iconFormat(booster.icon, 25, 25)
        if booster.stack >= boosterAmount then
            txts[#txts + 1] = ColorTxt(booster.color, icon, booster.stack)

        elseif tooltip == nil then
            return false
        else
            errorTxt = FailedTxt(self.failedIcon, booster.name, " ", icon, booster.stack)
                       .. ColorTxt(booster.color, "/", boosterAmount)
            tooltip:AddLine(errorTxt)
            result = false
        end
    end


    if tooltip then
        tooltip:AddLine(table.concat(txts, " "))
    end
    return result
end




function ConfirmMasterWrit:ConfirmStyle(itemStyleId, itemStyleChapter, tooltip)

    self:Debug("　　[Style]")
    local known = LibCharacterKnowledge.GetMotifKnowledgeForCharacter(itemStyleId, itemStyleChapter)


    if tooltip then
        local itemStyleName = self:Convert(GetItemStyleName(itemStyleId))

        if known == LibCharacterKnowledge.KNOWLEDGE_KNOWN then
            if self.savedVariables.moreInfo then
                txt = Txt(self.icon, GetString(SI_MASTER_WRIT_DESCRIPTION_STYLE), ": ", itemStyleName)
                tooltip:AddLine(txt)
            end


        elseif self:ContainsNumber(known, LibCharacterKnowledge.KNOWLEDGE_INVALID,
                                          LibCharacterKnowledge.KNOWLEDGE_NODATA) then

            local txt = zo_strformat("<<1>>(<<2>>): <<3>>", GetString(SI_MASTER_WRIT_DESCRIPTION_STYLE),
                                                            GetString(SI_CRAFTING_UNKNOWN_NAME),
                                                            tostring(itemStyleName))
            if GetDisplayName() == "@Marify" then
                self:Message(txt, ZO_ERROR_COLOR:ToHex())
            end
            txt = QuestionTxt(self.questionIcon, txt)
            tooltip:AddLine(txt)

        else
            local txt = FailedTxt(self.failedIcon, GetString(SI_MASTER_WRIT_DESCRIPTION_STYLE), ": ", itemStyleName)
            tooltip:AddLine(txt)

            local motifName = self:GetMotifName(itemStyleId, itemStyleChapter)
            local txt2 = FailedTxt(motifName)
            tooltip:AddLine(txt2)
        end
    end
    return (known == LibCharacterKnowledge.KNOWLEDGE_KNOWN)
end




function ConfirmMasterWrit:ConfirmTrait(craftingType, researchLineIndex, traitType, tooltip)

    self:Debug("　　[Trait]")
    local itemTraitType, isKnown
    local name, _, numTraits = GetSmithingResearchLineInfo(craftingType, researchLineIndex)
    for traitIndex = 1, numTraits do
        itemTraitType, _, isKnown = GetSmithingResearchLineTraitInfo(craftingType, researchLineIndex, traitIndex)
        if itemTraitType == traitType then
            local traitTypeName = zo_strjoin("", GetString("SI_ITEMTRAITTYPE", traitType), "(", tostring(name), ")")
            self:Debug("　　　　traitType=" .. traitType .. ":" .. GetString("SI_ITEMTRAITTYPE", traitType))
            if (not isKnown) then
                if tooltip == nil then
                    return false
                end
                local txt = FailedTxt(self.failedIcon, GetString(SI_MASTER_WRIT_DESCRIPTION_TRAIT), ": ", traitTypeName)
                tooltip:AddLine(txt)

            elseif self.savedVariables.moreInfo and tooltip then
                local txt = Txt(self.icon, GetString(SI_MASTER_WRIT_DESCRIPTION_TRAIT), ": ", traitTypeName)
                tooltip:AddLine(txt)
            end
            return true
        end
    end
    return false
end




function ConfirmMasterWrit:Convert(text)

    local list = {
        {"(\^)%a*", ""},
        {"(\-)",    " "},
    }

    local convertedText = text
    for _, value in ipairs(list) do
        convertedText = string.gsub(convertedText, value[1], value[2])
    end
    return convertedText
end




function ConfirmMasterWrit:CreateMenu()

    self.savedVariables.debugLog = {}
    if self.savedVariables.moreInfo == nil then
        self.savedVariables.moreInfo = false
    end
    if self.savedVariables.useMimicStone == nil then
        self.savedVariables.useMimicStone = true
    end
    if self.savedVariables.floorMark == nil then
        self.savedVariables.floorMark = false
    end
    if self.savedVariables.locationList == nil then
        self.savedVariables.locationList = {}
    end
    if self.savedVariables.isBoosterStack == nil then
        self.savedVariables.isBoosterStack = false
    end
    if self.savedVariables.alchemyResultList == nil then
        self.savedVariables.alchemyResultList = {}
    end
    for key, value in pairs(self.alchemyResultList) do
        self.savedVariables.alchemyResultList[key] = nil
    end
    for key, value in pairs(self.savedVariables.alchemyResultList) do
        self.alchemyResultList[key] = value
    end
    if self.savedVariables.stationMarkList == nil then
        self.savedVariables.stationMarkList = {}
    end
    if self.savedVariables.stationMarkList[CRAFTING_TYPE_BLACKSMITHING] == nil then
        self.savedVariables.stationMarkList[CRAFTING_TYPE_BLACKSMITHING] = true
    end
    if self.savedVariables.stationMarkList[CRAFTING_TYPE_CLOTHIER] == nil then
        self.savedVariables.stationMarkList[CRAFTING_TYPE_CLOTHIER] = true
    end
    if self.savedVariables.stationMarkList[CRAFTING_TYPE_WOODWORKING] == nil then
        self.savedVariables.stationMarkList[CRAFTING_TYPE_WOODWORKING] = true
    end
    if self.savedVariables.stationMarkList[CRAFTING_TYPE_JEWELRYCRAFTING] == nil then
        self.savedVariables.stationMarkList[CRAFTING_TYPE_JEWELRYCRAFTING] = true
    end
    self.savedVariables.styleToAchievement = nil -- abolition


    local panelData = {
        type = "panel",
        name = self.displayName,
        displayName = self.displayName,
        author = "Marify",
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LibAddonMenu2:RegisterAddonPanel(self.displayName, panelData)


    local optionsTable = {
        {
            type = "checkbox",
            name = GetString(SI_NOTIFICATIONS_MORE_INFO),
            getFunc = function()
                return self.savedVariables.moreInfo
            end,
            setFunc = function(value)
                self.savedVariables.moreInfo = value
            end,
            width = "full",
            default = false,
        },
        {
            type = "checkbox",
            name = GetString(SI_CRAFTING_CONFIRM_USE_UNIVERSAL_STYLE_ITEM_TITLE),
            getFunc = function()
                return self.savedVariables.useMimicStone
            end,
            setFunc = function(value)
                self.savedVariables.useMimicStone = value
            end,
            width = "full",
            default = useMimicStone,
        },
        {
            type = "header",
            name = GetString(CMW_MARK_HEADER),
            width = "full",
        },
        {
            type = "checkbox",
            name = zo_iconFormat("esoui/art/buttons/gamepad/gp_downarrow.dds", 18, 18)
                    .. zo_iconFormat("esoui/art/buttons/gamepad/gp_uparrow.dds", 18, 18)
                    .. "     " .. GetString(CMW_FLOOR_MARK),
            tooltip = GetString(CMW_FLOOR_MARK_TOOLTIP),
            getFunc = function()
                return self.savedVariables.floorMark
            end,
            setFunc = function(value)
                self.savedVariables.floorMark = value
            end,
            width = "full",
            default = true,
        },
        {
            type = "checkbox",
            name = zo_iconFormat("esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_down.dds", 42, 42)
                    .. "     " .. GetString(CMW_ST_BLACKSMITHING),
            getFunc = function()
                return self.savedVariables.stationMarkList[CRAFTING_TYPE_BLACKSMITHING]
            end,
            setFunc = function(value)
                self.savedVariables.stationMarkList[CRAFTING_TYPE_BLACKSMITHING] = value
            end,
            width = "full",
            default = true,
        },
        {
            type = "checkbox",
            name = zo_iconFormat("esoui/art/inventory/inventory_tabicon_craftbag_clothing_down.dds", 42, 42)
                    .. "     " .. GetString(CMW_ST_CLOTHIER),
            getFunc = function()
                return self.savedVariables.stationMarkList[CRAFTING_TYPE_CLOTHIER]
            end,
            setFunc = function(value)
                self.savedVariables.stationMarkList[CRAFTING_TYPE_CLOTHIER] = value
            end,
            width = "full",
            default = true,
        },
        {
            type = "checkbox",
            name = zo_iconFormat("esoui/art/inventory/inventory_tabicon_craftbag_woodworking_down.dds", 42, 42)
                    .. "     " .. GetString(CMW_ST_WOODWORKING),
            getFunc = function()
                return self.savedVariables.stationMarkList[CRAFTING_TYPE_WOODWORKING]
            end,
            setFunc = function(value)
                self.savedVariables.stationMarkList[CRAFTING_TYPE_WOODWORKING] = value
            end,
            width = "full",
            default = true,
        },
        {
            type = "checkbox",
            name = zo_iconFormat("esoui/art/inventory/inventory_tabIcon_craftbag_jewelrycrafting_down.dds", 42, 42)
                    .. "     " .. GetString(CMW_ST_JEWELRY),
            getFunc = function()
                return self.savedVariables.stationMarkList[CRAFTING_TYPE_JEWELRYCRAFTING]
            end,
            setFunc = function(value)
                self.savedVariables.stationMarkList[CRAFTING_TYPE_JEWELRYCRAFTING] = value
            end,
            width = "full",
            default = true,
        },
        {
            type = "header",
            name = GetString(CMW_OTHER_HEADER),
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(CMW_BOOSTER),
            tooltip = GetString(CMW_BOOSTER_TOOLTIP),
            getFunc = function()
                return self.savedVariables.isBoosterStack
            end,
            setFunc = function(value)
                self.savedVariables.isBoosterStack = value
            end,
            width = "full",
            default = false,
        },
        {
            type = "checkbox",
            name = GetString(CMW_DEBUG_LOG),
            getFunc = function()
                return self.savedVariables.isDebug
            end,
            setFunc = function(value)
                self.savedVariables.isDebug = value
            end,
            width = "full",
            default = false,
        },
        {
            type = "button",
            name = GetString(SI_OPTIONS_RESET),
            tooltip =GetString(SI_OPTIONS_RESET_TITLE),
            func = function()
                self.savedVariables.debugLog = {}
                self.savedVariables.locationList = {}
                self.savedVariables.moreInfo = false
                self.savedVariables.isDebug = false
                self.savedVariables.locationList = {}
            end,
            width = "full",
        },
    }
    LibAddonMenu2:RegisterOptionControls(self.displayName, optionsTable)
end




function ConfirmMasterWrit:GetAmountToMake(craftingType)

    local skillType, skillIndex = GetCraftingSkillLineIndices(craftingType)
    local abilityIndex = 6 -- (TemperExpertise/Tannin Expertise/Resin Expertise)
    if craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
        abilityIndex = 5 -- ()
    end

    local abilityName, _, _, _, _, purchased, _, rankIndex = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
    if (not purchased) then
        rankIndex = 0
    end

    if craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
        if rankIndex == 3 then
            return {0,1,2,3,4}

        elseif rankIndex == 2 then
            return {0,2,3,4,5}

        elseif rankIndex == 1 then
            return {0,2,4,5,7}

        else
            return {0,3,5,7,10}
        end

    else
        if rankIndex == 3 then
            return {0,2,3,4,8}

        elseif rankIndex == 2 then
            return {0,3,4,5,10}

        elseif rankIndex == 1 then
            return {0,4,5,7,14}

        else
            return {0,5,7,10,20}
        end
    end

end




function ConfirmMasterWrit:GetBoosterList(craftingType, craftingQuality, isOneKind)

    if craftingQuality < ITEM_QUALITY_MAGIC then
        return nil
    end


    local boosterTypes = {
        [CRAFTING_TYPE_BLACKSMITHING] = {
            ITEMTYPE_BLACKSMITHING_BOOSTER,
            "|H1:item:54170:31:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
            "|H1:item:54171:32:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
            "|H1:item:54172:33:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
            "|H1:item:54173:34:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
            },
        [CRAFTING_TYPE_CLOTHIER] = {
            ITEMTYPE_CLOTHIER_BOOSTER,
            "|H1:item:54174:31:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
            "|H1:item:54175:32:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
            "|H1:item:54176:33:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
            "|H1:item:54177:34:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
            },
        [CRAFTING_TYPE_WOODWORKING] = {
            ITEMTYPE_WOODWORKING_BOOSTER,
            "|H1:item:54178:31:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
            "|H1:item:54179:32:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
            "|H1:item:54180:33:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
            "|H1:item:54181:34:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
            },
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {
            ITEMTYPE_JEWELRYCRAFTING_BOOSTER,
            "|H1:item:135147:31:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
            "|H1:item:135148:32:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
            "|H1:item:135149:33:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
            "|H1:item:135150:34:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
            },
    }
    local boosterItemType = boosterTypes[craftingType][1]


    local list = {}
    local itemLink
    for i = 2, craftingQuality do
        itemLink = boosterTypes[craftingType][i]
        
        booster = {}
        booster.quality = i
        booster.stack = 0
        booster.color = "|c" .. ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, i)):ToHex()
        booster.name = self:Convert(GetItemLinkName(itemLink))
        booster.icon  = GetItemLinkIcon(itemLink)
        list[i] = booster
    end

    for _, bagId in ipairs({BAG_SUBSCRIBER_BANK, BAG_VIRTUAL, BAG_BANK, BAG_BACKPACK}) do
        local slotIndex = ZO_GetNextBagSlotIndex(bagId, nil)
        while slotIndex do
            if GetItemType(bagId, slotIndex) == boosterItemType then
                local icon, stack, _, meetsUsageRequirement, _, _, _, quality = GetItemInfo(bagId, slotIndex)
                if craftingQuality >= quality then
                    local booster = list[quality]
                    booster.stack = booster.stack + stack
                end
            end
            slotIndex = ZO_GetNextBagSlotIndex(bagId, slotIndex)
        end
    end


    local boosterList = {}
    for _, booster in pairs(list) do
        boosterList[#boosterList + 1] = booster
    end
    table.sort(boosterList, function(a, b)
        if isOneKind then
            return a.quality > b.quality
        else
            return a.quality < b.quality
        end
    end)
    return boosterList
end




function ConfirmMasterWrit:GetItemSetName(itemLink)

    local description = GenerateMasterWritBaseText(itemLink):gsub("[)]", " ")
    description = description:gsub("[(]", " ")
    description = description:gsub("[)]", " ")

    local format = GetString(SI_MASTER_WRIT_ITEM_DURABLE_FORMAT_STRING)
    format = format:gsub("[(]", " ")
    format = format:gsub("[)]", " ")
    format = format:gsub(".+(<<.*>>.*<<.*>>.*<<.*>>.*<<.*>>.*<<.*>>.*)", "%1")

    local attribute = GetString(SI_MASTER_WRIT_ITEM_ATTRIBUTE_WITH_DESCRIPTION)
    local keyword1 = ".*"
    local keyword2 = zo_strformat(attribute, GetString(SI_MASTER_WRIT_DESCRIPTION_QUALITY), ".*")
    local keyword3 = zo_strformat(attribute, GetString(SI_MASTER_WRIT_DESCRIPTION_TRAIT), ".*")
    local keyword4 = zo_strformat(attribute, GetString(SI_MASTER_WRIT_DESCRIPTION_SET), "(.*)")
    local keyword5 = zo_strformat(attribute, GetString(SI_MASTER_WRIT_DESCRIPTION_STYLE), ".*")
    local keyword  = zo_strformat(format, keyword1, keyword2, keyword3, keyword4, keyword5)

    local setName = string.match(description, keyword)
    if (not setName) then
        keyword5 = ""
        keyword  = zo_strformat(GetString(SI_MASTER_WRIT_ITEM_DURABLE_FORMAT_STRING), keyword1,
                                                                                      keyword2,
                                                                                      keyword3,
                                                                                      keyword4,
                                                                                      keyword5)
        setName = string.match(description, keyword)
    end
    return setName
end




function ConfirmMasterWrit:GetMasterWritInfo(key)

    --self:Debug("　　[GetMasterWritInfo(<<1>>)]", tostring(key))
    local infoList = {
        -- BLACKSMITHING(Rubedite)
        [53] = {ITEM_STYLE_CHAPTER_AXES,        1,  11, "|H0:item:64489:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Axe
        [56] = {ITEM_STYLE_CHAPTER_MACES,       2,  11, "|H0:item:64489:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Mace
        [59] = {ITEM_STYLE_CHAPTER_SWORDS,      3,  11, "|H0:item:64489:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Sword
        [68] = {ITEM_STYLE_CHAPTER_AXES,        4,  14, "|H0:item:64489:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Battle Axe
        [69] = {ITEM_STYLE_CHAPTER_MACES,       5,  14, "|H0:item:64489:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Maul
        [67] = {ITEM_STYLE_CHAPTER_SWORDS,      6,  16, "|H0:item:64489:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Greatsword
        [62] = {ITEM_STYLE_CHAPTER_DAGGERS,     7,  10, "|H0:item:64489:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Dagger

        -- BLACKSMITHING(Rubedite)
        [46] = {ITEM_STYLE_CHAPTER_CHESTS,      8,  15, "|H0:item:64489:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Cuirass
        [50] = {ITEM_STYLE_CHAPTER_BOOTS,       9,  13, "|H0:item:64489:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Sabatons
        [52] = {ITEM_STYLE_CHAPTER_GLOVES,      10, 13, "|H0:item:64489:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Gauntlets
        [44] = {ITEM_STYLE_CHAPTER_HELMETS,     11, 13, "|H0:item:64489:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Helm
        [49] = {ITEM_STYLE_CHAPTER_LEGS,        12, 14, "|H0:item:64489:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Greaves
        [47] = {ITEM_STYLE_CHAPTER_SHOULDERS,   13, 13, "|H0:item:64489:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Pauldron
        [48] = {ITEM_STYLE_CHAPTER_BELTS,       14, 13, "|H0:item:64489:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Girdle

        -- CLOTHIER(Ancestor Silk)
        [28] = {ITEM_STYLE_CHAPTER_CHESTS,      1,  15, "|H0:item:64504:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Robe
--      [  ] = {ITEM_STYLE_CHAPTER_CHESTS,      1,  15, "|H0:item:64504:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Shirt
        [32] = {ITEM_STYLE_CHAPTER_BOOTS,       2,  13, "|H0:item:64504:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Shoes
        [34] = {ITEM_STYLE_CHAPTER_GLOVES,      3,  13, "|H0:item:64504:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Gloves
        [26] = {ITEM_STYLE_CHAPTER_HELMETS,     4,  13, "|H0:item:64504:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Hat
        [31] = {ITEM_STYLE_CHAPTER_LEGS,        5,  14, "|H0:item:64504:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Breeches
        [29] = {ITEM_STYLE_CHAPTER_SHOULDERS,   6,  13, "|H0:item:64504:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Epaulets
        [30] = {ITEM_STYLE_CHAPTER_BELTS,       7,  13, "|H0:item:64504:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Sash

        -- CLOTHIER(Rubedo Leather)
        [37] = {ITEM_STYLE_CHAPTER_CHESTS,      8,  15, "|H0:item:64506:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Jack
        [41] = {ITEM_STYLE_CHAPTER_BOOTS,       9,  13, "|H0:item:64506:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Boots
        [43] = {ITEM_STYLE_CHAPTER_GLOVES,      10, 13, "|H0:item:64506:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Bracers
        [35] = {ITEM_STYLE_CHAPTER_HELMETS,     11, 13, "|H0:item:64506:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Helmet
        [40] = {ITEM_STYLE_CHAPTER_LEGS,        12, 14, "|H0:item:64506:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Guards
        [38] = {ITEM_STYLE_CHAPTER_SHOULDERS,   13, 13, "|H0:item:64506:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Arm Cap
        [39] = {ITEM_STYLE_CHAPTER_BELTS,       14, 13, "|H0:item:64506:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Belt

        -- WOODWORKING(Sanded Ruby Ash)
        [70] = {ITEM_STYLE_CHAPTER_BOWS,        1,  12, "|H0:item:64502:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Bow
        [72] = {ITEM_STYLE_CHAPTER_STAVES,      2,  12, "|H0:item:64502:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Inferno Staff
        [73] = {ITEM_STYLE_CHAPTER_STAVES,      3,  12, "|H0:item:64502:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Ice Staff
        [74] = {ITEM_STYLE_CHAPTER_STAVES,      4,  12, "|H0:item:64502:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Lightning Staff
        [71] = {ITEM_STYLE_CHAPTER_STAVES,      5,  12, "|H0:item:64502:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Restoration Staff
        [65] = {ITEM_STYLE_CHAPTER_SHIELDS,     6,  12, "|H0:item:64502:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Shield

        -- JEWELRY(Platinum)
        [18] = {nil,                            1,  15, "|H0:item:135146:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Necklace
        [24] = {nil,                            2,  10, "|H0:item:135146:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},   -- Ring
    }

    local info = infoList[tonumber(key)]
    if info then
        return unpack(info)
    end
end




function ConfirmMasterWrit:GetMotifName(itemStyleId, itemStyleChapter)

    self:Debug("　　　　　　[GetMotifName] <<1>>, <<2>>", tostring(itemStyleId), tostring(itemStyleChapter))
    itemStyleId = tonumber(itemStyleId)
    if itemStyleId == 0 then
        return nil
    end


    local itemLink
    local items = LibCharacterKnowledge.GetMotifItemsFromStyle(itemStyleId)
    if (not items.chapters[itemStyleChapter]) then
        itemLink = zo_strformat("|H0:item:<<1>>:5:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", items.books[1])
    else
        itemLink = zo_strformat("|H0:item:<<1>>:5:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", items.chapters[itemStyleChapter])
    end
    return GetItemLinkName(itemLink), itemLink
end




function ConfirmMasterWrit:GetRunestoneData(essence, potency, quality)

    -- [Potency]
    local positivePotency = {
        [207] = "|H0:item:64509:308:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",    -- Rejera
        [225] = "|H0:item:68341:366:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",    -- Repora
    }
    local negativePotency = {
        [207] = "|H0:item:64508:308:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",    -- Jehade
        [225] = "|H0:item:68340:366:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",    -- Itade
    }

    -- [Essence]
    -- @see http://esoitem.uesp.net/viewlog.php?search=Sealed+Enchanting+Writ
    local list = {
        [26580] = {positivePotency, "|H0:item:45831:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Oko(HEALTH)
        [43573] = {negativePotency, "|H0:item:45831:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Oko(ABSORB HEALTH)

        [26581] = {positivePotency, "|H0:item:45834:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Okoma(HEALTH  RECOVERY)
        [45869] = {negativePotency, "|H0:item:45834:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Okoma(DECREASE HEALTH)

        [54484] = {positivePotency, "|H0:item:45843:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Okori(WEAPON DAMAGE)
        [26591] = {negativePotency, "|H0:item:45843:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Okori(WEAKENING)

        [45874] = {positivePotency, "|H0:item:45846:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Oru(POTION BOOST)
        [45875] = {negativePotency, "|H0:item:45846:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Oru(POTION SPEED)
        
        [45872] = {positivePotency, "|H0:item:45849:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Kaderi(BASHING)
        [45873] = {negativePotency, "|H0:item:45849:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Kaderi(SHIELDING)

        [26587] = {positivePotency, "|H0:item:45837:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Kuoko(POISON)
        [26586] = {negativePotency, "|H0:item:45837:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Kuoko(POISON RESIST)

        [45883] = {positivePotency, "|H0:item:45847:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Taderi(INCREASE PHYSICAL HARM)
        [45885] = {negativePotency, "|H0:item:45847:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Taderi(DECREASE PHYSICAL HARM)

        [5365]  = {positivePotency, "|H0:item:45839:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Dekeipa(FROST)
        [5364]  = {negativePotency, "|H0:item:45839:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Dekeipa(FROST RESIST)

        [5366]  = {positivePotency, "|H0:item:45842:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Deteri(HARDENING)
        [26845] = {negativePotency, "|H0:item:45842:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Deteri(CRUSHING)

        [26588] = {positivePotency, "|H0:item:45833:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Deni(STAMINA)
        [45867] = {negativePotency, "|H0:item:45833:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Deni(ABSORB STAMINA)

        [26589] = {positivePotency, "|H0:item:45836:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Denima(STAMINA RECOVERY)
        [45871] = {negativePotency, "|H0:item:45836:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Denima(REDUCE FEAT COST)

        [26841] = {positivePotency, "|H0:item:45841:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Haoko(FOULNESS)
        [26847] = {negativePotency, "|H0:item:45841:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Haoko(DISEASE RESIST)

        [68343] = {positivePotency, "|H0:item:68342:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Hakeijo(PRISMATIC DEFENSE)
        [68344] = {negativePotency, "|H0:item:68342:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Hakeijo(PRISMATIC ONSLAUGHT)

        [45884] = {positivePotency, "|H0:item:45848:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Makderi(INCREASE MAGICAL HARM)
        [45886] = {negativePotency, "|H0:item:45848:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Makderi(DECREASE SPELL HARM)

        [26582] = {positivePotency, "|H0:item:45832:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Makko(MAGICKA)
        [45868] = {negativePotency, "|H0:item:45832:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Makko(ABSORB MAGICKA)

        [26583] = {positivePotency, "|H0:item:45835:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Makkoma(MAGICKA RECOVERY)
        [45870] = {negativePotency, "|H0:item:45835:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Makkoma(REDUCE SPELL COST)

        [26844] = {positivePotency, "|H0:item:45840:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Meip(SHOCK)
        [43570] = {negativePotency, "|H0:item:45840:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Meip(SHOCK RESIST)

        [26848] = {positivePotency, "|H0:item:45838:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Rakeipa(FLAME)
        [26849] = {negativePotency, "|H0:item:45838:20:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"}, -- Rakeipa(FLAME RESIST)
    }

    -- [Quality]
    local qualityList = {
        [4] = "|H0:item:45853:23:16:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",    -- Rekuta(Artifact)
        [5] = "|H0:item:45854:24:21:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",    -- Kuta(Legendary)
    }

    local result = list[essence]
    return result[1][potency], result[2], qualityList[quality]
end




function ConfirmMasterWrit:GetTotalStack(itemLink)

    local itemId = GetItemLinkItemId(itemLink)
    local total = 0
    for _, bagId in ipairs({BAG_SUBSCRIBER_BANK, BAG_VIRTUAL, BAG_BANK, BAG_BACKPACK}) do
        local slotIndex = ZO_GetNextBagSlotIndex(bagId, nil)
        while slotIndex do
            if GetItemId(bagId, slotIndex) == itemId then
                local _, stack = GetItemInfo(bagId, slotIndex)
                total = total + stack
            end
            slotIndex = ZO_GetNextBagSlotIndex(bagId, slotIndex)
        end
    end
    return total
end




function ConfirmMasterWrit:LowerMatch(text, pattern)

    if (not text) or text == "" then
        return false
    end
    if (not pattern) or pattern == "" then
        return false
    end
    if string.match(text, pattern) then
        return true
    end


    local lowerText = string.lower(text)
    if (not lowerText) or lowerText == "" then
        return false
    end

    local lowerPattern = string.lower(pattern)
    if (not lowerPattern) or lowerPattern == "" then
        return false
    end
    if string.match(lowerText, lowerPattern) then
        return true
    end
    return false
end




function ConfirmMasterWrit:OnAddOnLoaded(event, addonName)

    if addonName ~= self.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
    setmetatable(ConfirmMasterWrit, {__index = LibMarify})


    self.savedVariables = ZO_SavedVars:NewAccountWide("ConfirmMasterWritVariables", 2, nil, {})
    self:CreateMenu()
    SLASH_COMMANDS["/cmw_clear"] = function()
        self.savedVariables.debugLog = {}
        self.savedVariables.locationList = {}
        self:Message("Cache cleared.")
    end

    --EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CRAFT_COMPLETED,                function(...) self:CraftingCompleted(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CRAFTING_STATION_INTERACT,      function(...) self:StationInteract(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_END_CRAFTING_STATION_INTERACT,  function(...) self:UpdateMarker() end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ABILITY_LIST_CHANGED,           function(...) self:ClearItemList() end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_INVENTORY_FULL_UPDATE,          function(...) self:ClearItemList() end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,   function(...) self:ClearItemList() end)
    EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,  REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

    FOCUSED_QUEST_TRACKER:RegisterCallback("QuestTrackerAssistStateChanged",        function(...) self:QuestTrackerChanged(...) end)

    self:PostHook(ZO_PlayerInventoryBackpack.dataTypes[1], "setupCallback",         function(...) self:UpdateInventory(...) end)
    self:PostHook(ItemTooltip,        "SetBagItem",                                 function(tooltip, ...) self:Confirm(GetItemLink(...)) end)
    self:PostHook(ItemTooltip,        "SetWornItem",                                function(tooltip, ...) self:Confirm(GetItemLink(BAG_WORN, ...)) end)
    self:PostHook(ItemTooltip,        "SetTradingHouseListing",                     function(tooltip, ...) self:Confirm(GetTradingHouseListingItemLink(...)) end)
    self:PostHookForAGS(ItemTooltip,  "SetTradingHouseItem",                        function(tooltip, ...) self:Confirm(GetTradingHouseSearchResultItemLink(...)) end)
    self:PostHook(INVENTORY_MENU_BAR, "OnFragmentShown",                            function(...)
        self:Debug("[OnFragmentShown]", self.checkColor)
        KEYBIND_STRIP:AddKeybindButton(self.bindButton)
        end)
    self:PostHook(INVENTORY_MENU_BAR, "OnFragmentHidden",                           function(...)
        self:Debug("[OnFragmentHidden]", self.checkColor)
        KEYBIND_STRIP:RemoveKeybindButton(self.bindButton)
        end)
    LibCustomMenu:RegisterContextMenu(function(...) self:ShowContextMenu(...) end, LibCustomMenu.CATEGORY_LATE)

    zo_callLater(function()
        ZO_PreHook(RETICLE, "OnUpdate",                                             function(...) self:ReticleUpdate(...) end)
        self:CheckStyleData()
    end, 5000)

end




EVENT_MANAGER:RegisterForEvent(ConfirmMasterWrit.name, EVENT_ADD_ON_LOADED, function(...) ConfirmMasterWrit:OnAddOnLoaded(...) end)

