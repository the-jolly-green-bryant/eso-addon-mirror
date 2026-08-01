-- Main-menu Add-ons entry coalesce / injection.

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

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
		local author, name = addonName:match("^(.+)'s%s(.+)")
		if name == nil then
			name = addonName
		end
		if addon.author then
			author = addon.author
		end

		subItems[#subItems + 1] = {
			name = name,
			icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_collections.dds",
			addon = addon,
			activatedCallback = function()
				addon:Select()

				local headerData = {}
				headerData.titleText = name
				headerData.subtitleText = addon.version
				headerData.messageText = author and zo_strformat(GetString(SI_ADD_ON_AUTHOR_LINE), author)
				ZO_GamepadGenericHeader_RefreshData(self.scrollList.header, headerData)

				SCENE_MANAGER:Push("LibConsoleMenuScene")
			end,
			enabled = function()
				return #self.addons > 0
			end
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
