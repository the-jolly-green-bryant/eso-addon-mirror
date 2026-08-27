local KDR = KDRTracker

-- Binding labels are always available, even if the shared settings library is not.
ZO_CreateStringId("SI_BINDING_NAME_KDR_TOGGLE_SETTINGS", "Open KDR HUD Editor")
ZO_CreateStringId("SI_BINDING_NAME_KDR_SCALE_UP", "Increase KDR HUD Scale")
ZO_CreateStringId("SI_BINDING_NAME_KDR_SCALE_DOWN", "Decrease KDR HUD Scale")
ZO_CreateStringId("SI_BINDING_NAME_KDR_BG_UP", "Increase KDR Background")
ZO_CreateStringId("SI_BINDING_NAME_KDR_BG_DOWN", "Decrease KDR Background")
ZO_CreateStringId("SI_BINDING_NAME_KDR_MOVE_LEFT", "Move KDR HUD Left")
ZO_CreateStringId("SI_BINDING_NAME_KDR_MOVE_RIGHT", "Move KDR HUD Right")
ZO_CreateStringId("SI_BINDING_NAME_KDR_MOVE_UP", "Move KDR HUD Up")
ZO_CreateStringId("SI_BINDING_NAME_KDR_MOVE_DOWN", "Move KDR HUD Down")
ZO_CreateStringId("SI_BINDING_NAME_KDR_RESET_SESSION", "Reset All KDR Stats")

local function Apply()
    if KDR and KDR.UpdateHUD then KDR:UpdateHUD() end
end

local function Restore()
    if KDR and KDR.RestorePosition then KDR:RestorePosition() end
end

function KDR:RegisterAddonSettings()
    local LHA = LibHarvensAddonSettings
    if not LHA then
        self.settingsRegistered = false
        return false
    end

    local panel = LHA:AddAddon("KDR Tracker", {
        allowDefaults = true,
        allowRefresh = true,
    })
    if not panel then
        self.settingsRegistered = false
        return false
    end

    local function Section(text)
        panel:AddSetting({ type = LHA.ST_SECTION, label = text })
    end

    self.settingsRegistered = true

    Section("HUD")

    panel:AddSetting({
        type = LHA.ST_CHECKBOX,
        label = "Show KDR HUD",
        default = true,
        getFunction = function() return KDR.sv.hudVisible end,
        setFunction = function(v) KDR.sv.hudVisible = v Apply() end,
    })

    panel:AddSetting({
        type = LHA.ST_SLIDER,
        label = "HUD Scale",
        min = 50, max = 350, step = 5, default = 100,
        unit = "%", format = "%d",
        getFunction = function() return zo_round((KDR.sv.hudScale or 1) * 100) end,
        setFunction = function(v) KDR.sv.hudScale = v / 100 Apply() end,
    })

    panel:AddSetting({
        type = LHA.ST_DROPDOWN,
        label = "Text Size",
        items = { "Small", "Medium", "Large" },
        default = "Medium",
        getFunction = function()
            return ({ "Small", "Medium", "Large" })[zo_clamp(KDR.sv.textSize or 2, 1, 3)]
        end,
        setFunction = function(v)
            KDR.sv.textSize = (v == "Small" and 1) or (v == "Large" and 3) or 2
            Apply()
        end,
    })

    panel:AddSetting({
        type = LHA.ST_SLIDER,
        label = "Background Opacity",
        min = 0, max = 100, step = 5, default = 0,
        unit = "%", format = "%d",
        getFunction = function() return zo_round((KDR.sv.hudAlpha or 0) * 100) end,
        setFunction = function(v) KDR.sv.hudAlpha = v / 100 Apply() end,
    })

    Section("Position")

    panel:AddSetting({
        type = LHA.ST_SLIDER,
        label = "Horizontal Position",
        min = -1600, max = 1600, step = 10, default = -55,
        getFunction = function() return zo_round(KDR.sv.hudX or -55) end,
        setFunction = function(v)
            KDR.sv.hudAnchor = TOPRIGHT
            KDR.sv.hudX = v
            Restore()
        end,
    })

    panel:AddSetting({
        type = LHA.ST_SLIDER,
        label = "Vertical Position",
        min = -1000, max = 1000, step = 10, default = 105,
        getFunction = function() return zo_round(KDR.sv.hudY or 105) end,
        setFunction = function(v)
            KDR.sv.hudAnchor = TOPRIGHT
            KDR.sv.hudY = v
            Restore()
        end,
    })

    Section("Colors")

    local function AddColor(label, field, defaultColor)
        if not LHA.ST_COLOR then return end
        panel:AddSetting({
            type = LHA.ST_COLOR,
            label = label,
            default = defaultColor,
            getFunction = function()
                local c = KDR.sv[field] or defaultColor
                return c[1], c[2], c[3], c[4] or 1
            end,
            setFunction = function(r,g,b,a)
                KDR.sv[field] = {r,g,b,a or 1}
                Apply()
            end,
        })
    end

    AddColor("Kills Color", "killsRGBA", {0.49,1.00,0.45,1})
    AddColor("Deaths Color", "deathsRGBA", {1.00,0.36,0.38,1})
    AddColor("Ratio Color", "ratioRGBA", {0.33,0.84,1.00,1})
    AddColor("Streak Color", "streakRGBA", {1.00,0.83,0.35,1})

    Section("Tracking")

    panel:AddSetting({
        type = LHA.ST_CHECKBOX,
        label = "Kill / Death Announcements",
        default = true,
        getFunction = function() return KDR.sv.announcements end,
        setFunction = function(v) KDR.sv.announcements = v end,
    })

    panel:AddSetting({
        type = LHA.ST_CHECKBOX,
        label = "PvP Only",
        default = true,
        getFunction = function() return KDR.sv.onlyPvP end,
        setFunction = function(v) KDR.sv.onlyPvP = v end,
    })

    if LHA.ST_BUTTON then
        panel:AddSetting({
            type = LHA.ST_BUTTON,
            label = "Reset All KDR Stats",
            tooltip = "Resets kills, deaths, ratio, current streak, best streak, and lifetime KDR statistics.",
            buttonText = "RESET STATS",
            clickHandler = function()
                KDR:ResetAllStats()
            end,
        })
    end

    return true
