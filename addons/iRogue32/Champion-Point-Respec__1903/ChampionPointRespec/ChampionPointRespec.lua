
local CPR2 = ChampionPointRespecV2 or {}

CPR2.name = "ChampionPointRespec"
CPR2.variableVersion = 1
CPR2.configSelected = 0
CPR2.aspectSelected = 1
CPR2.HEALTH_ASPECT = 1
CPR2.MAGICKA_ASPECT = 2
CPR2.STAMINA_ASPECT = 3

CPR2.Default = {

	["specs"] = {}, 

	["ui"] = {
		["offsetX"] = -5,
		["offsetY"] = 5,
		["point"] = TOPRIGHT,
		["relPoint"] = TOPRIGHT
	},
	
	["convertFromOldSavedVariables"] = true,
	["displayWarning"] = true,
	["openUIWithCPWindow"] = true
}

-- saves cp hash to saved variables
function CPR2.saveCPHash(name, h)
	if not CPR2.IsValidName(name) then
		return CPR2.NotValidName(name)
	end
	if h == nil then 
		h = CPR2.createCPHash()
	end
	table.insert(CPR2.savedVariables.specs, {name = name, hash = h})
	CPR2.PopulateDropdown()
	CPR2.SetSelectedConfig(name)
end

-- checks if config name is already in use
function CPR2.IsValidName(name)
	for k, v in pairs (CPR2.savedVariables.specs) do
		if v.name == name then
			return false
		end
	end
	return true
end

function CPR2.NotValidName(name)
	d(name.." already exists. Please enter a unique name.")
end

-- returns hash of currently spent CP
function CPR2.createCPHash(input)
	local hash = ""
	for discipline = 1, GetNumChampionDisciplines() do
		for skill = 1, GetNumChampionDisciplineSkills() - 4 do																								
			hash = hash..CPR2.GetBase64(GetNumPointsSpentOnChampionSkill(discipline, skill))
		end
	end
	return hash
end

-- loads CP from hash in saved variables
function CPR2.LoadCPFromHash(input)
	CPR2.resetCP()
	local hash = CPR2.savedVariables.specs[CPR2.configSelected].hash
	local counter = 1
	for discipline = 1, GetNumChampionDisciplines() do
		for skill = 1, GetNumChampionDisciplineSkills() - 4 do																								
			SetNumPendingChampionPoints(discipline, skill, CPR2.GetBase10(string.sub(hash, counter, counter + 1)))
			counter = counter + 2
		end
	end
	SpendPendingChampionPoints()
end

-- clears all spent and pending CP
function CPR2.resetCP()
	SetChampionIsInRespecMode(true)
	ClearPendingChampionPoints()
end

-- deletes hash from saved variables by name
function CPR2.DeleteCPHash(input) 
	table.remove(CPR2.savedVariables.specs, CPR2.configSelected)
	CPR2.SetSelectedConfig(nil)
	CPR2.PopulateDropdown()
	CPR2.UpdateUI()
end

function CPR2.LoadCPConfigFromName(input)
	for k, v in pairs (CPR2.savedVariables.specs) do
		if v.name == input then
			CPR2.configSelected = k
			CPR2.LoadCPConfiguration()
			CPR2.UpdateUI()
			return
		end
	end
	d("Please enter a valid name in the format: /cpr <name>")
end

function CPR2.LoadCPConfiguration()
	if CPR2.savedVariables["displayWarning"] then
		CPR2.DisplayLoadCPFromHashDialog()
	else 
		CPR2.LoadCPFromHash()
	end
end

--prints sv to chat
function CPR2.PrintSV()
	for k, v in pairs(CPR2.savedVariables.specs) do
		d(v.name)
	end
end

function CPR2.DisplayCreateNewConfigDialog()
	ZO_Dialogs_ShowDialog("CPR2_SAVE_CONFIG", nil, nil);
end

function CPR2.DisplayImportConfigDialog()
	ZO_Dialogs_ShowDialog("CPR2_IMPORT_CONFIG", nil, nil);
