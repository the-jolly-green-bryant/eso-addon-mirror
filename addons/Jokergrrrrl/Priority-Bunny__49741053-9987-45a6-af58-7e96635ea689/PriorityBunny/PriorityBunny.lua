-- Priority Bunny 0.2.0-alpha
-- Console-facing settings are registered with LibAddonMenu-2.0 and exposed
-- to the gamepad UI by LibGamepad.

PriorityBunny = PriorityBunny or {}
local PB = PriorityBunny

PB.name = "PriorityBunny"
PB.displayName = "Priority Bunny"
PB.version = "0.2.0-alpha"
PB.savedVariablesName = "PriorityBunnySavedVariables"
PB.savedVariablesVersion = 2
PB.labelsByControl = {}
PB.labelCounter = 0
PB.refreshPending = false

PB.firstNormalSlot = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1
PB.lastNormalSlot = ACTION_BAR_ULTIMATE_SLOT_INDEX

local defaults =
{
    front = { 1, 2, 3, 4, 5 },
    back  = { 1, 2, 3, 4, 5 },
    showBackBar = true,
    fontSize = 24,
    backBarFontSize = 18,
}

local GOLD_R, GOLD_G, GOLD_B, GOLD_A = 1.00, 0.82, 0.28, 1.00
local priorityChoices = { "None", "1", "2", "3", "4", "5" }
local priorityValues  = { 0, 1, 2, 3, 4, 5 }

local function Chat(message)
    d(string.format("|cFFD24APriority Bunny:|r %s", tostring(message)))
end

function PB:GetRelativeSlotIndex(physicalSlot)
    return physicalSlot - self.firstNormalSlot + 1
end

function PB:GetPriorityTable(hotbarCategory)
    if hotbarCategory == HOTBAR_CATEGORY_PRIMARY then
        return self.savedVariables.front
    elseif hotbarCategory == HOTBAR_CATEGORY_BACKUP then
        return self.savedVariables.back
    end
    return nil
end

function PB:GetOrCreateLabel(slotControl)
    local label = self.labelsByControl[slotControl]
    if label then return label end

    self.labelCounter = self.labelCounter + 1
    label = WINDOW_MANAGER:CreateControl(
        string.format("PriorityBunnyLabel%d", self.labelCounter),
        slotControl,
        CT_LABEL
    )
    label:SetDimensions(34, 34)
    label:SetAnchor(TOPLEFT, slotControl, TOPLEFT, 0, -1)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(GOLD_R, GOLD_G, GOLD_B, GOLD_A)
    label:SetDrawTier(DT_HIGH)
    label:SetDrawLayer(DL_OVERLAY)
    label:SetDrawLevel(100)
    label:SetMouseEnabled(false)
    label:SetHidden(true)

    self.labelsByControl[slotControl] = label
    return label
end

function PB:RefreshCategory(hotbarCategory)
    local priorities = self:GetPriorityTable(hotbarCategory)
    if not priorities then return end

    local activeCategory = GetActiveHotbarCategory()
    local isBackRow = hotbarCategory ~= activeCategory
    local fontSize = isBackRow and self.savedVariables.backBarFontSize
        or self.savedVariables.fontSize

    for physicalSlot = self.firstNormalSlot, self.lastNormalSlot do
        local button = ZO_ActionBar_GetButton(physicalSlot, hotbarCategory)
        if button and button.slot then
            local label = self:GetOrCreateLabel(button.slot)
            local relativeSlot = self:GetRelativeSlotIndex(physicalSlot)
            local priority = tonumber(priorities[relativeSlot]) or 0
            local slotType = GetSlotType(physicalSlot, hotbarCategory)
            local shouldShow = priority > 0
                and slotType ~= ACTION_TYPE_NOTHING
                and (not isBackRow or self.savedVariables.showBackBar)

            label:SetFont(string.format("$(BOLD_FONT)|%d|thick-outline", fontSize))
            label:SetText(shouldShow and tostring(priority) or "")
            label:SetHidden(not shouldShow)
        end
    end
end

function PB:RefreshAll()
    self:RefreshCategory(HOTBAR_CATEGORY_PRIMARY)
    self:RefreshCategory(HOTBAR_CATEGORY_BACKUP)
end

function PB:QueueRefresh(delay)
    if self.refreshPending then return end
    self.refreshPending = true
    zo_callLater(function()
        self.refreshPending = false
        self:RefreshAll()
    end, delay or 50)
end

function PB:MakePriorityOption(barKey, slotIndex, barLabel)
    return {
        type = "dropdown",
        name = string.format("%s slot %d", barLabel, slotIndex),
        tooltip = string.format(
            "Number shown on %s ability slot %d. Choose None to hide it.",
            zo_strlower(barLabel),
            slotIndex
        ),
        choices = priorityChoices,
        choicesValues = priorityValues,
        getFunc = function()
            return self.savedVariables[barKey][slotIndex] or 0
        end,
        setFunc = function(value)
            self.savedVariables[barKey][slotIndex] = tonumber(value) or 0
            self:QueueRefresh(0)
        end,
        default = defaults[barKey][slotIndex],
        width = "full",
    }
end

function PB:RegisterSettings()
    local LAM = LibAddonMenu2
    if not LAM then
        Chat("LibAddonMenu-2.0 is missing.")
        return
    end

    local panelData = {
        type = "panel",
        name = self.displayName,
        displayName = "|cFFD24APriority Bunny|r",
        author = "Savannah & Virgil",
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel("PriorityBunnyOptions", panelData)

    local options = {
        {
            type = "description",
            text = "Put simple priority numbers over your five normal ability buttons. Front and back bars are configured separately.",
            width = "full",
        },
        {
            type = "header",
            name = "Front bar",
            width = "full",
        },
    }

    for slotIndex = 1, 5 do
        table.insert(options, self:MakePriorityOption("front", slotIndex, "Front bar"))
    end

    table.insert(options, {
        type = "header",
        name = "Back bar",
        width = "full",
    })

    for slotIndex = 1, 5 do
        table.insert(options, self:MakePriorityOption("back", slotIndex, "Back bar"))
    end

    table.insert(options, {
        type = "checkbox",
        name = "Show numbers on inactive back row",
        tooltip = "When ESO displays the inactive weapon bar as a smaller row, show its Priority Bunny numbers too.",
        getFunc = function() return self.savedVariables.showBackBar end,
        setFunc = function(value)
            self.savedVariables.showBackBar = value
            self:QueueRefresh(0)
        end,
        default = defaults.showBackBar,
        width = "full",
    })

    LAM:RegisterOptionControls("PriorityBunnyOptions", options)
end

function PB:RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED,
        function() self:QueueRefresh(150) end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_HOTBAR_SLOT_UPDATED,
        function() self:QueueRefresh(50) end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED,
        function() self:QueueRefresh(100) end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED,
        function() self:QueueRefresh(100) end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED,
        function() self:QueueRefresh(100) end)
end

function PB:Initialize()
    self.savedVariables = ZO_SavedVars:NewCharacterIdSettings(
        self.savedVariablesName,
        self.savedVariablesVersion,
        nil,
        defaults
    )

    self:RegisterSettings()
    self:RegisterEvents()
    self:QueueRefresh(200)
    Chat("Loaded. Configure front and back slots in Settings > Addons > Priority Bunny.")
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= PB.name then return end
    EVENT_MANAGER:UnregisterForEvent(PB.name, EVENT_ADD_ON_LOADED)
    PB:Initialize()
end

EVENT_MANAGER:RegisterForEvent(PB.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
