--[[----------------------------------------------------------
    CurvyHud 
    ----------------------------------------------------------
	Localization 	:	/Main/Menu.lua 
    Original Author	:	Niocwy
	Update Author 	:	Vvarderen
    Version			: 	6.12
    Updated			:  	2020-06-20 (YYYY-MM-DD)
----------------------------------------------------------]]--

local L = CurvyHud:GetLoc()

-- Create a list of the saved presets, replacing defaults config IDs by their localized, display names
local function SavedPresets()

	local result = {}
	local i = 1
	local defaultConfigs = CurvyHud.defaultConfigs
	local tmp = {}
	-- load default presets first,  adding their localized names to the list
	for index, v in ipairs(defaultConfigs) do
		result[i] = L.ProfilsMgtdefaultProfil .. index
		i = i + 1
	end
	-- then add user presets in alphabetical order
	for k, v in pairs(CurvyHud.varsAccount.userConfigs) do
		table.insert(tmp, k)
	end
	table.sort(tmp)
	for j,  k in ipairs(tmp) do
		result[i] = k
		i = i + 1
	end
	return result
end

local function InUserPresets(name)

	for k, v in pairs(CurvyHud.varsAccount.userConfigs) do
		if k == name then	
			return true
		end	
	end
	return false
end

local function IsPresetDefault(presetName)

	if string.sub(presetName, 1, 1) == "*" then
		return true
	else
		return false
	end
end

local function deepcopy(orig)

    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key,  orig_value in next,  orig,  nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy,  deepcopy(getmetatable(orig)))
    else -- number,  string,  boolean,  etc
        copy = orig
    end
    return copy
end

function CurvyHud:MenuPanel()

	local LAM = LibAddonMenu2	

-------------	
-- Main Panel
-------------
	local panelData = {
		type 				= "panel", 
		name 				= CurvyHud.name, 
		displayName 		= CurvyHud.colorTable["titleColor"] .. "CurvyHud", 
		author 				= L.authors, 
		version 			= CurvyHud.version, 
		website				= CurvyHud.website, 
		slashCommand 		= L.CurvySlashCmd, 
		registerForRefresh 	= true, 
	}
	
-- End of panel
	
	LAM:RegisterAddonPanel		("CurvyHudpanel", 	panelData)
	CurvyHud.OptionDataMenu()
end
	
function CurvyHud.OptionDataMenu()

	local LAM = LibAddonMenu2	
	local cfg				= CurvyHud.config	
	local barchoiced 		= cfg.healthBar
	local selectedBar 		= L.Health
	local selectedUnit 		= L.PlayerUnit
	local selectedUnitEffect= L.PlayerUnit
	local selectedVisuals 	= cfg.visuals
	local comp 				= cfg.compass	
	local lowAlert 			= cfg.lowAttributes
	local tips 				= cfg.combatTips
	local reticle			= cfg.reticleOption
	local cleps				= cfg.clepsydre
	local editNewText 		= ""

	for i = 1, GetNumGuilds() do
	local guildId = GetGuildId(i)
		if (i == 1) then
			CurvyHud.state.initGone = GetGuildName(guildId)
		elseif (i == 2) then
			CurvyHud.state.initGtow = GetGuildName(guildId)
		elseif (i == 3) then
			CurvyHud.state.initGthree = GetGuildName(guildId)
		elseif (i == 4) then
			CurvyHud.state.initGfour = GetGuildName(guildId)
		elseif (i == 5) then
			CurvyHud.state.initGfive = GetGuildName(guildId)			
		end
	CurvyHud.state.initGnumber 	= GetNumGuilds()
	end

---------------	
-- Option table
---------------
	local optionsTable = {}
	---- LOGO ----
    optionsTable[#optionsTable + 1] = {
	type 	= "texture", 
	image 		= CurvyHud.name .. "/textures/icons/logo.dds", 
	imageWidth 	= 128, 	
	imageHeight = 64, 
    }
	-- Profils Management
    optionsTable[#optionsTable + 1] = {
    type 	= "header", 
    name 	= CurvyHud.colorTable["titleColor"] .. L.ProfilsMgtHeader, 
    }
	optionsTable[#optionsTable + 1] = {
    type 	= "description", 
    text 	= L.ProfilsMgtHeaderdesc
    }
	-- Saved profil dropdown
	optionsTable[#optionsTable + 1] = {
    type 	= "dropdown", 
    choices = SavedPresets(), 
	getFunc = function()
		return selectedPreset
	end, 
	setFunc = function(arg)
		selectedPreset = arg
		if(not IsPresetDefault(selectedPreset)) then
			CurvyHud:ControlButttons("saveButton", true)
			CHAT_SYSTEM:AddMessage(L.CurvyHudinfo .. L.Profils .. selectedPreset .. L.ProfilsSelected)
		else
			CurvyHud:ControlButttons("saveButton", false)
		end
		CurvyHud:ControlButttons("loadButton", true)
	end, 
    }
	-- LOAD button
	optionsTable[#optionsTable + 1] = {
    type 	= "button", 
    name 	= L.ProfilsMgtBtnLoad, 
	warning = L.ProfilsMgtBtnLoadReload, 
	func 	= function()
		-- if the selected preset is a default config,  get its ID instead of localized, display name
		if(IsPresetDefault(selectedPreset)) then
			CurvyHud.config = deepcopy(CurvyHud.defaultConfigs[tonumber(string.sub(selectedPreset, -1, -1))])
			CHAT_SYSTEM:AddMessage(L.CurvyHudinfo .. L.Profils .. selectedPreset .. L.ProfilsLoaded)
		else
			CurvyHud.config = deepcopy(CurvyHud.varsAccount.userConfigs[selectedPreset])
			CHAT_SYSTEM:AddMessage(L.CurvyHudinfo .. L.Profils .. selectedPreset .. L.ProfilsLoaded)
		end
		CurvyHud.vars.config = CurvyHud.config
		ReloadUI()
	end, 
	disabled = function() 
		return CurvyHud.button.load == false			
	end, 
	reference = 'CurvyHudOptions_cfgBtnLoadBtn'
    } 
	-- SAVE button
	optionsTable[#optionsTable + 1] = {
    type = "button", 
    name = L.ProfilsMgtBtnSave, 
	func = function()
		-- we can save only if the selected preset is not a default one
		if (not IsPresetDefault(selectedPreset)) then
			CurvyHud.varsAccount.userConfigs[selectedPreset] = deepcopy(CurvyHud.config)
			CHAT_SYSTEM:AddMessage(L.CurvyHudinfo .. L.Profils .. selectedPreset .. L.ProfilsSaved)
		end
	end, 
	disabled = function() 
		return CurvyHud.button.save == false			
	end, 
	reference = 'CurvyHudOptions_cfgBtnSaveBtn'
    }
	optionsTable[#optionsTable + 1] = {
    type = "description", 
    text = L.ProfilsMgtEndHeaderdesc
    } 
