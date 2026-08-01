PITHKA = PITHKA or {}
PITHKA.views = PITHKA.views or {}
PITHKA.views.groupFinderStandalone = PITHKA.views.groupFinderStandalone or {}

-- Distinct namespacing for clarity:
local groupFinderStandaloneUI = PITHKA.views.groupFinderStandalone
local constants = PITHKA.common.constants
local layout = PITHKA.layout
local ui = PITHKA.ui
local savedVars = PITHKA.data.savedVars
local data = PITHKA.data

-- constants
local DATA_TYPE = 1
local ROW_HEIGHT = 80

-- debug function
local debug_enabled = false
local function debug(message)
    if debug_enabled then
        d("|cFdA309[GroupFinderStandalone]|r " .. message)
    end
end

-------------------------------------------------------
-- SETUP SEARCH CONTROLS
-------------------------------------------------------

local function setupSearchControls()
    local window = WINDOW_MANAGER:GetControlByName("PITHKA_GROUP_FINDER_GUI")
    local contentContainer = window:GetNamedChild("ContentContainer")
    local footer = contentContainer:GetNamedChild("Footer")
    
    local grid = layout.grid.new(100, 3, footer, TOPLEFT)
    grid:addRow{
        ui.button.toggleButton({tooltipText='Healer',  textureBundle=constants.textureBundles.HEALER,  parent=footer, stateKey='groupFinderHealer'}),
        ui.button.toggleButton({tooltipText='Tank',    textureBundle=constants.textureBundles.TANK,    parent=footer, stateKey='groupFinderTank'}),
        ui.button.toggleButton({tooltipText='DPS',     textureBundle=constants.textureBundles.DPS,     parent=footer, stateKey='groupFinderDps'}),
        ui.other.spacer(15), 
        ui.button.toggleButton({tooltipText='Dungeon', textureBundle=constants.textureBundles.DUNGEON, parent=footer, stateKey='groupFinderDungeons'}),
        ui.button.toggleButton({tooltipText='Trial',   textureBundle=constants.textureBundles.TRIAL,   parent=footer, stateKey='groupFinderTrials'}),
        ui.other.spacer(15), 
        ui.button.toggleButton({tooltipText='Normal',  textureBundle=constants.textureBundles.NORMAL,  parent=footer, stateKey='groupFinderNormal'}),
        ui.button.toggleButton({tooltipText='Veteran', textureBundle=constants.textureBundles.VETERAN, parent=footer, stateKey='groupFinderVeteran'}),
    }

    -------------------------------------------------------
    -- SETUP PULSE LABEL
    -------------------------------------------------------

    -- PULSE LABEL BUSINESS LOGIC ---------------------------------------------------------
    local function updatePulseLabelSimple()
        local groupFinder = PITHKA.groupFinder.instance
        local pulseLabel = PITHKA.views.groupFinderStandalone.pulseLabel
        if not groupFinder or not pulseLabel then return end
        local state = groupFinder.stateMachine and groupFinder.stateMachine:GetCurrentState()
        local StateMachine = PITHKA.groupFinder.StateMachine
        if state == StateMachine.STATES.SEARCHING then
            local currentSearch = groupFinder.searchQueue and groupFinder.searchQueue:GetCurrentSearch()
            local searchText = "Currently searching..."
            if currentSearch then
                -- NEW: Searches now cover all roles, so we show enabled roles instead
                local enabledRoles = {}
                local roles = groupFinder:GetEnabledRoles()
                for role, enabled in pairs(roles) do
                    if enabled then
                        table.insert(enabledRoles, groupFinder:GetRoleName(role))
                    end
                end
                local roleText = #enabledRoles > 0 and table.concat(enabledRoles, "+") or "NO ROLES"
                
                local category = groupFinder:GetCategoryName(currentSearch.category)
                local difficulty = groupFinder:GetDifficultyName(currentSearch.difficulty)
                local idx = groupFinder.searchQueue:GetVisualSearchIndex()
                local total = groupFinder.searchQueue:GetTotalSearches()
                if idx and total and total > 0 then
                    searchText = string.format("SEARCHING (%d of %d):   %s %s for %s", idx, total, difficulty, category, roleText)
                else
                    searchText = string.format("SEARCHING:   %s %s for %s", difficulty, category, roleText)
                end
            end
            pulseLabel:SetText(searchText)
            pulseLabel:SetHidden(false)
            if pulseLabel.SetPulse then pulseLabel:SetPulse(true) end
        elseif state == StateMachine.STATES.IDLE then
            local idleText = "No active searches. Use buttons above to enable."
            pulseLabel:SetText(idleText)
            pulseLabel:SetHidden(false)
            if pulseLabel.SetPulse then pulseLabel:SetPulse(false) end
        else
            pulseLabel:SetHidden(true)
            if pulseLabel.SetPulse then pulseLabel:SetPulse(false) end
        end
    end

    local function registerPulseLabelCallbacksSimple()
        local groupFinder = PITHKA.groupFinder.instance
        local StateMachine = PITHKA.groupFinder.StateMachine
        if not groupFinder or not groupFinder.stateMachine then return end
        groupFinder.stateMachine:RegisterCallback(StateMachine.STATES.SEARCHING, function()
            updatePulseLabelSimple()
        end)
        groupFinder.stateMachine:RegisterCallback(StateMachine.STATES.IDLE, function()
            updatePulseLabelSimple()
        end)
        -- Also update when a new search starts
        local origProcessNextSearch = groupFinder.ProcessNextSearch
        groupFinder.ProcessNextSearch = function(self, ...)
            local result = origProcessNextSearch(self, ...)
            updatePulseLabelSimple()
            return result
        end
    end

    -- Create the pulse label using ui.label.pulse
    local pulseLabel = ui.label.pulse({
        text = 'testing label',
        width = 400,
        color = {1,1,1,1},
        align = TEXT_ALIGN_CENTER,
        font = constants.font.smallThinFont,
        parent = footer,
        hidden = false
    })
    pulseLabel:SetAnchor(BOTTOM, footer, BOTTOM, 0, -5)
    -- Store globally for updatePulseLabel
    PITHKA.views.groupFinderStandalone.pulseLabel = pulseLabel
    updatePulseLabelSimple()
    registerPulseLabelCallbacksSimple()
