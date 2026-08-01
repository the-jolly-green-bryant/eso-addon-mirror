-- Beltalowda Settings Menu
-- LibAddonMenu-2.0 integration for addon configuration

Beltalowda = Beltalowda or {}
Beltalowda.Settings = Beltalowda.Settings or {}

local Settings = Beltalowda.Settings

-- Default settings
Settings.defaults = {
    logging = {
        enabled = true,
        defaultLevel = 1,  -- ERROR
        moduleLevels = {
            Network = 1,    -- ERROR
            Ultimates = 1,  -- ERROR
            Equipment = 1,  -- ERROR
            General = 1,    -- ERROR
        },
        maxLogEntries = 200,
        verboseReset = true,
    },
    composition = {
        preferences = {
            -- Damage sets
            [232] = "optional",  -- Roar of Alkosh
            [617] = "optional",  -- Plaguebreak
            [236] = "optional",  -- Vicious Death
            [225] = "optional",  -- Clever Alchemist
            
            -- Support sets
            [629] = "optional",  -- Rallying Cry
            [180] = "optional",  -- Powerful Assault
            [768] = "optional",  -- Lucent Echoes
            [346] = "optional",  -- Jorvuld's Guidance
            [818] = "optional",  -- Recovery Convergence
            [518] = "optional",  -- Arkasis' Genius
            
            -- Pull sets
            [616] = "optional",  -- Dark Convergence
            [558] = "optional",  -- Void Bash
            [604] = "optional",  -- Rush of Agony
        }
    },
    leaderBeam = {
        enabled = false,
        beamThickness = 1,
        color = {
            r = 0,
            g = 0.5,
            b = 1,
            a = 0.75
        }
    },
    leaderArrow = {
        enabled = false,
        mode = "reticle",
        fixedPositionX = nil,
        fixedPositionY = nil,
    },
    powerfulAssault = {
        enabled = true,
        showWhenGroupHasPA = false,
        showOnlyInCombat = true,
        scale = 1.0,
        positionX = 200,
        positionY = 200,
    },
    rallyingCry = {
        enabled = true,
        showWhenGroupHasRC = false,
        showOnlyInCombat = true,
        scale = 1.0,
        positionX = 250,
        positionY = 250,
    },
    showInMenus = false,
    pvpOnly = true,
    namingStyle = "character",  -- "character" or "userid"
    rdkCompatEnabled = false,
    toolbox = {
        recharger = {
            enabled = false,
            sendChatMessages = true,
            percent = 5,
            checkInterval = 150,
            alerts = { login = true, empty = true, threshold = true },
            threshold = 100,
        },
        repair = {
            enabled = false,
            sendChatMessages = true,
            percent = 10,
            checkInterval = 150,
            alerts = { login = true, empty = true, threshold = true },
            threshold = 14,
        },
        cyrodiilPins = {
            volendrungEnabled = true,
            volendrungAlwaysShow = false,
            wellsEnabled = true,
            volendrungFilterPve = false,
            volendrungFilterPvp = true,
            wellsFilterPve = false,
            wellsFilterPvp = true,
            wellTimestamps = {},  -- well index → GetTimeStamp() epoch when taken
        },
        siegeMerchant = {
            enabled = false,
            sendChatMessages = true,
            paymentOption = 1,
            items = {
                repairKit           = 0,
                ballistaFire        = 0,
                ballistaStone       = 0,
                ballistaLightning   = 0,
                trebuchetFire       = 0,
                trebuchetStone      = 0,
                trebuchetIce        = 0,
                catapultMeatbag     = 0,
                catapultOil         = 0,
                catapultScattershot = 0,
                flamingOil          = 0,
                forwardCamp         = 0,
                batteringRam        = 0,
                keepRecall          = 0,
                potionHealth        = 0,
                potionBattle        = 0,
                potionSpell         = 0,
            },
        },
    },
}

--[[
    Initialize settings panel
    Should be called after addon is loaded
]]--
function Settings.Initialize()
    -- Don't initialize if LibAddonMenu isn't available
    if not LibAddonMenu2 then
        return false
    end
    
    -- Ensure defaults are set
    Settings.ApplyDefaults()
    
    -- Create the settings panel
    Settings.CreatePanel()
    
    return true
end

