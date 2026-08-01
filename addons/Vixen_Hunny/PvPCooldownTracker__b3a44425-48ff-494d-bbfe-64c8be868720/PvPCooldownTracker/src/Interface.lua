-- -----------------------------------------------------------------------------
-- Cooldowns
-- Author:  g4rr3t
-- Created: May 5, 2018
--
-- Interface.lua
-- -----------------------------------------------------------------------------
PvPCooldownTracker = PvPCooldownTracker or {}
PvPCooldownTracker.UI = {}
PvPCooldownTracker.UI.scaleBase = 100

local scaleBase = PvPCooldownTracker.UI.scaleBase
local WM = WINDOW_MANAGER
local AM = ANIMATION_MANAGER
local CONTAINER_SUFFIX = "_Container"
local TEXTURE_SUFFIX = "_Texture"
local FRAME_SUFFIX = "_Frame"
local LABEL_SUFFIX = "_Label"
local SET_LABEL_SUFFIX = "_123"
local GLOW_SUFFIX = "_Glow"
local NAME_LABEL_SUFFIX = "_NameLabel"
local BAR_BG_SUFFIX = "_BarBG"
local BAR_FILL_SUFFIX = "_BarFill"

local UI_WIDTH = 340
local UI_HEIGHT = 76
local ICON_SIZE = 64
local ICON_OFFSET_X = 36
local BAR_WIDTH = 232
local BAR_HEIGHT = 20
local BAR_OFFSET_X = 94
local BAR_OFFSET_Y = 14

local function GetControl(setKey, suffix)
    return WM:GetControlByName(setKey .. suffix)
end

local function GetStyleTable()
    local style = PvPCooldownTracker.preferences.style
    if type(style) ~= "table" then
        return nil
    end
    return style
end

local function ApplySetLabelStyle(setLabel)
    local style = GetStyleTable()
    local color = (style and style.labelColor) or { 1, 1, 1, 1 }
    setLabel:SetColor(color[1], color[2], color[3], color[4])
    setLabel:SetFont(PvPCooldownTracker.preferences.labelFont or "$(BOLD_FONT)|18|soft-shadow-thick")
    setLabel:SetHorizontalAlignment(CENTER)
    setLabel:SetVerticalAlignment(TOP)
    setLabel:SetPixelRoundingEnabled(true)
    setLabel:SetScale(PvPCooldownTracker.preferences.labelSize)
end

local function ApplyNameLabelStyle(nameLabel)
    local style = GetStyleTable()
    local color = (style and style.labelColor) or { 1, 1, 1, 1 }
    nameLabel:SetColor(color[1], color[2], color[3], color[4])
    nameLabel:SetFont(PvPCooldownTracker.preferences.labelFont or "$(BOLD_FONT)|18|soft-shadow-thick")
    nameLabel:SetHorizontalAlignment(LEFT)
    nameLabel:SetVerticalAlignment(CENTER)
    nameLabel:SetPixelRoundingEnabled(true)
end

local function ApplyTimerLabelStyle(label)
    local style = GetStyleTable()
    local color = (style and style.timerColor) or { 1, 1, 1, 1 }
    label:SetColor(color[1], color[2], color[3], color[4])
    label:SetFont(PvPCooldownTracker.preferences.timerFont or "$(BOLD_FONT)|22|soft-shadow-thick")
    label:SetVerticalAlignment(TOP)
    label:SetHorizontalAlignment(RIGHT)
    label:SetPixelRoundingEnabled(true)
end

local function SnapToGrid(position, gridSize)
    -- Round down
    position = math.floor(position)

    -- Return value to closest grid point
    if (position % gridSize >= gridSize / 2) then
        return position + (gridSize - (position % gridSize))
    else
        return position - (position % gridSize)
    end
end
local function SetPosition(key, container, left, top)
    PvPCooldownTracker:Trace(2, "Setting - Left: " .. left .. " Top: " .. top)
    local context = GetControl(key, container)
    if context == nil then return end
    context:ClearAnchors()
    context:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

local function SavePosition(key)
    local context = GetControl(key, CONTAINER_SUFFIX)
    if context == nil then return end
    local top   = context:GetTop()
    local left  = context:GetLeft()

    if PvPCooldownTracker.preferences.snapToGrid then
        local gridSize = PvPCooldownTracker.preferences.gridSize
        top = SnapToGrid(top, gridSize)
        left = SnapToGrid(left, gridSize)
        SetPosition(key, CONTAINER_SUFFIX, left, top)
    end

    PvPCooldownTracker:Trace(2, "Saving position for <<1>> - Left: <<2>> Top: <<3>>", key, left, top)

    if PvPCooldownTracker.preferences.sets[key] then
        PvPCooldownTracker.preferences.sets[key].x = left
        PvPCooldownTracker.preferences.sets[key].y = top
    end
