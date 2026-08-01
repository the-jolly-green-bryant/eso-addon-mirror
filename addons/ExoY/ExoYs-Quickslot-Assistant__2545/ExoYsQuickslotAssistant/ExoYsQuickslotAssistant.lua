EQA = {}

EQA.name = "ExoYsQuickslotAssistant"
EQA.version = "1.7"

-----------------
-- Addon Loaded
-----------------

function EQA.OnAddOnLoaded(event, addonName)
  if addonName == EQA.name then
    EQA:Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(EQA.name, EVENT_ADD_ON_LOADED, EQA.OnAddOnLoaded)


---------------
-- Initialize
---------------

function EQA:Initialize()
  EQA.inCombat = IsUnitInCombat("player")
  EQA.savedVariables = ZO_SavedVars:New("EQASV", 1, nil, {})
  EQA.LoadSaveVariables()
  EQA.IsPlayerInPvP()
  EQA.PlayerBar = nil

  EVENT_MANAGER:RegisterForEvent(EQA.name, EVENT_PLAYER_COMBAT_STATE, EQA.CombatStateChange)
  EVENT_MANAGER:RegisterForEvent(EQA.name, EVENT_ACTIVE_QUICKSLOT_CHANGED, EQA.ChooseQuickslot)
  EVENT_MANAGER:RegisterForEvent(EQA.name, EVENT_PLAYER_ACTIVATED, EQA.IsPlayerInPvP)
  EVENT_MANAGER:RegisterForEvent(EQA.name, EVENT_PLAYER_ACTIVATED, EQA.IsPlayerInRaid)
  EVENT_MANAGER:RegisterForEvent(EQA.name, EVENT_DUEL_STARTED, EQA.DuelStarted)
  EVENT_MANAGER:RegisterForEvent(EQA.name, EVENT_DUEL_FINISHED, EQA.DuelFinished)
  EVENT_MANAGER:RegisterForEvent(EQA.name,  EVENT_ACTIVE_WEAPON_PAIR_CHANGED, EQA.BarSwap)

  --EVENT_MANAGER:RegisterForEvent(EQA.name, EVENT_GAME_CAMERA_CHARACTER_FRAMING_STARTED , EQA.IsPlayerInPvP)
  EVENT_MANAGER:RegisterForUpdate(EQA.Name, 2000, EQA.CheckBuffFood)
  EQA.AddonMenu()

end
------------------
-- Notifications
------------------

function EQA.OnIndicatorMoveStop()
  EQA.savedVariables.left = EQA_BuffFood_Notification:GetLeft()
  EQA.savedVariables.top = EQA_BuffFood_Notification:GetTop()
end

function EQA:RestoreNotification()
  local top
  local left

  if EQA.savedVariables.left == nil then left = CENTER else left = EQA.savedVariables.left end
  if EQA.savedVariables.top == nil then top = CENTER else top = EQA.savedVariables.top end

  EQA_BuffFood_Notification:ClearAnchors()
  EQA_BuffFood_Notification:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)

  if EQA.savedVariables.BuffFoodNotificationText == nil then
    EQA.BuffFoodNotificationText="You should eat something!"
  else
    EQA.BuffFoodNotificationText = EQA.savedVariables.BuffFoodNotificationText
  end
  EQA_BuffFood_Notification_Label:SetText(EQA.BuffFoodNotificationText)

  if EQA.savedVariables.BuffFoodNotificationColor == nil then
    EQA.BuffFoodNotificationColor={1, 0, 0, 1}
  else
    EQA.BuffFoodNotificationColor = EQA.savedVariables.BuffFoodNotificationColor
  end
  EQA_BuffFood_Notification_Label:SetColor(unpack(EQA.BuffFoodNotificationColor))

  if EQA.savedVariables.BuffFoodNotificationSize == nil then
    EQA.BuffFoodNotificationSize = 80
  else
    EQA.BuffFoodNotificationSize = EQA.savedVariables.BuffFoodNotificationSize
  end

  if EQA.savedVariables.BuffFoodNotificationScale == nil then
    EQA.BuffFoodNotificationScale = 1
  else
    EQA.BuffFoodNotificationScale = EQA.savedVariables.BuffFoodNotificationScale
  end

  EQA_BuffFood_Notification_Label:SetScale(EQA.BuffFoodNotificationScale)
  --Test
  --EQA_BuffFood_Notification_Label:SetText
  EQA.SetFontSize(EQA_BuffFood_Notification, EQA_BuffFood_Notification_Label, EQA.BuffFoodNotificationSize)

  --EQA_BuffFood_Notification_Label:SetFont(g_castbarFont)

