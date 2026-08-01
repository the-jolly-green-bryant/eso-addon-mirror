local strings = {
  ["SI_OFFLINENOTIFY_ADDON_NAME"] = "Offline Notify",
}

for stringId, stringValue in pairs(strings) do
  ZO_CreateStringId(stringId, stringValue)
  SafeAddVersion(stringId, 1)
end