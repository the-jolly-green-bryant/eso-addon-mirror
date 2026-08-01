DailyProvisioning = {
    displayName = "|c3CB371" .. "Daily Provisioning" .. "|r",
    shortName = "DP",
    name = "DailyProvisioning",
    version = "1.5.3",

    emptySlot = nil,        -- ※Don't Finalize

    bulkConditionText = nil,
    executeCurrent = nil,
    executeToEnd = nil,
    checkedJournal = {},
    stackList = {},
    houseStackList =  {},

    recipeList = nil,
    itemTypeFilter = {},
    isDontKnow = nil,
    isStationInteract = false,  -- need Debug!
    isAcquire = false,
    existUnknownRecipe = nil,

    QUEST_DAILY  = "1:DAILY",
    QUEST_MASTER = "2:MASTER",
}




function DailyProvisioning:CraftCompleted(eventCode, craftSkill)

    if craftSkill ~= CRAFTING_TYPE_PROVISIONING then
        return
    end
    self:Debug("[CraftCompleted]")


    local result = self:Crafting(eventCode, craftSkill)
    if (not result) then
        self:Debug("　　> return(not result)")
        return
    end


    local isEmpty = true
    for key, value in pairs(self.checkedJournal) do
        self:Debug("　　<<1>>=<<2>>", key, tostring(value))
        if (not value) then
           self:Debug("　　> return(not value)")
           return
        end
        isEmpty = false
    end
    if isEmpty then
        self:Debug("　　> return(isEmpty)")
        return
    end


    if self.savedVariables.isAutoExit then
        self:Debug("　　> EndInteraction")
        EndInteraction(INTERACTION_CRAFT)
    else
        self:Debug("　　> not AutoExit")
    end
end




function DailyProvisioning:Crafting(craftSkill)

    self:Debug("[Crafting]", self.checkColor)

    if self.isAcquire then
        zo_callLater(function()
            self:Crafting(craftSkill)
        end, 1000)
    end


    local infos, hasMaster, hasDaily, hasEvent = self:GetQuestInfos()
    if (not infos) or #infos == 0 then
        self:Debug("　　>No Quest")
        return
    end


    self.recipeList = self.recipeList or self:GetRecipeList(hasMaster, hasDaily, hasEvent)
    if self.savedVariables.isDontKnow then
        if self:ExistUnknownRecipe(infos) then
            return false
        end
    end


    local toHide = self:IsDebug() and (not self.savedVariables.isDebugRecipe)
    local parameter
    for _, info in pairs(infos) do
        self:Debug("　　--------")
        info.convertedTxt = self:IsValidConditions(info.convertedTxt, info.current, info.max, info.isVisible)
        if info.convertedTxt then

            if toHide then
                self.savedVariables.isDebug = false
            end
            parameter = self:CreateParameter(info)[1]
            if toHide then
                self.savedVariables.isDebug = true
            end

            if (not parameter) then
                self.checkedJournal[info.key] = false
                return false

            elseif parameter.errorMsg then
                if (self.checkedJournal[info.key] ~= false) then
                    local isLogTmp = self.savedVariables.isLog
                    self.savedVariables.isLog = true
                    self:Message(parameter.recipeName .. parameter.errorMsg)
                    self.savedVariables.isLog = isLogTmp
                end
                self.executeCurrent = nil
                self.executeToEnd = nil
                self.checkedJournal[info.key] = false

            elseif parameter.recipeLink then
                self:SetStation(parameter)
                CraftProvisionerItem(parameter.listIndex, parameter.recipeIndex)

                local remainingQuantity = tostring(info.max - info.current)
                if self.executeCurrent then
                    local _, _, stack = GetRecipeResultItemInfo(parameter.listIndex, parameter.recipeIndex)
                    self.executeCurrent = math.min(self.executeCurrent + stack, self.executeToEnd)
                    remainingQuantity = zo_strformat("<<1>>/<<2>> [<<3>>]", self.executeCurrent,
                                                                            self.executeToEnd,
                                                                            GetString(DP_BULK_HEADER))
                end
                


                local msg = zo_strformat("<<1>><<2>> x <<3>>", parameter.icon,
                                                               parameter.recipeLink,
                                                               remainingQuantity)
                self:Message(msg)
                info.current = math.min(info.current + self:GetAmountToMake(parameter.itemType), info.max)
                if info.uniqueId then
                    self.savedVariables.reservations[info.uniqueId].current = info.current
                end
                self.checkedJournal[info.key] = true
                return false
            end
        end
    end
    return true
end




