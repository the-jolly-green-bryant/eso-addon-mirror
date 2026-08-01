-- ****************************************************************************
--                                  namespace
-- ****************************************************************************

local COLOR_HOTEP = "|c3366ff"
local COLOR_MSG = "|cff6633"
local COLOR_RED = "|cff0000"
local COLOR_GREEN = "|c00ff00"
local COLOR_BLUE = "|c0066ff"
local COLOR_PURPLE = "|cff00ff"
local COLOR_YELLOW = "|cffff00"
local COLOR_WHITE = "|cffffff"
local COLOR_GRAY = "|c7f7f7f"


HotepGBank = {
  name = "HotepGBankView",
  savedVars = "HotepGBankVars",
  version = 1,
  theLAMPanel = nil,
  title = "Hotep Guild Bank Viewer",
  fancytitle = zo_strformat("<<1>>Hotep\194\174|r <<2>>Guild Bank Viewer|r", COLOR_HOTEP, COLOR_MSG),
  displayVersion = "0.1-beta",
  officer = nil,
  guildid = nil,
  plebguilds = {"No Guild", "No Guild", "No Guild", "No Guild", "No Guild"},
  plebphrases = {false, false, false, false, false},
  plebchoices = {"No Guild"},
  savedOfficer = {
    gname = false,
    pass = false,
    pin = false,
  }
}




local HotepToolsLib = LibStub("HotepToolsLib")

local clone = HotepToolsLib.HotepCommonFuncs.clone
local explode = HotepToolsLib.HotepCommonFuncs.explode
local in_array = HotepToolsLib.HotepCommonFuncs.in_array
local array_key_exists = HotepToolsLib.HotepCommonFuncs.array_key_exists
local array_indexof = HotepToolsLib.HotepCommonFuncs.array_indexof
local array_without = HotepToolsLib.HotepCommonFuncs.array_without
local array_glob = HotepToolsLib.HotepCommonFuncs.array_glob
local array_find = HotepToolsLib.HotepCommonFuncs.array_find
local uuid = HotepToolsLib.HotepCommonFuncs.uuid
local array_keys = HotepToolsLib.HotepCommonFuncs.array_keys
local spairs = HotepToolsLib.HotepCommonFuncs.spairs
local eyesort = HotepToolsLib.HotepCommonFuncs.eyesort
local msgWithName = function (msg, color) HotepToolsLib.HotepCommonFuncs.msgWithName(msg, color, HotepGBank.name) end
local badscene = HotepToolsLib.HotepCommonFuncs.badscene
local array_append = HotepToolsLib.HotepCommonFuncs.array_append
local empty = HotepToolsLib.HotepCommonFuncs.empty



local Timer = HotepToolsLib.HotepUtilities.Timer


local LAM = LibStub("LibAddonMenu-2.0")




-- ****************************************************************************
--                                  saved vars
-- ****************************************************************************


local SV_OFFICER = "SV_OFFICER"
local SV_PLEB = "SV_PLEB"
local SV_COMMON = "SV_COMMON"


---@local defaultVariables @classdef GBSAVED
local defaultVariables = {
  [SV_OFFICER] = {
    data = {
      guildname = false,
      passphrase = false,
      PIN = false,
      GBankItems = {},       -- simple array of gbank items
      lastscan = 0,
    },
  },
  [SV_PLEB] = {
    data = {
      guildlist = {},       -- simple array of guild names
      activated = {},       -- keys are guild names, values are passphrases
      GBankItems = {},      -- keys are guild names, values are gbank item lists
      asof = {},            -- keys are guild names, values are date last uploaded (timestamps)
    },
  },
  [SV_COMMON] = {
    data = {
      guildname = false,
      realm = false,
    },
  },
}

---@local savedVariables @class GBSAVED
---@local savedVariables.vars @class GBSAVED
local savedVariables = {vars = {}}

function savedVariables:Load(ns)
  self.vars[ns] = ZO_SavedVars:NewAccountWide(HotepGBank.savedVars, HotepGBank.version, ns, defaultVariables[ns])
  
  -- the following is constructed in this way so as to facilitate NetBeans auto-complete
  self[ns] = {}
  self[ns].data = self.vars[ns].data
  
  if ((ns == SV_OFFICER) and (not self.SV_OFFICER.data.lastscan)) then
    self.SV_OFFICER.data.lastscan = 0
  end
end




-- ****************************************************************************
--                                  main code
-- ****************************************************************************

HotepGBank_LAM_GuildsDropdown = nil
HotepGBank_LAM_OfficerPassphrase = nil
HotepGBank_LAM_PassphraseMessage = nil
HotepGBank_LAM_OfficerPIN = nil
HotepGBank_LAM_PINMessage = nil
HotepGBank_LAM_PlebGuild1 = nil
HotepGBank_LAM_PlebGuild2 = nil
HotepGBank_LAM_PlebGuild3 = nil
HotepGBank_LAM_PlebGuild4 = nil
HotepGBank_LAM_PlebGuild5 = nil
HotepGBank_LAM_PlebPhrase1 = nil
HotepGBank_LAM_PlebPhrase2 = nil
HotepGBank_LAM_PlebPhrase3 = nil
HotepGBank_LAM_PlebPhrase4 = nil
HotepGBank_LAM_PlebPhrase5 = nil



function HotepGBank.RestoreSavedSettings()
  if (not HotepGBank.savedOfficer.gname) then return end
--  d("restore 1")
  if (HotepGBank.savedOfficer.gname ~= savedVariables.SV_COMMON.data.guildname) then return end
--  d("restore 2")
  HotepGBank_LAM_OfficerPassphrase:UpdateValue(false, HotepGBank.savedOfficer.pass)
  
  if (savedVariables.SV_OFFICER and HotepGBank.savedOfficer.pin == true) then
    savedVariables.SV_OFFICER.data.PIN = true
    HotepGBank_LAM_OfficerPIN:UpdateValue()
    HotepGBank_LAM_OfficerPIN:UpdateDisabled()
  else
    HotepGBank_LAM_OfficerPIN:UpdateValue(false, HotepGBank.savedOfficer.pin)
  end
