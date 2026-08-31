--[[
Furniture Locator - Category/Style Dialogs (LibConsoleDialogs)

Real, confirmed-working A-confirm/B-back button navigation for picking
a category and then a style within it -- built on LibConsoleDialogs
(votan, esoui.com), which wraps LibHarvensAddonSettings' proven console
UI machinery. This sidesteps the KEYBIND_STRIP problem entirely for
these two picking steps, since LibConsoleDialogs handles that correctly
where our own custom ZO_Gamepad_ParametricList_Screen did not (confirmed
by an independent bug report on LibConsoleDialogs' own page describing
the identical symptom: keybinds work on real game scenes, not on
non-standard/nested ones).

Flow:
  ShowCategoryDialog() -- one button per category, opens...
  ShowStyleDialogForCategory(category) -- one button per style present
    in that category (plus "All Styles"), opens the item list screen
    (FurnitureLocatorScreen.lua) filtered accordingly, via
    FURNITURE_LOCATOR_SCREEN_GAMEPAD:ShowFiltered(category, theme).

Both dialogs are rebuilt fresh each time they're shown -- no evidence
LibConsoleDialogs supports clearing/rebuilding an existing dialog's
settings, and the library's own documented example creates separate
dialog objects for separate content rather than reusing one.
]]

FurnitureLocatorDialogs = {}
local this = FurnitureLocatorDialogs

function this.ShowCategoryDialog()
    local ok, err = pcall(function()
        local items = FurnitureLocator.GetAllOwnedItems()

        local categoryCounts = {}
        for _, item in ipairs(items) do
            categoryCounts[item.category] = (categoryCounts[item.category] or 0) + 1
        end

        local categoryNames = {}
        for name, _ in pairs(categoryCounts) do
            table.insert(categoryNames, name)
        end
        table.sort(categoryNames)

        local dialog = LibConsoleDialogs:Create("Furniture Locator - Categories")

        for _, categoryName in ipairs(categoryNames) do
            local capturedCategory = categoryName
            dialog:AddSetting({
                type = LibHarvensAddonSettings.ST_BUTTON,
                label = string.format("%s (%d)", categoryName, categoryCounts[categoryName]),
                buttonText = "View",
                clickHandler = function()
                    this.ShowStyleDialogForCategory(capturedCategory)
                end,
            })
        end

        dialog:Show()
    end)

    if not ok then
        d("Furniture Locator: category dialog ERROR: " .. tostring(err))
    end
end

function this.ShowStyleDialogForCategory(categoryName)
    local ok, err = pcall(function()
        local items = FurnitureLocator.GetAllOwnedItems()

        local themeCounts = {}
        local totalInCategory = 0
        for _, item in ipairs(items) do
            if item.category == categoryName then
                totalInCategory = totalInCategory + 1
                themeCounts[item.theme] = (themeCounts[item.theme] or 0) + 1
            end
        end

        local themeNames = {}
        for name, _ in pairs(themeCounts) do
            table.insert(themeNames, name)
        end
        table.sort(themeNames)

        local dialog = LibConsoleDialogs:Create(string.format("Furniture Locator - %s", tostring(categoryName)))

        dialog:AddSetting({
            type = LibHarvensAddonSettings.ST_BUTTON,
            label = string.format("All Styles (%d)", totalInCategory),
            buttonText = "View",
            clickHandler = function()
                if FURNITURE_LOCATOR_SCREEN_GAMEPAD then
                    FURNITURE_LOCATOR_SCREEN_GAMEPAD:ShowFiltered(categoryName, nil)
                end
            end,
        })

        for _, themeName in ipairs(themeNames) do
            local capturedTheme = themeName
            dialog:AddSetting({
                type = LibHarvensAddonSettings.ST_BUTTON,
                label = string.format("%s (%d)", themeName, themeCounts[themeName]),
                buttonText = "View",
                clickHandler = function()
                    if FURNITURE_LOCATOR_SCREEN_GAMEPAD then
                        FURNITURE_LOCATOR_SCREEN_GAMEPAD:ShowFiltered(categoryName, capturedTheme)
                    end
                end,
            })
        end

        dialog:Show()
    end)

    if not ok then
        d("Furniture Locator: style dialog ERROR: " .. tostring(err))
    end
end

local ADDON_PACKAGE_NAME = "FurnitureLocator"

local function OnAddOnLoaded(_, addOnName)
    if addOnName ~= ADDON_PACKAGE_NAME then
        return
    end
    EVENT_MANAGER:UnregisterForEvent("FurnitureLocatorDialogs", EVENT_ADD_ON_LOADED)

    SLASH_COMMANDS["/flocator2"] = function()
        this.ShowCategoryDialog()
    end
    d("Furniture Locator dialogs loaded. /flocator2 opens the category picker (real button navigation).")
end

EVENT_MANAGER:RegisterForEvent("FurnitureLocatorDialogs", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
