-- FurnitureBuilder.lua
--
-- DIAGNOSTIC BUILD -- this does not draw a real grid yet. It tests two
-- unverified assumptions before we build the real thing:
--   1) Can we draw ANY custom visual control on screen at all? (isolated
--      test via /fbtest slash command, independent of Housing Editor)
--   2) Does the game notify addons when Housing Editor mode opens/closes,
--      and does GetHousingEditorMode() report something sensible?
--
-- Both are guarded with pcall/existence checks and print diagnostics,
-- same pattern that found the real tooltip hook for Furniture Finder.

-- TESTING GATE: only these accounts can use the addon while testing.
-- Add/remove @Handles here, or delete this whole block once ready to
-- publish for everyone.
local FB_allowedTesters = {
    ["@Atomic Khaos"] = true,
    ["@Rebelnine"] = true,
}
if not FB_allowedTesters[GetDisplayName()] then return end

FurnitureBuilder = FurnitureBuilder or {}
local FB = FurnitureBuilder
FB.name = "FurnitureBuilder"

local testWindow = nil
local testLabel = nil
local testFragment = nil
local fbTestVisible = false

-- ---------------------------------------------------------------------------
-- Test 1: can we draw a custom control on screen at all?
--
-- CONFIRMED from real working ESOUI forum code: a plain control parented to
-- GuiRoot with SetHidden(false) does NOT actually render during normal
-- gameplay, regardless of what its own properties report. ESO's scene/
-- fragment system gates what's actually drawn each frame. The real
-- requirement: create a TOP LEVEL WINDOW, wrap it in a scene fragment, and
-- register that fragment with the "hud" and "hudui" scenes (keyboard and
-- gamepad HUD scenes respectively).
-- ---------------------------------------------------------------------------

local function ToggleTestBox()
    if not testWindow then
        local ok, err = pcall(function()
            testWindow = WINDOW_MANAGER:CreateTopLevelWindow("FurnitureBuilder_TestWindow")
            testWindow:SetDimensions(300, 300)
            testWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
            testWindow:SetHidden(true)

            local box = WINDOW_MANAGER:CreateControl(nil, testWindow, CT_BACKDROP)
            box:SetAnchorFill(testWindow)
            box:SetCenterColor(1, 0, 0, 1)

            testLabel = WINDOW_MANAGER:CreateControl(nil, testWindow, CT_LABEL)
            testLabel:SetFont("ZoFontWinT1")
            testLabel:SetText("FURNITURE BUILDER TEST")
            testLabel:SetColor(1, 1, 0, 1)
            testLabel:SetAnchor(CENTER, testWindow, CENTER, 0, 0)

            testFragment = ZO_FadeSceneFragment:New(testWindow)

            local sceneHud = SCENE_MANAGER:GetScene("hud")
            local sceneHudUI = SCENE_MANAGER:GetScene("hudui")
            local sceneHousingEditor = SCENE_MANAGER:GetScene("housingEditorHud")
            if sceneHud then sceneHud:AddFragment(testFragment) end
            if sceneHudUI then sceneHudUI:AddFragment(testFragment) end
            if sceneHousingEditor then sceneHousingEditor:AddFragment(testFragment) end

            d("[FurnitureBuilder] sceneHud=" .. tostring(sceneHud ~= nil)
                .. " sceneHudUI=" .. tostring(sceneHudUI ~= nil)
                .. " sceneHousingEditor=" .. tostring(sceneHousingEditor ~= nil))
        end)
        if not ok then
            d("[FurnitureBuilder] setup FAILED: " .. tostring(err))
            return
        end
        d("[FurnitureBuilder] top-level window + fragment created")
    end

    fbTestVisible = not fbTestVisible
    testWindow:SetHidden(not fbTestVisible)
    d("[FurnitureBuilder] window hidden=" .. tostring(testWindow:IsHidden()) .. " fbTestVisible=" .. tostring(fbTestVisible))
end

SLASH_COMMANDS["/fbtest"] = ToggleTestBox

