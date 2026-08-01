--
-- Calamath's Quest Tracker [CQT]
--
-- Copyright (c) 2022 Calamath
--
-- This software is released under the Artistic License 2.0
-- https://opensource.org/licenses/Artistic-2.0
--

if not CQuestTracker then return end
local CQT = CQuestTracker:SetSharedEnvironment()

local L = GetString

-- ---------------------------------------------------------------------------------------
-- QuestJournal_Quests Customizer Base Class (CQuestJournalCustomizer_Shared)
-- ---------------------------------------------------------------------------------------
local CQuestJournalCustomizer_Shared = ZO_DeferredInitializingObject:Subclass()
function CQuestJournalCustomizer_Shared:Initialize(questJournalQuestsObject, questJournalScene, currentSavedVars)
	ZO_DeferredInitializingObject.Initialize(self, questJournalScene)
	self.questJournal = questJournalQuestsObject
	self.svCurrent = currentSavedVars or {}
end

function CQuestJournalCustomizer_Shared:GetSelectedQuestIndex()
	return self.questJournal:GetSelectedQuestIndex()
end

do
	local IsModifierKeyDown = {
		[KEY_CTRL] = function() return IsControlKeyDown() end, 
		[KEY_ALT] = function() return IsAltKeyDown() end, 
		[KEY_SHIFT] = function() return IsShiftKeyDown() end, 
		[KEY_COMMAND] = function() return IsCommandKeyDown() end, 
		[KEY_GAMEPAD_LEFT_TRIGGER] = function() return GetGamepadLeftTriggerMagnitude() > 0.2 end, 
		[KEY_GAMEPAD_RIGHT_TRIGGER] = function() return GetGamepadRightTriggerMagnitude() > 0.2 end, 
	}
	function CQuestJournalCustomizer_Shared:IsModifierKeyDown(keyCode)
		return keyCode and IsModifierKeyDown[keyCode] and IsModifierKeyDown[keyCode]() or false
	end
end

function CQuestJournalCustomizer_Shared:OnDeferredInitialize()
	-- NOTE: We should not use the gamepadPreferredKeybind specifier if there is already another button assigned to the key specified by 'keybind'.
	-- It is unclear whether this is intended, but the existing keybind button would be overwritten and replaced.
	-- Also, specifying your own keybind actions with gamepadPreferredKeybind will not work as intended.

--[[
	self.keybindButtonDescriptor = {
		-- Pin / Unpin Quest
		["pinning"] = {
			alignment = KEYBIND_STRIP_ALIGN_LEFT, 
			name = function()
				if CQT:IsPinnedQuestByIndex(self:GetSelectedQuestIndex()) then
					return L(SI_CQT_DISABLE_PINNING_QUEST)
				else
					return L(SI_CQT_ENABLE_PINNING_QUEST)
				end
			end, 
			keybind = "UI_SHORTCUT_SECONDARY", 
			gamepadPreferredKeybind = "UI_SHORTCUT_TERTIARY", 
			callback = function()
				local selectedQuestIndex = self:GetSelectedQuestIndex()
				if CQT:IsPinnedQuestByIndex(selectedQuestIndex) then
					CQT:DisablePinningQuestByIndex(selectedQuestIndex)
				else
					CQT:EnablePinningQuestByIndex(selectedQuestIndex)
				end
				self:UpdateQuestJournalDetailTitle(selectedQuestIndex)
				self:UpdateKeybindStripDescriptors()
			end, 
			visible = function()
				if self:GetSelectedQuestIndex() then
					return true
				else
					return false
				end
			end, 
		}, 

		-- Ignoring / Disable ignoring Quest
		["ignoring"] = {
			alignment = KEYBIND_STRIP_ALIGN_LEFT, 
			name = function()
				if CQT:IsIgnoredQuestByIndex(self:GetSelectedQuestIndex()) then
					return L(SI_CQT_DISABLE_IGNORING_QUEST)
				else
					return L(SI_CQT_ENABLE_IGNORING_QUEST)
				end
			end, 
			keybind = "UI_SHORTCUT_QUINARY", 
			gamepadPreferredKeybind = "UI_SHORTCUT_SECONDARY", 
			callback = function()
				local selectedQuestIndex = self:GetSelectedQuestIndex()
				if CQT:IsIgnoredQuestByIndex(selectedQuestIndex) then
					CQT:DisableIgnoringQuestByIndex(selectedQuestIndex)
				else
					CQT:EnableIgnoringQuestByIndex(selectedQuestIndex)
				end
				self:UpdateQuestJournalDetailTitle(selectedQuestIndex)
				self:UpdateKeybindStripDescriptors()
			end, 
			visible = function()
				if self:GetSelectedQuestIndex() then
					return true
				else
					return false
				end
			end, 
		}, 
	}
]]
end

