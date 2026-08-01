-- Beltalowda - Group PvP Coordination Addon
-- Main initialization file

--[[
    SavedVariables Best Practice:
    
    BeltalowdaVars is automatically loaded by ESO before EVENT_ADD_ON_LOADED fires.
    It will be nil on first load, or contain saved data on subsequent loads.
    
    We initialize it in OnAddOnLoaded() to ensure it exists throughout the addon lifecycle.
    After initialization, BeltalowdaVars is GUARANTEED to exist, so we should:
    
    1. Use `BeltalowdaVars = BeltalowdaVars or {}` in functions that might be called
       early or need to be defensive
    2. Avoid `if not BeltalowdaVars then return end` guards after initialization
       as they cause silent failures
    3. Always initialize nested tables (e.g., BeltalowdaVars.ui = BeltalowdaVars.ui or {})
       before accessing them
]]--

-- Initialize main namespace
Beltalowda = Beltalowda or {}

-- Version information
Beltalowda.name = "Beltalowda"
Beltalowda.version = "0.5.4"
Beltalowda.author = "Kickimanjaro"

-- Menu visibility state (centralized layer tracking)
Beltalowda.menuState = {}

-- PvP visibility state
Beltalowda.pvpHidden = false

-- Local reference
local Beltalowda = Beltalowda

--[[
    Get the display name for a unit based on the global naming style setting.
    
    @param unitTag  string  ESO unit tag (e.g. "group1", "player")
    @return string  Character name or @AccountName depending on BeltalowdaVars.namingStyle
]]--
function Beltalowda.GetDisplayName(unitTag)
    if not unitTag then return "" end
    if BeltalowdaVars and BeltalowdaVars.namingStyle == "userid" then
        local displayName = GetUnitDisplayName(unitTag)
        if displayName and displayName ~= "" then
            return displayName  -- Already includes @ prefix
        end
    end
    return GetUnitName(unitTag) or ""
end

--[[
    Check if required libraries are loaded
    Returns: loaded (boolean), missingLibs (table of strings)
]]--
function Beltalowda.AreLibrariesLoaded()
    local loaded = true
    local missingLibs = {}
    if not LibAsync then
        loaded = false
        table.insert(missingLibs, "LibAsync")
    end
    if not LibGroupBroadcast then
        loaded = false
        table.insert(missingLibs, "LibGroupBroadcast")
    end
    if not LibAddonMenu2 then
        loaded = false
        table.insert(missingLibs, "LibAddonMenu2")
    end
    -- Network layer libraries (LibSetDetection, LibGroupCombatStats) are checked
    -- by BeltalowdaNetwork.Initialize() to avoid load-order timing issues
    -- Don't check them here or the addon won't initialize if they load after Beltalowda
    
    -- Check optional libraries - log info messages
    if not LibCombat then
    end
    return loaded, missingLibs
end

--[[
    Initialize all addon modules
]]--
function Beltalowda.Initialize()
    
    -- Initialize network layer (handles its own library dependencies)
    if Beltalowda.network and Beltalowda.network.Initialize then
        Beltalowda.network.Initialize()
    end
    
    -- Initialize settings menu
    if Beltalowda.Settings and Beltalowda.Settings.Initialize then
        Beltalowda.Settings.Initialize()
    end
    
    -- Initialize UI modules (deferred to player activation)
    -- UI modules will be initialized in OnPlayerActivated to ensure
    -- the game world is fully loaded
    
    return true
end

