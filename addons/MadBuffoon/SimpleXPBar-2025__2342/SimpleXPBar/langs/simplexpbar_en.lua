---------------------
---------------------
------ ENGLISH ------
---------------------
---------------------

local strings = {
	---------------------
	------- META --------
	---------------------

	--leave blank if you dont want it shown.
	SXPB_TRANS_AUTHOR = "",
	SXPB_TRANS_BY = "Translated by",

	---------------------
	----- SETTINGS ------
	---------------------

	SXPB_ACCOUNTWIDE = "Use Account-Wide Settings",
	SXPB_PREVIEW = "Preview",
	SXPB_HIDE_ORIGINAL = "Hide Original ESO XPBar",

	SXPB_CUST_NAME = "Custom XPBar text",
	SXPB_CUST_TT = "Customize how you want the textbar to be formatted.",
	SXPB_CUST_RULES_NAME = "Custom text rules:",

	SXPB_TEXTOPTIONS = "Text Options",
	SXPB_BAROPTIONS = "Bar Options",
	SXPB_PBT_NAME = "Progress Bar Text",
	SXPB_LRT_NAME = "Level/Rank Text",

	SXPB_GEN_HIDE = "Hide",
	SXPB_GEN_FONT = "Font",
	SXPB_GEN_SIZE = "Size",
	SXPB_GEN_STYLE = "Style",
	SXPB_GEN_COLOR = "Color",
	SXPB_GEN_WIDTH = "Width",
	SXPB_GEN_HEIGHT = "Height",
	SXPB_GEN_BORDER = "Border Thickness",
	SXPB_GEN_POS = "Position",
	SXPB_GEN_HOR = "Horizontal Offset",
	SXPB_GEN_VERT = "Vertical Offset",
	SXPB_GEN_GAP = "Gap (between progress and border)",
	SXPB_GEN_BGCLR = "Background Color",
	SXPB_GEN_PGCLR = "Progress Color",
	SXPB_GEN_BDRCLR = "Border Color",

	SXPB_ANCHOR_LEFT = "LEFT",
	SXPB_ANCHOR_RIGHT = "RIGHT",
	SXPB_ANCHOR_TOPRIGHT = "TOPRIGHT",
	SXPB_ANCHOR_TOPLEFT = "TOPLEFT",
	SXPB_ANCHOR_BOTTOMRIGHT = "BOTTOMRIGHT",
	SXPB_ANCHOR_BOTTOMLEFT = "BOTTOMLEFT",
	SXPB_ANCHOR_CENTER = "CENTER",
	SXPB_ANCHOR_BOTTOM = "BOTTOM",
	SXPB_ANCHOR_TOP = "TOP",

	SXPB_STYLE_NONE = "NONE",
	SXPB_STYLE_THICK_SD = "Thick Shadow",
	SXPB_STYLE_THIN_SD = "Thin Shadow",

	SXPB_CUST_DEFAULT = "<lvlcpstr> <lvl> [<perc>%]  N <xpneed> (R <xpen>)   kill <mobs> to lvl",

	SXPB_CUST_RULES = 	''..
						'Inputing any of the following will replace them with their respective values when displayed:\n' ..
						'\n' ..
						'<lvl>       = players lvl/chmp\n' ..
						'<xp>        = players current xp/champion points\n' ..
						'<xpmax>     = max xp/points for current level/rank\n' ..
						'<xpneed>    = XP need to level\n' ..
						'<xpen>      = Enlightenment EXP that you have left\n' ..
						'<mobs>      = how many more of the last killed mob til a level up\n' ..
						'<perc>      = the current levels progress percentage\n' ..
						'<nextlvl>   = value of <lvl>+1\n' ..
						'\n' ..
						"<lvlcpstr>    = the string 'LvL', 'CP'\n" ..
						"<lvlstr>    = the string 'LvL', 'Chmp'\n" ..
						"<xpstr>     = the string 'XP', 'CP' \n",

	---------------------
	------- TAGS --------
	---------------------

	SXPB_TAG_XPSTR_TAG = "<xpstr>",
	SXPB_TAG_LVLSTR_TAG = "<lvlstr>",
	SXPB_TAG_LVL_TAG = "<lvl>",
	SXPB_TAG_XP_TAG = "<xp>",
	SXPB_TAG_XPMAX_TAG = "<xpmax>",
	SXPB_TAG_MOBS_TAG = "<mobs>",
	SXPB_TAG_PERC_TAG = "<perc>",
	SXPB_TAG_NEXTLVL_TAG = "<nextlvl>",
	
	SXPB_TAG_XPEN_TAG = "<xpen>",
	SXPB_TAG_XPNEED_TAG = "<xpneed>",
	
	SXPB_TAG_LVLCPSTR_TAG = "<lvlcpstr>",

	SXPB_TAG_XPSTR_CHAMP = "CP",
	SXPB_TAG_XPSTR_NORM = "XP",	

	SXPB_TAG_LVLSTR_CHAMP = "Chmp",
	SXPB_TAG_LVLSTR_NORM = "LvL",
	
	SXPB_TAG_LVLCPSTR_CHAMP = "CP",
	SXPB_TAG_LVLCPSTR_NORM = "LvL",

	SXPB_TAG_UNKNOWN = "???", -- <-- used to represent mobs before it has a value
}

for k,v in pairs(strings) do
	ZO_CreateStringId(k,v)
	SafeAddVersion(k, 1)
end