end

-------------------------------------------------------
-- SETUP LIST CARDS
-------------------------------------------------------

local function setupList()
    -- Get the window and list controls
    local window = WINDOW_MANAGER:GetControlByName("PITHKA_GROUP_FINDER_GUI")
    local contentContainer = window:GetNamedChild("ContentContainer")
    local list = contentContainer:GetNamedChild("List")

    -- Initialize the scroll list
    ZO_ScrollList_Initialize(list)

    -- Add the data type - using the standalone template
    ZO_ScrollList_AddDataType(list, DATA_TYPE, "PGFTableRowStandalone", ROW_HEIGHT, function(control, data)
        -- Set category text with conditional coloring
        local cardContainer = control:GetNamedChild("CardContainer")
        local leftContent = cardContainer:GetNamedChild("LeftContent")

        -- CARD HEADLINE ------------------------------------------------------------------------
        local categoryLabel = leftContent:GetNamedChild("Category")

        -- set text value
        local difficulty = data.difficulty == "Veteran" and "VET" or "NORM"
        local specificActivity = data.specificActivity
        local totalAttained = data.totalAttained or 0
        local numRoles = data.numRoles or 0
        local categoryText = string.format("%s %s", difficulty, specificActivity)

        categoryLabel:SetText(categoryText)
        
        -- Set color conditionally: blue for trials, gold for dungeons
        local categoryColor = constants.color.rgbBlue -- default to blue
        if data.category == GROUP_FINDER_CATEGORY_TRIAL then
            categoryColor = constants.color.rgbBlue
        elseif data.category == GROUP_FINDER_CATEGORY_DUNGEON then
            categoryColor = constants.color.rgbGold
        end
        categoryLabel:SetColor(unpack(categoryColor))

        -- set tooltip value
        local tooltipText = string.format("|cFFFFFF%s:|r %s\n|cFFFFFF%s:|r %s\n|cFFFFFF%s:|r %s", 
            "Leader", data.leader,
            "Title", data.title,
            "Description", data.description or "")
        categoryLabel:SetHandler("OnMouseEnter", function()
            InitializeTooltip(InformationTooltip, categoryLabel, TOPLEFT, -15, -10, TOPRIGHT)
            SetTooltipText(InformationTooltip, tooltipText)
        end)
        categoryLabel:SetHandler("OnMouseExit", function()
            ClearTooltip(InformationTooltip)
        end)

        -- INFO SUB HEADER ------------------------------------------------------------------------
        local infoContainer = leftContent:GetNamedChild("InfoContainer")
        local leaderTitleLabel = infoContainer:GetNamedChild("LeaderTitle")

        -- Format leader and title on first line
        local leaderTitleText = string.format("%s", data.title)
        leaderTitleLabel:SetText(leaderTitleText)

        -- ROLE BUTTONS ------------------------------------------------------------------------
        -- get container control
        local roleButtonsContainer = cardContainer:GetNamedChild("RoleButtonsContainer")
        if not roleButtonsContainer then return end
        
        -- get buttons contols
        local tankButton = roleButtonsContainer:GetNamedChild("TankButton")
        local healerButton = roleButtonsContainer:GetNamedChild("HealerButton")
        local dpsButton = roleButtonsContainer:GetNamedChild("DPSButton")
        if not tankButton or not healerButton or not dpsButton then return end

        -- Add group filled label to the right of DPS button
        local groupFilledLabel = roleButtonsContainer:GetNamedChild("GroupFilledLabel")
        if groupFilledLabel then
            groupFilledLabel:SetText(string.format("%d/%d", totalAttained or 0, numRoles or 0))
        end

        -- get role count controls
        local tankCount = tankButton:GetNamedChild("Count")
        local healerCount = healerButton:GetNamedChild("Count")
        local dpsCount = dpsButton:GetNamedChild("Count")

        -- Calculate total desired roles and any roles
        local totalDesiredRoles = (data.tankDesired or 0) + (data.healerDesired or 0) + (data.dpsDesired or 0)
        local anyRoles = (data.numRoles or 0) - totalDesiredRoles

        -- Calculate how many any roles have been used
        local anyRolesUsed = 0
        local tankExcess = math.max(0, (data.tankAttained or 0) - (data.tankDesired or 0))
        local healerExcess = math.max(0, (data.healerAttained or 0) - (data.healerDesired or 0))
        local dpsExcess = math.max(0, (data.dpsAttained or 0) - (data.dpsDesired or 0))
        anyRolesUsed = tankExcess + healerExcess + dpsExcess

        -- A role is needed if either:
        -- 1. It has a specific desired count > attained count
        -- 2. OR there are still any roles available
        local anyRolesAvailable = anyRolesUsed < anyRoles
        local tankNeeded = (data.tankAttained or 0) < (data.tankDesired or 0) or anyRolesAvailable
        local healerNeeded = (data.healerAttained or 0) < (data.healerDesired or 0) or anyRolesAvailable
        local dpsNeeded = (data.dpsAttained or 0) < (data.dpsDesired or 0) or anyRolesAvailable

        -- set enabled based on role counts
        tankButton:SetEnabled(tankNeeded)
        healerButton:SetEnabled(healerNeeded)
        dpsButton:SetEnabled(dpsNeeded)

        -- Format the count text with + if anyRoles are available
        local formatCount = function(attained, desired)
            if anyRolesAvailable then
                local denom = "∞"
                return string.format("%d/%s", attained or 0, denom)
            else
                local denom = desired or 0
                -- Add "+" if desired count is greater than attained count
                if (attained or 0) > (desired or 0) then
                    denom = denom .. "+"
                end
                return string.format("%d/%s", attained or 0, denom)
            end
        end

        if tankCount then tankCount:SetText(formatCount(data.tankAttained, data.tankDesired)) end
        if healerCount then healerCount:SetText(formatCount(data.healerAttained, data.healerDesired)) end
        if dpsCount then dpsCount:SetText(formatCount(data.dpsAttained, data.dpsDesired)) end

        -- Update button appearance based on enabled state
        local function setButtonState(button, enabled)
            local icon = button:GetNamedChild("Icon")
            if enabled then
                icon:SetColor(1, 1, 1, 1)  -- Full white
            else
                icon:SetColor(0.25, 0.25, 0.25, .50)  -- Gray
            end
        end

        setButtonState(tankButton, tankNeeded)
        setButtonState(healerButton, healerNeeded)
        setButtonState(dpsButton, dpsNeeded)

        -- role click function ---------------------------------------------------------------------------------------------------------
        -- Set up click handlers for role buttons
        local function handleRoleClick(data, role)
            data.role = role
            -- Initiate a priority search and join for the selected listing
            PITHKA.groupFinder.instance:JoinGroup(data)
        end

        tankButton:SetHandler("OnClicked", function()
            if tankNeeded then
                handleRoleClick(data, LFG_ROLE_TANK)
            end
        end)

        healerButton:SetHandler("OnClicked", function()
            if healerNeeded then
                handleRoleClick(data, LFG_ROLE_HEAL)
            end
        end)

        dpsButton:SetHandler("OnClicked", function()
            if dpsNeeded then
                handleRoleClick(data, LFG_ROLE_DPS)
            end
        end)
    end)
