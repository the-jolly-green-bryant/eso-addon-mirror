local LAM = LibAddonMenu2
AlchemyOpener = AlchemyOpener or {}
AlchemyOpenerSettings = AlchemyOpenerSettings or {}

local function BuildItemChoices()
    local orderedKeys = { "waxed_apothecary", "custom" }
    local choices = {}
    local choicesValues = {}

    for _, itemKey in ipairs(orderedKeys) do
        local itemData = AlchemyOpener.itemOptions and AlchemyOpener.itemOptions[itemKey]
        if itemData then
            table.insert(choices, itemData.label)
            table.insert(choicesValues, itemKey)
        end
    end

    return choices, choicesValues
end

local function InitializeSettings()
    local panelData = {
        type = "panel",
        name = "AlchemyOpener",
        displayName = "AlchemyOpener Settings",
        author = "Awh_Lina",
        version = AlchemyOpener.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local choices, choicesValues = BuildItemChoices()

    AlchemyOpenerSettings.settingsPanel = LAM:RegisterAddonPanel("AlchemyOpenerSettingsPanel", panelData)
    AlchemyOpener.db = AlchemyOpener.db or ZO_SavedVars:New("AlchemyOpenerSettings", 1, nil, AlchemyOpener.defaults_db)

    local optionsData = {
        {
            type = "checkbox",
            name = "Enabled",
            tooltip = "Enable automatic buying and opening.",
            getFunc = function()
                return AlchemyOpener.db.enabled
            end,
            setFunc = function(value)
                AlchemyOpener.db.enabled = value
            end,
        },
        {
            type = "dropdown",
            name = "Target item",
            tooltip = "Choose the default item to buy and open. Use Custom item name for Archival Fortune purchases or any other container.",
            choices = choices,
            choicesValues = choicesValues,
            getFunc = function()
                return AlchemyOpener.db.selectedItemKey
            end,
            setFunc = function(value)
                AlchemyOpener.db.selectedItemKey = value
            end,
            sort = "disabled",
        },
        {
            type = "editbox",
            name = "Custom item name",
            tooltip = "Exact store and inventory item name to buy and open. Use this for the Archival Fortune item you want.",
            getFunc = function()
                return AlchemyOpener.db.customItemName or ""
            end,
            setFunc = function(value)
                AlchemyOpener.db.customItemName = value
            end,
            isMultiline = false,
            width = "full",
            disabled = function()
                return AlchemyOpener.db.selectedItemKey ~= "custom"
            end,
        },
        {
            type = "description",
            text = "Purchases are limited by the currency required by the store entry, then by available backpack space. Potion and draught items can buy up to 100 at once, but only if that exact item is already present in your backpack. For Archival Fortune vendors, select Custom item name and enter the exact item you want to buy and open.",
            width = "full",
        },
    }

    LAM:RegisterOptionControls("AlchemyOpenerSettingsPanel", optionsData)
end

EVENT_MANAGER:RegisterForEvent("AlchemyOpenerSettings", EVENT_ADD_ON_LOADED, function(_, addOnName)
    if addOnName ~= AlchemyOpener.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent("AlchemyOpenerSettings", EVENT_ADD_ON_LOADED)
    InitializeSettings()
end)
