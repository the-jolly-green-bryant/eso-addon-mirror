-- CooldownTrackerFramesActions.lua
-- Creates and manages movable list-style display frames for tracking cooldowns/buffs/procs.

local CooldownTracker = assert(_G["CooldownTracker"], "CooldownTracker not loaded")

---@type any|nil
local SIEGE_BAR_SCENE = _G["SIEGE_BAR_SCENE"]

local FramesUtils = assert(CooldownTracker.FramesUtils, "FramesUtils not loaded")

local FramesActions = {}
CooldownTracker.FramesActions = FramesActions

FramesActions.STACK_DISPLAY_SIDE = FramesUtils.STACK_DISPLAY_SIDE
FramesActions.STACK_DISPLAY_OVERLAY = FramesUtils.STACK_DISPLAY_OVERLAY

-- Constants
local DEFAULT_ICON_SIZE = 32
local DEFAULT_ROW_HEIGHT = 36
local DEFAULT_MAX_ROWS = 10
local DEFAULT_FRAME_WIDTH = 300
local DEFAULT_FONT = "ZoFontGameBold"
local DEFAULT_TIMER_FONT = "ZoFontGamepad34"
local DEFAULT_TIMER_WIDTH = 90
local FALLBACK_ICON = FramesUtils.FALLBACK_ICON

-- Frame pool (reserved for future reuse; current implementation uses one persistent frame).
local framePool = {}

-- Canonical frames state.
local framesState = assert(CooldownTracker.State and CooldownTracker.State.frames, "Frames state not initialized")
local activeFrames = framesState.activeFrames

--- Get default frame configuration.
---@param id string
---@param name string
---@return TrackerFrameConfig
function FramesActions.GetDefaultConfig(id, name)
    return {
        id = id,
        name = name or "Tracker",
        point = TOPLEFT,
        x = 100,
        y = 300,
        scale = 1.0,
        alpha = 1.0,
        iconSize = DEFAULT_ICON_SIZE,
        rowHeight = DEFAULT_ROW_HEIGHT,
        maxRows = DEFAULT_MAX_ROWS,
        stackDisplayMode = FramesUtils.STACK_DISPLAY_OVERLAY,
        showTitle = true,
        locked = true,
    }
end

local function ApplyStackDisplayMode(row, config)
    if not row or not config then
        return
    end

    local mode = FramesUtils.NormalizeStackDisplayMode(config.stackDisplayMode)
    local stack = row.stack
    local stackBG = row.stackBG

    stack:ClearAnchors()
    if stackBG then
        stackBG:ClearAnchors()
    end

    if mode == FramesUtils.STACK_DISPLAY_OVERLAY then
        stack:SetAnchor(BOTTOMRIGHT, row.icon, BOTTOMRIGHT, -2, -2, nil)
        stack:SetDimensions(config.iconSize, 18)
        stack:SetFont("ZoFontGamepadBold20")
        stack:SetColor(1, 1, 1, 1)
        stack:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        stack:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    else
        local stackLabelWidth = FramesUtils.GetStackLabelWidth(config.iconSize, config.rowHeight)
        stack:SetAnchor(LEFT, row.iconBorder, RIGHT, 8, 0, nil)
        stack:SetDimensions(stackLabelWidth, config.rowHeight)
        stack:SetFont(DEFAULT_TIMER_FONT)
        stack:SetColor(1, 0.9, 0.2, 1)
        stack:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        stack:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        if stackBG then
            stackBG:SetAnchor(LEFT, row.iconBorder, RIGHT, 8, 0, nil)
            stackBG:SetDimensions(stackLabelWidth, config.rowHeight)
        end
    end

    if stackBG then
        stackBG:SetHidden(true)
    end
end

local function AnchorRows(rows, root, config)
    if not rows or not root or not config then
        return
    end
    local titleHeight = config.showTitle and 24 or 0
    for i = 1, config.maxRows do
        local row = rows[i]
        if row and row.control then
            row.control:ClearAnchors()
            local yOffset = titleHeight + ((i - 1) * config.rowHeight)
            row.control:SetAnchor(TOPLEFT, root, TOPLEFT, 0, yOffset, nil)
        end
    end
end

