-----------------------------------------------------------
-- Author: SpringPeace2575 | Version: 0.9.0
-- Settings for RandoMote add-on
-----------------------------------------------------------

RandoMoteSettingsInner = RandoMoteSettingsInner or {}
local RMS = RandoMoteSettingsInner
local RMData = RandoMoteDataInner
local RMEmotes = RandoMoteEmotesInner
local RMPlayer = RandoMotePlayerInner

RMS.name = "RandoMoteDev"

RMS.sv = {
    enable = true,
    debug = false,
    useStandard = true,
    useCollectible = true,
    useFavouriteOnly = false,
    selectedPreset = "None",
    showLocked = false,
    showSlash = false,
    chatOutput = false,
    idleMax = 15,
    minTime = 10,
    maxTime = 30,
    useEmote = {},
    useCategory = {},
    favEmote = {},
	presetEmote = {
        None = {},
        Dancer = {},
        Musician = {},
        Goofball = {},
        Custom1 = {},
        Custom2 = {},
        Custom3 = {},
    },
}

RMS.defaults = {
	enable          = true,
    debug			= false,
	useStandard		= true,
	useCollectible	= true,
	useFavouriteOnly= false,
	selectedPreset	= "None",
	showLocked		= false,
	showSlash		= false,
	chatOutput		= false,
	idleMax         = 15,
	minTime			= 10,
    maxTime			= 30,
	useEmote		= {},
	useCategory		= {},
	favEmote		= {},
	presetEmote		= {
		None		= {},
		Dancer		= {},
		Musician	= {},
		Goofball	= {},
		Custom1		= {},
		Custom2		= {},
		Custom3		= {},
	},
}

-- Settings state (for fast label updates without rebuilding large pages)
RMS.state = {
    addonSettings = nil,
    page = nil,
    emoteHeaderIndex = nil,
    presetHeaderIndex = nil,
    currentCid = nil,
    currentPreset = nil,
    currentEmote = nil,
	currentEmoteListPage = nil,
	categoriesAllIndex = nil,
	categoryRowIndexByCid = {},
	presetRowIndexByPreset = {},
	emoteRowIndexByEmote = {},
}

function RMS.Initialize(sv, defaults, name)
	RMS.sv = sv
	RMS.defaults = defaults
    RMS.name = name

	RMS.EnsureSavedVariables()
    RMS.EnsureState()
end

function RMS.EnsureSavedVariables()
	if type(RMEmotes.sv.enable) ~= "boolean" then RMEmotes.sv.enable = true end
	if type(RMEmotes.sv.debug) ~= "boolean" then RMEmotes.sv.debug = false end
	if type(RMEmotes.sv.useStandard) ~= "boolean" then RMEmotes.sv.useStandard = true end
	if type(RMEmotes.sv.useCollectible) ~= "boolean" then RMEmotes.sv.useCollectible = true end
	if type(RMEmotes.sv.useFavouriteOnly) ~= "boolean" then RMEmotes.sv.useFavouriteOnly = false end
	if type(RMEmotes.sv.selectedPreset) ~= "string" then RMEmotes.sv.selectedPreset = "None" end
	if type(RMEmotes.sv.showLocked) ~= "boolean" then RMEmotes.sv.showLocked = false end
	if type(RMEmotes.sv.showSlash) ~= "boolean" then RMEmotes.sv.showSlash = false end
	if type(RMEmotes.sv.chatOutput) ~= "boolean" then RMEmotes.sv.chatOutput = false end
	if type(RMEmotes.sv.idleMax) ~= "number" then RMEmotes.sv.idleMax = 15 end
	if type(RMEmotes.sv.minTime) ~= "number" then RMEmotes.sv.minTime = 10 end
	if type(RMEmotes.sv.maxTime) ~= "number" then RMEmotes.sv.maxTime = 30 end
	if type(RMEmotes.sv.useEmote) ~= "table" then RMEmotes.sv.useEmote = {} end
	if type(RMEmotes.sv.useCategory) ~= "table" then RMEmotes.sv.useCategory = {} end
	if type(RMEmotes.sv.favEmote) ~= "table" then RMEmotes.sv.favEmote = {} end
	if type(RMEmotes.sv.presetEmote) ~= "table" then
		RMEmotes.sv.presetEmote = {
			None = {},
			Dancer = {},
			Musician = {},
			Goofball = {},
			Custom1 = {},
			Custom2 = {},
			Custom3 = {},
		}
	end
