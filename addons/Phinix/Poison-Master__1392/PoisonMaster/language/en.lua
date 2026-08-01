local PMAddon = _G['PMAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- English
------------------------------------------------------------------------------------------------------------------

-- General strings
	L.PMAddon_GLOBAL			= "GLOBAL OPTIONS"
	L.PMAddon_LOCK				= "Lock Position"
	L.PMAddon_LOCKTIP			= "Prevents moving the poison config window."
	L.PMAddon_BACK				= "Hide Background"
	L.PMAddon_BACKTIP			= "Hides the background of the poison config window."
	L.PMAddon_ICONS				= "Show Equip Icons"
	L.PMAddon_ICONSTIP			= "Shows icon indicators for your active and inactive weapon poisons when assigned to a favorite slot."
	L.PMAddon_THEME				= "Equip Icon Theme"
	L.PMAddon_THEMETIP			= "Choose the style for equipped poison indicators."
	L.PMAddon_STYLE1			= "Borders"
	L.PMAddon_STYLE2			= "Checks"
	L.PMAddon_DEBUG				= "Show Debug Text"
	L.PMAddon_DEBUGTIP			= "Shows descriptive text in chat when certain things occur."
	L.PMAddon_Tooltip			= "Shift-click to assign equipped poison to slot. Right-click to clear."

-- Keybind strings
	L.PMAddon_KBT				= "Toggle Poison Config Window"
	L.PMAddon_KB1				= "Equip/Unequip Slot 1 Poison"
	L.PMAddon_KB2				= "Equip/Unequip Slot 2 Poison"
	L.PMAddon_KB3				= "Equip/Unequip Slot 3 Poison"
	L.PMAddon_KB4				= "Equip/Unequip Slot 4 Poison"

-- Debug strings
	L.PMAddon_PNE				= "Desired poison is no longer in your bags."
	L.PMAddon_NPE				= "Active weapon has no equipped poison to assign."


------------------------------------------------------------------------------------------------------------------

function PMAddon:GetLanguage() -- default locale, will be the return unless overwritten
	return L
end
