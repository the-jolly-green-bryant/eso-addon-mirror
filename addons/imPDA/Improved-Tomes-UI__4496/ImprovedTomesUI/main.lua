local addon = {
	name = 'ImprovedTomesUI',
	displayName = '|c7c42f2Imp|ceeeeeeroved Tomes UI|r',
	version = '6',
	-- settingsName = '',
	-- settingsDisplayName = '',
}

local DEFAULTS = {}

-- local Log = IMP_ImprovedTomesUI_Logger()

local EVENT_NAMESPACE = 'ImprovedTomesUIEventNamespace'

local TIER_COLORS = {
    {0.50, 0.70, 1.00}, -- Tier 1: Light Blue
    {0.30, 0.80, 1.00}, -- Tier 2: Blue-Cyan
    {0.10, 0.90, 1.00}, -- Tier 3: Cyan
    {0.00, 0.95, 0.95}, -- Tier 4: Light Cyan
    {0.00, 1.00, 0.80}, -- Tier 5: Green-Cyan
    {0.50, 1.00, 0.20}, -- Tier 6: Yellow-Green
    {1.00, 1.00, 0.00}, -- Tier 7: Yellow
    {1.00, 0.65, 0.00}, -- Tier 8: Orange
    {1.00, 0.35, 0.00}, -- Tier 9: Orange-Red
    {1.00, 0.00, 0.00}, -- Tier 10: Pure Red
    {1.00, 0.87, 0.00}, -- Tier 11 (bonus): Gold
    {1.00, 0.87, 0.00}, -- Tier 12 (bonus): Gold
}

-- esoui\ingame\tamrieltomes\tamrieltomes_manager.lua row 188
-- accrodin gto vanilla codebase, function below can return ONE id
local TAMRIEL_TOME_ID = GetActiveReferenceTrackIdsForRewardTrackType(REWARD_TRACK_TYPE_TAMRIEL_TOMES)
local REWARD_TRACK_ID = GetRewardTrackIdFromReferenceTrackId(REWARD_TRACK_TYPE_TAMRIEL_TOMES, TAMRIEL_TOME_ID)

function GetCostToProgressFromTierToTier(startingTier, tier)
    if tier <= startingTier then
        return 0
    end

    if tier > GetTotalNumTiersForRewardTrack(REWARD_TRACK_ID) then
        return 0
    end

    local totalCostToProgress = 0
    for nextTier = startingTier, tier-1 do
        totalCostToProgress = totalCostToProgress + GetCostToProgressToNextTier(REWARD_TRACK_ID, nextTier)
    end

    return totalCostToProgress
end

-- ----------------------------------------------------------------------------

local selectedRewardHash  -- TODO: move from here
local selectedControl