-- ---------------------------------------------------------------------------
-- Real feature: toggleable on-screen grid
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

        -- NOTE: deliberately NOT wrapping in a scene fragment this time.
        -- Scene fragments (used for the earlier /fbtest box) have their own
        -- automatic show/hide logic tied to scene transitions -- which
        -- happen constantly during normal play -- and that likely fights
        -- manual SetHidden calls, which matches "won't turn off" and
        -- "drifts position" symptoms. Testing whether a bare top-level
        -- window persists on its own, purely via manual control.
    end)

    if not ok then
        d("[FurnitureBuilder] grid build FAILED: " .. tostring(err))
    else
        d("[FurnitureBuilder] grid built, NO fragment this time (" .. GRID_LINE_COUNT .. " lines each direction)")
    end
end

local function ToggleGrid()
    BuildGrid()
    if not gridWindow then return end
    gridVisible = not gridVisible
    gridWindow:SetHidden(not gridVisible)
    d("[FurnitureBuilder] grid " .. (gridVisible and "ON" or "OFF"))
end

SLASH_COMMANDS["/fbgrid"] = ToggleGrid

-- ---------------------------------------------------------------------------
-- Test 3: does a naive world-to-renderspace conversion (just /100, cm to m)
-- place a marker at the player's actual current position? This tells us
-- whether the render space origin is simple/predictable or has real drift,
-- before building the full 4-point calibration feature on top of it.
-- ---------------------------------------------------------------------------

local markerWindow = nil
local markerAnchor = nil
local markerUpdateRegistered = false
local FB_MARKER_UPDATE_ID = "FurnitureBuilder_MarkerUpdate"

local function UpdateMarkerPosition()
    if not markerAnchor then return end
    local ok, zoneId, wx, wy, wz = pcall(GetUnitWorldPosition, "player")
    if not ok then return end

    local ok3, rx, ry, rz = pcall(WorldPositionToGuiRender3DPosition, wx, wy, wz)
    if not ok3 or not rx then return end

    -- Update the MIDDLE layer (the 3D anchor) every frame -- not the plain
    -- toplevel window, and not the icon (which stays at a fixed small
    -- local offset from the anchor).
    pcall(function()
        markerAnchor:Set3DRenderSpaceOrigin(rx, ry + 2, rz)
    end)
end

local function StartMarkerUpdateLoop()
    if markerUpdateRegistered then return end
    EVENT_MANAGER:RegisterForUpdate(FB_MARKER_UPDATE_ID, 0, UpdateMarkerPosition)
    markerUpdateRegistered = true
    d("[FurnitureBuilder] marker update loop started")
end

