
-- This file contains the necessary functions to diaplay acurate and enahaced tooltip information for the randomizers.
---------------------------------------------------------------------------------------------------------------
-- Gamepad
---------------------------------------------------------------------------------------------------------------
local function layoutCustomCollectibleData(self, tooltipType, imitationCollectibleData, actorCategory)
	if imitationCollectibleData.isCustom then
		local tooltip = self:GetTooltip(tooltipType)
		self:ClearTooltip(GAMEPAD_LEFT_TOOLTIP, true)

		local topSection = tooltip:AcquireSection(tooltip:GetStyle("collectionsTopSection"))
		topSection:AddLine(GetString("SI_COLLECTIBLECATEGORYTYPE", imitationCollectibleData:GetCategoryType()))
		tooltip:AddSection(topSection)

		tooltip:AddLine(imitationCollectibleData:GetName(), tooltip:GetStyle("title"))

		local bodySection = tooltip:AcquireSection(tooltip:GetStyle("collectionsInfoSection"))
		local dedescription = imitationCollectibleData:GetDescription(actorCategory)
		if dedescription ~= nil and dedescription ~= '' then
			bodySection:AddLine(dedescription, tooltip:GetStyle("bodyDescription"))
		end

		if imitationCollectibleData.GetActiveCollectibleText then
			local activeCollectibleText = imitationCollectibleData:GetActiveCollectibleText(actorCategory)
			if activeCollectibleText ~= nil and activeCollectibleText ~= "" then
				bodySection:AddLine(activeCollectibleText, tooltip:GetStyle("bodyDescription"))
			end
		end

		local blockReason = imitationCollectibleData:IsBlocked(actorCategory) and imitationCollectibleData:GetBlockReason(actorCategory) or nil
		if blockReason ~= nil and blockReason ~= "" then
			bodySection:AddLine(blockReason, tooltip:GetStyle("bodyDescription"), tooltip:GetStyle("failed"))
		end

		tooltip:AddSection(bodySection)
	end
end

-- Used for aompanion
local orig_LayoutImitationCollectibleFromData = GAMEPAD_TOOLTIPS['LayoutImitationCollectibleFromData']
GAMEPAD_TOOLTIPS['LayoutImitationCollectibleFromData'] = function(self, tooltipType, imitationCollectibleData, ...)
	self.currentLayoutFunctionName = 'LayoutImitationCollectibleFromData'
	orig_LayoutImitationCollectibleFromData(self, tooltipType, imitationCollectibleData, ...)
	
	layoutCustomCollectibleData(self, tooltipType, imitationCollectibleData, ...)
end

-- Used for player
local orig_LayoutCollectibleFromData = GAMEPAD_TOOLTIPS['LayoutCollectibleFromData']
GAMEPAD_TOOLTIPS['LayoutCollectibleFromData'] = function(self, tooltipType, imitationCollectibleData, ...)
	self.currentLayoutFunctionName = 'LayoutCollectibleFromData'
	orig_LayoutCollectibleFromData(self, tooltipType, imitationCollectibleData, ...)
	
	layoutCustomCollectibleData(self, tooltipType, imitationCollectibleData, GAMEPLAY_ACTOR_CATEGORY_PLAYER, ...)
end

---------------------------------------------------------------------------------------------------------------
-- Keyboard
---------------------------------------------------------------------------------------------------------------
local IJA_CollectibleRandomizerTile_Keyboard = ZO_CollectibleImitationTile_Keyboard:Subclass()

function IJA_CollectibleRandomizerTile_Keyboard:RefreshMouseoverVisuals()
	if self:IsMousedOver() then
		local description = self.imitationCollectibleData:GetDescription(self:GetActorCategory())
		if description then
			-- Tooltip
			ClearTooltip(InformationTooltip)
			local offsetX = self.control:GetParent():GetLeft() - self.control:GetLeft() - 5
			InitializeTooltip(InformationTooltip, self.control, RIGHT, offsetX, 0, LEFT)
			
			local DEFAULT_FONT = ""
			local r, g, b = ZO_NORMAL_TEXT:UnpackRGB()
			InformationTooltip:AddLine(GetString("SI_COLLECTIBLECATEGORYTYPE", self.imitationCollectibleData:GetCategoryType()), DEFAULT_FONT, r, g, b, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, true)
			
			InformationTooltip:AddLine(self.imitationCollectibleData:GetName(), "ZoFontWinH2", ZO_SELECTED_TEXT:UnpackRGBA())
			if dedescription ~= nil and dedescription ~= '' then
				InformationTooltip:AddLine(description, DEFAULT_FONT, r, g, b)
			end

			if self.imitationCollectibleData.GetActiveCollectibleText then
				local activeCollectibleText = self.imitationCollectibleData:GetActiveCollectibleText(self:GetActorCategory())
				if activeCollectibleText ~= nil and activeCollectibleText ~= "" then
					InformationTooltip:AddLine(activeCollectibleText, DEFAULT_FONT, r, g, b)
				end
			end

			if self.imitationCollectibleData:IsBlocked(self:GetActorCategory()) then
				local errorR, errorG, errorB = ZO_ERROR_COLOR:UnpackRGB()
				InformationTooltip:AddLine(self.imitationCollectibleData:GetBlockReason(self:GetActorCategory()), DEFAULT_FONT, errorR, errorG, errorB)
			end
		end
	end

	self:RefreshTitleLabelColor()
end

function IJA_CollectibleRandomizerTile_Keyboard_OnInitialized(control)
	IJA_CollectibleRandomizerTile_Keyboard:New(control)
end

