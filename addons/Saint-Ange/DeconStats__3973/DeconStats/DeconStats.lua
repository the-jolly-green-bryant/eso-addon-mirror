DeconStats = {}
local addon = { name = "DeconStats", author = "Saint-Ange", version = "1.0.2" }

--------------------------------------------------------------------------------

local default = {
   debugMode = false,
   decon   = { base = 100, intri = 100, craft = 100, style = 100, boost = 100, trait = 100 },
   yield   = { base = 107, intri = 300, craft = 500, style = 40,  boost = 75,  trait = 75  },
   chance  = { base = 1  , intri = 3  , craft = 5  , style = .4,  boost = .75, trait = .75 },
}
local LAM = LibAddonMenu2
local slot = { sellPrice = 0, base = false, intri = false, craft = false, style = false, boost = false, trait = false }

--------------------------------------------------------------------------------

local function DebugPrint(message)
   if DeconStats.sv.debugMode then d(message) end
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
      { type = "header", name = "Debug Mode" },
      {
         type = "description",
         text = "Print in system chat: slotted for decon item info including potential yield materials, deconstruction counts update, effective yields, yield and chance counts update.",
      },
      {
         type = "checkbox",
         name = "Debug Mode",
         default = false,
         getFunc = function() return DeconStats.sv.debugMode end,
         setFunc = function(value) DeconStats.sv.debugMode = value end,
      },
      { type = "description", text = "" },
      { type = "header", name = "Slash Command" },
      { type = "description", text = "/ds%  to print yield percentages" },
   }

   LAM:RegisterAddonPanel("DeconStats_Settings", panelData)
   LAM:RegisterOptionControls("DeconStats_Settings", optionsTable)
end

--------------------------------------------------------------------------------

local function GetDeconGearInfo()
   function ZO_SmithingExtractionSlot:AddItem(bagId, slotIndex)
      if not ZO_SmithingTopLevelDeconstructionPanelSlotContainer:IsHidden() then
         ZO_CraftingMultiSlotBase.AddItem(self, bagId, slotIndex)

         slot.sellPrice = select(3, GetItemInfo(bagId, slotIndex))
         if slot.sellPrice == 1 then return end

         local itemLink = GetItemLink(bagId, slotIndex)
         local style = select(7, GetItemInfo(bagId, slotIndex))
         local boost = GetItemQuality(bagId, slotIndex)
         local trait = GetItemTrait(bagId, slotIndex)
         local craft = IsItemLinkCrafted(itemLink)
         DebugPrint(string.format("%s", itemLink))

         slot.base  = trait ~= 9 and trait ~= 20 and not craft
         slot.intri = (trait == 20 or trait == 9)
         slot.craft = craft
         slot.style = style ~= 0 and style ~= 10 and style ~= 18 and style ~= 32 and style ~= 37 and style ~= 67
         slot.boost = boost > 1
         slot.trait = trait ~= 0 and trait ~= 9 and trait ~= 10 and trait ~= 20
      else
         ZO_CraftingMultiSlotBase.AddItem(self, bagId, slotIndex)
      end
   end
end

