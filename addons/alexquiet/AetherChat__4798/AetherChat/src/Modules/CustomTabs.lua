-- ============================================================================
-- AetherChat : Custom Chat Tabs & Filtering Engine (Official ZOS Architecture)
-- ============================================================================
AetherChat = AetherChat or {}
local AetherChat = AetherChat

AetherChat.CustomTabs = {}
local CustomTabs = AetherChat.CustomTabs

local FILTER_KEYS = {
    -- Column 1
    say       = 'FiltSay',
    whisper   = 'FiltWhisper',
    emote     = 'FiltEmote',
    zone      = 'FiltZone',
    zone_fr   = 'FiltZoneFR',
    zone_jp   = 'FiltZoneJP',
    zone_es   = 'FiltZoneES',
    -- Column 2
    yell      = 'FiltYell',
    party     = 'FiltParty',
    npc       = 'FiltNPC',
    zone_en   = 'FiltZoneEN',
    zone_de   = 'FiltZoneDE',
    zone_ru   = 'FiltZoneRU',
    zone_zh   = 'FiltZoneZH',
    -- Guilds Left Column
    guild1    = 'FiltGuild1',
    officer1  = 'FiltOfficer1',
    guild3    = 'FiltGuild3',
    officer3  = 'FiltOfficer3',
    guild5    = 'FiltGuild5',
    officer5  = 'FiltOfficer5',
    -- Guilds Right Column
    guild2    = 'FiltGuild2',
    officer2  = 'FiltOfficer2',
    guild4    = 'FiltGuild4',
    officer4  = 'FiltOfficer4',
}

local DEFAULT_FILTERS = {
    say = true,
    yell = true,
    whisper = true,
    party = true,
    emote = false,
    npc = false,
    zone = true,
    zone_fr = true,
    zone_en = true,
    zone_de = false,
    zone_ru = false,
    zone_es = false,
    zone_jp = false,
    zone_zh = false,
    guild1 = true,
    officer1 = true,
    guild2 = true,
    officer2 = true,
    guild3 = true,
    officer3 = true,
    guild4 = true,
    officer4 = true,
    guild5 = true,
    officer5 = true,
}

local currentEditingTabId = nil
local currentSelectedIcon = '/esoui/art/collections/collections_tabIcon_itemSets_up.dds'

CustomTabs.ICON_PRESETS = {
    { key = 'star',    nameKey = 'TAB_ICON_STAR',    icon = '/esoui/art/collections/collections_tabIcon_itemSets_up.dds' },
    { key = 'gold',    nameKey = 'TAB_ICON_GOLD',    icon = '/esoui/art/bank/bank_tabicon_gold_up.dds' },
    { key = 'pvp',     nameKey = 'TAB_ICON_PVP',     icon = '/esoui/art/battlegrounds/battlegrounds_tabicon_battlegrounds_up.dds' },
    { key = 'raid',    nameKey = 'TAB_ICON_RAID',    icon = '/esoui/art/treeicons/reconstruction_tabicon_arenagroup_up.dds' },
    { key = 'dungeon', nameKey = 'TAB_ICON_DUNGEON', icon = '/esoui/art/lfg/lfg_veterandungeon_up.dds' },
    { key = 'mail',    nameKey = 'TAB_ICON_MAIL',    icon = '/esoui/art/mail/mail_tabicon_compose_up.dds' },
    { key = 'lore',    nameKey = 'TAB_ICON_LORE',    icon = '/esoui/art/journal/journal_tabicon_cadwell_up.dds' },
    { key = 'craft',   nameKey = 'TAB_ICON_CRAFT',   icon = '/esoui/art/inventory/inventory_tabicon_crafting_up.dds' },
    { key = 'telvar',  nameKey = 'TAB_ICON_TELVAR',  icon = '/esoui/art/bank/bank_tabicon_telvar_up.dds' },
    { key = 'tribute', nameKey = 'TAB_ICON_TRIBUTE', icon = '/esoui/art/tribute/tribute_tabicon_tribute_up.dds' },
}