end

local function EnsureSetControls(key, set, saved)
    local container = GetControl(key, CONTAINER_SUFFIX)
    if container == nil then
        container = WM:CreateTopLevelWindow(key .. CONTAINER_SUFFIX)
        container:SetHandler("OnMoveStop", function() SavePosition(key) end)
    end

    container:SetClampedToScreen(true)
    container:SetDimensions(UI_WIDTH, UI_HEIGHT)
    container:SetMouseEnabled(true)
    container:SetMovable(PvPCooldownTracker.preferences.unlocked)
    container:SetAlpha(1)
    container:SetScale(saved.size / scaleBase)
    container:SetHidden(PvPCooldownTracker.HUDHidden and not PvPCooldownTracker.ForceShow)

    local texture = GetControl(key, TEXTURE_SUFFIX)
    if texture == nil then
        texture = WM:CreateControl(key .. TEXTURE_SUFFIX, container, CT_TEXTURE)
    end
    texture:SetTexture(set.texture)
    texture:SetDimensions(ICON_SIZE, ICON_SIZE)
    texture:SetAnchor(LEFT, container, LEFT, ICON_OFFSET_X, 0)

    local glow = GetControl(key, GLOW_SUFFIX)
    if glow == nil then
        glow = WM:CreateControl(key .. GLOW_SUFFIX, container, CT_TEXTURE)
    end
    glow:SetTexture("/esoui/art/actionbar/abilityhighlight_round.dds")
    glow:SetDimensions(ICON_SIZE + 24, ICON_SIZE + 24)
    glow:SetAnchor(CENTER, texture, CENTER, 0, 0)
    local style = GetStyleTable()
    local glowColor = (style and style.glowColor) or { 0.92, 0.40, 0.18, 0.45 }
    glow:SetColor(glowColor[1], glowColor[2], glowColor[3], glowColor[4])
    glow:SetAlpha(0.15)

    local frame = GetControl(key, FRAME_SUFFIX)
    if set.showFrame then
        if frame == nil then
            frame = WM:CreateControl(key .. FRAME_SUFFIX, container, CT_TEXTURE)
        end

        if set.procType == "passive" then
            frame:SetTexture("/esoui/art/actionbar/passiveabilityframe_round_up.dds")
            frame:SetDimensions(ICON_SIZE + 5, ICON_SIZE + 5)
        else
            frame:SetTexture("/esoui/art/actionbar/gamepad/gp_abilityframe64.dds")
            frame:SetDimensions(ICON_SIZE, ICON_SIZE)
        end

        frame:SetAnchor(CENTER, texture, CENTER, 0, 0)
        frame:SetHidden(false)
    elseif frame ~= nil then
        frame:SetHidden(true)
    end

    local barBg = GetControl(key, BAR_BG_SUFFIX)
    if barBg == nil then
        barBg = WM:CreateControl(key .. BAR_BG_SUFFIX, container, CT_BACKDROP)
    end
    barBg:SetDimensions(BAR_WIDTH, BAR_HEIGHT)
    barBg:SetAnchor(TOPLEFT, container, TOPLEFT, BAR_OFFSET_X, BAR_OFFSET_Y)
    barBg:SetEdgeTexture(nil, 1, 1, 1)
    barBg:SetEdgeColor(0.45, 0.45, 0.45, 0.9)
    local style = GetStyleTable()
    local barBackground = (style and style.barBackgroundColor) or { 0.08, 0.08, 0.08, 0.80 }
    barBg:SetCenterColor(barBackground[1], barBackground[2], barBackground[3], barBackground[4])

    local barFill = GetControl(key, BAR_FILL_SUFFIX)
    if barFill == nil then
        barFill = WM:CreateControl(key .. BAR_FILL_SUFFIX, barBg, CT_STATUSBAR)
    end
    barFill:SetAnchor(TOPLEFT, barBg, TOPLEFT, 2, 2)
    barFill:SetAnchor(BOTTOMRIGHT, barBg, BOTTOMRIGHT, -2, -2)
    barFill:SetTexture("/esoui/art/miscellaneous/progressbar_genericfill.dds")
    barFill:SetMinMax(0, 1)
    barFill:SetValue(1)
    local readyColor = (style and style.barReadyColor) or { 0.42, 0.72, 0.24, 0.95 }
    barFill:SetColor(readyColor[1], readyColor[2], readyColor[3], readyColor[4])

    local timerLabel = GetControl(key, LABEL_SUFFIX)
    if timerLabel == nil then
        timerLabel = WM:CreateControl(key .. LABEL_SUFFIX, container, CT_LABEL)
    end
    timerLabel:SetAnchor(RIGHT, barBg, RIGHT, -6, 0)
    ApplyTimerLabelStyle(timerLabel)

    local nameLabel = GetControl(key, NAME_LABEL_SUFFIX)
    if nameLabel == nil then
        nameLabel = WM:CreateControl(key .. NAME_LABEL_SUFFIX, container, CT_LABEL)
    end
    nameLabel:SetAnchor(BOTTOMLEFT, barBg, TOPLEFT, 2, -2)
    nameLabel:SetDimensions(BAR_WIDTH - 8, 20)
    ApplyNameLabelStyle(nameLabel)
    nameLabel:SetText(tostring(key))

    local setLabel = GetControl(key, SET_LABEL_SUFFIX)
    if setLabel == nil then
        setLabel = WM:CreateControl(key .. SET_LABEL_SUFFIX, container, CT_LABEL)
    end
    setLabel:SetAnchor(CENTER, container, CENTER, PvPCooldownTracker.preferences.LabelLocation.x, PvPCooldownTracker.preferences.LabelLocation.y)
    ApplySetLabelStyle(setLabel)

    SetPosition(key, CONTAINER_SUFFIX, saved.x, saved.y)

    return container