--  d("restore 3")
end


function HotepGBank.ChangedOfficerGuild(gname)
  
  savedVariables.SV_COMMON.data.guildname = gname
  
  if (gname == "No Guild") then
    HotepGBank_LAM_OfficerPassphrase:UpdateValue(false, "")
    HotepGBank_LAM_OfficerPIN:UpdateValue(false, "")
    return
  end
  
  
--  d({gname})
  if (HotepGBank.savedOfficer.gname and (HotepGBank.savedOfficer.gname == gname)) then
    HotepGBank.RestoreSavedSettings()
    return
  end
  
  if (not savedVariables.SV_OFFICER) then
    savedVariables:Load(SV_OFFICER)
  end
  
  if (savedVariables.SV_OFFICER.data.guildname) then
    if (savedVariables.SV_OFFICER.data.guildname == gname) then
      HotepGBank.RestoreSavedSettings()
      return
    end
  end
  
  if (not HotepGBank.savedOfficer.gname) then
--    d("SAVING")
    HotepGBank.savedOfficer.gname = savedVariables.SV_OFFICER.data.guildname
    HotepGBank.savedOfficer.pass = savedVariables.SV_OFFICER.data.passphrase
    HotepGBank.savedOfficer.pin = savedVariables.SV_OFFICER.data.PIN
  end
--  d("changing 1")
  HotepGBank_LAM_OfficerPassphrase:UpdateValue(false, "")
  
  savedVariables.SV_OFFICER.data.PIN = false
  
  HotepGBank_LAM_OfficerPIN:UpdateValue(false, "")
--  d("changing 2")
end
-- end HotepGBank.ChangedOfficerGuild(gname)


function HotepGBank:CreateAddonMenu()
  
  local paneldata = {
    type = "panel",
    name = HotepGBank.title,
    displayName = HotepGBank.fancytitle,
    author = "|cff6633@tomtom|r|c3366ffhotep|r",
    version = HotepGBank.displayVersion,
    registerForRefresh = true,
  }
  
  
  local odisab = function()
    return (not savedVariables.SV_COMMON.data.guildname or (savedVariables.SV_COMMON.data.guildname == "No Guild"))
  end
  -- end local function disab
  
  local pindisab = function()
    local p
    
    if (not savedVariables.SV_OFFICER) then
      p = true
    else
      p = savedVariables.SV_OFFICER.data.PIN
    end
    
    return (odisab() or (p and (type(p) == "boolean")))   -- PIN is boolean TRUE
  end
  
  
  
  local footer = {
    type = "description",
    text = "Hotep\194\174 is a registered trademark of Simple Designs Software LLC. All Rights Reserved.",
  }
  
  
  local officers = {
    [1] = {
      type = "dropdown",
      name = "Guild To Upload",
      tooltip = "Choose the guild for which you will be uploading the Guild Bank Item Contents.",
      choices = {"No Guild"},
      getFunc = function()
                  if (not savedVariables.SV_COMMON.data.guildname) then
                    return "No Guild"
                  else
                    return savedVariables.SV_COMMON.data.guildname
                  end
                end,
      setFunc = function(x) HotepGBank.ChangedOfficerGuild(x) end,
      reference = "HotepGBank_LAM_GuildsDropdown",
    },
    
    [2] = {
      type = "editbox",
      name = "Guild Passphrase",
      tooltip = "This is the Security Passphrase for Uploading and Downloading your Guild Bank Item List",
      warning = "Must be 8-36 characters, contain Upper & Lower-case Letters, and at least 1 number and 1 symbol. May contain spaces, but not consecutive spaces.",
      getFunc = function()
                  if (savedVariables.SV_OFFICER and savedVariables.SV_OFFICER.data.passphrase) then
                    return savedVariables.SV_OFFICER.data.passphrase
                  else
                    return ""
                  end
                end,
      setFunc = function(x)
                  if (savedVariables.SV_OFFICER) then
                    savedVariables.SV_OFFICER.data.passphrase = HotepGBank.ValidatePP(x)
                  end
                end,
      disabled = odisab,
      reference = "HotepGBank_LAM_OfficerPassphrase",
    },
    
    [3] = {
      type = "description",
      text = "|cffffffThe passphrase will be stored by this Addon. You will NOT need to enter it again here or on the website.|r\n" ..
             "|cffff00Please give it to your guild members to enter into their GBankView Addon Settings.|r",
      reference = "HotepGBank_LAM_PassphraseMessage",
    },
    
    [4] = {
      type = "editbox",
      name = "Guild PIN #",
      tooltip = "This is a 4-digit PIN # to authorize Website access to your Guild Item List.",
      getFunc = function()
                  if (not savedVariables.SV_OFFICER) then
                    return ""
                  elseif (savedVariables.SV_OFFICER.data.PIN == true) then
                    return "uploaded to website"
                  elseif (savedVariables.SV_OFFICER.data.PIN == false) then
                    return ""
                  else
                    return savedVariables.SV_OFFICER.data.PIN
                  end
                end,
      setFunc = function(x)
                  if (savedVariables.SV_OFFICER) then
                    savedVariables.SV_OFFICER.data.PIN = HotepGBank.ValidatePIN(x)
                  end
                end,
      disabled = pindisab,
      reference = "HotepGBank_LAM_OfficerPIN",
    },
    
    [5] = {
      type = "description",
      text = "|cff6633The PIN will be stored by this Addon ONLY until you first access the website.|r\n" ..
             "|cffff00You WILL NEED to enter it every time you access the website, so please write it down, "..
             "and give it to your guild members privately. Do NOT share it with anyone outside your guild.|r",
      reference = "HotepGBank_LAM_PINMessage",
    },
  }
  
  
  local drop = function(i)
    return {
        type = "dropdown",
        name = zo_strformat("Guild <<1>> To Download", i),
        tooltip = "Choose a guild for which you will be downloading Guild Bank Item Contents.",
        width = "half",
        choices = HotepGBank.plebchoices,
        getFunc = function() return HotepGBank.plebguilds[i] end,
        setFunc = function(x) HotepGBank.plebguilds[i] = x; HotepGBank.RefreshLAMPleb() end,
        reference = zo_strformat("HotepGBank_LAM_PlebGuild<<1>>", i),
    }
  end
  
  local field = function(i)
    return {
        type = "editbox",
        name = zo_strformat("PassPhrase for Guild <<1>>", i),
        tooltip = "Get this from an Officer.",
        width = "half",
        getFunc = function() return HotepGBank.plebphrases[i] or "" end,
        setFunc = function(x) HotepGBank.plebphrases[i] = x end,
        reference = zo_strformat("HotepGBank_LAM_PlebPhrase<<1>>", i),
        disabled = function() return (HotepGBank.plebguilds[i] == "No Guild") end
    }
  end
  
  local div = {
    type = "divider",
  }
  
  local mainOptions = {}
  
  for i = 1,5 do
    table.insert(mainOptions, drop(i))
    table.insert(mainOptions, field(i))
    table.insert(mainOptions, div)
  end
  
  
  
  local OfficerOptions = {
    type = "submenu",
    name = "Guild Officer Settings",
    tooltip = "If you have Guild Withdrawal Permissions in one of your Guilds,"..
              " and would like to upload GBank Items to the WebSite, set these options.",
    controls = officers
  }
  
  table.insert(mainOptions, OfficerOptions)
  
  table.insert(mainOptions, footer)
  
  
  HotepGBank.theLAMPanel = LAM:RegisterAddonPanel(HotepGBank.name, paneldata)
  LAM:RegisterOptionControls(HotepGBank.name, mainOptions)
  CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", HotepGBank.MyLAMWasOpened)
  CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", HotepGBank.MyLAMWasOpened)
  CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", HotepGBank.MyLAMWasClosed)
