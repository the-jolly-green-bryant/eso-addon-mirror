AUI.Settings.Attributes = {}

local isLoaded = false

local LAM = LibStub("LibAddonMenu-2.0")
local LMP = LibStub("LibMediaProvider-1.0")

local changed = false
local isPreviewShowing = false

local player_attributes_enabled = false
local target_attributes_enabled = false
local group_attributes_enabled = false
local boss_attributes_enabled = false

local defaultSettings =
{
	--general
	lock_windows = false,

	--group
	group_attributes_enabled = true,		
		
	--player
	player_attributes_enabled = true,	
		
	--target			
	target_attributes_enabled = true,	
		
	--boss
	boss_attributes_enabled = true,
	boss_show_text = true,
	boss_font_size = 16,
	boss_font_art = "Sansita One",
	boss_use_thousand_seperator = true,
}

local function GetCurrentTemplateName()
	local templateData = AUI.Attributes.GetCurrentTemplateData()
	return templateData.internName
end

local function IsSettingDisabled(_type, _setting)
	local currentTemplateData = AUI.Attributes.GetCurrentTemplateData()
	if currentTemplateData then
		for type, data in pairs(currentTemplateData.attributeData) do	
			if _type == type then
				if data.disabled_settings and data.disabled_settings[_setting] then
					return true				
				end		
			end		
		end
	end
	
	return false
end

local function DoesAttributeIdExists(_type)
	local currentTemplateData = AUI.Attributes.GetCurrentTemplateData()
	if currentTemplateData then
		for type, _ in pairs(currentTemplateData.attributeData) do	
			if _type == type then
				return true					
			end		
		end
	end
	
	return false
end

local function AcceptSettings()
	AUI.Settings.Attributes.player_attributes_enabled = player_attributes_enabled
	AUI.Settings.Attributes.target_attributes_enabled = target_attributes_enabled
	AUI.Settings.Attributes.group_attributes_enabled = group_attributes_enabled
	AUI.Settings.Attributes.boss_attributes_enabled = boss_attributes_enabled
	
	ReloadUI()
end

local function GetPlayerColorSettingsTable()
	local optionTable = {	
		{
			type = "header",
			name = AUI.L10n.GetString("player")
		},			
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("health"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_PLAYER_UNIT_TAG)					
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].bar_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_PLAYER_UNIT_TAG)					
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].bar_color[2],
			width = "half",
		},				
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("magicka"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}					
				AUI.Attributes.UpdateUI(AUI_PLAYER_UNIT_TAG)							
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].bar_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}					
				AUI.Attributes.UpdateUI(AUI_PLAYER_UNIT_TAG)							
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].bar_color[2],
			width = "half",
		},				
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("stamina"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_PLAYER_UNIT_TAG)						
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].bar_color[1],
			width = "half",
		},	
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_PLAYER_UNIT_TAG)						
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].bar_color[2],
			width = "half",
		},					
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("stamina_mount"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_PLAYER_UNIT_TAG)					
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].bar_color[1],
			width = "half",
		},	
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_PLAYER_UNIT_TAG)					
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].bar_color[2],
			width = "half",
		},				
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("werewolf"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_PLAYER_UNIT_TAG)					
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].bar_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_PLAYER_UNIT_TAG)					
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].bar_color[2],
			width = "half",
		},			
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("siege")  .. " (" .. AUI.L10n.GetString("health") .. ")",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_PLAYER_UNIT_TAG)											
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].bar_color[1],
			width = "half",
		},	
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_PLAYER_UNIT_TAG)											
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].bar_color[2],
			width = "half",
		},				
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("shield"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_PLAYER_UNIT_TAG)						
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].bar_color[1],
			width = "half",
		},	
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_PLAYER_UNIT_TAG)					
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].bar_color[2],
			width = "half",
		},					
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("regeneration") .. " (" .. AUI.L10n.GetString("health") ..")",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].increase_regen_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].increase_regen_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_PLAYER_UNIT_TAG)
						
				AUI.Attributes.RemoveAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
				AUI.Attributes.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].increase_regen_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].increase_regen_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].increase_regen_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_PLAYER_UNIT_TAG)
						
				AUI.Attributes.RemoveAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
				AUI.Attributes.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)						
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].increase_regen_color[2],
			width = "half",
		},				
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("degeneration") .. " (" .. AUI.L10n.GetString("health") ..")",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].decrease_regen_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].decrease_regen_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_PLAYER_UNIT_TAG)
					
				AUI.Attributes.RemoveAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
				AUI.Attributes.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)							
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].decrease_regen_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].decrease_regen_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].decrease_regen_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_PLAYER_UNIT_TAG)
					
				AUI.Attributes.RemoveAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
				AUI.Attributes.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)								
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].decrease_regen_color[2],
			width = "half",
		},		
	}

	return optionTable
end

local function GetTargetColorSettingsTable(_type, submenuName)
local shieldType = AUI_ATTRIBUTE_TYPE_PRIMARY_TARGET_SHIELD

if _type == AUI_ATTRIBUTE_TYPE_SECUNDARY_TARGET_HEALTH then
	shieldType = AUI_ATTRIBUTE_TYPE_SECUNDARY_TARGET_SHIELD	
end

