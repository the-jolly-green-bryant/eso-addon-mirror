SurveyZoneList.GUI = {}

--[[
-- @var table The ui TolLevelWindow
--]]
SurveyZoneList.GUI.ui = nil

--[[
-- @var table The ui backdrop
--]]
SurveyZoneList.GUI.backUI = nil

--[[
-- @var table The first item of the list which display list title
--]]
SurveyZoneList.GUI.title = nil

--[[
-- @var table The second item of the list which display info about the current survey
--]]
SurveyZoneList.GUI.currentNode = nil

--[[
-- @var table Label which display the number of node has been looted on the spot
--]]
SurveyZoneList.GUI.nodeCounter = nil

--[[
-- @var tabke Label which display info about the current spot
--]]
SurveyZoneList.GUI.spotInfo = nil

--[[
-- @var table The fragment used to link the ui to a scene
--]]
SurveyZoneList.GUI.fragment = nil

--[[
-- @var table A list of all GUIItems created. We cannot remove an ui item from
-- memory, so we keep it all created items here to reuse it when the list is refreshed.
--]]
SurveyZoneList.GUI.itemList = {}

--[[
-- @var table All saved variables dedicated to the gui.
--]]
SurveyZoneList.GUI.savedVars = nil

--[[
-- Initialise the GUI
--]]
function SurveyZoneList.GUI:init()
    self.savedVars = SurveyZoneList.savedVariables.gui

    self:initSavedVarsValues()
    self:build()
    self:defineFragment()
end

--[[
-- Initialise with a default value all saved variables dedicated to the gui
--]]
function SurveyZoneList.GUI:initSavedVarsValues()
    if self.savedVars.position == nil then
        self.savedVars.position = {}
    end
    if self.savedVars.position.top == nil then
        self.savedVars.position.top = 0
    end
    if self.savedVars.position.left == nil then
        self.savedVars.position.left = 0
    end
    
    if self.savedVars.hidden == nil then
        self.savedVars.hidden = false
    end
    
    if self.savedVars.locked == nil then
        self.savedVars.locked = false
    end
    
    if self.savedVars.displayWithWMap == nil then
        self.savedVars.displayWithWMap = false
    end

    if self.savedVars.displayItemText == nil then
        self.savedVars.displayItemText = "<<1>> : <<2>> - <<3>> / <<4>>"
    end
    
    if self.savedVars.displaySurvey == nil then
        self.savedVars.displaySurvey = true
    end
    
    if self.savedVars.displayTreasure == nil then
        self.savedVars.displayTreasure = true
    end
end