end
-- end HotepGBank:CreateAddonMenu()


function HotepGBank.RefreshLAMPleb()
  
  local PlebGuilds = {
    HotepGBank_LAM_PlebGuild1,
    HotepGBank_LAM_PlebGuild2,
    HotepGBank_LAM_PlebGuild3,
    HotepGBank_LAM_PlebGuild4,
    HotepGBank_LAM_PlebGuild5,
  }
  
  local PlebPhrases = {
    HotepGBank_LAM_PlebPhrase1,
    HotepGBank_LAM_PlebPhrase2,
    HotepGBank_LAM_PlebPhrase3,
    HotepGBank_LAM_PlebPhrase4,
    HotepGBank_LAM_PlebPhrase5,
  }
  
  
  local n = GetNumGuilds()
  
  HotepGBank.plebchoices = {"No Guild"}
  
  for i = 1,n do
    local gid = GetGuildId(i)
    local name = GetGuildName(gid)
    if (not DoesPlayerHaveGuildPermission(gid, GUILD_PERMISSION_BANK_WITHDRAW)) then
      if (not in_array(name, HotepGBank.plebguilds)) then
        table.insert(HotepGBank.plebchoices, name)
      end
    end
  end
  
  for i,control in ipairs(PlebGuilds) do
    local choices = clone(HotepGBank.plebchoices)
    table.insert(choices, HotepGBank.plebguilds[i])
    control:UpdateChoices(choices)
    control:UpdateValue()
  end
  
  for i,control in ipairs(PlebPhrases) do
    if (HotepGBank.plebguilds[i] == "No Guild") then
      HotepGBank.plebphrases[i] = false
      control:UpdateValue()
    end
    control:UpdateDisabled()
  end
end
-- end HotepGBank.RefreshLAMPleb()


function HotepGBank.MyLAMWasClosed(panel)
  if (panel == HotepGBank.theLAMPanel) then
    HotepGBank.Setup()
  end
end

function HotepGBank.MyLAMWasOpened(panel)
  if (panel == HotepGBank.theLAMPanel) then
    local n = GetNumGuilds()
    
    local guildchoices = {"No Guild"}
    
    for i = 1,n do
      local gid = GetGuildId(i)
      local name = GetGuildName(gid)
      if (DoesPlayerHaveGuildPermission(gid, GUILD_PERMISSION_BANK_WITHDRAW)) then
        table.insert(guildchoices, name)
      end
    end
    
    if (HotepGBank_LAM_GuildsDropdown) then
      HotepGBank_LAM_GuildsDropdown:UpdateChoices(guildchoices)
      HotepGBank_LAM_GuildsDropdown:UpdateValue()
    end
    
    HotepGBank.RefreshLAMPleb()
  end
end
-- end HotepGBank.MyLAMWasOpened(panel)


function HotepGBank.GetGuildID(gname)
  local n = GetNumGuilds()
  
  for i = 1,n do
    local gid = GetGuildId(i)
    if (GetGuildName(gid) == gname) then
      return gid
    end
  end
  
  return false
end
-- end HotepGBank.GetGuildID(gname)


