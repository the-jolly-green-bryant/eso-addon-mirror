DsRGuildPrecrafterQueue = ZO_Object:Subclass()
DsRGuildPrecrafterQueue.name = "DsRGuildPrecrafterQueue"

local LLC = LibLazyCrafting

local DAILY_ROTATION = {
    [CRAFTING_TYPE_BLACKSMITHING] = {
        --Chest
        [1] = {
          [1]   = 8,
          [15]  = 1,
        },
        --Legs
        [2] = {
          [1]   = 12,
          [15]  = 1,
        },
        --Sword
        [3] = {
          [1]   = 3,
          [15]  = 1,
        },
        --Helmet
        [4] = {
          [1]   = 11,
          [15]  = 1,
        },
        --Shoulders
        [5] = {
          [1]   = 13,
          [15]  = 1,
        },
        --Dagger
        [6] = {
          [1]   = 7,
          [15]  = 1,
        },
        --Feet
        [7] = {
          [1]   = 9,
          [15]  = 1,
        },
        --Hands
        [8] = {
          [1]   = 10,
          [15]  = 1,
        },
        --Greatsword
        [9] = {
          [1]   = 6,
          [15]  = 1,
        },
    },
    [CRAFTING_TYPE_CLOTHIER] = {
        --Light Chest
        [1] = {
          [1]   = 1, 
          [15]  = 1,
        },
        --Light Legs
        [2] = {
          [1]   = 6,
          [15]  = 1,
        },
        --Light Shoulders
        [3] = {
          [1]   = 7,
          [15]  = 1,
        },
        --Medium Hands
        [4] = {
          [1]   = 11,
          [15]  = 1,
        },
        --Medium Head
        [5] = {
          [1]   = 12,
          [15]  = 1,
        },
        --Medium Shoulders
        [6] = {
          [1]   = 14,
          [15]  = 1,
        },
        --Light Feet
        [7] = {
          [1]   = 3,
          [15]  = 1,
        },
        --Light Head
        [8] = {
          [1]   = 5,
          [15]  = 1,
        },
        --Light Belt
        [9] = {
          [1]   = 8,
          [15]  = 1,
        },
    },
    [CRAFTING_TYPE_WOODWORKING] = {
        --Restoration Staff
        [1] = {
          [1]   = 6,
          [15]  = 2,
        },
        --Shield
        [2] = {
          [1]   = 2,
          [15]  = 2,
        },
        --Bow
        [3] = {
          [1]   = 1,
          [15]  = 2,
        },
        --Fire Staff
        [4] = {
          [1]   = 3,
          [15]  = 1,
        },
        --Ice Staff
        [5] = {
          [1]   = 4,
          [15]  = 1,
        },
        --Lightning Staff
        [6] = {
          [1]   = 5,
          [15]  = 1,
        },
    },
    [CRAFTING_TYPE_JEWELRYCRAFTING] = {
        --Ring
        [1] = {
          [1]   = 1,
          [15]  = 4,
        },
        --Necklace
        [2] = {
          [1]   = 2,
          [15]  = 3,
        }
    }
}

local STYLE_ID = LLC_FREE_STYLE_CHOICE

local defaultWritOptions = {
    [4]  = STYLE_ID,
    [5]  = 1,
    [6]  = false,
    [8]  = 0,
    [9]  = 1,
    [10] = true,
    [11] = nil, --reference
    [12] = false,
    [13] = false,
    [14] = false
}

local BASE_LEVELS = {
    [1]  = { false, 1 },
    [2]  = { false, 16 },
    [3]  = { false, 26 },
    [4]  = { false, 36 },
    [5]  = { false, 46 },
    [6]  = { true, 10 },
    [7]  = { true, 40 },
    [8]  = { true, 70 },
    [9]  = { true, 90 },
    [10] = { true, 150 },
}

local WRIT_LEVELS = {
    [CRAFTING_TYPE_BLACKSMITHING]   = BASE_LEVELS,
    [CRAFTING_TYPE_CLOTHIER]        = BASE_LEVELS,
    [CRAFTING_TYPE_WOODWORKING]     = BASE_LEVELS,
    [CRAFTING_TYPE_JEWELRYCRAFTING] = {
        [1] = { false, 1 },
        [2] = { false, 26 },
        [3] = { true, 10 },
        [4] = { true, 80 },
        [5] = { true, 150 }
    }
}

local CRAFTING_BONUSES = {
    [CRAFTING_TYPE_BLACKSMITHING]   = NON_COMBAT_BONUS_BLACKSMITHING_LEVEL,
    [CRAFTING_TYPE_CLOTHIER]        = NON_COMBAT_BONUS_CLOTHIER_LEVEL,
    [CRAFTING_TYPE_WOODWORKING]     = NON_COMBAT_BONUS_WOODWORKING_LEVEL,
    [CRAFTING_TYPE_JEWELRYCRAFTING] = NON_COMBAT_BONUS_JEWELRYCRAFTING_LEVEL,
    [CRAFTING_TYPE_ENCHANTING]      = NON_COMBAT_BONUS_ENCHANTING_LEVEL
}

