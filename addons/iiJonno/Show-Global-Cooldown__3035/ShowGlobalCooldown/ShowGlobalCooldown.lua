local LAM2 = LibAddonMenu2

ShowGlobalCooldown = {
	name = "ShowGlobalCooldown",
	title = "Show Global Cooldown",
	author = "Valve",
	version = "2.0.1",

	defaults =
	{
		enabled = true,
		animationEnabled = false,
		potionCooldown = false,
		desaturatedIcons = false,
		cooldownType = CD_TYPE_VERTICAL_REVEAL,
	},
}

local NO_LEADING_EDGE = false

local cooldownOptions =
{
	strings = {
		[3] = GetString(SI_SGC_ASCENDING_DROP_OPT),
		[1] = GetString(SI_SGC_DESCENDING_DROP_OPT),
		[2] = GetString(SI_SGC_RADIAL_DROP_OPT),
	},

	values = {
		[GetString(SI_SGC_ASCENDING_DROP_OPT)	] = CD_TYPE_VERTICAL_REVEAL,
		[GetString(SI_SGC_DESCENDING_DROP_OPT)	] = CD_TYPE_VERTICAL,
		[GetString(SI_SGC_RADIAL_DROP_OPT)		] = CD_TYPE_RADIAL,
	},
}

function ShowGlobalCooldown:Initialise()

	ShowGlobalCooldown.settings = ZO_SavedVars:NewAccountWide("ShowGlobalCooldown_dat", 1, nil, ShowGlobalCooldown.defaults)

	ShowGlobalCooldown.ActionButtonUsable()
	ShowGlobalCooldown.ActionButtonCooldown()

	ShowGlobalCooldown.Menu()
end

function ShowGlobalCooldown.ActionButtonUsable()
	ActionButton.UpdateUsable = function(self)
		local isGamepad = IsInGamepadPreferredMode()
		local slotnum = self:GetSlot()
		local consumable = IsSlotItemConsumable(slotnum)
		local _, duration, _, _ = GetSlotCooldownInfo(slotnum)
		local isShowingCooldown = self.showingCooldown
		local isKeyboardUltimateSlot = not isGamepad and self.slot.slotNum == ACTION_BAR_ULTIMATE_SLOT_INDEX + 1
		local usable = false
		if not self.useFailure and not isShowingCooldown then
			usable = true
		elseif isKeyboardUltimateSlot and self.costFailureOnly and not isShowingCooldown then
			usable = true
		elseif consumable and duration <= 1000 and not self.useFailure then
			usable = true
		end
		if usable ~= self.usable or isGamepad ~= self.isGamepad then
			self.usable = usable
			self.isGamepad = isGamepad
		end
		local useDesaturation = (isShowingCooldown --[[or self.costFailureOnly]]) and ShowGlobalCooldown.settings.desaturatedIcons
		ZO_ActionSlot_SetUnusable(self.icon, not usable, useDesaturation)
	end
end

function ShowGlobalCooldown.ActionButtonCooldown()
	ActionButton.UpdateCooldown = function(self, options)
		local slotnum = self:GetSlot()
		local consumable = IsSlotItemConsumable(slotnum)
		local remain, duration, global, globalSlotType = GetSlotCooldownInfo(slotnum)
		local isInCooldown = duration > 0
		local slotType = GetSlotType(slotnum)
		local showGlobalCooldownForCollectible = global and slotType == ACTION_TYPE_COLLECTIBLE and globalSlotType == ACTION_TYPE_COLLECTIBLE-- and ShowGlobalCooldown.settings.potionCooldown
		local showCooldown = isInCooldown and (ShowGlobalCooldown.settings.enabled or not global or showGlobalCooldownForCollectible)
		self.cooldown:SetHidden(not showCooldown)
		local updateChromaQuickslot = slotType ~= ACTION_TYPE_ABILITY and ZO_RZCHROMA_EFFECTS
		if showCooldown then
			if not consumable or duration > 1000 or ShowGlobalCooldown.settings.potionCooldown then
				self.cooldown:StartCooldown(remain, duration, ShowGlobalCooldown.settings.cooldownType--[[CD_TYPE_RADIAL]], nil, NO_LEADING_EDGE)
				if(self.cooldownCompleteAnim.animation) then
					self.cooldownCompleteAnim.animation:GetTimeline():PlayInstantlyToStart()
				end
				if IsInGamepadPreferredMode() then
					if not self.itemQtyFailure then
						self.icon:SetDesaturation(0)
					end
					self.cooldown:SetHidden(true)
					if not self.showingCooldown then
						self:SetNeedsAnimationParameterUpdate(true)
						self:PlayAbilityUsedBounce()
					end
				else
					self.cooldown:SetHidden(false)
				end
				self.slot:SetHandler("OnUpdate", function() self:RefreshCooldown() end)
				if updateChromaQuickslot then
					ZO_RZCHROMA_EFFECTS:RemoveKeybindActionEffect("UI_SHORTCUT_QUICK_SLOTS")
				end
			else
				self.cooldown:SetHidden(true)
			end
		else
			if ShowGlobalCooldown.settings.animationEnabled then
				--if not consumable or ShowGlobalCooldown.settings.potionCooldown then
				if self.showingCooldown then
					-- This ability was in a non-global cooldown, and now the cooldown is over...play animation and sound
					--if options ~= FORCE_SUPPRESS_COOLDOWN_SOUND then
					--	PlaySound(SOUNDS.ABILITY_READY)
					--end

					self.cooldownCompleteAnim.animation = self.cooldownCompleteAnim.animation or CreateSimpleAnimation(ANIMATION_TEXTURE, self.cooldownCompleteAnim)
					local anim = self.cooldownCompleteAnim.animation
					self.cooldownCompleteAnim:SetHidden(false)
					self.cooldown:SetHidden(false)
					anim:SetImageData(16,1)
					anim:SetFramerate(30)
					anim:GetTimeline():PlayFromStart()
					if updateChromaQuickslot then
						ZO_RZCHROMA_EFFECTS:AddKeybindActionEffect("UI_SHORTCUT_QUICK_SLOTS")
					end
				end
				--end
			end
			self.icon.percentComplete = 1
			self.slot:SetHandler("OnUpdate", nil)
			self.cooldown:ResetCooldown()
		end
		if showCooldown ~= self.showingCooldown then
			self.showingCooldown = showCooldown
			if self.showingCooldown then
				ZO_ContextualActionBar_AddReference()
			else
				ZO_ContextualActionBar_RemoveReference()
			end

			self:UpdateActivationHighlight()
			if IsInGamepadPreferredMode() then
				self:SetCooldownHeight(self.icon.percentComplete)
			end
			self:SetShowCooldown(showCooldown)
		end
		local textColor = showCooldown and INTERFACE_TEXT_COLOR_FAILED or INTERFACE_TEXT_COLOR_SELECTED
		self.buttonText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, textColor))
		self.isGlobalCooldown = global
		self:UpdateUsable()
	end
