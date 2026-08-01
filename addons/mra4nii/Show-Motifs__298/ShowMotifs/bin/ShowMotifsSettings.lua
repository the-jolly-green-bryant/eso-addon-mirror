local ShowMotifs = _G['ShowMotifs']
local L = ShowMotifs:GetLanguage()

-- here we will keep our settings and will make a menu to change them
ShowMotifs.ShowMotifsSettings = ZO_Object:Subclass()

local LAM = LibAddonMenu2
local settings = nil
local version = "1.1.7"

-- list of available themes
local TEXTURE_OPTIONS = { "Default \(Phinix\)", "Materials" }

-- function to initialize our settings object
function ShowMotifs.ShowMotifsSettings:New()
	local obj = ZO_Object.New(self)
	obj:Initialize()
	return obj
end

-- default settings if none found
function ShowMotifs.ShowMotifsSettings:Initialize()
	local defaults = {
		smToggle = true,
		showTooltips = true,
		MotifTextureSize = 24,
		ArmorTextureSize = 24,
		textureName = "Default \(Phinix\)",
		position = 418,
		gssposition = 418,
		gslposition = 484,
		IsMotifIcon = true,
		IsArmorIcon = false,
		IsArmorLetter = false,
		ColorIcon = true,
	}

	settings = ZO_SavedVars:NewAccountWide("ShowMotifs_Settings", 5, nil, defaults)

    self:CreateOptionsMenu()
end

-- function to check if module is activated
function ShowMotifs.ShowMotifsSettings:IsActivated()
	return settings.smToggle

end

-- function to check if tooltips are enabled
function ShowMotifs.ShowMotifsSettings:ShowTooltips()
	return settings.showTooltips
end

-- function to check if racial motifs icons are enabled
function ShowMotifs.ShowMotifsSettings:IsMotifIconEnabled()
	return settings.IsMotifIcon
end

-- function to check if armor type icons are enabled
function ShowMotifs.ShowMotifsSettings:IsArmorIconEnabled()
	return settings.IsArmorIcon
end

-- function checks if we have necessary dates for racial motif <<MotifID>>
function ShowMotifs.ShowMotifsSettings:GetMotif(MotifID)
	if ( ShowMotifs.STYLES_TEXTURES[settings.textureName][MotifID] and ShowMotifs.STYLES_TEXTURES[settings.textureName][MotifID].texture ) then
		return true
	else
		return false
	end
end

-- function returns path to icon texture for racial motif <<MotifID>>
function ShowMotifs.ShowMotifsSettings:GetMotifTexture(MotifID)
	return ShowMotifs.STYLES_TEXTURES[settings.textureName][MotifID].texture
end

-- function returns path to icon texture for armor type <<TextureTypeID>>
function ShowMotifs.ShowMotifsSettings:GetArmorTexture(TextureTypeID)
	if ( settings.IsArmorLetter ) then
		return ShowMotifs.ARMOR_TEXTURES[settings.textureName][TextureTypeID].letter
	end
	
	return ShowMotifs.ARMOR_TEXTURES[settings.textureName][TextureTypeID].texture
end

-- function returns name of armor type based on in-game strings
function ShowMotifs.ShowMotifsSettings:GetArmorName(TextureTypeID)
	if ( self:GetLang() == "fr" ) then
		return GetString(SI_ITEM_FORMAT_STR_ARMOR) .. " " .. GetString(_G['SI_ARMORTYPE' .. TextureTypeID])
	end

	return GetString(_G['SI_ARMORTYPE' .. TextureTypeID]) .. " " .. GetString(SI_ITEM_FORMAT_STR_ARMOR)
end

-- function returns name of racial motif based on in-game strings
function ShowMotifs.ShowMotifsSettings:GetMotifName(MotifID)
	if MotifID == 0 then
		return ShowMotifs.Names[MotifID]
	else
		local mText = zo_strformat("<<t:1>>", GetItemStyleName(MotifID))
		if mText ~= "" then
			return mText
		else
			mText = (ShowMotifs.Names[MotifID] ~= nil) and ShowMotifs.Names[MotifID] or "Unknown"
			return mText
		end
	end
