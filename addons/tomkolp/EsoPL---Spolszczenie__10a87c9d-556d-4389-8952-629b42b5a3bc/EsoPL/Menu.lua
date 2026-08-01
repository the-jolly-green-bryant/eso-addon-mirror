local ADDON_NAME = "EsoPL"

local NamingModes = {
    pl   = "Tylko polski",
    en   = "Tylko angielski",
    plen = "Polski (Angielski)",
    enpl = "Angielski (Polski)",
}

local function GetModeName(mode)
    return NamingModes[mode] or mode
end

function EsoPL.BuildMenu()
    if not LibHarvensAddonSettings then
        d(ADDON_NAME .. ": LibHarvensAddonSettings nie jest zainstalowany.")
        return
    end

    local settings = LibHarvensAddonSettings:AddAddon("EsoPL (Konsola)", {
        allowDefaults = true,
        allowRefresh  = true,
        defaultsFunction = function()
            EsoPL.SetAbilitiesMode("pl")
            EsoPL.SetChampionMode("pl")
        end,
    })

    if not settings then return end

    ------------------------------------------------------------
    -- JĘZYK GRY (Instrukcja)
    ------------------------------------------------------------
    settings:AddSetting({
        type  = LibHarvensAddonSettings.ST_SECTION,
        label = "Język Gry / Language",
    })

    settings:AddSetting({
        type  = LibHarvensAddonSettings.ST_LABEL,
        label = "|cEECA2AZmiana języka:|r",
    })
    
    settings:AddSetting({
        type  = LibHarvensAddonSettings.ST_LABEL,
        label = "|c00FF00/pl|r - włącza język polski\n|cFFFF00/en|r - włącza język angielski\n(Komendy należy wpisać na czacie)",
    })

    ------------------------------------------------------------
    -- UMIEJĘTNOŚCI (SKILLS)
    ------------------------------------------------------------
    settings:AddSetting({
        type  = LibHarvensAddonSettings.ST_SECTION,
        label = "Nazwy Umiejętności (Skille)",
    })

    settings:AddSetting({
        type    = LibHarvensAddonSettings.ST_DROPDOWN,
        label   = "Format nazw umiejętności",
        tooltip = "Wybierz format wyświetlania nazw w drzewkach umiejętności.",
        items = {
            { name = NamingModes["pl"],   data = "pl" },
            { name = NamingModes["en"],   data = "en" },
            { name = NamingModes["plen"], data = "plen" },
            { name = NamingModes["enpl"], data = "enpl" },
        },
        getFunction = function() return GetModeName(EsoPL.GetAbilitiesMode()) end,
        setFunction = function(_, _, item) EsoPL.SetAbilitiesMode(item.data) end,
        default = NamingModes["pl"],
    })

    ------------------------------------------------------------
    -- MISTRZOSTWO (CHAMPION POINTS)
    ------------------------------------------------------------
    settings:AddSetting({
        type  = LibHarvensAddonSettings.ST_SECTION,
        label = "System Mistrzostwa (Champion)",
    })

    settings:AddSetting({
        type    = LibHarvensAddonSettings.ST_DROPDOWN,
        label   = "Format nazw gwiazdek",
        tooltip = "Wybierz format wyświetlania nazw w konstelacjach Mistrzostwa.",
        items = {
            { name = NamingModes["pl"],   data = "pl" },
            { name = NamingModes["en"],   data = "en" },
            { name = NamingModes["plen"], data = "plen" },
            { name = NamingModes["enpl"], data = "enpl" },
        },
        getFunction = function() return GetModeName(EsoPL.GetChampionMode()) end,
        setFunction = function(_, _, item) EsoPL.SetChampionMode(item.data) end,
        default = NamingModes["pl"],
    })
	------------------------------------------------------------
    -- STOPKA
    ------------------------------------------------------------    
    settings:AddSetting({
        type  = LibHarvensAddonSettings.ST_LABEL,
        label = "Wersja addonu: " .. tostring(EsoPL.Version),
    })
end