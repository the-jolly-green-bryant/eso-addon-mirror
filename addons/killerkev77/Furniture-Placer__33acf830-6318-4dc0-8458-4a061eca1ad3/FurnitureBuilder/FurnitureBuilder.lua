-- FurnitureBuilder.lua ("Furniture Placer")
--
-- Precision alignment tools for Housing Editor: read exact furniture
-- coordinates and move items to match, instead of eyeballing placement.
--
-- Core functions confirmed against real, working, currently-maintained
-- addon source (github.com/WetWiredU/HomesteadEng):
--   HousingEditorCanSelectTargettedFurniture / SelectTargettedFurniture
--   HousingEditorGetSelectedFurnitureId
--   HousingEditorGetFurnitureWorldPosition / GetFurnitureOrientation
--   HousingEditorRequestChangePositionAndOrientation

FurnitureBuilder = FurnitureBuilder or {}
local FB = FurnitureBuilder
FB.name = "FurnitureBuilder"

-- ---------------------------------------------------------------------------
-- Screen-locked visual grid (rough alignment guide, not tied to 3D position)
-- ---------------------------------------------------------------------------

local gridWindow = nil
local gridVisible = false
local GRID_LINE_COUNT = 6
local GRID_LINE_THICKNESS = 2

local function BuildGrid()
    if gridWindow then return end

    local ok, err = pcall(function()
        gridWindow = WINDOW_MANAGER:CreateTopLevelWindow("FurnitureBuilder_Grid")
        gridWindow:SetAnchorFill(GuiRoot)
        gridWindow:SetHidden(true)
        gridWindow:SetMouseEnabled(false)

        local screenW = GuiRoot:GetWidth()
        local screenH = GuiRoot:GetHeight()

        for i = 1, GRID_LINE_COUNT do
            local x = (screenW / (GRID_LINE_COUNT + 1)) * i
            local line = WINDOW_MANAGER:CreateControl(nil, gridWindow, CT_BACKDROP)
            line:SetDimensions(GRID_LINE_THICKNESS, screenH)
            line:SetAnchor(TOPLEFT, gridWindow, TOPLEFT, x, 0)
            line:SetCenterColor(1, 1, 0, 0.45)
        end

        for i = 1, GRID_LINE_COUNT do
            local y = (screenH / (GRID_LINE_COUNT + 1)) * i
            local line = WINDOW_MANAGER:CreateControl(nil, gridWindow, CT_BACKDROP)
            line:SetDimensions(screenW, GRID_LINE_THICKNESS)
            line:SetAnchor(TOPLEFT, gridWindow, TOPLEFT, 0, y)
            line:SetCenterColor(1, 1, 0, 0.45)
        end
    end)

    if not ok then
        d("[FurnitureBuilder] grid build failed: " .. tostring(err))
    end
end

local function ToggleGrid()
    BuildGrid()
    if not gridWindow then return end
    gridVisible = not gridVisible
    gridWindow:SetHidden(not gridVisible)
end
SLASH_COMMANDS["/fbgrid"] = ToggleGrid

-- ---------------------------------------------------------------------------
-- Targeting: get the furniture ID currently under the cursor in Housing
-- Editor. Selecting alone leaves the item in an active placement/held
-- state, so the mode is reset immediately after reading the ID to release
-- it cleanly.
-- ---------------------------------------------------------------------------

local function GetTargetedFurnitureId()
    if not GetHousingEditorMode or not HOUSING_EDITOR_MODE_SELECTION then
        return nil
    end
    if GetHousingEditorMode() ~= HOUSING_EDITOR_MODE_SELECTION then
        d("[FurnitureBuilder] enter Housing Editor's selection mode first")
        return nil
    end
    if not HousingEditorCanSelectTargettedFurniture or not HousingEditorCanSelectTargettedFurniture() then
        d("[FurnitureBuilder] point your cursor at a placed furnishing first")
        return nil
    end

    local ok, furnId = pcall(function()
        LockCameraRotation(true)
        HousingEditorSelectTargettedFurniture()
        local id = HousingEditorGetSelectedFurnitureId()
        HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_DISABLED)
        HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_SELECTION)
        LockCameraRotation(false)
        return id
    end)

    if not ok or not furnId or furnId == 0 then
        return nil
    end
    return furnId
end

local function ReadTargetTransform()
    local furnId = GetTargetedFurnitureId()
    if not furnId then return nil end
    local okPos, x, y, z = pcall(HousingEditorGetFurnitureWorldPosition, furnId)
    local okRot, pitch, yaw, roll = pcall(HousingEditorGetFurnitureOrientation, furnId)
    if not okPos or not okRot then
        d("[FurnitureBuilder] could not read that item's position/orientation")
        return nil
    end
    return furnId, {x = x, y = y, z = z, pitch = pitch, yaw = yaw, roll = roll}
end