local function TestWorldMarker()
    if not GetUnitWorldPosition then
        d("[FurnitureBuilder] GetUnitWorldPosition not found")
        return
    end
    if not WorldPositionToGuiRender3DPosition then
        d("[FurnitureBuilder] WorldPositionToGuiRender3DPosition not found")
        return
    end

    if not markerWindow then
        local ok2, err = pcall(function()
            -- LEVEL 1: plain 2D top-level window. NOT 3D-spaced. Just a
            -- scene-registration container, matching real Lib3DArrow's
            -- explicit avoidance of Create3DRenderSpace on the toplevel.
            markerWindow = WINDOW_MANAGER:CreateTopLevelWindow("FurnitureBuilder_Marker")
            markerWindow:SetDimensions(40, 40)
            markerWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)

            -- LEVEL 2: CT_CONTROL anchor, 3D-spaced, origin updated every
            -- frame to track world position. This is what "parent.marker"
            -- is in the real source.
            markerAnchor = WINDOW_MANAGER:CreateControl(nil, markerWindow, CT_CONTROL)
            markerAnchor:Create3DRenderSpace()
            markerAnchor:Set3DRenderSpaceUsesDepthBuffer(false)
            markerAnchor:Set3DRenderSpaceOrigin(0, 0, 0)

            -- LEVEL 3: CT_TEXTURE icon, ALSO its own 3D space, but with a
            -- FIXED small local origin (0,0,0) relative to the anchor --
            -- matches CreateMarkerPart() in real marker.lua exactly.
            local icon = WINDOW_MANAGER:CreateControl(nil, markerAnchor, CT_TEXTURE)
            icon:Create3DRenderSpace()
            icon:Set3DRenderSpaceUsesDepthBuffer(false)
            icon:Set3DLocalDimensions(1.5, 1.5)
            icon:Set3DRenderSpaceOrigin(0, 0, 0)
            icon:SetTexture("/esoui/art/icons/heraldrycrests_misc_blank_01.dds")
            icon:SetColor(0, 1, 1, 1)

            -- NEW HYPOTHESIS: 3D render space content might specifically
            -- need scene fragment registration to actually composite into
            -- the 3D world view, even though plain 2D overlays render fine
            -- without it once using a top-level window. Same fragment
            -- pattern that made the original /fbtest box work.
            local fragment = ZO_FadeSceneFragment:New(markerWindow)
            local sceneHud = SCENE_MANAGER:GetScene("hud")
            local sceneHudUI = SCENE_MANAGER:GetScene("hudui")
            local sceneHousingEditor = SCENE_MANAGER:GetScene("housingEditorHud")
            if sceneHud then sceneHud:AddFragment(fragment) end
            if sceneHudUI then sceneHudUI:AddFragment(fragment) end
            if sceneHousingEditor then sceneHousingEditor:AddFragment(fragment) end
        end)
        if not ok2 then
            d("[FurnitureBuilder] marker create FAILED: " .. tostring(err))
            markerWindow = nil
            markerAnchor = nil
            return
        end
        d("[FurnitureBuilder] 3-level marker structure created")
    end

    markerWindow:SetHidden(false)
    StartMarkerUpdateLoop()
    d("[FurnitureBuilder] marker placed -- look for a small cyan icon. Should be exactly where you're standing.")
end

SLASH_COMMANDS["/fbmark"] = TestWorldMarker

-- ---------------------------------------------------------------------------
-- Test 2: does Housing Editor mode notify us?
-- ---------------------------------------------------------------------------

local function CheckHousingEditorAPI()
    if type(GetHousingEditorMode) == "function" then
        local ok, mode = pcall(GetHousingEditorMode)
        d("[FurnitureBuilder] GetHousingEditorMode() = " .. tostring(ok and mode or ("ERROR: " .. tostring(mode))))
    else
        d("[FurnitureBuilder] GetHousingEditorMode function NOT found")
    end

    if EVENT_HOUSING_EDITOR_MODE_CHANGED then
        d("[FurnitureBuilder] EVENT_HOUSING_EDITOR_MODE_CHANGED exists, registering...")
        EVENT_MANAGER:RegisterForEvent(FB.name, EVENT_HOUSING_EDITOR_MODE_CHANGED, function(_, newMode, oldMode)
            d("[FurnitureBuilder] housing editor mode changed: " .. tostring(oldMode) .. " -> " .. tostring(newMode))
            local ok, scene = pcall(function() return SCENE_MANAGER:GetCurrentScene() end)
            if ok and scene then
                local ok2, name = pcall(function() return scene:GetName() end)
                d("[FurnitureBuilder] current scene name = " .. tostring(ok2 and name or "unknown"))
            else
                d("[FurnitureBuilder] could not get current scene")
            end
        end)
    else
        d("[FurnitureBuilder] EVENT_HOUSING_EDITOR_MODE_CHANGED constant NOT found")
    end
end

-- ---------------------------------------------------------------------------
-- Coordinate-based approach: target furniture, read its exact position,
-- mark a reference point, and move furniture to match it. Uses confirmed
-- real functions from Homestead Engineer's actual source (github.com/
-- WetWiredU/HomesteadEng) -- no custom drawing involved at all, which
-- sidesteps everything we struggled with on the 3D marker.
-- ---------------------------------------------------------------------------

local FB_referencePos = nil -- {x, y, z, pitch, yaw, roll}

