local addonName = "AdrosarSandbox"

local antiqueFont = "EsoPL/fonts/ProseAntique.slug"
local handwrittenFont = "EsoPL/fonts/handwritten_bold.slug"
local tabletFont = "EsoPL/fonts/trajanpro-regular.slug"
local mapFont = "EsoPL/fonts/handwritten_bold.slug|34"

local authCounter = 0
local loadCounter = 0

local mapFontCurrentIndex = 0
local mapFontMaxLength = 999
local mapFontMaxFails = 3

local function getRegKey(name)
    return addonName .. ":" .. name
end

local function log(str)
    d(str)
end

local function xor(a, b)
    local res = 0
    local bitval = 1
    while a > 0 or b > 0 do
        local abit = a % 2
        local bbit = b % 2
        if abit ~= bbit then
            res = res + bitval
        end
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        bitval = bitval * 2
    end
    return res
end

local function fnv1a(str)
    local hash = 2166136261
    for i = 1, #str do
        hash = xor(hash, string.byte(str, i))
        hash = (hash * 16777619) % 2 ^ 32
    end
    return hash
end

local function hash(text)
    return fnv1a(text)
end

local function getCurrentUserID()
    return hash(GetDisplayName() .. "$" .. GetPlatformServiceType() .. "#" .. GetUnitName("player"))
end

local function isAllowedUser()
    local allowedUsers = { 522152040, 3506768576, 322433720 }
    local currentUser = getCurrentUserID()
    for i = 1, #allowedUsers do
        if allowedUsers[i] == currentUser then
            return true
        end
    end
    return false
end

local function setLanguage(lang)
    SetCVar("IgnorePatcherLanguageSetting", "1")
    SetCVar("language.2", lang)
    SetCVar("LastPlatformLanguage", lang)
end

local function getBookFontInfo(fnGetFontInfo, ID, isGamepad)
    local titleFontName,
    titleFontSize,
    titleFontStyle,
    bodyFontName,
    bodyFontSize,
    bodyFontStyle,
    fontColorR,
    fontColorG,
    fontColorB,
    fontColorA,
    fontStyleColorR,
    fontStyleColorG,
    fontStyleColorB,
    fontStyleColorA = fnGetFontInfo(ID, isGamepad)

    if ID == 1 or ID == 2 or ID == 3 or ID == 8 or ID == 9 then
        titleFontName = antiqueFont
        bodyFontName = antiqueFont
    elseif ID == 4 or ID == 5 or ID == 6 or ID == 10 or ID == 11 then
        titleFontName = handwrittenFont
        bodyFontName = handwrittenFont
    elseif ID == 7 then
        titleFontName = tabletFont
        bodyFontName = tabletFont
    end

    return titleFontName,
        titleFontSize,
        titleFontStyle,
        bodyFontName,
        bodyFontSize,
        bodyFontStyle,
        fontColorR,
        fontColorG,
        fontColorB,
        fontColorA,
        fontStyleColorR,
        fontStyleColorG,
        fontStyleColorB,
        fontStyleColorA
end

local function installBookFontPL()
    if GetCVar("language.2") ~= "pl" then
        return
    end

    local orginalGetBookSmallFontInfo = GetBookSmallFontInfo
    GetBookSmallFontInfo = function(ID, isGamepad)
        return getBookFontInfo(orginalGetBookSmallFontInfo, ID, isGamepad)
    end

    local orginalGetBookMediumFontInfo = GetBookMediumFontInfo
    GetBookMediumFontInfo = function(ID, isGamepad)
        return getBookFontInfo(orginalGetBookMediumFontInfo, ID, isGamepad)
    end

    local orginalGetBookLargeFontInfo = GetBookLargeFontInfo
    GetBookLargeFontInfo = function(ID, isGamepad)
        return getBookFontInfo(orginalGetBookLargeFontInfo, ID, isGamepad)
    end
end

local function fixMapFontPL()
    local fail = 0
    for i = mapFontCurrentIndex, mapFontMaxLength do
        local ctrl = _G["ZO_WorldMapContainerBlobName" .. i]
        if ctrl then
            fail = 0
            local font = ctrl:GetFont()
            if font:find("Handwritten") then
                ctrl:SetFont(mapFont)
                mapFontCurrentIndex = i + 1
            end
        else
            fail = fail + 1
            if fail >= mapFontMaxFails then
                break
            end
        end
    end
end

local function installMapFontPL()
    if GetCVar("language.2") ~= "pl" then
        return
    end

    EVENT_MANAGER:RegisterForUpdate(getRegKey("fixMapFontPL"), 1000, fixMapFontPL)
end

local function printInfo()
    if authCounter > 0 then
        log("AdrosarSandbox is enabled")
    else
        log("AdrosarSandbox is disabled")
    end
end

local function printCurrentUserID()
    log("UID: " .. getCurrentUserID())
end

local function printCVar()
    log("IgnorePatcherLanguageSetting: " .. GetCVar("IgnorePatcherLanguageSetting"))
    log("language.2: " .. GetCVar("language.2"))
    log("LastPlatformLanguage: " .. GetCVar("LastPlatformLanguage"))
end

local function setLangPL()
    setLanguage("pl")
    log("Lang set to PL")
end

local function setLangEN()
    setLanguage("en")
    log("Lang set to EN")
end

local function installBaseCommands()
    SLASH_COMMANDS["/adrosarsandbox"] = printInfo
    SLASH_COMMANDS["/printcurrentuserid"] = printCurrentUserID
end

local function installAdvancedCommands()
    SLASH_COMMANDS["/printcvar"] = printCVar
    SLASH_COMMANDS["/setlangpl"] = setLangPL
    SLASH_COMMANDS["/setlangen"] = setLangEN
end

local function start()
    installBaseCommands()
    if isAllowedUser() then
        installAdvancedCommands()
        installBookFontPL()
        installMapFontPL()
        authCounter = authCounter + 1
    end
end

local function onLoaded(event, name)
    if name == addonName and loadCounter == 0 then
        EVENT_MANAGER:UnregisterForEvent(getRegKey("onLoaded"), EVENT_ADD_ON_LOADED)
        loadCounter = loadCounter + 1
        start()
    end
end

EVENT_MANAGER:RegisterForEvent(getRegKey("onLoaded"), EVENT_ADD_ON_LOADED, onLoaded)