end

function ShowMotifs.ShowMotifsSettings:GetMotifTextureSize()
	return settings.MotifTextureSize
end

-- function returns icon size for armor type icon
function ShowMotifs.ShowMotifsSettings:GetArmorTextureSize()
	return settings.ArmorTextureSize
end

-- function returns icon size for racial motif icon
function ShowMotifs.ShowMotifsSettings:GetIconPosition(list)
	if list == 1 then
		return settings.position
	elseif list == 2 then
		return settings.gssposition
	elseif list == 3 then
		return settings.gslposition
	end
end

-- function to check if we should use quality colors for icons
function ShowMotifs.ShowMotifsSettings:GetIconColor()
	return settings.ColorIcon
end

-- function to check client locale
function ShowMotifs.ShowMotifsSettings:GetLang()
	local lang = GetCVar("language.2")
	if ( lang == "de" or lang == "en" or lang == "fr" ) then
		return lang
	end
	return "en"
end

-- function to create settings menu. It uses LibAddonMenu v2
function ShowMotifs.ShowMotifsSettings:CreateOptionsMenu()
--	initialize main panel for our settings
	local lampanel = {
		type = "panel",
		name = "Show Motifs",
		author = "mra4nii & Phinix",
		version = version,
		slashCommand = "/showmotifs",
		registerForRefresh = true,
		registerForDefaults = true,
	}

--	show an icon, so we can see how theme looks
	local icon = WINDOW_MANAGER:CreateControl("ShowMotifsSettingsPanel_Icon", ZO_OptionsWindowSettingsScrollChild, CT_TEXTURE)
	icon:SetColor(255, 255, 255, 1)
	icon:SetHandler("OnShow", function()
--			icon:SetTexture(ShowMotifs.STYLES_TEXTURES[settings.textureName][ITEMSTYLE_RACIAL_HIGH_ELF].texture)
--			icon:SetDimensions(settings.MotifTextureSize, settings.MotifTextureSize)
	end)

