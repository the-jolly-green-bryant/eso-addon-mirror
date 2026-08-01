local HouseAndWayshrine = {
    NAME        = "HouseAndWayshrine",
    LONGNAME    = "House & Wayshrine Controller",
    AUTHOR      = "@|c00c1ffZai|r|cffffffZah|r",
    VERSION     = "1.0.3",
    SV_VER      = 1,
    SV_NAME     = "HouseAndWayshrine_SV",
    SV_DEF      = {
        showAllWayshrines = false,
        showAllOwnedHouses = false,
        showAllUnownedHouses = false,
    },
    SV = {}
}

local GetMapType = GetMapType
local MAPTYPE_COSMIC = MAPTYPE_COSMIC
local POI_TYPE_WAYSHRINE = POI_TYPE_WAYSHRINE
local POI_TYPE_HOUSE = POI_TYPE_HOUSE
local pinManager = ZO_WorldMap_GetPinManager()

-- Setup enhanced refresh functionality
local function SetupEnhancedRefresh()
    -- Helper function to check if showing cosmic map
    local function IsShowingCosmicMap()
        return GetMapType() == MAPTYPE_COSMIC
    end

    -- Copy of the original AddWayshrines function with our modifications
    local function AddWayshrines() -- This refers to all 4 kinds of fast travel
        -- Design rule, don't show wayshrine pins on cosmic, even if they're in the map
        if IsShowingCosmicMap() then
            return
        end
        
        -- Filters are split, with the "Wayshrines" filter being explicitly lore Wayshrines
        local isShowingWayshrines = ZO_WorldMap_IsPinGroupShown(MAP_FILTER_WAYSHRINES)
        local isShowingDungeons = ZO_WorldMap_IsPinGroupShown(MAP_FILTER_DUNGEONS)
        local isShowingArenas = ZO_WorldMap_IsPinGroupShown(MAP_FILTER_ARENAS)
        local isShowingTrials = ZO_WorldMap_IsPinGroupShown(MAP_FILTER_TRIALS)
        local isShowingHouses = ZO_WorldMap_IsPinGroupShown(MAP_FILTER_HOUSES)
        if not (isShowingWayshrines or isShowingDungeons or isShowingArenas or isShowingTrials or isShowingHouses) then
            return
        end
    
        -- Get the default behavior first
        local showPriorityFastTravelOnly = ShouldMapShowPriorityFastTravelOnly() 
        
        -- If showAllWayshrines is enabled and wayshrines are showing, override the default behavior
        if HouseAndWayshrine.SV.showAllWayshrines and isShowingWayshrines then
            showPriorityFastTravelOnly = false
        end
        
        -- Cache settings for better performance in the loop
        local showAllOwnedHouses = HouseAndWayshrine.SV.showAllOwnedHouses
        local showAllUnownedHouses = HouseAndWayshrine.SV.showAllUnownedHouses

        -- Only initialize the priority table if we're using priority filtering
        local priorityWayshrinesByZone
        if showPriorityFastTravelOnly then
            priorityWayshrinesByZone = {}
        end
    
        local numFastTravelNodes = GetNumFastTravelNodes()
        for nodeIndex = 1, numFastTravelNodes do
            local known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isLocatedInCurrentMap, linkedCollectibleIsLocked = GetFastTravelNodeInfo(nodeIndex)
            
            -- Fast early-out if not known or not on current map
            if known and isLocatedInCurrentMap and ZO_WorldMap_IsNormalizedPointInsideMapBounds(normalizedX, normalizedY) then
                local zoneIndex, poiIndex = GetFastTravelNodePOIIndicies(nodeIndex)
                local instanceType = GetPOIInstanceType(zoneIndex, poiIndex)
        
                -- TODO: Apply MapFilterOverride in other pin adding functions that require it.
                local mapFilterOverride = GetPOIMapFilterOverride(zoneIndex, poiIndex)
                
                local passesFilter = false
                if mapFilterOverride ~= MAP_FILTER_NONE then
                    if mapFilterOverride == MAP_FILTER_WAYSHRINES then
                        passesFilter = isShowingWayshrines
                    elseif mapFilterOverride == MAP_FILTER_DUNGEONS then
                        passesFilter = isShowingDungeons
                    elseif mapFilterOverride == MAP_FILTER_ARENAS then
                        passesFilter = isShowingArenas
                    elseif mapFilterOverride == MAP_FILTER_TRIALS then
                        passesFilter = isShowingTrials
                    elseif mapFilterOverride == MAP_FILTER_HOUSES then
                        passesFilter = isShowingHouses
                    end
                elseif poiType == POI_TYPE_HOUSE then
                    passesFilter = isShowingHouses
                elseif poiType == POI_TYPE_WAYSHRINE then
                    passesFilter = isShowingWayshrines
                elseif instanceType == INSTANCE_TYPE_RAID then
                    passesFilter = isShowingTrials
                else
                    passesFilter = isShowingDungeons
                end
        
                if passesFilter then
                    local suppressPin = false
        
                    if poiType == POI_TYPE_HOUSE then
                        local houseId = GetFastTravelNodeHouseId(nodeIndex)
                        local collectibleId = GetCollectibleIdForHouse(houseId)
                        local isOwned = IsCollectibleUnlocked(collectibleId)
                        -- Apply custom filters based on settings
                        if isOwned then
                            -- For owned houses - override default behavior if showAllOwnedHouses is true
                            if not showAllOwnedHouses then
                                -- Default behavior for owned houses - only show primary/favorite
                                if not IsPrimaryHouse(houseId) then
                                    local userFlags = GetCollectibleUserFlags(collectibleId)
                                    if not ZO_FlagHelpers.MaskHasFlag(userFlags, COLLECTIBLE_USER_FLAG_FAVORITE) then
                                        suppressPin = true
                                    end
                                end
                            end
                            -- If showAllOwnedHouses is true, we don't suppress any owned house pins
                        else
                            -- For unowned houses - suppress if not showing all unowned houses
                            if not showAllUnownedHouses then
                                suppressPin = true
                            end
                        end
                    end
                                        
                    if not suppressPin then
                        local isCurrentLoc = g_fastTravelNodeIndex == nodeIndex
                    
                        if isCurrentLoc then
                            glowIcon = nil
                        end
                    
                        local tag = ZO_MapPin.CreateTravelNetworkPinTag(nodeIndex, icon, glowIcon, linkedCollectibleIsLocked, poiType)
                        local pinType = isCurrentLoc and MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE_CURRENT_LOC or MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE
                        
                        -- Handle wayshrine priority filtering
                        local handledByPriority = false
                        local isCapitalWayshrine = false
                        
                        -- Only apply priority filtering for wayshrines if we're using the priority system
                        if showPriorityFastTravelOnly and poiType == POI_TYPE_WAYSHRINE then
                            -- Can return nil, which means ignore prioritization rules and always show (designer controlled)
                            local mapPriority = GetFastTravelNodeMapPriority(nodeIndex)
                            
                            if mapPriority then
                                if IsFastTravelNodeAutoDiscovered(nodeIndex) then
                                    -- Prefer auto discovered when priorities are the same
                                    mapPriority = mapPriority + 0.5
                                end
                    
                                local priorityWayshrineInfo = priorityWayshrinesByZone[zoneIndex]
                    
                                if not priorityWayshrineInfo or priorityWayshrineInfo.mapPriority < mapPriority then
                                    if not priorityWayshrineInfo then
                                        priorityWayshrineInfo = {}
                                        priorityWayshrinesByZone[zoneIndex] = priorityWayshrineInfo
                                    end
                                    priorityWayshrineInfo.mapPriority = mapPriority
                                    priorityWayshrineInfo.pinType = pinType
                                    priorityWayshrineInfo.tag = tag
                                    priorityWayshrineInfo.normalizedX = normalizedX
                                    priorityWayshrineInfo.normalizedY = normalizedY
                                end
                                
                                -- Mark as handled by priority system
                                handledByPriority = true
                            end
                        end
                        
                        -- If we got here and haven't been handled by priority system,
                        -- create the pin directly
                        if not handledByPriority then
                            pinManager:CreatePin(pinType, tag, normalizedX, normalizedY)
                        end
                    end
                end
            end
        end
    
        -- Process priority wayshrines if we're using the priority system
        if priorityWayshrinesByZone then
            for _, info in pairs(priorityWayshrinesByZone) do
                pinManager:CreatePin(info.pinType, info.tag, info.normalizedX, info.normalizedY)
            end
        end
    end

    -- Hook ZO_WorldMap_RefreshWayshrines to call our version of AddWayshrines
    ZO_WorldMap_RefreshWayshrines = function()
        pinManager:RemovePins("fastTravelWayshrine")
        AddWayshrines()
    end
