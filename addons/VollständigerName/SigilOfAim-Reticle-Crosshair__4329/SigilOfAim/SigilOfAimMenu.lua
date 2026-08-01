-- =============================================================================
-- === SigilOfAimMenu Core Logic (SigilOfAimMenu.lua)                        ===
-- =============================================================================
--[[
    AddOn Name:         SigilOfAim
    Description:        Central configuration menu for SigilOfAim reticles
    Version:            1.0.0
    Author:             VollständigerName
    Dependencies:       LibAddonMenu-2.0
--]]

-- =============================================================================
-- == GLOBAL DECLARATIONS =====================================================
-- =============================================================================

SigilOfAimMenu = {
    name = "SigilOfAim",
    version = "1.0.0",
    author = "|cEBD03CVollständigerName|r",
}

-- Local namespace alias for performance
local SOAM = SigilOfAimMenu

-- =============================================================================
-- == SAVED VARIABLES DEFINITION ==============================================
-- =============================================================================

-- Default settings structure
SOAM.defaults = {
    -- Module activation states
    dotEnabled = true,
    triangleEnabled = true,
    rectangleEnabled = true,
    
    -- Global color settings (applies to all modules)
    colors = {
        stealth = {
            enabled = true,
            r = 1.0, g = 1.0, b = 1.0, a = 0.0
        },
        dead = {
            enabled = true,
            r = 0.0, g = 0.0, b = 0.0, a = 0.0
        },
        reincarnating = {
            enabled = true,
            r = 0.1, g = 0.8, b = 0.9, a = 0.8
        },
        falling = {
            enabled = true,
            r = 0.95, g = 0.95, b = 0.95, a = 0.7
        },
        swimming = {
            enabled = true,
            r = 0.1, g = 0.3, b = 0.9, a = 0.8
        },
        stunned = {
            enabled = true,
            r = 0.0, g = 0.0, b = 0.0, a = 0.4
        },
        combat = {
            enabled = true,
            r = 0.7, g = 0.1, b = 0.1, a = 0.9
        },
        attackable = {
            enabled = true,
            r = 0.9, g = 0.3, b = 0.1, a = 0.8
        },
        interactable = {
            enabled = true,
            r = 0.9, g = 0.6, b = 0.1, a = 0.8
        },
        disguised = {
            enabled = true,
            r = 0.0, g = 0.0, b = 0.0, a = 0.4
        },
        default = {
            enabled = true,
            r = 0.95, g = 0.95, b = 0.95, a = 0.7
        }
    },
    
    -- Module-specific scale settings
    dotScale = 1.0,
    triangleScale = 0.15,
    rectangleScale = 1.0,
    
    -- Visibility settings
    showOriginalReticle = false,
    hideInMouseMode = true,
    hideInSiegeWeapon = true
}

-- SavedVariables reference
SOAM.SOASV = nil

-- =============================================================================
-- == INITIALIZATION & SAVED VARIABLES ========================================
-- =============================================================================

function SOAM.InitializeSavedVariables()
    -- Account-wide SavedVariables
    SOAM.SOASV = ZO_SavedVars:NewAccountWide("SigilOfAim_SV", 1, nil, SOAM.defaults)
    
    d("|c997F3D[Sigil of Aim]|r SavedVariables initialized")
    
    -- Pass settings to modules if they exist
    if SigilOfAimDot then
        SigilOfAimDot.SOASV = SOAM.SOASV
        SigilOfAimDot.isEnabled = SOAM.SOASV.dotEnabled
        d("|c997F3D[Sigil of Aim]|r Dot module settings applied")
    end
    
    if SigilOfAimTriangle then
        SigilOfAimTriangle.SOASV = SOAM.SOASV
        SigilOfAimTriangle.isEnabled = SOAM.SOASV.triangleEnabled
        d("|c997F3D[Sigil of Aim]|r Triangle module settings applied")
    end
    
    if SigilOfAimRectangle then
        SigilOfAimRectangle.SOASV = SOAM.SOASV
        SigilOfAimRectangle.isEnabled = SOAM.SOASV.rectangleEnabled
        d("|c997F3D[Sigil of Aim]|r Rectangle module settings applied")
    end
end

-- =============================================================================
-- == COLOR HELPER FUNCTIONS ==================================================
-- =============================================================================

