GuildDonate = {
    displayName = "|c3CB371" .. "Guild Donate" .. "|r",
    shortName = "GD",
    name = "GuildDonate",
    version = "1.4.11",

    isSelect = false,
    selectedGuildId = nil,
    history = nil,

    bindButton = {
        name = function()
            return GuildDonate:GetBindButtonName()
        end,
        keybind = "GD_HISTORY",
        visible = function()
            return true
        end,
        callback = function()
            GuildDonate:OpenHistory()
        end,
        enabled = true,
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
    },

}




function GuildDonate:CanDonate(guildId)

    self:Debug("　　[CanDonate] " .. tostring(guildId))
    if guildId == nil then
        self:Debug("　　　　> false:guildId is nil")
        return false
    end

    local guildName = GetGuildName(guildId)
    if guildName == nil then
        self:Debug("　　　　> false:guildName is nil")
        return false
    end
    self:Debug("　　　　guildName=" .. tostring(guildName))

    local deposited = self.savedVariables.depositedList[guildName]
    self:Debug("　　　　deposited=" .. tostring(deposited))
    if deposited == nil then
        self:Debug("　　　　> false:deposited[] is nil")
        return false
    end

    self:Debug("　　　　payAmount=" .. tostring(deposited[1]))
    if (deposited[1] == nil) or (deposited[1] == 0) then
        self:Debug("　　　　> false:payAmount is nil/0")
        return false
    end


    self:Debug("　　　　lastDonate=" .. tostring(deposited[2]))
    if deposited[2] then
        local nowTime = os.time()
        local year, month, day = string.match(deposited[2], "(%d+)%p(%d+)%p(%d+).*")
        local lastDeposited = os.time({
            ["year"] = tonumber(year),
            ["month"] = tonumber(month),
            ["day"] = tonumber(day),
            })

        self:Debug("　　　　interval=" .. tostring(deposited[3]))
        if deposited[3] > 1 then
            local fromTime, toTime = self:CreateFromTo(deposited[3])
            if fromTime <= lastDeposited then
                self:Debug("　　　　> false:interval")
                return false
            end

        else
            -- Case: 1Day
            local interval = deposited[3] * 86400 -- 1day = 86400sec
            local difftime = os.difftime(nowTime, lastDeposited)
            if difftime < interval then
                self:Debug("　　　　> false:interval(1Day)")
                return false
            end
        end
    end


    if self.selectedGuildId then
        local currencyAmount = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
        if currencyAmount < tonumber(deposited[1]) then
            self:Debug("　　　　> false:currency is " .. tostring(currencyAmount))
            local payAmount = deposited[1]
            local goldIcon = zo_iconFormat("EsoUI/Art/currency/currency_gold.dds", 16, 16)
            local msg = GetString(SI_STOREFAILURE12) .. " [" .. guildName .. "] x " .. payAmount .. goldIcon
            self:Message(msg, ZO_ERROR_COLOR:ToHex())
            return false
        end
    end


    self:Debug("　　　　> true")
    return true
end




function GuildDonate:CreateFromTo(interval)

    if interval > 1 then
        local startWeek = interval - 10
        --self:DebugIfMarify("startWeek=" .. tostring(startWeek))
        local nowTime = os.time()
        local nowWeek = tonumber(os.date("%w", nowTime))
        if nowWeek == 0 then   -- 0:Sun
            nowWeek = 7
        end


        local fromTime = nowTime
        if nowWeek > startWeek then
            fromTime = nowTime + ((nowWeek - startWeek) * -86400) -- 1day = 86400sec

        elseif nowWeek < startWeek then
            nowWeek = nowWeek + 7
            fromTime = nowTime + ((nowWeek - startWeek) * -86400) -- 1day = 86400sec
        end
        fromTime = os.time({
            ["year"]    = tonumber(os.date("%Y", fromTime)),
            ["month"]   = tonumber(os.date("%m", fromTime)),
            ["day"]     = tonumber(os.date("%d", fromTime)),
            ["hour"]    = 0,
            ["min"]     = 0,
            })
        local toTime = fromTime + (6 * 86400)
        toTime = os.time({
            ["year"]    = tonumber(os.date("%Y", toTime)),
            ["month"]   = tonumber(os.date("%m", toTime)),
            ["day"]     = tonumber(os.date("%d", toTime)),
            ["hour"]    = 23,
            ["min"]     = 59,
            })
        return fromTime, toTime
    end