--- Create a single row within a frame.
---@param parent Control
---@param index number
---@param config TrackerFrameConfig
---@return { control: Control, icon: SCT_TextureControl, iconBorder: SCT_TextureControl, iconBG: SCT_TextureControl, label: LabelControl, timer: LabelControl, stack: SCT_LabelControl, stackBG: SCT_TextureControl|nil }
local function CreateRow(parent, index, config)
    local frameId = config.id
    local iconSize = config.iconSize
    local rowHeight = config.rowHeight

    local row = WINDOW_MANAGER:CreateControl(string.format("%s_Row%d", frameId, index), parent, CT_CONTROL)
    row:SetDimensions(DEFAULT_FRAME_WIDTH, rowHeight)
    row:SetDrawLayer(DL_OVERLAY)
    row:SetDrawLevel(10 + index)

    -- Icon background/border (ability frame style)
    ---@type SCT_TextureControl
    local iconBorder = WINDOW_MANAGER:CreateControl(string.format("%s_Row%dIconBorder", frameId, index), row, CT_TEXTURE)
    iconBorder:SetDimensions(iconSize + 4, iconSize + 4)
    iconBorder:SetAnchor(LEFT, row, LEFT, 2, 0, nil)
    iconBorder:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
    iconBorder:SetDrawLayer(DL_OVERLAY)
    iconBorder:SetDrawLevel(11 + index)

    -- Icon background fill (matches action bar inset)
    ---@type SCT_TextureControl
    local iconBG = WINDOW_MANAGER:CreateControl(string.format("%s_Row%dIconBG", frameId, index), row, CT_TEXTURE)
    iconBG:SetDimensions(iconSize + 4, iconSize + 4)
    iconBG:SetAnchor(CENTER, iconBorder, CENTER, 0, 0, nil)
    iconBG:SetTexture("/esoui/art/actionbar/abilityInset.dds")
    iconBG:SetDrawLayer(DL_OVERLAY)
    iconBG:SetDrawLevel(10 + index)

    -- Icon texture
    ---@type SCT_TextureControl
    local icon = WINDOW_MANAGER:CreateControl(string.format("%s_Row%dIcon", frameId, index), row, CT_TEXTURE)
    icon:SetDimensions(iconSize, iconSize)
    icon:SetAnchor(CENTER, iconBorder, CENTER, 0, 0, nil)
    icon:SetDrawLayer(DL_OVERLAY)
    icon:SetDrawLevel(12 + index)

    -- Stack count overlay (between icon and timer)
    local stackLabelWidth = FramesUtils.GetStackLabelWidth(iconSize, rowHeight)
    ---@type SCT_TextureControl
    local stackBG = WINDOW_MANAGER:CreateControl(string.format("%s_Row%dStackBG", frameId, index), iconBorder, CT_TEXTURE)
    stackBG:SetAnchor(LEFT, iconBorder, RIGHT, 8, 0, nil)
    stackBG:SetDimensions(stackLabelWidth, rowHeight)
    stackBG:SetTexture("/esoui/art/miscellaneous/gamepad/gp_edgeFill.dds")
    stackBG:SetColor(0, 0, 0, 0.8)
    stackBG:SetDrawLayer(DL_OVERLAY)
    stackBG:SetDrawLevel(12 + index)
    stackBG:SetHidden(true)

    ---@type SCT_LabelControl
    local stack = WINDOW_MANAGER:CreateControl(string.format("%s_Row%dStack", frameId, index), iconBorder, CT_LABEL)
    stack:SetAnchor(LEFT, iconBorder, RIGHT, 8, 0, nil)
    stack:SetDimensions(stackLabelWidth, rowHeight)
    stack:SetDrawLayer(DL_OVERLAY)
    stack:SetDrawLevel(13 + index)
    stack:SetText("")
    stack:SetHidden(true)
    -- Stack styling is applied after the row is created.

    -- Name label
    local label = WINDOW_MANAGER:CreateControl(string.format("%s_Row%dLabel", frameId, index), row, CT_LABEL)
    label:SetAnchor(LEFT, iconBorder, RIGHT, 8, 0, nil)
    label:SetDimensions(DEFAULT_FRAME_WIDTH - iconSize - DEFAULT_TIMER_WIDTH - 28, rowHeight)
    label:SetFont(DEFAULT_FONT)
    label:SetColor(1, 1, 1, 1)
    label:SetDrawLayer(DL_OVERLAY)
    label:SetDrawLevel(12 + index)
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    -- Timer label
    local timer = WINDOW_MANAGER:CreateControl(string.format("%s_Row%dTimer", frameId, index), row, CT_LABEL)
    timer:SetAnchor(LEFT, stack, RIGHT, 8, 0, nil)
    timer:SetDimensions(DEFAULT_TIMER_WIDTH, rowHeight)
    timer:SetFont(DEFAULT_TIMER_FONT)
    timer:SetColor(0.9, 0.9, 0.9, 1)
    timer:SetDrawLayer(DL_OVERLAY)
    timer:SetDrawLevel(12 + index)
    timer:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    timer:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local rowData = {
        control = row,
        icon = icon,
        iconBorder = iconBorder,
        iconBG = iconBG,
        label = label,
        timer = timer,
        stack = stack,
        stackBG = stackBG,
    }
    ApplyStackDisplayMode(rowData, config)
    return rowData
