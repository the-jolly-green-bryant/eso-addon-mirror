-- Main-menu Add-ons entry coalesce / injection.

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

local DEFAULT_ADDON_MENU_ICON = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_collections.dds"

-- Stock Browse Add-Ons category icons (mirror ZO_ModBrowserListingSearchData CATEGORY_TO_ICON).
local CATEGORY_TO_ICON = {
	[MOD_BROWSER_CATEGORY_TYPE_LIBRARIES] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_libraries.dds",
	[MOD_BROWSER_CATEGORY_TYPE_MAIL] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_mail.dds",
	[MOD_BROWSER_CATEGORY_TYPE_COMBAT] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_combat.dds",
	[MOD_BROWSER_CATEGORY_TYPE_CHAT] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_chat.dds",
	[MOD_BROWSER_CATEGORY_TYPE_MISC] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_misc.dds",
	[MOD_BROWSER_CATEGORY_TYPE_ABILITY_BAR] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_abilityBar.dds",
	[MOD_BROWSER_CATEGORY_TYPE_GUILD_TRADERS_AND_VENDORS] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_guildTradersAndVendors.dds",
	[MOD_BROWSER_CATEGORY_TYPE_BANK_AND_INVENTORY] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_bankAndInventory.dds",
	[MOD_BROWSER_CATEGORY_TYPE_BUFFS_AND_DEBUFFS] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_buffsAndDebuffs.dds",
	[MOD_BROWSER_CATEGORY_TYPE_CAST_BARS_AND_COOLDOWNS] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_castBarsAndCooldowns.dds",
	[MOD_BROWSER_CATEGORY_TYPE_CHARACTER_PROGRESSION] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_characterProgression.dds",
	[MOD_BROWSER_CATEGORY_TYPE_CRAFTING] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_crafting.dds",
	[MOD_BROWSER_CATEGORY_TYPE_DATA] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_data.dds",
	[MOD_BROWSER_CATEGORY_TYPE_UI_GRAPHICS] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_uiGraphics.dds",
	[MOD_BROWSER_CATEGORY_TYPE_SOCIAL] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_social.dds",
	[MOD_BROWSER_CATEGORY_TYPE_HOUSING] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_housing.dds",
	[MOD_BROWSER_CATEGORY_TYPE_INFO_AND_PLUGIN_BARS] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_infoAndPluginBars.dds",
	[MOD_BROWSER_CATEGORY_TYPE_MAP_AND_COMPASS] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_mapAndCompass.dds",
	[MOD_BROWSER_CATEGORY_TYPE_PVP] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_pvp.dds",
	[MOD_BROWSER_CATEGORY_TYPE_ROLEPLAY] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_roleplay.dds",
	[MOD_BROWSER_CATEGORY_TYPE_TOOLTIP] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_tooltip.dds",
	[MOD_BROWSER_CATEGORY_TYPE_TRIALS] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_trials.dds",
	[MOD_BROWSER_CATEGORY_TYPE_UNIT_FRAMES] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_unitFrames.dds",
	[MOD_BROWSER_CATEGORY_TYPE_UTILITY] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_utility.dds",
	[MOD_BROWSER_CATEGORY_TYPE_BETA] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_beta.dds",
	[MOD_BROWSER_CATEGORY_TYPE_PLUGINS_AND_PATCHES] = "EsoUI/Art/Addons/Gamepad/gp_mod_listing_category_pluginsAndPatches.dds",
}

function LCM.ResolveAddonMenuIcon(category)
	if category == nil or category == "" then
		return DEFAULT_ADDON_MENU_ICON
	end
	local categoryType = category
	if type(category) == "string" then
		local key = category:upper():gsub("[%s%-]+", "_")
		categoryType = _G["MOD_BROWSER_CATEGORY_TYPE_" .. key]
	end
	if type(categoryType) == "number" then
		local path = CATEGORY_TO_ICON[categoryType]
		if path then
			return path
		end
	end
	return DEFAULT_ADDON_MENU_ICON