--[[
    Event handler for addon loaded
]]--
function Beltalowda.OnAddOnLoaded(eventCode, addonName)
    if addonName ~= Beltalowda.name then
        return
    end
    
    -- Unregister this event - only need to load once
    EVENT_MANAGER:UnregisterForEvent(Beltalowda.name, EVENT_ADD_ON_LOADED)
    
    -- Initialize SavedVariables
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.version = BeltalowdaVars.version or Beltalowda.version
    BeltalowdaVars.debug = BeltalowdaVars.debug or {}
    BeltalowdaVars.debug.lgcsDataSamples = BeltalowdaVars.debug.lgcsDataSamples or {}
    BeltalowdaVars.debug.lsdDataSamples = BeltalowdaVars.debug.lsdDataSamples or {}
    
    -- Initialize RdK compat default (nil-safe: preserves existing true/false)
    if BeltalowdaVars.rdkCompatEnabled == nil then
        BeltalowdaVars.rdkCompatEnabled = false
    end
    
    -- Initialize toolbox SavedVariables with defaults for new installs / upgrades
    BeltalowdaVars.toolbox = BeltalowdaVars.toolbox or {}
    if Beltalowda.Settings and Beltalowda.Settings.defaults and Beltalowda.Settings.defaults.toolbox then
        local tbDefaults = Beltalowda.Settings.defaults.toolbox
        for moduleKey, moduleDefaults in pairs(tbDefaults) do
            BeltalowdaVars.toolbox[moduleKey] = BeltalowdaVars.toolbox[moduleKey] or {}
            for k, v in pairs(moduleDefaults) do
                if BeltalowdaVars.toolbox[moduleKey][k] == nil then
                    if type(v) == "table" then
                        BeltalowdaVars.toolbox[moduleKey][k] = {}
                        for k2, v2 in pairs(v) do
                            if type(v2) == "table" then
                                BeltalowdaVars.toolbox[moduleKey][k][k2] = BeltalowdaVars.toolbox[moduleKey][k][k2] or {}
                                for k3, v3 in pairs(v2) do
                                    if BeltalowdaVars.toolbox[moduleKey][k][k2][k3] == nil then
                                        BeltalowdaVars.toolbox[moduleKey][k][k2][k3] = v3
                                    end
                                end
                            else
                                if BeltalowdaVars.toolbox[moduleKey][k][k2] == nil then
                                    BeltalowdaVars.toolbox[moduleKey][k][k2] = v2
                                end
                            end
                        end
                    else
                        BeltalowdaVars.toolbox[moduleKey][k] = v
                    end
                end
            end
        end
    end
    
    -- Initialize Logger early (before modules)
    if Beltalowda.Logger and Beltalowda.Logger.Initialize then
        Beltalowda.Logger.Initialize()
    end
    
    -- Initialize BuffMonitor early (before UI modules)
    if Beltalowda.BuffMonitor and Beltalowda.BuffMonitor.Initialize then
        Beltalowda.BuffMonitor.Initialize()
    end
    
    -- Initialize 3D Objects system (required for LeaderBeam)
    if Beltalowda.Util and Beltalowda.Util.Objects3D and Beltalowda.Util.Objects3D.Initialize then
        Beltalowda.Util.Objects3D.Initialize()
    end
    
    -- Pre-register Ruinous Cyclone (Volendrung ultimate) so it's always available
    if Beltalowda.Data and Beltalowda.Data.UltimateTracker then
        Beltalowda.Data.UltimateTracker.RegisterUltimate(116096) -- Ruinous Cyclone
    end
    
    -- Initialize the addon
    Beltalowda.Initialize()
end

-- ============================================================================
-- Menu Visibility (centralized layer handling)
-- ============================================================================

--[[
    Handle layer push/pop events for menu detection.
    Hides all UI elements when menus/inventory are open (activeLayerIndex > 2)
    unless the global "Show in Menus" setting is enabled.
]]--
function Beltalowda.OnLayerChanged(eventCode, layerIndex, activeLayerIndex)
    Beltalowda.UpdateMenuVisibility()
    -- Schedule a delayed re-check: when closing menus, the HUD scene may still
    -- be transitioning when the layer event fires, causing IsShowingBaseScene()
    -- to return false prematurely. The delayed call catches this.
    EVENT_MANAGER:UnregisterForUpdate("BeltalowdaMenuVisibilityDeferred")
    EVENT_MANAGER:RegisterForUpdate("BeltalowdaMenuVisibilityDeferred", 200, function()
        EVENT_MANAGER:UnregisterForUpdate("BeltalowdaMenuVisibilityDeferred")
        Beltalowda.UpdateMenuVisibility()
    end)
