--[[
  * Wykkyd [ Equipment Level ]
  * Sponsored & Supported by: The Prydonian Elders
  * Author: Ravalox Darkshire (support@ecgroup.us)
  * Embedded: LibStub & libAddonMenu by Seerah.
  * Special credit to Biki, the original author of EquipmentLevel from which this was derived
  * Special Thanks To: Zenimax Online Studios & Bethesda for The Elder Scrolls Online
]]--

local _addon = {}
_addon._v = {}
_addon._v.major		= 2
_addon._v.monthly 	= 3
_addon._v.daily 	= 3
_addon._v.minor 	= 9
_addon.Version 	= _addon._v.major
	..".".._addon._v.monthly
	..".".._addon._v.daily
	..".".._addon._v.minor
_addon.Name			= "wykkydsEquipmentLevel"
_addon.MAJOR 		= _addon.Name..".".._addon._v.major
_addon.MINOR 		= string.format(".%02d%02d%03d", _addon._v.monthly, _addon._v.daily, _addon._v.minor)
_addon.DisplayName  = "Wykkyd Equip. Level"
_addon.SavedVariableVersion = 3
_addon.Player = "" -- will be set on load by LibWykkkydFactory
_addon.Settings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.GlobalSettings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.wykkydPreferred = {
	["showString"] = true,
	["showColors"] = true,
	["colorValuesgood"] = 2,
	["colorValuesbad"] = 5,
}

_addon.LoadSavedVariables = function( self )
	self.parent = ZO_CharacterApparelSection
	self.colors = {
	   ["good"] = "|c2ECC40",
	   ["ok"] = "|cFFDC00",
	   ["bad"] = "|cFF4136"
	}
	self.slots = {
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
end

_addon.LoadSettingsMenu = function( self )
	local panelData = self:MakeStandardSettingsPanel( "Exodus Code Group", "|cFF2222" )
	panelData.displayName = "|cFF2222Wykkyd Equipment Level|r"
	local optionsTable = {
		[1] = {
			type = "description",
			text = "This addon adds an Equipment Level indicator to your character's inventory screen. This addon is based upon Biki's Equipment Level and acts as a replacement of that addon since Biki has stepped away from the game.",
		},
		[2] = self:MakeStandardLAMOption( self.Settings, "Show label name", "showString", true, "checkbox", { tooltip = "Shows the 'ELVL' string before the actual equipment level.", default=true } ),
		[3] = self:MakeStandardLAMOption( self.Settings, "Show colors", "showColors", true, "checkbox", { tooltip = "Colors the value depending on the difference between your character and equipment levels.", default=true } ),
		[4] = self:MakeStandardLAMOption( self.Settings, "- Max. difference for 'good' (green)", "colorValuesgood", 2, "slider", { min=0, max=50, step=1, default=2, } ),
		[5] = self:MakeStandardLAMOption( self.Settings, "- Max. difference for 'bad' (red)", "colorValuesbad", 5, "slider", { min=0, max=50, step=1, default=5, } ),
	}
	optionsTable = self:InjectAdvancedSettings( optionsTable, 1 )
	self.LAM:RegisterAddonPanel(_addon.Name.."_LAM", panelData)
	self.LAM:RegisterOptionControls(_addon.Name.."_LAM", optionsTable)
end

_addon.Initialize = function( self )
	self:RegisterEvent( EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
	function(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
		if bagId == BAG_WORN and updateReason == INVENTORY_UPDATE_REASON_DEFAULT then self:Update() end
	end, false)
	ZO_Character:SetHandler("OnShow", function() self:Update() end)
end

if wykkydsEquipmentLevelGlobal == nil then wykkydsEquipmentLevelGlobal = {} end
LWF4.REGISTER_FACTORY(
	_addon, false, true,
	function( self ) _addon:LoadSavedVariables( self ) end,
	function( self ) _addon:LoadSettingsMenu( self ) end,
	function( self ) _addon:Initialize( self ) end,
	"wykkydsEquipmentLevelGlobal", true
)

_addon.Update = function( self )
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

   iLevel = self:Round(iLevel / numItems)

   local lbl = self.parent:GetNamedChild("ItemLevelLabel") or self.Frames.NewLabel(self.parent:GetName() .. "ItemLevelLabel", self.parent)
   lbl:SetAnchor(TOPRIGHT, self.parent, BOTTOMRIGHT, -80, 5)
   lbl:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
   lbl:SetFont("ZoFontGameBold")
   lbl:SetColor(0.772, 0.760, 0.619, 1)

   local color = "|cFFFFFF"
   if self:GetOrDefault( true, self.Settings[ "showColors" ] ) then
      local playerLevel = GetUnitEffectiveLevel("player")
      local diff = playerLevel - iLevel

      if diff <= self:GetOrDefault( 2, self.Settings[ "colorValuesgood" ] ) then
         color = self.colors["good"]
      elseif diff > self:GetOrDefault( 2, self.Settings[ "colorValuesgood"] ) and diff < self:GetOrDefault( 5, self.Settings[ "colorValuesbad"] ) then
         color = self.colors["ok"]
      elseif diff >= self:GetOrDefault( 5, self.Settings[ "colorValuesbad"] ) then
         color = self.colors["bad"]
      end
   end

   if self:GetOrDefault( true, self.Settings[ "showString" ] ) then
      lbl:SetText("ELVL " .. color .. iLevel .. "|r")
   else
      lbl:SetText(color .. iLevel .. "|r")
   end
end
