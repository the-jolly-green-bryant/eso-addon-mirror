ShoyruCrosshair = {}
ShoyruCrosshair.name    = "ShoyruCrosshair"
ShoyruCrosshair.version = "1.0"

local SC  = ShoyruCrosshair
local WM  = WINDOW_MANAGER
local LAM = LibStub("LibAddonMenu-2.0")

-- ---------------------------------------------------------------------------
-- Defaults
-- ---------------------------------------------------------------------------

local DEFAULT_PROFILE = {
    style              = "lines_dot",     -- "lines" | "dot" | "lines_dot"

    -- Lines
    lineLength         = 8,
    lineThickness      = 2,
    lineGap            = 4,
    lineColor          = { r = 1, g = 1, b = 1, a = 1 },

    -- Outline (drawn as a slightly-larger colored rect behind each fill)
    outlineEnabled     = true,
    outlineThickness   = 1,
    outlineColor       = { r = 0, g = 0, b = 0, a = 1 },

    -- Center dot
    dotShape           = "circle",        -- "circle" | "square"
    dotSize            = 2,
    dotColor           = { r = 1, g = 1, b = 1, a = 1 },
    dotUseOutline      = true,

    -- Visibility
    hideOnMenus        = true,
    hideOnDeath        = true,
    hideInNonCombat    = false,
}

local DEFAULTS = {
    profiles      = { ["Default"] = ZO_DeepTableCopy(DEFAULT_PROFILE) },
    activeProfile = "Default",
    testMode      = false,
    pendingName   = "",
}

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

local function MergeDefaults(target, source)
    for k, v in pairs(source) do
        if type(v) == "table" then
            if type(target[k]) ~= "table" then target[k] = {} end
            MergeDefaults(target[k], v)
        elseif target[k] == nil then
            target[k] = v
        end
    end
end

function SC:GetActiveProfile()
    local sv = self.sv
    local p  = sv.profiles[sv.activeProfile]
    if not p then
        -- Active profile was deleted externally; recreate Default.
        sv.profiles["Default"] = ZO_DeepTableCopy(DEFAULT_PROFILE)
        sv.activeProfile = "Default"
        p = sv.profiles["Default"]
    end
    MergeDefaults(p, DEFAULT_PROFILE)
    return p
end

function SC:GetProfileNames()
    local names = {}
    for name in pairs(self.sv.profiles) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

-- ---------------------------------------------------------------------------
-- Crosshair rendering
-- ---------------------------------------------------------------------------

local function MakeRect(parent, name, drawLayer)
    local t = WM:CreateControl(name, parent, CT_TEXTURE)
    t:SetDrawLayer(drawLayer or DL_OVERLAY)
    return t
end

function SC:BuildUI()
    if self.container then return end

    local c = WM:CreateTopLevelWindow("ShoyruCrosshairContainer")
    c:SetClampedToScreen(false)
    c:SetMouseEnabled(false)
    c:SetMovable(false)
    c:SetDrawTier(DT_HIGH)
    c:SetDrawLayer(DL_OVERLAY)
    c:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    c:SetDimensions(256, 256)
    self.container = c

    self.lines = {}
    for _, dir in ipairs({ "top", "bottom", "left", "right" }) do
        self.lines[dir] = {
            outline = MakeRect(c, "ShoyruCH_"..dir.."_outline", DL_BACKGROUND),
            fill    = MakeRect(c, "ShoyruCH_"..dir.."_fill",    DL_OVERLAY),
        }
    end

    self.dot = {
        outline = MakeRect(c, "ShoyruCH_dot_outline", DL_BACKGROUND),
        fill    = MakeRect(c, "ShoyruCH_dot_fill",    DL_OVERLAY),
    }
end

local function ApplyRect(ctrl, w, h, color, hidden)
    ctrl:SetDimensions(w, h)
    ctrl:SetColor(color.r, color.g, color.b, color.a or 1)
    ctrl:ClearAnchors()
end

