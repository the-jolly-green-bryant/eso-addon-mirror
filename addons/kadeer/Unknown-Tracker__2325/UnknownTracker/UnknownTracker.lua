local UT = UnknownTracker or {}
UnknownTracker.name = "UnknownTracker"

local account
local server
local character
local allCharacters = {}
local allAccounts = {}
local m = nil
local groupMembers = {}

-- MISSING CONSTANTS in api (used in ut.lua and data.lua)
ITEMTYPE_SCRIBINGX = 73               -- update from here
SPECIALIZED_ITEMTYPE_AFFIXX = 3252    -- https://wiki.esoui.com/Globals#ItemType
SPECIALIZED_ITEMTYPE_FOCUSX = 3250    -- https://wiki.esoui.com/Globals#SpecializedItemType
SPECIALIZED_ITEMTYPE_SIGNATUREX = 3251

local VALID_ITEMTYPES = {
  [ITEMTYPE_RACIAL_STYLE_MOTIF] = true,
  [ITEMTYPE_RECIPE] = true,
  [ITEMTYPE_COLLECTIBLE] = true,
  [ITEMTYPE_CONTAINER] = true,
  [ITEMTYPE_ARMOR] = true,
  [ITEMTYPE_WEAPON] = true,
  [ITEMTYPE_SCRIBINGX] = true,        -- check constants.lua and update if api changed
}

local SHORTEN_NAME_LENGTH = 3

------------------------------------------------------------------------------
-- @Shadowfen - AutoCategory integration
function UT:GetCharacterList()
  -- Build character lists if they don't exist
  if next(allCharacters) == nil then
     UT:BuildCharacterList()
  end
  -- return lists
  return allCharacters, allAccounts
end
------------------------------------------------------------------------------

-- Checks itemlink if its valid and who knows it
--  could pre-check and only hook relevant items but then other addons which use this would need to "self-check")
--  need some overloads (itemId) (bagid, slotIndex)
--  tbd reuse funcs from data.lua
--
-- Returns
--  isValid             = true if its motif/recipe/furnishing/stylepage/runebox, false otherwise
--  knownByNameList     = a list of names which are the characters who know this itemlink (could be empty if no one knows it)
--  isGear              = for stickerbook gear
function UT:IsValidAndWhoKnowsIt(itemLink)
  local itemId = GetItemLinkItemId(itemLink)
  local itemType, specializedType = GetItemLinkItemType(itemLink)
  local isValid = false         -- make sure its a valid itemtype because knownByNameList can be nil sometimes even with correct itemtype
  local knownByNameList = {}
  local isGear = false
  local isCrafted = false

  -- bail quick if its an item we are not interested in
  if VALID_ITEMTYPES[itemType] == nil then
    return false, {}
  end

  -- Check for motifs and return a list of characters who know it
  if itemType == ITEMTYPE_RACIAL_STYLE_MOTIF and UTOpts.displayMotifs then
    -- Goal is to find root itemId (motif book id) of this style
    isValid = true
    local rootItemId = nil

    -- check if its a motif book
    if UTDataDump.motifData[itemId] ~= nil then
      rootItemId = itemId
    else
      -- its a chapter, need to keep subtracting itemId until a match is found (limit 14 aka UT.CHAPTERS)
      local NumChapters = NonContiguousCount(UT.CHAPTERS)

      for i = 1, NumChapters do
        if UTDataDump.motifData[itemId-i] ~= nil then
          rootItemId = itemId-i
          break
        end
      end
    end

    if rootItemId then
      local characters = m.motifs[rootItemId]

      -- iterate all characters for this motif book looking for characters who know it
      -- v could be a 1 (full motif known) or a list of only known chapters
      if characters ~= nil then
        for name, v in pairs(characters) do
          if v == 1 or v[itemId] ~= nil then
            knownByNameList[name] = 1
          end
        end
      end
      knownByNameList = self:TrimList(knownByNameList, allCharacters)
    else
      -- didnt find rootItemId
      -- its a motif but datadump has no knowledge about
      d("UnknownTracker: Motif no info " .. itemLink .. tostring(itemId))
      isValid = false
    end
  end

  -- Check for recipes and furnishings and return a list of characters who know it
  if itemType == ITEMTYPE_RECIPE then
    local isFurniture = IsItemLinkFurnitureRecipe(itemLink)

    if isFurniture and UTOpts.displayFurnishings then
      isValid = true
      knownByNameList = m.furnishings[itemId]
      knownByNameList = self:TrimList(knownByNameList, allCharacters)
    elseif UTOpts.displayRecipes then
      isValid = true
      knownByNameList = m.recipes[itemId]
      knownByNameList = self:TrimList(knownByNameList, allCharacters)
    end
  end

  -- Collectible = stylepages, Container = runeboxes, Check and return a list of account ids who know it
  if itemType == ITEMTYPE_CONTAINER or itemType == ITEMTYPE_COLLECTIBLE then
    local linkIcon = GetItemLinkIcon(itemLink)

    -- using icon names to find the correct containers
    if (linkIcon == self.STYLEPAGE_ICON_PATH1 or linkIcon == self.STYLEPAGE_ICON_PATH2) and UTOpts.displayStylepages then
      isValid = true
      knownByNameList = m.stylepages[itemId]
    end
    if linkIcon == self.RUNEBOX_ICON_PATH1 and UTOpts.displayRuneboxes then
      isValid = true
      knownByNameList = m.runeboxes[itemId]
    end
  end

  -- Check gear for stickerbook (green=learnable, blue=trade/sellable, bound=no icon)
  if UTOpts.displayGear then
    if itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_ARMOR then
      isGear = true
      knownByNameList = {}

      if IsItemLinkSetCollectionPiece(itemLink) and not IsItemSetCollectionPieceUnlocked(itemId) then     -- unlocked means collected in stickerbook NOT locked by user :S
        -- learnable/needed (green)
        --d("UT need: " .. itemLink .. tostring(itemId))        
        isValid = true
      elseif IsItemLinkSetCollectionPiece(itemLink) and IsItemSetCollectionPieceUnlocked(itemId) and not IsItemLinkBound(itemLink) then
        -- can trade or sell to others (blue)
        --d("UT dont need: " .. itemLink .. tostring(itemId))
        isValid = true
        knownByNameList[account] = 1   
      end                
    end
  end

  -- Check Scribing
  if UTOpts.displayScribing then
    if itemType == ITEMTYPE_SCRIBINGX then
      if specializedType == SPECIALIZED_ITEMTYPE_AFFIXX then
        -- d("UT affix type: " .. itemLink .. tostring(itemId))
        isValid = true
        knownByNameList = m.affix[itemId]
        knownByNameList = self:TrimList(knownByNameList, allCharacters)
      elseif specializedType == SPECIALIZED_ITEMTYPE_FOCUSX then
        -- d("UT focus type: " .. itemLink .. tostring(itemId))
        isValid = true
        knownByNameList = m.focus[itemId]
        knownByNameList = self:TrimList(knownByNameList, allCharacters)
      elseif specializedType == SPECIALIZED_ITEMTYPE_SIGNATUREX then
        -- d("UT signature type: " .. itemLink .. tostring(itemId))
        isValid = true
        knownByNameList = m.signature[itemId]
        knownByNameList = self:TrimList(knownByNameList, allCharacters)
      end
    end
  end

  -- Mark crafted gear
  if UTOpts.displayCraftedGear then 
    if IsItemLinkCrafted(itemLink) then 
      isValid = true      
      isCrafted = true      
    end
  end

  return isValid, knownByNameList, isGear, isCrafted
