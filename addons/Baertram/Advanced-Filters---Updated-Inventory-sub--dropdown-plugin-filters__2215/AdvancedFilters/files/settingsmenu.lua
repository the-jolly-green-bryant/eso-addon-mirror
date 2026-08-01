AdvancedFilters = AdvancedFilters or {}
local AF = AdvancedFilters

function AF.LAMSettingsMenu()
    --Library LibStub was loaded and library LibAddonMenu exists?
    --Create the settings panel object of libAddonMenu 2.0
    if AF.LAM == nil then return end

    --Function loaded as AF LAM panel got cretaed
    --local function AFLAMPanelCreated()
    --end

    --Build the LAM addon menu
    local function BuildAddonMenu()
        local defSettings = AF.defaultSettings
        local settings = AF.settings
        local strings = AF.strings

        local panelData = {
            type 				= 'panel',
            name 				= AF.name,
            displayName 		= AF.name,
            author 				= AF.author,
            version 			= AF.version,
            registerForRefresh 	= true,
            registerForDefaults = true,
            slashCommand 		= "/afs",
            website             = AF.website,
            feedback            = AF.feedback,
            donation            = AF.donation,
        }
        --The LibAddonMenu2.0 settings panel reference variable
        AF.LAMsettingsPanel = AF.LAM:RegisterAddonPanel(AF.name .. "_LAM", panelData)

------------------------------------------------------------------------------------------------------------------------
        local optionsTableSubmenuDebug = {}
        --For debugging
        local debugCb = {
            type = "checkbox",
            name = strings.lamDebugOutput,
            tooltip = strings.lamDebugOutputTT,
            getFunc = function() return settings.doDebugOutput end,
            setFunc = function(value)
                AF.settings.doDebugOutput = value
            end,
            default = defSettings.doDebugOutput,
        }
        table.insert(optionsTableSubmenuDebug, debugCb)
        local cbDebugSpam =             {
            type = "checkbox",
            name = strings.lamDebugSpamOutput,
            tooltip = strings.lamDebugSpamOutputTT,
            warning= strings.lamDebugSpamOutputTT,
            getFunc = function() return settings.debugSpam end,
            setFunc = function(value)
                AF.settings.debugSpam = value
            end,
            default = defSettings.debugSpam,
        }
        table.insert(optionsTableSubmenuDebug, cbDebugSpam)
        local cbDebugSpamRefreshSubfilterBarExclude =             {
            type = "checkbox",
            name = strings.lamDebugSpamExcludeRefreshSubfilterBar,
            tooltip = strings.lamDebugSpamExcludeRefreshSubfilterBar,
            getFunc = function() return settings.debugSpamExcludeRefreshSubfilterBar end,
            setFunc = function(value)
                AF.settings.debugSpamExcludeRefreshSubfilterBar = value
            end,
            disabled = function() return not AF.settings.debugSpam end,
            default = defSettings.debugSpamExcludeRefreshSubfilterBar,
        }
        table.insert(optionsTableSubmenuDebug, cbDebugSpamRefreshSubfilterBarExclude)
        local cbDebugSpamDropdownBoxfilterExclude =             {
            type = "checkbox",
            name = strings.lamDebugSpamExcludeDropdownBoxFilters,
            tooltip = strings.lamDebugSpamExcludeDropdownBoxFilters,
            getFunc = function() return settings.debugSpamExcludeDropdownBoxFilters end,
            setFunc = function(value)
                AF.settings.debugSpamExcludeDropdownBoxFilters = value
            end,
            disabled = function() return not AF.settings.debugSpam end,
            default = defSettings.debugSpamExcludeDropdownBoxFilters,
        }
        table.insert(optionsTableSubmenuDebug, cbDebugSpamDropdownBoxfilterExclude)

