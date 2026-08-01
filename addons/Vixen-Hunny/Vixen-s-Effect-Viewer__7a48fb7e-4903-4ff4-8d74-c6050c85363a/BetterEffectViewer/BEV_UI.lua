local BEV = BetterEffectViewer

function BEV:ApplyFontSettings()
    local size = self.sv.fontSize or self.defaults.fontSize
    local fontString = string.format("$(BOLD_FONT)|%d|soft-shadow-thick", size)

    if self.buffSlots then
        for _, slot in ipairs(self.buffSlots) do
            slot.timer:SetFont(fontString)
            slot.count:SetFont(fontString)
        end
    end

    if self.debuffSlots then
        for _, slot in ipairs(self.debuffSlots) do
            slot.timer:SetFont(fontString)
            slot.count:SetFont(fontString)
        end
    end
end

function BEV:UpdateSlotLayout()
    if not self.buffSlots or not self.debuffSlots or not self.win then
        return
    end

    local spacing = 2
    local iconSize = self.iconSize or self.sv.iconSize or self.defaults.iconSize
    local cols = self.maxCols or self.defaults.pveLayout.maxCols

    local buffCount = 0
    local debuffCount = 0
    for _, effect in pairs(self.effects) do
        if effect.effectType == BUFF_EFFECT_TYPE_BUFF then
            buffCount = buffCount + 1
        elseif effect.effectType == BUFF_EFFECT_TYPE_DEBUFF then
            debuffCount = debuffCount + 1
        end
    end

    local buffRows = self:GetRequiredRows(buffCount)
    local debuffRows = self:GetRequiredRows(debuffCount)
    local layoutKey = string.format("%d:%d:%d:%d", iconSize, cols, buffRows, debuffRows)

    if self.lastLayoutKey == layoutKey then
        return
    end
    self.lastLayoutKey = layoutKey

    local contentWidth = cols * iconSize + math.max(cols - 1, 0) * spacing
    local buffHeight = buffRows * iconSize + math.max(buffRows - 1, 0) * spacing
    local debuffHeight = debuffRows * iconSize + math.max(debuffRows - 1, 0) * spacing

    local windowWidth = contentWidth + 8
    local windowHeight = 4 + buffHeight + 4 + debuffHeight + 4

    self.buffContainer:SetDimensions(contentWidth, buffHeight)
    self.debuffContainer:SetDimensions(contentWidth, debuffHeight)

    self.buffContainer:ClearAnchors()
    self.buffContainer:SetAnchor(TOPLEFT, self.win, TOPLEFT, 4, 4)

    self.debuffContainer:ClearAnchors()
    self.debuffContainer:SetAnchor(TOPLEFT, self.buffContainer, BOTTOMLEFT, 0, 4)

    self.win:SetDimensions(windowWidth, windowHeight)

    for i, slot in ipairs(self.buffSlots) do
        local idx = i - 1
        local row = math.floor(idx / cols)
        local col = idx % cols

        slot:ClearAnchors()
        slot:SetAnchor(TOPLEFT, self.buffContainer, TOPLEFT, col * (iconSize + spacing), row * (iconSize + spacing))
        slot:SetDimensions(iconSize, iconSize)
    end

    for i, slot in ipairs(self.debuffSlots) do
        local idx = i - 1
        local row = math.floor(idx / cols)
        local col = idx % cols

        slot:ClearAnchors()
        slot:SetAnchor(TOPLEFT, self.debuffContainer, TOPLEFT, col * (iconSize + spacing), row * (iconSize + spacing))
        slot:SetDimensions(iconSize, iconSize)
    end

    self:ApplyFontSettings()
end

