
--------------------------------------------------------------------------------
-- Loot history
--------------------------------------------------------------------------------

local LootHistory = ZO_LootHistory_Shared:Subclass()

--------------------------------------------------------------------------------
-- 
--------------------------------------------------------------------------------

local STATE_DISABLED	= 0
local STATE_ENABLED		= 1
local STATE_EXTRA		= 2

local updating = false
local rowPadding = 8
local minMidth = 0
local minMidth = 100
local paddingMuliplyer = 0.5
local nextTimeToFlushMS = 0
local FLUSH_UPDATE_TIME_MS = 200

local g_fragments = {
	[LOOT_HISTORY_KEYBOARD] = KEYBOARD_LOOT_HISTORY_FRAGMENT,
	[LOOT_HISTORY_GAMEPAD] = GAMEPAD_LOOT_HISTORY_FRAGMENT,
}

--------------------------------------------------------------------------------
-- Shared
--------------------------------------------------------------------------------

local streams = {'lootStream', 'lootStreamPersistent'}
local function streamsIterator(object)
	local nextKey, nextData = next(streams)

	return function()
		while nextKey do
			local currentKey, stream = nextKey, nextData
			nextKey, nextData = next(streams, nextKey)
			
			return stream, object[stream]
		end
	end
end

local function setDimensions(control, width, height)
	if not control:IsHidden() then
		control:SetDimensions(width, height)
	end
end

local function getFontPadding(font)
	local padding = font:match('%d+')
	return padding + padding * paddingMuliplyer
end

local function getRowHeight(font)
	local height = font:match('%d+')
	return height + height * 0.5
end

local function getWidth(font, text)
	local padding = getFontPadding(font)
	
    local fontObject = _G[font]
	local rowWidth = GetStringWidthScaled(fontObject, text, 1, SPACE_INTERFACE) + padding
	
	return rowWidth
end

local function getMinWidth()
	local height = zo_max(getRowHeight(LootHistory.lootHistoryLabelFont), getRowHeight(LootHistory.lootHistoryOverlayFont))
	return minMidth + height * paddingMuliplyer
end

local function getRowDimensions(control, maxWidth, maxHeight)
	maxWidth = maxWidth or getMinWidth()
	maxHeight = maxHeight or zo_max(getRowHeight(LootHistory.lootHistoryLabelFont), getRowHeight(LootHistory.lootHistoryOverlayFont))
	local width = getWidth(LootHistory.lootHistoryLabelFont, control.label:GetText()) + maxHeight
	
	if width > maxWidth then
		maxWidth = width
	end

--	maxWidth = zo_max(width, maxWidth)
	return maxWidth, maxHeight
end

local function updateRow(control, maxWidth, maxHeight)
	local labelFont = LootHistory.lootHistoryLabelFont
	local overlayFont = LootHistory.lootHistoryOverlayFont

	maxWidth, maxHeight = getRowDimensions(control, maxWidth, maxHeight)
	
	control.label:SetFont(labelFont)
	control.iconOverlayText:SetFont(overlayFont)
	
	local rowHeight = maxHeight
	local iconSize = rowHeight - 4

	local iconOverlayTextWidth = getWidth(overlayFont, control.iconOverlayText:GetText())
	setDimensions(control.iconOverlayText, iconOverlayTextWidth, rowHeight)
	
	setDimensions(control.icon, rowHeight, rowHeight)
	setDimensions(control.statusIcon, rowHeight, rowHeight)
	
	-- updateDimensions(control, iconTemplate, LootHistory.lootHistoryOverlayFont, control.iconOverlayText:GetText())
	-- SPACE_WORLD
	-- SPACE_CAMERA
	-- SPACE_INTERFACE
	
	
	setDimensions(control.label, maxWidth, rowHeight)
	setDimensions(control.backgroundHighlight, maxWidth, rowHeight)

	setDimensions(control, maxWidth, rowHeight)

--	control.label:SetDimensionConstraints(minMidth, 20, maxWidth, rowHeight)
--	control:SetDimensionConstraints(minMidth, 20, maxWidth + 20, maxHeight + 20)
	return maxWidth, maxHeight
end

local function updateStream(self, maxWidth, maxHeight)
	if self and #self.activeEntries > 0 then
		for k, entry in pairs(self.activeEntries) do
			if entry.Update then
				entry:Update()
			elseif entry.activeLines then
				for k, line in pairs(entry.activeLines) do
					maxWidth, maxHeight = updateRow(line, maxWidth, maxHeight)
				end
			else
				maxWidth, maxHeight = updateRow(entry, maxWidth, maxHeight)
			end
		end
	end
	return maxWidth, maxHeight