end

function PvPCooldownTracker.UI.Draw(key)
    local set = PvPCooldownTracker.Data.Sets[key]
    if set == nil then return end

    local container = GetControl(key, CONTAINER_SUFFIX)
    if set.enabled then
        local saved = PvPCooldownTracker.preferences.sets[key]
        if saved == nil then return end

        PvPCooldownTracker:Trace(2, "Drawing: <<1>>", key)
        container = EnsureSetControls(key, set, saved)

        if container and not PvPCooldownTracker.HUDHidden then
            container:SetHidden(false)
        end
    elseif container ~= nil then
        container:SetHidden(true)
    end

    PvPCooldownTracker:Trace(2, "Finished DrawUI()")
end

function PvPCooldownTracker.UI:SetCombatStateDisplay()
    PvPCooldownTracker:Trace(3, "Setting combat state display, in combat: <<1>>", tostring(PvPCooldownTracker.isInCombat))

    if PvPCooldownTracker.isInCombat or PvPCooldownTracker.preferences.showOutsideCombat and not PvPCooldownTracker.isDead then
        PvPCooldownTracker.UI.ShowIcon(true)
    else
        PvPCooldownTracker.UI.ShowIcon(false)
    end
end

function PvPCooldownTracker.UI.PlaySound(sound)
    if sound and sound.enabled then
        PlaySound(SOUNDS[sound.sound])
    end
end

local function PlayStatusAnimation(setKey, text)
    local container = GetControl(setKey, CONTAINER_SUFFIX)
    local setLabel = GetControl(setKey, SET_LABEL_SUFFIX)
    if not container or not setLabel then return end

    local pref = PvPCooldownTracker.preferences
    local animation = AM:CreateTimeline(true)
    local slide = animation:InsertAnimation(ANIMATION_TRANSLATE, setLabel, 0)
    local fade = animation:InsertAnimation(ANIMATION_ALPHA, setLabel, 200)

    slide:SetTranslateOffsets(pref.LabelLocation.x, pref.LabelLocation.y, pref.LabelLocation.x, pref.LabelLocation.y - 120)
    slide:SetDuration(900)
    slide:SetEasingFunction(ZO_EaseInCubic)

    fade:SetAlphaValues(1, 0)
    fade:SetDuration(900)
    fade:SetEasingFunction(ZO_EaseOutCubic)

    animation:SetHandler("OnPlay", function()
        setLabel:SetAlpha(1)
        setLabel:SetScale(pref.labelSize)
        setLabel:SetText(text)
    end)

    animation:SetHandler("OnStop", function()
        local set = PvPCooldownTracker.Data.Sets[setKey]
        if set and set.onCooldown then
            setLabel:SetText(string.format("|c%s%s|r", pref.set_active, setKey))
        else
            setLabel:SetText("")
        end

        setLabel:SetAlpha(1)
        setLabel:SetAnchor(CENTER, container, CENTER, pref.LabelLocation.x, pref.LabelLocation.y)
        setLabel:SetScale(pref.labelSize)
    end)

    animation:PlayFromStart()
end

