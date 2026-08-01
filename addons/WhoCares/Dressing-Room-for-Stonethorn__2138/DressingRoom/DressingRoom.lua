local function Set(...)
  local s = {}
  for _, v in ipairs({...}) do s[v] = true end
  return s
end

local function msg(fmt, ...)
  if DressingRoom.options.showChatMessages then
    d("[DressingRoom] "..string.format(fmt, ...))
  end
end

local function DeepTableCopy_Dense(source, dest)
  if type(source) ~= "table" then return source end

  local next = next
  local keep = false
  dest = dest or {}
  setmetatable(dest, getmetatable(source))

  for k, v in pairs(source) do
    if type(v) == "table" then
      if next(v) == nil then
        dest[k] = nil
      else
        dest[k] = DeepTableCopy_Dense(v)
        if dest[k] then keep = true end
      end
    else
      dest[k] = v
      keep = true
    end
  end

  if not keep then return nil end
  return dest
end

local DEBUGLEVEL = 0
local function DEBUG(level, ...) if level <= DEBUGLEVEL then d(string.format(...)) end end

DressingRoom = {
  name = "DressingRoom",
  version = "0.10.3b",

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
    EQUIP_SLOT_POISON,
    EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_BACKUP_POISON,
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
    clearEmptyPoisons = true,
    clearEmptySkill = false,
    activeBarOnly = true,
    lockWindowPosition = false,
    fontSize = 18,
    btnSize = 35,
    columnMajorOrder = false,
    numRows = 4,
    numCols = 2,
    openWithSkillsWindow = false,
    openWithInventoryWindow = false,
    showChatMessages = true,
    singleBarToCurrent = false,
    autoCloseOnMovement = false,
    enablePages = true,
    confirmPageDelete = true,
    alwaysChangePageOnZoneChanged = true,
    autoRechargeWeapons = true,
    ignoreAppearanceSlot = false,
    enableOutfits = false,
    showNotificationArea = true,
    lockNotificationArea = false,
    disableInCombat = false,
    useOldUI = false,
    roleSpecificPresets = true,
    roleFromLFGTool = false,
    autoSaveChangesOnClose = true,
  },

  savedHandlers = {},
}

DressingRoom.compat = {
  -- Data Format Version
  -- 0: Pre-0.7.0
  -- 1: 0.7.0 (2018-02-12)
  -- 2: 0.8.0 (2018-02-12)
  -- 3: 0.9.0 (2018-03-19)
  -- 4: 0.10.0 (2020-03-30)
  -- 5: 0.10.3 (2020-08-26)
  version = 5,

  -- API Version
  -- 100022: Update 17 / Dragon Bones (2018-02-12)
  api = GetAPIVersion(),

  -- New skill line mappings in API 100022 (Update 17)
  -- Apply if format version <2 and data API <100022
  u17mappings_0 = {
    [1] = { 35, 36, 37 }, -- Dragonknight
    [2] = { 41, 42, 43 }, -- Sorcerer
    [3] = { 38, 39, 40 }, -- Nightblade
    [4] = { 129, 128, 127 }, -- Warden
    [6] = { 22, 27, 28 }, -- Templar
  },
  u17mappings_1 = {
    129, 128, 127, 38, 43, 42, 41, 37, 36, 35, 28, 27, 22, 39, 40,
  },
};

DressingRoom.groupRoles = {
  [1] = "Damage",
  [2] = "Tank",
  [3] = "Healer",
}

function DressingRoom:msg(fmt, ...) msg(fmt, ...) end -- export
function DressingRoom:Warning(fmt, ...) d(string.format("[|cFF8000DressingRoom:Warning|r] "..fmt, ...)) end
function DressingRoom:Error(fmt, ...) d(string.format("[|cFF0000DressingRoom:Error|r] "..fmt, ...)) end


