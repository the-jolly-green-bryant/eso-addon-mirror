--[[
      HCMAddon main.
--]]
-------------------------------------------------------------------------------
-- Variables
-------------------------------------------------------------------------------
HCMAddon = {}
HCMAddon.id = "HyperionCombatMaster"

HCMAddon.inCombat = false
HCMAddon.activeLayerIndex = 0

HCMAddon.powerType = 0 -- magicka or stamina
HCMAddon.powerCalc = ""
HCMAddon.critDmgCalc = ""
HCMAddon.isMounted = false
HCMAddon.gameTime = 0
HCMAddon.caaTimeLastSwap = 0

HCMAddon.icons = {
  abi     = zo_iconFormat("/esoui/art/icons/placeholder/icon_offensive_shieldsword_01.dds", 24, 24),
  power   = zo_iconFormat("/esoui/art/icons/placeholder/icon_offense_fistraised_01.dds", 28, 28),
  gcdi    = zo_iconFormat("/esoui/art/icons/placeholder/icon_offense_speedstrike_01.dds", 24, 24),
  gcdi2   = zo_iconFormat("/esoui/art/icons/placeholder/icon_offense_weaponcharge_01.dds", 24, 24),
  magicka = zo_iconFormat("esoui/art/champion/champion_points_magicka_icon.dds", 16, 16),
  stamina = zo_iconFormat("esoui/art/champion/champion_points_stamina_icon.dds", 16, 16),
  health  = zo_iconFormat("/esoui/art/champion/champion_points_health_icon.dds", 16, 16),

  wText = {
    abi              = string.format("%s %s", zo_iconFormat("/esoui/art/icons/placeholder/icon_offensive_shieldsword_01.dds", 16, 16), "Active Bar"),
    power            = string.format("%s %s", zo_iconFormat("/esoui/art/icons/placeholder/icon_offense_fistraised_01.dds", 16, 16), "Power"),
    gcd              = string.format("%s %s", zo_iconFormat("/esoui/art/icons/placeholder/icon_offense_speedstrike_01.dds", 16, 16), "Global Cooldown"),
    gcdi             = string.format("%s %s", zo_iconFormat("/esoui/art/icons/placeholder/icon_offense_speedstrike_01.dds", 16, 16), "Type 1"),
    gcdi2            = string.format("%s %s", zo_iconFormat("/esoui/art/icons/placeholder/icon_offense_weaponcharge_01.dds", 16, 16), "Type 2"),
    magicka          = string.format("%s %s", zo_iconFormat("esoui/art/champion/champion_points_magicka_icon.dds", 16, 16), "Magicka"),
    stamina          = string.format("%s %s", zo_iconFormat("esoui/art/champion/champion_points_stamina_icon.dds", 16, 16), "Stamina"),
    ability_rm       = string.format("%s %s", zo_iconFormat("/esoui/art/icons/ability_ava_002.dds", 16, 16), "Rapid Maneuver"),
    major_berserk    = string.format("%s %s", zo_iconFormat("/esoui/art/icons/ability_buff_major_berserk.dds", 16, 16), "Major Berserk"),
    minor_berserk    = string.format("%s %s", zo_iconFormat("/esoui/art/icons/ability_buff_minor_berserk.dds", 16, 16), "Minor Berserk"),
    major_maim       = string.format("%s %s", zo_iconFormat("/esoui/art/icons/ability_debuff_major_maim.dds", 16, 16), "Major Maim"),
    minor_maim       = string.format("%s %s", zo_iconFormat("/esoui/art/icons/ability_debuff_minor_maim.dds", 16, 16), "Minor Maim"),
    major_expedition = string.format("%s %s", zo_iconFormat("/esoui/art/icons/ability_buff_major_expedition.dds", 16, 16), "Major Expedition"),
    major_gallop     = string.format("%s %s", zo_iconFormat("/esoui/art/icons/ability_buff_major_gallop.dds", 16, 16), "Major Gallop"),

  }
  --/esoui/art/icons/placeholder/icon_health_epic.dds
  --/esoui/art/icons/placeholder/icon_offense_swordtarget_01.dds
  --/esoui/art/icons/placeholder/icon_offense_swordglowing_01.dds
  --/esoui/art/icons/placeholder/icon_blank.dds
  --/esoui/art/icons/placeholder/icon_armor_shoulder01.dds
  --/esoui/art/inventory/inventory_tabicon_weapons_up.dds
  --/esoui/art/icons/placeholder/icon_offense_debuffarmor_01.dds target reductions
}