function CustomTabs.GetTabIcon(tabData)
    if not tabData then
        return '/esoui/art/collections/collections_tabIcon_itemSets_up.dds'
    end
    if tabData.icon and tabData.icon ~= "" and tabData.icon ~= '/esoui/art/chatwindow/chat_options_up.dds' then
        return tabData.icon
    end

    local name = (tabData.name or ""):lower()
    if name:find("vente") or name:find("achat") or name:find("commerce") or name:find("trade")
       or name:find("gold") or name:find("shop") or name:find("wts") or name:find("wtb") or name:find(" or ") or name:find("bourse") then
        return '/esoui/art/bank/bank_tabicon_gold_up.dds'
    end
    if name:find("pvp") or name:find("cyro") or name:find("bg") or name:find("guerre") or name:find("war") then
        return '/esoui/art/battlegrounds/battlegrounds_tabicon_battlegrounds_up.dds'
    end
    if name:find("raid") or name:find("trial") or name:find("epreuve") or name:find("ar[eè]ne") or name:find("hm") then
        return '/esoui/art/treeicons/reconstruction_tabicon_arenagroup_up.dds'
    end
    if name:find("donjon") or name:find("dungeon") or name:find("vet") or name:find("boss") or name:find("mort") then
        return '/esoui/art/lfg/lfg_veterandungeon_up.dds'
    end
    if name:find("mail") or name:find("courrier") or name:find("lettre") or name:find("msg") or name:find("chuchot") then
        return '/esoui/art/mail/mail_tabicon_compose_up.dds'
    end
    if name:find("rp") or name:find("lore") or name:find("quete") or name:find("quest") or name:find("cadwell") or name:find("histoire") or name:find("livre") then
        return '/esoui/art/journal/journal_tabicon_cadwell_up.dds'
    end
    if name:find("craft") or name:find("artisan") or name:find("forge") or name:find("metier") or name:find("commande") then
        return '/esoui/art/inventory/inventory_tabicon_crafting_up.dds'
    end
    if name:find("telvar") or name:find("tel var") or name:find("imperial") or name:find("ci") then
        return '/esoui/art/bank/bank_tabicon_telvar_up.dds'
    end
    if name:find("tribute") or name:find("gloire") or name:find("carte") or name:find("jeu") or name:find("taverne") then
        return '/esoui/art/tribute/tribute_tabicon_tribute_up.dds'
    end

    return '/esoui/art/collections/collections_tabIcon_itemSets_up.dds'
end

function CustomTabs.UpdateIconHighlight()
    local dialog = CustomTabs.dialog
    if not dialog then return end
    local iconContainer = dialog:GetNamedChild('IconContainer')
    if not iconContainer then return end
    local highlight = iconContainer:GetNamedChild('Highlight')
    if not highlight then return end

    local targetBtn = nil
    for idx, preset in ipairs(CustomTabs.ICON_PRESETS) do
        local btn = iconContainer:GetNamedChild('Btn' .. idx)
        if btn then
            if preset.icon == currentSelectedIcon then
                targetBtn = btn
                btn:SetAlpha(1.0)
            else
                btn:SetAlpha(0.55)
            end
        end
    end

    if targetBtn then
        highlight:ClearAnchors()
        highlight:SetAnchor(CENTER, targetBtn, CENTER, 0, 0)
        highlight:SetHidden(false)
    else
        highlight:SetHidden(true)
    end
end

local function SetCheckbox(ctrlName, isChecked)
    if not CustomTabs.dialog then return end
    local ctrl = CustomTabs.dialog:GetNamedChild(ctrlName)
    if not ctrl then return end
    local check = ctrl:GetNamedChild('Check')
    if check then
        ZO_CheckButton_SetCheckState(check, isChecked == true)
    end
end

local function GetCheckbox(ctrlName)
    if not CustomTabs.dialog then return false end
    local ctrl = CustomTabs.dialog:GetNamedChild(ctrlName)
    if not ctrl then return false end
    local check = ctrl:GetNamedChild('Check')
    if check then
        return ZO_CheckButton_IsChecked(check)
    end
    return false
end

local function SetupCheckboxItem(ctrl, labelText, defaultChecked)
    if not ctrl then return end
    local check = ctrl:GetNamedChild('Check')
    local label = ctrl:GetNamedChild('Label')
    if label and labelText then
        label:SetText(labelText)
    end
    if check then
        ZO_CheckButton_SetCheckState(check, defaultChecked or false)
        check:SetHandler('OnClicked', function(self)
            if not self:IsMouseEnabled() then return end
            local newState = not ZO_CheckButton_IsChecked(self)
            ZO_CheckButton_SetCheckState(self, newState)
        end)
    end
    ctrl:SetHandler('OnMouseUp', function(self, button, upInside)
        if upInside and check and check:IsMouseEnabled() then
            local newState = not ZO_CheckButton_IsChecked(check)
            ZO_CheckButton_SetCheckState(check, newState)
        end
    end)
