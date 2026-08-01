--[[----------------------------------------------------------
    PLAYER DATA COMPONENT
  ]]----------------------------------------------------------
local FTC = FTC
FTC.Player = {}

--[[
 * Initialize Player Data Table
 * --------------------------------
 * Called by FTC:Initialize()
 * --------------------------------
 ]]--
function FTC.Player:Initialize()

  -- Setup initial character information
  FTC.Player.name = GetUnitName('player')
  FTC.Player.race = GetUnitRace('player')
  FTC.Player.class = GetUnitClass('player')
  FTC.Player:GetLevel()

  -- Load starting attributes
  local stats = {
    { ["name"] = "health", ["id"] = COMBAT_MECHANIC_FLAGS_HEALTH },
    { ["name"] = "magicka", ["id"] = COMBAT_MECHANIC_FLAGS_MAGICKA },
    { ["name"] = "stamina", ["id"] = COMBAT_MECHANIC_FLAGS_STAMINA },
    { ["name"] = "ultimate", ["id"] = COMBAT_MECHANIC_FLAGS_ULTIMATE }
  }
  for i = 1, #stats, 1 do
    local current, maximum, effMax = GetUnitPower("player", stats[i].id)
    FTC.Player[stats[i].name] = { ["current"] = current, ["max"] = maximum, ["pct"] = zo_roundToNearest(current / maximum, 0.01) }
  end

  -- Load starting shield
  local value, maxValue = GetUnitAttributeVisualizerEffectInfo('player', ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH)
  FTC.Player.shield = { ["current"] = value or 0, ["max"] = maxValue or 0, ["pct"] = zo_roundToNearest((value or 0) / (maxValue or 0), 0.01) }

  -- Load quickslot ability
  FTC.Player:GetQuickslot()
  local _, _, canPotion = GetSlotCooldownInfo(GetCurrentQuickslot())
  FTC.Player.canPotion = canPotion
end


--[[----------------------------------------------------------
    TARGET DATA COMPONENT
  ]]----------------------------------------------------------
FTC.Target = {}

--[[
 * Initialize Target Data Table
 * --------------------------------
 * Called by FTC:Initialize()
 * --------------------------------
 ]]--
function FTC.Target:Initialize()

  -- Setup initial target information
  local target = {
    ["name"] = "-999",
    ["level"] = 0,
    ["class"] = "",
    ["vlevel"] = 0,
    ["health"] = { ["current"] = 0, ["max"] = 0, ["pct"] = 100 },
    ["magicka"] = { ["current"] = 0, ["max"] = 0, ["pct"] = 100 },
    ["stamina"] = { ["current"] = 0, ["max"] = 0, ["pct"] = 100 },
    ["shield"] = { ["current"] = 0, ["max"] = 0, ["pct"] = 100 },
  }

  -- Populate the target object
  for attr, value in pairs(target) do FTC.Target[attr] = value end

  -- Get target data
  FTC.Target:Update()
end

--[[
 * Update the Target Object
 * --------------------------------
 * Called by FTC.Target:Initialize()
 * Called by FTC:OnTargetChanged()
 * --------------------------------
 ]]--
function FTC.Target:Update()
  -- Hide default frame
  if (FTC.init.Frames and not FTC.Vars.DefaultTargetFrame) then FTC.TARGET_WINDOW:SetHidden(true) end

  local isCritter = false
  if FTC.Vars.ignoreCritters then isCritter = FTC:IsCritter('reticleover') end

  -- Ignore empty and critters, but not during move mode
  local ignore = ((not DoesUnitExist('reticleover')) or isCritter) and not FTC.move

  -- Update valid targets
  if (not ignore) then

    -- Update the target data object
    FTC.Target.name = GetUnitName('reticleover')
    FTC.Target.class = GetUnitClass('reticleover')
    FTC.Target.level = GetUnitLevel('reticleover')
    FTC.Target.vlevel = GetUnitChampionPoints('reticleover')
    FTC.Target.display = GetUnitDisplayName('reticleover')
    if FTC.Target.display == '' or not FTC.Target.display then
      FTC.Target.display = FTC.Target.name
    end

    -- Update target buffs
    if (FTC.init.Buffs) then FTC.Buffs:GetBuffs('reticleover') end

    -- Update target frame
    if (FTC.init.Frames) then FTC.Frames:SetupTarget() end

    -- Otherwise ensure target frame stays hidden
  else
    if (FTC.init.Frames) then FTC_TargetFrame:SetHidden(true) end
  end
end


--[[----------------------------------------------------------
    GROUP DATA COMPONENT
  ]]----------------------------------------------------------
