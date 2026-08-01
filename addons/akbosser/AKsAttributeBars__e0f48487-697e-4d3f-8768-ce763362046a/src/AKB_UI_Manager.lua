-- ============================================================================
-- AKsAttributeBars - UI Manager Module
-- ============================================================================
-- Handles high-level UI management, visibility control, and bar coordination

local AKB = AKsAttributeBars

-- Create Manager namespace
AKB.UI = AKB.UI or {}
AKB.UI.Manager = AKB.UI.Manager or {}

-- Runtime Variables
local playerHealthBar = nil
local playerMagickaBar = nil
local playerStaminaBar = nil
local playerMountStaminaBar = nil
local playerAttributeBars = nil
local playerNameLabel = nil
local physicalResistanceWindow = nil

-- Initialize shield event handlers
function AKB.UI.Manager.InitializeShieldEvents()
    if EVENT_MANAGER then
        EVENT_MANAGER:RegisterForEvent(AKB.name .. "_ShieldAdded", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, function(_, unitTag, attributeVisualizerEffect)
            if unitTag == "player" and attributeVisualizerEffect == ATTRIBUTE_VISUAL_POWER_SHIELDING then
                if playerHealthBar and playerHealthBar.Update then
                    local currentHealth, maxHealth = GetUnitPower("player", AKB.Utils.POWER_TYPES.HEALTH)
                    playerHealthBar:Update(currentHealth, maxHealth)
                end
            end
        end)
        EVENT_MANAGER:RegisterForEvent(AKB.name .. "_ShieldUpdated", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, function(_, unitTag, attributeVisualizerEffect)
            if unitTag == "player" and attributeVisualizerEffect == ATTRIBUTE_VISUAL_POWER_SHIELDING then
                if playerHealthBar and playerHealthBar.Update then
                    local currentHealth, maxHealth = GetUnitPower("player", AKB.Utils.POWER_TYPES.HEALTH)
                    playerHealthBar:Update(currentHealth, maxHealth)
                end
            end
        end)
        EVENT_MANAGER:RegisterForEvent(AKB.name .. "_ShieldRemoved", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, function(_, unitTag, attributeVisualizerEffect)
            if unitTag == "player" and attributeVisualizerEffect == ATTRIBUTE_VISUAL_POWER_SHIELDING then
                if playerHealthBar and playerHealthBar.Update then
                    local currentHealth, maxHealth = GetUnitPower("player", AKB.Utils.POWER_TYPES.HEALTH)
                    playerHealthBar:Update(currentHealth, maxHealth)
                end
            end
        end)
    end
end

-- Initialize stat change event handlers for more responsive updates
function AKB.UI.Manager.InitializeStatEvents()
    if EVENT_MANAGER then
        -- Effect changes that can affect stats (buffs, debuffs, set bonuses, etc.)
        EVENT_MANAGER:RegisterForEvent(AKB.name .. "_PlayerEffectChanged", EVENT_EFFECT_CHANGED, function(_, changeType, slotNum, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId)
            if unitTag == "player" and physicalResistanceWindow and physicalResistanceWindow.Update then
                physicalResistanceWindow:Update()
            end
        end)
        EVENT_MANAGER:AddFilterForEvent(AKB.name .. "_PlayerEffectChanged", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
        
        -- Item slot changes that can affect stats (equipment changes)
        EVENT_MANAGER:RegisterForEvent(AKB.name .. "_ItemSlotChanged", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason)
            -- Only update for equipped items (worn bag)
            if bagId == BAG_WORN and physicalResistanceWindow and physicalResistanceWindow.Update then
                physicalResistanceWindow:Update()
            end
        end)
    end
end

