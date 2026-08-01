------------------------------------------------
-- Durability Template
-- @author Flagrick
------------------------------------------------
DurabilityConfig											= ZO_Object:Subclass()
DurabilityConfig.db										= nil
DurabilityConfig.EVENT_TOGGLE_SHOW					= 'Durability_TOGGLE_SHOW'
DurabilityConfig.EVENT_TOGGLE_TOOLTIP				= 'Durability_TOGGLE_TOOLTIP'
DurabilityConfig.EVENT_ENTRY_SCALE					= 'Durability_ENTRY_SCALE'
DurabilityConfig.EVENT_CHANGE_ARMOR_COLORS		= 'Durability_CHANGE_ARMOR_COLORS'
DurabilityConfig.EVENT_CHANGE_WEAPON_COLORS 		= 'Durability_CHANGE_WEAPON_COLORS'
DurabilityConfig.EVENT_ENTRY_ALPHA					= 'Durability_CHANGE_ENTRY_ALPHA'
DurabilityConfig.EVENT_ENTRY_TRESHOLD		   	= 'Durability_CHANGE_ENTRY_TRESHOLD'
DurabilityConfig.EVENT_TOGGLE_AUTOMATIC_HIDDING	= 'Durability_TOGGLE_AUTOMATIC_HIDDING'

--Local constants -------------------------------------------------------------
local ADDON_VERSION = "1.3"
local ADDON_NAME = "Durability"
--Libraries--------------------------------------------------------------------
local CBM = CALLBACK_MANAGER
local LAM2 = LibStub("LibAddonMenu-2.0")
if ( not LAM2 ) then return end
-----------------------------------------------------------------------------------------
function DurabilityConfig:New( ... )
	local result = ZO_Object.New( self )
	result:Initialize( ... )
	return result