--[[
    Apply default settings if they don't exist
]]--
function Settings.ApplyDefaults()
    -- Ensure BeltalowdaVars exists (should be initialized in OnAddOnLoaded)
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.logging = BeltalowdaVars.logging or {}
    BeltalowdaVars.composition = BeltalowdaVars.composition or {}
    BeltalowdaVars.composition.preferences = BeltalowdaVars.composition.preferences or {}
    BeltalowdaVars.composition.synergyPreferences = BeltalowdaVars.composition.synergyPreferences or {}
    BeltalowdaVars.composition.buffPreferences = BeltalowdaVars.composition.buffPreferences or {}
    if BeltalowdaVars.composition.mundusWarning == nil then
        BeltalowdaVars.composition.mundusWarning = false
    end
    if BeltalowdaVars.composition.trackChampionPoints == nil then
        BeltalowdaVars.composition.trackChampionPoints = true
    end

    -- Notification settings
    BeltalowdaVars.notifications = BeltalowdaVars.notifications or {}
    if BeltalowdaVars.notifications.foodExpiry == nil then
        BeltalowdaVars.notifications.foodExpiry = true
    end
    if BeltalowdaVars.notifications.foodExpirySelf == nil then
        BeltalowdaVars.notifications.foodExpirySelf = true
    end
    
    -- Migrate deprecated buff preference values → required
    for buffName, pref in pairs(BeltalowdaVars.composition.buffPreferences) do
        if pref == "required_individual" or pref == "required_unique" then
            BeltalowdaVars.composition.buffPreferences[buffName] = "required"
        end
    end
    
    -- Migrate renamed buff preference key
    if BeltalowdaVars.composition.buffPreferences["Snare/Immob Immunity"] then
        if not BeltalowdaVars.composition.buffPreferences["Immunity to Snares and Immobilizations"] then
            BeltalowdaVars.composition.buffPreferences["Immunity to Snares and Immobilizations"] =
                BeltalowdaVars.composition.buffPreferences["Snare/Immob Immunity"]
        end
        BeltalowdaVars.composition.buffPreferences["Snare/Immob Immunity"] = nil
    end
    
    -- Migrate SPC (185) from individual set prefs to buff-level prefs
    -- If user had SPC set to a non-optional preference, don't lose that intent
    if BeltalowdaVars.composition.preferences[185] then
        local oldPref = BeltalowdaVars.composition.preferences[185]
        if oldPref ~= "optional" and not BeltalowdaVars.composition.buffPreferences["Major Courage"] then
            -- Map set-level pref to buff-level pref
            if oldPref ~= "optional" then
                BeltalowdaVars.composition.buffPreferences["Major Courage"] = "required"
            end
        end
        BeltalowdaVars.composition.preferences[185] = nil
    end
    
    -- Migrate old set IDs to corrected ones
    local setIdMigrations = {
        [637] = 818,  -- Recovery Convergence: old incorrect ID → correct ID
        [643] = 617,  -- Plaguebreak: old incorrect ID → correct ID
        [152] = 225,  -- Clever Alchemist: old incorrect ID → correct ID
        [659] = 629,  -- Rallying Cry: old incorrect ID → correct ID
        [305] = 180,  -- Powerful Assault: old incorrect ID → correct ID
        [635] = 768,  -- Lucent Echoes: old incorrect ID → correct ID
        [817] = 818,  -- Recovery Convergence: old incorrect ID → correct ID
        [583] = 518,  -- Arkasis' Genius: old incorrect ID → correct ID
        [140] = 185,  -- Spell Power Cure: old incorrect ID → correct ID
        [642] = 616,  -- Dark Convergence: old incorrect ID → correct ID
        [641] = 558,  -- Void Bash: old incorrect ID → correct ID
        [644] = 604,  -- Rush of Agony: old incorrect ID → correct ID
    }
    for oldId, newId in pairs(setIdMigrations) do
        if BeltalowdaVars.composition.preferences[oldId] then
            -- Only migrate if the new ID doesn't already have a preference
            if not BeltalowdaVars.composition.preferences[newId] then
                BeltalowdaVars.composition.preferences[newId] = BeltalowdaVars.composition.preferences[oldId]
            end
            BeltalowdaVars.composition.preferences[oldId] = nil
        end
    end
    
    -- Apply defaults for missing values
    if BeltalowdaVars.logging.enabled == nil then
        BeltalowdaVars.logging.enabled = Settings.defaults.logging.enabled
    end
    
    if not BeltalowdaVars.logging.defaultLevel then
        BeltalowdaVars.logging.defaultLevel = Settings.defaults.logging.defaultLevel
    end
    
    -- Apply composition preference defaults
    for setId, preference in pairs(Settings.defaults.composition.preferences) do
        if not BeltalowdaVars.composition.preferences[setId] then
            BeltalowdaVars.composition.preferences[setId] = preference
        end
    end
    
    -- Apply buff preference defaults (all optional by default)
    local BuffDB = Beltalowda.Data and Beltalowda.Data.BuffDatabase
    if BuffDB and BuffDB.BUFF_DEFINITIONS then
        for buffName, _ in pairs(BuffDB.BUFF_DEFINITIONS) do
            if not BeltalowdaVars.composition.buffPreferences[buffName] then
                BeltalowdaVars.composition.buffPreferences[buffName] = "optional"
            end
        end
    end
    
    if not BeltalowdaVars.logging.moduleLevels then
        BeltalowdaVars.logging.moduleLevels = {}
        for module, level in pairs(Settings.defaults.logging.moduleLevels) do
            BeltalowdaVars.logging.moduleLevels[module] = level
        end
    end
    
    if not BeltalowdaVars.logging.maxLogEntries then
        BeltalowdaVars.logging.maxLogEntries = Settings.defaults.logging.maxLogEntries
    end
    
    if BeltalowdaVars.logging.verboseReset == nil then
        BeltalowdaVars.logging.verboseReset = Settings.defaults.logging.verboseReset
    end

    if BeltalowdaVars.showInMenus == nil then
        BeltalowdaVars.showInMenus = Settings.defaults.showInMenus
    end

    if BeltalowdaVars.pvpOnly == nil then
        BeltalowdaVars.pvpOnly = Settings.defaults.pvpOnly
    end

    if not BeltalowdaVars.namingStyle then
        BeltalowdaVars.namingStyle = Settings.defaults.namingStyle
    end
end