end

function CPR2.DisplaySaveCurrentConfigDialog()
	ZO_Dialogs_ShowDialog("CPR2_SAVE_CURRENT_CONFIG", nil, nil);
end

function CPR2.DisplayLoadCPFromHashDialog()
	ZO_Dialogs_ShowDialog("CPR2_CHAMPION_CONFIRM_COST", nil, { mainTextParams = { GetChampionRespecCost(), ZO_Currency_GetPlatformFormattedGoldIcon() } });
end

function CPR2.OverwriteConfig(config)
	local hash = CPR2.createCPHash()
	CPR2.savedVariables.specs[config].hash = hash
	CPR2.configSelected = config
	CPR2.PopulateDropdown()
	CPR2.UpdateUI()
	OverwriteWindow:SetHidden(true)
end

function CPR2.SetSelectedConfig(name)
	--d(name)
	if name == nil then
		CPR2.configSelected = 0
		CPR2.UpdateUI()
		return
	end
	ChampPointRespecWindow1ConfigSelectorPanel:SetHidden(true)
	for k, v in pairs (CPR2.savedVariables.specs) do
		if name == v.name then
			CPR2.configSelected = k
		end
	end
	CPR2.UpdateUI()
end

function CPR2.ToggleDropdown()
	CPR2.PopulateDropdown()
	if ChampPointRespecWindow1ConfigSelectorPanel:IsHidden() then
		ChampPointRespecWindow1ConfigSelectorPanel:SetHidden(false)
	else
		ChampPointRespecWindow1ConfigSelectorPanel:SetHidden(true)
	end
end

