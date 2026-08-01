-- Notice
-- Some Code based on Addon "UnknownTracker" from "kadeer"
-- ---------------------------------------------------------------

-- Create namespace
DsRGuildUnknown = {}
local DsRGuildUnknown = DsRGuildUnknown  or {}

DsRGuildUnknown.name = "DsRGuildUnknown"

local account
local server
local character
local allCharacters = {}
local allAccounts = {}
local m = nil
local groupMembers = {}

local DsRIcon = DsRglobals:HolidayIconLoad()

-- MISSING CONSTANTS in api (used in DsRGuildUnknown.lua and data.lua)
ITEMTYPE_SCRIBINGX              = 73      -- update from here
SPECIALIZED_ITEMTYPE_AFFIXX     = 3252    -- https://wiki.esoui.com/Globals#ItemType
SPECIALIZED_ITEMTYPE_FOCUSX     = 3250    -- https://wiki.esoui.com/Globals#SpecializedItemType
SPECIALIZED_ITEMTYPE_SIGNATUREX = 3251

local VALID_ITEMTYPES = {
  [ITEMTYPE_RACIAL_STYLE_MOTIF] = true,
  [ITEMTYPE_RECIPE]             = true,
  [ITEMTYPE_COLLECTIBLE]        = true,
  [ITEMTYPE_CONTAINER]          = true,
  [ITEMTYPE_ARMOR]              = true,
  [ITEMTYPE_WEAPON]             = true,
  [ITEMTYPE_SCRIBINGX]          = true, -- check constants.lua and update if api changed
}

-------------------------------------------------------------------------------------------------------------------------------------------------
-- @Shadowfen - AutoCategory integration
function DsRGuildUnknown:GetCharacterList()
  -- Build character lists if they don't exist
  if next(allCharacters) == nil then
     DsRGuildUnknown:BuildCharacterList()
  end
  -- return lists
  return allCharacters, allAccounts
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknown:IsItemLinkKnownUnknown(itemLink)
  local known = false
  local itemType, specializedItemType = GetItemLinkItemType(itemLink)
  if itemType == ITEMTYPE_RECIPE then
    known = IsItemLinkRecipeKnown(itemLink)
  end
  if itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
    known = IsItemLinkBookKnown(itemLink)
  end

  if DsRGuildUnknown:IsItemLinkLearnedCollectible(specializedItemType) then
    if DsRGuildUnknown:IsCollectibleValidForPlayer(itemLink) then
      local containerCollectibleId = GetItemLinkContainerCollectibleId(itemLink)
      known = IsCollectibleUnlocked(containerCollectibleId)
    end
  end
  return known
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknown:IsItemLinkLearnedCollectible(specializedItemType)
  if not specializedItemType then return false end
  local specializedItemtypesOfContainers = {
    [SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE] = true,
    [SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE] = true,
    [SPECIALIZED_ITEMTYPE_CONTAINER] = true,
  }
  if specializedItemtypesOfContainers[specializedItemType] then
    return true
  end
  return false
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknown:IsCollectibleValidForPlayer(itemLink)
  local containerCollectibleId = GetItemLinkContainerCollectibleId(itemLink)
  local isValidForPlayer = IsCollectibleValidForPlayer(containerCollectibleId)
  if isValidForPlayer then
    return true
  end
  return false
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknown:IsValidAndWhoKnowsIt(itemLink)
  local itemId          = GetItemLinkItemId(itemLink)
  local itemType, specializedType = GetItemLinkItemType(itemLink)
  local isValid         = false         -- make sure its a valid itemtype because knownByNameList can be nil sometimes even with correct itemtype
  local knownByNameList = {}
  local isGear          = false
  local isCrafted       = false

  if VALID_ITEMTYPES[itemType] == nil then
    return false, {}
  end

  if itemType == ITEMTYPE_RACIAL_STYLE_MOTIF and DsRGuildUnknownOpts.displayMotifs then
    isValid = true
    local rootItemId = nil

    if DsRGuildUnknownDD.motifData[itemId] ~= nil then
      rootItemId = itemId
    else
      local NumChapters = NonContiguousCount(DsRGuildUnknownDefaults.CHAPTERS)

      for i = 1, NumChapters do
        if DsRGuildUnknownDD.motifData[itemId-i] ~= nil then
          rootItemId = itemId-i
          break
        end
      end
    end

    if rootItemId then
      local characters = m.motifs[rootItemId]

      if characters ~= nil then
        for name, v in pairs(characters) do
          if v == 1 or v[itemId] ~= nil then
            knownByNameList[name] = 1
          end
        end
      end
      knownByNameList = DsRGuildUnknownUtility:TrimList(knownByNameList, allCharacters)
    else
      isValid = false
    end
  end

  if itemType == ITEMTYPE_RECIPE then
    local isFurniture = IsItemLinkFurnitureRecipe(itemLink)

    if isFurniture and DsRGuildUnknownOpts.displayFurnishings then
      isValid = true
      knownByNameList = m.furnishings[itemId]
      knownByNameList = DsRGuildUnknownUtility:TrimList(knownByNameList, allCharacters)
    elseif ( specializedType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK or specializedType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD ) and DsRGuildUnknownOpts.displayRecipes then
      isValid = true
      knownByNameList = m.recipes[itemId]
      knownByNameList = DsRGuildUnknownUtility:TrimList(knownByNameList, allCharacters)
    end
  end

  if itemType == ITEMTYPE_CONTAINER or itemType == ITEMTYPE_COLLECTIBLE then
    local linkIcon = GetItemLinkIcon(itemLink)

    if (linkIcon == DsRGuildUnknownDefaults.STYLEPAGE_ICON_PATH1 or linkIcon == DsRGuildUnknownDefaults.STYLEPAGE_ICON_PATH2) and DsRGuildUnknownOpts.displayStylepages then
      isValid = true
      knownByNameList = m.stylepages[itemId]
    end
    if linkIcon == DsRGuildUnknownDefaults.RUNEBOX_ICON_PATH1 and DsRGuildUnknownOpts.displayRuneboxes then
      isValid = true
      knownByNameList = m.runeboxes[itemId]
    end
  end

  if DsRGuildUnknownOpts.displayScribing then
    if itemType == ITEMTYPE_SCRIBINGX then
      if specializedType == SPECIALIZED_ITEMTYPE_AFFIXX then
        isValid = true
        knownByNameList = m.affix[itemId]
        knownByNameList = DsRGuildUnknownUtility:TrimList(knownByNameList, allCharacters)
      elseif specializedType == SPECIALIZED_ITEMTYPE_FOCUSX then
        isValid = true
        knownByNameList = m.focus[itemId]
        knownByNameList = DsRGuildUnknownUtility:TrimList(knownByNameList, allCharacters)
      elseif specializedType == SPECIALIZED_ITEMTYPE_SIGNATUREX then
        isValid = true
        knownByNameList = m.signature[itemId]
        knownByNameList = DsRGuildUnknownUtility:TrimList(knownByNameList, allCharacters)
      end
    end
  end

  return isValid, knownByNameList, isGear, isCrafted