-- Create all three attribute bars with proper layout
function AKB.UI.Manager.CreatePlayerAttributeBars()
    -- Check if required API functions are available
    if not WINDOW_MANAGER or not GuiRoot or not GetUnitPower then
        return
    end
    
    -- Always destroy existing bars first to ensure settings changes take effect immediately
    -- This ensures live updates for all settings, even if it causes a brief flicker
    
    -- Get current power values
    local testHealth, testMaxHealth = GetUnitPower("player", AKB.Utils.POWER_TYPES.HEALTH)
    local testMagicka, testMaxMagicka = GetUnitPower("player", AKB.Utils.POWER_TYPES.MAGICKA)
    local testStamina, testMaxStamina = GetUnitPower("player", AKB.Utils.POWER_TYPES.STAMINA)
    
    if not (testHealth and testMaxHealth and testMagicka and testMaxMagicka and testStamina and testMaxStamina) then
        return
    end
    
    -- Clean up existing bars first
    AKB.UI.Manager.DestroyPlayerAttributeBars()
    
    -- Create bars after cleanup delay
    local function createAndSyncMountBar()
        AKB.UI.Manager.CreateBarsAfterCleanup(testHealth, testMaxHealth, testMagicka, testMaxMagicka, testStamina, testMaxStamina)
        -- After recreating bars, ensure mount stamina bar visibility matches mount state
        if AKB.UI.Manager.GetPlayerBars then
            local bars = AKB.UI.Manager.GetPlayerBars()
            if bars and bars.mountStamina and IsMounted then
                if IsMounted() then
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
    end
    if EVENT_MANAGER then
        EVENT_MANAGER:RegisterForUpdate(AKB.name .. "_DelayedCreate", 200, function()
            EVENT_MANAGER:UnregisterForUpdate(AKB.name .. "_DelayedCreate")
            createAndSyncMountBar()
        end)
    else
        createAndSyncMountBar()
    end
end