end





function GuildDonate:CreateGuildIdList()

    local guildId
    local guildName
    self.guildIdList = {}
    for guildIndex = 1, GetNumGuilds() do
        guildId = tonumber(GetGuildId(guildIndex))
        guildName = GetGuildName(guildId)

        self.guildIdList[guildId] = guildName
        self.savedVariables.guildIdListForHistory[guildId] = guildName
    end

end




function GuildDonate:CreateMenu()

    self.savedVariables.debugLog = {}


    local panelData = {
        type = "panel",
        name = self.displayName,
        displayName = self.displayName,
        author = "Marify",
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    local settingsPanel = LibAddonMenu2:RegisterAddonPanel(self.displayName, panelData)

    local function CreateIcons(panel)
        if panel ~= settingsPanel then
            return
        end

        for guildIndex = 1, GetNumGuilds() do
            local intervalGuild = WINDOW_MANAGER:GetControlByName("intervalGuild", guildIndex)
            if intervalGuild == nil then
                break
            end
            intervalGuild.combobox:SetWidth(220)
            intervalGuild.combobox:SetHeight(30)

            local title = WINDOW_MANAGER:CreateControl(nil, intervalGuild, CT_LABEL)
            title:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            title:SetFont("ZoFontGame")
            title:SetText(GetString(SI_BANK_DEPOSIT))
            local textWidth = title:GetTextWidth()
            title:SetWidth(textWidth)
            title:SetAnchor(RIGHT, intervalGuild.dropdown:GetControl(), LEFT, textWidth / 2 * -1, 0)

            local title = WINDOW_MANAGER:CreateControl(nil, intervalGuild, CT_LABEL)
            title:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            title:SetFont("ZoFontGame")
            title:SetText("/")
            textWidth = title:GetTextWidth()
            title:SetWidth(textWidth)
            title:SetAnchor(RIGHT, intervalGuild.dropdown:GetControl(), LEFT, -10, 0)

            local depositGuild = WINDOW_MANAGER:GetControlByName("depositGuild", guildIndex)
            local icon = WINDOW_MANAGER:CreateControl(nil, depositGuild, CT_TEXTURE)
            icon:SetTexture("EsoUI/Art/currency/currency_gold.dds")
            icon:SetDimensions(16, 16)
            icon:SetAnchor(RIGHT, depositGuild.slidervalue, LEFT, 65, 0)
        end
        CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", CreateIcons)
    end
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", CreateIcons)


    local optionsTable = {}
    for guildIndex = 1, GetNumGuilds() do
        local guildId = GetGuildId(guildIndex)
        local guildName = GetGuildName(guildId)
        if guildName then
            local deposited = self.savedVariables.depositedList[guildName]
            if deposited then
                if deposited[3] == nil then
                    deposited[3] = 1
                end
                if deposited[3] == 7 then
                    deposited[3] = 11
                end

                optionsTable[#optionsTable + 1] = {
                    type = "header",
                    name = function()
                        return guildName
                    end,
                    width = "full",
                }
                optionsTable[#optionsTable + 1] = {
                    type = "description",
                    reference = "description" .. guildIndex,
                    text = function()
                        if deposited[1] == 0 then
                            return ""
                        end

                        local txtColor
                        local status
                        if self:CanDonate(guildId) then
                            txtColor = "FFA500"
                            status = "(" .. GetString(SI_ACHIEVEMENTS_INCOMPLETE) .. ")"

                            local fromTime, toTime = self:CreateFromTo(deposited[3])
                            if fromTime and deposited[3] > 1 then
                                return zo_strformat("|c<<1>><<2>> <<3>> ... <<4>>|r",
                                                    txtColor,
                                                    status,
                                                    os.date("%Y/%m/%d [%a] %H:%M", fromTime),
                                                    os.date("%Y/%m/%d [%a] %H:%M", toTime))
                            else
                                return zo_strformat("|c<<1>><<2>> <<3>>|r",
                                                    txtColor,
                                                    status,
                                                    os.date("%Y/%m/%d [%a]", fromTime))
                            end
                        else
                            txtColor = "808080"
                            status = "(" .. GetString(SI_QUEST_TYPE_COMPLETE) .. ")"

                            return zo_strformat("|c<<1>><<2>> <<3>>|r",
                                                txtColor,
                                                status,
                                                deposited[2])
                        end

                    end,
                    width = "full",
                }
                optionsTable[#optionsTable + 1] = {
                    type = "dropdown",
                    reference = "intervalGuild" .. guildIndex,
                    choices = {
                        zo_strformat(GetString(SI_TIME_FORMAT_DAYS_DESC_SHORT), 1),
                        zo_strformat(GetString(GD_WEEKLY), GetString(GD_MONDAY)),
                        zo_strformat(GetString(GD_WEEKLY), GetString(GD_TUESDAY)),
                        zo_strformat(GetString(GD_WEEKLY), GetString(GD_WEDNESDAY)),
                        zo_strformat(GetString(GD_WEEKLY), GetString(GD_THURSDAY)),
                        zo_strformat(GetString(GD_WEEKLY), GetString(GD_FRIDAY)),
                        zo_strformat(GetString(GD_WEEKLY), GetString(GD_SATURDAY)),
                        zo_strformat(GetString(GD_WEEKLY), GetString(GD_SUNDAY)),
                        },
                    choicesValues = {
                        1,
                        11,
                        12,
                        13,
                        14,
                        15,
                        16,
                        17,
                        },
                    getFunc = function()
                        return deposited[3]
                    end,
                    setFunc = function(value)
                        deposited[3] = tonumber(value)
                    end,
                    disabled = function()
                        return (deposited[1] == 0)
                    end,
                    width = "full",
                    default = 1,
                }
                optionsTable[#optionsTable + 1] = {
                    type = "slider",
                    reference = "depositGuild" .. guildIndex,
                    min = 0,
                    max = 1000000,
                    step = 1000,
                    getFunc = function()
                        return deposited[1]
                    end,
                    setFunc = function(value)
                        deposited[1] = tonumber(value)
                    end,
                    width = "full",
                    default = 1000,
                }
            end
        end
    end

    optionsTable[#optionsTable + 1] = {
        type = "header",
        name = GetString(SI_PLAYER_MENU_MISC),
        width = "full",
    }
    optionsTable[#optionsTable + 1] = {
        type = "checkbox",
        name = GetString(GD_AUTO),
        getFunc = function()
            return self.savedVariables.auto
        end,
        setFunc = function(value)
            self.savedVariables.auto = value
        end,
        width = "full",
        default = false,
    }
    optionsTable[#optionsTable + 1] = {
        type = "slider",
        name = GetString(GD_MAX_HISTORY),
        min = 0,
        max = 2000,
        step = 1,
        disabled = function()
            return (not self.savedVariables.maxHistory)
        end,
        getFunc = function()
            return self.savedVariables.maxHistory
        end,
        setFunc = function(value)
            self.savedVariables.maxHistory = tonumber(value)
        end,
        width = "full",
        default = 300,
    }
    optionsTable[#optionsTable + 1] = {
        type = "checkbox",
        name = GetString(GD_DEBUG_LOG),
        getFunc = function()
            return self.savedVariables.isDebug
        end,
        setFunc = function(value)
            self.savedVariables.isDebug = value
        end,
        width = "full",
        default = false,
    }

    LibAddonMenu2:RegisterOptionControls(self.displayName, optionsTable)
end




function GuildDonate:Donation(guildId)
    self:Debug("　　[Donation]")

    local guildName = GetGuildName(guildId)
    local deposited = self.savedVariables.depositedList[guildName]
    local payAmount = tonumber(deposited[1])

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MONEY_UPDATE,  function(eventCode, newMoney, oldMoney, reason)

        local goldIcon = zo_iconFormat("EsoUI/Art/currency/currency_gold.dds", 16, 16)
        self:Debug("　　　　EVENT_MONEY_UPDATE", self.checkColor)
        self:Debug("　　　　payAmount=" .. ZO_CurrencyControl_FormatCurrency(payAmount) .. goldIcon)
        self:Debug("　　　　oldMoney=" .. ZO_CurrencyControl_FormatCurrency(oldMoney) .. goldIcon)
        self:Debug("　　　　newMoney=" .. ZO_CurrencyControl_FormatCurrency(newMoney) .. goldIcon)
        self:Debug("　　　　reason=" .. tostring(reason))
        if reason == CURRENCY_CHANGE_REASON_GUILD_BANK_DEPOSIT and (oldMoney - payAmount == newMoney) then

            local msg = GetString(SI_BANK_DEPOSIT) .. " [" .. guildName .. "] x "
                        .. ZO_CurrencyControl_FormatCurrency(payAmount)
                        .. goldIcon
            self:Message(msg)

            local now = os.time()
            deposited[2] = os.date("%Y/%m/%d [%a] %H:%M", now)
            table.insert(self.savedVariables.historyList, zo_strformat("<<1>>,<<2>>,<<3>>", now, guildId, payAmount))
            EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_MONEY_UPDATE)

            if self.history and (not GDHistoryWindow:IsHidden()) then
                self.history:RefreshData()
            end

            if self.savedVariables.auto then
                zo_callLater(function()
                    self:NextBank()
                end, 1000)
            else
                self:Debug("　　no auto")
            end
        end
    end)

    DepositMoneyIntoGuildBank(payAmount)