end

-------------------------------------------------------
-- SETUP DYNAMIC TABLE UPDATES
-------------------------------------------------------
function groupFinderStandaloneUI.updateTable()
    local window = WINDOW_MANAGER:GetControlByName("PITHKA_GROUP_FINDER_GUI")
    if not window then return end

    local contentContainer = window:GetNamedChild("ContentContainer")
    if not contentContainer then return end

    local list = contentContainer:GetNamedChild("List")
    
    -- Preserve scroll position during update
    local currentScrollValue = ZO_ScrollList_GetScrollValue and ZO_ScrollList_GetScrollValue(list) or 0
    
    local scrollData = ZO_ScrollList_GetDataList(list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    -- Get data from database
    local data = PITHKA.groupFinder.instance.dataStore:GetAllListings()
    for _, row in pairs(data) do
        table.insert(scrollData, ZO_ScrollList_CreateDataEntry(DATA_TYPE, row))
    end

    -- Commit the data
    ZO_ScrollList_Commit(list)
    
    -- Restore scroll position if we have data and it was scrolled
    if #scrollData > 0 and currentScrollValue > 0 then
        -- Small delay to ensure the list is fully committed before scrolling
        zo_callLater(function()
            if ZO_ScrollList_ScrollAbsolute then
                ZO_ScrollList_ScrollAbsolute(list, currentScrollValue)
            end
        end, 50)
    end
end

-------------------------------------------------------
-- REFRESH LIST FUNCTION
-------------------------------------------------------
function groupFinderStandaloneUI.refreshList()
    groupFinderStandaloneUI.updateTable()
end

-------------------------------------------------------
-- INITIALIZE GROUP FINDER STANDALONE UI
-------------------------------------------------------

-- Create a fragment that hides our window during certain scenes (like game menu)
local GroupFinderHideFragment = ZO_SceneFragment:Subclass()

function GroupFinderHideFragment:New()
    return ZO_SceneFragment.New(self)
end

function GroupFinderHideFragment:Show()
    -- When this fragment shows (like during game menu), hide our window if it was visible
    if PITHKA_GROUP_FINDER_GUI and not PITHKA_GROUP_FINDER_GUI:IsControlHidden() then
        self.wasVisible = true
        PITHKA_GROUP_FINDER_GUI:SetHidden(true)
        debug("Group Finder hidden for game menu")
    else
        self.wasVisible = false
    end
    self:OnShown()
end

function GroupFinderHideFragment:Hide()
    -- When this fragment hides (like leaving game menu), restore our window if it was visible
    if self.wasVisible and PITHKA_GROUP_FINDER_GUI then
        PITHKA_GROUP_FINDER_GUI:SetHidden(false)
        debug("Group Finder restored after game menu")
    end
    self.wasVisible = false
    self:OnHidden()
end

function groupFinderStandaloneUI.initialize()
    -- Basic initialization
    PITHKA_GROUP_FINDER_GUI:SetHidden(true) -- Start hidden
    
    -- Create our hide fragment and add it to scenes that should hide our window
    local hideFragment = GroupFinderHideFragment:New()
    
    -- Add to game menu scene so our window hides when ESC menu opens
    SCENE_MANAGER:GetScene("gameMenuInGame"):AddFragment(hideFragment)
    
    -- Store reference for later use
    groupFinderStandaloneUI.hideFragment = hideFragment
    
    setupList()
    setupSearchControls()

    -- Register for data updates
    if PITHKA.groupFinder.instance and PITHKA.groupFinder.instance.dataStore then
        PITHKA.groupFinder.instance.dataStore:RegisterUpdateCallback(groupFinderStandaloneUI.updateTable)
    end

    -- Check if search should start based on current conditions
    if PITHKA.groupFinder.instance then
        zo_callLater(function()
            debug("Checking if search should start on UI initialization")
            PITHKA.groupFinder.instance:UpdateSearchState()
        end, 100) -- Small delay to ensure everything is fully initialized
    end

    debug("GroupFinder Standalone UI initialized")
end

-------------------------------------------------------
-- TOGGLE UI FUNCTION
-------------------------------------------------------
function groupFinderStandaloneUI.toggleUI()
    -- Simple window toggle - no scene management
    local isHidden = PITHKA_GROUP_FINDER_GUI:IsControlHidden()
    PITHKA_GROUP_FINDER_GUI:SetHidden(not isHidden)
    
    debug("Group Finder window toggled: " .. (isHidden and "shown" or "hidden"))
    
    -- Update search state based on new window visibility
    if PITHKA.groupFinder.instance then
        PITHKA.groupFinder.instance:UpdateSearchState()
    end
end

-- Export the module
return groupFinderStandaloneUI 