-- Create bars after cleanup delay
function AKB.UI.Manager.CreateBarsAfterCleanup(testHealth, testMaxHealth, testMagicka, testMaxMagicka, testStamina, testMaxStamina)
    local settings = AKB.Settings.GetAll()
    local isCompact = settings.customBarType == 2
    local constants = AKB.Utils.BAR_CONSTANTS
    
    local actualBarHeight = isCompact and (constants.HEIGHT + 8) or constants.HEIGHT
    local windowHeight = isCompact and (actualBarHeight + 20) or (constants.HEIGHT + 20)
    local barSpacing = isCompact and actualBarHeight or (windowHeight + constants.SPACING)
    
    -- Calculate positions based on layout
    local healthXOffset, healthYOffset = 0, 0
    local magickaXOffset, magickaYOffset = 0, 0
    local staminaXOffset, staminaYOffset = 0, 0
    local mountStaminaXOffset, mountStaminaYOffset = 0, 0

    local mountStaminaHeight = settings.mountStaminaHeight or 12

    if settings.customBarLayout == 2 then
        -- Pyramid layout
        healthXOffset = 0
        healthYOffset = 0
        magickaXOffset = -150
        magickaYOffset = barSpacing
        staminaXOffset = 150
        staminaYOffset = barSpacing
        -- Mount stamina always directly below stamina bar with extra spacing
        mountStaminaXOffset = staminaXOffset
        mountStaminaYOffset = staminaYOffset + (settings.staminaBarHeight or (isCompact and (constants.HEIGHT + 8) or constants.HEIGHT)) + 12
    else
        -- Stacked layout (default)
        healthXOffset = 0
        healthYOffset = 0
        magickaXOffset = 0
        magickaYOffset = barSpacing
        staminaXOffset = 0
        staminaYOffset = barSpacing * 2
        -- Mount stamina always directly below stamina bar with extra spacing
        mountStaminaXOffset = 0
        mountStaminaYOffset = staminaYOffset + (settings.staminaBarHeight or (isCompact and (constants.HEIGHT + 8) or constants.HEIGHT)) + 12
    end
    
    -- Create bars
    playerHealthBar = AKB.UI.Bars.CreateSingleAttributeBar("Health", AKB.Utils.POWER_TYPES.HEALTH, healthXOffset, healthYOffset, settings.healthBarColor)
    playerMagickaBar = AKB.UI.Bars.CreateSingleAttributeBar("Magicka", AKB.Utils.POWER_TYPES.MAGICKA, magickaXOffset, magickaYOffset, settings.magickaBarColor)
    playerStaminaBar = AKB.UI.Bars.CreateSingleAttributeBar("Stamina", AKB.Utils.POWER_TYPES.STAMINA, staminaXOffset, staminaYOffset, settings.staminaBarColor)
    
    -- Create mount stamina bar if enabled
    if settings.showMountStamina then
        playerMountStaminaBar = AKB.UI.Bars.CreateMountStaminaBar("MountStamina", AKB.Utils.POWER_TYPES.MOUNT_STAMINA, mountStaminaXOffset, mountStaminaYOffset, settings.mountStaminaBarColor)
        -- Always hide on creation; will be shown by mount event if needed
        if playerMountStaminaBar and playerMountStaminaBar.Hide then
            playerMountStaminaBar:Hide()
        end
        -- Immediately update mount stamina bar with current values
        if playerMountStaminaBar and GetUnitPower then
            local currentMountStamina, maxMountStamina = GetUnitPower("player", AKB.Utils.POWER_TYPES.MOUNT_STAMINA)
            if currentMountStamina and maxMountStamina then
                playerMountStaminaBar:Update(currentMountStamina, maxMountStamina)
            end
        end
    else
        playerMountStaminaBar = nil
    end
    -- Listen for mount state changes to show/hide mount stamina bar
    if EVENT_MANAGER then
        EVENT_MANAGER:RegisterForEvent(AKB.name .. "_MountStateChanged", EVENT_MOUNTED_STATE_CHANGED, function(_, mounted)
            if AKB.UI.Manager.GetPlayerBars then
                local bars = AKB.UI.Manager.GetPlayerBars()
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
            end
        end)
    end
    
    -- Create player name label
    playerNameLabel = AKB.UI.NameLabel.CreatePlayerNameLabel(healthXOffset, healthYOffset)
    
    -- Create food indicator (shows bread icon when no food/drink buff is active)
    -- Add a small delay to ensure bars are fully created
    if AKB.FoodIndicator and AKB.FoodIndicator.CreateFoodIndicator then
        if EVENT_MANAGER then
            EVENT_MANAGER:RegisterForUpdate(AKB.name .. "_DelayedFoodIndicator", 300, function()
                EVENT_MANAGER:UnregisterForUpdate(AKB.name .. "_DelayedFoodIndicator")
                AKB.FoodIndicator.CreateFoodIndicator()
            end)
        else
            -- Fallback if no event manager
            AKB.FoodIndicator.CreateFoodIndicator()
        end
    end
    
    -- Create stat window (test: physical resistance)
    if AKB.UI.StatWindows and AKB.UI.StatWindows.CreatePhysicalResistanceWindow then
        physicalResistanceWindow = AKB.UI.StatWindows.CreatePhysicalResistanceWindow(0, 0)
    end
    
    -- Store bars in array
    playerAttributeBars = {playerHealthBar, playerMagickaBar, playerStaminaBar}
    if playerMountStaminaBar then
        table.insert(playerAttributeBars, playerMountStaminaBar)
    end
    
    -- Update with current values
    AKB.UI.Manager.UpdateAllBars()
    
    -- Apply visibility settings (hide when full and out of combat if enabled)
    AKB.UI.Manager.UpdateBarVisibility()
    
    -- Note: Stat windows are created independently via their own menu settings
    -- and are not tied to the main attribute bars
end

-- Update all bars with current values
function AKB.UI.Manager.UpdateAllBars()
    if playerHealthBar then
        local currentHealth, maxHealth = GetUnitPower("player", AKB.Utils.POWER_TYPES.HEALTH)
        if currentHealth and maxHealth then
            playerHealthBar:Update(currentHealth, maxHealth)
        end
    end
    
    if playerMagickaBar then
        local currentMagicka, maxMagicka = GetUnitPower("player", AKB.Utils.POWER_TYPES.MAGICKA)
        if currentMagicka and maxMagicka then
            playerMagickaBar:Update(currentMagicka, maxMagicka)
        end
    end
    
    if playerStaminaBar then
        local currentStamina, maxStamina = GetUnitPower("player", AKB.Utils.POWER_TYPES.STAMINA)
        if currentStamina and maxStamina then
            playerStaminaBar:Update(currentStamina, maxStamina)
        end
    end
    
    if playerMountStaminaBar then
        local currentMountStamina, maxMountStamina = GetUnitPower("player", AKB.Utils.POWER_TYPES.MOUNT_STAMINA)
        if currentMountStamina and maxMountStamina then
            playerMountStaminaBar:Update(currentMountStamina, maxMountStamina)
        end
    end
    
    -- Update stat windows
    if physicalResistanceWindow and physicalResistanceWindow.Update then
        physicalResistanceWindow:Update()
    end
    
    -- Update visibility based on auto-hide setting
    AKB.UI.Manager.UpdateBarVisibility()