end

--- Create a tracker frame.
---@param config TrackerFrameConfig
---@return TrackerFrame
function FramesActions.CreateFrame(config)
    local frameId = config.id
    local controlName = "CooldownTracker_" .. frameId

    -- Root control
    local root = WINDOW_MANAGER:CreateTopLevelWindow(controlName)
    root:SetClampedToScreen(true)
    root:SetMouseEnabled(not config.locked)
    root:SetMovable(not config.locked)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawTier(DT_HIGH)
    root:SetDrawLevel(5)
    root:SetAlpha(config.alpha)
    root:SetScale(config.scale)
    root:SetHidden(false)

    -- Calculate dimensions
    local titleHeight = config.showTitle and 24 or 0
    local totalHeight = titleHeight + (config.maxRows * config.rowHeight)
    root:SetDimensions(DEFAULT_FRAME_WIDTH, totalHeight)
    root:SetAnchor(config.point, GuiRoot, config.point, config.x, config.y, nil)

    -- Title label (optional)
    local title = nil
    if config.showTitle then
        title = WINDOW_MANAGER:CreateControl(controlName .. "_Title", root, CT_LABEL)
        title:SetAnchor(TOPLEFT, root, TOPLEFT, 4, 2, nil)
        title:SetDimensions(DEFAULT_FRAME_WIDTH - 8, 20)
        title:SetFont("ZoFontGameBold")
        title:SetColor(0.8, 0.7, 0.5, 1)
        title:SetDrawLayer(DL_OVERLAY)
        title:SetDrawLevel(6)
        title:SetText(config.name)
    end

    -- Create rows
    local rows = {}
    for i = 1, config.maxRows do
        local row = CreateRow(root, i, config)
        row.control:SetHidden(true)
        rows[i] = row
    end
    AnchorRows(rows, root, config)

    -- Add to scene fragments for HUD visibility
    local fragment = ZO_HUDFadeSceneFragment:New(root, 0, 0)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
    if SIEGE_BAR_SCENE and SIEGE_BAR_SCENE.AddFragment then
        SIEGE_BAR_SCENE:AddFragment(fragment)
    end

    -- Drag handlers for repositioning
    root:SetHandler("OnMoveStart", function(control)
        -- Nothing special needed
    end)

    root:SetHandler("OnMoveStop", function(control)
        local _, point, _, _, x, y = control:GetAnchor(0)
        config.x = x
        config.y = y
        config.point = point
        -- Save to savedvars
        if CooldownTracker.SaveFramePosition then
            CooldownTracker:SaveFramePosition(config.id, config.point, config.x, config.y)
        end
    end)

    root:SetHandler("OnEffectivelyShown", function(control)
        control:SetAlpha(config.alpha)
    end)

    ---@type TrackerFrame
    local frame = {
        config = config,
        root = root,
        title = title,
        rows = rows,
        fragment = fragment,
        isDragging = false,
    }

    activeFrames[frameId] = frame
    return frame
end

--- Update frame lock state.
---@param frame TrackerFrame
---@param locked boolean
function FramesActions.SetLocked(frame, locked)
    frame.config.locked = locked
    frame.root:SetMouseEnabled(not locked)
    frame.root:SetMovable(not locked)
end

--- Update frame scale.
---@param frame TrackerFrame
---@param scale number
function FramesActions.SetScale(frame, scale)
    frame.config.scale = scale
    frame.root:SetScale(scale)
end

--- Update frame alpha.
---@param frame TrackerFrame
---@param alpha number
function FramesActions.SetAlpha(frame, alpha)
    frame.config.alpha = alpha
    frame.root:SetAlpha(alpha)
end

