local Addon = LarvalTearMod
local ScribingRecipe = Addon.Modules.ScribingRecipe
local Log = Addon.Common.Log
local Util = Addon.Common.Util

local STATION_INTERACT_EVENT_NAME = "LTM_ScribingRecipe_StationInteract"
local STATION_END_EVENT_NAME = "LTM_ScribingRecipe_StationEnd"
local SCRIBING_SCENE_CALLBACK_UPDATE_NAME = "LTM_ScribingRecipe_ScribingSceneRetry"
local SCRIBING_SCENE_CALLBACK_RETRY_INTERVAL_MS = 1000
local SCRIBING_SCENE_CALLBACK_MAX_RETRY = 30

ScribingRecipe.isStationOpen = false

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
    if type(Log) == "table" and type(Log.Debug) == "function" then
        Log.Debug("[ScribingRecipe]", ...)
    end
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

local function NormalizePositiveId(value)
    value = tonumber(value)
    if value ~= nil and value > 0 then
        return math.floor(value)
    end
    return nil
end

local function NormalizeScriptId(value)
    return NormalizePositiveId(value) or 0
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

local function GetScribingObject()
    local scribing = rawget(_G, "SCRIBING_KEYBOARD")
    if type(scribing) == "table" then
        return scribing
    end

    if type(IsInGamepadPreferredMode) == "function" and IsInGamepadPreferredMode() == true then
        scribing = rawget(_G, "SCRIBING_GAMEPAD")
        return type(scribing) == "table" and scribing or nil
    end

    return nil
end

local function GetKeyboardScribingObject()
    local scribing = rawget(_G, "SCRIBING_KEYBOARD")
    return type(scribing) == "table" and scribing or nil
end

local function GetScribingScene()
    local scene = rawget(_G, "SCRIBING_SCENE_KEYBOARD")
    if scene ~= nil then
        return scene
    end
    return rawget(_G, "SCRIBING_SCENE_GAMEPAD")
end

local function GetSceneShowingState()
    return rawget(_G, "SCENE_SHOWING") or "showing"
end

local function IsSceneShowingState(newState)
    return newState == GetSceneShowingState()
end

local function IsScribingSceneOpen()
    local scene = GetScribingScene()
    if type(scene) ~= "table" then
        return ScribingRecipe.isStationOpen == true
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

    return ScribingRecipe.isStationOpen == true
end

local function IsScribingSceneReady()
    local scene = GetScribingScene()
    if type(scene) ~= "table" then
        return false
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

    return false
end

local function GetDataManager()
    local dataManager = rawget(_G, "SCRIBING_DATA_MANAGER")
    return type(dataManager) == "table" and dataManager or nil
end

local function GetCraftedAbilityData(craftedAbilityId)
    local dataManager = GetDataManager()
    if type(dataManager) ~= "table" or type(dataManager.GetCraftedAbilityData) ~= "function" then
        return nil
    end
    return Util:SafeCall(dataManager.GetCraftedAbilityData, dataManager, craftedAbilityId)
end

local function GetScriptData(scriptId)
    local dataManager = GetDataManager()
    if type(dataManager) ~= "table" or type(dataManager.GetCraftedAbilityScriptData) ~= "function" then
        return nil
    end
    return Util:SafeCall(dataManager.GetCraftedAbilityScriptData, dataManager, scriptId)
end

local function GetDataName(data)
    if type(data) ~= "table" then
        return nil
    end

    return Util:NormalizeDisplayName(Util:SafeCall(data.GetName, data))
        or Util:NormalizeDisplayName(Util:SafeCall(data.GetFormattedName, data))
        or Util:NormalizeDisplayName(Util:SafeCall(data.GetDisplayName, data))
end

local function GetDataIcon(data)
    if type(data) ~= "table" then
        return nil
    end

    local icon = Util:SafeCall(data.GetIcon, data) or Util:SafeCall(data.GetIconFile, data)
    return type(icon) == "string" and icon ~= "" and icon or nil
end

