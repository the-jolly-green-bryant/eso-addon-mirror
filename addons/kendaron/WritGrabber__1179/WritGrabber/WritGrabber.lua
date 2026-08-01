
local L = WritGrabberLanguage.language

local ASPECT_RUNE = GetString(SI_ENCHANTINGRUNECLASSIFICATION1):lower()
local ESSENCE_RUNE = GetString(SI_ENCHANTINGRUNECLASSIFICATION2):lower()
local POTENCY_RUNE = GetString(SI_ENCHANTINGRUNECLASSIFICATION3):lower()

local WRIT_ITEM_NONE = 0
local WRIT_ITEM_ALCHEMY = 1
local WRIT_ITEM_ENCHANTING = 2

WritGrabber = EasyFrame:new()
WritGrabber.name = L[WGL_WRITGRABBER_NAME]
WritGrabber.savedVariables = nil
WritGrabber.questTypeAlchemy = nil
WritGrabber.questTypeEnchanting = nil
WritGrabber.writItems = {}
WritGrabber.firstReset = true

WritGrabber.traceEnabled = false

local function trace(msg)
  WritGrabber:Trace(msg)
end

function WritGrabber:EnableAlchemistWritCollection(enable)
  self.savedVariables.collectAlchemist = enable
  if enable then
    self.questTypeAlchemy = CookeryWizWritQuest:Register(self.name, self, L[WGL_QUEST_ALCHEMIST_WRIT_TITLE])
  else
    CookeryWizWritQuest:Unregister(self.name, self.questTypeAlchemy)
  end  
end

function WritGrabber:EnableEnchanterWritCollection(enable)
  self.savedVariables.collectEnchanter = enable
  if enable then
    self.questTypeEnchanting = CookeryWizWritQuest:Register(self.name, self, L[WGL_QUEST_ENCHANTER_WRIT_TITLE])
  else
    CookeryWizWritQuest:Unregister(self.name, self.questTypeEnchanting)
  end  
end

---------------------------------------------------------------------
-- CookeryWizGuildBank events and related functions
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Function: OnPrepareForBank
--
-- This function is called when the bank is opened. It gives
-- us a chance to setup the items to be fetched.
---------------------------------------------------------------------
function WritGrabber:OnPrepareForBank(control)
  trace("WritGrabber:OnPrepareForBank")
end

---------------------------------------------------------------------
-- Function: OnItemFetched
--
-- This function is called when the item has been fetched or failed
-- to be fetched. 'fetched' is true if it was successful
---------------------------------------------------------------------
function WritGrabber:OnItemFetched(item, fetched)
  trace("WritGrabber:OnItemFetched")
  table.remove(self.writItems)
  
  --d(item)
  local display
  if item.link then
    local itemType = GetItemLinkItemType(item.link)
    if (itemType == ITEMTYPE_POTION or itemType == ITEMTYPE_POISON) then
      display = item.name
    else
      display = zo_strformat("<<1>>", item.link)
    end
  else
      display = item.name    
  end
  
 
  if fetched then
    d(string.format(L[WGL_NOTIFY_ITEM_COLLECTED], self.name, display))
  else
    d(string.format(L[WGL_NOTIFY_ITEM_NOT_COLLECTED], self.name, item.name))
  end

end

