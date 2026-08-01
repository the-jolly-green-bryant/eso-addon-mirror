local DEBUG =
-- function() end
d

local function _tr(str)
	return str
end

if not InventoryManager then InventoryManager = {} end
local IM = InventoryManager

local SE = IM.UI.Settings

function SE:GetControls()
	return {
		{
			type = "checkbox",
			name = GetString(IM_SET_BANK_LIMITS_GOLD),
			tooltip = GetString(IM_SET_BANK_LIMITS_TT),
			getFunc = function() return IM.settings.bankGold end,
			setFunc = function(value) IM.settings.bankGold = value end,
		},
		{
			type = "slider",
			name = GetString(IM_SET_MIN_GOLD),
			tooltip = GetString(IM_SET_MIN_GOLD_TOOLTIP),
			min = 0,
			max = 100000,
			getFunc = function() return IM.settings.minGold end,
			setFunc = function(value) IM.settings.minGold = value end,
			clampInput = false,
			width = "half",	--or "half" (optional)
		},
		{
			type = "slider",
			name = GetString(IM_SET_MAX_GOLD),
			tooltip = GetString(IM_SET_MAX_GOLD_TOOLTIP),
			min = 0,
			max = 100000,
			getFunc = function() return IM.settings.maxGold end,
			setFunc = function(value) IM.settings.maxGold = value end,
			clampInput = false,
			width = "half",	--or "half" (optional)
		},
		{
			type = "checkbox",
			name = GetString(IM_SET_BANK_LIMITS_TV),
			tooltip = GetString(IM_SET_BANK_LIMITS_TT),
			getFunc = function() return IM.settings.bankTV end,
			setFunc = function(value) IM.settings.bankTV = value end,
		},
		{
			type = "slider",
			name = GetString(IM_SET_MIN_TV),
			tooltip = GetString(IM_SET_MIN_TV_TOOLTIP),
			min = 0,
			max = 100000,
			getFunc = function() return IM.settings.minTV end,
			setFunc = function(value) IM.settings.minTV = value end,
			clampInput = false,
			width = "half",	--or "half" (optional)
		},
		{
			type = "slider",
			name = GetString(IM_SET_MAX_TV),
			tooltip = GetString(IM_SET_MAX_TV_TOOLTIP),
			min = 0,
			max = 100000,
			getFunc = function() return IM.settings.maxTV end,
			setFunc = function(value) IM.settings.maxTV = value end,
			clampInput = false,
			width = "half",	--or "half" (optional)
		},
		{
			type = "checkbox",
			name = GetString(IM_SET_BANK_LIMITS_AP),
			tooltip = GetString(IM_SET_BANK_LIMITS_AP),
			getFunc = function() return IM.settings.bankAP end,
			setFunc = function(value) IM.settings.bankAP = value end,
		},
		{
			type = "slider",
			name = GetString(IM_SET_MIN_AP),
			tooltip = GetString(IM_SET_MIN_AP_TOOLTIP),
			min = 0,
			max = 100000,
			getFunc = function() return IM.settings.minAP end,
			setFunc = function(value) IM.settings.minAP = value end,
			clampInput = false,
			width = "half",	--or "half" (optional)
		},
		{
			type = "slider",
			name = GetString(IM_SET_MAX_AP),
			tooltip = GetString(IM_SET_MAX_AP_TOOLTIP),
			min = 0,
			max = 100000,
			getFunc = function() return IM.settings.maxAP end,
			setFunc = function(value) IM.settings.maxAP = value end,
			clampInput = false,
			width = "half",	--or "half" (optional)
		},
		{
			type = "checkbox",
			name = GetString(IM_SET_BANK_LIMITS_WV),
			tooltip = GetString(IM_SET_BANK_LIMITS_WV),
			getFunc = function() return IM.settings.bankWV end,
			setFunc = function(value) IM.settings.bankWV = value end,
		},
		{
			type = "slider",
			name = GetString(IM_SET_MIN_VW),
			tooltip = GetString(IM_SET_MIN_VW_TOOLTIP),
			min = 0,
			max = 100000,
			getFunc = function() return IM.settings.minVW end,
			setFunc = function(value) IM.settings.minVW = value end,
			clampInput = false,
			width = "half",	--or "half" (optional)
		},
		{
			type = "slider",
			name = GetString(IM_SET_MAX_VW),
			tooltip = GetString(IM_SET_MAX_GOLD_VW),
			min = 0,
			max = 100000,
			getFunc = function() return IM.settings.maxVW end,
			setFunc = function(value) IM.settings.maxVW = value end,
			clampInput = false,
			width = "half",	--or "half" (optional)
		},
		{
			type = "slider",
			name = GetString(IM_SET_BANK),
			tooltip = GetString(IM_SET_BANK_TOOLTIP),
			min = 2,
			max = 200,
			getFunc = function() return IM.settings.bankMoveDelay end,
			setFunc = function(value) IM.settings.bankMoveDelay = value end,
			width = "half",	--or "half" (optional)
		},
		{
			type = "slider",
			name = GetString(IM_SET_START_BM),
			tooltip = GetString(IM_SET_START_BM_TT),
			min = 10,
			max = 5000,
			getFunc = function() return IM.settings.bankInitDelay end,
			setFunc = function(value) IM.settings.bankInitDelay = value end,
			width = "half",	--or "half" (optional)
		},
		{
			type = "slider",
			name = GetString(IM_SET_INV),
			tooltip = GetString(IM_SET_INV_TT),
			min = 2,
			max = 200,
			getFunc = function() return IM.settings.statusChangeDelay end,
			setFunc = function(value) IM.settings.statusChangeDelay = value end,
			width = "half",	--or "half" (optional)
		},
		{
			type = "slider",
			name = GetString(IM_SET_DEST),
			tooltip = GetString(IM_SET_DEST_TOOLTIP),
			min = 0,
			max = 500,
			getFunc = function() return IM.settings.destroyThreshold end,
			setFunc = function(value) IM.settings.destroyThreshold = value end,
			width = "half",	--or "half" (optional)
		},
		{
			type = "checkbox",
			name = GetString(IM_SET_AUTOSELL),
			tooltip = GetString(IM_SET_AUTOSELL_TOOLTIP),
			width = "half",
			getFunc = function() return IM.settings.autosell end,
			setFunc = function(value) IM.settings.autosell = value end,
		},
		{
			type = "description",
			text = "",
			width = "half",
		},
		{
			type = "checkbox",
			name = GetString(IM_SET_PROGRESS),
			tooltip = GetString(IM_SET_PROGRESS_TT),
			getFunc = function() return IM.settings.progressreport end,
			setFunc = function(value) IM.settings.progressreport = value end,
		},
		{
			type = "button",
			name = GetString(IM_SET_LIST),
			tooltip = GetString(IM_SET_LIST_TOOLTIP),
			func = function() IM:listrules() end,
			width = "half",	--or "half" (optional)
		},
		{
			type = "button",
			name = GetString(IM_SET_UNJUNK),
			tooltip = GetString(IM_SET_UNJUNK_TOOLTIP),
			func = function() IM:UnJunk() end,
			width = "half",	--or "half" (optional)
		},
		{
			type = "button",
			name = GetString(IM_SET_DRYRUN),
			tooltip = GetString(IM_SET_DRYRUN_TOOLTIP),
			func = function() IM:dryrun() end,
			width = "half",	--or "half" (optional)
		},
		{
			type = "button",
			name = GetString(IM_SET_RUN),
			tooltip = GetString(IM_SET_RUN_TOOLTIP),
			func = function() IM:WorkBackpack(false) end,
			width = "half",	--or "half" (optional)
		},
	}
end

function SE:PopulateUI()
end