end

local function GetAddonsMenuTitle()
	return GetString(SI_GAME_MENU_ADDONS)
end

local function GetMenuEntryLabel(entry)
	if not entry then
		return ""
	end
	if entry.GetText then
		local text = entry:GetText()
		if text and text ~= "" then
			return text
		end
	end
	if entry.data and entry.data.name then
		return entry.data.name
	end
	return entry.text or entry.name or ""
end

local function IsSharedAddonsMenuEntry(entry)
	if not entry or not entry.subMenu then
		return false
	end
	local id = entry.id
	if id == "LibHarvensAddonSettings" or id == "LibVotans" or id == "LibConsoleMenu" then
		return true
	end
	local title = GetAddonsMenuTitle()
	local name = GetMenuEntryLabel(entry)
	return name == title or name == (title .. " 2")
end

local function GetAddonsMenuPriority(entry)
	if entry.id == "LibHarvensAddonSettings" then
		return 1
	end
	if entry.id == "LibVotans" then
		return 2
	end
	if entry.id == "LibConsoleMenu" then
		return 3
	end
	return 4
end

local function FindForeignAddonsMenu()
	local title = GetAddonsMenuTitle()
	local fallback
	for i = 1, #ZO_MENU_ENTRIES do
		local entry = ZO_MENU_ENTRIES[i]
		if entry and entry.subMenu then
			if entry.id == "LibHarvensAddonSettings" or entry.id == "LibVotans" then
				return entry
			end
			local name = GetMenuEntryLabel(entry)
			if entry.id ~= "LibConsoleMenu" and (name == title or name == (title .. " 2")) then
				fallback = fallback or entry
			end
		end
	end
	return fallback
end

local function SortAddonSubMenu(subMenu)
	table.sort(
		subMenu,
		function(a, b)
			return GetMenuEntryLabel(a) < GetMenuEntryLabel(b)
		end
	)
end

