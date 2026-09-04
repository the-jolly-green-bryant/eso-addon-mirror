local Menu = Chorus.Menu
local S = Chorus.Strings
function Menu.Init(sv, hooks)
    local LAM = _G.LibAddonMenu2
    if not LAM or not LAM.RegisterAddonPanel then return false end
    local D = Chorus.Settings.defaults
    local function color(key, label)
        return { type = "colorpicker", name = S.Get(label),
            getFunc = function() local c = sv.colors[key]; return c[1], c[2], c[3] end,
            setFunc = function(r, g, b) sv.colors[key] = { r, g, b } end,
            default = { r = D.colors[key][1], g = D.colors[key][2], b = D.colors[key][3] } }
    end
    local function checkbox(key, label, tip, after)
        return { type = "checkbox", name = S.Get(label), tooltip = tip and S.Get(tip) or nil, getFunc = function() return sv[key] end,
            setFunc = function(v) sv[key] = v; if after then after(v) end end, default = D[key] }
    end
    local function slider(key, label, tip, min, max, step)
        return { type = "slider", name = S.Get(label), tooltip = tip and S.Get(tip) or nil, min = min, max = max, step = step,
            getFunc = function() return sv[key] end, setFunc = function(v) sv[key] = v; hooks.apply() end, default = D[key] }
    end
    LAM:RegisterAddonPanel("ChorusOptions", { type = "panel", name = S.Get("TITLE"), displayName = "|cE8ECF0Chorus|r", author = "Alpay",
        version = Chorus.version, registerForRefresh = true, registerForDefaults = true })
    LAM:RegisterOptionControls("ChorusOptions", {
        { type = "header", name = S.Get("M_GENERAL") },
        { type = "button", name = function() return S.Get(sv.locked and "M_MOVE" or "M_MOVE_DONE") end, tooltip = S.Get("M_MOVE_T"),
          func = function(control)
              sv.locked = not sv.locked
              hooks.lock(sv.locked)

              if control and control.button and control.button.SetText then control.button:SetText(S.Get(sv.locked and "M_MOVE" or "M_MOVE_DONE")) end
              if LAM.util and LAM.util.RequestRefreshIfNeeded then LAM.util.RequestRefreshIfNeeded(control) end
          end },
        { type = "button", name = S.Get("M_RESET"), func = function() hooks.resetPosition() end },
        { type = "button", name = S.Get("M_PREVIEW"), func = function() hooks.preview() end },
        (function()
            local names, values = Chorus.Fonts.Choices()
            return { type = "dropdown", name = S.Get("M_FONT"), tooltip = S.Get("M_FONT_T"), choices = names, choicesValues = values, scrollable = true,
                getFunc = function() return sv.font end, setFunc = function(v) sv.font = v; hooks.apply() end, default = D.font }
        end)(),
        slider("lines", "M_LINES", nil, 3, 12, 1),
        slider("sizeMin", "M_SIZE_MIN", nil, 10, 30, 1),
        slider("sizeMax", "M_SIZE_MAX", nil, 16, 48, 1),
        slider("dwell", "M_DWELL", "M_DWELL_T", 400, 2500, 100),
        checkbox("includePets", "M_PETS"),
        checkbox("showHealing", "M_HEALING", "M_HEALING_T"),
        checkbox("showNames", "M_NAMES", "M_NAMES_T", function() hooks.apply() end),
        checkbox("critMark", "M_CRIT_MARK"),
        checkbox("summary", "M_SUMMARY", "M_SUMMARY_T"),
        color("text", "M_COLOR"),
        color("crit", "M_COLOR_CRIT"),
    })
    return true
end