function SC:Redraw()
    if not self.container then return end
    local p = self:GetActiveProfile()

    local showLines = (p.style == "lines" or p.style == "lines_dot")
    local showDot   = (p.style == "dot"   or p.style == "lines_dot")

    local L  = p.lineLength
    local T  = p.lineThickness
    local G  = p.lineGap
    local OT = (p.outlineEnabled and p.outlineThickness > 0) and p.outlineThickness or 0

    local lc = p.lineColor
    local oc = p.outlineColor

    -- Each arm of the cross: position the center of the line at distance
    -- (G + L/2) from screen center along its axis.
    local armOffset = G + L / 2

    -- Vertical lines (top / bottom): width = T, height = L
    local function placeVert(pair, yOffset)
        ApplyRect(pair.outline, T + 2*OT, L + 2*OT, oc)
        pair.outline:SetAnchor(CENTER, self.container, CENTER, 0, yOffset)
        pair.outline:SetHidden(not (showLines and OT > 0))

        ApplyRect(pair.fill, T, L, lc)
        pair.fill:SetAnchor(CENTER, self.container, CENTER, 0, yOffset)
        pair.fill:SetHidden(not showLines)
    end

    -- Horizontal lines (left / right): width = L, height = T
    local function placeHorz(pair, xOffset)
        ApplyRect(pair.outline, L + 2*OT, T + 2*OT, oc)
        pair.outline:SetAnchor(CENTER, self.container, CENTER, xOffset, 0)
        pair.outline:SetHidden(not (showLines and OT > 0))

        ApplyRect(pair.fill, L, T, lc)
        pair.fill:SetAnchor(CENTER, self.container, CENTER, xOffset, 0)
        pair.fill:SetHidden(not showLines)
    end

    placeVert(self.lines.top,    -armOffset)
    placeVert(self.lines.bottom,  armOffset)
    placeHorz(self.lines.left,   -armOffset)
    placeHorz(self.lines.right,   armOffset)

    -- Center dot. CT_TEXTURE renders as a rect by default; tinting a circular
    -- DDS gives a real circle when "circle" shape is selected.
    local dc       = p.dotColor
    local ds       = p.dotSize
    local dotOT    = (p.dotUseOutline and OT > 0) and OT or 0
    local dotTex   = (p.dotShape == "circle") and "ShoyruCrosshair/circle.dds" or ""

    self.dot.outline:SetTexture(dotTex)
    ApplyRect(self.dot.outline, ds + 2*dotOT, ds + 2*dotOT, oc)
    self.dot.outline:SetAnchor(CENTER, self.container, CENTER, 0, 0)
    self.dot.outline:SetHidden(not (showDot and dotOT > 0))

    self.dot.fill:SetTexture(dotTex)
    ApplyRect(self.dot.fill, ds, ds, dc)
    self.dot.fill:SetAnchor(CENTER, self.container, CENTER, 0, 0)
    self.dot.fill:SetHidden(not showDot)
end

-- ---------------------------------------------------------------------------
-- Visibility
-- ---------------------------------------------------------------------------

function SC:UpdateVisibility()
    if not self.container then return end
    local p = self:GetActiveProfile()

    -- Test mode and the open settings panel both force the crosshair visible
    -- so the user can see edits land in real time.
    if self.sv.testMode or self.settingsOpen then
        self.container:SetHidden(false)
        return
    end

    local hidden = false

    if p.hideOnMenus then
        local scene = SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene()
        local name  = scene and scene:GetName() or ""
        if name ~= "hud" and name ~= "hudui" then
            hidden = true
        end
    end

    if not hidden and p.hideOnDeath and IsUnitDead("player") then
        hidden = true
    end

    if not hidden and p.hideInNonCombat and not IsUnitInCombat("player") then
        hidden = true
    end

    self.container:SetHidden(hidden)
end

-- ---------------------------------------------------------------------------
-- Profile operations
-- ---------------------------------------------------------------------------

local function SanitizeName(name)
    if type(name) ~= "string" then return "" end
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    if #name > 32 then name = name:sub(1, 32) end
    return name
end

function SC:SwitchProfile(name)
    if not self.sv.profiles[name] then return end
    self.sv.activeProfile = name
    self:Redraw()
    self:UpdateVisibility()
end

