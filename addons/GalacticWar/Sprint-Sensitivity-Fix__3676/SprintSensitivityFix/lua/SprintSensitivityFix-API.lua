-- Globals -----------------------------------------------------
SprintSensitivityFix = {}

SprintSensitivityFix.name = "SprintSensitivityFix"

SprintSensitivityFix.events = {
  loop = SprintSensitivityFix.name .. ".SprintSensitivityFixLoop",
}

-- Localizations -----------------------------------------------
local SprintSensitivityFixName = SprintSensitivityFix.name
local loopEvent = SprintSensitivityFix.events.loop
-----
local zo_callLater = zo_callLater
local GetItemWeaponType = GetItemWeaponType
local GetSlotBoundId = GetSlotBoundId
local GetSetting = GetSetting
local SetSetting = SetSetting
local GetGameTimeMilliseconds = GetGameTimeMilliseconds
local ArePlayerWeaponsSheathed = ArePlayerWeaponsSheathed
local IsShiftKeyDown = IsShiftKeyDown
local IsPlayerTryingToMove = IsPlayerTryingToMove
local GetAllyUnitBlockState = GetAllyUnitBlockState
local ActionSlotHasStatusEffectFailure = ActionSlotHasStatusEffectFailure
local GetUnitPower = GetUnitPower
local IsUnitDeadOrReincarnating = IsUnitDeadOrReincarnating
local CACHED_EVENT_MANAGER = EVENT_MANAGER
-----
local EQUIP_SLOT_MAIN_HAND = EQUIP_SLOT_MAIN_HAND
local EQUIP_SLOT_BACKUP_MAIN = EQUIP_SLOT_BACKUP_MAIN
local EQUIP_SLOT_OFF_HAND = EQUIP_SLOT_OFF_HAND
local EQUIP_SLOT_BACKUP_OFF = EQUIP_SLOT_BACKUP_OFF
local WEAPONTYPE_NONE = WEAPONTYPE_NONE
local BAG_WORN = BAG_WORN
local POWERTYPE_STAMINA = POWERTYPE_STAMINA
local HOTBAR_CATEGORY_PRIMARY = HOTBAR_CATEGORY_PRIMARY
local HOTBAR_CATEGORY_BACKUP = HOTBAR_CATEGORY_BACKUP
local HOTBAR_CATEGORY_WEREWOLF = HOTBAR_CATEGORY_WEREWOLF
local GAMEPAD_SETTING_INPUT_PREFERRED_MODE = GAMEPAD_SETTING_INPUT_PREFERRED_MODE

----- SETTING_TYPE_CAMERA = 2
----- SETTING_TYPE_GAMEPAD = 15
----- CAMERA_SETTING_SENSITIVITY_FIRST_PERSON_X = 3
----- CAMERA_SETTING_SENSITIVITY_FIRST_PERSON_Y = 19
----- CAMERA_SETTING_SENSITIVITY_THIRD_PERSON_X = 2
----- CAMERA_SETTING_SENSITIVITY_THIRD_PERSON_Y = 18
----- SETTING_TYPE_GAMEPAD = 15
----- GAMEPAD_SETTING_CAMERA_SENSITIVITY_X = 3
----- GAMEPAD_SETTING_CAMERA_SENSITIVITY_Y = 15

-- Hotbar ------------------------------------------------------
local hotbarSlot = 1
local activeHotbar = HOTBAR_CATEGORY_PRIMARY
local mainHotbarWeaponTimer = 1200
local backupHotbarWeaponTimer = 1200

-- Mode/Menu ---------------------------------------------------
local isInGamepadMode
local isRollDodgeReady = true
local isMenuOpen = false

-- Timer -------------------------------------------------------
local elapsed
local sheathingWeaponTimer
local fastSheathingWeaponTimer
local rollDodgeTimer
local lastStaminaUpdate = 0
local lastStealthUpdate = 0

-- Keyboard & Gamepad ------------------------------------------
local playerBlockState
local isPlayerSwimming
-----
local isPlayerDead
local isPlayerMounted
local hasStamina = true
local fullRollDodge
-----
local isPlayerTryingToMove
local isPlayerCrouched

-- Rotation Speed ----------------------------------------------
local appliedRotationSpeed = 1
-----
local mouse1stPersonLookSpeedX = 0.85
local mouse1stPersonLookSpeedY = 0.85
local mouse3rdPersonLookSpeedX = 0.85
local mouse3rdPersonLookSpeedY = 0.85
local mouse1stPersonSprintLookSpeedX = 1.7
local mouse1stPersonSprintLookSpeedY = 1.7
local mouse3rdPersonSprintLookSpeedX = 1.7
local mouse3rdPersonSprintLookSpeedY = 1.7
-----
local gamepadLookSensitivityX = 0.85
local gamepadLookSensitivityY = 0.85
local gamepadSprintLookSensitivityX = 1.05
local gamepadSprintLookSensitivityY = 1.05

-- Current and Previous ----------------------------------------
local previousWeaponsSheathed
local currentWeaponsSheathed
-----
local previousStamina
local currentStamina = 0
-----
local previousShiftKeyDown
local currentShiftKeyDown = false
----------------------------------------------------------------