end

function RMS.EnsureState()
	RMS.state.addonSettings = RMS.state.addonSettings or nil
	RMS.state.page = RMS.state.page or nil
	RMS.state.emoteHeaderIndex = RMS.state.emoteHeaderIndex or nil
	RMS.state.presetHeaderIndex = RMS.state.presetHeaderIndex or nil
	RMS.state.currentCid = RMS.state.currentCid or nil
	RMS.state.currentPreset = RMS.state.currentPreset or nil
	RMS.state.currentEmote = RMS.state.currentEmote or nil
	RMS.state.currentEmoteListPage = RMS.state.currentEmoteListPage or nil
	RMS.state.categoriesAllIndex = RMS.state.categoriesAllIndex or nil
	RMS.state.categoryRowIndexByCid = RMS.state.categoryRowIndexByCid or {}
	RMS.state.presetRowIndexByPreset = RMS.state.presetRowIndexByPreset or {}
	RMS.state.emoteRowIndexByEmote = RMS.state.emoteRowIndexByEmote or {}
end

function RMS.RegisterSettings(panelData, settingsPanelId)
	local options = RMS.BuildCategoriesPage() -- naming? GetSettingsOptions()
	RMS.RebuildIndexMaps(options)
	-- SPFLibSettings.ReplaceSettings(RMS.state.addonSettings, option, true)

	SPFLibSettings.HookHarvensNavigation(settingsPanelId, RMS.SettingsGoBack)
	SPFLibSettings.RegisterSettingsPanelControlled(settingsPanelId, panelData, options, RMS.ConsoleSetDefaultsContext, RMS.SetSettings)
end

function RMS.RefreshSettings()
	if RMS.state == nil then return end
	local page = RMS.state.page
	local cid = RMS.state.currentCid
	local preset = RMS.state.currentPreset

	if page == "categories" then
		RMS.ConsoleUpdateCategoriesLabels()
	end

	if page == "emotes" then
		RMS.ConsoleUpdateEmoteHeader(cid)
		RMS.ConsoleUpdatePresetHeader(preset)
		RMS.ConsoleUpdateCategoryEmoteListLabels(cid)
		RMS.ConsoleUpdatePresetEmoteListLabels(preset)
	end

	if page == "emoteDetail" then
		RMS.ConsoleUpdateEmoteHeader(cid)
		RMS.ConsoleUpdatePresetHeader(preset)
	end
	SPFLibSettings.RefreshSettings()
end

function RMS.ConsoleUpdateCategoriesLabels()
	if not RMS.state or not RMS.state.addonSettings then return end
	local addonSettings = RMS.state.addonSettings
	if addonSettings == nil or addonSettings.settings == nil then return end
	if RMS.state.page ~= "categories" then return end

	-- Update "All Emotes" header
	local allIdx = RMS.state.categoriesAllIndex
	if allIdx and addonSettings.settings[allIdx] then
		addonSettings.settings[allIdx].labelText = RMEmotes.GetEmotesCountsDisplayInfo()
	end

	-- Update each category button label
	local mapC = RMS.state.categoryRowIndexByCid
	if mapC then
		for cid, idx in pairs(mapC) do
			if idx and addonSettings.settings[idx] then
				addonSettings.settings[idx].labelText = RMEmotes.GetCategoryInfoToDisplay(cid)
			end
		end
	end

	-- Update each preset button label
	local mapP = RMS.state.presetRowIndexByPreset
	if mapP then
		for preset, idx in pairs(mapP) do
			if idx and addonSettings.settings[idx] then
				addonSettings.settings[idx].labelText = RMEmotes.GetPresetInfoToDisplay(preset)
			end
		end
	end
