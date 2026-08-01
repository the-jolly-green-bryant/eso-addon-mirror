
DT.UI = {}

DT.UI.FONT_STRING = 'EsoUI/Common/Fonts/ProseAntiquePSMT.otf|%d'
DT.UI.FONT_SIZE = 18

DT.UI.CurWindow = nil
DT.UI.IsAggregateView = false
DT.UI.IsGoldFiltered = true

function DT.UI.OnWindowMoveStop(windowMoved)
    if windowMoved == DTItemWindow then
        DT.Data.WinLeft = DTItemWindow:GetLeft()
        DT.Data.WinTop = DTItemWindow:GetTop()
    elseif windowMoved == DTDonorWindow then
        DT.Data.WinLeft = DTDonorWindow:GetLeft()
        DT.Data.WinTop = DTDonorWindow:GetTop()
    end
end

function DT.UI.RestoreWindowPosition()
    DTItemWindow:ClearAnchors()
    DTItemWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, DT.Data.WinLeft, DT.Data.WinTop)
    
    DTDonorWindow:ClearAnchors()
    DTDonorWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, DT.Data.WinLeft, DT.Data.WinTop)
end

function DT.UI.SwitchToView(window)
    DT.CurWindow:SetHidden(true)
    DT.UI.RestoreWindowPosition()
    DT.CurWindow = window
    DT.CurWindow:SetHidden(false)
    
    if window == DT.UI.ItemScrollList.Window then DT.UI.ItemScrollList:RefreshData() end
    if window == DT.UI.DonorScrollList.Window then DT.UI.DonorScrollList:RefreshData() end
end

function DT.UI.ToggleWindow()
    if DT.CurWindow == nil then DT.CurWindow = DTDonorWindow end
    
    DT.CurWindow:SetHidden(not DT.CurWindow:IsHidden())
end

---- Scroll List
local ScrollList = ZO_SortFilterList:Subclass()

function ScrollList:Initialize(winName, dataRowName, title, columns)
    self.Columns = columns
    self.WindowName = winName
    self.Window = _G[self.WindowName]
    self.WindowTitle = title
    self.cSearch = GetControl(self.Window, "Search")
    
    self:UpdateHeaderNames()
    
	ZO_SortFilterList.InitializeSortFilterList(self, self.Window)
	
 	self.masterList = {}
    self.currentSortOrder = true
	
 	ZO_ScrollList_AddDataType(self.list, 1, dataRowName, 42, function(control, data) self:SetupEntry(control, data) end)
    
    self:RefreshData()
end

function ScrollList:PreSetupEntry(control, data)
    for key, column in pairs(self.Columns) do
        local cElement = GetControl(control, key)
        control["c" .. key] = cElement
        if column.font ~= nil then cElement:SetFont(column.font) end
        cElement:SetMouseEnabled(true)
    end
end

function ScrollList:UpdateHeaderNames()
    local cTitle = GetControl(self.Window, "Title")
    cTitle:SetFont(string.format(DT.UI.FONT_STRING, DT.UI.FONT_SIZE + 8))
    cTitle:SetText(self.WindowTitle)
    
    for key, column in pairs(self.Columns) do
        if column.label ~= nil then
            ZO_SortHeader_Initialize(GetControl(self.Window, "Headers" .. key), column.label, key, ZO_SORT_ORDER_DOWN, column.headerAlign == nil and TEXT_ALIGN_CENTER or column.headerAlign, string.format(DT.UI.FONT_STRING, DT.UI.FONT_SIZE - 5))
        end
    end
end

function ScrollList:SortScrollList(key)
	local scrollData = ZO_ScrollList_GetDataList(self.list)
    local key = (key == nil and self.currentSortKey or key)
    local order = self.currentSortOrder
    
    if key == nil then return end

    function Compare(a, b)
        a = a.data[key]
        b = b.data[key]
        
        if type(a) == "number" and b == nil then b = 0 end
        if type(b) == "number" and a == nil then a = 0 end
        if type(a) == "string" and b == nil then b = "" end
        if type(b) == "string" and a == nil then a = "" end
        
        if (a == nil) or (b == nil) then
            return a ~= nil
        else
            if type(a) == "string" then a = string.lower(a) end
            if type(b) == "string" then b = string.lower(b) end
            if (order == true) then return (a < b) else return (a > b) end
        end
    end
        
	table.sort(scrollData, Compare)