local function UpdateDeconCounts(_, _, _, _, _, _, stackCountChange)
   if slot.sellPrice == 1 then return end
   if not ZO_SmithingTopLevelDeconstructionPanelSlotContainer:IsHidden() then
      if stackCountChange == -1 then
         if slot.base  then
            DeconStats.sv.decon.base  = DeconStats.sv.decon.base + 1
            DebugPrint(string.format("decon.base  %d + 1 = %d", DeconStats.sv.decon.base - 1, DeconStats.sv.decon.base))
         end

         if slot.intri then
            DeconStats.sv.decon.intri = DeconStats.sv.decon.intri + 1
            DebugPrint(string.format("decon.intri  %d + 1 = %d", DeconStats.sv.decon.intri - 1, DeconStats.sv.decon.intri))
         end

         if slot.craft then
            DeconStats.sv.decon.craft = DeconStats.sv.decon.craft + 1
            DebugPrint(string.format("decon.craft  %d + 1 = %d", DeconStats.sv.decon.craft - 1, DeconStats.sv.decon.craft))
         end

         if slot.style then
            DeconStats.sv.decon.style = DeconStats.sv.decon.style + 1
            DebugPrint(string.format("decon.style  %d + 1 = %d", DeconStats.sv.decon.style - 1, DeconStats.sv.decon.style))
         end

         if slot.boost then
            DeconStats.sv.decon.boost = DeconStats.sv.decon.boost + 1
            DebugPrint(string.format("decon.boost  %d + 1 = %d", DeconStats.sv.decon.boost - 1, DeconStats.sv.decon.boost))
         end

         if slot.trait then
            DeconStats.sv.decon.trait = DeconStats.sv.decon.trait + 1
            DebugPrint(string.format("decon.trait:   %d + 1 = %d", DeconStats.sv.decon.trait - 1, DeconStats.sv.decon.trait))
         end
      end
   end
end

local function StoreAndUpdateYieldedQuantities(_, bagId, slotIndex, _, _, _, stackCountChange)
   if slot.sellPrice == 1 then return end
   if not ZO_SmithingTopLevelDeconstructionPanelSlotContainer:IsHidden() then
      local count = { base = 0, intri = 0, craft = 0, style = 0, boost = 0, trait = 0 }
      local itemType = GetItemType(bagId, slotIndex)

      if stackCountChange >= 0 then
         if itemType == ITEMTYPE_BLACKSMITHING_MATERIAL or itemType == ITEMTYPE_CLOTHIER_MATERIAL or itemType == ITEMTYPE_WOODWORKING_MATERIAL then
            if slot.base  then count.base  = count.base  + stackCountChange end
            if slot.intri then count.intri = count.intri + stackCountChange end
            if slot.craft then count.craft = count.craft + stackCountChange end
         end

         if itemType == ITEMTYPE_STYLE_MATERIAL then
            if slot.style then count.style = count.style + stackCountChange end
         end

         if itemType == ITEMTYPE_BLACKSMITHING_BOOSTER or itemType == ITEMTYPE_CLOTHIER_BOOSTER or itemType == ITEMTYPE_WOODWORKING_BOOSTER then
            if slot.boost then count.boost = count.boost + stackCountChange end
         end

         if itemType == ITEMTYPE_ARMOR_TRAIT or itemType == ITEMTYPE_WEAPON_TRAIT then
            if slot.trait then count.trait = count.trait + stackCountChange end
         end

         if count.base  > 0 and slot.base  then
            DeconStats.sv.yield.base  = DeconStats.sv.yield.base  + count.base
            DeconStats.sv.chance.base  = DeconStats.sv.yield.base  / DeconStats.sv.decon.base
            DebugPrint(string.format("base:   yield  %d + %d = %d   / decon  %d   = chance  %.2f %%",
            DeconStats.sv.yield.base - count.base, count.base, DeconStats.sv.yield.base, DeconStats.sv.decon.base, DeconStats.sv.chance.base * 100))
         end

         if count.intri > 0 and slot.intri then
            DeconStats.sv.yield.intri = DeconStats.sv.yield.intri + count.intri
            DeconStats.sv.chance.intri = DeconStats.sv.yield.intri / DeconStats.sv.decon.intri
            DebugPrint(string.format("intri:   yield  %d + %d = %d   / decon  %d   = chance  %.2f %%",
            DeconStats.sv.yield.intri - count.intri, count.intri, DeconStats.sv.yield.intri, DeconStats.sv.decon.intri, DeconStats.sv.chance.intri * 100))
         end

         if count.craft > 0 and slot.craft then
            DeconStats.sv.yield.craft = DeconStats.sv.yield.craft + count.craft
            DeconStats.sv.chance.craft = DeconStats.sv.yield.craft / DeconStats.sv.decon.craft
            DebugPrint(string.format("craft:   yield  %d + %d = %d   / decon  %d   = chance  %.2f %%",
            DeconStats.sv.yield.craft - count.craft, count.craft, DeconStats.sv.yield.craft, DeconStats.sv.decon.craft, DeconStats.sv.chance.craft * 100))
         end

         if count.style > 0 and slot.style then
            DeconStats.sv.yield.style = DeconStats.sv.yield.style + count.style
            DeconStats.sv.chance.style = DeconStats.sv.yield.style / DeconStats.sv.decon.style
            DebugPrint(string.format("style:   yield  %d + %d = %d   / decon  %d   = chance  %.2f %%",
            DeconStats.sv.yield.style - count.style, count.style, DeconStats.sv.yield.style, DeconStats.sv.decon.style, DeconStats.sv.chance.style * 100))
         end

         if count.boost > 0 and slot.boost then
            DeconStats.sv.yield.boost = DeconStats.sv.yield.boost + count.boost
            DeconStats.sv.chance.boost = DeconStats.sv.yield.boost / DeconStats.sv.decon.boost
            DebugPrint(string.format("boost:   yield  %d + %d = %d   / decon  %d   = chance  %.2f %%",
            DeconStats.sv.yield.boost - count.boost, count.boost, DeconStats.sv.yield.boost, DeconStats.sv.decon.boost, DeconStats.sv.chance.boost * 100))
         end

         if count.trait > 0 and slot.trait then
            DeconStats.sv.yield.trait = DeconStats.sv.yield.trait + count.trait
            DeconStats.sv.chance.trait = DeconStats.sv.yield.trait / DeconStats.sv.decon.trait
            DebugPrint(string.format("trait:   yield  %d + %d = %d   / decon  %d   = chance  %.2f %%",
            DeconStats.sv.yield.trait - count.trait, count.trait, DeconStats.sv.yield.trait, DeconStats.sv.decon.trait, DeconStats.sv.chance.trait * 100))
         end
      end
   end
