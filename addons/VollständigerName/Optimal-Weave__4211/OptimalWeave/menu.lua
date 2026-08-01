--------------------------------------------------------------------------------
-- OptimalWeave menu.lua 
-- =============================================================================
-- AddOn Name:        OptimalWeave
-- Description:       Advanced configuration menu system for OptimalWeave AddOn
-- Authors:           Orollas & VollständigerName
-- Version:           1.17.0
-- Dependencies:      LibAddonMenu-2.0
-- =============================================================================
-- =============================================================================

local OW = OptimalWeave
local LAM = LibAddonMenu2
local OWColoredName = "|c6D6D6DOp|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve|r"
local valueMode

-- =============================================================================
-- == COLOR SCHEMA DEFINITION ==================================================
-- =============================================================================
--[[
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
    Purpose: Reusable checkbox
    Param: 
        nameKey: Localization key for display name
        tooltipKey: Localization key for tooltip text
        OWgetFunc: Function to retrieve current value
        OWsetFunc: Function to set new value
        disabledFunc: Optional function to determine disabled state
    return: Configured checkbox table    
--]]
local function CreateCheckbox(nameKey, tooltipKey, OWgetFunc, OWsetFunc, disabledFunc, reloadUICheck)
    return {
        type = "checkbox",
        name = COLOR.PRIMARY..OW.L(nameKey),
        tooltip = COLOR.SECONDARY..OW.L(tooltipKey),
        getFunc = OWgetFunc,
        setFunc = OWsetFunc,
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

--[[
    Purpose: Reusable Dropdown
    Param: 
        nameKey: Localization key for display name
        tooltipKey: Localization key for tooltip text
        OWgetFunc: Function to retrieve current value
        OWsetFunc: Function to set new value
    return: Configured dropdown table    
--]]
local function CreateDropdown(nameKey, tooltipKey, choicesKeys, OWgetFunc, OWsetFunc)
    local choices = {}
    for _, key in ipairs(choicesKeys) do
        table.insert(choices, COLOR.SECONDARY..OW.L(key))
    end
    
    return {
        type = "dropdown",
        name = COLOR.PRIMARY..OW.L(nameKey),
        tooltip = COLOR.SECONDARY..OW.L(tooltipKey),
        choices = choices,
        getFunc = OWgetFunc,
        setFunc = OWsetFunc,
        scrollable = true,
        width = "full",
        choicesValues = {4 ,1, 2, 3}
    }
end

--[[
    Purpose: Reusable slider
    Param: 
        nameKey: Localization key for display name
        tooltipKey: Localization key for tooltip text
        min: Minimum slider value
        max: Maximum slider value
        OWgetFunc: Function to retrieve current value
        OWsetFunc: Function to set new value
        disabledFunc: Optional function to determine disabled state
    return: Configured slider table    
--]]
local function CreateSlider(nameKey, tooltipKey, min, max, OWgetFunc, OWsetFunc, disabledFunc)
    return {
        type = "slider",
        name = COLOR.PRIMARY..OW.L(nameKey),
        tooltip = COLOR.SECONDARY..OW.L(tooltipKey),
        min = min,
        max = max,
        getFunc = OWgetFunc,
        setFunc = OWsetFunc,
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
    return: Section header
--]]

local function CreateSectionHeader()
    return {

        type = "description",
        fontSize = "medium"
    }
end

-- =============================================================================
-- == CREATE RELOAD CONFIRMATION DIALOG ========================================
-- =============================================================================
--[[
Purpose: Registers a standardized UI dialog for requesting player confirmation
        before performing a UI reload after settings changes.
--]]

ZO_Dialogs_RegisterCustomDialog("OW_RELOAD_DIALOG", {
    canQueue = true,
    title = {
        text = OWColoredName
    },
    mainText = {
        text = COLOR.PRIMARY .. OW.L("OW_MENU_RELOAD_DIALOG_MAIN_TEXT")
    },
    buttons = {
        {
            text = COLOR.ACCENT .. OW.L("OW_MENU_RELOAD_DIALOG_BUTTON_YES"),
            callback = function()
                ReloadUI() 
            end
        },
        {
            text = COLOR.SECONDARY .. OW.L("OW_MENU_RELOAD_DIALOG_BUTTON_LATER"),
            callback = function()
            end
        }
    }
})

-- =============================================================================
-- == CREATE SETTINGS MODE RELOAD DIALOG =======================================
-- =============================================================================
--[[
Purpose: Registers a standardized UI dialog for requesting player confirmation
        before performing a UI reload after changing the settings mode
        (account-wide vs. per character).
--]]
ZO_Dialogs_RegisterCustomDialog("OW_RELOAD_DIALOG_SETTINGS", {
    canQueue = true,
    title = {
        text = OWColoredName
    },
    mainText = {
        text = COLOR.PRIMARY .. OW.L("OW_MENU_RELOAD_DIALOG_SETTINGS_MAIN_TEXT")
    },
    buttons = {
        {
            text = COLOR.ACCENT .. OW.L("OW_MENU_RELOAD_DIALOG_BUTTON_YES"),
            callback = function()
                ReloadUI()
            end
        },
        {
            text = COLOR.SECONDARY .. OW.L("OW_MENU_RELOAD_DIALOG_BUTTON_LATER"),
            callback = function()
            end
        }
    }
})

-- =============================================================================
-- == CREATE ERROR CONFIRMATION DIALOG =========================================
-- =============================================================================
ZO_Dialogs_RegisterCustomDialog("OW_INVALID_ID_DIALOG", {
    canQueue = true,
    title = {
        text = OWColoredName
    },
    mainText = {
        text = COLOR.WARNING .. OW.L("OW_MENU_INVALID_ID_DIALOG_MAIN_TEXT")
    },
    buttons = {
        {
            text = COLOR.ACCENT .. OW.L("OW_MENU_DIALOG_BUTTON_OK"),
            callback = function()
            end
        }
    }
})

ZO_Dialogs_RegisterCustomDialog("OW_ID_NOT_EXIST_DIALOG", {
    canQueue = true,
    title = {
        text = OWColoredName
    },
    mainText = {
        text = COLOR.WARNING .. OW.L("OW_MENU_ID_NOT_EXIST_DIALOG_MAIN_TEXT")
    },
    buttons = {
        {
            text = COLOR.ACCENT .. OW.L("OW_MENU_DIALOG_BUTTON_OK"),
            callback = function()
            end
        }
    }
})

ZO_Dialogs_RegisterCustomDialog("OW_ID_IS_IN_SV_DIALOG", {
    canQueue = true,
    title = {
        text = OWColoredName
    },
    mainText = {
        text = COLOR.WARNING .. OW.L("OW_MENU_ID_IS_IN_SV_DIALOG_MAIN_TEXT")
    },
    buttons = {
        {
            text = COLOR.ACCENT .. OW.L("OW_MENU_DIALOG_BUTTON_OK"),
            callback = function()
            end
        }
    }
})

