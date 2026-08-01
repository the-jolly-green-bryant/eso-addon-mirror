if PotionTakenSoundFix == nil then PotionTakenSoundFix = {} end
local PTSF = PotionTakenSoundFix
--=============================================================================================================
-- Constants & variables
--=============================================================================================================
--LAM addon menu
PTSF.addonMenu = {}
PTSF.addonMenu.isShown = false
PTSF.addonMenu.isBuilt = false

-- Debug
PTSF.debug				= false

--Settings
PTSF.settingsVars						= {}
PTSF.settingsVars.defaults				= {}
PTSF.settingsVars.settings				= {}
PTSF.settingsVars.defaultSettings		= {}
PTSF.localizationVars					= {}
PTSF.settingsVars.settings.buffFilters	= {}
PTSF.masterSwitch						= true
PTSF.toggle_potion_buffs_check_enabled	= false
PTSF.soundCategoryPotTaken 				= 1
PTSF.soundCategoryPotionLostBuff		= 2
PTSF.soundCategoryPotionCooldownEnded	= 3
PTSF.soundCategoryLowHealth 			= 4
PTSF.soundCategoryLowStamina 			= 5
PTSF.soundCategoryLowMagicka 			= 6
--=============================================================================================================
--	Debug functions {{{ They're here since this is the 1st file loading
--=============================================================================================================
function PTSF.D(message, force)
    if(PTSF.debug or force) then
        d("|cFF0000["..PTSF.addonVars.addonName.."]|r "..tostring(message))
    end
end
function PTSF.DG(message)
    d("|c00FF00["..PTSF.addonVars.addonName.."]|r "..tostring(message))
end 
--}}}