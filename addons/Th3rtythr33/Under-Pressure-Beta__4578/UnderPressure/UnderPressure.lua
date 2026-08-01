-- =============================================================================
-- Under Pressure -- main entry
-- =============================================================================
-- Lifecycle:
--   1. EVENT_ADD_ON_LOADED for this addon
--   2. Load saved variables
--   3. Run feature detection
--   4. Init classifier, UI, debug, settings
--   5. Register event listeners
--   6. Start the engine tick loop
-- =============================================================================

UP = UP or {}
UP.name    = "UnderPressure"
UP.version = "0.2.2"

local DEFAULT_SAVED = {
    hidden        = false,
    offset_x      = 0,
    offset_y      = -140,
    scale         = 1.0,
    debug         = false,
    -- "solo" (Not Tank) counts attackers on the local player.
    -- "tank" counts attackers on any groupmate (best-effort: limited to
    -- combat events the local client actually receives).
    attacker_mode = "solo",
    show_counter  = true,
    tunables      = {},
    abilityOverrides   = {},
    riskBonusOverrides = {},
}

local function deepMergeDefaults(target, defaults)
    for k, v in pairs(defaults) do
        if type(v) == "table" then
            if type(target[k]) ~= "table" then target[k] = {} end
            deepMergeDefaults(target[k], v)
        elseif target[k] == nil then
            target[k] = v
        end
    end
end

local function onAddOnLoaded(eventCode, addonName)
    if addonName ~= UP.name then return end
    EVENT_MANAGER:UnregisterForEvent(UP.name, EVENT_ADD_ON_LOADED)

    -- Saved variables
    UnderPressureSavedVars = UnderPressureSavedVars or {}
    deepMergeDefaults(UnderPressureSavedVars, DEFAULT_SAVED)

    -- Feature detection runs first; engine consults its results
    if not UP.RunFeatureDetect() then return end

    -- Classifier needs access to override tables in saved vars
    UP.Classifier.init(UnderPressureSavedVars)

    -- UI
    if not UP.UI.Init() then return end
    UP.Debug.Init()
    UP.Debug.SetVisible(UnderPressureSavedVars.debug or false)

    -- Settings panel
    UP.Settings.Init()

    -- Wire up the per-tick UI refreshes (counter + debug overlay) into the
    -- engine tick chain by composing the original tick.
    local engineTick = UP.Engine.Tick
    UP.Engine.Tick = function()
        engineTick()
        if UP.UI and UP.UI.SetCounter and UP.Attackers and UP.Attackers.Counts then
            local count = UP.Attackers.Counts(GetGameTimeMilliseconds()) or 0
            UP.UI.SetCounter(count)
        end
        if UP.Debug and UP.Debug.Refresh then UP.Debug.Refresh() end
    end

    -- Event ingestion
    UP.Ingest.Register()

    -- Engine loop
    UP.Engine.Start()

    -- Slash commands
    SLASH_COMMANDS["/updebug"] = function()
        if UP.Debug and UP.Debug.Toggle then
            UP.Debug.Toggle()
            UnderPressureSavedVars.debug = not UnderPressureSavedVars.debug
        end
    end
    SLASH_COMMANDS["/up"] = function()
        if LibStub and LibStub("LibAddonMenu-2.0", true) then
            -- Open settings panel directly if API available
            local LAM = LibStub("LibAddonMenu-2.0")
            if LAM.OpenToPanel then LAM:OpenToPanel(UP_IndicatorRoot) end
        else
            d("[Under Pressure] Open Settings > Addons > Under Pressure")
        end
    end

    d(("[Under Pressure] v%s loaded."):format(UP.version))
end

EVENT_MANAGER:RegisterForEvent(UP.name, EVENT_ADD_ON_LOADED, onAddOnLoaded)
