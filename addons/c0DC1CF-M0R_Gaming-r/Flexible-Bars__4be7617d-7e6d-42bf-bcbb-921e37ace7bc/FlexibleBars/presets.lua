FlexibleBars = FlexibleBars or {}
local FB = FlexibleBars

FB.presets = {
	["Base Game"] = {
		health = {
			colour = {0.6, 0.0745, 0.0745}, -- 991313
			desiredX = 250,
			desiredY = 23,
			rotation = 0,
			pos = {
				center = 0,
				bottom = -123,
			},
			hide = false,
			textHide = false,
			textRotation = 0,
			textScale = 1,
			textOffsetX = 0,
			textOffsetY = 0,
		},
		mag = {
			colour = {0.0078, 0.3216, 0.7804}, -- 0252c7
			desiredX = 250,
			desiredY = 23,
			rotation = 0,
			pos = {
				center = -400,
				bottom = -123,
			},
			hide = false,
			textHide = false,
			textRotation = 0,
			textScale = 1,
			textOffsetX = 0,
			textOffsetY = 0,
		},
		stam = {
			colour = {0.0117, 0.6, 0}, -- 039900
			desiredX = 250,
			desiredY = 23,
			rotation = 0,
			pos = {
				center = 400,
				bottom = -123,
			},
			hide = false,
			textHide = false,
			textRotation = 0,
			textScale = 1,
			textOffsetX = 0,
			textOffsetY = 0,
		},
	},
	["Vertical"] = {
		["stam"] = {
			["desiredX"] = 215,
			["colour"] = { [1] = 0.0117000000, [2] = 0.6000000000, [3] = 0 },
			["textOffsetX"] = 123,
			["desiredY"] = 25,
			["textOffsetY"] = 0,
			["hide"] = false,
			["textHide"] = false,
			["textRotation"] = 90,
			["pos"] = { ["mid"] = 112.5000000000, ["center"] = 350 },
			["rotation"] = 270,
			["textScale"] = 1.2000000000,
		},
		["mag"] = {
			["desiredX"] = 215,
			["colour"] = { [1] = 0.0078000000, [2] = 0.3216000000, [3] = 0.7804000000 },
			["textOffsetX"] = 123,
			["desiredY"] = 25,
			["textOffsetY"] = 0,
			["hide"] = false,
			["textHide"] = false,
			["textRotation"] = 270,
			["pos"] = { ["mid"] = -112.5000000000, ["center"] = 350 },
			["rotation"] = 90,
			["textScale"] = 1.2000000000,
		},
		["health"] = {
			["desiredX"] = 450,
			["colour"] = { [1] = 0.6000000000, [2] = 0.0745000000, [3] = 0.0745000000 },
			["textOffsetX"] = -245,
			["desiredY"] = 25,
			["textOffsetY"] = 0,
			["hide"] = false,
			["textHide"] = false,
			["textRotation"] = 270,
			["pos"] = { ["mid"] = 0, ["center"] = -350 },
			["rotation"] = 90,
			["textScale"] = 1.2000000000,
		},
	},
	["Stacked"] = {
		health = {
			colour = {0.6, 0.0745, 0.0745},
			desiredX = 250,
			desiredY = 23,
			rotation = 0,
			pos = {
				center = -350,
				bottom = -173,
			},
			hide = false,
			textHide = false,
			textRotation = 0,
			textScale = 1,
			textOffsetX = 0,
			textOffsetY = 0,
		},
		mag = {
			colour = {0.0078, 0.3216, 0.7804},
			desiredX = 250,
			desiredY = 23,
			rotation = 0,
			pos = {
				center = -350,
				bottom = -148,
			},
			hide = false,
			textHide = false,
			textRotation = 0,
			textScale = 1,
			textOffsetX = 0,
			textOffsetY = 0,
		},
		stam = {
			colour = {0.0117, 0.6, 0},
			desiredX = 250,
			desiredY = 23,
			rotation = 0,
			pos = {
				center = -350,
				bottom = -123,
			},
			hide = false,
			textHide = false,
			textRotation = 0,
			textScale = 1,
			textOffsetX = 0,
			textOffsetY = 0,
		},
	},
	["Reticle"] = {
		health = {
			colour = {0.6, 0.0745, 0.0745},
			desiredX = 200,
			desiredY = 20,
			rotation = 0,
			pos = {
				center = 0,
				mid = 75,
			},
			hide = false,
			textHide = false,
			textRotation = 0,
			textScale = 1.2,
			textOffsetX = 0,
			textOffsetY = 0,
		},
		mag = {
			colour = {0.0078, 0.3216, 0.7804},
			desiredX = 200,
			desiredY = 20,
			rotation = 60,
			pos = {
				center = -64.9,
				mid = -37.5,
			},
			hide = false,
			textHide = false,
			textRotation = 0,
			textScale = 1.2,
			textOffsetX = 0,
			textOffsetY = 0,
		},
		stam = {
			colour = {0.0117, 0.6, 0},
			desiredX = 200,
			desiredY = 20,
			rotation = 120,
			pos = {
				center = 64.9,
				mid = -37.5,
			},
			hide = false,
			textHide = false,
			textRotation = 180,
			textScale = 1.2,
			textOffsetX = 0,
			textOffsetY = 0,
		},
	}
}






