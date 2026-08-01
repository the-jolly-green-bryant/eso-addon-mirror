
CW_RECIPE_DATA_TYPE = 1
CW_RECIPE_CATEGORY_DATA_TYPE = 3

MAIL_COMMAND_KNOWN = 1
--local MAIL_COMMAND_KNOWN_VERSION = 2

local MRL = CookeryWizRecipeList

local L = CookeryWizLanguage.language

local maxMailTimeSeconds = 3092000

CW_FILTER_CHOICE_ALL = 0
CW_FILTER_CHOICE_KNOWN = 1
CW_FILTER_CHOICE_QUANTITY = 2
CW_FILTER_CHOICE_UNKNOWN = 3
CW_FILTER_CHOICE_COOKABLE = 4


local filterOptions = { L[CWL_FILTER_ALL], L[CWL_FILTER_KNOWN], L[CWL_FILTER_QUANTITY], L[CWL_FILTER_UNKNOWN], L[CWL_FILTER_COOKABLE]}

local filterLevelOptions = { L[CWL_FILTER_ALL], "1-9", "10-19", "20-29", "30-39", "40-49", "C10-49", "C50-99","C100-149", "C150-150"}


local cookTiming = {
  startTime = 0,
  totalItems = 0,
  sessionStart = 0,
  sessionCount = 0,
  sessionPrediction = nil,
  sessionActual = nil,
  craftCount = 0,
  averageCook = 2400,
  averageDelay = 500,
  count = 1
}

-- String used in the keybindings window
ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_COOKERYWIZ_WINDOW", "Show/Hide Cook Book")

CookeryWiz = EasyFrame:new()
CookeryWiz.name = L[CWL_COOKERYWIZ_NAME]

-- scroll list control
CookeryWiz.recipeScrollList = nil

CookeryWiz.characterComboBox = nil
CookeryWiz.characterDropdown = nil

CookeryWiz.filterComboBox = nil
CookeryWiz.filterDropdown = nil
CookeryWiz.selectedFilter = nil
CookeryWiz.selectedFilterChoice = FILTER_ALL_CHOICE

CookeryWiz.filterLevelComboBox = nil
CookeryWiz.filterLevelDropdown = nil
CookeryWiz.selectedFilterLevel = nil

CookeryWiz.qualityComboBox = nil
CookeryWiz.qualityDropdown = nil

CookeryWiz.savedVariables = nil

--CookeryWiz.masterRecipeList = nil
CookeryWiz.selectedPlayerName = nil

CookeryWiz.searchControl = nil

CookeryWiz.searchClearButtonControl = nil

CookeryWiz.optionsButtonControl = nil

CookeryWiz.clearOrdersButtonControl = nil

CookeryWiz.cookButtonControl = nil

CookeryWiz.mailButtonControl = nil

CookeryWiz.timeRemainingLabel = nil


CookeryWiz.contentControl = nil

CookeryWiz.ingredients = {}

CookeryWiz.filterText = ""

CookeryWiz.provisionWritStartTextLower = "craft"

CookeryWiz.isCookingStationOpen = false
--CookeryWiz.isCooking = false
CookeryWiz.currentlyCooking = nil

CookeryWiz.mailHandler = nil

CookeryWiz.scannedMailItems = {}
CookeryWiz.lastMailCount = -1
CookeryWiz.enableScanning = true
CookeryWiz.messages = nil
CookeryWiz.flagsOffset = 2
CookeryWiz.bitSize = 32

-- messages to be deleted
CookeryWiz.deleteMessages = {}

-- The very first time the mailbox is opened it will not be populated with messages
-- If this flag is true then we scan mail on the first read event instead
CookeryWiz.firstRead = true
CookeryWiz.firstShow = true

CookeryWiz.ingredientMissingColour = "FF6347"

CookeryWiz.currentQuality = nil

CookeryWiz.disableIngredientUpdate = false

CookeryWiz.editLinkControl = nil
CookeryWiz.cancelCooking = false

CookeryWiz.bankFood = nil
CookeryWiz.bankFoodSlot = nil
CookeryWiz.isBankOpen = false
CookeryWiz.isRegisteredForSlotUpdate = false

CookeryWiz.isGuildBankOpen = false
CookeryWiz.currentGuildBankId = nil
CookeryWiz.currentBagId = nil
CookeryWiz.lastFullSlotDataCount = 0
CookeryWiz.guildBankFoodSlot = 0


CookeryWiz.slotUdatedFood = nil
--CookeryWiz.updatedFood = nil
--CookeryWiz.handledFood = nil
CookeryWiz.writTransferComplete = false

CookeryWiz.writItems = {}

CookeryWiz.initComplete = false

CookeryWiz.favouriteFilterIndex = 0

-- These are used for the edit amount control in the recipe scroll list
--[[
CookeryWiz.editAmountGoodColor = GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL)
CookeryWiz.editAmountBadColor =  ZO_ERROR_COLOR:UnpackRGBA()
]]--

--CookeryWiz.enableBookTheme = false

CookeryWiz.traceEnabled = false

local function trace(msg)
  CookeryWiz:Trace(msg)
end



CW_SAVED_VAR_RECIPE_KNOWLEDGE_ICON = "enableRecipeKnowledgeIcon"

---------------------------------------------------------------------
-- Generic saved variables data function
---------------------------------------------------------------------

-- Enable item
function CookeryWiz:Enable(item, enable)
  self.savedVariables[item] = enable
end

-- Is item enabled?
function CookeryWiz:IsEnabled(item)
  return self.savedVariables[item]
end


---------------------------------------------------------------------
-- Awesome Guild Store hook
---------------------------------------------------------------------

CookeryWiz.fnAwesomeGuildStore = nil

-- Enable integration with AGS. Integration happens on window show/hide
function CookeryWiz:EnableAwesomeGuildStoreIntegration(enable)
  self.savedVariables.enableAwesomeGuildStoreIntegration = enable
  if enable then
    self:HookAwesomeGuildStore()
  else
    self:UnHookAwesomeGuildStore()
  end
end

-- Is AGS integration enabled?
function CookeryWiz:IsAwesomeGuildStoreIntegrationEnabled()
  return self.savedVariables.enableAwesomeGuildStoreIntegration
end

-- Integrate CookeryWiz with AGS
function CookeryWiz:HookAwesomeGuildStore()
  if self:IsAwesomeGuildStoreIntegrationEnabled() and AwesomeGuildStore and AwesomeGuildStore.KnownRecipeFilter then
    -- if it is not already hooked
    if not self.fnAwesomeGuildStore then
      trace("Hooking filters")
      self.fnAwesomeGuildStore = AwesomeGuildStore.KnownRecipeFilter.FilterPageResult
      AwesomeGuildStore.KnownRecipeFilter.FilterPageResult = function (...)      
      return self:FilterPageResult(...)
      end
    end
  end
end

function CookeryWiz:FilterPageResult(ags, index, icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice)
  --d(self.selectedPlayerName..": Filter Page Result Called index"..index)
  local showKnown = ags.showKnown
  local showUnknown = ags.showUnknown
  local characterVars = self:GetSelectedPlayerCharacterVars()
	local itemLink = GetTradingHouseSearchResultItemLink(index, LINK_STYLE_DEFAULT)
  local masterEntry = MRL:GetEntryByRecipeLink(itemLink)
  local isKnown = false
  if masterEntry then
    trace("Known["..itemLink.."]"..tostring(showKnown)..tostring(showUnknown))
    local knownEntry = characterVars.known[tostring(masterEntry:ItemId())]
    
    if knownEntry then
      trace("-Found it")
      isKnown = true
    end
  else
    trace("Unnown["..itemLink.."]"..tostring(showKnown)..tostring(showUnknown))
  end
  local res = (showUnknown and not isKnown) or (showKnown and isKnown)
  trace("Return result ["..tostring(res).."]")

	return res
end

-- Unhook CookeryWiz from AGS
function CookeryWiz:UnHookAwesomeGuildStore()
  if self.fnAwesomeGuildStore then
    trace("Unhooking filters")
    AwesomeGuildStore.KnownRecipeFilter.FilterPageResult = self.fnAwesomeGuildStore
    self.fnAwesomeGuildStore = nil
  end  
end

---------------------------------------------------------------------
-- General functions
---------------------------------------------------------------------

function CookeryWiz:DisplayWithStationInteraction(display)
  self.savedVariables.displayWithStationInteraction = display
end

function CookeryWiz:IsDisplayWithStationInteractionEnabled()
  return self.savedVariables.displayWithStationInteraction
end

function CookeryWiz:DeleteReadMail(delete)
  self.savedVariables.deleteReadMail = delete
end

function CookeryWiz:IsDeleteReadMailEnabled()
  return self.savedVariables.deleteReadMail
end

-- Writ collection status
function CookeryWiz:DisableWritCollection(disable)
  self.savedVariables.disableWritCollection = disable
end

function CookeryWiz:IsWritCollectionDisabled()
  return self.savedVariables.disableWritCollection
end

function CookeryWiz:CookeryWizValidate()
  trace("Inside CookeryWizValidate")
  if not self then
    trace("You have called Validate without :")
    return
  end
  
  local res = true

  if not self.recipeScrollList then
      trace("No recipeScrollList")
      res = false
  end 
  
  if not self.characterDropdown then
    trace("No characterDropdown")
    res = false
  end
  
  res = self:EasyFrameValidate()
  return res
end

---------------------------------------------------------------------
-- Cookbook ScrollList related functions
---------------------------------------------------------------------
function CookeryWiz:GetCookVars()
  return self.savedVariables.cook
end

function CookeryWiz:GetCookEntry(recipeId)
  local cookVars = self.savedVariables.cook
  for cookIndex, cookEntry in pairs(cookVars) do
    -- Each cookEntry looks like this { masterindex = <index into masterrecipelist>, quantity = <quantity to cook>, tag = < a tag of some sort> }    
    if cookEntry.recipeId == recipeId then
      --d("Matched recipe. Cook index "..cookIndex)
      return cookEntry
    end
  end  
end

-- Gets the first entry that still needs to be cooked
function CookeryWiz:GetFirstCookEntry()
  -- # on this is unreliable
  local cookVars = self.savedVariables.cook
  for cookIndex, cookEntry in pairs(cookVars) do
      return cookEntry
  end   
end

function CookeryWiz:IsCollapsed(cat) 
  local isCollapsed = self.savedVariables.collapsed[tostring(cat)]
  if isCollapsed then
    return true
  else
    return false
  end
end

function CookeryWiz:SetCollapsed(cat, collapsed)
  self.savedVariables.collapsed[tostring(cat)] = collapsed  
end

function CookeryWiz:GetSelectedPlayerCharacterVars()
  return self:GetPlayerCharacterVars(self.selectedPlayerName)
end

function CookeryWiz:GetCurrentPlayerCharacterVars()
  return self:GetPlayerCharacterVars(GetUnitName("player"))
end

function CookeryWiz:GetCharacterVars()
  return self.savedVariables.characters
end

-- Whenever we call this, we will always want to create the player entry
-- regardles. So if it is missing we add it!
function CookeryWiz:GetPlayerCharacterVars(playerName)
  local characterVars = self.savedVariables.characters[playerName];
  if not characterVars then
    --trace("No CharacterVars for "..self.selectedPlayerName)
    -- NOTE: 2592000 seconds is roughly 30 days, which is how long a message can be in the inbox for, Make it bigger
    characterVars = { enabled = true,
      external = nil,
      seconds = maxMailTimeSeconds, 
      provisionerRecipeImprovement = nil,
      provisionerRecipeQuality = nil,
      --writFood = nil,
      knownCount = nil,
      known = {}
      }
    self.savedVariables.characters[playerName] = characterVars
  end
  return characterVars
end

-- table of search criteria items entered by user
CookeryWiz.textSearchItems = {}

