--[[
Addon to loop through specific guild names displayed on character at a specific rate
Based on TitleFlex by Kwiebe-Kwibus
Adapted for guild name rotation (SetRepresentedGuildId, available since ESO U49)
TODO:
  * Enjoy life
]]--

-------------------------------------
GuildFlex = {
  name = "GuildFlex",
  title = "GuildFlex",
  version = "1.0.1",
  varVersion = 1,
  author = "Kwiebe-Kwibus",
  counter = 0,       -- index of the currently displayed guild in the rotation
  counterLimit = 0,  -- total number of guilds selected for rotation
  maxGuilds = 5,     -- ESO cap: a player can belong to at most 5 guilds
  guildList = {},    -- names of the guilds chosen by the player for the rotation
  guildIDList = {},  -- guild IDs matching the chosen names
  guildChoices = {}, -- all guild names available to the player (populated at load)
  guildTimer = 0,
  slashCommands = "/guildflex",
  accountSettings = {}, -- main settings table
  settings = {},        -- currently active settings (account-wide or per-character)
}

local NO_GUILD = "None"
for i = 1, GuildFlex.maxGuilds do
  GuildFlex.guildList[i] = NO_GUILD
end
--------------------------------------

function GuildFlex.StartCountdown()
  EVENT_MANAGER:UnregisterForUpdate(GuildFlex.name .. "Countdown")
  EVENT_MANAGER:RegisterForUpdate(GuildFlex.name .. "Countdown", GuildFlex.guildTimer, function()
    GuildFlex.ChangeGuild()
  end)
end

function GuildFlex.HandleSlashCommands(cmd)
  cmd = string.lower(cmd)
  if cmd == "enable" then
    GuildFlex.settings.enableRotation = not GuildFlex.settings.enableRotation
    GuildFlex.EnableRotation(GuildFlex.settings.enableRotation)
    CHAT_ROUTER:AddSystemMessage(string.format(
      "[%s] Guild Rotating: %s",
      GuildFlex.title,
      GetString(GuildFlex.settings.enableRotation and SI_CHECK_BUTTON_ON or SI_CHECK_BUTTON_OFF)
    ))
  else
    CHAT_ROUTER:AddSystemMessage(GuildFlex.title)
    CHAT_ROUTER:AddSystemMessage("/guildflex enable – Enable/disable the rotating of displayed guild names.")
  end
end

function GuildFlex.ReloadSettings()
  GuildFlex.counterLimit = 0
  GuildFlex.counter = 0
  GuildFlex.guildList = {}
  for i = 1, GuildFlex.maxGuilds do
    GuildFlex.guildList[i] = GuildFlex.settings["guildChoice" .. i]
  end
  GuildFlex.GetGuildIDs()
  GuildFlex.guildTimer = GuildFlex.settings.changeIntervalMinutes * 60000
                       + GuildFlex.settings.changeIntervalSeconds * 1000
  GuildFlex.EnableRotation(GuildFlex.settings.enableRotation)
end

function GuildFlex.EnableRotation(value)
  if value == true then
    GuildFlex.StartCountdown()
  else
    EVENT_MANAGER:UnregisterForUpdate(GuildFlex.name .. "Countdown")
  end
end

function GuildFlex.GetGuildIDs()
  -- Convert chosen guild names to guild IDs.
  -- Called at startup and whenever guild data is reloaded.
  GuildFlex.counterLimit = 0
  GuildFlex.guildIDList = {}

  for i = 1, GuildFlex.maxGuilds do
    local chosenName = GuildFlex.guildList[i]
    if chosenName and chosenName ~= NO_GUILD then
      for j = 1, GetNumGuilds() do
        local guildId   = GetGuildId(j)
        local guildName = GetGuildName(guildId)
        if chosenName == guildName then
          GuildFlex.counterLimit = GuildFlex.counterLimit + 1
          GuildFlex.guildIDList[GuildFlex.counterLimit] = guildId
          break
        end
      end
    end
  end
end

function GuildFlex.ChangeGuild()
  -- Cycle to the next guild in the rotation and display it.
  -- API: SetRepresentedGuildId(guildId) — sets the guild name shown on the character sheet.
  if GuildFlex.counterLimit ~= 0 then
    GuildFlex.counter = GuildFlex.counter + 1
    local guildId = GuildFlex.guildIDList[GuildFlex.counter]
    SetRepresentedGuildId(guildId)
    if GuildFlex.counter == GuildFlex.counterLimit then
      GuildFlex.counter = 0
    end
  end
end

function GuildFlex.TableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function GuildFlex.OnAddOnLoaded(event, addonName)
  if addonName == GuildFlex.name then
    EVENT_MANAGER:UnregisterForEvent(GuildFlex.name, EVENT_ADD_ON_LOADED)
    GuildFlex.SettingsLoad()
    GuildFlex.SettingsBuildGuildTable()
    GuildFlex.SettingsBuildMenu()
    GuildFlex.GetGuildIDs()
    GuildFlex.EnableRotation(GuildFlex.settings.enableRotation)
  end
end

local function OnGuildDataLoaded()
  GuildFlex.SettingsBuildGuildTable()
  GuildFlex.GetGuildIDs()
end

EVENT_MANAGER:RegisterForEvent(GuildFlex.name, EVENT_ADD_ON_LOADED, GuildFlex.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(GuildFlex.name .. "GuildData", EVENT_GUILD_DATA_LOADED, OnGuildDataLoaded)
SLASH_COMMANDS[GuildFlex.slashCommands] = GuildFlex.HandleSlashCommands
