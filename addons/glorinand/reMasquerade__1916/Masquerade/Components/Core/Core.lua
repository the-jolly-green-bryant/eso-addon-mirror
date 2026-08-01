masqueradeAddon   = { playerName = GetUnitName("player") }
masqueradeAddonDB = masqueradeAddonDB or {}

local lom, msg, db

function masqueradeAddon.onLoad(_, addon)
  if addon ~= "Masquerade" or not LibStub then return end

  masqueradeAddonDB[masqueradeAddon.playerName]             = masqueradeAddonDB[masqueradeAddon.playerName]             or {}
  masqueradeAddonDB[masqueradeAddon.playerName].setBindings = masqueradeAddonDB[masqueradeAddon.playerName].setBindings or {}
  db                                                        = masqueradeAddonDB[masqueradeAddon.playerName]

  if LibStub then
    masqueradeAddon.lom = LibStub:GetLibrary("LibOmniMessage-2.0")
  end

  if masqueradeAddon.lom then
    masqueradeAddon.doMessage = function(textMessage, formatTable)
      masqueradeAddon.lom:Send(lom:Title("Masquerade")..textMessage, formatTable)
    end
  end

  lom = masqueradeAddon.lom       or {}
  msg = masqueradeAddon.doMessage or function() end

  SLASH_COMMANDS["/mq"]   = masqueradeAddon.slashHandler
  SLASH_COMMANDS["/masq"] = masqueradeAddon.slashHandler

  ZO_CreateStringId("SI_BINDING_NAME_MASQ_SLOT_1", "Slot 1")
  ZO_CreateStringId("SI_BINDING_NAME_MASQ_SLOT_2", "Slot 2")
  ZO_CreateStringId("SI_BINDING_NAME_MASQ_SLOT_3", "Slot 3")
  ZO_CreateStringId("SI_BINDING_NAME_MASQ_SLOT_4", "Slot 4")
  ZO_CreateStringId("SI_BINDING_NAME_MASQ_SLOT_5", "Slot 5")
  ZO_CreateStringId("SI_BINDING_NAME_MASQ_SLOT_6", "Slot 6")
  ZO_CreateStringId("SI_BINDING_NAME_MASQ_SLOT_7", "Slot 7")
  ZO_CreateStringId("SI_BINDING_NAME_MASQ_SLOT_8", "Slot 8")
  ZO_CreateStringId("SI_BINDING_NAME_MASQ_SLOT_9", "Slot 9")

  if db.currentSet and IA and IA.SVC.IdleProfile then
    IA.SVC.IdleProfile = db[db.currentSet].idleAnimations
  end

  EVENT_MANAGER:UnregisterForEvent("Masquerade_OnLoad")
end

function masqueradeAddon.bindHandler(bindNum)
  if not bindNum or type(bindNum) ~= "number" then return end

  if not db.setBindings[bindNum] then
    msg("You have no set saved for slot <<LOM-SLOT>>", {SLOT=(tostring(bindNum) or "?")})

    return
  end

  masqueradeAddon.equipSet(db.setBindings[bindNum])
end

function masqueradeAddon.slashHandler(textMessage)
  textMessage = type(textMessage) == "string" and textMessage:lower() or ""

  local varType, varText

  if textMessage:find(" ") then varType, varText = textMessage:match("(%w+) (.*)") end

  if db[textMessage] then
    masqueradeAddon.equipSet(textMessage)

  elseif masqueradeAddon[(varType or textMessage)] then
    masqueradeAddon[(varType or textMessage)](varText)

  else
    masqueradeAddon.showHelp()
  end
end

function masqueradeAddon.checkSet(setName, save, bindNum, bind)
  if bind and (not setName or not bindNum) then
    msg("You must provide a bind number and name.")

    return false

  elseif not setName then
    msg("You must provide a set name.")

    return false

  elseif not save and not db[setName] then
    msg("You don't have a set named <<LOM-CYAN>><<LOM-NAME>><<LOM-CLEAR>>.", {CYAN=lom.cyanColor, CLEAR=lom.clearColor, NAME=(setName or "?")})

    return false

  elseif save and db[setName] then
    msg("You already have a set named <<LOM-CYAN>><<LOM-NAME>><<LOM-CLEAR>>.", {CYAN=lom.cyanColor, CLEAR=lom.clearColor, NAME=(setName or "?")})

    return false
  end

  return true
end

function masqueradeAddon.save(setName)
  if not masqueradeAddon.checkSet(setName, true) then return end

  db[setName] = {
    [COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING]             = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING),
    [COLLECTIBLE_CATEGORY_TYPE_COSTUME]                  = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COSTUME),
    [COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY]         = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY),
    [COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS]        = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS),
    [COLLECTIBLE_CATEGORY_TYPE_HAIR]                     = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_HAIR),
    [COLLECTIBLE_CATEGORY_TYPE_HAT]                      = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_HAT),
    [COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING]             = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING),
    [COLLECTIBLE_CATEGORY_TYPE_PERSONALITY]              = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_PERSONALITY),
    [COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY]         = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY),
    [COLLECTIBLE_CATEGORY_TYPE_POLYMORPH]                = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_POLYMORPH),
    [COLLECTIBLE_CATEGORY_TYPE_VANITY_PET]               = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET),
    [COLLECTIBLE_CATEGORY_TYPE_SKIN]                     = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_SKIN),
    [COLLECTIBLE_CATEGORY_TYPE_MOUNT]                    = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_MOUNT),
  }

  if IA and IA.SVC.IdleProfile then
    db[setName].idleAnimations = IA.SVC.IdleProfile
  end

  outfitIndex = GetEquippedOutfitIndex()
  if outfitIndex then
    db[setName].outfitIndex = outfitIndex
  end

  db[setName].mountUpgrades = {
	[IN_WORLD_UI_SETTING_HIDE_MOUNT_STAMINA_UPGRADE] = GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_MOUNT_STAMINA_UPGRADE),
        [IN_WORLD_UI_SETTING_HIDE_MOUNT_SPEED_UPGRADE] = GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_MOUNT_SPEED_UPGRADE),
        [IN_WORLD_UI_SETTING_HIDE_MOUNT_INVENTORY_UPGRADE] = GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_MOUNT_INVENTORY_UPGRADE)
  }

  msg("Set named <<LOM-CYAN>><<LOM-NAME>><<LOM-CLEAR>> saved.", {CYAN=lom.cyanColor, CLEAR=lom.clearColor, NAME=(setName or "?")})
