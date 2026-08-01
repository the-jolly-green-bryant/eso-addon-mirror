local LAM2 = LibAddonMenu2

local panelData = {
    type = "panel",
    name = "Sauhaufen",
    displayName = "Sauhaufen",
    author = "|cFFC0CBm00ny|r",
    version = "2.0.0",
    website = "https://Sauhaufen.eu",
    slashCommand = "/shsettings",	--(optional) will register a keybind to open to this panel
    registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
    registerForDefaults = true,	--boolean (optional) (will set all options controls back to default values)
}

local optionsTable = {
    [1] = {
        type = "header",
        name = "Chat Einstellungen",
        width = "full",	--or "half" (optional)
    },
    [2] = {
        type = "checkbox",
        name = "MOTD",
        tooltip = "Aktiviert/Deaktiviert die MOTD beim Einloggen",
        getFunc = function() return Sauhaufen.savedVariables.showMOTD end,
        setFunc = function(value) Sauhaufen.savedVariables.showMOTD = value end,
        width = "half",	--or "half" (optional)
        default = true,
        --warning = "Will need to reload the UI.",	--(optional)
    },
    [3] = {
        type = "checkbox",
        name = "Online",
        tooltip = "Aktiviert/Deaktiviert das Anzeigen der Online Spieler im Chat",
        getFunc = function() return Sauhaufen.savedVariables.showOnline end,
        setFunc = function(value) Sauhaufen.savedVariables.showOnline = value end,
        width = "half",	--or "half" (optional)
        default = true,
        --warning = "Will need to reload the UI.",	--(optional)
    },
    [4] = {
        type = "header",
        name = "Oberflächeneinstellungen",
        width = "full",	--or "half" (optional)
    },
    [5] = {
        type = "checkbox",
        name = "Sauhaufen Addon Button anzeigen",
        tooltip = "Zeigt/Versteckt den Sauhaufen Menuknopf auf dem Bildschirm",
        getFunc = function() return Sauhaufen.savedVariables.showAddonButton end,
        setFunc = function(value) Sauhaufen.savedVariables.showAddonButton = value; Sauhaufen.GUISetup() end,
        width = "half",	--or "half" (optional)
        default = true,
        --warning = "Will need to reload the UI.",	--(optional)
    },
}

LAM2:RegisterAddonPanel("Sauhaufen", panelData)
LAM2:RegisterOptionControls("Sauhaufen", optionsTable)