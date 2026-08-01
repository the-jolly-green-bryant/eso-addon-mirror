FurnishingRecipeCollector = FurnishingRecipeCollector or {}
local FRC = FurnishingRecipeCollector

--------------------------------------------------------------------
-- Locals
--------------------------------------------------------------------
local tos = tostring
local LCK = LibCharacterKnowledge

local function Linkify(itemId)
  return "|H1:item:"..itemId..":1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
end
local function GetItemlinkDetails(itemLinkOrItemId)
  local vItemLink, vItemId

  if type(itemLinkOrItemId) == "string" then
    vItemLink = itemLinkOrItemId
    vItemId = GetItemLinkItemId(vItemLink)
  else
    vItemId = itemLinkOrItemId
    vItemLink = Linkify(vItemId)
  end

  return vItemLink, vItemId
end

--------------------------------------------------------------------
-- Recipe Functions
--------------------------------------------------------------------
function FRC.GetRecipeDetail(itemLinkOrItemID)

  local vItemLink, vItemId = GetItemlinkDetails(itemLinkOrItemID)
  local vItemType, vSpecialType = GetItemLinkItemType(vItemLink)
  local vItemName = GetItemLinkName(vItemLink)
  local vItemFunctionalQuality = GetItemLinkFunctionalQuality(vItemLink)

  local vFolioItemLinkId, vFolioItemLink, vFolioItemName = nil, nil, nil
  local vRecipeItemLinkId, vRecipeItemLink, vRecipeItemName = nil, nil, nil
  local vGrabBagItemLinkId, vGrabBagItemLink, vGrabBagItemName = nil, nil, nil
  local vResultLinkId, vResultLink, vResultName = nil, nil, nil
  local vLocation, vRecipePrice, vRecipeListing = nil, nil, nil

  if FRC.Data.Folios[vItemId] ~= nil then
    -- This is a folio
    vFolioItemLink, vFolioItemLinkId = GetItemlinkDetails(vItemId)
    vFolioItemName = vItemName
  elseif FRC.Data.FurnisherDocuments[vItemId] ~= nil then
    -- This is a grab bag
    vGrabBagItemLink, vGrabBagItemLinkId = GetItemlinkDetails(vItemId)
    vGrabBagItemName = vItemName
  elseif FRC.Data.Misc[vItemId] ~= nil then
    -- This is a recipe with special location
    vRecipeItemLink, vRecipeItemLinkId = GetItemlinkDetails(vItemId)
    vRecipeItemName = GetItemLinkName(vRecipeItemLink)
    vLocation = FRC.Data.Misc[vRecipeItemLinkId].location
    vResultLink, vResultLinkId = GetItemlinkDetails(GetItemLinkRecipeResultItemLink(Linkify(vRecipeItemLinkId)))
    vResultName = GetItemLinkName(vResultLink)
  elseif vSpecialType == SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING
    or vSpecialType == SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING
    or vSpecialType == SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING
    or vSpecialType == SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING
    or vSpecialType == SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING
    or vSpecialType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING
    or vSpecialType == SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING then
      --This is a furnishing recipe
      vRecipeItemLink, vRecipeItemLinkId = GetItemlinkDetails(vItemId)
      vRecipeItemName = GetItemLinkName(vRecipeItemLink)
      vResultLink, vResultLinkId = GetItemlinkDetails(GetItemLinkRecipeResultItemLink(Linkify(vRecipeItemLinkId)))
      vResultName = GetItemLinkName(vResultLink)

      --Loop through each folio looking for recipe
      for i_key,i_value in pairs(FRC.Data.Folios) do
        for j_key,j_value in pairs(FRC.Data.Folios[i_key]) do
          -- if FRC.logger ~= nil then FRC.logger:Verbose("==============================") end
          -- if FRC.logger ~= nil then FRC.logger:Verbose("Folio: "..tos(i_key).." "..Linkify(i_key)) end
          -- if FRC.logger ~= nil then FRC.logger:Verbose("Recipe ID: "..tos(FRC.Data.Folios[i_key][j_key]).." "..Linkify(FRC.Data.Folios[i_key][j_key])) end
          -- if FRC.logger ~= nil then FRC.logger:Verbose("Result Link ID: "..vResultLinkId..resultLink ) end
          -- if FRC.logger ~= nil then FRC.logger:Verbose("Search ID: "..itemLinkId.." "..itemLink) end

          if FRC.Data.Folios[i_key][j_key] == vItemId then
            --if FRC.logger ~= nil then FRC.logger:Verbose(Linkify(i).." "..Linkify(FRC.Data.Folios[i_key][j_key]).." "..Linkify(vItemId)) end
            vFolioItemLink, vFolioItemLinkId = GetItemlinkDetails(i_key)
            vFolioItemName = GetItemLinkName(vFolioItemLink)
            break
          end
        end
        if vFolioItemLinkId ~= nil then
          break
        end
      end
      if vFolioItemLinkId == nil then
        --Loop through each grabn bag looking for recipe, if not found earlier
        for i_key,i_value in pairs(FRC.Data.FurnisherDocuments) do
          for j_key,j_value in pairs(FRC.Data.FurnisherDocuments[i_key]) do
            -- if FRC.logger ~= nil then FRC.logger:Verbose("==============================") end
            -- if FRC.logger ~= nil then FRC.logger:Verbose("FurnisherDocuments: "..tos(i_key).." "..Linkify(i_key)) end
            -- if FRC.logger ~= nil then FRC.logger:Verbose("Recipe ID: "..tos(FRC.Data.FurnisherDocuments[i_key][j_key]).." "..Linkify(FRC.Data.FurnisherDocuments[i_key][j_key])) end
            -- if FRC.logger ~= nil then FRC.logger:Verbose("Result Link ID: "..vResultLinkId..resultLink ) end
            -- if FRC.logger ~= nil then FRC.logger:Verbose("Search ID: "..itemLinkId.." "..itemLink) end

            if FRC.Data.FurnisherDocuments[i_key][j_key] == vItemId then
              --if FRC.logger ~= nil then FRC.logger:Verbose(Linkify(i).." "..Linkify(FRC.Data.FurnisherDocuments[i_key][j_key]).." "..Linkify(vItemId)) end
              vGrabBagItemLink, vGrabBagItemLinkId = GetItemlinkDetails(i_key)
              vGrabBagItemName = GetItemLinkName(vGrabBagItemLink)
              break
            end
          end
          if vGrabBagItemLinkId ~= nil then
            break
          end
        end
      end
  elseif vItemType == ITEMTYPE_FURNISHING then
    --This is a furnishing item
    -- local craftingStationType, recipeListIndex,recipeIndex = GetRecipeInfoFromItemId(vItemId)
    -- local recipeListName, numRecipes, upIcon, downIcon, overIcon, _, recipeListCreateSound = GetRecipeListInfo(recipeListIndex)
    -- local known_, name_, numIngredients_, provisionerLevelReq_, qualityReq_, specialIngredientType_, requiredCraftingStationType_, resultItemId_ GetRecipeInfo(recipeListIndex,recipeIndex)
    -- local link = GetRecipeIngredientItemLink(recipeListIndex, recipeIndex, i, LINK_STYLE_BRACKETS)
    vResultLink, vResultLinkId = GetItemlinkDetails(vItemId)
    vResultName = GetItemLinkName(vResultLink)

    --Loop through each folio looking for recipe
    for i_key,i_value in pairs(FRC.Data.Folios) do
      for j_key,j_value in pairs(FRC.Data.Folios[i_key]) do
        local vSearchResultLink = GetItemLinkRecipeResultItemLink(Linkify(FRC.Data.Folios[i_key][j_key]))
        local vSearchResultLinkId = GetItemLinkItemId(vSearchResultLink)

        if vResultLinkId == vSearchResultLinkId then
          --if FRC.logger ~= nil then FRC.logger:Verbose(Linkify(i).." "..Linkify(FRC.Data.Folios[i_key][j_key]).." "..Linkify(vItemId)) end
          vFolioItemLink, vFolioItemLinkId = GetItemlinkDetails(i_key)
          vFolioItemName = GetItemLinkName(vFolioItemLink)
          vRecipeItemLink, vRecipeItemLinkId = GetItemlinkDetails(FRC.Data.Folios[i_key][j_key])
          vRecipeItemName = GetItemLinkName(vRecipeItemLink)
          break
        end
      end
      if vFolioItemLinkId ~= nil then
        break
      end
    end
    if vFolioItemLinkId == nil then
      --Loop through each grabn bag looking for recipe, if not found earlier
      for i_key,i_value in pairs(FRC.Data.FurnisherDocuments) do
        for j_key,j_value in pairs(FRC.Data.FurnisherDocuments[i_key]) do
          local vSearchResultLink, vSearchResultLinkId = GetItemlinkDetails(GetItemLinkRecipeResultItemLink(Linkify(FRC.Data.FurnisherDocuments[i_key][j_key])))

          if vResultLinkId == vSearchResultLinkId then
            --if FRC.logger ~= nil then FRC.logger:Verbose(Linkify(i).." "..Linkify(FRC.Data.FurnisherDocuments[i_key][j_key]).." "..Linkify(vItemId)) end
            vGrabBagItemLink, vGrabBagItemLinkId = GetItemlinkDetails(i_key)
            vGrabBagItemName = GetItemLinkName(vGrabBagItemLink)
            vRecipeItemLink, vRecipeItemLinkId = GetItemlinkDetails(FRC.Data.FurnisherDocuments[i_key][j_key])
            vRecipeItemName = GetItemLinkName(vRecipeItemLink)
            break
          end
        end
        if vGrabBagItemLinkId ~= nil then
          break
        end
      end
    end
    if vFolioItemLinkId == nil and vGrabBagItemLinkId == nil then
      --Loop through each misc looking for recipe, if not found earlier
      for i_key,i_value in pairs(FRC.Data.Misc) do
        local vSearchResultLink, vSearchResultLinkId = GetItemlinkDetails(GetItemLinkRecipeResultItemLink(Linkify(i_key)))

        if vResultLinkId == vSearchResultLinkId then
          --if FRC.logger ~= nil then FRC.logger:Verbose(Linkify(i).." "..Linkify(FRC.Data.Misc[i_key]).." "..Linkify(vItemId)) end
          vRecipeItemLink, vRecipeItemLinkId = GetItemlinkDetails(i_key)
          vRecipeItemName = GetItemLinkName(vRecipeItemLink)
          vLocation = FRC.Data.Misc[vRecipeItemLinkId].location
          break
        end
      end
    end
    if vFolioItemLinkId == nil and vGrabBagItemLinkId == nil and vLocation == nil then
      if LCK ~= nil then
        local souceItemId =LCK.GetSourceItemIdFromResultItem(vResultLink)
        if souceItemId ~= 0 then
          vRecipeItemLink, vRecipeItemLinkId = GetItemlinkDetails(LCK.GetSourceItemIdFromResultItem(vResultLink))
          vRecipeItemName = GetItemLinkName(vRecipeItemLink)
        end
      end
    end
  end

  if TamrielTradeCentrePrice~= nil then
    local priceTable = TamrielTradeCentrePrice:GetPriceInfo(vRecipeItemLink)
    if priceTable ~= nil then
      if priceTable[FRC.savedVariables.price] ~= nil then
        vRecipePrice = priceTable[FRC.savedVariables.price]
      end
      if priceTable["EntryCount"] ~= nil then
        vRecipeListing = priceTable["EntryCount"]
      end
    end
  end

  return vItemId, vItemName, vItemFunctionalQuality, vItemType, vSpecialType, vFolioItemLinkId, vFolioItemLink, vFolioItemName, vRecipeItemLinkId, vRecipeItemLink, vRecipeItemName, vGrabBagItemLinkId, vGrabBagItemLink, vGrabBagItemName, vLocation, vResultLinkId, vResultLink, vResultName, vRecipePrice, vRecipeListing
