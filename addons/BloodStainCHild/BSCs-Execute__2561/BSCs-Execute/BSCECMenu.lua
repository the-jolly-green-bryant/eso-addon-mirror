BSCExecute = BSCExecute or {}
local BSCEC = BSCExecute

local COLOR_ACTIVE   = "|c00FF00"  -- grün
local COLOR_INACTIVE = "|cFF5555"  -- rot
local COLOR_RESET    = "|r"

local function GetSkillIdByName(skillName)
    for id, name in pairs(BSCEC.ActiveSkills) do
        if name == skillName then
            return id
        end
    end
    return nil
end

local function BuildSavedSkillsText()
    local entries = {}
    for skillId, value in pairs(BSCEC.SV_acc.SkillExecuteValues) do
        local name = zo_strformat("<<1>>", GetAbilityName(skillId))
        local isActive = BSCEC.ActiveSkills[skillId] ~= nil

        local color = isActive and "|c00FF00" or "|cFF5555"
        local label = string.format("%s%s|r - %d%%", color, name, value)

        table.insert(entries, label)
    end

    if #entries == 0 then
        return "No saved skill thresholds."
    end

    table.sort(entries, function(a, b)
        return a:gsub("|c........", ""):lower() < b:gsub("|c........", ""):lower()
    end)

    return table.concat(entries, "\n")
end

local function CallDonate()
    SCENE_MANAGER:Show('mailSend')
    zo_callLater(function()
		ZO_MailSendToField:SetText(BSCEC.Author)
		ZO_MailSendSubjectField:SetText(BSCEC.Name)
		ZO_MailSendBodyField:TakeFocus()
    end, 250)
end

