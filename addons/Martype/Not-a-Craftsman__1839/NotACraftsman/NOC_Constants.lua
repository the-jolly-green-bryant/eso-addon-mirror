--Global array with all data of this addon
if NOC == nil then NOC = {} end
local NOC = NOC

--==========================================================================================================================================
-- 															NOC CONSTANTS
--==========================================================================================================================================

NOC.checkVars = {}
--Table with the item types to lock
NOC.checkVars.itemTypesToLock = {
	[ITEMTYPE_RECIPE]	= true,
	[ITEMTYPE_RACIAL_STYLE_MOTIF]	= true,
}