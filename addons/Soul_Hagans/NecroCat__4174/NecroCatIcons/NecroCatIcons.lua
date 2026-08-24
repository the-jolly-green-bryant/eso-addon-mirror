local ADDON_NAME = "NecroCatIcons"

-- 1. Список всех путей к текстурам
local ICONS = {
    ["Кошка"]        = "NecroCatIcons/imgs/Necrocat.dds",
    ["Кошка2"]       = "NecroCatIcons/imgs/Necrocat2.dds",
    ["Кошка3"]       = "NecroCatIcons/imgs/Necrocat3.dds",
    ["Praid"]        = "NecroCatIcons/imgs/Pra1d.dds",
    ["Praid2"]       = "NecroCatIcons/imgs/Pra1d2.dds",
    ["Praid3"]       = "NecroCatIcons/imgs/Pra1d3.dds",
    ["Pra1d4"]       = "NecroCatIcons/imgs/Pra1d4.dds",
    ["Julia"]        = "NecroCatIcons/imgs/Julia.dds",
    ["Julia2"]       = "NecroCatIcons/imgs/Julia2.dds",
    ["Julia3"]       = "NecroCatIcons/imgs/Julia3.dds",
    ["Julia4"]       = "NecroCatIcons/imgs/Julia4.dds",
    ["Avi"]          = "NecroCatIcons/imgs/AviryNa.dds",
    ["Avi2"]         = "NecroCatIcons/imgs/AviryNa2.dds",
    ["Avi3"]         = "NecroCatIcons/imgs/AviryNa3.dds",
    ["StarIDNova"]   = "NecroCatIcons/imgs/StarIDNova.dds",
    ["Soul_Hagans"]  = "NecroCatIcons/imgs/SoulHagans.dds",
    ["Soul_Hagans2"] = "NecroCatIcons/imgs/SoulHagans2.dds",
    ["Soul_Hagans3"] = "NecroCatIcons/imgs/SoulHagans3.dds",
    ["Tegaro"]       = "NecroCatIcons/imgs/Tegaro.dds",
    ["Moonrae"]      = "NecroCatIcons/imgs/Moonrae.dds",
    ["Crown"]        = "NecroCatIcons/imgs/Crown.dds",
    ["Tesoshnik"]    = "NecroCatIcons/imgs/Tesoshnik.dds",
    ["DontUp"]       = "NecroCatIcons/imgs/DontUp.dds",
    ["F"]            = "NecroCatIcons/imgs/F.dds",
    ["Loot"]         = "NecroCatIcons/imgs/Loot.dds",
    ["Tails"]        = "NecroCatIcons/imgs/tails.dds",
    ["FoxyAnezka"]   = "NecroCatIcons/imgs/FoxyAnezka.dds",
    ["Wildmile98"]   = "NecroCatIcons/imgs/Wildmile98.dds",
    ["ArCrass"]      = "NecroCatIcons/imgs/ArCrass.dds",
}

-- 2. Привязка иконок к аккаунтам по умолчанию
local DEFAULT_USERS = {
    ["@NecroCat_Crimson"]   = ICONS["Кошка3"],
    ["@horusgor"]           = ICONS["Кошка2"],
    ["@Gonzo-Cat"]          = ICONS["Кошка2"],
    ["@Praid_Crimson"]      = ICONS["Praid3"],
    ["@Chio-Cill"]          = ICONS["Julia"],
    ["@AviryNa"]            = ICONS["Avi"],
    ["@Star_ID.Nova"]       = ICONS["StarIDNova"],
    ["@Soul_Hagans"]        = ICONS["Soul_Hagans3"],
    ["@Tegaro"]             = ICONS["Tegaro"],
    ["@Moonrae"]            = ICONS["Moonrae"],
    ["@TESOSHNIK"]          = ICONS["Tesoshnik"],
    ["@TESOSHNIK_REBIRTH"]  = ICONS["Tesoshnik"],
    ["@Primo_Kilert007"]    = ICONS["Tails"],
    ["@Jerry_Russo"]        = ICONS["Tails"],
    ["@SoulBeast"]          = ICONS["Tails"],
    ["@FoxyAnezka"]         = ICONS["FoxyAnezka"],
    ["@Wildmile98"]         = ICONS["Wildmile98"],
    ["@ArCrass"]            = ICONS["ArCrass"],
}

-- 3. Регистрация в OSI
local function ApplyIconsToOSI()
    if not OSI or not OSI.AddUniqueIconPack or not OSI.AddCustomIconPack then return end

    -- Передаём дефолтные иконки для игроков
    OSI.AddUniqueIconPack(DEFAULT_USERS)

    -- Передаём весь набор иконок в общий список OSI (чтобы их можно было выбирать вручную)
    local customIcons = {}
    for _, path in pairs(ICONS) do
        table.insert(customIcons, path)
    end
    OSI.AddCustomIconPack(customIcons)

    if OSI.RefreshAllIcons then
        OSI.RefreshAllIcons()
    end
end

-- 4. Запуск при загрузке
local function OnAddOnLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end

    ApplyIconsToOSI()

    -- Отключаем слушатель, так как аддон уже загрузился и больше слушать это событие не нужно
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)