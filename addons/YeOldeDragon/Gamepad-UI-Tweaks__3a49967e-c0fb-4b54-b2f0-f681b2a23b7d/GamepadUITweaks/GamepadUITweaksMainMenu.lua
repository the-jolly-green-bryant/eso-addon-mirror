GamepadUITweaks = GamepadUITweaks or {}

local MAIN_MENU_MAIL_CUSTOM_ENTRY_ID = 91001
local MAIN_MENU_QUESTS_CUSTOM_ENTRY_ID = 91002
local MAIN_MENU_ANTIQUITIES_CUSTOM_ENTRY_ID = 91003

local function FindMainMenuEntryById(entryId)
	if not ZO_MENU_ENTRIES then
		return nil
	end

	for _, entry in ipairs(ZO_MENU_ENTRIES) do
		if entry and entry.id == entryId then
			return entry
		end
	end

	return nil
end

local function RemoveCustomMainMenuEntry(customEntryId)
	if not ZO_MENU_ENTRIES then
		return
	end

	for i = #ZO_MENU_ENTRIES, 1, -1 do
		local entry = ZO_MENU_ENTRIES[i]
		if entry and entry.id == customEntryId then
			table.remove(ZO_MENU_ENTRIES, i)
			break
		end
	end
end

local function RemoveCustomMainMenuMailEntry()
	RemoveCustomMainMenuEntry(MAIN_MENU_MAIL_CUSTOM_ENTRY_ID)
end

local function EnsureCustomMainMenuEntryFromSubmenu(parentEntryId, submenuSceneName, customEntryId, insertAfterEntryId, fallbackInsertAfterEntryId)
	if not (ZO_MENU_ENTRIES and ZO_MENU_MAIN_ENTRIES) then
		return
	end

	for _, entry in ipairs(ZO_MENU_ENTRIES) do
		if entry and entry.id == customEntryId then
			return
		end
	end

	local parentEntry = FindMainMenuEntryById(parentEntryId)
	if not (parentEntry and parentEntry.subMenu) then
		return
	end

	local sourceSubEntry
	for _, subEntry in ipairs(parentEntry.subMenu) do
		if subEntry and subEntry.data and subEntry.data.scene == submenuSceneName then
			sourceSubEntry = subEntry
			break
		end
	end

	if not (sourceSubEntry and sourceSubEntry.data) then
		return
	end

	local sourceData = ZO_ShallowTableCopy(sourceSubEntry.data)
	local customEntry = ZO_GamepadEntryData:New(sourceData.name, sourceData.icon, nil, nil, sourceData.isNewCallback)
	customEntry:SetIconTintOnSelection(true)
	customEntry:SetIconDisabledTintOnSelection(true)
	customEntry.data = sourceData
	customEntry.id = customEntryId

	local insertIndex
	for i, existingEntry in ipairs(ZO_MENU_ENTRIES) do
		if existingEntry and existingEntry.id == insertAfterEntryId then
			insertIndex = i + 1
			break
		end
	end

	if not insertIndex and fallbackInsertAfterEntryId then
		for i, existingEntry in ipairs(ZO_MENU_ENTRIES) do
			if existingEntry and existingEntry.id == fallbackInsertAfterEntryId then
				insertIndex = i + 1
				break
			end
		end
	end

	if insertIndex then
		table.insert(ZO_MENU_ENTRIES, insertIndex, customEntry)
	else
		table.insert(ZO_MENU_ENTRIES, customEntry)
	end
end

local function EnsureCustomMainMenuMailEntry()
	EnsureCustomMainMenuEntryFromSubmenu(
		ZO_MENU_MAIN_ENTRIES.SOCIAL,
		"mailGamepad",
		MAIN_MENU_MAIL_CUSTOM_ENTRY_ID,
		ZO_MENU_MAIN_ENTRIES.SOCIAL
	)
end

local function EnsureCustomMainMenuQuestEntry()
	EnsureCustomMainMenuEntryFromSubmenu(
		ZO_MENU_MAIN_ENTRIES.JOURNAL,
		"gamepad_quest_journal",
		MAIN_MENU_QUESTS_CUSTOM_ENTRY_ID,
		ZO_MENU_MAIN_ENTRIES.JOURNAL,
		ZO_MENU_MAIN_ENTRIES.CAMPAIGN
	)
end

local function EnsureCustomMainMenuAntiquitiesEntry()
	EnsureCustomMainMenuEntryFromSubmenu(
		ZO_MENU_MAIN_ENTRIES.JOURNAL,
		"gamepad_antiquity_journal",
		MAIN_MENU_ANTIQUITIES_CUSTOM_ENTRY_ID,
		ZO_MENU_MAIN_ENTRIES.JOURNAL,
		ZO_MENU_MAIN_ENTRIES.CAMPAIGN
	)
end

