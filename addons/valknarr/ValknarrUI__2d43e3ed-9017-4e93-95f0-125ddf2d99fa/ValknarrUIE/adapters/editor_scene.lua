ValknarrUIEEditorScene = ValknarrUIEEditorScene or {}

local Scene = ValknarrUIEEditorScene
local Log = ValknarrUIELog
local Platform = ValknarrUIEPlatform
local SCENE_NAME = "ValknarrUIEScene"

local function SceneStateName(state)
    if state == nil then
        return "nil"
    end
    return tostring(state)
end

local function IsHiddenState(state)
    if state == nil then
        return false
    end
    if SCENE_HIDDEN and state == SCENE_HIDDEN then
        return true
    end
    if SCENE_HIDING and state == SCENE_HIDING then
        return true
    end
    return state == "hidden" or state == "hiding"
end

local function CurrentSceneName()
    if not SCENE_MANAGER then
        return nil
    end
    local scene = SCENE_MANAGER.currentScene
    if scene and type(scene.GetName) == "function" then
        local ok, name = pcall(scene.GetName, scene)
        if ok and type(name) == "string" then
            return name
        end
    end
    if type(SCENE_MANAGER.GetCurrentSceneName) == "function" then
        local ok, name = pcall(SCENE_MANAGER.GetCurrentSceneName, SCENE_MANAGER)
        if ok and type(name) == "string" then
            return name
        end
    end
    return nil
end

function Scene:AddFragment(fragment, label)
    if not self.scene or not fragment then
        return false
    end
    if type(self.scene.AddFragment) ~= "function" then
        return false
    end
    local ok, err = pcall(self.scene.AddFragment, self.scene, fragment)
    if Log then
        if ok then
            Log:Debug("Scene fragment added: " .. tostring(label))
        else
            Log:Warn("Scene fragment failed (" .. tostring(label) .. "): " .. tostring(err))
        end
    end
    return ok
end

-- Grid / yellow box live on a GuiRoot top-level window. Do not add that
-- window as a scene fragment: when chat's 20s timer or look pops the
-- scene, ZO_SimpleSceneFragment hides the overlay while stick polling
-- keeps running (zombie editor).
function Scene:DetachEditorRoot(root)
    if self.scene and self.fragment and type(self.scene.RemoveFragment) == "function" then
        pcall(self.scene.RemoveFragment, self.scene, self.fragment)
    end
    self.fragment = nil
    if root and type(root.SetHidden) == "function" then
        pcall(root.SetHidden, root, false)
    end
end

function Scene:AddEditorRootFragment(root)
    self:DetachEditorRoot(root)
    return false
end

function Scene:IsShowing()
    if self.scene and type(self.scene.IsShowing) == "function" then
        local ok, showing = pcall(self.scene.IsShowing, self.scene)
        if ok and showing then
            return true
        end
    end
    if self.scene and type(self.scene.GetState) == "function" then
        local ok, state = pcall(self.scene.GetState, self.scene)
        if ok then
            if SCENE_SHOWN and state == SCENE_SHOWN then
                return true
            end
            if SCENE_SHOWING and state == SCENE_SHOWING then
                return true
            end
        end
    end
    return CurrentSceneName() == SCENE_NAME
end

function Scene:SetKeybindChromeVisible(visible)
    if not self.scene then
        return
    end
    local backdrop = _G.KEYBIND_STRIP_GAMEPAD_BACKDROP_FRAGMENT
    if not backdrop then
        return
    end
    if visible then
        -- Avoid re-AddFragment spam (Recover used to log this every hide cycle).
        if type(backdrop.IsShowing) == "function" then
            local ok, showing = pcall(backdrop.IsShowing, backdrop)
            if ok and showing then
                return
            end
        end
        if self.keybindBackdropAdded then
            return
        end
        if self:AddFragment(backdrop, "KEYBIND_STRIP_GAMEPAD_BACKDROP") then
            self.keybindBackdropAdded = true
        end
        return
    end
    self.keybindBackdropAdded = false
    if type(self.scene.RemoveFragment) == "function" then
        pcall(self.scene.RemoveFragment, self.scene, backdrop)
    end
end

