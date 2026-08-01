--========================================
--        vars
--========================================
local addon = AssistVampireTrade -- Addon#M
local settings = addon.load("Settings#M") -- Settings#M
local m = {} -- #M
local l = {} -- #L

---
--@type SlotedSkill
--@field #number weaponPair
--@field #number slotNum
--@field #SkillInfo info

---
--@type SkillInfo
--@field #number skillType
--@field #number skillLine
--@field #number abilityIndex
--@field #number abilityId
--@field #string abilityName
--@field #number progressionIndex

---
--@type CoreSavedVars
local coreSavedVarsDefaults = {
  switchAtAbilitySlot = 5,
  soundEnabled = false,
  soundIndex = 28,
  oldSlotedSkill = nil--#SlotedSkill
}

--========================================
--        l
--========================================
l.token = 0 --#number
l.waitRecover = false --#boolean
l.rmSkillInfo = nil --#SkillInfo
l.coverTime = 0 --#number
l.progressionIndexToSkillInfo = {} --#map<#number,#SkillInfo>

l.debug -- #(#number:level)->(#(#string:format, #string:...)->())
=function(level)
  return function(format, ...)
    if m.debugLevel>=level then
      d(string.format(format, ...))
    end
  end
end

l.getSavedVars -- #()->(#CoreSavedVars)
= function()
  return settings.getSavedVars()
end

l.getCharacterSavedVars -- #()->(#CoreSavedVars)
= function()
  return settings.getCharacterSavedVars()
end

l.getDuration -- #(#number:abilityId)->(#number)
= function(abilityId)
  local duration = GetAbilityDuration(abilityId)
  -- longer duration in description
  local description = GetAbilityDescription(abilityId)
  local init = 1
  local s = 0
  local e = 0
  while true do
    s,e = description:find("[0-9]+",init,false)
    if s and s> 0 and tonumber(description:sub(s,e)) then
      init = e+1
      local percentLoc = description:find("%%",e,false)
      if not percentLoc or percentLoc > e+5 then
        local num = tonumber(description:sub(s,e)) * 1000
        duration = math.max(duration,num)
      end
    else
      break
    end
  end
  return duration
end

l.loadSkillInfo -- #()->()
= function()
  if not IsPlayerActivated() then return end
  l.rmSkillInfo = nil
  l.progressionIndexToSkillInfo = {}
  for skillType = 1, GetNumSkillTypes() do
    for skillLine = 1, GetNumSkillLines(skillType) do
      for abilityIndex = 1, math.min(7, GetNumAbilities(skillType, skillLine)) do
        local abilityId = GetSkillAbilityId(skillType, skillLine, abilityIndex, false)
        local abilityName,texture,earnedRank,passive,ultimate,purchased,progressionIndex,rankIndex =
          GetSkillAbilityInfo(skillType, skillLine, abilityIndex)
        local info = {
          skillType = skillType,
          skillLine = skillLine,
          abilityIndex = abilityIndex,
          abilityId = abilityId,
          abilityName = abilityName,
          progressionIndex = progressionIndex,
        }--#SkillInfo
        if string.find(texture,'ability_u26_vampire_04',1,true) then
          l.rmSkillInfo = info
        elseif progressionIndex then
          l.progressionIndexToSkillInfo[progressionIndex] = info
        end
      end
    end
  end
end

