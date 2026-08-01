WorldEventsTracker.GUIItem = {}
WorldEventsTracker.GUIItem.__index = WorldEventsTracker.GUIItem

WorldEventsTracker.GUIItem.offsetYRelColor = -5

--[[
-- Instanciate a new GUIItem "object"
--
-- @param itemIdx the worldEvent GUI item index
--
-- @return GUIItem
--]]
function WorldEventsTracker.GUIItem:new(itemIdx)

    local titleFormat = WorldEventsTracker.savedVariables.gui.labelFormat

    local guiItem = {
        used     = false,
        event    = nil,
        control  = nil,
        colorctr = nil,
        labelctr = nil,
        valuectr = nil,
        title    = "",
        value    = ""
    }

    setmetatable(guiItem, self)

    guiItem.control = CreateControlFromVirtual(
        "WorldEventsTrackerGUIItem",
        WorldEventsTrackerGUI,
        "WorldEventsTrackerGUIRow",
        itemIdx
    )

    guiItem.control:ClearAnchors()
    if itemIdx > 1 then
        local prevItemIdx = itemIdx - 1
        guiItem.control:SetAnchor(
            TOPLEFT,
            _G["WorldEventsTrackerGUIItem"..prevItemIdx],
            BOTTOMLEFT,
            0,
            0
        )
    else
        guiItem.control:SetAnchor(TOPLEFT, WorldEventsTrackerGUI, TOPLEFT, 0, 0)
    end

    guiItem.colorctr = guiItem.control:GetNamedChild("Color")
    guiItem.labelctr = guiItem.control:GetNamedChild("Label")
    guiItem.valuectr = guiItem.control:GetNamedChild("Value")

    guiItem:defineTooltips()

    return guiItem
end

--[[
-- Set a new dragon|poi to associate with the guiItem
--
-- @param Dragon|POI event
--]]
function WorldEventsTracker.GUIItem:setEvent(event)
    self.used  = true
    self.event = event
    self.title = event.GUI.title[titleFormat]

    self:changeColor({r=0, g=0, b=0}, 0)
    self:show()

    if self.event.eventType == LibWorldEvents.Zone.WORLD_EVENT_TYPE.DRAGON then
        self.colorctr:SetHidden(false)
        self.colorctr:SetEdgeColor(1, 1, 1, 1)
    else
        self.colorctr:SetHidden(true)
        self.colorctr:SetEdgeColor(0, 0, 0, 0)
    end
end

--[[
-- reset all properties of the guiItem and hide it
--]]
function WorldEventsTracker.GUIItem:reset()
    self:clear()
    self:hide()

    self.used  = false
    self.event = nil
    self.title = ""
    self.value = ""
end

--[[
-- Define all tooltip
--]]
function WorldEventsTracker.GUIItem:defineTooltips()
    local guiItem = self

    -- Color control tooltip
    self.colorctr:SetHandler("OnMouseEnter", function(self)
        local colorTooltipTxt = guiItem:obtainTypeTooltipText()

        if colorTooltipTxt ~= "" then
            ZO_Tooltips_ShowTextTooltip(self, BOTTOM, colorTooltipTxt)
        end
    end)

    self.colorctr:SetHandler("OnMouseExit", function(self)
        ZO_Tooltips_HideTextTooltip()
    end)
end

--[[
-- Return the text to use in color tooltip
--
-- @return string
--]]
function WorldEventsTracker.GUIItem:obtainTypeTooltipText()
    if self.event.eventType ~= LibWorldEvents.Zone.WORLD_EVENT_TYPE.DRAGON then
        return ""
    end

    if self.event.type.name == "" then
        return ""
    end

    return zo_strformat(
        "<<1>> (<<2>>)",
        self.event.type.name,
        self.event.type.colorTxt
    )
end

--[[
-- To change the color in the dragon color box
--
-- @param table newColor The new color to use.
--  The table must contain properties "r", "g" and "b"
--  /!\ It's 0-1 RGB values, not 0-255
-- @param number alpha The alpha value (0 to 1)
--]]
function WorldEventsTracker.GUIItem:changeColor(newColor, alpha)
    if newColor == nil then
        self.colorctr:SetCenterColor(0, 0, 0, alpha)
    else
        self.colorctr:SetCenterColor(newColor.r, newColor.g, newColor.b, alpha)
    end
end

--[[
-- Change the title type to use and update label text.
--
-- @param string newTitleType The new type of title to use
--
-- @return number The width taken by the label text.
--]]
function WorldEventsTracker.GUIItem:changeTitleType(newTitleType)
    self.title = self.event.GUI.title[newTitleType]
    self.labelctr:SetText(zo_strformat("<<1>>", self.title))

    return self.labelctr:GetTextWidth()
end

--[[
-- Move the value controler relative to the label width.
--
-- @param number labelWidth : The max width of all labels text
--]]
function WorldEventsTracker.GUIItem:moveValueCtr(labelWidth)
    self.valuectr:ClearAnchors()
    self.valuectr:SetAnchor(
        TOPLEFT,
        self.colorctr,
        TOPRIGHT,
        labelWidth + 10,
        self.offsetYRelColor
    )
end

--[[
-- Define the text value of LabelControls to empty string
--]]
function WorldEventsTracker.GUIItem:clear()
    self.colorctr:SetCenterColor(0, 0, 0, 0)
    self.labelctr:SetText("")
    self.valuectr:SetText("")
end

--[[
-- Hide or show all GUIItems.
--
-- @param boolean status true to show it, false to hide it
--]]
function WorldEventsTracker.GUIItem:display(status)
    self.colorctr:SetHidden(not status)
    self.labelctr:SetHidden(not status)
    self.valuectr:SetHidden(not status)
