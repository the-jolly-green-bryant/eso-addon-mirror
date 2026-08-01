--A UNIQUE identifier
local _IDENTIFIER = "FsBountyDecay" 

local FsBountyDecay_aux = {
    name              = _IDENTIFIER,
	shortName         = "FSBD",
    version           = "3.0",
    author            = "FelipeS11",
    authorId          = "@FelipeS11",
    menuName          = "Fs Bounty Decay",
	slashCommandName  = "/fsbounty",
	settings = {},
	fsAddonCreated = true,
	isDebug = false,
    -- Default settings.
	defaults = {
        FirstLoad = true,
		point = BOTTOMRIGHT,
		relPoint = BOTTOMRIGHT,
		x = -5,
		y = -100,
		showInfo = false,
		isClock = true
	}
}

FsBountyDecay_aux.Utils = LibFsCommons(FsBountyDecay_aux.name, FsBountyDecay_aux.shortName)
-- Test if exist another version, or addon using the same 'name'
if(FsBountyDecay_aux.Utils.CanCreateAddon(_IDENTIFIER, FsBountyDecay_aux))then
	_G[_IDENTIFIER] = FsBountyDecay_aux
end