function PvPCooldownTracker:SetAppearance(x, y, setKey)
    if setKey == nil then return end

    local saved = PvPCooldownTracker.preferences.sets[setKey]
    if saved == nil then return end

    PvPCooldownTracker:Trace(3, "Setting appearance for <<1>> X: <<2>> Y: <<3>>", setKey, x, y)

    local set = PvPCooldownTracker.Data.Sets[setKey]
    if not set then return end

    if set.enabled then
        EnsureSetControls(setKey, set, saved)
    end

    local container = GetControl(setKey, CONTAINER_SUFFIX)
    if container ~= nil then
        container:SetScale(saved.size / scaleBase)
        SetPosition(setKey, CONTAINER_SUFFIX, saved.x, saved.y)
    end

    local setLabel = GetControl(setKey, SET_LABEL_SUFFIX)
    if setLabel and container then
        ApplySetLabelStyle(setLabel)
        setLabel:SetAnchor(CENTER, container, CENTER, PvPCooldownTracker.preferences.LabelLocation.x, PvPCooldownTracker.preferences.LabelLocation.y)
    end

    local label = GetControl(setKey, LABEL_SUFFIX)
    if label then
        ApplyTimerLabelStyle(label)
    end

    local nameLabel = GetControl(setKey, NAME_LABEL_SUFFIX)
    if nameLabel then
        ApplyNameLabelStyle(nameLabel)
        nameLabel:SetText(tostring(setKey))
    end

    local barBg = GetControl(setKey, BAR_BG_SUFFIX)
    if barBg then
        local style = GetStyleTable()
        local bgColor = (style and style.barBackgroundColor) or { 0.08, 0.08, 0.08, 0.80 }
        barBg:SetCenterColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
    end

    PvPCooldownTracker:Trace(3, "SetAppearance complete")
end
function PvPCooldownTracker:Check_Cooldown(setKey)
    local set = PvPCooldownTracker.Data.Sets[setKey]
    return set ~= nil and set.onCooldown == true
end
function PvPCooldownTracker.UI.Update(setKey)
    local set = PvPCooldownTracker.Data.Sets[setKey]
    if not set then return end

    local saved = PvPCooldownTracker.preferences.sets[setKey]
    if not saved then return end

    if set.enabled then
        EnsureSetControls(setKey, set, saved)
    end

    local container = GetControl(setKey, CONTAINER_SUFFIX)
    local texture = GetControl(setKey, TEXTURE_SUFFIX)
    local label = GetControl(setKey, LABEL_SUFFIX)
    local setLabel = GetControl(setKey, SET_LABEL_SUFFIX)
    local nameLabel = GetControl(setKey, NAME_LABEL_SUFFIX)
    local barFill = GetControl(setKey, BAR_FILL_SUFFIX)
    local glow = GetControl(setKey, GLOW_SUFFIX)
    if not container or not texture or not label or not setLabel then return end
    local style = GetStyleTable()

    if nameLabel then
        nameLabel:SetText(tostring(setKey))
    end

    if PvPCooldownTracker.first_run[setKey] or set.justProcced then
        PvPCooldownTracker.first_run[setKey] = nil
        set.justProcced = false
        PlayStatusAnimation(setKey, string.format("|c%s%s Cooling Down|r", PvPCooldownTracker.preferences.set_active, setKey))
    end

    if not set.onCooldown then
        label:SetText("")
        setLabel:SetText("")
        texture:SetColor(1, 1, 1, 1)
        if barFill then
            local readyColor = (style and style.barReadyColor) or { 0.42, 0.72, 0.24, 0.95 }
            barFill:SetColor(readyColor[1], readyColor[2], readyColor[3], readyColor[4])
            barFill:SetValue(1)
        end
        if glow then
            glow:SetAlpha(0.15)
        end
        return
    end

    local cooldownTint = (style and style.cooldownTint) or { 0.55, 0.48, 0.48, 1.0 }
    texture:SetTexture(set.texture)
    texture:SetColor(cooldownTint[1], cooldownTint[2], cooldownTint[3], cooldownTint[4])
    if glow then
        glow:SetAlpha(0.42)
    end

    local countdown = (set.timeOfProc + set.cooldownDurationMs - GetGameTimeMilliseconds()) / 1000
    if countdown <= 0 then
        set.onCooldown = false
        EVENT_MANAGER:UnregisterForUpdate(PvPCooldownTracker.name .. setKey .. "Count")
        label:SetText("")
        texture:SetColor(1, 1, 1, 1)
        if barFill then
            local readyColor = (style and style.barReadyColor) or { 0.42, 0.72, 0.24, 0.95 }
            barFill:SetColor(readyColor[1], readyColor[2], readyColor[3], readyColor[4])
            barFill:SetValue(1)
        end
        if glow then
            glow:SetAlpha(0.20)
        end

        PlayStatusAnimation(setKey, string.format("|c%s%s Ready!|r", PvPCooldownTracker.preferences.cooldown_expired, setKey))
        PvPCooldownTracker.UI.PlaySound(PvPCooldownTracker.preferences.sets[setKey].sounds.onReady)
        return
    end

    local countdownText
    if countdown < 10 then
        countdownText = string.format("%.1f", countdown)
    else
        countdownText = tostring(math.floor(countdown + 0.5))
    end

    label:SetText(countdownText)
    setLabel:SetText("")

    if barFill then
        local durationSeconds = math.max(0.1, set.cooldownDurationMs / 1000)
        local progress = countdown / durationSeconds
        progress = math.max(0, math.min(1, progress))
        local barColor = (style and style.barFillColor) or { 0.84, 0.46, 0.20, 0.95 }
        barFill:SetColor(barColor[1], barColor[2], barColor[3], barColor[4])
        barFill:SetValue(progress)
    end

