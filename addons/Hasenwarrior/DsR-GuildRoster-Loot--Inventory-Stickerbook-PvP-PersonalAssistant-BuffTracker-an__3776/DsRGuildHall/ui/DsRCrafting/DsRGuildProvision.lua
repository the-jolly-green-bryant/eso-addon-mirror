-- Create namespace
DsRGuildProvision = {}
local DsRGuildProvision = DsRGuildProvision  or {}

DsRGuildProvision.name = "DsRGuildProvision"

DsRGuildProvision.CraftList = {}

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildProvision.CraftCore(scene, _, newstate)
    if DsRGuildLoot.sV.DsRDailyCraftProvision == false then return end
    if scene.name ~= "provisioner" then return end
    if newstate == SCENE_HIDING then --Reset
      EVENT_MANAGER:UnregisterForEvent(DsRGuildProvision.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
      EVENT_MANAGER:UnregisterForEvent(DsRGuildProvision.name, EVENT_CRAFT_COMPLETED)
      EVENT_MANAGER:UnregisterForEvent(DsRGuildProvision.name, EVENT_CRAFT_FAILED)
      return
    end
    if newstate ~= SCENE_SHOWN then return end
    
    local CurrentCraft = GetCraftingInteractionType() --current station
    EVENT_MANAGER:RegisterForEvent(DsRGuildProvision.name, EVENT_CRAFT_FAILED, DsRGuildProvision.CraftFail) 

    DsRGuildProvision.QuestStart(CurrentCraft)
end

local Recipes = {} --All Recipes info

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildProvision.QuestStart(CurrentType)
  DsRGuildProvision.CraftList = {}
  local Tep       = {}
  local CraftType = 0
  if Recipes[33526] == nil then --The first time run
    for x = 1, 40 do
      for y = 1, 1000 do
        local TargetId = select(8, GetRecipeInfo(x, y)) --Get recipe info (index, index)
        if TargetId == 0 then
          break
        else
          Recipes[TargetId] = {x, y}
        end
      end
    end
  end
  
  for questIdx = 1, MAX_JOURNAL_QUESTS do  --Look up all journal quests
    local Type      = select(10, GetJournalQuestInfo(questIdx))
    local questName = GetJournalQuestName(questIdx)
    if Type == 4 then -- Craft quests
      if (not GetJournalQuestIsComplete(questIdx)) then
        for b = 1, 6 do --Normal daily craft
          local ItemId, MaterialId, CraftType = GetQuestConditionItemInfo(questIdx, 1, b)
          if CraftType == CurrentType then
            if CraftType == 5 then
              for stepIdx = 1, GetJournalQuestNumSteps(questIdx) do
                for conditionIdx = 1, GetJournalQuestNumConditions(questIdx, stepIdx) do
                  local key = table.concat({questIdx, stepIdx, conditionIdx}, "_")
                  local txt, current, max, _, _, _, isVisible, conditionType = GetJournalQuestConditionInfo(questIdx, stepIdx, conditionIdx)

                  if txt ~="" then
                    local current, need = GetJournalQuestConditionValues(questIdx, stepIdx, conditionIdx)
                    Tep[3] = need - current
                                          
                    local Target, _, CraftType = GetQuestConditionItemInfo(questIdx, stepIdx, conditionIdx)
                    if Target ~= 0 then
                      if Tep[3] ~= 0 then
                        if CraftType ~= 0 then
                          PlaySound(SOUNDS.PROVISIONING_FILLET)
                          Tep[1], Tep[2] = unpack(Recipes[Target])
                          DsRGuildProvision.Cooking(Tep[1], Tep[2], Tep[3], questIdx)
                          EVENT_MANAGER:RegisterForEvent(DsRGuildProvision.name, EVENT_CRAFT_COMPLETED, function() zo_callLater(function() DsRGuildProvision.QuestStart(CurrentType) end, 100) end)
                        end
                      else
                        zo_callLater(
                        function()
                          SCENE_MANAGER:Hide("provisioner")
                          SCENE_MANAGER:Hide("gamepad_provisioner_root")
                          d("|c9fb6cd[DsR-Crafter]|r " .. GetString(DsRGuildCrafting_ProvisionFinish))
                        end, 2500)
                      end
                    end
                  end
                end
              end
              return
            end
          end
        end
      end
    end
  end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildProvision.Cooking(Tep1, Tep2, Tep3, questIdx)
  local IsKnown   = GetRecipeInfo(Tep1, Tep2) 
  if IsKnown == false then
    DsRGuildProvision.CraftFail(_, 100)
    return
  end

  CraftProvisionerItem(Tep1, Tep2, Tep3)
  Tep1 = 0
  Tep2 = 0
  Tep3 = 0
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildProvision.CraftFail(Alert, Warning)
    DsRGuildProvision.CraftList["Stop"] = true
    if not DsRGuildProvision.CraftList[1] then return end
    DsRGuildProvision.DD(1, {Warning})
end
  
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildProvision.DD(Type, Info) 
    local Table = {}
    --Warning_Craft_Fail: Num
    if Type == 1 then
        Table[1] = GetString("SI_TRADESKILLRESULT", Info[1])
    end
    if not Table[1] then return end
    DsRGuildProvision.Chat(Table)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildProvision.Chat(Table) 
  for i = 1, #Table do
    d("|c9fb6cd[DsR-Crafter]|r "..Table[i])
  end
  return
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildProvision.OnAddOnLoaded(eventCode, addonName)
    EVENT_MANAGER:UnregisterForEvent(DsRGuildProvision.name, EVENT_ADD_ON_LOADED)

    --Register Callback
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", DsRGuildProvision.CraftCore)    --Start craft work
end