function SOAM.GetColor(state)
    if not SOAM.SOASV or not SOAM.SOASV.colors or not SOAM.SOASV.colors[state] then
        return SOAM.defaults.colors[state] or SOAM.defaults.colors.default
    end
    
    local color = SOAM.SOASV.colors[state]
    return color
end

function SOAM.ApplyColorStyle(control, state, scale)
    if not control then return end
    
    -- Get color for requested state
    local color = SOAM.GetColor(state)
    
    -- If this color is disabled, use default color instead
    if not color.enabled then
        -- Get default color
        local defaultColor = SOAM.GetColor("default")
        
        -- If default color is also disabled, use fallback color
        if not defaultColor.enabled then
            -- Fallback: light gray with medium visibility
            if control.SetColor then
                control:SetColor(0.95, 0.95, 0.95, 0.7)
            end
            if control.SetScale then
                control:SetScale(scale or 1.0)
            end
        else
            -- Use default color
            if control.SetColor then
                control:SetColor(defaultColor.r, defaultColor.g, defaultColor.b, defaultColor.a)
            end
            if control.SetScale then
                control:SetScale(scale or 1.0)
            end
        end
        return
    end
    
    -- Apply the enabled color and scale
    if control.SetColor then
        control:SetColor(color.r, color.g, color.b, color.a)
    end
    if control.SetScale then
        control:SetScale(scale or 1.0)
    end
end
-- =============================================================================
-- == MODULE CONTROL FUNCTIONS ================================================
-- =============================================================================

function SOAM.SetDotEnabled(enabled)
    if not SOAM.SOASV then return end
    
    SOAM.SOASV.dotEnabled = enabled
    
    -- Update module if it exists
    if SigilOfAimDot then
        SigilOfAimDot.isEnabled = enabled
        -- Hide/show the entire UI control
        if SigilOfAimDot.SetHidden then
            SigilOfAimDot:SetHidden(not enabled)
        end
    end
    d("|c997F3D[Sigil of Aim]|r Dot enabled: " .. tostring(enabled))
end

function SOAM.SetTriangleEnabled(enabled)
    if not SOAM.SOASV then return end
    
    SOAM.SOASV.triangleEnabled = enabled
    
    -- Update module if it exists
    if SigilOfAimTriangle then
        SigilOfAimTriangle.isEnabled = enabled
        -- Hide/show the entire UI control
        if SigilOfAimTriangle.SetHidden then
            SigilOfAimTriangle:SetHidden(not enabled)
        end
    end
    d("|c997F3D[Sigil of Aim]|r Triangle enabled: " .. tostring(enabled))
end

function SOAM.SetRectangleEnabled(enabled)
    if not SOAM.SOASV then return end
    
    SOAM.SOASV.rectangleEnabled = enabled
    
    -- Update module if it exists
    if SigilOfAimRectangle then
        SigilOfAimRectangle.isEnabled = enabled
        -- Hide/show the entire UI control
        if SigilOfAimRectangle.SetHidden then
            SigilOfAimRectangle:SetHidden(not enabled)
        end
    end
    d("|c997F3D[Sigil of Aim]|r Rectangle enabled: " .. tostring(enabled))
end

-- =============================================================================
-- == LAM MENU CREATION =======================================================
-- =============================================================================

