KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.Fashion = KyzderpsDerps.Fashion or {}
local Fashion = KyzderpsDerps.Fashion

---------------------------------------------------------------------------------------------------
local curseTypes = {
    [CURSE_TYPE_NONE] = "CURSE_TYPE_NONE",
    [CURSE_TYPE_VAMPIRE] = "CURSE_TYPE_VAMPIRE",
    [CURSE_TYPE_WEREWOLF] = "CURSE_TYPE_WEREWOLF",
}

local isVampire = false


---------------------------------------------------------------------------------------------------
-- Skin over vampire armory preset
---------------------------------------------------------------------------------------------------
local function EquipVampSkin()
    local currentId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_SKIN)

    -- Only equip a skin if there is no skin active
    if (currentId ~= 0) then return end

    KyzderpsDerps:msg(string.format("Equipping |H1:collectible:%d|h|h to cover up your pale skin", KyzderpsDerps.savedOptions.fashion.vampSkinId)) -- 5108
    zo_callLater(function()
        UseCollectible(KyzderpsDerps.savedOptions.fashion.vampSkinId)
    end, 1000)
end

local function RestoreNonVampSkin()
    local currentId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_SKIN)
    if (currentId ~= KyzderpsDerps.savedOptions.fashion.vampSkinId and KyzderpsDerps.savedOptions.fashion.restoreAfterVampSameOnly) then
        KyzderpsDerps:msg(string.format("Keeping current skin because it is different from the anti-vamp skin"))
        return
    end

    if (currentId ~= 0) then
        -- No skin
        KyzderpsDerps:msg(string.format("Restoring to no skin because you are no longer a vampire"))
        zo_callLater(function()
            UseCollectible(currentId)
        end, 1000)
    end
end

---------------------------------------------------------------------------------------------------
-- * EVENT_ARMORY_BUILD_RESTORE_RESPONSE (*[ArmoryBuildRestoreResult|#ArmoryBuildRestoreResult]* _result_, *luaindex* _buildIndex_)
local function OnBuildLoaded(_, result)
    if (result ~= ARMORY_BUILD_RESTORE_RESULT_SUCCESS) then return end

    local curseType = GetPlayerCurseType()

    if (not isVampire and curseType == CURSE_TYPE_VAMPIRE) then
        -- Turning into a vampire
        isVampire = true
        if (KyzderpsDerps.savedOptions.fashion.equipSkinForVamp) then
            EquipVampSkin()
        end
    elseif (isVampire and curseType ~= CURSE_TYPE_VAMPIRE) then
        -- No longer a vampire
        isVampire = false
        if (KyzderpsDerps.savedOptions.fashion.equipSkinForVamp and KyzderpsDerps.savedOptions.fashion.restoreAfterVamp) then
            RestoreNonVampSkin()
        end
    end
end


---------------------------------------------------------------------------------------------------
-- Auto equip/unequip tabard
---------------------------------------------------------------------------------------------------
local prevCostumeId = 0

local function OnCollectibleUpdated(_, collectibleId)
    if (GetCollectibleCategoryType(collectibleId) ~= COLLECTIBLE_CATEGORY_TYPE_COSTUME) then
        return
    end
    local currCostumeId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COSTUME)

    if (prevCostumeId ~= currCostumeId) then
        prevCostumeId = currCostumeId

        if (not KyzderpsDerps.savedOptions.fashion.autoTabard) then return end

        if (currCostumeId == 0) then
            -- Unequip tabard
            if (not GetItemInstanceId(BAG_WORN, EQUIP_SLOT_COSTUME)) then return end
            local link = GetItemLink(BAG_WORN, EQUIP_SLOT_COSTUME, LINK_STYLE_BRACKETS)
            if (GetNumBagFreeSlots(BAG_BACKPACK) == 0) then
                KyzderpsDerps:msg(string.format("Could not unequip %s because you have no space in your backpack.", link))
            else
                KyzderpsDerps:msg(string.format("Unequipping %s.", link))
                RequestUnequipItem(BAG_WORN, EQUIP_SLOT_COSTUME)
            end
        else
            -- Find and equip tabard
            if (GetItemInstanceId(BAG_WORN, EQUIP_SLOT_COSTUME)) then return end
            local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)
            for _, item in pairs(bagCache) do
                if (GetItemEquipType(item.bagId, item.slotIndex) == EQUIP_TYPE_COSTUME) then
                    local itemLink = GetItemLink(item.bagId, item.slotIndex, LINK_STYLE_BRACKETS)
                    local itemType, specializedType = GetItemLinkItemType(itemLink)
                    if (itemType == ITEMTYPE_TABARD and specializedType == SPECIALIZED_ITEMTYPE_TABARD) then
                        KyzderpsDerps:msg(string.format("Equipping %s, which will override your currently equipped Guild Nameplate.", itemLink))
                        RequestEquipItem(BAG_BACKPACK, item.slotIndex, BAG_WORN, EQUIP_SLOT_COSTUME)
                        return
                    end
                end
            end
            KyzderpsDerps:msg("No tabard to equip.")
        end
    end
