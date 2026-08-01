EPT = EPT or {}
local EPT = EPT

--IDEA
--Stuhn's
--Syvarras Schuppen
--Domihaus and Bahraha's Curse
--Alkosh, Morag Tong
--Gloom-Graced
--Draugkin Grip
--dro'zakar

---------------
-- VARIABLES --
---------------

EPT.name = "ExoYsProcSetTimer"
EPT.displayName = "|c40FF00ExoY|rs Proc Set Timer"
EPT.version = "2.14.0"
EPT.author = "@|c00FF00ExoY|r94 (PC/EU)"
EPT.event = GetEventManager()
EPT.window = GetWindowManager()
EPT.player = zo_strformat( SI_UNIT_NAME, GetUnitName( "player" ) )
EPT.procSets = {}
EPT.bosses = {}
EPT.equippedSets = {}

EPT.group = {}
EPT.guiList = {}
EPT.activeTimerList = {}

EPT_ACTION_READ = 1
EPT_ACTION_TOGGLE = 2
EPT_ACTION_SET = 3

local equipSlotList = { EQUIP_SLOT_HEAD, --0
                        EQUIP_SLOT_NECK, --1
                        EQUIP_SLOT_CHEST, --2
                        EQUIP_SLOT_SHOULDERS, --3
                        EQUIP_SLOT_MAIN_HAND,   --4
                        EQUIP_SLOT_OFF_HAND,  --5
                        EQUIP_SLOT_WAIST, --6
                        EQUIP_SLOT_LEGS, --8
                        EQUIP_SLOT_FEET, --9
                        EQUIP_SLOT_RING1, --11
                        EQUIP_SLOT_RING2, --12
                        EQUIP_SLOT_HAND, --16
                        EQUIP_SLOT_BACKUP_MAIN,   --20
                        EQUIP_SLOT_BACKUP_OFF     --21
                      }

local twoHanderList = { WEAPONTYPE_FIRE_STAFF, --12
                        WEAPONTYPE_FROST_STAFF,  --13
                        WEAPONTYPE_LIGHTNING_STAFF, --15
                        WEAPONTYPE_HEALING_STAFF, --9
                        WEAPONTYPE_BOW, --8
                        WEAPONTYPE_TWO_HANDED_AXE, --5
                        WEAPONTYPE_TWO_HANDED_HAMMER, --6
                        WEAPONTYPE_TWO_HANDED_SWORD, --4
                      }

---------------------
-- LOCAL FUNCTIONS --
---------------------

local function debug (type, name, extra)
  local output = "- ProcSet"
  output = output..type.." : "..tostring(name)
  if extra ~= nil then
    output = output .. " ("..tostring(extra)..")"
  end
  if type == "seperator" then
    output = "_________________________"
  end
  d(output)
end

function EPT.GetSetIdBySetName(name)
  local id
  for setId, setInfo in pairs(EPT.procSets) do
    if setInfo.setName == name then id = setId end
  end
  return id
end

function EPT.ResetGui()
  local self = EPT
  for setId, status in pairs(self.completeSets) do
    if status then
      self:DeleteCompleteSetEntry(setId)
    end
  end
  self:CheckEquippedSets()
end

local function GetTimeRemaining( finish )
	return zo_max( 0, finish - GetGameTimeMilliseconds() )
end

local function IsTable(var)
  local bool = false
  if type(var)=="table" then bool=true end
  return bool
end

local function IsTableEmpty(var)
  local bool = false
  if next(var) == nil then bool = true end
  return bool
end

local function GetSetIdBySlotId(slotId)
  local _, _, _, _, _, setId = GetItemLinkSetInfo(GetItemLink(BAG_WORN, slotId))
  return setId
end

local function GetMaxEquipped(slotId)
  local _, _, _, _, maxEquipped, _ = GetItemLinkSetInfo(GetItemLink(BAG_WORN, slotId))
  return maxEquipped
end

local function IsSetFullyEquipped(setId)
  local bool = false
  local counter = 0
  local exampleSlotId
  for tableSlotId, tableSetId in pairs(EPT.equippedSets) do
    if tableSetId == setId then
        counter = counter + 1
      if not exampleSlotId then
        exampleSlotId = tableSlotId
      end
    end
  end

  local targetNo
  if GetMaxEquipped(exampleSlotId) == 5 then
    targetNo = EPT.store.setPieceOverwrite
  else
    targetNo = GetMaxEquipped(exampleSlotId)
  end

  if counter > 0 and counter >= targetNo then
    bool = true
  end
  return bool
