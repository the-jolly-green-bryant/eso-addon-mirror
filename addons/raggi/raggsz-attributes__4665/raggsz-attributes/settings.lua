local RA = RaggszAttributes
local LAM = LibAddonMenu2

local ATTR_NAMES = {
    health  = "Health",
    magicka = "Magicka",
    stamina = "Stamina",
}

-- Header + color picker per attribute.
local function attributeControls(attr)
    local key = attr.key
    return {
        {
            type = "header",
            name = ATTR_NAMES[key],
        },
        {
            type    = "colorpicker",
            name    = "Color",
            getFunc = function()
                local c = RA.sv[key].color
                return c.r, c.g, c.b, c.a
            end,
            setFunc = function(r, g, b, a)
                local c = RA.sv[key].color
                c.r, c.g, c.b, c.a = r, g, b, a
                RA.RefreshStyle()
            end,
            default = RA.defaults[key].color,
        },
    }
end

function RA.SetupSettings()
    LAM:RegisterAddonPanel("RaggszAttributesPanel", {
        type              = "panel",
        name              = "raggsz attributes",
        author            = "@raggsz",
        registerForRefresh  = true,
        registerForDefaults = true,
    })

    local handle = ZO_LinkHandler_CreateDisplayNameLink and ZO_LinkHandler_CreateDisplayNameLink("@raggsz") or "@raggsz"

    local options = {
        {
            type = "description",
            text = "Simplified attributes near your feet: subtle when healthy, standing out as they run low or in combat.",
        },
        {
            type = "description",
            text = "Donations welcome in-game to " .. handle .. " (NA).",
            enableLinks = true,
        },
        {
            type    = "checkbox",
            name    = "raggsz defaults",
            tooltip = "Apply the author's layout: dock above the action bar, a 42px gap, and lift overlapping prompts & buffs. On by default on the @raggsz account; enable it to adopt that setup.",
            getFunc = function() return RA.sv.raggszDefaults == true end,
            setFunc = function(v)
                RA.sv.raggszDefaults = v
                if v then RA.ApplyPreset() end
                RA.RefreshStyle()
            end,
            default = false,
        },
        {
            type    = "checkbox",
            name    = "Show number",
            tooltip = "Show the numeric value.",
            getFunc = function() return RA.sv.showNumber end,
            setFunc = function(v) RA.sv.showNumber = v RA.RefreshStyle() end,
            default = RA.defaults.showNumber,
        },
        {
            type    = "checkbox",
            name    = "Show bar",
            tooltip = "Show a thin flat bar beneath each number.",
            getFunc = function() return RA.sv.showBar end,
            setFunc = function(v) RA.sv.showBar = v RA.RefreshStyle() end,
            default = RA.defaults.showBar,
        },
        {
            type    = "slider",
            name    = "Bar width",
            tooltip = "Length of the bar in pixels.",
            min     = 40,
            max     = 400,
            step    = 5,
            getFunc = function() return RA.sv.barWidth end,
            setFunc = function(v) RA.sv.barWidth = v RA.RefreshStyle() end,
            default = RA.defaults.barWidth,
        },
        {
            type    = "slider",
            name    = "Bar thickness",
            tooltip = "Scales the height of the bar relative to its default.",
            min     = 50,
            max     = 400,
            step    = 10,
            getFunc = function() return zo_round(RA.sv.barThickness * 100) end,
            setFunc = function(v) RA.sv.barThickness = v / 100 RA.RefreshStyle() end,
            default = zo_round(RA.defaults.barThickness * 100),
        },
        {
            type    = "checkbox",
            name    = "Bar on top",
            tooltip = "Place the bar above the number instead of below it.",
            getFunc = function() return RA.sv.barOnTop end,
            setFunc = function(v) RA.sv.barOnTop = v RA.RefreshStyle() end,
            default = RA.defaults.barOnTop,
        },
        {
            type    = "checkbox",
            name    = "Show change arrow",
            tooltip = "Show an arrow beside a number while a regen or drain effect (HoT, DoT, recovery, drain) is active on it.",
            getFunc = function() return RA.sv.showRate end,
            setFunc = function(v) RA.sv.showRate = v RA.RefreshStyle() end,
            default = RA.defaults.showRate,
        },
        {
            type    = "checkbox",
            name    = "Smooth changes",
            tooltip = "Ease the bars and numbers toward new values. Drops are quick; a drop into low resource shows instantly.",
            getFunc = function() return RA.sv.animate end,
            setFunc = function(v) RA.sv.animate = v RA.RefreshStyle() end,
            default = RA.defaults.animate,
        },
        {
            type    = "slider",
            name    = "Resting intensity",
            tooltip = "How visible the numbers are at full and out of combat. They reach fully opaque by half, and are always full in combat.",
            min     = 0,
            max     = 100,
            step    = 5,
            getFunc = function() return zo_round(RA.sv.intensity * 100) end,
            setFunc = function(v) RA.sv.intensity = v / 100 RA.RefreshStyle() end,
            default = zo_round(RA.defaults.intensity * 100),
        },
        {
            type = "header",
            name = "Form bars",
        },
        {
            type    = "checkbox",
            name    = "Show form bars",
            tooltip = "Thin werewolf and mount bars beneath magicka and stamina, shown only while in that form.",
            getFunc = function() return RA.sv.showFormBars end,
            setFunc = function(v) RA.sv.showFormBars = v RA.RefreshStyle() end,
            default = RA.defaults.showFormBars,
        },
        {
            type    = "slider",
            name    = "Form bar thickness",
            tooltip = "Form bar height as a percent of its column's bar.",
            min     = 10,
            max     = 100,
            step    = 5,
            getFunc = function() return zo_round(RA.sv.formBarRatio * 100) end,
            setFunc = function(v) RA.sv.formBarRatio = v / 100 RA.RefreshStyle() end,
            default = zo_round(RA.defaults.formBarRatio * 100),
        },
        {
            type    = "colorpicker",
            name    = "Werewolf color",
            getFunc = function() local c = RA.sv.werewolf.color return c.r, c.g, c.b, c.a end,
            setFunc = function(r, g, b, a) local c = RA.sv.werewolf.color c.r, c.g, c.b, c.a = r, g, b, a RA.RefreshStyle() end,
            default = RA.defaults.werewolf.color,
        },
        {
            type    = "colorpicker",
            name    = "Mount color",
            getFunc = function() local c = RA.sv.mount.color return c.r, c.g, c.b, c.a end,
            setFunc = function(r, g, b, a) local c = RA.sv.mount.color c.r, c.g, c.b, c.a = r, g, b, a RA.RefreshStyle() end,
            default = RA.defaults.mount.color,
        },
        {
            type = "header",
            name = "Position",
        },
        {
            type    = "checkbox",
            name    = "Dock above action bar",
            tooltip = "Anchor the bars just above the action bar so they track it, instead of placing them at a fixed point on the screen.",
            getFunc = function() return RA.sv.dock end,
            setFunc = function(v) RA.sv.dock = v RA.RefreshStyle() end,
            default = RA.defaults.dock,
        },
        {
            type    = "slider",
            name    = "Dock gap",
            tooltip = "Pixels the bars clear the action bar's top. Raise it to clear a stacked back bar (e.g. ~90 for Fancy Action Bar+ showing both bars).",
            min     = 0,
            max     = 200,
            step    = 1,
            getFunc = function() return RA.sv.dockGap end,
            setFunc = function(v) RA.sv.dockGap = v RA.RefreshStyle() end,
            default = RA.defaults.dockGap,
            disabled = function() return not RA.sv.dock end,
        },
        {
            type    = "checkbox",
            name    = "Lift overlapping prompts & buffs",
            tooltip = "Move the game's bottom prompts (synergy, combat tips like 'hold to block') and the player buff bar up above the bars so they stop overlapping. Only applies while docked. Don't also move these in Azurah or the two will fight.",
            getFunc = function() return RA.sv.liftClutter end,
            setFunc = function(v) RA.sv.liftClutter = v RA.RefreshStyle() end,
            default = RA.defaults.liftClutter,
            disabled = function() return not RA.sv.dock end,
        },
        {
            type    = "checkbox",
            name    = "Unlock (drag with mouse)",
            tooltip = "Show a frame you can drag with the mouse. A cursor appears while unlocked; lock again when done. When docked, dragging sets the horizontal nudge and the gap.",
            getFunc = function() return RA.unlocked == true end,
            setFunc = function(v) RA.SetUnlocked(v) end,
            default = false,
        },
        {
            type    = "slider",
            name    = "Horizontal offset",
            tooltip = "Pixels right of screen center, or right of the dock target's center when docked.",
            min     = -960,
            max     = 960,
            step    = 1,
            getFunc = function() return RA.sv.offsetX end,
            setFunc = function(v) RA.sv.offsetX = v RA.RefreshStyle() end,
            default = RA.defaults.offsetX,
        },
        {
            type    = "slider",
            name    = "Vertical offset",
            tooltip = "Pixels below screen center. Ignored while docked (use Dock gap instead).",
            min     = -540,
            max     = 540,
            step    = 1,
            getFunc = function() return RA.sv.offsetY end,
            setFunc = function(v) RA.sv.offsetY = v RA.RefreshStyle() end,
            default = RA.defaults.offsetY,
            disabled = function() return RA.sv.dock end,
        },
        {
            type    = "slider",
            name    = "Spacing",
            tooltip = "Horizontal gap between the bars.",
            min     = 0,
            max     = 300,
            step    = 1,
            getFunc = function() return RA.sv.spacing end,
            setFunc = function(v) RA.sv.spacing = v RA.RefreshStyle() end,
            default = RA.defaults.spacing,
        },
    }
    for _, attr in ipairs(RA.ATTRIBUTES) do
        for _, control in ipairs(attributeControls(attr)) do
            options[#options + 1] = control
        end
    end

    LAM:RegisterOptionControls("RaggszAttributesPanel", options)
end
