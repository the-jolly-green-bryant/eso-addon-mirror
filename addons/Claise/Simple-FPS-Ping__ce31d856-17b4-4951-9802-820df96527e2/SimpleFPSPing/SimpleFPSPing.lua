-- ============================================================
--  Simple FPS & Ping  |  by Claise
--  Console-only overlay for PS5 and Xbox Series X|S.
--  Position and size controlled through the settings menu.
-- ============================================================

local ADDON_NAME    = "SimpleFPSPing"
local ADDON_VERSION = "1.0.4"

if not IsConsoleUI() then return end

local SCREEN_W = 1920
local SCREEN_H = 1080

local DEFAULTS = {
    posX         = 5,
    posY         = 1030,
    width        = 122,
    height       = 28,
    showInMenu   = false,
    updateRate   = 1,
    showFPS      = true,
    showPing     = true,
    fontSize     = 16,
    sideBySide   = true,
}

-- Slider ranges, shared by the settings menu and saved-var sanitizing
local LIMITS = {
    posX   = { min = 0,  max = SCREEN_W - 100 },
    posY   = { min = 0,  max = SCREEN_H - 50  },
    width  = { min = 50, max = 160 },
    height = { min = 24, max = 100 },
}

-- Baseline window sizes at font size 16; scaled up for larger fonts
local SNAP_SIZES = {
    sideBySide = { width = 122, height = 28 },
    stacked    = { width = 78,  height = 48 },
}

-- Explicit font strings with direct point sizes
local fontMap = {
    [16] = "EsoUI/Common/Fonts/Univers57.otf|16|soft-shadow-thick",
    [20] = "EsoUI/Common/Fonts/Univers57.otf|20|soft-shadow-thick",
    [22] = "EsoUI/Common/Fonts/Univers57.otf|22|soft-shadow-thick",
    [24] = "EsoUI/Common/Fonts/Univers57.otf|24|soft-shadow-thick",
    [28] = "EsoUI/Common/Fonts/Univers57.otf|28|soft-shadow-thick",
    [32] = "EsoUI/Common/Fonts/Univers57.otf|32|soft-shadow-thick",
}

-- Dropdown items must be {name, data} tables for LAS
local fontSizeItems = {
    { name = "Small (16)",   data = 16 },
    { name = "Normal (20)",  data = 20 },
    { name = "Medium (22)",  data = 22 },
    { name = "Large (24)",   data = 24 },
    { name = "X-Large (28)", data = 28 },
    { name = "Huge (32)",    data = 32 },
}

local SV
local overlay
local hudVisible = true  -- tracked via hud/hudui StateChange callbacks

-- ============================================================
--  HELPERS
-- ============================================================

local function ApplyPosition()
    overlay:ClearAnchors()
    overlay:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SV.posX, SV.posY)
end

local function ApplySize()
    overlay:SetDimensions(SV.width, SV.height)
end


local function ApplyFont()
    local font = fontMap[SV.fontSize] or "EsoUI/Common/Fonts/Univers57.otf|20|soft-shadow-thick"
    if overlay.fpsLabel  then overlay.fpsLabel:SetFont(font)  end
    if overlay.pingLabel then overlay.pingLabel:SetFont(font) end
end

-- Re-anchors the ping label to suit the chosen layout.
-- Stacked:      FPS on top, Ping below  — narrow tall window
-- Side by side: FPS left,  Ping right   — wide short window
local function ApplyLayout()
    if not overlay.fpsLabel or not overlay.pingLabel then return end

    if SV.sideBySide then
        overlay.fpsLabel:ClearAnchors()
        overlay.fpsLabel:SetAnchor(TOPLEFT, overlay, TOPLEFT, 4, 4)
        overlay.pingLabel:ClearAnchors()
        overlay.pingLabel:SetAnchor(LEFT, overlay.fpsLabel, RIGHT, 8, 0)
    else
        -- Second row offset scales with font size so the labels
        -- never overlap (3 + fontSize + 7 = 26 at the default 16)
        overlay.fpsLabel:ClearAnchors()
        overlay.fpsLabel:SetAnchor(TOPLEFT, overlay, TOPLEFT, 4, 3)
        overlay.pingLabel:ClearAnchors()
        overlay.pingLabel:SetAnchor(TOPLEFT, overlay, TOPLEFT, 4, 3 + SV.fontSize + 7)
    end