end

--[[
    Update PvP-hidden state for all UI modules.
    Called on zone transitions (EVENT_PLAYER_ACTIVATED) and when pvpOnly setting changes.
    When pvpOnly is enabled, hides all UI outside of PvP zones.
]]--
function Beltalowda.UpdatePvPVisibility()
    local pvpOnly = BeltalowdaVars and BeltalowdaVars.pvpOnly or false
    local inPvP = Beltalowda.Util and Beltalowda.Util.PvPDetection
                  and Beltalowda.Util.PvPDetection.GetCachedState() or false
    local shouldHide = pvpOnly and not inPvP
    Beltalowda.pvpHidden = shouldHide

    if Beltalowda.UI then
        if Beltalowda.UI.GroupDamageTimers and Beltalowda.UI.GroupDamageTimers.SetPvPHidden then
            Beltalowda.UI.GroupDamageTimers.SetPvPHidden(shouldHide)
        end
        if Beltalowda.UI.GroupDamageTimersByRole and Beltalowda.UI.GroupDamageTimersByRole.SetPvPHidden then
            Beltalowda.UI.GroupDamageTimersByRole.SetPvPHidden(shouldHide)
        end
        if Beltalowda.UI.GroupUltimateDisplay and Beltalowda.UI.GroupUltimateDisplay.SetPvPHidden then
            Beltalowda.UI.GroupUltimateDisplay.SetPvPHidden(shouldHide)
        end
        if Beltalowda.UI.GroupUltimateDisplayByRoles and Beltalowda.UI.GroupUltimateDisplayByRoles.SetPvPHidden then
            Beltalowda.UI.GroupUltimateDisplayByRoles.SetPvPHidden(shouldHide)
        end
        if Beltalowda.UI.ClientUltimateSelector and Beltalowda.UI.ClientUltimateSelector.SetPvPHidden then
            Beltalowda.UI.ClientUltimateSelector.SetPvPHidden(shouldHide)
        end
        if Beltalowda.UI.CompositionWarnings and Beltalowda.UI.CompositionWarnings.SetPvPHidden then
            Beltalowda.UI.CompositionWarnings.SetPvPHidden(shouldHide)
        end
        if Beltalowda.UI.CompositionWarningsPanel and Beltalowda.UI.CompositionWarningsPanel.SetPvPHidden then
            Beltalowda.UI.CompositionWarningsPanel.SetPvPHidden(shouldHide)
        end
        if Beltalowda.UI.GroupCompositionPanel and Beltalowda.UI.GroupCompositionPanel.SetPvPHidden then
            Beltalowda.UI.GroupCompositionPanel.SetPvPHidden(shouldHide)
        end
        if Beltalowda.UI.LeaderBeam and Beltalowda.UI.LeaderBeam.SetPvPHidden then
            Beltalowda.UI.LeaderBeam.SetPvPHidden(shouldHide)
        end
        if Beltalowda.UI.LeaderArrow and Beltalowda.UI.LeaderArrow.SetPvPHidden then
            Beltalowda.UI.LeaderArrow.SetPvPHidden(shouldHide)
        end
        if Beltalowda.UI.GroupSynergyDisplay and Beltalowda.UI.GroupSynergyDisplay.SetPvPHidden then
            Beltalowda.UI.GroupSynergyDisplay.SetPvPHidden(shouldHide)
        end
        if Beltalowda.UI.GroupSynergyDisplayByRoles and Beltalowda.UI.GroupSynergyDisplayByRoles.SetPvPHidden then
            Beltalowda.UI.GroupSynergyDisplayByRoles.SetPvPHidden(shouldHide)
        end
        if Beltalowda.UI.RapidOverview and Beltalowda.UI.RapidOverview.SetPvPHidden then
            Beltalowda.UI.RapidOverview.SetPvPHidden(shouldHide)
        end
        if Beltalowda.UI.PowerfulAssaultDisplay and Beltalowda.UI.PowerfulAssaultDisplay.SetPvPHidden then
            Beltalowda.UI.PowerfulAssaultDisplay.SetPvPHidden(shouldHide)
        end
        if Beltalowda.UI.RallyingCryDisplay and Beltalowda.UI.RallyingCryDisplay.SetPvPHidden then
            Beltalowda.UI.RallyingCryDisplay.SetPvPHidden(shouldHide)
        end
        if Beltalowda.UI.GroupFightTotalsMeter and Beltalowda.UI.GroupFightTotalsMeter.SetPvPHidden then
            Beltalowda.UI.GroupFightTotalsMeter.SetPvPHidden(shouldHide)
        end
    end