function HotepGBank.Setup()
  
  local gname = savedVariables.SV_COMMON.data.guildname
  
  if (not gname) then
    HotepGBank.UserSetup()
    return
  end
  
  local gid = HotepGBank.GetGuildID(gname)
  
  if (not gid) then
    HotepGBank.UserSetup()
    return
  end
  
  HotepGBank.guildid = gid
  
  if (DoesPlayerHaveGuildPermission(gid, GUILD_PERMISSION_BANK_WITHDRAW)) then   -- officer setup
    HotepGBank.officer = true
    
    if (not savedVariables.SV_OFFICER) then
      savedVariables:Load(SV_OFFICER)
    end
    
    savedVariables.SV_OFFICER.data.guildname = gname
    
    HotepGBank.PlebSetup()
    
    if (not HotepGBank.ValidatePP(savedVariables.SV_OFFICER.data.passphrase)) then
      msgWithName("Please set up the rest of the Officer Options.", COLOR_PURPLE);
    elseif (not HotepGBank.ValidatePIN(savedVariables.SV_OFFICER.data.PIN)) then
      msgWithName("Please set up the rest of the Officer Options.", COLOR_PURPLE);
    else
      msgWithName("Loaded in Officer Mode.", COLOR_PURPLE);
      EVENT_MANAGER:RegisterForEvent(HotepGBank.name, EVENT_OPEN_GUILD_BANK, HotepGBank.BankOpened)
      EVENT_MANAGER:RegisterForEvent(HotepGBank.name, EVENT_GUILD_BANK_SELECTED, HotepGBank.BankOpened)
      EVENT_MANAGER:RegisterForEvent(HotepGBank.name, EVENT_CLOSE_GUILD_BANK, HotepGBank.BankClosed)
    end
    
  else
    HotepGBank.UserSetup()
  end
end
-- end HotepGBank:Setup()


-- Must be 8-36 characters, contain Upper & Lower-case Letters, and at least 
-- 1 number and 1 symbol. May contain spaces, but not consecutive spaces.
function HotepGBank.ValidatePP(x)
  
  if (HotepGBank_LAM_PassphraseMessage and HotepGBank_LAM_PassphraseMessage.origtext) then
    HotepGBank_LAM_PassphraseMessage.data.text = HotepGBank_LAM_PassphraseMessage.origtext
    HotepGBank_LAM_PassphraseMessage:UpdateValue()
  end
  
  local valid = false
  x = tostring(x)
  local s = "entry blank"
  
  if (type(x) == "string") then
    valid = true
    
    local c = string.len(x)
    if ((c < 8) or (c > 36)) then
      valid = false
      s = "not 8-36 characters"
    elseif (not string.find(x, "%l")) then
      valid = false
      s = "no lower-case letters"
    elseif (not string.find(x, "%u")) then
      valid = false
      s = "no upper-case letters"
    elseif (not string.find(x, "%d")) then
      valid = false
      s = "no digits"
    elseif (not string.find(x, "[^%w%s]")) then
      valid = false
      s = "no symbols"
    elseif (string.find(x, "%s%s")) then
      valid = false
      s = "multiple consecutive spaces"
    end
  end
  
  
  if (valid) then return x end
  
  savedVariables.SV_OFFICER.data.passphrase = false
  
  if (HotepGBank_LAM_PassphraseMessage and (x ~= "")) then
    HotepGBank_LAM_PassphraseMessage.origtext = HotepGBank_LAM_PassphraseMessage.data.text
    HotepGBank_LAM_PassphraseMessage.data.text = "|cff0000Invalid Entry (".. s ..").|r\n\n" .. HotepGBank_LAM_PassphraseMessage.data.text
    HotepGBank_LAM_PassphraseMessage:UpdateValue()
  end
  
  return false
end
-- end HotepGBank.ValidatePP(x)


function HotepGBank.ValidatePIN(x)
  
  if (HotepGBank_LAM_PINMessage and HotepGBank_LAM_PINMessage.origtext) then
    HotepGBank_LAM_PINMessage.data.text = HotepGBank_LAM_PINMessage.origtext
    HotepGBank_LAM_PINMessage:UpdateValue()
  end
  
  if (not savedVariables.SV_OFFICER or (x == "")) then return false end
  
  if (savedVariables.SV_OFFICER.data.PIN == true) then
    return "uploaded"
  end
  
  local y = tonumber(x)
  if (y and (type(x) == "string") and (string.len(x) == 4)) then
    if ((0 <= y) and (y <= 9999)) then return x end
  end
  
  savedVariables.SV_OFFICER.data.PIN = false
  
  if (HotepGBank_LAM_PINMessage) then
    HotepGBank_LAM_PINMessage.origtext = HotepGBank_LAM_PINMessage.data.text
    HotepGBank_LAM_PINMessage.data.text = "|cff0000Invalid Entry. Must be 4 digits.|r\n\n" .. HotepGBank_LAM_PINMessage.data.text
    HotepGBank_LAM_PINMessage:UpdateValue()
  end
  
  return false
end
-- end HotepGBank.ValidatePIN(x)


function HotepGBank.BankOpened()
  if (HotepGBank.BANKISOPEN) then return end
  
  if (GetSelectedGuildBankId() == HotepGBank.guildid) then
    HotepGBank.ToggleScanningWindow(true)
    HotepGBank.BANKISOPEN = true
  end
  
  EVENT_MANAGER:RegisterForEvent(HotepGBank.name, EVENT_GUILD_BANK_ITEMS_READY, HotepGBank.BankReady)
end
-- end HotepGBank.BankOpened()


function HotepGBank.BankReady()
  
  EVENT_MANAGER:UnregisterForEvent(HotepGBank.name, EVENT_GUILD_BANK_ITEMS_READY)
  
  if (GetSelectedGuildBankId() == HotepGBank.guildid) then
    SHARED_INVENTORY:PerformFullUpdateOnBagCache(BAG_GUILDBANK)
    Timer:New(0.09, HotepGBank.ScanGBank)
  end
end
-- end HotepGBank.BankReady()


function HotepGBank.BankClosed()
  HotepGBank.ToggleScanningWindow(false)
  HotepGBank.BANKISOPEN = nil
end


