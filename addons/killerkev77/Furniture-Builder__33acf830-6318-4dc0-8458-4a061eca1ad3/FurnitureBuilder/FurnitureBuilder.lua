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

if GetDisplayName() ~= "@Atomic Khaos" then return end

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

local function TestWorldMarker()
    if not GetUnitWorldPosition then
        d("[FurnitureBuilder] GetUnitWorldPosition not found")
        return
    end
    if not WorldPositionToGuiRender3DPosition then
        d("[FurnitureBuilder] WorldPositionToGuiRender3DPosition not found")
        return
    end

    local ok, zoneId, wx, wy, wz = pcall(GetUnitWorldPosition, "player")
    if not ok then
        d("[FurnitureBuilder] GetUnitWorldPosition FAILED: " .. tostring(zoneId))
        return
    end
    d("[FurnitureBuilder] player world pos: zone=" .. tostring(zoneId) .. " x=" .. tostring(wx) .. " y=" .. tostring(wy) .. " z=" .. tostring(wz))

    if not markerWindow then
        local ok2, err = pcall(function()
            markerWindow = WINDOW_MANAGER:CreateTopLevelWindow("FurnitureBuilder_Marker")
            markerWindow:SetDimensions(40, 40)
            markerWindow:Create3DRenderSpace()
            local box = WINDOW_MANAGER:CreateControl(nil, markerWindow, CT_BACKDROP)
            box:SetAnchorFill(markerWindow)
            box:SetCenterColor(0, 1, 1, 1)
        end)
        if not ok2 then
            d("[FurnitureBuilder] marker create FAILED: " .. tostring(err))
            markerWindow = nil
            return
        end
    end

    local ok3, rx, ry, rz = pcall(WorldPositionToGuiRender3DPosition, wx, wy, wz)
    if not ok3 then
        d("[FurnitureBuilder] WorldPositionToGuiRender3DPosition FAILED: " .. tostring(rx))
        return
    end
    if not rx then
        d("[FurnitureBuilder] WorldPositionToGuiRender3DPosition returned nil (out of range / wrong zone?)")
        return
    end
    d("[FurnitureBuilder] converted render pos: " .. tostring(rx) .. "," .. tostring(ry) .. "," .. tostring(rz))

    local ok4, err4 = pcall(function()
        markerWindow:Set3DRenderSpaceOrigin(rx, ry, rz)
    end)
    if not ok4 then
        d("[FurnitureBuilder] Set3DRenderSpaceOrigin FAILED: " .. tostring(err4))
        return
    end

    markerWindow:SetHidden(false)
    d("[FurnitureBuilder] marker placed -- look for a small cyan box. Should be exactly where you're standing.")
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
-- Init
-- ---------------------------------------------------------------------------

local function OnAddOnLoaded(_, addonName)
    if addonName ~= FB.name then return end
    EVENT_MANAGER:UnregisterForEvent(FB.name, EVENT_ADD_ON_LOADED)

    d("[FurnitureBuilder] loaded OK -- /fbtest for test box, /fbgrid to toggle the grid")
    CheckHousingEditorAPI()
end

EVENT_MANAGER:RegisterForEvent(FB.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
