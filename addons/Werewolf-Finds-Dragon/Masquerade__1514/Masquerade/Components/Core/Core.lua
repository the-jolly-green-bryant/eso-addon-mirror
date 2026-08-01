masqueradeAddon         = {playerName = GetUnitName("player")}
local obj, lom, msg, db = masqueradeAddon

function obj.onLoad(_, addon)
  if addon ~= "Masquerade" or not LibStub then return end

  masqueradeAddonDB                 = masqueradeAddonDB                 or {}
  masqueradeAddonDB[obj.playerName] = masqueradeAddonDB[obj.playerName] or {setBindings = {}}
  db                                = masqueradeAddonDB[obj.playerName]

  if LibStub then
    obj.lom = LibStub:GetLibrary("LibOmniMessage-2.0")
  end

  if obj.lom then
    obj.doMessage = function(textMessage, formatTable)
      obj.lom:Send(lom:Title("Masquerade")..textMessage, formatTable)
    end
  end

  lom = obj.lom       or {}
  msg = obj.doMessage or function() end

  SLASH_COMMANDS["/mq"]   = obj.slashHandler
  SLASH_COMMANDS["/masq"] = obj.slashHandler

  ZO_CreateStringId("SI_BINDING_NAME_MASQ_SLOT_1", "Slot 1")
  ZO_CreateStringId("SI_BINDING_NAME_MASQ_SLOT_2", "Slot 2")
  ZO_CreateStringId("SI_BINDING_NAME_MASQ_SLOT_3", "Slot 3")
  ZO_CreateStringId("SI_BINDING_NAME_MASQ_SLOT_4", "Slot 4")
  ZO_CreateStringId("SI_BINDING_NAME_MASQ_SLOT_5", "Slot 5")
  ZO_CreateStringId("SI_BINDING_NAME_MASQ_SLOT_6", "Slot 6")
  ZO_CreateStringId("SI_BINDING_NAME_MASQ_SLOT_7", "Slot 7")
  ZO_CreateStringId("SI_BINDING_NAME_MASQ_SLOT_8", "Slot 8")
  ZO_CreateStringId("SI_BINDING_NAME_MASQ_SLOT_9", "Slot 9")

  obj.idleAnimationsHandler()

  EVENT_MANAGER:UnregisterForEvent("Masquerade_OnLoad")
end

function obj.idleAnimationsHandler()
  if db.currentSet and db[db.currentSet] and db[db.currentSet].idleAnimations and IA and IA.SVC.IdleProfile then
    IA.SVC.IdleProfile = db[db.currentSet].idleAnimations

    CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", IdleAnimations_Options)

    IA.endTimer()
    IA.startTimer(IA.SVC.IdleTime)
  end
end

function obj.bindHandler(bindNum)
  if not bindNum or type(bindNum) ~= "number" then return end

  if not db.setBindings[bindNum] then
    msg("You have no set saved for slot <<LOM-SLOT>>", {SLOT=(tostring(bindNum) or "?")})

    return
  end

  obj.equipSet(db.setBindings[bindNum])
end

function obj.slashHandler(textMessage)
  textMessage = type(textMessage) == "string" and textMessage:lower() or ""

  if not textMessage or textMessage == "" then
    obj.helpSlash()

    return
  end

  local varType, varText

  if textMessage:find(" ") then
    varType, varText = textMessage:match("(%w+) (.*)")
  end

  if obj[(varType or textMessage).."Slash"] then
    obj[(varType or textMessage).."Slash"](varText)

    return
  end

  obj.equipSet(textMessage)
end

function obj.checkSet(setName, save, bindNum, bind)
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

  elseif (save and obj[setName]) or (save and setName:lower() == "currentset") or (save and setName:lower() == "setbindings") then
      msg("The set name <<LOM-CYAN>><<LOM-NAME>><<LOM-CLEAR>> is prohibited, please try another.", {CYAN=lom.cyanColor, CLEAR=lom.clearColor, NAME=(setName or "?")})

    return false
  end

  return true
end

function obj.saveSet(setName, extraType, completeSet)
  if not obj.checkSet(setName, true) then return end

  db[setName] = {
    [4]       = GetActiveCollectibleByType(4),
    [9]       = GetActiveCollectibleByType(9),
    [10]      = GetActiveCollectibleByType(10),
    [11]      = GetActiveCollectibleByType(11),
    [12]      = GetActiveCollectibleByType(12),
    [13]      = GetActiveCollectibleByType(13),
    [14]      = GetActiveCollectibleByType(14),
    [15]      = GetActiveCollectibleByType(15),
    [16]      = GetActiveCollectibleByType(16),
    [17]      = GetActiveCollectibleByType(17),
    [18]      = GetActiveCollectibleByType(18)
  }

  if extraType == 1 or extraType == 3 then
    db[setName][3] = GetActiveCollectibleByType(3)
  end

  if extraType == 2 or extraType == 3 then
    db[setName][2] = GetActiveCollectibleByType(2)
  end

  if IA.SVC.IdleProfile then
    db[setName].idleAnimations = IA.SVC.IdleProfile
  end

  db[setName].completeSet = completeSet

  msg("Set named <<LOM-CYAN>><<LOM-NAME>><<LOM-CLEAR>> saved.", {CYAN=lom.cyanColor, CLEAR=lom.clearColor, NAME=(setName or "?")})
end

function obj.psaveSlash(setName)
  obj.saveSet(setName)
end

function obj.psavepetSlash(setName)
  obj.saveSet(setName, 1)