-- /fbtarget -- inspect the targeted furnishing (name, position, rotation)
local function CmdTarget()
    local furnId, t = ReadTargetTransform()
    if not t then return end

    local okInfo, name = pcall(GetPlacedHousingFurnitureInfo, furnId)
    d("[FurnitureBuilder] " .. tostring(okInfo and name or "?")
        .. " -- pos x=" .. tostring(t.x) .. " y=" .. tostring(t.y) .. " z=" .. tostring(t.z)
        .. " -- rot pitch=" .. tostring(t.pitch) .. " yaw=" .. tostring(t.yaw) .. " roll=" .. tostring(t.roll))
end
SLASH_COMMANDS["/fbtarget"] = CmdTarget

-- ---------------------------------------------------------------------------
-- Align one item to a marked reference point
-- ---------------------------------------------------------------------------

local FB_referencePos = nil -- {x, y, z, pitch, yaw, roll}

-- /fbmark -- store the targeted item's position+orientation as the
-- reference point for /fbalign, /fbalignfull, /fbalignrot.
local function CmdMark()
    local furnId, t = ReadTargetTransform()
    if not t then return end
    FB_referencePos = t
    d("[FurnitureBuilder] reference point marked")
end
SLASH_COMMANDS["/fbmark"] = CmdMark

-- /fbalign -- match X/Z to the reference, keep own height and rotation
local function CmdAlign()
    if not FB_referencePos then
        d("[FurnitureBuilder] mark a reference point first with /fbmark")
        return
    end
    local furnId, t = ReadTargetTransform()
    if not t then return end

    local ref = FB_referencePos
    local ok, err = pcall(function()
        HousingEditorRequestChangePositionAndOrientation(furnId, ref.x, t.y, ref.z, t.pitch, t.yaw, t.roll)
    end)
    if not ok then
        d("[FurnitureBuilder] align failed: " .. tostring(err))
        return
    end
    d("[FurnitureBuilder] aligned X/Z to reference")
end
SLASH_COMMANDS["/fbalign"] = CmdAlign

-- /fbalignfull -- match X/Y/Z to the reference, keep own rotation
local function CmdAlignFull()
    if not FB_referencePos then
        d("[FurnitureBuilder] mark a reference point first with /fbmark")
        return
    end
    local furnId, t = ReadTargetTransform()
    if not t then return end

    local ref = FB_referencePos
    local ok, err = pcall(function()
        HousingEditorRequestChangePositionAndOrientation(furnId, ref.x, ref.y, ref.z, t.pitch, t.yaw, t.roll)
    end)
    if not ok then
        d("[FurnitureBuilder] align failed: " .. tostring(err))
        return
    end
    d("[FurnitureBuilder] aligned full position to reference")
end
SLASH_COMMANDS["/fbalignfull"] = CmdAlignFull

-- /fbalignrot -- match position AND rotation exactly
local function CmdAlignRot()
    if not FB_referencePos then
        d("[FurnitureBuilder] mark a reference point first with /fbmark")
        return
    end
    local furnId = GetTargetedFurnitureId()
    if not furnId then return end

    local ref = FB_referencePos
    local ok, err = pcall(function()
        HousingEditorRequestChangePositionAndOrientation(furnId, ref.x, ref.y, ref.z, ref.pitch, ref.yaw, ref.roll)
    end)
    if not ok then
        d("[FurnitureBuilder] align failed: " .. tostring(err))
        return
    end
    d("[FurnitureBuilder] aligned position and rotation to reference")
end
SLASH_COMMANDS["/fbalignrot"] = CmdAlignRot

-- ---------------------------------------------------------------------------
-- Even spacing along a line
-- ---------------------------------------------------------------------------

local FB_pointA = nil
local FB_pointB = nil
local FB_spaceIndex = 0

local function CmdMarkA()
    local furnId, t = ReadTargetTransform()
    if not t then return end
    FB_pointA = t
    FB_spaceIndex = 0
    d("[FurnitureBuilder] row start marked")
end
SLASH_COMMANDS["/fbmarka"] = CmdMarkA

local function CmdMarkB()
    local furnId, t = ReadTargetTransform()
    if not t then return end
    FB_pointB = t
    d("[FurnitureBuilder] row end marked")
end
SLASH_COMMANDS["/fbmarkb"] = CmdMarkB