local optionTable = 
	{	
		{
			type = "header",
			name = submenuName
		},	
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("health"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_TARGET_UNIT_TAG)												
			  end,
			default = defaultSettings[GetCurrentTemplateName()][_type].bar_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_TARGET_UNIT_TAG)												
			  end,
			default = defaultSettings[GetCurrentTemplateName()][_type].bar_color[2],
			width = "half",
		},	
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("shield"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][shieldType].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][shieldType].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_TARGET_UNIT_TAG)					
			end,
			default = defaultSettings[GetCurrentTemplateName()][shieldType].bar_color[1],
			width = "half",
		},	
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][shieldType].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][shieldType].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_TARGET_UNIT_TAG)					
			end,
			default = defaultSettings[GetCurrentTemplateName()][shieldType].bar_color[2],
			width = "half",
		},									
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("friendly"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_friendly_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_friendly_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				if preview then
					AUI.Attributes.UpdateUI(AUI_TARGET_UNIT_TAG)
					AUI.Attributes.UpdateSingleBar(AUI_TARGET_UNIT_TAG, POWERTYPE_HEALTH, false, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, 
					{					
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_friendly_color[1]), 
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_friendly_color[2])
					})
				end													
			  end,
			default = defaultSettings[GetCurrentTemplateName()][_type].bar_friendly_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_friendly_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_friendly_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				if preview then
					AUI.Attributes.UpdateUI(AUI_TARGET_UNIT_TAG)
					AUI.Attributes.UpdateSingleBar(AUI_TARGET_UNIT_TAG, POWERTYPE_HEALTH, false, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, 
					{					
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_friendly_color[1]), 
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_friendly_color[2])
					})						
				end												
			  end,
			default = defaultSettings[GetCurrentTemplateName()][_type].bar_friendly_color[2],
			width = "half",
		},				
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("allied") .. " (" .. AUI.L10n.GetString("npc") .. ")",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_allied_npc_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_allied_npc_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				if preview then
					AUI.Attributes.UpdateUI(AUI_TARGET_UNIT_TAG)
					AUI.Attributes.UpdateSingleBar(AUI_TARGET_UNIT_TAG, POWERTYPE_HEALTH, false, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, 
					{					
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_allied_npc_color[1]), 
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_allied_npc_color[2])
					})							
				end
			  end,
			default = defaultSettings[GetCurrentTemplateName()][_type].bar_allied_npc_color[1],
			width = "half",
		},	
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_allied_npc_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_allied_npc_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				if preview then
					AUI.Attributes.UpdateUI(AUI_TARGET_UNIT_TAG)
					AUI.Attributes.UpdateSingleBar(AUI_TARGET_UNIT_TAG, POWERTYPE_HEALTH, false, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, 
					{					
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_allied_npc_color[1]), 
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_allied_npc_color[2])
					})	
				end
			  end,
			default = defaultSettings[GetCurrentTemplateName()][_type].bar_allied_npc_color[2],
			width = "half",
		},	
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("allied") .. " (" .. AUI.L10n.GetString("player") .. ")",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_allied_player_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a)
				AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_allied_player_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				if preview then
					AUI.Attributes.UpdateUI(AUI_TARGET_UNIT_TAG)
					AUI.Attributes.UpdateSingleBar(AUI_TARGET_UNIT_TAG, POWERTYPE_HEALTH, false, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, 
					{					
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_allied_player_color[1]), 
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_allied_player_color[2])
					})	
				end	
			  end,
			default = defaultSettings[GetCurrentTemplateName()][_type].bar_allied_player_color[1],
			width = "half",
		},	
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_allied_player_color[2]):UnpackRGBA() end,
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_allied_player_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a)
				AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_allied_player_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				if preview then
					AUI.Attributes.UpdateUI(AUI_TARGET_UNIT_TAG)
					AUI.Attributes.UpdateSingleBar(AUI_TARGET_UNIT_TAG, POWERTYPE_HEALTH, false, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, 
					{					
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_allied_player_color[1]), 
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_allied_player_color[2])
					})	
				end		
			  end,
			default = defaultSettings[GetCurrentTemplateName()][_type].bar_allied_player_color[2],
			width = "half",
		},				
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("neutral"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_neutral_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_neutral_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				if preview then
					AUI.Attributes.UpdateUI(AUI_TARGET_UNIT_TAG)
					AUI.Attributes.UpdateSingleBar(AUI_TARGET_UNIT_TAG, POWERTYPE_HEALTH, false, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, 
					{					
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_neutral_color[1]), 
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_neutral_color[2])
					})	
				end
			  end,
			default = defaultSettings[GetCurrentTemplateName()][_type].bar_neutral_color[1],
			width = "half",
		},	
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_neutral_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_neutral_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				if preview then
					AUI.Attributes.UpdateUI(AUI_TARGET_UNIT_TAG)
					AUI.Attributes.UpdateSingleBar(AUI_TARGET_UNIT_TAG, POWERTYPE_HEALTH, false, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, 
					{					
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_neutral_color[1]), 
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_neutral_color[2])
					})	
				end
			  end,
			default = defaultSettings[GetCurrentTemplateName()][_type].bar_neutral_color[2],
			width = "half",
		},					
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("guard"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_guard_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a)
				AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_guard_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				if preview then
					AUI.Attributes.UpdateUI(AUI_TARGET_UNIT_TAG)
					AUI.Attributes.UpdateSingleBar(AUI_TARGET_UNIT_TAG, POWERTYPE_HEALTH, false, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, 
					{					
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_guard_color[1]), 
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_guard_color[2])
					})
				end	
			  end,
			default = defaultSettings[GetCurrentTemplateName()][_type].bar_guard_color[1],
			width = "half",
		},	
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_guard_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a)
				AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_guard_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				if preview then
					AUI.Attributes.UpdateUI(AUI_TARGET_UNIT_TAG)
					AUI.Attributes.UpdateSingleBar(AUI_TARGET_UNIT_TAG, POWERTYPE_HEALTH, false, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, 
					{					
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_guard_color[1]), 
						AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].bar_guard_color[2])
					})
				end		
			  end,
			default = defaultSettings[GetCurrentTemplateName()][_type].bar_guard_color[2],
			width = "half",
		},	
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("regeneration"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].increase_regen_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][_type].increase_regen_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_TARGET_UNIT_TAG)
							
				AUI.Attributes.AddAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
				AUI.Attributes.AddAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)						
			end,
			default = defaultSettings[GetCurrentTemplateName()][_type].increase_regen_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].increase_regen_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][_type].increase_regen_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_TARGET_UNIT_TAG)

				AUI.Attributes.AddAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
				AUI.Attributes.AddAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)							
			end,
			default = defaultSettings[GetCurrentTemplateName()][_type].increase_regen_color[2],
			width = "half",
		},				
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("degeneration"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].decrease_regen_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][_type].decrease_regen_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_TARGET_UNIT_TAG)

				AUI.Attributes.AddAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
				AUI.Attributes.AddAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)							
			end,
			default = defaultSettings[GetCurrentTemplateName()][_type].decrease_regen_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][_type].decrease_regen_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][_type].decrease_regen_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_TARGET_UNIT_TAG)
						
				AUI.Attributes.AddAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
				AUI.Attributes.AddAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)						
			end,
			default = defaultSettings[GetCurrentTemplateName()][_type].decrease_regen_color[2],
			width = "half",
		},	
	}
	
	return optionTable
end

local function GetGroupColorSettingsTable()
	local optionTable = 
	{	
		{
			type = "header",
			name = AUI.L10n.GetString("group")
		},	
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("health"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.Group.SetPreviewGroupSize(4)
				AUI.Attributes.UpdateUI()	
			  end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].bar_color[1],
			width = "half",
		},		
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.Group.SetPreviewGroupSize(4)
				AUI.Attributes.UpdateUI()
			  end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].bar_color[2],
			width = "half",
		},	
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("shield"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_SHIELD].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_SHIELD].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.Group.SetPreviewGroupSize(4)
				AUI.Attributes.UpdateUI()	
			  end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_SHIELD].bar_color[1],
			width = "half",
		},		
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_SHIELD].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_SHIELD].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.Group.SetPreviewGroupSize(4)
				AUI.Attributes.UpdateUI()					
			  end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_SHIELD].bar_color[2],
			width = "half",
		},					
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("regeneration"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].increase_regen_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].increase_regen_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.Group.SetPreviewGroupSize(4)
				AUI.Attributes.UpdateUI()
							
				for i = 1, 4, 1 do	
					unitTag = "group" .. i	

					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)									
				end								
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].increase_regen_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].increase_regen_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].increase_regen_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.Group.SetPreviewGroupSize(4)
				AUI.Attributes.UpdateUI()		
							
				for i = 1, 4, 1 do	
					unitTag = "group" .. i	

					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)							
				end							
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].increase_regen_color[2],
			width = "half",
		},								
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("degeneration"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].decrease_regen_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].decrease_regen_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.Group.SetPreviewGroupSize(4)
				AUI.Attributes.UpdateUI()
				
				for i = 1, 4, 1 do	
					unitTag = "group" .. i	

					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)									
				end					
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].decrease_regen_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].decrease_regen_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].decrease_regen_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.Group.SetPreviewGroupSize(4)
				AUI.Attributes.UpdateUI()
				
				for i = 1, 4, 1 do	
					unitTag = "group" .. i	

					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)								
				end							
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].decrease_regen_color[2],
			width = "half",
		},
	}
	return optionTable			
end

local function GetRaidColorSettingsTable()
	local optionTable = 
	{	
		{
			type = "header",
			name = AUI.L10n.GetString("raid")
		},	
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("health"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.Group.SetPreviewGroupSize(24)
				AUI.Attributes.UpdateUI()												
			  end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].bar_color[1],
			width = "half",
		},		
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.Group.SetPreviewGroupSize(24)
				AUI.Attributes.UpdateUI()												
			  end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].bar_color[2],
			width = "half",
		},	
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("shield"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_SHIELD].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_SHIELD].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.Group.SetPreviewGroupSize(24)
				AUI.Attributes.UpdateUI()

				for i = 1, 4, 1 do	
					unitTag = "group" .. i	
					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH,  DEFAULT_PREVIEW_HP / 3, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
				end							
			  end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_SHIELD].bar_color[1],
			width = "half",
		},		
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_SHIELD].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_SHIELD].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.Group.SetPreviewGroupSize(24)
				AUI.Attributes.UpdateUI()	

				for i = 1, 4, 1 do	
					unitTag = "group" .. i	
					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH,  DEFAULT_PREVIEW_HP / 3, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
				end							
			  end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_SHIELD].bar_color[2],
			width = "half",
		},				
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("regeneration"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].increase_regen_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].increase_regen_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.Group.SetPreviewGroupSize(24)
				AUI.Attributes.UpdateUI()
							
				for i = 1, 24, 1 do	
					unitTag = "group" .. i	

					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)								
				end					
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].increase_regen_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].increase_regen_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].increase_regen_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.Group.SetPreviewGroupSize(24)
				AUI.Attributes.UpdateUI()
							
				for i = 1, 24, 1 do	
					unitTag = "group" .. i	

					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)							
				end							
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].increase_regen_color[2],
			width = "half",
		},								
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("degeneration"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].decrease_regen_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].decrease_regen_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.Group.SetPreviewGroupSize(24)
				AUI.Attributes.UpdateUI()
				
				for i = 1, 24, 1 do	
					unitTag = "group" .. i	

					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)								
				end						
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].decrease_regen_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].decrease_regen_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].decrease_regen_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.Group.SetPreviewGroupSize(24)
				AUI.Attributes.UpdateUI()
				
				for i = 1, 24, 1 do	
					unitTag = "group" .. i	

					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)															
				end							
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].decrease_regen_color[2],
			width = "half",
		},
	}
	return optionTable			