function CQuestJournalCustomizer_Shared:UpdateKeybindStripDescriptors()
	-- Should be overridden
end

function CQuestJournalCustomizer_Shared:UpdateQuestJournalDetailTitle(questIndex)
	-- Should be overridden
end

CQT:RegisterSharedObject("CQuestJournalCustomizer_Shared", CQuestJournalCustomizer_Shared)



-- ---------------------------------------------------------------------------------------
-- QuestJournal_Quests Customizer Gamepad Class (CQuestJournalCustomizer_Gamepad)
-- ---------------------------------------------------------------------------------------
local CQuestJournalCustomizer_Gamepad = CQuestJournalCustomizer_Shared:Subclass()
function CQuestJournalCustomizer_Gamepad:Initialize(svCurrent)
	CQuestJournalCustomizer_Shared.Initialize(self, ZO_QUEST_JOURNAL_QUESTS_GAMEPAD or SYSTEMS:GetGamepadObject("questJournal") or QUEST_JOURNAL_GAMEPAD, SYSTEMS:GetGamepadRootScene("questJournal") or GAMEPAD_QUEST_JOURNAL_ROOT_SCENE, svCurrent)
end

function CQuestJournalCustomizer_Gamepad:OnDeferredInitialize()
	CQuestJournalCustomizer_Shared.OnDeferredInitialize(self)

	-- We would replace the keybind button for show on the map on the keybind strip for the main menu.
	local mainKeybindStripDescriptor = self.questJournal.mainKeybindStripDescriptor
	if mainKeybindStripDescriptor then
		-- Show On Map
		mainKeybindStripDescriptor[#mainKeybindStripDescriptor + 1] = {
			alignment = KEYBIND_STRIP_ALIGN_LEFT, 
			name = L(SI_QUEST_JOURNAL_SHOW_ON_MAP), 
			keybind = "UI_SHORTCUT_SECONDARY", 
			callback = function()
				local selectedQuestIndex = self:GetSelectedQuestIndex()
				if selectedQuestIndex then
					self.questJournal:QueuePendingJournalQuestIndex(selectedQuestIndex)
					local result = CQT:ShowQuestPingOnMap(selectedQuestIndex)
					if result == nil then
						ZO_WorldMap_ShowQuestOnMap(selectedQuestIndex)
					end
				end
			end, 
			visible = function()
				if self:GetSelectedQuestIndex() then
					return true
				else
					return false
				end
			end, 
		}
	end
	KEYBIND_STRIP:UpdateKeybindButtonGroup(mainKeybindStripDescriptor)

	local optionsKeybindStripDescriptor = self.questJournal.optionsKeybindStripDescriptor
	if optionsKeybindStripDescriptor then
		-- We would add a keybind button for picking out quest to the keybind strip for the options menu.
		optionsKeybindStripDescriptor[#optionsKeybindStripDescriptor + 1] = {
		-- Pick out Quest
			alignment = KEYBIND_STRIP_ALIGN_LEFT, 
			name = L(SI_CQT_PICK_OUT_QUEST), 
			keybind = "UI_SHORTCUT_SECONDARY", 
			callback = function()
				local selectedQuestIndex = self:GetSelectedQuestIndex()
				CQT:PickOutQuestByIndex(selectedQuestIndex)
			end, 
			visible = function()
				local selectedQuestIndex = self:GetSelectedQuestIndex()
				if selectedQuestIndex and not CQT:IsIgnoredQuestByIndex(selectedQuestIndex) and not CQT:IsPinnedQuestByIndex(selectedQuestIndex) then
					return true
				else
					return false
				end
			end, 
		}
		-- We would add a keybind button for pinning to the keybind strip for the options menu.
		optionsKeybindStripDescriptor[#optionsKeybindStripDescriptor + 1] = {
		-- Pin / Unpin Quest
			alignment = KEYBIND_STRIP_ALIGN_LEFT, 
			name = function()
				if CQT:IsPinnedQuestByIndex(self:GetSelectedQuestIndex()) then
					return L(SI_CQT_DISABLE_PINNING_QUEST)
				else
					return L(SI_CQT_ENABLE_PINNING_QUEST)
				end
			end, 
			keybind = "UI_SHORTCUT_TERTIARY", 
			callback = function()
				local selectedQuestIndex = self:GetSelectedQuestIndex()
				if CQT:IsPinnedQuestByIndex(selectedQuestIndex) then
					CQT:DisablePinningQuestByIndex(selectedQuestIndex)
				else
					CQT:EnablePinningQuestByIndex(selectedQuestIndex)
				end
				self:UpdateQuestJournalDetailTitle(selectedQuestIndex)
				self:UpdateKeybindStripDescriptors()
			end, 
			visible = function()
				if self:GetSelectedQuestIndex() then
					return true
				else
					return false
				end
			end, 
		}
	end

	-- After RefreshOptionsList runs, we add our menu items and rebuild the list.
	SecurePostHook(self.questJournal, "RefreshOptionsList", function(questJournalGamepad)
		local selectedQuestIndex = self:GetSelectedQuestIndex()
		if CQT:IsPinnedQuestByIndex(selectedQuestIndex) then
			-- Unpin the quest
			local disablePinningQuest = ZO_GamepadEntryData:New(L(SI_CQT_DISABLE_PINNING_QUEST))
			disablePinningQuest.action = function()
				CQT:DisablePinningQuestByIndex(selectedQuestIndex)
				self:UpdateQuestJournalDetailTitle(selectedQuestIndex)
				self:UpdateKeybindStripDescriptors()
			end
			table.insert(questJournalGamepad.options, disablePinningQuest)
		else
			-- Pin the quest
			local enablePinningQuest = ZO_GamepadEntryData:New(L(SI_CQT_ENABLE_PINNING_QUEST))
			enablePinningQuest.action = function()
				CQT:EnablePinningQuestByIndex(selectedQuestIndex)
				self:UpdateQuestJournalDetailTitle(selectedQuestIndex)
				self:UpdateKeybindStripDescriptors()
			end
			table.insert(questJournalGamepad.options, enablePinningQuest)
		end
		if CQT:IsIgnoredQuestByIndex(selectedQuestIndex) then
			-- Disable ignoring the quest
			local disableIgnoringQuest = ZO_GamepadEntryData:New(L(SI_CQT_DISABLE_IGNORING_QUEST))
			disableIgnoringQuest.action = function()
				CQT:DisableIgnoringQuestByIndex(selectedQuestIndex)
				self:UpdateQuestJournalDetailTitle(selectedQuestIndex)
				self:UpdateKeybindStripDescriptors()
			end
			table.insert(questJournalGamepad.options, disableIgnoringQuest)
		else
			-- Ignoring the quest
			local enableIgnoringQuest = ZO_GamepadEntryData:New(L(SI_CQT_ENABLE_IGNORING_QUEST))
			enableIgnoringQuest.action = function()
				CQT:EnableIgnoringQuestByIndex(selectedQuestIndex)
				self:UpdateQuestJournalDetailTitle(selectedQuestIndex)
				self:UpdateKeybindStripDescriptors()
			end
			table.insert(questJournalGamepad.options, enableIgnoringQuest)
		end
		questJournalGamepad.optionsList:Clear()
		for _, option in pairs(questJournalGamepad.options) do
			questJournalGamepad.optionsList:AddEntry("ZO_GamepadSubMenuEntryTemplate", option)
		end
		questJournalGamepad.optionsList:Commit()
	end)

	-- After RefreshDetails runs, we replace the quest title in the quest details pane.
	SecurePostHook(self.questJournal, "RefreshDetails", function(questJournalGamepad)
		self:UpdateQuestJournalDetailTitle(self:GetSelectedQuestIndex())
	end)
