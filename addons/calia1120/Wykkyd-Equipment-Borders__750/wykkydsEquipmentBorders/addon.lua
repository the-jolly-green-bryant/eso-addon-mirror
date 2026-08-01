--[[
  * Wykkyd [ Equipment Borders ]
  * Sponsored & Supported by: The Prydonian Elders
  * Author: Ravalox Darkshire (support@ecgroup.us)
  * Feature Author: @BalticBlues (display of equipped item level with colored warning and enchancment to repair warning colors)  9-June-2015
  * Embedded: LibStub & libAddonMenu by Seerah.
  * Special credit to Biki, the original author of InventoryItemBorders from which this was derived
  * Special Thanks To: Zenimax Online Studios & Bethesda for The Elder Scrolls Online
]]--

local _addon = {}
_addon._v = {}
_addon._v.major		= 2
_addon._v.monthly 	= 4
_addon._v.daily 	= 2
_addon._v.minor 	= 6
_addon.Version 	= _addon._v.major
	..".".._addon._v.monthly
	..".".._addon._v.daily
	..".".._addon._v.minor
_addon.Name			= "wykkydsEquipmentBorders"
_addon.MAJOR 		= _addon.Name..".".._addon._v.major
_addon.MINOR 		= string.format(".%02d%02d%03d", _addon._v.monthly, _addon._v.daily, _addon._v.minor)
_addon.DisplayName  = "Wykkyd Equip. Borders"
_addon.SavedVariableVersion = 3
_addon.Player = "" -- will be set on load by LibWykkkydFactory
_addon.Settings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.GlobalSettings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.wykkydPreferred = {
	["showBorders"] = true,
	["altBorders"] = true,
	["altActiveWeaponDisplay"] = true,
	["showCondition"] = true,
	["showLevel"] = true,
	["showColoredDoll"] = true,
	["warningThreshold"] = 25,
	["warningThresholdLevel"] = 5,
}

_addon.LoadSavedVariables = function( self )
	self.borderTex = "wykkydsEquipmentBorders/images/itemborder.dds"
	self.hoverTex = "wykkydsEquipmentBorders/images/griditem_hover.dds"
	self.borderTexAlt = "wykkydsEquipmentBorders/images/griditem_outline.dds"
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
	panelData.displayName = "|cFF2222Wykkyd Equipment Borders|r"
	local optionsTable = {
		[1] = {
			type = "description",
			text = "This addon adds color-coded Equipment Borders to your character's paperdoll inventory screen. This addon is based upon Biki's Inventory Item Borders and acts as a replacement of that addon since Biki has stepped away from the game.",
		},
		[2] = self:MakeStandardLAMOption( self.Settings, "Show item borders", "showBorders", true, "checkbox", { tooltip="Should the item rarity borders be displayed?",default=true, } ),
		[3] = self:MakeStandardLAMOption( self.Settings, "Use alternative borders", "altBorders", true, "checkbox", { tooltip="Colored borders same as IntenvoryGridView addon, nearly identical to default.", warning="Reloads UI when changed", default=true, } ),
		[4] = self:MakeStandardLAMOption( self.Settings, "Alternative active weapon display", "altActiveWeaponDisplay", true, "checkbox", { tooltip="Uses an alternative method of showing what weapon set is active so the colored borders are more visible",default=true, } ),
		[5] = self:MakeStandardLAMOption( self.Settings, "Show item condition", "showCondition", true, "checkbox", { tooltip="When set this option will show the repair condition of each equipped item.  The useability percentage will be displayed in the lower right corner.",default=true, } ),
		[6] = self:MakeStandardLAMOption( self.Settings, "Show item level", "showLevel", true, "checkbox", { tooltip="When set this option will show the item's minimum character level required to wear in the top right corner.",default=true, } ),
		[7] = self:MakeStandardLAMOption( self.Settings, "Color the doll red", "showColoredDoll", true, "checkbox", { tooltip="Should the doll in the equipment screen be colored red as a visual warning?",default=true, } ),
		[8] = self:MakeStandardLAMOption( self.Settings, "Warning threshold (in %) for item repair", "warningThreshold", 25, "slider", { min=1, max=100, step=1, default=25, }, { tooltip="The color of the % number shown will change to yellow when the item wear reaches the slider value.  The color will change to red if the % falls 2x the slider setting."} ),
		[9] = self:MakeStandardLAMOption( self.Settings, "Warning threshold for item levels", "warningThresholdLevel", 5, "slider", { min=1, max=10, step=1, default=5, }, { tooltip="The color of the equipped item level will change to yellow when the Character level has risen above the minimum level required to wear the item by the slider value.  The color will change to red if the Character's level rises 2x the slider setting."} ),
	}
	optionsTable[3].setFunc = function( val )
		_addon.Settings[ "altBorders" ] = val
		_addon:ReloadUI()
	end

	optionsTable[5].setFunc = function( val )
		if not WYK_EquipBorders then return end
		self.Settings["showCondition"] = val
		_addon:Refresh()
	end

	optionsTable[6].setFunc = function( val )
		if not WYK_EquipBorders then return end
		self.Settings["showLevel"] = val
		_addon:Refresh()
	end

	optionsTable = self:InjectAdvancedSettings( optionsTable, 1 )
	self.LAM:RegisterAddonPanel(_addon.Name.."_LAM", panelData)
	self.LAM:RegisterOptionControls(_addon.Name.."_LAM", optionsTable)
end

