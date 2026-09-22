local A = PBS_CLOCK

function A:SetPanelOpen(open)
    self.panelOpen=open and true or false
    if not open then self.previewStyle=nil; self.previewKind=nil end
    self:ApplyLayout()
    self:RefreshVisibility()
end

function A:PreviewClock(style,kind)
    self.previewStyle=style
    self.previewKind=kind
    self.sv.preview=true
    self:ApplyLayout()
    self:RefreshVisibility()
end

function A:WatchSettingsScene()
    local library=LibHarvensAddonSettings
    local scene=library and library.scene
    if not scene and SCENE_MANAGER then
        scene=SCENE_MANAGER:GetScene("LibHarvensAddonSettingsScene")
    end
    -- Desktop versions show the settings panel inside the current settings scene.
    if not scene and SCENE_MANAGER then scene=SCENE_MANAGER:GetCurrentScene() end
    if not scene or scene==HUD_SCENE or scene==HUD_UI_SCENE then return nil end
    self.watchedScenes=self.watchedScenes or {}
    if not self.watchedScenes[scene] then
        self.watchedScenes[scene]=true
        scene:RegisterCallback("StateChange",function(_,state)
            if state==SCENE_SHOWN then
                self:SetPanelOpen(self.panel and self.panel.selected==true)
            elseif state==SCENE_HIDING or state==SCENE_HIDDEN then
                self:SetPanelOpen(false)
            end
        end)
    end
    return scene
end

function A:OnAddonSelected(panel)
    local scene=self:WatchSettingsScene()
    -- Console selection fires before its settings scene is pushed.
    self:SetPanelOpen(panel==self.panel and (not scene or scene:IsShowing()))
end