end

function ScrollList:FilterScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)
	
    for i, data in ipairs(self.masterList) do
        if self:IsRowShown(data, self.cSearch:GetText()) then
            table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
        end
	end
		
end

function ScrollList:IsRowShown(data, s)
    return true
end

local function ShowTooltip(control)
    if control.tooltipText == nil or control.tooltipText == "" or control.tooltipType == nil then return end
    InitializeTooltip(control.tooltipType, control, TOPLEFT, -control:GetWidth()/2, 0)
    if control.tooltipType == ItemTooltip then
        control.tooltipType:SetLink(control.tooltipText)
    else
        SetTooltipText(control.tooltipType, control.tooltipText)
    end
end
 
local function HideTooltip(control)
   ClearTooltip(control.tooltipType)
end

function ScrollList:UpdateTooltip(control, infoStr, tooltip)
    tooltip = (tooltip == nil and InformationTooltip or tooltip)
    
    control.tooltipText = infoStr
    control.tooltipType = tooltip
    if control:GetHandler("OnMouseEnter") ~= ShowTooltip then control:SetHandler("OnMouseEnter", ShowTooltip) end
    if control:GetHandler("OnMouseExit") ~= HideTooltip then control:SetHandler("OnMouseExit", HideTooltip) end
end

---- Item List
local ItemScrollList = ScrollList:Subclass()
DT.UI.ItemScrollList = ItemScrollList

function ItemScrollList:Initialize()
    local COLUMNS = {
        Account = {label="Donor", font=string.format(DT.UI.FONT_STRING, DT.UI.FONT_SIZE - 3)},
        Icon = {},
        Count = {font=string.format(DT.UI.FONT_STRING, DT.UI.FONT_SIZE - 4)},
        Link = {label="Item", font=string.format(DT.UI.FONT_STRING, DT.UI.FONT_SIZE - 4) .. '|soft-shadow-thick'},
        Price = {label="Price", font=string.format(DT.UI.FONT_STRING, DT.UI.FONT_SIZE - 3)},
        PriceSource = {label="Price Source", font=string.format(DT.UI.FONT_STRING, DT.UI.FONT_SIZE)},
        Category = {label="Category", font=string.format(DT.UI.FONT_STRING, DT.UI.FONT_SIZE - 3)},
        Multiplier = {label="MUL", font=string.format(DT.UI.FONT_STRING, DT.UI.FONT_SIZE)},
        ReceivedDate = {label="Received", font=string.format(DT.UI.FONT_STRING, DT.UI.FONT_SIZE)},
        DonationSource = {label="SRC", font=string.format(DT.UI.FONT_STRING, DT.UI.FONT_SIZE)}
    }
    self.currentSortKey = "Account"
    ScrollList.Initialize(self, "DTItemWindow", "DTItemDataRow", "Donation Records", COLUMNS)
    
    -- Register complicated cont5rol handlers
    local cRefreshAllBtn = GetControl(self.Window, "RefreshAllButton")
    cRefreshAllBtn:SetHandler("OnMouseUp", function(ctrl, btn)
        if btn == 2 then
            DT.UI.ConfirmDialog("Update ALL Prices", "Are you sure you want to ALL prices?", function()
                DT.RecalcPrices(false)
                DT.SystemPrintf("ALL prices updated with best guesses")
                ItemScrollList:RefreshData()
            end)
        else
            DT.RecalcPrices(true)
            DT.SystemPrintf("Unknown prices updated with best guesses")
            ItemScrollList:RefreshData()
        end
    end)
    self:UpdateTooltip(cRefreshAllBtn, "Left click to refresh all UNKNOWN prices\nRight click to refresh ALL prices")
end

function ItemScrollList:SwitchToAggregateView(isAgg)
    DT.UI.IsAggregateView = isAgg
    self:UpdateHeaderNames()
    self:RefreshData()
end

function ItemScrollList:SwitchGoldFilterOn(isGoldFiltered)
    DT.UI.IsGoldFiltered = isGoldFiltered
    self:UpdateHeaderNames()
    self:RefreshData()
end