------------------------------------------------------------------------------------------------------------------------
        --The option controls for the LAM 2.0 panel
        local optionsTable =
        {	-- BEGIN OF OPTIONS TABLE

            {
                type = 'description',
                text = strings.lamDescription,
            },
            --==============================================================================
            {
                type = 'header',
                name = strings.lamHeaderVisual,
            },
            --==============================================================================
            {
                type = "checkbox",
                name = strings.lamHideItemCount,
                tooltip = strings.lamHideItemCountTT,
                getFunc = function() return settings.hideItemCount end,
                setFunc = function(value)
                    AF.settings.hideItemCount = value
                end,
                default = defSettings.hideItemCount,
            },
            {
                type = "colorpicker",
                name = strings.lamHideItemCountColor,
                tooltip = strings.lamHideItemCountColorTT,
                getFunc = function() return AF.settings.itemCountLabelColor["r"], AF.settings.itemCountLabelColor["g"], AF.settings.itemCountLabelColor["b"], AF.settings.itemCountLabelColor["a"] end,
                setFunc = function(r,g,b,a)
                    AF.settings.itemCountLabelColor["r"] = r
                    AF.settings.itemCountLabelColor["g"] = g
                    AF.settings.itemCountLabelColor["b"] = b
                    AF.settings.itemCountLabelColor["a"] = a
                end,
                --default = defSettings.itemCountLabelColor,
                disabled = function() return settings.hideItemCount end,
            },
            --==============================================================================
            {
                type = 'header',
                name = strings.lamHeaderFilterCategory,
            },
            --==============================================================================
            {
                type = "checkbox",
                name = strings.lamHideSubFilterLabel,
                tooltip = strings.lamHideSubFilterLabelTT,
                getFunc = function() return settings.hideSubFilterLabel end,
                setFunc = function(value)
                    AF.settings.hideSubFilterLabel = value
                end,
                default = defSettings.hideSubFilterLabel,
            },
            --==============================================================================
            {
                type = 'header',
                name = strings.lamHeaderSubfilter,
            },
            --==============================================================================
            {
                type = "checkbox",
                name = strings.lamGrayOutSubFiltersWithNoItems,
                tooltip = strings.lamGrayOutSubFiltersWithNoItemsTT,
                getFunc = function() return settings.grayOutSubFiltersWithNoItems end,
                setFunc = function(value)
                    AF.settings.grayOutSubFiltersWithNoItems = value
                end,
                default = defSettings.grayOutSubFiltersWithNoItems,
            },
            --==============================================================================
            {
                type = "checkbox",
                name = strings.lamHideCharBoundAtBankDeposit,
                tooltip = strings.lamHideCharBoundAtBankDepositTT,
                getFunc = function() return settings.hideCharBoundAtBankDeposit end,
                setFunc = function(value)
                    AF.settings.hideCharBoundAtBankDeposit = value
                end,
                default = defSettings.hideCharBoundAtBankDeposit,
            },
            --==============================================================================
            --[[
            {
                type = "checkbox",
                name = strings.lamShowFilterDropdownMenuOnRightMouse,
                tooltip = strings.lamShowFilterDropdownMenuOnRightMouseTT,
                getFunc = function() return settings.showFilterDropdownMenuOnRightMouseAtSubFilterButton end,
                setFunc = function(value)
                    AF.settings.showFilterDropdownMenuOnRightMouseAtSubFilterButton = value
                end,
                default = defSettings.showFilterDropdownMenuOnRightMouseAtSubFilterButton,
                requiresReload = true,
            },
            ]]
            --==============================================================================
            {
                type = 'header',
                name = strings.lamHeaderDropdownFilterbox,
            },
            --==============================================================================
            {
                type = "checkbox",
                name = strings.lamShowIconsInFilterDropdowns,
                tooltip = strings.lamShowIconsInFilterDropdownsTT,
                getFunc = function() return settings.showIconsInFilterDropdowns end,
                setFunc = function(value)
                    AF.settings.showIconsInFilterDropdowns = value
                end,
                default = defSettings.showIconsInFilterDropdowns,
            },
            --==============================================================================
            {
                type = "checkbox",
                name = strings.lamShowSubMenuHeaderlinesInFilterDropdowns,
                tooltip = strings.lamShowSubMenuHeaderlinesInFilterDropdownsTT,
                getFunc = function() return settings.showSubMenuHeaderlinesInFilterDropdowns end,
                setFunc = function(value)
                    AF.settings.showSubMenuHeaderlinesInFilterDropdowns = value
                end,
                default = defSettings.showSubMenuHeaderlinesInFilterDropdowns,
            },
            --==============================================================================
            {
                type = "checkbox",
                name = strings.lamRememberFilterDropdownsLastSelection,
                tooltip = strings.lamRememberFilterDropdownsLastSelectionTT,
                getFunc = function() return settings.rememberFilterDropdownsLastSelection end,
                setFunc = function(value)
                    AF.settings.rememberFilterDropdownsLastSelection = value
                end,
                default = defSettings.rememberFilterDropdownsLastSelection,
            },
            --==============================================================================
            {
                type = "checkbox",
                name = strings.lamShowDropdownSelectedReminderAnimation,
                tooltip = strings.lamShowDropdownSelectedReminderAnimationTT,
                getFunc = function() return settings.showDropdownSelectedReminderAnimation end,
                setFunc = function(value)
                    AF.settings.showDropdownSelectedReminderAnimation = value
                end,
                default = defSettings.showDropdownSelectedReminderAnimation,
                disabled = function() return not settings.rememberFilterDropdownsLastSelection end,
            },
            --==============================================================================
            {
                type = "slider",
                name = strings.lamDropdownVisibleRows,
                tooltip = strings.lamDropdownVisibleRowsTT,
                min = 5,
                max = 30,
                step = 1, -- (optional)
                getFunc = function() return settings.dropdownVisibleRows end,
                setFunc = function(value)
                    AF.settings.dropdownVisibleRows = value
                end,
                default = defSettings.dropdownVisibleRows,
                requiresReload = true,
            },
            --==============================================================================
            {
                type = "slider",
                name = strings.lamDropdownVisibleSubmenuRows,
                tooltip = strings.lamDropdownVisibleSubmenuRowsTT,
                min = 5,
                max = 30,
                step = 1, -- (optional)
                getFunc = function() return settings.dropdownVisibleSubmenuRows end,
                setFunc = function(value)
                    AF.settings.dropdownVisibleSubmenuRows = value
                end,
                default = defSettings.dropdownVisibleSubmenuRows,
                requiresReload = true,
            },


            --==============================================================================
            --[[
            {
                type = "checkbox",
                name = strings.lamShowDropdownLastSelectedEntries,
                tooltip = strings.lamShowDropdownLastSelectedEntriesTT,
                getFunc = function() return settings.showDropdownLastSelectedEntries end,
                setFunc = function(value)
                    AF.settings.showDropdownLastSelectedEntries = value
                end,
                default = defSettings.showDropdownLastSelectedEntries,
            },
            ]]
            --==============================================================================
            --                              DEBUG
            --==============================================================================
            {
                type = "submenu",
                name = strings.lamDebugOutput,
                controls = optionsTableSubmenuDebug
            },

        } -- END OF OPTIONS TABLE
        --CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", AFLAMPanelCreated)
        AF.LAM:RegisterOptionControls(AF.name .. "_LAM", optionsTable)
    end

    --Build the LAM options menu now
    BuildAddonMenu()
end