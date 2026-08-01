VestigeMirror = VestigeMirror or {}
VestigeMirror.UI = {}

local LEFT_ARMOR_SLOTS =
{
    Chest = true,
    Hands = true,
    Waist = true,
}

local RIGHT_ARMOR_SLOTS =
{
    Shoulders = true,
    Legs = true,
    Feet = true,
}

local function SetDye(control, dye)
    local alpha = dye.empty and 0.55 or 1
    control:SetCenterColor(dye.r, dye.g, dye.b, alpha)
    control:SetEdgeColor(0, 0, 0, 1)
    control:SetMouseEnabled(true)
    control:SetHandler("OnMouseEnter", function()
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -4)
        SetTooltipText(InformationTooltip, dye.name)
    end)
    control:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)
end

local function ConfigureCalloutSide(callout, side)
    local iconFrame = callout:GetNamedChild("IconFrame")
    local icon = callout:GetNamedChild("Icon")
    local slotLabel = callout:GetNamedChild("Slot")
    local name = callout:GetNamedChild("Name")
    local meta = callout:GetNamedChild("Meta")
    local dyeName1 = callout:GetNamedChild("DyeName1")
    local dyeName2 = callout:GetNamedChild("DyeName2")
    local dyeName3 = callout:GetNamedChild("DyeName3")
    local dye1 = callout:GetNamedChild("Dye1")
    local dye2 = callout:GetNamedChild("Dye2")
    local dye3 = callout:GetNamedChild("Dye3")
    local readability = callout:GetNamedChild("Readability")

    readability:ClearAnchors()
    iconFrame:ClearAnchors()
    icon:ClearAnchors()
    slotLabel:ClearAnchors()
    name:ClearAnchors()
    meta:ClearAnchors()
    dyeName1:ClearAnchors()
    dyeName2:ClearAnchors()
    dyeName3:ClearAnchors()
    dye1:ClearAnchors()
    dye2:ClearAnchors()
    dye3:ClearAnchors()

    if side == "right" then
        slotLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        name:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        meta:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        dyeName1:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        dyeName2:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        dyeName3:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        readability:SetAnchor(TOPRIGHT, callout, TOPRIGHT, -76, 12)
        iconFrame:SetAnchor(TOPRIGHT, callout, TOPRIGHT, -12, 36)
        icon:SetAnchor(CENTER, iconFrame, CENTER, 0, 0)
        slotLabel:SetAnchor(TOPRIGHT, readability, TOPRIGHT, -10, 8)
        name:SetAnchor(TOPRIGHT, slotLabel, BOTTOMRIGHT, 0, -1)
        meta:SetAnchor(TOPRIGHT, name, BOTTOMRIGHT, 0, -1)
        dye1:SetAnchor(TOPRIGHT, meta, BOTTOMRIGHT, 0, 8)
        dyeName1:SetAnchor(RIGHT, dye1, LEFT, -6, 0)
        dye2:SetAnchor(TOPRIGHT, dye1, BOTTOMRIGHT, 0, 3)
        dyeName2:SetAnchor(RIGHT, dye2, LEFT, -6, 0)
        dye3:SetAnchor(TOPRIGHT, dye2, BOTTOMRIGHT, 0, 3)
        dyeName3:SetAnchor(RIGHT, dye3, LEFT, -6, 0)
    else
        slotLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        meta:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        dyeName1:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        dyeName2:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        dyeName3:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        readability:SetAnchor(TOPLEFT, callout, TOPLEFT, 76, 12)
        iconFrame:SetAnchor(TOPLEFT, callout, TOPLEFT, 12, 36)
        icon:SetAnchor(CENTER, iconFrame, CENTER, 0, 0)
        slotLabel:SetAnchor(TOPLEFT, readability, TOPLEFT, 10, 8)
        name:SetAnchor(TOPLEFT, slotLabel, BOTTOMLEFT, 0, -1)
        meta:SetAnchor(TOPLEFT, name, BOTTOMLEFT, 0, -1)
        dye1:SetAnchor(TOPLEFT, meta, BOTTOMLEFT, 0, 8)
        dyeName1:SetAnchor(LEFT, dye1, RIGHT, 6, 0)
        dye2:SetAnchor(TOPLEFT, dye1, BOTTOMLEFT, 0, 4)
        dyeName2:SetAnchor(LEFT, dye2, RIGHT, 6, 0)
        dye3:SetAnchor(TOPLEFT, dye2, BOTTOMLEFT, 0, 4)
        dyeName3:SetAnchor(LEFT, dye3, RIGHT, 6, 0)
    end
end

