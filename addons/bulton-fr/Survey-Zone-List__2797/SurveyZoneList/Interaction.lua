SurveyZoneList.Interaction = {}

--[[
-- @var table All saved variables dedicated to the interaction system.
--]]
SurveyZoneList.Interaction.savedVars = nil

--[[
-- @var string The last interactible item see
--]]
SurveyZoneList.Interaction.lastName = nil

--[[
-- @var bool If the last interactible item is a survey node or not
--]]
SurveyZoneList.Interaction.lastIsSurvey = false

--[[
-- Initialise the Spot system
--]]
function SurveyZoneList.Interaction:init()
    self.savedVars = SurveyZoneList.savedVariables.interaction
    self:initSavedVarsValues()
end

--[[
-- Initialise with a default value all saved variables dedicated to the interaction system
--]]
function SurveyZoneList.Interaction:initSavedVarsValues()
    if self.savedVars.showIcon == nil then
        self.savedVars.showIcon = true
    end
end

--[[
-- Get the showIcon
--]]
function SurveyZoneList.Interaction:getShowIcon()
    return self.savedVars.showIcon
end

--[[
-- Set the showIcon
--]]
function SurveyZoneList.Interaction:setShowIcon(showIcon)
    self.savedVars.showIcon = showIcon
end

--[[
-- Called by PostHook on TryHandlingInteraction
-- Call the check if the interaction is with a survey node; If true, display
-- the craft icon before the interaction item's name
--
-- @var bool interactionPossible (see TryHandlingInteraction method)
--]]
function SurveyZoneList.Interaction:updateInteractContext(interactionPossible)
    if not interactionPossible then
        return nil
    end

    local action, name, _, _, additionalInteractInfo, _, _, _ = GetGameCameraInteractableActionInfo()
    
    if not action or not name then
        return nil
    end

    if additionalInteractInfo ~= ADDITIONAL_INTERACT_INFO_NONE then
        return nil
    end
    
    local sameInteraction = true
    if name ~= self.lastName then
        sameInteraction   = false
        self.lastName     = name
        self.lastIsSurvey = false
    end

    if sameInteraction == false then
        -- d(zo_strformat("<<1>> / <<2>>", action, name))
        self.lastIsSurvey = self:isSurveyNode(action, name)
    end

    if self.lastIsSurvey == false then
        return nil
    end

    if self.savedVars.showIcon == true then
        RETICLE.interactContext:SetText(
            zo_iconTextFormat(
                '/esoui/art/icons/poi/poi_crafting_complete.dds',
                40,
                40,
                self.lastName
            )
        )
    end
end

--[[
-- Check if the interacionName and the action match with a survey node
--
-- @param string action Action label feasible on the item
-- @param string interactionName The name of the interactible item
--
-- @return bool
--]]
function SurveyZoneList.Interaction:isSurveyNode(action, interactionName)
    local actionAllowed = false
    for avActionIdx, availableAction in pairs(SurveyZoneList.lang.surveyAction) do
        if action == availableAction then
            actionAllowed = true
            break
        end
    end

    if actionAllowed == false then
        return false
    end

    local nodeNameList = SurveyZoneList.lang.nodeName

    -- d(zo_strformat("<<1>>", interactionName:lower()))

    for nodeNameIdx, nodeNamePartToFind in pairs(nodeNameList) do
        if string.find(interactionName:lower(), nodeNamePartToFind) then
            return true
        end
    end

    return false
end
