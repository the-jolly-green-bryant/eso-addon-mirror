local SK = SwissKnife
local SKDA = SK.Data.abilities
local WM, AM = WINDOW_MANAGER, ANIMATION_MANAGER

local function setMenuBarData(self, data)
    if self.m_object.m_pool ~= nil then return end
    if data.orientation == "vertical" then
        self.m_object.m_point = TOPLEFT
        self.m_object.m_relativePoint = BOTTOMLEFT
    else
        self.m_object.m_point = LEFT
        self.m_object.m_relativePoint = RIGHT
    end
    self.m_object.m_pool = ZO_ControlPool:New(data.buttonTemplate or "ZO_MenuBarButtonTemplate1", self.m_object.m_control, "Button")
    self.m_object.m_pool:SetCustomResetBehavior(function(control) control.m_object:Reset() end)
    self.m_object.m_barPool = ZO_ControlPool:New(data.barTemplate or "ZO_MenuBarPaddingBarTemplate", self.m_object.m_control, "PaddingBar")
    self.m_object.m_buttonPadding = data.buttonPadding or 0
    self.m_object.m_normalSize = data.normalSize or 32
    self.m_object.m_downSize = data.downSize or 50
    self.m_object.m_animationDuration = data.animationDuration or 180
end

local function onRowMouseToggle(listControl, rowControl, buttonNames, visible)
    if visible then
        listControl:Row_OnMouseEnter(rowControl)
    else
        listControl:Row_OnMouseExit(rowControl)
    end
    for _, name in ipairs(buttonNames) do
        local button = rowControl:GetNamedChild(name)
        button:SetHidden(not visible)
    end
end

local function onItemNameMouseUp(control, button)
    if button == MOUSE_BUTTON_INDEX_RIGHT then
        local itemLink = control.itemLink
        local function AddLink()
            ZO_LinkHandler_InsertLink(zo_strformat(SI_TOOLTIP_ITEM_NAME, itemLink))
        end
        ClearMenu()
        if not control.setName then
            AddMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), AddLink)
        end
        SK_HandleLinkClickEvent(itemLink, button, itemNameControl, nil, ITEM_LINK_TYPE)
    end
end

-- ----------------------------------------------------
-- SK_CombatIndicators
-- ----------------------------------------------------
SK_CombatIndicators = ZO_Object:Subclass()
function SK_CombatIndicators:New()
    local object = ZO_Object.New(self)
    return object
end

function SK_CombatIndicators:Initialize()
    self.currentTargetHP = 100
    self.currentTargetMaxHP = 100
    self.hasExecutionSkill = false
    self.executionSkillHP = 0
    self.reticleControl = WM:GetControlByName("ZO_ReticleContainerReticle")
    self.executionControl = WM:CreateControlFromVirtual("SK_ExecutionIndicator", self.reticleControl, "SK_Info_Slot")
    self.executionControlText = self.executionControl:GetNamedChild("Text")
    self.executionControlIcon = self.executionControl:GetNamedChild("Icon")
    self.executionControlIcon:SetTexture("/SwissKnife/textures/abilities/execution.dds")
    self.executionControl:ClearAnchors()
    self.executionControlText:SetColor(unpack(SK.savedVars.executionIndicatorColor))
    self.executionControl:SetAnchor(TOPLEFT, self.reticleControl, BOTTOMLEFT,
        SK.savedVars.executionIndicatorOffsetX, SK.savedVars.executionIndicatorOffsetY
    )
    self:effectPrepare()
    self:updateIndicatorsVisibility(false)
end

function SK_CombatIndicators:updateExecutionAbilityExists()
	local hotbarData
    for hotbarIndex = 0,1 do
		hotbarData = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(hotbarIndex)
		if hotbarData then
			for actionSlotIndex= SKILL_BAR_FIRST_SLOT_INDEX, SKILL_BAR_LAST_SLOT_INDEX do
		        if hotbarData:GetSlotData(actionSlotIndex) then
                    local id = GetSlotBoundId(actionSlotIndex, hotbarIndex)
                    if id ~= nil and id ~= 0 then
                        local abData = SK.globalSV.automationBlockAbilities[id]
                        if abData ~= nil and abData.mode == SKDA.CAST_MODES.PHASE and abData.hp ~= nil then
                            self.hasExecutionSkill = true
                            self.executionSkillHP = abData.hp
                            return
                        end
                    end
                end
			end
		end
	end
end

function SK_CombatIndicators:updateIndicatorsVisibility(inCombat)
    self.hasExecutionSkill = false
    self.executionSkillHP = 0
    self.executionControlText:SetText("")
    self.executionControlIcon:SetHidden(true)
    if inCombat then
        self:updateExecutionAbilityExists()
    elseif self.executionControl.loop ~= nil then
        self.executionControl.loopTimeline:Stop()
        self.executionControl.loop:SetHidden(true)
    end
    if self.hasExecutionSkill then
        self:updateExecutionIndicator()
        self.executionControl:SetHidden(not inCombat)
    end
