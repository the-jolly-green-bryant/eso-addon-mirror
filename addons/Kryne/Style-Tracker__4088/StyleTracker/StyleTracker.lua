local ADDON_NAME = "StyleTracker"
local savedVars = {}

-- Filter constants
local FILTER_TYPES = {
    ALL = "All",
    WEAPONS = "Weapons",
    ARMOR = "Armor",
}

-- Loading the addon
local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end

    -- Initialization SavedVariables
    StyleTracker_SavedVars = StyleTracker_SavedVars or {
        masterCharacter = "",
        knownStyles = {},
        currentFilter = FILTER_TYPES.ALL,
    }
    savedVars = StyleTracker_SavedVars

    -- Create GUI
    CreateTrackerWindow()

    -- Event registration
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_LEARNED_MOTIF, UpdateKnownStyles)
    SLASH_COMMANDS["/stsetmaster"] = function() SetMasterCharacter() end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

-- Set the main character
local function SetMasterCharacter()
    savedVars.masterCharacter = GetUnitName("player")
    UpdateKnownStyles()
    d("The main character has been updated: " .. savedVars.masterCharacter)
end

-- Update style data (automatically when learning a new one)
local function UpdateKnownStyles()
    if savedVars.masterCharacter ~= GetUnitName("player") then return end

    savedVars.knownStyles = {}
    for motifId = 1, GetNumMotifStyles() do
        for chapter = 1, GetNumMotifChapters(motifId) do
            if IsMotifChapterKnown(motifId, chapter) then
                savedVars.knownStyles[motifId] = true
                break
            end
        end
    end
end

-- Check if the style is learned
local function IsStyleKnown(motifId)
    return savedVars.knownStyles[motifId] or false
end

-- Create GUI (tracker window)
local function CreateTrackerWindow()
    local window = WINDOW_MANAGER:CreateTopLevelWindow("StyleTracker_Window")
    window:SetDimensions(400, 500)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetHidden(true)

    -- Title
    local title = WINDOW_MANAGER:CreateControl("StyleTracker_Title", window, CT_LABEL)
    title:SetText("Style Tracker")
    title:SetFont("ZoFontGameLarge")
    title:SetAnchor(TOP, window, TOP, 0, 10)

    -- Close button
    local closeBtn = WINDOW_MANAGER:CreateControl("StyleTracker_CloseBtn", window, CT_BUTTON)
    closeBtn:SetText("X")
    closeBtn:SetDimensions(30, 30)
    closeBtn:SetAnchor(TOPRIGHT, window, TOPRIGHT, -10, 10)
    closeBtn:SetHandler("OnClicked", function() window:SetHidden(true) end)

    -- Filter (drop-down list)
    local filterDropdown = WINDOW_MANAGER:CreateControl("StyleTracker_Filter", window, CT_DROPDOWN)
    filterDropdown:SetDimensions(150, 30)
    filterDropdown:SetAnchor(TOP, title, BOTTOM, 0, 20)
    filterDropdown:SetItems(ZO_ComboBox_ObjectFromTable(FILTER_TYPES))
    filterDropdown:SetSelectedItem(savedVars.currentFilter)
    filterDropdown:SetHandler("OnItemSelected", function(_, _, filterType)
        savedVars.currentFilter = filterType
        RefreshMotifList()
    end)

    -- List of motives
    local scrollList = WINDOW_MANAGER:CreateControl("StyleTracker_ScrollList", window, CT_SCROLL)
    scrollList:SetDimensions(380, 400)
    scrollList:SetAnchor(TOP, filterDropdown, BOTTOM, 0, 10)

    -- Update the list of motives
    function RefreshMotifList()
        -- This will be where the filtering and display logic will be.
    end

    -- Tracker open button
    local openBtn = WINDOW_MANAGER:CreateControl("StyleTracker_OpenBtn", ZO_GameMenu, CT_BUTTON)
    openBtn:SetText("Style Tracker")
    openBtn:SetDimensions(120, 30)
    openBtn:SetAnchor(BOTTOM, ZO_GameMenu, BOTTOM, 0, -50)
    openBtn:SetHandler("OnClicked", function() window:SetHidden(not window:IsHidden()) end)
end

-- Event when opening a motif
local function OnMotifInspected(motifId)
    local status = IsStyleKnown(motifId) and "|c00FF00Studied|r" or "|cFF0000Not studied|r"
    d("Motive status: " .. status)
end

-- Event registration
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_MOTIF_INSPECTED, OnMotifInspected)