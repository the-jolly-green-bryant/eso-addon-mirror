local Addon = LarvalTearMod
local AlchemyRecipe = Addon.Modules.AlchemyRecipe
local Log = Addon.Common.Log
local Util = Addon.Common.Util

local STATION_INTERACT_EVENT_NAME = "LTM_AlchemyRecipe_StationInteract"
local STATION_END_EVENT_NAME = "LTM_AlchemyRecipe_StationEnd"
local ALCHEMY_SCENE_CALLBACK_UPDATE_NAME = "LTM_AlchemyRecipe_AlchemySceneRetry"
local ALCHEMY_SCENE_CALLBACK_RETRY_INTERVAL_MS = 1000
local ALCHEMY_SCENE_CALLBACK_MAX_RETRY = 30

AlchemyRecipe.isStationOpen = false

local function NormalizeCharacterKey(characterKey)
    if characterKey ~= nil then
        return tostring(characterKey)
    end

    if type(GetCurrentCharacterId) ~= "function" then
        return nil
    end

    local ok, characterId = pcall(GetCurrentCharacterId)
    if ok and characterId ~= nil then
        return tostring(characterId)
    end

    return nil
end

local function Debug(...)
    Log.Debug("[AlchemyRecipe]", ...)
end

local function NormalizeRecipeId(recipeId)
    if type(recipeId) ~= "string" or recipeId == "" then
        return nil
    end
    return recipeId
end

local function NormalizeAutoApplyEnabled(enabled)
    return enabled == true
end

local function RemoveFirstValue(values, targetValue)
    if type(values) ~= "table" then
        return nil
    end

    for index, value in ipairs(values) do
        if value == targetValue then
            table.remove(values, index)
            return index
        end
    end

    return nil
end

local function GetItemIdFromBagSlot(bagId, slotIndex)
    if bagId == nil or slotIndex == nil or type(GetItemId) ~= "function" then
        return nil
    end

    local ok, itemId = pcall(GetItemId, bagId, slotIndex)
    if ok and type(itemId) == "number" then
        return itemId
    end

    return nil
end

local function ReadCraftingSlot(craftingSlot)
    if type(craftingSlot) ~= "table" or type(craftingSlot.GetBagAndSlot) ~= "function" then
        return nil, nil, nil
    end

    local ok, bagId, slotIndex = pcall(craftingSlot.GetBagAndSlot, craftingSlot)
    if not ok then
        return nil, nil, nil
    end

    return bagId, slotIndex, GetItemIdFromBagSlot(bagId, slotIndex)
end

local function ReadCurrentStationSlots()
    local alchemy = rawget(_G, "ALCHEMY")
    if type(alchemy) ~= "table" then
        return nil
    end

    local solventBag, solventSlot, solventItemId = ReadCraftingSlot(alchemy.solventSlot)
    local slots = {
        solventBag = solventBag,
        solventSlot = solventSlot,
        solventItemId = solventItemId,
        reagents = {},
    }

    local reagentSlots = type(alchemy.reagentSlots) == "table" and alchemy.reagentSlots or {}
    for index = 1, 3 do
        local reagentBag, reagentSlot, reagentItemId = ReadCraftingSlot(reagentSlots[index])
        slots.reagents[index] = {
            bag = reagentBag,
            slot = reagentSlot,
            itemId = reagentItemId,
        }
    end

    return slots
end

local function HasBagSlot(bagId, slotIndex)
    return bagId ~= nil and slotIndex ~= nil
end

local function IsValidItemId(itemId)
    return type(itemId) == "number" and itemId > 0
end

local function GetSlotStackCount(bagId, slotIndex)
    if bagId == nil or slotIndex == nil then
        return 0
    end

    if type(GetSlotStackSize) == "function" then
        local ok, stackCount = pcall(GetSlotStackSize, bagId, slotIndex)
        if ok and tonumber(stackCount) ~= nil then
            return tonumber(stackCount) or 0
        end
    end

    if type(GetItemTotalCount) == "function" then
        local ok, stackCount = pcall(GetItemTotalCount, bagId, slotIndex)
        if ok and tonumber(stackCount) ~= nil then
            return tonumber(stackCount) or 0
        end
    end

    return 0
end