--- Update stack display mode.
---@param frame TrackerFrame
---@param mode string
function FramesActions.SetStackDisplayMode(frame, mode)
    if not frame then
        return
    end
    frame.config.stackDisplayMode = FramesUtils.NormalizeStackDisplayMode(mode)
    for i = 1, frame.config.maxRows do
        ApplyStackDisplayMode(frame.rows[i], frame.config)
    end
end

local floor = math.floor

---@param remaining number
---@return string kind
---@return number bucket
local function GetTimerKindBucket(remaining)
    if remaining <= 0 then
        return "empty", 0
    end
    if remaining < 10 then
        return "dec", floor((remaining * 10) + 0.5)
    end
    if remaining < 60 then
        return "sec", floor(remaining)
    end
    if remaining < 3600 then
        return "minsec", floor(remaining)
    end
    return "hour", floor(remaining / 3600)
end

---@param kind string
---@param bucket number
---@return string
local function FormatTimerText(kind, bucket)
    if kind == "empty" then
        return ""
    end
    if kind == "dec" then
        local whole = floor(bucket / 10)
        local tenths = bucket - (whole * 10)
        return tostring(whole) .. "." .. tostring(tenths) .. "s"
    end
    if kind == "sec" then
        return tostring(bucket) .. "s"
    end
    if kind == "minsec" then
        local mins = floor(bucket / 60)
        local secs = bucket - (mins * 60)
        return tostring(mins) .. "m " .. tostring(secs) .. "s"
    end
    return tostring(bucket) .. "h+"
end

--- Render entries to a frame.
---@param frame TrackerFrame
---@param entries ActiveEntry[]
function FramesActions.RenderEntries(frame, entries)
    local rows = frame.rows
    local maxRows = frame.config.maxRows

    -- Sort by remaining time (soonest first)
    table.sort(entries, function(a, b)
        return (a.remaining or 0) < (b.remaining or 0)
    end)

    local stackMode = FramesUtils.NormalizeStackDisplayMode(frame.config.stackDisplayMode)
    local overlayMode = stackMode == FramesUtils.STACK_DISPLAY_OVERLAY

    for i = 1, maxRows do
        local row = rows[i]
        local entry = entries[i]

        if entry then
            if row._hidden ~= false then
                row.control:SetHidden(false)
                row._hidden = false
            end

            local iconPath = FramesUtils.GetValidIcon(entry.icon)
            if row._iconPath ~= iconPath then
                row.icon:SetTexture(iconPath)
                row._iconPath = iconPath
            end

            if row._iconAlpha ~= 1 then
                row.icon:SetColor(1, 1, 1, 1)
                row._iconAlpha = 1
            end

            if row._borderHidden ~= false then
                row.iconBorder:SetHidden(false)
                row._borderHidden = false
            end

            if row._labelText ~= "" then
                row.label:SetText("")
                row._labelText = ""
            end

            if entry.isPermanent then
                if row._timerText ~= "" then
                    row.timer:SetText("")
                    row._timerText = ""
                end
                row._timerKind = "permanent"
                row._timerBucket = 0
            else
                local kind, bucket = GetTimerKindBucket(entry.remaining or 0)
                if kind ~= row._timerKind or bucket ~= row._timerBucket then
                    local timerText = FormatTimerText(kind, bucket)
                    row.timer:SetText(timerText)
                    row._timerText = timerText
                    row._timerKind = kind
                    row._timerBucket = bucket
                end
            end

            -- Stack overlay
            local stacks = entry.stackCount
            local hasStacks = type(stacks) == "number" and stacks > 0
            if hasStacks then
                if row._stackVisible ~= true then
                    row.stack:SetHidden(false)
                    row._stackVisible = true
                end
                if row._stackCount ~= stacks then
                    local stackText = tostring(stacks)
                    row.stack:SetText(stackText)
                    row._stackText = stackText
                    row._stackCount = stacks
                end
                if row._stackColorMode ~= stackMode then
                    if overlayMode then
                        row.stack:SetColor(1, 1, 1, 1)
                    else
                        row.stack:SetColor(1, 0.9, 0.2, 1)
                    end
                    row._stackColorMode = stackMode
                end
            else
                if row._stackVisible ~= false then
                    row.stack:SetHidden(true)
                    row._stackVisible = false
                end
                if row._stackText ~= "" then
                    row.stack:SetText("")
                    row._stackText = ""
                end
                row._stackCount = nil
                row._stackColorMode = nil
            end

            local desiredAnchor = "icon"
            if hasStacks and not overlayMode then
                desiredAnchor = "stack"
            end
            if row._timerAnchor ~= desiredAnchor then
                row.timer:ClearAnchors()
                if desiredAnchor == "stack" then
                    row.timer:SetAnchor(LEFT, row.stack, RIGHT, 8, 0, nil)
                else
                    row.timer:SetAnchor(LEFT, row.iconBorder, RIGHT, 8, 0, nil)
                end
                row._timerAnchor = desiredAnchor
            end

            -- Keep icons fully saturated; cooldown styling handled elsewhere.
            if row._iconDesaturation ~= 0 then
                row.icon:SetDesaturation(0)
                row._iconDesaturation = 0
            end
            row._entryId = entry.id
        else
            if row._hidden ~= true then
                row.control:SetHidden(true)
                row._hidden = true
            end
            row._entryId = nil
        end
    end
