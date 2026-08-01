--ZO_CreateStringId("SI_BINDING_NAME_FCOCO_SHOW_COMPANION_MENU", GetString(FCOCO_SHOW_COMPANION_MENU))
if not FCOCO.isCompanionUnlocked then return end
ZO_CreateStringId("SI_BINDING_NAME_FCOCO_TOGGLE_COMPANION",     GetString(FCOCO_TOGGLE_COMPANION))

local companionInfo = FCOCO.companionInfo
for companionDefId, _ in pairs(companionInfo) do
    ZO_CreateStringId("SI_BINDING_NAME_FCOCO_TOGGLE_COMPANION_" ..tostring(companionDefId), GetString(_G["FCOCO_TOGGLE_COMPANION_" .. tostring(companionDefId)]))
end