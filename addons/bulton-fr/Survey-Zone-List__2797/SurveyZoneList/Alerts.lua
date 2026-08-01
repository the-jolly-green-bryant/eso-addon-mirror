SurveyZoneList.Alerts = {}

--[[
-- @const WHEN_START string The value for when alerts should be executed on the first survey's node
--]]
SurveyZoneList.Alerts.WHEN_START = "BEFORE"

--[[
-- @const WHEN_END string The value for when alerts should be executed on the last survey's node
--]]
SurveyZoneList.Alerts.WHEN_END = "END"

--[[
-- @var table All saved variables dedicated to the spot system.
--]]
SurveyZoneList.Alerts.savedVars = nil

--[[
-- @var bool inBag To know if we have the bag displayed
--]]
SurveyZoneList.Alerts.inBag = false

--[[
-- @var bool inBank To know if we have the bank displayed
--]]
SurveyZoneList.Alerts.inBank = false

--[[
-- @var int The quantity of survey for the current spot
--]]
SurveyZoneList.Alerts.spotQuantity = 0

--[[
-- @var int The quantity of survey for the current zone
--]]
SurveyZoneList.Alerts.zoneQuantity = 0

--[[
-- Initialise the Spot system
--]]
function SurveyZoneList.Alerts:init()
    self.savedVars = SurveyZoneList.savedVariables.alerts

    self:initSavedVarsValues()
    self:initOpenBagEvent()
end

--[[
-- Initialise with a default value all saved variables dedicated to the spot system
--]]
function SurveyZoneList.Alerts:initSavedVarsValues()
    if self.savedVars.sound == nil then
        self.savedVars.sound = {}
    end
    if self.savedVars.sound.use == nil then
        self.savedVars.sound.use = false
    end
    if self.savedVars.sound.id == nil then
        self.savedVars.sound.id = "NONE"
    end
    
    if self.savedVars.alert == nil then
        self.savedVars.alert = false
    end
    
    if self.savedVars.when == nil then
        self.savedVars.when = self.WHEN_START
    end
end

--[[
-- Add an event for when the inventory scene is trigger
--]]
function SurveyZoneList.Alerts:initOpenBagEvent()
    local inventoryScene = SCENE_MANAGER:GetScene("inventory")
    inventoryScene:RegisterCallback("StateChange", function(oldState, newState)
        if newState == 'hidden' then
            SurveyZoneList.Alerts.inBag = false
        elseif newState == 'shown' then
            SurveyZoneList.Alerts.inBag = false
        end
    end)
end

--[[
-- Set the value of inBank
--
-- @param bool newState
--]]
function SurveyZoneList.Alerts:setInBank(newState)
    self.inBank = newState
end

--[[
-- Get the value of sound.use
--]]
function SurveyZoneList.Alerts:getSoundUse()
    return self.savedVars.sound.use
end

--[[
-- Set the value of sound.use
--
-- @param bool newState
--]]
function SurveyZoneList.Alerts:setSoundUse(useSound)
    self.savedVars.sound.use = useSound
end

--[[
-- Get the value of sound.id
--]]
function SurveyZoneList.Alerts:getSoundId()
    return self.savedVars.sound.id
end

--[[
-- Set the value of sound.id
--
-- @param string idSound
--]]
function SurveyZoneList.Alerts:setSoundId(idSound)
    self.savedVars.sound.id = idSound
end

--[[
-- Get the value of alert
--]]
function SurveyZoneList.Alerts:getAlert()
    return self.savedVars.alert
end

--[[
-- Set the value of alert
--
-- @param bool useAlert
--]]
function SurveyZoneList.Alerts:setAlert(useAlert)
    self.savedVars.alert = useAlert
end

--[[
-- Get the value of when
--]]
function SurveyZoneList.Alerts:getWhen()
    return self.savedVars.when
end

--[[
-- Set the value of when
--
-- @param string when
--]]
function SurveyZoneList.Alerts:setWhen(when)
    self.savedVars.when = when
end

--[[
-- Check if the bag or the bank is displayed/opened
--
-- @return bool
--]]
function SurveyZoneList.Alerts:uiOpen()
    return self.inBag or self.inBank
end

--[[
-- Change about the quantity of survey
--
-- @var int spotQuantity The survey's quantity for the spot which have changed
-- @var int zoneQuantity The survey's quantity for the zone which have changed
--]]
function SurveyZoneList.Alerts:updateQuantity(spotQuantity, zoneQuantity)
    self.spotQuantity = spotQuantity
    self.zoneQuantity = zoneQuantity

    if self:uiOpen() == false then
        self:updateGUI()
        self:execAlerts(self.WHEN_START)
    end
end

--[[
-- Execute all configured alert for a specific time
--
-- @param string when If the function is called on the first or the last node
--]]
function SurveyZoneList.Alerts:execAlerts(when)
    if when ~= self.savedVars.when then
        return
    end

    if self.spotQuantity == 0 then
        self:displayAnnounce()
        self:playSong()
    end
end

--[[
-- Call the update of the spot info in the GUI
--]]
function SurveyZoneList.Alerts:updateGUI()
    SurveyZoneList.GUI:updateSpotInfo()
end

--[[
-- Display the announce about the last spot
--]]
function SurveyZoneList.Alerts:displayAnnounce()
    if self.savedVars.alert == false then
        return
    end

    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
	messageParams:SetText(GetString(SI_SURVEYZONELIST_SPOT_NOTIFY_LASTSPOT))
	messageParams:SetLifespanMS(5000)
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

--[[
-- Play sound about the last spot
--]]
function SurveyZoneList.Alerts:playSong()
    if self.savedVars.sound.use == false then
        return
    end

    if SOUNDS[self.savedVars.sound.id] ~= nil then
        PlaySound(SOUNDS[self.savedVars.sound.id])
    end
end