end

local function GetBossColorSettingsTable()
	local optionTable = 
	{	
		{
			type = "header",
			name = AUI.L10n.GetString("boss")
		},			
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("health"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_BOSS_UNIT_TAG)					
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].bar_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_BOSS_UNIT_TAG)					
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].bar_color[2],
			width = "half",
		},								
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("shield"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_SHIELD].bar_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_SHIELD].bar_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_BOSS_UNIT_TAG)						
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_SHIELD].bar_color[1],
			width = "half",
		},	
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_SHIELD].bar_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_SHIELD].bar_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_BOSS_UNIT_TAG)					
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_SHIELD].bar_color[2],
			width = "half",
		},					
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("regeneration"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].increase_regen_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].increase_regen_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_BOSS_UNIT_TAG)
							
				for i = 1, MAX_BOSSES, 1 do	
					unitTag = "boss" .. i	

					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)								
				end					
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].increase_regen_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].increase_regen_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].increase_regen_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_BOSS_UNIT_TAG)
							
				for i = 1, MAX_BOSSES, 1 do	
					unitTag = "boss" .. i	

					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)							
				end							
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].increase_regen_color[2],
			width = "half",
		},								
		{
			type = "colorpicker",
			name = AUI.L10n.GetString("color") .. ": " .. AUI.L10n.GetString("degeneration"),
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].decrease_regen_color[1]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].decrease_regen_color[1] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_BOSS_UNIT_TAG)
				
				for i = 1, MAX_BOSSES, 1 do	
					unitTag = "boss" .. i	

					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)								
				end						
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].decrease_regen_color[1],
			width = "half",
		},
		{
			type = "colorpicker",
			getFunc = function() return AUI.Color.GetColorDefFromNamedRGBA(AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].decrease_regen_color[2]):UnpackRGBA() end,
			setFunc = function(r,g,b,a) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].decrease_regen_color[2] = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
				AUI.Attributes.UpdateUI(AUI_BOSS_UNIT_TAG)
				
				for i = 1, MAX_BOSSES, 1 do	
					unitTag = "boss" .. i	

					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
					AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)															
				end							
			end,
			default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].decrease_regen_color[2],
			width = "half",
		},	
	}
	
	return optionTable
end

local function GetPlayerSettingsTable()
	local optionTable = 
	{	
		{
			type = "submenu",
			name = AUI_TXT_COLOR_SUBMENU:Colorize(AUI.L10n.GetString("player")),
			controls = 
			{
				{
					type = "checkbox",
					name = AUI.L10n.GetString("always_show"),
					tooltip = AUI.L10n.GetString("always_show_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()].show_player_always end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()].show_player_always = value	
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()].show_player_always,
					width = "full",
					disabled = function() 
						local templateData = AUI.Attributes.GetCurrentTemplateData()	
						return templateData.isCompact
					end,
				},															
				{
					type = "header",
					name = AUI.L10n.GetString("health"),
				},
				{
					type = "slider",
					name = AUI.L10n.GetString("width"),
					tooltip = AUI.L10n.GetString("width_tooltip"),
					min = 225,
					max = 450,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].width end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].width = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].width,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "width") end,
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("height"),
					tooltip = AUI.L10n.GetString("height_tooltip"),
					min = 16,
					max = 80,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].height end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].height = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].height,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "height") end,
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("opacity"),
					tooltip = AUI.L10n.GetString("opacity_tooltip"),
					min = 0.25,
					max = 1,
					step = 0.0625,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].opacity end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].opacity = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].opacity,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "opacity") end,
				},		
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_text"),
					tooltip = AUI.L10n.GetString("show_text_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].show_text end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].show_text = value					
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].show_text,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "show_text") end,
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_max_value"),
					tooltip = AUI.L10n.GetString("show_max_value_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].show_max_value end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].show_max_value = value	
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].show_max_value,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "show_max_value") end,
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_thousand_seperator"),
					tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].use_thousand_seperator end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].use_thousand_seperator = value
						AUI.Attributes.UpdateUI()	
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].use_thousand_seperator,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "use_thousand_seperator") end,
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = LMP:List(LMP.MediaType.FONT),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].font_art end,
					setFunc = function(value) 		
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].font_art = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].font_art,	
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "font_art") end,	
				},				
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4,
					max = 22,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].font_size end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].font_size = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].font_size,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "font_size") end,
				},					
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_regeneration_effect"),
					tooltip = AUI.L10n.GetString("show_regeneration_effect_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].show_increase_regen_color end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].show_increase_regen_color = value
	
						if value then
							AUI.Attributes.RemoveAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, false)
							AUI.Attributes.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
						else
							AUI.Attributes.RemoveAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, false)
						end							
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].show_increase_regen_color,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "show_increase_regen_color") end,	
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_degeneration_effect"),
					tooltip = AUI.L10n.GetString("show_degeneration_effect_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].show_decrease_regen_color end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].show_decrease_regen_color = value

						if value then
							AUI.Attributes.RemoveAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, false)
							AUI.Attributes.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
						else
							AUI.Attributes.RemoveAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, false)
						end									
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH].show_decrease_regen_color,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "show_decrease_regen_color") end,	
				},		
				{
					type = "header",
					name = AUI.L10n.GetString("magicka"),
				},
				{
					type = "slider",
					name = AUI.L10n.GetString("width"),
					tooltip = AUI.L10n.GetString("width_tooltip"),
					min = 225,
					max = 450,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].width end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].width = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].width,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "width") end,
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("height"),
					tooltip = AUI.L10n.GetString("height_tooltip"),
					min = 16,
					max = 80,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].height end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].height = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].height,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "height") end,
				},				
				{
					type = "slider",
					name = AUI.L10n.GetString("opacity"),
					tooltip = AUI.L10n.GetString("opacity_tooltip"),
					min = 0.25,
					max = 1,
					step = 0.0625,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].opacity end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].opacity = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].opacity,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "opacity") end,
				},			
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_text"),
					tooltip = AUI.L10n.GetString("show_text_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].show_text end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].show_text = value					
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].show_text,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "show_text") end,
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_max_value"),
					tooltip = AUI.L10n.GetString("show_max_value_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].show_max_value end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].show_max_value = value					
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].show_max_value,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "show_max_value") end,
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_thousand_seperator"),
					tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].use_thousand_seperator end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].use_thousand_seperator = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].use_thousand_seperator,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "use_thousand_seperator") end,
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = LMP:List(LMP.MediaType.FONT),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].font_art end,
					setFunc = function(value) 		
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].font_art = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].font_art,	
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "font_art") end,					
				},				
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4,
					max = 22,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].font_size end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].font_size = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA].font_size,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "font_size") end,
				},										
				{
					type = "header",
					name = AUI.L10n.GetString("stamina"),
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("width"),
					tooltip = AUI.L10n.GetString("width_tooltip"),
					min = 225,
					max = 450,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].width end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].width = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].width,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "width") end,	
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("height"),
					tooltip = AUI.L10n.GetString("height_tooltip"),
					min = 16,
					max = 80,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].height end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].height = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].height,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "height") end,
				},				
				{
					type = "slider",
					name = AUI.L10n.GetString("opacity"),
					tooltip = AUI.L10n.GetString("opacity_tooltip"),
					min = 0.25,
					max = 1,
					step = 0.0625,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].opacity end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].opacity = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].opacity,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "opacity") end,
				},		
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_text"),
					tooltip = AUI.L10n.GetString("show_text_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].show_text end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].show_text = value					
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].show_text,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "show_text") end,
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_max_value"),
					tooltip = AUI.L10n.GetString("show_max_value_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].show_max_value end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].show_max_value = value					
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].show_max_value,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "show_max_value") end,
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_thousand_seperator"),
					tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].use_thousand_seperator end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].use_thousand_seperator = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].use_thousand_seperator,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "use_thousand_seperator") end,
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = LMP:List(LMP.MediaType.FONT),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].font_art end,
					setFunc = function(value) 		
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].font_art = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].font_art,	
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "font_art") end,
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4,
					max = 22,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].font_size end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].font_size = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA].font_size,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH, "font_size") end,
				},				
				{
					type = "header",
					name = AUI.L10n.GetString("shield"),
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("width"),
					tooltip = AUI.L10n.GetString("width_tooltip"),
					min = 225,
					max = 450,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].width end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].width = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].width,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD, "width") end,
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("height"),
					tooltip = AUI.L10n.GetString("height_tooltip"),
					min = 16,
					max = 80,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].height end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].height = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].height,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD, "height") end,
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("opacity"),
					tooltip = AUI.L10n.GetString("opacity_tooltip"),
					min = 0.25,
					max = 1,
					step = 0.0625,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].opacity end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].opacity = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].opacity,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD, "opacity") end,
				},			
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_text"),
					tooltip = AUI.L10n.GetString("show_text_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].show_text end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].show_text = value					
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].show_text,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD, "show_text") end,
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_max_value"),
					tooltip = AUI.L10n.GetString("show_max_value_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].show_max_value end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].show_max_value = value					
						AUI.Attributes.UpdateUI()	
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].show_max_value,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD, "show_max_value") end,
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_thousand_seperator"),
					tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].use_thousand_seperator end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].use_thousand_seperator = value
						AUI.Attributes.UpdateUI()
						AUI.Attributes.AddAttributeVisual(AUI_PLAYER_UNIT_TAG, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH,  DEFAULT_PREVIEW_HP / 3, DEFAULT_PREVIEW_HP, false)
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].use_thousand_seperator,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD, "use_thousand_seperator") end,
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = LMP:List(LMP.MediaType.FONT),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].font_art end,
					setFunc = function(value) 		
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].font_art = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].font_art,	
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD, "font_art") end,					
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4,
					max = 22,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].font_size end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].font_size = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD].font_size,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD, "font_size") end,
				},		
				{
					type = "header",
					name = AUI.L10n.GetString("siege") .. " (" .. AUI.L10n.GetString("health") .. ")"
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("width"),
					tooltip = AUI.L10n.GetString("width_tooltip"),
					min = 225,
					max = 450,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].width end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].width = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].width,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE, "width") end,
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("height"),
					tooltip = AUI.L10n.GetString("height_tooltip"),
					min = 16,
					max = 80,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].height end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].height = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].height,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE, "height") end,
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("opacity"),
					tooltip = AUI.L10n.GetString("opacity_tooltip"),
					min = 0.25,
					max = 1,
					step = 0.0625,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].opacity end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].opacity = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].opacity,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE, "opacity") end,
				},			
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_text"),
					tooltip = AUI.L10n.GetString("show_text_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].show_text end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].show_text = value					
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].show_text,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE, "show_text") end,
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_max_value"),
					tooltip = AUI.L10n.GetString("show_max_value_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].show_max_value end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].show_max_value = value					
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].show_max_value,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE, "show_max_value") end,
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_thousand_seperator"),
					tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].use_thousand_seperator end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].use_thousand_seperator = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].use_thousand_seperator,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE, "use_thousand_seperator") end,
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = LMP:List(LMP.MediaType.FONT),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].font_art end,
					setFunc = function(value) 		
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].font_art = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].font_art,	
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE, "font_art") end,
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4,
					max = 22,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].font_size end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].font_size = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE].font_size,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE, "font_size") end,
				},		
				{
					type = "header",
					name = AUI.L10n.GetString("stamina") .. " ( " .. AUI.L10n.GetString("mount") .. " )",
				},	
					{
					type = "slider",
					name = AUI.L10n.GetString("width"),
					tooltip = AUI.L10n.GetString("width_tooltip"),
					min = 225,
					max = 450,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].width end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].width = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].width,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT, "width") end,
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("height"),
					tooltip = AUI.L10n.GetString("height_tooltip"),
					min = 16,
					max = 80,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].height end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].height = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].height,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT, "height") end,
				},				
				{
					type = "slider",
					name = AUI.L10n.GetString("opacity"),
					tooltip = AUI.L10n.GetString("opacity_tooltip"),
					min = 0.25,
					max = 1,
					step = 0.0625,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].opacity end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].opacity = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].opacity,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT, "opacity") end,
				},		
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_text"),
					tooltip = AUI.L10n.GetString("show_text_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].show_text end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].show_text = value					
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].show_text,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT, "show_text") end,
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_max_value"),
					tooltip = AUI.L10n.GetString("show_max_value_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].show_max_value end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].show_max_value = value					
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].show_max_value,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT, "show_max_value") end,
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_thousand_seperator"),
					tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].use_thousand_seperator end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].use_thousand_seperator = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].use_thousand_seperator,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT, "use_thousand_seperator") end,
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = LMP:List(LMP.MediaType.FONT),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].font_art end,
					setFunc = function(value) 		
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].font_art = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].font_art,
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT, "font_art") end,					
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4,
					max = 22,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].font_size end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].font_size = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT].font_size,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT, "font_size") end,
				},	
				{
					type = "header",
					name = AUI.L10n.GetString("werewolf"),
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("width"),
					tooltip = AUI.L10n.GetString("width_tooltip"),
					min = 225,
					max = 450,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].width end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].width = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].width,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF, "width") end,
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("height"),
					tooltip = AUI.L10n.GetString("height_tooltip"),
					min = 16,
					max = 80,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].height end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].height = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].height,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF, "height") end,
				},				
				{
					type = "slider",
					name = AUI.L10n.GetString("opacity"),
					tooltip = AUI.L10n.GetString("opacity_tooltip"),
					min = 0.25,
					max = 1,
					step = 0.0625,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].opacity end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].opacity = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].opacity,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF, "opacity") end,
				},		
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_text"),
					tooltip = AUI.L10n.GetString("show_text_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].show_text end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].show_text = value					
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].show_text,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF, "show_text") end,
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_max_value"),
					tooltip = AUI.L10n.GetString("show_max_value_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].show_max_value end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].show_max_value = value					
						AUI.Attributes.UpdateUI()	
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].show_max_value,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF, "show_max_value") end,
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_thousand_seperator"),
					tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].use_thousand_seperator end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].use_thousand_seperator = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].use_thousand_seperator,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF, "use_thousand_seperator") end,
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = LMP:List(LMP.MediaType.FONT),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].font_art end,
					setFunc = function(value) 		
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].font_art = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].font_art,
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF, "font_art") end,					
				},				
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4,
					max = 22,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].font_size end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].font_size = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF].font_size,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF, "font_size") end,
				},				
			}
		},
	}
	
	return optionTable
