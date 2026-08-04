-- Initials
----------------------------------------------------------------

local Addon = {
    name    = 'HonestWrits',
    title   = 'Honest Writs',
    version = '1.3.1',
    options = {},

    meta = {
        init      = false,
        svVersion = '1'
    },

    data = {
        stations = {},
    }
}

local defaultOptions = {
    ['STATIONS'] = {
        ['ALCHEMY']    = false,
        ['ENCHANTING'] = false,
        ['SMITHING']   = false,

        -- todo: Add support for separate smithing stations
        -- ['BLACKSMITHING'] = false,
        -- ['CLOTHING']      = false,
        -- ['WOODWORKING']   = false
    }
}

-- Functions (General)
----------------------------------------------------------------

local function _P(msg)
    CHAT_SYSTEM:AddMessage(string.format('[|cFF2222D|r] [|cFFD966' .. Addon.title .. '|r] %s', tostring(msg)))
end

-- Functions
----------------------------------------------------------------

local function _InitializeOptions(...)
    LibAddonMenu2:RegisterAddonPanel(Addon.name .. '_Config', {
        type                = 'panel',
        name                = Addon.name,
        displayName         = '|cFFD966' .. Addon.title .. '|r',
        author              = '|cFFFFFFSerious Angel|r',
        version             = Addon.version,
        registerForRefresh  = true,
        registerForDefaults = true,
        website             = 'https://esoui.com/downloads/fileinfo.php?id=4011',
    })

    Addon.options = ZO_SavedVars:NewAccountWide(Addon.name .. 'SavedVars', Addon.meta.svVersion, GetWorldName(), defaultOptions)

    local optionsData={
        {
            type = 'header',
            name = 'Revealed Writ Quest Pins Stations',
        },
        {
            type    = 'checkbox',
            name    = 'Alchemy (Ingredients)',
            default = defaultOptions['STATIONS']['ALCHEMY'],
            getFunc = function() return Addon.options['STATIONS']['ALCHEMY'] end,
            setFunc = function(value) Addon.options['STATIONS']['ALCHEMY'] = value end,
        },
        {
            type    = 'checkbox',
            name    = 'Enchanting (Runes)',
            default = defaultOptions['STATIONS']['ENCHANTING'],
            getFunc = function() return Addon.options['STATIONS']['ENCHANTING'] end,
            setFunc = function(value) Addon.options['STATIONS']['ENCHANTING'] = value end,
        },
        {
            type    = 'checkbox',
            name    = 'Smithing',
            default = defaultOptions['STATIONS']['SMITHING'],
            getFunc = function() return Addon.options['STATIONS']['SMITHING'] end,
            setFunc = function(value) Addon.options['STATIONS']['SMITHING'] = value end,
        },

        -- todo: Add support for separate smithing stations
        -- {
        --     type    = 'checkbox',
        --     name    = 'Blacksmithing',
        --     default = defaultOptions['STATIONS']['BLACKSMITHING'],
        --     getFunc = function() return Addon.options['STATIONS']['BLACKSMITHING'] end,
        --     setFunc = function(value) Addon.options['STATIONS']['BLACKSMITHING'] = value end,
        -- },
        -- {
        --     type    = 'checkbox',
        --     name    = 'Clothing',
        --     default = defaultOptions['STATIONS']['CLOTHING'],
        --     getFunc = function() return Addon.options['STATIONS']['CLOTHING'] end,
        --     setFunc = function(value) Addon.options['STATIONS']['CLOTHING'] = value end,
        -- },
        -- {
        --     type    = 'checkbox',
        --     name    = 'Woodworking',
        --     default = defaultOptions['STATIONS']['WOODWORKING'],
        --     getFunc = function() return Addon.options['STATIONS']['WOODWORKING'] end,
        --     setFunc = function(value) Addon.options['STATIONS']['WOODWORKING'] = value end,
        -- },
    }

    LibAddonMenu2:RegisterOptionControls(Addon.name .. '_Config', optionsData)
end