local function CreateScrollListDataType()
	local scrollListControl = IMP_ImprovedTomesUI_TLCContainerScrollableList

	local rewardTrackId = REWARD_TRACK_ID  -- TODO: not very good

	local function LayoutRow(rowControl, data, scrollList)
        local tierIndex = data.tierIndex
		local currentTier = data.currentTier  -- TODO: not very good
		local progressToNextTier = data.progressToNextTier  -- TODO: not very good
		-- local hasAccess = HasAccessToRewardTrackComponent(REWARD_TRACK_TYPE_TAMRIEL_TOMES, 1, REWARD_TRACK_COMPONENT_SECONDARY)  -- TODO: remove hradcoded tomeIndex

		local tierContainer = rowControl:GetNamedChild('Container')
		tierContainer:GetNamedChild('TierName'):SetText(tierIndex)
		tierContainer:GetNamedChild('TierName'):SetColor(unpack(TIER_COLORS[tierIndex]))
		if tierIndex > currentTier then
			tierContainer:GetNamedChild('TierName'):SetDesaturation(1)
		else
			tierContainer:GetNamedChild('TierName'):SetDesaturation(0)
		end

		if tierIndex > currentTier then
			local required = GetCostToProgressFromTierToTier(currentTier, tierIndex)
			-- tierContainer:GetNamedChild('Cost'):SetText(required - progressToNextTier)

			ZO_CurrencyControl_SetSimpleCurrency(
				tierContainer:GetNamedChild('Cost'),
				CURT_TOME_POINTS,
				required - progressToNextTier,
				ZO_KEYBOARD_CURRENCY_OPTIONS
			)
		else
			tierContainer:GetNamedChild('Cost'):SetText(zo_iconFormat('/esoui/art/miscellaneous/check_icon_64.dds', 32, 32))
		end

		for rewardTrackComponent = REWARD_TRACK_COMPONENT_PRIMARY, REWARD_TRACK_COMPONENT_SECONDARY do
			local componentContainer = tierContainer:GetNamedChild('Component'..rewardTrackComponent)
			local rewards = {}
			for rewardIndex = 1, 5 do
				local rewardId, overrideAmount, cost, displayQuality, hideQuality = GetTamrielTomesRewardInfo(rewardTrackId, tierIndex, rewardTrackComponent, rewardIndex)
				local rewardData = REWARDS_MANAGER:GetInfoForReward(rewardId, overrideAmount)

				rewards[#rewards+1] = {
					overrideAmount, cost, rewardData, rewardId, rewardIndex
				}
			end

			table.sort(rewards, function(left, right) return left[2] < right[2] end)

			for i = 1, #rewards do
				local reward = rewards[i]

				local rewardIndex = reward[5]
				local overrideAmount = reward[1]
				local cost = reward[2]
				local rewardData = reward[3]
				local rewardId = reward[4]
				local texture = rewardData:GetKeyboardIcon()

				local rewardContainer = componentContainer:GetNamedChild('Reward'..i)
				rewardContainer:GetNamedChild('Icon'):SetTexture(texture)
				if tierIndex > currentTier then
					rewardContainer:GetNamedChild('Icon'):SetDesaturation(1)
				else
					rewardContainer:GetNamedChild('Icon'):SetDesaturation(0)
				end

				local quantity = overrideAmount
				local isRewardList = rewardData.rewardType == REWARD_ENTRY_TYPE_REWARD_LIST
				if isRewardList then
					local rewardListId = GetRewardListIdFromReward(rewardId)
					if rewardListId ~= 0 then
						local rewardListData = REWARDS_MANAGER:GetAllRewardInfoForRewardList(rewardListId)
						quantity = #rewardListData - 1
					end
				end

				if quantity > 1 then
					if isRewardList then
						quantity = zo_strformat(SI_TAMRIEL_TOMES_REWARD_LIST_QUANTITY_FORMATTER, quantity)
					else
						quantity = ZO_CommaDelimitNumber(quantity)
					end
				else
					quantity = ''
				end
				rewardContainer:GetNamedChild('Quantity'):SetText(quantity)

				local tomeIndex = GetReferenceTrackIndex(REWARD_TRACK_TYPE_TAMRIEL_TOMES, TAMRIEL_TOME_ID)
				local isClaimed = GetRewardTrackRewardClaimedState(REWARD_TRACK_TYPE_TAMRIEL_TOMES, tomeIndex, tierIndex, rewardTrackComponent, rewardIndex)
				if isClaimed then
					rewardContainer:GetNamedChild('Cost'):SetText(zo_iconFormat('/esoui/art/miscellaneous/check_icon_64.dds', 28, 28))
				else
					if cost > 0 then
						ZO_CurrencyControl_SetSimpleCurrency(
							rewardContainer:GetNamedChild('Cost'),
							CURT_TOME_POINTS,
							cost,
							ZO_KEYBOARD_CURRENCY_OPTIONS
						)
					else
						rewardContainer:GetNamedChild('Cost'):SetText('Free!')
					end
				end

				if selectedRewardHash == ('%02d%02d%02d'):format(tierIndex, rewardTrackComponent, rewardIndex) then  -- TODO: extract hash logic
					rewardContainer:GetNamedChild('Selection'):SetHidden(false)
					selectedControl = rewardContainer
				else
					rewardContainer:GetNamedChild('Selection'):SetHidden(true)
				end

				rewardData.trackId = rewardTrackId
				rewardData.trackIndex = tomeIndex
				rewardData.tierIndex = tierIndex
				rewardData.rewardComponent = rewardTrackComponent
				rewardData.rewardIndex = rewardIndex

				rewardContainer.data = rewardData
			end
		end
    end

	local control = scrollListControl
	local typeId = 1
	local templateName = 'IMP_IMP_ImprovedTomesUI_RewardsTemplateHorizontal'
	-- local height = 108
	local height = 148
	local setupFunction = LayoutRow
	local hideCallback = nil
	local dataTypeSelectSound = nil
	local resetControlCallback = nil

	ZO_ScrollList_AddDataType(control, typeId, templateName, height, setupFunction, hideCallback, dataTypeSelectSound, resetControlCallback)
