-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis, demawi
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: CharacterSetting.lua
-- File Description: This file contains the functions to edit character settings
-- Load Order Requirements: after RulebaseInventory
--
-----------------------------------------------------------------------------------

-- imports
local RbI = RulebasedInventory
local utils = RbI.Import(RbI.utils)

-- statics
local characterSettings = {} -- loaded character settings

RbI.class.CharacterSetting = {

    -- constructor
    New = function(name, id, settingTable)
        local self = {}

        self.GetRaw = function()
            return settingTable
        end

        self.IsInitialised = function()
            return settingTable.profile ~= nil
        end

        function self.RenameRule(ruleName, ruleNameNew)
            if(self.IsInitialised()) then
                for taskName, ruleSetData in pairs(settingTable.profile) do
                    if(ruleSetData.ruleSet ~= nil) then
                        RbI.rename(ruleSetData.ruleSet, ruleName, ruleNameNew)
                    end
                end
            end
        end

        return self
    end,

    GetAll = function()
        return characterSettings
    end,

    -- static
    LoadAll = function()
        local thisCharSettings
        local function create(characterName, characterId)
            local default = {
                profileName = nil,
                profile = {},
				lastInstanceDisplayType = -1,
                currencies = {
                    gold = {
                        bag = 1,
                        holdMin = nil,
                        holdMax = nil,
                    },
                    ap = {
                        bag = 1,
                        holdMin = nil,
                        holdMax = nil,
                    },
                    telvar = {
                        bag = 1,
                        holdMin = nil,
                        holdMax = nil,
                    },
                    vouchers = {
                        bag = 1,
                        holdMin = nil,
                        holdMax = nil,
                    }
                },
            }
            return RbI.class.CharacterSetting.New(characterName, characterId, ZO_SavedVars:New("RbICharacter", RbI.savedVariableVersion, nil, default, nil, GetDisplayName(), characterName, characterId, ZO_SAVED_VARS_CHARACTER_ID_KEY))
        end
        for i = 1, GetNumCharacters() do
            local characterName, _, _, _, _, _, characterId = GetCharacterInfo(i)
            characterName = zo_strformat("<<C:1>>", characterName)
            local curSettings = create(characterName, characterId)
            if(characterName == RbI.GetUnitName('player')) then
                thisCharSettings = curSettings
            end
            characterSettings[characterName] = curSettings
        end
        return thisCharSettings, characterSettings
    end
}