--[[
-- Build the GUI
--]]
function SurveyZoneList.GUI:build()
    local WindowManager = GetWindowManager()

    self.ui = WindowManager:CreateTopLevelWindow("SurveyZoneListUI")
	self.ui:SetClampedToScreen(true)
	self.ui:ClearAnchors()
    self.ui:SetHidden(self.savedVars.hidden)
    self.ui:SetDimensions(300, 30)
	self.ui:SetHandler("OnMoveStop", function(...) SurveyZoneList.Events.onGuiMoveStop() end)
    self:restorePosition()
    self:defineLocked(self.savedVars.locked)

	self.backUI = WindowManager:CreateControl("SurveyZoneListUIBack", self.ui, CT_BACKDROP)
    self.backUI:SetAnchor(TOPLEFT, self.ui, TOPLEFT, 0, 0)
    self.backUI:SetDimensions(self.ui:GetWidth(), self.ui:GetHeight())
    self.backUI:SetHidden(self.savedVars.hidden)
	self.backUI:SetCenterColor(0, 0, 0, .25)
	self.backUI:SetEdgeColor(0, 0, 0, .25)
	self.backUI:SetEdgeTexture(nil, 1, 1, 0, 0)

	self.title = WindowManager:CreateControl("SurveyZoneListUITitle", self.ui, CT_BACKDROP)
    self.title:SetAnchor(TOPLEFT, self.ui, TOPLEFT, 0, 0)
    self.title:SetDimensions(self.ui:GetWidth(), 30)
    self.title:SetHidden(self.savedVars.hidden)
	self.title:SetCenterColor(0, 0, 0, .25)
	self.title:SetEdgeColor(0, 0, 0, .25)
	self.title:SetEdgeTexture(nil, 1, 1, 0, 0)

    local titleLabel = WindowManager:CreateControl("titleLabel", self.title, CT_LABEL)
    titleLabel:SetAnchor(TOPLEFT, self.title, TOPLEFT, 5, 3)
    titleLabel:SetText(GetString(SI_SURVEYZONELIST_LIST_TITLE))
    titleLabel:SetFont("ZoFontGame")

	self.currentNode = WindowManager:CreateControl("SurveyZoneListUICurrentNode", self.ui, CT_BACKDROP)
    self.currentNode:SetAnchor(TOPLEFT, self.ui, TOPLEFT, 0, 30)
    self.currentNode:SetDimensions(self.ui:GetWidth(), 30)
    self.currentNode:SetHidden(self.savedVars.hidden)
	self.currentNode:SetCenterColor(0, 0, 0, .25)
	self.currentNode:SetEdgeColor(0, 0, 0, .25)
	self.currentNode:SetEdgeTexture(nil, 1, 1, 0, 0)

    local nodeIcon = WindowManager:CreateControl("SurveyZoneListUICurrentNodeIcon", self.currentNode, CT_TEXTURE)
    nodeIcon:SetDimensions(25, 25)
    nodeIcon:SetAnchor(TOPLEFT, self.currentNode, TOPLEFT, 5, 3)
    nodeIcon:SetTexture("/esoui/art/icons/poi/poi_crafting_complete.dds")

    self.nodeCounter = WindowManager:CreateControl("SurveyZoneListUICurrentNodeCounterLabel", self.currentNode, CT_LABEL)
    self.nodeCounter:SetAnchor(TOPLEFT, nodeIcon, TOPLEFT, 30, 3)
    self.nodeCounter:SetText("0/6")
    self.nodeCounter:SetFont("ZoFontGame")

    local spotIcon = WindowManager:CreateControl("SurveyZoneListUICurrentSpotIcon", self.currentNode, CT_TEXTURE)
    spotIcon:SetDimensions(30, 30)
    spotIcon:SetAnchor(TOPLEFT, self.currentNode, TOPLEFT, 110, 3)
    spotIcon:SetTexture("/esoui/art/treeicons/achievements_indexicon_summary_down.dds")

    self.spotInfo = WindowManager:CreateControl("SurveyZoneListUICurrentNodeSpotInfo", self.currentNode, CT_LABEL)
    self.spotInfo:SetAnchor(TOPLEFT, nodeIcon, TOPLEFT, 140, 3)
    self.spotInfo:SetText("No info")
    self.spotInfo:SetFont("ZoFontGame")
end

--[[
-- Restore the GUI's position from saved variables
--]]
function SurveyZoneList.GUI:restorePosition()
    self.ui:ClearAnchors()

    local left = self.savedVars.position.left
    local top  = self.savedVars.position.top

    self.ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

--[[
-- Return info about if the GUI position is locked or not
--
-- @return bool
--]]
function SurveyZoneList.GUI:isLocked()
    return self.savedVars.locked
end

--[[
-- Define if the GUI is locked or not.
--
-- @param bool value
--]]
function SurveyZoneList.GUI:defineLocked(value)
    self.savedVars.locked = value

	self.ui:SetMouseEnabled(not value)
	self.ui:SetMovable(not value)
end

--[[
-- Return info about if the GUI should be displayed when the world map is open or not
--
-- @return bool
--]]
function SurveyZoneList.GUI:isDisplayWithWMap()
    return self.savedVars.displayWithWMap
end

--[[
-- Define if the GUI should be displayed when the world map is open or not
--
-- @param bool value
--]]
function SurveyZoneList.GUI:defineDisplayWithWMap(value)
    self.savedVars.displayWithWMap = value

	if value == true then
        SCENE_MANAGER:GetScene("worldMap"):AddFragment(self.fragment)
    else
        SCENE_MANAGER:GetScene("worldMap"):RemoveFragment(self.fragment)
    end
end

--[[
-- Return the text format used for each item
--
-- @return string
--]]
function SurveyZoneList.GUI:obtainDisplayItemText()
    return self.savedVars.displayItemText
end

--[[
-- Define a new text format for items
--
-- @param string value
--]]
function SurveyZoneList.GUI:defineDisplayItemText(value)
    self.savedVars.displayItemText = value
    self:refreshAll()
end

--[[
-- Return info about if 
--
-- @return bool
--]]
function SurveyZoneList.GUI:isDisplaySurvey()
    return self.savedVars.displaySurvey
end

--[[
-- Define 
--
-- @param bool value
--]]
function SurveyZoneList.GUI:defineDisplaySurvey(value)
    self.savedVars.displaySurvey = value
    self:refreshAll()
end

--[[
-- Return info about 
--
-- @return bool
--]]
function SurveyZoneList.GUI:isDisplayTreasure()
    return self.savedVars.displayTreasure
