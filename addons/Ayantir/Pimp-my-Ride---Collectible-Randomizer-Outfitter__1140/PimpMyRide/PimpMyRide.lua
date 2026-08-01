--[[
-------------------------------------------------------------------------------
-- PimpMyRide, by Ayantir
-------------------------------------------------------------------------------
This software is under : CreativeCommons CC BY-NC-SA 4.0
Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

You are free to:

    Share — copy and redistribute the material in any medium or format
    Adapt — remix, transform, and build upon the material
    The licensor cannot revoke these freedoms as long as you follow the license terms.


Under the following terms:

    Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
    NonCommercial — You may not use the material for commercial purposes.
    ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
    No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.


Please read full licence at : 
http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
]]

local ADDON_NAME = "PimpMyRide"
local ADDON_VERSION = "Nissan 240SX"
local ADDON_AUTHOR = "Ayantir"
local ADDON_WEBSITE = "http://www.esoui.com/downloads/fileinfo.php?id=1140"

local onlyAt1stLaunch = true
local categoryData = {}
local db

local COLLECTIBLE_CATEGORY_TYPE_TITLE = 99 -- faked

local LAM
local outfitterCategoryIndex
local actualOutfitId
local original_GetCollectiblesSearchResults = GetCollectiblesSearchResults	

-- Randomization
local enabledTitles = {}
local enabledCollectibles = {
	[COLLECTIBLE_CATEGORY_TYPE_VANITY_PET] = {},
	[COLLECTIBLE_CATEGORY_TYPE_COSTUME] = {},
	[COLLECTIBLE_CATEGORY_TYPE_MOUNT] = {},
	[COLLECTIBLE_CATEGORY_TYPE_POLYMORPH] = {},
	[COLLECTIBLE_CATEGORY_TYPE_SKIN] = {},
	[COLLECTIBLE_CATEGORY_TYPE_PERSONALITY] = {},
	[COLLECTIBLE_CATEGORY_TYPE_HAT] = {},
	[COLLECTIBLE_CATEGORY_TYPE_HAIR] = {},
	[COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS] = {},
	[COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY] = {},
	[COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY] = {},
	[COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING] = {},
	[COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING] = {},
}

local categoryEnabledForOutfitter = {
	[COLLECTIBLE_CATEGORY_TYPE_VANITY_PET] = true,
	[COLLECTIBLE_CATEGORY_TYPE_COSTUME] = true,
	[COLLECTIBLE_CATEGORY_TYPE_MOUNT] = true,
	[COLLECTIBLE_CATEGORY_TYPE_POLYMORPH] = true,
	[COLLECTIBLE_CATEGORY_TYPE_SKIN] = true,
	[COLLECTIBLE_CATEGORY_TYPE_PERSONALITY] = true,
	[COLLECTIBLE_CATEGORY_TYPE_HAT] = true,
	[COLLECTIBLE_CATEGORY_TYPE_HAIR] = true,
	[COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS] = true,
	[COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY] = true,
	[COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY] = true,
	[COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING] = true,
	[COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING] = true,
}

local includeNoCollectible = {
	[COLLECTIBLE_CATEGORY_TYPE_VANITY_PET] = "includeNoVanity",
	[COLLECTIBLE_CATEGORY_TYPE_COSTUME] = "includeNoCostume",
	[COLLECTIBLE_CATEGORY_TYPE_POLYMORPH] = "includeNoPolymorph",
	[COLLECTIBLE_CATEGORY_TYPE_SKIN] = "includeNoSkin",
	[COLLECTIBLE_CATEGORY_TYPE_PERSONALITY] = "includeNoPersonnality",
	[COLLECTIBLE_CATEGORY_TYPE_HAT] = "includeNoHat",
	[COLLECTIBLE_CATEGORY_TYPE_HAIR] = "includeNoHair",
	[COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS] = "includeNoHorns",
	[COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY] = "includeNoFacial",
	[COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY] = "includeNoJewelry",
	[COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING] = "includeNoHeadMarks",
	[COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING] = "includeNoBodyMarks",
}

local randomizeThis = {
	[COLLECTIBLE_CATEGORY_TYPE_MOUNT] = "randomizeMounts",
	[COLLECTIBLE_CATEGORY_TYPE_VANITY_PET] = "randomizeVanity",
	[COLLECTIBLE_CATEGORY_TYPE_COSTUME] = "randomizeCostumes",
	[COLLECTIBLE_CATEGORY_TYPE_POLYMORPH] = "randomizePolymorph",
	[COLLECTIBLE_CATEGORY_TYPE_SKIN] = "randomizeSkin",
	[COLLECTIBLE_CATEGORY_TYPE_PERSONALITY] = "randomizePersonnality",
	[COLLECTIBLE_CATEGORY_TYPE_HAT] = "randomizeHat",
	[COLLECTIBLE_CATEGORY_TYPE_HAIR] = "randomizeHair",
	[COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS] = "randomizeHorns",
	[COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY] = "randomizeFacial",
	[COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY] = "randomizeJewelry",
	[COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING] = "randomizeHeadMarks",
	[COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING] = "randomizeBodyMarks",
}

local defaults = {
	randomizeMounts = 2,
	randomizeVanity = 2,
	randomizeCostumes = 2,
	randomizePolymorph = 2,
	randomizeSkin = 2,
	randomizePersonnality = 2,
	randomizeHat = 2,
	randomizeHair = 2,
	randomizeHorns = 2,
	randomizeFacial = 2,
	randomizeJewelry = 2,
	randomizeHeadMarks = 2,
	randomizeBodyMarks = 2,
	RandomizeTitles = 2,
	includeNoVanity = true,
	includeNoCostume = true,
	includeNoTitle = true,
	includeNoPolymorph = true,
	includeNoSkin = true,
	includeNoPersonnality = true,
	includeNoHat = true,
	includeNoHair = true,
	includeNoHorns = true,
	includeNoFacial = true,
	includeNoJewelry = true,
	includeNoHeadMarks = true,
	includeNoBodyMarks = true,
	collectibleEnabled = {},
	titlesEnabled = {},
	outfits = {},
	keybinds = {
		[COLLECTIBLE_CATEGORY_TYPE_VANITY_PET] = {},
		[COLLECTIBLE_CATEGORY_TYPE_COSTUME] = {},
		[COLLECTIBLE_CATEGORY_TYPE_MOUNT] = {},
		[COLLECTIBLE_CATEGORY_TYPE_POLYMORPH] = {},
		[COLLECTIBLE_CATEGORY_TYPE_SKIN] = {},
		[COLLECTIBLE_CATEGORY_TYPE_PERSONALITY] = {},
		[COLLECTIBLE_CATEGORY_TYPE_HAT] = {},
		[COLLECTIBLE_CATEGORY_TYPE_HAIR] = {},
		[COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS] = {},
		[COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY] = {},
		[COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY] = {},
		[COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING] = {},
		[COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING] = {},
		[COLLECTIBLE_CATEGORY_TYPE_ASSISTANT] = {},
		[COLLECTIBLE_CATEGORY_TYPE_TROPHY] = {},
	}
}

local NOTIFICATIONS_PROVIDER = NOTIFICATIONS:GetCollectionsProvider()
local FORCE_HIDE_PROGRESS_TEXT = true
local DONT_HIDE_LOCKED = false
local DONT_ANIMATE = true

local function GetTextColor(enabled, normalColor, disabledColor)
	if enabled then
		return (normalColor or ZO_NORMAL_TEXT):UnpackRGBA()
	end
	return (disabledColor or ZO_DISABLED_TEXT):UnpackRGBA()
end

local function ApplyTextColorToLabel(label, ...)
	label:SetColor(GetTextColor(...))
end

local g_currentMouseTarget = nil

local Collectible = ZO_Object:Subclass()

function Collectible:New(...)
	local collectible = ZO_Object.New(self)
	collectible:Initialize(...)
	return collectible
end