function DailyProvisioning:CreateMenu()

    self.savedVariables.debugLog = {}
    if self.savedVariables.isAcquireItem == nil then
        self.savedVariables.isAcquireItem = true
    end
    if self.savedVariables.acquireDelay == nil then
        self.savedVariables.acquireDelay = 1
    end
    if self.savedVariables.isDontKnow == nil then
        self.savedVariables.isDontKnow = true
    end
    if self.savedVariables.isLog == nil then
        self.savedVariables.isLog = true
    end
    if self.savedVariables.isDebugQuest == nil then
        self.savedVariables.isDebugQuest = true
    end


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
            type = "header",
            name = GetString(DP_BULK_HEADER),
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(DP_BULK_FLG),
            tooltip = GetString(DP_BULK_FLG_TOOLTIP),
            getFunc = function()
                return self.savedVariables.bulkQuantity
            end,
            setFunc = function(value)
                if value then
                    self.savedVariables.bulkQuantity = 1
                else
                    self.savedVariables.bulkQuantity = nil
                end
            end,
            width = "full",
            default = false,
        },
        {
            type = "slider",
            name = GetString(DP_BULK_COUNT),
            tooltip = GetString(DP_BULK_COUNT_TOOLTIP),
            min = 1,
            max = 100,
            step = 1,
            disabled = function()
                return (not self.savedVariables.bulkQuantity)
            end,
            getFunc = function()
                return self.savedVariables.bulkQuantity
            end,
            setFunc = function(value)
                self.savedVariables.bulkQuantity = tonumber(value)
            end,
            width = "full",
            default = 1,
        },
        {
            type = "header",
            name = GetString(DP_OTHER_HEADER),
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(DP_ACQUIRE_ITEM),
            getFunc = function()
                return self.savedVariables.isAcquireItem
            end,
            setFunc = function(value)
                self.savedVariables.isAcquireItem = value
            end,
            width = "full",
            default = true,
        },
        {
            type = "slider",
            name = GetString(DP_DELAY),
            tooltip = GetString(DP_DELAY_TOOLTIP),
            min = 0,
            max = 10,
            step = 0.5,
            disabled = function()
                return (not self.savedVariables.isAcquireItem)
            end,
            getFunc = function()
                return self.savedVariables.acquireDelay
            end,
            setFunc = function(value)
                self.savedVariables.acquireDelay = tonumber(value)
            end,
            width = "full",
            default = 1,
        },
        {
            type = "checkbox",
            name = GetString(DP_AUTO_EXIT),
            tooltip = GetString(DP_AUTO_EXIT_TOOLTIP),
            getFunc = function()
                return self.savedVariables.isAutoExit
            end,
            setFunc = function(value)
                self.savedVariables.isAutoExit = value
            end,
            width = "full",
            default = true,
        },
        {
            type = "checkbox",
            name = GetString(DP_DONT_KNOW),
            tooltip = GetString(DP_DONT_KNOW_TOOLTIP),
            getFunc = function()
                return self.savedVariables.isDontKnow
            end,
            setFunc = function(value)
                self.savedVariables.isDontKnow = value
            end,
            width = "full",
            default = true,
        },
        {
            type = "checkbox",
            name = GetString(DP_LOG),
            getFunc = function()
                return self.savedVariables.isLog
            end,
            setFunc = function(value)
                self.savedVariables.isLog = value
            end,
            width = "full",
            default = true,
        },
        {
            type = "checkbox",
            name = GetString(DP_DEBUG_LOG),
            getFunc = function()
                return self.savedVariables.isDebug
            end,
            setFunc = function(value)
                self.savedVariables.isDebug = value
                DP_IsDebugSettings:SetHidden(not value)
                DP_IsDebugQuest:SetHidden(not value)
                DP_IsDebugRecipe:SetHidden(not value)
            end,
            width = "full",
            default = false,
        },
        {
            type = "checkbox",
            name = zo_strformat("<<1>>(<<2>>)", GetString(DA_DEBUG_LOG), GetString(SI_GAME_MENU_SETTINGS)),
            getFunc = function()
                DP_IsDebugSettings:SetHidden(not self.savedVariables.isDebug)
                return self.savedVariables.isDebugSettings
            end,
            setFunc = function(value)
                self.savedVariables.isDebugSettings = value
            end,
            width = "full",
            default = true,
            reference = "DP_IsDebugSettings",
        },
        {
            type = "checkbox",
            name = zo_strformat("<<1>>(<<2>>)", GetString(DP_DEBUG_LOG), GetString(SI_QUEST_JOURNAL_MENU_JOURNAL)),
            getFunc = function()
                DP_IsDebugQuest:SetHidden(not self.savedVariables.isDebug)
                return self.savedVariables.isDebugQuest
            end,
            setFunc = function(value)
                self.savedVariables.isDebugQuest = value
            end,
            width = "full",
            default = true,
            reference = "DP_IsDebugQuest",
        },
        {
            type = "checkbox",
            name = zo_strformat("<<1>>(<<2>>)", GetString(DP_DEBUG_LOG), GetString(SI_ITEMTYPE29)),
            getFunc = function()
                DP_IsDebugRecipe:SetHidden(not self.savedVariables.isDebug)
                return self.savedVariables.isDebugRecipe
            end,
            setFunc = function(value)
                self.savedVariables.isDebugRecipe = value
            end,
            width = "full",
            default = false,
            reference = "DP_IsDebugRecipe",
        }
    }
    LibAddonMenu2:RegisterOptionControls(self.displayName, optionsTable)
end




