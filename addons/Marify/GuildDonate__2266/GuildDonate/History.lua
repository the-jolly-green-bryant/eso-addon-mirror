-- 
-- see : esoui/libraries/zo_templates/scrolltemplates.lua
--       esoui/libraries/zo_templates/scrolltemplates.xml
-- 
-- base: esoui/libraries/zo_sortfilterlist/zo_sortfilterlist.lua
--       esoui/libraries/zo_sortfilterlist/zo_sortfilterlist.xml
-- 
GDHistory = ZO_SortFilterList:Subclass()

GDHistory.SORT_DATE_DOWN = 1
GDHistory.SORT_DATE_UP = 2
GDHistory.SORT_NAME_DOWN = 3
GDHistory.SORT_NAME_UP = 4
GDHistory.SORT_KEYS = {
    ["date"]  = {},
    ["name"]  = {tiebreaker="date"},
}




function GDHistory:BuildMasterList()
    GuildDonate:Debug("　　　　[BuildMasterList]")

    if GuildDonate.guildIdList == nil then
        GuildDonate:CreateGuildIdList()
    end

    ZO_ScrollList_Clear(self.list)
    self.masterList = {}
    local goldIcon = zo_iconFormat("EsoUI/Art/currency/currency_gold.dds", 16, 16)
    local time, guildId, amount
    local dataList = {}
    for _, history in pairs(GuildDonate.savedVariables.historyList) do
        time, guildId, amount = zo_strsplit(",", history)
        guildId = tonumber(guildId)
        amount  = tonumber(amount)
        data = {}
        data.time     = time
        data.date     = os.date("%Y/%m/%d [%a] %H:%M.%S", time)
        data.id       = guildId
        data.name     = GuildDonate.savedVariables.guildIdListForHistory[guildId]
        data.amount   = ZO_CurrencyControl_FormatCurrency(amount) .. " " .. goldIcon
        table.insert(self.masterList, data)
    end
end




function GDHistory:Close()
    GuildDonate:Debug("[Close]")
    GDHistoryWindow:SetHidden(true)
end




function GDHistory:FilterScrollList()
    GuildDonate:Debug("　　　　[FilterScrollList]")
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    local data
    for i = 1, #self.masterList do
        data = self.masterList[i]
        table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
    end
end




function GDHistory:Initialize(control)
    GuildDonate:Debug("　　[Initialize]")

    ZO_SortFilterList.Initialize(self, control)

    self.sortHeaderGroup:SelectHeaderByKey("date")
    ZO_SortHeader_OnMouseExit(GDHistoryWindowHeadersDate)

    self.masterList = {}
    ZO_ScrollList_AddDataType(self.list,
                              1,                                                        -- @typeId               - A unique identifier to give to CreateDataEntry when you want to add an element of this type.
                              "GDHistoryRowTemplate",                                   -- @templateName         - The name of the virtual control template that will be used to hold this data
                              22,                                                       -- @height               - The control height
                              function(control, data) self:SetupRow(control, data) end, -- @setupCallback        - The function that will be called when a control of this type becomes visible.
                                                                                        --                         Signature: setupCallback(control, data)
                              nil,                                                      -- @dataTypeSelectSound  - An optional sound to play when a row of this data type is selected.
                              nil)                                                      -- @resetControlCallback - An optional callback when the datatype control gets reset.
    ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")


    self.sortFunction = function(listEntry1, listEntry2)
        return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, self.SORT_KEYS, self.currentSortOrder)
        end


    GDHistoryWindowTitle:SetText(GetString(GD_HISTORY))
    GDHistoryWindowHeadersDateName:SetText(GetString(GD_DATE))
    GDHistoryWindowHeadersNameName:SetText(GetString(SI_GUILDMETADATAATTRIBUTE1))

    if GuildDonate.savedVariables.historyWindowX and GuildDonate.savedVariables.historyWindowY then
        control:ClearAnchors()
        control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GuildDonate.savedVariables.historyWindowX,
                                                     GuildDonate.savedVariables.historyWindowY)
    end

end




function GDHistory:MoveStop()
    GuildDonate:Debug("[MoveStop]")
    GuildDonate.savedVariables.historyWindowX  = GDHistoryWindow:GetLeft()
    GuildDonate.savedVariables.historyWindowY  = GDHistoryWindow:GetTop()
end




function GDHistory:New()
    GuildDonate:Debug("[New]")
    local units = ZO_SortFilterList.New(self, GDHistoryWindow)
    return units
end




function GDHistory:Open()
    GuildDonate:Debug("[Open]")
    if GDHistoryWindow:IsHidden() then
        self:RefreshData()
        GDHistoryWindow:SetHidden(false)
    else
        GDHistoryWindow:SetHidden(true)
    end
end




function GDHistory:SetupRow(control, data)
    GuildDonate:Debug("　　　　[SetupRow]")

    control.data = data

    control.date = GetControl(control, "RowDate")
    control.date:SetText(data.date)
    control.date.normalColor = ZO_DEFAULT_ENABLED_COLOR

    control.name = GetControl(control, "RowName")
    control.name:SetText(data.name)
    control.name.normalColor = ZO_DEFAULT_ENABLED_COLOR

    control.amount = GetControl(control, "RowAmount")
    control.amount:SetText(data.amount)
    control.amount.normalColor = ZO_DEFAULT_ENABLED_COLOR

    ZO_SortFilterList.SetupRow(self, control, data)
end




function GDHistory:SortScrollList()
    GuildDonate:Debug("　　　　[SortScrollList]")
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    table.sort(scrollData, self.sortFunction)
end