end

function RMS.ConsoleUpdateEmoteHeader(cid)
	if not RMS.state or not RMS.state.addonSettings then return end
	local addonSettings = RMS.state.addonSettings
	if addonSettings == nil or addonSettings.settings == nil then return end
	if cid == nil then return end
	if (RMS.state.page ~= "emotes" and RMS.state.page ~= "emoteDetail") or RMS.state.currentCid ~= cid then return end

	local idx = RMS.state.emoteHeaderIndex
	if idx and addonSettings.settings[idx] ~= nil then
		addonSettings.settings[idx].labelText = RMEmotes.GetCategoryInfoToDisplay(cid)
	end
end

function RMS.ConsoleUpdatePresetHeader(preset)
	if not RMS.state or not RMS.state.addonSettings then return end
	local addonSettings = RMS.state.addonSettings
	if addonSettings == nil or addonSettings.settings == nil then return end
	if preset == nil then return end
	if (RMS.state.page ~= "emotes" and RMS.state.page ~= "emoteDetail") or RMS.state.currentPreset ~= preset then return end

	local idx = RMS.state.presetHeaderIndex
	if idx and addonSettings.settings[idx] ~= nil then
		addonSettings.settings[idx].labelText = RMEmotes.GetPresetInfoToDisplay(preset)
	end
end

function RMS.SettingsGoBack()
	local page = RMS.state.page
	if page == "emoteDetail" then
		local cid = RMS.state.currentCid
		local preset = RMS.state.currentPreset
		if cid ~= nil or preset ~= nil then
			SPFLibUtils.ConsolePlayBackSound()
			local options = RMS.BuildEmotesPage(cid, preset)
			RMS.RebuildIndexMaps(options)
			SPFLibSettings.ReplaceSettings(RMS.state.addonSettings, options, true, RMS._consoleEmoteIndex)
			return true
		end
	elseif page == "emotes" then
		SPFLibUtils.ConsolePlayBackSound()
		local options = RMS.BuildCategoriesPage()
		RMS.RebuildIndexMaps(options)
		SPFLibSettings.ReplaceSettings(RMS.state.addonSettings, options, true, RMS._consoleCategoriesIndex)
		return true
	end

	return false
end

function RMS.SetSettings(addonSettings)
	RMS.state.addonSettings = addonSettings
end

function RMS.ResetGlobals()
	for k, v in pairs(RMS.defaults) do
		if k ~= "useEmote" and k ~= "useCategory" and k ~= "favEmote" and k ~= "presetEmote" then
			RMS.sv[k] = v
		end
	end
end

function RMS.ConsoleSetDefaultsContext()
	if RMS.state == nil then return end
	local page = RMS.state.page

	if page == "categories" then
		RMS.ResetGlobals()
		RMEmotes.ResetCategories()
		RMEmotes.ResetPresets()
		RMEmotes.ResetEmotesInPresets()
		RMPlayer.ResetTimer()

		local options = RMS.BuildCategoriesPage()
		RMS.RebuildIndexMaps(options)
		SPFLibSettings.ReplaceSettings(RMS.state.addonSettings, options, true, RMS._consoleCategoriesIndex)
		return
	end

	if page == "emotes" then
		local cid = RMS.state.currentCid
		local preset = RMS.state.currentPreset

		RMEmotes.ResetCategory(cid)
		RMEmotes.ResetEmotesInCategory(cid)
		RMEmotes.ResetPreset(preset)
		RMEmotes.ResetEmotesInPreset(preset)
		RMPlayer.ResetTimer()

		RMS.ConsoleUpdateEmoteHeader(cid)
		RMS.ConsoleUpdatePresetHeader(preset)
		RMS.ConsoleUpdateCategoryEmoteListLabels(cid)
		RMS.ConsoleUpdatePresetEmoteListLabels(preset)
		return
	end

	if page == "emoteDetail" then
		local cid = RMS.state.currentCid
		local preset = RMS.state.currentPreset
		local emote = RMS.state.currentEmote

		RMEmotes.ResetEmote(emote)
		RMEmotes.ResetEmoteInPresets(emote)
		RMPlayer.ResetTimer()

		RMS.ConsoleUpdateEmoteHeader(cid)
		RMS.ConsoleUpdatePresetHeader(preset)
		-- RMS.ConsoleUpdateCategoryEmoteListLabels(cid) -- TODO: this probably not needed here
		return
	end
