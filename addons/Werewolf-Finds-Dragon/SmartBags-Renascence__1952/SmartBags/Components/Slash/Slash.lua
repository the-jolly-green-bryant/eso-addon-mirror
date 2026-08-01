local obj, db, lom, msg = SmartBags

function obj.SetupSlash(mainDB)
  db                                            = mainDB
  lom                                           = LibStub:GetLibrary("LibOmniMessage-3.0")
  SLASH_COMMANDS["/"..obj.strings.slashCommand] = obj.slashHandler

  if not obj.doMessage then
    obj.doMessage = function(textMessage, formatTable)
      lom:Send(lom:Title(obj.strings.slashName)..textMessage, formatTable)
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

  obj.barMain:SetColor( r, g, b)
  obj.barRight:SetColor(r, g, b)

  msg(obj.strings.slashRGB, {CYAN=lom.cyanColor, TYPE=text, WHITE=lom.clearToWhite, RED=lom.redColor, GREEN=lom.greenColor, BLUE=lom.blueColor, R=tostring(r), G=tostring(g), B=tostring(b)})
end

function obj.setSlider(opt, upper, text, symbol, min, max, push, _)
  text    = tonumber(text)
  text    = symbol and math.floor(text) or text
  db[opt] = text

  symbol = not symbol and "" or "%%"

  if push then SmartBagsUI[push](SmartBagsUI, text) end

  if text > max or text < min then
    msg(obj.strings.slashError2, {RED=lom.redColor, WHITE=lom.clearToWhite})

    return
  end

  msg(obj.strings.slashSlider, {CYAN=lom.cyanColor, UPPER=upper, WHITE=lom.clearToWhite, VAR=text, SYMBOL=symbol})
end

function obj.warnSlash(text)
  obj.setSlider("warn", obj.strings.slashPerCent, text, true, 0, 100)
end

function obj.alphaSlash(text)
  obj.setSlider("alpha", obj.strings.slashAlpha, text, nil, 0.0, 1.0, "SetAlpha")
end

function obj.unlockSlash()
  obj.toggleOpt("unlock", obj.strings.slashUnlock)
end

function obj.autoSlash()
  obj.toggleOpt("auto", obj.strings.slashAuto)
end

function obj.smartSlash()
  obj.toggleOpt("smart", obj.strings.slashSmart)
end

function obj.basecolorSlash(text)
  obj.setColor("base", obj.strings.slashBase, text)
end

function obj.warncolorSlash(text)
  obj.setColor("warn", obj.strings.slashWarn, text)
end

function obj.fullcolorSlash(text)
  obj.setColor("full", obj.strings.slashFull, text)
end

function obj.defaultsSlash()
  for k, v in pairs(SmartBags.Defaults) do SmartBagsSettings[k] = v end

  SmartBagsSettings.wndMainX = SmartBagsUI:GetLeft()
  SmartBagsSettings.wndMainY = SmartBagsUI:GetTop()

  msg(obj.strings.slashReset1)
  msg(obj.strings.slashReset2)

  zo_callLater(function() ReloadUI() end, 5000)
end