end

local function updateStreams(object)
	if not updating then
		updating = true
		local maxWidth, maxHeight
		for k, streamObject in streamsIterator(object) do
			if streamObject and #streamObject.activeEntries > 0 then
				maxWidth, maxHeight = streamObject:UpdateStream(maxWidth, maxHeight)
			end
		end
		updating = false
	end
end

--------------------------------------------------------------------------------
-- 
--------------------------------------------------------------------------------

local function postInitializeStreams(object)
	if not object.UpdateStreams then
		object.UpdateStreams = updateStreams
	
		for k, streamObject in streamsIterator(object) do
			if not streamObject.UpdateStream then
				streamObject.UpdateStream = updateStream
			
				local orig_onUpdateBuffer = streamObject.OnUpdateBuffer
				streamObject.OnUpdateBuffer = function(self, timeMs)
					local queuedBatches = self.queuedBatches
					
					orig_onUpdateBuffer(self, timeMs)
					
					if not ZO_IsTableEmpty(queuedBatches) then
						if timeMs > nextTimeToFlushMS then
							nextTimeToFlushMS = timeMs + FLUSH_UPDATE_TIME_MS
							object:UpdateStreams()
						end
					end
				end

				local orig_displayBatches = streamObject.DisplayBatches
				streamObject.DisplayBatches = function(self)
					orig_displayBatches(self)
					object:UpdateStreams()
				end
		
				local orig_equalitySetup = streamObject.templates[object.entryTemplate].equalitySetup
				streamObject.templates[object.entryTemplate].equalitySetup = function(fadingControlBuffer, currentEntry, newEntry)
					local currentEntryData = currentEntry.lines[1]
					if currentEntryData.entryType == LOOT_ENTRY_TYPE_COMPANION_EXPERIENCE then
						local newEntryData = newEntry.lines[1]
						local control = currentEntryData.control
						currentEntryData.gainedXp = currentEntryData.gainedXp + newEntryData.gainedXp
						
						if control then
							ZO_CraftingResults_Base_PlayPulse(control.iconOverlayText) -- added animation to icon text?
						end
					else
						orig_equalitySetup(fadingControlBuffer, currentEntry, newEntry)
					end
				end
			end
		end
	end
end

local function postInitialize(object)
	if not object.lootStream.UpdateStreams then
		postInitializeStreams(object)
		object.AddCompanionXpEntry		= LootHistory.AddCompanionXpEntry
		object.CanShowItemsInHistory	= LootHistory.CanShowItemsInHistory
		object.OnCompanionRapportUpdate = LootHistory.OnCompanionRapportUpdate
		object.AddCompanionRapportEntry = LootHistory.AddCompanionRapportEntry
	end
end

--------------------------------------------------------------------------------
-- 
--------------------------------------------------------------------------------

local function flushEntries(self)
	if self.lastAnchoredEntry then
		self.lastAnchoredEntry = nil
		self:ReleaseAllControls()
	end
	
	self.containerStartTimeMs = GetFrameTimeMilliseconds()
	ZO_ClearNumericallyIndexedTable(self.queuedTimedEntries)
	ZO_ClearNumericallyIndexedTable(self.queuedBatches)
	ZO_ClearNumericallyIndexedTable(self.queue)
	self:FlushEntries()
end

local function purgeLootQueue(object)
	object:DisplayLootQueue()
	for k, streamObject in streamsIterator(object) do
		flushEntries(streamObject)
	end
end

--------------------------------------------------------------------------------
-- 
--------------------------------------------------------------------------------

---@diagnostic disable-next-line: duplicate-set-field
function LootHistory:New(...)
	return ZO_LootHistory_Shared.New(self, ...)
end

function LootHistory:Initialize(control)
	self.control = control
    ZO_LootHistory_Shared.Initialize(self, control)
	
	postInitialize(LOOT_HISTORY_GAMEPAD)
end

