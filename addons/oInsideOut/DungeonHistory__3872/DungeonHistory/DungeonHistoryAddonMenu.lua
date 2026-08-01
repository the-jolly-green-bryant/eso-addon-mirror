DungeonHistory.AddonMenu = {}

DungeonHistory.AddonMenu.LAM2 = LibAddonMenu2
DungeonHistory.AddonMenu.panelName = "DungeonHistorySettingsPanel"

DungeonHistory.AddonMenu.panelData = {
    type = "panel",
    name = "DungeonHistory",
    author = "oInsideOut",
    version = DungeonHistory.version,
    website = "https://www.esoui.com/downloads/info3872-DungeonHistory.html",
    feedback = "https://www.esoui.com/downloads/info3872-DungeonHistory.html#comments"
}

DungeonHistory.AddonMenu.optionsData = {
    [1] = {
        type = "header",
        name = "UI Settings"
    },
    [2] = {
        type = "checkbox",
        name = "Date Format m/d/Y",
        tooltip = "Change the Date Format to Month/Day/Year",
        getFunc = function () return DungeonHistory.saveData.options.dateMDY end,
        setFunc = function (value) DungeonHistory.saveData.options.dateMDY = value DungeonHistory.XML.FillListSavedVariables() DungeonHistory.XML.SL.DungeonList:Refresh() end
    },
    [3] = {
        type = "divider",
    },
    [4] = {
        type = "button",
        name = "Erase All Data",
        func = DungeonHistory.eraseAllData,
        warning = "The data cannot be restored after you have confirmed the action. Reload the UI or restart the game for it to take effect.",
        tooltip = "Erases all data from the SavedVariables table and reloads back the Defaults.",
        isDangerous = true
    },
}