local function _FindQuestPin(control)
    if not control then
        return nil
    end

    -- Try all common Quest pin references.

    local questPin = control.questPin

    if questPin then
        return questPin
    end

    local questPin = control:GetNamedChild("QuestPin")

    if questPin then
        return questPin
    end

    -- Try looping the control children with a possible Quest pin (e.g. Enchanting station).

    local numChildren = control:GetNumChildren()

    for i = 1, numChildren do
        local questPin = _FindQuestPin(control:GetChild(i))

        -- If found the Quest pin.
        if questPin then
            return questPin
        end
    end

    -- No Quest pin was found.

    return nil
end

local function _HideQuestPin(questPin, itemType, force)
    -- If no Quest pin found
    if not questPin then
        return false
    end

    local initialVisibility = not questPin:IsHidden()

    -- If Quest pin is visible, or force hide
    if initialVisibility or force then
        questPin:SetHidden(true)

        -- If already was hid (forced)
        if not initialVisibility then
            return true
        end

        -- If the state did not change (still visible)
        if not questPin:IsHidden() then
            _P("[-] Sorry. Failed to hide a Quest pin: " .. tostring(questPin:GetName()))

            return false
        end

        -- Visibility state changed (hid).

        -- _P('[+] Hurray! Hid Quest pin in of type: ' .. tostring(itemType))

        return true
    end

    return false
end

local function _HandleQuestPin(control, itemType)
    -- Try finding the Quest pin.
    local questPin = _FindQuestPin(control)

    -- If no Quest pin found
    if not questPin then
        return
    end

    -- Found a Quest pin. Hurray!

    -- Try hiding!
    _HideQuestPin(questPin, itemType)

    -- Try hide again, but on the next closest frames.
    -- This should solve the case as the Enchanting station, where Quest pins appear still visible on the first attempt (as of 2026-05).
    zo_callLater(function()
        if not questPin then
            return
        end

        _HideQuestPin(questPin, itemType .. '_later')
    end, 0)
end

local function _HandleStationListContents(listControl, station, itemType)
    local enabledStations = Addon.options['STATIONS']

    -- If we should not hide the Quest pins for the now "enabled" station
    if enabledStations[station] then
        return false
    end

    local childrenCount = listControl:GetNumChildren()

    -- Each tab (e.g. 1=Rune1, 2=Rune2 etc.).
    for i = 1, childrenCount do
        local rowControl = listControl:GetChild(i)

        if rowControl then
            _HandleQuestPin(rowControl, itemType)
        end
    end
end

local function _HandleEnchantingVisibleRows(list, itemType)
    if not list or not list.activeControls then
        return
    end

    for _, rowControl in pairs(list.activeControls) do
        if rowControl then
            _HandleQuestPin(rowControl, itemType)
        end
    end
end

local function _SetAlchemyCraftingStationHooks()
    if not Addon.data.stations.alchemy then
        _P('[-] No Alchemy station found.')

        return false
    end

    -- If already set
    if Addon.data.stations.alchemy._honestWrits then
        return true
    end

    local alchemyStation = Addon.data.stations.alchemy

    if not (alchemyStation.creationButton and alchemyStation.recipeButton) then
        _P('[-] Unexpected state of Alchemy station.')

        return false
    end

    local list = Addon.data.stations.alchemy.inventory.list

    if not list then
        return false
    end

    -- 1="ZO_AlchemyTopLevellnventoryBackpackContents" (CT_SCROLL)
    local solventsListContents = list:GetChild(1)
    local reagentsListContents = list:GetChild(2)

    if not solventsListContents or not reagentsListContents then
        return false
    end

    local solventsListControl = list.dataTypes[1]
    local reagentsListControl = list.dataTypes[2]

    if not (solventsListControl.setupCallback and reagentsListControl.setupCallback) then
        _P('[-] Could not find original setup function(s) for Alchemy station.')

        return false
    end

    local enabledStations = Addon.options['STATIONS']

    -- Set the hook to hide Quest pins for Alchemy Solvents.

    SecurePostHook(solventsListControl, 'setupCallback', function(rowControl)
        if enabledStations['ALCHEMY'] then
            return false
        end

        _HandleQuestPin(rowControl, 'alchemy_solvents')
    end)

    -- Set the hook to hide Quest pins for Alchemy Reagents.

    SecurePostHook(reagentsListControl, 'setupCallback', function(rowControl)
        if enabledStations['ALCHEMY'] then
            return false
        end

        _HandleQuestPin(rowControl, 'alchemy_reagents')
    end)

    -- Process existing items, if possible (e.g. the first viewable list, prior scrolling).

    _HandleStationListContents(solventsListContents, 'ALCHEMY', 'alchemy_solvents_initial')
    _HandleStationListContents(reagentsListContents, 'ALCHEMY', 'alchemy_reagents_initial')

    alchemyStation._honestWrits = true

    return true
