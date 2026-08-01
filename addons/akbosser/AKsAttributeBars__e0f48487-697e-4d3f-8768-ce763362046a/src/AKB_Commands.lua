-- ============================================================================
-- AKsAttributeBars - Commands Module
-- ============================================================================
-- Handles slash commands and user interactions

local AKB = AKsAttributeBars

-- Create commands namespace
AKB.Commands = AKB.Commands or {}

-- Initialize commands
function AKB.Commands.Initialize()
    AKB.Commands.SetupSlashCommands()
end

-- Setup essential user commands
function AKB.Commands.SetupSlashCommands()
    if not SLASH_COMMANDS then
        return
    end
    
    -- Main toggle command
    SLASH_COMMANDS["/akbtoggle"] = function()
        AKB.Commands.ToggleCustomBars()
    end
    
    -- Settings panel command
    SLASH_COMMANDS["/akbsettings"] = function()
        AKB.Commands.OpenSettings()
    end
    
    -- Cleanup command for duplicate bar issues
    SLASH_COMMANDS["/akbcleanup"] = function()
        AKB.Commands.CleanupDuplicateBars()
    end
    
    -- Enemy bar toggle command
    SLASH_COMMANDS["/akbenemy"] = function()
        AKB.Commands.ToggleEnemyBars()
    end
end

-- Clean up any duplicate or orphaned bars
function AKB.Commands.CleanupDuplicateBars()
    AKB.Print("Cleaning up duplicate attribute bars...")
    
    -- Force cleanup of all UI elements
    AKB.UI.ForceCleanupOrphanedElements()
    
    -- Destroy current bars
    AKB.UI.DestroyPlayerAttributeBars()
    
    -- Wait a moment then recreate if enabled
    local settings = AKB.Settings.GetAll()
    if settings.showBars then
        if EVENT_MANAGER then
            EVENT_MANAGER:RegisterForUpdate(AKB.name .. "_CleanupRecreate", 1000, function()
                EVENT_MANAGER:UnregisterForUpdate(AKB.name .. "_CleanupRecreate")
                AKB.UI.CreatePlayerAttributeBars()
                AKB.DefaultBars.SetVisibility(false)
                -- Fix mount stamina visibility after recreating bars
                if AKB.Events and AKB.Events.UpdateMountStaminaVisibility then
                    AKB.Events.UpdateMountStaminaVisibility()
                end
                AKB.Print("Attribute bars recreated successfully")
            end)
        end
    else
        AKB.Print("Cleanup complete - bars are disabled")
    end
end

-- Toggle custom attribute bars on/off
function AKB.Commands.ToggleCustomBars()
    local settings = AKB.Settings.GetAll()
    local newValue = not settings.showBars
    
    AKB.Print("Custom attribute bars " .. (newValue and "enabled" or "disabled"))
    
    AKB.Settings.Save("showBars", newValue)
    
    if newValue then
        AKB.UI.CreatePlayerAttributeBars()
        AKB.Events.RegisterAttributeEvents()
        AKB.DefaultBars.SetVisibility(false)
        -- Fix mount stamina visibility after enabling bars
        if AKB.Events and AKB.Events.UpdateMountStaminaVisibility then
            AKB.Events.UpdateMountStaminaVisibility()
        end
    else
        AKB.UI.DestroyPlayerAttributeBars()
        AKB.DefaultBars.SetVisibility(true)
    end
end

-- Open settings menu
function AKB.Commands.OpenSettings()
    if LibAddonMenu2 then
        LibAddonMenu2:OpenToPanel("AKsAttributeBarsPanel")
    else
        AKB.Print("Settings menu requires LibAddonMenu2")
    end
end

-- Toggle enemy health bars on/off
function AKB.Commands.ToggleEnemyBars()
    local settings = AKB.Settings.GetAll()
    local newValue = not settings.showEnemyBars
    
    AKB.Print("Enemy health bars " .. (newValue and "enabled" or "disabled"))
    
    AKB.Settings.Save("showEnemyBars", newValue)
    
    if newValue and AKB.EnemyBars then
        AKB.EnemyBars.OnTargetChanged() -- Check current target
    elseif AKB.EnemyBars then
        AKB.EnemyBars.HideEnemyBar()
    end
end
