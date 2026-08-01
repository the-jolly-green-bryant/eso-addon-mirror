DeconOrSell = {}
local addon = { name = "DeconOrSell", author = "Saint-Ange", version = "1.1.3" }

--------------------------------------------------------------------------------

local default = { useTraderFee = false, marginPercentage = 0, debugMode = false }
local chance = { base = 1, intri = 3, craft = 5, style = .4, boost = .75, trait = .75 }
local LAM = LibAddonMenu2

--------------------------------------------------------------------------------

local function DebugPrint(message)
   if DeconOrSell.sv.debugMode then d(message) end
end

local function OptionsMenu()
   local panelData = {
      type = "panel",
      name = addon.name,
      displayName = addon.name,
      author = addon.author,
      version = addon.version,
      registerForRefresh = true,
      registerForDefaults = true,
   }

   local optionsTable = {
      { type = "description", text = "" },
      { type = "header", name = "Guild Trader Fee" },
      { type = "description", text = "Apply an 8% guild trader fee to the total value of materials yielded from deconstruction." },
      {
         type = "checkbox",
         name = "Guild Trader Fee",
         default = false,
         getFunc = function() return DeconOrSell.sv.useTraderFee end,
         setFunc = function(value) DeconOrSell.sv.useTraderFee = value end,
      },
      { type = "description", text = "" },
      { type = "header", name = "Margin Percentage" },
      {
         type = "description",
         text = "Apply a positive or negative percentage margin to the total value of materials yielded from deconstruction.\
                  \nIf prices go down or you want to undercut the conccurence you can anticipate your stock value loss with a negative margin.\
                  \nIf prices go up or you want to increase the profit margin you can anticipate your stock value gain with a positive margin.",
      },
      {
         type = "editbox",
         name = "Margin Percentage",
         tooltip = "Example: -10 for -10% or 10 for 10%",
         isMultiline = false,
         default = "0",
         getFunc = function() return tostring(DeconOrSell.sv.marginPercentage * 100) end,
         setFunc = function(value)
               local percentage = tonumber(value)
               if percentage then
                  DeconOrSell.sv.marginPercentage = percentage / 100
               end
         end,
         isValidCallback = function(text)
               local number = tonumber(text)
               return number and math.abs(number) <= 999
         end,
      },
      { type = "description", text = "" },
      { type = "header", name = "Debug Mode" },
      {
         type = "description",
         text = "Print in system chat: gear item info, materials data (IDs, TTC Suggested prices, adjusted values based on yield chance, total net value), FCOIS mark applied on gear item.",
      },
      {
         type = "checkbox",
         name = "Debug Mode",
         default = false,
         getFunc = function() return DeconOrSell.sv.debugMode end,
         setFunc = function(value) DeconOrSell.sv.debugMode = value end,
      },
   }

   LAM:RegisterAddonPanel("DeconOrSell_Settings", panelData)
   LAM:RegisterOptionControls("DeconOrSell_Settings", optionsTable)
end

--------------------------------------------------------------------------------

local function GenerateItemLink(id)
   return string.format("|H0:item:%d:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", id)
end

--------------------------------------------------------------------------------

function GetGearInfo(bagId, slotIndex)
   local itemFilterType = GetItemFilterTypeInfo(bagId, slotIndex)
   if itemFilterType == ITEMFILTERTYPE_COMPANION then return end
   if itemFilterType == ITEMFILTERTYPE_ARMOR or itemFilterType == ITEMFILTERTYPE_WEAPONS then
      if IsItemJunk(bagId, slotIndex) and not FCOIS.IsMarked(bagId, slotIndex, -1) then
         local itemLink = GetItemLink(bagId, slotIndex)
         local craftingType = GetItemLinkCraftingSkillType(itemLink)
         local armorType = GetItemArmorType(bagId, slotIndex)
         local style = select(7, GetItemInfo(bagId, slotIndex))
         local craft = IsItemLinkCrafted(itemLink)
         local quality = GetItemQuality(bagId, slotIndex)
         local level = GetItemRequiredLevel(bagId, slotIndex)
         local cp = GetItemRequiredChampionPoints(bagId, slotIndex)
         local trait = GetItemTrait(bagId, slotIndex)
         local sellPrice = select(3, GetItemInfo(bagId, slotIndex))
         DebugPrint(string.format("%s", itemLink))

         return GetMaterialId(craftingType, armorType, style, level, cp, quality, itemFilterType, trait, craft, sellPrice, bagId, slotIndex)
      end
   end
end

function GetMaterialId(craftingType, armorType, style, level, cp, quality, itemFilterType, trait, craft, sellPrice, bagId, slotIndex)
   local data = DeconOrSell_data
   local id_table = data.base_id[(cp > 0) and 'cp' or 'level']
   local baseId = 0
   for _, range in ipairs(id_table) do
      if ((cp > 0 and cp >= range.min and cp <= range.max) or (cp <= 0 and level >= range.min and level <= range.max)) then
         if craftingType == CRAFTING_TYPE_BLACKSMITHING then
            baseId = range.ingot
         elseif craftingType == CRAFTING_TYPE_CLOTHIER then
            baseId = (armorType == ARMORTYPE_LIGHT) and range.cloth or range.leather
         elseif craftingType == CRAFTING_TYPE_WOODWORKING then
            baseId = range.wood
         end
         break
      end
   end

   local styleId = data.style_id[style] or 0
   local boostId = data.boost_id[craftingType] and data.boost_id[craftingType][quality] or 0
   local traitId = data.trait_id[itemFilterType] and data.trait_id[itemFilterType][trait] or 0

   return GetMaterialTraderPrice(baseId, styleId, boostId, traitId, trait, craft, sellPrice, bagId, slotIndex)