function CookeryWiz:ParseSearchFilter(text)
  local entry = nil
  
  local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
  end
  
  text = trim(text)
  --d("["..text.."]")
  if not text or text == "" then
    entry = {}
  elseif not text:find(",", 1, true) then
    entry = { text }
  else
    entry = split(text..",", ",")
  end
  --d(entry)


  -- now trim space and save lowercase version
  local entryLower = {}
  --d("#Entries - "..#entry)
  for i = 1, #entry do
    entry[i] = trim(entry[i])
    entryLower[i] = entry[i]:lower()
  end
  --d(entryLower)
  self.textSearchItems = entryLower

end


function CookeryWiz:RebuildMasterRecipeScrollList()

  trace("RebuildMasterRecipeScrollList called")
  CookeryWizRecipeList:PopulateMasterRecipes(self.textSearchItems, self.selectedFilterChoice, self.selectedFilterLevel, self.currentQuality, self:GetFavouriteFilterIndex())
  CookeryWizRecipeList:UpdateList()

end



---------------------------------------------------------------------
-- Help functions
---------------------------------------------------------------------

CookeryWiz.helpBook = nil

function CookeryWiz:OnHelpButtonClicked(control)
  if not self.helpBook then
    self.helpBook = CookeryWizBook:New(self, "CookeryWizHelpBook", self:GetSavedVars())
  end
end


function CookeryWiz:OnGetCookeryWizParentUI()
  return self:GetWindow()
end

function CookeryWiz:OnHelpButtonInitialized(control)

end

---------------------------------------------------------------------
-- Time Remaining functions
---------------------------------------------------------------------


function CookeryWiz:OnTimeRemainingLabelInitialized(control) 
  self.timeRemainingLabel = control
  self:SetupTooltip(control, L[CWL_LABEL_TOOLTIP_TIME_REMAINING]) 
  CookeryWizUtils:SetFont(control, 14)  
end

---------------------------------------------------------------------
-- Free Space functions
---------------------------------------------------------------------

CookeryWiz.lastFreeSpace = nil

function CookeryWiz:OnFreeSpaceLabelInitialized(control) 
  self.freeSpaceLabelControl = control
  self:SetupTooltip(control, L[CWL_BUTTON_TOOLTIP_FREE_SPACE]) 
  CookeryWizUtils:SetFont(control, 14)  
end

function CookeryWiz:UpdateFreeSpace()
  -- CheckInventorySpaceSilently(integer numItems) 
  if self:IsHidden() then
    return
  end
  
  local freeSlots = GetNumBagFreeSlots(BAG_BACKPACK)
  if self.lastFreeSpace ~= freeSlots then
    local displayText = zo_iconTextFormat("/esoui/art/tooltips/icon_bag.dds", 24, 24, freeSlots)
    self.freeSpaceLabelControl:SetText(displayText)
    self.lastFreeSpace = freeSlots
  end
end

---------------------------------------------------------------------
-- Stockpile functions
---------------------------------------------------------------------

function CookeryWiz:OnStockpileButtonInitialized(control)
  self.stockpileButtonControl = control
end

function CookeryWiz:OnStockpileButtonClicked(control)
  CookeryWizStockpiles:SetItemType(ITEMTYPE_INGREDIENT)
  CookeryWizStockpiles:ShowDialog(self)  
end

---------------------------------------------------------------------
-- Mailbox functions
---------------------------------------------------------------------

function CookeryWiz:AddMailIdToDelete(mailId)
  if self:IsDeleteReadMailEnabled() then
    local mailStringId = Id64ToString(mailId) 
    self.deleteMessages[mailStringId] = mailId
  end
end

function CookeryWiz:GetNextMessageToDelete()
  if not self.deleteMessages then
    return
  end  
  for key, entry in pairs(self.deleteMessages) do
    return entry
  end
end

function CookeryWiz:RemoveMailIdToDelete(mailId)
  if self:IsDeleteReadMailEnabled() then
    local mailStringId = Id64ToString(mailId) 
    self.deleteMessages[mailStringId] = nil
  end
end

function CookeryWiz:EnableScanning(enableScanning)
  self.enableScanning = enableScanning
end

function CookeryWiz.OnMailReadable(eventCode, mailId)
  local self = CookeryWiz
  local mailStringId = Id64ToString(mailId) 
  trace("OnMailReadable: code["..eventCode.."], mailid[".. mailStringId .."]")
  
  if self.firstRead then
    self.firstRead = false
    self:ScanMail()
    return
  end
  
  -- if we have no messages we are interested in then exit
  if not self.messages then
    trace("No messages to parse so exiting")
    return
  end
  
  -- Is this an entry we are interested in?
  local message = self:GetMatchingMessage(mailId)  
  if not message then
    trace("No matching message to parse so exiting")
    return
  end
  
  d(string.format(L[CWL_NOTIFY_IMPORTING_CHARACTER], self.name, message.storageName))
  
  local body = ReadMail(message.mailId)   
  if not body or #body == 0 then
    d(L[CWL_NOTIFY_MAIL_MISSING_BODY])
  else
    self:ParseEmail(message.refNumber, message.storageName, body)
    
    -- now do we auto delete it?
    self:AddMailIdToDelete(message.mailId)
    --[[
    if self:IsDeleteReadMailEnabled() then
      DeleteMail(message.mailId, true) 
    end
    ]]--
  end
  
  -- move to the next one
  self.messages[message.storageName] = nil
  self:RequestMessages()  
  
end

function CookeryWiz:ParseEmail(refNumber, storageName, body)
  local characterVars =  self:GetPlayerCharacterVars(storageName)
    
  --local known = self:DeconstructKnownRecipes(body)
  local known = CookeryWizUtils:DecodeKnownRecipes(body)
  if known then
    characterVars.known = known 
    characterVars.external = refNumber
    characterVars.knownCount = refNumber
    self.savedVariables.characters[storageName] = characterVars   
  end

end

function CookeryWiz:GetNextMessage()
  if not self.messages then
    return
  end
  
  for key, entry in pairs(self.messages) do
    return entry
  end      
end

function CookeryWiz:GetMatchingMessage(mailId)
  if not self.messages then
    return
  end
  
  for key, entry in pairs(self.messages) do
    if entry.mailId == mailId then
      return entry
    end
  end      
end

function CookeryWiz:ParseMailHeader(header)
  -- header looks like this:
  -- CookeryWiz<space><ascending reference><space><character name>
  local startRefPos = #self.name+2
  local startCharPos = header:find(" ", startRefPos, true)
  if not startCharPos then
    trace("Invalid header")
    return
  end
  
  local reference = header:sub(startRefPos, startCharPos - 1)
  if not reference then
    trace("Missing reference in header")
    return
  end
  
  --trace("Ref:"..reference)
  local refNumber = tonumber(reference)
  if not refNumber then
    trace("Reference in header is not a number")
    return
  end
    
  local characterName = header:sub(startCharPos + 1) 
  if not characterName then
    trace("Missing charactername in header")
    return
  end
    
  -- If we are here.. all is good!
  return refNumber, characterName
end

-- This function will scan the inbox for mails relating to CookeryWiz.
-- NOTE: Not sure why, but sometimes the mail count will be 0. This only appears to happen on the very first
-- time that the inbox is scanned. Perhaps a race condition if it has not been properly initialised?
function CookeryWiz:ScanMail()
  trace("ScanMail")
  if not self.enableScanning then
    return
  end
  
  --RequestOpenMailbox() 
  local mailCount = GetNumMailItems()
  trace("Last Mail Count "..self.lastMailCount)
  if mailCount == self.lastMailCount then
    trace(string.format(L[CWL_NOTIFY_NOT_SCANNING], self.name, mailCount))
    return
  else
    trace(string.format(L[CWL_NOTIFY_SCANNING], self.name, mailCount))
  end

  local function HaveSeenMailBefore(stringMailEntry)
    -- Dont bother with this atm
    --[[
     -- is it one we have checked before?
    --trace("Scanned Before count "..#self.scannedMailItems)
    for i = 1, #self.scannedMailItems do
      local entry = self.scannedMailItems[i]
    --for key, entry in pairs(self.scannedMailItems) do
      --trace("-"..entry.."["..stringMailEntry.."]")
      if entry == stringMailEntry then
        -- yep. exit
        trace("Scanned this email before "..stringMailEntry)
        return true
      end      
    end
    ]]--
    return false
  end

  local mailEntry = GetNextMailId(nil)

  while mailEntry do
    local stringMailEntry = Id64ToString(mailEntry)
    -- we have not seen it. scan it
    if HaveSeenMailBefore(stringMailEntry) == false then
    
      local senderDisplayName, senderCharacterName, subject, icon, unread, fromSystem, fromCustomerService, returned,
      numAttachments, attachedMoney, codAmount, expiresInDays, secsSinceReceived = GetMailItemInfo(mailEntry) 
      
      -- parse the subject line
      if subject:find(self.name)==1 then
        trace("Found mail for us '"..subject.." ["..stringMailEntry.."]'")
        local refNumber, characterName = self:ParseMailHeader(subject)

        -- The information is stored under a combination of characterName and account name
        -- make sure we have them both. If they are missing then it looks like this is an 
        -- email which is not correct
        if refNumber and characterName and senderDisplayName ~= "" then
          -- it's valid
          local storageName = characterName..senderDisplayName 
          -- get the character vars (Note they will be created if dont exist)
          local characterVars =  self:GetPlayerCharacterVars(storageName)
        
          -- we dont want to parse this email if we dont have to. This is for performance reasons
          -- so the mail id is stored with the character's known recipes. We check this to see if
          -- we have already parsed the mail.
          -- In addition, if there happens to be more than one mail entry in the inbox for this character we
          -- we will not read it if it is older than the 'secondsreceived' entry of the existing one
          
          --trace("external["..characterVars.external.."]"..stringMailEntry)
          local externalRef = 0
          if characterVars.external then
            externalRef = tonumber(characterVars.external)
            if not externalRef then
              externalRef = 0
            end
          end
          trace("External Ref["..externalRef.."] "..refNumber)
          if not characterVars or not characterVars.external or externalRef < refNumber then
            trace("Examining "..stringMailEntry)
            if not self.messages then
              self.messages = {}
            end
            
            local message = self.messages[storageName]
            if not message then
              message = {}
              self.messages[storageName] = message
            else
              -- do we replace this?
              trace("Replacing ["..message.stringMailEntry.."]")
              message = {}
              self.messages[storageName] = message             
            end
            
            -- we could also check if we have an email for this storagename and
            -- replace if the current one is later            
            message.refNumber = refNumber
            message.mailId = mailEntry
            message.storageName = storageName
            message.stringMailEntry = stringMailEntry
          else
            trace("No need to parse message")
            -- now do we auto delete it?
            self:AddMailIdToDelete(mailEntry)         
          end
        end
      end  
     
      -- for optimisation reasons, we record the mail ids of those already scanned
      -- this is only for the player session and we do not record them in the saved variables
      -- Dont bother atm
      --self.scannedMailItems[#self.scannedMailItems + 1] = stringMailEntry       
    
    end
    
    -- get the next mail entry id
    mailEntry = GetNextMailId(mailEntry)
  end
  
  -- now start the reading of the body process
  self:RequestMessages()
  
  -- for further optimisation, store the count of emails when we parsed this. The scan routine is run when the inbox is opened
  -- if the user deletes items them the count will change, or new messages.
  self.lastMailCount = mailCount
end

function CookeryWiz:RequestMessages()
  local message = self:GetNextMessage()  
  if message then
    RequestReadMail(message.mailId)
  else
    -- we are done
    trace("No remaining messages to parse so exiting")
    self.messages = nil
    self:PopulateCharacterDropDown()
    -- now delet any messages
    self:DeleteMessages()
  end  
end

function CookeryWiz:DeleteMessages()
  if self:IsDeleteReadMailEnabled() == false then
    return
  end  
  
  local mailId = self:GetNextMessageToDelete()  
  if mailId then
    DeleteMail(mailId, true) 
  end  
end

function CookeryWiz.OnOpenMailBox(eventCode)
  trace("OnOpenMailBox")
  --zo_callLater(function() CookeryWiz:ScanMail() end, 500)
  local self = CookeryWiz
  if not self.firstRead then
    self:ScanMail()
  end    
end

function CookeryWiz:OnMailRemoved(eventCode, mailId)
  --trace("Mail removed")
  self.lastMailCount = self.lastMailCount - 1
  
  -- remove any message from our list to be removed
  self:RemoveMailIdToDelete(mailId)
  -- delete any remaining
  self:DeleteMessages()
end

function CookeryWiz.OnCloseMailBox(eventCode)
  --d("OnCloseMailBox "..eventCode)
end

function CookeryWiz.OnMailSendFailed(eventCode, reason)
  trace("OnMailSendFailed "..eventCode..", reason "..reason)
end

function CookeryWiz.OnMailSendSuccess(eventCode)
 --d("OnCloseMailBox "..eventCode)   
end

function CookeryWiz:OnMailButtonInitialized(control)
  --d("OnMailButtonInitialized")
  self.mailButtonControl = control
  self:SetupTooltip(control, L[CWL_BUTTON_TOOLTIP_MAILER])  
end

function CookeryWiz:CreateMailHeader(characterVars, characterName)
  -- uses the number of recipes known as this can only go up!
  local knownCount = characterVars.knownCount
  if not knownCount then
    knownCount = 0
  end
  local header = self.name.." "..knownCount.." "..characterName
  return header
end


-----------------------


local function bit(p)
  return 2 ^ (p - 1)  -- 1-based indexing
end

-- Typical call:  if hasbit(x, bit(3)) then ...
local function hasbit(x, p)
  return x % (p + p) >= p       
end

local function setbit(x, p)
  return hasbit(x, p) and x or x + p
end

local function clearbit(x, p)
  return hasbit(x, p) and x - p or x
end


-----------------------
function CookeryWiz:DeconstructKnownRecipes(data)
  local bitSize = self.bitSize
  local maxRecipes = self.maxRecipes
  local maxFlags = self.maxFlags
  local version = nil
  local flags = nil
  
  -- is it a string or table
  local dataType = type(data)
  if dataType == "string" then
    trace("Parsing string")
    local t = split(data, ",")
    flags = {}
    version = t[2]
    for i = 1 + self.flagsOffset, #t do
      flags[#flags + 1] = t[i]
    end
  elseif dataType == "table" then
    trace("Parsing table")
    version = data[2]
    flags = {}
    for i = 1 + self.flagsOffset, #data do
      flags[#flags + 1] = data[i]
    end

  else
    d("Invalid data type passed to DeconstructKnownRecipes")
    return
  end
  
  -- is this a valid message
  trace("Version["..MAIL_COMMAND_KNOWN_VERSION.."] "..version)
  if tonumber(version) ~= MAIL_COMMAND_KNOWN_VERSION then
    d(string.format(L[CWL_NOTIFY_INCORRECT_IMPORT_VERSION], self.name))
    return
  end

  local knownCount = 0
  local known = {}
  trace("Flags Count "..#flags)
  for i = 1, #flags do
    local flag = tonumber(flags[i])
    trace("Parsing "..flag)
    for j = 1, bitSize do
      if hasbit(flag, bit(j)) then
        knownCount = knownCount + 1
        local index = ((i - 1) * bitSize) + j
        local recipeEntry = MRL:GetEntryByMasterRecipeListIndex(index)
        local recipeId = recipeEntry:ItemId()        
        known[tostring(recipeId)] = recipeId
      end
    end
  end

  trace("Known Count "..knownCount)
  return known
end


function CookeryWiz:ConstructKnownRecipes(characterName)
  local bitSize = self.bitSize
  local maxRecipes = self.maxRecipes
  local maxFlags = self.maxFlags
  
  local flags = {MAIL_COMMAND_KNOWN, MAIL_COMMAND_KNOWN_VERSION}

  local knownCount = 0

  -- Clear the flags to 0
  for i = 1, maxFlags do
    flags[#flags + 1] = 0
  end
  
  local characterVars =  self:GetPlayerCharacterVars(characterName)
  
  local known = characterVars.known
  
  -- go through each known recipe
  for key, value in pairs(known) do
    local recipeEntry = MRL:GetEntry(value)
    local recipeIndex = recipeEntry:GetIndex()
    -- value is the index into MRL
    local index = math.floor( (recipeIndex-1) / (bitSize)) + 1
    local bitFlag =  recipeIndex - ( (index - 1) * bitSize)
    local flag = flags[index + self.flagsOffset]
    
    --trace("Setting Flags["..index.."]-["..bitFlag.."]-"..value)    
    if hasbit(flag, bit(bitFlag)) then
    --if testflag(flags[index], bitFlag) then
      d("Gasp! Flags["..index.."]-["..bitFlag.."]-"..recipeId.." Already set!")
    end
    flags[index + self.flagsOffset] = setbit(flag, bit(bitFlag)) --setflag(flags[index], bitFlag)
    knownCount = knownCount + 1
  end

  local s = table.concat(flags, ",")..","
  trace("Known count"..knownCount)
  trace(s)
  return s
end
  
    
function CookeryWiz:SendKnownRecipes(characterName, address)
  local characterVars =  self:GetPlayerCharacterVars(characterName)
  local known = characterVars.known
  
  --local s = self:ConstructKnownRecipes(characterName)
  
  local s = CookeryWizUtils:EncodeKnownRecipes(known)
  
  --d(s)
  RequestOpenMailbox()
  local header = self:CreateMailHeader(characterVars, characterName)
  trace("Sending mail "..header)
  SendMail(address, header, s)
end

function CookeryWiz:OnMailShow(control)
  
end

function CookeryWiz:OnMailButtonClicked(control)
  CookeryWizMailer:ShowDialog(self)
end

---------------------------------------------------------------------
-- EasyFrame virtual functions
---------------------------------------------------------------------

-- Use this function to hide and show controls according to whether we are shrunk or expanded
function CookeryWiz:OnShrink()
  if not self then
    d("OnShrink called without :")
    return
  end
    
  local vars = self.easyFrameVariables
  local isShrunk = vars.isShrunk
  
  if isShrunk then
    -- hide controls
    CookeryWizMailer:HideWindow(true)
  else
    -- show controls

  end
  self.freeSpaceLabelControl:SetHidden(isShrunk)
  self.contentControl:SetHidden(isShrunk)
  self.characterComboBox:SetHidden(isShrunk)
  self.optionsButtonControl:SetHidden(isShrunk)
  self.mailButtonControl:SetHidden(isShrunk)
  self.timeRemainingLabel:SetHidden(isShrunk)
  self.stockpileButtonControl:SetHidden(isShrunk)
end

function CookeryWiz:OnEasyFrameResize()
  --d("OnEasyFrameResize")
  
  if not self then
    d("OnEasyFrameResize called without :")
    return
  end
    
  if not self.ui then
    d("Missing ui")
    return    
  end
  
  CookeryWizRecipeList:RefreshScrollList()
  CookeryWizIngredients:RefreshScrollList()

end

function CookeryWiz:OnRestorePosition()
end


function CookeryWiz:SetHighlight(control, state)

  local highlightControl = control:GetNamedChild("Highlight")

  highlightControl:SetHidden(not state)
end

---------------------------------------------------------------------
-- Function: ToggleWindowKeyPress
--
-- This function is called for a keybinding to toggle the window
-- If we are replacing the default ESO provisioner cooking station
-- window then we ignore this kep press
---------------------------------------------------------------------
function CookeryWiz:ToggleWindowKeyPress()
  if self.normalWindowData then
    trace("Ignoring keypress")
    return
  end
  self:ToggleWindow()
end

function CookeryWiz:OnHideWindow(isHidden)
  if isHidden then
    CookeryWizMailer:HideWindow(true)
    CookeryWizOptions:HideWindow(true)
    CookeryWizStockpiles:HideWindow(true)
    self:UnHookAwesomeGuildStore()
    
  else
    -- set focus to search
    self:UpdateFreeSpace()
    if not self:IsShrunk() and not isHidden and self.initComplete then
      self:HookAwesomeGuildStore()
      self:TakeFocus(self.searchControl)
    end
  end
end

function CookeryWiz:OnShow(topLevelControl)
  --d("OnShow")
  self:OnReloadRecipes(true)
end

function CookeryWiz:OnReload()
  
  -- force an update to these skill levels
  self:UpdateProvisionerRecipeImprovement(self.selectedPlayerName)
  self:UpdateProvisionerRecipeQuality(self.selectedPlayerName)
      
  self:OnReloadRecipes(true)
  self:UpdateCookIngredients()   
end

function CookeryWiz:OnReloadRecipes(refreshCharacter)
  if not self then
    d("OnReloadRecipes called without :")
    return
  end
   
  -- check master recipes to see if known
  --local numRecipeLists = GetNumRecipeLists()
  
  local characterName = self.selectedPlayerName  
  --local characterVars = self:GetSelectedCharacterVars()
  
  -- Only refresh if the current player is the one selected
  -- As we have no way of refreshing other players!
  if refreshCharacter and characterName == GetUnitName("player") then
    self:RefreshCharacterKnowledge()
  end  

  self.disableIngredientUpdate = true
  local scrollData = self:RebuildMasterRecipeScrollList()
  self.disableIngredientUpdate = false
end

function CookeryWiz:OnMoveStop()
end

---------------------------------------------------------------------
-- Initialization functions
---------------------------------------------------------------------

function CookeryWiz:OnContentInitialized(control)
  self.contentControl = control

end

function CookeryWiz:OnSearchClearButtonInitialized(control)
  self.searchClearButtonControl = control
  self:SetupTooltip(control, L[CWL_BUTTON_TOOLTIP_CLEAR_SEARCH])
end

function CookeryWiz:OnSearchClearButtonClicked(control) 
  self.searchControl:SetText("")  
  self.searchControl:TakeFocus()
end


function CookeryWiz:IsKnownBySelectedCharacter(recipeId)
  local characterVars = self:GetSelectedPlayerCharacterVars()
  if not characterVars then
    return false
  end
  local knownEntry = characterVars.known[tostring(recipeId)]
  if knownEntry then
    return true
  else
    return false
  end
end

---------------------------------------------------------------------
-- Ingredients scroll control functions
---------------------------------------------------------------------



function CookeryWiz:RepositionTooltip(control)
  -- we need to determine optimal postion. If close to edge of screen funny things happen!
  local tooltipOffset = 10
  local tooltipWidth = control:GetWidth()
  local left = self.ui:GetLeft() --self.easyFrameVariables.leftNormal
  local tooltipLeft = left
    
  local screenWidth = self.ui:GetParent():GetWidth()
  local uiWidth = self.ui:GetWidth()
    
  if left + uiWidth + tooltipWidth + tooltipOffset > screenWidth then
    InitializeTooltip(control, self.ui, TOPLEFT, -1 * (tooltipWidth + 10), 15, TOPLEFT)  
  else
    InitializeTooltip(control, self.ui, TOPLEFT, 10, 15, TOPRIGHT)
  end  
end


---------------------------------------------------------------------
-- Cooking Action functions
---------------------------------------------------------------------

-- Gets the first entry that still needs to be cooked
-- that we can actually cook and we have the ingredients for
function CookeryWiz:GetFirstCookableEntry()
  -- # on this is unreliable  
  local cookVars = self.savedVariables.cook
  local currentPlayer = GetUnitName("player")
  for cookIndex, cookEntry in pairs(cookVars) do
    local masterEntry = MRL:GetEntry(cookEntry.recipeId)
    -- First thing.. do we know it?
    if masterEntry and masterEntry:IsKnown() then
      
      -- do we have skills to cook it?
      if masterEntry:CanCook(self:GetProvisionerRecipeImprovement(currentPlayer), self:GetProvisionerRecipeQuality(currentPlayer)) then
        local missingIngredients = false
        -- so far so good. Do we have enough ingredients?
        local ingredients = masterEntry:GetIngredients()
        for ingredientIndex = 1, #ingredients do
          -- each object in array returned resembles the folowing:
          -- { entry = entryIngredient, quantity = amountRequired, stocked = stockedAmount}
          local ingredient = ingredients[ingredientIndex]
          local entry = ingredient.entry;
          --d(ingredient:GetName().."-"..ingredient:GetStock())
          --if (ingredient:GetStock() + ingredient:GetStolenStock()) == 0 then
          if ingredient.quantity > ingredient.stocked then
            missingIngredients = true
            break
          end
        end
        
        -- did we have enough ingredients?
        if not missingIngredients then
          -- yep! return this item
          return cookEntry, masterEntry
        end
        
      end      
    end    
  end   
end


function CookeryWiz:ResetCooking()
    self:SetCookButtonTitle(false)
    self.cancelCooking = false
    self.currentlyCooking = nil
end

function CookeryWiz:OnCookButtonInitialized(control)
  self.cookButtonControl = control
  
  self.cookButtonControl:SetEnabled(false)
  --control:SetText(L[CWL_BUTTON_COOK])
  --self:SetupTooltip(control, L[CWL_BUTTON_TOOLTIP_COOK])
  self:ResetCooking()
end

function CookeryWiz:OnCraftingStationInteract(eventCode, craftSkill, sameStation)
  if craftSkill ~= CRAFTING_TYPE_PROVISIONING then 
    return
  end

  self:ReplaceProvisionerWindow()
  self.isCookingStationOpen = true
  self:ResetCooking()

  --d("Cooking station interaction:event("..eventCode..")")
  self.cookButtonControl:SetEnabled(true) 
  
  local stationInteractionMethod = self:GetStationInteractionMethod()
  if stationInteractionMethod == CW_STATION_INTERACTION_METHOD_DISPLAY then
    if self:IsHidden() then
      self:HideWindow(false)
    end
  end
  
 
  local playerName = GetUnitName("player")
  self:UpdateProvisionerRecipeImprovement(playerName)
  self:UpdateProvisionerRecipeQuality(playerName)
  
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CRAFT_COMPLETED, self.OnCraftCompleted)
  
  self:ReplaceCookeryWizPosition()

end


function CookeryWiz:IsChatEdgeEnabledSetting()
  if self.normalWindowData then  
    return self.normalWindowData.chatEdgeEnabled
  else
    return self:IsChatEdgeEnabled()
  end
end

function CookeryWiz:EnableChatEdgeSetting(enable)
  if self.normalWindowData then
    local data = self.normalWindowData    
    data.chatEdgeEnabled = not data.chatEdgeEnabled
  else
    self:EnableChatEdge(enable)
  end     
end

function CookeryWiz:IsMiniIconDisabledSetting()
  return self:IsMiniIconDisabled()
end

function CookeryWiz:DisableMiniIconSetting(enable)
  self:DisableMiniIcon(enable)
  self:ShowMiniIcon()
end

function CookeryWiz:ShowMiniIcon()
  trace("ShowMiniIcon")
  local disabled = self:IsMiniIconDisabled()
  local stationInteractionMethod = self:GetStationInteractionMethod()
  local scene = SCENE_MANAGER:GetCurrentScene()
  
  if disabled then      
    if stationInteractionMethod ~= CW_STATION_INTERACTION_METHOD_REPLACE and scene == PROVISIONER_SCENE then
      local left = ZO_SharedRightPanelBackground:GetLeft() 
      local top = ZO_SharedRightPanelBackground:GetTop() 
      --d("-New left["..left.."], top["..top.."]")
      self.miniBar:PushPosition(left, top)
      self.miniBar:SetHidden(false)
      self.miniBar:DisableMove(true)
      self.miniBar:SetNormalTooltip()
    else
      self.miniBar:DisableMove(false)
      self.miniBar:PopPosition()
      self.miniBar:SetHidden(true)
      self.miniBar:SetDragTooltip()
    end
  else
    self.miniBar:DisableMove(false)
    self.miniBar:PopPosition()
    self.miniBar:SetHidden(false) 
    self.miniBar:SetDragTooltip()
  end

end

---------------------------------------------------------------------
-- Function: ReplaceCookeryWizPosition
--
-- This function replaces and resizes the CookeryWiz window. It is called
-- when CookeryWiz should be displayed when a cooking station is opened
---------------------------------------------------------------------
function CookeryWiz:ReplaceCookeryWizPosition()
  self:ShowMiniIcon()
    
  local scene = SCENE_MANAGER:GetCurrentScene()
  if self.provisionerReplaced and scene == PROVISIONER_SCENE then
  
    self:HookProvisionerCraftButton()
    
    -- do some adjusting
    if self:IsHidden() then
      self:HideWindow(false)
    end
    local data = {}
    data.isShrunk = self:IsShrunk()
    data.isShrinkDisabled = self:IsShrinkDisabled()
    data.isMiniIconDisabled = self:IsMiniIconDisabled()
    self:DisableShrink(true)
    self:SetIsShrunk(false)    
    self:Shrink()
    
    local ui = self:GetWindow()

    local height = ui:GetHeight()

    
    data.chatInsets = self:GetChatInsets()
    data.top = ui:GetTop()
    data.left = ui:GetLeft()
    
    data.height = ui:GetHeight()
    data.width = ui:GetWidth()
    data.chatEdgeEnabled = self:IsChatEdgeEnabled()
    self.normalWindowData = data
    
    self:SetChatInsets(64)
    if not data.chatEdgeEnabled then
      self:EnableChatEdge(true)
    end
    self.closeButton:SetHidden(true)
    --self.optionsButtonControl:SetHidden(true)
    -- move
    ui:ClearAnchors()
    ui:SetAnchor(TOPRIGHT, ZO_SharedRightPanelBackground, TOPRIGHT, -5, 5)
    ui:SetAnchor(BOTTOMLEFT, ZO_SharedRightPanelBackground, BOTTOMRIGHT, -1 * self.minWidthNormal, -40)
    ZO_SharedRightPanelBackground:SetHidden(true)
    
    -- because the window is a different size the scrollist may not have updated the contents to fit
    CookeryWizRecipeList:RefreshScrollList()    

  end
    
end

function CookeryWiz:RestoreCookeryWizPosition()
  
  --local disabled = self:IsMiniIconDisabled()
  --d(disabled)
  --self.miniBar:SetHidden(disabled)
  self:ShowMiniIcon()
  
  if self.normalWindowData then
    self:UnhookProvisionerCraftButton()
    local data = self.normalWindowData
    -- do some adjusting
    self:HideWindow(true)
    self:DisableShrink(data.isShrinkDisabled)
    self:SetChatInsets(data.chatInsets)
    self:SetIsShrunk(data.isShrunk)    
    self:Shrink()      
    
    --local ui = self:GetWindow()
    --ui:ClearAnchors()
    --ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, data.left, data.top) 
    --ui:SetAnchor(BOTTOMRIGHT, GuiRoot, TOPLEFT, data.left + data.width, data.top + data.height)
    self:EnableChatEdge(data.chatEdgeEnabled )
    self.closeButton:SetHidden(false)
    --self.optionsButtonControl:SetHidden(false)
    
    local scene = SCENE_MANAGER:GetCurrentScene()
    if scene == PROVISIONER_SCENE then    
      ZO_SharedRightPanelBackground:SetHidden(false)
    end
    self:OnEasyFrameResize()
    self.normalWindowData = nil
  end  
end

function CookeryWiz:OnEndCraftingStationInteract(eventCode)
  if self.isCookingStationOpen then
    -- 131346
    --d("Cooking station close interaction:event("..eventCode..")")
    self.isCookingStationOpen = false
    self:ResetCooking()   
    
    self.cookButtonControl:SetEnabled(false) 
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_CRAFT_COMPLETED)
    
    --self:HideWindow(false)
    self:RestoreProvisionerWindow()
    self:RestoreCookeryWizPosition()

    -- Close Cookerywiz at end crafting interaction if in display mode
    local stationInteractionMethod = self:GetStationInteractionMethod()
    if stationInteractionMethod == CW_STATION_INTERACTION_METHOD_DISPLAY then
      if not self:IsHidden() then
        self:HideWindow(true)
      end
    end
  end
end

local function doCraft()
  CookeryWiz:Craft()
end

---------------------------------------------------------------------
-- Function: GetTotalCraftCount
--
-- This function determines how many crating iterations will occur
-- in order to cook all items in the list
---------------------------------------------------------------------
function CookeryWiz:GetTotalCraftCount()
  local cookVars = self:GetCookVars()
  if not cookVars then
    return 0
  end
  
  local count = 0
  for cookIndex, cookEntry in pairs(cookVars) do
    local masterEntry = MRL:GetEntry(cookEntry.recipeId)
    if masterEntry then
      local stackCount = masterEntry:GetStackCount()
      local remainder =  cookEntry.quantity % stackCount
      local craftCount =  math.floor( cookEntry.quantity / stackCount)
      if remainder == 0 then
        --d("stack["..stackCount.."], remainder["..remainder.."], craft["..craftCount.."]")
        count = count + craftCount
      else
        --d("stack["..stackCount.."], remainder["..remainder.."], craft["..(craftCount + 1).."]")
        count = count + craftCount + 1
      end
    end
    
  end
  return count
end

---------------------------------------------------------------------
-- Function: InitCookTiming
--
-- This function initialises cooking time information. It is used to
-- estimate how long remains before all items are cooked
-- It is called when there is a change in items that are to be cooked
-- and when the cooking process is about to begin
---------------------------------------------------------------------
function CookeryWiz:InitCookTiming() 
  --d("Init Session")
  cookTiming.sessionStart = GetGameTimeMilliseconds()
  cookTiming.sessionCount = 0
  cookTiming.count = 0
  cookTiming.dummyDisplay = FormatTimeMilliseconds(cookTiming.dummyEstimation, TIME_FORMAT_STYLE_COLONS , TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
  cookTiming.sessionDisplay = nil
  cookTiming.sessionActual = nil
  cookTiming.craftCount = self:GetTotalCraftCount()
  --cookTiming.averageCook = 2400
  --if cookTiming.averageCook == 0 then
    -- From my system the average was ~2400
    --cookTiming.startTime = cookTiming.sessionStart - 2400
  --else
    cookTiming.startTime = cookTiming.sessionStart - cookTiming.averageCook
  --end

end

---------------------------------------------------------------------
-- Function: UpdateEstimation
--
-- This function estimates how long it will take to cook all items
-- in our list
-- It is called when there is a change in items that are to be cooked,
-- and every time we begin to craft each item in our order list
---------------------------------------------------------------------
function CookeryWiz:CalculateEstimations(startTime, count)
  --if not startTime then
    --startTime = cookTiming.startTime
  --end
  if not startTime then
    startTime = GetGameTimeMilliseconds() - 2400
    d("init start time to ["..startTime.."]")
  end
  if not count then
    count = 1
  end
  local cookTime = GetGameTimeMilliseconds() - startTime
  cookTiming.averageCook = (cookTiming.averageCook * (count - 1) + cookTime ) / count;
  cookTiming.craftItemTime = cookTiming.craftCount * (cookTiming.averageCook + cookTiming.averageDelay)  
  d("Average["..cookTiming.averageCook.."], CraftTime ["..cookTiming.craftItemTime.."], cook Time["..cookTime.."]")
end

---------------------------------------------------------------------
-- Function: UpdateDummyEstimation()
--
-- This function estimates how long it will take to cook all items
-- in our list. It is a dummy estimation that is used prior to actual
-- cooking
---------------------------------------------------------------------
function CookeryWiz:UpdateDummyEstimation()
  
  if self.currentlyCooking then
    -- do not update if cooking
    return
  end  
  local cookTime = GetGameTimeMilliseconds() - 2400
  local craftCount = self:GetTotalCraftCount()
  local craftItemTime = craftCount * (2400 + cookTiming.averageDelay)  

  self:UpdateEstimationDisplay(craftItemTime)
  cookTiming.dummyEstimation = craftItemTime
  return craftItemTime
end

---------------------------------------------------------------------
-- Function: UpdateEstimation
--
-- This function estimates how long it will take to cook all items
-- in our list
-- It is called when there is a change in items that are to be cooked,
-- and every time we begin to craft each item in our order list
---------------------------------------------------------------------
function CookeryWiz:UpdateEstimation()
--[[
 timeDisplay = FormatTimeMilliseconds(GetGameTimeMilliseconds(), TIME_FORMAT_STYLE_COLONS , TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)   
  d("Time["..GetGameTimeMilliseconds().."], Format["..timeDisplay.."]")
  ]]--
  cookTiming.count = cookTiming.count + 1
  
  local cookTime = GetGameTimeMilliseconds() - cookTiming.startTime
  cookTiming.averageCook = (cookTiming.averageCook * (cookTiming.count - 1) + cookTime ) / cookTiming.count;
  cookTiming.craftItemTime = cookTiming.craftCount * (cookTiming.averageCook + cookTiming.averageDelay)  
  --d("Avg["..math.floor(cookTiming.averageCook).."], CraftTime ["..math.floor(cookTiming.craftItemTime).."], CookTime["..math.floor(cookTime).."]")
  self:UpdateEstimationDisplay(cookTiming.craftItemTime)

  if not cookTiming.sessionDisplay then
    -- store the first predicted time
    cookTiming.sessionDisplay = FormatTimeMilliseconds(cookTiming.craftItemTime, TIME_FORMAT_STYLE_COLONS , TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING) 
    --d("Session Display ["..cookTiming.sessionDisplay.."]")
  end

  
end


---------------------------------------------------------------------
-- Function: UpdateEstimationDisplay
--
-- This function estimates how long it will take to cook all items
-- in our list
-- It is called when there is a change in items that are to be cooked,
-- and every time we begin to craft each item in our order list
---------------------------------------------------------------------
function CookeryWiz:UpdateEstimationDisplay(craftItemTime)
  local timeDisplay = FormatTimeMilliseconds(craftItemTime, TIME_FORMAT_STYLE_COLONS , TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
  self.timeRemainingLabel:SetText(timeDisplay)
end


function CookeryWiz.OnCraftCompleted(eventCode, craftSkill)

  local self = CookeryWiz
  -- we ignore any craft completed if we are not doing the crafting!
  if not self.currentlyCooking then
    --d("we are not cooking so ignore")
    return
  end
  
  local cookEntry = self.currentlyCooking
  -- 131442
  --d("craftSkill{"..craftSkill.."-PROV("..CRAFTING_TYPE_PROVISIONING.."),eventCode -"..eventCode)
  

    --Returns: string name, textureName icon, integer stack, integer sellPrice, boolean meetsUsageRequirement, integer equipType, integer ItemType itemType, integer itemStyle, integer quality, integer ItemUISoundCategory soundCategory, integer itemInstanceId 
    
  if craftSkill == CRAFTING_TYPE_PROVISIONING then
    trace("OnCraftCompleted - Provisioner["..eventCode.."]")
    self:UpdateFreeSpace()
    --[[
    local numItems, penaltyApplied = GetNumLastCraftingResultItemsAndPenalty()
    local penaltyString = "false"
    if penaltyApplied then
      penaltyString = "true"
    end
    d("Last Result - "..numItems.." "..penaltyString)
    local name, icon, stack = GetLastCraftingResultItemInfo(1)
    d("LastResult - "..name.." stack - "..stack) 
    ]]--
    
    self:UpdateEstimation()
    cookTiming.craftCount = cookTiming.craftCount - 1

    --cookTiming.startTime = GetGameTimeMilliseconds() --os.time()

    -- reduce the quantity
    --local cookEntry, masterEntry = self:GetFirstCookableEntry()
    --if cookEntry then
    local masterEntry = MRL:GetEntry(cookEntry.recipeId)
    cookEntry.quantity = cookEntry.quantity - masterEntry:GetStackCount()
    --d(masterEntry:GetRecipeName().." - New Cook Entry Quantity ["..cookEntry.quantity.."]")
    if cookEntry.quantity <= 0 then
      -- delete it and move on
      masterEntry:SetCookEntry(nil)
      self:DeleteCookEntry(cookEntry.recipeId)
      self:UpdateCookIngredients() 
      -- have to reload the recipes to potentially remove the finished items if quantity
      -- filter is active
      self:OnReloadRecipes(false)
    else
      masterEntry:UpdateCookEntry()
      
      local ingredients = masterEntry:GetIngredients()
      for i = 1, #ingredients do
        -- each object in array returned resembles the folowing:
        -- { entry = entryIngredient, quantity = amountRequired, stocked = stockedAmount}
        local ingredient = ingredients[i]
        local entry = ingredient.entry;
        
        --d("updating["..ingredient:GetName().."]")
        entry:SetCookQuantity(entry:GetCookQuantity()- ingredient.quantity)
      end
    end
    
     self.currentlyCooking = nil

    --self:OnReloadRecipes(true)
    --self:UpdateCookIngredients(masterEntry) 
    --zo_callLater(function() CookeryWiz:ScanMail() end, 500)
    zo_callLater(doCraft, math.random(300, 700))

  --end
  end

end

function CookeryWiz:DumpCookItems()
  local cookVars = self:GetCookVars()
  for cookIndex, cookEntry in pairs(cookVars) do
    d("cookIndex["..cookIndex.."]")
    d(cookEntry)
    local masterEntry = MRL:GetEntry(cookEntry.recipeId)
    if masterEntry then
      d(masterEntry:GetRecipeName())
    end
  end
end

function CookeryWiz:SetCookButtonTitle(isCooking)
  if isCooking then
    self.cookButtonControl:SetText(L[CWL_BUTTON_COOK_CANCEL])
    self:SetupTooltip(self.cookButtonControl, L[CWL_BUTTON_TOOLTIP_COOK_CANCEL])  
  else
    self.cookButtonControl:SetText(L[CWL_BUTTON_COOK])
    self:SetupTooltip(self.cookButtonControl, L[CWL_BUTTON_TOOLTIP_COOK])  
  end
 
end

-- This function performs the cooking process. It will use the first item to cook that is known
-- and that we have ingredients for
function CookeryWiz:Craft()
  
  if self.cancelCooking then
    d(L[CWL_NOTIFY_COOKING_CANCELLED])
    self:ResetCooking()
    return
  end
  
  -- we can only cook if we have an open cooking fire station!
  if not self.isCookingStationOpen then
    d("Cooking Station is not open")
    self:ResetCooking()
    return
  end
  
  -- get the first item that we can cook and have ingredients for
  -- of course there could still be entries that need cooking.. but we cannot do it
  local cookEntry, masterEntry = self:GetFirstCookableEntry()
  if not cookEntry then
    d(L[CWL_NOTIFY_NO_ITEMS_LEFT])
    local timeDisplay = FormatTimeMilliseconds(GetGameTimeMilliseconds() - cookTiming.sessionStart, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
    -- display stats
    --d("Dummy Prediction ["..cookTiming.dummyDisplay.."]")
    --d("Session Prediction ["..cookTiming.sessionDisplay.."]")
    --d("Session Actual ["..timeDisplay.."]")
    self:ResetCooking()
    return
  end

  -- shows an estimate of how long it will take to complete
  local cookVars = self:GetCookVars()
  cookTiming.totalItems = #cookVars;
  cookTiming.startTime = GetGameTimeMilliseconds()
  
--[[
  if true then
    self:ResetCooking()
    return
  end
    ]]--
  -- flag that we are cooking
  self.currentlyCooking = cookEntry
  --local notifyText = string.format(L[CWL_NOTIFY_CRAFTING], masterEntry:GetFoodResultName(), cookEntry.quantity) 
  --d(notifyText)
  
  --trace("Crafting "..masterEntry:GetRecipeListIndex().." ["..masterEntry:GetRecipeIndex().."]")
  -- change the provisioner tooltip
  local listIndex = masterEntry:GetRecipeListIndex()
  local recipeIndex = masterEntry:GetRecipeIndex()
  
  --ZO_ProvisionerTopLevelTooltip:ClearLines()
  self:OnSetProvisionerResultItem(ZO_ProvisionerTopLevelTooltip, listIndex, recipeIndex)
  CraftProvisionerItem(listIndex, recipeIndex)
  
end

---------------------------------------------------------------------
-- Provisioner tooltip functions
---------------------------------------------------------------------

CookeryWiz.fnSetProvisionerResultItem = nil

---------------------------------------------------------------------
-- Function: OnSetProvisionerResultItem
--
-- This function is called by the replacement function for the 
-- provisioner tooltip SetProvisionerResultItem
---------------------------------------------------------------------
function CookeryWiz:OnSetProvisionerResultItem(control, listIndex, recipeIndex)
  trace("SetProvisionerResultItem(listIndex="..listIndex..", recipeIndex="..recipeIndex..")")
  if not self.fnSetProvisionerResultItem then
    return
  end
  
  if self.currentlyCooking then
     -- { masterindex = masterRecipeIndex, quantity = entryQuantity, tag = entryTag }
    local masterEntry = MRL:GetEntry(self.currentlyCooking.recipeId) 
    local entryListIndex = masterEntry:GetRecipeListIndex()
    local entryRecipeIndex = masterEntry:GetRecipeIndex()
    if entryListIndex ~= listIndex or entryRecipeIndex ~= recipeIndex then
      listIndex = entryListIndex
      recipeIndex = entryRecipeIndex
    end
    control:ClearLines()
    if control:IsHidden() then
      control:SetHidden(false)
    end
  else
    if self:GetStationInteractionMethod() == CW_STATION_INTERACTION_METHOD_REPLACE then
      control:SetHidden(true)
    else
      control:SetHidden(false)
    end    
  end
  self.fnSetProvisionerResultItem(ZO_ProvisionerTopLevelTooltip, listIndex, recipeIndex)
end

---------------------------------------------------------------------
-- Function: CookeryWizHookToolTip
--
-- This function is is the replacement function for the provisioner
-- tooltip SetProvisionerResultItem
---------------------------------------------------------------------
local function CookeryWizHookToolTip(...)
  CookeryWiz:OnSetProvisionerResultItem(...)
end

---------------------------------------------------------------------
-- Function: HookProvisionerTooltip
--
-- This function is called to hook the provisioner tooltip 
-- SetProvisionerResultItem function so that when crafting we see
-- the correct crafted item
---------------------------------------------------------------------
function CookeryWiz:HookProvisionerTooltip()
  if not self.savedVariables.hookTooltip then
    trace("HookProvisionerTooltip not enabled")
    return
  end
  
  if ZO_ProvisionerTopLevelTooltip then
    ZO_ProvisionerTopLevelTooltip:ClearLines()
    self.fnSetProvisionerResultItem = ZO_ProvisionerTopLevelTooltip.SetProvisionerResultItem
    ZO_ProvisionerTopLevelTooltip.SetProvisionerResultItem = CookeryWizHookToolTip
  end    
end

---------------------------------------------------------------------
-- Function: UnHookProvisionerTooltip
--
-- This function is called to unhook the provisioner tooltip 
-- SetProvisionerResultItem function
---------------------------------------------------------------------
function CookeryWiz:UnHookProvisionerTooltip()
  if ZO_ProvisionerTopLevelTooltip then
    if self.fnSetProvisionerResultItem then
      ZO_ProvisionerTopLevelTooltip.SetProvisionerResultItem = self.fnSetProvisionerResultItem
      self.fnSetProvisionerResultItem = nil
    end
  end 
end

---------------------------------------------------------------------
-- Provisioner functions
---------------------------------------------------------------------

CookeryWiz.provisionerReplaced = false
CookeryWiz.normalWindowData = nil


CookeryWiz.fnCraftButtonCallback = nil
CookeryWiz.fnCraftButtonVisible = nil

---------------------------------------------------------------------
-- Function: HookProvisionerCraftButton
--
-- This function is called allow CookeryWiz to replace the default
-- functionality of the 'R' craft button for the provisioner station
---------------------------------------------------------------------
function CookeryWiz:HookProvisionerCraftButton()
  
  if not self.fnCraftButtonCallback then  
    -- hooked function
    local function craftCallback()
      --d("craftCallback")
      self:OnCookButtonClicked() 
    end
    local function craftVisible()
      return not self.currentlyCooking
    end
    
    if not PROVISIONER.mainKeybindStripDescriptor  then
      trace("No PROVISIONER keybind strip descriptor")
      return
    end

    self.fnCraftButtonCallback = PROVISIONER.mainKeybindStripDescriptor[1].callback
    self.fnCraftButtonVisible = PROVISIONER.mainKeybindStripDescriptor[1].visible
    PROVISIONER.mainKeybindStripDescriptor[1].callback = craftCallback
    PROVISIONER.mainKeybindStripDescriptor[1].visible = craftVisible
  end  
end

---------------------------------------------------------------------
-- Function: UnhookProvisionerCraftButton
--
-- This function is called allow CookeryWiz to restore the default
-- functionality of the 'R' craft button for the provisioner station
---------------------------------------------------------------------
function CookeryWiz:UnhookProvisionerCraftButton()
  
  if self.fnCraftButtonCallback then
    PROVISIONER.mainKeybindStripDescriptor[1].callback = self.fnCraftButtonCallback
    PROVISIONER.mainKeybindStripDescriptor[1].visible = self.fnCraftButtonVisible
    self.fnCraftButtonCallback = nil
    self.fnCraftButtonVisible = nil
  end 
end

---------------------------------------------------------------------
-- Function: ReplaceProvisionerWindow
--
-- This function is called allow CookeryWiz to replace the default
-- provisioner window
---------------------------------------------------------------------
function CookeryWiz:ReplaceProvisionerWindow()
  trace("ReplaceProvisionerWindow")
  
  if self:GetStationInteractionMethod() ~= CW_STATION_INTERACTION_METHOD_REPLACE then
    trace("ReplaceProvisionerWindow not enabled")
    return false
  end  
  
  if self.provisionerReplaced then
    trace("ReplaceProvisionerWindow is already replaced")
    return
  end
  
  --self.provisionerName = PROVISIONER.mainSceneName
  --PROVISIONER.mainSceneName = PROVISIONER.mainSceneName.."NoShow"

  --ZO_SharedRightPanelBackground
  self:HideDefaultProvisionerWindow(true)  
  self.provisionerReplaced = true
  self:ReplaceCookeryWizPosition()
end

function CookeryWiz:HideDefaultProvisionerWindow(hide)

  local children = ZO_ProvisionerTopLevel:GetNumChildren() 
  for i = 1, children do
    local child = ZO_ProvisionerTopLevel:GetChild(i)
    if child ~= ZO_ProvisionerTopLevelSkillInfo then
      child:SetHidden(hide)
    end
  end
  
end
---------------------------------------------------------------------
-- Function: RestoreProvisionerWindow
--
-- This function is called to restore the deafult provisioner window
---------------------------------------------------------------------
function CookeryWiz:RestoreProvisionerWindow()
  trace("RestoreProvisionerWindow")
  if not self.provisionerReplaced then
    trace("RestoreProvisionerWindow is already restored")
    return
  end

  --PROVISIONER.mainSceneName = self.provisionerName
  self.provisionerReplaced = false
  
  self:HideDefaultProvisionerWindow(false)  
  self:HideWindow(false)
  self:RestoreCookeryWizPosition()
  
end


function CookeryWiz:OnCookButtonClicked(control) 
  -- if we are crafting then we need to stop
  if self.currentlyCooking then
    self.cancelCooking = true
  else
    self:SetCookButtonTitle(true)
    self:InitCookTiming()
    self:Craft()
  end
end

function CookeryWiz:DumpCookIngredients()
  if self.ingredients then
    for key, ingredient in pairs(self.ingredients) do
      --d("-- Name :"..key.."["..ingredient.quantity.."]")
      trace(ingredient)
    end
  end
end


function CookeryWiz:GetIngredientEntry(name)

  for key, ingredientEntry in pairs(self.ingredients) do
    if ingredientEntry.data.name == name then
      return ingredientEntry
    end
  end  
end

-- UpdateProvisionerRecipeImprovement: updates the level of the provisioner Recipe Improvement skill
-- NOTE: Should be called when level of the provisioner skill changes
function CookeryWiz:UpdateProvisionerRecipeImprovement(playerName)
    if playerName ~= GetUnitName("player") then
      --trace("Can only update current player")
      return
    end
    -- we can only update the currently playing character!
    local characterVars =  self:GetPlayerCharacterVars(playerName)
    characterVars.provisionerRecipeImprovement = GetNonCombatBonus(NON_COMBAT_BONUS_PROVISIONING_LEVEL)
end

-- GetProvisionerRecipeImprovement: Returns the level of the provisioner Recipe Improvement skill
function CookeryWiz:GetProvisionerRecipeImprovement(playerName)
  if not playerName then
    playerName = self.selectedPlayerName
  end
  local characterVars =  self:GetPlayerCharacterVars(playerName)
  if not characterVars.provisionerRecipeImprovement then
    self:UpdateProvisionerRecipeImprovement(playerName)
  end
  if not characterVars.provisionerRecipeImprovement then
    return 1
  else
    return characterVars.provisionerRecipeImprovement
  end
end

-- UpdateProvisionerRecipeQuality: updates the level of the provisioner Recipe Quality skill
-- NOTE: Should be called when level of the provisioner skill changes
function CookeryWiz:UpdateProvisionerRecipeQuality(playerName)
    if playerName ~= GetUnitName("player") then
      --trace("Can only update current player")
      return
    end
    -- we can only update the currently playing character!
    local characterVars =  self:GetPlayerCharacterVars(playerName)
    characterVars.provisionerRecipeQuality = GetNonCombatBonus(NON_COMBAT_BONUS_PROVISIONING_RARITY_LEVEL)
end

-- GetProvisionerRecipeQuality: Returns the level of the provisioner Recipe Quality skill
function CookeryWiz:GetProvisionerRecipeQuality(playerName)
  if not playerName then
    playerName = self.selectedPlayerName
  end  
  local characterVars =  self:GetPlayerCharacterVars(playerName)
  if not characterVars.provisionerRecipeQuality then
    self:UpdateProvisionerRecipeQuality(playerName)
  end
  if not characterVars.provisionerRecipeQuality then
    --trace("returning provisionerRecipeQuality=1 for "..playerName)
    return 1
  else
    --trace("returning provisionerRecipeQuality=="..characterVars.provisionerRecipeQuality.." for "..playerName)
    return characterVars.provisionerRecipeQuality
  end  
end


function CookeryWiz:UpdateCookIngredients(masterRecipe)
  
  if self.disableIngredientUpdate then
    return
  end
  
  CookeryWizIngredients:UpdateCookIngredients(masterRecipe)
  
  -- update items to craft count
  
  self:UpdateDummyEstimation()
end

---------------------------------------------------------------------
-- Recipe Options Combo functions
---------------------------------------------------------------------

function CookeryWiz:OnEditLinkInitialized(control)
  self.editLinkControl = control
  self:SetupTooltip(control, L[CWL_EDIT_TOOLTIP_COPY_LINK])  
end

function CookeryWiz:OnEditLinkFocusLost(control)
  control:SetHidden(true)
end

function CookeryWiz:OnRecipeClickedLinkRecipe(menuEntry)
  trace("OnRecipeClickedLinkRecipe")
  local chatEditControl = CHAT_SYSTEM.textEntry.editControl
  if chatEditControl:HasFocus() == false then
    StartChatInput()
  end

  chatEditControl:InsertText(menuEntry.link)
end

function CookeryWiz:OnRecipeClickedLinkFood(menuEntry)
  trace("OnRecipeClickedLinkFood")
  local chatEditControl = CHAT_SYSTEM.textEntry.editControl
  if chatEditControl:HasFocus() == false then
    StartChatInput()
  end  

  chatEditControl:InsertText(menuEntry.link)
end

function CookeryWiz:OnRecipeClickedCookMaxFood(menuEntry)
  trace("OnRecipeClickedCookMaxFood")

  local masterEntry = menuEntry.masterEntry
  masterEntry.editAmountControl:SetText(masterEntry:CalculateCanCookQuantity())
end

function CookeryWiz:OnRecipeClicked(control, button)
  trace("OnRecipeClicked")
  
  local rowControl = control:GetParent()
  if not rowControl then
    trace("Problem getting rowControl")
    return
  end
  
  local masterEntry = rowControl.entry
  if not masterEntry then
    trace("Problem getting recipe from rowControl")
    return
  end
  
  if masterEntry.dataEntry.typeId == CW_RECIPE_CATEGORY_DATA_TYPE then
    return
  end
  
  local items = self.recipeOptionsDropdown:GetItems()
  
  local menuEntry = items[1]
  local link = masterEntry.rid  
  menuEntry.control = control
  menuEntry.index = 1
  menuEntry.link = link
  menuEntry.fnClick = self.OnRecipeClickedLinkRecipe
  
  menuEntry.name = string.format(L[CWL_MENU_ITEM_LINK_RECIPE_IN_CHAT], link)

  -- add the food menu item
  --link = masterEntry:GetFoodResultLinkStyle(LINK_STYLE_BRACKETS)  
  link = masterEntry:GetFoodResultLink() 
  menuEntry = items[2]
  menuEntry.control = control
  menuEntry.index = 2
  menuEntry.link = link
  menuEntry.name = string.format(L[CWL_MENU_ITEM_LINK_FOOD_IN_CHAT], link)  
  menuEntry.fnClick = self.OnRecipeClickedLinkFood
  
  -- add the cook maximum items link
  --link = masterEntry:GetFoodResultLinkStyle(LINK_STYLE_BRACKETS)
  link = masterEntry:GetFoodResultLink()   
  menuEntry = items[3]
  menuEntry.control = control
  menuEntry.index = 3
  menuEntry.link = link
  menuEntry.quantity = masterEntry:CalculateCanCookQuantity()
  menuEntry.name = string.format(L[CWL_MENU_ITEM_LINK_COOK_MAXIMUM], menuEntry.quantity, link)
  menuEntry.masterEntry = masterEntry
  menuEntry.fnClick = self.OnRecipeClickedCookMaxFood
    
  self.recipeOptionsComboBox:ClearAnchors()
  self.recipeOptionsComboBox:SetAnchor(LEFTTOP, control, LEFTTOP, 10) 
  self.recipeOptionsDropdown:ShowDropdown()
end

function CookeryWiz:OnRecipeOptionsComboInitialized(control)
  
  self.recipeOptionsComboBox = control
  self.recipeOptionsDropdown = ZO_ComboBox:New(control) 
  
  local function OnItemSelect(dropDown, name, menuEntry)
    trace("Selected "..name)
    menuEntry.fnClick(self, menuEntry)
  end
  
  -- Create placeholder menu items
  local recipeOptions = {"Link Recipe in Chat", "Link Food in Chat", "Cook Maximum Items"}
  
  self.recipeOptionsDropdown:ClearItems()
  self.recipeOptionsDropdown.cookeryWiz = self
  
  -- populate from available options
  for key, recipeOptionsData in pairs(recipeOptions) do      
      local entry = self.recipeOptionsDropdown:CreateItemEntry(recipeOptionsData, OnItemSelect)
      self.recipeOptionsDropdown:AddItem(entry)
  end  
end

---------------------------------------------------------------------
-- Function: OnFavouriteComboInitialized
--
-- This function initalizes and handles the population of the favourite
-- combo
---------------------------------------------------------------------


function CookeryWiz:OnFavouriteComboInitialized(control)
  self.favouriteComboBox = control
  self.favouriteDropdown = ZO_ComboBox:New(control) 
  self:SetupTooltip(control, L[CWL_COMBO_TOOLTIP_FILTER_FAVOURITE])
end


function CookeryWiz:OnFavouriteSelect(comboBox, name, item, selectionChanged)  
  self:SetFavouriteFilterIndex(item.iconIndex)
  self:RebuildMasterRecipeScrollList()
end

function CookeryWiz:GetFavouriteFilterIndex()
    return self.favouriteFilterIndex
end

function CookeryWiz:SetFavouriteFilterIndex(favouriteFilterIndex)
  self.favouriteFilterIndex = favouriteFilterIndex
end

function CookeryWiz:PopulateFavouriteDropDown()
  
  local dropdown = self.favouriteDropdown
  
  if not dropdown then
    d("No favourite Dropdown")
    return
  end
  
  local maxfavouriteTypes = self:GetMaxFavouriteTypes()
  
  dropdown:ClearItems() 
  
  for i = 0, maxfavouriteTypes do
    local textureFile = CookeryWizUtils:GetFavouriteTextureFile(i)
    self:AddFavouriteListItem(textureFile, i)
  end
  
  -- select the chosen icon
  dropdown:SelectItemByIndex(self:GetFavouriteFilterIndex())
end

function CookeryWiz:AddFavouriteListItem(textureFile, iconIndex)
  local icon = zo_iconTextFormat(textureFile, 16, 16)
  
  local entry = self.favouriteDropdown:CreateItemEntry(icon, function(...)
      self:OnFavouriteSelect(...)
    end)
  entry.iconIndex = iconIndex
  self.favouriteDropdown:AddItem(entry)  
end


---------------------------------------------------------------------
-- Filter Level Combo functions
---------------------------------------------------------------------
  
function CookeryWiz:OnFilterLevelComboInitialized(control)
  self.filterLevelComboBox = control
  self.filterLevelDropdown = ZO_ComboBox:New(control)
  self:SetupTooltip(control, L[CWL_COMBO_TOOLTIP_FILTER_LEVEL]) 
  self:PopulateFilterLevelDropDown()
end

function CookeryWiz:PopulateFilterLevelDropDown()
  local cookeryWiz = self
  
  if not self.filterLevelDropdown then
    d("No filter level Dropdown")
    return
  end
  
  local function OnItemSelect(dropDown, name, menuEntry)
    -- first, if All then there is no filter
    if name == L[CWL_FILTER_ALL] then
      cookeryWiz.selectedFilterLevel = nil
    else
      -- next split on '-'
      local separator = name:find("-", 1, true)

      local selectedLevel = {}
      local lowerString = name:sub(1, separator - 1)
      local upperString = name:sub(separator + 1)
      -- is it champion?
      if name:find("C", 1, true) == 1 then
        --d("Champion")
        --selectedLevel.veteran = true
        selectedLevel.champion = true
        selectedLevel.lower = tonumber(lowerString:sub(2))
        selectedLevel.upper = tonumber(upperString)

      else
        --d("Normal")
        selectedLevel.champion = false
        selectedLevel.lower = tonumber(lowerString)
        selectedLevel.upper = tonumber(upperString)
      end
      --d(selectedLevel)
      cookeryWiz.selectedFilterLevel = selectedLevel 
    end
    cookeryWiz:RebuildMasterRecipeScrollList()
    
  end
  
  self.filterLevelDropdown:ClearItems()
  
  -- populate from available options
  for i = 1, #filterLevelOptions do
  --for key, filterLevelData in pairs(filterLevelOptions) do      
      local filterLevelData = filterLevelOptions[i]
      local entry = self.filterDropdown:CreateItemEntry(filterLevelData, OnItemSelect)
      entry.filterIndex = i
      self.filterLevelDropdown:AddItem(entry)      
  end

  local items = self.filterLevelDropdown:GetItems()
  table.sort(items, function(a, b)
      return a.filterIndex < b.filterIndex
    end)
  
  self.filterLevelDropdown:SetSelectedItem(L[CWL_FILTER_ALL])
end

---------------------------------------------------------------------
-- Filter Combo functions
---------------------------------------------------------------------

function CookeryWiz:OnFilterComboInitialized(control)
  self.filterComboBox = control
  self.filterDropdown = ZO_ComboBox:New(control)
  self:SetupTooltip(control, L[CWL_COMBO_TOOLTIP_RECIPE_CATEGORY])
end


function CookeryWiz:PopulateFilterDropDown()
  local cookbook = self
  
  if not self.filterDropdown then
    d("No filter Dropdown")
    return
  end
  
  local function OnItemSelect(control, choiceText, choice)
    --d("Selected filter - "..choiceText)
    local self = cookbook
    
    self.selectedFilter = choiceText
    
    if self.selectedFilter == L[CWL_FILTER_ALL] then
      self.selectedFilterChoice = CW_FILTER_CHOICE_ALL
    elseif self.selectedFilter == L[CWL_FILTER_QUANTITY] then
      self.selectedFilterChoice = CW_FILTER_CHOICE_QUANTITY
    elseif self.selectedFilter == L[CWL_FILTER_KNOWN] then
      self.selectedFilterChoice = CW_FILTER_CHOICE_KNOWN
    elseif self.selectedFilter == L[CWL_FILTER_UNKNOWN] then
       self.selectedFilterChoice = CW_FILTER_CHOICE_UNKNOWN
    elseif self.selectedFilter == L[CWL_FILTER_INGREDIENT] then
      self.selectedFilterChoice = CW_FILTER_CHOICE_INGREDIENT
    elseif self.selectedFilter == L[CWL_FILTER_COOKABLE] then
      self.selectedFilterChoice = CW_FILTER_CHOICE_COOKABLE
    elseif self.selectedFilter == L[CWL_FILTER_FAVOURITES] then
      self.selectedFilterChoice = CW_FILTER_CHOICE_FAVOURITES        
    end      
    
    -- load the recipes
    self:OnReloadRecipes(true)
  end
  
  self.filterDropdown:ClearItems()
      
  -- populate from available options
  for key, filterData in pairs(filterOptions) do      
      local entry = self.filterDropdown:CreateItemEntry(filterData, OnItemSelect)
      self.filterDropdown:AddItem(entry)
  end

  self.filterDropdown:SetSelectedItem(L[CWL_FILTER_ALL])
end

---------------------------------------------------------------------
-- Character Combo functions
---------------------------------------------------------------------

function CookeryWiz:GetKnownRecipeCount(characterVars)
  local knownCount = 0
  
  -- Each entry in the characterVars.known table tells us the
  -- CookeryWizRecipeList index for it. Event though it is a number
  -- it has to be stored as an associative array as the numbers 
  -- stored are only a subset
   
  -- determine how many we know
  for key, entry in pairs(characterVars.known) do
    knownCount = knownCount + 1
  end

  return knownCount;
end

function CookeryWiz:UpdateSelectedPlayerKnownRecipeCount()
  local characterVars =  self:GetPlayerCharacterVars(self.selectedPlayerName)
  characterVars.knownCount = self:GetKnownRecipeCount(characterVars)
end

function CookeryWiz:PopulateCharacterDropDown()
  local cookbook = self
  
  if not self.characterDropdown then
    d("No Character Dropdown")
    return
  end
  
  local function OnItemSelect(control, choiceText, choice)
    --d("Selected character - "..choiceText)
    cookbook.selectedPlayerName = choice.characterName -- choiceText
    -- load the recipes
    cookbook:OnReloadRecipes(true)
  end
  
  self.characterDropdown:ClearItems()
  local selectedMenuItemText = nil
  
  -- populate from our stored list. The key of the list is the character name
  local characterName = GetUnitName("player")
  --local masterRecipeCount = MRL:GetCount()
  local masterRecipeCount = CookeryWizUtils:GetTotalRecipes() 
  for key, characterVars in pairs(self.savedVariables.characters) do   
    if characterVars.enabled or key == characterName then
      if not characterVars.knownCount then
        characterVars.knownCount = self:GetKnownRecipeCount(characterVars)
      end
      local recipeCount = characterVars.knownCount
      local menuText = "("..recipeCount.."/"..masterRecipeCount..")\t"..key
      local entry = self.characterDropdown:CreateItemEntry(menuText, OnItemSelect)
      entry.characterName = key
      self.characterDropdown:AddItem(entry)
      if self.selectedPlayerName == key then
        selectedMenuItemText = menuText
      end
    else
      if key == self.selectedPlayerName then
        self.selectedPlayerName = nil
      end
    end
  end

  if selectedMenuItemText then
    self.characterDropdown:SetSelectedItem(selectedMenuItemText)
  else
    self.characterDropdown:SelectFirstItem()
  end
end


function CookeryWiz:OnCharacterComboInitialized(control)  
  self.characterComboBox = control
  self.characterDropdown = ZO_ComboBox:New(control)
  
  self:SetupTooltip(control, L[CWL_COMBO_TOOLTIP_CHARACTER])
end

function CookeryWiz:OnPlayerDeactivated(eventCode)
  local characterName = GetUnitName("player")
  local characterVars =  self:GetPlayerCharacterVars(characterName)
  if not characterVars.enabled then
    characterVars.known = nil
  end
end

function CookeryWiz:RefreshCharacterKnowledge()
  local characterName = GetUnitName("player")
  local characterVars =  self:GetPlayerCharacterVars(characterName)
  
  
  --if characterVars.enabled then
    local known = {}
    local knownCount = 0
    

  MRL:Enumerate(function(recipeEntry)
      --local link = recipeEntry:GetFoodResultLink()
      if recipeEntry:IsKnown() then
        local recipeId = recipeEntry:ItemId()
        known[tostring(recipeId)] = recipeId
        knownCount = knownCount + 1
      end 
  end) 

    characterVars.known = known
    characterVars.knownCount = knownCount
    self.savedVariables.characters[characterName] = characterVars
  --end
end



function CookeryWiz:OnOptionsButtonInitialized(control)
  self.optionsButtonControl = control
  self:SetupTooltip(control, L[CWL_BUTTON_TOOLTIP_OPTIONS])

end

function CookeryWiz:OnOptionsButtonClicked(control)
  CookeryWizOptions:ShowDialog(self)
  --CookeryWizOptions:HideWindow(false)
  --CookeryWizOptionsUI:SetHidden(false)
end

function CookeryWiz:OnClearOrdersButtonInitialized(control)
  self.clearOrdersButtonControl = control
  control:SetText(L[CWL_BUTTON_CLEAR_ORDERS])
  self:SetupTooltip(control, L[CWL_BUTTON_TOOLTIP_CLEAR_ORDERS]) 
end

function CookeryWiz:OnClearOrdersButtonClicked(control)
    self.savedVariables.cook = {}
    self:OnReloadRecipes(false)
    CookeryWizIngredients:ClearCookIngredients()  
end

function CookeryWiz:OnEditSearchInitialized(control)
  self.searchControl = control
  control:SetText(L[CWL_FILTER_TEXT_BLANK])
  self:SetupTooltip(control, L[CWL_EDIT_TOOLTIP_SEARCH])
end

function CookeryWiz:OnEditSearchFocusLost(control)
  local text = control:GetText()
  if text == "" then
    control:SetText(L[CWL_FILTER_TEXT_BLANK])
  end 
end

function CookeryWiz:OnEditSearchFocusGained(control)
  local text = control:GetText()
  if text == L[CWL_FILTER_TEXT_BLANK] then
    control:SetText("")
  end 
end

function CookeryWiz:OnEditSearchChanged(control)
  --d(GetFormattedTime().."OnEditSearchChanged")
  local text = control:GetText()
  --control:CopyAllTextToClipboard() 
  if text == L[CWL_FILTER_TEXT_BLANK] then
    return
  end 
 
  text = string.lower(text)
  if self.filterText ~= text then
    self:ParseSearchFilter(text)
    self.filterText = text
    self:OnReloadRecipes(false)
  end  
end

function CookeryWiz:OnEditAmountInitialized(control)
  control:SetTextType(TEXT_TYPE_NUMERIC_UNSIGNED_INT) 
end

function CookeryWiz:OnEditAmountChanged(control) 

  -- the data entry item has been associated with the row control
  local rowControl = control:GetParent()
  local entry = rowControl.entry
  
  -- not initialised yet or hidden
  if not entry then
    return
  end


  local currentAmount = 0
  local amount
  local text = control:GetText()
  
  if not text or text == "" then
    amount = 0
  else
    amount = tonumber(text)
  end

  local cook = entry:GetCookEntry()

  if cook then
    currentAmount = cook.quantity
  end
  
  if currentAmount == amount then
    --d("currentamount("..currentAmount..") equals amount("..amount..") so exiting")
    return
  end
  
  --d("currentamount("..currentAmount..") amount("..amount..") ")
  -- do we delete it?
  if amount == 0 then
    if cook then
      entry:SetCookEntry(nil)
      self:DeleteCookEntry(entry:ItemId())
    end
  else
    -- no we change it
    if not cook then
      cook = self:CreateCookEntry(entry:ItemId(), amount, "test")
      entry:SetCookEntry(cook)
    else
      cook.quantity = amount
    end
  end
  --d("Updating cook Ingredients from edit")
  self:UpdateCookIngredients()
  
end


function CookeryWiz:ExtractQuestItems(conditionText)
    local craftItem = nil
    trace("ExtractQuestItems:conditionText:"..conditionText)
    local conditionTextLower = conditionText:lower()
    
    --d("ExtractQuestItems '"..conditionTextLower.."'")
    --d("Find '"..self.provisionWritStartTextLower.."'")
    local startIndex = self.provisionWritStartTextLower:len() + 2
    if conditionTextLower:find(self.provisionWritStartTextLower) == 1 then
      local colonIndex = conditionText:find(":")
      craftItem = conditionText:sub(startIndex, colonIndex - 1)
      trace("ExtractQuestItems:craftItem:"..craftItem)
    else
      --d("did not find text")
    end
    return craftItem
end

function CookeryWiz:DeleteCookEntry(recipeId)
  if not self.savedVariables.cook then
    self.savedVariables.cook = {}
  end
  local cookVars = self.savedVariables.cook
  local foundIndex
  
  for cookIndex, cookEntry in pairs(cookVars) do
    if cookEntry.recipeId == recipeId then
      --d("Matched recipe. Cook index "..cookIndex)
      foundIndex = cookIndex
      break
    end
  end 
  
  if foundIndex then
    --d("Found index and deleting")
    cookVars[foundIndex] = nil
  end
 
end

function CookeryWiz:CreateCookEntry(recipeId, entryQuantity, entryTag)
  
  --determine ingredient requirements  
  if not self.savedVariables.cook then
    self.savedVariables.cook = {}
  end
  
  local cook = self.savedVariables.cook  
  local entry = nil
  
  if entryQuantity ~= 0 then
    entry = self:GetCookEntry(recipeId)
    if not entry then
      entry = { recipeId = recipeId, quantity = entryQuantity, tag = entryTag }
      cook[#cook + 1] = entry
    end
  end
  return entry
end



function CookeryWiz:AddItemEntryToCraft(masterEntry, quantity, tag)
  
  if not self.savedVariables.cook then
    self.savedVariables.cook = {}
  end
  
  local cookVars = self.savedVariables.cook
  local cook = self:GetCookEntry(masterEntry:ItemId())
  
  if not cook then
    --d("AddItemEntryToCraft - no cook "..quantity.."'")
    cook = self:CreateCookEntry(masterEntry:ItemId(), quantity, tag)
  else     
    local amount = cook.quantity
    if not amount or amount == "" then
      amount = 0
    end
    --d("AddItemEntryToCraft - entry "..amount + quantity.."'")
    cook.quantity = amount + quantity
    if cook.tag then
      cook.tag = cook.tag..", "..tag     
    else    
      cook.tag = tag
    end
  end
  local fid = masterEntry:GetFoodResultLink()
  --CookeryWizUtils:SendToChat(fid)
  d(string.format(L[CWL_NOTIFY_WRIT_FOOD_ADDED], self.name, fid))  
  --d("CookeryWiz Adding Writ Food - "..masterEntry:GetFoodResultName())
  self:UpdateCookIngredients()
end


function CookeryWiz:AddItemToCraft(masterEntry, quantity, tag)
  
  if masterEntry then
    return self:AddItemEntryToCraft(masterEntry, quantity, tag)
  end
end

function CookeryWiz:AddItemNameToCollect(foodName, quantity, tag)
  
  local masterEntry = MRL:GetEntryByFoodName(foodName)
  if masterEntry then
    trace("Found masterentry for "..foodName)
    self:AddItemLinkToCollect(masterEntry:GetFoodResultLink(), quantity, tag)
  end
  return masterEntry
end

function CookeryWiz:AddItemLinkToCollect(link, quantity, tag)
  trace("Adding "..link.." to collect")
  self.writItems[#self.writItems + 1] = link
end

function CookeryWiz:OnRecipeLearned(eventCode, recipeListIndex, recipeIndex, other)
  local known, foodName, numIngredients, provisionerLevelReq, qualityReq, specialIngredientType, requiredCraftingStationType = GetRecipeInfo(recipeListIndex, recipeIndex)
  
  if requiredCraftingStationType ~= CRAFTING_TYPE_PROVISIONING then
    return
  end
  
  d(string.format(L[CWL_NOTIFY_RECIPE_LEARNT], self.name))

  --d("recipeListIndex["..recipeListIndex.."],recipeIndex["..recipeIndex.."]")
  local quality = ITEM_QUALITY_MAGIC
  local entry = MRL:UpdateRecipeListIndex(recipeListIndex, recipeIndex)
  if not entry then
    d("Failed updating recipe entry "..recipeListIndex.." "..recipeIndex)
  else
    -- celebrate it!
    quality = entry:GetFoodResultQuality()
  end  
  
  self:Celebrate(quality)   
  
  self:RefreshCharacterKnowledge()
  self:UpdateSelectedPlayerKnownRecipeCount()
  self:PopulateCharacterDropDown()  
end

function CookeryWiz:QualityChanged(currentQuality)
  trace("QualityChanged")
  self.currentQuality = currentQuality
  self:OnReloadRecipes(false)
end

CookeryWiz.burst1 = nil
CookeryWiz.burst2 = nil

local function onCelebrateEnd(animation, control)
  local parent = control:GetParent()
  --d("Name:"..control:GetName())
  if parent and parent.iconBar then
    local alpha = parent.iconBar:GetIconAlphaMin() 
    --d("Restoring alpha")
    control:SetAlpha(alpha)
  end
end

CookeryWiz.normalPulseColor = nil

---------------------------------------------------------------------
-- Function: Celebrate
--
-- This function triggers the celebrate animation
---------------------------------------------------------------------
function CookeryWiz:Celebrate(quality)
  -- SetGradientColors(integer orientation, number startR, number startG, number startB, number startA, number endR, number endG, number endB, number endA)
  
  local miniBar = self:GetMiniBar()
  if miniBar and not miniBar:IsHidden() then
    local mainIcon = miniBar:GetMainIcon()
    if mainIcon then
      EasyFrameUtils:ConstructHighlightAnimation(mainIcon, onCelebrateEnd)
      local pulseTexture = mainIcon:GetNamedChild("PulseTexture")
      if pulseTexture then
        --d(pulseTexture)
        self.pulseTexture = pulseTexture
        local burst1 = pulseTexture:GetNamedChild("Burst1")
        if burst1 then
          if not self.normalPulseColor then
            self.normalPulseColor = ZO_ColorDef:New(burst1:GetColor())
          end
          local burst2 = pulseTexture:GetNamedChild("Burst2")
          self.burst1 = burst1
          self.burst2 = burst2          
          
          if quality == nil or quality < ITEM_QUALITY_TRASH or quality > ITEM_QUALITY_LEGENDARY then
            --d("Quality nil")
            burst1:SetTexture("/esoui/art/crafting/burst_blue.dds")
            burst1:SetColor(self.normalPulseColor:UnpackRGB())
          else
            --d("Quality good")
            local colorDef = ZO_ColorDef.FromInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, quality)
            burst1:SetTexture("/esoui/art/crafting/white_burst.dds")
            burst1:SetColor(colorDef:UnpackRGB()) 
          end
          
          --local filename, addressMode, blendMode, desaturation, left, right, top, bottom, r, g, b, a, pixelWidth, pixelHeight = burst1:GetTextureInfo()
          --d("filename["..filename.."]")
        else
          d("No Burst1")
        end
      else
        d("No PulseTexture")
      end
      -- now play!
      mainIcon:SetAlpha(1)
      EasyFrameUtils:PlayHighlightAnimation(mainIcon)
    else
      d("No mainIcon")
    end
  end   
end

---------------------------------------------------------------------
-- Function: GetIconCount
--
-- This function returns the number of knowledge icon variations
---------------------------------------------------------------------
function CookeryWiz:GetIconCount()
  return self.savedVariables.iconCount
end

---------------------------------------------------------------------
-- Function: SetIconCount
--
-- This function sets the number of knowledge icon variations
---------------------------------------------------------------------
function CookeryWiz:SetIconCount(iconCount)
  if not iconCount then
    iconCount = 2
  end
  self.savedVariables.iconCount = iconCount
  return iconCount
end

---------------------------------------------------------------------
-- Function: MissingRecipes
--
-- This function the saved variables file with missing recipes
---------------------------------------------------------------------
function CookeryWiz:MissingRecipes(processIngredients)

  d("Processing missing recipes")
  
  -- To process all possible recipes, pass no parameters. It will start from 45000 and
  -- keep going until it has discovered the total number of recipes as reported by the game

  a = CookeryWizMissingRecipes()

  -- You can start from a specific id, but if you do so then you MUST pass the number of recipes
  -- to find. Getting this wrong can keep it going way beyond what it should. There is a fail safe
  -- built in which will stop processing after a nominated amount of time. This defaults to 5 minutes

  -- Enable extra debug output to show recipes found and other status information
  a:SetTraceEnabled(true)

  -- Show how long it takes to process
  a.showMetrics = true

  -- You can speed it up by setting the max number of iteration per timer event. 100 is default
  -- If set too hight it can lock up you game so use cautiously!
  a:SetMaxLoopCounter(200)

  -- If you do not want it to exceed a max id, set it as below
  -- NOTE: 96968 was the last max recipe prior to morrowwind
  --a:SetMaxId(96968)

  -- To save the results to the saved variables file call Save to set a variable name prior to begin
  a:Save("MissingRecipes")

  if processIngredients then
    a.OnFinished = function()
      CookeryWiz:MissingIngredients(a.recipeInfo)
    end
  end

  a:Begin()
end


---------------------------------------------------------------------
-- Function: MissingIngredients
--
-- This function updates the saved variables file with missing ingredients
-- It needs to be called after MissingRecipes has been called and updated
-- in the main lua file
---------------------------------------------------------------------
function CookeryWiz:MissingIngredients(data)

  d("Processing missing ingredients")
  
  if not data then
    data = CookeryWizRecipeList:GetRecipeData()
  end
  
  -- Start by creating an object of this type and passing the recipe info
  -- It can be existing recipes or just those found via CookeryWizMissingRecipes

  local i = CookeryWizMissingIngredients(data)

  -- There is a fail safe built in which will stop processing after a nominated amount of time. This defaults to 5 minutes

  -- Enable extra debug output to show ingredient found and other status information
  CookeryWizMissingIngredients.traceEnabled = true

  -- Show how long it takes to process
  i.showMetrics = true

  -- You can speed it up by setting the max number of iteration per timer event. 100 is default
  -- If set too hight it can lock up you game so use cautiously!
  i:SetMaxLoopCounter(200)

  -- To save the results to the saved variables file, call Save to set a variable name prior to begin
  i:Save("MissingIngredients")

  i:Begin()
end

function CookeryWiz:RegisterSlashCommands()
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
      
      if(arg == "" or arg == nil or #arg == 0 or arg==L[CWL_CHAT_OPTION_TOGGLE]) then
        --Use your toggle function here or maybe this wil work too
        if self:IsHidden() then
          self:HideWindow(false, true)
        else
          self:HideWindow(true, true)
        end
        --self:ToggleWindow()
        handled = true
      elseif arg==L[CWL_CHAT_OPTION_SHOW] then
        self:HideWindow(false, true)
        handled = true
      elseif arg==L[CWL_CHAT_OPTION_HIDE] then
        self:HideWindow(true, true)
        handled = true
      elseif arg==L[CWL_CHAT_OPTION_RESET] then
        self:ResetVariables()
        d("Saved variables have been reset. Please /reloadui or login again.")
        ReloadUI()
        handled = true
      elseif arg==L[CWL_CHAT_OPTION_FETCH_DELAY] then
        if #args > 1 then
          local delay = args[2]
          delay = CookeryWizBank:SetFetchDelay( tonumber(delay) )
          self.savedVariables.fetchDelay = delay
          local text = string.format(L[CWL_CHAT_OPTION_FETCH_DELAY_SET], delay)
          d(text)
          handled = true
        end
      elseif arg==L[CWL_CHAT_OPTION_ICON_COUNT] then
        if #args > 1 then
          local iconcount = args[2]
          iconcount = self:SetIconCount( tonumber(iconcount) )
          local text = string.format(L[CWL_CHAT_OPTION_ICON_COUNT_SET], iconcount)
          d(text)
          handled = true
        end        
      elseif arg==L[CWL_CHAT_OPTION_CELEBRATE] then
        if #args > 1 then
          local quality = args[2]
          quality = tonumber(quality)
          if quality and quality >= ITEM_QUALITY_MAGIC and quality <= ITEM_QUALITY_LEGENDARY then
          else
            d("Invalid quality")
          end
        else
          d("Quality not specified")          
        end
      elseif arg==L[CWL_CHAT_OPTION_MISSING_RECIPES] then
        self:MissingRecipes()
        handled = true
      elseif arg==L[CWL_CHAT_OPTION_MISSING_INGREDIENTS] then
        self:MissingIngredients()
        handled = true
      elseif arg==L[CWL_CHAT_OPTION_UPDATE_MISSING] then
        self:MissingRecipes(true)
        handled = true
      else
        handled = false
      end
      
      if handled == false then
        d(L[CWL_CHAT_OPTION_INVALID])
      end
  end
          
  SLASH_COMMANDS["/cw"]           = command_handler
  SLASH_COMMANDS["/cookerywiz"]   = command_handler
end




function CookeryWiz:DumpSlotItem(itemData)
  for dataName, dataValue in pairs(itemData) do      
    d(dataName)
    if dataName == "slotIndex" then
      d(" slotIndex-"..dataValue)
    end
    if dataName == "bagId" then
      d(" bagId-"..dataValue)
    end  
    if dataName == "uniqueId" then
      d(" uniqueId-"..dataValue)
    end
    if dataName == "itemInstanceId" then
      d(" itemInstanceId-"..dataValue)
    end    
  end  
end

---------------------------------------------------------------------
-- CookeryWizGuildBank events and related functions
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Function: OnPrepareForGuildBank
--
-- This function is called when the guild bank is opened. It gives
-- us a chance to setup the items to be fetched.
-- The collect food control is passed so that we can (optionally) 
-- position it from saved data.
---------------------------------------------------------------------
function CookeryWiz:OnPrepareForGuildBank(control, guildId)
  trace("CookeryWiz:OnPrepareForGuildBank")
  CookeryWizWritQuest:Rescan()
end

---------------------------------------------------------------------
-- Function: OnPositionGuildBankOptionsControl
--
-- The collect food control is passed so that we can
-- position it from saved data.
---------------------------------------------------------------------
function CookeryWiz:OnPositionGuildBankOptionsControl(control)
  trace("OnPositionGuildBankOptionsControl")
  local vars = self.savedVariables
  if vars.collectControlPosition then
    control:ClearAnchors()
    trace("left["..vars.collectControlPosition.left.."], top["..vars.collectControlPosition.top.."]")
    control:SetAnchor(TOPLEFT, nil, TOPLEFT, vars.collectControlPosition.left, vars.collectControlPosition.top) 
  end  
end

---------------------------------------------------------------------
-- Function: OnPrepareForBank
--
-- This function is called when the bank is opened. It gives
-- us a chance to setup the items to be fetched.
---------------------------------------------------------------------
function CookeryWiz:OnPrepareForBank(control)
  trace("CookeryWiz:OnPrepareForBank")
  CookeryWizWritQuest:Rescan()  

end

---------------------------------------------------------------------
-- Function: OnItemFetched
--
-- This function is called when the item has been fetched or failed
-- to be fetched. 'fetched' is true if it was successful
---------------------------------------------------------------------
function CookeryWiz:OnItemFetched(item, fetched)
  if fetched then
    local display = item.link
    if not item.link then
      display = item.name
    end    
    d(string.format(L[CWL_NOTIFY_FOOD_COLLECTED], self.name, display))
  end
  for i = 1, #self.bankFood do
    if self.bankFood[i].id == item.id then
      self.bankFood[i] = nil
      return
    end
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
function CookeryWiz:OnItemToFetch()
  trace("CookeryWiz:OnItemToFetch")
  local item = nil
  -- do food
  if self.bankFood and #self.bankFood > 0 then
    item = self.bankFood[#self.bankFood]
    trace("Fetching "..item.link)
  end

  return item
end

---------------------------------------------------------------------
-- Function: OnCollectWritFoodControlMoved
--
-- This function is called when the control is moved. It's only real
-- purpose is to allow you to save the position
---------------------------------------------------------------------
function CookeryWiz:OnCollectWritFoodControlMoved(control)
  local vars = self.savedVariables
  vars.collectControlPosition = { left = control:GetLeft(), top = control:GetTop()}
  trace("left["..vars.collectControlPosition.left.."], top["..vars.collectControlPosition.top.."]")
end

---------------------------------------------------------------------
-- Function: SetupBankFood
--
-- This function is a helper function and is called to
-- setup the table of food to collect.
-- We check to see if there is any writ food, and if there is
-- we construct a table of items that will be progressively
-- collected by CookeryWizGUildBank in the OnItemToFetch
-- routine
---------------------------------------------------------------------
function CookeryWiz:SetupBankFood()
  trace("CookeryWiz:SetupBankFood")
 -- now do we have items to collect?
  local writFood = self.writItems
  
  if not writFood then
    trace("Finished with bank as no writ food to collect.")
    return false
  end
      
  self.bankFood = {}
  
  -- go through and determine what we need to collect
  trace(#writFood.." writ items to collect")
  for i = 1, #writFood do
    local fid = writFood[i]
    -- do we have it in our backpack?
    local stackCountBackpack, stackCountBank = GetItemLinkStacks(fid)
    if stackCountBackpack == 0 then
      trace("No food in backpack. Could be in (guild)bank. Should fetch "..fid)
      self.bankFood[#self.bankFood + 1] = { count = 1, link = fid}
    else
      trace("Food is in backpack. Don't collect")
    end
  end  

  -- do we need to process?
  CookeryWizGuildBank:Enable(#self.bankFood > 0)

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
function CookeryWiz:OnWritQuestReset(questType)
  trace("CookeryWiz:OnWritQuestReset["..questType.."]")

  if questType == self.questTypeProvisioning then  
    self.writItems = {}
  end
end

---------------------------------------------------------------------
-- Function: OnExtractQuestItems
--
-- This function is called when a writ quest is being parsed. The 
-- line is passed to this routine (with quantity extracted), along with the 
-- quantity
-- It is up to this routine to find a match, however it can.
-- If a match is found, then it should return the correct text
---------------------------------------------------------------------
function CookeryWiz:TestQuestExtract(questLine, debugId, lang)  
  if not lang then
    lang = "de"
  end
  local item = self:OnExtractQuestItems(self.questTypeProvisioning, questLine, lang, debugId)
  d(item)
end

---------------------------------------------------------------------
-- Function: OnExtractQuestItems
--
-- This function is called when a writ quest is being parsed. The 
-- line is passed to this routine (with quantity extracted), along with the 
-- quantity
-- It is up to this routine to find a match, however it can.
-- If a match is found, then it should return the correct text
---------------------------------------------------------------------
function CookeryWiz:OnExtractQuestItems(questType, questLine, lang, debugId)
  if questType == self.questTypeProvisioning then  
    local match = nil
    local startIndex, endIndex
    

  local questLineConstructor = "craft <<1>>"

  -- localization for questLineConstructor
  -- MUST BE LOWERCASE! Hargraven's Tonic in FR was failing
  if lang == "en" then
      questLineConstructor = "craft <<1>>"
  elseif lang == "de" then
      questLineConstructor = "stellt einen <<1>> her"
  elseif lang == "fr" then
      questLineConstructor = "préparez un <<1>>"
  end  
  

    -- enumerate through our recipes. We have to go through ALL
    -- recipes as we could match more than one. The longest food name
    -- will be the correct match
    
    CookeryWizRecipeList:Enumerate(function(recipeEntry)
        --local link = recipeEntry:GetFoodResultLink()
        -- we only need to look at green recipes
        if recipeEntry:GetFoodResultQuality() ~= ITEM_QUALITY_MAGIC then
          return
        end
        
        local foodName = GetItemLinkName(recipeEntry:GetFoodResultLink())
        
--        local foodName = recipeEntry:GetFoodResultName()
--        local lowerFoodName = foodName:lower()
        
        -- let zo_strformat do all it's locaization magic
        -- NOTE: Have to use foodname that still has control characters and make lowercase last so that captital control
        -- codes are not converted.
        local thisRecipeQuestLine = zo_strformat(questLineConstructor, foodName):lower()


        local lowerFoodName = recipeEntry:GetFoodResultNameLower()
        if debugId then
          if recipeEntry:GetFoodId() == debugId then
            d("foodName: "..foodName..", lowerFoodName: "..lowerFoodName)  
            d("line: "..thisRecipeQuestLine)          
            d("questline: "..questLine)   
          end
        end
  
        if questLine == thisRecipeQuestLine then
          if match then
            -- if we already have a match, then we only change if name of this recipe we are checking is larger
            -- eg chicken breast 
            local len = lowerFoodName:len()
            if len > match:GetFoodResultNameLower():len() then
              match = recipeEntry
            end
          else
            match = recipeEntry
          end                    
        end        
    end)
  
    if match then
      return match:GetFoodResultNameLower(), match
    else
      d("Unable to resolve item to cook from ["..questLine.."]")
    end
    
    return nil
  end  
end

function CookeryWiz:OnExtractQuestItemsOld(questType, questLine, lang)
  if questType == self.questTypeProvisioning then  
    local match = nil
    local startIndex, endIndex
    
    if lang == "en" then
      -- no fixups
    elseif lang == "de" then
      -- fix up       
      startIndex, endIndex = questLine:find("arenthischen branntwein", 1, true)
      if startIndex then
        questLine = "arenthischer branntwein"
      else
        startIndex, endIndex = questLine:find("khenarthis beflÃ¼gelnden chai", 1, true)
        if startIndex then
          questLine = "khenarthis beflÃ¼gelnder chai"
        else
          startIndex, endIndex = questLine:find("eltherischen fusel", 1, true)
          if startIndex then
            questLine = "eltherischer fusel"
          --else
            --startIndex, endIndex = questLine:find("khenarthis beflÃ¼gelnden chai", 1, true)
          end
        end
      end
    elseif lang == "fr" then

    end
  
  
    -- enumerate through our recipes. We have to go through ALL
    -- recipes as we could match more than one. The longest food name
    -- will be the correct match
    CookeryWizRecipeList:Enumerate(function(recipeEntry)
        --local link = recipeEntry:GetFoodResultLink()
        -- we only need to look at green recipes
        if recipeEntry:GetFoodResultQuality() ~= ITEM_QUALITY_MAGIC then
          return
        end
        
        --local display = zo_strformat("<<1>>", recipeEntry:GetFoodResultNameLower())
        local lowerFoodName = recipeEntry:GetFoodResultNameLower()
        if lowerFoodName then          
          startIndex, endIndex = questLine:find(lowerFoodName, 1, true)
          --if recipeEntry.index == 345 then
            --d("Finding "..lowerFoodName.." in ["..questLine.."]") 
          --end
          if startIndex then
            --d("Found a match!")
            if match then
              -- if we already have a match, then we only change if name of this recipe we are checking is larger
              -- eg chicken breast 
              local len = lowerFoodName:len()
              if len > match:GetFoodResultNameLower():len() then
                match = recipeEntry
              end
            else
              match = recipeEntry
            end
          end          
        else
          d("Failed getting lowercase foodname from "..recipeEntry:GetFoodResultLinkStyle(LINK_STYLE_BRACKETS))
        end
        

    end)
  
    if match then
      --d("Matched ["..match:GetFoodResultNameLower().."]")
      return match:GetFoodResultNameLower(), match
    else
      d("Unable to resolve item to cook from ["..questLine.."]")
    end
    
    return nil
  end  
end
---------------------------------------------------------------------
-- Function: OnWritItemAdded
--
-- This function is called when a writ quest item is parsed from the
-- text. It is called with the name of the item
-- We should know what type of item we are looking for to convert to
-- link. In this case, food.
---------------------------------------------------------------------
function CookeryWiz:OnWritItemAdded(questType, itemName, itemQuantity, questAdded, entry)
  trace("CookeryWiz:OnWritItemAdded["..questType.."], item["..itemName.."], quantity["..itemQuantity.."]")
  
  if questType == self.questTypeProvisioning then
    -- find item
    trace("looking for food in <"..itemName..">")
    local masterEntry = entry
    if not entry then
      masterEntry = CookeryWizRecipeList:ResolveFoodInText(itemName)    
    else
      --d("Entry has been passed")
    end
    if masterEntry then
      self:AddItemLinkToCollect(masterEntry:GetFoodResultLink(), itemQuantity, GetUnitName("player")) 
      if questAdded then
        self:AddItemToCraft(masterEntry, itemQuantity, GetUnitName("player"))       
      end
    else
      d("Unable to resolve item to cook["..itemName.."]")
    end
  end

end

---------------------------------------------------------------------
-- Function: AddTestItems
--
-- This function is called to add additional food to grab from
-- the bank. You can hard code test food here, or overwrite in a test
-- environment. A simple array of foods would not provide the more
-- complex behaviour
-- eg
--  CookeryWiz.AddTestItems = function(this) {
--    this.
-- }
--
---------------------------------------------------------------------
function CookeryWiz:AddTestItems()
  trace("CookeryWiz:AddTestItems")

end

---------------------------------------------------------------------
-- Function: OnWritQuestItemsComplete
--
-- This function is called when the items from a writ quest have been
-- extracted
---------------------------------------------------------------------
function CookeryWiz:OnWritQuestExtractionComplete(questType)
  trace("CookeryWiz:OnWritQuestExtractionComplete["..questType.."]")
  
  self:AddTestItems()
  
  if questType == self.questTypeProvisioning then
    self:SetupBankFood() 
  end
end

---------------------------------------------------------------------
-- Function: OnWritQuestComplete
--
-- This function is called when the items for the given writ quest
-- have been collected
---------------------------------------------------------------------
function CookeryWiz:OnWritQuestComplete(questType)
  trace("CookeryWiz:OnWritQuestComplete["..questType.."]")
  if questType == self.questTypeProvisioning then
    self.writItems = {}
    self:OnReloadRecipes(true) 
  end
end

---------------------------------------------------------------------
-- CookeryWizStockpiles events
---------------------------------------------------------------------
---------------------------------------------------------------------
-- Function: OnStockpilesGetSavedVariables
--
-- This function is called when the CookeryWizStockpiles object wants
-- the saved variables object to use. It will store data under the
-- key "stockpiles'
---------------------------------------------------------------------
function CookeryWiz:OnStockpilesGetSavedVariables(itemType)
  trace("CookeryWiz:OnStockpilesGetSavedVariables["..itemType.."]")
  if itemType == ITEMTYPE_INGREDIENT then
    return self.savedVariables
  end
end

---------------------------------------------------------------------
-- Function: OnStockpilesLoaded
--
-- This function is called when the CookeryWizStockpiles object has
-- populated its data from the saved variables file. Create items
-- all items of this type here
---------------------------------------------------------------------
function CookeryWiz:OnStockpilesLoaded(callback)
  trace("CookeryWiz:OnStockpilesLoaded["..callback.itemType.."]")
  if callback.itemType == ITEMTYPE_INGREDIENT then
    --if dataCollection.count == 0 then
      -- set the ingredients
      CookeryWizIngredients:Enumerate(function(ingredient)
        CookeryWizStockpiles:CreateStockpile(callback, ingredient:GetItemId(), ingredient:GetQuality(), ingredient:GetLevel())
      end)
    --end
  end
end

---------------------------------------------------------------------
-- Function: OnStockpilesGetDefaultMaximums
--
-- This function is called when we want to know the default maximums
-- for the itemType
---------------------------------------------------------------------
function CookeryWiz:OnStockpilesGetDefaultMaximums(itemType)
  trace("CookeryWiz:OnStockpilesGetDefaultMaximums["..itemType.."]")
  return 200
end

---------------------------------------------------------------------
-- Function: GetFavourites
--
-- This function returns the favourites
---------------------------------------------------------------------
function CookeryWiz:GetFavourites()
  local savedVars = self:GetSavedVars()
  return savedVars.favourites    
end

---------------------------------------------------------------------
-- Function: GetMaxFavouriteTypes
--
-- This function returns the maximum number of favourite types
---------------------------------------------------------------------
function CookeryWiz:GetMaxFavouriteTypes()
  local savedVars = self:GetSavedVars()
  return savedVars.maxFavouriteTypes    
end

---------------------------------------------------------------------
-- Function: OnFavouriteIconClicked
--
-- This function is called when the favourite icon is clicked
---------------------------------------------------------------------
function CookeryWiz:OnFavouriteIconClicked(control, button)
  local rowControl = control:GetParent()
  local entry = rowControl.entry
  if not entry then
    return
  end
  local maxFavouriteTypes = self:GetMaxFavouriteTypes()
  local favouriteIndex = entry:GetFavouriteIndex()
  if favouriteIndex < maxFavouriteTypes then
    favouriteIndex = favouriteIndex + 1
  else
    favouriteIndex = 0
  end

  self:SetFavouriteIndex(entry:ItemId(), favouriteIndex)
  entry:SetFavouriteIndex(favouriteIndex)
  self:OnMouseEnterFavourite(control)
end

---------------------------------------------------------------------
-- Function: OnMouseEnterFavourite
--
-- This function is called when the mouse is over the favourite icon
---------------------------------------------------------------------
function CookeryWiz:OnMouseEnterFavourite(control)
  control:SetAlpha(1)
  local rowControl = control:GetParent()
  local entry = rowControl.entry
  if not entry then
    return
  end
  local favouriteTypeIndex = entry:GetFavouriteIndex()
  if favouriteTypeIndex == 0 then
    ZO_Tooltips_ShowTextTooltip(control, TOP, L[CWL_BUTTON_TOOLTIP_FAVOURITE_ADD])
  elseif favouriteTypeIndex == self:GetMaxFavouriteTypes() then
    ZO_Tooltips_ShowTextTooltip(control, TOP, L[CWL_BUTTON_TOOLTIP_FAVOURITE_REMOVE])
  else
    ZO_Tooltips_ShowTextTooltip(control, TOP, L[CWL_BUTTON_TOOLTIP_FAVOURITE_CHANGE])
  end
end

---------------------------------------------------------------------
-- Function: OnMouseExitFavourite
--
-- This function is called when the mouse exits the favourite icon
---------------------------------------------------------------------
function CookeryWiz:OnMouseExitFavourite(control)
  control:SetAlpha(0.4)
  ZO_Tooltips_HideTextTooltip()
end

---------------------------------------------------------------------
-- Function: IsFavourite
--
-- This function returns whether the recipe is a favourite
---------------------------------------------------------------------
function CookeryWiz:IsFavourite(id)
  if self:GetFavouriteIndex(id) == 0 then
    return false
  else
    return true
  end
end

---------------------------------------------------------------------
-- Function: GetFavouriteIndex
--
-- This function returns the favourite icon index
-- An index of 0 means that it is not a favourite
---------------------------------------------------------------------
function CookeryWiz:GetFavouriteIndex(id)
  local savedVars = self:GetSavedVars()
  local iconIndex = savedVars.favourites[tostring(id)]
  if iconIndex ~= nil then
    return tonumber(iconIndex)
  else
    return 0
  end
end

---------------------------------------------------------------------
-- Function: SetFavouriteIndex
--
-- This function sets the favourite icon index
-- An index of 0 means that it is not a favourite
---------------------------------------------------------------------
function CookeryWiz:SetFavouriteIndex(id, iconIndex)
  local savedVars = self:GetSavedVars()

  if iconIndex == 0 then
    savedVars.favourites[tostring(id)] = nil
  else
    savedVars.favourites[tostring(id)] = iconIndex
  end
  
end

---------------------------------------------------------------------
-- Function: IsAlwaysShowIngredientsEnabled
--
-- This function returns whether we should always show the list of
-- ingredients while cooking
---------------------------------------------------------------------
function CookeryWiz:IsAlwaysShowIngredientsEnabled()
  local savedVars = self:GetSavedVars()
  return savedVars.alwaysShowIngredients    
end

---------------------------------------------------------------------
-- Function: SetIsAlwaysShowIngredientsEnabled
--
-- This function sets whether we should always show the list of
-- ingredients while cooking
---------------------------------------------------------------------
function CookeryWiz:SetIsAlwaysShowIngredientsEnabled(enabled)
  local savedVars = self:GetSavedVars()
  savedVars.alwaysShowIngredients = enabled
end

local INVENTORY_SETUP_LIST_BAG = 1
local INVENTORY_SETUP_LIST_STORE = 4
local INVENTORY_SETUP_LIST_BUYBACK = 5


local UNKNOWN_RECIPE_NOONE = 1
local UNKNOWN_RECIPE_SELF = 2
local UNKNOWN_RECIPE_OTHERS = 3
local UNKNOWN_RECIPE_ALL = 4

local KNOWN_RECIPE_ICON = {
  { texture = "CookeryWiz/Graphics/cookerywiz-noone%u.dds"},
  { texture = "CookeryWiz/Graphics/cookerywiz-self%u.dds" },
  { texture = "CookeryWiz/Graphics/cookerywiz-others%u.dds" },
  { texture = "CookeryWiz/Graphics/cookerywiz-all%u.dds" }
}

CookeryWiz.fnInventorySetupSlot = nil
CookeryWiz.fnBuyBackList = nil
CookeryWiz.createIconCount = 0

local DEFAULT_INVENTORY_OFFSET = -110
local DEFAULT_STORE_OFFSET = -103

---------------------------------------------------------------------
-- Function: GetSavedVars
--
-- This function returns the saved vars
---------------------------------------------------------------------
function CookeryWiz:GetSavedVars()
  return self.savedVariables
end

---------------------------------------------------------------------
-- Function: IsDisplayTicksEnabled
--
-- This function returns whether ticks are enabled
---------------------------------------------------------------------
function CookeryWiz:IsDisplayTicksEnabled()
  local savedVars = self:GetSavedVars()
  return savedVars.displayTicks
end

---------------------------------------------------------------------
-- Function: SetTicksEnabled
--
-- This function sets whether ticks are enabled
---------------------------------------------------------------------
function CookeryWiz:SetDisplayTicksEnabled(enabled)
  local savedVars = self:GetSavedVars()
  savedVars.displayTicks = enabled
  CookeryWizRecipeEntry:SetDisplayTicksEnabled(enabled)
  -- we can do this as the scroll list has been setup
  -- and this routine is only called from options dialog
  CookeryWizRecipeList:RefreshScrollList()

end

---------------------------------------------------------------------
-- Function: GetIconTable
--
-- This function returns the icon table
---------------------------------------------------------------------
function CookeryWiz:GetIconTable()
  return KNOWN_RECIPE_ICON
end


---------------------------------------------------------------------
-- Recipe knowledge icon
---------------------------------------------------------------------

--[[
-- Enable item
function CookeryWiz:EnableRecipeKnowledgeIcon(enable)
  self:Enable(CW_SAVED_VAR_RECIPE_KNOWLEDGE_ICON, enable)
  if enable then
    self:HookStorageSetup()
  end
end

-- Is item enabled?
function CookeryWiz:IsRecipeKnowledgeIconEnabled()
  return self:IsEnabled(CW_SAVED_VAR_RECIPE_KNOWLEDGE_ICON)
end
]]--

CW_STATION_INTERACTION_METHOD_NONE = 0
CW_STATION_INTERACTION_METHOD_DISPLAY = 1
CW_STATION_INTERACTION_METHOD_REPLACE = 2

---------------------------------------------------------------------
-- Function: GetStationInteractionMethod
--
-- This function returns the index of the station interaction method
---------------------------------------------------------------------
function CookeryWiz:GetStationInteractionMethod()
  local vars = self:GetSavedVars()
  return vars.stationInteractionMethod  
end

---------------------------------------------------------------------
-- Function: SetStationInteractionIndex
--
-- This function sets the index of the station interaction method
---------------------------------------------------------------------
function CookeryWiz:SetStationInteractionMethod(stationInteractionMethod)
  local vars = self:GetSavedVars()
  
  vars.stationInteractionMethod = stationInteractionMethod
  
  if self.isCookingStationOpen then
    if stationInteractionMethod == CW_STATION_INTERACTION_METHOD_REPLACE then
      self:ReplaceProvisionerWindow()
    else
      self:RestoreProvisionerWindow()
    end
  end
  --if iconIndex > 0 then
    --self:HookStorageSetup()
  --end
end

---------------------------------------------------------------------
-- Function: GetIconIndex
--
-- This function returns the index of the icon to use
---------------------------------------------------------------------
function CookeryWiz:GetIconIndex()
  local vars = self:GetSavedVars()
  return vars.iconIndex  
end

---------------------------------------------------------------------
-- Function: SetIconIndex
--
-- This function sets the index of the icon to use
-- It is appended to the end of the filename and is 1 based
---------------------------------------------------------------------
function CookeryWiz:SetIconIndex(iconIndex)
  local vars = self:GetSavedVars()
  vars.iconIndex = iconIndex
  if iconIndex > 0 then
    self:HookStorageSetup()
  end
end

---------------------------------------------------------------------
-- Function: GetInventoryIconPosition
--
-- This function returns the location of the inventory icon
---------------------------------------------------------------------
function CookeryWiz:GetInventoryIconOffset()
  local vars = self:GetSavedVars()
  return vars.inventoryOffset
end

---------------------------------------------------------------------
-- Function: SetInventoryIconOffset
--
-- This function sets the location of the inventory  icon
---------------------------------------------------------------------
function CookeryWiz:SetInventoryIconOffset(offset)
  local vars = self:GetSavedVars()
  vars.inventoryOffset = offset
end

---------------------------------------------------------------------
-- Function: SetDefaultInventoryIconOffset
--
-- This function sets the default location of the inventory icon
---------------------------------------------------------------------
function CookeryWiz:SetDefaultInventoryIconOffset()
  local vars = self:GetSavedVars()
  vars.inventoryOffset = DEFAULT_INVENTORY_OFFSET
end

---------------------------------------------------------------------
-- Function: GetStoreIconPosition
--
-- This function returns the location of the inventory icon
---------------------------------------------------------------------
function CookeryWiz:GetStoreIconOffset()
  local vars = self:GetSavedVars()
  return vars.storeOffset
end

---------------------------------------------------------------------
-- Function: SetStoreIconOffset
--
-- This function sets the location of the store icon
---------------------------------------------------------------------
function CookeryWiz:SetStoreIconOffset(offset)
  local vars = self:GetSavedVars()
  vars.storeOffset = offset
end

---------------------------------------------------------------------
-- Function: SetDefaultStoreIconOffset
--
-- This function sets the default location of the store icon
---------------------------------------------------------------------
function CookeryWiz:SetDefaultStoreIconOffset()
  local vars = self:GetSavedVars()
  vars.storeOffset = DEFAULT_STORE_OFFSET
end

---------------------------------------------------------------------
-- Function: InventorySetupSlot
--
-- This function is the replaced setup function for the inventory
-- control
---------------------------------------------------------------------
function CookeryWiz:InventorySetupSlot(control, ...)

  local rowControl = control:GetParent()
  if not rowControl then
    trace("Failed getting parent of inventory setup slot control")
    return
  end
  
  local data = ZO_ScrollList_GetData(rowControl)
  if not data then
    trace("failed getting data from rowcontrol")
    return
  end
  
  if not data.slotIndex then
    trace("No slot index")
    return
  end
  
  local link
  local listType

  local bagId = data.bagId 
  if bagId then
    listType = INVENTORY_SETUP_LIST_BAG
    link = GetItemLink(bagId, data.slotIndex) 
  else
    listType = INVENTORY_SETUP_LIST_STORE
    link = GetTradingHouseSearchResultItemLink(data.slotIndex)       
  end

  
  --if data.dataEntry then
    --DumpData(data.dataEntry)
  --end
  
  -- did we get a link?
  if not link then
    trace("Unabled to get link from bag or trading house")
    return
  end


  local itemType = GetItemLinkItemType(link)

  local icon = rowControl:GetNamedChild("cwIcon")
  local level = rowControl:GetNamedChild("cwLevel")   
  if itemType ~= ITEMTYPE_RECIPE then
    -- not interested in this.. but has this row been used for a recipe?
    if icon then
      -- need to hide it
      icon:SetHidden(true)
      level:SetHidden(true)
    end
    --trace("Not a recipe "..link)
    return
  end

  -- are we enabled?
  local iconTypeIndex = self:GetIconIndex()
  if iconTypeIndex == 0 then
    trace("iconTypeIndex == 0")
    if icon then
      -- need to hide it
      icon:SetHidden(true)
      level:SetHidden(true)
    end    
    return
  end
  
  local recipeEntry = CookeryWizRecipeList:GetEntryByRecipeLink(link)
  if not recipeEntry then
    trace("failed finding master entry from link")
    return
  end
    
  local offset
  local levelOffset
  
  if listType == INVENTORY_SETUP_LIST_STORE then
    offset = self:GetStoreIconOffset()
    levelOffset = 0
  else
    offset = self:GetInventoryIconOffset()
    levelOffset = 32
  end
    
  -- does the icon control already exist?  
  if not icon then
    self.createIconCount = self.createIconCount + 1

    local controlName = rowControl:GetName().."cwIcon"
    icon = WINDOW_MANAGER:CreateControl(controlName, rowControl, CT_TEXTURE)
    icon.data = { tooltipText = "Unknown" }
    icon:SetInheritAlpha(false)
    icon:SetInheritScale(true)
    icon:SetMouseEnabled(true)
    icon:SetHandler("OnMouseEnter", function (control)
          CookeryWizRecipeList:ShowFoodToolTip(control, true)

        end)
    icon:SetHandler("OnMouseExit", function(control)
        CookeryWizRecipeList:ShowFoodToolTip(control, false)
      end)
    
    icon:SetHandler("OnMouseUp", function(control)
        if self.savedVariables.debugExtra then
          DumpChildren(rowControl)
        end
      end)
    
    -- now position it
    icon:ClearAnchors()
    icon:SetDimensions(32, 32)

    icon:SetAnchor(LEFT, rowControl, RIGHT, offset, 0)
    --icon:SetAnchor(LEFT, rowControl, LEFT, 0, 0)
    icon:SetDrawLevel(100)
    icon:SetHidden(false)
    
    -- create the level of the food
    controlName = rowControl:GetName().."cwLevel"
    level = WINDOW_MANAGER:CreateControl(controlName, rowControl, CT_LABEL)
    --icon.data = { tooltipText = "Unknown" }
    level:SetInheritAlpha(false)
    level:SetInheritScale(true)
    level:SetMouseEnabled(false)
    
		level:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))	
		level:SetFont("ZoFontGame")
    CookeryWizUtils:SetFont(level, 14)
		level:SetHorizontalAlignment(TEXT_ALIGN_LEFT) 	
		level:SetVerticalAlignment(TEXT_ALIGN_CENTER) 	
    
    level:ClearAnchors()
    level:SetDimensions(32, 32)

    --level:SetAnchor(RIGHT, rowControl, RIGHT, offset, -12)
    --level:SetAnchor(LEFT, rowControl, RIGHT, offset + 30, -16)
    --local button = rowControl:GetNamedChild("Button")
    --if button then
      --level:SetAnchor(BOTTOMRIGHT, button, BOTTOMLEFT, 15, -25)
    --else
      level:SetAnchor(LEFT, rowControl, LEFT, levelOffset, -20)
    --end
    level:SetHidden(false)      
  end
  
  -- do we know it?
  local isKnownToMe = IsItemLinkRecipeKnown(link)
  
  -- A user asked for a change so that if we are logged on and are not enabled, then we are not interested
  -- in showing whether we 'know' the recipe. I think that is better behaviour so the simplest way to implement
  -- this is to say we know it!
  local characterVars = self:GetCurrentPlayerCharacterVars()
  local isEnabled = characterVars.enabled
  
  local subTitle = L[CWL_ICON_UNKNOWN_RECIPE_TOOLTIP]
  local unknownBy = {}
  
  if not isKnownToMe and isEnabled then
    unknownBy[#unknownBy + 1] = "Me"
  end
  
  local totalCharacters = 0
  local characters = self:GetCharacterVars()
  local notKnownCount = 0

  for name, vars in pairs(characters) do
    if name ~= GetUnitName("player") and vars.enabled then     
      totalCharacters = totalCharacters + 1
      local knownEntry = vars.known[tostring(recipeEntry:ItemId())]
      if not knownEntry then
        notKnownCount = notKnownCount + 1
        unknownBy[#unknownBy + 1] = name
      end    
    end
  end
  
  local iconIndex
  if (isKnownToMe or not isEnabled) and notKnownCount == 0 then
    -- known to all!
    iconIndex = UNKNOWN_RECIPE_NOONE
    subTitle = L[CWL_ICON_KNOWN_RECIPE_TOOLTIP]
  elseif (isKnownToMe == false or isEnabled == false) and notKnownCount > 0 then
    -- unknown all
    iconIndex = UNKNOWN_RECIPE_ALL
  elseif notKnownCount > 0 then
    -- unknown to others
    iconIndex = UNKNOWN_RECIPE_OTHERS 
  else
    -- unknown only by me
    iconIndex = UNKNOWN_RECIPE_SELF
  end
  

  icon.data.foodLink = recipeEntry:GetFoodResultLink()
  icon.data.subTitle = subTitle
  icon.data.unknownBy = unknownBy
  icon.data.offsetX = -550
  icon.data.offsetY = 150
  icon.data.texture = string.format(KNOWN_RECIPE_ICON[iconIndex].texture, iconTypeIndex)
  
  --icon.data.tooltipText = unknownBy
  icon:SetTexture(icon.data.texture)

  icon:SetHidden(false)
  
  level:SetText(recipeEntry:GetFoodLevel())
  level:SetHidden(false)
    
  -- there are addons that modify the inventory display... and only show the icon. The below code
  -- is a simple attempt to show the cookerywiz icon (smaller) by the recipe icon if it thinks this
  -- is happening
  local x, y = rowControl:GetDimensions()
  icon:ClearAnchors()
  if x < 60 then
    icon:SetDimensions(26, 26)
    icon:SetAnchor(LEFT, rowControl, LEFT, -3, 3) 
  else
    icon:SetDimensions(32, 32)    
    icon:SetAnchor(LEFT, rowControl, RIGHT, offset, 0)     
  end
  
end

function DumpData(item)
  for key, data in pairs(item) do
    d(key)
    if key == "slotIndex" or key == "itemType" or key == "uniqueId" or key == "itemInstanceId" or key == "bagId" then
      d("["..data.."]")
    end
  end

end

function DumpChildren(parent, indent)
  if indent == nil then
    indent = ""
  end
  
  local children = parent:GetNumChildren()
  for i = 1, children do
    local child = parent:GetChild(i)
    d(indent.."["..i.."] "..child:GetName())
    DumpChildren(child, indent.."-")
  end 
end

function CookeryWiz:DumpChildren(parent)
  DumpChildren(parent)
end

---------------------------------------------------------------------
-- Function: HookStorageSetup
--
-- This function is called to hook the functions required to show
-- known recipe icons
---------------------------------------------------------------------
function CookeryWiz:HookStorageSetup()
  
  -- backpack
  if not self.fnInventorySetupSlot then
    self.fnInventorySetupSlot = _G["ZO_Inventory_SetupSlot"]
    ZO_PreHook(_G, "ZO_Inventory_SetupSlot", function(...)
        self:InventorySetupSlot(...)
        end)    
  end
  
  --[[
  -- buy back
  if not self.fnBuyBackList then
    self.fnBuyBackList = _G["ZO_BuyBackList"]
    ZO_PreHook(_G, "ZO_BuyBackList", function(...)
        self:InventorySetupSlot(INVENTORY_SETUP_LIST_BUYBACK,...)
        end)    
  end   
  ]]--
end

---------------------------------------------------------------------
-- Function: UnHookStorageLists
--
-- This function is called to unhook the functions required to show
-- known recipe icons
---------------------------------------------------------------------
function CookeryWiz:UnHookStorageSetup()
  
  -- bag
  if self.fnInventorySetupSlot then
    _G["ZO_Inventory_SetupSlot"] = self.fnInventorySetupSlot
    self.fnInventorySetupSlot = nil
  end
  
  -- buy back
  --[[
  if self.fnBuyBackList then
    _G["ZO_BuyBackList"] = self.fnBuyBackList
    self.fnBuyBackList = nil
  end  
 ]]--
end


CookeryWiz.defaultSave = nil

function CookeryWiz:ResetVariables()
    for key, data in pairs(self.defaultSave) do
      self.savedVariables[key] = nil
    end
end


function CookeryWiz:OnSelectedQualityButtonInitialized(control)
  self.selectedQualityControl = control
end

function CookeryWiz:OnQualityDownButtonInitialized(control)
  self.qualityDownButtonControl = control
  CookeryWizUtils:SetupTooltip(control, L[CWL_BUTTON_TOOLTIP_QUALITY_FILTER])  
end

function CookeryWiz:OnListQualityInitialized(control)
  self.qualityListControl = control
  control.selectCallback = self
end

function CookeryWiz:OnScrollListSelect(scrollList, entry)
  local quality = entry:GetQualityEntry()
  self.currentQuality = quality
  self.qualitySelector:SetSelectedQuality(quality)
  scrollList:SetHidden(true)
  self:OnReloadRecipes(false)
end


function CookeryWiz:OnToggleWindow()
  trace("OnToggleWindow")
  local disabled = self:IsMiniIconDisabled()
  local stationInteractionMethod = self:GetStationInteractionMethod()
  local scene = SCENE_MANAGER:GetCurrentScene()
  
  if not disabled then      
    if stationInteractionMethod == CW_STATION_INTERACTION_METHOD_REPLACE and scene == PROVISIONER_SCENE then
      SCENE_MANAGER:ShowBaseScene()
      return false
    end
  end
  return true
end

local qualityTable = {
  {ITEM_QUALITY_MAGIC},
  {ITEM_QUALITY_ARCANE, ITEM_QUALITY_MAGIC},
  {ITEM_QUALITY_ARTIFACT, ITEM_QUALITY_ARCANE, ITEM_QUALITY_MAGIC},
  {ITEM_QUALITY_ARCANE},
  {ITEM_QUALITY_ARTIFACT, ITEM_QUALITY_ARCANE},
  {ITEM_QUALITY_ARTIFACT}, 
  {ITEM_QUALITY_LEGENDARY}  
}

function CookeryWiz:Initialize()
   
  if not CookeryWizRecipeList.Initialize then
    return
  end
  
 
	self.defaultSave =
	{
    collapsed = {},
    characters = {},
    cook = {},
    favourites = {},
    extras = {

      },
    enableAwesomeGuildStoreIntegration = false,
    displayWithStationInteraction = true,
    deleteReadMail = true,
    disableWritCollection = false,
    collectControlPosition = nil,
    enableStockpiles = false,
    stockpileData = {},
    contacts = {},
    fetchDelay = 0,
    debugExtra = false,
    hookTooltip = true,
    stationInteractionMethod = CW_STATION_INTERACTION_METHOD_REPLACE,
    replaceProvisioner = true,
    displayTicks = false,
    alwaysShowIngredients = true,
    inventoryOffset = DEFAULT_INVENTORY_OFFSET,
    storeOffset = DEFAULT_STORE_OFFSET,
    iconIndex = 1,
    iconCount = 3,
    maxFavouriteTypes = 3,
    easyFrameVariables = self.easyFrameVariables
	}
  
  self.savedVariables = ZO_SavedVars:NewAccountWide("CookeryWizSavedVariables", 1, nil, self.defaultSave)  

  self.easyFrameVariables = self.savedVariables.easyFrameVariables

  if not self.savedVariables.collapsed then
    self.savedVariables.collapsed = {}
  end
  
  -- fix up previous version of favourites
  local favs = self:GetFavourites()
  if favs.version == nil then
    for recipeIndex, favIndex in pairs(favs) do
      favs[recipeIndex] = 1
    end      
    favs.version = 1
  end
  
  -- fix up new icon count
  local iconCount = self:GetIconCount()
  if iconCount < 3 then
    self:SetIconCount(3)
  end
  -- Configure strings
  self.closeTooltip = L[CWL_BUTTON_TOOLTIP_CLOSE]
  self.reloadTooltip = L[CWL_BUTTON_TOOLTIP_RELOAD]
  self.expandTooltip = L[CWL_BUTTON_TOOLTIP_EXPAND]
  self.shrinkTooltip = L[CWL_BUTTON_TOOLTIP_SHRINK]

  --self:EnableSceneIntegration(true)
  
  self.selectedPlayerName = GetUnitName("player")
  self:InitializeEasyFrame(L[CWL_COOKERYWIZ_TITLE], CookeryWizUI) 
    
  self:SetChatInsets(16)
  CookeryWizIngredients:Initialize()
  CookeryWizRecipeList:Initialize()
  
  -- Perform backgropund processing
  CookeryWizStartup.traceEnabled = false
  CookeryWizStartup:SetMaxLoopCounter(200)
  CookeryWizStartup:Begin()
  
  if self.savedVariables.enableStockpiles then
    CookeryWizStockpiles:Initialise(self.savedVariables)
    self.stockpileButtonControl:SetEnabled(true)
    -- get the icon from Apples!
    local itemLink = "|H1:item:34311:25:12:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
    local icon, sellPrice, meetsUsageRequirement, equipType, itemStyle = GetItemLinkInfo(itemLink)
    CookeryWizStockpiles:Register(self.name, self, ITEMTYPE_INGREDIENT, icon)

  else
    self.stockpileButtonControl:SetEnabled(false)
  end
  CookeryWizMailer:Initialize(self)
  
  --CookeryWizQualitySelector:Initialize(self, self.QualityChanged)
  self.qualitySelector = CookeryWizQualitySelector:new()
  self.qualitySelector:Initialise(self, self.qualityListControl, self.selectedQualityControl, self.qualityDownButtonControl, qualityTable)
  self.qualitySelector:PopulateQualityEntries()
  self.currentQuality = qualityTable[3]
  self.qualitySelector:SetSelectedQuality(self.currentQuality)
  
  -- reset the knowledge for this character
  local characterVars = self:GetCurrentPlayerCharacterVars()
  characterVars.known = {}
  
  self:UpdateProvisionerRecipeImprovement(self.selectedPlayerName)
  self:UpdateProvisionerRecipeQuality(self.selectedPlayerName)
  
  CookeryWizRecipeEntry:SetDisplayTicksEnabled(self:IsDisplayTicksEnabled())  
  
  -- load the recipes
  self:OnReloadRecipes(true)
  self:UpdateCookIngredients()
  
  self:UpdateSelectedPlayerKnownRecipeCount()
  self:PopulateCharacterDropDown()
  self:PopulateFilterDropDown()
  self:PopulateFavouriteDropDown()
  
  -- Register slash commands
  self:RegisterSlashCommands()

  self.maxRecipes = MRL:GetCount()
  self.maxFlags = math.ceil(self.maxRecipes / self.bitSize)

  CookeryWizGuildBank:PopulateOptionsDropDown(self.savedVariables.enableStockpiles)
  CookeryWizGuildBank:Register(self.name, self)
  CookeryWizBank:SetFetchDelay(self.savedVariables.fetchDelay)
  CookeryWizBank:Register(self.name, self)
  
  --characterVars.writFood = nil
  self.questTypeProvisioning = CookeryWizWritQuest:Register(self.name, self, L[CWL_QUEST_PROVISIONER_WRIT_TITLE])

  -- hook storage functions
  if self:GetIconIndex() ~= 0 then
    self:HookStorageSetup()
  end  
  
 
  --[[
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_BANK, function(...)
      self:OnOpenBank(...)
      end)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_BANK, function(...)
      self:OnCloseBank(...)
      end)  
  ]]--
  
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...)
      self:OnInventorySingleSlotUpdate(...)
    end)
  
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CRAFTING_STATION_INTERACT, function(...)
    self:OnCraftingStationInteract(...)
  end)

  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_END_CRAFTING_STATION_INTERACT, function(...)
    self:OnEndCraftingStationInteract(...)
  end)
  
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_OPEN_MAILBOX, CookeryWiz.OnOpenMailBox)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_CLOSE_MAILBOX, CookeryWiz.OnCloseMailBox)
  
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_SEND_FAILED, CookeryWiz.OnMailSendFailed) 
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_SEND_SUCCESS, CookeryWiz.OnMailSendSuccess)
  
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_READABLE, CookeryWiz.OnMailReadable)
  
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_REMOVED, function(...)
    self:OnMailRemoved(...)
  end)
 
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RECIPE_LEARNED, function(...)
    self:OnRecipeLearned(...)
  end)
    

