local logger
local function GetUnknownMotifLink(parser)
    local LCK = LibCharacterKnowledge
    if not LCK then
        return nil
    end
    local motif = parser.motif_num
    local recipe = parser.recipe
    if not motif and recipe then
        if recipe.is_known then
            return nil
        end
        return recipe.recipe_link
    end
    if not parser.motif_num then
        return nil
    end
    local chapter = parser.request_item.motif_page or ITEM_STYLE_CHAPTER_ALL
    local is_unknown = LCK.GetMotifKnowledgeForCharacter(motif, chapter) == LCK.KNOWLEDGE_UNKNOWN
    if not is_unknown then
        return nil
    end

    local LCKI = LibCharacterKnowledgeInternal
    local id = LCKI.TranslateItem({ styleId = motif, chapterId = chapter })
    local link = LCKI.GetItemLink(id, LINK_STYLE_BRACKETS)
    return link
end

local function GetMotifInfo(motif_link)
    local string_list = {}
    local curr_fmt = function(value)
        return ZO_Currency_FormatPlatform(CURT_MONEY, value, ZO_CURRENCY_FORMAT_AMOUNT_ICON, nil)
    end

    table.insert(string_list, motif_link)
    if LibPrice then
        local priceData = LibPrice.ItemLinkToPriceData(motif_link)
        local TTC = TamrielTradeCentre
        local ttc = priceData.ttc
        if ttc and TTC then
            if ttc.SuggestedPrice ~= nil then
                table.insert(string_list,
                        string.format("TTC %s: %s",
                                GetString(TTC_SETTING_INCLUDESUGGESTEDPRICE),
                        --TTC:FormatNumber(ttc.SuggestedPrice)
                                curr_fmt(ttc.SuggestedPrice)
                        )
                )
            end
            table.insert(string_list,
                    string.format("TTC " .. GetString(TTC_PRICE_AGGREGATEPRICESXYZ) .. " %s",
                            TTC:FormatNumber(ttc.Avg),
                            TTC:FormatNumber(ttc.Min),
                            TTC:FormatNumber(ttc.Max),
                            ZO_Currency_GetPlatformFormattedCurrencyIcon(CURT_MONEY, false, true)
                    )
            )
        end

        local mm = priceData.mm
        if mm and mm.avgPrice > 0 then
            table.insert(string_list, string.format("MM Avg: %s", curr_fmt(mm.avgPrice)))
        end

        local att = priceData.att
        if att and att.avgPrice > 0 then
            table.insert(string_list, string.format("ATT Avg: %s", curr_fmt(att.avgPrice)))
        end

    end
    local result = table.concat(string_list, "\n")
    return result
end

