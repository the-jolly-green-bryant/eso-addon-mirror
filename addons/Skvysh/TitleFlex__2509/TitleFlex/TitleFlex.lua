--[[
Addon to loop through specific titles at a specific rate
TODO:
  * Enjoy life
]]--

-------------------------------------
TitleFlex = {
  name = "TitleFlex",
  title = "TitleFlex",
  version = "1.8.0",
  varVersion = 3,
  counter = 0, -- count which title we're on currently
  counterLimit = 0, -- how many titles were selected in total
  maxTitles = 10, -- how many titles do the settings allow to pick
  titleList = {}, --list of titles player has chosen
  titleIDList = {}, --list of IDs of the titles the player has chosen
  titleChoices = {}, --list of titles available to the player
  titleTimer = 0,
  slashCommands = "/titleflex",
}
for i=1,TitleFlex.maxTitles do --set default values for tables
  TitleFlex.titleList[i] = GetString(SI_STATS_NO_TITLE)
end
--------------------------------------

function TitleFlex.StartCountdown() --Register an event to call a function to change title every time desired interval passes
  EVENT_MANAGER:UnregisterForUpdate(TitleFlex.name .. "Countdown")
  EVENT_MANAGER:RegisterForUpdate(TitleFlex.name .. "Countdown", TitleFlex.titleTimer, function()
    TitleFlex.ChangeTitle()
  end)
end

function TitleFlex.HandleSlashCommands(cmd) --Handle slash commands
  cmd = string.lower(cmd)
  if cmd == "enable" then
    TitleFlex.settings.enableRotation = not TitleFlex.settings.enableRotation
    TitleFlex.EnableRotation(TitleFlex.settings.enableRotation)
    CHAT_ROUTER:AddSystemMessage(string.format(
      "[%s] Title Rotating: %s",
      TitleFlex.title,
      GetString(TitleFlex.settings.enableRotation and SI_CHECK_BUTTON_ON or SI_CHECK_BUTTON_OFF)
    ))
  else
    CHAT_ROUTER:AddSystemMessage(TitleFlex.title)
    CHAT_ROUTER:AddSystemMessage("/titleflex enable – Enable/disable the rotating of titles.")
  end
end

function TitleFlex.ReloadSettings() --Load new settings and restart timer/etc. for convenience
  TitleFlex.counterLimit = 0
  TitleFlex.counter = 0
  TitleFlex.titleList = {
    [1] = TitleFlex.settings.titleChoice1,
    [2] = TitleFlex.settings.titleChoice2,
    [3] = TitleFlex.settings.titleChoice3,
    [4] = TitleFlex.settings.titleChoice4,
    [5] = TitleFlex.settings.titleChoice5,
    [6] = TitleFlex.settings.titleChoice6,
    [7] = TitleFlex.settings.titleChoice7,
    [8] = TitleFlex.settings.titleChoice8,
    [9] = TitleFlex.settings.titleChoice9,
    [10] = TitleFlex.settings.titleChoice10,
  }
  TitleFlex.GetTitleIDs()
  TitleFlex.titleTimer = TitleFlex.settings.changeIntervalMinutes*1000*60+TitleFlex.settings.changeIntervalSeconds*1000
  TitleFlex.EnableRotation(TitleFlex.settings.enableRotation)
end

function TitleFlex.EnableRotation(value) --Handle enablind/disabling of the title rotating
  if value == true then
    TitleFlex.StartCountdown()
  else
    EVENT_MANAGER:UnregisterForUpdate(TitleFlex.name .. "Countdown")
  end
end

function TitleFlex.GetTitleIDs() --convert selected title names to IDs. Called on startup as well as when an achievement is earned
  for i=1,TitleFlex.maxTitles do
    if TitleFlex.titleList[i] ~= GetString(SI_STATS_NO_TITLE) then
      for j=1,GetNumTitles() do
        if TitleFlex.titleList[i] == GetTitle(j) then
          TitleFlex.counterLimit = TitleFlex.counterLimit + 1
          TitleFlex.titleIDList[TitleFlex.counterLimit] = j
          break
        end
      end
    end
  end
end

function TitleFlex.ChangeTitle() --change title if there are any selected
  if TitleFlex.counterLimit ~= 0 then
    TitleFlex.counter = TitleFlex.counter + 1
    local titleID = TitleFlex.titleIDList[TitleFlex.counter]
    SelectTitle(titleID)
    if TitleFlex.counter == TitleFlex.counterLimit then
      TitleFlex.counter = 0
    end
  end
end

function TitleFlex.GetTitleID(title) --currently unused function to get the ID of a title using the name of the title
  local index = 0
  for i=1,GetNumTitles() do
    if GetTitle(i) == title then
      index = i
      break
    end
  end
  return index
end

function TitleFlex.HasTitles(T) --check if player has chosen any titles to display
  for index, name in ipairs(T) do
    if name ~= 0 then
      return true
    end
  end
  return false
end

function TitleFlex.TableLength(T) --function to get the length of the table
  local count = 0
  for _ in pairs(T) do
    count = count + 1
  end
  return count
end

function TitleFlex.OnAddOnLoaded(event, addonName) --initialize the addon
  if addonName == TitleFlex.name then
    EVENT_MANAGER:UnregisterForEvent(TitleFlex.name, EVENT_ADD_ON_LOADED)
    TitleFlex.SettingsLoad()
    TitleFlex.SettingsBuildMenu()
    TitleFlex.SettingsBuildTitleTable()
    TitleFlex.GetTitleIDs()
    TitleFlex.EnableRotation(TitleFlex.settings.enableRotation)
  end
end

EVENT_MANAGER:RegisterForEvent(TitleFlex.name, EVENT_ADD_ON_LOADED, TitleFlex.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent("TitleFlexAchievementEarned", EVENT_ACHIEVEMENT_AWARDED, TitleFlex.GetTitleIDs)
SLASH_COMMANDS[TitleFlex.slashCommands] = TitleFlex.HandleSlashCommands