---------------------------------------------------------------------
-- Function: OnItemToFetch
--
-- This function is called when the bank /guild bank fetch process has begun. 
-- We should return the next item that has to be fetched
-- Each item is an object of the form:
-- { count = nn, link = xxxx | name = "zzz"}
---------------------------------------------------------------------
function WritGrabber:OnItemToFetch()
  trace("WritGrabber:OnItemToFetch")
  local item = nil
  
  if self.writItems and #self.writItems > 0 then
    item = self.writItems[#self.writItems]
    trace("Fetching "..item.name)
  end

  return item
end


---------------------------------------------------------------------
-- CookeryWizWritQuest events
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Function: OnWritQuestReset
--
-- This function is called when the CookeryWizWritQuest object is about
-- to parse a writ quest for items. It can be called automatically when
-- the corresponding quest is added to the journal, or when a manual
-- Rescan() is executed
---------------------------------------------------------------------
function WritGrabber:OnWritQuestReset(questType)
  trace("WritGrabber:OnWritQuestReset["..questType.."]")
  local writType
  
  if questType == self.questTypeAlchemy then
    trace("-alchemy")
    writType = WRIT_ITEM_ALCHEMY
  elseif questType == self.questTypeEnchanting then
    trace("-enchanting")   
    writType = WRIT_ITEM_ENCHANTING
  end
  
  -- we only reset on the first reset request
  --if writType and self.firstReset then
    --self.writItems = {}
    --self.firstReset = false
  --end
  
end

---------------------------------------------------------------------
-- Function: OnWritItemAdded
--
-- This function is called when a writ quest item is parsed from the
-- text. It is called with the name of the item
-- We should know what type of item we are looking for from the questType
-- parameter
---------------------------------------------------------------------
function WritGrabber:OnWritItemAdded(questType, itemName, itemQuantity, questAdded)
  trace("WritGrabber:OnWritItemAdded["..questType.."], item["..itemName.."], quantity["..itemQuantity.."]")
  
  local itemNameLower = itemName:lower()
  local match
  local item
  
  -- is passed but check anyway
  if questType == self.questTypeAlchemy then
    trace("Alchemy WritItem["..itemName.."]")
    local startIndex, endIndex, herb, potion
    
    -- check for potion
    trace("- checking if potion")
    match, potion = WritGrabberAlchemy:FindPotion(itemNameLower)
    if match then
      trace("Matched potion "..potion.link.."")
      --trace("spaceIndex["..spaceIndex.."],endIndex]"..endIndex.."]")
      --itemNameLower = match --itemNameLower:sub(1, endIndex)

      trace("Adding potion name to look for "..match)
      item = { count = itemQuantity, name = match, id = potion.id}         
    else
      -- herb or reagent?    
      trace("Checking if it is a herb/reagent ["..itemNameLower.."]")
      startIndex, endIndex, herb = WritGrabberAlchemy:FindHerb(itemNameLower)
      if startIndex then
        trace("Matched herb/reagent "..herb.link)
        item = { count = itemQuantity, link = herb.link, id = herb.id, name = herb.name}
      else    
        item = { count = itemQuantity, name = itemNameLower}
      end
    end
    self.writItems[#self.writItems + 1] = item

    if questAdded then      
      local display = item.link
      if not item.link then
        display = item.name
      end      
      display = zo_strformat("<<1>>", display)
      d(string.format(L[WGL_NOTIFY_WRIT_ALCHEMY_ADDED], self.name, display)) 
    end    
  elseif questType == self.questTypeEnchanting then      
        
    local startIndex, endIndex, rune, glyph

    -- check for glyph
    trace("Checking if glyph["..itemNameLower.."]")
    match, glyph = WritGrabberEnchanting:FindGlyph(itemNameLower)
    if match then
      trace("Matched enchanting glyph "..glyph.link.."")
      --trace("spaceIndex["..spaceIndex.."],endIndex]"..endIndex.."]")
      --itemNameLower = match --itemNameLower:sub(1, endIndex)

      trace("Adding glyph name to look for "..itemNameLower)
      item = { count = itemQuantity, name = itemNameLower}        
    else
      trace("Checking if it is a rune ["..itemNameLower.."]")
      startIndex, endIndex, rune = WritGrabberEnchanting:FindRune(itemNameLower)
      if startIndex then
        trace("Matched enchanting rune "..rune.link)
        item = { count = itemQuantity, link = rune.link, id = rune.id, name = rune.name}
      else    
        item = { count = itemQuantity, name = itemName}
      end
    end
    self.writItems[#self.writItems + 1] = item
    if questAdded then
      local display = item.link
      if not item.link then
        display = item.name
      end      
      display = zo_strformat("<<1>>", display)
      d(string.format(L[WGL_NOTIFY_WRIT_ENCHANTING_ADDED], self.name, itemName)) 
    end    
  end

end

---------------------------------------------------------------------
-- Function: OnWritQuestItemsComplete
--
-- This function is called when the items from an individual writ quest
-- have been extracted
---------------------------------------------------------------------
function WritGrabber:OnWritQuestExtractionComplete(questType)
  trace("WritGrabber:OnWritQuestExtractionComplete["..questType.."]")
     
  --[[
  if questType == self.questTypeAlchemy then
    trace("This is for alchemy")
  elseif questType == self.questTypeEnchanting then
    trace("This is for enchanting")    
  end
]]--
end

---------------------------------------------------------------------
-- Function: OnWritQuestsExtractionComplete
--
-- This function is called when all the writ quests have been processed
---------------------------------------------------------------------
function WritGrabber:OnWritQuestsExtractionComplete()
  trace("WritGrabber:OnWritQuestsExtractionComplete")
  CookeryWizGuildBank:Enable(#self.writItems > 0)
end

---------------------------------------------------------------------
-- Function: OnWritQuestsExtractionStart
--
-- This function is called when all the writ quests are about to
-- be processed
---------------------------------------------------------------------
function WritGrabber:OnWritQuestsExtractionStart()
  trace("WritGrabber:OnWritQuestsExtractionStart")
  --self.firstReset = true
  self.writItems = {}
end


---------------------------------------------------------------------
-- Function: OnWritQuestComplete
--
-- This function is called when the items for the given writ quest
-- have been collected
---------------------------------------------------------------------
function WritGrabber:OnWritQuestComplete(questType)
  trace("WritGrabber:OnWritQuestComplete["..questType.."]")
  --[[
  if questType == self.questTypeAlchemy then
    trace("This is for alchemy")
  elseif questType == self.questTypeEnchanting then
    trace("This is for enchanting")    
  end
  ]]--
  --self.writItems = {}
end

function WritGrabber:RegisterSlashCommands()
 
  --chat command handlers
  local function command_handler(arg)
      --d("command_handler")
      arg = string.lower(arg)
      if(arg == "" or arg == nil or #arg == 0 or arg==L[WGL_CHAT_OPTION_TOGGLE]) then
        --Use your toggle function here or maybe this wil work too
        self:ToggleWindow()
      elseif arg==L[WGL_CHAT_OPTION_SHOW] then
        self:HideWindow(false)
      elseif arg==L[WGL_CHAT_OPTION_HIDE] then
        self:HideWindow(true)
      end
  end
          
  SLASH_COMMANDS["/wg"]           = command_handler
  SLASH_COMMANDS["/writgrabber"]   = command_handler
end

function WritGrabber:Initialize()
  
	local defaultSave =
	{
    collectAlchemist = true,
    collectEnchanter = true,
    easyFrameVariables = self.easyFrameVariables
	}

  self.savedVariables = ZO_SavedVars:NewAccountWide("WritGrabberSavedVariables", 1, nil, defaultSave)  
  self.easyFrameVariables = self.savedVariables.easyFrameVariables

  if not self.savedVariables.collapsed then
    self.savedVariables.collapsed = {}
  end
  
  -- Configure strings
  self.closeTooltip = L[WGL_BUTTON_TOOLTIP_CLOSE]
  --self.reloadTooltip:SetHidden(true)
  self.expandTooltip = L[WGL_BUTTON_TOOLTIP_EXPAND]
  self.shrinkTooltip = L[WGL_BUTTON_TOOLTIP_SHRINK]

  --self:EnableSceneIntegration(true)
  
  -- force it to stop showing
  self.easyFrameVariables.isHidden = true
  
  self:InitializeEasyFrame(L[WGL_WRITGRABBER_TITLE], WritGrabberUI) 
  
  self:SetChatInsets(16)
  
  -- Register slash commands
  self:RegisterSlashCommands()

  WritGrabberAlchemy:Initialise()
  WritGrabberEnchanting:Initialise()
  
  CookeryWizGuildBank:Register(self.name, self)
  CookeryWizBank:Register(self.name, self)
  
  if self.savedVariables.collectAlchemist then
    self:EnableAlchemistWritCollection(true)
  end
  
  if self.savedVariables.collectEnchanter then
    self:EnableEnchanterWritCollection(true)
  end

  self:HideWindow(true)
end

function WritGrabber:OnAddOnLoaded(event, addonName)
  if addonName == self.name then
    self:Initialize()
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
  end
end

EVENT_MANAGER:RegisterForEvent(WritGrabber.name, EVENT_ADD_ON_LOADED, function(...)
  WritGrabber:OnAddOnLoaded(...)
  end)