HCMAddon.savedVariables = {}
HCMAddon.charSV = {}
HCMAddon.accSV = {}
local savedVariablesId = "HCMAddonSavedVariables"
local savedVariablesVersion = 1.0
local savedVariablesNamespace = nil
local savedVariablesDefaults = { -- default settings
  general = {
    accountWideSettingsEnabled     = true
  },

  abi = { -- active bar indicator
    enabled                 = true,
    changeColorInCombat     = true,
    showOnlyInCombat        = false,
    showStockBarSwap        = true,
    color                   = {r=1,g=1,b=1,a=1}, -- white
    colorCombat             = {r=1,g=0,b=0,a=1}, -- red
    left                    = 500,
    top                     = 500,
    bar0                    = "1",
    bar1                    = "2"
  },

  ici = { -- in combat indicator
    enabled                 = false,
    left                    = 0,
    top                     = 0
  },

  powi = { -- power indicator
    enabled                 = true,
    includeCrit             = true,
    includePenetration      = true,
    includeBerserk          = true,
    includeMaim             = true,
    left                    = 500,
    top                     = 600
  },

  gcdi = { -- global cooldown indicator
    enabled                 = true,
    showDetailed            = true,
    showOnlyInCombat        = false,
    colorNoCd               = {r=0.254,g=0.827,b=0.266,a=1},  -- green
    colorLowCd              = {r=1,g=0.5,b=0,a=1},            -- orange
    colorOnCd               = {r=1,g=0,b=0,a=1},              -- red
    updateInterval          = 50,                             -- update every updateInterval ms
    left                    = 600,
    top                     = 500
  },

  rma = { -- rapid maneuver auto-assist
    enabled                 = true,
    swapOnFoot              = true,
    currentlySwapped        = false,
    barSwappedOn            = -1,
    slotSwappedOn           = -1,
    slotToSwap              = 2,
    recoveryTimeMs          = 1000,
    maneuverAbilityId       = 0,
    replacedAbilityId       = 0
  },

  caa = { -- custom ability auto-assist
    enabled                 = false,
    currentlySwapped        = false,
    barSwappedOn            = -1,
    slotSwappedOn           = -1,
    slotToSwap              = 1,
    recoveryTimeMs          = 1000,
    chosenAbilityId         = 0,
    replacedAbilityId       = 0
  }
}
-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------
function HCMAddon:Initialize()

  --https://esodata.uesp.net/100016/src/libraries/utility/zo_savedvars.lua.html
  HCMAddon.charSV = ZO_SavedVars:New(savedVariablesId, savedVariablesVersion, savedVariablesNamespace, savedVariablesDefaults)
  HCMAddon.accSV = ZO_SavedVars:NewAccountWide(savedVariablesId, savedVariablesVersion, savedVariablesNamespace, savedVariablesDefaults)
  if not HCMAddon.charSV.general.accountWideSettingsEnabled then
    HCMAddon.savedVariables = HCMAddon.charSV
  elseif HCMAddon.charSV.general.accountWideSettingsEnabled then
    HCMAddon.savedVariables = HCMAddon.accSV
  end

  ActiveBarIndicator:SetHidden(true)
  InCombatIndicator:SetHidden(true)
  PowerIndicator:SetHidden(true)
  CriticalPowerIndicator:SetHidden(true)
  GlobalCooldownIndicator:SetHidden(true)

  if HCMAddon.savedVariables.abi.enabled then
    HCMAddon:UpdateActiveHotBarCategory()
    ActiveBarIndicator:ClearAnchors()
    ActiveBarIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, HCMAddon.savedVariables.abi.left, HCMAddon.savedVariables.abi.top)
  end

  if HCMAddon.savedVariables.ici.enabled then
    InCombatIndicator:ClearAnchors()
    InCombatIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, HCMAddon.savedVariables.ici.left, HCMAddon.savedVariables.ici.top)
  end

  if HCMAddon.savedVariables.powi.enabled then
    EVENT_MANAGER:RegisterForUpdate("HCM_U_POWI", 250, HCMAddon.UpdatePowerIndicator)
    HCMAddon:UpdatePowerIndicator()
    PowerIndicator:ClearAnchors()
    PowerIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, HCMAddon.savedVariables.powi.left, HCMAddon.savedVariables.powi.top)
    PowerIndicator:SetHidden(false)
  end

  if HCMAddon.savedVariables.gcdi.enabled then
    EVENT_MANAGER:RegisterForUpdate("HCM_U_GCDI", HCMAddon.savedVariables.gcdi.updateInterval, HCMAddon.UpdateGlobalCooldownIndicator)
    HCMAddon.UpdateGlobalCooldownIndicator()
    GlobalCooldownIndicator:ClearAnchors()
    GlobalCooldownIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, HCMAddon.savedVariables.gcdi.left, HCMAddon.savedVariables.gcdi.top)
    GlobalCooldownIndicator:SetHidden(false)
    GlobalCooldownIndicatorLabel:SetHidden(false)
  end

--[[
  if HCMAddon.savedVariables.criti.enabled then
    EVENT_MANAGER:RegisterForUpdate(_, 200, HCMAddon.UpdateCriticalPowerIndicator)
    HCMAddon:UpdateCriticalPowerIndicator()
    CriticalPowerIndicator:ClearAnchors()
    CriticalPowerIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, HCMAddon.savedVariables.criti.left, HCMAddon.savedVariables.criti.top)
    CriticalPowerIndicator:SetHidden(false)
  end
]]--

  HCMAddon:UpdateActionBarWeaponSwapButton()
  HCMAddon:UpdatePlayerCombatState()
end