end

--[[
-- Define 
--
-- @param bool value
--]]
function SurveyZoneList.GUI:defineDisplayTreasure(value)
    self.savedVars.displayTreasure = value
    self:refreshAll()
end

--[[
-- Save the GUI's position to savedVariables
--]]
function SurveyZoneList.GUI:savePosition()
    self.savedVars.position.left = self.ui:GetLeft()
    self.savedVars.position.top  = self.ui:GetTop()
end

--[[
-- Define GUI as a fragment linked to scenes.
-- With that, the GUI is hidden when we open a menu (like inventory or map)
--]]
function SurveyZoneList.GUI:defineFragment()
    self.fragment = ZO_SimpleSceneFragment:New(self.ui)

    SCENE_MANAGER:GetScene("hud"):AddFragment(self.fragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(self.fragment)
end

--[[
-- Show or hide the GUI
-- If the GUI is currently hidden, it will be shown.
-- If the GUI is currently shown, it will be hidden.
--]]
function SurveyZoneList.GUI:toggle()
    self.savedVars.hidden = not self.savedVars.hidden
    self.ui:SetHidden(self.savedVars.hidden)
    self.backUI:SetHidden(self.savedVars.hidden)
    self.title:SetHidden(self.savedVars.hidden)
    self.currentNode:SetHidden(self.savedVars.hidden)

    if self.savedVars.hidden == true then
        self:hideAllItems()
    else
        self:showAllItems()
    end
end

--[[
-- Refresh all items displayed
--]]
function SurveyZoneList.GUI:refreshAll()
    self:resetAllItems()

    local idx    = 1
    local uiItem = nil

    SurveyZoneList.ItemSort:exec()

    for listIdx, zoneInfo in pairs(SurveyZoneList.Collect.orderedList) do
        local zoneName = zoneInfo.name

        if 
            (self.savedVars.displaySurvey == true and zoneInfo.survey.nbUnique > 0)
            or
            (self.savedVars.displayTreasure == true and zoneInfo.treasure.nbUnique > 0)
        then
            if self.itemList[idx] == nil then
                self.itemList[idx] = SurveyZoneList.GUIItem:new()
            end

            guiItem = self.itemList[idx]
            guiItem.used     = true
            guiItem.zoneName = zoneName
            guiItem.zoneInfo = zoneInfo
            guiItem:updateText()
            guiItem:display(self.savedVars.hidden)
            
            guiItem:definePosition(idx)
            idx = idx + 1
        end
    end

    self.ui:SetDimensions(self.ui:GetWidth(), idx*30)
    self.backUI:SetDimensions(self.ui:GetWidth(), self.ui:GetHeight())
end

--[[
-- Reset each item values an hide it
--]]
function SurveyZoneList.GUI:resetAllItems()
    for idx, guiItem in pairs(self.itemList) do
        if guiItem ~= nil then
            guiItem.used     = false
            guiItem.zoneName = nil
            guiItem.zoneInfo = nil
            guiItem:hide()
        end
    end
end

--[[
-- Hide all items
--]]
function SurveyZoneList.GUI:hideAllItems()
    for idx, guiItem in pairs(self.itemList) do
        if guiItem ~= nil then
            if guiItem.used == true then
                guiItem:hide()
            end
        end
    end
end

--[[
-- Show all used items
--]]
function SurveyZoneList.GUI:showAllItems()
    for idx, guiItem in pairs(self.itemList) do
        if guiItem ~= nil then
            if guiItem.used == true then
                guiItem:show()
            end
        end
    end
end

--[[
-- Update the node counter value displayed
--]]
function SurveyZoneList.GUI:updateCounter()
    self.nodeCounter:SetText(
        zo_strformat(
            "<<1>> / <<2>>",
            SurveyZoneList.Recolt.counter,
            SurveyZoneList.Recolt.maxNode
        )
    )
end

--[[
-- Update the spot info displayed
--]]
function SurveyZoneList.GUI:updateSpotInfo()
    local str = GetString(SI_SURVEYZONELIST_GUI_REMAINING)

    if SurveyZoneList.Alerts.zoneQuantity == 0 then
        str = GetString(SI_SURVEYZONELIST_GUI_GO_NEXT_ZONE)
    elseif SurveyZoneList.Alerts.spotQuantity == 0 then
        str = GetString(SI_SURVEYZONELIST_GUI_GO_NEXT_SPOT)
    end

    self.spotInfo:SetText(zo_strformat(str, SurveyZoneList.Alerts.spotQuantity))
end