ESO_Dialogs["FlexibleBarsConfirmDialogue"] = {
	canQueue = true,
	gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
	title = { text = "<<1>>" },
	mainText = { text = "<<1>>" },
	warning = { text = "<<1>>" },
	buttons = { { text = "Yes", callback = function(dialogue)
		dialogue.data.yesCallback()
	end }, { text = "No" } },
}


function FB.ShowDialogue(title, description, warning, callback)
	ZO_Dialogs_ShowPlatformDialog("FlexibleBarsConfirmDialogue", {yesCallback = callback}, {
		titleParams = {title or ""},
		mainTextParams = {description or ""},
		warningParams = {warning or ""}
	})
end




-- can prob remove alot of this
local CHECKED_ICON = "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_equipped.dds"

local function IsSelected(data)
	return data.isActive
end

local function SetupProfileItem(control, data, ...)
	ZO_SharedGamepadEntry_OnSetup(control, data, ...)
	--control.statusIndicator:AddIcon(CHECKED_ICON)

	if IsSelected(data) then
		control.statusIndicator:AddIcon(CHECKED_ICON)
		control.statusIndicator:Show()
	end
end

local function setupPresets(dialog, activeCriteria)
	local presets = FB.presets
	dialog.info.parametricList = {}
	local template = "ZO_GamepadSubMenuEntryWithStatusTemplate"

	for i,v in pairs(presets) do
		local entryData = ZO_GamepadEntryData:New(i)
		entryData:SetFontScaleOnSelection(false)
		entryData:SetIconTintOnSelection(true)
		entryData.setup = SetupProfileItem
		entryData.name = i
		entryData.isActive = activeCriteria(i)

		local listItem = {
			template = template,
			entryData = entryData,
		}
		table.insert(dialog.info.parametricList, listItem)
	end
	dialog:setupFunc()
	dialog.entryList:SetSelectedDataByEval(IsSelected)
end

ESO_Dialogs["FlexibleBarsPresetSelect"] = {
	canQueue = true,
	gamepadInfo = {
		dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
	},
	setup = function(dialog)
		setupPresets(dialog, function(itemName)
			return false
		end)
	end,
	title = {
		text = "Select the Preset to load!",
	},
	warning = {
		text = "After making a selection, your UI will be reloaded."
	},
	buttons = {
		{
			text = SI_GAMEPAD_SELECT_OPTION,
			callback =  function(dialog)
				local data = dialog.entryList:GetTargetData()
				if data.name and FB.presets[data.name] and FB.vars then
					FB.ShowDialogue("Loading Preset",
						"Are you sure you would like to load the preset \""..tostring(data.name).."\"?",
						"Accepting will immediately start a reload UI, and will overwrite any saved settings.",
						function()
							local preset = FB.presets[data.name]
							for i,v in pairs(preset) do
								FB.vars[i] = v
							end
							ReloadUI()
						end)
				end
			end,
		},
		{
			text = SI_DIALOG_EXIT,
		},
	},
}