local function GetTargetedFurnitureId()
    if not GetHousingEditorMode or not HOUSING_EDITOR_MODE_SELECTION then
        d("[FurnitureBuilder] HOUSING_EDITOR_MODE_SELECTION constant not found")
        return nil
    end
    local mode = GetHousingEditorMode()
    if mode ~= HOUSING_EDITOR_MODE_SELECTION then
        d("[FurnitureBuilder] not in HOUSING_EDITOR_MODE_SELECTION (mode=" .. tostring(mode) .. ")")
        return nil
    end
    if not HousingEditorCanSelectTargettedFurniture or not HousingEditorCanSelectTargettedFurniture() then
        d("[FurnitureBuilder] nothing targetable right now -- point your cursor at a placed furnishing")
        return nil
    end

    -- CONFIRMED real sequence from Homestead Engineer's actual source:
    -- selecting alone leaves the item in an active placement/held state,
    -- so we reset the mode immediately after reading the ID to release it.
    local ok, furnId = pcall(function()
        LockCameraRotation(true)
        HousingEditorSelectTargettedFurniture()
        local id = HousingEditorGetSelectedFurnitureId()
        HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_DISABLED)
        HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_SELECTION)
        LockCameraRotation(false)
        return id
    end)

    if not ok then
        d("[FurnitureBuilder] targeting sequence FAILED: " .. tostring(furnId))
        return nil
    end
    if not furnId or furnId == 0 then
        d("[FurnitureBuilder] furnId=" .. tostring(furnId) .. " -- invalid/no selection")
        return nil
    end
    return furnId
end

-- /fbtarget -- diagnostic: report everything we can read about whatever
-- furnishing is currently under the cursor.
local function CmdTarget()
    local furnId = GetTargetedFurnitureId()
    if not furnId then return end

    d("[FurnitureBuilder] targeted furnId=" .. tostring(furnId))

    local okInfo, name, icon, dataId = pcall(GetPlacedHousingFurnitureInfo, furnId)
    if okInfo then
        d("[FurnitureBuilder] name=" .. tostring(name) .. " dataId=" .. tostring(dataId))
    else
        d("[FurnitureBuilder] GetPlacedHousingFurnitureInfo FAILED: " .. tostring(name))
    end

    local okPos, x, y, z = pcall(HousingEditorGetFurnitureWorldPosition, furnId)
    if okPos then
        d("[FurnitureBuilder] position x=" .. tostring(x) .. " y=" .. tostring(y) .. " z=" .. tostring(z))
    else
        d("[FurnitureBuilder] HousingEditorGetFurnitureWorldPosition FAILED: " .. tostring(x))
    end

    local okRot, pitch, yaw, roll = pcall(HousingEditorGetFurnitureOrientation, furnId)
    if okRot then
        d("[FurnitureBuilder] orientation pitch=" .. tostring(pitch) .. " yaw=" .. tostring(yaw) .. " roll=" .. tostring(roll))
    else
        d("[FurnitureBuilder] HousingEditorGetFurnitureOrientation FAILED: " .. tostring(pitch))
    end
end
SLASH_COMMANDS["/fbtarget"] = CmdTarget
FB.OnTargetKeybind = CmdTarget

-- /fbmark -- store the targeted furnishing's position+orientation as the
-- reference point for alignment.
local function CmdMark()
    local furnId = GetTargetedFurnitureId()
    if not furnId then return end

    local okPos, x, y, z = pcall(HousingEditorGetFurnitureWorldPosition, furnId)
    local okRot, pitch, yaw, roll = pcall(HousingEditorGetFurnitureOrientation, furnId)
    if not okPos or not okRot then
        d("[FurnitureBuilder] could not read position/orientation, mark failed")
        return
    end

    FB_referencePos = {x = x, y = y, z = z, pitch = pitch, yaw = yaw, roll = roll}
    d("[FurnitureBuilder] marked reference point: x=" .. tostring(x) .. " y=" .. tostring(y) .. " z=" .. tostring(z))
end
SLASH_COMMANDS["/fbmark"] = CmdMark

