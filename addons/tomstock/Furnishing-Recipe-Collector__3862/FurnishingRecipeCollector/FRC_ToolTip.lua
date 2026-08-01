FurnishingRecipeCollector = FurnishingRecipeCollector or {}
local FRC = FurnishingRecipeCollector

--------------------------------------------------------------------
-- Locals
--------------------------------------------------------------------
--ZOs local speed-up/reference variables
local tos = tostring
local LCK = LibCharacterKnowledge
local SLASH = LibSlashCommander

local function adjustToolTip(tooltipControl, itemLink)
  local fontStyle = "MEDIUM_FONT"
  local fontSizeH1 = 14
  local fontSizeH2 = 12
  local fontWeight = "soft-shadow-thin"
  local vItemLinkId, vItemName, vItemFunctionalQuality, vItemType, vSpecialType, vFolioItemLinkId, vFolioItemLink, vFolioItemName, vRecipeItemLinkId, vRecipeItemLink, vRecipeItemName, vGrabBagItemLinkId, vGrabBagItemLink, vGrabBagItemName, vLocation, vResultLinkId, vResultLink, vResultName, vRecipePrice, vRecipeListing = FRC.GetRecipeDetail(itemLink)

  if vItemType == ITEMTYPE_CONTAINER then
    if FRC.logger ~= nil then FRC.logger:Verbose("Container ItemLinkID: ["..tos(vItemLinkId).."] "..tos(vItemName)) end
  end

  --This large if statement handles items tracked by the data files.
  if vRecipeItemLinkId ~= nil and (vFolioItemLinkId ~= nil or vGrabBagItemLinkId ~= nil or vLocation ~= nil) then
    --Recipe or Furnishing from a folio or grab bag

    if vItemType == ITEMTYPE_FURNISHING and FRC.savedVariables.furnishing_on == false then
      return
    elseif vItemType ~= ITEMTYPE_FURNISHING and FRC.savedVariables.furnishingrecipe_on == false then
      return
    end

    local vVendorCharacterString, vVendorRecipeCount = FRC.GetWritVendorContainerStats(vFolioItemLinkId or vGrabBagItemLinkId)

    if (vFolioItemLinkId ~= nil and FRC.savedVariables.folio_on)
        or (vGrabBagItemLinkId ~= nil and FRC.savedVariables.grabbag_on) then
      ZO_Tooltip_AddDivider(tooltipControl)

      tooltipControl:AddLine("Recipe available in Writ Vendor Folio: ",string.format("$(%s)|$(KB_%s)|%s", fontStyle, fontSizeH1, fontWeight))
      tooltipControl:AddLine((vFolioItemLink or vGrabBagItemLink),string.format("$(%s)|$(KB_%s)|%s", fontStyle, fontSizeH1, fontWeight))

      if LCK ~= nil then
        tooltipControl:AddLine("Folio Knowledge: "..vVendorCharacterString,string.format("$(%s)|$(KB_%s)|%s", fontStyle, fontSizeH1, fontWeight))
      else
        tooltipControl:AddLine("Recipe Count: "..vVendorRecipeCount,string.format("$(%s)|$(KB_%s)|%s", fontStyle, fontSizeH1, fontWeight))
      end
    elseif vLocation ~= nil then
      --Recipe with a misc location
      --TODO: This can be toggable setting
      ZO_Tooltip_AddDivider(tooltipControl)
      tooltipControl:AddLine("Recipe available from: "..vLocation,string.format("$(%s)|$(KB_%s)|%s", fontStyle, fontSizeH1, fontWeight))
    end
  elseif vGrabBagItemLinkId ~= nil then
    --Grab Bag
    if FRC.savedVariables.grabbag_on == false then
      return
    end

    local vVendorCharacterString, vVendorRecipeCount = FRC.GetWritVendorContainerStats(vGrabBagItemLinkId)

    ZO_Tooltip_AddDivider(tooltipControl)

    if LCK ~= nil and FRC.savedVariables.grabbag_lck_on then
      tooltipControl:AddLine("Grab Bag Knowledge: "..vVendorCharacterString,string.format("$(%s)|$(KB_%s)|%s", fontStyle, fontSizeH1, fontWeight))
    else
      tooltipControl:AddLine("Recipe Count: "..vVendorRecipeCount,string.format("$(%s)|$(KB_%s)|%s", fontStyle, fontSizeH1, fontWeight))
    end
  elseif vFolioItemLinkId ~= nil then
    --Folio
    if FRC.savedVariables.folio_on == false then
      return
    end

    local vVendorCharacterString, vVendorRecipeCount = FRC.GetWritVendorContainerStats(vFolioItemLinkId)

    ZO_Tooltip_AddDivider(tooltipControl)
    for i,recipeId in ipairs(FRC.Data.Folios[vItemLinkId]) do
      tooltipControl:AddLine("|H1:item:"..recipeId..":1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",string.format("$(%s)|$(KB_%s)|%s", fontStyle, fontSizeH1, fontWeight))
      if LCK ~= nil and FRC.savedVariables.folio_lck_on then
        local vCharacterStringLong, vCharacterStringShort, vCharTrackedCount, vCharKnownCount =FRC.GetRecipeKnowledge(recipeId)
        tooltipControl:AddLine("Known By: "..vCharacterStringLong,string.format("$(%s)|$(KB_%s)|%s", fontStyle, fontSizeH2, fontWeight))
      end
    end
    ZO_Tooltip_AddDivider(tooltipControl)
    if LCK ~= nil and FRC.savedVariables.folio_lck_on then
      tooltipControl:AddLine("Folio Knowledge: "..vVendorCharacterString,string.format("$(%s)|$(KB_%s)|%s", fontStyle, fontSizeH1, fontWeight))
    else
      tooltipControl:AddLine("Recipe Count: "..vVendorRecipeCount,string.format("$(%s)|$(KB_%s)|%s", fontStyle, fontSizeH1, fontWeight))
    end
  end
  --Add recipe data to all furnishings
  if (vRecipeItemLinkId ~= nil and vItemType == ITEMTYPE_FURNISHING and FRC.savedVariables.furnishing_showrecipe_on) then
    --only add recipe details to furnishings
    ZO_Tooltip_AddDivider(tooltipControl)
    tooltipControl:AddLine(vRecipeItemLink,string.format("$(%s)|$(KB_%s)|%s", fontStyle, fontSizeH1, fontWeight))
    if LCK ~= nil and FRC.savedVariables.furnishing_showrecipe_lck_on then
      local vCharacterStringLong, vCharacterStringShort, vCharTrackedCount, vCharKnownCount = FRC.GetRecipeKnowledge(vRecipeItemLinkId)
      tooltipControl:AddLine("Known By "..vCharacterStringShort..": "..vCharacterStringLong,string.format("$(%s)|$(KB_%s)|%s", fontStyle, fontSizeH1, fontWeight))
    end
  end
  --Add price data to to all recipes
  if (vItemType == ITEMTYPE_FURNISHING and FRC.savedVariables.furnishing_showrecipe_ttc_on and vRecipeItemLinkId ~= nil)
      or ((vSpecialType == SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING
      or vSpecialType == SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING
      or vSpecialType == SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING
      or vSpecialType == SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING
      or vSpecialType == SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING
      or vSpecialType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING
      or vSpecialType == SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING) and FRC.savedVariables.furnishingrecipe_ttc_on) then
    tooltipControl:AddLine("Average Price: "..zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(vRecipePrice or 0)),string.format("$(%s)|$(KB_%s)|%s", fontStyle, fontSizeH1, fontWeight))
    if vRecipeListing ~= nil then
      tooltipControl:AddLine("Listings: "..vRecipeListing,string.format("$(%s)|$(KB_%s)|%s", fontStyle, fontSizeH1, fontWeight))
    end
  end
