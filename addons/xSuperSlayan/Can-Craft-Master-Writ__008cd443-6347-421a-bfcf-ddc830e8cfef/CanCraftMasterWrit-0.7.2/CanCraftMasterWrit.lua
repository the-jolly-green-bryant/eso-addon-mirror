-- CanCraftMasterWrit - Production Version
-- Shows Master Writ craftability in tooltips using LibCharacterKnowledge integration

local ADDON_NAME = "CanCraftMasterWrit"

-- Load version configuration
local VERSION_CONFIG = _G.CanCraftMasterWritVersion or { VERSION = "Beta" }

-- 🎛️ GLOBAL DEBUG CONTROL - Set to FALSE to disable ALL debug output
local GLOBAL_DEBUG_ENABLED = false  -- Change to FALSE to disable all debugging

-- TEXTURE ICONS
-- esoui/art/hud/gamepad/gp_radialicon_accept_down.dds      => Craftable
-- esoui/art/hud/gamepad/gp_radialicon_cancel_down.dds      => Not Craftable

-- Global addon object for external access
_G.CanCraftMasterWrit = {
    debugEnabled = GLOBAL_DEBUG_ENABLED,
    
    -- Global function to enable/disable all debugging
    SetGlobalDebug = function(enabled)
        GLOBAL_DEBUG_ENABLED = enabled
        _G.CanCraftMasterWrit.debugEnabled = enabled
        
        -- Update DebugLog function globally
        if enabled then
            _G.DebugLog = function(message)
                if message then
                    d("[CanCraftMasterWrit] " .. tostring(message))
                end
            end
        else
            _G.DebugLog = function(message) 
                -- Silent - no output when debugging disabled
            end
        end
        
        -- Notify user of debug state change
        d("|cFFFF00[CanCraftMasterWrit] Global Debug " .. (enabled and "|c00FF00ENABLED|r" or "|cFF0000DISABLED|r"))
    end,
    
    -- Quick debug status check
    IsDebugEnabled = function()
        return GLOBAL_DEBUG_ENABLED
    end
}

-- Initialize DebugLog function based on current debug state
if GLOBAL_DEBUG_ENABLED then
    _G.DebugLog = function(message)
        if message then
            d("[CanCraftMasterWrit] " .. tostring(message))
        end
    end
else
    _G.DebugLog = function(message) 
        -- Silent - no debug output
    end
end

-- State tracking
local librariesInitialized = false

-- Font styles for console optimization
local largeFontStyle = { fontSize = 36, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1 }
local mediumFontStyle = { fontSize = 28, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1 }
local smallFontStyle = { fontSize = 22, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_2 }
local paddingStyle = { fontSize = 30, }  -- Adds padding for spacing
local paddingStyleSM = { fontSize = 3, }  -- Adds padding for spacing

-- Get MasterWritCore reference
local function GetMasterWritCore()
    return _G.MasterWritCore
end

-- Get LibraryManager reference
local function GetLibraryManager()
    return _G.LibraryManager
end

-- Initialize libraries using proper LibCharacterKnowledge callback pattern
local function InitializeLibraries()
    if librariesInitialized then return true end

    -- Check if LibraryManager is available
    local libManager = _G.LibraryManager
    if not libManager then
        DebugLog("LibraryManager not available")
        return false
    end

    -- Try to initialize libraries using EVENT_INITIALIZED callback
    local success, message = libManager.Initialize()
    
    DebugLog("Library initialization: " .. message)

    if success then
        librariesInitialized = true
    end

    return success
end

