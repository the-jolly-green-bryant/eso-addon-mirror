local BEV = BetterEffectViewer
local LAM = LibAddonMenu2

SLASH_COMMANDS["/bev"] = function(cmd)
    local args = {}
    for word in cmd:gmatch("%S+") do
        args[#args + 1] = word
    end

    if args[1] == "whitelist" then
        local id = tonumber(args[2])
        if id then
            BEV.sv.whitelist[id] = true
            d("Added to whitelist: " .. id)
        end
    elseif args[1] == "blacklist" then
        local id = tonumber(args[2])
        if id then
            BEV.sv.blacklist[id] = true
            d("Added to blacklist: " .. id)
        end
    end
end

function BEV:CreateSettingsMenu()
    if not LAM then
        return
    end

    local defaults = self.defaults

    local panelData = {
        type = "panel",
        name = "BetterEffectViewer",
        displayName = "BetterEffectViewer",
        author = "You",
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "description",
            text = "LUI-style buff/debuff tracker for your reticle target.",
        },
        {
            type = "checkbox",
            name = "Lock Window",
            tooltip = "Lock the window so it cannot be dragged.",
            getFunc = function()
                return self.sv.lockWindow
            end,
            setFunc = function(value)
                self.sv.lockWindow = value
                self.win:SetMovable(not value)
                self.win:SetMouseEnabled(not value)
            end,
            default = defaults.lockWindow,
        },
        {
            type = "checkbox",
            name = "Auto Detect Important Buffs",
            tooltip = "Automatically add longer buffs to the whitelist.",
            getFunc = function()
                return self.sv.autoWhitelist
            end,
            setFunc = function(v)
                self.sv.autoWhitelist = v
            end,
            default = true,
        },
        {
            type = "slider",
            name = "Position X",
            tooltip = "Horizontal offset from the screen center.",
            min = -2000,
            max = 2000,
            step = 1,
            getFunc = function()
                return self.sv.offsetX
            end,
            setFunc = function(value)
                self.sv.offsetX = value
                self.win:ClearAnchors()
                self.win:SetAnchor(CENTER, GuiRoot, CENTER, self.sv.offsetX, self.sv.offsetY)
            end,
            default = defaults.offsetX,
        },
        {
            type = "slider",
            name = "Position Y",
            tooltip = "Vertical offset from the screen center.",
            min = -2000,
            max = 2000,
            step = 1,
            getFunc = function()
                return self.sv.offsetY
            end,
            setFunc = function(value)
                self.sv.offsetY = value
                self.win:ClearAnchors()
                self.win:SetAnchor(CENTER, GuiRoot, CENTER, self.sv.offsetX, self.sv.offsetY)
            end,
            default = defaults.offsetY,
        },
        {
            type = "slider",
            name = "Icon Size",
            tooltip = "Size of buff/debuff icons.",
            min = 16,
            max = 64,
            step = 1,
            getFunc = function()
                return self.sv.iconSize
            end,
            setFunc = function(value)
                self.sv.iconSize = value
                self:UpdateSlotLayout()
                self:Redraw()
            end,
            default = defaults.iconSize,
        },
        {
            type = "slider",
            name = "Font Size",
            tooltip = "Size of timer and stack text.",
            min = 10,
            max = 32,
            step = 1,
            getFunc = function()
                return self.sv.fontSize
            end,
            setFunc = function(value)
                self.sv.fontSize = value
                self:ApplyFontSettings()
            end,
            default = defaults.fontSize,
        },
        {
            type = "slider",
            name = "Flash threshold (seconds)",
            tooltip = "When remaining duration is below this, buffs/debuffs will flash.",
            min = 1,
            max = 15,
            step = 1,
            getFunc = function()
                return self.sv.flashThreshold
            end,
            setFunc = function(value)
                self.sv.flashThreshold = value
            end,
            default = defaults.flashThreshold,
        },
        {
            type = "dropdown",
            name = "Performance Mode",
            tooltip = "Lower CPU usage by reducing update frequency.",
            choices = { "Balanced", "Low CPU", "Ultra Low CPU" },
            getFunc = function()
                local map = {
                    balanced = "Balanced",
                    low = "Low CPU",
                    ultra = "Ultra Low CPU",
                }
                return map[self.sv.performanceMode] or "Low CPU"
            end,
            setFunc = function(choice)
                if choice == "Balanced" then
                    self.sv.performanceMode = "balanced"
                elseif choice == "Ultra Low CPU" then
                    self.sv.performanceMode = "ultra"
                else
                    self.sv.performanceMode = "low"
                end

                self.nextMaintenanceAt = 0
                self.nextVisualUpdateAt = 0
            end,
            default = "Low CPU",
        },
        {
            type = "slider",
            name = "Fallback Rescan Interval (seconds)",
            tooltip = "How often to rescan reticle effects when events are missed.",
            min = 0.5,
            max = 5.0,
            step = 0.1,
            getFunc = function()
                return self.sv.fallbackRescanInterval
            end,
            setFunc = function(value)
                self.sv.fallbackRescanInterval = value
                self:ApplyRuntimePlatformTuning()
                self.nextFallbackRescanAt = 0
            end,
            default = defaults.fallbackRescanInterval,
        },
        {
            type = "checkbox",
            name = "Auto Console Tuning",
            tooltip = "On console, reduce memory usage and update load automatically.",
            getFunc = function()
                return self.sv.autoConsoleTuning
            end,
            setFunc = function(value)
                self.sv.autoConsoleTuning = value
            end,
            default = defaults.autoConsoleTuning,
        },
        {
            type = "slider",
            name = "Console Slot Rows Cap",
            tooltip = "Maximum slot rows allocated on console when Auto Console Tuning is enabled.",
            min = 1,
            max = 256,
            step = 1,
            getFunc = function()
                return self.sv.consoleSlotRowsCap
            end,
            setFunc = function(value)
                self.sv.consoleSlotRowsCap = value
                self:ApplyRuntimePlatformTuning()
                self:ApplyCurrentLayout()
                self:Redraw()
                if d then
                    d("BetterEffectViewer: Slot pool cap updated. Use /reloadui to reclaim memory immediately.")
                end
            end,
            default = defaults.consoleSlotRowsCap,
        },
        {
            type = "slider",
            name = "Console Effect Cap",
            tooltip = "Maximum number of active effects tracked on console when Auto Console Tuning is enabled.",
            min = 1,
            max = 256,
            step = 1,
            getFunc = function()
                return self.sv.consoleEffectCap
            end,
            setFunc = function(value)
                self.sv.consoleEffectCap = value
                self:ApplyRuntimePlatformTuning()
            end,
            default = defaults.consoleEffectCap,
        },
        {
            type = "slider",
            name = "Console Max Cols Cap",
            tooltip = "Maximum columns allowed on console when Auto Console Tuning is enabled.",
            min = 1,
            max = 256,
            step = 1,
            getFunc = function()
                return self.sv.consoleMaxColsCap
            end,
            setFunc = function(value)
                self.sv.consoleMaxColsCap = value
                self:ApplyRuntimePlatformTuning()
                self:ApplyCurrentLayout()
            end,
            default = defaults.consoleMaxColsCap,
        },
        {
            type = "dropdown",
            name = "Effect Filter Mode",
            choices = { "None", "Whitelist", "Blacklist" },
            getFunc = function()
                if self.sv.filterMode == "whitelist" then
                    return "Whitelist"
                elseif self.sv.filterMode == "blacklist" then
                    return "Blacklist"
                end
                return "None"
            end,
            setFunc = function(choice)
                if choice == "Whitelist" then
                    self.sv.filterMode = "whitelist"
                elseif choice == "Blacklist" then
                    self.sv.filterMode = "blacklist"
                else
                    self.sv.filterMode = "none"
                end

                self:Redraw()
            end,
        },
        {
            type = "header",
            name = "Buff Colors",
        },
        {
            type = "colorpicker",
            name = "Buff border color",
            getFunc = function()
                return self:UnpackColor(self.sv.buffBorderColor)
            end,
            setFunc = function(r, g, b, a)
                self.sv.buffBorderColor = { r, g, b, a }
                self:Redraw()
            end,
            default = defaults.buffBorderColor,
        },
        {
            type = "colorpicker",
            name = "Buff timer color",
            getFunc = function()
                return self:UnpackColor(self.sv.buffTimerColor)
            end,
            setFunc = function(r, g, b, a)
                self.sv.buffTimerColor = { r, g, b, a }
                self:Redraw()
            end,
            default = defaults.buffTimerColor,
        },
        {
            type = "header",
            name = "Debuff Colors",
        },
        {
            type = "colorpicker",
            name = "Debuff border color",
            getFunc = function()
                return self:UnpackColor(self.sv.debuffBorderColor)
            end,
            setFunc = function(r, g, b, a)
                self.sv.debuffBorderColor = { r, g, b, a }
                self:Redraw()
            end,
            default = defaults.debuffBorderColor,
        },
        {
            type = "colorpicker",
            name = "Debuff timer color",
            getFunc = function()
                return self:UnpackColor(self.sv.debuffTimerColor)
            end,
            setFunc = function(r, g, b, a)
                self.sv.debuffTimerColor = { r, g, b, a }
                self:Redraw()
            end,
            default = defaults.debuffTimerColor,
        },
        {
            type = "header",
            name = "Permanent Effect Colors",
        },
        {
            type = "colorpicker",
            name = "Permanent border color",
            getFunc = function()
                return self:UnpackColor(self.sv.permanentBorderColor)
            end,
            setFunc = function(r, g, b, a)
                self.sv.permanentBorderColor = { r, g, b, a }
                self:Redraw()
            end,
            default = defaults.permanentBorderColor,
        },
        {
            type = "colorpicker",
            name = "Permanent timer color",
            getFunc = function()
                return self:UnpackColor(self.sv.permanentTimerColor)
            end,
            setFunc = function(r, g, b, a)
                self.sv.permanentTimerColor = { r, g, b, a }
                self:Redraw()
            end,
            default = defaults.permanentTimerColor,
        },
        {
            type = "dropdown",
            name = "Effect Sorting",
            tooltip = "Choose how buffs and debuffs are sorted.",
            choices = {
                "Shortest Remaining",
                "Longest Remaining",
                "Newest First",
                "Oldest First",
            },
            getFunc = function()
                local map = {
                    shortest = "Shortest Remaining",
                    longest = "Longest Remaining",
                    newest = "Newest First",
                    oldest = "Oldest First",
                }
                return map[self.sv.sortMode]
            end,
            setFunc = function(choice)
                if choice == "Shortest Remaining" then
                    self.sv.sortMode = "shortest"
                elseif choice == "Longest Remaining" then
                    self.sv.sortMode = "longest"
                elseif choice == "Newest First" then
                    self.sv.sortMode = "newest"
                elseif choice == "Oldest First" then
                    self.sv.sortMode = "oldest"
                end

                self:Redraw()
            end,
            default = "Shortest Remaining",
        },
        {
            type = "header",
            name = "Flash Color",
        },
        {
            type = "colorpicker",
            name = "Flash color",
            tooltip = "Color to flash towards when an effect is about to expire.",
            getFunc = function()
                return self:UnpackColor(self.sv.flashColor)
            end,
            setFunc = function(r, g, b, a)
                self.sv.flashColor = { r, g, b, a }
            end,
            default = defaults.flashColor,
        },
        {
            type = "checkbox",
            name = "Show Buffs",
            tooltip = "Show the buff section for the reticle target.",
            getFunc = function()
                return self.sv.showBuffs
            end,
            setFunc = function(value)
                self.sv.showBuffs = value
                self:Redraw()
            end,
            default = defaults.showBuffs,
        },
        {
            type = "checkbox",
            name = "Show Debuffs",
            tooltip = "Show the debuff section for the reticle target.",
            getFunc = function()
                return self.sv.showDebuffs
            end,
            setFunc = function(value)
                self.sv.showDebuffs = value
                self:Redraw()
            end,
            default = defaults.showDebuffs,
        },
        {
            type = "checkbox",
            name = "Show permanent effects",
            tooltip = "Show buffs/debuffs that have no duration or very long duration.",
            getFunc = function()
                return self.sv.showPermanents
            end,
            setFunc = function(value)
                self.sv.showPermanents = value
                self:Redraw()
            end,
            default = defaults.showPermanents,
        },
    }

    LAM:RegisterAddonPanel("BetterEffectViewerPanel", panelData)
    LAM:RegisterOptionControls("BetterEffectViewerPanel", optionsData)
end