end
-----------------------------------------------------------------------------------------
function DurabilityConfig:Initialize( db )
	self.db = db
	
	local panelData = {
		type = "panel",
		name = ADDON_NAME,
		displayName = ADDON_NAME .. " by |cAA0000Flagrick|r",
		author = "|cAA0000Flagrick|r",
		version = ADDON_VERSION,
		slashCommand = "/durability",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	LAM2:RegisterAddonPanel(ADDON_NAME, panelData)

	local optionsTable = {
		------------GENERAL--------------
		[1] = {
			type = "header",
			name = "General",
			width = "full",	--or "half" (optional)
		},
		[2] = {
			type = "description",
			--title = "My Title",	--(optional)
			title = nil,	--(optional)
			text = "Durability shows armor for item you are wearing and charges for weapons that are used.",
			width = "full",	--or "half" (optional)
		},
		[3] = {
			type = "slider",
			name = "Scale",
			tooltip = "Entry Scale (1 to 3)",
			min = 1,
			max = 3,
			step = 1,	--(optional)
			getFunc = function() return self.db.DurabilityScale end,
			setFunc = function(value) self:EntryScale(value) end,
			width = "full",	--or "half" (optional)
			default = Durability_Defaults.DurabilityScale
			--default = 5,	--(optional)
		},
		[4] = {
			type = "checkbox",
			name = "Tooltip",
			tooltip = "Tooltip with durability, cost, and weapons charge details.",
			getFunc = function() return self.db.DurabilityTooltip end,
			setFunc = function(value) self:ToggleTooltip(value) end,
			width = "full",	--or "half" (optional)
			default = Durability_Defaults.DurabilityTooltip
			--warning = "Will need to reload the UI.",	--(optional)
			},
		[5] = {
			type = "checkbox",
			name = "Texts",
			tooltip = "Should we show texts ?",
			getFunc = function() return self.db.DurabilityText end,
			setFunc = function(value) self:ToggleTexts(value) end,
			width = "full",	--or "half" (optional)
			default = Durability_Defaults.DurabilityText
			--warning = "Will need to reload the UI.",	--(optional)
			},
		[6] = {
			type = "checkbox",
			name = "Automatic Hidding",
			tooltip = "If set, Durability will be automaticaly hide if inventory or game menu are open - /reloadui will be done",
			getFunc = function() return self.db.DurabilityAutomaticHidding end,
			setFunc = function(value) self:ToggleAutomaticHidding(value) end,
			width = "full",	--or "half" (optional)
			default = Durability_Defaults.DurabilityAutomaticHidding,
			warning = "Will need to reload the UI.",	--(optional)
			},
	--ARMOR COLORS
		[7] = {
			type = "header",
			name = "Colors and Alpha",
			width = "full",	--or "half" (optional)
		},
		[8] = {
			type = "colorpicker",
			name = "No armor color",
			tooltip = "Select a color.",
			getFunc = function() return self.db.DurabilityColor_NoArmor["r"], self.db.DurabilityColor_NoArmor["g"], self.db.DurabilityColor_NoArmor["b"] end,	--(alpha is optional)
			setFunc = function(r,g,b) self:ChangeColorNoArmor(r,g,b) end,	--(alpha is optional)
			width = "full",	--or "half" (optional)
			default = Durability_Defaults.DurabilityColor_NoArmor
			--warning = "warning text",
		},
		[9] = {
			type = "colorpicker",
			name = "Up to 30% armor color",
			tooltip = "Select a color.",
			getFunc = function() return self.db.DurabilityColor_UpToStep1["r"], self.db.DurabilityColor_UpToStep1["g"], self.db.DurabilityColor_UpToStep1["b"] end,	--(alpha is optional)
			setFunc = function(r,g,b) self:ChangeColorUpToStep1(r,g,b) end,	--(alpha is optional)
			width = "full",	--or "half" (optional)
			default = Durability_Defaults.DurabilityColor_UpToStep1
			--warning = "warning text",
		},
		[10] = {
			type = "colorpicker",
			name = "Up to 60% armor color",
			tooltip = "Select a color.",
			getFunc = function() return self.db.DurabilityColor_UpToStep2["r"], self.db.DurabilityColor_UpToStep2["g"], self.db.DurabilityColor_UpToStep2["b"] end,	--(alpha is optional)
			setFunc = function(r,g,b) self:ChangeColorUpToStep2(r,g,b) end,	--(alpha is optional)
			width = "full",	--or "half" (optional)
			default = Durability_Defaults.DurabilityColor_UpToStep2
			--warning = "warning text",
		},
		[11] = {
			type = "colorpicker",
			name = "Up to 90% armor color",
			tooltip = "Select a color.",
			getFunc = function() return self.db.DurabilityColor_UpToStep3["r"], self.db.DurabilityColor_UpToStep3["g"], self.db.DurabilityColor_UpToStep3["b"] end,	--(alpha is optional)
			setFunc = function(r,g,b) self:ChangeColorUpToStep3(r,g,b) end,	--(alpha is optional)
			width = "full",	--or "half" (optional)
			default = Durability_Defaults.DurabilityColor_UpToStep3
			--warning = "warning text",
		},
		[12] = {
			type = "colorpicker",
			name = "Full armor color",
			tooltip = "Select a color.",
			getFunc = function() return self.db.DurabilityColor_FullArmor["r"], self.db.DurabilityColor_FullArmor["g"], self.db.DurabilityColor_FullArmor["b"] end,	--(alpha is optional)
			setFunc = function(r,g,b) self:ChangeColorFullArmor(r,g,b) end,	--(alpha is optional)
			width = "full",	--or "half" (optional)
			default = Durability_Defaults.DurabilityColor_FullArmor
			--warning = "warning text",
		},
	--WEAPON COLORS
		[13] = {
			type = "colorpicker",
			name = "Weapon front color",
			tooltip = "Select a color.",
			getFunc = function() return self.db.DurabilityColor_WpnFront["r"], self.db.DurabilityColor_WpnFront["g"], self.db.DurabilityColor_WpnFront["b"] end,	--(alpha is optional)
			setFunc = function(r,g,b) self:ChangeColorWpnFront(r,g,b) end,	--(alpha is optional)
			width = "half",	--or "half" (optional)
			default = Durability_Defaults.DurabilityColor_WpnFront
			--warning = "warning text",
		},
		[14] = {
			type = "colorpicker",
			name = "Weapon back color",
			tooltip = "Select a color.",
			getFunc = function() return self.db.DurabilityColor_WpnBack["r"], self.db.DurabilityColor_WpnBack["g"], self.db.DurabilityColor_WpnBack["b"] end,	--(alpha is optional)
			setFunc = function(r,g,b) self:ChangeColorWpnBack(r,g,b) end,	--(alpha is optional)
			width = "half",	--or "half" (optional)
			default = Durability_Defaults.DurabilityColor_WpnBack
			--warning = "warning text",
		},
		[15] = {
			type = "slider",
			name = "Armor alpha",
			tooltip = "Select armor alpha.",
			min = 0,
			max = 100,
			step = 1,	--(optional)
			getFunc = function() return self.db.DurabilityAlpha end,
			setFunc = function(value) self:EntryAlpha(value) end,
			width = "half",	--or "half" (optional)
			default = Durability_Defaults.DurabilityAlpha
			--default = 5,	--(optional)
		},
		[16] = {
			type = "slider",
			name = "Frame alpha",
			tooltip = "Select Frame alpha.",
			min = 0,
			max = 100,
			step = 1,	--(optional)
			getFunc = function() return self.db.DurabilityFrameAlpha end,
			setFunc = function(value) self:EntryFrameAlpha(value) end,
			width = "half",	--or "half" (optional)
			default = Durability_Defaults.DurabilityFrameAlpha
			--default = 5,	--(optional)
		},
--ARMOR TRESHOLDS
		[17] = {
			type = "header",
			name = "Armor Thresholds",
			width = "full",	--or "half" (optional)
		},
		[18] = {
			type = "checkbox",
			name = "Armor Thresholds",
			tooltip = "Should we activate Armor Thresholds ?",
			getFunc = function() return self.db.DurabilityArmorThreshold end,
			setFunc = function(value) self:ToggleArmorThreshold(value) end,
			width = "full",	--or "half" (optional)
			default = Durability_Defaults.DurabilityArmorThreshold
			--warning = "Will need to reload the UI.",	--(optional)
			},
		[19] = {
			type = "slider",
			name = "Global Armor Threshold (%)",
			tooltip = "Select global armor threshold.",
			min = 0,
			max = 100,
			step = 1,	--(optional)
			getFunc = function() return self.db.DurabilityGlobalArmorThreshold end,
			setFunc = function(value) self:EntryGlobalArmorThreshold(value) end,
			width = "half",	--or "half" (optional)
			disabled = function() return not self.db.DurabilityArmorThreshold end,
			default = Durability_Defaults.DurabilityGlobalArmorThreshold
			--default = 5,	--(optional)
		},
		[20] = {
			type = "slider",
			name = "Global Armor Threshold (%)",
			tooltip = "Select global armor threshold.",
			min = 0,
			max = 100,
			step = 1,	--(optional)
			getFunc = function() return self.db.DurabilityMinArmorThreshold end,
			setFunc = function(value) self:EntryMinArmorThreshold(value) end,
			width = "half",	--or "half" (optional)
			disabled = function() return not self.db.DurabilityArmorThreshold end,
			default = Durability_Defaults.DurabilityMinArmorThreshold
			--default = 5,	--(optional)
		},

--WEAPON TRESHOLDS
		[21] = {
			type = "header",
			name = "Weapon Thresholds",
			width = "full",	--or "half" (optional)
		},
		[22] = {
			type = "checkbox",
			name = "Weapon Threshold",
			tooltip = "Should we activate Weapon Threshold ?",
			getFunc = function() return self.db.DurabilityWeaponThreshold end,
			setFunc = function(value) self:ToggleWeaponThreshold(value) end,
			width = "full",	--or "half" (optional)
			default = Durability_Defaults.DurabilityWeaponThreshold
			--warning = "Will need to reload the UI.",	--(optional)
			},
		[23] = {
			type = "slider",
			name = "Min Weapon Threshold (%)",
			tooltip = "Select min weapon threshold.",
			min = 0,
			max = 100,
			step = 1,	--(optional)
			getFunc = function() return self.db.DurabilityMinWeaponThreshold end,
			setFunc = function(value) self:EntryMinWeaponThreshold(value) end,
			width = "full",	--or "half" (optional)
			disabled = function() return not self.db.DurabilityWeaponThreshold end,
			default = Durability_Defaults.DurabilityMinWeaponThreshold
			--default = 5,	--(optional)
		},

--VISIBILITY
		[24] = {
			type = "header",
			name = "Visibility Frame",
			width = "full",	--or "half" (optional)
		},
		[25] = {
			type = "button",
			name = "Show/Hide",
			tooltip = "Click to show/hide frame.",
			func = function() self:ToggleShow() end,
			width = "full",	--or "half" (optional)
			default = Durability_Defaults.DurabilityShow
			--warning = "Will need to reload the UI.",	--(optional)
		},
	}

	LAM2:RegisterOptionControls(ADDON_NAME, optionsTable)

end
-----------------------------------------------------------------------------------------
function DurabilityConfig:ChangeColorNoArmor(r,g,b)
	self.db.DurabilityColor_NoArmor["r"]=r
	self.db.DurabilityColor_NoArmor["g"]=g
	self.db.DurabilityColor_NoArmor["b"]=b
	self.db.DurabilityColor_NoArmor["a"]=1
	CBM:FireCallbacks( self.EVENT_CHANGE_ARMOR_COLORS )
end
-----------------------------------------------------------------------------------------
function DurabilityConfig:ChangeColorUpToStep1(r,g,b)
	self.db.DurabilityColor_UpToStep1["r"]=r
	self.db.DurabilityColor_UpToStep1["g"]=g
	self.db.DurabilityColor_UpToStep1["b"]=b
	self.db.DurabilityColor_UpToStep1["a"]=1
	CBM:FireCallbacks( self.EVENT_CHANGE_ARMOR_COLORS )
end
-----------------------------------------------------------------------------------------
function DurabilityConfig:ChangeColorUpToStep2(r,g,b)
	self.db.DurabilityColor_UpToStep2["r"]=r
	self.db.DurabilityColor_UpToStep2["g"]=g
	self.db.DurabilityColor_UpToStep2["b"]=b
	self.db.DurabilityColor_UpToStep2["a"]=1
	CBM:FireCallbacks( self.EVENT_CHANGE_ARMOR_COLORS )
end
-----------------------------------------------------------------------------------------
function DurabilityConfig:ChangeColorUpToStep3(r,g,b)
	self.db.DurabilityColor_UpToStep3["r"]=r
	self.db.DurabilityColor_UpToStep3["g"]=g
	self.db.DurabilityColor_UpToStep3["b"]=b
	self.db.DurabilityColor_UpToStep3["a"]=1
	CBM:FireCallbacks( self.EVENT_CHANGE_ARMOR_COLORS )
end
-----------------------------------------------------------------------------------------
function DurabilityConfig:ChangeColorFullArmor(r,g,b)
	self.db.DurabilityColor_FullArmor["r"]=r
	self.db.DurabilityColor_FullArmor["g"]=g
	self.db.DurabilityColor_FullArmor["b"]=b
	self.db.DurabilityColor_FullArmor["a"]=1
	CBM:FireCallbacks( self.EVENT_CHANGE_ARMOR_COLORS )
end
-----------------------------------------------------------------------------------------
function DurabilityConfig:ChangeColorWpnFront(r,g,b)
	self.db.DurabilityColor_WpnFront["r"]=r
	self.db.DurabilityColor_WpnFront["g"]=g
	self.db.DurabilityColor_WpnFront["b"]=b
	self.db.DurabilityColor_WpnFront["a"]=1
	CBM:FireCallbacks( self.EVENT_CHANGE_ARMOR_COLORS )
end
-----------------------------------------------------------------------------------------
function DurabilityConfig:ChangeColorWpnBack(r,g,b)
	self.db.DurabilityColor_WpnBack["r"]=r
	self.db.DurabilityColor_WpnBack["g"]=g
	self.db.DurabilityColor_WpnBack["b"]=b
	self.db.DurabilityColor_WpnBack["a"]=1
	CBM:FireCallbacks( self.EVENT_CHANGE_ARMOR_COLORS )
end
-------------------------------------------------------------------------------
function DurabilityConfig:ToggleTooltip(value) 
	self.db.DurabilityTooltip = value
	CBM:FireCallbacks( self.EVENT_TOGGLE_TOOLTIP )
end
-----------------------------------------------------------------------------------------
function DurabilityConfig:ToggleShow() 
	self.db.DurabilityShow = not self.db.DurabilityShow
	CBM:FireCallbacks( self.EVENT_TOGGLE_SHOW )
end
-----------------------------------------------------------------------------------------
function DurabilityConfig:EntryScale(scale) 
	self.db.DurabilityScale = scale
	CBM:FireCallbacks( self.EVENT_ENTRY_SCALE )
end
-----------------------------------------------------------------------------------------
function DurabilityConfig:EntryAlpha(alpha) 
	self.db.DurabilityAlpha = alpha
	CBM:FireCallbacks( self.EVENT_ENTRY_ALPHA )
end
-----------------------------------------------------------------------------------------
function DurabilityConfig:EntryFrameAlpha(alpha) 
	self.db.DurabilityFrameAlpha = alpha
	CBM:FireCallbacks( self.EVENT_ENTRY_ALPHA )
end
-----------------------------------------------------------------------------------------
function DurabilityConfig:ToggleAutomaticHidding(value)
	self.db.DurabilityAutomaticHidding = value
	CBM:FireCallbacks( self.EVENT_TOGGLE_AUTOMATIC_HIDDING )
end
-----------------------------------------------------------------------------------------
function DurabilityConfig:ToggleArmorThreshold(value)
	self.db.DurabilityArmorThreshold= value
	CBM:FireCallbacks( self.EVENT_ENTRY_TRESHOLD )
end
-----------------------------------------------------------------------------------------
function DurabilityConfig:EntryGlobalArmorThreshold(value)
	self.db.DurabilityGlobalArmorThreshold=value
	CBM:FireCallbacks( self.EVENT_ENTRY_TRESHOLD )
end
-----------------------------------------------------------------------------------------
function DurabilityConfig:EntryMinArmorThreshold(value)
	self.db.DurabilityMinArmorThreshold=value
	CBM:FireCallbacks( self.EVENT_ENTRY_TRESHOLD )
end
-----------------------------------------------------------------------------------------
function DurabilityConfig:ToggleWeaponThreshold(value)
	self.db.DurabilityWeaponThreshold= value
	CBM:FireCallbacks( self.EVENT_ENTRY_TRESHOLD )
end
-----------------------------------------------------------------------------------------
function DurabilityConfig:EntryMinWeaponThreshold(value)
	self.db.DurabilityMinWeaponThreshold=value
	CBM:FireCallbacks( self.EVENT_ENTRY_TRESHOLD )
end
-----------------------------------------------------------------------------------------
function DurabilityConfig:ToggleTexts(value)
	self.db.DurabilityText = value
	CBM:FireCallbacks( self.EVENT_ENTRY_SCALE )
end