-- /fbmovetest -- SAFE first test of the move function: nudge the targeted
-- item by a tiny, obvious, easily-undoable amount (+0.1 on X) rather than
-- jumping straight to full alignment. Confirms HousingEditorRequestChange
-- PositionAndOrientation actually works before we build on top of it.
local function CmdMoveTest()
    if not HousingEditorRequestChangePositionAndOrientation then
        d("[FurnitureBuilder] HousingEditorRequestChangePositionAndOrientation not found")
        return
    end

    local furnId = GetTargetedFurnitureId()
    if not furnId then return end

    local okPos, x, y, z = pcall(HousingEditorGetFurnitureWorldPosition, furnId)
    local okRot, pitch, yaw, roll = pcall(HousingEditorGetFurnitureOrientation, furnId)
    if not okPos or not okRot then
        d("[FurnitureBuilder] could not read current position/orientation")
        return
    end

    d("[FurnitureBuilder] before: x=" .. tostring(x) .. " y=" .. tostring(y) .. " z=" .. tostring(z))

    local ok, err = pcall(function()
        HousingEditorRequestChangePositionAndOrientation(furnId, x + 10, y, z, pitch, yaw, roll)
    end)
    if not ok then
        d("[FurnitureBuilder] move FAILED: " .. tostring(err))
        return
    end

    d("[FurnitureBuilder] move request sent (+10 on X, ~10cm) -- check in-game if it actually moved")
end
SLASH_COMMANDS["/fbmovetest"] = CmdMoveTest

-- /fbalign -- move the targeted furnishing's X/Z to match the marked
-- reference point, keeping its own Y and orientation untouched.
local function CmdAlign()
    if not FB_referencePos then
        d("[FurnitureBuilder] no reference point marked yet -- target an item and use /fbmark first")
        return
    end
    if not HousingEditorRequestChangePositionAndOrientation then
        d("[FurnitureBuilder] HousingEditorRequestChangePositionAndOrientation not found")
        return
    end

    local furnId = GetTargetedFurnitureId()
    if not furnId then return end

    local okPos, x, y, z = pcall(HousingEditorGetFurnitureWorldPosition, furnId)
    local okRot, pitch, yaw, roll = pcall(HousingEditorGetFurnitureOrientation, furnId)
    if not okPos or not okRot then
        d("[FurnitureBuilder] could not read current position/orientation")
        return
    end

    local ref = FB_referencePos
    local ok, err = pcall(function()
        HousingEditorRequestChangePositionAndOrientation(furnId, ref.x, y, ref.z, pitch, yaw, roll)
    end)
    if not ok then
        d("[FurnitureBuilder] align FAILED: " .. tostring(err))
        return
    end

    d("[FurnitureBuilder] aligned X/Z to reference (kept own Y/rotation)")
end
SLASH_COMMANDS["/fbalign"] = CmdAlign

-- /fbalignfull -- match the reference's X/Y/Z fully, keep own rotation.
local function CmdAlignFull()
    if not FB_referencePos then
        d("[FurnitureBuilder] no reference point marked yet -- use /fbmark first")
        return
    end
    if not HousingEditorRequestChangePositionAndOrientation then return end

    local furnId = GetTargetedFurnitureId()
    if not furnId then return end

    local okRot, pitch, yaw, roll = pcall(HousingEditorGetFurnitureOrientation, furnId)
    if not okRot then
        d("[FurnitureBuilder] could not read current orientation")
        return
    end

    local ref = FB_referencePos
    local ok, err = pcall(function()
        HousingEditorRequestChangePositionAndOrientation(furnId, ref.x, ref.y, ref.z, pitch, yaw, roll)
    end)
    if not ok then
        d("[FurnitureBuilder] align FAILED: " .. tostring(err))
        return
    end
    d("[FurnitureBuilder] aligned full X/Y/Z to reference (kept own rotation)")
end
SLASH_COMMANDS["/fbalignfull"] = CmdAlignFull

