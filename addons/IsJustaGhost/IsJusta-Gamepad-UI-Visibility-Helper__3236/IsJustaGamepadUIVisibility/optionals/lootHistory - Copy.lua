
---------------------------------------------------------------------------------------------------------------
-- Loot history
---------------------------------------------------------------------------------------------------------------
local LootHistory = {}

local USE_LOWERCASE_NUMBER_SUFFIXES = false

local RAPPORT_INCREASE_BACKGROUND_COLOR = ZO_ColorDef:New("102d0b")
local RAPPORT_DECREASE_BACKGROUND_COLOR = ZO_ColorDef:New("3f0a0a")
local COMPANION_NAME_COLOR = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_UNIT_REACTION_COLOR, UNIT_REACTION_COLOR_COMPANION))

local custom_AddCompanionXpEntry
local custom_AddCompanionRapportEntry
local keyboard_CanShowItemsInHistory
local original_AddCompanionXpEntry
local original_AddCompanionRapportEntry

local lableWidth = {
	["ZoFontGamepad18"] = 218,
	["ZoFontGamepad20"] = 240,
	["ZoFontGamepad22"] = 272,
	["ZoFontGamepad25"] = 284,
	["ZoFontGamepad27"] = 294,
	["ZoFontGamepad34"] = 500,
	["ZoFontGamepad36"] = 500,
	["ZoFontGamepad42"] = 500,
}

local fontAdjustment = {
	["ZoFontGamepad18"] = 27,
	["ZoFontGamepad20"] = 29,
	["ZoFontGamepad22"] = 29,
	["ZoFontGamepad25"] = 32,
	["ZoFontGamepad27"] = 36,
	["ZoFontGamepad34"] = 42,
	["ZoFontGamepad36"] = 44,
	["ZoFontGamepad42"] = 50,
}

local SUPPORTED_SCENES = {
	["gamepadInteract"] = true,
	["gamepad_inventory_root"] = true,
	["crownCrateGamepad"] = true,
	["gamepadTrade"] = true,
	["gamepad_stats_root"] = true,
	["LevelUpRewardsClaimGamepad"] = true,
	["giftInventoryViewGamepad"] = true,
	["playerSubmenu"] = true, -- Need this for daily login since this is the scene it exists in
	["mailManagerGamepad"] = true,
	["gamepad_market_purchase"] = true,
	["codeRedemptionGamepad"] = true,
}

-- used to replace the original Keyboard Loot History CanShowItemsInHistory function to allow gamepad scenes
local function canShowItemsInHistory()
	local currentSceneName = SCENE_MANAGER:GetCurrentSceneName()
	return not LOOT_HISTORY_KEYBOARD.hidden or SUPPORTED_SCENES[currentSceneName] or SCENE_MANAGER:IsSceneOnStack("gamepad_inventory_root")
end

local function setupEntryText(control, data)
	local text = data.text
	if type(text) == "function" then
		text = text(data)
	end
	control.label:SetText(text)
end

local function setupIconOverlayText(control, data)
	local overlayText = ZO_LootHistory_Shared.GetIconOverlayTextFromData(data)
	control.iconOverlayText:SetText(overlayText)
	local showOverlayText = ZO_LootHistory_Shared.GetShowIconOverlayTextFromData(data)
	control.iconOverlayText:SetHidden(not showOverlayText)
end

local function getExperienceStringFromData(data)
	return ZO_AbbreviateAndLocalizeNumber(data.gainedXp, NUMBER_ABBREVIATION_PRECISION_TENTHS, USE_LOWERCASE_NUMBER_SUFFIXES)
end

local function getRowHeight(control)
	return zo_max(
		fontAdjustment[control.lootHistoryOverlayFont], 
		fontAdjustment[control.lootHistoryLabelFont],
		25
	)
end

local function updateRowControl(control)
	if control == nil then return end
	
	IJA_LootHistory_Entry_Template_OnUpdate(control)
	
	local iconSize = fontAdjustment[control.lootHistoryOverlayFont]
	local width = fontAdjustment[control.lootHistoryLabelFont] * 8
	
	control.label:SetFont(control.lootHistoryLabelFont)
	control.iconOverlayText:SetFont(control.lootHistoryOverlayFont)
	
	control.icon:SetDimensions(iconSize,iconSize)
	
	control.label:SetWidth(width)
	control:SetWidth(width + iconSize)
	
	local height = getRowHeight(control)
	local textHeight = control.label:GetHeight()
	
	height = textHeight > height and textHeight or height
	control:SetHeight(height)