end

function SK_CombatIndicators:cleanupIndicators()
    self.currentTargetHP = 100
    self.currentTargetMaxHP = 0
    self.executionControlText:SetText("")
    self.executionControlIcon:SetHidden(true)
    self.executionControl.loopTimeline:Stop()
    self.executionControl.loop:SetHidden(true)
end

function SK_CombatIndicators:effectPrepare()
	self.executionControl.loop = WM:CreateControl("$(parent)Anim", self.executionControl, CT_TEXTURE)
	self.executionControl.loop:SetAnchor(TOPLEFT, self.executionControl, TOPLEFT, 5, 5)
	self.executionControl.loop:SetAnchor(BOTTOMRIGHT, self.executionControl, BOTTOMRIGHT, -5, -5)
	self.executionControl.loop:SetTexture("EsoUI/Art/ActionBar/abilityHighlightAnimation.dds")
	self.executionControl.loop:SetDrawTier(DT_HIGH)
	self.executionControl.loopTimeline = AM:CreateTimelineFromVirtual("SK_Loop", self.executionControl.loop)
end

function SK_CombatIndicators:updateExecutionIndicator()
    if self.hasExecutionSkill and (SK.savedVars.minTargetHealthForExecutionWatch == 0 or
        self.currentTargetMaxHP >= SK.savedVars.minTargetHealthForExecutionWatch)
    then
        if self.currentTargetHP >= self.executionSkillHP then
            if not self.executionControlIcon:IsHidden() then self.executionControlIcon:SetHidden(true) end
            if self.currentTargetHP < 100 then
                self.executionControlText:SetText(string.format("%.1f", self.currentTargetHP).."%")
            end
            if not self.executionControl.loop:IsHidden() then
                self.executionControl.loop:SetHidden(true)
                self.executionControl.loopTimeline:Stop()
            end
        elseif self.executionControlIcon:IsHidden() then
            if not SK.savedVars.disableExecutionIndicatorSound then PlaySound(SOUNDS.ABILITY_COMPANION_ULTIMATE_READY) end
            self.executionControlText:SetText("")
            self.executionControlIcon:SetHidden(false)
            if self.executionControl.loop:IsHidden() then
                self.executionControl.loopTimeline:PlayFromStart()
                self.executionControl.loop:SetHidden(false)
            end
        elseif self.currentTargetHP == 0 and not self.executionControl.loop:IsHidden() then
            self.executionControlText:SetText("")
            self.executionControlIcon:SetHidden(true)
            self.executionControl.loopTimeline:Stop()
            self.executionControl.loop:SetHidden(true)
        end
    end
end

SK_ProtectedIndicator = ZO_Object:Subclass()
function SK_ProtectedIndicator:New()
    local object = ZO_Object.New(self)
    return object
end

function SK_ProtectedIndicator:Initialize()
    self.controlRoot = WM:GetControlByName("ZO_ActionBar1")
    self.guiRoot = WM:GetControlByName("GuiRoot")
    self.iconControl = WM:CreateControl("SK_ProtectedIndicator", self.controlRoot, CT_TEXTURE)
    self.iconControl:SetDrawTier(DT_HIGH)
    self.iconControl:ClearAnchors()
    self.iconControl:SetAnchor(SK.savedVars.dangerInteractionIndicator.point, self.guiRoot,
        SK.savedVars.dangerInteractionIndicator.relativePoint, SK.savedVars.dangerInteractionIndicator.offsetX,
        SK.savedVars.dangerInteractionIndicator.offsetY
    )
    self.iconControl:SetDimensions(32, 32)
    self.iconControl:SetHandler("OnMouseUp", function()
        local _
        _, SK.savedVars.dangerInteractionIndicator.point, _, SK.savedVars.dangerInteractionIndicator.relativePoint,
        SK.savedVars.dangerInteractionIndicator.offsetX, SK.savedVars.dangerInteractionIndicator.offsetY = self.iconControl:GetAnchor(0)
    end)
    self.iconControl:SetTexture("SwissKnife/textures/gui/protect.dds")
    self.iconControl:SetMouseEnabled(true)
    self.iconControl:SetMovable(true)
end

function SK_ProtectedIndicator:SetColor()
    local r, g, b = SK.COLOR.GREEN:UnpackRGB()
    if not SK.savedVars.hideDangerInteraction then
        r, g, b = SK.COLOR.SWISS_RED:UnpackRGB()
    end
    self.iconControl:SetColor(r, g, b, 1)
end

function SK_ProtectedIndicator:SetHidden()
    self.iconControl:SetHidden(not SK.savedVars.enableDangerInteractionIndicator)
end

-- Export
SK.HelperFunctions.setMenuBarData = setMenuBarData
SK.HelperFunctions.onRowMouseToggle = onRowMouseToggle
SK.HelperFunctions.onItemNameMouseUp = onItemNameMouseUp