end


function EQA.SetFontSize(control, label, size)
     local path = "EsoUI/Common/Fonts/univers67.otf"
     local outline = "soft-shadow-thick"
     label:SetFont(path .. "|" .. size .. "|" .. outline)
     control:SetDimensions(label:GetTextWidth(), label:GetTextHeight())
end


--------------
-- Functions
--------------

function EQA:LoadSaveVariables()
  --if  EQA.savedVariables.Debug == nil then
  --  EQA.Debug = false
  --else
  --  EQA.Debug = EQA.savedVariables.Debug
  --end
    EQA.Debug = false
   EQA:RestoreNotification()

  if EQA.savedVariables.PositionPotion == nil then
    EQA.PositionPotion = 12
  else
    EQA.PositionPotion = EQA.savedVariables.PositionPotion
  end

  if  EQA.savedVariables.LockPotion == nil then
    EQA.LockPotion = true
  else
    EQA.LockPotion = EQA.savedVariables.LockPotion
  end

  if EQA.savedVariables.EnableInPvP == nil then
    EQA.EnableInPvP = false
  else
    EQA.EnableInPvP = EQA.savedVariables.EnableInPvP
  end

  if EQA.savedVariables.OnlyInRaid == nil then
    EQA.OnlyInRaid = true
  else
    EQA.OnlyInRaid = EQA.savedVariables.OnlyInRaid
  end

  if EQA.savedVariables.PositionBuffFood == nil then
    EQA.PositionBuffFood = 16
  else
    EQA.PositionBuffFood = EQA.savedVariables.PositionBuffFood
  end

  if  EQA.savedVariables.LockBuffFood == nil then
    EQA.LockBuffFood = true
  else
    EQA.LockBuffFood = EQA.savedVariables.LockBuffFood
  end

  if  EQA.savedVariables.CleverModus == nil then
    EQA.CleverModus = false
  else
    EQA.CleverModus = EQA.savedVariables.CleverModus
  end

  if  EQA.savedVariables.PositionEmpty == nil then
    EQA.PositionEmpty = 12
  else
    EQA.PositionEmpty = EQA.savedVariables.PositionEmpty
  end

  if  EQA.savedVariables.BuffFoodNotification == nil then
    EQA.BuffFoodNotification = true
  else
    EQA.BuffFoodNotification = EQA.savedVariables.BuffFoodNotification
  end

end


function EQA.IsPlayerInPvP()
  EQA.inPvP = false
  if IsPlayerInAvAWorld() or IsActiveWorldBattleground() or IsInImperialCity() then
    EQA.inPvP = true
    if EQA.Debug then d("Player in PvP-Zone") end
  end
end

function EQA.IsPlayerInRaid()
  EQA.inRaid = false
  diff = GetCurrentZoneDungeonDifficulty()
  if GetCurrentZoneDungeonDifficulty() ~= 0 then
    EQA.inRaid = true
    if EQA.Debug then d("Player in Dungeon or Raid") end
  end
end

function EQA.DecideActive()
  EQA.IsPlayerInPvP()
  EQA.IsPlayerInRaid()

  EQA.Activation = false

  if EQA.inPvP and EQA.EnableInPvP == EQA.inPvP then EQA.Activation = true end

  if not EQA.inPvP then
    if EQA.inRaid or not EQA.OnlyInRaid then EQA.Activation = true end
  end