end

-- Update bar colors without recreating bars
function AKB.UI.Manager.UpdateBarColors()
    local settings = AKB.Settings.GetAll()
    
    -- Update health bar color
    if playerHealthBar and playerHealthBar.color and playerHealthBar.fill then
        playerHealthBar.color = settings.healthBarColor
        if playerHealthBar.fill.SetColor then
            playerHealthBar.fill:SetColor(settings.healthBarColor.r, settings.healthBarColor.g, settings.healthBarColor.b, settings.barTransparency)
            
            -- Phase 2: Update health bar gradient when color changes (gamepad compatible)
            if playerHealthBar.fill.SetGradientColors then
                local color = settings.healthBarColor
                local lighter = {
                    r = math.min(1.0, color.r + 0.2), 
                    g = math.min(1.0, color.g + 0.2), 
                    b = math.min(1.0, color.b + 0.2)
                }
                local darker = {
                    r = math.max(0.0, color.r - 0.15), 
                    g = math.max(0.0, color.g - 0.15), 
                    b = math.max(0.0, color.b - 0.15)
                }
                
                playerHealthBar.fill:SetGradientColors(2, 
                    lighter.r, lighter.g, lighter.b, settings.barTransparency,
                    darker.r, darker.g, darker.b, settings.barTransparency
                )
            end
        end
    end
    
    -- Update magicka bar color
    if playerMagickaBar and playerMagickaBar.color and playerMagickaBar.fill then
        playerMagickaBar.color = settings.magickaBarColor
        if playerMagickaBar.fill.SetColor then
            playerMagickaBar.fill:SetColor(settings.magickaBarColor.r, settings.magickaBarColor.g, settings.magickaBarColor.b, settings.barTransparency)
            
            -- Phase 2: Update magicka bar gradient when color changes (gamepad compatible)
            if playerMagickaBar.fill.SetGradientColors then
                local color = settings.magickaBarColor
                local lighter = {
                    r = math.min(1.0, color.r + 0.2), 
                    g = math.min(1.0, color.g + 0.2), 
                    b = math.min(1.0, color.b + 0.2)
                }
                local darker = {
                    r = math.max(0.0, color.r - 0.15), 
                    g = math.max(0.0, color.g - 0.15), 
                    b = math.max(0.0, color.b - 0.15)
                }
                
                playerMagickaBar.fill:SetGradientColors(2, 
                    lighter.r, lighter.g, lighter.b, settings.barTransparency,
                    darker.r, darker.g, darker.b, settings.barTransparency
                )
            end
        end
    end
    
    -- Update stamina bar color
    if playerStaminaBar and playerStaminaBar.color and playerStaminaBar.fill then
        playerStaminaBar.color = settings.staminaBarColor
        if playerStaminaBar.fill.SetColor then
            playerStaminaBar.fill:SetColor(settings.staminaBarColor.r, settings.staminaBarColor.g, settings.staminaBarColor.b, settings.barTransparency)
            
            -- Phase 2: Update stamina bar gradient when color changes (gamepad compatible)
            if playerStaminaBar.fill.SetGradientColors then
                local color = settings.staminaBarColor
                local lighter = {
                    r = math.min(1.0, color.r + 0.2), 
                    g = math.min(1.0, color.g + 0.2), 
                    b = math.min(1.0, color.b + 0.2)
                }
                local darker = {
                    r = math.max(0.0, color.r - 0.15), 
                    g = math.max(0.0, color.g - 0.15), 
                    b = math.max(0.0, color.b - 0.15)
                }
                
                playerStaminaBar.fill:SetGradientColors(2, 
                    lighter.r, lighter.g, lighter.b, settings.barTransparency,
                    darker.r, darker.g, darker.b, settings.barTransparency
                )
            end
        end
    end
    
    -- Update mount stamina bar color
    if playerMountStaminaBar and playerMountStaminaBar.color and playerMountStaminaBar.fill then
        playerMountStaminaBar.color = settings.mountStaminaBarColor
        if playerMountStaminaBar.fill.SetColor then
            playerMountStaminaBar.fill:SetColor(settings.mountStaminaBarColor.r, settings.mountStaminaBarColor.g, settings.mountStaminaBarColor.b, settings.barTransparency)
            
            -- Phase 2: Update mount stamina bar gradient when color changes (gamepad compatible)
            if playerMountStaminaBar.fill.SetGradientColors then
                local color = settings.mountStaminaBarColor
                local lighter = {
                    r = math.min(1.0, color.r + 0.2), 
                    g = math.min(1.0, color.g + 0.2), 
                    b = math.min(1.0, color.b + 0.2)
                }
                local darker = {
                    r = math.max(0.0, color.r - 0.15), 
                    g = math.max(0.0, color.g - 0.15), 
                    b = math.max(0.0, color.b - 0.15)
                }
                
                playerMountStaminaBar.fill:SetGradientColors(2, 
                    lighter.r, lighter.g, lighter.b, settings.barTransparency,
                    darker.r, darker.g, darker.b, settings.barTransparency
                )
            end
        end
    end
    
    -- Update shield color
    if playerHealthBar and playerHealthBar.shieldBar and playerHealthBar.shieldBar.SetColor then
        local shieldColor = settings.shieldColor
        playerHealthBar.shieldBar:SetColor(shieldColor.r, shieldColor.g, shieldColor.b, shieldColor.a)
        
        -- Phase 2: Update shield gradient when color changes (gamepad compatible)
        if playerHealthBar.shieldBar.SetGradientColors then
            -- Create lighter top and darker bottom for 3D depth effect
            local lighter = {
                r = math.min(1.0, shieldColor.r + 0.2), 
                g = math.min(1.0, shieldColor.g + 0.2), 
                b = math.min(1.0, shieldColor.b + 0.2)
            }
            local darker = {
                r = math.max(0.0, shieldColor.r - 0.15), 
                g = math.max(0.0, shieldColor.g - 0.15), 
                b = math.max(0.0, shieldColor.b - 0.15)
            }
            
            -- Direction 2 = vertical gradient (top to bottom)
            playerHealthBar.shieldBar:SetGradientColors(2, 
                lighter.r, lighter.g, lighter.b, shieldColor.a,  -- Top (lighter)
                darker.r, darker.g, darker.b, shieldColor.a      -- Bottom (darker)
            )
        end
    end
