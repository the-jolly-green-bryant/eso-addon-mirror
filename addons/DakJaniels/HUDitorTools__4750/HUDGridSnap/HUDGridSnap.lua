-- -----------------------------------------------------------------------------
-- HUDGridSnap
-- Grid overlay + snap-to-grid for the ZOS HUD Editor (settings in info box).
-- -----------------------------------------------------------------------------

HUDGridSnap = {}
HUDGridSnap.name = "HUDGridSnap"
HUDGridSnap.Defaults =
{
    enabled = false,
    showGrid = false,
    gridSize = 15,
}

local editorShowing = false

function HUDGridSnap.IsEditorShowing()
    return editorShowing
end

local function SnapControlTopLeft(control)
    local sv = HUDGridSnap.SV
    if not sv.enabled then
        return
    end
    local left, top = zo_round(control:GetLeft()), zo_round(control:GetTop())
    left, top = HUDGridSnap.ApplySnap(left, top, sv.gridSize)
    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

local function InstallEditorHooks()
    ZO_PreHook(ZO_HUDEditorElement_Keyboard, "ApplyChanges", function (self)
        if not HUDGridSnap.SV.enabled then
            return false
        end
        SnapControlTopLeft(self.control)
        return false
    end)

    ZO_PreHook(ZO_HUDEditorElement_Keyboard, "SetPositionFromTopLeft", function (self, offsetX, offsetY)
        if not HUDGridSnap.SV.enabled then
            return false
        end
        offsetX, offsetY = HUDGridSnap.ApplySnap(tonumber(offsetX), tonumber(offsetY), HUDGridSnap.SV.gridSize)
        self.control:ClearAnchors()
        self.control:SetAnchor(TOPLEFT, nil, nil, offsetX, offsetY)
        self:ApplyChanges()
        HUD_EDITOR_KEYBOARD.infoBoxXCoordsEditBox:SetText(tostring(offsetX))
        HUD_EDITOR_KEYBOARD.infoBoxYCoordsEditBox:SetText(tostring(offsetY))
        return true
    end)
end

local function OnEditorSceneStateChange(oldState, newState)
    if newState == SCENE_SHOWING or newState == SCENE_SHOWN then
        editorShowing = true
        HUDGridSnap.RefreshGridOverlay()
    elseif newState == SCENE_HIDING or newState == SCENE_HIDDEN then
        editorShowing = false
        HUDGridSnap.HideGridOverlay()
    end
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= HUDGridSnap.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(HUDGridSnap.name, EVENT_ADD_ON_LOADED)

    HUDGridSnap.SV = ZO_SavedVars:NewAccountWide("HUDGridSnapSV", 1, nil, HUDGridSnap.Defaults)

    SCENE_MANAGER:GetScene("hud_editor_keyboard"):RegisterCallback("StateChange", OnEditorSceneStateChange)
    InstallEditorHooks()
    HUDGridSnap.InstallInfoBoxControls()
end

EVENT_MANAGER:RegisterForEvent(HUDGridSnap.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)