-- Merge duplicate top-level Add-ons menus from other settings libs into one shared submenu.
function LibConsoleMenu:CoalesceAddonsMenus()
	local candidates = {}
	for i = 1, #ZO_MENU_ENTRIES do
		if IsSharedAddonsMenuEntry(ZO_MENU_ENTRIES[i]) then
			candidates[#candidates + 1] = i
		end
	end
	if #candidates <= 1 then
		return false
	end

	local hostIndex = candidates[1]
	for _, index in ipairs(candidates) do
		if GetAddonsMenuPriority(ZO_MENU_ENTRIES[index]) < GetAddonsMenuPriority(ZO_MENU_ENTRIES[hostIndex]) then
			hostIndex = index
		end
	end

	local host = ZO_MENU_ENTRIES[hostIndex]
	host.subMenu = host.subMenu or {}

	table.sort(
		candidates,
		function(a, b)
			return a > b
		end
	)
	for _, index in ipairs(candidates) do
		if index ~= hostIndex then
			local victim = ZO_MENU_ENTRIES[index]
			for _, child in ipairs(victim.subMenu or {}) do
				host.subMenu[#host.subMenu + 1] = child
			end
			table.remove(ZO_MENU_ENTRIES, index)
			if index < hostIndex then
				hostIndex = hostIndex - 1
				host = ZO_MENU_ENTRIES[hostIndex]
			end
		end
	end

	SortAddonSubMenu(host.subMenu)
	local title = GetAddonsMenuTitle()
	if host.SetText then
		host:SetText(title)
	end
	host.name = title

	MAIN_MENU_GAMEPAD:RefreshMainList()
	return true
end

local function HookForeignAddonsMenuBuilders()
	local function afterForeignMenu()
		LibConsoleMenu:CoalesceAddonsMenus()
	end

	local lhas = rawget(_G, "LibHarvensAddonSettings")
	if lhas and not lhas._lcmMenuHooked and type(lhas.CreateAddonSettingsPanel) == "function" then
		lhas._lcmMenuHooked = true
		local original = lhas.CreateAddonSettingsPanel
		function lhas.CreateAddonSettingsPanel(settingsSelf, ...)
			original(settingsSelf, ...)
			afterForeignMenu()
		end
	end
end



function LCM:InjectIntoAddonsMenu()
	local insertPosition = 0
	for i = 1, #ZO_MENU_ENTRIES do
		if ZO_MENU_ENTRIES[i].id == ZO_MENU_MAIN_ENTRIES.ACTIVITY_FINDER then
			insertPosition = i
			break
		end
	end
	if insertPosition == 0 then
		return false
	end

	local function CreateEntry(id, data)
		local name = data.name
		if type(name) == "function" then
			name = ""
		end

		local entry = ZO_GamepadEntryData:New(name, data.icon, nil, nil, data.isNewCallback)
		entry:SetIconTintOnSelection(true)
		entry:SetIconDisabledTintOnSelection(true)

		local header = data.header
		if header then
			entry:SetHeader(header)
		end

		entry.canLevel = data.canLevel
		entry.narrationText = data.narrationText
		entry.subLabelsNarrationText = data.subLabelsNarrationText

		if data.subMenu then
			entry.subMenu = {}
			for submenuEntryId, subMenuData in ipairs(data.subMenu) do
				entry.subMenu[#entry.subMenu + 1] = CreateEntry(submenuEntryId, subMenuData)
			end
		end

		entry.data = data
		entry.id = id
		return entry
	end

	local subItems = {}
	for i = 1, #self.addons do
		local addon = self.addons[i]
		addon.control = self.container
		addon:InitHandlers()

		local addonName = addon.name
		local _, name = addonName:match("^(.+)'s%s(.+)")
		if name == nil then
			name = addonName
		end
		addon.displayName = name

		subItems[#subItems + 1] = {
			name = name,
			icon = LCM.ResolveAddonMenuIcon(addon.category),
			addon = addon,
			activatedCallback = function()
				addon:Select()
				LCM:RefreshSceneHeader()
				SCENE_MANAGER:Push("LibConsoleMenuScene")
			end,
			enabled = function()
				return #self.addons > 0
			end,
			onSelectedCallback = function()
				if not MAIN_MENU_GAMEPAD:IsShowing() then
					return
				end
				local meta = LCM.GetAddonManifestMeta(addon)
				if not meta then
					GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_LEFT_TOOLTIP)
					return
				end
				GAMEPAD_TOOLTIPS:LayoutLibConsoleMenuAddonTooltip(GAMEPAD_LEFT_TOOLTIP, meta)
			end,
			onUnselectedCallback = function()
				if MAIN_MENU_GAMEPAD:IsShowing() then
					GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_LEFT_TOOLTIP)
				end
			end,
		}
	end
	table.sort(
		subItems,
		function(el1, el2)
			return el1.name < el2.name
		end
	)

	if #self.addons > 0 then
		local host = FindForeignAddonsMenu()
		if host then
			host.subMenu = host.subMenu or {}
			for index, data in ipairs(subItems) do
				local child = CreateEntry("LibConsoleMenu_" .. index .. "_" .. data.name, data)
				child.lcmOwned = true
				host.subMenu[#host.subMenu + 1] = child
			end
			SortAddonSubMenu(host.subMenu)
		else
			table.insert(
				ZO_MENU_ENTRIES,
				insertPosition,
				CreateEntry(
					"LibConsoleMenu",
					{
						customTemplate = "ZO_GamepadMenuEntryTemplateWithArrow",
						name = GetAddonsMenuTitle(),
						icon = "/esoui/art/options/gamepad/gp_options_addons.dds",
						subMenu = subItems
					}
				)
			)
		end
		self:CoalesceAddonsMenus()
		MAIN_MENU_GAMEPAD:RefreshMainList()
		HookForeignAddonsMenuBuilders()
	end
	return true
end
