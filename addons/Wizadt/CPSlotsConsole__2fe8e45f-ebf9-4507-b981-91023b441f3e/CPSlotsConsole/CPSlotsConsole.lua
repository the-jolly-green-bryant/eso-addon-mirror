-- CPSlotsConsole.lua
local CPSlotsConsole = {}
CPSlotsConsole.name = "CPSlotsConsole"

-- =====================
-- Saved Variables
-- =====================
CPSlotsConsole_SavedVars = CPSlotsConsole_SavedVars or {}

local defaults = {
    showOnLogin = true,
    updateInterval = 0.25,
    windowOffsetX = 0,
    windowOffsetY = 0,
    windowOpacity = 1,
    windowScale = 1,
    color1to4 = {r=0,g=1,b=0},   -- green
    color5to8 = {r=0,g=0,b=1},   -- blue
    color9to12 = {r=1,g=0,b=0},  -- red
}

for k,v in pairs(defaults) do
    if CPSlotsConsole_SavedVars[k] == nil then
        CPSlotsConsole_SavedVars[k] = v
    end
end

-- =====================
-- Constants
-- =====================
local HOTBAR_CAT = HOTBAR_CATEGORY_CHAMPION
local MAX_SLOTS = 12

-- =====================
-- Helper: Get slot color
-- =====================
local function GetSlotColor(slotId)
    if slotId >=1 and slotId <=4 then return CPSlotsConsole_SavedVars.color1to4
    elseif slotId >=5 and slotId <=8 then return CPSlotsConsole_SavedVars.color5to8
    elseif slotId >=9 and slotId <=12 then return CPSlotsConsole_SavedVars.color9to12
    end
    return {r=1,g=1,b=1}
end

-- =====================
-- Create main window
-- =====================
local function CreateMainWindow()
    if CPSlotsConsole.window then return end

    -- Main Window Frame
    local w = WINDOW_MANAGER:CreateTopLevelWindow("CPSlotsConsoleWindow")
    w:SetDimensions(420, 220)
    w:SetAnchor(CENTER, GuiRoot, CENTER,
        CPSlotsConsole_SavedVars.windowOffsetX,
        CPSlotsConsole_SavedVars.windowOffsetY)
    w:SetHidden(not CPSlotsConsole_SavedVars.showOnLogin)
    w:SetMouseEnabled(false)
    w:SetMovable(true)
    w:SetClampedToScreen(true)

    -- Column headers and labels
    w.slotLabels = {}
    w.columnHeaders = {}

    local startX, startY = 10, 10
    local headerHeight = 30
    local rowHeight = 28
    local colWidth = 130
    local colSpacing = 10

    local headers = { "Craft", "Warfare", "Fitness" }
    local headerColors = { {1,1,1,1}, {1,1,1,1}, {1,1,1,1} } -- match slot colors

    -- Create column headers
    for col = 1, 3 do
        local header = WINDOW_MANAGER:CreateControl(nil, w, CT_LABEL)
        header:SetAnchor(TOPLEFT, w, TOPLEFT,
            startX + (col - 1) * (colWidth + colSpacing),
            startY)
        header:SetFont("ZoFontGamepad34")
        header:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        header:SetText(headers[col])
        header:SetColor(headerColors[col][1], headerColors[col][2], headerColors[col][3], 1)
        w.columnHeaders[col] = header
    end

    -- Slot labels (4 rows per column)
    for slotId = 1, MAX_SLOTS do
        local col = math.floor((slotId - 1) / 4) + 1
        local row = (slotId - 1) % 4 + 1

        local label = WINDOW_MANAGER:CreateControl(nil, w, CT_LABEL)
        label:SetAnchor(TOPLEFT, w, TOPLEFT,
            startX + (col - 1) * (colWidth + colSpacing),
            startY + headerHeight + (row - 1) * rowHeight)
        label:SetFont("ZoFontGamepad27")
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetDimensions(colWidth - 5, rowHeight)
        label:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
        label:SetColor(1,1,1,1)  -- white text default
        w.slotLabels[slotId] = label
    end

    w:SetScale(CPSlotsConsole_SavedVars.windowScale)
    CPSlotsConsole.window = w
