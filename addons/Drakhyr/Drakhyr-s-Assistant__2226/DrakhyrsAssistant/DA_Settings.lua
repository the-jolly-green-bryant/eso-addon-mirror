--local LAM2 = LibStub("LibAddonMenu-2.0")

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DA = {}
DA.name = "DrakhyrsAssistant"
DA.version = "0.2"
DA.versionNum = tonumber(DA.version)
DA.initialised = false

-- Set-up the defaults options for saved variables.
DA.defaults = {
	Debug = false,
	FXCounterEnabled = true,
	Effect1 = "Major Expedition",
	Count1 = 0,
	Effect2 = "Vicious Death",
	Count2 = 0,
	--FilterPlayer = false,
	--FilterGroup = false,
	LogFilter = "All",
	EffectFilter = "Me",
	LoggerEnabled = false
	}

--------------------------------------------------------------------------------------------------
--UI controls

local function addSubMenu(parent, theTitle, theControls)
	parent[#parent + 1] = {
		type = "submenu",
		name = theTitle,
		controls = theControls
	}
end

local function addTitle(parent, title)
	parent[#parent + 1] = {
		type = "header",
		name = title,
	}
end

local function addDescription(parent, theTitle, theText, theWidth)
	parent[#parent + 1] = {
		type = "description",
		title = theTitle,
		text = theText,
		width = theWidth--half or full
	}
end

local function addEditbox(parent, saveData, defaultData, propertyName, theName, theWidth, isMulti)
	parent[#parent + 1] = {
		type = "editbox",
		name = theName,
		getFunc = function() return saveData[propertyName] end,
		setFunc = function(value) saveData[propertyName] = value end,
		isMultiline = isMulti,
		width = theWidth--half or full
	}
end

local function addCheckbox(parent, saveData, defaultData, propertyName, label, tooltip, warning, disabled, callback, theWidth)
	parent[#parent + 1] = {
		type = "checkbox",
		name = label,
		tooltip = tooltip,
		getFunc = function() return saveData[propertyName] end,
		setFunc = function(value) saveData[propertyName] = value 
			if callback then callback(value) end
		end,
		warning = warning,
		disabled = disabled,
		default = defaultData[propertyName],
		width = theWidth
	}
end

local function addButtonCountReset(parent, name, tooltip, width, func)
	parent[#parent + 1] = {
		type = "button",
		name = name, -- string id or function returning a string
		func = func,
		tooltip = tooltip, -- string id or function returning a string (optional)
		width = width, --or "half" (optional)
		--disabled = function() return db.someBooleanSetting end, --or boolean (optional)
		--icon = "icon\\path.dds", --(optional)
		--isDangerous = false, -- boolean, if set to true, the button text will be red and a confirmation dialog with the button label and warning text will show on click before the callback is executed (optional)
		--warning = "Will need to reload the UI.", --(optional)
		--reference = "MyAddonButton", -- unique global reference to control (optional)
	}
end

local function addSlider(parent, saveData, defaultData, propertyName, min, max, label, tooltip, warning, disabled, isHalf, callback, stepSize)
	parent[#parent + 1] = {
		type = "slider",
		name = label,
		tooltip = tooltip,
		width = isHalf and "half" or nil,
		min = min,
		max = max,
		step = stepSize,
		getFunc = function() return saveData[propertyName] end,
		setFunc = function(value)
			saveData[propertyName] = value
			if(callback) then callback(saveData, value) end
		end,
		warning = warning,
		disabled = disabled,
		default = defaultData[propertyName]
	}
end

local function addDropdown(parent, saveData, defaultData, propertyName, theName, theChoices, ref, tooltip) 
	parent[#parent + 1] = {
		type = "dropdown",
		name = theName,
		choices = theChoices,
		getFunc = function()
			for k,v in pairs(theChoices) do
				if saveData[propertyName] == v then
					return v
				end
			end
		end,
		setFunc = function(value)
			for k,v in pairs(theChoices) do
				if value == v then
					saveData[propertyName] = v
				end
			end
		end,
		default = defaultData[propertyName],
		reference = ref,
		tooltip = tooltip
	}