function ItemScrollList:UpdateHeaderNames()
    ScrollList.UpdateHeaderNames(self)
    GetControl(self.Window, "AggregateViewOnButton"):SetHidden(DT.UI.IsAggregateView)
    GetControl(self.Window, "AggregateViewOffButton"):SetHidden(not DT.UI.IsAggregateView)
    GetControl(self.Window, "GoldFilterOnButton"):SetHidden(DT.UI.IsGoldFiltered)
    GetControl(self.Window, "GoldFilterOffButton"):SetHidden(not DT.UI.IsGoldFiltered)
end

function ItemScrollList:BuildMasterList()
    self.masterList = {}
    
    if not DT.UI.IsGoldFiltered then
        DT.FillGoldObjMasterList(self.masterList, DT.UI.IsAggregateView)
        for i, goldObj in pairs(self.masterList) do
            goldObj.Link = "GOLD"
            goldObj.Name = "GOLD"
            goldObj.Price = goldObj.Amount
            goldObj.Count = ""
            goldObj.PriceSource = ""
            goldObj.Category = ""
        end
    end
    
    DT.FillItemMasterList(self.masterList, DT.UI.IsAggregateView)
end

function ItemScrollList:IsRowShown(data, s)
    s = string.lower(s)
    return s == "" or string.find(string.lower(data.Account), s, 1, true) ~= nil or string.find(string.lower(data.Name), s, 1, true) ~= nil or string.find(string.lower(data.Category), s, 1, true) ~= nil
end

function ItemScrollList:SetupEntry(control, data)
    self:PreSetupEntry(control, data)
    
    control.cAccount:SetText(data.Account)
    control.cMultiplier:SetText(data.Multiplier ~= nil and string.format("%.2f", data.Multiplier) or "")
    control.cReceivedDate:SetText(data.ReceivedDate)
    control.cCount:SetText(data.Count)
    control.cLink:SetText(data.Link)
    control.cPrice:SetText(DT.FormatMoney(data.Price))
    control.cPriceSource:SetText(data.PriceSource)
    control.cCategory:SetText(data.Category)
    control.cDonationSource:SetText(DT.UI.IsAggregateView and "Multi" or data.DonationSource)
    
    -- Dynamic buttons
    control.cEditButton = GetControl(control, "EditButton")
    control.cEditButton:SetHandler("OnMouseUp", function(ctrl, btn)
        if btn == 2 then
            DT.UpdateItemRow(data, {CustomPrice="?"})
            ItemScrollList:RefreshData()
        else
            DT.UI.EditCashDialog("Set Custom Price", data.PriceSource == "Custom" and data.Price or 0, function(amt)
                DT.UpdateItemRow(data, {CustomPrice=amt})
                ItemScrollList:RefreshData()
            end)
        end
    end)
    self:UpdateTooltip(control.cEditButton, "Left click to set custom price\nRight click to clear price")
   
    control.cRefreshButton = GetControl(control, "RefreshButton")
    control.cRefreshButton:SetHandler("OnClicked", function ()
        DT.UI.ConfirmDialog("Update Price", string.format("Are you sure you want to auto update the price of %s for %s?", data.Link, DT.UI.IsAggregateView and "EVERYONE" or data.Account), function()
            DT.UpdateItemRow(data, {RefreshPrice=true})
            ItemScrollList:RefreshData()
        end)
    end)
   
    control.cDeleteButton = GetControl(control, "DeleteButton")
    control.cDeleteButton:SetHandler("OnClicked", function ()
        DT.UI.ConfirmDialog("Delete Donation Record", string.format("Are you sure you want to delete %s for %s", data.Link, DT.UI.IsAggregateView and "EVERYONE" or data.Account), function()
            DT.UpdateItemRow(data, {Delete=true})
            ItemScrollList:RefreshData()
        end)
    end) 

    local isGoldEntry = (data.Amount ~= nil)
    control.cRefreshButton:SetHidden(isGoldEntry)
    control.cEditButton:SetHidden(isGoldEntry)
    
    -- Give gold entries a special texture
    if not isGoldEntry then
        control.cIcon:SetTexture(GetItemLinkIcon(data.Link))
        self:UpdateTooltip(control.cLink, data.Link, ItemTooltip)
        
    else
        control.cIcon:SetTexture("/esoui/art/bank/bank_tabicon_gold_up.dds")
        self:UpdateTooltip(control.cLink, nil)
    end
    
    -- Columns that need tooltips
    self:UpdateTooltip(control.cCategory, data.Category)
    self:UpdateTooltip(control.cAccount, data.AccountsStr)
    self:UpdateTooltip(control.cDonationSource, data.DonationSource)
    self:UpdateTooltip(control.cReceivedDate, data.ReceivedDate)
    
    --ZO_SortFilterList.SetupRow(self, control, data)
