ProvTF =
{
	name = "ProvisionsTeamFormation",
	namePublic = "Prov's TeamFormation",
	nameColor = "|cFF9999Team|cFF0000Formation|r",
	author = "|c00C000Provision|r",
	version = "1.3.1b", --3 endroits
	CPL = nil,
	defaults =
	{ --Don't forget header.lua
		enabled		= true,

		posx		= 0,
		posy		= 50,
		width		= 600,
		height		= 500,

		refreshRate	= 25,

		circle		= true,
		camRotation = true,

		scale		= 92,
		logdist		= .42,
		cardinal	= 0.12,

		siege		= true,

		myAlpha 	= .72,
		roleIcon	= false,

		jRules		= {},
	},
	debug = {
		enabled		= false,
		pos =
		{
			num		= 2,
			x		= nil,
			y		= nil,
			heading	= nil,
		}
	}
}

CLASS_ID2NAME = {
	[1] = 'Dragonknight',
	[2] = 'Sorcerer',
	[3] = 'Nightblade',
	[4] = 'Warden',
	[6] = 'Templar',
}

LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")