end

local function addDropdownCustomFunc(parent, saveData, defaultData, propertyName, theName, theChoices, tooltip, getFunc, setFunc) 
	parent[#parent + 1] = {
		type = "dropdown",
		name = theName,
		choices = theChoices,
		getFunc = getFunc,
		setFunc = setFunc,
		default = defaultData[propertyName],
		reference = ref,
		tooltip = tooltip
	}
end

--------------------------------------------------------------------------------------------------
--create UI
DA.addonMenu = LibStub:GetLibrary("LibAddonMenu-2.0")
function DA.populateSettingsUI()
	local optionsData = {}
	local submenu = {}
	local DA_panelData = {
		type = "panel",
		name = DA.name,
		displayName = "Drakhyr's Assistant",
		author = "Drakhyr",
		version = DA.version,
		registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
		registerForDefaults = true	--boolean (optional) (will set all options controls back to default values)
	}
	
	--DA.TheSlots = {}
	--DA.TheSlotNames = {}
	optionsData = {}
	--DA.createSlotTables()
	
	local PanelBuilt = false
	
	local function addonMenuOnRefreshCallback(panel)
		DA.log("menu refresh")
		if panel == DA.addonMenuPanel then
			
			optionsData = {}
			--DA.TheSlots = {}
			--DA.TheSlotNames = {}
			--DA.createSlotTables()
		
			--Dropdown_Recovered:UpdateChoices(DA.TheSlotNames)
			
			-- for i=1,#DA.TheSlotNames do
				-- d("----------- "..tostring(DA.savedVariables.PVPStamSlotPos))
				-- d(DA.TheSlotNames[i]..": "..DA.TheSlots[i])
			-- end
		end
	end
	
	ZO_PreHookHandler(ZO_GameMenu_InGame, "OnShow", function() if PanelBuilt then addonMenuOnRefreshCallback(DA.addonMenuPanel) end end)  --refresh the dropdowns
	
	local function addonMenuOnLoadCallback(panel)
		
		if panel == DA.addonMenuPanel then
			DA.log("menu load")
			--UnRegister the callback for the LAM2 panel created function
	        CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", addonMenuOnLoadCallback)
			
			PanelBuilt = true
		
			--Register the callback for the LAM panel refresh function
			CALLBACK_MANAGER:RegisterCallback("LAM-RefreshPanel", addonMenuOnRefreshCallback)
		end
		
	end
	--Register the callback for the LAM panel created function
  	CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", addonMenuOnLoadCallback)
	
	--function DA.BuildRFCUI()
	DA.log("building menu")
	--addon description
	--addDescription(optionsData, "", "Open a store and your gear will be automatically repaired, your weapons recharged and missing items automatically bought. Ready for the next fight, and it didn't even take 5 seconds. And never forget your food again. The chat output is your log to be sure that something happend and what it was. Settings are saved per character.")
	
	--FXCounter
	addTitle(optionsData, "|c3e73ffFXCounter|r")
	addCheckbox(optionsData, DA.savedVariables, DA.defaults, "FXCounterEnabled", "|c3e73ffEnable FXCounter|r", nil, nil, nil, DA.ToggleFXCounter, "full")
	addDescription(optionsData, "", "Which effect to count (correct spelling of the complete name)")
	addEditbox(optionsData, DA.savedVariables, DA.defaults, "Effect1", "|c3e73ffEffect to count|r", "full", false)
	addDropdownCustomFunc(optionsData, DA.savedVariables, DA.defaults, "EffectFilter", "|c3e73ffFilter|r", {"All","Group","Me"}, nil, 
		function()
			for k,v in pairs({"All","Group","Me"}) do
				if DA.savedVariables.EffectFilter == v then
					return v
				end
			end
		end,
		function(value)
			for k,v in pairs({"All","Group","Me"}) do
				if value == v then
					--DA.savedVariables["EffectFilter"] = v
					DA.savedVariables.EffectFilter = v
				end
			end
			DA.FXFilterSwitch()
		end
	)
	--addCheckbox(optionsData, DA.savedVariables, DA.defaults, "FilterPlayer", "|c3e73ffOnly FX on me|r", nil, nil, nil, DA.ToggleFilterPlayer, "full")
	--addCheckbox(optionsData, DA.savedVariables, DA.defaults, "FilterGroup", "|c3e73ffOnly FX on group|r", nil, nil, nil, DA.ToggleFilterGroup, "full")
	addButtonCountReset(optionsData, "|c3e73ffReset Counter|r", "Reset the counter to 0", "full",function() 
		DA.savedVariables.Count = 0 
		--DA_COUNTERCount:SetText(DA.savedVariables.Effect1..": "..DA.savedVariables.Count)
		--DA_COUNTEREffect1:SetText(DA.savedVariables.Effect1)
		DA_COUNTERCount1:SetText(0)
		DA.savedVariables.Count1 = 0
		--DA_COUNTEREffect2:SetText(DA.savedVariables.Effect2)
		DA_COUNTERCount2:SetText(0)
		DA.savedVariables.Count2 = 0
		end)
	
	addDescription(optionsData, "Log FX names and IDs", "Logging depends on the filter settings above. If you want all FX logged then set the above filter also to \"All\".")
	addCheckbox(optionsData, DA.savedVariables, DA.defaults, "LoggerEnabled", "|c3e73ffEnable logger|r", nil, nil, nil, DA.ToggleLogEffects, "full")
	addDropdown(optionsData, DA.savedVariables, DA.defaults, "LogFilter", "|c3e73ffFilter the log output|r", {"All","Group","Me"}, nil, nil)
	
	--addCheckbox(optionsData, DA.savedVariables, DA.defaults, "LogEffectsOnMe", "|c3e73ffEnable logger on me|r", nil, nil, nil, DA.ToggleLogEffectsOnMe, "full")
	--addCheckbox(optionsData, DA.savedVariables, DA.defaults, "LogEffectsOnGroup", "|c3e73ffEnable logger on group|r", nil, nil, nil, DA.ToggleLogEffectsOnGroup, "full")
	
	--Assistants
	addTitle(optionsData, "|c3e73ffAssistants|r")
	addDescription(optionsData, "", "Set keybinds for the merchant, banker and reloadui in your game settings under DA.") --spacer
	--Debug
	--addTitle(optionsData, " ")
	--addCheckbox(optionsData, DA.savedVariables, DA.defaults, "Debug", "Debug", nil, nil, nil, nil, "full")
	
	--Register Settings Menu
	DA.addonMenuPanel = DA.addonMenu:RegisterAddonPanel("DA_Settings", DA_panelData)
	DA.addonMenu:RegisterOptionControls("DA_Settings", optionsData)
end



--------------------------------------------------------------------------------------------------

function DA.setupUI()
	DA.populateSettingsUI() --generate UI option data from items
	
	--keybinding
	--ZO_CreateStringId("SI_BINDING_NAME_RFC_AUTOREPAIR", "Repair gear and recharge weapons")
	
	ZO_CreateStringId("SI_BINDING_NAME_DA_RELOADUI", "ReloadUI")
		
	ZO_CreateStringId("SI_BINDING_NAME_DA_MERCHANT", "Merchant")
	ZO_CreateStringId("SI_BINDING_NAME_DA_BANKER", "Banker")
	
	DA.initCOUNTER()
	--DA_COUNTERLabelCounter:SetText("Drakhyr's FX counter")
	--DA_COUNTERLabelCounter:SetText(DA.savedVariables.Effect1..": "..DA.savedVariables.Count)
	DA_COUNTEREffect1:SetText(DA.savedVariables.Effect1)
	DA_COUNTERCount1:SetText(DA.savedVariables.Count1)
	DA_COUNTEREffect2:SetText(DA.savedVariables.Effect2)
	DA_COUNTERCount2:SetText(DA.savedVariables.Count2)
end

-----------------------------------------------------------------------------------------------------
