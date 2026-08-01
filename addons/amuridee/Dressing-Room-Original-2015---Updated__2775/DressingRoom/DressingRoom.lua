local function Set(...)
  local s = {}
  for _, v in ipairs({...}) do s[v] = true end
  return s
end

local function msg(fmt, ...)
  if DressingRoom.sv.options.showChatMessages then
    d(string.format(fmt, ...))
  end
end

local DEBUGLEVEL = 0
local function DEBUG(level, ...) if level <= DEBUGLEVEL then d(string.format(...)) end end

DressingRoom = {
  name = "DressingRoom",
  
  gearSlots = {
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_CHEST,
    EQUIP_SLOT_HAND,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET,
    EQUIP_SLOT_NECK,
    EQUIP_SLOT_RING1,
    EQUIP_SLOT_RING2,
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_BACKUP_OFF,
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_COSTUME,
  },
  
  twoHanded = Set(
    WEAPONTYPE_FIRE_STAFF,
    WEAPONTYPE_FROST_STAFF,
    WEAPONTYPE_HEALING_STAFF,
    WEAPONTYPE_LIGHTNING_STAFF,
    WEAPONTYPE_TWO_HANDED_AXE,
    WEAPONTYPE_TWO_HANDED_HAMMER,
    WEAPONTYPE_TWO_HANDED_SWORD),
  
  default_options = {
    clearEmptyGear = false,
    clearEmptySkill = false,
    activeBarOnly = true,
    fontSize = 18,
    btnSize = 35,
    columnMajorOrder = false,
    numRows = 4,
    numCols = 2,
    openWithSkillsWindow = false,
    openWithInventoryWindow = false,
    showChatMessages = true,
    singleBarToCurrent = false,
  },
  
  savedHandlers = {},
}


function DressingRoom:Error(fmt, ...) d(string.format("|cFF0000DressingRoom Error|r "..fmt, ...)) end


