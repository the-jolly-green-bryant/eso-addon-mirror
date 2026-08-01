--------------------------------------------------------------------------------
-- PerfectedWeave menu.lua 
-- =============================================================================
-- AddOn Name:        PerfectedWeave
-- Description:       Advanced configuration menu system for PerfectedWeave AddOn
-- Authors:           Orollas, VollständigerName, mYoda01
-- Version:           1.2.0
-- Dependencies:      LibAddonMenu-2.0
-- =============================================================================
-- =============================================================================
-- === PERFECTEDWEAVE CONFIGURATION MENU (menu.lua) =============================
-- =============================================================================
--[[
    Features:
    - Gold-themed color scheme
    - Flat information section
    - Divider-based layout
    - Simplified dropdown structure
--]]
-- =============================================================================

local PW = PerfectedWeave
local LAM = LibAddonMenu2
local PWColoredName = " PerfectedWeave "
local valueMode
-- =============================================================================
-- == COLOR SCHEMA DEFINITION ==================================================
-- =============================================================================
--[[
    Purpose: Centralized color management for UI consistency
    Color Codes:
    - PRIMARY: Main text (Light Gray |cD4D4D4)
    - SECONDARY: Secondary text (Medium Gray |cA6A6A6)
    - ACCENT: Gold accent (Gold |c948159)
    - WARNING: Error/alert text (Red |cFF5555)
    - DISABLED: Disabled state (Dark Gray |c666666)
    - BORDER: UI borders (Very Dark Gray |c3C3C3C)
--]]
local COLOR = {
    PRIMARY    = "|cD4D4D4",   -- Main text
    SECONDARY  = "|cA6A6A6",   -- Secondary text
    ACCENT     = "|c948159",   -- Gold accent
    WARNING    = "|cFF5555",   -- Warnings
    DISABLED   = "|c666666",   -- Disabled
    BORDER     = "|c3C3C3C"    -- Borders
}

-- =============================================================================
-- == UI COMPONENT FACTORIES ===================================================
-- =============================================================================
--[[
    Purpose: Reusable component generators for menu consistency
    Features:
    - Standardized styling across all controls
    - Automatic color application
    - Localization integration
    - Dynamic enable/disable states
--]]

--------------------------------------------------------------------------------
-- Checkbox Control Factory
-- @param nameKey: Localization key for display name
-- @param tooltipKey: Localization key for tooltip text
-- @param PWgetFunc: Function to retrieve current value
-- @param PWsetFunc: Function to set new value
-- @param disabledFunc: Optional function to determine disabled state
-- @return: Fully configured checkbox table
--------------------------------------------------------------------------------
local function CreateCheckbox(nameKey, tooltipKey, PWgetFunc, PWsetFunc, disabledFunc, reloadUICheck)
    return {
        type = "checkbox",
        name = COLOR.PRIMARY..PW.L(nameKey),
        tooltip = COLOR.SECONDARY..PW.L(tooltipKey),
        getFunc = PWgetFunc,
        setFunc = PWsetFunc,
        width = "full",
        style = {
            paddingTop = 8,
            paddingBottom = 8,
            labelBeforeCheckbox = true
        },
        disabled = disabledFunc,
        requiresReload = reloadUICheck or false, 
    }
end

--------------------------------------------------------------------------------
-- Dropdown Control Factory
-- @param nameKey: Localization key for display name
-- @param tooltipKey: Localization key for tooltip text
-- @param choicesKeys: Table of localization keys for dropdown options
-- @param PWgetFunc: Function to retrieve current value
-- @param PWsetFunc: Function to set new value
-- @return: Fully configured dropdown table
--------------------------------------------------------------------------------
local function CreateDropdown(nameKey, tooltipKey, choicesKeys, PWgetFunc, PWsetFunc)
    local choices = {}
    for _, key in ipairs(choicesKeys) do
        table.insert(choices, COLOR.SECONDARY..PW.L(key))
    end
    
    return {
        type = "dropdown",
        name = COLOR.PRIMARY..PW.L(nameKey),
        tooltip = COLOR.SECONDARY..PW.L(tooltipKey),
        choices = choices,
        getFunc = PWgetFunc,
        setFunc = PWsetFunc,
        scrollable = true,
        width = "full",
        choicesValues = {4 ,1, 2, 3}
    }
end

--------------------------------------------------------------------------------
-- Slider Control Factory
-- @param nameKey: Localization key for display name
-- @param tooltipKey: Localization key for tooltip text
-- @param min: Minimum slider value
-- @param max: Maximum slider value
-- @param PWgetFunc: Function to retrieve current value
-- @param PWsetFunc: Function to set new value
-- @param disabledFunc: Optional function to determine disabled state
-- @return: Fully configured slider table
--------------------------------------------------------------------------------
local function CreateSlider(nameKey, tooltipKey, min, max, PWgetFunc, PWsetFunc, disabledFunc)
    return {
        type = "slider",
        name = COLOR.PRIMARY..PW.L(nameKey),
        tooltip = COLOR.SECONDARY..PW.L(tooltipKey),
        min = min,
        max = max,
        getFunc = PWgetFunc,
        setFunc = PWsetFunc,
        disabled = disabledFunc,
        width = "full",
        decimals = 0,
        clampInput = false
    }
end

-- =============================================================================
-- == MENU STRUCTURE COMPONENTS ================================================
-- =============================================================================
--[[
    Purpose: Visual organization elements for menu layout
    Features:
    - Consistent section headers
    - Themed dividers
    - Proper spacing and alignment
--]]

--------------------------------------------------------------------------------
-- Section Header Generator
-- @param text: Display text for section header
-- @return: Divider and description control pair
--------------------------------------------------------------------------------
local function CreateSectionHeader(text)
    return {
    --     type = "divider",
    --     alpha = 0.2
    -- }, {
        type = "description",
        --text = COLOR.ACCENT..text,
        fontSize = "medium"
    }
end

-- =============================================================================
-- == CREATE RELOAD CONFIRMATION DIALOG ========================================
-- =============================================================================
-- Create Reload Confirmation Dialog
-- Purpose: Registers a standardized UI dialog for requesting player confirmation
--          before performing a UI reload after settings changes.
-- Features:
-- - Reusable dialog system for consistent UX
-- - Localization support for all text elements
-- - Queue-aware to prevent dialog stacking
-- Architecture:
-- - Checks if dialog already registered to avoid duplicates
-- - Uses addon's color scheme for visual consistency
-- - Provides clear Yes/No options with appropriate callbacks
--------------------------------------------------------------------------------
ZO_Dialogs_RegisterCustomDialog("PW_RELOAD_DIALOG", {
    canQueue = true,
    title = {
        text = PWColoredName
    },
    mainText = {
        text = COLOR.PRIMARY .. PW.L("PW_MENU_RELOAD_DIALOG_MAIN_TEXT")
    },
    buttons = {
        {
            text = COLOR.ACCENT .. PW.L("PW_MENU_RELOAD_DIALOG_BUTTON_YES"),
            callback = function()
                ReloadUI() 
            end
        },
        {
            text = COLOR.SECONDARY .. PW.L("PW_MENU_RELOAD_DIALOG_BUTTON_LATER"),
            callback = function()
            end
        }
    }
})

-- =============================================================================
-- == CREATE ERROR CONFIRMATION DIALOG =========================================
-- =============================================================================


ZO_Dialogs_RegisterCustomDialog("PW_INVALID_ID_DIALOG", {
    canQueue = true,
    title = {
        text = PWColoredName
    },
    mainText = {
        text = COLOR.WARNING .. PW.L("PW_MENU_INVALID_ID_DIALOG_MAIN_TEXT")
    },
    buttons = {
        {
            text = COLOR.ACCENT .. PW.L("PW_MENU_DIALOG_BUTTON_OK"),
            callback = function()
            end
        }
    }
})

ZO_Dialogs_RegisterCustomDialog("PW_ID_NOT_EXIST_DIALOG", {
    canQueue = true,
    title = {
        text = PWColoredName
    },
    mainText = {
        text = COLOR.WARNING .. PW.L("PW_MENU_ID_NOT_EXIST_DIALOG_MAIN_TEXT")
    },
    buttons = {
        {
            text = COLOR.ACCENT .. PW.L("PW_MENU_DIALOG_BUTTON_OK"),
            callback = function()
            end
        }
    }
})