end

local function GetGroupSettingsTable()
	local optionTable = 
	{	
		{
			type = "submenu",
			name = AUI_TXT_COLOR_SUBMENU:Colorize(AUI.L10n.GetString("group") .. " / " .. AUI.L10n.GetString("raid")),
			controls = 
			{																
				{
					type = "header",
					name = AUI.L10n.GetString("group")
				},			
				{
					type = "slider",
					name = AUI.L10n.GetString("width"),
					tooltip = AUI.L10n.GetString("width_tooltip"),
					min = 160,
					max = 350,
					step = 2,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].width end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].width = value
						AUI.Attributes.Group.SetPreviewGroupSize(4)
						AUI.Attributes.UpdateUI()					
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].width,
					width = "half",		
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_GROUP_HEALTH, "width") end,
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("height"),
					tooltip = AUI.L10n.GetString("height_tooltip"),
					min = 16,
					max = 48,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].height end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].height = value
						AUI.Attributes.Group.SetPreviewGroupSize(4)
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].height,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_GROUP_HEALTH, "height") end,
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("distance"),
					tooltip = AUI.L10n.GetString("row_distance_tooltip"),
					min = 32,
					max = 60,
					step = 2,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].row_distance end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].row_distance = value
						AUI.Attributes.Group.SetPreviewGroupSize(4)
						AUI.Attributes.UpdateUI()							
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].row_distance,
					width = "full",	
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_GROUP_HEALTH, "row_distance") end,					
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = LMP:List(LMP.MediaType.FONT),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].font_art end,
					setFunc = function(value) 		
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].font_art = value
						AUI.Attributes.Group.SetPreviewGroupSize(4)
						AUI.Attributes.UpdateUI()								
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].font_art,
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_GROUP_HEALTH, "font_art") end,	
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4,
					max = 22,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].font_size end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].font_size = value
						AUI.Attributes.Group.SetPreviewGroupSize(4)
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].font_size,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_GROUP_HEALTH, "font_size") end,
				},		
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_account_name"),
					tooltip = AUI.L10n.GetString("show_account_name_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].show_account_name end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].show_account_name = value
						AUI.Attributes.Group.SetPreviewGroupSize(4)	
						AUI.Attributes.UpdateUI()											
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].show_account_name,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_GROUP_HEALTH, "show_account_name") end,
				},					
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_thousand_seperator"),
					tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].use_thousand_seperator end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].use_thousand_seperator = value
						AUI.Attributes.Group.SetPreviewGroupSize(4)	
						AUI.Attributes.UpdateUI()											
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].use_thousand_seperator,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_GROUP_HEALTH, "use_thousand_seperator") end,
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_regeneration_effect"),
					tooltip = AUI.L10n.GetString("show_regeneration_effect_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].show_increase_regen_color end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].show_increase_regen_color = value
						AUI.Attributes.Group.SetPreviewGroupSize(4)
						AUI.Attributes.UpdateUI()
						
						for i = 1, 4, 1 do	
							unitTag = "group" .. i					
							if value then
								AUI.Attributes.RemoveAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
								AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
							else
								AUI.Attributes.RemoveAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
							end		
						end
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].show_increase_regen_color,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_GROUP_HEALTH, "show_increase_regen_color") end,
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_degeneration_effect"),
					tooltip = AUI.L10n.GetString("show_degeneration_effect_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].show_decrease_regen_color end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].show_decrease_regen_color = value
						AUI.Attributes.Group.SetPreviewGroupSize(4)
						AUI.Attributes.UpdateUI()
					
						for i = 1, 4, 1 do	
							unitTag = "group" .. i					
							if value then
								AUI.Attributes.RemoveAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
								AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
							else
								AUI.Attributes.RemoveAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
							end	
						end
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].show_decrease_regen_color,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_GROUP_HEALTH, "show_decrease_regen_color") end,
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("opacity"),
					tooltip = AUI.L10n.GetString("opacity_tooltip"),
					min = 0.25,
					max = 1,
					step = 0.0625,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].opacity end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].opacity = value
						AUI.Attributes.Group.SetPreviewGroupSize(4)
						AUI.Attributes.UpdateUI()						
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].opacity,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_GROUP_HEALTH, "opacity") end,					
				},				
				{
					type = "slider",
					name = AUI.L10n.GetString("unit_out_of_range_opacity"),
					tooltip = AUI.L10n.GetString("unit_out_of_range_opacity_tooltip"),
					min = 0.25,
					max = 1,
					step = 0.0625,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].out_of_range_opacity end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].out_of_range_opacity = value
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_SHIELD].out_of_range_opacity = value
						AUI.Attributes.Group.SetPreviewGroupSize(4)	
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_GROUP_HEALTH].out_of_range_opacity,
					width = "half",	
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_GROUP_HEALTH, "out_of_range_opacity") end,					
				},					
				{
					type = "header",
					name = AUI.L10n.GetString("raid")
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("width"),
					tooltip = AUI.L10n.GetString("width_tooltip"),
					min = 100,
					max = 350,
					step = 2,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].width end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].width = value
						AUI.Attributes.Group.SetPreviewGroupSize(24)
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].width,
					width = "half",	
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_RAID_HEALTH, "width") end,					
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("height"),
					tooltip = AUI.L10n.GetString("height_tooltip"),
					min = 32,
					max = 48,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].height end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].height = value
						AUI.Attributes.Group.SetPreviewGroupSize(24)
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].height,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_RAID_HEALTH, "height") end,
				},						
				{
					type = "slider",
					name = AUI.L10n.GetString("column_distance"),
					tooltip = AUI.L10n.GetString("column_distance_tooltip"),
					min = 2,
					max = 24,
					step = 2,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].column_distance end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].column_distance = value
						AUI.Attributes.Group.SetPreviewGroupSize(24)
						AUI.Attributes.UpdateUI()							
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].column_distance,
					width = "half",	
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_RAID_HEALTH, "column_distance") end,					
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("row_distance"),
					tooltip = AUI.L10n.GetString("row_distance_tooltip"),
					min = 2,
					max = 24,
					step = 2,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].row_distance end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].row_distance = value
						AUI.Attributes.Group.SetPreviewGroupSize(24)
						AUI.Attributes.UpdateUI()					
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].row_distance,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_RAID_HEALTH, "row_distance") end,					
				},
				{
					type = "slider",
					name = AUI.L10n.GetString("row_count"),
					tooltip = AUI.L10n.GetString("row_count_tooltip"),
					min = 4,
					max = 12,
					step = 2,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].row_count end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].row_count = value
						AUI.Attributes.Group.SetPreviewGroupSize(24)
						AUI.Attributes.UpdateUI()						
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].row_count,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_RAID_HEALTH, "row_count") end,	
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = LMP:List(LMP.MediaType.FONT),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].font_art end,
					setFunc = function(value) 		
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].font_art = value
						AUI.Attributes.Group.SetPreviewGroupSize(24)
						AUI.Attributes.UpdateUI()								
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].font_art,
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_RAID_HEALTH, "font_art") end,					
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4,
					max = 22,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].font_size end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].font_size = value
						AUI.Attributes.Group.SetPreviewGroupSize(24)
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].font_size,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_RAID_HEALTH, "font_size") end,
				},		
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_account_name"),
					tooltip = AUI.L10n.GetString("show_account_name_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].show_account_name end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].show_account_name = value
						AUI.Attributes.Group.SetPreviewGroupSize(24)
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].show_account_name,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_RAID_HEALTH, "show_account_name") end,	
				},				
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_thousand_seperator"),
					tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].use_thousand_seperator end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].use_thousand_seperator = value
						AUI.Attributes.Group.SetPreviewGroupSize(24)
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].use_thousand_seperator,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_RAID_HEALTH, "use_thousand_seperator") end,	
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_regeneration_effect"),
					tooltip = AUI.L10n.GetString("show_regeneration_effect_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].show_increase_regen_color end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].show_increase_regen_color = value
						AUI.Attributes.Group.SetPreviewGroupSize(24)
						AUI.Attributes.UpdateUI()
		
						for i = 1, 24, 1 do	
							unitTag = "group" .. i					
							if value then
								AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, false)
								AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
							else
								AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, false)
							end
						end
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].show_increase_regen_color,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_RAID_HEALTH, "show_increase_regen_color") end,
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_degeneration_effect"),
					tooltip = AUI.L10n.GetString("show_degeneration_effect_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].show_decrease_regen_color end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].show_decrease_regen_color = value
						AUI.Attributes.Group.SetPreviewGroupSize(24)
						AUI.Attributes.UpdateUI()
						
						for i = 1, 24, 1 do	
							unitTag = "group" .. i					
							if value then
								AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, false)
								AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, -DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
							else
								AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, false)
							end
						end
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].show_decrease_regen_color,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_RAID_HEALTH, "show_decrease_regen_color") end,
				},
				{
					type = "slider",
					name = AUI.L10n.GetString("opacity"),
					tooltip = AUI.L10n.GetString("opacity_tooltip"),
					min = 0.25,
					max = 1,
					step = 0.0625,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].opacity end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].opacity = value
						AUI.Attributes.Group.SetPreviewGroupSize(24)
						AUI.Attributes.UpdateUI()						
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].opacity,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_RAID_HEALTH, "opacity") end,					
				},				
				{
					type = "slider",
					name = AUI.L10n.GetString("unit_out_of_range_opacity"),
					tooltip = AUI.L10n.GetString("unit_out_of_range_opacity_tooltip"),
					min = 0.25,
					max = 1,
					step = 0.0625,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].out_of_range_opacity end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].out_of_range_opacity = value
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_SHIELD].out_of_range_opacity = value
						AUI.Attributes.Group.SetPreviewGroupSize(24)	
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_RAID_HEALTH].out_of_range_opacity,
					width = "half",	
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_RAID_HEALTH, "out_of_range_opacity") end,							
				},					
			}
		},
	}

	return optionTable
