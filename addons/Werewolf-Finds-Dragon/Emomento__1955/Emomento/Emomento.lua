emomentoAddon = {}
local obj, db, lom, msg = emomentoAddon

function obj.onLoad()
  emomentoAddonDB        = emomentoAddonDB or {}
  db                     = emomentoAddonDB
  lom                    = LibStub:GetLibrary("LibOmniMessage-3.0")
  SLASH_COMMANDS["/emo"] = obj.slashHandler

  if not obj.doMessage then
    obj.doMessage = function(textMessage, formatTable)
      lom:Send(lom:Title("Emomento")..textMessage, formatTable)
    end

    msg = obj.doMessage
  end

  for k, v in pairs(db) do
    k                      = k:lower()
    SLASH_COMMANDS["/"..k] = function() UseCollectible(v) end
  end

  ZO_PreHook("UseCollectible", obj.trackCollectible)

  EVENT_MANAGER:UnregisterForEvent("Emomento_Load")
end

function obj.trackCollectible(id)
  if obj.doTrack and not obj.doWait then
    msg("You used <<LOM-CYAN>><<LOM-ID>><<LOM-CLEAR>>.", {CYAN=lom.cyanColor, CLEAR=lom.clearColor, ID=id})

    obj.doWait = true

    zo_callLater(function() obj.doWait = nil end, 1000)
  end
end

function obj.slashHandler(varType)
  local varText

  if type(varType) == "string" then
    if varType:find(" ") then varType, varText = varType:match("(%w+) (.*)") end

    verType = varType:lower()

    if varText then varText = varText:lower() end
  end

  if varType and obj[varType.."Slash"] then
    obj[varType.."Slash"](varText)

  else
    obj.helpSlash()
  end
end

function obj.saveSlash(varText)
  local _, _, emoName, emoNum = varText:find("(%w+) (%d+)")

  if not emoName or not emoNum then
    msg("An error has occurred, please check your use of the slash command and try again.")

    return

  elseif db[emoName] then
    msg("You already have an emote named <<LOM-CYAN>><<LOM-NAME>><<LOM-CLEAR>>.", {CYAN=lom.cyanColor, CLEAR=lom.clearColor, NAME=emoName})

    return

  elseif SLASH_COMMANDS["/"..emoName] then
    msg("Another addon or system process is already using <<LOM-CYAN>><<LOM-NAME>><<LOM-CLEAR>>.", {CYAN=lom.cyanColor, CLEAR=lom.clearColor, NAME=emoName})

    return
  end

  db[emoName]                  = tonumber(emoNum)
  SLASH_COMMANDS["/"..emoName] = function() UseCollectible(emoNum) end

  msg("Emote named <<LOM-CYAN>><<LOM-NAME>><<LOM-CLEAR>> saved.", {CYAN=lom.cyanColor, CLEAR=lom.clearColor, NAME=emoName})
end

function obj.deleteSlash(emoName)
  if not db[emoName] then
    msg("You don't have an emote named <<LOM-CYAN>><<LOM-NAME>><<LOM-CLEAR>>.", {CYAN=lom.cyanColor, CLEAR=lom.clearColor, NAME=emoName})

    return
  end

  db[emoName]                  = nil
  SLASH_COMMANDS["/"..emoName] = nil

  msg("Emote named <<LOM-CYAN>><<LOM-NAME>><<LOM-CLEAR>> removed.", {CYAN=lom.cyanColor, CLEAR=lom.clearColor, NAME=emoName})
end

function obj.trackSlash()
  obj.doTrack = not obj.doTrack

  msg("ID tracking <<LOM-CYAN>><<LOM-STATE>>abled<<LOM-CLEAR>>.", {CYAN=lom.cyanColor, CLEAR=lom.clearColor, STATE=(obj.doTrack and "en" or "dis")})
end

function obj.listSlash()
  local emptyDB, emoName = true

  msg("You have the following emotes saved...")

  for emoName, _ in pairs(db) do
    emptyDB = nil

    msg("<<LOM-YELLOW>>*<<LOM-CLEAR>> <<LOM-GREEN>><<LOM-NAME>><<LOM-CLEAR>>", {GREEN=lom.greenColor, YELLOW=lom.yellowColor, CLEAR=lom.clearColor, NAME=emoName})
  end

  if emptyDB then msg("<<LOM-RED>>None!<<LOM-CLEAR>>", {RED=lom.redColor, CLEAR=lom.clearColor}) end
end

function obj.helpSlash()
  msg("Here are the commands you can use.")
  msg("<<LOM-GREEN>>/emo save [emote name] [collectible number]<<LOM-WHITE>> Adds a named emote which triggers the indicated memento.", {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/emo delete [emote name]<<LOM-WHITE>> Deletes the indicated emote.",                                                {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/emo track<<LOM-WHITE>> Toggles memento tracking.",                                                                 {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/emo list<<LOM-WHITE>> Lists all of your saved emotes.",                                                            {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
end

EVENT_MANAGER:RegisterForEvent("Emomento_Load", EVENT_ADD_ON_LOADED, obj.onLoad)