end

local dirty = false
local TOME_POINTS_NAME = GetCurrencyName(CURT_TOME_POINTS)
local function UpdateScrollListControl()
	if IMP_ImprovedTomesUI_TLC:IsHidden() then
		-- dirty = true
		return
	end

	if not dirty then return end

	local tomeIndex = GetReferenceTrackIndex(REWARD_TRACK_TYPE_TAMRIEL_TOMES, TAMRIEL_TOME_ID)
	local trackId, currentTier, progressToNextTier, endTime = GetInfoForRewardTrack(REWARD_TRACK_TYPE_TAMRIEL_TOMES, tomeIndex)
	IMP_ImprovedTomesUI_TLCContainerCurrency:SetText(('%s: %d'):format(TOME_POINTS_NAME, GetPlayerStoredCurrencyAmount(CURT_TOME_POINTS)))

	local hasAccess = HasAccessToRewardTrackComponent(REWARD_TRACK_TYPE_TAMRIEL_TOMES, tomeIndex, REWARD_TRACK_COMPONENT_SECONDARY)  -- TODO: remove hradcoded tomeIndex
	local premiumHighlightControl = IMP_ImprovedTomesUI_TLCContainerScrollableListPremiumHighlight
	premiumHighlightControl:GetNamedChild('PremiumContainerLock'):SetHidden(hasAccess)
	if hasAccess then
		premiumHighlightControl:GetNamedChild('Background'):SetEdgeColor(1, 0.87, 0)
	else
		premiumHighlightControl:GetNamedChild('Background'):SetEdgeColor(0.93, 0, 0)
	end

    local scrollListControl = IMP_ImprovedTomesUI_TLCContainerScrollableList
    local dataList = ZO_ScrollList_GetDataList(scrollListControl)

    local function CreateAndAddDataEntry(tierIndex)
        local value = {tierIndex = tierIndex, currentTier = currentTier, progressToNextTier = progressToNextTier}
        local entry = ZO_ScrollList_CreateDataEntry(1, value)

		table.insert(dataList, entry)
    end

    ZO_ScrollList_Clear(scrollListControl)

	for tierIndex = 1, GetTotalNumTiersForRewardTrack(REWARD_TRACK_ID) do
		CreateAndAddDataEntry(tierIndex)
	end

    -- table.sort(dataList, function(a, b) return a.data.zoneName < b.data.zoneName end)

    ZO_ScrollList_Commit(scrollListControl)
end

local function MarkDirty()
	dirty = true
	UpdateScrollListControl()
end

-- SCENE ----------------------------------------------------------------------

local function CreateFragment()
	return ZO_SimpleSceneFragment:New(IMP_ImprovedTomesUI_TLC)
end

local function CreateScenes()
	local scene1Name = 'ImprovedTomesUIScene'

	local IMPROVED_TOMES_UI_SCENE = ZO_Scene:New(scene1Name, SCENE_MANAGER)

	local fragment = CreateFragment()
	IMPROVED_TOMES_UI_SCENE:AddFragment(fragment)
    IMPROVED_TOMES_UI_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
    IMPROVED_TOMES_UI_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
    -- IMPROVED_TOMES_UI_SCENE:AddFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_KEYBOARD_CURRENT)
	IMPROVED_TOMES_UI_SCENE:AddFragment(RIGHT_BG_FRAGMENT)
    IMPROVED_TOMES_UI_SCENE:AddFragment(TITLE_FRAGMENT)

	ZO_CreateStringId('SI_IMPROVED_TOMES_UI_MENU_ROOT_TITLE', 'Tamriel Tomes')
    IMPROVED_TOMES_UI_SCENE:AddFragment(ZO_SetTitleFragment:New(SI_IMPROVED_TOMES_UI_MENU_ROOT_TITLE))

	IMPROVED_TOMES_UI_SCENE:AddFragment(ITEM_PREVIEW_KEYBOARD:GetFragment())
	IMPROVED_TOMES_UI_SCENE:AddFragment(MINIMIZE_CHAT_FRAGMENT)
	IMPROVED_TOMES_UI_SCENE:AddFragment(PREVIEW_KEYBIND_INTERCEPT_LAYER_FRAGMENT)
	IMPROVED_TOMES_UI_SCENE:AddFragment(STOP_MOVEMENT_FRAGMENT)
	IMPROVED_TOMES_UI_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_REWARD_TRACK_BOOK)
	IMPROVED_TOMES_UI_SCENE:AddFragment(FRAME_TARGET_STANDARD_RIGHT_PANEL_FRAGMENT)
	IMPROVED_TOMES_UI_SCENE:AddFragment(FRAME_PLAYER_FRAGMENT)

	return scene1Name
