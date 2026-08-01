local Bootstrap = STARSModuleBootstrap
local Project = Bootstrap and Bootstrap.current
if not Project then error("STARSConnect: config.lua must load before HUD.lua") end

Project.HUD = Project.HUD or {}
local HUD = Project.HUD

-- The template does not impose a HUD design. When Config.hud.enabled is true,
-- Project.lua may provide CreateHUD, RefreshHUD and ShutdownHUD methods. This
-- adapter keeps those optional calls out of the reusable controller.
function HUD:Initialize()
    if not (Project.Config.hud and Project.Config.hud.enabled) then return end
    if type(Project.CreateHUD) == "function" then
        Project:CreateHUD()
    end
end

function HUD:OnPlayerActivated()
    if not (Project.Config.hud and Project.Config.hud.enabled) then return end
    if type(Project.RefreshHUD) == "function" then
        Project:RefreshHUD()
    end
end

function HUD:Shutdown()
    if type(Project.ShutdownHUD) == "function" then
        Project:ShutdownHUD()
    end
end

Project.Controller:RegisterModule("HUD", HUD)
