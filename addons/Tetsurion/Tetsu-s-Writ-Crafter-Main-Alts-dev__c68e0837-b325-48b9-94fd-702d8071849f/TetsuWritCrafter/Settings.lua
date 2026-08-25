TetsuWritCrafter = TetsuWritCrafter or {}

function TetsuWritCrafter.RegisterSettings()
    local LibHarven = LibHarvensAddonSettings
    if not LibHarven then return end

    local L = TetsuWritCrafter.L
    local vars = TetsuWritCrafter.savedVars
    if not vars then return end

    local settings = LibHarven:AddAddon(L.TITLE)
    if not settings then return end

    settings.version = "1.1.3"
    settings.author = "Tetsurion"

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = L.ALTS_SECTION_LABEL,
        tooltip = L.ALTS_SECTION_TT,
    })

    local numChars = GetNumCharacters()
    for i = 1, numChars do
        local name = zo_strformat("<<1>>", GetCharacterInfo(i))
        settings:AddSetting({
            type = LibHarvensAddonSettings.ST_CHECKBOX,
            label = name,
            tooltip = zo_strformat(L.CHAR_ENABLED_TT, name),
            default = true,
            getFunction = function()
                if vars.characters and vars.characters[name] then
                    return vars.characters[name].enabled ~= false
                end
                return true
            end,
            setFunction = function(val)
                if vars.characters and vars.characters[name] then
                    vars.characters[name].enabled = val
                end
            end,
        })
    end
end