-- Using "Colored Regions" extension for better readability

-- region [GAMEPAD]

-- Sets current stamina ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function staminaCheck(eventCode, unitTag, powerIndex, powerType, powerValue)

  previousStamina = currentStamina
  currentStamina = powerValue

  -- MENU OPEN -----------------------------------------------------------------------------------------------------------<<<<
  if isMenuOpen then return end
  ------------------------------------------------------------------------------------------------------------------------<<<<

  if currentStamina < previousStamina and currentStamina + 25 > previousStamina and isPlayerTryingToMove and playerBlockState ~= 2 and playerBlockState ~= 4 and not isPlayerCrouched and currentStamina ~= 0 then

    lastStaminaUpdate = GetGameTimeMilliseconds()

    if playerBlockState ~= 4 then isPlayerSwimming = false end

    if not currentWeaponsSheathed or sheathingWeaponTimer or fastSheathingWeaponTimer then
      if appliedRotationSpeed == 2 then return end
      SetSetting(2, 3, mouse1stPersonSprintLookSpeedX)
      SetSetting(2, 19, mouse1stPersonSprintLookSpeedY)
      SetSetting(2, 2, mouse3rdPersonSprintLookSpeedX)
      SetSetting(2, 18, mouse3rdPersonSprintLookSpeedY)
      SetSetting(15, 3, gamepadSprintLookSensitivityX)
      SetSetting(15, 15, gamepadSprintLookSensitivityY)
      appliedRotationSpeed = 2
  
    elseif appliedRotationSpeed ~= 3 then
      SetSetting(2, 3, mouse1stPersonSprintLookSpeedX)
      SetSetting(2, 19, mouse1stPersonSprintLookSpeedY)
      SetSetting(2, 2, mouse3rdPersonLookSpeedX)
      SetSetting(2, 18, mouse3rdPersonLookSpeedY)
      SetSetting(15, 3, gamepadLookSensitivityX)
      SetSetting(15, 15, gamepadLookSensitivityY)
      appliedRotationSpeed = 3
    end

  elseif appliedRotationSpeed ~= 1 and (lastStaminaUpdate - lastStealthUpdate >= 25) then
    SetSetting(2, 3, mouse1stPersonLookSpeedX)
    SetSetting(2, 19, mouse1stPersonLookSpeedY)
    SetSetting(2, 2, mouse3rdPersonLookSpeedX)
    SetSetting(2, 18, mouse3rdPersonLookSpeedY)
    SetSetting(15, 3, gamepadLookSensitivityX)
    SetSetting(15, 15, gamepadLookSensitivityY)
    appliedRotationSpeed = 1
  end
end

-- Gamepad mode loop function ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function gamepadLoop()

  -- SHIFT KEY ---------------------------------------------------------------------------------
  previousShiftKeyDown = currentShiftKeyDown
  currentShiftKeyDown = IsShiftKeyDown()
  ----------------------------------------------------------------------------------------------

  -- WEAPON SHEATHED ---------------------------------------------------------------------------
  currentWeaponsSheathed = ArePlayerWeaponsSheathed()

  if previousWeaponsSheathed ~= currentWeaponsSheathed then

    if not previousWeaponsSheathed and currentWeaponsSheathed then
      sheathingWeaponTimer = GetGameTimeMilliseconds()
  
    elseif previousWeaponsSheathed and not currentWeaponsSheathed then
      sheathingWeaponTimer = false

      if appliedRotationSpeed == 3 then
        SetSetting(2, 3, mouse1stPersonSprintLookSpeedX)
        SetSetting(2, 19, mouse1stPersonSprintLookSpeedY)
        SetSetting(2, 2, mouse3rdPersonSprintLookSpeedX)
        SetSetting(2, 18, mouse3rdPersonSprintLookSpeedY)
        SetSetting(15, 3, gamepadSprintLookSensitivityX)
        SetSetting(15, 15, gamepadSprintLookSensitivityY)
        appliedRotationSpeed = 2
      end
    end

    previousWeaponsSheathed = currentWeaponsSheathed
  end
  ----------------------------------------------------------------------------------------------

  -- MENU OPEN -----------------------------------------------------------------------------------------------------------<<<<
  if isMenuOpen then return
  ------------------------------------------------------------------------------------------------------------------------<<<<

  -- SHEATHING WEAPON TIMER --------------------------------------------------------------------
  elseif fastSheathingWeaponTimer and GetGameTimeMilliseconds() - fastSheathingWeaponTimer >= 600 then
    fastSheathingWeaponTimer = false
    sheathingWeaponTimer = false

    if appliedRotationSpeed == 2 then
      SetSetting(2, 3, mouse1stPersonSprintLookSpeedX)
      SetSetting(2, 19, mouse1stPersonSprintLookSpeedY)
      SetSetting(2, 2, mouse3rdPersonLookSpeedX)
      SetSetting(2, 18, mouse3rdPersonLookSpeedY)
      SetSetting(15, 3, gamepadLookSensitivityX)
      SetSetting(15, 15, gamepadLookSensitivityY)
      appliedRotationSpeed = 3
    end

  elseif sheathingWeaponTimer then
    elapsed = GetGameTimeMilliseconds() - sheathingWeaponTimer

    if elapsed >= 800 then

      if activeHotbar == HOTBAR_CATEGORY_WEREWOLF and elapsed >= 1000 then
          sheathingWeaponTimer = false

      elseif activeHotbar == HOTBAR_CATEGORY_PRIMARY and elapsed >= mainHotbarWeaponTimer then
          sheathingWeaponTimer = false

      elseif activeHotbar == HOTBAR_CATEGORY_BACKUP and elapsed >= backupHotbarWeaponTimer then
          sheathingWeaponTimer = false
      end

      if not sheathingWeaponTimer and appliedRotationSpeed == 2 then
        SetSetting(2, 3, mouse1stPersonSprintLookSpeedX)
        SetSetting(2, 19, mouse1stPersonSprintLookSpeedY)
        SetSetting(2, 2, mouse3rdPersonLookSpeedX)
        SetSetting(2, 18, mouse3rdPersonLookSpeedY)
        SetSetting(15, 3, gamepadLookSensitivityX)
        SetSetting(15, 15, gamepadLookSensitivityY)
        appliedRotationSpeed = 3
      end
    end
  end
  ----------------------------------------------------------------------------------------------

  -- NOT MOVING or BLOCKING/ROLL DODGING -------------------------------------------------------
  isPlayerTryingToMove = IsPlayerTryingToMove()
  playerBlockState = GetAllyUnitBlockState("player")

  if appliedRotationSpeed ~= 1 and (not isPlayerTryingToMove or playerBlockState == 2 or playerBlockState == 4 or isPlayerSwimming or isPlayerCrouched
  or (currentShiftKeyDown and currentShiftKeyDown ~= previousShiftKeyDown) or (GetGameTimeMilliseconds() - lastStaminaUpdate >= 50)) then
    SetSetting(2, 3, mouse1stPersonLookSpeedX)
    SetSetting(2, 19, mouse1stPersonLookSpeedY)
    SetSetting(2, 2, mouse3rdPersonLookSpeedX)
    SetSetting(2, 18, mouse3rdPersonLookSpeedY)
    SetSetting(15, 3, gamepadLookSensitivityX)
    SetSetting(15, 15, gamepadLookSensitivityY)
    appliedRotationSpeed = 1
  end
  ----------------------------------------------------------------------------------------------