end

--[[
    Update menu-hidden state for all UI modules.
    Called when layer events fire or when showInMenus setting changes.
]]--
function Beltalowda.UpdateMenuVisibility()
    local showInMenus = BeltalowdaVars and BeltalowdaVars.showInMenus or false
    -- Use SCENE_MANAGER to detect menus: IsShowingBaseScene() returns true for
    -- both HUD_SCENE (normal gameplay) and HUD_UI_SCENE (cursor mode / drag mode),
    -- but false for inventory, settings, map, etc.
    local inMenu = SCENE_MANAGER and not SCENE_MANAGER:IsShowingBaseScene() or false
    local shouldHide = inMenu and not showInMenus

    if Beltalowda.UI then
        if Beltalowda.UI.GroupDamageTimers and Beltalowda.UI.GroupDamageTimers.SetMenuHidden then
            Beltalowda.UI.GroupDamageTimers.SetMenuHidden(shouldHide)
        end
        if Beltalowda.UI.GroupDamageTimersByRole and Beltalowda.UI.GroupDamageTimersByRole.SetMenuHidden then
            Beltalowda.UI.GroupDamageTimersByRole.SetMenuHidden(shouldHide)
        end
        if Beltalowda.UI.GroupUltimateDisplay and Beltalowda.UI.GroupUltimateDisplay.SetMenuHidden then
            Beltalowda.UI.GroupUltimateDisplay.SetMenuHidden(shouldHide)
        end
        if Beltalowda.UI.GroupUltimateDisplayByRoles and Beltalowda.UI.GroupUltimateDisplayByRoles.SetMenuHidden then
            Beltalowda.UI.GroupUltimateDisplayByRoles.SetMenuHidden(shouldHide)
        end
        if Beltalowda.UI.ClientUltimateSelector and Beltalowda.UI.ClientUltimateSelector.SetMenuHidden then
            Beltalowda.UI.ClientUltimateSelector.SetMenuHidden(shouldHide)
        end
        if Beltalowda.UI.CompositionWarnings and Beltalowda.UI.CompositionWarnings.SetMenuHidden then
            Beltalowda.UI.CompositionWarnings.SetMenuHidden(shouldHide)
        end
        if Beltalowda.UI.CompositionWarningsPanel and Beltalowda.UI.CompositionWarningsPanel.SetMenuHidden then
            Beltalowda.UI.CompositionWarningsPanel.SetMenuHidden(shouldHide)
        end
        if Beltalowda.UI.GroupCompositionPanel and Beltalowda.UI.GroupCompositionPanel.SetMenuHidden then
            Beltalowda.UI.GroupCompositionPanel.SetMenuHidden(shouldHide)
        end
        if Beltalowda.UI.LeaderBeam and Beltalowda.UI.LeaderBeam.SetMenuHidden then
            Beltalowda.UI.LeaderBeam.SetMenuHidden(shouldHide)
        end
        if Beltalowda.UI.LeaderArrow and Beltalowda.UI.LeaderArrow.SetMenuHidden then
            Beltalowda.UI.LeaderArrow.SetMenuHidden(shouldHide)
        end
        if Beltalowda.UI.GroupSynergyDisplay and Beltalowda.UI.GroupSynergyDisplay.SetMenuHidden then
            Beltalowda.UI.GroupSynergyDisplay.SetMenuHidden(shouldHide)
        end
        if Beltalowda.UI.GroupSynergyDisplayByRoles and Beltalowda.UI.GroupSynergyDisplayByRoles.SetMenuHidden then
            Beltalowda.UI.GroupSynergyDisplayByRoles.SetMenuHidden(shouldHide)
        end
        if Beltalowda.UI.RapidOverview and Beltalowda.UI.RapidOverview.SetMenuHidden then
            Beltalowda.UI.RapidOverview.SetMenuHidden(shouldHide)
        end
        if Beltalowda.UI.PowerfulAssaultDisplay and Beltalowda.UI.PowerfulAssaultDisplay.SetMenuHidden then
            Beltalowda.UI.PowerfulAssaultDisplay.SetMenuHidden(shouldHide)
        end
        if Beltalowda.UI.RallyingCryDisplay and Beltalowda.UI.RallyingCryDisplay.SetMenuHidden then
            Beltalowda.UI.RallyingCryDisplay.SetMenuHidden(shouldHide)
        end
        if Beltalowda.UI.GroupFightTotalsMeter and Beltalowda.UI.GroupFightTotalsMeter.SetMenuHidden then
            Beltalowda.UI.GroupFightTotalsMeter.SetMenuHidden(shouldHide)
        end
    end