function Collectible:Initialize(collectibleId)
	self.collectibleId = collectibleId
	self.isUsable = false
	self.isCooldownActive = false
	self.cooldownDuration = 0
	self.cooldownStartTime = 0

	if collectibleId then
		local name, description, icon, deprecatedLockedIcon, unlocked, purchasable, isActive, categoryType = self:GetCollectibleInfo()

		self.name = zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, name)
		self.icon = icon
		self.unlocked = unlocked
		self.purchasable = purchasable
		self.active = isActive
		self.categoryType = categoryType

		COLLECTIONS_BOOK_SINGLETON:RegisterCallback("OnUpdateCooldowns",
													function(...)
														-- don't try to update the control if we aren't the current collectible it's showing
														if self.control and self.control.collectible == self then
															self:OnUpdateCooldowns(...)
														end
													end)
	end
end

function Collectible:RefreshInfo()
	local unlocked, _, isActive = select(5, self:GetCollectibleInfo())
	self.unlocked = unlocked
	self.active = isActive
	self.isUsable = IsCollectibleUsable(self.collectibleId)
end

function Collectible:Show(control)
	self.control = control
	if self.collectibleId then
		control.collectible = self

		self:RefreshInfo()

		self.maxIconHeight = control.icon:GetHeight()
		
		control.title:SetText(self.name)
		local isUnlocked = self.unlocked
		local iconControl = control.icon
		iconControl:SetTexture(self.icon)

		self.isBlocked = IsCollectibleBlocked(self.collectibleId)
		local desaturation = (not isUnlocked or self.isBlocked) and 1 or 0
		iconControl:SetDesaturation(desaturation)
		control.highlight:SetDesaturation(desaturation)

		local textureSampleProcessingWeightTable = isUnlocked and ZO_UNLOCKED_ICON_SAMPLE_PROCESSING_WEIGHT_TABLE or ZO_LOCKED_ICON_SAMPLE_PROCESSING_WEIGHT_TABLE
		for type, weight in pairs(textureSampleProcessingWeightTable) do
			iconControl:SetTextureSampleProcessingWeight(type, weight)
		end
		ApplyTextColorToLabel(control.title, self.unlocked, ZO_NORMAL_TEXT, ZO_DISABLED_TEXT)

		control.cooldownIcon:SetTexture(self.icon)
		control.cooldownIconDesaturated:SetTexture(self.icon)
		control.cooldownIconDesaturated:SetDesaturation(1)
		control.cooldownTime:SetText("")

		control.title:SetHidden(false)
		iconControl:SetHidden(false)

		self:RefreshVisualLayer()

		if self:IsCurrentMouseTarget() then
			self:ShowKeybinds()
		end

		self:OnUpdateCooldowns()
	else
		control.title:SetHidden(true)
		control.icon:SetHidden(true)
		control.multiIcon:ClearIcons()
		control.cornerTag:SetHidden(true)
		self:EndCooldown()
		control.collectible = nil
	end
	self:RefreshMouseoverVisuals(DONT_ANIMATE)
end

function Collectible:RefreshVisualLayer()
	self:RefreshTooltip()
	self:RefreshMultiIcon()
end

function Collectible:RefreshMultiIcon()
	local control = self.control
	control.multiIcon:ClearIcons()

	if self.active then
		control.multiIcon:AddIcon(ACTIVE_ICON)

		if WouldCollectibleBeHidden(self.collectibleId) then
			control.multiIcon:AddIcon(HIDDEN_ICON)
		end
	end

	self.notificationId = NOTIFICATIONS_PROVIDER:GetNotificationIdForCollectible(self.collectibleId)
	self.isNew = IsCollectibleNew(self.collectibleId)
	if self.isNew then
		control.multiIcon:AddIcon(ZO_KEYBOARD_NEW_ICON)
	end

	control.multiIcon:Show()
end

function Collectible:GetId()
	return self.collectibleId
end

function Collectible:GetCollectibleInfo()
	return GetCollectibleInfo(self.collectibleId)
end

function Collectible:GetControl()
	return self.control
end

function Collectible:SetHighlightHidden(hidden, dontAnimate)
	local control = self.control
	control.highlight:SetHidden(false) -- let alpha take care of the actual hiding
	if not control.highlightAnimation then
		control.highlightAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("JournalProgressHighlightAnimation", control.highlight)
	end

	if hidden then
		ApplyTextColorToLabel(control.title, self.unlocked, ZO_NORMAL_TEXT, ZO_DISABLED_TEXT)
		if dontAnimate then
			control.iconAnimation:PlayInstantlyToStart()
			control.highlightAnimation:PlayInstantlyToStart()
		else
			control.iconAnimation:PlayBackward()
			control.highlightAnimation:PlayBackward()
		end
	else
		ApplyTextColorToLabel(control.title, self.unlocked, ZO_HIGHLIGHT_TEXT, ZO_SELECTED_TEXT)
		if dontAnimate then
			control.highlightAnimation:PlayInstantlyToEnd()
			if self.isCooldownActive ~= true then
				control.iconAnimation:PlayInstantlyToEnd()
			end
		else
			control.highlightAnimation:PlayForward()
			if self.isCooldownActive ~= true then
				control.iconAnimation:PlayForward()
			end
		end
	end
end

function Collectible:GetInteractionTextEnum()
	local textEnum
	if self.active then
		if self.categoryType == COLLECTIBLE_CATEGORY_TYPE_VANITY_PET or self.categoryType == COLLECTIBLE_CATEGORY_TYPE_ASSISTANT then
			textEnum = SI_COLLECTIBLE_ACTION_DISMISS
		else
			textEnum = SI_COLLECTIBLE_ACTION_PUT_AWAY
		end
	elseif self.isCooldownActive ~= true and self.isBlocked ~= true then
		if self.categoryType == COLLECTIBLE_CATEGORY_TYPE_MEMENTO then
			textEnum = SI_COLLECTIBLE_ACTION_USE
		else
			textEnum = SI_COLLECTIBLE_ACTION_SET_ACTIVE
		end
	end
	return textEnum
end

function Collectible:ShowCollectibleMenu()
	local collectibleId = self.collectibleId
	if not collectibleId then
		return
	end

	ClearMenu()

	--Use
	if self.isUsable then
		local textEnum = self:GetInteractionTextEnum()
		if textEnum then
			AddMenuItem(GetString(textEnum), function() UseCollectible(collectibleId) end)
		end
	end

	if IsChatSystemAvailableForCurrentPlatform() then
		--Link in chat
		local link = GetCollectibleLink(collectibleId, LINK_STYLE_BRACKETS)
		AddMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), function() ZO_LinkHandler_InsertLink(zo_strformat(SI_TOOLTIP_ITEM_NAME, link)) end)
	end

	--Rename
	if IsCollectibleRenameable(collectibleId) then
		AddMenuItem(GetString(SI_COLLECTIBLE_ACTION_RENAME), function() ZO_Dialogs_ShowDialog("COLLECTIONS_INVENTORY_RENAME_COLLECTIBLE", { collectibleId = collectibleId }) end)
	end

	ShowMenu(self.control)
end

local g_keybindUseCollectible = {
	name = nil,
	keybind = "UI_SHORTCUT_PRIMARY",
	callback = nil,
}

local g_keybindRenameCollectible = {
	name = GetString(SI_COLLECTIBLE_ACTION_RENAME),
	keybind = "UI_SHORTCUT_SECONDARY",
	callback = nil,
}

function Collectible:ShowKeybinds()
	local function UpdateKeybind(keybind)
		if KEYBIND_STRIP:HasKeybindButton(keybind) then
			KEYBIND_STRIP:UpdateKeybindButton(keybind)
		else
			KEYBIND_STRIP:AddKeybindButton(keybind)
		end
	end

	if self.isUsable then
		local textEnum = self:GetInteractionTextEnum()
		if textEnum then
			g_keybindUseCollectible.name = GetString(textEnum)
			g_keybindUseCollectible.callback = function() UseCollectible(self.collectibleId) end
			UpdateKeybind(g_keybindUseCollectible)
		end
	end

	if IsCollectibleRenameable(self.collectibleId) then
		g_keybindRenameCollectible.callback = function() ZO_Dialogs_ShowDialog("COLLECTIONS_INVENTORY_RENAME_COLLECTIBLE", { collectibleId = self.collectibleId }) end

		UpdateKeybind(g_keybindRenameCollectible)
	end