-- =============================================================================
-- == MAIN MENU CONSTRUCTION ===================================================
-- =============================================================================
--[[
    Purpose: Construct complete configuration interface
   
    Structure of the Menu:
    - Information section with core mechanics
    - Core mechanics
    - Activation conditions 
    - Advanced controls 
    - (Sub)class-specific settings 
    - Weapon type deactivation 
    - Performance settings 
    - User-configurable block lists
    - Legal disclaimer
--]]
-- Main panel definition
local function BuildMenu(sv, defaults)
    local panel = {
        type = "panel",
        name = OW.name,
        displayName = COLOR.ACCENT..OW.L("OW_MENU_PANEL_NAME"),
        author = COLOR.SECONDARY..OW.L("OW_MENU_AUTHORS"),
        version = COLOR.PRIMARY..OW.version,
        website = OW.L("OW_MENU_WEBSITE"),
        registerForRefresh = true,
        --registerForDefaults = true,
        slashCommand = "/optimalweave",
    }
    OW.panel = LAM:RegisterAddonPanel(OW.name.."Menu", panel)
    -- =============================================================================
    -- == BLOCK LIST MENU ==========================================================
    -- =============================================================================
    --[[
        Purpose: Adds a spell to the block list.
    --]]
    local function AddSpellToBlockList()
        --local spellId = tonumber(_G["OW_TEMP_SPELL_ID"])
        local spellId = tonumber(OW.TEMP_SPELL_ID) 
        
        -- Check whether a valid ID has been entered
        if not spellId or spellId <= 1000 or spellId >= 500000 then
            ZO_Dialogs_ShowDialog("OW_INVALID_ID_DIALOG")
            return
        end
        
        -- Check if Spell exists 
        local AbilityName = GetAbilityName(spellId)
        if AbilityName == nil or AbilityName == "" then
            ZO_Dialogs_ShowDialog("OW_ID_NOT_EXIST_DIALOG")
            --d(OWColoredName.."Error: Spell-ID " .. spellId .. " does not exist")
            return
        end
        
        -- Prevent duplicates
        if sv.customBlockList[spellId] ~= nil then
            ZO_Dialogs_ShowDialog("OW_ID_IS_IN_SV_DIALOG")
            --d(OWColoredName.."Note: Spell ID  " ..  spellId .. ", Spell " .. zo_strformat("<<1>>", AbilityName) .. " is already in the block list")
            return
        end
        
        -- Add Spell to block list
        sv.customBlockList[spellId] = false  -- Default: not blocked
        --_G["OW_TEMP_SPELL_ID"] = ""  -- Clear input field
        OW.TEMP_SPELL_ID = ""
        ZO_Dialogs_ShowDialog("OW_RELOAD_DIALOG")
        --d(OWColoredName.."Spell-ID " .. spellId .. ", Spell " .. zo_strformat("<<1>>", AbilityName) .. " has been added to the block list")
    end

    -- =============================================================================
    -- == RECAST BLOCK LIST MENU ===================================================
    -- =============================================================================
    --[[
        Purpose: Adds a spell to the recast block list.
    --]]
    local function AddSpellToRecastBlockList()
        --local spellId = tonumber(_G["OW_TEMP_RECAST_SPELL_ID"])
        local spellId = tonumber(OW.TEMP_RECAST_SPELL_ID)
        
        -- Check whether a valid ID has been entered
        if not spellId or spellId <= 1000 or spellId >= 500000 then
            ZO_Dialogs_ShowDialog("OW_INVALID_ID_DIALOG")
            return
        end
        
        -- Check if Spell exists 
        local AbilityName = GetAbilityName(spellId)
        if AbilityName == nil or AbilityName == "" then
            ZO_Dialogs_ShowDialog("OW_ID_NOT_EXIST_DIALOG")
            --d(OWColoredName.."Error: Spell-ID " .. spellId .. " does not exist")
            return
        end
        
        -- Prevent duplicates
        if sv.customRecastBlockList[spellId] ~= nil then
            ZO_Dialogs_ShowDialog("OW_ID_IS_IN_SV_DIALOG")
            --d(OWColoredName.."Note: Spell ID  " ..  spellId .. ", Spell " .. zo_strformat("<<1>>", AbilityName) .. " is already in the block list")
            return
        end
        
        -- Add Spell to block list
        sv.customRecastBlockList[spellId] = false  -- Default: not blocked
        OW.TEMP_RECAST_SPELL_ID = ""--_G["OW_TEMP_RECAST_SPELL_ID"] = ""  -- Clear input field
        ZO_Dialogs_ShowDialog("OW_RELOAD_DIALOG")
        --d(OWColoredName.."Spell-ID " .. spellId .. ", Spell " .. zo_strformat("<<1>>", AbilityName) .. " has been added to the block list")
    end

    -- =============================================================================
    -- == RESOURCE BLOCK LIST MENU =================================================
    -- =============================================================================
    --[[
        Purpose: Adds a spell to the block list.
    --]]
local function AddSpellToResourceBlockList()
    local spellId = tonumber(OW.TEMP_RESOURCE_SPELL_ID) 
    
    -- Check whether a valid ID has been entered
    if not spellId or spellId <= 1000 or spellId >= 500000 then
        ZO_Dialogs_ShowDialog("OW_INVALID_ID_DIALOG")
        return
    end
    
    -- Check if Spell exists 
    local AbilityName = GetAbilityName(spellId)
    if AbilityName == nil or AbilityName == "" then
        ZO_Dialogs_ShowDialog("OW_ID_NOT_EXIST_DIALOG")
        return
    end
    
    -- Prevent duplicates
    if sv.customResourceBlockList[spellId] ~= nil then
        ZO_Dialogs_ShowDialog("OW_ID_IS_IN_SV_DIALOG")
        return
    end
    
    -- Add Spell to block list with new structure
    sv.customResourceBlockList[spellId] = {
        blocked = false,           -- Complete blocked
        magickaCheck = false,      -- If Magicka check is used
        magickaBlock = false,      -- Block when magicka below threshold (true=block, false=allow only)
        magickaPercent = 0,        -- Magicka percentage threshold
        staminaCheck = false,      -- If Stamina check is used
        staminaBlock = false,      -- Block when stamina below threshold (true=block, false=allow only)
        staminaPercent = 0,        -- Stamina percentage threshold
    }
    
    OW.TEMP_RESOURCE_SPELL_ID = "" -- Clear input field
    ZO_Dialogs_ShowDialog("OW_RELOAD_DIALOG")
