VWoeAddon = WINDOW_MANAGER:CreateControl(nil, GuiRoot)
local VWoe = _G['VWoeAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- English
------------------------------------------------------------------------------------------------------------------

--General strings
	L.AddonTitle				= "Vampire's Woe"
	L.KeybindToggle				= "Toggle Suppression"
	L.KeybindInnocent			= "'Prevent Attacking Innocents'"
	L.KeybindCriminal			= "Block Criminal Abilities"
	L.FeedToggleOn				= "Vampire Feed synergy is no longer suppressed."
	L.FeedToggleOff				= "Vampire Feed synergy is being suppressed."
	L.BladeToggleOn				= "Blade of Woe synergy is no longer suppressed."
	L.BladeToggleOff			= "Blade of Woe synergy is being suppressed."
	L.SwapToggleV				= "Vampire Feed suppressed, Blade of Woe enabled."
	L.SwapToggleB				= "Blade of Woe suppressed, Vampire Feed enabled."
	L.AddonToggleOn				= "Vampire's Woe Enabled."
	L.AddonToggleOff			= "Vampire's Woe Disabled."
	L.KeybindInnoOn				= "'Prevent Attacking Innocents' is enabled."
	L.KeybindInnoOff			= "'Prevent Attacking Innocents' is disabled."
	L.BlockCrimeOn				= "Block using 'Criminal Action' skills: ON."
	L.BlockCrimeOff				= "Block using 'Criminal Action' skills: OFF."
	L.AbilityBlocked			= "Vampire's Woe: Ability blocked by crime setting."

--Settings stringse language
	L.EnableAddon				= "Enable Addon"
	L.EnableAddonTip			= "Enable/Disable the addon functionality."
	L.KeybindOption				= "Keybind Function"
	L.KeybindOptionTip			= "Set the behavior when pressing the Toggle Suppression keybind."
	L.KeyOption1				= "Toggle Feeding"
	L.KeyOption2				= "Toggle Blade"
	L.KeyOption3				= "Switch Between"
	L.KeyOption4				= "Enable/Disable"
	L.AllowAlly					= "Bite Ally When Suppressed"
	L.AllowAllyTip				= "Allows you to bite and pass vampirism to an ally even when the feeding synergy is suppressed."
	L.AutoInnocent				= "Automatic Innocent Toggle"
	L.AutoInnocentTip			= "Automatically disable 'Prevent Attacking Innocents' when Vampire Feed or Blade of Woe synergy is shown."
	L.ShowDebug					= "Show Debug Messages"
	L.ShowDebugTip				= "Show a chat notice when Vampire Feed or Blade of Woe is toggled on/off using the keybind."
	L.Status					= "Suppression Toggle Status"
	L.FeedSetting				= "Suppress Vampire Feed Synergy"
	L.FeedSettingTip			= "Block the Vampire Feed synergy from triggering."
	L.AutoStage					= "Enable Max Stage"
	L.AutoStageTip				= "When checked, vampire feeding will be enabled even if above setting is checked if your current stage is lower than the max stage set below."
	L.MaxStage					= "Set Max Stage"
	L.MaxStageTip				= "Vampire feed synergy will be suppressed when your current stage is greater than or equal to this limit."
	L.BladeSetting				= "Suppress Blade of Woe Synergy"
	L.BladeSettingTip			= "Block the Blade of Woe synergy from triggering."
	L.CriminalSetting			= "Block 'Criminal Act' abilities."
	L.CriminalSettingTip		= "Prevents abilities marked as 'Criminal Act' from being cast."


------------------------------------------------------------------------------------------------------------------

function VWoe:GetLanguage() -- default locale, will be the return unless overwritten
	return L
end
