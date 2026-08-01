YeOldeInfos = YeOldeInfos or {}
YeOldeInfos.AddonName = "YeOldeInfos"

YeOldeInfos.SETTING_PATTERN = "<<1>>Control<<2>>"
YeOldeInfos.SETTING_DESC_TITLE_PATTERN = "|cDA8A00<<1>> :|r"
YeOldeInfos.SETTING_DESC_CONTENT_PATTERN = "|c777777<<1>>|r"

YeOldeInfos.Default = {
	Bars = {},

	HideInMenu = false,
	HideInGame = false,
	ShowExt = false, -- v1.4
	FontType = "MEDIUM_FONT", -- v1.4
	FontSize = "16", -- v1.4
	IconScale = 1, -- v1.4
}

YeOldeInfos.ToolTip = {
	MIN_WIDTH = 250,
	MAX_WIDTH = 400,
	AUTO_SIZE = 0,
}

-- Daily quest states
YeOldeInfos.CraftingQuestStatus = {
	UNAVAILABLE = 0,
	AVAILABLE = 1,
	ACTIVE = 2,
	READY_TO_DELIVER = 3,
	COMPLETED = 4,
	UNKNOWN = 5,
}

-- Color definitions for YeOlde addons
YeOldeInfos.Colors = {
	DISABLED = ZO_DISABLED_TEXT,
	WHITE = ZO_WHITE,
	GOLD = ZO_ColorDef:New("DA8A00"),
	YELLOW = ZO_ColorDef:New("f5c904"),
	GREEN = ZO_ColorDef:New("3E7A00"),
	BLUE = ZO_ColorDef:New("176C65"),
	RED = ZO_ColorDef:New("FF0000"),
	GRAY = ZO_ColorDef:New(0.5, 0.5, 0.5),
}