end

local function RefreshGuildLabels()
    if not CustomTabs.dialog then return end
    local L = AetherChat.L
    local numGuilds = GetNumGuilds() or 0
    for i = 1, 5 do
        local gCtrl = CustomTabs.dialog:GetNamedChild('FiltGuild' .. i)
        local oCtrl = CustomTabs.dialog:GetNamedChild('FiltOfficer' .. i)
        local gCheck = gCtrl and gCtrl:GetNamedChild('Check')
        local oCheck = oCtrl and oCtrl:GetNamedChild('Check')
        local gId = (i <= numGuilds) and GetGuildId(i) or 0

        if gId and gId > 0 then
            local gName = GetGuildName(gId) or (L('FILT_GUILD_PREFIX') .. ' ' .. i)
            if gCtrl then
                local lbl = gCtrl:GetNamedChild('Label')
                if lbl then lbl:SetText(gName) end
                gCtrl:SetAlpha(1.0)
                gCtrl:SetMouseEnabled(true)
                if gCheck then
                    gCheck:SetMouseEnabled(true)
                    if ZO_CheckButton_SetEnableState then
                        ZO_CheckButton_SetEnableState(gCheck, true)
                    end
                end
            end
            if oCtrl then
                local lbl = oCtrl:GetNamedChild('Label')
                if lbl then lbl:SetText(L('FILT_OFFICER_PREFIX') .. ' ' .. i) end
                oCtrl:SetAlpha(1.0)
                oCtrl:SetMouseEnabled(true)
                if oCheck then
                    oCheck:SetMouseEnabled(true)
                    if ZO_CheckButton_SetEnableState then
                        ZO_CheckButton_SetEnableState(oCheck, true)
                    end
                end
            end
        else
            if gCtrl then
                local lbl = gCtrl:GetNamedChild('Label')
                if lbl then lbl:SetText(L('FILT_GUILD_PREFIX') .. ' ' .. i .. ' (-)') end
                gCtrl:SetAlpha(0.35)
                gCtrl:SetMouseEnabled(false)
                if gCheck then
                    gCheck:SetMouseEnabled(false)
                    ZO_CheckButton_SetCheckState(gCheck, false)
                    if ZO_CheckButton_SetEnableState then
                        ZO_CheckButton_SetEnableState(gCheck, false)
                    end
                end
            end
            if oCtrl then
                local lbl = oCtrl:GetNamedChild('Label')
                if lbl then lbl:SetText(L('FILT_OFFICER_PREFIX') .. ' ' .. i .. ' (-)') end
                oCtrl:SetAlpha(0.35)
                oCtrl:SetMouseEnabled(false)
                if oCheck then
                    oCheck:SetMouseEnabled(false)
                    ZO_CheckButton_SetCheckState(oCheck, false)
                    if ZO_CheckButton_SetEnableState then
                        ZO_CheckButton_SetEnableState(oCheck, false)
                    end
                end
            end
        end
    end
end

local function OnSave()
    local dialog = CustomTabs.dialog
    if not dialog then return end
    local L = AetherChat.L

    local nameEdit = dialog:GetNamedChild('NameBG'):GetNamedChild('Edit')
    local rawName = nameEdit and nameEdit:GetText() or ""
    local cleanName = rawName:gsub("^%s+", ""):gsub("%s+$", "")
    if cleanName == "" then
        cleanName = L('TAB_NEW_DEFAULT_NAME')
    end

    local filters = {}
    for filterKey, ctrlName in pairs(FILTER_KEYS) do
        filters[filterKey] = GetCheckbox(ctrlName)
    end

    local tabId = currentEditingTabId
    if not tabId then
        tabId = 'custom_' .. tostring(GetTimeStamp()) .. '_' .. tostring(math.random(100, 999))
        if not AetherChat.savedVars.customTabOrder then
            AetherChat.savedVars.customTabOrder = {}
        end
        table.insert(AetherChat.savedVars.customTabOrder, tabId)
    end

    if not AetherChat.savedVars.customTabs then
        AetherChat.savedVars.customTabs = {}
    end

    AetherChat.savedVars.customTabs[tabId] = {
        id = tabId,
        name = cleanName,
        icon = currentSelectedIcon or CustomTabs.GetTabIcon({ name = cleanName }),
        filters = filters,
    }

    dialog:SetHidden(true)

    if AetherChat.Messenger then
        if AetherChat.Messenger.RefreshCompactTabs then
            AetherChat.Messenger.RefreshCompactTabs()
        end
        if AetherChat.Messenger.RefreshChannelList then
            AetherChat.Messenger.RefreshChannelList()
        end
        AetherChat.Messenger.SelectChannel(tabId, true, false)
    end