end

-- Donor list
local DonorScrollList = ScrollList:Subclass()
DT.UI.DonorScrollList = DonorScrollList

function DonorScrollList:Initialize()
    local COLUMNS = {
        Account = {label="Donor", headerAlign=TEXT_ALIGN_LEFT, font=string.format(DT.UI.FONT_STRING, DT.UI.FONT_SIZE - 3)},
        MailCash = {label="Mail Cash", headerAlign=TEXT_ALIGN_LEFT, font=string.format(DT.UI.FONT_STRING, DT.UI.FONT_SIZE)},
        MailItemsValue = {label="Mail Items", headerAlign=TEXT_ALIGN_LEFT, font=string.format(DT.UI.FONT_STRING, DT.UI.FONT_SIZE)},
        GBCash = {label="GB Cash", headerAlign=TEXT_ALIGN_LEFT, font=string.format(DT.UI.FONT_STRING, DT.UI.FONT_SIZE)},
        GBItemsValue = {label="GB Items", headerAlign=TEXT_ALIGN_LEFT, font=string.format(DT.UI.FONT_STRING, DT.UI.FONT_SIZE)},
        CustomCash = {label="Custom", headerAlign=TEXT_ALIGN_LEFT, font=string.format(DT.UI.FONT_STRING, DT.UI.FONT_SIZE)},
        Vouchers = {label="Vouchers", headerAlign=TEXT_ALIGN_LEFT, font=string.format(DT.UI.FONT_STRING, DT.UI.FONT_SIZE)},
        ItemCategories = {label="Item Categories", headerAlign=TEXT_ALIGN_CENTER, font=string.format(DT.UI.FONT_STRING, DT.UI.FONT_SIZE - 5)},
        Total = {label="Total", headerAlign=TEXT_ALIGN_LEFT, font=string.format(DT.UI.FONT_STRING, DT.UI.FONT_SIZE)},
        TotalPercent = {label="Total %", headerAlign=TEXT_ALIGN_LEFT, font=string.format(DT.UI.FONT_STRING, DT.UI.FONT_SIZE)}
    }
    self.currentSortKey = "Account"
    ScrollList.Initialize(self, "DTDonorWindow", "DTDonorDataRow", "Donor Summary", COLUMNS)
end

function DonorScrollList:BuildMasterList()
    self.masterList = {}
    DT.FillDonorMasterList(self.masterList)
end

function DonorScrollList:SetupEntry(control, data)
    self:PreSetupEntry(control, data)
    
    control.cAccount:SetText(data.Account)
    control.cMailCash:SetText(DT.FormatMoney(data.MailCash))
    control.cMailItemsValue:SetText(DT.FormatMoney(data.MailItemsValue))
    control.cGBCash:SetText(DT.FormatMoney(data.GBCash))
    control.cGBItemsValue:SetText(DT.FormatMoney(data.GBItemsValue))
    control.cCustomCash:SetText(DT.FormatMoney(data.CustomCash))
    control.cVouchers:SetText(data.Vouchers)
    control.cItemCategories:SetText(data.ItemCategories)
    control.cTotal:SetText(DT.FormatMoney(data.Total))
    control.cTotalPercent:SetText(string.format("%2.2f", data.TotalPercent) .. "%")
    
    self:UpdateTooltip(control.cItemCategories, data.ItemCategories)
    
    control.cEditButton = GetControl(control, "EditButton")
    control.cEditButton:SetHandler("OnClicked", function()
        DT.UI.EditNoteDialog("Add donor note", data.CustomNote, function(txt)
            DT.UpdateDonorRow(data, {CustomNote=txt})
            DonorScrollList:RefreshData()
        end)
    end)
    self:UpdateTooltip(control.cEditButton, data.CustomNote)
    
    control.cCustomGoldButton = GetControl(control, "CustomGoldButton")
    control.cCustomGoldButton:SetHandler("OnClicked", function()
        DT.UI.EditCashDialog("Set Custom Gold", data.CustomCash, function(amt)
            DT.UpdateDonorRow(data, {CustomCash=tonumber(amt)})
            DonorScrollList:RefreshData()
        end)
    end)
    
    --ZO_SortFilterList.SetupRow(self, control, data)
