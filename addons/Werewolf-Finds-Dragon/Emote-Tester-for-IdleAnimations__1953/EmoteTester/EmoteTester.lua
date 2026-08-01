EmoteTester = {}

function EmoteTester.doEmote(emoteText)
  if SLASH_COMMANDS["/"..emoteText] then
    SLASH_COMMANDS["/"..emoteText]()
  end
end

function EmoteTester.doMsg(printText)
  printText = printText:gsub("<<", "|caaffaa")
  printText = printText:gsub(">>", "|r")
 
 d("|caaaaffEmoteTester: |r"..printText)
end

function EmoteTester.slashHandler(emoteText)
  if not emoteText or emoteText == "" or emoteText == "help" then
    EmoteTester.doMsg("The format for using this addon is as follows <<[emote] [time]-[emote] [time]-[emote]>>.")
    EmoteTester.doMsg("For example <</emtest laugh 10-cry 10-laugh 10-cry>>.")

    return
  end

  local emoteTable, lastTime = {}

  if not emoteText:find(" ") then
    emoteTable[1] = {emote = emoteText}

    EmoteTester.doMsg("Emoting <<"..emoteText..">>.")

    EmoteTester.doEmote(emoteText)

  else
    lastTime = 0

    for dataStr in emoteText:gmatch("([^%s]+)") do
      if dataStr:find("-") then
        local _, _, eTime, eText           = dataStr:find("(%d+)-(%w+)")
        eTime                              = tonumber(eTime) + lastTime
        emoteTable[(#emoteTable or 0) + 1] = {emote = eText, time = eTime}

        zo_callLater(function()
          EmoteTester.doEmote(eText)

          eText = "Emoting <<"..eText..">> after "
          eTime = tostring(tonumber(eTime) / 1000)
          eTime = "<<"..eTime..">> "..(eTime == "1" and "second" or "seconds").."."

          EmoteTester.doMsg(eText..eTime)
        end, eTime)

        lastTime = eTime

      else
        emoteTable[(#emoteTable or 0) + 1] = {emote = dataStr}

        EmoteTester.doMsg("Emoting <<"..dataStr..">>.")

        EmoteTester.doEmote(dataStr)
      end
    end
  end

  lastTime = lastTime or 0

  zo_callLater(function()
    EmoteTester.doMsg("To copy the result from the edit box, press return.")
    EmoteTester.doMsg("To enter a new command, press the / key.")

    local outputStr = '[""] = {'

    for _, emoteData in ipairs(emoteTable) do
      outputStr = (emoteData.time  and outputStr..      emoteData.time.. ', '  or outputStr)
      outputStr = (emoteData.emote and outputStr..'"/'..emoteData.emote..'", ' or outputStr)
    end

    outputStr = outputStr:sub(1, -3)..'},'

    ZO_ChatWindowTextEntryEditBox:SetText(outputStr)
  end, lastTime + 100)
end

SLASH_COMMANDS["/emtest"] = EmoteTester.slashHandler