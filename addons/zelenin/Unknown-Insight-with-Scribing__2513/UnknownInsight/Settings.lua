local class = ZO_InitializingObject:Subclass()
unknownInsightSettings = class

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sSettings", self.owner.addonData.name)
    self.data = LibSimpleSavedVars:NewInstallationWide(string.format("%sData", self.name), 1, {
        --iconSize = 24,
        --iconXOffset = 460,
        --iconYOffset = 0,
        colorUnknown = { r = 1, g = 0, b = 0 },
        colorSemiUnknown = { r = 1, g = 1, b = 0 },
        colorKnown = { r = 0.5, g = 0.5, b = 0.5 },
        chatIcon = true,
        characters = {},
        tooltip = true,
        tooltipHeader = self.owner.addonData.title
    })

    if self.data.chatIcon == nil then
        self.data.chatIcon = true
    end

    if self.data.tooltip == nil then
        self.data.tooltip = true
    end

    self.panel = LibAddonMenu2

    self:initSettingsPanel()
end

function class:initSettingsPanel()
    local panelData = {
        type = "panel",
        name = self.owner.addonData.title,
        displayName = self.owner.addonData.title,
        author = self.owner.addonData.author,
        version = tostring(self.owner.addonData.version),
        registerForRefresh = true,
        registerForDefaults = true,
    }

    self.panel:RegisterAddonPanel(panelData.name, panelData)

    local optionsTable = {}

    --table.insert(optionsTable, {
    --    type = "slider",
    --    name = "Icon Size",
    --    getFunc = function()
    --        return self.data.iconSize
    --    end,
    --    setFunc = function(value)
    --        self.data.iconSize = value
    --    end,
    --    min = 16,
    --    max = 48,
    --    step = 4,
    --    decimals = 0,
    --    width = "full",
    --    default = self.data.iconSize,
    --})

    --table.insert(optionsTable, {
    --    type = "slider",
    --    name = "Icon X axis offset",
    --    getFunc = function()
    --        return self.data.iconXOffset
    --    end,
    --    setFunc = function(value)
    --        self.data.iconXOffset = value
    --    end,
    --    min = 0,
    --    max = 500,
    --    step = 1,
    --    decimals = 0,
    --    width = "full",
    --    default = self.data.iconXOffset,
    --})

    --table.insert(optionsTable, {
    --    type = "slider",
    --    name = "Icon Y axis offset",
    --    getFunc = function()
    --        return self.data.iconYOffset
    --    end,
    --    setFunc = function(value)
    --        self.data.iconYOffset = value
    --    end,
    --    min = -16,
    --    max = 16,
    --    step = 1,
    --    decimals = 0,
    --    --inputLocation = "below",
    --    width = "full",
    --    default = nil,
    --})

    table.insert(optionsTable, {
        type = "colorpicker",
        name = "Unknown color",
        getFunc = function()
            return self.data.colorUnknown.r, self.data.colorUnknown.g, self.data.colorUnknown.b
        end,
        setFunc = function(r, g, b, a)
            self.data.colorUnknown.r = r
            self.data.colorUnknown.g = g
            self.data.colorUnknown.b = b
        end,
        default = {
            r = self.data.colorUnknown.r,
            g = self.data.colorUnknown.g,
            b = self.data.colorUnknown.b,
        }
    })

    table.insert(optionsTable, {
        type = "colorpicker",
        name = "Known by some characters color",
        getFunc = function()
            return self.data.colorSemiUnknown.r, self.data.colorSemiUnknown.g, self.data.colorSemiUnknown.b
        end,
        setFunc = function(r, g, b, a)
            self.data.colorSemiUnknown.r = r
            self.data.colorSemiUnknown.g = g
            self.data.colorSemiUnknown.b = b
        end,
        default = {
            r = self.data.colorSemiUnknown.r,
            g = self.data.colorSemiUnknown.g,
            b = self.data.colorSemiUnknown.b,
        }
    })

    table.insert(optionsTable, {
        type = "colorpicker",
        name = "Known color",
        getFunc = function()
            return self.data.colorKnown.r, self.data.colorKnown.g, self.data.colorKnown.b
        end,
        setFunc = function(r, g, b, a)
            self.data.colorKnown.r = r
            self.data.colorKnown.g = g
            self.data.colorKnown.b = b
        end,
        default = {
            r = self.data.colorKnown.r,
            g = self.data.colorKnown.g,
            b = self.data.colorKnown.b,
        }
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = "Chat icon",
        getFunc = function()
            return self.data.chatIcon
        end,
        setFunc = function(value)
            self.data.chatIcon = value
        end,
        width = "full",
        requiresReload = true,
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = "Add info to the tooltip",
        getFunc = function()
            return self.data.tooltip
        end,
        setFunc = function(value)
            self.data.tooltip = value
        end,
        width = "full",
        requiresReload = true,
    })

    table.insert(optionsTable, {
        type = "editbox",
        name = "Tooltip header",
        getFunc = function()
            return self.data.tooltipHeader
        end,
        setFunc = function(value)
            self.data.tooltipHeader = value
        end,
        isMultiline = false,
        isExtraWide = false,
        width = "full"
    })

    table.insert(optionsTable, {
        type = "header",
        name = ZO_HIGHLIGHT_TEXT:Colorize("Characters"),
        width = "full",
    })

    table.insert(optionsTable, {
        type = "divider",
        width = "full",
        height = 10,
        alpha = 0.25,
    })

    local servers = {}
    for _, character in ipairs(LibCharacter:GetCharacters()) do
        servers[character.server] = true
    end

    local serverKeys = {}
    for server, _ in pairs(servers) do
        table.insert(serverKeys, server)
    end

    table.sort(serverKeys)

    for _, serverName in ipairs(serverKeys) do
        if #serverKeys > 1 then
            table.insert(optionsTable, {
                type = "header",
                name = ZO_HIGHLIGHT_TEXT:Colorize(serverName),
                width = "full",
            })
        end

        for _, character in ipairs(LibCharacter:GetServerCharacters(serverName)) do
            if self.data.characters[character.id] == nil then
                self.data.characters[character.id] = true
            end
            table.insert(optionsTable, {
                type = "checkbox",
                name = character.name,
                getFunc = function()
                    return self.data.characters[character.id]
                end,
                setFunc = function(value)
                    self.data.characters[character.id] = value
                end,
                width = "full",
            })
        end
    end

    self.panel:RegisterOptionControls(panelData.name, optionsTable)
end
