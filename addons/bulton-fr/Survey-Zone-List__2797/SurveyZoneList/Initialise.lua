SurveyZoneList = {}

SurveyZoneList.lang = {}

SurveyZoneList.name           = "Survey Zone List"
SurveyZoneList.dirName        = "SurveyZoneList"
SurveyZoneList.savedVariables = nil
SurveyZoneList.ready          = false
SurveyZoneList.LAM            = LibAddonMenu2

--[[
-- Module initialiser
-- Intiialise savedVariables, GUI and sort system
--]]
function SurveyZoneList:Initialise()
    SurveyZoneList.savedVariables = ZO_SavedVars:NewAccountWide("SurveyZoneListSavedVariables", 1, nil, {})

    if SurveyZoneList.savedVariables.gui == nil then
        SurveyZoneList.savedVariables.gui = {}
    end
    if SurveyZoneList.savedVariables.sort == nil then
        SurveyZoneList.savedVariables.sort = {}
    end
    if SurveyZoneList.savedVariables.alerts == nil then
        SurveyZoneList.savedVariables.alerts = {}
    end
    if SurveyZoneList.savedVariables.interaction == nil then
        SurveyZoneList.savedVariables.interaction = {}
    end

    SurveyZoneList.Alerts:init()
    SurveyZoneList.Interaction:init()
    SurveyZoneList.Settings:init()
    SurveyZoneList.GUI:init()
    SurveyZoneList.ItemSort:init()
    SurveyZoneList.ready = true
end
