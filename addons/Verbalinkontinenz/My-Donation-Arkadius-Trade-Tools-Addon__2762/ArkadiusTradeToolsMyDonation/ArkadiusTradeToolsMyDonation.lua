ArkadiusTradeTools.Modules.MyDonation = ArkadiusTradeTools.Templates.Module:New(ArkadiusTradeTools.NAME .. "MyDonation", ArkadiusTradeTools.TITLE .. " - MyDonation", ArkadiusTradeTools.VERSION, ArkadiusTradeTools.AUTHOR)
local ArkadiusTradeToolsMyDonation = ArkadiusTradeTools.Modules.MyDonation
ArkadiusTradeToolsMyDonation.Localization = {}

local attRound = math.attRound
local L = ArkadiusTradeToolsMyDonation.Localization
local Utilities = ArkadiusTradeTools.Utilities
local Settings
local MyDonation

local SECONDS_IN_HOUR = 60 * 60
local SECONDS_IN_DAY = SECONDS_IN_HOUR * 24

-- --------------------------------------------------------
-- -------------------- List functions --------------------
-- --------------------------------------------------------
local ArkadiusTradeToolsMyDonationList = ArkadiusTradeToolsSortFilterList:Subclass()

function ArkadiusTradeToolsMyDonationList:Initialize(control)
    ArkadiusTradeToolsSortFilterList.Initialize(self, control)

    self.SORT_KEYS = {["donorName"]  = {tiebreaker = "timeStamp"},
                      ["guildName"]  = {tiebreaker = "timeStamp"},
                      ["donation"]      = {tiebreaker = "timeStamp"},					
                      ["timeStamp"]  = {}}

    ZO_ScrollList_AddDataType(self.list, 1, "ArkadiusTradeToolsMyDonationRow", 32,
        function(control, data)
            self:SetupMyDonationRow(control, data)
        end
    )

    local function OnHeaderToggle(switch, pressed)
        self[switch:GetParent().key.."Switch"] = pressed
        self:CommitScrollList()
        Settings.filters[switch:GetParent().key] = pressed
		
    end

    local function OnHeaderFilterToggle(switch, pressed)
        self[switch:GetParent().key.."Switch"] = pressed
        self.Filter:SetNeedsRefilter()
        self:RefreshFilters()
        Settings.filters[switch:GetParent().key] = pressed
		
    end

	--- +/- toggle ---
	
    self.donorNameSwitch = Settings.filters.donorName
    self.guildNameSwitch = Settings.filters.guildName
    self.timeStampSwitch = Settings.filters.timeStamp

	self.sortHeaderGroup.headerContainer.sortHeaderGroup = self.sortHeaderGroup
    self.sortHeaderGroup:HeaderForKey("donorName").switch:SetPressed(self.donorNameSwitch)
    self.sortHeaderGroup:HeaderForKey("donorName").switch.tooltip:SetContent(L["ATT_STR_FILTER_COLUMN_TOOLTIP"])
    self.sortHeaderGroup:HeaderForKey("donorName").switch.OnToggle = OnHeaderFilterToggle

    self.sortHeaderGroup:HeaderForKey("guildName").switch:SetPressed(self.guildNameSwitch)
    self.sortHeaderGroup:HeaderForKey("guildName").switch.tooltip:SetContent(L["ATT_STR_FILTER_COLUMN_TOOLTIP"])
    self.sortHeaderGroup:HeaderForKey("guildName").switch.OnToggle = OnHeaderFilterToggle

    self.sortHeaderGroup:HeaderForKey("timeStamp").switch:SetPressed(self.timeStampSwitch)
    self.sortHeaderGroup:HeaderForKey("timeStamp").switch.OnToggle = OnHeaderToggle

    self.sortHeaderGroup:SelectHeaderByKey("timeStamp", true)
    self.sortHeaderGroup:SelectHeaderByKey("timeStamp", true)
    self.currentSortKey = "timeStamp"
	
end