-------------------
-- CREATE NEW PROFIL
-------------------
	optionsTable[#optionsTable + 1] = {
	type = "submenu", 
	name = CurvyHud.colorTable["titleColor"] .. L.ProfilsMgtCreatNewProfilSubMenu, 
	controls = {
		-- New Preset description	
		{
		type 	= "description", 
		text 	= L.ProfilsMgtNewdesc, 
		}, 
		-- Preset Editbox
		{
		type 		= "editbox", 
		isMultiline = false, 
		getFunc = function()
			return ""
		end, 
		setFunc = function(arg)
			editNewText = arg
			if (editNewText ~= nil and editNewText ~= '') then
				local goodNname, x = string.gsub(editNewText, "[^a-zA-Z0-9_-]", "")
				local button = "newButton"
				if(x > 0) then	
					CurvyHud:ControlButttons(button, false)
				elseif(InUserPresets(editNewText)) then
					CurvyHud:ControlButttons(button, false)
				else
					CurvyHud:ControlButttons(button, true)
				end
			end
		end, 
		}, 
		-- New Preset button
		{
		type 		= "button", 
		name 		= L.ProfilsMgtBtnNew, 
		tooltip = L.ProfilsMgtBtnNewTooltip, 
		warning = L.ProfilsMgtBtnNewWarning, 
		func = function()
			-- we can save only if the selected preset is not a default one
			if (not InUserPresets(editNewText)  and editNewText ~= nil and editNewText ~= '') then
				CurvyHud.varsAccount.userConfigs[editNewText] = deepcopy(CurvyHud.config)
				CHAT_SYSTEM:AddMessage(L.CurvyHudinfo .. L.Profils .. editNewText .. L.ProfilsCreat)
				ReloadUI()
			end
		end, 
		disabled = function() 
			return CurvyHud.button.new == false			
		end, 
		reference = 'CurvyHudOptions_cfgBtnNewBtn'
		}, 
		-- New Preset using description	
		{
		type = "description", 
		text = L.ProfilsMgtTextNewdesc, 
		}, 
	}, 
	-- End of CREAT NEW PROFIL SUBMENU
	}
	--
	-- MOVABLE SETTINGS
	--
	-- Divider
	optionsTable[#optionsTable + 1] = {
	type 	= "header", 
	name 	= CurvyHud.colorTable["divColor"] .. L.Move_ModeDiv, 
    }
	optionsTable[#optionsTable + 1] = {
    type = "description", 
    text = L.Move_ModeDesc, 
    }
	-- Unlock Move button
	optionsTable[#optionsTable + 1] = {
	type = "button", 
	name = L.MenuEnable, 
	func = function()
		CurvyHud:ToggleMoveFramesMode(true)
		if (CurvyHud.moveMode.enabled) then
			CurvyHudOptions_EnableMoveBtn.button:SetState(BSTATE_DISABLED)
			CurvyHudOptions_DisableMoveBtn.button:SetState(BSTATE_NORMAL)
		end
		CurvyHud:InitializeEffects("player")
		CurvyHud:BuildVisualizers()
		CurvyHud:InitializeState()
	end, 
	disabled = function() 
		return CurvyHud.moveMode.enabled == true 
	end, 
	reference = 'CurvyHudOptions_EnableMoveBtn'
	} 
	-- Lock Move button
	optionsTable[#optionsTable + 1] = {
	type = "button", 
	name = L.MenuDisable,  
	func = function()
		CurvyHud:ToggleMoveFramesMode(false)
		if (not CurvyHud.moveMode.enabled) then
			CurvyHudOptions_EnableMoveBtn.button:SetState(BSTATE_NORMAL)
			CurvyHudOptions_DisableMoveBtn.button:SetState(BSTATE_DISABLED)
		end
		CurvyHud:BuildVisualizers()
		CurvyHud:InitializeState()
	end, 
	disabled = function() 
		return CurvyHud.moveMode.enabled == false 
	end, 
	reference = 'CurvyHudOptions_DisableMoveBtn'
	}
	-- Display or not Bar Effets demonstration
	optionsTable[#optionsTable + 1] = {
	type 	= "checkbox", 
	name 	= L.Demobars,
	tooltip	= L.ShowMoveModeDesc,
	getFunc = function()
		return cfg.effects.showdemobars
	end, 
	setFunc = function(arg)
		if (arg ~= cfg.effects.showdemobars) then
			cfg.effects.showdemobars = arg
			CurvyHud:BuildVisualizers()
			CurvyHud:InitializeState()
		end
	end
	}
	-- Lock text on movable
	optionsTable[#optionsTable + 1] = {
	type = "checkbox", 
	name = L.Move_ModeLockValues, 
	tooltip = L.Move_ModeLockValuesTooltip, 
	getFunc = function()
		return CurvyHud.moveMode.lockTextValues
	end, 
	setFunc = function(arg)
		if (arg ~= CurvyHud.moveMode.lockTextValues) then
			CurvyHud.moveMode.lockTextValues = arg
		end
	end
	}
