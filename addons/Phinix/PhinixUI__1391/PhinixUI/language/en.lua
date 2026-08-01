local PUIAddon = _G['PUIAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- English
------------------------------------------------------------------------------------------------------------------

-- General strings
	L.PUIAddon_CLOSE 		= 'Close'
	L.PUIAddon_CLEAR 		= 'Clear Selection'
	L.PUIAddon_DEFAULT 		= 'Default Selection'
	L.PUIAddon_RUN			= 'Run Selected Config'
	L.PUIAddon_COMPLETE		= 'Addon configuration complete:'
	L.PUIAddon_SUCCESS		= '--> Successfully configured '
	L.PUIAddon_ADDONS		= ' addons.'

	
------------------------------------------------------------------------------------------------------------------

function PUIAddon:GetLanguage() -- default locale, will be the return unless overwritten
	return L
end