end

function Collectible:HideKeybinds()
	KEYBIND_STRIP:RemoveKeybindButton(g_keybindUseCollectible)
	KEYBIND_STRIP:RemoveKeybindButton(g_keybindRenameCollectible)
end

do
	local SHOW_NICKNAME, SHOW_HINT, SHOW_BLOCK_REASON = true, true, true
	function Collectible:OnMouseEnter()
		if self.collectibleId and self.collectibleId ~= 0 then
			InitializeTooltip(ItemTooltip, self.control.parent, RIGHT, -5, 0, LEFT)
			ItemTooltip:SetCollectible(self.collectibleId, SHOW_NICKNAME, SHOW_HINT, SHOW_BLOCK_REASON)
			g_currentMouseTarget = self
			self:ShowKeybinds()
			self:RefreshMouseoverVisuals()
		end
	end

	function Collectible:RefreshTooltip()
		if self:IsCurrentMouseTarget() then
			ClearTooltip(ItemTooltip)
			InitializeTooltip(ItemTooltip, self.parentRow, RIGHT, -5, 0, LEFT)
			ItemTooltip:SetCollectible(self.collectibleId, SHOW_NICKNAME, SHOW_HINT, SHOW_BLOCK_REASON)
		end
	end
end

function Collectible:OnMouseExit()
	if self.collectibleId then
		ClearTooltip(ItemTooltip)
		self:HideKeybinds()
		g_currentMouseTarget = nil
		self:RefreshMouseoverVisuals()

		if self.notificationId then
			RemoveCollectibleNotification(self.notificationId)
		end

		if self.isNew then
			ClearCollectibleNewStatus(self.collectibleId)
		end
	end
end

function Collectible:RefreshMouseoverVisuals(dontAnimate)
	local areVisualsHidden = not self:IsCurrentMouseTarget()
	self:SetHighlightHidden(areVisualsHidden, dontAnimate)
	if self.purchasable then
		self.control.cornerTag:SetHidden(areVisualsHidden)
	end
end

function Collectible:IsCurrentMouseTarget()
	return g_currentMouseTarget == self
end

function Collectible:OnClicked(button)
	if(button == MOUSE_BUTTON_INDEX_RIGHT) then
		--TODO: Add open store bridge (if applicable)
		self:ShowCollectibleMenu()
	end
end

function Collectible:OnMouseDoubleClick(button)
	if(button == MOUSE_BUTTON_INDEX_LEFT) then
		if self.collectibleId and self.isUsable then
			UseCollectible(self.collectibleId)
		end
	end
end

function Collectible:OnEffectivelyHidden()
	self:HideKeybinds()
end

function Collectible:OnUpdate()
	if self.isUsable and self.isCooldownActive then
		self:UpdateCooldownEffect()
	end
end

function Collectible:OnUpdateCooldowns()
	if self.isUsable then
		local remaining, duration = GetCollectibleCooldownAndDuration(self.collectibleId)
		if remaining > 0 and duration > 0 then
			self.cooldownDuration = duration
			self.cooldownStartTime = GetFrameTimeMilliseconds() - (duration - remaining)
			self:BeginCooldown()
			return
		end
	end

	self:EndCooldown()
end

function Collectible:BeginCooldown()
	local control = self.control
	self.isCooldownActive = true
	control.cooldownIcon:SetHidden(false)
	control.cooldownIconDesaturated:SetHidden(false)
	control.cooldownTime:SetHidden(false)
	control.cooldownEdge:SetHidden(false)
	self:SetHighlightHidden(true)
	self:HideKeybinds()
end

function Collectible:EndCooldown()
	local control = self.control
	self.isCooldownActive = false
	control.cooldownIcon:SetTextureCoords(0, 1, 0, 1)
	control.cooldownIcon:SetHeight(self.maxIconHeight)
	control.cooldownIcon:SetHidden(true)
	control.cooldownIconDesaturated:SetHidden(true)
	control.cooldownTime:SetHidden(true)
	control.cooldownEdge:SetHidden(true)
	control.cooldownTime:SetText("")
	if self:IsCurrentMouseTarget() then
		self:ShowKeybinds()
		self:SetHighlightHidden(false)
	end
end

function Collectible:UpdateCooldownEffect()
	local duration = self.cooldownDuration
	local cooldown = self.cooldownStartTime + duration - GetFrameTimeMilliseconds()
	local percentCompleted = (1 - (cooldown / duration)) or 1
	local height = zo_ceil(self.maxIconHeight * percentCompleted)
	local textureCoord = 1 - (height / self.maxIconHeight)

	local control = self.control
	control.cooldownIcon:SetHeight(height)
	control.cooldownIcon:SetTextureCoords(0, 1, textureCoord, 1)

	if not self.active then
		local secondsRemaining = cooldown / 1000
		control.cooldownTime:SetText(ZO_FormatTimeAsDecimalWhenBelowThreshold(secondsRemaining))
	else
		control.cooldownTime:SetText("")
	end
end

local function NameSorter(left, right)
	return left.name < right.name
end

local function GetFirstUnlockedCollectibleByCategory(categoryType)

	if categoryType and categoryData[categoryType] and #categoryData[categoryType].collectiblesEnabled > 0 then
		if #categoryData[categoryType].collectiblesEnabled == 1 and categoryData[categoryType].collectiblesEnabled[1].id == 0 then
			return
		else
			table.sort(categoryData[categoryType].collectiblesEnabled, NameSorter)
			return categoryData[categoryType].collectiblesEnabled[1].id
		end
	end

end

local function GetNumOutfitterOutfits()
	return #db.outfits + 1
end

local function GetActualOutfit()
	
	local outfitName = PimpMyRideOutfitter:GetNamedChild("OutfitNameBox"):GetText()
	local associateKeybind = PimpMyRideOutfitter:GetNamedChild("AssociateKeybind"):GetState() == BSTATE_PRESSED
	local collectibleData = {}
	
	for categoryType in pairs(categoryEnabledForOutfitter) do
		local stickerControl = PimpMyRideOutfitter:GetNamedChild("Sticker" .. categoryType)
		if stickerControl.collectible then
			collectibleData[categoryType] = stickerControl.collectible.collectibleId
		else
			collectibleData[categoryType] = 0
		end
	end
	
	return outfitName, associateKeybind, collectibleData
	
end

local function BuildOutfitterPanel(outfitIndex)
	
	actualOutfitId = outfitIndex
	
	ZO_CollectionsBookList:SetHidden(true)
	ZO_CollectionsBookCategory:SetHidden(true)
	PimpMyRideOutfitter:SetHidden(false)
	
	if actualOutfitId == 0 then
	
		PimpMyRideOutfitter:GetNamedChild("Remove"):SetState(BSTATE_DISABLED)
		PimpMyRideOutfitter:GetNamedChild("OutfitNameBox"):SetText("")
		
		for categoryType in pairs(categoryEnabledForOutfitter) do
			local stickerControl = PimpMyRideOutfitter:GetNamedChild("Sticker" .. categoryType)
			local active = GetFirstUnlockedCollectibleByCategory(categoryType)
			local collectibleObject = Collectible:New(active)
			collectibleObject:Show(stickerControl)
		end
		
	else
		
		PimpMyRideOutfitter:GetNamedChild("Remove"):SetHidden(false)
		
		PimpMyRideOutfitter:GetNamedChild("OutfitNameBox"):SetText(db.outfits[actualOutfitId].name)
		
		if db.outfits[actualOutfitId].associateKeybind then
			PimpMyRideOutfitter:GetNamedChild("AssociateKeybind"):SetState(BSTATE_PRESSED)
		else
			PimpMyRideOutfitter:GetNamedChild("AssociateKeybind"):SetState(BSTATE_NORMAL)
		end
		
		for categoryType in pairs(categoryEnabledForOutfitter) do
			local stickerControl = PimpMyRideOutfitter:GetNamedChild("Sticker" .. categoryType)
			local active = db.outfits[actualOutfitId].collectibleData[categoryType]
			if active ~= 0 or GetFirstUnlockedCollectibleByCategory(categoryType) then
				local collectibleObject = Collectible:New(active)
				collectibleObject:Show(stickerControl)
			end
		end
		
	end
	