end
local function TooltipHook(tooltipControl, method, linkFunc)
  local origMethod = tooltipControl[method]
  tooltipControl[method] = function(self, ...)
    origMethod(self, ...)

    adjustToolTip(tooltipControl, linkFunc(...))
  end
end

local function TooltipHook_Gamepad(tooltipControl, method, linkFunc)
  local origMethod = tooltipControl[method]

  tooltipControl[method] = function(self, ...)
    local result = origMethod(self, ...)

    adjustToolTip(tooltipControl, linkFunc(...))

    return result
  end
end
local ItemLinkPassthrough = function( itemLink )
  return itemLink
end

local function HookTradingHouseTooltips()
  TooltipHook(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
  TooltipHook(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
end

function FRC.HookTooltips()

  TooltipHook(PopupTooltip, "SetLink", ItemLinkPassthrough)
  TooltipHook(ItemTooltip, "SetLink", ItemLinkPassthrough)
  TooltipHook(ItemTooltip, "SetBagItem", GetItemLink)
  TooltipHook(ItemTooltip, "SetTradeItem", GetTradeItemLink)
  TooltipHook(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
  TooltipHook(ItemTooltip, "SetStoreItem", GetStoreItemLink)
  TooltipHook(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
  TooltipHook(ItemTooltip, "SetLootItem", GetLootItemLink)
  TooltipHook(ItemTooltip, "SetReward", GetItemRewardItemLink)
  TooltipHook(ItemTooltip, "SetQuestReward", GetQuestRewardItemLink)

  if AwesomeGuildStore then
    AwesomeGuildStore:RegisterCallback(AwesomeGuildStore.callback.AFTER_INITIAL_SETUP, HookTradingHouseTooltips)
  else
    HookTradingHouseTooltips()
  end

  TooltipHook_Gamepad(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP), "LayoutItem", ItemLinkPassthrough)
  TooltipHook_Gamepad(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP), "LayoutItem", ItemLinkPassthrough)
  TooltipHook_Gamepad(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_MOVABLE_TOOLTIP), "LayoutItem", ItemLinkPassthrough)
end