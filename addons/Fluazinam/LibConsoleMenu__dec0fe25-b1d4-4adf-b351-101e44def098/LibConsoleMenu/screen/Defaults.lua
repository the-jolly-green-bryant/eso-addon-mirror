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
	return list ~= nil and list.currentSubmenu == nil
end

-- Reset controls on the current list page only (never calls menu resetFunc).
function LCM.AddonMenu:ResetToDefaults()
	if not self.selected or not self.enableDefaults then
		return
	end

	local list = GetCurrentList()
	local currentSubmenu = list and list.currentSubmenu
	for i = 1, #self.controls do
		local setting = self.controls[i]
		if setting.currentSubmenu == currentSubmenu and setting.type ~= LCM.CT_SUBMENU then
			setting:ResetToDefaults()
		end
	end
	self:UpdateControls()
end

-- Full addon reset via menu resetFunc / resetFunction (root Tertiary only).
function LCM.AddonMenu:ResetAddonToDefaults()
	if not self.selected or not self.enableReset then
		return
	end
	if type(self.resetFunction) ~= "function" then
		return
	end

	self.resetFunction()
	self:CreateControls()
	self:UpdateControls()
end

function LCM.AppendDefaultsKeybinds(descriptor)
	descriptor[#descriptor + 1] = {
		alignment = KEYBIND_STRIP_ALIGN_LEFT,
		name = GetString(SI_OPTIONS_DEFAULTS),
		keybind = "UI_SHORTCUT_SECONDARY",
		visible = function()
			return LCM.currentMenu and LCM.currentMenu.hasDefaults and LCM.currentMenu.enableDefaults
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
			local settings = LCM.currentMenu
			return settings
				and settings.enableReset
				and type(settings.resetFunction) == "function"
				and IsRootPage()
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
					if LCM.currentMenu then
						LCM.currentMenu:ResetToDefaults()
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
					if LCM.currentMenu then
						LCM.currentMenu:ResetAddonToDefaults()
					end
				end,
			},
			[2] = {
				text = SI_DIALOG_CANCEL,
			},
		},
	}
)
