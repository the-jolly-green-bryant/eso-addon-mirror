ChatSkipper = ChatSkipper or {}

function ChatSkipper.InitSavedVariables()
    ChatSkipper.SavedVariables = ZO_SavedVars:NewCharacterIdSettings("ChatSkipperVars", 1, nil, nil)
    if (ChatSkipper.SavedVariables.SkipDialogues == nil) then
        ChatSkipper.SavedVariables.SkipDialogues = true
    end
    if (ChatSkipper.SavedVariables.SkipBooks == nil) then
        ChatSkipper.SavedVariables.SkipBooks = true
    end
    if (ChatSkipper.SavedVariables.SkipImportantChoices == nil) then
        ChatSkipper.SavedVariables.SkipImportantChoices = false
    end
end

function ChatSkipper.InitSettings()
    local panelName = "ChatSkipperSettingsPanel"
     
    local panelData = {
        type = "panel",
        name = ChatSkipper.Name,
        displayName = ChatSkipper.Name,
        version = ChatSkipper.Version,
        author = "@myoda",
    }
    local optionsData = {
        {
            type = "checkbox",
            name = "Skip dialogues",
            getFunc = function() return ChatSkipper.SavedVariables.SkipDialogues end,
            setFunc = function(value) ChatSkipper.SavedVariables.SkipDialogues = value end
        },
        {
            type = "checkbox",
            name = "Skip important choices",
            tooltip = "Whether to skip or not quest-specific choices (red text). If enabled, will always pick the first option.",
            getFunc = function() return ChatSkipper.SavedVariables.SkipImportantChoices end,
            setFunc = function(value) ChatSkipper.SavedVariables.SkipImportantChoices = value end
        },
        {
            type = "checkbox",
            name = "Skip books",
            tooltip = "Read books without opening them.",
            getFunc = function() return ChatSkipper.SavedVariables.SkipBooks end,
            setFunc = function(value) ChatSkipper.SavedVariables.SkipBooks = value end
        }
    }
    LibAddonMenu2:RegisterAddonPanel(panelName, panelData)
    LibAddonMenu2:RegisterOptionControls(panelName, optionsData)
end