function CPR2.PopulateDropdown()
	local numConfigs = 0
	for k, v in pairs (CPR2.savedVariables.specs) do
		local button = WINDOW_MANAGER:GetControlByName("ChampPointRespecWindow1ConfigSelectorPanelScrollChildButton"..k)
		if not button then
			button = WINDOW_MANAGER:CreateControl("ChampPointRespecWindow1ConfigSelectorPanelScrollChildButton"..k, ChampPointRespecWindow1ConfigSelectorPanelScrollChild, CT_BUTTON)
			button:SetAnchor(TOPLEFT, ChampPointRespecWindow1ConfigSelectorPanelScrollChild, TOPLEFT, 8, 5 + (k - 1) * 22)
			button:SetDimensions(280, 22)
			button:SetText(v.name)
			button:SetFont("ZoFontWinH4")
			button:SetHorizontalAlignment(0)
			button:SetVerticalAlignment(1)
			button:SetClickSound("Click")
			button:SetNormalFontColor(1.0,1.0,1.0,1)
			button:SetMouseOverFontColor(0.91,0.875,0.686,1)
			button:SetHandler("OnMouseDown", function() CPR2.SetSelectedConfig(v.name) end)
		else 
			button:SetText(v.name)
			button:SetHandler("OnMouseDown", function() CPR2.SetSelectedConfig(v.name) end)
		end
		numConfigs = numConfigs + 1
	end
	local control = WINDOW_MANAGER:GetControlByName("ChampPointRespecWindow1ConfigSelectorPanelScrollChild")
	local numChild = control:GetNumChildren()
	if numChild > numConfigs then 
		for i = numConfigs + 1, numChild, 1 do
			local button = WINDOW_MANAGER:GetControlByName("ChampPointRespecWindow1ConfigSelectorPanelScrollChildButton"..i)
			button:SetHidden(true)
		end
	end
	ChampPointRespecWindow1ConfigSelectorPanelScrollChild:SetHeight(#CPR2.savedVariables.specs * 22 + 10)
end

function CPR2.PopulateOverwriteDropdown()
	local numConfigs = 0
	for k, v in pairs (CPR2.savedVariables.specs) do
		local button = WINDOW_MANAGER:GetControlByName("OverwriteWindowSelectorScrollChildButton"..k)
		if not button then
			button = WINDOW_MANAGER:CreateControl("OverwriteWindowSelectorScrollChildButton"..k, OverwriteWindowSelectorScrollChild, CT_BUTTON)
			button:SetAnchor(TOPLEFT, OverwriteWindowSelectorPanelScrollChild, TOPLEFT, 8, 5 + (k - 1) * 22)
			button:SetDimensions(280, 22)
			button:SetText(v.name)
			button:SetFont("ZoFontWinH4")
			button:SetHorizontalAlignment(0)
			button:SetVerticalAlignment(1)
			button:SetClickSound("Click")
			button:SetNormalFontColor(1.0,1.0,1.0,1)
			button:SetMouseOverFontColor(0.91,0.875,0.686,1)
			button:SetHandler("OnMouseDown", function() CPR2.OverwriteConfig(k) end)
		else 
			button:SetText(v.name)
		end
		numConfigs = numConfigs + 1
	end
	local control = WINDOW_MANAGER:GetControlByName("OverwriteWindowSelectorScrollChild")
	local numChild = control:GetNumChildren()
	if numChild > numConfigs then 
		for i = numConfigs + 1, numChild, 1 do
			local button = WINDOW_MANAGER:GetControlByName("OverwriteWindowSelectorPanelScrollChildButton"..i)
			button:SetHidden(true)
		end
	end
	OverwriteWindowSelectorScrollChild:SetHeight(#CPR2.savedVariables.specs * 22 + 10)
end

function CPR2.UpdateAspectSelected(aspect)
	if aspect == CPR2.HEALTH_ASPECT then
		CPR2.aspectSelected = 1
		CPR2.UpdateUI()
	end
	if aspect == CPR2.MAGICKA_ASPECT then
		CPR2.aspectSelected = 2
		CPR2.UpdateUI()
	end
	if aspect == CPR2.STAMINA_ASPECT then
		CPR2.aspectSelected = 3
		CPR2.UpdateUI()
	end
end

function CPR2.UpdateUI()
	if CPR2.configSelected == 0 then
		ChampPointRespecWindow1ConfigSelector:SetText("Select CP Configuration")
		ChampPointRespecWindow1LoadProfileBGLoadConfigButton:SetEnabled(false)
		ChampPointRespecWindow1LoadProfileBGDeleteConfigButton:SetEnabled(false)
		ChampPointRespecWindow1ImportExportBGExportButton:SetEnabled(false)
		ChampPointRespecWindow1ImportExportBGExportButton:SetEnabled(false)
	end
	if CPR2.configSelected > 0 then 
		ChampPointRespecWindow1ConfigSelector:SetText(CPR2.savedVariables.specs[CPR2.configSelected].name)
		ChampPointRespecWindow1LoadProfileBGLoadConfigButton:SetEnabled(true)
		ChampPointRespecWindow1LoadProfileBGDeleteConfigButton:SetEnabled(true)
		ChampPointRespecWindow1ImportExportBGExportButton:SetEnabled(true)
		ChampPointRespecWindow1ImportExportBGExportButton:SetEnabled(true)
	end
	
	if CPR2.aspectSelected == CPR2.HEALTH_ASPECT then
		ChampPointRespecWindow1BG:SetEdgeColor(0.894, 0.427 ,0.192, 1.0)
		ChampPointRespecWindow1WarriorBG:SetHidden(false)
		ChampPointRespecWindow1MageBG:SetHidden(true)
		ChampPointRespecWindow1ThiefBG:SetHidden(true)
		ChampPointRespecWindow1CPDisplayButton1:SetAlpha(1.0)
		ChampPointRespecWindow1CPDisplayButton2:SetAlpha(0.5)
		ChampPointRespecWindow1CPDisplayButton3:SetAlpha(0.5)
	end
	if CPR2.aspectSelected == CPR2.MAGICKA_ASPECT then
		ChampPointRespecWindow1BG:SetEdgeColor(0.42, 0.78 ,0.937, 1.0)
		ChampPointRespecWindow1WarriorBG:SetHidden(true)
		ChampPointRespecWindow1MageBG:SetHidden(false)
		ChampPointRespecWindow1ThiefBG:SetHidden(true)
		ChampPointRespecWindow1CPDisplayButton1:SetAlpha(0.5)
		ChampPointRespecWindow1CPDisplayButton2:SetAlpha(1.0)
		ChampPointRespecWindow1CPDisplayButton3:SetAlpha(0.5)
	end
	if CPR2.aspectSelected == CPR2.STAMINA_ASPECT then
		ChampPointRespecWindow1BG:SetEdgeColor(0.647, 0.843 ,0.322, 1.0)
		ChampPointRespecWindow1WarriorBG:SetHidden(true)
		ChampPointRespecWindow1MageBG:SetHidden(true)
		ChampPointRespecWindow1ThiefBG:SetHidden(false)
		ChampPointRespecWindow1CPDisplayButton1:SetAlpha(0.5)
		ChampPointRespecWindow1CPDisplayButton2:SetAlpha(0.5)
		ChampPointRespecWindow1CPDisplayButton3:SetAlpha(1.0)
	end
	
	-- UPDATE UI CP VALUES --
	if CPR2.configSelected > 0 then 
		local hash = CPR2.savedVariables.specs[CPR2.configSelected].hash
		local counter = 0
	
		ChampPointRespecWindow1ThiefBGColumn1Tower1:SetText(GetChampionSkillName(1, 1)..": "..CPR2.GetBase10(string.sub(hash, 1, 2)))
		ChampPointRespecWindow1ThiefBGColumn1Tower2:SetText(GetChampionSkillName(1, 2)..": "..CPR2.GetBase10(string.sub(hash, 3, 4)))
		ChampPointRespecWindow1ThiefBGColumn1Tower3:SetText(GetChampionSkillName(1, 3)..": "..CPR2.GetBase10(string.sub(hash, 5, 6)))
		ChampPointRespecWindow1ThiefBGColumn1Tower4:SetText(GetChampionSkillName(1, 4)..": "..CPR2.GetBase10(string.sub(hash, 7, 8)))
		
		ChampPointRespecWindow1WarriorBGColumn3Lord1:SetText(GetChampionSkillName(2, 1)..": "..CPR2.GetBase10(string.sub(hash, 9, 10)))
		ChampPointRespecWindow1WarriorBGColumn3Lord2:SetText(GetChampionSkillName(2, 2)..": "..CPR2.GetBase10(string.sub(hash, 11, 12)))
		ChampPointRespecWindow1WarriorBGColumn3Lord3:SetText(GetChampionSkillName(2, 3)..": "..CPR2.GetBase10(string.sub(hash, 13, 14)))
		ChampPointRespecWindow1WarriorBGColumn3Lord4:SetText(GetChampionSkillName(2, 4)..": "..CPR2.GetBase10(string.sub(hash, 15, 16)))
		
		ChampPointRespecWindow1WarriorBGColumn2Lady1:SetText(GetChampionSkillName(3, 1)..": "..CPR2.GetBase10(string.sub(hash, 17, 18)))
		ChampPointRespecWindow1WarriorBGColumn2Lady2:SetText(GetChampionSkillName(3, 2)..": "..CPR2.GetBase10(string.sub(hash, 19, 20)))
		ChampPointRespecWindow1WarriorBGColumn2Lady3:SetText(GetChampionSkillName(3, 3)..": "..CPR2.GetBase10(string.sub(hash, 21, 22)))
		ChampPointRespecWindow1WarriorBGColumn2Lady4:SetText(GetChampionSkillName(3, 4)..": "..CPR2.GetBase10(string.sub(hash, 23, 24)))
		
		ChampPointRespecWindow1WarriorBGColumn1Steed1:SetText(GetChampionSkillName(4, 1)..": "..CPR2.GetBase10(string.sub(hash, 25, 26)))
		ChampPointRespecWindow1WarriorBGColumn1Steed2:SetText(GetChampionSkillName(4, 2)..": "..CPR2.GetBase10(string.sub(hash, 27, 28)))
		ChampPointRespecWindow1WarriorBGColumn1Steed3:SetText(GetChampionSkillName(4, 3)..": "..CPR2.GetBase10(string.sub(hash, 29, 30)))
		ChampPointRespecWindow1WarriorBGColumn1Steed4:SetText(GetChampionSkillName(4, 4)..": "..CPR2.GetBase10(string.sub(hash, 31, 32)))
		
		ChampPointRespecWindow1MageBGColumn3Ritual1:SetText(GetChampionSkillName(5, 1)..": "..CPR2.GetBase10(string.sub(hash, 33, 34)))
		ChampPointRespecWindow1MageBGColumn3Ritual2:SetText(GetChampionSkillName(5, 2)..": "..CPR2.GetBase10(string.sub(hash, 35, 36)))
		ChampPointRespecWindow1MageBGColumn3Ritual3:SetText(GetChampionSkillName(5, 3)..": "..CPR2.GetBase10(string.sub(hash, 37, 38)))
		ChampPointRespecWindow1MageBGColumn3Ritual4:SetText(GetChampionSkillName(5, 4)..": "..CPR2.GetBase10(string.sub(hash, 39, 40)))
		
		ChampPointRespecWindow1MageBGColumn3Ritual1:SetText(GetChampionSkillName(5, 1)..": "..CPR2.GetBase10(string.sub(hash, 33, 34)))
		ChampPointRespecWindow1MageBGColumn3Ritual2:SetText(GetChampionSkillName(5, 2)..": "..CPR2.GetBase10(string.sub(hash, 35, 36)))
		ChampPointRespecWindow1MageBGColumn3Ritual3:SetText(GetChampionSkillName(5, 3)..": "..CPR2.GetBase10(string.sub(hash, 37, 38)))
		ChampPointRespecWindow1MageBGColumn3Ritual4:SetText(GetChampionSkillName(5, 4)..": "..CPR2.GetBase10(string.sub(hash, 39, 40)))
		
		ChampPointRespecWindow1MageBGColumn2Atronach1:SetText(GetChampionSkillName(6, 1)..": "..CPR2.GetBase10(string.sub(hash, 41, 42)))
		ChampPointRespecWindow1MageBGColumn2Atronach2:SetText(GetChampionSkillName(6, 2)..": "..CPR2.GetBase10(string.sub(hash, 43, 44)))
		ChampPointRespecWindow1MageBGColumn2Atronach3:SetText(GetChampionSkillName(6, 3)..": "..CPR2.GetBase10(string.sub(hash, 45, 46)))
		ChampPointRespecWindow1MageBGColumn2Atronach4:SetText(GetChampionSkillName(6, 4)..": "..CPR2.GetBase10(string.sub(hash, 47, 48)))
		
		ChampPointRespecWindow1MageBGColumn1Apprentice1:SetText(GetChampionSkillName(7, 1)..": "..CPR2.GetBase10(string.sub(hash, 49, 50)))
		ChampPointRespecWindow1MageBGColumn1Apprentice2:SetText(GetChampionSkillName(7, 2)..": "..CPR2.GetBase10(string.sub(hash, 51, 52)))
		ChampPointRespecWindow1MageBGColumn1Apprentice3:SetText(GetChampionSkillName(7, 3)..": "..CPR2.GetBase10(string.sub(hash, 53, 54)))
		ChampPointRespecWindow1MageBGColumn1Apprentice4:SetText(GetChampionSkillName(7, 4)..": "..CPR2.GetBase10(string.sub(hash, 55, 56)))
		
		ChampPointRespecWindow1ThiefBGColumn3Shadow1:SetText(GetChampionSkillName(8, 1)..": "..CPR2.GetBase10(string.sub(hash, 57,58)))
		ChampPointRespecWindow1ThiefBGColumn3Shadow2:SetText(GetChampionSkillName(8, 2)..": "..CPR2.GetBase10(string.sub(hash,59, 60)))
		ChampPointRespecWindow1ThiefBGColumn3Shadow3:SetText(GetChampionSkillName(8, 3)..": "..CPR2.GetBase10(string.sub(hash, 61, 62)))
		ChampPointRespecWindow1ThiefBGColumn3Shadow4:SetText(GetChampionSkillName(8, 4)..": "..CPR2.GetBase10(string.sub(hash, 63, 64)))
		
		ChampPointRespecWindow1ThiefBGColumn2Lover1:SetText(GetChampionSkillName(9, 1)..": "..CPR2.GetBase10(string.sub(hash, 65,66)))
		ChampPointRespecWindow1ThiefBGColumn2Lover2:SetText(GetChampionSkillName(9, 2)..": "..CPR2.GetBase10(string.sub(hash,67, 68)))
		ChampPointRespecWindow1ThiefBGColumn2Lover3:SetText(GetChampionSkillName(9, 3)..": "..CPR2.GetBase10(string.sub(hash, 69, 70)))
		ChampPointRespecWindow1ThiefBGColumn2Lover4:SetText(GetChampionSkillName(9, 4)..": "..CPR2.GetBase10(string.sub(hash, 71, 72)))
		
	end
	
end

-- toggles UI window --
function CPR2.toggleCPRUI() 
	ChampPointRespecWindow1:ToggleHidden()
	if not CHAMPION_PERKS_SCENE:IsShowing() then
		SetGameCameraUIMode(not ChampPointRespecWindow1:IsHidden())
	end
end

function CPR2.DisplayOverwriteWindow()
	OverwriteWindow:SetHidden(false) 
	CPR2.PopulateOverwriteDropdown() 
	SetGameCameraUIMode(true)
end

function CPR2.savePositions(self)
	local valid, point, _, relPoint, offsetX, offsetY = self:GetAnchor(0)
	if valid then
		CPR2.savedVariables.ui.point = point
		CPR2.savedVariables.ui.relPoint = relPoint
		CPR2.savedVariables.ui.offsetX = offsetX
		CPR2.savedVariables.ui.offsetY = offsetY
	end
end

function CPR2.CreateHashFromOldSV(num)
	local hash = ""
	for discipline = 1, GetNumChampionDisciplines() do
		for skill = 1, GetNumChampionDisciplineSkills() - 4 do																								
			hash = hash..CPR2.GetBase64(CPR2.oldSavedVariables[num][discipline][skill])
		end
	end
	return hash
end

function CPR2.ConvertOldSavedVariables()
	d("converting old sv")
	if CPR2.oldSavedVariables[1] ~= nil then
		for i = 1, 10 do
			local h = CPR2.CreateHashFromOldSV(i)
			if h ~= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" then
				table.insert(CPR2.savedVariables.specs, {name = CPR2.oldSavedVariables[11][i], hash = h})
				CPR2.PopulateDropdown()
			end
		end
	end
	CPR2.savedVariables.convertFromOldSavedVariables = false
end

function CPR2.WhyZOS()
	d("why zos?")
	zo_callLater(function () CPR2.DisplayCreateNewConfigDialog() end, 100)
end

function CPR2:Initialize()
	CPR2.savedVariables = ZO_SavedVars:New("CPR2", CPR2.variableVersion, nil, CPR2.Default)
	CPR2.oldSavedVariables = ZO_SavedVars:New("ChampionPointRespec_sv", CPR2.variableVersion, nil, nil)
	if CPR2.savedVariables.convertFromOldSavedVariables then
		CPR2.ConvertOldSavedVariables()
	end
	
	-- INITIALIZE DIALOGUE CONFIRMATION (from ingame/championperks/championperks.lua) --
	
	local customControl = ZO_ChampionRespecConfirmationDialog
	
	ZO_Dialogs_RegisterCustomDialog("CPR2_CHAMPION_CONFIRM_COST",
    {
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        customControl = customControl,
        title =
        {
            text = SI_CHAMPION_DIALOG_CONFIRM_CHANGES_TITLE,
        },
        mainText =
        {
            text = zo_strformat(SI_CHAMPION_DIALOG_CONFIRM_POINT_COST),
        },
        setup = function(dialog)
            if SCENE_MANAGER:IsCurrentSceneGamepad() then
                local gamepadGoldIconMarkup =  ZO_Currency_GetGamepadFormattedCurrencyIcon(CURT_MONEY)
                gamepadData.data1.value = zo_strformat(SI_CHAMPION_RESPEC_CURRENCY_FORMAT, ZO_CommaDelimitNumber(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)), gamepadGoldIconMarkup)
                gamepadData.data2.value = zo_strformat(SI_CHAMPION_RESPEC_CURRENCY_FORMAT, ZO_CommaDelimitNumber(GetChampionRespecCost()), gamepadGoldIconMarkup)
                dialog.setupFunc(dialog, gamepadData)
            else
                ZO_CurrencyControl_SetSimpleCurrency(customControl:GetNamedChild("BalanceAmount"), CURT_MONEY,  GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER))
                ZO_CurrencyControl_SetSimpleCurrency(customControl:GetNamedChild("RespecCost"), CURT_MONEY,  GetChampionRespecCost())
            end
        end,
        buttons =
        {
            {
                control = customControl:GetNamedChild("Confirm"),
                text = SI_DIALOG_CONFIRM,
                callback = function()
                                CPR2.LoadCPFromHash(name)
                            end,
            },
            {
                control = customControl:GetNamedChild("Cancel"),
                text = SI_DIALOG_CANCEL,
            }
        }
    })
	
	-- INITIALIZE SAVE CURRENT CONFIG DIALOGUE --
	
	ZO_Dialogs_RegisterCustomDialog("CPR2_SAVE_CURRENT_CONFIG",
	{
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title = {
            text = "Save Current CP Configuration",
        },
        mainText = {
            text = "Create a new configuration or overwrite and existing one?",
        },
        buttons = {
            {
                text = "Create New",
                callback = function() zo_callLater(function () CPR2.DisplayCreateNewConfigDialog() end, 100)
                end,
            },
            {
                text = "Overwrite Existing",
                callback = function() zo_callLater(function () CPR2.DisplayOverwriteWindow() end,100)
                end,
            }
        }
    })
	
	-- INITIALIZE CREATE NEW CONFIG DIALOGE --
	
	ZO_Dialogs_RegisterCustomDialog("CPR2_SAVE_CONFIG",
	{
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title = {
            text = "Create New Configuration",
        },
        mainText = {
            text = "Enter a name: ",
        },
		editBox = { defaultText = ""
			
		},
        buttons = {
            {
                text = SI_DIALOG_CONFIRM,
                callback = function(dialog) CPR2.saveCPHash(ZO_Dialogs_GetEditBoxText(dialog), nil)
                end,
            },
            {
                text = SI_DIALOG_CANCEL,
                callback = function() 
                end,
            }
        }
    })
	
	-- INITIALIZE IMPORT CONFIG DIALOGE --
	
	ZO_Dialogs_RegisterCustomDialog("CPR2_IMPORT_CONFIG",
	{
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title = {
            text = "Import Configuration",
        },
        mainText = {
            text = "Enter a valid config hash: ",
        },
		editBox = { defaultText = ""
			
		},
        buttons = {
            {
                text = SI_DIALOG_CONFIRM,
                callback = function(dialog) CPR2.ImportHash(ZO_Dialogs_GetEditBoxText(dialog))
                end,
            },
            {
                text = SI_DIALOG_CANCEL,
                callback = function() 
                end,
            }
        }
    })
	
	-- INITIALIZE IMPORT CONFIG NAME DIALOGE --
	
	ZO_Dialogs_RegisterCustomDialog("CPR2_IMPORT_CONFIG_NAME",
	{
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title = {
            text = "Import Configuration",
        },
        mainText = {
            text = "Enter a name: ",
        },
		editBox = { defaultText = ""
			
		},
        buttons = {
            {
                text = SI_DIALOG_CONFIRM,
                callback = function(dialog) CPR2.saveCPHash(ZO_Dialogs_GetEditBoxText(dialog), CPR2.importedHash)
                end,
            },
            {
                text = SI_DIALOG_CANCEL,
                callback = function() 
                end,
            }
        }
    })
	
	CPR2.configSelector = WINDOW_MANAGER:GetControlByName("ChampPointRespecWindow1ConfigSelector")
	
	CPR2.configSelector.data = { tooltipText = "Select CP Configuration"}
	
	CPR2.configSelector:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	CPR2.configSelector:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	-- export config button tooltip
	CPR2.exportConfigButton = WINDOW_MANAGER:GetControlByName("ChampPointRespecWindow1ImportExportBGExportButton")
	
	CPR2.exportConfigButton.data = { tooltipText = "Generates an export hash for currently selected configuration"}

	CPR2.exportConfigButton:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	CPR2.exportConfigButton:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	-- import config button tooltip
	CPR2.importConfigButton = WINDOW_MANAGER:GetControlByName("ChampPointRespecWindow1ImportExportBGImportButton")
	
	CPR2.importConfigButton.data = { tooltipText = "Opens a window to import a configuration"}
	
	CPR2.importConfigButton:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	CPR2.importConfigButton:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
	
	CPR2.UpdateUI()
	
	ChampPointRespecWindow1:SetHandler("OnMoveStop", CPR2.savePositions)
	ChampPointRespecWindow1:ClearAnchors()
	ChampPointRespecWindow1:SetAnchor(CPR2.savedVariables.ui.point, GuiRoot, CPR2.savedVariables.ui.relPoint, CPR2.savedVariables.ui.offsetX, CPR2.savedVariables.ui.offsetY)
	
	ChampPointRespecWindow1CloseButton:SetHandler("OnClicked", function() ChampPointRespecWindow1:SetHidden(true) end)
	
	OverwriteWindowCancelButton:SetHandler("OnClicked", function() OverwriteWindow:SetHidden(true) end)
	
	ExportWindowCloseButton:SetHandler("OnClicked", function() ExportWindow:SetHidden(true) end)
	
	if CPR2.savedVariables["openUIWithCPWindow"] then 
		CHAMPION_PERKS_SCENE:RegisterCallback("StateChange", function(oldstate, newState)
			if(CHAMPION_PERKS_SCENE:IsShowing()) then
				ChampPointRespecWindow1:SetHidden(false)
			else
				ChampPointRespecWindow1:SetHidden(true)
			end
		end)
	end
	
	CPR2.InitializeAddonSettingsPanel()
	
	--SLASH_COMMANDS["/testexport"] = CPR2.DisplayExportWindow
	SLASH_COMMANDS["/cpr"] = CPR2.ToggleScene
	--SLASH_COMMANDS["/cprprintsv"] = CPR2.PrintSV
	--SLASH_COMMANDS["/cpr"] = CPR2.LoadCPConfigFromName
	--SLASH_COMMANDS["/cphash"] = CPR2.createCPHash
	--SLASH_COMMANDS["/savecphash"] = CPR2.saveCPHash
	--SLASH_COMMANDS["/deletecphash"] = CPR2.DeleteCPHash
	--SLASH_COMMANDS["/resetcp"] = CPR2.resetCP
	--SLASH_COMMANDS["/setcpfromhash"] = CPR2.LoadCPFromHash
	--SLASH_COMMANDS["/testcpfunction"] = TestFunction
end

function CPR2.OnAddOnLoaded(event, addonName)
	if addonName ~= CPR2.name then return end
	CPR2:Initialize()
end

EVENT_MANAGER:RegisterForEvent(CPR2.name, EVENT_ADD_ON_LOADED, CPR2.OnAddOnLoaded)