end

function ShowGlobalCooldown.OnAddonLoaded(event, name)
	if name ~= ShowGlobalCooldown.name then return end
	EVENT_MANAGER:UnregisterForEvent(ShowGlobalCooldown.name, EVENT_ADD_ON_LOADED)

	ShowGlobalCooldown:Initialise()
end

EVENT_MANAGER:RegisterForEvent(ShowGlobalCooldown.name, EVENT_ADD_ON_LOADED, ShowGlobalCooldown.OnAddonLoaded)

function ShowGlobalCooldown.Menu()
	local panelData =
	{
		type = "panel",
		name = ShowGlobalCooldown.title,
		displayName = ShowGlobalCooldown.title,
		author = ShowGlobalCooldown.author,
		version = ShowGlobalCooldown.version,
	}

	LAM2:RegisterAddonPanel(ShowGlobalCooldown.name .. "Menu", panelData)

	local optionsTable = {
		{
			type = "header",
			name = GetString(SI_SGC_CORE_HEADER),
		},
		{
			type = "description",
			text = GetString(SI_SGC_DESC),
		},
		{
			type = "checkbox",
			name = GetString(SI_SGC_ENABLE_OPT),
			tooltip = GetString(SI_SGC_ENABLE_OPT_TOOLTIP),
			getFunc = function() return ShowGlobalCooldown.settings.enabled end,
			setFunc = function(value) ShowGlobalCooldown.settings.enabled = value end,
			requiresReload = false,
			default = ShowGlobalCooldown.defaults.enabled,
		},
		{
			type = "checkbox",
			name = GetString(SI_SGC_ANIMATION_OPT),
			tooltip = GetString(SI_SGC_ANIMATION_OPT_TOOLTIP),
			getFunc = function() return ShowGlobalCooldown.settings.animationEnabled end,
			setFunc = function(value) ShowGlobalCooldown.settings.animationEnabled = value end,
			requiresReload = false,
			default = ShowGlobalCooldown.defaults.animationEnabled,
		},
		{
			type = "checkbox",
			name = GetString(SI_SGC_POT_ANIMATION_OPT),
			tooltip = GetString(SI_SGC_POT_ANIMATION_OPT_TOOLTIP),
			getFunc = function() return ShowGlobalCooldown.settings.potionCooldown end,
			setFunc = function(value) ShowGlobalCooldown.settings.potionCooldown = value end,
			requiresReload = false,
			default = ShowGlobalCooldown.defaults.potionCooldown,
		},
		{
			type = "dropdown",
			name = GetString(SI_SGC_COOLDOWN_OPT),
			tooltip = GetString(SI_SGC_COOLDOWN_OPT_TOOLTIP),
			choices = cooldownOptions.strings,
			getFunc = function() return cooldownOptions.strings[ShowGlobalCooldown.settings.cooldownType] end,
			setFunc = function(value) ShowGlobalCooldown.settings.cooldownType = cooldownOptions.values[value] end,
			requiresReload = false,
			default = cooldownOptions.strings[2],
		},
		{
			type = "checkbox",
			name = GetString(SI_SGC_DESATURATE_OPT),
			tooltip = GetString(SI_SGC_DESATURATE_OPT_TOOLTIP),
			getFunc = function() return ShowGlobalCooldown.settings.desaturatedIcons end,
			setFunc = function(value) ShowGlobalCooldown.settings.desaturatedIcons = value;  end,
			requiresReload = false,
			default = ShowGlobalCooldown.defaults.desaturatedIcons,
		},
	}

	LAM2:RegisterOptionControls(ShowGlobalCooldown.name .. "Menu", optionsTable)
end