end

local function GetOutfitterOutfitInfo(outfitIndex)
	if outfitIndex == 1 then
		return GetString(PMR_NEW_OUTFIT)
	else
		return db.outfits[outfitIndex - 1].name
	end
end

function COLLECTIONS_BOOK:UpdateCategoryLabels(data, retainScrollPosition)

	ZO_JournalProgressBook_Common.UpdateCategoryLabels(self, data)

	--Per a design call, we're (temporarily?) removing progress indicators, so no category progress
	COLLECTIONS_BOOK.categoryProgress:SetHidden(true)
	COLLECTIONS_BOOK.categoryLabel:SetHidden(true)
	
	if data.parentData and data.parentData.categoryIndex == outfitterCategoryIndex then
		BuildOutfitterPanel(data.categoryIndex - 1)
	else
		ZO_CollectionsBookList:SetHidden(false)
		ZO_CollectionsBookCategory:SetHidden(false)
		PimpMyRideOutfitter:SetHidden(true)
		self:BuildContentList(data, retainScrollPosition)
	end
	
end

function COLLECTIONS_BOOK:GetSubCategoryInfo(categoryIndex, i)
	if categoryIndex == outfitterCategoryIndex then
		return GetOutfitterOutfitInfo(i)
	else
		return GetCollectibleSubCategoryInfo(categoryIndex, i)
	end
end

local function IsActiveKeybind(collectibleCategoryType, collectibleId)
	return db.keybinds[collectibleCategoryType][collectibleId]
end

local function GetFirstFreeIndex(collectibleCategoryType)

	local freeIndex = {
		[1] = true,
		[2] = true,
		[3] = true,
		[4] = true,
		[5] = true,
		[6] = true,
		[7] = true,
		[8] = true,
		[9] = true,
		[10] = true,
	}

	for collectibleId, keybindIndex in pairs(db.keybinds[collectibleCategoryType]) do
		freeIndex[keybindIndex] = false
	end
	
	for keybindIndex in ipairs(freeIndex) do
		if keybindIndex then
			return keybindIndex
		end
	end
	
end

local function AddCollectibleToKeybinds(collectibleCategoryType, collectibleId)
	if NonContiguousCount(db.keybinds[collectibleCategoryType]) < 10 then
		local firstFreeIndex = GetFirstFreeIndex(collectibleCategoryType)
		
		db.keybinds[collectibleCategoryType][collectibleId] = firstFreeIndex
		local collectibleName = zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, GetCollectibleInfo(collectibleId))
		
		ZO_CreateStringId("SI_BINDING_NAME_PMR_" .. collectibleCategoryType .."_" .. firstFreeIndex, collectibleName)
		SafeAddVersion("SI_BINDING_NAME_PMR_" .. collectibleCategoryType .."_" .. firstFreeIndex, 1)
		
	end
end

local function RemoveCollectibleFromKeybinds(collectibleCategoryType, collectibleId)
	db.keybinds[collectibleCategoryType][collectibleId] = nil
end

local function ShowCollectibleMenu(self, ...)
	local collectibleId = self.collectibleId
	if not collectibleId then
		return
	end

	ClearMenu()

	--Use
	if self.isUsable then
		local textEnum = self:GetInteractionTextEnum()
		if textEnum then
			AddMenuItem(GetString(textEnum), function() UseCollectible(collectibleId) end)
		end
	end

	if IsChatSystemAvailableForCurrentPlatform() then
		--Link in chat
		local link = GetCollectibleLink(collectibleId, LINK_STYLE_BRACKETS)
		AddMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), function() ZO_LinkHandler_InsertLink(zo_strformat(SI_TOOLTIP_ITEM_NAME, link)) end)
	end
	
	local collectibleCategoryType = GetCollectibleCategoryType(collectibleId)	
	if self.isUsable and IsCollectibleValidForPlayer(collectibleId) then
		local keybindIndex = IsActiveKeybind(collectibleCategoryType, collectibleId)
		if keybindIndex then
			AddMenuItem(GetString(PMR_REM_KEYBIND), function()
				RemoveCollectibleFromKeybinds(collectibleCategoryType, collectibleId)
			end)
		else
			AddMenuItem(GetString(PMR_ADD_KEYBIND), function()
				AddCollectibleToKeybinds(collectibleCategoryType, collectibleId)
			end)
		end
	end

	--Rename
	if IsCollectibleRenameable(collectibleId) then
		AddMenuItem(GetString(SI_COLLECTIBLE_ACTION_RENAME), function() ZO_Dialogs_ShowDialog("COLLECTIONS_INVENTORY_RENAME_COLLECTIBLE", { collectibleId = collectibleId }) end)
	end

	ShowMenu(self.control)
	
	return true
	
end

local function InitializeVanillaStickerModifications()
	
	if ZO_CollectionsBookList1Row1Sticker1 and ZO_CollectionsBookList1Row1Sticker1.collectible then ZO_PreHook(ZO_CollectionsBookList1Row1Sticker1.collectible, "ShowCollectibleMenu", ShowCollectibleMenu) end
	if ZO_CollectionsBookList1Row1Sticker2 and ZO_CollectionsBookList1Row1Sticker2.collectible then ZO_PreHook(ZO_CollectionsBookList1Row1Sticker2.collectible, "ShowCollectibleMenu", ShowCollectibleMenu) end
	if ZO_CollectionsBookList1Row1Sticker3 and ZO_CollectionsBookList1Row1Sticker3.collectible then ZO_PreHook(ZO_CollectionsBookList1Row1Sticker3.collectible, "ShowCollectibleMenu", ShowCollectibleMenu) end
	
	if ZO_CollectionsBookList1Row2Sticker1 and ZO_CollectionsBookList1Row2Sticker1.collectible then ZO_PreHook(ZO_CollectionsBookList1Row2Sticker1.collectible, "ShowCollectibleMenu", ShowCollectibleMenu) end
	if ZO_CollectionsBookList1Row2Sticker2 and ZO_CollectionsBookList1Row2Sticker2.collectible then ZO_PreHook(ZO_CollectionsBookList1Row2Sticker2.collectible, "ShowCollectibleMenu", ShowCollectibleMenu) end
	if ZO_CollectionsBookList1Row2Sticker3 and ZO_CollectionsBookList1Row2Sticker3.collectible then ZO_PreHook(ZO_CollectionsBookList1Row2Sticker3.collectible, "ShowCollectibleMenu", ShowCollectibleMenu) end
	
	if ZO_CollectionsBookList1Row3Sticker1 and ZO_CollectionsBookList1Row3Sticker1.collectible then ZO_PreHook(ZO_CollectionsBookList1Row3Sticker1.collectible, "ShowCollectibleMenu", ShowCollectibleMenu) end
	if ZO_CollectionsBookList1Row3Sticker2 and ZO_CollectionsBookList1Row3Sticker2.collectible then ZO_PreHook(ZO_CollectionsBookList1Row3Sticker2.collectible, "ShowCollectibleMenu", ShowCollectibleMenu) end
	if ZO_CollectionsBookList1Row3Sticker3 and ZO_CollectionsBookList1Row3Sticker3.collectible then ZO_PreHook(ZO_CollectionsBookList1Row3Sticker3.collectible, "ShowCollectibleMenu", ShowCollectibleMenu) end
	
	if ZO_CollectionsBookList1Row4Sticker1 and ZO_CollectionsBookList1Row4Sticker1.collectible then ZO_PreHook(ZO_CollectionsBookList1Row4Sticker1.collectible, "ShowCollectibleMenu", ShowCollectibleMenu) end
	if ZO_CollectionsBookList1Row4Sticker2 and ZO_CollectionsBookList1Row4Sticker2.collectible then ZO_PreHook(ZO_CollectionsBookList1Row4Sticker2.collectible, "ShowCollectibleMenu", ShowCollectibleMenu) end
	if ZO_CollectionsBookList1Row4Sticker3 and ZO_CollectionsBookList1Row4Sticker3.collectible then ZO_PreHook(ZO_CollectionsBookList1Row4Sticker3.collectible, "ShowCollectibleMenu", ShowCollectibleMenu) end

	if ZO_CollectionsBookList1Row5Sticker1 and ZO_CollectionsBookList1Row5Sticker1.collectible then ZO_PreHook(ZO_CollectionsBookList1Row5Sticker1.collectible, "ShowCollectibleMenu", ShowCollectibleMenu) end
	if ZO_CollectionsBookList1Row5Sticker2 and ZO_CollectionsBookList1Row5Sticker2.collectible then ZO_PreHook(ZO_CollectionsBookList1Row5Sticker2.collectible, "ShowCollectibleMenu", ShowCollectibleMenu) end
	if ZO_CollectionsBookList1Row5Sticker3 and ZO_CollectionsBookList1Row5Sticker3.collectible then ZO_PreHook(ZO_CollectionsBookList1Row5Sticker3.collectible, "ShowCollectibleMenu", ShowCollectibleMenu) end

	if ZO_CollectionsBookList1Row6Sticker1 and ZO_CollectionsBookList1Row6Sticker1.collectible then ZO_PreHook(ZO_CollectionsBookList1Row6Sticker1.collectible, "ShowCollectibleMenu", ShowCollectibleMenu) end
	if ZO_CollectionsBookList1Row6Sticker2 and ZO_CollectionsBookList1Row6Sticker2.collectible then ZO_PreHook(ZO_CollectionsBookList1Row6Sticker2.collectible, "ShowCollectibleMenu", ShowCollectibleMenu) end
	if ZO_CollectionsBookList1Row6Sticker3 and ZO_CollectionsBookList1Row6Sticker3.collectible then ZO_PreHook(ZO_CollectionsBookList1Row6Sticker3.collectible, "ShowCollectibleMenu", ShowCollectibleMenu) end