local function WrapMainMenuVisibility(entry, svKey)
	if not (entry and entry.data and svKey) then
		return
	end

	if entry.data._GamepadUITweaksVisibilityWrapped then
		return
	end

	local originalIsVisibleCallback = entry.data.isVisibleCallback
	local entryData = entry.data
	entry.data.isVisibleCallback = function(...)
		if entryData._GamepadUITweaksForceVisible then
			if originalIsVisibleCallback then
				return originalIsVisibleCallback(...)
			end
			return true
		end

		if not (GamepadUITweaks.SV and GamepadUITweaks.SV[svKey]) then
			return false
		end

		if originalIsVisibleCallback then
			return originalIsVisibleCallback(...)
		end

		return true
	end

	entry.data._GamepadUITweaksVisibilityWrapped = true
end

local function ApplyMainMenuTweaks()
	if not (ZO_MENU_ENTRIES and ZO_MENU_MAIN_ENTRIES and GamepadUITweaks.SV) then
		return
	end

	local visibilityMappings = {
		{ id = ZO_MENU_MAIN_ENTRIES.CROWN_STORE, sv = "ShowMainMenuCrownStore" },
		{ id = ZO_MENU_MAIN_ENTRIES.TAMRIEL_TOMES, sv = "ShowMainMenuTamrielTomes" },
		{ id = ZO_MENU_MAIN_ENTRIES.ANNOUNCEMENTS, sv = "ShowMainMenuAnnouncements" },
		{ id = ZO_MENU_MAIN_ENTRIES.COLLECTIONS, sv = "ShowMainMenuCollections" },
		{ id = ZO_MENU_MAIN_ENTRIES.SOCIAL, sv = "ShowMainMenuSocial" },
		{ id = ZO_MENU_MAIN_ENTRIES.ACTIVITY_FINDER, sv = "ShowMainMenuActivityFinder" },
		{ id = ZO_MENU_MAIN_ENTRIES.CAMPAIGN, sv = "ShowMainMenuCampaign" },
		{ id = ZO_MENU_MAIN_ENTRIES.JOURNAL, sv = "ShowMainMenuJournal" },
		{ id = ZO_MENU_MAIN_ENTRIES.HELP, sv = "ShowMainMenuHelp" },
	}

	for _, mapping in ipairs(visibilityMappings) do
		local entry = FindMainMenuEntryById(mapping.id)
		WrapMainMenuVisibility(entry, mapping.sv)
	end

	if GamepadUITweaks.SV.ShowMainMenuMail then
		EnsureCustomMainMenuMailEntry()
	else
		RemoveCustomMainMenuMailEntry()
	end

	if GamepadUITweaks.SV.ShowMainMenuQuestJournal then
		EnsureCustomMainMenuQuestEntry()
	else
		RemoveCustomMainMenuEntry(MAIN_MENU_QUESTS_CUSTOM_ENTRY_ID)
	end

	if GamepadUITweaks.SV.ShowMainMenuAntiquitiesJournal then
		EnsureCustomMainMenuAntiquitiesEntry()
	else
		RemoveCustomMainMenuEntry(MAIN_MENU_ANTIQUITIES_CUSTOM_ENTRY_ID)
	end

	if MAIN_MENU_GAMEPAD and MAIN_MENU_GAMEPAD.UpdateEntryEnabledStates then
		MAIN_MENU_GAMEPAD:UpdateEntryEnabledStates()
	end
end

-- When the game programmatically navigates to a menu entry that GamepadUITweaks
-- has hidden (e.g. ACTIVITY_FINDER during a promotional event), SelectMenuEntry
-- receives nil from mainMenuEntryToListIndex and crashes in zo_clamp.
-- This hook detects that case, temporarily forces the entry visible, rebuilds
-- the list so the index is populated, then lets the original call proceed.
local function HookSelectMenuEntryForHiddenEntries()
	if not (MAIN_MENU_GAMEPAD and MAIN_MENU_GAMEPAD.SelectMenuEntry) then
		return
	end

	local originalSelectMenuEntry = MAIN_MENU_GAMEPAD.SelectMenuEntry
	MAIN_MENU_GAMEPAD.SelectMenuEntry = function(self, menuEntry)
		if self.mainMenuEntryToListIndex[menuEntry] == nil then
			for _, entry in ipairs(ZO_MENU_ENTRIES) do
				if entry.id == menuEntry and entry.data and entry.data._GamepadUITweaksVisibilityWrapped then
					entry.data._GamepadUITweaksForceVisible = true
					self:RefreshMainList()
					entry.data._GamepadUITweaksForceVisible = false
					break
				end
			end
		end
		return originalSelectMenuEntry(self, menuEntry)
	end
end

GamepadUITweaks.ApplyMainMenuTweaks = ApplyMainMenuTweaks
GamepadUITweaks.HookSelectMenuEntryForHiddenEntries = HookSelectMenuEntryForHiddenEntries