function HCMAddon.OnAddOnLoaded(event, addonName)
  -- Fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == HCMAddon.id then
    HCMAddon:Initialize()
    HCMAddon:RegisterAddonMenu() -- AddonMenu.lua
    EVENT_MANAGER:UnregisterForEvent(HCMAddon.id, EVENT_ADD_ON_LOADED)
  end
end

-- activeLayerIndex: playing = 2, game menus = 3, crown store = 4, esc menus = 5, higher is higher priority(?)
function HCMAddon.OnActionLayerChange(event, layerIndex, activeLayerIndex)
  HCMAddon.activeLayerIndex = activeLayerIndex

  if HCMAddon.savedVariables.abi.enabled then
    if HCMAddon.savedVariables.abi.showOnlyInCombat then
      if HCMAddon.inCombat then
        ActiveBarIndicator:SetHidden(activeLayerIndex > 2)
      elseif not HCMAddon.inCombat then
        ActiveBarIndicator:SetHidden(true)
      end
    elseif not HCMAddon.savedVariables.abi.showOnlyInCombat then
      ActiveBarIndicator:SetHidden(activeLayerIndex > 2)
    end
  end

  if HCMAddon.savedVariables.ici.enabled then
    if HCMAddon.inCombat then
      InCombatIndicator:SetHidden(activeLayerIndex == 2)
    elseif not HCMAddon.inCombat then
      InCombatIndicator:SetHidden(true)
    end
  end

  if HCMAddon.savedVariables.powi.enabled then
    PowerIndicator:SetHidden(activeLayerIndex > 2)
  end

  if HCMAddon.savedVariables.gcdi.enabled then
    if HCMAddon.savedVariables.gcdi.showOnlyInCombat then
      if HCMAddon.inCombat then
        GlobalCooldownIndicator:SetHidden(activeLayerIndex > 2)
      elseif not HCMAddon.inCombat then
        GlobalCooldownIndicator:SetHidden(true)
      end
    elseif not HCMAddon.savedVariables.gcdi.showOnlyInCombat then
      GlobalCooldownIndicator:SetHidden(activeLayerIndex > 2)
    end
  end

end

function HCMAddon.OnPlayerCombatState(event, inCombat)
  if inCombat ~= HCMAddon.inCombat then
    HCMAddon:UpdatePlayerCombatState()
  end
end

function HCMAddon.UpdatePlayerCombatState()
  HCMAddon.inCombat = IsUnitInCombat("player")

  if HCMAddon.savedVariables.abi.enabled then
    if HCMAddon.savedVariables.abi.showOnlyInCombat then
      if HCMAddon.inCombat then
        ActiveBarIndicator:SetHidden(HCMAddon.activeLayerIndex > 2)
      elseif not HCMAddon.inCombat then
        ActiveBarIndicator:SetHidden(true)
      end
    elseif not HCMAddon.savedVariables.abi.showOnlyInCombat then
      ActiveBarIndicator:SetHidden(false)
    end

    if HCMAddon.savedVariables.abi.changeColorInCombat then
      if HCMAddon.inCombat then
        -- SetColor takes normalized rgba values (range 0-1)
        local color = HCMAddon.savedVariables.abi.colorCombat
        ActiveBarIndicatorLabel:SetColor(color.r,color.g,color.b,color.a)
        ActiveBarIndicatorLabel2:SetColor(color.r,color.g,color.b,color.a)
      elseif not HCMAddon.inCombat then
        local color = HCMAddon.savedVariables.abi.color
        ActiveBarIndicatorLabel:SetColor(color.r,color.g,color.b,color.a)
        ActiveBarIndicatorLabel2:SetColor(color.r,color.g,color.b,color.a)
      end
    end
  end

  if HCMAddon.savedVariables.ici.enabled and
     HCMAddon.inCombat then
    InCombatIndicator:SetHidden(HCMAddon.activeLayerIndex == 2)
  end

  if HCMAddon.savedVariables.gcdi.enabled then
    if HCMAddon.savedVariables.gcdi.showOnlyInCombat then
      if HCMAddon.inCombat then
        GlobalCooldownIndicator:SetHidden(HCMAddon.activeLayerIndex > 2)
      elseif not HCMAddon.inCombat then
        GlobalCooldownIndicator:SetHidden(true)
      end
    elseif not HCMAddon.savedVariables.gcdi.showOnlyInCombat then
      GlobalCooldownIndicator:SetHidden(false)
    end
  end

end