end

function COLLECTIONS_BOOK:BuildCategories()

    --Per a design call, we're (temporarily?) removing progress indicators, so no summary blade
	self.categoryTree:Reset()
	self.nodeLookupData = {}
	
	local function AddCategoryByCategoryIndex(categoryIndex)
		local name, numSubCategories, _, _, _, hidesUnearned = self:GetCategoryInfo(categoryIndex)
		--Some categories are handled by specialized scenes.
		if COLLECTIONS_BOOK:IsStandardCategory(categoryIndex) then
			local normalIcon, pressedIcon, mouseoverIcon = self:GetCategoryIcons(categoryIndex)
			self:AddTopLevelCategory(categoryIndex, zo_strformat(SI_JOURNAL_PROGRESS_CATEGORY, name), numSubCategories, hidesUnearned, normalIcon, pressedIcon, mouseoverIcon)
		end
	end
	
	local searchResults = COLLECTIONS_BOOK_SINGLETON:GetSearchResults()
	if searchResults then
		for categoryIndex, data in pairs(searchResults) do
			AddCategoryByCategoryIndex(categoryIndex)
		end
	else
		for categoryIndex = 1, self:GetNumCategories() do
			AddCategoryByCategoryIndex(categoryIndex)
		end
	end
	self.categoryTree:Commit()
	
	ZO_JournalProgressBook_Common.AddTopLevelCategory(self, outfitterCategoryIndex, GetString(PMP_OUTFITTER_CATNAME), GetNumOutfitterOutfits(), false, "EsoUI/Art/MainMenu/menuBar_champion_up.dds", "EsoUI/Art/MainMenu/menuBar_champion_down.dds", "EsoUI/Art/MainMenu/menuBar_champion_over.dds")
	
	self.categoryTree:Commit()
	self:UpdateAllCategoryStatuses()
	
end

local function InitializeCategoryTreeHook()
	local original = COLLECTIONS_BOOK.categoryTree.SelectNode
	local function CollectionBookCategoryTreeSelectNode(...)
		original(...)
		InitializeVanillaStickerModifications()
	end
	COLLECTIONS_BOOK.categoryTree.SelectNode = CollectionBookCategoryTreeSelectNode
end

function COLLECTIONS_BOOK:GetCollectibleIds(categoryIndex, subCategoryIndex, index, ...)
	if categoryIndex~= outfitterCategoryIndex then
		if index >= 1 then
			local searchResults = COLLECTIONS_BOOK_SINGLETON:GetSearchResults()
				if searchResults then
				local inSearchResults = false
				local categoryResults = searchResults[categoryIndex]
				if categoryResults then
					local effectiveSubcategoryIndex = subCategoryIndex or ZO_COLLECTIONS_SEARCH_ROOT
					local subcategoryResults = categoryResults[effectiveSubcategoryIndex]
					if subcategoryResults and subcategoryResults[index] then
						inSearchResults = true
					end
				end

				if not inSearchResults then
					index = index - 1
					return self:GetCollectibleIds(categoryIndex, subCategoryIndex, index, ...)
				end
			end
			local id = GetCollectibleId(categoryIndex, subCategoryIndex, index) 
			index = index - 1
			return self:GetCollectibleIds(categoryIndex, subCategoryIndex, index, id, ...)
		end
	end
	return ...
end

function COLLECTIONS_BOOK:InitializeStickerGrid(control)
	local function SetupRow(control, data)
		local COLLECTIBLE_STICKER_ROW_STRIDE = 3
		for i = 1, COLLECTIBLE_STICKER_ROW_STRIDE do
			local stickerControl = control:GetNamedChild("Sticker" .. i)

			local id = data[i]
			local collectibleObject
			if id then
				collectibleObject = self.collectibleObjectList[id]
				if not collectibleObject then
					collectibleObject = Collectible:New(id)
					self.collectibleObjectList[id] = collectibleObject
				end
			else
				collectibleObject = self.blankCollectibleObject
			end
		collectibleObject:Show(stickerControl)
		end
	end

	ZO_ScrollList_AddDataType(self.list, STICKER_ROW_DATA, "ZO_CollectibleStickerRow", ZO_COLLECTIBLE_STICKER_ROW_HEIGHT, SetupRow)
	
end

local function SwitchToOutfit(outfitId)
	
	local collectiblesToUse = {}
	
	if outfitId then
		if db.outfits[outfitId] then
			for categoryType in pairs(categoryEnabledForOutfitter) do
				local collectibleToSet = db.outfits[outfitId].collectibleData[categoryType]
				local activeCollectible = GetActiveCollectibleByType(categoryType)
				if collectibleToSet ~= activeCollectible and collectibleToSet ~= 0 then
					table.insert(collectiblesToUse, collectibleToSet)
				elseif activeCollectible ~= 0 and collectibleToSet == 0 then
					table.insert(collectiblesToUse, activeCollectible)
				end
			end
		end
	else
		for categoryType in pairs(categoryEnabledForOutfitter) do
			local stickerControl = PimpMyRideOutfitter:GetNamedChild("Sticker" .. categoryType)
			if stickerControl.collectible then
				local collectibleToSet = stickerControl.collectible.collectibleId
				local activeCollectible = GetActiveCollectibleByType(categoryType)
				if collectibleToSet ~= activeCollectible and collectibleToSet ~= 0 then
					table.insert(collectiblesToUse, collectibleToSet)
				elseif activeCollectible ~= 0 and collectibleToSet == 0 then
					table.insert(collectiblesToUse, activeCollectible)
				end
			else
				local activeCollectible = GetActiveCollectibleByType(categoryType)
				if activeCollectible ~= 0 then
					table.insert(collectiblesToUse, activeCollectible)
				end
			end
		end
	end
	
	for index, collectibleId in ipairs(collectiblesToUse) do
		UseCollectible(collectibleId)
	end

end

function PimpMyRide_SwitchToSpecifiedOutfit(outfitId)
	SwitchToOutfit(outfitId)
end

function PimpMyRide_SwitchToOutfit()
	SwitchToOutfit()
end

