local tbug = TBUG or SYSTEMS:GetSystem("merTorchbug")
local classes = tbug.classes
local TextButton = classes.TextButton

local types = tbug.types
--local stringType = types.string
--local numberType = types.number
local functionType = types.func
--local tableType = types.table
--local userDataType = types.userdata
--local structType = types.struct

function TextButton:__init__(parent, name)
    self.control = assert(parent:GetNamedChild(name))
    self.label = assert(self.control:GetLabelControl())
    self.padding = 0
    self.onClicked = {}
    self.onMouseUp = nil
    self.onMouseEnter = {}
    self.onMouseExit = {}

    local function onClicked(control, mouseButton)
        local handler = self.onClicked[mouseButton]
        if handler then
            handler(self)
        end
    end

    local function onMouseUp(control, mouseButton, isUpInside, ctrl, shift, alt, command)
        local handler = self.onMouseUp
        if handler ~= nil then
            handler(control, mouseButton, isUpInside, ctrl, shift, alt, command)
        end
    end

    local function onMouseEnter(control)
        local handler = self.onMouseEnter
        if handler then
            for _, handlerFunc in ipairs(handler) do
                handlerFunc(self)
            end
        end
    end

    local function onMouseExit(control)
        local handler = self.onMouseExit
        if handler then
            for _, handlerFunc in ipairs(handler) do
                handlerFunc(self)
            end
        end
    end

    local function onScreenResized()
        local text = self.label:GetText()
        local width = self.label:GetStringWidth(text) / GetUIGlobalScale()
        self.control:SetWidth(width + self.padding)
    end

    self.control:SetHandler("OnClicked", onClicked)
    self.control:SetHandler("OnMouseUp", onMouseUp)
    self.control:SetHandler("OnMouseEnter", onMouseEnter)
    self.control:SetHandler("OnMouseExit", onMouseExit)
    self.control:RegisterForEvent(EVENT_SCREEN_RESIZED, onScreenResized)
end


function TextButton:enableMouseButton(mouseButton)
    self.control:EnableMouseButton(mouseButton, true)
end


function TextButton:fitText(text, padding)
    padding = padding or 0
    local width = self.label:GetStringWidth(text) / GetUIGlobalScale()
    self.control:SetText(text)
    self.control:SetWidth(width + padding)
    self.padding = padding
end


function TextButton:getText()
    return self.label:GetText()
end

function TextButton:getId()
    return self.id
end

function TextButton:setId(value)
    self.id = value
end


function TextButton:setMouseOverBackgroundColor(r, g, b, a)
    local mouseOverBg = self.control:GetNamedChild("MouseOverBg")
    if not mouseOverBg then
        mouseOverBg = self.control:CreateControl("$(parent)MouseOverBg", CT_TEXTURE)
        mouseOverBg:SetAnchorFill()
        mouseOverBg:SetHidden(true)
    end
    mouseOverBg:SetColor(r, g, b, a)

    local function onMouseEnterExit_textureColorBGChange(doHide)
        if mouseOverBg then mouseOverBg:SetHidden(doHide) end
    end
    self:insertOnMouseEnterHandler(function() onMouseEnterExit_textureColorBGChange(false) end, 1)
    self:insertOnMouseExitHandler(function() onMouseEnterExit_textureColorBGChange(true) end, 1)
end

function TextButton:setMouseEnabled(value)
    self.control:SetMouseEnabled(value)
end

function TextButton:setEnabled(value)
    self.control:SetEnabled(value)
end

function TextButton:insertOnMouseEnterHandler(func, index)
    if type(func) ~= functionType then return end
    local handlerCurrent = self.onMouseEnter
    if handlerCurrent then
        index = index or (#handlerCurrent + 1)
        table.insert(self.onMouseEnter, index, function()
            func(self)
        end)
    end
end

function TextButton:insertOnMouseExitHandler(func, index)
    if type(func) ~= functionType then return end
    local handlerCurrent = self.onMouseExit
    if handlerCurrent then
        index = index or (#handlerCurrent + 1)
        table.insert(self.onMouseExit, index, function()
            func(self)
        end)
    end
end