end

-- Force cleanup of any orphaned UI elements
function AKB.UI.Manager.ForceCleanupOrphanedElements()
    -- Clear all animations first
    if AKB.Animation and AKB.Animation.ClearAllAnimations then
        AKB.Animation.ClearAllAnimations()
    end
    
    -- Find and destroy any orphaned AKB UI elements
    if WINDOW_MANAGER and WINDOW_MANAGER.GetTopLevelWindows then
        local topLevelWindows = WINDOW_MANAGER:GetTopLevelWindows()
        for _, window in ipairs(topLevelWindows) do
            if window and window.GetName then
                local name = window:GetName()
                if name and (name:find("AKB_Console") or name:find("AKB_Player")) then
                    -- This is one of our UI elements, destroy it
                    if window.Destroy then
                        window:Destroy()
                    end
                end
            end
        end
    end
end

-- Destroy all player attribute bars
function AKB.UI.Manager.DestroyPlayerAttributeBars()
    -- Cancel any pending creation timers first
    if EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForUpdate(AKB.name .. "_DelayedCreate")
        EVENT_MANAGER:UnregisterForUpdate(AKB.name .. "_DelayedBarCreation")
        EVENT_MANAGER:UnregisterForUpdate(AKB.name .. "_DelayedFoodIndicator")
        -- Unregister shield events
        EVENT_MANAGER:UnregisterForEvent(AKB.name .. "_ShieldAdded")
        EVENT_MANAGER:UnregisterForEvent(AKB.name .. "_ShieldUpdated")
        EVENT_MANAGER:UnregisterForEvent(AKB.name .. "_ShieldRemoved")
    end
    
    -- Destroy individual bars
    if playerHealthBar and playerHealthBar.Destroy then
        playerHealthBar:Destroy()
    end
    if playerMagickaBar and playerMagickaBar.Destroy then
        playerMagickaBar:Destroy()
    end
    if playerStaminaBar and playerStaminaBar.Destroy then
        playerStaminaBar:Destroy()
    end
    if playerMountStaminaBar and playerMountStaminaBar.Destroy then
        playerMountStaminaBar:Destroy()
    end
    
    -- Destroy food indicator
    if AKB.FoodIndicator and AKB.FoodIndicator.DestroyFoodIndicator then
        AKB.FoodIndicator.DestroyFoodIndicator()
    end
    
    -- Destroy bars from the array
    if playerAttributeBars then
        for _, bar in ipairs(playerAttributeBars) do
            if bar and bar.Destroy then
                bar:Destroy()
            end
        end
    end
    
    -- Destroy name label
    if playerNameLabel and playerNameLabel.Destroy then
        playerNameLabel:Destroy()
    end
    
    -- Note: Stat windows are NOT destroyed here - they are independent of main bars
    -- and managed separately by their own Enable/Disable settings
    
    -- Clear all references
    playerHealthBar = nil
    playerMagickaBar = nil
    playerStaminaBar = nil
    playerMountStaminaBar = nil
    playerAttributeBars = nil
    playerNameLabel = nil
    
    -- Force cleanup of any orphaned elements
    AKB.UI.Manager.ForceCleanupOrphanedElements()
    
    -- Force garbage collection to ensure cleanup
    if collectgarbage then
        collectgarbage("collect")
    end