-- Unified function to add Master Writ craftability info to any tooltip
local function AddMasterWritInfo(tooltip, itemLink, debugSource)
    if not itemLink or not tooltip or not tooltip.AddLine then
        return
    end

    -- Check if this is a Master Writ
    local isMasterWrit = false
    if GetItemLinkItemType and ITEMTYPE_MASTER_WRIT then
        isMasterWrit = (GetItemLinkItemType(itemLink) == ITEMTYPE_MASTER_WRIT)
    else
        -- Fallback to name checking if ESO API not available
        local itemName = GetItemLinkName(itemLink)
        isMasterWrit = itemName and (string.find(itemName, "Master") and string.find(itemName, "Writ")) or false
    end

    if not isMasterWrit then
        return
    end

    local MasterWritCore = GetMasterWritCore()

    -- Parse Master Writ requirements
    local requirements = MasterWritCore.ParseMasterWritTooltip(itemLink, nil)
    local requiredStyle = requirements and requirements.style
    local isJewelry = requirements and requirements.craftType == "jewelry"
    local isProvisioning = requirements and requirements.craftType == "provisioning"

    -- Fallback parsing if ESO API method failed  
    if not requiredStyle and not isJewelry and not isProvisioning then
        local itemName = GetItemLinkName(itemLink)
        if itemName then
            local styleMatch = string.match(itemName, "%(([^%)]*)")
            if styleMatch then
                local firstWord = string.match(styleMatch, "^([^%s]+)")
                if firstWord then
                    requiredStyle = firstWord
                end
            end
        end
    end

    -- Add spacing before our section
    tooltip:AddLine(" ", paddingStyle)

    if requiredStyle or isJewelry or isProvisioning then
        -- Check craftability components
        local styleKnown = true -- Default to true for jewelry/provisioning (no styles)
        local motifPageKnown = true -- Default to true for jewelry/provisioning (no motifs)
        local traitKnown = true -- Default to true if no trait required
        local setCraftable = true -- Default to true if no set required
        local setStatus = nil -- Set status message
        local recipeKnown = true -- Default to true for non-provisioning
        local skillsOk = true -- Default to true for non-provisioning
        local missingSkills = nil -- For provisioning skill requirements
        local canCraft = false

        if requirements then
            -- Provisioning-specific checks
            if isProvisioning then
                if requirements.recipe then
                    recipeKnown = MasterWritCore.IsProvisioningRecipeKnown(requirements.recipe)
                    skillsOk, missingSkills = MasterWritCore.IsProvisioningSkillSufficient(requirements.recipe, requirements.quality)
                end
                -- For provisioning, only recipe and skills matter
                canCraft = recipeKnown and skillsOk
            else
                -- Equipment/jewelry-specific checks
                -- Only check style/motifs for non-jewelry writs
                if not isJewelry then
                    -- Check overall style knowledge
                    styleKnown = MasterWritCore.IsStyleKnown(requiredStyle, nil)

                    -- Check specific motif page knowledge
                    if requirements.itemType then
                        motifPageKnown = MasterWritCore.IsMotifPageKnown(requiredStyle, requirements.itemType, nil)
                    else
                        motifPageKnown = styleKnown
                    end
                end

                -- Check trait research
                if requirements.trait and requirements.craftType then
                    traitKnown = MasterWritCore.IsTraitKnown(requirements.trait, requirements.craftType,
                        requirements.itemType, nil)
                end

                -- Check set craftability (with error handling)
                if requirements.set and requirements.set ~= "" and string.len(requirements.set) > 2 then
                    DebugLog("Found set in requirements: " .. tostring(requirements.set))
                    local success, craftable, status = pcall(MasterWritCore.IsSetCraftable, requirements.set, requirements.itemType, requirements.craftType)
                    
                    if success then
                        setCraftable = craftable
                        setStatus = status
                        if setCraftable == nil then
                            setCraftable = false
                        end
                    else
                        DebugLog("Error checking set craftability: " .. tostring(craftable))
                        setCraftable = false
                        setStatus = "Error"
                    end
                else
                    DebugLog("No valid set found in requirements")
                    setCraftable = true  -- No set requirement means set check passes
                end

                -- Calculate final craftability: all required checks must pass
                if requirements.set and requirements.set ~= "" and string.len(requirements.set) > 2 then
                    canCraft = styleKnown and motifPageKnown and traitKnown and setCraftable
                else
                    canCraft = styleKnown and motifPageKnown and traitKnown
                end
            end
        else
            -- Fallback to basic style checking
            styleKnown = MasterWritCore.IsStyleKnown(requiredStyle, nil)
            motifPageKnown = styleKnown
            canCraft = styleKnown
        end

        -- CONSOLE-OPTIMIZED: Craftability status is handled by AddMasterWritHeaderInfo
        -- (removed duplicate display to prevent two headers)

        -- STATUS DETAILS
        if isProvisioning then
            -- Provisioning-specific status display (NO duplicate header)
            -- Show recipe knowledge status
            if requirements and requirements.recipe then
                if recipeKnown then
                    tooltip:AddLine("|c00FF00RECIPE KNOWN|r", smallFontStyle)
                else
                    tooltip:AddLine("|cFF0000MISSING RECIPE|r", smallFontStyle)
                end
            end

            -- Show skill requirement status with specific details
            if requirements and requirements.recipe then
                if skillsOk then
                    tooltip:AddLine("|c00FF00SKILLS LEARNED|r", smallFontStyle)
                else
                    tooltip:AddLine("|cFF0000INSUFFICIENT SKILLS|r", smallFontStyle)
                    -- Show specific missing skill requirements
                    if missingSkills and type(missingSkills) == "table" then
                        for _, skillRequirement in ipairs(missingSkills) do
                            if skillRequirement and type(skillRequirement) == "string" then
                                tooltip:AddLine("|cFFFF00".. skillRequirement .."|r", smallFontStyle)
                            else
                                tooltip:AddLine("|cFFFF00MISSING SKILL(S)|r", smallFontStyle)
                            end
                        end
                    end
                end
            end
        else
            -- MOTIF KNOWN/UNKNOWN TOOLTIP TEXT
            if not isJewelry then
                if motifPageKnown then
                    tooltip:AddLine("|c00FF00MOTIF PAGE KNOWN|r", smallFontStyle)
                else
                    tooltip:AddLine("|cFF0000MOTIF PAGE MISSING|r", smallFontStyle)
                end
            end

            -- SET RESEARCH TOOLTIP TEXT
            if requirements and requirements.trait then
                if traitKnown then
                    tooltip:AddLine("|c00FF00TRAIT RESEARCHED|r", smallFontStyle)
                else
                    tooltip:AddLine("|cFF0000TRAIT NOT RESEARCHED|r", smallFontStyle)
                end
            end

            -- SET CRAFTABLE / NOT CRAFTABLE TOOLTIP TEXT
            -- Display set craftability status (only for writs with actual set requirements)
            if requirements and requirements.set and requirements.set ~= "" and string.len(requirements.set) > 2 then
                if setCraftable then
                    tooltip:AddLine("|c00FF00SET CRAFTABLE (" .. (setStatus or "ready") .. ")|r", smallFontStyle)
                else
                    tooltip:AddLine("|cFF0000SET NOT CRAFTABLE (" .. (setStatus or "try again later") .. ")|r", smallFontStyle)
                end
            end
        end
    else
        -- Fallback if we can't determine requirements
        tooltip:AddLine("|c00FF00Feature Under Development|r", largeFontStyle)
        tooltip:AddLine("Coming soon!", smallFontStyle)
    end