end

-- Triggers when the player casts an ability -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function gamepadAbilityCastCheck(eventCode)

  if appliedRotationSpeed ~= 1 then
    SetSetting(2, 3, mouse1stPersonLookSpeedX)
    SetSetting(2, 19, mouse1stPersonLookSpeedY)
    SetSetting(2, 2, mouse3rdPersonLookSpeedX)
    SetSetting(2, 18, mouse3rdPersonLookSpeedY)
    SetSetting(15, 3, gamepadLookSensitivityX)
    SetSetting(15, 15, gamepadLookSensitivityY)
    appliedRotationSpeed = 1
  end
end

-- Triggers when the player stealth state changes --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function stealthCheck(eventCode, unitTag, stealthState)

  stealthState = stealthState > 0

  if isPlayerCrouched ~= stealthState then
    lastStealthUpdate = GetGameTimeMilliseconds()

    isPlayerCrouched = stealthState

    if isPlayerCrouched and appliedRotationSpeed ~= 1 then
      SetSetting(2, 3, mouse1stPersonLookSpeedX)
      SetSetting(2, 19, mouse1stPersonLookSpeedY)
      SetSetting(2, 2, mouse3rdPersonLookSpeedX)
      SetSetting(2, 18, mouse3rdPersonLookSpeedY)
      SetSetting(15, 3, gamepadLookSensitivityX)
      SetSetting(15, 15, gamepadLookSensitivityY)
      appliedRotationSpeed = 1
    end
  end
end

-- endregion


-- region [KEYBOARD]

-- Checks if the player is sprinting ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function sprintingCheck(eventCode, slotId)

  if slotId ~= hotbarSlot or isMenuOpen or fullRollDodge then return end

  playerBlockState = GetAllyUnitBlockState("player")

  if playerBlockState ~= 4 then isPlayerSwimming = false end

  if playerBlockState == 4 or playerBlockState == 2 or isPlayerMounted or not ActionSlotHasStatusEffectFailure() then
    if appliedRotationSpeed == 1 then return end
    SetSetting(2, 3, mouse1stPersonLookSpeedX)
    SetSetting(2, 19, mouse1stPersonLookSpeedY)
    SetSetting(2, 2, mouse3rdPersonLookSpeedX)
    SetSetting(2, 18, mouse3rdPersonLookSpeedY)
    appliedRotationSpeed = 1

  elseif not currentWeaponsSheathed or sheathingWeaponTimer or fastSheathingWeaponTimer then
    if appliedRotationSpeed == 2 then return end
    SetSetting(2, 3, mouse1stPersonSprintLookSpeedX)
    SetSetting(2, 19, mouse1stPersonSprintLookSpeedY)
    SetSetting(2, 2, mouse3rdPersonSprintLookSpeedX)
    SetSetting(2, 18, mouse3rdPersonSprintLookSpeedY)
    appliedRotationSpeed = 2

  elseif appliedRotationSpeed ~= 3 then
    SetSetting(2, 3, mouse1stPersonSprintLookSpeedX)
    SetSetting(2, 19, mouse1stPersonSprintLookSpeedY)
    SetSetting(2, 2, mouse3rdPersonLookSpeedX)
    SetSetting(2, 18, mouse3rdPersonLookSpeedY)
    appliedRotationSpeed = 3
  end