end

function CQuestJournalCustomizer_Gamepad:OnShowing()
	self:UpdateQuestJournalDetailTitle(self:GetSelectedQuestIndex())
end

function CQuestJournalCustomizer_Gamepad:UpdateKeybindStripDescriptors()
	KEYBIND_STRIP:UpdateKeybindButtonGroup(self.questJournal.optionsKeybindStripDescriptor)
	local optionsList = self.questJournal.optionsList
	local numListItems = optionsList:GetNumItems()
	local selectedIndex = optionsList:GetSelectedIndex()
	-- In gamepad mode, we need to rebuild the list of options menu at the same time.
	self.questJournal:RefreshOptionsList()
	-- But we do not want to move selected items in the options menu before/after switching menu items such as pin/unpin.
	if optionsList:GetSelectedIndex() ~= selectedIndex then
		if optionsList:GetNumItems() == numListItems then
			optionsList:SetSelectedIndexWithoutAnimation(selectedIndex)
		end
	end
end

function CQuestJournalCustomizer_Gamepad:UpdateQuestJournalDetailTitle(questIndex)
	if self:IsShowing() then
		ZO_GamepadGenericHeader_Refresh(self.questJournal.contentHeader, self.questJournal.contentHeaderData)
		local titleLabel = self.questJournal.contentHeader.controls[ZO_GAMEPAD_HEADER_CONTROLS.TITLE]
		local title = titleLabel:GetText()
		if CQT:IsPinnedQuestByIndex(questIndex) then
			title = zo_strformat(L(SI_CQT_QUEST_LIST_PINNED_FORMATTER), title)
		elseif CQT:IsIgnoredQuestByIndex(questIndex) then
			title = zo_strformat(L(SI_CQT_QUEST_LIST_IGNORED_FORMATTER), title)
		end
		titleLabel:SetText(title)
	end
