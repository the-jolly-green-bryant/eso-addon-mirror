local GF = GroupFinderPlus

function GF.RegisterLAMPanel()
	local LAM = LibAddonMenu2

	local function Iconize(name, iconPath, size)
		size = size or 20
		return string.format("|t%d:%d:%s|t %s", size, size, iconPath, name)
	end

	GF.Settings.CategoriesEnabled = GF.Settings.CategoriesEnabled or {}
	for _, cat in ipairs(GF.Categories) do
		if GF.Settings.CategoriesEnabled[cat.id] == nil then
			GF.Settings.CategoriesEnabled[cat.id] = true
		end
	end

	for short, _ in pairs(GF.Trials) do
		if GF.Settings.TrialsEnabled[short] == nil then
			GF.Settings.TrialsEnabled[short] = true
		end
	end

	local optionsData = {
		{
			type = "header",
			name = "|t35:35:/esoui/art/leveluprewards/gamepad/levelup_gp_attribute_32.dds|tGeneral Settings",
		},
		{
			type = "checkbox",
			name = "Allow All Roles In Group Finder",
			tooltip = "Keeps the 'Enforce Roles' filter off by default when searching for groups",
			getFunc = function() return GF.Settings.AllowAllRoles end,
			setFunc = function(value)
				GF.Settings.AllowAllRoles = value
			end,
			default = true,
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = "Hide Listings if CP is Insufficient",
			tooltip = "Hide trials/activities where your champion points are too low to join.",
			getFunc = function() return GF.Settings.HideInsufficientCP end,
			setFunc = function(value)
				GF.Settings.HideInsufficientCP = value
				GF.RefreshUI()
			end,
			default = false,
		},
		{
			type = "checkbox",
			name = "Hide WTS Listings (not in Custom category)",
			tooltip = "Hide listings whose titles contain 'WTS' (want to sell).",
			getFunc = function() return GF.Settings.HideWTSListings end,
			setFunc = function(value)
				GF.Settings.HideWTSListings = value
				GF.RefreshUI()
			end,
			default = true,
		},

		{
			type = "checkbox",
			name = "Show Instance Name in Tooltip",
			tooltip = "Switch to enable/disable showing localized target instance name in a tooltip.",
			getFunc = function() return GF.Settings.ShowInstanceTooltip end,
			setFunc = function(value)
				GF.Settings.ShowInstanceTooltip = value
			end,
			default = true,
		},

		{
			type = "checkbox",
			name = "Show Normal / Veteran Toggle Button",
			tooltip = "Show or hide the Normal–Veteran toggle button next to the category selector.",
			getFunc = function()
				return GF.Settings.ShowInstanceModeButton
			end,
			setFunc = function(value)
				GF.Settings.ShowInstanceModeButton = value

				if GF.leftTopButton then
					GF.leftTopButton:SetHidden(not value)
				end

				GF.UpdateInstanceModeButtonVisibility()
			end,
			default = true,
		},

		{
			type = "checkbox",
			name = "Save Last Selected Category",
			tooltip = "If enabled, GroupFinder+ will remember the last selected category between sessions.",
			getFunc = function()
				return GF.Settings.SaveLastCategory
			end,
			setFunc = function(value)
				GF.Settings.SaveLastCategory = value
			end,
			default = false,
		},

		{
			type = "checkbox",
			name = "Full Description For Achievement Links",
			tooltip = "If enabled, any achievements viewed from a link will always have description fully visible.",
			getFunc = function()
				return GF.Settings.FullAchievements
			end,
			setFunc = function(value)
				GF.Settings.FullAchievements = value
			end,
			default = true,
		},

		{
			type = "checkbox",
			name = "|cff0000R|cff7f00a|cffff00i|c00ff00n|c0000ffb|c4b0082o|c9400d3w|r Effect for Last Boss Listings",
			tooltip = "If enabled, listings that mention 'last boss' will have a rainbow background effect.",
			getFunc = function()
				return GF.Settings.LastBossRainbow
			end,
			setFunc = function(value)
				GF.Settings.LastBossRainbow = value
				if GF.win and not GF.win:IsHidden() then
					GF.RefreshUI()
				end
			end,
			default = false,
		},

		{
			type = "checkbox",
			name = "Hide UI in Dungeons and Trials",
			tooltip = "If enabled, UI will auto-hide when joining a dungeon or a trial.",
			getFunc = function()
				return GF.Settings.HideInInstance
			end,
			setFunc = function(value)
				GF.Settings.HideInInstance = value
				GF.MasterToggleCheck()
			end,
			default = false,
		},

		-- =====================================================
		-- Category toggles
		-- =====================================================
		{
			type = "header",
			name = "|t35:35:/esoui/art/hud/gamepad/gp_radialicon_tribute_down.dds|tCategory Options",
		},
	}

	for _, cat in ipairs(GF.Categories) do
		table.insert(optionsData, {
			type = "checkbox",
			name = Iconize(cat.name or cat.id, cat.icon, 25),
			tooltip = "Toggle visibility for category " .. (cat.name or cat.id),
			getFunc = function() return GF.Settings.CategoriesEnabled[cat.id] end,
			setFunc = function(value)
				GF.Settings.CategoriesEnabled[cat.id] = value
				GF.RefreshUI()
			end,
			default = true,
		})
	end

	-- =====================================================
	-- Trial toggles
	-- =====================================================
	table.insert(optionsData, {
		type = "header",
		name = "|t35:35:/esoui/art/tutorial/gamepad/gp_lfg_trial.dds|tTrial Options",
	})

	for short, zoneId in pairs(GF.Trials) do
		local cleanName = GF.StripZonePostfix(GetZoneNameById(zoneId))
		table.insert(optionsData, {
			type = "checkbox",
			name = short .. " (" .. cleanName .. ")",
			tooltip = "Toggle visibility for trial " .. short,
			getFunc = function() return GF.Settings.TrialsEnabled[short] end,
			setFunc = function(value)
				GF.Settings.TrialsEnabled[short] = value
				GF.RefreshUI()
			end,
			default = true,
		})
	end

	-- =====================================================
	-- Blacklist Options
	-- =====================================================
	table.insert(optionsData, {
		type = "header",
		name = "|t35:35:/esoui/art/hud/gamepad/gp_radialicon_gamercard_down.dds|tBlacklist Options",
	})

	table.insert(optionsData, {
		type = "description",
		name = "Blacklisted players' listings will be hidden from the group finder.",
		fontSize = 14,
	})

	local selectedBlacklistedPlayer = ""

	function GF.GetBlacklistChoices()
		local leaders = {}
		if GF.Settings and GF.Settings.BlacklistedLeaders then
			for name, _ in pairs(GF.Settings.BlacklistedLeaders) do
				table.insert(leaders, name)
			end
		end
		table.sort(leaders)
		return leaders
	end

	table.insert(optionsData, {
		type = "dropdown",
		name = "Blacklisted Players (Listings)",
		tooltip = "Select a player to unblacklist.",
		choices = GF.GetBlacklistChoices(),
		getFunc = function() return selectedBlacklistedPlayer end,
		setFunc = function(value) selectedBlacklistedPlayer = value end,
		width = "full",
		scrollable = 10,
		reference = "GF_BLACKLIST_DROPDOWN",
	})

	table.insert(optionsData, {
		type = "button",
		name = "Remove from Blacklist",
		tooltip = "Unblacklist the selected player.",
		func = function()
			if selectedBlacklistedPlayer and selectedBlacklistedPlayer ~= "" then
				GF.Settings.BlacklistedLeaders[selectedBlacklistedPlayer] = nil
				GF.RefreshUI()
				GF.Popup("Unblacklisted " .. selectedBlacklistedPlayer, nil, "00FF00")
				selectedBlacklistedPlayer = ""
				if GF_BLACKLIST_DROPDOWN then
					GF_BLACKLIST_DROPDOWN:UpdateChoices(GF.GetBlacklistChoices())
					GF_BLACKLIST_DROPDOWN:UpdateValue()
				end
			end
		end,
		width = "full",
	})

	local panelData = {
		type = "panel",
		name = "GroupFinder+",
		displayName = "|cFFD700GroupFinder+|r",
		author = "|cFFD700@Atharti|r",
		registerForRefresh = true,
		registerForDefaults = true,
	}

	LAM:RegisterAddonPanel("GroupFinderPlusPanel", panelData)
	LAM:RegisterOptionControls("GroupFinderPlusPanel", optionsData)

	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function()
		if GF_BLACKLIST_DROPDOWN then
			GF_BLACKLIST_DROPDOWN:UpdateChoices(GF.GetBlacklistChoices())
			GF_BLACKLIST_DROPDOWN:UpdateValue()
		end
	end)
end