end




function GuildDonate:Finalize()
    self.selectedGuildId = nil
    self.guildIdList = nil

    KEYBIND_STRIP:RemoveKeybindButton(self.bindButton)
    if self.history then
        self.history:Close()
        ZO_ScrollList_Clear(self.history.list)
    end

end




function GuildDonate:GetBindButtonName()
    return GetString(GD_HISTORY)
end




function GuildDonate:GuildBankReady()

    self:Debug("[GuildBankReady]")
    if Roomba and (not RoombaWindow:IsHidden()) then
        self:Debug("　　Roomba is restacking...")
        zo_callLater(function()
            self:GuildBankReady()
        end, 2000)
        return
    end


    local guildId = GetSelectedGuildBankId()
    if self.selectedGuildId == nil then
        self.selectedGuildId = guildId
        self:Debug("　　SelectedGuild =" .. tostring(self.selectedGuildId) .. ":" .. GetGuildName(self.selectedGuildId))
    end
    self.guildIdList[guildId] = nil


    if self:CanDonate(guildId) then
        zo_callLater(function()
            self:Donation(guildId)
        end, 1000)
        
    elseif self.savedVariables.auto then
        self:NextBank()
    end
end




function GuildDonate:InitializeCommand()

    if GetCVar("language.2") == "en" then
        local defaultLang = self.savedVariables.defaultLanguage
        if defaultLang then
            SLASH_COMMANDS["/lang" .. defaultLang] = function()
                SetCVar("language.2", defaultLang)
            end
        end
    else
        self.savedVariables.defaultLanguage = GetCVar("language.2")
        SLASH_COMMANDS["/langen"] = function()
            SetCVar("language.2", "en")
        end
        SLASH_COMMANDS["/j2e_update"] = function()
            SetCVar("language.2", "en")
        end
    end
    SLASH_COMMANDS["/j2e_reset"] = function()
        self:ResetTable()
    end
