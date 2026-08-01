--Initial LAM Settings support and code cleanup by Baertram

PetHealth = PetHealth or {}

local function updateExcludedZonesForHide()
    --local settings = PetHealth.savedVars
    --if not settings then return end

    local excludedZonesForHide = PetHealth.excludedZonesForHide
    for _, data in ipairs(PetHealth.GetSavedVars().excludedZonesForHide) do
        excludedZonesForHide[data.value] = true
    end
    PetHealth.excludedZonesForHide = excludedZonesForHide
end
PetHealth.updateExcludedZonesForHide = updateExcludedZonesForHide

function PetHealth.buildAddonMenu()
   -- local settings = PetHealth.GetSavedVars()
	local LAM = LibAddonMenu2
    if not LAM or not  PetHealth.GetSavedVars() then return false end

    local defaults = PetHealth.savedVarsDefault
    local addonVars = PetHealth.addonData

    local panelData = {
        type 				= 'panel',
        name 				= addonVars.name,
        displayName 		= addonVars.lamDisplayName,
        author 				= addonVars.lamAuthor,
        version 			= tostring(addonVars.version),
        registerForRefresh 	= true,
        registerForDefaults = true,
        slashCommand        = "/pethealthsettings",
        website             = addonVars.lamUrl
    }

    local savedVariablesOptions = {
        [1] = GetString(SI_PET_HEALTH_EACH_CHAR),
        [2] = GetString(SI_PET_HEALTH_ACCOUNT_WIDE),
    }
	
	local PetHealthWindowInMenu = false
	local scene
	local maxX, maxY = GuiRoot:GetDimensions()
	maxX = math.floor(maxX)
	maxY = math.floor(maxY)
	--adds it
	local function addPetHealthWindow()
		if PetHealthWindowInMenu then return end
		scene = SCENE_MANAGER:GetCurrentScene()					
		scene:AddFragment(PetHealth.PET_BAR_FRAGMENT)
		PetHealth.PET_BAR_FRAGMENT:Refresh()	
		PetHealthWindowInMenu = true	
	end
	--removes it
	local function addonSelected(_, addonSettings)
		if PetHealthWindowInMenu then	
			scene:RemoveFragment(PetHealth.PET_BAR_FRAGMENT)
			PetHealth.PET_BAR_FRAGMENT:Refresh()
			PetHealthWindowInMenu = false
		end
	end
	
	--CALLBACK_MANAGER:RegisterCallback("LAM-RefreshPanel", addonSelected)	
    --Register the LAM panel and add it to the global PetHealth table
    LAM_SettingsPanel = LAM:RegisterAddonPanel(addonVars.name .. "_LAM", panelData)
    --Create the options table for the LAM controls
    local optionsTable =
    {	-- BEGIN OF OPTIONS TABLE

        {
            type = 'description',
            text = GetString(SI_PET_HEALTH_DESC),
        },
       {
            type = 'dropdown',
            name = GetString(SI_PET_HEALTH_SAVE_TYPE),
            tooltip = GetString(SI_PET_HEALTH_SAVE_TYPE_TT),
            choices = savedVariablesOptions,
            getFunc = function() return savedVariablesOptions[PetHealth.saveMode] end,
			setFunc = function(value)
				if savedVariablesOptions[PetHealth.saveMode] == value then return end
                for i,v in pairs(savedVariablesOptions) do
                    if v == value then
						PetHealth.saveMode = i
						PetHealth.saveTypeChanged()	
						PetHealth.MovePetWindow()
						break
					end
                end
            end,
        },
	
        --==============================================================================
        {
            type = 'header',
            name = GetString(SI_PET_HEALTH_LAM_HEADER_VISUAL),
        },
		{
            type = "checkbox",
            name = "Show Pet Window Here",
            getFunc = function() return PetHealthWindowInMenu end,
            setFunc = function(value) 	
				if PetHealthWindowInMenu == value then return end
				if not PetHealthWindowInMenu then
					addPetHealthWindow()
				else
					addonSelected()
				end			
            end,
            width="full",
			default = false,
        },
		{
            type = "slider",
            name = "Left <- -> Right",
            tooltip = "move it left or right",
            getFunc = function() return PetHealth.GetSavedVars().x end,
            setFunc = function(value) 
				PetHealth.GetSavedVars().x = value
               PetHealth.MovePetWindow()
            end,
            min = 0,
            max = maxX,
            step = 5,
            clampInput = true,
            decimals = 0,
            autoSelect = false,
            inputLocation = "right",
            width = "full",
            default = defaults.x,
        },
		{
            type = "slider",
            name = "Up <- -> Down",
            tooltip = "move it up or down",
            getFunc = function() return PetHealth.GetSavedVars().y end,
            setFunc = function(value) 
				PetHealth.GetSavedVars().y = value
				PetHealth.MovePetWindow()
            end,
            min = 0,
            max = maxY,
            step = 5,
            clampInput = true,
            decimals = 0,
            autoSelect = false,
            inputLocation = "right",
            width = "full",
            default = defaults.y,
        },
		{
            type = "checkbox",
            name = GetString(SI_PET_HEALTH_LAM_LOCK_WINDOW),
            tooltip = GetString(SI_PET_HEALTH_LAM_LOCK_WINDOW_TT),
            getFunc = function() return PetHealth.GetSavedVars().lockWindow end,
            setFunc = function(value) PetHealth.GetSavedVars().lockWindow = value
                PetHealth.lockPetWindow(value)
            end,
            default = defaults.lockWindow,
            width="full",
            requiresReload = true,
        },
        {
            type = "checkbox",
            name = GetString(SI_PET_HEALTH_LAM_LABELS),
            tooltip = GetString(SI_PET_HEALTH_LAM_LABELS_TT),
            getFunc = function() return PetHealth.GetSavedVars().showLabels end,
            setFunc = function(value) PetHealth.GetSavedVars().showLabels = value
                PetHealth.changeLabels(value)
            end,
            default = defaults.showLabels,
            width="full",
        },
        {
            type = "checkbox",
            name = GetString(SI_PET_HEALTH_LAM_VALUES),
            tooltip = GetString(SI_PET_HEALTH_LAM_VALUES_TT),
            getFunc = function() return PetHealth.GetSavedVars().showValues end,
            setFunc = function(value) PetHealth.GetSavedVars().showValues = value
                PetHealth.changeValues(value)
            end,
            default = defaults.showValues,
            width="full",
        },
        {
            type = "checkbox",
            name = GetString(SI_PET_HEALTH_LAM_UNSUMMONED_ALERT),
            tooltip = GetString(SI_PET_HEALTH_LAM_UNSUMMONED_ALERT_TT),
            getFunc = function() return PetHealth.GetSavedVars().petUnsummonedAlerts end,
            setFunc = function(value) PetHealth.GetSavedVars().petUnsummonedAlerts = value
                PetHealth.unsummonedAlerts(value)
            end,
            default = defaults.petUnsummonedAlerts,
            width="full",
        },
        {
            type = "checkbox",
            name = GetString(SI_PET_HEALTH_LAM_USE_ZOS_STYLE),
            tooltip = GetString(SI_PET_HEALTH_LAM_USE_ZOS_STYLE_TT),
            getFunc = function() return PetHealth.GetSavedVars().useZosStyle end,
            setFunc = function(value) 
				PetHealth.GetSavedVars().useZosStyle = value
				if value then 
					PetHealth.changeBackground(false)
				else
					PetHealth.changeBackground(PetHealth.GetSavedVars().showBackground)
				end
				PetHealth.frameStyleChanged()
            end,
			default = defaults.useZosStyle,
            width = "full",
        },
		       {
            type = "checkbox",
            name = GetString(SI_PET_HEALTH_LAM_BACKGROUND),
            tooltip = GetString(SI_PET_HEALTH_LAM_BACKGROUND_TT),
            getFunc = function() return PetHealth.GetSavedVars().showBackground end,
            setFunc = function(value) PetHealth.GetSavedVars().showBackground = value
                PetHealth.changeBackground(value)
            end,
            default = defaults.showBackground,
            disabled = function() return PetHealth.GetSavedVars().useZosStyle end,
            width="full",
        },
        {
            type = "slider",
            name = GetString(SI_PET_HEALTH_LAM_LOW_HEALTH_WARN),
            tooltip = GetString(SI_PET_HEALTH_LAM_LOW_HEALTH_WARN_TT),
            getFunc = function() return PetHealth.GetSavedVars().lowHealthAlertSlider end,
            setFunc = function(value) PetHealth.GetSavedVars().lowHealthAlertSlider = value
                PetHealth.lowHealthAlertPercentage(value)
            end,
            min = 0,
            max = 99,
            step = 1,
            clampInput = true,
            decimals = 0,
            autoSelect = false,
            inputLocation = "right",
            width = "full",
            default = defaults.lowHealthAlertSlider,
        },
        {
            type = "slider",
            name = GetString(SI_PET_HEALTH_LAM_LOW_SHIELD_WARN),
            tooltip = GetString(SI_PET_HEALTH_LAM_LOW_SHIELD_WARN_TT),
            getFunc = function() return PetHealth.GetSavedVars().lowShieldAlertSlider end,
            setFunc = function(value) PetHealth.GetSavedVars().lowShieldAlertSlider = value
                PetHealth.lowShieldAlertPercentage(value)
            end,
            min = 0,
            max = 99,
            step = 1,
            clampInput = true,
            decimals = 0,
            autoSelect = false,
            inputLocation = "right",
            width = "full",
            default = defaults.lowShieldAlertSlider,
        },
		{
			type = "colorpicker",
			name = "low Health Alert Color",
			tooltip = function() return zo_strformat("|c"..PetHealth.GetSavedVars().lowHealthAlertColor.."<<1>> <<2>>|r", "PET NAME", GetString(SI_PET_HEALTH_LOW_HEALTH_WARNING_MSG)) end,
			getFunc = function() return ZO_ColorDef:New(PetHealth.GetSavedVars().lowHealthAlertColor):UnpackRGBA() end,
			setFunc = function(r, g, b, a) PetHealth.GetSavedVars().lowHealthAlertColor = ZO_ColorDef:New(r, g, b):ToHex() end,
			default = function() local db={} db.r, db.g, db.b, db.a =ZO_ColorDef:New(defaults.lowHealthAlertColor):UnpackRGBA() return db end,
		},
		{
			type = "colorpicker",
			name = "low Shield Alert Color",
			tooltip = function() return zo_strformat("|c"..PetHealth.GetSavedVars().lowShieldAlertColor.."<<1>>\'s <<2>>|r", "PET NAME", GetString(SI_PET_HEALTH_LOW_SHIELD_WARNING_MSG)) end,
			getFunc = function() return ZO_ColorDef:New(PetHealth.GetSavedVars().lowShieldAlertColor):UnpackRGBA() end,
			setFunc = function(r, g, b, a) PetHealth.GetSavedVars().lowShieldAlertColor = ZO_ColorDef:New(r, g, b):ToHex() end,
			default = function() local db={} db.r, db.g, db.b, db.a =ZO_ColorDef:New(defaults.lowShieldAlertColor):UnpackRGBA() return db end,
		},		
        {
            type = "checkbox",
            name = GetString(SI_PET_HEALTH_LAM_COMPANION),
            tooltip = GetString(SI_PET_HEALTH_LAM_COMPANION_TT),
            getFunc = function() return PetHealth.GetSavedVars().showCompanion end,
            setFunc = function(value) PetHealth.GetSavedVars().showCompanion = value
                PetHealth.changeCompanion(value)
            end,
            default = defaults.showCompanion,
            width="full",
        },
        --==============================================================================
        {
            type = 'header',
            name = GetString(SI_PET_HEALTH_LAM_HEADER_BEHAVIOR),
        },
        {
            type = "checkbox",
            name = GetString(SI_PET_HEALTH_LAM_HIDE_IN_DUNGEON),
            tooltip = GetString(SI_PET_HEALTH_LAM_HIDE_IN_DUNGEON_TT),
            getFunc = function() return PetHealth.GetSavedVars().hideInDungeon end,
            setFunc = function(value) PetHealth.GetSavedVars().hideInDungeon = value
                PetHealth.hideInDungeon(value)
            end,
            default = defaults.hideInDungeon,
            width="full",
        },
        {
            type = "checkbox",
            name = GetString(SI_PET_HEALTH_LAM_ONLY_IN_COMBAT),
            tooltip = GetString(SI_PET_HEALTH_LAM_ONLY_IN_COMBAT_TT),
            getFunc = function() return PetHealth.GetSavedVars().onlyInCombat end,
            setFunc = function(value) PetHealth.GetSavedVars().onlyInCombat = value
                PetHealth.changeCombatState()
            end,
            default = defaults.onlyInCombat,
            width="full",
        },
        {
            type = "slider",
            name = GetString(SI_PET_HEALTH_LAM_ONLY_IN_COMBAT_HEALTH),
            tooltip = GetString(SI_PET_HEALTH_LAM_ONLY_IN_COMBAT_HEALTH_TT),
            getFunc = function() return PetHealth.GetSavedVars().onlyInCombatHealthSlider end,
            setFunc = function(value) PetHealth.GetSavedVars().onlyInCombatHealthSlider = value
                PetHealth.onlyInCombatHealthPercentage(value)
            end,
            min = 0,
            max = 99,
            step = 1,
            clampInput = true,
            decimals = 0,
            autoSelect = false,
            inputLocation = "right",
            width = "full",
            default = defaults.onlyInCombatHealthSlider,
			disabled = function() return not PetHealth.GetSavedVars().onlyInCombat end, 
        },   
    } -- optionsTable
    -- Optional suport for LibAddonMenuOrderListBox
	if LibAddonMenuOrderListBox then
		table.insert(optionsTable, {
            type                 = "orderlistbox",
            name                 = GetString(SI_PET_HEALTH_LAM_EXCLUDED_ZONEIDS),
            tooltip              = GetString(SI_PET_HEALTH_LAM_EXCLUDED_ZONEIDS_TT),
            listEntries          = PetHealth.GetSavedVars().excludedZonesForHide,
            getFunc              = function() return PetHealth.GetSavedVars().excludedZonesForHide end,
            setFunc              = function(currentSortedListEntries)
                PetHealth.GetSavedVars().excludedZonesForHide = currentSortedListEntries
                updateExcludedZonesForHide()
            end,
            width                = "full", -- or "half" (optional)
            isExtraWide          = false, -- or function returning a boolean (optional). Show the listBox as extra wide box
            minHeight            = 200,
            maxHeight            = 500,
            rowHeight            = 25,
            --rowSelectedCallback  = function() doStuffOnSelection(rowControl, previouslySelectedData, selectedData, reselectingDuringRebuild) end, --An optional callback function when a row of the listEntries got selected (optional)
            --rowHideCallback = function() doStuffOnHide(rowControl, currentRowData) end, --An optional callback function when a row of the listEntries got hidden (optional)
            disableDrag = false, -- or function returning a boolean (optional). Disable the drag&drop of the rows
            disableButtons = false, -- or function returning a boolean (optional). Disable the move up/move down/move to top/move to bottom buttons
            showPosition = false, -- or function returning a boolean (optional). Show the position number in front of the list entry
            showValue = false, -- or function returning a boolean (optional). Show the value of the entry after the list entry text, surrounded by []
            showValueAtTooltip = false, -- or function returning a boolean (optional). Show the value of the entry after the tooltip text, surrounded by []
            addEntryDialog = { title = "Add new zoneId", text = "Enter new zoneId here", textType = TEXT_TYPE_NUMERIC, buttonTexture = "", maxInputCharacters = 5, selectAll = false, defaultText = "Type zoneId here" },
            addEntryCallbackFunction = function(orderListBox, newAddedEntry, orderListBoxData)
                updateExcludedZonesForHide()
                return true
            end,
            showRemoveEntryButton = true, -- or function returning a boolean (optional). Show a button to remove the currently selected entry
            askBeforeRemoveEntry = false, -- or function returning a boolean (optional). If showRemoveEntryButton is enabled: Ask via a dialog if the entry should be removed
            --removeEntryCheckFunction = function (orderListBox, selectedIndex, orderListBoxData) return true end, -- (optional) function returning a boolean (true = remove, false = keep) if the entry can be removed or not
            removeEntryCallbackFunction = function(orderListBox, selectedEntry, orderListBoxData)
                updateExcludedZonesForHide()
                return true
            end, -- (optional) function returning a boolean (true = removed, false = not removed) called as the entry get's removed,
            --disabled = function () return false end, -- or boolean (optional)
            --warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
            --requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
            default = defaults.excludedZonesForHide, -- default value or function that returns the default value (optional)
            --helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
            --reference = "MyAddonOrderListBox" -- function returning String, or String unique global reference to control (optional)
        })
	end   
	-- END OF OPTIONS TABLE
	--Create the LAM panel now
    LAM:RegisterOptionControls(addonVars.name .. "_LAM", optionsTable)
end