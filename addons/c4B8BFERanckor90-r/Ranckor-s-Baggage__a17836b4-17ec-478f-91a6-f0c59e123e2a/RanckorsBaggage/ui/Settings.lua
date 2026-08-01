local RB = RanckorsBaggage
local LAM = RB.LAM

function RB:CreateSettings()
    local panel = {
        type = "panel",
        name = "Ranckor's Baggage",
        displayName = "|cFFD700Ranckor's Baggage|r",
        author = "Ranckor90",
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
        resetFunc = function()
            self.saved.position        = { x = self.defaults.position.x, y = self.defaults.position.y }
            self.saved.uiScale         = 100
            self.saved.size            = nil
            self.saved.backgroundStyle = self.defaults.backgroundStyle or "clear"
            self.saved.displaySettings = ZO_DeepTableCopy(self.defaults.displaySettings)

            self:RestorePosition()
            self:RestoreSize()

            if self:IsValidWindow() then
                local bg = RanckorsBaggageWindow:GetNamedChild("BG")
                if bg then
                    self:ApplyBackgroundStyle(bg)
                end
            end

            self:RequestUpdate()
        end
    }

    self.settingsPanel = LAM:RegisterAddonPanel(self.name .. "Settings", panel)

    local playerCurrencies = {
        { key = CURT_MONEY,              label = "Gold" },
        { key = CURT_ALLIANCE_POINTS,    label = "Alliance Points" },
        { key = CURT_TELVAR_STONES,      label = "Tel Var Stones" },
        { key = CURT_TOME_POINT_CACHES,  label = "Caches of Tome Points" },
        { key = CURT_TOME_POINTS,        label = "Tome Points" },
        { key = CURT_TRADE_BARS,         label = "Trade Bars" },
        { key = CURT_TOME_TOKENS,        label = "Tome Tokens" },
        { key = CURT_UNDAUNTED_KEYS,     label = "Undaunted Keys" },
        { key = CURT_CHAOTIC_CREATIA,    label = "Transmute Crystals" },
        { key = CURT_CROWN_GEMS,         label = "Crown Gems" },
        { key = CURT_IMPERIAL_FRAGMENTS, label = "Imperial Fragments" },
        { key = CURT_ENDEAVOR_SEALS,     label = "Seals of Endeavor" },
        { key = CURT_WRIT_VOUCHERS,      label = "Writ Vouchers" },
        { key = CURT_ARCHIVAL_FORTUNES,  label = "Archival Fortunes" },
        { key = CURT_CROWNS,             label = "Crowns" },
    }

    local bankedCurrencies = {
        { key = "BankedGold",           label = "Banked Gold" },
        { key = "BankedAlliancePoints", label = "Banked Alliance Points" },
        { key = "BankedTelVar",         label = "Banked Tel Var Stones" },
        { key = "BankedWritVouchers",   label = "Banked Writ Vouchers" },
    }

    local encumbrance = {
        { key = "BagSpace",  label = "Bag Space" },
        { key = "BankSpace", label = "Bank Space" },
    }

    local opts = {}

    local function currentWindowSize()
        if self:IsValidWindow() then
            return RanckorsBaggageWindow:GetWidth(), RanckorsBaggageWindow:GetHeight()
        else
            return self:GetWindowSize()
        end
    end

    local wndW, wndH = currentWindowSize()
    local maxX = math.max(0, GuiRoot:GetWidth() - wndW)
    local maxY = math.max(0, GuiRoot:GetHeight() - wndH)

    table.insert(opts, { type = "header", name = "UI Position" })

    table.insert(opts, {
        type = "slider",
        name = "Position X",
        tooltip = "Horizontal position of the UI",
        min = 0,
        max = maxX,
        step = 1,
        getFunc = function() return self.saved.position.x end,
        setFunc = function(v)
            self.saved.position.x = v
            self:RestorePosition()
        end,
        default = self.defaults.position.x,
    })

    table.insert(opts, {
        type = "slider",
        name = "Position Y",
        tooltip = "Vertical position of the UI",
        min = 0,
        max = maxY,
        step = 1,
        getFunc = function() return self.saved.position.y end,
        setFunc = function(v)
            self.saved.position.y = v
            self:RestorePosition()
        end,
        default = self.defaults.position.y,
    })

    table.insert(opts, { type = "header", name = "Scale (Resize)" })

    table.insert(opts, {
        type = "slider",
        name = "UI Scale",
        tooltip = "Resize the window and its contents together. 100% is default.",
        min = 50,
        max = 200,
        step = 5,
        getFunc = function()
            return self.saved.uiScale or 100
        end,
        setFunc = function(val)
            self.saved.uiScale = math.floor(val + 0.5)
            self.saved.size = nil

            if self:IsValidWindow() then
                local bw = self.baseWidth or select(1, self:GetWindowSize())
                local bh = self.baseHeight or select(2, self:GetWindowSize())
                local s = (self.saved.uiScale or 100) / 100
                RanckorsBaggageWindow:SetDimensions(bw * s, bh * s)
                self:ApplyContentScale()
            end
        end,
        default = 100,
    })

    table.insert(opts, { type = "header", name = "Player Currencies" })
    for _, item in ipairs(playerCurrencies) do
        table.insert(opts, {
            type = "checkbox",
            name = item.label,
            getFunc = function() return self.saved.displaySettings[item.key] end,
            setFunc = function(val)
                self.saved.displaySettings[item.key] = val
                self:RequestUpdate()
            end,
            default = true,
        })
    end

    table.insert(opts, { type = "header", name = "Banked Currencies" })
    for _, item in ipairs(bankedCurrencies) do
        table.insert(opts, {
            type = "checkbox",
            name = item.label,
            getFunc = function() return self.saved.displaySettings[item.key] end,
            setFunc = function(val)
                self.saved.displaySettings[item.key] = val
                self:RequestUpdate()
            end,
            default = true,
        })
    end

    table.insert(opts, { type = "header", name = "Encumbrance" })
    for _, item in ipairs(encumbrance) do
        table.insert(opts, {
            type = "checkbox",
            name = item.label,
            getFunc = function() return self.saved.displaySettings[item.key] end,
            setFunc = function(val)
                self.saved.displaySettings[item.key] = val
                self:RequestUpdate()
            end,
            default = true,
        })
    end

    table.insert(opts, { type = "header", name = "Utilities" })

    table.insert(opts, {
        type = "dropdown",
        name = "Theme Style",
        tooltip = "Choose the background style for the display window.",
        choices = { "Clear", "Dark" },
        getFunc = function()
            return self:Ucfirst(self.saved.backgroundStyle or "clear")
        end,
        setFunc = function(choice)
            local style = string.lower(choice)
            self:SetBackgroundStyle(style)

            if self:IsValidWindow() then
                local bg = RanckorsBaggageWindow:GetNamedChild("BG")
                if bg then
                    self:ApplyBackgroundStyle(bg)
                end
            end
        end,
        default = "Clear",
        width = "full",
    })

    table.insert(opts, {
        type = "button",
        name = "Reset All",
        func = function()
            self.saved.position = self.saved.position or { x = 0, y = 100 }
            self.saved.position.x = self.defaults.position.x or 0
            self.saved.position.y = self.defaults.position.y or 100
            self.saved.uiScale = self.defaults.uiScale or 100
            self.saved.size = nil
            self.saved.backgroundStyle = self.defaults.backgroundStyle or "clear"

            for k in pairs(self.saved.displaySettings) do
                self.saved.displaySettings[k] = nil
            end
            for k, v in pairs(self.defaults.displaySettings) do
                self.saved.displaySettings[k] = v
            end

            self:RestorePosition()
            self:RestoreSize()

            local bg = self:IsValidWindow() and RanckorsBaggageWindow:GetNamedChild("BG")
            if bg then
                self:ApplyBackgroundStyle(bg)
            end

            self:RequestUpdate()

            if CALLBACK_MANAGER and self.settingsPanel then
                CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", self.settingsPanel)
            end
        end,
        width = "full",
        warning = "Resets position, scale, theme, and all toggles to defaults.",
    })

    LAM:RegisterOptionControls(self.name .. "Settings", opts)
end