function HCMAddon.UpdateGlobalCooldownIndicator()
  local timeRemain = GetSlotCooldownInfo(1)
  local timeRemain2 = 0
  for slot=3,8 do                             -- test next ones if slot is empty
    timeRemain2 = GetSlotCooldownInfo(slot)
    if timeRemain2 > 0 then break end
  end

  if HCMAddon.savedVariables.gcdi.showDetailed then
    local s = string.format("%s %i %s %i",
    HCMAddon.icons.gcdi, math.floor(timeRemain/100),
    HCMAddon.icons.gcdi2, math.floor(timeRemain2/100))
    GlobalCooldownIndicatorLabel:SetText(s)
  else
    local s = string.format("%s %s",
    HCMAddon.icons.gcdi, "GCD")
    GlobalCooldownIndicatorLabel:SetText(s)
  end

  local freq = HCMAddon.savedVariables.gcdi.updateInterval
  local color = {}
  if timeRemain == 0 and timeRemain2 == 0 then
    color = HCMAddon.savedVariables.gcdi.colorNoCd
  elseif timeRemain2 <= 300 then                      -- TODO: find exact point when you can attack again?
    color = HCMAddon.savedVariables.gcdi.colorLowCd
  elseif timeRemain > 0 or timeRemain2 > 300 then
    color = HCMAddon.savedVariables.gcdi.colorOnCd
  end
  GlobalCooldownIndicatorLabel:SetColor(color.r,color.g,color.b,color.a)
end

function HCMAddon.OnActionSlotUpdate(event, didActiveHotbarChange, shouldUpdateAbilityAssignments, activeHotbarCategory)
  if didActiveHotbarChange then
    HCMAddon:UpdateActiveHotBarCategory()
    if HCMAddon.savedVariables.rma.enabled then HCMAddon:UpdateRapidManeuver() end
    if HCMAddon.savedVariables.caa.enabled then HCMAddon:UpdateSlotSkillAutoAssist() end
  end
end

--[[ activeHotbarCategory values:
    primary       = 0,
    backup        = 1,
                  = 7,
    werewolf      = 8,
                  = 9
--]]
function HCMAddon.UpdateActiveHotBarCategory()
  activeHotbarCategory = GetActiveHotbarCategory()
  if activeHotbarCategory == 0 then
    ActiveBarIndicatorLabel:SetText(string.format("%s %s",HCMAddon.icons.abi, HCMAddon.savedVariables.abi.bar0))
  elseif activeHotbarCategory == 1 then
    ActiveBarIndicatorLabel:SetText(string.format("%s %s",HCMAddon.icons.abi, HCMAddon.savedVariables.abi.bar1))
  end
end

function HCMAddon.OnActionSlotAbilityUse(event, actionSlotIndex)
  if HCMAddon.savedVariables.rma.enabled then
    if GetSlotBoundId(actionSlotIndex) == HCMAddon.savedVariables.rma.maneuverAbilityId then
      HCMAddon:UnslotRapidManeuver()  -- unslot when rm is used
    end
  end
  if HCMAddon.savedVariables.caa.enabled then
    if GetSlotBoundId(actionSlotIndex) == HCMAddon.savedVariables.caa.chosenAbilityId then
      HCMAddon.caaTimeLastSwap = HCMAddon.gameTime
      HCMAddon:UnslotSkill(HCMAddon.savedVariables.caa.chosenAbilityId)  -- unslot when skill is used
    end
  end

end

function HCMAddon.OnMountedStateChange(event, mounted)
  if HCMAddon.savedVariables.rma.enabled then
    if not HCMAddon.isMounted and mounted then HCMAddon.SlotRapidManeuver() end   -- slot on mount
    if HCMAddon.isMounted and not mounted then HCMAddon.UnslotRapidManeuver() end -- unslot on dismount
  end
  HCMAddon.isMounted = mounted
end

function HCMAddon.UpdateRapidManeuver()
  if not HCMAddon.savedVariables.rma.swapOnFoot then
    if HCMAddon.savedVariables.rma.currentlySwapped then HCMAddon:UnslotRapidManeuver() return end  -- on foot disabled but RM still on bar
    if not HCMAddon.isMounted then return end                                    -- on foot disabled and is on foot
  end

  if not HCMAddon.savedVariables.rma.currentlySwapped then
    HCMAddon:SlotRapidManeuver()
  elseif HCMAddon.savedVariables.rma.currentlySwapped then
    HCMAddon:UnslotRapidManeuver()
  end
end

function HCMAddon.SlotRapidManeuver()
  if HCMAddon.inCombat then return end
  if HCMAddon.savedVariables.rma.currentlySwapped then return end
  HCMAddon.savedVariables.rma.currentlySwapped = true -- ACCORDING TO A BRILLIANT BRANCH OF COMPUTER SCIENCE KNOWN AS CONCURRENCY, THIS IS REFERRED TO AS A BINARY SEMAPHORE. PRAISE DIJKSTRA.
  zo_callLater(function() HCMAddon.UnslotRapidManeuver() end, HCMAddon.savedVariables.rma.recoveryTimeMs)

  local rmInfo = {st=6,sl=1,si=2} -- rapid maneuver skill info
  local rmId = GetSkillAbilityId(rmInfo.st,rmInfo.sl,rmInfo.si,false)
  HCMAddon.savedVariables.rma.maneuverAbilityId = rmId

  -- check if has enough stamina to cast
  local currentStam = GetUnitPower("player", POWERTYPE_STAMINA)
  if currentStam < GetAbilityCost(rmId) then return end

  -- check if already slotted
  for bar = 0, 1 do
    for slot = 3, 8 do
      if GetSlotBoundId(slot,bar) == rmId then return end
    end
  end

  -- check if speed buff is already active
  for i=1, GetNumBuffs("player") do
    local texn = select(6,GetUnitBuffInfo("player",i))
    if texn == Buffs.TEXTURENAMES.MAJOR_GALLOP and HCMAddon.isMounted then return end
    if texn == Buffs.TEXTURENAMES.MAJOR_EXPEDITION and not HCMAddon.isMounted then return end
  end

  local swapSlot = HCMAddon.savedVariables.rma.slotToSwap+2
  HCMAddon.savedVariables.rma.replacedAbilityId = GetSlotBoundId(swapSlot)
  SlotSkillAbilityInSlot(rmInfo.st,rmInfo.sl,rmInfo.si,swapSlot)
  HCMAddon.savedVariables.rma.barSwappedOn = GetActiveHotbarCategory()
  HCMAddon.savedVariables.rma.slotSwappedOn = swapSlot