-------------------------------------
-- CONTAINER AND BARS GLOBAL SETTINGS
-------------------------------------
	optionsTable[#optionsTable + 1] = {
	type = "submenu", 
	name = CurvyHud.colorTable["titleColor"] .. L.GlobalSettingsSubMenu, 
    controls = {
		-- Divider
		{
		type 	= "header", 
		name 	= CurvyHud.colorTable["divColor"] .. L.ContainerDiv, 
		}, 	
		-- Left bar display form
		{
		type 	= "dropdown", 
		name 	= L.ContainerLeftForm,  
		choices = {L.ContainerStyleNormal, L.ContainerStyleStairway}, 
		getFunc = function()
			if (cfg.barContainerLeft.stepOn) then
				return L.ContainerStyleStairway
			else
				return L.ContainerStyleNormal
			end
		end, 
		setFunc = function(arg)
			if (arg == L.ContainerStyleNormal and cfg.barContainerLeft.stepOn) then
				cfg.barContainerLeft.stepOn = false
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			elseif(arg == L.ContainerStyleStairway and not cfg.barContainerLeft.stepOn) then
				cfg.barContainerLeft.stepOn = true
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Right bar display form
		{
		type 	= "dropdown", 
		name 	= L.ContainerRightForm,  
		choices = {L.ContainerStyleNormal, L.ContainerStyleStairway}, 
		getFunc = function()
			if (cfg.barContainerRight.stepOn) then
				return L.ContainerStyleStairway
			else
				return L.ContainerStyleNormal
			end
		end, 
		setFunc = function(arg)
			if (arg == L.ContainerStyleNormal and cfg.barContainerRight.stepOn) then
				cfg.barContainerRight.stepOn = false
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			elseif (arg == L.ContainerStyleStairway and not cfg.barContainerRight.stepOn) then
				cfg.barContainerRight.stepOn = true
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Divider
		{
		type 	= "header", 
		name 	= CurvyHud.colorTable["divColor"] .. L.BarDiv, 
		}, 	
		-- Choice of bar style
		{
		type 	= "dropdown", 
		name 	= L.BarStyle,  
		choices = {L.Default_bar, L.Flat_bar, L.Oblivion_bar, L.Ghost_bar}, 
		getFunc = function()
			if (cfg.textureConfig == "default")then
				return L.Default_bar
			elseif (cfg.textureConfig == "flat")then
				return L.Flat_bar
			elseif (cfg.textureConfig == "oblivion") then
				return L.Oblivion_bar
			elseif (cfg.textureConfig == "ghostly") then
				return L.Ghost_bar
			end
		end, 
		setFunc = function(arg)
			local barStyledds
			if (arg	== L.Default_bar) then
				barStyledds = "default"
			elseif (arg	== L.Flat_bar) then
				barStyledds = "flat"
			elseif (arg == L.Oblivion_bar) then
				barStyledds = "oblivion"
			elseif (arg == L.Ghost_bar) then
				barStyledds = "ghostly"
			end
			
			if (cfg.textureConfig ~= barStyledds) then
				cfg.textureConfig = barStyledds	
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Bar Spacing
		{
		type 	= "slider", 
		name 	= L.BarSpacing,  
		min 	= -5, 
		max 	= 50, 
		step 	= 1, 
		getFunc = function()
			return cfg.barSpacing
		end, 
		setFunc = function(arg)
			if (arg ~=  cfg.barSpacing) then
				cfg.barSpacing = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Bar Width
		{
		type 	= "slider", 
		name 	= L.BarWidth,  
		min 	= 50, 
		max 	= 140,  
		step 	= 1, 
		getFunc = function()
			return cfg.barWidth
		end, 
		setFunc = function(arg)
			if (arg ~=  cfg.barWidth) then
				cfg.barWidth = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Bar Height
		{
		type = "slider", 
		name = L.BarHeight, 
		min 	= 250, 
		max 	= 650,  
		step 	= 1, 
		getFunc = function()
			return cfg.barHeight
		end, 
		setFunc = function(arg)
			if (arg ~=  cfg.barHeight) then
				cfg.barHeight = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Divider	
		{
		type 	= "header", 
		name 	= CurvyHud.colorTable["divColor"] .. L.OpacityDiv, 
		}, 	
		-- Opacity out of combat state
		{
		type 	= "slider", 
		name 	= L.OpacityOoc,  
		min 	= 0, 
		max 	= 100, 
		step 	= 1, 
		getFunc = function() 
			return cfg.oocAlpha * 100 
		end, 
		setFunc = function(arg)
			if (arg / 100 ~=  cfg.oocAlpha) then
				cfg.oocAlpha = arg / 100
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Opacity out of combat when attribute is used
		{
		type 	= "slider", 
		name 	= L.OpacityAttributeUsed, 
		min 	= 0, 
		max 	= 100, 
		step 	= 1, 
		getFunc = function()
			return cfg.attributeUsedAlpha * 100
		end, 
		setFunc = function(arg)
			if (arg / 100 ~=  cfg.attributeUsedAlpha) then
				cfg.attributeUsedAlpha = arg / 100
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Divider	
		{
		type = "divider", 
		}, 	
		-- Opacity in combat state
		{
		type 	= "slider", 
		name 	= L.OpacityCombat, 
		min 	= 0, 
		max 	= 100, 
		step 	= 1, 
		getFunc = function() 
			return cfg.combatAlpha * 100 
		end, 
		setFunc = function(arg)
			if (arg / 100 ~=  cfg.combatAlpha) then
				cfg.combatAlpha = arg / 100
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Divider	
		{
		type = "divider", 
		}, 
		-- Opacity when target is acquired and not in combat
		{
		type 	= "slider", 
		name 	= L.OpacityTargetOoc, 
		min 	= 0, 
		max		= 100,  
		step 	= 1, 
		getFunc = function()
			return cfg.targetOocAlpha * 100
		end, 
		setFunc = function(arg)
			if (arg / 100 ~=  cfg.targetOocAlpha) then
				cfg.targetOocAlpha = arg / 100
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Opacity when target is acquired and IN combat
		{
		type 	= "slider", 
		name 	= L.OpacityTargetinCombat, 
		min 	= 0, 
		max 	= 100, 
		step 	= 1, 
		getFunc = function() 
			return cfg.targetinCombatAlpha * 100 
		end, 
		setFunc = function(arg)
			if (arg / 100 ~=  cfg.targetinCombatAlpha) then
				cfg.targetinCombatAlpha = arg / 100
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Divider	
		{
		type 	= "header", 
		name 	= CurvyHud.colorTable["divColor"] .. L.FormatDiv, 
		}, 
		-- Display or not the decimal spearator
         {
		type 	= "checkbox", 
		name 	= L.FormatDecSep,  
		getFunc = function()
			return cfg.localizationDecimal
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.localizationDecimal) then
				cfg.localizationDecimal = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:UpdateTargetNameplate()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Display or not the decimal in %
        {
		type 	= "checkbox", 
		name 	= L.FormatDecPer,  
		getFunc = function()
			return cfg.showDecimal
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.showDecimal) then
				cfg.showDecimal = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:UpdateTargetNameplate()
				CurvyHud:InitializeState()
			end
		end
		}, 
	}, 
	-- End of CONTAINER AND BARS GLOBAL SETTINGS SUBMENU
	}
---------------------
-- NAMEPLATE SETTINGS
---------------------
	optionsTable[#optionsTable + 1] = {
	type = "submenu", 
	name = CurvyHud.colorTable["titleColor"] .. L.NameplateSubMenu, 
    controls = {
		-- Divider
		{
		type 	= "header", 
		name 	= CurvyHud.colorTable["divColor"] .. L.NamePlateDiv, 
		}, 
		-- Display or not the nameplate
       {
		type 	= "checkbox", 
		name 	= L.MenuEnable,  
		getFunc = function()
			return cfg.targetNameplate.show
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.targetNameplate.show) then
				cfg.targetNameplate.show = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:UpdateTargetNameplate()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- name display on name plate
       {
		type 	= "dropdown", 
		name 	= L.NampletePlayer, 
		choices = {L.NameplateAvatar, L.NameplateAccount, L.NameplateAllone, L.NameplateAlltow}, 
		getFunc = function()
			if (cfg.targetNameplate.showTypeName == 'name') then
				return L.NameplateAvatar
			elseif (cfg.targetNameplate.showTypeName == 'account') then
				return L.NameplateAccount
			elseif (cfg.targetNameplate.showTypeName == 'allone') then
				return L.NameplateAllone
			elseif (cfg.targetNameplate.showTypeName == 'alltwo') then
				return L.NameplateAlltow
			end
		end, 
		setFunc = function(arg)
			local text
			if (arg == L.NameplateAvatar) then
				text = "name"
			elseif (arg == L.NameplateAccount) then
				text = "account"
			elseif (arg == L.NameplateAllone) then
				text = "allone"
			elseif (arg == L.NameplateAlltow) then
				text = "alltwo"
			end
			if (cfg.targetNameplate.showTypeName ~= text) then
				cfg.targetNameplate.showTypeName = text	
				CurvyHud:BuildVisualizers()
				CurvyHud:UpdateTargetNameplate()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Style font on name plate
       {
		type 	= "dropdown", 
		name 	= L.Font, 
		choices = {"ProseAntique", "Skyrim Handwritten", "Trajan Pro", "Univers 55", "Univers 57", "Univers 67"}, 
		getFunc = function()
			return cfg.targetNameplate.fontName
		end, 
		setFunc = function(arg)
			local text
			if (arg == "ProseAntique") then
				text = "ProseAntique"
			elseif (arg == "Skyrim Handwritten") then
				text = "Skyrim Handwritten"
			elseif (arg == "Trajan Pro") then
				text = "Trajan Pro"
			elseif (arg == "Univers 55") then
				text = "Univers 55"
			elseif (arg == "Univers 57") then
				text = "Univers 57"
			elseif (arg == "Univers 67") then
				text = "Univers 67"
			end
			if (cfg.targetNameplate.fontName ~= text) then
				cfg.targetNameplate.fontName = text	
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- font size of name plate
       {
		type 	= "slider", 
		name 	= L.FontSize,  
		tooltip = L.NamePlateFontSizeTooltip, 
		min 	= 15, 
		max 	= 55, 
		step 	= 1, 
		getFunc = function() return cfg.targetNameplate.fontSize end, 
		setFunc = function(arg)
			if (arg ~=  cfg.targetNameplate.fontSize) then
				cfg.targetNameplate.fontSize = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:UpdateTargetNameplate()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Divider
		{
		type 	= "header", 
		name 	= CurvyHud.colorTable["divColor"] .. L.NamePlateIconDiv, 
		}, 
		-- Icon class on name plate
       {
		type 	= "checkbox", 
		name 	= L.NamePlateClass, 
		getFunc = function()
			return cfg.targetNameplate.classIcon
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.targetNameplate.classIcon) then
				cfg.targetNameplate.classIcon = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:UpdateTargetNameplate()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- level on name plate
        {
		type 	= "checkbox", 
		name 	= L.NamePlateLevel, 
		getFunc = function()
			return cfg.targetNameplate.level
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.targetNameplate.level) then
				cfg.targetNameplate.level = arg
				CurvyHud:UpdateTargetNameplate()
			end
		end
		},
		-- Icon race on name plate
        {
		type 	= "checkbox", 
		name 	= L.NamePlateRace, 
		getFunc = function()
			return cfg.targetNameplate.raceIcon
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.targetNameplate.raceIcon) then
				cfg.targetNameplate.raceIcon = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:UpdateTargetNameplate()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Rank icon on nameplate
        {
		type 	= 'checkbox', 
		name 	= L.NamePlateRank, 
		getFunc = function()
			return cfg.targetNameplate.rankIcon
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.targetNameplate.rankIcon) then
				cfg.targetNameplate.rankIcon = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:UpdateTargetNameplate()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Alliance icon on nameplate
        {
		type 	= "checkbox", 
		name 	= L.NamePlateAlliance, 
		getFunc = function()
			return cfg.targetNameplate.allianceIcon
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.targetNameplate.allianceIcon) then
				cfg.targetNameplate.allianceIcon = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:UpdateTargetNameplate()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Caption
        {
		type 	= "checkbox", 
		name 	= L.NamePlateCaption, 
		getFunc = function()
			return cfg.targetNameplate.caption
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.targetNameplate.caption) then
				cfg.targetNameplate.caption = arg
				CurvyHud:UpdateTargetNameplate()
			end
		end
		}, 
		-- Color Icons on nameplate
        {
		type 	= "dropdown", 
		name 	= L.NamePlateIconColor,  
		choices = {L.Julianos, L.Gold, L.Silver, L.Alliance}, 
		getFunc = function()
			if (cfg.targetNameplate.colorIcons == 'default') then
				return L.Julianos
			elseif (cfg.targetNameplate.colorIcons == 'gold') then
				return L.Gold
			elseif (cfg.targetNameplate.colorIcons == 'silver') then
				return L.Silver
			elseif (cfg.targetNameplate.colorIcons == 'alliance') then
				return L.Alliance
			end
		end, 
		setFunc = function(arg)
			local color
			if (arg == L.Julianos) then
				color = 'default'
			elseif (arg == L.Gold) then
				color = 'gold'
			elseif (arg == L.Silver) then
				color = 'silver'
			elseif (arg == L.Alliance) then
				color = 'alliance'
			end
			if (cfg.targetNameplate.colorIcons ~= color) then
				cfg.targetNameplate.colorIcons = color
				CurvyHud:BuildVisualizers()
				CurvyHud:UpdateTargetNameplate()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Divider
		{
		type = "divider", 
		}, 
		-- Choice icon of boss
		{
		type 	= "dropdown", 
		name 	= L.BossStyle,  
		choices = {L.Default_boss, L.Star_boss, L.Dsword_boss, L.Obli_boss, L.Skull_boss, L.NoneIcon_boss}, 
		getFunc = function()
			if (cfg.iconBoss == "default_boss")then
				return L.Default_boss
			elseif (cfg.iconBoss == "star_boss") then
				return L.Star_boss
			elseif (cfg.iconBoss == "dsword_boss") then
				return L.Dsword_boss
			elseif (cfg.iconBoss == "obli_boss") then
				return L.Obli_boss
			elseif (cfg.iconBoss == "skull_boss") then
				return L.Skull_boss
			elseif (cfg.iconBoss == "noneIcon_boss") then
				return L.NoneIcon_boss
			end
		end, 
		setFunc = function(arg)
			local bossStyledds
			if (arg	== L.Default_boss) then
				bossStyledds = "default_boss"
			elseif (arg	== L.Star_boss) then
				bossStyledds = "star_boss"
			elseif (arg	== L.Dsword_boss) then
				bossStyledds = "dsword_boss"
			elseif (arg	== L.Obli_boss) then
				bossStyledds = "obli_boss"
			elseif (arg	== L.Skull_boss) then
				bossStyledds = "skull_boss"
			elseif (arg	== L.NoneIcon_boss) then
				bossStyledds = "noneIcon_boss"
			end
			if (cfg.iconBoss ~= bossStyledds) then
				cfg.iconBoss = bossStyledds	
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Color icon difficulty of Guard
        {
		type 	=	"colorpicker", 
		name 	= L.GuardColor,  
		getFunc = function()
			return unpack(cfg.targetNameplate.colorGuard)
		end, 
		setFunc = function(r, g, b, a)
			cfg.targetNameplate.colorGuard = {r, g, b, a}
			CurvyHud:BuildVisualizers()
			CurvyHud:InitializeState()
		end
		}, 
		-- Divider
		{
		type 	= "header", 
		name 	= CurvyHud.colorTable["divColor"] .. L.NamePlateCrittersDiv, 
		}, 
		-- Show or not the name of Critters
        {
		type 	= "checkbox", 
		name 	= L.MenuEnable,
		tooltip = L.ShowCrittersTooltip,
		getFunc = function()
			return cfg.showCritters
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.showCritters) then
				cfg.showCritters = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Show or not the name of deads
        {
		type 	= "checkbox", 
		name 	= L.MenuEnable, 
		tooltip = L.ShowDeadsTooltip,
		getFunc = function()
			return cfg.showDead
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.showDead) then
				cfg.showDead = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
	}, 	
	-- End of NAMEPLATE SETTINGS SUBMENU
	}
-----------------------------------
-- DIFERENTIATION OF THE TARGET BAR
-----------------------------------
	optionsTable[#optionsTable + 1] = {
	type = "submenu", 
	name = CurvyHud.colorTable["titleColor"] .. L.diffOfTargetsSubMenu, 
	controls = {
		-- Divider
		{
		type 	= "header", 
		name 	= CurvyHud.colorTable["divColor"] .. L.AllyColorBarDiv, 
		}, 
		-- Description of Friendly Player Bar
		{
		type 	= "description", 
		text 	= L.AllyColorBarDesc, 
		}, 
		-- Divider
		{
		type 	= "divider", 
		}, 
		-- Show Differentiation of Friendly Player Bar
		{
		type 	= "checkbox", 
		name 	= L.MenuEnable, 
		getFunc = function() 
			return cfg.differentiationBar.showAlly
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.differentiationBar.showAlly) then
				cfg.differentiationBar.showAlly = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Color max of firendly health bar
		{
		type 	= "colorpicker", 
		name 	= L.BarColorMax,  
		getFunc = function()
			return unpack(cfg.differentiationBar.colorMax)
		end, 
		setFunc = function(r, g, b, a)
			cfg.differentiationBar.colorMax = {r, g, b, a}
			CurvyHud:BuildVisualizers()
			CurvyHud:InitializeState()
		end
		}, 
		-- Color low of firendly health bar
		{
		type 	= "colorpicker", 
		name 	= L.BarColorLow,  
		getFunc = function()
			return unpack(cfg.differentiationBar.colorLow)
		end, 
		setFunc = function(r, g, b, a)
			cfg.differentiationBar.colorLow = {r, g, b, a}
			CurvyHud:BuildVisualizers()
			CurvyHud:InitializeState()
		end
		}, 
		-- Divider
		{
		type 	= "header", 
		name 	= CurvyHud.colorTable["divColor"] .. L.NeutralTragetDiv, 
		}, 
		-- Show Differentiation of Neutral NPC
		{
		type 	= "checkbox", 
		name 	= L.MenuEnable, 
		tooltip = L.NeutralTragetTooltip, 
		getFunc = function() 
			return cfg.differentiationBar.showNPCNeutral
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.differentiationBar.showNPCNeutral) then
				cfg.differentiationBar.showNPCNeutral = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
	}, 
	-- End of DIFERENTIATION OF THE TARGET BAR SUBMENU
	}
-------
-- BARS
-------
	optionsTable[#optionsTable + 1] = {
	type = "submenu", 
	name = CurvyHud.colorTable["titleColor"] .. L.BarsSubMenu, 
    controls = {
		-- Divider
		{
		type 	= "header", 
		name 	= CurvyHud.colorTable["divColor"] .. L.SelectedBarDiv, 
		}, 
		-- Choice bar
		{
		type 	= "dropdown", 
		name 	= L.SelectedBar,  
		choices = {L.Health, L.Magicka, L.Stamina, L.Target, L.Mount, L.Siege, L.Werewolf}, 
		getFunc = function() 
			return selectedBar
		end, 
		setFunc = function(arg)
			if (arg	== L.Health) then
				barchoiced = cfg.healthBar
			elseif (arg	== L.Magicka) then
				barchoiced = cfg.magickaBar
			elseif (arg	== L.Stamina) then
				barchoiced = cfg.staminaBar
			elseif (arg	== L.Target) then
				barchoiced = cfg.targetBar
			elseif (arg	== L.Mount) then
				barchoiced = cfg.mountBar
			elseif (arg	== L.Siege) then
				barchoiced = cfg.siegeBar
			elseif (arg	== L.Werewolf) then
				barchoiced = cfg.werewolfBar
			end
			if (arg ~= selectedBar) then
				selectedBar = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Divider
		{
		type 	= "divider", 
		}, 	
		-- Display or not the bar selected
		{
		type 	= "checkbox", 
		name 	= L.MenuEnable, 
		tooltip = L.SelectedBarShowTooltip, 
		getFunc = function() 
			return barchoiced.show
		end, 
		setFunc = function(arg)
			if (arg ~= barchoiced.show) then
				barchoiced.show = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
				CurvyHud:ToggleDefaultPlayerFrameHide()
			end
		end
		}, 
		-- Container of bars
		{
		type 	= "dropdown", 
		name 	= L.BarPosition,  
		choices = {L.Left,  L.Right}, 
		getFunc = function()
			if (barchoiced.position	== 'left' )then
				return L.Left
			elseif (barchoiced.position == 'right') then
				return L.Right
			end
		end, 
		setFunc = function(arg)
			local tmp
			if (arg	== L.Left) then
				tmp = 'left'
			elseif (arg == L.Right) then
				tmp =  'right'
			end
			if (barchoiced.position ~= tmp) then
				barchoiced.position = tmp	
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Chose poistion of bar
		{
		type 	= "dropdown", 
		name 	= L.Index,  
		tooltip = L.IndexTooltip,  
		choices = { 1,  2,  3,  4,  5,  6}, 
		getFunc = function()
			return barchoiced.index + 1	
		end, 
		setFunc = function(arg)
			if (barchoiced.index ~= arg -1) then
				barchoiced.index = arg -1
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Color Max
		{
		type 	=	"colorpicker", 
		name 	= L.BarColorMax,  
		getFunc = function()
			return unpack(barchoiced.colorMax)
		end, 
		setFunc = function(r, g, b, a)
			barchoiced.colorMax = {r, g, b, a}
			CurvyHud:BuildVisualizers()
			CurvyHud:InitializeState()
		end
		}, 
		-- Color Low
		{
		type 	= "colorpicker", 
		name 	= L.BarColorLow, 
		getFunc =function()
			return unpack(barchoiced.colorLow)
		end, 
		setFunc = function(r, g, b, a)
			barchoiced.colorLow = {r, g, b, a}
			CurvyHud:BuildVisualizers()
			CurvyHud:InitializeState()
		end
		}, 
		-- Border Color
		{
		type 	= "checkbox", 
		name 	= L.MenuEnable .. L.Border, 
		getFunc = function() 
			return barchoiced.borderShow
		end, 
		setFunc = function(arg)
			if (arg ~= barchoiced.borderShow) then
				barchoiced.borderShow = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Background Color
		{
		type 	= 'colorpicker', 
		name 	= L.BarBkgrdColor,  
		getFunc = function()
			return unpack(barchoiced.backgroundColor)
		end, 
		setFunc = function(r, g, b, a)
			barchoiced.backgroundColor = {r, g, b, a}
			CurvyHud:BuildVisualizers()
			CurvyHud:InitializeState()
		end
		}, 
		-- Divider
		{
		type = "divider", 
		}, 	
		-- Display text of attribute
		{
		type 	= "checkbox", 
		name 	= L.MenuEnable .. L.TextBar, 
		getFunc = function()
			return barchoiced.showText
		end, 
		setFunc = function(arg)
			if (arg ~= barchoiced.showText) then
				barchoiced.showText = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Format text of attributes
		{
		type 	= "editbox", 
		name 	= L.TextFormat, 
		tooltip = L.TextFormatTooltip, 
		isMultiline = false, 
		getFunc = function()
			return barchoiced.textFormat
		end, 
		setFunc =function(arg)
			if(arg ~= barchoiced.textFormat) then
				barchoiced.textFormat = string.gsub(string.gsub(arg, "%]", ""), "%[", "")
				self:BuildVisualizers()
				self:InitializeState()
			end
		end	
		}, 
		-- Style font text of attribute
		{
		type 	= "dropdown",  
		name 	= L.Font, 
		choices = {"ProseAntique", "Skyrim Handwritten", "Trajan Pro", "Univers 55", "Univers 57", "Univers 67"}, 
		getFunc = function()
			return barchoiced.fontName
		end, 
		setFunc = function(arg)
			local text
			if (arg == "ProseAntique") then
				text = "ProseAntique"
			elseif (arg == "Skyrim Handwritten") then
				text = "Skyrim Handwritten"
			elseif (arg == "Trajan Pro") then
				text = "Trajan Pro"
			elseif (arg == "Univers 55") then
				text = "Univers 55"
			elseif (arg == "Univers 57") then
				text = "Univers 57"
			elseif (arg == "Univers 67") then
				text = "Univers 67"
			end
			if (barchoiced.fontName ~= text) then
				barchoiced.fontName = text	
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Font Size of attribute
		{
		type  	= "slider", 
		name 	= L.FontSize,  
		min 	= 1, 
		max 	= 50, 
		step 	=	1, 
		getFunc = function()
			return barchoiced.fontSize
		end, 
		setFunc = function(arg)
			if (arg ~=  barchoiced.fontSize) then
				barchoiced.fontSize = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Text Color of attribute
		{
		type 	= "dropdown", 
		name 	= L.TextColor, 
		choices = {L.DefaultColor,  L.AttibuteColor}, 
		getFunc = function()
			if (barchoiced.textColor	== 'default' )then
				return L.DefaultColor
			elseif (barchoiced.textColor == 'attribute') then
				return L.AttibuteColor
			end
		end, 
		setFunc = function(arg)
			local ColorText
			if (arg	== L.DefaultColor) then
				ColorText = 'default'
			elseif (arg == L.AttibuteColor) then
				ColorText =  'attribute'
			end
			if (ColorText ~= barchoiced.textColor) then
				barchoiced.textColor = ColorText	
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
	}, 
	-- End of BARS SUBMENU
	}
-------------------------
-- VISUALATION OF EFFETCS
-------------------------
	optionsTable[#optionsTable + 1] = {
	type = "submenu", 
	name = CurvyHud.colorTable["titleColor"] .. L.ShowEffectsSubMenu, 
    controls = {
		{
		type = "description", 
		text = L.ShowMoveModeDesc, 
		}, 	
		-- Divider
		{
		type 	= "header", 
		name 	= CurvyHud.colorTable["divColor"] .. L.PhysicalInc, 
		},		
		-- Display or not Major Physical Inc effects
		{
		type 	= "checkbox", 
		name 	= L.Major,  
		getFunc = function()
			return cfg.effects.showMajPhysResistInc
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.effects.showMajPhysResistInc) then
				cfg.effects.showMajPhysResistInc = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Display or not Minor Physical Inc effects
		{
		type 	= "checkbox", 
		name 	= L.Minor,  
		getFunc = function()
			return cfg.effects.showMinPhysResistInc
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.effects.showMinPhysResistInc) then
				cfg.effects.showMinPhysResistInc = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Color of Increased physical resistance effect
		{
		type 	=	"colorpicker", 
		name 	= L.PhysResistIncColor,  
		getFunc = function()
			return unpack(cfg.effects.physResistIncColor)
		end, 
		setFunc = function(r, g, b, a)
			cfg.effects.physResistIncColor = {r, g, b, a}
			CurvyHud:BuildVisualizers()
			CurvyHud:InitializeState()
		end
		},
		-- Divider
		{
		type 	= "header", 
		name 	= CurvyHud.colorTable["divColor"] .. L.SpellInc,
		},
		-- Display or not Major Spell resist Inc effects
		{
		type 	= "checkbox", 
		name 	= L.Major,  
		getFunc = function()
			return cfg.effects.showMajSpellResistInc
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.effects.showMajSpellResistInc) then
				cfg.effects.showMajSpellResistInc = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Display or not Minor Spell resist Inc effects
		{
		type 	= "checkbox", 
		name 	= L.Minor,  
		getFunc = function()
			return cfg.effects.showMinSpellResistInc
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.effects.showMinSpellResistInc) then
				cfg.effects.showMinSpellResistInc = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Color of Increased magical resistance effect
		{
		type 	=	"colorpicker", 
		name 	= L.SpellResistIncColor,  
		getFunc = function()
			return unpack(cfg.effects.spellResistIncColor)
		end, 
		setFunc = function(r, g, b, a)
			cfg.effects.spellResistIncColor = {r, g, b, a}
			CurvyHud:BuildVisualizers()
			CurvyHud:InitializeState()
		end
		}, 
		-- Divider
		{
		type 	= "header", 
		name 	= CurvyHud.colorTable["divColor"] .. L.PhysicalDec,
		},
		-- Display or not Major Physical Dec effects
		{
		type 	= "checkbox", 
		name 	= L.Major,  
		getFunc = function()
			return cfg.effects.showMajPhysResistDec
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.effects.showMajPhysResistDec) then
				cfg.effects.showMajPhysResistDec = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Display or not Minor Physical Dec effects
		{
		type 	= "checkbox", 
		name 	= L.Minor,  
		getFunc = function()
			return cfg.effects.showMinPhysResistDec
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.effects.showMinPhysResistDec) then
				cfg.effects.showMinPhysResistDec = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Color of Decreased Physical resistance effect
		{
		type 	=	"colorpicker", 
		name 	= L.PhysResistDecColor,  
		getFunc = function()
			return unpack(cfg.effects.physResistDecColor)
		end, 
		setFunc = function(r, g, b, a)
			cfg.effects.physResistDecColor = {r, g, b, a}
			CurvyHud:BuildVisualizers()
			CurvyHud:InitializeState()
		end
		}, 
		-- Divider
		{
		type 	= "header", 
		name 	= CurvyHud.colorTable["divColor"] .. L.SpellDec,
		},
		-- Display or not Major Spell resist Dec effects
		{
		type 	= "checkbox", 
		name 	= L.Major,  
		getFunc = function()
			return cfg.effects.showMajSpellResistDec
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.effects.showMajSpellResistDec) then
				cfg.effects.showMajSpellResistDec = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Display or not Minor Spell resist Inc effects
		{
		type 	= "checkbox", 
		name 	= L.Minor,  
		getFunc = function()
			return cfg.effects.showMinSpellResistDec
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.effects.showMinSpellResistDec) then
				cfg.effects.showMinSpellResistDec = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Color of Decreased magical resistance effect
		{
		type 	=	"colorpicker", 
		name 	= L.SpellResistDecColor,  
		getFunc = function()
			return unpack(cfg.effects.spellResistDecColor)
		end, 
		setFunc = function(r, g, b, a)
			cfg.effects.spellResistDecColor = {r, g, b, a}
			CurvyHud:BuildVisualizers()
			CurvyHud:InitializeState()
		end
		},
		-- Divider
		{
		type 	= "header", 
		name 	= CurvyHud.colorTable["divColor"] .. L.PhysicalDual,
		},
		-- Display or not Major Physical resist Antinimics effects
		{
		type 	= "checkbox", 
		name 	= L.Major,  
		getFunc = function()
			return cfg.effects.showMajPhysResistDual
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.effects.showMajPhysResistDual) then
				cfg.effects.showMajPhysResistDual = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Display or not Minor Physical resist Antinimics effects
		{
		type 	= "checkbox", 
		name 	= L.Minor,  
		getFunc = function()
			return cfg.effects.showMinPhysResistDual
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.effects.showMinPhysResistDual) then
				cfg.effects.showMinPhysResistDual = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Color of physical resistance duality
		{
		type 	=	"colorpicker", 
		name 	= L.PhysResistDualColor,  
		getFunc = function()
			return unpack(cfg.effects.physResistDualColor)
		end, 
		setFunc = function(r, g, b, a)
			cfg.effects.physResistDualColor = {r, g, b, a}
			CurvyHud:BuildVisualizers()
			CurvyHud:InitializeState()
		end
		}, 
		-- Divider
		{
		type 	= "header", 
		name 	= CurvyHud.colorTable["divColor"] .. L.SpellDual,
		},
		-- Display or not Major Spell resist Antinimics effects
		{
		type 	= "checkbox", 
		name 	= L.Major,  
		getFunc = function()
			return cfg.effects.showMajSpellResistDual
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.effects.showMajSpellResistDual) then
				cfg.effects.showMajSpellResistDual = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Display or not Minor Spell resist Antinimics effects
		{
		type 	= "checkbox", 
		name 	= L.Minor,  
		getFunc = function()
			return cfg.effects.showMinSpellResistDual
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.effects.showMinSpellResistDual) then
				cfg.effects.showMinSpellResistDual = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Color of magical resistance duality
		{
		type 	=	"colorpicker", 
		name 	= L.SpellResistDualColor,  
		getFunc = function()
			return unpack(cfg.effects.spellResistDualColor)
		end, 
		setFunc = function(r, g, b, a)
			cfg.effects.spellResistDualColor = {r, g, b, a}
			CurvyHud:BuildVisualizers()
			CurvyHud:InitializeState()
		end
		},
	},
	-- End of VISUALATION OF EFFETCS subMenu
	}
----------------------------------------------------	
-- INCREASE / DECREASE RESISTANCES and TAUNT EFFECTS
----------------------------------------------------
	optionsTable[#optionsTable + 1] = {
	type = "submenu", 
	name = CurvyHud.colorTable["titleColor"] .. L.EffectsSettingsSubMenu, 
    controls = {
		-- Choice bar
		{
		type 	= "dropdown", 
		name 	= L.ChoiceUnit,  
		choices = {L.PlayerUnit, L.TargetUnit}, 
		getFunc = function() 
			return selectedUnitEffect
		end, 
		setFunc = function(arg)
			if (arg	== L.PlayerUnit) then
				selectedVisuals = cfg.visuals
			elseif (arg	== L.TargetUnit) then
				selectedVisuals = cfg.targetVisuals
			end
			if (arg ~= selectedUnitEffect) then
				selectedUnitEffect = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Divider
		{
		type 	= "divider", 
		}, 	
		-- Enable or not Major Inc effects
		{
		type 	= "checkbox", 
		name 	= L.MenuEnable .. L.MajorIncEffect,  
		getFunc = function()
			return selectedVisuals.majorEffect.incShow
		end, 
		setFunc = function(arg)
			if (arg ~= selectedVisuals.majorEffect.incShow) then
				selectedVisuals.majorEffect.incShow = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Enable or not Major Dec effects
		{
		type 	= "checkbox", 
		name 	= L.MenuEnable .. L.MajorDecEffect,  
		getFunc = function()
			return selectedVisuals.majorEffect.decShow
		end, 
		setFunc = function(arg)
			if (arg ~= selectedVisuals.majorEffect.decShow) then
				selectedVisuals.majorEffect.decShow = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Enable or not Minoir Inc effects
		{
		type 	= "checkbox", 
		name 	= L.MenuEnable .. L.MinorIncEffect,  
		getFunc = function()
			return selectedVisuals.minorEffect.incShow
		end, 
		setFunc = function(arg)
			if (arg ~= selectedVisuals.minorEffect.incShow) then
				selectedVisuals.minorEffect.incShow = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Enable or not Minor effects
		{
		type 	= "checkbox", 
		name 	= L.MenuEnable .. L.MinorDecEffect,  
		getFunc = function()
			return selectedVisuals.minorEffect.decShow
		end, 
		setFunc = function(arg)
			if (arg ~= selectedVisuals.minorEffect.decShow) then
				selectedVisuals.minorEffect.decShow = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Enable or not antinomic effects
		{
		type 	= "checkbox", 
		name 	= L.MenuEnable .. L.DualEffect, 
		tooltip = L.DualEffectTooltip,
		getFunc = function()
			return selectedVisuals.antinomic.show
		end, 
		setFunc = function(arg)
			if (arg ~= selectedVisuals.antinomic.show) then
				selectedVisuals.antinomic.show = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Divider
		{
		type = "divider", 
		}, 
		-- Divider
		{
		type = "header", 
		name = CurvyHud.colorTable["divColor"] .. L.TauntEffectDiv, 
		}, 
		-- Display or not Taunt
		{
		type 	= "checkbox", 
		name 	= L.MenuEnable,  
		getFunc = function()
			return cfg.targetVisuals.taunt.show
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.targetVisuals.taunt.show) then
				cfg.targetVisuals.taunt.show = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},
	}, 
	-- End of INCREASE / DECREASE RESISTANCES and TAUNT EFFECTS SUBMENU
	}
-----------------------------------	
-- REGEN / DEGEN and SHIELD EFFECTS
-----------------------------------
	optionsTable[#optionsTable + 1] = {
	type = "submenu", 
	name = CurvyHud.colorTable["titleColor"] .. L.VisualsSettingsSubMenu, 
    controls = {
		-- Choice bar
		{
		type 	= "dropdown", 
		name 	= L.ChoiceUnit,  
		choices = {L.PlayerUnit, L.TargetUnit}, 
		getFunc = function() 
			return selectedUnitEffect
		end, 
		setFunc = function(arg)
			if (arg	== L.PlayerUnit) then
				selectedVisuals = cfg.visuals
			elseif (arg	== L.TargetUnit) then
				selectedVisuals = cfg.targetVisuals
			end
			if (arg ~= selectedUnitEffect) then
				selectedUnitEffect = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Divider
		{
		type = "header", 
		name = CurvyHud.colorTable["divColor"] .. L.RegenDiv, 
		},
		-- Display REGEN/DEGEN
		{
		type 	= "checkbox", 
		name 	= L.MenuEnable,  
		getFunc = function()
			return selectedVisuals.regen.show
		end, 
		setFunc = function(arg)
			if (arg ~= selectedVisuals.regen.show) then
				selectedVisuals.regen.show = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Divider
		{
		type = "header", 
		name = CurvyHud.colorTable["divColor"] .. L.ShieldDiv, 
		}, 
		-- Display or not Shield
		{
		type 	= "checkbox", 
		name 	= L.MenuEnable,  
		getFunc = function()
			return selectedVisuals.shield.show
		end, 
		setFunc = function(arg)
			if (arg ~= selectedVisuals.shield.show) then
				selectedVisuals.shield.show = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Color of Shield
		{
		type 	=	"colorpicker", 
		name 	= L.ShieldColor,  
		getFunc = function()
			return unpack(selectedVisuals.shield.color)
		end, 
		setFunc = function(r, g, b, a)
			selectedVisuals.shield.color = {r, g, b, a}
			CurvyHud:BuildVisualizers()
			CurvyHud:InitializeState()
		end
		}, 
		-- Display or not Text SHIELD
		{
		type 	= "checkbox", 
		name 	= L.ShieldTextShow, 
		getFunc = function()
			return selectedVisuals.shield.showText
		end, 
		setFunc = function(arg)
			if (arg ~= selectedVisuals.shield.showText) then
				selectedVisuals.shield.showText = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- SHIELD Font
		{
		type 	= "dropdown",  
		name 	= L.Font, 
		choices = {"ProseAntique", "Skyrim Handwritten", "Trajan Pro", "Univers 55", "Univers 57", "Univers 67"}, 
		getFunc = function()
			return selectedVisuals.shield.fontName
		end, 
		setFunc = function(arg)
			local text
			if (arg == "ProseAntique") then
				text = "ProseAntique"
			elseif (arg == "Skyrim Handwritten") then
				text = "Skyrim Handwritten"
			elseif (arg == "Trajan Pro") then
				text = "Trajan Pro"
			elseif (arg == "Univers 55") then
				text = "Univers 55"
			elseif (arg == "Univers 57") then
				text = "Univers 57"
			elseif (arg == "Univers 67") then
				text = "Univers 67"
			end
			if (selectedVisuals.shield.fontName ~= text) then
				selectedVisuals.shield.fontName = text	
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- SHIELD Font Size
		{
		type  	= "slider", 
		name 	= L.FontSize,  
		min 	= 1, 
		max 	= 50, 
		step 	= 1, 
		getFunc = function() return selectedVisuals.shield.fontSize end, 
		setFunc = function(arg)
			if (arg ~=  selectedVisuals.shield.fontSize) then
				selectedVisuals.shield.fontSize = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- SHIELD Color
		{
		type 	= "colorpicker", 
		name 	= L.ShieldTextColor, 
		getFunc = function()
			return unpack(selectedVisuals.shield.textColor)
		end, 
		setFunc = function(r, g, b, a)
			selectedVisuals.shield.textColor = {r, g, b, a}
			CurvyHud:BuildVisualizers()
			CurvyHud:InitializeState()
		end
		}, 
	}, 
	-- End of REGEN / DEGEN and SHIELD EFFECTS SUBMENU
	}
----------------
-- COMBAT HELPER
----------------
	optionsTable[#optionsTable + 1] = {
	type = "submenu", 
	name = CurvyHud.colorTable["titleColor"] .. L.CombatHelperSubMenu, 
    controls = {
		-- Divider
		{
		type 	= "header", 
		name 	= CurvyHud.colorTable["divColor"] .. L.TipsDiv, 
		}, 
		-- Display or not Combat helper
		{
		type 	= 'checkbox', 
		name 	= L.MenuEnable, 
		tooltip = L.CombatTipsTooltip, 
		getFunc = function()
			return tips.show
		end, 
		setFunc = function(arg)
			if (arg ~= tips.show) then
				tips.show = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Display or not Zenimax icon
		{
		type 	= 'checkbox', 
		name 	= L.TipsZoTips, 
		getFunc = function()
			return tips.zoShow
		end, 
		setFunc = function(arg)
			if (arg ~= tips.zoShow) then
				tips.zoShow = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Font of combatTips
		{
		type 	= "dropdown",  
		name 	= L.Font, 
		choices = {"ProseAntique", "Skyrim Handwritten", "Trajan Pro", "Univers 55", "Univers 57", "Univers 67"}, 
		getFunc = function()
			return tips.fontName
		end, 
		setFunc = function(arg)
			local text
			if (arg == "ProseAntique") then
				text = "ProseAntique"
			elseif (arg == "Skyrim Handwritten") then
				text = "Skyrim Handwritten"
			elseif (arg == "Trajan Pro") then
				text = "Trajan Pro"
			elseif (arg == "Univers 55") then
				text = "Univers 55"
			elseif (arg == "Univers 57") then
				text = "Univers 57"
			elseif (arg == "Univers 67") then
				text = "Univers 67"
			end
			if (tips.fontName ~= text) then
				tips.fontName = text	
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Font Size of combatTips texts
		{
		type  	= "slider", 
		name 	= L.FontSize,  
		min 	= 20, 
		max 	= 60, 
		step 	=	1, 
		getFunc = function() return tips.fontSize end, 
		setFunc = function(arg)
			if (arg ~=  tips.fontSize) then
				tips.fontSize = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 	
		-- Choice color of block when it appear
		{
		type 	= "colorpicker", 
		name 	= L.TipsBloc, 
		getFunc = function()
			return unpack(tips.blockColor)
		end, 
		setFunc = function(r, g, b, a)
			tips.blockColor = {r, g, b, a}
			CurvyHud:BuildVisualizers()
			CurvyHud:InitializeState()
		end
		}, 
		-- Choice color of exploit when it appear		
		{
		type 	= "colorpicker", 
		name 	= L.TipsExploit, 
		getFunc = function()
			return unpack(tips.exploitColor)
		end, 
		setFunc = function(r, g, b, a)
			tips.exploitColor = {r, g, b, a}
			CurvyHud:BuildVisualizers()
			CurvyHud:InitializeState()
		end
		}, 
		-- Choice color of interrupt when it appear
		{
		type 	= "colorpicker", 
		name 	= L.TipsInterrupt, 
		getFunc = function()
			return unpack(tips.interruptColor)
		end, 
		setFunc = function(r, g, b, a)
			tips.interruptColor = {r, g, b, a}
			CurvyHud:BuildVisualizers()
			CurvyHud:InitializeState()
		end
		}, 
		-- Choice color of dodge when it appear
		{
		type 	= "colorpicker", 
		name 	= L.TipsDodge, 
		getFunc = function()
			return unpack(tips.dodgeColor)
		end, 
		setFunc = function(r, g, b, a)
			tips.dodgeColor = {r, g, b, a}
			CurvyHud:BuildVisualizers()
			CurvyHud:InitializeState()
		end
		},
		-- Divider
		{
		type 	= "header", 
		name 	= CurvyHud.colorTable["divColor"] .. L.LowAttribDiv, 
		}, 
		-- Display or not Low Attibut Alert
		{
		type 	= "checkbox", 
		name 	= L.MenuEnable, 
		getFunc = function()
			return lowAlert.show
		end, 
		setFunc = function(arg)
			if (arg ~= lowAlert.show) then
				lowAlert.show = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Trigger of low player attributs
		{
		type 	= "slider", 
		name 	= L.LowAttribTrigger,  
		min 	= 10, 
		max 	= 50, 
		step 	= 1, 
		getFunc = function() 
			return lowAlert.trigger 
		end, 
		setFunc = function(arg)
			if (arg ~= lowAlert.trigger) then
				lowAlert.trigger = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 	
		-- Font text of low player attributs
		{
		type 	= "dropdown",  
		name 	= L.Font, 
		choices = {"ProseAntique", "Skyrim Handwritten", "Trajan Pro", "Univers 55", "Univers 57", "Univers 67"}, 
		getFunc = function()
			return lowAlert.fontName
		end, 
		setFunc = function(arg)
			local text
			if (arg == "ProseAntique") then
				text = "ProseAntique"
			elseif (arg == "Skyrim Handwritten") then
				text = "Skyrim Handwritten"
			elseif (arg == "Trajan Pro") then
				text = "Trajan Pro"
			elseif (arg == "Univers 55") then
				text = "Univers 55"
			elseif (arg == "Univers 57") then
				text = "Univers 57"
			elseif (arg == "Univers 67") then
				text = "Univers 67"
			end
			if (lowAlert.fontName ~= text) then
				lowAlert.fontName = text	
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 	
		-- Font Size of low player attributs
		{
		type  	= "slider", 
		name 	= L.FontSize,  
		min 	= 20, 
		max 	= 60, 
		step 	=	1, 
		getFunc = function() 
			return lowAlert.fontSize 
		end, 
		setFunc = function(arg)
			if (arg ~= lowAlert.fontSize) then
				lowAlert.fontSize = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
	}, 
	-- End of Combat Helper
	}
----------------------------------
-- COMBAT STATE, COMPASS & RETICLE
----------------------------------
	optionsTable[#optionsTable + 1] = {
	type = "submenu", 
	name = CurvyHud.colorTable["titleColor"] .. L.CompassSubMenu, 
    controls = {
		-- Divider
		{
		type 	= "header", 
		name 	= CurvyHud.colorTable["divColor"] .. L.CombatStateDiv, 
		}, 
		-- Compass color
		{
		type 	= "checkbox", 
		name 	= L.CombatCompass, 
		tooltip = L.InfoTooltip,  
		getFunc = function()
			return comp.inCombat
		end, 
		setFunc = function(arg)
			if (arg ~= comp.inCombat) then
				comp.inCombat = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Reticle Alert color
		{
		type 	= "checkbox", 
		name 	= L.ReticleColorAlert, 
		tooltip = L.InfoTooltip,  
		getFunc = function()
			return reticle.inCombat
		end, 
		setFunc = function(arg)
			if (arg ~= reticle.inCombat) then
				reticle.inCombat = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Hight Visibility Color Compass in Combat state (inspired by PL_Combat_Indicator)
		{
		type 	= "checkbox", 
		name 	= L.CombatVisibility, 
		getFunc = function()
			return comp.colorVisibility
		end, 
		setFunc = function(arg)
			if (arg ~= comp.colorVisibility) then
				comp.colorVisibility = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Divider
		{
		type 	= "header", 
		name 	= CurvyHud.colorTable["divColor"] .. L.CompassDiv, 
		}, 
		-- Display or not Texture on compass for show
		{
		type 	= 'checkbox', 
		name 	= L.MenuEnable, 
		getFunc = function()
			return comp.show
		end, 
		setFunc = function(arg)
			if (arg ~= comp.show) then
				comp.show = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Display or not Texture of compass
		{
		type 	= 'checkbox', 
		name 	= L.CompassTexture, 
		getFunc = function()
			return comp.notexture
		end, 
		setFunc = function(arg)
			if (arg ~= comp.notexture) then
				comp.notexture = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Display or not Boss bar on compass
		{
		type 	= 'checkbox', 
		name 	= L.CompassBoss, 
		getFunc = function()
			return comp.boss
		end, 
		setFunc = function(arg)
			if (arg ~= comp.boss) then
				comp.boss = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Divider
		{
		type 	= "header", 
		name 	= CurvyHud.colorTable["divColor"] .. L.ReticleDiv, 
		},
		-- Show texture of Reticle
        {
		type 	= "dropdown", 
		name 	= L.ReticleTexture, 
		choices = {L.ReticleDefault, L.ReticleCurvyHUD}, 
		getFunc = function()
			if (reticle.textureConfig == "default") then
				return L.ReticleDefault
			elseif (reticle.textureConfig == "CurvyReticle") then
				return L.ReticleCurvyHUD
			end
		end, 
		setFunc = function(arg)
			local text
			if (arg == L.ReticleDefault) then
				text = "default"
			elseif (arg == L.ReticleCurvyHUD) then
				text = "CurvyReticle"
			end
			if (reticle.textureConfig ~= text) then
				reticle.textureConfig = text	
				CurvyHud:UpdateReticleColor(reticle.color)
				CurvyHud:InitializeState()
				CurvyHud:UpadteSightColor()
			end
		end
		}, 		
		-- Choice of color for reticle
		{
		type 	= "checkbox", 
		name 	= L.ReticleColor,
		tooltip = L.ReticleColorTooltip, 
		getFunc = function()
			return reticle.color
		end, 
		setFunc = function(arg)
			if (arg ~= reticle.color) then
				reticle.color = arg
				CurvyHud:UpadteSightColor()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Display or not text on reticle when you are hidden/discovered
		{
		type 	= "checkbox", 
		name 	= L.ReticleStealthText, 
		getFunc = function()
			return reticle.hidden
		end, 
		setFunc = function(arg)
			if (arg ~= reticle.hidden) then
				reticle.hidden = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()				
			end
		end
		}, 
	}, 
	-- End of SubMenu COMBAT STATE, COMPASS & RETICLE
	}
----------
-- ON CHAT
----------
	optionsTable[#optionsTable + 1] = {
	type = "submenu", 
	name = CurvyHud.colorTable["titleColor"] .. L.ChatSubMenu, 
    controls = {	
		-- Display message on chat when you are in/out combat
		{
		type 	= "checkbox", 
		name 	= L.CombatChat,  
		getFunc = function()
			return cfg.combatChatIndic
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.combatChatIndic) then
				cfg.combatChatIndic = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Display message on chat when you are covert state changed
		{
		type 	= "checkbox", 
		name 	= L.CovertChat,  
		getFunc = function()
			return cfg.covertChatIndic
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.covertChatIndic) then
				cfg.covertChatIndic = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Divider
		{
		type 	= "header", 
		name 	= CurvyHud.colorTable["divColor"] .. L.ChatDiv,
		},		
		-- Status guildmates display message on chat 
		{
		type 	= "checkbox", 
		name 	= L.MenuEnable,
		getFunc = function()
			return cfg.guildmatesChatIndic
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.guildmatesChatIndic) then
				cfg.guildmatesChatIndic = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Divider
		{
		type 	= "header", 
		},			
		-- Show G1 members status
		{
		type 	= "checkbox", 
		name 	= L.gOne..CurvyHud.state.initGone,  
		warning = L.GuildWarning,	
		getFunc = function()
			return cfg.guildOne
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.guildOne) then
				cfg.guildOne = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Show G2 members status
		{
		name 	= L.gTow..CurvyHud.state.initGtow, 
		warning = L.GuildWarning,		
		type 	= "checkbox", 
		getFunc = function()
			return cfg.guildTow
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.guildTow) then
				cfg.guildTow = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Show G3 members status
		{
		type 	= "checkbox", 
		name 	= L.gThree..CurvyHud.state.initGthree, 
		warning = L.GuildWarning,
		getFunc = function()
			return cfg.guildThree
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.guildThree) then
				cfg.guildThree = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Show G4 members status
		{
		type 	= "checkbox", 
		name 	= L.gFour..CurvyHud.state.initGfour,
		warning = L.GuildWarning,		
		getFunc = function()
			return cfg.guildFour
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.guildFour) then
				cfg.guildFour = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Show G5 members status
		{
		type 	= "checkbox", 
		name 	= L.gFive..CurvyHud.state.initGfive,
		warning = L.GuildWarning,		
		getFunc = function()
			return cfg.guildFive
		end, 
		setFunc = function(arg)
			if (arg ~= cfg.guildFive) then
				cfg.guildFive = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},		
	},
	-- end of submenu GuildMates Status
	}
-------------
-- CLEPSYDRE
-------------
	optionsTable[#optionsTable + 1] = {
	type = "submenu", 
	name = CurvyHud.colorTable["titleColor"] .. L.ClepsydreSubMenu, 
    controls = {
		-- Display or not Clepsydre
		{
		type 	= "checkbox", 
		name 	= L.MenuEnable, 
		tooltip = L.ClepsydreShowTooltip,  
		getFunc = function()
			return cleps.show
		end, 
		setFunc = function(arg)
			if (arg ~= cleps.show) then
				cleps.show = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
				CurvyHud:InitializeClepsydre()
			end
		end
		},
		-- font size of Clepsydre
        {
		type 	= "slider", 
		name 	= L.FontSize,  
		min 	= 15, 
		max 	= 35, 
		step 	= 1, 
		getFunc = function() return cleps.fontSize end, 
		setFunc = function(arg)
			if (arg ~=  cleps.fontSize) then
				cleps.fontSize = arg
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
		-- Style font of Clepsydre
        {
		type 	= "dropdown", 
		name 	= L.Font, 
		choices = {"ProseAntique", "Skyrim Handwritten", "Trajan Pro", "Univers 55", "Univers 57", "Univers 67"}, 
		getFunc = function()
			return cleps.fontName
		end, 
		setFunc = function(arg)
			local text
			if (arg == "ProseAntique") then
				text = "ProseAntique"
			elseif (arg == "Skyrim Handwritten") then
				text = "Skyrim Handwritten"
			elseif (arg == "Trajan Pro") then
				text = "Trajan Pro"
			elseif (arg == "Univers 55") then
				text = "Univers 55"
			elseif (arg == "Univers 57") then
				text = "Univers 57"
			elseif (arg == "Univers 67") then
				text = "Univers 67"
			end
			if (cleps.fontName ~= text) then
				cleps.fontName = text	
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		},
		-- Color of Clepsydre
        {
		type 	=	"colorpicker", 
		name 	= L.ClepsydreColor,  
		getFunc = function()
			return unpack(cleps.color)
		end, 
		setFunc = function(r, g, b, a)
			cleps.color = {r, g, b, a}
			CurvyHud:BuildVisualizers()
			CurvyHud:InitializeState()
		end
		},
		-- Opacity of Clapsydre
		{
		type 	= "slider", 
		name 	= L.ClepdyreOpacity,  
		min 	= 0, 
		max 	= 100, 
		step 	= 1, 
		getFunc = function() 
			return cleps.alpha * 100 
		end, 
		setFunc = function(arg)
			if (arg / 100 ~=  cfg.oocAlpha) then
				cleps.alpha = arg / 100
				CurvyHud:BuildVisualizers()
				CurvyHud:InitializeState()
			end
		end
		}, 
	}, 
	-- End of Sub Menu CURVYCLOCK
	}
------------------
-- ACKNOWLEDGEMENT
------------------	
	-- Divider
	optionsTable[#optionsTable + 1] = {
	type = "header", 
    name = CurvyHud.colorTable["titleColor"] .. L.AcknowledgmentDiv, 
    }
	optionsTable[#optionsTable + 1] = {
    type = "description", 
    text = L.AcknowledgmentAuthor, 
    }
	optionsTable[#optionsTable + 1] = {
	type = "submenu", 
	name = CurvyHud.colorTable["titleColor"] .. L.AcknowledgmentSubMenu, 
	controls = {
		-- Thank to
		{
		type 	= "description", 
		text 	= L.AcknowledgmentThank,
		}, 
		-- Description
		{
		type 	= "description", 
		text 	= L.AcknowledgmentText,
		}, 
		-- Description 2
		{
		type 	= "description", 
		text 	= L.AcknowledgmentTextTwo,
		},
		-- Description 3
		{
		type 	= "description", 
		text 	= L.AcknowledgmentTextThree,
		},
		-- Description 4
		{
		type 	= "description", 
		text 	= L.AcknowledgmentTextFour,
		},		
	}, 
	-- End of Sub Menu ACKNOWLEDGEMENT
	} 
-------------
-- TROLL TEXT
-------------
	-- Troll text header
    optionsTable[#optionsTable + 1] = {
    type 	= "header", 
    name 	= CurvyHud.colorTable["divColor"] .. L.TrollEnable, 
    }
	-- Display or not Troll text
	optionsTable[#optionsTable + 1] = {
	type 	= "checkbox", 
	name 	= L.MenuEnable,
	getFunc = function()
		return cfg.troll
	end, 
	setFunc = function(arg)
		if (arg ~= cfg.troll) then
			cfg.troll = arg
			CurvyHud:BuildVisualizers()
			CurvyHud:InitializeState()
			CurvyHud:InitializeClepsydre()
		end
	end
	}
	-- Logo separation
    optionsTable[#optionsTable + 1] = {
    type 	= "header", 
    name 	= ""
    }
------ LOGO -----	
    optionsTable[#optionsTable + 1] = {
        type 	= "texture", 
        image 	= CurvyHud.name .. "/textures/icons/logo.dds", 
        imageWidth 	= 128, 	
        imageHeight = 64, 
    }

-- End of Menu

	LAM:RegisterOptionControls	("CurvyHudpanel", 	optionsTable)
end