end

local function GetBossSettingsTable()
	local optionTable = 
	{	
		{
			type = "submenu",
			name = AUI_TXT_COLOR_SUBMENU:Colorize(AUI.L10n.GetString("boss")),
			controls = 
			{																
				{
					type = "header",
					name = AUI.L10n.GetString("aui")
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show"),
					tooltip = AUI.L10n.GetString("show_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].display end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].display = value
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_SHIELD].display = value
						AUI.Attributes.UpdateUI()

						if value then
							AUI.Attributes.ShowFrame(AUI_ATTRIBUTE_TYPE_BOSS_HEALTH)
							AUI.Attributes.ShowFrame(AUI_ATTRIBUTE_TYPE_BOSS_SHIELD)
						else
							AUI.Attributes.HideFrame(AUI_ATTRIBUTE_TYPE_BOSS_HEALTH)
							AUI.Attributes.HideFrame(AUI_ATTRIBUTE_TYPE_BOSS_SHIELD)							
						end
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].display,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_BOSS_HEALTH, "display") end,
				},			
				{
					type = "slider",
					name = AUI.L10n.GetString("width"),
					tooltip = AUI.L10n.GetString("width_tooltip"),
					min = 160,
					max = 350,
					step = 2,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].width end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].width = value
						AUI.Attributes.UpdateUI()					
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].width,
					width = "half",		
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_BOSS_HEALTH, "width") end,
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("height"),
					tooltip = AUI.L10n.GetString("height_tooltip"),
					min = 16,
					max = 48,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].height end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].height = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].height,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_BOSS_HEALTH, "height") end,
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("column_distance"),
					tooltip = AUI.L10n.GetString("column_distance_tooltip"),
					min = 2,
					max = 24,
					step = 2,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].column_distance end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].column_distance = value
						AUI.Attributes.UpdateUI()							
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].column_distance,
					width = "half",	
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_BOSS_HEALTH, "column_distance") end,					
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("row_distance"),
					tooltip = AUI.L10n.GetString("row_distance_tooltip"),
					min = 2,
					max = 24,
					step = 2,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].row_distance end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].row_distance = value
						AUI.Attributes.UpdateUI()					
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].row_distance,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_BOSS_HEALTH, "row_distance") end,					
				},
				{
					type = "slider",
					name = AUI.L10n.GetString("row_count"),
					tooltip = AUI.L10n.GetString("row_count_tooltip"),
					min = 2,
					max = 6,
					step = 2,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].row_count end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].row_count = value
						AUI.Attributes.UpdateUI()						
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].row_count,
					width = "half",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_BOSS_HEALTH, "row_count") end,	
				},	
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = LMP:List(LMP.MediaType.FONT),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].font_art end,
					setFunc = function(value) 		
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].font_art = value
						AUI.Attributes.UpdateUI()								
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].font_art,
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_BOSS_HEALTH, "font_art") end,	
				},
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4,
					max = 22,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].font_size end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].font_size = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].font_size,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_BOSS_HEALTH, "font_size") end,
				},									
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_thousand_seperator"),
					tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].use_thousand_seperator end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].use_thousand_seperator = value
						AUI.Attributes.UpdateUI()											
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].use_thousand_seperator,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_BOSS_HEALTH, "use_thousand_seperator") end,
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_regeneration_effect"),
					tooltip = AUI.L10n.GetString("show_regeneration_effect_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].show_increase_regen_color end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].show_increase_regen_color = value
						AUI.Attributes.UpdateUI()
						
						for i = 1, MAX_BOSSES, 1 do	
							unitTag = "boss" .. i					
							if value then
								AUI.Attributes.RemoveAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
								AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
							else
								AUI.Attributes.RemoveAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
							end		
						end
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].show_increase_regen_color,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_BOSS_HEALTH, "show_increase_regen_color") end,
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_degeneration_effect"),
					tooltip = AUI.L10n.GetString("show_degeneration_effect_tooltip"),
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].show_decrease_regen_color end,
					setFunc = function(value)
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].show_decrease_regen_color = value
						AUI.Attributes.UpdateUI()
					
						for i = 1, MAX_BOSSES, 1 do	
							unitTag = "boss" .. i					
							if value then
								AUI.Attributes.RemoveAttributeVisual(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
								AUI.Attributes.AddAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
							else
								AUI.Attributes.RemoveAttributeVisual(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, nil, false)
							end	
						end
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].show_decrease_regen_color,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_BOSS_HEALTH, "show_decrease_regen_color") end,
				},	
				{
					type = "slider",
					name = AUI.L10n.GetString("opacity"),
					tooltip = AUI.L10n.GetString("opacity_tooltip"),
					min = 0.25,
					max = 1,
					step = 0.0625,
					getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].opacity end,
					setFunc = function(value) 
						AUI.Settings.Attributes[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].opacity = value
						AUI.Attributes.UpdateUI()						
					end,
					default = defaultSettings[GetCurrentTemplateName()][AUI_ATTRIBUTE_TYPE_BOSS_HEALTH].opacity,
					width = "full",
					disabled = function() return IsSettingDisabled(AUI_ATTRIBUTE_TYPE_BOSS_HEALTH, "opacity") end,					
				},								
				{
					type = "header",
					name = AUI.L10n.GetString("default")
				},		
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_text"),
					tooltip = AUI.L10n.GetString("show_text_tooltip"),
					getFunc = function() return AUI.Settings.Attributes.boss_show_text end,
					setFunc = function(value)
						AUI.Settings.Attributes.boss_show_text = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings.boss_show_text,
					width = "full",
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("show_thousand_seperator"),
					tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
					getFunc = function() return AUI.Settings.Attributes.boss_use_thousand_seperator end,
					setFunc = function(value)
						AUI.Settings.Attributes.boss_use_thousand_seperator = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings.boss_use_thousand_seperator,
					width = "full",
				},					
				{
					type = "slider",
					name = AUI.L10n.GetString("font_size"),
					tooltip = AUI.L10n.GetString("font_size_tooltip"),
					min = 4 ,
					max = 22 ,
					step = 1,
					getFunc = function() return AUI.Settings.Attributes.boss_font_size end,
					setFunc = function(value) 
						AUI.Settings.Attributes.boss_font_size = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings.boss_font_size,
					width = "full",
				},
				{
					type = "dropdown",
					name = AUI.L10n.GetString("font_art"),
					tooltip = AUI.L10n.GetString("font_art_tooltip"),
					choices = LMP:List(LMP.MediaType.FONT),
					getFunc = function() return AUI.Settings.Attributes.boss_font_art end,
					setFunc = function(value) 		
						AUI.Settings.Attributes.boss_font_art = value
						AUI.Attributes.UpdateUI()
					end,
					default = defaultSettings.boss_font_art,		
				},				
			}			
		},
	}

	return optionTable