end

local function CreateSceneGroup(sceneGroupName, ...)
	local SCENE_GROUP = ZO_SceneGroup:New(...)
	SCENE_MANAGER:AddSceneGroup(sceneGroupName, SCENE_GROUP)
end

local function AddSceneToCollections()
	local IMPROVED_TOMES_UI_SCENE = ZO_Scene:New('ImprovedTomesUIScene', SCENE_MANAGER)

    IMPROVED_TOMES_UI_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
    IMPROVED_TOMES_UI_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
    -- IMPROVED_TOMES_UI_SCENE:AddFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_KEYBOARD_CURRENT)
	IMPROVED_TOMES_UI_SCENE:AddFragment(RIGHT_BG_FRAGMENT)
    IMPROVED_TOMES_UI_SCENE:AddFragment(TITLE_FRAGMENT)
    IMPROVED_TOMES_UI_SCENE:AddFragment(COLLECTIONS_TITLE_FRAGMENT)

	IMPROVED_TOMES_UI_SCENE:AddFragment(ITEM_PREVIEW_KEYBOARD:GetFragment())
	IMPROVED_TOMES_UI_SCENE:AddFragment(MINIMIZE_CHAT_FRAGMENT)
	IMPROVED_TOMES_UI_SCENE:AddFragment(PREVIEW_KEYBIND_INTERCEPT_LAYER_FRAGMENT)
	IMPROVED_TOMES_UI_SCENE:AddFragment(STOP_MOVEMENT_FRAGMENT)
	IMPROVED_TOMES_UI_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_REWARD_TRACK_BOOK)
	IMPROVED_TOMES_UI_SCENE:AddFragment(FRAME_TARGET_STANDARD_RIGHT_PANEL_FRAGMENT)
	IMPROVED_TOMES_UI_SCENE:AddFragment(FRAME_PLAYER_FRAGMENT)

	local sceneGroupInfo = MAIN_MENU_KEYBOARD.sceneGroupInfo['collectionsSceneGroup']
	local iconData = sceneGroupInfo.menuBarIconData
	iconData[#iconData + 1] = {
        categoryName = SI_MAIN_MENU_TAMRIEL_TOMES,
        descriptor = 'ImprovedTomesUIScene',
		normal = 'EsoUI/Art/MainMenu/menuBar_tamrielTomes_up.dds',
		pressed = 'EsoUI/Art/MainMenu/menuBar_tamrielTomes_down.dds',
		disabled = 'EsoUI/Art/MainMenu/menuBar_tamrielTomes_disabled.dds',
		highlight = 'EsoUI/Art/MainMenu/menuBar_tamrielTomes_over.dds',
    }
	local sceneGroupBarFragment = sceneGroupInfo.sceneGroupBarFragment
	IMPROVED_TOMES_UI_SCENE:AddFragment(sceneGroupBarFragment)

	local scenegroup = SCENE_MANAGER:GetSceneGroup('collectionsSceneGroup')
	scenegroup:AddScene('ImprovedTomesUIScene')

	MAIN_MENU_KEYBOARD:AddRawScene('ImprovedTomesUIScene', MENU_CATEGORY_COLLECTIONS, MAIN_MENU_KEYBOARD.categoryInfo[MENU_CATEGORY_COLLECTIONS], 'collectionsSceneGroup')
