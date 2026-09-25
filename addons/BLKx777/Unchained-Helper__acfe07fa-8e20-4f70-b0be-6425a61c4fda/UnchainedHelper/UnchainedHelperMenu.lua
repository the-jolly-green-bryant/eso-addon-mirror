UnchainedHelper = UnchainedHelper or { }
local UnchainedHelper = UnchainedHelper

local sounds = {
    "No Sound Effect",
    "Justice_PickpocketFailed",
    "Dialog_Decline",
    "Ability_Ultimate_Ready_Sound",
    "Quest_Shared",
    "Champion_PointsCommitted",
    "GroupElection_Requested",
    "Duel_Boundary_Warning",
}

local function RefreshPosition()
    if UnchainedHelper.setPos then
        UnchainedHelper.setPos()
    end
end

local function RefreshLegendPosition()
    if UnchainedHelper.UpdateLegendPosition then
        UnchainedHelper.UpdateLegendPosition()
    end
    if UnchainedHelper.RefreshLegend then
        UnchainedHelper.RefreshLegend()
    end
end

local function PreviewMarkers()
    if GetZoneId(GetUnitZoneIndex("player")) ~= 1082 then
        d("Unchained Helper: preview only works inside Blackrose Prison.")
        return
    end
    if UnchainedHelper.HasMarkerRuntime and not UnchainedHelper.HasMarkerRuntime() then
        UnchainedHelper.WarnMissingMarkerRuntime(true)
        d("Unchained Helper: preview cannot draw until the marker layer is available.")
        return
    end
    UnchainedHelper.ClearIcons()
    -- Use the current stage's first queued marker set if possible.
    UnchainedHelper.nextStage = UnchainedHelper.GetCurrentStage()
    if UnchainedHelper.nextStage == 0 then UnchainedHelper.nextStage = 1 end
    UnchainedHelper.nextRound = 1
    UnchainedHelper.nextWave = 1
    UnchainedHelper.NotifyNewWave(1)
    d("Unchained Helper: Preview markers placed.")
end