end

-- TOOLTIPS ----------------------------------------------------------------------------------
function UT:SetTooltip(tooltip, itemLink)
  if UTOpts.displayTooltip == false then return end
  local isValid, knownByNameList, isGear, isCrafted = self:IsValidAndWhoKnowsIt(itemLink)
  if not isValid then return end
  if isGear then return end
  if isCrafted then return end
  local itemType = GetItemLinkItemType(itemLink)
  local allLearners = (itemType == ITEMTYPE_CONTAINER or itemType == ITEMTYPE_COLLECTIBLE) and allAccounts or allCharacters
  local outstr = ""

  -- output relevant character/account names and set colours
  local out = {}
  for k, name in pairs(allLearners) do
    
    if knownByNameList ~= nil and knownByNameList[name] then
      if UTOpts.shortenTooltipNames then name = string.sub(name, 1, SHORTEN_NAME_LENGTH) end
      name = self:SetColour(name, UTOpts.knownByAllColour)

      if UTOpts.displayTooltipNameOnlyIfUnknown == false then
        table.insert(out, name)
      end
    else
      if UTOpts.shortenTooltipNames then name = string.sub(name, 1, SHORTEN_NAME_LENGTH) end    
      name = self:SetColour(name, UTOpts.unknownColour)
      table.insert(out, name)
    end    
  end
  outstr = table.concat(out, ", ")
  --outstr = ZO_GenerateCommaSeparatedList(out)

  if outstr then
    tooltip:AddVerticalPadding(5)
    ZO_Tooltip_AddDivider(tooltip)
    tooltip:AddLine("UNKNOWN TRACKER", "ZoFontGameBold", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
    tooltip:AddLine(zo_strformat(outstr), "", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
  end

end

function UT:TooltipHook(tooltipControl, method, linkFunc)
  local origMethod = tooltipControl[method]

  tooltipControl[method] = function(self, ...)
    origMethod(self, ...)
    UnknownTracker:SetTooltip(self, linkFunc(...))
  end
end

function UT:HookBagTips()
  self:TooltipHook(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
  self:TooltipHook(ItemTooltip, "SetBagItem", GetItemLink)
  self:TooltipHook(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
  self:TooltipHook(ItemTooltip, "SetLootItem", GetLootItemLink)
  self:TooltipHook(ItemTooltip, "SetTradeItem", GetTradeItemLink)
  self:TooltipHook(ItemTooltip, "SetStoreItem", GetStoreItemLink)
  self:TooltipHook(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
  --self:TooltipHook(ItemTooltip, "SetLink", function(...) return ... end)
  self:TooltipHook(PopupTooltip, "SetLink", function(...) return ... end)

  -- AGS shenanigans
  if AwesomeGuildStore then
    AwesomeGuildStore:RegisterCallback(AwesomeGuildStore.callback.AFTER_INITIAL_SETUP, function()
      self:TooltipHook(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
    end)
  else
    self:TooltipHook(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
  end
end

-- INVENTORY ICON ----------------------------------------------------------------------------------
function UT:SetInventoryIcon(control, itemLink, tradingHouse)
  if not control or not itemLink then d("UnknownTracker: Missing control/itemLink") return end
  local c = control:GetNamedChild("UTIcon")
  if c then c:SetHidden(true) end

  local isValid, knownByNameList, isGear, isCrafted = self:IsValidAndWhoKnowsIt(itemLink)
  if not isValid then return end

  -- stylepage/runebox/gear use @account everything else uses character name
  local itemType = GetItemLinkItemType(itemLink)
  local allLearners = (itemType == ITEMTYPE_CONTAINER or itemType == ITEMTYPE_COLLECTIBLE) and allAccounts or allCharacters
  local name = (itemType == ITEMTYPE_CONTAINER or itemType == ITEMTYPE_COLLECTIBLE)  and account or character

  if not c then
    c = WINDOW_MANAGER:CreateControl(control:GetName() .. "UTIcon", control, CT_TEXTURE)
  end

  -- always setting anchors incase options changed
  c:ClearAnchors()
  c:SetDimensions(UTOpts.iconSize, UTOpts.iconSize)
  c:SetDrawLevel(UTOpts.iconDrawLevel)

  -- slightly different Left for trading house
  if tradingHouse and UTOpts.inventoryIconPosition == 1 then
      c:SetAnchor(CENTER, control:GetNamedChild("Button"), CENTER, UTOpts.iconXOffset, UTOpts.iconYOffset)
  elseif UTOpts.inventoryIconPosition == 1 then
    c:SetAnchor(CENTER, control:GetNamedChild("Status"), CENTER, UTOpts.iconXOffset, UTOpts.iconYOffset)
  elseif UTOpts.inventoryIconPosition == 2 then
    c:SetAnchor(CENTER, control:GetNamedChild("Button"), CENTER, UTOpts.iconXOffset, UTOpts.iconYOffset)
  else
    c:SetAnchor(CENTER, control:GetNamedChild("TraitInfo"), CENTER, UTOpts.iconXOffset, UTOpts.iconYOffset)
  end
  
  local isLearning = false
  for i = 1, #allLearners do
    if allLearners[i] == name then
      isLearning = true
    end
  end

  -- figure out which colour to use
  local r, g, b, a = self:ConvertHexToRGBA(UTOpts.knownBySomeColour)
  local isUnknown = false

  -- unknown by all learners ?
  if knownByNameList == nil or (knownByNameList ~= nil and knownByNameList[name] == nil) then
    -- only passes if we are learning otherwise it will be either knownbysome or knownbyall
    if isLearning then
      r, g, b, a = self:ConvertHexToRGBA(UTOpts.unknownColour)
    end
    isUnknown = true
  end
  
  -- known by all leaners ?
  if knownByNameList ~= nil and allLearners ~= nil then
    if NonContiguousCount(knownByNameList) == NonContiguousCount(allLearners) then
      r, g, b, a = self:ConvertHexToRGBA(UTOpts.knownByAllColour)
      isUnknown = false
    end
  end

  -- only display unknown otherwise hide
  if UTOpts.displayOnlyIfUnknown and isUnknown == false then
    c:SetHidden(true)
    return
  end
  
  -- d(itemLink)
  -- d("knownByNameList")
  -- d(knownByNameList)
  -- d("---------------")
  
  if isCrafted then -- 1: Crafted    
    c:SetTexture("/UnknownTracker/Textures/gear.dds")
    c:SetColor(self:ConvertHexToRGBA(UTOpts.unknownColour))
    c:SetHidden(false)
    return
  elseif isGear then -- 2: Gear    
    if knownByNameList[account] then 
      c:SetTexture("/UnknownTracker/Textures/tradegear.dds")
      c:SetColor(self:ConvertHexToRGBA(UTOpts.knownByAllColour))
      
        -- dont show trade icon for guild stores
        if tradingHouse then
          c:SetHidden(true)
        else 
          c:SetHidden(false)
        end
      return
    else      
      c:SetTexture("/UnknownTracker/Textures/learngear.dds")  
      c:SetColor(self:ConvertHexToRGBA(UTOpts.unknownColour))
      c:SetHidden(false)      
      return
    end
  end

  c:SetTexture(UTOpts.inventoryIconStyle)
  c:SetColor(r, g, b, a)  
  c:SetHidden(false)
end

function UT:HookBags()
  -- PLAYER_INVENTORY (backpack/quest_item/bank/house_bank/guild_bank/craft_bag)
  for k,v in pairs(PLAYER_INVENTORY.inventories) do
    local listView = v.listView
    if ( listView and listView.dataTypes and listView.dataTypes[1] ) then
      ZO_PreHook(listView.dataTypes[1], "setupCallback", function(control, slot)
        local itemLink = GetItemLink(control.dataEntry.data.bagId, control.dataEntry.data.slotIndex, LINK_STYLE_BRACKETS)
        self:SetInventoryIcon(control, itemLink)
      end)
    end
  end
end

-- CHECK KNOWN ----------------------------------------------------------------------------------
function UT:CheckMotifs()

  -- iterate datadumps motif data
  if UTDataDump.motifData ~= nil then
    for bookId, v in pairs(UTDataDump.motifData) do
      local isEntireMotifKnown = IsItemLinkBookKnown(("|H1:item:%d:299:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"):format(bookId))
      m.motifs[bookId] = m.motifs[bookId] or {}   -- use exisiting or initialise first time

      -- book without chapters
      if isEntireMotifKnown and v.chapters == false then
        m.motifs[bookId][character] = 1
      elseif not isEntireMotifKnown and v.chapters == false then
        m.motifs[bookId][character] = nil -- specifically remove incase of incorrect (shouldnt happen)
      end

      -- book with chapters
      if isEntireMotifKnown and v.chapters then
        m.motifs[bookId][character] = 1
      elseif not isEntireMotifKnown and v.chapters then

        -- only some chapters are known, making sure its a table currently
        if type(m.motifs[bookId][character]) ~= "table" then
          m.motifs[bookId][character] = {}
        end

        -- iterate chapters
        local NumChapters = NonContiguousCount(UT.CHAPTERS)

        for chapterId = 1, NumChapters do
          m.motifs[bookId][character] = m.motifs[bookId][character] or {}

          if IsItemLinkBookKnown(("|H1:item:%d:299:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"):format(bookId+chapterId)) then
            m.motifs[bookId][character][bookId+chapterId] = 1
          else
            m.motifs[bookId][character][bookId+chapterId] = nil
          end
        end
      end
    end
  end

  self:ClearEmptyTables(m.motifs)
  self:RefreshViews()
end

function UT:CheckRecipesAndFurniture()
  local itemLink = ""

  if UTDataDump.recipeData ~= nil then
    for itemId, v in pairs(UTDataDump.recipeData) do
      itemLink = ("|H1:item:%d:299:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"):format(itemId)
      m.recipes[itemId] = m.recipes[itemId] or {}

      if IsItemLinkRecipeKnown(itemLink) then
        m.recipes[itemId][character] = 1
      else
        m.recipes[itemId][character] = nil                  -- making sure character is nil
      end
    end
  end

  self:ClearEmptyTables(m.recipes)
  self:RefreshViews()

  if UTDataDump.furnitureData ~= nil then
    for itemId, v in pairs(UTDataDump.furnitureData) do
      itemLink = ("|H1:item:%d:299:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"):format(itemId)
      m.furnishings[itemId] = m.furnishings[itemId] or {}

      if IsItemLinkRecipeKnown(itemLink) then
        m.furnishings[itemId][character] = 1
      else
        m.furnishings[itemId][character] = nil
      end
    end
  end

  self:ClearEmptyTables(m.furnishings)
  self:RefreshViews()
end

function UT:CheckStylePagesAndRuneboxes()
  local collectibleId
  local itemLink

  if UTDataDump.stylepageData ~= nil then
    for itemId, v in pairs(UTDataDump.stylepageData) do
      itemLink = ("|H1:item:%d:299:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"):format(itemId)
      m.stylepages[itemId] = m.stylepages[itemId] or {}
      collectibleId = GetItemLinkContainerCollectibleId(itemLink)

      if IsCollectibleUnlocked(collectibleId) then
        m.stylepages[itemId][account] = 1
      else
        m.stylepages[itemId][account] = nil
      end
    end
  end

  if UTDataDump.runeboxData ~= nil then
    for itemId, v in pairs(UTDataDump.runeboxData) do
      itemLink = ("|H1:item:%d:299:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"):format(itemId)
      m.runeboxes[itemId] = m.runeboxes[itemId] or {}
      collectibleId = GetItemLinkContainerCollectibleId(itemLink)

      if IsCollectibleUnlocked(collectibleId) then
        m.runeboxes[itemId][account] = 1
      else
        m.runeboxes[itemId][account] = nil
      end
    end
  end

  self:ClearEmptyTables(m.runeboxes)
  self:ClearEmptyTables(m.stylepages)
  self:RefreshViews()
end

function UT:CheckScribing()
  if UTDataDump.affixData ~= nil then
    for itemId, v in pairs(UTDataDump.affixData) do
      itemLink = ("|H1:item:%d:299:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"):format(itemId)
      m.affix[itemId] = m.affix[itemId] or {}

      local isItemUseTypeCraftedAbilityScript = GetItemLinkItemUseType(itemLink) == ITEM_USE_TYPE_CRAFTED_ABILITY_SCRIPT
      local craftedAbilityScriptId = isItemUseTypeCraftedAbilityScript and GetItemLinkItemUseReferenceId(itemLink) or 0

      if IsCraftedAbilityScriptUnlocked(craftedAbilityScriptId) then
        m.affix[itemId][character] = 1
      else
        m.affix[itemId][character] = nil                  -- making sure character is nil
      end
    end
  end

  self:ClearEmptyTables(m.affix)
  self:RefreshViews()

  if UTDataDump.focusData ~= nil then
    for itemId, v in pairs(UTDataDump.focusData) do
      itemLink = ("|H1:item:%d:299:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"):format(itemId)
      m.focus[itemId] = m.focus[itemId] or {}

      local isItemUseTypeCraftedAbilityScript = GetItemLinkItemUseType(itemLink) == ITEM_USE_TYPE_CRAFTED_ABILITY_SCRIPT
      local craftedAbilityScriptId = isItemUseTypeCraftedAbilityScript and GetItemLinkItemUseReferenceId(itemLink) or 0

      if IsCraftedAbilityScriptUnlocked(craftedAbilityScriptId) then
        m.focus[itemId][character] = 1
      else
        m.focus[itemId][character] = nil
      end
    end
  end

  self:ClearEmptyTables(m.focus)
  self:RefreshViews()

  if UTDataDump.signatureData ~= nil then
    for itemId, v in pairs(UTDataDump.signatureData) do
      itemLink = ("|H1:item:%d:299:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"):format(itemId)
      m.signature[itemId] = m.signature[itemId] or {}

      local isItemUseTypeCraftedAbilityScript = GetItemLinkItemUseType(itemLink) == ITEM_USE_TYPE_CRAFTED_ABILITY_SCRIPT
      local craftedAbilityScriptId = isItemUseTypeCraftedAbilityScript and GetItemLinkItemUseReferenceId(itemLink) or 0

      if IsCraftedAbilityScriptUnlocked(craftedAbilityScriptId) then
        m.signature[itemId][character] = 1
      else
        m.signature[itemId][character] = nil
      end
    end
  end

  self:ClearEmptyTables(m.signature)
  self:RefreshViews()

end

function UT:RefreshViews()
  ZO_ScrollList_RefreshVisible(ZO_PlayerInventoryBackpack)
  ZO_ScrollList_RefreshVisible(ZO_PlayerBankBackpack)
  ZO_ScrollList_RefreshVisible(ZO_GuildBankBackpack)
  ZO_ScrollList_RefreshVisible(ZO_StoreWindowList)
  ZO_ScrollList_RefreshVisible(ZO_TradingHouseBrowseItemsRightPaneSearchResults)
  --ZO_ScrollList_RefreshVisible(ZO_CraftBagList)
  --ZO_ScrollList_RefreshVisible(ZO_TradingHousePostedItemsList)
end

function UT:PurgeCharacter(name)

  local function PurgeFrom(name, table)
    for k, v in pairs(table) do
      if v[name] then
        v[name] = nil
      end
    end
  end

  PurgeFrom(name, m.recipes)
  PurgeFrom(name, m.furnishings)
  PurgeFrom(name, m.motifs)
end

function UT:BuildCharacterList()

  -- Build allcharacter and allaccount lists (just 3s followed by 1s, ignoring 2s)
  -- 1 = Learning (normal show icon and tooltip for this character)
  -- 2 = Not Learning (not showing what this character knows but will display inventory icon "unknown by others")
  -- 3 = Learning on All Accounts (normal show icon and tooltip but even if on a different account)
  allCharacters = {}
  allAccounts = {}

  -- create entry for this account if its the first time
  if UTOpts.trackedCharacters[server][account] == nil then
    UTOpts.trackedCharacters[server][account] = { isEnabled=true, characters={} }
  end

  -- Tracked Characters Server Account
  local tcsa = UTOpts.trackedCharacters[server][account]

  -- Get/Create Character list from API and check it against savedVars
  -- retain existing setting if it has previously been set
  -- also detect name changes and take appropriate actions
  local exisitingCharacters = {}
  local numChars = GetNumCharacters()
  local c = ""

  for i = 1, numChars do
    c = zo_strformat("<<1>>", GetCharacterInfo(i))
    exisitingCharacters[i] = tcsa.characters[i] and tcsa.characters[i] or { name=c, setting=1 }

    -- detect name change
    if exisitingCharacters[i]["name"] ~= c then
      -- purge old name
      UT:PurgeCharacter(exisitingCharacters[i]["name"])

      -- set new name
      exisitingCharacters[i]["name"] = c
    end
  end

  -- saved updated character list to savedVars
  tcsa.characters = exisitingCharacters

  -- Find all "3" setting so they appear first on the tooltip
  for accountName, v in pairs(UTOpts.trackedCharacters[server]) do

    -- ignore full disabled accounts
    if v.isEnabled then
      for k, character in pairs(v.characters) do
        if character.setting == 3 then
          allCharacters[#allCharacters+1] = character.name
        end
      end
      -- can build allAccounts here too
      allAccounts[#allAccounts+1] = accountName
    end
  end

  -- Next find all "1 Show" of this account
  if tcsa.isEnabled then
    for i = 1, #tcsa.characters do
      if tcsa.characters[i].setting == 1 then
        allCharacters[#allCharacters+1] = tcsa.characters[i].name
      end
    end
  end
end

function UT:HookDeconstruction()  
  -- ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack
  local listView = ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack
  if ( listView and listView.dataTypes and listView.dataTypes[1] ) then
    ZO_PreHook(listView.dataTypes[1], "setupCallback", function(control, slot)
      local slot = control.dataEntry.data
      local itemLink = GetItemLink(slot.bagId, slot.slotIndex)
      self:SetInventoryIcon(control, itemLink)
    end)
  end
end

function UT:HookStore()
  --ZO_StoreWindow List
  local listView = ZO_StoreWindowList
  if ( listView and listView.dataTypes and listView.dataTypes[1] ) then
    ZO_PreHook(listView.dataTypes[1], "setupCallback", function(control, slot)
      local itemLink = GetStoreItemLink(slot.slotIndex)
      self:SetInventoryIcon(control, itemLink)
    end)
  end

  --ZO_BuyBack List
  listView = ZO_BuyBackList
  if ( listView and listView.dataTypes and listView.dataTypes[1] ) then
    ZO_PreHook(listView.dataTypes[1], "setupCallback", function(control, slot)
      local itemLink = GetBuybackItemLink(slot.slotIndex)
      self:SetInventoryIcon(control, itemLink)
    end)
  end
end

function UT:HookTradingHouse()
  -- GetTradingHouseListingItemLink for the list where u sell stuff for trading house

  local listView = ZO_TradingHouseBrowseItemsRightPaneSearchResults
  if ( listView and listView.dataTypes and listView.dataTypes[1] ) then
    ZO_PreHook(listView.dataTypes[1], "setupCallback", function(control, slot)
      local itemLink = GetTradingHouseSearchResultItemLink(slot.slotIndex)
      self:SetInventoryIcon(control, itemLink, true)
    end)
  end
end

function UT:OnGroupChanged()
  gsize = GetGroupSize()
  for i = 1, gsize do
    groupMembers[GetUnitName('group' .. i)] = GetUnitDisplayName('group' .. i)
  end
end

function UT:OnLootReceived(eventCode, receivedBy, itemName, quantity, soundCategory, lootType, self, isPickpocketLoot, questItemIcon, itemId, isStolen) 	

	--/script UnknownTracker.OnLootReceived(0,"Testplayer^Mx","|H1:item:55990:363:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:500:0|h|h",0,0,0,0,0,"",55990,0)
	
  if UTOpts.displayGear then  	  	
    if IsItemLinkSetCollectionPiece(itemName) and not IsItemSetCollectionPieceUnlocked(itemId) then

      -- try to get @name (falls back to character name)
      UT:OnGroupChanged()
      local name = groupMembers[zo_strformat(SI_UNIT_NAME, receivedBy)] or receivedBy
      name = name:gsub("%^%a+$", "", 1) -- get rid of ^Mx stuff if applicable
      
      -- get item quality directly from itemlink
      elements = UT:Split(itemName, ":")
      local quality = elements[4]

      d("UT Collectable: " .. itemName .. " " ..  UT:MakeLink("8F8F8F", "UT Gear Link", name, tostring(itemId), tostring(quality)))
    end
  end

    -- d("------------------------------")
    -- d("eventCode: " .. eventCode)
    -- d("receivedBy: " .. receivedBy)
    -- d("itemName: " .. itemName)
    -- d("lootType: " .. lootType)

  if UTOpts.displayBust then
    -- /script d(GetCollectibleName(GetCollectibleIdFromLink("|H0:collectible:8152|h|h")))
    local bustTrophy = GetCollectibleName(GetCollectibleIdFromLink(itemName));

    UT:OnGroupChanged();
    local name = groupMembers[zo_strformat(SI_UNIT_NAME, receivedBy)] or receivedBy
    name = name:gsub("%^%a+$", "", 1);

    if string.find(bustTrophy, "Trophy:") then
      d("UT TROPHY (First Normal Clear): " .. itemName .. " |cFFD800" .. name .. "|r")
    end

    if string.find(bustTrophy, "Bust:") then
      d("UT BUST (First Veteran Clear): " .. itemName .. " |cFFD800" .. name .. "|r")
    end

  end

end

function UT:MakeLink(colour, linkId, name, itemId, quality)
  -- |H1:ability:69|h[Test]|h
  local combineTable = {"|c", colour, "|H1:", tostring(linkId), ":", name, ":", itemId, ":", quality, "|h", name, "|h", "|r"}
  return table.concat(combineTable)
end

-- lol beggar AI
function UT.HandleClickEvent(rawLink, mouseButton, linkText, linkStyle, linkId, name, itemId, quality)
	if linkId == "UT Gear Link" then
		local msg = "Requesting |H1:item:" .. itemId .. ":" .. quality .. ":50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:500:0|h|h "
		CHAT_SYSTEM.textEntry:SetText("/w " .. name .. " " .. msg)
		return true
	end
end

function UT:OnScriptUnlocked(craftedAbilityScriptDefId, isUnlocked)
  --d("OnScriptUnlocked")
  --d(craftedAbilityScriptDefId)
  --d(tostring(isUnlocked))

  if isUnlocked then
    self:CheckScribing()
  end
end

-- unreliable since accountwide achievs
-- function UT:OnAchievement(id)
--   -- check if scribing script learned by using achievement (no other way yet)
--   -- focus/affix/signature
--   if id == 3996 or id == 3997 or id == 3998 then
--     self:CheckScribing()
--   end
-- end

function UT:SetupEvents(toggle)
  if toggle then
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COLLECTIBLE_NOTIFICATION_NEW, function(...) self:CheckStylePagesAndRuneboxes(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_STYLE_LEARNED , function(...) self:CheckMotifs(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RECIPE_LEARNED, function(...) self:CheckRecipesAndFurniture(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MULTIPLE_RECIPES_LEARNED, function(...) self:CheckRecipesAndFurniture(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_STORE, function(...) self:HookStore(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_TRADING_HOUSE, function(...) self:HookTradingHouse(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_LOOT_RECEIVED, function(...) self:OnLootReceived(...) end)
    EVENT_MANAGER:RegisterForEvent(self.ame, EVENT_GROUP_MEMBER_JOINED, function(...)  self:OnGroupChanged(...) end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CRAFTED_ABILITY_SCRIPT_LOCK_STATE_CHANGED, function(...) self:OnScriptUnlocked(...) end)

    -- unreliable since accountwide achievs
    -- EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACHIEVEMENT_UPDATED, function(_, id) self:OnAchievement(id) end) -- achiev in progress
    -- EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACHIEVEMENT_AWARDED, function(_, _, _, id) self:OnAchievement(id) end) -- achiev complete

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CRAFTING_STATION_INTERACT, function(...) self:HookDeconstruction(...) end)    
  else    
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_COLLECTIBLE_NOTIFICATION_NEW)
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_RECIPE_LEARNED)
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_STYLE_LEARNED)
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_LOOT_RECEIVED)
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_GROUP_MEMBER_JOINED)

  end
end

-- SLASH COMMANDS -------------------------------------------------------------------------------

local CHAT_MAX = 350 - 12
local overflow  = "" 

-- only one main item line and one overflow, anything more and it will fail
-- make items into an array of CHAT_MAX itemlink msgs to output

SLASH_COMMANDS["/utg"] = function (extra)
  -- d("Tradeable Gear")  
  -- LibChatMessage("UT", "ut"):Print("LibChatMessage test...")
  local items = ""

  -- Check if there was overflow previously
  if overflow ~= "" then 
    items = overflow
    overflow = ""
  else
    -- Output first batch of items  
    local tmp = ""
    local backpackCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)
    for _, item in pairs(backpackCache) do
      local itemLink = GetItemLink(item.bagId, item.slotIndex, LINK_STYLE_BRACKETS)
      local _, knownByNameList, isGear = UT:IsValidAndWhoKnowsIt(itemLink)

      if knownByNameList[account] == 1 and isGear and not IsItemPlayerLocked(item.bagId, item.slotIndex) then
        tmp = items .. itemLink
        
        if zo_strlen(tmp) < CHAT_MAX then
          items = items .. itemLink
        else
          overflow = overflow .. itemLink        
        end
      end
    end
  end

  if items == "" then
    d("[UT] No tradeable gear")    
  else
    if IsUnitGrouped("player") then
      items = "/g " .. items 
    end

    CHAT_SYSTEM.textEntry:SetText(items)
    CHAT_SYSTEM:Maximize()
    CHAT_SYSTEM.textEntry:Open()
    CHAT_SYSTEM.textEntry:FadeIn()
  end
end


-- INITIALISATION -------------------------------------------------------------------------------
function UT:Initialise(waited)
  
  -- wait for pchat to be loaded for d() to work (need better way)
  if waited == nil then    
    zo_callLater(function() self:Initialise(true) end, 5000)
    return
  end

  groupMembers[GetUnitName('player')] = "You"

  -- gather info
  server = GetWorldName()
  account = GetUnitDisplayName("player")
  character = zo_strformat("<<1>>", GetRawUnitName("player"))
  local manager = GetAddOnManager()

  for i = 1, manager:GetNumAddOns() do
    local name, _, _, _, _, state = manager:GetAddOnInfo(i)
    if name == self.name then
      UnknownTracker.AddOnVersion = manager:GetAddOnVersion(i)
    end
  end

  -- UTOpts.displayTooltips to UTOpts.trackedCharacters upgrade
  if UTOpts then
    if UTOpts.displayTooltips then
      UTOpts.trackedCharacters = UTOpts.displayTooltips
      UTOpts.displayTooltips = nil
    end
  end

  -- scribing savedvariables update
  if UTMasterList then
    if UTMasterList["EU Megaserver"].affix == nil then UTMasterList["EU Megaserver"].affix = {} end
    if UTMasterList["EU Megaserver"].focus == nil then UTMasterList["EU Megaserver"].focus = {} end
    if UTMasterList["EU Megaserver"].signature == nil then UTMasterList["EU Megaserver"].signature = {} end

    if UTMasterList["NA Megaserver"].affix == nil then UTMasterList["NA Megaserver"].affix = {} end
    if UTMasterList["NA Megaserver"].focus == nil then UTMasterList["NA Megaserver"].focus = {} end
    if UTMasterList["NA Megaserver"].signature == nil then UTMasterList["NA Megaserver"].signature = {} end

    if UTMasterList["PTS"].affix == nil then UTMasterList["PTS"].affix = {} end
    if UTMasterList["PTS"].focus == nil then UTMasterList["PTS"].focus = {} end
    if UTMasterList["PTS"].signature == nil then UTMasterList["PTS"].signature = {} end
  end

  -- sv defaults
  UTMasterList = self:CheckDefaults(UTMasterList, self.defaultUTMasterList)
  UTDataDump = self:CheckDefaults(UTDataDump, self.defaultUTDataDump)
  UTOpts = self:CheckDefaults(UTOpts, self.defaultOpts)

  -- short
  m = UTMasterList[server]

  self:BuildCharacterList()
  self:HookBagTips()
  self:HookBags()
  self:SetupEvents(true)

  -- build datadump and populate masterlist using it (async)
  if UTDataDump == nil or UTOpts.APIVersion ~= GetAPIVersion() or UTOpts.AddOnVersion ~= UnknownTracker.AddOnVersion then
    self:BuildDataDump()
  else
    self:CheckMotifs()
    self:CheckRecipesAndFurniture()
    self:CheckStylePagesAndRuneboxes()
    self:CheckScribing()
  end

  UT:InitialiseAddonMenu()
end

function UT.OnLoad(event, addonName)
  if addonName ~= UnknownTracker.name then return end
  EVENT_MANAGER:UnregisterForEvent(UnknownTracker.name, EVENT_ADD_ON_LOADED, UT.OnLoad)
  UT:Initialise()
end

EVENT_MANAGER:RegisterForEvent(UnknownTracker.name, EVENT_ADD_ON_LOADED, UT.OnLoad)
LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, UT.HandleClickEvent) --as for Update 4 default ingame GUI uses this event
LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, UT.HandleClickEvent)  --this event still can be used, so the best practise is registering both events

-- function UnknownTracker:TradeableGear()
--   d("Tradeable Gear")  
--   --LibChatMessage("UT", "ut"):Print("LibChatMessage test...")

--   local backpackCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)
--   for _, item in pairs(backpackCache) do
--     local itemLink = GetItemLink(item.bagId, item.slotIndex, LINK_STYLE_BRACKETS)
--     local _, knownByNameList, isGear = UT:IsValidAndWhoKnowsIt(itemLink)

--     if knownByNameList[account] == 1 and isGear and not IsItemPlayerLocked(item.bagId, item.slotIndex) then
--       d(itemLink)
--     end
--   end

-- end

-- SLASH_COMMANDS["/UTg"] = function() UnknownTracker:TradeableGear() end

-- function UT:TradeableGear()
--   d("Tradeable Gear")  
--   --LibChatMessage("UT", "ut"):Print("LibChatMessage test...")
--   local items = ""

--   local backpackCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)
--   for _, item in pairs(backpackCache) do
--     local itemLink = GetItemLink(item.bagId, item.slotIndex, LINK_STYLE_BRACKETS)
--     local _, knownByNameList, isGear = UT:IsValidAndWhoKnowsIt(itemLink)

--     if knownByNameList[account] == 1 and isGear and not IsItemPlayerLocked(item.bagId, item.slotIndex) then      
--       items = items .. itemLink
--     end
--   end

--   -- CHAT_SYSTEM.textEntry:SetText(items)
--   -- CHAT_SYSTEM:Maximize()
--   -- CHAT_SYSTEM.textEntry:Open()
--   -- CHAT_SYSTEM.textEntry:FadeIn()

-- end

-- SLASH_COMMANDS["/UTg"] = function() UT:TradeableGear() end