local function GetSearchBagsForCrafting()
    local bags = {}
    local backpackBag = rawget(_G, "BAG_BACKPACK")
    if backpackBag ~= nil then
        bags[#bags + 1] = backpackBag
    end

    local virtualBag = rawget(_G, "BAG_VIRTUAL")
    if virtualBag ~= nil then
        bags[#bags + 1] = virtualBag
    end

    return bags
end

local function AddBagToInventoryIndex(inventoryIndex, bagId)
    local function AddSlot(slotIndex)
        local itemId = GetItemIdFromBagSlot(bagId, slotIndex)
        if itemId == nil or itemId <= 0 then
            return
        end

        local stackCount = GetSlotStackCount(bagId, slotIndex)
        local itemEntry = inventoryIndex.itemsByItemId[itemId]
        if type(itemEntry) ~= "table" then
            inventoryIndex.itemsByItemId[itemId] = {
                bagId = bagId,
                slotIndex = slotIndex,
                stackCount = stackCount,
                totalStackCount = stackCount,
            }
        else
            itemEntry.totalStackCount = (tonumber(itemEntry.totalStackCount) or 0) + stackCount
        end
    end

    if type(ZO_IterateBagSlots) == "function" then
        for slotIndex in ZO_IterateBagSlots(bagId) do
            AddSlot(slotIndex)
        end
    elseif type(GetBagSize) == "function" then
        local ok, bagSize = pcall(GetBagSize, bagId)
        bagSize = ok and tonumber(bagSize) or 0
        for slotIndex = 0, bagSize - 1 do
            AddSlot(slotIndex)
        end
    end
end

local function BuildCraftingInventoryIndex()
    local inventoryIndex = {
        itemsByItemId = {},
    }
    for _, bagId in ipairs(GetSearchBagsForCrafting()) do
        AddBagToInventoryIndex(inventoryIndex, bagId)
    end
    return inventoryIndex
end

local function BuildInventoryItemState(itemId, inventoryIndex)
    itemId = tonumber(itemId)
    if itemId == nil or itemId <= 0 then
        return {
            itemId = itemId,
            found = false,
            bagId = nil,
            slotIndex = nil,
            stackCount = 0,
            totalStackCount = 0,
        }
    end

    local itemEntry = type(inventoryIndex) == "table"
        and type(inventoryIndex.itemsByItemId) == "table"
        and inventoryIndex.itemsByItemId[itemId]
        or nil
    local bagId = type(itemEntry) == "table" and itemEntry.bagId or nil
    local slotIndex = type(itemEntry) == "table" and itemEntry.slotIndex or nil
    return {
        itemId = itemId,
        found = bagId ~= nil and slotIndex ~= nil,
        bagId = bagId,
        slotIndex = slotIndex,
        stackCount = type(itemEntry) == "table" and (tonumber(itemEntry.stackCount) or 0) or 0,
        totalStackCount = type(itemEntry) == "table" and (tonumber(itemEntry.totalStackCount) or 0) or 0,
    }
end

local function IsThirdAlchemySlotUnlocked()
    if type(ZO_Alchemy_IsThirdAlchemySlotUnlocked) ~= "function" then
        return false
    end

    local ok, unlocked = pcall(ZO_Alchemy_IsThirdAlchemySlotUnlocked)
    return ok and unlocked == true
end

local function GetAlchemyObject()
    local alchemy = rawget(_G, "ALCHEMY")
    if type(alchemy) ~= "table" then
        return nil
    end
    return alchemy
end

local function GetMissingRequiredInventoryReason(inventoryState)
    if type(inventoryState) ~= "table" then
        return "inventory_unavailable"
    end
    if type(inventoryState.solvent) ~= "table" or inventoryState.solvent.found ~= true then
        return "item_not_found:solvent"
    end

    local reagents = type(inventoryState.reagents) == "table" and inventoryState.reagents or {}
    if type(reagents[1]) ~= "table" or reagents[1].found ~= true then
        return "item_not_found:reagent1"
    end
    if type(reagents[2]) ~= "table" or reagents[2].found ~= true then
        return "item_not_found:reagent2"
    end

    return nil
end

local function CallAlchemyMethod(alchemy, methodName, ...)
    local method = type(alchemy) == "table" and alchemy[methodName] or nil
    if type(method) ~= "function" then
        return false, "alchemy_method_unavailable:" .. tostring(methodName)
    end

    local ok, result = pcall(method, alchemy, ...)
    if not ok then
        return false, result
    end

    return true, result
end

local function ApplyCraftCountToAlchemySpinner(count)
    count = math.max(math.floor(tonumber(count) or 1), 1)

    local alchemy = GetAlchemyObject()
    if type(alchemy) ~= "table" then
        return false, "alchemy_unavailable"
    end

    local spinner = rawget(alchemy, "multiCraftSpinner")
    if type(spinner) ~= "table" or type(spinner.SetValue) ~= "function" then
        return false, "spinner_unavailable"
    end

    local ok, result = pcall(spinner.SetValue, spinner, count)
    if not ok then
        return false, "spinner_set_failed"
    end

    return true, result
end

local function GetAlchemyScene()
    local scene = rawget(_G, "ALCHEMY_SCENE")
    if scene == nil then
        return nil
    end
    return scene
end

local function GetSceneShowingState()
    return rawget(_G, "SCENE_SHOWING") or "showing"
end

local function IsSceneShowingState(newState)
    return newState == GetSceneShowingState()
end

local function IsAlchemySceneOpen()
    local scene = GetAlchemyScene()
    if type(scene) ~= "table" then
        return AlchemyRecipe.isStationOpen == true
    end

    if type(scene.IsShowing) == "function" then
        local ok, isShowing = pcall(scene.IsShowing, scene)
        if ok and isShowing == true then
            return true
        end
    end

    if type(scene.GetState) == "function" then
        local ok, state = pcall(scene.GetState, scene)
        if ok then
            return state == GetSceneShowingState() or state == rawget(_G, "SCENE_SHOWN")
        end
    end

    return AlchemyRecipe.isStationOpen == true
end

local function GetResultingItemLink(slots)
    if type(slots) ~= "table" or type(GetAlchemyResultingItemLink) ~= "function" then
        return nil
    end

    local reagent1 = type(slots.reagents) == "table" and slots.reagents[1] or nil
    local reagent2 = type(slots.reagents) == "table" and slots.reagents[2] or nil
    local reagent3 = type(slots.reagents) == "table" and slots.reagents[3] or nil
    if type(reagent1) ~= "table" or type(reagent2) ~= "table" then
        return nil
    end

    local ok, itemLink
    if type(reagent3) == "table" and HasBagSlot(reagent3.bag, reagent3.slot) then
        ok, itemLink = pcall(
            GetAlchemyResultingItemLink,
            slots.solventBag,
            slots.solventSlot,
            reagent1.bag,
            reagent1.slot,
            reagent2.bag,
            reagent2.slot,
            reagent3.bag,
            reagent3.slot
        )
    else
        ok, itemLink = pcall(
            GetAlchemyResultingItemLink,
            slots.solventBag,
            slots.solventSlot,
            reagent1.bag,
            reagent1.slot,
            reagent2.bag,
            reagent2.slot
        )
    end

    if ok and type(itemLink) == "string" and itemLink ~= "" then
        return itemLink
    end

    return nil
end

local function OnAlchemySceneStateChange(_, newState)
    if not IsSceneShowingState(newState) then
        return
    end
    if AlchemyRecipe:GetAutoApplyEnabled() ~= true then
        return
    end

    local recipeId = AlchemyRecipe:GetActiveRecipeId()
    if recipeId == nil then
        return
    end

    local ok, result = AlchemyRecipe:ApplyRecipeToStation(recipeId)
    if ok then
        Debug("autoApply", "succeeded=true", "recipeId=" .. tostring(recipeId))
    else
        Debug("autoApply", "succeeded=false", "recipeId=" .. tostring(recipeId), "reason=" .. tostring(result))
    end
end

local function RegisterAlchemySceneCallback()
    if AlchemyRecipe.alchemySceneCallbackRegistered == true then
        return false
    end

    local scene = GetAlchemyScene()
    if scene == nil or type(scene.RegisterCallback) ~= "function" then
        return false
    end

    AlchemyRecipe.alchemySceneCallbackRegistered = true
    scene:RegisterCallback("StateChange", OnAlchemySceneStateChange)
    return true
end

local function ScheduleAlchemySceneCallbackRegistration()
    if AlchemyRecipe.alchemySceneCallbackRegistered == true
        or AlchemyRecipe.alchemySceneCallbackRetryScheduled == true then
        return false
    end
    if type(EVENT_MANAGER) ~= "table" or type(EVENT_MANAGER.RegisterForUpdate) ~= "function" then
        return false
    end

    AlchemyRecipe.alchemySceneCallbackRetryScheduled = true
    local retryCount = 0
    EVENT_MANAGER:RegisterForUpdate(ALCHEMY_SCENE_CALLBACK_UPDATE_NAME, ALCHEMY_SCENE_CALLBACK_RETRY_INTERVAL_MS, function()
        retryCount = retryCount + 1

        if AlchemyRecipe.alchemySceneCallbackRegistered == true then
            AlchemyRecipe.alchemySceneCallbackRetryScheduled = false
            if type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
                EVENT_MANAGER:UnregisterForUpdate(ALCHEMY_SCENE_CALLBACK_UPDATE_NAME)
            end
            return
        end
        if RegisterAlchemySceneCallback() then
            AlchemyRecipe.alchemySceneCallbackRetryScheduled = false
            if type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
                EVENT_MANAGER:UnregisterForUpdate(ALCHEMY_SCENE_CALLBACK_UPDATE_NAME)
            end
            return
        end

        if retryCount >= ALCHEMY_SCENE_CALLBACK_MAX_RETRY then
            AlchemyRecipe.alchemySceneCallbackRetryScheduled = false
            if type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
                EVENT_MANAGER:UnregisterForUpdate(ALCHEMY_SCENE_CALLBACK_UPDATE_NAME)
            end
            Debug("AlchemySceneCallback retry exhausted")
        end
    end)

    return true
end

local function GetItemLinkDisplayName(itemLink)
    if type(itemLink) ~= "string" or itemLink == "" or type(GetItemLinkName) ~= "function" then
        return nil
    end

    local ok, displayName = pcall(GetItemLinkName, itemLink)
    if ok then
        return Util:NormalizeDisplayName(displayName)
    end

    return nil
end

local function BuildDefaultRecipeName(recipeId)
    local suffix = type(recipeId) == "string" and recipeId:match("recipe_(%d+)$") or nil
    return "Recipe " .. (suffix or "0001")
end

local function GetRecipeById(self, recipeId)
    recipeId = NormalizeRecipeId(recipeId)
    if recipeId == nil then
        return nil, "recipe_not_found"
    end

    local bucket = self:GetCharacterBucketReadonly()
    local recipe = type(bucket) == "table"
        and type(bucket.recipes) == "table"
        and bucket.recipes[recipeId]
        or nil
    if type(recipe) ~= "table" then
        return nil, "recipe_not_found"
    end

    return Util:DeepCopy(recipe)
end

function AlchemyRecipe:Initialize(savedVars)
    self.savedVars = savedVars
    self:RegisterStationEvents()
    if not RegisterAlchemySceneCallback() then
        ScheduleAlchemySceneCallbackRegistration()
    end
end

function AlchemyRecipe:EnsureSavedVarsShape(readOnly)
    if type(self.savedVars) ~= "table" then
        return nil
    end

    if type(self.savedVars.alchemyRecipeByCharacter) ~= "table" then
        if readOnly then
            return nil
        end
        self.savedVars.alchemyRecipeByCharacter = {}
    end

    return self.savedVars
end

function AlchemyRecipe:BuildDefaultCharacterBucket(characterKey)
    return {
        recipes = {},
        recipeOrder = {},
        nextIndex = 1,
        activeRecipeId = nil,
        autoApplyEnabled = false,
        ownerCharacterId = characterKey,
    }
end

function AlchemyRecipe:NormalizeCharacterBucket(bucket, characterKey)
    if type(bucket) ~= "table" then
        return nil
    end

    if type(bucket.recipes) ~= "table" then
        bucket.recipes = {}
    end
    if type(bucket.recipeOrder) ~= "table" then
        bucket.recipeOrder = {}
        for recipeId, recipe in pairs(bucket.recipes) do
            if type(recipeId) == "string" and type(recipe) == "table" then
                bucket.recipeOrder[#bucket.recipeOrder + 1] = recipeId
            end
        end
        table.sort(bucket.recipeOrder)
    end

    bucket.nextIndex = math.max(tonumber(bucket.nextIndex) or 1, 1)
    bucket.autoApplyEnabled = NormalizeAutoApplyEnabled(bucket.autoApplyEnabled)
    bucket.activeRecipeId = NormalizeRecipeId(bucket.activeRecipeId)
    bucket.ownerCharacterId = bucket.ownerCharacterId or characterKey

    if bucket.activeRecipeId ~= nil and type(bucket.recipes[bucket.activeRecipeId]) ~= "table" then
        bucket.activeRecipeId = nil
    end

    return bucket
end

function AlchemyRecipe:GetCharacterBucketReadonly()
    local savedVars = self:EnsureSavedVarsShape(true)
    if type(savedVars) ~= "table" or type(savedVars.alchemyRecipeByCharacter) ~= "table" then
        return nil
    end

    local characterKey = NormalizeCharacterKey()
    if type(characterKey) ~= "string" or characterKey == "" then
        return nil
    end

    local bucket = savedVars.alchemyRecipeByCharacter[characterKey]
    if type(bucket) ~= "table" then
        return nil
    end

    bucket = Util:DeepCopy(bucket)
    return self:NormalizeCharacterBucket(bucket, characterKey)
end

function AlchemyRecipe:EnsureCharacterBucketForWrite()
    local savedVars = self:EnsureSavedVarsShape(false)
    if type(savedVars) ~= "table" then
        return nil
    end

    local characterKey = NormalizeCharacterKey()
    if type(characterKey) ~= "string" or characterKey == "" then
        return nil
    end

    local bucket = savedVars.alchemyRecipeByCharacter[characterKey]
    if type(bucket) ~= "table" then
        bucket = self:BuildDefaultCharacterBucket(characterKey)
        savedVars.alchemyRecipeByCharacter[characterKey] = bucket
    end

    return self:NormalizeCharacterBucket(bucket, characterKey)
end

function AlchemyRecipe:GenerateRecipeId(bucket)
    bucket = type(bucket) == "table" and bucket or self:EnsureCharacterBucketForWrite()
    if type(bucket) ~= "table" then
        return nil
    end

    if type(bucket.recipes) ~= "table" then
        bucket.recipes = {}
    end

    while true do
        local nextIndex = math.max(tonumber(bucket.nextIndex) or 1, 1)
        local recipeId = string.format("recipe_%04d", nextIndex)
        bucket.nextIndex = nextIndex + 1
        if type(bucket.recipes[recipeId]) ~= "table" then
            return recipeId
        end
    end
end

function AlchemyRecipe:GetAutoApplyEnabled()
    local bucket = self:GetCharacterBucketReadonly()
    return NormalizeAutoApplyEnabled(type(bucket) == "table" and bucket.autoApplyEnabled or nil)
end

function AlchemyRecipe:IsStationOpen()
    return GetAlchemyObject() ~= nil and IsAlchemySceneOpen()
end

function AlchemyRecipe:SetAutoApplyEnabled(enabled)
    local bucket = self:EnsureCharacterBucketForWrite()
    if type(bucket) ~= "table" then
        return false
    end

    bucket.autoApplyEnabled = NormalizeAutoApplyEnabled(enabled)
    return true
end

function AlchemyRecipe:GetActiveRecipeId()
    local bucket = self:GetCharacterBucketReadonly()
    return type(bucket) == "table" and bucket.activeRecipeId or nil
end

function AlchemyRecipe:SetActiveRecipe(recipeId)
    recipeId = NormalizeRecipeId(recipeId)
    local existingBucket = self:GetCharacterBucketReadonly()
    if type(existingBucket) ~= "table"
        or recipeId == nil
        or type(existingBucket.recipes[recipeId]) ~= "table" then
        return nil, "alchemy_recipe_not_found"
    end

    local bucket = self:EnsureCharacterBucketForWrite()
    if type(bucket) ~= "table" or type(bucket.recipes[recipeId]) ~= "table" then
        return nil, "alchemy_recipe_not_found"
    end

    bucket.activeRecipeId = recipeId
    return Util:DeepCopy(bucket.recipes[recipeId])
end

function AlchemyRecipe:RenameRecipe(recipeId, newName)
    recipeId = NormalizeRecipeId(recipeId)
    newName = Util:NormalizeDisplayName(newName)
    if recipeId == nil or newName == nil then
        return nil, "invalid_recipe_name"
    end

    local existingBucket = self:GetCharacterBucketReadonly()
    if type(existingBucket) ~= "table"
        or type(existingBucket.recipes) ~= "table"
        or type(existingBucket.recipes[recipeId]) ~= "table" then
        return nil, "alchemy_recipe_not_found"
    end

    local bucket = self:EnsureCharacterBucketForWrite()
    if type(bucket) ~= "table" or type(bucket.recipes[recipeId]) ~= "table" then
        return nil, "alchemy_recipe_not_found"
    end

    bucket.recipes[recipeId].name = newName
    bucket.recipes[recipeId].updatedAt = Util:GetTimestamp()
    return Util:DeepCopy(bucket.recipes[recipeId])
end

function AlchemyRecipe:SetRecipeCraftCount(recipeId, count)
    recipeId = NormalizeRecipeId(recipeId)
    count = math.max(math.floor(tonumber(count) or 1), 1)
    if recipeId == nil then
        return nil, "alchemy_recipe_not_found"
    end

    local existingBucket = self:GetCharacterBucketReadonly()
    if type(existingBucket) ~= "table"
        or type(existingBucket.recipes) ~= "table"
        or type(existingBucket.recipes[recipeId]) ~= "table" then
        return nil, "alchemy_recipe_not_found"
    end

    local bucket = self:EnsureCharacterBucketForWrite()
    if type(bucket) ~= "table" or type(bucket.recipes[recipeId]) ~= "table" then
        return nil, "alchemy_recipe_not_found"
    end

    bucket.recipes[recipeId].craftCount = count
    bucket.recipes[recipeId].updatedAt = Util:GetTimestamp()
    return Util:DeepCopy(bucket.recipes[recipeId])
end

function AlchemyRecipe:GetRecipeList()
    local bucket = self:GetCharacterBucketReadonly()
    local recipes = {}
    if type(bucket) ~= "table" or type(bucket.recipes) ~= "table" then
        return recipes
    end

    for _, recipeId in ipairs(bucket.recipeOrder or {}) do
        local recipe = bucket.recipes[recipeId]
        if type(recipe) == "table" then
            local copy = Util:DeepCopy(recipe)
            copy.isActive = bucket.activeRecipeId == recipeId
            recipes[#recipes + 1] = copy
        end
    end

    return recipes
end

function AlchemyRecipe:DeleteRecipe(recipeId)
    recipeId = NormalizeRecipeId(recipeId)
    local existingBucket = self:GetCharacterBucketReadonly()
    if type(existingBucket) ~= "table"
        or recipeId == nil
        or type(existingBucket.recipes[recipeId]) ~= "table" then
        return false, "alchemy_recipe_not_found"
    end

    local bucket = self:EnsureCharacterBucketForWrite()
    if type(bucket) ~= "table" or type(bucket.recipes[recipeId]) ~= "table" then
        return false, "alchemy_recipe_not_found"
    end

    bucket.recipes[recipeId] = nil
    RemoveFirstValue(bucket.recipeOrder, recipeId)
    if bucket.activeRecipeId == recipeId then
        bucket.activeRecipeId = nil
    end

    return true
end

function AlchemyRecipe:BuildInventoryIndex()
    return BuildCraftingInventoryIndex()
end

function AlchemyRecipe:GetRecipeInventoryState(recipeId, inventoryIndex)
    local recipe, err = GetRecipeById(self, recipeId)
    if type(recipe) ~= "table" then
        return nil, err or "recipe_not_found"
    end

    if type(inventoryIndex) ~= "table" or type(inventoryIndex.itemsByItemId) ~= "table" then
        inventoryIndex = BuildCraftingInventoryIndex()
    end

    local reagentItemIds = type(recipe.reagentItemIds) == "table" and recipe.reagentItemIds or {}
    local solventState = BuildInventoryItemState(recipe.solventItemId, inventoryIndex)
    local reagent1State = BuildInventoryItemState(reagentItemIds[1], inventoryIndex)
    local reagent2State = BuildInventoryItemState(reagentItemIds[2], inventoryIndex)
    local reagent3State = {
        itemId = reagentItemIds[3],
        found = false,
        bagId = nil,
        slotIndex = nil,
        stackCount = 0,
        totalStackCount = 0,
    }
    if IsValidItemId(reagentItemIds[3]) then
        reagent3State = BuildInventoryItemState(reagentItemIds[3], inventoryIndex)
    end

    return {
        solvent = solventState,
        reagents = {
            [1] = reagent1State,
            [2] = reagent2State,
            [3] = reagent3State,
        },
        allRequiredFound = solventState.found == true
            and reagent1State.found == true
            and reagent2State.found == true,
        thirdSlotUnlocked = IsThirdAlchemySlotUnlocked(),
    }
end

function AlchemyRecipe:RegisterStationEvents()
    if self.stationEventsRegistered == true then
        return false
    end
    if EVENT_MANAGER == nil or type(EVENT_MANAGER.RegisterForEvent) ~= "function" then
        return false
    end

    local stationInteractEvent = rawget(_G, "EVENT_CRAFTING_STATION_INTERACT")
    local stationEndEvent = rawget(_G, "EVENT_END_CRAFTING_STATION_INTERACT")
    if stationInteractEvent == nil or stationEndEvent == nil then
        return false
    end

    self.stationEventsRegistered = true
    EVENT_MANAGER:RegisterForEvent(STATION_INTERACT_EVENT_NAME, stationInteractEvent, function(_, craftingType)
        if craftingType == rawget(_G, "CRAFTING_TYPE_ALCHEMY") then
            AlchemyRecipe.isStationOpen = true
            if not RegisterAlchemySceneCallback() then
                ScheduleAlchemySceneCallbackRegistration()
            end
        end
    end)
    EVENT_MANAGER:RegisterForEvent(STATION_END_EVENT_NAME, stationEndEvent, function(_, craftingType)
        if craftingType == rawget(_G, "CRAFTING_TYPE_ALCHEMY") then
            AlchemyRecipe.isStationOpen = false
        end
    end)
    return true
end

function AlchemyRecipe:ApplyRecipeToStation(recipeId)
    local alchemy = GetAlchemyObject()
    if type(alchemy) ~= "table" then
        return false, "alchemy_unavailable"
    end
    if self:IsStationOpen() ~= true then
        return false, "station_not_open"
    end
    if type(alchemy.ClearSelections) ~= "function"
        or type(alchemy.SetSolventItem) ~= "function"
        or type(alchemy.SetReagentItem) ~= "function" then
        return false, "alchemy_methods_unavailable"
    end

    local recipe, recipeErr = GetRecipeById(self, recipeId)
    if type(recipe) ~= "table" then
        return false, recipeErr or "recipe_not_found"
    end

    local inventoryState, inventoryErr = self:GetRecipeInventoryState(recipe.id)
    if type(inventoryState) ~= "table" then
        return false, inventoryErr or "inventory_unavailable"
    end

    local missingReason = GetMissingRequiredInventoryReason(inventoryState)
    if missingReason ~= nil then
        return false, missingReason
    end

    local ok, err = CallAlchemyMethod(alchemy, "ClearSelections")
    if not ok then
        return false, err or "clear_selections_failed"
    end

    ok, err = CallAlchemyMethod(
        alchemy,
        "SetSolventItem",
        inventoryState.solvent.bagId,
        inventoryState.solvent.slotIndex
    )
    if not ok then
        return false, err or "set_solvent_failed"
    end

    ok, err = CallAlchemyMethod(
        alchemy,
        "SetReagentItem",
        1,
        inventoryState.reagents[1].bagId,
        inventoryState.reagents[1].slotIndex
    )
    if not ok then
        return false, err or "set_reagent1_failed"
    end

    ok, err = CallAlchemyMethod(
        alchemy,
        "SetReagentItem",
        2,
        inventoryState.reagents[2].bagId,
        inventoryState.reagents[2].slotIndex
    )
    if not ok then
        return false, err or "set_reagent2_failed"
    end

    local reagent3 = inventoryState.reagents[3]
    local useThirdReagent = inventoryState.thirdSlotUnlocked == true
        and type(reagent3) == "table"
        and reagent3.found == true
    if useThirdReagent then
        ok, err = CallAlchemyMethod(alchemy, "SetReagentItem", 3, reagent3.bagId, reagent3.slotIndex)
        if not ok then
            return false, err or "set_reagent3_failed"
        end
    end

    local craftCount = math.max(math.floor(tonumber(recipe.craftCount) or 1), 1)
    local spinnerOk, spinnerErr = ApplyCraftCountToAlchemySpinner(craftCount)
    if spinnerOk ~= true then
        Debug(
            "craftCountSpinner",
            "skipped=true",
            "recipeId=" .. tostring(recipe.id),
            "craftCount=" .. tostring(craftCount),
            "reason=" .. tostring(spinnerErr)
        )
    end

    return true, {
        recipeId = recipe.id,
        recipe = Util:DeepCopy(recipe),
        craftCount = craftCount,
        inventoryState = inventoryState,
        solventBag = inventoryState.solvent.bagId,
        solventSlot = inventoryState.solvent.slotIndex,
        r1Bag = inventoryState.reagents[1].bagId,
        r1Slot = inventoryState.reagents[1].slotIndex,
        r2Bag = inventoryState.reagents[2].bagId,
        r2Slot = inventoryState.reagents[2].slotIndex,
        r3Bag = useThirdReagent and reagent3.bagId or nil,
        r3Slot = useThirdReagent and reagent3.slotIndex or nil,
    }
end

function AlchemyRecipe:UpsertRecipeFromSlots(slots, name)
    if type(slots) ~= "table" then
        return nil, "invalid_slots"
    end

    local bucket = self:EnsureCharacterBucketForWrite()
    if type(bucket) ~= "table" then
        return nil, "saved_vars_unavailable"
    end

    local recipeId = self:GenerateRecipeId(bucket)
    if recipeId == nil then
        return nil, "recipe_id_unavailable"
    end

    local reagent1 = type(slots.reagents) == "table" and slots.reagents[1] or nil
    local reagent2 = type(slots.reagents) == "table" and slots.reagents[2] or nil
    local reagent3 = type(slots.reagents) == "table" and slots.reagents[3] or nil
    if type(reagent1) ~= "table"
        or type(reagent2) ~= "table"
        or not IsValidItemId(reagent1.itemId)
        or not IsValidItemId(reagent2.itemId) then
        return nil, "invalid_reagent_item"
    end

    local reagentItemIds = {
        reagent1.itemId,
        reagent2.itemId,
    }
    if type(reagent3) == "table" and IsValidItemId(reagent3.itemId) then
        reagentItemIds[#reagentItemIds + 1] = reagent3.itemId
    end

    local timestamp = Util:GetTimestamp()
    local recipe = {
        id = recipeId,
        name = Util:NormalizeDisplayName(name)
            or GetItemLinkDisplayName(slots.resultItemLink)
            or BuildDefaultRecipeName(recipeId),
        notes = "",
        solventItemId = slots.solventItemId,
        reagentItemIds = reagentItemIds,
        resultItemLink = slots.resultItemLink,
        craftCount = 1,
        createdAt = timestamp,
        updatedAt = timestamp,
    }

    bucket.recipes[recipeId] = recipe
    bucket.recipeOrder[#bucket.recipeOrder + 1] = recipeId
    if bucket.activeRecipeId == nil then
        bucket.activeRecipeId = recipeId
    end

    return Util:DeepCopy(recipe)
end

function AlchemyRecipe:CaptureFromStation(name)
    if self.isStationOpen ~= true then
        return nil, "station_not_open"
    end
    if type(rawget(_G, "ALCHEMY")) ~= "table" then
        return nil, "alchemy_unavailable"
    end

    local slots = ReadCurrentStationSlots()
    if type(slots) ~= "table" then
        return nil, "alchemy_unavailable"
    end

    if not HasBagSlot(slots.solventBag, slots.solventSlot) then
        return nil, "solvent_not_set"
    end
    if not IsValidItemId(slots.solventItemId) then
        return nil, "invalid_solvent_item"
    end

    local reagent1 = slots.reagents[1]
    local reagent2 = slots.reagents[2]
    if type(reagent1) ~= "table"
        or type(reagent2) ~= "table"
        or not HasBagSlot(reagent1.bag, reagent1.slot)
        or not HasBagSlot(reagent2.bag, reagent2.slot) then
        return nil, "reagents_insufficient"
    end
    if not IsValidItemId(reagent1.itemId) or not IsValidItemId(reagent2.itemId) then
        return nil, "invalid_reagent_item"
    end

    local reagent3 = slots.reagents[3]
    if type(reagent3) == "table" and HasBagSlot(reagent3.bag, reagent3.slot) and not IsValidItemId(reagent3.itemId) then
        return nil, "invalid_reagent_item"
    end

    slots.resultItemLink = GetResultingItemLink(slots)
    return self:UpsertRecipeFromSlots(slots, name)
end