l.onActionSlotAbilityUsed = function(eventCode, slotNum, force)
  if not l.getSavedVars().RevertSkillAfterUse then
    return
  end

  local oss = l.getCharacterSavedVars().oldSlotedSkill
  if not oss then
    return
  end

  if oss.slotNum ~= slotNum then
    return
  end

  local weaponPair, locked = GetActiveWeaponPairInfo()
  if not weaponPair or locked then
    -- No weapon is equipped or weapon swap is locked, introduce a delay and then do nothing
    zo_callLater(function() l.recover() end, 1000)  -- Introduce a 1-second delay
    return
  end

  l.debug(1)("avt-core:l.onActionSlotAbilityUsed %i:%s", slotNum, GetSlotName(slotNum))
  local abilityId = GetSlotBoundId(slotNum)
  local hasProgression, progressionIndex, lastRankXp, nextRankXP, currentXP, atMorph = GetAbilityProgressionXPInfoFromAbilityId(abilityId)

  if progressionIndex == l.rmSkillInfo.progressionIndex then
    l.coverTime = GetGameTimeMilliseconds() + l.getDuration(abilityId)

    if l.getSavedVars().autoSwitchAgainBeforeEffectFades then
      l.coverTime = l.coverTime - l.getSavedVars().secondsLeftToSwitchAgain * 1000
    end

    -- recover
    l.debug(1)('avt-core: call later to recover')
    zo_callLater(
      function()
        l.recover()
        if l.getSavedVars().autoSwitchOnlyInNonPvpZones and IsPlayerInAvAWorld() then
          return
        end

        if l.getSavedVars().autoSwitchAgainBeforeEffectFades then
          l.token = l.token + 1
          l.switch(l.token)
        end
      end,
      500
    )
    return
  end
end


l.onActiveWeaponPairChanged -- #(#number:eventCode,#ActiveWeaponPair:activeWeaponPair,#boolean:locked)->()
= function(eventCode,activeWeaponPair,locked)
  if l.waitRecover and l.getCharacterSavedVars().oldSlotedSkill then
    zo_callLater(l.recover, 300)
  end
end

l.onPlayerActivated -- #(#number:eventCode,#boolean:initial)->()
= function(eventCode,initial)
  if initial then
    l.loadSkillInfo()
    l.recover()
  end
end

l.onSkillPointsChanged -- #(#number:eventCode,#integer:pointsBefore,#integer:pointsNow,#integer:partialPointsBefore,#integer:partialPointsNow,#SkillPointReason:skillPointChangeReason)->()
= function(eventCode,pointsBefore,pointsNow,partialPointsBefore,partialPointsNow,skillPointChangeReason)
  l.loadSkillInfo()
end

l.onStart -- #()->()
= function()

  l.loadSkillInfo()

  EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ACTION_SLOT_ABILITY_USED, l.onActionSlotAbilityUsed)
  EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, l.onActiveWeaponPairChanged)
  EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED, l.onPlayerActivated)
  EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_SKILL_POINTS_CHANGED, l.onSkillPointsChanged )
end

l.recover -- #()->()
= function()
  l.debug(1)('recover called')
  local oss = l.getCharacterSavedVars().oldSlotedSkill
  if oss ~= nil then
    if IsUnitInCombat('player') then
      zo_callLater(l.recover, 1000)
      return
    end
    local weaponPair,locked = GetActiveWeaponPairInfo()
    if weaponPair ~= oss.weaponPair then
      l.waitRecover = true -- try again when player switch weapon pair
      return
    end
    l.waitRecover = false -- clean flag
    local info = oss.info;
    l.debug(1)('avt-core:l.recover %s,%s,%s abilityId:%i', info.skillType,info.skillLine,info.abilityIndex, (info.abilityId or 'not saved'))
    SlotSkillAbilityInSlot(info.skillType, info.skillLine, info.abilityIndex, oss.slotNum)
    l.getCharacterSavedVars().oldSlotedSkill = nil
  end
end

l.saveOldSlotedSkill -- #(#number:slotNum)->()
= function(slotNum)
  local abilityId = GetSlotBoundId(slotNum)
  if l.rmSkillInfo.abilityId == abilityId then return end
  if GetSkillAbilityId(l.rmSkillInfo.skillType,l.rmSkillInfo.skillLine,l.rmSkillInfo.abilityIndex,false)==abilityId then
    l.rmSkillInfo.abilityId = abilityId -- auto patch
    return
  end
  local _,progressionIndex = GetAbilityProgressionXPInfoFromAbilityId(abilityId)
  local info = l.progressionIndexToSkillInfo[progressionIndex]
  if not info then
    d('AVT can not find info for ability id:'..abilityId)
    return
  end
  local weaponPair,locked = GetActiveWeaponPairInfo()
  l.debug(1)('avt-core:l.saveOldSlotedSkill(%i)(%i,%i,%i) abilityId:%i',slotNum,info.skillType,
    info.skillLine,info.abilityIndex,info.abilityId)
  l.getCharacterSavedVars().oldSlotedSkill = {
    slotNum = slotNum,
    weaponPair = weaponPair,
    info = info,
  }