end

function GetMaterialTraderPrice(baseId, styleId, boostId, traitId, trait, craft, sellPrice, bagId, slotIndex)
   local baseItemLink = GenerateItemLink(baseId)
   local styleItemLink = GenerateItemLink(styleId)
   local boostItemLink = GenerateItemLink(boostId)
   local traitItemLink = GenerateItemLink(traitId)

   local baseTraderPrice  = TamrielTradeCentrePrice:GetPriceInfo(baseItemLink) and TamrielTradeCentrePrice:GetPriceInfo(baseItemLink).SuggestedPrice
   local styleTraderPrice = TamrielTradeCentrePrice:GetPriceInfo(styleItemLink) and TamrielTradeCentrePrice:GetPriceInfo(styleItemLink).SuggestedPrice or 0
   local boostTraderPrice = TamrielTradeCentrePrice:GetPriceInfo(boostItemLink) and TamrielTradeCentrePrice:GetPriceInfo(boostItemLink).SuggestedPrice or 0
   local traitTraderPrice = TamrielTradeCentrePrice:GetPriceInfo(traitItemLink) and TamrielTradeCentrePrice:GetPriceInfo(traitItemLink).SuggestedPrice or 0

   return CalculateMaterialProdValue(trait, craft, baseTraderPrice, styleTraderPrice, boostTraderPrice, traitTraderPrice, baseItemLink, styleItemLink, boostItemLink, traitItemLink, sellPrice, bagId, slotIndex)
end

function CalculateMaterialProdValue(trait, craft, baseTraderPrice, styleTraderPrice, boostTraderPrice, traitTraderPrice, baseItemLink, styleItemLink, boostItemLink, traitItemLink, sellPrice, bagId, slotIndex)
   local baseChanceDecimal  = ((trait == 20 or trait == 9) and ((DeconStats and DeconStats.sv.chance.intri) or chance.intri))
      or (craft and ((DeconStats and DeconStats.sv.chance.craft) or chance.craft))
      or ((DeconStats and DeconStats.sv.chance.base) or chance.base)
   local styleChanceDecimal = (DeconStats and DeconStats.sv.chance.style) or chance.style
   local boostChanceDecimal = (DeconStats and DeconStats.sv.chance.boost) or chance.boost
   local traitChanceDecimal = (DeconStats and DeconStats.sv.chance.trait) or chance.trait

   local traderFeeDecimal = DeconOrSell.sv.useTraderFee and 0.92 or 1
   local marginDecimal    = 1 + DeconOrSell.sv.marginPercentage

   local baseNet  = baseTraderPrice  * baseChanceDecimal  * traderFeeDecimal * marginDecimal
   local styleNet = styleTraderPrice * styleChanceDecimal * traderFeeDecimal * marginDecimal
   local boostNet = boostTraderPrice * boostChanceDecimal * traderFeeDecimal * marginDecimal
   local traitNet = traitTraderPrice * traitChanceDecimal * traderFeeDecimal * marginDecimal

   DebugPrint(string.format("%s     ttc  %.2f  *  chance  %.2f  *  fee  %.2f  *  margin  %.2f  =  net  %.2f",
      baseItemLink, baseTraderPrice, baseChanceDecimal, traderFeeDecimal, marginDecimal, baseNet))

   if styleTraderPrice > 0 then
      DebugPrint(string.format("%s     ttc  %.2f  *  chance  %.2f  *  fee  %.2f  *  margin  %.2f  =  net  %.2f",
         styleItemLink, styleTraderPrice, styleChanceDecimal, traderFeeDecimal, marginDecimal, styleNet))
   end

   if boostTraderPrice > 0 then
      DebugPrint(string.format("%s     ttc  %.2f  *  chance  %.2f  *  fee  %.2f  *  margin  %.2f  =  net  %.2f",
         boostItemLink, boostTraderPrice, boostChanceDecimal, traderFeeDecimal, marginDecimal, boostNet))
   end

   if traitTraderPrice > 0 then
      DebugPrint(string.format("%s     ttc  %.2f  *  chance  %.2f  *  fee  %.2f  *  margin  %.2f  =  net  %.2f",
         traitItemLink, traitTraderPrice, traitChanceDecimal, traderFeeDecimal, marginDecimal, traitNet))
   end

   local totalNet = baseNet + styleNet + boostNet + traitNet

   return MarkGearItem(sellPrice, totalNet, bagId, slotIndex)
end

function MarkGearItem(sellPrice, totalNet, bagId, slotIndex)
   if sellPrice == 1 then
      FCOIS.MarkItem(bagId, slotIndex, FCOIS_CON_ICON_SELL)
      return
   elseif sellPrice > totalNet then
      FCOIS.MarkItem(bagId, slotIndex, FCOIS_CON_ICON_SELL)
   else
      FCOIS.MarkItem(bagId, slotIndex, FCOIS_CON_ICON_DECONSTRUCTION)
   end

   local markType = (sellPrice > totalNet) and "sell" or "deconstruct"
   DebugPrint(string.format("sell price  %d  vs  materials total net  %.2f  =  %s\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", sellPrice, totalNet, markType))
end

--------------------------------------------------------------------------------

local function OnInventoryUpdate(_, bagId, slotIndex)
   GetGearInfo(bagId, slotIndex)
end

local function Initialize()
   DeconOrSell.sv = ZO_SavedVars:NewAccountWide("DeconOrSell_SavedVars", 1, nil, default)
   OptionsMenu()
   EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventoryUpdate)
end

local function OnAddonLoaded(_, addonName)
   if addonName ~= addon.name then return end
   Initialize()
   EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)