local function GetWornGear(self)
  local gear = {emptySlots = {}}
  local gearName = {}
  for _, gearSlot in ipairs(DressingRoom.gearSlots) do
    local itemId = GetItemUniqueId(BAG_WORN, gearSlot)
    local instanceId = GetItemInstanceId(BAG_WORN, gearSlot)
    if itemId and not (gearSlot == EQUIP_SLOT_COSTUME and self.options.ignoreAppearanceSlot) then
      if gearSlot == EQUIP_SLOT_BACKUP_POISON and instanceId == GetItemInstanceId(BAG_WORN, EQUIP_SLOT_POISON) then
        DEBUG(1, "Identical poisons equipped on both bars, keeping only on bar 1")
        table.insert(gear.emptySlots, gearSlot)
      else
        local equipType = select(6, GetItemInfo(BAG_WORN, gearSlot))
        if equipType == EQUIP_TYPE_POISON then
          gear[tostring(instanceId)] = gearSlot
        else
          gear[Id64ToString(itemId)] = gearSlot
        end
        gearName[#gearName+1] = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLink(BAG_WORN, gearSlot, LINK_STYLE_DEFAULT))
      end
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


local function EquipGear(self, gear)
  if DressingRoom.gearQueue then DressingRoom.gearQueue:clear() end
  DressingRoom.gearQueue = DVDWorkQueue:new()

  -- check for already worn gear, swap it around if necessary
  local slotMap = {}
  local mythicSlot, mythicSlotNew
  for _, gearSlot in ipairs(DressingRoom.gearSlots) do
    slotMap[gearSlot] = {
      id = Id64ToString(GetItemUniqueId(BAG_WORN, gearSlot)),
      instanceId = tostring(GetItemInstanceId(BAG_WORN, gearSlot)),
      equipType = select(6, GetItemInfo(BAG_WORN, gearSlot))
    }
    if select(9, GetItemInfo(BAG_WORN, gearSlot)) == 6 then mythicSlot = gearSlot end
  end
  local i = 1
  while i <= #DressingRoom.gearSlots do
    local gearSlot = DressingRoom.gearSlots[i]
    local itemId = slotMap[gearSlot].id
    local instanceId = slotMap[gearSlot].instanceId
    local newSlot = gear[itemId]
    if slotMap[gearSlot].equipType == EQUIP_TYPE_POISON and gear[instanceId] then
      newSlot = (instanceId ~= slotMap[gear[instanceId]].instanceId) and gear[instanceId]
    end
    if newSlot and newSlot ~= gearSlot then
      if mythicSlot == newSlot then mythicSlot = gearSlot end
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
  -- first, unequip an equipped mythic item if we want to equip a different one
  local bpSize = GetBagSize(BAG_BACKPACK)
  for bpSlot = 0, bpSize do
    local id = Id64ToString(GetItemUniqueId(BAG_BACKPACK, bpSlot))
    local gearSlot = gear[id]
    if gearSlot then
      if mythicSlot then
        if select(9, GetItemInfo(BAG_BACKPACK, bpSlot)) == 6 then mythicSlotNew = gearSlot end
        if mythicSlotNew and mythicSlot ~= mythicSlotNew then
          doUnequip(mythicSlot, slotMap[mythicSlot].id)
          mythicSlot = nil
        end
      end
    end
  end
  for bpSlot = 0, bpSize do
    local id = Id64ToString(GetItemUniqueId(BAG_BACKPACK, bpSlot))
    local instanceId = tostring(GetItemInstanceId(BAG_BACKPACK, bpSlot))
    local equipType = select(6, GetItemInfo(BAG_BACKPACK, bpSlot))
    local gearSlot = gear[id]
    -- equippable poisons
    if equipType == EQUIP_TYPE_POISON then
      gearSlot = gear[instanceId]
    end
    if gearSlot then
      -- UniqueIds seems really unique, no need to check whether an identical item is already equipped
      if not (gearSlot == EQUIP_SLOT_COSTUME and self.options.ignoreAppearanceSlot) then
        doEquip(BAG_BACKPACK, bpSlot, gearSlot, id)
      end
    end
  end
  -- if relevant option is set, unequip empty saved slots
  if DressingRoom.options.clearEmptyGear then
    for _, slot in ipairs(gear.emptySlots) do
      if not ZO_Character_DoesEquipSlotUseEquipType(slot, EQUIP_TYPE_POISON) then
        local id = GetItemUniqueId(BAG_WORN, slot)
        if not (slot == EQUIP_SLOT_COSTUME and self.options.ignoreAppearanceSlot) then
          if id then doUnequip(slot, Id64ToString(id)) end
        end
      end
    end
  end
  if DressingRoom.options.clearEmptyPoisons or DressingRoom.options.clearEmptyGear then
    local emptySlot = {}
    for _, slot in ipairs(gear.emptySlots) do
      emptySlot[slot] = true
    end
    if emptySlot[EQUIP_SLOT_POISON] and not (emptySlot[EQUIP_SLOT_MAIN_HAND] and emptySlot[EQUIP_SLOT_OFF_HAND]) then
      local id = GetItemUniqueId(BAG_WORN, EQUIP_SLOT_POISON)
      if id then doUnequip(EQUIP_SLOT_POISON, Id64ToString(id)) end
    end
    if emptySlot[EQUIP_SLOT_BACKUP_POISON] and not (emptySlot[EQUIP_SLOT_BACKUP_MAIN] and emptySlot[EQUIP_SLOT_BACKUP_OFF]) then
      local id = GetItemUniqueId(BAG_WORN, EQUIP_SLOT_BACKUP_POISON)
      if id then doUnequip(EQUIP_SLOT_BACKUP_POISON, Id64ToString(id)) end
    end
  end
  DressingRoom.gearQueue:run()

  -- absolutely disgusting workaround for an annoying game issue
  DressingRoom.unstuckRetryCount = 2
  EVENT_MANAGER:RegisterForUpdate("DressingRoom_UnstuckBars", 1500, function()
        local _, locked = GetActiveWeaponPairInfo()
        if locked and DressingRoom.unstuckRetryCount > 0 then
          --DressingRoom:Warning("Detected possibly stuck hotbar, attempting to workaround.")
          EquipItem(BAG_WORN, EQUIP_SLOT_RING1, EQUIP_SLOT_RING2)
          DressingRoom.unstuckRetryCount = DressingRoom.unstuckRetryCount - 1
        else
          EVENT_MANAGER:UnregisterForUpdate("DressingRoom_UnstuckBars")
          EVENT_MANAGER:UnregisterForEvent("DressingRoom_UnstuckBars")
        end
      end)
  EVENT_MANAGER:RegisterForEvent("DressingRoom_UnstuckBars", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function()
        EVENT_MANAGER:UnregisterForUpdate("DressingRoom_UnstuckBars")
        EVENT_MANAGER:UnregisterForEvent("DressingRoom_UnstuckBars")
      end)
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
  local gear, gearName = GetWornGear(self)
  if self.options.enableOutfits then
    gear.outfitIndex = GetEquippedOutfitIndex()
  end
  gear.text = table.concat(gearName, "\n")
  if gear.outfitIndex then
    local outfitName = GetOutfitName(gear.outfitIndex)
    if outfitName == "" then outfitName = "Outfit "..gear.outfitIndex end
    self.setLabel[setId].text = gear.text.."\n("..outfitName..")"
  else
    self.setLabel[setId].text = gear.text
  end
  gear.name = WeaponSetName()
  self.setLabel[setId]:SetText(self.ram.page.pages[self.sv.page.current].customSetName[setId] or "|cC8C8C8("..gear.name..")|r")
  self.ram.page.pages[self.sv.page.current].gearSet[setId] = gear
  self.GearMarkers:buildMap()
  msg(self._msg.gearSetSaved, setId)
--  self:StorePage()
  self:SetDirty(true)
end


function DressingRoom:DeleteGear(setId)
  self.ram.page.pages[self.sv.page.current].gearSet[setId] = nil
  self.setLabel[setId].text = nil
  self.setLabel[setId]:SetText(self.ram.page.pages[self.sv.page.current].customSetName[setId])
  self.GearMarkers:buildMap()
  msg(self._msg.gearSetDeleted, setId)
--  self:StorePage()
  self:SetDirty(true)
end


function DressingRoom:CancelPendingLoad()
  if not self.initialised then return end
  EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
  self.weaponSwapNeeded = false
  self.deferredLoad.skills = {}
  self.deferredLoad.gear = nil
  self:UpdateNotificationAreaLabel()
end


function DressingRoom:LoadGearDeferred(setId)
  self.deferredLoad.gear = setId
end

function DressingRoom:LoadGear(setId)
  if not self.initialised then return end
  if IsUnitInCombat("player") then
    if self.options.disableInCombat then return end
    self:LoadGearDeferred(setId)
    self:UpdateNotificationAreaLabel()
    return
  end

  local gear = self.ram.page.pages[self.sv.page.current].gearSet[setId]
  if gear then
    if self.options.enableOutfits then
      if gear.outfitIndex then EquipOutfit(gear.outfitIndex) else UnequipOutfit() end
    end
    EquipGear(self, gear)
    msg(self._msg.gearSetLoaded, setId)
  else
    msg(self._msg.noGearSaved, setId)
  end

  self.deferredLoad.gear = nil
  self:UpdateNotificationAreaLabel()
end


function DressingRoom:Undress()
  if not self.initialised then return end
  if IsUnitInCombat("player") then return end

  if DressingRoom.gearQueue then DressingRoom.gearQueue:clear() end
  DressingRoom.gearQueue = DVDWorkQueue:new()
  for i = 1, #DressingRoom.gearSlots do
    local slot = DressingRoom.gearSlots[i]
    local id = GetItemUniqueId(BAG_WORN, slot)
    if id then doUnequip(slot, Id64ToString(id)) end
  end
  DressingRoom.gearQueue:run()
  msg(self._msg.undressClicked)
end


function DressingRoom:DeleteSkill(setId, bar, i)
  -- delete saved skill
  self.ram.page.pages[self.sv.page.current].skillSet[setId][bar][i] = nil
  -- update UI button
  local btn = self.skillBtn[setId][bar][i]
  btn:SetNormalTexture("ESOUI/art/actionbar/quickslotbg.dds")
  btn:SetAlpha(0.3)
  btn.text = nil
--  self:StorePage()
  self:SetDirty(true)
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

function DressingRoom:GetSkillFromAbilityId(abilityId) -- export
  return GetSkillFromAbilityId(abilityId)
end


function DressingRoom:SaveSkills(setId, barId)
  for i = 1, 6 do
    local abilityId = GetSlotBoundId(i+2)
    if abilityId > 0 then
      local t, l, a = GetSkillFromAbilityId(abilityId)
      local _, _, _, id = GetSkillLineInfo(t, l);
      local skill = {skillLineId = id, ability = a}
      self.ram.page.pages[self.sv.page.current].skillSet[setId][barId][i] = skill
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
--  self:StorePage()
  self:SetDirty(true)
end


function DressingRoom:DeleteSkills(setId, barId)
  for i = 1, 6 do
    self:DeleteSkill(setId, barId, i)
  end
  msg(self._msg.skillBarDeleted, setId, barId)
--  self:StorePage()
  self:SetDirty(true)
end


local function Protected(fname)
  if IsProtectedFunction(fname) then
    return function (...) CallSecureProtected(fname, ...) end
  else
    return _G[fname]
  end
end


local ClearSlot = Protected("ClearSlot")


local function IsSameSkill(abilityId1, abilityId2)
  local t1, l1, a1 = GetSkillFromAbilityId(abilityId1)
  local t2, l2, a2 = GetSkillFromAbilityId(abilityId2)
  return ((t1 == t2) and (l1 == l2) and (a1 == a2))
end


local function LoadSkillBar(skillBar)
  for i = 1, 6 do
    if skillBar[i] then
      local type, line = GetSkillLineIndicesFromSkillId(skillBar[i].skillLineId)
      if not IsSameSkill(GetSlotBoundId(i+2), GetSkillAbilityId(type, line, skillBar[i].ability)) then
        SlotSkillAbilityInSlot(type, line, skillBar[i].ability, i+2)
      end
    elseif DressingRoom.options.clearEmptySkill and GetSlotBoundId(i+2) ~= 0 then
      ClearSlot(i+2)
    end
  end
end


function DressingRoom:LoadSkillsDeferred(setId, barId)
  self.deferredLoad.skills = self.deferredLoad.skills or {}
  self.deferredLoad.skills[barId] = setId
end

function DressingRoom:LoadSkills(setId, barId)
  if not self.initialised then return end
  if IsUnitInCombat("player") then
    if self.options.disableInCombat then return end
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    self:LoadSkillsDeferred(setId, barId)
    self:UpdateNotificationAreaLabel()
    return
  end

  local pair, _ = GetActiveWeaponPairInfo()
  if (pair == barId) then
    -- if barId is the active bar, load skills immediately
    LoadSkillBar(self.ram.page.pages[self.sv.page.current].skillSet[setId][barId])
    self.deferredLoad.skills[barId] = nil
    msg(self._msg.skillBarLoaded, setId, barId)
  else
    -- else register an event to load skills on next weapon pair change event
    -- unregister previous callback, if any still pending
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    self.weaponSwapNeeded = true
    self:UpdateNotificationAreaLabel()
    local pageId = self.sv.page.current
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED,
      function (eventCode, activeWeaponPair, locked)
        if activeWeaponPair == barId then
          -- TODO: for sanity, check that the equipped weapons are consistent with the saved weapons for that setId and bar, if any
--          LoadSkillBar(self.ram.page.pages[pageId].skillSet[setId][barId])
--          msg(self._msg.skillBarLoaded, setId, barId)
          self:LoadSkills(setId, barId) -- take care of postponing the load here
          EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
          self.weaponSwapNeeded = false
          self:UpdateNotificationAreaLabel()
        end
      end)
  end
  self:UpdateNotificationAreaLabel()