function SC:SaveAsNew(name)
    name = SanitizeName(name)
    if name == "" or self.sv.profiles[name] then return false end
    self.sv.profiles[name] = ZO_DeepTableCopy(self:GetActiveProfile())
    self.sv.activeProfile  = name
    self:RefreshProfileDropdown()
    self:Redraw()
    return true
end

function SC:RenameActive(name)
    name = SanitizeName(name)
    local old = self.sv.activeProfile
    if name == "" or name == old or self.sv.profiles[name] then return false end
    self.sv.profiles[name] = self.sv.profiles[old]
    self.sv.profiles[old]  = nil
    self.sv.activeProfile  = name
    self:RefreshProfileDropdown()
    return true
end

function SC:DeleteActive()
    local name = self.sv.activeProfile
    if name == "Default" then
        -- Reset Default instead of deleting it so there's always one profile.
        self.sv.profiles["Default"] = ZO_DeepTableCopy(DEFAULT_PROFILE)
    else
        self.sv.profiles[name] = nil
        self.sv.activeProfile = "Default"
        if not self.sv.profiles["Default"] then
            self.sv.profiles["Default"] = ZO_DeepTableCopy(DEFAULT_PROFILE)
        end
    end
    self:RefreshProfileDropdown()
    self:Redraw()
end

function SC:ResetActive()
    self.sv.profiles[self.sv.activeProfile] = ZO_DeepTableCopy(DEFAULT_PROFILE)
    self:Redraw()
end

function SC:RefreshProfileDropdown()
    local widget = _G["ShoyruCrosshair_ProfileDropdown"]
    if widget and widget.UpdateChoices then
        local names = self:GetProfileNames()
        widget:UpdateChoices(names, names)
        if widget.UpdateValue then widget:UpdateValue() end
    end
end

-- ---------------------------------------------------------------------------
-- LAM panel
-- ---------------------------------------------------------------------------

local function pget(field) return function() return SC:GetActiveProfile()[field] end end
local function pset(field)
    return function(value)
        SC:GetActiveProfile()[field] = value
        SC:Redraw()
        SC:UpdateVisibility()
    end
end

local function colorGet(field)
    return function()
        local c = SC:GetActiveProfile()[field]
        return c.r, c.g, c.b, c.a or 1
    end
end
local function colorSet(field)
    return function(r, g, b, a)
        local c = SC:GetActiveProfile()[field]
        c.r, c.g, c.b, c.a = r, g, b, a
        SC:Redraw()
    end
end