end

-- Snaps window size to a sensible preset for the current layout
-- and font size. Users can still fine-tune with the sliders after.
local function SnapSizeToLayout()
    local preset = SV.sideBySide and SNAP_SIZES.sideBySide or SNAP_SIZES.stacked
    local scale  = SV.fontSize / 16

    local function fit(value, limits)
        local v = zo_floor(value * scale / 2) * 2  -- keep to the slider's step of 2
        return zo_clamp(v, limits.min, limits.max)
    end

    SV.width  = fit(preset.width,  LIMITS.width)
    SV.height = fit(preset.height, LIMITS.height)
    ApplySize()
end

-- Single source of truth for whether the overlay should be visible:
-- hidden when both readouts are off, and hidden outside the HUD
-- unless "Show Window in This Menu" is enabled.
local function UpdateVisibility()
    if not overlay then return end
    local anyReadout = SV.showFPS or SV.showPing
    overlay:SetHidden(not anyReadout or not (hudVisible or SV.showInMenu))
end

-- Returns the font item name string for the current saved font size
local function GetCurrentFontName()
    for _, item in ipairs(fontSizeItems) do
        if item.data == SV.fontSize then return item.name end
    end
    return "Normal (20)"
end

-- Clamps saved values back into legal ranges in case the saved file
-- is from an older version or was corrupted.
local function SanitizeSavedVars()
    local function clampNumber(key, limits)
        if type(SV[key]) ~= "number" then
            SV[key] = DEFAULTS[key]
        else
            SV[key] = zo_clamp(SV[key], limits.min, limits.max)
        end
    end
    clampNumber("posX",   LIMITS.posX)
    clampNumber("posY",   LIMITS.posY)
    clampNumber("width",  LIMITS.width)
    clampNumber("height", LIMITS.height)

    if not fontMap[SV.fontSize] then
        SV.fontSize = DEFAULTS.fontSize
    end

    -- A zero/negative rate would run the update loop every frame
    if type(SV.updateRate) ~= "number" or SV.updateRate < 0.25 then
        SV.updateRate = DEFAULTS.updateRate
    end

    if type(SV.showFPS)    ~= "boolean" then SV.showFPS    = DEFAULTS.showFPS    end
    if type(SV.showPing)   ~= "boolean" then SV.showPing   = DEFAULTS.showPing   end
    if type(SV.showInMenu) ~= "boolean" then SV.showInMenu = DEFAULTS.showInMenu end
    if type(SV.sideBySide) ~= "boolean" then SV.sideBySide = DEFAULTS.sideBySide end
end

-- ============================================================
--  UPDATE LOOP
-- ============================================================

local function OnUpdate()
    if overlay:IsHidden() then return end

    if overlay.fpsLabel and not overlay.fpsLabel:IsHidden() then
        local fps = zo_floor(GetFramerate() or 0)
        local r, g, b = 0.2, 1, 0.4
        if   fps <= 29 then r, g, b = 1, 0.2, 0.2
        elseif fps <= 44 then r, g, b = 1, 0.85, 0.1
        end
        overlay.fpsLabel:SetColor(r, g, b, 1)
        overlay.fpsLabel:SetText(string.format("%d FPS", fps))
    end

    if overlay.pingLabel and not overlay.pingLabel:IsHidden() then
        local ping = GetLatency() or 0
        local r, g, b = 0.2, 1, 0.4
        if   ping > 200 then r, g, b = 1, 0.2, 0.2
        elseif ping > 150 then r, g, b = 1, 0.85, 0.1
        end
        overlay.pingLabel:SetColor(r, g, b, 1)
        overlay.pingLabel:SetText(string.format("%dms", ping))
    end
end

local function RegisterUpdateLoop()
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_Update")
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_Update", SV.updateRate * 1000, OnUpdate)
end

-- ============================================================
--  RESET
-- ============================================================

