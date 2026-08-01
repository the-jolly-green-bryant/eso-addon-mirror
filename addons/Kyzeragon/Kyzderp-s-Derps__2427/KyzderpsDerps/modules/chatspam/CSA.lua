KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.ChatSpam = KyzderpsDerps.ChatSpam or {}
local Spam = KyzderpsDerps.ChatSpam

local csaCategories = {
    [CSA_CATEGORY_ANIMATED_CONTROL] = "ANIMATED_CONTROL",
    [CSA_CATEGORY_COUNTDOWN_TEXT] = "COUNTDOWN_TEXT",
    [CSA_CATEGORY_ENDLESS_DUNGEON_STAGE_STARTED_TEXT] = "ENDLESS_DUNGEON_STAGE_STARTED_TEXT",
    [CSA_CATEGORY_EXTERNAL_HANDLE] = "EXTERNAL_HANDLE",
    [CSA_CATEGORY_INVALID] = "INVALID",
    [CSA_CATEGORY_LARGE_TEXT] = "LARGE_TEXT",
    [CSA_CATEGORY_MAJOR_TEXT] = "MAJOR_TEXT",
    [CSA_CATEGORY_NO_TEXT] = "NO_TEXT",
    [CSA_CATEGORY_RAID_COMPLETE_TEXT] = "RAID_COMPLETE_TEXT",
    [CSA_CATEGORY_ROLLING_METER_PROGRESS_TEXT] = "ROLLING_METER_PROGRESS_TEXT",
    [CSA_CATEGORY_SCRYING_PROGRESS_TEXT] = "SCRYING_PROGRESS_TEXT",
    [CSA_CATEGORY_SMALL_TEXT] = "SMALL_TEXT",
}
KyzderpsDerps.csaCategories = csaCategories

local alertCategories = {
    [UI_ALERT_CATEGORY_ERROR] = "ERROR",
    [UI_ALERT_CATEGORY_ALERT] = "ALERT",
}

---------------------------------------------------------------------
local function StartsWith(str, prefix)
    if (not str) then return false end
    return string.sub(str, 1, #prefix) == prefix
end

local function HookCenterScreenAnnounce(s, messageParams)
    local mainText = messageParams:GetMainText()
    local secondaryText = messageParams:GetSecondaryText()

    if (KyzderpsDerps.savedOptions.misc.suppressKillEnemiesNM
        and (StartsWith(mainText, "Kill Enemies in the Night Market:")
            or StartsWith(mainText, "Kill More Enemies in the Night Market:"))) then
        return true
    end

    if (mainText ~= nil or secondaryText ~= nil) then
        if (LibFilteredChatPanel) then
            LibFilteredChatPanel:GetSystemFilter():AddMessage(string.format("%s - %s / %s",
                csaCategories[messageParams:GetCategory()] or "",
                tostring(mainText),
                tostring(secondaryText)))
        end
    end
    return false
end

---------------------------------------------------------------------
local function HookAlert(category, soundId, message)
    if (LibFilteredChatPanel and category and message) then
        LibFilteredChatPanel:GetSystemFilter():AddMessage(string.format("|cede795%s - %s",
                alertCategories[category],
                tostring(message)))
    end
    return false
end


---------------------------------------------------------------------
function Spam.InitializeCSAHook()
    ZO_PreHook(CENTER_SCREEN_ANNOUNCE, "QueueMessage", HookCenterScreenAnnounce)
    ZO_PreHook("ZO_Alert", HookAlert)
end
