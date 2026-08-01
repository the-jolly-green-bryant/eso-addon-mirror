GoldBalance = {}

GoldBalance.name = "GoldBalance"
GoldBalance.sessionStartGold = 0
GoldBalance.sessionStartTime = 0
GoldBalance.goldEarned = 0
GoldBalance.goldSpent = 0
GoldBalance.balance = 0
GoldBalance.sessionTime = 0
GoldBalance.goldPerMinute = 0


EVENT_MANAGER:RegisterForEvent("GoldBalance", EVENT_PLAYER_ACTIVATED, function()
  GoldBalance.sessionStartGold = GetCurrentMoney()
  GoldBalance.sessionStartTime = GetTimeStamp()
  GoldBalance.goldEarned = 0
  GoldBalance.goldSpent = 0
  GoldBalance.balance = 0
  GoldBalance.sessionTime = 0
  GoldBalance.goldPerMinute = 0
end)

function currentTime(time)
  time = time - GoldBalance.sessionStartTime
  hours = string.format("%02.f", math.floor(time/3600))
  mins = string.format("%02.f", math.floor(time/60 - (hours*60)))
  secs = string.format("%02.f", math.floor(time - hours*3600 - mins *60))
  output = hours .. " hours, " .. mins .. " minutes, " .. secs .. " seconds."
  return output
end

function getMinutes(time)
  time = time - GoldBalance.sessionStartTime
  mins = string.format("%02.f", math.floor(time/60))
  if tonumber(mins) > tonumber("0") then
    return mins
  else
    return 1
  end
end

SLASH_COMMANDS["/gb"] = function() 
  d("Session balance: " .. GetCurrentMoney() - GoldBalance.sessionStartGold)
  d("Session time: " .. currentTime(GetTimeStamp()))
  d("Gold per minute: " .. ((GetCurrentMoney() - GoldBalance.sessionStartGold) / getMinutes(GetTimeStamp())))
end