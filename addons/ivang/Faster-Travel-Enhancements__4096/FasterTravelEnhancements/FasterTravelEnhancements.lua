FasterTravelEnhancements = {
    addon = {
        name = "FasterTravelEnhancements",
        displayName = "|c40FF40Faster|r Travel |cFFC300Enhancements|r",
        author = "xIvanGx",
        version = "1.0.0"
    }
}

local FT = FasterTravel
local FTE = FasterTravelEnhancements
local addon = FTE.addon
local savedVars = {
    hideMapKeybind = nil, --- @type boolean
    lastTab = nil         --- @type string
}
local FtCategoryNames = {
    All = GetString(FASTER_TRAVEL_WAYSHRINES_CATEGORY_ALL),
    Favorites = GetString(FASTER_TRAVEL_WAYSHRINES_CATEGORY_FAVOURITES),
    Recent = GetString(FASTER_TRAVEL_WAYSHRINES_CATEGORY_RECENT)
}


--- original FasterTravel fill recent and favorite categories without zoneId,
--- and it's a bug - you cant navigate by right-click to the wayshrine
local function FixZoneIndexForFavoriteAndRecent()
    local function afterRefreshFixRecentAndFavorites()
        local categories = {}
        for _, category in ipairs(FT.MapTabWayshrines.categories) do
            if (category.name == FtCategoryNames.All
                    or category.name == FtCategoryNames.Favorites
                    or category.name == FtCategoryNames.Recent
                ) then
                categories[category.name] = category.data

                if (#categories == 3) then break end
            end
        end

        local allWayshrines = categories[FtCategoryNames.All]
        local lookup = {}
        for _, data in ipairs(allWayshrines)
        do
            lookup[data.nodeIndex] = data.zoneIndex
        end

        local wayshrineNeedToFixArrays =
        {
            categories[FtCategoryNames.Favorites],
            categories[FtCategoryNames.Recent]
        }

        for _, array in ipairs(wayshrineNeedToFixArrays) do
            for _, el in ipairs(array) do
                el.zoneIndex = el.zoneIndex or lookup[el.nodeIndex]
            end
        end
    end

    FTE.wayshrineTab.Refresh = FT.hook(FTE.wayshrineTab.Refresh,
        function(refresh, ...)
            local refreshResult = refresh(...)
            afterRefreshFixRecentAndFavorites()
            return refreshResult
        end)
end

--- save last tab NAME and try to find and restore after game restart
--- probably in the future may change to tab index/number (but it's required cycle each time when close map)
local function FixLastTab()
    -- always save last selected map tab
    SCENE_MANAGER:GetScene('worldMap'):RegisterCallback("StateChange",
        function(oldState, newState)
            if (newState ~= SCENE_HIDDEN) then return end
            savedVars.lastTab = GetString(WORLD_MAP_INFO.modeBar.lastFragmentName)
        end)



    local function findMapTabDescriptorByTabName(tabName)
        for _, btn in ipairs(WORLD_MAP_INFO.modeBar.buttonData) do
            local currentName = GetString(btn.descriptor)
            if (tabName == currentName) then
                return btn.descriptor
            end
        end
    end

    -- optional restore previous saved tab (only if already selected )
    local isLastTabSettingEnabled =
        FT.Options.initial_tab[FT.settings.initial_tab].value == FASTER_TRAVEL_SETTINGS_INITIAL_TAB_LAST


    if (isLastTabSettingEnabled and savedVars.lastTab ~= nil) then
        WORLD_MAP_INFO.SelectTab = FT.hook(WORLD_MAP_INFO.SelectTab,
            function(base, self, tabId)
                local tabIdToOpen = findMapTabDescriptorByTabName(savedVars.lastTab) or tabId
                WORLD_MAP_INFO.SelectTab = base
                return base(self, tabIdToOpen)
            end)
    end
end

--- that functions hook map keybindigs from FasterTravel
--- and override visible function - add new condition - disable button flag is not active
local function HideFastTravelMapKeybinding()
    KEYBIND_STRIP.AddKeybindButtonGroup = FT.hook(KEYBIND_STRIP.AddKeybindButtonGroup,
        function(base, self, btn)
            if (btn[1].keybind == "FASTER_TRAVEL_REJUMP") then
                for _, button in ipairs(btn) do
                    if (button.visible ~= nil) then
                        button.visible = FT.hook(button.visible,
                            function(base, ...) return not savedVars.hideMapKeybind and base(...) end)
                    end
                end

                KEYBIND_STRIP.AddKeybindButtonGroup = base
            end

            return base(self, btn)
        end)
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= addon.name then return end

    if not FT then
        zo_callLater(function() d(addon.name .. " cant work without FasterTravel") end, 5000)
        return
    end

    savedVars = ZO_SavedVars:NewAccountWide(addon.name .. "_Data", 1, nil, savedVars)
    FTE.savedVars = savedVars

    FTE.Settings.Initialize(addon, savedVars)

    FixLastTab()
    FixZoneIndexForFavoriteAndRecent()
    HideFastTravelMapKeybinding()
end


-- override init method asap to hook creation of object
FT.MapTabWayshrines.init = FT.hook(FT.MapTabWayshrines.init,
    function(init, self, ...)
        local initResult = init(self, ...)
        local wayshrineTab = self
        FTE.wayshrineTab = wayshrineTab
        return initResult
    end)

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