local TA = 45850
local ESSENCE_IDS ={
    45831,
    45832,
    45833,
}
local POTENCY_IDS = {
    [1]  = 45855,
    [2]  = 45857,
    [3]  = 45807,
    [4]  = 45809,
    [5]  = 45811,
    [6]  = 45813,
    [7]  = 45814,
    [8]  = 45815,
    [9]  = 45816,
    [10] = 64509,
}

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrecrafterQueue:New()
    local obj = ZO_Object.New(self)
    DsRGuildPrecrafterQueue:Initialize()
    return obj
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrecrafterQueue:CallbackFunction()
    return function (event, craftingType, requestTable)
        if event == LLC_NO_FURTHER_CRAFT_POSSIBLE and GetCraftingInteractionType() ~= 0 and DsRGuildPrecrafterQueue.QueueActive[craftingType] then
            DsRGuildPrecrafterQueue.QueueActive[craftingType] = false
            local currentStation = GetCraftingInteractionType()
            if currentStation == CRAFTING_TYPE_BLACKSMITHING then
              d("|c9fb6cd[DsR-Precrafter]|r " .. "|c42ffa1" .. DsR.Localization[DsR.language].DsRGuildLoot_exp_blacksmithing .. "|r" .. GetString(DsRGuildCrafting_PrecraftFinish))
            elseif currentStation == CRAFTING_TYPE_CLOTHIER then
              d("|c9fb6cd[DsR-Precrafter]|r " .. "|c42ffa1" .. DsR.Localization[DsR.language].DsRGuildLoot_exp_clothier .. "|r" .. GetString(DsRGuildCrafting_PrecraftFinish))
            elseif currentStation == CRAFTING_TYPE_WOODWORKING then
              d("|c9fb6cd[DsR-Precrafter]|r " .. "|c42ffa1" .. DsR.Localization[DsR.language].DsRGuildLoot_exp_woodworking .. "|r" .. GetString(DsRGuildCrafting_PrecraftFinish))
            elseif currentStation == CRAFTING_TYPE_JEWELRYCRAFTING then
              d("|c9fb6cd[DsR-Precrafter]|r " .. "|c42ffa1" .. DsR.Localization[DsR.language].DsRGuildLoot_exp_jewelrymaking .. "|r" .. GetString(DsRGuildCrafting_PrecraftFinish))
            elseif currentStation == CRAFTING_TYPE_ENCHANTING then
              d("|c9fb6cd[DsR-Precrafter]|r " .. "|c42ffa1" .. DsR.Localization[DsR.language].DsRGuildLoot_exp_enchanting .. "|r" .. GetString(DsRGuildCrafting_PrecraftFinish))
            end
            SCENE_MANAGER:HideCurrentScene()
        elseif event == LLC_INSUFFICIENT_MATERIALS then
            d("|c9fb6cd[DsR-Precrafter]|r " .. GetString(DsRGuildCrafting_PrecraftMats))
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrecrafterQueue:Initialize()
    DsRGuildPrecrafterQueue.InteractionTable = LLC:AddRequestingAddon(DsRGuildPrecrafterQueue.name, true, DsRGuildPrecrafterQueue:CallbackFunction(), "Hasenwarrior", {true,true,true,true,true,true,true,true,true,true,[34] = true}) 
    DsRGuildPrecrafterQueue.QueueActive = {}
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrecrafterQueue:AddProfession(professionId, multiplier)
    DsRGuildPrecrafterQueue.QueueActive[professionId] = true
    if professionId == CRAFTING_TYPE_ENCHANTING then
        local craftingPassive = GetNonCombatBonus(CRAFTING_BONUSES[professionId])
        local potency = POTENCY_IDS[craftingPassive]
        for k, essence in pairs(ESSENCE_IDS) do
            local requestTable = DsRGuildPrecrafterQueue.InteractionTable:CraftEnchantingItemId(potency, essence, TA, true, nil, nil, multiplier)
        end
    else
      local craftingPassive     = GetNonCombatBonus(CRAFTING_BONUSES[professionId])
        local isCP, craftingLevel = unpack(WRIT_LEVELS[professionId][craftingPassive])
        local craftableItems      = ZO_DeepTableCopy(DAILY_ROTATION[professionId])
        for k, item in ipairs(craftableItems) do
            item[2]  = isCP
            item[3]  = craftingLevel
            item[7]  = professionId
            item[15] = multiplier * item[15]
            ZO_DeepTableCopy(defaultWritOptions, item)
        end
        for key, craftRequest in pairs(craftableItems) do
          DsRGuildPrecrafterQueue.InteractionTable:CraftSmithingItemByLevel(unpack(craftRequest))   
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrecrafterQueue:Clear()
  DsRGuildPrecrafterQueue.InteractionTable:cancelItem()
    for key, value in pairs(DsRGuildPrecrafterQueue.QueueActive) do
      DsRGuildPrecrafterQueue.QueueActive[key] = false
    end
end