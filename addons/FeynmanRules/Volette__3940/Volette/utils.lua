function Volette.InitializeConfirmReloadDialog()
    ESO_Dialogs["VOLETTE_CONFIRM_RELOAD"] = {
        title = { text = GetString(VOLETTE_RELOADUI_DIALOG_TITLE) },
        mainText = { text = GetString(VOLETTE_RELOADUI_DIALOG_DESCRIPTION) },
        buttons = {
            {
                text = GetString(VOLETTE_YES),
                callback = function(dialog)
                    ReloadUI()
                end,
            },
            {
                text = GetString(VOLETTE_NO),
            },
        }
    }
end

function Volette.IsInArray(array, value)
    for _, v in ipairs(array) do
        if v == value then
            return true
        end
    end
    return false
end

function Volette.GetText(text_id, ...)
    local text = GetString(text_id)
    if select("#", ...) == 0 then
        return text
    else
        return zo_strformat(text, ...)
    end
end

function Volette.InitializeCharactersList()
    Volette.charactersList = {}

    for i = 1, GetNumCharacters() do
        local characterName, _, _, _, _, _, characterId = GetCharacterInfo(i)
        local cleanCharacterName = zo_strformat("<<1>>", characterName)
        Volette.charactersList[cleanCharacterName] = characterId
    end
end