local function GetCraftedAbilityDisplayNameSafe(craftedAbilityId)
    if type(GetCraftedAbilityDisplayName) == "function" then
        local displayName = Util:SafeCall(GetCraftedAbilityDisplayName, craftedAbilityId)
        displayName = Util:NormalizeDisplayName(displayName)
        if displayName ~= nil then
            return displayName
        end
    end

    return GetDataName(GetCraftedAbilityData(craftedAbilityId))
end

local function GetCraftedAbilityIconSafe(craftedAbilityId)
    if type(GetCraftedAbilityIcon) == "function" then
        local icon = Util:SafeCall(GetCraftedAbilityIcon, craftedAbilityId)
        if type(icon) == "string" and icon ~= "" then
            return icon
        end
    end

    return GetDataIcon(GetCraftedAbilityData(craftedAbilityId))
end

local function GetScriptName(scriptId)
    return GetDataName(GetScriptData(scriptId))
end

local function GetScriptIcon(scriptId)
    return GetDataIcon(GetScriptData(scriptId))
end

local function GetCraftedAbilityLinkSafe(craftedAbilityId, primaryScriptId, secondaryScriptId, tertiaryScriptId)
    if type(ZO_LinkHandler_CreateChatLink) == "function" and type(GetCraftedAbilityLink) == "function" then
        local ok, link = pcall(
            ZO_LinkHandler_CreateChatLink,
            GetCraftedAbilityLink,
            craftedAbilityId,
            primaryScriptId,
            secondaryScriptId,
            tertiaryScriptId
        )
        if ok and type(link) == "string" and link ~= "" then
            return link
        end
    end

    if type(GetCraftedAbilityLink) == "function" then
        local link = Util:SafeCall(
            GetCraftedAbilityLink,
            craftedAbilityId,
            primaryScriptId,
            secondaryScriptId,
            tertiaryScriptId
        )
        if type(link) == "string" and link ~= "" then
            return link
        end
    end

    return nil
end

local function ReadCurrentStationSlots()
    local scribing = GetKeyboardScribingObject()
    if type(scribing) ~= "table" then
        return nil
    end
    if type(scribing.GetSlottedCraftedAbilityId) ~= "function"
        or type(scribing.GetSlottedScriptIds) ~= "function" then
        return nil
    end

    local craftedAbilityId = NormalizePositiveId(Util:SafeCall(scribing.GetSlottedCraftedAbilityId, scribing))
    if craftedAbilityId == nil then
        return nil
    end

    local ok, primaryScriptId, secondaryScriptId, tertiaryScriptId = pcall(scribing.GetSlottedScriptIds, scribing)
    if not ok then
        return nil
    end

    return {
        craftedAbilityId = craftedAbilityId,
        primaryScriptId = NormalizeScriptId(primaryScriptId),
        secondaryScriptId = NormalizeScriptId(secondaryScriptId),
        tertiaryScriptId = NormalizeScriptId(tertiaryScriptId),
    }
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

local function BuildRecipeCache(recipe)
    if type(recipe) ~= "table" then
        return nil
    end

    recipe.craftedAbilityName = GetCraftedAbilityDisplayNameSafe(recipe.craftedAbilityId)
    recipe.craftedAbilityIcon = GetCraftedAbilityIconSafe(recipe.craftedAbilityId)
    recipe.primaryScriptName = GetScriptName(recipe.primaryScriptId)
    recipe.secondaryScriptName = GetScriptName(recipe.secondaryScriptId)
    recipe.tertiaryScriptName = GetScriptName(recipe.tertiaryScriptId)
    recipe.primaryScriptIcon = GetScriptIcon(recipe.primaryScriptId)
    recipe.secondaryScriptIcon = GetScriptIcon(recipe.secondaryScriptId)
    recipe.tertiaryScriptIcon = GetScriptIcon(recipe.tertiaryScriptId)
    recipe.craftedAbilityLink = GetCraftedAbilityLinkSafe(
        recipe.craftedAbilityId,
        recipe.primaryScriptId,
        recipe.secondaryScriptId,
        recipe.tertiaryScriptId
    )
    return recipe
end

