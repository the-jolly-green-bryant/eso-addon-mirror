BT = {name = "CustomBeamTracker", version = "1", duration = 0, fcslot = nil}

function BT:RestorePosition()
  local left = self.savedVariables.left
  local top = self.savedVariables.top

  BTIndicator:ClearAnchors()
  BTIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)

  BTIndicator:SetDimensions(BT.savedVariables.size, BT.savedVariables.size)
  BTIndicatorIcon:SetDimensions(BT.savedVariables.size, BT.savedVariables.size)
  BTIndicatorIcon:SetAlpha(BT.savedVariables.framealpha)

  if BT.savedVariables.vertical then
    BTIndicatorBackdrop:ClearAnchors()
    BTIndicatorBackdrop:SetAnchor(BOTTOM, BTIndicatorIcon, TOP, 0, 1, ANCHOR_CONSTRAINS_XY)
    BTIndicatorBackdrop:SetDimensions(BT.savedVariables.size, 0)
  else
    BTIndicatorBackdrop:SetDimensions(0, BT.savedVariables.size)
  end

  BTIndicatorBackdrop:SetCenterColor(unpack(BT.savedVariables.color))
  BTIndicatorBackdrop:SetEdgeColor(unpack(BT.savedVariables.edgecolor))
end

function BT.OnIndicatorMoveStop()
  BT.savedVariables.left = BTIndicator:GetLeft()
  BT.savedVariables.top = BTIndicator:GetTop()
end

function BT.UpdateTimer(initial)
  if BT.savedVariables.timer then
    if initial then
      BTIndicatorTimer:SetText(tostring(math.floor(BT.duration/1000)))
      BTIndicatorTimer:SetHidden(false)
    else
      BTIndicatorTimer:SetHidden(true)
    end
  end
end



function BT.OnCombatEvent(e, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

  if GetRawUnitName("player") == targetName or not targetName == "" or not targetName == nil then

    if abilityId == 193397 or abilityId == 183122 or abilityId == 185805 or abilityId == 193331 or abilityId == 186366 or abilityId == 193398 then

      if(result == 2250) then

        EVENT_MANAGER:UnregisterForUpdate(BT.name..'Update')
        BTIndicatorBackdrop:SetHidden(true)
        if BT.savedVariables.vertical == true then BTIndicatorBackdrop:SetDimensions(BT.savedVariables.size, BT.savedVariables.width) else BTIndicatorBackdrop:SetDimensions(BT.savedVariables.width, BT.savedVariables.size) end
        BT.UpdateTimer(false)

      end

      if(result == 2200) then

        local castBeginTime = GetGameTimeMilliseconds()
        BT.duration = hitValue
        BT.UpdateTimer(true)
        BTIndicatorBackdrop:SetHidden(false)

        EVENT_MANAGER:RegisterForUpdate(BT.name..'Update', 1000/30, function(...)
          local remaining = (castBeginTime - GetGameTimeMilliseconds()) + BT.duration

          if not BT.savedVariables.vertical then
            BTIndicatorBackdrop:SetDimensions((remaining / BT.duration) * BT.savedVariables.width, BT.savedVariables.size)
          else
            BTIndicatorBackdrop:SetDimensions(BT.savedVariables.size, (remaining / BT.duration) * BT.savedVariables.width)
          end

          BTIndicatorTimer:SetText(remaining < 1000 and string.format("%.1f", remaining/1000) or tostring(math.floor(remaining/1000)))
        end)

      end

    end

  end

end

function BT.OnAbilityUsed(e, actionSlotIndex)
  if string.match(GetSlotName(actionSlotIndex), "Fatecarver") then
    BT.fcslot = actionSlotIndex
  end
end

function BT.OnPlayerActivated(e, initial)
  if initial then
    for i=3,MAX_ACTION_BAR_ABILITY_SLOTS+1 do
      for s = 0, 1 do
        if GetSlotName(i, s):find("Fatecarver") then
          BTIndicatorIcon:SetTexture(GetSlotTexture(i, s))
          break
        end
      end
    end
  end
end

function BT.Initialize()
  if GetUnitClassId("player") == 117 then BTIndicator:SetHidden(false) else return end

  BT.savedVariables = ZO_SavedVars:NewCharacterIdSettings("BTSavedVariables", 1, nil, {width = 200, size = 32, color = { 1, 0.5, 0, 0.5 }, edgecolor = { 0, 0, 0, 1 }, timer = false, framealpha = 1, vertical = false})
  BT:RestorePosition()
  BT.BuildMenu()

  EVENT_MANAGER:RegisterForEvent(BT.name..'CombatEvent', EVENT_COMBAT_EVENT, BT.OnCombatEvent)
  EVENT_MANAGER:RegisterForEvent(BT.name..'AbilityUsed', EVENT_ACTION_SLOT_ABILITY_USED, BT.OnAbilityUsed)

  EVENT_MANAGER:RegisterForEvent(BT.name..'PlayerActivated', EVENT_PLAYER_ACTIVATED, BT.OnPlayerActivated)
end

function BT.OnAddOnLoaded(event, addonName)
  if addonName == BT.name then
    BT.Initialize()
    EVENT_MANAGER:UnregisterForEvent(BT.name..'OnLoaded', EVENT_ADD_ON_LOADED)
  end
end

EVENT_MANAGER:RegisterForEvent(BT.name..'OnLoaded', EVENT_ADD_ON_LOADED, BT.OnAddOnLoaded)