function BEV:CreateUI()
    self.win = BetterEffectViewer_Window
    self.buffContainer = BetterEffectViewer_WindowBuffContainer
    self.debuffContainer = BetterEffectViewer_WindowDebuffContainer
    self.fadeOut = ANIMATION_MANAGER:CreateTimeline()

    local fade = self.fadeOut:InsertAnimation(ANIMATION_ALPHA, self.win)
    fade:SetDuration(1000)
    fade:SetAlphaValues(1, 0)

    self.fadeOut:SetHandler("OnStop", function()
        if self.win:GetAlpha() == 0 then
            self.win:SetHidden(true)
        end
    end)

    self.win:ClearAnchors()
    self.win:SetAnchor(CENTER, GuiRoot, CENTER, self.sv.offsetX, self.sv.offsetY)

    self.win:SetMovable(not self.sv.lockWindow)
    self.win:SetMouseEnabled(not self.sv.lockWindow)

    self.win:SetHandler("OnMoveStop", function(control)
        local centerX = control:GetLeft() + control:GetWidth() / 2
        local centerY = control:GetTop() + control:GetHeight() / 2
        local rootCenterX = GuiRoot:GetWidth() / 2
        local rootCenterY = GuiRoot:GetHeight() / 2

        self.sv.offsetX = centerX - rootCenterX
        self.sv.offsetY = centerY - rootCenterY
    end)

    self.iconSize = self.sv.iconSize or self.defaults.iconSize

    self.buffSlots = {}
    self.debuffSlots = {}
    local totalSlots = self:GetSlotPoolSize()

    self.targetNameLabel = self.win:GetNamedChild("TargetName")
    self.targetPlate = self.win:GetNamedChild("TargetPlate")
    self:ApplyTargetFrameStyle(nil)

    for i = 1, totalSlots do
        local ctrl = CreateControlFromVirtual("BetterEffectViewer_BuffSlot" .. i, self.buffContainer, "BetterEffectViewer_SlotTemplate")
        ctrl:SetHidden(true)
        ctrl.icon = ctrl:GetNamedChild("Icon")
        ctrl.timer = ctrl:GetNamedChild("Timer")
        ctrl.count = ctrl:GetNamedChild("Count")
        ctrl.border = ctrl:GetNamedChild("Border")
        ctrl.effect = nil
        self.buffSlots[i] = ctrl
    end

    for i = 1, totalSlots do
        local ctrl = CreateControlFromVirtual("BetterEffectViewer_DebuffSlot" .. i, self.debuffContainer, "BetterEffectViewer_SlotTemplate")
        ctrl:SetHidden(true)
        ctrl.icon = ctrl:GetNamedChild("Icon")
        ctrl.timer = ctrl:GetNamedChild("Timer")
        ctrl.count = ctrl:GetNamedChild("Count")
        ctrl.border = ctrl:GetNamedChild("Border")
        ctrl.effect = nil
        self.debuffSlots[i] = ctrl
    end

    self:UpdateSlotLayout()
end

function BEV:ApplyTargetFrameStyle(unitTag)
    if not self.targetPlate then
        return
    end

    local edgeR, edgeG, edgeB, edgeA = 0.35, 0.35, 0.35, 0.85

    if unitTag then
        if IsUnitAttackable(unitTag) then
            edgeR, edgeG, edgeB, edgeA = 0.75, 0.18, 0.18, 0.95
        elseif IsUnitFriend("player", unitTag) then
            edgeR, edgeG, edgeB, edgeA = 0.2, 0.65, 0.28, 0.95
        else
            edgeR, edgeG, edgeB, edgeA = 0.7, 0.55, 0.2, 0.95
        end
    end

    self.targetPlate:SetCenterColor(0, 0, 0, 0.72)
    self.targetPlate:SetEdgeColor(edgeR, edgeG, edgeB, edgeA)
    self.targetPlate:SetHidden(not unitTag)
end

function BEV:UpdateTargetName(unitTag)
    unitTag = unitTag or self:ResolveReticleUnitTag()

    if not unitTag then
        self:ApplyTargetFrameStyle(nil)
        self.targetNameLabel:SetHidden(true)
        return
    end

    local rawName = (GetUnitName ~= nil and GetUnitName(unitTag)) or unitTag
    local name = (zo_strformat ~= nil and zo_strformat("<<C:1>>", rawName)) or rawName
    local r, g, b = 1, 1, 1

    if IsUnitAttackable(unitTag) then
        r, g, b = 1, 0.28, 0.28
    elseif IsUnitFriend("player", unitTag) then
        r, g, b = 0.35, 1, 0.4
    else
        r, g, b = 1, 0.84, 0.3
    end

    self:ApplyTargetFrameStyle(unitTag)
    self.targetNameLabel:SetColor(r, g, b)
    self.targetNameLabel:SetText(name)
    self.targetNameLabel:SetHidden(false)