end


-- =====================
-- Update window text
-- =====================
local function UpdateWindow()
    if not CPSlotsConsole.window or CPSlotsConsole.window:IsHidden() then return end

    -- 1. Reset all labels to empty first using the correct table reference
    for i = 1, MAX_SLOTS do
        if CPSlotsConsole.window.slotLabels[i] then
            CPSlotsConsole.window.slotLabels[i]:SetText("")
        end
    end

    -- 2. Track which label index we are on for each column (Craft: 1, Warfare: 5, Fitness: 9)
    local colCounters = { 1, 5, 9 }

    for slotId = 1, MAX_SLOTS do
        local skillId = GetSlotBoundId and GetSlotBoundId(slotId, HOTBAR_CAT) or 0
        
        if skillId ~= 0 then
            local state = GetChampionSkillState and GetChampionSkillState(skillId) or CHAMPION_SKILL_STATE_ACTIVE

            -- Only process if the skill is actually active
            if state == CHAMPION_SKILL_STATE_ACTIVE then
                local col = math.floor((slotId - 1) / 4) + 1
                local targetLabelIdx = colCounters[col]

                -- Ensure we don't exceed 4 labels per column
                if targetLabelIdx <= (col * 4) then
                    local label = CPSlotsConsole.window.slotLabels[targetLabelIdx]
                    
                    if label then
                        local textColor = GetSlotColor(slotId)
                        local hex = string.format("%02X%02X%02X",
                            math.floor(textColor.r * 255),
                            math.floor(textColor.g * 255),
                            math.floor(textColor.b * 255)
                        )

                        local name = GetChampionSkillName and GetChampionSkillName(skillId) or "Unknown"
                        local cp = GetChampionSkillPointsAllocated and GetChampionSkillPointsAllocated(skillId) or 0
                        local text = name
                        if cp > 0 then text = text .. " - " .. cp end

                        label:SetText(string.format("|c%s%s|r", hex, text))
                        label:SetAlpha(CPSlotsConsole_SavedVars.windowOpacity)

                        -- Increment the counter for this column
                        colCounters[col] = colCounters[col] + 1
                    end
                end
            end
        end
    end
end

local function ResetSlotColors()
    CPSlotsConsole_SavedVars.color1to4 = defaults.color1to4
    CPSlotsConsole_SavedVars.color5to8 = defaults.color5to8
    CPSlotsConsole_SavedVars.color9to12 = defaults.color9to12

end


-- =====================
-- Real-time updater
-- =====================
local function StartUpdater()
    if CPSlotsConsole.updater then return end
    local lastTime = 0
    local updater = WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_CONTROL)
    updater:SetHandler("OnUpdate", function(control, time)
        if (time - lastTime) >= CPSlotsConsole_SavedVars.updateInterval then
            lastTime = time
            UpdateWindow()
        end
    end)
    CPSlotsConsole.updater = updater
end

