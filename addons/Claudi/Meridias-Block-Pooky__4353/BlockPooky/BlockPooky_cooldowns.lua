--[[
    BlockPooky Cooldown Bars Module
    
    This module provides custom cooldown tracking bars for any ability or effect.
    Users can create personalized bars to track:
    - Ability cooldowns (uses configured duration)
    - Effect durations (uses begin/end times from events)
    
    Features:
    - Dynamic creation/removal through settings menu
    - Movable positioning with persistence
    - Customizable colors per bar
    - Character-specific visibility settings
    - Account-wide configuration storage
    
    Bar Types:
    - "ability": Tracks when you cast an ability, shows configured cooldown
    - "effect": Tracks when an effect is gained/lost, uses event timing
    
    CLOSURE PATTERNS EXPLAINED:
    
    This module demonstrates advanced closure usage for dynamic event handling.
    Three distinct closure patterns are employed:
    
    1. FACTORY CLOSURES (OnCooldownAbilityEventClosure, OnCooldownEffectClosure):
       - Create customized event handlers for each cooldown bar
       - Capture the bar 'name' to ensure each handler processes only its own events
       - Essential for dynamic bars where multiple instances need separate handlers
    
    2. IIFE CLOSURES (showCDbar update function):
       - Immediately Invoked Function Expression that captures variables
       - Prevents variable reference issues in timer callbacks
       - Each bar gets its own update loop with correct variable scope
    
    3. SIMPLE CLOSURES (OnMoveStop handlers):
       - Capture 'name' parameter for position saving callbacks
       - Standard pattern for UI event handlers that need context
    
    WHY CLOSURES ARE NECESSARY HERE:
    - ESO's event system requires function references, not method calls
    - Multiple cooldown bars need isolated event processing
    - Dynamic creation means handlers can't be predefined
    - Variable capture prevents reference bugs in async operations
--]]

--[[ basic initialization -------------------------------------------------------------------------------------------]]
BlockPooky = BlockPooky or {}
local BlockPooky = BlockPooky

--[[ cooldown bars implementation ----------------------------------------------------------------------------------]]

---Sets the color of a cooldown bar based on its configuration
---@param name string the name of the cooldown bar to color
function BlockPooky.SetCooldownBarColour(name)
    if BlockPooky.config.cooldownbar[name].color then
        BlockPooky.cooldownbar[name].statusBar:SetColor(unpack(BlockPooky.config.cooldownbar[name].color))
    else
        BlockPooky.cooldownbar[name].statusBar:SetColor(1, 0, 1, 1) -- Default magenta color
    end
end

function BlockPooky.InitCooldownBarUI(name)
    -- Prüfen, ob die ccBar bereits existiert
    if BlockPooky.cooldownbar == nil then
        BlockPooky.cooldownbar = {}
    end
    if BlockPooky.cooldownbar[name] == nil then
        local config = BlockPooky.AddCooldownBar(name)
        BlockPooky.cooldownbar[name] = {}
        BlockPooky.cooldownbar[name]["bar"] = CreateControl(BlockPooky.name..name.."Bar", GuiRoot, CT_TOPLEVELCONTROL)
        BlockPooky.cooldownbar[name]["label"] = CreateControl(BlockPooky.name..name.."Label", BlockPooky.cooldownbar[name].bar , CT_LABEL)
        BlockPooky.cooldownbar[name]["statusBar"] = CreateControl(BlockPooky.name..name.."Status", BlockPooky.cooldownbar[name].bar, CT_STATUSBAR)
        
        local cdbar = BlockPooky.cooldownbar[name]["bar"]

        BlockPooky.cooldownbar[name].bar:SetDimensions(200, 40)
        BlockPooky.cooldownbar[name].bar:SetAnchor(CENTER, GuiRoot, CENTER, 0, -120)
        BlockPooky.cooldownbar[name].bar:SetHidden(true)
        BlockPooky.cooldownbar[name].bar:SetMovable(true) -- Verschiebbar machen
        BlockPooky.cooldownbar[name].bar:SetMouseEnabled(true) -- Mausinteraktionen erlauben
        -- SIMPLE CLOSURE: Captures 'name' for the position saving callback
        -- Without this closure, the handler wouldn't know which bar was moved
        BlockPooky.cooldownbar[name].bar:SetHandler("OnMoveStop", function() BlockPooky.SaveCooldownBarPosition(name) end)
    
        BlockPooky.cooldownbar[name].label:SetFont("ZoFontWinH4")
        BlockPooky.cooldownbar[name].label:SetColor(1, 1, 1, 1) -- Weiß
        BlockPooky.cooldownbar[name].label:SetText("")
        BlockPooky.cooldownbar[name].label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        BlockPooky.cooldownbar[name].label:SetAnchor(TOP, cdbar, TOP, 0, 0)

        BlockPooky.cooldownbar[name].statusBar:SetDimensions(200, 20)
        BlockPooky.cooldownbar[name].statusBar:SetAnchor(BOTTOM, cdbar, BOTTOM, 0, 0)
        BlockPooky.cooldownbar[name].statusBar:SetMinMax(0, 1)
        BlockPooky.SetCooldownBarColour(name)

        if config.left==nil or config.top==nil then
            BlockPooky.SaveCooldownBarPosition(name)
        end
    end
    -- Lade die gespeicherte Position
    BlockPooky.LoadCooldownBarPosition(name)
