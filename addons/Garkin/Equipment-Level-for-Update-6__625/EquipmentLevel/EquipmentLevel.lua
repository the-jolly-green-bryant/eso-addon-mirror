local EquipmentLevel = ZO_Object:Subclass()

EquipmentLevel.defaults = {
   ["showString"] = true,
   ["showColors"] = true,
   ["colorValues"] = {
      ["bad"] = 5,
      ["ok"] = 3,
      ["good"] = 2
  }
}
EquipmentLevel.config = nil
EquipmentLevel.parent = ZO_CharacterApparelSection
EquipmentLevel.colors = {
   ["good"] = "|c2ECC40",
   ["ok"] = "|cFFDC00",
   ["bad"] = "|cFF4136"
}
EquipmentLevel.slots = {
   ["EQUIP_SLOT_HEAD"] = "ZO_CharacterEquipmentSlotsHead",
   ["EQUIP_SLOT_CHEST"] = "ZO_CharacterEquipmentSlotsChest",
   ["EQUIP_SLOT_SHOULDERS"] = "ZO_CharacterEquipmentSlotsShoulder",
   ["EQUIP_SLOT_FEET"] = "ZO_CharacterEquipmentSlotsFoot",
   ["EQUIP_SLOT_HAND"] = "ZO_CharacterEquipmentSlotsGlove",
   ["EQUIP_SLOT_LEGS"] = "ZO_CharacterEquipmentSlotsLeg",
   ["EQUIP_SLOT_WAIST"] = "ZO_CharacterEquipmentSlotsBelt",
   ["EQUIP_SLOT_RING1"] = "ZO_CharacterEquipmentSlotsRing1",
   ["EQUIP_SLOT_RING2"] = "ZO_CharacterEquipmentSlotsRing2",
   ["EQUIP_SLOT_NECK"] = "ZO_CharacterEquipmentSlotsNeck",
   ["EQUIP_SLOT_COSTUME"] = "ZO_CharacterEquipmentSlotsCostume",
   ["EQUIP_SLOT_MAIN_HAND"] = "ZO_CharacterEquipmentSlotsMainHand",
   ["EQUIP_SLOT_OFF_HAND"] = "ZO_CharacterEquipmentSlotsOffHand",
   ["EQUIP_SLOT_BACKUP_MAIN"] = "ZO_CharacterEquipmentSlotsBackupMain",
   ["EQUIP_SLOT_BACKUP_OFF"] = "ZO_CharacterEquipmentSlotsBackupOff"
}

function EquipmentLevel:Update()
   local iLevel = 0
   local numItems = 0
   for key, value in pairs(self.slots) do
      local lvl = GetItemLevel(BAG_WORN, _G[key])
      if lvl then
         iLevel = iLevel + lvl
      end
      if key ~= "EQUIP_SLOT_COSTUME" then
         numItems = numItems + 1
      end
   end

   -- handle twohanders
   if GetItemLevel(BAG_WORN, EQUIP_SLOT_OFF_HAND) == 0 then numItems = numItems - 1 end
   if GetItemLevel(BAG_WORN, EQUIP_SLOT_BACKUP_OFF) == 0 then numItems = numItems - 1 end

   iLevel = zo_round(iLevel / numItems)

   local lbl = self.parent:GetNamedChild("ItemLevelLabel") or WINDOW_MANAGER:CreateControl(self.parent:GetName() .. "ItemLevelLabel", self.parent, CT_LABEL)
   lbl:SetAnchor(TOPRIGHT, self.parent, BOTTOMRIGHT, -80, 5)
   lbl:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
   lbl:SetFont("ZoFontGameBold")
   lbl:SetColor(0.772, 0.760, 0.619, 1)

   local color = "|cFFFFFF"
   if self.config.showColors then
      local playerLevel = GetUnitEffectiveLevel("player")
      local diff = playerLevel - iLevel

      if diff <= self.config.colorValues["good"] then
         color = self.colors["good"]
      elseif diff > self.config.colorValues["good"] and diff < self.config.colorValues["bad"] then
         color = self.colors["ok"]
      elseif diff >= self.config.colorValues["bad"] then
         color = self.colors["bad"]
      end
   end

   if self.config.showString then
      lbl:SetText("ELVL " .. color .. iLevel .. "|r")
   else
      lbl:SetText(color .. iLevel .. "|r")
   end
end

function EquipmentLevel:Init(event, name)
   if name ~= "EquipmentLevel" then return end
   EVENT_MANAGER:UnregisterForEvent("EquipmentLevel", EVENT_ADD_ON_LOADED)

   self.config = ZO_SavedVars:New("EquipmentLevelSavedVars", 1.0, nil, self.defaults)

   EVENT_MANAGER:RegisterForEvent("AdjustItemLevelEvent", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
      function(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
         if bagId == BAG_WORN and updateReason == INVENTORY_UPDATE_REASON_DEFAULT then 
            self:Update()
         end
      end)

   ZO_Character:SetHandler("OnShow", function()
      self:Update()
   end)

   self:CreateSettings()
end

function EquipmentLevel:CreateSettings()
   local panelData = {
      type = 'panel',
      name = "Biki's Equipment Level",
      displayName = ZO_HIGHLIGHT_TEXT:Colorize("Biki's Equipment Level"),
      author = 'Biki & Garkin',
      version = '1.3',
      slashCommand = '/equipmentlevel',
      registerForRefresh = true,
      registerForDefaults = true,
   }
   local optionsData = {
      {
         type = 'checkbox',
         name = 'Show label name',
         tooltip = 'Shows the "ELVL" string before the actual equipment level',
         getFunc = function() return self.config.showString end,
         setFunc = function(value) self.config.showString = value end,
         default = self.defaults.showString,
      },
      {
         type = 'checkbox',
         name = 'Show colors',
         tooltip = 'Colors the value depending on the difference between your character and equipment levels',
         getFunc = function() return self.config.showColors end,
         setFunc = function(value) self.config.showColors = value end,
         default = self.defaults.showColors 
      },
      {
         type = 'slider',
         name = '- Max. difference for "good" (green)',
         tooltip = 'Select the maximum difference between your character and equipment level for it to be "good"',
         min = 0,
         max = 50,
         getFunc = function() return self.config.colorValues["good"] end,
         setFunc = function(value) self.config.colorValues["good"] = value end,
         default = self.defaults.colorValues["good"],
      },
      {
         type = 'slider',
         name = '- Max. difference for "ok" (yellow)',
         tooltip = 'Select the maximum difference between your character and equipment level for it to be "ok"',
         min = 0,
         max = 50,
         getFunc = function() return self.config.colorValues["ok"] end,
         setFunc = function(value) self.config.colorValues["ok"] = value end,
         default = self.defaults.colorValues["ok"],
      },
      {
         type = 'slider',
         name = '- Max. difference for "bad" (red)',
         tooltip = 'Select the maximum difference between your character and equipment level for it to be "bad"',
         min = 0,
         max = 50,
         getFunc = function() return self.config.colorValues["bad"] end,
         setFunc = function(value) self.config.colorValues["bad"] = value end,
         default = self.defaults.colorValues["bad"],
      },
   }



   local LAM2 = LibStub("LibAddonMenu-2.0")
   LAM2:RegisterAddonPanel("_bikisEquipmentLevel", panelData)
   LAM2:RegisterOptionControls("_bikisEquipmentLevel", optionsData)
end

EVENT_MANAGER:RegisterForEvent("EquipmentLevel", EVENT_ADD_ON_LOADED, function(...) EquipmentLevel:Init(...) end)
