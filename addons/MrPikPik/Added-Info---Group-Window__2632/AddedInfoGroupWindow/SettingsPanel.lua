AIGW = AIGW or {}
local AIGW = AIGW

-- Creates the addon settings menu
function AIGW.InitializeAddonMenu()
    local markSelfIcon

	local panelData = {
		type = "panel",
		name = "Added Info - Group Window",
		displayName = "Added Info - Group Window (AIGW)",
		author = "MrPikPik",
		version = AIGW.version,
		website = 'https://www.esoui.com/downloads/info2632-AddedInfo-GroupWindow.html#donate',
		donation = function()
			SCENE_MANAGER:Show('mailSend')
			zo_callLater(function() 
				ZO_MailSendToField:SetText("@MrPikPik")
				ZO_MailSendSubjectField:SetText("Thank you for making addons!")
				ZO_MailSendBodyField:SetText("I like using your addon 'Added Info - Group Window'")
				ZO_MailSendBodyField:TakeFocus()
			end, 250)
		end,
		registerForRefresh = true,
		registerForDefaults = true
	}

	
	local optionsData = {}

    
    -- Description
	table.insert(optionsData, {
		type = "description",
		text = GetString(AIGW_OPTIONS_DESCRIPTION),
	})
    
    -- Options header
	table.insert(optionsData, {
		type = "header",
		name = GetString(AIGW_OPTIONS_HEADER),
	})
    
    -- Account wide setting
	table.insert(optionsData, {
		type = "checkbox",
		name = GetString(AIGW_OPTIONS_ACCOUNTWIDE_SETTINGS),
		tooltip = GetString(AIGW_OPTIONS_ON) .. GetString(AIGW_OPTIONS_ACCOUNTWIDE_SETTINGS_TT_ON) .. "\n" .. GetString(AIGW_OPTIONS_OFF) .. GetString(AIGW_OPTIONS_ACCOUNTWIDE_SETTINGS_TT_OFF),
		requiresReload = true,
		default = AIGW.accountWideDefaults.accountWide,
		getFunc = function() return AIGW.DS.accountWide end,
		setFunc = function(newValue) AIGW.DS.accountWide = newValue end,
	}) 

    -- Options header
	table.insert(optionsData, {
		type = "header",
		name = GetString(AIGW_DISPLAY_HEADER),
	})
    
    -- Wider Group Window
    table.insert(optionsData, {
		type = "checkbox",
		name = GetString(AIGW_OPTIONS_WIDE_MENU),
		tooltip = GetString(AIGW_OPTIONS_ON) .. GetString(AIGW_OPTIONS_WIDE_MENU_TT_ON) .. "\n" .. GetString(AIGW_OPTIONS_OFF) .. GetString(AIGW_OPTIONS_WIDE_MENU_TT_OFF),
		default = AIGW.defaults.wideMenu,
        requiresReload = true,
		getFunc = function() return AIGW.SV.wideMenu end,
		setFunc = function(newValue)
            AIGW.SV.wideMenu = newValue
            if newValue == false and AIGW.SV.displayMode == 3 then
                AIGW.SV.displayMode = 1
            end
        end,
	})
    
    -- Divider
    table.insert(optionsData, {
		type = "divider",
	})
    
    -- Display Type (Character name, account name, both)
	table.insert(optionsData, {
		type = "dropdown",
		name = GetString(AIGW_OPTIONS_DISPLAY_TYPE),
		tooltip = GetString(AIGW_OPTIONS_DISPLAY_TYPE_TT),
		choices = (function()
			local opts = {}
			table.insert(opts, GetString(AIGW_OPTIONS_DISPLAY_CHARACTER_NAME))
			table.insert(opts, GetString(AIGW_OPTIONS_DISPLAY_ACCOUNT_NAME))
			if AIGW.SV.wideMenu then
				table.insert(opts, GetString(AIGW_OPTIONS_DISPLAY_BOTH))
			end
			return opts
		end)(),
		getFunc = function() 
			if AIGW.SV.displayMode == 1 then 
				return GetString(AIGW_OPTIONS_DISPLAY_CHARACTER_NAME)
			elseif AIGW.SV.displayMode == 2 then
				return GetString(AIGW_OPTIONS_DISPLAY_ACCOUNT_NAME)				
			elseif AIGW.SV.displayMode == 3 then
				if AIGW.SV.wideMenu then
					return GetString(AIGW_OPTIONS_DISPLAY_BOTH)
				else
					return GetString(AIGW_OPTIONS_DISPLAY_CHARACTER_NAME)
				end
			end
		end,
		setFunc = function(newValue)
			if newValue == GetString(AIGW_OPTIONS_DISPLAY_CHARACTER_NAME) then 
				AIGW.SV.displayMode = 1
			elseif newValue == GetString(AIGW_OPTIONS_DISPLAY_ACCOUNT_NAME) then
				AIGW.SV.displayMode = 2
			elseif newValue == GetString(AIGW_OPTIONS_DISPLAY_BOTH) then
				AIGW.SV.displayMode = 3
			end
			AIGW.UpdateHeaderWidths()
		end,
		default = AIGW.defaults.displayMode,
	})
  
    -- Tooltip Mode (Character name, account name, both)
	table.insert(optionsData, {
		type = "dropdown",
		name = GetString(AIGW_OPTIONS_TOOLTIP_TYPE),
		tooltip = GetString(AIGW_OPTIONS_TOOLTIP_TYPE_TT),
		choices = {
            GetString(AIGW_OPTIONS_DISPLAY_CHARACTER_NAME),
            GetString(AIGW_OPTIONS_DISPLAY_ACCOUNT_NAME),
            GetString(AIGW_OPTIONS_DISPLAY_BOTH)
        },
		getFunc = function() 
			if AIGW.SV.tooltipMode == 1 then 
				return GetString(AIGW_OPTIONS_DISPLAY_CHARACTER_NAME)
			elseif AIGW.SV.tooltipMode == 2 then
				return GetString(AIGW_OPTIONS_DISPLAY_ACCOUNT_NAME)				
			elseif AIGW.SV.tooltipMode == 3 then
				return GetString(AIGW_OPTIONS_DISPLAY_BOTH)
			end
		end,
		setFunc = function(newValue)
			if newValue == GetString(AIGW_OPTIONS_DISPLAY_CHARACTER_NAME) then 
				AIGW.SV.tooltipMode = 1
			elseif newValue == GetString(AIGW_OPTIONS_DISPLAY_ACCOUNT_NAME) then
				AIGW.SV.tooltipMode = 2
			elseif newValue == GetString(AIGW_OPTIONS_DISPLAY_BOTH) then
				AIGW.SV.tooltipMode = 3
			end
		end,
		default = AIGW.defaults.tooltipMode,
	})
    
    -- Tooltip Info (Race, class, both)
	table.insert(optionsData, {
		type = "dropdown",
		name = GetString(AIGW_OPTIONS_TOOLTIP_INFO),
		tooltip = GetString(AIGW_OPTIONS_TOOLTIP_INFO_TT),
		choices = {
            GetString(AIGW_OPTIONS_TOOLTIP_INFO_NONE),
            GetString(AIGW_OPTIONS_TOOLTIP_INFO_CLASS),
            GetString(AIGW_OPTIONS_TOOLTIP_INFO_RACE),
            GetString(AIGW_OPTIONS_TOOLTIP_INFO_BOTH)
        },
		getFunc = function() 
			if AIGW.SV.tooltipInfo == 1 then 
				return GetString(AIGW_OPTIONS_TOOLTIP_INFO_NONE)
			elseif AIGW.SV.tooltipInfo == 2 then
				return GetString(AIGW_OPTIONS_TOOLTIP_INFO_CLASS)				
			elseif AIGW.SV.tooltipInfo == 3 then
				return GetString(AIGW_OPTIONS_TOOLTIP_INFO_RACE)
            elseif AIGW.SV.tooltipInfo == 4 then
				return GetString(AIGW_OPTIONS_TOOLTIP_INFO_BOTH)
			end
		end,
		setFunc = function(newValue)
			if newValue == GetString(AIGW_OPTIONS_TOOLTIP_INFO_NONE) then 
				AIGW.SV.tooltipInfo = 1
			elseif newValue == GetString(AIGW_OPTIONS_TOOLTIP_INFO_CLASS) then
				AIGW.SV.tooltipInfo = 2
			elseif newValue == GetString(AIGW_OPTIONS_TOOLTIP_INFO_RACE) then
				AIGW.SV.tooltipInfo = 3
            elseif newValue == GetString(AIGW_OPTIONS_TOOLTIP_INFO_BOTH) then
				AIGW.SV.tooltipInfo = 4
			end
		end,
		default = AIGW.defaults.tooltipInfo,
	})
    
    -- Show Alliance option
    table.insert(optionsData, {
		type = "checkbox",
		name = GetString(AIGW_OPTIONS_SHOW_ALLIANCE),
		tooltip = GetString(AIGW_OPTIONS_SHOW_ALLIANCE_TT),
		default = AIGW.defaults.showAlliance,
		getFunc = function() return AIGW.SV.showAlliance end,
		setFunc = function(newValue)
            AIGW.SV.showAlliance = newValue
        end,
	})
    
    -- Show Title option
    table.insert(optionsData, {
		type = "checkbox",
		name = GetString(AIGW_OPTIONS_SHOW_TITLE),
		tooltip = GetString(AIGW_OPTIONS_SHOW_TITLE_TT),
		default = AIGW.defaults.showTitle,
		getFunc = function() return AIGW.SV.showTitle end,
		setFunc = function(newValue)
            AIGW.SV.showTitle = newValue
        end,
	})
    
    -- Show Gender option
    table.insert(optionsData, {
		type = "checkbox",
		name = GetString(AIGW_OPTIONS_SHOW_GENDER),
		tooltip = GetString(AIGW_OPTIONS_SHOW_GENDER_TT),
		default = AIGW.defaults.showGender,
		getFunc = function() return AIGW.SV.showGender end,
		setFunc = function(newValue)
            AIGW.SV.showGender = newValue
            AIGW.UpdateGroupList()
        end,
	})
    
    -- Show AvA Rank option
    table.insert(optionsData, {
		type = "checkbox",
		name = GetString(AIGW_OPTIONS_SHOW_LVLTOOLTIP),
		tooltip = GetString(AIGW_OPTIONS_SHOW_LVLTOOLTIP_TT),
		default = AIGW.defaults.showAvARank,
		getFunc = function() return AIGW.SV.showAvARank end,
		setFunc = function(newValue)
            AIGW.SV.showAvARank = newValue
            AIGW.UpdateGroupList()
        end,
	})
    
    -- Options header
	table.insert(optionsData, {
		type = "header",
		name = GetString(AIGW_HIGHLIGHTING_HEADER),
	})
    
    -- Player highlighting option
	table.insert(optionsData, {
		type = "checkbox",
		name = GetString(AIGW_OPTIONS_HIGHLIGHT),
		tooltip = GetString(AIGW_OPTIONS_ON) .. GetString(AIGW_OPTIONS_HIGHLIGHT_TT_ON) .. "\n" .. GetString(AIGW_OPTIONS_OFF) .. GetString(AIGW_OPTIONS_HIGHLIGHT_TT_OFF),
		default = AIGW.defaults.markSelf,
		getFunc = function() return AIGW.SV.markSelf end,
		setFunc = function(newValue) AIGW.SV.markSelf = newValue end,
	})
    
    -- Player highlighting icon selector
    table.insert(optionsData, {
		type = "dropdown",
		name = GetString(AIGW_OPTIONS_HIGHLIGHT_ICON),
		tooltip = GetString(AIGW_OPTIONS_HIGHLIGHT_ICON_TT),
		choices = (function()
            local names = {}
            for k in pairs(AIGW.markSelfTextureNames) do table.insert(names, k) end
            return names
        end)(),
		getFunc = function() 
			return AIGW.SV.markSelfTextureName
		end,
		setFunc = function(newValue)
			AIGW.SV.markSelfTextureName = newValue
            markSelfIcon:SetTexture(AIGW.markSelfTextureNames[AIGW.SV.markSelfTextureName])
		end,
        disabled = function()
			return not AIGW.SV.markSelf
		end,
        reference = "AIGW_SelfIcon",
		default = AIGW.defaults.markSelfTextureName,
	})
    
    -- Highlight tanks and healers
	table.insert(optionsData, {
		type = "checkbox",
		name = GetString(AIGW_OPTIONS_HIGHLIGHT_HEAL_AND_TANK),
		tooltip = GetString(AIGW_OPTIONS_ON) .. GetString(AIGW_OPTIONS_HIGHLIGHT_HEAL_AND_TANK_TT_ON) .. "\n" .. GetString(AIGW_OPTIONS_OFF) .. GetString(AIGW_OPTIONS_HIGHLIGHT_HEAL_AND_TANK_TT_OFF),
		default = AIGW.defaults.markTankAndHeal,
		getFunc = function() return AIGW.SV.markTankAndHeal end,
		setFunc = function(newValue) AIGW.SV.markTankAndHeal = newValue end,
	})
    
    -- Highlight dead players
	table.insert(optionsData, {
		type = "checkbox",
		name = GetString(AIGW_OPTIONS_HIGHLIGHT_DEAD),
		tooltip = GetString(AIGW_OPTIONS_ON) .. GetString(AIGW_OPTIONS_HIGHLIGHT_DEAD_TT_ON) .. "\n" .. GetString(AIGW_OPTIONS_OFF) .. GetString(AIGW_OPTIONS_HIGHLIGHT_DEAD_TT_OFF),
		default = AIGW.defaults.markDead,
		getFunc = function() return AIGW.SV.markDead end,
		setFunc = function(newValue) AIGW.SV.markDead = newValue end,
	})
    
    -- Highlight dead players color
	table.insert(optionsData, {
		type = "colorpicker",
		name = GetString(AIGW_OPTIONS_HIGHLIGHT_DEAD_COLOR),
		default = AIGW.defaults.markDeadColor,
        disabled = function() return not AIGW.SV.markDead end,
		getFunc = function() return unpack(AIGW.SV.markDeadColor) end,
		setFunc = function(r, g, b) 
            --d({r, g, b, 1.00})
            AIGW.SV.markDeadColor = {r, g, b, 1.00} 
        end,
	})
    
    -- Other header
	table.insert(optionsData, {
		type = "header",
		name = GetString(AIGW_OTHER_HEADER),
	})
    
    -- Short roles option
    table.insert(optionsData, {
		type = "checkbox",
		name = GetString(AIGW_OPTIONS_ROLES),
		tooltip = GetString(AIGW_OPTIONS_ON) .. GetString(AIGW_OPTIONS_ROLES_TT_ON) .. "\n" .. GetString(AIGW_OPTIONS_OFF) .. GetString(AIGW_OPTIONS_ROLES_TT_OFF),
		default = AIGW.defaults.shortenRole,
		getFunc = function() return AIGW.SV.shortenRole end,
		setFunc = function(newValue)
            AIGW.SV.shortenRole = newValue
        end,
	})
    
    -- Show avg CP option
    table.insert(optionsData, {
		type = "checkbox",
		name = GetString(AIGW_OPTIONS_SHOW_AVGCP),
		tooltip = GetString(AIGW_OPTIONS_SHOW_AVGCP_TT),
		default = AIGW.defaults.showAvgGroupCP,
		getFunc = function() return AIGW.SV.showAvgGroupCP end,
		setFunc = function(newValue)
            AIGW.SV.showAvgGroupCP = newValue
            AIGW.ModifyAvgCP(0, "", 0, "", nil, false)
        end,
	})
	
	-- Show Companion Checkbox
    table.insert(optionsData, {
		type = "checkbox",
		name = GetString(AIGW_OPTIONS_SHOW_COMPANIONS),
		tooltip = GetString(AIGW_OPTIONS_SHOW_COMPANIONS_TT),
		default = AIGW.defaults.enableCompanionDisplay,
		getFunc = function() return AIGW.SV.enableCompanionDisplay end,
		setFunc = function(newValue)
            AIGW.SV.enableCompanionDisplay = newValue
            AIGW.companionToggle:SetHidden(not newValue)
        end,
	})
	
	
	
	
	
	
    
	--local count = 1
	local optionsPanel = LibAddonMenu2:RegisterAddonPanel(AIGW.name, panelData)
	LibAddonMenu2:RegisterOptionControls(AIGW.name, optionsData)
    
    
    -- Register icon for highlight player icon selector
    local SetupAIGWIcons = function(control)
    if control ~= optionsPanel then return end
        if not markSelfIcon then
            markSelfIcon = WINDOW_MANAGER:CreateControl(nil, AIGW_SelfIcon, CT_TEXTURE)
            markSelfIcon:SetAnchor(RIGHT, AIGW_SelfIcon.dropdown:GetControl(), LEFT, -10, 0)
            markSelfIcon:SetTexture(AIGW.markSelfTextureNames[AIGW.SV.markSelfTextureName])
            markSelfIcon:SetDimensions(32, 32)
        end
        CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", SetupAIGWIcons)
    end
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", SetupAIGWIcons)
end