end

--- Show an empty state (no text).
---@param frame TrackerFrame
function FramesActions.ShowEmpty(frame)
    local rows = frame.rows
    local maxRows = frame.config.maxRows

    if maxRows > 0 and rows[1] then
        local row = rows[1]
        if row._labelText ~= "" then
            row.label:SetText("")
            row._labelText = ""
        end
        if row._timerText ~= "" then
            row.timer:SetText("")
            row._timerText = ""
        end
        row._timerKind = "empty"
        row._timerBucket = 0
        if row.stack then
            if row._stackText ~= "" then
                row.stack:SetText("")
                row._stackText = ""
            end
            if row._stackVisible ~= false then
                row.stack:SetHidden(true)
                row._stackVisible = false
            end
            row._stackCount = nil
        end

        if frame.config.locked then
            -- When locked, hide the entire row so the frame is visually empty.
            if row._hidden ~= true then
                row.control:SetHidden(true)
                row._hidden = true
            end
        else
            -- When unlocked, show a subtle placeholder icon so it's easy to grab and move.
            if row._hidden ~= false then
                row.control:SetHidden(false)
                row._hidden = false
            end
            if row._borderHidden ~= false then
                row.iconBorder:SetHidden(false)
                row._borderHidden = false
            end
            local placeholderIcon = FramesUtils.GetValidIcon(FALLBACK_ICON)
            if row._iconPath ~= placeholderIcon then
                row.icon:SetTexture(placeholderIcon)
                row._iconPath = placeholderIcon
            end
            if row._iconAlpha ~= 0.25 then
                row.icon:SetColor(1, 1, 1, 0.25)
                row._iconAlpha = 0.25
            end
            if row._iconDesaturation ~= 1.0 then
                row.icon:SetDesaturation(1.0)
                row._iconDesaturation = 1.0
            end
        end
        row._entryId = nil
    end

    for i = 2, maxRows do
        local row = rows[i]
        if row._hidden ~= true then
            row.control:SetHidden(true)
            row._hidden = true
        end
        row._entryId = nil
    end
end

--- Hide all rows in a frame.
---@param frame TrackerFrame
function FramesActions.HideAll(frame)
    for i = 1, frame.config.maxRows do
        local row = frame.rows[i]
        if row._hidden ~= true then
            row.control:SetHidden(true)
            row._hidden = true
        end
        row._entryId = nil
    end
end

--- Destroy a frame and clean up.
---@param frameId string
function FramesActions.DestroyFrame(frameId)
    local frame = activeFrames[frameId]
    if not frame then
        return
    end

    -- Remove from scenes
    if frame.fragment then
        HUD_SCENE:RemoveFragment(frame.fragment)
        HUD_UI_SCENE:RemoveFragment(frame.fragment)
        if SIEGE_BAR_SCENE and SIEGE_BAR_SCENE.RemoveFragment then
            SIEGE_BAR_SCENE:RemoveFragment(frame.fragment)
        end
    end

    -- Destroy controls
    if frame.root then
        frame.root:SetHidden(true)
        frame.root:ClearAnchors()
    end

    activeFrames[frameId] = nil
end

--- Get an active frame by ID.
---@param frameId string
---@return TrackerFrame|nil
function FramesActions.GetFrame(frameId)
    return activeFrames[frameId]
end

--- Get all active frames.
---@return table<string, TrackerFrame>
function FramesActions.GetAllFrames()
    return activeFrames
end

return FramesActions