end

local function styleSlotFromEffect(self, slot, effect)
    if not effect then
        slot.effect = nil
        slot:SetHidden(true)
        if slot.border then
            slot.border:SetEdgeColor(0, 0, 0, 0)
        end
        slot.timer:SetText("")
        slot.count:SetText("")
        slot.lastTimerText = ""
        slot.wasFlashing = false
        slot.baseBorderColor = nil
        slot.baseTimerColor = nil
        return
    end

    if self:IsPlayerApplied(effect) then
        slot.icon:SetAlpha(1)
    else
        slot.icon:SetAlpha(0.92)
    end

    slot.icon:SetTexture(effect.iconName)
    if effect.stackCount and effect.stackCount > 1 then
        slot.count:SetText(tostring(effect.stackCount))
    else
        slot.count:SetText("")
    end
    slot.count:SetColor(1, 0.92, 0.75, 1)

    slot.effect = effect
    slot:SetHidden(false)

    local borderColor, timerColor = self:GetColorsForEffect(effect)
    slot.baseBorderColor = borderColor
    slot.baseTimerColor = timerColor
    slot.wasFlashing = false
    slot.lastTimerText = nil

    if slot.border and borderColor then
        slot.border:SetCenterColor(0, 0, 0, 0.45)
        slot.border:SetEdgeColor(self:UnpackColor(borderColor))
    end
    if timerColor then
        slot.timer:SetColor(self:UnpackColor(timerColor))
    end
end

function BEV:Redraw()
    if not self.win then
        return
    end

    local showBuffs = self.sv.showBuffs
    local showDebuffs = self.sv.showDebuffs
    local showPermanents = self.sv.showPermanents
    local now = GetFrameTimeSeconds()

    local buffsList = self.buffScratch or {}
    local debuffsList = self.debuffScratch or {}
    self.buffScratch = buffsList
    self.debuffScratch = debuffsList

    ZO_ClearNumericallyIndexedTable(buffsList)
    ZO_ClearNumericallyIndexedTable(debuffsList)

    for _, effect in pairs(self.effects) do
        if showPermanents or not effect.isPermanent then
            if effect.effectType == BUFF_EFFECT_TYPE_BUFF then
                buffsList[#buffsList + 1] = effect
            elseif effect.effectType == BUFF_EFFECT_TYPE_DEBUFF then
                debuffsList[#debuffsList + 1] = effect
            end
        end
    end

    self:SortEffects(buffsList, now)
    self:SortEffects(debuffsList, now)
    self:UpdateSlotLayout()

    local visibleBuffSlotCount = 0
    if showBuffs then
        visibleBuffSlotCount = math.min(#buffsList, #self.buffSlots)
        for i = 1, visibleBuffSlotCount do
            styleSlotFromEffect(self, self.buffSlots[i], buffsList[i])
        end

        local previousBuffSlotCount = self.visibleBuffSlotCount or 0
        for i = visibleBuffSlotCount + 1, previousBuffSlotCount do
            styleSlotFromEffect(self, self.buffSlots[i], nil)
        end
    else
        local previousBuffSlotCount = self.visibleBuffSlotCount or 0
        for i = 1, previousBuffSlotCount do
            styleSlotFromEffect(self, self.buffSlots[i], nil)
        end
    end
    self.visibleBuffSlotCount = visibleBuffSlotCount

    local visibleDebuffSlotCount = 0
    if showDebuffs then
        visibleDebuffSlotCount = math.min(#debuffsList, #self.debuffSlots)
        for i = 1, visibleDebuffSlotCount do
            styleSlotFromEffect(self, self.debuffSlots[i], debuffsList[i])
        end

        local previousDebuffSlotCount = self.visibleDebuffSlotCount or 0
        for i = visibleDebuffSlotCount + 1, previousDebuffSlotCount do
            styleSlotFromEffect(self, self.debuffSlots[i], nil)
        end
    else
        local previousDebuffSlotCount = self.visibleDebuffSlotCount or 0
        for i = 1, previousDebuffSlotCount do
            styleSlotFromEffect(self, self.debuffSlots[i], nil)
        end
    end
    self.visibleDebuffSlotCount = visibleDebuffSlotCount
end
