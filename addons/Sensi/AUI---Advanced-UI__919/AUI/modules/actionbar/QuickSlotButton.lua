AUI_QuickSlotButton = ActionButton:Subclass()

local ACTION_BUTTON_BORDERS = {normal = "EsoUI/Art/ActionBar/abilityFrame64_up.dds", mouseDown = "EsoUI/Art/ActionBar/abilityFrame64_down.dds"}
local slotCount = 1
local isDragActive = false

function AUI_QuickSlotButton:New(slotNum, buttonType, parent, controlTemplate, hotbarCategory)
    local newB = ZO_Object.New(self)

    if newB then
        newB.buttonType             = buttonType
        newB.hasAction              = false
        newB.slot                   = CreateControlFromVirtual("AUI_QuickSlotButton" .. slotNum, parent, controlTemplate)
        newB.slot.slotNum           = slotNum
        newB.button                 = GetControl(newB.slot, "Button")
        newB.button.slotNum         = slotNum
        newB.button.slotType        = ACTION_TYPE_ITEM
        newB.button.tooltip         = ItemTooltip
		newB.slot.hotbarCategory 	= HOTBAR_CATEGORY_QUICKSLOT_WHEEL
		newB.button.hotbarCategory 	= HOTBAR_CATEGORY_QUICKSLOT_WHEEL

        newB.flipCard               = GetControl(newB.slot, "FlipCard")
        newB.bg                     = GetControl(newB.slot, "BG")
        newB.icon                   = GetControl(newB.slot, "Icon")
        newB.glow                   = GetControl(newB.slot, "Glow")
        newB.buttonText             = GetControl(newB.slot, "ButtonText")
        newB.countText              = GetControl(newB.slot, "CountText")
        newB.cooldown               = GetControl(newB.slot, "Cooldown")
        newB.cooldownCompleteAnim   = GetControl(newB.slot, "CooldownCompleteAnimation")
        newB.cooldownIcon           = GetControl(newB.slot, "CooldownIcon")
        newB.cooldownEdge           = GetControl(newB.slot, "CooldownEdge")
        newB.status                 = GetControl(newB.slot, "Status")
        newB.inCooldown             = false
        newB.showingCooldown        = false
        newB.activationHighlight    = GetControl(newB.slot,"ActivationHighlight")

        newB.cooldownIcon:SetDesaturation(1)

        local HIDE_UNBOUND = false
        ZO_Keybindings_RegisterLabelForBindingUpdate(newB.buttonText, "AUI_QUICKSLOT_".. slotCount, HIDE_UNBOUND, "AUI_QUICKSLOT_".. slotCount, nil)
			
		newB.button:SetHandler("OnMouseUp", function(_, _button, _, _, _) newB:OnClicked(_button) end)
		newB.button:SetHandler("OnMouseDown", function(_, _button, _, _, _) ClearTooltip(newB.button.tooltip) end)
		newB.button:SetHandler("OnMouseEnter", function(self) newB:OnMouseEnter(self) end)
		newB.button:SetHandler("OnMouseExit", function(self) newB:OnMouseExit(self) end)
		newB.button:SetHandler("OnDragStart", function(self, button) newB:OnDragStart(self, button) end)			
		newB.button:SetHandler("OnReceiveDrag", function(self, button) newB:OnReceiveDrag(self, button) end)
		
		newB.button.object = newB
		newB.object = newB
		newB.slot.object = newB
		slotCount = slotCount + 1
    end

    return newB
end

function AUI_QuickSlotButton:OnDragStart(_self, _button)
	isDragActive = true
	CallSecureProtected("PickupAction", self.slot.slotNum, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
end

function AUI_QuickSlotButton:OnReceiveDrag(_self, _button)
	CallSecureProtected("PlaceInActionBar", self.slot.slotNum, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
end

function AUI_QuickSlotButton:OnMouseEnter(_button)
   local slotType = GetSlotType(self.slot.slotNum)

    if self.button.actionId > 0 and slotType ~= ACTION_TYPE_NOTHING then
		InitializeTooltip(self.button.tooltip, self.slot, BOTTOM, 0, -5, TOP)
        self.button.tooltip:SetAction(self.slot.slotNum, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
		self.activeTooltip = self.button.tooltip
    elseif self.activeTooltip then
        ClearTooltip(self.button.tooltip)
    end
end

function AUI_QuickSlotButton:OnMouseExit(_button)
	if(self.activeTooltip) then
		ClearTooltip(self.button.tooltip)
		self.activeTooltip = nil
	end
end

function AUI_QuickSlotButton:OnClicked(_button)
	if _button == 1 and not isDragActive then
		AUI.Actionbar.QuickButtons.SelectQuickSlotButton(self.slot.slotNum)
		SetCurrentQuickslot(self.slot.slotNum)
		AUI.Actionbar.QuickButtons.SelectCurrentQuickSlot()
	end
	
	isDragActive = false
end

function AUI_QuickSlotButton:Select()
	self.status:SetHidden(false)
end

function AUI_QuickSlotButton:Unselect()
	self.status:SetHidden(true)
end

function AUI_QuickSlotButton:HandleSlotChanged(hotbarCategory)
	local slotId = self:GetSlot()
	local slotType = GetSlotType(slotId, hotbarCategory)

	local setupSlotHandler = SetupSlotHandlers[slotType]
	if internalassert(setupSlotHandler, "update slot handlers") then
		setupSlotHandler(self, slotId)
	end

	self.barType = HOTBAR_CATEGORY_QUICKSLOT_WHEEL
	self:SetShowCooldown(false)
	self:UpdateState()
	self.barType = HOTBAR_CATEGORY_QUICKSLOT_WHEEL
    if self.icon then
        local slotIcon = GetSlotTexture(slotId, self.barType)
        self.icon:SetTexture(slotIcon)
    end	
	
	AUI.Actionbar.QuickButtons.SelectCurrentQuickSlot()
end