end

--[[
-- Show the container (LabelControl)
--]]
function WorldEventsTracker.GUIItem:show()
    self:display(true)
end

--[[
-- Hide the container (LabelControl)
--]]
function WorldEventsTracker.GUIItem:hide()
    self:display(false)
end

--[[
-- Update the message displayed in GUI for a specific event
--]]
function WorldEventsTracker.GUIItem:update()
    local eventStatus  = self.event.status.current
    local killedStatus = LibWorldEvents.Dragons.DragonStatus.list.killed
    local repopTime    = LibWorldEvents.Dragons.ZoneInfo.repopTime
    local newValue     = ""

    if 
        self.event.eventType == LibWorldEvents.Zone.WORLD_EVENT_TYPE.DRAGON and
        eventStatus == killedStatus and
        repopTime > 0
    then
        newValue = self:obtainRepopInValue(eventStatus)
    else
        newValue = self:obtainSinceValue(eventStatus)
    end

    if newValue == self.value then
        return
    end

    self.value = newValue
    -- self.labelctr:SetText(self.title)
    self.valuectr:SetText(newValue)
end

--[[
-- Obtain the text to display with a "[status] since..."
--
-- @param string eventStatus Current event's status
--
-- @return string
--]]
function WorldEventsTracker.GUIItem:obtainSinceValue(eventStatus)
    local eventTime  = self.event.status.time
    local statusText = self:obtainStatusText(eventStatus)
    local timerInfo  = self:obtainSinceTimerInfo(eventTime)

    if timerInfo == nil then
        return string.format(
            GetString(SI_WORLD_EVENTS_TRACKER_GUI_SIMPLE),
            statusText
        )
    else
        return string.format(
            GetString(SI_WORLD_EVENTS_TRACKER_GUI_STATUS),
            statusText,
            timerInfo.value,
            timerInfo.unit
        )
    end
end

--[[
-- Obtain the text to display with a "repop in..."
--
-- @return string
--]]
function WorldEventsTracker.GUIItem:obtainRepopInValue(eventStatus)
    local eventTime = self.event.status.time
    local timerInfo = self:obtainInTimerInfo(eventTime)

    if timerInfo == nil then
        return self:obtainSinceValue(eventStatus)
    else
        return string.format(
            GetString(SI_WORLD_EVENTS_TRACKER_GUI_REPOP),
            timerInfo.value,
            timerInfo.unit
        )
    end
end

--[[
-- Obtain the status to display from a event status
--
-- @param string eventStatus The event status
--
-- @return string
--]]
function WorldEventsTracker.GUIItem:obtainStatusText(eventStatus)
    if self.event.eventType == LibWorldEvents.Zone.WORLD_EVENT_TYPE.DRAGON then
        local statusList = LibWorldEvents.Dragons.DragonStatus.list

        if eventStatus == statusList.killed then
            return GetString(SI_LIB_WORLD_EVENTS_STATUS_KILLED)
        elseif eventStatus == statusList.waiting then
            return GetString(SI_LIB_WORLD_EVENTS_STATUS_WAITING)
        elseif eventStatus == statusList.fight then
            return GetString(SI_LIB_WORLD_EVENTS_STATUS_FIGHT)
        elseif eventStatus == statusList.weak then
            return GetString(SI_LIB_WORLD_EVENTS_STATUS_WEAK)
        elseif eventStatus == statusList.flying then
            return GetString(SI_LIB_WORLD_EVENTS_STATUS_FLYING)
        end
    else
        local statusList = LibWorldEvents.POI.POIStatus.list

        if eventStatus == statusList.started then
            return GetString(SI_LIB_WORLD_EVENTS_STATUS_STARTED)
        elseif eventStatus == statusList.ended then
            return GetString(SI_LIB_WORLD_EVENTS_STATUS_ENDED)
        end
    end

    return GetString(SI_LIB_WORLD_EVENTS_STATUS_UNKNOWN)
end

--[[
-- Obtain the timer text to display when message is "[status] since..." (so count from 0)
--
-- @param number eventTime the os.time() of the last event
--
-- @return table
--]]
function WorldEventsTracker.GUIItem:obtainSinceTimerInfo(eventTime)
    if eventTime == 0 then
        return nil
    end

    local currentTime = os.time()
    local timeDiff    = currentTime - eventTime

    return self:formatTime(timeDiff)
end

--[[
-- Obtain the timer text to display when message is "repop in..." (so count to 0)
--
-- @param number eventTime the os.time() of the last event
--
-- @return table
--]]
function WorldEventsTracker.GUIItem:obtainInTimerInfo(eventTime)
    local repopTime  = LibWorldEvents.Dragons.ZoneInfo.repopTime

    if eventTime == 0 then
        return nil
    end

    local currentTime = os.time()
    local repopTime   = eventTime + repopTime
    local timeDiff    = repopTime - currentTime

    if timeDiff < 0 then
        timeDiff = 0
    end

    return self:formatTime(timeDiff)
end

--[[
-- Format the time to have it for second, minute, or hour
--
-- @param number timeValue the os.time() of the last event
--
-- @return table
--]]
function WorldEventsTracker.GUIItem:formatTime(timeValue)
    local timeUnit = GetString(SI_WORLD_EVENTS_TRACKER_TIMER_SECOND)

    if timeValue > 60 then
        timeValue = timeValue / 60
        timeUnit = GetString(SI_WORLD_EVENTS_TRACKER_TIMER_MINUTE)
    end

    if timeValue > 60 then
        timeValue = timeValue / 60
        timeUnit = GetString(SI_WORLD_EVENTS_TRACKER_TIMER_HOUR)
    end

    return {
        value = timeValue,
        unit  = timeUnit
    }
end
