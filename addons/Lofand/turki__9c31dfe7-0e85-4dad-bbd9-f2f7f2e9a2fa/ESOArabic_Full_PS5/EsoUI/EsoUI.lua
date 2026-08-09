local ArabicEsoUILoader = {
    name = "EsoUIArabicLoader",
}

local function OnAddOnLoaded(eventCode, addOnName)
    if addOnName ~= "EsoUI Arabic Loader" and addOnName ~= "EsoUI" then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(ArabicEsoUILoader.name, EVENT_ADD_ON_LOADED)
    SetCVar("IgnorePatcherLanguageSetting", 1)
    if GetCVar("Language.2") ~= "ar" then
        SetCVar("Language.2", "ar")
    end
end

EVENT_MANAGER:RegisterForEvent(ArabicEsoUILoader.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