function LootHistory:ShowPreview(show)
	local lootHistoy = SYSTEMS:GetObject(ZO_LOOT_HISTORY_NAME)
	purgeLootQueue(lootHistoy)

	if show then
		zo_callLater(function()
			lootHistoy:AddXpEntry(20000)
																									-- , craft
			-- OnNewItemReceived(itemLinkOrName, stackCount, itemSound, lootType, questItemIcon, itemId, isVirtual, isStolen, bonusDropSource)
			lootHistoy:OnNewItemReceived('|H0:item:45854:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h', 52, nil, nil, nil, 45854, nil, false)
			lootHistoy:OnNewItemReceived('|H0:item:135150:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h', 10, nil, nil, nil, 135150, nil, true)
			lootHistoy:OnNewItemReceived('|H0:item:30157:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h', 10, nil, nil, nil, 30157, nil, false)
			lootHistoy:OnNewItemReceived('|H0:item:23117:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h', 10, nil, nil, nil, 23117, true, false)
			lootHistoy:OnNewItemReceived('|H0:item:68247:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h', 10, nil, nil, nil, 68247, true, false)
			
			local activeCompanion = GetActiveCompanionDefId()
			activeCompanion = activeCompanion > 0 and activeCompanion or 1
			if activeCompanion > 0 then
				lootHistoy:OnCompanionRapportUpdate(activeCompanion, 900, 1, 1) -- - 899
				lootHistoy:OnCompanionRapportUpdate(activeCompanion, 1900, 1, 1) -- - 1899
				lootHistoy:OnCompanionRapportUpdate(activeCompanion, 1, 10, 1) -- + 9
				lootHistoy:OnCompanionRapportUpdate(activeCompanion, 1, 1900, 1) -- + 9
				
				lootHistoy:OnCompanionExperienceGainUpdate(activeCompanion, 19, 1000, 19000)
			end
		end, 500)
	end
end

function LootHistory:SetEntryTemplate()
	self.entryTemplate = 'ZO_LootHistory_KeyboardEntry'
end

do
	local SUPPORTED_SCENES = {
        ["gamepadTrade"] = true,
        ["playerSubmenu"] = true, -- Need this for daily login since this is the scene it exists in
        ["gameMenuInGame"] = true,
        ["gamepadInteract"] = true,
        ["crownCrateGamepad"] = true,
        ["mailManagerGamepad"] = true,
        ["gamepad_stats_root"] = true,
        ["codeRedemptionGamepad"] = true,
        ["gamepad_inventory_root"] = true,
        ["gamepad_market_purchase"] = true,
        ["giftInventoryViewGamepad"] = true,
        ["LevelUpRewardsClaimGamepad"] = true,
	}
	function LootHistory:CanShowItemsInHistory()
        local currentSceneName = SCENE_MANAGER:GetCurrentSceneName()
        return not self.hidden or SUPPORTED_SCENES[currentSceneName] or SCENE_MANAGER:IsSceneOnStack("gamepad_inventory_root")
	end
end

do
	local STATUS_ICONS = {
		[ZO_LOOT_HISTORY_DISPLAY_TYPE_CRAFT_BAG] = "EsoUI/Art/HUD/lootHistory_icon_craftBag.dds",
		[ZO_LOOT_HISTORY_DISPLAY_TYPE_STOLEN] = "EsoUI/Art/Inventory/inventory_stolenItem_icon.dds",
		[ZO_LOOT_HISTORY_DISPLAY_TYPE_COLLECTIONS] = "EsoUI/Art/HUD/Keyboard/lootHistory_icon_collections.dds",
		[ZO_LOOT_HISTORY_DISPLAY_TYPE_ANTIQUITIES] = "EsoUI/Art/HUD/Keyboard/lootHistory_icon_antiquities.dds",
		[ZO_LOOT_HISTORY_DISPLAY_TYPE_CROWN_CRATE] = "EsoUI/Art/HUD/Keyboard/lootHistory_icon_crownCrates.dds",
	}

	function LootHistory:GetStatusIcon(displayType)
		return STATUS_ICONS[displayType]
	end
end

do
	local HIGHLIGHTS = {
		[ZO_LOOT_HISTORY_DISPLAY_TYPE_CRAFT_BAG] = "EsoUI/Art/HUD/lootHistory_highlight.dds",
		[ZO_LOOT_HISTORY_DISPLAY_TYPE_STOLEN] = "EsoUI/Art/HUD/lootHistory_highlight_stolen.dds",
		[ZO_LOOT_HISTORY_DISPLAY_TYPE_COLLECTIONS] = "EsoUI/Art/HUD/lootHistory_highlight.dds",
		[ZO_LOOT_HISTORY_DISPLAY_TYPE_ANTIQUITIES] = "EsoUI/Art/HUD/lootHistory_highlight.dds",
		[ZO_LOOT_HISTORY_DISPLAY_TYPE_CROWN_CRATE] = "EsoUI/Art/HUD/lootHistory_highlight.dds",
	}

	function LootHistory:GetHighlight(displayType)
		return HIGHLIGHTS[displayType]
	end