end

function HCMAddon.UnslotRapidManeuver()
  if HCMAddon.inCombat then return end
  if not HCMAddon.savedVariables.rma.currentlySwapped then return end
  HCMAddon.savedVariables.rma.currentlySwapped = false

  if HCMAddon.savedVariables.rma.barSwappedOn == GetActiveHotbarCategory() then
    if GetSlotBoundId(HCMAddon.savedVariables.rma.slotSwappedOn) ~= HCMAddon.savedVariables.rma.maneuverAbilityId then return end

    local st, sl, si = HCMAddon.GetSkillInfoByAbilityId(HCMAddon.savedVariables.rma.replacedAbilityId)
    SlotSkillAbilityInSlot(st,sl,si,HCMAddon.savedVariables.rma.slotSwappedOn)
    HCMAddon.savedVariables.rma.replacedAbilityId = 0
    HCMAddon.savedVariables.rma.barSwappedOn = -1
    HCMAddon.savedVariables.rma.slotSwappedOn = -1
  end
end

function HCMAddon.UpdateSlotSkillAutoAssist()
  if HCMAddon.inCombat then return end
  if not HCMAddon.savedVariables.caa.currentlySwapped then
    HCMAddon:SlotSkill(HCMAddon.savedVariables.caa.chosenAbilityId)
    zo_callLater(function() HCMAddon.UnslotSkill(HCMAddon.savedVariables.caa.chosenAbilityId) end, HCMAddon.savedVariables.caa.recoveryTimeMs)
  elseif HCMAddon.savedVariables.caa.currentlySwapped then
    HCMAddon:UnslotSkill(HCMAddon.savedVariables.caa.chosenAbilityId)
  end
end

function HCMAddon.SlotSkill(abilityId)
  HCMAddon.savedVariables.caa.currentlySwapped = true

  HCMAddon.gameTime = GetGameTimeMilliseconds()
  if HCMAddon.gameTime - HCMAddon.caaTimeLastSwap < GetAbilityDuration(HCMAddon.savedVariables.caa.chosenAbilityId) then return end

  local st, sl, si = HCMAddon.GetSkillInfoByAbilityId(HCMAddon.savedVariables.caa.chosenAbilityId)
  local swapSlot = HCMAddon.savedVariables.caa.slotToSwap+2
  HCMAddon.savedVariables.caa.replacedAbilityId = GetSlotBoundId(swapSlot)
  SlotSkillAbilityInSlot(st,sl,si,swapSlot)
  HCMAddon.savedVariables.caa.barSwappedOn = GetActiveHotbarCategory()
  HCMAddon.savedVariables.caa.slotSwappedOn = swapSlot
end

function HCMAddon.UnslotSkill(abilityId) -- TODO: TEST THIS FEATURE.
  HCMAddon.savedVariables.caa.currentlySwapped = false

  if HCMAddon.savedVariables.caa.barSwappedOn == GetActiveHotbarCategory() then
    if GetSlotBoundId(HCMAddon.savedVariables.caa.slotSwappedOn) ~= HCMAddon.savedVariables.caa.chosenAbilityId then return end

    local st, sl, si = HCMAddon.GetSkillInfoByAbilityId(HCMAddon.savedVariables.caa.replacedAbilityId)
    SlotSkillAbilityInSlot(st,sl,si,HCMAddon.savedVariables.caa.slotSwappedOn)
    HCMAddon.savedVariables.caa.replacedAbilityId = 0
    HCMAddon.savedVariables.caa.barSwappedOn = -1
    HCMAddon.savedVariables.caa.slotSwappedOn = -1
  end
end


-- skills count from top to bottom on UI
-- skillType: Class/Weapon/Armor/...
-- skillLineIndex: skillType submenu
-- skillIndex: aka abilities. ults then actives then passives
-- actionSlotIndex: (1 = light atk, 2 = heavy atk), 3 = 1st slot, 4 = 2nd slot, ..., 8 = ult
function HCMAddon.GetSkillInfoByAbilityId(abilityId)
  local hasProgression, progressionIndex = GetAbilityProgressionXPInfoFromAbilityId(abilityId)
  if not hasProgression then return 0,0,0 end

  local st, sl, si = GetSkillAbilityIndicesFromProgressionIndex(progressionIndex)
  if st > 0 then return st, sl, si end

  for st = 1, GetNumSkillTypes() do
    for sl = 1, GetNumSkillLines(st) do
      for si = 1, GetNumSkillAbilities(st, sl) do
        local progressionIdx = select(7, GetSkillAbilityInfo(st, sl, si))
        if progressionIdx == progressionIndex then return st, sl, si end
      end
    end
  end
  return 0,0,0
