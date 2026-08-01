
local L = GuildBankTwiddlerLanguage.language

local DEFAULT_TWIDDLE_TIMEOUT = 2000

local GUILD_SORT_INDEX_ASCEND = 1
local GUILD_SORT_ALPHA_ASCEND = 2

local hideControls = {}

GuildBankTwiddler = {}
GuildBankTwiddler.name = "GuildBankTwiddler"

GuildBankTwiddler.editAutoChangeTimeoutControl = nil
GuildBankTwiddler.twiddleButtonControl = nil
GuildBankTwiddler.guildComboBox = nil
GuildBankTwiddler.guildDropdown = nil
GuildBankTwiddler.uiTopLevel = nil
GuildBankTwiddler.fragmentAutoChange = nil
GuildBankTwiddler.selfTriggered = false

GuildBankTwiddler.traceEnabled = false

local function trace(msg)
  if GuildBankTwiddler.traceEnabled then
    GuildBankTwiddlerUtils:Trace(msg)
  end
end

---------------------------------------------------------------------
-- GUI Events
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Function: OnGuildBankTwiddlerUIInitialized
--
-- Called when the toplevel UI control is initialised
---------------------------------------------------------------------
function GuildBankTwiddler:OnGuildBankTwiddlerUIInitialized(control)
  self.uiTopLevel = control
end

---------------------------------------------------------------------
-- Function: OnGuildBankTwiddlerUIMoveStop
--
-- Called when the toplevel UI control is moved
---------------------------------------------------------------------
function GuildBankTwiddler:OnGuildBankTwiddlerUIMoveStop(control)
  local savedVars = self:GetSavedVars()
  savedVars.position = { left = control:GetLeft(), top = control:GetTop()}
  trace("left["..savedVars.position.left.."], top["..savedVars.position.top.."]")
end


---------------------------------------------------------------------
-- Function: OnTwiddleButtonInitialized
--
-- Called when the twiddle button is initialised
---------------------------------------------------------------------
function GuildBankTwiddler:OnTwiddleButtonInitialized(control)
  self.twiddleButtonControl = control
  GuildBankTwiddlerUtils:SetupTooltip(control, L[GBQC_BUTTON_TWIDDLE_TOOLTIP])

end

---------------------------------------------------------------------
-- Function: OnTwiddleButtonClicked
--
-- Called when the twiddle button is clicked
---------------------------------------------------------------------
function GuildBankTwiddler:OnTwiddleButtonClicked(control, mouseButton)
  self:BeginTwiddle()
end

--------------------------------------------------------------------
-- Function: OnGuildBankTwiddlerUIHide
--
-- Called when the top level UI is hidden
---------------------------------------------------------------------
function GuildBankTwiddler:OnGuildBankTwiddlerUIHide(control, hidden) 
end

---------------------------------------------------------------------
-- Function: OnGuildBankTwiddlerUIShow
--
-- Called when the top level UI is shown
---------------------------------------------------------------------
function GuildBankTwiddler:OnGuildBankTwiddlerUIShow(control, hidden) 

end



---------------------------------------------------------------------
-- Function: OnGuildComboInitialized
--
-- Called when the guid combo is initialised
---------------------------------------------------------------------
function GuildBankTwiddler:OnGuildComboInitialized(control)
  self.guildComboBox = control
  self.guildDropdown = ZO_ComboBox:New(control)
end


---------------------------------------------------------------------
-- Regsitered for ESO Events
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Function: OnGuildSelfJoined
--
-- ESO event called when self joins guild
---------------------------------------------------------------------
function GuildBankTwiddler:OnGuildSelfJoined(eventCode, guildId, guildName)
  self:EnableTwiddle()
end

---------------------------------------------------------------------
-- Function: OnGuildSelfLeft
--
-- ESO event called when self leaves guild
---------------------------------------------------------------------
function GuildBankTwiddler:OnGuildSelfLeft(eventCode, guildId, guildName)
  self:EnableTwiddle()
end