function HotepGBank.ScanGBank()
  
  if (not HotepGBank.BANKISOPEN) then
    HotepGBank.ToggleScanningWindow(false)
    return
  end
  
  
  msgWithName("Scanning Your Guild Bank...", COLOR_PURPLE)
  
  local list = {}
  
  local bagCache = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_GUILDBANK)
  
  for slotId, data in pairs(bagCache) do
    local i = data.slotIndex
    
    if (HasItemInSlot(BAG_GUILDBANK, i)) then
      local d = {
        condition = data.condition,
        iconFile = data.iconFile,
        isPlaceableFurniture = data.isPlaceableFurniture,
        itemType = data.itemType,
        name = data.name,
        quality = data.quality,
        sellPrice = data.sellPrice,
        stackCount = data.stackCount,
        itemlink = GetItemLink(BAG_GUILDBANK, i, LINK_STYLE_DEFAULT),
      }
      
      table.insert(list, d)
    end
  end
  
  savedVariables.SV_OFFICER.data.GBankItems = list
  savedVariables.SV_OFFICER.data.lastscan = GetTimeStamp()
  
  msgWithName("Complete.  Remember to upload your SavedVariables file.", COLOR_PURPLE)
  HotepGBank.ToggleScanningWindow(false)
end
-- end HotepGBank.ScanGBank()





function HotepGBank.GetAllGuilds()
  local n = GetNumGuilds()
  
  local guildchoices = {}
  
  for i = 1,n do
    local gid = GetGuildId(i)
    local name = GetGuildName(gid)
    table.insert(guildchoices, name)
  end
  
  return guildchoices
end


function HotepGBank.UserSetup()
  HotepGBank.officer = false
  savedVariables.vars.SV_OFFICER.data = defaultVariables.SV_OFFICER.data
  savedVariables.SV_OFFICER = nil
  savedVariables.SV_COMMON.data.guildname = false
  msgWithName("Loaded in Non-Officer Mode.", COLOR_GREEN);
  
  HotepGBank.PlebSetup()
  
end
-- end HotepGBank.UserSetup()


function HotepGBank.PlebSetup()
  local guilds = HotepGBank.GetAllGuilds()
  
  local n = #guilds
  
  if n > 0 then
    for i,name in ipairs(guilds) do
      if (not array_key_exists(name, savedVariables.SV_PLEB.data.GBankItems)) then
        savedVariables.SV_PLEB.data.GBankItems[name] = {}
        savedVariables.SV_PLEB.data.asof[name] = 0
      end
      if (not array_key_exists(name, savedVariables.SV_PLEB.data.activated)) then
        savedVariables.SV_PLEB.data.activated[name] = false
      end
    end
    
    
    for i,name in ipairs(HotepGBank.plebguilds) do
      if (array_key_exists(name, savedVariables.SV_PLEB.data.activated)) then
        savedVariables.SV_PLEB.data.activated[name] = HotepGBank.plebphrases[i]
      end
    end
    
    
    local keys = array_keys(savedVariables.SV_PLEB.data.GBankItems)
    
    for _,name in pairs(keys) do
      if (not in_array(name, guilds)) then
        savedVariables.SV_PLEB.data.GBankItems[name] = nil
      elseif (HotepGBank.GetGuildID(name) 
            and DoesPlayerHaveGuildPermission(HotepGBank.GetGuildID(name), GUILD_PERMISSION_BANK_WITHDRAW)) then
        savedVariables.SV_PLEB.data.GBankItems[name] = nil
      elseif (not in_array(name, HotepGBank.plebguilds)) then
        savedVariables.SV_PLEB.data.GBankItems[name] = {}
      end
    end
    
    keys = array_keys(savedVariables.SV_PLEB.data.activated)
    
    for _,name in pairs(keys) do
      if (not in_array(name, guilds)) then
        savedVariables.SV_PLEB.data.activated[name] = nil
      elseif (HotepGBank.GetGuildID(name)
            and DoesPlayerHaveGuildPermission(HotepGBank.GetGuildID(name), GUILD_PERMISSION_BANK_WITHDRAW)) then
        savedVariables.SV_PLEB.data.activated[name] = nil
      elseif (not in_array(name, HotepGBank.plebguilds)) then
        savedVariables.SV_PLEB.data.activated[name] = false
      end
    end
    
    keys = array_keys(savedVariables.SV_PLEB.data.asof)
    
    for _,name in pairs(keys) do
      if (not in_array(name, guilds)) then
        savedVariables.SV_PLEB.data.asof[name] = nil
      elseif (HotepGBank.GetGuildID(name)
            and DoesPlayerHaveGuildPermission(HotepGBank.GetGuildID(name), GUILD_PERMISSION_BANK_WITHDRAW)) then
        savedVariables.SV_PLEB.data.asof[name] = nil
      elseif (not in_array(name, HotepGBank.plebguilds)) then
        savedVariables.SV_PLEB.data.asof[name] = 0
      end
    end
    
    savedVariables.SV_PLEB.data.guildlist = guilds
    
    if (savedVariables.SV_OFFICER) then
      local gname = savedVariables.SV_OFFICER.data.guildname
      
      if (array_key_exists(gname, savedVariables.SV_PLEB.data.GBankItems)) then
        savedVariables.SV_PLEB.data.GBankItems[gname] = nil
      end
      
      if (array_key_exists(gname, savedVariables.SV_PLEB.data.activated)) then
        savedVariables.SV_PLEB.data.activated[gname] = nil
      end
      
      if (array_key_exists(gname, savedVariables.SV_PLEB.data.asof)) then
        savedVariables.SV_PLEB.data.asof[gname] = nil
      end
    end
    
  else      -- player don't have no Guilds right now!
    savedVariables.SV_PLEB.data.guildlist = {}
    savedVariables.SV_PLEB.data.GBankItems = {}
    savedVariables.SV_PLEB.data.asof = {}
    savedVariables.SV_PLEB.data.activated = {}
  end
end
-- end HotepGBank.PlebSetup()






