local RPR = RewardPopupsReworked

RPR.PopupSuppressor = {
    installedHooks = {},
    installedScenes = {},
}

local Suppressor = RPR.PopupSuppressor

function Suppressor:Initialize()
    self.installedHooks = {}
    self.installedScenes = {}
    RPR:Debug("popup suppressor initialized")
end

local function SourceCanSuppress(source)
    return RPR.savedVars
        and RPR.savedVars.general
        and RPR.savedVars.general.enabled
        and source
        and source.IsReplacementEnabled
        and source:IsReplacementEnabled()
end

local function RefreshLater(reason)
    if RPR.RewardManager and RPR.RewardManager.RefreshLater then
        RPR.RewardManager:RefreshLater(reason)
    end
end

function Suppressor:Install(source)
    if not source or not source.suppressor then return end

    self:InstallFunctionHooks(source)
    self:InstallSceneHooks(source)
end

function Suppressor:InstallFunctionHooks(source)
    if not source.suppressor.hooks or not ZO_PreHook then return end

    for _, hook in ipairs(source.suppressor.hooks) do
        local key = type(hook) == "table"
            and ((hook.object or "") .. "." .. (hook.method or hook.func or ""))
            or tostring(hook)

        if not self.installedHooks[key] then
            if type(hook) == "string" and type(_G[hook]) == "function" then
                ZO_PreHook(hook, function()
                    if SourceCanSuppress(source) then
                        RPR:Debug("function popup suppressed: " .. tostring(source.id))
                        RefreshLater("popup hook")
                        return true
                    end

                    return false
                end)

                self.installedHooks[key] = true

            elseif type(hook) == "table" and hook.object and hook.method then
                local object = RPR.Utils.GetGlobal(hook.object)

                if object and type(object[hook.method]) == "function" then
                    ZO_PreHook(object, hook.method, function()
                        if SourceCanSuppress(source) then
                            RPR:Debug("manager popup suppressed: " .. tostring(source.id))
                            RefreshLater("popup hook")
                            return true
                        end

                        return false
                    end)

                    self.installedHooks[key] = true
                end
            end
        end
    end
end

function Suppressor:InstallSceneHooks(source)
    if not source.suppressor.scenes or not SCENE_MANAGER then return end

    for _, sceneName in ipairs(source.suppressor.scenes) do
        local key = source.id .. ":" .. sceneName

        if not self.installedScenes[key] then
            local scene

            if SCENE_MANAGER.GetScene then
                local ok, result = pcall(SCENE_MANAGER.GetScene, SCENE_MANAGER, sceneName)
                if ok then
                    scene = result
                end
            end

            if scene and scene.RegisterCallback then
                scene:RegisterCallback("StateChange", function(_, newState)
                    if newState == SCENE_SHOWING and SourceCanSuppress(source) then
                        RPR:Debug("scene popup suppressed: " .. tostring(source.id))
                        self:SuppressNow(source)
                        RefreshLater("scene suppressed")
                    end
                end)

                self.installedScenes[key] = true
            end
        end
    end
end

function Suppressor:SuppressNow(source)
    if not SourceCanSuppress(source) or not source.suppressor then return end
    RPR:Debug("suppress now: " .. tostring(source.id))

    if source.suppressor.dialogs then
        for _, dialogName in ipairs(source.suppressor.dialogs) do
            if ZO_Dialogs_ReleaseDialog then
                pcall(ZO_Dialogs_ReleaseDialog, dialogName)
            end
        end
    end

    if source.suppressor.controls then
        for _, controlName in ipairs(source.suppressor.controls) do
            local control = _G[controlName]

            if control and control.SetHidden then
                pcall(control.SetHidden, control, true)
            end
        end
    end

    if source.suppressor.scenes and SCENE_MANAGER then
        for _, sceneName in ipairs(source.suppressor.scenes) do
            local scene

            if SCENE_MANAGER.GetScene then
                local ok, result = pcall(SCENE_MANAGER.GetScene, SCENE_MANAGER, sceneName)
                if ok then
                    scene = result
                end
            end

            if scene and scene.IsShowing and scene:IsShowing() and SCENE_MANAGER.Hide then
                pcall(SCENE_MANAGER.Hide, SCENE_MANAGER, sceneName)
            end
        end
    end
end
