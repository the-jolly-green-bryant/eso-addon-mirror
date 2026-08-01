WritStylePrice.GUI = {}

--[[
-- @var table The main UI control
--]]
WritStylePrice.GUI.ui = nil

--[[
-- @var bool If the UI is hidden or not
--]]
WritStylePrice.GUI.isHidden = true

--[[
-- @var WritStylePrice.List The object which manage the ui table's content list
--]]
WritStylePrice.GUI.list = nil

--[[
-- @var table All saved variables dedicated to the gui.
--]]
WritStylePrice.GUI.savedVars = nil

--[[
-- Initialise the GUI
--]]
function WritStylePrice.GUI:init()
    self.ui        = WritStylePriceUI
    self.isHidden  = WritStylePriceUI:IsHidden()
    self.savedVars = WritStylePrice.savedVariables.gui
    self.list      = WritStylePrice.List:New(self.ui)

    SCENE_MANAGER:RegisterTopLevel(self.ui, false)

    self:initSavedVarsValues()
    self:restorePosition()
end

--[[
-- Get the info if the UI is hidden or not
--
-- @return bool
--]]
function WritStylePrice.GUI:getIsHidden()
    return self.isHidden
end

--[[
-- Refresh the list of item in the ui table
--]]
function WritStylePrice.GUI:refreshList()
    self.list:RefreshData()
end

--[[
-- Initialise with a default value all saved variables dedicated to the gui
--]]
function WritStylePrice.GUI:initSavedVarsValues()
    if self.savedVars.position == nil then
        self.savedVars.position = {}
    end
    if self.savedVars.position.top == nil then
        self.savedVars.position.top = 50
    end
    if self.savedVars.position.left == nil then
        self.savedVars.position.left = 50
    end
end

--[[
-- Show or hide the UI
--]]
function WritStylePrice.GUI:toggle()
    if self.isHidden == true then
        self:show()
    elseif self.isHidden == false then
        self:hide()
    end
end

--[[
-- Show the UI and refresh the content list
--]]
function WritStylePrice.GUI:show()
    if self.isHidden == false then
        return
    end

    self:refreshList()

    --self.ui:SetHidden(false)
    SCENE_MANAGER:ToggleTopLevel(self.ui)
    self.isHidden = false
end

--[[
-- Hide the UI
--]]
function WritStylePrice.GUI:hide()
    if self.isHidden == true then
        return
    end

    --self.ui:SetHidden(true)
    SCENE_MANAGER:ToggleTopLevel(self.ui)
    self.isHidden = true
end

--[[
-- Save the current position and size of the UI
--]]
function WritStylePrice.GUI:savePosition()
    self.savedVars.position.top  = self.ui:GetTop()
    self.savedVars.position.left = self.ui:GetLeft()
end

--[[
-- Redefine position and size of the UI from saved data
--]]
function WritStylePrice.GUI:restorePosition()
    local position = self.savedVars.position

    self.ui:ClearAnchors()
    self.ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, position.left, position.top)
end

--[[
-- Called on each ui table header cell
--
-- @param table control
-- @param string name
-- @param string key
--]]
function WritStylePrice.GUI.headerInitCell(control, name, key)
    ZO_SortHeader_Initialize(
        control,
        name,
        key,
        ZO_SORT_ORDER_UP,
        TEXT_ALIGN_LEFT,
        "ZoFontWinT1",
        nil
    )
end