end

local function lootSetupFunction(control, data)
	setupEntryText(control, data)
	control.label:SetColor(data.color:UnpackRGBA())
	control.icon:SetTexture(data.icon)
	setupIconOverlayText(control, data)
	
	if data.statusIcon then
		control.statusIcon:SetTexture(data.statusIcon)
		control.statusIcon:SetHidden(false)
	else
		control.statusIcon:SetHidden(true)
	end
	if data.highlight then
		control.backgroundHighlight:SetTexture(data.highlight)
		control.backgroundHighlight:SetHidden(false)
	else
		control.backgroundHighlight:SetHidden(true)
	end
	if data.backgroundColor then
		control.background:SetColor(data.backgroundColor:UnpackRGB())
	else
		control.background:SetColor(ZO_BLACK:UnpackRGB())
	end
	
	IJA_LootHistory_Entry_Template_OnUpdate(control)
end

local function equalitySetup(fadingControlBuffer, currentEntry, newEntry)
	local currentEntryData = currentEntry.lines[1]
	local newEntryData = newEntry.lines[1]
	local control = currentEntryData.control
	
	if currentEntryData.entryType == LOOT_ENTRY_TYPE_COMPANION_EXPERIENCE then
		currentEntryData.gainedXp = currentEntryData.gainedXp + newEntryData.gainedXp
		if control then
			setupEntryText(control, currentEntryData)
			setupIconOverlayText(control, currentEntryData)
		--	ZO_CraftingResults_Base_PlayPulse(control.icon)
			ZO_CraftingResults_Base_PlayPulse(control.iconOverlayText) -- added animation to icon text?
		end
	elseif currentEntryData.entryType ~= LOOT_ENTRY_TYPE_MEDAL and currentEntryData.entryType ~= LOOT_ENTRY_TYPE_SCORE then
		currentEntryData.stackCount = currentEntryData.stackCount + newEntryData.stackCount
		if control and control.iconOverlayText then
			setupEntryText(control, currentEntryData)
			setupIconOverlayText(control, currentEntryData)
			ZO_CraftingResults_Base_PlayPulse(control.iconOverlayText)
		end
	end
end

local function updateStyle(self)
	if #self.activeEntries > 0 then
		for k, entry in pairs(self.activeEntries) do
			if entry.Update then
				entry:Update()
			elseif entry.activeLines then
				for k, line in pairs(entry.activeLines) do
					IJA_LootHistory_Entry_Template_OnUpdate(line)
				end
			end
		end
	end
end

local function addLootHistoryEntryTemplate()
	local entryTemplate = LOOT_HISTORY_KEYBOARD.lootStreamPersistent.templates['ZO_LootHistory_KeyboardEntry']
	
	for k, stream in pairs({'lootStreamPersistent', 'lootStream'}) do
		LOOT_HISTORY_KEYBOARD[stream].templates['IJA_LootHistory_Entry_Template'] = entryTemplate
		LOOT_HISTORY_KEYBOARD[stream].templates['IJA_LootHistory_Entry_Template'].equalitySetup = equalitySetup
		LOOT_HISTORY_KEYBOARD[stream].templates['IJA_LootHistory_Entry_Template'].setup = lootSetupFunction
		LOOT_HISTORY_KEYBOARD[stream].UpdateStyle = updateStyle
	end
end