end

local function IsSetComplete(setId)
  return EPT.completeSets[setId]
end

local function GetSetIdByAbilityId(abilityId)
  local match
  for setId, setInfo in pairs(EPT.procSets) do
      --if abilityId == setInfo.abilityId and IsSetFullyEquipped(setId) then match = setId end
      if abilityId == setInfo.abilityId and IsSetComplete(setId) then match = setId end
  end
  return match
end

local function IsSetTracked(setId)
  local self = EPT
  if self.completeSets[setId] == nil then
    return false
  elseif self.store.filter.active and self.store.filter.type then
    return self.store[setId].whiteList
  elseif self.store.filter.active and not self.store.filter.type then
    return not self.store[setId].blackList
  else return true
  end
end

local function IsSetSupported(setId)
  local supported = false
  local list = EPT.procSets
  for key, _ in pairs(list) do
    if key == setId then supported = true end
  end
  return supported
end

----------------
-- INITIALIZE --
----------------
local function CheckAllSets()
  EPT:CheckEquippedSets()
end

local function OnPlayerActivated()
  EVENT_MANAGER:UnregisterForEvent(EPT.name, EVENT_PLAYER_ACTIVATED)
	EPT:Initialize()
	--CHAT_ROUTER:AddSystemMessage(EPT.name.." Now Enabled!")
  EVENT_MANAGER:RegisterForEvent(EPT.name, EVENT_PLAYER_ACTIVATED, CheckAllSets)
end