FTC.Group = {}
function FTC.Group:Initialize()
  for i = 1, MAX_GROUP_SIZE_THRESHOLD do
    FTC.Group[i] = {
      ["health"] = { ["current"] = 0, ["max"] = 0, ["pct"] = 100 },
      ["magicka"] = { ["current"] = 0, ["max"] = 0, ["pct"] = 100 },
      ["stamina"] = { ["current"] = 0, ["max"] = 0, ["pct"] = 100 },
      ["shield"] = { ["current"] = 0, ["max"] = 0, ["pct"] = 100 },
    }
  end
  FTC.Group.groupSize = 0
  FTC.Group.hasCompanion = false
  FTC.Group.previousNumCompanions = 0
end

--[[
* Determine if the player is not in a group with other players. In which case
if the player has a companion summoned then there are two unit frames to
generate for the player and the companion.
* --------------------------------
* Called by FTC.Frames:SetupGroup()
* --------------------------------
]]--
function FTC.Group:ShowCompanionFrame()
  -- the player and the players companion
  if FTC.Group.groupSize == 0 and (HasActiveCompanion() or HasPendingCompanion()) then FTC.Group.hasCompanion = true
  else FTC.Group.hasCompanion = false end
  return FTC.Group.hasCompanion
end

--[[
* Get group index by unitTag because the index depends on group size
and distance of unit from the player
* --------------------------------
* Called by FTC.Frames:Initialize()
* --------------------------------
]]--
function FTC.Group:GetGroupIndexByUnitTag(unitTag)
  for index, info in pairs(FTC.Group) do
    if type(info) == "table" then
      if info.unitTag == unitTag then return FTC.Group[index].groupIndex end
    end
  end
  return
end

function FTC.Group:IsUnitTagGroupTag(unitTag)
  local isGroupUnitTag = string.find(unitTag, "group") and not string.find(unitTag, "companion")
  local isGroupCompanionUnitTag = string.find(unitTag, "group") and string.find(unitTag, "companion")
  return (isGroupUnitTag or isGroupCompanionUnitTag)
end

function FTC.Group:IsStandardGroupSize()
  -- Is the current group size less than the
  local groupSize = FTC.Group.groupSize <= SMALL_GROUP_SIZE_THRESHOLD and FTC.Vars.GroupFrames
  return groupSize
end

function FTC.Group:IsLargeGroupSize()
  -- the player and the players companion
  local groupSize = FTC.Group.groupSize > SMALL_GROUP_SIZE_THRESHOLD and FTC.Vars.RaidFrames
  return groupSize
end

function FTC.Group:UpdateNumCompanionsInGroup()
  -- the player and the players companion
  if GetNumCompanionsInGroup() ~= FTC.Group.previousNumCompanions then
    FTC.Group.previousNumCompanions = GetNumCompanionsInGroup()
    FTC.Frames:SetupGroup()
  end
end

--[[----------------------------------------------------------
    EVENT HANDLERS
  ]]----------------------------------------------------------

--[[
 * Process Updates to Attributes
 * --------------------------------
 * Called by FTC.OnPowerUpdate()
 * Called by FTC.Frames:SetupPlayer()
 * Called by FTC.Frames:SetupTarget()
 * --------------------------------
 ]]--
function FTC.Player:UpdateAttribute(unitTag, powerType, powerValue, powerMax, powerEffectiveMax)
  -- bail if there is no unitTag
  if not unitTag then return end

  local currentUnitTag = unitTag
  local isGroupUnitTag = FTC.Group:IsUnitTagGroupTag(unitTag)

  -- Player
  local data = nil
  if (currentUnitTag == 'player') then
    data = FTC.Player

    -- Target
  elseif (currentUnitTag == 'reticleover') then
    data = FTC.Target

    -- Companion
  elseif (currentUnitTag == 'companion') then
    data = FTC.Group[FTC_LOCAL_COMPANION]

    -- Group
  elseif isGroupUnitTag then
    local index = FTC.Group:GetGroupIndexByUnitTag(currentUnitTag)
    if not index then return end
    data = FTC.Group[index]
    -- get current unitTag if companion
    currentUnitTag = data.unitTag

    -- Otherwise bail out
  else return end

  -- Translate the attribute
  local attrs = { [COMBAT_MECHANIC_FLAGS_HEALTH] = "health", [COMBAT_MECHANIC_FLAGS_MAGICKA] = "magicka", [COMBAT_MECHANIC_FLAGS_STAMINA] = "stamina" }
  local power = attrs[powerType]

  -- If no value was passed, get new data
  if (powerValue == nil) then
    powerValue, powerMax, powerEffectiveMax = GetUnitPower(currentUnitTag, powerType)
  end

  -- Get the percentage
  local pct = math.max(zo_roundToNearest((powerValue or 0) / powerMax, 0.01), 0)

  -- Update frames
  if (FTC.init.Frames) then FTC.Frames:Attribute(unitTag, power, powerValue, powerMax, pct, data.shield.current) end

  -- Update the database object
  data[power] = { ["current"] = powerValue, ["max"] = powerMax, ["pct"] = pct }
