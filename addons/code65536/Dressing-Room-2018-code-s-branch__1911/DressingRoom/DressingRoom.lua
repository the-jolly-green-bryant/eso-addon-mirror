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
    alwaysChangePageOnZoneChanged = true,
  },

  savedHandlers = {},
  manualPageChange = false,
}

DressingRoom.compat = {
  -- Data Format Version
  -- 0: Pre-0.7.0
  -- 1: 0.7.0 (2018-02-12)
  -- 2: 0.8.0 (2018-02-12)
  -- 3: 0.9.0 (2018-03-19)
  -- 4: 0.12.0 (2024-06-03)
  version = 4,

  -- API Version
  -- 100022: Update 17 / Dragon Bones (2018-02-12)
  -- 100042: Update 42 / Gold Road (2024-06-03)
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
  self.setLabel[setId]:SetText(self.sv.page.pages[self.sv.page.current].customSetName[setId] or gear.name)
  self.sv.page.pages[self.sv.page.current].gearSet[setId] = gear
  self.GearMarkers:buildMap()
  msg(self._msg.gearSetSaved, setId)
end


function DressingRoom:DeleteGear(setId)
  self.sv.page.pages[self.sv.page.current].gearSet[setId] = nil
  self.setLabel[setId].text = nil
  self.setLabel[setId]:SetText(nil)
  msg(self._msg.gearSetDeleted, setId)
end


function DressingRoom:LoadGear(setId)
  local gear = self.sv.page.pages[self.sv.page.current].gearSet[setId]
  if gear then
    EquipGear(gear)
    msg(self._msg.gearSetLoaded, setId)
  else
    msg(self._msg.noGearSaved, setId)
  end
end


function DressingRoom:DeleteSkill(setId, bar, i)
  -- delete saved skill
  self.sv.page.pages[self.sv.page.current].skillSet[setId][bar][i] = nil
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
    local slotType = GetSlotType(i+2)
    local abilityId = GetSlotBoundId(i+2)
    if slotType == ACTION_TYPE_ABILITY then
      self.sv.page.pages[self.sv.page.current].skillSet[setId][barId][i] = abilityId
      self:SetButton(DressingRoom.skillBtn[setId][barId][i], abilityId)
    elseif slotType == ACTION_TYPE_CRAFTED_ABILITY then
      local realId = GetAbilityIdForCraftedAbilityId(abilityId)
      self.sv.page.pages[self.sv.page.current].skillSet[setId][barId][i] = string.format("C:%d:%d", abilityId, realId)
      self:SetButton(DressingRoom.skillBtn[setId][barId][i], realId)
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
    if type(skillBar[i]) == "number" then
      local t, l, idx = GetSkillFromAbilityId(skillBar[i])
      if t > 0 then
        SlotSkillAbilityInSlot(t, l, idx, i+2)
      end
    elseif type(skillBar[i]) == "string" then
      local craftedAbilityId = select(2, zo_strsplit(":", skillBar[i]))
      local t, l, idx = GetSkillAbilityIndicesFromCraftedAbilityId(tonumber(craftedAbilityId))
      if t > 0 then
        SlotSkillAbilityInSlot(t, l, idx, i+2)
      end
    elseif DressingRoom.sv.options.clearEmptySkill then
      ClearSlot(i+2)
    end
  end
end


function DressingRoom:LoadSkills(setId, barId)
  local pair, _ = GetActiveWeaponPairInfo()
  if (pair == barId) then
    -- if barId is the active bar, load skills immediately
    LoadSkillBar(self.sv.page.pages[self.sv.page.current].skillSet[setId][barId])
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
          LoadSkillBar(self.sv.page.pages[self.sv.page.current].skillSet[setId][barId])
          msg(self._msg.skillBarLoaded, setId, barId)
          EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
          self.weaponSwapNeeded = false
        end
      end)
  end
end


local function isSingleBar(setId)
  local hasEmptyBar = next(DressingRoom.sv.page.pages[self.sv.page.current].skillSet[setId][1]) == nil or next(DressingRoom.sv.page.pages[self.sv.page.current].skillSet[setId][2]) == nil
  return hasEmptyBar and not DressingRoom.sv.page.pages[self.sv.page.current].gearSet[setId]
end


function DressingRoom:LoadSet(setId)
  if self.sv.options.singleBarToCurrent and isSingleBar(setId) then
    local barId = next(self.sv.page.pages[self.sv.page.current].skillSet[setId][1]) and 1 or 2
    LoadSkillBar(self.sv.page.pages[self.sv.page.current].skillSet[setId][barId])
  else
    self:LoadSkills(setId, 1)
    self:LoadSkills(setId, 2)
  end
  self:LoadGear(setId)
end


function DressingRoom:numSets()
  return self.numRows * self.numCols
end

