-----------------------------------------------------------------------------------
-- Addon Name: Champion Point Import
-- Creator: TaxTalis
-- Addon Ideal: Import Champion Points from text
-- Addon Creation Date: 2022-06-20
--
-- File Name: Data.lua
-- File Description: This file contains the saved variable data handler
-- Load Order Requirements: TBD
--
-----------------------------------------------------------------------------------
local CPI = ChampionPointImport
local DataManager = CPI.Import(CPI.DataManager)

local function RegisterEvents()
    local name = CPI.name
    local events = {
        [EVENT_CHAMPION_POINT_GAINED] = function()
            local dataManager = DataManager:GetInterfaceMainDataManager()
            dataManager.Import()
            local allowRespec = dataManager.GetPresetSetting("AutoRespec") or false

            dataManager.Redistribute(allowRespec)
        end,
        [EVENT_CHAMPION_PURCHASE_RESULT] = function(_, result)
            local dataManager = DataManager:GetInterfaceMainDataManager()
            if (result == CHAMPION_PURCHASE_SUCCESS) then
                dataManager.FireCallbacks("Redistribute")
                local dataManager = DataManager:GetInterfaceEditorDataManager()
                dataManager.FireCallbacks("SkillList")
            elseif (result == CHAMPION_PURCHASE_IN_COMBAT) then
                local function Purchase(eventCode, inCombat)
                    if (not inCombat) then
                        SendChampionPurchaseRequest()
                        EVENT_MANAGER:UnregisterForEvent(name, EVENT_PLAYER_COMBAT_STATE)
                    end
                end
                EVENT_MANAGER:RegisterForEvent(name, EVENT_PLAYER_COMBAT_STATE, Purchase)
            end
        end,
        [EVENT_ARMORY_BUILD_RESTORE_RESPONSE] = function(_, result, buildIndex)
            if result == ARMORY_BUILD_RESTORE_RESULT_SUCCESS then
                DataManager:LoadPresetForArmoryBuild(buildIndex)
            end
        end,
        [EVENT_ARMORY_BUILD_COUNT_UPDATED] = function()
            local dataManager = DataManager:GetInterfaceMainDataManager()
            dataManager.FireCallbacks("AddArmoryBuild")
        end,
    }
    for event, callback in pairs(events) do
        EVENT_MANAGER:RegisterForEvent(name, event, callback)
    end
end

local function RegisterCallbacks()
    local callbacks = {}
    callbacks[ZO_ARMORY_MANAGER] = {
        ["BuildListUpdated"] = function()
            local dataManager = DataManager:GetInterfaceMainDataManager()
            dataManager.FireCallbacks("ArmoryList")
        end,
    }
    for callbackObject, callbacks in pairs(callbacks) do
        for callbackName, callbackFunction in pairs(callbacks) do
            callbackObject:RegisterCallback(callbackName, callbackFunction)
        end
    end
end

-------------------------------------------
--- INITIALIZE ----------------------------
-------------------------------------------
local function initialize()
    RegisterEvents()
    RegisterCallbacks()
end
CPI.addInitialize(initialize)