---------------------------------------------------------------------
-- General routines
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Function: EnableTwiddle
--
-- Called to enable or disable the twiddle button
---------------------------------------------------------------------
function GuildBankTwiddler:EnableTwiddle()
  local numGuilds = GetNumGuilds()
  local enable = false
  if numGuilds >= 2 then
    -- enable button
    enable = true
  end   
  self.twiddleButtonControl:SetEnabled(enable)
end


---------------------------------------------------------------------
-- Function: BeginTwiddle
--
-- This function starts the twiddling process
---------------------------------------------------------------------
function GuildBankTwiddler:BeginTwiddle() 
  -- change the guild bank then wait for timeout before
  -- changing back
  local restoreGuildId = self.currentGuildBankId
  for i = 1, GetNumGuilds() do
    local guildId = GetGuildId(i) 
    if guildId ~= restoreGuildId then
      self.twiddleButtonControl:SetEnabled(false)
      self:SelectGuildInDropDown(guildId)
      
      local function callLater()
        self:SelectGuildInDropDown(restoreGuildId)
        self.twiddleButtonControl:SetEnabled(true)
      end
      
      zo_callLater(callLater, self:GetTwiddleTimeout())  
      break
    end
  end
end

---------------------------------------------------------------------
-- Function: SelectGuildInDropDown
--
-- This function selects the specified guild in the dropdown
-- this can also trigger a change in guild bank
---------------------------------------------------------------------
function GuildBankTwiddler:SelectGuildInDropDown(guildId)
  
  local items = self.guildDropdown:GetItems()
  for key, entry in pairs(items) do
    if entry.guildId == guildId then
      self.guildDropdown:SelectItem(entry) 
      return
    end
  end
end

---------------------------------------------------------------------
-- Function: AddFragment
--
-- Add the control to the guild bank scene
---------------------------------------------------------------------
function GuildBankTwiddler:AddFragment()
  if not self.fragmentAutoChange then
    self.fragmentAutoChange = ZO_FadeSceneFragment:New(self.uiTopLevel)
    local guildBankScene = SCENE_MANAGER:GetScene("guildBank")
    if guildBankScene then
      trace("Got guild bank scene")
      guildBankScene:AddFragment(self.fragmentAutoChange)
    end
  end    
end

---------------------------------------------------------------------
-- Function: RemoveFragment
--
-- Removes the control from the guild bank scene
---------------------------------------------------------------------
function GuildBankTwiddler:RemoveFragment()
  if self.fragmentAutoChange then
    local guildBankScene = SCENE_MANAGER:GetScene("guildBank")
    if guildBankScene then
      trace("Got guild bank scene")
      guildBankScene:RemoveFragment(self.fragmentAutoChange)
      self.fragmentAutoChange = nil
    end
  end    
end

---------------------------------------------------------------------
-- Function: PopulateGuildDropDown
--
-- Poulates the guild entries in the dropdown
---------------------------------------------------------------------
function GuildBankTwiddler:PopulateGuildDropDown()
  local sortOrder = self:GetGuildSortOrder()

  if not self.guildDropdown then
    trace("No guild Dropdown")
    return
  end
  
  self.guildDropdown:ClearItems()

  local guildCount = GetNumGuilds()
  self.guildCount = guildCount
  
  if sortOrder == GUILD_SORT_INDEX_ASCEND then
    self.guildDropdown:SetSortsItems(false)
  else
    self.guildDropdown:SetSortsItems(true)
  end
  
  for i = 1, guildCount do
    self:AddGuildListItem(GetGuildName(i), i)
  end
  
  local guildId = GetSelectedGuildBankId()
  if guildId ~= nil then
    self:SelectGuildInDropDown(guildId)
  end
end


function GuildBankTwiddler:OnGuildItemSelect(comboBox, name, item, selectionChanged)
  trace("OnGuildItemSelect["..name.."]")
  local guildId = GetSelectedGuildBankId()
  
  --local item = self.guildDropdown:GetSelectedItem()
  if item.guildId == guildId then
    return
  end

  SelectGuildBank(item.guildId) 
  
end

local function OnGuildItemSelect(...)
  GuildBankTwiddler:OnGuildItemSelect(...)
end