end

-- Seperated the sheathing weapon timers into their own function to simplify code ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function weaponTimerCheck(doAditionalCheck)

  if fastSheathingWeaponTimer and GetGameTimeMilliseconds() - fastSheathingWeaponTimer >= 600 then
    fastSheathingWeaponTimer = false
    sheathingWeaponTimer = false
    sprintingCheck(nil, hotbarSlot)

    return true

  elseif sheathingWeaponTimer then
    elapsed = GetGameTimeMilliseconds() - sheathingWeaponTimer

    if elapsed < 800 then
      return true

    elseif activeHotbar == HOTBAR_CATEGORY_WEREWOLF and elapsed >= 1000 then
      sheathingWeaponTimer = false
      sprintingCheck(nil, hotbarSlot)

    elseif activeHotbar == HOTBAR_CATEGORY_PRIMARY and elapsed >= mainHotbarWeaponTimer then
      sheathingWeaponTimer = false
      sprintingCheck(nil, hotbarSlot)

    elseif activeHotbar == HOTBAR_CATEGORY_BACKUP and elapsed >= backupHotbarWeaponTimer then
      sheathingWeaponTimer = false
      sprintingCheck(nil, hotbarSlot)

    elseif doAditionalCheck and elapsed >= 900 and elapsed < 1000 and GetAllyUnitBlockState("player") == 4 then
      sheathingWeaponTimer = false
      if appliedRotationSpeed == 1 then return end
      SetSetting(2, 3, mouse1stPersonLookSpeedX)
      SetSetting(2, 19, mouse1stPersonLookSpeedY)
      SetSetting(2, 2, mouse3rdPersonLookSpeedX)
      SetSetting(2, 18, mouse3rdPersonLookSpeedY)
      appliedRotationSpeed = 1
    end

    return true
  end

  return false
end

-- Checks if player weapons are sheathed in a loop and controls the roll dodge timer ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function keyboardLoop()

  -- WEAPON SHEATHED ---------------------------------------------------------------------------
  currentWeaponsSheathed = ArePlayerWeaponsSheathed()

  if previousWeaponsSheathed ~= currentWeaponsSheathed then

    if not previousWeaponsSheathed and currentWeaponsSheathed then
      if not fastSheathingWeaponTimer then sheathingWeaponTimer = GetGameTimeMilliseconds() end
  
    elseif previousWeaponsSheathed and not currentWeaponsSheathed then
      fastSheathingWeaponTimer = false
      sheathingWeaponTimer = false

      if appliedRotationSpeed == 3 then
        SetSetting(2, 3, mouse1stPersonSprintLookSpeedX)
        SetSetting(2, 19, mouse1stPersonSprintLookSpeedY)
        SetSetting(2, 2, mouse3rdPersonSprintLookSpeedX)
        SetSetting(2, 18, mouse3rdPersonSprintLookSpeedY)
        appliedRotationSpeed = 2
      end
    end

    previousWeaponsSheathed = currentWeaponsSheathed
  ----------------------------------------------------------------------------------------------

  -- MENU OPEN -----------------------------------------------------------------------------------------------------------<<<<
  elseif isMenuOpen then
    return
  ------------------------------------------------------------------------------------------------------------------------<<<<

  -- SHEATHING WEAPON TIMER (& ALTERNATIVE SPRINT CHECK) ---------------------------------------
  elseif rollDodgeTimer then
    playerBlockState = GetAllyUnitBlockState("player")

    if not isRollDodgeReady then
      rollDodgeTimer = false

    elseif GetGameTimeMilliseconds() - rollDodgeTimer >= 400 then
      rollDodgeTimer = false
      fullRollDodge = false
      CACHED_EVENT_MANAGER:UnregisterForEvent(SprintSensitivityFixName, EVENT_ACTION_SLOT_ABILITY_USED)

      if not weaponTimerCheck(false) then
        sprintingCheck(nil, hotbarSlot)
      end

     -- ALTERNATIVE SPRINT CHECK ---------------------------------------------------------------
    elseif GetUnitPower("player", POWERTYPE_STAMINA) == 0 then
      hasStamina = false
      if appliedRotationSpeed == 1 then return end
      SetSetting(2, 3, mouse1stPersonLookSpeedX)
      SetSetting(2, 19, mouse1stPersonLookSpeedY)
      SetSetting(2, 2, mouse3rdPersonLookSpeedX)
      SetSetting(2, 18, mouse3rdPersonLookSpeedY)
      appliedRotationSpeed = 1

    elseif isPlayerDead or playerBlockState == 2 or not IsPlayerTryingToMove() or not IsShiftKeyDown() then
      hasStamina = true
      if appliedRotationSpeed == 1 then return end
      SetSetting(2, 3, mouse1stPersonLookSpeedX)
      SetSetting(2, 19, mouse1stPersonLookSpeedY)
      SetSetting(2, 2, mouse3rdPersonLookSpeedX)
      SetSetting(2, 18, mouse3rdPersonLookSpeedY)
      appliedRotationSpeed = 1

    elseif playerBlockState == 4 then
      if appliedRotationSpeed == 1 or not hasStamina then return end
      SetSetting(2, 3, mouse1stPersonLookSpeedX)
      SetSetting(2, 19, mouse1stPersonLookSpeedY)
      SetSetting(2, 2, mouse3rdPersonLookSpeedX)
      SetSetting(2, 18, mouse3rdPersonLookSpeedY)
      appliedRotationSpeed = 1

    elseif not currentWeaponsSheathed or sheathingWeaponTimer then
      if appliedRotationSpeed == 2 or not hasStamina then return end
      SetSetting(2, 3, mouse1stPersonSprintLookSpeedX)
      SetSetting(2, 19, mouse1stPersonSprintLookSpeedY)
      SetSetting(2, 2, mouse3rdPersonSprintLookSpeedX)
      SetSetting(2, 18, mouse3rdPersonSprintLookSpeedY)
      appliedRotationSpeed = 2

    elseif appliedRotationSpeed ~= 3 and hasStamina then
      SetSetting(2, 3, mouse1stPersonSprintLookSpeedX)
      SetSetting(2, 19, mouse1stPersonSprintLookSpeedY)
      SetSetting(2, 2, mouse3rdPersonLookSpeedX)
      SetSetting(2, 18, mouse3rdPersonLookSpeedY)
      appliedRotationSpeed = 3
    end
   ---------------------------------------------------------------------------------------------

  else
    weaponTimerCheck(true)
  end
  ----------------------------------------------------------------------------------------------
