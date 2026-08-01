local ADDON_NAME = "Mousoboros"

-- Scenes we treat as "gameplay" -- the custom cursor stays hidden here.
-- Everything else (menus, settings, char select overlays, etc.) shows it.
local EXCLUDED_SCENES = {
    ["hud"] = true,
    ["hudui"] = true,
}

local cursorControl
local tlw
local updateHandle = ADDON_NAME .. "_Update"

local function UpdateCursorPosition()
    local x, y = GetUIMousePosition()
    local halfWidth, halfHeight = cursorControl:GetDimensions()
    halfWidth, halfHeight = halfWidth / 2, halfHeight / 2
    cursorControl:ClearAnchors()
    cursorControl:SetAnchor(TOPLEFT, tlw, TOPLEFT, x - halfWidth , y - halfHeight)
end

local function ShowCursor()
    if not cursorControl:IsHidden() then return end
    cursorControl:SetHidden(false)
    EVENT_MANAGER:RegisterForUpdate(updateHandle, 0, UpdateCursorPosition)
end

local function HideCursor()
    if cursorControl:IsHidden() then return end
    cursorControl:SetHidden(true)
    EVENT_MANAGER:UnregisterForUpdate(updateHandle)
end

local function RefreshForScene(scene)
    local sceneName = scene and scene:GetName()
    if sceneName and not EXCLUDED_SCENES[sceneName] then
        ShowCursor()
    else
        HideCursor()
    end
end

local function OnSceneStateChanged(scene, oldState, newState)
    if newState == SCENE_SHOWN or newState == SCENE_HIDDEN then
        RefreshForScene(SCENE_MANAGER:GetCurrentScene())
    end
end

local function CreateCursorControl()
    tlw = WINDOW_MANAGER:CreateTopLevelWindow(ADDON_NAME .. "TLW")
    tlw:SetDimensions(GuiRoot:GetDimensions())
    tlw:SetDrawLayer(0)
    tlw:SetDrawTier(0)
    tlw:SetDrawLevel(0) 
    cursorControl = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "Cursor", tlw, CT_TEXTURE)
    cursorControl:SetDimensions(128, 128) 
    cursorControl:SetAnchor(TOPLEFT, tlw, TOPLEFT, 0 , 0 )
    cursorControl:SetTexture("/esoui/art/loadscreen/gamepad/load_ouroboros.dds") -- "esoui/art/cursors/cursor_default.dds"
    cursorControl:SetMouseEnabled(false)
    cursorControl:SetHidden(true)

    
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    CreateCursorControl()
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", OnSceneStateChanged)

    -- Cover the case of /reloadui happening while already in a menu.
    RefreshForScene(SCENE_MANAGER:GetCurrentScene())
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
