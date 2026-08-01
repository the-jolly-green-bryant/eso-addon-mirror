SurveyZoneList.Settings = {}

-- @var string The name of the setting panel
SurveyZoneList.Settings.panelName = "SurveyZoneListSettingsPanel"

--[[
-- Initialise the Setting interface
--]]
function SurveyZoneList.Settings:init()
    local panelData = {
        type               = "panel",
        name               = SurveyZoneList.name,
        author             = "bulton-fr",
        registerForRefresh = true,
    }

    SurveyZoneList.LAM:RegisterAddonPanel(self.panelName, panelData)
    self:build()
end

--[[
-- Build the settings interface
--]]
function SurveyZoneList.Settings:build()
    local optionsData = {
        self:buildGUILocked(),
        self:buildDisplayedWithWorldMap(),
        self:buildDisplaySurvey(),
        self:buildDisplayTreasure(),
        self:buildCurrentZoneFirst(),
        self:buildDisplayItemText(),
        {
            type = "header",
            name = GetString(SI_SURVEYZONELIST_SETTINGS_SORT_TITLE)
        },
        {
            type = "description",
            text = GetString(SI_SURVEYZONELIST_SETTINGS_SORT_DESC)
        },
        self:buildSort(1),
        self:buildSort(2),
        self:buildSort(3),
        self:buildSort(4),
        {
            type = "header",
            name = GetString(SI_SURVEYZONELIST_SETTINGS_INTERACTION_TITLE)
        },
        {
            type = "description",
            text = GetString(SI_SURVEYZONELIST_SETTINGS_INTERACTION_DESC)
        },
        self:buildInteractionShowIcon(),
        {
            type = "header",
            name = GetString(SI_SURVEYZONELIST_SETTINGS_ALERT_TITLE)
        },
        {
            type = "description",
            text = GetString(SI_SURVEYZONELIST_SETTINGS_ALERT_DESC)
        },
        self:buildAlertWhen(),
        self:buildAlertUseAlert(),
        self:buildAlertUseSound(),
        self:buildAlertChoiceSound(),
        self:buildAlertPlaySound(),
    }

    SurveyZoneList.LAM:RegisterOptionControls(self.panelName, optionsData)
end

--[[
-- Return info to build the setting panel for "lock ui"
--
-- @return table
--]]
function SurveyZoneList.Settings:buildGUILocked()
    return {
        type    = "checkbox",
        name    = GetString(SI_SURVEYZONELIST_SETTINGS_LOCKUI),
        getFunc = function()
            return SurveyZoneList.GUI:isLocked()
        end,
        setFunc = function(value)
            SurveyZoneList.GUI:defineLocked(value)
        end,
    }
end

--[[
-- Return info to build the setting panel for "display with world map"
--
-- @return table
--]]
function SurveyZoneList.Settings:buildDisplayedWithWorldMap()
    return {
        type    = "checkbox",
        name    = GetString(SI_SURVEYZONELIST_SETTINGS_DISPLAYED_WITH_WM),
        getFunc = function()
            return SurveyZoneList.GUI:isDisplayWithWMap()
        end,
        setFunc = function(value)
            SurveyZoneList.GUI:defineDisplayWithWMap(value)
        end,
    }
end

--[[
-- Return info to build the setting panel for "display survey"
--
-- @return table
--]]
function SurveyZoneList.Settings:buildDisplaySurvey()
    return {
        type    = "checkbox",
        name    = GetString(SI_SURVEYZONELIST_SETTINGS_DISPLAY_SURVEY),
        getFunc = function()
            return SurveyZoneList.GUI:isDisplaySurvey()
        end,
        setFunc = function(value)
            SurveyZoneList.GUI:defineDisplaySurvey(value)
        end,
    }
end

--[[
-- Return info to build the setting panel for "display treasure"
--
-- @return table
--]]
function SurveyZoneList.Settings:buildDisplayTreasure()
    return {
        type    = "checkbox",
        name    = GetString(SI_SURVEYZONELIST_SETTINGS_DISPLAY_TREASURE),
        getFunc = function()
            return SurveyZoneList.GUI:isDisplayTreasure()
        end,
        setFunc = function(value)
            SurveyZoneList.GUI:defineDisplayTreasure(value)
        end,
    }
end

