NextTryShared = NextTryShared or {}

local MODULE_VERSION = 1

if not NextTryShared.WindowVisibility
or not NextTryShared.WindowVisibility.version
or NextTryShared.WindowVisibility.version < MODULE_VERSION then
    local M = {}
    M.version = MODULE_VERSION

    function M.GetCurrentSceneName()
        if not (SCENE_MANAGER and SCENE_MANAGER.GetCurrentScene) then return nil end
        local scene = SCENE_MANAGER:GetCurrentScene()
        if scene and scene.GetName then return scene:GetName() end
        return nil
    end

    function M.IsHudSceneActive()
        local sceneName = M.GetCurrentSceneName()
        if sceneName then
            return sceneName == "hud" or sceneName == "hudui"
        end
        if SCENE_MANAGER and SCENE_MANAGER.IsShowing then
            return SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui")
        end
        return false
    end

    function M.IsSettingsPreviewActive(addon)
        if not addon or not addon.sv then return false end
        if addon.settingsPreviewActive ~= true then return false end
        if addon.sv.enabled ~= true then return false end

        if addon.sv.showSettingsPreview ~= nil then
            return addon.sv.showSettingsPreview == true
        end
        if addon.sv.showInSettings ~= nil then
            return addon.sv.showInSettings == true
        end
        if addon.sv.settingsPreview ~= nil then
            return addon.sv.settingsPreview == true
        end
        return false
    end

    function M.GetVisibilityDecision(addon)
        if not addon or not addon.sv then return false, "no saved variables" end
        if not addon.sv.enabled then return false, "addon disabled" end
        if addon.sv.visible == false then return false, "window hidden" end

        if M.IsSettingsPreviewActive(addon) then
            return true, "settings preview"
        end

        local sceneName = M.GetCurrentSceneName() or "unknown"
        if not M.IsHudSceneActive() then
            return false, "scene is " .. tostring(sceneName)
        end

        local unlocked = addon.sv.uiUnlocked == true or addon.sv.unlock == true
        if addon.sv.onlyCombat and addon.state and not addon.state.inCombat and not unlocked then
            return false, "only combat enabled and not in combat"
        end

        return true, "visible"
    end

    function M.ShouldShowWindow(addon)
        return select(1, M.GetVisibilityDecision(addon))
    end

    function M.ApplyVisibility(addon)
        if not addon then return end
        local window = addon.window or addon.container
        if not window then return end
        window:SetHidden(not M.ShouldShowWindow(addon))
    end

    function M.ScheduleApplyVisibility(addon, delayMs)
        if not addon or not EVENT_MANAGER or not addon.name then
            M.ApplyVisibility(addon)
            return
        end

        local updateName = addon.name .. "_WindowVisibilityDelayedApply"
        EVENT_MANAGER:UnregisterForUpdate(updateName)
        EVENT_MANAGER:RegisterForUpdate(updateName, delayMs or 200, function()
            EVENT_MANAGER:UnregisterForUpdate(updateName)
            M.ApplyVisibility(addon)
        end)
    end

    function M.RegisterSceneCallbacks(addon)
        if not addon or addon.windowVisibilitySceneCallbacksRegistered then return end
        addon.windowVisibilitySceneCallbacksRegistered = true
        if not (SCENE_MANAGER and SCENE_MANAGER.RegisterCallback) then return end

        SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState, newState)
            if newState == SCENE_SHOWN or newState == SCENE_HIDDEN then
                M.ApplyVisibility(addon)
                M.ScheduleApplyVisibility(addon, 200)
            end
        end)
    end

    function M.RegisterLAMPreviewCallbacks(addon, isOwnPanelFn, setPreviewFn)
        if not addon or addon.windowVisibilityLAMCallbacksRegistered or not CALLBACK_MANAGER then return end
        addon.windowVisibilityLAMCallbacksRegistered = true

        CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
            if type(isOwnPanelFn) == "function" and isOwnPanelFn(panel) then
                setPreviewFn(true)
            end
        end)

        CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
            if type(isOwnPanelFn) == "function" and isOwnPanelFn(panel) then
                setPreviewFn(false)
            end
        end)
    end

    function M.ValidatePosition(position, defaults)
        position = position or defaults or { x = 660, y = 420 }
        defaults = defaults or position
        local guiW = GuiRoot and GuiRoot.GetWidth and GuiRoot:GetWidth() or 1920
        local guiH = GuiRoot and GuiRoot.GetHeight and GuiRoot:GetHeight() or 1080
        if type(position.x) ~= "number" or type(position.y) ~= "number" or position.x < -50 or position.y < -50 or position.x > guiW - 50 or position.y > guiH - 50 then
            position.x = defaults.x or 660
            position.y = defaults.y or 420
        end
        return position
    end

    NextTryShared.WindowVisibility = M
end