function DailyProvisioning:CreateParameter(info)

    self:Debug("　　[CreateParameter]")
    local qualityMax = 1
    local qualityMin = 1
    if info.isEvent then
        qualityMax = 4
        qualityMin = 1
    elseif info.isMaster then
        qualityMax = 4
        qualityMin = 1
    end

    local listIndexs
    if info.isEvent then
        listIndexs = {1, 2,  3,  4,  5,  6,  7, 16,
                      8, 9, 10, 11, 12, 13, 14, 15} -- ALL
    elseif info.isMaster then
        listIndexs = {4, 5, 6, 7, 16,
                      11, 12, 13, 14, 15}
    else
        listIndexs = {1, 2, 3,
                      8, 9, 10}
    end

    local resultItem = string.match(info.convertedTxt, "%[(.+)%]")
    if not resultItem then
        local isLogTmp = self.savedVariables.isLog
        self.savedVariables.isLog = true
        local msg = zo_strformat(GetString(DP_MISMATCH_RECIPE), info.convertedTxt)
        self:Message(msg, self.failedColor)
        self.savedVariables.isLog = isLogTmp
        self:DebugIfMarify("　　txt=\"<<1>>\"", tostring(info.txt))
        self:DebugIfMarify("　　convertedTxt=\"<<1>>\"", tostring(info.convertedTxt))
        return {}
    end
    self:Debug("　　　　Quality=<<1>> to <<2>>", qualityMin, qualityMax)
    self:Debug("　　　　resultItem=\"<<1>>\"", resultItem)
    local convertedItemNames
    for _, recipe in pairs (self.recipeList) do
        if self:ContainsNumber(recipe.listIndex, listIndexs) then
            if recipe.skillQuality <= qualityMax and recipe.skillQuality >= qualityMin then

                convertedItemNames = self:ConvertedItemNames(recipe.recipeName)
                for i, name in pairs (convertedItemNames) do

                    -- There are cases where string.match("xxx", "%[" .. "xxx" .. "%]") does not work properly depending on the timing ...
                    if self:Contains(resultItem, name) then
                        self:Debug("　　　　(O):Index<<1>>-<<2>>: <<3>><<4>>", recipe.listIndex,
                                                                               recipe.recipeIndex,
                                                                               name,
                                                                               recipe.errorMsg)
                        return {self:ComplementRecipeData(recipe)}

                    elseif self:IsDebug() then
                        --self:Debug("　　　　(X):Index<<1>>-<<2>>: <<3>><<4>>", recipe.listIndex,
                        --                                                       recipe.recipeIndex,
                        --                                                       name,
                        --                                                       recipe.errorMsg)
                        -- Don't Use self:Debug() !
                        d("|c" .. self.disabledColor
                          .. self.shortName .. ":"
                          .. zo_strformat("　　　　(X):Index<<1>>-<<2>>: ", recipe.listIndex, recipe.recipeIndex)
                          .. "\"" .. name .. "\""
                          .. (i == 1 and recipe.errorMsg or "")
                          .. "|r")
                    end
                end
            else
                self:Debug("　　　　(X):Quality<<1>>:Index<<2>>-<<3>>: <<4>>", recipe.skillQuality,
                                                                               recipe.listIndex,
                                                                               recipe.recipeIndex,
                                                                               name)
            end
        end
    end
    self:DebugIfMarify("　　txt=\"<<1>>\" (<<2>>/<<3>>)<<4>>", info.txt,
                                                               info.current,
                                                               info.max,
                                                               info.bulkMark,
                                                               "ff00ff")


    local recipe = self:GetRecipeException(info)
    if recipe then
        if recipe.isKnown then
            self:DebugIfMarify("　　convertedTxt=\"<<1>>\"", tostring(info.convertedTxt))
            self:DebugIfMarify("　　　　(O): Index<<1>>-<<2>>: \"<<3>>\" skillLevel=<<4>> skillQuality=<<5>>", recipe.listIndex,
                                                                                                               recipe.recipeIndex,
                                                                                                               recipe.recipeName,
                                                                                                               recipe.skillLevel,
                                                                                                               recipe.skillQuality,
                                                                                                               "ff00ff")
            self:DebugIfMarify("　　　　(O): Index<<1>>-<<2>>: <<3>> skillLevel=<<4>> skillQuality=<<5>>", recipe.listIndex,
                                                                                                           recipe.recipeIndex,
                                                                                                           recipe.recipeName,
                                                                                                           recipe.skillLevel,
                                                                                                           recipe.skillQuality,
                                                                                                           "ff00ff")
        else
            self:Debug("　　　　(X):Index<<1>>-<<2>>: <<3>><<4>>", recipe.listIndex,
                                                                   recipe.recipeIndex,
                                                                   recipe.recipeName,
                                                                   recipe.errorMsg,
                                                                   self.disabledColor)
        end
        return {self:ComplementRecipeData(recipe)}
    end

    local msg = zo_strformat(GetString(DP_MISMATCH_RECIPE), info.convertedTxt)
    local isLogTmp = self.savedVariables.isLog
    self.savedVariables.isLog = true
    self:Message(msg, self.failedColor)
    self.savedVariables.isLog = isLogTmp
    self:DebugIfMarify("　　txt=\"<<1>>\"", tostring(info.txt))
    self:DebugIfMarify("　　convertedTxt=\"<<1>>\"", tostring(info.convertedTxt))
    return {}
end




function DailyProvisioning:ExistUnknownRecipe(infos)

    self:Debug("　　[ExistUnknownRecipe]")

    -- Case: Already checked.
    if self.existUnknownRecipe ~= nil then
        self:Debug("　　　　><<1>>", tostring(self.existUnknownRecipe), self.checkColor)
        return self.existUnknownRecipe
    end


    self.existUnknownRecipe = false
    local toHide = self:IsDebug()
    if toHide then
        self.savedVariables.isDebug = false
    end

    local bulkQuantity = self.savedVariables.bulkQuantity
    self.savedVariables.bulkQuantity = nil

    local parameter
    for _, info in pairs(infos) do
        if (not info.isMaster)
            and self:IsValidConditions(info.convertedTxt, info.current, info.max, info.isVisible) then

            parameter = self:CreateParameter(info)[1]
            parameterList = self:CreateParameter(info)

            if (not parameter) then
                -- Case DP_MISMATCH_RECIPE
                self.existUnknownRecipe = true
                break

            elseif parameter.errorMsg and (not parameter.isKnown) then
                local isLogTmp = self.savedVariables.isLog
                self.savedVariables.isLog = true
                local msg = zo_strformat(GetString(DP_UNKNOWN_RECIPE), parameter.recipeName)
                self:Message(msg)
                self.savedVariables.isLog = isLogTmp

                self.existUnknownRecipe = true
                break
            end
        end
    end
    if toHide then
        self.savedVariables.isDebug = true
    end


    self.savedVariables.bulkQuantity = bulkQuantity
    self.bulkConditionText = nil
    self.executeCurrent = nil
    self.executeToEnd = nil

    self:Debug("　　　　><<1>>", tostring(self.existUnknownRecipe), self.checkColor)
    return self.existUnknownRecipe
end




function DailyProvisioning:Finalize()
    self:Debug("[Finalize]")
    self.bulkConditionText = nil
    self.executeCurrent = nil
    self.executeToEnd = nil
    self.checkedJournal = {}

    self.recipeList = nil
    self.itemTypeFilter = {}
    self.stackList = {}
    self.houseStackList = {}
    self.existUnknownRecipe = nil
    self.isStationInteract = false
end




function DailyProvisioning:GetAmountToMake(itemType)

    local skillType, skillIndex = GetCraftingSkillLineIndices(CRAFTING_TYPE_PROVISIONING)
    local abilityIndex = 5
    if itemType == ITEMTYPE_DRINK then
        abilityIndex = 6
    end
    local abilityName, _, _, _, _, purchased, _, rankIndex = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
    if (not purchased) then
        rankIndex = 0
    end

    -- Rank0:1
    -- Rank1:2 (+1)
    -- Rank2:3 (+2)
    -- Rank3:4 (+3)
    abilityName = abilityName:gsub("(\^)%a*", "")
    self:Debug("　　　　<<1>> Rank<<2>> ... AmountToMake=<<3>>", abilityName, rankIndex, 1 + rankIndex)
    return 1 + rankIndex
end




