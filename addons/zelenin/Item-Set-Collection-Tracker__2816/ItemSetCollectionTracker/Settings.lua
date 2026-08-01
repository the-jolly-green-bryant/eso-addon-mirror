local settings = ZO_Object:Subclass()
itemSetCollectionTrackerSettings = settings

function settings:New(...)
    local instance = ZO_Object.New(self)
    instance:initialize(...)
    return instance
end

function settings:initialize(owner)
    self.owner = owner
    self.name = string.format("%sSettings", self.owner.name)
    self.data = LibSimpleSavedVars:NewInstallationWide(string.format("%sData", self.name), 1, {
        iconSize = 24,
        iconXOffset = 36,
        iconYOffset = -16,
        color = { r = 1, g = 0, b = 0 },
        test = false,
        notifications = true,
        notificationsOnlyMy = false,
        notificationsSetInfo = true,
        chatIcon = true,
        autoBind = false,
        uiEnhancemements = true,
        lootPosting = {
            armor = true,
            jewelry = true,
            weapon = true,
            monsterSet = true,
        }
    })

    if self.data.test == nil then
        self.data.test = false
    end
    if self.data.autoBind == nil then
        self.data.autoBind = false
    end
    if self.data.uiEnhancemements == nil then
        self.data.uiEnhancemements = true
    end
    if self.data.chatIcon == nil then
        self.data.chatIcon = true
    end
    if self.data.lootPosting == nil then
        self.data.lootPosting = {
            armor = false,
            jewelry = false,
            weapon = true,
            monsterSet = true,
        }
    end
    if self.data.notificationsOnlyMy == nil then
        self.data.notificationsOnlyMy = false
    end
    if self.data.notificationsSetInfo == nil then
        self.data.notificationsSetInfo = true
    end

   self:initSettingsPanel()
end

function settings:initSettingsPanel()
    local panelData = {
        type = "panel",
        name = self.owner.addonData.title,
        displayName = self.owner.addonData.title,
        author = self.owner.addonData.author,
        version = tostring(self.owner.addonData.version),
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LibAddonMenu2:RegisterAddonPanel(panelData.name, panelData)

    local optionsTable = {}

    table.insert(optionsTable, {
        type = "header",
        name = ZO_HIGHLIGHT_TEXT:Colorize(GetString(SI_SETTINGS_ICON)),
        width = "full",
    })

    table.insert(optionsTable, {
        type = "slider",
        name = GetString(SI_SETTINGS_ICON_SIZE),
        getFunc = function()
            return self.data.iconSize
        end,
        setFunc = function(value)
            self.data.iconSize = value
        end,
        min = 16,
        max = 48,
        step = 4,
        decimals = 0,
        width = "full",
        default = self.data.iconSize,
    })

    table.insert(optionsTable, {
        type = "slider",
        name = GetString(SI_SETTINGS_ICON_X),
        getFunc = function()
            return self.data.iconXOffset
        end,
        setFunc = function(value)
            self.data.iconXOffset = value
        end,
        min = 0,
        max = 500,
        step = 1,
        decimals = 0,
        width = "full",
        default = self.data.iconXOffset,
    })

    table.insert(optionsTable, {
        type = "slider",
        name = GetString(SI_SETTINGS_ICON_Y),
        getFunc = function()
            return self.data.iconYOffset
        end,
        setFunc = function(value)
            self.data.iconYOffset = value
        end,
        min = -16,
        max = 16,
        step = 1,
        decimals = 0,
        --inputLocation = "below",
        width = "full",
        default = nil,
    })

    table.insert(optionsTable, {
        type = "colorpicker",
        name = GetString(SI_SETTINGS_COLOR),
        getFunc = function()
            return self.data.color.r, self.data.color.g, self.data.color.b
        end,
        setFunc = function(r, g, b, a)
            self.data.color.r = r
            self.data.color.g = g
            self.data.color.b = b
        end,
        default = {
            r = self.data.color.r,
            g = self.data.color.g,
            b = self.data.color.b,
        }
    })

    table.insert(optionsTable, {
        type = "divider",
        width = "full",
        --height = 10,
        --alpha = 0.25,
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = GetString(SI_SETTINGS_LOOT_NOTIFICATIONS),
        getFunc = function()
            return self.data.notifications
        end,
        setFunc = function(value)
            self.data.notifications = value
            self.owner:notifications(self.data.notifications, self.data.notificationsOnlyMy)
        end,
        width = "full",
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = GetString(SI_SETTINGS_LOOT_NOTIFICATIONS_ONLY_MY),
        getFunc = function()
            return self.data.notificationsOnlyMy
        end,
        setFunc = function(value)
            self.data.notificationsOnlyMy = value
            self.owner:notifications(self.data.notifications, self.data.notificationsOnlyMy)
        end,
        width = "full",
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = GetString(SI_SETTINGS_LOOT_NOTIFICATIONS_SET_INFO),
        getFunc = function()
            return self.data.notificationsSetInfo
        end,
        setFunc = function(value)
            self.data.notificationsSetInfo = value
            self.owner:notifications(self.data.notifications, self.data.notificationsOnlyMy, self.data.notificationsSetInfo)
        end,
        width = "full",
    })

    table.insert(optionsTable, {
        type = "divider",
        width = "full",
        --height = 10,
        --alpha = 0.25,
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = GetString(SI_SETTINGS_CHAT_ICONS),
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
        name = GetString(SI_SETTINGS_AUTO_BIND),
        getFunc = function()
            return self.data.autoBind
        end,
        setFunc = function(value)
            self.data.autoBind = value
            self.owner.bind:eventHandler(self.data.autoBind)
        end,
        width = "full",
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = GetString(SI_SETTINGS_UI_ENHANCEMENTS),
        getFunc = function()
            return self.data.uiEnhancemements
        end,
        setFunc = function(value)
            self.data.uiEnhancemements = value
        end,
        width = "full",
        requiresReload = true,
    })

    table.insert(optionsTable, {
        type = "header",
        name = ZO_HIGHLIGHT_TEXT:Colorize(GetString(SI_SETTINGS_LOOT_POSTING)),
        width = "full",
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = GetString(SI_SETTINGS_LOOT_POSTING_ARMOR),
        getFunc = function()
            return self.data.lootPosting.armor
        end,
        setFunc = function(value)
            self.data.lootPosting.armor = value
        end,
        width = "full",
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = GetString(SI_SETTINGS_LOOT_POSTING_JEWELRY),
        getFunc = function()
            return self.data.lootPosting.jewelry
        end,
        setFunc = function(value)
            self.data.lootPosting.jewelry = value
        end,
        width = "full",
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = GetString(SI_SETTINGS_LOOT_POSTING_WEAPON),
        getFunc = function()
            return self.data.lootPosting.weapon
        end,
        setFunc = function(value)
            self.data.lootPosting.weapon = value
        end,
        width = "full",
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = GetString(SI_SETTINGS_LOOT_POSTING_MONSTER_SET),
        getFunc = function()
            return self.data.lootPosting.monsterSet
        end,
        setFunc = function(value)
            self.data.lootPosting.monsterSet = value
        end,
        width = "full",
    })

    LibAddonMenu2:RegisterOptionControls(panelData.name, optionsTable)
end