function GuildBankTwiddler:AddGuildListItem(name, guildId)
  
  local entry = self.guildDropdown:CreateItemEntry(name, function(...)
      self:OnGuildItemSelect(...)
    end)
  entry.guildId = guildId
  --trace(entry)
  self.guildDropdown:AddItem(entry)

end

---------------------------------------------------------------------
-- Function: GetSavedVars
--
-- This function returns the saved vars
---------------------------------------------------------------------
function GuildBankTwiddler:GetSavedVars()
  return self.savedVariables
end


---------------------------------------------------------------------
-- Function: GetTwiddleTimeout
--
-- This function returns the twiddle change timeout
---------------------------------------------------------------------
function GuildBankTwiddler:GetTwiddleTimeout()
  local savedVars = self:GetSavedVars()
  return savedVars.twiddleTimeout
end


---------------------------------------------------------------------
-- Function: SetTwiddleTimeout
--
-- This function sets the twiddle change timeout
---------------------------------------------------------------------
function GuildBankTwiddler:SetTwiddleTimeout(timeout)
  local savedVars = self:GetSavedVars()
  savedVars.twiddleTimeout = timeout 
end

---------------------------------------------------------------------
-- Function: GetGuildSortOrder
--
-- This function returns the guild sort order
---------------------------------------------------------------------
function GuildBankTwiddler:GetGuildSortOrder()
  local savedVars = self:GetSavedVars()
  local sortOrder = savedVars.guildSortOrder
  if sortOrder == GUILD_SORT_INDEX_ASCEND or sortOrder == GUILD_SORT_ALPHA_ASCEND then
    return sortOrder
  end  
  return GUILD_SORT_ALPHA_ASCEND
end


---------------------------------------------------------------------
-- Function: SetGuildSortOrder
--
-- This function sets the guild sort order
---------------------------------------------------------------------
function GuildBankTwiddler:SetGuildSortOrder(sortOrder)
  local savedVars = self:GetSavedVars()
  if sortOrder == GUILD_SORT_INDEX_ASCEND or sortOrder == GUILD_SORT_ALPHA_ASCEND then
    savedVars.guildSortOrder = sortOrder 
  end
end

---------------------------------------------------------------------
-- Function: OnGuildBankSelected
--
-- Called when a guild is selected and changed to.
-- If we dont have permissions we dont bother
---------------------------------------------------------------------
function GuildBankTwiddler:OnGuildBankSelected(eventCode, guildId)
  trace("OnGuildBankSelected["..guildId.."]")

  self.currentGuildBankId = guildId
  self:SelectGuildInDropDown(guildId)
end

---------------------------------------------------------------------
-- Function: EnableAutoHide
--
-- Called to enabled auto hide ability
---------------------------------------------------------------------
function GuildBankTwiddler:EnableAutoHide(enable)
  local savedVars = self:GetSavedVars()
  savedVars.autohideEnabled = enable
  self.autoHide:EnableAutoHide(enable)
end

---------------------------------------------------------------------
-- Function: IsAutoHideEnabled
--
-- Called to get state of auto hide
---------------------------------------------------------------------
function GuildBankTwiddler:IsAutoHideEnabled()
  local savedVars = self:GetSavedVars()
  return savedVars.autohideEnabled
end

---------------------------------------------------------------------
-- Function: DisplayUsage
--
-- Called to display slash commands
---------------------------------------------------------------------
function GuildBankTwiddler:DisplayUsage()
  d(" ")
  d("Usage:")
  d(string.format("/%s %s", L[GBT_CHAT_OPTION_KEY], L[GBT_CHAT_OPTION_SORT_INDEX]))
  d(L[GBT_CHAT_OPTION_SORT_INDEX_DESCRIPTION])
  d(string.format("/%s %s", L[GBT_CHAT_OPTION_KEY], L[GBT_CHAT_OPTION_SORT_ALPHA]))
  d(L[GBT_CHAT_OPTION_SORT_ALPHA_DESCRIPTION])
  d(string.format("/%s %s", L[GBT_CHAT_OPTION_KEY], L[GBT_CHAT_OPTION_HIDE_OFF]))
  d(L[GBT_CHAT_OPTION_HIDE_OFF_DESCRIPTION])
  d(string.format("/%s %s", L[GBT_CHAT_OPTION_KEY], L[GBT_CHAT_OPTION_HIDE_ON]))
  d(L[GBT_CHAT_OPTION_HIDE_ON_DESCRIPTION])  