end

-- Triggers when the player stunned state changes --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function stunCheck(eventCode, playerStunned)

  if playerStunned then
    if appliedRotationSpeed == 1 then return end
    SetSetting(2, 3, mouse1stPersonLookSpeedX)
    SetSetting(2, 18, mouse1stPersonLookSpeedY)
    SetSetting(2, 2, mouse3rdPersonLookSpeedX)
    SetSetting(2, 19, mouse3rdPersonLookSpeedY)
    appliedRotationSpeed = 1

  else
    sprintingCheck(nil, hotbarSlot)
  end
end

-- Checks if the player casted an ability ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function keyboardAbilityCastCheck(eventCode, slotNum)

  if not hasStamina and GetUnitPower("player", POWERTYPE_STAMINA) ~= 0 then
    hasStamina = true
  end
end

-- Checks for player deaths ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function playerDeathCheck()

  if fullRollDodge then
    isPlayerDead = true
    sheathingWeaponTimer = false
    if rollDodgeTimer then CACHED_EVENT_MANAGER:UnregisterForEvent(SprintSensitivityFixName, EVENT_ACTION_SLOT_ABILITY_USED) end
    rollDodgeTimer = false
    fullRollDodge = false
  end

  if appliedRotationSpeed ~= 1 then
    SetSetting(2, 3, mouse1stPersonLookSpeedX)
    SetSetting(2, 19, mouse1stPersonLookSpeedY)
    SetSetting(2, 2, mouse3rdPersonLookSpeedX)
    SetSetting(2, 18, mouse3rdPersonLookSpeedY)
    appliedRotationSpeed = 1
  end
end

-- Function that updates the variable relating to the player being in a mount ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function playerMountedCheck(eventCode, mounted)

  isPlayerMounted = mounted
end

-- Checks if the player is roll dodging ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function rollDodgeCheck(eventCode, changeType, effectSlot, effectName, unitTag, beginTime)

  if effectName == "Immobilize Immunity" and isRollDodgeReady and beginTime ~= 0 then

    isRollDodgeReady = false

    fullRollDodge = true
    hasStamina = true
    fastSheathingWeaponTimer = false
    sheathingWeaponTimer = false
    isPlayerDead = false

    zo_callLater(function()
      isRollDodgeReady = true
      rollDodgeTimer = GetGameTimeMilliseconds()
      CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_ACTION_SLOT_ABILITY_USED, keyboardAbilityCastCheck)
      keyboardLoop()
    end, 600)
  end
end

-- endregion


-- region [SHARED]

-- Checks the type of weapon the player has (armed or unarmed) -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function weaponTypeCheck(eventCode, bagId, slotId)

  if bagId == BAG_WORN and (slotId == EQUIP_SLOT_MAIN_HAND or slotId == EQUIP_SLOT_BACKUP_MAIN or slotId == EQUIP_SLOT_OFF_HAND or slotId == EQUIP_SLOT_BACKUP_OFF) then

    if GetItemWeaponType(BAG_WORN, EQUIP_SLOT_MAIN_HAND) == WEAPONTYPE_NONE then
      mainHotbarWeaponTimer = (GetItemWeaponType(BAG_WORN, EQUIP_SLOT_OFF_HAND) ~= WEAPONTYPE_NONE) and 1200 or 800
    else
      mainHotbarWeaponTimer = 1200
    end

    if GetItemWeaponType(BAG_WORN, EQUIP_SLOT_BACKUP_MAIN) == WEAPONTYPE_NONE then
      backupHotbarWeaponTimer = (GetItemWeaponType(BAG_WORN, EQUIP_SLOT_BACKUP_OFF) ~= WEAPONTYPE_NONE) and 1200 or 800
    else
      backupHotbarWeaponTimer = 1200
    end
  end