end


local function isSingleBar(setId)
  local hasEmptyBar = next(DressingRoom.ram.page.pages[DressingRoom.ram.page.current].skillSet[setId][1]) == nil or next(DressingRoom.ram.page.pages[DressingRoom.ram.page.current].skillSet[setId][2]) == nil
  return hasEmptyBar and not DressingRoom.ram.page.pages[DressingRoom.ram.page.current].gearSet[setId]
end


function DressingRoom:LoadSet(setId)
  if not self.initialised then return end
  if IsUnitInCombat("player") and self.options.disableInCombat then return end

  if setId > self:numSets() then return end
  local currentPage = self.ram.page.pages[self.sv.page.current]
  local setName = currentPage.customSetName[setId]
  setName = setName or (currentPage.gearSet[setId] and currentPage.gearSet[setId].name)
  setName = setName or "Set "..setId
  setName = string.format("'%s'", setName)
  if self.enablePages and self.ram.page.name[self.sv.page.current] then setName = string.format("%s (%s)", setName, self.ram.page.name[self.sv.page.current]) end
  msg(self._msg.loadingSet, setName)
  self.currentSetName = setName
  if self.roleSpecificPresets then
    self.currentSetIcon = string.format("|t32:32:%s|t ", DressingRoom:GetRoleIconTexturePath(self.currentGroupRole))
  else
    self.currentSetIcon = ""
  end
  self:UpdateNotificationAreaLabel()
  if next(currentPage.skillSet[setId][1]) ~= nil or next(currentPage.skillSet[setId][2]) ~= nil then
    if self.options.singleBarToCurrent and isSingleBar(setId) then
      local barId = next(currentPage.skillSet[setId][1]) and 1 or 2
      LoadSkillBar(currentPage.skillSet[setId][barId])
    else
      self:LoadSkills(setId, 1)
      self:LoadSkills(setId, 2)
    end
  end
  self:LoadGear(setId)