--[[
    Create the LibAddonMenu settings panel
]]--
function Settings.CreatePanel()
    local LAM = LibAddonMenu2
    
    -- Create the panel
    local panelData = {
        type = "panel",
        name = "Beltalowda",
        displayName = "Beltalowda",
        author = "Kickimanjaro",
        version = Beltalowda.version or "0.5.4",
        slashCommand = "/btlwsettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    
    LAM:RegisterAddonPanel("BeltalowdaSettings", panelData)
    
    -- Create the options
    local optionsData = {
        {
            type = "description",
            text = "Beltalowda is a group coordination addon designed primarily for PvP. It detects each player's role and organises most of its features around three PvP-specific roles that are similar to, but distinct from, their PvE counterparts:\n\n"
                .. "|cFF8000Pull|r — groups enemies together\n"
                .. "|cFF4C4CDamage|r — kills them\n"
                .. "|c4CFF4CSupport|r — keeps everyone alive\n\n"
                .. "You can set preferences for your group's composition (sets, buffs, and synergies). When these preferences are not met, on-screen warnings highlight what is missing.\n\n"
                .. "Ultimate and synergy trackers are grouped by role so you can choose to see only the information relevant to your role, or view the entire group at once.\n\n"
                .. "Additional trackers help coordinate group damage timing and ensure the group has Expedition buffs for speed.",
            width = "full",
        },
        -- Global: Naming Style
        {
            type = "dropdown",
            name = "Naming Style",
            tooltip = "How player names are displayed throughout the addon.\n\nCharacter Name — the name of the character (e.g. Kick the Concept)\nUserID — the account name (e.g. @kick_me)",
            choices = {"Character Name", "UserID"},
            getFunc = function()
                local style = BeltalowdaVars.namingStyle or "character"
                if style == "userid" then return "UserID" end
                return "Character Name"
            end,
            setFunc = function(value)
                if value == "UserID" then
                    BeltalowdaVars.namingStyle = "userid"
                else
                    BeltalowdaVars.namingStyle = "character"
                end
            end,
            width = "full",
            default = "Character Name",
        },
        -- Global: Show UI in Menus
        {
            type = "checkbox",
            name = "Show UI in Menus",
            tooltip = "When enabled, Beltalowda UI elements remain visible when menus and inventory are open. Cursor mode (for dragging unlocked windows) always shows UI elements regardless of this setting.",
            getFunc = function()
                return BeltalowdaVars.showInMenus or false
            end,
            setFunc = function(value)
                BeltalowdaVars.showInMenus = value
                if Beltalowda.UpdateMenuVisibility then
                    Beltalowda.UpdateMenuVisibility()
                end
            end,
            width = "full",
            default = false,
        },
        -- Global: Show in PvP Only
        {
            type = "checkbox",
            name = "Show in PvP Only",
            tooltip = "When enabled, all Beltalowda UI elements are hidden outside of PvP zones (Cyrodiil, Imperial City, and Battlegrounds). Disable this to use Beltalowda in PvE zones as well.",
            getFunc = function()
                return BeltalowdaVars.pvpOnly
            end,
            setFunc = function(value)
                BeltalowdaVars.pvpOnly = value
                if Beltalowda.UpdatePvPVisibility then
                    Beltalowda.UpdatePvPVisibility()
                end
            end,
            width = "full",
            default = true,
        },
    }
    
    -- Helper to append a module's settings controls to optionsData
    local function appendModuleControls(module)
        if module and module.GetSettingsControls then
            local controls = module.GetSettingsControls()
            for _, control in ipairs(controls) do
                table.insert(optionsData, control)
            end
        end
    end
    
    -- ── Group Composition ────────────────────────────────────────────
    table.insert(optionsData, {type = "header", name = "Group Composition"})
    table.insert(optionsData, {type = "description", text = "Analyze your group's composition for potential issues. Tracks missing buffs, duplicate sets, unused synergies, and your consumable buffs with expiration timers.", width = "full"})
    appendModuleControls(Beltalowda.UI and Beltalowda.UI.CompositionWarnings)            -- Warnings & Consumables
    table.insert(optionsData, {
        type = "submenu",
        name = "Chat Notifications",
        tooltip = "Receive chat notifications when group members lose their food or drink buff",
        controls = {
            {
                type = "description",
                text = "Receive chat notifications when group members lose their food or drink buff. Messages appear in your chat window via the system channel.",
                width = "full",
            },
            {
                type = "checkbox",
                name = GetString(BELTALOWDA_NOTIF_FOOD_EXPIRY),
                tooltip = GetString(BELTALOWDA_NOTIF_FOOD_EXPIRY_TOOLTIP),
                getFunc = function()
                    return BeltalowdaVars and BeltalowdaVars.notifications
                        and BeltalowdaVars.notifications.foodExpiry or false
                end,
                setFunc = function(value)
                    BeltalowdaVars.notifications = BeltalowdaVars.notifications or {}
                    BeltalowdaVars.notifications.foodExpiry = value
                end,
                width = "full",
                default = true,
            },
            {
                type = "checkbox",
                name = GetString(BELTALOWDA_NOTIF_FOOD_EXPIRY_SELF),
                tooltip = GetString(BELTALOWDA_NOTIF_FOOD_EXPIRY_SELF_TOOLTIP),
                getFunc = function()
                    return BeltalowdaVars and BeltalowdaVars.notifications
                        and BeltalowdaVars.notifications.foodExpirySelf or false
                end,
                setFunc = function(value)
                    BeltalowdaVars.notifications = BeltalowdaVars.notifications or {}
                    BeltalowdaVars.notifications.foodExpirySelf = value
                end,
                width = "full",
                default = true,
            },
        },
    })

    -- ── Ultimate Tracking ──────────────────────────────────────────────
    table.insert(optionsData, {type = "header", name = "Ultimate Tracking"})
    table.insert(optionsData, {type = "description", text = "Monitor ultimate ability charge and usage across your group. Includes a role-based tracker that organizes ultimates by category and a classic list-style tracker.", width = "full"})
    
    -- Cross-tracker classification setting (applies to both role-based and classic trackers)
    local GUDBR = Beltalowda.UI and Beltalowda.UI.GroupUltimateDisplayByRoles
    if GUDBR and GUDBR.settings then
        table.insert(optionsData, {
            type = "checkbox",
            name = "Treat Gibbering Shield / Sanctum as Damage",
            tooltip = "When enabled, Gibbering Shield and Sanctum of the Abyssal Sea are classified as Damage ultimates instead of Shields. Gibbering Shelter (the morph that provides group shields) is always classified as Shields.",
            getFunc = function() return GUDBR.settings.gibberingAsDamage end,
            setFunc = function(value)
                GUDBR.settings.gibberingAsDamage = value
                GUDBR.ApplyGibberingClassification()
                GUDBR.SaveSettings()
                if GUDBR.RefreshDisplay then GUDBR.RefreshDisplay() end
                local GUD = Beltalowda.UI and Beltalowda.UI.GroupUltimateDisplay
                if GUD and GUD.RefreshDisplay then GUD.RefreshDisplay() end
            end,
            width = "full",
            default = false,
        })
    end
    
    appendModuleControls(Beltalowda.UI and Beltalowda.UI.GroupUltimateDisplayByRoles)  -- Ultimate Tracker (includes Smart Ult + Client Selector)
    appendModuleControls(Beltalowda.UI and Beltalowda.UI.GroupUltimateDisplay)          -- Classic Ultimate Tracker
    
    -- ── Synergy Tracking ───────────────────────────────────────────────
    table.insert(optionsData, {type = "header", name = "Synergy Tracking"})
    table.insert(optionsData, {type = "description", text = "Track synergy cooldowns across your group to coordinate activations. Includes a role-based tracker that auto-detects synergies and a classic tracker for manual synergy selection.", width = "full"})
    appendModuleControls(Beltalowda.UI and Beltalowda.UI.GroupSynergyDisplayByRoles)   -- Role-Based Synergy Tracker
    appendModuleControls(Beltalowda.UI and Beltalowda.UI.GroupSynergyDisplay)           -- Classic Synergy Tracker

    -- ── Damage Tracking ────────────────────────────────────────────────
    table.insert(optionsData, {type = "header", name = "Damage Tracking"})
    table.insert(optionsData, {type = "description", text = "Track timed damage abilities like Deep Fissure, Proximity Detonation, and Blighted Blastbones across your group. Includes both role-based and classic tracker layouts.", width = "full"})
    appendModuleControls(Beltalowda.UI and Beltalowda.UI.GroupDamageTimersByRole)        -- Role-Based Damage Tracker
    appendModuleControls(Beltalowda.UI and Beltalowda.UI.GroupDamageTimers)              -- Classic Damage Timers

    -- ── Expedition Tracking ────────────────────────────────────────────
    table.insert(optionsData, {type = "header", name = "Expedition Tracking"})
    table.insert(optionsData, {type = "description", text = "Monitor Major and Minor Expedition buff uptime across your group with distance-based player coloring.", width = "full"})
    appendModuleControls(Beltalowda.UI and Beltalowda.UI.RapidOverview)                 -- Rapid Overview
    
    -- ── Leader Tracking ────────────────────────────────────────────────
    table.insert(optionsData, {type = "header", name = "Leader Tracking"})
    table.insert(optionsData, {type = "description", text = "Display a visual beam on the group leader for easy tracking during movement and combat.", width = "full"})
    appendModuleControls(Beltalowda.UI and Beltalowda.UI.LeaderBeam)                    -- Leader Beam
    appendModuleControls(Beltalowda.UI and Beltalowda.UI.LeaderArrow)                   -- Leader Arrow
    
    -- ── Proc Set Tracking ──────────────────────────────────────────────
    table.insert(optionsData, {type = "header", name = "Proc Set Tracking"})
    table.insert(optionsData, {type = "description", text = "Track beneficial group effects provided by proc sets like Powerful Assault and Rallying Cry, with visibility options for the wearer or group.", width = "full"})
    appendModuleControls(Beltalowda.UI and Beltalowda.UI.PowerfulAssaultDisplay)         -- Powerful Assault
    appendModuleControls(Beltalowda.UI and Beltalowda.UI.RallyingCryDisplay)              -- Rallying Cry
    
    -- ── Miscellaneous Utilities ─────────────────────────────────────────
    table.insert(optionsData, {type = "header", name = "Miscellaneous Utilities"})
    table.insert(optionsData, {type = "description", text = "Automation utilities for weapon charging, gear repair, siege equipment restocking, and cross-addon network compatibility.", width = "full"})
    appendModuleControls(Beltalowda.network and Beltalowda.network.rdkCompat)             -- RdK Network Compatibility toggle
    appendModuleControls(Beltalowda.Toolbox and Beltalowda.Toolbox.CyrodiilPins)          -- Map pins
    appendModuleControls(Beltalowda.Toolbox and Beltalowda.Toolbox.SiegeMerchant)          -- Restock
    appendModuleControls(Beltalowda.Toolbox and Beltalowda.Toolbox.Recharger)              -- Recharge
    appendModuleControls(Beltalowda.Toolbox and Beltalowda.Toolbox.Repair)                 -- Repair
    appendModuleControls(Beltalowda.UI and Beltalowda.UI.GroupFightTotalsMeter)           -- Leaderboard
    
    -- ── Logging ────────────────────────────────────────────────────────
    table.insert(optionsData, {type = "header", name = "Logging"})
    table.insert(optionsData, {type = "description", text = "Configure debug logging to troubleshoot issues and monitor addon behavior.", width = "full"})
    
    -- Debugging & Diagnostics (cross-cutting concern - stays in settings file)
    local debuggingOptions = {
        -- Debugging & Diagnostics
        {
            type = "submenu",
            name = "|c4592FFDebugging & Diagnostics|r",
            tooltip = "Configure debug logging to troubleshoot issues",
            controls = {
        {
            type = "description",
            text = "Configure debug logging to troubleshoot issues. See docs/DEBUGGING_GUIDE.md for detailed information.",
            width = "full",
        },
        
        -- Master enable/disable toggle
        {
            type = "checkbox",
            name = "Enable Debug Logging",
            tooltip = "Master switch for debug logging. When disabled, only critical errors are logged.",
            getFunc = function() 
                return BeltalowdaVars.logging.enabled 
            end,
            setFunc = function(value)
                BeltalowdaVars.logging.enabled = value
                -- Update logger if available
                if value and Beltalowda.Logger then
                end
            end,
            width = "full",
            default = Settings.defaults.logging.enabled,
        },
        
        -- Default debug level
        {
            type = "dropdown",
            name = "Default Debug Level",
            tooltip = "Default log level for all modules. Lower levels show fewer messages.",
            choices = {"ERROR", "WARN", "INFO", "DEBUG", "VERBOSE"},
            getFunc = function()
                local level = BeltalowdaVars.logging.defaultLevel or 1
                local levelNames = {"ERROR", "WARN", "INFO", "DEBUG", "VERBOSE"}
                return levelNames[level]
            end,
            setFunc = function(value)
                local levelMap = {ERROR = 1, WARN = 2, INFO = 3, DEBUG = 4, VERBOSE = 5}
                BeltalowdaVars.logging.defaultLevel = levelMap[value]
                
                -- Apply to logger if available
                if Beltalowda.Logger then
                    for module, _ in pairs(Beltalowda.Logger.moduleConfig) do
                        BeltalowdaVars.logging.moduleLevels[module] = levelMap[value]
                        Beltalowda.Logger.SetModuleLevel(module, levelMap[value])
                    end
                end
            end,
            width = "full",
            default = "ERROR",
        },
        
        -- Module-specific levels submenu
        {
            type = "submenu",
            name = "Module-Specific Levels",
            tooltip = "Configure debug levels for individual modules",
            controls = {
                {
                    type = "description",
                    text = "Set log levels for each module independently. Module settings override the default level.",
                },
                
                -- Network module
                {
                    type = "dropdown",
                    name = "Network Module",
                    tooltip = "Debug level for network communication and data synchronization",
                    choices = {"ERROR", "WARN", "INFO", "DEBUG", "VERBOSE"},
                    getFunc = function()
                        local level = BeltalowdaVars.logging.moduleLevels.Network or 1
                        local levelNames = {"ERROR", "WARN", "INFO", "DEBUG", "VERBOSE"}
                        return levelNames[level]
                    end,
                    setFunc = function(value)
                        local levelMap = {ERROR = 1, WARN = 2, INFO = 3, DEBUG = 4, VERBOSE = 5}
                        BeltalowdaVars.logging.moduleLevels.Network = levelMap[value]
                        if Beltalowda.Logger then
                            Beltalowda.Logger.SetModuleLevel("Network", levelMap[value])
                        end
                    end,
                    width = "full",
                    default = "ERROR",
                },
                
                -- Ultimates module
                {
                    type = "dropdown",
                    name = "Ultimate Tracking",
                    tooltip = "Debug level for ultimate tracking and display",
                    choices = {"ERROR", "WARN", "INFO", "DEBUG", "VERBOSE"},
                    getFunc = function()
                        local level = BeltalowdaVars.logging.moduleLevels.Ultimates or 1
                        local levelNames = {"ERROR", "WARN", "INFO", "DEBUG", "VERBOSE"}
                        return levelNames[level]
                    end,
                    setFunc = function(value)
                        local levelMap = {ERROR = 1, WARN = 2, INFO = 3, DEBUG = 4, VERBOSE = 5}
                        BeltalowdaVars.logging.moduleLevels.Ultimates = levelMap[value]
                        if Beltalowda.Logger then
                            Beltalowda.Logger.SetModuleLevel("Ultimates", levelMap[value])
                        end
                    end,
                    width = "full",
                    default = "ERROR",
                },
                
                -- Equipment module
                {
                    type = "dropdown",
                    name = "Equipment Tracking",
                    tooltip = "Debug level for equipment and set detection",
                    choices = {"ERROR", "WARN", "INFO", "DEBUG", "VERBOSE"},
                    getFunc = function()
                        local level = BeltalowdaVars.logging.moduleLevels.Equipment or 1
                        local levelNames = {"ERROR", "WARN", "INFO", "DEBUG", "VERBOSE"}
                        return levelNames[level]
                    end,
                    setFunc = function(value)
                        local levelMap = {ERROR = 1, WARN = 2, INFO = 3, DEBUG = 4, VERBOSE = 5}
                        BeltalowdaVars.logging.moduleLevels.Equipment = levelMap[value]
                        if Beltalowda.Logger then
                            Beltalowda.Logger.SetModuleLevel("Equipment", levelMap[value])
                        end
                    end,
                    width = "full",
                    default = "ERROR",
                },
                
                -- General module
                {
                    type = "dropdown",
                    name = "General / Core",
                    tooltip = "Debug level for general addon functionality",
                    choices = {"ERROR", "WARN", "INFO", "DEBUG", "VERBOSE"},
                    getFunc = function()
                        local level = BeltalowdaVars.logging.moduleLevels.General or 1
                        local levelNames = {"ERROR", "WARN", "INFO", "DEBUG", "VERBOSE"}
                        return levelNames[level]
                    end,
                    setFunc = function(value)
                        local levelMap = {ERROR = 1, WARN = 2, INFO = 3, DEBUG = 4, VERBOSE = 5}
                        BeltalowdaVars.logging.moduleLevels.General = levelMap[value]
                        if Beltalowda.Logger then
                            Beltalowda.Logger.SetModuleLevel("General", levelMap[value])
                        end
                    end,
                    width = "full",
                    default = "ERROR",
                },

                -- Synergy module
                {
                    type = "dropdown",
                    name = "Synergy Tracking",
                    tooltip = "Debug level for synergy detection and cooldown tracking.\nDEBUG = log confirmed synergy activations.\nVERBOSE = log ALL effects gained on self (for auditing ability IDs).",
                    choices = {"ERROR", "WARN", "INFO", "DEBUG", "VERBOSE"},
                    getFunc = function()
                        local level = BeltalowdaVars.logging.moduleLevels.Synergy or 1
                        local levelNames = {"ERROR", "WARN", "INFO", "DEBUG", "VERBOSE"}
                        return levelNames[level]
                    end,
                    setFunc = function(value)
                        local levelMap = {ERROR = 1, WARN = 2, INFO = 3, DEBUG = 4, VERBOSE = 5}
                        BeltalowdaVars.logging.moduleLevels.Synergy = levelMap[value]
                        if Beltalowda.Logger then
                            Beltalowda.Logger.SetModuleLevel("Synergy", levelMap[value])
                        end
                    end,
                    width = "full",
                    default = "ERROR",
                },
            },
        },
            }, -- end Debugging & Diagnostics controls
        }, -- end Debugging & Diagnostics submenu
        
        -- Advanced Logging Settings
        {
            type = "submenu",
            name = "|c4592FFAdvanced Logging Settings|r",
            tooltip = "Fine-tune logging behavior and view debug commands",
            controls = {
        
        -- Max log entries slider
        {
            type = "slider",
            name = "Max Log Entries",
            tooltip = "Maximum number of log entries to keep in memory before rotation. Higher values use more memory.",
            min = 50,
            max = 500,
            step = 50,
            getFunc = function()
                return BeltalowdaVars.logging.maxLogEntries or 200
            end,
            setFunc = function(value)
                BeltalowdaVars.logging.maxLogEntries = value
                if Beltalowda.Logger then
                    Beltalowda.Logger.maxLogEntries = value
                end
            end,
            width = "full",
            default = 200,
        },
        
        -- VERBOSE reset checkbox
        {
            type = "checkbox",
            name = "Reset VERBOSE on Reload",
            tooltip = "When enabled, VERBOSE debug level automatically resets to configured level after /reloadui. Prevents chat spam after debugging sessions.",
            getFunc = function()
                return BeltalowdaVars.logging.verboseReset
            end,
            setFunc = function(value)
                BeltalowdaVars.logging.verboseReset = value
                if Beltalowda.Logger then
                    Beltalowda.Logger.verboseModeResetOnReload = value
                end
            end,
            width = "full",
            default = Settings.defaults.logging.verboseReset,
        },
        
        -- Help text
        {
            type = "description",
            text = "For more information on debugging, see docs/DEBUGGING_GUIDE.md or use /btlwdata help",
            width = "full",
        },
        
        -- Button to open documentation
        {
            type = "button",
            name = "Show Debug Commands",
            tooltip = "Display available debug slash commands in chat",
            func = function()
                d("=== Beltalowda Debug Commands ===")
                d("/btlwdata help - Show all available commands")
                d("/btlwdata debug <module> <level> - Set debug level")
                d("/btlwdata log show [module] - View recent logs")
                d("/btlwdata log levels - Show current levels")
                d("")
                d("See docs/DEBUGGING_GUIDE.md for detailed information")
            end,
            width = "full",
        },
            }, -- end Advanced Logging Settings controls
        }, -- end Advanced Logging Settings submenu
    }
    
    -- Merge debugging/logging options into main table
    for _, control in ipairs(debuggingOptions) do
        table.insert(optionsData, control)
    end
    
    LAM:RegisterOptionControls("BeltalowdaSettings", optionsData)
    
    -- Create separate "Beltalowda Composition" panel (like LUI Extended)
    Settings.CreateCompositionPanel()
    
end

--[[
    Create a synergy preference control for composition warnings
    @param synergyId: The synergy ID (from SynergyTracker)
    @param synergyName: The display name of the synergy
    @return: LAM control definition
]]
-- Map stored preference value → display label for synergy preferences
Settings.SYNERGY_PREF_TO_LABEL = {
    ["optional"]  = "Optional",
    ["required"]  = "Required",
    ["required2"] = "Required (x2)",
}
-- Map display label → stored value
Settings.SYNERGY_LABEL_TO_PREF = {}
for k, v in pairs(Settings.SYNERGY_PREF_TO_LABEL) do
    Settings.SYNERGY_LABEL_TO_PREF[v] = k
end
Settings.SYNERGY_CHOICES = {"Optional", "Required", "Required (x2)"}

function Settings.CreateSynergyPreference(synergyId, synergyName)
    return {
        type = "dropdown",
        name = synergyName,
        tooltip = string.format("Set preference for %s synergy in group composition. Use Required to require at least 1 provider, or Required (x2) for at least 2.", synergyName),
        choices = Settings.SYNERGY_CHOICES,
        getFunc = function()
            local pref = BeltalowdaVars.composition.synergyPreferences[synergyId] or "optional"
            return Settings.SYNERGY_PREF_TO_LABEL[pref] or "Optional"
        end,
        setFunc = function(value)
            BeltalowdaVars.composition.synergyPreferences[synergyId] = Settings.SYNERGY_LABEL_TO_PREF[value] or "optional"
            -- Trigger composition analysis update
            if Beltalowda.Composition and Beltalowda.Composition.AnalyzeComposition then
                Beltalowda.Composition.AnalyzeComposition()
            end
        end,
        width = "full",
        default = "Optional",
    }
end

--[[
    Create a set preference control for composition warnings
    @param setId: The set ID
    @param setName: The display name of the set
    @return: LAM control definition
]]--
-- Map stored preference value → display label for set preferences
Settings.SET_PREF_TO_LABEL = {
    ["optional"]        = "Optional",
    ["required"]        = "Required",
    ["prohibited"]      = "Prohibited",
    ["unique"]          = "Required (warn on duplicate)",
    ["required_unique"] = "Required (warn on duplicate)",
}
Settings.SET_LABEL_TO_PREF = {}
for k, v in pairs(Settings.SET_PREF_TO_LABEL) do
    Settings.SET_LABEL_TO_PREF[v] = k
end
-- Override: "Required (warn on duplicate)" maps to "required_unique"
Settings.SET_LABEL_TO_PREF["Required (warn on duplicate)"] = "required_unique"
Settings.SET_CHOICES = {"Optional", "Required", "Prohibited", "Required (warn on duplicate)"}

--[[
    Create a buff preference control for composition warnings
    @param buffName: The buff name (e.g., "Major Courage")
    @return: LAM control definition
]]
Settings.BUFF_PREF_TO_LABEL = {
    ["optional"]  = "Optional",
    ["required"]  = "Required",
}
Settings.BUFF_LABEL_TO_PREF = {}
for k, v in pairs(Settings.BUFF_PREF_TO_LABEL) do
    Settings.BUFF_LABEL_TO_PREF[v] = k
end
Settings.BUFF_CHOICES = {"Optional", "Required"}

function Settings.CreateBuffPreference(buffName)
    local BuffDB = Beltalowda.Data and Beltalowda.Data.BuffDatabase
    local def = BuffDB and BuffDB.BUFF_DEFINITIONS[buffName]
    local description = def and def.description or ""
    local sourceDesc = BuffDB and BuffDB.GetSourceDescription(buffName) or ""
    local tooltip = string.format("%s\n%s\n\nSources:\n%s", buffName, description, sourceDesc)

    return {
        type = "dropdown",
        name = buffName,
        tooltip = tooltip,
        choices = Settings.BUFF_CHOICES,
        getFunc = function()
            local pref = BeltalowdaVars.composition.buffPreferences[buffName] or "optional"
            return Settings.BUFF_PREF_TO_LABEL[pref] or "Optional"
        end,
        setFunc = function(value)
            BeltalowdaVars.composition.buffPreferences[buffName] = Settings.BUFF_LABEL_TO_PREF[value] or "optional"
            if Beltalowda.Composition and Beltalowda.Composition.AnalyzeComposition then
                Beltalowda.Composition.AnalyzeComposition()
            end
            -- Refresh the settings panel so warnings update immediately
            local LAM = LibAddonMenu2
            if LAM and LAM.util and LAM.util.RequestRefreshIfNeeded and BeltalowdaCompositionPanel then
                LAM.util.RequestRefreshIfNeeded(BeltalowdaCompositionPanel)
            end
        end,
        width = "full",
        default = "Optional",
    }
end

function Settings.CreateSetPreference(setId, setName)
    return {
        type = "dropdown",
        name = setName,
        tooltip = string.format("Set preference for %s in group composition. 'Required (warn on duplicate)' requires at least one player wearing the set and warns if more than one does.", setName),
        choices = Settings.SET_CHOICES,
        getFunc = function()
            local pref = BeltalowdaVars.composition.preferences[setId] or "optional"
            return Settings.SET_PREF_TO_LABEL[pref] or "Optional"
        end,
        setFunc = function(value)
            BeltalowdaVars.composition.preferences[setId] = Settings.SET_LABEL_TO_PREF[value] or "optional"
            -- Trigger composition analysis update
            if Beltalowda.Composition and Beltalowda.Composition.AnalyzeComposition then
                Beltalowda.Composition.AnalyzeComposition()
            end
        end,
        width = "full",
        default = "Optional",
    }
end

--[[
    Create the Beltalowda Composition settings panel
    Shows group composition analysis and warnings
]]--
function Settings.CreateCompositionPanel()
    local LAM = LibAddonMenu2
    if not LAM then
        return
    end
    
    -- Create composition panel
    local compositionPanelData = {
        type = "panel",
        name = "Beltalowda Composition",
        displayName = "Beltalowda Composition",
        author = "Kickimanjaro",
        version = Beltalowda.version or "0.5.4",
        registerForRefresh = true,
        registerForDefaults = false,
    }
    
    BeltalowdaCompositionPanel = LAM:RegisterAddonPanel("BeltalowdaComposition", compositionPanelData)
    
    -- Track whether composition panel is currently open
    local isCompositionPanelOpen = false
    
    -- Register callback to refresh data when panel opens
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
        if panel == BeltalowdaCompositionPanel then
            isCompositionPanelOpen = true
            
            -- Request fresh broadcasts from all group members
            if Beltalowda.network and Beltalowda.network.RequestGroupCompositionUpdate then
                Beltalowda.network.RequestGroupCompositionUpdate()
            end
            
            -- Refresh composition analysis
            if Beltalowda.Composition and Beltalowda.Composition.AnalyzeComposition then
                Beltalowda.Composition.AnalyzeComposition()
            end
            
            -- Delay panel refresh to allow data to arrive (two waves)
            zo_callLater(function()
                if Beltalowda.Composition and Beltalowda.Composition.AnalyzeComposition then
                    Beltalowda.Composition.AnalyzeComposition()
                end
                if LAM.util and LAM.util.RequestRefreshIfNeeded then
                    LAM.util.RequestRefreshIfNeeded(BeltalowdaCompositionPanel)
                end
            end, 1500)
            zo_callLater(function()
                if Beltalowda.Composition and Beltalowda.Composition.AnalyzeComposition then
                    Beltalowda.Composition.AnalyzeComposition()
                end
                if LAM.util and LAM.util.RequestRefreshIfNeeded then
                    LAM.util.RequestRefreshIfNeeded(BeltalowdaCompositionPanel)
                end
            end, 4000)
        end
    end)
    
    -- Register callback to track when panel closes
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
        if panel == BeltalowdaCompositionPanel then
            isCompositionPanelOpen = false
        end
    end)
    
    -- Hook into OnDataChanged to refresh composition panel when equipment data changes
    -- Only proceed if network module is available
    if Beltalowda.network then
        -- Store original function to preserve existing functionality
        local originalOnDataChanged = Beltalowda.network.OnDataChanged
        Beltalowda.network.OnDataChanged = function(dataType, unitTag)
            -- Call original function first to preserve any existing handlers
            if originalOnDataChanged and type(originalOnDataChanged) == "function" then
                originalOnDataChanged(dataType, unitTag)
            end
            
            -- If equipment data changed and composition panel is open, refresh it
            if dataType == "equipment" and isCompositionPanelOpen then
                -- Trigger composition analysis
                if Beltalowda.Composition and Beltalowda.Composition.AnalyzeComposition then
                    Beltalowda.Composition.AnalyzeComposition()
                end
                
                -- Refresh the panel UI
                if LAM.util and LAM.util.RequestRefreshIfNeeded then
                    LAM.util.RequestRefreshIfNeeded(BeltalowdaCompositionPanel)
                end
            end
        end
    end
    
    -- Composition panel options
    local compositionOptions = {
        -- ── Intro ──────────────────────────────────────────────────────────
        {
            type = "description",
            title = "Group Composition Analysis",
            text = "View your group's composition, roles, and equipment. Warnings appear when composition issues are detected based on preferences defined below.",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show set IDs in info panel",
            tooltip = "Display the internal set ID next to each set name in the composition info panel (useful for debugging)",
            getFunc = function()
                return BeltalowdaVars and BeltalowdaVars.composition and BeltalowdaVars.composition.showSetIds or false
            end,
            setFunc = function(value)
                if BeltalowdaVars and BeltalowdaVars.composition then
                    BeltalowdaVars.composition.showSetIds = value
                end
            end,
            width = "full",
            default = false,
        },

        -- ── Preferences ────────────────────────────────────────────────────
        {
            type = "header",
            name = "Preferences",
            width = "full",
        },
        {
            type = "description",
            text = "Configure which sets and synergies should be present in your group. Warnings are generated based on these preferences and the currently detected group composition.",
            width = "full",
        },

        -- Buffs sub-header
        {
            type = "header",
            name = "Buffs",
            width = "full",
        },
        {
            type = "description",
            text = "Configure which group-wide buffs should be present. Sources include specific gear sets and abilities that provide the buff to the entire group.",
            width = "full",
        },
        Settings.CreateBuffPreference("Major Courage"),
        Settings.CreateBuffPreference("Major Resolve"),
        Settings.CreateBuffPreference("Major Evasion"),
        Settings.CreateBuffPreference("Minor Toughness"),
        Settings.CreateBuffPreference("Immunity to Snares and Immobilizations"),
        {
            type = "checkbox",
            name = "Warn if no Mundus Stone",
            tooltip = "Generate a warning when group members are detected without an active Mundus Stone (Boon). Mundus stones are permanent effects from standing stones that provide passive stat bonuses.",
            getFunc = function()
                return BeltalowdaVars.composition.mundusWarning or false
            end,
            setFunc = function(value)
                BeltalowdaVars.composition.mundusWarning = value
                if Beltalowda.Composition and Beltalowda.Composition.AnalyzeComposition then
                    Beltalowda.Composition.AnalyzeComposition()
                end
            end,
            width = "full",
            default = false,
        },
        {
            type = "checkbox",
            name = "Track Champion Points",
            tooltip = "Show slotted champion point perks per discipline (Warfare, Fitness, Craft) in the group composition panel. Each discipline icon tooltip lists the 4 slotted perks.",
            getFunc = function()
                return BeltalowdaVars.composition.trackChampionPoints ~= false
            end,
            setFunc = function(value)
                BeltalowdaVars.composition.trackChampionPoints = value
            end,
            width = "full",
            default = true,
        },

        -- Sets sub-header
        {
            type = "header",
            name = "Sets",
            width = "full",
        },
        Settings.CreateSetPreference(232, "Roar of Alkosh"),
        Settings.CreateSetPreference(617, "Plaguebreak"),
        Settings.CreateSetPreference(236, "Vicious Death"),
        Settings.CreateSetPreference(629, "Rallying Cry"),
        Settings.CreateSetPreference(180, "Powerful Assault"),
        Settings.CreateSetPreference(768, "Lucent Echoes"),
        Settings.CreateSetPreference(518, "Arkasis' Genius"),
        Settings.CreateSetPreference(616, "Dark Convergence"),
        Settings.CreateSetPreference(558, "Void Bash"),
        Settings.CreateSetPreference(604, "Rush of Agony"),

        -- Synergies sub-header
        {
            type = "header",
            name = "Synergies",
            width = "full",
        },
        {
            type = "submenu",
            name = "Damage Synergies",
            tooltip = "Configure preferences for damage-oriented synergies",
            controls = {
                Settings.CreateSynergyPreference(22, "Runebreak"),
                Settings.CreateSynergyPreference(11, "Radiate"),
                Settings.CreateSynergyPreference(15, "Grave Robber"),
                Settings.CreateSynergyPreference(9, "Pure Agony"),
                Settings.CreateSynergyPreference(8, "Conduit"),
                Settings.CreateSynergyPreference(10, "Charged Lightning"),
                Settings.CreateSynergyPreference(3, "Nova"),
            }
        },
        {
            type = "submenu",
            name = "Support Synergies",
            tooltip = "Configure preferences for support-oriented synergies",
            controls = {
                Settings.CreateSynergyPreference(1, "Combustion / Shards"),
                Settings.CreateSynergyPreference(4, "Blood Altar"),
                Settings.CreateSynergyPreference(7, "Bone Shield"),
                Settings.CreateSynergyPreference(13, "Purify"),
                Settings.CreateSynergyPreference(14, "Harvest"),
                Settings.CreateSynergyPreference(16, "Icy Escape"),
                Settings.CreateSynergyPreference(17, "Hidden Refresh"),
                Settings.CreateSynergyPreference(23, "Passage"),
                Settings.CreateSynergyPreference(24, "Convergence Release"),
            }
        },

        -- ── Live Group Composition (debug) ─────────────────────────────
        {
            type = "submenu",
            name = "Current Group Composition",
            tooltip = "Click to view the full group composition breakdown (live data).",
            controls = {
                {
                    type = "description",
                    text = function()
                        if Beltalowda.Composition then
                            return Beltalowda.Composition.GetSummary()
                        end
                        return "Not in a group"
                    end,
                    width = "full",
                },
            },
        },
        {
            type = "header",
            name = "Composition Warnings",
            width = "full",
        },
        {
            type = "description",
            text = function()
                if Beltalowda.Composition then
                    local warnings = Beltalowda.Composition.GetWarnings()
                    if #warnings == 0 then
                        return "|c00FF00No warnings - composition looks good!|r"
                    else
                        local lines = {}
                        for _, warning in ipairs(warnings) do
                            local color = ""
                            if warning.severity == "high" then
                                color = "|cFF0000"
                            elseif warning.severity == "medium" then
                                color = "|cFFAA00"
                            else
                                color = "|cFFFF00"
                            end
                            table.insert(lines, color .. warning.message .. "|r")
                            -- Show children (e.g., specific buff names or player names)
                            if warning.children then
                                for _, child in ipairs(warning.children) do
                                    table.insert(lines, color .. "  - " .. child .. "|r")
                                end
                            end
                        end
                        return table.concat(lines, "\n")
                    end
                end
                return "No warnings"
            end,
            width = "full",
        },

    }

    LAM:RegisterOptionControls("BeltalowdaComposition", compositionOptions)
end

return Settings