function PimpMyRide_CheckOutfitterName(self)

	local text = self:GetText()
	
	if text ~= "" then
		
		local canBeSet = true
		for outfitIndex, outfitData in ipairs(db.outfits) do
			if outfitIndex ~= actualOutfitId and outfitData.name == text then
				PimpMyRideOutfitter:GetNamedChild("AssociateKeybind"):SetState(BSTATE_DISABLED, true)
				PimpMyRideOutfitter:GetNamedChild("Accept"):SetState(BSTATE_DISABLED, true)
				PimpMyRideOutfitter:GetNamedChild("Remove"):SetState(BSTATE_DISABLED, true)
				canBeSet = false
				break
			end
		end
		
		if canBeSet then
			PimpMyRideOutfitter:GetNamedChild("AssociateKeybind"):SetState(BSTATE_NORMAL, true)
			PimpMyRideOutfitter:GetNamedChild("Accept"):SetState(BSTATE_NORMAL, true)
			PimpMyRideOutfitter:GetNamedChild("Remove"):SetState(BSTATE_NORMAL, true)
		end
		 
	else
		PimpMyRideOutfitter:GetNamedChild("AssociateKeybind"):SetState(BSTATE_DISABLED, true)
		PimpMyRideOutfitter:GetNamedChild("Accept"):SetState(BSTATE_DISABLED, true)
		PimpMyRideOutfitter:GetNamedChild("Remove"):SetState(BSTATE_DISABLED, true)
	end
		
end