function Scene:Ensure(root)
    if self.scene then
        self:DetachEditorRoot(root)
        return true
    end
    if not SCENE_MANAGER or type(ZO_Scene) ~= "table" or type(ZO_Scene.New) ~= "function" then
        if Log then
            Log:Warn("SCENE_MANAGER/ZO_Scene unavailable — overlay-only editor")
        end
        return false
    end

    local ok, scene = pcall(ZO_Scene.New, ZO_Scene, SCENE_NAME, SCENE_MANAGER)
    if not ok or not scene then
        if Log then
            Log:Warn("ZO_Scene:New failed: " .. tostring(scene))
        end
        return false
    end
    self.scene = scene

    -- Writ Crafter: gamepad keybind strip + shortcuts layer. Do not add
    -- GAMEPAD_DRIVEN_UI_WINDOW — that group commonly blanks the world HUD.
    self:AddFragment(UI_SHORTCUTS_ACTION_LAYER_FRAGMENT, "UI_SHORTCUTS_ACTION_LAYER")
    self:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT, "KEYBIND_STRIP_GAMEPAD")
    self:AddFragment(KEYBIND_STRIP_GAMEPAD_BACKDROP_FRAGMENT, "KEYBIND_STRIP_GAMEPAD_BACKDROP")
    self:AddFragment(PLAYER_ATTRIBUTE_BARS_FRAGMENT, "PLAYER_ATTRIBUTE_BARS")
    self:AddFragment(_G.HUD_FRAGMENT, "HUD_FRAGMENT")
    self:AddFragment(_G.HUD_UI_FRAGMENT, "HUD_UI_FRAGMENT")
    self:AddFragment(_G.ACTION_BAR_FRAGMENT, "ACTION_BAR")
    self:AddFragment(_G.COMPASS_FRAME_FRAGMENT, "COMPASS_FRAME")
    self:AddFragment(_G.FOCUSED_QUEST_TRACKER_FRAGMENT, "FOCUSED_QUEST_TRACKER")
    self:AddFragment(_G.UNIT_FRAMES_FRAGMENT, "UNIT_FRAMES")
    self:AddFragment(_G.PLAYER_PROGRESS_BAR_FRAGMENT, "PLAYER_PROGRESS_BAR")
    self:AddFragment(_G.BUFF_DEBUFF_FRAGMENT, "BUFF_DEBUFF")
    self:AddFragment(_G.HUD_EQUIPMENT_STATUS_FRAGMENT, "HUD_EQUIPMENT_STATUS")
    self:AddFragment(_G.CONTEXTUAL_ACTION_BAR_AREA_FRAGMENT, "CONTEXTUAL_ACTION_BAR")
    -- Do not add GAMEPAD_CHAT_FRAGMENT: chat's 20s minimize can hide that
    -- fragment and take this scene with it. Chat preview pins separately.
    self:AddEditorRootFragment(root)

    if type(scene.RegisterCallback) == "function" then
        pcall(scene.RegisterCallback, scene, "StateChange", function(oldState, newState)
            if Log then
                Log:Debug("Scene " .. SceneStateName(oldState) .. " -> " .. SceneStateName(newState))
            end
            if IsHiddenState(newState) and type(self.onHidden) == "function" then
                self.onHidden()
            end
        end)
    end

    if Log then
        Log:Info("Editor scene registered (" .. SCENE_NAME .. ")")
    end
    return true
end

function Scene:ShowHudFirst()
    if not SCENE_MANAGER or type(SCENE_MANAGER.Show) ~= "function" then
        return
    end
    local current = CurrentSceneName()
    if current == SCENE_NAME or current == "hud" or current == "hudui" then
        return
    end
    -- Writ Crafter slash paths force HUD so the editor is not under a menu.
    local ok, err = pcall(SCENE_MANAGER.Show, SCENE_MANAGER, "hud")
    if Log then
        if ok then
            Log:Debug("Show(hud) before editor scene (was " .. tostring(current) .. ")")
        else
            Log:Warn("Show(hud) failed: " .. tostring(err))
        end
    end
end

function Scene:Show(root, skipHudFirst)
    if not self:Ensure(root) then
        return false
    end
    if not SCENE_MANAGER then
        return false
    end
    self:DetachEditorRoot(root)
    if not skipHudFirst then
        if Platform and Platform.IsConsoleOrGameCore and Platform:IsConsoleOrGameCore() then
            self:ShowHudFirst()
        end
    end
    local pusher = SCENE_MANAGER.Push or SCENE_MANAGER.Show
    if type(pusher) ~= "function" then
        if Log then
            Log:Warn("SCENE_MANAGER has no Push/Show")
        end
        return false
    end
    local ok, err = pcall(pusher, SCENE_MANAGER, SCENE_NAME)
    if Log then
        if ok then
            Log:Info("Editor scene shown")
        else
            Log:Warn("Editor scene show failed: " .. tostring(err))
        end
    end
    return ok
end

function Scene:Hide()
    if not self.scene or not SCENE_MANAGER then
        return
    end
    -- Never HideCurrentScene unless we are the current scene. After a
    -- zombie hide the current scene is hud; popping that would blank HUD.
    if CurrentSceneName() ~= SCENE_NAME then
        return
    end
    self.keybindBackdropAdded = false
    local hider = SCENE_MANAGER.HideCurrentScene or SCENE_MANAGER.Hide
    if type(hider) ~= "function" then
        return
    end
    local ok, err
    if hider == SCENE_MANAGER.HideCurrentScene then
        ok, err = pcall(hider, SCENE_MANAGER)
    else
        ok, err = pcall(hider, SCENE_MANAGER, SCENE_NAME)
    end
    if Log and not ok then
        Log:Warn("Editor scene hide failed: " .. tostring(err))
    end
end

-- After hide, ensure gameplay HUD if we did not already land there.
-- Do not Show(hud) while the editor scene is still current — that fights
-- HideCurrentScene and can shove the action bar / eat left stick.
function Scene:ReturnToGame()
    if not SCENE_MANAGER or type(SCENE_MANAGER.Show) ~= "function" then
        return
    end
    local current = CurrentSceneName()
    if current == "hud" or current == "hudui" then
        return
    end
    if current == SCENE_NAME then
        return
    end
    local ok, err = pcall(SCENE_MANAGER.Show, SCENE_MANAGER, "hud")
    if Log then
        if ok then
            Log:Debug("Returned to hud after editor close")
        else
            Log:Warn("Return to hud failed: " .. tostring(err))
        end
    end
end

return Scene
