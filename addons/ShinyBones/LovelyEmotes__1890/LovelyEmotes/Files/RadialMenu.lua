LE_RadialMenu = ZO_Object:New()

local _cancelIconPath = "esoui/art/hud/gamepad/gp_radialicon_cancel_down.dds"
local _defaultCategoryIconPath = "esoui/art/quickslots/quickslot_emptySlot.dds"

local function GetCategoryIcon(categoryId)
	if categoryId < LE_Const_FavoriteCommandsCategoryId then
		return ZO_PlayerEmote_Manager:GetSharedEmoteIconForCategory(categoryId)
	end

	return _defaultCategoryIconPath
end

function LE_RadialMenu:Initialize()
	local menuControl = CreateControlFromVirtual("LE_RadialMenuControl", GuiRoot, "LE_RadialMenu_Variant_GP_Default")

	local actionLayers = { "RadialMenu", GetString(SI_LOVELYEMOTES_BINDING_LAYER_RADIAL_MENU) }
	self.Menu = ZO_RadialMenu:New(menuControl, "ZO_GamepadPlayerEmoteRadialMenuEntryTemplate", "LE_RadialMenuAnimation_Default", "DefaultRadialMenuEntryAnimation", actionLayers)
	self.InfoText = self.Menu.control:GetNamedChild("InfoText")

	self.IsActive = false
	self.TabIndex = 1
	self.HasMainWindowMinimized = false

	self.Settings = {
		AnimationOffsetY = math.floor(GuiRoot:GetHeight() * GetUICustomScale() + 0.5) / 12,
	}

	self:UpdateScale()

	self.Menu:SetCustomControlSetUpFunction(function(control, data)
		control.label:SetText(data.Name)
	end)

	self.Menu:SetOnClearCallback(function()
		RETICLE:RequestHidden(false)
		LockCameraRotation(false)
		self.HasMainWindowMinimized = false
	end)
end

function LE_RadialMenu:AddEntries()
	local savedtab = LovelyEmotes_Settings.GetSavedFavoriteTab(self.TabIndex)

	local tabName = savedtab.Name
	if tabName == "" then tabName = self.TabIndex end
	self.InfoText:SetText(tabName)

	for i = savedtab.ButtonCount, 1, -1 do
		local emote = savedtab.EmoteIDs[i]

		if emote == nil then
			emote = LovelyEmotes.SaveRandomEmote(i, self.TabIndex)
		else
			emote = LovelyEmotes.GetEmoteByID(emote)
		end

		if emote then
			local displayName = LovelyEmotes.GetEmoteDisplayName(emote)
			local categoryIconPath

			if emote.ID > -1 and emote.IsOverridden then
				categoryIconPath = ZO_PlayerEmote_Manager:GetSharedPersonalityEmoteIconForCategory(emote.CategoryID)
				displayName = ZO_PERSONALITY_EMOTES_COLOR:Colorize(displayName)
			else
				categoryIconPath = GetCategoryIcon(emote.CategoryID)

				if emote.ID < LE_Const_PersonalityOffset and IsCollectibleActive(emote.ID * -1 + LE_Const_PersonalityOffset) then
					displayName = LOVELYEMOTES_COLOR_PERSONALITY_ACTIVE:Colorize(displayName)
				end
			end

			self.Menu:AddEntry("", categoryIconPath, categoryIconPath, function() emote.Play() end, { Name = displayName, })
		end
	end

	self.Menu:AddEntry("", _cancelIconPath, _cancelIconPath, nil, { Name = GetString(SI_CANCEL), })
end

function LE_RadialMenu:RefreshEntries(playSound)
	self.Menu:ResetData()
	self:AddEntries()
	self.Menu:Refresh()

	if playSound then LovelyEmotes.PlayTabSound() end
end

function LE_RadialMenu:UpdateScale()
	local scaleValueMax = LovelyEmotes_Settings.SavedAccountVariables.RadialMenuScale
	local scaleValueMin = scaleValueMax * 0.9

	local scaleAnimation = self.Menu.animation:GetAnimation(2)
	scaleAnimation:SetScaleValues(scaleValueMin, scaleValueMax)

	local translateAnimation = self.Menu.animation:GetAnimation(3)
	local offsetY = self.Settings.AnimationOffsetY * scaleValueMax
	translateAnimation:SetTranslateOffsets(0, offsetY, 0, 0)
end

function LE_RadialMenu:Show()
	if self.IsActive or LE_Invisible:IsHidden() then return end
	self.IsActive = true

	if not LovelyEmotes.MainWindow.IsMinimized() then
		LovelyEmotes.MainWindow.SetMinimized(true, true)
		self.HasMainWindowMinimized = true
	end

	local targetIndex = LovelyEmotes_Settings.GetRadialMenuTargetTabIndex()
	if targetIndex > 0 then
		self.TabIndex = targetIndex
	else
		self.TabIndex = LovelyEmotes_Settings.GetActiveFavoriteEmotesTabIndex()
	end

	self:AddEntries()
	self.Menu:Show()

	if SCENE_MANAGER:IsInUIMode() then
		SCENE_MANAGER:SetInUIMode(false)
	end

	RETICLE:RequestHidden(true)
	LockCameraRotation(true)
end

function LE_RadialMenu:Hide()
	if not self.IsActive then return end
	self.IsActive = false

	if LovelyEmotes_Settings.GetRadialMenuTargetTabIndex() == 0 then
		LE_FavoriteEmotesMode.TryShowTab(self.TabIndex)
	end

	if self.HasMainWindowMinimized then
		LovelyEmotes.MainWindow.SetMinimized(false, true)
	end

	self.Menu:SelectCurrentEntry()
	self.Menu:Clear()
end

function LE_RadialMenu:TryShowTab(tabIndex, playSound)
	if tabIndex == self.TabIndex then
		return false
	end

	self.TabIndex = tabIndex
	self:RefreshEntries(playSound)
	return true
end

function LE_RadialMenu:ShowNextTab()
	self.TabIndex = self.TabIndex + 1

	if self.TabIndex > LovelyEmotes_Settings.GetNumberOfVisibleFavoriteEmotesTabs() then
		self.TabIndex = 1
	end

	self:RefreshEntries(true)
end

function LE_RadialMenu:ShowPreviousTab()
	self.TabIndex = self.TabIndex - 1

	if self.TabIndex < 1 then
		self.TabIndex = LovelyEmotes_Settings.GetNumberOfVisibleFavoriteEmotesTabs()
	end

	self:RefreshEntries(true)
end