function PimpMyRide_ValidateOutfit(self)
	
	local outfitId = actualOutfitId
	local outfitName, associateKeybind, collectibleData = GetActualOutfit()
	
	if outfitId == 0 then
		table.insert(db.outfits, {
			name = outfitName,
			associateKeybind = associateKeybind,
			collectibleData = collectibleData,
		})
	else
		db.outfits[outfitId] = {
			name = outfitName,
			associateKeybind = associateKeybind,
			collectibleData = collectibleData,
		}
	end
	
	if associateKeybind then
		if outfitId == 0 then
			ZO_CreateStringId("SI_BINDING_NAME_PMP_SWITCHTOOUTFIT" .. #db.outfits, outfitName)
			SafeAddVersion("SI_BINDING_NAME_PMP_SWITCHTOOUTFIT" .. #db.outfits, 1)
		else
			SafeAddString(_G["SI_BINDING_NAME_PMP_SWITCHTOOUTFIT" .. outfitId], outfitName, 1)
		end
	else
		if outfitId == 0 then
			ZO_CreateStringId("SI_BINDING_NAME_PMP_SWITCHTOOUTFIT" .. 1, "")
			SafeAddVersion("SI_BINDING_NAME_PMP_SWITCHTOOUTFIT" .. 1, 1)
		else
			SafeAddString(_G["SI_BINDING_NAME_PMP_SWITCHTOOUTFIT" .. outfitId], "", 1)
		end
	end
	
	PimpMyRideOutfitter:GetNamedChild("OutfitNameBox"):SetText("")
	PimpMyRideOutfitter:GetNamedChild("AssociateKeybind"):SetState(BSTATE_NORMAL, true)
	
	COLLECTIONS_BOOK:BuildCategories()
	
	local categoryNode = COLLECTIONS_BOOK:GetLookupNodeByCategory(outfitterCategoryIndex, 1)
	if categoryNode then
		COLLECTIONS_BOOK.categoryTree:SelectNode(categoryNode)
	end

end

function PimpMyRide_RemoveOutfit(self)

	table.remove(db.outfits, actualOutfitId)
	COLLECTIONS_BOOK:BuildCategories()
	local categoryNode = COLLECTIONS_BOOK:GetLookupNodeByCategory(outfitterCategoryIndex, 1)
	if categoryNode then
		COLLECTIONS_BOOK.categoryTree:SelectNode(categoryNode)
	end
	
end

local function BuildOutfitter()
	outfitterCategoryIndex = COLLECTIONS_BOOK:GetNumCategories() + 1
	COLLECTIONS_BOOK:BuildCategories()
	PimpMyRideOutfitter:SetParent(COLLECTIONS_BOOK.control)
	
	for outfitIndex, outfitData in ipairs(db.outfits) do
		if outfitData.associateKeybind then
			ZO_CreateStringId("SI_BINDING_NAME_PMP_SWITCHTOOUTFIT" .. outfitIndex, outfitData.name)
			SafeAddVersion("SI_BINDING_NAME_PMP_SWITCHTOOUTFIT" .. outfitIndex, 1)
		end
	end	
	
end

function PimpMyRide_OutfitterScrollCategory(self, delta)
	
	if self.collectible then
		local categoryType = self.collectible.categoryType
		if categoryType == 0 then -- dirtyhack
			categoryType = self:GetName():gsub("PimpMyRideOutfitterSticker", "")
			categoryType = tonumber(categoryType)
		end
		if categoryData[categoryType] and #categoryData[categoryType].collectiblesEnabled >= 1 then
			local collectibleId = self.collectible.collectibleId
			for collectibleIndex in ipairs(categoryData[categoryType].collectiblesEnabled) do
			
				if categoryData[categoryType].collectiblesEnabled[collectibleIndex].id == collectibleId then
					local indexToSwitch = collectibleIndex - delta
					if indexToSwitch <= #categoryData[categoryType].collectiblesEnabled and indexToSwitch >= 1 then
						local collectibleObject = Collectible:New(categoryData[categoryType].collectiblesEnabled[indexToSwitch].id)
						collectibleObject:Show(self)
						self.collectible:OnMouseEnter()
					end
					break
				end
			end
			
		end
	end

end

local function BuildEnabledCollectibleType(category)

	local activeCollectible = GetActiveCollectibleByType(category)
	for collectibleId, isEnabled in pairs(db.collectibleEnabled) do
		
		if isEnabled then
			local _, _, _, _, unlocked, _, _, categoryType = GetCollectibleInfo(collectibleId)
			if categoryType == category and unlocked and collectibleId ~= activeCollectible then
				if not IsCollectibleBlocked(collectibleId) then
					table.insert(enabledCollectibles[category], collectibleId)
				end
			end
		end
		
	end
	
	if db[includeNoCollectible[category]] then
		table.insert(enabledCollectibles[category], 0)
	end

end

local function BuildEnabledCollectibles(categoryType)

	if not categoryType then
		for categoryType in pairs(enabledCollectibles) do
			BuildEnabledCollectibleType(categoryType)
		end
	else
		BuildEnabledCollectibleType(categoryType)
	end

end

local function BuildEnabledTitles()
	
	for titleIndex=1, GetNumTitles() do
		if titleIndex ~= GetCurrentTitleIndex() then
			if db.titlesEnabled[GetTitle(titleIndex)] then
				table.insert(enabledTitles, titleIndex)
			end
		end
	end
	
	if db.includeNoTitle then
		table.insert(enabledTitles, 0)
	end

end

local function RandomizeCategoryType(category)
	
	if categoryData[category] and categoryData[category].enabled and #enabledCollectibles[category] > 1 then
		
		local choice = zo_random(1, #enabledCollectibles[category])
		if enabledCollectibles[category][choice] ~= 0 then
			UseCollectible(enabledCollectibles[category][choice])
		elseif GetActiveCollectibleByType(category) ~= 0 then
			UseCollectible(GetActiveCollectibleByType(category))
		end
		
		BuildEnabledCollectibleType(category)
	
	end
	
end

local function RandomizeTitles()
	
	if #enabledTitles > 1 then
		local choice = zo_random(1, #enabledTitles)
		if enabledTitles[choice] ~= 0 then
			SelectTitle(enabledTitles[choice])
		else
			SelectTitle()
		end
		
		BuildEnabledTitles()
	end
	
end

local function UsePMPCollectible(categoryType, keybindIndex)
	for collectibleId, collectibleIndex in pairs(db.keybinds[categoryType]) do
		if collectibleIndex == keybindIndex then
			UseCollectible(collectibleId)
			break
		end
	end
end

local function OnPlayerActivated()
	
	if onlyAt1stLaunch then
		
		for categoryType in pairs(enabledCollectibles) do
			if (not IsPlayerInAvAWorld() or (IsPlayerInAvAWorld() and categoryType ~= COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)) and categoryData[categoryType] and categoryData[categoryType].enabled and db[randomizeThis[categoryType]] == 2 then
				RandomizeCategoryType(categoryType)
			end
		end
		
		if categoryData[COLLECTIBLE_CATEGORY_TYPE_TITLE].enabled and db.RandomizeTitles == 2 then
			RandomizeTitles()
		end
		
		onlyAt1stLaunch = false
		
	end
	
	for categoryType in pairs(enabledCollectibles) do
		if (not IsPlayerInAvAWorld() or (IsPlayerInAvAWorld() and categoryType ~= COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)) and categoryData[categoryType] and categoryData[categoryType].enabled and db[randomizeThis[categoryType]] == 1 then
			RandomizeCategoryType(categoryType)
		end
	end
	
	if categoryData[COLLECTIBLE_CATEGORY_TYPE_TITLE].enabled and db.RandomizeTitles == 1 then
		RandomizeTitles()
	end
	
end

local function BuildOptionsTable()

	local function sortByName(a, b)
		return GetCollectibleInfo(a) < GetCollectibleInfo(b)
	end

	local optionsTable = {}	
	
	for categoryType in pairs(enabledCollectibles) do
		
		if categoryData[categoryType] and categoryData[categoryType].enabled then
			
			local categoryTable = {
				type = "submenu", -- Destroy
				name = categoryData[categoryType].name,
				controls = {}
			}
			
			table.insert(categoryTable.controls, {
				type = "dropdown",
				name = GetString(PMP_RANDOMIZE),
				tooltip = GetString(PMP_RANDOMIZE_DESC),
				choices = {GetString(PMP_RANDOMIZE_CHOICE1), GetString(PMP_RANDOMIZE_CHOICE2), GetString(PMP_RANDOMIZE_CHOICE3)},
				default = defaults[randomizeThis[categoryType]],
				getFunc = function() return GetString("PMP_RANDOMIZE_CHOICE", db[randomizeThis[categoryType]]) end,
				setFunc = function(choice)
					if choice == GetString(PMP_RANDOMIZE_CHOICE1) then
						db[randomizeThis[categoryType]] = 1
					elseif choice == GetString(PMP_RANDOMIZE_CHOICE2) then
						db[randomizeThis[categoryType]] = 2
					elseif choice == GetString(PMP_RANDOMIZE_CHOICE3) then
						db[randomizeThis[categoryType]] = 3
					else
						-- When user click on LAM reinit button
						db[randomizeThis[categoryType]] = defaults[randomizeThis[categoryType]]
					end
					
				end,
			})
			
			if includeNoCollectible[categoryType] then
				table.insert(categoryTable.controls, {
					type = "checkbox",
					name = GetString("PMP_INCLUDE_NO", categoryType),
					default = defaults[includeNoCollectible[categoryType]],
					getFunc = function() return db[includeNoCollectible[categoryType]] end,
					setFunc = function(newValue) db[includeNoCollectible[categoryType]] = newValue
						BuildEnabledCollectibleType(categoryType)	
					end,
					disabled = function() return db[randomizeThis[categoryType]] == 3 end,
				})
			end
			
			table.sort(categoryData[categoryType].collectibles, sortByName)
			
			for j=1, categoryData[categoryType].numCollectibles do
			
				local collectibleId = categoryData[categoryType].collectibles[j]
				local name, _, _, _, unlocked = GetCollectibleInfo(collectibleId)
				
				if unlocked then
					
					table.insert(categoryTable.controls, {
						type = "checkbox",
						name = zo_strformat(GetString(PMP_INCLUDE), name),
						default = true,
						getFunc = function() return db.collectibleEnabled[collectibleId] end,
						setFunc = function(newValue) db.collectibleEnabled[collectibleId] = newValue
							BuildEnabledCollectibleType(categoryType)					
						end,
						disabled = function() return db[randomizeThis[categoryType]] == 3 end,
					})
					
				end
				
			end
			
			table.insert(optionsTable, categoryTable)
			
		end
		
	end
	
	if categoryData[COLLECTIBLE_CATEGORY_TYPE_TITLE].enabled then
	
		local categoryTable = {
			type = "submenu", -- Destroy
			name = categoryData[COLLECTIBLE_CATEGORY_TYPE_TITLE].name,
			controls = {}
		}
		
		-- TODO : optimize
		table.insert(categoryTable.controls, {
			type = "dropdown",
			name = GetString(PMP_RANDOMIZE),
			tooltip = GetString(PMP_RANDOMIZE_DESC),
			choices = {GetString(PMP_RANDOMIZE_CHOICE1), GetString(PMP_RANDOMIZE_CHOICE2), GetString(PMP_RANDOMIZE_CHOICE3)}, 
			default = defaults.RandomizeTitles,
			getFunc = function() return GetString("PMP_RANDOMIZE_CHOICE", db.RandomizeTitles) end,
			setFunc = function(choice)
				if choice == GetString(PMP_RANDOMIZE_CHOICE1) then
					db.RandomizeTitles = 1
				elseif choice == GetString(PMP_RANDOMIZE_CHOICE2) then
					db.RandomizeTitles = 2
				elseif choice == GetString(PMP_RANDOMIZE_CHOICE3) then
					db.RandomizeTitles = 3
				else
					-- When user click on LAM reinit button
					db.RandomizeTitles = defaults.RandomizeTitles
				end
				
			end,
		})
		
		table.insert(categoryTable.controls, {
			type = "checkbox",
			name = GetString("PMP_INCLUDE_NO", COLLECTIBLE_CATEGORY_TYPE_TITLE),
			default = defaults.includeNoTitle,
			getFunc = function() return db.includeNoTitle end,
			setFunc = function(newValue) db.includeNoTitle = newValue
				BuildEnabledTitles()
			end,
			disabled = function() return db.RandomizeTitles == 3 end,
		})		
		
		for j=1, categoryData[COLLECTIBLE_CATEGORY_TYPE_TITLE].numCollectibles do
		
			local titleName = GetTitle(j)
			table.insert(categoryTable.controls, {
				type = "checkbox",
				name = zo_strformat(GetString(PMP_INCLUDE), titleName),
				default = true,
				getFunc = function() return db.titlesEnabled[titleName] end,
				setFunc = function(newValue) db.titlesEnabled[titleName] = newValue
					BuildEnabledTitles()
				end,
				disabled = function() return db.RandomizeTitles == 3 end,
			})
			
		end
		
		table.insert(optionsTable, categoryTable)
		
	end
	
	LAM:RegisterOptionControls("PimpMyRideOptions", optionsTable)
	
end

local function InitializeCategoryData()
	
	categoryData = {}
	
	for categoryIndex=1, GetNumCollectibleCategories() do
	
		local name, numSubCatgories, numCollectibles, unlockedCollectibles = GetCollectibleCategoryInfo(categoryIndex)
		
		for subCategoryIndex=1, numSubCatgories do
		
			local subCategoryName, subCategoryNumCollectibles, subCategoryUnlockedCollectibles = GetCollectibleSubCategoryInfo(categoryIndex, subCategoryIndex)
			
			for collectibleIndex=1, subCategoryNumCollectibles do
			
				local collectibleId = GetCollectibleId(categoryIndex, subCategoryIndex, collectibleIndex)
				local collectibleName, _, _, _, unlocked, _, _, categoryType = GetCollectibleInfo(collectibleId)
				
				if not categoryData[categoryType] then
					categoryData[categoryType] = {}
					categoryData[categoryType].name = subCategoryName
					categoryData[categoryType].enabled = subCategoryUnlockedCollectibles > 0
					categoryData[categoryType].numCollectibles = subCategoryNumCollectibles
					categoryData[categoryType].collectibles = {}
					categoryData[categoryType].collectiblesEnabled = {}
					if includeNoCollectible[categoryType] then
						table.insert(categoryData[categoryType].collectiblesEnabled, {name = GetString(PMR_NOCOLLECTIBLE), id = 0})
					end
				end
				
				table.insert(categoryData[categoryType].collectibles, collectibleId)
				
				if categoryType == COLLECTIBLE_CATEGORY_TYPE_VANITY_PET
				or categoryType == COLLECTIBLE_CATEGORY_TYPE_COSTUME
				or categoryType == COLLECTIBLE_CATEGORY_TYPE_ASSISTANT
				or categoryType == COLLECTIBLE_CATEGORY_TYPE_TROPHY
				or categoryType == COLLECTIBLE_CATEGORY_TYPE_MOUNT
				or categoryType == COLLECTIBLE_CATEGORY_TYPE_POLYMORPH
				or categoryType == COLLECTIBLE_CATEGORY_TYPE_SKIN
				or categoryType == COLLECTIBLE_CATEGORY_TYPE_PERSONALITY
				or categoryType == COLLECTIBLE_CATEGORY_TYPE_HAT
				or categoryType == COLLECTIBLE_CATEGORY_TYPE_HAIR
				or categoryType == COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS
				or categoryType == COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY
				or categoryType == COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY
				or categoryType == COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING
				or categoryType == COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING
				then
					if unlocked then
						if not IsCollectibleBlocked(collectibleId) then
							table.insert(categoryData[categoryType].collectiblesEnabled, {name = collectibleName, id = collectibleId})
							defaults.collectibleEnabled[collectibleId] = true
							ZO_CreateStringId("SI_BINDING_NAME_PIMPMYRIDE_" .. collectibleId, zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, collectibleName))
						end
					end
				end
				
			end
		end

		for collectibleIndex=1, numCollectibles do
		
			local collectibleId = GetCollectibleId(categoryIndex, nil, collectibleIndex)
			local collectibleName, _, _, _, unlocked, _, _, categoryType = GetCollectibleInfo(collectibleId)
			
			if not categoryData[categoryType] then
				categoryData[categoryType] = {}
				categoryData[categoryType].name = name
				categoryData[categoryType].enabled = unlockedCollectibles > 0
				categoryData[categoryType].numCollectibles = numCollectibles
				categoryData[categoryType].collectibles = {}
				categoryData[categoryType].collectiblesEnabled = {}
				if includeNoCollectible[categoryType] then
					table.insert(categoryData[categoryType].collectiblesEnabled, {name = GetString(PMR_NOCOLLECTIBLE), id = 0})
				end
			end
			
			table.insert(categoryData[categoryType].collectibles, collectibleId)
			
			if categoryType == COLLECTIBLE_CATEGORY_TYPE_VANITY_PET
			or categoryType == COLLECTIBLE_CATEGORY_TYPE_COSTUME
			or categoryType == COLLECTIBLE_CATEGORY_TYPE_ASSISTANT
			or categoryType == COLLECTIBLE_CATEGORY_TYPE_TROPHY
			or categoryType == COLLECTIBLE_CATEGORY_TYPE_MOUNT
			or categoryType == COLLECTIBLE_CATEGORY_TYPE_POLYMORPH
			or categoryType == COLLECTIBLE_CATEGORY_TYPE_SKIN
			or categoryType == COLLECTIBLE_CATEGORY_TYPE_PERSONALITY
			or categoryType == COLLECTIBLE_CATEGORY_TYPE_HAT
			or categoryType == COLLECTIBLE_CATEGORY_TYPE_HAIR
			or categoryType == COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS
			or categoryType == COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY
			or categoryType == COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY
			or categoryType == COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING
			or categoryType == COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING
			then
				if unlocked then
					if not IsCollectibleBlocked(collectibleId) then
						table.insert(categoryData[categoryType].collectiblesEnabled, {name = collectibleName, id = collectibleId})
						defaults.collectibleEnabled[collectibleId] = true
						ZO_CreateStringId("SI_BINDING_NAME_PIMPMYRIDE_" .. collectibleId, zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, collectibleName))
					end
				end
			end
			
		end
		
	end
	
	local numTitles = GetNumTitles()
	categoryData[COLLECTIBLE_CATEGORY_TYPE_TITLE] = {}
	if numTitles > 0 then
		categoryData[COLLECTIBLE_CATEGORY_TYPE_TITLE].enabled = true
		categoryData[COLLECTIBLE_CATEGORY_TYPE_TITLE].name = GetString(SI_STATS_TITLE)
		categoryData[COLLECTIBLE_CATEGORY_TYPE_TITLE].numCollectibles = numTitles
		categoryData[COLLECTIBLE_CATEGORY_TYPE_TITLE].collectibles = {}
		for titleIndex=1, numTitles do
			local title = GetTitle(titleIndex)
			defaults.titlesEnabled[title] = true
			table.insert(categoryData[COLLECTIBLE_CATEGORY_TYPE_TITLE].collectibles, titleIndex)
		end
	end
	
	BuildEnabledCollectibles()
	BuildEnabledTitles()
	
	BuildOutfitter()
	BuildOptionsTable()
	
end

local function InitializeDynamicKeybinds()

	for collectibleCategoryType, collectibleCategoryData in pairs(db.keybinds) do
		for collectibleId, keybindIndex in pairs(collectibleCategoryData) do
			local collectibleName = zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, GetCollectibleInfo(collectibleId))
			ZO_CreateStringId("SI_BINDING_NAME_PMR_" .. collectibleCategoryType .."_" .. keybindIndex, collectibleName)
			SafeAddVersion("SI_BINDING_NAME_PMR_" .. collectibleCategoryType .."_" .. keybindIndex, 1)
		end
	end
	
end
		
local function OnAddonLoaded(_, addonName)

	--Protect
	if addonName == ADDON_NAME then
	
		db = ZO_SavedVars:New('PimpMyRide_OPTS', 1, nil, defaults)
		
		LAM = LibStub('LibAddonMenu-2.0')

		local panelData = {
			type = "panel",
			name = ADDON_NAME,
			displayName = ZO_HIGHLIGHT_TEXT:Colorize("Pimp my Ride!"),
			author = ADDON_AUTHOR,
			version = ADDON_VERSION,
			slashCommand = "/pmr",
			registerForRefresh = true,
			registerForDefaults = true,
			website = ADDON_WEBSITE,
		}
		
		LAM:RegisterAddonPanel("PimpMyRideOptions", panelData)
		
		--LAM and db for saved vars
		InitializeCategoryData()
		
		InitializeCategoryTreeHook()
		InitializeDynamicKeybinds()
		
		-- Unregisters
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_COLLECTIBLE_NOTIFICATION_NEW, InitializeCategoryData)
		
	end
	
