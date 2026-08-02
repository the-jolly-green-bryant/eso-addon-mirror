-- Quartermaster/localization/de.lua
-- German locale stub. Falls back to en.lua via the AccountHold.Strings table.
-- Add overrides to the `overrides` table to translate individual SI_* ids;
-- any id NOT present here uses the English string registered by en.lua.
--
-- This file is intentionally NOT listed in AccountHold.addon today — load it
-- by appending `localization/de.lua` to the manifest after `localization/en.lua`
-- when GetCVar("language.2") == "de" handling is wired up. Keeping the file
-- in tree avoids a manifest change when translations land.

local overrides = {
    -- SI_ACCOUNTHOLD_ADDON_NAME = "Konto-Reservierung",
}

for stringId, value in pairs(overrides) do
    ZO_CreateStringId(stringId, value)
end

AccountHold = AccountHold or {}
AccountHold.Strings = AccountHold.Strings or {}
for k, v in pairs(overrides) do AccountHold.Strings[k] = v end
