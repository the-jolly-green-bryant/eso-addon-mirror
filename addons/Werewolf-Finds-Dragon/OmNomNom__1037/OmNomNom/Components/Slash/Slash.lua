local obj = omNomNomAddon
local db  = omNomNomAddonDB

local playerName, lom, msg

function obj.slashHandler(varType)
  if not obj.lom then return end

  playerName = playerName or GetUnitName("player")

  if not obj.doMessage then
    obj.doMessage = function(textMessage, formatTable)
      obj.lom:Send(lom:Title("OmNomNom")..textMessage, formatTable)
    end

    lom = obj.lom
    msg = obj.doMessage
  end

  local varText

  if type(varType) == "string" then
    if varType:find(" ") then varType, varText = varType:match("(%w+) (.*)") end

    verType = varType:lower()
  end

  if varType and obj[varType] then
    obj[varType](varText)

  else
    obj.showHelp()
  end
end

function obj.showHelp()
  local alert = "<<LOM-GREEN>>/nom <<LOM-FOOD_OR_DRINK>><<LOM-WHITE>> The text you enter after this command becomes your <<LOM-FOOD_OR_DRINK>> alert. If you enter no text it shows you what your alert is."

  msg("Here are the commands you can use...")
  msg(alert,                                                                              {GREEN=lom.greenColor, WHITE=lom.clearToWhite, FOOD_OR_DRINK="food"})
  msg(alert,                                                                              {GREEN=lom.greenColor, WHITE=lom.clearToWhite, FOOD_OR_DRINK="drink"})
  msg("<<LOM-GREEN>>/nom toggle<<LOM-WHITE>> Toggles the addon on/off.",                  {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
  msg("<<LOM-GREEN>>/nom reset<<LOM-WHITE>> Resets the options to their default values.", {GREEN=lom.greenColor, WHITE=lom.clearToWhite})
end

function obj.descriptorHandler(varType, varText)
  if not varType or not varText then return end

  db[playerName][varType.."Text"] = varText

  msg("Your <<LOM-FOOD_OR_DRINK>> alert is: <<LOM-CYAN>><<LOM-ALERT>>", {FOOD_OR_DRINK=varType, CYAN=lom.cyanColor, ALERT=db[playerName][varType.."Text"]})
end

function obj.food(varText)
  obj.descriptorHandler("food", varText)
end

function obj.drink(varText)
  obj.descriptorHandler("drink", varText)
end

function obj.toggle()
  db.addonState = not db.addonState

  msg("Addon has been toggled <<LOM-STATE>>.", {STATE=(db.addonState and lom.greenColor.."on" or lom.redColor.."off")})
end

function obj.reset()
  db = obj.defaultsDB

  msg("All options have been reset to their default values.")
end

SLASH_COMMANDS["/nom"] = obj.slashHandler