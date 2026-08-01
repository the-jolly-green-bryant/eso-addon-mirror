local ADDON_NAME = "LeadFilter"

-- State
local activeQualityFilter = nil
local filterButton = nil
local hideCompleted = false
local hideCompletedButton = nil
local currentCategoryData = nil
local selectedFilterName = nil -- initialized after GetString is available

-- Filter that removes any antiquity already recovered at least once (in the codex)
local function HideCompletedFilter(antiquityData)
    return not antiquityData:HasRecovered()
end

-- Lead type filter definitions (built lazily so GetString is available)
-- From data dump: q=3 (blue furnishings), q=4 (purple furnishings + mythic set fragments)
-- Mythics are always set fragments. Treasures are q<3 (green/white). Furnishings are q>=3 non-set.
local LEAD_TYPE_FILTERS = nil

local function GetLeadTypeFilters()
    if not LEAD_TYPE_FILTERS then
        LEAD_TYPE_FILTERS = {
            {
                name = GetString(SI_ITEMTYPEDISPLAYCATEGORY0), -- "All"
                filterFn = nil
            },
            {
                name = GetString(SI_ITEMTYPE56), -- "Treasure"
                filterFn = function(antiquityData)
                    return not antiquityData:IsSetFragment() and antiquityData:GetQuality() < 3
                end
            },
            {
                name = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES1002), -- "Furnishings"
                filterFn = function(antiquityData)
                    return not antiquityData:IsSetFragment() and antiquityData:GetQuality() >= 3
                end
            },
            {
                name = GetString(SI_ITEMDISPLAYQUALITY6), -- "Mythic"
                filterFn = function(antiquityData)
                    return antiquityData:IsSetFragment()
                end
            }
        }
        selectedFilterName = LEAD_TYPE_FILTERS[1].name
    end
    return LEAD_TYPE_FILTERS
end

-- Hook the antiquity filter category iterator to inject our quality filter
-- Note: Cannot use ZO_PreHook/ZO_PostHook here because we need to modify the
-- arguments passed to the original and return its result.
-- Note: self may be a ZO_EntryData wrapper, so compare by ID not identity
local origAntiquityIterator = ZO_AntiquityFilterCategory.AntiquityIterator
ZO_AntiquityFilterCategory.AntiquityIterator = function(self, filterFunctions)
    if activeQualityFilter or hideCompleted then
        local categoryId = self:GetId()
        local isScryable = categoryId == ZO_SCRYABLE_ANTIQUITY_CURRENT_ZONE_SUBCATEGORY_ID or categoryId ==
                               ZO_SCRYABLE_ANTIQUITY_ALL_LEADS_SUBCATEGORY_ID
        if isScryable then
            local newFilters = {}
            if filterFunctions then
                for i, fn in ipairs(filterFunctions) do
                    newFilters[i] = fn
                end
            end
            if activeQualityFilter then
                newFilters[#newFilters + 1] = activeQualityFilter
            end
            if hideCompleted then
                newFilters[#newFilters + 1] = HideCompletedFilter
            end
            return origAntiquityIterator(self, newFilters)
        end
    end
    return origAntiquityIterator(self, filterFunctions)
end

-- Create a right-aligned clickable label with hover highlight
local function CreateHoverLabel(name, parent)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetFont("ZoFontWinT1")
    label:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
    label:SetMouseEnabled(true)
    label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    label:SetHidden(true)
    label:SetHandler(
        "OnMouseEnter", function(self)
            self:SetColor(ZO_HIGHLIGHT_TEXT:UnpackRGBA())
        end)
    label:SetHandler(
        "OnMouseExit", function(self)
            self:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
        end)
    return label
end

-- Create clickable filter label with context menu
local function CreateFilterButton(journal)
    if filterButton then
        return
    end

    local categoryInset = journal.categoryInset
    if not categoryInset then
        return
    end

    local function RebuildTiles()
        if currentCategoryData and ZO_IsAntiquityScryableSubcategory(currentCategoryData) then
            journal:BuildCategoryAntiquityTiles(currentCategoryData)
        end
    end

    local btn = CreateHoverLabel("LeadFilterButton", categoryInset)
    btn:SetText("Lead Type: " .. (selectedFilterName or GetString(SI_ITEMTYPEDISPLAYCATEGORY0)))
    btn:SetAnchor(TOPRIGHT, categoryInset, TOPRIGHT, -10, 5)

    btn:SetHandler(
        "OnMouseDown", function(self)
            ClearMenu()
            for _, filterInfo in ipairs(GetLeadTypeFilters()) do
                AddMenuItem(
                    filterInfo.name, function()
                        activeQualityFilter = filterInfo.filterFn
                        selectedFilterName = filterInfo.name
                        self:SetText("Lead Type: " .. filterInfo.name)
                        RebuildTiles()
                    end)
            end
            ShowMenu(self)
        end)

    filterButton = btn

    -- "Hide Completed" toggle: hides any lead already recovered at least once.
    -- Stacked directly under the Lead Type label.
    local toggle = CreateHoverLabel("LeadFilterHideCompletedButton", categoryInset)
    toggle:SetText("Hide Completed: " .. (hideCompleted and "On" or "Off"))
    toggle:SetAnchor(TOPRIGHT, btn, BOTTOMRIGHT, 0, 4)

    toggle:SetHandler(
        "OnMouseDown", function(self)
            hideCompleted = not hideCompleted
            self:SetText("Hide Completed: " .. (hideCompleted and "On" or "Off"))
            RebuildTiles()
        end)

    hideCompletedButton = toggle
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    -- Hook ResetCategoryTiles to show/hide button and adjust layout
    ZO_PostHook(ZO_AntiquityJournal_Keyboard, "ResetCategoryTiles", function(self, shouldHideProgressBar)
        if filterButton then
            filterButton:SetHidden(not shouldHideProgressBar)
            hideCompletedButton:SetHidden(not shouldHideProgressBar)
            if shouldHideProgressBar then
                self.contentList:ClearAnchors()
                self.contentList:SetAnchor(BOTTOMRIGHT, nil, nil, -10, -75)
                self.contentList:SetAnchor(TOPLEFT, self.categoryInset, BOTTOMLEFT, nil, 45)
            end
        end
    end)

    -- Track current category so we can rebuild tiles on filter change
    ZO_PreHook(ZO_AntiquityJournal_Keyboard, "BuildCategoryAntiquityTiles", function(self, categoryData)
        currentCategoryData = categoryData
    end)

    -- Create the filter buttons once the journal initializes. Note: deferred init
    -- can run before addon load (ShowCategory calls PerformDeferredInitialize
    -- outside the scene-show path), so the hook alone is not sufficient — keep
    -- the scene callback and immediate fallback below.
    ZO_PostHook(ZO_AntiquityJournal_Keyboard, "OnDeferredInitialize", function(self)
        CreateFilterButton(self)
    end)

    -- Fallback: fires every time the codex opens
    if ANTIQUITY_JOURNAL_KEYBOARD_SCENE then
        ANTIQUITY_JOURNAL_KEYBOARD_SCENE:RegisterCallback(
            "StateChange", function(oldState, newState)
                if newState == SCENE_SHOWN and not filterButton then
                    CreateFilterButton(ANTIQUITY_JOURNAL_KEYBOARD)
                end
            end)
    end

    -- Fallback: journal already initialized before addon load
    if ANTIQUITY_JOURNAL_KEYBOARD and ANTIQUITY_JOURNAL_KEYBOARD.categoryInset then
        CreateFilterButton(ANTIQUITY_JOURNAL_KEYBOARD)
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