function UnchainedHelper.setupMenu()
    local LAM = LibAddonMenu2
    if not LAM then
        d("Unchained Helper: LibAddonMenu-2.0 not found. Addon will run with default settings.")
        return
    end

    local panelData = {
        type = "panel",
        name = "Unchained Helper",
        displayName = "|cFFD700Unchained Helper|r",
        author = "BLKx777",
        version = UnchainedHelper.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel(UnchainedHelper.name.."Options", panelData)

    local options = {
        {
            type = "checkbox",
            name = "Enable addon",
            getFunc = function() return UnchainedHelper.savedVars.enabled end,
            setFunc = function(value)
                UnchainedHelper.savedVars.enabled = value
                if not value then
                    UnchainedHelper.UnregisterZoneEvents()
                    UnchainedHelperFrame:SetHidden(true)
                    if UnchainedHelper.HideLegend then UnchainedHelper.HideLegend() end
                else
                    UnchainedHelper.PlayerActivated()
                end
            end,
            default = UnchainedHelper.defaults.enabled,
        },
        {
            type = "header",
            name = "Unchained safety",
        },
        {
            type = "checkbox",
            name = "Block Blackrose sigils",
            tooltip = "Blocks Blackrose sigils used in the arena while inside Blackrose Prison. Player synergies such as orbs and shards are not targeted.",
            getFunc = function() return UnchainedHelper.savedVars.blockBlackroseSigils end,
            setFunc = function(value) UnchainedHelper.savedVars.blockBlackroseSigils = value end,
            default = UnchainedHelper.defaults.blockBlackroseSigils,
        },
        {
            type = "checkbox",
            name = "Show sigil block notice",
            tooltip = "Shows a short chat notice when a Blackrose sigil prompt is blocked.",
            getFunc = function() return UnchainedHelper.savedVars.sigilBlockNotice end,
            setFunc = function(value) UnchainedHelper.savedVars.sigilBlockNotice = value end,
            default = UnchainedHelper.defaults.sigilBlockNotice,
        },
        {
            type = "checkbox",
            name = "Show round/stage callout",
            tooltip = "Shows progress in chat when a new Blackrose round is detected. Format: Round: current/5 - Stage: current/5.",
            getFunc = function() return UnchainedHelper.savedVars.showProgressCallouts ~= false end,
            setFunc = function(value) UnchainedHelper.savedVars.showProgressCallouts = value end,
            default = UnchainedHelper.defaults.showProgressCallouts,
        },

        {
            type = "header",
            name = "Markers",
        },
        {
            type = "checkbox",
            name = "Show priority kill markers",
            getFunc = function() return UnchainedHelper.savedVars.showPriorityMarkers end,
            setFunc = function(value) UnchainedHelper.savedVars.showPriorityMarkers = value if UnchainedHelper.RedrawActiveMarkers then UnchainedHelper.RedrawActiveMarkers() end end,
            default = UnchainedHelper.defaults.showPriorityMarkers,
        },
        {
            type = "checkbox",
            name = "Show interrupt markers",
            getFunc = function() return UnchainedHelper.savedVars.showInterruptMarkers end,
            setFunc = function(value) UnchainedHelper.savedVars.showInterruptMarkers = value if UnchainedHelper.RedrawActiveMarkers then UnchainedHelper.RedrawActiveMarkers() end end,
            default = UnchainedHelper.defaults.showInterruptMarkers,
        },
        {
            type = "checkbox",
            name = "Show danger add markers",
            getFunc = function() return UnchainedHelper.savedVars.showDangerMarkers end,
            setFunc = function(value) UnchainedHelper.savedVars.showDangerMarkers = value if UnchainedHelper.RedrawActiveMarkers then UnchainedHelper.RedrawActiveMarkers() end end,
            default = UnchainedHelper.defaults.showDangerMarkers,
        },
        {
            type = "checkbox",
            name = "Show tank positions",
            getFunc = function() return UnchainedHelper.savedVars.tankPosition end,
            setFunc = function(value) UnchainedHelper.savedVars.tankPosition = value if UnchainedHelper.RedrawActiveMarkers then UnchainedHelper.RedrawActiveMarkers() end end,
            default = UnchainedHelper.defaults.tankPosition,
        },
        {
            type = "checkbox",
            name = "Show group stack positions",
            getFunc = function() return UnchainedHelper.savedVars.dpsPosition end,
            setFunc = function(value) UnchainedHelper.savedVars.dpsPosition = value if UnchainedHelper.RedrawActiveMarkers then UnchainedHelper.RedrawActiveMarkers() end end,
            default = UnchainedHelper.defaults.dpsPosition,
        },
        {
            type = "slider",
            name = "Marker size",
            min = 80,
            max = 320,
            step = 5,
            getFunc = function() return UnchainedHelper.savedVars.markerSize end,
            setFunc = function(value)
                UnchainedHelper.savedVars.markerSize = value
                if UnchainedHelper.RedrawActiveMarkers then UnchainedHelper.RedrawActiveMarkers() end
            end,
            default = UnchainedHelper.defaults.markerSize,
        },
        {
            type = "slider",
            name = "Marker height",
            min = 0,
            max = 700,
            step = 10,
            getFunc = function() return UnchainedHelper.savedVars.markerHeight end,
            setFunc = function(value)
                UnchainedHelper.savedVars.markerHeight = value
                if UnchainedHelper.RedrawActiveMarkers then UnchainedHelper.RedrawActiveMarkers() end
            end,
            default = UnchainedHelper.defaults.markerHeight,
        },
        {
            type = "slider",
            name = "Active marker duration",
            tooltip = "Seconds after a spawn wave before active markers clear.",
            min = 2,
            max = 15,
            step = 1,
            getFunc = function() return UnchainedHelper.savedVars.removeMarkerSeconds end,
            setFunc = function(value) UnchainedHelper.savedVars.removeMarkerSeconds = value end,
            default = UnchainedHelper.defaults.removeMarkerSeconds,
        },
        {
            type = "slider",
            name = "Next wave preview delay",
            tooltip = "Seconds after clearing current markers before showing the next wave preview.",
            min = 2,
            max = 30,
            step = 1,
            getFunc = function() return UnchainedHelper.savedVars.nextMarkerSeconds end,
            setFunc = function(value) UnchainedHelper.savedVars.nextMarkerSeconds = value end,
            default = UnchainedHelper.defaults.nextMarkerSeconds,
        },
        {
            type = "button",
            name = "Preview first-wave markers",
            func = PreviewMarkers,
        },
        {
            type = "header",
            name = "Marker legend",
        },
        {
            type = "checkbox",
            name = "Show marker legend",
            getFunc = function() return UnchainedHelper.savedVars.showMarkerLegend end,
            setFunc = function(value) UnchainedHelper.savedVars.showMarkerLegend = value RefreshLegendPosition() end,
            default = UnchainedHelper.defaults.showMarkerLegend,
        },
        {
            type = "slider",
            name = "Legend scale",
            min = 60,
            max = 140,
            step = 5,
            getFunc = function() return UnchainedHelper.savedVars.legendScale end,
            setFunc = function(value) UnchainedHelper.savedVars.legendScale = value RefreshLegendPosition() end,
            default = UnchainedHelper.defaults.legendScale,
        },
        {
            type = "slider",
            name = "Legend X position",
            min = 0,
            max = 3000,
            step = 10,
            getFunc = function() return UnchainedHelper.savedVars.legendOffsetX end,
            setFunc = function(value) UnchainedHelper.savedVars.legendOffsetX = value RefreshLegendPosition() end,
            default = UnchainedHelper.defaults.legendOffsetX,
        },
        {
            type = "slider",
            name = "Legend Y position",
            min = 0,
            max = 1800,
            step = 10,
            getFunc = function() return UnchainedHelper.savedVars.legendOffsetY end,
            setFunc = function(value) UnchainedHelper.savedVars.legendOffsetY = value RefreshLegendPosition() end,
            default = UnchainedHelper.defaults.legendOffsetY,
        },
        {
            type = "slider",
            name = "Legend background opacity",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return UnchainedHelper.savedVars.legendBackgroundAlpha end,
            setFunc = function(value) UnchainedHelper.savedVars.legendBackgroundAlpha = value RefreshLegendPosition() end,
            default = UnchainedHelper.defaults.legendBackgroundAlpha,
        },
        {
            type = "button",
            name = "Reset legend position",
            func = function()
                UnchainedHelper.savedVars.legendScale = UnchainedHelper.defaults.legendScale
                UnchainedHelper.savedVars.legendOffsetX = UnchainedHelper.defaults.legendOffsetX
                UnchainedHelper.savedVars.legendOffsetY = UnchainedHelper.defaults.legendOffsetY
                UnchainedHelper.savedVars.legendBackgroundAlpha = UnchainedHelper.defaults.legendBackgroundAlpha
                RefreshLegendPosition()
            end,
        },
        {
            type = "header",
            name = "Purge display",
        },
        {
            type = "checkbox",
            name = "Show purge counter",
            getFunc = function() return UnchainedHelper.savedVars.displayPurge end,
            setFunc = function(value) UnchainedHelper.savedVars.displayPurge = value end,
            default = UnchainedHelper.defaults.displayPurge,
        },
        {
            type = "dropdown",
            name = "Purge sound",
            choices = sounds,
            getFunc = function() return UnchainedHelper.savedVars.soundEffectPurge end,
            setFunc = function(value) UnchainedHelper.savedVars.soundEffectPurge = value end,
            default = UnchainedHelper.defaults.soundEffectPurge,
        },
        {
            type = "header",
            name = "Purge UI position",
        },
        {
            type = "slider",
            name = "Purge UI X position",
            min = 0,
            max = 3000,
            step = 10,
            getFunc = function() return UnchainedHelper.savedVars.offsetX end,
            setFunc = function(value) UnchainedHelper.savedVars.offsetX = value RefreshPosition() end,
            default = UnchainedHelper.defaults.offsetX,
        },
        {
            type = "slider",
            name = "Purge UI Y position",
            min = 0,
            max = 1800,
            step = 10,
            getFunc = function() return UnchainedHelper.savedVars.offsetY end,
            setFunc = function(value) UnchainedHelper.savedVars.offsetY = value RefreshPosition() end,
            default = UnchainedHelper.defaults.offsetY,
        },
        {
            type = "button",
            name = "Reset purge UI position",
            func = function()
                UnchainedHelper.savedVars.offsetX = UnchainedHelper.defaults.offsetX
                UnchainedHelper.savedVars.offsetY = UnchainedHelper.defaults.offsetY
                RefreshPosition()
            end,
        },
    }

    LAM:RegisterOptionControls(UnchainedHelper.name.."Options", options)
end