function ArkadiusTradeToolsMyDonationList:SetupFilters()
    local useSubStrings = ArkadiusTradeToolsMyDonation.frame.filterBar.SubStrings:IsPressed()

    local CompareStringsFuncs = {}
    CompareStringsFuncs[true] = function(string1, string2) string2 = string2:gsub("-", "--") return (string.find(string1:lower(), string2) ~= nil) end
    CompareStringsFuncs[false] = function(string1, string2) return (string1:lower() == string2) end
  
	local item = ArkadiusTradeToolsMyDonation.frame.filterBar.Time:GetSelectedItem()
    local newerThanTimeStamp = item.NewerThanTimeStamp()
    local olderThanTimestamp = item.OlderThanTimeStamp()

    local function CompareTimestamp(timeStamp)
        return ((timeStamp >= newerThanTimeStamp) and (timeStamp < olderThanTimestamp))
		
    end

    self.Filter:SetKeywords(ArkadiusTradeToolsMyDonation.frame.filterBar.Text:GetStrings())
    self.Filter:SetKeyFunc(1, "timeStamp", CompareTimestamp)

    if (self["donorNameSwitch"])
        then self.Filter:SetKeyFunc(2, "donorName", CompareStringsFuncs[useSubStrings])
    else
        self.Filter:SetKeyFunc(2, "donorName", nil)
    end

    if (self["guildNameSwitch"])
        then self.Filter:SetKeyFunc(2, "guildName", CompareStringsFuncs[useSubStrings])
    else
        self.Filter:SetKeyFunc(2, "guildName", nil)
    end

end

function ArkadiusTradeToolsMyDonationList:SetupMyDonationRow(rowControl, rowData)
    rowControl.data = rowData
    local data = rowData.rawData
    local donorName = rowControl:GetNamedChild("DonorName")
    local guildName = rowControl:GetNamedChild("GuildName")
    local donation = rowControl:GetNamedChild("Donation")
    local timeStamp = rowControl:GetNamedChild("TimeStamp")
  
    donorName:SetText(data.donorName)
    donorName:SetWidth(donorName.header:GetWidth() - 10)
    donorName:SetHidden(donorName.header:IsHidden())
    donorName:SetColor(ArkadiusTradeTools:GetDisplayNameColor(data.donorName):UnpackRGBA())

    guildName:SetText(data.guildName)
    guildName:SetWidth(guildName.header:GetWidth() - 10)
    guildName:SetHidden(guildName.header:IsHidden())
    guildName:SetColor(ArkadiusTradeTools:GetGuildColor(data.guildName):UnpackRGBA())

    donation:SetText(ArkadiusTradeTools:LocalizeDezimalNumber(data.donation) .. " |t16:16:EsoUI/Art/currency/currency_gold.dds|t")
    donation:SetWidth(donation.header:GetWidth() - 10)
    donation:SetHidden(donation.header:IsHidden())

    if (self.timeStampSwitch) then
        timeStamp:SetText(ArkadiusTradeTools:TimeStampToDateTimeString(data.timeStamp + ArkadiusTradeTools:GetLocalTimeShift()))
    else
        timeStamp:SetText(ArkadiusTradeTools:TimeStampToAgoString(data.timeStamp))
    end

    timeStamp:SetWidth(timeStamp.header:GetWidth() - 10)
    timeStamp:SetHidden(timeStamp.header:IsHidden())
	

    ArkadiusTradeToolsSortFilterList.SetupRow(self, rowControl, rowData)
	
end

---------------------------------------------------------------------------------------