end

-- Show/hide custom bars
function AKB.UI.Manager.SetCustomBarsVisibility(visible)
    if visible then
        AKB.UI.Manager.CreatePlayerAttributeBars()
        -- Fix mount stamina visibility after showing bars
        if AKB.Events and AKB.Events.UpdateMountStaminaVisibility then
            AKB.Events.UpdateMountStaminaVisibility()
        end
    else
        AKB.UI.Manager.DestroyPlayerAttributeBars()
    end
end

-- Get current bars for external access
function AKB.UI.Manager.GetPlayerBars()
    return {
        health = playerHealthBar,
        magicka = playerMagickaBar,
        stamina = playerStaminaBar,
        mountStamina = playerMountStaminaBar,
        nameLabel = playerNameLabel
    }
end

-- Check if all attributes are at full
function AKB.UI.Manager.AreAllAttributesFull()
    if not GetUnitPower then
        return false
    end
    
    local currentHealth, maxHealth = GetUnitPower("player", AKB.Utils.POWER_TYPES.HEALTH)
    local currentMagicka, maxMagicka = GetUnitPower("player", AKB.Utils.POWER_TYPES.MAGICKA)
    local currentStamina, maxStamina = GetUnitPower("player", AKB.Utils.POWER_TYPES.STAMINA)
    
    if not (currentHealth and maxHealth and currentMagicka and maxMagicka and currentStamina and maxStamina) then
        return false
    end
    
    return currentHealth >= maxHealth and currentMagicka >= maxMagicka and currentStamina >= maxStamina
end