end

local MENU_CATEGORY_IMPROVED_TOMES_UI = {
	binding = 'IMPROVED_TAMRIEL_TOMES',
	categoryName = SI_MAIN_MENU_TAMRIEL_TOMES,

	previousButtonExtraPadding = 10,
	-- barPadding = 20,
	-- hideCategoryBar = true,
	-- hideSceneGroupBar = true,
	disabledTooltipText = zo_strformat(SI_TAMRIEL_TOMES_MAIN_MENU_TOOLTIP_FORMATTER, GetString(SI_MAIN_MENU_TAMRIEL_TOMES), GetString(SI_TAMRIEL_TOMES_ARE_UNAVAILABLE)),

	normal = 'EsoUI/Art/MainMenu/menuBar_tamrielTomes_up.dds',
	pressed = 'EsoUI/Art/MainMenu/menuBar_tamrielTomes_down.dds',
	disabled = 'EsoUI/Art/MainMenu/menuBar_tamrielTomes_disabled.dds',
	highlight = 'EsoUI/Art/MainMenu/menuBar_tamrielTomes_over.dds',

	indicators = function()
		if TAMRIEL_TOMES_MANAGER and (TAMRIEL_TOMES_MANAGER:HasNewTomes() or TIMED_ACTIVITIES_MANAGER:HasClaimableTimedActivities() or TIMED_ACTIVITIES_MANAGER:HasNewTimedActivities()) then
			return { ZO_KEYBOARD_NEW_ICON }
		end
	end,

	disableWhenNoTamrielTomesAreAvailable = true,
}

local SUBCATEGORY_ICON_DATA = {
	{
		categoryName = SI_MAIN_MENU_TAMRIEL_TOMES,
		descriptor = 'ImprovedTomesUIScene',
		normal = 'EsoUI/Art/MainMenu/menuBar_tamrielTomes_up.dds',
		pressed = 'EsoUI/Art/MainMenu/menuBar_tamrielTomes_down.dds',
		disabled = 'EsoUI/Art/MainMenu/menuBar_tamrielTomes_disabled.dds',
		highlight = 'EsoUI/Art/MainMenu/menuBar_tamrielTomes_over.dds',
	},
}

-- ----------------------------------------------------------------------------

function addon:OnLoad()
	-- Log('Loading %s v%s', self.name, self.version)

	-- local sv = ZO_SavedVars:NewAccountWide('IMP_PVP_UI_SV', 1, nil, DEFAULTS)
	-- IMP_PVP_UI_InitializeSettings(addon.name .. 'Settings', addon.displayName, sv)

	CreateScrollListDataType()
	MarkDirty()

	EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_CURRENCY_UPDATE, MarkDirty)
	EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_REWARD_TRACK_REWARD_CLAIMED, MarkDirty)

	IMP_ImprovedTomesUI_TLC:SetHandler('OnEffectivelyShown', UpdateScrollListControl)
	IMP_ImprovedTomesUI_TLC:SetHandler('OnEffectivelyHidden', function()
		selectedRewardHash = nil
		if self.keybinds then
			KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybinds)
			self.keybinds = nil
		end
	end)

	local SCENE_GROUP_NAME = 'ImprovedTomesUISceneGroup'
	CreateSceneGroup(SCENE_GROUP_NAME, CreateScenes())

	local category = IMP_MAIN_MENU:AddCategory(MENU_CATEGORY_IMPROVED_TOMES_UI)
	IMP_MAIN_MENU:AddMenu(category, SCENE_GROUP_NAME, SUBCATEGORY_ICON_DATA)

	self.animations = GetAnimationManager():CreateTimelineFromVirtual('IMP_HighlightTimeline')
	self.animations:GetAnimation(1):SetAnimatedControl(IMP_ImprovedTomesUI_TLCHighlight)
end

-- ----------------------------------------------------------------------------

