KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.QuickSlots = KyzderpsDerps.QuickSlots or {}
local QuickSlots = KyzderpsDerps.QuickSlots

local indexToSlotIndex_highIsle = {
    [1] = 4,
    [2] = 3,
    [3] = 2,
    [4] = 1,
    [5] = 8,
    [6] = 7,
    [7] = 6,
    [8] = 5,
}

local slotIndexToIndex_highIsle = {
    [4] = 1,
    [3] = 2,
    [2] = 3,
}


---------------------------------------------------------------------
-- High Isle PTS compatibility
---------------------------------------------------------------------
local function GetIndexToSlotIndex()
    return indexToSlotIndex_highIsle
end

local function GetSlotIndexToIndex()
    return slotIndexToIndex_highIsle
end

local function GetIndexTexture(index)
    return GetSlotTexture(GetIndexToSlotIndex()[index], HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
end


---------------------------------------------------------------------
-- Update the visual mini slots
---------------------------------------------------------------------
local function UpdateSlots()
    for index = 1, 3 do
        local control = KDDQuickSlot:GetNamedChild("Slot" .. tostring(index)):GetNamedChild("Texture")
        local texture = GetIndexTexture(index)
        if (texture ~= "") then
            control:SetTexture(texture)
            control:SetHidden(false)
        else
            control:SetHidden(true)
        end
    end
end

local function SetBackground(index, highlighted)
    local control = KDDQuickSlot:GetNamedChild("Slot" .. tostring(index)):GetNamedChild("Backdrop")
    control:SetHidden(not highlighted)
end

local function OnSlotChanged(_, actionSlotIndex)
    SetBackground(1, false)
    SetBackground(2, false)
    SetBackground(3, false)

    local index = GetSlotIndexToIndex()[actionSlotIndex]
    if (index) then
        SetBackground(index, true)
    end
end


---------------------------------------------------------------------
-- Called from keybinds
---------------------------------------------------------------------
function QuickSlots.SelectQuickSlot(index)
    SetCurrentQuickslot(GetIndexToSlotIndex()[index])
    PlaySound(SOUNDS.QUICKSLOT_SET)
end


---------------------------------------------------------------------
-- Initialize
---------------------------------------------------------------------
function QuickSlots.Initialize()
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "QuickSlot", EVENT_ACTIVE_QUICKSLOT_CHANGED, OnSlotChanged)
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "ArmoryEquippedQuickSlot", EVENT_ARMORY_BUILD_RESTORE_RESPONSE, UpdateSlots)
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "ActionSlotUpdated", EVENT_ACTION_SLOT_UPDATED, UpdateSlots)

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "HotbarSlotUpdated", EVENT_HOTBAR_SLOT_UPDATED, UpdateSlots)
    KDDQuickSlot:SetParent(QuickslotButton)
    KDDQuickSlot:SetAnchor(BOTTOMLEFT, QuickslotButton, TOPLEFT, -2, -2)

    UpdateSlots()
    OnSlotChanged(0, GetCurrentQuickslot())
    KDDQuickSlot:SetHidden(not KyzderpsDerps.savedOptions.quickSlots.enable)
end


---------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------
function QuickSlots.GetSettings()
    local controls = {
        {
            type = "description",
            title = nil,
            text = "You can set keybinds in your controls settings to select a quickslot with one key - though you still need to press your Quickslot Item key to use the item!",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Enable Indicator",
            tooltip = "Show 3 small icons above the default quickslot to indicate which one is selected",
            default = true,
            getFunc = function() return KyzderpsDerps.savedOptions.quickSlots.enable end,
            setFunc = function(value)
                    KyzderpsDerps.savedOptions.quickSlots.enable = value
                    KDDQuickSlot:SetHidden(not value)
                end,
            width = "full",
        },
    }

    local saveLoadSettings = QuickSlots.GetSaveLoadSettings()
    for _, control in ipairs(saveLoadSettings) do
        table.insert(controls, control)
    end

    return controls
end