-- /fbalignrot -- match the reference's X/Y/Z AND rotation exactly (a true
-- duplicate placement).
local function CmdAlignRot()
    if not FB_referencePos then
        d("[FurnitureBuilder] no reference point marked yet -- use /fbmark first")
        return
    end
    if not HousingEditorRequestChangePositionAndOrientation then return end

    local furnId = GetTargetedFurnitureId()
    if not furnId then return end

    local ref = FB_referencePos
    local ok, err = pcall(function()
        HousingEditorRequestChangePositionAndOrientation(furnId, ref.x, ref.y, ref.z, ref.pitch, ref.yaw, ref.roll)
    end)
    if not ok then
        d("[FurnitureBuilder] align FAILED: " .. tostring(err))
        return
    end
    d("[FurnitureBuilder] aligned full position AND rotation to reference")
end
SLASH_COMMANDS["/fbalignrot"] = CmdAlignRot

-- ---------------------------------------------------------------------------
-- Even spacing along a line: mark two endpoints (A and B), then place a
-- series of items evenly between them.
-- ---------------------------------------------------------------------------

local FB_pointA = nil
local FB_pointB = nil
local FB_spaceIndex = 0

local function ReadTargetTransform()
    local furnId = GetTargetedFurnitureId()
    if not furnId then return nil end
    local okPos, x, y, z = pcall(HousingEditorGetFurnitureWorldPosition, furnId)
    local okRot, pitch, yaw, roll = pcall(HousingEditorGetFurnitureOrientation, furnId)
    if not okPos or not okRot then
        d("[FurnitureBuilder] could not read position/orientation")
        return nil
    end
    return furnId, {x = x, y = y, z = z, pitch = pitch, yaw = yaw, roll = roll}
end

local function CmdMarkA()
    local furnId, t = ReadTargetTransform()
    if not t then return end
    FB_pointA = t
    FB_spaceIndex = 0
    d("[FurnitureBuilder] point A marked: x=" .. tostring(t.x) .. " y=" .. tostring(t.y) .. " z=" .. tostring(t.z))
end
SLASH_COMMANDS["/fbmarka"] = CmdMarkA

local function CmdMarkB()
    local furnId, t = ReadTargetTransform()
    if not t then return end
    FB_pointB = t
    d("[FurnitureBuilder] point B marked: x=" .. tostring(t.x) .. " y=" .. tostring(t.y) .. " z=" .. tostring(t.z))
end
SLASH_COMMANDS["/fbmarkb"] = CmdMarkB

-- /fbspace <count> -- moves the targeted item to the next evenly-spaced
-- slot along the A-B line. Call it once per item, in order; the slot index
-- auto-increments each call and resets whenever /fbmarka is run again.
local function CmdSpace(argString)
    if not FB_pointA or not FB_pointB then
        d("[FurnitureBuilder] need both /fbmarka and /fbmarkb set first")
        return
    end
    local count = tonumber(argString)
    if not count or count < 2 then
        d("[FurnitureBuilder] usage: /fbspace <total item count, e.g. /fbspace 5>")
        return
    end
    if not HousingEditorRequestChangePositionAndOrientation then return end

    local furnId = GetTargetedFurnitureId()
    if not furnId then return end

    local t = FB_spaceIndex / (count - 1) -- 0.0 at A, 1.0 at B
    local a, b = FB_pointA, FB_pointB
    local x = a.x + (b.x - a.x) * t
    local y = a.y + (b.y - a.y) * t
    local z = a.z + (b.z - a.z) * t

    -- CHANGED: use point A's rotation for every item in the row, instead
    -- of each item's own current rotation -- keeps the whole row facing
    -- the same direction consistently.
    local ok, err = pcall(function()
        HousingEditorRequestChangePositionAndOrientation(furnId, x, y, z, a.pitch, a.yaw, a.roll)
    end)
    if not ok then
        d("[FurnitureBuilder] space FAILED: " .. tostring(err))
        return
    end

    d("[FurnitureBuilder] placed at slot " .. tostring(FB_spaceIndex) .. "/" .. tostring(count - 1)
        .. " (position + rotation matched to point A)")
    FB_spaceIndex = FB_spaceIndex + 1