end

-- Checks slots for skills to observe --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function skillSlottedCheck()

  if activeHotbar == HOTBAR_CATEGORY_WEREWOLF or GetSlotBoundId(8) > 0 then
    hotbarSlot = 8

  else
    hotbarSlot = 1
  end
end

-- Triggers when player swaps hotbar ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function hotbarSwapCheck(eventCode, didActiveHotbarChange, shouldUpdateAbilityAssignments, HotBarCategory)

  if not didActiveHotbarChange then
    return

  elseif HotBarCategory == HOTBAR_CATEGORY_WEREWOLF or GetSlotBoundId(8) > 0 then
    hotbarSlot = 8

  else
    hotbarSlot = 1
  end

  activeHotbar = HotBarCategory
end

-- Function that detects fast weapon sheaths -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function fastWeaponSheathCheck(eventCode)

  if not currentWeaponsSheathed and (appliedRotationSpeed == 1 or isInGamepadMode) and not IsPlayerTryingToMove() then
    playerBlockState = GetAllyUnitBlockState("player")

    if playerBlockState ~= 4 then
      isPlayerSwimming = false

      if playerBlockState ~= 2 then
        fastSheathingWeaponTimer = GetGameTimeMilliseconds()
      end
    end
  end
end

-- Triggers when the camera goes into character framing mode ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function fastWeaponSheathCheck2(eventCode)

  if not ArePlayerWeaponsSheathed() and GetAllyUnitBlockState("player") ~= 4 then
    sheathingWeaponTimer = false
    fastSheathingWeaponTimer = GetGameTimeMilliseconds()
  end
end

-- Function that detects if the player starts swimming ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function swimmingCheck()

  isPlayerSwimming = true

  if appliedRotationSpeed ~= 1 then
    SetSetting(2, 2, mouse3rdPersonLookSpeedX)
    SetSetting(2, 19, mouse3rdPersonLookSpeedY)
    SetSetting(2, 3, mouse1stPersonLookSpeedX)
    SetSetting(2, 18, mouse1stPersonLookSpeedY)
    if isInGamepadMode then
      SetSetting(15, 3, gamepadLookSensitivityX)
      SetSetting(15, 15, gamepadLookSensitivityY)
    end
    appliedRotationSpeed = 1
  end
end

-- Triggers when the player exits water ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function notSwimmingCheck()

  isPlayerSwimming = false

  if not ArePlayerWeaponsSheathed() then
    TogglePlayerWield()
  end
end

-- Triggers when the player interacts with an object -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function notSwimmingCheck2()

  if isPlayerSwimming and not currentWeaponsSheathed then
    TogglePlayerWield()
  end

  isPlayerSwimming = false
end

-- Function ran every time the character is displaced (teleports) or the game is closed ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function characterDisplacement()

  isPlayerSwimming = false
end

-- Checks if any menu is open ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function menuOpenCheck(eventCode, hidden)

  isMenuOpen = hidden

  if isMenuOpen then

    if appliedRotationSpeed ~= 1 then
      SetSetting(2, 2, mouse3rdPersonLookSpeedX)
      SetSetting(2, 19, mouse3rdPersonLookSpeedY)
      SetSetting(2, 3, mouse1stPersonLookSpeedX)
      SetSetting(2, 18, mouse1stPersonLookSpeedY)
      SetSetting(15, 3, gamepadLookSensitivityX)
      SetSetting(15, 15, gamepadLookSensitivityY)
      appliedRotationSpeed = 1
    end

  else
    mouse1stPersonLookSpeedX = GetSetting(2, 3)
    mouse1stPersonSprintLookSpeedX = mouse1stPersonLookSpeedX * 2
    mouse1stPersonLookSpeedY = GetSetting(2, 19)
    mouse1stPersonSprintLookSpeedY = mouse1stPersonLookSpeedY * 2

    mouse3rdPersonLookSpeedX = GetSetting(2, 2)
    mouse3rdPersonSprintLookSpeedX = mouse3rdPersonLookSpeedX * 2
    mouse3rdPersonLookSpeedY = GetSetting(2, 18)
    mouse3rdPersonSprintLookSpeedY = mouse3rdPersonLookSpeedY * 2

    gamepadLookSensitivityX = GetSetting(15, 3)
    gamepadSprintLookSensitivityX = gamepadLookSensitivityX * 2
    gamepadLookSensitivityY = GetSetting(15, 15)
    gamepadSprintLookSensitivityY = gamepadLookSensitivityY * 2

    if not isInGamepadMode then
      sprintingCheck(nil, hotbarSlot)
    end
  end
end

-- endregion


-- region [SWITCH INPUT MODE]

