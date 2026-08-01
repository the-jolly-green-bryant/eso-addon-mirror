-- Settings menu.
function GamepadStayMounted.LoadSettings()
    local LAM = LibAddonMenu2

    local panelData = {
        type = "panel",
        name = GamepadStayMounted.menuName,
        displayName = GamepadStayMounted.menuName,
        author = GamepadStayMounted.author,
        version = GamepadStayMounted.appVersion,
        website = "https://www.esoui.com/downloads/info3951-GamepadStayMounted.html",
        feedback = "https://www.esoui.com/forums/private.php?do=newpm&u=35341",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(GamepadStayMounted.menuName, panelData)

    local optionsTable = {}

    table.insert(optionsTable, {
            type = "checkbox",
            name = "Allow 'Use' interactions",
            tooltip = "Allow interactions with objects where the action is 'Use'",
            getFunc = function()  return GamepadStayMounted.saved.allowUse end,
            setFunc = function(v) GamepadStayMounted.saved.allowUse = v end,
            width = "full"
        })
    
    table.insert(optionsTable, {
        type = "checkbox",
        name = "Allow 'Open' interactions",
        tooltip = "Allow interactions with objects where the action is 'Open'",
        getFunc = function()  return GamepadStayMounted.saved.allowOpen end,
        setFunc = function(v) GamepadStayMounted.saved.allowOpen = v end,
        width = "full"
    })

    LAM:RegisterOptionControls(GamepadStayMounted.menuName, optionsTable)
end