end

function FRC.GetWritVendorContainerStats(vendorContainerLinkId)
  local vVendorCharacterString = ""
  local vVendorRecipeCount = nil
  local container = FRC.Data.Folios[vendorContainerLinkId] or FRC.Data.FurnisherDocuments[vendorContainerLinkId]

  if container == nil then
    return
  end
  vVendorRecipeCount = table.getn(container)

  if LCK ~= nil then
    if container ~= nil then
      local tChars = {}
      local charactercolor = ""

      for j,recipeId in ipairs(container) do
        local knowl = LCK.GetItemKnowledgeList(recipeId, nil,nil)

        for i, knowledge in ipairs(knowl) do
          if knowledge["knowledge"] == LCK.KNOWLEDGE_KNOWN then
            if tChars[knowledge["id"]] == nil then
              tChars[knowledge["id"]] = 1
            else
              tChars[knowledge["id"]] = tChars[knowledge["id"]] + 1
            end
          elseif knowledge["knowledge"] == LCK.KNOWLEDGE_UNKNOWN then
            if tChars[knowledge["id"]] == nil then
              tChars[knowledge["id"]] = 0
            end
          end
        end
      end

      local chrList=LCK.GetCharacterList( nil )

      for i, chr in ipairs(chrList) do
        if tChars[chr["id"]] ~= nil then

          if tChars[chr["id"]] == 0 then
            charactercolor = FRC.savedVariables.colorAllUnknown
          elseif tChars[chr["id"]] == table.getn(container) then
            charactercolor = FRC.savedVariables.colorAllKnown
          else
            charactercolor = FRC.savedVariables.colorAllPartial
          end
          if vVendorCharacterString ~= "" then
            vVendorCharacterString = vVendorCharacterString..", "
          end
          vVendorCharacterString = vVendorCharacterString..string.format("|c%06X%s|r", charactercolor, chr["name"].." ("..tChars[chr["id"]].."/"..table.getn(container)..")")
        end
      end
    end
  end
  return vVendorCharacterString, vVendorRecipeCount
