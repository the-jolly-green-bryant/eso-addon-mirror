VestigeMirror = VestigeMirror or {}
VestigeMirror.Scene = {}

local SCENE_NAME = "vestigeMirrorKeyboard"
local OPEN_SOUND_ID = "ZONE_STORIES_TRACK_ACTIVITY"

local function PlayOpenSound()
    if SOUNDS and SOUNDS[OPEN_SOUND_ID] then
        PlaySound(SOUNDS[OPEN_SOUND_ID])
    else
        PlaySound(OPEN_SOUND_ID)
    end
end

function VestigeMirror.Scene:Initialize()
    if self.scene then
        return
    end

    local scene = ZO_Scene:New(SCENE_NAME, SCENE_MANAGER)
    scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
    scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_CENTERED)
    scene:AddFragment(STATS_OUTFIT_PREVIEW_OPTIONS_FRAGMENT)
    scene:AddFragment(ITEM_PREVIEW_KEYBOARD:GetFragment())
    scene:AddFragment(ZO_FadeSceneFragment:New(VestigeMirrorWindow))
    scene:AddFragment(MINIMIZE_CHAT_FRAGMENT)
    scene:AddFragment(CHARACTER_WINDOW_SOUNDS)

    scene:RegisterCallback("StateChange", function(_, newState)
        self:OnSceneStateChanged(newState)
    end)

    self.scene = scene
end

function VestigeMirror.Scene:OnSceneStateChanged(newState)
    if newState == SCENE_SHOWING then
        PlayOpenSound()
        local appearance = self.pendingAppearance or VestigeMirror.Data:BuildAppearance()
        self.pendingAppearance = nil
        self.appearance = appearance
        VestigeMirror.UI:Refresh(appearance)
        VestigeMirror.UI:ShowTextureKeybinds()
    elseif newState == SCENE_SHOWN then
        if self.appearance then
            VestigeMirror.Preview:ShowAppearance(self.appearance)
        end
    elseif newState == SCENE_HIDDEN then
        VestigeMirror.UI:HideTextureKeybinds()
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
