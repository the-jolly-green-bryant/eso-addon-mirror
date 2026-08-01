local obj, db, lom, msg = Snoop

function obj.SetupSlash(mainDB)
  db                                            = mainDB
  lom                                           = LibStub:GetLibrary("LibOmniMessage-3.0")
  SLASH_COMMANDS["/"..obj.strings.slashCommand] = obj.slashHandler

  if not obj.doMessage then
    obj.doMessage = function(textMessage, formatTable)
      lom:Send(lom:Title(obj.strings.name)..textMessage, formatTable)
    end

    msg = obj.doMessage
  end
end

function obj.slashHandler(varType)
  local varText

  if type(varType) == "string" then
    if varType:find(" ") then varType, varText = varType:match("(%w+) (.*)") end

    verType = varType:lower()
  end

  if varType and obj[varType.."Slash"] then
    obj[varType.."Slash"](varText)

  else
    obj.help()
  end
end

function obj.help()
  msg(obj.strings.commandList1)
  msg(obj.strings.commandList2,  {NAME=obj.strings.slashCommand, GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg(obj.strings.commandList3,  {NAME=obj.strings.slashCommand, GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg(obj.strings.commandList4,  {NAME=obj.strings.slashCommand, GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg(obj.strings.commandList5,  {NAME=obj.strings.slashCommand, GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg(obj.strings.commandList6,  {NAME=obj.strings.slashCommand, GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg(obj.strings.commandList7,  {NAME=obj.strings.slashCommand, GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg(obj.strings.commandList8,  {NAME=obj.strings.slashCommand, GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg(obj.strings.commandList9,  {NAME=obj.strings.slashCommand, GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg(obj.strings.commandList10, {NAME=obj.strings.slashCommand, GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg(obj.strings.commandList11, {NAME=obj.strings.slashCommand, GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg(obj.strings.commandList12, {NAME=obj.strings.slashCommand, GREEN=lom.greenColor, WHITE=lom.clearToWhite})
end

function obj.toggleOpt(option, upper)
  db[option] = not db[option]

  msg(obj.strings.slashToggle, {UPPER=upper, CYAN=lom.cyanColor, STATE=obj.strings["slash"..(db[option] and "On" or "Off")], WHITE=lom.clearToWhite})
end

function obj.setColor(type, text, rgb)
  local _, _, r, g, b = rgb:find("(.*) (.*) (.*)")

  if not r or not g or not b then
    msg(obj.strings.slashError1, {RED=lom.redColor, WHITE=lom.clearToWhite})

    return
  end

  r = tonumber(r)
  g = tonumber(g)
  b = tonumber(b)

  if r > 1.0 or r < 0.0 or g > 1.0 or g < 0.0 or b > 1.0 or b < 0.0 then
    msg(obj.strings.slashError2, {RED=lom.redColor, WHITE=lom.clearToWhite})

    return
  end

  db[type.."R"] = r
  db[type.."G"] = g
  db[type.."B"] = b

  msg(obj.strings.slashRGB, {CYAN=lom.cyanColor, TYPE=text, WHITE=lom.clearToWhite, RED=lom.redColor, GREEN=lom.greenColor, BLUE=lom.blueColor, R=tostring(r), G=tostring(g), B=tostring(b)})
end

function obj.goldSlash()
  obj.toggleOpt("gold", obj.strings.gold)
end

function obj.lootSlash()
  obj.toggleOpt("loot", obj.strings.loot)
end

function obj.countSlash()
  obj.toggleOpt("count", obj.strings.count)
end

function obj.partySlash()
  obj.toggleOpt("party", obj.strings.party)
end

function obj.craftSlash()
  obj.toggleOpt("craft", obj.strings.craft)
end

function obj.showSlash()
  obj.toggleOpt("show", obj.strings.show)
end

function obj.gaincolorSlash(text)
  obj.setColor("gain", obj.strings.gain, text)
end

function obj.losscolorSlash(text)
  obj.setColor("loss", obj.strings.loss, text)
end

function obj.lootcolorSlash(text)
  obj.setColor("loot", obj.strings.loot, text)
end

function obj.partycolorSlash(text)
  obj.setColor("party", obj.strings.party, text)
end

function obj.craftcolorSlash(text)
  obj.setColor("craft", obj.strings.craft, text)
end

function obj.defaultsSlash()
  for k, v in pairs(Snoop.Defaults) do SnoopSettings[k] = v end

  msg(obj.strings.slashReset1)
  msg(obj.strings.slashReset2)

  zo_callLater(function() ReloadUI() end, 5000)
end