local function GetInkCount()
    local manager = rawget(_G, "ZO_Scribing_Manager")
    if type(manager) == "table" and type(manager.GetScribingInkAmount) == "function" then
        local count = Util:SafeCall(manager.GetScribingInkAmount, manager)
        if tonumber(count) ~= nil then
            return math.max(math.floor(tonumber(count)), 0)
        end
    end

    if type(GetScribingInkItemLink) == "function" and type(GetItemLinkInventoryCount) == "function" then
        local link = Util:SafeCall(GetScribingInkItemLink)
        if type(link) == "string" and link ~= "" then
            local count = Util:SafeCall(
                GetItemLinkInventoryCount,
                link,
                rawget(_G, "INVENTORY_COUNT_BAG_OPTION_BACKPACK_AND_BANK_AND_CRAFT_BAG")
            )
            if tonumber(count) ~= nil then
                return math.max(math.floor(tonumber(count)), 0)
            end
        end
    end

    return nil
end

local function GetInkCost(recipe)
    if type(recipe) ~= "table" or type(GetCostToScribeScripts) ~= "function" then
        return nil
    end

    local cost = Util:SafeCall(
        GetCostToScribeScripts,
        recipe.craftedAbilityId,
        recipe.primaryScriptId,
        recipe.secondaryScriptId,
        recipe.tertiaryScriptId
    )
    if tonumber(cost) ~= nil then
        return math.max(math.floor(tonumber(cost)), 0)
    end

    return nil
end

local function OnScribingSceneStateChange(_, newState)
    if not IsSceneShowingState(newState) then
        return
    end
    if ScribingRecipe:GetAutoApplyEnabled() ~= true then
        return
    end

    local recipeId = ScribingRecipe:GetActiveRecipeId()
    if recipeId == nil then
        return
    end

    local ok, result = ScribingRecipe:ApplyRecipeToStation(recipeId)
    if ok then
        Debug("autoApply", "succeeded=true", "recipeId=" .. tostring(recipeId))
    else
        Debug("autoApply", "succeeded=false", "recipeId=" .. tostring(recipeId), "reason=" .. tostring(result))
    end
end

local function RegisterScribingSceneCallback()
    if ScribingRecipe.scribingSceneCallbackRegistered == true then
        return false
    end

    local scene = GetScribingScene()
    if scene == nil or type(scene.RegisterCallback) ~= "function" then
        return false
    end

    ScribingRecipe.scribingSceneCallbackRegistered = true
    scene:RegisterCallback("StateChange", OnScribingSceneStateChange)
    return true
end

local function ScheduleScribingSceneCallbackRegistration()
    if ScribingRecipe.scribingSceneCallbackRegistered == true
        or ScribingRecipe.scribingSceneCallbackRetryScheduled == true then
        return false
    end
    if type(EVENT_MANAGER) ~= "table" or type(EVENT_MANAGER.RegisterForUpdate) ~= "function" then
        return false
    end

    ScribingRecipe.scribingSceneCallbackRetryScheduled = true
    local retryCount = 0
    EVENT_MANAGER:RegisterForUpdate(SCRIBING_SCENE_CALLBACK_UPDATE_NAME, SCRIBING_SCENE_CALLBACK_RETRY_INTERVAL_MS, function()
        retryCount = retryCount + 1

        if ScribingRecipe.scribingSceneCallbackRegistered == true then
            ScribingRecipe.scribingSceneCallbackRetryScheduled = false
            if type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
                EVENT_MANAGER:UnregisterForUpdate(SCRIBING_SCENE_CALLBACK_UPDATE_NAME)
            end
            return
        end
        if RegisterScribingSceneCallback() then
            ScribingRecipe.scribingSceneCallbackRetryScheduled = false
            if type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
                EVENT_MANAGER:UnregisterForUpdate(SCRIBING_SCENE_CALLBACK_UPDATE_NAME)
            end
            return
        end

        if retryCount >= SCRIBING_SCENE_CALLBACK_MAX_RETRY then
            ScribingRecipe.scribingSceneCallbackRetryScheduled = false
            if type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
                EVENT_MANAGER:UnregisterForUpdate(SCRIBING_SCENE_CALLBACK_UPDATE_NAME)
            end
            Debug("ScribingSceneCallback retry exhausted")
        end
    end)

    return true
