-- ============================================================================
-- AKsAttributeBars - Event Handling Module
-- ============================================================================
-- Handles all event registration and callbacks

local AKB = AKsAttributeBars

-- Create events namespace
AKB.Events = AKB.Events or {}

-- State tracking to prevent flickering
AKB.Events.lastUIState = false -- Start with bars visible

-- Initialize event handling
function AKB.Events.Initialize()
    AKB.Events.RegisterAttributeEvents()
    AKB.Events.RegisterUIStateEvents()
end

-- Register for all power update events
function AKB.Events.RegisterAttributeEvents()
    if not EVENT_MANAGER or not EVENT_POWER_UPDATE then
        return
    end
    
    -- Register for all power updates
    EVENT_MANAGER:RegisterForEvent(AKB.name .. "_PowerUpdate", EVENT_POWER_UPDATE, function(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
        if unitTag == "player" then
            AKB.Events.HandlePowerUpdate(powerType, powerValue, powerMax)
        end
    end)

    -- Register for mount state changes
    if EVENT_MOUNTED_STATE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(AKB.name .. "_MountState", EVENT_MOUNTED_STATE_CHANGED, function(eventCode, mounted)
            local bars = AKB.UI.GetPlayerBars()
            if bars and bars.mountStamina then
                if mounted then
                    if bars.mountStamina.Show then
                        bars.mountStamina:Show()
                    end
                else
                    if bars.mountStamina.Hide then
                        bars.mountStamina:Hide()
                    end
                end
            end
        end)
    end
    
    -- Register for gamepad mode changes
    if EVENT_GAMEPAD_PREFERRED_MODE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(AKB.name .. "_GamepadMode", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function(eventCode, gamepadPreferred)
            AKB.Events.HandleGamepadModeChange(gamepadPreferred)
        end)
    end
    
    -- Register for player activated (for initialization)
    EVENT_MANAGER:RegisterForEvent(AKB.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
        AKB.Events.HandlePlayerActivated()
    end)
    
    -- Register for combat state changes (for auto-hide feature)
    if EVENT_PLAYER_COMBAT_STATE then
        EVENT_MANAGER:RegisterForEvent(AKB.name .. "_CombatState", EVENT_PLAYER_COMBAT_STATE, function(eventCode, inCombat)
            AKB.Events.HandleCombatStateChange(inCombat)
        end)
    end
    
    -- Register for player resurrect events (for PvP revive fixes)
    if EVENT_RESURRECT_RESULT then
        EVENT_MANAGER:RegisterForEvent(AKB.name .. "_ResurrectResult", EVENT_RESURRECT_RESULT, function(eventCode, result)
            if result == RESURRECT_RESULT_SUCCESS then
                AKB.Events.HandlePlayerRevive()
            end
        end)
    end
    
    -- Register for player alive event (alternative revive detection)
    if EVENT_PLAYER_ALIVE then
        EVENT_MANAGER:RegisterForEvent(AKB.name .. "_PlayerAlive", EVENT_PLAYER_ALIVE, function(eventCode)
            AKB.Events.HandlePlayerRevive()
        end)
    end
    
    -- Register for equipment changes (affects stats)
    if EVENT_INVENTORY_SINGLE_SLOT_UPDATE then
        EVENT_MANAGER:RegisterForEvent(AKB.name .. "_InventoryUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
            -- Only update for equipped items
            if bagId == BAG_WORN then
                -- Check if this is a weapon slot change (main hand, off hand, backup main, backup off)
                -- ESO weapon slots: EQUIP_SLOT_MAIN_HAND (16), EQUIP_SLOT_OFF_HAND (17), 
                -- EQUIP_SLOT_BACKUP_MAIN (20), EQUIP_SLOT_BACKUP_OFF (21)
                if slotId == 16 or slotId == 17 or slotId == 20 or slotId == 21 then
                    -- Weapon change detected - priority update with no throttling
                    AKB.Events.HandleWeaponSwap()
                else
                    -- Other equipment change - normal stat update
                    AKB.Events.HandleStatChange()
                end
            end
        end)
    end
    
    -- Register for effect changes (buffs/debuffs affect stats)
    if EVENT_EFFECT_CHANGED then
        EVENT_MANAGER:RegisterForEvent(AKB.name .. "_EffectChanged", EVENT_EFFECT_CHANGED, function(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, castByPlayer)
            if unitTag == "player" then
                AKB.Events.HandleStatChange()
            end
        end)
    end
    
    -- Register for additional stat-affecting events
    if EVENT_STATS_CHANGED then
        EVENT_MANAGER:RegisterForEvent(AKB.name .. "_StatsChanged", EVENT_STATS_CHANGED, function(eventCode)
            AKB.Events.HandleStatChange()
        end)
    end
    
    -- Register for level changes (affects stats)
    if EVENT_LEVEL_UPDATE then
        EVENT_MANAGER:RegisterForEvent(AKB.name .. "_LevelUpdate", EVENT_LEVEL_UPDATE, function(eventCode, unitTag, level)
            if unitTag == "player" then
                AKB.Events.HandleStatChange()
            end
        end)
    end
    
    -- Register for champion point changes
    if EVENT_CHAMPION_POINT_UPDATE then
        EVENT_MANAGER:RegisterForEvent(AKB.name .. "_ChampionUpdate", EVENT_CHAMPION_POINT_UPDATE, function(eventCode)
            AKB.Events.HandleStatChange()
        end)
    end
    
    -- Register for skill point changes (affects passives)
    if EVENT_SKILLS_FULL_UPDATE or EVENT_SKILL_POINTS_CHANGED then
        if EVENT_SKILLS_FULL_UPDATE then
            EVENT_MANAGER:RegisterForEvent(AKB.name .. "_SkillsUpdate", EVENT_SKILLS_FULL_UPDATE, function(eventCode)
                AKB.Events.HandleStatChange()
            end)
        end
        if EVENT_SKILL_POINTS_CHANGED then
            EVENT_MANAGER:RegisterForEvent(AKB.name .. "_SkillPointsChanged", EVENT_SKILL_POINTS_CHANGED, function(eventCode)
                AKB.Events.HandleStatChange()
            end)
        end
    end
    
    -- Register for weapon swap events (critical for stat changes)
    if EVENT_WEAPON_PAIR_LOCK_CHANGED then
        EVENT_MANAGER:RegisterForEvent(AKB.name .. "_WeaponSwap", EVENT_WEAPON_PAIR_LOCK_CHANGED, function(eventCode, unitTag)
            if unitTag == "player" then
                -- Weapon swapped - stats will definitely change due to different weapons/sets/enchants
                AKB.Events.HandleStatChange()
            end
        end)
    end
    
    -- Alternative weapon swap detection via active hotbar change
    if EVENT_ACTION_BAR_LOCKED_REASON_CHANGED then
        EVENT_MANAGER:RegisterForEvent(AKB.name .. "_HotbarChange", EVENT_ACTION_BAR_LOCKED_REASON_CHANGED, function(eventCode)
            -- Hotbar changed - could be weapon swap
            AKB.Events.HandleStatChange()
        end)
    end
    
    -- Register for ability slot changes (can affect stats via slotted abilities)
    if EVENT_ACTION_SLOT_UPDATED then
        EVENT_MANAGER:RegisterForEvent(AKB.name .. "_AbilitySlotChanged", EVENT_ACTION_SLOT_UPDATED, function(eventCode, slotNum)
            -- Ability slotted/unslotted - some abilities affect stats passively
            AKB.Events.HandleStatChange()
        end)
    end
    
    -- Add periodic weapon set tracking as backup for missed swap events
    AKB.Events.InitializeWeaponTracking()

    -- Attribute visual events (regen/degen indicators) - exact BanditsUI/archive approach
    if EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED and EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED then
        EVENT_MANAGER:RegisterForEvent(AKB.name .. "_AttrVisualAdded", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, function(_, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
            if unitTag ~= "player" or powerType ~= AKB.Utils.POWER_TYPES.HEALTH then return end
            local bars = AKB.UI.GetPlayerBars()
            if not bars or not bars.health then return end
            
            if unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER then
                -- Always count every stack add, regardless of sequenceId or animation state
                bars.health._regenStackCount = (bars.health._regenStackCount or 0) + 1
                -- Only start/restart animation for new effects (sequenceId==0) or when not already running
                local shouldAnimate = (sequenceId == 0) or not bars.health._regenAnimActive
                if shouldAnimate and bars.health.TriggerRegenArrow then
                    bars.health:TriggerRegenArrow(1800)
                end
            elseif unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER then
                -- Always count every stack add, regardless of sequenceId or animation state
                bars.health._degenStackCount = (bars.health._degenStackCount or 0) + 1
                -- Only start/restart animation for new effects (sequenceId==0) or when not already running
                local shouldAnimate = (sequenceId == 0) or not bars.health._degenAnimActive
                if shouldAnimate and bars.health.TriggerDegenArrow then
                    bars.health:TriggerDegenArrow(1800)
                end
            end
        end)

        EVENT_MANAGER:RegisterForEvent(AKB.name .. "_AttrVisualRemoved", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, function(_, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
            if unitTag ~= "player" or powerType ~= AKB.Utils.POWER_TYPES.HEALTH then return end
            local bars = AKB.UI.GetPlayerBars()
            if not bars or not bars.health then return end
            
            -- Hide arrows when effects are removed
            if unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER then
                if bars.health.HideRegenArrow then bars.health:HideRegenArrow() end
            elseif unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER then
                if bars.health.HideDegenArrow then bars.health:HideDegenArrow() end
            end
        end)
    end
    
    -- Start periodic stat polling for stats that may not have reliable events
    AKB.Events.StartStatPolling()
end

-- Start periodic stat update polling (for stats without reliable events)
function AKB.Events.StartStatPolling()
    if not EVENT_MANAGER then
        return
    end
    
    -- Poll stats every 2 seconds for comprehensive updates
    EVENT_MANAGER:RegisterForUpdate(AKB.name .. "_StatPolling", 2000, function()
        -- Only poll if stat windows are active
        if AKB.UI and AKB.UI.StatWindows and AKB.UI.StatWindows.GetActiveWindows then
            local activeWindows = AKB.UI.StatWindows.GetActiveWindows()
            local hasActiveWindows = false
            for _ in pairs(activeWindows) do
                hasActiveWindows = true
                break
            end
            
            if hasActiveWindows then
                AKB.Events.HandleStatChange()
            end
        end
    end)
end

-- Stop stat polling
function AKB.Events.StopStatPolling()
    if EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForUpdate(AKB.name .. "_StatPolling")
    end
end

-- Handle power updates for individual attributes
function AKB.Events.HandlePowerUpdate(powerType, powerValue, powerMax)
    local bars = AKB.UI.GetPlayerBars()

    if powerType == AKB.Utils.POWER_TYPES.HEALTH and bars.health then
        bars.health:Update(powerValue, powerMax)
    elseif powerType == AKB.Utils.POWER_TYPES.MAGICKA and bars.magicka then
        bars.magicka:Update(powerValue, powerMax)
    elseif powerType == AKB.Utils.POWER_TYPES.STAMINA and bars.stamina then
        bars.stamina:Update(powerValue, powerMax)
    elseif powerType == AKB.Utils.POWER_TYPES.MOUNT_STAMINA and bars.mountStamina then
        bars.mountStamina:Update(powerValue, powerMax)
    end
    
    -- Update visibility after any power change (for auto-hide feature)
    AKB.UI.UpdateBarVisibility()
    
    -- Update stat windows when any power changes (stats may be affected) - using smart throttling
    if AKB.UI and AKB.UI.StatWindows and AKB.UI.StatWindows.RequestUpdate then
        AKB.UI.StatWindows.RequestUpdate()
    end
end

-- Handle combat state changes (for auto-hide feature)
function AKB.Events.HandleCombatStateChange(inCombat)
    -- Update visibility when combat state changes
    AKB.UI.UpdateBarVisibility()
    
    -- Update stat windows when entering/leaving combat (buffs may change) - using smart throttling
    if AKB.UI and AKB.UI.StatWindows and AKB.UI.StatWindows.RequestUpdate then
        AKB.UI.StatWindows.RequestUpdate()
    end
end

-- Handle stat changes (equipment, buffs, etc.)
function AKB.Events.HandleStatChange()
    -- Update stat windows when player stats change - using smart throttling
    if AKB.UI and AKB.UI.StatWindows and AKB.UI.StatWindows.RequestUpdate then
        -- Optional debug output (can be removed in production)
        if AKB.Settings and AKB.Settings.Get and AKB.Settings.Get("debugStatUpdates") then
            AKB.Print("Updating stat windows")
        end
        AKB.UI.StatWindows.RequestUpdate()
    end
end

-- Handle weapon swap changes (priority update - no throttling)
function AKB.Events.HandleWeaponSwap()
    -- Weapon swapping causes immediate and significant stat changes
    -- Skip throttling for weapon swaps to ensure immediate updates
    if AKB.UI and AKB.UI.StatWindows and AKB.UI.StatWindows.UpdateAllWindows then
        -- Optional debug output (can be removed in production)
        if AKB.Settings and AKB.Settings.Get and AKB.Settings.Get("debugStatUpdates") then
            AKB.Print("Weapon swap detected - updating stat windows immediately")
        end
        
        -- Force immediate update by temporarily bypassing throttling
        if AKB.UI.StatWindows.ForceUpdateAllWindows then
            AKB.UI.StatWindows.ForceUpdateAllWindows()
        else
            AKB.UI.StatWindows.UpdateAllWindows()
        end
    end
end

-- Handle player revive events (for PvP bar update fixes)
function AKB.Events.HandlePlayerRevive()
    -- Force immediate update of all bars after revival
    -- This fixes the issue where bars show 0% until damage/resource use in PvP
    if AKB.UI.UpdateAllBars then
        AKB.UI.UpdateAllBars()
    end
    
    -- Also update visibility in case auto-hide settings need to be applied
    if AKB.UI.UpdateBarVisibility then
        AKB.UI.UpdateBarVisibility()
    end
end

-- Handle gamepad mode changes
function AKB.Events.HandleGamepadModeChange(gamepadPreferred)
    -- Recreate bars if they exist to adjust for gamepad mode
    local settings = AKB.Settings.GetAll()
    if settings.showBars then
        AKB.UI.CreatePlayerAttributeBars()
        -- Fix mount stamina visibility after recreating bars for gamepad mode
        AKB.Events.UpdateMountStaminaVisibility()
    end
    
    -- Recreate stat windows for gamepad mode
    if AKB.UI and AKB.UI.StatWindows then
        if AKB.UI.StatWindows.DestroyAllWindows then
            AKB.UI.StatWindows.DestroyAllWindows()
        end
        if AKB.UI.StatWindows.CreateAllWindows then
            AKB.UI.StatWindows.CreateAllWindows()
        end
    end
    
    -- Apply chat customization for gamepad mode
    if settings.enableChatBoxCustomization then
        if EVENT_MANAGER then
            EVENT_MANAGER:RegisterForUpdate(AKB.name .. "_ChatReCustomize", 500, function()
                EVENT_MANAGER:UnregisterForUpdate(AKB.name .. "_ChatReCustomize")
                AKB.Chat.ApplyChatBoxCustomization()
            end)
        end
    end
end

-- Handle player activation (game fully loaded)
function AKB.Events.HandlePlayerActivated()
    local settings = AKB.Settings.GetAll()
    
    -- Only create bars if they don't already exist and are enabled
    if settings.showBars then
        -- Check if bars already exist to prevent duplicates
        local existingBars = AKB.UI.GetPlayerBars()
        if not existingBars or not existingBars.health then
            -- Add a delay to ensure the UI is fully loaded after zone change
            if EVENT_MANAGER then
                EVENT_MANAGER:RegisterForUpdate(AKB.name .. "_DelayedBarCreation", 1000, function()
                    EVENT_MANAGER:UnregisterForUpdate(AKB.name .. "_DelayedBarCreation")
                    -- Double-check that bars still don't exist before creating
                    local bars = AKB.UI.GetPlayerBars()
                    if not bars or not bars.health then
                        AKB.UI.CreatePlayerAttributeBars()
                        AKB.DefaultBars.SetVisibility(false)
                    end
                    -- Fix mount stamina visibility after load screens
                    AKB.Events.UpdateMountStaminaVisibility()
                end)
            else
                AKB.UI.CreatePlayerAttributeBars()
                AKB.DefaultBars.SetVisibility(false)
                -- Fix mount stamina visibility after load screens
                AKB.Events.UpdateMountStaminaVisibility()
            end
        else
            -- Bars already exist, just fix mount stamina visibility after load screens
            AKB.Events.UpdateMountStaminaVisibility()
        end
    end
    
    -- Apply default bar positioning
    AKB.DefaultBars.ApplyPositioning()
    
    -- Apply chat customization
    if settings.enableChatBoxCustomization then
        if EVENT_MANAGER then
            EVENT_MANAGER:RegisterForUpdate(AKB.name .. "_ChatCustomize", 1000, function()
                EVENT_MANAGER:UnregisterForUpdate(AKB.name .. "_ChatCustomize")
                AKB.Chat.ApplyChatBoxCustomization()
            end)
        end
    end
end

-- Update mount stamina bar visibility based on current mount state
-- This fixes the issue where mount stamina shows incorrectly after load screens
function AKB.Events.UpdateMountStaminaVisibility()
    -- Add a small delay to ensure game state is fully loaded
    if EVENT_MANAGER then
        EVENT_MANAGER:RegisterForUpdate(AKB.name .. "_MountVisibilityCheck", 250, function()
            EVENT_MANAGER:UnregisterForUpdate(AKB.name .. "_MountVisibilityCheck")
            
            local bars = AKB.UI.GetPlayerBars()
            if not bars or not bars.mountStamina or not bars.mountStamina.window then
                return
            end
            
            -- Check current mount state and set visibility accordingly
            local isMounted = false
            if IsMounted then
                isMounted = IsMounted()
            end
            
            -- Hide/show mount stamina bar based on current mount state
            if isMounted then
                if bars.mountStamina.Show then
                    bars.mountStamina:Show()
                end
            else
                if bars.mountStamina.Hide then
                    bars.mountStamina:Hide()
                end
            end
        end)
        
        -- Also do an immediate check without delay for faster response
        local bars = AKB.UI.GetPlayerBars()
        if bars and bars.mountStamina then
            local isMounted = false
            if IsMounted then
                isMounted = IsMounted()
            end
            if isMounted then
                if bars.mountStamina.Show then
                    bars.mountStamina:Show()
                end
            else
                if bars.mountStamina.Hide then
                    bars.mountStamina:Hide()
                end
            end
        end
    else
        -- Fallback without delay if EVENT_MANAGER is not available
        local bars = AKB.UI.GetPlayerBars()
        if not bars or not bars.mountStamina then
            return
        end
        
        local isMounted = false
        if IsMounted then
            isMounted = IsMounted()
        end
        
        if isMounted then
            if bars.mountStamina.Show then
                bars.mountStamina:Show()
            end
        else
            if bars.mountStamina.Hide then
                bars.mountStamina:Hide()
            end
        end
    end
end

-- Unregister all events (for cleanup)
function AKB.Events.UnregisterAll()
    if EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForEvent(AKB.name .. "_PowerUpdate", EVENT_POWER_UPDATE)
        EVENT_MANAGER:UnregisterForEvent(AKB.name .. "_GamepadMode", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(AKB.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED)
        
        -- Unregister UI state checking
        EVENT_MANAGER:UnregisterForUpdate(AKB.name .. "_UIStateCheck")
    end
end

-- Register for UI state changes (map, menus, overlays)
function AKB.Events.RegisterUIStateEvents()
    if not EVENT_MANAGER then
        return
    end
    
    -- Register for immediate scene change detection
    if SCENE_MANAGER and SCENE_MANAGER.RegisterCallback then
        -- Register for scene state changes for immediate response
        SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState, newState)
            -- When any scene becomes showing or hiding, check UI state immediately
            if newState == SCENE_SHOWN or newState == SCENE_HIDING or newState == SCENE_HIDDEN then
                -- Small delay to ensure scene transition is complete
                zo_callLater(function()
                    AKB.Events.CheckUIState()
                    -- Also update stat windows directly for immediate response
                    if AKB.UI and AKB.UI.StatWindows and AKB.UI.StatWindows.UpdateVisibility then
                        AKB.UI.StatWindows.UpdateVisibility()
                    end
                end, 10)
            end
        end)
    end
    
    -- Polling as backup - reduced from 100ms to 50ms for faster response
    EVENT_MANAGER:RegisterForUpdate(AKB.name .. "_UIStateCheck", 50, function()
        AKB.Events.CheckUIState()
    end)
    
    -- Initial state check after a short delay to ensure bars are visible
    EVENT_MANAGER:RegisterForUpdate(AKB.name .. "_InitialStateCheck", 500, function()
        EVENT_MANAGER:UnregisterForUpdate(AKB.name .. "_InitialStateCheck")
        AKB.Events.CheckUIState()
    end)
end

-- Check current UI state and hide/show bars accordingly
function AKB.Events.CheckUIState()
    local shouldHideBars = false
    
    -- Check if any major UI is open that should hide the bars
    local success, menuOpen = pcall(function()
        if IsInGamepadPreferredMode and IsInGamepadPreferredMode() then
            -- Console-specific checks
            return AKB.Events.IsAnyMenuOpen()
        else
            -- PC-specific checks
            return AKB.Events.IsAnyMenuOpen()
        end
    end)
    
    if success then
        shouldHideBars = menuOpen
    else
        -- If checking fails, assume no menus are open (safe default)
        shouldHideBars = false
    end
    
    -- Only update if state has changed (reduces unnecessary updates)
    if AKB.Events.lastUIState ~= shouldHideBars then
        AKB.Events.lastUIState = shouldHideBars
        AKB.Events.SetBarsVisibilityForUIState(not shouldHideBars)
    end
end

-- Check if any menu/overlay is currently open
-- NOTE: Chat input is NOT considered a menu - bars should stay visible while typing
function AKB.Events.IsAnyMenuOpen()
    -- Check scene manager early to see what's happening
    if SCENE_MANAGER and SCENE_MANAGER.GetCurrentSceneName then
        local scene = SCENE_MANAGER:GetCurrentSceneName()
        if scene then
            -- Check for gamepad chat menu specifically (Xbox controller Start + X)
            if scene == "gamepadChatMenu" then
                return true
            end
        end
    end
    
    -- Check if world map is open first (PC and console)
    if ZO_WorldMap_IsWorldMapShowing then
        if ZO_WorldMap_IsWorldMapShowing() then 
            return true 
        end
    end
    
    -- Additional console-specific world map check
    if IsInGamepadPreferredMode and IsInGamepadPreferredMode() then
        -- Check for gamepad world map state
        if WORLD_MAP_MANAGER and WORLD_MAP_MANAGER.IsShowing and WORLD_MAP_MANAGER:IsShowing() then
            return true
        end
    end
    
    -- COMPREHENSIVE CHAT DETECTION - try multiple methods
    local chatFocused = false
    local chatWindowOpen = false
    
    -- Method 1: Check CHAT_SYSTEM text entry focus
    if CHAT_SYSTEM and CHAT_SYSTEM.textEntry then
        if CHAT_SYSTEM.textEntry.HasFocus and CHAT_SYSTEM.textEntry:HasFocus() then
            chatFocused = true
        end
    end
    
    -- Method 2: Check for full chat window/panel being open
    if CHAT_SYSTEM then
        -- Check if chat window is maximized or expanded
        if CHAT_SYSTEM.primaryContainer then
            local container = CHAT_SYSTEM.primaryContainer
            if container.IsHidden and not container:IsHidden() then
                -- Check if container is larger than normal (indicating full window)
                if container.GetWidth and container.GetHeight then
                    local width = container:GetWidth()
                    local height = container:GetHeight()
                    if width > 800 or height > 400 then
                        chatWindowOpen = true
                    end
                end
            end
            
            -- Alternative check: see if chat is in fullscreen/maximized mode
            if CHAT_SYSTEM.container then
                local container = CHAT_SYSTEM.container
                if container.IsHidden and not container:IsHidden() then
                    if container.GetWidth and container.GetHeight then
                        local width = container:GetWidth()
                        local height = container:GetHeight()
                        if width > 800 or height > 400 then
                            chatWindowOpen = true
                        end
                    end
                end
            end
        end
        
        -- Gamepad-specific check: Check if chat system is in fullscreen/maximized state
        if CHAT_SYSTEM.IsMaximized and CHAT_SYSTEM:IsMaximized() then
            chatWindowOpen = true
        end
        
        -- Additional gamepad check: Check if chat is in full window mode
        if CHAT_SYSTEM.IsInFullScreenMode and CHAT_SYSTEM:IsInFullScreenMode() then
            chatWindowOpen = true
        end
        
        -- Check for gamepad chat window by looking for specific gamepad chat controls
        if ZO_GamepadChatSystem then
            local gamepadChat = ZO_GamepadChatSystem
            if gamepadChat.IsShowing and gamepadChat:IsShowing() then
                chatWindowOpen = true
            end
        end
        
        -- Check for main chat container being in fullscreen state
        if CHAT_SYSTEM.control then
            local control = CHAT_SYSTEM.control
            if control.IsHidden and not control:IsHidden() then
                if control.GetWidth and control.GetHeight then
                    local width = control:GetWidth()
                    local height = control:GetHeight()
                    -- Lower threshold for gamepad detection
                    if width > 600 or height > 300 then
                        chatWindowOpen = true
                    end
                end
            end
        end
    end
    
    -- Method 3: Check window manager focus control
    if not chatFocused and not chatWindowOpen and WINDOW_MANAGER and WINDOW_MANAGER.GetFocusControl then
        local focusControl = WINDOW_MANAGER:GetFocusControl()
        if focusControl and focusControl.GetType then
            local controlType = focusControl:GetType()
            if controlType == CT_EDITBOX then
                -- Additional check: is it the chat editbox?
                if focusControl.GetText then  -- EditBox controls have GetText
                    chatFocused = true
                end
            end
        end
    end
    
    -- Method 4: Check for chat-related scenes
    if not chatFocused and SCENE_MANAGER and SCENE_MANAGER.GetCurrentSceneName then
        local scene = SCENE_MANAGER:GetCurrentSceneName()
        if scene and type(scene) == "string" then
            local lowerScene = scene:lower()
            if lowerScene:find("chat") or lowerScene:find("text") or lowerScene:find("input") then
                chatFocused = true
            end
        end
    end
    
    -- PRIORITY: If any chat detection method succeeded, determine visibility
    if chatFocused then
        return false  -- Chat input is active, keep bars visible
    end
    
    if chatWindowOpen then
        return true   -- Full chat window is open, hide bars
    end
    
    -- Check if reticle is hidden (menus open) - but only if chat doesn't have focus
    if IsReticleHidden then
        if IsReticleHidden() then 
            -- Additional check: if reticle is hidden AND we're in gamepad mode, 
            -- this could be the gamepad chat menu that we didn't catch above
            if IsInGamepadPreferredMode and IsInGamepadPreferredMode() then
                -- In gamepad mode with reticle hidden - likely a menu including chat
                return true
            else
                -- PC mode with reticle hidden - standard menu detection
                return true
            end
        end
    end
    
    -- Check scene manager for specific scenes
    if SCENE_MANAGER and SCENE_MANAGER.GetCurrentSceneName then
        local scene = SCENE_MANAGER:GetCurrentSceneName()
        if scene then
            -- Check for common menu scenes
            local menuScenes = {
                "inventory", "map", "mainMenu", "gameMenu", "skills", 
                "collections", "journal", "mail", "store", "bank", 
                "guild", "group", "champion", "crown", "market", "settings",
                -- Additional UI scenes that should hide stat windows
                "crownStore", "crownCrates", "antiquities", "endeavors",
                "dailyLoginRewards", "giftInventory", "help", "tutorial",
                "character", "stats", "outfitter", "dyeStamp",
                "fence", "launder", "repair", "vendor", "tradinghouse",
                "siegeBar", "battlegroundScoreboard", "groupBrowser"
            }
            
            for _, menuScene in ipairs(menuScenes) do
                if scene:find(menuScene) then
                    return true
                end
            end
            
            -- Check for specific world map scenes (both PC and gamepad)
            if scene == "worldMap" or scene == "gamepad_worldMap" then
                return true
            end
            
            -- Additional gamepad-specific scene checks (enhanced for console stat windows)
            local gamepadScenes = {
                "gamepad_inventory", "gamepadInventory",
                "gamepad_skills", "gamepadSkills", 
                "gamepad_character", "gamepadCharacter",
                "gamepad_collections", "gamepadCollections",
                "gamepad_journal", "gamepadJournal",
                "gamepad_mail", "gamepadMail",
                "gamepad_store", "gamepadStore",
                "gamepad_bank", "gamepadBank",
                "gamepad_guild", "gamepadGuild",
                "gamepad_group", "gamepadGroup",
                "gamepad_champion", "gamepadChampion",
                "gamepad_crownStore", "gamepadCrownStore",
                "gamepad_settings", "gamepadSettings",
                "gamepadMainMenu", "gamepad_mainMenu",
                -- Additional console-specific scenes that should hide stat windows
                "gamepad_antiquities", "gamepadAntiquities",
                "gamepad_endeavors", "gamepadEndeavors", 
                "gamepad_stats", "gamepadStats",
                "gamepad_achievements", "gamepadAchievements",
                "gamepad_lore_library", "gamepadLoreLibrary"
            }
            
            for _, gamepadScene in ipairs(gamepadScenes) do
                if scene == gamepadScene then
                    return true
                end
            end
            
            -- Check for any fullscreen chat scene
            if scene:find("chatFullScreen") or scene:find("chat_fullscreen") then
                return true
            end
            
            -- Check for any scene containing "chat"
            if scene:find("chat") then
                return true
            end
        end
    end
    
    return false
end

-- Set bar visibility based on UI state
function AKB.Events.SetBarsVisibilityForUIState(visible)
    local settings = AKB.Settings.GetAll()
    if not settings.showBars then
        return -- Don't show bars if user has them disabled
    end
    
    local bars = AKB.UI.GetPlayerBars()
    if not bars then
        return
    end

    
    if visible then
        -- When UI state says bars should be visible, use the same system as normal showing
        -- But still respect auto-hide settings
        if AKB.UI and AKB.UI.Manager and AKB.UI.Manager.UpdateBarVisibility then
            -- This handles auto-hide logic and calls ShowAllBars() when appropriate
            AKB.UI.Manager.UpdateBarVisibility()
        else
            -- Fallback to direct showing if UpdateBarVisibility not available
            if AKB.UI and AKB.UI.Manager and AKB.UI.Manager.ShowAllBars then
                AKB.UI.Manager.ShowAllBars()
            end
        end
        
        -- Ensure stat windows follow their own visibility logic (independent of main bars)
        if AKB.UI and AKB.UI.StatWindows and AKB.UI.StatWindows.UpdateVisibility then
            AKB.UI.StatWindows.UpdateVisibility()
        end
    else
        -- When UI state says bars should be hidden (menus open), use the same system as normal hiding
        -- This ensures stat windows and all other components are handled consistently        
        if AKB.UI and AKB.UI.Manager and AKB.UI.Manager.HideAllBars then
            AKB.UI.Manager.HideAllBars()
        else
            -- Fallback to individual hiding if HideAllBars not available
            local components = {bars.health, bars.magicka, bars.stamina, bars.nameLabel}
            
            for _, component in ipairs(components) do
                if component and component.Hide then
                    component:Hide()
                end
            end
            
            -- Handle mount stamina bar separately - always hide when UI state requires hiding
            if bars.mountStamina and bars.mountStamina.Hide then
                bars.mountStamina:Hide()
            end
            
            -- Handle food indicator - hide when UI state requires hiding
            if AKB.FoodIndicator and AKB.FoodIndicator.UpdateVisibility then
                AKB.FoodIndicator.UpdateVisibility()
            end
            
            -- Ensure stat windows follow their own visibility logic (independent of main bars)
            if AKB.UI and AKB.UI.StatWindows and AKB.UI.StatWindows.UpdateVisibility then
                AKB.UI.StatWindows.UpdateVisibility()
            end
        end
    end
end

-- Initialize weapon set tracking for backup detection
function AKB.Events.InitializeWeaponTracking()
    -- Track current active weapon set
    if not AKB.Events.currentWeaponSet then
        AKB.Events.currentWeaponSet = GetActiveWeaponPairInfo and GetActiveWeaponPairInfo() or 1
    end
    
    -- Periodic check as backup for missed swap events (every 200ms for console performance)
    EVENT_MANAGER:RegisterForUpdate(AKB.name .. "_WeaponSetTracker", 200, function()
        if GetActiveWeaponPairInfo then
            local currentSet = GetActiveWeaponPairInfo()
            if currentSet ~= AKB.Events.currentWeaponSet then
                AKB.Events.currentWeaponSet = currentSet
                AKB.Events.HandleWeaponSwap()
            end
        end
    end)
end