-- Checks if gamepad mode is turned on or off ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function gamepadModeCheck(eventCode, gamepadPreferred)

  -- UPDATES "isInGamepadMode" ---------------------------------------------------------------------
  isInGamepadMode = gamepadPreferred
  ----------------------------------------------------------------------------------------------

  -- DISABLES TIMERS ---------------------------------------------------------------------------
  sheathingWeaponTimer = false
  if rollDodgeTimer then CACHED_EVENT_MANAGER:UnregisterForEvent(SprintSensitivityFixName, EVENT_ACTION_SLOT_ABILITY_USED) end
  rollDodgeTimer = false
  ----------------------------------------------------------------------------------------------

  -- RUNS & POPULATES RESPECTIVE EVENTS & VARIABLES FOR THE CURRENT INPUT MODE -----------------
  if isInGamepadMode then
    isPlayerCrouched = GetUnitStealthState("player") > 0
    currentStamina = GetUnitPower("player", POWERTYPE_STAMINA)
    CACHED_EVENT_MANAGER:UnregisterForUpdate(loopEvent)
    CACHED_EVENT_MANAGER:UnregisterForEvent(SprintSensitivityFixName, EVENT_ACTION_SLOT_ABILITY_USED)
    CACHED_EVENT_MANAGER:UnregisterForEvent(SprintSensitivityFixName, EVENT_PLAYER_DEAD)
    CACHED_EVENT_MANAGER:UnregisterForEvent(SprintSensitivityFixName, EVENT_MOUNTED_STATE_CHANGED)
    CACHED_EVENT_MANAGER:UnregisterForEvent(SprintSensitivityFixName, EVENT_EFFECT_CHANGED)
    CACHED_EVENT_MANAGER:UnregisterForEvent(SprintSensitivityFixName, EVENT_PLAYER_STUNNED_STATE_CHANGED)
    CACHED_EVENT_MANAGER:UnregisterForEvent(SprintSensitivityFixName, EVENT_ACTION_SLOT_STATE_UPDATED)

    CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_ACTION_SLOT_ABILITY_USED, gamepadAbilityCastCheck)
    CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_ACTION_SLOT_ABILITY_USED_WRONG_WEAPON, gamepadAbilityCastCheck)
    CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_STEALTH_STATE_CHANGED, stealthCheck)
    CACHED_EVENT_MANAGER:AddFilterForEvent(SprintSensitivityFixName, EVENT_STEALTH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_POWER_UPDATE, staminaCheck)
    CACHED_EVENT_MANAGER:AddFilterForEvent(SprintSensitivityFixName, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
    CACHED_EVENT_MANAGER:AddFilterForEvent(SprintSensitivityFixName, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_STAMINA)
    CACHED_EVENT_MANAGER:RegisterForUpdate(loopEvent, 1, gamepadLoop)

  else
    isPlayerDead = IsUnitDeadOrReincarnating("player")
    isPlayerMounted = IsMounted()
    CACHED_EVENT_MANAGER:UnregisterForUpdate(loopEvent)
    CACHED_EVENT_MANAGER:UnregisterForEvent(SprintSensitivityFixName, EVENT_POWER_UPDATE)
    CACHED_EVENT_MANAGER:UnregisterForEvent(SprintSensitivityFixName, EVENT_STEALTH_STATE_CHANGED)
    CACHED_EVENT_MANAGER:UnregisterForEvent(SprintSensitivityFixName, EVENT_ACTION_SLOT_ABILITY_USED_WRONG_WEAPON)
    CACHED_EVENT_MANAGER:UnregisterForEvent(SprintSensitivityFixName, EVENT_ACTION_SLOT_ABILITY_USED)

    CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_ACTION_SLOT_STATE_UPDATED, sprintingCheck)
    CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_PLAYER_STUNNED_STATE_CHANGED, stunCheck)
    CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_EFFECT_CHANGED, rollDodgeCheck)
    CACHED_EVENT_MANAGER:AddFilterForEvent(SprintSensitivityFixName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_MOUNTED_STATE_CHANGED, playerMountedCheck)
    CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_PLAYER_DEAD, playerDeathCheck)
    CACHED_EVENT_MANAGER:RegisterForUpdate(loopEvent, 1, keyboardLoop)
  end
  ----------------------------------------------------------------------------------------------
end

-- endregion


-- region [START UP]

