-- ESO Quest Tracker Toggle Addon
local addonName = "QuestTrackerToggle"
local savedVariables
local LAM = LibAddonMenu2
local currentZoneId = 0

-- List of Trial Zone IDs
local trialZones = {
    [636] = true,  -- Hel Ra Citadel
    [638] = true,  -- Aetherian Archive
    [639] = true,  -- Sanctum Ophidia
    [725] = true,  -- Maw of Lorkhaj
    [975] = true,  -- Halls of Fabrication
    [1000] = true, -- Asylum Sanctorium
    [1051] = true, -- Cloudrest
    [1121] = true, -- Sunspire
    [1196] = true, -- Kyne's Aegis
    [1263] = true, -- Rockgrove
    [1344] = true, -- Dreadsail Reef
    [1427] = true, -- Sanity's Edge
    [1478] = true, -- Lucent Citadel
	[1548] = true, -- Ossein Cage
}

-- Global function to toggle the quest tracker visibility
function ToggleQuestTracker()
    local questTracker
    
    if IsInGamepadPreferredMode() then
        questTracker = ZO_FocusedQuestTrackerPanelContainerQuestContainer
    else
        questTracker = ZO_FocusedQuestTrackerPanel
    end
    
    if questTracker then
        local isHidden = not questTracker:IsHidden()
        questTracker:SetHidden(isHidden)
        savedVariables.isTrackerHidden = isHidden
    end
end

-- Function to apply stored visibility setting on load
local function ApplySavedTrackerState()
    if not savedVariables then return end
    
    local questTracker
    if IsInGamepadPreferredMode() then
        questTracker = ZO_FocusedQuestTrackerPanelContainerQuestContainer
    else
        questTracker = ZO_FocusedQuestTrackerPanel
    end
    
    if questTracker then
        questTracker:SetHidden(savedVariables.isTrackerHidden)
    end
	
	local eventTracker = ZO_PromotionalEventTracker
    if eventTracker then
		PROMOTIONAL_EVENT_TRACKER_FRAGMENT:SetHiddenForReason("HiddenByQuestTrackerToggle", savedVariables.isTrackerHidden, DEFAULT_HUD_DURATION, DEFAULT_HUD_DURATION)
		
    end
	
end

-- Function to handle trial instance entry and exit via zone change
local function OnZoneChange()
    if not savedVariables then return end

    local zoneId = GetZoneId(GetUnitZoneIndex("player"))

    local isFirstZoneAfterReload = (currentZoneId == 0)

    if zoneId == currentZoneId then
        return
    end

    currentZoneId = zoneId

    local questTracker
    if IsInGamepadPreferredMode() then
        questTracker = ZO_FocusedQuestTrackerPanelContainerQuestContainer
    else
        questTracker = ZO_FocusedQuestTrackerPanel
    end

    local eventTracker = ZO_PromotionalEventTracker

    if savedVariables.autoHideInTrial and trialZones[zoneId] then
        if questTracker then
            questTracker:SetHidden(true)
        end
        if eventTracker then
            PROMOTIONAL_EVENT_TRACKER_FRAGMENT:SetHiddenForReason(
                "HiddenByQuestTrackerToggle", true, DEFAULT_HUD_DURATION, DEFAULT_HUD_DURATION
            )
        end
    else
        -- If leaving a trial, restore visibility
        if questTracker and not savedVariables.isTrackerHidden then
            questTracker:SetHidden(false)
        end
        if eventTracker then
            PROMOTIONAL_EVENT_TRACKER_FRAGMENT:SetHiddenForReason(
                "HiddenByQuestTrackerToggle", savedVariables.isTrackerHidden, DEFAULT_HUD_DURATION, DEFAULT_HUD_DURATION
            )
        end
    end
end

-- Function to create settings menu
local function CreateSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then
        d("[QuestTrackerToggle] LibAddonMenu2 not found. Cannot create settings.")
        return
    end
    local panelData = {
        type = "panel",
        name = "Quest Tracker Toggle",
        author = "SkullElf",
        version = "1.3",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(addonName .. "_Options", panelData)

    local optionsData = {
        {
            type = "checkbox",
            name = "Hide Quest Tracker",
            tooltip = "Automatically hide the quest tracker when loading into the game.",
            getFunc = function() return savedVariables.isTrackerHidden end,
            setFunc = function(value) 
                savedVariables.isTrackerHidden = value 
                ApplySavedTrackerState() 
            end,
            default = false,
        },
        {
            type = "checkbox",
            name = "Auto-Hide in Trials",
            tooltip = "Automatically hide the quest tracker when entering a trial instance.",
            getFunc = function() return savedVariables.autoHideInTrial end,
            setFunc = function(value)
                savedVariables.autoHideInTrial = value
            end,
            default = false,
        },
    }

    LAM:RegisterOptionControls(addonName .. "_Options", optionsData)
end

-- Event handler to initialize the addon
local function OnAddonLoaded(event, name)
    if name ~= addonName then return end

    -- Force account-wide saved variables
    savedVariables = ZO_SavedVars:NewAccountWide("QuestTrackerToggle_SavedVariables", 1, nil, { isTrackerHidden = false, autoHideInTrial = false })
    
    -- Register the keybind string
    ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_QUEST_TRACKER", "Toggle Quest Tracker")
    
    -- Ensure keybind persists across characters
    ZO_SavedVars:NewAccountWide("QuestTrackerToggle_Keybinds", 1, nil, {})
    
    -- Create settings menu
    zo_callLater(CreateSettingsMenu, 500)

    
    -- Apply saved state with delay
    zo_callLater(ApplySavedTrackerState, 1000)
    
    -- Register event for entering a trial via zone change
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_PLAYER_ACTIVATED, OnZoneChange)
    
    -- Unregister event after initialization
    EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
end

-- Register event for when the addon is loaded
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, OnAddonLoaded)