end

function ScribingRecipe:Initialize(savedVars)
    self.savedVars = savedVars
    self:RegisterStationEvents()
    if not RegisterScribingSceneCallback() then
        ScheduleScribingSceneCallbackRegistration()
    end
end

function ScribingRecipe:EnsureSavedVarsShape(readOnly)
    if type(self.savedVars) ~= "table" then
        return nil
    end

    if type(self.savedVars.scribingRecipeByCharacter) ~= "table" then
        if readOnly then
            return nil
        end
        self.savedVars.scribingRecipeByCharacter = {}
    end

    return self.savedVars
end

function ScribingRecipe:BuildDefaultCharacterBucket(characterKey)
    return {
        recipes = {},
        recipeOrder = {},
        nextIndex = 1,
        activeRecipeId = nil,
        autoApplyEnabled = false,
        ownerCharacterId = characterKey,
    }
end

function ScribingRecipe:NormalizeRecipe(recipe)
    if type(recipe) ~= "table" then
        return nil
    end

    recipe.id = NormalizeRecipeId(recipe.id)
    recipe.name = Util:NormalizeDisplayName(recipe.name) or recipe.id or "Recipe"
    recipe.craftedAbilityId = NormalizePositiveId(recipe.craftedAbilityId)
    recipe.primaryScriptId = NormalizeScriptId(recipe.primaryScriptId)
    recipe.secondaryScriptId = NormalizeScriptId(recipe.secondaryScriptId)
    recipe.tertiaryScriptId = NormalizeScriptId(recipe.tertiaryScriptId)
    recipe.craftCount = nil
    return recipe
end

function ScribingRecipe:NormalizeCharacterBucket(bucket, characterKey)
    if type(bucket) ~= "table" then
        return nil
    end

    if type(bucket.recipes) ~= "table" then
        bucket.recipes = {}
    end
    for recipeId, recipe in pairs(bucket.recipes) do
        if type(recipeId) == "string" and type(recipe) == "table" then
            recipe.id = recipe.id or recipeId
            self:NormalizeRecipe(recipe)
        end
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

function ScribingRecipe:GetCharacterBucketReadonly()
    local savedVars = self:EnsureSavedVarsShape(true)
    if type(savedVars) ~= "table" or type(savedVars.scribingRecipeByCharacter) ~= "table" then
        return nil
    end

    local characterKey = NormalizeCharacterKey()
    if type(characterKey) ~= "string" or characterKey == "" then
        return nil
    end

    local bucket = savedVars.scribingRecipeByCharacter[characterKey]
    if type(bucket) ~= "table" then
        return nil
    end

    bucket = Util:DeepCopy(bucket)
    return self:NormalizeCharacterBucket(bucket, characterKey)
end

function ScribingRecipe:EnsureCharacterBucketForWrite()
    local savedVars = self:EnsureSavedVarsShape(false)
    if type(savedVars) ~= "table" then
        return nil
    end

    local characterKey = NormalizeCharacterKey()
    if type(characterKey) ~= "string" or characterKey == "" then
        return nil
    end

    local bucket = savedVars.scribingRecipeByCharacter[characterKey]
    if type(bucket) ~= "table" then
        bucket = self:BuildDefaultCharacterBucket(characterKey)
        savedVars.scribingRecipeByCharacter[characterKey] = bucket
    end

    return self:NormalizeCharacterBucket(bucket, characterKey)
end

function ScribingRecipe:GenerateRecipeId(bucket)
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

function ScribingRecipe:GetAutoApplyEnabled()
    local bucket = self:GetCharacterBucketReadonly()
    return NormalizeAutoApplyEnabled(type(bucket) == "table" and bucket.autoApplyEnabled or nil)
end

function ScribingRecipe:SetAutoApplyEnabled(enabled)
    local bucket = self:EnsureCharacterBucketForWrite()
    if type(bucket) ~= "table" then
        return false
    end

    bucket.autoApplyEnabled = NormalizeAutoApplyEnabled(enabled)
    return true
