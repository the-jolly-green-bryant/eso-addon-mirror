FixVisualBugs = {}
local L = {}

------------------------------------------------------------------------------------------------------------------
-- English
------------------------------------------------------------------------------------------------------------------

-- Settings panel
	L.FVBAddon_AutoIWFix			= "Automatic Weapon Fix"
	L.FVBAddon_AutoIWFixTip			= "Fix invisible weapon bug automatically (experimental). You can also set a keybind to fix visual bugs manually."

------------------------------------------------------------------------------------------------------------------

function FixVisualBugs:GetLanguage() -- default locale, will be the return unless overwritten
	return L
end