end



function DonorScrollList:IsRowShown(data, s)
    return s == "" or string.find(string.lower(data.Account), string.lower(s), 1, true) ~= nil
end

function DT.UI.InitializeWindow()

    DT.UI.RestoreWindowPosition()
    
    ItemScrollList:Initialize()
    DonorScrollList:Initialize()

end

function DT.UI.KBStripNameUpdate()
    DT.UI.KBDescTrack.name = (DT.Data.IsMailAutoTrack and "Untrack" or "Track" )
    DT.UI.KBDescAccept.name = ((not DT.IsCurMailForwarded and DT.Data.IsForwarder) and "Forward Data" or "Accept Data")
    KEYBIND_STRIP:UpdateKeybindButtonGroup(MAIL_INBOX.selectionKeybindStripDescriptor)
end

function DT.UI.OnPressIgnore(pressed)
    DT.IsTrackPressed = pressed
    KEYBIND_STRIP:UpdateKeybindButtonGroup(MAIL_INBOX.selectionKeybindStripDescriptor)
end

function DT.UI.OnPressAccept()
    if DT.IsCurMailForwarded then
        DT.RetriveMailReport()
    elseif DT.UI.KBDescAccept.visible() then
        DT.InsertMailReport()
    end
end

function DT.UI.EditCashDialog(title, default, cb)
    DT.UI.EditNoteDialog(title .. "(# ONLY PLEASE, NO COMMAS)", string.format("%d", default), function(txt) cb(tonumber(txt)) end)
end

function DT.UI.EditNoteDialog(title, note, cb)
    title = (title == nil and "Edit Custom Note" or title)
    note = (note == nil and "" or note)
    ZO_Dialogs_ShowDialog("EDIT_NOTE", {displayName=title, note=note, changedCallback=function(ctrl, txt) cb(txt) end})
end

-- Function DT.UI.ConfirmDialog is taken from MM. See MM_license
function DT.UI.ConfirmDialog(titleStr, mainStr, cb)
    local diagName = "DonationTrackerResetDiag"
    ZO_Dialogs_RegisterCustomDialog(diagName, {
        title = { text = titleStr},
        mainText = { text = mainStr},
        buttons = {
          {
            text = SI_DIALOG_ACCEPT,
            callback = cb
          },
          { text = SI_DIALOG_CANCEL }
        }
    })
    ZO_Dialogs_ShowDialog(diagName)
end