end

local function _SetEnchantingCraftingStationHooks()
    if not Addon.data.stations.enchanting then
        _P('[-] No Enchanting station found.')

        return false
    end

    if Addon.data.stations.enchanting._honestWrits then
        return true
    end

    local enchantingStation = Addon.data.stations.enchanting

    if not (enchantingStation.creationButton and enchantingStation.recipeButton) then
        _P('[-] Unexpected state of Enchanting station.')

        return false
    end

    local runesInventory = enchantingStation.inventory

    if not runesInventory or not runesInventory.list then
        return
    end

    local list = runesInventory.list

    -- 1="ZO_EnchantingTopLevellnventoryBackpackContents" (CT_SCROLL)
    -- 2="ZO_EnchantingTopLevellnventoryBackpackScrollBar" (CT_SLIDER)
    local runesListContents = list:GetChild(1)

    if not runesListContents then
        return false
    end

    local runesListControl = list.dataTypes[1]

    if not runesListControl then
        _P('[-] Could not find Enchanting station Runes list.')

        return false
    end

    local enabledStations = Addon.options['STATIONS']

    -- Set the hook to hide Quest pins for Enchanting Runes list sorting.

    SecurePostHook(runesInventory, "PerformFullRefresh", function()
        if enabledStations['ENCHANTING'] then
            return
        end

        -- They were mentions about caching of the controls in Enchanting, and hence we try getting them again.

        if not runesInventory or not runesInventory.list then
            return
        end

        local runesListContents = runesInventory.list:GetChild(1)

        _HandleStationListContents(runesListContents, 'ENCHANTING', 'enchanting_runes_refresh_list')
        _HandleEnchantingVisibleRows(list, 'enchanting_runes_refresh_rows')
    end)

    -- Set the hook to hide Quest pins for every Enchanting Rune list item creation.

    SecurePostHook(runesListControl, "setupCallback", function(rowControl)
        if enabledStations['ENCHANTING'] then
            return false
        end

        _HandleQuestPin(rowControl, 'enchanting_rune_setup')
    end)

    -- Process existing items, if possible (e.g. the first viewable list, prior scrolling)
    _HandleStationListContents(runesListContents, 'ENCHANTING', 'enchanting_runes_initial')

    enchantingStation._honestWrits = true

    return true
end