function SOAM.CreateMenu()
    local panelData = {
        type = "panel",
        name = "|c997F3DSigil of Aim|r",
        author = SOAM.author,
        version = SOAM.version,
        registerForRefresh = true,
        website = "https://github.com/VollstaendigerName",
        slashCommand = "/sigilofaim",
    }
    
    local LAM = LibAddonMenu2
    LAM:RegisterAddonPanel("SigilOfAimMenu", panelData)
    
    local optionsTable = {}
    
    -- Main enable/disable controls
    table.insert(optionsTable, {
        type = "header",
        name = "Module Activation",
        width = "full",
    })
    
    table.insert(optionsTable, {
        type = "checkbox",
        name = "Enable Dot Reticle",
        tooltip = "Enable or disable the dot reticle",
        getFunc = function() return SOAM.SOASV.dotEnabled end,
        setFunc = function(value) SOAM.SetDotEnabled(value) end,
        default = SOAM.defaults.dotEnabled,
        width = "full",
    })
    
    table.insert(optionsTable, {
        type = "checkbox",
        name = "Enable Triangle Reticle",
        tooltip = "Enable or disable the triangle reticle",
        getFunc = function() return SOAM.SOASV.triangleEnabled end,
        setFunc = function(value) SOAM.SetTriangleEnabled(value) end,
        default = SOAM.defaults.triangleEnabled,
        width = "full",
    })
    
    table.insert(optionsTable, {
        type = "checkbox",
        name = "Enable Rectangle Reticle",
        tooltip = "Enable or disable the rectangle reticle",
        getFunc = function() return SOAM.SOASV.rectangleEnabled end,
        setFunc = function(value) SOAM.SetRectangleEnabled(value) end,
        default = SOAM.defaults.rectangleEnabled,
        width = "full",
    })
    
    -- Color configuration for each state
    table.insert(optionsTable, {
        type = "header",
        name = "Color Configuration",
        width = "full",
    })
    
    table.insert(optionsTable, {
        type = "submenu",
        name = "Stealth State",
        controls = SOAM.CreateColorControls("stealth", "When player is in stealth"),
    })
    
    table.insert(optionsTable, {
        type = "submenu",
        name = "Dead State",
        controls = SOAM.CreateColorControls("dead", "When player is dead"),
    })
    
    table.insert(optionsTable, {
        type = "submenu",
        name = "Reincarnating State",
        controls = SOAM.CreateColorControls("reincarnating", "When player is reincarnating"),
    })
    
    table.insert(optionsTable, {
        type = "submenu",
        name = "Falling State",
        controls = SOAM.CreateColorControls("falling", "When player is falling"),
    })
    
    table.insert(optionsTable, {
        type = "submenu",
        name = "Swimming State",
        controls = SOAM.CreateColorControls("swimming", "When player is swimming"),
    })
    
    table.insert(optionsTable, {
        type = "submenu",
        name = "Stunned State",
        controls = SOAM.CreateColorControls("stunned", "When player is stunned"),
    })
    
    table.insert(optionsTable, {
        type = "submenu",
        name = "Combat State",
        controls = SOAM.CreateColorControls("combat", "When player is in combat"),
    })
    
    table.insert(optionsTable, {
        type = "submenu",
        name = "Attackable Target",
        controls = SOAM.CreateColorControls("attackable", "When targeting an attackable unit"),
    })
    
    table.insert(optionsTable, {
        type = "submenu",
        name = "Interactable Target",
        controls = SOAM.CreateColorControls("interactable", "When targeting an interactable object"),
    })
    
    table.insert(optionsTable, {
        type = "submenu",
        name = "Disguised State",
        controls = SOAM.CreateColorControls("disguised", "When player is disguised"),
    })
    
    table.insert(optionsTable, {
        type = "submenu",
        name = "Default State",
        controls = SOAM.CreateColorControls("default", "Normal/default state"),
    })
    
    -- Scale settings
    table.insert(optionsTable, {
        type = "header",
        name = "Scale Settings",
        width = "full",
    })
    
    table.insert(optionsTable, {
        type = "slider",
        name = "Dot Scale",
        tooltip = "Adjust the size of the dot reticle",
        min = 0.5,
        max = 2.0,
        step = 0.1,
        getFunc = function() return SOAM.SOASV.dotScale end,
        setFunc = function(value) 
            SOAM.SOASV.dotScale = value
            if SigilOfAimDot and SigilOfAimDot.UpdateScale then
                SigilOfAimDot.UpdateScale()
            end
        end,
        default = SOAM.defaults.dotScale,
        width = "full",
    })
    
    table.insert(optionsTable, {
        type = "slider",
        name = "Triangle Scale",
        tooltip = "Adjust the size of the triangle reticle",
        min = 0.05,
        max = 0.5,
        step = 0.01,
        getFunc = function() return SOAM.SOASV.triangleScale end,
        setFunc = function(value) 
            SOAM.SOASV.triangleScale = value
            if SigilOfAimTriangle and SigilOfAimTriangle.UpdateScale then
                SigilOfAimTriangle.UpdateScale()
            end
        end,
        default = SOAM.defaults.triangleScale,
        width = "full",
    })
    
    table.insert(optionsTable, {
        type = "slider",
        name = "Rectangle Scale",
        tooltip = "Adjust the size of the rectangle reticle",
        min = 0.5,
        max = 2.0,
        step = 0.1,
        getFunc = function() return SOAM.SOASV.rectangleScale end,
        setFunc = function(value) 
            SOAM.SOASV.rectangleScale = value
            if SigilOfAimRectangle and SigilOfAimRectangle.UpdateScale then
                SigilOfAimRectangle.UpdateScale()
            end
        end,
        default = SOAM.defaults.rectangleScale,
        width = "full",
    })
    
    -- Visibility settings
    table.insert(optionsTable, {
        type = "header",
        name = "Visibility Settings",
        width = "full",
    })
    
    table.insert(optionsTable, {
        type = "checkbox",
        name = "Show Original Reticle",
        tooltip = "Show the original ESO reticle alongside custom reticles",
        getFunc = function() return SOAM.SOASV.showOriginalReticle end,
        setFunc = function(value) SOAM.SOASV.showOriginalReticle = value end,
        default = SOAM.defaults.showOriginalReticle,
        width = "full",
    })
    
    table.insert(optionsTable, {
        type = "checkbox",
        name = "Hide in Mouse Mode",
        tooltip = "Hide reticles when in mouse/UI mode",
        getFunc = function() return SOAM.SOASV.hideInMouseMode end,
        setFunc = function(value) SOAM.SOASV.hideInMouseMode = value end,
        default = SOAM.defaults.hideInMouseMode,
        width = "full",
    })
    
    table.insert(optionsTable, {
        type = "checkbox",
        name = "Hide in Siege Weapon",
        tooltip = "Hide reticles when controlling siege weapons",
        getFunc = function() return SOAM.SOASV.hideInSiegeWeapon end,
        setFunc = function(value) SOAM.SOASV.hideInSiegeWeapon = value end,
        default = SOAM.defaults.hideInSiegeWeapon,
        width = "full",
    })
    
    LAM:RegisterOptionControls("SigilOfAimMenu", optionsTable)
    d("|c997F3D[Sigil of Aim]|r LAM menu created")