end


function EQA.DuelStarted()
  if EQA.Debug then d("Duel started") end
  EQA.inPvP = true
end


function EQA.DuelFinished()
  if EQA.Debug then d("Duel finished") end
  EQA.IsPlayerInPvP()
end


function EQA.CombatStateChange(event, inCombat)
  if inCombat ~= EQA.inCombat then
    EQA.inCombat = inCombat
    if EQA.inCombat then -- enter Combat
      if EQA.Debug then d("combat started") end
      EQA.PeacefullId=GetCurrentQuickslot()
      if EQA.Debug then d("GetCurrentQuickslot:") end
      if EQA.Debug then d(EQA.PeacefullId) end
      EQA.ChooseQuickslot()
    else -- exit combat
      if EQA.Debug then d("combat finished") end
      --EQA.ChangeCurrentQuickslot(EQA.PeacefullId)
      --if EQA.Debug then d("changed to original qs") end
      EQA_BuffFood_Notification:SetHidden(true)
    end
  end
end


function EQA.CheckBuffFood()
  --if EQA.Debug then d("BuffFoodCheck") end
  local LastFoodSituation = EQA.ActiveBuffFood

  local lib = LIB_FOOD_DRINK_BUFF
  EQA.ActiveBuffFood = lib:IsFoodBuffActive("player")
  --if EQA.ActiveBuffFood == nil then EQA.LockBuffFood = false end --notlösung

  if EQA.ActiveBuffFood ~= LastFoodSituation then EQA.ChooseQuickslot() end

  --if EQA.Debug and EQA.ActiveBuffFood then d("buff food active") end
  --if EQA.Debug and not EQA.ActiveBuffFood then d("buff food missing") end

  --for i = 1, GetNumBuffs("player") do
  --  local name, _, finish, _, _, _, _, _, _, _, abilityId, canClickOff = GetUnitBuffInfo("player", i)
  --  if canClickOff and GetAbilityDuration(abilityId)>0 then
  --    EQA.ActiveBuffFood = true
  --    EQA_BuffFood_Notification:SetHidden(true)
  --    break
  --  end
  --  end
end


function EQA.ChooseQuickslot()
  --if EQA.inPvP == EQA.EnableInPvP or not EQA.inPvP then
  --if (EQA.inPvP == EQA.EnableInPvP or not EQA.inPvP) and (EQA.inRaid or not EQA.OnlyInRaid) then
  EQA.DecideActive()
  if EQA.CleverModus then
      EQA.ExecuteClever()
  elseif EQA.Activation then
      if EQA.Debug then d("ChooseQuickslot activated") end
    --if EQA.inRaid == EQA.OnlyInRaid then
      if EQA.inCombat then
        if EQA.ActiveBuffFood then EQA_BuffFood_Notification:SetHidden(true) end
        if not EQA.ActiveBuffFood and EQA.BuffFoodNotification then
            EQA_BuffFood_Notification:SetHidden(false)
        end
        if not EQA.ActiveBuffFood and EQA.LockBuffFood then
          EQA.ChangeCurrentQuickslot(EQA.PositionBuffFood)
          if EQA.Debug then d("changed to buff food") end
        elseif EQA.LockPotion then
          if EQA.Debug then d("EQA.PositionPotion") end
          if EQA.Debug then d(EQA.PositionPotion) end

          EQA.ChangeCurrentQuickslot(EQA.PositionPotion)
          if EQA.Debug then d("changed to potion") end
        end
      end
    --end
  end
end