--[[
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RETICLE_HIDDEN_UPDATE, 
    function(...)
      self:OnReticleHidden(...)
    end)
]]--
  -- Create a new mail handler to take care of interacting with mail
  --self.mailHandler = CookeryWizMailHandler:new()
  
    
  --if self.savedVariables.isFirstTime then
    --self:HideWindow(false)
    --self.savedVariables.isFirstTime = false
  --end
  
 
  self:CreateMiniBar(false, CookeryWizIconBarUI, 0.7)
  
  self:HookProvisionerTooltip()
  --self:ReplaceProvisionerWindow()
  
  self.initComplete = true
end


---------------------------------------------------------------------
-- Function: OnInventorySingleSlotUpdate
--
-- This event happens when a slot is updated
---------------------------------------------------------------------
function CookeryWiz:OnInventorySingleSlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
  self:UpdateFreeSpace()  
end


function CookeryWiz.OnAddOnLoaded(event, addonName)
  if addonName == CookeryWiz.name then
    CookeryWiz:Initialize()
    EVENT_MANAGER:UnregisterForEvent(CookeryWiz.name, EVENT_ADD_ON_LOADED)
  end
end

EVENT_MANAGER:RegisterForEvent(CookeryWiz.name, EVENT_ADD_ON_LOADED, CookeryWiz.OnAddOnLoaded)


