-- create global object do not touch!
SwitchBar = SwitchBar or {}
-- end do not touch
-- should we look for more icons in iconPak.lua?
SwitchBar.installOptionalIcons = true
--texture paths for icons in menu at least 2 must be present edit iconPak.lua to add more to change the defaults change these paths
SwitchBar.iconTextures = {
[1] = "/esoui/art/icons/icon_2handed.dds",
[2] = "/esoui/art/icons/heraldrycrests_weapon_shield_01.dds",
}

--Descriptions table for icons in menu at least 2 must be present edit iconPak.lua to add more tooltips to change the defaults change these
SwitchBar.iconTooltips = {
[1] = "2 Handed Sword",
[2] = "Sword and Board",
}

--Addon defaults what saved variables is based on
SwitchBar.defaults = {
	--should not change these lines
	["positionLockOption"] = true,
	["showAlwaysOption"] = false,
	--end should not change these lines
	["size"] = 300,
	--default color of background image behind icons
	["bgColor"] = { ["r"]=0.062745, ["g"]=0.113725, ["b"]=0.152941, ["a"]=0.155738 },
	["bgAlpha"] = 100,
	["icons"] = {
		--change index ie [#] to whatever you want the default to start as
		["1"] = SwitchBar.iconTextures[1],
		["2"] = SwitchBar.iconTextures[2],
		
	},
	["colours"] = {
		--default color of icons per bar
		["1"] = { ["r"]=1.0, ["g"]=1.0, ["b"]=1.0, ["a"]=1.0 },
		["2"] = { ["r"]=1.0, ["g"]=1.0, ["b"]=1.0, ["a"]=1.0 },
	},
	["hideBackground"] = false,
	--default position of main element on install
	["offsetX"] = 0,
	["offsetY"] = 19,
	--should not change this
	["activeBar"] = "1"
}