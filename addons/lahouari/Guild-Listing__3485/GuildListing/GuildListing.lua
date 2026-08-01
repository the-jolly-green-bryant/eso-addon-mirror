-- Namespace
DLC_GuildListing = {}

DLC_GuildListing.name = "GuildListing"
DLC_GuildListing.guildData = {}
DLC_GuildListing.isScanning = false

DLC_GuildListing.savedDataVersion = 1
DLC_GuildListing.savedData = nil

local logger = nil
if LibDebugLogger then
  logger = LibDebugLogger.Create(DLC_GuildListing.name)
  DLC_GuildListing.logger = logger
else
  logger = {
    Info = function(msg) end
  }
end

function DLC_GuildListing:Initialize()
  DLC_GuildListing.savedData = ZO_SavedVars:NewAccountWide("GuildListingData", DLC_GuildListing.savedDataVersion, nil, nil, nil)

  logger:Info("Guild Listing initialized!")
end

function DLC_GuildListing.SaveGuild(option)
  local guildIndex = tonumber(option)
  if guildIndex == nil then return end
  local guilds = GetNumGuilds()
  if guildIndex <= 0 then return end
  if guildIndex > guilds then return end
  local guildId = GetGuildId(guildIndex)
  local guildName = GetGuildName(guildId)
  local members = GetNumGuildMembers(guildId)

  DLC_GuildListing.guildData[guildName] = {}

  for i=1, members  do
    local name, note, rankIndex, _, secsSinceLogoff = GetGuildMemberInfo(guildId, i)
    local rankName = GetGuildRankCustomName(guildId, rankIndex)
    name = name:gsub("|c.*|r", "")
    rankName = rankName:gsub("|c.*|r", "")
    table.insert(DLC_GuildListing.guildData[guildName], name .. "," .. rankIndex .. "," .. rankName .. "," .. secsSinceLogoff)
  end

  DLC_GuildListing.SaveData()
end

function DLC_GuildListing.SaveData()
  if DLC_GuildListing.isScanning then return end

  logger:Info("Guild Listing Saving data")
  DLC_GuildListing.savedData.Guilds = DLC_GuildListing.guildData 
  CHAT_ROUTER:AddSystemMessage("Guild Listing: Guild roster saved. Make sure to switch zone or /reloadui or log off in order to actually save to disk")
end

function DLC_GuildListing.ClearData()
  if DLC_GuildListing.isScanning then return end

  DLC_GuildListing.guildData = {}
  DLC_GuildListing.guildName = {}

  DLC_GuildListing.savedData = {}
  LibGuildRoster:Refresh()
end

local function DLC_CloseMsgBox(dialogName)
  ZO_Dialogs_ReleaseDialog(dialogName, false)
  DLC_GuildListingt.activeDialog[dialogName] = nil
end

local function DLC_ShowMsgBox(dialogName, title, msg)
  if ZO_Dialogs_IsShowing(dialogName) and DLC_GuildListing.activeDialog[dialogName] then
    ZO_Dialogs_UpdateDialogMainText(DLC_GuildListing.activeDialog[dialogName], {text = msg})
  else
    local confirmDialog = 
    {
      title = { text = title },
      mainText = { text = msg },
      buttons = {}
    }
    ZO_Dialogs_RegisterCustomDialog(dialogName, confirmDialog)
    DLC_GuildListing.activeDialog[dialogName] = ZO_Dialogs_ShowDialog(dialogName)
  end 
end

local function DLC_OnAddonLoaded(event, addonName)
  if addonName == DLC_GuildListing.name then
    DLC_GuildListing:Initialize()

    SLASH_COMMANDS['/saveguild'] = DLC_GuildListing.SaveGuild

    EVENT_MANAGER:UnregisterForEvent(DLC_GuildListing.name, EVENT_ADD_ON_LOADED)
  end
end

EVENT_MANAGER:RegisterForEvent(DLC_GuildListing.name, EVENT_ADD_ON_LOADED, DLC_OnAddonLoaded)