end

    -- =============================================================================
    -- == MENU =====================================================================
    -- =============================================================================
    -- Register main panel with LibAddonMenu
    --LAM:RegisterAddonPanel(OW.name.."Menu", panel)
    --OW.panel = LAM:RegisterAddonPanel(OW.name.."Menu", panel)
    -- Complete menu structure definition
    local options = {
        -- Information Section (flat, no submenu)
        {
            type = "description",
            text = COLOR.SECONDARY..OW.L("OW_MENU_INFO_TEXT"),
            fontSize = "medium",
            width = "full"
        },

        -- ====================================================================================================================================================
        -- Core Mechanics Submenu =============================================================================================================================
        -- ====================================================================================================================================================
        -- { -- Removed for better visibility
        --     type = "submenu",            
        --     name = COLOR.ACCENT..OW.L("OW_MENU_MODE_HEADER"),
        --     controls = {
                CreateSectionHeader(OW.L("OW_MENU_MODE_HEADER")),
                {
                    type = "dropdown",
                    name = COLOR.PRIMARY..OW.L("OW_MENU_MODE_SELECTION_LABEL"),
                    tooltip = COLOR.SECONDARY..OW.L("OW_MENU_MODE_SELECTION_TOOLTIP"),
                    choices = {
                        COLOR.SECONDARY..OW.L("OW_MENU_MODE_ACCOUNTWIDE"),
                        COLOR.SECONDARY..OW.L("OW_MENU_MODE_PERCHARACTER")
                    },
                    choicesValues = { "accountwide", "character" },
                    getFunc = function() return OW.accSV.modeSelection end,
                    setFunc = function(value)
                        OW.accSV.modeSelection = value
                        ZO_Dialogs_ShowDialog("OW_RELOAD_DIALOG_SETTINGS")
                    end,
                    width = "full",
                    scrollable = true,
                },

                { type = "divider", alpha = 0.2 }, -- =====================================================================================

                CreateDropdown(
                    "OW_MENU_MODE_LABEL",
                    "OW_MENU_MODE_TOOLTIP",
                    {"OW_MENU_MODE_CHOICE_COND", "OW_MENU_MODE_CHOICE_HARD", "OW_MENU_MODE_CHOICE_SOFT", "OW_MENU_MODE_CHOICE_NONE"},
                    function() return sv.mode end,
   
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
                        
                        sv.originalMode = 0
                        sv.mode = tonumber(valueMode) 
                    end
                ),
                CreateCheckbox(
                    "OW_MENU_GROUNDAOE_LABEL",
                    "OW_MENU_GROUNDAOE_TOOLTIP",
                    function() return sv.blockGroundAbilities end,
                    function(value) sv.blockGroundAbilities = value end
                ),
           -- }
       -- },

        -- ====================================================================================================================================================
        -- Activation Conditions Submenu ======================================================================================================================
        -- ====================================================================================================================================================
        {
            type = "submenu",
            name = COLOR.ACCENT..OW.L("OW_MENU_CONDITIONS_HEADER"),
            controls = {
                CreateSectionHeader(OW.L("OW_MENU_CONDITIONS_HEADER")),
                CreateCheckbox(
                    "OW_MENU_COMBAT_LABEL",
                    "OW_MENU_COMBAT_TOOLTIP",
                    function() return sv.combat end,
                    function(value) sv.combat = value end
                ),
                CreateCheckbox(
                    "OW_MENU_ENEMYTARGET_LABEL",
                    "OW_MENU_ENEMYTARGET_TOOLTIP",
                    function() return sv.checkTarget end,
                    function(value) sv.checkTarget = value end
                ),
                CreateCheckbox(
                    "OW_MENU_BLOCKING_LABEL",
                    "OW_MENU_BLOCKING_TOOLTIP",
                    function() return sv.block end,
                    function(value) sv.block = value end
                ),

                CreateCheckbox(
                    "OW_MENU_BLOCKLISTS_COMBAT_ONLY_LABEL",
                    "OW_MENU_BLOCKLISTS_COMBAT_ONLY_TOOLTIP",
                    function() return sv.blockListsCombatOnly end,
                    function(value) sv.blockListsCombatOnly = value end
                ),

                { type = "divider", alpha = 0.2 }, -- =====================================================================================

                CreateCheckbox(
                    "OW_MENU_DISABLE_TANK",
                    "OW_MENU_DISABLE_TANK_TOOLTIP",
                    function() return sv.disableTank end,
                    function(value) 
                        sv.disableTank = value
                        OW.CheckRoleOverride()
                    end
                ),
                CreateCheckbox(
                    "OW_MENU_DISABLE_HEAL",
                    "OW_MENU_DISABLE_HEAL_TOOLTIP",
                    function() return sv.disableHeal end,
                    function(value) 
                        sv.disableHeal = value
                        OW.CheckRoleOverride()
                    end
                ),

                { type = "divider", alpha = 0.2 }, -- =====================================================================================

                CreateCheckbox(
                    "OW_MENU_DISABLE_FEATURES_ON_BACKBAR",
                    "OW_MENU_DISABLE_FEATURES_ON_BACKBAR_TOOLTIP",
                    function() return sv.deactivateOnBackbar.features end,
                    function(value) 
                        sv.deactivateOnBackbar.features = value
                    end
                ),
                CreateCheckbox(
                    "OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR",
                    "OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR_TOOLTIP",
                    function() return sv.deactivateOnBackbar.weaveAssist end,
                    function(value) 
                        sv.deactivateOnBackbar.weaveAssist = value
                    end
                ),

                { type = "divider", alpha = 0.2 }, -- =====================================================================================

                CreateCheckbox(
                    "OW_MENU_DISABLE_FEATURES_IN_PVP",
                    "OW_MENU_DISABLE_FEATURES_IN_PVP_TOOLTIP",
                    function() return sv.deactivateInPvP.features end,
                    function(value) sv.deactivateInPvP.features = value end
                ),

                CreateCheckbox(
                    "OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP",
                    "OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP_TOOLTIP",
                    function() return sv.deactivateInPvP.weaveAssist end,
                    function(value) sv.deactivateInPvP.weaveAssist = value end
                ),

                -- { type = "divider", alpha = 0.2 }, -- ===================================================================================== 

                -- CreateCheckbox( -- Dosen´t work!, will fix it later (Wish from kalitva) =================================================== 
                --     "OW_MENU_BLOCKAOEIFNOTARGET_LABEL",
                --     "OW_MENU_BLOCKAOEIFNOTARGET_TOOLTIP",
                --     function() return sv.blockAoEIfNoTarget end,
                --     function(value) sv.blockAoEIfNoTarget = value end
                -- ),
            }
        },

        -- ====================================================================================================================================================
        -- Advanced Controls Submenu ==========================================================================================================================
        -- ====================================================================================================================================================
        {
            type = "submenu",
            name = COLOR.ACCENT..OW.L("OW_MENU_ADVANCED_HEADER"),
            controls = {
                CreateSectionHeader(OW.L("OW_MENU_ADVANCED_HEADER")),
                CreateCheckbox(
                    "OW_MENU_RESETONDODGE_LABEL",
                    "OW_MENU_RESETONDODGE_TOOLTIP",
                    function() return sv.resetOnDodge end,
                    function(value) sv.resetOnDodge = value end
                ),

                CreateCheckbox(
                    "OW_MENU_RESETONBARSWAP_LABEL",
                    "OW_MENU_RESETONBARSWAP_TOOLTIP",
                    function() return sv.resetOnBarswap end,
                    function(value) sv.resetOnBarswap = value end
                ),
                
                -- Channel Buffer Settings
                CreateSlider(
                    "OW_MENU_CHANNEL_NORMAL", 
                    "OW_MENU_CHANNEL_NORMAL_TOOLTIP", 
                    0, 100, -- 0-100ms (Default 50)
                    function() return sv.channelBufferNormal end,
                    function(value) sv.channelBufferNormal = value end
                ),
                CreateSlider(
                    "OW_MENU_CHANNEL_CHANNELED", 
                    "OW_MENU_CHANNEL_CHANNELED_TOOLTIP", 
                    0, 400, -- 0-400ms (Default 200)
                    function() return sv.channelBufferChanneled end,
                    function(value) sv.channelBufferChanneled = value end
                ),
                                
                -- GCD Thresholds
                CreateSlider(
                    "OW_MENU_MIN_GCD", 
                    "OW_MENU_MIN_GCD_TOOLTIP", 
                    0, 50, -- 0-50ms (Default 10)
                    function() return sv.minGcdThreshold end,
                    function(value) sv.minGcdThreshold = value end
                ),
                CreateSlider(
                    "OW_MENU_QUEUE_TIME", 
                    "OW_MENU_QUEUE_TIME_TOOLTIP", 
                    100, 2000, -- 100-2000ms (Default 1050)
                    function() return sv.baseQueueTime end,
                    function(value) sv.baseQueueTime = value end
                ),

                CreateCheckbox(
                    "OW_MENU_AUTO_GCD_SLOT_LABEL",
                    "OW_MENU_AUTO_GCD_SLOT_TOOLTIP",
                    function() return sv.autoGcdTrackingSlot end,
                    function(value) sv.autoGcdTrackingSlot = value end
                ),

                CreateSlider(
                    "OW_MENU_GCD_SLOT",
                    "OW_MENU_GCD_SLOT_TOOLTIP", 
                    3, 8, -- GCD tracking slot (Spells between 3 to 8), Light Attack 1
                    function() return sv.gcdTrackingSlot end,
                    function(value) sv.gcdTrackingSlot = value end,
                    function() return sv.autoGcdTrackingSlot end
                ),

                CreateSlider(
                    "OW_MENU_RESET_TIME_LABEL",
                    "OW_MENU_RESET_TIME_TOOLTIP", 
                    1, 60, -- Min: 1 seconds, Max: 60 seconds
                    function() return sv.resetAfterSeconds end,
                    function(value) sv.resetAfterSeconds = value end
                ),

                 CreateCheckbox(
                    "OW_MENU_SHOW_GCD_LABEL",
                    "OW_MENU_SHOW_GCD_TOOLTIP",
                    function() return sv.showGCD end,
                    function(value) sv.showGCD = value end,
                    nil,
                    false
                ),

                { type = "divider", alpha = 0.2 }, -- =====================================================================================

                -- Automatic Weapon Equipping
                CreateCheckbox(
                    "OW_MENU_AUTO_EQUIP_WEAPONS_LABEL",
                    "OW_MENU_AUTO_EQUIP_WEAPONS_TOOLTIP",
                    function() return sv.autoEquipWeapons end,
                    function(value) sv.autoEquipWeapons = value end,
                    nil,
                    true
                ),

                { type = "divider", alpha = 0.2 }, -- =====================================================================================

                CreateCheckbox(
                    "OW_MENU_BLOCK_LAST_MENU",
                    "OW_MENU_BLOCK_LAST_MENU_TOOLTIP",
                    function() return sv.blockLastMenu end,
                    function(value) sv.blockLastMenu = value end,
                    nil,
                    true
                ),
                CreateCheckbox(
                    "OW_MENU_BLOCK_CHAR_MENU",
                    "OW_MENU_BLOCK_CHAR_MENU_TOOLTIP",
                    function() return sv.blockCharMenu end,
                    function(value) sv.blockCharMenu = value end,
                    nil,
                    true
                ),
                
                { type = "divider", alpha = 0.2 }, -- =====================================================================================

                -- Reset Settings Button
                {
                    type = "button",
                    name = COLOR.WARNING..OW.L("OW_MENU_RESET_SETTINGS_LABEL"),
                    tooltip = COLOR.SECONDARY..OW.L("OW_MENU_RESET_SETTINGS_TOOLTIP"),
                    width = "full",
                    isDangerous = true,
                    func = function()
                        -- Overwrite savedvariables (sv) with defaults
                        for key, value in pairs(defaults) do
                            if type(value) == "table" then
                                sv[key] = {}
                                for subkey, subvalue in pairs(value) do
                                    sv[key][subkey] = subvalue
                                end
                            else
                                sv[key] = value
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
            name = COLOR.ACCENT..OW.L("OW_MENU_SUBCLASS_HEADER"),
            controls = {
                CreateSectionHeader(OW.L("OW_MENU_SUBCLASS_HEADER")),
                {
                    type = "header",
                    name = COLOR.PRIMARY..OW.L("OW_MENU_SUBCLASS_GRIMFOCUS"),
                    width = "full"
                },
                
                -- Grim Focus (and Morphs)
                CreateCheckbox(
                    "OW_MENU_GRIMFOCUS_ALL_MORPHS",
                    "OW_MENU_GRIMFOCUS_ALL_MORPHS_TOOLTIP",
                    function() return sv.grimFocusSkillIds[61919] and sv.grimFocusSkillIds[61927] and sv.grimFocusSkillIds[61902] end,
                    function(value) 
                        sv.grimFocusSkillIds[61919] = value
                        sv.grimFocusSkillIds[61927] = value
                        sv.grimFocusSkillIds[61902] = value
                        sv.useGrimFocusStacks = false
                    end
                ),

                CreateCheckbox(
                    "OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE",
                    "OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE_TOOLTIP",
                    function() return sv.useGrimFocusStacks end,
                    function(value) 
                        sv.useGrimFocusStacks = value
                    end,
                    function() return sv.grimFocusSkillIds[61919] end
                ),
                
                { type = "divider", alpha = 0.2 }, -- =====================================================================================
                
                -- Grim Focus Stacks Slider
                CreateSlider(
                    "OW_MENU_GRIMFOCUS_STACKS",
                    "OW_MENU_GRIMFOCUS_STACKS_TOOLTIP",
                    5, 10, -- Min:5, Max:10 Stacks
                    function() return sv.grimFocusStacks end,
                    function(value) sv.grimFocusStacks = value end,
                    function() return not sv.useGrimFocusStacks end
                ),
                
                -- Arcanist Fatecarver
                CreateSectionHeader(OW.L("OW_MENU_SUBCLASS_HEADER")),
                {
                    type = "header",
                    name = COLOR.PRIMARY..OW.L("OW_MENU_SUBCLASS_FATECARVER"),
                    width = "full"
                },
                
                -- Fatecarver (and Morphs)
                CreateCheckbox(
                    "OW_MENU_FATECARVER_ALL_MORPHS",
                    "OW_MENU_FATECARVER_ALL_MORPHS_TOOLTIP",
                    function() return sv.arcaBeamSkillIds[186366] and sv.arcaBeamSkillIds[186366] and sv.arcaBeamSkillIds[186366] end,
                    function(value) 
                        sv.arcaBeamSkillIds[185805] = value -- Base Mag
                        sv.arcaBeamSkillIds[183122] = value -- Exhausting Fatecarver Mag
                        sv.arcaBeamSkillIds[186366] = value -- Pragmatic Fatecarver Mag
                        sv.arcaBeamSkillIds[193397] = value -- Base
                        sv.arcaBeamSkillIds[193398] = value -- Exhausting Fatecarver
                        sv.arcaBeamSkillIds[193331] = value -- Pragmatic Fatecarver
                        sv.useCruxStacks = value
                        --d(tostring(value))
                    end
                ),

                -- Crux Stack Slider
                CreateSlider(
                    "OW_MENU_CRUX_STACKS",
                    "OW_MENU_CRUX_STACKS_TOOLTIP",
                    1, 3, -- Min:1, Max:3 Stacks
                    function() return sv.cruxStacks end,
                    function(value) sv.cruxStacks = value end,
                    function() return not sv.useCruxStacks end
                ),

                { type = "divider", alpha = 0.2 }, -- =====================================================================================

                -- Deactivate under certain HP toggle
                CreateCheckbox(
                    "OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE",
                    "OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE_TOOLTIP",
                    function() return sv.checkHpForArcaBeam end,
                    function(value) 
                        sv.checkHpForArcaBeam = value
                    end
                ),
                
                { type = "divider", alpha = 0.2 }, -- =====================================================================================
                
                -- Deactivate under certain HP Slider
                CreateSlider(
                    "OW_MENU_CHECK_HP_FOR_BEAM",
                    "OW_MENU_CHECK_HP_FOR_BEAM_TOOLTIP",
                    0, 100, -- Min:0, Max:100 % HP
                    function() return sv.deactivateArcaBeamBlockAtHpUnder end,
                    function(value) sv.deactivateArcaBeamBlockAtHpUnder = value end,
                    function() return not sv.checkHpForArcaBeam end
                ),

                { type = "divider", alpha = 0.2 }, -- =====================================================================================

                -- Deactivate under certain Stam toggle
                CreateCheckbox(
                    "OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE",
                    "OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE_TOOLTIP",
                    function() return sv.checkStamForArcaBeam end,
                    function(value) 
                        sv.checkStamForArcaBeam = value
                    end
                ),
                
                
                -- Deactivate under certain HP Slider
                CreateSlider(
                    "OW_MENU_CHECK_STAMINA_FOR_BEAM",
                    "OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOLTIP",
                    0, 100, -- Min:0, Max:100 % Stam
                    function() return sv.deactivateArcaBeamBlockAtStamUnder end,
                    function(value) sv.deactivateArcaBeamBlockAtStamUnder = value end,
                    function() return not sv.checkStamForArcaBeam end
                ),

                -- Arcanist Cephaliarch's Flail
                CreateSectionHeader(OW.L("OW_MENU_SUBCLASS_HEADER")),
                {
                    type = "header",
                    name = COLOR.PRIMARY..OW.L("OW_MENU_SUBCLASS_CEPHALIARCHSFLAIL"),
                    width = "full"
                },

                -- Cephaliarch's Flail
                CreateCheckbox(
                    "OW_MENU_CEPHALIARCHSFLAIL",
                    "OW_MENU_CEPHALIARCHSFLAIL_TOOLTIP",
                    function() return sv.cephaliarchsFlail[183006] end,
                    function(value) 
                        sv.cephaliarchsFlail[183006] = value
                        sv.useCruxStacksCephaliarch = value
                    end
                ),

                -- Arcanist Tentacular Dread
                CreateSectionHeader(OW.L("OW_MENU_SUBCLASS_HEADER")),
                {
                    type = "header",
                    name = COLOR.PRIMARY..OW.L("OW_MENU_SUBCLASS_TENTACULAR"),
                    width = "full"
                },
                
                -- Tentacular
                CreateCheckbox(
                    "OW_MENU_TENTACULAR",
                    "OW_MENU_TENTACULAR_TOOLTIP",
                    function() return sv.tentacularDread[185823] end,
                    function(value) 
                        sv.tentacularDread[185823] = value -- Tentacular Dread
                        sv.usecruxStacksTentacular = value
                        --d(tostring(value))
                    end
                ),
                
                -- Crux Stack Slider
                CreateSlider(
                    "OW_MENU_CRUX_STACKS",
                    "OW_MENU_TENTACULAR_TOOLTIP",
                    1, 3, -- Min:1, Max:3 Stacks
                    function() return sv.cruxStacksTentacular end,
                    function(value) sv.cruxStacksTentacular = value end,
                    function() return not sv.usecruxStacksTentacular end
                ),

                -- Dragonknight Molten Whip
                CreateSectionHeader(OW.L("OW_MENU_SUBCLASS_HEADER")),
                {
                    type = "header",
                    name = COLOR.PRIMARY..OW.L("OW_MENU_SUBCLASS_MOLTENWHIP"),
                    width = "full"
                },

                -- Molten Whip
                CreateCheckbox(
                    "OW_MENU_MOLTENWHIP_BLOCK",
                    "OW_MENU_MOLTENWHIP_BLOCK_TOOLTIP",
                    function() return sv.MoltenWhip[20805] end,
                    function(value) 
                        sv.MoltenWhip[20805] = value
                    end
                ),

                -- Execute Check 
                {
                    type = "header",
                    name = COLOR.PRIMARY..OW.L("OW_MENU_EXECUTE_HEADER"),
                    width = "full"
                },
                
                -- Enable/Disable Execute Check
                CreateCheckbox(
                    "OW_MENU_EXECUTE_ENABLE",
                    "OW_MENU_EXECUTE_ENABLE_TOOLTIP",
                    function() return sv.useExecuteCheck end,
                    function(value) sv.useExecuteCheck = value end
                ),
                
                -- Execute Threshold Slider
                CreateSlider(
                    "OW_MENU_EXECUTE_THRESHOLD",
                    "OW_MENU_EXECUTE_THRESHOLD_TOOLTIP",
                    0, 100, -- 0-100%
                    function() return sv.executeThreshold end,
                    function(value) sv.executeThreshold = value end,
                    function() return not sv.useExecuteCheck end
                ),
                                
                -- Execute Spells Header
                {
                    type = "header",
                    name = COLOR.PRIMARY..OW.L("OW_MENU_EXECUTE_SPELLS_HEADER"),
                    width = "full"
                },
                
                -- Radiant Destruction and Morphs 
                CreateCheckbox(
                    "OW_MENU_EXECUTE_SPELL_RADIANTMORPHS",
                    "OW_MENU_EXECUTE_SPELL_RADIANTMORPHS_TOOLTIP",
                    function() return sv.executeCheckSpells[63029] end,
                    function(value) 
                        sv.executeCheckSpells[63029] = value
                        sv.executeCheckSpells[63044] = value
                        sv.executeCheckSpells[63046] = value
                    end,
                    function() return not sv.useExecuteCheck end
                ),
                
                -- Assassin's Blade and Morphs
                CreateCheckbox(
                    "OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS",
                    "OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS_TOOLTIP",
                    function() return sv.executeCheckSpells[33386] end,
                    function(value) 
                        sv.executeCheckSpells[33386] = value
                        sv.executeCheckSpells[34851] = value
                        sv.executeCheckSpells[34843] = value
                    end,
                    function() return not sv.useExecuteCheck end
                ),

                 -- Mages' Fury and Morphs 
                CreateCheckbox(
                    "OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS",
                    "OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS_TOOLTIP",
                    function() return sv.executeCheckSpells[19123] end,
                    function(value) 
                        sv.executeCheckSpells[19123] = value
                        sv.executeCheckSpells[18718] = value
                        sv.executeCheckSpells[19109] = value
                    end,
                    function() return not sv.useExecuteCheck end
                ),

                -- Reverse Slash and Morphs
                CreateCheckbox(
                    "OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS",
                    "OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS_TOOLTIP",
                    function() return sv.executeCheckSpells[28302] end,
                    function(value) 
                        sv.executeCheckSpells[28302] = value
                        sv.executeCheckSpells[38823] = value
                        sv.executeCheckSpells[38819] = value
                    end,
                    function() return not sv.useExecuteCheck end
                ),

                -- guild
                CreateSectionHeader(OW.L("OW_MENU_SUBCLASS_HEADER")),
                {
                    type = "header",
                    name = COLOR.PRIMARY..OW.L("OW_MENU_SUBCLASS_GUILDS"),
                    width = "full"
                },
                -- Mages guild
                CreateCheckbox(
                    "OW_MENU_LIGHT_ALL_MORPHS",
                    "OW_MENU_LIGHT_ALL_MORPHS_TOOLTIP",
                    function() return sv.lightMorphs[30920] and sv.lightMorphs[40478] and sv.lightMorphs[40483] end,
                    function(value) 
                        sv.lightMorphs[30920] = value
                        sv.lightMorphs[40478] = value
                        sv.lightMorphs[40483] = value
                    end
                ),

                { type = "divider", alpha = 0.2 }, -- =====================================================================================
                
                -- Fighter guild
                CreateCheckbox(
                    "OW_MENU_HUNTER_ALL_MORPHS",
                    "OW_MENU_HUNTER_ALL_MORPHS_TOOLTIP",
                    function() return sv.hunterMorphs[35762] and sv.hunterMorphs[40195] and sv.hunterMorphs[40194] end,
                    function(value) 
                        sv.hunterMorphs[35762] = value
                        sv.hunterMorphs[40195] = value
                        sv.hunterMorphs[40194] = value
                    end
                ),

                { type = "divider", alpha = 0.2 }, -- =====================================================================================
                
                -- Deactivate Hunter and light block in PvP
                CreateCheckbox(
                    "OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS",
                    "OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS_TOOLTIP",
                    function() return sv.deactivateHunterLightInPvP end,
                    function(value) 
                        sv.deactivateHunterLightInPvP = value
                    end
                ),
            }
        },

        -- ====================================================================================================================================================
        -- Weapon Type Deactivation Submenu ===================================================================================================================
        -- ====================================================================================================================================================
        {
            type = "submenu",
            name = COLOR.ACCENT..OW.L("OW_MENU_DEACTIVATE_ON_WEAPON_HEADER"),
            controls = {
                CreateSectionHeader(OW.L("OW_MENU_DEACTIVATE_ON_WEAPON_HEADER")),

                CreateCheckbox(
                    "OW_MENU_DISABLE_FEATURES_ON_WEAPON",
                    "OW_MENU_DISABLE_FEATURES_ON_WEAPON_TOOLTIP",
                    function() return sv.deactivateOnWeapon.features end,
                    function(value) 
                        sv.deactivateOnWeapon.features = value
                    end
                ),
                CreateCheckbox(
                    "OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON",
                    "OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON_TOOLTIP",
                    function() return sv.deactivateOnWeapon.weaveAssist end,
                    function(value) 
                        sv.deactivateOnWeapon.weaveAssist = value
                    end
                ),
                
                { type = "divider", alpha = 1.0 }, -- =====================================================================================

                -- One-handed weapons
                CreateCheckbox(
                    "OW_MENU_DEACTIVATE_ON_WEAPON_AXE",
                    "OW_MENU_DEACTIVATE_ON_WEAPON_AXE_TOOLTIP",
                    function() return sv.deactivateOnWeaponType.axe end,
                    function(value) sv.deactivateOnWeaponType.axe = value end,
                    function() return not (sv.deactivateOnWeapon.features or sv.deactivateOnWeapon.weaveAssist) end
                ),
                CreateCheckbox(
                    "OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER",
                    "OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER_TOOLTIP",
                    function() return sv.deactivateOnWeaponType.hammer end,
                    function(value) sv.deactivateOnWeaponType.hammer = value end,
                    function() return not (sv.deactivateOnWeapon.features or sv.deactivateOnWeapon.weaveAssist) end
                ),
                CreateCheckbox(
                    "OW_MENU_DEACTIVATE_ON_WEAPON_SWORD",
                    "OW_MENU_DEACTIVATE_ON_WEAPON_SWORD_TOOLTIP",
                    function() return sv.deactivateOnWeaponType.sword end,
                    function(value) sv.deactivateOnWeaponType.sword = value end,
                    function() return not (sv.deactivateOnWeapon.features or sv.deactivateOnWeapon.weaveAssist) end
                ),
                CreateCheckbox(
                    "OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER",
                    "OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER_TOOLTIP",
                    function() return sv.deactivateOnWeaponType.dagger end,
                    function(value) sv.deactivateOnWeaponType.dagger = value end,
                    function() return not (sv.deactivateOnWeapon.features or sv.deactivateOnWeapon.weaveAssist) end
                ),
                
                { type = "divider", alpha = 0.2 }, -- =====================================================================================
                
                -- Two-handed weapons
                CreateCheckbox(
                    "OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD",
                    "OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD_TOOLTIP",
                    function() return sv.deactivateOnWeaponType.twoHandedSword end,
                    function(value) sv.deactivateOnWeaponType.twoHandedSword = value end,
                    function() return not (sv.deactivateOnWeapon.features or sv.deactivateOnWeapon.weaveAssist) end
                ),
                CreateCheckbox(
                    "OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE",
                    "OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE_TOOLTIP",
                    function() return sv.deactivateOnWeaponType.twoHandedAxe end,
                    function(value) sv.deactivateOnWeaponType.twoHandedAxe = value end,
                    function() return not (sv.deactivateOnWeapon.features or sv.deactivateOnWeapon.weaveAssist) end
                ),
                CreateCheckbox(
                    "OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER",
                    "OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER_TOOLTIP",
                    function() return sv.deactivateOnWeaponType.twoHandedHammer end,
                    function(value) sv.deactivateOnWeaponType.twoHandedHammer = value end,
                    function() return not (sv.deactivateOnWeapon.features or sv.deactivateOnWeapon.weaveAssist) end
                ),
                CreateCheckbox(
                    "OW_MENU_DEACTIVATE_ON_WEAPON_BOW",
                    "OW_MENU_DEACTIVATE_ON_WEAPON_BOW_TOOLTIP",
                    function() return sv.deactivateOnWeaponType.bow end,
                    function(value) sv.deactivateOnWeaponType.bow = value end,
                    function() return not (sv.deactivateOnWeapon.features or sv.deactivateOnWeapon.weaveAssist) end
                ),
                
                { type = "divider", alpha = 0.2 }, -- =====================================================================================
                
                -- Staves
                CreateCheckbox(
                    "OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF",
                    "OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF_TOOLTIP",
                    function() return sv.deactivateOnWeaponType.fireStaff end,
                    function(value) sv.deactivateOnWeaponType.fireStaff = value end,
                    function() return not (sv.deactivateOnWeapon.features or sv.deactivateOnWeapon.weaveAssist) end
                ),
                CreateCheckbox(
                    "OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF",
                    "OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF_TOOLTIP",
                    function() return sv.deactivateOnWeaponType.frostStaff end,
                    function(value) sv.deactivateOnWeaponType.frostStaff = value end,
                    function() return not (sv.deactivateOnWeapon.features or sv.deactivateOnWeapon.weaveAssist) end
                ),
                CreateCheckbox(
                    "OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF",
                    "OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF_TOOLTIP",
                    function() return sv.deactivateOnWeaponType.lightningStaff end,
                    function(value) sv.deactivateOnWeaponType.lightningStaff = value end,
                    function() return not (sv.deactivateOnWeapon.features or sv.deactivateOnWeapon.weaveAssist) end
                ),
                CreateCheckbox(
                    "OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF",
                    "OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF_TOOLTIP",
                    function() return sv.deactivateOnWeaponType.healingStaff end,
                    function(value) sv.deactivateOnWeaponType.healingStaff = value end,
                    function() return not (sv.deactivateOnWeapon.features or sv.deactivateOnWeapon.weaveAssist) end
                ),
                
                { type = "divider", alpha = 0.2 }, -- =====================================================================================
                
                -- Other weapons
                CreateCheckbox(
                    "OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD",
                    "OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD_TOOLTIP",
                    function() return sv.deactivateOnWeaponType.shield end,
                    function(value) sv.deactivateOnWeaponType.shield = value end,
                    function() return not (sv.deactivateOnWeapon.features or sv.deactivateOnWeapon.weaveAssist) end
                ),
                -- CreateCheckbox(
                --     "OW_MENU_DEACTIVATE_ON_WEAPON_RUNE",
                --     "OW_MENU_DEACTIVATE_ON_WEAPON_RUNE_TOOLTIP",
                --     function() return sv.deactivateOnWeaponType.rune end,
                --     function(value) sv.deactivateOnWeaponType.rune = value end,
                --     function() return not (sv.deactivateOnWeapon.features or sv.deactivateOnWeapon.weaveAssist) end
                -- ),
                -- CreateCheckbox(
                --     "OW_MENU_DEACTIVATE_ON_WEAPON_NONE",
                --     "OW_MENU_DEACTIVATE_ON_WEAPON_NONE_TOOLTIP",
                --     function() return sv.deactivateOnWeaponType.none end,
                --     function(value) sv.deactivateOnWeaponType.none = value end,
                --     function() return not (sv.deactivateOnWeapon.features or sv.deactivateOnWeapon.weaveAssist) end
                -- ),
                -- CreateCheckbox(
                --     "OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED",
                --     "OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED_TOOLTIP",
                --     function() return sv.deactivateOnWeaponType.reservedWeapon end,
                --     function(value) sv.deactivateOnWeaponType.reservedWeapon = value end,
                --     function() return not (sv.deactivateOnWeapon.features or sv.deactivateOnWeapon.weaveAssist) end
                -- )
            }
        },

        -- ====================================================================================================================================================
        -- Performance Settings ===============================================================================================================================
        -- ====================================================================================================================================================
        {
            type = "submenu",
            name = COLOR.ACCENT..OW.L("OW_MENU_PERFORMANCE_HEADER"),
            controls = {
                CreateSectionHeader(OW.L("OW_MENU_PERFORMANCE_HEADER")),
                CreateCheckbox(
                    "OW_MENU_AUTOLATENCY_LABEL",
                    "OW_MENU_AUTOLATENCY_TOOLTIP",
                    function() return sv.autoLag end,
                    function(value) sv.autoLag = value end
                ),
                CreateSlider(
                    "OW_MENU_MANUALLATENCY_LABEL",
                    "OW_MENU_MANUALLATENCY_TOOLTIP",
                    0,
                    200,
                    function() return sv.inputLag end,
                    function(value) sv.inputLag = value end,
                    function() return sv.autoLag end
                )
            }
        },

        -- ====================================================================================================================================================
        -- USER-CONFIGURABLE BLOCK LIST =======================================================================================================================
        -- ====================================================================================================================================================
        {
            type = "submenu",            
            name = COLOR.ACCENT..OW.L("OW_MENU_BLOCKLIST_HEADER"),
            controls = {
        {
            type = "submenu",
            name = COLOR.ACCENT..OW.L("OW_MENU_CONFIGURABLEBLOCK_HEADER"),
            controls = (function()
                local controls = {
                    CreateSectionHeader(OW.L("OW_MENU_CONFIGURABLEBLOCK_HEADER")),
                    {
                        type = "description",
                        text = COLOR.SECONDARY..OW.L("OW_MENU_CUSTOMBLOCK_DESC"),
                        width = "full"
                    },

                    CreateCheckbox(
                        "OW_MENU_USE_CUSTOM_BLOCK_LIST",
                        "OW_MENU_USE_CUSTOM_BLOCK_LIST_TOOLTIP",
                        function() return sv.useCustomBlockList end,
                        function(value) sv.useCustomBlockList = value end
                    ),

                    { type = "divider", alpha = 0.2 }, -- =====================================================================================

                    -- Health Check for Block List
                    CreateCheckbox(
                        "OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK",
                        "OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK_TOOLTIP",
                        function() return sv.useCustomBlockListHealthCheck end,
                        function(value) sv.useCustomBlockListHealthCheck = value end,
                        function() return not sv.useCustomBlockList end
                    ),

                    -- Health Percent Slider for Block List
                    CreateSlider(
                        "OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT",
                        "OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP",
                        0, 100, -- 0-100%
                        function() return sv.useCustomBlockListHealthPercent end,
                        function(value) sv.useCustomBlockListHealthPercent = value end,
                        function() return not (sv.useCustomBlockList and sv.useCustomBlockListHealthCheck) end
                    ),

                    { type = "divider", alpha = 0.2 }, -- =====================================================================================

                    {
                        type = "editbox",
                        name = COLOR.PRIMARY..OW.L("OW_MENU_CUSTOMBLOCK_SPELLID_LABEL"),
                        tooltip = COLOR.SECONDARY..OW.L("OW_MENU_CUSTOMBLOCK_SPELLID_TOOLTIP"),
                        getFunc = function() return OW.TEMP_SPELL_ID or "" end,--_G["OW_TEMP_SPELL_ID"] or "" end,
                        setFunc = function(value) 
                            --_G["OW_TEMP_SPELL_ID"] = value
                            OW.TEMP_SPELL_ID = value 
                        end,
                        width = "full"
                    },
                    {
                        type = "button",
                        name = COLOR.PRIMARY..OW.L("OW_MENU_CUSTOMBLOCK_ADD_BUTTON"),
                        func = function()
                            AddSpellToBlockList()
                        end,
                        --requiresReload = true,
                        width = "full"
                    },

                    { type = "divider", alpha = 0.2 }, -- =====================================================================================
                    
                    {
                        type = "description",
                        text = COLOR.ACCENT..OW.L("OW_MENU_CUSTOMBLOCK_LIST_HEADER"),
                        width = "full"
                    },
                }
                
                -- Dynamically generated checkboxes for each spell ID in customRecastBlockList
                local spellIds = {}
                for spellId, _ in pairs(sv.customBlockList) do
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
                            return sv.customBlockList[spellId] 
                        end,
                        setFunc = function(value) 
                            sv.customBlockList[spellId] = value
                        end,
                        width = "full"
                    })
                    --Remove Button for each spell in block list
                    table.insert(controls, {
                    type = "button",
                    name = COLOR.WARNING..OW.L("OW_MENU_CUSTOMBLOCK_REMOVE_BUTTON"),
                    tooltip = OW.L("OW_MENU_CUSTOMBLOCK_REMOVE_TOOLTIP"),
                    width = "full",
                    func = function()
                        sv.customBlockList[spellId] = nil
                        ZO_Dialogs_ShowDialog("OW_RELOAD_DIALOG")
                    end
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
            name = COLOR.ACCENT..OW.L("OW_MENU_CONFIGURABLERECASTBLOCK_HEADER"),
            controls = (function()
                local controls = {
                    CreateSectionHeader(OW.L("OW_MENU_CONFIGURABLERECASTBLOCK_HEADER")),
                    {
                        type = "description",
                        text = COLOR.SECONDARY..OW.L("OW_MENU_CUSTOMRECASTBLOCK_DESC"),
                        width = "full"
                    },

                    CreateCheckbox(
                        "OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST",
                        "OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_TOOLTIP",
                        function() return sv.useCustomRecastBlockList end,
                        function(value) sv.useCustomRecastBlockList = value end
                    ),

                    CreateSlider(
                        "OW_MENU_RECAST_BLOCK_TIME",
                        "OW_MENU_RECAST_BLOCK_TIME_TOOLTIP",
                        0, 120, -- 0-120s (Default 1)
                        function() return sv.recastBlockTime end,
                        function(value) sv.recastBlockTime = value end,
                        function() return not sv.useCustomRecastBlockList end
                    ),
                    
                    { type = "divider", alpha = 0.2 }, -- =====================================================================================

                    -- Health Check for Recast Block List
                    CreateCheckbox(
                        "OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK",
                        "OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK_TOOLTIP",
                        function() return sv.useCustomRecastBlockListHealthCheck end,
                        function(value) sv.useCustomRecastBlockListHealthCheck = value end,
                        function() return not sv.useCustomRecastBlockList end
                    ),

                    -- Health Percent Slider for Recast Block List
                    CreateSlider(
                        "OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT",
                        "OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP",
                        0, 100, -- 0-100%
                        function() return sv.useCustomRecastBlockListHealthPercent end,
                        function(value) sv.useCustomRecastBlockListHealthPercent = value end,
                        function() return not (sv.useCustomRecastBlockList and sv.useCustomRecastBlockListHealthCheck) end
                    ),
                    
                    { type = "divider", alpha = 0.2 }, -- =====================================================================================

                    {
                        type = "editbox",
                        name = COLOR.PRIMARY..OW.L("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_LABEL"),
                        tooltip = COLOR.SECONDARY..OW.L("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_TOOLTIP"),
                        getFunc = function() return OW.TEMP_RECAST_SPELL_ID or "" end,--_G["OW_TEMP_RECAST_SPELL_ID"] or "" end,
                        setFunc = function(value) 
                            OW.TEMP_RECAST_SPELL_ID = value--_G["OW_TEMP_RECAST_SPELL_ID"] = value
                        end,
                        width = "full"
                    },
                    {
                        type = "button",
                        name = COLOR.PRIMARY..OW.L("OW_MENU_CUSTOMRECASTBLOCK_ADD_BUTTON"),
                        func = function()
                            AddSpellToRecastBlockList()
                        end,
                        --requiresReload = true,
                        width = "full"
                    },

                    { type = "divider", alpha = 0.2 }, -- =====================================================================================

                    {
                        type = "description",
                        text = COLOR.ACCENT..OW.L("OW_MENU_CUSTOMRECASTBLOCK_LIST_HEADER"),
                        width = "full"
                    },
                }
                
                -- Dynamically generated checkboxes for each spell ID in customRecastBlockList
                local spellIds = {}
                for spellId, _ in pairs(sv.customRecastBlockList) do
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
                            return sv.customRecastBlockList[spellId] 
                        end,
                        setFunc = function(value) 
                            sv.customRecastBlockList[spellId] = value
                        end,
                        width = "full"
                    })
                    --Remove Button for each spell in recast block list
                    table.insert(controls, {
                    type = "button",
                    name = COLOR.WARNING..OW.L("OW_MENU_CUSTOMBLOCK_REMOVE_BUTTON"),
                    tooltip = OW.L("OW_MENU_CUSTOMBLOCK_REMOVE_TOOLTIP"),
                    width = "full",
                    func = function()
                        sv.customRecastBlockList[spellId] = nil
                        ZO_Dialogs_ShowDialog("OW_RELOAD_DIALOG")
                    end
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
            name = COLOR.ACCENT..OW.L("OW_MENU_CONFIGURABLEBLOCK_RESOURCE_HEADER"),
            controls = (function()
                local controls = {
                    CreateSectionHeader(OW.L("OW_MENU_CONFIGURABLEBLOCK_RESOURCE_HEADER")),
                    {
                        type = "description",
                        text = COLOR.SECONDARY..OW.L("OW_MENU_CUSTOMBLOCK_RESOURCE_DESC"),
                        width = "full"
                    },

                    CreateCheckbox(
                        "OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST",
                        "OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST_TOOLTIP",
                        function() return sv.useCustomResourceBlockList end,
                        function(value) sv.useCustomResourceBlockList = value end
                    ),

                    { type = "divider", alpha = 0.2 }, -- =====================================================================================

                    {
                        type = "editbox",
                        name = COLOR.PRIMARY..OW.L("OW_MENU_CUSTOMBLOCK_SPELLID_LABEL"),
                        tooltip = COLOR.SECONDARY..OW.L("OW_MENU_CUSTOMBLOCK_SPELLID_TOOLTIP"),
                        getFunc = function() return OW.TEMP_RESOURCE_SPELL_ID or "" end,
                        setFunc = function(value) 
                            OW.TEMP_RESOURCE_SPELL_ID = value
                        end,
                        width = "full"
                    },
                    {
                        type = "button",
                        name = COLOR.PRIMARY..OW.L("OW_MENU_CUSTOMBLOCK_ADD_BUTTON"),
                        func = function()
                            AddSpellToResourceBlockList()
                        end,
                        width = "full"
                    },

                    { type = "divider", alpha = 0.2 }, -- =====================================================================================
                    
                    {
                        type = "description",
                        text = COLOR.ACCENT..OW.L("OW_MENU_CUSTOMBLOCK_LIST_HEADER"),
                        width = "full"
                    },
                }
                
                -- Dynamically generated controls for each spell ID in customResourceBlockList
                local spellIds = {}
                for spellId, _ in pairs(sv.customResourceBlockList) do
                    table.insert(spellIds, spellId)
                end
                table.sort(spellIds)
                
                for _, spellId in ipairs(spellIds) do
                    local spellData = sv.customResourceBlockList[spellId]
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
                            sv.customResourceBlockList[spellId].blocked = value
                        end,
                        width = "full"
                    })
                    
                    -- Magicka check section
                    table.insert(controls, {
                        type = "checkbox",
                        name = COLOR.SECONDARY..OW.L("OW_MENU_RESOURCE_MAGICKA_CHECK"),
                        tooltip = COLOR.SECONDARY..OW.L("OW_MENU_RESOURCE_MAGICKA_CHECK_TOOLTIP"),
                        getFunc = function() 
                            return spellData.magickaCheck 
                        end,
                        setFunc = function(value) 
                            sv.customResourceBlockList[spellId].magickaCheck = value
                        end,
                        width = "half",
                        disabled = function() return not sv.useCustomResourceBlockList end
                    })
                    
                    table.insert(controls, {
                        type = "checkbox",
                        name = COLOR.SECONDARY..OW.L("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE"),
                        tooltip = COLOR.SECONDARY..OW.L("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE_TOOLTIP"),
                        getFunc = function() 
                            return spellData.magickaBlock 
                        end,
                        setFunc = function(value) 
                            sv.customResourceBlockList[spellId].magickaBlock = value
                        end,
                        width = "half",
                        disabled = function() return not (sv.useCustomResourceBlockList and spellData.magickaCheck) end
                    })
                    
                    table.insert(controls, {
                        type = "slider",
                        name = COLOR.SECONDARY..OW.L("OW_MENU_RESOURCE_MAGICKA_THRESHOLD"),
                        tooltip = COLOR.SECONDARY..OW.L("OW_MENU_RESOURCE_MAGICKA_THRESHOLD_TOOLTIP"),
                        min = 0,
                        max = 100,
                        getFunc = function() 
                            return spellData.magickaPercent 
                        end,
                        setFunc = function(value) 
                            sv.customResourceBlockList[spellId].magickaPercent = value
                        end,
                        width = "full",
                        disabled = function() return not (sv.useCustomResourceBlockList and spellData.magickaCheck) end
                    })
                    
                    -- Stamina check section
                    table.insert(controls, {
                        type = "checkbox",
                        name = COLOR.SECONDARY..OW.L("OW_MENU_RESOURCE_STAMINA_CHECK"),
                        tooltip = COLOR.SECONDARY..OW.L("OW_MENU_RESOURCE_STAMINA_CHECK_TOOLTIP"),
                        getFunc = function() 
                            return spellData.staminaCheck 
                        end,
                        setFunc = function(value) 
                            sv.customResourceBlockList[spellId].staminaCheck = value
                        end,
                        width = "half",
                        disabled = function() return not sv.useCustomResourceBlockList end
                    })
                    
                    table.insert(controls, {
                        type = "checkbox",
                        name = COLOR.SECONDARY..OW.L("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE"),
                        tooltip = COLOR.SECONDARY..OW.L("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE_TOOLTIP"),
                        getFunc = function() 
                            return spellData.staminaBlock 
                        end,
                        setFunc = function(value) 
                            sv.customResourceBlockList[spellId].staminaBlock = value
                        end,
                        width = "half",
                        disabled = function() return not (sv.useCustomResourceBlockList and spellData.staminaCheck) end
                    })
                    
                    table.insert(controls, {
                        type = "slider",
                        name = COLOR.SECONDARY..OW.L("OW_MENU_RESOURCE_STAMINA_THRESHOLD"),
                        tooltip = COLOR.SECONDARY..OW.L("OW_MENU_RESOURCE_STAMINA_THRESHOLD_TOOLTIP"),
                        min = 0,
                        max = 100,
                        getFunc = function() 
                            return spellData.staminaPercent 
                        end,
                        setFunc = function(value) 
                            sv.customResourceBlockList[spellId].staminaPercent = value
                        end,
                        width = "full",
                        disabled = function() return not (sv.useCustomResourceBlockList and spellData.staminaCheck) end
                    })
                    
                    -- Remove Button for each spell in resource block list
                    table.insert(controls, {
                        type = "button",
                        name = COLOR.WARNING..OW.L("OW_MENU_CUSTOMBLOCK_REMOVE_BUTTON"),
                        tooltip = OW.L("OW_MENU_CUSTOMBLOCK_REMOVE_TOOLTIP"),
                        width = "full",
                        func = function()
                            sv.customResourceBlockList[spellId] = nil
                            ZO_Dialogs_ShowDialog("OW_RELOAD_DIALOG")
                        end
                    })
                    
                    -- Divider between spells
                    table.insert(controls, { type = "divider", alpha = 1.0 })
                end
                
                return controls
            end)()
        },
        },
        },

        -- ====================================================================================================================================================
        -- LICENSE ============================================================================================================================================
        -- ====================================================================================================================================================
        {
            type = "button",
            name = OW.L("OW_MENU_DISCLAIMER_LABEL"),
            tooltip = OW.L("OW_MENU_DISCLAIMER_TOOLTIP"),
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

    --LAM:RegisterOptionControls(OW.name.."_LAM", optionsTable)
    LAM:RegisterOptionControls(OW.name.."Menu", options)
end


-- =============================================================================
-- === MENU TO GLOBAL FOR INITIALIZATION IN MAIN ===============================
-- =============================================================================

OptimalWeave.BuildMenu = BuildMenu

-- =============================================================================
-- === END OF MENU SYSTEM ======================================================
-- =============================================================================