function EQA.ChangeCurrentQuickslot(QS_ID)
  --if EQA.Debug then d("Quickslot change") end
  EVENT_MANAGER:UnregisterForEvent(EQA.name, EVENT_ACTIVE_QUICKSLOT_CHANGED)
  --if EQA.Debug then d("ChangeCurrentQuickslot") end
      if EQA.Debug then d("EQA.PositionPotion - QS_ID:") end
      if EQA.Debug then d(QS_ID) end
  --SetCurrentQuickslot(QS_ID)
  SetCurrentQuickslot(QS_ID)
  zo_callLater(function() EVENT_MANAGER:RegisterForEvent(EQA.name, EVENT_ACTIVE_QUICKSLOT_CHANGED, EQA.ChooseQuickslot) end, 250)
end


function EQA.CheckCollision()
  if EQA.PositionPotion == EQA.PositionBuffFood then
    d('Buff Food Lock Disabled!')
    d('Potion and BuffFood Position should NOT be the same!')
    EQA.LockBuffFood = false
  end
end
--------------
-- Clever Alchemist Experimental
--------------

function EQA.BarSwap(_,CurrentBar)
  EQA.PlayerBar = CurrentBar
  if EQA.CleverModus then
    if EQA.PlayerBar == 1 then
      EQA.QSBAR2 = GetCurrentQuickslot()
    elseif EQA.PlayerBar == 2 then
      EQA.ChangeCurrentQuickslot(EQA.QSBAR2)
    end
    EQA.ExecuteClever()
  end
end

function EQA.ExecuteClever()
  if EQA.IsPlayerInPvP then
    if EQA.inCombat then
      if EQA.PlayerBar == 1 then
        --d('bar1')
        EQA.ChangeCurrentQuickslot(EQA.PositionEmpty)
      elseif EQA.PlayerBar == 2 then
        --d('bar2')
        --EQA.ChangeCurrentQuickslot(EQA.QSBAR2)
      end
      --d('clever active')
    end
  end
end

--------------
-- Debugging
--------------

function EQA.PrintVars()
  d('inPvP: ' ..tostring(EQA.inPvP))
  d('Active in PvP: ' ..tostring(EQA.EnableInPvP))
  d('inRaid: ' ..tostring(EQA.inRaid))
  d('only in Raid: ' ..tostring(EQA.OnlyInRaid))
  d('Activation: ' ..tostring(EQA.Activation))
  d('ActiveBuffFood: ' ..tostring(EQA.ActiveBuffFood))
  d('LockPotion: ' ..tostring(EQA.LockPotion))
  d('PositionPotion: ' ..tostring(EQA.PositionPotion))
  d('LockBuffFood: ' ..tostring(EQA.LockBuffFood))
  d('PositionBuffFood: ' ..tostring(EQA.PositionBuffFood))
end

function EQA.ToggleDebugMode()
  if EQA.Debug then
    EQA.Debug = false
    d("EQA DebugMode Deactivated")
  else
    EQA.Debug = true
    d("EQA DebugMode Activated")
  end
end

-------------------
-- Slash Commands
-------------------

SLASH_COMMANDS["/eqavars"] = EQA.PrintVars
SLASH_COMMANDS["/eqadebug"] = EQA.ToggleDebugMode


---------------------
-- Test Environment
---------------------

function EQA.Test()
  d(GetNumBuffs("player"))
  buffs = GetNumBuffs("player")
  for i=1,buffs,1 do
    d("NextBuff")
    d(GetUnitBuffInfo("player", i))
    --local name, _, finish, _, _, _, _, _, _, _, abilityId, canClickOff = GetUnitBuffInfo("player", i)
    --d(NextBuff)
    --d(name)
    --d(finish)
    --d(abilityID)
    --d(canClickOff)
  end
end


function EQA.Test2()
  local lib = LIB_FOOD_DRINK_BUFF
  back = lib:IsFoodBuffActive("player")
  d(back)
end

function EQA.Test3()
  d(EQA.PlayerBar)
end

--SLASH_COMMANDS["/eqatest"] = EQA.Test
--SLASH_COMMANDS["/eqatest2"] = EQA.Test2
SLASH_COMMANDS["/eqatest3"] = EQA.Test3