--	populate our settings menu
	local lamoptions = {
		[1] = {
			type = "header",
			name = L.GENERAL,
		},
--	dropdown menu to select themes		
		[2] = {
			type = "dropdown",
			name = L.ICON_THEME,
			tooltip = L.ICON_THEME_TOOLTIP,
			choices = TEXTURE_OPTIONS,
			getFunc = function() return settings.textureName end,
			setFunc = function(value)
						settings.textureName = value
						icon:SetTexture(ShowMotifs.STYLES_TEXTURES[settings.textureName][ITEMSTYLE_RACIAL_HIGH_ELF].texture)
						if ( settings.textureName == "Materials" ) then settings.ColorIcon = false end
						ZO_ScrollList_RefreshVisible(ZO_PlayerInventoryBackpack)
					end,
			reference = "ShowMotifsSettingsPanel_Icon_Dropdown",
			default = TEXTURE_OPTIONS[1],
		},
--	racial motif size
		[3] = {
			type = "slider",
			name = L.ICON_SIZE,
			tooltip = L.ICON_SIZE_TOOLTIP,
			min = 16,
			max = 64,
			step = 4,
			getFunc = function() return settings.MotifTextureSize end,
			setFunc = function( value )
				settings.MotifTextureSize = value
				icon:SetDimensions(settings.MotifTextureSize, settings.MotifTextureSize)
				ZO_ScrollList_RefreshVisible(ZO_PlayerInventoryBackpack)
			end,
			default = 32,
		},
--	armor type size
		[4] = {
			type = "slider",
			name = L.ARMOR_ICON_SIZE,
			tooltip = L.ARMOR_ICON_SIZE_TOOLTIP,
			min = 16,
			max = 64,
			step = 4,
			getFunc = function() return settings.ArmorTextureSize end,
			setFunc = function( value )
				settings.ArmorTextureSize = value
				ZO_ScrollList_RefreshVisible(ZO_PlayerInventoryBackpack)
			end,
			default = 32
		},
-- inventory icon position
		[5] = {
			type = "slider",
			name = L.II_POSITION,
			tooltip = L.II_POSITION_TOOLTIP,
			min = 0,
			max = 800,
			step = 1,
			getFunc = function() return settings.position end,
			setFunc = function( value )
				settings.position = value
				ZO_ScrollList_RefreshVisible(ZO_PlayerInventoryBackpack)
			end,
			default = 0,
		},
-- guild store search icon position
		[6] = {
			type = "slider",
			name = L.GSS_POSITION,
			tooltip = L.GSS_POSITION_TOOLTIP,
			min = 0,
			max = 800,
			step = 1,
			getFunc = function() return settings.gssposition end,
			setFunc = function( value )
				settings.gssposition = value
			--	ZO_ScrollList_RefreshVisible(ZO_TradingHouseItemPaneSearchResults)
			end,
			default = 0,
		},
-- guild store listing icon position
		[7] = {
			type = "slider",
			name = L.GSL_POSITION,
			tooltip = L.GSL_POSITION_TOOLTIP,
			min = 0,
			max = 800,
			step = 1,
			getFunc = function() return settings.gslposition end,
			setFunc = function( value )
				settings.gslposition = value
				ZO_ScrollList_RefreshVisible(ZO_TradingHousePostedItemsList)
			end,
			default = 0,
		},
--	show racial motifs icon
		[8] = {
			type = "checkbox",
			name = L.RACIAL,
			tooltip = L.RACIAL_TOOLTIP,
			getFunc = function() return settings.IsMotifIcon end,
			setFunc = function(value)
						settings.IsMotifIcon = value
						ZO_ScrollList_RefreshVisible(ZO_PlayerInventoryBackpack)
			end,
			default = true,
		},
--	show armor type icon
		[9] = {
			type = "checkbox",
			name = L.ARMOR,
			tooltip = L.ARMOR_TOOLTIP,
			getFunc = function() return settings.IsArmorIcon end,
			setFunc = function(value)
						settings.IsArmorIcon = value
						ZO_ScrollList_RefreshVisible(ZO_PlayerInventoryBackpack)
			end,
			default = true,
		},
--	show letters
		[10] = {
			type = "checkbox",
			name = L.LETTER,
			tooltip = L.LETTER_TOOLTIP,
			getFunc = function() return settings.IsArmorLetter end,
			setFunc = function(value)
						settings.IsArmorLetter = value
						ZO_ScrollList_RefreshVisible(ZO_PlayerInventoryBackpack)
			end,
			default = false,
		},
--	use quality colors
		[11] = {
			type = "checkbox",
			name = L.COLOR,
			tooltip = L.COLOR_TOOLTIP,
			getFunc = function() return settings.ColorIcon end,
			setFunc = function(value)
						settings.ColorIcon = value
						ZO_ScrollList_RefreshVisible(ZO_PlayerInventoryBackpack)
			end,
			default = true,
		},
--	show tooltips
		[12] = {
			type = "checkbox",
			name = L.TOOLTIP,
			tooltip = L.TOOLTIP_TOOLTIP,
			getFunc = function() return settings.showTooltips end,
			setFunc = function(value)
						settings.showTooltips = value
						ZO_ScrollList_RefreshVisible(ZO_PlayerInventoryBackpack)
			end,
			default = false,
		},
	}
	
--	register our settings menu and its options
	LAM:RegisterAddonPanel("ShowMotifsSettingsPanel", lampanel)
	LAM:RegisterOptionControls("ShowMotifsSettingsPanel", lamoptions)

--	anchor our theme example icon
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated",
		function()
			icon:SetParent(ShowMotifsSettingsPanel_Icon_Dropdown)
			icon:SetTexture(ShowMotifs.STYLES_TEXTURES[settings.textureName][ITEMSTYLE_RACIAL_HIGH_ELF].texture)
			icon:SetDimensions(settings.MotifTextureSize, settings.MotifTextureSize)
			icon:SetAnchor(CENTER, ShowMotifsSettingsPanel_Icon_Dropdown, CENTER, 18, 0)
		end)	

end