end

function HCMAddon.OnActiveBarIndicatorMoveStop()
  HCMAddon.savedVariables.abi.left = ActiveBarIndicator:GetLeft()
  HCMAddon.savedVariables.abi.top = ActiveBarIndicator:GetTop()
end

function HCMAddon.OnInCombatIndicatorMoveStop()
  HCMAddon.savedVariables.ici.left = InCombatIndicator:GetLeft()
  HCMAddon.savedVariables.ici.top = InCombatIndicator:GetTop()
end

function HCMAddon.OnPowerIndicatorMoveStop()
  HCMAddon.savedVariables.powi.left = PowerIndicator:GetLeft()
  HCMAddon.savedVariables.powi.top = PowerIndicator:GetTop()
end

function HCMAddon.OnCriticalPowerIndicatorMoveStop()
  HCMAddon.savedVariables.criti.left = CriticalPowerIndicator:GetLeft()
  HCMAddon.savedVariables.criti.top = CriticalPowerIndicator:GetTop()
end

function HCMAddon.OnGlobalCooldownIndicatorMoveStop()
  HCMAddon.savedVariables.gcdi.left = GlobalCooldownIndicator:GetLeft()
  HCMAddon.savedVariables.gcdi.top = GlobalCooldownIndicator:GetTop()
end

function HCMAddon.UpdatePowerIndicator()
  local mag = GetPlayerStat(STAT_MAGICKA_MAX)
  local spelldmg = GetPlayerStat(STAT_SPELL_POWER)
  local stam = GetPlayerStat(STAT_STAMINA_MAX)
  local wepdmg = GetPlayerStat(STAT_POWER)
  local mpow = mag/10.5+spelldmg
  local ppow = stam/10.5+wepdmg
  local base_pow = math.max(mpow,ppow)

  local pow_type = 0
  if     base_pow == mpow then pow_type = POWERTYPE_MAGICKA
  elseif base_pow == ppow then pow_type = POWERTYPE_STAMINA
  end
  HCMAddon.powerType = pow_type

  local powtext = "POWER"
  local pow_type_sign = ""
  if pow_type == POWERTYPE_MAGICKA then
    powtext = string.format("%s %s", powtext, HCMAddon.icons.magicka)
    pow_type_sign = "Magical"
  elseif pow_type == POWERTYPE_STAMINA then
    powtext = string.format("%s %s", powtext, HCMAddon.icons.stamina)
    pow_type_sign = "Physical"
  end

  local critAvg = 0
  if HCMAddon.savedVariables.powi.includeCrit then
    CRIT_RATING_RATIO = 219 -- equals 1% hit chance
    local critDmg_p, critDmg_m = HCMAddon:GetCriticalDamageModifiers()
    critDmg_p = critDmg_p/100
    critDmg_m = critDmg_m/100
    local critChance = 0
    if pow_type == POWERTYPE_MAGICKA then
      critChance = GetPlayerStat(STAT_SPELL_CRITICAL)/CRIT_RATING_RATIO/100
      critAvg = critChance*critDmg_m
    elseif pow_type == POWERTYPE_STAMINA then
      critChance = GetPlayerStat(STAT_CRITICAL_STRIKE)/CRIT_RATING_RATIO/100
      critAvg = critChance*critDmg_p
    end
    local critAvg = math.floor(critAvg*1000+0.5)/1000 -- round to 3 decimals
  end

  -- 660 pen = 1% dmg on cp160=lv66 player.
  -- 500 pen = 1% dmg on lv50 mob. chosen default, since pve is more common
  local pen_bonus = 0
  if HCMAddon.savedVariables.powi.includePenetration then
    local pen_k = 0
    TARGET_LVL = 50
    if pow_type == POWERTYPE_MAGICKA then
      pen_k = GetPlayerStat(STAT_SPELL_PENETRATION)/1000
    elseif pow_type == POWERTYPE_STAMINA then
      pen_k = GetPlayerStat(STAT_PHYSICAL_PENETRATION)/1000
    end
    pen_bonus = pen_k/TARGET_LVL
    pen_bonus = math.floor(pen_bonus*1000+0.5)/1000 -- round to 3 decimals
  end

  local zerk_bonus = 0
  if HCMAddon.savedVariables.powi.includeBerserk then
    for i=1, GetNumBuffs("player") do
      local texn = select(6,GetUnitBuffInfo("player",i))
      if     texn == Buffs.TEXTURENAMES.MINOR_BERSERK then zerk_bonus = zerk_bonus+0.08
      elseif texn == Buffs.TEXTURENAMES.MAJOR_BERSERK then zerk_bonus = zerk_bonus+0.25
      end
    end
  end

  local maim_bonus = 0
  if HCMAddon.savedVariables.powi.includeMaim then
    for i=1, GetNumBuffs("player") do
      local texn = select(6,GetUnitBuffInfo("player",i))
      if     texn == Buffs.TEXTURENAMES.MINOR_MAIM then maim_bonus = maim_bonus+0.15
      elseif texn == Buffs.TEXTURENAMES.MAJOR_MAIM then maim_bonus = maim_bonus+0.30
      end
    end
  end

  local power = math.floor(base_pow*(1+critAvg)*(1+pen_bonus)*(1+zerk_bonus)*(1-maim_bonus))

  PowerIndicatorLabel2:SetText(powtext)
  PowerIndicatorLabel:SetText(string.format("%i",power))

  HCMAddon.powerCalc = string.format("%s Power: %i (Base: %i", pow_type_sign, math.floor(power), math.floor(base_pow))
  if critAvg > 0 then
    HCMAddon.powerCalc = string.format("%s Critical: +%.1f%%", HCMAddon.powerCalc, 100*critAvg)
  end
  if pen_bonus > 0 then
    HCMAddon.powerCalc = string.format("%s Penetration: +%.1f%%", HCMAddon.powerCalc, 100*pen_bonus)
  end
  if zerk_bonus > 0 then
    HCMAddon.powerCalc = string.format("%s Berserk: +%.1f%%", HCMAddon.powerCalc, 100*zerk_bonus)
  end
  if maim_bonus > 0 then
    HCMAddon.powerCalc = string.format("%s Maim: -%.1f%%", HCMAddon.powerCalc, 100*maim_bonus)
  end
    HCMAddon.powerCalc = string.format("%s)",HCMAddon.powerCalc)