function ArkadiusTradeToolsMyDonation:Initialize()
    self.frame = ArkadiusTradeToolsMyDonationFrame
    ArkadiusTradeTools.TabWindow:AddTab(self.frame, L["ATT_STR_MYDONATION"], "/esoui/art/guild/guild_indexicon_member_up.dds", "/esoui/art/guild/guild_indexicon_member_up.dds", {left = 0.15, top = 0.15, right = 0.85, bottom = 0.85})

    self.list = ArkadiusTradeToolsMyDonationList:New(self, self.frame)
    self.frame.list = self.frame:GetNamedChild("List")
    self.frame.filterBar = self.frame:GetNamedChild("FilterBar")
    self.frame.headers = self.frame:GetNamedChild("Headers")
    self.frame.headers.donorName = self.frame.headers:GetNamedChild("DonorName")
    self.frame.headers.guildName = self.frame.headers:GetNamedChild("GuildName")
    self.frame.headers.donation = self.frame.headers:GetNamedChild("Donation")
    self.frame.headers.timeStamp = self.frame.headers:GetNamedChild("TimeStamp")
    self.frame.OnResize = self.OnResize
    self.frame:SetHandler("OnEffectivelyShown", function(_, hidden) if (hidden == false) then self.list:RefreshData() end end)

    self:LoadSettings()
    self:LoadMyDonation()
     
    --- Setup FilterBar ---
    local function callback(...)
        self.list.Filter:SetNeedsRefilter()
        self.list:RefreshData()
        Settings.filters.timeSelection = self.frame.filterBar.Time:GetSelectedIndex()
		
    end
	
    self.frame.filterBar.Time:AddItem({name = L["ATT_STR_THIS_WEEK"], callback = callback, NewerThanTimeStamp = function() return ArkadiusTradeTools:GetStartOfWeek(0, true) end, OlderThanTimeStamp = function() return GetTimeStamp() end})
    self.frame.filterBar.Time:AddItem({name = L["ATT_STR_LAST_WEEK"], callback = callback, NewerThanTimeStamp = function() return ArkadiusTradeTools:GetStartOfWeek(-1, true) end, OlderThanTimeStamp = function() return ArkadiusTradeTools:GetStartOfWeek(0, true) - 1 end})
    self.frame.filterBar.Time:AddItem({name = L["ATT_STR_PRIOR_WEEK"], callback = callback, NewerThanTimeStamp = function() return ArkadiusTradeTools:GetStartOfWeek(-2, true) end, OlderThanTimeStamp = function() return ArkadiusTradeTools:GetStartOfWeek(-1, true) - 1 end})
    self.frame.filterBar.Time:AddItem({name = L["ATT_STR_7_DAYS"], callback = callback, NewerThanTimeStamp = function() return ArkadiusTradeTools:GetStartOfDay(-7) end, OlderThanTimeStamp = function() return GetTimeStamp() end})
    self.frame.filterBar.Time:AddItem({name = L["ATT_STR_14_DAYS"], callback = callback, NewerThanTimeStamp = function() return ArkadiusTradeTools:GetStartOfDay(-14) end, OlderThanTimeStamp = function() return GetTimeStamp() end})
	self.frame.filterBar.Time:AddItem({name = L["ATT_STR_3_MONTHS"], callback = callback, NewerThanTimeStamp = function() return ArkadiusTradeTools:GetStartOfDay(-92) end, OlderThanTimeStamp = function() return GetTimeStamp() end})
	self.frame.filterBar.Time:AddItem({name = L["ATT_STR_6_MONTHS"], callback = callback, NewerThanTimeStamp = function() return ArkadiusTradeTools:GetStartOfDay(-183) end, OlderThanTimeStamp = function() return GetTimeStamp() end})
	self.frame.filterBar.Time:AddItem({name = L["ATT_STR_365_DAYS"], callback = callback, NewerThanTimeStamp = function() return 0 end, OlderThanTimeStamp = function() return GetTimeStamp() end})
    self.frame.filterBar.Time:SelectByIndex(Settings.filters.timeSelection)
    self.frame.filterBar.Text.OnChanged = function(text) self.list:RefreshFilters() end
    self.frame.filterBar.Text.tooltip:SetContent(L["ATT_STR_FILTER_TEXT_TOOLTIP"])
    self.frame.filterBar.SubStrings.OnToggle = function(switch, pressed) self.list.Filter:SetNeedsRefilter() self.list:RefreshFilters() Settings.filters.useSubStrings = pressed end
    self.frame.filterBar.SubStrings:SetPressed(Settings.filters.useSubStrings)
    self.frame.filterBar.SubStrings.tooltip:SetContent(L["ATT_STR_FILTER_SUBSTRING_TOOLTIP"])
    
end

function ArkadiusTradeToolsMyDonation:Finalize()
    self:CleanupSavedVariables()
    self:SaveSettings()
	
end

function ArkadiusTradeToolsMyDonation:GetSettingsMenu()
    local settingsMenu = {}

    table.insert(settingsMenu, {type = "header", name = L["ATT_STR_MYDONATION"]})
    table.insert(settingsMenu, {type = "slider", name = L["ATT_STR_KEEP_DEPOSIT_FOR_DAYS"], min = 1, max = 365, getFunc = function() return Settings.keepDataDays end, setFunc = function(value) Settings.keepDataDays = value end})
    table.insert(settingsMenu, {type = "custom"})

    return settingsMenu
end