function SC:BuildSettings()
    local panelData = {
        type                = "panel",
        name                = "Shoyru's Crosshair",
        displayName         = "Shoyru's Crosshair",
        author              = "Shoyru",
        version             = self.version,
        slashCommand        = "/crosshair",
        registerForRefresh  = true,
        registerForDefaults = true,
    }

    -- Disabled helpers — used to grey out sections that don't apply to the
    -- current style. LAM has no native "hide on condition", so we lean on
    -- disabled+tooltip as the consistent visual signal.
    local function linesUnused()
        return SC:GetActiveProfile().style == "dot"
    end
    local function dotUnused()
        return SC:GetActiveProfile().style == "lines"
    end
    local function outlineUnused()
        return not SC:GetActiveProfile().outlineEnabled
    end

    local options = {
        -- ---------- Style (first; drives what else is relevant) ----------
        {
            type = "header",
            name = "Crosshair style",
        },
        {
            type          = "dropdown",
            name          = "Type",
            tooltip       = "Choose which elements make up the crosshair. Other sections grey out when they don't apply.",
            choices       = { "Lines only", "Dot only", "Lines + Dot" },
            choicesValues = { "lines",       "dot",       "lines_dot" },
            getFunc       = pget("style"),
            setFunc       = pset("style"),
            width         = "full",
        },
        {
            type    = "checkbox",
            name    = "Test mode (force crosshair visible)",
            tooltip = "Keeps the crosshair drawn even in menus while you tune settings.",
            getFunc = function() return self.sv.testMode end,
            setFunc = function(v)
                self.sv.testMode = v
                self:UpdateVisibility()
            end,
            width   = "full",
        },

        -- ---------- Profile management ----------
        {
            type = "header",
            name = "Profile",
        },
        {
            type      = "dropdown",
            name      = "Active profile",
            tooltip   = "Switch between saved crosshair profiles.",
            choices   = self:GetProfileNames(),
            getFunc   = function() return self.sv.activeProfile end,
            setFunc   = function(v) self:SwitchProfile(v) end,
            reference = "ShoyruCrosshair_ProfileDropdown",
            width     = "full",
        },
        {
            type    = "editbox",
            name    = "Profile name (for save/rename below)",
            getFunc = function() return self.sv.pendingName or "" end,
            setFunc = function(v) self.sv.pendingName = v end,
            width   = "full",
        },
        {
            type    = "button",
            name    = "Save as new profile",
            tooltip = "Create a new profile with the name above, copying current settings.",
            func    = function()
                if self:SaveAsNew(self.sv.pendingName) then
                    self.sv.pendingName = ""
                end
            end,
            width   = "half",
        },
        {
            type    = "button",
            name    = "Rename current",
            tooltip = "Rename the active profile to the name above.",
            func    = function()
                if self:RenameActive(self.sv.pendingName) then
                    self.sv.pendingName = ""
                end
            end,
            width   = "half",
        },
        {
            type        = "button",
            name        = "Delete current profile",
            tooltip     = "Delete the active profile. Default is reset rather than removed.",
            func        = function() self:DeleteActive() end,
            warning     = "This cannot be undone.",
            isDangerous = true,
            width       = "half",
        },
        {
            type    = "button",
            name    = "Reset active to defaults",
            tooltip = "Reset every setting in the active profile to default values.",
            func    = function() self:ResetActive() end,
            warning = "Resets all settings for the active profile.",
            width   = "half",
        },

        -- ---------- Lines (greyed if style == "dot") ----------
        {
            type = "header",
            name = "Lines",
        },
        { type = "slider", name = "Length", min = 0, max = 40, step = 1,
          getFunc = pget("lineLength"), setFunc = pset("lineLength"),
          disabled = linesUnused, width = "full" },
        { type = "slider", name = "Thickness", min = 1, max = 10, step = 1,
          getFunc = pget("lineThickness"), setFunc = pset("lineThickness"),
          disabled = linesUnused, width = "full" },
        { type = "slider", name = "Gap from center", min = 0, max = 40, step = 1,
          getFunc = pget("lineGap"), setFunc = pset("lineGap"),
          disabled = linesUnused, width = "full" },
        { type = "colorpicker", name = "Line color",
          getFunc = colorGet("lineColor"), setFunc = colorSet("lineColor"),
          disabled = linesUnused, width = "half" },
        { type = "slider", name = "Line opacity", min = 0, max = 100, step = 5,
          getFunc = function() return math.floor((SC:GetActiveProfile().lineColor.a or 1) * 100 + 0.5) end,
          setFunc = function(v)
              SC:GetActiveProfile().lineColor.a = v / 100
              SC:Redraw()
          end,
          disabled = linesUnused, width = "half" },

        -- ---------- Outline / Border ----------
        {
            type = "header",
            name = "Outline / Border",
        },
        { type = "checkbox", name = "Enable outline",
          getFunc = pget("outlineEnabled"), setFunc = pset("outlineEnabled"),
          width = "full" },
        { type = "slider", name = "Outline thickness", min = 0, max = 6, step = 1,
          getFunc = pget("outlineThickness"), setFunc = pset("outlineThickness"),
          disabled = outlineUnused, width = "full" },
        { type = "colorpicker", name = "Outline color",
          getFunc = colorGet("outlineColor"), setFunc = colorSet("outlineColor"),
          disabled = outlineUnused, width = "half" },
        { type = "slider", name = "Outline opacity", min = 0, max = 100, step = 5,
          getFunc = function() return math.floor((SC:GetActiveProfile().outlineColor.a or 1) * 100 + 0.5) end,
          setFunc = function(v)
              SC:GetActiveProfile().outlineColor.a = v / 100
              SC:Redraw()
          end,
          disabled = outlineUnused, width = "half" },

        -- ---------- Center Dot (greyed if style == "lines") ----------
        {
            type = "header",
            name = "Center dot",
        },
        { type = "dropdown", name = "Dot shape",
          choices       = { "Round",  "Square" },
          choicesValues = { "circle", "square" },
          getFunc = pget("dotShape"), setFunc = pset("dotShape"),
          disabled = dotUnused, width = "full" },
        { type = "slider", name = "Size", min = 1, max = 64, step = 1,
          getFunc = pget("dotSize"), setFunc = pset("dotSize"),
          disabled = dotUnused, width = "full" },
        { type = "colorpicker", name = "Dot color",
          getFunc = colorGet("dotColor"), setFunc = colorSet("dotColor"),
          disabled = dotUnused, width = "half" },
        { type = "slider", name = "Dot opacity", min = 0, max = 100, step = 5,
          getFunc = function() return math.floor((SC:GetActiveProfile().dotColor.a or 1) * 100 + 0.5) end,
          setFunc = function(v)
              SC:GetActiveProfile().dotColor.a = v / 100
              SC:Redraw()
          end,
          disabled = dotUnused, width = "half" },
        { type = "checkbox", name = "Use outline on dot",
          getFunc = pget("dotUseOutline"), setFunc = pset("dotUseOutline"),
          disabled = function() return dotUnused() or outlineUnused() end,
          width = "full" },

        -- ---------- Visibility ----------
        {
            type = "header",
            name = "Visibility",
        },
        { type = "checkbox", name = "Hide when in menus / cursor mode",
          getFunc = pget("hideOnMenus"),  setFunc = pset("hideOnMenus"),  width = "full" },
        { type = "checkbox", name = "Hide while dead",
          getFunc = pget("hideOnDeath"),  setFunc = pset("hideOnDeath"),  width = "full" },
        { type = "checkbox", name = "Hide outside of combat",
          getFunc = pget("hideInNonCombat"), setFunc = pset("hideInNonCombat"), width = "full" },
    }

    self.lamPanel = LAM:RegisterAddonPanel("ShoyruCrosshairPanel", panelData)
    LAM:RegisterOptionControls("ShoyruCrosshairPanel", options)

    -- Force crosshair visible while user is in the settings panel.
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
        if panel == self.lamPanel then
            self.settingsOpen = true
            self:UpdateVisibility()
        end
    end)
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
        if panel == self.lamPanel then
            self.settingsOpen = false
            self:UpdateVisibility()
        end
    end)