--[[
-- Return info to build the setting panel for "keep the current zone first"
--
-- @return table
--]]
function SurveyZoneList.Settings:buildCurrentZoneFirst()
    return {
        type    = "checkbox",
        name    = GetString(SI_SURVEYZONELIST_SETTINGS_CURRENT_ZONE_FIRST),
        getFunc = function()
            return SurveyZoneList.ItemSort:isKeepCurrentZoneFirst()
        end,
        setFunc = function(value)
            SurveyZoneList.ItemSort:defineKeepCurrentZoneFirst(value)
        end,
    }
end

--[[
-- Return info to build the setting panel for "item text format"
--
-- @return table
--]]
function SurveyZoneList.Settings:buildDisplayItemText()
    return {
        type        = "editbox",
        name        = GetString(SI_SURVEYZONELIST_SETTINGS_ITEM_TEXT_FORMAT),
        isMultiline = false,
        isExtraWide = false,
        tooltip     = GetString(SI_SURVEYZONELIST_SETTINGS_ITEM_TEXT_FORMAT_DESC),
        getFunc     = function()
            return SurveyZoneList.GUI:obtainDisplayItemText()
        end,
        setFunc     = function(value)
            return SurveyZoneList.GUI:defineDisplayItemText(value)
        end,
    }
end

--[[
-- Return info to build the setting panel for a "sort" order
--
-- @param integer pos The sort order
--
-- @return table
--]]
function SurveyZoneList.Settings:buildSort(pos)
    return {
        type          = "dropdown",
        name          = zo_strformat("#<<1>>", pos),
        choices       = {
            GetString(SI_SURVEYZONELIST_SETTINGS_SORT_ZONE_NAME),
            GetString(SI_SURVEYZONELIST_SETTINGS_SORT_SURVEY_NB_UNIQUE),
            GetString(SI_SURVEYZONELIST_SETTINGS_SORT_SURVEY_NB_TOTAL),
            GetString(SI_SURVEYZONELIST_SETTINGS_SORT_TREASURE_NB_UNIQUE),
        },
        choicesValues = {
            SurveyZoneList.ItemSort.ORDER_TYPE_ZONE_NAME,
            SurveyZoneList.ItemSort.ORDER_TYPE_SURVEY_NB_UNIQUE,
            SurveyZoneList.ItemSort.ORDER_TYPE_SURVEY_NB_TOTAL,
            SurveyZoneList.ItemSort.ORDER_TYPE_TREASURE_NB_UNIQUE,
        },
        getFunc       = function()
            return SurveyZoneList.ItemSort:obtainOrder()[pos]
        end,
        setFunc       = function(sortOrder)
            SurveyZoneList.ItemSort:defineOrder(pos, sortOrder)
        end
    }
end


--[[
-- Return info to build the setting panel for interaction : show icon
--
-- @return table
--]]
function SurveyZoneList.Settings:buildInteractionShowIcon()
    return {
        type    = "checkbox",
        name    = GetString(SI_SURVEYZONELIST_SETTINGS_INTERACTION_SHOW_ICON),
        getFunc = function()
            return SurveyZoneList.Interaction:getShowIcon()
        end,
        setFunc = function(value)
            SurveyZoneList.Interaction:setShowIcon(value)
        end,
    }
end

--[[
-- Return info to build the setting panel for alert : when
--
-- @return table
--]]
function SurveyZoneList.Settings:buildAlertWhen()
    return {
        type          = "dropdown",
        name          = GetString(SI_SURVEYZONELIST_SETTINGS_ALERT_WHEN),
        choices       = {
            GetString(SI_SURVEYZONELIST_SETTINGS_ALERT_WHEN_START),
            GetString(SI_SURVEYZONELIST_SETTINGS_ALERT_WHEN_END),
        },
        choicesValues = {
            SurveyZoneList.Alerts.WHEN_START,
            SurveyZoneList.Alerts.WHEN_END
        },
        getFunc       = function()
            return SurveyZoneList.Alerts:getWhen()
        end,
        setFunc       = function(value)
            SurveyZoneList.Alerts:setWhen(value)
        end
    }
end

--[[
-- Return info to build the setting panel for alert : use alert (announce)
--
-- @return table
--]]
function SurveyZoneList.Settings:buildAlertUseAlert()
    return {
        type    = "checkbox",
        name    = GetString(SI_SURVEYZONELIST_SETTINGS_ALERT_USE_ALERT),
        getFunc = function()
            return SurveyZoneList.Alerts:getAlert()
        end,
        setFunc = function(value)
            SurveyZoneList.Alerts:setAlert(value)
        end,
    }
end