end

function ScribingRecipe:IsStationOpen()
    return GetScribingObject() ~= nil and IsScribingSceneOpen()
end

function ScribingRecipe:GetActiveRecipeId()
    local bucket = self:GetCharacterBucketReadonly()
    return type(bucket) == "table" and bucket.activeRecipeId or nil
end

function ScribingRecipe:SetActiveRecipe(recipeId)
    recipeId = NormalizeRecipeId(recipeId)
    local existingBucket = self:GetCharacterBucketReadonly()
    if type(existingBucket) ~= "table"
        or recipeId == nil
        or type(existingBucket.recipes[recipeId]) ~= "table" then
        return nil, "scribing_recipe_not_found"
    end

    local bucket = self:EnsureCharacterBucketForWrite()
    if type(bucket) ~= "table" or type(bucket.recipes[recipeId]) ~= "table" then
        return nil, "scribing_recipe_not_found"
    end

    bucket.activeRecipeId = recipeId
    return Util:DeepCopy(bucket.recipes[recipeId])
end

function ScribingRecipe:RenameRecipe(recipeId, newName)
    recipeId = NormalizeRecipeId(recipeId)
    newName = Util:NormalizeDisplayName(newName)
    if recipeId == nil or newName == nil then
        return nil, "invalid_recipe_name"
    end

    local existingBucket = self:GetCharacterBucketReadonly()
    if type(existingBucket) ~= "table"
        or type(existingBucket.recipes) ~= "table"
        or type(existingBucket.recipes[recipeId]) ~= "table" then
        return nil, "scribing_recipe_not_found"
    end

    local bucket = self:EnsureCharacterBucketForWrite()
    if type(bucket) ~= "table" or type(bucket.recipes[recipeId]) ~= "table" then
        return nil, "scribing_recipe_not_found"
    end

    bucket.recipes[recipeId].name = newName
    bucket.recipes[recipeId].updatedAt = Util:GetTimestamp()
    return Util:DeepCopy(bucket.recipes[recipeId])
end

function ScribingRecipe:GetRecipeList()
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

function ScribingRecipe:GetRecipe(recipeId)
    return GetRecipeById(self, recipeId)
end

function ScribingRecipe:DeleteRecipe(recipeId)
    recipeId = NormalizeRecipeId(recipeId)
    local existingBucket = self:GetCharacterBucketReadonly()
    if type(existingBucket) ~= "table"
        or recipeId == nil
        or type(existingBucket.recipes[recipeId]) ~= "table" then
        return false, "scribing_recipe_not_found"
    end

    local bucket = self:EnsureCharacterBucketForWrite()
    if type(bucket) ~= "table" or type(bucket.recipes[recipeId]) ~= "table" then
        return false, "scribing_recipe_not_found"
    end

    bucket.recipes[recipeId] = nil
    RemoveFirstValue(bucket.recipeOrder, recipeId)
    if bucket.activeRecipeId == recipeId then
        bucket.activeRecipeId = nil
    end

    return true
end

local function CreateValidationState(recipe, reason)
    local state = {
        ok = false,
        valid = false,
        reason = reason,
        recipeId = type(recipe) == "table" and recipe.id or nil,
        craftedAbilityId = type(recipe) == "table" and recipe.craftedAbilityId or nil,
        primaryScriptId = type(recipe) == "table" and recipe.primaryScriptId or nil,
        secondaryScriptId = type(recipe) == "table" and recipe.secondaryScriptId or nil,
        tertiaryScriptId = type(recipe) == "table" and recipe.tertiaryScriptId or nil,
        isScribingUnlocked = false,
        craftedAbilityUnlocked = false,
        craftedAbilityDisabled = false,
        primaryScriptUnlocked = false,
        secondaryScriptUnlocked = false,
        tertiaryScriptUnlocked = false,
        primaryScriptDisabled = false,
        secondaryScriptDisabled = false,
        tertiaryScriptDisabled = false,
        combinationValid = false,
        alreadyActive = false,
        inkCost = nil,
        inkCount = nil,
        canAffordInk = nil,
    }
    return state