end

l.soundChoices = {} -- #list<#number>
for k,v in pairs(SOUNDS) do
  table.insert(l.soundChoices, k)
end
table.sort(l.soundChoices)

l.switch = function(token, force)
  l.debug(1)('avt-core:l.switch token=%i, force=%s, l.token=%i', token, force and 'true' or 'false', l.token)
  local now = GetGameTimeMilliseconds()
  -- check
  if not l.rmSkillInfo then
    l.debug(1)('avt-core:l.switch no rmSkillInfo, try again.')
    l.loadSkillInfo()
    if not l.rmSkillInfo then
      l.debug(1)('avt-core:l.switch still no rmSkillInfo!!!')
      return
    end
  end
  if token ~= l.token then return end
  if not force then return end
  if not force and l.coverTime and l.coverTime > now then
    l.debug(2)('avt-core:l.switch l.coverTime>now')
    zo_callLater(function() l.switch(token, force) end, l.coverTime - now)
    return
  end
  if IsUnitInCombat('player') then
    l.debug(2)('avt-core:l.switch inCombat')
    zo_callLater(function() l.switch(token, force) end, 1000)
    return
  end

  --  save old info
  l.debug(2)('avt-core:l.switch saving oss')
  local slotNum = l.getSavedVars().switchAtAbilitySlot + 2
  if l.rmSkillInfo.abilityId == GetSlotBoundId(slotNum) then return end
  l.saveOldSlotedSkill(slotNum)
  l.debug(2)('avt-core:l.switch oss saved')

  -- switch ability
  l.waitRecover = false
  if l.getSavedVars().soundEnabled then PlaySound(SOUNDS[l.soundChoices[l.getSavedVars().soundIndex]]) end
  SlotSkillAbilityInSlot(l.rmSkillInfo.skillType, l.rmSkillInfo.skillLine, l.rmSkillInfo.abilityIndex, slotNum)
  if AddonForMrNegative then
    local commander = AddonForMrNegative.load('Commander#M')
    if commander then commander.send({'s 500','k '..(slotNum-2)}) end
  end
  l.debug(2)('avt-core:l.switch finished')
end

--========================================
--        m
--========================================
m.debugLevel = 0 -- #number exposed for console use. e.g. /script AssistVampireTrade.load('Core#M').debugLevel=1
m.reloadSkillInfo -- #()->() exposed for console use. e.g. /script AssistVampireTrade.load('Core#M').reloadSkillInfo()
= function()
  l.loadSkillInfo()
end

--========================================
--        register
--========================================
addon.register("Core#M",m)

addon.addAction("switch",function()
  local oss = l.getCharacterSavedVars().oldSlotedSkill
  if oss and oss.info then
    l.recover()
    return
  end
  l.token = l.token+1
  l.switch(l.token,true);
end)

addon.hookStart(l.onStart)

addon.extend(settings.EXTKEY_ADD_DEFAULTS,function()
  settings.addDefaults(coreSavedVarsDefaults)
end)

