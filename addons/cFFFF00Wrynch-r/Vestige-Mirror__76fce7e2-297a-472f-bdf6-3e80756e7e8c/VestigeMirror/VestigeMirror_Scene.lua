VestigeMirror = VestigeMirror or {}
VestigeMirror.Scene = {}

local SCENE_NAME = "vestigeMirrorKeyboard"

local function AddFragmentGroupIfExists(scene, fragmentGroup)
    if fragmentGroup then
        scene:AddFragmentGroup(fragmentGroup)
    end
end

local function AddFragmentIfExists(scene, fragment)
    if fragment then
        scene:AddFragment(fragment)
    end
end

function VestigeMirror.Scene:Initialize()
    if self.scene then
        return
    end

    local scene = ZO_Scene:New(SCENE_NAME, SCENE_MANAGER)
    if FRAGMENT_GROUP then
        AddFragmentGroupIfExists(scene, FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
        AddFragmentGroupIfExists(scene, FRAGMENT_GROUP.FRAME_TARGET_CENTERED)
    end

    AddFragmentIfExists(scene, STATS_OUTFIT_PREVIEW_OPTIONS_FRAGMENT)

    local itemPreview = VestigeMirror.Preview:GetController()
    if itemPreview and itemPreview.GetFragment then
        AddFragmentIfExists(scene, itemPreview:GetFragment())
    end

    if ZO_FadeSceneFragment and VestigeMirrorWindow then
        AddFragmentIfExists(scene, ZO_FadeSceneFragment:New(VestigeMirrorWindow))
    end

    AddFragmentIfExists(scene, MINIMIZE_CHAT_FRAGMENT)
    AddFragmentIfExists(scene, CHARACTER_WINDOW_SOUNDS)

    scene:RegisterCallback("StateChange", function(_, newState)
        self:OnSceneStateChanged(newState)
    end)

    self.scene = scene
end

function VestigeMirror.Scene:OnSceneStateChanged(newState)
    if newState == SCENE_SHOWING then
        local appearance = self.pendingAppearance or VestigeMirror.Data:BuildAppearance()
        self.pendingAppearance = nil
        self.appearance = appearance
        VestigeMirror.UI:Refresh(appearance)
        VestigeMirror.UI:ShowToggleBar()
    elseif newState == SCENE_SHOWN then
        if self.appearance then
            VestigeMirror.Preview:ShowAppearance(self.appearance)
        end
    elseif newState == SCENE_HIDDEN then
        VestigeMirror.UI:HideToggleBar()
        VestigeMirror.Preview:Hide()
        self.appearance = nil
    end
end

function VestigeMirror.Scene:IsShowing()
    return self.scene and self.scene:IsShowing()
end

function VestigeMirror.Scene:Show()
    SCENE_MANAGER:Show(SCENE_NAME)
end

function VestigeMirror.Scene:ShowAppearance(appearance)
    if self:IsShowing() then
        self.appearance = appearance
        VestigeMirror.UI:Refresh(appearance)
        VestigeMirror.Preview:Hide()
        VestigeMirror.Preview:ShowAppearance(appearance)
        return
    end

    self.pendingAppearance = appearance
    SCENE_MANAGER:Show(SCENE_NAME)
end

function VestigeMirror.Scene:Hide()
    if self:IsShowing() then
        SCENE_MANAGER:ShowBaseScene()
    end
end
