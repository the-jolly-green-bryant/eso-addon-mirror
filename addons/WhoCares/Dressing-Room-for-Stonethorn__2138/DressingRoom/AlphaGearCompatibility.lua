function DressingRoom:GetCompatibleAlphaGearVersion()
  return "v6.6.0 beta1"
end

function DressingRoom:DetectAlphaGear()
  if not AG then return end
  if AG.name ~= "AlphaGear" then return end
  if AG.displayname ~= "AlphaGear 2" then return end
  return AG.version
end

function DressingRoom:MoveKeyBinding(oldId, newId)
  local layerIndexOld, categoryIndexOld, actionIndexOld = GetActionIndicesFromName(oldId)
  local layerIndexNew, categoryIndexNew, actionIndexNew = GetActionIndicesFromName(newId)
  for j = 1, 4 do
    local key, mod1, mod2, mod3, mod4 = GetActionBindingInfo(layerIndexOld, categoryIndexOld, actionIndexOld, j)
    if key then
      CallSecureProtected("UnbindKeyFromAction", layerIndexOld, categoryIndexOld, actionIndexOld, j)
      CallSecureProtected("BindKeyToAction", layerIndexNew, categoryIndexNew, actionIndexNew, j, key, mod1, mod2, mod3, mod4)
    end
  end
end

local SLOTS = { -- from AlphaGear
  {EQUIP_SLOT_MAIN_HAND,},
  {EQUIP_SLOT_OFF_HAND,},
  {EQUIP_SLOT_BACKUP_MAIN,},
  {EQUIP_SLOT_BACKUP_OFF,},
  {EQUIP_SLOT_HEAD,},
  {EQUIP_SLOT_CHEST,},
  {EQUIP_SLOT_LEGS,},
  {EQUIP_SLOT_SHOULDERS,},
  {EQUIP_SLOT_FEET,},
  {EQUIP_SLOT_WAIST,},
  {EQUIP_SLOT_HAND,},
  {EQUIP_SLOT_NECK,},
  {EQUIP_SLOT_RING1,},
  {EQUIP_SLOT_RING2,},
  {EQUIP_SLOT_POISON,},
  {EQUIP_SLOT_BACKUP_POISON,},
}

function DressingRoom:CopyAlphaGearPresets()
  AG.storeProfile(AG.setdata.currentProfileId)
  DressingRoom:msg("Converting data format...")
  local newPages = {}
  for i = 1, 20 do
    local profile = AG.setdata.profiles[i]
    if profile and profile.setdata then
      newPages[i] = {
        name = profile.name or "Profile "..i,
        skillSet = {},
        gearSet = {},
        customSetName = {},
      }
      for setId = 1, self:numSets() do
        newPages[i].skillSet[setId] = {{}, {}}
      end
      for j = 1, AG.setdata.setamount do
        local setdata = profile.setdata[j]
        if type(setdata.Set.text[1]) == "string" then
          newPages[i].customSetName[j] = setdata.Set.text[1]
        end
        if setdata.Set.gear ~= 0 then
          local gear = profile.setdata[setdata.Set.gear].Gear
          local newGear = {emptySlots = {}}
          local gearName = {}
          local gearLinks = {}
          for k = 1, #SLOTS do -- SLOTS[k] == {EQUIP_SLOT_x, string, string}
            if k == 16 then -- SLOTS[16][1] == EQUIP_SLOT_BACKUP_POISON
              if gear[16].id == gear[15].id or gear[16].link == gear[15].link then
                -- AlphaGear allows saving the same poison in both poison slots; we don't
                table.insert(newGear.emptySlots, EQUIP_SLOT_BACKUP_POISON)
              end
            elseif gear[k].id ~= 0 then
              newGear[gear[k].id] = SLOTS[k][1]
              gearLinks[SLOTS[k][1]] = gear[k].link
            -- two-handed weapons; gear[1] is main hand and gear[3] is backup main hand
            elseif not ((SLOTS[k][1] == EQUIP_SLOT_OFF_HAND and DressingRoom.twoHanded[GetItemLinkWeaponType(gear[1].link)])
              or (SLOTS[k][1] == EQUIP_SLOT_BACKUP_OFF and DressingRoom.twoHanded[GetItemLinkWeaponType(gear[3].link)])) then
              table.insert(newGear.emptySlots, SLOTS[k][1])
            end
          end
          table.insert(newGear.emptySlots, EQUIP_SLOT_COSTUME) -- AlphaGear doesn't use this slot so it will always be empty
          for _, gearSlot in ipairs(DressingRoom.gearSlots) do -- use native ordering
            if gearLinks[gearSlot] then
              gearName[#gearName+1] = zo_strformat(SI_TOOLTIP_ITEM_NAME, gearLinks[gearSlot])
            end
          end
          newGear.text = table.concat(gearName, "\n")
          newGear.name = "AlphaGear Build "..j
          newPages[i].gearSet[j] = newGear
        end
        local bars = {}
        for k = 1, 2 do
          if setdata.Set.skill[k] ~= 0 then
            bars[k] = profile.setdata[setdata.Set.skill[k]].Skill
          else
            bars[k] = {0, 0, 0, 0, 0, 0}
          end
          for m = 1, 6 do
            local abilityId = bars[k][m]
            if abilityId > 0 then
              local t, l, a = DressingRoom:GetSkillFromAbilityId(abilityId)
              local _, _, _, id = GetSkillLineInfo(t, l)
              local skill = {skillLineId = id, ability = a}
              newPages[i].skillSet[j][k][m] = skill
            end
          end
        end
      end
    end
  end
  DressingRoom:msg("Overwriting...")
  self.ram.page.byRole[self.currentGroupRole] = newPages
  self.ram.page.pages = self.ram.page.byRole[self.currentGroupRole]
  for i = 1, #self.ram.page.pages do
    for j in ipairs(self.groupRoles) do
      if j ~= self.currentGroupRole then
        self.ram.page.byRole[j][i] = {}
      end
    end
    self:StorePage(i)
  end
end

function DressingRoom:CopyAlphaGearKeyBindings()
  DressingRoom:msg("Rebinding keys...")
  DressingRoom:MoveKeyBinding("SHOW_AG_WINDOW", "DRESSINGROOM_TOGGLE")
  DressingRoom:MoveKeyBinding("AG_UNDRESS", "DRESSINGROOM_UNDRESS")
  DressingRoom:MoveKeyBinding("AG_NEXT_PROFILE", "DRESSINGROOM_PAGE_SELECT_NEXT")
  DressingRoom:MoveKeyBinding("AG_PREVIOUS_PROFILE", "DRESSINGROOM_PAGE_SELECT_PREVIOUS")
  for i = 1, 16 do
    DressingRoom:MoveKeyBinding("AG_SET_"..i, "DRESSINGROOM_SET_"..i)
  end
end

function DressingRoom:ImportAlphaGear(rebindKeys)
  local alphaGearVersion = DressingRoom:DetectAlphaGear()
  if not alphaGearVersion then return end
  if IsUnitInCombat("player") then DressingRoom:msg("Cannot use this function in combat") return end
  DressingRoom:msg("Importing data from |cFFAA33AlphaGear 2 %s|r...", alphaGearVersion)
  DressingRoom:CopyAlphaGearPresets()
  if rebindKeys then
    DressingRoom:CopyAlphaGearKeyBindings()
  end
  self.options.numRows = 6
  self.options.numCols = 4
  self.options.enablePages = true
  self.options.clearEmptySkill = false
  self.options.clearEmptyGear = false
  self.options.clearEmptyPoisons = true
  DressingRoom:msg("Reloading UI")
  ReloadUI()
end