end

function BlockPooky.SaveCooldownBarPosition(name)
    local left, top = BlockPooky.cooldownbar[name].bar:GetLeft(), BlockPooky.cooldownbar[name].bar:GetTop()
    if BlockPooky.config.cooldownbar[name] then
        BlockPooky.config.cooldownbar[name].left = left
        BlockPooky.config.cooldownbar[name].top = top
    else
        d("THIS should never happen...")
        BlockPooky.config.cooldownbar[name] = {
            left = left, top = top, abilityId=0, cooldown=0, type="ability", color={1, 0, 1, 1}}
    end
end

function BlockPooky.LoadCooldownBarPosition(name)
    if BlockPooky.config and BlockPooky.config.cooldownbar and BlockPooky.config.cooldownbar[name] then
        if BlockPooky.cooldownbar[name] then
            local bar = BlockPooky.cooldownbar[name].bar
            if bar:GetAnchor() ~= nil then
                bar:ClearAnchors()
            end
            bar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BlockPooky.config.cooldownbar[name].left, BlockPooky.config.cooldownbar[name].top)
        end
    end
end

function BlockPooky.GetShowCooldownBar(name)
    if BlockPooky.toonConfig.cooldownbar[name] then
        return BlockPooky.toonConfig.cooldownbar[name].show
    end
    return false
end

function BlockPooky.AddCooldownBar(name)
    if BlockPooky.config.cooldownbar[name] == nil then
        BlockPooky.config.cooldownbar[name] = {
            top=nil, left=nil, abilityId=0, cooldown=0, type="ability", color={1, 0, 1, 1}}
    end
    if BlockPooky.toonConfig.cooldownbar[name] == nil then
        BlockPooky.toonConfig.cooldownbar[name] = {show=false}
    end
    return BlockPooky.config.cooldownbar[name]
end

function BlockPooky.RemoveCooldownBar(name)
    if BlockPooky.config.cooldownbar[name] ~= nil then
        BlockPooky.config.cooldownbar[name] = nil
    end
end

function BlockPooky.InitCooldownBarUIs()
    if BlockPooky.config.cooldownbar then
        for name, config in pairs(BlockPooky.config.cooldownbar) do
            BlockPooky.InitCooldownBarUI(name)
        end
    end
end

function BlockPooky.InitCooldownBarEvents()
    if BlockPooky.config.cooldownbar then
        for name, config in pairs(BlockPooky.config.cooldownbar) do
            if BlockPooky.GetShowCooldownBar(name) then
                BlockPooky.CooldownBarEventRegisterUpdate(name, true, config.type)
            end
        end
    end
end

function BlockPooky.CooldownBarsSetHidden(hide)
    if BlockPooky.config.cooldownbar then
        for name, config in pairs(BlockPooky.config.cooldownbar) do
            if BlockPooky.GetShowCooldownBar(name) and BlockPooky.cooldownbar[name] then
                BlockPooky.cooldownbar[name].bar:SetHidden(hide)
            end
        end
    end
end

function BlockPooky.ResetCooldownBarsPosition()
    if BlockPooky.config.cooldownbar and BlockPooky.cooldownbar then
        for name, config in pairs(BlockPooky.config.cooldownbar) do
            if BlockPooky.GetShowCooldownBar(name) and BlockPooky.cooldownbar[name] then
                local bar = BlockPooky.cooldownbar[name].bar
                if bar:GetAnchor() ~= nil then
                    bar:ClearAnchors()
                end
                bar:SetAnchor(CENTER, GuiRoot, CENTER, 0, -120)
                BlockPooky.SaveCooldownBarPosition(name)
            end
        end
    end
end

function BlockPooky.RestoreCooldownBarsPosition()
    if BlockPooky.config.cooldownbar and BlockPooky.cooldownbar then
        for name, config in pairs(BlockPooky.config.cooldownbar) do
            if BlockPooky.GetShowCooldownBar(name) then
                BlockPooky.LoadCooldownBarPosition(name)
            end
        end
    end
end