end

function HCMAddon.UpdateCriticalPowerIndicator()
  local critChance = GetPlayerStat(STAT_CRITICAL_STRIKE)/219/100
  local critDmg = HCMAddon:GetCriticalDamageModifiers()/100
  local critAvg = math.floor((1+critChance*critDmg)*100+0.5)/100 -- calculate and round to two decimals
  CriticalPowerIndicatorLabel:SetText(critAvg)
end

local function GetDivinesBonus()
  local gear_slots = {EQUIP_SLOT_HEAD, EQUIP_SLOT_CHEST, EQUIP_SLOT_SHOULDERS, EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS, EQUIP_SLOT_FEET, EQUIP_SLOT_HAND}	-- {0,2,3,6,8,9,16}
	local bonus = 0
	for _,i in pairs(gear_slots) do
    local tt, td = GetItemLinkTraitInfo(GetItemLink(BAG_WORN,i))
		if tt == ITEM_TRAIT_TYPE_ARMOR_DIVINES then
      bonus = bonus+(tonumber(string.sub(td,string.find(td,"%d.%d"))) or 0)
    end
	end
	return bonus/100 -- mundus stone effect modifier from Divines, 1 legendary = +0.075
end

function HCMAddon.GetCriticalDamageModifiers()
  local base_bonus = 50

  local force_bonus = 0
  local shadow_bonus = 0
  SHADOW_DMG_BONUS = 13 -- shadow increases Critical Damage by this amount
	for i=1, GetNumBuffs("player") do
    local texn = select(6,GetUnitBuffInfo("player",i))
    if     texn == Buffs.TEXTURENAMES.MINOR_FORCE then force_bonus = force_bonus+10
    elseif texn == Buffs.TEXTURENAMES.MAJOR_FORCE then force_bonus = force_bonus+15
		elseif texn == Buffs.TEXTURENAMES.BOON_SHADOW then shadow_bonus = math.floor(SHADOW_DMG_BONUS*(1+GetDivinesBonus()))
    end
  end

  local class_bonus = 0 -- from class passive
	local class = GetUnitClassId("player")
	local ability_slotted = 0
	local ability_equipped = {}
  CLASS_CRIT_PER_SKILL_LEVEL = 5
	if class == 3 or class == 6 then	-- if nb or templar
		for i = 1, 6 do -- check nb assasination abilities or templar aedric spear abilities
			id = GetSkillAbilityId(1,1,i)
			ability_equipped[id] = true
		end
		for i = 3, 8 do
			if ability_equipped[GetSlotBoundId(i)] then ability_slotted = 1 break end
		end
		passive_level = GetSkillAbilityUpgradeInfo(1,1,(class == 3 and 10 or 7))
		class_bonus = CLASS_CRIT_PER_SKILL_LEVEL*passive_level*ability_slotted
	end

	local race_bonus = 0 -- from racial (only khajiit)
  RACE_CRIT_PER_SKILL_LEVEL = 1/3*10 -- 3%/6%/10%
	if GetUnitRaceId("player") == 9 then
		passive_level = GetSkillAbilityUpgradeInfo(7,1,4)
		race_bonus = math.floor(RACE_CRIT_PER_SKILL_LEVEL*passive_level)
	end

  local crit_bonus = base_bonus + force_bonus + shadow_bonus + class_bonus + race_bonus

	local n_preciseStrikes = GetNumPointsSpentOnChampionSkill(5,2)/100
	local n_elfborn = GetNumPointsSpentOnChampionSkill(7,3)/100
  local cp_phy_bonus = math.floor(0.25*n_preciseStrikes*(2-n_preciseStrikes)*100)
  local cp_mag_bonus = math.floor(0.25*n_elfborn*(2-n_elfborn)*100)

  local crit_tot = 0
  pow_type = HCMAddon.powerType
  if pow_type == POWERTYPE_MAGICKA then
    crit_tot = crit_bonus+cp_mag_bonus
  elseif pow_type == POWERTYPE_STAMINA then
    crit_tot = crit_bonus+cp_phy_bonus
  end

  HCMAddon.critDmgCalc = string.format("Critical Damage: +%.1f%% (Base: %.0f%% Force: %.0f%% Shadow: %.0f%% Class: %.0f%% Race: %.0f%%",
  crit_tot, base_bonus, force_bonus, shadow_bonus, class_bonus, race_bonus)
  if cp_phy_bonus > 0 then
    HCMAddon.critDmgCalc = string.format("%s Precise Strikes: %.0f%%", HCMAddon.critDmgCalc, cp_phy_bonus)
  end
  if cp_mag_bonus > 0 then
    HCMAddon.critDmgCalc = string.format("%s Elfborn: %.0f%%", HCMAddon.critDmgCalc, cp_mag_bonus)
  end
  HCMAddon.critDmgCalc = string.format("%s)", HCMAddon.critDmgCalc)

	return (crit_bonus + cp_phy_bonus),
         (crit_bonus + cp_mag_bonus)