end

function PvPCooldownTracker.UI.ToggleHUD()
    local hudScene = SCENE_MANAGER:GetScene("hud")
    hudScene:RegisterCallback("StateChange", function(oldState, newState)

        -- Don't change states if display should be forced to show
        if PvPCooldownTracker.ForceShow then return end

        -- Transitioning to a menu/non-HUD
        if newState == SCENE_HIDDEN and SCENE_MANAGER:GetNextScene():GetName() ~= "hudui" then
            PvPCooldownTracker:Trace(3, "Hiding HUD")
            PvPCooldownTracker.HUDHidden = true
            PvPCooldownTracker.UI:SetCombatStateDisplay()
        end

        -- Transitioning to a HUD/non-menu
        if newState == SCENE_SHOWING then
            PvPCooldownTracker:Trace(3, "Showing HUD")
            PvPCooldownTracker.HUDHidden = false
            PvPCooldownTracker.UI:SetCombatStateDisplay()
        end
    end)

    PvPCooldownTracker:Trace(2, "Finished ToggleHUD()")
end

function PvPCooldownTracker.UI.ShowIcon(shouldShow)

    for key, set in pairs(PvPCooldownTracker.Data.Sets) do
        local context = WM:GetControlByName(key .. "_Container")
        if context ~= nil then
            if PvPCooldownTracker.ForceShow and set.enabled then
                context:SetHidden(false)
            elseif (shouldShow and set.enabled and not PvPCooldownTracker.HUDHidden) then
                context:SetHidden(false)
            else
                context:SetHidden(true)
            end
        end
    end

end

function PvPCooldownTracker.UI.SlashCommand(command)
    -- Debug Options ----------------------------------------------------------
    if command == "debug 0" then
        d(PvPCooldownTracker.prefix .. "Setting debug level to 0 (Off)")
        PvPCooldownTracker.debugMode = 0
        PvPCooldownTracker.preferences.debugMode = 0
    elseif command == "debug 1" then
        d(PvPCooldownTracker.prefix .. "Setting debug level to 1 (Low)")
        PvPCooldownTracker.debugMode = 1
        PvPCooldownTracker.preferences.debugMode = 1
    elseif command == "debug 2" then
        d(PvPCooldownTracker.prefix .. "Setting debug level to 2 (Medium)")
        PvPCooldownTracker.debugMode = 2
        PvPCooldownTracker.preferences.debugMode = 2
    elseif command == "debug 3" then
        d(PvPCooldownTracker.prefix .. "Setting debug level to 3 (High)")
        PvPCooldownTracker.debugMode = 3
        PvPCooldownTracker.preferences.debugMode = 3

    -- Unfiltered Events
    elseif command == "all on" then
        d(PvPCooldownTracker.prefix .. "Registering unfiltered events, setting debug mode to 1")
        PvPCooldownTracker.debugMode = 1
        PvPCooldownTracker.preferences.debugMode = 1
        PvPCooldownTracker.Tracking.RegisterUnfiltered()
    elseif command == "all off" then
        d(PvPCooldownTracker.prefix .. "Unregistering unfiltered events, setting debug mode to 0")
        PvPCooldownTracker.Tracking.UnregisterUnfiltered()
        PvPCooldownTracker.debugMode = 0
        PvPCooldownTracker.preferences.debugMode = 0

    -- Default ----------------------------------------------------------------
    else
        d(PvPCooldownTracker.prefix .. "Command not recognized!")
    end
end