local function ResetToDefaults()
    for k, v in pairs(DEFAULTS) do SV[k] = v end
    ApplyPosition()
    ApplySize()
    ApplyFont()
    ApplyLayout()
    RegisterUpdateLoop()
    if overlay.fpsLabel  then overlay.fpsLabel:SetHidden(not SV.showFPS)   end
    if overlay.pingLabel then overlay.pingLabel:SetHidden(not SV.showPing) end
    UpdateVisibility()
end

-- ============================================================
--  OVERLAY CREATION
-- ============================================================

local function CreateOverlay()
    local wm = WINDOW_MANAGER

    overlay = wm:CreateTopLevelWindow(ADDON_NAME .. "_Overlay")
    overlay:SetDimensions(SV.width, SV.height)
    overlay:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SV.posX, SV.posY)
    overlay:SetMovable(false)
    overlay:SetMouseEnabled(false)
    overlay:SetClampedToScreen(true)
    overlay:SetHidden(false)

    local bg = wm:CreateControl(ADDON_NAME .. "_BG", overlay, CT_BACKDROP)
    bg:SetAnchorFill(overlay)
    bg:SetCenterColor(0, 0, 0, 0.50)  -- fixed 50% opacity background
    bg:SetEdgeColor(0, 0, 0, 0)
    bg:SetEdgeTexture("", 1, 1, 1)
    bg:SetInsets(0, 0, 0, 0)

    local fpsLabel = wm:CreateControl(ADDON_NAME .. "_FPS", overlay, CT_LABEL)
    fpsLabel:SetFont(fontMap[SV.fontSize] or "EsoUI/Common/Fonts/Univers57.otf|20|soft-shadow-thick")
    fpsLabel:SetColor(0.2, 1, 0.4, 1)
    fpsLabel:SetAnchor(TOPLEFT, overlay, TOPLEFT, 4, 3)
    fpsLabel:SetText("-- FPS")
    fpsLabel:SetHidden(not SV.showFPS)
    overlay.fpsLabel = fpsLabel

    local pingLabel = wm:CreateControl(ADDON_NAME .. "_Ping", overlay, CT_LABEL)
    pingLabel:SetFont(fontMap[SV.fontSize] or "EsoUI/Common/Fonts/Univers57.otf|20|soft-shadow-thick")
    pingLabel:SetColor(0.2, 1, 0.4, 1)
    pingLabel:SetAnchor(TOPLEFT, overlay, TOPLEFT, 4, 26)
    pingLabel:SetText("--ms")
    pingLabel:SetHidden(not SV.showPing)
    overlay.pingLabel = pingLabel
end

-- ============================================================
--  HUD VISIBILITY
-- ============================================================

local function SetupSceneHiding()
    -- Same state-driven approach as 1.0.3c (proven on console):
    -- the hud/hudui scenes tell us when the HUD appears/disappears.
    local function OnHudStateChange(oldState, newState)
        if newState == SCENE_SHOWN then
            hudVisible = true
        elseif newState == SCENE_HIDDEN then
            hudVisible = false
        else
            return  -- ignore transitional states (showing/hiding)
        end
        UpdateVisibility()
    end
    local hudScene   = SCENE_MANAGER:GetScene("hud")
    local huduiScene = SCENE_MANAGER:GetScene("hudui")
    if hudScene   then hudScene:RegisterCallback("StateChange",   OnHudStateChange) end
    if huduiScene then huduiScene:RegisterCallback("StateChange", OnHudStateChange) end
end

-- ============================================================
--  SETTINGS MENU
-- ============================================================