end

-- /// TOOLTIP HEADER CRAFTABILITY STATUS ///
-- Adds a single-line craftability status between title and body of the tooltip
local function AddMasterWritHeaderInfo(tooltip, itemLink, debugSource)
    if not itemLink or not tooltip or not tooltip.AddLine then
        return
    end

    -- Check if this is a Master Writ
    local isMasterWrit = false
    if GetItemLinkItemType and ITEMTYPE_MASTER_WRIT then
        isMasterWrit = (GetItemLinkItemType(itemLink) == ITEMTYPE_MASTER_WRIT)
    else
        -- Fallback to name checking if ESO API not available
        local itemName = GetItemLinkName(itemLink)
        isMasterWrit = itemName and (string.find(itemName, "Master") and string.find(itemName, "Writ")) or false
    end

    if not isMasterWrit then
        return
    end

    local MasterWritCore = GetMasterWritCore()

    -- Parse Master Writ requirements
    local requirements = MasterWritCore.ParseMasterWritTooltip(itemLink, nil)
    local requiredStyle = requirements and requirements.style
    local isJewelry = requirements and requirements.craftType == "jewelry"
    local isProvisioning = requirements and requirements.craftType == "provisioning"

    -- Fallback parsing if ESO API method failed  
    if not requiredStyle and not isJewelry and not isProvisioning then
        local itemName = GetItemLinkName(itemLink)
        if itemName then
            local styleMatch = string.match(itemName, "%(([^%)]*)")
            if styleMatch then
                local firstWord = string.match(styleMatch, "^([^%s]+)")
                if firstWord then
                    requiredStyle = firstWord
                end
            end
        end
    end

    if requiredStyle or isJewelry or isProvisioning then
        -- Check craftability components
        local styleKnown = true -- Default to true for jewelry/provisioning (no styles)
        local motifPageKnown = true -- Default to true for jewelry/provisioning (no motifs)
        local traitKnown = true -- Default to true if no trait required
        local setCraftable = true -- Default to true if no set required
        local setStatus = nil -- Set status message
        local recipeKnown = true -- Default to true for non-provisioning
        local skillsOk = true -- Default to true for non-provisioning
        local canCraft = false

        if requirements then
            -- // PROVISIONING
            if isProvisioning then
                if requirements.recipe then
                    recipeKnown = MasterWritCore.IsProvisioningRecipeKnown(requirements.recipe)
                    skillsOk, _ = MasterWritCore.IsProvisioningSkillSufficient(requirements.recipe, requirements.quality)
                end
                -- For provisioning, only recipe and skills matter
                canCraft = recipeKnown and skillsOk
            else
                -- // JEWELRY
                -- Only check style/motifs for non-jewelry writs
                if not isJewelry then
                    -- Check overall style knowledge
                    styleKnown = MasterWritCore.IsStyleKnown(requiredStyle, nil)

                    -- Check specific motif page knowledge
                    if requirements.itemType then
                        motifPageKnown = MasterWritCore.IsMotifPageKnown(requiredStyle, requirements.itemType, nil)
                    else
                        motifPageKnown = styleKnown
                    end
                end

                -- Check trait research
                if requirements.trait and requirements.craftType then
                    traitKnown = MasterWritCore.IsTraitKnown(requirements.trait, requirements.craftType,
                        requirements.itemType, nil)
                end

                -- Check set craftability (with error handling)
                if requirements.set and requirements.set ~= "" and string.len(requirements.set) > 2 then
                    DebugLog("Found set in requirements: " .. tostring(requirements.set))
                    local success, craftable, status = pcall(MasterWritCore.IsSetCraftable, requirements.set, requirements.itemType, requirements.craftType)
                    
                    if success then
                        setCraftable = craftable
                        setStatus = status
                        if setCraftable == nil then
                            setCraftable = false
                        end
                    else
                        DebugLog("Error checking set craftability: " .. tostring(craftable))
                        setCraftable = false
                        setStatus = "Error"
                    end
                else
                    DebugLog("No valid set found in requirements")
                    setCraftable = true  -- No set requirement means set check passes
                end

                -- Calculate final craftability: all required checks must pass
                if requirements.set and requirements.set ~= "" and string.len(requirements.set) > 2 then
                    canCraft = styleKnown and motifPageKnown and traitKnown and setCraftable
                else
                    canCraft = styleKnown and motifPageKnown and traitKnown
                end
            end
        else
            -- Fallback to basic style checking
            styleKnown = MasterWritCore.IsStyleKnown(requiredStyle, nil)
            motifPageKnown = styleKnown
            canCraft = styleKnown
        end

        -- HEADER PLACEMENT: Add craftability status between title and body (no spacing, direct injection)
        if canCraft then
            tooltip:AddLine("|t24:24:esoui/art/hud/gamepad/gp_radialicon_accept_down.dds|t|r |c00FF00CRAFTABLE|r", mediumFontStyle)
        else
            tooltip:AddLine("|t24:24:esoui/art/hud/gamepad/gp_radialicon_cancel_down.dds|t|r |cFF0000CANNOT CRAFT|r", mediumFontStyle)
        end
    else
        -- Fallback if we can't determine requirements
        tooltip:AddLine("|cFF0000WRIT STATUS UNKNOWN|r", mediumFontStyle)
    end
