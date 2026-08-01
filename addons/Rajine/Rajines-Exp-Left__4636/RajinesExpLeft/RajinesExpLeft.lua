RajinesExpLeft = RajinesExpLeft or {}
RajinesExpLeft.name = "RajinesExpLeft"

local addon = RajinesExpLeft

addon.defaults = {
    enabled = true,
    cooldownSeconds = 2
}

addon.savedVars = nil

addon.lastNormalXp = nil
addon.lastChampionXp = nil
addon.lastPrintTime = 0

addon.lang = "en"
addon.L = {}

local function FormatNumber(value)
    value = tonumber(value) or 0

    local formatted = tostring(math.floor(value))
    local k

    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1.%2")
        if k == 0 then
            break
        end
    end

    return formatted
end

local function GetLanguage()
    local lang = GetCVar("language.2") or "en"

    if lang == "de" then return "de" end
    if lang == "fr" then return "fr" end
    if lang == "es" then return "es" end
    if lang == "ru" then return "ru" end
    if lang == "jp" then return "jp" end

    return "en"
end

local function InitLanguage()
    addon.lang = GetLanguage()

    if addon.translations ~= nil and addon.translations[addon.lang] ~= nil then
        addon.L = addon.translations[addon.lang]
    elseif addon.translations ~= nil and addon.translations["en"] ~= nil then
        addon.L = addon.translations["en"]
        addon.lang = "en"
    else
        addon.L = {}
        addon.lang = "en"
    end
end

local function T(key)
    if addon.L ~= nil and addon.L[key] ~= nil then
        return addon.L[key]
    end

    if addon.translations ~= nil and addon.translations["en"] ~= nil and addon.translations["en"][key] ~= nil then
        return addon.translations["en"][key]
    end

    return key
end

local function Print(message)
    d("|c66ccff[REL]|r " .. message)
end

local function PrintHelp()
    Print(T("help_title"))
    d("|cffff66/rel on|r - " .. T("help_on"))
    d("|cffff66/rel off|r - " .. T("help_off"))
    d("|cffff66/rel status|r - " .. T("help_status"))
    d("|cffff66/rel cooldown 5|r - " .. T("help_cooldown"))
    d("|cffff66/rel reset|r - " .. T("help_reset"))
    d("|cffff66/rel help|r - " .. T("help_help"))
end

local function IsChampionMode()
    return IsUnitChampion and IsUnitChampion("player")
end

local function GetCurrentProgress()
    if IsChampionMode() then
        local currentXp = GetPlayerChampionXP()
        local earnedCp = GetPlayerChampionPointsEarned()
        local maxXp = GetNumChampionXPInChampionPoint(earnedCp)

        return currentXp, maxXp, true
    else
        local currentXp = GetUnitXP("player")
        local maxXp = GetUnitXPMax("player")

        return currentXp, maxXp, false
    end
end

local function GetLastXp(isChampion)
    if isChampion then
        return addon.lastChampionXp
    end

    return addon.lastNormalXp
end

local function SetLastXp(isChampion, value)
    if isChampion then
        addon.lastChampionXp = value
    else
        addon.lastNormalXp = value
    end
end

local function ResetTracking()
    local currentXp, maxXp, isChampion = GetCurrentProgress()

    if currentXp ~= nil and maxXp ~= nil then
        SetLastXp(isChampion, currentXp)
    end

    addon.lastPrintTime = 0
end

local function GetCooldownMilliseconds()
    local seconds = addon.savedVars.cooldownSeconds or addon.defaults.cooldownSeconds
    return seconds * 1000
end

local function FormatMessage(template, values)
    if template == nil then
        return ""
    end

    local result = tostring(template)

    if values == nil then
        return result
    end

    for key, value in pairs(values) do
        result = string.gsub(result, "{" .. key .. "}", tostring(value))
    end

    return result
end

