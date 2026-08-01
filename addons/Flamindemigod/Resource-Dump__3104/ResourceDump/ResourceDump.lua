local ResourceDump
do
  local _class_0
  local _base_0 = {
    name = "ResourceDump",
    variableVersion = 1,
    defaults = {
      enable = true,
      magTresholdLower = 50,
      magDumpSkill = "Siege Shield",
      magTresholdUpper = 70,
      magSkillSlot = 5,
      stamTresholdLower = 50,
      stamDumpSkill = "Rapid Maneuver",
      stamTresholdUpper = 70,
      stamSkillSlot = 5
    },
    magSkillTexture = {
      ["Siege Shield"] = "ability_ava_004",
      ["Time Stop"] = "ability_psijic_002",
      ["Purge"] = "ability_ava_005"
    },
    stamSkillTexture = {
      ["Rapid Maneuver"] = "ability_ava_002",
      ["Expert Hunter"] = "ability_fightersguild_002",
      ["Circle of Protection"] = "ability_fightersguild_001"
    },
    stamSkillInfo = nil,
    magSkillInfo = nil,
    trackMag = false,
    trackStam = false,
    onPlayerCombatState = function(event, inCombat)
      if inCombat ~= ResourceDump.inCombat then 
        ResourceDump.inCombat = inCombat
      end
      if ResourceDump.savedVariables.enable then
        if inCombat then
          EVENT_MANAGER:UnregisterForEvent(ResourceDump.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ResourceDump.gearUpdate)
          EVENT_MANAGER:UnregisterForEvent(ResourceDump.name, EVENT_POWER_UPDATE, ResourceDump.resourceTracker)
        else
          EVENT_MANAGER:RegisterForEvent(ResourceDump.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ResourceDump.gearUpdate)
          EVENT_MANAGER:AddFilterForEvent(ResourceDump.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
          EVENT_MANAGER:RegisterForEvent(ResourceDump.name, EVENT_POWER_UPDATE, ResourceDump.resourceTracker)
        end
      end
    end,
    loadSkillInfo = function()
      --if not IsPlayerActivated() then return end
      ResourceDump.stamSkillInfo = nil
      ResourceDump.magSkillInfo = nil
      ResourceDump.progressionIndexToSkillInfo = {}
      for skillType = 1, GetNumSkillTypes() do
        for skillLine = 1, GetNumSkillLines(skillType) do
          for abilityIndex = 1, math.min(7, GetNumAbilities(skillType, skillLine)) do
            local abilityId = GetSkillAbilityId(skillType, skillLine, abilityIndex, false)
            local abilityName,texture,earnedRank,passive,ultimate,purchased,progressionIndex,rankIndex =
              GetSkillAbilityInfo(skillType, skillLine, abilityIndex)
            local info = {
              skillType = skillType,
              skillLine = skillLine,
              abilityIndex = abilityIndex,
              abilityId = abilityId,
              abilityName = abilityName,
              progressionIndex = progressionIndex,
            }
            if string.find(texture,ResourceDump.stamSkillTexture[ResourceDump.savedVariables.stamDumpSkill],1,true) then
              ResourceDump.stamSkillInfo = info
            elseif string.find(texture,ResourceDump.magSkillTexture[ResourceDump.savedVariables.magDumpSkill],1,true) then
              ResourceDump.magSkillInfo = info
            elseif progressionIndex then
              ResourceDump.progressionIndexToSkillInfo[progressionIndex] = info
            end
          end
        end
      end
    end,
    saveOldSlotedSkill = function(slotNum)
      local abilityId = GetSlotBoundId(slotNum)
      if ResourceDump.magSkillInfo.abilityId == abilityId then return end
      if ResourceDump.stamSkillInfo.abilityId == abilityId then return end
      local _,progressionIndex = GetAbilityProgressionXPInfoFromAbilityId(abilityId)
      local info = ResourceDump.progressionIndexToSkillInfo[progressionIndex]
      local weaponPair,locked = GetActiveWeaponPairInfo()
      oldSlotedSkill = { slotNum = slotNum,
      weaponPair = weaponPair, 
      info = info
      }
      return oldSlotedSkill
    end,
    onActiveWeaponPairChanged = function(eventCode,activeWeaponPair,locked)
      if ResourceDump.waitSwapMag and ResourceDump.oldMagSkill then
        EVENT_MANAGER:UnregisterForEvent(ResourceDump.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, ResourceDump.onActiveWeaponPairChanged)        
        zo_callLater(function () ResourceDump.swapSkill("Mag", ResourceDump.savedVariables.magSkillSlot +2, true) end, cd)
      end
      if ResourceDump.waitSwapStam and ResourceDump.oldStamSkill then
        EVENT_MANAGER:UnregisterForEvent(ResourceDump.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, ResourceDump.onActiveWeaponPairChanged)        
        zo_callLater(function () ResourceDump.swapSkill("Stam", ResourceDump.savedVariables.stamSkillSlot +2, true) end, cd)
      end
    end,
    swapSkill = function (ResourceType, slotNum, revert)
      if (ResourceDump.oldMagSkill or ResourceDump.oldStamSkill) and not revert then
        return
      end 
      if ResourceType == "Mag" then
        if not revert and not ResourceDump.oldMagSkill then
          ResourceDump.oldMagSkill = ResourceDump.saveOldSlotedSkill(slotNum)
          SlotSkillAbilityInSlot(ResourceDump.magSkillInfo.skillType, ResourceDump.magSkillInfo.skillLine, ResourceDump.magSkillInfo.abilityIndex, ResourceDump.savedVariables.magSkillSlot+2)
        elseif revert and ResourceDump.oldMagSkill then 
          local weaponPair,locked = GetActiveWeaponPairInfo()
          if weaponPair == ResourceDump.oldMagSkill.weaponPair then
            ResourceDump.waitSwapMag = false
            SlotSkillAbilityInSlot(ResourceDump.oldMagSkill.info.skillType, ResourceDump.oldMagSkill.info.skillLine, ResourceDump.oldMagSkill.info.abilityIndex, ResourceDump.savedVariables.magSkillSlot+2)
            ResourceDump.oldMagSkill = nil
          else
            CHAT_SYSTEM:AddMessage("|caffff0Bar Swap.|r")
            ResourceDump.waitSwapMag = true
            EVENT_MANAGER:RegisterForEvent(ResourceDump.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, ResourceDump.onActiveWeaponPairChanged)
          end
        else
          return
        end
      end
      if ResourceType == "Stam" then
            if revert == false then
              ResourceDump.oldStamSkill = ResourceDump.saveOldSlotedSkill(slotNum)
              SlotSkillAbilityInSlot(ResourceDump.stamSkillInfo.skillType, ResourceDump.stamSkillInfo.skillLine, ResourceDump.stamSkillInfo.abilityIndex, ResourceDump.savedVariables.stamSkillSlot+2)
            elseif revert and ResourceDump.oldStamSkill then 
              local weaponPair,locked = GetActiveWeaponPairInfo()
              if weaponPair == ResourceDump.oldStamSkill.weaponPair then
                ResourceDump.waitSwapStam = false
                SlotSkillAbilityInSlot(ResourceDump.oldStamSkill.info.skillType, ResourceDump.oldStamSkill.info.skillLine, ResourceDump.oldStamSkill.info.abilityIndex, ResourceDump.savedVariables.stamSkillSlot+2)
                ResourceDump.oldStamSkill = nil
              else
                CHAT_SYSTEM:AddMessage("|caffff0Bar Swap.|r")
                ResourceDump.waitSwapStam = true
                EVENT_MANAGER:RegisterForEvent(ResourceDump.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, ResourceDump.onActiveWeaponPairChanged)
              end
            else
              return
            end
      end
    end,
    initalChecks = function() -- To be run on each initialize and toggle
      ResourceDump.gearUpdate() -- Recheck for gear
      local currStam, MaxStam, _ = GetUnitPower("player", POWERTYPE_STAMINA)
      local currMag, MaxMag , _= GetUnitPower("player", POWERTYPE_MAGICKA)
      if currMag == MaxMag and ResourceDump.trackMag then -- Inital Checks for Resource tracking incase resources are full, if not resourceTracker will handle switch
        ResourceDump.swapSkill("Mag", ResourceDump.savedVariables.magSkillSlot + 2, false)
      end
      if currStam == MaxStam and ResourceDump.trackStam then -- Inital Checks for Resource tracking incase resources are full, if not resourceTracker will handle switch. If Mag swap happens this is redundant, and resourceTracker will handle change
        ResourceDump.swapSkill("Stam", ResourceDump.savedVariables.stamSkillSlot + 2, false)
      end
    end,
    toggle = function()
    ResourceDump.savedVariables.enable = not ResourceDump.savedVariables.enable
    if ResourceDump.savedVariables.enable then
      CHAT_SYSTEM:AddMessage("|c00a000Resource Dump has been enabled.|r")
      ResourceDump.initalChecks()
      EVENT_MANAGER:RegisterForEvent(ResourceDump.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ResourceDump.gearUpdate)
      EVENT_MANAGER:AddFilterForEvent(ResourceDump.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
      EVENT_MANAGER:RegisterForEvent(ResourceDump.name, EVENT_POWER_UPDATE, ResourceDump.resourceTracker)
    else
      CHAT_SYSTEM:AddMessage("|caf0000Resource Dump has been disabled.|r")
      EVENT_MANAGER:UnregisterForEvent(ResourceDump.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ResourceDump.gearUpdate)
      EVENT_MANAGER:UnregisterForEvent(ResourceDump.name, EVENT_POWER_UPDATE, ResourceDump.resourceTracker)
      if ResourceDump.oldMagSkill then 
        ResourceDump.swapSkill("Mag", ResourceDump.savedVariables.magSkillSlot + 2, true)
      elseif ResourceDump.oldStamSkill then
        ResourceDump.swapSkill("Stam", ResourceDump.savedVariables.stamSkillSlot +2, true)
      end
    end
    end,
    resourceTracker = function(event, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
      if not ResourceDump.gearSwap and ResourceDump.savedVariables.enable then 
        if powerType == POWERTYPE_MAGICKA and ResourceDump.trackMag then
          if (powerValue/powerMax)*100 >= ResourceDump.savedVariables.magTresholdUpper and not ResourceDump.oldMagSkill then
            ResourceDump.swapSkill("Mag", ResourceDump.savedVariables.magSkillSlot + 2, false)
          elseif (powerValue/powerMax)*100 <= ResourceDump.savedVariables.magTresholdLower and ResourceDump.oldMagSkill then 
            ResourceDump.swapSkill("Mag", ResourceDump.savedVariables.magSkillSlot + 2, true)
          else
            local currStam, MaxStam, _ = GetUnitPower("player", POWERTYPE_STAMINA) -- Handle initial swap to start tracking stam at max stam
            if currStam == MaxStam and ResourceDump.trackStam and not ResourceDump.oldStamSkill then 
              ResourceDump.swapSkill("Stam", ResourceDump.savedVariables.stamSkillSlot + 2, false)
            end
          end
        end
        if powerType == POWERTYPE_STAMINA and ResourceDump.trackStam then
          if (powerValue/powerMax)*100 >= ResourceDump.savedVariables.stamTresholdUpper and not ResourceDump.oldStamSkill then
            ResourceDump.swapSkill("Stam", ResourceDump.savedVariables.stamSkillSlot + 2, false)
          elseif (powerValue/powerMax)*100 <= ResourceDump.savedVariables.stamTresholdLower and ResourceDump.oldStamSkill then 
            ResourceDump.swapSkill("Stam", ResourceDump.savedVariables.stamSkillSlot + 2, true)
          else
            local currMag, MaxMag, _ = GetUnitPower("player", POWERTYPE_MAGICKA) -- Handle initial swap to start tracking Mag at max Mag
            if currMag == MaxMag and ResourceDump.trackMag and not ResourceDump.oldMagSkill then 
              ResourceDump.swapSkill("Mag", ResourceDump.savedVariables.magSkillSlot + 2, false)
            end
         end
        end
      end
  end,
  gearUpdate = function()
    ResourceDump.gearSwap = true
    local slotIds = { 
      0, -- head
      3, -- shoulder
      2, -- chest
      16, -- hands
      6, -- waist
      8, -- legs
      9, -- shoes
      1, -- neck
      11, -- ring 1
      12, -- ring 2
      4, -- main weapon 1
      5, -- main weapon 2
      20, -- backup weapon 1
      21 -- backup weapon 2
    }
    local setIds1equipmag = {576 -- pearls
                    }
    local setIds5equipmag = {
      587, -- Bahsei's Mania
    591 -- Perfected Bahsei's Mania
    }
    local setIds5equipstam = {
      147 -- Martial Knowledge
      }
    local function GetSetIdBySlotId(slotId)
      local _, _, _, num_equipped, _, setId = GetItemLinkSetInfo(GetItemLink(BAG_WORN, slotId))
      return setId, num_equipped
    end
    for itterator=1, #setIds5equipmag do
      setId = setIds5equipmag[itterator]
      local pieces = 0
      for itterator2=1, 14 do
        slotId = slotIds[itterator2]
          equipedSetId, numEquiped = GetSetIdBySlotId(slotId)
          if setId == equipedSetId then
            pieces = pieces + 1
          end
          if pieces >= 5 then
            ResourceDump.trackMag = true
          else
            ResourceDump.trackMag = false
            if ResourceDump.oldMagSkill then ResourceDump.swapSkill("Mag", ResourceDump.savedVariables.magSkillSlot + 2, true) end
          end
      end
    end
    for itterator=1, #setIds5equipstam do
      setId = setIds5equipstam[itterator]
      local pieces = 0
      for itterator2=1, 14 do
        slotId = slotIds[itterator2]
          equipedSetId, numEquiped = GetSetIdBySlotId(slotId)
          if setId == equipedSetId then
            pieces = pieces + 1
          end
          if pieces >= 5 then
            ResourceDump.trackStam = true
          else
            ResourceDump.trackStam = false
            if ResourceDump.oldStamSkill then ResourceDump.swapSkill("Stam", ResourceDump.savedVariables.stamSkillSlot + 2, true) end
          end
      end
    end
    local _, _, effectiveMaxStam = GetUnitPower("player", POWERTYPE_STAMINA)
    local _, _, effectiveMaxMag = GetUnitPower("player", POWERTYPE_MAGICKA)
    if effectiveMaxMag > effectiveMaxStam then ResourceDump.dominantResource = "Mag" else ResourceDump.dominantResource = "Stam" end
    for itterator=1, #setIds1equipmag do
      setId = setIds1equipmag[itterator]
      local pieces = 0
      for itterator2=1, 14 do
        slotId = slotIds[itterator2]
          equipedSetId, numEquiped = GetSetIdBySlotId(slotId)
          if setId == equipedSetId then
            pieces = pieces + 1
          end
          if pieces == 1 then
            ResourceDump.trackPearls = true
          else
            ResourceDump.trackPearls = false
            if ResourceDump.dominantResource == "Mag" then 
              if ResourceDump.oldMagSkill then ResourceDump.swapSkill("Mag", ResourceDump.savedVariables.magSkillSlot + 2, true) end
            else
              if ResourceDump.oldStamSkill then ResourceDump.swapSkill("Stam", ResourceDump.savedVariables.stamSkillSlot + 2, true) end
            end
          end
      end
    end
    if ResourceDump.dominantResource == "Mag" then 
      ResourceDump.trackMag = ResourceDump.trackMag or ResourceDump.trackPearls
    else
      ResourceDump.trackStam = ResourceDump.trackStam or ResourceDump.trackPearls
    end
    zo_callLater(function () ResourceDump.gearSwap = false end, 500)
  end,
    Initialize = function(self)
      self.savedVariables = ZO_SavedVars:NewAccountWide(self.name .. "Vars", self.variableVersion, nil, self.defaults)
      self.inCombat = IsUnitInCombat("player")
      self.loadSkillInfo()
      if self.enable then
        self.initalChecks()
      end
      --SLASH_COMMANDS["/rd.test"] = function() ResourceDump.swapSkill("Mag", ResourceDump.savedVariables.magSkillSlot + 2 , false) end
      SLASH_COMMANDS["/rd.toggle"] = function() ResourceDump.toggle() end
      --SLASH_COMMANDS["/rd.test"] = function() d(ResourceDump.savedVariables.magSkillSlot) end
      --SLASH_COMMANDS["/rd.rettest"] = function() ResourceDump.swapSkill("Mag", ResourceDump.savedVariables.magSkillSlot + 2, true) end
      local LAM = LibAddonMenu2
      local panelName = self.name .. "Panel"
      local panelData = {
        type = "panel",
        name = "Resource Dump",
        author = "|cFFA500FlaminDemigod|r",
        version = "1.1.0",
        slashCommand = "/rd",
        registerForDefaults = true,
        registerForRefresh = true
      }
      LAM:RegisterAddonPanel(panelName, panelData)
      local optionsData = {
        [1] = {
          type = "description",
          text = "Resource Dump is used to pre-dump resources before entering combat when running sets such as Bahsei's Mania (perf. and non perf.), Martial Knowledge and Pearls of Ehlnofey"
        },
        [2] = {
          type = "checkbox",
          name = "Toggle",
          tooltip = "Global Enable/Disable of Addon without reloading",
          width = "half",
          getFunc = function() return self.savedVariables.enable end,
          setFunc = function(_) ResourceDump.toggle() end,
          warning = "All settings changes will require a reloadui to be persistant"
        },
        [3] = {
          type = "button",
          name = "Save",
          width = "half",
          warning = "Will reload ui",
          tooltip = "Will save all addon settings",
          func = function() ReloadUI("ingame") end 
        },
        [4] = {
          type = "submenu",
          name = "Stamina Dump",
          controls = {
            [1] = {
              type = "dropdown",
              name = "Dump Skill",
              tooltip = "Choose Stamina dump skill",
              choices = {"Rapid Maneuver", "Expert Hunter", "Circle of Protection"},
              width = "half",
              getFunc = function()
                return self.savedVariables.stamDumpSkill
              end,
              setFunc = function(var)
                self.savedVariables.stamDumpSkill = var
              end
            },
            [2] = {
              type = "slider", 
              name = "Stamina Threshold - Lower Bound",
              tooltip = "Set threshold to swap out stamina dump skill",
              min = 0,
              max = 100,
              step = 10,
              width = "half",
              getFunc = function()
                return self.savedVariables.stamTresholdLower
              end,
              setFunc = function(value)
                self.savedVariables.stamTresholdLower = value
              end
            },
            [3] = {
              type = "slider", 
              name = "Stamina Threshold - Upper Bound",
              tooltip = "Set threshold to swap in stamina dump skill",
              min = 0,
              max = 100,
              step = 10,
              width = "half",
              getFunc = function()
                return self.savedVariables.stamTresholdUpper
              end,
              setFunc = function(value)
                self.savedVariables.stamTresholdUpper = value
              end
            },
            [4] = {
              type = "slider", 
              name = "Skill Slot",
              tooltip = "Which Skill slot to swap into",
              min = 1,
              max = 5,
              step = 1,
              width = "half",
              getFunc = function()
                return self.savedVariables.stamSkillSlot
              end,
              setFunc = function(value)
                self.savedVariables.stamSkillSlot = value
              end
            }
          }
        },
        [5] = {
            type = "submenu",
            name = "Magicka Dump",
            controls = {
              [1] = {
                type = "dropdown",
                name = "Dump Skill",
                tooltip = "Choose Magicka dump skill",
                choices = {"Siege Shield", "Purge", "Time Stop"},
                width = "half",
                getFunc = function()
                  return self.savedVariables.magDumpSkill
                end,
                setFunc = function(var)
                  self.savedVariables.magDumpSkill = var
                end
              },
              [2] = {
                type = "slider", 
                name = "Magicka Threshold - Lower Bound",
                tooltip = "Set threshold to swap out magicka dump skill",
                min = 0,
                max = 100,
                step = 10,
                width = "half",
                getFunc = function()
                  return self.savedVariables.magTresholdLower
                end,
                setFunc = function(value)
                  self.savedVariables.magTresholdLower = value
                end
              },
              [3] = {
                type = "slider", 
                name = "Magicka Threshold - Upper Bound",
                tooltip = "How many seconds to wait before switching dump skill in",
                min = 0,
                max = 100,
                step = 10,
                width = "half",
                getFunc = function()
                  return self.savedVariables.magTresholdUpper
                end,
                setFunc = function(value)
                  self.savedVariables.magTresholdUpper = value
                end,
              },
              [4] = {
                type = "slider", 
                name = "Skill Slot",
                tooltip = "Which Skill slot to swap into",
                min = 1,
                max = 5,
                step = 1,
                width = "half",
                getFunc = function()
                  return self.savedVariables.magSkillSlot
                end,
                setFunc = function(value)
                  self.savedVariables.magSkillSlot = value
                end
              }
            }
        }
      }
      return LAM:RegisterOptionControls(panelName, optionsData)
    end,
    onAddonLoaded = function(_, addonName)
      if addonName == ResourceDump.name then
        EVENT_MANAGER:UnregisterForEvent(ResourceDump.name, EVENT_ADD_ON_LOADED)
        EVENT_MANAGER:RegisterForEvent(ResourceDump.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ResourceDump.gearUpdate)
        EVENT_MANAGER:AddFilterForEvent(ResourceDump.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
        EVENT_MANAGER:RegisterForEvent(ResourceDump.name, EVENT_POWER_UPDATE, ResourceDump.resourceTracker)
        EVENT_MANAGER:RegisterForEvent(ResourceDump.name, EVENT_PLAYER_COMBAT_STATE, ResourceDump.onPlayerCombatState)
        ZO_CreateStringId("SI_BINDING_NAME_RD_TOGGLE", "Global Toggle")


        return ResourceDump:Initialize()
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "ResourceDump"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  ResourceDump = _class_0
end
return EVENT_MANAGER:RegisterForEvent(ResourceDump.name, EVENT_ADD_ON_LOADED, ResourceDump.onAddonLoaded)

