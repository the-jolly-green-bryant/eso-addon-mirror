local _addon = {
	name = "DailyCraftStatus",
	author = "@czerepx",
	website = "https://www.esoui.com/downloads/fileinfo.php?id=2510#info",
	version = "0.2.16",
	slashCmd = "/dcsbar",
	savedVariablesName = "DailyCraftStatusVars", 
	savedVariablesVersion = 1,

	posLocked = true,
	alwaysOn = false,
	autoSavePos = false,
	showStock = false,
	showRawStock = false,
	showSurveys = false,
	showInvSpace = false,
	questOrder = "",
	lowThres = 3,
	lowMatThres,
	lowStockWarn = false,
	sepBackpQty = false,
	hudOnly = false,
	updOnReset = false,
	keepOnWarn = false,
	rideTrain = false,
	hiddenInScene = false,
	pendingUpdates = false,
	keepIcon = true,
	trackAlts = false,
	inclConsum = false,
	showAbbrev = false,

	shareStyle,
	uiScale, 
	singleRow,
	alignCenter,
	barCenter,
	bgStyle,

	useIcons,
	iconSizes = {24,28,32,36},


	doingWrits = false,
	dailyReset = false,
	warnings = {},
	toolTipText = "",
	toolTipTextStock = "",
	lowStockItems = {},
	lowStockHist = {},
	mailStock = {},
}

function _addon.setAppearanceDefaults()
	_addon.uiScale = 1 
	_addon.singleRow = false
	_addon.useIcons = false
	_addon.bgStyle = 1
end

DailyCraftStatus = _addon
