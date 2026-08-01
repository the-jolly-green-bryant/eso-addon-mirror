--Register with LibStub
local MAJOR, MINOR = "Up_LocaleUtils", 1
local LIB, _ = LibStub:NewLibrary(MAJOR, MINOR)
if not LIB then return end -- avoid double loading.

--- Used to configure locale storage for addon.
-- @param localizedStrings table of strings to be localized.
-- @param localizationVersion version for safe add.
-- Use in code after add: GetString(key)
function LIB.register(localizedStrings, localizationVersion)
    -- Register localized strings in ESO storage.
    for key, locale in pairs(localizedStrings) do
        ZO_CreateStringId(key, locale)
        SafeAddVersion(key, localizationVersion) -- See EsoStringVersions.
    end
end
