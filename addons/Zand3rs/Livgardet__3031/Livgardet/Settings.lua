local LAM2 = LibAddonMenu2
local leaveOption = { GetString(LIVGARDET_SETTINGS_NOGUILDLEAVE_COICE_0), GetString(LIVGARDET_SETTINGS_NOGUILDLEAVE_COICE_1), GetString(LIVGARDET_SETTINGS_NOGUILDLEAVE_COICE_2) }
local leaveOptionLookup = { [GetString(LIVGARDET_SETTINGS_NOGUILDLEAVE_COICE_0)] = 0, [GetString(LIVGARDET_SETTINGS_NOGUILDLEAVE_COICE_1)] = 1, [GetString(LIVGARDET_SETTINGS_NOGUILDLEAVE_COICE_2)] = 2 }

function Livgardet:InitializeMenu()
    local panelData = {
        type = "panel",
        name = self.addonName,
        displayName = self.displayName,
        author = "Zand3rs",
        version = "2.3",
        slashCommand = "/Livgardet",
        website = "",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsTable = {
        {
            type = "header",
            name = GetString(LIVGARDET_SETTINGS_HEADER_GENERAL),
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(LIVGARDET_SETTINGS_CHAT_ICON),
            getFunc = function()
                return self.db.showChatIcon
            end,
            setFunc = function(show)
                self.db.showChatIcon = show
                self:ShowChatIcon(show)
            end,
        },
 --       {
 --           type = "checkbox",
 --           name = GetString(LIVGARDET_SETTINGS_MONOCHROME_ICON),
 --           getFunc = function()
 --               return self.db.monochromeIcon
 --           end,
 --           setFunc = function(monochrome)
 --               self.db.monochromeIcon = monochrome
 --               self:SetChatIconTexture(monochrome)
 --           end,
 --           disabled = function()
 --               return not self.db.showChatIcon
 --           end
  --      },
        {
            type = "dropdown",
            name = GetString(LIVGARDET_SETTINGS_NOGUILDLEAVE),
            tooltip = GetString(LIVGARDET_SETTINGS_TOOLTIP_NOGUILDLEAVE),
            choices = leaveOption,
            getFunc = function()
                return leaveOption[self.db.noGuildLeave + 1]
            end,
            setFunc = function(value)
                self.db.noGuildLeave = leaveOptionLookup[value]
                self:CheckNoGuildLeave()
            end,
            default = leaveOption[self.defaults.noGuildLeave + 1],
        },
        { -- BUG EATER.
        type = 'checkbox', 
        name = GetString(LIVGARDET_SETTINGS_BUGEATER), 
        tooltip = GetString(LIVGARDET_SETTINGS_BUGEATER_TT), 
        getFunc = function() return self.db.BugEater end, 
        setFunc = function(value) self.db.BugEater = value end, 
        },
--        {
--            type = "header",
--            name = GetString(LIVGARDET_SETTINGS_HEADER_NAMES),
--            width = "full",
--        },
--        {
--            type = "description",
--            title = nil,
--            text = GetString(LIVGARDET_SETTINGS_HEADER_DESCRIPTION),
--            width = "full",
--        },
--        {
--            type = "checkbox",
--            name = GetString(LIVGARDET_SETTINGS_COLORIZE_GUILD_NAMES),
--            getFunc = function()
--                return self.db.colorizeNames
--            end,
--            setFunc = function(colorize)
--                self.db.colorizeNames = colorize
--            end,
--        },
        {
            type = "header",
            name = GetString(LIVGARDET_SETTINGS_HEADER_QOL),
            width = "full",
        },
        { -- SKIP CONFIRM PROMPT WHEN ERASING MAIL.
            type = "checkbox",
            name = GetString(LIVGARDET_SETTINGS_MAIL_DELETION),
            tooltip = GetString(LIVGARDET_SETTINGS_MAIL_DELETION_TT),
            getFunc = function() return self.db.skipMailDeletionPrompt end,
            setFunc = function( skip ) self.db.skipMailDeletionPrompt = skip end,
        },
        { -- HIDE DIALOG WHEN IMPROVING ITEMS.
			type = "checkbox",
			name = GetString(LIVGARDET_SETTINGS_CONFIRM_IMPROVE),
            tooltip = GetString(LIVGARDET_SETTINGS_CONFIRM_IMPROVE_TT),
			getFunc = function() return self.db.ConfirmDialog end,
			setFunc = function(value) self.db.ConfirmDialog = value end,
		},
        { -- NO CONFIRM TRAVEL.
            type = 'checkbox',
            name = GetString(LIVGARDET_SETTINGS_CONFIRM_FAST_TRAVEL),
            tooltip = GetString(LIVGARDET_SETTINGS_CONFIRM_FAST_TRAVEL_TT),
            getFunc = function() return self.db.NoConfirmTravel end,
            setFunc = function(value) self.db.NoConfirmTravel = value end,
         }, 
         { -- AUTO TRADER.
            type = 'checkbox',
            name = GetString(LIVGARDET_SETTINGS_AUTOTRADER),
            tooltip = GetString(LIVGARDET_SETTINGS_AUTOTRADER_TT),
            getFunc = function() return self.db.AutoTrader end,
            setFunc = function(value) self.db.AutoTrader = value AutoTradeRepair() end,
         }, 
         { -- AUTO REPAIR.
            type = 'checkbox', 
            name = GetString(LIVGARDET_SETTINGS_AUTOREPAIR), 
            tooltip = GetString(LIVGARDET_SETTINGS_AUTOREPAIR_TT), 
            getFunc = function() return self.db.AutoRepair end, 
            setFunc = function(value) self.db.AutoRepair = value end,
         }, 

        { -- HIDE BOOK WHEN READING.
        type = "checkbox",
        name = GetString(LIVGARDET_SETTINGS_CONFIRM_NOBOOK),
        tooltip = GetString(LIVGARDET_SETTINGS_CONFIRM_NOBOOK_TT),
        getFunc = function() return self.db.dontReadBooks end,
        setFunc = function(value) self.db.dontReadBooks = value DontReadBooks() end, 
        },
--        { -- AUTO LOOT CRAFTING MATERIALS.
--        type = 'checkbox', 
--        name = GetString(LIVGARDET_SETTINGS_CRAFTAUTOLOOT), 
--        tooltip = GetString(LIVGARDET_SETTINGS_CRAFTAUTOLOOT_TT), 
--        getFunc = function() return self.db.test22 end, 
--        setFunc = function(value) self.db.test22 = value end, 
--    }, 
    
}

    self.panel = LAM2:RegisterAddonPanel(self.name .. "Options", panelData)
    LAM2:RegisterOptionControls(self.name .. "Options", optionsTable)
end