function BlockPooky.CooldownBarEventRegisterUpdate(name, useCooldownBar, type)
    if type=="effect" then
        if useCooldownBar then
            EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. name .."CDWatcher", EVENT_EFFECT_CHANGED, BlockPooky.OnCooldownEffectClosure(name))
            EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. name .."CDWatcher", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
        else
            EVENT_MANAGER:UnregisterForEvent(BlockPooky.name .. name .."CDWatcher")
        end
    else
        if useCooldownBar then
            EVENT_MANAGER:RegisterForEvent(BlockPooky.name .. name .."CDWatcher", EVENT_COMBAT_EVENT, BlockPooky.OnCooldownAbilityEventClosure(name))
            EVENT_MANAGER:AddFilterForEvent(BlockPooky.name .. name .."CDWatcher", EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG, "player")
        else
            EVENT_MANAGER:UnregisterForEvent(BlockPooky.name .. name .."CDWatcher")
        end
    end
end

function BlockPooky.UpdateCooldownBarUsage(name, useCooldownBar)
    if BlockPooky.toonConfig.cooldownbar[name] == nil then
        BlockPooky.toonConfig.cooldownbar[name] {show=false}
    end
    if useCooldownBar ~= BlockPooky.toonConfig.cooldownbar[name].show then
        if useCooldownBar then
            BlockPooky.InitCooldownBarUI(name)
            BlockPooky.toonConfig.cooldownbar[name].show=true
        else
            BlockPooky.toonConfig.cooldownbar[name].show=false
            if BlockPooky.cooldownbar and BlockPooky.cooldownbar[name] then
                BlockPooky.cooldownbar[name].bar:SetHidden(true)
            end
        end
        BlockPooky.CooldownBarEventRegisterUpdate(name, useCooldownBar, BlockPooky.config.cooldownbar[name].type)
    end
end

local BlockPooky_cdBarActiveEndTime = {}
function BlockPooky.showCDbar(name, beginTime, endTime)
    local showed = false;
    local barActiveEndTime = BlockPooky_cdBarActiveEndTime[name]
    if barActiveEndTime == nil then
        barActiveEndTime = 0
    end
    if endTime > barActiveEndTime then
        showed = true;
        BlockPooky_cdBarActiveEndTime[name] = endTime
        local duration = endTime - beginTime
        local cooldownbar = BlockPooky.cooldownbar[name]
        if cooldownbar.bar ~=nil then
            cooldownbar.statusBar:SetMinMax(0, duration)
            cooldownbar.statusBar:SetValue(duration)
            cooldownbar.label:SetText(name) -- Text über dem Balken
            cooldownbar.bar:SetHidden(false)
        end
        -- Update function for the cooldown bar - CLOSURE PATTERN EXPLANATION:
        -- This is an Immediately Invoked Function Expression (IIFE) closure that creates
        -- a unique update function for each cooldown bar. The pattern works as follows:
        --
        -- 1. (function(name) ... end)(name) - IIFE that captures the current 'name' value
        -- 2. The inner 'function inner()' has access to the captured 'name' variable
        -- 3. This prevents all bars from sharing the same 'name' reference
        -- 4. Each bar gets its own dedicated update function with its specific name
        --
        -- Without this closure pattern, all bars would reference the final 'name' value
        -- from the loop, causing incorrect behavior where all bars update the same UI element.
        EVENT_MANAGER:RegisterForUpdate(BlockPooky.name..name.."UpdateCDBar", 50, (function(name)
                function inner()
                    local remaining = BlockPooky_cdBarActiveEndTime[name] - GetGameTimeSeconds()
                    local cooldownbar = BlockPooky.cooldownbar[name]
                    if cooldownbar~=nil then
                        if remaining <= 0 then
                            cooldownbar.bar:SetHidden(not BlockPooky.config.lockedUI)
                            EVENT_MANAGER:UnregisterForUpdate(BlockPooky.name..name.."UpdateCDBar")
                        else
                            cooldownbar.statusBar:SetValue(remaining)
                        end
                    end
                end
                return inner
            end)(name)  -- The 'name' parameter is passed to and captured by the IIFE
        )
    end 
    return showed
end

--[[ event handling - factory closure patterns ---------------------------------------------------------------------]]

