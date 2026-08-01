if FCORep == nil then FCORep = {} end
local FCORep = FCORep

--==============================================================================
--===== Constants BEGIN ============================================================
--==============================================================================

--Create the settings panel object of libAddonMenu 2.0
FCORep.LAM 	 = LibAddonMenu2

--Available languages
FCORep.numVars = {}
FCORep.numVars.languageCount = 7 --English, German, French, Spanish, Italian, Japanese, Russian
FCORep.langVars = {}
FCORep.langVars.languages = {}
--Build the languages array
for i=1, FCORep.numVars.languageCount do
    FCORep.langVars.languages[i] = true
end

--Array for all the variables
FCORep.locVars = {}

--Uncolored "FCORep" pre chat text for the chat output
FCORep.locVars.preChatText = "FCO CraftFilter"
--Green colored "FCORep" pre text for the chat output
FCORep.locVars.preChatTextGreen = "|c22DD22"..FCORep.locVars.preChatText.."|r "
--Red colored "FCORep" pre text for the chat output
FCORep.locVars.preChatTextRed = "|cDD2222"..FCORep.locVars.preChatText.."|r "
--Blue colored "FCORep" pre text for the chat output
FCORep.locVars.preChatTextBlue = "|c2222DD"..FCORep.locVars.preChatText.."|r "

--Control names of ZO* standard controls etc.
FCORep.zoVars = {}
--Enchanting
--FCORep.zoVars.BACKPACK                              = ZO_PlayerInventoryBackpack
FCORep.zoVars.REPAIR_WINDOW                         = ZO_RepairWindow
FCORep.zoVars.REPAIR_WINDOW_LIST                    = ZO_RepairWindowList

FCORep.settingsVars			    = {}
FCORep.settingsVars.settings       = {}
FCORep.settingsVars.defaultSettings= {}

FCORep.preventerVars = {}
FCORep.preventerVars.gLocalizationDone = false

FCORep.localizationVars = {}
FCORep.localizationVars.localizationAll = {}
FCORep.localizationVars.FCORep_loc = {}

FCORep.eventHandlers = {}