end

local function GetTargetSettingTable(_attributeId, _subMenuName)
	local optionTable = 
	{
		{
		type = "submenu",
		name = AUI_TXT_COLOR_SUBMENU:Colorize(_subMenuName)
		},
	}
	
	local display = 
	{
		type = "checkbox",
		name = AUI.L10n.GetString("show"),
		tooltip = AUI.L10n.GetString("show_tooltip"),
		getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][_attributeId].display end,
		setFunc = function(value) 
			AUI.Settings.Attributes[GetCurrentTemplateName()][_attributeId].display = value
			AUI.Attributes.HideFrame(_attributeId)
			AUI.Attributes.UpdateUI()
		end,
		default = defaultSettings[GetCurrentTemplateName()][_attributeId].display,
		width = "full",
		disabled = function() return IsSettingDisabled(_attributeId, "display") end,
	}	

	optionTable[1].controls = 
	{
		display,
		{
			type = "slider",
			name = AUI.L10n.GetString("width"),
			tooltip = AUI.L10n.GetString("width_tooltip"),
			min = 225,
			max = 400,
			step = 1,
			getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][_attributeId].width end,
			setFunc = function(value) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][_attributeId].width = value
				AUI.Attributes.UpdateUI()
			end,
			default = defaultSettings[GetCurrentTemplateName()][_attributeId].width,
			width = "half",
			disabled = function() return IsSettingDisabled(_attributeId, "width") end,
		},	
		{
			type = "slider",
			name = AUI.L10n.GetString("height"),
			tooltip = AUI.L10n.GetString("height_tooltip"),
			min = 16,
			max = 80,
			step = 1,
			getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][_attributeId].height end,
			setFunc = function(value) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][_attributeId].height = value
				AUI.Attributes.UpdateUI()
			end,
			default = defaultSettings[GetCurrentTemplateName()][_attributeId].height,
			width = "half",
			disabled = function() return IsSettingDisabled(_attributeId, "height") end,
		},					
		{
			type = "slider",
			name = AUI.L10n.GetString("opacity"),
			tooltip = AUI.L10n.GetString("opacity_tooltip"),
			min = 0.25,
			max = 1,
			step = 0.0625,
			getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][_attributeId].opacity end,
			setFunc = function(value) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][_attributeId].opacity = value
				AUI.Attributes.UpdateUI()
			end,
			default = defaultSettings[GetCurrentTemplateName()][_attributeId].opacity,
			width = "full",
			disabled = function() return IsSettingDisabled(_attributeId, "opacity") end,
		},				
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_account_name"),
			tooltip = AUI.L10n.GetString("show_account_name_tooltip"),
			getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][_attributeId].show_account_name end,
			setFunc = function(value)
				AUI.Settings.Attributes[GetCurrentTemplateName()][_attributeId].show_account_name = value
				AUI.Attributes.UpdateUI()
			end,
			default = defaultSettings[GetCurrentTemplateName()][_attributeId].show_account_name,
			width = "full",
			disabled = function() return IsSettingDisabled(_attributeId, "show_account_name") end,
		},					
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_text"),
			tooltip = AUI.L10n.GetString("show_text_tooltip"),
			getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][_attributeId].show_text end,
			setFunc = function(value)
				AUI.Settings.Attributes[GetCurrentTemplateName()][_attributeId].show_text = value
				AUI.Attributes.UpdateUI()
			end,
			default = defaultSettings[GetCurrentTemplateName()][_attributeId].show_text,
			width = "full",
			disabled = function() return IsSettingDisabled(_attributeId, "show_text") end,
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_max_value"),
			tooltip = AUI.L10n.GetString("show_max_value_tooltip"),
			getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][_attributeId].show_max_value end,
			setFunc = function(value)
				AUI.Settings.Attributes[GetCurrentTemplateName()][_attributeId].show_max_value = value					
				AUI.Attributes.UpdateUI()
			end,
			default = defaultSettings[GetCurrentTemplateName()][_attributeId].show_max_value,
			width = "full",
			disabled = function() return IsSettingDisabled(_attributeId, "show_max_value") end,
		},					
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_thousand_seperator"),
			tooltip = AUI.L10n.GetString("show_thousand_seperator_tooltip"),
			getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][_attributeId].use_thousand_seperator end,
			setFunc = function(value)
				AUI.Settings.Attributes[GetCurrentTemplateName()][_attributeId].use_thousand_seperator = value
				AUI.Attributes.UpdateUI()
			end,
			default = defaultSettings[GetCurrentTemplateName()][_attributeId].use_thousand_seperator,
			width = "full",
			disabled = function() return IsSettingDisabled(_attributeId, "use_thousand_seperator") end,
		},							
		{
			type = "slider",
			name = AUI.L10n.GetString("font_size"),
			tooltip = AUI.L10n.GetString("font_size_tooltip"),
			min = 4 ,
			max = 22 ,
			step = 1,
			getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][_attributeId].font_size end,
			setFunc = function(value) 
				AUI.Settings.Attributes[GetCurrentTemplateName()][_attributeId].font_size = value
				AUI.Attributes.UpdateUI()
			end,
			default = defaultSettings[GetCurrentTemplateName()][_attributeId].font_size,
			width = "full",
			disabled = function() return IsSettingDisabled(_attributeId, "font_size") end,
		},
		{
			type = "dropdown",
			name = AUI.L10n.GetString("font_art"),
			tooltip = AUI.L10n.GetString("font_art_tooltip"),
			choices = LMP:List(LMP.MediaType.FONT),
			getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][_attributeId].font_art end,
			setFunc = function(value) 		
				AUI.Settings.Attributes[GetCurrentTemplateName()][_attributeId].font_art = value
				AUI.Attributes.UpdateUI()
			end,
			default = defaultSettings[GetCurrentTemplateName()][_attributeId].font_art,
			disabled = function() return IsSettingDisabled(_attributeId, "font_art") end,					
		},			
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_regeneration_effect"),
			tooltip = AUI.L10n.GetString("show_regeneration_effect_tooltip"),
			getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][_attributeId].show_increase_regen_color end,
			setFunc = function(value)
				AUI.Settings.Attributes[GetCurrentTemplateName()][_attributeId].show_increase_regen_color = value
				AUI.Attributes.UpdateUI()
				if value then
					AUI.Attributes.RemoveAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, false)
					AUI.Attributes.AddAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, 100, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
				else
					AUI.Attributes.RemoveAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, false)
				end										
			end,
			default = defaultSettings[GetCurrentTemplateName()][_attributeId].show_increase_regen_color,
			width = "full",
			disabled = function() return IsSettingDisabled(_attributeId, "show_increase_regen_color") end,
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("show_degeneration_effect"),
			tooltip = AUI.L10n.GetString("show_degeneration_effect_tooltip"),
			getFunc = function() return AUI.Settings.Attributes[GetCurrentTemplateName()][_attributeId].show_decrease_regen_color end,
			setFunc = function(value)
				AUI.Settings.Attributes[GetCurrentTemplateName()][_attributeId].show_decrease_regen_color = value
				AUI.Attributes.UpdateUI()
				if value then
					AUI.Attributes.RemoveAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, false)
					AUI.Attributes.AddAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, -150, DEFAULT_PREVIEW_HP, DEFAULT_PREVIEW_HP, false)
				else
					AUI.Attributes.RemoveAttributeVisual(AUI_TARGET_UNIT_TAG, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, POWERTYPE_HEALTH, nil, nil, false)
				end		
			end,
			default = defaultSettings[GetCurrentTemplateName()][_attributeId].show_decrease_regen_color,
			width = "full",
			disabled = function() return IsSettingDisabled(_attributeId, "show_decrease_regen_color") end,
		},
	}

	return optionTable