end

do
	local BONUS_DROP_SOURCE_ICONS = {
		[BONUS_DROP_SOURCE_COMPANION] = "EsoUI/Art/HUD/lootHistory_bonusDropSourceIcon_companion.dds",
	}

	function LootHistory:GetBonusDropSourceIcon(bonusDropSource)
		return BONUS_DROP_SOURCE_ICONS[bonusDropSource]
	end
end

function LootHistory:InitializeFragment()
	self.fragment = ZO_HUDFadeSceneFragment:New(ZO_LootHistoryControl_Keyboard)
	self.fragment:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_FRAGMENT_SHOWN then
			self:DisplayLootQueue()
		elseif newState == SCENE_FRAGMENT_HIDING then
			self:HideLootQueue()
		end
	end)
	
	g_fragments[self] = self.fragment
	
	SCENE_MANAGER:GetScene("gameMenuInGame"):RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_SHOWN then
		elseif newState == SCENE_HIDDEN then
			local object = SYSTEMS:GetGamepadObject(ZO_LOOT_HISTORY_NAME)
			object:DisplayLootQueue()
			purgeLootQueue(object)
		end
	end)
end

function LootHistory:InitializeFadingControlBuffer(control)
	local HORIZ_OFFSET = 0
	local VERTICAL_OFFSET = -84
	local MAX_ENTRIES = 6
	local CONTAINER_SHOW_TIME_MS = self:GetContainerShowTime()
	local PERSISTENT_CONTAINER_SHOW_TIME_MS = self:GetPersistentContainerShowTime()
	local anchor = ZO_Anchor:New(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, HORIZ_OFFSET, VERTICAL_OFFSET)

	self.lootStreamPersistent = self:CreateFadingStationaryControlBuffer(control:GetNamedChild("PersistentContainer"), "ZO_LootHistory_FadeShared", "ZO_LootHistory_IconEntranceShared", "ZO_LootHistory_ContainerFadeShared", anchor, MAX_ENTRIES, PERSISTENT_CONTAINER_SHOW_TIME_MS, "CustomGamepadPersistent")
	self.lootStream = self:CreateFadingStationaryControlBuffer(control:GetNamedChild("Container"), "ZO_LootHistory_FadeShared", "ZO_LootHistory_IconEntranceShared", "ZO_LootHistory_ContainerFadeShared", anchor, MAX_ENTRIES, CONTAINER_SHOW_TIME_MS, "CustomGamepad")

	self.lootStreamPersistent:SetAdditionalEntrySpacingY(ZO_KEYBOARD_LOOT_HISTORY_ENTRY_SPACING_Y)
	self.lootStream:SetAdditionalEntrySpacingY(ZO_KEYBOARD_LOOT_HISTORY_ENTRY_SPACING_Y)
	
	postInitializeStreams(self)
end

local function syncQueues(object, objectToRemove)
	object.queue = objectToRemove.queue
	
	for k, streamObject in streamsIterator(object) do
		streamObject.queue				= objectToRemove[k].queue
		streamObject.pauseTimeMS		= objectToRemove[k].pauseTimeMS
		streamObject.queuedBatches		= objectToRemove[k].queuedBatches
		streamObject.activeEntries		= objectToRemove[k].activeEntries
		streamObject.queuedTimedEntries = objectToRemove[k].queuedTimedEntries
	end
--	objectToRemove:DisplayLootQueue()
end

local function enableObject(object)
	local objectToRemove = SYSTEMS:GetGamepadObject(ZO_LOOT_HISTORY_NAME)
	
	local lootPickupGamepadScene = SCENE_MANAGER:GetScene("lootGamepad")
	local gameMenuInGameScene = SCENE_MANAGER:GetScene("gameMenuInGame")
	
	SYSTEMS:GetSystem(ZO_LOOT_HISTORY_NAME).gamepadObject = object

	purgeLootQueue(objectToRemove)
	objectToRemove:HideLootQueue()
--	syncQueues(object, objectToRemove)
	
	zo_callLater(function()
		lootPickupGamepadScene:RemoveFragment(g_fragments[objectToRemove])
		gameMenuInGameScene:RemoveFragment(g_fragments[objectToRemove])

		lootPickupGamepadScene:AddFragment(g_fragments[object])
		gameMenuInGameScene:AddFragment(g_fragments[object])

		object:DisplayLootQueue()
	end, 10)