end

local function OnDefault()
    for filterKey, ctrlName in pairs(FILTER_KEYS) do
        local val = DEFAULT_FILTERS[filterKey]
        SetCheckbox(ctrlName, val == true)
    end
    currentSelectedIcon = '/esoui/art/collections/collections_tabIcon_itemSets_up.dds'
    CustomTabs.UpdateIconHighlight()
end

local function OnCancel()
    if CustomTabs.dialog then
        CustomTabs.dialog:SetHidden(true)
    end
end

function CustomTabs.DeleteTab(tabId)
    if not tabId or not AetherChat.savedVars or not AetherChat.savedVars.customTabs then return end

    AetherChat.savedVars.customTabs[tabId] = nil

    local order = AetherChat.savedVars.customTabOrder
    if order then
        for i = #order, 1, -1 do
            if order[i] == tabId then
                table.remove(order, i)
            end
        end
    end

    local chOrder = AetherChat.savedVars.channelOrder
    if chOrder then
        for i = #chOrder, 1, -1 do
            if chOrder[i] == tabId then
                table.remove(chOrder, i)
            end
        end
    end

    if CustomTabs.dialog and not CustomTabs.dialog:IsHidden() then
        CustomTabs.dialog:SetHidden(true)
    end

    if AetherChat.Messenger then
        if AetherChat.Messenger.GetActiveChannel and AetherChat.Messenger.GetActiveChannel() == tabId then
            AetherChat.Messenger.SelectChannel('zone', true, false)
        else
            if AetherChat.Messenger.RefreshCompactTabs then
                AetherChat.Messenger.RefreshCompactTabs()
            end
            if AetherChat.Messenger.RefreshChannelList then
                AetherChat.Messenger.RefreshChannelList()
            end
        end
    end
end