end

CQuestTracker:RegisterClassObject("CQuestJournalCustomizer_Gamepad", CQuestJournalCustomizer_Gamepad)



-- ---------------------------------------------------------------------------------------
-- QuestJournal_Quests Customizer Keyboard Class (CQuestJournalCustomizer_Keyboard)
-- ---------------------------------------------------------------------------------------
local CQuestJournalCustomizer_Keyboard = CQuestJournalCustomizer_Shared:Subclass()
function CQuestJournalCustomizer_Keyboard:Initialize(svCurrent)
	CQuestJournalCustomizer_Shared.Initialize(self, ZO_QUEST_JOURNAL_QUESTS_KEYBOARD or SYSTEMS:GetKeyboardObject("questJournal") or QUEST_JOURNAL_KEYBOARD, SYSTEMS:GetKeyboardRootScene("questJournal") or QUEST_JOURNAL_SCENE, svCurrent)
end

function CQuestJournalCustomizer_Keyboard:OnDeferredInitialize()
	CQuestJournalCustomizer_Shared.OnDeferredInitialize(self)

	-- We completely replace the keybind strip.
	self.keybindStripDescriptor = {
		alignment = KEYBIND_STRIP_ALIGN_CENTER
	}
	-- Cycle Focused Quest
	self.keybindStripDescriptor[#self.keybindStripDescriptor + 1] = {
		name = L(SI_QUEST_JOURNAL_CYCLE_FOCUSED_QUEST), 
		keybind = "UI_SHORTCUT_QUATERNARY", 
		callback = function()
			local isModifierKeyDown = self:IsModifierKeyDown(self.svCurrent.cycleBackwardsMod1) or self:IsModifierKeyDown(self.svCurrent.cycleBackwardsMod2)
			if isModifierKeyDown then
				CQT:AssistPrevious()
			else
				CQT:AssistNext()
			end
			self.questJournal:FocusQuestWithIndex(QUEST_JOURNAL_MANAGER:GetFocusedQuestIndex())
		end, 
		visible = function()
			return GetNumJournalQuests() >= 2
		end, 
	}
	-- Show On Map
	self.keybindStripDescriptor[#self.keybindStripDescriptor + 1] = {
		name = L(SI_QUEST_JOURNAL_SHOW_ON_MAP), 
		keybind = "UI_SHORTCUT_SHOW_QUEST_ON_MAP", 
		callback = function()
			local selectedQuestIndex = self:GetSelectedQuestIndex()
			if selectedQuestIndex then
				self.questJournal:QueuePendingJournalQuestIndex(selectedQuestIndex)
				local result = CQT:ShowQuestPingOnMap(selectedQuestIndex)
				if result == nil then
					ZO_WorldMap_ShowQuestOnMap(selectedQuestIndex)
				end
			end
		end, 
		visible = function()
			if self:GetSelectedQuestIndex() then
				return true
			else
				return false
			end
		end, 
	}
	-- Share Quest
	self.keybindStripDescriptor[#self.keybindStripDescriptor + 1] = {
		name = L(SI_QUEST_JOURNAL_SHARE), 
		keybind = "UI_SHORTCUT_TERTIARY", 
		callback = function()
			local selectedQuestIndex = self:GetSelectedQuestIndex()
			if selectedQuestIndex then
				QUEST_JOURNAL_MANAGER:ShareQuest(selectedQuestIndex)
			end
		end, 
		visible = function()
			local selectedQuestIndex = self:GetSelectedQuestIndex()
			return selectedQuestIndex and GetIsQuestSharable(selectedQuestIndex) and IsUnitGrouped("player")
		end, 
	}
	-- Abandon Quest
	self.keybindStripDescriptor[#self.keybindStripDescriptor + 1] = {
		name = L(SI_QUEST_JOURNAL_ABANDON),
		keybind = "UI_SHORTCUT_NEGATIVE",
		callback = function()
			local selectedQuestIndex = self:GetSelectedQuestIndex()
			if selectedQuestIndex then
				QUEST_JOURNAL_MANAGER:ConfirmAbandonQuest(selectedQuestIndex)
			end
		end, 
		visible = function()
			local selectedQuestIndex = self:GetSelectedQuestIndex()
			return selectedQuestIndex and GetJournalQuestType(selectedQuestIndex) ~= QUEST_TYPE_MAIN_STORY
		end, 
	}
	-- Pin / Unpin Quest
	self.keybindStripDescriptor[#self.keybindStripDescriptor + 1] = {
		alignment = KEYBIND_STRIP_ALIGN_LEFT, 
		name = function()
			if CQT:IsPinnedQuestByIndex(self:GetSelectedQuestIndex()) then
				return L(SI_CQT_DISABLE_PINNING_QUEST)
			else
				return L(SI_CQT_ENABLE_PINNING_QUEST)
			end
		end, 
		keybind = "UI_SHORTCUT_SECONDARY", 
		callback = function()
			local selectedQuestIndex = self:GetSelectedQuestIndex()
			if CQT:IsPinnedQuestByIndex(selectedQuestIndex) then
				CQT:DisablePinningQuestByIndex(selectedQuestIndex)
			else
				CQT:EnablePinningQuestByIndex(selectedQuestIndex)
			end
			self:UpdateQuestJournalDetailTitle(selectedQuestIndex)
			self:UpdateKeybindStripDescriptors()
		end, 
		visible = function()
			if self:GetSelectedQuestIndex() then
				return true
			else
				return false
			end
		end, 
	}
	-- Ignoring / Disable ignoring Quest
	self.keybindStripDescriptor[#self.keybindStripDescriptor + 1] = {
		alignment = KEYBIND_STRIP_ALIGN_LEFT, 
		name = function()
			if CQT:IsIgnoredQuestByIndex(self:GetSelectedQuestIndex()) then
				return L(SI_CQT_DISABLE_IGNORING_QUEST)
			else
				return L(SI_CQT_ENABLE_IGNORING_QUEST)
			end
		end, 
		keybind = "UI_SHORTCUT_QUINARY", 
		callback = function()
			local selectedQuestIndex = self:GetSelectedQuestIndex()
			if CQT:IsIgnoredQuestByIndex(selectedQuestIndex) then
				CQT:DisableIgnoringQuestByIndex(selectedQuestIndex)
			else
				CQT:EnableIgnoringQuestByIndex(selectedQuestIndex)
			end
			self:UpdateQuestJournalDetailTitle(selectedQuestIndex)
			self:UpdateKeybindStripDescriptors()
		end, 
		visible = function()
			if self:GetSelectedQuestIndex() then
				return true
			else
				return false
			end
		end, 
	}

	self.questJournal:RegisterCallback("QuestSelected", function()
		self:UpdateKeybindStripDescriptors()
	end)

	-- After RefreshDetails runs, we replace the quest title in the quest details pane.
	SecurePostHook(self.questJournal, "RefreshDetails", function(questJournalKeyboard)
		self:UpdateQuestJournalDetailTitle(self:GetSelectedQuestIndex())
	end)