end

function RMS.ConsoleUpdateCategoryEmoteListLabels(cid)
	if RMS.state == nil then return end
	if RMS.state.page ~= "emotes" then return end
	if RMS.state.currentCid ~= cid then return end
	local addonSettings = RMS.state.addonSettings
	if addonSettings == nil or addonSettings.settings == nil then return end
	local list = RMEmotes.GetCategoryEmoteList(cid)
	local map = RMS.state.emoteRowIndexByEmote
	if map == nil then return end

	for _, emote in ipairs(list) do
		local key = emote.emoteKey
		local idx = map[key]
		if idx ~= nil and addonSettings.settings[idx] ~= nil then
			local label = RMEmotes.GetEmoteInfoToDisplayWithFlags(emote)
			addonSettings.settings[idx].labelText = label
		end
	end
end

function RMS.ConsoleUpdatePresetEmoteListLabels(preset)
	if RMS.state == nil then return end
	if RMS.state.page ~= "emotes" then return end
	if RMS.state.currentPreset ~= preset then return end
	local addonSettings = RMS.state.addonSettings
	if addonSettings == nil or addonSettings.settings == nil then return end
	local list = RMEmotes.GetPresetEmoteList(preset)
	local map = RMS.state.emoteRowIndexByEmote
	if map == nil then return end

	for _, emote in ipairs(list) do
		local key = emote.emoteKey
		local idx = map[key]
		if idx ~= nil and addonSettings.settings[idx] ~= nil then
			local label = RMEmotes.GetEmoteInfoToDisplayWithFlags(emote)
			addonSettings.settings[idx].labelText = label
		end
	end
end

function RMS.RebuildIndexMaps(options)
	-- Build fast label update index maps for Categories page
	if options ~= nil and RMS.state.page == "categories" then
		RMS.state.categoriesAllIndex = nil
		RMS.state.categoryRowIndexByCid = {}
		RMS.state.presetRowIndexByPreset = {}
		local pIndex = 0
		for _, c in ipairs(options) do
			local t = c.type
			-- Types that convert to a single Harvens setting row
			if t == "checkbox" or t == "slider" or t == "dropdown" or t == "description" or t == "image" or t == "button" or t == "submenu" or t == "divider" or t == "label" or t == "space" then
				pIndex = pIndex + 1
				if c.rm_id == "all_emotes_header" then
					RMS.state.categoriesAllIndex = pIndex
				elseif c.rm_cid ~= nil then
					RMS.state.categoryRowIndexByCid[c.rm_cid] = pIndex
				elseif c.rm_preset ~= nil then
					RMS.state.presetRowIndexByPreset[c.rm_preset] = pIndex
				end
			end
		end
	end
end

