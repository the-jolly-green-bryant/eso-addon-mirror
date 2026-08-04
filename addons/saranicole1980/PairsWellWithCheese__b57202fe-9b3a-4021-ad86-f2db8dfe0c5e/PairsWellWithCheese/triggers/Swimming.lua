local IFTTT = PairsWellWithCheese

local Triggers = IFTTT.Triggers
local Swimming = Triggers.items.Swimming
Swimming.categories = {}
Swimming.subcategories = {}
Swimming.collectibles = {}
Swimming.available = {}
Swimming.previous = {}
Swimming.changes = {}
Swimming.selectedSubcategory = nil
Swimming.selections = {}
Swimming.selected = {}
Swimming.activeLock = {}
Swimming.categoryLock = {}
Swimming.existingCooldown = 0
Swimming.timeRemaining = {}
Swimming.snapshot = {}
Swimming.hookGuard = {}
local EM = EVENT_MANAGER

local lockKey = "swimming"

function Swimming:GetAvailable()
  self.available = {{
      data          = "0-0_0_0-swimming",
      name        = IFTTT.Lang.SWIMMING
  },
  {
      data          = "0-0_0_0-swimming",
      name        = IFTTT.Lang.SWIMMING
  }}
  return self.available
end

function Swimming:Refresh()
  self.available = self:GetAvailable()
end

function Swimming:removeCallbacks()
  Swimming.hookGuard = {}
  EM:UnregisterForEvent(IFTTT.Name.."SwimmingCallback", EVENT_PLAYER_SWIMMING)
end

function Swimming:HookSwim(links)
  local callbackTable = {}
  for key, link in pairs(links) do
    callbackTable = {}
    local triggerparts = IFTTT.Split(link.trigger.data)
    local outcomeparts = IFTTT.Split(link.outcome.data)
    local activeCollectibleId = tonumber(triggerparts[1])
    local desiredCollectibleId = tonumber(outcomeparts[1])
    local type = IFTTT.toCapitalized(outcomeparts[3])
    link.trigger.active = link.trigger.active or {}
    if activeCollectibleId == 0 or not IsCollectibleActive(desiredCollectibleId) then
      local slotKey = triggerparts[1].."-"..triggerparts[2].."-"..outcomeparts[1]
      local categoryId = GetCollectibleCategoryType(desiredCollectibleId)
      callbackTable[type] = callbackTable[type] or {}
      table.insert(callbackTable[type], link.outcome)
      for k, obj in pairs(callbackTable) do
        IFTTT.Outcomes.items[k]:DoOutcome(obj, true, self.categoryLock[categoryId])
        if not self.categoryLock[categoryId] then
          self.categoryLock[categoryId] = true
        end
      end
    end
  end
end

function Swimming:PostSwim(links)
  local callbackTable = {}
  for key, link in pairs(links) do
    callbackTable = {}
    local triggerparts = IFTTT.Split(link.trigger.data)
    local outcomeparts = IFTTT.Split(link.outcome.data)
    local activeCollectibleId = tonumber(triggerparts[1])
    local desiredCollectibleId = tonumber(outcomeparts[1])
    local type = IFTTT.toCapitalized(outcomeparts[3])
    link.trigger.active = link.trigger.active or {}
    -- GetCollectibleCooldownAndDuration == 0 means it is a toggled collectible
    if IsCollectibleActive(desiredCollectibleId) and GetCollectibleCooldownAndDuration(desiredCollectibleId) == 0 then
      local slotKey = triggerparts[1].."-"..triggerparts[2].."-"..outcomeparts[1]
      callbackTable[type] = callbackTable[type] or {}
      table.insert(callbackTable[type], link.outcome)
      for k, obj in pairs(callbackTable) do
        IFTTT.Outcomes.items[k]:DoOutcome(obj, false, self.categoryLock[lockKey])
        if not self.categoryLock[lockKey] then
          self.categoryLock[lockKey] = true
        end
      end
    end
  end
end

function Swimming:removeCallbacks(links)
  EM:UnregisterForEvent(IFTTT.Name.."SwimmingCallback", EVENT_PLAYER_SWIMMING)
  EM:UnregisterForEvent(IFTTT.Name.."SwimmingCallback", EVENT_PLAYER_NOT_SWIMMING)
end

function Swimming:callbacks(links)
  local origSelf = self
  EM:UnregisterForEvent(IFTTT.Name.."SwimmingCallback", EVENT_PLAYER_SWIMMING)
  EM:UnregisterForEvent(IFTTT.Name.."SwimmingCallback", EVENT_PLAYER_NOT_SWIMMING)
  EM:RegisterForEvent(IFTTT.Name.."SwimmingCallback", EVENT_PLAYER_SWIMMING, function() 
    origSelf:HookSwim(links)
  end)
  EM:RegisterForEvent(IFTTT.Name.."SwimmingCallback", EVENT_PLAYER_NOT_SWIMMING, function() 
    origSelf:PostSwim(links)
  end)
end