end


---------------------------------------------------------------------------------------------------
-- Skill Styles
---------------------------------------------------------------------------------------------------
local function EquipAllSkillStyles()
    for skillType = 1, GetNumSkillTypes() do
        for skillLineIndex = 1, GetNumSkillLines(skillType) do
            -- The current class' 3 lines is always returned first, so skip the rest
            if (skillType == SKILL_TYPE_CLASS and skillLineIndex > 3) then break end

            for skillIndex = 1, GetNumSkillAbilities(skillType, skillLineIndex) do
                local progressionId = GetProgressionSkillProgressionId(skillType, skillLineIndex, skillIndex)
                local numStyles = GetNumProgressionSkillAbilityFxOverrides(progressionId)

                local _, _, _, _, _, _, progressionIndex = GetSkillAbilityInfo(skillType, skillLineIndex, skillIndex)
                local skillUnlocked = progressionIndex ~= nil

                if (numStyles > 0) then
                    local name = GetSkillAbilityInfo(skillType, skillLineIndex, skillIndex)
                    d(zo_strformat("<<1>>-<<2>> <<3>> (progId <<5>>) has <<4>> styles", skillLineIndex, skillIndex, name, numStyles, progressionId))

                    if (not skillUnlocked) then
                        d("...|cFF0000BUT THE SKILL IS NOT UNLOCKED AAAAAAAAAAAA|r")
                    end

                    -- Find the newest(?) unlocked one, while printing out all and checking for current active
                    local newestUnlocked
                    for i = 1, numStyles do
                        local fxIndex = numStyles + 1 - i -- Go backwards
                        local collectibleId = GetProgressionSkillAbilityFxOverrideCollectibleIdByIndex(progressionId, fxIndex)
                        if (IsCollectibleUnlocked(collectibleId)) then
                            if (not newestUnlocked) then
                                newestUnlocked = collectibleId
                            end

                            -- Don't override a style if one is already set
                            if (IsCollectibleActive(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)) then
                                d(zo_strformat("...|c00FF00<<1>> (<<2>>)|r", GetCollectibleName(collectibleId), collectibleId))
                            else
                                local applying = newestUnlocked == collectibleId and skillUnlocked
                                d(zo_strformat("...|cFF9900<<1>> (<<2>>)<<3>>|r",
                                    GetCollectibleName(collectibleId),
                                    collectibleId,
                                    applying and " |c00FF00- applying!" or ""))
                            end
                        else
                            d(zo_strformat("...|cFF0000<<1>> (<<2>>)|r", GetCollectibleName(collectibleId), collectibleId))
                        end
                    end

                    -- Apply the newest unlocked if there isn't already one
                    if (skillUnlocked and newestUnlocked ~= nil and not IsCollectibleActive(newestUnlocked, GAMEPLAY_ACTOR_CATEGORY_PLAYER)) then
                        UseCollectible(newestUnlocked, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
                    end
                end
            end
        end
    end
end

--[[
A map of abilityId to the collectible IDs, but only if the skill is unlocked and the collectibles are unlocked
{
    abilityId = {
        available = {0, 139213, 345435}, -- Treat 0 as no style applied
        active = 1, -- The index, 1, 2...
    }
}
]]
local skillStyleTable = {}

local function BuildSkillStyleTable()
    d("building skill style table")
    for skillType = 1, GetNumSkillTypes() do
        for skillLineIndex = 1, GetNumSkillLines(skillType) do
            -- The current class' 3 lines is always returned first, so skip the rest
            if (skillType == SKILL_TYPE_CLASS and skillLineIndex > 3) then break end

            for skillIndex = 1, GetNumSkillAbilities(skillType, skillLineIndex) do
                local progressionId = GetProgressionSkillProgressionId(skillType, skillLineIndex, skillIndex)
                local numStyles = GetNumProgressionSkillAbilityFxOverrides(progressionId)

                -- Make sure the skill is unlocked
                local _, _, _, _, _, _, progressionIndex = GetSkillAbilityInfo(skillType, skillLineIndex, skillIndex)

                if (progressionIndex ~= nil and numStyles > 0) then
                    -- Collect list of unlocked styles
                    local unlockedStyles = {0}
                    local activeStyle = 0
                    for fxIndex = 1, numStyles do
                        local collectibleId = GetProgressionSkillAbilityFxOverrideCollectibleIdByIndex(progressionId, fxIndex)
                        if (IsCollectibleUnlocked(collectibleId)) then
                            table.insert(unlockedStyles, collectibleId)

                            if (IsCollectibleActive(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)) then
                                activeStyle = fxIndex
                            end
                        end
                    end

                    -- Only add it to the table if there are styles unlocked, obv
                    if (#unlockedStyles > 1) then
                        local morph = GetProgressionSkillCurrentMorphSlot(progressionId)
                        local abilityId = GetProgressionSkillMorphSlotAbilityId(progressionId, morph)
                        skillStyleTable[abilityId] = {
                            available = unlockedStyles,
                            active = activeStyle,
                        }
                    end
                end
            end
        end
    end
end

local function GetSlotTrueBoundId(index, hotbarCategory)
    local id = GetSlotBoundId(index, hotbarCategory)
    local actionType = GetSlotType(index, hotbarCategory)
    if actionType == ACTION_TYPE_CRAFTED_ABILITY then
        id = GetAbilityIdForCraftedAbilityId(id)
    end
    return id
end

local pauseCycle = {}
local function TryUseCollectible(abilityId, collectibleId)
    pauseCycle[abilityId] = true
    UseCollectible(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "AwaitCollectibleResult" .. tostring(abilityId), EVENT_COLLECTIBLE_USE_RESULT, function(_, result)
        EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "AwaitCollectibleResult" .. tostring(abilityId), EVENT_COLLECTIBLE_USE_RESULT)
        if (result == COLLECTIBLE_USAGE_BLOCK_REASON_ON_COOLDOWN) then
            zo_callLater(function() TryUseCollectible(abilityId, collectibleId) end, 50)
        elseif (result == COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED) then
            pauseCycle[abilityId] = false
            d("successfully used " .. tostring(collectibleId) .. " " .. GetCollectibleName(collectibleId))
        end
    end)
end

local function OnSkillUsed(_, slotIndex)
    local abilityId = GetSlotTrueBoundId(slotIndex, GetActiveHotbarCategory())
    local data = skillStyleTable[abilityId]
    if (not data) then return end

    -- Don't try to cycle if it's currently already trying to set it
    if (pauseCycle[abilityId] == true) then return end

    -- Increment, wrapping around if needed
    local active = data.active + 1
    if (active >= #data.available) then
        active = 0
    end
    data.active = active

    -- Find the ID
    local collectibleId = data.available[active + 1]
    -- Deactivate the last one
    if (collectibleId == 0) then
        collectibleId = data.available[#data.available]
    end

    zo_callLater(function() TryUseCollectible(abilityId, collectibleId) end, 500)
end

local function CycleSkillStyles()
    BuildSkillStyleTable()
    d(skillStyleTable)

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "StyleCycle", EVENT_ACTION_SLOT_ABILITY_USED, OnSkillUsed)
end
KyzderpsDerps.CycleSkillStyles = CycleSkillStyles -- /script KyzderpsDerps.CycleSkillStyles()


---------------------------------------------------------------------------------------------------
-- Recalling
---------------------------------------------------------------------------------------------------
-- 1 ~ num
local function GetRandomNumber(num)
    return math.floor(math.random() * num + 1)
end

local recallTries = 0
local function TryEquipRecall(collectibleToUse, isDefault)
     if (isDefault) then
        KyzderpsDerps:dbg("Trying to equip default recall style")
    else
        KyzderpsDerps:dbg(string.format("Trying to equip |H1:collectible:%d|h|h", collectibleToUse))
    end

    UseCollectible(collectibleToUse)

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "AwaitCollectibleResult" .. tostring(collectibleToUse), EVENT_COLLECTIBLE_USE_RESULT, function(_, result)
        EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "AwaitCollectibleResult" .. tostring(collectibleToUse), EVENT_COLLECTIBLE_USE_RESULT)
        if (result == COLLECTIBLE_USAGE_BLOCK_REASON_ON_COOLDOWN) then
            if (recallTries > 5) then
                KyzderpsDerps:msg("Couldn't equip recall style after several retries; collectibles on cooldown?")
                return
            end
            recallTries = recallTries + 1
            zo_callLater(function() TryEquipRecall(collectibleToUse, isDefault) end, 2000)
        elseif (result == COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED) then
            if (isDefault) then
                KyzderpsDerps:msg("Equipped default recall style")
            else
                KyzderpsDerps:msg(string.format("Equipped |H1:collectible:%d|h|h", collectibleToUse))
            end
        end
    end)