end

-- Hook the map filter buttons to refresh the pins
local function HookMapFilterButtons()
    local MapFilterGlobalWindows = ZO_WorldMapFiltersGlobal:GetName()
    local MapFilterGlobalControlCount = ZO_WorldMapFiltersGlobal:GetNumChildren()
    if MapFilterGlobalWindows then
        for i = 1, MapFilterGlobalControlCount do
            local control = ZO_WorldMapFiltersGlobal:GetChild(i)
            if control then
                local label = control:GetNamedChild("Label")
                -- Hook the control to refresh the pins
                control:SetHandler("OnMouseUp", function(self, button, upInside)
                    if upInside then
                        ZO_WorldMap_RefreshWayshrines()
                    end
                end)
                -- Hook the label as well as it can also be clicked
                label:SetHandler("OnMouseUp", function(self, button, upInside)
                    if upInside then
                        ZO_WorldMap_RefreshWayshrines()
                    end
                end)
            end
        end
    end
end

-- Setup the settings menu
local function CreateSettingsMenu()
    local LAM2 = LibAddonMenu2
    if not LAM2 then return end

    local panelData = {
        type = "panel",
        name = HouseAndWayshrine.NAME,
        displayName = HouseAndWayshrine.LONGNAME,
        author = HouseAndWayshrine.AUTHOR,
        version = HouseAndWayshrine.VERSION,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local SV = HouseAndWayshrine.SV
    local DEF = HouseAndWayshrine.SV_DEF

    local optionsData = {
        --------------------
        {
            type = "header",
            name = "World Map Display Options",
            width = "full",
        },
        --------------------
        {
            type = "description",
            text = "These options control what is shown on the Tamriel world map. By default, ESO only shows capital city wayshrines and favourited houses.",
            width = "full",
        },
        --------------------
        {
            type = "checkbox",
            name = "Show All Wayshrines",
            tooltip = "When enabled, all discovered wayshrines will be shown on the world map, not just capital cities.",
            getFunc = function() return SV.showAllWayshrines end,
            setFunc = function(value) 
                SV.showAllWayshrines = value
            end,
            default = DEF.showAllWayshrines,
            width = "full",
        },
        --------------------
        {
            type = "checkbox",
            name = "Show All Owned Houses",
            tooltip = "When enabled, all owned houses will be shown on the world map, not just the default selection.",
            getFunc = function() return SV.showAllOwnedHouses end,
            setFunc = function(value) 
                SV.showAllOwnedHouses = value
            end,
            default = DEF.showAllOwnedHouses,
            width = "full",
        },
        --------------------
        {
            type = "checkbox",
            name = "Show All Unowned Houses",
            tooltip = "When enabled, all unowned houses will be shown on the world map, not just the default selection.",
            getFunc = function() return SV.showAllUnownedHouses end,
            setFunc = function(value) 
                SV.showAllUnownedHouses = value
            end,
            default = DEF.showAllUnownedHouses,
            width = "full",
        },
        --------------------
        {
            type = "description",
            text = "Note: The ESO map filters (Wayshrines, Dungeons, Trials, Houses) will still control the overall visibility of these pins, but these settings allow you to show more pins than ESO does by default.",
            width = "full",
        },
    }

    LAM2:RegisterAddonPanel("HouseAndWayshrine_Panel", panelData)
    LAM2:RegisterOptionControls("HouseAndWayshrine_Panel", optionsData)
end

-- Event handler for EVENT_PLAYER_ACTIVATED
-- This is where we setup the enhanced refresh and hook the map filter buttons
local function OnActivated(e)
    EVENT_MANAGER:UnregisterForEvent(HouseAndWayshrine.NAME, EVENT_PLAYER_ACTIVATED)
    -- Setup the enhanced refresh 
    SetupEnhancedRefresh()
    -- Hook the map filter buttons to refresh the pins
    HookMapFilterButtons()
    -- Create the settings menu
    CreateSettingsMenu()
end
EVENT_MANAGER:RegisterForEvent(HouseAndWayshrine.NAME, EVENT_PLAYER_ACTIVATED, OnActivated)

-- Event handler for ADD_ON_LOADED
local function OnAddOnLoaded(e, addonName)
    if addonName ~= HouseAndWayshrine.NAME then return end
    HouseAndWayshrine.SV = ZO_SavedVars:NewAccountWide(HouseAndWayshrine.SV_NAME, HouseAndWayshrine.SV_VER, nil, HouseAndWayshrine.SV_DEF, GetWorldName())
    EVENT_MANAGER:UnregisterForEvent(HouseAndWayshrine.NAME, EVENT_ADD_ON_LOADED)
end
EVENT_MANAGER:RegisterForEvent(HouseAndWayshrine.NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)