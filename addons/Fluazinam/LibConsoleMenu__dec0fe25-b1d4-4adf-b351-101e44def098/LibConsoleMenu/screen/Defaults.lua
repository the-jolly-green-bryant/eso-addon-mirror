-- Page Defaults (Secondary) and optional full-addon Reset (Tertiary, root only).

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

local function GetCurrentList()
	if LCM.list then
		return LCM.list
	end
	if LCM.scrollList then
		return LCM.scrollList:GetCurrentList() or LCM.scrollList:GetMainList()
	end
	return nil
end

local function IsRootPage()
	local list = GetCurrentList()
	return list ~= nil and list.currentSection == nil
end

-- Reset controls on the current list page only (never calls panel resetFunc).
function LCM.AddonSettings:ResetToDefaults()
	if not self.selected or not self.allowDefaults then
		return
	end

	local list = GetCurrentList()
	local currentSection = list and list.currentSection
	for i = 1, #self.settings do
		local setting = self.settings[i]
		if setting.currentSection == currentSection and setting.type ~= LCM.CT_SECTION then
			setting:ResetToDefaults()
		end
	end
	self:UpdateControls()
end

-- Full addon reset via panel resetFunc / defaultsFunction (root Tertiary only).
function LCM.AddonSettings:ResetAddonToDefaults()
	if not self.selected then
		return
	end
	if type(self.defaultsFunction) ~= "function" then
		return
	end

	self.defaultsFunction()
	self:CreateControls()
	self:UpdateControls()
end

function LCM.AppendDefaultsKeybinds(descriptor)
	descriptor[#descriptor + 1] = {
		alignment = KEYBIND_STRIP_ALIGN_LEFT,
		name = GetString(SI_OPTIONS_DEFAULTS),
		keybind = "UI_SHORTCUT_SECONDARY",
		visible = function()
			return LCM.currentSettings and LCM.currentSettings.hasDefaults and LCM.currentSettings.allowDefaults
		end,
		callback = function()
			ZO_Dialogs_ShowGamepadDialog("LibConsoleMenu_Defaults")
		end,
	}

	descriptor[#descriptor + 1] = {
		alignment = KEYBIND_STRIP_ALIGN_LEFT,
		name = GetString(SI_CHAT_CONFIG_RESET),
		keybind = "UI_SHORTCUT_TERTIARY",
		visible = function()
			local settings = LCM.currentSettings
			return settings and type(settings.defaultsFunction) == "function" and IsRootPage()
		end,
		callback = function()
			ZO_Dialogs_ShowGamepadDialog("LibConsoleMenu_ResetAddon")
		end,
	}
end

ZO_Dialogs_RegisterCustomDialog(
	"LibConsoleMenu_Defaults",
	{
		mustChoose = true,
		gamepadInfo = {
			dialogType = GAMEPAD_DIALOGS.BASIC,
		},
		title = {
			text = SI_OPTIONS_RESET_TITLE,
		},
		mainText = {
			text = SI_OPTIONS_RESET_PROMPT,
		},
		buttons = {
			[1] = {
				text = SI_OPTIONS_RESET,
				callback = function()
					if LCM.currentSettings then
						LCM.currentSettings:ResetToDefaults()
					end
				end,
			},
			[2] = {
				text = SI_DIALOG_CANCEL,
			},
		},
	}
)

ZO_Dialogs_RegisterCustomDialog(
	"LibConsoleMenu_ResetAddon",
	{
		mustChoose = true,
		gamepadInfo = {
			dialogType = GAMEPAD_DIALOGS.BASIC,
		},
		title = {
			text = SI_OPTIONS_RESET_TITLE,
		},
		mainText = {
			text = SI_OPTIONS_RESET_ALL_PROMPT,
		},
		buttons = {
			[1] = {
				text = SI_OPTIONS_RESET,
				callback = function()
					if LCM.currentSettings then
						LCM.currentSettings:ResetAddonToDefaults()
					end
				end,
			},
			[2] = {
				text = SI_DIALOG_CANCEL,
			},
		},
	}
)