local function GetWornGear()
  local gear = {emptySlots = {}}
  local gearName = {}
  for _, gearSlot in ipairs(DressingRoom.gearSlots) do
    local itemId = GetItemUniqueId(BAG_WORN, gearSlot)
    if itemId then
      gear[Id64ToString(itemId)] = gearSlot
      gearName[#gearName+1] = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLink(BAG_WORN, gearSlot, LINK_STYLE_DEFAULT))
    elseif not ((gearSlot == EQUIP_SLOT_OFF_HAND and DressingRoom.twoHanded[GetItemWeaponType(BAG_WORN, EQUIP_SLOT_MAIN_HAND)])
             or (gearSlot == EQUIP_SLOT_BACKUP_OFF and DressingRoom.twoHanded[GetItemWeaponType(BAG_WORN, EQUIP_SLOT_BACKUP_MAIN)])) then
      -- save empty slots; off-hand is not considered empty if a two-handed weapon is equipped
      table.insert(gear.emptySlots, gearSlot)
    end
  end
  return gear, gearName
end


local function doEquip(bag, slot, gearSlot, sid)
  DEBUG(2, "EQUIP (%d, %d) TO SLOT %d", bag, slot, gearSlot)
  DressingRoom.gearQueue:add(function()
    EquipItem(bag, slot, gearSlot)
    DressingRoom.gearQueue:run()
  end)
end


local function doUnequip(gearSlot, sid)
  DEBUG(2, "UNEQUIP SLOT %d", gearSlot)
  DressingRoom.gearQueue:add(function()
    DVDInventoryWatcher.onSlotAdded(BAG_BACKPACK, sid, function() DressingRoom.gearQueue:run() end)
    UnequipItem(gearSlot)
  end)
end


local function doSwitch(oldSlot, newSlot, sid)
  DEBUG(2, "SWITCH SLOT %d AND %d", oldSlot, newSlot)
  DressingRoom.gearQueue:add(function()
    DVDInventoryWatcher.onSlotUpdated(BAG_WORN, sid, function() zo_callLater(function() DressingRoom.gearQueue:run() end, 50) end)
    EquipItem(BAG_WORN, oldSlot, newSlot)
  end)
end


local function EquipGear(gear)
  if DressingRoom.gearQueue then DressingRoom.gearQueue:clear() end
  DressingRoom.gearQueue = DVDWorkQueue:new()
  
  -- check for already worn gear, swap it around if necessary
  local slotMap = {}
  for _, gearSlot in ipairs(DressingRoom.gearSlots) do
    slotMap[gearSlot] = {
      id = Id64ToString(GetItemUniqueId(BAG_WORN, gearSlot)),
      equipType = select(6, GetItemInfo(BAG_WORN, gearSlot))
    }
  end
  local i = 1
  while i <= #DressingRoom.gearSlots do
    local gearSlot = DressingRoom.gearSlots[i]
    local itemId = slotMap[gearSlot].id
    local newSlot = gear[itemId]
    if newSlot and newSlot ~= gearSlot then
      if slotMap[newSlot].equipType == 0 or ZO_Character_DoesEquipSlotUseEquipType(gearSlot, slotMap[newSlot].equipType) then 
        doSwitch(gearSlot, newSlot, itemId)
        slotMap[gearSlot], slotMap[newSlot] = slotMap[newSlot], slotMap[gearSlot]
      else
        -- cannot switch a shield to a main hand slot, unequiping it is not a problem
        -- since an eventual shield swap is checked first
        doUnequip(newSlot, Id64ToString(GetItemUniqueId(BAG_WORN, newSlot)))
        doSwitch(gearSlot, newSlot, itemId)
        slotMap[newSlot] = slotMap[gearSlot]
        i = i + 1
      end
    else
      i = i + 1
    end
  end
  
  -- find saved gear in backpack and equip it
  local bpSize = GetBagSize(BAG_BACKPACK)
  for bpSlot = 0, bpSize do
    local id = Id64ToString(GetItemUniqueId(BAG_BACKPACK, bpSlot))
    local gearSlot = gear[id]
    if gearSlot then
      -- UniqueIds seems really unique, no need to check whether an identical item is already equipped
      doEquip(BAG_BACKPACK, bpSlot, gearSlot, id)
    end
  end
  -- if relevant option is set, unequip empty saved slots
  if DressingRoom.sv.options.clearEmptyGear then
    for _, slot in ipairs(gear.emptySlots) do
      local id = GetItemUniqueId(BAG_WORN, slot)
      if id then doUnequip(slot, Id64ToString(id)) end
    end
  end
  DressingRoom.gearQueue:run()
end


local function WeaponSetName()
  local w = GetItemWeaponType(BAG_WORN, EQUIP_SLOT_MAIN_HAND)
  local s = DressingRoom._msg.weaponType[w]
  w = GetItemWeaponType(BAG_WORN, EQUIP_SLOT_OFF_HAND)
  if w ~= WEAPONTYPE_NONE then s = s.." & "..DressingRoom._msg.weaponType[w] end
  s = s.." / "
  w = GetItemWeaponType(BAG_WORN, EQUIP_SLOT_BACKUP_MAIN)
  s = s..DressingRoom._msg.weaponType[w]
  w = GetItemWeaponType(BAG_WORN, EQUIP_SLOT_BACKUP_OFF)
  if w ~= WEAPONTYPE_NONE then s = s.." & "..DressingRoom._msg.weaponType[w] end
  return s
end


function DressingRoom:SaveGear(setId)
  local gear, gearName = GetWornGear()
  gear.text = table.concat(gearName, "\n")
  self.setLabel[setId].text = gear.text
  gear.name = WeaponSetName() 
  self.setLabel[setId]:SetText(self.sv.customSetName[setId] or gear.name)
  self.sv.gearSet[setId] = gear
  self.GearMarkers:buildMap()
  msg(self._msg.gearSetSaved, setId)
end


function DressingRoom:DeleteGear(setId)
  self.sv.gearSet[setId] = nil
  self.setLabel[setId].text = nil
  self.setLabel[setId]:SetText(nil)
  msg(self._msg.gearSetDeleted, setId)
end


function DressingRoom:LoadGear(setId)
  local gear = self.sv.gearSet[setId]
  if gear then
    EquipGear(gear)
    msg(self._msg.gearSetLoaded, setId)
  else
    msg(self._msg.noGearSaved, setId)
  end
end


function DressingRoom:DeleteSkill(setId, bar, i)
  -- delete saved skill
  self.sv.skillSet[setId][bar][i] = nil
  -- update UI button
  local btn = self.skillBtn[setId][bar][i]
  btn:SetNormalTexture("ESOUI/art/actionbar/quickslotbg.dds")
  btn:SetAlpha(0.3)
  btn.text = nil
end


local function GetSkillFromAbilityId(abilityId)
  local hasProgression, progressionIndex = GetAbilityProgressionXPInfoFromAbilityId(abilityId)
  
  if not hasProgression then
    DressingRoom:Error("Skill %s(%d) has no progressionIndex", GetAbilityName(abilityId), abilityId)
    return 0,0,0
  end
  
  -- quick path, but seems to fail sometimes (needs confirmation)
  local t, l, a = GetSkillAbilityIndicesFromProgressionIndex(progressionIndex)
  if t > 0 then return t,l,a
  else DEBUG(1, "Ability not found by ProgressionIndex for %s(%d)", GetAbilityName(abilityId), abilityId) end
  
  -- slow path
  for t = 1, GetNumSkillTypes() do
    for l = 1, GetNumSkillLines(t) do
      for a = 1, GetNumSkillAbilities(t, l) do
        local progId = select(7, GetSkillAbilityInfo(t, l, a))
        if progId == progressionIndex then return t, l, a end
      end
    end
  end
  
  DressingRoom:Error("Skill %s(%d) not found", GetAbilityName(abilityId), abilityId)
  return 0,0,0
end


function DressingRoom:SaveSkills(setId, barId)
  for i = 1, 6 do
    local abilityId = GetSlotBoundId(i+2)
    if abilityId > 0 then
      local t, l, a = GetSkillFromAbilityId(abilityId)
      local skill = {type = t, line = l, ability = a}
      self.sv.skillSet[setId][barId][i] = skill
      local btn = DressingRoom.skillBtn[setId][barId][i]
      local name, texture = GetSkillAbilityInfo(t, l, a)
      btn:SetNormalTexture(texture)
      btn:SetAlpha(1)
      btn.text = zo_strformat(SI_ABILITY_NAME, name)
    else
      self:DeleteSkill(setId, barId, i)
    end
  end
  msg(self._msg.skillBarSaved, setId, barId)
end


function DressingRoom:DeleteSkills(setId, barId)
  for i = 1, 6 do
    self:DeleteSkill(setId, barId, i)
  end
  msg(self._msg.skillBarDeleted, setId, barId)
end


local function Protected(fname)
  if IsProtectedFunction(fname) then
    return function (...) CallSecureProtected(fname, ...) end
  else
    return _G[fname]
  end
end


local ClearSlot = Protected("ClearSlot")


local function LoadSkillBar(skillBar)
  for i = 1, 6 do
    if skillBar[i] then 
      SlotSkillAbilityInSlot(skillBar[i].type, skillBar[i].line, skillBar[i].ability, i+2)
    elseif DressingRoom.sv.options.clearEmptySkill then
      ClearSlot(i+2)
    end
  end
end


function DressingRoom:LoadSkills(setId, barId)
  local pair, _ = GetActiveWeaponPairInfo()
  if (pair == barId) then
    -- if barId is the active bar, load skills immediately
    LoadSkillBar(self.sv.skillSet[setId][barId])
    msg(self._msg.skillBarLoaded, setId, barId)
  else
    -- else register an event to load skills on next weapon pair change event
    -- unregister previous callback, if any still pending
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    self.weaponSwapNeeded = true
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED,
      function (eventCode, activeWeaponPair, locked)
        if activeWeaponPair == barId then
          -- TODO: for sanity, check that the equipped weapons are consistent with the saved weapons for that setId and bar, if any
          LoadSkillBar(self.sv.skillSet[setId][barId])
          msg(self._msg.skillBarLoaded, setId, barId)
          EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
          self.weaponSwapNeeded = false
        end
      end)
  end
