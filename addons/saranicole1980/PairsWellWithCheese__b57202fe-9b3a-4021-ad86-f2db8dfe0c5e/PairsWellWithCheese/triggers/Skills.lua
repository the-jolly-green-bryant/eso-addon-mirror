local IFTTT = PairsWellWithCheese

local Triggers = IFTTT.Triggers
local Skills = Triggers.items.Skills
Skills.available = {}
Skills.previous = {}
Skills.changes = {}
Skills.selections = {}
Skills.selected = {}
Skills.activeLock = {}
Skills.categoryLock = {}
Skills.existingCooldown = 0
Skills.timeRemaining = {}
local EM = EVENT_MANAGER



function Skills:Refresh()
  ZO_DeepTableCopy(Skills.available, Skills.previous)
  Skills.available = {}
  for slot = 3, 8 do
      local abilityId = GetSlotBoundId(slot, HOTBAR_CATEGORY_PRIMARY)
      if abilityId and abilityId ~= 0 then
          local name = GetAbilityName(abilityId)
          table.insert(Skills.available, { name=name, bar=HOTBAR_CATEGORY_PRIMARY, slotId=slot, data=HOTBAR_CATEGORY_PRIMARY.."-"..tostring(slot).."-skills" })
      end
  end
  for slot = 3, 8 do
      local abilityId = GetSlotBoundId(slot, HOTBAR_CATEGORY_BACKUP)
      if abilityId and abilityId ~= 0 then
          local name = GetAbilityName(abilityId)
          table.insert(Skills.available, { name=name, bar=HOTBAR_CATEGORY_BACKUP, slotId=slot, data=HOTBAR_CATEGORY_BACKUP.."-"..tostring(slot).."-skills" })
      end
  end
  Skills.changes = IFTTT.DiffTables(Skills.previous, Skills.hotbar)
end

function Skills:removeCallbacks(links)
  EM:UnregisterForEvent(IFTTT.Name.."SkillCallback", EVENT_ACTION_SLOT_ABILITY_USED)
end

function Skills:callbacks(links)
  local function pollSkillFinished(slotNum, hotbarCategory, slotKey, key, obj, toggleOn, firstTriggerInSequence, wait)
    local timeRemaining = 0
    for k, active in pairs(self.timeRemaining) do
      local triggerparts = IFTTT.Split(k)
      if active then
        local timeLeftSkill = GetActionSlotEffectTimeRemaining(tonumber(triggerparts[2]), tonumber(triggerparts[1]))
        if timeLeftSkill == 0 then
          self.timeRemaining[k] = false
        end
        timeRemaining = math.max(timeRemaining, timeLeftSkill)
      end
    end
    if timeRemaining <= 0 then
      self.activeLock[slotKey] = false
      self.existingCooldown = 0
      IFTTT.Outcomes.items[key]:DoOutcome(obj, toggleOn, firstTriggerInSequence)
    else
      zo_callLater(function()
        pollSkillFinished(slotNum, hotbarCategory, slotKey, key, obj, toggleOn, firstTriggerInSequence, timeRemaining)
      end, timeRemaining)
    end
  end

  EM:UnregisterForEvent(IFTTT.Name.."SkillCallback", EVENT_ACTION_SLOT_ABILITY_USED)
  EM:RegisterForEvent(IFTTT.Name.."SkillCallback", EVENT_ACTION_SLOT_ABILITY_USED, function(_, actionSlotIndex) 
    local callbackTable = {}
    for key, link in pairs(links) do
      callbackTable = {}
      local triggerparts = IFTTT.Split(link.trigger.data)
      local outcomeparts = IFTTT.Split(link.outcome.data)
      local categoryparts = IFTTT.Split(outcomeparts[2], "_")
      local type = IFTTT.toCapitalized(outcomeparts[3])
      link.trigger.active = link.trigger.active or {}
      local slotNum = tonumber(triggerparts[2])
      local hotbarCategory = tonumber(triggerparts[1])
      local outcomeCategory = tonumber(categoryparts[2])
      if not outcomeCategory or outcomeCategory == 0 then
        outcomeCategory = tonumber(categoryparts[1])
      end
      if actionSlotIndex == slotNum and GetActiveHotbarCategory() == hotbarCategory then
        local slotKey = triggerparts[1].."-"..triggerparts[2].."-"..outcomeparts[1]
        callbackTable[type] = callbackTable[type] or {}
        table.insert(callbackTable[type], link.outcome)
        for k, obj in pairs(callbackTable) do
          zo_callLater(function()
            if not self.activeLock[slotKey] then
              IFTTT.Outcomes.items[k]:DoOutcome(obj, true, self.categoryLock[outcomeCategory])
              if not self.categoryLock[outcomeCategory] then
                self.categoryLock[outcomeCategory] = true
              end
              self.activeLock[slotKey] = true
              self.existingCooldown = self.existingCooldown + GetActionSlotEffectDuration(slotNum, hotbarCategory)
              self.timeRemaining[slotKey] = true
              zo_callLater(function()
                  pollSkillFinished(slotNum, hotbarCategory, slotKey, k, obj, false, self.categoryLock[outcomeCategory], 300)
              end, self.existingCooldown)
            end
          end, 1500)
        end
      end
    end
  end)
end
