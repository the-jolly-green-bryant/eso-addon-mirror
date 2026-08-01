local addon = QualitySort
local dataVersion2Upgrade

----------------- Settings -----------------------
local COLOR_DISABLED = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_DISABLED))
local NONE = COLOR_DISABLED:Colorize(zo_strformat(GetString(SI_QUEST_TYPE_FORMAT), GetString(SI_ITEMTYPE0)))
local INDENT = "|t420%:100%:esoui/art/worldmap/worldmap_map_background.dds|t"

local function SwapDropdownValues(settings, optionIndex, value)
    if value == "" then
        settings[optionIndex] = value
        return
    end
    local oldValue = settings[optionIndex]
    for swapOptionIndex=1,#settings do
        local swapValue = settings[swapOptionIndex]
        if swapValue == value then
            settings[swapOptionIndex] = oldValue
            settings[optionIndex] = value
            return swapOptionIndex
        end
    end
    settings[optionIndex] = value
end
local function CreateSortOrderOption(optionsTable, optionIndex)
    local self = addon
    table.insert(optionsTable, {
        type = "dropdown",
        width = "half",
        choices = self.sortOrderOptions,
        choicesValues = self.sortOrderValues,
        name = INDENT .. tostring(optionIndex),
        getFunc = function() return self.settings.sortOrder[optionIndex] end,
        setFunc = function(value)
            local swapOptionIndex = SwapDropdownValues(self.settings.sortOrder, optionIndex, value)
            if swapOptionIndex then
                local tmpSortDirection = self.settings.sortDirection[swapOptionIndex]
                self.settings.sortDirection[swapOptionIndex] = self.settings.sortDirection[optionIndex]
                self.settings.sortDirection[optionIndex] = tmpSortDirection
            end
        end,
        default = self.defaults.sortOrder[optionIndex]
    })
end
local function CreateSortDirectionOption(optionsTable, optionIndex)
    local self = addon
    table.insert(optionsTable, {
        type = "dropdown",
        width = "half",
        choices = self.sortDirectionChoices,
        choicesValues = self.sortDirectionChoicesValues,
        getFunc = function() return self.settings.sortDirection[self.settings.sortOrder[optionIndex]] end,
        setFunc = function(value) self.settings.sortDirection[self.settings.sortOrder[optionIndex]] = value end,
        default = self.defaults.sortDirection[self.settings.sortOrder[optionIndex]],
        disabled = function() return self.settings.sortOrder[optionIndex] == "" end,
    })
end

function addon:SetupOptions()
    
    -- Setup saved vars
    self.settings = LibSavedVars:NewAccountWide(self.name .. "_Account", self.defaults)
                                :AddCharacterSettingsToggle(self.name .. "_Character")
                                :Version(2, dataVersion2Upgrade)
    
    if LSV_Data.EnableDefaultsTrimming then
        self.settings:EnableDefaultsTrimming()
    end
    
    -- Generate alphabetical list of sort order options in the current language
    local sortOrderValuesByOption = { [NONE] = "" }
    self.sortOrderOptions = { NONE }
    for value, option in pairs(self.sortOrders) do
        sortOrderValuesByOption[option] = value
        table.insert(self.sortOrderOptions, option)
    end
    table.sort(self.sortOrderOptions)
    self.sortOrderValues = {}
    for i=1,#self.sortOrderOptions do
        table.insert(self.sortOrderValues, sortOrderValuesByOption[self.sortOrderOptions[i]])
    end
    
    --Setup options panel
    local panelData = {
        type = "panel",
        name = self.title,
        displayName = self.title,
        author = self.author,
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LibAddonMenu2:RegisterAddonPanel(self.name .. "Options", panelData)
    self.sortDirectionChoices = {GetString(SI_QUALITYSORT_DESCENDING), GetString(SI_QUALITYSORT_ASCENDING)}
    self.sortDirectionChoicesValues = {QUALITYSORT_DIR_DESC, QUALITYSORT_DIR_ASC}
    local optionsTable = { 
        
        -- Account-wide settings
        self.settings:GetLibAddonMenuAccountCheckbox(),
        
        -- Automatic sort
        {
            type = "checkbox",
            name = GetString(SI_QUALITYSORT_AUTO),
            getFunc = function() return self.settings.automatic end,
            setFunc = function(value) self.settings.automatic = value end,
            width = "full",
            default = self.defaults.automatic,
        },
    }
    
    local sortOrderControls = {
        {
            type  = "divider",
            width = "full",
        },
    }
    local optionCount = #self.sortOrderOptions - 1
    for optionIndex = 1, optionCount do
        CreateSortOrderOption(sortOrderControls, optionIndex)
        CreateSortDirectionOption(sortOrderControls, optionIndex)
    end
    table.insert(optionsTable,
        -- Submenu
        {
            type = "submenu",
            name = GetString(SI_QUALITYSORT_SORT_ORDER),
            controls = sortOrderControls,
        })

    LibAddonMenu2:RegisterOptionControls(self.name .. "Options", optionsTable)
end


-- Local functions

function dataVersion2Upgrade(settings)
    if settings.sortOrder then
        table.insert(settings.sortOrder, 1, "quality")
    end
end