local function BuildSettingsMenu()
    local LAS = LibHarvensAddonSettings
    if not LAS then return end
    if type(LAS.AddAddon) ~= "function" then return end

    -- allowRefresh: documented option that re-reads getFunctions after
    -- a setting changes, so the size sliders update after a layout snap
    local settings = LAS:AddAddon("Simple FPS & Ping", { allowRefresh = true })
    if not settings then return end

    -- ── Visibility ──────────────────────────────────────────
    settings:AddSetting({ type = LAS.ST_SECTION, label = "Visibility" })
    settings:AddSetting({
        type        = LAS.ST_CHECKBOX,
        label       = "Show FPS",
        setFunction = function(v)
            SV.showFPS = v
            if overlay.fpsLabel then overlay.fpsLabel:SetHidden(not v) end
            UpdateVisibility()
        end,
        getFunction = function() return SV.showFPS end,
    })
    settings:AddSetting({
        type        = LAS.ST_CHECKBOX,
        label       = "Show Ping",
        setFunction = function(v)
            SV.showPing = v
            if overlay.pingLabel then overlay.pingLabel:SetHidden(not v) end
            UpdateVisibility()
        end,
        getFunction = function() return SV.showPing end,
    })
    settings:AddSetting({
        type        = LAS.ST_CHECKBOX,
        label       = "Show Window in This Menu",
        setFunction = function(v)
            SV.showInMenu = v
            UpdateVisibility()
        end,
        getFunction = function() return SV.showInMenu end,
    })

    -- ── Window Position ──────────────────────────────────────
    settings:AddSetting({ type = LAS.ST_SECTION, label = "Window Position" })
    settings:AddSetting({
        type        = LAS.ST_SLIDER,
        label       = "X Position",
        min         = LIMITS.posX.min,
        max         = LIMITS.posX.max,
        step        = 5,
        format      = "%d",
        setFunction = function(v) SV.posX = v ; ApplyPosition() end,
        getFunction = function() return SV.posX end,
    })
    settings:AddSetting({
        type        = LAS.ST_SLIDER,
        label       = "Y Position",
        min         = LIMITS.posY.min,
        max         = LIMITS.posY.max,
        step        = 5,
        format      = "%d",
        setFunction = function(v) SV.posY = v ; ApplyPosition() end,
        getFunction = function() return SV.posY end,
    })

    -- ── Window Size ──────────────────────────────────────────
    settings:AddSetting({ type = LAS.ST_SECTION, label = "Window Size" })
    settings:AddSetting({
        type        = LAS.ST_SLIDER,
        label       = "Width",
        min         = LIMITS.width.min,
        max         = LIMITS.width.max,
        step        = 2,
        format      = "%d",
        setFunction = function(v) SV.width = v ; ApplySize() end,
        getFunction = function() return SV.width end,
    })
    settings:AddSetting({
        type        = LAS.ST_SLIDER,
        label       = "Height",
        min         = LIMITS.height.min,
        max         = LIMITS.height.max,
        step        = 2,
        format      = "%d",
        setFunction = function(v) SV.height = v ; ApplySize() end,
        getFunction = function() return SV.height end,
    })

    -- ── Appearance ───────────────────────────────────────────
    settings:AddSetting({ type = LAS.ST_SECTION, label = "Appearance" })
    settings:AddSetting({
        type        = LAS.ST_CHECKBOX,
        label       = "Side by Side  (FPS | Ping)",
        setFunction = function(v)
            SV.sideBySide = v
            ApplyLayout()
            SnapSizeToLayout()
        end,
        getFunction = function() return SV.sideBySide end,
    })
    settings:AddSetting({
        type        = LAS.ST_DROPDOWN,
        label       = "Font Size",
        items       = fontSizeItems,
        -- setFunction receives (combobox, name, item) — use item.data for the size
        setFunction = function(combobox, name, item)
            SV.fontSize = item.data
            ApplyFont()
            ApplyLayout()
        end,
        getFunction = function() return GetCurrentFontName() end,
    })


    -- ── Reset ────────────────────────────────────────────────
    settings:AddSetting({
        type         = LAS.ST_BUTTON,
        label        = "Reset to Defaults",
        buttonText   = "Reset",
        clickHandler = ResetToDefaults,
    })
end

-- ============================================================
--  ADDON LOADED
-- ============================================================

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end

    SimpleFPSPingSV = SimpleFPSPingSV or {}
    SV = ZO_SavedVars:NewAccountWide("SimpleFPSPingSV", 8, nil, DEFAULTS)
    SanitizeSavedVars()

    CreateOverlay()
    ApplyFont()
    ApplyLayout()
    ApplySize()
    SetupSceneHiding()
    UpdateVisibility()

    local ok, err = pcall(BuildSettingsMenu)
    if not ok then SV.lastError = tostring(err) else SV.lastError = nil end

    RegisterUpdateLoop()
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