function addon.OnExperienceUpdate(eventCode, unitTag, currentExp, maxExp, reason)
    if not addon.savedVars.enabled then
        return
    end

    if unitTag ~= nil and unitTag ~= "player" then
        return
    end

    local currentXp, levelMaxXp, isChampion = GetCurrentProgress()

    if currentXp == nil or levelMaxXp == nil or levelMaxXp <= 0 then
        return
    end

    local lastXp = GetLastXp(isChampion)

    if lastXp == nil then
        SetLastXp(isChampion, currentXp)
        return
    end

    local gainedXp = currentXp - lastXp

    -- Bei Levelup oder CP-Up springt der aktuelle XP-Wert zurück.
    -- Dann setzen wir neu auf und ignorieren diesen Tick, damit kein Blödsinn ausgegeben wird.
    if gainedXp < 0 then
        SetLastXp(isChampion, currentXp)
        return
    end

    SetLastXp(isChampion, currentXp)

    if gainedXp <= 0 then
        return
    end

    local now = GetFrameTimeMilliseconds()
    local cooldownMs = GetCooldownMilliseconds()

    if now - addon.lastPrintTime < cooldownMs then
        return
    end

    addon.lastPrintTime = now

    local remainingXp = levelMaxXp - currentXp

    if remainingXp < 0 then
        remainingXp = 0
    end

    local repeatCount = math.ceil(remainingXp / gainedXp)

    local values = {
        gained = FormatNumber(gainedXp),
        remaining = FormatNumber(remainingXp),
        repeatCount = FormatNumber(repeatCount)
    }


    if isChampion then
        Print(FormatMessage(T("cp_xp_message"), values))
    else
        Print(FormatMessage(T("xp_message"), values))
    end
end

function addon.OnPlayerActivated(eventCode, initial)
    ResetTracking()
end

local function SlashCommand(input)
    input = string.lower(input or "")

    local command, value = string.match(input, "^(%S*)%s*(.-)$")

    if command == nil or command == "" or command == "help" then
        PrintHelp()
        return
    end

    if command == "on" then
        addon.savedVars.enabled = true
        ResetTracking()
        Print(T("enabled"))
        return
    end

    if command == "off" then
        addon.savedVars.enabled = false
        Print(T("disabled"))
        return
    end

    if command == "status" then
        local enabledText = addon.savedVars.enabled and T("active") or T("inactive")

        Print(FormatMessage(T("status"), {
            status = enabledText,
            cooldown = tostring(addon.savedVars.cooldownSeconds),
            language = addon.lang
        }))
        return
    end

    if command == "cooldown" then
        local seconds = tonumber(value)

        if seconds == nil then
            Print(T("cooldown_missing"))
            return
        end

        if seconds < 0 then
            seconds = 0
        end

        if seconds > 60 then
            seconds = 60
        end

        addon.savedVars.cooldownSeconds = seconds

        if seconds == 0 then
            Print(T("cooldown_disabled"))
        else
            Print(FormatMessage(T("cooldown_set"), {
                seconds = tostring(seconds)
            }))
        end

        return
    end

    if command == "reset" then
        ResetTracking()
        Print(T("reset_done"))
        return
    end

    Print(FormatMessage(T("unknown_command"), {
        command = command
    }))
    PrintHelp()
end

function addon.OnAddOnLoaded(eventCode, addonName)
    if addonName ~= addon.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

    InitLanguage()

    addon.savedVars = ZO_SavedVars:NewAccountWide(
            "RajinesExpLeftSavedVars",
            1,
            nil,
            addon.defaults
    )

    ResetTracking()

    SLASH_COMMANDS["/rel"] = SlashCommand
    SLASH_COMMANDS["/rajinesexpleft"] = SlashCommand

    EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_EXPERIENCE_UPDATE, addon.OnExperienceUpdate)
    EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED, addon.OnPlayerActivated)

    Print(FormatMessage(T("loaded"), {
        language = addon.lang
    }))
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, addon.OnAddOnLoaded)