end

-- Enhanced tooltip hook for Master Writs
local function SetupMasterWritTooltips()
    -- Hook inventory tooltips - use gamepad-specific approach
    if GAMEPAD_TOOLTIPS and GAMEPAD_TOOLTIPS.LayoutItemWithHeader then
        -- Prevent double-hooking
        if _G.CCMWGamepadTooltipHooked then
            return
        end

        -- Hook the gamepad tooltip system directly
        local origLayoutItemWithHeader = GAMEPAD_TOOLTIPS.LayoutItemWithHeader
        GAMEPAD_TOOLTIPS.LayoutItemWithHeader = function(tooltip, tooltipType, header, itemLink, ...)
            -- FIRST: Add header craftability status (between title and body)
            if itemLink then
                AddMasterWritHeaderInfo(tooltip, itemLink, "gamepad-header")
            end
            
            local result = origLayoutItemWithHeader(tooltip, tooltipType, header, itemLink, ...)

            -- SECOND: Add detailed Master Writ craftability info to gamepad tooltips (at bottom)
            if itemLink then
                AddMasterWritInfo(tooltip, itemLink, "gamepad-bottom")
            end

            return result
        end

        -- Mark as hooked
        _G.CCMWGamepadTooltipHooked = true
    end

    -- Also hook the standard ZO_Tooltip for non-gamepad contexts
    if ZO_Tooltip and ZO_Tooltip.LayoutBagItem then
        -- Prevent double-hooking
        if _G.CCMWTooltipHooked then
            return
        end

        local origLayoutBagItem = ZO_Tooltip.LayoutBagItem
        ZO_Tooltip.LayoutBagItem = function(tooltip, bagId, slotIndex, ...)
            -- FIRST: Add header craftability status (between title and body)
            local itemLink = GetItemLink(bagId, slotIndex)
            if itemLink then
                AddMasterWritHeaderInfo(tooltip, itemLink, "bag-header")
            end
            
            -- Second: Call the original function to add the standard tooltip content
            local result = origLayoutBagItem(tooltip, bagId, slotIndex, ...)

            -- THIRD: Add detailed Master Writ craftability info (at bottom)
            AddMasterWritInfo(tooltip, itemLink, "bag-bottom")

            return result
        end

        -- Mark as hooked
        _G.CCMWTooltipHooked = true
    end

    -- Hook guild store/trading house tooltips
    local tradingHouseFunctions = {
        "LayoutGuildStoreSearchResult",
        "LayoutStoreWindowItem",
        "LayoutStoreItemFromLink",
        "LayoutTradingHouseItem",
        "LayoutStoreItem",
        "LayoutGuildStoreItem",
        "LayoutSearchResultItem"
    }

    for _, funcName in ipairs(tradingHouseFunctions) do
        if ZO_Tooltip and ZO_Tooltip[funcName] then
            -- Prevent double-hooking
            local hookVar = "_CCMW" .. funcName .. "Hooked"
            if _G[hookVar] then
                break
            end

            local origFunc = ZO_Tooltip[funcName]
            ZO_Tooltip[funcName] = function(tooltip, ...)
                -- Try to get item link - parameters vary by function
                local itemLink = nil
                local args = { ... }

                -- Try different approaches to get the item link with error handling
                if funcName == "LayoutTradingHouseItem" and args[1] and type(args[1]) == "number" then
                    local success, result = pcall(GetTradingHouseSearchResultItemLink, args[1])
                    if success then itemLink = result end
                elseif funcName == "LayoutGuildStoreSearchResult" and args[1] and type(args[1]) == "number" then
                    -- For guild store search results, try getting from search result index
                    local success, result = pcall(GetTradingHouseSearchResultItemLink, args[1])
                    if success then itemLink = result end
                elseif funcName == "LayoutStoreItemFromLink" and args[1] then
                    -- This function likely takes the item link directly
                    if type(args[1]) == "string" and string.find(args[1], "|H") then
                        itemLink = args[1]
                    end
                elseif funcName == "LayoutStoreWindowItem" and args[1] and args[2] then
                    -- This might be store slot index
                    if type(args[1]) == "number" and type(args[2]) == "number" then
                        local success, result = pcall(GetStoreItem, args[1], args[2])
                        if success then itemLink = result end
                    end
                elseif args[2] and type(args[2]) == "string" and string.find(args[2], "|H") then
                    itemLink = args[2] -- Item link might be the second parameter
                elseif args[1] and type(args[1]) == "string" and string.find(args[1], "|H") then
                    itemLink = args[1] -- Item link might be the first parameter
                end

                -- FIRST: Add header craftability status (before ESO builds tooltip)
                if itemLink then
                    AddMasterWritHeaderInfo(tooltip, itemLink, funcName .. "-header")
                end

                -- SECOND: Call the original function to build standard tooltip
                local result = origFunc(tooltip, ...)

                -- THIRD: Add detailed Master Writ craftability info (after ESO builds tooltip)
                if itemLink then
                    AddMasterWritInfo(tooltip, itemLink, funcName .. "-bottom")
                end

                return result
            end

            -- Mark this function as hooked
            _G[hookVar] = true
        end
    end