end

--[[
    Event handler for player activated (entering world)
]]--
function Beltalowda.OnPlayerActivated(eventCode, initial)
    -- This fires when the player enters the world
    -- Used for initializing features that require the player to be fully loaded

    -- Register centralized layer events for menu visibility
    EVENT_MANAGER:RegisterForEvent("BeltalowdaMenuVisibility", EVENT_ACTION_LAYER_POPPED, Beltalowda.OnLayerChanged)
    EVENT_MANAGER:RegisterForEvent("BeltalowdaMenuVisibility", EVENT_ACTION_LAYER_PUSHED, Beltalowda.OnLayerChanged)

    -- Register HUD scene callbacks for reliable menu-close detection.
    -- When the game returns to the HUD after a menu, the layer event may fire
    -- before the scene transition completes. These callbacks fire AFTER the
    -- HUD scene is fully shown, guaranteeing IsShowingBaseScene() returns true.
    if HUD_SCENE and not Beltalowda.hudSceneCallbackRegistered then
        HUD_SCENE:RegisterCallback("StateChange", function(oldState, newState)
            if newState == SCENE_SHOWN then
                Beltalowda.UpdateMenuVisibility()
            end
        end)
        Beltalowda.hudSceneCallbackRegistered = true
    end
    if HUD_UI_SCENE and not Beltalowda.hudUiSceneCallbackRegistered then
        HUD_UI_SCENE:RegisterCallback("StateChange", function(oldState, newState)
            if newState == SCENE_SHOWN then
                Beltalowda.UpdateMenuVisibility()
            end
        end)
        Beltalowda.hudUiSceneCallbackRegistered = true
    end

    -- Initialize UI modules
    -- Note: We initialize on every activation, not just first, to handle /reloadui
    if Beltalowda.UI then
        if Beltalowda.UI.GroupUltimateDisplay and Beltalowda.UI.GroupUltimateDisplay.Initialize then
            Beltalowda.UI.GroupUltimateDisplay.Initialize()
        end
        
        if Beltalowda.UI.GroupUltimateDisplayByRoles and Beltalowda.UI.GroupUltimateDisplayByRoles.Initialize then
            Beltalowda.UI.GroupUltimateDisplayByRoles.Initialize()
        end
        
        if Beltalowda.UI.ClientUltimateSelector and Beltalowda.UI.ClientUltimateSelector.Initialize then
            Beltalowda.UI.ClientUltimateSelector.Initialize()
        end
        
        if Beltalowda.UI.CompositionWarnings and Beltalowda.UI.CompositionWarnings.Initialize then
            Beltalowda.UI.CompositionWarnings.Initialize()
        end
        
        if Beltalowda.UI.GroupCompositionPanel and Beltalowda.UI.GroupCompositionPanel.Initialize then
            Beltalowda.UI.GroupCompositionPanel.Initialize()
        end
        
        if Beltalowda.UI.LeaderBeam and Beltalowda.UI.LeaderBeam.Initialize then
            Beltalowda.UI.LeaderBeam.Initialize()
        end
        
        if Beltalowda.UI.LeaderArrow and Beltalowda.UI.LeaderArrow.Initialize then
            Beltalowda.UI.LeaderArrow.Initialize()
        end
        
        if Beltalowda.UI.GroupDamageTimers and Beltalowda.UI.GroupDamageTimers.Initialize then
            Beltalowda.UI.GroupDamageTimers.Initialize()
        end
        
        if Beltalowda.UI.GroupDamageTimersByRole and Beltalowda.UI.GroupDamageTimersByRole.Initialize then
            Beltalowda.UI.GroupDamageTimersByRole.Initialize()
        end
        
        if Beltalowda.UI.RapidOverview and Beltalowda.UI.RapidOverview.Initialize then
            Beltalowda.UI.RapidOverview.Initialize()
        end

        -- Synergy Tracker data layer (must initialize before UI modules)
        if Beltalowda.Data and Beltalowda.Data.SynergyTracker and Beltalowda.Data.SynergyTracker.Initialize then
            Beltalowda.Data.SynergyTracker.Initialize()
        end

        -- Synergy Composition (must initialize after SynergyTracker and GroupBroadcast)
        if Beltalowda.Data and Beltalowda.Data.SynergyComposition and Beltalowda.Data.SynergyComposition.Initialize then
            Beltalowda.Data.SynergyComposition.Initialize()
        end

        -- Buff Composition (must initialize after BuffDatabase and GroupBroadcast)
        if Beltalowda.Data and Beltalowda.Data.BuffComposition and Beltalowda.Data.BuffComposition.Initialize then
            Beltalowda.Data.BuffComposition.Initialize()
        end

        -- Mundus Composition (direct unit-tag scan, no network dependency)
        if Beltalowda.Data and Beltalowda.Data.MundusComposition and Beltalowda.Data.MundusComposition.Initialize then
            Beltalowda.Data.MundusComposition.Initialize()
        end

        -- Consumable Tracker (must initialize after GroupBroadcast for protocol 228)
        if Beltalowda.Data and Beltalowda.Data.ConsumableTracker and Beltalowda.Data.ConsumableTracker.Initialize then
            Beltalowda.Data.ConsumableTracker.Initialize()
        end

        -- Champion Point Composition (must initialize after GroupBroadcast for protocol 225)
        if Beltalowda.Data and Beltalowda.Data.ChampionPointComposition and Beltalowda.Data.ChampionPointComposition.Initialize then
            Beltalowda.Data.ChampionPointComposition.Initialize()
        end

        -- Fight Totals (must initialize after GroupBroadcast for protocol 229)
        if Beltalowda.Data and Beltalowda.Data.FightTotals and Beltalowda.Data.FightTotals.Initialize then
            Beltalowda.Data.FightTotals.Initialize()
        end

        if Beltalowda.UI.GroupSynergyDisplay and Beltalowda.UI.GroupSynergyDisplay.Initialize then
            Beltalowda.UI.GroupSynergyDisplay.Initialize()
        end

        if Beltalowda.UI.GroupSynergyDisplayByRoles and Beltalowda.UI.GroupSynergyDisplayByRoles.Initialize then
            Beltalowda.UI.GroupSynergyDisplayByRoles.Initialize()
        end

        if Beltalowda.UI.PowerfulAssaultDisplay and Beltalowda.UI.PowerfulAssaultDisplay.Initialize then
            Beltalowda.UI.PowerfulAssaultDisplay.Initialize()
        end

        if Beltalowda.UI.RallyingCryDisplay and Beltalowda.UI.RallyingCryDisplay.Initialize then
            Beltalowda.UI.RallyingCryDisplay.Initialize()
        end

        if Beltalowda.UI.GroupFightTotalsMeter and Beltalowda.UI.GroupFightTotalsMeter.Initialize then
            Beltalowda.UI.GroupFightTotalsMeter.Initialize()
        end
        
        -- GroupEquipmentDisplay is now settings-based, no window initialization needed
        -- if Beltalowda.UI.GroupEquipmentDisplay and Beltalowda.UI.GroupEquipmentDisplay.Initialize then
        --     Beltalowda.UI.GroupEquipmentDisplay.Initialize()
        -- end
    end

    -- Initialize toolbox modules
    if Beltalowda.Toolbox then
        if Beltalowda.Toolbox.Recharger and Beltalowda.Toolbox.Recharger.Initialize then
            Beltalowda.Toolbox.Recharger.Initialize()
        end
        if Beltalowda.Toolbox.Repair and Beltalowda.Toolbox.Repair.Initialize then
            Beltalowda.Toolbox.Repair.Initialize()
        end
        if Beltalowda.Toolbox.SiegeMerchant and Beltalowda.Toolbox.SiegeMerchant.Initialize then
            Beltalowda.Toolbox.SiegeMerchant.Initialize()
        end
        if Beltalowda.Toolbox.CyrodiilPins and Beltalowda.Toolbox.CyrodiilPins.Initialize then
            Beltalowda.Toolbox.CyrodiilPins.Initialize()
        end
    end

    -- Update PvP zone state and visibility on every zone transition
    if Beltalowda.Util and Beltalowda.Util.PvPDetection then
        Beltalowda.Util.PvPDetection.Update()
    end
    Beltalowda.UpdatePvPVisibility()

    -- Reset menu-hidden state now that the player is fully loaded.
    -- During loading screens (e.g. transitus shrine travel), layer events fire
    -- and set menuHidden=true on all UI modules. By the time EVENT_PLAYER_ACTIVATED
    -- fires the HUD scene should be active, but we add a small delay to guarantee
    -- IsShowingBaseScene() returns true after the scene fully transitions.
    Beltalowda.UpdateMenuVisibility()
    EVENT_MANAGER:UnregisterForUpdate("BeltalowdaMenuVisibilityPostLoad")
    EVENT_MANAGER:RegisterForUpdate("BeltalowdaMenuVisibilityPostLoad", 500, function()
        EVENT_MANAGER:UnregisterForUpdate("BeltalowdaMenuVisibilityPostLoad")
        Beltalowda.UpdateMenuVisibility()
    end)

    -- Request fresh data from group members on load/reload.
    -- On UI reload the group already exists but nobody automatically re-broadcasts,
    -- so we must request composition updates to populate remote data.
    if GetGroupSize() > 0 and Beltalowda.network and Beltalowda.network.RequestGroupCompositionUpdate then
        zo_callLater(function()
            Beltalowda.network.RequestGroupCompositionUpdate()
        end, 3000)  -- 3s delay: protocols init at 1s, local scan at 2s
    end
end

-- Register for addon loaded event
EVENT_MANAGER:RegisterForEvent(Beltalowda.name, EVENT_ADD_ON_LOADED, Beltalowda.OnAddOnLoaded)

-- Register for player activated event
EVENT_MANAGER:RegisterForEvent(Beltalowda.name, EVENT_PLAYER_ACTIVATED, Beltalowda.OnPlayerActivated)