local itemTypes = {
  [ITEMTYPE_ADDITIVE] = 'additive',
  [ITEMTYPE_ARMOR] = 'armor',
  [ITEMTYPE_ARMOR_BOOSTER] = 'armor booster',
  [ITEMTYPE_ARMOR_TRAIT] = 'armor trait',
  [ITEMTYPE_AVA_REPAIR] = 'AVA repair',
  [ITEMTYPE_BLACKSMITHING_BOOSTER] = 'Blacksmitting booster',
  [ITEMTYPE_BLACKSMITHING_MATERIAL] = 'Blacksmitting mat',
  [ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = 'Blacksmitting raw mat',
  [ITEMTYPE_CLOTHIER_BOOSTER] = 'Clothier booster',
  [ITEMTYPE_CLOTHIER_MATERIAL] = 'Clothier mat',
  [ITEMTYPE_CLOTHIER_RAW_MATERIAL] = 'Clothier raw mat',
  [ITEMTYPE_COLLECTIBLE] = 'Collectible',
  [ITEMTYPE_CONTAINER] = 'Container',
  [ITEMTYPE_COSTUME] = 'Costume',
  [ITEMTYPE_CROWN_ITEM] = 'CROWN item',
  [ITEMTYPE_CROWN_REPAIR] = 'CROWN repair',
  [ITEMTYPE_DEPRECATED] = '--',
  [ITEMTYPE_DISGUISE] = 'Disguise',
  [ITEMTYPE_DRINK] = 'Drink',
  [ITEMTYPE_DYE_STAMP] = 'Dye Stamp',
  [ITEMTYPE_ENCHANTING_RUNE_ASPECT] = 'aspect rune',
  [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = 'essence rune',
  [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = 'potency rune',
  [ITEMTYPE_ENCHANTMENT_BOOSTER] = 'enchantment booster',
  [ITEMTYPE_FISH] = 'Fish',
  [ITEMTYPE_FLAVORING] = 'flavoring',
  [ITEMTYPE_FOOD] = 'Food',
  [ITEMTYPE_FURNISHING] = 'Furnishing',
  [ITEMTYPE_FURNISHING_MATERIAL] = 'Furnishing mat',
  [ITEMTYPE_GLYPH_ARMOR] = 'armor glyph',
  [ITEMTYPE_GLYPH_JEWELRY] = 'jewelry glyph',
  [ITEMTYPE_GLYPH_WEAPON] = 'weapon glyph',
  [ITEMTYPE_INGREDIENT] = 'ingredient',
  [ITEMTYPE_LOCKPICK] = 'lockpick',
  [ITEMTYPE_LURE] = 'fishing bait',
  [ITEMTYPE_MASTER_WRIT] = 'Master Writ',
  [ITEMTYPE_MOUNT] = 'Mount',
  [ITEMTYPE_NONE] = '--',
  [ITEMTYPE_PLUG] = 'plug',
  [ITEMTYPE_POISON] = 'Poison',
  [ITEMTYPE_POISON_BASE] = 'poison solvent',
  [ITEMTYPE_POTION] = 'Potion',
  [ITEMTYPE_POTION_BASE] = 'potion solvent',
  [ITEMTYPE_RACIAL_STYLE_MOTIF] = 'Motif',
  [ITEMTYPE_RAW_MATERIAL] = 'raw mat',
  [ITEMTYPE_REAGENT] = 'reagent',
  [ITEMTYPE_RECIPE] = 'recipe',
  [ITEMTYPE_SIEGE] = 'Siege',
  [ITEMTYPE_SOUL_GEM] = 'Soul Gem',
  [ITEMTYPE_SPELLCRAFTING_TABLET] = 'Spell Tablet',
  [ITEMTYPE_SPICE] = 'spice',
  [ITEMTYPE_STYLE_MATERIAL] = 'style mat',
  [ITEMTYPE_TABARD] = 'Guild Tabard',
  [ITEMTYPE_TOOL] = 'tool',
  [ITEMTYPE_TRASH] = 'trash',
  [ITEMTYPE_TREASURE] = 'treasure',
  [ITEMTYPE_TROPHY] = 'trophy',
  [ITEMTYPE_WEAPON] = 'weapon',
  [ITEMTYPE_WEAPON_BOOSTER] = 'weapon booster',
  [ITEMTYPE_WEAPON_TRAIT] = 'weapon trait',
  [ITEMTYPE_WOODWORKING_BOOSTER] = 'Woodworking booster',
  [ITEMTYPE_WOODWORKING_MATERIAL] = 'Woodworking mat',
  [ITEMTYPE_WOODWORKING_RAW_MATERIAL] = 'Woodworking raw mat',
}


local itemQuals = {
  [ITEM_QUALITY_TRASH] = zo_strformat('<<1>>trash|r', COLOR_GRAY),
  [ITEM_QUALITY_NORMAL] = zo_strformat('<<1>>Normal|r', COLOR_WHITE),
  [ITEM_QUALITY_MAGIC] = zo_strformat('<<1>>Fine|r', COLOR_GREEN),
  [ITEM_QUALITY_ARCANE] = zo_strformat('<<1>>Superior|r', COLOR_BLUE),
  [ITEM_QUALITY_ARTIFACT] = zo_strformat('<<1>>Epic|r', COLOR_PURPLE),
  [ITEM_QUALITY_LEGENDARY] = zo_strformat('<<1>>Legendary|r', COLOR_YELLOW),
}




local UI_ItemsList = ZO_SortFilterList:Subclass()

UI_ItemsList.defaults = {}

UI_ItemsList.SORT_KEYS = {
  ["itemTypeName"] = {tiebreaker = "name", caseInsensitive = true, tieBreakerSortOrder = ZO_SORT_ORDER_UP},
  ["stackCount"] = {tiebreaker = "name", isNumeric = true, tieBreakerSortOrder = ZO_SORT_ORDER_UP},
  ["name"] = {tiebreaker = "qualityNum", caseInsensitive = true, tieBreakerSortOrder = ZO_SORT_ORDER_UP},
  ["itemlink"] = {},
  ["quality"] = {tiebreaker = "name", isNumeric = true, tieBreakerSortOrder = ZO_SORT_ORDER_UP},
  ["qualityNum"] = {isNumeric = true},
  ["condition"] = {tiebreaker = "name", isNumeric = true, tieBreakerSortOrder = ZO_SORT_ORDER_UP},
  ["isPlaceableFurniture"] = {tiebreaker = "name", caseInsensitive = true, tieBreakerSortOrder = ZO_SORT_ORDER_UP},
  ["sellPrice"] = {tiebreaker = "name", isNumeric = true, tieBreakerSortOrder = ZO_SORT_ORDER_UP},
}

function UI_ItemsList:New(control)
  ZO_SortFilterList.InitializeSortFilterList(self, control)
  
  self.masterList = {}
  
  self.ACTIVEGUILD = nil
  
  local template = "HotepGBank_UI_show_ListRow"
  local height = 32
  
  local setupItem = function(control, data)
    self:SetupItemRow(control, data)
  end
  
  ZO_ScrollList_AddDataType(self.list, 1, template, height, setupItem)
  
  ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
  
  self.currentSortKey = "itemTypeName"
  self.currentSortOrder = ZO_SORT_ORDER_UP
  
  self.sortFunction = function(listEntry1, listEntry2)
      return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, self.SORT_KEYS, self.currentSortOrder)
    end
  
--  self:SetAlternateRowBackgrounds(true)
  
  return self
end
-- end UI_CostsList:New(control)


---
-- @param rowControl @class userdata
-- @param data @class table
-- @return @class nil
function UI_ItemsList:SetupItemRow(rowControl, data)
  
  rowControl.data = data
  rowControl.itemType = GetControl(rowControl, "itemType")
  rowControl.stackCount = GetControl(rowControl, "stackCount")
  rowControl.itemlink = GetControl(rowControl, "itemlink")
  rowControl.quality = GetControl(rowControl, "quality")
  rowControl.condition = GetControl(rowControl, "condition")
  rowControl.isPlaceableFurniture = GetControl(rowControl, "isPlaceableFurniture")
  rowControl.sellPrice = GetControl(rowControl, "sellPrice")
  
  rowControl.itemlink.data = data
  
  local furn = (data.isPlaceableFurniture and "YES") or "NO"
  local price = zo_strformat("<<1>> |t16:16:/esoui/art/currency/currency_gold_32.dds|t", data.sellPrice)
  local name = zo_strformat("|t32:32:<<1>>|t <<2>>", data.iconFile, data.itemlink)
  
  rowControl.itemType:SetText(data.itemTypeName)
  rowControl.stackCount:SetText(data.stackCount)
  rowControl.itemlink:SetText(name)
  rowControl.quality:SetText(data.qualityName)
  rowControl.condition:SetText(data.condition)
  rowControl.isPlaceableFurniture:SetText(furn)
  rowControl.sellPrice:SetText(price)
  
  ZO_SortFilterList.SetupRow(self, rowControl, data)
end
-- end UI_CostsList:SetupItemRow(rowControl, data)


function UI_ItemsList:BuildMasterList()
  self.masterList = HotepGBank.GetBankList(self.ACTIVEGUILD)
end


function UI_ItemsList:FilterScrollList()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  ZO_ClearNumericallyIndexedTable(scrollData)
  
  for i = 1, #self.masterList do
    local data = self.masterList[i]
    table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
  end
end


function UI_ItemsList:SortScrollList()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  table.sort(scrollData, self.sortFunction)
end






function HotepGBank.GetBankList(gname)
  if (not gname) then return {} end
  
  local dataItems = {}
  
  local items = savedVariables.SV_PLEB.data.GBankItems[gname]
  
  for _,item in ipairs(items) do
    local data = clone(item)
    data.itemTypeName = itemTypes[data.itemType]
    data.qualityName = itemQuals[data.quality]
    data.qualityNum = data.quality
    table.insert(dataItems, data)
  end
  
  
  return dataItems
end




local function NotYetSetUp(n)
  if (n) then
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>Addon Not Yet Set Up|r", COLOR_RED))
  end
end

local function GuildViewChosen(n)
  
  if (not n) then return end
  
  HotepGBank.UI_ItemsList.ACTIVEGUILD = n
  
  local count = #savedVariables.SV_PLEB.data.GBankItems[n]
  local ts = savedVariables.SV_PLEB.data.asof[n]
  
  local td, tt
  if (ts == 0) then
    td, tt = "Never", ""
  else
    td, tt = FormatAchievementLinkTimestamp(ts)
  end
  
  local t = "|t32:32:/esoui/art/buttons/dropbox_arrow_disabled.dds|t"
  local h = zo_strformat("<<1>> <<2>>Guild: <<3>>. <<4>> items as of <<5>> <<6>>|r", t, COLOR_YELLOW, n, count, td, tt)
  
  HotepGBank_UI_show_Heading:SetText(h)
  HotepGBank.ShowUIDropdown(false)
  
  HotepGBank.UI_ItemsList:RefreshData()
  HotepGBank.UI_ItemsList:RefreshVisible()
end
-- end function GuildViewChosen(n)


function HotepGBank.CreateUIDropdown()
  
  HotepGBank_UI_show.data = {}
  
  local widgit = {
    type = "dropdown",
    name = "Choose Guild: ",
    choices = {"No Guild"},
--    getFunc = function () return ((type(HotepGBank.UI_ItemsList) ~= "nil") and HotepGBank.UI_ItemsList.ACTIVEGUILD) or "No Guild" end,
    getFunc = function () return HotepGBank.UI_ItemsList.ACTIVEGUILD end,
    setFunc = function (n) if ((type(HotepGBank.UI_ItemsList) ~= "nil")) then GuildViewChosen(n) else NotYetSetUp(n) end end,
    reference = "HotepGBank_GuildChooser",
  }
  
  LAMCreateControl.dropdown(HotepGBank_UI_show, widgit)
  
  HotepGBank_GuildChooser:SetAnchor(TOPLEFT, HotepGBank_UI_show_Heading, TOPLEFT, 0, 0)
  HotepGBank_GuildChooser:SetWidth(600)
  HotepGBank_GuildChooser:SetHidden(true)
end
-- end HotepGBank.CreateUIDropdown()


function HotepGBank.ShowUIDropdown(show)
  if (HotepGBank_GuildChooser) then
    if (show) then
      if (not HotepGBank.FillUIDropdown()) then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, zo_strformat("<<1>>No Items Stored for any Guild|r", COLOR_RED))
        return
      end
    end
    HotepGBank_UI_show_Heading:SetHidden(show)
    HotepGBank_GuildChooser:SetHidden(not show)
  else
    NotYetSetUp()
  end
end


function HotepGBank.FillUIDropdown()
  local t = {}
  
  for gname,pass in pairs(savedVariables.SV_PLEB.data.activated) do
    if (pass) then
      table.insert(t, gname)
    end
  end
  
  if (#t == 0) then
    HotepGBank_UI_show_Heading:SetText("You haven't downloaded any Guild Bank Items")
    return false
  end
  
  HotepGBank_GuildChooser:UpdateChoices(t)
  
  if (HotepGBank.UI_ItemsList and HotepGBank.UI_ItemsList.ACTIVEGUILD) then
--    d(HotepGBank.UI_ItemsList.ACTIVEGUILD)
    HotepGBank_GuildChooser:UpdateValue()
--    HotepGBank_GuildChooser.dropdown:SetSelectedItem(HotepGBank.UI_ItemsList.ACTIVEGUILD)
  end
  
  return true
end
-- end HotepGBank.FillUIDropdown()





function HotepGBank.ToggleScanningWindow(show)
  HotepGBank_UI_scan:SetHidden(not show)
end


function HotepGBank.ToggleUIShowItems(show)
  if (type(show) == "nil") then
    SCENE_MANAGER:ToggleTopLevel(HotepGBank_UI_show)
  elseif (show) then
    SCENE_MANAGER:ShowTopLevel(HotepGBank_UI_show)
  else
    SCENE_MANAGER:HideTopLevel(HotepGBank_UI_show)
  end
  
  if (HotepGBank.UI_ItemsList and not HotepGBank_UI_show:IsHidden()) then
    HotepGBank.UI_ItemsList:RefreshData()
    HotepGBank.UI_ItemsList:RefreshVisible()
  end
end


function HotepGBank.InitUIWindows()
  local title = "|c3366ffHotep\194\174|r |cff6633Guild Bank Viewer|r"
  
  HotepGBank_UI_scan_WindowTitle:SetText(title)
--  HotepGBank_UI_scan:SetAlpha(0.6)
  
  SCENE_MANAGER:RegisterTopLevel(HotepGBank_UI_show, false)
  HotepGBank_UI_show:SetDrawTier(2)
  HotepGBank_UI_show_WindowTitle:SetText(title)
  
  HotepGBank.UI_ItemsList = UI_ItemsList:New(HotepGBank_UI_show);
  HotepGBank.UI_ItemsList:SetEmptyText(zo_strformat("<<1>>No Items|r", COLOR_RED))
  
  HotepGBank.CreateUIDropdown()
end











-- ****************************************************************************
--                              event handling
-- ****************************************************************************



function HotepGBank.Initialize()
  
  EVENT_MANAGER:UnregisterForEvent(HotepGBank.name, EVENT_PLAYER_ACTIVATED)
  
  
  HotepToolsLib:Init()
  
  savedVariables:Load(SV_COMMON)
  savedVariables:Load(SV_PLEB)
  savedVariables:Load(SV_OFFICER)
  savedVariables.SV_COMMON.data.realm = GetWorldName()
  
  if (savedVariables.SV_PLEB.data.activated) then
    local i = 1
    for gname,pass in pairs(savedVariables.SV_PLEB.data.activated) do
      if (pass) then
        HotepGBank.plebguilds[i] = gname
        HotepGBank.plebphrases[i] = pass
        i = i + 1
      end
    end
    if (i < 6) then
      for j = i,5 do
        HotepGBank.plebguilds[j] = "No Guild"
        HotepGBank.plebphrases[j] = false
      end
    end
  end
  
  HotepGBank:CreateAddonMenu()
  HotepGBank.InitUIWindows()
  HotepGBank.Setup()
  
  EVENT_MANAGER:RegisterForEvent(HotepGBank.name, EVENT_GUILD_SELF_JOINED_GUILD, HotepGBank.Setup)
  EVENT_MANAGER:RegisterForEvent(HotepGBank.name, EVENT_GUILD_SELF_LEFT_GUILD, HotepGBank.Setup)
end





function HotepGBank.OnAddOnLoaded(event, addonName)
  if addonName == HotepGBank.name then
    math.randomseed(GetTimeStamp())
    
    EVENT_MANAGER:UnregisterForEvent(HotepGBank.name, EVENT_ADD_ON_LOADED)
    
    ZO_CreateStringId("SI_BINDING_NAME_HOTEPGBANK", "Show GBank Items")
    
    EVENT_MANAGER:RegisterForEvent(HotepGBank.name, EVENT_PLAYER_ACTIVATED, HotepGBank.Initialize)
  end
end


EVENT_MANAGER:RegisterForEvent(HotepGBank.name, EVENT_ADD_ON_LOADED, HotepGBank.OnAddOnLoaded)
