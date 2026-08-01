local ItemConditionAlert = {}
ItemConditionAlert = _G["ItemConditionAlert"]

local language = GetCVar("language.2")

ItemConditionAlert.wordlist.valid = false

if (language == nil or language == "en") then ItemConditionAlert.wordlist = ItemConditionAlert.enwordlib:New() end
if (language == "de") then ItemConditionAlert.wordlist = ItemConditionAlert.dewordlib:New() end
if (language == "fr") then ItemConditionAlert.wordlist = ItemConditionAlert.frwordlib:New() end
if not ItemConditionAlert.wordlist.valid then ItemConditionAlert.wordlist = ItemConditionAlert.enwordlib:New() end --use English as the default wordlist