function DressingRoom:CheckDataCompatibility()
  self.sv.compat = self.sv.compat or { version = 0, api = 0 }

  -- New skill line mappings in API 100022 (Update 17)
  if (self.compat.api >= 100022 and self.sv.compat.version < 2 and self.sv.skillSet) then
    local classId = GetUnitClassId("player")
    for setId = 1, self:numSets() do
      for i = 1, 2 do
        for j = 1, 6 do
          if (self.sv.skillSet[setId][i][j]) then
            local skillType = self.sv.skillSet[setId][i][j].type
            local skillIndex = self.sv.skillSet[setId][i][j].line
            _, _, _, self.sv.skillSet[setId][i][j].skillLineId = GetSkillLineInfo(skillType, skillIndex)

            if (self.sv.compat.api < 100022) then
              if (skillType == SKILL_TYPE_CLASS and skillIndex < 4) then
                  self.sv.skillSet[setId][i][j].skillLineId = self.compat.u17mappings_0[classId][skillIndex]
              elseif (skillType == SKILL_TYPE_AVA and skillIndex == 2) then
                  self.sv.skillSet[setId][i][j].skillLineId = 67
              end
            elseif (self.sv.compat.version == 1 and skillType == SKILL_TYPE_CLASS) then
              self.sv.skillSet[setId][i][j].skillLineId = self.compat.u17mappings_1[skillIndex]
            end
          end
        end
      end
    end
  end

  -- Migrate existing data to the new paged system
  if (self.sv.compat.version < 3 and self.sv.skillSet) then
    self.sv.page.pages[1].customSetName = self.sv.customSetName
    self.sv.page.pages[1].gearSet = self.sv.gearSet
    self.sv.page.pages[1].skillSet = self.sv.skillSet
    self.sv.customSetName = nil
    self.sv.gearSet = nil
    self.sv.skillSet = nil
  end

  -- Migrate to the new post-scribing system (Update 42)
  local getScribingOffsets = function(t,l)
    local results = { }
    for i = 1, GetNumSkillAbilities(t, l) do
      if IsCraftedAbilitySkill(t, l, i) then
        table.insert(results, i)
      end
    end
    return results
  end

  if (self.sv.compat.version < 4) then
    for _, page in ipairs(self.sv.page.pages) do
      for _, set in ipairs(page.skillSet) do
        for _, bar in ipairs(set) do
          for i = 1, 6 do
            if (type(bar[i]) == "table") then
              if bar[i].skillLineId then
                local t, l = GetSkillLineIndicesFromSkillLineId(bar[i].skillLineId)
                local idx = bar[i].ability
                for _, offset in ipairs(getScribingOffsets(t, l)) do
                  if idx >= offset then
                    idx = idx + 1
                  end
                end
                bar[i] = GetSkillAbilityId(t, l, idx)
              else
                bar[i] = 0
              end
            end
          end
        end
      end
    end
  end

  self.sv.compat.version = self.compat.version
  self.sv.compat.api = self.compat.api
end

function DressingRoom:PopulatePage(i)
  self.sv.page.pages[i].name = self.sv.page.pages[i].name or "New Page "..i
  self.sv.page.pages[i].skillSet = self.sv.page.pages[i].skillSet or {}
  self.sv.page.pages[i].gearSet = self.sv.page.pages[i].gearSet or {}
  for setId = 1, self:numSets() do
    self.sv.page.pages[i].skillSet[setId] = self.sv.page.pages[i].skillSet[setId] or
    {{}, {}}
  end
  self.sv.page.pages[i].customSetName = self.sv.page.pages[i].customSetName or {}
end

function DressingRoom:AddPage(name)
  local i = #self.sv.page.pages + 1
  self.sv.page.pages[i] = {}
  self.sv.page.pages[i].name = name or GetUnitZone("player")
  self:PopulatePage(i)
end

function DressingRoom:OnZoneChanged()
  local zone = GetUnitZone("player")
  if zone ~= self.lastZone then
    self.lastZone = zone
    for i = 1, #self.sv.page.pages do
      if self.sv.page.pages[i].name == zone then
        self.sv.page.current = i
        self.manualPageChange = false
        self:RefreshWindowData()
        return
      end
    end
    if self.sv.options.alwaysChangePageOnZoneChanged and not self.manualPageChange then
      self.sv.page.current = 1
      self:RefreshWindowData()
    end
  end
end

function DressingRoom:Initialize()
  -- initialize addon
  -- saved variables
  self.sv = ZO_SavedVars:NewCharacterIdSettings("DressingRoomSavedVariables", 1, nil, {})
  if not self.sv.options then
    self.sv.options = {}
    self.sv.compat = {
      version = self.compat.version,
      api = self.compat.api
    }
  end
  for k,v in pairs(self.default_options) do
    if self.sv.options[k] == nil then self.sv.options[k] = v end
  end
  self.numRows = self.sv.options.numRows
  self.numCols = self.sv.options.numCols
  if not self.sv.page then
    self.sv.page = {}
    self.sv.page.current = 1
    self.sv.page.pages = {}
    self:AddPage("Default")
  end

  if not self.sv.page.pages or self.sv.page.byRole then
    local name = "DressingRoom_Fork_Warning"
    EVENT_MANAGER:RegisterForEvent(name, EVENT_PLAYER_ACTIVATED, function()
      EVENT_MANAGER:UnregisterForEvent(name, EVENT_PLAYER_ACTIVATED)
      zo_callLater(function()
        CHAT_ROUTER:AddSystemMessage("WARNING: 'Dressing Room 2018' is incompatible with the newer 'Dressing Room for Stonethorn', and it appears that your data is in the latter's format. You should continue to use 'Dressing Room for Stonethorn' instead of 'Dressing Room 2018'.")
      end, 2000)
    end)
    if not self.sv.page.pages then
      self.sv.page.pages = {}
    end
  end

  -- apply any necessary compatibility conversions
  self:CheckDataCompatibility()

  for i = 1, #self.sv.page.pages do
    self:PopulatePage(i)
  end

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

  EVENT_MANAGER:RegisterForEvent(DressingRoom.name, EVENT_PLAYER_ACTIVATED, function() self:OnZoneChanged() end)
end


function DressingRoom.OnAddOnLoaded(event, addonName)
  if addonName ~= DressingRoom.name then return end

  DressingRoom:Initialize()
end


EVENT_MANAGER:RegisterForEvent(DressingRoom.name, EVENT_ADD_ON_LOADED, DressingRoom.OnAddOnLoaded)
