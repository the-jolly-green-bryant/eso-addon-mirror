local companionStr = GetString(SI_UNIT_FRAME_NAME_COMPANION)
local companionKeybindBaseStr = "見せる/隠す " .. companionStr

local stringsJP = {
    FCOCO_NO_COMPANION_UNLOCKED_YET                         = "[FCOCompanion]You did not unlock any " .. GetString(SI_UNIT_FRAME_NAME_COMPANION) .. " yet. Please finish and turn in any of the unlock quests first and reload the UI afterwards!",

    --FCOCO_SHOW_COMPANION_MENU   = "見せる \'" .. GetString(SI_INTERACT_OPTION_COMPANION_MENU) .. "\'",
    FCOCO_TOGGLE_COMPANION      = companionKeybindBaseStr .. " (最終)",

    --LAM Settings
}

local companionInfo = FCOCO.companionInfo
for companionDefId, companionCollectibleId in pairs(companionInfo) do
    --local companionCollectibleId = GetCompanionCollectibleId(companionDefId)
    if companionCollectibleId ~= nil then
        local companionName = GetCollectibleName(companionCollectibleId)
        local companionNameClean = ZO_CachedStrFormat(SI_UNIT_NAME, companionName)
        stringsJP["FCOCO_TOGGLE_COMPANION_" .. tostring(companionDefId)]     = companionKeybindBaseStr .. ": \'" .. companionNameClean .. "\'"
    end
end

for stringId, stringValue in pairs(stringsJP) do
    SafeAddString(_G[stringId], stringValue, 2)
end