function BSCEC.buildMenu()
	-- the panel for the addons menu
	local panelData = {
		type = "panel",
		name = BSCEC.Name,
		displayName = BSCEC.NameSpaced,
		author = BSCEC.Author,
		version = BSCEC.DisplayVersion,
		registerForRefresh = true,
		donation = CallDonate,
	}	
	local optionsTable = {}
	
	local BSCECUI = BSCExecute
	
	table.insert(optionsTable, {
		type = "button",
		name = "Show/Hide UI",
        width = "half",
		func = function(control)
			BSCEC.bUIisHidden = not BSCEC.bUIisHidden
			BSCExecute:SetHidden(BSCEC.bUIisHidden)
		end,
	})
	
	table.insert(optionsTable, {
		type = "button",
		name = "Resett UI Position",
        width = "half",
		func = function(control)
			BSCEC.SV_acc.Left = nil
			BSCEC.SV_acc.Top = nil
			BSCECUI:ClearAnchors()
			BSCECUI:SetAnchor(CENTER, GuiRoot, CENTER, 0, -150)
		end,
	})
	-- settings
	table.insert(optionsTable, {
        type = "header",
		name = "Settings",
		controls = control,
    })	
	table.insert(optionsTable, {
		type = "submenu",
		name = "Saved Execute Thresholds",
		tooltip = "All skills with custom thresholds.",
		controls = {
			{
				type = "description",
				reference = "BSCEC_SavedSkillsList",
				text = function()
					return BuildSavedSkillsText()
				end,
				width = "full",
			},
		},
	})
	table.insert(optionsTable, {
        type = "dropdown",
        name = "Select Skill",
        tooltip = "Choose a skill currently equipped on your bar.",
        choices = BSCEC:GetListNames(),
        getFunc = function() return BSCEC.SelectedSkillName end,
        setFunc = function(value)
            BSCEC.SelectedSkillName = value
        end,
        width = "full",
        reference = "BSCEC_SkillsDropdown",
    })
	table.insert(optionsTable, {
        type = "slider",
        name = "Execute Threshold (%)",
        tooltip = "Set the HP percentage at which the execute warning will be shown.",
        min = 0,
        max = 100,
        step = 1,
        getFunc = function()
            local id = GetSkillIdByName(BSCEC.SelectedSkillName)
            if id and BSCEC.SV_acc.SkillExecuteValues[id] then
                return BSCEC.SV_acc.SkillExecuteValues[id]
            else
                return BSCEC.SV_acc.ExecuteP
            end
        end,
        setFunc = function(value)
            BSCEC.TempSkillValue = value
        end,
        --disabled = function() return BSCEC.SelectedSkillName == nil or BSCEC.SelectedSkillName == "" end,
        width = "full",
    })
	table.insert(optionsTable, {
        type = "button",
        name = "Add / Update",
        tooltip = "Save the execute threshold for the selected skill.",
        func = function()
            if not BSCEC.SelectedSkillName then return end
            local id = GetSkillIdByName(BSCEC.SelectedSkillName)
            if id and BSCEC.TempSkillValue then
                BSCEC.SV_acc.SkillExecuteValues[id] = BSCEC.TempSkillValue
				d(zo_strformat("|c00FF00[BSC Execute]|r Saved execute threshold for <<1>>: |cFFFFFF<<2>>%%|r", BSCEC.SelectedSkillName, BSCEC.TempSkillValue))
				
				if BSCEC_SavedSkillsList then
					BSCEC_SavedSkillsList:UpdateValue() -- ruft text()-Funktion neu auf
				end
            end
        end,
        disabled = function() return BSCEC.SelectedSkillName == nil end,
        width = "half",
    })
	table.insert(optionsTable, {
        type = "button",
        name = "Remove",
        tooltip = "Delete the saved execute threshold for the selected skill.",
        func = function()
            if not BSCEC.SelectedSkillName then return end
            local id = GetSkillIdByName(BSCEC.SelectedSkillName)
            if id and BSCEC.SV_acc.SkillExecuteValues[id] then
                BSCEC.SV_acc.SkillExecuteValues[id] = nil
				d(zo_strformat("|cFF0000[BSC Execute]|r Removed execute threshold for <<1>>", BSCEC.SelectedSkillName))
								
				if BSCEC_SavedSkillsList then
					BSCEC_SavedSkillsList:UpdateValue() -- ruft text()-Funktion neu auf
				end
            end
        end,
        disabled = function()
            local id = GetSkillIdByName(BSCEC.SelectedSkillName)
            return not id or not BSCEC.SV_acc.SkillExecuteValues[id]
        end,
        width = "half",
    })
	table.insert(optionsTable, {
        type = "header",
        name = "General Settings",
    })
	-- only DD
	table.insert(optionsTable, {
        type = "checkbox",
        name = "Show Only on Selected Role DD",
        getFunc = function() return BSCEC.SV_acc.bOnlyDD end,
        setFunc = function(value)
            BSCEC.SV_acc.bOnlyDD = value
        end,
    })	
    table.insert(optionsTable, {
        type = "slider",
        name = "Default Execute Threshold (%)",
        tooltip = "If a skill has no specific threshold set, this value is used.",
        min = 0,
        max = 100,
        step = 1,
        getFunc = function() return BSCEC.SV_acc.ExecuteP end,
        setFunc = function(value) BSCEC.SV_acc.ExecuteP = value end,
    })
	-- Ahlpha
	table.insert(optionsTable, {
        type = "slider",
        name = "Alpha",
        tooltip = "Set UI transparency.",
        min = 0,
        max = 1,
        step = 0.1,
        getFunc = function() return BSCEC.SV_acc.Alpha end,
        setFunc = function(value) 
            BSCEC.SV_acc.Alpha = value
            BSCExecute:SetAlpha(value)
        end,
    })
	-- Scaling
	table.insert(optionsTable, {
        type = "slider",
        name = "Scale",
        tooltip = "Set the size of the UI.",
        min = 1,
        max = 10,
        step = 1,
        getFunc = function() return BSCEC.SV_acc.Scale end,
        setFunc = function(value)
            BSCEC.SV_acc.Scale = value
            BSCExecute:SetScale(value)
        end,
    })
	table.insert(optionsTable, {
        type = "colorpicker",
        name = "Text Color",
        tooltip = "Set the color of the text.",
        getFunc = function() 
            return BSCEC.SV_acc.textcolor_r, BSCEC.SV_acc.textcolor_g, BSCEC.SV_acc.textcolor_b, BSCEC.SV_acc.textcolor_a
        end,
        setFunc = function(r, g, b, a)
            BSCEC.SV_acc.textcolor_r = r
            BSCEC.SV_acc.textcolor_g = g
            BSCEC.SV_acc.textcolor_b = b
            BSCEC.SV_acc.textcolor_a = a
            BSCEC.UpdateUI()
        end,
    })
	table.insert(optionsTable, {
        type = "checkbox",
        name = "Show Text",
        tooltip = "Toggle display of the text element.",
        getFunc = function() return BSCEC.SV_acc.bEnableText end,
        setFunc = function(value)
            BSCEC.SV_acc.bEnableText = value
            BSCEC.UpdateUI()
        end,
    })	
	table.insert(optionsTable, {
        type = "checkbox",
        name = "Show Icon",
        tooltip = "Toggle display of the icon.",
        getFunc = function() return BSCEC.SV_acc.bEnableIcon end,
        setFunc = function(value)
            BSCEC.SV_acc.bEnableIcon = value
            BSCEC.UpdateUI()
        end,
    })	
	
	-- timing
	-- 
	table.insert(optionsTable, {
        type = "checkbox",
        name = "Show Again On Target Change",
        tooltip = "If popup duration > 0, show the alert again when changing targets.",
        getFunc = function() return BSCEC.SV_acc.bShowAgainOnChange end,
        setFunc = function(value) BSCEC.SV_acc.bShowAgainOnChange = value end,
    })
	table.insert(optionsTable, {
        type = "slider",
        name = "Popup Duration (seconds)",
        tooltip = "How long the execute alert will remain visible. 0 = until target dies.",
        min = 0,
        max = 10,
        step = 1,
        getFunc = function() return BSCEC.SV_acc.MSShow end,
        setFunc = function(value) BSCEC.SV_acc.MSShow = value end,
    })
	table.insert(optionsTable, {
        type = "editbox",
        name = "Popup Text",
        tooltip = "Set the text displayed when execute is triggered.",
        getFunc = function() return BSCEC.SV_acc.sExecuteTxT end,
        setFunc = function(value)
            if value ~= "" then
                BSCEC.SV_acc.sExecuteTxT = value
                BSCEC.UpdateUI()
            end
        end,
    })
	table.insert(optionsTable, {
		type = "header",
		name = "Difficulty Settings",
	})

	table.insert(optionsTable, {
		type = "dropdown",
		name = "Minimum Difficulty",
		tooltip = "The execute UI will only show on targets at or above this difficulty.",
		choices = { "None", "Easy", "Normal", "Hard", "Deadly" },
		choicesValues = { MONSTER_DIFFICULTY_NONE, MONSTER_DIFFICULTY_EASY, MONSTER_DIFFICULTY_NORMAL, MONSTER_DIFFICULTY_HARD, MONSTER_DIFFICULTY_DEADLY },
		getFunc = function() return BSCEC.SV_acc.MinDifficulty end,
		setFunc = function(value)
			BSCEC.SV_acc.MinDifficulty = value
		end,
		width = "full",
	})
	
    LibAddonMenu2:RegisterAddonPanel(BSCEC.NameSpaced.."Options", panelData)
    LibAddonMenu2:RegisterOptionControls(BSCEC.NameSpaced.."Options", optionsTable)
	
	
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
		if panel and panel:GetName() == BSCEC.NameSpaced.."Options" then
			BSCEC:CheckHotbar()
			if BSCEC_SkillsDropdown then
				BSCEC_SkillsDropdown:UpdateChoices(BSCEC.ActiveSkillList)
			end
		end
		if #BSCEC.ActiveSkillList > 0 and not BSCEC.SelectedSkillName then
			BSCEC.SelectedSkillName = BSCEC.ActiveSkillList[1]
		end
	end)
end