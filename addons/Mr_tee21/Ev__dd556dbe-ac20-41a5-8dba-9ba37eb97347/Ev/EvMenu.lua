-- Ev LAM menu (position, scale, opacity, font + active colors + tracking toggles + debug + master enable)
local EV = Ev

function Ev.setupMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "Ev",
        displayName = "Ev — Echoing Vigor / Radiating Regeneration",
        author = "mr_tee21",
        version = EV.version,
        registerForRefresh = true,
    }
    LAM:RegisterAddonPanel("EvOptions", panelData)

    local SV = EV.savedVars

    local function clampAndApply()
        Ev.clampOffsets()
        Ev.adjustFrameLocation()
        Ev.applyLabelFontIfNeeded()
        Ev.updateUi()
    end

    local faceChoicesNames  = { "Chat (Default)", "Univers 67 (Bold)", "ProseAntique (Book)" }
    local faceChoicesValues = { "$(CHAT_FONT)", "EsoUI/Common/Fonts/univers67.otf", "EsoUI/Common/Fonts/ProseAntiquePSMT.otf" }
    local outlineNames = { "None", "Soft Thin", "Soft Thick", "Outline", "Thick Outline" }
    local outlineVals  = { "", "soft-shadow-thin", "soft-shadow-thick", "outline", "thick-outline" }

    -- Compute numeric slider bounds once (console needs numbers, not functions)
    local s  = SV.scale or 1
    local xMax = math.max(0, math.floor(GuiRoot:GetWidth()  - (242 * s)))
    local yMax = math.max(0, math.floor(GuiRoot:GetHeight() - (180 * s)))

    local options = {
        { type = "header", name = "General" },

        { type = "checkbox", name = "Enable Ev",
          tooltip = "Master switch: turn the addon on/off.",
          getFunc = function() return SV.enabled end,
          setFunc = function(v) SV.enabled = not not v; Ev.applyEnabledToggle() end,
          width = "full" },

        { type = "header", name = "Frame Position" },

        { type = "slider", name = "X Offset", min = 0, max = xMax, step = 1,
          getFunc = function() return SV.offsetX end,
          setFunc = function(v) SV.offsetX = tonumber(v) or SV.offsetX; clampAndApply() end,
          width = "full" },

        { type = "slider", name = "Y Offset", min = 0, max = yMax, step = 1,
          getFunc = function() return SV.offsetY end,
          setFunc = function(v) SV.offsetY = tonumber(v) or SV.offsetY; clampAndApply() end,
          width = "full" },

        { type = "button", name = "Center on Screen",
          func = function()
              local s2 = SV.scale or 1
              SV.offsetX = math.floor((GuiRoot:GetWidth()  - (242 * s2)) / 2)
              SV.offsetY = math.floor((GuiRoot:GetHeight() - (180 * s2)) / 2)
              clampAndApply()
          end, width = "half" },

        { type = "button", name = "Reset to Defaults",
          func = function()
              for k,v in pairs({
                  enabled = true,
                  offsetX = 500, offsetY = 500, scale = 1.0, alpha = 1.0,
                  labelFontFace = "$(CHAT_FONT)",
                  labelFontSize = 14,
                  labelFontOutline = "soft-shadow-thin",
                  activeEvColor = {0.00, 0.69, 0.00, 0.90},
                  activeRrColor = {0.00, 0.69, 0.00, 0.90},
                  trackEV = true,
                  trackRR = true,
                  debugPrint = false,
              }) do SV[k] = v end
              Ev.applyEnabledToggle()
              clampAndApply()
          end, width = "half" },

        { type = "header", name = "Appearance" },

        { type = "slider", name = "Scale", tooltip = "Resize the frame.",
          min = 0.5, max = 2.0, step = 0.05,
          getFunc = function() return SV.scale end,
          setFunc = function(v)
              SV.scale = tonumber(string.format("%.2f", v)) or SV.scale
              clampAndApply()
              -- NOTE: X/Y slider max values are computed once; after changing scale,
              -- use the Center button or /reloadui to rebuild bounds if needed.
          end,
          width = "full" },

        { type = "slider", name = "Opacity", tooltip = "Overall bar opacity.",
          min = 0.2, max = 1.0, step = 0.05,
          getFunc = function() return SV.alpha end,
          setFunc = function(v) SV.alpha = tonumber(string.format("%.2f", v)) or SV.alpha; Ev.updateUi() end,
          width = "full" },

        { type = "dropdown", name = "Label Font Face",
          choices = faceChoicesNames, choicesValues = faceChoicesValues,
          getFunc = function() return SV.labelFontFace end,
          setFunc = function(v) SV.labelFontFace = v; Ev.applyLabelFontIfNeeded() end,
          width = "full" },

        { type = "slider", name = "Label Font Size",
          min = 10, max = 24, step = 1,
          getFunc = function() return SV.labelFontSize end,
          setFunc = function(v) SV.labelFontSize = math.floor(tonumber(v) or SV.labelFontSize); Ev.applyLabelFontIfNeeded() end,
          width = "full" },

        { type = "dropdown", name = "Label Outline",
          choices = outlineNames, choicesValues = outlineVals,
          getFunc = function() return SV.labelFontOutline end,
          setFunc = function(v) SV.labelFontOutline = v; Ev.applyLabelFontIfNeeded() end,
          width = "full" },

        { type = "header", name = "Colors" },

        { type = "colorpicker", name = "EV Active Color (Bottom lane)", hasAlpha = true,
          getFunc = function() local c = SV.activeEvColor or {0,1,0,0.9}; return c[1], c[2], c[3], c[4] end,
          setFunc = function(r,g,b,a) SV.activeEvColor = {r,g,b,a or 1}; Ev.updateUi() end,
          width = "full" },

        { type = "colorpicker", name = "RR Active Color (Top lane)", hasAlpha = true,
          getFunc = function() local c = SV.activeRrColor or {0,1,0,0.9}; return c[1], c[2], c[3], c[4] end,
          setFunc = function(r,g,b,a) SV.activeRrColor = {r,g,b,a or 1}; Ev.updateUi() end,
          width = "full" },

        { type = "header", name = "Tracking" },

        { type = "checkbox", name = "Track Echoing Vigor (EV)",
          tooltip = "Enable or disable EV tracking (bottom lane).",
          getFunc = function() return SV.trackEV end,
          setFunc = function(v) SV.trackEV = not not v; Ev.applyTrackingToggles() end,
          width = "full" },

        { type = "checkbox", name = "Track Radiating Regeneration (RR)",
          tooltip = "Enable or disable RR tracking (top lane).",
          getFunc = function() return SV.trackRR end,
          setFunc = function(v) SV.trackRR = not not v; Ev.applyTrackingToggles() end,
          width = "full" },

        { type = "header", name = "Debug" },

        { type = "checkbox", name = "Print Effect IDs (your casts)",
          tooltip = "When you gain a timed effect from your own casts, print its ability ID, name, duration, and target to chat.",
          getFunc = function() return SV.debugPrint end,
          setFunc = function(v) SV.debugPrint = not not v; Ev.applyDebugToggle() end,
          width = "full" },
    }

    LAM:RegisterOptionControls("EvOptions", options)
end