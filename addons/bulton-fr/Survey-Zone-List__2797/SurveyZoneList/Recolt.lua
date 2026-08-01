SurveyZoneList.Recolt = {}

--[[
-- @var int max number of node on a survey
--]]
SurveyZoneList.Recolt.maxNode = 6

--[[
-- @var int number of node recolted for the current survey
--]]
SurveyZoneList.Recolt.counter = 0

--[[
-- @var bool if the loot received event is when there is a new survey interaction or not
--]]
SurveyZoneList.Recolt.newSurveyInteraction = false

--[[
-- Set the value of newSurveyInteraction
--]]
function SurveyZoneList.Recolt:setNewSurveyInteraction(value)
    self.newSurveyInteraction = value
end

--[[
-- Reset the counter of node recolted
--]]
function SurveyZoneList.Recolt:reset()
    self.counter = 0
    SurveyZoneList.GUI:updateCounter()
end

--[[
-- Called when a loot item is received
-- Check if the last interaction is a survey, and update the counter if true
-- Also call alerts systems if the number of spot recolted is equal to max node
--]]
function SurveyZoneList.Recolt:lootReceived()
    if self.newSurveyInteraction == true then
        self.newSurveyInteraction = false
        
        if SurveyZoneList.Interaction.lastIsSurvey == false then
            return
        end
    
        self.counter = self.counter + 1
        SurveyZoneList.GUI:updateCounter()
    
        if self.counter == self.maxNode then
            SurveyZoneList.Alerts:execAlerts(SurveyZoneList.Alerts.WHEN_END)
        end
    end
end
