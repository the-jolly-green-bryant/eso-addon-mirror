--[[
Author: Jarth
Filename: Button.lua
]] --
-------------------------------------------------------------------------------------------------
-- VARIABLES --
-------------------------------------------------------------------------------------------------
local base = CollectionBars
local texts = base.Texts

-------------------------------------------------------------------------------------------------
-- FUNCTIONS --
-------------------------------------------------------------------------------------------------
CBs_Button = ZO_Object:Subclass()

function CBs_Button:New(categoryId, frame, cId)
	base:Verbose("CBs_Button:New", categoryId, frame, cId)
	local newB = ZO_Object.New(self)
	local category = base.Categories[categoryId]
	local collectible = category.Collection[cId]

	if newB then
		local ctrl = CreateControlFromVirtual(string.format(texts.FormatCategoryName, category.Id), frame, string.format(texts.FormatAbbreviationLowDash, "Button"), string.format("_B%s", cId))
		newB.cId = cId
		newB.categoryId = categoryId
		newB.ctrl = ctrl
		newB.ctrl.cId = cId
		newB.button = ctrl:GetNamedChild("Button")
		newB.button:SetId(cId)
		newB.button.tooltip = collectible.Name
		newB.enabledTexture = collectible.EnabledTexture
		newB.button.CBs = true
		newB.icon = ctrl:GetNamedChild("Icon")
		newB.cooldownIcon = ctrl:GetNamedChild("CooldownIcon")
		newB.cooldownTime = ctrl:GetNamedChild("CooldownTime")
		newB.buttonText = ctrl:GetNamedChild("ButtonText")
		newB.cooldown = ctrl:GetNamedChild("Cooldown")
		newB.cooldownCompleteAnim = ctrl:GetNamedChild("CooldownCompleteAnimation")
		newB.status = ctrl:GetNamedChild("Status")
		newB.inCooldown = false
		newB.showingCooldown = false
		newB.playSounds = false
	end

	return newB
end

function CBs_Button:UpdateAnchor(frame, left, top)
	base:Verbose("CBs_Button:UpdateAnchor", frame, left, top)

	self.ctrl:ClearAnchors()
	self.ctrl:SetAnchor(TOPLEFT, frame, TOPLEFT, left, top)
end

function CBs_Button:Setup()
	base:Verbose("CBs_Button:Setup")

	self.ctrl:SetHidden(false)
	self.icon:SetTexture(self.enabledTexture)
	self.icon:SetHidden(false)

	if self.cooldownIcon ~= nil then
		self.cooldownIcon:SetTexture(self.enabledTexture)
		self.cooldownIcon:SetDesaturation(1)
	end

	self.button:SetHandler("OnClicked", function()
		base:Activate(self)
	end)
	self.button:SetHandler("OnMouseEnter", function()
		if self.playSounds then
			PlaySound(SOUNDS.QUICKSLOT_MOUSEOVER)
		end
		local saved = base.Saved.Categories[self.categoryId]
		if saved.Tooltip.Show then
			ZO_Tooltips_ShowTextTooltip(self.button, saved.Tooltip.Position, self.button.tooltip)
		end
	end)
	self.button:SetHandler("OnMouseExit", function()
		ZO_Tooltips_HideTextTooltip()
	end)
end

function CBs_Button:SetShowBindingText(visible)
	base:Verbose("CBs_Button:SetShowBindingText", visible)

	self.buttonText:SetHidden(not visible)
end

function CBs_Button:SetSize(size)
	base:Verbose("CBs_Button:SetSize", size)

	self.ctrl:SetHeight(size)
	self.ctrl:SetWidth(size)
	self.icon:SetHeight(size - 6)
	self.icon:SetWidth(size - 6)
end

function CBs_Button:SetBindingText(show, cId)
	base:Verbose("CBs_Button:SetBindingText", show, cId)

	local keyId = base.Global.ReverseBindings[cId]

	if self.buttonText ~= nil then
		ZO_Keybindings_UnregisterLabelForBindingUpdate(self.buttonText)
		self.buttonText:ClearAnchors()
		self.buttonText:SetText("")

		if keyId ~= nil and show then
			self.buttonText:SetHeight(self.ctrl:GetHeight())
			self.buttonText:SetWidth(self.ctrl:GetWidth())
			self.buttonText:SetAnchor(BOTTOM, self.ctrl, BOTTOM, 0, 0)
			ZO_Keybindings_RegisterLabelForBindingUpdate(self.buttonText, string.format(texts.FormatAbbreviationLowDash, keyId), false)
		end
	end