function ArkadiusTradeToolsMyDonation:LoadSettings()
    --- Apply list header visibilites ---
    if (Settings.hiddenHeaders) then
        local headers = self.frame.headers

        for _, headerKey in pairs(Settings.hiddenHeaders) do
            for i = 1, headers:GetNumChildren() do
                local header = headers:GetChild(i)

                if ((header.key) and (header.key == headerKey)) then
                    header:SetHidden(true)

                    break
                end
            end
        end
    end
end

function ArkadiusTradeToolsMyDonation:SaveSettings()
    --- Save list header visibilites ---
    Settings.hiddenHeaders = {}

    if ((self.frame) and (self.frame.headers)) then
        local headers = self.frame.headers

        for i = 1, headers:GetNumChildren() do
            local header = headers:GetChild(i)

            if ((header.key) and (header:IsControlHidden())) then
                table.insert(Settings.hiddenHeaders, header.key)
            end
        end
    end
end

function ArkadiusTradeToolsMyDonation:CleanupSavedVariables()
    local timeStamp = GetTimeStamp() - Settings.keepDataDays * SECONDS_IN_DAY

    --- Delete old Donation ---
    for i, mydonation in pairs(MyDonation) do
        if mydonation.timeStamp <= timeStamp then
            MyDonation[i] = nil
        end
	end
end

function ArkadiusTradeToolsMyDonation:LoadMyDonation()
    for _, mydonation in pairs(MyDonation) do
        ArkadiusTradeToolsMyDonation.list:UpdateMasterList(mydonation)
    end
end

--------------------------------------------------------
------------------- Text --------------------
--------------------------------------------------------

local TransferCurrency_API = TransferCurrency

function TransferCurrency(currencyType, amount, from, to)

if 	(currencyType == CURT_MONEY) and  
	(to == CURRENCY_LOCATION_GUILD_BANK) then

	--- Save donation ---
	
    local mydonation = {}
    mydonation.donation = amount
	mydonation.guildName = GetGuildName(GetSelectedGuildBankId())
	mydonation.donorName = GetDisplayName()
	mydonation.timeStamp = GetTimeStamp()
	
	table.insert(MyDonation, mydonation)

    --- Update list ---
  ArkadiusTradeToolsMyDonation.list:UpdateMasterList(mydonation)
  ArkadiusTradeToolsMyDonation.list:RefreshData()

end

TransferCurrency_API(currencyType, amount, from, to)
	
end

function ArkadiusTradeToolsMyDonation.OnResize(frame, width, height)
    frame.headers:Update()
    ZO_ScrollList_Commit(frame.list)
end

--------------------------------------------------------
------------------- Local functions --------------------
--------------------------------------------------------
local function onAddOnLoaded(eventCode, addonName)
    if (addonName ~= ArkadiusTradeToolsMyDonation.NAME) then
        return
    end

    local serverName = GetWorldName()

    ArkadiusTradeToolsMyDonationData = ArkadiusTradeToolsMyDonationData or {}
    ArkadiusTradeToolsMyDonationData.mydonation = ArkadiusTradeToolsMyDonationData.mydonation or {}
    ArkadiusTradeToolsMyDonationData.mydonation[serverName] = ArkadiusTradeToolsMyDonationData.mydonation[serverName] or {}
    ArkadiusTradeToolsMyDonationData.settings = ArkadiusTradeToolsMyDonationData.settings or {}

    Settings = ArkadiusTradeToolsMyDonationData.settings
    MyDonation = ArkadiusTradeToolsMyDonationData.mydonation[serverName]

    ----------------------------------

    --- Create default settings ---
    Settings.keepDataDays = Settings.keepDataDays or 365
    Settings.filters = Settings.filters or {}
    Settings.filters.timeSelection = Settings.filters.timeSelection or 5
	if (Settings.filters.donorName == nil) then Settings.filters.donorName = true end
    if (Settings.filters.guildName == nil) then Settings.filters.guildName = true end
    if (Settings.filters.timeStamp == nil) then Settings.filters.timeStamp = false end
    if (Settings.filters.donation == nil) then Settings.filters.donation = false end
    if (Settings.filters.useSubStrings == nil) then Settings.filters.useSubStrings = true end

    EVENT_MANAGER:UnregisterForEvent(ArkadiusTradeToolsMyDonation.NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ArkadiusTradeToolsMyDonation.NAME, EVENT_ADD_ON_LOADED, onAddOnLoaded)