local function OnAddonLoaded(_, addonName)
	if addonName ~= addon.name then return end
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

	addon:OnLoad()

	IMP_ImprovedTomesUI = nil
	-- IMP_ImprovedTomesUI_Logger = nil

	ZO_PostHook(ZO_TimedActivities_Keyboard, 'InitializeControls', function(self_, ...)
		self_.keybindStripDescriptor[1] = {
            alignment = KEYBIND_STRIP_ALIGN_CENTER,
            name = GetString(SI_DIALOG_BACK),
            keybind = "UI_SHORTCUT_NEGATIVE",
            callback = function()
				local previousScene = SCENE_MANAGER.previousScene
				if previousScene == TAMRIEL_TOMES_SCENE_KEYBOARD then
					previousScene = HUD_SCENE
				end

				SCENE_MANAGER:Show(previousScene.name)
			end,
            sound = SOUNDS.TAMRIEL_TOMES_NAVIGATE_BACK,
        }
	end)
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
IMP_ImprovedTomesUI = addon


local previewId
local function _preview(rewardId, rewardQuantity, buttonGroup, force)
	if addon.keybinds then
		KEYBIND_STRIP:RemoveKeybindButtonGroup(addon.keybinds)
		addon.keybinds = nil
	end

	if previewId then
		zo_removeCallLater(previewId)
		previewId = nil
	end

	local rewardData = REWARDS_MANAGER:GetInfoForReward(rewardId, rewardQuantity)
	TAMRIEL_TOMES_SCREEN_KEYBOARD:SetActiveRewardListRewardData(rewardData)

	local delay = 250
	if force then delay = 0 end
	previewId = zo_callLater(function()
		TAMRIEL_TOMES_SCREEN_KEYBOARD:BeginPreview(ZO_TAMRIEL_TOMES_REWARD_DATA_PREVIEW_TYPES.QUICK_PREVIEW, rewardData)
		previewId = nil

		if buttonGroup then
			KEYBIND_STRIP:AddKeybindButtonGroup(buttonGroup)
			addon.keybinds = buttonGroup
		end
	end, delay)

	return true
end