function RMS.BuildEmoteDetailPage(preset, emote)
	RMS.state.currentEmote = emote
	-- Level 3: details/toggles for a single emote
	local key = emote.emoteKey

	local lamControls = {}

	if preset ~= nil then
		table.insert(lamControls, {
			type = "submenu",
			name = RMEmotes.GetPresetInfoToDisplay(preset),
		})
	end

	-- Category header with counts (kept for context)
	table.insert(lamControls, {
		type = "submenu",
		name = RMEmotes.GetCategoryInfoToDisplay(emote.categoryId),
	})

	table.insert(lamControls, {
		type = "submenu",
		name = RMEmotes.GetEmoteInfoToDisplay(emote)
	})

	--[[ -- this does not work, because used PreviewCollectible() inside is private
	if emote.collectibleId then
		table.insert(lamControls, {
			type = "button",
			name = function() return IsCurrentlyPreviewing() and "End Preview" or "Preview" end,
			width = "half",
			func = function()
				d("[RM]: CanCollectibleBePreviewed - "..tostring(CanCollectibleBePreviewed(emote.collectibleId)))
				d("[RM]: IsCharacterPreviewingAvailable - "..tostring(IsCharacterPreviewingAvailable()))
				d("[RM]: ITEM_PREVIEW_GAMEPAD.GetFragment.IsShowing - "..tostring(ITEM_PREVIEW_GAMEPAD:GetFragment():IsShowing()))
				if IsCurrentlyPreviewing() then
					ITEM_PREVIEW_GAMEPAD:EndCurrentPreview()
					DisablePreviewMode()
				else
					EnablePreviewMode(false)
					ITEM_PREVIEW_GAMEPAD:PreviewCollectible(emote.collectibleId)
				end
			end,
		})
	end ]]

	table.insert(lamControls, {
		type = "button",
		name = "Play",
		width = "half",
		func = function() RMPlayer.PlayEmoteNow(emote) end,
	})

	table.insert(lamControls, {
		type = "checkbox",
		name = "Enable",
		default = true,
		getFunc = function() return RMS.sv.useEmote[key] == true end,
		setFunc = function(v)
			RMS.sv.useEmote[key] = v
			RMEmotes.RequestRebuildEmoteLists()
			-- keep category toggle in sync: if any emote disabled, category is not fully enabled (but do not force true/false here)
			RMS.ConsoleUpdateEmoteHeader(emote.categoryId)
			RMS.ConsoleUpdatePresetHeader(preset)
			-- RMS.ConsoleUpdateCategoryEmoteListLabels(emote.categoryId)
			SPFLibSettings.RefreshSettings()
		end,
	})

	table.insert(lamControls, {
		type = "checkbox",
		name = "Favourite",
		default = false,
		getFunc = function() return RMS.sv.favEmote[key] == true end,
		setFunc = function(v)
			RMS.sv.favEmote[key] = v
			RMEmotes.RequestRebuildEmoteLists()
		end,
	})

	for i = 2, #RMData.Presets do
		local preset = RMData.Presets[i]
		table.insert(lamControls, {
			type = "checkbox",
			name = RMData.PresetNamesMap[preset] .. " Preset",
			default = false,
			getFunc = function() return RMEmotes.IsEmoteInPreset(preset, key) end,
			setFunc = function(v)
				RMS.sv.presetEmote[preset][key] = v
				RMEmotes.RebuildPresetEmoteState()
				RMEmotes.RequestRebuildEmoteLists()
			end,
		})
	end

	RMS.state.page = "emoteDetail"
	RMS.state.currentCid = preset == nil and emote.categoryId or nil
	RMS.state.currentPreset = preset
	if preset ~= nil then
		RMS.state.presetHeaderIndex = 1 -- preset header position on this page
		RMS.state.emoteHeaderIndex = 2 -- category header position on this page
	else
		RMS.state.emoteHeaderIndex = 1 -- category header position on this page
	end
	return lamControls
end

function RMS.GetEmotesPagination(totalItems, cid)
	local pageSize = 50
	local totalPages = math.max(1, math.ceil(totalItems / pageSize))
	local page = RMS.state.currentEmoteListPage
		-- or (RMS.state.emotePageByCid and RMS.state.emotePageByCid[cid])
		or 1
	if page < 1 then page = 1 end
	if page > totalPages then page = totalPages end

	-- remember current page for this category
	-- RMS.state.emotePageByCid = RMS.state.emotePageByCid or {}
	-- RMS.state.emotePageByCid[cid] = page

	local fromIndex = (page - 1) * pageSize + 1
	local toIndex = math.min(totalItems, page * pageSize)

	return totalPages, page, fromIndex, toIndex