function LootHistory:UseKeyboardLootHistory()
	--	set Keyboard Loot History CanShowItemsInHistory to custom CanShowItemsInHistory function to allow gamepad scenes
	LOOT_HISTORY_KEYBOARD.CanShowItemsInHistory = canShowItemsInHistory
	-- set "ZO_LootHistory" Gamepad System object to Keyboard Loot History
	SYSTEMS:GetSystem(ZO_LOOT_HISTORY_NAME).gamepadObject = LOOT_HISTORY_KEYBOARD
	
	-- set Keyboard Loot History entryTemplate to custom template
	LOOT_HISTORY_KEYBOARD.entryTemplate = "IJA_LootHistory_Entry_Template"
	
	SCENE_MANAGER:GetScene("lootGamepad"):AddFragment(KEYBOARD_LOOT_HISTORY_FRAGMENT)
	SCENE_MANAGER:GetScene("lootGamepad"):RemoveFragment(GAMEPAD_LOOT_HISTORY_FRAGMENT)
	
	
	LOOT_HISTORY_KEYBOARD.AddCompanionXpEntry = custom_AddCompanionXpEntry
--	LOOT_HISTORY_KEYBOARD.AddCompanionRapportEntry = AddCompanionRapportEntry
--	LOOT_HISTORY_KEYBOARD.AddCompanionRapportEntry = custom_AddCompanionRapportEntry
	
	-- added to allow the loot demo to be seen while in options
	SCENE_MANAGER:GetScene("gameMenuInGame"):AddFragment(KEYBOARD_LOOT_HISTORY_FRAGMENT)
	SCENE_MANAGER:GetScene("gameMenuInGame"):RemoveFragment(GAMEPAD_LOOT_HISTORY_FRAGMENT)
end

function LootHistory:Reset()
	--	set Keyboard Loot History CanShowItemsInHistory to original Keyboard Loot History CanShowItemsInHistory function
	LOOT_HISTORY_KEYBOARD.CanShowItemsInHistory = keyboard_CanShowItemsInHistory
	-- set "ZO_LootHistory" Gamepad System object to Gamepad Loot History
	SYSTEMS:GetSystem(ZO_LOOT_HISTORY_NAME).gamepadObject = LOOT_HISTORY_GAMEPAD
	
	-- set Keyboard Loot History entryTemplate to original template
	LOOT_HISTORY_KEYBOARD.entryTemplate = "ZO_LootHistory_KeyboardEntry"
	
	SCENE_MANAGER:GetScene("lootGamepad"):RemoveFragment(KEYBOARD_LOOT_HISTORY_FRAGMENT)
	SCENE_MANAGER:GetScene("lootGamepad"):AddFragment(GAMEPAD_LOOT_HISTORY_FRAGMENT)
				
	LOOT_HISTORY_KEYBOARD.AddCompanionXpEntry = original_AddCompanionXpEntry
	LOOT_HISTORY_KEYBOARD.AddCompanionRapportEntry = original_AddCompanionRapportEntry
	
		-- added to allow the loot demo to be seen while in options
	SCENE_MANAGER:GetScene("gameMenuInGame"):RemoveFragment(KEYBOARD_LOOT_HISTORY_FRAGMENT)
	SCENE_MANAGER:GetScene("gameMenuInGame"):AddFragment(GAMEPAD_LOOT_HISTORY_FRAGMENT)
end

function LootHistory:Enable(enabled)
--	ZO_LootHistoryControl_Gamepad:SetHidden(enabled)
	GAMEPAD_LOOT_HISTORY_FRAGMENT:Hide()
	
	if enabled then
		if not self.initialized then self:Initialize() end
		if LOOT_HISTORY_KEYBOARD.entryTemplate ~= "IJA_LootHistory_Entry_Template" then
			self:UseKeyboardLootHistory()
		end
	elseif LOOT_HISTORY_KEYBOARD.entryTemplate == "IJA_LootHistory_Entry_Template" then
		self:Reset()
	end
end

function LootHistory:UpdateFonts(savedVars)
	self.lootHistoryOverlayFont = savedVars.lootHistoryOverlayFont
	self.lootHistoryLabelFont = savedVars.lootHistoryLabelFont
	self.lootHistoryLabelWidth = lableWidth[savedVars.lootHistoryLabelFont]
	
	for k, stream in pairs({'lootStreamPersistent', 'lootStream'}) do
--	self:Debug( 'stream = %s, UpdateStyle = %s', stream, LOOT_HISTORY_KEYBOARD[stream].UpdateStyle)
		if LOOT_HISTORY_KEYBOARD[stream].UpdateStyle then
			LOOT_HISTORY_KEYBOARD[stream]:UpdateStyle()
		end
	end