local function getCircular(arr, index)
    return arr[((index - 1) % #arr) + 1]
end

local function EndPreview(control, force)
	if previewId then
		zo_removeCallLater(previewId)
		previewId = nil
	end

	local delay = 250
	if force then delay = 0 end
	previewId = zo_callLater(function()
		TAMRIEL_TOMES_SCREEN_KEYBOARD:EndPreviewInternal()
		previewId = nil
	end, delay)

	if addon.keybinds then
		KEYBIND_STRIP:RemoveKeybindButtonGroup(addon.keybinds)
		addon.keybinds = nil
	end
end

local function _previewListRewardIndex(rewardId, rewardIndex, force)
	local rewardListId = GetRewardListIdFromReward(rewardId)
	if rewardListId  == 0 then return end

	local rewardListData = REWARDS_MANAGER:GetAllRewardInfoForRewardList(rewardListId)

	local rewardData = getCircular(rewardListData, rewardIndex)

	if not CanPreviewReward(rewardData.rewardId) then return end

	local previewButtonGroup = {
		{
			name = ("Previous (%s)"):format(getCircular(rewardListData, rewardIndex-1).formattedName),
			keybind = "UI_SHORTCUT_PRIMARY",
			callback = function() _previewListRewardIndex(rewardId, rewardIndex-1, true) end,
		},
		{
			name = GetString(SI_COLLECTIBLE_ACTION_END_PREVIEW),
			keybind = "UI_SHORTCUT_NEGATIVE",
			callback = function() EndPreview(nil, true) end,
		},
		{
			name = ("Next (%s)"):format(getCircular(rewardListData, rewardIndex+1).formattedName),
			keybind = "UI_SHORTCUT_SECONDARY",
			callback = function() _previewListRewardIndex(rewardId, rewardIndex+1, true) end,
		},
		alignment = KEYBIND_STRIP_ALIGN_CENTER,
	}

	return _preview(rewardData.rewardId, rewardData.quantity or 1, previewButtonGroup, force)
end

local currentRewardListIndex
local function BeginPreview(control)
	local rewardId = control.data.rewardId
	currentRewardListIndex = 1

	local isRewardList = control.data.rewardType == REWARD_ENTRY_TYPE_REWARD_LIST
	if isRewardList then
		return _previewListRewardIndex(rewardId, currentRewardListIndex)
	else
		if rewardId == 0 or not CanPreviewReward(rewardId) then
			return
		end

		local previewButtonGroup = {
			{
				name = GetString(SI_COLLECTIBLE_ACTION_END_PREVIEW),
				keybind = "UI_SHORTCUT_NEGATIVE",
				callback = function() EndPreview(nil, true) end,
			},
			alignment = KEYBIND_STRIP_ALIGN_CENTER,
		}

		return _preview(rewardId, control.data.quantity or 1, previewButtonGroup)
	end
end

local highlightControl = IMP_ImprovedTomesUI_TLCHighlight
local hidingId = nil
local function MoveHighlight(control)
	if highlightControl:IsHidden() then
		highlightControl:ClearAnchors()
		highlightControl:SetAnchor(TOP, control, TOP, 0, -8)
		highlightControl:SetHidden(false)  -- TODO: add alpha animation

		return
	end

	if hidingId then
		zo_removeCallLater(hidingId)
		hidingId = nil
	end

	local dX = (highlightControl:GetRight() + highlightControl:GetLeft()) / 2 - (control:GetRight() + control:GetLeft()) / 2
	local dY = highlightControl:GetTop() - control:GetTop()

	highlightControl:ClearAnchors()
	highlightControl:SetAnchor(TOP, control, TOP, dX, dY)  -- -8

	local translateAnimation = addon.animations:GetAnimation(1)
	translateAnimation:SetStartOffsetX(dX)
	translateAnimation:SetStartOffsetY(dY)
	translateAnimation:SetEndOffsetX(0)
	translateAnimation:SetEndOffsetY(-8)

	addon.animations:PlayFromStart()
end

local function HideHighlight()
	hidingId = zo_callLater(function()
		highlightControl:SetHidden(true)
		hidingId = nil
	end, 850)
end

local function ChangeSaturation(control)
	local icon = control:GetNamedChild('Icon')
	control.startDesaturation = icon:GetDesaturation()
	icon:SetDesaturation(0)
end

local function RevertSaturation(control)
	-- if control ~= selectedControl then
	control:GetNamedChild('Icon'):SetDesaturation(control.startDesaturation)
	-- end
end

function IMP_ImprovedTomesUI_Reward_OnMouseEnter(control)
	ZO_Rewards_Shared_OnMouseEnter(control, RIGHT, LEFT, -15)
	-- BeginPreview(control)
	MoveHighlight(control)
	ChangeSaturation(control)
end

function IMP_ImprovedTomesUI_Reward_OnMouseExit(control)
	ZO_Rewards_Shared_OnMouseExit(control)
	-- EndPreview(control)
	HideHighlight()
	RevertSaturation(control)
end

local function _rewardHash(rewardContainerControl)
	local d = rewardContainerControl.data
	return ('%02d%02d%02d'):format(d.tierIndex, d.rewardComponent, d.rewardIndex)
end

local selectionControl = IMP_ImprovedTomesUI_TLCSelection
local function SetSelection(control)
	local rewardHash = _rewardHash(control)

	if selectedControl then
		selectedControl:GetNamedChild('Selection'):SetHidden(true)
	end

	control:GetNamedChild('Selection'):SetHidden(false)
	selectedRewardHash = rewardHash
	selectedControl = control
end

local function UnsetSelection(control)
	control:GetNamedChild('Selection'):SetHidden(true)

	-- if selectedControl and selectionControl.startDesaturation then
	-- 	selectionControl:GetNamedChild('Icon'):SetDesaturation(selectedControl.startDesaturation)
	-- end

	selectedRewardHash = nil
	selectedControl = nil
end

function IMP_ImprovedTomesUI_Reward_OnMouseClick(control)
	if selectedRewardHash == _rewardHash(control) then
		UnsetSelection(control)
		EndPreview(control)
	else
		SetSelection(control)
		if not BeginPreview(control) then
			EndPreview(control)
		end
	end
end

function IMP_ImprovedTomesUI_Reward_OnMouseDoubleClick(control)
	local data = control.data

	ClaimRewardTrackReward(REWARD_TRACK_TYPE_TAMRIEL_TOMES, data.trackIndex, data.tierIndex, data.rewardComponent, data.rewardIndex)
end


-- feature: favorites
-- make it not return to first submenu
-- moving background
-- remove flickering on preview change