end

local function CycleRecall()
    local mode = KyzderpsDerps.savedOptions.fashion.changeRecallStyle
    if (mode == "Do nothing") then return end

    -- Collect the available collectibles
    local available = {}
    local currentId = 0
    local currentIndex = 0
    for i = 1, GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE) do
        local collectibleId = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE, i)
        if (GetCollectiblePlayerFxOverrideAbilityType(collectibleId) == PLAYER_FX_OVERRIDE_ABILITY_TYPE_WAYSHRINE
            and IsCollectibleUnlocked(collectibleId)) then
            if (IsCollectibleActive(collectibleId)) then
                currentId = collectibleId
                -- If randomizing, we pick from ones other than the current, but still include
                -- the ID in the available table, because using it will go to default style
                if (KyzderpsDerps.savedOptions.fashion.recallIncludeDefault) then
                    isCurrentIncluded = true
                    table.insert(available, collectibleId)
                    currentIndex = #available
                end
            else
                table.insert(available, collectibleId)
            end
        end
    end

    if (#available == 0) then
        -- d(available)
        KyzderpsDerps:dbg("No recall styles available")
        return
    end

    -- Randomize or cycle
    local newIndex
    if (mode == "Randomize") then
        newIndex = GetRandomNumber(#available)
    else -- Cycle; if none equipped then it starts over at the beginning
        newIndex = currentIndex + 1
        if (newIndex > #available) then
            -- If at the end of the list, then the next one is either use the last one to deactivate...
            if (KyzderpsDerps.savedOptions.fashion.recallIncludeDefault) then
                newIndex = currentIndex
            else -- ... or start over
                newIndex = 1
            end
        end
    end

    local collectibleToUse = available[newIndex]
    recallTries = 0
    TryEquipRecall(collectibleToUse, currentId == collectibleToUse)
end
KyzderpsDerps.CycleRecall = CycleRecall -- /script KyzderpsDerps.CycleRecall()

---------------------------------------------------------------------------------------------------
-- Initialize
---------------------------------------------------------------------------------------------------
function Fashion.Initialize()
    KyzderpsDerps:dbg("    Initializing Fashion module...")

    SLASH_COMMANDS["/applyskillstyles"] = EquipAllSkillStyles

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "FashionArmoryRestore", EVENT_ARMORY_BUILD_RESTORE_RESPONSE, OnBuildLoaded)
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "FashionCostumeUpdate", EVENT_COLLECTIBLE_UPDATED, OnCollectibleUpdated)

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "FashionRecallStyle", EVENT_PLAYER_ACTIVATED, function() zo_callLater(CycleRecall, 2000) end)

    isVampire = (GetPlayerCurseType() == CURSE_TYPE_VAMPIRE)

    prevCostumeId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COSTUME)

    Fashion.InitializeTrampleMount()