end

local function CreateOptionTable()
	local optionsTable = 
	{	
		{
			type = "header",
			name = AUI_TXT_COLOR_HEADER:Colorize(AUI.L10n.GetString("general"))
		},	
		{
			type = "checkbox",
			name = AUI.L10n.GetString("acount_wide"),
			tooltip = AUI.L10n.GetString("acount_wide_tooltip"),
			getFunc = function() return AUI.MainSettings.modul_attributes_account_wide end,
			setFunc = function(value)
				AUI.MainSettings.modul_attributes_account_wide = value
				ReloadUI()
			end,
			default = true,
			width = "full",
			warning = AUI.L10n.GetString("reloadui_warning_tooltip"),
		},		
		{
			type = "checkbox",
			name = AUI.L10n.GetString("preview"),
			tooltip = AUI.L10n.GetString("preview_tooltip"),
			getFunc = function() return isPreviewShowing end,
			setFunc = function(value)					
				if value == true then	
					AUI.Attributes.ShowPreview()	
				else
					AUI.Attributes.HidePreview()
				end	
				
				isPreviewShowing = value
			end,
			default = isPreviewShowing,
			width = "full",
			warning = AUI.L10n.GetString("preview_warning"),	
		},
		{
			type = "checkbox",
			name = AUI.L10n.GetString("lock_window"),
			tooltip = AUI.L10n.GetString("lock_window_tooltip"),
			getFunc = function() return AUI.Settings.Attributes.lock_windows end,
			setFunc = function(value)
				AUI.Settings.Attributes.lock_windows = value
			end,
			default = defaultSettings.lock_windows,
			width = "full",
		},	
		{
			type = "dropdown",
			name = AUI.L10n.GetString("template"),
			tooltip = AUI.L10n.GetString("template_tooltip"),
			choices = AUI.Table.GetChoiceList(AUI.Attributes.GetTemplateNames(), "value"),
			getFunc = function() 					
				return AUI.Table.GetValue(AUI.Attributes.GetTemplateNames(), GetCurrentTemplateName())						
			end,
			setFunc = function(value) 
				value = AUI.Table.GetKey(AUI.Attributes.GetTemplateNames(), value)
				if GetCurrentTemplateName() ~= value then
					AUI.Settings.Template.Attributes = value
					ReloadUI()
				end
			end,
			warning = AUI.L10n.GetString("reloadui_warning_tooltip"),
		},		
		{		
			type = "submenu",
			name = AUI_TXT_COLOR_SUBMENU:Colorize(AUI.L10n.GetString("display_elements")),
			controls = 
			{					
				{
					type = "checkbox",
					name = AUI.L10n.GetString("activate_player_attributes"),
					getFunc = function() return player_attributes_enabled end,
					setFunc = function(value)
						player_attributes_enabled = value
						changed = true
					end,
					default = defaultSettings.player_attributes_enabled,
					width = "full",
					warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
				},		
				{
					type = "checkbox",
					name = AUI.L10n.GetString("activate_target_attributes"),
					getFunc = function() return target_attributes_enabled end,
					setFunc = function(value)
						target_attributes_enabled = value
						changed = true
					end,
					default = defaultSettings.target_attributes_enabled,
					width = "full",
					warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
				},
				{
					type = "checkbox",
					name = AUI.L10n.GetString("activate_group_attributes"),
					getFunc = function() return group_attributes_enabled end,
					setFunc = function(value)
						group_attributes_enabled = value
						changed = true
					end,
					default = defaultSettings.group_attributes_enabled,
					width = "full",
					warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
				},	
				{
					type = "checkbox",
					name = AUI.L10n.GetString("activate_boss_attributes"),
					getFunc = function() return boss_attributes_enabled end,
					setFunc = function(value)
						boss_attributes_enabled = value
						changed = true
					end,
					default = defaultSettings.boss_attributes_enabled,
					width = "full",
					warning = AUI.L10n.GetString("reloadui_manual_warning_tooltip"),
				},				
				{
					type = "button",
					name = AUI.L10n.GetString("accept_settings"),
					tooltip = AUI.L10n.GetString("accept_settings_tooltip"),
					func = function() AcceptSettings() end,
					disabled = function() return not changed end,
				},		
			}
		},			
	}
	
	local optionTableList = {}
	
	local optionsColorTable = 
	{			
		type = "submenu",
		name = AUI_TXT_COLOR_SUBMENU:Colorize(AUI.L10n.GetString("colors")),
		controls = {}
	}	
	
	for i = 1 , #optionsTable do 
		table.insert(optionTableList, optionsTable[i]) 
	end			
	
	if player_attributes_enabled then
		local playerColorOptionTable = GetPlayerColorSettingsTable()
		for i = 1 , #playerColorOptionTable do 
			table.insert(optionsColorTable.controls, playerColorOptionTable[i]) 
		end		
	end	
	
	if target_attributes_enabled and DoesAttributeIdExists(AUI_ATTRIBUTE_TYPE_PRIMARY_TARGET_HEALTH) then
		local submenuName = AUI.L10n.GetString("target")
		if DoesAttributeIdExists(AUI_ATTRIBUTE_TYPE_SECUNDARY_TARGET_HEALTH) then
			submenuName = submenuName .. " (" .. AUI.L10n.GetString("primary") .. ")"
		end	
	
		local targetColorOptionTable = GetTargetColorSettingsTable(AUI_ATTRIBUTE_TYPE_PRIMARY_TARGET_HEALTH, submenuName)
		for i = 1 , #targetColorOptionTable do 
			table.insert(optionsColorTable.controls, targetColorOptionTable[i]) 
		end		
	end	
	
	if target_attributes_enabled and DoesAttributeIdExists(AUI_ATTRIBUTE_TYPE_SECUNDARY_TARGET_HEALTH) then
		local submenuName = AUI.L10n.GetString("target")
		if DoesAttributeIdExists(AUI_ATTRIBUTE_TYPE_PRIMARY_TARGET_HEALTH) then
			submenuName = submenuName .. " (" .. AUI.L10n.GetString("secundary") .. ")"
		end	
	
		local targetColorOptionTable = GetTargetColorSettingsTable(AUI_ATTRIBUTE_TYPE_SECUNDARY_TARGET_HEALTH, AUI.L10n.GetString("target") .. " " .. AUI.L10n.GetString("secundary") .. ")")
		for i = 1 , #targetColorOptionTable do 
			table.insert(optionsColorTable.controls, targetColorOptionTable[i] ) 
		end	
	end	
	
	if group_attributes_enabled then
		local groupColorOptionTable = GetGroupColorSettingsTable()
		for i = 1 , #groupColorOptionTable do 
			table.insert(optionsColorTable.controls, groupColorOptionTable[i]) 
		end		
	end	
	
	if group_attributes_enabled then
		local raidColorOptionTable = GetRaidColorSettingsTable()
		for i = 1 , #raidColorOptionTable do 
			table.insert(optionsColorTable.controls, raidColorOptionTable[i]) 
		end		
	end

	if boss_attributes_enabled then
		local bossColorOptionTable = GetBossColorSettingsTable()
		for i = 1 , #bossColorOptionTable do 
			table.insert(optionsColorTable.controls, bossColorOptionTable[i]) 
		end		
	end		
	
	for _, data in pairs({optionsColorTable}) do	
		table.insert(optionTableList, data) 	
	end

	if player_attributes_enabled then
		local playerOptionTable = GetPlayerSettingsTable()
		for i = 1 , #playerOptionTable do 
			table.insert(optionTableList, playerOptionTable[i]) 
		end		
	end
	
	if group_attributes_enabled then
		local groupOptionTable = GetGroupSettingsTable()
		for i = 1 , #groupOptionTable do 
			table.insert(optionTableList, groupOptionTable[i]) 
		end		
	end
	
	if target_attributes_enabled and DoesAttributeIdExists(AUI_ATTRIBUTE_TYPE_PRIMARY_TARGET_HEALTH) then
		local submenuName = AUI.L10n.GetString("target")
		if DoesAttributeIdExists(AUI_ATTRIBUTE_TYPE_SECUNDARY_TARGET_HEALTH) then
			submenuName = submenuName .. " (" .. AUI.L10n.GetString("primary") .. ")"
		end
	
		local targetPrimaryOptionTable = GetTargetSettingTable(AUI_ATTRIBUTE_TYPE_PRIMARY_TARGET_HEALTH, submenuName)
		for i = 1 , #targetPrimaryOptionTable do 
			table.insert(optionTableList, targetPrimaryOptionTable[i] ) 
		end		
	end
	
	if target_attributes_enabled and DoesAttributeIdExists(AUI_ATTRIBUTE_TYPE_SECUNDARY_TARGET_HEALTH) then
		local submenuName = AUI.L10n.GetString("target")
		if DoesAttributeIdExists(AUI_ATTRIBUTE_TYPE_PRIMARY_TARGET_HEALTH) then
			submenuName = submenuName .. " (" .. AUI.L10n.GetString("secundary") .. ")"
		end	
	
		local targetSecundaryOptionTable = GetTargetSettingTable(AUI_ATTRIBUTE_TYPE_SECUNDARY_TARGET_HEALTH, AUI.L10n.GetString("target") .. " (" .. AUI.L10n.GetString("secundary") .. ")")
		for i = 1 , #targetSecundaryOptionTable do 
			table.insert(optionTableList, targetSecundaryOptionTable[i] ) 
		end	
	end
	
	if boss_attributes_enabled then
		local bossOptionTable = GetBossSettingsTable()
		for i = 1 , #bossOptionTable do 
			table.insert(optionTableList, bossOptionTable[i] ) 
		end		
	end
	
	local footerOptions = 
	{
		{
			type = "header",
		},		
		{
			type = "button",
			name = AUI.L10n.GetString("reset_to_default_position"),
			tooltip = AUI.L10n.GetString("reset_to_default_position_tooltip"),
			func = function() AUI.Attributes.SetToDefaultPosition() end,
		},		
	}	
	
	for i = 1 , #footerOptions do 
		table.insert(optionTableList , footerOptions[i] ) 
	end		
	
	LAM:RegisterOptionControls("AUI_Menu_Attributes", optionTableList)