function DailyProvisioning:GetQuestInfos()

    local toHide = self:IsDebug() and (not self.savedVariables.isDebugQuest)
    if toHide then
        self.savedVariables.isDebug = false
    end

    self:Debug("　　[GetQuestInfos]")

    local hasMaster = false
    local hasDaily = false
    local hasEvent = false
    local list = {}
    for questIdx = 1, MAX_JOURNAL_QUESTS do
        local questName = GetJournalQuestName(questIdx)
        if self:IsValidQuest(questIdx, questName) then

            local isMaster = self:Contains(questName, GetString(DP_CRAFTING_MASTER))
            local isEvent = self:Contains(questName, GetString(DP_CRAFTING_EVENT1), GetString(DP_CRAFTING_WITCH))
            if isMaster then
                hasMaster = true
            elseif isEvent then
                hasEvent = true
            else
                hasDaily = true
            end

            for stepIdx = 1, GetJournalQuestNumSteps(questIdx) do
                for conditionIdx = 1, GetJournalQuestNumConditions(questIdx, stepIdx) do

                    local key = table.concat({questIdx, stepIdx, conditionIdx}, "_")
                    local txt, current, max, _, _, _, isVisible, conditionType = GetJournalQuestConditionInfo(questIdx,
                                                                                                              stepIdx,
                                                                                                              conditionIdx)
                    if isVisible and txt and txt ~="" then
                        local info = {}
                        info.txt = txt
                        info.convertedTxt = self:ConvertedJournalCondition(txt)
                        info.current = current
                        info.max = max
                        info.isVisible = isVisible
                        info.isMaster = isMaster
                        info.isEvent = isEvent
                        info.key = key
                        info.questIdx = questIdx
                        info.stepIdx = stepIdx
                        info.conditionIdx = conditionIdx
                        info.conditionType = conditionType

                        self:Debug("　　　　　　<<1>>-<<2>>-<<3>>: <<4>>", info.questIdx,
                                                                           info.stepIdx,
                                                                           info.conditionIdx,
                                                                           info.convertedTxt)
                        list[#list + 1] = info
                    end
                end
            end


        end
    end


    local reservations = self.savedVariables.reservations or {}
    local itemLink
    local uniqueId
    local reservation
    local txt
    local slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, nil)
    while slotIndex do
        itemLink = GetItemLink(BAG_BACKPACK, slotIndex)
        if self:GetCraftingTypeByLink(itemLink) == CRAFTING_TYPE_PROVISIONING then
            uniqueId = Id64ToString(GetItemUniqueId(BAG_BACKPACK, slotIndex))
            reservation = reservations[uniqueId]
            if reservation then
                self:Debug("　　　　questName(O):" .. GetString(DP_CRAFTING_MASTER))
                txt = GenerateMasterWritBaseText(GetItemLink(BAG_BACKPACK, slotIndex))
                local info = {}
                info.recipeItemId = reservation.recipeItemId
                info.uniqueId = uniqueId
                info.txt = txt
                info.convertedTxt = self:ConvertedJournalCondition(txt)
                info.current = reservation.current
                info.max = reservation.max
                info.isVisible = true
                info.isMaster = not reservation.isEvent
                info.isEvent = reservation.isEvent
                info.key = uniqueId
                list[#list + 1] = info
                if reservation.isEvent then
                    hasEvent = true
                else
                    hasMaster = true
                end
                self:Debug(zo_strformat("　　　　　　<<1>>:<<2>> <<3>> / <<4>>", info.recipeItemId,
                                                                                 tostring(info.convertedTxt),
                                                                                 tostring(info.current),
                                                                                 tostring(info.max)))
            end
        end
        slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, slotIndex)
    end

    if toHide then
        self.savedVariables.isDebug = true
    end
    return list, hasMaster, hasDaily, hasEvent
end




function DailyProvisioning:GetRecipeException(info)

    self:Debug("　　[GetRecipeException]")
    local listName, numRecipes
    local isKnown, recipeName, numIg, level, quality, ingredientType, stationType
    local itemLink
    local itemId
    self:Debug("　　　　info.questIdx=" .. tostring(info.questIdx))
    self:Debug("　　　　info.stepIdx=" .. tostring(info.stepIdx))
    self:Debug("　　　　info.conditionIdx=" .. tostring(info.conditionIdx))

    for listIndex = 1, GetNumRecipeLists() do
        listName, numRecipes = GetRecipeListInfo(listIndex)
        for recipeIndex = 1, numRecipes do
            isKnown, recipeName, numIg, level, quality, ingredientType, stationType = GetRecipeInfo(listIndex,
                                                                                                    recipeIndex)
            itemLink = GetRecipeResultItemLink(listIndex, recipeIndex)
            itemId   = GetItemLinkItemId(itemLink)
            if (info.questIdx and DoesItemLinkFulfillJournalQuestCondition(itemLink,
                                                                           info.questIdx,
                                                                           info.stepIdx,
                                                                           info.conditionIdx))
            or (info.recipeItemId and info.recipeItemId == itemId) then
                local recipe = {}
                recipe.recipeName       = recipeName
                recipe.isKnown          = isKnown
                recipe.listIndex        = listIndex
                recipe.recipeIndex      = recipeIndex
                recipe.ingredientType   = ingredientType
                recipe.numIngredients   = numIg
                recipe.len              = string.len(recipeName)
                recipe.skillLevel       = level
                recipe.skillQuality     = quality

                if (not isKnown) then
                    recipe.errorMsg = GetString(DP_NOTHING_RECIPE)
                end
                return self:ComplementRecipeData(recipe)
            end
        end
    end
    return nil
end