end

function masqueradeAddon.delete(setName)
  if not masqueradeAddon.checkSet(setName) then return end

  db[setName] = nil

  local bindIndex

  for bindIndex = 1, 9 do
    bindName = db.setBindings[bindIndex]

    if bindName == setName then
      db.setBindings[bindIndex] = nil
    end
  end

  msg("Set named <<LOM-CYAN>><<LOM-NAME>><<LOM-CLEAR>> removed.", {CYAN=lom.cyanColor, CLEAR=lom.clearColor, NAME=(setName or "?")})
end

function masqueradeAddon.bind(bindString)
  local bindNum, setName

  if (bindString or ""):find(" ") then
    bindNum, setName = bindString:match("(%d+) (.*)")

  else setName = bindString end

  if not masqueradeAddon.checkSet(setName, nil, bindNum, true) then return end

  db.setBindings[tonumber(bindNum)] = setName

  msg("Bind slot <<LOM-SLOT>> has been set to equip set <<LOM-CYAN>><<LOM-SET>><<LOM-CLEAR>>.", {CYAN=lom.cyanColor, CLEAR=lom.clearColor, SLOT=(bindNum or "?"), SET=(setName or "?")})
end

function masqueradeAddon.equipSet(setName)
  if not masqueradeAddon.checkSet(setName) then return end

  msg("Equipping set <<LOM-CYAN>><<LOM-NAME>><<LOM-CLEAR>>.", {CYAN=lom.cyanColor, CLEAR=lom.clearColor, NAME=(setName or "?")})

  local categoryName, setID

  db.currentSet = setName

  for categoryName, setID in pairs(db[setName]) do
    if categoryName == "idleAnimations" then
      if db.currentSet and IA and IA.SVC.IdleProfile then
        IA.SVC.IdleProfile = db[db.currentSet].idleAnimations
      end
    elseif categoryName == "outfitIndex" then
       EquipOutfit(db[db.currentSet].outfitIndex)
    elseif categoryName == "mountUpgrades" then
      for settingName, settingVal in pairs(setID) do
        SetSetting(SETTING_TYPE_IN_WORLD, settingName, settingVal, 1)
      end
    elseif not setID or type(setID) ~= "number" or setID == 0 then
      local currentlyWearingID = GetActiveCollectibleByType(categoryName)

      if currentlyWearingID and type(currentlyWearingID) == "number" and currentlyWearingID ~= 0 then
        UseCollectible(currentlyWearingID)
      end

    else
      local currentlyWearingID = GetActiveCollectibleByType(categoryName)

      if currentlyWearingID ~= setID then
        UseCollectible(setID)
      end
    end
  end
end

function masqueradeAddon.list()
  local emptyDB, setName = true
  setList = ""

  for setName, _ in pairs(db) do
    if setName ~= "setBindings" then
      emptyDB = nil
      setList = setList .. string.format("<<LOM-YELLOW>>*<<LOM-CLEAR>> <<LOM-GREEN>>%s<<LOM-CLEAR>>\n", string.gsub(" "..(setName or "?"), "%W%l", string.upper):sub(2))
    end
  end

  msg("You have the following sets saved...\n"..setList, {GREEN=lom.greenColor, YELLOW=lom.yellowColor, CLEAR=lom.clearColor})

  if emptyDB then msg("<<LOM-RED>>None!<<LOM-CLEAR>>", {RED=lom.redColor, CLEAR=lom.clearColor}) end
end

function masqueradeAddon.listbinds()
  local bindIndex, bindName

  msg("Your binds are set to...")

  for bindIndex = 1, 9 do
    bindName = db.setBindings[bindIndex]

    msg("<<LOM-GREEN>><<LOM-NUM>><<LOM-CLEAR>> - <<LOM-CYAN>><<LOM-BIND>><<LOM-CLEAR>>", {GREEN=lom.greenColor, CYAN=lom.cyanColor, CLEAR=lom.clearColor, NUM=bindIndex, BIND=string.gsub(" "..(bindName or "Nothing"), "%W%l", string.upper):sub(2)})
  end
end

function masqueradeAddon.showHelp()
  msg("Here are the commands you can use...")
  msg("<<LOM-GREEN>>/mq set name<<LOM-WHITE>> Equips the set named 'set name.'",                       {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/mq save set name<<LOM-WHITE>> Stores your currently equipped set as 'set name.'", {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/mq delete set name<<LOM-WHITE>> Deletes the set named 'set name.'",               {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/mq bind # set name<<LOM-WHITE>> Sets the binding slot to the set, respectively.", {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/mq list<<LOM-WHITE>> Lists all stored sets.",                                     {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/mq listbinds<<LOM-WHITE>> Lists the binds and what they're set to.",              {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
end

EVENT_MANAGER:RegisterForEvent("Masquerade_OnLoad", EVENT_ADD_ON_LOADED, masqueradeAddon.onLoad)