end

local function LoadSettings()
	if AUI.MainSettings.modul_attributes_account_wide then
		AUI.Settings.Attributes = ZO_SavedVars:NewAccountWide("AUI_Attributes", 5, nil, defaultSettings)
	else
		AUI.Settings.Attributes = ZO_SavedVars:New("AUI_Attributes", 5, nil, defaultSettings)
	end		
	
	player_attributes_enabled = AUI.Settings.Attributes.player_attributes_enabled
	target_attributes_enabled = AUI.Settings.Attributes.target_attributes_enabled
	group_attributes_enabled = AUI.Settings.Attributes.group_attributes_enabled	
	boss_attributes_enabled = AUI.Settings.Attributes.boss_attributes_enabled
end

function AUI.Attributes.GetDefaultSettings()
	return defaultSettings
end

function AUI.Attributes.SetMenuData()
	if isLoaded then
		return
	end

	local panelData = 
	{
		type = "panel",
		name = AUI_MAIN_NAME .. " (" .. AUI.L10n.GetString("attributes_module_name") .. ")",
		displayName = "|cFFFFB0" .. AUI_MAIN_NAME .. " (" .. AUI.L10n.GetString("attributes_module_name") .. ")",
		author = AUI_TXT_COLOR_AUTHOR:Colorize(AUI_ATTRIBUTE_AUTHOR),
		version = AUI_TXT_COLOR_VERSION:Colorize(AUI_ATTRIBUTE_VERSION),
		slashCommand = "/auiattributes",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	LoadSettings()
	CreateOptionTable()
	
	panel = LAM:RegisterAddonPanel("AUI_Menu_Attributes", panelData)
	
	isLoaded = true
end