function DailyProvisioning:GetRecipeList(hasMaster, hasDaily, hasEvent)

    local toHide = self:IsDebug() and (not self.savedVariables.isDebugRecipe)
    if toHide then
        self.savedVariables.isDebug = false
    end

    self:Debug("　　[GetRecipeList]")
    self.itemTypeFilter = {ITEMTYPE_INGREDIENT, ITEMTYPE_DRINK, ITEMTYPE_FOOD}
    local itemTypeCache = {ITEMTYPE_INGREDIENT, ITEMTYPE_DRINK, ITEMTYPE_FOOD}
    local list = {}
    local listName, numRecipes
    local isKnown, recipeName, numIg, level, quality, ingredientType, stationType
    local itemLink
    local itemType
    local levelMax = self.savedCharVariables.levelWhenReceived
    local levelMin = levelMax
    if (not levelMax) then
        levelMax = self:GetSkillLevel()
        levelMin = math.max(levelMax - 3, 1)
    end
    if hasEvent then
        levelMax = 6
        levelMin = 1
    elseif hasMaster then
        levelMax = 6
        levelMin = 1
    end

    local qualityMax = 1
    local qualityMin = 1
    if hasEvent then
        qualityMax = 4
        qualityMin = 1
    elseif hasMaster then
        qualityMax = 4
        qualityMin = 1 -- TODO: In case of Master, is there quality 1?
    end

    local recipe
    for listIndex = 1, GetNumRecipeLists() do
        listName, numRecipes = GetRecipeListInfo(listIndex)
        for recipeIndex = 1, numRecipes do
            isKnown, recipeName, numIg, level, quality, ingredientType, stationType = GetRecipeInfo(listIndex, recipeIndex)

            if recipeName
                and recipeName ~= ""
                and stationType == CRAFTING_TYPE_PROVISIONING
                and ingredientType ~= PROVISIONER_SPECIAL_INGREDIENT_TYPE_FURNISHING
                and level <= levelMax
                and level >= levelMin
                and quality <= qualityMax
                and quality >= qualityMin then

                recipe = {}
                recipe.recipeName       = recipeName
                recipe.isKnown          = isKnown
                recipe.listIndex        = listIndex
                recipe.recipeIndex      = recipeIndex
                recipe.ingredientType   = ingredientType
                recipe.numIngredients   = numIg
                recipe.len              = string.len(recipeName)
                recipe.skillLevel       = level
                recipe.skillQuality     = quality

                if (not isKnown) then -- Flags are not returned correctly in some environments?
                    recipe.errorMsg = GetString(DP_NOTHING_RECIPE)

                elseif quality >= 2 then
                    for igIndex = 1, numIg do
                        itemLink = GetRecipeIngredientItemLink(listIndex, recipeIndex, igIndex)
                        itemType = GetItemLinkItemType(itemLink)
                        if (not itemTypeCache[itemType]) then
                            itemTypeCache[itemType] = true
                            self.itemTypeFilter[#self.itemTypeFilter + 1] = itemType
                        end
                    end
                end
                list[#list + 1] = recipe
            end
        end
    end
    table.sort(list, function(a, b)

        local isMasterA = (a.skillQuality > 1)
        local isMasterB = (b.skillQuality > 1)
        if isMasterA and isMasterB then
            return a.len > b.len
        end
        if isMasterA then -- a > b
            return true
        end
        if isMasterB then -- b > a
            return false
        end

        if a.skillLevel ~= b.skillLevel then
            return a.skillLevel > b.skillLevel
        end

        return a.len > b.len
    end)


    self:GetSkillLevel()
    self:GetSkillQuality()
    self:Debug("　　　　LevelWhenReceived=" .. tostring(self.savedCharVariables.levelWhenReceived))
    self:Debug("　　　　QualityWhenReceived=" .. tostring(self.savedCharVariables.qualityWhenReceived))
    self:Debug("　　　　hasMaster=" .. tostring(hasMaster))
    self:Debug("　　　　hasDaily=" .. tostring(hasDaily))
    self:Debug("　　　　hasEvent=" .. tostring(hasEvent))
    self:Debug("　　　　Level=" .. tostring(levelMin) .. " to " .. tostring(levelMax))
    self:Debug("　　　　Quality=" .. tostring(qualityMin) .. " to " .. tostring(qualityMax))
    local convertedItemNames
    for _, recipe in pairs(list) do
        --convertedItemNames = self:ConvertedItemNames(recipe.recipeName)
        self:Debug("　　　　Lv<<1>>:Quality<<2>>:Index<<3>>-<<4>>: <<5>><<6>>", recipe.skillLevel,
                                                                                recipe.skillQuality,
                                                                                recipe.listIndex,
                                                                                recipe.recipeIndex,
                                                                                recipe.recipeName,
                                                                                recipe.errorMsg,
                                                                                (not recipe.isKnown) and self.disabledColor or nil
                                                                                )
    end
    self:Debug("　　　　Total:" .. #list)

    if toHide then
        self.savedVariables.isDebug = true
    end
    return list
end




function DailyProvisioning:GetSkillLevel()

    local skillType, skillIndex = GetCraftingSkillLineIndices(CRAFTING_TYPE_PROVISIONING)
    local abilityIndex = 1
    local abilityName, _, _, _, _, purchased, _, rankIndex = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
    if (not purchased) then
        rankIndex = 1
    end

    abilityName = abilityName:gsub("(\^)%a*", "")
    self:Debug("　　　　" .. abilityName .. " Level" .. rankIndex)
    return rankIndex
end




function DailyProvisioning:GetSkillQuality()

    local skillType, skillIndex = GetCraftingSkillLineIndices(CRAFTING_TYPE_PROVISIONING)
    local abilityIndex = 2
    local abilityName, _, _, _, _, purchased, _, rankIndex = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
    if (not purchased) then
        rankIndex = 1
    end

    abilityName = abilityName:gsub("(\^)%a*", "")
    self:Debug("　　　　" .. abilityName .. " Quality" .. rankIndex)
    return rankIndex
end




function DailyProvisioning:GetStackList()

    local stackList = {}
    local itemType
    for i, bagId in ipairs({BAG_BACKPACK, BAG_VIRTUAL, BAG_BANK, BAG_SUBSCRIBER_BANK}) do
        local slotIndex = ZO_GetNextBagSlotIndex(bagId, nil)
        while slotIndex do
            itemType = GetItemType(bagId, slotIndex)
            if self:ContainsNumber(itemType, self.itemTypeFilter) then
                local itemId = GetItemId(bagId, slotIndex)
                local _, stack = GetItemInfo(bagId, slotIndex)
                local totalStack = stackList[itemId] or 0
                stackList[itemId] = totalStack + stack
            end

            slotIndex = ZO_GetNextBagSlotIndex(bagId, slotIndex)
        end
    end
    return stackList
end




function DailyProvisioning:IsValidConditions(conditionText, current, max, isVisible)

    self:Debug("　　[IsValidConditions]")
    if (not conditionText) or conditionText == "" then
        self:Debug("　　　　> conditionText is nil")
        return nil
    end


    if not string.match(conditionText, "%[.+%]") then
        self:Debug("　　　　(X):<<1>>", tostring(conditionText), self.disabledColor)
        return nil -- Thanks @mightyjo!
    end


    if self.savedVariables.bulkQuantity then
        --self:Debug("　　　　bulkQuantity=" .. tostring(self.savedVariables.bulkQuantity), self.checkColor)
        self:Debug("　　　　isVisible=" .. tostring(isVisible), self.checkColor)
        self:Debug("　　　　current=" .. tostring(current), self.checkColor)
        self:Debug("　　　　max=" .. tostring(max), self.checkColor)
        self:Debug("　　　　self.executeCurrent=" .. tostring(self.executeCurrent), self.checkColor)
        self:Debug("　　　　self.executeToEnd=" .. tostring(self.executeToEnd), self.checkColor)
        self:Debug("　　　　-----------------------------", self.checkColor)
        if self.executeCurrent == nil and isVisible and (current < max) then
            local conditions = self.CraftingConditions()
            if (#conditions == 0) or self:Contains(conditionText, conditions) then
                self.bulkConditionText = conditionText
                self.executeCurrent = 0
                self.executeToEnd = tonumber(self.savedVariables.bulkQuantity)
                self:Debug("　　　　self.executeCurrent > " .. tostring(self.executeCurrent), self.checkColor)
                self:Debug("　　　　self.executeToEnd > " .. tostring(self.executeToEnd), self.checkColor)
                self:Debug("　　　　(O): <<1>> [<<2>> <<3>>/<<4>>]", tostring(conditionText),
                                                                     GetString(DP_BULK_HEADER),
                                                                     self.executeCurrent,
                                                                     self.executeToEnd,
                                                                     self.checkColor)
               return conditionText
            end

        elseif self.executeCurrent == nil then
            self:Debug("　　　　(X): <<1>> [<<2>>]", tostring(conditionText),
                                                     GetString(DP_BULK_HEADER),
                                                     self.disabledColor)
            return nil

        elseif self.executeCurrent < self.executeToEnd then
            self:Debug("　　　　(O): <<1>> [<<2>> <<3>>/<<4>>]", tostring(self.bulkConditionText),
                                                                 GetString(DP_BULK_HEADER),
                                                                 self.executeCurrent,
                                                                 self.executeToEnd,
                                                                 self.checkColor)
            return self.bulkConditionText
        else
            self.bulkConditionText = nil
            self.executeCurrent = nil
            self.executeToEnd = nil
            self:Debug("　　　　self.executeCurrent > " .. tostring(self.executeCurrent), self.checkColor)
            self:Debug("　　　　self.executeToEnd > " .. tostring(self.executeToEnd), self.checkColor)
        end

    elseif isVisible and (current < max) then
        local conditions = self.CraftingConditions()
        if (#conditions == 0) or self:Contains(conditionText, conditions) then
            self:Debug("　　　　(O):" .. tostring(conditionText))
            return conditionText
        end
    end

    self:Debug("　　　　(X):<<1>>", tostring(conditionText), self.disabledColor)
    return nil
end




function DailyProvisioning:IsValidQuest(questIdx, questName)

    if GetJournalQuestType(questIdx) == QUEST_TYPE_CRAFTING then
        if (not GetJournalQuestIsComplete(questIdx)) then
            if self:Contains(questName, GetString(DP_CRAFTING_QUEST), GetString(DP_CRAFTING_MASTER)) then
                self:Debug("　　　　questName(O):<<1>>", questName)
                return true
            end

            if self:Contains(questName, GetString(DP_CRAFTING_EVENT1), GetString(DP_CRAFTING_WITCH)) then
                for stepIdx = 1, GetJournalQuestNumSteps(questIdx) do
                    for conditionIdx = 1, GetJournalQuestNumConditions(questIdx, stepIdx) do
                        local txt, current, max, _, _, _, isVisible = GetJournalQuestConditionInfo(questIdx,
                                                                                                   stepIdx,
                                                                                                   conditionIdx)
                        if isVisible and txt and txt ~="" and (not self:isProvisioning(txt)) then
                            self:Debug("　　　　questName(X1):<<1>>", questName, self.disabledColor)
                            return false
                        end
                        if isVisible and current >= max then
                            self:Debug("　　　　questName(X2):<<1>>", questName, self.disabledColor)
                            return false
                        end
                    end
                end
                self:Debug("　　　　questName(O):<<1>>", questName)
                return true
            else
                self:Debug("　　　　questName(X3):<<1>>", questName, self.disabledColor)
            end
        else
            self:Debug("　　　　questName(X):<<1>> isComplete", questName, self.disabledColor)
        end
    end
    return false
end




function DailyProvisioning:ComplementRecipeData(recipe)

    self:Debug("　　　　[ComplementRecipeData]")

    recipe.recipeName       = self:ConvertedItemNameForDisplay(recipe.recipeName)
    if (not recipe.isKnown) then
        recipe.recipeLink = self.questRecipeList[recipe.listIndex][recipe.recipeIndex]
        recipe.itemId     = GetItemLinkItemId(recipe.recipeLink)

        if recipe.recipeLink == nil then
            self:DebugIfMarify("　　　　New Recipe <<1>> (listIndex<<2>>, recipeIndex<<3>>)", recipe.recipeName,
                                                                                              recipe.listIndex,
                                                                                              recipe.recipeIndex,
                                                                                              "ff00ff")
        end

        return recipe
    end

    recipe.recipeLink       = GetRecipeResultItemLink(recipe.listIndex, recipe.recipeIndex)
    recipe.itemId           = GetItemLinkItemId(recipe.recipeLink)
    recipe.itemType         = GetItemLinkItemType(recipe.recipeLink)
    recipe.icon             = zo_iconFormat(GetItemLinkIcon(recipe.recipeLink), 20, 20)
    recipe.ingredients      = {}
    recipe.ingredientLinks  = {}


    local ingredient
    local count
    local nameForDisplay
    local shortList = {}
    for ingredientIndex = 1, recipe.numIngredients do
        ingredient = {}
        ingredient.itemName, _, ingredient.quantity = GetRecipeIngredientItemInfo(recipe.listIndex,
                                                                                  recipe.recipeIndex,
                                                                                  ingredientIndex)
        ingredient.itemLink = GetRecipeIngredientItemLink(recipe.listIndex, recipe.recipeIndex, ingredientIndex)
        ingredient.itemId = GetItemLinkItemId(ingredient.itemLink)
        ingredient.icon = zo_iconFormat(GetItemLinkIcon(ingredient.itemLink), 20, 20)
        count = GetCurrentRecipeIngredientCount(recipe.listIndex, recipe.recipeIndex, ingredientIndex)
        nameForDisplay = self:ConvertedItemNameForDisplay(ingredient.itemName)
        self:Debug("　　　　　　<<1>><<2>> (<<3>>/<<4>>)", ingredient.icon, nameForDisplay, count, ingredient.quantity)
        if count < ingredient.quantity then
            shortList[#shortList + 1] = ingredient.icon .. nameForDisplay
        end
        recipe.ingredients[#recipe.ingredients + 1] = ingredient
        recipe.ingredientLinks[#recipe.ingredientLinks + 1] = ingredient.itemLink
    end

    if #shortList > 0 and self.isStationInteract then
        recipe.errorMsg = zo_strformat(GetString(DP_SHORT_OF), table.concat(shortList, ", "))
    end
    return recipe
end




function DailyProvisioning:OnAddOnLoaded(event, addonName)

    if addonName ~= self.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
    setmetatable(DailyProvisioning, {__index = LibMarify})


    SLASH_COMMANDS["/langen"] = function() SetCVar("language.2", "en") end
    SLASH_COMMANDS["/langjp"] = function() SetCVar("language.2", "jp") end
    SLASH_COMMANDS["/langde"] = function() SetCVar("language.2", "de") end
    SLASH_COMMANDS["/langfr"] = function() SetCVar("language.2", "fr") end
    SLASH_COMMANDS["/langru"] = function() SetCVar("language.2", "ru") end
    if EsoPL then
        SLASH_COMMANDS["/langpl"] = function() SetCVar("language.2", "pl") end
    end

    self.savedVariables = ZO_SavedVars:NewAccountWide("DailyProvisioningVariables", 1, nil, {})
    self.savedCharVariables  = ZO_SavedVars:NewCharacterIdSettings("DailyProvisioningVariables", 1, nil, {})
    self:CreateMenu()

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CRAFTING_STATION_INTERACT,     function(...) self:StationInteract(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CRAFT_COMPLETED,               function(...) self:CraftCompleted(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_END_CRAFTING_STATION_INTERACT, function(...) self:Finalize(...) end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED,              function(...) self:Camehome() end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_BANK,                     function(...) self:OnOpenBank() end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_BANK,                    function(...) self:Finalize(...) end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_QUEST_ADDED,                   function(...) self:QuestReceived(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_QUEST_COMPLETE,                function(...) self:QuestComplete(...) end)
    self:PostHook(ZO_PlayerInventoryBackpack.dataTypes[1], "setupCallback",        function(...) self:UpdateInventory(...) end)
    LibCustomMenu:RegisterContextMenu(function(...) self:ShowContextMenu(...) end, LibCustomMenu.CATEGORY_LATE)

end




function DailyProvisioning:QuestComplete()
    local oldReservations = self.savedVariables.reservations
    local newReservations = {}
    local uniqueId
    local reservation
    local slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, nil)
    while slotIndex do
        if string.match(GetItemInfo(BAG_BACKPACK, slotIndex), "master_writ_alchemy") then
            uniqueId = Id64ToString(GetItemUniqueId(BAG_BACKPACK, slotIndex))
            reservation = oldReservations[uniqueId]
            if reservation then
                newReservations[uniqueId] = reservation
            end
        end
        slotIndex = ZO_GetNextBagSlotIndex(BAG_BACKPACK, slotIndex)
    end
    self.savedVariables.reservations = newReservations
end




function DailyProvisioning:QuestReceived(eventCode, journalIndex, questName, objectiveName)

    if self:Contains(questName, GetString(DP_CRAFTING_QUEST)) then
        self.savedCharVariables.levelWhenReceived = self:GetSkillLevel()
        self.savedCharVariables.qualityWhenReceived = self:GetSkillQuality()
        self.savedVariables.debugLog = {}
    end
end




function DailyProvisioning:SetStation(recipe)

    if IsInGamepadPreferredMode() then
        --if GAMEPAD_PROVISIONER.filterType ~= recipe.ingredientType then
        --    ZO_GamepadGenericHeader_SetActiveTabIndex(GAMEPAD_PROVISIONER.header, recipe.ingredientType, false)
        --end

        GAMEPAD_PROVISIONER:RefreshRecipeList()
        for i, data in pairs (GAMEPAD_PROVISIONER.recipeList.dataList) do
            if data.recipeListIndex == recipe.listIndex then
                if data.recipeIndex == recipe.recipeIndex then
                    zo_callLater(function()
                        GAMEPAD_PROVISIONER.recipeList:SetSelectedIndex(i, true)
                    end, 0)
                    break
                end
            end
        end
        return

    else
        if PROVISIONER.filterType ~= recipe.ingredientType then
            ZO_MenuBar_SelectDescriptor(PROVISIONER.tabs, recipe.ingredientType)
            PROVISIONER:RefreshRecipeList()
        end

        local nodes = PROVISIONER.recipeTree.rootNode:GetChildren()
        if (not nodes) then
            PROVISIONER:RefreshRecipeList()
            nodes = PROVISIONER.recipeTree.rootNode:GetChildren()
            if (not nodes) then
                return
            end
        end
        for _, node in pairs (nodes) do
            if node.data.recipeListIndex == recipe.listIndex then
                PROVISIONER.recipeTree:ToggleNode(node)
                for _, childNode in pairs (node:GetChildren()) do
                    if childNode.data.recipeIndex == recipe.recipeIndex then
                        PROVISIONER.recipeTree:SelectNode(childNode)
                        break
                    end
                end
                break
            end
        end
    end
end




function DailyProvisioning:ShowContextMenu(inventorySlot, slotActions)

    local slotType = ZO_InventorySlot_GetType(inventorySlot)
    if slotType ~= SLOT_TYPE_ITEM then
        return
    end


    local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
    local itemLink = GetItemLink(bagId, slotIndex)
    local craftingType, max = self:GetCraftingTypeByLink(itemLink)
    if craftingType ~= CRAFTING_TYPE_PROVISIONING then
        return
    end
    local isEvent = self:Contains(GetItemLinkName(itemLink), GetString(DP_CRAFTING_EVENT1BOOK))
    self:Debug("　　isEvent=" .. tostring(isEvent))


    local uniqueId = Id64ToString(GetItemUniqueId(bagId, slotIndex))
    local lang = GetCVar("language.2")
    local txt = GenerateMasterWritBaseText(itemLink)
    txt = self:ConvertedJournalCondition(txt)

    local reservations = self.savedVariables.reservations
    if (not reservations) then
        reservations = {}
        self.savedVariables.reservations = reservations
    end

    local reservation = reservations[uniqueId]
    if reservation and reservation.current < reservation.max then
        local label = (self.savedVariables.isDebug or self:Equal(GetDisplayName(), "@Marify", "@anego_J"))
                        and zo_strformat("|cE4007F<<1>>|r", GetString(DP_CANCEL_WRIT))
                        or GetString(DP_CANCEL_WRIT)
        AddCustomMenuItem(label, function()
            reservations[uniqueId] = nil
            self:Message(GetString(DP_CANCEL_WRIT_MSG))
            PLAYER_INVENTORY:RefreshAllInventorySlots(INVENTORY_BACKPACK)
        end, MENU_ADD_OPTION_LABEL)
    else
        local label = (self.savedVariables.isDebug or self:Equal(GetDisplayName(), "@Marify", "@anego_J"))
                        and zo_strformat("|c3CB371<<1>>|r", GetString(DP_CRAFT_WRIT))
                        or GetString(DP_CRAFT_WRIT)
        AddCustomMenuItem(label, function()
            local reservation = {}
            reservation.recipeItemId = self:SplitRecipeItemId(itemLink)
            reservation.txt = txt
            reservation.current = 0
            reservation.max = max
            reservation.isEvent = isEvent
            reservations[uniqueId] = reservation
            self:Message(zo_strformat(GetString(DP_CRAFT_WRIT_MSG), txt))
            PLAYER_INVENTORY:RefreshAllInventorySlots(INVENTORY_BACKPACK)
        end, MENU_ADD_OPTION_LABEL)
    end
end




function DailyProvisioning:SplitRecipeItemId(masterWrit)
    return string.match(masterWrit, "item:%d+:%d+:%d+:%d+:%d+:%d+:(%d+)")
end




function DailyProvisioning:StationInteract(eventCode, craftSkill, sameStation)

    if craftSkill ~= CRAFTING_TYPE_PROVISIONING then
        return false
    end

    self.isStationInteract = true
    self.savedVariables.debugLog = {}
    self.recipeList = nil
    self:Debug("[StationInteract]")
    if self:IsDebug() and self.savedVariables.isDebugSettings then
        self:Debug("　　savedVariables.bulkQuantity=" .. tostring(self.savedVariables.bulkQuantity))
        self:Debug("　　savedVariables.isAcquireItem=" .. tostring(self.savedVariables.isAcquireItem))
        self:Debug("　　savedVariables.acquireDelay=" .. tostring(self.savedVariables.acquireDelay))
        self:Debug("　　savedVariables.isAutoExit=" .. tostring(self.savedVariables.isAutoExit))
        self:Debug("　　savedVariables.isDontKnow=" .. tostring(self.savedVariables.isDontKnow))
        self:Debug("　　savedVariables.isLog=" .. tostring(self.savedVariables.isLog))
        self:Debug("　　savedVariables.isDebug=" .. tostring(self.savedVariables.isDebug))
        self:Debug("　　savedVariables.isDebugSettings=" .. tostring(self.savedVariables.isDebugSettings))
        self:Debug("　　savedVariables.isDebugQuest=" .. tostring(self.savedVariables.isDebugQuest))
        self:Debug("　　savedVariables.isDebugRecipe=" .. tostring(self.savedVariables.isDebugRecipe))
    end
    self:Crafting(craftSkill)
end




function DailyProvisioning:UpdateInventory(control)

    local reservations = self.savedVariables.reservations
    if (not reservations) then
        reservations = {}
        self.savedVariables.reservations = reservations
        return
    end

    if ConfirmMasterWrit then
        return
    end

    if (not control) then
        return
    end

    local slot = control.dataEntry.data
    if (not slot) then
        return
    end

    local uniqueId = Id64ToString(GetItemUniqueId(slot.bagId, slot.slotIndex))
    if (not uniqueId) then
        return
    end


    local mark = control:GetNamedChild("DP_ItemMark")
    if (not mark) and reservations[uniqueId] then
        mark = WINDOW_MANAGER:CreateControl(control:GetName() .. "DP_ItemMark", control, CT_TEXTURE)
        mark:SetDrawLayer(3)
        mark:SetDimensions(20, 20)
        mark:ClearAnchors()
        mark:SetAnchor(LEFT, control:GetNamedChild('Bg'), LEFT, 80, 10)
        mark:SetTexture("esoui/art/journal/journal_quest_selected.dds")
    end
    if (not mark) then
        return
    end


    reservation = reservations[uniqueId]
    if reservation then
        if (reservation.current < reservation.max) then
            mark:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, ITEM_QUALITY_LEGENDARY))
        else
            mark:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_DISABLED))
        end
        mark:SetHidden(false)
    else
        mark:SetHidden(true)
    end
end




EVENT_MANAGER:RegisterForEvent(DailyProvisioning.name, EVENT_ADD_ON_LOADED, function(...) DailyProvisioning:OnAddOnLoaded(...) end)