end


---------------------------------------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------------------------------------
local skinIds = {}
local skinNames = {}
local function BuildAvailableSkins()
    table.insert(skinIds, 0)
    table.insert(skinNames, "No Skin")

    for index = 1, GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_SKIN) do
        local collectibleId = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_SKIN, index)
        if (IsCollectibleUnlocked(collectibleId)) then
            table.insert(skinIds, collectibleId)
            table.insert(skinNames, GetCollectibleName(collectibleId))
        end
    end
end

function Fashion.GetSettings()
    BuildAvailableSkins()

    local settings = {
        {
            type = "checkbox",
            name = "Equip skin for vampire",
            tooltip = "Equip a specific skin when you become a vampire through armory loadout, but only if you did not have a skin previously equipped",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.fashion.equipSkinForVamp end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.fashion.equipSkinForVamp = value
            end,
            width = "full",
        },
        {
            type = "dropdown",
            name = "    Skin to equip",
            tooltip = "Specify which skin to equip",
            choices = skinNames,
            choicesValues = skinIds,
            getFunc = function() return KyzderpsDerps.savedOptions.fashion.vampSkinId end,
            setFunc = function(id)
                KyzderpsDerps:dbg("selected " .. tostring(id))
                KyzderpsDerps.savedOptions.fashion.vampSkinId = id
            end,
            width = "full",
            disabled = function() return not KyzderpsDerps.savedOptions.fashion.equipSkinForVamp end
        },
        {
            type = "checkbox",
            name = "Restore no skin after vampire",
            tooltip = "Remove skin after you are cured of vampirism through an armory loadout",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.fashion.restoreAfterVamp end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.fashion.restoreAfterVamp = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "    Only restore if \"vampire skin\" is equipped",
            tooltip = "Only remove skin if your currently equipped skin matches the specified skin above",
            default = true,
            getFunc = function() return KyzderpsDerps.savedOptions.fashion.restoreAfterVampSameOnly end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.fashion.restoreAfterVampSameOnly = value
            end,
            width = "full",
            disabled = function() return not KyzderpsDerps.savedOptions.fashion.restoreAfterVamp end
        },
        {
            type = "checkbox",
            name = "Costume tabard / outfit none",
            tooltip = "Equip guild tabard when you equip a costume, and unequip guild tabard when you have no costume. WTB invisible tabards",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.fashion.autoTabard end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.fashion.autoTabard = value
            end,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Change recall style on loadscreen",
            tooltip = "Upon every player activation (aka usually loadscreens), change your equipped recall style. \"Randomize\" picks a style other than your current one.",
            choices = {"Do nothing", "Randomize", "Cycle"},
            choicesValues = {"Do nothing", "Randomize", "Cycle"},
            getFunc = function() return KyzderpsDerps.savedOptions.fashion.changeRecallStyle end,
            setFunc = function(choice)
                KyzderpsDerps.savedOptions.fashion.changeRecallStyle = choice
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "    Include default style",
            tooltip = "",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.fashion.recallIncludeDefault end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.fashion.recallIncludeDefault = value
            end,
            width = "full",
            disabled = function() return KyzderpsDerps.savedOptions.fashion.changeRecallStyle == "Do nothing" end
        },
    }

    for _, setting in ipairs(Fashion.GetTrampleSettings()) do
        table.insert(settings, setting)
    end

    return settings
end