end

--------------------------------------------------------------------------------

local function printPercentages()
   d(string.format("Yield Chance ~ %s%.2f %% ~ %s%.2f %% ~ %s%.2f %% ~ %s%.2f %% ~ %s%.2f %% ~ %s%.2f %%",
      "base ",    DeconStats.sv.chance.base  * 100,
      "intri ",   DeconStats.sv.chance.intri * 100,
      "crafted ", DeconStats.sv.chance.craft * 100,
      "style ",   DeconStats.sv.chance.style * 100,
      "boost ",   DeconStats.sv.chance.boost * 100,
      "trait ",   DeconStats.sv.chance.trait * 100
   ))
end

local function slashCommand()
   SLASH_COMMANDS["/ds%"] = printPercentages
end

slashCommand()

--------------------------------------------------------------------------------

local function OnEndCraftingStationInteract()
   EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
   EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_END_CRAFTING_STATION_INTERACT)
end

local function OnInventoryUpdate(_, bagId, slotIndex, _, _, _, stackCountChange)
   UpdateDeconCounts(_, _, _, _, _, _, stackCountChange)
   StoreAndUpdateYieldedQuantities(_, bagId, slotIndex, _, _, _, stackCountChange)
end

local function OnCraftingStationInteract(_, craftSkill)
	if	craftSkill == CRAFTING_TYPE_BLACKSMITHING or craftSkill == CRAFTING_TYPE_CLOTHIER or craftSkill == CRAFTING_TYPE_WOODWORKING then
      GetDeconGearInfo()
      EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventoryUpdate)
      EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_END_CRAFTING_STATION_INTERACT, OnEndCraftingStationInteract)
   end
end

local function Initialize()
   DeconStats.sv = ZO_SavedVars:NewAccountWide("DeconStats_SavedVars", 1, nil, default)
   OptionsMenu()
   EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_CRAFTING_STATION_INTERACT, OnCraftingStationInteract)
end

local function OnAddonLoaded(_, addonName)
   if addonName ~= addon.name then return end
   Initialize()
   EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)