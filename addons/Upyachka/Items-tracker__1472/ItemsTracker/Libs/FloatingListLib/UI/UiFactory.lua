--Register with LibStub
local MAJOR, MINOR = "Up_UiFactory", 2
local LIB, _ = LibStub:NewLibrary(MAJOR, MINOR)
if not LIB then return end -- avoid double loading.

--- Used to create widgets.

local UiTools = LibStub:GetLibrary("Up_UiTools")

local InfoContainer = LibStub:GetLibrary("Up_InfoContainer")

--[[
    TODO list
    # Configure layouts in xml.
    ]] --

-- System window manager. Same as GetWindowManager(). See globalvars.lua
local windowManager = GetWindowManager()

-- Produces simple top level container.
function LIB.createWindow(id)
    local container = windowManager:CreateTopLevelWindow(id)
    container:SetClampedToScreen(true)
    container:SetMouseEnabled(true)
    container:SetResizeToFitDescendents(true)
    container:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, 0)
    container:SetHidden(false)
    return container
end

-- Produces simple container.
function LIB.createContainer(id, parent, type)
    local backdrop = windowManager:CreateControl("$(parent)_" .. id, parent, type)
    backdrop:SetClampedToScreen(true)
    backdrop:SetResizeToFitDescendents(true)
    backdrop:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
    backdrop:SetHidden(false)
    return backdrop
end

-- Produces window with shadow backdrop.
function LIB.createPaddingWindow(id, padding, shadowEnabled)
    local root = LIB.createWindow(id)
    if shadowEnabled then
        local backdrop = LIB.createContainer("backdrop", root, CT_BACKDROP)
        backdrop:SetResizeToFitPadding(2 * padding, 2 * padding)
        backdrop:SetAnchor(TOPLEFT, root, TOPLEFT, 0, 0)
        UiTools.addShadow(backdrop)
        local container = LIB.createContainer("container", backdrop, CT_CONTROL)
        container:SetAnchor(TOPLEFT, backdrop, TOPLEFT, padding, padding)
        return InfoContainer:new(id, root, backdrop, container)
    else
        root:SetResizeToFitPadding(2 * padding, 2 * padding)
        local container = LIB.createContainer("container", root, CT_CONTROL)
        container:SetAnchor(TOPLEFT, root, TOPLEFT, padding, padding)
        return InfoContainer:new(id, root, container)
    end
end

-- Creates label and adds it to specified container.
function LIB.createNormalLabel(id, parent)
    local container = UiTools.getContainer(parent)
    local label = windowManager:CreateControl("$(parent)_" .. id, container, CT_LABEL)
    label:SetColor(0.8, 0.8, 0.8, 1) -- TODO custom color
    label:SetFont("ZoFontGameMedium")
    label:SetWrapMode(TEX_MODE_CLAMP)
    return label
end
