QBAC = QBAC or {}
local QBAC = QBAC

function QBAC.HasSkillSlotted()
  return true
  -- Implement a check on each skill swap, player activated etc.
  --return QBAC.HasSkillSlottedInBar(HOTBAR_CATEGORY_PRIMARY) or QBAC.HasSkillSlottedInBar(HOTBAR_CATEGORY_BACKUP)
end

function QBAC.HasSkillSlottedInBar(hotbar_id)
  if hotbar_id == nil then
    return false
  end

  local hotbar = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(hotbar_id)
  if hotbar == nil then
    return false
  end

  for slotIndex, slotData in hotbar:SlotIterator() do
    --local skilldata = slotData:GetAbilityId()
    d(slotData)
    return
  end

end