end

function FRC.GetRecipeKnowledge(vRecipeItemLinkOrItemId)
  local vCharacterStringLong = ""
  local vCharacterStringShort = ""
  local vCharTrackedCount = 0
  local vCharKnownCount = 0

  local _, vRecipeItemId = GetItemlinkDetails(vRecipeItemLinkOrItemId)

  if LCK ~= nil then
    local tChars= LCK.GetItemKnowledgeList(vRecipeItemId,nil,nil)
    local charColor = nil

    for i, chr in ipairs(tChars) do
      if chr["knowledge"] == LCK.KNOWLEDGE_KNOWN then
        vCharTrackedCount = vCharTrackedCount + 1
        vCharKnownCount = vCharKnownCount + 1
        charColor = FRC.savedVariables.colorCharKnown
      elseif chr["knowledge"] == LCK.KNOWLEDGE_UNKNOWN then
        vCharTrackedCount = vCharTrackedCount + 1
        charColor = FRC.savedVariables.colorCharUnknown
      end

      if chr["knowledge"] == LCK.KNOWLEDGE_KNOWN or chr["knowledge"] == LCK.KNOWLEDGE_UNKNOWN then
        if vCharacterStringLong ~= "" then
          vCharacterStringLong = vCharacterStringLong..", "
        end
        vCharacterStringLong = vCharacterStringLong..string.format("|c%06X%s|r", charColor, chr["name"])
      end
    end
    if vCharKnownCount == 0 then
      vCharacterStringShort = string.format("|c%06X%s|r", FRC.savedVariables.colorAllUnknown, tos(vCharKnownCount).."/"..tos(vCharTrackedCount))
    elseif vCharKnownCount == vCharTrackedCount then
      vCharacterStringShort = string.format("|c%06X%s|r", FRC.savedVariables.colorAllKnown, tos(vCharKnownCount).."/"..tos(vCharTrackedCount))
    else
      vCharacterStringShort = string.format("|c%06X%s|r", FRC.savedVariables.colorAllPartial, tos(vCharKnownCount).."/"..tos(vCharTrackedCount))
    end
  end
  return vCharacterStringLong, vCharacterStringShort, vCharTrackedCount, vCharKnownCount
end