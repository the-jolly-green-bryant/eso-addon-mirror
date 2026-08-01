AureoleRange_Settings = {}

-- Local references at top of file
local LAM = LibAddonMenu2
local AR  = AureoleRange

local function Apply()
    AR.pulseStartMs = GetGameTimeMilliseconds()
    AR.ApplyAll()
end

function AureoleRange_Settings.BuildMenu()
    if AureoleRange_Settings._built then return end
    AureoleRange_Settings._built = true

    local panelData = {
        type        = "panel",
        name        = GetString(SI_AR_ADDON_NAME),
        displayName = GetString(SI_AR_ADDON_NAME),
        author      = "Valeryi_Igorevich (@Valeryi_Igorevich EU | PC)",
        version     = "6.5.2",
    }

    local panelId = "AureoleRangePanel"
    local panel   = LAM:RegisterAddonPanel(panelId, panelData)

    AureoleRange_Settings.panelId = panelId
    AureoleRange_Settings.panel   = panel

    AR.EnsureRingSets()
    local ringSetChoices      = {}
    local ringSetChoiceValues = {}
    for i, s in ipairs(AR.sv.ringSets) do
        ringSetChoices[i]      = string.format("%d) %s", i, s.name or ("Set " .. i))
        ringSetChoiceValues[i] = i
    end

    local options = {
        { type    = "checkbox",
          name    = GetString(SI_AR_ENABLE_RINGS),
          getFunc = function() return AR.sv.enabled end,
          setFunc = function(v) AR.sv.enabled = v; Apply() end,
          default = AR.defaults.enabled },

        { type = "header", name = GetString(SI_AR_RING_SETS_HEADER) },

        { type         = "dropdown",
          name         = GetString(SI_AR_ACTIVE_RING_SET),
          choices      = ringSetChoices,
          choicesValues = ringSetChoiceValues,
          getFunc      = function() return AR.sv.activeRingSet end,
          setFunc      = function(v) AR.sv.activeRingSet = v end,
          default      = AR.defaults.activeRingSet },

        { type    = "editbox",
          name    = GetString(SI_AR_SET_NAME),
          getFunc = function()
              AR.EnsureRingSets()
              local s = AR.sv.ringSets[AR.sv.activeRingSet]
              return s and (s.name or "") or ""
          end,
          setFunc = function(v)
              AR.EnsureRingSets()
              local s = AR.sv.ringSets[AR.sv.activeRingSet]
              if s then s.name = v end
          end,
          default = "" },

        { type    = "button",
          name    = GetString(SI_AR_LOAD_SET),
          tooltip = GetString(SI_AR_LOAD_SET_TT),
          width   = "full",
          func    = function()
              AR.EnsureRingSets()
              AR.LoadRingSet(AR.sv.activeRingSet)
              Apply()
          end },

        { type    = "button",
          name    = GetString(SI_AR_SAVE_SET),
          tooltip = GetString(SI_AR_SAVE_SET_TT),
          width   = "full",
          func    = function()
              AR.EnsureRingSets()
              AR.SaveCurrentSelectionToRingSet(AR.sv.activeRingSet)
          end },

        { type    = "button",
          name    = GetString(SI_AR_ADD_TO_SET),
          tooltip = GetString(SI_AR_ADD_TO_SET_TT),
          width   = "full",
          func    = function()
              AR.EnsureRingSets()
              AR.AddCurrentSelectionToRingSet(AR.sv.activeRingSet)
          end },

        { type    = "button",
          name    = GetString(SI_AR_REMOVE_FROM_SET),
          tooltip = GetString(SI_AR_REMOVE_FROM_SET_TT),
          width   = "full",
          func    = function()
              AR.EnsureRingSets()
              AR.RemoveCurrentSelectionFromRingSet(AR.sv.activeRingSet)
          end },

        { type    = "button",
          name    = GetString(SI_AR_NEW_SET),
          tooltip = GetString(SI_AR_NEW_SET_TT),
          width   = "full",
          func    = function()
              AR.CreateRingSet("New set")
          end },

        { type     = "button",
          name     = GetString(SI_AR_DELETE_SET),
          tooltip  = GetString(SI_AR_DELETE_SET_TT),
          width    = "full",
          disabled = function()
              AR.EnsureRingSets()
              return #AR.sv.ringSets <= 1
          end,
          func = function()
              AR.EnsureRingSets()
              AR.DeleteRingSet(AR.sv.activeRingSet)
              Apply()
          end },

        { type = "description", text = GetString(SI_AR_SETS_NOTE) },

        { type = "header", name = GetString(SI_AR_GLOBAL_HEADER) },

        { type    = "slider",
          name    = GetString(SI_AR_HEIGHT_OFFSET),
          min=0.0, max=1.0, step=0.01,
          getFunc = function() return AR.sv.heightOffset end,
          setFunc = function(v) AR.sv.heightOffset = v; Apply() end,
          default = AR.defaults.heightOffset },

        { type    = "slider",
          name    = GetString(SI_AR_STACKING_STEP),
          min=0.0, max=0.05, step=0.001,
          getFunc = function() return AR.sv.stackingStep end,
          setFunc = function(v) AR.sv.stackingStep = v; Apply() end,
          default = AR.defaults.stackingStep },

        { type    = "checkbox",
          name    = GetString(SI_AR_USE_DEPTH_BUFFER),
          getFunc = function() return AR.sv.useDepthBuffer end,
          setFunc = function(v) AR.sv.useDepthBuffer = v; Apply() end,
          default = AR.defaults.useDepthBuffer },

        { type    = "slider",
          name    = GetString(SI_AR_UPDATE_INTERVAL),
          min=10, max=200, step=5,
          tooltip = "Lower = smoother follow, higher = less CPU.",
          getFunc = function() return AR.sv.updateIntervalMs end,
          setFunc = function(v) AR.sv.updateIntervalMs = v; Apply() end,
          default = AR.defaults.updateIntervalMs },

        { type    = "checkbox",
          name    = GetString(SI_AR_PULSE_GLOBAL),
          getFunc = function() return AR.sv.pulse.enabled end,
          setFunc = function(v) AR.sv.pulse.enabled = v; Apply() end,
          default = AR.defaults.pulse.enabled },

        { type     = "slider",
          name     = GetString(SI_AR_PULSE_PERIOD),
          min=200, max=2500, step=25,
          disabled = function() return not AR.sv.pulse.enabled end,
          getFunc  = function() return AR.sv.pulse.periodMs end,
          setFunc  = function(v) AR.sv.pulse.periodMs = v; Apply() end,
          default  = AR.defaults.pulse.periodMs },

        { type     = "slider",
          name     = GetString(SI_AR_PULSE_MIN_MUL),
          min=0.05, max=2.0, step=0.05,
          disabled = function() return not AR.sv.pulse.enabled end,
          getFunc  = function() return AR.sv.pulse.minMul end,
          setFunc  = function(v) AR.sv.pulse.minMul = v; Apply() end,
          default  = AR.defaults.pulse.minMul },

        { type     = "slider",
          name     = GetString(SI_AR_PULSE_MAX_MUL),
          min=0.05, max=3.0, step=0.05,
          disabled = function() return not AR.sv.pulse.enabled end,
          getFunc  = function() return AR.sv.pulse.maxMul end,
          setFunc  = function(v) AR.sv.pulse.maxMul = v; Apply() end,
          default  = AR.defaults.pulse.maxMul },

        { type = "description", text = GetString(SI_AR_RINGS_NOTE) },
    }

    -- per-ring options
    for idx, _ in ipairs(AR.sv.presets) do
        table.insert(options, {
            type = "header",
            name = string.format(GetString(SI_AR_RING_N_HEADER), idx),
        })

        table.insert(options, {
            type    = "editbox",
            name    = GetString(SI_AR_RING_NAME),
            getFunc = function() return AR.sv.presets[idx].name end,
            setFunc = function(v) AR.sv.presets[idx].name = v; Apply() end,
            default = AR.defaults.presets[idx].name,
        })

        table.insert(options, {
            type    = "checkbox",
            name    = GetString(SI_AR_RING_ENABLED),
            getFunc = function() return AR.sv.presets[idx].enabled end,
            setFunc = function(v) AR.sv.presets[idx].enabled = v; Apply() end,
            default = AR.defaults.presets[idx].enabled,
        })

        table.insert(options, {
            type     = "slider",
            name     = GetString(SI_AR_RING_RADIUS),
            min=1, max=100, step=1,
            disabled = function() return not AR.sv.presets[idx].enabled end,
            getFunc  = function() return AR.sv.presets[idx].radiusMeters end,
            setFunc  = function(v) AR.sv.presets[idx].radiusMeters = v; Apply() end,
            default  = AR.defaults.presets[idx].radiusMeters,
        })

        table.insert(options, {
            type     = "colorpicker",
            name     = GetString(SI_AR_RING_COLOR),
            disabled = function() return not AR.sv.presets[idx].enabled end,
            getFunc  = function()
                local c = AR.sv.presets[idx].color
                return c.r, c.g, c.b
            end,
            setFunc  = function(r,g,b)
                AR.sv.presets[idx].color = {r=r,g=g,b=b}
                Apply()
            end,
            default = {
                AR.defaults.presets[idx].color.r,
                AR.defaults.presets[idx].color.g,
                AR.defaults.presets[idx].color.b,
            },
        })

        table.insert(options, {
            type     = "slider",
            name     = GetString(SI_AR_RING_INTENSITY),
            min=0, max=1, step=0.01,
            disabled = function() return not AR.sv.presets[idx].enabled end,
            getFunc  = function() return AR.sv.presets[idx].intensity end,
            setFunc  = function(v) AR.sv.presets[idx].intensity = v; Apply() end,
            default  = AR.defaults.presets[idx].intensity,
        })
    end

    LAM:RegisterOptionControls(panelId, options)
end
