if not LibStub then return end

local MAJOR = "LibOmniMessage-3.0"
local MINOR = 002
local lom   = LibStub:NewLibrary(MAJOR, MINOR)

if not lom then return end

lom.redColor     = "|cffaaaa"
lom.greenColor   = "|caaffaa"
lom.blueColor    = "|caaaaff"

lom.yellowColor  = "|cffffaa"
lom.cyanColor    = "|caaffff"
lom.purpleColor  = "|cffaaff"
lom.greyColor    = "|cdddddd"

lom.clearToWhite = "|r|cffffff"
lom.clearColor   = "|r"

function lom:Title(addonName)
  return lom.blueColor..addonName..": "..lom.clearToWhite
end

function lom:Format(textMessage, formatTable, indicator, replaceWith)
  if type(formatTable) == "table" and type(textMessage) == "string" then
    for indicator, replaceWith in pairs(formatTable) do
      textMessage = textMessage:gsub("(<)(<)LOM(-)"..indicator.."(>)(>)", replaceWith)
    end
  end

  return textMessage
end

function lom:Alert(alertText, sound, csa)
  sound = sound or SOUNDS.DISPLAY_ANNOUNCEMENT
  csa   = csa   or CENTER_SCREEN_ANNOUNCE_TYPE_LORE_BOOK_LEARNED_SKILL_EXPERIENCE

  local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, sound)

  messageParams:SetText(alertText)
  messageParams:SetCSAType(csa)

  CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

function lom:Send(textMessage, formatTable)
  if not textMessage or type(textMessage) ~= "string" then return end

  textMessage = formatTable and lom:Format(textMessage, formatTable) or textMessage
  textMessage = textMessage.."|r"

  local windowIndex, tabIndex

  for windowIndex = 1, #CHAT_SYSTEM.containers do
    for tabIndex  = 1, #CHAT_SYSTEM.containers[windowIndex].windows do
      CHAT_SYSTEM.containers[windowIndex].windows[tabIndex].buffer:AddMessage(textMessage)
    end
  end
end

CHAT_SYSTEM.AddMessage = function(self, value)
  lom:Send(lom.yellowColor..tostring(value)..lom.clearColor)
end