-- Quartermaster/localization/ru.lua
-- Russian locale stub. Falls back to en.lua via the AccountHold.Strings table.
-- See localization/de.lua for the override pattern.

local overrides = {
    -- SI_ACCOUNTHOLD_ADDON_NAME = "Резерв аккаунта",
}

for stringId, value in pairs(overrides) do
    ZO_CreateStringId(stringId, value)
end

AccountHold = AccountHold or {}
AccountHold.Strings = AccountHold.Strings or {}
for k, v in pairs(overrides) do AccountHold.Strings[k] = v end
