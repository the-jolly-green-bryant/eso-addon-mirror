function AST.LoadSettings()
    local LAM = LibAddonMenu2

    local panelData = {
        type = "panel",
        name = AST.name,
        displayName = AST.name,
        author = "|cfd6a02AiMPlAyEr[EU]|r",
        version = AST.version,
        slashCommand = "/astmenu",
        website = AST.website,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(AST.menuname, panelData)

    local optionsTable = {}

    table.insert(optionsTable, {
        type = "slider",
        name = "Update Interval",
        tooltip = "Defines the refresh rate in ms",
        min = 50,
        max = 1000,
        step = 50,
        getFunc = function()
            return AST.SV.interval
        end,
        setFunc = function(var)
            AST.SV.interval = var
        end,
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = "Show Only In Combat",
        tooltip = "Toggles the tracker outside of fights",
        getFunc = function() return AST.SV.windowstate end,
        setFunc = function(value)
            AST.SV.windowstate = value
            windowstate = value
            AST.windowState()
        end,
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = "Lock UI Elements",
        getFunc = function() return AST.SV.lockwindow end,
        setFunc = function(value)
            AST.SetWindowLock(value)
            AST.SV.lockwindow = value
        end,
    })

    table.insert(optionsTable, {
        type = "submenu",
        name = "Synergy Settings",
        controls = {
            [1] = {
                type = "description",
                text = [[The |cff0000Tracker UI|r shows you your synergies and their cooldown.
                ]],
            },
            [2] = {
                type = "checkbox",
                name = "Tracker Frame",
                tooltip = "Enables/Disables Tracker Frame",
                getFunc = function() return AST.SV.trackerui end,
                setFunc = function(value)
                    AST.SV.trackerui = value
                end,
                requiresReload = true,
            },
            [3] = {
                type = "dropdown",
                name = "Alignment of Synergies",
                tooltip = "Allows the alignment of synergies to be adjusted",
                choices = {"horizontal", "vertical", "compact"},
                getFunc = function() return AST.SV.orientation end,
                setFunc = function(var)
                    AST.SV.orientation = var
                    AST.Tracker.UpdateElements()
                end,
                disabled = function() return not AST.SV.trackerui end,
            },
            [4] = {
                type = "slider",
                name = "Tracker Transparency",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function()
                    if AST.SV.alpha ~= nil then
                        return math.floor(AST.SV.alpha*100)
                    end
                end,
                setFunc = function(var)
                    local newAlpha = var / 100
                    AST.SV.alpha =newAlpha
                    AST.Tracker.SetTrackerAlpha(newAlpha);
                end,
            },
            [5] = {
                type = "checkbox",
                name = "Texture Transparency",
                tooltip = "Textures will be a affected by the Tracker Transparency option as well",
                getFunc = function() return AST.SV.textures end,
                setFunc = function(value)
                    AST.SV.textures = value
                    AST.Tracker.SetTrackerAlpha(AST.SV.alpha)
                end,
            },
            [6] = {
                type = "slider",
                name = "Tracker Scale",
                min = 50,
                max = 200,
                step = 1,
                getFunc = function()
                    if AST.SV.windowscale ~= nil then
                        return math.floor(AST.SV.windowscale*100)
                    end
                end,
                setFunc = function(var)
                    local newWindowScale = var / 100
                    AST.SV.windowscale = newWindowScale
                    AST.Tracker.UpdateElements()
                end,
            },
            [7] = {
                type = "divider",
                height = 15,
                alpha = 1,
            },
            [8] = {
                type = "checkbox",
                name = "Conduit",
                tooltip = "Synergy of Liquid Lightning",
                getFunc = function() return AST.SV.liq end,
                setFunc = function(value)
                    AST.SV.liq = value
                    AST.Tracker.UpdateElements()
                end,
                disabled = function() return not AST.SV.trackerui end,
            },
            [9] = {
                type = "checkbox",
                name = "Purify",
                tooltip = "Synergy of Cleansing Ritual",
                getFunc = function() return AST.SV.pur end,
                setFunc = function(value)
                    AST.SV.pur = value
                    AST.Tracker.UpdateElements()
                end,
                disabled = function() return not AST.SV.trackerui end,
            },
            [10] = {
                type = "checkbox",
                name = "Combustion/Blessed Shard",
                tooltip = "Synergy of Energy Orb/Spear Shard",
                getFunc = function() return AST.SV.orb end,
                setFunc = function(value)
                    AST.SV.orb = value
                    AST.Tracker.UpdateElements()
                end,
                disabled = function() return not AST.SV.trackerui end,
            },
            [11] = {
                type = "checkbox",
                name = "Bone Wall",
                tooltip = "Synergy of Bone Shield",
                getFunc = function() return AST.SV.bon end,
                setFunc = function(value)
                    AST.SV.bon = value
                    AST.Tracker.UpdateElements()
                end,
                disabled = function() return not AST.SV.trackerui end,
            },
            [12] = {
                type = "checkbox",
                name = "Harvest",
                tooltip = "Synergy of Healing Seed",
                getFunc = function() return AST.SV.hea end,
                setFunc = function(value)
                    AST.SV.hea = value
                    AST.Tracker.UpdateElements()
                end,
                disabled = function() return not AST.SV.trackerui end,
            },
            [13] = {
                type = "checkbox",
                name = "Blood Funnel",
                tooltip = "Synergy of Blood Altar",
                getFunc = function() return AST.SV.blo end,
                setFunc = function(value)
                    AST.SV.blo = value
                    AST.Tracker.UpdateElements()
                end,
                disabled = function() return not AST.SV.trackerui end,
            },
            [14] = {
                type = "checkbox",
                name = "Spawn Broodlings",
                tooltip = "Synergy of Trapping Webs",
                getFunc = function() return AST.SV.tra end,
                setFunc = function(value)
                    AST.SV.tra = value
                    AST.Tracker.UpdateElements()
                end,
                disabled = function() return not AST.SV.trackerui end,
            },
            [15] = {
                type = "checkbox",
                name = "Charged Lightning",
                tooltip = "Synergy of Summon Storm Atronach",
                getFunc = function() return AST.SV.cha end,
                setFunc = function(value)
                    AST.SV.cha = value
                    AST.Tracker.UpdateElements()
                end,
                disabled = function() return not AST.SV.trackerui end,
            },
            [16] = {
                type = "checkbox",
                name = "Radiate",
                tooltip = "Synergy of Inner Fire",
                getFunc = function() return AST.SV.rad end,
                setFunc = function(value)
                    AST.SV.rad = value
                    AST.Tracker.UpdateElements()
                end,
                disabled = function() return not AST.SV.trackerui end,
            },
            [17] = {
                type = "checkbox",
                name = "Shackle",
                tooltip = "Synergy of Dragonknight Standard",
                getFunc = function() return AST.SV.sha end,
                setFunc = function(value)
                    AST.SV.sha = value
                    AST.Tracker.UpdateElements()
                end,
                disabled = function() return not AST.SV.trackerui end,
            },
            [18] = {
                type = "checkbox",
                name = "Impale",
                tooltip = "Synergy of Dark Talons",
                getFunc = function() return AST.SV.imp end,
                setFunc = function(value)
                    AST.SV.imp = value
                    AST.Tracker.UpdateElements()
                end,
                disabled = function() return not AST.SV.trackerui end,
            },
            [19] = {
                type = "checkbox",
                name = "Supernova",
                tooltip = "Synergy of Nova",
                getFunc = function() return AST.SV.gra end,
                setFunc = function(value)
                    AST.SV.gra = value
                    AST.Tracker.UpdateElements()
                end,
                disabled = function() return not AST.SV.trackerui end,
            },
            [20] = {
                type = "checkbox",
                name = "Hidden Refresh",
                tooltip = "Synergy of Consuming Darkness",
                getFunc = function() return AST.SV.hir end,
                setFunc = function(value)
                    AST.SV.hir = value
                    AST.Tracker.UpdateElements()
                end,
                disabled = function() return not AST.SV.trackerui end,
            },
            [21] = {
                type = "checkbox",
                name = "Soul Leech",
                tooltip = "Synergy of Soul Shred",
                getFunc = function() return AST.SV.sol end,
                setFunc = function(value)
                    AST.SV.sol = value
                    AST.Tracker.UpdateElements()
                end,
                disabled = function() return not AST.SV.trackerui end,
            },
            [22] = {
                type = "checkbox",
                name = "Grave Robber",
                tooltip = "Synergy of Boneyard",
                getFunc = function() return AST.SV.rob end,
                setFunc = function(value)
                    AST.SV.rob = value
                    AST.Tracker.UpdateElements()
                end,
                disabled = function() return not AST.SV.trackerui end,
            },
            [23] = {
                type = "checkbox",
                name = "Pure Agony",
                tooltip = "Synergy of Agony Totem",
                getFunc = function() return AST.SV.ago end,
                setFunc = function(value)
                    AST.SV.ago = value
                    AST.Tracker.UpdateElements()
                end,
                disabled = function() return not AST.SV.trackerui end,
            },
            --[[[24] = {
                type = "checkbox",
                name = "Icy Escape",
                tooltip = "Synergy of Frozen Retreat",
                getFunc = function() return AST.SV.icy end,
                setFunc = function(value)
                    AST.SV.icy = value
                    AST.Tracker.UpdateElements()
                end,
                disabled = function() return not AST.SV.trackerui end,
            },]]--
        },
    })

    table.insert(optionsTable, {
        type = "submenu",
        name = "Healer Settings",
        controls = {
            [1] = {
                type = "description",
                text = [[The |c32cd32Healer UI|r tracks Synergies being used by your tanks and dds.
These setting to not affect the ones above.
]],
            },
            [2] = {
                type = "checkbox",
                name = "Healer Frame",
                tooltip = "Enables/Disables Healer Frame",
                getFunc = function() return AST.SV.healerui end,
                setFunc = function(value)
                    AST.SV.healerui = value
                end,
                requiresReload = true,
            },
            [3] = {
                type = "slider",
                name = "Transparency",
                min = 0,
                max = 100,
                step = 1,
                getFunc = function()
                    if AST.SV.healer.alpha ~= nil then
                        return math.floor(AST.SV.healer.alpha*100)
                    end
                end,
                setFunc = function(var)
                    local newAlpha = var / 100
                    AST.SV.healer.alpha = newAlpha
                    AST.Healer.HealerUIUpdate()
                end,
            },
            [4] = {
                type = "checkbox",
                name = "Only Track Tanks",
                getFunc = function() return AST.SV.healer.tanksonly end,
                setFunc = function(value)
                    AST.SV.healer.tanksonly = value
                    AST.Healer.HealerUIUpdate()
                end,
                disabled = function() return not AST.SV.healerui end,
            },
            [5] = {
                type = "checkbox",
                name = "Only Track DDs",
                getFunc = function() return AST.SV.healer.ddsonly end,
                setFunc = function(value)
                    AST.SV.healer.ddsonly = value
                    AST.Healer.HealerUIUpdate()
                end,
                disabled = function() return not AST.SV.healerui end,
            },
            [6] = {
                type = "divider",
                height = 15,
                alpha = 1,
            },
            [7] = {
                type = "dropdown",
                name = "First Synergy",
                choices = D.SynergyList,
                choicesValues = D.SynergyListValues,
                getFunc = function() return AST.SV.healer.firstsynergy end,
                setFunc = function(var)
                    AST.SV.healer.firstsynergy = var
                    AST.Healer.HealerUIUpdate()
                end,
                disabled = function() return not AST.SV.healerui end,
            },
            [8] = {
                type = "dropdown",
                name = "Second Synergy",
                choices = D.SynergyList,
                choicesValues = D.SynergyListValues,
                getFunc = function() return AST.SV.healer.secondsynergy end,
                setFunc = function(var)
                    AST.SV.healer.secondsynergy = var
                    AST.Healer.HealerUIUpdate()
                end,
                disabled = function() return not AST.SV.healerui end,
            },
            [9] = {
                type = "dropdown",
                name = "Third Synergy",
                choices = D.SynergyList,
                choicesValues = D.SynergyListValues,
                getFunc = function() return AST.SV.healer.thirdsynergy end,
                setFunc = function(var)
                    AST.SV.healer.thirdsynergy = var
                    AST.Healer.HealerUIUpdate()
                end,
                disabled = function() return not AST.SV.healerui end,
            },
            [10] = {
                type = "dropdown",
                name = "Fourth Synergy",
                choices = D.SynergyList,
                choicesValues = D.SynergyListValues,
                getFunc = function() return AST.SV.healer.fourthsynergy end,
                setFunc = function(var)
                    AST.SV.healer.fourthsynergy = var
                    AST.Healer.HealerUIUpdate()
                end,
                disabled = function() return not AST.SV.healerui end,
            },
        },
    })

    LAM:RegisterOptionControls(AST.menuname, optionsTable)
end