end

function SOAM.CreateColorControls(stateName, description)
    local controls = {}
    
    table.insert(controls, {
        type = "description",
        text = description,
        width = "full",
    })
    
    table.insert(controls, {
        type = "checkbox",
        name = "Enable Color",
        tooltip = "Enable this color state",
        getFunc = function() 
            return SOAM.SOASV.colors[stateName].enabled 
        end,
        setFunc = function(value) 
            SOAM.SOASV.colors[stateName].enabled = value 
        end,
        default = SOAM.defaults.colors[stateName].enabled,
        width = "full",
    })
    
    table.insert(controls, {
        type = "colorpicker",
        name = "Color",
        tooltip = "Select color for this state",
        getFunc = function() 
            local c = SOAM.SOASV.colors[stateName]
            return c.r, c.g, c.b, c.a
        end,
        setFunc = function(r, g, b, a) 
            SOAM.SOASV.colors[stateName].r = r
            SOAM.SOASV.colors[stateName].g = g
            SOAM.SOASV.colors[stateName].b = b
            SOAM.SOASV.colors[stateName].a = a
        end,
        default = SOAM.defaults.colors[stateName],
        disabled = function() 
            return not SOAM.SOASV.colors[stateName].enabled 
        end,
        width = "full",
    })
    
    return controls
end

-- =============================================================================
-- == EVENT HANDLING ==========================================================
-- =============================================================================

function SOAM.OnAddOnLoaded(event, addonName)
    if addonName ~= SOAM.name then return end
    
    d("|c997F3D[Sigil of Aim]|r Addon loading...")
    
    -- Initialize SavedVariables
    SOAM.InitializeSavedVariables()
    
    -- Create menu when LibAddonMenu is ready
    if LibAddonMenu2 then
        SOAM.CreateMenu()
    else
        EVENT_MANAGER:RegisterForEvent(SOAM.name, EVENT_LIBRARY_LOADED, function(event, libName)
            if libName == "LibAddonMenu-2.0" then
                SOAM.CreateMenu()
                EVENT_MANAGER:UnregisterForEvent(SOAM.name, EVENT_LIBRARY_LOADED)
            end
        end)
    end
    
    -- Debug output
    d("|c997F3D[Sigil of Aim]|r Addon loaded successfully")
    
    EVENT_MANAGER:UnregisterForEvent(SOAM.name, EVENT_ADD_ON_LOADED)
end

-- Register events
EVENT_MANAGER:RegisterForEvent(SOAM.name, EVENT_ADD_ON_LOADED, SOAM.OnAddOnLoaded)