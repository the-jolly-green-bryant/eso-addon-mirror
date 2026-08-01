ELM = {}
ELM.Name = "EmoteLoop"
ELM.Version = "1.01"

function StopLoopingEmote()
  EVENT_MANAGER:UnregisterForUpdate("PerformLoopedEmote")
  EVENT_MANAGER:UnregisterForUpdate("ClearPreviousEmote")
end

function StartLoopingEmote(emote, delay, endless)
  ELMcommand = table.concat({"/", emote}, "")
  if type(delay) ~= "number" then
    local delay = 2500
  end
  if emote then
    EVENT_MANAGER:RegisterForUpdate("PerformLoopedEmote", delay, function () DoCommand(ELMcommand) end)
    EVENT_MANAGER:RegisterForUpdate("ClearPreviousEmote", delay - 50, function () DoCommand("/idle") end)
    if endless ~= true then
      zo_callLater(StopLoopingEmote, delay * 20 )
    end
  end
end

SLASH_COMMANDS["/loop"] = function (emote)
  StartLoopingEmote(emote, 2500, false)
end

SLASH_COMMANDS["/startloop"] = function (emote)
  StartLoopingEmote(emote, 2500, true)
end

SLASH_COMMANDS["/stoploop"] = function()
  StopLoopingEmote()
end

SLASH_COMMANDS["/endloop"] = function()
  StopLoopingEmote()
end