end

-- Register essential slash commands
local function RegisterSlashCommands()
    SLASH_COMMANDS = SLASH_COMMANDS or {}

    -- Essential production commands only
    SLASH_COMMANDS["/ru"] = function()
        ReloadUI()
    end

    -- Global debug control commands (production feature)
    SLASH_COMMANDS["/ccdebugon"] = function()
        _G.CanCraftMasterWrit.SetGlobalDebug(true)
    end
    
    SLASH_COMMANDS["/ccdebugoff"] = function()
        _G.CanCraftMasterWrit.SetGlobalDebug(false)
    end
    
    SLASH_COMMANDS["/ccdebugstatus"] = function()
        local status = _G.CanCraftMasterWrit.IsDebugEnabled()
        d("|cFFFF00[CanCraftMasterWrit] Global Debug Status: " .. (status and "|c00FF00ENABLED|r" or "|cFF0000DISABLED|r"))
    end

    -- Load extended debugging commands from SlashCommands module
    if _G.SlashCommands and _G.SlashCommands.RegisterCommands then
        _G.SlashCommands.RegisterCommands(_G.DebugLog, nil)
        DebugLog("Extended slash commands loaded from SlashCommands module")
    else
        DebugLog("SlashCommands module not found - only basic commands available")
    end
end