local function _SetSmithingCraftingStationHooks(craftingType)
    if not Addon.data.stations.smithing then
        _P('[-] No smithing station found.')

        return false
    end

    -- If already set hooks
    if Addon.data.stations.smithing._honestWrits then
        return true
    end

    local smithingStation = Addon.data.stations.smithing

    if not (smithingStation.creationButton and smithingStation.recipeButton) then
        _P('[-] Unexpected state of Smithing station.')

        return false
    end

    local stationObject = smithingStation
    local enabledStations = Addon.options['STATIONS']
    local creationPanel = stationObject.creationPanel

    if not creationPanel then
        return false
    end

    -- Handle Types (e.g. Weapons, Apparel etc.)
    local function _HandleTypeTabs(tabsControl)
        -- If we should not hide the Quest pins for the now "enabled" station
        if enabledStations['SMITHING'] then
            return false
        end

        local tabs = tabsControl:GetNumChildren()

        -- Each tab (e.g. 2=Weapons, 4=Apparel etc.).
        for i = 1, tabs do
            local tabControl = tabsControl:GetChild(i)

            if tabControl then
                _HandleQuestPin(tabControl, 'smithing_creation_tab')
            end
        end
    end

    -- Handle Panel List (e.g. Patterns, Materials etc.)
    local function _HandlePanelList(list)
        if list.setupFunction then
            -- If we should not hide the Quest pins for the now "enabled" station
            if enabledStations['SMITHING'] then
                return false
            end

            -- Set the main hook (triggers on each scrolling event).

            SecurePostHook(list, 'setupFunction', function(control, data)
                if enabledStations['SMITHING'] then
                    return false
                end

                -- Type tabs may reset (e.g. on type change), so handle them again.
                _HandleTypeTabs(creationPanel.tabs)

                _HandleQuestPin(control, 'smithing_creation')
            end)

            -- Process existing items, if possible (e.g. the first viewable list, prior scrolling).

            if list.controls then
                for _, control in pairs(list.controls) do
                    if control then
                        _HandleQuestPin(control, 'smithing_creation_initial')
                    end
                end
            end
        end
    end

    -- Hide already existing type tabs (e.g. Weapons, Apparel etc.).
    _HandleTypeTabs(creationPanel.tabs)

    -- Handle Pattern list (e.g. Cuirass, Sabatons, Gauntlets, Helm, Greeves, Pauldron, Girdle etc.).
    _HandlePanelList(creationPanel.patternList)

    -- Handle Material list (e.g. Iron Ingot, Steel Ingot, Orichalcum Ingot, Dwraven Ingnot, Ebony Ingot etc.).
    _HandlePanelList(creationPanel.materialList)

    -- Set hooks and initials for Smithing station.

    smithingStation._honestWrits = true

    return true
end

local function _SetHooks()
    if Addon.meta.init then
        return
    end

    EVENT_MANAGER:RegisterForEvent(Addon.name .. '_OnCraftingStationInteract', EVENT_CRAFTING_STATION_INTERACT, function(eventCode, craftingType, isCraftingSameAsPrevious)
        if craftingType == CRAFTING_TYPE_ALCHEMY then
            -- If not yet set
            if not Addon.data.stations.alchemy or not Addon.data.stations.alchemy._honestWrits then
                Addon.data.stations.alchemy = ALCHEMY

                _SetAlchemyCraftingStationHooks()
            end

            return
        end

        if craftingType == CRAFTING_TYPE_ENCHANTING then
            -- If not yet set
            if not Addon.data.stations.enchanting or not Addon.data.stations.enchanting._honestWrits then
                Addon.data.stations.enchanting = ENCHANTING

                _SetEnchantingCraftingStationHooks()
            end

            return
        end

        -- todo: Currently, this works for any "smithing" station, yet we need to separate them.
        if craftingType == CRAFTING_TYPE_BLACKSMITHING or craftingType == CRAFTING_TYPE_WOODWORKING or craftingType == CRAFTING_TYPE_CLOTHIER then
            -- If not yet set
            if not Addon.data.stations.smithing or not Addon.data.stations.smithing._honestWrits then
                -- On each mode change (1=Refine, 2=Creation, 3=Deconstruct, 4=Improvement, 5=Research, and 6=Diagrams).
                SecurePostHook(SMITHING, 'SetMode', function(_, mode)
                    -- If not "Creation" mode
                    if mode ~= 2 then
                        return
                    end

                    Addon.data.stations.smithing = SMITHING

                    _SetSmithingCraftingStationHooks(craftingType)
                end)
            end

            return
        end
    end)
end

-- Main
----------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(Addon.name .. '_OnAddonLoaded', EVENT_ADD_ON_LOADED, function(event, addonName)
    if addonName ~= Addon.name or Addon.meta.init then
        return
    end

    _InitializeOptions()
    _SetHooks()

    Addon.meta.init = true

    EVENT_MANAGER:UnregisterForEvent(Addon.name .. '_OnAddonLoaded', EVENT_ADD_ON_LOADED)
end)