addon.extend(settings.EXTKEY_ADD_MENUS,function()
  settings.addMenuOptions(
    --
    {
      type = "checkbox",
      name = zo_strformat("|c<<1>>Revert when skill is used|r", ZO_HIGHLIGHT_TEXT:ToHex()),
      getFunc = function() return l.getSavedVars().RevertSkillAfterUse end,
      setFunc = function(value) l.getSavedVars().RevertSkillAfterUse=value end,
      width = "full",
      default =coreSavedVarsDefaults.RevertSkillAfterUse,
    },
    --
    {
      type = "slider",
      name = zo_strformat("|c<<1>>Ability slot to use|r", ZO_HIGHLIGHT_TEXT:ToHex()),
      min = 1, max = 5, step = 1,
      getFunc = function() return l.getSavedVars().switchAtAbilitySlot end,
      setFunc = function(value) l.getSavedVars().switchAtAbilitySlot=value end,
      width = "full",
      default = coreSavedVarsDefaults.switchAtAbilitySlot,
    },
    {
        type = "header",
        name = zo_strformat("|c<<1>>Info|r", ZO_HIGHLIGHT_TEXT:ToHex()),
        width = "full",
    },
    {
        type = "description",
        text = zo_strformat("|c<<1>>Facilitate your vampire trades effortlessly with|r '|cff0000Assist Vampire Trade|r|c<<1>>'. Swap skills seamlessly and trade hassle-free with merchants. Enjoy a smoother undead experience with this essential addon for nocturnal traders.|r", ZO_HIGHLIGHT_TEXT:ToHex()),
        title = zo_strformat("|c<<1>>About|r", ZO_HIGHLIGHT_TEXT:ToHex()),
        width = "full",
    },
    {
        type = "description",
        text = zo_strformat("|c<<1>>You will need to add a keybind for this to work.|r", ZO_HIGHLIGHT_TEXT:ToHex()),
        title = zo_strformat("|c<<1>>Keybindings|r", ZO_HIGHLIGHT_TEXT:ToHex()),
        width = "full",
    },
    {
        type = "description",
        text = zo_strformat("|c<<1>>In: 'Controls' > 'Keybindings'|r > '|cff0000Assist Vampire Trade|r|c<<1>>'.|r", ZO_HIGHLIGHT_TEXT:ToHex()),
        title = zo_strformat("|c<<1>>Where can I do this?|r", ZO_HIGHLIGHT_TEXT:ToHex()),
        width = "full",
    },
    {
        type = "description",
        text = zo_strformat("|c<<1>>You no longer need have your weapon out before using Mesmerize. I've implemented a fix that ensures a smoother and more intuitive experience.|r", ZO_HIGHLIGHT_TEXT:ToHex()),
        title = zo_strformat("|c<<1>>Version 1.1.0: Improved Usability|r", ZO_HIGHLIGHT_TEXT:ToHex()),
        width = "full",
    },
    {
        type = "description",
        title = zo_strformat("|c<<1>>Feedback|r", ZO_HIGHLIGHT_TEXT:ToHex()),
        width = "full",
    }
  )

  -- Add this function to find the parent control for your addon's settings panel
  local function GetAddonSettingsPanelParentControl()
    local addonSettingsPanel = AVTAddonOptions -- Replace with the actual name of your addon's settings panel control
    if addonSettingsPanel then
        return addonSettingsPanel
    end
    return nil
  end

  -- Modify LibFeedback initialization to use the parent control for your addon's settings panel
  local parentControl = GetAddonSettingsPanelParentControl()

  -- Check if the parent control is found
  if parentControl then
      l.feedbackButton = LibFeedback:initializeFeedbackWindow(
          addon,
          "Assist Vampire Trade",
          parentControl,
          "@Mr_Negative",
          { BOTTOMLEFT, parentControl, BOTTOMLEFT, 14, -10 },
          {
              [1] = { 0, "Send Note", false },
              [2] = { 10000, "Send 10K Gold", true },
              [3] = { 0, "Send More Gold", true },
          },
          zo_strformat("|c<<1>>If you found a bug, have a request or a suggestion, or simply wish to donate, send me mail. Server:|r |ceeca2aEU|r |c<<1>>Megaserver.|r", ZO_HIGHLIGHT_TEXT:ToHex()),
          600,
          150,
          150,
          28
      )
  end
end)