end


function DressingRoom:numSets()
  return self.numRows * self.numCols
end

function DressingRoom:CheckDataCompatibility()
  self.sv.compat = self.sv.compat or { version = 0, api = 0 };

  -- New skill line mappings in API 100022 (Update 17)
  local classId = GetUnitClassId("player");
  if (self.compat.api >= 100022 and self.sv.compat.version < 2 and self.sv.skillSet and self.compat.u17mappings_0[classId]) then
    for setId = 1, self:numSets() do
      for i = 1, 2 do
        for j = 1, 6 do
          if (self.sv.skillSet[setId][i][j]) then
            local skillType = self.sv.skillSet[setId][i][j].type;
            local skillIndex = self.sv.skillSet[setId][i][j].line;
            _, _, _, self.sv.skillSet[setId][i][j].skillLineId = GetSkillLineInfo(skillType, skillIndex);

            if (self.sv.compat.api < 100022) then
              if (skillType == SKILL_TYPE_CLASS and skillIndex < 4) then
                  self.sv.skillSet[setId][i][j].skillLineId = self.compat.u17mappings_0[classId][skillIndex];
              elseif (skillType == SKILL_TYPE_AVA and skillIndex == 2) then
                  self.sv.skillSet[setId][i][j].skillLineId = 67;
              end
            elseif (self.sv.compat.version == 1 and skillType == SKILL_TYPE_CLASS) then
              self.sv.skillSet[setId][i][j].skillLineId = self.compat.u17mappings_1[skillIndex];
            end
          end
        end
      end
    end
  end

  -- Migrate existing data to the new paged system
  if (self.sv.compat.version < 3 and self.sv.skillSet) then
    self.ram.page.pages[1].customSetName = self.sv.customSetName
    self.ram.page.pages[1].gearSet = self.sv.gearSet
    self.ram.page.pages[1].skillSet = self.sv.skillSet
    self.sv.customSetName = nil;
    self.sv.gearSet = nil;
    self.sv.skillSet = nil;
  end

  if (self.sv.compat.version < 4 and not self.ram.page.byRole) then
    self.ram.page.byRole = {[self.sv.defaultRole] = self.ram.page.pages}
    self.sv.page = {byRole = {}, name = {}}
    for j in ipairs(self.groupRoles) do
      if j ~= self.sv.defaultRole then
        self.ram.page.byRole[j] = {}
      end
      self.sv.page.byRole[j] = {}
    end
    self.ram.page.name = {}
    for i = 1, #self.ram.page.pages do
      self.ram.page.name[i] = self.ram.page.pages[i].name
      self.ram.page.pages[i].name = nil
      for j in ipairs(self.groupRoles) do
        if j ~= self.sv.defaultRole then
          self.ram.page.byRole[j][i] = {}
        end
        self.sv.page.byRole[j][i] = {}
      end
    end
    local oldPages = DeepTableCopy_Dense(self.ram.page.byRole[self.sv.defaultRole])
    if oldPages then
      self.sv.page.byRole[self.sv.defaultRole] = oldPages
    end
    self.sv.page.name = ZO_DeepTableCopy(self.ram.page.name)
  end

  --fix for a botched update, TODO remove this in a future version
  for j in ipairs(self.groupRoles) do
    self.ram.page.byRole[j] = self.ram.page.byRole[j] or {}
    self.sv.page.byRole[j] = self.sv.page.byRole[j] or {}
    for i = 1, #self.ram.page.name do
      self.ram.page.byRole[j][i] = self.ram.page.byRole[j][i] or {}
      self.sv.page.byRole[j][i] = self.sv.page.byRole[j][i] or {}
    end
  end

  -- Rapid Maneuver and Vigor swapped in U27
  if (self.compat.api >= 100032 and self.sv.compat.version < 5) then
    for page = 1, #self.ram.page.byRole[self.sv.defaultRole] do
      self:PopulatePage(page)
      for role in ipairs(self.groupRoles) do
        for setId = 1, self:numSets() do
          for i = 1, 2 do
            local skillBar = self.ram.page.byRole[role][page].skillSet[setId][i]
            for sk = 1, 6 do
              if (skillBar[sk]) then
                local type, line = GetSkillLineIndicesFromSkillId(skillBar[sk].skillLineId)
                if (type == SKILL_TYPE_AVA and line == 1) then
                  if (skillBar[sk].ability == 2) then
                    skillBar[sk].ability = 3
                  elseif (skillBar[sk].ability == 3) then
                    skillBar[sk].ability = 2
                  end
                end
              end
            end
          end
        end
      end
      self:StorePage(page)
    end
  end

  self.sv.compat.version = self.compat.version;
  self.sv.compat.api = self.compat.api;
