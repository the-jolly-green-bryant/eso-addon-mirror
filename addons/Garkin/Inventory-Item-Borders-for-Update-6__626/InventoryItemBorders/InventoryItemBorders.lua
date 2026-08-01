local InventoryItemBorders = ZO_Object:Subclass()

InventoryItemBorders.defaults = {
   ["showBorders"] = true,
   ["showCondition"] = true,
   ["showColoredDoll"] = true,
   ["warningThreshold"] = 20,
   ["altBorders"] = true,
   ["altActiveWeaponDisplay"] = true
}

InventoryItemBorders.borderTex = "InventoryItemBorders/itemborder.dds"
InventoryItemBorders.hoverTex = "InventoryItemBorders/griditem_hover.dds"
InventoryItemBorders.borderTexAlt = "InventoryItemBorders/griditem_outline.dds"
InventoryItemBorders.slots = {
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

function InventoryItemBorders:Refresh()
   local doll = ZO_CharacterPaperDoll
   local redDoll = false

   if self.config.altActiveWeaponDisplay then
      ZO_CharacterEquipmentSlotsMainHandHighlight:SetAlpha(0)
      ZO_CharacterEquipmentSlotsOffHandHighlight:SetAlpha(0)
      ZO_CharacterEquipmentSlotsBackupMainHighlight:SetAlpha(0)
      ZO_CharacterEquipmentSlotsBackupOffHighlight:SetAlpha(0)

      local activeWeaponSet = ZO_CharacterWeaponSwap.activeWeaponPair
      local otherAlpha = 0.25
      if activeWeaponSet == 1 then
         ZO_CharacterEquipmentSlotsMainHand:SetAlpha(1)
         ZO_CharacterEquipmentSlotsOffHand:SetAlpha(1)
         ZO_CharacterEquipmentSlotsBackupMain:SetAlpha(otherAlpha)
         ZO_CharacterEquipmentSlotsBackupOff:SetAlpha(otherAlpha)
      else
         ZO_CharacterEquipmentSlotsMainHand:SetAlpha(otherAlpha)
         ZO_CharacterEquipmentSlotsOffHand:SetAlpha(otherAlpha)
         ZO_CharacterEquipmentSlotsBackupMain:SetAlpha(1)
         ZO_CharacterEquipmentSlotsBackupOff:SetAlpha(1)
      end
   else
      ZO_CharacterEquipmentSlotsMainHand:SetAlpha(1)
      ZO_CharacterEquipmentSlotsOffHand:SetAlpha(1)
      ZO_CharacterEquipmentSlotsBackupMain:SetAlpha(1)
      ZO_CharacterEquipmentSlotsBackupOff:SetAlpha(1)
      ZO_CharacterEquipmentSlotsMainHandHighlight:SetAlpha(1)
      ZO_CharacterEquipmentSlotsOffHandHighlight:SetAlpha(1)
      ZO_CharacterEquipmentSlotsBackupMainHighlight:SetAlpha(1)
      ZO_CharacterEquipmentSlotsBackupOffHighlight:SetAlpha(1)
   end

   for k, v in pairs(self.slots) do
      local _,_,_,_,_,_,_,quality = GetItemInfo(BAG_WORN, _G[k])
      if quality > 0 then
         local name = tostring(v .. "RarityBorder")
         local nameLabel = tostring(v .. "ConditionLabel")
         local parent = _G[v]

         local bg = parent:GetNamedChild("RarityBorder") or WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)
         bg:SetDimensions(46, 46)
         bg:SetAnchor(BOTTOM, parent, BOTTOM, 0, 1)
         if self.config.altBorders then
            bg:SetTexture(self.borderTexAlt)
         else
            bg:SetTexture(self.borderTex)
         end
         bg:SetDrawLayer(0)
         bg:SetHidden(not self.config.showBorders)

         local color = GetItemQualityColor(quality)
         bg:SetColor(color:UnpackRGBA())

         local condition = GetItemCondition(BAG_WORN, _G[k])

         local label = parent:GetNamedChild("ConditionLabel") or WINDOW_MANAGER:CreateControl(nameLabel, parent, CT_LABEL)
         label:SetText(tostring(condition .. "%"))
         label:SetAnchor(BOTTOMRIGHT, bg, BOTTOMRIGHT, -1, -5)
         label:SetDrawLayer(1)
         label:SetFont("ZoFontGameSmall")
         label:SetDimensions(50, 10)
         label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
         label:SetHidden(not self.config.showCondition)

         local warningLimit = self.config.warningThreshold

         -- color string red if under warning limit
         if condition <= warningLimit then
            label:SetColor(1, 0.25, 0.21, 1)
         else
            label:SetColor(1, 1, 1, 1)
         end

         -- hide when full durability
         if condition == 100 then
            label:SetHidden(true)
         end

         -- color doll red to indicate equipment damage
         if self.config.showColoredDoll == true then
            if condition <= warningLimit then
               redDoll = true
            end
         else
            doll:SetColor(1, 1, 1, 1)
         end
      else
         local bg = _G[v]:GetNamedChild("RarityBorder")
         if bg ~= nil then bg:SetHidden(true) end

         local label = _G[v]:GetNamedChild("ConditionLabel")
         if label ~= nil then label:SetHidden(true) end
      end
   end

   if redDoll then
      doll:SetColor(1, 0, 0, 0.5)
   else
      doll:SetColor(1, 1, 1, 1)
   end