-- Update bar visibility based on auto-hide setting
function AKB.UI.Manager.UpdateBarVisibility()
    local settings = AKB.Settings.GetAll()
    
    -- If custom bars are not enabled, nothing to do
    if not settings.showBars then
        return
    end
    
    -- Check if bars should be hidden due to UI state (menus/maps open) first
    if AKB.Events and AKB.Events.IsAnyMenuOpen then
        local status, menuOpen = pcall(AKB.Events.IsAnyMenuOpen)
        if status and menuOpen then
            -- UI state requires bars to be hidden - hide all bars AND stat windows
            AKB.UI.Manager.HideAllBars()
            return
        end
    end
    
    -- If auto-hide is not enabled, ensure bars are visible
    if not settings.hideWhenFullAndOutOfCombat then
        -- Cancel any pending hide timer
        if EVENT_MANAGER then
            EVENT_MANAGER:UnregisterForUpdate(AKB.name .. "_DelayedHide")
        end
        AKB.UI.Manager.ShowAllBars()
        return
    end
    
    -- Check if we should hide bars (except mount stamina bar, which should always show if mounted)
    local shouldHide = AKB.UI.Manager.AreAllAttributesFull() and not IsUnitInCombat("player")

    if shouldHide then
        -- Add 1-second delay before hiding bars
        if EVENT_MANAGER then
            EVENT_MANAGER:RegisterForUpdate(AKB.name .. "_DelayedHide", 1000, function()
                EVENT_MANAGER:UnregisterForUpdate(AKB.name .. "_DelayedHide")
                -- Double-check conditions are still met after delay
                if AKB.UI.Manager.AreAllAttributesFull() and not IsUnitInCombat("player") and settings.hideWhenFullAndOutOfCombat then
                    -- Hide all bars except mount stamina if mounted
                    AKB.UI.Manager.HideAllBars()
                    -- Show mount stamina bar if mounted
                    if playerMountStaminaBar and playerMountStaminaBar.Show and IsMounted and IsMounted() then
                        playerMountStaminaBar:Show()
                    end
                    

                end
            end)
        else
            -- Fallback without delay if EVENT_MANAGER not available
            AKB.UI.Manager.HideAllBars()
            if playerMountStaminaBar and playerMountStaminaBar.Show and IsMounted and IsMounted() then
                playerMountStaminaBar:Show()
            end
        end
    else
        -- Cancel any pending hide timer when conditions change
        if EVENT_MANAGER then
            EVENT_MANAGER:UnregisterForUpdate(AKB.name .. "_DelayedHide")
        end
        AKB.UI.Manager.ShowAllBars()
    end
end

-- Hide all bars and labels
function AKB.UI.Manager.HideAllBars()
    if playerHealthBar and playerHealthBar.Hide then
        playerHealthBar:Hide()
    end
    if playerMagickaBar and playerMagickaBar.Hide then
        playerMagickaBar:Hide()
    end
    if playerStaminaBar and playerStaminaBar.Hide then
        playerStaminaBar:Hide()
    end
    if playerMountStaminaBar and playerMountStaminaBar.Hide then
        playerMountStaminaBar:Hide()
    end
    if playerNameLabel and playerNameLabel.Hide then
        playerNameLabel:Hide()
    end
    
    -- Update food indicator visibility when bars are hidden
    if AKB.FoodIndicator and AKB.FoodIndicator.UpdateVisibility then
        AKB.FoodIndicator.UpdateVisibility()
    end
    
    -- Hide enemy bars when player bars are hidden
    if AKB.EnemyBars and AKB.EnemyBars.SetVisibility then
        AKB.EnemyBars.SetVisibility(false)
    end
    
    -- Note: Stat windows are now independent - they have their own visibility logic
    -- that's separate from main attribute bars via AKB.UI.StatWindows.UpdateVisibility()
end

-- Show all bars and labels
function AKB.UI.Manager.ShowAllBars()
    if playerHealthBar and playerHealthBar.Show then
        playerHealthBar:Show()
    end
    if playerMagickaBar and playerMagickaBar.Show then
        playerMagickaBar:Show()
    end
    if playerStaminaBar and playerStaminaBar.Show then
        playerStaminaBar:Show()
    end
    -- Mount stamina bar should only show if mounted
    if playerMountStaminaBar and playerMountStaminaBar.Show and IsMounted and IsMounted() then
        playerMountStaminaBar:Show()
    end
    if playerNameLabel and playerNameLabel.Show then
        playerNameLabel:Show()
    end
    
    -- Update food indicator visibility when bars are shown
    if AKB.FoodIndicator and AKB.FoodIndicator.UpdateVisibility then
        AKB.FoodIndicator.UpdateVisibility()
    end
    
    -- Show enemy bars when player bars are shown
    if AKB.EnemyBars and AKB.EnemyBars.SetVisibility then
        AKB.EnemyBars.SetVisibility(true)
    end
    
    -- Note: Stat windows are now independent - they have their own visibility logic
    -- that's separate from main attribute bars via AKB.UI.StatWindows.UpdateVisibility()
end