end

function CBs_Button:OnClicked()
	base:Verbose("CBs_Button:OnClicked")

	if self.usable then
		UseCollectible(self.cId)
	end
end

function CBs_Button:UpdateState(forceId, isAttempting, isActiveActivationEnabled)
	base:Verbose("CBs_Button:UpdateState", forceId, isAttempting)

	local show = false

	if isActiveActivationEnabled then
		show = self.cId == forceId and isAttempting or not forceId and IsCollectibleActive(self.cId)
	end

	self.status:SetHidden(show == false)
end

function CBs_Button:UpdateUsable()
	base:Verbose("CBs_Button:UpdateUsable")

	local isShowingCooldown = self.showingCooldown
	local usable = false

	if not isShowingCooldown then
		usable = true
	end

	if usable ~= self.usable then
		self.usable = usable
	end
end

function CBs_Button:RefreshCooldown(remaining, duration, cooldown)
	base:Verbose("CBs_Button:RefreshCooldown", remaining, duration, cooldown)

	local percentComplete = (1 - remaining / duration)

	self.icon.percentComplete = percentComplete
	self.cooldownTime:SetText(cooldown)
end

function CBs_Button:UpdatePlaySounds(playSounds)
	base:Verbose("CBs_Button:UpdatePlaySounds", playSounds)

	self.playSounds = playSounds
end

function CBs_Button:UpdateCooldown(remaining, duration, cooldown)
	base:Verbose("CBs_Button:UpdateCooldown", remaining, duration, cooldown)

	local showCooldown = duration > 0

	self.cooldown:SetHidden(not showCooldown)
	self.cooldownTime:SetHidden(not showCooldown)

	if showCooldown then
		self.cooldown:StartCooldown(remaining, duration, CD_TYPE_RADIAL, nil, NO_LEADING_EDGE)

		if self.cooldownCompleteAnim.animation then
			self.cooldownCompleteAnim.animation:GetTimeline():PlayInstantlyToStart()
		end

		self.cooldown:SetHidden(false)
		self.ctrl:SetHandler("OnUpdate", function()
			self:RefreshCooldown(remaining, duration, cooldown)
		end)
	else
		if self.showingCooldown then
			if self.playSounds then
				PlaySound(SOUNDS.ABILITY_READY)
			end

			self.cooldownCompleteAnim.animation = self.cooldownCompleteAnim.animation or CreateSimpleAnimation(ANIMATION_TEXTURE, self.cooldownCompleteAnim)
			self.cooldownCompleteAnim:SetHidden(false)
			self.cooldown:SetHidden(false)

			self.cooldownCompleteAnim.animation:SetImageData(16, 1)
			self.cooldownCompleteAnim.animation:SetFramerate(30)
			self.cooldownCompleteAnim.animation:GetTimeline():PlayFromStart()
		end

		self.icon.percentComplete = 1
		self.ctrl:SetHandler("OnUpdate", nil)
		self.cooldown:ResetCooldown()
	end

	if showCooldown ~= self.showingCooldown then
		self.showingCooldown = showCooldown

		if self.showingCooldown then
			ZO_ContextualActionBar_AddReference()
		else
			ZO_ContextualActionBar_RemoveReference()
		end
	end

	local textColor = showCooldown and INTERFACE_TEXT_COLOR_FAILED or INTERFACE_TEXT_COLOR_SELECTED
	self.buttonText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, textColor))

	self:UpdateUsable()
end

function CBs_Button:SetHidden(value)
	base:Verbose("CBs_Button:SetHidden", value)

	self.ctrl:SetHidden(value)
end

function CBs_Button:IsHidden()
	base:Verbose("CBs_Button:IsHidden")

	local isHidden = self.ctrl:IsHidden()

	return isHidden
end