local function SetupCallout(callout, slot, side)
    ConfigureCalloutSide(callout, side)

    local iconFrame = callout:GetNamedChild("IconFrame")
    if slot.label == "Head" and slot.source == "Head Collectible" then
        iconFrame:SetTexture("/esoui/art/siegebar/siegeslot_pressed.dds")
    else
        iconFrame:SetTexture("EsoUI/Art/SiegeBar/siegeSlot_empty.dds")
    end

    callout:GetNamedChild("Icon"):SetTexture(slot.icon)
    callout:GetNamedChild("Slot"):SetText(slot.label)
    callout:GetNamedChild("Name"):SetText(slot.name)

    local meta = slot.source
    if slot.materialName and slot.materialName ~= "" then
        meta = string.format("%s - %s", meta, slot.materialName)
    end
    callout:GetNamedChild("Meta"):SetText(meta)

    local name = callout:GetNamedChild("Name")
    local icon = callout:GetNamedChild("Icon")
    if slot.isEmpty then
        name:SetColor(0.56, 0.59, 0.62, 1)
        icon:SetAlpha(0.55)
    else
        name:SetColor(0.95, 0.91, 0.82, 1)
        icon:SetAlpha(1)
    end

    for dyeIndex = 1, 3 do
        SetDye(callout:GetNamedChild("Dye" .. dyeIndex), slot.dyes[dyeIndex])
    end

    callout:GetNamedChild("DyeName1"):SetText(slot.dyes[1].name)
    callout:GetNamedChild("DyeName2"):SetText(slot.dyes[2].name)
    callout:GetNamedChild("DyeName3"):SetText(slot.dyes[3].name)
end

local function AnchorCallout(callout, parent, previousCallout, index, layout)
    callout:ClearAnchors()
    if layout == "horizontal" then
        if index == 1 then
            callout:SetAnchor(LEFT, parent, LEFT, 0, 0)
        else
            callout:SetAnchor(LEFT, previousCallout, RIGHT, 28, 0)
        end
    elseif layout == "split" then
        if index == 1 then
            callout:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
        else
            callout:SetAnchor(TOPRIGHT, parent, TOPRIGHT, 0, 0)
        end
    else
        if index == 1 then
            callout:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
        else
            callout:SetAnchor(TOPLEFT, previousCallout, BOTTOMLEFT, 0, 26)
        end
    end
end