end

-- ---------------------------------------------------------------------------
-- Bootstrap
-- ---------------------------------------------------------------------------

function SC:OnLoaded(addonName)
    if addonName ~= self.name then return end
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)

    self.sv = ZO_SavedVars:NewAccountWide("ShoyruCrosshairSavedVariables", 1, nil, DEFAULTS)

    -- Ensure every profile carries every default field (new fields added in
    -- future versions get filled in for existing saved profiles).
    for _, profile in pairs(self.sv.profiles) do
        MergeDefaults(profile, DEFAULT_PROFILE)
    end
    if not self.sv.profiles[self.sv.activeProfile] then
        self.sv.activeProfile = "Default"
    end

    self:BuildUI()
    self:BuildSettings()

    -- Hide the game's built-in reticle so only our custom crosshair is drawn.
    -- RETICLE re-shows it on most frames, so we re-hide on a short interval.
    if ZO_ReticleContainerReticle then
        ZO_ReticleContainerReticle:SetHidden(true)
        EVENT_MANAGER:RegisterForUpdate(self.name .. "_HideReticle", 100, function()
            if ZO_ReticleContainerReticle and not ZO_ReticleContainerReticle:IsHidden() then
                ZO_ReticleContainerReticle:SetHidden(true)
            end
        end)
    end

    -- Hook visibility-relevant state changes.
    local function vis() self:UpdateVisibility() end
    if SCENE_MANAGER and SCENE_MANAGER.RegisterCallback then
        SCENE_MANAGER:RegisterCallback("SceneStateChanged", vis)
    end
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ALIVE,         vis)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_DEAD,          vis)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE,  vis)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED,     vis)

    self:Redraw()
    self:UpdateVisibility()
end

EVENT_MANAGER:RegisterForEvent(SC.name, EVENT_ADD_ON_LOADED, function(_, name)
    SC:OnLoaded(name)
end)