ZO_Dialogs_RegisterCustomDialog("PW_ID_IS_IN_SV_DIALOG", {
    canQueue = true,
    title = {
        text = PWColoredName
    },
    mainText = {
        text = COLOR.WARNING .. PW.L("PW_MENU_ID_IS_IN_SV_DIALOG_MAIN_TEXT")
    },
    buttons = {
        {
            text = COLOR.ACCENT .. PW.L("PW_MENU_DIALOG_BUTTON_OK"),
            callback = function()
            end
        }
    }
})

-- =============================================================================
-- == MAIN MENU CONSTRUCTION ===================================================
-- =============================================================================
--[[
    Function: PW.BuildMenu
    Purpose: Construct complete configuration interface
    Process Flow:
    1. Create main panel definition
    2. Register panel with LibAddonMenu
    3. Build hierarchical options structure
    4. Register all control elements
    
    Architecture:
    - Flat information section
    - Core mechanics submenu
    - Activation conditions submenu
    - Advanced controls submenu
    - Subclass-specific settings submenu
    - Performance settings submenu
    - Legal disclaimer
--]]
-- Main panel definition
local function BuildMenu(PWSV, defaults)
    local panel = {
        type = "panel",
        name = PW.name,
        displayName = COLOR.ACCENT..PW.L("PW_MENU_PANEL_NAME"),
        author = COLOR.SECONDARY..PW.L("PW_MENU_AUTHORS"),
        version = COLOR.PRIMARY..PW.version,
        website = PW.L("PW_MENU_WEBSITE"),
        registerForRefresh = true,
        --registerForDefaults = true,
        slashCommand = "/perfectedweave",
    }

    -- =============================================================================
    -- == BLOCK LIST MENU ==========================================================
    -- =============================================================================
    --[[
        Function: AddSpellToBlockList
        Purpose: Adds a spell to the block list.
        Features:
        - Checks whether spell exists
        - Prevents duplicates.
        - Saves directly to PWSV.customBlockList.
    --]]
    local function AddSpellToBlockList()
        --local spellId = tonumber(_G["PW_TEMP_SPELL_ID"])
        local spellId = tonumber(PW.TEMP_SPELL_ID) 
        
        -- Check whether a valid ID has been entered
        if not spellId or spellId <= 1000 or spellId >= 500000 then
            ZO_Dialogs_ShowDialog("PW_INVALID_ID_DIALOG")
            return
        end
        
        -- Check if Spell exists 
        local AbilityName = GetAbilityName(spellId)
        if AbilityName == nil or AbilityName == "" then
            ZO_Dialogs_ShowDialog("PW_ID_NOT_EXIST_DIALOG")
            --d(PWColoredName.."Error: Spell-ID " .. spellId .. " does not exist")
            return
        end
        
        -- Prevent duplicates
        if PWSV.customBlockList[spellId] ~= nil then
            ZO_Dialogs_ShowDialog("PW_ID_IS_IN_SV_DIALOG")
            --d(PWColoredName.."Note: Spell ID  " ..  spellId .. ", Spell " .. zo_strformat("<<1>>", AbilityName) .. " is already in the block list")
            return
        end
        
        -- Add Spell to block list
        PWSV.customBlockList[spellId] = false  -- Default: not blocked
        --_G["PW_TEMP_SPELL_ID"] = ""  -- Clear input field
        PW.TEMP_SPELL_ID = ""
        ZO_Dialogs_ShowDialog("PW_RELOAD_DIALOG")
        --d(PWColoredName.."Spell-ID " .. spellId .. ", Spell " .. zo_strformat("<<1>>", AbilityName) .. " has been added to the block list")
    end

    -- =============================================================================
    -- == RECAST BLOCK LIST MENU ===================================================
    -- =============================================================================
    --[[
        Function: AddSpellToRecastBlockList
        Purpose: Adds a spell to the recast block list.
        Features:
        - Checks whether spell exists
        - Prevents duplicates
        - Saves directly to PWSV.customRecastBlockList
    --]]
    local function AddSpellToRecastBlockList()
        --local spellId = tonumber(_G["PW_TEMP_RECAST_SPELL_ID"])
        local spellId = tonumber(PW.TEMP_RECAST_SPELL_ID)
        
        -- Check whether a valid ID has been entered
        if not spellId or spellId <= 1000 or spellId >= 500000 then
            ZO_Dialogs_ShowDialog("PW_INVALID_ID_DIALOG")
            return
        end
        
        -- Check if Spell exists 
        local AbilityName = GetAbilityName(spellId)
        if AbilityName == nil or AbilityName == "" then
            ZO_Dialogs_ShowDialog("PW_ID_NOT_EXIST_DIALOG")
            --d(PWColoredName.."Error: Spell-ID " .. spellId .. " does not exist")
            return
        end
        
        -- Prevent duplicates
        if PWSV.customRecastBlockList[spellId] ~= nil then
            ZO_Dialogs_ShowDialog("PW_ID_IS_IN_SV_DIALOG")
            --d(PWColoredName.."Note: Spell ID  " ..  spellId .. ", Spell " .. zo_strformat("<<1>>", AbilityName) .. " is already in the block list")
            return
        end
        
        -- Add Spell to block list
        PWSV.customRecastBlockList[spellId] = false  -- Default: not blocked
        PW.TEMP_RECAST_SPELL_ID = ""--_G["PW_TEMP_RECAST_SPELL_ID"] = ""  -- Clear input field
        ZO_Dialogs_ShowDialog("PW_RELOAD_DIALOG")
        --d(PWColoredName.."Spell-ID " .. spellId .. ", Spell " .. zo_strformat("<<1>>", AbilityName) .. " has been added to the block list")
    end

    -- =============================================================================
    -- == RESOURCE BLOCK LIST MENU =================================================
    -- =============================================================================
    --[[
        Function: AddSpellToResourceBlockList
        Purpose: Adds a spell to the block list.
        Features:
        - Checks whether spell exists
        - Prevents duplicates.
        - Saves directly to PWSV.customResourceBlockList.
    --]]
local function AddSpellToResourceBlockList()
    local spellId = tonumber(PW.TEMP_RESOURCE_SPELL_ID) 
    
    -- Check whether a valid ID has been entered
    if not spellId or spellId <= 1000 or spellId >= 500000 then
        ZO_Dialogs_ShowDialog("PW_INVALID_ID_DIALOG")
        return
    end
    
    -- Check if Spell exists 
    local AbilityName = GetAbilityName(spellId)
    if AbilityName == nil or AbilityName == "" then
        ZO_Dialogs_ShowDialog("PW_ID_NOT_EXIST_DIALOG")
        return
    end
    
    -- Prevent duplicates
    if PWSV.customResourceBlockList[spellId] ~= nil then
        ZO_Dialogs_ShowDialog("PW_ID_IS_IN_SV_DIALOG")
        return
    end
    
    -- Add Spell to block list with new structure
    PWSV.customResourceBlockList[spellId] = {
        blocked = false,           -- Complete blocked
        magickaCheck = false,      -- If Magicka check is used
        magickaBlock = false,      -- Block when magicka below threshold (true=block, false=allow only)
        magickaPercent = 0,        -- Magicka percentage threshold
        staminaCheck = false,      -- If Stamina check is used
        staminaBlock = false,      -- Block when stamina below threshold (true=block, false=allow only)
        staminaPercent = 0,        -- Stamina percentage threshold
    }
    
    PW.TEMP_RESOURCE_SPELL_ID = "" -- Clear input field
    ZO_Dialogs_ShowDialog("PW_RELOAD_DIALOG")