-- /fbspace <count> -- place the targeted item in the next evenly-spaced
-- slot along the A-B line. Call once per item, in order; the slot index
-- auto-increments and resets whenever /fbmarka runs again.
local function CmdSpace(argString)
    if not FB_pointA or not FB_pointB then
        d("[FurnitureBuilder] mark both ends of the row first: /fbmarka and /fbmarkb")
        return
    end
    local count = tonumber(argString)
    if not count or count < 2 then
        d("[FurnitureBuilder] usage: /fbspace <total item count>, e.g. /fbspace 5")
        return
    end

    local furnId = GetTargetedFurnitureId()
    if not furnId then return end

    local t = FB_spaceIndex / (count - 1)
    local a, b = FB_pointA, FB_pointB
    local x = a.x + (b.x - a.x) * t
    local y = a.y + (b.y - a.y) * t
    local z = a.z + (b.z - a.z) * t

    local ok, err = pcall(function()
        HousingEditorRequestChangePositionAndOrientation(furnId, x, y, z, a.pitch, a.yaw, a.roll)
    end)
    if not ok then
        d("[FurnitureBuilder] space failed: " .. tostring(err))
        return
    end

    d("[FurnitureBuilder] placed at slot " .. tostring(FB_spaceIndex) .. "/" .. tostring(count - 1))
    FB_spaceIndex = FB_spaceIndex + 1
end
SLASH_COMMANDS["/fbspace"] = CmdSpace

-- ---------------------------------------------------------------------------
-- Snap to a round grid increment (no reference item needed)
-- ---------------------------------------------------------------------------

-- /fbsnap <increment> -- round the targeted item's X/Z to the nearest
-- multiple of <increment> meters, e.g. /fbsnap 0.5
local function CmdSnap(argString)
    local increment = tonumber(argString)
    if not increment or increment <= 0 then
        d("[FurnitureBuilder] usage: /fbsnap <increment in meters>, e.g. /fbsnap 0.5")
        return
    end

    local furnId, t = ReadTargetTransform()
    if not t then return end

    local incCm = increment * 100
    local snappedX = zo_round(t.x / incCm) * incCm
    local snappedZ = zo_round(t.z / incCm) * incCm

    local ok, err = pcall(function()
        HousingEditorRequestChangePositionAndOrientation(furnId, snappedX, t.y, snappedZ, t.pitch, t.yaw, t.roll)
    end)
    if not ok then
        d("[FurnitureBuilder] snap failed: " .. tostring(err))
        return
    end
    d("[FurnitureBuilder] snapped to nearest " .. tostring(increment) .. "m")
end
SLASH_COMMANDS["/fbsnap"] = CmdSnap

-- ---------------------------------------------------------------------------
-- /fbhelp -- on-screen command reference (chat font size is a player
-- setting we can't control, so this draws its own larger text instead)
-- ---------------------------------------------------------------------------

local helpWindow = nil
local helpVisible = false

local FB_HELP_TEXT = table.concat({
    "Furniture Placer Commands",
    "",
    "/fbtarget - inspect targeted item",
    "/fbmark - mark a reference point",
    "/fbalign - align X/Z to reference",
    "/fbalignfull - align X/Y/Z",
    "/fbalignrot - align pos + rotation",
    "",
    "/fbmarka - mark row start",
    "/fbmarkb - mark row end",
    "/fbspace <count> - space evenly",
    "",
    "/fbsnap <increment> - snap to grid",
    "/fbgrid - toggle screen grid",
    "/fbhelp - toggle this panel",
}, "\n")

local function BuildHelpPanel()
    if helpWindow then return end
    local ok, err = pcall(function()
        helpWindow = WINDOW_MANAGER:CreateTopLevelWindow("FurnitureBuilder_Help")
        helpWindow:SetDimensions(400, 480)
        helpWindow:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -20, 20)
        helpWindow:SetHidden(true)

        local bg = WINDOW_MANAGER:CreateControl(nil, helpWindow, CT_BACKDROP)
        bg:SetAnchorFill(helpWindow)
        bg:SetCenterColor(0, 0, 0, 0.9)
        bg:SetEdgeColor(1, 1, 1, 0.6)
        bg:SetEdgeTexture("", 2, 2, 2)

        local label = WINDOW_MANAGER:CreateControl(nil, helpWindow, CT_LABEL)
        label:SetFont("ZoFontGamepad25")
        label:SetColor(1, 1, 1, 1)
        label:SetAnchor(TOPLEFT, helpWindow, TOPLEFT, 16, 16)
        label:SetDimensions(368, 448)
        label:SetVerticalAlignment(TEXT_ALIGN_TOP)
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetText(FB_HELP_TEXT)
    end)
    if not ok then
        d("[FurnitureBuilder] help panel build failed: " .. tostring(err))
        helpWindow = nil
    end
end

local function CmdHelp()
    BuildHelpPanel()
    if not helpWindow then return end
    helpVisible = not helpVisible
    helpWindow:SetHidden(not helpVisible)
end
SLASH_COMMANDS["/fbhelp"] = CmdHelp

-- ---------------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------------

local function OnAddOnLoaded(_, addonName)
    if addonName ~= FB.name then return end
    EVENT_MANAGER:UnregisterForEvent(FB.name, EVENT_ADD_ON_LOADED)
    d("[FurnitureBuilder] Furniture Placer loaded -- type /fbhelp for commands")
end

EVENT_MANAGER:RegisterForEvent(FB.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