end

local function sublist(t, fromIndex, toIndex)
    local result = {}

    -- Ensure boundaries
    fromIndex = math.max(1, fromIndex)
    toIndex = math.min(#t, toIndex)

    for i = fromIndex, toIndex do
        table.insert(result, t[i])
    end

    return result
end

function RMS.BuildPaginationControls(totalPages, page, cid, preset)
	local lamControls = {}

	if totalPages > 1 then
		table.insert(lamControls, {
			type = "label",
			name = "(" .. tostring(page) .. "/" .. tostring(totalPages) .. ")",
		})

		table.insert(lamControls, {
			type = "button",
			name = "Prev",
			buttonText = "Prev Page",
			disabled = (page <= 1),
			func = function()
				if not (page <= 1) then
					RMS.state.currentEmoteListPage = page - 1
					local options = RMS.BuildEmotesPage(cid, preset)
					RMS.RebuildIndexMaps(options)
					SPFLibSettings.ReplaceSettings(RMS.state.addonSettings, options, true)
				end
			end,
			width = "half",
		})

		table.insert(lamControls, {
			type = "button",
			name = "Next",
			buttonText = "Next Page",
			disabled = (page >= totalPages),
			func = function()
				if not (page >= totalPages) then
					RMS.state.currentEmoteListPage = page + 1
					local options = RMS.BuildEmotesPage(cid, preset)
					RMS.RebuildIndexMaps(options)
					SPFLibSettings.ReplaceSettings(RMS.state.addonSettings, options, true)
				end
			end,
			width = "half",
		})

		table.insert(lamControls, { type = "space", height = 15, alpha = 1.0, width = "full" })
	end

	return lamControls
end

function RMS.BuildEmotesPage(cid, preset)
	-- Level 2: list emotes in a category (minimal controls for performance)
	local list = RMEmotes.GetCategoryOrPresetEmotesList(cid, preset)

	local lamControls = {}
	RMS.state.emoteRowIndexByEmote = {}

	if cid ~= nil then
		table.insert(lamControls, {
			type = "submenu",
			name = RMEmotes.GetCategoryInfoToDisplay(cid),
		})

		table.insert(lamControls, {
			type = "checkbox",
			name = "All Enable",
			default = true,
			getFunc = function() return RMS.sv.useCategory[cid] ~= false end,
			setFunc = function(v)
				RMS.sv.useCategory[cid] = v
				for _, emote in ipairs(list) do
					local k = emote.emoteKey
					RMS.sv.useEmote[k] = v
				end
				RMEmotes.RequestRebuildEmoteLists()
				RMS.ConsoleUpdateEmoteHeader(cid)
				RMS.ConsoleUpdateCategoryEmoteListLabels(cid)
				SPFLibSettings.RefreshSettings()
			end,
		})
	elseif preset ~= nil then
		table.insert(lamControls, {
			type = "submenu",
			name = RMEmotes.GetPresetInfoToDisplay(preset),
		})
	end

	table.insert(lamControls, { type = "space", height = 15, alpha = 1.0, width = "full" })

	-- Add pegination if needed
	local totalPages, page, fromIndex, toIndex = RMS.GetEmotesPagination(#list, cid)
	if totalPages > 1 then
		local paginationControls = RMS.BuildPaginationControls(totalPages, page, cid, preset)
		for _, c in ipairs(paginationControls) do table.insert(lamControls, c) end
		list = sublist(list, fromIndex, toIndex)
	end

	-- Emote entries: one button each (fast). Clicking opens detail page.
	for _, emote in ipairs(list) do
		local key = emote.emoteKey
		table.insert(lamControls, {
			type = "button",
			name = RMEmotes.GetEmoteInfoToDisplayWithFlags(emote),
			buttonText = "Open",
			func = function()
				RMS._consoleEmoteIndex = SPFLibSettings.GetSelectedIndex()
				local options = RMS.BuildEmoteDetailPage(preset, emote)
				RMS.RebuildIndexMaps(options)
				SPFLibSettings.ReplaceSettings(RMS.state.addonSettings, options, false)
			end,
		})
		RMS.state.emoteRowIndexByEmote[key] = #lamControls
	end

	RMS.state.page = "emotes"
	RMS.state.currentCid = cid
	RMS.state.currentPreset = preset
	if cid ~= nil then
		RMS.state.emoteHeaderIndex = 1
	elseif preset ~= nil then
		RMS.state.presetHeaderIndex = 1
	end
	return lamControls
end

function RMS.BuildCategoriesPage()
	RMS.state.page = "categories"
	RMS.state.currentCid = nil
	RMS.state.currentEmoteListPage = nil
	local lamControls = {}
	for _, c in ipairs(RMS.BuildGlobalSettingsControls()) do table.insert(lamControls, c) end

	table.insert(lamControls, { type = "space", height = 15, alpha = 1.0, width = "full" })
	table.insert(lamControls, {
		type = "submenu",
		rm_id = "all_emotes_header",
		name = RMEmotes.GetEmotesCountsDisplayInfo(),
	})

	for _, cid in ipairs(RMEmotes.GetCategoryIds()) do
		table.insert(lamControls, {
			type = "button",
			rm_cid = cid,
			name = RMEmotes.GetCategoryInfoToDisplay(cid),
			buttonText = "Open Category",
			func = function()
				RMS._consoleCategoriesIndex = SPFLibSettings.GetSelectedIndex()
				local options = RMS.BuildEmotesPage(cid, nil)
				RMS.RebuildIndexMaps(options)
				SPFLibSettings.ReplaceSettings(RMS.state.addonSettings, options, false)
			end,
		})
	end

	table.insert(lamControls, {
		type = "submenu",
		name = "Presets",
	})

	for i = 2, #RMData.Presets do
		local preset = RMData.Presets[i]
		table.insert(lamControls, {
			type = "button",
			rm_preset = preset,
			name = RMEmotes.GetPresetInfoToDisplay(preset),
			buttonText = "Open Preset",
			func = function()
				RMS._consoleCategoriesIndex = SPFLibSettings.GetSelectedIndex()
				local options = RMS.BuildEmotesPage(nil, preset)
				RMS.RebuildIndexMaps(options)
				SPFLibSettings.ReplaceSettings(RMS.state.addonSettings, options, false)
			end,
		})
	end

	return lamControls
end

function RMS.BuildGlobalSettingsControls()
	return SPFLibUtils.ConcatArrays(SPFLibUtils.GetDonationSettingsOptions(RMS.name), {
		{
			type = "checkbox",
			name = "Enable",
			tooltip = "Enable or disable random emotes.",
			default = RMS.defaults.enable,
			getFunc = function() return RMS.sv.enable end,
			setFunc = function(v)
				RMS.sv.enable = v
				RMPlayer.ResetTimer()
			end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Use Standard Emotes",
			default = RMS.defaults.useStandard,
			getFunc = function() return RMS.sv.useStandard end,
			setFunc = function(v)
				RMS.sv.useStandard = v
				RMEmotes.RequestRebuildEmoteLists()
				RMPlayer.ResetTimer()
				RMS.ConsoleUpdateCategoriesLabels()
				SPFLibSettings.RefreshSettings()
			end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Use Collectible Emotes",
			default = RMS.defaults.useCollectible,
			getFunc = function() return RMS.sv.useCollectible end,
			setFunc = function(v)
				RMS.sv.useCollectible = v
				RMEmotes.RequestRebuildEmoteLists()
				RMPlayer.ResetTimer()
				RMS.ConsoleUpdateCategoriesLabels()
				SPFLibSettings.RefreshSettings()
			end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Use Favourite only",
			tooltip = "If enabled, random will play only emotes marked as FAV.",
			default = RMS.defaults.useFavouriteOnly,
			getFunc = function() return RMS.sv.useFavouriteOnly end,
			setFunc = function(v)
				RMS.sv.useFavouriteOnly = v
				RMPlayer.ResetTimer()
				RMS.ConsoleUpdateCategoriesLabels()
				SPFLibSettings.RefreshSettings()
			end,
			width = "full",
		},
		{
			type = "dropdown",
			name = "Use Preset only",
			tooltip = "If selected, random will play only emotes included in the selected preset.",
			default = RMS.defaults.selectedPreset,
			choices = RMData.PresetNames,
			choicesValues = RMData.Presets,
			getFunc = function() return RMS.sv.selectedPreset end,
			setFunc = function(v)
				RMS.sv.selectedPreset = v
				RMEmotes.RequestRebuildEmoteLists()
				RMPlayer.ResetTimer()
				RMS.ConsoleUpdateCategoriesLabels()
				SPFLibSettings.RefreshSettings()
			end,
		},
		{
			type = "checkbox",
			name = "Show locked",
			tooltip = "Show also locked collectible emotes.",
			default = RMS.defaults.showLocked,
			getFunc = function() return RMS.sv.showLocked end,
			setFunc = function(v)
				RMS.sv.showLocked = v
				RMPlayer.ResetTimer()
				RMS.ConsoleUpdateCategoriesLabels()
				SPFLibSettings.RefreshSettings()
			end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Show slash",
			tooltip = "Show slash of emote.",
			default = RMS.defaults.showSlash,
			getFunc = function() return RMS.sv.showSlash end,
			setFunc = function(v)
				RMS.sv.showSlash = v
				RMPlayer.ResetTimer()
				RMS.ConsoleUpdateCategoriesLabels()
				SPFLibSettings.RefreshSettings()
			end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Chat Output",
			tooltip = "Enable or disable printing selected emote and delay to chat.",
			default = RMS.defaults.chatOutput,
			getFunc = function() return RMS.sv.chatOutput end,
			setFunc = function(v) RMS.sv.chatOutput = v end,
			width = "full",
		},
        {
            type = "checkbox",
            name = "Debug chat output",
            default = RMS.defaults.debug,
            getFunc = function() return RMS.sv.debug end,
            setFunc = function(v) RMS.sv.debug = v end,
            width = "full",
        },
		{
			type = "slider",
			name = "Idle Time",
			tooltip = "How long player should be idle before emotes start. (Seconds)",
			min = 1, max = 60, step = 1,
			default = RMS.defaults.idleMax,
			getFunc = function() return RMS.sv.idleMax end,
			setFunc = function(v)
				RMS.sv.idleMax = v
				RMPlayer.ResetTimer()
			end,
			width = "full",
		},
		{
			type = "slider",
			name = "Emote Delay Minimum",
			tooltip = "Minimum delay between emotes. (Seconds)",
			min = 1, max = 120, step = 1,
			default = RMS.defaults.minTime,
			getFunc = function() return RMS.sv.minTime end,
			setFunc = function(v)
				RMS.sv.minTime = v
				RMPlayer.ResetTimer()
			end,
			width = "full",
		},
		{
			type = "slider",
			name = "Emote Delay Maximum",
			tooltip = "Maximum delay between emotes. (Seconds)",
			min = 1, max = 600, step = 1,
			default = RMS.defaults.maxTime,
			getFunc = function() return RMS.sv.maxTime end,
			setFunc = function(v)
				RMS.sv.maxTime = v
				RMPlayer.ResetTimer()
			end,
			width = "full",
		},
	})
end