end
SLASH_COMMANDS["/fbspace"] = CmdSpace

-- ---------------------------------------------------------------------------
-- Snap to a round increment (no reference item needed).
-- ---------------------------------------------------------------------------

-- /fbsnap <increment> -- rounds the targeted item's X and Z to the nearest
-- multiple of <increment> meters (e.g. /fbsnap 0.5).
local function CmdSnap(argString)
    local increment = tonumber(argString)
    if not increment or increment <= 0 then
        d("[FurnitureBuilder] usage: /fbsnap <increment in meters, e.g. /fbsnap 0.5>")
        return
    end
    if not HousingEditorRequestChangePositionAndOrientation then return end

    local furnId = GetTargetedFurnitureId()
    if not furnId then return end

    local okPos, x, y, z = pcall(HousingEditorGetFurnitureWorldPosition, furnId)
    local okRot, pitch, yaw, roll = pcall(HousingEditorGetFurnitureOrientation, furnId)
    if not okPos or not okRot then
        d("[FurnitureBuilder] could not read current position/orientation")
        return
    end

    -- Positions are in centimeters (world position units), so convert the
    -- meter increment before rounding.
    local incCm = increment * 100
    local snappedX = zo_round(x / incCm) * incCm
    local snappedZ = zo_round(z / incCm) * incCm

    local ok, err = pcall(function()
        HousingEditorRequestChangePositionAndOrientation(furnId, snappedX, y, snappedZ, pitch, yaw, roll)
    end)
    if not ok then
        d("[FurnitureBuilder] snap FAILED: " .. tostring(err))
        return
    end
    d("[FurnitureBuilder] snapped to nearest " .. tostring(increment) .. "m grid")
end
SLASH_COMMANDS["/fbsnap"] = CmdSnap

-- ---------------------------------------------------------------------------
-- /fbhelp -- large, addon-controlled on-screen command reference. Chat text
-- size is a player setting we can't control, so this uses the same proven
-- top-level-window (no fragment, manual toggle) pattern that made the grid
-- work reliably, just with a text label instead of grid lines.
-- ---------------------------------------------------------------------------

local helpWindow = nil
local helpVisible = false

local FB_HELP_TEXT = table.concat({
    "Furniture Placer Commands",
    "",
    "/fbtarget - inspect the targeted item",
    "/fbmark - mark a reference point",
    "/fbalign - align X/Z to reference",
    "/fbalignfull - align X/Y/Z to reference",
    "/fbalignrot - align position + rotation",
    "",
    "/fbmarka - mark row start",
    "/fbmarkb - mark row end",
    "/fbspace <count> - space evenly along row",
    "",
    "/fbsnap <increment> - snap to grid (meters)",
    "/fbgrid - toggle screen grid overlay",
    "/fbhelp - toggle this panel",
}, "\n")

local function BuildHelpPanel()
    if helpWindow then return end
    local ok, err = pcall(function()
        helpWindow = WINDOW_MANAGER:CreateTopLevelWindow("FurnitureBuilder_Help")
        helpWindow:SetDimensions(700, 560)
        helpWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        helpWindow:SetHidden(true)

        local bg = WINDOW_MANAGER:CreateControl(nil, helpWindow, CT_BACKDROP)
        bg:SetAnchorFill(helpWindow)
        bg:SetCenterColor(0, 0, 0, 0.85)
        bg:SetEdgeColor(1, 1, 1, 0.6)
        bg:SetEdgeTexture("", 2, 2, 2)

        local label = WINDOW_MANAGER:CreateControl(nil, helpWindow, CT_LABEL)
        label:SetFont("ZoFontWinT1")
        label:SetColor(1, 1, 1, 1)
        label:SetAnchor(TOPLEFT, helpWindow, TOPLEFT, 24, 24)
        label:SetDimensions(650, 510)
        label:SetVerticalAlignment(TEXT_ALIGN_TOP)
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetText(FB_HELP_TEXT)
    end)
    if not ok then
        d("[FurnitureBuilder] help panel build FAILED: " .. tostring(err))
        helpWindow = nil
    end