end

function obj.psavemountSlash(setName)
  obj.saveSet(setName, 2)
end

function obj.psavepamSlash(setName)
  obj.saveSet(setName, 3)
end

function obj.csaveSlash(setName)
  obj.saveSet(setName, nil, true)
end

function obj.csavepetSlash(setName)
  obj.saveSet(setName, 1, true)
end

function obj.csavemountSlash(setName)
  obj.saveSet(setName, 2, true)
end

function obj.csavepamSlash(setName)
  obj.saveSet(setName, 3, true)
end

function obj.deleteSlash(setName)
  if not obj.checkSet(setName) then return end

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

function obj.bindSlash(bindString)
  local bindNum, setName

  if (bindString or ""):find(" ") then
    bindNum, setName = bindString:match("(%d+) (.*)")

  else setName = bindString end

  if not obj.checkSet(setName, nil, bindNum, true) then return end

  db.setBindings[tonumber(bindNum)] = setName 

  msg("Bind slot <<LOM-SLOT>> has been set to equip set <<LOM-CYAN>><<LOM-SET>><<LOM-CLEAR>>.", {CYAN=lom.cyanColor, CLEAR=lom.clearColor, SLOT=(bindNum or "?"), SET=(setName or "?")})
end

function obj.listSlash()
  local emptyDB, setName = true

  msg("You have the following sets saved...")

  for setName, _ in pairs(db) do
    if setName ~= "setBindings" and setName ~= "currentSet" then
      emptyDB = nil

      msg("<<LOM-YELLOW>>*<<LOM-CLEAR>> <<LOM-GREEN>><<LOM-NAME>><<LOM-CLEAR>> (<<LOM-GREEN>><<LOM-TYPE>><<LOM-CLEAR>>)", {GREEN=lom.greenColor, YELLOW=lom.yellowColor, CLEAR=lom.clearColor, TYPE=(db[setName].completeSet and "Complete" or "Partial"), NAME=string.gsub(" "..(setName or "?"), "%W%l", string.upper):sub(2)})
    end
  end

  if emptyDB then msg("<<LOM-RED>>None!<<LOM-CLEAR>>", {RED=lom.redColor, CLEAR=lom.clearColor}) end
end

function obj.listbindsSlash()
  local bindIndex, bindName

  msg("Your binds are set to...")

  for bindIndex = 1, 9 do
    bindName = db.setBindings[bindIndex]

    msg("<<LOM-GREEN>><<LOM-NUM>><<LOM-CLEAR>> - <<LOM-CYAN>><<LOM-BIND>><<LOM-CLEAR>>", {GREEN=lom.greenColor, CYAN=lom.cyanColor, CLEAR=lom.clearColor, NUM=bindIndex, BIND=string.gsub(" "..(bindName or "Nothing"), "%W%l", string.upper):sub(2)})
  end
end

function obj.helpSlash()
  msg("Here are the commands you can use...")
  msg("<<LOM-GREEN>>/mq [set name]<<LOM-WHITE>> Equips the set named 'set name.'",                                                 {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/mq psave [set name]<<LOM-WHITE>> Stores your currently equipped partial set as 'set name.'",                           {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/mq psavepet [set name]<<LOM-WHITE>> Works the same as 'psave' but also stores your cosmetic pet.",                {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/mq psavemount [set name]<<LOM-WHITE>> Works the same as 'psave' but also stores your mount.'",                    {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/mq psavepam [set name]<<LOM-WHITE>> Works the same as 'psave' but also stores both your cosmetic pet and mount'", {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/mq csave [set name]<<LOM-WHITE>> Stores your currently equipped complete set as 'set name.'",                           {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/mq csavepet [set name]<<LOM-WHITE>> Works the same as 'csave' but also stores your cosmetic pet.",                {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/mq csavemount [set name]<<LOM-WHITE>> Works the same as 'csave' but also stores your mount.'",                    {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/mq csavepam [set name]<<LOM-WHITE>> Works the same as save 'csave' also stores both your cosmetic pet and mount'", {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/mq delete [set name]<<LOM-WHITE>> Deletes the set named 'set name.'",                                         {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/mq bind [set number] [set name]<<LOM-WHITE>> Sets the binding slot to the set, respectively.",                {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/mq list<<LOM-WHITE>> Lists all stored sets.",                                                                 {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/mq listbinds<<LOM-WHITE>> Lists the binds and what they're set to.",                                          {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/mq help<<LOM-WHITE>> Shows this help text.",                                                   {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
end

function obj.equipSet(setName)
  if not obj.checkSet(setName) then return end

  msg("Equipping set <<LOM-CYAN>><<LOM-NAME>><<LOM-CLEAR>>.", {CYAN=lom.cyanColor, CLEAR=lom.clearColor, NAME=(setName or "?")})

  db.currentSet = setName

  for categoryName, setID in pairs(db[setName]) do
    local colID

    if not setID or type(setID) ~= "number" or setID == 0 then
      if db[setName].completeSet and type(categoryName) == "number" then
        colID = GetActiveCollectibleByType(categoryName)
      end

    elseif GetActiveCollectibleByType(categoryName) ~= setID then
      colID = setID
    end

    if colID and IsCollectibleUsable(colID) then UseCollectible(colID) end
  end

  obj.idleAnimationsHandler()
end

EVENT_MANAGER:RegisterForEvent("Masquerade_OnLoad", EVENT_ADD_ON_LOADED, obj.onLoad)