local function GetOrCreateTooltipControlForMotifInfo(control)
    local parent_name = control:GetName()
    local motif_label_name = parent_name .. "WritWorthyMotifTooltip"
    local motif_label = WINDOW_MANAGER:GetControlByName(motif_label_name)
    if motif_label == nil then
        logger:Debug("Create " .. motif_label_name)
        --motif_label = CreateControlFromVirtual(motif_label_name, control, "ZO_InventorySlot")
        motif_label = CreateControl(motif_label_name, control, CT_LABEL)
        motif_label:SetFont("ZoFontGame")
        motif_label:SetMouseEnabled(true)
        motif_label:SetHandler('OnMouseEnter', function(self)
            self.tooltip = ItemTooltip
            InitializeTooltip(self.tooltip)
            self.tooltip:SetLink(self.data.link)
            if self.data.link then
                if TamrielTradeCentre and TamrielTradeCentrePrice then
                    TamrielTradeCentrePrice:AppendPriceInfo(self.tooltip, self.data.link)
                end
                --Integrate MM graphs
                if MasterMerchant and MasterMerchant.isInitialized then
                    MasterMerchant:addStatsAndGraph(self.tooltip, self.data.link)
                end
            end
            self.tooltip:SetHidden(false)
        end)
        motif_label:SetHandler('OnMouseExit', function(self)
            if self.tooltip then
                ClearTooltip(self.tooltip)
                self.tooltip:SetHidden(true)
                self.tooltip = nil
            end
        end)
        motif_label:SetHandler('OnMouseDown', function(self, button)
            if button == MOUSE_BUTTON_INDEX_RIGHT then
                zo_callLater(function()

                    --local chat = CHAT_SYSTEM.textEntry:GetText()
                    --StartChatInput(chat .. self.data.link)
                    ClearMenu()
                    if TamrielTradeCentre then
                        local itemInfo = TamrielTradeCentre_ItemInfo:New(self.data.link)
                        AddCustomMenuItem(
                                TamrielTradeCentre:GetString("TTC_PRICE_PRICETOCHAT", TamrielTradeCentreLangEnum.Default),
                                function()
                                    TamrielTradeCentrePrice:PriceInfoToChat(itemInfo, langEnum)
                                end
                        )
                        if itemInfo.ID ~= nil then
                            AddCustomMenuItem(GetString(TTC_SEARCHONLINE),
                                    function()
                                        TamrielTradeCentrePrice:SearchOnline(itemInfo)
                                    end
                            )
                            AddCustomMenuItem(GetString(TTC_PRICEHISTORYONLINE),
                                    function()
                                        TamrielTradeCentrePrice:PriceDetailOnline(itemInfo)
                                    end
                            )
                        end
                    end

                    if MasterMerchant then
                        AddCustomMenuItem(GetString(MM_STATS_TO_CHAT), function()
                            MasterMerchant:OnItemLinkAction(self.data.link)
                        end)
                    end

                    if ArkadiusTradeTools then
                        local ArkadiusTradeToolsSales = ArkadiusTradeTools.Modules.Sales
                        local L = ArkadiusTradeToolsSales.Localization
                        AddCustomMenuItem(L["ATT_STR_STATS_TO_CHAT"], function()
                            ArkadiusTradeToolsSales:StatsToChat(self.data.link)
                        end)
                    end

                    AddCustomMenuItem(GetString(SI_ITEM_ACTION_LINK_TO_CHAT), function()
                        ZO_LinkHandler_InsertLink(zo_strformat(SI_TOOLTIP_ITEM_NAME, self.data.link))
                    end)
                    ShowMenu(self)
                end, 0)
            end
        end)
    end
    control:AddControl(motif_label)
    motif_label:SetAnchor(CENTER)
    return motif_label
end

local function HookWritWorthy()
    logger:Debug("HookWritWorthy")
    local orig_TooltipInsertOurText = WritWorthy.TooltipInsertOurText
    local orig_ToMatKnowList = WritWorthy.ToMatKnowList
    local last_parser
    local ToMatKnowList = function(item_link)
        logger:Debug("ToMatKnowList")
        local result = { orig_ToMatKnowList(item_link) }
        last_parser = result[3]
        return unpack(result)
    end

    WritWorthy["ToMatKnowList"] = ToMatKnowList

    local TooltipInsertOurText = function(control, item_link, purchase_gold, unique_id, style)
        logger:Debug("TooltipInsertOurText")
        --orig_TooltipInsertOurText(control, item_link, purchase_gold, unique_id, style)
        local motif_label = GetOrCreateTooltipControlForMotifInfo(control)
        motif_label:SetHidden(true)
        if last_parser then
            local motif_link = GetUnknownMotifLink(last_parser)
            if motif_link then
                motif_label.data = { link = motif_link }
                local motif_text = GetMotifInfo(motif_link)
                motif_label:SetText(motif_text)
                --motif_label.itemLink = motif_link
                motif_label:SetHidden(false)
            end
			last_parser = nil
        end
    end
    SecurePostHook(WritWorthy, "TooltipInsertOurText", TooltipInsertOurText)
end

local function Start(addonName)
    if LibDebugLogger then
        logger = LibDebugLogger(addonName)
        else
        logger = {}
        logger.Debug = function()

        end
    end
    -- On load
    logger:Debug("Start")
    local function OnLoaded(_, loadedAddonName)
        if (addonName == loadedAddonName) then
            logger:Debug("OnLoaded")
            HookWritWorthy()
            EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
        end
    end
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, OnLoaded)
end

Start("RecipePriceForWritWorthy")