end

-- Standalone fallback editor model. It is used only when the common console
-- settings library is unavailable, preventing any UI error.
KDR.settingRows = {
    { id="scale", name="HUD Scale" },
    { id="text", name="Text Size" },
    { id="bg", name="Background Opacity" },
    { id="x", name="Horizontal Position" },
    { id="y", name="Vertical Position" },
    { id="kills", name="Kills Color" },
    { id="deaths", name="Deaths Color" },
    { id="ratio", name="Ratio Color" },
    { id="streak", name="Streak Color" },
    { id="show", name="HUD Visibility" },
}

function KDR:CyclePresetColor(field, delta)
    local current = self.sv[field] or 1
    current = current + delta
    if current < 1 then current = #self.palette end
    if current > #self.palette then current = 1 end
    self.sv[field] = current
    local c = self.palette[current]
    local rgbaField = ({
        killsColor="killsRGBA", deathsColor="deathsRGBA",
        ratioColor="ratioRGBA", streakColor="streakRGBA"
    })[field]
    if rgbaField then self.sv[rgbaField] = {c.r,c.g,c.b,1} end
end

function KDR:FallbackAdjust(id, delta)
    if id == "scale" then
        self.sv.hudScale = zo_clamp((self.sv.hudScale or 1) + 0.10*delta, 0.50, 3.50)
    elseif id == "text" then
        self.sv.textSize = zo_clamp((self.sv.textSize or 2) + delta, 1, 3)
    elseif id == "bg" then
        self.sv.hudAlpha = zo_clamp((self.sv.hudAlpha or 0) + 0.10*delta, 0, 1)
    elseif id == "x" then
        self:MoveHUD(10*delta, 0)
    elseif id == "y" then
        self:MoveHUD(0, 10*delta)
    elseif id == "kills" then
        self:CyclePresetColor("killsColor", delta)
    elseif id == "deaths" then
        self:CyclePresetColor("deathsColor", delta)
    elseif id == "ratio" then
        self:CyclePresetColor("ratioColor", delta)
    elseif id == "streak" then
        self:CyclePresetColor("streakColor", delta)
    elseif id == "show" then
        self.sv.hudVisible = not self.sv.hudVisible
    end
    Apply()
end

function KDR_TOGGLE_SETTINGS()
    if KDR and KDR.TryRegisterAddonSettings and KDR:TryRegisterAddonSettings() then
        d("KDR Tracker: Settings > Addons > KDR Tracker")
    else
        d("KDR Tracker: console Addons settings library is unavailable; use the KDR HUD control bindings.")
    end
end

function KDR_SCALE_UP() if KDR and KDR.sv then KDR.sv.hudScale=zo_clamp((KDR.sv.hudScale or 1)+0.10,0.50,3.50) Apply() end end
function KDR_SCALE_DOWN() if KDR and KDR.sv then KDR.sv.hudScale=zo_clamp((KDR.sv.hudScale or 1)-0.10,0.50,3.50) Apply() end end
function KDR_BG_UP() if KDR and KDR.sv then KDR.sv.hudAlpha=zo_clamp((KDR.sv.hudAlpha or 0)+0.10,0,1) Apply() end end
function KDR_BG_DOWN() if KDR and KDR.sv then KDR.sv.hudAlpha=zo_clamp((KDR.sv.hudAlpha or 0)-0.10,0,1) Apply() end end
function KDR_RESET_SESSION() if KDR then KDR:ResetAllStats() end end
function KDR_MOVE_LEFT() if KDR then KDR:MoveHUD(-10,0) end end
function KDR_MOVE_RIGHT() if KDR then KDR:MoveHUD(10,0) end end
function KDR_MOVE_UP() if KDR then KDR:MoveHUD(0,-10) end end
function KDR_MOVE_DOWN() if KDR then KDR:MoveHUD(0,10) end end