end

function InventoryItemBorders:Init(eventCode, addonName)
   if addonName == "InventoryItemBorders" then
      EVENT_MANAGER:UnregisterForEvent("InventoryItemBorders", EVENT_ADD_ON_LOADED)
      
      self.config = ZO_SavedVars:New("IIB_SETTINGS", 1, nil, self.defaults, nil)

      self:Refresh()
      ZO_PlayerInventoryBackpack:RegisterForEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
         function(_, bagId, _, _, _, updateReason)
            if bagId == BAG_WORN and updateReason ~= INVENTORY_UPDATE_REASON_DYE_CHANGE then
               self:Refresh()
            end
         end)
      ZO_PlayerInventoryBackpack:RegisterForEvent(EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function() self:Refresh() end)

      self:CreateSettings()
   end
end

function InventoryItemBorders:CreateSettings()
   local panelData = {
      type = 'panel',
      name = "Biki's Item Borders",
      displayName = ZO_HIGHLIGHT_TEXT:Colorize("Biki's Inventory Item borders"),
      author = 'Biki & Garkin',
      version = '1.4',
      slashCommand = '/itemborders',
      registerForRefresh = true,
      registerForDefaults = true,
   }
   local optionsData = {
      {
         type = 'checkbox',
         name = 'Show item borders',
         tooltip = 'Should the item rarity borders be displayed? Of course :)',
         getFunc = function() return self.config.showBorders end,
         setFunc = function(value) self.config.showBorders = value; self:Refresh() end,
         default = self.defaults.showBorders,
      },
      {
         type = 'checkbox',
         name = '- Use alternative borders',
         tooltip = 'Uses the same borders as the IntenvoryGridView addon.',
         getFunc = function() return self.config.altBorders end,
         setFunc = function(value) self.config.altBorders = value; self:Refresh() end,
         default = self.defaults.altBorders,
      },
      {
         type = 'checkbox',
         name = 'Alternative active weapon display',
         tooltip = 'Uses an alternative method of showing what weapon set is active so the colored borders are more visible',
         getFunc = function() return self.config.altActiveWeaponDisplay end,
         setFunc = function(value) self.config.altActiveWeaponDisplay = value; self:Refresh() end,
         default = self.defaults.altActiveWeaponDisplay,
      },
      {
         type = 'checkbox',
         name = 'Show item condition',
         tooltip = 'Should the item condition be displayed in the lower right corner?',
         getFunc = function() return self.config.showCondition end,
         setFunc = function(value) self.config.showCondition = value; self:Refresh() end,
         default = self.defaults.showCondition,
      },
      {
         type = 'checkbox',
         name = 'Color the doll red',
         tooltip = 'Should the doll in the equipment screen be colored red as a visual warning?',
         getFunc = function() return self.config.showColoredDoll end,
         setFunc = function(value) self.config.showColoredDoll = value; self:Refresh() end,
         default = self.defaults.showColoredDoll
      },
      {
         type = 'slider',
         name = 'Warning threshold',
         tooltip = 'Set the warning threshold for when visual warnings should appear',
         min = 1,
         max = 100,
         getFunc = function() return self.config.warningThreshold end,
         setFunc = function(value) self.config.warningThreshold = value; self:Refresh() end,
         default = self.defaults.warningThreshold,
      },
   }

   local LAM2 = LibStub("LibAddonMenu-2.0")
   LAM2:RegisterAddonPanel("_bikisInventoryItemBorders", panelData)
   LAM2:RegisterOptionControls("_bikisInventoryItemBorders", optionsData)
end

EVENT_MANAGER:RegisterForEvent("InventoryItemBorders", EVENT_ADD_ON_LOADED, function(...) InventoryItemBorders:Init(...) end)