end

    -- =============================================================================
    -- == MENU =====================================================================
    -- =============================================================================
    -- Register main panel with LibAddonMenu
    LAM:RegisterAddonPanel(PW.name.."Menu", panel)

    -- Complete menu structure definition
    local options = {
        -- Information Section (flat, no submenu)
        {
            type = "description",
            text = COLOR.SECONDARY..PW.L("PW_MENU_INFO_TEXT"),
            fontSize = "medium",
            width = "full"
        },

        -- ====================================================================================================================================================
        -- Core Mechanics Submenu =============================================================================================================================
        -- ====================================================================================================================================================
        {
            type = "submenu",
            name = COLOR.ACCENT..PW.L("PW_MENU_MODE_HEADER"),
            controls = {
                CreateSectionHeader(PW.L("PW_MENU_MODE_HEADER")),
                CreateDropdown(
                    "PW_MENU_MODE_LABEL",
                    "PW_MENU_MODE_TOOLTIP",
                    {"PW_MENU_MODE_CHOICE_COND", "PW_MENU_MODE_CHOICE_HARD", "PW_MENU_MODE_CHOICE_SOFT", "PW_MENU_MODE_CHOICE_NONE"},
                    function() return PWSV.mode end,
   
                    function(value) -- Tmp fix, fix later
                        if value == 4 then
                            valueMode = 4  -- Sequential
                        elseif value == 1 then
                            valueMode = 1  -- Strict
                        elseif value == 2 then
                            valueMode = 2  -- Intelligent
                        elseif value == 3 then
                            valueMode = 3  -- Disabled
                        else    
                            valueMode = 0
                        end

                        -- d("ValueMode "..valueMode)
                        -- d("Value " ..value)
                        
                        PWSV.originalMode = 0
                        PWSV.mode = tonumber(valueMode) 
                    end
                ),
                CreateCheckbox(
                    "PW_MENU_GROUNDAOE_LABEL",
                    "PW_MENU_GROUNDAOE_TOOLTIP",
                    function() return PWSV.blockGroundAbilities end,
                    function(value) PWSV.blockGroundAbilities = value end
                )
            }
        },

        -- ====================================================================================================================================================
        -- Activation Conditions Submenu ======================================================================================================================
        -- ====================================================================================================================================================
        {
            type = "submenu",
            name = COLOR.ACCENT..PW.L("PW_MENU_CONDITIONS_HEADER"),
            controls = {
                CreateSectionHeader(PW.L("PW_MENU_CONDITIONS_HEADER")),
                CreateCheckbox(
                    "PW_MENU_COMBAT_LABEL",
                    "PW_MENU_COMBAT_TOOLTIP",
                    function() return PWSV.combat end,
                    function(value) PWSV.combat = value end
                ),
                CreateCheckbox(
                    "PW_MENU_ENEMYTARGET_LABEL",
                    "PW_MENU_ENEMYTARGET_TOOLTIP",
                    function() return PWSV.checkTarget end,
                    function(value) PWSV.checkTarget = value end
                ),
                CreateCheckbox(
                    "PW_MENU_BLOCKING_LABEL",
                    "PW_MENU_BLOCKING_TOOLTIP",
                    function() return PWSV.block end,
                    function(value) PWSV.block = value end
                ),

                { type = "divider", alpha = 0.2 }, -- =====================================================================================

                CreateCheckbox(
                    "PW_MENU_DISABLE_TANK",
                    "PW_MENU_DISABLE_TANK_TOOLTIP",
                    function() return PWSV.disableTank end,
                    function(value) 
                        PWSV.disableTank = value
                        PW.CheckRoleOverride()
                    end
                ),
                CreateCheckbox(
                    "PW_MENU_DISABLE_HEAL",
                    "PW_MENU_DISABLE_HEAL_TOOLTIP",
                    function() return PWSV.disableHeal end,
                    function(value) 
                        PWSV.disableHeal = value
                        PW.CheckRoleOverride()
                    end
                ),

                { type = "divider", alpha = 0.2 }, -- =====================================================================================

                CreateCheckbox(
                    "PW_MENU_DISABLE_FEATURES_ON_BACKBAR",
                    "PW_MENU_DISABLE_FEATURES_ON_BACKBAR_TOOLTIP",
                    function() return PWSV.deactivateOnBackbar.features end,
                    function(value) 
                        PWSV.deactivateOnBackbar.features = value
                    end
                ),
                CreateCheckbox(
                    "PW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR",
                    "PW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR_TOOLTIP",
                    function() return PWSV.deactivateOnBackbar.weaveAssist end,
                    function(value) 
                        PWSV.deactivateOnBackbar.weaveAssist = value
                    end
                ),

                { type = "divider", alpha = 0.2 }, -- =====================================================================================

                CreateCheckbox(
                    "PW_MENU_DISABLE_FEATURES_IN_PVP",
                    "PW_MENU_DISABLE_FEATURES_IN_PVP_TOOLTIP",
                    function() return PWSV.deactivateInPvP.features end,
                    function(value) PWSV.deactivateInPvP.features = value end
                ),

                CreateCheckbox(
                    "PW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP",
                    "PW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP_TOOLTIP",
                    function() return PWSV.deactivateInPvP.weaveAssist end,
                    function(value) PWSV.deactivateInPvP.weaveAssist = value end
                ),

            }
        },

        -- ====================================================================================================================================================
        -- Advanced Controls Submenu ==========================================================================================================================
        -- ====================================================================================================================================================
        {
            type = "submenu",
            name = COLOR.ACCENT..PW.L("PW_MENU_ADVANCED_HEADER"),
            controls = {
                CreateSectionHeader(PW.L("PW_MENU_ADVANCED_HEADER")),
                CreateCheckbox(
                    "PW_MENU_RESETONDODGE_LABEL",
                    "PW_MENU_RESETONDODGE_TOOLTIP",
                    function() return PWSV.resetOnDodge end,
                    function(value) PWSV.resetOnDodge = value end
                ),

                CreateCheckbox(
                    "PW_MENU_RESETONBARSWAP_LABEL",
                    "PW_MENU_RESETONBARSWAP_TOOLTIP",
                    function() return PWSV.resetOnBarswap end,
                    function(value) PWSV.resetOnBarswap = value end
                ),
                
                -- Channel Buffer Settings
                CreateSlider(
                    "PW_MENU_CHANNEL_NORMAL", 
                    "PW_MENU_CHANNEL_NORMAL_TOOLTIP", 
                    0, 100, -- 0-100ms (Default 50)
                    function() return PWSV.channelBufferNormal end,
                    function(value) PWSV.channelBufferNormal = value end
                ),
                CreateSlider(
                    "PW_MENU_CHANNEL_CHANNELED", 
                    "PW_MENU_CHANNEL_CHANNELED_TOOLTIP", 
                    0, 400, -- 0-400ms (Default 200)
                    function() return PWSV.channelBufferChanneled end,
                    function(value) PWSV.channelBufferChanneled = value end
                ),
                                
                -- GCD Thresholds
                CreateSlider(
                    "PW_MENU_MIN_GCD", 
                    "PW_MENU_MIN_GCD_TOOLTIP", 
                    0, 20, -- 0-20ms (Default 10)
                    function() return PWSV.minGcdThreshold end,
                    function(value) PWSV.minGcdThreshold = value end
                ),
                CreateSlider(
                    "PW_MENU_QUEUE_TIME", 
                    "PW_MENU_QUEUE_TIME_TOOLTIP", 
                    100, 2000, -- 100-2000ms (Default 1050)
                    function() return PWSV.baseQueueTime end,
                    function(value) PWSV.baseQueueTime = value end
                ),

                CreateCheckbox(
                    "PW_MENU_AUTO_GCD_SLOT_LABEL",
                    "PW_MENU_AUTO_GCD_SLOT_TOOLTIP",
                    function() return PWSV.autoGcdTrackingSlot end,
                    function(value) PWSV.autoGcdTrackingSlot = value end
                ),

                CreateSlider(
                    "PW_MENU_GCD_SLOT",
                    "PW_MENU_GCD_SLOT_TOOLTIP", 
                    3, 8, -- GCD tracking slot (Spells between 3 to 8), Light Attack 1
                    function() return PWSV.gcdTrackingSlot end,
                    function(value) PWSV.gcdTrackingSlot = value end,
                    function() return PWSV.autoGcdTrackingSlot end
                ),

                CreateSlider(
                    "PW_MENU_RESET_TIME_LABEL",
                    "PW_MENU_RESET_TIME_TOOLTIP", 
                    1, 60, -- Min: 1 seconds, Max: 60 seconds
                    function() return PWSV.resetAfterSeconds end,
                    function(value) PWSV.resetAfterSeconds = value end
                ),

                { type = "divider", alpha = 0.2 }, -- =====================================================================================

                -- Automatic Weapon Equipping
                CreateCheckbox(
                    "PW_MENU_AUTO_EQUIP_WEAPONS_LABEL",
                    "PW_MENU_AUTO_EQUIP_WEAPONS_TOOLTIP",
                    function() return PWSV.autoEquipWeapons end,
                    function(value) PWSV.autoEquipWeapons = value end,
                    nil,
                    true
                ),
                
                { type = "divider", alpha = 0.2 }, -- =====================================================================================

                -- Reset Settings Button
                {
                    type = "button",
                    name = COLOR.WARNING..PW.L("PW_MENU_RESET_SETTINGS_LABEL"),
                    tooltip = COLOR.SECONDARY..PW.L("PW_MENU_RESET_SETTINGS_TOOLTIP"),
                    width = "full",
                    isDangerous = true,
                    func = function()
                        -- Overwrite savedvariables (PWSV) with defaults
                        for key, value in pairs(defaults) do
                            if type(value) == "table" then
                                PWSV[key] = {}
                                for subkey, subvalue in pairs(value) do
                                    PWSV[key][subkey] = subvalue
                                end
                            else
                                PWSV[key] = value
                            end
                        end
                    end
                }

            }
        },

        -- ====================================================================================================================================================
        -- (Sub)Class Settings Submenu ========================================================================================================================
        -- ====================================================================================================================================================
        {
            type = "submenu",
            name = COLOR.ACCENT..PW.L("PW_MENU_SUBCLASS_HEADER"),
            controls = {
                CreateSectionHeader(PW.L("PW_MENU_SUBCLASS_HEADER")),
                {
                    type = "header",
                    name = COLOR.PRIMARY..PW.L("PW_MENU_SUBCLASS_GRIMFOCUS"),
                    width = "full"
                },
                
                -- Grim Focus (and Morphs)
                CreateCheckbox(
                    "PW_MENU_GRIMFOCUS_ALL_MORPHS",
                    "PW_MENU_GRIMFOCUS_ALL_MORPHS_TOOLTIP",
                    function() return PWSV.grimFocusSkillIds[61919] and PWSV.grimFocusSkillIds[61927] and PWSV.grimFocusSkillIds[61902] end,
                    function(value) 
                        PWSV.grimFocusSkillIds[61919] = value
                        PWSV.grimFocusSkillIds[61927] = value
                        PWSV.grimFocusSkillIds[61902] = value
                        PWSV.useGrimFocusStacks = false
                    end
                ),

                CreateCheckbox(
                    "PW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE",
                    "PW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE_TOOLTIP",
                    function() return PWSV.useGrimFocusStacks end,
                    function(value) 
                        PWSV.useGrimFocusStacks = value
                    end,
                    function() return PWSV.grimFocusSkillIds[61919] end
                ),
                
                { type = "divider", alpha = 0.2 }, -- =====================================================================================
                
                -- Grim Focus Stacks Slider
                CreateSlider(
                    "PW_MENU_GRIMFOCUS_STACKS",
                    "PW_MENU_GRIMFOCUS_STACKS_TOOLTIP",
                    5, 10, -- Min:5, Max:10 Stacks
                    function() return PWSV.grimFocusStacks end,
                    function(value) PWSV.grimFocusStacks = value end,
                    function() return not PWSV.useGrimFocusStacks end
                ),
                
                -- Arcanist Fatecarver
                CreateSectionHeader(PW.L("PW_MENU_SUBCLASS_HEADER")),
                {
                    type = "header",
                    name = COLOR.PRIMARY..PW.L("PW_MENU_SUBCLASS_FATECARVER"),
                    width = "full"
                },
                
                -- Fatecarver (and Morphs)
                CreateCheckbox(
                    "PW_MENU_FATECARVER_ALL_MORPHS",
                    "PW_MENU_FATECARVER_ALL_MORPHS_TOOLTIP",
                    function() return PWSV.arcaBeamSkillIds[186366] and PWSV.arcaBeamSkillIds[186366] and PWSV.arcaBeamSkillIds[186366] end,
                    function(value) 
                        PWSV.arcaBeamSkillIds[185805] = value -- Base Mag
                        PWSV.arcaBeamSkillIds[183122] = value -- Exhausting Fatecarver Mag
                        PWSV.arcaBeamSkillIds[186366] = value -- Pragmatic Fatecarver Mag
                        PWSV.arcaBeamSkillIds[193397] = value -- Base
                        PWSV.arcaBeamSkillIds[193398] = value -- Exhausting Fatecarver
                        PWSV.arcaBeamSkillIds[193331] = value -- Pragmatic Fatecarver
                        PWSV.useCruxStacks = value
                        --d(tostring(value))
                    end
                ),

                -- Crux Stack Slider
                CreateSlider(
                    "PW_MENU_CRUX_STACKS",
                    "PW_MENU_CRUX_STACKS_TOOLTIP",
                    1, 3, -- Min:1, Max:3 Stacks
                    function() return PWSV.cruxStacks end,
                    function(value) PWSV.cruxStacks = value end,
                    function() return not PWSV.useCruxStacks end
                ),

                { type = "divider", alpha = 0.2 }, -- =====================================================================================

                -- Deactivate under certain HP toggle
                CreateCheckbox(
                    "PW_MENU_CHECK_HP_FOR_BEAM_TOOGLE",
                    "PW_MENU_CHECK_HP_FOR_BEAM_TOOGLE_TOOLTIP",
                    function() return PWSV.checkHpForArcaBeam end,
                    function(value) 
                        PWSV.checkHpForArcaBeam = value
                    end
                ),
                
                { type = "divider", alpha = 0.2 }, -- =====================================================================================
                
                -- Deactivate under certain HP Slider
                CreateSlider(
                    "PW_MENU_CHECK_HP_FOR_BEAM",
                    "PW_MENU_CHECK_HP_FOR_BEAM_TOOLTIP",
                    0, 100, -- Min:0, Max:100 % HP
                    function() return PWSV.deactivateArcaBeamBlockAtHpUnder end,
                    function(value) PWSV.deactivateArcaBeamBlockAtHpUnder = value end,
                    function() return not PWSV.checkHpForArcaBeam end
                ),

                { type = "divider", alpha = 0.2 }, -- =====================================================================================

                -- Deactivate under certain Stam toggle
                CreateCheckbox(
                    "PW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE",
                    "PW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE_TOOLTIP",
                    function() return PWSV.checkStamForArcaBeam end,
                    function(value) 
                        PWSV.checkStamForArcaBeam = value
                    end
                ),
                
                
                -- Deactivate under certain HP Slider
                CreateSlider(
                    "PW_MENU_CHECK_STAMINA_FOR_BEAM",
                    "PW_MENU_CHECK_STAMINA_FOR_BEAM_TOOLTIP",
                    0, 100, -- Min:0, Max:100 % Stam
                    function() return PWSV.deactivateArcaBeamBlockAtStamUnder end,
                    function(value) PWSV.deactivateArcaBeamBlockAtStamUnder = value end,
                    function() return not PWSV.checkStamForArcaBeam end
                ),

                -- Arcanist Cephaliarch's Flail
                CreateSectionHeader(PW.L("PW_MENU_SUBCLASS_HEADER")),
                {
                    type = "header",
                    name = COLOR.PRIMARY..PW.L("PW_MENU_SUBCLASS_CEPHALIARCHSFLAIL"),
                    width = "full"
                },

                -- Cephaliarch's Flail
                CreateCheckbox(
                    "PW_MENU_CEPHALIARCHSFLAIL",
                    "PW_MENU_CEPHALIARCHSFLAIL_TOOLTIP",
                    function() return PWSV.cephaliarchsFlail[183006] end,
                    function(value) 
                        PWSV.cephaliarchsFlail[183006] = value
                        PWSV.useCruxStacksCephaliarch = value
                    end
                ),

                -- Arcanist Tentacular Dread
                CreateSectionHeader(PW.L("PW_MENU_SUBCLASS_HEADER")),
                {
                    type = "header",
                    name = COLOR.PRIMARY..PW.L("PW_MENU_SUBCLASS_TENTACULAR"),
                    width = "full"
                },
                
                -- Tentacular
                CreateCheckbox(
                    "PW_MENU_TENTACULAR",
                    "PW_MENU_TENTACULAR_TOOLTIP",
                    function() return PWSV.tentacularDread[185823] end,
                    function(value) 
                        PWSV.tentacularDread[185823] = value -- Tentacular Dread
                        PWSV.usecruxStacksTentacular = value
                        --d(tostring(value))
                    end
                ),
                
                -- Crux Stack Slider
                CreateSlider(
                    "PW_MENU_CRUX_STACKS",
                    "PW_MENU_TENTACULAR_TOOLTIP",
                    1, 3, -- Min:1, Max:3 Stacks
                    function() return PWSV.cruxStacksTentacular end,
                    function(value) PWSV.cruxStacksTentacular = value end,
                    function() return not PWSV.usecruxStacksTentacular end
                ),

                -- Dragonknight Molten Whip
                CreateSectionHeader(PW.L("PW_MENU_SUBCLASS_HEADER")),
                {
                    type = "header",
                    name = COLOR.PRIMARY..PW.L("PW_MENU_SUBCLASS_MOLTENWHIP"),
                    width = "full"
                },

                -- Molten Whip
                CreateCheckbox(
                    "PW_MENU_MOLTENWHIP_BLOCK",
                    "PW_MENU_MOLTENWHIP_BLOCK_TOOLTIP",
                    function() return PWSV.MoltenWhip[20805] end,
                    function(value) 
                        PWSV.MoltenWhip[20805] = value
                    end
                ),

                -- Execute Check 
                {
                    type = "header",
                    name = COLOR.PRIMARY..PW.L("PW_MENU_EXECUTE_HEADER"),
                    width = "full"
                },
                
                -- Enable/Disable Execute Check
                CreateCheckbox(
                    "PW_MENU_EXECUTE_ENABLE",
                    "PW_MENU_EXECUTE_ENABLE_TOOLTIP",
                    function() return PWSV.useExecuteCheck end,
                    function(value) PWSV.useExecuteCheck = value end
                ),
                
                -- Execute Threshold Slider
                CreateSlider(
                    "PW_MENU_EXECUTE_THRESHOLD",
                    "PW_MENU_EXECUTE_THRESHOLD_TOOLTIP",
                    0, 100, -- 0-100%
                    function() return PWSV.executeThreshold end,
                    function(value) PWSV.executeThreshold = value end,
                    function() return not PWSV.useExecuteCheck end
                ),
                                
                -- Execute Spells Header
                {
                    type = "header",
                    name = COLOR.PRIMARY..PW.L("PW_MENU_EXECUTE_SPELLS_HEADER"),
                    width = "full"
                },
                
                -- Radiant Destruction and Morphs 
                CreateCheckbox(
                    "PW_MENU_EXECUTE_SPELL_RADIANTMORPHS",
                    "PW_MENU_EXECUTE_SPELL_RADIANTMORPHS_TOOLTIP",
                    function() return PWSV.executeCheckSpells[63029] end,
                    function(value) 
                        PWSV.executeCheckSpells[63029] = value
                        PWSV.executeCheckSpells[63044] = value
                        PWSV.executeCheckSpells[63046] = value
                    end,
                    function() return not PWSV.useExecuteCheck end
                ),
                
                -- Assassin's Blade and Morphs
                CreateCheckbox(
                    "PW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS",
                    "PW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS_TOOLTIP",
                    function() return PWSV.executeCheckSpells[33386] end,
                    function(value) 
                        PWSV.executeCheckSpells[33386] = value
                        PWSV.executeCheckSpells[34851] = value
                        PWSV.executeCheckSpells[34843] = value
                    end,
                    function() return not PWSV.useExecuteCheck end
                ),

                 -- Mages' Fury and Morphs 
                CreateCheckbox(
                    "PW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS",
                    "PW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS_TOOLTIP",
                    function() return PWSV.executeCheckSpells[19123] end,
                    function(value) 
                        PWSV.executeCheckSpells[19123] = value
                        PWSV.executeCheckSpells[18718] = value
                        PWSV.executeCheckSpells[19109] = value
                    end,
                    function() return not PWSV.useExecuteCheck end
                ),

                -- Reverse Slash and Morphs
                CreateCheckbox(
                    "PW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS",
                    "PW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS_TOOLTIP",
                    function() return PWSV.executeCheckSpells[28302] end,
                    function(value) 
                        PWSV.executeCheckSpells[28302] = value
                        PWSV.executeCheckSpells[38823] = value
                        PWSV.executeCheckSpells[38819] = value
                    end,
                    function() return not PWSV.useExecuteCheck end
                ),

                -- guild
                CreateSectionHeader(PW.L("PW_MENU_SUBCLASS_HEADER")),
                {
                    type = "header",
                    name = COLOR.PRIMARY..PW.L("PW_MENU_SUBCLASS_GUILDS"),
                    width = "full"
                },
                -- Mages guild
                CreateCheckbox(
                    "PW_MENU_LIGHT_ALL_MORPHS",
                    "PW_MENU_LIGHT_ALL_MORPHS_TOOLTIP",
                    function() return PWSV.lightMorphs[30920] and PWSV.lightMorphs[40478] and PWSV.lightMorphs[40483] end,
                    function(value) 
                        PWSV.lightMorphs[30920] = value
                        PWSV.lightMorphs[40478] = value
                        PWSV.lightMorphs[40483] = value
                    end
                ),

                { type = "divider", alpha = 0.2 }, -- =====================================================================================
                
                -- Fighter guild
                CreateCheckbox(
                    "PW_MENU_HUNTER_ALL_MORPHS",
                    "PW_MENU_HUNTER_ALL_MORPHS_TOOLTIP",
                    function() return PWSV.hunterMorphs[35762] and PWSV.hunterMorphs[40195] and PWSV.hunterMorphs[40194] end,
                    function(value) 
                        PWSV.hunterMorphs[35762] = value
                        PWSV.hunterMorphs[40195] = value
                        PWSV.hunterMorphs[40194] = value
                    end
                ),

                { type = "divider", alpha = 0.2 }, -- =====================================================================================
                
                -- Deactivate Hunter and light block in PvP
                CreateCheckbox(
                    "PW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS",
                    "PW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS_TOOLTIP",
                    function() return PWSV.deactivateHunterLightInPvP end,
                    function(value) 
                        PWSV.deactivateHunterLightInPvP = value
                    end
                ),
            }
        },

        -- ====================================================================================================================================================
        -- Weapon Type Deactivation Submenu ===================================================================================================================
        -- ====================================================================================================================================================
        {
            type = "submenu",
            name = COLOR.ACCENT..PW.L("PW_MENU_DEACTIVATE_ON_WEAPON_HEADER"),
            controls = {
                CreateSectionHeader(PW.L("PW_MENU_DEACTIVATE_ON_WEAPON_HEADER")),

                CreateCheckbox(
                    "PW_MENU_DISABLE_FEATURES_ON_WEAPON",
                    "PW_MENU_DISABLE_FEATURES_ON_WEAPON_TOOLTIP",
                    function() return PWSV.deactivateOnWeapon.features end,
                    function(value) 
                        PWSV.deactivateOnWeapon.features = value
                    end
                ),
                CreateCheckbox(
                    "PW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON",
                    "PW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON_TOOLTIP",
                    function() return PWSV.deactivateOnWeapon.weaveAssist end,
                    function(value) 
                        PWSV.deactivateOnWeapon.weaveAssist = value
                    end
                ),
                
                { type = "divider", alpha = 1.0 }, -- =====================================================================================

                -- One-handed weapons
                CreateCheckbox(
                    "PW_MENU_DEACTIVATE_ON_WEAPON_AXE",
                    "PW_MENU_DEACTIVATE_ON_WEAPON_AXE_TOOLTIP",
                    function() return PWSV.deactivateOnWeaponType.axe end,
                    function(value) PWSV.deactivateOnWeaponType.axe = value end,
                    function() return not (PWSV.deactivateOnWeapon.features or PWSV.deactivateOnWeapon.weaveAssist) end
                ),
                CreateCheckbox(
                    "PW_MENU_DEACTIVATE_ON_WEAPON_HAMMER",
                    "PW_MENU_DEACTIVATE_ON_WEAPON_HAMMER_TOOLTIP",
                    function() return PWSV.deactivateOnWeaponType.hammer end,
                    function(value) PWSV.deactivateOnWeaponType.hammer = value end,
                    function() return not (PWSV.deactivateOnWeapon.features or PWSV.deactivateOnWeapon.weaveAssist) end
                ),
                CreateCheckbox(
                    "PW_MENU_DEACTIVATE_ON_WEAPON_SWORD",
                    "PW_MENU_DEACTIVATE_ON_WEAPON_SWORD_TOOLTIP",
                    function() return PWSV.deactivateOnWeaponType.sword end,
                    function(value) PWSV.deactivateOnWeaponType.sword = value end,
                    function() return not (PWSV.deactivateOnWeapon.features or PWSV.deactivateOnWeapon.weaveAssist) end
                ),
                CreateCheckbox(
                    "PW_MENU_DEACTIVATE_ON_WEAPON_DAGGER",
                    "PW_MENU_DEACTIVATE_ON_WEAPON_DAGGER_TOOLTIP",
                    function() return PWSV.deactivateOnWeaponType.dagger end,
                    function(value) PWSV.deactivateOnWeaponType.dagger = value end,
                    function() return not (PWSV.deactivateOnWeapon.features or PWSV.deactivateOnWeapon.weaveAssist) end
                ),
                
                { type = "divider", alpha = 0.2 }, -- =====================================================================================
                
                -- Two-handed weapons
                CreateCheckbox(
                    "PW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD",
                    "PW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD_TOOLTIP",
                    function() return PWSV.deactivateOnWeaponType.twoHandedSword end,
                    function(value) PWSV.deactivateOnWeaponType.twoHandedSword = value end,
                    function() return not (PWSV.deactivateOnWeapon.features or PWSV.deactivateOnWeapon.weaveAssist) end
                ),
                CreateCheckbox(
                    "PW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE",
                    "PW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE_TOOLTIP",
                    function() return PWSV.deactivateOnWeaponType.twoHandedAxe end,
                    function(value) PWSV.deactivateOnWeaponType.twoHandedAxe = value end,
                    function() return not (PWSV.deactivateOnWeapon.features or PWSV.deactivateOnWeapon.weaveAssist) end
                ),
                CreateCheckbox(
                    "PW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER",
                    "PW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER_TOOLTIP",
                    function() return PWSV.deactivateOnWeaponType.twoHandedHammer end,
                    function(value) PWSV.deactivateOnWeaponType.twoHandedHammer = value end,
                    function() return not (PWSV.deactivateOnWeapon.features or PWSV.deactivateOnWeapon.weaveAssist) end
                ),
                CreateCheckbox(
                    "PW_MENU_DEACTIVATE_ON_WEAPON_BOW",
                    "PW_MENU_DEACTIVATE_ON_WEAPON_BOW_TOOLTIP",
                    function() return PWSV.deactivateOnWeaponType.bow end,
                    function(value) PWSV.deactivateOnWeaponType.bow = value end,
                    function() return not (PWSV.deactivateOnWeapon.features or PWSV.deactivateOnWeapon.weaveAssist) end
                ),
                
                { type = "divider", alpha = 0.2 }, -- =====================================================================================
                
                -- Staves
                CreateCheckbox(
                    "PW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF",
                    "PW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF_TOOLTIP",
                    function() return PWSV.deactivateOnWeaponType.fireStaff end,
                    function(value) PWSV.deactivateOnWeaponType.fireStaff = value end,
                    function() return not (PWSV.deactivateOnWeapon.features or PWSV.deactivateOnWeapon.weaveAssist) end
                ),
                CreateCheckbox(
                    "PW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF",
                    "PW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF_TOOLTIP",
                    function() return PWSV.deactivateOnWeaponType.frostStaff end,
                    function(value) PWSV.deactivateOnWeaponType.frostStaff = value end,
                    function() return not (PWSV.deactivateOnWeapon.features or PWSV.deactivateOnWeapon.weaveAssist) end
                ),
                CreateCheckbox(
                    "PW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF",
                    "PW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF_TOOLTIP",
                    function() return PWSV.deactivateOnWeaponType.lightningStaff end,
                    function(value) PWSV.deactivateOnWeaponType.lightningStaff = value end,
                    function() return not (PWSV.deactivateOnWeapon.features or PWSV.deactivateOnWeapon.weaveAssist) end
                ),
                CreateCheckbox(
                    "PW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF",
                    "PW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF_TOOLTIP",
                    function() return PWSV.deactivateOnWeaponType.healingStaff end,
                    function(value) PWSV.deactivateOnWeaponType.healingStaff = value end,
                    function() return not (PWSV.deactivateOnWeapon.features or PWSV.deactivateOnWeapon.weaveAssist) end
                ),
                
                { type = "divider", alpha = 0.2 }, -- =====================================================================================
                
                -- Other weapons
                CreateCheckbox(
                    "PW_MENU_DEACTIVATE_ON_WEAPON_SHIELD",
                    "PW_MENU_DEACTIVATE_ON_WEAPON_SHIELD_TOOLTIP",
                    function() return PWSV.deactivateOnWeaponType.shield end,
                    function(value) PWSV.deactivateOnWeaponType.shield = value end,
                    function() return not (PWSV.deactivateOnWeapon.features or PWSV.deactivateOnWeapon.weaveAssist) end
                ),
                -- CreateCheckbox(
                --     "PW_MENU_DEACTIVATE_ON_WEAPON_RUNE",
                --     "PW_MENU_DEACTIVATE_ON_WEAPON_RUNE_TOOLTIP",
                --     function() return PWSV.deactivateOnWeaponType.rune end,
                --     function(value) PWSV.deactivateOnWeaponType.rune = value end,
                --     function() return not (PWSV.deactivateOnWeapon.features or PWSV.deactivateOnWeapon.weaveAssist) end
                -- ),
                -- CreateCheckbox(
                --     "PW_MENU_DEACTIVATE_ON_WEAPON_NONE",
                --     "PW_MENU_DEACTIVATE_ON_WEAPON_NONE_TOOLTIP",
                --     function() return PWSV.deactivateOnWeaponType.none end,
                --     function(value) PWSV.deactivateOnWeaponType.none = value end,
                --     function() return not (PWSV.deactivateOnWeapon.features or PWSV.deactivateOnWeapon.weaveAssist) end
                -- ),
                -- CreateCheckbox(
                --     "PW_MENU_DEACTIVATE_ON_WEAPON_RESERVED",
                --     "PW_MENU_DEACTIVATE_ON_WEAPON_RESERVED_TOOLTIP",
                --     function() return PWSV.deactivateOnWeaponType.reservedWeapon end,
                --     function(value) PWSV.deactivateOnWeaponType.reservedWeapon = value end,
                --     function() return not (PWSV.deactivateOnWeapon.features or PWSV.deactivateOnWeapon.weaveAssist) end
                -- )
            }
        },

        -- ====================================================================================================================================================
        -- Performance Settings ===============================================================================================================================
        -- ====================================================================================================================================================
        {
            type = "submenu",
            name = COLOR.ACCENT..PW.L("PW_MENU_PERFORMANCE_HEADER"),
            controls = {
                CreateSectionHeader(PW.L("PW_MENU_PERFORMANCE_HEADER")),
                CreateCheckbox(
                    "PW_MENU_AUTOLATENCY_LABEL",
                    "PW_MENU_AUTOLATENCY_TOOLTIP",
                    function() return PWSV.autoLag end,
                    function(value) PWSV.autoLag = value end
                ),
                CreateSlider(
                    "PW_MENU_MANUALLATENCY_LABEL",
                    "PW_MENU_MANUALLATENCY_TOOLTIP",
                    0,
                    200,
                    function() return PWSV.inputLag end,
                    function(value) PWSV.inputLag = value end,
                    function() return PWSV.autoLag end
                )
            }
        },

        -- ====================================================================================================================================================
        -- USER-CONFIGURABLE BLOCK LIST =======================================================================================================================
        -- ====================================================================================================================================================
        {
            type = "submenu",
            name = COLOR.ACCENT..PW.L("PW_MENU_CONFIGURABLEBLOCK_HEADER"),
            controls = (function()
                local controls = {
                    CreateSectionHeader(PW.L("PW_MENU_CONFIGURABLEBLOCK_HEADER")),
                    {
                        type = "description",
                        text = COLOR.SECONDARY..PW.L("PW_MENU_CUSTOMBLOCK_DESC"),
                        width = "full"
                    },

                    CreateCheckbox(
                        "PW_MENU_USE_CUSTOM_BLOCK_LIST",
                        "PW_MENU_USE_CUSTOM_BLOCK_LIST_TOOLTIP",
                        function() return PWSV.useCustomBlockList end,
                        function(value) PWSV.useCustomBlockList = value end
                    ),

                    { type = "divider", alpha = 0.2 }, -- =====================================================================================

                    -- Health Check for Block List
                    CreateCheckbox(
                        "PW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK",
                        "PW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK_TOOLTIP",
                        function() return PWSV.useCustomBlockListHealthCheck end,
                        function(value) PWSV.useCustomBlockListHealthCheck = value end,
                        function() return not PWSV.useCustomBlockList end
                    ),

                    -- Health Percent Slider for Block List
                    CreateSlider(
                        "PW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT",
                        "PW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP",
                        0, 100, -- 0-100%
                        function() return PWSV.useCustomBlockListHealthPercent end,
                        function(value) PWSV.useCustomBlockListHealthPercent = value end,
                        function() return not (PWSV.useCustomBlockList and PWSV.useCustomBlockListHealthCheck) end
                    ),

                    { type = "divider", alpha = 0.2 }, -- =====================================================================================

                    {
                        type = "editbox",
                        name = COLOR.PRIMARY..PW.L("PW_MENU_CUSTOMBLOCK_SPELLID_LABEL"),
                        tooltip = COLOR.SECONDARY..PW.L("PW_MENU_CUSTOMBLOCK_SPELLID_TOOLTIP"),
                        getFunc = function() return PW.TEMP_SPELL_ID or "" end,--_G["PW_TEMP_SPELL_ID"] or "" end,
                        setFunc = function(value) 
                            --_G["PW_TEMP_SPELL_ID"] = value
                            PW.TEMP_SPELL_ID = value 
                        end,
                        width = "full"
                    },
                    {
                        type = "button",
                        name = COLOR.PRIMARY..PW.L("PW_MENU_CUSTOMBLOCK_ADD_BUTTON"),
                        func = function()
                            AddSpellToBlockList()
                            --ZO_Dialogs_ShowDialog("PW_RELOAD_DIALOG")
                        end,
                        --requiresReload = true,
                        width = "full"
                    },

                    { type = "divider", alpha = 0.2 }, -- =====================================================================================
                    
                    {
                        type = "description",
                        text = COLOR.ACCENT..PW.L("PW_MENU_CUSTOMBLOCK_LIST_HEADER"),
                        width = "full"
                    },
                }
                
                -- Dynamically generated checkboxes for each spell ID in customRecastBlockList
                local spellIds = {}
                for spellId, _ in pairs(PWSV.customBlockList) do
                    table.insert(spellIds, spellId)
                end
                table.sort(spellIds)
                
                for _, spellId in ipairs(spellIds) do
                    local spellName = GetAbilityName(spellId) or ("Unknown Spell ("..spellId..")")
                    table.insert(controls, {
                        type = "checkbox",
                        name = COLOR.PRIMARY..zo_strformat("<<1>>", spellName),
                        tooltip = COLOR.SECONDARY.."Spell ID: "..spellId,
                        getFunc = function() 
                            return PWSV.customBlockList[spellId] 
                        end,
                        setFunc = function(value) 
                            PWSV.customBlockList[spellId] = value
                        end,
                        width = "full"
                    })
                end
                
                return controls
            end)()
        },

        -- ====================================================================================================================================================
        -- USER-CONFIGURABLE RECAST BLOCK LIST ================================================================================================================
        -- ====================================================================================================================================================
        {
            type = "submenu",
            name = COLOR.ACCENT..PW.L("PW_MENU_CONFIGURABLERECASTBLOCK_HEADER"),
            controls = (function()
                local controls = {
                    CreateSectionHeader(PW.L("PW_MENU_CONFIGURABLERECASTBLOCK_HEADER")),
                    {
                        type = "description",
                        text = COLOR.SECONDARY..PW.L("PW_MENU_CUSTOMRECASTBLOCK_DESC"),
                        width = "full"
                    },

                    CreateCheckbox(
                        "PW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST",
                        "PW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_TOOLTIP",
                        function() return PWSV.useCustomRecastBlockList end,
                        function(value) PWSV.useCustomRecastBlockList = value end
                    ),

                    CreateSlider(
                        "PW_MENU_RECAST_BLOCK_TIME",
                        "PW_MENU_RECAST_BLOCK_TIME_TOOLTIP",
                        0, 120, -- 0-120s (Default 1)
                        function() return PWSV.recastBlockTime end,
                        function(value) PWSV.recastBlockTime = value end,
                        function() return not PWSV.useCustomRecastBlockList end
                    ),
                    
                    { type = "divider", alpha = 0.2 }, -- =====================================================================================

                    -- Health Check for Recast Block List
                    CreateCheckbox(
                        "PW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK",
                        "PW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK_TOOLTIP",
                        function() return PWSV.useCustomRecastBlockListHealthCheck end,
                        function(value) PWSV.useCustomRecastBlockListHealthCheck = value end,
                        function() return not PWSV.useCustomRecastBlockList end
                    ),

                    -- Health Percent Slider for Recast Block List
                    CreateSlider(
                        "PW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT",
                        "PW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP",
                        0, 100, -- 0-100%
                        function() return PWSV.useCustomRecastBlockListHealthPercent end,
                        function(value) PWSV.useCustomRecastBlockListHealthPercent = value end,
                        function() return not (PWSV.useCustomRecastBlockList and PWSV.useCustomRecastBlockListHealthCheck) end
                    ),

                    CreateSlider(
                        "PW_MENU_RECAST_BLOCK_TIME",
                        "PW_MENU_RECAST_BLOCK_TIME_TOOLTIP",
                        0, 120, -- 0-120s (Default 1)
                        function() return PWSV.recastBlockTime end,
                        function(value) PWSV.recastBlockTime = value end,
                        function() return not PWSV.useCustomRecastBlockList end
                    ),
                    
                    { type = "divider", alpha = 0.2 }, -- =====================================================================================

                    {
                        type = "editbox",
                        name = COLOR.PRIMARY..PW.L("PW_MENU_CUSTOMRECASTBLOCK_SPELLID_LABEL"),
                        tooltip = COLOR.SECONDARY..PW.L("PW_MENU_CUSTOMRECASTBLOCK_SPELLID_TOOLTIP"),
                        getFunc = function() return PW.TEMP_RECAST_SPELL_ID or "" end,--_G["PW_TEMP_RECAST_SPELL_ID"] or "" end,
                        setFunc = function(value) 
                            PW.TEMP_RECAST_SPELL_ID = value--_G["PW_TEMP_RECAST_SPELL_ID"] = value
                        end,
                        width = "full"
                    },
                    {
                        type = "button",
                        name = COLOR.PRIMARY..PW.L("PW_MENU_CUSTOMRECASTBLOCK_ADD_BUTTON"),
                        func = function()
                            AddSpellToRecastBlockList()
                            --ZO_Dialogs_ShowDialog("PW_RELOAD_DIALOG")  
                        end,
                        --requiresReload = true,
                        width = "full"
                    },

                    { type = "divider", alpha = 0.2 }, -- =====================================================================================

                    {
                        type = "description",
                        text = COLOR.ACCENT..PW.L("PW_MENU_CUSTOMRECASTBLOCK_LIST_HEADER"),
                        width = "full"
                    },
                }
                
                -- Dynamically generated checkboxes for each spell ID in customRecastBlockList
                local spellIds = {}
                for spellId, _ in pairs(PWSV.customRecastBlockList) do
                    table.insert(spellIds, spellId)
                end
                table.sort(spellIds)
                
                for _, spellId in ipairs(spellIds) do
                    local spellName = GetAbilityName(spellId) or ("Unknown Spell ("..spellId..")")
                    table.insert(controls, {
                        type = "checkbox",
                        name = COLOR.PRIMARY..zo_strformat("<<1>>", spellName),
                        tooltip = COLOR.SECONDARY.."Spell ID: "..spellId,
                        getFunc = function() 
                            return PWSV.customRecastBlockList[spellId] 
                        end,
                        setFunc = function(value) 
                            PWSV.customRecastBlockList[spellId] = value
                        end,
                        width = "full"
                    })
                end
                
                return controls
            end)()
        },

        -- ====================================================================================================================================================
        -- USER-CONFIGURABLE RESOURCE-BASED BLOCK LIST ========================================================================================================
        -- ====================================================================================================================================================
        {
            type = "submenu",
            name = COLOR.ACCENT..PW.L("PW_MENU_CONFIGURABLEBLOCK_RESOURCE_HEADER").." Experimental",
            controls = (function()
                local controls = {
                    CreateSectionHeader(PW.L("PW_MENU_CONFIGURABLEBLOCK_RESOURCE_HEADER").." Experimental"),
                    {
                        type = "description",
                        text = COLOR.SECONDARY..PW.L("PW_MENU_CUSTOMBLOCK_RESOURCE_DESC"),
                        width = "full"
                    },

                    CreateCheckbox(
                        "PW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST",
                        "PW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST_TOOLTIP",
                        function() return PWSV.useCustomResourceBlockList end,
                        function(value) PWSV.useCustomResourceBlockList = value end
                    ),

                    { type = "divider", alpha = 0.2 }, -- =====================================================================================

                    {
                        type = "editbox",
                        name = COLOR.PRIMARY..PW.L("PW_MENU_CUSTOMBLOCK_SPELLID_LABEL"),
                        tooltip = COLOR.SECONDARY..PW.L("PW_MENU_CUSTOMBLOCK_SPELLID_TOOLTIP"),
                        getFunc = function() return PW.TEMP_RESOURCE_SPELL_ID or "" end,
                        setFunc = function(value) 
                            PW.TEMP_RESOURCE_SPELL_ID = value
                        end,
                        width = "full"
                    },
                    {
                        type = "button",
                        name = COLOR.PRIMARY..PW.L("PW_MENU_CUSTOMBLOCK_ADD_BUTTON"),
                        func = function()
                            AddSpellToResourceBlockList()
                        end,
                        width = "full"
                    },

                    { type = "divider", alpha = 0.2 }, -- =====================================================================================
                    
                    {
                        type = "description",
                        text = COLOR.ACCENT..PW.L("PW_MENU_CUSTOMBLOCK_LIST_HEADER"),
                        width = "full"
                    },
                }
                
                -- Dynamically generated controls for each spell ID in customResourceBlockList
                local spellIds = {}
                for spellId, _ in pairs(PWSV.customResourceBlockList) do
                    table.insert(spellIds, spellId)
                end
                table.sort(spellIds)
                
                for _, spellId in ipairs(spellIds) do
                    local spellData = PWSV.customResourceBlockList[spellId]
                    local spellName = GetAbilityName(spellId) or ("Unknown Spell ("..spellId..")")
                    
                    -- Base blocked checkbox
                    table.insert(controls, {
                        type = "checkbox",
                        name = COLOR.PRIMARY..zo_strformat("<<1>>", spellName),
                        tooltip = COLOR.SECONDARY.."Spell ID: "..spellId,
                        getFunc = function() 
                            return spellData.blocked 
                        end,
                        setFunc = function(value) 
                            PWSV.customResourceBlockList[spellId].blocked = value
                        end,
                        width = "full"
                    })
                    
                    -- Magicka check section
                    table.insert(controls, {
                        type = "checkbox",
                        name = COLOR.SECONDARY..PW.L("PW_MENU_RESOURCE_MAGICKA_CHECK"),
                        tooltip = COLOR.SECONDARY..PW.L("PW_MENU_RESOURCE_MAGICKA_CHECK_TOOLTIP"),
                        getFunc = function() 
                            return spellData.magickaCheck 
                        end,
                        setFunc = function(value) 
                            PWSV.customResourceBlockList[spellId].magickaCheck = value
                        end,
                        width = "full",
                        disabled = function() return not PWSV.useCustomResourceBlockList end
                    })
                    
                    table.insert(controls, {
                        type = "checkbox",
                        name = COLOR.SECONDARY..PW.L("PW_MENU_RESOURCE_MAGICKA_BLOCK_MODE"),
                        tooltip = COLOR.SECONDARY..PW.L("PW_MENU_RESOURCE_MAGICKA_BLOCK_MODE_TOOLTIP"),
                        getFunc = function() 
                            return spellData.magickaBlock 
                        end,
                        setFunc = function(value) 
                            PWSV.customResourceBlockList[spellId].magickaBlock = value
                        end,
                        width = "full",
                        disabled = function() return not (PWSV.useCustomResourceBlockList and spellData.magickaCheck) end
                    })
                    
                    table.insert(controls, {
                        type = "slider",
                        name = COLOR.SECONDARY..PW.L("PW_MENU_RESOURCE_MAGICKA_THRESHOLD"),
                        tooltip = COLOR.SECONDARY..PW.L("PW_MENU_RESOURCE_MAGICKA_THRESHOLD_TOOLTIP"),
                        min = 0,
                        max = 100,
                        getFunc = function() 
                            return spellData.magickaPercent 
                        end,
                        setFunc = function(value) 
                            PWSV.customResourceBlockList[spellId].magickaPercent = value
                        end,
                        width = "full",
                        disabled = function() return not (PWSV.useCustomResourceBlockList and spellData.magickaCheck) end
                    })
                    
                    -- Stamina check section
                    table.insert(controls, {
                        type = "checkbox",
                        name = COLOR.SECONDARY..PW.L("PW_MENU_RESOURCE_STAMINA_CHECK"),
                        tooltip = COLOR.SECONDARY..PW.L("PW_MENU_RESOURCE_STAMINA_CHECK_TOOLTIP"),
                        getFunc = function() 
                            return spellData.staminaCheck 
                        end,
                        setFunc = function(value) 
                            PWSV.customResourceBlockList[spellId].staminaCheck = value
                        end,
                        width = "full",
                        disabled = function() return not PWSV.useCustomResourceBlockList end
                    })
                    
                    table.insert(controls, {
                        type = "checkbox",
                        name = COLOR.SECONDARY..PW.L("PW_MENU_RESOURCE_STAMINA_BLOCK_MODE"),
                        tooltip = COLOR.SECONDARY..PW.L("PW_MENU_RESOURCE_STAMINA_BLOCK_MODE_TOOLTIP"),
                        getFunc = function() 
                            return spellData.staminaBlock 
                        end,
                        setFunc = function(value) 
                            PWSV.customResourceBlockList[spellId].staminaBlock = value
                        end,
                        width = "full",
                        disabled = function() return not (PWSV.useCustomResourceBlockList and spellData.staminaCheck) end
                    })
                    
                    table.insert(controls, {
                        type = "slider",
                        name = COLOR.SECONDARY..PW.L("PW_MENU_RESOURCE_STAMINA_THRESHOLD"),
                        tooltip = COLOR.SECONDARY..PW.L("PW_MENU_RESOURCE_STAMINA_THRESHOLD_TOOLTIP"),
                        min = 0,
                        max = 100,
                        getFunc = function() 
                            return spellData.staminaPercent 
                        end,
                        setFunc = function(value) 
                            PWSV.customResourceBlockList[spellId].staminaPercent = value
                        end,
                        width = "full",
                        disabled = function() return not (PWSV.useCustomResourceBlockList and spellData.staminaCheck) end
                    })
                    
                    -- Divider between spells
                    table.insert(controls, { type = "divider", alpha = 1.0 })
                end
                
                return controls
            end)()
        },

        -- ====================================================================================================================================================
        -- LICENSE ============================================================================================================================================
        -- ====================================================================================================================================================
        {
            type = "button",
            name = PW.L("PW_MENU_DISCLAIMER_LABEL"),
            tooltip = PW.L("PW_MENU_DISCLAIMER_TOOLTIP"),
            width = "full",
            func = function() end, 
            enabled = false, 
            style = {
                paddingTop = 40,
                labelFont = "ZoFontGameSmall",
                labelColor = ZO_SELECTED_TEXT,
                labelHorizontalAlignment = TEXT_ALIGN_LEFT,
                highlightColor = ZO_ERROR_COLOR,
            }
        }
    }

    --LAM:RegisterOptionControls(PW.name.."_LAM", optionsTable)
    LAM:RegisterOptionControls(PW.name.."Menu", options)
end


-- =============================================================================
-- === MENU TO GLOBAL FOR INITIALIZATION IN MAIN ===============================
-- =============================================================================

PerfectedWeave.BuildMenu = BuildMenu

-- =============================================================================
-- === END OF MENU SYSTEM ======================================================
-- =============================================================================