end

function LootHistory:SetState(state)
	if self.state ~= state then
		self.state = state

		if state == STATE_ENABLED then
			paddingMuliplyer = 0.2
			enableObject(self)
		elseif state == STATE_EXTRA then
			paddingMuliplyer = 0.9
			enableObject(LOOT_HISTORY_KEYBOARD)
		else
			enableObject(LOOT_HISTORY_GAMEPAD)
		end
	end
end

function LootHistory:UpdateFonts(savedVars)
	LootHistory.lootHistoryOverlayFont = savedVars.lootHistoryOverlayFont
	LootHistory.lootHistoryLabelFont = savedVars.lootHistoryLabelFont
	
--	postInitialize(SYSTEMS:GetGamepadObject(ZO_LOOT_HISTORY_NAME))
	nextTimeToFlushMS = 0
end

--------------------------------------------------------------------------------
-- Companion entries
--------------------------------------------------------------------------------

do
	local RAPPORT_INCREASE_BACKGROUND_COLOR = ZO_ColorDef:New("102d0b")
	local RAPPORT_DECREASE_BACKGROUND_COLOR = ZO_ColorDef:New("3f0a0a")
	local COMPANION_NAME_COLOR				= ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_UNIT_REACTION_COLOR, UNIT_REACTION_COLOR_COMPANION))

    function LootHistory:AddCompanionXpEntry(companionId, xpAdded)
        local collectibleId = GetCompanionCollectibleId(companionId)
        local colorizedCompanionName = COMPANION_NAME_COLOR:Colorize(GetCompanionName(companionId))
        local lootData =  {
            text = zo_strformat(SI_COMPANION_NAME_FORMATTER, colorizedCompanionName),
            icon = GetCollectibleIcon(collectibleId),
         --   stackCount = 1,
            stackCount = xpAdded,
            color = ZO_SELECTED_TEXT,
            companionId = companionId,
            companionName = colorizedCompanionName,
            gainedXp = xpAdded,
            entryType = LOOT_ENTRY_TYPE_COMPANION_EXPERIENCE,
            iconOverlayText = ZO_LootHistory_Shared.GetStackCountStringFromData,
            showIconOverlayText = ZO_LootHistory_Shared.ShouldShowStackCountStringFromData
        }
        local lootEntry = self:CreateLootEntry(lootData)
        lootEntry.isPersistent = true
        self:InsertOrQueue(lootEntry)
    end

    function LootHistory:AddCompanionRapportEntry(companionId, isIncrease, adjustmentAmountType, rapport)
        local colorizedCompanionName = COMPANION_NAME_COLOR:Colorize(GetCompanionName(companionId))
        local iconFormatter = isIncrease and LOOT_RAPPORT_INCREASE_ICON_FORMATTER or LOOT_RAPPORT_DECREASE_ICON_FORMATTER

		rapport =isIncrease and rapport or -rapport
        local lootData = {
            text = zo_strformat(SI_COMPANION_NAME_FORMATTER, colorizedCompanionName),
            icon = string.format(iconFormatter, adjustmentAmountType),
            color = ZO_SELECTED_TEXT,
            backgroundColor = isIncrease and RAPPORT_INCREASE_BACKGROUND_COLOR or RAPPORT_DECREASE_BACKGROUND_COLOR,
            companionId = companionId,
            companionName = colorizedCompanionName,
            entryType = LOOT_ENTRY_TYPE_COMPANION_RAPPORT,
			stackCount = rapport,
            iconOverlayText = ZO_LootHistory_Shared.GetStackCountStringFromData,
            showIconOverlayText = true
        }
        local lootEntry = self:CreateLootEntry(lootData)
        lootEntry.isPersistent = true
        self:InsertOrQueue(lootEntry)
    end
	
	function LootHistory:OnCompanionRapportUpdate(companionId, previousRapport, currentRapport, adjustmentAmountType)
		if currentRapport ~= previousRapport then
			local adjustmentAmount = math.abs(previousRapport - currentRapport)
			self:AddCompanionRapportEntry(companionId, currentRapport > previousRapport, adjustmentAmountType, adjustmentAmount)
		end
	end
end

--------------------------------------------------------------------------------
-- 
--------------------------------------------------------------------------------

function IJA_GamepadUIVisibility_LootHistory_Initialize(state)
	return LootHistory:New(IJA_LootHistoryControl_Keyboard)
end