_addon.Initialize = function( self )
	self:Refresh()
	self:RegisterEvent(EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId, _, _, _, updateReason)
		if bagId == BAG_WORN and updateReason ~= INVENTORY_UPDATE_REASON_DYE_CHANGE then self:Refresh() end
	end, false)
	self:RegisterEvent(EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function() self:Refresh() end, false)
end

if wykkydsEquipmentBordersGlobal == nil then wykkydsEquipmentBordersGlobal = {} end
LWF4.REGISTER_FACTORY(
	_addon, false, true,
	function( self ) _addon:LoadSavedVariables( self ) end,
	function( self ) _addon:LoadSettingsMenu( self ) end,
	function( self ) _addon:Initialize( self ) end,
	"wykkydsEquipmentBordersGlobal", true
)

_addon.Refresh = function( self )
	local doll = ZO_CharacterPaperDoll
	local redDoll = false

	if self:GetOrDefault( true, self.Settings[ "altActiveWeaponDisplay" ] ) then
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
			local level_item
			local level_player
			local name = tostring(v .. "rarityBorder")
			local nameLabel = tostring(v .. "labelCondition")
			local nameLevel = tostring(v .. "labelLevel")
			local parent = _G[v]

			local bg = parent:GetNamedChild("rarityBorder") or self.Frames.NewImage(name, parent)
			bg:SetDimensions(46, 46)
			bg:SetAnchor(BOTTOM, parent, BOTTOM, 0, 1)

			if self:GetOrDefault( true, self.Settings[ "altBorders" ] ) then bg:SetTexture(self.borderTexAlt)
			else bg:SetTexture(self.borderTex) end
			bg:SetDrawLayer(0)
			bg:SetHidden(not self:GetOrDefault( true, self.Settings[ "showBorders" ] ))

			local color = GetItemQualityColor(quality)
			bg:SetColor(color:UnpackRGBA())

			local condition = GetItemCondition(BAG_WORN, _G[k])

			local label = parent:GetNamedChild("labelCondition") or self.Frames.NewLabel(nameLabel, parent, CT_LABEL)
			label:SetText(tostring(condition .. "%"))
			label:SetAnchor(BOTTOMRIGHT, bg, BOTTOMRIGHT, -1, -5)
			label:SetDrawLayer(1)
			label:SetFont("ZoFontGameSmall")
			label:SetDimensions(50, 10)
			label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
			label:SetHidden(not self:GetOrDefault( true, self.Settings[ "showCondition" ] ))

			-- color string yellow if warning limit reached, red if of over 2 * warning level reached
			local warningLimit = self:GetOrDefault( 25, self.Settings[ "warningThreshold" ] )
			local difference = 100 - condition
			if difference >= 2 * warningLimit then
				label:SetColor(1, 0.25, 0.21, 1)
			elseif difference >= warningLimit then
				label:SetColor(1, 1, 0.21, 1)
			else
				label:SetColor(1, 1, 1, 1)
			end

			-- hide when full durability or option disabled
			if condition == 100 then
				label:SetHidden(true)
			end

			-- Show Minimum player level for equipped items
			if IsUnitVeteran('player') then
				level_player = 50 + GetUnitVeteranRank("player")
			else
				level_player = GetUnitLevel("player")
			end

			local labelL = parent:GetNamedChild("labelLevel") or self.Frames.NewLabel(nameLevel, parent, CT_LABEL)

			local level_item = GetItemRequiredVeteranRank(BAG_WORN, _G[k])
			if level_item >0 then
				labelL:SetText(tostring("v" .. tostring(level_item)))
				level_item = 50 + level_item
			else
				level_item = GetItemRequiredLevel(BAG_WORN, _G[k])
				labelL:SetText(tostring(level_item))
			end

			labelL:SetAnchor(TOPRIGHT, bg, TOPRIGHT, -1, -3)
			labelL:SetDrawLayer(1)
			labelL:SetFont("ZoFontGameSmall")
			labelL:SetDimensions(50, 10)
			labelL:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
			labelL:SetHidden(not self:GetOrDefault( true, self.Settings[ "showLevel" ] ))

			-- color string yellow if warning limit reached, red if of over 2 * warning level reached
			local warningLimit = self:GetOrDefault( 5, self.Settings[ "warningThresholdLevel" ] )
			local difference = level_player - level_item
			if difference >= 2 * warningLimit then
				labelL:SetColor(1, 0.25, 0.21, 1)
			elseif difference >= warningLimit then
				labelL:SetColor(1, 1, 0.21, 1)
			else
				labelL:SetColor(1, 1, 1, 1)
			end
			-- ITEM LEVEL CODE END

			-- color doll red to indicate equipment damage
			if self:GetOrDefault( true, self.Settings[ "showColoredDoll" ] ) == true then
				if condition <= warningLimit then redDoll = true end
			else doll:SetColor(1, 1, 1, 1) end
		else
			local bg = _G[v]:GetNamedChild("rarityBorder")
			if bg ~= nil then bg:SetHidden(true) end

			local label = _G[v]:GetNamedChild("labelCondition")
			if label ~= nil then label:SetHidden(true) end

			local label = _G[v]:GetNamedChild("labelLevel")
			if label ~= nil then label:SetHidden(true) end
		end
	end

	if redDoll then doll:SetColor(1, 0, 0, 0.5)
	else doll:SetColor(1, 1, 1, 1)
	end
end

WYK_EquipBorders = _addon
