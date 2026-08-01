KayzarUI = KayzarUI or {}
local KayzarUI = KayzarUI

KayzarUI.Settings = {}

function KayzarUI.Settings:Initialize()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local sv = KayzarUI.sv
    local uf = sv.unitFrames or {}
    sv.unitFrames = uf
    local el = sv.elements or {}
    sv.elements = el

    local function GS(id) return GetString(id) end
    local function LR() KayzarUI.LiveRefreshAll() end
    local function LC() KayzarUI.LiveRecolor() end

    local panel = {
        type        = "panel",
        name        = GS(KAYZARUI_PANEL_NAME),
        displayName = "|cF24D8CKayzar|cFFFFFFUI|r",
        author      = "|cF24D8C@haze068|r",
        version     = "1.1.0",
        slashCommand = "/kayzar",
        registerForRefresh  = true,
        registerForDefaults = true,
    }

    local opts = {}

    opts[#opts + 1] = {
        type  = "description",
        text  = "|c00FF00All changes apply instantly! Use Show Elements Position Mode to reposition frames.|r",
        width = "full",
    }

    -- DONATE & LINKS
    opts[#opts + 1] = {type = "header", name = "|cFFD700Support & Links|r"}
    opts[#opts + 1] = {
        type  = "description",
        text  = '|cFFD700Donation for "|cF24D8CKayzarUI|r|cFFD700" or "|cF24D8CFancyTitles|r|cFFD700".|r\nIngame: |cF24D8C@haze068|r',
        width = "full",
    }
    opts[#opts + 1] = {
        type    = "button",
        name    = "|cFFD700Donate to @haze068|r",
        tooltip = "Opens the ingame mail window to send a donation to @haze068.",
        func    = function()
            SCENE_MANAGER:Show("mailSend")
            zo_callLater(function()
                if MAIL_SEND then
                    MAIL_SEND.to:SetText("@haze068")
                    MAIL_SEND.subject:SetText("KayzarUI & FancyTitles Addon Donation")
                end
                local toField = ZO_MailSendToField
                if toField then toField:SetText("@haze068") end
                local subField = ZO_MailSendSubjectField
                if subField then subField:SetText("KayzarUI & FancyTitles Addon Donation") end
            end, 500)
        end,
        width = "full",
    }
    opts[#opts + 1] = {
        type    = "button",
        name    = "|cF24D8CFancyTitles|r |cAAAAAAon ESOUI|r",
        tooltip = "Open FancyTitles addon page on ESOUI.",
        func    = function()
            RequestOpenUnsafeURL("https://www.esoui.com/downloads/info4355-FancyTitles.html#info")
        end,
        width = "full",
    }

    -- STYLE PRESET
    opts[#opts + 1] = {type = "header", name = "|cF24D8CStyle Preset|r"}
    opts[#opts + 1] = {
        type    = "dropdown",
        name    = GS(KAYZARUI_OPT_STYLE_PRESET),
        tooltip = "Choose a color theme.",
        choices = KayzarUI.STYLE_NAMES,
        getFunc = function() return sv.stylePreset end,
        setFunc = function(v) KayzarUI.ApplyStyle(v) end,
        default = "Glint Pink",
        width   = "full",
    }

    -- GENERAL
    opts[#opts + 1] = {type = "header", name = "|cF24D8CGeneral|r"}
    opts[#opts + 1] = {
        type    = "checkbox",
        name    = GS(KAYZARUI_OPT_LOCK_FRAMES),
        getFunc = function() return sv.lockFrames end,
        setFunc = function(v) sv.lockFrames = v; KayzarUI.UpdateFrameLock() end,
    }
    opts[#opts + 1] = {
        type    = "checkbox",
        name    = GS(KAYZARUI_OPT_WELCOME),
        getFunc = function() return sv.showWelcome end,
        setFunc = function(v) sv.showWelcome = v end,
    }
    opts[#opts + 1] = {
        type    = "checkbox",
        name    = "Show All Elements (Position Mode)",
        tooltip = "Shows all UI elements and unlocks them for repositioning.",
        getFunc = function() return sv.showAllElements end,
        setFunc = function(v) KayzarUI.ToggleShowAllElements(v) end,
    }

    -- UI COLOR SCHEME
    opts[#opts + 1] = {type = "header", name = "|cF24D8CUI Color Scheme|r"}
    opts[#opts + 1] = {
        type    = "checkbox",
        name    = "Enable UI Color Scheme",
        getFunc = function() return sv.uiSchemeEnabled end,
        setFunc = function(v) sv.uiSchemeEnabled = v; KayzarUI.ApplyUIScheme() end,
    }
    opts[#opts + 1] = {
        type     = "colorpicker",
        name     = "UI Scheme Color",
        getFunc  = function() return sv.uiSchemeColor.r, sv.uiSchemeColor.g, sv.uiSchemeColor.b, sv.uiSchemeColor.a end,
        setFunc  = function(r, g, b, a) sv.uiSchemeColor = {r = r, g = g, b = b, a = a}; KayzarUI.ApplyUIScheme() end,
        disabled = function() return not sv.uiSchemeEnabled end,
    }

    -- COLORS
    opts[#opts + 1] = {type = "header", name = "|cF24D8CColors|r"}
    local colorDefs = {
        {"Accent",           "accentColor"},
        {"Name Color",       "nameColor"},
        {"Level Color",      "levelColor"},
        {"Bar Text Color",   "textColor"},
        {"Health",           "healthColor"},
        {"Magicka",          "magickaColor"},
        {"Stamina",          "staminaColor"},
        {"Ultimate",         "ultimateColor"},
        {"Frame Background", "frameBgColor"},
        {"Frame Border",     "frameBorderColor"},
    }
    for _, cd in ipairs(colorDefs) do
        opts[#opts + 1] = {
            type    = "colorpicker",
            name    = cd[1],
            getFunc = function() local c = sv[cd[2]]; return c.r, c.g, c.b, c.a end,
            setFunc = function(r, g, b, a)
                sv[cd[2]] = {r = r, g = g, b = b, a = a or 1}
                sv.stylePreset = "Custom"
                LC()
            end,
        }
    end

    -- TARGET FRAME
    opts[#opts + 1] = {
        type     = "submenu",
        name     = "|cF24D8CTarget Frame|r",
        controls = {
            {
                type    = "dropdown",
                name    = "Target Name Display (Line 1)",
                tooltip = "Line 1 shows the name. Line 2 always shows the title (if available).\nCharacter Name = character name\nUserID = @UserID\nCharacter + UserID = both",
                choices = KayzarUI.TARGET_NAME_MODES,
                getFunc = function() return sv.targetNameMode end,
                setFunc = function(v) sv.targetNameMode = v end,
                default = "Character Name",
                width   = "full",
            },
        },
    }

    -- ELEMENT VISIBILITY
    opts[#opts + 1] = {
        type     = "submenu",
        name     = "|cF24D8CElement Visibility|r",
        controls = {
            {type = "checkbox", name = "Player Name",        getFunc = function() return el.playerName end,   setFunc = function(v) el.playerName = v; LR() end},
            {type = "checkbox", name = "Player Level / CP",  getFunc = function() return el.playerLevel end,  setFunc = function(v) el.playerLevel = v; LR() end},
            {type = "checkbox", name = "Player Ultimate %",  getFunc = function() return el.playerUlt end,    setFunc = function(v) el.playerUlt = v; LR() end},
            {type = "checkbox", name = "Health Bar",         getFunc = function() return el.healthBar end,    setFunc = function(v) el.healthBar = v; LR() end},
            {type = "checkbox", name = "Magicka Bar",        getFunc = function() return el.magickaBar end,   setFunc = function(v) el.magickaBar = v; LR() end},
            {type = "checkbox", name = "Stamina Bar",        getFunc = function() return el.staminaBar end,   setFunc = function(v) el.staminaBar = v; LR() end},
            {type = "checkbox", name = "Target Name",        getFunc = function() return el.targetName end,   setFunc = function(v) el.targetName = v; LR() end},
            {type = "checkbox", name = "Target Level",       getFunc = function() return el.targetLevel end,  setFunc = function(v) el.targetLevel = v; LR() end},
            {type = "checkbox", name = "Target Health Bar",  getFunc = function() return el.targetHealth end, setFunc = function(v) el.targetHealth = v; LR() end},
            {type = "checkbox", name = "Active Bar Indicator (1/2)", getFunc = function() return el.barIndicator end,
                setFunc = function(v) el.barIndicator = v; if KayzarUI.ActionBar then KayzarUI.ActionBar:RefreshBarIndicator() end end},
        },
    }

    -- UNIT FRAMES - APPEARANCE
    opts[#opts + 1] = {
        type     = "submenu",
        name     = "|cF24D8CUnit Frames - Appearance|r",
        controls = {
            {type = "dropdown", name = "Layout Mode",    choices = KayzarUI.LAYOUT_MODES,      getFunc = function() return uf.layoutMode end,  setFunc = function(v) uf.layoutMode = v; LR() end, default = "Stacked", width = "full"},
            {type = "dropdown", name = "Bar Texture",    choices = KayzarUI.BAR_TEXTURE_NAMES,  getFunc = function() return uf.barTexture end,  setFunc = function(v) uf.barTexture = v; LR() end, default = "Smooth",  width = "full"},
            {type = "dropdown", name = "Bar Shape",      choices = KayzarUI.BAR_SHAPES,         getFunc = function() return uf.barShape end,    setFunc = function(v) uf.barShape = v; LR() end,   default = "Rectangle", width = "full"},
            {type = "checkbox", name = "Show Background", getFunc = function() return uf.showBackground end, setFunc = function(v) uf.showBackground = v; LC() end},
            {type = "slider",   name = "Background Opacity", min = 0, max = 100, step = 5, getFunc = function() return uf.bgOpacity end, setFunc = function(v) uf.bgOpacity = v; LC() end, disabled = function() return not uf.showBackground end},
            {type = "checkbox", name = "Show Border",     getFunc = function() return uf.showBorder end,     setFunc = function(v) uf.showBorder = v; LC() end},
            {type = "dropdown", name = "Text Display",   choices = KayzarUI.TEXT_MODES,         getFunc = function() return uf.textMode end,    setFunc = function(v) uf.textMode = v end,         default = "Value + Percent", width = "full"},
            {type = "checkbox", name = "Animate Bars",    getFunc = function() return uf.animateBars end,    setFunc = function(v) uf.animateBars = v end},
        },
    }

    -- UNIT FRAMES - SIZE & POSITION
    opts[#opts + 1] = {
        type     = "submenu",
        name     = "|cF24D8CUnit Frames - Size & Position|r",
        controls = {
            {type = "slider", name = "Global Bar Width",          min = 120, max = 500, step = 10, getFunc = function() return uf.barWidth or 280 end,         setFunc = function(v) uf.barWidth = v; LR() end,          default = 280},
            {type = "slider", name = "Health Bar Height",         min = 8,   max = 50,  step = 2,  getFunc = function() return uf.healthBarHeight or 22 end,   setFunc = function(v) uf.healthBarHeight = v; LR() end,   default = 22},
            {type = "slider", name = "Magicka Bar Height",        min = 4,   max = 40,  step = 2,  getFunc = function() return uf.magickaBarHeight or 14 end,  setFunc = function(v) uf.magickaBarHeight = v; LR() end,  default = 14},
            {type = "slider", name = "Stamina Bar Height",        min = 4,   max = 40,  step = 2,  getFunc = function() return uf.staminaBarHeight or 14 end,  setFunc = function(v) uf.staminaBarHeight = v; LR() end,  default = 14},
            {type = "slider", name = "Health Bar Width (0=Global)",  min = 0, max = 500, step = 10, getFunc = function() return uf.healthBarWidth or 0 end,    setFunc = function(v) uf.healthBarWidth = v; LR() end,    default = 0},
            {type = "slider", name = "Magicka Bar Width (0=Global)", min = 0, max = 500, step = 10, getFunc = function() return uf.magickaBarWidth or 0 end,   setFunc = function(v) uf.magickaBarWidth = v; LR() end,   default = 0},
            {type = "slider", name = "Stamina Bar Width (0=Global)", min = 0, max = 500, step = 10, getFunc = function() return uf.staminaBarWidth or 0 end,   setFunc = function(v) uf.staminaBarWidth = v; LR() end,   default = 0},
            {type = "slider", name = "Bar Spacing",              min = 0,   max = 20,  step = 1,  getFunc = function() return uf.barSpacing or 4 end,         setFunc = function(v) uf.barSpacing = v; LR() end,         default = 4},
            {type = "checkbox", name = "Independent Bars (Free Move)", tooltip = "Each bar becomes its own movable frame. Positions persist through /reloadui.",
                getFunc = function() return uf.independentBars or false end, setFunc = function(v) uf.independentBars = v; LR() end, default = false},
        },
    }

    -- UNIT FRAMES - VISIBILITY
    opts[#opts + 1] = {
        type     = "submenu",
        name     = "|cF24D8CUnit Frames - Visibility|r",
        controls = {
            {type = "checkbox", name = "Player Frame", getFunc = function() return uf.playerEnabled end, setFunc = function(v) uf.playerEnabled = v; LR() end},
            {type = "checkbox", name = "Target Frame", getFunc = function() return uf.targetEnabled end, setFunc = function(v) uf.targetEnabled = v; LR() end},
            {type = "checkbox", name = "Fade out of Combat", getFunc = function() return uf.fadeOutOfCombat end, setFunc = function(v) uf.fadeOutOfCombat = v end},
            {type = "slider", name = "Out-of-Combat Opacity", min = 0, max = 100, step = 5,
                getFunc = function() return uf.fadeAlpha end, setFunc = function(v) uf.fadeAlpha = v end,
                disabled = function() return not uf.fadeOutOfCombat end},
        },
    }

    -- SHIELD OVERLAY
    local shieldSv = sv.shield or {}
    sv.shield = shieldSv
    opts[#opts + 1] = {
        type     = "submenu",
        name     = "|cF24D8CShield Overlay|r",
        controls = {
            {type = "checkbox", name = "Enable Shield Overlay",
                tooltip = "Shows a shield overlay on health bars when a damage shield is active.",
                getFunc = function() return shieldSv.enabled ~= false end,
                setFunc = function(v) shieldSv.enabled = v end},
            {type = "colorpicker", name = "Shield Color",
                getFunc = function() local c = shieldSv.color or {r = 0.3, g = 0.7, b = 1, a = 0.55}; return c.r, c.g, c.b, c.a end,
                setFunc = function(r, g, b, a) shieldSv.color = {r = r, g = g, b = b, a = a or 0.55} end,
                disabled = function() return shieldSv.enabled == false end},
            {type = "colorpicker", name = "Overshield Color",
                tooltip = "Color when shield + health exceeds max health.",
                getFunc = function() local c = shieldSv.overshieldColor or {r = 0.9, g = 0.85, b = 0.2, a = 0.65}; return c.r, c.g, c.b, c.a end,
                setFunc = function(r, g, b, a) shieldSv.overshieldColor = {r = r, g = g, b = b, a = a or 0.65} end,
                disabled = function() return shieldSv.enabled == false end},
        },
    }

    -- BUFF TRACKER
    local buffSv = sv.buffTracker or {}
    sv.buffTracker = buffSv
    opts[#opts + 1] = {
        type     = "submenu",
        name     = "|cF24D8CBuff Tracker (Player & Monsters)|r",
        controls = {
            {type = "checkbox", name = "Enable Buff Tracker",
                tooltip = "Shows your active buffs on screen. Each icon can be moved individually when frames are unlocked.",
                getFunc = function() return buffSv.enabled ~= false end,
                setFunc = function(v) buffSv.enabled = v; LR() end},
            {type = "slider", name = "Icon Size", min = 20, max = 64, step = 2,
                getFunc = function() return buffSv.iconSize or 36 end,
                setFunc = function(v) buffSv.iconSize = v; LR() end,
                disabled = function() return buffSv.enabled == false end},
            {type = "slider", name = "Max Buffs Shown", min = 1, max = 24, step = 1,
                getFunc = function() return buffSv.maxBuffs or 12 end,
                setFunc = function(v) buffSv.maxBuffs = v; LR() end,
                disabled = function() return buffSv.enabled == false end},
            {type = "checkbox", name = "Show Timer",
                getFunc = function() return buffSv.showTimer ~= false end,
                setFunc = function(v) buffSv.showTimer = v; LR() end,
                disabled = function() return buffSv.enabled == false end},
        },
    }

    -- TARGET DEBUFFS
    local debuffSv = sv.targetDebuffs or {}
    sv.targetDebuffs = debuffSv
    opts[#opts + 1] = {
        type     = "submenu",
        name     = "|cF24D8CTarget Debuffs|r",
        controls = {
            {type = "checkbox", name = "Enable Target Debuffs",
                tooltip = "Shows debuffs on your current target below the target frame.",
                getFunc = function() return debuffSv.enabled ~= false end,
                setFunc = function(v) debuffSv.enabled = v; LR() end},
            {type = "slider", name = "Icon Size", min = 16, max = 50, step = 2,
                getFunc = function() return debuffSv.iconSize or 30 end,
                setFunc = function(v) debuffSv.iconSize = v; LR() end,
                disabled = function() return debuffSv.enabled == false end},
            {type = "slider", name = "Max Debuffs Shown", min = 1, max = 16, step = 1,
                getFunc = function() return debuffSv.maxDebuffs or 8 end,
                setFunc = function(v) debuffSv.maxDebuffs = v; LR() end,
                disabled = function() return debuffSv.enabled == false end},
        },
    }

    -- ACTION BAR
    opts[#opts + 1] = {
        type     = "submenu",
        name     = "|cF24D8CAction Bar|r",
        controls = {
            {type = "checkbox", name = GS(KAYZARUI_OPT_ENABLED),      getFunc = function() return sv.actionBar.enabled end,          setFunc = function(v) sv.actionBar.enabled = v end},
            {type = "checkbox", name = GS(KAYZARUI_OPT_SHOW_COOLDOWN), getFunc = function() return sv.actionBar.showCooldownText end, setFunc = function(v) sv.actionBar.showCooldownText = v end},
            {type = "checkbox", name = GS(KAYZARUI_OPT_SHOW_ULT_COST), getFunc = function() return sv.actionBar.showUltimateCost end, setFunc = function(v) sv.actionBar.showUltimateCost = v end},
            {type = "checkbox", name = "Active Bar Indicator",         getFunc = function() return sv.actionBar.showBarIndicator end,  setFunc = function(v) sv.actionBar.showBarIndicator = v end},
            {type = "slider", name = "Bar Indicator Width",  min = 24, max = 80, step = 2,
                getFunc = function() return sv.actionBar.barIndicatorWidth or 44 end,
                setFunc = function(v) sv.actionBar.barIndicatorWidth = v; LR() end,
                disabled = function() return not sv.actionBar.showBarIndicator end},
            {type = "slider", name = "Bar Indicator Height", min = 16, max = 50, step = 2,
                getFunc = function() return sv.actionBar.barIndicatorHeight or 26 end,
                setFunc = function(v) sv.actionBar.barIndicatorHeight = v; LR() end,
                disabled = function() return not sv.actionBar.showBarIndicator end},
        },
    }

    -- ACTIONS
    opts[#opts + 1] = {type = "header", name = "|cF24D8CActions|r"}
    opts[#opts + 1] = {
        type    = "button",
        name    = "|c00FF00Save Settings|r",
        tooltip = "Confirms all current settings and positions are saved.",
        func    = function()
            local uf2 = KayzarUI.sv.unitFrames
            KayzarUI.Print("|c00FF00Settings saved!|r All positions stored.")
            if uf2.playerPosX then KayzarUI.Print("Player: " .. zo_floor(uf2.playerPosX) .. ", " .. zo_floor(uf2.playerPosY)) end
            if uf2.targetPosX then KayzarUI.Print("Target: " .. zo_floor(uf2.targetPosX) .. ", " .. zo_floor(uf2.targetPosY)) end
            if uf2.independentBars then
                if uf2.healthPosX then KayzarUI.Print("Health: " .. zo_floor(uf2.healthPosX) .. ", " .. zo_floor(uf2.healthPosY)) end
                if uf2.magickaPosX then KayzarUI.Print("Magicka: " .. zo_floor(uf2.magickaPosX) .. ", " .. zo_floor(uf2.magickaPosY)) end
                if uf2.staminaPosX then KayzarUI.Print("Stamina: " .. zo_floor(uf2.staminaPosX) .. ", " .. zo_floor(uf2.staminaPosY)) end
            end
        end,
        width = "full",
    }
    opts[#opts + 1] = {
        type  = "button",
        name  = "|cFFFF00Reload UI|r",
        func  = function() ReloadUI() end,
        width = "full",
    }
    opts[#opts + 1] = {
        type    = "button",
        name    = "|c00CCFFLoad Defaults (keep positions)|r",
        tooltip = "Resets colors/sizes to defaults, keeps frame positions.",
        func    = function()
            local def = KayzarUI.DeepCopy(KayzarUI.DEFAULT_SETTINGS)
            -- Preserve positions
            def.unitFrames.playerPosX  = uf.playerPosX
            def.unitFrames.playerPosY  = uf.playerPosY
            def.unitFrames.targetPosX  = uf.targetPosX
            def.unitFrames.targetPosY  = uf.targetPosY
            def.unitFrames.healthPosX  = uf.healthPosX
            def.unitFrames.healthPosY  = uf.healthPosY
            def.unitFrames.magickaPosX = uf.magickaPosX
            def.unitFrames.magickaPosY = uf.magickaPosY
            def.unitFrames.staminaPosX = uf.staminaPosX
            def.unitFrames.staminaPosY = uf.staminaPosY
            def.unitFrames.debuffContPosX = uf.debuffContPosX
            def.unitFrames.debuffContPosY = uf.debuffContPosY
            if sv.buffTracker then
                def.buffTracker = def.buffTracker or {}
                for k, v in pairs(sv.buffTracker) do
                    if type(k) == "string" and (k:find("X$") or k:find("Y$")) then
                        def.buffTracker[k] = v
                    end
                end
            end
            for k, v in pairs(def) do
                KayzarUI.sv[k] = v
            end
            KayzarUI.Print("Defaults loaded (positions kept). Reloading...")
            zo_callLater(function() ReloadUI() end, 500)
        end,
        width = "full",
    }

    opts[#opts + 1] = {type = "header", name = "|cFF4444Danger Zone|r"}
    opts[#opts + 1] = {
        type        = "button",
        name        = "|cFF4444Reset All Settings|r",
        tooltip     = "Resets EVERYTHING to defaults and reloads.",
        func        = function()
            KayzarUI.sv = ZO_SavedVars:NewAccountWide("KayzarUI_SavedVars", 6, nil, {})
            ReloadUI()
        end,
        isDangerous = true,
        width       = "full",
    }

    KayzarUI.settingsPanel = LAM:RegisterAddonPanel("KayzarUI_Settings", panel)
    LAM:RegisterOptionControls("KayzarUI_Settings", opts)
end