end

local function CmdHelp()
    BuildHelpPanel()
    if not helpWindow then return end
    helpVisible = not helpVisible
    helpWindow:SetHidden(not helpVisible)
    d("[FurnitureBuilder] help panel " .. (helpVisible and "shown" or "hidden"))
end
SLASH_COMMANDS["/fbhelp"] = CmdHelp

-- ---------------------------------------------------------------------------
-- On-screen command reference: a toggleable box in the top-right listing
-- all the commands, so you don't have to remember them. Same proven
-- pattern as the working grid (plain top-level window, no scene fragment,
-- manual SetHidden) -- deliberately NOT using a fragment since that's what
-- caused the "won't turn off" bug on the earlier marker experiment.
-- ---------------------------------------------------------------------------

local helpWindow = nil
local helpVisible = false

local HELP_TEXT = table.concat({
    "|cFFD700Furniture Placer|r",
    "",
    "/fbtarget - inspect targeted item",
    "/fbmark - mark reference point",
    "/fbalign - match X/Z to reference",
    "/fbalignfull - match X/Y/Z",
    "/fbalignrot - match position+rotation",
    "",
    "/fbmarka - mark row start",
    "/fbmarkb - mark row end",
    "/fbspace <count> - space row evenly",
    "",
    "/fbsnap <increment> - snap to grid",
    "/fbgrid - toggle screen grid",
    "/fbhelp - toggle this box",
}, "\n")

local function BuildHelpBox()
    if helpWindow then return end

    local ok, err = pcall(function()
        helpWindow = WINDOW_MANAGER:CreateTopLevelWindow("FurnitureBuilder_Help")
        helpWindow:SetDimensions(480, 460)
        helpWindow:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -20, 20)
        helpWindow:SetHidden(true)

        local bg = WINDOW_MANAGER:CreateControl(nil, helpWindow, CT_BACKDROP)
        bg:SetAnchorFill(helpWindow)
        bg:SetCenterColor(0, 0, 0, 0.8)

        local label = WINDOW_MANAGER:CreateControl(nil, helpWindow, CT_LABEL)
        label:SetFont("ZoFontGameLargeBold")
        label:SetText(HELP_TEXT)
        label:SetColor(1, 1, 1, 1)
        label:SetAnchor(TOPLEFT, helpWindow, TOPLEFT, 16, 16)
        label:SetDimensions(448, 428)
        label:SetVerticalAlignment(TEXT_ALIGN_TOP)
    end)

    if not ok then
        d("[FurnitureBuilder] help box create FAILED: " .. tostring(err))
        helpWindow = nil
    end
end

local function CmdHelp()
    BuildHelpBox()
    if not helpWindow then return end
    helpVisible = not helpVisible
    helpWindow:SetHidden(not helpVisible)
    d("[FurnitureBuilder] command reference " .. (helpVisible and "ON" or "OFF"))
end
SLASH_COMMANDS["/fbhelp"] = CmdHelp

-- ---------------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------------

local function OnAddOnLoaded(_, addonName)
    if addonName ~= FB.name then return end
    EVENT_MANAGER:UnregisterForEvent(FB.name, EVENT_ADD_ON_LOADED)

    -- Keybind display name, shown in Controls settings under the
    -- "Furniture Placer" category (matches bindings.xml's Category name).
    local ok, err = pcall(function()
        ZO_CreateStringId("SI_BINDING_NAME_FURNITUREPLACER_TARGET", "Target Furniture")
    end)
    if not ok then
        d("[FurnitureBuilder] ZO_CreateStringId FAILED: " .. tostring(err))
    end

    d("[FurnitureBuilder] loaded OK -- /fbhelp for command reference box, or /fbtarget /fbmark /fbalign /fbalignfull /fbalignrot /fbmarka /fbmarkb /fbspace /fbsnap")
    CheckHousingEditorAPI()
end

EVENT_MANAGER:RegisterForEvent(FB.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