end

function DressingRoom:SetUpAutoCloseOnMovement(enabled)
  if enabled then
    EVENT_MANAGER:RegisterForEvent("DressingRoom_PlayerMove", EVENT_NEW_MOVEMENT_IN_UI_MODE,
      function() if not DressingRoomWin:IsControlHidden() then SCENE_MANAGER:ToggleTopLevel(DressingRoomWin) end end)
  else
    EVENT_MANAGER:UnregisterForEvent("DressingRoom_PlayerMove", EVENT_NEW_MOVEMENT_IN_UI_MODE)
  end
end

function DressingRoom:StorePage(i)
  if not i then i = self.sv.page.current end
  if i > #self.ram.page.pages then return end

  for j in ipairs(self.groupRoles) do
    self.sv.page.byRole[j][i] = DeepTableCopy_Dense(self.ram.page.byRole[j][i]) or {}
  end
  self.sv.page.name[i] = self.ram.page.name[i] or "New Page "..i
end

function DressingRoom:StoreAll()
  for i = 1, #self.ram.page.pages do
    self:StorePage(i)
  end
  while #self.sv.page.name > #self.ram.page.name do
    for j in ipairs(self.groupRoles) do
      self.sv.page.byRole[j][#self.sv.page.name] = nil
    end
    self.sv.page.name[#self.sv.page.name] = nil
  end
  self:SetDirty(false)
end

function DressingRoom:UndoAll()
  self.ram.page = ZO_DeepTableCopy(self.sv.page)
  self.ram.page.pages = self.ram.page.byRole[self.currentGroupRole]
  for i = 1, #self.ram.page.pages do
    self:PopulatePage(i)
  end
  if self.sv.page.current > #self.ram.page.pages then self.sv.page.current = 1 end
  self:SetDirty(false)
  self:RefreshWindowData()
end

function DressingRoom:PopulatePage(i)
  self.ram.page.name[i] = self.ram.page.name[i] or "New Page "..i
  for j in ipairs(self.groupRoles) do
    self.ram.page.byRole[j][i].skillSet = self.ram.page.byRole[j][i].skillSet or {}
    self.ram.page.byRole[j][i].gearSet = self.ram.page.byRole[j][i].gearSet or {}
    for setId = 1, self:numSets() do
      self.ram.page.byRole[j][i].skillSet[setId] = self.ram.page.byRole[j][i].skillSet[setId] or {}
      for barId = 1, 2 do
        self.ram.page.byRole[j][i].skillSet[setId][barId] = self.ram.page.byRole[j][i].skillSet[setId][barId] or {}
      end
    end
    self.ram.page.byRole[j][i].customSetName = self.ram.page.byRole[j][i].customSetName or {}
  end
end

function DressingRoom:AddPage(name)
  local i = #self.ram.page.pages + 1
  for j in ipairs(self.groupRoles) do
    self.ram.page.byRole[j][i] = {}
  end
  self.ram.page.name[i] = name or GetUnitZone("player")
  self:PopulatePage(i)
--  self:StorePage(i)
  self:SetDirty(true)
end

function DressingRoom:DeleteCurrentPage()
  for i = self.sv.page.current, #self.ram.page.pages do
    for j in ipairs(self.groupRoles) do
      self.ram.page.byRole[j][i] = self.ram.page.byRole[j][i + 1]
--      self.sv.page.byRole[j][i] = self.sv.page.byRole[j][i + 1]
    end
    self.ram.page.name[i] = self.ram.page.name[i + 1]
--    self.sv.page.name[i] = self.sv.page.name[i + 1]
  end
  if self.sv.page.current > #self.ram.page.pages then
    self.sv.page.current = #self.ram.page.pages
  end
  self:SetDirty(true)
  self:RefreshWindowData()
  self.GearMarkers:buildMap()
end

function DressingRoom:SetDirty(dirty)
  self.dirty = dirty
end

function DressingRoom:SelectPage(pageId)
  if not self.initialised then return end
  if self.isDeletingPage then return end
  if not self.enablePages then return end

--  self:StorePage()
  if pageId > #self.ram.page.pages then
    self.sv.page.current = #self.ram.page.pages
  elseif pageId < 1 then
    self.sv.page.current = 1
  else
    self.sv.page.current = pageId
  end
  self:RefreshWindowData()
end

function DressingRoom:SelectPreviousPage()
  self:SelectPage(self.sv.page.current - 1)
end

function DressingRoom:SelectNextPage()
  self:SelectPage(self.sv.page.current + 1)
end

function DressingRoom:SelectGroupRole(groupRole)
--  self:StorePage()
  self.ram.page.pages = self.ram.page.byRole[groupRole]
  self.currentGroupRole = groupRole
  self:RefreshWindowData()
  self:UpdateNotificationAreaLabel()
end

function DressingRoom:ToggleGroupRole()
  if not self.roleSpecificPresets then return end
  self:SelectGroupRole((self.currentGroupRole % #self.groupRoles) + 1)
end

function DressingRoom:GetGroupRoleFromLFGTool(role)
  local groupRole = {
    [LFG_ROLE_DPS] = 1,
    [LFG_ROLE_TANK] = 2,
    [LFG_ROLE_HEAL] = 3,
  }

  return groupRole[role or GetSelectedLFGRole()] or 1
end

function DressingRoom:OnZoneChanged()
  if not self.enablePages then return end

  local zone = GetUnitZone("player")
  if zone ~= self.lastZone then
    if self.options.alwaysChangePageOnZoneChanged and self.lastZone then
      self.sv.page.current = 1
    end
    for i = 1, #self.ram.page.pages do
      if self.ram.page.name[i] == zone then
        self.sv.page.current = i
        break
      end
    end
    self.lastZone = zone
    self:RefreshWindowData()
  end
end

function DressingRoom:RechargeItem(slotId)
  local bagId = BAG_WORN
  local charges, maxCharges = GetChargeInfoForItem(bagId, slotId)
  local soulGemSlotIndex
  if charges / maxCharges < 0.01 then
    for k, v in pairs(SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_BACKPACK)) do
      if IsItemSoulGem(SOUL_GEM_TYPE_FILLED, BAG_BACKPACK, v.slotIndex) then
        soulGemSlotIndex = v.slotIndex
      end
      if GetItemId(BAG_BACKPACK, v.slotIndex) == 33271 then
        ChargeItemWithSoulGem(bagId, slotId, BAG_BACKPACK, v.slotIndex) -- use "Soul Gem" first, if available
        msg(self._msg.rechargedWeapon, GetItemName(bagId, slotId), GetItemName(BAG_BACKPACK, v.slotIndex))
        return
      end
    end
    if soulGemSlotIndex then
      ChargeItemWithSoulGem(bagId, slotId, BAG_BACKPACK, soulGemSlotIndex) -- otherwise, use any other type
      msg(self._msg.rechargedWeapon, GetItemName(bagId, slotId), GetItemName(BAG_BACKPACK, soulGemSlotIndex))
    end
  end
end

function DressingRoom:RechargeAll()
  self:RechargeItem(EQUIP_SLOT_OFF_HAND)
  self:RechargeItem(EQUIP_SLOT_BACKUP_OFF)
  self:RechargeItem(EQUIP_SLOT_MAIN_HAND)
  self:RechargeItem(EQUIP_SLOT_BACKUP_MAIN)
end

function DressingRoom:OnInventorySingleSlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
  if not self.options.autoRechargeWeapons then return end
  if inventoryUpdateReason ~= INVENTORY_UPDATE_REASON_ITEM_CHARGE then return end
  if bagId ~= BAG_WORN then return end
  if not IsItemChargeable(bagId, slotId) then return end
  if not GetItemInfo(bagId, slotId) then return end
  self:RechargeItem(slotId)
end

function DressingRoom:PurgeCharacterData()
  for k, v in pairs(getmetatable(self.sv).__index) do
    self.sv[k] = nil
  end
  ReloadUI()
end

function DressingRoom:ImportPresetsFromCharacter(characterIndex, purge)
  local characterName, _, _, _, _, _, characterId, _ = GetCharacterInfo(characterIndex)
  characterName = characterName:gsub("%^%a+$", "")
  self.sv_other = ZO_SavedVars:New("DressingRoomSavedVariables", 1, nil, {}, nil, GetDisplayName(), characterName, characterId)
  if purge then
    self.sv.page = self.sv_other.page
  else
    local numPages = #self.ram.page.pages
    for i = 1, #self.sv_other.page.name do
      for j in ipairs(self.groupRoles) do
        self.sv.page.byRole[j][i + numPages] = self.sv_other.page.byRole[j][i]
      end
      self.sv.page.name[i + numPages] = self.sv_other.page.name[i]
    end
  end
  ReloadUI()
end

function DressingRoom:ChangeDefaultRole(roleName, exchangePages)
  local roles = {
    ["Damage"] = 1,
    ["Tank"] = 2,
    ["Healer"] = 3,
  }
  local role = roles[roleName]
  if not role then return end
  if role == self.sv.defaultRole then return end
--  self:StorePage()
  if exchangePages then
    local t = self.sv.page.byRole[role]
    self.sv.page.byRole[role] = self.sv.page.byRole[self.sv.defaultRole]
    self.sv.page.byRole[self.sv.defaultRole] = t
  end
  self.sv.defaultRole = role
  ReloadUI()
end

function DressingRoom:CombatState(inCombat)
  if inCombat then
    -- entered combat, check weapon charges
    if self.options.autoRechargeWeapons then self:RechargeAll() end
    self:UpdateNotificationAreaLabel()
  else
    -- exited combat, finish loading any pending presets
    self.weaponSwapNeeded = false -- a bit hacky, change this var without updating the notification area label - should rewrite this entire logic some time
    if self.deferredLoad.skills[1] then self:LoadSkills(self.deferredLoad.skills[1], 1) end
    if self.deferredLoad.skills[2] then self:LoadSkills(self.deferredLoad.skills[2], 2) end
    if self.deferredLoad.gear then self:LoadGear(self.deferredLoad.gear) end
  end
end

function DressingRoom:PreInitialize()
  self.sv = ZO_SavedVars:New("DressingRoomSavedVariables", 1, nil, {})

  if not self.sv or not self.sv.page or not self.sv.page.byRole then
    self:CreateSetupWindow()
  else
    self:Initialize()
  end
end

function DressingRoom:SetUpdateSelectedLFGRoleHook(enable)
  if not self.roleSpecificPresets then return end

  if not self.UpdateSelectedLFGRole_orig or not self.UpdateSelectedLFGRole_hook then
    self.UpdateSelectedLFGRole_orig = UpdateSelectedLFGRole
    self.UpdateSelectedLFGRole_hook = function(role)
      self:SelectGroupRole(self:GetGroupRoleFromLFGTool(role))
      self.UpdateSelectedLFGRole_orig(role)
    end
  end

  if enable then
    UpdateSelectedLFGRole = self.UpdateSelectedLFGRole_hook
  else
    UpdateSelectedLFGRole = self.UpdateSelectedLFGRole_orig
  end
end

function DressingRoom:Initialize()
  -- initialize addon
  -- saved variables
  self.sv = self.sv or ZO_SavedVars:New("DressingRoomSavedVariables", 1, nil, {})
  self.svAccWide = ZO_SavedVars:NewAccountWide("DressingRoomSavedVariables", 1, nil, {})
  if self.svAccWide.accountWideSettings then
    self.svAccWide.options = self.svAccWide.options or {}
    self.options = self.svAccWide.options
  else
    self.sv.options = self.sv.options or {}
    self.options = self.sv.options
  end

  if not self.sv.compat then
    self.sv.compat = {
      version = self.compat.version,
      api = self.compat.api
    }
  end
  for k,v in pairs(self.default_options) do
    if self.options[k] == nil then self.options[k] = v end
  end
  self.numRows = self.options.numRows
  self.numCols = self.options.numCols
  self.ram = {}
  self.sv.defaultRole = self.sv.defaultRole or self.selectedDefaultRole or self:GetGroupRoleFromLFGTool()
  if (not self.sv.page) or (self.sv.compat.version >= 5 and ((not self.sv.page.name) or (#self.sv.page.name == 0))) then
    self.ram.page = {}
    self.ram.page.byRole = {}
    for j in ipairs(self.groupRoles) do
      self.ram.page.byRole[j] = {}
    end
    self.ram.page.name = {}
    self.sv.page = ZO_DeepTableCopy(self.ram.page)
    self.ram.page.pages = self.ram.page.byRole[self.sv.defaultRole]
    self:AddPage("Default")
    self:StoreAll()
  else
    self.ram.page = ZO_DeepTableCopy(self.sv.page)
    -- if not initialising with pre-0.10.0 data
    if type(self.ram.page.byRole) == "table" then
      self.ram.page.pages = self.ram.page.byRole[self.sv.defaultRole]
    end
  end

  -- apply any necessary compatibility conversions
  self:CheckDataCompatibility()

  self.ram.page.pages = self.ram.page.byRole[self.sv.defaultRole]
  self.sv.page.current = self.sv.page.current or 1
  if self.sv.page.current > #self.ram.page.pages then self.sv.page.current = 1 end

  self.enablePages = self.options.enablePages
  if self.enablePages then
    for i = 1, #self.ram.page.pages do
      self:PopulatePage(i)
    end
  else
    self:PopulatePage(1)
  end

  -- addon settings menu
  self:CreateAddonMenu()

  -- main window
  self.useOldUI = self.options.useOldUI
  self.roleSpecificPresets = self.options.roleSpecificPresets
  self:CreateWindow()
  if self.roleSpecificPresets then
    if self.options.roleFromLFGTool then
      self:SelectGroupRole(self:GetGroupRoleFromLFGTool())
    else
      self:SelectGroupRole(self.sv.defaultRole)
    end
    self:SetUpdateSelectedLFGRoleHook(self.options.roleFromLFGTool)
  else
    self:SelectGroupRole(self.sv.defaultRole or 1)
  end
  self:RefreshWindowData()

  SCENE_MANAGER:HideTopLevel(DressingRoomWin)

  -- notification area
  --self.notificationAreaWelcomeText = "<"..ZO_Keybindings_GetBindingStringFromAction("DRESSINGROOM_TOGGLE").."> || /dr"
  self.notificationAreaWelcomeText = "Version "..self.version
  self:CreateNotificationArea()

  -- gear markers
  self.GearMarkers:buildMap()
  self.GearMarkers:initCallbacks()

  -- monitor windows if requested
  self:OpenWith(ZO_Skills, self.options.openWithSkillsWindow)
  self:OpenWith(ZO_PlayerInventory, self.options.openWithInventoryWindow)
  self:SetUpAutoCloseOnMovement(self.options.autoCloseOnMovement)
  EVENT_MANAGER:RegisterForEvent(DressingRoom.name.."_AutoRecharge", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...) self:OnInventorySingleSlotUpdate(...) end)

  CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function() self:OnZoneChanged() end)

  -- for automatically loading presets once out of combat
  self.deferredLoad = {skills = {}}
  EVENT_MANAGER:RegisterForEvent(DressingRoom.name, EVENT_PLAYER_COMBAT_STATE, function(_, inCombat) self:CombatState(inCombat) end)

  SLASH_COMMANDS["/dr"] = function() DressingRoom:ToggleWindow() end

  self.initialised = true
end


function DressingRoom.OnAddOnLoaded(event, addonName)
  if addonName ~= DressingRoom.name then return end

  DressingRoom:PreInitialize()
end


EVENT_MANAGER:RegisterForEvent(DressingRoom.name, EVENT_ADD_ON_LOADED, DressingRoom.OnAddOnLoaded)