end

--[[
* Update Shielding Attribute
* --------------------------------
* Called by FTC.OnVisualAdded()
* Called by FTC.OnVisualUpdate()
* Called by FTC.OnVisualRemoved()
* Called by FTC.Frames:SetupPlayer()
* Called by FTC.Frames:SetupTarget()
* --------------------------------
]]--
function FTC.Player:UpdateShield(unitTag, value, maxValue)
  -- bail if there is no unitTag
  if not unitTag then return end

  local currentUnitTag = unitTag
  local isGroupUnitTag = FTC.Group:IsUnitTagGroupTag(unitTag)

  -- Player
  local data = nil
  if (currentUnitTag == 'player') then
    data = FTC.Player

    -- Target
  elseif (currentUnitTag == 'reticleover') then
    data = FTC.Target

    -- Companion
  elseif (currentUnitTag == 'companion') then
    data = FTC.Group[FTC_LOCAL_COMPANION]

    -- Group
  elseif isGroupUnitTag then
    local index = FTC.Group:GetGroupIndexByUnitTag(currentUnitTag)
    if not index then return end
    data = FTC.Group[index]
    currentUnitTag = data.unitTag

    -- Otherwise bail out
  else return end

  -- If no value was passed, get new data
  if (value == nil) then
    value = GetUnitAttributeVisualizerEffectInfo(currentUnitTag, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH) or 0
  end

  -- Get the unit's maximum health
  local pct = zo_roundToNearest(value / data["health"]["max"], 0.01)

  -- Update frames
  if (FTC.init.Frames) then FTC.Frames:Shield(unitTag, value, pct, data.health.current, data.health.max, data.health.pct) end

  -- Update the database object
  data.shield = { ["current"] = value, ["max"] = maxValue, ["pct"] = pct }
end

--[[
* Update Player Ultimate
* --------------------------------
* Called by FTC.OnPowerUpdate()
* --------------------------------
]]--
function FTC.Player:UpdateUltimate(powerValue, powerMax, powerEffectiveMax)

  -- Get the currently slotted ultimate cost
  --[[TODO GetSlotAbilityCost() requires 3 arguments, update
  luaindex: actionSlotIndex
  Constant: mechanicType
  Constant: hotbarCategory

  COMBAT_MECHANIC_FLAGS_DAEDRIC
  COMBAT_MECHANIC_FLAGS_HEALTH
  COMBAT_MECHANIC_FLAGS_MAGICKA
  COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA
  COMBAT_MECHANIC_FLAGS_STAMINA
  COMBAT_MECHANIC_FLAGS_ULTIMATE
  COMBAT_MECHANIC_FLAGS_WEREWOLF

  HOTBAR_CATEGORY_ALLY_WHEEL
  HOTBAR_CATEGORY_BACKUP
  HOTBAR_CATEGORY_CHAMPION
  HOTBAR_CATEGORY_COMPANION
  HOTBAR_CATEGORY_DAEDRIC_ARTIFACT
  HOTBAR_CATEGORY_EMOTE_WHEEL
  HOTBAR_CATEGORY_MEMENTO_WHEEL
  HOTBAR_CATEGORY_OVERLOAD
  HOTBAR_CATEGORY_PRIMARY
  HOTBAR_CATEGORY_QUICKSLOT_WHEEL
  HOTBAR_CATEGORY_TEMPORARY
  HOTBAR_CATEGORY_TOOL_WHEEL
  HOTBAR_CATEGORY_WEREWOLF
  ]]--

  local cost = GetSlotAbilityCost(8, COMBAT_MECHANIC_FLAGS_ULTIMATE)

  -- Calculate the percentage to activation
  local pct = (cost > 0) and math.max(zo_roundToNearest((powerValue / cost), 0.01), 0) or 0

  -- Maybe fire an alert
  if (FTC.init.SCT and pct >= 1 and FTC.Player.ultimate.pct < 1) then FTC.SCT:Ultimate() end

  -- Update the hotbar label
  if (FTC.init.Hotbar) then FTC.Hotbar:UpdateUltimate(powerValue, cost) end

  -- Update the database object
  FTC.Player.ultimate = { ["current"] = powerValue, ["max"] = powerEffectiveMax, ["pct"] = pct }