end

local function ValidateRecipeForUse(recipe, initialReason)
    local state = CreateValidationState(recipe, initialReason)
    if initialReason ~= nil or type(recipe) ~= "table" then
        return state
    end

    local dataManager = GetDataManager()
    if dataManager == nil then
        state.reason = "scribing_data_manager_unavailable"
        return state
    end
    if type(dataManager.IsScribingUnlocked) == "function" then
        state.isScribingUnlocked = Util:SafeCall(dataManager.IsScribingUnlocked, dataManager) == true
        if state.isScribingUnlocked ~= true then
            state.reason = "scribing_unavailable"
            return state
        end
    else
        state.isScribingUnlocked = true
    end

    if recipe.craftedAbilityId == nil then
        state.reason = "crafted_ability_not_found"
        return state
    end
    if recipe.primaryScriptId == 0 or recipe.secondaryScriptId == 0 or recipe.tertiaryScriptId == 0 then
        state.reason = "scripts_insufficient"
        return state
    end

    local craftedAbilityData = GetCraftedAbilityData(recipe.craftedAbilityId)
    if type(craftedAbilityData) ~= "table" then
        state.reason = "crafted_ability_not_found"
        return state
    end

    local abilityUnlocked = Util:SafeCall(IsCraftedAbilityUnlocked, recipe.craftedAbilityId)
    if abilityUnlocked == nil and type(craftedAbilityData.IsUnlocked) == "function" then
        abilityUnlocked = Util:SafeCall(craftedAbilityData.IsUnlocked, craftedAbilityData)
    end
    state.craftedAbilityUnlocked = abilityUnlocked == true
    if state.craftedAbilityUnlocked ~= true then
        state.reason = "crafted_ability_locked"
        return state
    end

    local abilityDisabled = Util:SafeCall(IsCraftedAbilityDisabled, recipe.craftedAbilityId)
    if abilityDisabled == nil and type(craftedAbilityData.IsDisabled) == "function" then
        abilityDisabled = Util:SafeCall(craftedAbilityData.IsDisabled, craftedAbilityData)
    end
    state.craftedAbilityDisabled = abilityDisabled == true
    if state.craftedAbilityDisabled == true then
        state.reason = "crafted_ability_disabled"
        return state
    end

    local scriptChecks = {
        { key = "primary", id = recipe.primaryScriptId, unlockedField = "primaryScriptUnlocked", disabledField = "primaryScriptDisabled" },
        { key = "secondary", id = recipe.secondaryScriptId, unlockedField = "secondaryScriptUnlocked", disabledField = "secondaryScriptDisabled" },
        { key = "tertiary", id = recipe.tertiaryScriptId, unlockedField = "tertiaryScriptUnlocked", disabledField = "tertiaryScriptDisabled" },
    }
    state.scripts = {}
    for _, scriptCheck in ipairs(scriptChecks) do
        local scriptData = GetScriptData(scriptCheck.id)
        if type(scriptData) ~= "table" then
            state.reason = scriptCheck.key .. "_script_not_found"
            return state
        end

        local unlocked = Util:SafeCall(IsCraftedAbilityScriptUnlocked, scriptCheck.id)
        if unlocked == nil and type(scriptData.IsUnlocked) == "function" then
            unlocked = Util:SafeCall(scriptData.IsUnlocked, scriptData)
        end
        local disabled = Util:SafeCall(IsCraftedAbilityScriptDisabled, scriptCheck.id)
        if disabled == nil and type(scriptData.IsDisabled) == "function" then
            disabled = Util:SafeCall(scriptData.IsDisabled, scriptData)
        end

        state.scripts[scriptCheck.key] = {
            id = scriptCheck.id,
            unlocked = unlocked == true,
            disabled = disabled == true,
        }
        state[scriptCheck.unlockedField] = unlocked == true
        state[scriptCheck.disabledField] = disabled == true
        if unlocked ~= true then
            state.reason = scriptCheck.key .. "_script_locked"
            return state
        end
        if disabled == true then
            state.reason = scriptCheck.key .. "_script_disabled"
            return state
        end
    end

    local combinationValid = Util:SafeCall(
        IsScribableScriptCombinationForCraftedAbility,
        recipe.craftedAbilityId,
        recipe.primaryScriptId,
        recipe.secondaryScriptId,
        recipe.tertiaryScriptId
    )
    state.combinationValid = combinationValid == true
    if state.combinationValid ~= true then
        state.reason = "script_combination_invalid"
        return state
    end

    local alreadyActive = false
    if type(craftedAbilityData.AreScriptIdsActive) == "function" then
        alreadyActive = Util:SafeCall(
            craftedAbilityData.AreScriptIdsActive,
            craftedAbilityData,
            recipe.primaryScriptId,
            recipe.secondaryScriptId,
            recipe.tertiaryScriptId
        ) == true
    elseif type(GetCraftedAbilityActiveScriptIds) == "function" then
        local ok, activePrimary, activeSecondary, activeTertiary = pcall(GetCraftedAbilityActiveScriptIds, recipe.craftedAbilityId)
        alreadyActive = ok
            and activePrimary == recipe.primaryScriptId
            and activeSecondary == recipe.secondaryScriptId
            and activeTertiary == recipe.tertiaryScriptId
    end
    state.alreadyActive = alreadyActive
    if alreadyActive == true then
        state.reason = "already_active"
        return state
    end

    state.inkCost = GetInkCost(recipe)
    state.inkCount = GetInkCount()
    if state.inkCost ~= nil and state.inkCount ~= nil then
        state.canAffordInk = state.inkCount >= state.inkCost
    end
    if state.inkCost ~= nil and state.inkCount ~= nil and state.inkCount < state.inkCost then
        state.reason = "ink_insufficient"
        return state
    end

    state.ok = true
    state.valid = true
    state.reason = nil
    return state
