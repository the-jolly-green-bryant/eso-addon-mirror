FCOCO = FCOCO or  {}
local FCOCompanion = FCOCO

------------------------------------------------------------------------------------------------------------------------
--[Addon variables]
FCOCompanion.addonVars = {}
local addonVars = FCOCompanion.addonVars
addonVars.addonVersion		        = 0.17
addonVars.addonSavedVarsVersion	    = "0.04"
addonVars.addonSavedVarsVersionPerToon = "0.01"
addonVars.addonSavedVarsForAllTable = "SettingsForAll"
addonVars.addonSavedVarsNormalTable = "Settings"
addonVars.addonName				    = "FCOCompanion"
addonVars.addonNameMenu  		    = "FCO Companion"
addonVars.addonNameMenuDisplay	    = "|c00FF00FCO |cFFFF00 Companion|r"
addonVars.addonSavedVariablesName   = "FCOCompanion_Settings"
addonVars.addonSavedVariablesNamePerToon = "FCOCompanion_Settings_PerToon"
addonVars.settingsName   		    = "FCO Companion"
addonVars.addonAuthor			    = "Baertram"
addonVars.addonWebsite              = "https://www.esoui.com/downloads/info3044-FCOCompanion.html"
addonVars.addonFeedback             = "https://www.esoui.com/portal.php?uid=2028"
addonVars.addonDonation             = "https://www.esoui.com/portal.php?id=136&a=faq&faqid=131"


------------------------------------------------------------------------------------------------------------------------
--[Libraries]
FCOCompanion.LAM = LibAddonMenu2

------------------------------------------------------------------------------------------------------------------------
--[Settings]
FCOCompanion.settingsVars = {}
FCOCompanion.settingsVars.defaultSettings = {}
FCOCompanion.settingsVars.settings = {}
FCOCompanion.settingsVars.settingsPerToon = {}
FCOCompanion.settingsVars.defaults = {}
FCOCompanion.settingsVars.defaultsPerToon = {}

------------------------------------------------------------------------------------------------------------------------
--[Controls]
--FCOCompanion.ctrlVars = {}

------------------------------------------------------------------------------------------------------------------------
--[Other addons]
--FCOCompanion.otherAddons = {}

------------------------------------------------------------------------------------------------------------------------
--[Checks]
FCOCompanion.playerActivatedDone = false

------------------------------------------------------------------------------------------------------------------------
--[Constants]

--Companion Ids and collectibleIds
local companionInfo = {
--[[
    [1] = 9245,     -- Bastian Helix, companionDefId 1,
    [2] = 9353,     -- Mirri Elendis, companionDefId 2,
    [5] = 9911,     -- Ember, companionDefId 5,
    [6] = 9912,     -- Isobel, companionDefId 6,
    ...
]]
}
--Dynamic companion count, up to 30
for i=1, 30, 1 do
    local companionCollectibleId = GetCompanionCollectibleId(i)
    if companionCollectibleId and companionCollectibleId > 0 then
        companionInfo[i] = companionCollectibleId
    end
end
FCOCompanion.companionInfo = companionInfo
FCOCompanion.isCompanionUnlocked = false

for _, companionCollectibleId in pairs(companionInfo) do
    if IsCollectibleUnlocked(companionCollectibleId) then
        FCOCompanion.isCompanionUnlocked = true
        break
    end
end
if not FCOCompanion.isCompanionUnlocked then
    d(GetString(FCOCO_NO_COMPANION_UNLOCKED_YET))
    return
end