end


local function isSingleBar(setId)
  local hasEmptyBar = next(DressingRoom.sv.skillSet[setId][1]) == nil or next(DressingRoom.sv.skillSet[setId][2]) == nil
  return hasEmptyBar and not DressingRoom.sv.gearSet[setId]
end


function DressingRoom:LoadSet(setId)
  if self.sv.options.singleBarToCurrent and isSingleBar(setId) then
    local barId = next(self.sv.skillSet[setId][1]) and 1 or 2
    LoadSkillBar(self.sv.skillSet[setId][barId])
  else
    self:LoadSkills(setId, 1)
    self:LoadSkills(setId, 2)
  end
  self:LoadGear(setId)
end


function DressingRoom:numSets()
  return self.numRows * self.numCols
end

  
function DressingRoom:Initialize()
  -- initialize addon
  -- saved variables
  self.sv = ZO_SavedVars:New("DressingRoomSavedVariables", 1, nil, {})
  self.sv.options = self.sv.options or {}
  for k,v in pairs(self.default_options) do
    if self.sv.options[k] == nil then self.sv.options[k] = v end
  end
  self.numRows = self.sv.options.numRows
  self.numCols = self.sv.options.numCols
  self.sv.skillSet = self.sv.skillSet or {}
  self.sv.gearSet = self.sv.gearSet or {}
  for setId = 1, self:numSets() do
    self.sv.skillSet[setId] = self.sv.skillSet[setId] or
        {{}, {}}
  end
  self.sv.customSetName = self.sv.customSetName or {}

  -- addon settings menu
  self:CreateAddonMenu()
  
  -- main window
  self:CreateWindow()
  self:RefreshWindowData()
  
  -- gear markers
  self.GearMarkers:buildMap()
  self.GearMarkers:initCallbacks()
  
  -- monitor windows if requested
  self:OpenWith(ZO_Skills, self.sv.options.openWithSkillsWindow)
  self:OpenWith(ZO_PlayerInventory, self.sv.options.openWithInventoryWindow)
end


function DressingRoom.OnAddOnLoaded(event, addonName)
  if addonName ~= DressingRoom.name then return end

  DressingRoom:Initialize()
end


EVENT_MANAGER:RegisterForEvent(DressingRoom.name, EVENT_ADD_ON_LOADED, DressingRoom.OnAddOnLoaded)