end

function ScribingRecipe:GetRecipeValidationState(recipeId)
    local recipe, err = GetRecipeById(self, recipeId)
    if type(recipe) ~= "table" then
        return CreateValidationState(nil, err or "recipe_not_found")
    end

    return ValidateRecipeForUse(recipe)
end

function ScribingRecipe:RegisterStationEvents()
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
        if craftingType == rawget(_G, "CRAFTING_TYPE_SCRIBING") then
            ScribingRecipe.isStationOpen = true
            if not RegisterScribingSceneCallback() then
                ScheduleScribingSceneCallbackRegistration()
            end
        end
    end)
    EVENT_MANAGER:RegisterForEvent(STATION_END_EVENT_NAME, stationEndEvent, function(_, craftingType)
        if craftingType == rawget(_G, "CRAFTING_TYPE_SCRIBING") then
            ScribingRecipe.isStationOpen = false
        end
    end)
    return true
end

function ScribingRecipe:ApplyRecipeToStation(recipeId)
    local scribing = GetKeyboardScribingObject()
    if type(scribing) ~= "table" then
        return false, "scribing_unavailable"
    end
    if self.isStationOpen ~= true then
        return false, "station_not_open"
    end
    if IsScribingSceneReady() ~= true then
        return false, "scene_not_ready"
    end
    if type(scribing.SetupRecentCraftedAbilityToCraft) ~= "function" then
        return false, "scribing_methods_unavailable"
    end

    local recipe, recipeErr = GetRecipeById(self, recipeId)
    if type(recipe) ~= "table" then
        return false, recipeErr or "recipe_not_found"
    end

    local validationState = self:GetRecipeValidationState(recipe.id)
    if type(validationState) ~= "table" or validationState.ok ~= true then
        return false, type(validationState) == "table" and validationState.reason or "validation_failed"
    end

    local ok, err = pcall(
        scribing.SetupRecentCraftedAbilityToCraft,
        scribing,
        recipe.craftedAbilityId,
        recipe.primaryScriptId,
        recipe.secondaryScriptId,
        recipe.tertiaryScriptId
    )
    if not ok then
        return false, err or "setup_scribing_recipe_failed"
    end

    return true, {
        recipeId = recipe.id,
        recipe = Util:DeepCopy(recipe),
        validationState = validationState,
    }
