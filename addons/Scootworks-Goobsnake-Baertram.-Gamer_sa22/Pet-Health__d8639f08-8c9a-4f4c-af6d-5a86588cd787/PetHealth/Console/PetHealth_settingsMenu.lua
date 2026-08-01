--Initial LHAS Settings support and code cleanup by Baertram and moved to LHAS by Gamer_sa22 for console use

PetHealth = PetHealth or {}
    
local function updateExcludedZonesForHide()
    local settings = PetHealth.savedVars
    if not settings then return end

    local excludedZonesForHide = PetHealth.excludedZonesForHide
    for _, data in ipairs(settings.excludedZonesForHide) do
        excludedZonesForHide[data.value] = true
    end
    PetHealth.excludedZonesForHide = excludedZonesForHide
end
PetHealth.updateExcludedZonesForHide = updateExcludedZonesForHide

function PetHealth.buildAddonMenu()
	local LHAS = LibHarvensAddonSettings 
   -- local settings = PetHealth.GetSavedVars()
    if not LHAS or not PetHealth.GetSavedVars() then return false end

    local defaults = PetHealth.savedVarsDefault
    local addonVars = PetHealth.addonData

    local savedVariablesOptions = {
		[1] = {name = GetString(SI_PET_HEALTH_EACH_CHAR), data = 1,},
		[2] = {name = GetString(SI_PET_HEALTH_ACCOUNT_WIDE), data = 2,},
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
	CALLBACK_MANAGER:RegisterCallback("LibHarvensAddonSettings_AddonSelected", addonSelected)
    --Create the options table for the LAM controls
    local defaultSkip = false
	local options = {
        allowDefaults = true, --will allow users to reset the settings to default values
        allowRefresh = true, --if this is true, when one of settings is changed, all other settings will be checked for state change (disable/enable)
        defaultsFunction = function() --this function is called when allowDefaults is true and user hit the reset button
           
		   d("Reset")
        end,
    }
	LHAS_SettingsPanel = LHAS:AddAddon(addonVars.lamDisplayName, options)

   local optionsTable ={	
		-- BEGIN OF OPTIONS TABLE
		{
			type = LHAS.ST_CHECKBOX,
			label = " ",
			getFunction = function() return false end,
			setFunction = function(value) defaultSkip = value end,
			canSelect = false,
			disable = true,
			default = true,
		},
		{
			type = LHAS.ST_SECTION,
			label = GetString(SI_PET_HEALTH_DESC),
		},
		{
			type = LHAS.ST_DROPDOWN,
			label = GetString(SI_PET_HEALTH_SAVE_TYPE),
			tooltip = GetString(SI_PET_HEALTH_SAVE_TYPE_TT),
			items = savedVariablesOptions,
			getFunction = function() return savedVariablesOptions[PetHealth.saveMode].name end,
			setFunction = function(control, itemName, itemData) 
				if defaultSkip then defaultSkip = false return end -- skip the default reset so we stay on the setting we want to reset
				if PetHealth.saveMode ~= itemData.data then
					PetHealth.saveMode = itemData.data
					PetHealth.saveTypeChanged()	
					PetHealth.MovePetWindow()
				end
			end,
			default = savedVariablesOptions[defaults.saveMode].name,
		},	
        --==============================================================================
        {
			type = LHAS.ST_SECTION,
			label = GetString(SI_PET_HEALTH_LAM_HEADER_VISUAL),
		},
		{
			type = LHAS.ST_CHECKBOX,
			label = "Show Pet Window Here",
			getFunction = function() return PetHealthWindowInMenu end,
			setFunction = function(value) 	
				if PetHealthWindowInMenu == value then return end
				if not PetHealthWindowInMenu then
					addPetHealthWindow()
				else
					addonSelected()
				end			
            end,
			default = false
		},
		{
			type = LHAS.ST_SLIDER,
			label = "Left <- -> Right",
			tooltip = "move it left or right",
			min = -30, max = maxX, step = 5,
			getFunction = function() return PetHealth.GetSavedVars().x end,
			setFunction = function(value) 
				PetHealth.GetSavedVars().x = value
               PetHealth.MovePetWindow()
			end,
			default = defaults.x,
		},
		{
			type = LHAS.ST_SLIDER,
			label = "Up <- -> Down",
			tooltip = "move it up or down",
			min = -30, max = maxY, step = 5,
			getFunction = function() return PetHealth.GetSavedVars().y end,
			setFunction = function(value) 
				PetHealth.GetSavedVars().y = value
               PetHealth.MovePetWindow()
			end,
			default = defaults.y
		},
		{
			type = LHAS.ST_CHECKBOX,
			label = GetString(SI_PET_HEALTH_LAM_LABELS),
            tooltip = GetString(SI_PET_HEALTH_LAM_LABELS_TT),
			getFunction = function() return PetHealth.GetSavedVars().showLabels end,
			setFunction = function(value) 
				PetHealth.GetSavedVars().showLabels = value
                PetHealth.changeLabels(value) 
			end,
			default = defaults.showLabels,
		},
		{
			type = LHAS.ST_CHECKBOX,
			label =  GetString(SI_PET_HEALTH_LAM_VALUES),
            tooltip = GetString(SI_PET_HEALTH_LAM_VALUES_TT),
			getFunction = function() return PetHealth.GetSavedVars().showValues end,
			setFunction = function(value) 
				PetHealth.GetSavedVars().showValues = value
                PetHealth.changeValues(value) 
			end,
			default = defaults.showValues,
		},
		{
			type = LHAS.ST_CHECKBOX,
			label = GetString(SI_PET_HEALTH_LAM_UNSUMMONED_ALERT),
            tooltip = GetString(SI_PET_HEALTH_LAM_UNSUMMONED_ALERT_TT),
			getFunction = function() return PetHealth.GetSavedVars().petUnsummonedAlerts end,
			setFunction = function(value) 
				PetHealth.GetSavedVars().petUnsummonedAlerts = value
                PetHealth.unsummonedAlerts(value) 
			end,
			default = defaults.petUnsummonedAlerts,
		},
		{
			type = LHAS.ST_CHECKBOX,
			label = GetString(SI_PET_HEALTH_LAM_USE_ZOS_STYLE),
            tooltip = GetString(SI_PET_HEALTH_LAM_USE_ZOS_STYLE_TT),
			getFunction = function() return PetHealth.GetSavedVars().useZosStyle end,
			setFunction = function(value) 
				PetHealth.GetSavedVars().useZosStyle = value
				if value then 
					PetHealth.changeBackground(false)
				else
					PetHealth.changeBackground(PetHealth.GetSavedVars().showBackground)
				end
				PetHealth.frameStyleChanged()
			end,
			default = defaults.useZosStyle,
		},
        {
			type = LHAS.ST_CHECKBOX,
			label = GetString(SI_PET_HEALTH_LAM_BACKGROUND),
            tooltip = GetString(SI_PET_HEALTH_LAM_BACKGROUND_TT),
			getFunction = function() return PetHealth.GetSavedVars().showBackground end,
			setFunction = function(value) 
				PetHealth.GetSavedVars().showBackground = value
                PetHealth.changeBackground(value) 
			end,
			disable = function() return  PetHealth.GetSavedVars().useZosStyle end, 
			default = defaults.showBackground,
		},
		{
			type = LHAS.ST_SLIDER,
			label = GetString(SI_PET_HEALTH_LAM_LOW_HEALTH_WARN),
            tooltip = GetString(SI_PET_HEALTH_LAM_LOW_HEALTH_WARN_TT),
			min = 0, max = 99, step = 1,
			getFunction = function() return PetHealth.GetSavedVars().lowHealthAlertSlider end,
			setFunction = function(value) 
				PetHealth.GetSavedVars().lowHealthAlertSlider = value
                PetHealth.lowHealthAlertPercentage(value)
			end,
			default = defaults.lowHealthAlertSlider
		},
		{
			type = LHAS.ST_SLIDER,
			label = GetString(SI_PET_HEALTH_LAM_LOW_SHIELD_WARN),
            tooltip = GetString(SI_PET_HEALTH_LAM_LOW_SHIELD_WARN_TT),
			min = 0, max = 99, step = 1,
			getFunction = function() return PetHealth.GetSavedVars().lowShieldAlertSlider end,
			setFunction = function(value) 
				PetHealth.GetSavedVars().lowShieldAlertSlider = value
                PetHealth.lowShieldAlertPercentage(value)
			end,
			default = defaults.lowShieldAlertSlider
		},
		{
			type = LHAS.ST_COLOR,
			label = "low Health Alert Color",
			tooltip = function() return zo_strformat("|c"..PetHealth.GetSavedVars().lowHealthAlertColor.."<<1>> <<2>>|r", "PET NAME", GetString(SI_PET_HEALTH_LOW_HEALTH_WARNING_MSG)) end,
			getFunction = function() return ZO_ColorDef:New(PetHealth.GetSavedVars().lowHealthAlertColor):UnpackRGBA() end,
			setFunction = function(r, g, b, a) PetHealth.GetSavedVars().lowHealthAlertColor = ZO_ColorDef:New(r, g, b):ToHex() end,
			default = {ZO_ColorDef:New(defaults.lowHealthAlertColor):UnpackRGBA()},
		},
		{
			type = LHAS.ST_COLOR,
			label = "low Shield Alert Color",
			tooltip = function() return zo_strformat("|c"..PetHealth.GetSavedVars().lowShieldAlertColor.."<<1>>\'s <<2>>|r", "PET NAME", GetString(SI_PET_HEALTH_LOW_SHIELD_WARNING_MSG)) end,
			getFunction = function() return ZO_ColorDef:New(PetHealth.GetSavedVars().lowShieldAlertColor):UnpackRGBA() end,
			setFunction = function(r, g, b, a) PetHealth.GetSavedVars().lowShieldAlertColor = ZO_ColorDef:New(r, g, b):ToHex() end,
			default = {ZO_ColorDef:New(defaults.lowShieldAlertColor):UnpackRGBA()},
		},
		{
			type = LHAS.ST_CHECKBOX,
			label = GetString(SI_PET_HEALTH_LAM_COMPANION),
            tooltip = GetString(SI_PET_HEALTH_LAM_COMPANION_TT),
			getFunction = function() return PetHealth.GetSavedVars().showCompanion end,
			setFunction = function(value) 
				PetHealth.GetSavedVars().showCompanion = value
                PetHealth.changeCompanion(value)
			end,
			default = defaults.showCompanion,
		},
        --==============================================================================
		{
			type = LHAS.ST_SECTION,
			label = GetString(SI_PET_HEALTH_LAM_HEADER_BEHAVIOR),
		},
		{
			type = LHAS.ST_CHECKBOX,
			label = GetString(SI_PET_HEALTH_LAM_HIDE_IN_DUNGEON),
            tooltip = GetString(SI_PET_HEALTH_LAM_HIDE_IN_DUNGEON_TT),
			getFunction = function() return PetHealth.GetSavedVars().hideInDungeon end,
			setFunction = function(value) 
				PetHealth.GetSavedVars().hideInDungeon = value
                PetHealth.hideInDungeon(value)
			end,
			default = defaults.hideInDungeon,
		},
		{
			type = LHAS.ST_CHECKBOX,
			label = GetString(SI_PET_HEALTH_LAM_ONLY_IN_COMBAT),
            tooltip = GetString(SI_PET_HEALTH_LAM_ONLY_IN_COMBAT_TT),
			getFunction = function() return PetHealth.GetSavedVars().onlyInCombat end,
			setFunction = function(value) 
				PetHealth.GetSavedVars().onlyInCombat = value
                PetHealth.changeCombatState()
			end,
			default = defaults.onlyInCombat,
		},
		{
			type = LHAS.ST_SLIDER,
			label = GetString(SI_PET_HEALTH_LAM_ONLY_IN_COMBAT_HEALTH),
            tooltip = GetString(SI_PET_HEALTH_LAM_ONLY_IN_COMBAT_HEALTH_TT),
			min = 0, max = 99, step = 1,
			getFunction = function() return PetHealth.GetSavedVars().onlyInCombatHealthSlider end,
			setFunction = function(value) 
				PetHealth.GetSavedVars().onlyInCombatHealthSlider = value
                PetHealth.onlyInCombatHealthPercentage(value)
			end,
			disable = function() return not PetHealth.GetSavedVars().onlyInCombat end, 
			default = defaults.onlyInCombatHealthSlider
		},  
		{
			type = LHAS.ST_BUTTON,
			label = "Submit Feedback / Request",
			buttonText = "Submit",
			tooltip = "link to a form where you can leave feedback or even leave a request",
			clickHandler = function(control) RequestOpenUnsafeURL("https://docs.google.com/forms/d/e/1FAIpQLScYWtcIJmjn0ZUrjsvpB5rwA5AlsLvasHUIcKqzIYcogo9vjQ/viewform?usp=pp_url&entry.550722213=".."Pet Health") end,
		},
    } -- optionsTable
	--[[ to be added later
    -- Optional suport for LibAddonMenuOrderListBox
	if LibAddonMenuOrderListBox then
		table.insert(optionsTable, {
            type                 = "orderlistbox",
            name                 = GetString(SI_PET_HEALTH_LAM_EXCLUDED_ZONEIDS),
            tooltip              = GetString(SI_PET_HEALTH_LAM_EXCLUDED_ZONEIDS_TT),
            listEntries          = settings.excludedZonesForHide,
            getFunc              = function() return settings.excludedZonesForHide end,
            setFunc              = function(currentSortedListEntries)
                settings.excludedZonesForHide = currentSortedListEntries
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
	--]]
	-- END OF OPTIONS TABLE
	--Create the LAM panel now
	LHAS_SettingsPanel:AddSettings(optionsTable)
end