function DT.UI.Initialize()
    
    function CreateDiagWrapper(cb)
        return function() DT.UI.ConfirmDialog("Update Prices", "Warning: This will update your recorded item value and may change your total donation value!", cb) end
    end
    
    function RegisterKeybinds()
        -- Insert a non standard keybind
        DT.UI.KBDescTrack = {
            name = "",
            keybind = "DT_TRACK",
            visible = function() return (DT.IsCurMailWithAttachments and DT.IsCurMailFromUser) and not DT.IsTrackPressed end
        }
        DT.UI.KBDescAccept = {
            name = "",
            keybind = "DT_ACCEPT",
            visible = function() return DT.IsCurMailForwarded or (DT.Data.IsForwarder and DT.IsCurMailWithAttachments and DT.IsCurMailFromUser) end
        }
        table.insert(MAIL_INBOX.selectionKeybindStripDescriptor, DT.UI.KBDescTrack)
        table.insert(MAIL_INBOX.selectionKeybindStripDescriptor, DT.UI.KBDescAccept)
        
        DT.UI.KBStripNameUpdate()
        
        ZO_CreateStringId("SI_BINDING_NAME_DT_TOGGLE", "Donation Tracker Window")
        ZO_CreateStringId("SI_BINDING_NAME_DT_TRACK", "Track/Untrack Mail Key")
        ZO_CreateStringId("SI_BINDING_NAME_DT_ACCEPT", "Accept/Forward Data Key")
    end

    function CreateSettingsDialog()
        local LAM = LibStub("LibAddonMenu-2.0")
        local panelData = {
            type = "panel",
            name = "Donation Tracker",
            author = "@Libum",
            version = DT.VERSION,
            registerForRefresh = true,
            registerForDefaults = true
        }
        local panel = LAM:RegisterAddonPanel("DonationTrackerOptions", panelData)
        
        -- Mail handling
        local optionsData = {}
        optionsData[#optionsData + 1] = {
            type = "header",
            name = DT.FormatColorText("General", "908a89"),
            width = "full"
        }
        optionsData[#optionsData + 1] = {
                type = "checkbox",
                name = "Auto mail tracking",
                default = DT.DATA_DEFAULTS.IsMailAutoTrack,
                getFunc = function()
                    return DT.Data.IsMailAutoTrack
                end,
                setFunc = function(value)
                    DT.Data.IsMailAutoTrack = value
                    DT.UI.KBStripNameUpdate()
                end
        }
        optionsData[#optionsData + 1] = {
                type = "checkbox",
                name = "Forwarder Mode",
                default = DT.DATA_DEFAULTS.IsForwarder,
                getFunc = function()
                    return DT.Data.IsForwarder
                end,
                setFunc = function(value)
                    DT.Data.IsForwarder = value
                    DT.UI.KBStripNameUpdate()
                end
        }
        optionsData[#optionsData + 1]  = {
            type = "editbox",
            name = "Forwarder Target",
            default = DT.DATA_DEFAULTS.ForwarderTarget,
            getFunc = function()
                return DT.Data.ForwarderTarget
            end,
            setFunc = function(text)
                DT.Data.ForwarderTarget = text
            end,
            disabled = function() return not DT.Data.IsForwarder end,
            isMultiline = false,
            width = "full"
        }
        
        local GuildOpts = {"[None]"}
        for i=1, GetNumGuilds() do
            table.insert(GuildOpts, string.format("%d - %s", i, GetGuildName(GetGuildId(i))))
        end
        
        optionsData[#optionsData + 1] = {
                type = "dropdown",
                name = "Track Guild Bank",
                default = "[None]",
                choices = GuildOpts,
                getFunc = (function()
                    return function()
                        if DT.Data.GuildIndex ~= nil then
                            return string.format("%d - %s", DT.Data.GuildIndex, GetGuildName(GetGuildId(DT.Data.GuildIndex)))
                        else
                            return "[None]"
                        end
                    end
                end)(),
                setFunc = (function()
                    return function(opt)
                        DT.Data.GuildIndex = tonumber(string.match(opt, "%d"))
                    end
                end)(),
                width = "full",
        }

        -- Voucher Counter
        optionsData[#optionsData + 1] = {
            type = "header",
            name = DT.FormatColorText("Master Writ Voucher Counter", "908a89"),
            width = "full"
        }
        optionsData[#optionsData + 1] = {
                type = "checkbox",
                name = "Exclude Jewelry Writs",
                default = DT.DATA_DEFAULTS.IsIgnoreJewelryWrits,
                getFunc = function()
                    return DT.Data.VoucherCounter.IsIgnoreJewelryWrits
                end,
                setFunc = function(value)
                    DT.Data.VoucherCounter.IsIgnoreJewelryWrits = value
                end
        }
        
        -- Multipliers
        optionsData[#optionsData + 1] = {
            type = "header",
            name = DT.FormatColorText("Item Price Multiplier", "908a89"),
            width = "full"
        }
        

        optionsData[#optionsData + 1] = {
            type = "submenu",
            name = "Multiplier %",
            controls = {}
        }
        local sliderTypes = {
            {"EquipMatsMul", DT.CATEGORY_DESC["EquipMats"]},
            {"JCMatsMul", DT.CATEGORY_DESC["JCMats"]},
            {"ConsumMatsMul", DT.CATEGORY_DESC["ConsumMats"]},
            {"AlchemyMatsMul", DT.CATEGORY_DESC["AlchemyMats"]},
            {"FurnishMatsMul", DT.CATEGORY_DESC["FurnishMats"]},
            {"WritsMul", DT.CATEGORY_DESC["Writs"]},
            {"JCWritsMul", DT.CATEGORY_DESC["JCWrits"]},
            {"ClothierIntricatesMul", DT.CATEGORY_DESC["ClothierIntricates"]},
            {"BSIntricatesMul", DT.CATEGORY_DESC["BSIntricates"]},
            {"WWIntricatesMul", DT.CATEGORY_DESC["WWIntricates"]},
            {"JCIntricatesMul", DT.CATEGORY_DESC["JCIntricates"]},
            {"GearMul", DT.CATEGORY_DESC["Gear"]},
            {"MiscMul", DT.CATEGORY_DESC["Misc"]}
        }
        for _, p  in pairs(sliderTypes) do
            local sliderKey, lbl = p[1], p[2]
            table.insert(optionsData[#optionsData].controls, {
                type = "slider",
                name = lbl,
                default = DT.DATA_DEFAULTS[sliderKey] * 100,
                min = 0,
                max = 200,
                getFunc = (function(sliderKey)
                    return function()
                        return math.floor(DT.Data[sliderKey]*100+0.5)
                    end
                end)(sliderKey),
                setFunc = (function(sliderKey)
                    return function(value)
                        DT.Data[sliderKey] = value / 100
                    end
                end)(sliderKey)
            })
        end
        table.insert(optionsData[#optionsData].controls, {
            type = "button",
            name = "Update Multipliers",
            width="half",
            func = CreateDiagWrapper(DT.RecalcMultipliers)
        })
        
        -- Price guesser
        optionsData[#optionsData + 1] = {
            type = "header",
            name = DT.FormatColorText("Pricing Methods", "908a89"),
            width = "full"
        }
        
        local PriceMethods = DT.Clone(DT.DATA_DEFAULTS.PricingOrder)
        table.insert(PriceMethods, "[None]")
        
        for i=1,#PriceMethods - 1 do
            table.insert(optionsData, {
                type = "dropdown",
                name = "#"..i,
                default = DT.DATA_DEFAULTS.PricingOrder[i],
                choices = PriceMethods,
                getFunc = (function()
                    return function()
                        return DT.Data.PricingOrder[i]
                    end
                end)(),
                setFunc = (function()
                    return function(opt)
                        DT.Data.PricingOrder[i] = opt
                    end
                end)(),
                width = "full",
            })
        end

        optionsData[#optionsData + 1] = {
            type = "submenu",
            name = "MM/TTC Price",
            controls = {
                --[[
                {
                    type = "slider",
                    name = "Min Data Points",
                    default = DT.DATA_DEFAULTS,
                    min = 0,
                    max = 100,
                    getFunc = function()
                        return DT.Data.MMTTC.MinDataPoints
                    end,
                    setFunc = function(value)
                        DT.Data.MMTTC.MinDataPoints = value
                    end
                },
                --]]
                {
                    type = "button",
                    name = "Update Prices",
                    width = "half",
                    func = CreateDiagWrapper(DT.RecalcMMTTC)
                }
            }
        }
        
        optionsData[#optionsData + 1] = {
            type = "submenu",
            name = "Writ Formula",
            controls = {
                {
                    type = "checkbox",
                    name = "Ignore Writ Mats Cost",
                    default = DT.DATA_DEFAULTS.WritFormula.IsIgnoreMatsCost,
                    getFunc = function()
                        return DT.Data.WritFormula.IsIgnoreMatsCost
                    end,
                    setFunc = function(value)
                        DT.Data.WritFormula.IsIgnoreMatsCost = value
                    end
                },
                {
                    type = "slider",
                    name = "Writ Voucher Base Value",
                    default = DT.DATA_DEFAULTS.WritFormula.VoucherBaseValue,
                    min = 0,
                    max = 2000,
                    getFunc = function()
                        return DT.Data.WritFormula.VoucherBaseValue
                    end,
                    setFunc = function(value)
                        DT.Data.WritFormula.VoucherBaseValue = value
                    end
                },
                {
                    type = "slider",
                    name = "JC Writ Voucher Base Value",
                    default = DT.DATA_DEFAULTS.WritFormula.JCVoucherBaseValue,
                    min = 0,
                    max = 2000,
                    getFunc = function()
                        return DT.Data.WritFormula.JCVoucherBaseValue
                    end,
                    setFunc = function(value)
                        DT.Data.WritFormula.JCVoucherBaseValue = value
                    end
                },
                {
                    type = "button",
                    name = "Update Prices",
                    width="half",
                    func = CreateDiagWrapper(function() DT.RecalcPriceSource("WritFormula", DT.PriceWritFormula) end)
                }
            }
        }
        
        optionsData[#optionsData + 1] = {
            type = "submenu",
            name = "Gear For Decon",
            controls = {
                {
                    type = "checkbox",
                    name = "Skip Jewelry",
                    default = DT.DATA_DEFAULTS.GearForDecon.IsIgnoreJewelry,
                    getFunc = function()
                        return DT.Data.GearForDecon.IsIgnoreJewelry
                    end,
                    setFunc = function(value)
                        DT.Data.GearForDecon.IsIgnoreJewelry = value
                    end
                },
                {
                    type = "slider",
                    name = DT.FormatColorText("Intricates", "83a8e2"),
                    default = DT.DATA_DEFAULTS.GearForDecon.IntricateValue,
                    min = 0,
                    max = 2000,
                    getFunc = function()
                        return DT.Data.GearForDecon.IntricateValue
                    end,
                    setFunc = function(value)
                        DT.Data.GearForDecon.IntricateValue = value
                    end
                },
                {
                    type = "slider",
                    name = DT.FormatColorText("JC Intricates", "83a8e2"),
                    default = DT.DATA_DEFAULTS.GearForDecon.JCIntricateValue,
                    min = 0,
                    max = 2000,
                    getFunc = function()
                        return DT.Data.GearForDecon.JCIntricateValue
                    end,
                    setFunc = function(value)
                        DT.Data.GearForDecon.JCIntricateValue = value
                    end
                },
                {
                    type = "slider",
                    name = DT.FormatColorText("Normal", DT.QUALITY_COLORS.NORMAL),
                    default = DT.DATA_DEFAULTS.GearForDecon.NormalValue,
                    min = 0,
                    max = 2000,
                    getFunc = function()
                        return DT.Data.GearForDecon.NormalValue
                    end,
                    setFunc = function(value)
                        DT.Data.GearForDecon.NormalValue = value
                    end
                },
                {
                    type = "slider",
                    name = DT.FormatColorText("Fine", DT.QUALITY_COLORS.FINE),
                    default = DT.DATA_DEFAULTS.GearForDecon.FineValue,
                    min = 0,
                    max = 2000,
                    getFunc = function()
                        return DT.Data.GearForDecon.FineValue
                    end,
                    setFunc = function(value)
                        DT.Data.GearForDecon.FineValue = value
                    end
                },
                {
                    type = "slider",
                    name = DT.FormatColorText("Superior", DT.QUALITY_COLORS.SUPERIOR),
                    default = DT.DATA_DEFAULTS.GearForDecon.SuperiorValue,
                    min = 0,
                    max = 2000,
                    getFunc = function()
                        return DT.Data.GearForDecon.SuperiorValue
                    end,
                    setFunc = function(value)
                        DT.Data.GearForDecon.SuperiorValue = value
                    end
                },
                {
                    type = "slider",
                    name = DT.FormatColorText("Epic", DT.QUALITY_COLORS.EPIC),
                    default = DT.DATA_DEFAULTS.GearForDecon.EpicValue,
                    min = 0,
                    max = 2000,
                    getFunc = function()
                        return DT.Data.GearForDecon.EpicValue
                    end,
                    setFunc = function(value)
                        DT.Data.GearForDecon.EpicValue = value
                    end
                },
                {
                    type = "slider",
                    name = DT.FormatColorText("Legendary", DT.QUALITY_COLORS.LEGENDARY),
                    default = DT.DATA_DEFAULTS.GearForDecon.LegendaryValue,
                    min = 0,
                    max = 2000,
                    getFunc = function()
                        return DT.Data.GearForDecon.LegendaryValue
                    end,
                    setFunc = function(value)
                        DT.Data.GearForDecon.LegendaryValue = value
                    end
                },
                {
                    type = "button",
                    name = "Update Prices",
                    width="half",
                    func = CreateDiagWrapper(function() DT.RecalcPriceSource("GearForDecon", DT.PriceGearForDecon) end)
                }
            }
        }
        LAM:RegisterOptionControls("DonationTrackerOptions", optionsData)
    end
    
    RegisterKeybinds()
        
    CreateSettingsDialog()
        
    DT.UI.InitializeWindow()
    
    --[[
    ZO_Dialogs_RegisterCustomDialog("DTEditGold", {
        customControl = DTCurrencyDialog,
        setup = function(dialog, data) return end,
        title = { text = "Set Gold Amount" },
        buttons = {
            [1] =
            {
                control =   GetControl(DTCurrencyDialog, "Save"),
                text =      SI_SAVE,
                callback =  function(dialog)
                                local data = dialog.data
                                data.changedCallback(amount)
                            end,
            },
        
            [2] =
            {
                control =   GetControl(DTCurrencyDialog, "Cancel"),
                text =      SI_DIALOG_CANCEL,
            }
        }
    })
    --]]
end