--[[
    FACTORY CLOSURE PATTERN - OnCooldownAbilityEventClosure
    
    This is a "factory function" that creates customized event handlers for each cooldown bar.
    The closure pattern solves a critical problem in dynamic event handling:
    
    PROBLEM: Each cooldown bar needs its own EVENT_COMBAT_EVENT handler, but they must
    remember which specific bar (name) they belong to when the event fires.
    
    SOLUTION: This factory function takes a 'name' parameter and returns a specialized
    event handler that has "captured" that specific name in its closure scope.
    
    HOW IT WORKS:
    1. BlockPooky:OnCooldownAbilityEventClosure("MyBar") is called
    2. The 'name' parameter ("MyBar") is captured in the closure
    3. An inner function OnCooldownAbilityEvent is created with access to that 'name'
    4. The inner function is returned and used as the actual event handler
    5. When events fire, the handler knows it belongs to "MyBar" specifically
    
    BENEFITS:
    - Each cooldown bar gets its own dedicated event handler
    - No global state or lookup tables needed
    - Clean separation - each handler only processes its own bar's events
    - Memory efficient - handlers are created only when bars are configured
    
    USAGE EXAMPLE:
    local myBarHandler = BlockPooky.OnCooldownAbilityEventClosure("MyBar")
    EVENT_MANAGER:RegisterForEvent("MyBarWatcher", EVENT_COMBAT_EVENT, myBarHandler)
--]]
---Creates a specialized EVENT_COMBAT_EVENT handler for a specific cooldown bar
---@param name string the name of the cooldown bar this handler belongs to
---@return function event handler function that captures the bar name
function BlockPooky.OnCooldownAbilityEventClosure(name)
    function OnCooldownAbilityEvent(
        eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
        sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType,
        combat_log, sourceUnitId, targetUnitId, abilityId)
        local cleanSourceName = BlockPooky.CleanupName(sourceName)
        -- local cleanAbilityName = BlockPooky.CleanupName(abilityName)
        if cleanSourceName == BlockPooky.player or cleanSourceName ~= BlockPooky.companionName then
            -- Access the specific cooldown bar config using the captured 'name'
            local config = BlockPooky.config.cooldownbar[name]
            if config~=nil then
                if abilityId == tonumber(config.abilityId) then
                    if result == ACTION_RESULT_EFFECT_GAINED then
                        beginTime = GetGameTimeSeconds()
                        endTime = beginTime + config.cooldown
                        BlockPooky.showCDbar(name, beginTime, endTime)
                    elseif result == ACTION_RESULT_EFFECT_FADED then
                        BlockPooky.cooldownbar[name].bar:SetHidden(not BlockPooky.config.lockedUI)
                        EVENT_MANAGER:UnregisterForUpdate(BlockPooky.name..name.."UpdateCDBar")
                    end
                end
            end
        end
    end
    return OnCooldownAbilityEvent  -- Return the closure with captured 'name'
end

--[[
    FACTORY CLOSURE PATTERN - OnCooldownEffectClosure
    
    This is the companion factory function for EVENT_EFFECT_CHANGED handlers.
    It follows the same closure pattern as OnCooldownAbilityEventClosure but handles
    effect-based cooldown bars instead of ability-based ones.
    
    KEY DIFFERENCES FROM ABILITY HANDLER:
    - Listens to EVENT_EFFECT_CHANGED instead of EVENT_COMBAT_EVENT
    - Uses effect begin/end times when available
    - Falls back to configured cooldown if begin == end (some effects don't provide duration)
    - Handles EFFECT_RESULT_GAINED/FADED instead of ACTION_RESULT_EFFECT_GAINED/FADED
    
    SAME CLOSURE BENEFITS:
    - Each effect-based cooldown bar gets its own dedicated handler
    - The 'name' parameter is captured and available when events fire
    - Clean separation between different bars
    - No cross-contamination between different effect trackers
--]]
---Creates a specialized EVENT_EFFECT_CHANGED handler for a specific cooldown bar
---@param name string the name of the cooldown bar this handler belongs to
---@return function event handler function that captures the bar name
function BlockPooky.OnCooldownEffectClosure(name)
    function OnCooldownEffectEvent(
        eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount,
        iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
        if unitTag ~= "player" then return end -- Only relevant for the player
        -- Access the specific cooldown bar config using the captured 'name'
        local config = BlockPooky.config.cooldownbar[name]
        if config~=nil then
            if abilityId == tonumber(config.abilityId) then
                if changeType == EFFECT_RESULT_GAINED then
                    -- Some effects don't provide duration (beginTime == endTime)
                    -- In those cases, use the configured cooldown duration
                    if beginTime == endTime then
                        endTime = beginTime + config.cooldown
                    end
                    BlockPooky.showCDbar(name, beginTime, endTime)
                elseif changeType == EFFECT_RESULT_FADED then
                    BlockPooky.cooldownbar[name].bar:SetHidden(not BlockPooky.config.lockedUI)
                    EVENT_MANAGER:UnregisterForUpdate(BlockPooky.name..name.."UpdateCDBar")
                end
            end
        end
    end
    return OnCooldownEffectEvent  -- Return the closure with captured 'name'
end  