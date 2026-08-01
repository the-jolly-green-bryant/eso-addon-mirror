local SK = SwissKnife
local SKH = SK.HelperFunctions

local function getPregameOptions()
	return {
		["InterfaceMisc"] = {
			["SkipEULAS"] = {
				n = GetString(SI_SK_PREGAME_SEU_TITLE),
				t = "checkbox"
			},
			["SkipPregameVideos"] = {
				n = GetString(SI_SK_PREGAME_SPV_TITLE),
				t = "checkbox"
			},
			["EnergySustainabilityMeasuresEnabled"] = {
				n = GetString(SI_SK_PREGAME_ESAM_TITLE),
				t = "checkbox"
			},
			--["HideRemotePetsAroundInteractableStations"] = {
			--	n = GetString(SI_SK_PREGAME_HRPAIS_TITLE),
			--	t = "checkbox"
			--},
			--["PregameAccessibilitySettingMenuEnabled"] = {
			--	t = "checkbox"
			--},
			--["PregameAccessibilityPromptEnabled"] = {
			--	t = "checkbox"
			--},
			--["HousingEditorSurfaceDragEnabled"] = {
			--	t = "checkbox"
			--},
		},
		["GuildHistory"] = {
			["EnableGuildHistoryLogging"] = {
				n = GetString(SI_SK_PREGAME_EGHL_TITLE),
				t = "checkbox",
				i = 0
			},
			["GuildHistoryCacheAutoDeleteLeftGuilds"] = {
				n = GetString(SI_SK_PREGAME_CADLG_TITLE),
				t = "checkbox",
				i = 1
			},
			["GuildHistoryCacheMaxNumberOfDays_ava_activity"] = {
				n = GetString(SI_SK_PREGAME_CMNDAA_TITLE),
				t = "slider",
				["m"] = 180,
				i = 6
			},
			["GuildHistoryCacheMaxNumberOfDays_activity"] = {
				n = GetString(SI_SK_PREGAME_CMNDA_TITLE),
				t = "slider",
				["m"] = 180,
				i = 7
			},
			--["GuildHistoryCacheMaxNumberOfDays_milestone"] = {
			--	t = "slider",
			--	["m"] = 180
			--},
			["GuildHistoryCacheMaxNumberOfDays_trader"] = {
				n = GetString(SI_SK_PREGAME_CMNDT_TITLE),
				t = "slider",
				m = 180,
				i = 5
			},
			["GuildHistoryCacheMaxNumberOfDays_banked_currency"] = {
				n = GetString(SI_SK_PREGAME_CMNDBC_TITLE),
				t = "slider",
				m = 180,
				i = 3
			},
			["GuildHistoryCacheMaxNumberOfDays_banked_item"] = {
				n = GetString(SI_SK_PREGAME_CMNDBI_TITLE),
				t = "slider",
				m = 180,
				i = 4
			},
			["GuildHistoryCacheMaxNumberOfDays_roster"] = {
				n = GetString(SI_SK_PREGAME_CMNDR_TITLE),
				t = "slider",
				m = 180,
				i = 2
			},
		}
	}
end

local function SysVarSetter(data, variable, value)
	if data then
		if data.t == "checkbox" then
			value = value and SK.TRUE or SK.FALSE
			print(value)
		end
		SetCVar(variable, tostring(value))
	end
end

local function SysVarGetter(data, variable)
	if data then
		local v = GetCVar(variable)
		if data.t == "checkbox" then return tonumber(v) == SK.TRUE end
		return tonumber(v)
	else
		return nil
	end
end

local function makeMenuControls(controls, section, firstIdx)
    local pregameOptions = getPregameOptions()
    local cidx = firstIdx
	local opt = pregameOptions[section]
	if opt then
		for v, data in pairs(opt) do
			local name = data.n
			if name == nil then
				name = v:gsub(section, ""):gsub("_", " "):gsub("(%u)", " %1"):gsub("^%s", ""):lower():gsub("^%l", string.upper)
			end
			local idx = cidx
			if data.i ~= nil then idx = firstIdx + data.i end
			controls[idx] = {
				type = data.t,
				name = name,
				getFunc = function() return SysVarGetter(data, v) end,
				setFunc = function(value) SysVarSetter(data, v, value) end,
				width = "full",
			}
			if data.t == "slider" then
				controls[idx].min = 1
				controls[idx].max = data.m
				controls[idx].decimals = 0
				controls[idx].step = 1
				controls[idx].inputLocation = "bottom"
			end
			if data.tt then
                controls[idx].tooltip = data.tt
            else
				controls[idx].tooltip = data.n
			end
			cidx = cidx + 1
		end
	end
	return controls
end

SK.HelperFunctions.SysVarGetter = SysVarGetter
SK.HelperFunctions.SysVarSetter = SysVarSetter
SK.HelperFunctions.getPregameOptions = getPregameOptions
SK.HelperFunctions.makeMenuControls = makeMenuControls