end




function GuildDonate:NextBank()
    self:Debug("　　[NextBank]")
    if Roomba and (not RoombaWindow:IsHidden()) then
        self:Debug("　　Roomba is restacking...")
        zo_callLater(function()
            self:NextBank()
        end, 2000)
        return
    end

    for nextGuildId, nextGuildName in pairs(self.guildIdList) do
        self:Debug("　　　　nextGuildId=" .. tostring(nextGuildId), self.checkColor)
        if nextGuildId ~= guildId and self:CanDonate(nextGuildId) then
            self.isSelect = true
            self:Debug("　　Select to " .. nextGuildId .. ":" .. nextGuildName)
            SelectGuildBank(nextGuildId)
            return
        end
    end
    if self.isSelect then
        zo_callLater(function()
            self:Debug("　　[LAST]Select to " .. self.selectedGuildId .. ":" .. GetGuildName(self.selectedGuildId))
            SelectGuildBank(self.selectedGuildId)
        end, 2000)
    end
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_GUILD_BANK_ITEMS_READY)

end




function GuildDonate:OnAddOnLoaded(event, addonName)

    if addonName ~= self.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
    setmetatable(GuildDonate, {__index = LibMarify})


    self.savedVariables = ZO_SavedVars:NewAccountWide("GuildDonateVariables", 2, nil, {})
    if self.savedVariables.depositedList == nil then
        self.savedVariables.depositedList = {}
    end
    if self.savedVariables.historyList == nil then
        self.savedVariables.historyList = {}
    end
    if self.savedVariables.guildIdListForHistory == nil then
        self.savedVariables.guildIdListForHistory = {}
    end
    if self.savedVariables.maxHistory == nil then
        self.savedVariables.maxHistory = 300
    end

    for guildIndex = 1, GetNumGuilds() do
        local guildId = GetGuildId(guildIndex)
        local guildName = GetGuildName(guildId)
        if guildName then
            local deposited = self.savedVariables.depositedList[guildName]
            if deposited == nil then
                self.savedVariables.depositedList[guildName] = {1000, nil, 1}
            else
                deposited[1] = deposited[1] or 1000
                deposited[3] = deposited[3] or 1
            end
        end
    end


    while(#self.savedVariables.historyList > self.savedVariables.maxHistory) do
        table.remove(self.savedVariables.historyList, 1)
    end


    self:SetKeyBindings()
    self:CreateMenu()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_GUILD_BANK,  function(...) self:OpenGuildBank(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_GUILD_BANK, function(...) self:Finalize(...) end)
    --self:PostHook(INVENTORY_MENU_BAR, "OnFragmentShown",              function(...) KEYBIND_STRIP:AddKeybindButton(self.bindButton) end)
    --self:PostHook(INVENTORY_MENU_BAR, "OnFragmentHidden",             function(...) KEYBIND_STRIP:RemoveKeybindButton(self.bindButton) end)

    --EVENT_MANAGER:RegisterForEvent(self.name, EVENT_BANKED_CURRENCY_UPDATE,     function(...) self:DebugIfMarify("EVENT_BANKED_CURRENCY_UPDATE" , self.checkColor) end)
    --EVENT_MANAGER:RegisterForEvent(self.name, EVENT_BANKED_MONEY_UPDATE,        function(...) self:DebugIfMarify("EVENT_BANKED_MONEY_UPDATE" , self.checkColor) end)
    --EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_BANKED_MONEY_UPDATE,  function(...) self:DebugIfMarify("EVENT_GUILD_BANKED_MONEY_UPDATE" , self.checkColor) end)