local function AcquireCallouts(parent, callouts, slots, layout, side)
    parent:SetHidden(#slots == 0)

    for index, callout in ipairs(callouts) do
        callout:SetHidden(index > #slots)
    end

    for index, slot in ipairs(slots) do
        local callout = callouts[index]
        if not callout then
            callout = WINDOW_MANAGER:CreateControlFromVirtual(parent:GetName() .. "Callout" .. index, parent, "VestigeMirrorItemCallout")
            callouts[index] = callout
        end

        AnchorCallout(callout, parent, callouts[index - 1], index, layout)
        SetupCallout(callout, slot, side)
        callout:SetHidden(false)
    end
end

local function SplitArmorSlots(slots)
    local headSlots = {}
    local leftSlots = {}
    local rightSlots = {}

    for _, slot in ipairs(slots) do
        if slot.label == "Head" then
            table.insert(headSlots, slot)
        elseif LEFT_ARMOR_SLOTS[slot.label] then
            table.insert(leftSlots, slot)
        elseif RIGHT_ARMOR_SLOTS[slot.label] then
            table.insert(rightSlots, slot)
        end
    end

    return headSlots, leftSlots, rightSlots
end

local function SetupCollectibleRow(row, collectible)
    local iconFrame = row:GetNamedChild("IconFrame")
    local icon = row:GetNamedChild("Icon")
    local label = row:GetNamedChild("Label")
    local name = row:GetNamedChild("Name")

    label:SetText(collectible.label)
    name:SetText(collectible.name)

    if collectible.icon then
        icon:SetTexture(collectible.icon)
        icon:SetHidden(false)
    else
        icon:SetHidden(true)
    end

    if collectible.isEmpty then
        iconFrame:SetAlpha(0.35)
        icon:SetAlpha(0.35)
        name:SetColor(0.56, 0.59, 0.62, 1)
    else
        iconFrame:SetAlpha(1)
        icon:SetAlpha(1)
        name:SetColor(0.95, 0.91, 0.82, 1)
    end
end

local function AcquireCollectibleRows(parent, rows, collectibles)
    parent:SetHidden(#collectibles == 0)

    local rowWidth = 300
    local rowHeight = 42
    local rowGap = 10
    local rowOffsetX = 42

    for index, row in ipairs(rows) do
        row:SetHidden(index > #collectibles)
    end

    for index, collectible in ipairs(collectibles) do
        local row = rows[index]
        if not row then
            row = WINDOW_MANAGER:CreateControl(parent:GetName() .. "Row" .. index, parent, CT_CONTROL)
            row:SetDimensions(rowWidth, rowHeight)

            local readability = WINDOW_MANAGER:CreateControl(row:GetName() .. "Readability", row, CT_TEXTURE)
            readability:SetTexture("EsoUI/Art/Miscellaneous/listItem_backdrop.dds")
            readability:SetColor(0, 0, 0, 0.82)
            readability:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 3)
            readability:SetAnchor(BOTTOMRIGHT, row, BOTTOMRIGHT, 0, 3)

            local iconFrame = WINDOW_MANAGER:CreateControl(row:GetName() .. "IconFrame", row, CT_TEXTURE)
            iconFrame:SetTexture("EsoUI/Art/SiegeBar/siegeSlot_empty.dds")
            iconFrame:SetDimensions(26, 26)
            iconFrame:SetAnchor(LEFT, row, LEFT, 8, 0)

            local icon = WINDOW_MANAGER:CreateControl(row:GetName() .. "Icon", row, CT_TEXTURE)
            icon:SetDimensions(19, 19)
            icon:SetAnchor(CENTER, iconFrame, CENTER, 0, 0)

            local label = WINDOW_MANAGER:CreateControl(row:GetName() .. "Label", row, CT_LABEL)
            label:SetFont("$(BOLD_FONT)|11|soft-shadow-thick")
            label:SetColor(0.50, 0.91, 0.88, 1)
            label:SetDimensions(250, 13)
            label:SetMaxLineCount(1)
            label:SetAnchor(TOPLEFT, iconFrame, TOPRIGHT, 7, 0)

            local name = WINDOW_MANAGER:CreateControl(row:GetName() .. "Name", row, CT_LABEL)
            name:SetFont("$(BOLD_FONT)|13|soft-shadow-thick")
            name:SetDimensions(250, 16)
            name:SetMaxLineCount(1)
            name:SetAnchor(TOPLEFT, label, BOTTOMLEFT, 0, -1)

            rows[index] = row
        end

        row:ClearAnchors()
        row:SetAnchor(TOPLEFT, parent, TOPLEFT, rowOffsetX * (index - 1), (rowHeight + rowGap) * (index - 1))

        SetupCollectibleRow(row, collectible)
        row:SetHidden(false)
    end
end

local function SetTextButtonHandler(control, callback)
    control:SetMouseEnabled(true)
    control:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            callback()
        end
    end)
end

function VestigeMirror.UI:Initialize(control)
    self.control = control
    self.headCallouts = {}
    self.leftCallouts = {}
    self.rightCallouts = {}
    self.weaponCallouts = {}
    self.collectibleRows = {}
    self.toggleBar = VestigeMirrorToggleBar
    self.toggleCollectibles = self.toggleBar:GetNamedChild("ToggleCollectibles")
    self.toggleCollectiblesLabel = self.toggleCollectibles:GetNamedChild("Label")
    self.collectiblesVisible = true

    SetTextButtonHandler(self.toggleCollectibles, function()
        self:ToggleCollectibles()
    end)

    control:SetHandler("OnKeyDown", function(_, key)
        if key == KEY_ESCAPE or key == KEY_GAMEPAD_START then
            VestigeMirror:Hide()
            return true
        elseif key == KEY_GAMEPAD_BUTTON_4 then
            self:ToggleCollectibles()
            return true
        end
    end)
    self:RefreshToggleControls()
end

function VestigeMirror.UI:IsShowing()
    return self.control and not self.control:IsHidden()
end

function VestigeMirror.UI:RefreshToggleControls()
    self.toggleCollectiblesLabel:SetText(self.collectiblesVisible and "Y/Triangle: Hide Collectibles" or "Y/Triangle: Show Collectibles")
end

function VestigeMirror.UI:ShowToggleBar()
    self.toggleBar:SetHidden(false)
    self:RefreshToggleControls()
end

function VestigeMirror.UI:HideToggleBar()
    self.toggleBar:SetHidden(true)
end

function VestigeMirror.UI:SetCollectiblesVisible(visible)
    self.collectiblesVisible = visible
    self.control:GetNamedChild("Collectibles"):SetHidden(not visible)
    self:RefreshToggleControls()
end

function VestigeMirror.UI:ToggleCollectibles()
    self:SetCollectiblesVisible(not self.collectiblesVisible)
end

function VestigeMirror.UI:Refresh(appearance)
    self.control:GetNamedChild("Subtitle"):SetText(appearance.outfitName)

    local headSlots, leftArmorSlots, rightArmorSlots = SplitArmorSlots(appearance.armorSlots)
    AcquireCallouts(self.control:GetNamedChild("HeadCallouts"), self.headCallouts, headSlots, nil, "left")
    AcquireCallouts(self.control:GetNamedChild("LeftCallouts"), self.leftCallouts, leftArmorSlots, nil, "left")
    AcquireCallouts(self.control:GetNamedChild("RightCallouts"), self.rightCallouts, rightArmorSlots, nil, "right")
    AcquireCallouts(self.control:GetNamedChild("BottomCallouts"), self.weaponCallouts, appearance.weaponSlots, "split", "left")
    AcquireCollectibleRows(self.control:GetNamedChild("Collectibles"):GetNamedChild("Rows"), self.collectibleRows, appearance.appearanceCollectibles or {})
    self.control:GetNamedChild("Collectibles"):SetHidden(not self.collectiblesVisible)
end
