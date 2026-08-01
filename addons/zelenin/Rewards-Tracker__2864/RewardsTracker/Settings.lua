local settings = ZO_InitializingObject:Subclass()
rewardsTrackerSettings = settings

function settings:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sSettings", self.owner.name)
    self.data = LibSimpleSavedVars:NewInstallationWide(string.format("%sData", self.name), 1, {
        notifications = {},
        timers = {},
        allianceWarUi = true,
        apChatNotifications = true,
        test = false,
        characters={},
        log = true,
    })

    self.data.test = nil

    if self.data.allianceWarUi == nil then
        self.data.allianceWarUi = true
    end
    if self.data.timers == nil then
        self.data.timers = {}
    end
    if self.data.characters == nil then
        self.data.characters = {}
    end
    if self.data.apChatNotifications == nil then
        self.data.apChatNotifications = true
    end
    if self.data.log == nil then
        self.data.log = true
    end

    self.panel = LibAddonMenu2

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

    self.panel:RegisterAddonPanel(panelData.name, panelData)

    local optionsTable = {}

    local servers = {
        LibCharacter.EU,
        LibCharacter.NA
    }

    for _, account in ipairs(LibCharacter:GetAccounts()) do
        for _, server in ipairs(servers) do
            local characters = LibCharacter:GetCharacters(function(character)
                return character.account == account and character.server == server
            end, LibCharacter.SORT_NAME)

            if #characters > 0 then
                table.insert(optionsTable, {
                    type = "header",
                    name = ZO_HIGHLIGHT_TEXT:Colorize(string.format("%s, %s", account, server)),
                    width = "full",
                })
                for _, character in ipairs(characters) do
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
                        requiresReload = true
                    })
                end
            end
        end
    end

    table.insert(optionsTable, {
        type = "header",
        name = ZO_HIGHLIGHT_TEXT:Colorize("Character timers"),
        width = "full",
    })

    for _, _characterReward in ipairs(self.owner.characterRewards) do
        if self.data.timers[_characterReward:GetId()] == nil then
            self.data.timers[_characterReward:GetId()] = true
        end
        table.insert(optionsTable, {
            type = "checkbox",
            name = _characterReward:GetFullName(),
            getFunc = function()
                return self.data.timers[_characterReward:GetId()]
            end,
            setFunc = function(value)
                self.data.timers[_characterReward:GetId()] = value
            end,
            width = "full",
            requiresReload = true
        })
    end

    table.insert(optionsTable, {
        type = "header",
        name = ZO_HIGHLIGHT_TEXT:Colorize("Account timers"),
        width = "full",
    })

    for _, _accountReward in ipairs(self.owner.accountRewards) do
        if self.data.timers[_accountReward:GetId()] == nil then
            self.data.timers[_accountReward:GetId()] = true
        end
        table.insert(optionsTable, {
            type = "checkbox",
            name = _accountReward:GetFormattedName(),
            getFunc = function()
                return self.data.timers[_accountReward:GetId()]
            end,
            setFunc = function(value)
                self.data.timers[_accountReward:GetId()] = value
            end,
            width = "full",
            requiresReload = true
        })
    end

    table.insert(optionsTable, {
        type = "header",
        name = ZO_HIGHLIGHT_TEXT:Colorize("Notifications"),
        width = "full",
    })

    for _, _accountReward in ipairs(self.owner.accountRewards) do
        if self.data.notifications[_accountReward:GetId()] == nil then
            self.data.notifications[_accountReward:GetId()] = false
        end
        table.insert(optionsTable, {
            type = "checkbox",
            name = _accountReward:GetFormattedName(),
            getFunc = function()
                return self.data.notifications[_accountReward:GetId()]
            end,
            setFunc = function(value)
                self.data.notifications[_accountReward:GetId()] = value
            end,
            width = "full",
        })
    end

    table.insert(optionsTable, {
        type = "header",
        name = ZO_HIGHLIGHT_TEXT:Colorize("Other settings"),
        width = "full",
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = "Alliance War campaign UI",
        getFunc = function()
            return self.data.allianceWarUi
        end,
        setFunc = function(value)
            self.data.allianceWarUi = value
        end,
        width = "full",
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = "AP chat notifications",
        getFunc = function()
            return self.data.apChatNotifications
        end,
        setFunc = function(value)
            self.data.apChatNotifications = value
        end,
        width = "full",
    })

    table.insert(optionsTable, {
        type = "header",
        name = ZO_HIGHLIGHT_TEXT:Colorize("Other settings"),
        width = "full",
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = "Log to chat",
        getFunc = function()
            return self.data.log == true
        end,
        setFunc = function(value)
            self.data.log = value
        end,
        width = "full",
    })

    self.panel:RegisterOptionControls(panelData.name, optionsTable)
end