end

function CQuestJournalCustomizer_Keyboard:OnShowing()
	self.keybindStripId = KEYBIND_STRIP:PushKeybindGroupState()
	KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor, self.keybindStripId)
	self:UpdateQuestJournalDetailTitle(self:GetSelectedQuestIndex())
end

function CQuestJournalCustomizer_Keyboard:OnHiding()
	KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor, self.keybindStripId)
	KEYBIND_STRIP:PopKeybindGroupState()
	self.keybindStripId = nil
end

function CQuestJournalCustomizer_Keyboard:UpdateKeybindStripDescriptors()
	KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor, self.keybindStripId)
end

function CQuestJournalCustomizer_Keyboard:UpdateQuestJournalDetailTitle(questIndex)
	if self:IsShowing() then
		local title = zo_strformat(SI_QUEST_JOURNAL_QUEST_NAME_FORMAT, GetJournalQuestName(questIndex))
		if CQT:IsPinnedQuestByIndex(questIndex) then
			title = zo_strformat(L(SI_CQT_QUEST_LIST_PINNED_FORMATTER), title)
		elseif CQT:IsIgnoredQuestByIndex(questIndex) then
			title = zo_strformat(L(SI_CQT_QUEST_LIST_IGNORED_FORMATTER), title)
		end
		self.questJournal.titleText:SetText(title)
	end
end

CQuestTracker:RegisterClassObject("CQuestJournalCustomizer_Keyboard", CQuestJournalCustomizer_Keyboard)