end




function GuildDonate:OnClickedClose()
    self:Debug("[OnClickedClose]")
    GDListings:SetHidden(true)
end




function GuildDonate:OnMoveListings()
    self:Debug("[OnMoveListings]")
    self.savedVariables.listingsX   = GDListings:GetLeft()
    self.savedVariables.listingsY   = GDListings:GetTop()
end




function GuildDonate:OpenGuildBank()

    self:Debug("[OpenGuildBank]")
    self.isSelect = false
    self.selectedGuildId = nil
    if self.guildIdList == nil then
        self:CreateGuildIdList()
    end


    KEYBIND_STRIP:AddKeybindButton(self.bindButton)


    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_BANK_ITEMS_READY, function(...)
        self:Debug("EVENT_GUILD_BANK_ITEMS_READY", self.checkColor)
        self:GuildBankReady()
    end)
end




function GuildDonate:OpenHistory()

    self:Debug("[OpenHistory]")
    if self.history == nil then
        self.history = GDHistory:New()
    end
    self.history:Open()
end




function GuildDonate:SetKeyBindings()

    ZO_CreateStringId("SI_BINDING_NAME_GD_HISTORY", GetString(GD_HISTORY))
end




EVENT_MANAGER:RegisterForEvent(GuildDonate.name, EVENT_ADD_ON_LOADED, function(...) GuildDonate:OnAddOnLoaded(...) end)