end

function HCMAddon.UpdateActionBarWeaponSwapButton()
  local showButton = HCMAddon.savedVariables.abi.showStockBarSwap
  if showButton then
    ZO_WeaponSwap_SetPermanentlyHidden(ZO_ActionBar1:GetNamedChild("WeaponSwap"), false)
  elseif not showButton then
    ZO_WeaponSwap_SetPermanentlyHidden(ZO_ActionBar1:GetNamedChild("WeaponSwap"), true)
  end
end


function HCMAddon.PostPower()
  StartChatInput(string.format("[%s] %s for %s (%s %s)",
  "Combat Master", HCMAddon.powerCalc, GetUnitName("player"), GetUnitRace("player"), GetUnitClass("player")))
  end

function HCMAddon.PostCriticalDamage()
  StartChatInput(string.format("[%s] %s for %s (%s %s)",
  "Combat Master", HCMAddon.critDmgCalc, GetUnitName("player"), GetUnitRace("player"), GetUnitClass("player")))
end

-------------------------------------------------------------------------------
-- Listeners
-------------------------------------------------------------------------------


EVENT_MANAGER:RegisterForEvent(HCMAddon.id, EVENT_ADD_ON_LOADED, HCMAddon.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(HCMAddon.id, EVENT_ACTION_LAYER_POPPED, HCMAddon.OnActionLayerChange)                -- used by: gui
EVENT_MANAGER:RegisterForEvent(HCMAddon.id, EVENT_ACTION_LAYER_PUSHED, HCMAddon.OnActionLayerChange)                -- used by: gui
EVENT_MANAGER:RegisterForEvent(HCMAddon.id, EVENT_PLAYER_COMBAT_STATE, HCMAddon.OnPlayerCombatState)                -- used by: all
EVENT_MANAGER:RegisterForEvent(HCMAddon.id, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, HCMAddon.OnActionSlotUpdate)  -- used by: abi, rma
EVENT_MANAGER:RegisterForEvent(HCMAddon.id, EVENT_ACTION_SLOT_ABILITY_USED, HCMAddon.OnActionSlotAbilityUse)        -- used by: rma
EVENT_MANAGER:RegisterForEvent(HCMAddon.id, EVENT_MOUNTED_STATE_CHANGED, HCMAddon.OnMountedStateChange)             -- used by: rma

--COMBAT_EVENT params:
--number eventCode, number ActionResult result, boolean isError, string abilityName,
--number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName,
--number CombatUnitType sourceType, string targetName, number CombatUnitType targetType,
--number hitValue, number CombatMechanicType powerType, number DamageType damageType,
--boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
-- total 18 params
--[[
function HCMAddon.OnCombatEvent(_,_,_,abilityName,
                                _,_,_,
                                _,targetName,_,
                                hitVal,_,_,
                                _,sourceUnitId,targetUnitId,abilityId,_)
  --d(string.format("abName:%s - abId:%s - sourceUnitId:%s - targUId: %s",abilityName,abilityId,sourceUnitId,targetUnitId))
end
]]--
--EVENT_MANAGER:RegisterForEvent(HCMAddon.id, EVENT_COMBAT_EVENT, HCMAddon.OnCombatEvent)

-------------------------------------------------------------------------------
-- Commands
-------------------------------------------------------------------------------
SLASH_COMMANDS["/power"] = HCMAddon.PostPower
SLASH_COMMANDS["/critdmg"] = HCMAddon.PostCriticalDamage