end

---------------------------------------------------------------------
-- Function: RegisterSlashCommands
--
-- Called to setup the slash commands the it will respond to
---------------------------------------------------------------------
function GuildBankTwiddler:RegisterSlashCommands()
  -- chat command handlers
  local function command_handler(arguments)
      local arg
      local args
      
      arguments = string.lower(arguments)
      local pos = string.find(arguments, " ", 1, true)
      if pos == 0 then
        arg = arguments
      else
        args = split(arguments.." ", " ")
        if #args > 0 then
          arg = args[1]
        end
      end

      local handled = false
      
      if arg == "" or arg == nil or #arg == 0 then
        -- Display options
        self:DisplayUsage()
        handled = true
      elseif arg==L[GBT_CHAT_OPTION_HIDE_OFF] then
        self:EnableAutoHide(false)
        handled = true
      elseif arg==L[GBT_CHAT_OPTION_HIDE_ON] then
        self:EnableAutoHide(true)
        handled = true
      elseif arg==L[GBT_CHAT_OPTION_SORT_INDEX] then
        self:SetGuildSortOrder(GUILD_SORT_INDEX_ASCEND)
        self:PopulateGuildDropDown()
        handled = true
      elseif arg==L[GBT_CHAT_OPTION_SORT_ALPHA] then
        self:SetGuildSortOrder(GUILD_SORT_ALPHA_ASCEND)
        self:PopulateGuildDropDown()
        handled = true         
      else
        handled = false
      end
      
      if handled == false then
        d(L[GBT_CHAT_OPTION_INVALID])
      end
  end
          
  SLASH_COMMANDS["/gbt"]           = command_handler
  SLASH_COMMANDS["/guildbanktwiddler"]   = command_handler
end


---------------------------------------------------------------------
-- Function: Initialize
--
-- Called to initialise the addon
---------------------------------------------------------------------
function GuildBankTwiddler:Initialize()

	local defaultSave =
	{
    autoChangeTimeout = 4,
    twiddleTimeout = DEFAULT_TWIDDLE_TIMEOUT,
    autohideEnabled = true,
    guildSortOrder = GUILD_SORT_ALPHABETICAL_ASCEND
	}
  -- set for first time or retrieve existing
  self.savedVariables = ZO_SavedVars:New("GuildBankTwiddlerSavedVariables", 1, nil, defaultSave)  
 
   -- Register slash commands
  self:RegisterSlashCommands()
  
  self:AddFragment()
   
  local vars = self.savedVariables
  if vars.position then
    self.uiTopLevel:ClearAnchors()
    self.uiTopLevel:SetAnchor(TOPLEFT, nil, TOPLEFT, vars.position.left, vars.position.top) 
  end
  
  self:PopulateGuildDropDown()
    
  self:EnableTwiddle()
  
  
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_BANK_SELECTED, function(...)
    self:OnGuildBankSelected(...)
  end)

  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_SELF_JOINED_GUILD, function(...)
    self:OnGuildSelfJoined(...)
  end)

  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_SELF_LEFT_GUILD, function(...)
    self:OnGuildSelfLeft(...)
  end)

  self.autoHide = GuildBankTwiddlerAutoHide:New()
  self.autoHide:SetParent(self.uiTopLevel)
  self.autoHide:SetOverControl(self.guildComboBox )
  self.autoHide:AddAutoHideControl(self.twiddleButtonControl)
  
  if self:IsAutoHideEnabled() then
    self.autoHide:EnableAutoHide(true)
  else
    self.autoHide:EnableAutoHide(false)
  end  
end

function GuildBankTwiddler:OnAddOnLoaded(event, addonName)
  if addonName == self.name then
    self:Initialize()
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
  end
end


EVENT_MANAGER:RegisterForEvent(GuildBankTwiddler.name, EVENT_ADD_ON_LOADED, function(...)
    GuildBankTwiddler:OnAddOnLoaded(...)
    end)