-- =====================
-- LibAddonMenu Settings
-- =====================
local function SetupSettings()
    if not LibAddonMenu2 then
        zo_callLater(function()
            if LibAddonMenu2 then SetupSettings() end
        end, 1000)
        return
    end

    local panel = {
        type = "panel",
        name = "CPSlotsConsole",
        displayName = "|cFFD700CP|r |cFFFFFFSlots|r |c4169E1Console|r",
        author = "|cE6E6FAtwizadt|r",
        version = "|c00FF001.0|r",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LibAddonMenu2:RegisterAddonPanel("CPSlotsConsolePanel", panel)

    local options = {
        {
            type = "checkbox",
            name = "|cE6E6FAInitial Visibility|r",
            tooltip = "Show window automatically when logging in.",
            getFunc = function() return CPSlotsConsole_SavedVars.showOnLogin end,
            setFunc = function(value)
                CPSlotsConsole_SavedVars.showOnLogin = value
                CPSlotsConsole.window:SetHidden(not value)
            end,
        },
        {
            type = "slider",
            name = "|cFFFFFFText Scale|r",
            min = 0.5, max = 2, step = 0.05,
            getFunc = function() return CPSlotsConsole_SavedVars.windowScale end,
            setFunc = function(value)
                CPSlotsConsole_SavedVars.windowScale = value
                if CPSlotsConsole.window then
                    CPSlotsConsole.window:SetScale(value)
                end
            end,
        },

        -- APPEARANCE SECTION (No Headers to save space)
        {
            type = "submenu",
            name = "|c55FF55[ Slot Colors ]|r",
            controls = {
                {
                    type = "colorpicker",
                    name = "|c23D023Craft (1-4)|r",
                    getFunc = function() local c=CPSlotsConsole_SavedVars.color1to4 return c.r,c.g,c.b end,
                    setFunc = function(r,g,b) CPSlotsConsole_SavedVars.color1to4={r=r,g=g,b=b} end,
                    width = "half",
                },
                {
                    type = "colorpicker",
                    name = "|c319CFEWarfare (5-8)|r",
                    getFunc = function() local c=CPSlotsConsole_SavedVars.color5to8 return c.r,c.g,c.b end,
                    setFunc = function(r,g,b) CPSlotsConsole_SavedVars.color5to8={r=r,g=g,b=b} end,
                    width = "half",
                },
                {
                    type = "colorpicker",
                    name = "|cFF3838Fitness (9-12)|r",
                    getFunc = function() local c=CPSlotsConsole_SavedVars.color9to12 return c.r,c.g,c.b end,
                    setFunc = function(r,g,b) CPSlotsConsole_SavedVars.color9to12={r=r,g=g,b=b} end,
                    width = "half",
                },
                {
                    type = "button",
                    name = "|cFFD700Reset Defaults|r",
                    func = ResetSlotColors,
                    width = "half",
                },
            },
        },

        -- POSITIONING SECTION
        {
            type = "submenu",
            name = "|c55A2FF[ Window Placement ]|r",
            controls = {
                {
                    type = "slider",
                    name = "|cFFFFFFHorizontal (X)|r",
                    min = -1000, max = 1000, step = 10,
                    getFunc = function() return CPSlotsConsole_SavedVars.windowOffsetX end,
                    setFunc = function(value)
                        CPSlotsConsole_SavedVars.windowOffsetX = value
                        CPSlotsConsole.window:ClearAnchors()
                        CPSlotsConsole.window:SetAnchor(CENTER, GuiRoot, CENTER, value, CPSlotsConsole_SavedVars.windowOffsetY)
                    end,
                },
                {
                    type = "slider",
                    name = "|cFFFFFFVertical (Y)|r",
                    min = -1000, max = 1000, step = 10,
                    getFunc = function() return CPSlotsConsole_SavedVars.windowOffsetY end,
                    setFunc = function(value)
                        CPSlotsConsole_SavedVars.windowOffsetY = value
                        CPSlotsConsole.window:ClearAnchors()
                        CPSlotsConsole.window:SetAnchor(CENTER, GuiRoot, CENTER, CPSlotsConsole_SavedVars.windowOffsetX, value)
                    end,
                },
                {
                    type = "button",
                    name = "|cFF00FFSnap to Center|r",
                    func = function()
                        CPSlotsConsole_SavedVars.windowOffsetX = 0
                        CPSlotsConsole_SavedVars.windowOffsetY = 0
                        CPSlotsConsole.window:ClearAnchors()
                        CPSlotsConsole.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
                    end,
                },
            },
        },

        {
            type = "description",
            text = "Contact: |c00FFFFwizadt@gmail.com|r",
            title = "|cFFFF00Support|r",
        },
    }

    LibAddonMenu2:RegisterOptionControls("CPSlotsConsolePanel", options)
end
-- =====================
-- Addon loaded
-- =====================
local function OnAddOnLoaded(event, name)
    if name ~= CPSlotsConsole.name then return end

    CreateMainWindow()
    UpdateWindow()
    StartUpdater()
    SetupSettings()

    EVENT_MANAGER:RegisterForEvent(CPSlotsConsole.name, EVENT_CHAMPION_POINT_UPDATE, UpdateWindow)
end

EVENT_MANAGER:RegisterForEvent(CPSlotsConsole.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