end


--[[----------------------------------------------------------
    HELPER FUNCTIONS
  ]]----------------------------------------------------------

--[[
 * Filters Targets for "Critters"
 * --------------------------------
 * Called by FTC.Target:Update()
 * --------------------------------
 ]]--
function FTC:IsCritter(unitTag)
    -- bail if there is no unitTag
  if not unitTag then return end

  -- Critters meet all the following criteria: EffectiveLevel 50, Effective Health 1, Difficulty = NONE, and Neutral or Friendly reaction
  local isBaseLevel = GetUnitEffectiveLevel(unitTag) == 50
  local _, _, effectiveMaxHealth = GetUnitPower(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH)
  local hasNegligibleHealth = effectiveMaxHealth == 1
  local difficultyNone = GetUnitDifficulty(unitTag) == MONSTER_DIFFICULTY_NONE
  local friendlyOrNeutral = (GetUnitReaction(unitTag) == UNIT_REACTION_NEUTRAL or GetUnitReaction(unitTag) == UNIT_REACTION_FRIENDLY)
  local isCritter = (isBaseLevel and hasNegligibleHealth and difficultyNone and friendlyOrNeutral)
  return isCritter
end

--[[
 * Re-populates Player Experience
 * --------------------------------
 * Called by FTC.Player:Initialize()
 * Called by FTC:OnXPUpdate()
 * Called by FTC:OnVPUpdate()
 * --------------------------------
 ]]--
function FTC.Player:GetLevel()
  FTC.Player.level = GetUnitLevel('player')
  FTC.Player.alevel = GetUnitAvARank('player')
  FTC.Player.clevel = GetPlayerChampionPointsEarned()
  FTC.Player.exp = GetUnitXP('player')
  FTC.Player.cxp = GetPlayerChampionXP()
end

--[[
 * Get Currently Active Quickslot
 * --------------------------------
 * Called by FTC:OnQuickslotChanged
 * --------------------------------
 ]]--
function FTC.Player:GetQuickslot(slotNum)

  -- Get the current slot
  local slotNumber = slotNum or GetCurrentQuickslot()

  -- Populate the quickslot object
  if (IsSlotUsed(slotNumber)) then
    local abilityId = GetSlotBoundId(slotNumber)

    -- Get potion base duration
    local baseDur = tonumber(zo_strformat("<<x:1>>", string.match(GetAbilityDescription(abilityId), 'for (.*) seconds'))) or 0

    -- Get potion level
    local itemLevel = (GetItemLinkRequiredLevel(GetSlotItemLink(slotNumber)) or 0) + (GetItemLinkRequiredChampionPoints(GetSlotItemLink(slotNumber)) or 0)

    -- Get Medicinal Use multiplier
    local multiplier = GetSkillAbilityUpgradeInfo(SKILL_TYPE_TRADESKILL, 1, 3)
    multiplier = 1.0 + (0.1 * multiplier)

    -- Approximate potion duration with a close (but incorrect) formula
    local duration = (baseDur + (itemLevel * .325)) * multiplier * 1000

    -- Setup object
    local ability = {
      ["owner"] = FTC.Player.name,
      ["slot"] = slotNumber,
      ["id"] = abilityId,
      ["name"] = zo_strformat("<<t:1>>", GetSlotName(slotNumber)),
      ["cast"] = 0,
      ["chan"] = 0,
      ["dur"] = duration,
      ["tex"] = GetSlotTexture(slotNumber),
    }

    -- Save the slot
    FTC.Player.Quickslot = ability

    -- Otherwise empty the object
  else FTC.Player.Quickslot = {} end
end

--[[
 * Get abilityID from abilityName
 * --------------------------------
 * UNUSED / DEBUGGING
 * --------------------------------
 ]]--
function FTC:GetAbilityId(abilityName)

  -- Loop over all ability IDs until we find it
  for i = 1, 200000 do
    if (DoesAbilityExist(i) and (GetAbilityName(i) == abilityName)) then
      d(i .. " -- " .. abilityName)
      return i
    end
  end
end

function FTC:FindAbilityIds(abilityName)

  -- Loop over all ability IDs until we find it
  for i = 1, 200000 do
    local nameLower = string.lower(GetAbilityName(i))
    abilityName = string.lower(abilityName)
    if (DoesAbilityExist(i) and string.find(nameLower, abilityName)) then
      d(i .. " -- " .. GetAbilityName(i))
    end
  end
end