function CustomTabs.SetupDialog()
    local dialog = CustomTabs.dialog
    if not dialog then return end
    local L = AetherChat.L

    -- Dialog Titles & Static Labels
    local title = dialog:GetNamedChild('Title')
    if title then title:SetText(L('TAB_OPTIONS_TITLE')) end

    local nameLabel = dialog:GetNamedChild('NameLabel')
    if nameLabel then nameLabel:SetText(L('TAB_OPTIONS_NAME')) end

    local nameBG = dialog:GetNamedChild('NameBG')
    local nameEdit = nameBG and nameBG:GetNamedChild('Edit')
    if nameEdit then
        nameEdit:SetColor(1, 1, 1, 1)
        nameEdit:SetHandler('OnMouseUp', function(self, button, upInside)
            if upInside then
                self:TakeFocus()
            end
        end)
        nameEdit:SetHandler('OnFocusGained', function(self)
            if nameBG then
                nameBG:SetEdgeColor(0.9, 0.71, 0.35, 1.0)
            end
        end)
        nameEdit:SetHandler('OnFocusLost', function(self)
            if nameBG then
                nameBG:SetEdgeColor(0.29, 0.29, 0.29, 0.9)
            end
        end)
        nameEdit:SetHandler('OnEscape', function(self)
            self:LoseFocus()
        end)
        nameEdit:SetHandler('OnEnter', function()
            OnSave()
        end)
    end
    if nameBG then
        nameBG:SetMouseEnabled(true)
        nameBG:SetHandler('OnMouseUp', function(self, button, upInside)
            if upInside and nameEdit then
                nameEdit:TakeFocus()
            end
        end)
    end

    local iconLabel = dialog:GetNamedChild('IconLabel')
    if iconLabel then iconLabel:SetText(L('TAB_OPTIONS_ICON')) end

    local iconContainer = dialog:GetNamedChild('IconContainer')
    if iconContainer then
        for idx, preset in ipairs(CustomTabs.ICON_PRESETS) do
            local btn = iconContainer:GetNamedChild('Btn' .. idx)
            if btn then
                btn:SetHandler('OnClicked', function()
                    currentSelectedIcon = preset.icon
                    CustomTabs.UpdateIconHighlight()
                end)
                btn:SetHandler('OnMouseEnter', function(self)
                    InitializeTooltip(InformationTooltip, self, TOP, 0, -4)
                    InformationTooltip:AddLine(L(preset.nameKey), "ZoFontGame", 1, 1, 1, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
                end)
                btn:SetHandler('OnMouseExit', function()
                    ClearTooltip(InformationTooltip)
                end)
            end
        end
    end

    local filtersLabel = dialog:GetNamedChild('FiltersLabel')
    if filtersLabel then filtersLabel:SetText(L('TAB_OPTIONS_FILTERS')) end

    local channelsLabel = dialog:GetNamedChild('ChannelsLabel')
    if channelsLabel then channelsLabel:SetText(L('TAB_OPTIONS_CHANNELS')) end

    -- Buttons
    local defaultBtn = dialog:GetNamedChild('DefaultBtn')
    if defaultBtn then
        defaultBtn:SetText(L('TAB_OPTIONS_DEFAULT'))
        defaultBtn:SetHandler('OnClicked', OnDefault)
    end

    local cancelBtn = dialog:GetNamedChild('CancelBtn')
    if cancelBtn then
        cancelBtn:SetText(L('TAB_OPTIONS_CANCEL'))
        cancelBtn:SetHandler('OnClicked', OnCancel)
    end

    local deleteBtn = dialog:GetNamedChild('DeleteBtn')
    if deleteBtn then
        deleteBtn:SetText(L('TAB_OPTIONS_DELETE'))
        deleteBtn:SetHandler('OnClicked', function()
            if currentEditingTabId then
                CustomTabs.DeleteTab(currentEditingTabId)
            end
        end)
    end

    local saveBtn = dialog:GetNamedChild('SaveBtn')
    if saveBtn then
        saveBtn:SetText(L('TAB_OPTIONS_SAVE'))
        saveBtn:SetHandler('OnClicked', OnSave)
    end

    local closeBtn = dialog:GetNamedChild('CloseBtn')
    if closeBtn then
        closeBtn:SetHandler('OnClicked', OnCancel)
    end

    -- Setup Filter Checkbox Controls
    SetupCheckboxItem(dialog:GetNamedChild('FiltSay'), L('FILT_SAY'), true)
    SetupCheckboxItem(dialog:GetNamedChild('FiltWhisper'), L('FILT_WHISPER'), true)
    SetupCheckboxItem(dialog:GetNamedChild('FiltEmote'), L('FILT_EMOTE'), false)
    SetupCheckboxItem(dialog:GetNamedChild('FiltZone'), L('FILT_ZONE'), true)
    SetupCheckboxItem(dialog:GetNamedChild('FiltZoneFR'), L('FILT_ZONE_FR'), true)
    SetupCheckboxItem(dialog:GetNamedChild('FiltZoneJP'), L('FILT_ZONE_JP'), false)
    SetupCheckboxItem(dialog:GetNamedChild('FiltZoneES'), L('FILT_ZONE_ES'), false)

    SetupCheckboxItem(dialog:GetNamedChild('FiltYell'), L('FILT_YELL'), true)
    SetupCheckboxItem(dialog:GetNamedChild('FiltParty'), L('FILT_PARTY'), true)
    SetupCheckboxItem(dialog:GetNamedChild('FiltNPC'), L('FILT_NPC'), false)
    SetupCheckboxItem(dialog:GetNamedChild('FiltZoneEN'), L('FILT_ZONE_EN'), true)
    SetupCheckboxItem(dialog:GetNamedChild('FiltZoneDE'), L('FILT_ZONE_DE'), false)
    SetupCheckboxItem(dialog:GetNamedChild('FiltZoneRU'), L('FILT_ZONE_RU'), false)
    SetupCheckboxItem(dialog:GetNamedChild('FiltZoneZH'), L('FILT_ZONE_ZH'), false)

    -- Setup Guild Checkbox Controls
    for i = 1, 5 do
        SetupCheckboxItem(dialog:GetNamedChild('FiltGuild' .. i), L('FILT_GUILD_PREFIX') .. ' ' .. i, true)
        SetupCheckboxItem(dialog:GetNamedChild('FiltOfficer' .. i), L('FILT_OFFICER_PREFIX') .. ' ' .. i, true)
    end
end

function CustomTabs.OpenTabOptions(tabId)
    local dialog = CustomTabs.dialog or _G['AetherChat_TabOptionsDialog']
    if not dialog then return end
    CustomTabs.dialog = dialog

    currentEditingTabId = tabId
    RefreshGuildLabels()

    local nameBG = dialog:GetNamedChild('NameBG')
    local nameEdit = nameBG and nameBG:GetNamedChild('Edit')
    local deleteBtn = dialog:GetNamedChild('DeleteBtn')
    local L = AetherChat.L

    if tabId and AetherChat.savedVars and AetherChat.savedVars.customTabs and AetherChat.savedVars.customTabs[tabId] then
        local tabData = AetherChat.savedVars.customTabs[tabId]
        currentSelectedIcon = CustomTabs.GetTabIcon(tabData)
        if nameEdit then
            nameEdit:SetText(tabData.name or "")
        end
        if deleteBtn then
            deleteBtn:SetHidden(false)
        end
        for filterKey, ctrlName in pairs(FILTER_KEYS) do
            local val = tabData.filters and tabData.filters[filterKey]
            SetCheckbox(ctrlName, val == true)
        end
    else
        currentEditingTabId = nil
        currentSelectedIcon = '/esoui/art/collections/collections_tabIcon_itemSets_up.dds'
        local order = (AetherChat.savedVars and AetherChat.savedVars.customTabOrder) or {}
        local defaultName = L('TAB_NEW_DEFAULT_NAME') .. ' ' .. tostring(#order + 1)
        if nameEdit then
            nameEdit:SetText(defaultName)
        end
        if deleteBtn then
            deleteBtn:SetHidden(true)
        end
        for filterKey, ctrlName in pairs(FILTER_KEYS) do
            local val = DEFAULT_FILTERS[filterKey]
            SetCheckbox(ctrlName, val == true)
        end
    end

    CustomTabs.UpdateIconHighlight()

    dialog:SetHidden(false)
    if nameEdit then
        nameEdit:TakeFocus()
    end
end

function CustomTabs.GetTabs()
    return (AetherChat.savedVars and AetherChat.savedVars.customTabs) or {}
end

function CustomTabs.GetTab(tabId)
    if not tabId or not AetherChat.savedVars or not AetherChat.savedVars.customTabs then return nil end
    return AetherChat.savedVars.customTabs[tabId]
end

function CustomTabs.GetTabOrder()
    return (AetherChat.savedVars and AetherChat.savedVars.customTabOrder) or {}
end

function CustomTabs.MatchesMessage(tabData, channelType, channelKey, zoneLang)
    if not tabData or not tabData.filters then return false end
    local f = tabData.filters

    -- 1. Direct official ESO channelType matching
    if channelType == CHAT_CHANNEL_SAY then return f.say == true end
    if channelType == CHAT_CHANNEL_YELL then return f.yell == true end
    if channelType == CHAT_CHANNEL_WHISPER or channelType == CHAT_CHANNEL_WHISPER_SENT then return f.whisper == true end
    if channelType == CHAT_CHANNEL_PARTY or channelType == CHAT_CHANNEL_INSTANCE_POPULATION then return f.party == true end
    if channelType == CHAT_CHANNEL_EMOTE then return f.emote == true end
    if channelType == CHAT_CHANNEL_MONSTER_SAY or channelType == CHAT_CHANNEL_MONSTER_YELL
       or channelType == CHAT_CHANNEL_MONSTER_EMOTE or channelType == CHAT_CHANNEL_MONSTER_WHISPER then
        return f.npc == true
    end
    if channelType == CHAT_CHANNEL_ZONE then return f.zone == true end
    if channelType == CHAT_CHANNEL_ZONE_LANGUAGE_1 then return f.zone_en == true or f.zone == true end
    if channelType == CHAT_CHANNEL_ZONE_LANGUAGE_2 then return f.zone_fr == true or f.zone == true end
    if channelType == CHAT_CHANNEL_ZONE_LANGUAGE_3 then return f.zone_de == true or f.zone == true end
    if channelType == CHAT_CHANNEL_ZONE_LANGUAGE_4 then return f.zone_ru == true or f.zone == true end
    if channelType == CHAT_CHANNEL_ZONE_LANGUAGE_6 then return f.zone_es == true or f.zone == true end
    if CHAT_CHANNEL_ZONE_LANGUAGE_7 and channelType == CHAT_CHANNEL_ZONE_LANGUAGE_7 then return f.zone_jp == true or f.zone == true end
    if CHAT_CHANNEL_ZONE_LANGUAGE_8 and channelType == CHAT_CHANNEL_ZONE_LANGUAGE_8 then return f.zone_zh == true or f.zone == true end

    if channelType == CHAT_CHANNEL_GUILD_1 then return f.guild1 == true end
    if channelType == CHAT_CHANNEL_GUILD_2 then return f.guild2 == true end
    if channelType == CHAT_CHANNEL_GUILD_3 then return f.guild3 == true end
    if channelType == CHAT_CHANNEL_GUILD_4 then return f.guild4 == true end
    if channelType == CHAT_CHANNEL_GUILD_5 then return f.guild5 == true end

    if channelType == CHAT_CHANNEL_OFFICER_1 then return f.officer1 == true end
    if channelType == CHAT_CHANNEL_OFFICER_2 then return f.officer2 == true end
    if channelType == CHAT_CHANNEL_OFFICER_3 then return f.officer3 == true end
    if channelType == CHAT_CHANNEL_OFFICER_4 then return f.officer4 == true end
    if channelType == CHAT_CHANNEL_OFFICER_5 then return f.officer5 == true end

    -- 2. Fallback matching via channelKey
    if channelKey then
        if channelKey == 'say' then return f.say == true end
        if channelKey == 'yell' then return f.yell == true end
        if channelKey == 'party' then return f.party == true end
        if channelKey:find('^dm:') then return f.whisper == true end
        if channelKey == 'guild1' then return f.guild1 == true end
        if channelKey == 'guild2' then return f.guild2 == true end
        if channelKey == 'guild3' then return f.guild3 == true end
        if channelKey == 'guild4' then return f.guild4 == true end
        if channelKey == 'guild5' then return f.guild5 == true end
        if channelKey == 'officer1' then return f.officer1 == true end
        if channelKey == 'officer2' then return f.officer2 == true end
        if channelKey == 'officer3' then return f.officer3 == true end
        if channelKey == 'officer4' then return f.officer4 == true end
        if channelKey == 'officer5' then return f.officer5 == true end
        if channelKey == 'general' then
            return (f.say == true) or (f.yell == true) or (f.emote == true) or (f.npc == true)
        end
        if channelKey == 'zone' then
            if zoneLang == 'fr' then return f.zone_fr == true or f.zone == true end
            if zoneLang == 'en' then return f.zone_en == true or f.zone == true end
            if zoneLang == 'de' then return f.zone_de == true or f.zone == true end
            if zoneLang == 'es' then return f.zone_es == true or f.zone == true end
            return f.zone == true
        end
    end

    return false
end

function CustomTabs.GetPrimaryChatChannel(tabData)
    if not tabData or not tabData.filters then return CHAT_CHANNEL_ZONE, nil end
    local f = tabData.filters
    if f.guild1 then return CHAT_CHANNEL_GUILD_1, nil end
    if f.guild2 then return CHAT_CHANNEL_GUILD_2, nil end
    if f.guild3 then return CHAT_CHANNEL_GUILD_3, nil end
    if f.guild4 then return CHAT_CHANNEL_GUILD_4, nil end
    if f.guild5 then return CHAT_CHANNEL_GUILD_5, nil end
    if f.party then return CHAT_CHANNEL_PARTY, nil end
    if f.zone_fr then return CHAT_CHANNEL_ZONE_LANGUAGE_2, nil end
    if f.zone_en then return CHAT_CHANNEL_ZONE_LANGUAGE_1, nil end
    if f.zone then return CHAT_CHANNEL_ZONE, nil end
    if f.say then return CHAT_CHANNEL_SAY, nil end
    if f.officer1 then return CHAT_CHANNEL_OFFICER_1, nil end
    if f.yell then return CHAT_CHANNEL_YELL, nil end
    return CHAT_CHANNEL_ZONE, nil
end

function CustomTabs.Initialize()
    if not AetherChat.savedVars then return end
    if not AetherChat.savedVars.customTabs then
        AetherChat.savedVars.customTabs = {}
    end
    if not AetherChat.savedVars.customTabOrder then
        AetherChat.savedVars.customTabOrder = {}
    end

    CustomTabs.dialog = _G['AetherChat_TabOptionsDialog']
    if CustomTabs.dialog then
        CustomTabs.SetupDialog()
    end
end