-- Make tooltip setup function global for LibCharacterKnowledge callback access
_G.SetupMasterWritTooltips = SetupMasterWritTooltips

-- Main addon initialization with proper LibCharacterKnowledge callback pattern
local function OnPlayerActivated()
    DebugLog("Player activated - initializing libraries with EVENT_INITIALIZED callback")
    
    -- Use the proper LibCharacterKnowledge initialization pattern
    local success, message = InitializeLibraries()
    DebugLog("Library initialization: " .. tostring(message))
    
    -- If library is ready immediately, setup tooltips
    if success then
        SetupMasterWritTooltips()
    end
    -- Otherwise, tooltips will be setup automatically by the EVENT_INITIALIZED callback
end

-- Event handler for addon loading
local function OnAddonLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end

    RegisterSlashCommands()
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

-- Rainbow loading message for console visibility
local function LoadedMessage()
d(
    -- "|cFF0000C|r|cFF4000a|r|cFF8000n|r|cFFFF00C|r|c80FF00r|r|c00FF00a|r|c00FF80f|r|c00FFFFt|r|c0080FFM|r|c0000FFa|r|c8000FFs|r|cFF00FFt|r|cFF0080e|r|cFF0000r|r|cFF8000W|r|cFFFF00r|r|c80FF00i|r|c00FF00t|r v" .. (VERSION_CONFIG.VERSION or "0.6") .. " |c00FF00Loaded!|r")
"|c450693C|r|c8C00FFa|r|cFF3F7Fn|r|cFFC400C|r|c450693r|r|c8C00FFa|r|cFF3F7Ff|r|cFFC400t|r|c450693M|r|c8C00FFa|r|cFF3F7Fs|r|cFFC400t|r|c450693e|r|c8C00FFr|r|cFF3F7FW|r|cFFC400r|r|c450693i|r|c8C00FFt|r v" .. (VERSION_CONFIG.VERSION or "BETA") .. " |c00FF00Loaded!|r")
end

-- Display loading message after everything is initialized
local function OnPlayerActivatedWithMessage()
    OnPlayerActivated()
    LoadedMessage()
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_Message", EVENT_PLAYER_ACTIVATED)
end

-- Register the addon loaded event
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Message", EVENT_PLAYER_ACTIVATED, OnPlayerActivatedWithMessage)