end

function ScribingRecipe:CreateRecipeFromIds(name, craftedAbilityId, primaryScriptId, secondaryScriptId, tertiaryScriptId)
    local slots = {
        craftedAbilityId = NormalizePositiveId(craftedAbilityId),
        primaryScriptId = NormalizeScriptId(primaryScriptId),
        secondaryScriptId = NormalizeScriptId(secondaryScriptId),
        tertiaryScriptId = NormalizeScriptId(tertiaryScriptId),
    }
    if slots.craftedAbilityId == nil then
        return nil, "crafted_ability_not_set"
    end
    if slots.primaryScriptId == 0 or slots.secondaryScriptId == 0 or slots.tertiaryScriptId == 0 then
        return nil, "active_scripts_insufficient"
    end

    local validationState = ValidateRecipeForUse(slots)
    if type(validationState) ~= "table" then
        return nil, "validation_failed"
    end
    if validationState.ok ~= true
        and validationState.reason ~= "already_active"
        and validationState.reason ~= "ink_insufficient" then
        return nil, validationState.reason or "validation_failed", validationState
    end

    return self:UpsertRecipeFromSlots(slots, name)
end

function ScribingRecipe:UpsertRecipeFromSlots(slots, name)
    if type(slots) ~= "table" then
        return nil, "invalid_slots"
    end
    if not NormalizePositiveId(slots.craftedAbilityId) then
        return nil, "crafted_ability_not_set"
    end
    if NormalizeScriptId(slots.primaryScriptId) == 0
        or NormalizeScriptId(slots.secondaryScriptId) == 0
        or NormalizeScriptId(slots.tertiaryScriptId) == 0 then
        return nil, "scripts_insufficient"
    end

    local bucket = self:EnsureCharacterBucketForWrite()
    if type(bucket) ~= "table" then
        return nil, "saved_vars_unavailable"
    end

    local recipeId = self:GenerateRecipeId(bucket)
    if recipeId == nil then
        return nil, "recipe_id_unavailable"
    end

    local craftedAbilityId = NormalizePositiveId(slots.craftedAbilityId)
    local primaryScriptId = NormalizeScriptId(slots.primaryScriptId)
    local secondaryScriptId = NormalizeScriptId(slots.secondaryScriptId)
    local tertiaryScriptId = NormalizeScriptId(slots.tertiaryScriptId)
    local timestamp = Util:GetTimestamp()
    local recipe = BuildRecipeCache({
        id = recipeId,
        name = Util:NormalizeDisplayName(name)
            or GetCraftedAbilityDisplayNameSafe(craftedAbilityId)
            or BuildDefaultRecipeName(recipeId),
        notes = "",
        craftedAbilityId = craftedAbilityId,
        primaryScriptId = primaryScriptId,
        secondaryScriptId = secondaryScriptId,
        tertiaryScriptId = tertiaryScriptId,
        createdAt = timestamp,
        updatedAt = timestamp,
    })

    bucket.recipes[recipeId] = recipe
    bucket.recipeOrder[#bucket.recipeOrder + 1] = recipeId
    if bucket.activeRecipeId == nil then
        bucket.activeRecipeId = recipeId
    end

    return Util:DeepCopy(recipe)
end

function ScribingRecipe:CaptureFromStation(name)
    if self.isStationOpen ~= true then
        return nil, "station_not_open"
    end
    if GetKeyboardScribingObject() == nil then
        return nil, "scribing_unavailable"
    end

    local slots = ReadCurrentStationSlots()
    if type(slots) ~= "table" then
        return nil, "scribing_selection_unavailable"
    end
    if slots.craftedAbilityId == nil then
        return nil, "crafted_ability_not_set"
    end
    if slots.primaryScriptId == 0 or slots.secondaryScriptId == 0 or slots.tertiaryScriptId == 0 then
        return nil, "scripts_insufficient"
    end

    return self:UpsertRecipeFromSlots(slots, name)
end