end

function LootHistory:Initialize()
--	IJA_GAMEPADUIVISIBILITY:CreateLogger('LootHistory', self)
	addLootHistoryEntryTemplate()
	
	ZO_LootHistoryControl_Keyboard:SetTopmost(true)
	
	keyboard_CanShowItemsInHistory = LOOT_HISTORY_KEYBOARD.CanShowItemsInHistory
	original_AddCompanionXpEntry = LOOT_HISTORY_KEYBOARD.AddCompanionXpEntry
	original_AddCompanionRapportEntry = LOOT_HISTORY_KEYBOARD.AddCompanionRapportEntry

	custom_AddCompanionXpEntry = function(self, companionId, xpAdded)
		local collectibleId = GetCompanionCollectibleId(companionId)
		local colorizedCompanionName = COMPANION_NAME_COLOR:Colorize(GetCompanionName(companionId))
		
		local lootData =
		{
			text = ZO_CachedStrFormat("<<C:1>>", colorizedCompanionName),
			icon = GetCollectibleIcon(collectibleId),
			stackCount = 1,
			color = ZO_SELECTED_TEXT,
			companionId = companionId,
			gainedXp = xpAdded,
			companionName = colorizedCompanionName,
			entryType = LOOT_ENTRY_TYPE_COMPANION_EXPERIENCE,
			iconOverlayText = getExperienceStringFromData,
			showIconOverlayText = true
		}
		local lootEntry = self:CreateLootEntry(lootData)
		lootEntry.isPersistent = true
		self:InsertOrQueue(lootEntry)
	end

	custom_AddCompanionRapportEntry = function(self, companionId, isIncrease, rapport)
		local colorizedCompanionName = COMPANION_NAME_COLOR:Colorize(GetCompanionName(companionId))
		local lootData =
		{
			text = ZO_CachedStrFormat("<<C:1>>", colorizedCompanionName),
			icon = isIncrease and LOOT_RAPPORT_INCREASE_ICON or LOOT_RAPPORT_DECREASE_ICON,
			color = ZO_SELECTED_TEXT,
			stackCount = rapport,
			backgroundColor = isIncrease and RAPPORT_INCREASE_BACKGROUND_COLOR or RAPPORT_DECREASE_BACKGROUND_COLOR,
			companionId = companionId,
			companionName = colorizedCompanionName,
			entryType = LOOT_ENTRY_TYPE_COMPANION_RAPPORT,
			iconOverlayText = ZO_LootHistory_Shared.GetStackCountStringFromData,
			showIconOverlayText = true
		}
		local lootEntry = self:CreateLootEntry(lootData)
		lootEntry.isPersistent = true
		self:InsertOrQueue(lootEntry)
	end

	function ZO_LootHistory_Shared:OnCompanionRapportUpdate(companionId, previousRapport, currentRapport)
		if currentRapport ~= previousRapport then
			self:AddCompanionRapportEntry(companionId, currentRapport > previousRapport, currentRapport - previousRapport)
		end
	end

	self.initialized = true
	self.maxWidth = 0
end

function IJA_LootHistory_Entry_Template_OnUpdate(control)
	local iconSize = fontAdjustment[LootHistory.lootHistoryOverlayFont] - 4
	control.icon:SetDimensions(iconSize, iconSize)
	control.statusIcon:SetDimensions(iconSize, iconSize)
	
	local height = fontAdjustment[LootHistory.lootHistoryLabelFont]
	local width = height * 8
	
	control.label:SetFont(LootHistory.lootHistoryLabelFont)
	control.iconOverlayText:SetFont(LootHistory.lootHistoryOverlayFont)
	
	control.label:SetWidth(width)
	control:SetWidth(width + iconSize)
	
	local textHeight = zo_max(control.label:GetHeight(), height)
	height = zo_max(textHeight, iconSize + 4)
	
--	self:Debug( 'height = %s, textHeight = %s', height, textHeight)
	control:SetHeight(height)
	control.backgroundHighlight:SetDimensions(height, height)
end

function IJA_GamepadUIVisibility_LootHistory_Enable(enabled)
	LootHistory:Enable(enabled)
	return LootHistory
end