end
-------------------------------------------------------------------------------------------------------------------------------------------------
-- TOOLTIPS
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknown:SetTooltip(tooltip, itemLink)
  if DsRGuildUnknownOpts.TrackerTooltipOnOff == false then return end
  if DsRGuildUnknownOpts.displayTooltip == false then return end

  local linkIcon = GetItemLinkIcon(itemLink)
  local itemType, specializedItemType = GetItemLinkItemType(itemLink)
  if specializedItemType == SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE or specializedItemType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE or specializedItemType == SPECIALIZED_ITEMTYPE_CONTAINER then return end

  local isValid, knownByNameList, isGear, isCrafted = DsRGuildUnknown:IsValidAndWhoKnowsIt(itemLink)
  if not isValid then return end
  if isGear      then return end
  if isCrafted   then return end

  local itemType    = GetItemLinkItemType(itemLink)
  local allLearners = (itemType == ITEMTYPE_CONTAINER or itemType == ITEMTYPE_COLLECTIBLE) and allAccounts or allCharacters
  local outstr      = ""
  local out         = {}
  local outsort     = {}
  local me          = GetUnitName("player")

  for k, name in pairs(allLearners) do
    local CharSettings = DsRGuildUnknownChars["trackedCharacters"][GetWorldName()][GetUnitDisplayName("player")]["characters"][k]
    local Color        = {}

    if knownByNameList ~= nil and knownByNameList[name] then
        if name == me then
          Color = zo_strsub(DsRGuildUnknownOpts.knownByAllColour , 1 , 6)
          name = "|c" .. Color .. "|L0:1:1:+10%:2:999999|l" .. name .. "|l|r"
        else
          name = DsRGuildUnknownUtility:SetColour(name, DsRGuildUnknownOpts.knownByAllColour)
        end
        table.insert(out, { name = name, prio = CharSettings.settingPrio })
      else
        if name == me then
          Color = zo_strsub(DsRGuildUnknownOpts.unknownColour , 1 , 6)
          name = "|c" .. Color .. "|L0:1:1:+10%:2:999999|l" .. name .. "|l|r"
        else
          name = DsRGuildUnknownUtility:SetColour(name, DsRGuildUnknownOpts.unknownColour)
        end
        table.insert(out, { name = name, prio = CharSettings.settingPrio })
    end 
  end

  table.sort(out, function(a, b) return tostring(a.prio) < tostring(b.prio) end)
  
  for key, value in pairs( out ) do
    table.insert(outsort, value.name)
  end

  outstr = table.concat(outsort, ", ")

  if outstr then
    tooltip:AddVerticalPadding(5)
    ZO_Tooltip_AddDivider(tooltip)
    tooltip:AddLine(zo_iconFormat(DsRIcon, 30, 30) .. "|c9fb6cdDsR-Unknown|r" .. zo_iconFormat(DsRIcon, 30, 30), "ZoFontGameBold", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
    tooltip:AddLine(zo_strformat(outstr), "$(MEDIUM_FONT)|$(KB_14)", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
  end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknown:TooltipHook(tooltipControl, method, linkFunc)
  local origMethod = tooltipControl[method]

  tooltipControl[method] = function(self, ...)
    origMethod(self, ...)
    DsRGuildUnknown:SetTooltip(self, linkFunc(...))
  end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknown:HookBagTips()
  self:TooltipHook(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
  self:TooltipHook(ItemTooltip, "SetBagItem", GetItemLink)
  self:TooltipHook(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
  self:TooltipHook(ItemTooltip, "SetLootItem", GetLootItemLink)
  self:TooltipHook(ItemTooltip, "SetTradeItem", GetTradeItemLink)
  self:TooltipHook(ItemTooltip, "SetStoreItem", GetStoreItemLink)
  self:TooltipHook(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
  self:TooltipHook(PopupTooltip, "SetLink", function(...) return ... end)

  if AwesomeGuildStore then
    AwesomeGuildStore:RegisterCallback(AwesomeGuildStore.callback.AFTER_INITIAL_SETUP, function()
      self:TooltipHook(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
    end)
  else
    self:TooltipHook(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
  end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY ICON
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknown:SetInventoryIcon(control, itemLink, tradingHouse)
  if DsRGuildUnknownOpts.TrackerIconOnOff == false then return end
  if DsRGuildUnknownOpts.displayInventory == false then return end

  if not control or not itemLink then d("DsRGuildUnknown: Missing control/itemLink") return end

  local itemType, specializedItemType = GetItemLinkItemType(itemLink)

  local c = control:GetNamedChild("DsRUnknownIcon")
  if c then c:SetHidden(true) end

  local isValid, knownByNameList, isGear, isCrafted = DsRGuildUnknown:IsValidAndWhoKnowsIt(itemLink)
  if not isValid then return end

  local itemType = GetItemLinkItemType(itemLink)
  local allLearners = (itemType == ITEMTYPE_CONTAINER or itemType == ITEMTYPE_COLLECTIBLE) and allAccounts or allCharacters
  local name = (itemType == ITEMTYPE_CONTAINER or itemType == ITEMTYPE_COLLECTIBLE)  and account or character

  if not c then
    c = WINDOW_MANAGER:CreateControl(control:GetName() .. "DsRUnknownIcon", control, CT_TEXTURE)
  end

  c:ClearAnchors()
  c:SetDimensions(DsRGuildUnknownOpts.iconSize, DsRGuildUnknownOpts.iconSize)
  c:SetDrawLevel(DsRGuildUnknownOpts.iconDrawLevel)

  if tradingHouse and DsRGuildUnknownOpts.inventoryIconPosition == 1 then
      c:SetAnchor(CENTER, control:GetNamedChild("Button"), CENTER, DsRGuildUnknownOpts.iconXOffset, DsRGuildUnknownOpts.iconYOffset)
  elseif DsRGuildUnknownOpts.inventoryIconPosition == 1 then
    c:SetAnchor(CENTER, control:GetNamedChild("Status"), CENTER, DsRGuildUnknownOpts.iconXOffset, DsRGuildUnknownOpts.iconYOffset)
  elseif DsRGuildUnknownOpts.inventoryIconPosition == 2 then
    c:SetAnchor(CENTER, control:GetNamedChild("Button"), CENTER, DsRGuildUnknownOpts.iconXOffset, DsRGuildUnknownOpts.iconYOffset)
  else
    c:SetAnchor(CENTER, control:GetNamedChild("TraitInfo"), CENTER, DsRGuildUnknownOpts.iconXOffset, DsRGuildUnknownOpts.iconYOffset)
  end
  
  local isLearning = false
  for i = 1, #allLearners do
    if allLearners[i] == name then
      isLearning = true
    end
  end

  local r, g, b, a = DsRGuildUnknownUtility:ConvertHexToRGBA(DsRGuildUnknownOpts.knownBySomeColour)
  local isUnknown  = false
  local Unknown    = "ANY"

  if knownByNameList == nil or (knownByNameList ~= nil and knownByNameList[name] == nil) then
    if isLearning then
      r, g, b, a = DsRGuildUnknownUtility:ConvertHexToRGBA(DsRGuildUnknownOpts.unknownColour)
    end
    isUnknown = true
    Unknown   = "CHAR"
  end
  
  if knownByNameList ~= nil and allLearners ~= nil then
    if NonContiguousCount(knownByNameList) == NonContiguousCount(allLearners) then
      r, g, b, a = DsRGuildUnknownUtility:ConvertHexToRGBA(DsRGuildUnknownOpts.knownByAllColour)
      isUnknown  = false
      Unknown    = "ALL"
    end
  end

  if specializedItemType == SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE or specializedItemType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE or specializedItemType == SPECIALIZED_ITEMTYPE_CONTAINER then
    local Known = DsRGuildUnknown:IsItemLinkKnownUnknown(itemLink)
    if Known then
      r, g, b, a = DsRGuildUnknownUtility:ConvertHexToRGBA(DsRGuildUnknownOpts.knownByAllColour)
      isUnknown  = false
      Unknown    = "ALL"
    else
      r, g, b, a = DsRGuildUnknownUtility:ConvertHexToRGBA(DsRGuildUnknownOpts.unknownColour)
      isUnknown  = true
      Unknown    = "CHAR"
    end
  end

  if DsRGuildUnknownOpts.displayOnlyIfUnknownINV and isUnknown == false then
    c:SetHidden(true)
    return
  end
  
  if DsRGuildUnknownOpts.MultiIconUseOnOff then
    if Unknown == "ANY" then
      c:SetTexture("/esoui/art/buttons/plus_up.dds")
    elseif Unknown == "CHAR" then
      c:SetTexture("/esoui/art/buttons/decline_up.dds")
    elseif Unknown == "ALL" then
      c:SetTexture("/esoui/art/buttons/accept_up.dds")
    end
  else
    c:SetTexture(DsRGuildUnknownOpts.inventoryIconStyle)
  end
  
  c:SetColor(r, g, b, a)  
  c:SetHidden(false)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknown:HookBags()
  for k,v in pairs(PLAYER_INVENTORY.inventories) do
    local listView = v.listView
    if ( listView and listView.dataTypes and listView.dataTypes[1] ) then
      ZO_PreHook(listView.dataTypes[1], "setupCallback", function(control, slot)
        local itemLink = GetItemLink(control.dataEntry.data.bagId, control.dataEntry.data.slotIndex, LINK_STYLE_BRACKETS)
        DsRGuildUnknown:SetInventoryIcon(control, itemLink)
      end)
    end
  end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- CHECK KNOWN
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknown:CheckMotifs()

  if DsRGuildUnknownDD.motifData ~= nil then
    for bookId, v in pairs(DsRGuildUnknownDD.motifData) do
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
        local NumChapters = NonContiguousCount(DsRGuildUnknownDefaults.CHAPTERS)

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

  DsRGuildUnknownUtility:ClearEmptyTables(m.motifs)
  DsRGuildUnknown:RefreshViews()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknown:CheckRecipesAndFurniture()
  local itemLink = ""

  if DsRGuildUnknownDD.recipeData ~= nil then
    for itemId, v in pairs(DsRGuildUnknownDD.recipeData) do
      itemLink = ("|H1:item:%d:299:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"):format(itemId)
      m.recipes[itemId] = m.recipes[itemId] or {}

      if IsItemLinkRecipeKnown(itemLink) then
        m.recipes[itemId][character] = 1
      else
        m.recipes[itemId][character] = nil                  -- making sure character is nil
      end
    end
  end

  DsRGuildUnknownUtility:ClearEmptyTables(m.recipes)
  DsRGuildUnknown:RefreshViews()

  if DsRGuildUnknownDD.furnitureData ~= nil then
    for itemId, v in pairs(DsRGuildUnknownDD.furnitureData) do
      itemLink = ("|H1:item:%d:299:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"):format(itemId)
      m.furnishings[itemId] = m.furnishings[itemId] or {}

      if IsItemLinkRecipeKnown(itemLink) then
        m.furnishings[itemId][character] = 1
      else
        m.furnishings[itemId][character] = nil
      end
    end
  end

  DsRGuildUnknownUtility:ClearEmptyTables(m.furnishings)
  DsRGuildUnknown:RefreshViews()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknown:CheckStylePagesAndRuneboxes()
  local collectibleId
  local itemLink

  if DsRGuildUnknownDD.stylepageData ~= nil then
    for itemId, v in pairs(DsRGuildUnknownDD.stylepageData) do
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

  if DsRGuildUnknownDD.runeboxData ~= nil then
    for itemId, v in pairs(DsRGuildUnknownDD.runeboxData) do
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

  DsRGuildUnknownUtility:ClearEmptyTables(m.runeboxes)
  DsRGuildUnknownUtility:ClearEmptyTables(m.stylepages)
  DsRGuildUnknown:RefreshViews()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknown:CheckScribing()
  if DsRGuildUnknownDD.affixData ~= nil then
    for itemId, v in pairs(DsRGuildUnknownDD.affixData) do
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

  DsRGuildUnknownUtility:ClearEmptyTables(m.affix)
  DsRGuildUnknown:RefreshViews()

  if DsRGuildUnknownDD.focusData ~= nil then
    for itemId, v in pairs(DsRGuildUnknownDD.focusData) do
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

  DsRGuildUnknownUtility:ClearEmptyTables(m.focus)
  DsRGuildUnknown:RefreshViews()

  if DsRGuildUnknownDD.signatureData ~= nil then
    for itemId, v in pairs(DsRGuildUnknownDD.signatureData) do
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

  DsRGuildUnknownUtility:ClearEmptyTables(m.signature)
  DsRGuildUnknown:RefreshViews()

end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- CHAT ICON
-------------------------------------------------------------------------------------------------------------------------------------------------
local function DsRGuildUnknown_Mark_ParseItemLinks(message, location, fromDisplayName, messageType)

  if (not message) then
    return nil, nil
  end

  local itemsString = ""
  local withIcons = {}
  local count = 0
  
  for itemLink in string.gmatch(message, "(|H%d:item:.-|h|h)") do
    local itemType, specializedItemType = GetItemLinkItemType ( itemLink )
    if itemType == ITEMTYPE_CRAFTED_ABILITY_SCRIPT or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD or specializedItemType == 172 or specializedItemType == 173 or specializedItemType == 174 or specializedItemType == 175 or specializedItemType == 176 or specializedItemType == 177 or specializedItemType == 178 or specializedItemType == SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK or specializedItemType == SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER or specializedItemType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE or itemType == ITEMTYPE_COLLECTIBLE then
      local isValid, knownByNameList, isGear, isCrafted = DsRGuildUnknown:IsValidAndWhoKnowsIt(itemLink)

      local itemType = GetItemLinkItemType(itemLink)
      local allLearners = (itemType == ITEMTYPE_CONTAINER or itemType == ITEMTYPE_COLLECTIBLE) and allAccounts or allCharacters
      local name = (itemType == ITEMTYPE_CONTAINER or itemType == ITEMTYPE_COLLECTIBLE)  and account or character

      local isLearning = false
      for i = 1, #allLearners do
        if allLearners[i] == name then
          isLearning = true
        end
      end
    
      local Color = zo_strsub(DsRGuildUnknownOpts.knownBySomeColour , 1 , 6)
      local Unknown = "ANY"
      
      if knownByNameList == nil or (knownByNameList ~= nil and knownByNameList[name] == nil) then
        if isLearning then
          Color = zo_strsub(DsRGuildUnknownOpts.unknownColour , 1 , 6)
          Unknown = "CHAR"
        end
      end
      
      if knownByNameList ~= nil and allLearners ~= nil then
        if NonContiguousCount(knownByNameList) == NonContiguousCount(allLearners) then
          Color = zo_strsub(DsRGuildUnknownOpts.knownByAllColour , 1 , 6)
          Unknown = "ALL"
        end
      end

      if specializedItemType == SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE or specializedItemType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE or specializedItemType == SPECIALIZED_ITEMTYPE_CONTAINER then
        local Known = DsRGuildUnknown:IsItemLinkKnownUnknown(itemLink)
        if Known then
          Color = zo_strsub(DsRGuildUnknownOpts.knownByAllColour , 1 , 6)
          Unknown = "ALL"
        else
          Color = zo_strsub(DsRGuildUnknownOpts.unknownColour , 1 , 6)
          Unknown = "CHAR"
        end
      end
    
      local icon = DsRGuildUnknownOpts.inventoryIconStyle

      if DsRGuildUnknownOpts.MultiIconUseOnOff then
        if Unknown == "ANY" then
          icon = "/esoui/art/buttons/plus_up.dds"
        elseif Unknown == "CHAR" then
          icon = "/esoui/art/buttons/decline_up.dds"
        elseif Unknown == "ALL" then
          icon = "/esoui/art/buttons/accept_up.dds"
        end
      end
    
      if DsRGuildUnknownOpts.displayOnlyIfUnknownCHAT then
        if Unknown == "CHAR" then
          withIcons[itemLink] = string.format("|c".. Color .. "|t24:24:%s:inheritcolor|t|r", icon ) .. itemLink
        else
          withIcons[itemLink] = itemLink
        end
      else
        withIcons[itemLink] = string.format("|c".. Color .. "|t24:24:%s:inheritcolor|t|r", icon ) .. itemLink
      end
    end

    itemsString = itemsString .. itemLink
    count = count + 1
  end
    
  if (count == 0) then
    return message, nil
  end
    
  for link, withIcon in pairs(withIcons) do
    message = string.gsub(message, link, withIcon)
  end
  return message, requestKey
end
    
-------------------------------------------------------------------------------------------------------------------------------------------------
local function DsRGuildUnknown_Mark_SetupChatHooks()
  local function DsRGuildUnknown_Mark_AddIconToSystem(origMessage)
    return DsRGuildUnknown_Mark_ParseItemLinks(origMessage, "Beginning")
  end

  local previousFormatter = CHAT_ROUTER:GetRegisteredMessageFormatters()["AddSystemMessage"]
  if (previousFormatter) then
    CHAT_ROUTER:RegisterMessageFormatter("AddSystemMessage", function(...)
      return DsRGuildUnknown_Mark_AddIconToSystem(previousFormatter(...))
    end)
  else
    CHAT_ROUTER:RegisterMessageFormatter("AddSystemMessage", DsRGuildUnknown_Mark_AddIconToSystem)
  end
    
  local function DsRGuildUnknown_Mark_AddIconToMessage(messageType, fromName, text, isFromCustomerService, fromDisplayName)
    formattedText, requestKey = DsRGuildUnknown_Mark_ParseItemLinks(text, "Before", fromDisplayName, messageType)
    
    local channelInfo = ZO_ChatSystem_GetChannelInfo()[messageType]
    if (not channelInfo or not channelInfo.format) then
      return
    end
    
    return formattedText, channelInfo.saveTarget
  end

  local oldFormatter = CHAT_ROUTER:GetRegisteredMessageFormatters()[EVENT_CHAT_MESSAGE_CHANNEL]
  if (oldFormatter) then
    CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, function(messageType, fromName, text, isFromCustomerService, fromDisplayName)
      local oldText = oldFormatter(messageType, fromName, text, isFromCustomerService, fromDisplayName)
      return DsRGuildUnknown_Mark_AddIconToMessage(messageType, fromName, oldText, isFromCustomerService, fromDisplayName)
    end)
  else
    CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, DsRGuildUnknown_Mark_AddIconToMessage)
  end
  EVENT_MANAGER:UnregisterForEvent(DsRGuildUnknown.name .. "Activated", EVENT_PLAYER_ACTIVATED)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- GENERAL
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknown:RefreshViews()
  ZO_ScrollList_RefreshVisible(ZO_PlayerInventoryBackpack)
  ZO_ScrollList_RefreshVisible(ZO_PlayerBankBackpack)
  ZO_ScrollList_RefreshVisible(ZO_GuildBankBackpack)
  ZO_ScrollList_RefreshVisible(ZO_StoreWindowList)
  ZO_ScrollList_RefreshVisible(ZO_TradingHouseBrowseItemsRightPaneSearchResults)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknown:PurgeCharacter(name)
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

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknown:BuildCharacterList()
  allCharacters = {}

  if DsRGuildUnknownChars["trackedCharacters"][server][account] == nil then
    DsRGuildUnknownChars["trackedCharacters"][server][account] = { isEnabled=true, characters={} }
  end

  local tcsa = DsRGuildUnknownChars["trackedCharacters"][server][account]

  local exisitingCharacters = {}
  local numChars = GetNumCharacters()
  local c = ""

  for i = 1, numChars do
    c = zo_strformat(SI_UNIT_NAME, GetCharacterInfo(i))
    exisitingCharacters[i] = tcsa.characters[i] and tcsa.characters[i] or { name=c, setting=1, settingPrio=20 }

    if exisitingCharacters[i]["name"] ~= c then
      DsRGuildUnknown:PurgeCharacter(exisitingCharacters[i]["name"])

      exisitingCharacters[i]["name"] = c
    end
  end

  tcsa.characters = exisitingCharacters

  if tcsa.isEnabled then
    for i = 1, #tcsa.characters do
      if tcsa.characters[i].setting == 1 then
        allCharacters[#allCharacters+1] = tcsa.characters[i].name
      end
    end
  end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknown:HookStore()
  --ZO_StoreWindow List
  local listView = ZO_StoreWindowList
  if ( listView and listView.dataTypes and listView.dataTypes[1] ) then
    ZO_PreHook(listView.dataTypes[1], "setupCallback", function(control, slot)
      local itemLink = GetStoreItemLink(slot.slotIndex)
      DsRGuildUnknown:SetInventoryIcon(control, itemLink)
    end)
  end

  --ZO_BuyBack List
  listView = ZO_BuyBackList
  if ( listView and listView.dataTypes and listView.dataTypes[1] ) then
    ZO_PreHook(listView.dataTypes[1], "setupCallback", function(control, slot)
      local itemLink = GetBuybackItemLink(slot.slotIndex)
      DsRGuildUnknown:SetInventoryIcon(control, itemLink)
    end)
  end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknown:HookTradingHouse()
  local listView = ZO_TradingHouseBrowseItemsRightPaneSearchResults
  if ( listView and listView.dataTypes and listView.dataTypes[1] ) then
    ZO_PreHook(listView.dataTypes[1], "setupCallback", function(control, slot)
      local itemLink = GetTradingHouseSearchResultItemLink(slot.slotIndex)
      DsRGuildUnknown:SetInventoryIcon(control, itemLink, true)
    end)
  end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknown:OnGroupChanged()
  gsize = GetGroupSize()
  for i = 1, gsize do
    groupMembers[GetUnitName('group' .. i)] = GetUnitDisplayName('group' .. i)
  end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknown:OnScriptUnlocked(craftedAbilityScriptDefId, isUnlocked)
  if isUnlocked then
    DsRGuildUnknown:CheckScribing()
  end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknown:SetupEvents(toggle)
  if toggle then
    EVENT_MANAGER:RegisterForEvent(DsRGuildUnknown.name, EVENT_COLLECTIBLE_NOTIFICATION_NEW, function(...) DsRGuildUnknown:CheckStylePagesAndRuneboxes(...) end)
    EVENT_MANAGER:RegisterForEvent(DsRGuildUnknown.name, EVENT_STYLE_LEARNED ,               function(...) DsRGuildUnknown:CheckMotifs(...) end)
    EVENT_MANAGER:RegisterForEvent(DsRGuildUnknown.name, EVENT_RECIPE_LEARNED,               function(...) DsRGuildUnknown:CheckRecipesAndFurniture(...) end)
    EVENT_MANAGER:RegisterForEvent(DsRGuildUnknown.name, EVENT_MULTIPLE_RECIPES_LEARNED,     function(...) DsRGuildUnknown:CheckRecipesAndFurniture(...) end)
    EVENT_MANAGER:RegisterForEvent(DsRGuildUnknown.name, EVENT_OPEN_STORE,                   function(...) DsRGuildUnknown:HookStore(...) end)
    EVENT_MANAGER:RegisterForEvent(DsRGuildUnknown.name, EVENT_OPEN_TRADING_HOUSE,           function(...) DsRGuildUnknown:HookTradingHouse(...) end)
    EVENT_MANAGER:RegisterForEvent(DsRGuildUnknown.name, EVENT_GROUP_MEMBER_JOINED,          function(...) DsRGuildUnknown:OnGroupChanged(...) end)

    EVENT_MANAGER:RegisterForEvent(DsRGuildUnknown.name, EVENT_CRAFTED_ABILITY_SCRIPT_LOCK_STATE_CHANGED, function(...) DsRGuildUnknown:OnScriptUnlocked(...) end)
  else    
    EVENT_MANAGER:UnregisterForEvent(DsRGuildUnknown.name, EVENT_COLLECTIBLE_NOTIFICATION_NEW)
    EVENT_MANAGER:UnregisterForEvent(DsRGuildUnknown.name, EVENT_RECIPE_LEARNED)
    EVENT_MANAGER:UnregisterForEvent(DsRGuildUnknown.name, EVENT_STYLE_LEARNED)
    EVENT_MANAGER:UnregisterForEvent(DsRGuildUnknown.name, EVENT_LOOT_RECEIVED)
    EVENT_MANAGER:UnregisterForEvent(DsRGuildUnknown.name, EVENT_GROUP_MEMBER_JOINED)
  end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- INITIALISATION
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknown:Initialise()
  groupMembers[GetUnitName('player')] = "You"

  server        = GetWorldName()
  account       = GetUnitDisplayName("player")
  character     = zo_strformat("<<1>>", GetRawUnitName("player"))
  local manager = GetAddOnManager()

  for i = 1, manager:GetNumAddOns() do
    local name, _, _, _, _, state = manager:GetAddOnInfo(i)
    if name == DsRGuildUnknown.name then
      DsRVersion.AddOnVersion = manager:GetAddOnVersion(i)
    end
  end

  if DsRGuildUnknownOpts then
    if DsRGuildUnknownOpts.displayTooltips then
      DsRGuildUnknownChars["trackedCharacters"] = DsRGuildUnknownOpts.displayTooltips
      DsRGuildUnknownOpts.displayTooltips = nil
    end
  end

  if DsRGuildUnknownML then
    if DsRGuildUnknownML["EU Megaserver"].affix == nil then DsRGuildUnknownML["EU Megaserver"].affix = {} end
    if DsRGuildUnknownML["EU Megaserver"].focus == nil then DsRGuildUnknownML["EU Megaserver"].focus = {} end
    if DsRGuildUnknownML["EU Megaserver"].signature == nil then DsRGuildUnknownML["EU Megaserver"].signature = {} end

    if DsRGuildUnknownML["NA Megaserver"].affix == nil then DsRGuildUnknownML["NA Megaserver"].affix = {} end
    if DsRGuildUnknownML["NA Megaserver"].focus == nil then DsRGuildUnknownML["NA Megaserver"].focus = {} end
    if DsRGuildUnknownML["NA Megaserver"].signature == nil then DsRGuildUnknownML["NA Megaserver"].signature = {} end

    if DsRGuildUnknownML["PTS"].affix == nil then DsRGuildUnknownML["PTS"].affix = {} end
    if DsRGuildUnknownML["PTS"].focus == nil then DsRGuildUnknownML["PTS"].focus = {} end
    if DsRGuildUnknownML["PTS"].signature == nil then DsRGuildUnknownML["PTS"].signature = {} end
  end

  DsRGuildUnknownML    = DsRGuildUnknownUtility:CheckDefaults(DsRGuildUnknownML,    DsRGuildUnknownDefaults.defaultDsRGuildUnknownConstantsML)
  DsRGuildUnknownDD    = DsRGuildUnknownUtility:CheckDefaults(DsRGuildUnknownDD,    DsRGuildUnknownDefaults.defaultDsRGuildUnknownConstantsDD)
  DsRGuildUnknownChars = DsRGuildUnknownUtility:CheckDefaults(DsRGuildUnknownChars,  DsRGuildUnknownDefaults.CharTrack)
  DsRGuildUnknownOpts  = DsRGuildUnknownUtility:CheckDefaults(DsRGuildUnknownOpts,  DsRGuildUnknownDefaults.defaultOpts)

  m = DsRGuildUnknownML[server]

  DsRGuildUnknown:BuildCharacterList()
  DsRGuildUnknown:HookBagTips()
  DsRGuildUnknown:HookBags()
  DsRGuildUnknown:SetupEvents(true)
  DsRGuildUnknownMenu:SetupMenueSettings()

  if DsRGuildUnknownDD == nil or DsRGuildUnknownOpts.APIVersion ~= GetAPIVersion() or DsRGuildUnknownOpts.AddOnVersion ~= DsRVersion.AddOnVersion then
    DsRGuildUnknownData:BuildDataDump()
  else
    DsRGuildUnknown:CheckMotifs()
    DsRGuildUnknown:CheckRecipesAndFurniture()
    DsRGuildUnknown:CheckStylePagesAndRuneboxes()
    DsRGuildUnknown:CheckScribing()
  end

  if DsRGuildUnknownOpts.TrackerOnOff == true then
    DsRGuildUnknownOpts.TrackerTooltipOnOff = false
    DsRGuildUnknownOpts.TrackerIconOnOff    = false
    DsRGuildUnknownOpts.TrackerChatOnOff    = false
  else
    DsRGuildUnknownOpts.TrackerTooltipOnOff = true
    DsRGuildUnknownOpts.TrackerIconOnOff    = true
    DsRGuildUnknownOpts.TrackerChatOnOff    = true
  end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- OnPlayerActivated
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknown.OnPlayerActivated()
	if (pChat or rChat) then
		EVENT_MANAGER:RegisterForUpdate(DsRGuildUnknown.name .. "DelayedActivated", 500,
			function()
				EVENT_MANAGER:UnregisterForUpdate(DsRGuildUnknown.name .. "DelayedActivated")
				DsRGuildUnknown_Mark_SetupChatHooks()
			end)
	else
		DsRGuildUnknown_Mark_SetupChatHooks()
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- On addon loaded
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildUnknown.OnAddonLoaded(event, addonName)
    EVENT_MANAGER:UnregisterForEvent ("DsRGuildUnknown", EVENT_ADD_ON_LOADED )
    DsRGuildUnknown:Initialise()

    if DsRGuildUnknownOpts.displayChat then
      if DsRGuildUnknownOpts.TrackerChatOnOff then
        EVENT_MANAGER:RegisterForEvent(DsRGuildUnknown.name .. "Activated", EVENT_PLAYER_ACTIVATED, DsRGuildUnknown.OnPlayerActivated)
      end
    end
end