--[[
-- Return info to build the setting panel for alert : use sound
--
-- @return table
--]]
function SurveyZoneList.Settings:buildAlertUseSound()
    return {
        type    = "checkbox",
        name    = GetString(SI_SURVEYZONELIST_SETTINGS_ALERT_USE_SOUND),
        getFunc = function()
            return SurveyZoneList.Alerts:getSoundUse()
        end,
        setFunc = function(value)
            SurveyZoneList.Alerts:setSoundUse(value)
        end,
    }
end

--[[
-- Return info to build the setting panel for alert : sound choice
--
-- @return table
--]]
function SurveyZoneList.Settings:buildAlertChoiceSound()
    local soundsList = {
        {value = "", name = "No sound"},
        {value = "NEW_NOTIFICATION", name = "New"},
        {value = "GROUP_REQUEST_DECLINED", name = "Group Request Declined"},
        {value = "DEFER_NOTIFICATION", name = "Defer"},
        {value = "NEW_MAIL", name = "New Mail"},
        {value = "MAIL_SENT", name = "Mail Sent"},
        {value = "ACHIEVEMENT_AWARDED", name = "Achievement Awarded"},
        {value = "QUEST_ACCEPTED", name = "Quest Accepted"},
        {value = "QUEST_ABANDONED", name = "Quest Abandoned"},
        {value = "QUEST_COMPLETED", name = "Quest Completed"},
        {value = "QUEST_STEP_FAILED", name = "Quest Step Failed"},
        {value = "QUEST_FOCUSED", name = "Quest Focused"},
        {value = "OBJECTIVE_ACCEPTED", name = "Objective Accepted"},
        {value = "OBJECTIVE_COMPLETED", name = "Objective Completed"},
        {value = "OBJECTIVE_DISCOVERED", name = "Objective Discovered"},
        {value = "INVENTORY_ITEM_JUNKED", name = "Inventory Item Junked"},
        {value = "INVENTORY_ITEM_UNJUNKED", name = "Inventory Item Unjunked"},
        {value = "COLLECTIBLE_UNLOCKED", name = "Collectible Unlocked"},
        {value = "JUSTICE_STATE_CHANGED", name = "Justice State Changed"},
        {value = "JUSTICE_NOW_KOS", name = "Justice Now KOS"},
        {value = "JUSTICE_NO_LONGER_KOS", name = "Justice No Longer KOS"},
        {value = "JUSTICE_GOLD_REMOVED", name = "Justice Gold Removed"},
        {value = "JUSTICE_ITEM_REMOVED", name = "Justice Item Removed"},
        {value = "JUSTICE_PICKPOCKET_BONUS", name = "Justice Pickpocket Bonus"},
        {value = "JUSTICE_PICKPOCKET_FAILED", name = "Justice Pickpocket Failed"},
        {value = "GROUP_JOIN", name = "Group Join"},
        {value = "GROUP_LEAVE", name = "Group Leave"},
        {value = "GROUP_DISBAND", name = "Group Disband"},
        {value = "TELVAR_GAINED", name = "Telvar Gained"},
        {value = "TELVAR_LOST", name = "Telvar Lost"},
        {value = "RAID_TRIAL_COMPLETED", name = "Raid Trial Completed"},
        {value = "RAID_TRIAL_FAILED", name = "Raid Trial Failed"},
    }

    local choicesKeys = {}
    local choicesName = {}

    for idx, soundInfo in ipairs(soundsList) do
        table.insert(choicesKeys, soundInfo.value)
        table.insert(choicesName, soundInfo.name)
    end

    return {
        type          = "dropdown",
        name          = GetString(SI_SURVEYZONELIST_SETTINGS_ALERT_CHOICE_SOUND),
        choices       = choicesName,
        choicesValues = choicesKeys,
        getFunc       = function()
            return SurveyZoneList.Alerts:getSoundId()
        end,
        setFunc       = function(idSound)
            SurveyZoneList.Alerts:setSoundId(idSound)
        end,
        disabled      = function()
            return not SurveyZoneList.Alerts:getSoundUse()
        end
    }
end

--[[
-- Return info to build the setting panel for alert : play chosen sound
--
-- @return table
--]]
function SurveyZoneList.Settings:buildAlertPlaySound()
    return {
        type  = "button",
        name  = GetString(SI_SURVEYZONELIST_SETTINGS_ALERT_PLAY_SOUND),
        width = "half",
        func  = function()
            PlaySound(SOUNDS[SurveyZoneList.Alerts:getSoundId()])
        end,
        disabled      = function()
            return not SurveyZoneList.Alerts:getSoundUse()
        end
    }
end