end

-- Called by Bindings
function PMP_UseCollectible(categoryType, keybindIndex)
	UsePMPCollectible(categoryType, keybindIndex)
	BuildEnabledCollectibles()
	BuildEnabledTitles()
end

-- Called by Bindings
function PMP_RandomAll()
		
	for categoryType in pairs(enabledCollectibles) do
		if (not IsPlayerInAvAWorld() or (IsPlayerInAvAWorld() and categoryType ~= COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)) and categoryData[categoryType] and categoryData[categoryType].enabled and db[randomizeThis[categoryType]] ~= 3 then
			RandomizeCategoryType(categoryType)
		end
	end
	
	if categoryData[COLLECTIBLE_CATEGORY_TYPE_TITLE].enabled and db.RandomizeTitles ~= 3 then
		RandomizeTitles()
	end
		
	BuildEnabledCollectibles()
	BuildEnabledTitles()
	
end

-- Called by Bindings
function PMP_RandomChar()
	
	for categoryType in pairs(enabledCollectibles) do
		if (not IsPlayerInAvAWorld() or (IsPlayerInAvAWorld() and categoryType ~= COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)) and categoryType ~= COLLECTIBLE_CATEGORY_TYPE_MOUNT and categoryData[categoryType] and categoryData[categoryType].enabled and db[randomizeThis[categoryType]] ~= 3 then
			RandomizeCategoryType(categoryType)
		end
	end
	
	BuildEnabledCollectibles()
	
end

-- Called by Bindings
function PMP_RandomRide()
	
	if categoryData[COLLECTIBLE_CATEGORY_TYPE_MOUNT] and categoryData[COLLECTIBLE_CATEGORY_TYPE_MOUNT].enabled and db[randomizeThis[COLLECTIBLE_CATEGORY_TYPE_MOUNT]] ~= 3 then
		RandomizeCategoryType(COLLECTIBLE_CATEGORY_TYPE_MOUNT)
		BuildEnabledCollectibleType(COLLECTIBLE_CATEGORY_TYPE_MOUNT)
	end
	
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)