-- Function ran on startup that populates local values ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function startUp()

  CACHED_EVENT_MANAGER:UnregisterForEvent(SprintSensitivityFixName, EVENT_PLAYER_ACTIVATED)

  -- LOADS SETTINGS MENU & VALUES TO LOCAL VARIABLES -------------------------------------------
  SprintSensitivityFix.loadConfig()

  mouse1stPersonLookSpeedX = GetSetting(2, 3)
  mouse1stPersonSprintLookSpeedX = mouse1stPersonLookSpeedX * 2
  mouse1stPersonLookSpeedY = GetSetting(2, 3)
  mouse1stPersonSprintLookSpeedY = mouse1stPersonLookSpeedY * 2

  mouse3rdPersonLookSpeedX = GetSetting(2, 2)
  mouse3rdPersonSprintLookSpeedX = mouse3rdPersonLookSpeedX * 2
  mouse3rdPersonLookSpeedY = GetSetting(2, 2)
  mouse3rdPersonSprintLookSpeedY = mouse3rdPersonLookSpeedY * 2

  gamepadLookSensitivityX = GetSetting(15, 3)
  gamepadSprintLookSensitivityX = gamepadLookSensitivityX * 2
  gamepadLookSensitivityY = GetSetting(15, 15)
  gamepadSprintLookSensitivityY = gamepadLookSensitivityY * 2
  ----------------------------------------------------------------------------------------------


  -- CHECKS PLAYER WEAPONS ---------------------------------------------------------------------
  if GetItemWeaponType(BAG_WORN, EQUIP_SLOT_MAIN_HAND) == WEAPONTYPE_NONE then
    mainHotbarWeaponTimer = (GetItemWeaponType(BAG_WORN, EQUIP_SLOT_OFF_HAND) ~= WEAPONTYPE_NONE) and 1200 or 800
  else
    mainHotbarWeaponTimer = 1200
  end

  if GetItemWeaponType(BAG_WORN, EQUIP_SLOT_BACKUP_MAIN) == WEAPONTYPE_NONE then
    backupHotbarWeaponTimer = (GetItemWeaponType(BAG_WORN, EQUIP_SLOT_BACKUP_OFF) ~= WEAPONTYPE_NONE) and 1200 or 800
  else
    backupHotbarWeaponTimer = 1200
  end
  ----------------------------------------------------------------------------------------------


  -- CHECKS PLAYER STATES ----------------------------------------------------------------------
  isPlayerSwimming = IsUnitSwimming("player")

  isPlayerMounted = IsMounted()

  currentWeaponsSheathed = ArePlayerWeaponsSheathed()
  previousWeaponsSheathed = currentWeaponsSheathed
  ----------------------------------------------------------------------------------------------


  -- CHECKS CURRENT HOTBAR & HOTBAR SLOTS ------------------------------------------------------
  activeHotbar = GetActiveHotbarCategory()

  if activeHotbar == HOTBAR_CATEGORY_WEREWOLF or GetSlotBoundId(8) > 0 then
    hotbarSlot = 8

  else
    hotbarSlot = 1
  end
  ----------------------------------------------------------------------------------------------


  -- CHECKS CURRENT INPUT MODE, RUNS & POPULATES RESPECTIVE EVENTS & VARIABLES -----------------
  isInGamepadMode = GetSetting(15, 6) == "1"

  if isInGamepadMode then
    isPlayerCrouched = GetUnitStealthState("player") > 0
    currentStamina = GetUnitPower("player", POWERTYPE_STAMINA)
    CACHED_EVENT_MANAGER:RegisterForUpdate(loopEvent, 1, gamepadLoop)
    CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_ACTION_SLOT_ABILITY_USED, gamepadAbilityCastCheck)
    CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_ACTION_SLOT_ABILITY_USED_WRONG_WEAPON, gamepadAbilityCastCheck)
    CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_STEALTH_STATE_CHANGED, stealthCheck)
    CACHED_EVENT_MANAGER:AddFilterForEvent(SprintSensitivityFixName, EVENT_STEALTH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_POWER_UPDATE, staminaCheck)
    CACHED_EVENT_MANAGER:AddFilterForEvent(SprintSensitivityFixName, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
    CACHED_EVENT_MANAGER:AddFilterForEvent(SprintSensitivityFixName, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_STAMINA)

  else
    isPlayerDead = IsUnitDeadOrReincarnating("player")
    CACHED_EVENT_MANAGER:RegisterForUpdate(loopEvent, 1, keyboardLoop)
    CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_ACTION_SLOT_STATE_UPDATED, sprintingCheck)
    CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_PLAYER_STUNNED_STATE_CHANGED, stunCheck)
    CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_EFFECT_CHANGED, rollDodgeCheck)
    CACHED_EVENT_MANAGER:AddFilterForEvent(SprintSensitivityFixName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_PLAYER_DEAD, playerDeathCheck)
    CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_MOUNTED_STATE_CHANGED, playerMountedCheck)
  end

  CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, gamepadModeCheck)
  CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_RETICLE_HIDDEN_UPDATE, menuOpenCheck)
  CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, weaponTypeCheck)
  CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_CLIENT_INTERACT_RESULT, fastWeaponSheathCheck)
  CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_GAME_CAMERA_CHARACTER_FRAMING_STARTED, fastWeaponSheathCheck2)

  CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_PLAYER_SWIMMING, swimmingCheck)
  CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_PLAYER_NOT_SWIMMING, notSwimmingCheck)
  CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_CHATTER_END, notSwimmingCheck2)

  CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, hotbarSwapCheck)
  CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, skillSlottedCheck) -- EVENT_SKILL_RESPEC_RESULT (alternative)

  CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_PLAYER_DEACTIVATED, characterDisplacement)
  ----------------------------------------------------------------------------------------------
end

--endregion


-- Initialization ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CACHED_EVENT_MANAGER:RegisterForEvent(SprintSensitivityFixName, EVENT_PLAYER_ACTIVATED, startUp)