local function OnAddOnLoaded(_, addonName)
  if addonName == EPT.name then
		EVENT_MANAGER:UnregisterForEvent(EPT.name, 	EVENT_ADD_ON_LOADED)
		EVENT_MANAGER:RegisterForEvent(EPT.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
  end
end

EVENT_MANAGER:RegisterForEvent(EPT.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

local function GetDefault()
  local default = {}
  default.debug = false
  default.spaulder = false
  default.setPieceOverwrite = 5

  --Design
  default.design = {
    ["iconSize"] = 50,
    ["font"] = 1,
    ["hiding"] = false,

    ["edge"] = {
      ["size"] = 5,
      ["show"] = true,
      ["changeColor"] = true,
    },

    ["color"] ={
      ["active"] = {0,1,0,1},
      ["cooldown"] = {1,0,0,1},
      ["standby"] = {0,0,0,0.3},
      ["high"] = {0,1,0,1},
      ["medium"] = {1,1,0,1},
      ["low"] = {1,0,0,1},
    },

    ["indicator"] = {
      ["showDecimal"] = true,
      ["changeColor"] = true,
      ["size"] = 7,
      ["offSetX"] = 0,
      ["offSetY"] = 0,
      ["font"] = 1,
    },

    ["nameDisplay"] = {
      ["gameMode"] = false,
      ["mouseMode"] = false,
      ["mouseHover"] = true,
      ["showBackground"] = true,
      ["size"] = 54,
      ["position"] = "above"
    },
  }

  -- Filter
  default.filter = {
    ["active"] = false,
    ["type"] = false, -- true = Whiteliste, false = Blacklist
  }

  -- Positions
  for setId, info in pairs(EPT.procSets) do
    default[setId] = {
      ["left"] = 600,
      ["top"] = 600,
      ["whiteList"] = false,
      ["blackList"] = false,
    }
  end

  default["demo"] = {["left"] = 600, ["top"] = 600,}

  --Special sets
  default.special = {
    ["zen"] = {
      ["focusOnBoss"] = true,
    },

    ["opportunist"] = {
      ["showDuration"] = true,
      ["showAffected"] = true,
    },

    ["martial"] = {
      ["showStamina"] = true,
    },
  }
  return default
end

function EPT:Initialize()
  -- load all sets
  self.procSets = self.GetSetList()

  local default = GetDefault()
  self.store = ZO_SavedVars:NewAccountWide("EPTSV", 2, nil, default)

  for setId, setInfo in pairs(self.procSets) do
    if setInfo.type == nil then setInfo.type = "timer" end
    if setInfo.cooldown == nil then setInfo.cooldwon = 0 end

    --workaround
    if setInfo.type == "stack" then setInfo.type = "timer" end
  end

  -- Special Initiation
  self:InitiateJorvulds()

  --Initiate CompleteSet-liste
  self.completeSets = {}
  for setId, _ in pairs(self.procSets) do
    table.insert(self.completeSets, setId, false)
  end

  self:CheckEquippedSets() -- schaut ob gerade getrackte sets aktiv sind

  if not IsUnitInCombat("player") then
    self.OnPlayerCombatState(_, false)
  end
  self.event:RegisterForEvent(self.name.."CombatStateChange", EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)
  --self.event:RegisterForEvent(self.name.."ReticleChange", EVENT_RETICLE_HIDDEN_UPDATE, self.OnReticleUpdate) xxx
  self.event:RegisterForEvent(self.name.."OnActivate", EVENT_PLAYER_ACTIVATED, self.OnActivated)

  zo_callLater(function() self.SetVisibility() end, 1000)

  self.lastZone = GetZoneId(GetUnitZoneIndex("player"))

  --dummy gui
  self.demo = {}
  self.demo.set = self:CreateGui("demo")
  self.demo.set.hidden = true

  --filter help
  self.filter = {}
  self.filter.origin = EPT_ORIGIN_ALL
  self.filter.type = true
  self.filter.action = true
  self.filter.originInfo = EPT_ORIGIN_ALL

  -- group

  self.group.tag = {}
  self.event:RegisterForEvent(self.name.."UpdateGroupMemberInfo", EVENT_EFFECT_CHANGED, self.UpdateGroupMemberInfo)
  self.event:AddFilterForEvent(self.name.."UpdateGroupMemberInfo", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

  local function GetPlayerId(event, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if changeType == EFFECT_RESULT_GAINED and unitId then
        self.playerId = unitId
    end
  end

  self.event:RegisterForEvent(self.name.."GetPlayerId", EVENT_EFFECT_CHANGED, GetPlayerId)
  self.event:AddFilterForEvent(self.name.."GetPlayerId", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

  self.CreateContextMenu()

  self:CreateAddonMenu()

  self.event:RegisterForUpdate(self.name.."TimerUpdate", 100, EPT.OnTimerUpdate)

end

function EPT.OnActivated()
	EPT.activeTimerList = {}
end

--------------
-- Jorvulds --
--------------

function EPT:InitiateJorvulds()
  local counter = 0
  local activeBar = GetActiveHotbarCategory()

  local function CheckForTwoHander(slot)
    local weaponslots = {
      EQUIP_SLOT_BACKUP_MAIN,
      EQUIP_SLOT_BACKUP_OFF,
      EQUIP_SLOT_MAIN_HAND,
      EQUIP_SLOT_OFF_HAND,
    }
    local affirm = false
    for _, weaponslot in pairs(weaponslots) do
      if slot == weaponslot then
        for _, twoHander in ipairs(twoHanderList) do
          d(twoHander)
          if GetItemWeaponType(BAG_WORN, slot) == twoHander then
            affirm = true
          end
        end
      end
    end
    return affirm
  end

  local slotList = { EQUIP_SLOT_HEAD, --0
                          EQUIP_SLOT_NECK, --1
                          EQUIP_SLOT_CHEST, --2
                          EQUIP_SLOT_SHOULDERS, --3
                          EQUIP_SLOT_MAIN_HAND,   --4
                          EQUIP_SLOT_OFF_HAND,  --5
                          EQUIP_SLOT_WAIST, --6
                          EQUIP_SLOT_LEGS, --8
                          EQUIP_SLOT_FEET, --9
                          EQUIP_SLOT_RING1, --11
                          EQUIP_SLOT_RING2, --12
                          EQUIP_SLOT_HAND, --16
                          EQUIP_SLOT_BACKUP_MAIN,   --20
                          EQUIP_SLOT_BACKUP_OFF     --21
                        }
  if activeBar == HOTBAR_CATEGORY_PRIMARY then -- 0
    table.remove(slotList, EQUIP_SLOT_BACKUP_MAIN)
    table.remove(slotList, EQUIP_SLOT_BACKUP_OFF-1)
  else -- HOTBAR_CATEGORY_BACKUP = 1
     table.remove(slotList, EQUIP_SLOT_MAIN_HAND)
    table.remove(slotList, EQUIP_SLOT_OFF_HAND-1)
  end
  for _, equipSlot in pairs(slotList) do
    if GetSetIdBySlotId(equipSlot) == 346 then
      counter = counter + 1
      if CheckForTwoHander(equipSlot) then
        counter = counter + 1
      end
    end
  end
  if counter >= 5 then self.jorvuld = true else self.jorvuld = false end
  self.event:RegisterForEvent(EPT.name.."Jorvuld", EVENT_COMBAT_EVENT, EPT.JorvuldChange)
  self.event:AddFilterForEvent(EPT.name.."Jorvuld", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 101978)
end

function EPT.JorvuldChange(_, result)
  local self = EPT
  if result == ACTION_RESULT_EFFECT_GAINED then
    self.jorvuld = true
  elseif result == ACTION_RESULT_EFFECT_FADED then
    self.jorvuld = false
  end
  if self.store.debug then d("--ProcSet Jorvuld: "..tostring(self.jorvuld)) end --xxx
end

------------
-- EVENTS --
------------
function EPT.OnReticleUpdate(_, hidden)
  local self = EPT
  if self.store.debug then debug("event", "OnReticleUpdate", hidden) end
  local show
  local design = self.store.design
  if not hidden then
    show = design.nameDisplay.gameMode
    --self.guiList[999].win:SetHidden(true)
    --self.completeSets[999] = false
  end
  if hidden then
    show = design.nameDisplay.mouseMode
  end
  for setId, gui in pairs(self.guiList) do
    --gui.nameWindow.label:SetText("test")
    gui.nameDisplay.ctrl:SetHidden(not show)
  end
  --change mode mouse / game
  --start
end

function EPT.OnEquipChange(_, _, slotId, _, _, _)
  if EPT.store.debug then debug("event", "OnEquipChange", slotId) end
  EPT:EquipChange(slotId)
end

function EPT.SetVisibility()
  local self = EPT
  if self.store.design.hiding then
    local visible = IsUnitInCombat("player")
    for setId, gui in pairs(self.guiList) do
      gui.win:SetHidden(not visible)
    end
  end
end

function EPT.OnPlayerCombatState(_, combat)
  local self = EPT
  if self.store.debug then debug("event", "OnPlayerCombatState", combat) end

  self.SetVisibility(not combat)

  if combat then
    self.event:UnregisterForEvent(self.name.."equipChange", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
  else
    self.event:RegisterForEvent(self.name.."equipChange", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, self.OnEquipChange)
    self.event:AddFilterForEvent(self.name.."equipChange", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
    self.event:AddFilterForEvent(self.name.."equipChange", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_IS_NEW_ITEM, false)
    self.event:AddFilterForEvent(self.name.."equipChange", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON , INVENTORY_UPDATE_REASON_DEFAULT)
  end
end

function EPT.OnCombatEvent(event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
  local self = EPT
  if EPT.store.debug then debug("event", "OnCombatEvent", abilityId) end
  local setId = GetSetIdByAbilityId(abilityId)
  if abilityId == nil or setId == nil then return end
  if EPT.store.debug then debug("event", "setId", setId) end
  if EPT.store.debug then debug("action result", result) end
  if self.procSets[setId].type == "special" and self:GetPrimaryIndicatorType(setId) == "timer" or self.procSets[setId].type == "timer" then
    if (result == ACTION_RESULT_EFFECT_GAINED) or (result == ACTION_RESULT_EFFECT_GAINED_DURATION) or (result == ACTION_RESULT_DAMAGE) or (result == ACTION_RESULT_CRITICAL_DAMAGE) then
      local gui = self.guiList[setId].primaryInd
      self:RegisterForTimer(gui, setId, abilityId)
    end
  end

  if self.procSets[setId].type == "value" then
    local gui = self.guiList[setId].primaryInd
    local before = tonumber(gui.label:GetText())
    if before == nil then before = 0 end
    local after
    local function HotFix()
      if after < 0 then after = 0 end
       gui.label:SetText(tostring(after))
       local groupSize = GetGroupSize()
       if groupSize == 0 then groupSize = 1 end
       self:UpdateColor(gui, self:GetValueStatus(after, groupSize))
     end
    if result == ACTION_RESULT_EFFECT_GAINED then
     after = before + 1
     HotFix(after)
   elseif result == ACTION_RESULT_EFFECT_FADED then
     after = before - 1
     HotFix(after)
   end
  end
end

-- EVENT_EFFECT_CHANGED (eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
local function OnEffectChanged( _,  changeType,  _,  _,  unitTag, beginTime, endTime, stackCount,  _,  _,  effectType, _,  _,  unitName, unitId, abilityId, sourceType)
	--changeType
	-- 1 = EFFECT_RESULT_GAINED
	-- 2 = EFFECT_RESULT_FADED
	-- 3 = EFFECT_RESULT_UPDATED
	if changeType == EFFECT_RESULT_FADED then stackCount = 0 end

	local self = EPT
	if EPT.store.debug then debug("event", "OnEffectChanged", abilityId) end
	local setId = GetSetIdByAbilityId(abilityId)
	if abilityId == nil or setId == nil then return end
	if EPT.store.debug then d(zo_strformat("setId[<<1>>] abilityId[<<2>>] StackCount[<<3>>] changeType[<<4>>]", setId, abilityId, stackCount, changeType)) end

	if changeType == EFFECT_RESULT_FADED then
		stackCount = 0
	else
		self:RegisterForTimer(self.guiList[setId].primaryInd, setId, abilityId)
	end
	self:UpdateStackNumber(setId, stackCount)
end

function EPT:InitiateValue(setId, gui)
  local groupSize = GetGroupSize()
  local value = 0
  local function IsBuffActive(unit)
    for i = 1, GetNumBuffs(unit) do
      local buffName, start, finish, slot, stacks, icon, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo( unit, i )
      if abilityId == self.procSets[setId].abilityId then
        return true
      else
        return false
      end
    end
  end
  if groupSize == 0 then
    if IsBuffActive("player") then
      value = value + 1
    end
  else
    for i=1,GetGroupSize() do
      if IsBuffActive("group"..tostring(i)) then
        value = value + 1
      end
    end
  end
  gui.label:SetText(tostring(value))
  if groupSize == 0 then groupSize = 1 end
  self:UpdateColor(gui, self:GetValueStatus(value, groupSize))
end

------------
-- UPDATE --
------------

function EPT:RegisterForTimer(gui, setId, abilityId)
  local currentTime = GetGameTimeMilliseconds()
  local setInfo = self.procSets[setId]
  local cd = setInfo.cooldown
  if cd == nil then cd = 0 end
  local entry = {
    ["gui"] = gui,
    ["buffEnd"] = currentTime + GetAbilityDuration(abilityId),
    ["cdEnd"] = currentTime + cd,
    ["status"] = "active",
  }
  -- WARNING only hotfix for RO to work with jorvuld
  --if self.jorvuld then
  --  if abilityId == 137986 or abilityId == 135923 then
  --    entry.buffEnd = currentTime + ( GetAbilityDuration(abilityId)*1.4 )
  --  end
  --end


  table.insert(self.activeTimerList, entry)
  --if not self.timerUpdateRunning then
  --  self.event:RegisterForUpdate(self.name.."TimerUpdate", 100, EPT.OnTimerUpdate)
  --  self.timerUpdateRunning = true
  --end
end

function EPT.OnTimerUpdate()
  local self = EPT
  local allStandby = true
  local removelist = {}
  for idx, timer in ipairs(self.activeTimerList) do
    local buffTime = GetTimeRemaining(timer.buffEnd)
    local cdTime = GetTimeRemaining(timer.cdEnd)
    --d(buffTime)
    local function GetString(time)
      if time < 10000  and self.store.design.indicator.showDecimal then
        return string.format( "%.1f", time/1000)
      else
        return string.format( "%.0f", math.ceil(time / 1000))
      end
    end
    if buffTime > 0 then
      timer.gui.label:SetText(GetString(buffTime))
      --timer.gui.ctrl:SetAlpha(self.store.design.transparency.combatActive)
      self:UpdateColor(timer.gui, "active")
      allStandby = false
    elseif cdTime > 0 then
      timer.gui.label:SetText(GetString(cdTime))
      --timer.gui.ctrl:SetAlpha(self.store.design.transparency.combatActive)
      self:UpdateColor(timer.gui, "cooldown")
      allStandby = false
    else
	  --table.insert(removelist, idx)
      timer.gui.label:SetText("")
      self:UpdateColor(timer.gui, "standby")
      --if IsUnitInCombat("player") then
         --timer.gui.ctrl:SetAlpha(self.store.design.transparency.combatStandby)
       --else
         --timer.gui.ctrl:SetAlpha(self.store.design.transparency.outOfCombat)
       --end
    end
  end
  -- Remove unused shit
  --for _, idx in ipairs(removelist) do
	--table.remove(self.activeTimerList, idx)
  --end
  --
  --if allStandby then
    --self.event:UnregisterForUpdate(self.name.."TimerUpdate")
    --self.timerUpdateRunning = false
  --end
end

------------------
-- SET TRACKING --
------------------

function EPT:CheckEquippedSets()
  zo_callLater(function()
    for _, equipSlot in pairs(equipSlotList) do
      self:EquipChange(equipSlot)
    end
    if EPT.completeSets[627] then
      local result = EPT.store.spaulder and ACTION_RESULT_EFFECT_GAINED or ACTION_RESULT_EFFECT_FADED
      EPT.OnSpaulder(_, result)
    end
  end, 1200 )
end

function EPT:EquipChange(slotId)
  local function HandleTwoHander()
    local mainOff = GetSetIdBySlotId(EQUIP_SLOT_OFF_HAND)
    local backOff = GetSetIdBySlotId(EQUIP_SLOT_BACKUP_OFF)
    if mainOff == 0 or not IsSetTracked(mainOff) then mainOff = nil end
    if backOff == 0 or not IsSetTracked(backOff) then backOff = nil end
    self.equippedSets[EQUIP_SLOT_OFF_HAND] = mainOff
    self.equippedSets[EQUIP_SLOT_BACKUP_OFF] = backOff
    for _, twoHander in ipairs(twoHanderList) do
      if GetItemWeaponType(BAG_WORN, EQUIP_SLOT_MAIN_HAND) == twoHander then
        if IsSetTracked(GetSetIdBySlotId(EQUIP_SLOT_MAIN_HAND)) then
        self.equippedSets[EQUIP_SLOT_OFF_HAND] = GetSetIdBySlotId(EQUIP_SLOT_MAIN_HAND)
        end
      end
      if GetItemWeaponType(BAG_WORN, EQUIP_SLOT_BACKUP_MAIN) == twoHander then
        if IsSetTracked(GetSetIdBySlotId(EQUIP_SLOT_BACKUP_MAIN)) then
          self.equippedSets[EQUIP_SLOT_BACKUP_OFF] = GetSetIdBySlotId(EQUIP_SLOT_BACKUP_MAIN)
        end
      end
    end
  end

  local oldSet = self.equippedSets[slotId]
  local newSet = GetSetIdBySlotId(slotId)
  if IsSetTracked(newSet) then
    self.equippedSets[slotId] = newSet
  else
    self.equippedSets[slotId] = nil
  end
  HandleTwoHander()
  if oldSet then
    if not IsSetFullyEquipped(oldSet) and IsSetComplete(oldSet) then
      self:DeleteCompleteSetEntry(oldSet)
    end
  end
  if IsSetTracked(newSet) and IsSetFullyEquipped(newSet) and not IsSetComplete(newSet) then
      self:AddCompleteSetEntry(newSet)
  end
end

function EPT:RegisterGUI(setId)
  if not self.guiList[setId] then
    self.guiList[setId] = self:CreateGui(setId)
  end
  HUD_UI_SCENE:AddFragment( self.guiList[setId].frag )
  HUD_SCENE:AddFragment( self.guiList[setId].frag )
end

function EPT:UnregisterGUI(setId)
  HUD_UI_SCENE:RemoveFragment( self.guiList[setId].frag )
  HUD_SCENE:RemoveFragment( self.guiList[setId].frag )
end

function EPT:AddCompleteSetEntry(setId)
  if self.store.debug then debug("function", "AddCompleteSetEntry", setId) end
  local setInfo = self.procSets[setId]
  if setInfo.type == "special" then
    self:InitializeSpecialSet(setId)
  elseif setInfo.type == "value" then
    self.event:RegisterForEvent(self.name..tostring(setId), EVENT_COMBAT_EVENT, EPT.OnCombatEvent)
    self.event:AddFilterForEvent(self.name..tostring(setId), EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, setInfo.abilityId)
    --self.event:AddFilterForEvent(self.name..tostring(setId), EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE , COMBAT_UNIT_TYPE_PLAYER)
  elseif setInfo.type == "stack" then    --

  elseif setInfo.type == "stacktarget" then
    --self.event:RegisterForEvent(self.name..tostring(setId), EVENT_EFFECT_CHANGED, OnEffectChanged)
    --self.event:AddFilterForEvent(self.name..tostring(setId), EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, setInfo.abilityId)
	--self.event:AddFilterForEvent(self.name..tostring(setId), EVENT_EFFECT_CHANGED, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
  elseif setInfo.type == "stackself" then
    self.event:RegisterForEvent(self.name..tostring(setId), EVENT_EFFECT_CHANGED, OnEffectChanged)
    self.event:AddFilterForEvent(self.name..tostring(setId), EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, setInfo.abilityId)
  	self.event:AddFilterForEvent(self.name..tostring(setId), EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

  elseif setInfo.type == "timer" then
    self.event:RegisterForEvent(self.name..tostring(setId), EVENT_COMBAT_EVENT, EPT.OnCombatEvent)
    self.event:AddFilterForEvent(self.name..tostring(setId), EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, setInfo.abilityId)
    self.event:AddFilterForEvent(self.name..tostring(setId), EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE , COMBAT_UNIT_TYPE_PLAYER)
  end
  self.completeSets[setId] = true
  self:RegisterGUI(setId)
end

function EPT:DeleteCompleteSetEntry(setId)
  if self.store.debug then debug("function", "DeleteCompleteSetEntry", setId) end
  local setInfo = self.procSets[setId]
  if setInfo.type == "special" then
    self:TerminateSpecialSet(setId)
  elseif setInfo.type == "timer" then
    self.event:UnregisterForEvent(self.name..tostring(setId), EVENT_COMBAT_EVENT)
  elseif setInfo.type == "stackself" then
    self:TerminateSpecialSet(setId)
    self.event:UnregisterForEvent(self.name..tostring(setId), EVENT_COMBAT_EVENT)
  elseif setInfo.type == "stacktarget" then
    self.event:UnregisterForEvent(self.name..tostring(setId), EVENT_COMBAT_EVENT)
  end
  self.completeSets[setId] = false
  self:UnregisterGUI(setId)
end

function EPT:GetValueStatus(value, max)
  local percent = 100*value/max
  if percent < 30 then return "low"
  elseif percent > 70 then return "high"
  else return "medium"
  end
end

------------
-- Filter --
------------

function EPT:FilterSetChoices()
  local list = {}
  for setId, setInfo in pairs(self.procSets) do
    if self.store[setId][self.filter.type and "whiteList" or "blackList"] ~= self.filter.action then
      if (self.filter.origin == EPT_ORIGIN_ALL) or (setInfo.origin == self.filter.origin) then
        table.insert(list, setInfo.setName)
      end
    end
  end
  table.sort(list)
  return list
end

function EPT:FilterSetManagement(setId, filterList, action)
  local filterList = self.filter.type and "whiteList" or "blackList"
  self.store[setId][filterList] = action


  -- filterList: "whiteList" or "blackList"
  -- action: nil read, true add, false delete
  --if action == nil then
  --  return self.store[setId][filterList]
  --else
  --  self.store[setId][filterList] = action
  --end
end



function EPT.FilterManagement(setId, filterList, action, optional)
  if not EPT.store[setId] then return end
  local filterStatus = EPT.store[setId][filterList]
  if action == EPT_ACTION_READ then
    return filterStatus
  elseif action == EPT_ACTION_TOGGLE then
    EPT.store[setId][filterList] = not filterStatus
  elseif action == EPT_ACTION_SET then
    filterStatus = optional
  end
  --EPT.Debug(EPT.procSets[setId].name.." "..filterList.." "..EPT_ACTION_TOGGLE_STRING)
end

function EPT.CreateContextMenu()
  if not LibCustomMenu then return end
  LibCustomMenu:RegisterContextMenu(function(inventorySlot)
    -- local slotType = ZO_InventorySlot_GetType(inventorySlot)
    local bagId, slotId = ZO_Inventory_GetBagAndIndex(inventorySlot)
    local _, _, _, _, _, setId = GetItemLinkSetInfo(GetItemLink(bagId, slotId))



    if IsSetSupported(setId) then
      local entries = {}
      local whiteListStatus = EPT.FilterManagement(setId, "whiteList", EPT_ACTION_READ)
      local blackListStatus = EPT.FilterManagement(setId, "blackList", EPT_ACTION_READ)
      entries = {
        {
          label = zo_strformat("<<1>> <<2>>", whiteListStatus and EPT_REMOVE_FROM or EPT_ADD_TO, EPT_WHITELIST),
          callback = function() EPT.FilterManagement(setId, "whiteList", EPT_ACTION_TOGGLE) end,
        },
        {
          label = zo_strformat("<<1>> <<2>>", blackListStatus and EPT_REMOVE_FROM or EPT_ADD_TO, EPT_BLACKLIST),
          callback = function() EPT.FilterManagement(setId, "blackList", EPT_ACTION_TOGGLE) end,
        },
      }
    --else
    --  entries = {
    --    {
    --      label = "Request Set",
    --      callback = function() d("set requested") end,
    --    },
    --  }
    AddCustomSubMenuItem("ExoY's ProcSet Timer" , entries)
    ShowMenu()
    end

  end)
end

-----------
-- Group --
-----------

function EPT.UpdateGroupMemberInfo(event, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
  local self = EPT
  if changeType == EFFECT_RESULT_GAINED then
    if unitTag and unitId then
      self.group.tag[unitId] = unitTag
    end
  end
end

--local num
--EPT.group["abilityId"] = num,
--EPT.group["name"] = {
--  ["roll"] = nil, --1-DD 2--Tank 4-Heal
--  ["abilityId"] = false,
--}
--GetGroupUnitTagByIndex() Index ~= tag
--GetGroupSize() -> 0=no group
--IsUnitOnline() -> boolean
--GetUnitName(unitTag)
--targetName wird nicht übergeben, aber targetId schon

function EPT.OnGroupUpdate()
  --for i = 1,GetGroupSize() do
--    if not self.group[GetUnitName("group"..i)] then
--      self.group[GetUnitName("group"..i)] = {}
--    else
--end
--  end
end

-------------------------
-- Debug/ SlashCommand --
-------------------------

function EPT.Debug(string)
  if not EPT.store.debug then return end
  d(string)
end


local function ParseScOption(option)
  local options={}
  for str in string.gmatch(option, "%S+") do
    table.insert(input, str)
  end
  return option
end

local function ProcSetDebug(option)
  local space
  space = string.find(option, " ") --Position vom ersten leerzeeichen
  d("_________________________")
  d("space"..tostring(space))
  d("_________________________")
  for str in string.gmatch(option, "%a+") do print(str) end
  d("_________________________")
  d("option:" .. tostring(option))
end

SLASH_COMMANDS["/epttest"] = ProcSetDebug


local function ToggleDebug()
		EPT.store.debug = not EPT.store.debug
		local debugMode
		if EPT.store.debug then
			debugMode = "activated"
		else
			debugMode = "deactivated"
		end
		d("ProcSet Debug Mode: "..debugMode)
end

SLASH_COMMANDS["/eptdebug"] = ToggleDebug

local function GetSetIDFromItemID(text)
	local hasSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo("|H0:item:"..text..":364:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:500:0|h|h", true)

	d("Name: "..setName.." ID: ".. setId)
end

SLASH_COMMANDS["/eptsetid"] = GetSetIDFromItemID

function EPT.DisplayTable(info, iteration)
  local tab = "-"
  for i = 0,iteration do
    tab = tab .. "-"
  end
  for key, value in pairs(info) do
    d(tab..tostring(key)..": "..tostring(value))
    if EPT.IsTable(value) then
      EPT.DisplayTable(value, iteration + 1) end
    if iteration == 0 then d("_________________________") end
  end
end

function EPT.Test()
  d(IsSetFullyEquipped(1))
end


function EPT.TestFunc(a,b,c)
  d("a: "..tostring(a))
  d("b: "..tostring(b))
  d("c: "..tostring(c))
end

function EPT.Test2()
  d("zen:" .. tostring(IsSetTracked(455)))
end

function EPT.Test4()
  d(GetMaxEquipped(20))
end

--SLASH_COMMANDS["/ept1"] = EPT.Test
--SLASH_COMMANDS["/ept2"] = EPT.Test2
--SLASH_COMMANDS["/eptdeveloptment"] = EPT.Test
